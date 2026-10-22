class_name PuppetLayout
extends RefCounted

enum Side { LEFT, RIGHT }

# Low enough that the stage front hides each puppet's stick.
const FOOT_Y := 1260.0


# Spread across the side's half of the flats, front first: the front of a line is nearest the middle.
static func get_stand_positions(flats_rect: Rect2, count: int, side: PuppetLayout.Side) -> Array[Vector2]:
	var direction := -1.0 if side == Side.LEFT else 1.0
	var half_width := flats_rect.size.x / 2.0
	var positions: Array[Vector2] = []
	for index in count:
		var x := flats_rect.get_center().x + direction * half_width * (index + 0.5) / count
		positions.append(Vector2(x, FOOT_Y))
	return positions
