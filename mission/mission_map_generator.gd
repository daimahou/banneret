class_name MissionMapGenerator
extends RefCounted

const LATTICE_COLUMN_COUNT := 3
const ROW_COUNT := 4

const ENCOUNTER_COLUMN := LATTICE_COLUMN_COUNT
const ENCOUNTER_ROW := 2

const PATH_COUNT := 3

const NODE_JITTER := 60.0
const EDGE_WOBBLE := 80.0

const NON_ENCOUNTER_TYPES: Array[MapNode.EventType] = [MapNode.EventType.PLACEHOLDER]


static func generate(map_seed: int, mission_index: int) -> MissionMap:
	var mission_map := _lay_out(map_seed)
	_fill_events(mission_map, mission_index, map_seed)
	return mission_map


static func get_step_rows(edges: Array[Vector2i], row: int) -> Array[int]:
	var rows: Array[int] = []
	for step_row in range(row - 1, row + 2):
		if step_row >= 0 and step_row < ROW_COUNT and not _crosses_any(edges, Vector2i(row, step_row)):
			rows.append(step_row)
	return rows


static func _crosses_any(edges: Array[Vector2i], edge: Vector2i) -> bool:
	for other in edges:
		if (edge.x - other.x) * (edge.y - other.y) < 0:
			return true
	return false


static func _lay_out(map_seed: int) -> MissionMap:
	var rng := RandomNumberGenerator.new()
	rng.seed = map_seed
	var mission_map := MissionMap.new()

	var first_row := -1
	for path in PATH_COUNT:
		var row := rng.randi_range(0, ROW_COUNT - 1)
		if path == 0:
			first_row = row
		elif path == 1:
			row = posmod(first_row + rng.randi_range(1, ROW_COUNT - 1), ROW_COUNT)
		var map_node := _get_or_add_map_node(mission_map, Vector2i(0, row), rng)
		for column in range(1, LATTICE_COLUMN_COUNT):
			var step_rows := get_step_rows(_get_gap_edges(mission_map, column), row)
			row = step_rows[rng.randi_range(0, step_rows.size() - 1)]
			var next_node := _get_or_add_map_node(mission_map, Vector2i(column, row), rng)
			_add_map_edge(mission_map, map_node, next_node, rng)
			map_node = next_node

	var encounter := _get_or_add_map_node(mission_map, Vector2i(ENCOUNTER_COLUMN, ENCOUNTER_ROW), rng)
	for end_node in mission_map.get_column(ENCOUNTER_COLUMN - 1):
		_add_map_edge(mission_map, end_node, encounter, rng)
	return mission_map


# A cell is (column, row).
static func _get_or_add_map_node(mission_map: MissionMap, cell: Vector2i, rng: RandomNumberGenerator) -> MapNode:
	for existing in mission_map.get_column(cell.x):
		if existing.row == cell.y:
			return existing
	var map_node := MapNode.new()
	map_node.column = cell.x
	map_node.row = cell.y
	map_node.jitter = Vector2(rng.randf_range(-NODE_JITTER, NODE_JITTER), rng.randf_range(-NODE_JITTER, NODE_JITTER))
	mission_map.map_nodes.append(map_node)
	return map_node


static func _add_map_edge(mission_map: MissionMap, start_node: MapNode, end_node: MapNode, rng: RandomNumberGenerator) -> void:
	if end_node.row in start_node.next_rows:
		return
	start_node.next_rows.append(end_node.row)
	end_node.previous_rows.append(start_node.row)
	var map_edge := MapEdge.new()
	map_edge.start = start_node
	map_edge.end = end_node
	map_edge.wobble = rng.randf_range(-EDGE_WOBBLE, EDGE_WOBBLE)
	mission_map.map_edges.append(map_edge)


# The map edges entering a column, as (start row, end row).
static func _get_gap_edges(mission_map: MissionMap, column: int) -> Array[Vector2i]:
	var edges: Array[Vector2i] = []
	for map_edge in mission_map.map_edges:
		if map_edge.end.column == column:
			edges.append(Vector2i(map_edge.start.row, map_edge.end.row))
	return edges


static func _fill_events(mission_map: MissionMap, mission_index: int, map_seed: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = map_seed
	for map_node in mission_map.map_nodes:
		map_node.event_type = _pick_event_type(map_node, mission_index, rng)


static func _pick_event_type(map_node: MapNode, _mission_index: int, rng: RandomNumberGenerator) -> MapNode.EventType:
	if map_node.column == ENCOUNTER_COLUMN:
		return MapNode.EventType.ENCOUNTER
	return NON_ENCOUNTER_TYPES[rng.randi_range(0, NON_ENCOUNTER_TYPES.size() - 1)]
