extends GdUnitTestSuite


func test_the_run_is_lost_only_once_every_hero_has_fallen() -> void:
	var run_model := RunModel.new()

	for index in run_model.party.size():
		assert_bool(run_model.is_lost()).is_false()
		run_model.party[index].health = 0

	assert_bool(run_model.is_lost()).is_true()


func test_each_completed_draft_advances_one_pick_until_progression_is_complete() -> void:
	var run_model := RunModel.new()
	for hero in run_model.party:
		hero.health = 0

	for pick in range(1, DraftRules.PICK_COUNT + 1):
		assert_int(run_model.next_pick).is_equal(pick)
		var draft := run_model.open_draft()
		assert_bool(draft.is_complete()).is_true()
		run_model.close_draft()
		run_model.close_draft()

	assert_bool(run_model.is_progression_complete()).is_true()
	assert_object(run_model.open_draft()).is_null()
	assert_int(RunModel.new().next_pick).is_equal(1)


func test_an_unfinished_draft_does_not_advance_the_pick() -> void:
	var run_model := RunModel.new()

	var draft := run_model.open_draft()
	run_model.close_draft()

	assert_bool(draft.is_complete()).is_false()
	assert_int(run_model.next_pick).is_equal(1)
	assert_object(run_model.open_draft()).is_same(draft)
