class_name HealthBar
extends Control
# A character's health, below the stage front: a frame, a fill and `health/max`. The stage slides it in and out with its puppet.

const FILL_DURATION := 0.3
const FADE_DURATION := 0.4

const FRAME_COLOR := Color("2b2118")
const FILL_COLOR := Color("a83a2a")
const EMPTY_COLOR := Color("5c534a")
const TEXT_COLOR := Color.WHITE
const FRAME_WIDTH := 6.0
const FONT_SIZE := 44

var character: Character

# Shown, and eased towards the character's health.
var _health := 0.0:
	set(value):
		_health = value
		queue_redraw()


func _init(bar_character: Character) -> void:
	character = bar_character
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_health = character.health


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, EMPTY_COLOR)
	var fill := rect.grow(-FRAME_WIDTH)
	fill.size.x *= clampf(_health / character.data.max_health, 0.0, 1.0)
	draw_rect(fill, FILL_COLOR)
	draw_rect(rect, FRAME_COLOR, false, FRAME_WIDTH)
	var font := get_theme_default_font()
	var text := "%d/%d" % [character.health, character.data.max_health]
	var baseline := (size.y + font.get_ascent(FONT_SIZE) - font.get_descent(FONT_SIZE)) / 2.0
	draw_string(font, Vector2(0.0, baseline), text, HORIZONTAL_ALIGNMENT_CENTER, size.x, FONT_SIZE, TEXT_COLOR)


# Eases the fill to the character's health.
func show_health() -> void:
	create_tween().tween_property(self, "_health", float(character.health), FILL_DURATION)


func fade_out() -> void:
	create_tween().tween_property(self, "modulate:a", 0.0, FADE_DURATION)
