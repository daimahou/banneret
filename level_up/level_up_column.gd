class_name LevelUpColumn
extends Control
# One hero's column of the level-up: their build, their offers and their Confirm. It shows what it is told, and only reports the confirmed pick.

signal pick_confirmed(offer: LevelUpOffer)

const OFFER_CARD_SCENE := preload("res://level_up/level_up_offer_card.tscn")
const SKILL_FRAME_TEXTURE := preload("res://level_up/assets/skill_frame.png")
const SKILL_SLOT_EMPTY_TEXTURE := preload("res://level_up/assets/skill_slot_empty.png")
const SKILL_NAME_FONT_SIZE := 26
const SKILL_NAME_COLOR := Color("e8d3a0")

var _level_up: LevelUp
var _hero: Character
var _offer_cards: Array[LevelUpOfferCard] = []
# Null while no offer is selected.
var _selected_offer: LevelUpOffer

@onready var _portrait: TextureRect = $PortraitFrame/Portrait
@onready var _name: Label = $Name
@onready var _stats: Label = $Stats
@onready var _skill_slots: HBoxContainer = $SkillTray/SkillSlots
@onready var _offers: VBoxContainer = $Offers
@onready var _confirm_button: TextureButton = $ConfirmButton
@onready var _confirm_label: Label = $ConfirmButton/Label


func _ready() -> void:
	for index in Character.SKILL_SLOTS:
		_skill_slots.add_child(_create_skill_slot())
	_confirm_button.pressed.connect(_on_confirm_pressed)


func show_hero(level_up: LevelUp, hero: Character) -> void:
	_level_up = level_up
	_hero = hero
	_selected_offer = null
	_portrait.texture = hero.data.portrait
	_name.text = hero.data.name
	_stats.text = "Health %d / %d   AP %d / %d" % [hero.health, hero.data.max_health, hero.ap, hero.data.max_ap]
	for card in _offer_cards:
		card.queue_free()
	_offer_cards.clear()
	for offer in level_up.get_offers(hero):
		var card: LevelUpOfferCard = OFFER_CARD_SCENE.instantiate()
		card.offer = offer
		card.pressed.connect(_on_offer_pressed.bind(offer))
		_offers.add_child(card)
		_offer_cards.append(card)
	update_state()


func update_state() -> void:
	var state := _level_up.get_state(_hero)
	for card in _offer_cards:
		card.set_selected(card.offer == _selected_offer)
		card.disabled = state != LevelUp.State.PENDING
	_confirm_button.disabled = state != LevelUp.State.PENDING or _selected_offer == null
	_confirm_label.text = {
		LevelUp.State.PENDING: "CONFIRM",
		LevelUp.State.CONFIRMED: "CONFIRMED",
		LevelUp.State.SKIPPED: "SKIPPED",
	}[state]
	var slots := _skill_slots.get_children()
	for index in slots.size():
		_show_skill_slot(slots[index], _hero.skills[index] if index < _hero.skills.size() else null)


func _create_skill_slot() -> TextureRect:
	var slot := TextureRect.new()
	slot.mouse_filter = Control.MOUSE_FILTER_PASS
	var label := Label.new()
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", SKILL_NAME_FONT_SIZE)
	label.add_theme_color_override("font_color", SKILL_NAME_COLOR)
	slot.add_child(label)
	return slot


# Null empties the slot.
func _show_skill_slot(slot: TextureRect, skill: Skill) -> void:
	slot.texture = SKILL_SLOT_EMPTY_TEXTURE if skill == null else SKILL_FRAME_TEXTURE
	slot.tooltip_text = "" if skill == null else skill.data.name
	(slot.get_child(0) as Label).text = "" if skill == null else skill.data.name


func _on_offer_pressed(offer: LevelUpOffer) -> void:
	_selected_offer = offer
	update_state()


func _on_confirm_pressed() -> void:
	pick_confirmed.emit(_selected_offer)
