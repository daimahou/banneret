extends GdUnitTestSuite


func test_a_delta_signals_changed_once_every_change_in_it_is_applied() -> void:
	var hero := Character.new(CharacterData.new())
	var heroes: Array[Character] = [hero]
	var enemies: Array[Character] = []
	var fight_model := FightModel.new(heroes, enemies)
	var skill := SkillData.new()
	var delta := Delta.new()
	delta.ticks = 4
	delta.add_cooldown(hero, skill, 3)
	var seen_cooldowns: Array[int] = []
	fight_model.changed.connect(func() -> void: seen_cooldowns.append(hero.skill_cooldowns.get(skill, 0)))

	fight_model.apply(delta)

	assert_array(seen_cooldowns).is_equal([3])


func test_a_delta_applied_to_the_preview_leaves_the_fight_untouched() -> void:
	var fight_model := _create_fight_model()
	var hero := fight_model.heroes[0]
	var action := _schedule(fight_model, hero, fight_model.enemies[0])
	var delta := FightRules.get_resolve_delta(fight_model, action)
	delta.add_health(hero, -3)

	fight_model.preview.apply(delta)

	assert_int(hero.health).is_equal(10)
	assert_int(fight_model.tick).is_equal(0)
	assert_array(fight_model.timeline).contains_exactly([action])
	assert_int(fight_model.preview.get_character(hero.id).health).is_equal(7)
	assert_int(fight_model.preview.tick).is_equal(2)
	assert_array(fight_model.preview.timeline).is_empty()


func test_a_sync_brings_the_preview_level_with_the_fight() -> void:
	var fight_model := _create_fight_model()
	var hero := fight_model.heroes[0]
	var action := _schedule(fight_model, hero, fight_model.enemies[0])
	fight_model.preview.apply(FightRules.get_resolve_delta(fight_model, action))

	fight_model.preview.sync(fight_model)

	assert_int(fight_model.preview.tick).is_equal(0)
	assert_int(fight_model.preview.get_character(fight_model.enemies[0].id).health).is_equal(10)
	assert_int(fight_model.preview.get_action(action.id).resolve_tick).is_equal(2)
	assert_array(fight_model.preview.history).is_empty()


func test_the_preview_follows_every_delta_applied_to_the_fight() -> void:
	var fight_model := _create_fight_model()
	var enemy := fight_model.enemies[0]
	var preview := fight_model.preview
	var action := _schedule(fight_model, fight_model.heroes[0], enemy)

	fight_model.apply(FightRules.get_resolve_delta(fight_model, action))

	assert_int(preview.get_character(enemy.id).health).is_equal(enemy.health)
	assert_int(preview.tick).is_equal(2)
	assert_array(preview.timeline).is_empty()


func _create_fight_model() -> FightModel:
	var heroes: Array[Character] = [_create_character()]
	var enemies: Array[Character] = [_create_character()]
	return FightModel.new(heroes, enemies)


func _create_character() -> Character:
	var character_data := CharacterData.new()
	character_data.max_health = 10
	return Character.new(character_data)


# A 2-tick skill dealing 4, put on the timeline; returns the action the fight model holds for it.
func _schedule(fight_model: FightModel, actor: Character, target: Character) -> Action:
	var choice := Action.new()
	choice.actor = actor
	choice.target = target
	choice.skill = SkillData.new()
	choice.skill.delay = 2
	var damage := DamageEffect.new()
	damage.amount = 4
	choice.skill.effects = [damage]
	var added: Array[Action] = []
	fight_model.action_added.connect(added.append, CONNECT_ONE_SHOT)
	fight_model.apply(FightRules.get_timeline_delta(fight_model, choice))
	return added[0]
