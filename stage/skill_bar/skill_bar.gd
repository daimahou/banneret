class_name SkillBar
extends Control
# One character's skills, and Stop or Pass during a fight. It shows what it is told, and only reports its buttons.

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


func show_skills(skills: Array[SkillData]) -> void:
	var flip_delay := 0.0
	for index in _slots.size():
		var skill: SkillData = skills[index] if index < skills.size() else null
		if _slots[index].show_skill(skill, flip_delay):
			flip_delay += Scenery.FLIP_STAGGER


func show_cooldown(slot_index: int, beats: int, style := PreviewPulse.Style.NONE) -> void:
	if slot_index < _slots.size():
		_slots[slot_index].show_cooldown(beats, style)


func set_usable(usable: Array[SkillData]) -> void:
	for slot in _slots:
		slot.disabled = slot.skill not in usable
		# An empty slot greys with the bar, not with its own disabled.
		slot.set_greyed(usable.is_empty() if slot.skill == null else slot.disabled)


func set_armed_skill(armed_skill: SkillData) -> void:
	for slot in _slots:
		slot.set_armed(slot.skill != null and slot.skill == armed_skill)


func clear() -> void:
	var flip_delay := 0.0
	for slot in _slots:
		if slot.clear(flip_delay):
			flip_delay += Scenery.FLIP_STAGGER
		slot.disabled = true
		slot.set_greyed(false)
		slot.set_armed(false)
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
