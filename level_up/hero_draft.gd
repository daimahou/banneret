class_name HeroDraft
extends RefCounted
# One hero's pick in a level-up: the offers drawn once, and the choice, which the hero may change until confirmed.

enum State { CHOOSING, CONFIRMED, FALLEN, STARVED }

var hero: Character
var offers: Array[DraftOffer] = []
var state := State.CHOOSING
# Null until an offer is selected.
var selected_offer: DraftOffer
# Null until a talent of the selected upgrade is selected.
var selected_talent: Talent


func _init(drafted: Character, kind: Learnable.Kind, bag: Array[Learnable], roll: Callable) -> void:
	hero = drafted
	if hero.is_fallen():
		state = State.FALLEN
		return
	offers = DraftRules.draw_offers(hero.build, kind, bag, roll)
	if offers.is_empty():
		state = State.STARVED


func is_done() -> bool:
	return state != State.CHOOSING


func select_offer(offer: DraftOffer) -> void:
	if is_done() or offer not in offers:
		return
	selected_offer = offer
	selected_talent = null


func select_talent(talent: Talent) -> void:
	if is_done() or selected_offer == null or talent not in selected_offer.talents:
		return
	selected_talent = talent


func back() -> void:
	if is_done():
		return
	selected_offer = null
	selected_talent = null


func can_confirm() -> bool:
	if is_done() or selected_offer == null:
		return false
	return not selected_offer.is_upgrade() or selected_talent != null


func confirm() -> void:
	if not can_confirm():
		return
	if selected_offer.is_upgrade():
		selected_offer.owned.talents.append(selected_talent)
	else:
		hero.build.learn(selected_offer.skill)
	hero.update_skills()
	state = State.CONFIRMED
