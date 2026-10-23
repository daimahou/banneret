extends GdUnitTestSuite

const AREA := Rect2(0, 0, 2000, 800)


func test_heroes_stand_in_the_left_half_front_first() -> void:
	var positions := PuppetLayout.get_stand_positions(AREA, 3, PuppetLayout.Side.LEFT)
	assert_int(positions.size()).is_equal(3)
	for index in positions.size():
		assert_float(positions[index].x).is_between(AREA.position.x, AREA.get_center().x)
		if index > 0:
			assert_float(positions[index].x).is_less(positions[index - 1].x)


func test_enemies_stand_in_the_right_half_front_first() -> void:
	var positions := PuppetLayout.get_stand_positions(AREA, 2, PuppetLayout.Side.RIGHT)
	assert_int(positions.size()).is_equal(2)
	for index in positions.size():
		assert_float(positions[index].x).is_between(AREA.get_center().x, AREA.end.x)
		if index > 0:
			assert_float(positions[index].x).is_greater(positions[index - 1].x)


func test_the_two_fronts_keep_the_middle_gap_between_them() -> void:
	var heroes := PuppetLayout.get_stand_positions(AREA, 3, PuppetLayout.Side.LEFT)
	var enemies := PuppetLayout.get_stand_positions(AREA, 3, PuppetLayout.Side.RIGHT)
	assert_float(enemies[0].x - heroes[0].x).is_greater_equal(PuppetLayout.MIDDLE_GAP)


func test_every_puppet_stands_on_the_bottom_edge() -> void:
	var positions := PuppetLayout.get_stand_positions(AREA, 3, PuppetLayout.Side.LEFT)
	positions.append_array(PuppetLayout.get_stand_positions(AREA, 1, PuppetLayout.Side.RIGHT))
	for position in positions:
		assert_float(position.y).is_equal(AREA.end.y)
