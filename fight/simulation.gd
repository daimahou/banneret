class_name Simulation
# The fight played out on a preview of it, no brains, until a given action lands.


# `action` is a pending action, or a choice not yet made, which takes the id it would be given. A choice without a target cannot resolve, so the preview stops once it is chosen.
static func run(preview_model: FightModel, fight_model: FightModel, action: Action) -> void:
	preview_model.sync(fight_model)
	if action not in fight_model.timeline:
		action.id = preview_model.next_action_id
		preview_model.apply(FightRules.get_timeline_delta(preview_model, action))
		if action.target == null:
			return
	while not preview_model.is_over() and preview_model.get_action(action.id) != null:
		if FightRules.is_beat_next(preview_model):
			preview_model.apply(FightRules.get_beat_delta(preview_model))
		else:
			preview_model.apply(FightRules.get_resolve_delta(preview_model, preview_model.get_next_action()))
