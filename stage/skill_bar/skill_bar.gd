class_name SkillBar
extends Control
# Below the characters' frames: its slots, filled from the left with the selected hero's skills, and Stop or Pass during a fight. It shows what it is told, and only reports its buttons.

signal skill_pressed(skill: SkillData)
# Null once the cursor leaves the skill.
signal skill_hovered(skill: SkillData)
signal stop_pressed

const FONT_SIZE := 48

var _slots: Array[SkillCard] = []
@onready var _stop_button: Button = $StopButton


func _ready() -> void:
	theme = Theme.new()
	theme.default_font_size = FONT_SIZE
	_slots.assign($Slots.get_children())
	for slot in _slots:
		slot.pressed.connect(func() -> void: skill_pressed.emit(slot.skill))
		slot.mouse_entered.connect(func() -> void: skill_hovered.emit(slot.skill))
		slot.mouse_exited.connect(skill_hovered.emit.bind(null))
	_stop_button.pressed.connect(stop_pressed.emit)


# Skills beyond the last slot are not shown.
func show_skills(skills: Array[SkillData], are_enabled: bool, cooldown_beats: Dictionary[SkillData, int]) -> void:
	for index in _slots.size():
		var slot := _slots[index]
		slot.show_skill(skills[index] if index < skills.size() else null)
		var beats: int = cooldown_beats.get(slot.skill, 0)
		slot.disabled = slot.skill == null or not are_enabled or beats > 0
		slot.show_cooldown(beats)


func set_armed_skill(armed_skill: SkillData) -> void:
	for slot in _slots:
		slot.set_armed(slot.skill != null and slot.skill == armed_skill)


# Every slot empty, and no Stop or Pass.
func clear() -> void:
	show_skills([], false, {})
	set_armed_skill(null)
	_stop_button.hide()


func show_pass_button() -> void:
	_stop_button.show()
	_stop_button.text = "Pass"
	_stop_button.set_pressed_no_signal(false)


# Held, it shows a stop on its way.
func show_stop_button(is_held: bool) -> void:
	_stop_button.show()
	_stop_button.text = "Stop"
	_stop_button.set_pressed_no_signal(is_held)
