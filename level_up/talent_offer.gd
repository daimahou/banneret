class_name TalentOffer
extends LevelUpOffer

# The hero's own talent for an upgrade, or a new one built for them.
var talent: Talent
var rank: Skill.Rank


func _init(offered_talent: Talent, offered_rank: Skill.Rank) -> void:
	talent = offered_talent
	rank = offered_rank


func is_upgrade() -> bool:
	return rank > talent.rank


func get_name() -> String:
	return talent.data.name


func get_icon() -> Texture2D:
	return talent.data.icon


func get_reached_rank_title() -> String:
	return Skill.get_title(rank)


func get_description_before_perk() -> String:
	var reached := talent.duplicate()
	reached.rank = rank
	return reached.get_description()


func get_perks() -> Array[Perk]:
	var perks: Array[Perk] = []
	if is_upgrade():
		perks.assign(talent.get_next_rank().perks)
	return perks


func apply(hero: Character, perk: Perk) -> void:
	if is_upgrade():
		hero.upgrade_talent(talent, perk as TalentPerk)
	else:
		hero.add_talent(talent)
