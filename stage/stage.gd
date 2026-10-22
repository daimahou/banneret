class_name Stage
extends Control

signal laid_out
signal map_node_pressed(map_node: MapNode)
signal offer_pressed(offer: Offer)

enum View { MISSION_MAP, TRANSITION, FIGHT }

const TRAVEL_DURATION := 0.6
const TRAVEL_TRANSITION := Tween.TRANS_SINE
const TRAVEL_EASE := Tween.EASE_IN_OUT

# A transition's beats, in seconds; slides ease like travel.
const COACH_SLIDE_DURATION := 0.8
const FLAT_FLIP_DURATION := 0.4
const PUPPET_SLIDE_DURATION := 0.8

# Beyond the curtains, in design units.
const OFFSTAGE_LEFT_X := -400.0
const OFFSTAGE_RIGHT_X := 4240.0

const BATTLEGROUND: Texture2D = preload("res://art/stage/battleground.png")
# The panels painted on the background, in design units.
const BATTLEGROUND_RECT := Rect2(971, 373, 1938, 744)

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
var _view := View.MISSION_MAP
# Each fight puppet slides out to where it came in from.
var _puppet_offstage_xs: Dictionary[Puppet, float] = {}

@onready var _flats_container: HBoxContainer = $Flats
@onready var _coach: Puppet = $Coach
@onready var _puppets: Node2D = $Puppets
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


func is_in_transition() -> bool:
	return _view == View.TRANSITION


# Roads draw from their own seed, derived from `map_seed`.
# Over the fight, plays the transition back and returns once it is done.
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
	_offer_presenter.clear()

	var flat_rects: Array[Rect2] = []
	for flat in _flats:
		flat_rects.append(_get_stage_rect(flat))
	var map_node_positions: Dictionary[MapNode, Vector2] = {}
	for map_node in mission_map.map_nodes:
		var column := mission_map.get_column(map_node.column)
		map_node_positions[map_node] = flat_rects[map_node.column].position + _flats[map_node.column].get_map_node_position(map_node, column)

	# A seed of their own, so they don't replay the generator's random sequence.
	var road_seed := hash([map_seed, "roads"])
	_road_dashes = RoadLayout.lay_out(mission_map, flat_rects, map_node_positions, road_seed)
	var flat_road_dashes := _sort_road_dashes_into_flats(flat_rects)
	var show_column_on_flat := func(flat: Flat) -> void:
		var index := _flats.find(flat)
		if index < column_count:
			flat.show_column(mission_map.get_column(index))
		else:
			flat.clear()
		for road_dash: Flat.RoadDash in flat_road_dashes[flat]:
			flat.add_road_dash(road_dash)

	if _view == View.FIGHT:
		await _play_transition_to_mission(show_column_on_flat)
		return
	_coach.position.x = _coach_start_x
	for flat in _flats:
		show_column_on_flat.call(flat)
	_update_highlights()


# Plays the transition to the fight, and returns once it is done.
func show_encounter(party: Array[Character], enemies: Array[Character]) -> void:
	_view = View.TRANSITION
	await _slide_coach(OFFSTAGE_RIGHT_X)
	await _flip_flats(_show_battle_on_flat)
	var flats_rect := Rect2(_flats_container.position, _flats_container.size)
	var tween := create_tween().set_parallel().set_trans(TRAVEL_TRANSITION).set_ease(TRAVEL_EASE)
	_add_puppets(tween, party, PuppetLayout.get_stand_positions(flats_rect, party.size(), PuppetLayout.Side.LEFT), OFFSTAGE_LEFT_X)
	_add_puppets(tween, enemies, PuppetLayout.get_stand_positions(flats_rect, enemies.size(), PuppetLayout.Side.RIGHT), OFFSTAGE_RIGHT_X)
	await tween.finished
	_view = View.FIGHT


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


func _play_transition_to_mission(show_column_on_flat: Callable) -> void:
	_view = View.TRANSITION
	var tween := create_tween().set_parallel().set_trans(TRAVEL_TRANSITION).set_ease(TRAVEL_EASE)
	for puppet in _puppet_offstage_xs:
		tween.tween_property(puppet, "position:x", _puppet_offstage_xs[puppet], PUPPET_SLIDE_DURATION)
	await tween.finished
	for puppet in _puppet_offstage_xs:
		puppet.queue_free()
	_puppet_offstage_xs.clear()
	await _flip_flats(show_column_on_flat)
	_coach.position.x = OFFSTAGE_LEFT_X
	await _slide_coach(_coach_start_x)
	_view = View.MISSION_MAP
	_update_highlights()


func _slide_coach(x: float) -> void:
	_coach_tween = create_tween().set_trans(TRAVEL_TRANSITION).set_ease(TRAVEL_EASE)
	_coach_tween.tween_property(_coach, "position:x", x, COACH_SLIDE_DURATION)
	await _coach_tween.finished


# One flat after another, left to right; each swaps its content while edge-on.
func _flip_flats(swap_content: Callable) -> void:
	for flat in _flats:
		flat.pivot_offset = flat.size / 2.0
		var tween := create_tween().set_trans(TRAVEL_TRANSITION)
		tween.tween_property(flat, "scale:x", 0.0, FLAT_FLIP_DURATION / 2.0).set_ease(Tween.EASE_IN)
		tween.tween_callback(swap_content.bind(flat))
		tween.tween_property(flat, "scale:x", 1.0, FLAT_FLIP_DURATION / 2.0).set_ease(Tween.EASE_OUT)
		await tween.finished


func _show_battle_on_flat(flat: Flat) -> void:
	flat.show_battle(BATTLEGROUND, Flat.get_battle_region(_get_stage_rect(flat), BATTLEGROUND_RECT, BATTLEGROUND.get_size()))


# Each puppet starts beyond the curtains at `offstage_x` and slides to its stand position on `tween`.
func _add_puppets(tween: Tween, characters: Array[Character], stand_positions: Array[Vector2], offstage_x: float) -> void:
	for index in characters.size():
		var puppet := Puppet.new()
		puppet.texture = characters[index].data.puppet
		puppet.position = Vector2(offstage_x, stand_positions[index].y)
		_puppets.add_child(puppet)
		_puppet_offstage_xs[puppet] = offstage_x
		tween.tween_property(puppet, "position:x", stand_positions[index].x, PUPPET_SLIDE_DURATION)


func _get_stage_rect(flat: Flat) -> Rect2:
	return Rect2(_flats_container.position + flat.position, flat.size)


# Merging can move a dash, so it goes to the flat that contains it now, in flat space; one left in a gap between flats is dropped.
func _sort_road_dashes_into_flats(flat_rects: Array[Rect2]) -> Dictionary[Flat, Array]:
	var flat_road_dashes: Dictionary[Flat, Array] = {}
	for flat in _flats:
		flat_road_dashes[flat] = []
	for road_dash in _road_dashes:
		for index in flat_rects.size():
			if flat_rects[index].has_point(road_dash.position):
				road_dash.position -= flat_rects[index].position
				flat_road_dashes[_flats[index]].append(road_dash)
				break
	return flat_road_dashes


# Nothing is pickable while the coach moves, nor away from the mission map.
func _is_pickable(map_node: MapNode) -> bool:
	var is_coach_moving := _coach_tween != null and _coach_tween.is_running()
	return _view == View.MISSION_MAP and not is_coach_moving and _mission_model.get_map_node_visitation(map_node) == MissionModel.Visitation.OPEN


# Hover follows the mouse even over a node that isn't pickable, so it shows as soon as that node opens.
func _on_map_node_mouse_entered(map_node: MapNode) -> void:
	_map_node_under_mouse = map_node
	_update_highlights()


func _on_map_node_mouse_exited(map_node: MapNode) -> void:
	if map_node != _map_node_under_mouse:
		return
	_map_node_under_mouse = null
	_update_highlights()


# Away from the mission map, a flat may not show its column yet; the transition back updates once it is done.
func _update_highlights() -> void:
	if _view != View.MISSION_MAP:
		return
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
