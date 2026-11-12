class_name Upgrade
extends Resource
# One rank up of a skill: its rank effect, and the talents the hero chooses one of.

# Null for an upgrade with no rank effect beyond its talent.
@export var mod: SkillMod
@export var talents: Array[Talent] = []
