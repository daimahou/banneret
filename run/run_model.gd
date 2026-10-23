class_name RunModel
extends RefCounted

const HERO_REGISTRY: Registry = preload("res://hero/hero_registry.tres")
const PARTY_HERO_IDS: Array[StringName] = [&"knight", &"rogue", &"mage"]
const ENCOUNTER_ENEMIES: Array[CharacterData] = [preload("res://enemy/brigand.tres")]

var party: Array[Character] = []


func _init() -> void:
	for id in PARTY_HERO_IDS:
		party.append(Character.new(HERO_REGISTRY.load_entry(id) as CharacterData))
