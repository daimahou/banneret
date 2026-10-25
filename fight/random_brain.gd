class_name RandomBrain
extends Brain
# Picks a random usable skill for the first character that can act, then a random target for it, from a seeded generator, so a fight it plays can be played again. Asked again, it goes on until the side's AP is spent.

var _rng := RandomNumberGenerator.new()


func _init(brain_side: FightModel.Side, brain_seed: int) -> void:
	side = brain_side
	_rng.seed = brain_seed


func get_next_action(fight_model: FightModel) -> Action:
	for character in fight_model.get_standing(side):
		var skills := FightRules.get_usable_skills(fight_model, character)
		if skills.is_empty():
			continue
		var action := Action.new()
		action.actor = character
		action.skill = skills[_rng.randi_range(0, skills.size() - 1)]
		var targets := FightRules.get_targets(fight_model, character, action.skill)
		action.target = targets[_rng.randi_range(0, targets.size() - 1)]
		return action
	return null
