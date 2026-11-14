@tool
class_name TalentData
extends Resource
# A talent's preset, which is its Basic rank, and the ranks above it.

@export var name: String
# Null shows the placeholder.
@export var icon: Texture2D
@export var modifiers: Array[HeroModifier] = []
# Advanced, then Expert.
@export var ranks: Array[TalentRank] = []
# Granted once it is acquired.
@export var granted_tags: Array[StringName] = []
# All must be met for it to be offered.
@export var requirements: Array[TagRequirement] = []


func _validate_property(property: Dictionary) -> void:
	if property.name == "granted_tags":
		TagLibrary.hint_tag_array(property)
