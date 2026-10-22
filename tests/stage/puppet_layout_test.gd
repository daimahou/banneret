extends GdUnitTestSuite

const FLATS_RECT := Rect2(1000, 400, 2000, 700)


func test_heroes_stand_in_the_left_half_front_first() -> void:
	var positions := PuppetLayout.get_stand_positions(FLATS_RECT, 3, PuppetLayout.Side.LEFT)
	assert_int(positions.size()).is_equal(3)
	for index in positions.size():
		assert_float(positions[index].x).is_between(FLATS_RECT.position.x, FLATS_RECT.get_center().x)
		if index > 0:
			assert_float(positions[index].x).is_less(positions[index - 1].x)


func test_enemies_stand_in_the_right_half_front_first() -> void:
	var positions := PuppetLayout.get_stand_positions(FLATS_RECT, 2, PuppetLayout.Side.RIGHT)
	assert_int(positions.size()).is_equal(2)
	for index in positions.size():
		assert_float(positions[index].x).is_between(FLATS_RECT.get_center().x, FLATS_RECT.end.x)
		if index > 0:
			assert_float(positions[index].x).is_greater(positions[index - 1].x)


func test_every_puppet_stands_on_the_same_floor_line() -> void:
	var positions := PuppetLayout.get_stand_positions(FLATS_RECT, 3, PuppetLayout.Side.LEFT)
	positions.append_array(PuppetLayout.get_stand_positions(FLATS_RECT, 1, PuppetLayout.Side.RIGHT))
	for position in positions:
		assert_float(position.y).is_equal(positions[0].y)
