class_name Action
extends RefCounted

# Given by the fight model as it goes on the timeline; -1 before.
var id := -1
var actor: Character
var skill: SkillData
# Null for a skill shown before its target is chosen.
var target: Character
var resolve_tick: int
