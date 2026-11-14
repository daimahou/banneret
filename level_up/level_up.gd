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
var _selected_perks: Dictionary[Character, Perk] = {}


# Each draft's bag: skill data for the skill draft, talent data for the talent draft.
func _init(position: int, party: Array[Character], bags: Dictionary[Draft, Array], rng: RandomNumberGenerator) -> void:
	number = position
	draft = Draft.SKILL if number in SKILL_DRAFT_NUMBERS else Draft.TALENT
	heroes = party
	for hero in heroes:
		_offers[hero] = _draw_offers(hero, bags.get(draft, []), rng)
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


# Null for a new skill or talent, or while the hero has selected nothing.
func get_selected_perk(hero: Character) -> Perk:
	return _selected_perks.get(hero)


# An upgrade is selected with one of its perks, a new skill or talent with none.
func select_offer(hero: Character, offer: LevelUpOffer, perk: Perk = null) -> void:
	if offer not in _offers[hero]:
		push_error("%s cannot select that offer" % hero.data.name)
		return
	var is_perk_valid := perk in offer.get_perks() if offer.is_upgrade() else perk == null
	if not is_perk_valid:
		push_error("%s cannot select that perk" % hero.data.name)
		return
	_selected_offers[hero] = offer
	_selected_perks[hero] = perk


func apply_picks() -> void:
	for hero in _selected_offers:
		_selected_offers[hero].apply(hero, _selected_perks[hero])


func _is_hero_ready(hero: Character) -> bool:
	return is_skipped(hero) or _selected_offers.has(hero)


# Two new skills or talents and one upgrade; where either falls short, the other fills its places.
func _draw_offers(hero: Character, bag: Array, rng: RandomNumberGenerator) -> Array[LevelUpOffer]:
	var offers: Array[LevelUpOffer] = []
	if hero.is_fallen():
		return offers
	var new_offers := _get_new_offers(hero, bag)
	var upgrades := _get_upgrade_offers(hero)
	var new_count := mini(OFFER_COUNT - mini(UPGRADE_COUNT, upgrades.size()), new_offers.size())
	var upgrade_count := mini(OFFER_COUNT - new_count, upgrades.size())
	for index in new_count:
		offers.append(new_offers.pop_at(rng.randi_range(0, new_offers.size() - 1)))
	for index in upgrade_count:
		offers.append(upgrades.pop_at(rng.randi_range(0, upgrades.size() - 1)))
	return offers


func _get_new_offers(hero: Character, bag: Array) -> Array[LevelUpOffer]:
	var offers: Array[LevelUpOffer] = []
	if draft == Draft.SKILL and hero.has_free_skill_slot():
		for skill_data: SkillData in bag:
			if not hero.has_skill(skill_data):
				offers.append(SkillOffer.new(Skill.new(skill_data), Skill.Rank.BASIC))
	elif draft == Draft.TALENT and hero.has_free_talent_slot():
		for talent_data: TalentData in bag:
			if not hero.has_talent(talent_data):
				offers.append(TalentOffer.new(Talent.new(talent_data), Skill.Rank.BASIC))
	return offers


func _get_upgrade_offers(hero: Character) -> Array[LevelUpOffer]:
	var candidates: Array[LevelUpOffer] = []
	if draft == Draft.SKILL:
		for skill in hero.skills.filter(func(skill: Skill) -> bool: return skill.get_next_rank() != null):
			candidates.append(SkillOffer.new(skill, skill.rank + 1))
	else:
		for talent in hero.talents.filter(func(talent: Talent) -> bool: return talent.get_next_rank() != null):
			candidates.append(TalentOffer.new(talent, talent.rank + 1))
	var offers: Array[LevelUpOffer] = []
	offers.assign(candidates.filter(func(offer: LevelUpOffer) -> bool: return not offer.get_perks().is_empty()))
	for offer in offers:
		if offer.get_perks().size() > PERK_LIMIT:
			var counts := [offer.get_perks().size(), offer.get_reached_rank_title(), PERK_LIMIT]
			push_error("%s has %d perks at %s, more than %d" % ([offer.get_name()] + counts))
	return offers
