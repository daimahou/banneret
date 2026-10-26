extends GdUnitTestSuite


func test_the_rope_runs_to_the_beat_after_the_last_action_one_due_now_first() -> void:
	var due_now := _create_action(1)
	var later := _create_action(3)

	var entries := TimelineEntry.create_entries(1, TimelineEntry.create_medallions([due_now, later]))

	var expected := ["action 0", "knot 2", "knot 3", "action 1", "beat 4"]
	assert_array(_describe(entries, [due_now, later])).contains_exactly(expected)


func test_actions_sharing_a_tick_hang_in_the_order_given() -> void:
	var first := _create_action(2)
	var second := _create_action(2)

	var entries := TimelineEntry.create_entries(0, TimelineEntry.create_medallions([second, first]))

	var expected := ["knot 1", "knot 2", "action 1", "action 0", "knot 3", "beat 4"]
	assert_array(_describe(entries, [first, second])).contains_exactly(expected)


func _create_action(resolve_tick: int) -> Action:
	var action := Action.new()
	action.actor = Character.new(CharacterData.new())
	action.resolve_tick = resolve_tick
	return action


# Each action by its index in `actions`.
func _describe(entries: Array[TimelineEntry], actions: Array[Action]) -> Array[String]:
	var described: Array[String] = []
	for entry in entries:
		if entry.is_knot():
			described.append("%s %d" % ["beat" if entry.is_beat else "knot", entry.tick])
		else:
			described.append("action %d" % actions.find(entry.action))
	return described
