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
	var seen_ready_beats: Array[int] = []
	fight_model.changed.connect(func() -> void: seen_ready_beats.append(hero.skill_cooldowns.get(skill, 0)))

	fight_model.apply(delta)

	assert_array(seen_ready_beats).is_equal([3])


func test_a_new_fight_starts_with_every_skill_ready() -> void:
	var skill := SkillData.new()
	skill.cooldown = 3
	var character_data := CharacterData.new()
	character_data.skills = [skill]
	var hero := Character.new(character_data)
	var heroes: Array[Character] = [hero]
	var enemies: Array[Character] = []
	var last_fight := FightModel.new(heroes, enemies)
	var delta := Delta.new()
	delta.ticks = 20
	delta.add_cooldown(hero, skill, 7)
	last_fight.apply(delta)

	var fight_model := FightModel.new(heroes, enemies)

	assert_array(FightRules.get_usable_skills(fight_model, hero)).contains([skill])
