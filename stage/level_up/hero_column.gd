class_name HeroColumn
extends Control
# One hero's column of the level-up: their build, and their pick in the draft. It shows the pick, and passes the player's choices to it.

signal pick_changed

const BUILD_SLOT_SCENE := preload("res://stage/level_up/build_slot.tscn")
const OFFER_CARD_SCENE := preload("res://stage/level_up/offer_card.tscn")
const TALENT_CARD_SCENE := preload("res://stage/level_up/talent_card.tscn")
const CONFIRM_ENABLED_TEXTURE := preload("res://stage/level_up/assets/button_enabled.png")
const CONFIRM_DISABLED_TEXTURE := preload("res://stage/level_up/assets/button_disabled.png")
const CONFIRMED_TEXTURE := preload("res://stage/level_up/assets/button_normal.png")
const PORTRAIT_SIZE := Vector2(208.0, 240.0)
const PASSIVE_SLOT_STEP := Vector2(168.0, 128.0)
const PASSIVE_SLOTS_PER_ROW := 4
const ACTIVE_SLOT_STEP := 192.0
const OFFER_STEP := 320.0
const TALENT_STEP := 216.0
const OFFER_CARD_HEIGHT := 304.0
const TALENT_CARD_HEIGHT := 200.0

var _hero_draft: HeroDraft
var _bag: Array[Learnable] = []
var _passive_slots: Array[BuildSlot] = []
var _active_slots: Array[BuildSlot] = []

@onready var _portrait: TextureRect = $PortraitClip/Portrait
@onready var _name: Label = $Name
@onready var _stats: Label = $Stats
@onready var _class: Label = $Class
@onready var _passive_area: Control = $PassiveSlots
@onready var _active_area: Control = $ActiveSlots
@onready var _offer_area: Control = $Offers
@onready var _message: Label = $Offers/Message
@onready var _confirm_button: TextureButton = $ConfirmButton
@onready var _confirm_label: Label = $ConfirmButton/Label


func _ready() -> void:
	for index in Build.PASSIVE_SLOTS + 1:
		var slot: BuildSlot = BUILD_SLOT_SCENE.instantiate()
		var row := floori(index / float(PASSIVE_SLOTS_PER_ROW))
		slot.position = Vector2(index % PASSIVE_SLOTS_PER_ROW, row) * PASSIVE_SLOT_STEP
		_passive_area.add_child(slot)
		_passive_slots.append(slot)
	for index in Build.ACTIVE_SLOTS + 1:
		var slot: BuildSlot = BUILD_SLOT_SCENE.instantiate()
		slot.position = Vector2(index * ACTIVE_SLOT_STEP, 0.0)
		_active_area.add_child(slot)
		_active_slots.append(slot)
	_confirm_button.pressed.connect(_on_confirm_pressed)


func show_hero_draft(hero_draft: HeroDraft, bag: Array[Learnable]) -> void:
	_hero_draft = hero_draft
	_bag = bag
	var hero := hero_draft.hero
	_portrait.texture = _cut_portrait_from_puppet(hero.data)
	_name.text = hero.data.name
	_stats.text = "Health %d/%d · AP %d/%d" % [hero.health, hero.data.max_health, hero.ap, hero.data.max_ap]
	_show_pick()


func _show_pick() -> void:
	var hero := _hero_draft.hero
	var class_data := hero.build.get_class_data()
	_class.text = "" if class_data == null else class_data.name
	_show_build(_passive_slots, hero.build.get_owned(Learnable.Kind.PASSIVE))
	_show_build(_active_slots, hero.build.actives)
	for child in _offer_area.get_children():
		if child != _message:
			child.queue_free()
	_message.text = {
		HeroDraft.State.FALLEN: "Fallen: no pick this level-up.",
		HeroDraft.State.STARVED: "No valid offers: pick skipped.",
	}.get(_hero_draft.state, "")
	var selected := _hero_draft.selected_offer
	if selected == null:
		_show_offers()
	else:
		_show_selected_offer(selected)
	_show_confirm_button()


func _show_build(slots: Array[BuildSlot], owned: Array[OwnedSkill]) -> void:
	for index in slots.size():
		slots[index].show_owned(owned[index] if index < owned.size() else null, _hero_draft.hero, _bag)


func _show_offers() -> void:
	for index in _hero_draft.offers.size():
		var offer := _hero_draft.offers[index]
		var card := _add_offer_card(offer, index * OFFER_STEP)
		card.show_look(OfferCard.Look.NORMAL, false)
		card.pressed.connect(_on_offer_pressed.bind(offer))


func _show_selected_offer(offer: DraftOffer) -> void:
	var card := _add_offer_card(offer, 0.0)
	var is_open := offer.is_upgrade() and not _hero_draft.is_done()
	card.show_look(OfferCard.Look.OPEN if offer.is_upgrade() else OfferCard.Look.SELECTED, is_open)
	card.back_pressed.connect(_on_back_pressed)
	card.pressed.connect(_on_back_pressed)
	card.disabled = _hero_draft.is_done()
	if not offer.is_upgrade():
		return
	var talents := offer.talents
	if _hero_draft.is_done():
		talents = [_hero_draft.selected_talent]
	var space := _offer_area.size.y - OFFER_CARD_HEIGHT - TALENT_CARD_HEIGHT
	var step := TALENT_STEP if talents.size() < 2 else minf(TALENT_STEP, space / (talents.size() - 1))
	for index in talents.size():
		var talent := talents[index]
		var talent_card: TalentCard = TALENT_CARD_SCENE.instantiate()
		talent_card.position.y = OFFER_CARD_HEIGHT + index * step
		_offer_area.add_child(talent_card)
		talent_card.show_talent(talent, _bag, talent == _hero_draft.selected_talent)
		talent_card.pressed.connect(_on_talent_pressed.bind(talent))
		talent_card.disabled = _hero_draft.is_done()


func _add_offer_card(offer: DraftOffer, y: float) -> OfferCard:
	var card: OfferCard = OFFER_CARD_SCENE.instantiate()
	card.position.y = y
	_offer_area.add_child(card)
	card.show_offer(offer, _bag)
	return card


func _show_confirm_button() -> void:
	_confirm_button.visible = _hero_draft.state in [HeroDraft.State.CHOOSING, HeroDraft.State.CONFIRMED]
	_confirm_button.disabled = not _hero_draft.can_confirm()
	if _hero_draft.state == HeroDraft.State.CONFIRMED:
		_confirm_button.texture_normal = CONFIRMED_TEXTURE
		_confirm_label.text = "CONFIRMED ✓"
		return
	_confirm_label.text = "CONFIRM"
	var is_confirmable := _hero_draft.can_confirm()
	_confirm_button.texture_normal = CONFIRM_ENABLED_TEXTURE if is_confirmable else CONFIRM_DISABLED_TEXTURE


func _cut_portrait_from_puppet(character_data: CharacterData) -> Texture2D:
	var nameplate_portrait := character_data.portrait as AtlasTexture
	var puppet_size := character_data.puppet.get_size()
	var region := Rect2(nameplate_portrait.region.get_center() - PORTRAIT_SIZE / 2.0, PORTRAIT_SIZE)
	region.position = region.position.clamp(Vector2.ZERO, (puppet_size - PORTRAIT_SIZE).max(Vector2.ZERO))
	var portrait := AtlasTexture.new()
	portrait.atlas = character_data.puppet
	portrait.region = region.intersection(Rect2(Vector2.ZERO, puppet_size))
	return portrait


func _on_offer_pressed(offer: DraftOffer) -> void:
	_hero_draft.select_offer(offer)
	_show_pick()


func _on_talent_pressed(talent: Talent) -> void:
	_hero_draft.select_talent(talent)
	_show_pick()


func _on_back_pressed() -> void:
	_hero_draft.back()
	_show_pick()


func _on_confirm_pressed() -> void:
	_hero_draft.confirm()
	_show_pick()
	pick_changed.emit()
