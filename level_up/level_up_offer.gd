class_name LevelUpOffer
extends RefCounted
# One offer a level-up puts up for one hero: a new skill, or an upgrade of one they own.

var skill_data: SkillData
# Null for a new skill.
var skill: Skill


func _init(offered_skill_data: SkillData, upgraded_skill: Skill = null) -> void:
	skill_data = offered_skill_data
	skill = upgraded_skill


func is_upgrade() -> bool:
	return skill != null


func get_perks() -> Array[SkillPerk]:
	var perks: Array[SkillPerk] = []
	if is_upgrade():
		perks.assign(skill.get_next_rank().perks)
	return perks


func create_skill_before_perk() -> Skill:
	if not is_upgrade():
		return Skill.new(skill_data)
	var offered := skill.duplicate()
	offered.upgrade(null)
	return offered
