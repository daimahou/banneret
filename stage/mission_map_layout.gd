class_name MissionMapLayout
extends RefCounted

const MAP_NODE_MIN_SPACING := 190.0
# Kept clear above the first row and below the last, in design units.
const MAP_NODE_MARGIN := 40.0

# Positions are in flat space.
var _map_node_positions: Dictionary[MapNode, Vector2] = {}
var _flat_map_nodes: Array[Array] = []
var _flat_road_dashes: Array[Array] = []


# The flats sit side by side from the scenery's origin, `separation` apart.
# Roads draw from their own seed, derived from `map_seed`.
static func create(mission_map: MissionMap, map_seed: int, flat_size: Vector2, separation: float, flat_count: int) -> MissionMapLayout:
	var layout := MissionMapLayout.new()
	var flat_rects: Array[Rect2] = []
	var scenery_positions: Dictionary[MapNode, Vector2] = {}
	for index in flat_count:
		flat_rects.append(Rect2(Vector2(index * (flat_size.x + separation), 0.0), flat_size))
		var column := mission_map.get_column(index)
		var rows: Array[int] = []
		rows.assign(column.map(func(map_node: MapNode) -> int: return map_node.row))
		for map_node in column:
			layout._map_node_positions[map_node] = _get_map_node_position(map_node, rows, flat_size)
			scenery_positions[map_node] = flat_rects[index].position + layout._map_node_positions[map_node]
		layout._flat_map_nodes.append(column)
		var road_dashes: Array[Flat.RoadDash] = []
		layout._flat_road_dashes.append(road_dashes)

	# A seed of their own, so they don't replay the generator's random sequence.
	var road_seed := hash([map_seed, "roads"])
	# Merging can move a dash, so it goes to the flat that contains it now; one left in a gap between flats is dropped.
	for road_dash in RoadLayout.lay_out(mission_map, flat_rects, scenery_positions, road_seed):
		for index in flat_count:
			if flat_rects[index].has_point(road_dash.position):
				road_dash.position -= flat_rects[index].position
				layout._flat_road_dashes[index].append(road_dash)
				break
	return layout


func get_map_nodes(flat_index: int) -> Array[MapNode]:
	return _flat_map_nodes[flat_index]


func get_map_node_position(map_node: MapNode) -> Vector2:
	return _map_node_positions[map_node]


func get_road_dashes(flat_index: int) -> Array[Flat.RoadDash]:
	return _flat_road_dashes[flat_index]


# The jitter towards a neighbouring row among `rows`, the column's, is capped, so neighbours stay MAP_NODE_MIN_SPACING apart.
static func _get_map_node_position(map_node: MapNode, rows: Array[int], flat_size: Vector2) -> Vector2:
	var row_spacing := (flat_size.y - MAP_NODE_MARGIN * 2.0) / MissionMapGenerator.ROW_COUNT
	# Never negative: a flat too short for the spacing loses its jitter towards neighbours rather than pushing them apart.
	var jitter_cap := maxf((row_spacing - MAP_NODE_MIN_SPACING) / 2.0, 0.0)
	var jitter := map_node.jitter
	if map_node.row - 1 in rows:
		jitter.y = maxf(jitter.y, -jitter_cap)
	if map_node.row + 1 in rows:
		jitter.y = minf(jitter.y, jitter_cap)
	return Vector2(flat_size.x / 2.0, MAP_NODE_MARGIN + row_spacing * (map_node.row + 0.5)) + jitter
