class_name SkillPerk
extends Resource
# One authored choice inside a skill's rank: what the skill gains once it is picked.

@export var name: String
# Null leaves its socket bare.
@export var icon: Texture2D
@export var effects: Array[Effect] = []
@export var modifiers: Array[SkillModifier] = []


func get_description() -> String:
	var lines := PackedStringArray()
	for modifier in modifiers:
		lines.append(modifier.get_description())
	for effect in effects:
		lines.append(effect.get_description())
	return "\n".join(lines)
