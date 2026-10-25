class_name SkillCard
extends TextureButton
# A skill on the skill bar: its icon, name, a line per effect and its delay. On cooldown it dims, and a clock-wipe over the icon shows the beats left.
# Armed, its ink turns gold; a card that can be clicked takes the hover ink under the cursor.

const PLACEHOLDER_ICON := preload("res://art/ui/skill_placeholder_icon.png")
const COOLDOWN_MODULATE := Color(1.0, 1.0, 1.0, 0.5)
const WIPE_COLOR := Color(0.0, 0.0, 0.0, 0.6)
# Polygon points on a full turn of the wipe.
const WIPE_STEPS := 64
const ARMED_INK_COLOR := Color("b8860b")

var skill: SkillData

var _wipe_fraction := 0.0
var _is_armed := false
var _is_mouse_over := false

@onready var _icon: TextureRect = $Icon
@onready var _name: Label = $Name
@onready var _description: RichTextLabel = $Description
@onready var _delay: Label = $Delay
@onready var _wipe: Control = $Wipe
@onready var _cooldown_label: Label = $Wipe/CooldownLabel
@onready var _armed_ink := Ink.create_color_material(ARMED_INK_COLOR)
@onready var _hover_ink := Ink.create_material(Ink.Highlight.HOVERED)


func _ready() -> void:
	_icon.texture = skill.icon if skill.icon != null else PLACEHOLDER_ICON
	_name.text = skill.name
	var lines := PackedStringArray()
	for effect in skill.effects:
		lines.append(effect.get_description())
	_description.text = "\n".join(lines)
	_delay.text = str(skill.delay)
	_wipe.draw.connect(_draw_wipe)
	mouse_entered.connect(_set_mouse_over.bind(true))
	mouse_exited.connect(_set_mouse_over.bind(false))


func show_cooldown(beats: int) -> void:
	modulate = COOLDOWN_MODULATE if beats > 0 else Color.WHITE
	_wipe.visible = beats > 0
	_cooldown_label.text = str(beats)
	_wipe_fraction = beats / float(skill.cooldown) if beats > 0 else 0.0
	_wipe.queue_redraw()


# Also catches up with `disabled`, which the bar sets before it.
func set_armed(is_armed: bool) -> void:
	_is_armed = is_armed
	_show_ink()


func _set_mouse_over(is_mouse_over: bool) -> void:
	_is_mouse_over = is_mouse_over
	_show_ink()


func _show_ink() -> void:
	if _is_armed:
		material = _armed_ink
	elif _is_mouse_over and not disabled:
		material = _hover_ink
	else:
		material = null


# A sector from twelve o'clock, clockwise, wide enough to reach the corners; the wipe clips it to the icon.
func _draw_wipe() -> void:
	if _wipe_fraction <= 0.0:
		return
	var center := _wipe.size / 2.0
	var radius := center.length()
	var points := PackedVector2Array([center])
	var steps := ceili(_wipe_fraction * WIPE_STEPS)
	for step in steps + 1:
		var angle := -PI / 2.0 + TAU * _wipe_fraction * step / float(steps)
		points.append(center + Vector2.from_angle(angle) * radius)
	_wipe.draw_colored_polygon(points, WIPE_COLOR)
