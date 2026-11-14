@tool
class_name TalentPerk
extends Perk

@export var modifiers: Array[HeroModifier] = []


func get_description() -> String:
	return "\n".join(modifiers.map(func(modifier: HeroModifier) -> String: return modifier.get_description()))
