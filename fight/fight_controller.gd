class_name FightController
extends RefCounted
# Plays a fight one delta at a time: a free enemy chooses first; a free hero chooses once nothing is due this tick; otherwise the next action resolves.
# Choices apply at once; a resolve waits for the stage, if any, to land its blow.

signal action_resolved(action: Action)

var fight_model: FightModel

var _hero_brain: Brain
var _enemy_brain: Brain
var _stage: Stage
var _knocked_out_sides: Array[FightModel.Side] = []


# The same seed plays the same fight.
func _init(heroes: Array[Character], enemies: Array[Character], fight_seed: int, fight_stage: Stage = null) -> void:
	fight_model = FightModel.new(heroes, enemies)
	_stage = fight_stage
	_hero_brain = RandomBrain.new(FightModel.Side.HERO, fight_seed)
	_enemy_brain = RandomBrain.new(FightModel.Side.ENEMY, fight_seed + 1)


# For debugging: the side falls between two steps, as if struck down.
func knock_out(side: FightModel.Side) -> void:
	_knocked_out_sides.append(side)


# Returns once one side has fallen.
func play() -> void:
	while not fight_model.is_over():
		if not _knocked_out_sides.is_empty():
			fight_model.apply(_get_knock_out_delta(_knocked_out_sides.pop_front()))
			continue
		var choice := await _enemy_brain.get_next_action(fight_model)
		var next_action := fight_model.get_next_action()
		if choice == null and (next_action == null or next_action.resolve_tick > fight_model.tick):
			choice = await _hero_brain.get_next_action(fight_model)
		if choice != null:
			fight_model.apply(FightRules.get_timeline_delta(fight_model, choice))
		else:
			var delta := FightRules.get_resolve_delta(fight_model, next_action)
			if _stage == null:
				fight_model.apply(delta)
			else:
				await _stage.show_action(next_action, fight_model.apply.bind(delta))
			action_resolved.emit(next_action)


func _get_knock_out_delta(side: FightModel.Side) -> Delta:
	var delta := Delta.new()
	for character in fight_model.get_standing(side):
		FightRules.add_damage(fight_model, delta, character, character.health)
	return delta
