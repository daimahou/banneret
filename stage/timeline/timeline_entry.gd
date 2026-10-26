class_name TimelineEntry
extends RefCounted
# One thing on the rope: the knot of a tick, or an action resolving on it, shown in a style.

enum Style { NORMAL, FADED, CROSSED, MOVED }

# What its node is known by from one show to the next. A choice's ghost takes the id its action will have, to become it once chosen.
var id: String
var tick := 0
# Null for a knot.
var action: Action
var is_beat := false
var portrait: Texture2D
# Not on the fight's timeline: a choice not made yet, or an action where the preview moves it.
var is_ghost := false
var style := Style.NORMAL


# Medallions on a shared tick hang in the order given; one due now hangs before any knot.
static func create_entries(fight_tick: int, medallions: Array[TimelineEntry]) -> Array[TimelineEntry]:
	var last_tick := fight_tick
	for medallion in medallions:
		last_tick = maxi(last_tick, medallion.tick)
	last_tick = FightRules.get_beat_at_or_after(last_tick)
	var entries: Array[TimelineEntry] = []
	for entry_tick in range(fight_tick, last_tick + 1):
		if entry_tick > fight_tick:
			var knot := TimelineEntry.new()
			knot.id = "knot %d" % entry_tick
			knot.tick = entry_tick
			knot.is_beat = FightRules.is_beat(entry_tick)
			entries.append(knot)
		for medallion in medallions:
			if medallion.tick == entry_tick:
				entries.append(medallion)
	return entries


static func create_medallions(actions: Array[Action]) -> Array[TimelineEntry]:
	var medallions: Array[TimelineEntry] = []
	for hung in actions:
		medallions.append(create_medallion(hung))
	return medallions


static func create_medallion(hung: Action) -> TimelineEntry:
	var medallion := TimelineEntry.new()
	medallion.id = get_medallion_id(hung)
	medallion.tick = hung.resolve_tick
	medallion.action = hung
	medallion.portrait = hung.actor.data.portrait
	return medallion


static func get_medallion_id(hung: Action) -> String:
	return "action %d" % hung.id


func is_knot() -> bool:
	return action == null
