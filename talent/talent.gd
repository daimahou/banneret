class_name Talent
extends RefCounted

var data: TalentData
var rank := Skill.Rank.BASIC
var perks: Array[TalentPerk] = []


func _init(talent_data: TalentData) -> void:
	data = talent_data


# Null at Expert, or where the next rank is not authored.
func get_next_rank() -> TalentRank:
	return data.ranks[rank] if rank < Skill.Rank.EXPERT and rank < data.ranks.size() else null


# Null raises the rank alone.
func upgrade(perk: TalentPerk) -> void:
	if get_next_rank() == null:
		push_error("%s has no rank to reach" % data.name)
		return
	rank = (rank + 1) as Skill.Rank
	if perk != null:
		perks.append(perk)


func get_rank_title() -> String:
	return Skill.get_title(rank)


func get_amount(stat: HeroModifier.Stat) -> int:
	var amount := 0
	for modifier in _get_modifiers():
		if modifier.stat == stat:
			amount += modifier.amount
	return amount


func get_description() -> String:
	return "\n".join(_get_modifiers().map(func(modifier: HeroModifier) -> String: return modifier.get_description()))


func duplicate() -> Talent:
	var copy := Talent.new(data)
	copy.rank = rank
	copy.perks = perks.duplicate()
	return copy


func _get_modifiers() -> Array[HeroModifier]:
	var modifiers := data.modifiers.duplicate()
	for reached in data.ranks.slice(0, rank):
		modifiers.append_array(reached.modifiers)
	for perk in perks:
		modifiers.append_array(perk.modifiers)
	return modifiers
