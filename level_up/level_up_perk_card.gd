class_name LevelUpPerkCard
extends TextureButton
# One perk of the upgrade open in a hero's column. It shows what it is told, and only reports its press.

const NORMAL_TEXTURE := preload("res://level_up/assets/talent_normal.png")
const SELECTED_TEXTURE := preload("res://level_up/assets/talent_selected.png")

# Null while the card is hidden.
var perk: Perk

@onready var _icon: TextureRect = $IconFrame/Icon
@onready var _name: Label = $Name
@onready var _description: Label = $Description
@onready var _check: TextureRect = $Check


# Null hides the card.
func show_perk(shown_perk: Perk) -> void:
	perk = shown_perk
	visible = perk != null
	if perk == null:
		return
	_icon.texture = perk.icon
	_name.text = perk.name
	_description.text = perk.get_description()


func set_selected(is_selected: bool) -> void:
	texture_normal = SELECTED_TEXTURE if is_selected else NORMAL_TEXTURE
	_check.visible = is_selected
