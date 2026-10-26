class_name Nameplate
extends Control
# A character's portrait, name, health and AP. Each readout shows what it is told, in a style.

# Held, lost and gained show full; lost and gained pulse.
enum Pip { EMPTY, HELD, LOST, GAINED }

# The yellow behind the fill drains down to it, in seconds.
const DAMAGE_DRAIN_DURATION := 0.3

const EMPTY_PIP_TEXTURE := preload("res://art/ui/ap_pip.png")
const FULL_PIP_TEXTURE := preload("res://art/ui/ap_pip_full.png")

# Null while the nameplate is unused.
var character: Character

var _is_awaiting_swap := false
var _health := 0
var _max_health := 1
var _health_style := PreviewPulse.Style.NONE
var _pip_states: Array[Pip] = []
var _drain_tween: Tween
var _drain_share := 0.0
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
	_is_awaiting_swap = true
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


func show_health(health: int, max_health: int, style := PreviewPulse.Style.NONE) -> void:
	_health = health
	_max_health = max_health
	_health_style = style
	if not _is_awaiting_swap:
		_show_health()


# One state for each AP the character can hold.
func show_pips(states: Array[Pip]) -> void:
	_pip_states = states
	if not _is_awaiting_swap:
		_show_pips()


func _show_health() -> void:
	var share := clampf(_health / float(_max_health), 0.0, 1.0)
	_fill.anchor_right = share
	_health_label.text = "%d/%d" % [_health, _max_health]
	_health_pulse.show_style(_health_style)
	if _health_style != PreviewPulse.Style.NONE:
		return
	var is_draining := _drain_tween != null and _drain_tween.is_running()
	if is_draining and share == _drain_share:
		return
	if is_draining:
		_drain_tween.kill()
	if share >= _damage.anchor_right:
		_damage.anchor_right = share
		return
	_drain_share = share
	_drain_tween = create_tween()
	_drain_tween.tween_property(_damage, "anchor_right", share, DAMAGE_DRAIN_DURATION)


func _show_pips() -> void:
	for index in _pips.size():
		var state := _pip_states[index] if index < _pip_states.size() else Pip.EMPTY
		_pips[index].visible = index < _pip_states.size()
		_pips[index].texture = EMPTY_PIP_TEXTURE if state == Pip.EMPTY else FULL_PIP_TEXTURE
		var style := PreviewPulse.Style.NONE
		if state == Pip.LOST:
			style = PreviewPulse.Style.WORSE
		elif state == Pip.GAINED:
			style = PreviewPulse.Style.BETTER
		_pip_pulses[index].show_style(style)


func _show_content(shown_character: Character) -> void:
	_is_awaiting_swap = false
	visible = shown_character != null
	if shown_character == null:
		return
	_portrait.texture = shown_character.data.portrait
	_name.text = shown_character.data.name
	if _drain_tween != null:
		_drain_tween.kill()
	_damage.anchor_right = 0.0
	_show_health()
	_show_pips()
