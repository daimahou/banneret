extends GdUnitTestSuite


func test_a_play_out_stops_once_the_action_lands() -> void:
	var fight_model := _create_fight_model()
	var preview_model := FightModel.new([], [])
	var hero := fight_model.heroes[0]
	var enemy := fight_model.enemies[0]
	var shown := _schedule(fight_model, hero, enemy, 6, 3)
	var earlier := _schedule(fight_model, enemy, hero, 2, 1)
	var later := _schedule(fight_model, enemy, hero, 9, 1)

	Simulation.run(preview_model, fight_model, shown)

	assert_int(preview_model.tick).is_equal(6)
	assert_int(preview_model.get_character(enemy.id).health).is_equal(7)
	assert_int(preview_model.get_character(hero.id).health).is_equal(9)
	assert_bool(preview_model.has_resolved(earlier.id)).is_true()
	assert_bool(preview_model.has_resolved(shown.id)).is_true()
	assert_object(preview_model.get_action(later.id)).is_not_null()


func test_a_play_out_leaves_the_fight_untouched() -> void:
	var fight_model := _create_fight_model()
	var preview_model := FightModel.new([], [])
	var shown := _schedule(fight_model, fight_model.heroes[0], fight_model.enemies[0], 6, 3)

	Simulation.run(preview_model, fight_model, shown)

	assert_int(fight_model.tick).is_equal(0)
	assert_int(fight_model.enemies[0].health).is_equal(10)
	assert_array(fight_model.timeline).contains_exactly([shown])


func test_a_play_out_s_history_holds_the_cancels_on_the_way() -> void:
	var fight_model := _create_fight_model()
	var preview_model := FightModel.new([], [])
	var blow := _schedule(fight_model, fight_model.heroes[0], fight_model.enemies[0], 2, 10)
	var doomed := _schedule(fight_model, fight_model.enemies[0], fight_model.heroes[1], 4, 1)
	var shown := _schedule(fight_model, fight_model.heroes[1], fight_model.enemies[1], 6, 1)

	Simulation.run(preview_model, fight_model, shown)

	assert_bool(preview_model.has_resolved(blow.id)).is_true()
	assert_bool(preview_model.has_cancelled(doomed.id)).is_true()
	assert_bool(preview_model.has_resolved(shown.id)).is_true()


func test_a_play_out_stops_when_the_action_is_cancelled() -> void:
	var fight_model := _create_fight_model()
	var preview_model := FightModel.new([], [])
	var blow := _schedule(fight_model, fight_model.heroes[0], fight_model.enemies[0], 2, 10)
	var shown := _schedule(fight_model, fight_model.heroes[1], fight_model.enemies[0], 6, 1)
	var later := _schedule(fight_model, fight_model.enemies[1], fight_model.heroes[1], 9, 1)

	Simulation.run(preview_model, fight_model, shown)

	assert_bool(preview_model.has_resolved(blow.id)).is_true()
	assert_bool(preview_model.has_cancelled(shown.id)).is_true()
	assert_int(preview_model.tick).is_equal(2)
	assert_object(preview_model.get_action(later.id)).is_not_null()


func test_a_choice_plays_out_under_the_id_it_will_take() -> void:
	var fight_model := _create_fight_model()
	var preview_model := FightModel.new([], [])
	var choice := _create_choice(fight_model.heroes[0], fight_model.enemies[0], 2, 3)

	Simulation.run(preview_model, fight_model, choice)

	assert_bool(preview_model.has_resolved(choice.id)).is_true()
	assert_int(preview_model.get_character(fight_model.enemies[0].id).health).is_equal(7)
	assert_array(fight_model.timeline).is_empty()
	var added := _schedule(fight_model, fight_model.heroes[0], fight_model.enemies[0], 2, 3)
	assert_int(added.id).is_equal(choice.id)


func test_a_choice_without_a_target_is_only_chosen() -> void:
	var fight_model := _create_fight_model()
	var preview_model := FightModel.new([], [])
	var hero := fight_model.heroes[0]
	var choice := _create_choice(hero, null, 2, 3)

	Simulation.run(preview_model, fight_model, choice)

	assert_int(preview_model.tick).is_equal(0)
	assert_int(preview_model.get_character(hero.id).ap).is_equal(hero.ap - 1)
	assert_object(preview_model.get_action(choice.id)).is_not_null()


func _create_fight_model() -> FightModel:
	var heroes: Array[Character] = [_create_character(), _create_character()]
	var enemies: Array[Character] = [_create_character(), _create_character()]
	return FightModel.new(heroes, enemies)


func _create_character() -> Character:
	var character_data := CharacterData.new()
	character_data.max_health = 10
	character_data.max_ap = CharacterData.MAX_AP
	return Character.new(character_data)


func _create_choice(actor: Character, target: Character, skill_delay: int, damage_amount: int) -> Action:
	var choice := Action.new()
	choice.actor = actor
	choice.target = target
	choice.skill = SkillData.new()
	choice.skill.delay = skill_delay
	var damage := DamageEffect.new()
	damage.amount = damage_amount
	choice.skill.effects = [damage]
	return choice


func _schedule(fight_model: FightModel, actor: Character, target: Character, skill_delay: int, damage: int) -> Action:
	var choice := _create_choice(actor, target, skill_delay, damage)
	var added: Array[Action] = []
	fight_model.action_added.connect(added.append, CONNECT_ONE_SHOT)
	fight_model.apply(FightRules.get_timeline_delta(fight_model, choice))
	return added[0]
