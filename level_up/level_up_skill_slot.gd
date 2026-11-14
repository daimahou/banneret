class_name LevelUpSkillSlot
extends TextureRect
# One skill slot of a hero's build in the level-up: empty, or an owned skill. It shows what it is told.

const FRAME_TEXTURE := preload("res://level_up/assets/skill_frame.png")
const EMPTY_TEXTURE := preload("res://level_up/assets/skill_slot_empty.png")

@onready var _name: Label = $Name


# Null empties the slot.
func show_skill(skill: Skill) -> void:
	texture = EMPTY_TEXTURE if skill == null else FRAME_TEXTURE
	tooltip_text = "" if skill == null else skill.data.name
	_name.text = tooltip_text
