class_name LevelUpColumn
extends Control
# One hero's column of the level-up: their build and their offers. It shows what it is told, and only reports the offer selected.

signal offer_selected(offer: LevelUpOffer)

var _level_up: LevelUp
var _hero: Character
var _skill_slots: Array[LevelUpSkillSlot] = []
var _offer_cards: Array[LevelUpOfferCard] = []

@onready var _portrait: TextureRect = $PortraitFrame/Portrait
@onready var _name: Label = $Name
@onready var _stats: Label = $Stats
@onready var _skipped_label: Label = $SkippedLabel


func _ready() -> void:
	_skill_slots.assign($SkillTray/SkillSlots.get_children())
	_offer_cards.assign($Offers.get_children())
	for card in _offer_cards:
		card.pressed.connect(func() -> void: offer_selected.emit(card.offer))


func show_hero(level_up: LevelUp, hero: Character) -> void:
	_level_up = level_up
	_hero = hero
	_portrait.texture = hero.data.portrait
	_name.text = hero.data.name
	_stats.text = "Health %d / %d   AP %d / %d" % [hero.health, hero.data.max_health, hero.ap, hero.data.max_ap]
	var offers := level_up.get_offers(hero)
	for index in _offer_cards.size():
		_offer_cards[index].show_offer(offers[index] if index < offers.size() else null)
	update_state()


func update_state() -> void:
	for card in _offer_cards:
		card.set_selected(card.offer != null and card.offer == _level_up.get_selected_offer(_hero))
	_skipped_label.visible = _level_up.get_state(_hero) == LevelUp.State.SKIPPED
	for index in _skill_slots.size():
		_skill_slots[index].show_skill(_hero.skills[index] if index < _hero.skills.size() else null)

