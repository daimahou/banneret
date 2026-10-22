extends GdUnitTestSuite


func test_a_flat_shows_the_part_of_the_battle_illustration_under_it() -> void:
	var battleground_rect := Rect2(1000, 400, 2000, 800)
	var flat_rect := Rect2(1500, 500, 400, 600)
	var region := Flat.get_battle_region(flat_rect, battleground_rect, Vector2(2000, 800))
	assert_vector(region.position).is_equal(Vector2(500, 100))
	assert_vector(region.size).is_equal(Vector2(400, 600))


func test_the_region_follows_a_texture_of_another_size() -> void:
	var battleground_rect := Rect2(1000, 400, 2000, 800)
	var flat_rect := Rect2(1500, 500, 400, 600)
	var region := Flat.get_battle_region(flat_rect, battleground_rect, Vector2(1000, 400))
	assert_vector(region.position).is_equal(Vector2(250, 50))
	assert_vector(region.size).is_equal(Vector2(200, 300))
