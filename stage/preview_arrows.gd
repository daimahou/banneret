class_name PreviewArrows
extends Node2D

const WIDTH := 6.0
const POINTS := 24
const HEAD_LENGTH := 28.0
const HEAD_ANGLE := PI / 6.0
const FADE_DURATION := 0.3

var _arrows: Array[Arrow] = []
var _fade: Tween


class Arrow:
	extends RefCounted

	var start: Vector2
	var control: Vector2
	var end: Vector2


func _ready() -> void:
	modulate.a = 0.0


# In global space; none fades the shown ones out.
func show_arrows(arrows: Array[Arrow]) -> void:
	if arrows.is_empty():
		if not _arrows.is_empty():
			_create_fade(0.0).tween_callback(clear)
		return
	_arrows = arrows
	queue_redraw()
	_create_fade(1.0)


func clear() -> void:
	if _fade != null:
		_fade.kill()
	_arrows = []
	modulate.a = 0.0
	queue_redraw()


func _draw() -> void:
	var color := Color(StaggerEffect.STAGGER_COLOR, TimelineRope.MOVED_ALPHA)
	for arrow in _arrows:
		_draw_arrow(to_local(arrow.start), to_local(arrow.control), to_local(arrow.end), color)


# Drawn as strokes that never overlap, so the alpha stays even.
func _draw_arrow(start: Vector2, control: Vector2, end: Vector2, color: Color) -> void:
	var direction := (end - control).normalized()
	var head_depth := HEAD_LENGTH * cos(HEAD_ANGLE)
	var points := PackedVector2Array()
	for index in POINTS + 1:
		var weight := index / float(POINTS)
		var point := start.lerp(control, weight).lerp(control.lerp(end, weight), weight)
		if point.distance_to(end) > head_depth:
			points.append(point)
	points.append(end - direction * head_depth)
	draw_polyline(points, color, WIDTH, true)
	var wing := direction * HEAD_LENGTH
	draw_colored_polygon(PackedVector2Array([end, end - wing.rotated(HEAD_ANGLE), end - wing.rotated(-HEAD_ANGLE)]), color)


func _create_fade(alpha: float) -> Tween:
	if _fade != null:
		_fade.kill()
	_fade = create_tween().set_trans(Tween.TRANS_SINE)
	_fade.tween_property(self, "modulate:a", alpha, FADE_DURATION)
	return _fade
