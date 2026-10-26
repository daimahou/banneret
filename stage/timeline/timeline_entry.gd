class_name TimelineEntry
extends RefCounted
# One thing on the rope: the knot of a tick, or an action resolving on it, shown in a style.

enum Style { NORMAL, FADED, CROSSED }

var tick := 0
# Null for a knot.
var action: Action
var is_beat := false
var portrait: Texture2D
# An action not chosen yet, hung faded where it would resolve.
var is_ghost := false
# A ghost of a pending action, where a preview would move it; its medallion stays where it is.
var is_moved := false
var style := Style.NORMAL


# The rope from left to right: a knot for each tick after the fight's, up to the beat at or after the last action, and
# each action after the knot of its tick. One due now comes before any knot; on a shared tick, the order given. A moved
# ghost hangs on the tick `moves` gives its action, after the actions there.
static func create_entries(fight_tick: int, actions: Array[Action], moves: Dictionary[Action, int]) -> Array[TimelineEntry]:
	var last_tick := fight_tick
	for hung in actions:
		last_tick = maxi(last_tick, hung.resolve_tick)
	for moved_tick in moves.values():
		last_tick = maxi(last_tick, moved_tick)
	last_tick = FightRules.get_beat_at_or_after(last_tick)
	var entries: Array[TimelineEntry] = []
	for entry_tick in range(fight_tick, last_tick + 1):
		if entry_tick > fight_tick:
			var knot := TimelineEntry.new()
			knot.tick = entry_tick
			knot.is_beat = FightRules.is_beat(entry_tick)
			entries.append(knot)
		for hung in actions:
			if hung.resolve_tick == entry_tick:
				entries.append(_create_medallion(entry_tick, hung))
		for moved in moves:
			if moves[moved] == entry_tick:
				var ghost := _create_medallion(entry_tick, moved)
				ghost.is_ghost = true
				ghost.is_moved = true
				entries.append(ghost)
	return entries


func is_knot() -> bool:
	return action == null


# What its node is known by from one show to the next: a knot by its tick, a medallion by its action's id, which a
# ghost shares with the action it becomes once chosen. A moved ghost is known apart from its action's medallion.
func get_key() -> String:
	if is_knot():
		return "knot %d" % tick
	return "%s %d" % ["moved" if is_moved else "action", action.id]


static func _create_medallion(entry_tick: int, hung: Action) -> TimelineEntry:
	var medallion := TimelineEntry.new()
	medallion.tick = entry_tick
	medallion.action = hung
	medallion.portrait = hung.actor.data.portrait
	return medallion
