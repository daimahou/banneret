class_name MissionMap
extends RefCounted

var map_nodes: Array[MapNode] = []
var map_edges: Array[MapEdge] = []


func get_column(column: int) -> Array[MapNode]:
	var column_nodes: Array[MapNode] = []
	for map_node in map_nodes:
		if map_node.column == column:
			column_nodes.append(map_node)
	return column_nodes
