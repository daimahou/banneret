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
		var fight_controller := FightController.new(heroes, _create_enemies(), fight_seed, _create_random_heroes(fight_seed))
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
	var fight_controller := FightController.new(_create_heroes(), _create_enemies(), 1, hero_brain)

	await fight_controller.play()

	assert_bool(hero_brain.is_asked_with_action_due).is_true()


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
	return FightController.new(_create_heroes(), _create_enemies(), fight_seed, _create_random_heroes(fight_seed))


func _create_random_heroes(fight_seed: int) -> RandomBrain:
	return RandomBrain.new(FightModel.Side.HERO, fight_seed)


func _create_heroes() -> Array[Character]:
	return [_create_character(10), _create_character(10), _create_character(10)]


func _create_enemies() -> Array[Character]:
	return [_create_character(15), _create_character(15)]


func _create_character(health: int) -> Character:
	var skill := SkillData.new()
	skill.delay = 4
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
