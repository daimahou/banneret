class_name RunModel
extends RefCounted

const HERO_REGISTRY: Registry = preload("res://hero/hero_registry.tres")
const PARTY_HERO_IDS: Array[StringName] = [&"knight", &"archer", &"mage"]

var party: Array[Hero] = []


func _init() -> void:
	for id in PARTY_HERO_IDS:
		party.append(Hero.new(HERO_REGISTRY.load_entry(id) as HeroData))
