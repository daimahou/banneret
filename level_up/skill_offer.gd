class_name SkillOffer
extends LevelUpOffer

# The hero's own skill for an upgrade, or a new one built for them.
var skill: Skill
var rank: Skill.Rank


func _init(offered_skill: Skill, offered_rank: Skill.Rank) -> void:
	skill = offered_skill
	rank = offered_rank


func is_upgrade() -> bool:
	return rank > skill.rank


func get_name() -> String:
	return skill.data.name


func get_icon() -> Texture2D:
	return skill.data.icon


func get_reached_rank_title() -> String:
	return Skill.get_title(rank)


func get_description_before_perk() -> String:
	var reached := skill.duplicate()
	reached.rank = rank
	return reached.get_description()


func get_perks() -> Array[Perk]:
	var perks: Array[Perk] = []
	if is_upgrade():
		perks.assign(skill.get_next_rank().perks)
	return perks


func apply(hero: Character, perk: Perk) -> void:
	if is_upgrade():
		skill.upgrade(perk as SkillPerk)
	else:
		hero.skills.append(skill)
