extends GdUnitTestSuite

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



func test_a_fight_suspended_mid_play_holds_its_state_until_resumed_then_plays_on() -> void:
	var fight_controller := _create_fight_controller_for(_create_heroes(), 1, FrameBrain.new(FightModel.Side.HERO, 1))
	var fight_model := fight_controller.fight_model
	fight_controller.play()

	assert_bool(await fight_controller.suspend()).is_true()
	var held := _record_state(fight_model)
	for frame in 5:
		await get_tree().process_frame
	assert_array(_record_state(fight_model)).is_equal(held)

	fight_controller.resume()
	await await_signal_on(fight_model, "changed", [], 2000)
	assert_array(_record_state(fight_model)).is_not_equal(held)


func test_a_fight_suspends_at_once_while_the_player_chooses() -> void:
	var player_brain := PlayerBrain.new()
	var fight_controller := _create_fight_controller_for(_create_heroes(), 1, player_brain)
	fight_controller.play()
	assert_bool(player_brain.is_waiting()).is_true()
	var tick := fight_controller.fight_model.tick

	assert_bool(await fight_controller.suspend()).is_true()
	assert_int(fight_controller.fight_model.tick).is_equal(tick)
	player_brain.arm_skill(player_brain.hero.skills[0])
	player_brain.confirm()
	assert_bool(player_brain.is_waiting()).is_true()

	fight_controller.resume()
	player_brain.arm_skill(player_brain.hero.skills[0])
	player_brain.confirm()
	assert_bool(fight_controller.fight_model.timeline.any(func(action: Action) -> bool: return action.actor in fight_controller.fight_model.heroes)).is_true()


func test_a_second_suspend_is_refused_while_one_is_requested() -> void:
	var fight_controller := _create_fight_controller_for(_create_heroes(), 1, FrameBrain.new(FightModel.Side.HERO, 1))
	fight_controller.play()

	fight_controller.suspend()
	assert_bool(await fight_controller.suspend()).is_false()
	for frame in 5:
		await get_tree().process_frame
	assert_bool(fight_controller.is_suspended()).is_true()
	fight_controller.resume()


func test_a_suspend_requested_as_the_fight_ends_is_dropped() -> void:
	var hero_brain := EndingBrain.new()
	var fight_controller := _create_fight_controller_for(_create_heroes(), 1, hero_brain)
	fight_controller.play()

	assert_bool(await fight_controller.suspend()).is_false()
	assert_bool(fight_controller.is_suspended()).is_false()
	assert_bool(fight_controller.fight_model.is_won()).is_true()


# The tick, the timeline as action ids, and each character's health, AP and cooldowns.
func _record_state(fight_model: FightModel) -> Array:
	var state: Array = [fight_model.tick, fight_model.timeline.map(func(action: Action) -> int: return action.id)]
	for character in fight_model.heroes + fight_model.enemies:
		state.append([character.health, character.ap, character.skill_cooldowns.duplicate()])
	return state

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


# Knocks out every enemy a frame after it is asked, then passes.
class EndingBrain:
	extends Brain

	func get_next_action(fight_model: FightModel) -> Action:
		await (Engine.get_main_loop() as SceneTree).process_frame
		var delta := Delta.new()
		for enemy in fight_model.get_standing(FightModel.Side.ENEMY):
			FightRules.add_damage(fight_model, delta, enemy, enemy.health)
		fight_model.apply(delta)
		return await super(fight_model)


# Plays at random, a frame after it is asked.
class FrameBrain:
	extends RandomBrain

	func get_next_action(fight_model: FightModel) -> Action:
		await (Engine.get_main_loop() as SceneTree).process_frame
		return await super(fight_model)
