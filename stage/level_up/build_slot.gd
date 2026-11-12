class_name BuildSlot
extends Control
# One slot of a hero's build: an owned skill with a socket for each of its upgrades, or an empty slot.

const FRAME_TEXTURE := preload("res://stage/level_up/assets/skill_frame.png")
const EMPTY_TEXTURE := preload("res://stage/level_up/assets/skill_slot_empty.png")
const SOCKET_COUNT := 2

@onready var _frame: TextureRect = $Frame
@onready var _monogram: Label = $Frame/Monogram
@onready var _sockets: Array[TalentIcon] = [$Socket1, $Socket2]


# Null shows an empty slot.
func show_owned(owned: OwnedSkill, hero: Character, bag: Array[Learnable]) -> void:
	_frame.texture = EMPTY_TEXTURE if owned == null else FRAME_TEXTURE
	_monogram.text = "" if owned == null else LevelUpText.get_monogram(owned.skill.name)
	_frame.tooltip_text = "" if owned == null else LevelUpText.get_owned_tooltip(owned, hero)
	for index in SOCKET_COUNT:
		var talent: Talent = null
		if owned != null and index < owned.talents.size():
			talent = owned.talents[index]
		var tooltip := "" if talent == null else LevelUpText.get_talent_tooltip(talent, bag)
		_sockets[index].show_talent(talent, tooltip)
		_sockets[index].visible = owned == null or index < owned.skill.upgrades.size()
