class_name Stage
extends Control

const MISSION_INDEX := 0

var _flats: Array[Flat] = []

@onready var _flats_container: HBoxContainer = $Flats


func _enter_tree() -> void:
	LimboConsole.register_command(build_mission_map, "map_seed", "Rebuild the mission map from a seed")


func _exit_tree() -> void:
	LimboConsole.unregister_command(build_mission_map)


func _ready() -> void:
	for child in _flats_container.get_children():
		if child is Flat:
			_flats.append(child)
	# The container sizes the flats on its first sort, which is still pending here.
	await _flats_container.sort_children
	build_mission_map(randi())


func build_mission_map(map_seed: int) -> void:
	print("Mission map seed: %d" % map_seed)
	var mission_map := MissionMapGenerator.generate(map_seed, MISSION_INDEX)
	var column_count := MissionMapGenerator.ENCOUNTER_COLUMN + 1
	if column_count > _flats.size():
		push_error("Mission map has %d columns but the stage has %d flats" % [column_count, _flats.size()])
		return

	for column in column_count:
		_flats[column].show_column(mission_map.get_column(column))
	for flat in _flats.slice(column_count):
		flat.clear()

	var flat_rects: Array[Rect2] = []
	for flat in _flats:
		flat_rects.append(_get_stage_rect(flat))
	var map_node_positions: Dictionary[MapNode, Vector2] = {}
	for map_node in mission_map.map_nodes:
		map_node_positions[map_node] = flat_rects[map_node.column].position + _flats[map_node.column].get_map_node_position(map_node)

	# Roads draw from their own seed, so they don't replay the generator's random sequence.
	var road_seed := hash([map_seed, "roads"])
	for road_dash in RoadLayout.lay_out(mission_map, flat_rects, map_node_positions, road_seed):
		_add_road_dash_to_flat(road_dash, flat_rects)


func _get_stage_rect(flat: Flat) -> Rect2:
	return Rect2(_flats_container.position + flat.position, flat.size)


# Merging can move a dash, so it goes to the flat that contains it now; one left in a gap between flats is dropped.
func _add_road_dash_to_flat(road_dash: Flat.RoadDash, flat_rects: Array[Rect2]) -> void:
	for index in flat_rects.size():
		if flat_rects[index].has_point(road_dash.position):
			road_dash.position -= flat_rects[index].position
			_flats[index].add_road_dash(road_dash)
			return
