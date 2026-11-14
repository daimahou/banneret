class_name Perk
extends Resource
# One authored choice inside a skill's or talent's rank: what it gains once it is picked.

@export var name: String
# Null leaves its socket bare.
@export var icon: Texture2D


func get_description() -> String:
	return ""
