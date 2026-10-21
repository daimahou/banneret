extends GdUnitTestSuite


func test_step_rows_without_edges_offers_every_neighbour() -> void:
	assert_array(MissionMapGenerator.get_step_rows([], 1)).contains_exactly_in_any_order([0, 1, 2])


func test_step_rows_skip_an_edge_that_crosses_an_existing_one() -> void:
	var edges: Array[Vector2i] = [Vector2i(0, 1)]
	assert_array(MissionMapGenerator.get_step_rows(edges, 1)).contains_exactly_in_any_order([1, 2])


func test_step_rows_from_the_bottom_row_keep_to_the_lattice() -> void:
	var bottom_row := MissionMapGenerator.ROW_COUNT - 1
	var edges: Array[Vector2i] = [Vector2i(bottom_row - 1, bottom_row)]
	assert_array(MissionMapGenerator.get_step_rows(edges, bottom_row)).contains_exactly([bottom_row])


func test_step_rows_skip_a_crossing_edge_from_below() -> void:
	var edges: Array[Vector2i] = [Vector2i(2, 1)]
	assert_array(MissionMapGenerator.get_step_rows(edges, 1)).contains_exactly_in_any_order([0, 1])
