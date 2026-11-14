class_name SkillOffer
extends LevelUpOffer

# The hero's own skill for an upgrade, or a new one built for them.
var skill: Skill
var rank: Skill.Rank


func _init(offered_skill: Skill, offered_rank: Skill.Rank, eligible_perks: Array[Perk] = []) -> void:
	skill = offered_skill
	rank = offered_rank
	perks = eligible_perks


func is_upgrade() -> bool:
	return rank > skill.rank


func get_name() -> String:
	return skill.data.name


func get_icon() -> Texture2D:
	return skill.data.icon


func get_reached_rank_title() -> String:
	return Skill.get_title(rank)


func get_description() -> String:
	return skill.get_next_rank().get_description() if is_upgrade() else skill.get_description()


func apply(hero: Character, perk: Perk) -> void:
	if is_upgrade():
		hero.upgrade_skill(skill, perk as SkillPerk)
	else:
		hero.add_skill(skill)
