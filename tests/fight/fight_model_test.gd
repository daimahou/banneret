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
