class_name TimelineRope
extends Node2D
# The timeline, strung across the top of the stage: a knot for each tick to come, and a medallion with the actor's portrait for each pending action, hung after the knot of the tick it resolves on.
# The rope's shape is its line's points, traced by hand over the rope drawn on the background; each thing on it hangs where the line passes. It follows the fight model, and changes nothing in it.

const KNOT_SCENE := preload("res://stage/timeline/timeline_knot.tscn")
const MEDALLION_SCENE := preload("res://stage/timeline/timeline_medallion.tscn")

const KNOT_SPACING := 68.0
const MEDALLION_SPACING := 224.0
# Nothing hangs this close to either side of a tie.
const TIE_CLEARANCE := 48.0

const MOVE_DURATION := 0.3
const LIFT := 48.0

var _fight_model: FightModel
# Each node on the rope by its entry's key.
var _nodes := {}
var _is_refresh_queued := false

@onready var _rope: Line2D = $Rope
@onready var _ties: Node2D = $Ties
@onready var _entries: Node2D = $Entries


# One thing on the rope: the knot of a tick, or an action resolving on it.
class Entry:
	extends RefCounted

	var tick := 0
	var action: Action

	func is_knot() -> bool:
		return action == null

	# What its node is known by from one change to the next: a knot by its tick, a medallion by its action.
	func get_key() -> Variant:
		return tick if is_knot() else action


# The rope from left to right. An action due now comes before any knot; on a shared tick, the timeline's order.
static func get_entries(fight_model: FightModel) -> Array[Entry]:
	var last_tick := fight_model.tick
	for action in fight_model.timeline:
		last_tick = maxi(last_tick, action.resolve_tick)
	var entries: Array[Entry] = []
	for tick in range(fight_model.tick, last_tick + 1):
		if tick > fight_model.tick:
			entries.append(_create_entry(tick, null))
		for action in fight_model.timeline:
			if action.resolve_tick == tick:
				entries.append(_create_entry(tick, action))
	return entries


static func _create_entry(tick: int, action: Action) -> Entry:
	var entry := Entry.new()
	entry.tick = tick
	entry.action = action
	return entry


# Hangs the fight's timeline on the rope, and follows it.
func show_fight(fight_model: FightModel) -> void:
	_fight_model = fight_model
	_fight_model.tick_changed.connect(_on_fight_changed)
	_fight_model.action_added.connect(_on_fight_changed)
	_fight_model.action_removed.connect(_on_fight_changed)
	_queue_refresh()


# Takes everything off the rope at once.
func clear() -> void:
	if _fight_model != null:
		_fight_model.tick_changed.disconnect(_on_fight_changed)
		_fight_model.action_added.disconnect(_on_fight_changed)
		_fight_model.action_removed.disconnect(_on_fight_changed)
		_fight_model = null
	for node: Node2D in _nodes.values():
		node.queue_free()
	_nodes.clear()


# Where the rope passes at x, both in the entries' space: the entries hang along it from their node's own x. Level off the rope's ends.
func get_rope_position(x: float) -> Vector2:
	var rope_x := _rope.to_local(_entries.to_global(Vector2(x, 0.0))).x
	var index := _get_rope_segment(rope_x)
	if index == -1:
		return Vector2(x, 0.0)
	var from := _rope.points[index]
	var to := _rope.points[index + 1]
	return _entries.to_local(_rope.to_global(from.lerp(to, inverse_lerp(from.x, to.x, rope_x))))


# The rope's angle at x, in the entries' space, for a knot tied in it.
func get_rope_angle(x: float) -> float:
	var rope_x := _rope.to_local(_entries.to_global(Vector2(x, 0.0))).x
	var index := _get_rope_segment(rope_x)
	if index == -1:
		return 0.0
	var from := _entries.to_local(_rope.to_global(_rope.points[index]))
	var to := _entries.to_local(_rope.to_global(_rope.points[index + 1]))
	return (to - from).angle()


# The line segment of the rope above x, in the rope's own space, or -1 off it.
func _get_rope_segment(rope_x: float) -> int:
	for index in _rope.points.size() - 1:
		if rope_x >= _rope.points[index].x and rope_x <= _rope.points[index + 1].x:
			return index
	return -1


func _on_fight_changed(_change: Variant) -> void:
	_queue_refresh()


# A delta changes the fight model several times at once; the rope moves once.
func _queue_refresh() -> void:
	if not _is_refresh_queued:
		_is_refresh_queued = true
		_refresh.call_deferred()


func _refresh() -> void:
	_is_refresh_queued = false
	if _fight_model == null:
		return
	var placed := {}
	var tie_xs := _get_tie_xs()
	var x := 0.0
	for entry in get_entries(_fight_model):
		var spacing := KNOT_SPACING if entry.is_knot() else MEDALLION_SPACING
		x = _get_clear_x(x, spacing, tie_xs)
		x += spacing / 2.0
		var key: Variant = entry.get_key()
		var node: Node2D = _nodes.get(key)
		if node == null:
			node = _add_entry_node(entry, x)
		else:
			var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
			tween.tween_property(node, "position", get_rope_position(x), MOVE_DURATION)
			if entry.is_knot():
				tween.tween_property(node, "rotation", get_rope_angle(x), MOVE_DURATION)
		placed[key] = node
		x += spacing / 2.0
	for key: Variant in _nodes:
		if not placed.has(key):
			_remove_entry_node(_nodes[key])
	_nodes = placed


# Where the ties hang, in the entries' space, left to right.
func _get_tie_xs() -> Array[float]:
	var tie_xs: Array[float] = []
	for tie: Marker2D in _ties.get_children():
		tie_xs.append(_entries.to_local(tie.global_position).x)
	tie_xs.sort()
	return tie_xs


# The first x from start where a thing that wide clears every tie.
func _get_clear_x(start: float, width: float, tie_xs: Array[float]) -> float:
	var x := start
	for tie_x in tie_xs:
		if x < tie_x + TIE_CLEARANCE and x + width > tie_x - TIE_CLEARANCE:
			x = tie_x + TIE_CLEARANCE
	return x


func _add_entry_node(entry: Entry, x: float) -> Node2D:
	var node: Node2D
	if entry.is_knot():
		node = KNOT_SCENE.instantiate()
		node.rotation = get_rope_angle(x)
	else:
		var medallion: TimelineMedallion = MEDALLION_SCENE.instantiate()
		medallion.portrait = entry.action.actor.data.portrait
		node = medallion
	var rope_position := get_rope_position(x)
	node.position = rope_position - Vector2(0.0, LIFT)
	node.modulate.a = 0.0
	_entries.add_child(node)
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "position:y", rope_position.y, MOVE_DURATION)
	tween.tween_property(node, "modulate:a", 1.0, MOVE_DURATION)
	return node


func _remove_entry_node(node: Node2D) -> void:
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "position:y", node.position.y - LIFT, MOVE_DURATION)
	tween.tween_property(node, "modulate:a", 0.0, MOVE_DURATION)
	tween.chain().tween_callback(node.queue_free)
