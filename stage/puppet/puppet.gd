class_name Puppet
extends Node2D

const SWAY_ANGLE := 0.03
const SWAY_PERIOD := 2.4

const HOP_HEIGHT := 18.0
const HOP_PERIOD := 0.45
const RAISE_HEIGHT := 60.0
const RAISE_DURATION := 0.3
const BOB_DEPTH := 18.0
const BOB_DURATION := 0.08

const SHAKE_DISTANCE := 18.0
const SHAKE_COUNT := 3
const SHAKE_DURATION := 0.3

const SINK_DURATION := 0.7

const WIND_UP_LEAN := 0.32
const WIND_UP_LIFT := 56.0
const SWING_LEAN := 0.34
const REEL_LEAN := 0.28
const REEL_DISTANCE := 80.0
const REEL_OUT_DURATION := 0.12
const REEL_DURATION := 0.8
const FLASH_DURATION := 0.18

enum Stance { SWAY, HOP, RAISED }

@export var texture: Texture2D

var _sway_phase := randf() * TAU

var _stance := Stance.SWAY
var _hop_time := 0.0
var _raise := 0.0
var _raise_tween: Tween
var _bob := 0.0
var _bob_tween: Tween
var _is_pressed := false
var _lift := 0.0
var _pose_tween: Tween
var _sprite_material: ShaderMaterial

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
	_sprite.position.y = _bob - _raise - hop - _lift


func get_height() -> float:
	return texture.get_height()


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


func set_sprite_material(sprite_material: ShaderMaterial) -> void:
	_sprite_material = sprite_material
	_sprite.material = sprite_material


func flash(flash_material: ShaderMaterial) -> void:
	_sprite.material = flash_material
	var tween := create_tween().set_ignore_time_scale()
	tween.tween_interval(FLASH_DURATION)
	tween.tween_callback(func() -> void: _sprite.material = _sprite_material)


func bob() -> void:
	var tween := _create_bob_tween()
	tween.tween_property(self, "_bob", BOB_DEPTH, BOB_DURATION).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "_bob", BOB_DEPTH if _is_pressed else 0.0, BOB_DURATION).set_ease(Tween.EASE_IN)


func set_pressed(is_pressed: bool) -> void:
	if is_pressed == _is_pressed:
		return
	_is_pressed = is_pressed
	_create_bob_tween().tween_property(self, "_bob", BOB_DEPTH if is_pressed else 0.0, BOB_DURATION).set_ease(Tween.EASE_OUT)


func _create_bob_tween() -> Tween:
	if _bob_tween != null:
		_bob_tween.kill()
	_bob_tween = create_tween().set_trans(Tween.TRANS_SINE)
	return _bob_tween


func shake() -> void:
	var tween := create_tween()
	var step := SHAKE_DURATION / (SHAKE_COUNT * 2 + 1)
	for index in SHAKE_COUNT:
		tween.tween_property(_sprite, "position:x", SHAKE_DISTANCE, step)
		tween.tween_property(_sprite, "position:x", -SHAKE_DISTANCE, step)
	tween.tween_property(_sprite, "position:x", 0.0, step)


func wind_up(facing: float, duration: float) -> void:
	var tween := _create_pose_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(_sprite, "rotation", -facing * WIND_UP_LEAN, duration)
	tween.tween_property(self, "_lift", WIND_UP_LIFT, duration)


func swing(facing: float, duration: float) -> void:
	var tween := _create_pose_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_property(_sprite, "rotation", facing * SWING_LEAN, duration)
	tween.tween_property(self, "_lift", 0.0, duration)


func straighten(duration: float) -> void:
	var tween := _create_pose_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_sprite, "rotation", 0.0, duration)
	tween.tween_property(self, "_lift", 0.0, duration)


func reel(facing: float) -> void:
	_sprite.rotation = facing * REEL_LEAN
	var tween := _create_pose_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_sprite, "rotation", 0.0, REEL_DURATION)
	var knocked_x := position.x + facing * REEL_DISTANCE
	var knock := create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	knock.tween_property(self, "position:x", knocked_x, REEL_OUT_DURATION)
	knock.tween_property(self, "position:x", position.x, REEL_DURATION).set_trans(Tween.TRANS_SINE)


func _create_pose_tween() -> Tween:
	if _pose_tween != null:
		_pose_tween.kill()
	_pose_tween = create_tween().set_parallel()
	return _pose_tween


func sink() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", position.y + get_height(), SINK_DURATION)
	await tween.finished


func _set_sway(cycle_angle: float) -> void:
	rotation = SWAY_ANGLE * sin(cycle_angle + _sway_phase) if _stance == Stance.SWAY else 0.0
