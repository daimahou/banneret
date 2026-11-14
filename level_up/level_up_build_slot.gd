class_name LevelUpBuildSlot
extends HBoxContainer
# One skill or talent slot of a hero's build in the level-up: empty, or an owned skill or talent with its perks beside it. It shows what it is told.

const FRAME_TEXTURE := preload("res://level_up/assets/skill_frame.png")
const EMPTY_TEXTURE := preload("res://level_up/assets/skill_slot_empty.png")

var _perk_icons: Array[LevelUpPerkIcon] = []

@onready var _frame: TextureRect = $Frame
@onready var _name: Label = $Frame/Name


func _ready() -> void:
	_perk_icons.assign($PerkColumn.get_children())


func _make_custom_tooltip(for_text: String) -> Object:
	return LevelUpTooltip.new(for_text)


# Null empties the slot.
func show_skill(skill: Skill) -> void:
	if skill == null:
		_show_empty()
	else:
		_show_owned(skill.data.name, skill.get_rank_title(), skill.get_description(), skill.perks)


# Null empties the slot.
func show_talent(talent: Talent) -> void:
	if talent == null:
		_show_empty()
	else:
		_show_owned(talent.data.name, talent.get_rank_title(), talent.get_description(), talent.perks)


func _show_empty() -> void:
	_frame.texture = EMPTY_TEXTURE
	_name.text = ""
	tooltip_text = ""
	for perk_icon in _perk_icons:
		perk_icon.show_perk(null)


func _show_owned(owned_name: String, rank_title: String, description: String, perks: Array) -> void:
	_frame.texture = FRAME_TEXTURE
	_name.text = owned_name
	var lines := PackedStringArray(["%s · %s" % [owned_name, rank_title]])
	if not description.is_empty():
		lines.append(description)
	if not perks.is_empty():
		lines.append("Perks: %s" % ", ".join(perks.map(func(perk: Perk) -> String: return perk.name)))
	tooltip_text = "\n".join(lines)
	for index in _perk_icons.size():
		_perk_icons[index].show_perk(perks[index] if index < perks.size() else null)
