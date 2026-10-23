class_name TimelineMedallion
extends Node2D
# An action on the timeline rope: its actor's portrait in a ring, hung from the rope by its loop.

@export var portrait: Texture2D
var knot_rotation := 0.0:
	set(value):
		knot_rotation = value
		if is_node_ready():
			_knot.rotation = value

@onready var _face: TextureRect = $Opening/Face
@onready var _knot: Sprite2D = $Knot


func _ready() -> void:
	_face.texture = portrait
	_knot.rotation = knot_rotation
