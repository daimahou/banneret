class_name Nameplate
extends Control
# A character's portrait and name, a health fill and `health/max`, and a pip for each AP it can hold. Each readout shows what it is told, in a style.
# A new character flips the nameplate like a flat: it swaps while edge-on, and hides without one.

# Held, lost and gained show full; lost and gained pulse.
enum Pip { EMPTY, HELD, LOST, GAINED }

# The yellow behind the fill drains down to it, in seconds.
const DAMAGE_DRAIN_DURATION := 0.3

const EMPTY_PIP_TEXTURE := preload("res://art/ui/ap_pip.png")
const FULL_PIP_TEXTURE := preload("res://art/ui/ap_pip_full.png")

# Null while the nameplate is unused.
var character: Character

var _drain_tween: Tween
var _flip_tween: Tween
var _pips: Array[TextureRect] = []
var _pip_pulses: Array[PreviewPulse] = []

@onready var _portrait: TextureRect = $Portrait
@onready var _name: Label = $Name
# Both span the empty bar; their right anchor is the share of health they show.
@onready var _damage: Control = $Empty/Damage
@onready var _fill: Control = $Empty/Fill
# Grows both ways past the bar's height, so its line stays centred on it.
@onready var _health_label: Label = $Empty/HealthLabel
@onready var _health_pulse := PreviewPulse.new(_health_label)


func _ready() -> void:
	_pips.assign($Pips.get_children())
	for pip in _pips:
		_pip_pulses.append(PreviewPulse.new(pip))


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


# Shown in a style, the yellow holds where it stands behind the fill; shown plain, it drains down to the fill, or
# rises to it at once.
func show_health(health: int, max_health: int, style := PreviewPulse.Style.NONE) -> void:
	if _drain_tween != null:
		_drain_tween.kill()
	var share := clampf(health / float(max_health), 0.0, 1.0)
	_fill.anchor_right = share
	_health_label.text = "%d/%d" % [health, max_health]
	_health_pulse.show_style(style)
	if style != PreviewPulse.Style.NONE:
		return
	if share >= _damage.anchor_right:
		_damage.anchor_right = share
		return
	_drain_tween = create_tween()
	_drain_tween.tween_property(_damage, "anchor_right", share, DAMAGE_DRAIN_DURATION)


# One state for each AP the character can hold.
func show_pips(states: Array[Pip]) -> void:
	for index in _pips.size():
		var state := states[index] if index < states.size() else Pip.EMPTY
		_pips[index].visible = index < states.size()
		_pips[index].texture = EMPTY_PIP_TEXTURE if state == Pip.EMPTY else FULL_PIP_TEXTURE
		var style := PreviewPulse.Style.NONE
		if state == Pip.LOST:
			style = PreviewPulse.Style.WORSE
		elif state == Pip.GAINED:
			style = PreviewPulse.Style.BETTER
		_pip_pulses[index].show_style(style)


# The readouts already show the new character; the last one's yellow goes.
func _show_content(shown_character: Character) -> void:
	visible = shown_character != null
	if shown_character != null:
		_portrait.texture = shown_character.data.portrait
		_name.text = shown_character.data.name
	if _drain_tween != null:
		_drain_tween.kill()
	_damage.anchor_right = _fill.anchor_right
