class_name LevelUpSkillSlot
extends TextureRect
# One skill slot of a hero's build in the level-up: empty, or an owned skill with its perks beside it. It shows what it is told.

const FRAME_TEXTURE := preload("res://level_up/assets/skill_frame.png")
const EMPTY_TEXTURE := preload("res://level_up/assets/skill_slot_empty.png")

var _perk_icons: Array[LevelUpPerkIcon] = []

@onready var _name: Label = $Name


func _ready() -> void:
	_perk_icons.assign($PerkColumn.get_children())


# Null empties the slot.
func show_skill(skill: Skill) -> void:
	texture = EMPTY_TEXTURE if skill == null else FRAME_TEXTURE
	_name.text = "" if skill == null else skill.data.name
	tooltip_text = "" if skill == null else _get_skill_tooltip(skill)
	for index in _perk_icons.size():
		var has_perk := skill != null and index < skill.perks.size()
		_perk_icons[index].show_perk(skill.perks[index] if has_perk else null)


static func _get_skill_tooltip(skill: Skill) -> String:
	var lines := PackedStringArray(["%s · %s" % [skill.data.name, skill.get_rank_title()], skill.get_description()])
	if not skill.perks.is_empty():
		lines.append("Perks: %s" % ", ".join(skill.perks.map(func(perk: SkillPerk) -> String: return perk.name)))
	return "\n".join(lines)
