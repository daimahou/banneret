class_name MissionMapFixture
extends RefCounted


static func add_map_node(mission_map: MissionMap, column: int, row: int, event_type := MapNode.EventType.PLACEHOLDER) -> MapNode:
	var map_node := MapNode.new()
	map_node.column = column
	map_node.row = row
	map_node.event_type = event_type
	mission_map.map_nodes.append(map_node)
	return map_node


static func add_map_edge(mission_map: MissionMap, start_node: MapNode, end_node: MapNode) -> void:
	var map_edge := MapEdge.new()
	map_edge.start = start_node
	map_edge.end = end_node
	mission_map.map_edges.append(map_edge)
