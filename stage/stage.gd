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
# Each marcher sets off up to this late, at random; too late and the one behind would catch up.
const MARCH_STAGGER := 0.05

# A blow: the actor's puppet lunges to this short of its target, then goes home; a pause before the next one. In design units and seconds.
const LUNGE_GAP := 220.0
const LUNGE_DURATION := 0.25
const RETURN_DURATION := 0.35
const BLOW_PAUSE := 0.25

# The fight holds on each beat this long, in seconds, so what the beat changed shows.
const BEAT_HOLD_DURATION := 0.4

# A damage number floats this far up off its target's head as it fades, in design units and seconds.
const DAMAGE_RISE := 140.0
const DAMAGE_DURATION := 0.9
const DAMAGE_FONT_SIZE := 96
const DAMAGE_COLOR := Color("c0392b")

const TARGET_INK_COLOR := Color("7a2a20")
const AIMED_INK_COLOR := Color("d8402c")

# Beyond the curtains, in design units, in stage space.
const OFFSTAGE_LEFT_X := -400.0
const OFFSTAGE_RIGHT_X := 4240.0

const PUPPET_SCENE := preload("res://stage/puppet/puppet.tscn")

var _coach_tween: Tween
var _view := View.MISSION_MAP
var _fight_puppets: Dictionary[Character, Puppet] = {}
# Left to right, each side's filled from its own edge so that its front stands nearest the middle.
var _hero_nameplates: Array[Nameplate] = []
var _enemy_nameplates: Array[Nameplate] = []
var _hover_ink := Ink.create_material(Ink.Highlight.HOVERED)
var _target_ink := Ink.create_color_material(TARGET_INK_COLOR)
var _aimed_ink := Ink.create_color_material(AIMED_INK_COLOR)

# Null before the first encounter.
var preview_model: FightModel
var _fight_model: FightModel
# Null outside a fight.
var _preview_presenter: PreviewPresenter

@onready var _scenery: Scenery = $Scenery
# Every puppet stands in this area, feet on its bottom edge; puppet positions are local to it.
@onready var _puppets: Control = $Puppets
@onready var _coach: Puppet = $Puppets/Coach
@onready var _offer_presenter: OfferPresenter = $OfferPresenter
@onready var _timeline_rope: TimelineRope = $TimelineRope
@onready var skill_bar: SkillBar = $SkillBar
@onready var _coach_start_x := _coach.position.x


func _ready() -> void:
	_hero_nameplates.assign($Nameplates/Heroes.get_children())
	_enemy_nameplates.assign($Nameplates/Enemies.get_children())
	_coach.position.y = _puppets.size.y
	_scenery.map_node_pressed.connect(map_node_pressed.emit)
	_offer_presenter.offer_pressed.connect(offer_pressed.emit)
	# The scenery sizes the flats on its first sort, which is still pending here.
	await _scenery.sort_children
	laid_out.emit()


func is_in_transition() -> bool:
	return _view == View.TRANSITION


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


func show_party(party: Array[Character]) -> void:
	_show_nameplates(_hero_nameplates, party, PuppetLayout.Side.LEFT)


func show_encounter(fight_model: FightModel) -> void:
	_view = View.TRANSITION
	_scenery.set_input_enabled(false)
	await _slide_coach(_get_puppet_x(OFFSTAGE_RIGHT_X))
	await _scenery.flip_to_battle()
	var area := Rect2(Vector2.ZERO, _puppets.size)
	var tween := create_tween().set_parallel().set_trans(TRAVEL_TRANSITION).set_ease(TRAVEL_EASE)
	_add_puppets(tween, fight_model.heroes, area, PuppetLayout.Side.LEFT, _get_puppet_x(OFFSTAGE_LEFT_X))
	_add_puppets(tween, fight_model.enemies, area, PuppetLayout.Side.RIGHT, _get_puppet_x(OFFSTAGE_RIGHT_X))
	_show_nameplates(_hero_nameplates, fight_model.heroes, PuppetLayout.Side.LEFT)
	_show_nameplates(_enemy_nameplates, fight_model.enemies, PuppetLayout.Side.RIGHT)
	fight_model.health_changed.connect(_on_health_changed)
	fight_model.character_fell.connect(_on_character_fell)
	_fight_model = fight_model
	preview_model = FightModel.new([], [])
	preview_model.sync(fight_model)
	# Connected before any brain sees the fight, so the preview is level by the time they read it.
	fight_model.changed.connect(_on_fight_changed)
	var nameplates: Array[Nameplate] = []
	nameplates.assign(_hero_nameplates + _enemy_nameplates)
	_preview_presenter = PreviewPresenter.new(fight_model, preview_model, nameplates, skill_bar, _timeline_rope)
	_show_fight()
	await tween.finished
	_view = View.FIGHT


func show_choices(brain: PlayerBrain) -> void:
	var is_waiting := brain.is_waiting()
	for character in _fight_puppets:
		var puppet := _fight_puppets[character]
		var stance := Puppet.Stance.SWAY
		if is_waiting and character == brain.hero:
			stance = Puppet.Stance.RAISED
		elif is_waiting and brain.is_ready(character):
			stance = Puppet.Stance.HOP
		puppet.set_stance(stance)
		puppet.set_sprite_material(_get_ink(brain, character))
		puppet.set_pressed(_is_hovered(brain, character) and brain.is_target(character))
	var highlighted: Array[Character] = []
	if is_waiting:
		highlighted.append(brain.hero)
	if brain.hovered_character != null:
		highlighted.append(brain.hovered_character)
	if _preview_presenter != null:
		_preview_presenter.show_choice(brain.get_inspected_character(), brain.get_previewed_action())
	_timeline_rope.highlight_actors(highlighted)


func hide_choices() -> void:
	for puppet: Puppet in _fight_puppets.values():
		puppet.set_stance(Puppet.Stance.SWAY)
		puppet.set_sprite_material(null)
		puppet.set_pressed(false)
	if _preview_presenter != null:
		_preview_presenter.show_choice(null, null)
	_timeline_rope.clear_highlights()


func bob_puppet(character: Character) -> void:
	_fight_puppets[character].bob()


func get_character_at(global_point: Vector2) -> Character:
	for character in _fight_puppets:
		if _fight_puppets[character].has_point(global_point):
			return character
	return null


func get_action_at(global_point: Vector2) -> Action:
	return _timeline_rope.get_action_at(global_point)


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


func show_beat() -> void:
	await get_tree().create_timer(BEAT_HOLD_DURATION).timeout


# The model has travelled already: this only shows it.
func show_travel(map_node: MapNode) -> void:
	_scenery.set_input_enabled(false)
	_coach_tween = create_tween().set_trans(TRAVEL_TRANSITION).set_ease(TRAVEL_EASE)
	_coach_tween.tween_property(_coach, "position:x", _get_puppet_x(_scenery.get_column_center_x(map_node.column)), TRAVEL_DURATION)
	await _coach_tween.finished
	_scenery.set_input_enabled(true)


func show_offers(offers: Array[Offer]) -> void:
	await _offer_presenter.show_offers(offers)


# The model has picked already: this only shows it.
func hide_offers() -> void:
	_scenery.update_highlights()
	await _offer_presenter.hide_offers()


# A target keeps its red when hovered: it is pressed down instead.
func _get_ink(brain: PlayerBrain, character: Character) -> ShaderMaterial:
	if brain.is_target(character):
		return _aimed_ink if character == brain.aimed_target else _target_ink
	if _is_hovered(brain, character):
		return _hover_ink
	return null


func _is_hovered(brain: PlayerBrain, character: Character) -> bool:
	var hovered_action := brain.hovered_action
	if hovered_action != null and character == hovered_action.actor:
		return true
	return character == brain.hovered_character and brain.is_pickable(character)


func _play_transition_to_mission(mission_model: MissionModel, map_seed: int) -> void:
	_view = View.TRANSITION
	hide_choices()
	var tween := create_tween().set_parallel().set_trans(TRAVEL_TRANSITION).set_ease(TRAVEL_EASE)
	# The side still standing marches on in its line, off to the right, until the hindmost is beyond the curtain.
	var march := 0.0
	for puppet in _fight_puppets.values():
		march = maxf(march, _get_puppet_x(OFFSTAGE_RIGHT_X) - puppet.position.x)
	for character in _fight_puppets:
		var puppet := _fight_puppets[character]
		var delay := randf() * MARCH_STAGGER
		tween.tween_property(puppet, "position:x", puppet.position.x + march, PUPPET_SLIDE_DURATION).set_delay(delay)
	_hide_nameplates(_enemy_nameplates)
	await tween.finished
	for puppet in _fight_puppets.values():
		puppet.queue_free()
	_fight_puppets.clear()
	_preview_presenter.dispose()
	_preview_presenter = null
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


func _add_puppets(tween: Tween, characters: Array[Character], area: Rect2, side: PuppetLayout.Side, offstage_x: float) -> void:
	var stand_positions := PuppetLayout.get_stand_positions(area, characters.size(), side)
	for index in characters.size():
		var puppet: Puppet = PUPPET_SCENE.instantiate()
		puppet.texture = characters[index].data.puppet
		puppet.position = Vector2(offstage_x, stand_positions[index].y)
		_puppets.add_child(puppet)
		_fight_puppets[characters[index]] = puppet
		tween.tween_property(puppet, "position:x", stand_positions[index].x, PUPPET_SLIDE_DURATION)


# A side with more characters than nameplates leaves the hindmost out.
func _show_nameplates(nameplates: Array[Nameplate], characters: Array[Character], side: PuppetLayout.Side) -> void:
	var count := mini(characters.size(), nameplates.size())
	var flip_delay := 0.0
	for index in nameplates.size():
		var line_index := count - 1 - index if side == PuppetLayout.Side.LEFT else index - (nameplates.size() - count)
		var character := characters[line_index] if line_index >= 0 and line_index < count else null
		if nameplates[index].show_character(character, flip_delay):
			flip_delay += Scenery.FLIP_STAGGER
	_update_nameplates()


func _hide_nameplates(nameplates: Array[Nameplate]) -> void:
	var flip_delay := 0.0
	for nameplate in nameplates:
		if nameplate.clear(flip_delay):
			flip_delay += Scenery.FLIP_STAGGER


func _get_nameplate(character: Character) -> Nameplate:
	for nameplate in _hero_nameplates + _enemy_nameplates:
		if nameplate.character == character:
			return nameplate
	return null


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
	if amount < 0:
		var puppet := _fight_puppets[character]
		puppet.shake()
		_add_damage_number(puppet, -amount)


func _on_fight_changed() -> void:
	preview_model.sync(_fight_model)
	_show_fight()


func _show_fight() -> void:
	_update_nameplates()
	var medallions := TimelineEntry.create_medallions(_fight_model.timeline)
	_timeline_rope.show_entries(TimelineEntry.create_entries(_fight_model.tick, medallions))


func _update_nameplates() -> void:
	for nameplate in _hero_nameplates + _enemy_nameplates:
		var character := nameplate.character
		if character == null:
			continue
		nameplate.show_health(character.health, character.data.max_health)
		var pips: Array[Nameplate.Pip] = []
		for index in character.data.max_ap:
			pips.append(Nameplate.Pip.HELD if index < character.ap else Nameplate.Pip.EMPTY)
		nameplate.show_pips(pips)


func _on_character_fell(character: Character) -> void:
	var puppet := _fight_puppets[character]
	_fight_puppets.erase(character)
	var nameplate := _get_nameplate(character)
	if nameplate != null:
		nameplate.clear(0.0)
	await puppet.sink()
	puppet.queue_free()


func _get_puppet_x(stage_x: float) -> float:
	return stage_x - _puppets.position.x
