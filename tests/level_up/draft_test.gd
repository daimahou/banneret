extends GdUnitTestSuite


func test_selecting_and_backing_out_keeps_the_offers_and_the_build() -> void:
	var draft := _create_draft([_create_hero(), _create_hero()])
	var hero_draft := draft.hero_drafts[0]
	var offers := hero_draft.offers.duplicate()
	var other_offers := draft.hero_drafts[1].offers.duplicate()

	for offer in offers:
		hero_draft.select_offer(offer)
		if offer.is_upgrade():
			hero_draft.select_talent(offer.talents[0])
		draft.hero_drafts[1].select_offer(other_offers[0])
		hero_draft.back()

	assert_array(hero_draft.offers).contains_exactly(offers)
	assert_array(draft.hero_drafts[1].offers).contains_exactly(other_offers)
	for hero_draft_any in draft.hero_drafts:
		assert_int(hero_draft_any.hero.build.passives.size()).is_equal(0)
		assert_int(hero_draft_any.hero.build.class_skill.get_rank()).is_equal(0)


func test_confirming_applies_the_choice_once_to_its_hero_only() -> void:
	var hero := _create_hero()
	var other := _create_hero()
	var draft := _create_draft([hero, other])
	var hero_draft := draft.hero_drafts[0]
	var new_offer: DraftOffer = hero_draft.offers.filter(func(offer: DraftOffer) -> bool: return not offer.is_upgrade())[0]

	hero_draft.select_offer(new_offer)
	hero_draft.confirm()
	hero_draft.confirm()
	hero_draft.select_offer(hero_draft.offers[1])
	hero_draft.confirm()

	assert_bool(hero.build.owns(new_offer.skill)).is_true()
	assert_int(hero.build.passives.size()).is_equal(1)
	assert_int(other.build.passives.size()).is_equal(0)


func test_an_upgrade_confirms_only_with_a_talent_and_takes_one_rank() -> void:
	var hero := _create_hero()
	var draft := _create_draft([hero])
	var hero_draft := draft.hero_drafts[0]
	var upgrade_offer: DraftOffer = hero_draft.offers.filter(func(offer: DraftOffer) -> bool: return offer.is_upgrade())[0]

	hero_draft.select_offer(upgrade_offer)
	hero_draft.confirm()
	assert_bool(hero_draft.is_done()).is_false()

	hero_draft.select_talent(upgrade_offer.talents[0])
	hero_draft.confirm()

	assert_bool(hero_draft.is_done()).is_true()
	assert_int(upgrade_offer.owned.get_rank()).is_equal(1)
	assert_array(upgrade_offer.owned.talents).contains_exactly([upgrade_offer.talents[0]])


func test_fallen_and_starved_heroes_are_skipped_and_the_draft_completes_without_them() -> void:
	var fallen := _create_hero()
	fallen.health = 0
	var starved := _create_hero()
	starved.build.class_skill = null
	var draft := Draft.new([fallen, starved], Learnable.Kind.PASSIVE, [], func() -> float: return 0.5)

	assert_int(draft.hero_drafts[0].state).is_equal(HeroDraft.State.FALLEN)
	assert_int(draft.hero_drafts[1].state).is_equal(HeroDraft.State.STARVED)
	assert_bool(draft.is_complete()).is_true()


func test_the_draft_completes_once_every_hero_has_confirmed() -> void:
	var draft := _create_draft([_create_hero(), _create_hero()])

	for hero_draft in draft.hero_drafts:
		assert_bool(draft.is_complete()).is_false()
		var offer: DraftOffer = hero_draft.offers.filter(func(offer: DraftOffer) -> bool: return not offer.is_upgrade())[0]
		hero_draft.select_offer(offer)
		hero_draft.confirm()

	assert_bool(draft.is_complete()).is_true()


func _create_draft(heroes: Array[Character]) -> Draft:
	var bag: Array[Learnable] = [_create_passive(), _create_passive(), _create_passive()]
	return Draft.new(heroes, Learnable.Kind.PASSIVE, bag, func() -> float: return 0.5)


func _create_hero() -> Character:
	var character_data := CharacterData.new()
	character_data.max_health = 10
	character_data.starting_class = ClassData.new()
	var upgrade := Upgrade.new()
	upgrade.talents = [Talent.new(), Talent.new()]
	character_data.starting_class.upgrades = [upgrade]
	return Character.new(character_data)


func _create_passive() -> PassiveData:
	var passive := PassiveData.new()
	var upgrade := Upgrade.new()
	upgrade.talents = [Talent.new()]
	passive.upgrades = [upgrade]
	return passive
