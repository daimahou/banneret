class_name RunModel
extends RefCounted

const HERO_REGISTRY: Registry = preload("res://hero/hero_registry.tres")
const PARTY_HERO_IDS: Array[StringName] = [&"warrior", &"rogue", &"mage"]
const BRIGAND: CharacterData = preload("res://enemy/brigand.tres")
const ENCOUNTER_ENEMIES: Array[CharacterData] = [BRIGAND, BRIGAND, BRIGAND]

var party: Array[Character] = []


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
