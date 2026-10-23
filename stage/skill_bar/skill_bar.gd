class_name SkillBar
extends HBoxContainer
# Below the heroes' health bars: the selected hero's skills, a gap, then Stop or Pass. It shows the player brain's choices, and only reports its buttons.

signal skill_pressed(skill: SkillData)
# Null once the cursor leaves the skill.
signal skill_hovered(skill: SkillData)
signal stop_pressed

const FONT_SIZE := 48
const SKILL_BUTTON_SIZE := Vector2(280.0, 100.0)
const PENDING_BORDER_COLOR := Color("e8c547")
const PENDING_BORDER_WIDTH := 6

var _shown_hero: Character

@onready var _skills: HBoxContainer = $Skills
@onready var _stop_button: Button = $StopButton


func _ready() -> void:
	theme = Theme.new()
	theme.default_font_size = FONT_SIZE
	_stop_button.pressed.connect(stop_pressed.emit)
	hide()


func show_choices(brain: PlayerBrain) -> void:
	show()
	if brain.hero != _shown_hero:
		_shown_hero = brain.hero
		_add_skill_buttons()
	var pending_action := brain.get_pending_action()
	for button: Button in _skills.get_children():
		if button.is_queued_for_deletion():
			continue
		var skill: SkillData = button.get_meta(&"skill")
		button.disabled = not brain.is_waiting()
		button.set_pressed_no_signal(skill == brain.armed_skill)
		_show_pending(button, pending_action != null and pending_action.skill == skill)
	_stop_button.text = "Pass" if brain.is_waiting() else "Stop"
	# Held down from the request until the stop lands.
	_stop_button.set_pressed_no_signal(brain.is_stop_requested() and not brain.is_waiting())


func hide_choices() -> void:
	_shown_hero = null
	hide()

func _add_skill_buttons() -> void:
	for child in _skills.get_children():
		child.queue_free()
	if _shown_hero == null:
		return
	for skill in FightRules.get_usable_skills(_shown_hero):
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

