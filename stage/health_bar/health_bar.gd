class_name HealthBar
extends Control
# A character's frame, in the row below the stage front: the portrait, a health fill and `health/max`, and an AP pip that is only art for now.
# A new character flips the frame like a flat: it swaps while edge-on, and hides without one.

# Health just lost shows as damage, holds, then drains; in seconds.
const DAMAGE_HOLD_DURATION := 0.4
const DAMAGE_DRAIN_DURATION := 0.3

# Inside the frame art's top bar.
const FILL_RECT := Rect2(196.0, 65.0, 316.0, 35.0)
const FILL_COLOR := Color("a83a2a")
const DAMAGE_COLOR := Color("e8c547")
const EMPTY_COLOR := Color("5c534a")
const TEXT_COLOR := Color.WHITE
const FONT_SIZE := 32

# Null while the frame is unused. Set at once, though a flip draws it only once edge-on.
var character: Character

var _drawn_character: Character
# Above the character's health while damage still shows.
var _shown_health := 0.0:
	set(value):
		_shown_health = value
		queue_redraw()
var _drain_tween: Tween
var _flip_tween: Tween

@onready var _portrait: TextureRect = $Portrait


func _draw() -> void:
	if _drawn_character == null:
		return
	draw_rect(FILL_RECT, EMPTY_COLOR)
	draw_rect(_get_fill(_shown_health), DAMAGE_COLOR)
	draw_rect(_get_fill(_drawn_character.health), FILL_COLOR)
	var font := get_theme_default_font()
	var text := "%d/%d" % [_drawn_character.health, _drawn_character.data.max_health]
	var baseline := FILL_RECT.position.y + (FILL_RECT.size.y + font.get_ascent(FONT_SIZE) - font.get_descent(FONT_SIZE)) / 2.0
	draw_string(font, Vector2(FILL_RECT.position.x, baseline), text, HORIZONTAL_ALIGNMENT_CENTER, FILL_RECT.size.x, FONT_SIZE, TEXT_COLOR)


# Null hides the frame. Returns whether the frame flips, `delay` from now.
func show_character(shown_character: Character, delay: float) -> bool:
	if shown_character == character:
		return false
	character = shown_character
	if _flip_tween != null:
		_flip_tween.kill()
	pivot_offset = size / 2.0
	_flip_tween = create_tween().set_trans(Scenery.FLIP_TRANSITION)
	_flip_tween.tween_property(self, "scale:x", 0.0, Scenery.FLIP_DURATION / 2.0).set_ease(Tween.EASE_IN).set_delay(delay)
	_flip_tween.tween_callback(_draw_character)
	_flip_tween.tween_property(self, "scale:x", 1.0, Scenery.FLIP_DURATION / 2.0).set_ease(Tween.EASE_OUT)
	return true


func show_health() -> void:
	if _drawn_character != character:
		return
	if _drain_tween != null:
		_drain_tween.kill()
	if character.health >= _shown_health:
		_shown_health = character.health
		return
	queue_redraw()
	_drain_tween = create_tween()
	_drain_tween.tween_property(self, "_shown_health", float(character.health), DAMAGE_DRAIN_DURATION).set_delay(DAMAGE_HOLD_DURATION)


func _draw_character() -> void:
	if _drain_tween != null:
		_drain_tween.kill()
	_drawn_character = character
	visible = character != null
	if character != null:
		_portrait.texture = character.data.portrait
		_shown_health = character.health
	queue_redraw()


func _get_fill(health: float) -> Rect2:
	var fill := FILL_RECT
	fill.size.x *= clampf(health / _drawn_character.data.max_health, 0.0, 1.0)
	return fill
