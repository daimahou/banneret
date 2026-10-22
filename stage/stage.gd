class_name Stage
extends Control

signal laid_out
signal map_node_pressed(map_node: MapNode)
signal offer_pressed(offer: Offer)

const TRAVEL_DURATION := 0.6
const TRAVEL_TRANSITION := Tween.TRANS_SINE
const TRAVEL_EASE := Tween.EASE_IN_OUT

const VISITATION_HIGHLIGHTS: Dictionary[MissionModel.Visitation, Flat.Highlight] = {
	MissionModel.Visitation.CLOSED: Flat.Highlight.DIMMED,
	MissionModel.Visitation.AHEAD: Flat.Highlight.NONE,
	MissionModel.Visitation.OPEN: Flat.Highlight.NONE,
	MissionModel.Visitation.TRAVELLED: Flat.Highlight.TRAVELLED,
	MissionModel.Visitation.CURRENT: Flat.Highlight.TRAVELLED,
}

var _flats: Array[Flat] = []
var _road_dashes: Array[Flat.RoadDash] = []
var _mission_model: MissionModel
var _map_node_under_mouse: MapNode
var _coach_tween: Tween

@onready var _flats_container: HBoxContainer = $Flats
@onready var _coach: Node2D = $Coach
@onready var _offer_presenter: OfferPresenter = $OfferPresenter
@onready var _coach_start_x := _coach.position.x


func _ready() -> void:
	for child in _flats_container.get_children():
		if child is Flat:
			_flats.append(child)
			child.map_node_pressed.connect(map_node_pressed.emit)
			child.map_node_mouse_entered.connect(_on_map_node_mouse_entered)
			child.map_node_mouse_exited.connect(_on_map_node_mouse_exited)
	_offer_presenter.offer_pressed.connect(offer_pressed.emit)
	# The container sizes the flats on its first sort, which is still pending here.
	await _flats_container.sort_children
	laid_out.emit()


# Roads draw from their own seed, derived from `map_seed`.
func show_mission(mission_model: MissionModel, map_seed: int) -> void:
	var mission_map := mission_model.mission_map
	var column_count := MissionMapGenerator.ENCOUNTER_COLUMN + 1
	if column_count > _flats.size():
		push_error("Mission map has %d columns but the stage has %d flats" % [column_count, _flats.size()])
		return

	_mission_model = mission_model
	_map_node_under_mouse = null
	if _coach_tween != null:
		_coach_tween.kill()
	_coach.position.x = _coach_start_x
	_offer_presenter.clear()

	for column in column_count:
		_flats[column].show_column(mission_map.get_column(column))
	for flat in _flats.slice(column_count):
		flat.clear()

	var flat_rects: Array[Rect2] = []
	for flat in _flats:
		flat_rects.append(_get_stage_rect(flat))
	var map_node_positions: Dictionary[MapNode, Vector2] = {}
	for map_node in mission_map.map_nodes:
		map_node_positions[map_node] = flat_rects[map_node.column].position + _flats[map_node.column].get_map_node_position(map_node)

	# A seed of their own, so they don't replay the generator's random sequence.
	var road_seed := hash([map_seed, "roads"])
	_road_dashes = RoadLayout.lay_out(mission_map, flat_rects, map_node_positions, road_seed)
	for road_dash in _road_dashes:
		_add_road_dash_to_flat(road_dash, flat_rects)
	_update_highlights()


# Shows the model after the coach travelled to `map_node`, and returns once the coach is there.
func show_travel(map_node: MapNode) -> void:
	_coach_tween = create_tween().set_trans(TRAVEL_TRANSITION).set_ease(TRAVEL_EASE)
	_coach_tween.tween_property(_coach, "position:x", _get_stage_rect(_flats[map_node.column]).get_center().x, TRAVEL_DURATION)
	_update_highlights()
	await _coach_tween.finished
	_update_highlights()


# Returns once the offers hang still.
func show_offers(offers: Array[Offer]) -> void:
	await _offer_presenter.show_offers(offers)


# Shows the model after the pick, and returns once the offers are gone.
func hide_offers() -> void:
	_update_highlights()
	await _offer_presenter.hide_offers()


func _get_stage_rect(flat: Flat) -> Rect2:
	return Rect2(_flats_container.position + flat.position, flat.size)


# Merging can move a dash, so it goes to the flat that contains it now; one left in a gap between flats is dropped.
func _add_road_dash_to_flat(road_dash: Flat.RoadDash, flat_rects: Array[Rect2]) -> void:
	for index in flat_rects.size():
		if flat_rects[index].has_point(road_dash.position):
			road_dash.position -= flat_rects[index].position
			_flats[index].add_road_dash(road_dash)
			return


# Nothing is pickable while the coach moves.
func _is_pickable(map_node: MapNode) -> bool:
	var is_coach_moving := _coach_tween != null and _coach_tween.is_running()
	return not is_coach_moving and _mission_model.get_map_node_visitation(map_node) == MissionModel.Visitation.OPEN


# Hover follows the mouse even over a node that isn't pickable, so it shows as soon as that node opens.
func _on_map_node_mouse_entered(map_node: MapNode) -> void:
	_map_node_under_mouse = map_node
	_update_highlights()


func _on_map_node_mouse_exited(map_node: MapNode) -> void:
	if map_node != _map_node_under_mouse:
		return
	_map_node_under_mouse = null
	_update_highlights()


func _update_highlights() -> void:
	var hovered_map_node: MapNode = null
	if _map_node_under_mouse != null and _is_pickable(_map_node_under_mouse):
		hovered_map_node = _map_node_under_mouse
	for map_node in _mission_model.mission_map.map_nodes:
		var highlight := VISITATION_HIGHLIGHTS[_mission_model.get_map_node_visitation(map_node)]
		if map_node == hovered_map_node:
			highlight = Flat.Highlight.HOVERED
		_flats[map_node.column].set_map_node_highlight(map_node, highlight, _is_pickable(map_node))
	for road_dash in _road_dashes:
		road_dash.highlight = Flat.Highlight.DIMMED
		for road in road_dash.roads:
			road_dash.highlight = maxi(road_dash.highlight, _get_road_highlight(road, hovered_map_node)) as Flat.Highlight
	for flat in _flats:
		flat.redraw_road_dashes()


func _get_road_highlight(road: RoadLayout.Road, hovered_map_node: MapNode) -> Flat.Highlight:
	if road.end_node == hovered_map_node and road.start_node == _mission_model.get_current_map_node():
		return Flat.Highlight.HOVERED
	return VISITATION_HIGHLIGHTS[_mission_model.get_road_visitation(road.start_node, road.end_node)]
