extends GdUnitTestSuite

const SKILL_DRAFT_NUMBERS: Array[int] = [3, 6, 8, 11, 14, 16, 19, 22, 24, 27, 30, 32, 35, 37]


func test_the_run_is_lost_only_once_every_hero_has_fallen() -> void:
	var run_model := RunModel.new()

	for index in run_model.party.size():
		assert_bool(run_model.is_lost()).is_false()
		run_model.party[index].health = 0

	assert_bool(run_model.is_lost()).is_true()


func test_each_level_up_number_sets_its_draft_until_the_37th() -> void:
	var run_model := RunModel.new(_create_seeded_rng())

	for number in range(1, 38):
		var level_up := run_model.get_next_level_up()
		assert_int(level_up.number).is_equal(number)
		var expected_draft := LevelUp.Draft.SKILL if number in SKILL_DRAFT_NUMBERS else LevelUp.Draft.TALENT
		assert_int(level_up.draft).is_equal(expected_draft)
		_confirm_first_offers(level_up)

	assert_object(run_model.get_next_level_up()).is_null()


func test_the_count_advances_only_once_the_level_up_completes() -> void:
	var run_model := RunModel.new(_create_seeded_rng())
	_complete_level_ups(run_model, 2)
	var level_up := run_model.get_next_level_up()
	assert_int(level_up.draft).is_equal(LevelUp.Draft.SKILL)

	assert_object(run_model.get_next_level_up()).is_same(level_up)
	_confirm_first_offers(level_up)

	assert_int(run_model.get_next_level_up().number).is_equal(4)


func test_an_all_skipped_level_up_completes_at_once_and_advances_the_count() -> void:
	var run_model := RunModel.new(_create_seeded_rng())

	var level_up := run_model.get_next_level_up()

	assert_int(level_up.draft).is_equal(LevelUp.Draft.TALENT)
	assert_bool(level_up.is_complete()).is_true()
	assert_int(run_model.get_next_level_up().number).is_equal(2)


func test_a_new_run_starts_at_the_first_level_up() -> void:
	var run_model := RunModel.new(_create_seeded_rng())
	_complete_level_ups(run_model, 3)

	assert_int(RunModel.new().get_next_level_up().number).is_equal(1)


func test_a_skill_pick_from_the_run_reaches_the_hero() -> void:
	var run_model := RunModel.new(_create_seeded_rng())
	_complete_level_ups(run_model, 2)
	var level_up := run_model.get_next_level_up()
	var hero := run_model.party[0]
	var offer: LevelUpOffer = level_up.get_offers(hero)[0]

	_confirm_first_offers(level_up)

	assert_object(hero.skills.back().data).is_same(offer.skill_data)


func _complete_level_ups(run_model: RunModel, count: int) -> void:
	for index in count:
		_confirm_first_offers(run_model.get_next_level_up())


func _confirm_first_offers(level_up: LevelUp) -> void:
	if level_up.is_complete():
		return
	for hero in level_up.heroes:
		if level_up.get_state(hero) == LevelUp.State.PENDING:
			level_up.select_offer(hero, level_up.get_offers(hero)[0])
	level_up.confirm_picks()


func _create_seeded_rng() -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	return rng
