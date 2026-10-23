extends GdUnitTestSuite


func test_a_choice_resolves_its_skills_delay_on() -> void:
	var fight_model := _create_fight_model()
	fight_model.apply(FightRules.get_timeline_delta(_create_choice(fight_model, fight_model.heroes[0], 3)))

	var delta := FightRules.get_resolve_delta(fight_model, fight_model.get_next_action())
	fight_model.apply(delta)

	assert_int(fight_model.tick).is_equal(3)


func test_on_a_shared_tick_the_action_chosen_last_resolves_first() -> void:
	var fight_model := _create_fight_model()
	var first := _create_choice(fight_model, fight_model.heroes[0], 4)
	var last := _create_choice(fight_model, fight_model.heroes[1], 4)
	fight_model.apply(FightRules.get_timeline_delta(first))
	fight_model.apply(FightRules.get_timeline_delta(last))

	assert_array(fight_model.timeline).contains_exactly([last, first])


func test_a_hit_takes_its_damage_off_the_target() -> void:
	var fight_model := _create_fight_model()
	var choice := _create_choice(fight_model, fight_model.heroes[0], 4, 3)
	fight_model.apply(FightRules.get_timeline_delta(choice))

	fight_model.apply(FightRules.get_resolve_delta(fight_model, choice))

	assert_int(fight_model.enemies[0].health).is_equal(7)


func test_a_fallen_character_loses_its_pending_action() -> void:
	var fight_model := _create_fight_model()
	var blow := _create_choice(fight_model, fight_model.heroes[0], 2, 10)
	var pending := _create_choice(fight_model, fight_model.enemies[0], 4)
	fight_model.apply(FightRules.get_timeline_delta(blow))
	fight_model.apply(FightRules.get_timeline_delta(pending))

	fight_model.apply(FightRules.get_resolve_delta(fight_model, blow))

	assert_bool(fight_model.enemies[0].is_fallen()).is_true()
	assert_array(fight_model.timeline).not_contains([pending])


func test_an_action_aimed_at_a_fallen_character_is_cancelled_and_its_actor_freed() -> void:
	var fight_model := _create_fight_model()
	var blow := _create_choice(fight_model, fight_model.heroes[0], 2, 10)
	var aimed := _create_choice(fight_model, fight_model.heroes[1], 4)
	fight_model.apply(FightRules.get_timeline_delta(blow))
	fight_model.apply(FightRules.get_timeline_delta(aimed))

	fight_model.apply(FightRules.get_resolve_delta(fight_model, blow))

	assert_object(fight_model.get_action(fight_model.heroes[1])).is_null()


func _create_fight_model() -> FightModel:
	var heroes: Array[Character] = [_create_character(10), _create_character(10)]
	var enemies: Array[Character] = [_create_character(10), _create_character(10)]
	return FightModel.new(heroes, enemies)


func _create_character(health: int) -> Character:
	var character_data := CharacterData.new()
	character_data.max_health = health
	return Character.new(character_data)


# Gives the actor one skill, and chooses it on the first enemy or hero.
func _create_choice(fight_model: FightModel, actor: Character, skill_delay: int, skill_damage := 1) -> Action:
	var skill := SkillData.new()
	skill.delay = skill_delay
	skill.damage = skill_damage
	actor.data.skills = [skill]
	return FightRules.get_choices(fight_model, actor)[0]
