extends GdUnitTestSuite

signal pause_released

const SEEDS: Array[int] = [1, 2, 3, 4, 5, 6, 7, 8]


func test_at_the_start_every_enemy_chooses_before_any_hero() -> void:
	var fight_controller := _create_fight_controller(1)
	var actors: Array[Character] = []
	fight_controller.fight_model.action_added.connect(func(action: Action) -> void: actors.append(action.actor))

	await fight_controller.play()

	var enemies := fight_controller.fight_model.enemies
	assert_array(actors.slice(0, enemies.size())).contains_exactly_in_any_order(enemies)


func test_every_fight_ends_with_one_side_fallen() -> void:
	for fight_seed in SEEDS:
		var fight_controller := _create_fight_controller(fight_seed)

		await fight_controller.play()

		assert_bool(fight_controller.fight_model.is_over()).is_true()


func test_the_same_seed_plays_the_same_fight() -> void:
	assert_array(await _record_fight(3)).is_equal(await _record_fight(3))


func test_a_win_leaves_the_heroes_health_as_the_fight_left_it() -> void:
	for fight_seed in SEEDS:
		var heroes := _create_heroes()
		var fight_controller := _create_fight_controller_for(heroes, fight_seed, _create_random_heroes(fight_seed))
		var damage_taken: Dictionary[Character, int] = {}
		fight_controller.fight_model.health_changed.connect(func(character: Character, amount: int) -> void: damage_taken[character] = damage_taken.get(character, 0) - amount)

		await fight_controller.play()

		if not fight_controller.fight_model.is_won():
			continue
		assert_array(fight_controller.fight_model.heroes).contains_exactly(heroes)
		assert_bool(heroes.any(func(hero: Character) -> bool: return damage_taken.has(hero))).is_true()
		for hero in heroes:
			assert_int(hero.health).is_equal(hero.data.max_health - damage_taken.get(hero, 0))
		return
	fail("No seed won")


func test_a_hero_brain_that_requests_a_stop_is_asked_with_an_action_due() -> void:
	var hero_brain := StoppingBrain.new()
	var fight_controller := _create_fight_controller_for(_create_heroes(), 1, hero_brain)

	await fight_controller.play()

	assert_bool(hero_brain.is_asked_with_action_due).is_true()


func test_the_fight_lands_on_every_beat_it_crosses() -> void:
	for fight_seed in SEEDS:
		var heroes: Array[Character] = [_create_character(10, 6), _create_character(10, 6)]
		var enemies: Array[Character] = [_create_character(15, 6)]
		var fight_controller := FightController.new(FightModel.new(heroes, enemies), RandomBrain.new(FightModel.Side.ENEMY, fight_seed + 1), _create_random_heroes(fight_seed))
		var ticks: Array[int] = []
		fight_controller.fight_model.tick_changed.connect(ticks.append)

		await fight_controller.play()

		for beat_tick in range(FightRules.BEAT_TICKS, fight_controller.fight_model.tick + 1, FightRules.BEAT_TICKS):
			assert_array(ticks).contains([beat_tick])


func test_a_pause_requested_mid_action_waits_for_it_to_resolve_and_holds_the_fight_still() -> void:
	var fight_controller := _create_fight_controller(1)
	var fight_model := fight_controller.fight_model
	var resolved: Array[Action] = []
	fight_controller.action_resolved.connect(resolved.append)
	var pause := FramesPause.new(fight_model)
	var request_pause := func(_action: Action) -> void: fight_controller.request_pause(pause.play)
	fight_controller.action_resolved.connect(request_pause, CONNECT_ONE_SHOT)

	await fight_controller.play()

	assert_int(pause.play_count).is_equal(1)
	assert_int(pause.resolved_count_at_start).is_equal(1)
	assert_bool(pause.is_fight_held).is_true()
	assert_bool(fight_model.is_over()).is_true()
	assert_int(resolved.size()).is_greater(1)


func test_a_pause_requested_while_the_player_chooses_starts_at_once_and_the_choice_follows_it() -> void:
	var player_brain := PlayerBrain.new()
	var fight_controller := _create_fight_controller_for(_create_heroes(), 1, player_brain)
	var hero_actions: Array[Action] = []
	fight_controller.fight_model.action_added.connect(func(action: Action) -> void:
		if action.actor in fight_controller.fight_model.heroes:
			hero_actions.append(action))
	fight_controller.play()
	assert_bool(player_brain.is_waiting()).is_true()
	var released := Signal(self, "pause_released")

	fight_controller.request_pause(func() -> void: await released)
	assert_bool(fight_controller.is_paused()).is_true()

	pause_released.emit()
	await get_tree().process_frame
	assert_bool(fight_controller.is_paused()).is_false()
	_choose_first_target(player_brain)
	assert_int(hero_actions.size()).is_equal(1)


func test_a_pause_still_requested_when_the_fight_ends_is_discarded() -> void:
	var fight_controller := _create_fight_controller(1)
	var pause := FramesPause.new(fight_controller.fight_model)
	fight_controller.action_resolved.connect(func(_action: Action) -> void:
		var delta := Delta.new()
		for enemy in fight_controller.fight_model.get_standing(FightModel.Side.ENEMY):
			FightRules.add_damage(fight_controller.fight_model, delta, enemy, enemy.health)
		fight_controller.fight_model.apply(delta)
		fight_controller.request_pause(pause.play), CONNECT_ONE_SHOT)

	await fight_controller.play()

	assert_int(pause.play_count).is_equal(0)
	assert_bool(fight_controller.is_pause_requested()).is_false()


func _choose_first_target(player_brain: PlayerBrain) -> void:
	player_brain.arm_skill(player_brain.hero.skills[0])
	player_brain.pick(player_brain.get_targets()[0])


# Each resolved action as its actor, target and tick, by index among the fight's characters.
func _record_fight(fight_seed: int) -> Array[Vector3i]:
	var fight_controller := _create_fight_controller(fight_seed)
	var fight_model := fight_controller.fight_model
	var characters := fight_model.heroes + fight_model.enemies
	var record: Array[Vector3i] = []
	fight_controller.action_resolved.connect(func(action: Action) -> void: record.append(Vector3i(characters.find(action.actor), characters.find(action.target), fight_model.tick)))
	await fight_controller.play()
	return record


func _create_fight_controller(fight_seed: int) -> FightController:
	return _create_fight_controller_for(_create_heroes(), fight_seed, _create_random_heroes(fight_seed))


func _create_fight_controller_for(heroes: Array[Character], fight_seed: int, heroes_brain: Brain) -> FightController:
	var enemies_brain := RandomBrain.new(FightModel.Side.ENEMY, fight_seed + 1)
	return FightController.new(FightModel.new(heroes, _create_enemies()), enemies_brain, heroes_brain)


func _create_random_heroes(fight_seed: int) -> RandomBrain:
	return RandomBrain.new(FightModel.Side.HERO, fight_seed)


func _create_heroes() -> Array[Character]:
	return [_create_character(10), _create_character(10), _create_character(10)]


func _create_enemies() -> Array[Character]:
	return [_create_character(15), _create_character(15)]


func _create_character(health: int, skill_delay := 4) -> Character:
	var skill := SkillData.new()
	skill.delay = skill_delay
	var damage := DamageEffect.new()
	damage.amount = 3
	skill.effects = [damage]
	var character_data := CharacterData.new()
	character_data.max_health = health
	character_data.skills = [skill]
	return Character.new(character_data)


# Always requests a stop, then passes, noting whether an action was due when it was asked.
class StoppingBrain:
	extends Brain

	var is_asked_with_action_due := false

	func is_stop_requested() -> bool:
		return true

	func get_next_action(fight_model: FightModel) -> Action:
		var next_action := fight_model.get_next_action()
		if next_action != null and next_action.resolve_tick == fight_model.tick:
			is_asked_with_action_due = true
		return await super(fight_model)


# Stands a few frames, noting whether the fight moved meanwhile.
class FramesPause:
	extends RefCounted

	const FRAMES := 5

	var play_count := 0
	var resolved_count_at_start := -1
	var is_fight_held := true
	var _fight_model: FightModel
	var _resolved_count := 0

	func _init(fight_model: FightModel) -> void:
		_fight_model = fight_model
		fight_model.action_resolved.connect(func(_action: Action) -> void: _resolved_count += 1)

	func play() -> void:
		play_count += 1
		resolved_count_at_start = _resolved_count
		var tick := _fight_model.tick
		var timeline_size := _fight_model.timeline.size()
		for frame in FRAMES:
			await (Engine.get_main_loop() as SceneTree).process_frame
		var is_timeline_held := _fight_model.timeline.size() == timeline_size and _resolved_count == resolved_count_at_start
		is_fight_held = _fight_model.tick == tick and is_timeline_held
