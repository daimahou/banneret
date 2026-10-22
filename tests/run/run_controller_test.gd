extends GdUnitTestSuite

const RUN_SCENE := "res://run/run.tscn"


func test_a_new_run_holds_the_party_at_full_health() -> void:
	var run_controller := scene_runner(RUN_SCENE).scene() as RunController
	var party := run_controller.run_model.party
	assert_int(party.size()).is_equal(RunModel.PARTY_HERO_IDS.size())
	for index in party.size():
		assert_object(party[index].data).is_same(RunModel.HERO_REGISTRY.load_entry(RunModel.PARTY_HERO_IDS[index]))
		assert_int(party[index].health).is_equal(party[index].data.max_health)


func test_a_new_mission_keeps_the_party_and_only_it_answers_the_stage() -> void:
	var runner := scene_runner(RUN_SCENE)
	var run_controller := runner.scene() as RunController
	var stage: Stage = run_controller.get_node("Stage")
	await runner.await_func("get_mission_controller").is_not_null()
	var party := run_controller.run_model.party.duplicate()
	var first_mission_controller := run_controller.get_mission_controller()

	run_controller.start_mission(2)

	assert_object(run_controller.get_mission_controller()).is_not_same(first_mission_controller)
	for index in party.size():
		assert_object(run_controller.run_model.party[index]).is_same(party[index])
	for stage_signal in [stage.map_node_pressed, stage.offer_pressed]:
		var connected_objects: Array = stage_signal.get_connections().map(func(connection: Dictionary) -> Object: return connection.callable.get_object())
		assert_array(connected_objects).contains_exactly([run_controller.get_mission_controller()])
