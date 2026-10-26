extends GdUnitTestSuite


func test_health_the_preview_takes_shows_worse() -> void:
	var fight_model := _create_fight_model()
	var hero := fight_model.heroes[0]
	var enemy := fight_model.enemies[0]
	var preview_model := _run(fight_model, _create_choice(hero, enemy, 2, 3))

	assert_int(PreviewPresenter.get_health_style(preview_model, enemy)).is_equal(PreviewPulse.Style.WORSE)
	assert_int(PreviewPresenter.get_health_style(preview_model, hero)).is_equal(PreviewPulse.Style.NONE)


func test_a_pip_spent_by_landing_shows_lost() -> void:
	var fight_model := _create_fight_model()
	var hero := fight_model.heroes[0]
	var preview_model := _run(fight_model, _create_choice(hero, fight_model.enemies[0], 2, 3))

	var held := Nameplate.Pip.HELD
	var states := PreviewPresenter.get_pip_states(preview_model, hero)

	assert_array(states).contains_exactly([held, held, held, held, Nameplate.Pip.LOST])


func test_a_pip_spent_and_got_back_on_the_way_shows_gained() -> void:
	var fight_model := _create_fight_model()
	var hero := fight_model.heroes[0]
	hero.ap = 3
	var preview_model := _run(fight_model, _create_choice(hero, fight_model.enemies[0], 6, 3))

	var held := Nameplate.Pip.HELD
	var empty := Nameplate.Pip.EMPTY
	var states := PreviewPresenter.get_pip_states(preview_model, hero)

	assert_array(states).contains_exactly([held, held, Nameplate.Pip.GAINED, empty, empty])


func test_a_cooldown_the_preview_starts_shows_worse() -> void:
	var fight_model := _create_fight_model()
	var hero := fight_model.heroes[0]
	var choice := _create_choice(hero, fight_model.enemies[0], 2, 3)
	choice.skill.cooldown = 2
	var preview_model := _run(fight_model, choice)

	var style := PreviewPresenter.get_cooldown_style(preview_model, hero, choice.skill)

	assert_int(style).is_equal(PreviewPulse.Style.WORSE)


func test_a_cooldown_a_beat_on_the_way_shortens_shows_better() -> void:
	var fight_model := _create_fight_model()
	var hero := fight_model.heroes[0]
	var resting := SkillData.new()
	hero.skill_cooldowns[resting] = 1
	var preview_model := _run(fight_model, _create_choice(hero, fight_model.enemies[0], 6, 3))

	var style := PreviewPresenter.get_cooldown_style(preview_model, hero, resting)

	assert_int(style).is_equal(PreviewPulse.Style.BETTER)


func test_a_shown_choice_hangs_as_a_ghost_where_it_would_resolve() -> void:
	var fight_model := _create_fight_model()
	var hero := fight_model.heroes[0]
	var enemy := fight_model.enemies[0]
	var pending := _schedule(fight_model, _create_choice(enemy, hero, 2, 1))
	var choice := _create_choice(hero, enemy, 2, 3)
	var preview_model := _run(fight_model, choice)

	var entries := PreviewPresenter.get_timeline_entries(fight_model, preview_model, choice)

	var expected := ["knot", "knot", "choice ghost NORMAL", "pending NORMAL", "knot", "knot"]
	assert_array(_describe(entries, {choice: "choice", pending: "pending"})).contains_exactly(expected)


func test_the_preview_fades_what_it_resolves_and_crosses_what_it_cancels_but_the_shown_action() -> void:
	var fight_model := _create_fight_model()
	var blow := _schedule(fight_model, _create_choice(fight_model.heroes[0], fight_model.enemies[0], 2, 10))
	var doomed := _schedule(fight_model, _create_choice(fight_model.enemies[0], fight_model.heroes[1], 3, 1))
	var shown := _schedule(fight_model, _create_choice(fight_model.heroes[1], fight_model.enemies[1], 4, 1))
	var preview_model := _run(fight_model, shown)

	var entries := PreviewPresenter.get_timeline_entries(fight_model, preview_model, shown)

	var expected := ["knot", "knot", "blow FADED", "knot", "doomed CROSSED", "knot", "shown NORMAL"]
	assert_array(_describe(entries, {blow: "blow", doomed: "doomed", shown: "shown"})).contains_exactly(expected)


func test_an_action_the_preview_moves_hangs_a_moved_ghost_where_it_would_land() -> void:
	var fight_model := _create_fight_model()
	var enemy := fight_model.enemies[0]
	var bash := _create_choice(fight_model.heroes[0], enemy, 2, 1)
	_add_stagger(bash, 2)
	bash = _schedule(fight_model, bash)
	var pending := _schedule(fight_model, _create_choice(enemy, fight_model.heroes[0], 3, 1))
	var preview_model := _run(fight_model, bash)

	var entries := PreviewPresenter.get_timeline_entries(fight_model, preview_model, bash)

	var expected := ["knot", "knot", "bash NORMAL", "knot", "pending NORMAL", "knot", "knot"]
	expected.append_array(["pending ghost MOVED", "knot", "knot", "knot"])
	assert_array(_describe(entries, {bash: "bash", pending: "pending"})).contains_exactly(expected)
	var ids := entries.map(func(entry: TimelineEntry) -> String: return entry.id)
	assert_array(ids).contains_exactly_in_any_order(_get_unique(ids))


func test_an_action_moved_twice_hangs_one_moved_ghost_where_it_last_lands() -> void:
	var fight_model := _create_fight_model()
	var enemy := fight_model.enemies[0]
	var first := _create_choice(fight_model.heroes[0], enemy, 2, 1)
	_add_stagger(first, 2)
	first = _schedule(fight_model, first)
	var second := _create_choice(fight_model.heroes[1], enemy, 3, 1)
	_add_stagger(second, 2)
	second = _schedule(fight_model, second)
	var pending := _schedule(fight_model, _create_choice(enemy, fight_model.heroes[0], 4, 1))
	var preview_model := _run(fight_model, second)

	var entries := PreviewPresenter.get_timeline_entries(fight_model, preview_model, second)

	var expected := ["knot", "knot", "first FADED", "knot", "second NORMAL", "knot", "pending NORMAL"]
	expected.append_array(["knot", "knot", "knot", "knot", "pending ghost MOVED"])
	assert_array(_describe(entries, {first: "first", second: "second", pending: "pending"})).contains_exactly(expected)


func test_an_action_the_preview_moves_then_cancels_hangs_a_crossed_moved_ghost() -> void:
	var fight_model := _create_fight_model()
	var enemy := fight_model.enemies[0]
	var bash := _create_choice(fight_model.heroes[0], enemy, 2, 1)
	_add_stagger(bash, 2)
	bash = _schedule(fight_model, bash)
	var pending := _schedule(fight_model, _create_choice(enemy, fight_model.heroes[0], 3, 1))
	var shown := _schedule(fight_model, _create_choice(fight_model.heroes[1], enemy, 4, 10))
	var preview_model := _run(fight_model, shown)

	var entries := PreviewPresenter.get_timeline_entries(fight_model, preview_model, shown)

	var expected := ["knot", "knot", "bash FADED", "knot", "pending CROSSED", "knot", "shown NORMAL", "knot"]
	expected.append_array(["pending ghost CROSSED", "knot", "knot", "knot"])
	assert_array(_describe(entries, {bash: "bash", pending: "pending", shown: "shown"})).contains_exactly(expected)


func test_a_lethal_stagger_hangs_the_target_s_actions_moved_and_crossed() -> void:
	var fight_model := _create_fight_model()
	var enemy := fight_model.enemies[0]
	var bash := _create_choice(fight_model.heroes[0], enemy, 2, 10)
	_add_stagger(bash, 2)
	bash = _schedule(fight_model, bash)
	var doomed := _schedule(fight_model, _create_choice(enemy, fight_model.heroes[0], 3, 1))
	var preview_model := _run(fight_model, bash)

	var entries := PreviewPresenter.get_timeline_entries(fight_model, preview_model, bash)

	var expected := ["knot", "knot", "bash NORMAL", "knot", "doomed CROSSED", "knot", "knot"]
	expected.append_array(["doomed ghost CROSSED", "knot", "knot", "knot"])
	assert_array(_describe(entries, {bash: "bash", doomed: "doomed"})).contains_exactly(expected)


func _describe(entries: Array[TimelineEntry], names: Dictionary[Action, String]) -> Array[String]:
	var described: Array[String] = []
	for entry in entries:
		if entry.is_knot():
			described.append("knot")
		else:
			var ghost := " ghost" if entry.is_ghost else ""
			described.append("%s%s %s" % [names[entry.action], ghost, TimelineEntry.Style.find_key(entry.style)])
	return described


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


func _add_stagger(choice: Action, ticks: int) -> void:
	var stagger := StaggerEffect.new()
	stagger.ticks = ticks
	choice.skill.effects.append(stagger)


func _get_unique(values: Array) -> Array:
	var unique := []
	for value in values:
		if value not in unique:
			unique.append(value)
	return unique


func _schedule(fight_model: FightModel, choice: Action) -> Action:
	var added: Array[Action] = []
	fight_model.action_added.connect(added.append, CONNECT_ONE_SHOT)
	fight_model.apply(FightRules.get_timeline_delta(fight_model, choice))
	return added[0]


func _run(fight_model: FightModel, shown: Action) -> FightModel:
	var preview_model := FightModel.new([], [])
	Simulation.run(preview_model, fight_model, shown)
	return preview_model
