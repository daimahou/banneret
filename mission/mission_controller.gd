class_name MissionController
extends RefCounted

signal mission_ended

const MISSION_INDEX := 0

var _stage: Stage
var _mission_model: MissionModel
var _is_stage_busy := false


func _init(mission_stage: Stage, map_seed: int) -> void:
	_stage = mission_stage
	LimboConsole.info("Mission map seed: %d" % map_seed)
	_mission_model = MissionModel.new(MissionMapGenerator.generate(map_seed, MISSION_INDEX), map_seed)
	_stage.map_node_pressed.connect(_on_map_node_pressed)
	_stage.offer_pressed.connect(_on_offer_pressed)
	_stage.show_mission(_mission_model, map_seed)


func dispose() -> void:
	_stage.map_node_pressed.disconnect(_on_map_node_pressed)
	_stage.offer_pressed.disconnect(_on_offer_pressed)


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
