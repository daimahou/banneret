class_name TalentFixture
extends RefCounted


static func create_talent_data(talent_name: String) -> TalentData:
	var talent_data := TalentData.new()
	talent_data.name = talent_name
	return talent_data


static func add_rank(talent_data: TalentData, perk_count := 1) -> TalentRank:
	var rank := TalentRank.new()
	for index in perk_count:
		var perk := TalentPerk.new()
		perk.name = "Perk %d" % index
		rank.perks.append(perk)
	talent_data.ranks.append(rank)
	return rank


static func create_modifier(stat: HeroModifier.Stat, amount: int) -> HeroModifier:
	var modifier := HeroModifier.new()
	modifier.stat = stat
	modifier.amount = amount
	return modifier
