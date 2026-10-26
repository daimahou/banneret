class_name ImpactBurst
extends Node2D
# A cut-out star that pops where a heavy blow lands, throws paper flecks, and fades.

const SPIKE_COUNT := 11
const RADIUS := 190.0
const INNER_RADIUS_SHARE := 0.5
const CORE_RADIUS_SHARE := 0.45
const SPIKE_JITTER := 0.3
const OUTLINE_WIDTH := 9.0

const PAPER_COLOR := Color("f2ead8")
const INK_COLOR := Color("1e1b18")
const CORE_COLOR := Color("c0392b")

const POP_DURATION := 0.14
const HOLD_DURATION := 0.2
const FADE_DURATION := 0.3

const FLECK_COUNT := 22
const FLECK_LIFETIME := 0.6
const FLECK_SPEED_MIN := 500.0
const FLECK_SPEED_MAX := 1200.0
const FLECK_GRAVITY := 2800.0
const FLECK_SIZE_MIN := 7.0
const FLECK_SIZE_MAX := 16.0
const FLECK_SPIN := 900.0

var _star_points := _create_star_points()
var _radius := 0.0


func _ready() -> void:
	rotation = randf() * TAU
	add_child(_create_flecks())
	var tween := create_tween().set_ignore_time_scale()
	tween.tween_method(_set_radius, 0.0, RADIUS, POP_DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(HOLD_DURATION)
	tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)


func _draw() -> void:
	if _radius < 1.0:
		return
	_draw_star(_radius, PAPER_COLOR)
	_draw_star(_radius * CORE_RADIUS_SHARE, CORE_COLOR)


func _draw_star(radius: float, fill_color: Color) -> void:
	var points := PackedVector2Array()
	for point in _star_points:
		points.append(point * radius)
	draw_colored_polygon(points, fill_color)
	points.append(points[0])
	draw_polyline(points, INK_COLOR, OUTLINE_WIDTH, true)


func _set_radius(radius: float) -> void:
	_radius = radius
	queue_redraw()


static func _create_star_points() -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in SPIKE_COUNT * 2:
		var angle := TAU * index / (SPIKE_COUNT * 2)
		var length := 1.0 if index % 2 == 0 else INNER_RADIUS_SHARE
		points.append(Vector2.from_angle(angle) * length * randf_range(1.0 - SPIKE_JITTER, 1.0))
	return points


func _create_flecks() -> CPUParticles2D:
	var colors := Gradient.new()
	colors.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	colors.set_color(0, INK_COLOR)
	colors.set_color(1, PAPER_COLOR)
	colors.add_point(0.5, PAPER_COLOR)
	var flecks := CPUParticles2D.new()
	flecks.one_shot = true
	flecks.explosiveness = 1.0
	flecks.amount = FLECK_COUNT
	flecks.lifetime = FLECK_LIFETIME
	flecks.spread = 180.0
	flecks.initial_velocity_min = FLECK_SPEED_MIN
	flecks.initial_velocity_max = FLECK_SPEED_MAX
	flecks.gravity = Vector2(0.0, FLECK_GRAVITY)
	flecks.scale_amount_min = FLECK_SIZE_MIN
	flecks.scale_amount_max = FLECK_SIZE_MAX
	flecks.angular_velocity_min = -FLECK_SPIN
	flecks.angular_velocity_max = FLECK_SPIN
	flecks.color_initial_ramp = colors
	flecks.emitting = true
	return flecks
