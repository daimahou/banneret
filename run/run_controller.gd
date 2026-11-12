class_name RunController
extends Node

signal fight_started(fight_controller: FightController)

const HOLD_DURATION := 0.4

var run_model := RunModel.new()
var fight_controller: FightController

@onready var _stage: Stage = $Stage


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


func _on_action_resolved(action: Action) -> void:
	LimboConsole.info("%s: %s on %s, %d health left" % [action.actor.data.name, action.skill.name, action.target.data.name, action.target.health])
