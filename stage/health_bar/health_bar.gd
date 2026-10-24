class_name HealthBar
extends Control
# A character's frame, in the row below the stage front: the portrait, a health fill and `health/max`, and an AP pip that is only art for now.

# Health just lost shows as damage, holds, then drains; in seconds.
const DAMAGE_HOLD_DURATION := 0.4
const DAMAGE_DRAIN_DURATION := 0.3
const FADE_DURATION := 0.4

# Inside the frame art's top bar.
const FILL_RECT := Rect2(226.0, 76.0, 333.0, 40.0)
const FILL_COLOR := Color("a83a2a")
const DAMAGE_COLOR := Color("e8c547")
const EMPTY_COLOR := Color("5c534a")
const TEXT_COLOR := Color.WHITE
const FONT_SIZE := 36

var character: Character

# Above the character's health while damage still shows.
var _shown_health := 0.0:
	set(value):
		_shown_health = value
		queue_redraw()
var _drain_tween: Tween

@onready var _portrait: TextureRect = $Portrait


func _ready() -> void:
	_shown_health = character.health
	_portrait.texture = character.data.portrait


func _draw() -> void:
	draw_rect(FILL_RECT, EMPTY_COLOR)
	draw_rect(_get_fill(_shown_health), DAMAGE_COLOR)
	draw_rect(_get_fill(character.health), FILL_COLOR)
	var font := get_theme_default_font()
	var text := "%d/%d" % [character.health, character.data.max_health]
	var baseline := FILL_RECT.position.y + (FILL_RECT.size.y + font.get_ascent(FONT_SIZE) - font.get_descent(FONT_SIZE)) / 2.0
	draw_string(font, Vector2(FILL_RECT.position.x, baseline), text, HORIZONTAL_ALIGNMENT_CENTER, FILL_RECT.size.x, FONT_SIZE, TEXT_COLOR)


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


func _get_fill(health: float) -> Rect2:
	var fill := FILL_RECT
	fill.size.x *= clampf(health / character.data.max_health, 0.0, 1.0)
	return fill
