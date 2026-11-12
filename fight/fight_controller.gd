class_name FightController
extends RefCounted
# Plays a fight one delta at a time: it asks the brains for choices and the rules for deltas, and waits on the stage, if any, to show each beat and blow.

signal action_resolved(action: Action)
signal _suspend_settled(is_suspended: bool)
signal _resumed

var fight_model: FightModel
var hero_brain: Brain

var _enemy_brain: Brain
var _stage: Stage
var _is_suspend_requested := false
var _is_suspended := false


func _init(model: FightModel, enemies_brain: Brain, heroes_brain: Brain = PlayerBrain.new()) -> void:
	fight_model = model
	_enemy_brain = enemies_brain
	hero_brain = heroes_brain


func set_stage(value: Stage) -> void:
	_stage = value


func dispose() -> void:
	hero_brain.dispose()
	_enemy_brain.dispose()


func is_suspended() -> bool:
	return _is_suspended


# False when a suspend is already requested, or when the fight ends first.
func suspend() -> bool:
	if _is_suspend_requested or fight_model.is_over():
		return false
	_is_suspend_requested = true
	if not hero_brain.is_waiting() and not await _suspend_settled:
		return false
	_is_suspended = true
	hero_brain.set_suspended(true)
	return true


func resume() -> void:
	if not _is_suspended:
		return
	_is_suspended = false
	_is_suspend_requested = false
	hero_brain.set_suspended(false)
	_resumed.emit()


func play() -> void:
	await _play_until_over()
	if _is_suspend_requested and not _is_suspended:
		_is_suspend_requested = false
		_suspend_settled.emit(false)


func _play_until_over() -> void:
	while not fight_model.is_over():
		await _hold_if_suspend_requested()
		var choice := await _enemy_brain.get_next_action(fight_model)
		var next_action := fight_model.get_next_action()
		var is_nothing_due := next_action == null or next_action.resolve_tick > fight_model.tick
		if choice == null and (is_nothing_due or hero_brain.is_stop_requested()):
			await _hold_if_suspend_requested()
			choice = await hero_brain.get_next_action(fight_model)
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
				_stage.preview_model.sync(fight_model)
				_stage.preview_model.apply(delta)
				await _stage.show_action(next_action, fight_model.apply.bind(delta))
			action_resolved.emit(next_action)


func _hold_if_suspend_requested() -> void:
	if not _is_suspend_requested:
		return
	_suspend_settled.emit(true)
	await _resumed
