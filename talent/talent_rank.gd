class_name TalentRank
extends Resource
# One of a talent's ranks above Basic: what reaching it adds, and the perks to pick one from.

@export var modifiers: Array[HeroModifier] = []
@export var perks: Array[TalentPerk] = []
