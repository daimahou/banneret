class_name SkillBar
extends Control
# Below the characters' frames: a card for each of the selected hero's skills, empty slots after them, and Stop or Pass. It shows what it is told, and only reports its buttons.

signal skill_pressed(skill: SkillData)
# Null once the cursor leaves the skill.
signal skill_hovered(skill: SkillData)
signal stop_pressed

const FONT_SIZE := 48
const SLOT_COUNT := 5

const SKILL_CARD_SCENE := preload("res://stage/skill_bar/skill_card.tscn")
const EMPTY_SLOT_TEXTURE := preload("res://art/ui/skill_slot_empty.png")

var _shown_skills: Array[SkillData] = []

@onready var _slots: HBoxContainer = $Slots
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
		_add_slots()
	for card in _get_skill_cards():
		var beats: int = cooldown_beats.get(card.skill, 0)
		card.disabled = not are_enabled or beats > 0
		card.show_cooldown(beats)


func set_armed_skill(armed_skill: SkillData) -> void:
	for card in _get_skill_cards():
		card.set_armed(card.skill == armed_skill)


func show_pass_button() -> void:
	_stop_button.text = "Pass"
	_stop_button.set_pressed_no_signal(false)


# Held, it shows a stop on its way.
func show_stop_button(is_held: bool) -> void:
	_stop_button.text = "Stop"
	_stop_button.set_pressed_no_signal(is_held)


func _get_skill_cards() -> Array[SkillCard]:
	var cards: Array[SkillCard] = []
	for child in _slots.get_children():
		if child is SkillCard and not child.is_queued_for_deletion():
			cards.append(child)
	return cards


func _add_slots() -> void:
	for child in _slots.get_children():
		child.queue_free()
	for skill in _shown_skills:
		_add_skill_card(skill)
	for index in range(_shown_skills.size(), SLOT_COUNT):
		var empty_slot := TextureRect.new()
		empty_slot.texture = EMPTY_SLOT_TEXTURE
		empty_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_slots.add_child(empty_slot)


func _add_skill_card(skill: SkillData) -> void:
	var card: SkillCard = SKILL_CARD_SCENE.instantiate()
	card.skill = skill
	card.pressed.connect(skill_pressed.emit.bind(skill))
	card.mouse_entered.connect(skill_hovered.emit.bind(skill))
	card.mouse_exited.connect(skill_hovered.emit.bind(null))
	_slots.add_child(card)
