extends GdUnitTestSuite

const SKILL_DRAFT_NUMBER := 3

var _rng := RandomNumberGenerator.new()


func before_test() -> void:
	_rng.seed = 1


func test_each_hero_gets_three_distinct_offers_of_skills_they_do_not_own() -> void:
	var bag := _create_bag(5)
	var hero := _create_hero()
	hero.skills.append(Skill.new(bag[0]))

	var offers := _create_level_up([hero], bag).get_offers(hero)

	assert_int(offers.size()).is_equal(LevelUp.OFFER_COUNT)
	var offered := offers.map(func(offer: LevelUpOffer) -> SkillData: return offer.skill_data)
	assert_array(bag).contains(offered)
	assert_array(offered).not_contains([bag[0]])
	for skill_data in offered:
		assert_int(offered.count(skill_data)).is_equal(1)


func test_fewer_valid_skills_than_three_are_all_offered() -> void:
	var bag := _create_bag(2)
	var hero := _create_hero()

	var offers := _create_level_up([hero], bag).get_offers(hero)

	var offered := offers.map(func(offer: LevelUpOffer) -> SkillData: return offer.skill_data)
	assert_array(offered).contains_exactly_in_any_order(bag)


func test_offers_stay_the_same_across_reads() -> void:
	var hero := _create_hero()
	var level_up := _create_level_up([hero], _create_bag(5))

	assert_array(level_up.get_offers(hero)).is_equal(level_up.get_offers(hero))


func test_a_hero_with_every_skill_slot_full_is_skipped() -> void:
	var bag := _create_bag(5)
	var hero := _create_hero()
	while hero.has_free_skill_slot():
		hero.skills.append(Skill.new(_create_skill_data("Owned")))

	var level_up := _create_level_up([hero], bag)

	assert_array(level_up.get_offers(hero)).is_empty()
	assert_bool(level_up.is_skipped(hero)).is_true()


func test_a_hero_owning_the_whole_bag_is_skipped() -> void:
	var bag := _create_bag(1)
	var hero := _create_hero()
	hero.skills.append(Skill.new(bag[0]))

	assert_bool(_create_level_up([hero], bag).is_skipped(hero)).is_true()


func test_a_skipped_hero_is_warned_by_name_and_draft() -> void:
	var hero := _create_hero()
	var create_level_up := func() -> void: _create_level_up([hero], [])

	await assert_error(create_level_up).is_push_warning("Hero has no offer in the skill draft of level-up 3")


func test_a_fallen_hero_is_skipped_while_the_others_pick() -> void:
	var fallen := _create_hero()
	fallen.health = 0
	var standing := _create_hero()

	var level_up := _create_level_up([fallen, standing], _create_bag(3))

	assert_array(level_up.get_offers(fallen)).is_empty()
	assert_bool(level_up.is_skipped(fallen)).is_true()
	assert_bool(level_up.is_skipped(standing)).is_false()
	assert_int(level_up.get_ready_count()).is_equal(1)
	assert_bool(level_up.is_ready()).is_false()


func test_a_talent_draft_skips_every_hero() -> void:
	var level_up := LevelUp.new(1, [_create_hero(), _create_hero()], _create_bag(3), _rng)

	assert_int(level_up.draft).is_equal(LevelUp.Draft.TALENT)
	assert_bool(level_up.has_offers()).is_false()


func test_a_selection_makes_its_hero_ready_and_can_be_changed_without_applying_it() -> void:
	var hero := _create_hero()
	var other := _create_hero()
	var level_up := _create_level_up([hero, other], _create_bag(5))
	var offers := level_up.get_offers(hero)

	level_up.select_offer(hero, offers[0])
	level_up.select_offer(hero, offers[1])

	assert_object(level_up.get_selected_offer(hero)).is_same(offers[1])
	assert_int(level_up.get_ready_count()).is_equal(1)
	assert_bool(level_up.is_ready()).is_false()
	assert_int(hero.skills.size()).is_equal(1)


func test_a_skill_draft_offers_two_new_skills_and_one_upgrade_of_an_owned_skill() -> void:
	var hero := _create_hero()
	SkillFixture.add_rank(hero.skills[0].data)

	var offers := _create_level_up([hero], _create_bag(5)).get_offers(hero)

	var upgrades := offers.filter(func(offer: LevelUpOffer) -> bool: return offer.is_upgrade())
	assert_int(offers.size()).is_equal(LevelUp.OFFER_COUNT)
	assert_int(upgrades.size()).is_equal(1)
	assert_object(upgrades[0].skill).is_same(hero.skills[0])


func test_upgrades_fill_the_places_the_bag_cannot() -> void:
	var hero := _create_hero()
	for skill_name in ["Basic attack", "Owned"]:
		hero.skills.append(Skill.new(_create_skill_data(skill_name)))
	for skill in hero.skills:
		SkillFixture.add_rank(skill.data)

	var offers := _create_level_up([hero], _create_bag(1)).get_offers(hero)

	var upgrades := offers.filter(func(offer: LevelUpOffer) -> bool: return offer.is_upgrade())
	assert_int(offers.size()).is_equal(LevelUp.OFFER_COUNT)
	assert_int(upgrades.size()).is_equal(2)
	assert_int(upgrades[0].skill.id).is_not_equal(upgrades[1].skill.id)


func test_a_hero_with_every_skill_slot_full_is_offered_upgrades_only() -> void:
	var hero := _create_hero()
	while hero.has_free_skill_slot():
		hero.skills.append(Skill.new(_create_skill_data("Owned")))
	for skill in hero.skills:
		SkillFixture.add_rank(skill.data)

	var offers := _create_level_up([hero], _create_bag(5)).get_offers(hero)

	assert_int(offers.size()).is_equal(LevelUp.OFFER_COUNT)
	assert_bool(offers.all(func(offer: LevelUpOffer) -> bool: return offer.is_upgrade())).is_true()


func test_a_skill_at_expert_is_not_upgradable() -> void:
	var hero := _create_hero()
	var skill := hero.skills[0]
	for rank in Skill.Rank.EXPERT:
		skill.upgrade(SkillFixture.add_rank(skill.data).perks[0])
	SkillFixture.add_rank(skill.data)

	assert_bool(_create_level_up([hero], []).is_skipped(hero)).is_true()


func test_a_skill_whose_next_rank_has_no_perk_is_not_upgradable() -> void:
	var hero := _create_hero()
	SkillFixture.add_rank(hero.skills[0].data, 0)

	assert_bool(_create_level_up([hero], []).is_skipped(hero)).is_true()


func test_an_upgrade_lists_its_next_rank_s_perks_in_authored_order() -> void:
	var hero := _create_hero()
	var rank := SkillFixture.add_rank(hero.skills[0].data, LevelUp.PERK_LIMIT)

	var offers := _create_level_up([hero], []).get_offers(hero)

	assert_array(offers[0].get_perks()).contains_exactly(rank.perks)


func test_more_perks_than_the_limit_are_reported_and_all_kept() -> void:
	var hero := _create_hero()
	var rank := SkillFixture.add_rank(hero.skills[0].data, LevelUp.PERK_LIMIT + 1)
	var offers: Array[LevelUpOffer] = []
	var create_level_up := func() -> void: offers.append_array(_create_level_up([hero], []).get_offers(hero))

	await assert_error(create_level_up).is_push_error("Basic attack has 5 perks at Advanced, more than 4")

	assert_array(offers[0].get_perks()).contains_exactly(rank.perks)


func test_an_upgrade_is_selected_with_one_of_its_perks() -> void:
	var hero := _create_hero()
	var rank := SkillFixture.add_rank(hero.skills[0].data, 3)
	var level_up := _create_level_up([hero], [])

	level_up.select_offer(hero, level_up.get_offers(hero)[0], rank.perks[1])

	assert_object(level_up.get_selected_perk(hero)).is_same(rank.perks[1])
	assert_bool(level_up.is_ready()).is_true()


func test_an_upgrade_without_one_of_its_perks_cannot_be_selected() -> void:
	var hero := _create_hero()
	SkillFixture.add_rank(hero.skills[0].data)
	var level_up := _create_level_up([hero], [])
	var select := func() -> void: level_up.select_offer(hero, level_up.get_offers(hero)[0], SkillPerk.new())

	await assert_error(select).is_push_error("Hero cannot select that perk")

	assert_bool(level_up.is_ready()).is_false()


func _create_level_up(heroes: Array[Character], bag: Array[SkillData]) -> LevelUp:
	return LevelUp.new(SKILL_DRAFT_NUMBER, heroes, bag, _rng)


func _create_hero() -> Character:
	var hero_data := CharacterData.new()
	hero_data.name = "Hero"
	hero_data.max_health = 10
	hero_data.skills.append(_create_skill_data("Basic attack"))
	return Character.new(hero_data)


func _create_bag(size: int) -> Array[SkillData]:
	var bag: Array[SkillData] = []
	for index in size:
		bag.append(_create_skill_data("Skill %d" % index))
	return bag


func _create_skill_data(skill_name: String) -> SkillData:
	var skill_data := SkillData.new()
	skill_data.name = skill_name
	return skill_data
