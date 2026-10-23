class_name FightControls
extends HBoxContainer
# The fight's plain controls, below the heroes' health bars: the selected hero's skills, a gap, then Stop or Pass. It also takes the fight's keys.
# It changes nothing itself: it makes the player brain's calls, and shows its choices.

const FONT_SIZE := 48
const SKILL_BUTTON_SIZE := Vector2(280.0, 100.0)
const PENDING_BORDER_COLOR := Color("e8c547")
const PENDING_BORDER_WIDTH := 6

var _player_brain: PlayerBrain
var _shown_hero: Character

@onready var _skills: HBoxContainer = $Skills
@onready var _stop_button: Button = $StopButton


func _ready() -> void:
	theme = Theme.new()
	theme.default_font_size = FONT_SIZE
	_stop_button.pressed.connect(_on_stop_button_pressed)
	hide()


func show_choices(brain: PlayerBrain) -> void:
	hide_choices()
	_player_brain = brain
	brain.choices_changed.connect(_show_choices)
	show()
	_show_choices()


func hide_choices() -> void:
	if _player_brain != null:
		_player_brain.choices_changed.disconnect(_show_choices)
		_player_brain = null
	_shown_hero = null
	hide()


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if _player_brain == null or key == null or not key.pressed or key.echo:
		return
	match key.keycode:
		KEY_SPACE:
			_player_brain.request_stop()
		KEY_P:
			_player_brain.pass_stop()
		KEY_TAB:
			_player_brain.cycle_hero(-1 if key.shift_pressed else 1)
		KEY_ESCAPE:
			_player_brain.disarm()
		KEY_ENTER, KEY_KP_ENTER:
			_player_brain.confirm()
		KEY_LEFT:
			_player_brain.cycle_aim(-1)
		KEY_RIGHT:
			_player_brain.cycle_aim(1)
		_:
			if key.keycode < KEY_1 or key.keycode > KEY_9:
				return
			_player_brain.press_number(key.keycode - KEY_1)
	get_viewport().set_input_as_handled()


func _show_choices() -> void:
	if _player_brain.hero != _shown_hero:
		_shown_hero = _player_brain.hero
		_add_skill_buttons()
	var pending_action := _player_brain.get_pending_action()
	for button: Button in _skills.get_children():
		if button.is_queued_for_deletion():
			continue
		var skill: SkillData = button.get_meta(&"skill")
		button.disabled = not _player_brain.is_waiting()
		button.set_pressed_no_signal(skill == _player_brain.armed_skill)
		_show_pending(button, pending_action != null and pending_action.skill == skill)
	_stop_button.text = "Pass" if _player_brain.is_waiting() else "Stop"
	# Held down from the request until the stop lands.
	_stop_button.set_pressed_no_signal(_player_brain.is_stop_requested() and not _player_brain.is_waiting())


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
		button.pressed.connect(_player_brain.arm_skill.bind(skill))
		button.mouse_entered.connect(_player_brain.hover_skill.bind(skill))
		button.mouse_exited.connect(_player_brain.hover_skill.bind(null))
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


func _on_stop_button_pressed() -> void:
	if _player_brain.is_waiting():
		_player_brain.pass_stop()
	else:
		_player_brain.request_stop()
	_show_choices()
