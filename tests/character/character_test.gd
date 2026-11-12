extends GdUnitTestSuite


func test_an_upgraded_active_changes_later_actions_only_and_keeps_its_cooldown() -> void:
	var character_data := _create_character_data()
	var hero := Character.new(character_data)
	var other := Character.new(character_data)
	var scheduled := Action.new()
	scheduled.skill = hero.skills[0]
	var scheduled_effects := scheduled.skill.effects.duplicate()
	hero.skill_cooldowns[hero.skills[0]] = 2

	hero.build.actives[0].talents.append(character_data.skills[0].upgrades[0].talents[0])
	hero.update_skills()

	assert_object(hero.skills[0]).is_not_same(scheduled.skill)
	assert_array(scheduled.skill.effects).contains_exactly(scheduled_effects)
	assert_object(other.skills[0]).is_same(character_data.skills[0])
	assert_int(FightRules.get_cooldown_beats(hero, hero.skills[0])).is_equal(2)


func test_a_passive_changes_every_active_of_its_hero_without_touching_the_definitions() -> void:
	var character_data := _create_character_data()
	var hero := Character.new(character_data)
	var passive := PassiveData.new()
	passive.mod = _create_mod()
	var definition_effects := character_data.skills[0].effects.duplicate()

	hero.build.learn(passive)
	hero.update_skills()

	assert_object(hero.skills[0]).is_not_same(character_data.skills[0])
	assert_array(character_data.skills[0].effects).contains_exactly(definition_effects)


func test_choosing_a_class_keeps_the_talents_chosen_before() -> void:
	var character_data := _create_character_data()
	var hero := Character.new(character_data)
	var earlier := character_data.skills[0].upgrades[0].talents[0]
	hero.build.actives[0].talents.append(earlier)
	var class_talent := Talent.new()
	class_talent.granted_class = ClassData.new()

	hero.build.class_skill.talents.append(class_talent)
	hero.update_skills()

	assert_object(hero.build.get_class_data()).is_same(class_talent.granted_class)
	assert_array(hero.build.actives[0].talents).contains_exactly([earlier])


func _create_character_data() -> CharacterData:
	var damage := DamageEffect.new()
	damage.amount = 3
	var skill := SkillData.new()
	skill.delay = 4
	skill.effects = [damage]
	var talent := Talent.new()
	talent.mod = _create_mod()
	var upgrade := Upgrade.new()
	upgrade.talents = [talent]
	skill.upgrades = [upgrade]
	var character_data := CharacterData.new()
	character_data.max_health = 10
	character_data.starting_class = ClassData.new()
	character_data.starting_class.upgrades = [Upgrade.new()]
	character_data.skills = [skill]
	return character_data


func _create_mod() -> SkillMod:
	var mod := SkillMod.new()
	mod.damage_change = 1
	return mod
