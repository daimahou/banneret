class_name HeroModifier
extends Resource

enum Stat { MAX_HEALTH, MAX_AP }

const STAT_NAMES: Dictionary[Stat, String] = { Stat.MAX_HEALTH: "Max health", Stat.MAX_AP: "Max AP" }

@export var stat := Stat.MAX_HEALTH
@export var amount: int


func get_description() -> String:
	return "%s %+d" % [STAT_NAMES[stat], amount]
