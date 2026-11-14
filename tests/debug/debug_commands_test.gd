extends GdUnitTestSuite

const RUN_SCENE := "res://run/run.tscn"
const TIME_FACTOR := 10.0


var _current_scene: Node


func before_test() -> void:
	_current_scene = get_tree().current_scene


func after_test() -> void:
	get_tree().paused = false
	get_tree().current_scene = _current_scene


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


func test_levelup_pauses_the_game_opens_the_next_level_up_and_resumes_the_same_fight() -> void:
	var runner := scene_runner(RUN_SCENE)
	var run_controller := await _start_run_at_first_skill_draft(runner)
	var fight_controller := run_controller.fight_controller
	var fight_model := fight_controller.fight_model
	var hero := fight_model.heroes[0]
	var debug_commands: DebugCommands = auto_free(DebugCommands.new())
	await debug_commands.set_player_brain(fight_controller, null, false)
	var opened: Array[LevelUp] = []
	run_controller.level_up_started.connect(opened.append)

	Debug.level_up()
	Debug.level_up()

	assert_int(opened.size()).is_equal(1)
	assert_int(opened[0].number).is_equal(3)
	assert_bool(get_tree().paused).is_true()
	var tick := fight_model.tick
	var timeline := fight_model.timeline.duplicate()
	var health := hero.health
	await runner.simulate_frames(10)
	assert_int(fight_model.tick).is_equal(tick)
	assert_array(fight_model.timeline).is_equal(timeline)
	assert_int(hero.health).is_equal(health)
	_select_first_offers(opened[0])
	_press_continue(run_controller)
	await runner.simulate_frames(2)
	assert_bool(get_tree().paused).is_false()
	assert_object(run_controller.fight_controller).is_same(fight_controller)
	assert_object(hero.skills.back().data).is_same(opened[0].get_offers(hero)[0].skill_data)
	assert_int(run_controller.run_model.level_up_count).is_equal(3)


func test_levelup_after_the_last_level_up_changes_nothing() -> void:
	var runner := scene_runner(RUN_SCENE)
	var run_controller := await _start_run_at_first_skill_draft(runner)
	var run_model := run_controller.run_model
	while run_model.has_level_up_left():
		var level_up := run_model.create_level_up()
		_select_first_offers(level_up)
		run_model.confirm_level_up(level_up)
	var opened: Array[LevelUp] = []
	run_controller.level_up_started.connect(opened.append)

	Debug.level_up()

	assert_array(opened).is_empty()
	assert_bool(get_tree().paused).is_false()


func _start_run_at_first_skill_draft(runner: GdUnitSceneRunner) -> RunController:
	var run_controller := runner.scene() as RunController
	runner.set_time_factor(TIME_FACTOR)
	get_tree().current_scene = run_controller
	var fight_controller: FightController = await run_controller.fight_started
	await runner.await_func_on(fight_controller.hero_brain, "is_waiting").is_true()
	for index in 2:
		run_controller.run_model.confirm_level_up(run_controller.run_model.create_level_up())
	return run_controller


func _select_first_offers(level_up: LevelUp) -> void:
	for hero in level_up.heroes:
		if not level_up.is_skipped(hero):
			var offer := level_up.get_offers(hero)[0]
			level_up.select_offer(hero, offer, offer.get_perks()[0] if offer.is_upgrade() else null)


func _press_continue(run_controller: RunController) -> void:
	(run_controller.get_node("LevelUpView/ContinueButton") as TextureButton).pressed.emit()
