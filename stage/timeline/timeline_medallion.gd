class_name TimelineMedallion
extends Node2D
# An action on the timeline rope: its actor's portrait in a ring, hung from the rope by its loop.
# Highlighted, its ring takes the hover ink; a cross over its face marks it cancelled.
# A moved ghost hangs in its own ring.

const RING_TEXTURE := preload("res://art/timeline/medallion.png")
const MOVED_RING_TEXTURE := preload("res://art/timeline/medallion_moved.png")

@export var portrait: Texture2D:
	set(value):
		portrait = value
		if is_node_ready():
			_face.texture = value
var is_moved := false:
	set(value):
		is_moved = value
		if is_node_ready():
			_ring.texture = MOVED_RING_TEXTURE if value else RING_TEXTURE
var knot_rotation := 0.0:
	set(value):
		knot_rotation = value
		if is_node_ready():
			_knot.rotation = value

@onready var _face: TextureRect = $Opening/Face
@onready var _ring: Sprite2D = $Ring
@onready var _knot: Sprite2D = $Knot
@onready var _cross: Node2D = $Cross
@onready var _highlight_material := Ink.create_material(Ink.Highlight.HOVERED)


func _ready() -> void:
	_face.texture = portrait
	_ring.texture = MOVED_RING_TEXTURE if is_moved else RING_TEXTURE
	_knot.rotation = knot_rotation


# The ring's rectangle, not its pixels.
func has_point(global_point: Vector2) -> bool:
	return _ring.get_rect().has_point(_ring.to_local(global_point))


# Where the bottom of its ring hangs, in its parent's space.
func get_ring_bottom() -> Vector2:
	var ring_rect := _ring.get_rect()
	return position + _ring.position + Vector2(ring_rect.get_center().x, ring_rect.end.y)


func set_highlighted(is_highlighted: bool) -> void:
	_ring.material = _highlight_material if is_highlighted else null


func set_cancelled(is_cancelled: bool) -> void:
	_cross.visible = is_cancelled
