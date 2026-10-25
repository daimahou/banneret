class_name FightController
extends RefCounted
# Plays a fight one delta at a time: a free enemy chooses first; the heroes choose once nothing is due this tick, or when their brain requests a stop; otherwise the fight moves on to the next beat, if it comes first, or the next action resolves.
# Choices apply at once; a beat waits for the stage, if any, to hold on it, and a resolve for it to land its blow. The preview runs ahead of the blow: it lands there as the lunge starts.

signal action_resolved(action: Action)

var fight_model: FightModel
var hero_brain: Brain

var _enemy_brain: Brain
var _stage: Stage


func _init(model: FightModel, enemies_brain: Brain, heroes_brain: Brain = PlayerBrain.new()) -> void:
	fight_model = model
	_enemy_brain = enemies_brain
	hero_brain = heroes_brain


func set_stage(value: Stage) -> void:
	_stage = value


func dispose() -> void:
	hero_brain.dispose()
	_enemy_brain.dispose()


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
		elif FightRules.is_beat_next(fight_model):
			fight_model.apply(FightRules.get_beat_delta(fight_model))
			if _stage != null:
				await _stage.show_beat()
		else:
			var delta := FightRules.get_resolve_delta(fight_model, next_action)
			if _stage == null:
				fight_model.apply(delta)
			else:
				fight_model.preview.sync(fight_model)
				fight_model.preview.apply(delta)
				await _stage.show_action(next_action, fight_model.apply.bind(delta))
			action_resolved.emit(next_action)
