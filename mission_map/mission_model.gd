class_name MissionModel
extends RefCounted

# Closed: out of reach. Ahead: still reachable, past the open ones.
enum Visitation { CLOSED, AHEAD, OPEN, TRAVELLED, CURRENT }

var mission_map: MissionMap

var _trail: Array[MapNode] = []


func _init(model_mission_map: MissionMap) -> void:
	mission_map = model_mission_map


func travel_to(map_node: MapNode) -> void:
	if map_node not in get_open_map_nodes():
		push_error("Map node (%d, %d) is not open" % [map_node.column, map_node.row])
		return
	_trail.append(map_node)


# Null before the first travel.
func get_current_map_node() -> MapNode:
	return null if _trail.is_empty() else _trail.back()


func is_mission_ended() -> bool:
	var current := get_current_map_node()
	return current != null and current.event_type == MapNode.EventType.ENCOUNTER


func get_open_map_nodes() -> Array[MapNode]:
	if is_mission_ended():
		return []
	return mission_map.get_next_map_nodes(get_current_map_node())


func get_map_node_visitation(map_node: MapNode) -> Visitation:
	if map_node == get_current_map_node():
		return Visitation.CURRENT
	if map_node in _trail:
		return Visitation.TRAVELLED
	if map_node in get_open_map_nodes():
		return Visitation.OPEN
	if _get_reachable_map_nodes().has(map_node):
		return Visitation.AHEAD
	return Visitation.CLOSED


# A road takes its start node's reach; a lead-in road, from off the map, has no start node.
func get_road_visitation(start_node: MapNode, end_node: MapNode) -> Visitation:
	var trail_index := _trail.find(end_node)
	if trail_index != -1 and start_node == (null if trail_index == 0 else _trail[trail_index - 1]):
		return Visitation.TRAVELLED
	if start_node == get_current_map_node():
		return Visitation.OPEN
	if _get_reachable_map_nodes().has(start_node):
		return Visitation.AHEAD
	return Visitation.CLOSED


# Every map node the coach can still reach from where it is.
func _get_reachable_map_nodes() -> Dictionary[MapNode, bool]:
	var reachable: Dictionary[MapNode, bool] = {}
	var frontier := get_open_map_nodes()
	while not frontier.is_empty():
		var map_node: MapNode = frontier.pop_back()
		if reachable.has(map_node):
			continue
		reachable[map_node] = true
		frontier.append_array(mission_map.get_next_map_nodes(map_node))
	return reachable
