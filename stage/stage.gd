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

# A blow: the actor's puppet lunges to this short of its target, then goes home; a pause before the next one. In design units and seconds.
const LUNGE_GAP := 220.0
const LUNGE_DURATION := 0.25
const RETURN_DURATION := 0.35
const BLOW_PAUSE := 0.25

# A damage number floats this far up off its target's head as it fades, in design units and seconds.
const DAMAGE_RISE := 140.0
const DAMAGE_DURATION := 0.9
const DAMAGE_FONT_SIZE := 96
const DAMAGE_COLOR := Color("c0392b")

# Every health bar's top and size, in stage space.
const HEALTH_BAR_Y := 1460.0
const HEALTH_BAR_SIZE := Vector2(220.0, 64.0)

# Beyond the curtains, in design units, in stage space.
const OFFSTAGE_LEFT_X := -400.0
const OFFSTAGE_RIGHT_X := 4240.0

const PUPPET_SCENE := preload("res://stage/puppet/puppet.tscn")

var _coach_tween: Tween
var _view := View.MISSION_MAP
var _fight_puppets: Dictionary[Character, Puppet] = {}
var _health_bars: Dictionary[Character, HealthBar] = {}

@onready var _scenery: Scenery = $Scenery
# Every puppet stands in this area, feet on its bottom edge; puppet positions are local to it.
@onready var _puppets: Control = $Puppets
@onready var _coach: Puppet = $Puppets/Coach
@onready var _offer_presenter: OfferPresenter = $OfferPresenter
@onready var _timeline_rope: TimelineRope = $TimelineRope
@onready var _health_bar_area: Control = $HealthBars
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


# Plays the transition to the fight, and returns once it is done. From then on the stage follows the fight model: the rope, the health bars, the falls.
func show_encounter(fight_model: FightModel) -> void:
	_view = View.TRANSITION
	_scenery.set_input_enabled(false)
	await _slide_coach(_get_puppet_x(OFFSTAGE_RIGHT_X))
	await _scenery.flip_to_battle()
	var area := Rect2(Vector2.ZERO, _puppets.size)
	var tween := create_tween().set_parallel().set_trans(TRAVEL_TRANSITION).set_ease(TRAVEL_EASE)
	_add_puppets(tween, fight_model.heroes, PuppetLayout.get_stand_positions(area, fight_model.heroes.size(), PuppetLayout.Side.LEFT), _get_puppet_x(OFFSTAGE_LEFT_X))
	_add_puppets(tween, fight_model.enemies, PuppetLayout.get_stand_positions(area, fight_model.enemies.size(), PuppetLayout.Side.RIGHT), _get_puppet_x(OFFSTAGE_RIGHT_X))
	fight_model.health_changed.connect(_on_health_changed)
	fight_model.character_fell.connect(_on_character_fell)
	_timeline_rope.show_fight(fight_model)
	await tween.finished
	_view = View.FIGHT


# The actor's puppet lunges at its target's and calls `on_impact` as the blow lands; returns once it is home and the stage has paused.
func show_action(action: Action, on_impact: Callable) -> void:
	var actor_puppet := _fight_puppets[action.actor]
	var target_puppet := _fight_puppets[action.target]
	var home_x := actor_puppet.position.x
	actor_puppet.z_index = 1
	var lunge_x := target_puppet.position.x - signf(target_puppet.position.x - home_x) * LUNGE_GAP
	var lunge := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	lunge.tween_property(actor_puppet, "position:x", lunge_x, LUNGE_DURATION)
	await lunge.finished
	on_impact.call()
	var back := create_tween().set_trans(TRAVEL_TRANSITION).set_ease(TRAVEL_EASE)
	back.tween_property(actor_puppet, "position:x", home_x, RETURN_DURATION)
	await back.finished
	actor_puppet.z_index = 0
	await get_tree().create_timer(BLOW_PAUSE).timeout


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
	# The side still standing marches on in its line, off to the right, until the hindmost is beyond the curtain.
	var march := 0.0
	for puppet in _fight_puppets.values():
		march = maxf(march, _get_puppet_x(OFFSTAGE_RIGHT_X) - puppet.position.x)
	for character in _fight_puppets:
		var puppet := _fight_puppets[character]
		tween.tween_property(puppet, "position:x", puppet.position.x + march, PUPPET_SLIDE_DURATION)
		tween.tween_property(_health_bars[character], "position:x", _get_health_bar_x(puppet.position.x + march), PUPPET_SLIDE_DURATION)
	await tween.finished
	for puppet in _fight_puppets.values():
		puppet.queue_free()
	for health_bar in _health_bars.values():
		health_bar.queue_free()
	_health_bars.clear()
	_fight_puppets.clear()
	_timeline_rope.clear()
	await _scenery.flip_to_mission_map(mission_model, map_seed)
	_coach.position.x = _get_puppet_x(OFFSTAGE_LEFT_X)
	await _slide_coach(_coach_start_x)
	_view = View.MISSION_MAP
	_scenery.set_input_enabled(true)


func _slide_coach(x: float) -> void:
	_coach_tween = create_tween().set_trans(TRAVEL_TRANSITION).set_ease(TRAVEL_EASE)
	_coach_tween.tween_property(_coach, "position:x", x, COACH_SLIDE_DURATION)
	await _coach_tween.finished


# Each puppet starts beyond the curtains at `offstage_x` and slides to its stand position on `tween`, its health bar with it.
func _add_puppets(tween: Tween, characters: Array[Character], stand_positions: Array[Vector2], offstage_x: float) -> void:
	for index in characters.size():
		var puppet: Puppet = PUPPET_SCENE.instantiate()
		puppet.texture = characters[index].data.puppet
		puppet.position = Vector2(offstage_x, stand_positions[index].y)
		_puppets.add_child(puppet)
		_fight_puppets[characters[index]] = puppet
		tween.tween_property(puppet, "position:x", stand_positions[index].x, PUPPET_SLIDE_DURATION)
		var health_bar := _add_health_bar(characters[index], offstage_x)
		tween.tween_property(health_bar, "position:x", _get_health_bar_x(stand_positions[index].x), PUPPET_SLIDE_DURATION)


func _add_health_bar(character: Character, puppet_x: float) -> HealthBar:
	var health_bar := HealthBar.new(character)
	health_bar.size = HEALTH_BAR_SIZE
	health_bar.position = Vector2(_get_health_bar_x(puppet_x), HEALTH_BAR_Y)
	_health_bar_area.add_child(health_bar)
	_health_bars[character] = health_bar
	return health_bar


func _get_health_bar_x(puppet_x: float) -> float:
	return puppet_x + _puppets.position.x - HEALTH_BAR_SIZE.x / 2.0


func _add_damage_number(puppet: Puppet, damage: int) -> void:
	var label := Label.new()
	label.text = str(damage)
	label.add_theme_font_size_override("font_size", DAMAGE_FONT_SIZE)
	label.add_theme_color_override("font_color", DAMAGE_COLOR)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_puppets.add_child(label)
	label.reset_size()
	label.position = puppet.position - Vector2(label.size.x / 2.0, puppet.get_height() + label.size.y)
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "position:y", label.position.y - DAMAGE_RISE, DAMAGE_DURATION)
	tween.tween_property(label, "modulate:a", 0.0, DAMAGE_DURATION).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(label.queue_free)


func _on_health_changed(character: Character, amount: int) -> void:
	_health_bars[character].show_health()
	if amount < 0:
		var puppet := _fight_puppets[character]
		puppet.shake()
		_add_damage_number(puppet, -amount)


func _on_character_fell(character: Character) -> void:
	var puppet := _fight_puppets[character]
	var health_bar := _health_bars[character]
	_fight_puppets.erase(character)
	_health_bars.erase(character)
	health_bar.fade_out()
	await puppet.sink()
	puppet.queue_free()
	health_bar.queue_free()


func _get_puppet_x(stage_x: float) -> float:
	return stage_x - _puppets.position.x
