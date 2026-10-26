extends GdUnitTestSuite

const ROAD_LENGTH := 500.0


func test_roads_branching_from_one_node_merge_their_first_steps() -> void:
	var start_node := MapNode.new()
	var left := _create_road(start_node, MapNode.new())
	var right := _create_road(start_node, MapNode.new())
	var laid: Array[RoadLayout.LaidRoadDash] = [
		_create_dash(left, Vector2(0, 0), 100.0, true),
		_create_dash(right, Vector2(0, 10), 100.0, true),
	]
	var kept := RoadLayout.prune_road_dashes(laid)
	assert_int(kept.size()).is_equal(1)
	assert_vector(kept[0].road_dash.position).is_equal(Vector2(0, 5))


func test_first_steps_out_of_different_nodes_stay_apart() -> void:
	var end_node := MapNode.new()
	var upper := _create_road(MapNode.new(), end_node)
	var lower := _create_road(MapNode.new(), end_node)
	var laid: Array[RoadLayout.LaidRoadDash] = [
		_create_dash(upper, Vector2(0, 0), 100.0, true),
		_create_dash(lower, Vector2(0, 10), 100.0, true),
	]
	assert_int(RoadLayout.prune_road_dashes(laid).size()).is_equal(2)


func test_merged_dash_keeps_the_roads_it_absorbed() -> void:
	var end_node := MapNode.new()
	var absorbed := _create_road(MapNode.new(), end_node)
	var keeper := _create_road(MapNode.new(), end_node)
	var laid: Array[RoadLayout.LaidRoadDash] = [
		_create_dash(keeper, Vector2(0, 0), 340.0, false),
		_create_dash(absorbed, Vector2(0, 10), 300.0, false),
		_create_dash(absorbed, Vector2(0, 61), 340.0, false),
	]
	assert_int(RoadLayout.prune_road_dashes(laid).size()).is_equal(2)


func _create_road(start_node: MapNode, end_node: MapNode) -> RoadLayout.Road:
	var road := RoadLayout.Road.new()
	road.length = ROAD_LENGTH
	road.start_node = start_node
	road.end_node = end_node
	return road


func _create_dash(road: RoadLayout.Road, dash_position: Vector2, offset: float, is_first_step: bool) -> RoadLayout.LaidRoadDash:
	return RoadLayout.create_laid_road_dash(RoadLayout.ROAD_DASH_TEXTURES[0], dash_position, 0.0, road, offset, is_first_step)
