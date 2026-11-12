class_name TalentCard
extends TextureButton
# One talent of an open upgrade, selected or not.

const NORMAL_TEXTURE := preload("res://stage/level_up/assets/talent_normal.png")
const SELECTED_TEXTURE := preload("res://stage/level_up/assets/talent_selected.png")

@onready var _monogram: Label = $IconFrame/Monogram
@onready var _name: Label = $Name
@onready var _description: RichTextLabel = $Description
@onready var _check: TextureRect = $Check


func show_talent(talent: Talent, bag: Array[Learnable], is_selected: bool) -> void:
	_monogram.text = LevelUpText.get_monogram(talent.name)
	_name.text = talent.name
	_description.text = LevelUpText.get_talent_description(talent, bag)
	texture_normal = SELECTED_TEXTURE if is_selected else NORMAL_TEXTURE
	_check.visible = is_selected
