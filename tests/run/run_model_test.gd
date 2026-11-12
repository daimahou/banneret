extends GdUnitTestSuite


func test_the_run_is_lost_only_once_every_hero_has_fallen() -> void:
	var run_model := RunModel.new()

	for index in run_model.party.size():
		assert_bool(run_model.is_lost()).is_false()
		run_model.party[index].health = 0

	assert_bool(run_model.is_lost()).is_true()
