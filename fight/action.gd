class_name Action
extends RefCounted

var id := -1
var actor: Character
var skill: SkillData
# Null for a skill shown before its target is chosen.
var target: Character
var resolve_tick: int
