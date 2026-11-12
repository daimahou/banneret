class_name Learnable
extends Resource
# A skill a hero can learn in a level-up, active or passive, and the upgrades that develop it.

enum Kind { PASSIVE, ACTIVE }

@export var name: String
@export var offer_weight := 1
# Null for a skill every class may be offered.
@export var required_class: ClassData
@export var class_offer_weights: Dictionary[ClassData, int] = {}
@export var upgrades: Array[Upgrade] = []


func get_kind() -> Kind:
	return Kind.PASSIVE


func get_basic_mods() -> Array[SkillMod]:
	return []
