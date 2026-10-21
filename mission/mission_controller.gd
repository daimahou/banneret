class_name MissionController
extends Node

signal mission_ended

const MISSION_INDEX := 0

var _mission_model: MissionModel
var _is_travelling := false

@onready var _stage: Stage = $Stage


func _enter_tree() -> void:
	LimboConsole.register_command(start_mission, "map_seed", "Rebuild the mission map from a seed")


func _exit_tree() -> void:
	LimboConsole.unregister_command(start_mission)


func _ready() -> void:
	_stage.map_node_pressed.connect(_on_map_node_pressed)
	await _stage.laid_out
	start_mission(randi())


func start_mission(map_seed: int) -> void:
	print("Mission map seed: %d" % map_seed)
	_mission_model = MissionModel.new(MissionMapGenerator.generate(map_seed, MISSION_INDEX))
	_is_travelling = false
	_stage.show_mission(_mission_model, map_seed)


# Input waits until the stage has shown the travel.
func _on_map_node_pressed(map_node: MapNode) -> void:
	if _is_travelling or map_node not in _mission_model.get_open_map_nodes():
		return
	_is_travelling = true
	_mission_model.travel_to(map_node)
	await _stage.show_travel(map_node)
	_is_travelling = false
	if _mission_model.is_mission_ended():
		print("Mission ended: encounter reached")
		mission_ended.emit()
