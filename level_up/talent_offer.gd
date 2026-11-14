class_name TalentOffer
extends LevelUpOffer

var talent_data: TalentData
# Null for a new talent.
var talent: Talent


func _init(offered_talent_data: TalentData, upgraded_talent: Talent = null) -> void:
	talent_data = offered_talent_data
	talent = upgraded_talent


func is_upgrade() -> bool:
	return talent != null


func get_name() -> String:
	return talent_data.name


func get_icon() -> Texture2D:
	return talent_data.icon


func get_reached_rank_title() -> String:
	return _create_talent_before_perk().get_rank_title()


func get_description_before_perk() -> String:
	return _create_talent_before_perk().get_description()


func get_perks() -> Array[Perk]:
	var perks: Array[Perk] = []
	if is_upgrade():
		perks.assign(talent.get_next_rank().perks)
	return perks


func apply(hero: Character, perk: Perk) -> void:
	if is_upgrade():
		hero.upgrade_talent(talent, perk as TalentPerk)
	else:
		hero.add_talent(Talent.new(talent_data))


func _create_talent_before_perk() -> Talent:
	if not is_upgrade():
		return Talent.new(talent_data)
	var offered := talent.duplicate()
	offered.upgrade(null)
	return offered
