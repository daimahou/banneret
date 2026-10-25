class_name Nameplate
extends Control
# A character's portrait and name, a health fill and `health/max`, and a pip for each AP it can hold, filled for each it holds.
# Beside the fight it shows the preview: the red fill, the label and the pips held are the preview's, the yellow behind the red the fight's. A readout the preview changes pulses.
# A new character flips the nameplate like a flat: it swaps while edge-on, and hides without one.

# The yellow drains down to the red as the fight catches up with the preview, in seconds.
const DAMAGE_DRAIN_DURATION := 0.3

const EMPTY_PIP_TEXTURE := preload("res://art/ui/ap_pip.png")
const FULL_PIP_TEXTURE := preload("res://art/ui/ap_pip_full.png")

# Null while the nameplate is unused.
var character: Character

var _drain_tween: Tween
var _flip_tween: Tween
var _pips: Array[TextureRect] = []
var _pip_marks: Array[PreviewMark] = []

@onready var _portrait: TextureRect = $Portrait
@onready var _name: Label = $Name
# Both span the empty bar; their right anchor is the share of health they show.
@onready var _damage: Control = $Empty/Damage
@onready var _fill: Control = $Empty/Fill
# Grows both ways past the bar's height, so its line stays centred on it.
@onready var _health_label: Label = $Empty/HealthLabel
@onready var _health_mark := PreviewMark.new(_health_label)


func _ready() -> void:
	_pips.assign($Pips.get_children())
	for pip in _pips:
		_pip_marks.append(PreviewMark.new(pip))


# Null hides the nameplate. Returns whether the nameplate flips, `delay` from now.
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


func clear(delay: float) -> bool:
	return show_character(null, delay)


# The character as the preview holds it.
func show_preview(previewed: Character) -> void:
	_show_health(character, previewed, true)
	_show_ap(character, previewed)


func _show_content(shown_character: Character) -> void:
	visible = shown_character != null
	if shown_character != null:
		_portrait.texture = shown_character.data.portrait
		_name.text = shown_character.data.name
		_show_health(shown_character, shown_character, false)
		_show_ap(shown_character, shown_character)


# A pip held in one and not the other shows full, and pulses.
func _show_ap(shown_character: Character, previewed: Character) -> void:
	for index in _pips.size():
		var is_held := index < shown_character.ap
		var is_held_previewed := index < previewed.ap
		_pips[index].visible = index < shown_character.data.max_ap
		_pips[index].texture = FULL_PIP_TEXTURE if is_held or is_held_previewed else EMPTY_PIP_TEXTURE
		_pip_marks[index].show_gain(int(is_held_previewed) - int(is_held))


# Drained, the yellow goes down to the fight's health over time, rather than at once.
func _show_health(shown_character: Character, previewed: Character, is_drained: bool) -> void:
	if _drain_tween != null:
		_drain_tween.kill()
	var share := _get_health_share(shown_character)
	_fill.anchor_right = _get_health_share(previewed)
	_health_label.text = "%d/%d" % [previewed.health, previewed.data.max_health]
	_health_mark.show_gain(previewed.health - shown_character.health)
	if not is_drained or share >= _damage.anchor_right:
		_damage.anchor_right = share
		return
	_drain_tween = create_tween()
	_drain_tween.tween_property(_damage, "anchor_right", share, DAMAGE_DRAIN_DURATION)


static func _get_health_share(shown_character: Character) -> float:
	return clampf(shown_character.health / float(shown_character.data.max_health), 0.0, 1.0)
