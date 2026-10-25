class_name SkillCard
extends TextureButton
# One slot of the skill bar, empty or showing a skill as a card: its icon, name, a line per effect and its delay. On cooldown it dims, and a clock-wipe over the icon shows the beats left.
# Armed, its ink turns gold; a card that can be clicked takes the hover ink under the cursor.
# A new skill flips the slot like a flat: it swaps its content while edge-on.

const CARD_TEXTURE := preload("res://art/ui/skill_slot.png")
const EMPTY_TEXTURE := preload("res://art/ui/skill_slot_empty.png")
const PLACEHOLDER_ICON := preload("res://art/ui/skill_placeholder_icon.png")
const COOLDOWN_MODULATE := Color(1.0, 1.0, 1.0, 0.5)
const WIPE_COLOR := Color(0.0, 0.0, 0.0, 0.6)
# Polygon points on a full turn of the wipe.
const WIPE_STEPS := 64
const ARMED_INK_COLOR := Color("b8860b")

# Null while the slot is empty.
var skill: SkillData

var _wipe_fraction := 0.0
var _flip_tween: Tween
var _is_armed := false
var _is_mouse_over := false

@onready var _content: Control = $Content
@onready var _icon: TextureRect = $Content/Icon
@onready var _name: Label = $Content/Name
@onready var _description: RichTextLabel = $Content/Description
@onready var _delay: Label = $Content/Delay
@onready var _wipe: Control = $Content/Wipe
@onready var _cooldown_label: Label = $Content/Wipe/CooldownLabel
@onready var _armed_ink := Ink.create_color_material(ARMED_INK_COLOR)
@onready var _hover_ink := Ink.create_material(Ink.Highlight.HOVERED)


func _ready() -> void:
	_wipe.draw.connect(_draw_wipe)
	mouse_entered.connect(_set_mouse_over.bind(true))
	mouse_exited.connect(_set_mouse_over.bind(false))


# Null empties the slot. Returns whether the slot flips, `delay` from now.
func show_skill(shown_skill: SkillData, cooldown_beats: int, delay: float) -> bool:
	if shown_skill == skill:
		_show_cooldown(shown_skill, cooldown_beats)
		return false
	skill = shown_skill
	if _flip_tween != null:
		_flip_tween.kill()
	pivot_offset = size / 2.0
	_flip_tween = create_tween().set_trans(Scenery.FLIP_TRANSITION)
	_flip_tween.tween_property(self, "scale:x", 0.0, Scenery.FLIP_DURATION / 2.0).set_ease(Tween.EASE_IN).set_delay(delay)
	_flip_tween.tween_callback(_show_content.bind(shown_skill, cooldown_beats))
	_flip_tween.tween_property(self, "scale:x", 1.0, Scenery.FLIP_DURATION / 2.0).set_ease(Tween.EASE_OUT)
	return true


func clear(delay: float) -> bool:
	return show_skill(null, 0, delay)


func _show_content(shown_skill: SkillData, cooldown_beats: int) -> void:
	texture_normal = EMPTY_TEXTURE if shown_skill == null else CARD_TEXTURE
	_content.visible = shown_skill != null
	if shown_skill != null:
		_icon.texture = shown_skill.icon if shown_skill.icon != null else PLACEHOLDER_ICON
		_name.text = shown_skill.name
		var lines := PackedStringArray()
		for effect in shown_skill.effects:
			lines.append(effect.get_description())
		_description.text = "\n".join(lines)
		_delay.text = str(shown_skill.delay)
	_show_cooldown(shown_skill, cooldown_beats)


func _show_cooldown(shown_skill: SkillData, cooldown_beats: int) -> void:
	modulate = COOLDOWN_MODULATE if cooldown_beats > 0 else Color.WHITE
	_wipe.visible = cooldown_beats > 0
	_cooldown_label.text = str(cooldown_beats)
	_wipe_fraction = cooldown_beats / float(shown_skill.cooldown) if cooldown_beats > 0 else 0.0
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
