@tool
class_name SkillData
extends Resource
# A skill's preset, which is its Basic rank, and the ranks above it.

enum Blow { QUICK, HEAVY }

@export var name: String
# Null shows the placeholder.
@export var icon: Texture2D
@export var delay: int
@export var cooldown: int
@export var ap_cost := 1
@export var blow := Blow.QUICK
@export var effects: Array[Effect] = []
# Advanced, then Expert.
@export var ranks: Array[SkillRank] = []
# Granted once it is acquired.
@export var granted_tags: Array[StringName] = []
# All must be met for it to be offered.
@export var requirements: Array[TagRequirement] = []


func _validate_property(property: Dictionary) -> void:
	if property.name == "granted_tags":
		TagLibrary.hint_tag_array(property)
