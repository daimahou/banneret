class_name LevelUpOfferCard
extends TextureButton
# One level-up offer in a hero's column. It shows what it is told, and only reports its press.

const NORMAL_TEXTURE := preload("res://level_up/assets/offer_normal.png")
const SELECTED_TEXTURE := preload("res://level_up/assets/offer_selected.png")

var offer: LevelUpOffer

@onready var _icon: TextureRect = $IconFrame/Icon
@onready var _name: Label = $Name
@onready var _description: Label = $Description
@onready var _check: TextureRect = $Check


func _ready() -> void:
	var skill_data := offer.skill_data
	_icon.texture = skill_data.icon
	_name.text = skill_data.name
	var lines := PackedStringArray(["%d AP, delay %d" % [skill_data.ap_cost, skill_data.delay]])
	if skill_data.cooldown > 0:
		lines[0] += ", cooldown %d" % skill_data.cooldown
	for effect in skill_data.effects:
		lines.append(effect.get_description())
	_description.text = "\n".join(lines)


func set_selected(is_selected: bool) -> void:
	texture_normal = SELECTED_TEXTURE if is_selected else NORMAL_TEXTURE
	_check.visible = is_selected
