class_name OwnedSkill
extends RefCounted
# A skill a character owns, with the talent chosen at each upgrade taken so far.

const RANK_NAMES: Array[String] = ["Basic", "Advanced", "Expert"]

var skill: Learnable
var talents: Array[Talent] = []


func _init(owned: Learnable) -> void:
	skill = owned


func get_rank() -> int:
	return talents.size()


# Null once every upgrade is taken.
func get_next_upgrade() -> Upgrade:
	return skill.upgrades[get_rank()] if get_rank() < skill.upgrades.size() else null


func get_mods() -> Array[SkillMod]:
	var mods := skill.get_basic_mods()
	for rank in get_rank():
		if skill.upgrades[rank].mod != null:
			mods.append(skill.upgrades[rank].mod)
		if talents[rank].mod != null:
			mods.append(talents[rank].mod)
	return mods
