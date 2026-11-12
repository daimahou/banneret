extends GdUnitTestSuite

const RUN_SCENE := "res://run/run.tscn"
const TIME_FACTOR := 10.0


func test_the_run_opens_on_a_fight_with_the_whole_party() -> void:
	var runner := scene_runner(RUN_SCENE)
	var run_controller := runner.scene() as RunController

	var fight_model := await _await_fight(runner, run_controller)

	assert_array(fight_model.heroes).contains_exactly(run_controller.run_model.party)
	assert_int(fight_model.enemies.size()).is_equal(RunModel.ENCOUNTER_ENEMIES.size())


func test_a_won_fight_leads_to_a_fresh_encounter_with_the_same_party_as_it_stands() -> void:
	var runner := scene_runner(RUN_SCENE)
	var run_controller := runner.scene() as RunController
	var first_fight_model := await _await_fight(runner, run_controller)
	var wounded_hero := first_fight_model.heroes[0]
	await _await_player(runner, run_controller)
	wounded_hero.health = 7
	wounded_hero.ap = 0
	wounded_hero.skill_cooldowns[wounded_hero.data.skills[0]] = 2

	_knock_out(run_controller, FightModel.Side.ENEMY)
	var fight_model := await _await_fight(runner, run_controller)

	assert_array(fight_model.heroes).contains_exactly(first_fight_model.heroes)
	assert_int(wounded_hero.health).is_equal(7)
	assert_int(wounded_hero.ap).is_equal(0)
	assert_int(wounded_hero.skill_cooldowns[wounded_hero.data.skills[0]]).is_equal(2)
	for enemy in fight_model.enemies:
		assert_array(first_fight_model.enemies).not_contains([enemy])
		assert_int(enemy.health).is_equal(enemy.data.max_health)
	assert_array(fight_model.timeline).is_empty()


func test_a_hero_fallen_in_a_won_fight_stays_fallen_in_the_next() -> void:
	var runner := scene_runner(RUN_SCENE)
	var run_controller := runner.scene() as RunController
	var first_fight_model := await _await_fight(runner, run_controller)
	var fallen_hero := first_fight_model.heroes[1]
	await _await_player(runner, run_controller)
	var delta := Delta.new()
	FightRules.add_damage(first_fight_model, delta, fallen_hero, fallen_hero.health)
	first_fight_model.apply(delta)

	_knock_out(run_controller, FightModel.Side.ENEMY)
	var fight_model := await _await_fight(runner, run_controller)

	assert_object(run_controller.run_model.party[1]).is_same(fallen_hero)
	assert_bool(fallen_hero.is_fallen()).is_true()
	assert_array(fight_model.get_standing(FightModel.Side.HERO)).not_contains([fallen_hero])


func test_a_lost_fight_starts_a_fresh_run_on_a_new_fight() -> void:
	var runner := scene_runner(RUN_SCENE)
	var run_controller := runner.scene() as RunController
	var first_fight_model := await _await_fight(runner, run_controller)
	await _await_player(runner, run_controller)

	_knock_out(run_controller, FightModel.Side.HERO)
	var fight_model := await _await_fight(runner, run_controller)

	var party := run_controller.run_model.party
	assert_array(fight_model.heroes).contains_exactly(party)
	for hero in party:
		assert_array(first_fight_model.heroes).not_contains([hero])
		assert_int(hero.health).is_equal(hero.data.max_health)


func _await_player(runner: GdUnitSceneRunner, run_controller: RunController) -> void:
	await runner.await_func_on(run_controller.fight_controller.hero_brain, "is_waiting").is_true()


func _knock_out(run_controller: RunController, side: FightModel.Side) -> void:
	var debug_commands: DebugCommands = auto_free(DebugCommands.new())
	debug_commands.knock_out(run_controller.fight_controller, side)


func _await_fight(runner: GdUnitSceneRunner, run_controller: RunController) -> FightModel:
	runner.set_time_factor(TIME_FACTOR)
	var fight_controller: FightController = await run_controller.fight_started
	return fight_controller.fight_model
