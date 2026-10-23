extends GdUnitTestSuite


func test_a_knocked_out_side_falls_as_the_next_action_resolves() -> void:
	for side in [FightModel.Side.HERO, FightModel.Side.ENEMY]:
		var fight_controller := FightController.new(_create_side(10, 3), _create_side(15, 2), 1)
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
		var fight_controller := FightController.new(_create_side(10, 3), _create_side(15, 2), 1)
		var fight_model := fight_controller.fight_model
		var player_brain := PlayerBrain.new()
		fight_controller.hero_brain = player_brain
		var resolved: Array[Action] = []
		fight_controller.action_resolved.connect(resolved.append)
		var debug_commands: DebugCommands = auto_free(DebugCommands.new())
		fight_controller.play()
		assert_bool(player_brain.is_waiting()).is_true()

		await debug_commands.knock_out(fight_controller, side)

		assert_array(resolved).is_empty()
		assert_bool(fight_model.get_standing(side).is_empty()).is_true()
		assert_bool(player_brain.is_waiting()).is_false()


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
