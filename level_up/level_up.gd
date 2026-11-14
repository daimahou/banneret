class_name LevelUp
extends RefCounted
# One level-up of the run: each hero's offers, drawn once, and the offer each has selected.

enum Draft { TALENT, SKILL }

const OFFER_COUNT := 3
const UPGRADE_COUNT := 1
const PERK_LIMIT := 4
const LAST_NUMBER := 37
const SKILL_DRAFT_NUMBERS: Array[int] = [3, 6, 8, 11, 14, 16, 19, 22, 24, 27, 30, 32, 35, 37]

var number: int
var draft: Draft
var heroes: Array[Character] = []

var _offers: Dictionary[Character, Array] = {}
var _selected_offers: Dictionary[Character, LevelUpOffer] = {}
var _selected_perks: Dictionary[Character, SkillPerk] = {}


func _init(level_up_number: int, party: Array[Character], bag: Array[SkillData], rng: RandomNumberGenerator) -> void:
	number = level_up_number
	draft = Draft.SKILL if number in SKILL_DRAFT_NUMBERS else Draft.TALENT
	heroes = party
	for hero in heroes:
		_offers[hero] = _draw_offers(hero, bag, rng)
		if not hero.is_fallen() and is_skipped(hero):
			push_warning("%s has no offer in the %s draft of level-up %d" % [hero.data.name, get_draft_name(), number])


func get_draft_name() -> String:
	return Draft.find_key(draft).to_lower()


func get_offers(hero: Character) -> Array[LevelUpOffer]:
	var offers: Array[LevelUpOffer] = []
	offers.assign(_offers[hero])
	return offers


func has_offers() -> bool:
	return not heroes.all(is_skipped)


func is_skipped(hero: Character) -> bool:
	return _offers[hero].is_empty()


# Null while the hero has selected nothing.
func get_selected_offer(hero: Character) -> LevelUpOffer:
	return _selected_offers.get(hero)


# A hero is ready once they have selected an offer, or are skipped.
func get_ready_count() -> int:
	return heroes.filter(_is_hero_ready).size()


func is_ready() -> bool:
	return heroes.all(_is_hero_ready)


# Null for a new skill, or while the hero has selected nothing.
func get_selected_perk(hero: Character) -> SkillPerk:
	return _selected_perks.get(hero)


# An upgrade is selected with one of its perks, a new skill with none.
func select_offer(hero: Character, offer: LevelUpOffer, perk: SkillPerk = null) -> void:
	if offer not in _offers[hero]:
		push_error("%s cannot select that offer" % hero.data.name)
		return
	var is_perk_valid := perk in offer.get_perks() if offer.is_upgrade() else perk == null
	if not is_perk_valid:
		push_error("%s cannot select that perk" % hero.data.name)
		return
	_selected_offers[hero] = offer
	_selected_perks[hero] = perk


func _is_hero_ready(hero: Character) -> bool:
	return is_skipped(hero) or _selected_offers.has(hero)


# Two new skills and one upgrade; where either falls short, the other fills its places.
func _draw_offers(hero: Character, bag: Array[SkillData], rng: RandomNumberGenerator) -> Array[LevelUpOffer]:
	var offers: Array[LevelUpOffer] = []
	if hero.is_fallen() or draft != Draft.SKILL:
		return offers
	var new_skills := _get_new_skill_offers(hero, bag)
	var upgrades := _get_upgrade_offers(hero)
	var new_skill_count := mini(OFFER_COUNT - mini(UPGRADE_COUNT, upgrades.size()), new_skills.size())
	var upgrade_count := mini(OFFER_COUNT - new_skill_count, upgrades.size())
	for index in new_skill_count:
		offers.append(new_skills.pop_at(rng.randi_range(0, new_skills.size() - 1)))
	for index in upgrade_count:
		offers.append(upgrades.pop_at(rng.randi_range(0, upgrades.size() - 1)))
	return offers


func _get_new_skill_offers(hero: Character, bag: Array[SkillData]) -> Array[LevelUpOffer]:
	var offers: Array[LevelUpOffer] = []
	if not hero.has_free_skill_slot():
		return offers
	for skill_data in bag:
		if not hero.has_skill(skill_data):
			offers.append(LevelUpOffer.new(skill_data))
	return offers


func _get_upgrade_offers(hero: Character) -> Array[LevelUpOffer]:
	var offers: Array[LevelUpOffer] = []
	for skill in hero.skills:
		var next_rank := skill.get_next_rank()
		if next_rank == null or next_rank.perks.is_empty():
			continue
		if next_rank.perks.size() > PERK_LIMIT:
			var rank_title: String = Skill.Rank.find_key(skill.rank + 1).capitalize()
			push_error("%s has %d perks at %s, more than %d" % [skill.data.name, next_rank.perks.size(), rank_title, PERK_LIMIT])
		offers.append(LevelUpOffer.new(skill.data, skill))
	return offers
