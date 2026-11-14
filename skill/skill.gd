class_name Skill
extends RefCounted

enum Rank { BASIC, ADVANCED, EXPERT }

static var _next_id := 0

var id: int
var data: SkillData
var rank := Rank.BASIC
var perks: Array[SkillPerk] = []
# Carries from one fight to the next.
var cooldown_beats := 0


func _init(skill_data: SkillData) -> void:
	id = _next_id
	_next_id += 1
	data = skill_data


# Null at Expert, or where the next rank is not authored.
func get_next_rank() -> SkillRank:
	return data.ranks[rank] if rank < Rank.EXPERT and rank < data.ranks.size() else null


# Null raises the rank alone.
func upgrade(perk: SkillPerk) -> void:
	if get_next_rank() == null:
		push_error("%s has no rank to reach" % data.name)
		return
	rank = (rank + 1) as Rank
	if perk != null:
		perks.append(perk)


func get_rank_title() -> String:
	return Rank.find_key(rank).capitalize()


func get_delay() -> int:
	return _get_modified(SkillModifier.Stat.DELAY, data.delay)


func get_cooldown() -> int:
	return _get_modified(SkillModifier.Stat.COOLDOWN, data.cooldown)


func get_ap_cost() -> int:
	return _get_modified(SkillModifier.Stat.AP_COST, data.ap_cost)


func get_effects() -> Array[Effect]:
	var effects := data.effects.duplicate()
	for reached in _get_reached_ranks():
		effects.append_array(reached.effects)
	for perk in perks:
		effects.append_array(perk.effects)
	return effects


func get_description() -> String:
	var lines := PackedStringArray(["%d AP, delay %d" % [get_ap_cost(), get_delay()]])
	if get_cooldown() > 0:
		lines[0] += ", cooldown %d" % get_cooldown()
	for effect in get_effects():
		lines.append(effect.get_description())
	return "\n".join(lines)


func duplicate() -> Skill:
	var copy := Skill.new(data)
	copy.id = id
	copy.rank = rank
	copy.perks = perks.duplicate()
	copy.cooldown_beats = cooldown_beats
	return copy


func _get_reached_ranks() -> Array[SkillRank]:
	return data.ranks.slice(0, rank)


# A modifier never takes a stat below zero.
func _get_modified(stat: SkillModifier.Stat, base: int) -> int:
	var modifiers: Array[SkillModifier] = []
	for reached in _get_reached_ranks():
		modifiers.append_array(reached.modifiers)
	for perk in perks:
		modifiers.append_array(perk.modifiers)
	var value := base
	for modifier in modifiers:
		if modifier.stat == stat:
			value += modifier.amount
	return maxi(0, value)
