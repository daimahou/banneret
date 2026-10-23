class_name TimelineMedallion
extends Node2D
# An action on the timeline rope: its actor's portrait in a ring, hung from the rope by its loop.
# Highlighted, its ring brightens; a cross over its face marks an action about to be dropped.

const HIGHLIGHT_TINT := Color(1.8, 1.8, 1.8)

@export var portrait: Texture2D:
	set(value):
		portrait = value
		if is_node_ready():
			_face.texture = value
var knot_rotation := 0.0:
	set(value):
		knot_rotation = value
		if is_node_ready():
			_knot.rotation = value

@onready var _face: TextureRect = $Opening/Face
@onready var _ring: Sprite2D = $Ring
@onready var _knot: Sprite2D = $Knot
@onready var _cross: Node2D = $Cross


func _ready() -> void:
	_face.texture = portrait
	_knot.rotation = knot_rotation


# Whether the point, in global space, is inside its ring's rectangle.
func has_point(global_point: Vector2) -> bool:
	return _ring.get_rect().has_point(_ring.to_local(global_point))


func set_highlighted(is_highlighted: bool) -> void:
	_ring.modulate = HIGHLIGHT_TINT if is_highlighted else Color.WHITE


func set_dropped(is_dropped: bool) -> void:
	_cross.visible = is_dropped
