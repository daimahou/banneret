class_name TalentOffer
extends LevelUpOffer

# The hero's own talent for an upgrade, or a new one built for them.
var talent: Talent
var rank: Skill.Rank


func _init(offered_talent: Talent, offered_rank: Skill.Rank, eligible_perks: Array[Perk] = []) -> void:
	talent = offered_talent
	rank = offered_rank
	perks = eligible_perks


func is_upgrade() -> bool:
	return rank > talent.rank


func get_name() -> String:
	return talent.data.name


func get_icon() -> Texture2D:
	return talent.data.icon


func get_reached_rank_title() -> String:
	return Skill.get_title(rank)


func get_description() -> String:
	return talent.get_next_rank().get_description() if is_upgrade() else talent.get_description()


func apply(hero: Character, perk: Perk) -> void:
	if is_upgrade():
		hero.upgrade_talent(talent, perk as TalentPerk)
	else:
		hero.add_talent(talent)
