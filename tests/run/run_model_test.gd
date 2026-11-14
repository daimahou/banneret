extends GdUnitTestSuite

const SKILL_DRAFT_NUMBERS: Array[int] = [3, 6, 8, 11, 14, 16, 19, 22, 24, 27, 30, 32, 35, 37]
const RUN_SEED := 1


func test_the_run_is_lost_only_once_every_hero_has_fallen() -> void:
	var run_model := RunModel.new()

	for index in run_model.party.size():
		assert_bool(run_model.is_lost()).is_false()
		run_model.party[index].health = 0

	assert_bool(run_model.is_lost()).is_true()


func test_each_level_up_number_sets_its_draft_until_the_37th() -> void:
	var run_model := RunModel.new(RUN_SEED)

	for number in range(1, 38):
		assert_bool(run_model.has_level_up_left()).is_true()
		var level_up := run_model.create_level_up()
		assert_int(level_up.number).is_equal(number)
		var expected_draft := LevelUp.Draft.SKILL if number in SKILL_DRAFT_NUMBERS else LevelUp.Draft.TALENT
		assert_int(level_up.draft).is_equal(expected_draft)
		_confirm_first_offers(run_model, level_up)

	assert_bool(run_model.has_level_up_left()).is_false()


func test_the_count_advances_only_when_a_level_up_is_confirmed() -> void:
	var run_model := RunModel.new(RUN_SEED)

	run_model.create_level_up()
	assert_int(run_model.level_up_count).is_equal(0)
	assert_int(run_model.create_level_up().number).is_equal(1)
	_confirm_first_offers(run_model, run_model.create_level_up())

	assert_int(run_model.level_up_count).is_equal(1)
	assert_int(run_model.create_level_up().number).is_equal(2)


func test_an_all_skipped_level_up_is_confirmed_without_picks() -> void:
	var run_model := RunModel.new(RUN_SEED)
	for hero in run_model.party:
		hero.health = 0
	var level_up := run_model.create_level_up()
	assert_bool(level_up.has_offers()).is_false()

	run_model.confirm_level_up(level_up)

	assert_int(run_model.level_up_count).is_equal(1)


func test_a_level_up_already_confirmed_is_rejected() -> void:
	var run_model := RunModel.new(RUN_SEED)
	var level_up := run_model.create_level_up()
	_confirm_first_offers(run_model, level_up)

	var confirm_again := func() -> void: run_model.confirm_level_up(level_up)
	await assert_error(confirm_again).is_push_error("Level-up 1 is not the next one")

	assert_int(run_model.level_up_count).is_equal(1)


func test_confirming_applies_each_selection_to_its_own_hero() -> void:
	var run_model := RunModel.new(RUN_SEED)
	_complete_level_ups(run_model, 2)
	var level_up := run_model.create_level_up()
	var selected: Array[SkillData] = []
	for index in level_up.heroes.size():
		var hero := level_up.heroes[index]
		var offer := level_up.get_offers(hero)[index] as SkillOffer
		level_up.select_offer(hero, offer)
		selected.append(offer.skill_data)

	run_model.confirm_level_up(level_up)

	for index in level_up.heroes.size():
		assert_int(level_up.heroes[index].skills.size()).is_equal(2)
		assert_object(level_up.heroes[index].skills.back().data).is_same(selected[index])


func test_a_level_up_waiting_on_a_selection_is_not_confirmed() -> void:
	var run_model := RunModel.new(RUN_SEED)
	_complete_level_ups(run_model, 2)
	var level_up := run_model.create_level_up()
	var hero := level_up.heroes[0]
	level_up.select_offer(hero, level_up.get_offers(hero)[0])

	var confirm := func() -> void: run_model.confirm_level_up(level_up)
	await assert_error(confirm).is_push_error("Level-up 3 waits on a selection")

	assert_int(hero.skills.size()).is_equal(1)
	assert_int(run_model.level_up_count).is_equal(2)


func test_the_same_run_seed_draws_the_same_offers_however_often_they_are_drawn() -> void:
	var run_model := RunModel.new(RUN_SEED)
	var other_run_model := RunModel.new(RUN_SEED)
	_complete_level_ups(run_model, 2)
	_complete_level_ups(other_run_model, 2)

	var offered := _get_offered(run_model.create_level_up())

	assert_array(offered).is_not_empty()
	assert_array(_get_offered(run_model.create_level_up())).is_equal(offered)
	assert_array(_get_offered(other_run_model.create_level_up())).is_equal(offered)


func test_a_new_run_starts_before_the_first_level_up() -> void:
	assert_int(RunModel.new().level_up_count).is_equal(0)
	assert_int(RunModel.new().create_level_up().number).is_equal(1)


func test_a_skill_pick_from_the_run_reaches_the_hero() -> void:
	var run_model := RunModel.new(RUN_SEED)
	_complete_level_ups(run_model, 2)
	var level_up := run_model.create_level_up()
	var hero := run_model.party[0]
	var offer := level_up.get_offers(hero)[0] as SkillOffer

	_confirm_first_offers(run_model, level_up)

	assert_object(hero.skills.back().data).is_same(offer.skill_data)


func test_confirming_an_upgrade_raises_its_skill_with_the_chosen_perk() -> void:
	var run_model := RunModel.new(RUN_SEED)
	_complete_level_ups(run_model, 2)
	var hero := run_model.party[0]
	var skill := Skill.new(SkillData.new())
	var perk := SkillFixture.add_rank(skill.data, 2).perks[1]
	var gained := SkillFixture.create_damage(1)
	perk.effects.append(gained)
	hero.skills.append(skill)
	var level_up := run_model.create_level_up()
	var is_upgrade := func(offer: LevelUpOffer) -> bool: return offer.is_upgrade()
	var upgrade: LevelUpOffer = level_up.get_offers(hero).filter(is_upgrade)[0]

	level_up.select_offer(hero, upgrade, perk)
	_confirm_first_offers(run_model, level_up)

	assert_array(skill.get_effects()).contains([gained])
	assert_object(skill.get_next_rank()).is_null()


func test_a_talent_pick_from_the_run_reaches_the_hero() -> void:
	var run_model := RunModel.new(RUN_SEED)
	var level_up := run_model.create_level_up()
	var hero := run_model.party[0]
	var offer := level_up.get_offers(hero)[0] as TalentOffer

	_confirm_first_offers(run_model, level_up)

	assert_object(hero.talents.back().data).is_same(offer.talent_data)


func _complete_level_ups(run_model: RunModel, count: int) -> void:
	for index in count:
		_confirm_first_offers(run_model, run_model.create_level_up())


func _confirm_first_offers(run_model: RunModel, level_up: LevelUp) -> void:
	for hero in level_up.heroes:
		if not level_up.is_skipped(hero) and level_up.get_selected_offer(hero) == null:
			var offer := level_up.get_offers(hero)[0]
			level_up.select_offer(hero, offer, offer.get_perks()[0] if offer.is_upgrade() else null)
	run_model.confirm_level_up(level_up)


# Each hero's offered skills, in party order.
func _get_offered(level_up: LevelUp) -> Array:
	return level_up.heroes.map(func(hero: Character) -> Array:
		return level_up.get_offers(hero).map(func(offer: SkillOffer) -> SkillData: return offer.skill_data))
