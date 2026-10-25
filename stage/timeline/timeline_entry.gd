class_name TimelineEntry
extends RefCounted
# One thing on the rope: the knot of a tick, or an action resolving on it, shown in a style.

enum Style { NORMAL, GHOST, FADED, CROSSED }

var tick := 0
# Null for a knot.
var action: Action
var is_beat := false
var portrait: Texture2D
var style := Style.NORMAL


# The rope from left to right, `tick` the fight's: a knot for each tick to come, up to the beat at or after the last
# action, and each action after the knot of its tick. One due now comes before any knot; on a shared tick, the order given.
static func create_entries(tick: int, actions: Array[Action]) -> Array[TimelineEntry]:
	var last_tick := tick
	for action in actions:
		last_tick = maxi(last_tick, action.resolve_tick)
	last_tick = FightRules.get_beat_at_or_after(last_tick)
	var entries: Array[TimelineEntry] = []
	for entry_tick in range(tick, last_tick + 1):
		if entry_tick > tick:
			var knot := TimelineEntry.new()
			knot.tick = entry_tick
			knot.is_beat = FightRules.is_beat(entry_tick)
			entries.append(knot)
		for action in actions:
			if action.resolve_tick == entry_tick:
				var medallion := TimelineEntry.new()
				medallion.tick = entry_tick
				medallion.action = action
				medallion.portrait = action.actor.data.portrait
				entries.append(medallion)
	return entries


func is_knot() -> bool:
	return action == null


# What its node is known by from one show to the next: a knot by its tick, a medallion by its action's id, which a
# ghost shares with the action it becomes once chosen.
func get_key() -> String:
	return "knot %d" % tick if is_knot() else "action %d" % action.id
