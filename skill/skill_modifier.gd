class_name SkillModifier
extends Resource

enum Stat { DELAY, COOLDOWN, AP_COST }

const STAT_NAMES: Dictionary[Stat, String] = { Stat.DELAY: "Delay", Stat.COOLDOWN: "Cooldown", Stat.AP_COST: "AP" }

@export var stat := Stat.DELAY
@export var amount: int


func get_description() -> String:
	return "%s %+d" % [STAT_NAMES[stat], amount]
