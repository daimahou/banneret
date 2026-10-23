class_name PlayerBrain
extends Brain
# The heroes played by the player. The fight stops for a free hero, or when the player requests it; then the brain waits for a hero, a skill and a target, or a pass.
# It takes the player's input as calls, so whatever the controls are, they only make the calls. Nothing is pickable while the fight runs.

signal choices_changed
signal target_pressed(target: Character)
signal _decided(action: Action)

var hero: Character
var armed_skill: SkillData
var aimed_target: Character
var hovered_skill: SkillData

var _fight_model: FightModel
var _is_waiting := false
# Whether the brain waited at its last turn: a new stop starts on the first hero, one going on keeps its hero.
var _is_stopped := false

# A requested stop lasts until a pass.
var _is_stop_requested := false

# Only a target aimed by a digit is confirmed by the same digit again.
var _digit_target: Character


func _init() -> void:
	side = FightModel.Side.HERO


func is_stop_requested() -> bool:
	return _is_stop_requested


func is_waiting() -> bool:
	return _is_waiting


# Returns null at once while the fight runs on. Stopped, it selects the first free hero, else the first hero, and waits.
func get_next_action(fight_model: FightModel) -> Action:
	_fight_model = fight_model
	var free_heroes := fight_model.get_standing(side).filter(_has_no_action)
	if free_heroes.is_empty() and not _is_stop_requested:
		_is_stopped = false
		return null
	if not free_heroes.is_empty():
		hero = free_heroes[0]
	elif not _is_stopped or hero.is_fallen():
		hero = fight_model.get_standing(side)[0]
	_is_stopped = true
	_is_waiting = true
	choices_changed.emit()
	return await _decided


func request_stop() -> void:
	if not _is_waiting and not _is_stop_requested:
		_is_stop_requested = true
		choices_changed.emit()


# The next action resolves; a free hero stops the fight again after it.
func pass_stop() -> void:
	if _is_waiting:
		_is_stop_requested = false
		_is_stopped = false
		_decide(null)


func select_hero(character: Character) -> void:
	if not _is_waiting or character not in _fight_model.get_standing(side) or character == hero:
		return
	hero = character
	hovered_skill = null
	_disarm()
	choices_changed.emit()


func cycle_hero(step: int) -> void:
	if not _is_waiting:
		return
	var heroes := _fight_model.get_standing(side)
	select_hero(heroes[posmod(heroes.find(hero) + step, heroes.size())])


# Aims the first target.
func arm_skill(skill: SkillData) -> void:
	if not _is_waiting or skill not in FightRules.get_usable_skills(hero):
		return
	armed_skill = skill
	var targets := get_targets()
	aimed_target = null if targets.is_empty() else targets[0]
	_digit_target = null
	choices_changed.emit()


func disarm() -> void:
	if _is_waiting:
		_disarm()
		choices_changed.emit()


# Unarmed, arms the skill; armed, aims the target, and confirms it if this digit aimed it already.
func press_number(index: int) -> void:
	if not _is_waiting:
		return
	if armed_skill == null:
		var skills := FightRules.get_usable_skills(hero)
		if index < skills.size():
			arm_skill(skills[index])
		return
	var targets := get_targets()
	if index >= targets.size():
		return
	var target := targets[index]
	target_pressed.emit(target)
	if target == _digit_target:
		confirm()
		return
	aimed_target = target
	_digit_target = target
	choices_changed.emit()


func cycle_aim(step: int) -> void:
	if not _is_waiting or armed_skill == null:
		return
	var targets := get_targets()
	aimed_target = targets[posmod(targets.find(aimed_target) + step, targets.size())]
	_digit_target = null
	choices_changed.emit()


func confirm() -> void:
	if not _is_waiting or aimed_target == null:
		return
	var action := Action.new()
	action.actor = hero
	action.skill = armed_skill
	action.target = aimed_target
	_decide(action)


# A click: a target confirmed, if the armed skill reaches it; else a hero selected.
func pick(character: Character) -> void:
	if is_target(character):
		aimed_target = character
		confirm()
	else:
		select_hero(character)


func hover_skill(skill: SkillData) -> void:
	if skill != hovered_skill:
		hovered_skill = skill
		choices_changed.emit()


# The armed skill's targets, left to right on stage: the enemies stand front first, the front towards the middle.
func get_targets() -> Array[Character]:
	if armed_skill == null:
		return []
	return FightRules.get_targets(_fight_model, hero, armed_skill)


func is_target(character: Character) -> bool:
	return _is_waiting and character in get_targets()


func is_pickable(character: Character) -> bool:
	return _is_waiting and (character in _fight_model.get_standing(side) or is_target(character))


# A hero with no pending action, while the fight waits.
func is_free(character: Character) -> bool:
	return _is_waiting and _fight_model.get_side(character) == side and _has_no_action(character)


func get_pending_action() -> Action:
	return _fight_model.get_action(hero) if _is_waiting and hero != null else null


# The pending action a confirm would drop, while a skill is armed.
func get_dropped_action() -> Action:
	return get_pending_action() if armed_skill != null else null


# The action the hovered skill, else the armed one, would hang on the timeline, or null.
func get_ghost_action() -> Action:
	if not _is_waiting or hero == null:
		return null
	var shown := hovered_skill if hovered_skill != null else armed_skill
	if shown == null:
		return null
	var ghost := Action.new()
	ghost.actor = hero
	ghost.skill = shown
	ghost.resolve_tick = _fight_model.tick + shown.delay
	return ghost


func _has_no_action(character: Character) -> bool:
	return _fight_model.get_action(character) == null


func _disarm() -> void:
	armed_skill = null
	aimed_target = null
	_digit_target = null


func _decide(action: Action) -> void:
	_is_waiting = false
	hovered_skill = null
	_disarm()
	choices_changed.emit()
	_decided.emit(action)
