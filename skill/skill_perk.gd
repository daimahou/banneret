@tool
class_name SkillPerk
extends Perk

@export var effects: Array[Effect] = []
@export var modifiers: Array[SkillModifier] = []


func get_description() -> String:
	var lines := PackedStringArray()
	for modifier in modifiers:
		lines.append(modifier.get_description())
	for effect in effects:
		lines.append(effect.get_description())
	return "\n".join(lines)
