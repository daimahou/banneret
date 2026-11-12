class_name DraftOffer
extends RefCounted
# One offer of a level-up: a skill to learn, or the next upgrade of one the hero owns.

var skill: Learnable
var rank := 0
# Null for a skill to learn.
var owned: OwnedSkill
# The talents of the upgrade the hero may choose from; empty for a skill to learn.
var talents: Array[Talent] = []


func is_upgrade() -> bool:
	return owned != null
