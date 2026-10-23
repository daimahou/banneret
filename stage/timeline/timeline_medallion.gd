class_name TimelineMedallion
extends Node2D
# An action on the timeline rope: its actor's portrait in a ring, hung from the rope by its loop.

@export var portrait: Texture2D

@onready var _face: TextureRect = $Opening/Face


func _ready() -> void:
	_face.texture = portrait
