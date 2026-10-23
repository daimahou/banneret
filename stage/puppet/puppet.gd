class_name Puppet
extends Node2D

# Sway, in radians and seconds.
const SWAY_ANGLE := 0.03
const SWAY_PERIOD := 2.4

# A hop, a raise and a bob down under a press, in design units and seconds.
const HOP_HEIGHT := 28.0
const HOP_PERIOD := 0.45
const RAISE_HEIGHT := 120.0
const RAISE_DURATION := 0.3
const BOB_DEPTH := 18.0
const BOB_DURATION := 0.08

# A shake under a blow, in design units and seconds.
const SHAKE_DISTANCE := 18.0
const SHAKE_COUNT := 3
const SHAKE_DURATION := 0.3

# A fall sinks it out of sight below the stage front, in seconds.
const SINK_DURATION := 0.7

enum Stance { SWAY, HOP, RAISED }

# Drawn with its stick foot on the origin, the point it sways about.
@export var texture: Texture2D

# A phase of its own, so puppets don't rock in step.
var _sway_phase := randf() * TAU

var _stance := Stance.SWAY
var _hop_time := 0.0
var _raise := 0.0
var _raise_tween: Tween
var _bob := 0.0

@onready var _sprite: Sprite2D = $Sprite


func _ready() -> void:
	_sprite.texture = texture
	_sprite.offset.y = -texture.get_height() / 2.0
	create_tween().set_loops().tween_method(_set_sway, 0.0, TAU, SWAY_PERIOD)


func _process(delta: float) -> void:
	var hop := 0.0
	if _stance == Stance.HOP:
		_hop_time += delta
		hop = HOP_HEIGHT * absf(sin(_hop_time * PI / HOP_PERIOD))
	_sprite.position.y = _bob - _raise - hop


func get_height() -> float:
	return texture.get_height()


# Whether the point, in global space, is inside its sprite's rectangle.
func has_point(global_point: Vector2) -> bool:
	return _sprite.get_rect().has_point(_sprite.to_local(global_point))


func set_stance(new_stance: Stance) -> void:
	if new_stance == _stance:
		return
	_stance = new_stance
	_hop_time = 0.0
	if _raise_tween != null:
		_raise_tween.kill()
	_raise_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_raise_tween.tween_property(self, "_raise", RAISE_HEIGHT if new_stance == Stance.RAISED else 0.0, RAISE_DURATION)


# Null keeps the ink's own color.
func set_ink(ink_material: ShaderMaterial) -> void:
	_sprite.material = ink_material


# Pressed down, like a button.
func bob() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "_bob", BOB_DEPTH, BOB_DURATION).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "_bob", 0.0, BOB_DURATION).set_ease(Tween.EASE_IN)


func shake() -> void:
	var tween := create_tween()
	var step := SHAKE_DURATION / (SHAKE_COUNT * 2 + 1)
	for index in SHAKE_COUNT:
		tween.tween_property(_sprite, "position:x", SHAKE_DISTANCE, step)
		tween.tween_property(_sprite, "position:x", -SHAKE_DISTANCE, step)
	tween.tween_property(_sprite, "position:x", 0.0, step)


func sink() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", position.y + get_height(), SINK_DURATION)
	await tween.finished


# Only a swaying puppet rocks; the others stand upright.
func _set_sway(cycle_angle: float) -> void:
	rotation = SWAY_ANGLE * sin(cycle_angle + _sway_phase) if _stance == Stance.SWAY else 0.0
