class_name MissionController
extends Node

signal mission_ended

const MISSION_INDEX := 0

var _mission_model: MissionModel
var _is_stage_busy := false

@onready var _stage: Stage = $Stage


func _enter_tree() -> void:
	LimboConsole.register_command(start_mission, "map_seed", "Rebuild the mission map from a seed")


func _exit_tree() -> void:
	LimboConsole.unregister_command(start_mission)


func _ready() -> void:
	_stage.map_node_pressed.connect(_on_map_node_pressed)
	_stage.offer_pressed.connect(_on_offer_pressed)
	await _stage.laid_out
	start_mission(randi())


func start_mission(map_seed: int) -> void:
	LimboConsole.info("Mission map seed: %d" % map_seed)
	_mission_model = MissionModel.new(MissionMapGenerator.generate(map_seed, MISSION_INDEX), map_seed)
	_is_stage_busy = false
	_stage.show_mission(_mission_model, map_seed)


# Input waits until the stage has shown each change: the travel, the offers dropping, the offers lifting.
func _on_map_node_pressed(map_node: MapNode) -> void:
	if _is_stage_busy or map_node not in _mission_model.get_open_map_nodes():
		return
	_is_stage_busy = true
	_mission_model.travel_to(map_node)
	await _stage.show_travel(map_node)
	var offers := _mission_model.get_offers()
	if not offers.is_empty():
		await _stage.show_offers(offers)
	_is_stage_busy = false
	if offers.is_empty():
		_finish_event()


func _on_offer_pressed(offer: Offer) -> void:
	if _is_stage_busy or offer not in _mission_model.get_offers():
		return
	_is_stage_busy = true
	_mission_model.pick_offer(offer)
	await _stage.hide_offers()
	_is_stage_busy = false
	_finish_event()


func _finish_event() -> void:
	var resolved_offer := _mission_model.get_resolved_offer()
	LimboConsole.info("Event resolved: %s" % ("none" if resolved_offer == null else resolved_offer.name))
	if _mission_model.is_mission_ended():
		LimboConsole.info("Mission ended: encounter reached")
		mission_ended.emit()
