class_name HealthBar
extends Control
# A character's health, below the stage front: a frame, a fill and `health/max`. The stage slides it in and out with its puppet.

# Health just lost shows as damage, holds, then drains; in seconds.
const DAMAGE_HOLD_DURATION := 0.4
const DAMAGE_DRAIN_DURATION := 0.3
const FADE_DURATION := 0.4

const FRAME_COLOR := Color("2b2118")
const FILL_COLOR := Color("a83a2a")
const DAMAGE_COLOR := Color("e8c547")
const EMPTY_COLOR := Color("5c534a")
const TEXT_COLOR := Color.WHITE
const FRAME_WIDTH := 6.0
const FONT_SIZE := 44

var character: Character

# Above the character's health while damage still shows.
var _shown_health := 0.0:
	set(value):
		_shown_health = value
		queue_redraw()
var _drain_tween: Tween


func _init(bar_character: Character) -> void:
	character = bar_character
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shown_health = character.health


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, EMPTY_COLOR)
	var inside := rect.grow(-FRAME_WIDTH)
	draw_rect(_get_fill(inside, _shown_health), DAMAGE_COLOR)
	draw_rect(_get_fill(inside, character.health), FILL_COLOR)
	draw_rect(rect, FRAME_COLOR, false, FRAME_WIDTH)
	var font := get_theme_default_font()
	var text := "%d/%d" % [character.health, character.data.max_health]
	var baseline := (size.y + font.get_ascent(FONT_SIZE) - font.get_descent(FONT_SIZE)) / 2.0
	draw_string(font, Vector2(0.0, baseline), text, HORIZONTAL_ALIGNMENT_CENTER, size.x, FONT_SIZE, TEXT_COLOR)


func show_health() -> void:
	if _drain_tween != null:
		_drain_tween.kill()
	if character.health >= _shown_health:
		_shown_health = character.health
		return
	queue_redraw()
	_drain_tween = create_tween()
	_drain_tween.tween_property(self, "_shown_health", float(character.health), DAMAGE_DRAIN_DURATION).set_delay(DAMAGE_HOLD_DURATION)


func fade_out() -> void:
	create_tween().tween_property(self, "modulate:a", 0.0, FADE_DURATION)


func _get_fill(inside: Rect2, health: float) -> Rect2:
	var fill := inside
	fill.size.x *= clampf(health / character.data.max_health, 0.0, 1.0)
	return fill
