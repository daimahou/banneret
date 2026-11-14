class_name RunController
extends Node

signal fight_started(fight_controller: FightController)
signal level_up_started(level_up: LevelUp)

const HOLD_DURATION := 0.4

var run_model := RunModel.new()
var fight_controller: FightController

var _is_level_up_open := false

@onready var _stage: Stage = $Stage
@onready var _level_up_view: LevelUpView = $LevelUpView


func _ready() -> void:
	LimboConsole.info("Party: %s" % ", ".join(run_model.party.map(func(hero: Character) -> String: return hero.data.name)))
	await _stage.laid_out
	_play_fights(_get_first_fight_seed())


func _get_first_fight_seed() -> int:
	for argument in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		if argument.begins_with("--fight="):
			return int(argument.trim_prefix("--fight="))
	return randi()


func _play_fights(first_fight_seed: int) -> void:
	var fight_seed := first_fight_seed
	while is_inside_tree():
		await _play_fight(fight_seed)
		await get_tree().create_timer(HOLD_DURATION).timeout
		if run_model.is_lost():
			LimboConsole.info("Run lost")
			run_model = RunModel.new()
		else:
			LimboConsole.info("Fight won")
			await _play_level_up()
		fight_seed = randi()


func _play_fight(fight_seed: int) -> void:
	LimboConsole.info("Fight seed: %d" % fight_seed)
	var fight_model := FightModel.new(run_model.party, run_model.create_encounter_enemies())
	await _stage.show_encounter(fight_model)
	var enemy_brain := RandomBrain.new(FightModel.Side.ENEMY, fight_seed)
	fight_controller = FightController.new(fight_model, enemy_brain, PlayerBrain.new(_stage))
	fight_controller.set_stage(_stage)
	fight_started.emit(fight_controller)
	await get_tree().create_timer(HOLD_DURATION).timeout
	fight_controller.action_resolved.connect(_on_action_resolved)
	await fight_controller.play()
	fight_controller.dispose()
	fight_controller = null


func request_level_up() -> void:
	if _is_level_up_open:
		return
	var fight_model := fight_controller.fight_model
	get_tree().paused = true
	_level_up_view.process_mode = Node.PROCESS_MODE_ALWAYS
	await _play_level_up()
	_level_up_view.process_mode = Node.PROCESS_MODE_INHERIT
	get_tree().paused = false
	fight_model.notify_characters_changed()


func _play_level_up() -> void:
	if not run_model.has_level_up_left():
		return
	var level_up := run_model.create_level_up()
	LimboConsole.info("Level-up %d: %s draft" % [level_up.number, level_up.get_draft_name()])
	if level_up.has_offers():
		await _show_level_up(level_up)
	run_model.confirm_level_up(level_up)


func _show_level_up(level_up: LevelUp) -> void:
	var select_offer := func(hero: Character, offer: LevelUpOffer) -> void:
		level_up.select_offer(hero, offer)
		_level_up_view.update_states()
	_is_level_up_open = true
	_level_up_view.offer_selected.connect(select_offer)
	_level_up_view.show_level_up(level_up)
	level_up_started.emit(level_up)
	while not level_up.is_ready():
		await _level_up_view.continue_pressed
	_level_up_view.offer_selected.disconnect(select_offer)
	_level_up_view.hide()
	_is_level_up_open = false


func _on_action_resolved(action: Action) -> void:
	var names := [action.actor.data.name, action.skill.data.name, action.target.data.name]
	LimboConsole.info("%s: %s on %s, %d health left" % (names + [action.target.health]))
