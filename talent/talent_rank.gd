class_name TalentRank
extends Resource
# One of a talent's ranks above Basic: what reaching it adds, and the perks to pick one from.

@export var modifiers: Array[HeroModifier] = []
@export var perks: Array[TalentPerk] = []


func get_description() -> String:
	return "\n".join(modifiers.map(func(modifier: HeroModifier) -> String: return modifier.get_description()))
