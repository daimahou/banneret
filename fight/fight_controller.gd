class_name FightController
extends RefCounted
# Plays a fight one delta at a time: a free enemy chooses first; the heroes choose once nothing is due this tick, or when their brain requests a stop; otherwise the next action resolves.
# Choices apply at once; a resolve waits for the stage, if any, to land its blow.

signal action_resolved(action: Action)

var fight_model: FightModel
var hero_brain: Brain

var _enemy_brain: Brain
var _stage: Stage


# The enemies choose from the seed; so do the heroes, given a random brain on the same seed.
func _init(heroes: Array[Character], enemies: Array[Character], fight_seed: int, ai_player: Brain = PlayerBrain.new(), fight_stage: Stage = null) -> void:
	fight_model = FightModel.new(heroes, enemies)
	_stage = fight_stage
	hero_brain = ai_player
	_enemy_brain = RandomBrain.new(FightModel.Side.ENEMY, fight_seed + 1)


# Returns once one side has fallen.
func play() -> void:
	while not fight_model.is_over():
		var choice := await _enemy_brain.get_next_action(fight_model)
		var next_action := fight_model.get_next_action()
		var is_nothing_due := next_action == null or next_action.resolve_tick > fight_model.tick
		if choice == null and (is_nothing_due or hero_brain.is_stop_requested()):
			choice = await hero_brain.get_next_action(fight_model)
			# The fight can end while the heroes choose, from outside it.
			if fight_model.is_over():
				return
		if choice != null:
			fight_model.apply(FightRules.get_timeline_delta(fight_model, choice))
		else:
			var delta := FightRules.get_resolve_delta(fight_model, next_action)
			if _stage == null:
				fight_model.apply(delta)
			else:
				await _stage.show_action(next_action, fight_model.apply.bind(delta))
			action_resolved.emit(next_action)
