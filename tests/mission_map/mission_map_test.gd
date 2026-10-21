extends GdUnitTestSuite


func test_off_the_map_every_first_column_map_node_is_next() -> void:
	var mission_map := MissionMap.new()
	var upper := MissionMapFixture.add_map_node(mission_map, 0, 0)
	var lower := MissionMapFixture.add_map_node(mission_map, 0, 2)
	var beyond := MissionMapFixture.add_map_node(mission_map, 1, 1)
	MissionMapFixture.add_map_edge(mission_map, upper, beyond)
	MissionMapFixture.add_map_edge(mission_map, lower, beyond)
	assert_array(mission_map.get_next_map_nodes(null)).contains_exactly_in_any_order([upper, lower])


func test_from_a_map_node_only_the_map_nodes_its_roads_lead_to_are_next() -> void:
	var mission_map := MissionMap.new()
	var start_node := MissionMapFixture.add_map_node(mission_map, 0, 1)
	var other_start := MissionMapFixture.add_map_node(mission_map, 0, 2)
	var upper := MissionMapFixture.add_map_node(mission_map, 1, 0)
	var middle := MissionMapFixture.add_map_node(mission_map, 1, 1)
	var lower := MissionMapFixture.add_map_node(mission_map, 1, 2)
	MissionMapFixture.add_map_edge(mission_map, start_node, upper)
	MissionMapFixture.add_map_edge(mission_map, start_node, middle)
	MissionMapFixture.add_map_edge(mission_map, other_start, lower)
	assert_array(mission_map.get_next_map_nodes(start_node)).contains_exactly_in_any_order([upper, middle])
