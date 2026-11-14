class_name SkillOffer
extends LevelUpOffer

# The hero's own skill for an upgrade, or a new one built for them.
var skill: Skill

var _is_upgrade: bool


func _init(offered_skill: Skill, is_owned: bool) -> void:
	skill = offered_skill
	_is_upgrade = is_owned


func is_upgrade() -> bool:
	return _is_upgrade


func get_name() -> String:
	return skill.data.name


func get_icon() -> Texture2D:
	return skill.data.icon


func get_reached_rank_title() -> String:
	return _get_reached_skill().get_rank_title()


func get_description_before_perk() -> String:
	return _get_reached_skill().get_description()


func get_perks() -> Array[Perk]:
	var perks: Array[Perk] = []
	if _is_upgrade:
		perks.assign(skill.get_next_rank().perks)
	return perks


func apply(hero: Character, perk: Perk) -> void:
	if _is_upgrade:
		skill.upgrade(perk as SkillPerk)
	else:
		hero.skills.append(skill)


func _get_reached_skill() -> Skill:
	if not _is_upgrade:
		return skill
	var upgraded := skill.duplicate()
	upgraded.upgrade(null)
	return upgraded
