class_name PuppetLayout
extends RefCounted

enum Side { LEFT, RIGHT }

# Kept clear between the two fronts, in design units.
const MIDDLE_GAP := 300.0


# Spread across the side's half of `area`, front first: the front of a line is nearest the middle.
# Feet stand on the area's bottom edge.
static func get_stand_positions(area: Rect2, count: int, side: PuppetLayout.Side) -> Array[Vector2]:
	var direction := -1.0 if side == Side.LEFT else 1.0
	var line_width := area.size.x / 2.0 - MIDDLE_GAP / 2.0
	var positions: Array[Vector2] = []
	for index in count:
		var x := area.get_center().x + direction * (MIDDLE_GAP / 2.0 + line_width * (index + 0.5) / count)
		positions.append(Vector2(x, area.end.y))
	return positions
