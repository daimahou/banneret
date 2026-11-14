class_name LevelUpOfferCard
extends TextureButton
# One level-up offer in a hero's column. It shows what it is told, and only reports its press.

const NORMAL_TEXTURE := preload("res://level_up/assets/offer_normal.png")
const SELECTED_TEXTURE := preload("res://level_up/assets/offer_selected.png")
const OPEN_TEXTURE := preload("res://level_up/assets/offer_focused.png")

# Null while the card is hidden.
var offer: LevelUpOffer

var _perk_icons: Array[LevelUpPerkIcon] = []

@onready var _icon: TextureRect = $IconFrame/Icon
@onready var _name: Label = $Name
@onready var _description: Label = $Description
@onready var _check: TextureRect = $Check
@onready var _perk_row: HBoxContainer = $PerkRow


func _ready() -> void:
	_perk_icons.assign(_perk_row.get_children())


# Null hides the card.
func show_offer(shown_offer: LevelUpOffer) -> void:
	offer = shown_offer
	visible = offer != null
	if offer == null:
		return
	_icon.texture = offer.get_icon()
	_name.text = "%s · %s" % [offer.get_name(), offer.get_reached_rank_title()]
	_description.text = offer.get_description_before_perk()
	var perks := offer.get_perks()
	for index in _perk_icons.size():
		_perk_icons[index].visible = index < perks.size()
		if _perk_icons[index].visible:
			_perk_icons[index].show_perk(perks[index])


func show_state(is_selected: bool, is_open: bool) -> void:
	texture_normal = OPEN_TEXTURE if is_open else SELECTED_TEXTURE if is_selected else NORMAL_TEXTURE
	_check.visible = is_selected and not is_open
	_perk_row.visible = not is_open
