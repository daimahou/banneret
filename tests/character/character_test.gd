extends GdUnitTestSuite

const MAX_HEALTH := 10
const MAX_AP := 2


func test_a_talent_s_max_health_gain_raises_health_by_as_much() -> void:
	var hero := _create_hero()
	hero.health = 4

	hero.add_talent(_create_talent(HeroModifier.Stat.MAX_HEALTH, 3))

	assert_int(hero.get_max_health()).is_equal(13)
	assert_int(hero.health).is_equal(7)


func test_a_talent_s_max_ap_gain_raises_ap_by_as_much() -> void:
	var hero := _create_hero()
	hero.ap = 1

	hero.add_talent(_create_talent(HeroModifier.Stat.MAX_AP, 1))

	assert_int(hero.get_max_ap()).is_equal(3)
	assert_int(hero.ap).is_equal(2)


func test_max_ap_never_exceeds_the_cap_nor_does_the_gain() -> void:
	var hero := _create_hero()
	hero.ap = 1

	hero.add_talent(_create_talent(HeroModifier.Stat.MAX_AP, CharacterData.MAX_AP))

	assert_int(hero.get_max_ap()).is_equal(CharacterData.MAX_AP)
	assert_int(hero.ap).is_equal(1 + CharacterData.MAX_AP - MAX_AP)


func test_a_max_loss_leaves_health_below_the_new_max_unchanged() -> void:
	var hero := _create_hero()
	hero.health = 5

	hero.add_talent(_create_talent(HeroModifier.Stat.MAX_HEALTH, -3))

	assert_int(hero.get_max_health()).is_equal(7)
	assert_int(hero.health).is_equal(5)


func test_a_max_loss_clamps_health_above_the_new_max() -> void:
	var hero := _create_hero()

	hero.add_talent(_create_talent(HeroModifier.Stat.MAX_HEALTH, -3))

	assert_int(hero.health).is_equal(7)


func test_a_fallen_hero_stays_at_zero_health_on_a_max_gain() -> void:
	var hero := _create_hero()
	hero.health = 0

	hero.add_talent(_create_talent(HeroModifier.Stat.MAX_HEALTH, 3))

	assert_int(hero.health).is_equal(0)


func test_an_upgrade_s_rank_and_perk_modifiers_follow_the_same_rule() -> void:
	var hero := _create_hero()
	hero.health = 4
	var talent := Talent.new(TalentFixture.create_talent_data("Talent"))
	var rank := TalentFixture.add_rank(talent.data)
	rank.modifiers.append(TalentFixture.create_modifier(HeroModifier.Stat.MAX_HEALTH, 2))
	rank.perks[0].modifiers.append(TalentFixture.create_modifier(HeroModifier.Stat.MAX_HEALTH, 1))
	hero.add_talent(talent)

	hero.upgrade_talent(talent, rank.perks[0])

	assert_int(hero.get_max_health()).is_equal(13)
	assert_int(hero.health).is_equal(7)


func test_a_hero_starts_with_its_class_and_full_resources() -> void:
	var class_data := TalentFixture.create_talent_data("Class")
	class_data.modifiers.append(TalentFixture.create_modifier(HeroModifier.Stat.MAX_HEALTH, 5))

	var hero := _create_hero(class_data)

	assert_object(hero.talents[0].data).is_same(class_data)
	assert_int(hero.health).is_equal(15)


func test_a_copy_keeps_its_talents_maxima() -> void:
	var hero := _create_hero()
	hero.add_talent(_create_talent(HeroModifier.Stat.MAX_HEALTH, 3))

	assert_int(hero.duplicate().get_max_health()).is_equal(13)


func _create_hero(class_data: TalentData = null) -> Character:
	var hero_data := CharacterData.new()
	hero_data.name = "Hero"
	hero_data.max_health = MAX_HEALTH
	hero_data.max_ap = MAX_AP
	hero_data.class_talent = class_data
	return Character.new(hero_data)


func _create_talent(stat: HeroModifier.Stat, amount: int) -> Talent:
	var talent_data := TalentFixture.create_talent_data("Talent")
	talent_data.modifiers.append(TalentFixture.create_modifier(stat, amount))
	return Talent.new(talent_data)
