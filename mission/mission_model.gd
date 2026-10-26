class_name MissionModel
extends RefCounted

# Closed: out of reach. Ahead: still reachable, past the open ones.
enum Visitation { CLOSED, AHEAD, OPEN, TRAVELLED, CURRENT }

var mission_map: MissionMap
var registry_filter := RegistryFilter.new()

var _trail: Array[MapNode] = []
var _offers: Array[Offer] = []
var _resolved_offer: Offer
var _rng := RandomNumberGenerator.new()


func _init(model_mission_map: MissionMap, map_seed: int) -> void:
	mission_map = model_mission_map
	_rng.seed = hash([map_seed, "offers"])


func travel_to(map_node: MapNode) -> void:
	if map_node not in get_open_map_nodes():
		push_error("Map node (%d, %d) is not open" % [map_node.column, map_node.row])
		return
	_trail.append(map_node)
	var event_type := map_node.event_type
	var registry := MapNode.EVENT_BAGS[event_type]
	var drawn: Array[Offer] = []
	for id in registry.pick_random(MapNode.EVENT_OFFER_COUNTS[event_type], registry_filter, _rng):
		drawn.append(registry.load_entry(id) as Offer)
	if event_type in MapNode.PICKED_EVENT_TYPES:
		_offers = drawn
		_resolved_offer = null
	else:
		_offers = []
		_resolved_offer = null if drawn.is_empty() else drawn[0]


# Empty once the event has resolved.
func get_offers() -> Array[Offer]:
	return _offers


func pick_offer(offer: Offer) -> void:
	if offer not in _offers:
		push_error("Offer %s is not pending" % offer.name)
		return
	_resolved_offer = offer
	_offers.clear()


# Null while offers are pending, or when the draw was empty.
func get_resolved_offer() -> Offer:
	return _resolved_offer


func get_current_map_node() -> MapNode:
	return null if _trail.is_empty() else _trail.back()


func is_mission_ended() -> bool:
	var current := get_current_map_node()
	return current != null and current.event_type == MapNode.EventType.ENCOUNTER


func get_open_map_nodes() -> Array[MapNode]:
	if not _offers.is_empty():
		return []
	return _get_next_map_nodes()


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


# A lead-in road, from off the map, has no start node.
func get_road_visitation(start_node: MapNode, end_node: MapNode) -> Visitation:
	var trail_index := _trail.find(end_node)
	if trail_index != -1 and start_node == (null if trail_index == 0 else _trail[trail_index - 1]):
		return Visitation.TRAVELLED
	if start_node == get_current_map_node():
		return Visitation.OPEN
	if _get_reachable_map_nodes().has(start_node):
		return Visitation.AHEAD
	return Visitation.CLOSED


func _get_reachable_map_nodes() -> Dictionary[MapNode, bool]:
	var reachable: Dictionary[MapNode, bool] = {}
	var frontier := _get_next_map_nodes()
	while not frontier.is_empty():
		var map_node: MapNode = frontier.pop_back()
		if reachable.has(map_node):
			continue
		reachable[map_node] = true
		frontier.append_array(mission_map.get_next_map_nodes(map_node))
	return reachable


func _get_next_map_nodes() -> Array[MapNode]:
	if is_mission_ended():
		return []
	return mission_map.get_next_map_nodes(get_current_map_node())
