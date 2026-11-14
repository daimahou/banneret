class_name SkillOffer
extends LevelUpOffer

var skill_data: SkillData
# Null for a new skill.
var skill: Skill


func _init(offered_skill_data: SkillData, upgraded_skill: Skill = null) -> void:
	skill_data = offered_skill_data
	skill = upgraded_skill


func is_upgrade() -> bool:
	return skill != null


func get_name() -> String:
	return skill_data.name


func get_icon() -> Texture2D:
	return skill_data.icon


func get_reached_rank_title() -> String:
	return _create_skill_before_perk().get_rank_title()


func get_description_before_perk() -> String:
	return _create_skill_before_perk().get_description()


func get_perks() -> Array[Perk]:
	var perks: Array[Perk] = []
	if is_upgrade():
		perks.assign(skill.get_next_rank().perks)
	return perks


func apply(hero: Character, perk: Perk) -> void:
	if is_upgrade():
		skill.upgrade(perk as SkillPerk)
	else:
		hero.skills.append(Skill.new(skill_data))


func _create_skill_before_perk() -> Skill:
	if not is_upgrade():
		return Skill.new(skill_data)
	var offered := skill.duplicate()
	offered.upgrade(null)
	return offered
