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


func test_an_action_aimed_at_a_fallen_character_is_cancelled_and_its_actor_freed() -> void:
	var fight_model := _create_fight_model()
	var blow := _create_choice(fight_model, fight_model.heroes[0], 2, 10)
	var aimed := _create_choice(fight_model, fight_model.heroes[1], 4)
	fight_model.apply(FightRules.get_timeline_delta(fight_model, blow))
	fight_model.apply(FightRules.get_timeline_delta(fight_model, aimed))

	fight_model.apply(FightRules.get_resolve_delta(fight_model, blow))

	assert_object(fight_model.get_action(fight_model.heroes[1])).is_null()


func test_a_reschedule_drops_the_pending_action_and_resolves_the_new_one_its_delay_on_from_now() -> void:
	var fight_model := _create_fight_model()
	var blow := _create_choice(fight_model, fight_model.enemies[0], 2)
	var pending := _create_choice(fight_model, fight_model.heroes[0], 6)
	fight_model.apply(FightRules.get_timeline_delta(fight_model, blow))
	fight_model.apply(FightRules.get_timeline_delta(fight_model, pending))
	fight_model.apply(FightRules.get_resolve_delta(fight_model, blow))
	var rescheduled := _create_choice(fight_model, fight_model.heroes[0], 3)

	fight_model.apply(FightRules.get_timeline_delta(fight_model, rescheduled))

	assert_array(fight_model.timeline).contains_exactly([rescheduled])
	assert_int(rescheduled.resolve_tick).is_equal(5)


func _create_fight_model() -> FightModel:
	var heroes: Array[Character] = [_create_character(10), _create_character(10)]
	var enemies: Array[Character] = [_create_character(10), _create_character(10)]
	return FightModel.new(heroes, enemies)


func _create_character(health: int) -> Character:
	var character_data := CharacterData.new()
	character_data.max_health = health
	return Character.new(character_data)


# A new skill, aimed at the first standing character of the other side.
func _create_choice(fight_model: FightModel, actor: Character, skill_delay: int, damage_amount := 1) -> Action:
	var choice := Action.new()
	choice.actor = actor
	choice.skill = SkillData.new()
	choice.skill.delay = skill_delay
	var damage := DamageEffect.new()
	damage.amount = damage_amount
	choice.skill.effects = [damage]
	choice.target = FightRules.get_targets(fight_model, actor, choice.skill)[0]
	return choice
