class_name Puppet
extends Node2D

# Sway, in radians and seconds.
const SWAY_ANGLE := 0.03
const SWAY_PERIOD := 2.4

# Drawn with its stick foot on the origin, the point it sways about.
@export var texture: Texture2D

# A phase of its own, so puppets don't rock in step.
var _sway_phase := randf() * TAU

@onready var _sprite: Sprite2D = $Sprite


func _ready() -> void:
	_sprite.texture = texture
	_sprite.offset.y = -texture.get_height() / 2.0
	create_tween().set_loops().tween_method(_set_sway, 0.0, TAU, SWAY_PERIOD)


func _set_sway(cycle_angle: float) -> void:
	rotation = SWAY_ANGLE * sin(cycle_angle + _sway_phase)
