extends GdUnitTestSuite

const SKILL_DRAFT_NUMBER := 3

var _basic_attack := _create_skill_data("Basic attack")
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


func test_confirming_applies_each_selection_to_its_own_hero_once() -> void:
	var heroes: Array[Character] = [_create_hero(), _create_hero()]
	var level_up := _create_level_up(heroes, _create_bag(5))
	var selected: Array[SkillData] = []
	for index in heroes.size():
		var offer: LevelUpOffer = level_up.get_offers(heroes[index])[index]
		level_up.select_offer(heroes[index], offer)
		selected.append(offer.skill_data)
	assert_bool(level_up.is_ready()).is_true()

	level_up.confirm_picks()
	await assert_error(level_up.confirm_picks).is_push_error("Level-up 3 is already confirmed")

	for index in heroes.size():
		assert_int(heroes[index].skills.size()).is_equal(2)
		assert_object(heroes[index].skills.back().data).is_same(selected[index])


func test_picks_are_not_confirmed_while_a_hero_has_no_selection() -> void:
	var hero := _create_hero()
	var other := _create_hero()
	var level_up := _create_level_up([hero, other], _create_bag(5))
	level_up.select_offer(hero, level_up.get_offers(hero)[0])

	await assert_error(level_up.confirm_picks).is_push_error("Level-up 3 waits on a selection")

	assert_int(hero.skills.size()).is_equal(1)


func _create_level_up(heroes: Array[Character], bag: Array[SkillData]) -> LevelUp:
	return LevelUp.new(SKILL_DRAFT_NUMBER, heroes, bag, _rng)


func _create_hero() -> Character:
	var hero_data := CharacterData.new()
	hero_data.name = "Hero"
	hero_data.max_health = 10
	hero_data.skills.append(_basic_attack)
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
