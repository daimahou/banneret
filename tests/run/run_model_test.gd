extends GdUnitTestSuite


func test_each_encounter_brings_fresh_enemies_at_full_health() -> void:
	var run_model := RunModel.new()
	var first_enemies := run_model.create_encounter_enemies()
	first_enemies[0].health = 0

	var next_enemies := run_model.create_encounter_enemies()

	assert_int(next_enemies.size()).is_equal(RunModel.ENCOUNTER_ENEMIES.size())
	for enemy in next_enemies:
		assert_array(first_enemies).not_contains([enemy])
		assert_int(enemy.health).is_equal(enemy.data.max_health)


func test_the_run_is_lost_only_once_every_hero_has_fallen() -> void:
	var run_model := RunModel.new()

	for index in run_model.party.size():
		assert_bool(run_model.is_lost()).is_false()
		run_model.party[index].health = 0

	assert_bool(run_model.is_lost()).is_true()
