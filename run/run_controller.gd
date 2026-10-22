class_name RunController
extends Node

var run_model := RunModel.new()

var _mission_controller: MissionController

@onready var _stage: Stage = $Stage


func _enter_tree() -> void:
	LimboConsole.register_command(start_mission, "map_seed", "Rebuild the mission map from a seed")


func _exit_tree() -> void:
	LimboConsole.unregister_command(start_mission)


func _ready() -> void:
	LimboConsole.info("Party: %s" % ", ".join(run_model.party.map(func(hero: Hero) -> String: return hero.data.name)))
	await _stage.laid_out
	start_mission(randi())


# Null until the stage is laid out.
func get_mission_controller() -> MissionController:
	return _mission_controller


# Replaces the current mission; the party stays the run's.
func start_mission(map_seed: int) -> void:
	if _mission_controller != null:
		_mission_controller.dispose()
	_mission_controller = MissionController.new(_stage, map_seed)
