extends GdUnitTestSuite


func test_a_knocked_out_side_falls_as_the_next_action_resolves() -> void:
	for side in [FightModel.Side.HERO, FightModel.Side.ENEMY]:
		var fight_controller := _create_fight_controller(RandomBrain.new(FightModel.Side.HERO, 1))
		var fight_model := fight_controller.fight_model
		var resolved: Array[Action] = []
		fight_controller.action_resolved.connect(resolved.append)
		var debug_commands: DebugCommands = auto_free(DebugCommands.new())

		debug_commands.knock_out(fight_controller, side)
		await fight_controller.play()

		assert_int(resolved.size()).is_equal(1)
		assert_bool(fight_model.get_standing(side).is_empty()).is_true()
		assert_bool(fight_model.is_won()).is_equal(side == FightModel.Side.ENEMY)
		assert_array(fight_model.timeline).is_empty()


func test_a_knocked_out_side_falls_at_once_while_the_player_chooses() -> void:
	for side in [FightModel.Side.HERO, FightModel.Side.ENEMY]:
		var player_brain := PlayerBrain.new()
		var fight_controller := _create_fight_controller(player_brain)
		var fight_model := fight_controller.fight_model
		var resolved: Array[Action] = []
		fight_controller.action_resolved.connect(resolved.append)
		var debug_commands: DebugCommands = auto_free(DebugCommands.new())
		fight_controller.play()
		assert_bool(player_brain.is_waiting()).is_true()

		await debug_commands.knock_out(fight_controller, side)

		assert_array(resolved).is_empty()
		assert_bool(fight_model.get_standing(side).is_empty()).is_true()
		assert_bool(player_brain.is_waiting()).is_false()


func test_random_heroes_take_over_a_waiting_player_brain_with_their_choice() -> void:
	var player_brain := PlayerBrain.new()
	var fight_controller := _create_fight_controller(player_brain)
	var fight_model := fight_controller.fight_model
	var debug_commands: DebugCommands = auto_free(DebugCommands.new())
	fight_controller.play()
	var actors: Array[Character] = []
	fight_model.action_added.connect(func(action: Action) -> void: actors.append(action.actor))

	await debug_commands.set_player_brain(fight_controller, null, false)

	assert_bool(fight_controller.hero_brain is RandomBrain).is_true()
	assert_bool(player_brain.is_waiting()).is_false()
	assert_object(actors[0]).is_same(player_brain.hero)


func test_heroes_no_longer_random_go_back_to_the_player() -> void:
	var fight_controller := _create_fight_controller(RandomBrain.new(FightModel.Side.HERO, 1))
	var debug_commands: DebugCommands = auto_free(DebugCommands.new())

	await debug_commands.set_player_brain(fight_controller, null, true)

	assert_bool(fight_controller.hero_brain is PlayerBrain).is_true()


func _create_fight_controller(heroes_brain: Brain) -> FightController:
	var fight_model := FightModel.new(_create_side(10, 3), _create_side(15, 2))
	return FightController.new(fight_model, RandomBrain.new(FightModel.Side.ENEMY, 2), heroes_brain)


func _create_side(health: int, count: int) -> Array[Character]:
	var characters: Array[Character] = []
	for index in count:
		var skill := SkillData.new()
		skill.delay = 4
		var damage := DamageEffect.new()
		damage.amount = 3
		skill.effects = [damage]
		var character_data := CharacterData.new()
		character_data.max_health = health
		character_data.skills = [skill]
		characters.append(Character.new(character_data))
	return characters
