class_name Scenery
extends HBoxContainer

signal map_node_pressed(map_node: MapNode)

# A flat's flip, and the time from one flat starting to the next: below the duration, flips overlap.
const FLIP_DURATION := 0.2
const FLIP_STAGGER := 0.1
const FLIP_TRANSITION := Tween.TRANS_SINE

const BATTLEGROUND: Texture2D = preload("res://art/stage/battleground.png")

const VISITATION_HIGHLIGHTS: Dictionary[MissionModel.Visitation, Ink.Highlight] = {
	MissionModel.Visitation.CLOSED: Ink.Highlight.DIMMED,
	MissionModel.Visitation.AHEAD: Ink.Highlight.NONE,
	MissionModel.Visitation.OPEN: Ink.Highlight.NONE,
	MissionModel.Visitation.TRAVELLED: Ink.Highlight.TRAVELLED,
	MissionModel.Visitation.CURRENT: Ink.Highlight.TRAVELLED,
}

var _mission_model: MissionModel
var _mission_map_layout: MissionMapLayout
var _map_node_under_mouse: MapNode
var _is_mission_map_shown := false
var _is_input_enabled := true

@onready var _flats: Array[Flat] = Array(get_children(), TYPE_OBJECT, &"Control", Flat)


func _ready() -> void:
	for flat in _flats:
		flat.map_node_pressed.connect(map_node_pressed.emit)
		flat.map_node_mouse_entered.connect(_on_map_node_mouse_entered)
		flat.map_node_mouse_exited.connect(_on_map_node_mouse_exited)


func show_mission_map(mission_model: MissionModel, map_seed: int) -> void:
	_set_mission(mission_model, map_seed)
	for index in _flats.size():
		_flats[index].show_column(_mission_map_layout, index)
	_is_mission_map_shown = true
	update_highlights()


# Returns once the last flat has flipped.
func flip_to_mission_map(mission_model: MissionModel, map_seed: int) -> void:
	_set_mission(mission_model, map_seed)
	await _flip_flats(func(flat: Flat) -> void: flat.show_column(_mission_map_layout, _flats.find(flat)))
	_is_mission_map_shown = true
	update_highlights()


# The battle illustration is centred on the scenery, each flat showing the part under it; a bigger one is cropped.
# Returns once the last flat has flipped.
func flip_to_battle() -> void:
	_is_mission_map_shown = false
	var texture_size := BATTLEGROUND.get_size()
	if texture_size.x < size.x or texture_size.y < size.y:
		push_warning("The battle illustration (%s) is smaller than the scenery (%s)" % [texture_size, size])
	var origin := (texture_size - size) / 2.0
	await _flip_flats(func(flat: Flat) -> void: flat.show_battle(BATTLEGROUND, Rect2(origin + flat.position, flat.size)))


# Map nodes are pickable only while input is enabled.
func set_input_enabled(is_enabled: bool) -> void:
	_is_input_enabled = is_enabled
	update_highlights()


# In the space the scenery is placed in.
func get_column_center_x(column: int) -> float:
	var flat := _flats[column]
	return position.x + flat.position.x + flat.size.x / 2.0


# Away from the mission map, a flat may not show its column yet; the flip back updates once it is done.
func update_highlights() -> void:
	if not _is_mission_map_shown:
		return
	var hovered_map_node: MapNode = null
	if _map_node_under_mouse != null and _is_pickable(_map_node_under_mouse):
		hovered_map_node = _map_node_under_mouse
	for index in _flats.size():
		var flat := _flats[index]
		for map_node in _mission_map_layout.get_map_nodes(index):
			var highlight := VISITATION_HIGHLIGHTS[_mission_model.get_map_node_visitation(map_node)]
			if map_node == hovered_map_node:
				highlight = Ink.Highlight.HOVERED
			flat.set_map_node_highlight(map_node, highlight, _is_pickable(map_node))
		var road_dash_highlights: Dictionary[Flat.RoadDash, Ink.Highlight] = {}
		for road_dash in _mission_map_layout.get_road_dashes(index):
			var highlight := Ink.Highlight.DIMMED
			for road in road_dash.roads:
				highlight = maxi(highlight, _get_road_highlight(road, hovered_map_node)) as Ink.Highlight
			road_dash_highlights[road_dash] = highlight
		flat.set_road_dash_highlights(road_dash_highlights)


func _set_mission(mission_model: MissionModel, map_seed: int) -> void:
	var column_count := MissionMapGenerator.ENCOUNTER_COLUMN + 1
	if column_count > _flats.size():
		push_error("Mission map has %d columns but the scenery has %d flats" % [column_count, _flats.size()])
	_mission_model = mission_model
	_map_node_under_mouse = null
	_is_mission_map_shown = false
	_mission_map_layout = MissionMapLayout.create(mission_model.mission_map, map_seed, _flats[0].size, get_theme_constant("separation"), _flats.size())


# One flat after another, left to right, each starting a stagger after the last; each swaps its content while edge-on. Returns once the last flat has flipped.
func _flip_flats(swap_content: Callable) -> void:
	var tween := create_tween().set_parallel().set_trans(FLIP_TRANSITION)
	for index in _flats.size():
		var flat := _flats[index]
		flat.pivot_offset = flat.size / 2.0
		var start := index * FLIP_STAGGER
		var edge_on := start + FLIP_DURATION / 2.0
		tween.tween_property(flat, "scale:x", 0.0, FLIP_DURATION / 2.0).set_ease(Tween.EASE_IN).set_delay(start)
		tween.tween_callback(swap_content.bind(flat)).set_delay(edge_on)
		tween.tween_property(flat, "scale:x", 1.0, FLIP_DURATION / 2.0).set_ease(Tween.EASE_OUT).set_delay(edge_on)
	await tween.finished


func _is_pickable(map_node: MapNode) -> bool:
	return _is_input_enabled and _mission_model.get_map_node_visitation(map_node) == MissionModel.Visitation.OPEN


# Hover follows the mouse even over a node that isn't pickable, so it shows as soon as that node opens.
func _on_map_node_mouse_entered(map_node: MapNode) -> void:
	_map_node_under_mouse = map_node
	update_highlights()


func _on_map_node_mouse_exited(map_node: MapNode) -> void:
	if map_node != _map_node_under_mouse:
		return
	_map_node_under_mouse = null
	update_highlights()


func _get_road_highlight(road: RoadLayout.Road, hovered_map_node: MapNode) -> Ink.Highlight:
	if road.end_node == hovered_map_node and road.start_node == _mission_model.get_current_map_node():
		return Ink.Highlight.HOVERED
	return VISITATION_HIGHLIGHTS[_mission_model.get_road_visitation(road.start_node, road.end_node)]
