class_name StageSet
extends Control
# Everything behind the stage's frame, which a heavy blow shakes while the frame holds still.

const SHAKE_FREQUENCY := 47.0
const SHAKE_X_SHARE := 0.4

var _shake_distance := 0.0
var _shake_tween: Tween

@onready var _home_position := position


func _ready() -> void:
	set_process(false)


func _process(_delta: float) -> void:
	var time := Time.get_ticks_msec() / 1000.0
	var direction := Vector2(SHAKE_X_SHARE * sin(time * SHAKE_FREQUENCY * 0.73), sin(time * SHAKE_FREQUENCY))
	position = _home_position + direction * _shake_distance


func shake(distance: float, duration: float) -> void:
	if _shake_tween != null:
		_shake_tween.kill()
	_shake_distance = distance
	set_process(true)
	_shake_tween = create_tween().set_ignore_time_scale().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_shake_tween.tween_property(self, "_shake_distance", 0.0, duration)
	_shake_tween.tween_callback(_stop_shaking)


func _stop_shaking() -> void:
	set_process(false)
	position = _home_position
