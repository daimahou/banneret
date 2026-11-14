@tool
class_name Perk
extends Resource
# One authored choice inside a skill's or talent's rank: what it gains once it is picked.

@export var name: String
# Null leaves its socket bare.
@export var icon: Texture2D
# Granted once it is picked.
@export var granted_tags: Array[StringName] = []
# All must be met for it to be offered.
@export var requirements: Array[TagRequirement] = []


func get_description() -> String:
	return ""


func _validate_property(property: Dictionary) -> void:
	if property.name == "granted_tags":
		TagLibrary.hint_tag_array(property)
