class_name Simulation
# The fight played out on a preview of it, no brains, until a given action lands.


# The action: a pending one, or a choice not yet made, which takes the id it would be given. A choice without a target is only chosen: it cannot resolve.
static func run(preview: FightModel, fight_model: FightModel, action: Action) -> void:
	preview.sync(fight_model)
	if action not in fight_model.timeline:
		action.id = preview.next_action_id
		preview.apply(FightRules.get_timeline_delta(preview, action))
		if action.target == null:
			return
	while not preview.is_over() and preview.get_action(action.id) != null:
		if FightRules.is_beat_next(preview):
			preview.apply(FightRules.get_beat_delta(preview))
		else:
			preview.apply(FightRules.get_resolve_delta(preview, preview.get_next_action()))
