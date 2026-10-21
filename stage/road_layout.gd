class_name RoadLayout
extends RefCounted

const ROAD_DASH_TEXTURES: Array[Texture2D] = [
	preload("res://art/map/road_dash_a.png"),
	preload("res://art/map/road_dash_b.png"),
	preload("res://art/map/road_dash_c.png"),
]

# Road dash layout, in design units and radians.
const ROAD_DASH_GAP := 16.0
const ROAD_DASH_TILT := 0.05
const ROAD_END_GAP := 16.0
const ROAD_SPAN_STEP := 4.0

# Road dash merging, in design units.
const ROAD_DASH_PRUNE_OVERLAP := 10.0
const ROAD_DASH_SHARED_NODE_MERGE_GAP := 30.0
const ROAD_SHARED_NODE_RADIUS := 250.0

# A lead-in road, from the imaginary flat left of the first flat, has no start node.
class Road:
	var curve: Curve2D
	var length: float
	var start_node: MapNode
	var end_node: MapNode

# Where a laid dash sits on one road; `offset` is along the road's curve.
class RoadPlace:
	var road: Road
	var offset: float
	var is_first_step: bool

# A road dash in stage space, with every road it sits on.
class LaidRoadDash:
	var road_dash: Flat.RoadDash
	var places: Array[RoadPlace] = []
	var footprint: RoadDashFootprint

# The capsule a road dash covers, in stage space.
class RoadDashFootprint:
	var start: Vector2
	var end: Vector2
	var radius: float

var _flat_rects: Array[Rect2] = []
var _map_node_positions: Dictionary[MapNode, Vector2] = {}
var _rng := RandomNumberGenerator.new()


# The mission map's road dashes in stage space, given each flat's rect and each map node's position in stage space.
static func lay_out(mission_map: MissionMap, flat_rects: Array[Rect2], map_node_positions: Dictionary[MapNode, Vector2], road_seed: int) -> Array[Flat.RoadDash]:
	var road_layout := RoadLayout.new()
	road_layout._flat_rects = flat_rects
	road_layout._map_node_positions = map_node_positions
	road_layout._rng.seed = road_seed

	var laid: Array[LaidRoadDash] = []
	for map_node in mission_map.get_column(0):
		var wobble := road_layout._rng.randf_range(-MissionMapGenerator.EDGE_WOBBLE, MissionMapGenerator.EDGE_WOBBLE)
		road_layout._add_road(laid, null, map_node, wobble)
	for map_edge in mission_map.map_edges:
		road_layout._add_road(laid, map_edge.start, map_edge.end, map_edge.wobble)

	var road_dashes: Array[Flat.RoadDash] = []
	for laid_road_dash in prune_road_dashes(laid):
		for place in laid_road_dash.places:
			laid_road_dash.road_dash.roads.append(place.road)
		road_dashes.append(laid_road_dash.road_dash)
	return road_dashes


static func create_laid_road_dash(texture: Texture2D, dash_position: Vector2, angle: float, road: Road, offset: float, is_first_step: bool) -> LaidRoadDash:
	var road_dash := Flat.RoadDash.new()
	road_dash.texture = texture
	road_dash.position = dash_position
	road_dash.rotation = angle
	var place := RoadPlace.new()
	place.road = road
	place.offset = offset
	place.is_first_step = is_first_step
	var laid_road_dash := LaidRoadDash.new()
	laid_road_dash.road_dash = road_dash
	laid_road_dash.places.append(place)
	laid_road_dash.footprint = _create_footprint(road_dash)
	return laid_road_dash


# Where roads branch or converge, a dash whose ink really overlaps one kept from another road is merged into the
# one it overlaps most; the merged dash moves, so it is checked again against the rest until it overlaps none.
# A merged dash takes the average position and rotation of every dash in it, so it sits on all their roads.
static func prune_road_dashes(laid: Array[LaidRoadDash]) -> Array[LaidRoadDash]:
	var kept: Array[LaidRoadDash] = []
	for candidate in laid:
		var merged := candidate
		var target := _find_merge_target(kept, merged)
		while target != null:
			kept.erase(target)
			_merge_road_dash(target, merged)
			merged = target
			target = _find_merge_target(kept, merged)
		kept.append(merged)
	return kept


# Flat 1's lead-in roads start one flat-width left of it, each at its own node's height, so they come in
# side by side rather than fanning out of one point.
func _get_lead_in_start(end: Vector2) -> Vector2:
	var first_flat_rect := _flat_rects[0]
	return Vector2(first_flat_rect.get_center().x - first_flat_rect.size.x, end.y)


# Dashes stop short of a node's icon; a lead-in road has no icon at its start.
func _get_road_end_clearance(map_node: MapNode) -> float:
	if map_node == null:
		return 0.0
	return MapNode.EVENT_ICONS[map_node.event_type].get_width() / 2.0 + ROAD_END_GAP


# A road's middle sits `wobble` off the straight line; the quadratic control point is twice that. The control
# point stays within the flats' height, and a quadratic curve stays within its points, so no road bulges off the flats.
func _add_road(laid: Array[LaidRoadDash], start_node: MapNode, end_node: MapNode, wobble: float) -> void:
	var end := _map_node_positions[end_node]
	var start := _get_lead_in_start(end) if start_node == null else _map_node_positions[start_node]
	var control := (start + end) / 2.0 + (end - start).orthogonal().normalized() * wobble * 2.0
	control.y = clampf(control.y, _flat_rects[0].position.y, _flat_rects[0].end.y)
	var road := Road.new()
	road.curve = Curve2D.new()
	road.curve.add_point(start, Vector2.ZERO, (control - start) * 2.0 / 3.0)
	road.curve.add_point(end, (control - end) * 2.0 / 3.0)
	road.length = road.curve.get_baked_length()
	road.start_node = start_node
	road.end_node = end_node

	var road_dashes: Array[LaidRoadDash] = []
	var from := _get_road_end_clearance(start_node)
	var to := road.length - _get_road_end_clearance(end_node)
	for span in _get_flat_spans(road.curve, from, to):
		if span.y <= span.x:
			continue
		# A span against one of the road's nodes hugs it and leaves its slack at the seam.
		var touches_start := start_node != null and span.x <= from + ROAD_SPAN_STEP
		var touches_end := span.y >= to - ROAD_SPAN_STEP
		var slack_before := 0.5
		if touches_start and not touches_end:
			slack_before = 0.0
		elif touches_end and not touches_start:
			slack_before = 1.0
		_add_span_road_dashes(road_dashes, road, span, slack_before)
	if road_dashes.is_empty():
		return

	var first_step := road_dashes[0]
	for laid_road_dash in road_dashes:
		if laid_road_dash.places[0].offset < first_step.places[0].offset:
			first_step = laid_road_dash
	first_step.places[0].is_first_step = true
	laid.append_array(road_dashes)


# The stretch of the curve inside each flat, as (from, to) offsets in flat order; empty when to <= from.
func _get_flat_spans(curve: Curve2D, from: float, to: float) -> Array[Vector2]:
	var spans: Array[Vector2] = []
	for flat_rect in _flat_rects:
		spans.append(Vector2(INF, -INF))
	var offset := from
	while offset <= to:
		var point := curve.sample_baked(offset)
		for index in _flat_rects.size():
			if _flat_rects[index].has_point(point):
				spans[index] = Vector2(minf(spans[index].x, offset), maxf(spans[index].y, offset))
		offset += ROAD_SPAN_STEP
	return spans


# Dashes run along the span with `slack_before` of its spare room ahead of them, so a road breaks only at the gap
# between flats. A variant too wide for what is left gives way to one that fits; a span too short for any, but at
# least half the narrowest, still gets the narrowest, overhanging both ends a little.
func _add_span_road_dashes(road_dashes: Array[LaidRoadDash], road: Road, span: Vector2, slack_before: float) -> void:
	var span_length := span.y - span.x
	var textures: Array[Texture2D] = []
	var run_length := 0.0
	while true:
		var room := span_length - run_length - (0.0 if textures.is_empty() else ROAD_DASH_GAP)
		var fitting: Array[Texture2D] = []
		for texture in ROAD_DASH_TEXTURES:
			if texture.get_width() <= room:
				fitting.append(texture)
		if fitting.is_empty():
			break
		var texture := fitting[_rng.randi_range(0, fitting.size() - 1)]
		run_length += texture.get_width() + (0.0 if textures.is_empty() else ROAD_DASH_GAP)
		textures.append(texture)

	if textures.is_empty():
		var narrowest := _get_narrowest_road_dash_texture()
		if span_length < narrowest.get_width() / 2.0:
			return
		textures.append(narrowest)
		run_length = narrowest.get_width()

	var offset := span.x + (span_length - run_length) * slack_before
	for texture in textures:
		var dash_offset := offset + texture.get_width() / 2.0
		var direction := road.curve.sample_baked(dash_offset + 1.0) - road.curve.sample_baked(dash_offset - 1.0)
		var angle := direction.angle() + _rng.randf_range(-ROAD_DASH_TILT, ROAD_DASH_TILT)
		road_dashes.append(create_laid_road_dash(texture, road.curve.sample_baked(dash_offset), angle, road, dash_offset, false))
		offset += texture.get_width() + ROAD_DASH_GAP


static func _get_narrowest_road_dash_texture() -> Texture2D:
	var narrowest := ROAD_DASH_TEXTURES[0]
	for texture in ROAD_DASH_TEXTURES:
		if texture.get_width() < narrowest.get_width():
			narrowest = texture
	return narrowest


static func _find_merge_target(kept: Array[LaidRoadDash], candidate: LaidRoadDash) -> LaidRoadDash:
	var target: LaidRoadDash = null
	var deepest := 0.0
	for other in kept:
		if _is_sharing_road(candidate, other) or not _can_merge(candidate, other):
			continue
		var closest := Geometry2D.get_closest_points_between_segments(candidate.footprint.start, candidate.footprint.end, other.footprint.start, other.footprint.end)
		var gap := closest[0].distance_to(closest[1]) - candidate.footprint.radius - other.footprint.radius
		var depth := _get_merge_gap(candidate, other) - gap
		if depth > deepest:
			deepest = depth
			target = other
	return target


static func _is_sharing_road(laid_road_dash: LaidRoadDash, other: LaidRoadDash) -> bool:
	for place in laid_road_dash.places:
		for other_place in other.places:
			if place.road == other_place.road:
				return true
	return false


# A step out of a node never merges with a road from another node, so every map node shows its own way out:
# where either dash holds a first step, every road in both must start at that one node.
static func _can_merge(laid_road_dash: LaidRoadDash, other: LaidRoadDash) -> bool:
	var places := laid_road_dash.places + other.places
	var holds_first_step := places.any(func(place: RoadPlace) -> bool: return place.is_first_step)
	if not holds_first_step:
		return true
	var start_node := places[0].road.start_node
	return start_node != null and places.all(func(place: RoadPlace) -> bool: return place.road.start_node == start_node)


# Near a node two roads share, dashes merge as soon as they are near: roads out of one node start as one and
# diverge, roads into one node join before they arrive. Elsewhere only really overlapping ink merges.
static func _get_merge_gap(laid_road_dash: LaidRoadDash, other: LaidRoadDash) -> float:
	for place in laid_road_dash.places:
		for other_place in other.places:
			if _is_near_shared_node(place, other_place):
				return ROAD_DASH_SHARED_NODE_MERGE_GAP
	return -ROAD_DASH_PRUNE_OVERLAP


static func _is_near_shared_node(place: RoadPlace, other_place: RoadPlace) -> bool:
	var road := place.road
	var other_road := other_place.road
	var near_shared_start := road.start_node != null and road.start_node == other_road.start_node \
		and place.offset < ROAD_SHARED_NODE_RADIUS \
		and other_place.offset < ROAD_SHARED_NODE_RADIUS
	var near_shared_end := road.end_node == other_road.end_node \
		and road.length - place.offset < ROAD_SHARED_NODE_RADIUS \
		and other_road.length - other_place.offset < ROAD_SHARED_NODE_RADIUS
	return near_shared_start or near_shared_end


# Each dash weighs as many as it holds, so the result is the plain average of them all; the merged dash then sits
# on every road either sat on.
static func _merge_road_dash(target: LaidRoadDash, merged: LaidRoadDash) -> void:
	var weight := float(merged.places.size()) / (target.places.size() + merged.places.size())
	target.road_dash.position = target.road_dash.position.lerp(merged.road_dash.position, weight)
	target.road_dash.rotation = lerp_angle(target.road_dash.rotation, merged.road_dash.rotation, weight)
	target.places.append_array(merged.places)
	target.footprint = _create_footprint(target.road_dash)


# Takes the dash in stage space.
static func _create_footprint(road_dash: Flat.RoadDash) -> RoadDashFootprint:
	var footprint := RoadDashFootprint.new()
	footprint.radius = road_dash.texture.get_height() / 2.0
	var half_axis := maxf(road_dash.texture.get_width() / 2.0 - footprint.radius, 0.0)
	var axis := Vector2.from_angle(road_dash.rotation) * half_axis
	footprint.start = road_dash.position - axis
	footprint.end = road_dash.position + axis
	return footprint
