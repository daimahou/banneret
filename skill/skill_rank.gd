class_name SkillRank
extends Resource
# One of a skill's ranks above Basic: what reaching it adds, and the perks to pick one from.

@export var effects: Array[Effect] = []
@export var modifiers: Array[SkillModifier] = []
@export var perks: Array[SkillPerk] = []
