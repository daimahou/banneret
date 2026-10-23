class_name RunController
extends Node

const ENCOUNTER_ENEMIES: Array[CharacterData] = [preload("res://enemy/brigand.tres")]

var run_model := RunModel.new()

var _mission_controller: MissionController
var _is_in_encounter := false

@onready var _stage: Stage = $Stage


func _enter_tree() -> void:
	LimboConsole.register_command(start_mission, "map_seed", "Rebuild the mission map from a seed")
	LimboConsole.register_command(end_encounter, "end_encounter", "End the encounter and start a new mission")


func _exit_tree() -> void:
	LimboConsole.unregister_command(start_mission)
	LimboConsole.unregister_command(end_encounter)


func _ready() -> void:
	LimboConsole.info("Party: %s" % ", ".join(run_model.party.map(func(hero: Character) -> String: return hero.data.name)))
	await _stage.laid_out
	start_mission(randi())


# Null until the stage is laid out.
func get_mission_controller() -> MissionController:
	return _mission_controller


# Replaces the current mission; the party stays the run's. Over the fight, the stage plays the transition back.
func start_mission(map_seed: int) -> void:
	if _stage.is_in_transition():
		LimboConsole.warn("The stage is in a transition")
		return
	if _mission_controller != null:
		_mission_controller.dispose()
	_is_in_encounter = false
	_mission_controller = MissionController.new(_stage, map_seed)
	_mission_controller.mission_ended.connect(_on_mission_ended)


func end_encounter() -> void:
	if not _is_in_encounter:
		LimboConsole.warn("No encounter to end")
		return
	start_mission(randi())


func _on_mission_ended() -> void:
	_is_in_encounter = true
	var enemies: Array[Character] = []
	for enemy_data in ENCOUNTER_ENEMIES:
		enemies.append(Character.new(enemy_data))
	_stage.show_encounter(run_model.party, enemies)
