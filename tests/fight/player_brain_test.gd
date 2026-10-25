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


func _create_fight_controller(heroes_brain: Brain) -> FightController:
	var fight_model := FightModel.new(_create_side(2), _create_side(2))
	return FightController.new(fight_model, RandomBrain.new(FightModel.Side.ENEMY, 1), heroes_brain)


func _create_side(count: int) -> Array[Character]:
	var characters: Array[Character] = []
	for index in count:
		var skill := SkillData.new()
		skill.delay = 4
		var damage := DamageEffect.new()
		damage.amount = 3
		skill.effects = [damage]
		var character_data := CharacterData.new()
		character_data.max_health = 10
		character_data.skills = [skill]
		characters.append(Character.new(character_data))
	return characters
