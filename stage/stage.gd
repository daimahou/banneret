class_name Stage
extends Control

signal laid_out
signal map_node_pressed(map_node: MapNode)
signal offer_pressed(offer: Offer)

enum View { MISSION_MAP, TRANSITION, FIGHT }

const TRAVEL_DURATION := 0.6
const TRAVEL_TRANSITION := Tween.TRANS_SINE
const TRAVEL_EASE := Tween.EASE_IN_OUT

# A transition's slides, in seconds; they ease like travel.
const COACH_SLIDE_DURATION := 0.8
const PUPPET_SLIDE_DURATION := 0.8

# Beyond the curtains, in design units, in stage space.
const OFFSTAGE_LEFT_X := -400.0
const OFFSTAGE_RIGHT_X := 4240.0

const PUPPET_SCENE := preload("res://stage/puppet.tscn")

var _coach_tween: Tween
var _view := View.MISSION_MAP
# Each fight puppet slides out to where it came in from.
var _puppet_offstage_xs: Dictionary[Puppet, float] = {}

@onready var _scenery: Scenery = $Scenery
# Every puppet stands in this area, feet on its bottom edge; puppet positions are local to it.
@onready var _puppets: Control = $Puppets
@onready var _coach: Puppet = $Puppets/Coach
@onready var _offer_presenter: OfferPresenter = $OfferPresenter
@onready var _coach_start_x := _coach.position.x


func _ready() -> void:
	_coach.position.y = _puppets.size.y
	_scenery.map_node_pressed.connect(map_node_pressed.emit)
	_offer_presenter.offer_pressed.connect(offer_pressed.emit)
	# The scenery sizes the flats on its first sort, which is still pending here.
	await _scenery.sort_children
	laid_out.emit()


func is_in_transition() -> bool:
	return _view == View.TRANSITION


# Over the fight, plays the transition back and returns once it is done.
func show_mission(mission_model: MissionModel, map_seed: int) -> void:
	if _coach_tween != null:
		_coach_tween.kill()
	_offer_presenter.clear()
	if _view == View.FIGHT:
		await _play_transition_to_mission(mission_model, map_seed)
		return
	_coach.position.x = _coach_start_x
	# A travel cut short by the new mission left input disabled.
	_scenery.set_input_enabled(true)
	_scenery.show_mission_map(mission_model, map_seed)


# Plays the transition to the fight, and returns once it is done.
func show_encounter(party: Array[Character], enemies: Array[Character]) -> void:
	_view = View.TRANSITION
	_scenery.set_input_enabled(false)
	await _slide_coach(_get_puppet_x(OFFSTAGE_RIGHT_X))
	await _scenery.flip_to_battle()
	var area := Rect2(Vector2.ZERO, _puppets.size)
	var tween := create_tween().set_parallel().set_trans(TRAVEL_TRANSITION).set_ease(TRAVEL_EASE)
	_add_puppets(tween, party, PuppetLayout.get_stand_positions(area, party.size(), PuppetLayout.Side.LEFT), _get_puppet_x(OFFSTAGE_LEFT_X))
	_add_puppets(tween, enemies, PuppetLayout.get_stand_positions(area, enemies.size(), PuppetLayout.Side.RIGHT), _get_puppet_x(OFFSTAGE_RIGHT_X))
	await tween.finished
	_view = View.FIGHT


# Shows the model after the coach travelled to `map_node`, and returns once the coach is there.
# Nothing is pickable while the coach moves.
func show_travel(map_node: MapNode) -> void:
	_scenery.set_input_enabled(false)
	_coach_tween = create_tween().set_trans(TRAVEL_TRANSITION).set_ease(TRAVEL_EASE)
	_coach_tween.tween_property(_coach, "position:x", _get_puppet_x(_scenery.get_column_center_x(map_node.column)), TRAVEL_DURATION)
	await _coach_tween.finished
	_scenery.set_input_enabled(true)


# Returns once the offers hang still.
func show_offers(offers: Array[Offer]) -> void:
	await _offer_presenter.show_offers(offers)


# Shows the model after the pick, and returns once the offers are gone.
func hide_offers() -> void:
	_scenery.update_highlights()
	await _offer_presenter.hide_offers()


func _play_transition_to_mission(mission_model: MissionModel, map_seed: int) -> void:
	_view = View.TRANSITION
	var tween := create_tween().set_parallel().set_trans(TRAVEL_TRANSITION).set_ease(TRAVEL_EASE)
	for puppet in _puppet_offstage_xs:
		tween.tween_property(puppet, "position:x", _puppet_offstage_xs[puppet], PUPPET_SLIDE_DURATION)
	await tween.finished
	for puppet in _puppet_offstage_xs:
		puppet.queue_free()
	_puppet_offstage_xs.clear()
	await _scenery.flip_to_mission_map(mission_model, map_seed)
	_coach.position.x = _get_puppet_x(OFFSTAGE_LEFT_X)
	await _slide_coach(_coach_start_x)
	_view = View.MISSION_MAP
	_scenery.set_input_enabled(true)


func _slide_coach(x: float) -> void:
	_coach_tween = create_tween().set_trans(TRAVEL_TRANSITION).set_ease(TRAVEL_EASE)
	_coach_tween.tween_property(_coach, "position:x", x, COACH_SLIDE_DURATION)
	await _coach_tween.finished


# Each puppet starts beyond the curtains at `offstage_x` and slides to its stand position on `tween`.
func _add_puppets(tween: Tween, characters: Array[Character], stand_positions: Array[Vector2], offstage_x: float) -> void:
	for index in characters.size():
		var puppet: Puppet = PUPPET_SCENE.instantiate()
		puppet.texture = characters[index].data.puppet
		puppet.position = Vector2(offstage_x, stand_positions[index].y)
		_puppets.add_child(puppet)
		_puppet_offstage_xs[puppet] = offstage_x
		tween.tween_property(puppet, "position:x", stand_positions[index].x, PUPPET_SLIDE_DURATION)


func _get_puppet_x(stage_x: float) -> float:
	return stage_x - _puppets.position.x
