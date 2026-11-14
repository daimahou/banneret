class_name LevelUpOffer
extends RefCounted
# One offer a level-up puts up for one hero: a new skill.

var skill_data: SkillData


func _init(offered_skill_data: SkillData) -> void:
	skill_data = offered_skill_data
