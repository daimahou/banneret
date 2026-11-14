class_name FightController
extends RefCounted
# Plays a fight one delta at a time: it asks the brains for choices and the rules for deltas, and waits on the stage, if any, to show each beat and blow.

signal action_resolved(action: Action)

var fight_model: FightModel
var hero_brain: Brain

var _enemy_brain: Brain
var _stage: Stage
# Empty while no pause is requested.
var _pause_request: Callable
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


# A pause is a coroutine the fight stands still for. It waits for a safe boundary: the end of the action being shown, or none while the heroes' brain waits.
func request_pause(pause: Callable) -> void:
	_pause_request = pause
	if hero_brain.is_waiting():
		_play_pause()


func is_pause_requested() -> bool:
	return not _pause_request.is_null()


func is_paused() -> bool:
	return _is_paused


func play() -> void:
	while not fight_model.is_over():
		if is_pause_requested():
			await _play_pause()
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
	_pause_request = Callable()


func _play_pause() -> void:
	var pause := _pause_request
	_pause_request = Callable()
	_is_paused = true
	var player_brain := hero_brain as PlayerBrain
	var input: PlayerInput = null if player_brain == null else player_brain.input
	if input != null:
		input.process_mode = Node.PROCESS_MODE_DISABLED
	await pause.call()
	if input != null:
		input.process_mode = Node.PROCESS_MODE_INHERIT
	_is_paused = false
	fight_model.notify_characters_changed()
