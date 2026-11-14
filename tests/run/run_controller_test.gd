extends GdUnitTestSuite

const RUN_SCENE := "res://run/run.tscn"
const TIME_FACTOR := 10.0


func test_a_new_run_holds_the_party_at_full_health() -> void:
	var run_controller := scene_runner(RUN_SCENE).scene() as RunController
	var party := run_controller.run_model.party
	assert_int(party.size()).is_equal(RunModel.PARTY_HERO_IDS.size())
	for index in party.size():
		assert_object(party[index].data).is_same(RunModel.HERO_REGISTRY.load_entry(RunModel.PARTY_HERO_IDS[index]))
		assert_int(party[index].health).is_equal(party[index].get_max_health())


func test_the_party_carries_its_health_ap_and_cooldowns_into_the_next_fight() -> void:
	var runner := scene_runner(RUN_SCENE)
	var run_controller := runner.scene() as RunController
	runner.set_time_factor(TIME_FACTOR)
	var first_fight_controller: FightController = await run_controller.fight_started
	var hero := first_fight_controller.fight_model.heroes[0]
	await runner.await_func_on(first_fight_controller.hero_brain, "is_waiting").is_true()
	hero.health = 7
	hero.ap = 0
	hero.skills[0].cooldown_beats = 2

	var debug_commands: DebugCommands = auto_free(DebugCommands.new())
	debug_commands.knock_out(first_fight_controller, FightModel.Side.ENEMY)
	_select_first_offers(await run_controller.level_up_started)
	_press_continue(run_controller)
	var fight_controller: FightController = await run_controller.fight_started

	assert_array(fight_controller.fight_model.heroes).contains([hero])
	assert_int(hero.health).is_equal(7)
	assert_int(hero.ap).is_equal(0)
	assert_int(hero.skills[0].cooldown_beats).is_equal(2)
	assert_array(fight_controller.fight_model.timeline).is_empty()


func test_a_victory_opens_the_level_up_and_the_next_fight_carries_its_picks() -> void:
	var runner := scene_runner(RUN_SCENE)
	var run_controller := runner.scene() as RunController
	runner.set_time_factor(TIME_FACTOR)
	var first_fight_controller: FightController = await run_controller.fight_started
	await runner.await_func_on(first_fight_controller.hero_brain, "is_waiting").is_true()
	for index in 2:
		var completed := run_controller.run_model.create_level_up()
		_select_first_offers(completed)
		run_controller.run_model.confirm_level_up(completed)

	var debug_commands: DebugCommands = auto_free(DebugCommands.new())
	debug_commands.knock_out(first_fight_controller, FightModel.Side.ENEMY)
	var level_up: LevelUp = await run_controller.level_up_started

	assert_int(level_up.draft).is_equal(LevelUp.Draft.SKILL)
	assert_object(run_controller.fight_controller).is_null()
	var picks: Dictionary[Character, SkillData] = {}
	for hero in level_up.heroes:
		var offer := level_up.get_offers(hero)[0] as SkillOffer
		level_up.select_offer(hero, offer)
		picks[hero] = offer.skill.data
	_press_continue(run_controller)
	var fight_controller: FightController = await run_controller.fight_started

	for hero in picks:
		assert_array(fight_controller.fight_model.heroes).contains([hero])
		assert_object(hero.skills.back().data).is_same(picks[hero])


func _select_first_offers(level_up: LevelUp) -> void:
	for hero in level_up.heroes:
		if not level_up.is_skipped(hero):
			var offer := level_up.get_offers(hero)[0]
			level_up.select_offer(hero, offer, offer.perks[0] if offer.is_upgrade() else null)


func _press_continue(run_controller: RunController) -> void:
	(run_controller.get_node("LevelUpView/ContinueButton") as TextureButton).pressed.emit()
