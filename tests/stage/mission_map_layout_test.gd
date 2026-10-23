extends GdUnitTestSuite

const FLAT_SIZE := Vector2(400, 700)
const SEPARATION := 12.0
const FLAT_COUNT := 4


func test_every_map_node_sits_inside_its_flat() -> void:
	var mission_map := _create_mission_map()
	var layout := MissionMapLayout.create(mission_map, 1, FLAT_SIZE, SEPARATION, FLAT_COUNT)
	for index in FLAT_COUNT:
		assert_array(layout.get_map_nodes(index)).contains_exactly_in_any_order(mission_map.get_column(index))
		for map_node in layout.get_map_nodes(index):
			assert_bool(Rect2(Vector2.ZERO, FLAT_SIZE).has_point(layout.get_map_node_position(map_node))).is_true()


func test_every_road_dash_sits_inside_its_flat() -> void:
	var layout := MissionMapLayout.create(_create_mission_map(), 1, FLAT_SIZE, SEPARATION, FLAT_COUNT)
	var road_dash_count := 0
	for index in FLAT_COUNT:
		for road_dash in layout.get_road_dashes(index):
			assert_bool(Rect2(Vector2.ZERO, FLAT_SIZE).has_point(road_dash.position)).is_true()
			road_dash_count += 1
	assert_int(road_dash_count).is_greater(0)


func test_neighbouring_map_nodes_keep_their_spacing_despite_jitter() -> void:
	var mission_map := MissionMap.new()
	var upper := MissionMapFixture.add_map_node(mission_map, 0, 1)
	var lower := MissionMapFixture.add_map_node(mission_map, 0, 2)
	upper.jitter = Vector2(0, 100)
	lower.jitter = Vector2(0, -100)
	# Tall enough that the rows leave room for jitter.
	var layout := MissionMapLayout.create(mission_map, 1, Vector2(400, 1000), SEPARATION, FLAT_COUNT)
	var spacing := layout.get_map_node_position(lower).y - layout.get_map_node_position(upper).y
	assert_float(spacing).is_greater_equal(MissionMapLayout.MAP_NODE_MIN_SPACING)


func _create_mission_map() -> MissionMap:
	var mission_map := MissionMap.new()
	var previous: Array[MapNode] = []
	for column in FLAT_COUNT:
		var current: Array[MapNode] = [
			MissionMapFixture.add_map_node(mission_map, column, 1),
			MissionMapFixture.add_map_node(mission_map, column, 2),
		]
		for index in previous.size():
			MissionMapFixture.add_map_edge(mission_map, previous[index], current[index])
		previous = current
	return mission_map
