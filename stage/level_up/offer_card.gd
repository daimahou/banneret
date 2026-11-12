class_name OfferCard
extends TextureButton
# One offer of a level-up as a parchment card, in the state the hero column tells it.

signal back_pressed

enum Look { NORMAL, OPEN, SELECTED }

const NORMAL_TEXTURE := preload("res://stage/level_up/assets/offer_normal.png")
const OPEN_TEXTURE := preload("res://stage/level_up/assets/offer_focused.png")
const SELECTED_TEXTURE := preload("res://stage/level_up/assets/offer_selected.png")
const TALENT_ICON_SCENE := preload("res://stage/level_up/talent_icon.tscn")

@onready var _title: Label = $Title
@onready var _talent_icons: HBoxContainer = $TalentIcons
@onready var _monogram: Label = $IconFrame/Monogram
@onready var _description: RichTextLabel = $Description
@onready var _hint: Label = $Hint
@onready var _back_button: TextureButton = $BackButton
@onready var _check: TextureRect = $Check


func _ready() -> void:
	_back_button.pressed.connect(back_pressed.emit)


func show_offer(offer: DraftOffer, bag: Array[Learnable]) -> void:
	_title.text = LevelUpText.get_offer_title(offer)
	_monogram.text = LevelUpText.get_monogram(offer.skill.name)
	_description.text = LevelUpText.get_offer_description(offer)
	var talents := offer.talents
	if not offer.is_upgrade() and not offer.skill.upgrades.is_empty():
		talents = offer.skill.upgrades[0].talents
	for talent in talents:
		var icon: TalentIcon = TALENT_ICON_SCENE.instantiate()
		_talent_icons.add_child(icon)
		icon.show_talent(talent, LevelUpText.get_talent_tooltip(talent, bag))
	_hint.visible = offer.is_upgrade()


func show_look(look: Look, is_back_shown: bool) -> void:
	texture_normal = {Look.NORMAL: NORMAL_TEXTURE, Look.OPEN: OPEN_TEXTURE, Look.SELECTED: SELECTED_TEXTURE}[look]
	_check.visible = look == Look.SELECTED
	_back_button.visible = is_back_shown
	_hint.visible = _hint.visible and look == Look.NORMAL
