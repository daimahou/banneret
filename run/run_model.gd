class_name RunModel
extends RefCounted

const HERO_REGISTRY: Registry = preload("res://hero/hero_registry.tres")
const PARTY_HERO_IDS: Array[StringName] = [&"warrior", &"rogue", &"mage"]
const BRIGAND: CharacterData = preload("res://enemy/brigand.tres")
const ENCOUNTER_ENEMIES: Array[CharacterData] = [BRIGAND, BRIGAND, BRIGAND]
const SKILL_BAG: SkillBag = preload("res://skill/placeholder/placeholder_bag.tres")

var party: Array[Character] = []
var next_pick := 1
# Null while no level-up is open.
var draft: Draft

var _rng := RandomNumberGenerator.new()


func _init() -> void:
	for id in PARTY_HERO_IDS:
		party.append(Character.new(HERO_REGISTRY.load_entry(id) as CharacterData))


func create_encounter_enemies() -> Array[Character]:
	var enemies: Array[Character] = []
	for enemy_data in ENCOUNTER_ENEMIES:
		enemies.append(Character.new(enemy_data))
	return enemies


func is_lost() -> bool:
	return party.all(func(hero: Character) -> bool: return hero.is_fallen())


func has_open_draft() -> bool:
	return draft != null


func is_progression_complete() -> bool:
	return next_pick > DraftRules.PICK_COUNT


# Null once progression is complete. A draft still open is opened again as it stands.
func open_draft() -> Draft:
	if is_progression_complete():
		return null
	if draft == null:
		draft = Draft.new(party, DraftRules.get_kind(next_pick), SKILL_BAG.skills, _rng.randf)
	return draft


func close_draft() -> void:
	if draft == null or not draft.is_complete():
		return
	draft = null
	next_pick += 1
