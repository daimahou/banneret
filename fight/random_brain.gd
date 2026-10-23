class_name RandomBrain
extends Brain
# Picks at random among the first free character's choices, from a seeded generator, so a fight it plays can be played again.

var _rng := RandomNumberGenerator.new()


func _init(brain_side: FightModel.Side, brain_seed: int) -> void:
	side = brain_side
	_rng.seed = brain_seed


func get_next_action(fight_model: FightModel) -> Action:
	for character in fight_model.get_standing(side):
		if fight_model.get_action(character) != null:
			continue
		var choices := FightRules.get_choices(fight_model, character)
		if not choices.is_empty():
			return choices[_rng.randi_range(0, choices.size() - 1)]
	return null
