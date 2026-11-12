class_name DraftRules
# The rules of a level-up: which pick of the run is which kind, and the offers a hero may draw.
# The draws come from a roll in [0, 1), so the same rolls draw the same offers.

const ACTIVE_PICKS: Array[int] = [3, 6, 8, 11, 14, 16, 19, 22, 24, 27, 30, 32, 35, 37]
const PICK_COUNT := 37
const OFFER_COUNT := 3
const NEW_SKILL_OFFER_COUNT := 2
const MAX_TALENTS := 4


static func get_kind(pick: int) -> Learnable.Kind:
	return Learnable.Kind.ACTIVE if pick in ACTIVE_PICKS else Learnable.Kind.PASSIVE


# Missing offers of one category are drawn from the other.
static func draw_offers(build: Build, kind: Learnable.Kind, bag: Array[Learnable], roll: Callable) -> Array[DraftOffer]:
	var new_skills := get_new_skills(build, kind, bag)
	var upgrades := get_upgrade_offers(build, kind)
	var new_count := mini(NEW_SKILL_OFFER_COUNT, new_skills.size())
	var upgrade_count := mini(OFFER_COUNT - new_count, upgrades.size())
	new_count = mini(OFFER_COUNT - upgrade_count, new_skills.size())
	var offers: Array[DraftOffer] = []
	var weights: Array[int] = []
	for skill in new_skills:
		weights.append(get_offer_weight(skill, build.get_class_data()))
	for count in new_count:
		var index := _draw_weighted(weights, roll)
		var offer := DraftOffer.new()
		offer.skill = new_skills.pop_at(index)
		weights.remove_at(index)
		offers.append(offer)
	for count in upgrade_count:
		offers.append(upgrades.pop_at(mini(floori(roll.call() * upgrades.size()), upgrades.size() - 1)))
	return offers


static func get_new_skills(build: Build, kind: Learnable.Kind, bag: Array[Learnable]) -> Array[Learnable]:
	var skills: Array[Learnable] = []
	if not build.has_free_slot(kind):
		return skills
	var class_data := build.get_class_data()
	for skill in bag:
		var is_eligible := skill.get_kind() == kind and not build.owns(skill) and skill not in skills
		if is_eligible and _is_open_to(skill.required_class, class_data) and get_offer_weight(skill, class_data) > 0:
			skills.append(skill)
	return skills


static func get_upgrade_offers(build: Build, kind: Learnable.Kind) -> Array[DraftOffer]:
	var offers: Array[DraftOffer] = []
	for owned in build.get_owned(kind):
		var upgrade := owned.get_next_upgrade()
		if upgrade == null:
			continue
		var talents := get_eligible_talents(upgrade, build.get_class_data())
		if talents.size() > MAX_TALENTS:
			var error := "%s's next upgrade has %d eligible talents, more than %d"
			push_error(error % [owned.skill.name, talents.size(), MAX_TALENTS])
			continue
		if talents.is_empty():
			continue
		var offer := DraftOffer.new()
		offer.skill = owned.skill
		offer.owned = owned
		offer.rank = owned.get_rank() + 1
		offer.talents = talents
		offers.append(offer)
	return offers


static func get_eligible_talents(upgrade: Upgrade, class_data: ClassData) -> Array[Talent]:
	return upgrade.talents.filter(func(talent: Talent) -> bool: return _is_open_to(talent.required_class, class_data))


static func get_offer_weight(skill: Learnable, class_data: ClassData) -> int:
	return skill.class_offer_weights.get(class_data, skill.offer_weight)


static func _is_open_to(required_class: ClassData, class_data: ClassData) -> bool:
	return required_class == null or required_class == class_data


static func _draw_weighted(weights: Array[int], roll: Callable) -> int:
	var total := 0
	for weight in weights:
		total += weight
	var drawn: float = roll.call() * total
	for index in weights.size():
		drawn -= weights[index]
		if drawn < 0.0:
			return index
	return weights.size() - 1
