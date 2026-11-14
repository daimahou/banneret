class_name FightController
extends RefCounted
# Plays a fight one delta at a time: it asks the brains for choices and the rules for deltas, and waits on the stage, if any, to show each beat and blow.

signal action_resolved(action: Action)
signal _resumed
signal _pause_settled(is_paused: bool)

var fight_model: FightModel
var hero_brain: Brain

var _enemy_brain: Brain
var _stage: Stage
var _is_pause_requested := false
var _is_paused := false


func _init(model: FightModel, enemies_brain: Brain, heroes_brain: Brain = PlayerBrain.new()) -> void:
	fight_model = model
	_enemy_brain = enemies_brain
	hero_brain = heroes_brain


func set_stage(value: Stage) -> void:
	_stage = value


func dispose() -> void:
	hero_brain.dispose()
	_enemy_brain.dispose()


# A pause waits for a safe boundary: the end of the action being shown, or none while the heroes' brain waits.
# False when the fight ends first. While paused, the fight stands still and takes no input.
func pause() -> bool:
	if hero_brain.is_waiting():
		_hold()
		return true
	_is_pause_requested = true
	return await _pause_settled


func resume() -> void:
	_set_input_enabled(true)
	_is_paused = false
	fight_model.notify_characters_changed()
	_resumed.emit()


func is_pause_requested() -> bool:
	return _is_pause_requested


func is_paused() -> bool:
	return _is_paused


func play() -> void:
	while not fight_model.is_over():
		if _is_pause_requested:
			_is_pause_requested = false
			_hold()
			_pause_settled.emit(true)
			while _is_paused:
				await _resumed
		var choice := await _enemy_brain.get_next_action(fight_model)
		var next_action := fight_model.get_next_action()
		var is_nothing_due := next_action == null or next_action.resolve_tick > fight_model.tick
		if choice == null and (is_nothing_due or hero_brain.is_stop_requested()):
			choice = await hero_brain.get_next_action(fight_model)
			if fight_model.is_over():
				break
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
	if _is_pause_requested:
		_is_pause_requested = false
		_pause_settled.emit(false)


func _hold() -> void:
	_is_paused = true
	_set_input_enabled(false)


func _set_input_enabled(is_enabled: bool) -> void:
	var player_brain := hero_brain as PlayerBrain
	if player_brain != null and player_brain.input != null:
		player_brain.input.process_mode = Node.PROCESS_MODE_INHERIT if is_enabled else Node.PROCESS_MODE_DISABLED
