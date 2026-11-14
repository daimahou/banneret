class_name LevelUpColumn
extends Control
# One hero's column of the level-up: their build and their offers, or the perks of the upgrade open. It shows what it is told, and only reports the offer selected.

signal offer_selected(offer: LevelUpOffer, perk: Perk)

var _level_up: LevelUp
var _hero: Character
# Null while the offers are listed.
var _open_offer: LevelUpOffer
var _talent_slots: Array[LevelUpBuildSlot] = []
var _skill_slots: Array[LevelUpBuildSlot] = []
var _offer_cards: Array[LevelUpOfferCard] = []
var _perk_cards: Array[LevelUpPerkCard] = []

@onready var _portrait: TextureRect = $PortraitFrame/Portrait
@onready var _name: Label = $Name
@onready var _stats: Label = $Stats
@onready var _skipped_label: Label = $SkippedLabel
@onready var _back_button: TextureButton = $BackButton


func _ready() -> void:
	_talent_slots.assign($TalentSlots.get_children())
	_skill_slots.assign($SkillTray/SkillSlots.get_children())
	_offer_cards.assign($Offers.get_children())
	_perk_cards.assign($Perks.get_children())
	for card in _offer_cards:
		card.pressed.connect(_on_offer_card_pressed.bind(card))
	for card in _perk_cards:
		card.pressed.connect(func() -> void: offer_selected.emit(_open_offer, card.perk))
	_back_button.pressed.connect(_open_offer_perks.bind(null))


func show_hero(level_up: LevelUp, hero: Character) -> void:
	_level_up = level_up
	_hero = hero
	_open_offer = null
	_portrait.texture = hero.data.portrait
	_name.text = hero.data.name
	_stats.text = "Health %d / %d   AP %d / %d" % [hero.health, hero.get_max_health(), hero.ap, hero.get_max_ap()]
	var offers := level_up.get_offers(hero)
	for index in _offer_cards.size():
		_offer_cards[index].show_offer(offers[index] if index < offers.size() else null)
	update_state()


func update_state() -> void:
	var selected_offer := _level_up.get_selected_offer(_hero)
	for card in _offer_cards:
		card.visible = card.offer != null and (_open_offer == null or card.offer == _open_offer)
		card.show_state(card.offer != null and card.offer == selected_offer, card.offer == _open_offer)
	var perks: Array[Perk] = []
	if _open_offer != null:
		perks = _open_offer.get_perks()
	var selected_perk := _level_up.get_selected_perk(_hero) if selected_offer == _open_offer else null
	for index in _perk_cards.size():
		var card := _perk_cards[index]
		card.show_perk(perks[index] if index < perks.size() else null)
		card.set_selected(card.perk != null and card.perk == selected_perk)
	_back_button.visible = _open_offer != null
	_skipped_label.visible = _level_up.is_skipped(_hero)
	for index in _talent_slots.size():
		_talent_slots[index].show_talent(_hero.talents[index] if index < _hero.talents.size() else null)
	for index in _skill_slots.size():
		_skill_slots[index].show_skill(_hero.skills[index] if index < _hero.skills.size() else null)


func _on_offer_card_pressed(card: LevelUpOfferCard) -> void:
	if card.offer.is_upgrade():
		_open_offer_perks(card.offer)
	else:
		offer_selected.emit(card.offer, null)


# Null lists the offers again.
func _open_offer_perks(offer: LevelUpOffer) -> void:
	_open_offer = offer
	update_state()
