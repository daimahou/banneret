class_name TalentOffer
extends LevelUpOffer

# The hero's own talent for an upgrade, or a new one built for them.
var talent: Talent

var _is_upgrade: bool


func _init(offered_talent: Talent, is_owned: bool) -> void:
	talent = offered_talent
	_is_upgrade = is_owned


func is_upgrade() -> bool:
	return _is_upgrade


func get_name() -> String:
	return talent.data.name


func get_icon() -> Texture2D:
	return talent.data.icon


func get_reached_rank_title() -> String:
	return _get_reached_talent().get_rank_title()


func get_description_before_perk() -> String:
	return _get_reached_talent().get_description()


func get_perks() -> Array[Perk]:
	var perks: Array[Perk] = []
	if _is_upgrade:
		perks.assign(talent.get_next_rank().perks)
	return perks


func apply(hero: Character, perk: Perk) -> void:
	if _is_upgrade:
		hero.upgrade_talent(talent, perk as TalentPerk)
	else:
		hero.add_talent(talent)


func _get_reached_talent() -> Talent:
	if not _is_upgrade:
		return talent
	var upgraded := talent.duplicate()
	upgraded.upgrade(null)
	return upgraded
