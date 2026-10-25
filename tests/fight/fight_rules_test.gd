extends GdUnitTestSuite


func test_an_action_resolves_its_skills_delay_after_it_was_chosen() -> void:
	var fight_model := _create_fight_model()
	var first := _create_choice(fight_model, fight_model.heroes[0], 2)
	fight_model.apply(FightRules.get_timeline_delta(fight_model, first))
	fight_model.apply(FightRules.get_resolve_delta(fight_model, first))
	var second := _create_choice(fight_model, fight_model.heroes[0], 3)
	fight_model.apply(FightRules.get_timeline_delta(fight_model, second))

	fight_model.apply(FightRules.get_resolve_delta(fight_model, fight_model.get_next_action()))

	assert_int(fight_model.tick).is_equal(5)


func test_on_a_shared_tick_the_action_chosen_last_resolves_first() -> void:
	var fight_model := _create_fight_model()
	var first := _create_choice(fight_model, fight_model.heroes[0], 4)
	var last := _create_choice(fight_model, fight_model.heroes[1], 4)
	fight_model.apply(FightRules.get_timeline_delta(fight_model, first))
	fight_model.apply(FightRules.get_timeline_delta(fight_model, last))

	assert_array(fight_model.timeline).contains_exactly([last, first])


func test_a_hit_takes_its_damage_off_the_target() -> void:
	var fight_model := _create_fight_model()
	var choice := _create_choice(fight_model, fight_model.heroes[0], 4, 3)
	fight_model.apply(FightRules.get_timeline_delta(fight_model, choice))

	fight_model.apply(FightRules.get_resolve_delta(fight_model, choice))

	assert_int(fight_model.enemies[0].health).is_equal(7)


func test_a_fallen_character_loses_its_pending_action() -> void:
	var fight_model := _create_fight_model()
	var blow := _create_choice(fight_model, fight_model.heroes[0], 2, 10)
	var pending := _create_choice(fight_model, fight_model.enemies[0], 4)
	fight_model.apply(FightRules.get_timeline_delta(fight_model, blow))
	fight_model.apply(FightRules.get_timeline_delta(fight_model, pending))

	fight_model.apply(FightRules.get_resolve_delta(fight_model, blow))

	assert_bool(fight_model.enemies[0].is_fallen()).is_true()
	assert_array(fight_model.timeline).not_contains([pending])


func test_a_fallen_character_loses_all_its_pending_actions() -> void:
	var fight_model := _create_fight_model()
	var blow := _create_choice(fight_model, fight_model.heroes[0], 2, 10)
	var first := _create_choice(fight_model, fight_model.enemies[0], 4)
	var second := _create_choice(fight_model, fight_model.enemies[0], 6)
	for choice in [blow, first, second]:
		fight_model.apply(FightRules.get_timeline_delta(fight_model, choice))

	fight_model.apply(FightRules.get_resolve_delta(fight_model, blow))

	assert_array(fight_model.timeline).is_empty()


func test_an_action_aimed_at_a_fallen_character_is_cancelled() -> void:
	var fight_model := _create_fight_model()
	var blow := _create_choice(fight_model, fight_model.heroes[0], 2, 10)
	var aimed := _create_choice(fight_model, fight_model.heroes[1], 4)
	fight_model.apply(FightRules.get_timeline_delta(fight_model, blow))
	fight_model.apply(FightRules.get_timeline_delta(fight_model, aimed))

	fight_model.apply(FightRules.get_resolve_delta(fight_model, blow))

	assert_array(fight_model.timeline).not_contains([aimed])


func test_a_second_action_leaves_the_first_pending_and_each_resolves_its_own_delay_on() -> void:
	var fight_model := _create_fight_model()
	_advance(fight_model, 2)
	var first := _create_choice(fight_model, fight_model.heroes[0], 6)
	var second := _create_choice(fight_model, fight_model.heroes[0], 3)

	fight_model.apply(FightRules.get_timeline_delta(fight_model, first))
	fight_model.apply(FightRules.get_timeline_delta(fight_model, second))

	assert_array(fight_model.timeline).contains_exactly([second, first])
	assert_int(second.resolve_tick).is_equal(5)
	assert_int(first.resolve_tick).is_equal(8)


func test_a_character_without_ap_has_no_usable_skill() -> void:
	var fight_model := _create_fight_model()
	var hero := _create_character(10, 1)
	fight_model.heroes[0] = hero
	var choice := _create_choice(fight_model, hero, 2)

	fight_model.apply(FightRules.get_timeline_delta(fight_model, choice))

	assert_array(FightRules.get_usable_skills(fight_model, hero)).is_empty()


func test_a_beat_gives_back_ap() -> void:
	var fight_model := _create_fight_model()
	var hero := _create_character(10, 1)
	fight_model.heroes[0] = hero
	var choice := _create_choice(fight_model, hero, 2)
	fight_model.apply(FightRules.get_timeline_delta(fight_model, choice))

	fight_model.apply(FightRules.get_beat_delta(fight_model))

	assert_array(FightRules.get_usable_skills(fight_model, hero)).contains([choice.skill])


func test_a_beat_gives_back_one_ap_not_up_to_the_cap() -> void:
	var fight_model := _create_fight_model()
	var hero := _create_character(10, 3)
	fight_model.heroes[0] = hero
	for spent in 3:
		fight_model.apply(FightRules.get_timeline_delta(fight_model, _create_choice(fight_model, hero, 2)))

	fight_model.apply(FightRules.get_beat_delta(fight_model))

	assert_int(hero.ap).is_equal(FightRules.AP_PER_BEAT)


func test_ap_is_held_up_to_its_cap() -> void:
	var fight_model := _create_fight_model()
	var hero := _create_character(10, 2)
	fight_model.heroes[0] = hero
	var choice := _create_choice(fight_model, hero, 2)
	fight_model.apply(FightRules.get_beat_delta(fight_model))

	fight_model.apply(FightRules.get_timeline_delta(fight_model, choice))
	fight_model.apply(FightRules.get_timeline_delta(fight_model, _create_choice(fight_model, hero, 2)))

	assert_array(FightRules.get_usable_skills(fight_model, hero)).is_empty()


func test_a_skill_costing_more_ap_than_held_is_not_usable() -> void:
	var fight_model := _create_fight_model()
	var hero := _create_character(10, 2)
	fight_model.heroes[0] = hero
	var cheap := _create_choice(fight_model, hero, 2)
	var dear := _create_choice(fight_model, hero, 2)
	dear.skill.ap_cost = 2

	fight_model.apply(FightRules.get_timeline_delta(fight_model, cheap))

	assert_array(FightRules.get_usable_skills(fight_model, hero)).contains_exactly([cheap.skill])


func test_a_skill_spends_its_ap_cost() -> void:
	var fight_model := _create_fight_model()
	var hero := _create_character(10, 2)
	fight_model.heroes[0] = hero
	var dear := _create_choice(fight_model, hero, 2)
	dear.skill.ap_cost = 2

	fight_model.apply(FightRules.get_timeline_delta(fight_model, dear))

	assert_array(FightRules.get_usable_skills(fight_model, hero)).is_empty()


func test_ap_carries_over_to_the_next_fight() -> void:
	var last_fight := _create_fight_model()
	var hero := _create_character(10, 1)
	last_fight.heroes[0] = hero
	last_fight.apply(FightRules.get_timeline_delta(last_fight, _create_choice(last_fight, hero, 2)))

	var fight_model := FightModel.new(last_fight.heroes, last_fight.enemies)

	assert_array(FightRules.get_usable_skills(fight_model, hero)).is_empty()


func test_a_skill_goes_on_cooldown_when_chosen_until_its_nth_beat() -> void:
	var fight_model := _create_fight_model()
	_advance(fight_model, 5)
	var choice := _create_choice(fight_model, fight_model.heroes[0], 2, 1, 2)

	fight_model.apply(FightRules.get_timeline_delta(fight_model, choice))

	assert_array(FightRules.get_usable_skills(fight_model, fight_model.heroes[0])).not_contains([choice.skill])
	fight_model.apply(FightRules.get_beat_delta(fight_model))
	assert_array(FightRules.get_usable_skills(fight_model, fight_model.heroes[0])).not_contains([choice.skill])
	fight_model.apply(FightRules.get_beat_delta(fight_model))
	assert_array(FightRules.get_usable_skills(fight_model, fight_model.heroes[0])).contains([choice.skill])


func test_a_skill_chosen_on_a_beat_does_not_count_that_beat() -> void:
	var fight_model := _create_fight_model()
	fight_model.apply(FightRules.get_beat_delta(fight_model))
	var choice := _create_choice(fight_model, fight_model.heroes[0], 2, 1, 1)

	fight_model.apply(FightRules.get_timeline_delta(fight_model, choice))

	assert_array(FightRules.get_usable_skills(fight_model, fight_model.heroes[0])).not_contains([choice.skill])
	fight_model.apply(FightRules.get_beat_delta(fight_model))
	assert_array(FightRules.get_usable_skills(fight_model, fight_model.heroes[0])).contains([choice.skill])


func test_a_cooldown_carries_over_to_the_next_fight() -> void:
	var last_fight := _create_fight_model()
	var choice := _create_choice(last_fight, last_fight.heroes[0], 2, 1, 2)
	last_fight.apply(FightRules.get_timeline_delta(last_fight, choice))
	last_fight.apply(FightRules.get_beat_delta(last_fight))

	var fight_model := FightModel.new(last_fight.heroes, last_fight.enemies)

	assert_array(FightRules.get_usable_skills(fight_model, fight_model.heroes[0])).not_contains([choice.skill])
	fight_model.apply(FightRules.get_beat_delta(fight_model))
	assert_array(FightRules.get_usable_skills(fight_model, fight_model.heroes[0])).contains([choice.skill])


func test_an_enemy_with_its_only_skill_on_cooldown_chooses_nothing() -> void:
	var fight_model := _create_fight_model()
	var enemy := fight_model.enemies[0]
	var choice := _create_choice(fight_model, enemy, 2, 1, 1)
	fight_model.apply(FightRules.get_timeline_delta(fight_model, choice))
	fight_model.apply(FightRules.get_resolve_delta(fight_model, choice))
	var brain := RandomBrain.new(FightModel.Side.ENEMY, 1)
	fight_model.enemies[1].data.skills = []

	assert_object(await brain.get_next_action(fight_model)).is_null()


func test_an_enemy_spends_all_its_ap() -> void:
	var fight_model := _create_fight_model()
	var enemy := _create_character(10, 2)
	fight_model.enemies = [enemy]
	enemy.data.skills.append(SkillData.new())
	var brain := RandomBrain.new(FightModel.Side.ENEMY, 1)
	var actors: Array[Character] = []
	var choice := await brain.get_next_action(fight_model)
	while choice != null:
		actors.append(choice.actor)
		fight_model.apply(FightRules.get_timeline_delta(fight_model, choice))
		choice = await brain.get_next_action(fight_model)

	assert_array(actors).contains_exactly([enemy, enemy])


func _create_fight_model() -> FightModel:
	var heroes: Array[Character] = [_create_character(10), _create_character(10)]
	var enemies: Array[Character] = [_create_character(10), _create_character(10)]
	return FightModel.new(heroes, enemies)


func _create_character(health: int, max_ap := CharacterData.MAX_AP) -> Character:
	var character_data := CharacterData.new()
	character_data.max_health = health
	character_data.max_ap = max_ap
	return Character.new(character_data)


# A new skill, aimed at the first standing character of the other side.
func _create_choice(fight_model: FightModel, actor: Character, skill_delay: int, damage_amount := 1, skill_cooldown := 0) -> Action:
	var choice := Action.new()
	choice.actor = actor
	choice.skill = SkillData.new()
	choice.skill.delay = skill_delay
	choice.skill.cooldown = skill_cooldown
	actor.data.skills.append(choice.skill)
	var damage := DamageEffect.new()
	damage.amount = damage_amount
	choice.skill.effects = [damage]
	choice.target = FightRules.get_targets(fight_model, actor, choice.skill)[0]
	return choice


func _advance(fight_model: FightModel, ticks: int) -> void:
	var delta := Delta.new()
	delta.ticks = ticks
	fight_model.apply(delta)
