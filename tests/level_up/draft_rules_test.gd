extends GdUnitTestSuite

const ROLLS: Array[float] = [0.0, 0.3, 0.5, 0.7, 0.99]


func test_offers_are_distinct_skills_of_the_draft_kind_and_new_ones_are_not_owned() -> void:
	var hero := _create_hero()
	hero.build.learn(_create_passive())
	var bag: Array[Learnable] = [_create_passive(), _create_passive(), _create_passive(), _create_active(), _create_active()]
	for kind in [Learnable.Kind.PASSIVE, Learnable.Kind.ACTIVE]:
		for roll in ROLLS:
			var offers := DraftRules.create_offers(hero, kind, bag, func() -> float: return roll)
			var skills: Array[Learnable] = []
			for offer in offers:
				skills.append(offer.skill)
				assert_int(offer.skill.get_kind()).is_equal(kind)
				assert_bool(hero.build.owns(offer.skill)).is_equal(offer.owned != null)
			assert_int(offers.size()).is_equal(DraftRules.OFFER_COUNT)
			for skill in skills:
				assert_int(skills.count(skill)).is_equal(1)



func test_a_hero_with_no_free_slot_is_offered_only_upgrades() -> void:
	var hero := _create_hero()
	for count in Build.PASSIVE_SLOTS:
		hero.build.learn(_create_passive())
	var bag: Array[Learnable] = [_create_passive(), _create_passive()]

	for roll in ROLLS:
		var offers := DraftRules.create_offers(hero, Learnable.Kind.PASSIVE, bag, func() -> float: return roll)

		assert_int(offers.size()).is_equal(DraftRules.OFFER_COUNT)
		assert_bool(offers.all(func(offer: DraftOffer) -> bool: return offer.is_upgrade())).is_true()


func test_a_hero_with_nothing_to_upgrade_is_offered_only_new_skills() -> void:
	var hero := _create_hero()
	hero.build.actives[0].talents.assign(_create_upgrade(2).talents)
	var bag: Array[Learnable] = [_create_active(), _create_active(), _create_active(), _create_active()]

	for roll in ROLLS:
		var offers := DraftRules.create_offers(hero, Learnable.Kind.ACTIVE, bag, func() -> float: return roll)

		assert_int(offers.size()).is_equal(DraftRules.OFFER_COUNT)
		assert_bool(offers.any(func(offer: DraftOffer) -> bool: return offer.is_upgrade())).is_false()


func test_fewer_valid_offers_than_three_are_all_offered() -> void:
	var hero := _create_hero()
	var bag: Array[Learnable] = [_create_active()]

	var offers := DraftRules.create_offers(hero, Learnable.Kind.ACTIVE, bag, func() -> float: return 0.5)

	assert_int(offers.size()).is_equal(2)


func test_a_hero_with_full_slots_and_maximal_skills_has_no_offers() -> void:
	var hero := _create_hero()
	hero.build.actives[0].talents.assign(_create_upgrade(2).talents)
	for count in Build.ACTIVE_SLOTS:
		var active := _create_active()
		active.upgrades = []
		hero.build.learn(active)

	assert_array(DraftRules.create_offers(hero, Learnable.Kind.ACTIVE, [_create_active()], func() -> float: return 0.5)).is_empty()


func test_every_eligible_upgrade_can_be_drawn() -> void:
	var hero := _create_hero()
	for count in Build.PASSIVE_SLOTS:
		hero.build.learn(_create_passive())
	var drawn: Array[Learnable] = []

	for step in 100:
		var roll := step / 100.0
		for offer in DraftRules.create_offers(hero, Learnable.Kind.PASSIVE, [], func() -> float: return roll):
			drawn.append(offer.skill)

	for owned in hero.build.get_owned(Learnable.Kind.PASSIVE):
		assert_array(drawn).contains([owned.skill])


func test_class_restricted_skills_and_talents_are_offered_only_to_that_class() -> void:
	var hero := _create_hero()
	var specialization := ClassData.new()
	var exclusive := _create_passive()
	exclusive.required_class = specialization
	var owned := _create_passive()
	owned.upgrades = [_create_upgrade(1, specialization)]
	hero.build.learn(owned)
	var bag: Array[Learnable] = [exclusive]

	var offers := _get_all_offers(hero, bag)
	assert_array(offers.map(func(offer: DraftOffer) -> Learnable: return offer.skill)).not_contains([exclusive, owned])

	var talent := Talent.new()
	talent.granted_class = specialization
	hero.build.class_skill.talents.append(talent)

	offers = _get_all_offers(hero, bag)
	assert_array(offers.map(func(offer: DraftOffer) -> Learnable: return offer.skill)).contains([exclusive, owned])


func test_an_upgrade_with_more_eligible_talents_than_the_most_is_not_offered() -> void:
	var hero := _create_hero()
	var oversized := _create_passive()
	oversized.upgrades = [_create_upgrade(DraftRules.MAX_TALENTS + 1)]
	hero.build.learn(oversized)

	var offers := _get_all_offers(hero, [])

	assert_array(offers.map(func(offer: DraftOffer) -> Learnable: return offer.skill)).not_contains([oversized])


func test_a_skill_weighted_zero_for_the_hero_class_is_never_offered() -> void:
	var hero := _create_hero()
	var unwanted := _create_passive()
	unwanted.class_offer_weights[hero.build.get_class_data()] = 0

	var offers := _get_all_offers(hero, [unwanted, _create_passive()])

	assert_array(offers.map(func(offer: DraftOffer) -> Learnable: return offer.skill)).not_contains([unwanted])


func _get_all_offers(hero: Character, bag: Array[Learnable]) -> Array[DraftOffer]:
	var offers: Array[DraftOffer] = []
	for roll in ROLLS:
		offers.append_array(DraftRules.create_offers(hero, Learnable.Kind.PASSIVE, bag, func() -> float: return roll))
	return offers

func _create_hero() -> Character:
	var character_data := CharacterData.new()
	character_data.max_health = 10
	character_data.starting_class = ClassData.new()
	character_data.starting_class.upgrades = [_create_upgrade(2)]
	character_data.skills = [_create_active()]
	return Character.new(character_data)


func _create_passive() -> PassiveData:
	var passive := PassiveData.new()
	passive.upgrades = [_create_upgrade(3), _create_upgrade(3)]
	return passive


func _create_active() -> SkillData:
	var active := SkillData.new()
	active.delay = 4
	active.upgrades = [_create_upgrade(3), _create_upgrade(3)]
	return active


func _create_upgrade(talent_count: int, required_class: ClassData = null) -> Upgrade:
	var upgrade := Upgrade.new()
	for index in talent_count:
		var talent := Talent.new()
		talent.required_class = required_class
		upgrade.talents.append(talent)
	return upgrade
