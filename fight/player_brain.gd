class_name PlayerBrain
extends Brain
# The heroes played by the player. The fight stops for a free hero, or when the player requests it; then the brain waits for a hero, a skill and a target, or a pass.
# Given a stage, it shows its choices there and takes the player's input through its own PlayerInput, until disposed. Nothing is pickable while the fight runs.

signal _decided(action: Action)

var hero: Character
var armed_skill: SkillData
var aimed_target: Character
var hovered_skill: SkillData
var hovered_character: Character
var hovered_action: Action

var _stage: Stage
var _input: PlayerInput
var _fight_model: FightModel
var _is_waiting := false
var _is_stopped := false
# The shown skill as the preview plays it out, built afresh each time the choices show; null for none.
var _ghost_action: Action

# A requested stop lasts until a pass.
var _is_stop_requested := false

# Only a target aimed by a digit is confirmed by the same digit again.
var _digit_target: Character


func _init(stage: Stage = null) -> void:
	side = FightModel.Side.HERO
	if stage == null:
		return
	_stage = stage
	_input = PlayerInput.new(stage)
	_input.stop_pressed.connect(request_stop)
	_input.pass_pressed.connect(pass_stop)
	_input.stop_button_pressed.connect(_on_stop_button_pressed)
	_input.hero_cycled.connect(cycle_hero)
	_input.number_pressed.connect(press_number)
	_input.aim_cycled.connect(cycle_aim)
	_input.confirm_pressed.connect(confirm)
	_input.cancel_pressed.connect(disarm)
	_input.character_hovered.connect(hover_character)
	_input.action_hovered.connect(hover_action)
	_input.character_clicked.connect(pick)
	_input.skill_pressed.connect(arm_skill)
	_input.skill_hovered.connect(hover_skill)
	(Engine.get_main_loop() as SceneTree).root.add_child(_input)
	_show_choices()


# No more input, and the stage stops showing the choices.
func dispose() -> void:
	if _input != null:
		_input.queue_free()
		_input = null
	if _stage != null:
		_stage.hide_choices()
		_stage.skill_bar.clear()
		_stage = null


func is_stop_requested() -> bool:
	return _is_stop_requested


func is_waiting() -> bool:
	return _is_waiting


# Returns null at once while the fight runs on. Stopped, it selects the first free hero, else the first hero, and waits.
func get_next_action(fight_model: FightModel) -> Action:
	if fight_model != _fight_model:
		_fight_model = fight_model
		fight_model.action_resolved.connect(_on_action_removed)
		fight_model.action_cancelled.connect(_on_action_removed)
		fight_model.character_fell.connect(_on_character_fell)
		fight_model.changed.connect(_show_choices)
	var free_heroes := fight_model.get_standing(side).filter(is_hero_ready.bind(fight_model))
	if free_heroes.is_empty() and not _is_stop_requested:
		_is_stopped = false
		return null
	if not free_heroes.is_empty():
		if hero not in free_heroes:
			hero = free_heroes[0]
	elif not _is_stopped or hero.is_fallen():
		hero = fight_model.get_standing(side)[0]
	_is_stopped = true
	_is_waiting = true
	_show_choices()
	return await _decided


func is_hero_ready(character: Character, fight_model: FightModel) -> bool:
	return FightRules.is_ready(fight_model, character)


# Shows the choices even when nothing changes: the stop button toggles itself when pressed.
func request_stop() -> void:
	if not _is_waiting:
		_is_stop_requested = true
	_show_choices()


# The next action resolves; a free hero stops the fight again after it.
func pass_stop() -> void:
	if not _is_waiting:
		_show_choices()
		return
	_is_stop_requested = false
	_is_stopped = false
	_decide(null)


func select_hero(character: Character) -> void:
	if not _is_waiting or character not in _fight_model.get_standing(side) or character == hero:
		return
	hero = character
	hovered_skill = null
	_disarm()
	_show_choices()


func cycle_hero(step: int) -> void:
	if not _is_waiting:
		return
	var heroes := _fight_model.get_standing(side)
	select_hero(heroes[posmod(heroes.find(hero) + step, heroes.size())])


# Aims the first target.
func arm_skill(skill: SkillData) -> void:
	if not _is_waiting:
		return
	var usable_skills := FightRules.get_usable_skills(_fight_model, hero)
	if get_inspected_character() != hero or skill not in usable_skills:
		return
	armed_skill = skill
	var targets := get_targets()
	aimed_target = null if targets.is_empty() else targets[0]
	_digit_target = null
	_show_choices()


func disarm() -> void:
	if _is_waiting:
		_disarm()
		_show_choices()


# Unarmed, arms the skill; armed, aims the target, and confirms it if this digit aimed it already.
func press_number(index: int) -> void:
	if not _is_waiting or get_inspected_character() != hero:
		return
	if armed_skill == null:
		var skills := hero.data.skills
		if index < skills.size():
			arm_skill(skills[index])
		return
	var targets := get_targets()
	if index >= targets.size():
		return
	var target := targets[index]
	if _stage != null:
		_stage.bob_puppet(target)
	if target == _digit_target:
		confirm()
		return
	aimed_target = target
	_digit_target = target
	_show_choices()


func cycle_aim(step: int) -> void:
	if not _is_waiting or armed_skill == null:
		return
	var targets := get_targets()
	aimed_target = targets[posmod(targets.find(aimed_target) + step, targets.size())]
	_digit_target = null
	_show_choices()


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
		_show_choices()


func hover_character(character: Character) -> void:
	if character != hovered_character:
		hovered_character = character
		_show_choices()


func hover_action(action: Action) -> void:
	if action != hovered_action:
		hovered_action = action
		_show_choices()


# The armed skill's targets, left to right on stage: the enemies stand front first, the front towards the middle.
func get_targets() -> Array[Character]:
	if armed_skill == null:
		return []
	return FightRules.get_targets(_fight_model, hero, armed_skill)


func is_target(character: Character) -> bool:
	return _is_waiting and character in get_targets()


func is_pickable(character: Character) -> bool:
	return _is_waiting and (character in _fight_model.get_standing(side) or is_target(character))


func is_ready(character: Character) -> bool:
	return _is_waiting and _fight_model.get_side(character) == side and FightRules.is_ready(_fight_model, character)


# Whose skills the bar shows: a hovered medallion's actor, else a hovered character while no skill is armed, else the selected hero.
func get_inspected_character() -> Character:
	if hovered_action != null:
		return hovered_action.actor
	if hovered_character != null and armed_skill == null:
		return hovered_character
	return hero


# What the preview plays out during a stop: a hovered medallion's action, else the ghost of a usable skill; null for nothing.
func get_previewed_action() -> Action:
	if not _is_waiting:
		return null
	if hovered_action != null:
		return hovered_action
	if _ghost_action != null and _ghost_action.skill in FightRules.get_usable_skills(_fight_model, hero):
		return _ghost_action
	return null


# The hovered skill, else the armed one, as it would hang on the timeline, or null. A hovered skill of anyone but the hero hangs nothing.
# Characters share skill resources, so the hovered skill is the hero's only while the bar shows the hero's.
func _create_ghost_action() -> Action:
	if not _is_waiting or hero == null:
		return null
	var is_hero_skill_hovered := hovered_skill != null and get_inspected_character() == hero
	var shown := hovered_skill if is_hero_skill_hovered else armed_skill
	if shown == null:
		return null
	var ghost := Action.new()
	ghost.actor = hero
	ghost.skill = shown
	ghost.target = _get_ghost_target(shown)
	ghost.resolve_tick = _fight_model.tick + shown.delay
	return ghost


# Only the armed skill has a target: the hovered character if the skill reaches them, else the aimed one. A hovered character it cannot reach leaves it none.
func _get_ghost_target(shown: SkillData) -> Character:
	if shown != armed_skill:
		return null
	if hovered_character == null:
		return aimed_target
	return hovered_character if is_target(hovered_character) else null


func _on_stop_button_pressed() -> void:
	if _is_waiting:
		pass_stop()
	else:
		request_stop()


func _on_action_removed(action: Action) -> void:
	if action == hovered_action:
		hover_action(null)


func _on_character_fell(character: Character) -> void:
	if character == hovered_character:
		hover_character(null)


func _show_choices() -> void:
	if _stage == null:
		return
	_ghost_action = _create_ghost_action()
	_show_preview()
	_stage.show_choices(self)
	var skill_bar := _stage.skill_bar
	var inspected := get_inspected_character()
	var skills: Array[SkillData] = []
	if inspected != null:
		skills = inspected.data.skills
	skill_bar.show_skills(skills)
	for index in skills.size():
		skill_bar.set_cooldown(index, FightRules.get_cooldown_beats(inspected, skills[index]))
	var usable_skills: Array[SkillData] = []
	if _is_waiting and inspected == hero:
		usable_skills = FightRules.get_usable_skills(_fight_model, hero)
	skill_bar.set_usable(usable_skills)
	if hovered_action != null:
		skill_bar.set_armed_skill(hovered_action.skill)
	else:
		skill_bar.set_armed_skill(armed_skill if inspected == hero else null)
	if _is_waiting:
		skill_bar.show_pass_button()
	else:
		skill_bar.show_stop_button(_is_stop_requested)


# Only during a stop: while the fight runs, the fight controller plays the preview.
func _show_preview() -> void:
	if not _is_waiting:
		return
	var previewed := get_previewed_action()
	if previewed == null:
		_stage.preview_model.sync(_fight_model)
	else:
		Simulation.run(_stage.preview_model, _fight_model, previewed)


func _disarm() -> void:
	armed_skill = null
	aimed_target = null
	_digit_target = null


func _decide(action: Action) -> void:
	_is_waiting = false
	hovered_skill = null
	_disarm()
	if _stage != null:
		_stage.preview_model.sync(_fight_model)
	_show_choices()
	_decided.emit(action)
