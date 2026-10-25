class_name HealthBar
extends Control
# A character's frame, in the row below the stage front: the portrait, the name, a health fill and `health/max`, and an AP pip that is only art for now.
# A new character flips the frame like a flat: it swaps while edge-on, and hides without one.

# Health just lost shows as damage, holds, then drains; in seconds.
const DAMAGE_HOLD_DURATION := 0.4
const DAMAGE_DRAIN_DURATION := 0.3

# Null while the frame is unused.
var character: Character

var _drain_tween: Tween
var _flip_tween: Tween

@onready var _portrait: TextureRect = $Portrait
@onready var _name: Label = $Name
# Both span the empty bar; their right anchor is the share of health they show.
@onready var _damage: Control = $Empty/Damage
@onready var _fill: Control = $Empty/Fill
# Grows both ways past the bar's height, so its line stays centred on it.
@onready var _health_label: Label = $Empty/HealthLabel


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
	_flip_tween.tween_callback(_show_content.bind(shown_character))
	_flip_tween.tween_property(self, "scale:x", 1.0, Scenery.FLIP_DURATION / 2.0).set_ease(Tween.EASE_OUT)
	return true


func show_health() -> void:
	_show_health(character, true)


func _show_content(shown_character: Character) -> void:
	visible = shown_character != null
	if shown_character != null:
		_portrait.texture = shown_character.data.portrait
		_name.text = shown_character.data.name
		_show_health(shown_character, false)


# Drained, health just lost shows as damage first.
func _show_health(shown_character: Character, is_drained: bool) -> void:
	if _drain_tween != null:
		_drain_tween.kill()
	var share := clampf(shown_character.health / float(shown_character.data.max_health), 0.0, 1.0)
	_fill.anchor_right = share
	_health_label.text = "%d/%d" % [shown_character.health, shown_character.data.max_health]
	if not is_drained or share >= _damage.anchor_right:
		_damage.anchor_right = share
		return
	_drain_tween = create_tween()
	_drain_tween.tween_property(_damage, "anchor_right", share, DAMAGE_DRAIN_DURATION).set_delay(DAMAGE_HOLD_DURATION)
