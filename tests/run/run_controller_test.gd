extends GdUnitTestSuite

const RUN_SCENE := "res://run/run.tscn"
const TIME_FACTOR := 10.0


func test_a_new_run_holds_the_party_at_full_health() -> void:
	var run_controller := scene_runner(RUN_SCENE).scene() as RunController
	var party := run_controller.run_model.party
	assert_int(party.size()).is_equal(RunModel.PARTY_HERO_IDS.size())
	for index in party.size():
		assert_object(party[index].data).is_same(RunModel.HERO_REGISTRY.load_entry(RunModel.PARTY_HERO_IDS[index]))
		assert_int(party[index].health).is_equal(party[index].data.max_health)


func test_the_party_carries_its_health_ap_and_cooldowns_into_the_next_fight() -> void:
	var runner := scene_runner(RUN_SCENE)
	var run_controller := runner.scene() as RunController
	runner.set_time_factor(TIME_FACTOR)
	var first_fight_controller: FightController = await run_controller.fight_started
	var hero := first_fight_controller.fight_model.heroes[0]
	await runner.await_func_on(first_fight_controller.hero_brain, "is_waiting").is_true()
	hero.health = 7
	hero.ap = 0
	hero.skill_cooldowns[hero.skills[0]] = 2

	var debug_commands: DebugCommands = auto_free(DebugCommands.new())
	await debug_commands.knock_out(first_fight_controller, FightModel.Side.ENEMY)
	await runner.await_func_on(run_controller.run_model, "has_open_draft").is_true()
	_confirm_every_pick(run_controller.run_model.draft)
	_press_continue(run_controller)
	var fight_controller: FightController = await run_controller.fight_started

	assert_array(fight_controller.fight_model.heroes).contains([hero])
	assert_int(hero.health).is_equal(7)
	assert_int(hero.ap).is_equal(0)
	assert_int(hero.skill_cooldowns[hero.skills[0]]).is_equal(2)
	assert_array(fight_controller.fight_model.timeline).is_empty()


func test_victory_opens_a_level_up_and_the_next_fight_starts_once_the_party_continues() -> void:
	var runner := scene_runner(RUN_SCENE)
	var run_controller := runner.scene() as RunController
	runner.set_time_factor(TIME_FACTOR)
	var first_fight_controller: FightController = await run_controller.fight_started
	await runner.await_func_on(first_fight_controller.hero_brain, "is_waiting").is_true()
	var started: Array[FightController] = []
	run_controller.fight_started.connect(started.append)

	var debug_commands: DebugCommands = auto_free(DebugCommands.new())
	await debug_commands.knock_out(first_fight_controller, FightModel.Side.ENEMY)
	await runner.await_func_on(run_controller.run_model, "has_open_draft").is_true()
	await runner.simulate_frames(10)
	assert_array(started).is_empty()

	_confirm_every_pick(run_controller.run_model.draft)
	_press_continue(run_controller)

	assert_int(run_controller.run_model.next_pick).is_equal(2)
	await run_controller.fight_started
	assert_int(run_controller.run_model.next_pick).is_equal(2)


func test_a_level_up_command_suspends_the_fight_and_resumes_the_same_fight_after_it() -> void:
	var runner := scene_runner(RUN_SCENE)
	var run_controller := runner.scene() as RunController
	var fight_controller: FightController = await run_controller.fight_started
	await runner.await_func_on(fight_controller.hero_brain, "is_waiting").is_true()
	var fight_model := fight_controller.fight_model
	var tick := fight_model.tick
	var timeline := fight_model.timeline.duplicate()
	var debug_commands: DebugCommands = auto_free(DebugCommands.new())

	debug_commands.level_up_in_fight(run_controller, fight_controller)
	var draft := run_controller.run_model.draft
	await debug_commands.level_up_in_fight(run_controller, fight_controller)
	assert_object(run_controller.run_model.draft).is_same(draft)
	assert_bool(fight_controller.is_suspended()).is_true()

	_confirm_every_pick(draft)
	_press_continue(run_controller)

	assert_bool(fight_controller.is_suspended()).is_false()
	assert_object(run_controller.fight_controller).is_same(fight_controller)
	assert_int(fight_model.tick).is_equal(tick)
	assert_array(fight_model.timeline).contains_exactly(timeline)
	assert_int(run_controller.run_model.next_pick).is_equal(2)


func _confirm_every_pick(draft: Draft) -> void:
	for hero_draft in draft.hero_drafts:
		if hero_draft.is_done():
			continue
		var offer := hero_draft.offers[0]
		hero_draft.select_offer(offer)
		if offer.is_upgrade():
			hero_draft.select_talent(offer.talents[0])
		hero_draft.confirm()


func _press_continue(run_controller: RunController) -> void:
	(run_controller.get_node(^"Stage/LevelUpView/Board/ContinueButton") as TextureButton).pressed.emit()
