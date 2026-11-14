class_name SkillFixture
extends RefCounted


static func add_rank(skill_data: SkillData, perk_count := 1) -> SkillRank:
	var rank := SkillRank.new()
	for index in perk_count:
		var perk := SkillPerk.new()
		perk.name = "Perk %d" % index
		rank.perks.append(perk)
	skill_data.ranks.append(rank)
	return rank


static func create_modifier(stat: SkillModifier.Stat, amount: int) -> SkillModifier:
	var modifier := SkillModifier.new()
	modifier.stat = stat
	modifier.amount = amount
	return modifier


static func create_damage(amount: int) -> DamageEffect:
	var damage := DamageEffect.new()
	damage.amount = amount
	return damage
