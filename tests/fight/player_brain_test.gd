extends GdUnitTestSuite


func test_a_digit_arms_nothing_while_an_enemy_medallion_is_hovered() -> void:
	var player_brain := PlayerBrain.new()
	var fight_controller := _create_fight_controller(player_brain)
	fight_controller.play()

	player_brain.hover_action(fight_controller.fight_model.timeline[0])
	player_brain.press_number(0)

	assert_object(player_brain.armed_skill).is_null()


func test_a_digit_aims_nothing_while_an_enemy_medallion_is_hovered() -> void:
	var player_brain := PlayerBrain.new()
	var fight_controller := _create_fight_controller(player_brain)
	fight_controller.play()
	player_brain.press_number(0)
	var aimed_target := player_brain.aimed_target

	player_brain.hover_action(fight_controller.fight_model.timeline[0])
	player_brain.press_number(1)

	assert_object(player_brain.aimed_target).is_same(aimed_target)


func test_a_skill_click_arms_nothing_while_an_enemy_is_hovered() -> void:
	var player_brain := PlayerBrain.new()
	var fight_controller := _create_fight_controller(player_brain)
	fight_controller.play()

	player_brain.hover_character(fight_controller.fight_model.enemies[0])
	player_brain.arm_skill(player_brain.hero.data.skills[0])

	assert_object(player_brain.armed_skill).is_null()


func test_a_skill_click_arms_once_the_hover_ends() -> void:
	var player_brain := PlayerBrain.new()
	var fight_controller := _create_fight_controller(player_brain)
	fight_controller.play()
	player_brain.hover_character(fight_controller.fight_model.enemies[0])

	player_brain.hover_character(null)
	player_brain.arm_skill(player_brain.hero.data.skills[0])

	assert_object(player_brain.armed_skill).is_same(player_brain.hero.data.skills[0])


func test_the_hero_stays_selected_while_holding_ap() -> void:
	var player_brain := PlayerBrain.new()
	var fight_controller := _create_fight_controller(player_brain, 2)
	fight_controller.play()
	var hero := player_brain.hero

	_choose_first_skill(player_brain)

	assert_object(player_brain.hero).is_same(hero)


func test_spending_the_last_ap_selects_the_next_hero_holding_some() -> void:
	var player_brain := PlayerBrain.new()
	var fight_controller := _create_fight_controller(player_brain)
	fight_controller.play()

	_choose_first_skill(player_brain)

	assert_object(player_brain.hero).is_same(fight_controller.fight_model.heroes[1])


func test_a_hero_with_an_action_pending_and_ap_left_stops_the_fight() -> void:
	var player_brain := PlayerBrain.new()
	var fight_controller := _create_fight_controller(player_brain, 2, 1)
	fight_controller.play()

	_choose_first_skill(player_brain)

	assert_bool(player_brain.is_waiting()).is_true()
	assert_int(fight_controller.fight_model.tick).is_equal(0)


func _create_fight_controller(heroes_brain: Brain, heroes_max_ap := 1, hero_count := 2) -> FightController:
	var fight_model := FightModel.new(_create_side(hero_count, heroes_max_ap), _create_side(2))
	return FightController.new(fight_model, RandomBrain.new(FightModel.Side.ENEMY, 1), heroes_brain)


func _choose_first_skill(player_brain: PlayerBrain) -> void:
	player_brain.arm_skill(player_brain.hero.data.skills[0])
	player_brain.confirm()


func _create_side(count: int, max_ap := 1) -> Array[Character]:
	var characters: Array[Character] = []
	for index in count:
		var skill := SkillData.new()
		skill.delay = 4
		var damage := DamageEffect.new()
		damage.amount = 3
		skill.effects = [damage]
		var character_data := CharacterData.new()
		character_data.max_health = 10
		character_data.max_ap = max_ap
		character_data.skills = [skill]
		characters.append(Character.new(character_data))
	return characters
