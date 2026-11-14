class_name LevelUp
extends RefCounted
# One level-up of the run: each hero's offers, drawn once, the offer each selects, and the picks that confirm them all at once.

enum Draft { TALENT, SKILL }
enum State { PENDING, CONFIRMED, SKIPPED }

const OFFER_COUNT := 3
const LAST_NUMBER := 37
const SKILL_DRAFT_NUMBERS: Array[int] = [3, 6, 8, 11, 14, 16, 19, 22, 24, 27, 30, 32, 35, 37]

var number: int
var draft: Draft
var heroes: Array[Character] = []

var _offers: Dictionary[Character, Array] = {}
var _states: Dictionary[Character, State] = {}
var _selected_offers: Dictionary[Character, LevelUpOffer] = {}


func _init(level_up_number: int, party: Array[Character], bag: Array[SkillData], rng: RandomNumberGenerator) -> void:
	number = level_up_number
	draft = Draft.SKILL if number in SKILL_DRAFT_NUMBERS else Draft.TALENT
	heroes = party
	for hero in heroes:
		_offers[hero] = _draw_offers(hero, bag, rng)
		_states[hero] = State.SKIPPED if _offers[hero].is_empty() else State.PENDING
		if not hero.is_fallen() and _offers[hero].is_empty():
			push_warning("%s has no offer in the %s draft of level-up %d" % [hero.data.name, get_draft_name(), number])


func get_draft_name() -> String:
	return Draft.find_key(draft).to_lower()


func get_offers(hero: Character) -> Array[LevelUpOffer]:
	var offers: Array[LevelUpOffer] = []
	offers.assign(_offers[hero])
	return offers


func get_state(hero: Character) -> State:
	return _states[hero]


# Null while the hero has selected nothing.
func get_selected_offer(hero: Character) -> LevelUpOffer:
	return _selected_offers.get(hero)


# A hero is ready once they have selected an offer, or are skipped.
func get_ready_count() -> int:
	return heroes.filter(_is_hero_ready).size()


func is_ready() -> bool:
	return heroes.all(_is_hero_ready)


func is_complete() -> bool:
	return heroes.all(func(hero: Character) -> bool: return _states[hero] != State.PENDING)


func select_offer(hero: Character, offer: LevelUpOffer) -> void:
	if _states[hero] != State.PENDING or offer not in _offers[hero]:
		push_error("%s cannot select that offer" % hero.data.name)
		return
	_selected_offers[hero] = offer


func confirm_picks() -> void:
	if is_complete():
		push_error("Level-up %d is already confirmed" % number)
		return
	if not is_ready():
		push_error("Level-up %d waits on a selection" % number)
		return
	for hero in _selected_offers:
		_selected_offers[hero].apply(hero)
		_states[hero] = State.CONFIRMED


func _is_hero_ready(hero: Character) -> bool:
	return _states[hero] == State.SKIPPED or _selected_offers.has(hero)


func _draw_offers(hero: Character, bag: Array[SkillData], rng: RandomNumberGenerator) -> Array[LevelUpOffer]:
	var offers: Array[LevelUpOffer] = []
	if hero.is_fallen() or draft != Draft.SKILL or not hero.has_free_skill_slot():
		return offers
	var eligible := bag.filter(func(skill_data: SkillData) -> bool: return not hero.has_skill(skill_data))
	while offers.size() < OFFER_COUNT and not eligible.is_empty():
		offers.append(LevelUpOffer.new(eligible.pop_at(rng.randi_range(0, eligible.size() - 1))))
	return offers
