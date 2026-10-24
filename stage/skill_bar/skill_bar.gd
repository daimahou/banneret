class_name SkillBar
extends HBoxContainer
# Below the heroes' health bars: the selected hero's skills, a gap, then Stop or Pass. It shows what it is told, and only reports its buttons.

signal skill_pressed(skill: SkillData)
# Null once the cursor leaves the skill.
signal skill_hovered(skill: SkillData)
signal stop_pressed

const FONT_SIZE := 48
const SKILL_BUTTON_SIZE := Vector2(280.0, 100.0)
const PENDING_BORDER_COLOR := Color("e8c547")
const PENDING_BORDER_WIDTH := 6
const COOLDOWN_ALPHA := 0.5

var _shown_skills: Array[SkillData] = []

@onready var _skills: HBoxContainer = $Skills
@onready var _stop_button: Button = $StopButton


func _ready() -> void:
	theme = Theme.new()
	theme.default_font_size = FONT_SIZE
	_stop_button.pressed.connect(stop_pressed.emit)
	hide()


func show_skills(skills: Array[SkillData], are_enabled: bool, cooldown_beats: Dictionary[SkillData, int]) -> void:
	show()
	if skills != _shown_skills:
		_shown_skills = skills
		_add_skill_buttons()
	for button in _get_skill_buttons():
		var skill: SkillData = button.get_meta(&"skill")
		var beats: int = cooldown_beats.get(skill, 0)
		button.disabled = not are_enabled or beats > 0
		button.modulate.a = COOLDOWN_ALPHA if beats > 0 else 1.0
		button.text = skill.name if beats == 0 else "%s (%d)" % [skill.name, beats]


func set_armed_skill(armed_skill: SkillData) -> void:
	for button in _get_skill_buttons():
		button.set_pressed_no_signal(button.get_meta(&"skill") == armed_skill)


func set_pending_skill(pending_skill: SkillData) -> void:
	for button in _get_skill_buttons():
		_show_pending(button, button.get_meta(&"skill") == pending_skill)


func show_pass_button() -> void:
	_stop_button.text = "Pass"
	_stop_button.set_pressed_no_signal(false)


# Held, it shows a stop on its way.
func show_stop_button(is_held: bool) -> void:
	_stop_button.text = "Stop"
	_stop_button.set_pressed_no_signal(is_held)


func _get_skill_buttons() -> Array[Button]:
	var buttons: Array[Button] = []
	for button: Button in _skills.get_children():
		if not button.is_queued_for_deletion():
			buttons.append(button)
	return buttons


func _add_skill_buttons() -> void:
	for child in _skills.get_children():
		child.queue_free()
	for skill in _shown_skills:
		var button := Button.new()
		button.text = skill.name
		button.custom_minimum_size = SKILL_BUTTON_SIZE
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		button.tooltip_text = _describe_skill(skill)
		button.set_meta(&"skill", skill)
		button.pressed.connect(skill_pressed.emit.bind(skill))
		button.mouse_entered.connect(skill_hovered.emit.bind(skill))
		button.mouse_exited.connect(skill_hovered.emit.bind(null))
		_skills.add_child(button)


func _show_pending(button: Button, is_pending: bool) -> void:
	for style_name: StringName in [&"normal", &"hover", &"pressed", &"disabled"]:
		if not is_pending:
			button.remove_theme_stylebox_override(style_name)
			continue
		var style: StyleBox = button.get_theme_stylebox(style_name).duplicate()
		var flat := style as StyleBoxFlat
		if flat != null:
			flat.border_color = PENDING_BORDER_COLOR
			flat.set_border_width_all(PENDING_BORDER_WIDTH)
		button.add_theme_stylebox_override(style_name, style)


# Like a card: the name, the delay, a line per effect.
func _describe_skill(skill: SkillData) -> String:
	var lines: Array[String] = [skill.name, "Delay: %d" % skill.delay]
	for effect in skill.effects:
		lines.append(effect.get_description())
	return "\n".join(PackedStringArray(lines))
