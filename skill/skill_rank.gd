class_name SkillRank
extends Resource
# One of a skill's ranks above Basic: what reaching it adds, and the perks to pick one from.

@export var effects: Array[Effect] = []
@export var modifiers: Array[SkillModifier] = []
@export var perks: Array[SkillPerk] = []


func get_description() -> String:
	var lines := PackedStringArray()
	for modifier in modifiers:
		lines.append(modifier.get_description())
	for effect in effects:
		lines.append(effect.get_description())
	return "\n".join(lines)
