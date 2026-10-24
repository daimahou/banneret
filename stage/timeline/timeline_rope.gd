class_name TimelineRope
extends Node2D
# The timeline, strung across the top of the stage: a knot for each tick to come, and a medallion with the actor's portrait for each pending action, hung after the knot of the tick it resolves on.
# The rope's shape is its line's points, traced by hand over the rope drawn on the background; each thing on it hangs where the line passes. It follows the fight model, and changes nothing in it.
# A ghost, an action not yet chosen, hangs faded where it would resolve.

const KNOT_SCENE := preload("res://stage/timeline/timeline_knot.tscn")
const BEAT_KNOT_SCENE := preload("res://stage/timeline/timeline_beat_knot.tscn")
const MEDALLION_SCENE := preload("res://stage/timeline/timeline_medallion.tscn")

const KNOT_SPACING := 72.0
const MEDALLION_SPACING := 148.0
# Nothing hangs this close to either side of a tie.
const TIE_CLEARANCE := 24.0

const GHOST_ALPHA := 0.4
const GHOST_KEY := &"ghost"

const MOVE_DURATION := 0.3
# A thing on the rope drops this far onto it as it comes, and lifts as far off it as it goes, in design units.
const LIFT := 24.0

var _fight_model: FightModel
var _entry_nodes: Dictionary[Variant, Node2D] = {}
var _entry_tweens: Dictionary[Node2D, Tween] = {}
var _is_refresh_queued := false
var _ghost_action: Action
var _highlighted_actors: Array[Character] = []
var _dropped_action: Action

@onready var _rope: Line2D = $Rope
@onready var _ties: Node2D = $Ties
@onready var _entries: Node2D = $Entries


# One thing on the rope: the knot of a tick, or an action resolving on it.
class Entry:
	extends RefCounted

	var tick := 0
	var action: Action
	var is_ghost := false

	func _init(entry_tick: int, entry_action: Action, entry_is_ghost := false) -> void:
		tick = entry_tick
		action = entry_action
		is_ghost = entry_is_ghost

	func is_knot() -> bool:
		return action == null

	# What its node is known by from one change to the next: a knot by its tick, a medallion by its action, the ghost by itself.
	func get_key() -> Variant:
		if is_ghost:
			return GHOST_KEY
		return tick if is_knot() else action


# The rope from left to right. An action due now comes before any knot; on a shared tick, the timeline's order, after the ghost: chosen last, it would resolve first.
static func _get_entries(fight_model: FightModel, ghost_action: Action) -> Array[Entry]:
	var last_tick := fight_model.tick
	for action in fight_model.timeline:
		last_tick = maxi(last_tick, action.resolve_tick)
	if ghost_action != null:
		last_tick = maxi(last_tick, ghost_action.resolve_tick)
	last_tick = FightRules.get_beat_at_or_after(last_tick)
	var entries: Array[Entry] = []
	for tick in range(fight_model.tick, last_tick + 1):
		if tick > fight_model.tick:
			entries.append(Entry.new(tick, null))
		if ghost_action != null and ghost_action.resolve_tick == tick:
			entries.append(Entry.new(tick, ghost_action, true))
		for action in fight_model.timeline:
			if action.resolve_tick == tick:
				entries.append(Entry.new(tick, action))
	return entries


func show_fight(fight_model: FightModel) -> void:
	_fight_model = fight_model
	_fight_model.tick_changed.connect(_on_fight_changed)
	_fight_model.action_added.connect(_on_fight_changed)
	_fight_model.action_removed.connect(_on_fight_changed)
	_queue_refresh()


func show_ghost(action: Action) -> void:
	_ghost_action = action
	_queue_refresh()


func hide_ghost() -> void:
	_ghost_action = null
	_queue_refresh()


# The medallions of these actors hang highlighted; the dropped action's is crossed out.
func set_marks(actors: Array[Character], dropped: Action) -> void:
	_highlighted_actors = actors
	_dropped_action = dropped
	_show_marks()


# The pending action whose medallion is under the point, in global space, or null.
func get_action_at(global_point: Vector2) -> Action:
	for key: Variant in _entry_nodes:
		if key is Action and (_entry_nodes[key] as TimelineMedallion).has_point(global_point):
			return key
	return null


func clear() -> void:
	_ghost_action = null
	_highlighted_actors = []
	_dropped_action = null
	if _fight_model != null:
		_fight_model.tick_changed.disconnect(_on_fight_changed)
		_fight_model.action_added.disconnect(_on_fight_changed)
		_fight_model.action_removed.disconnect(_on_fight_changed)
		_fight_model = null
	for tween in _entry_tweens.values():
		tween.kill()
	_entry_tweens.clear()
	for node in _entry_nodes.values():
		node.queue_free()
	_entry_nodes.clear()


# Where the rope passes at x, both in the entries' space. Past either end, level with that end.
func _get_rope_position(x: float) -> Vector2:
	var rope_x := _convert_entries_to_rope_x(x)
	var index := _get_rope_segment(rope_x)
	if index == -1:
		var end := _rope.points[0] if rope_x < _rope.points[0].x else _rope.points[-1]
		return _convert_rope_to_entries_point(Vector2(rope_x, end.y))
	var from := _rope.points[index]
	var to := _rope.points[index + 1]
	var weight := inverse_lerp(from.x, to.x, rope_x)
	return _convert_rope_to_entries_point(from.lerp(to, weight))


# The rope's angle at x, in the entries' space, for a knot tied in it.
func _get_rope_angle(x: float) -> float:
	var index := _get_rope_segment(_convert_entries_to_rope_x(x))
	if index == -1:
		return 0.0
	var from := _convert_rope_to_entries_point(_rope.points[index])
	var to := _convert_rope_to_entries_point(_rope.points[index + 1])
	return (to - from).angle()


# The rope's first point, in the entries' space: the first entry hangs from there.
func _get_rope_start_x() -> float:
	return _convert_rope_to_entries_point(_rope.points[0]).x


func _convert_rope_to_entries_point(rope_point: Vector2) -> Vector2:
	return _entries.to_local(_rope.to_global(rope_point))


func _convert_entries_to_rope_x(x: float) -> float:
	return _rope.to_local(_entries.to_global(Vector2(x, 0.0))).x


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
	var placed: Dictionary[Variant, Node2D] = {}
	var tie_xs := _get_tie_xs()
	var x := _get_rope_start_x()
	for entry in _get_entries(_fight_model, _ghost_action):
		var spacing := KNOT_SPACING if entry.is_knot() else MEDALLION_SPACING
		x = _get_left_x_past_ties(x, spacing, tie_xs)
		x += spacing / 2.0
		var key: Variant = entry.get_key()
		var node: Node2D = _entry_nodes.get(key)
		if node == null:
			node = _add_entry_node(entry, x)
		else:
			if entry.is_ghost:
				(node as TimelineMedallion).portrait = entry.action.actor.data.portrait
			# A move cuts any fade in short, so it finishes the fade too.
			var tween := _create_entry_tween(node)
			tween.tween_property(node, "position", _get_rope_position(x), MOVE_DURATION)
			tween.tween_property(node, "modulate:a", _get_alpha(entry), MOVE_DURATION)
			tween.tween_property(node, "rotation" if entry.is_knot() else "knot_rotation", _get_rope_angle(x), MOVE_DURATION)
		placed[key] = node
		x += spacing / 2.0
	for key: Variant in _entry_nodes:
		if not placed.has(key):
			_remove_entry_node(_entry_nodes[key])
	_entry_nodes = placed
	_show_marks()


func _show_marks() -> void:
	for key: Variant in _entry_nodes:
		if key is Action:
			var medallion: TimelineMedallion = _entry_nodes[key]
			medallion.set_highlighted((key as Action).actor in _highlighted_actors)
			medallion.set_dropped(key == _dropped_action)


# Where the ties hang, in the entries' space, left to right.
func _get_tie_xs() -> Array[float]:
	var tie_xs: Array[float] = []
	for tie: Marker2D in _ties.get_children():
		tie_xs.append(_entries.to_local(tie.global_position).x)
	tie_xs.sort()
	return tie_xs


# The left edge for an entry `width` wide: `left_x`, or pushed right past any tie the entry would cover, `TIE_CLEARANCE` kept on both sides of the tie.
func _get_left_x_past_ties(left_x: float, width: float, tie_xs: Array[float]) -> float:
	var x := left_x
	for tie_x in tie_xs:
		if x < tie_x + TIE_CLEARANCE and x + width > tie_x - TIE_CLEARANCE:
			x = tie_x + TIE_CLEARANCE
	return x


func _add_entry_node(entry: Entry, x: float) -> Node2D:
	var node: Node2D
	if entry.is_knot():
		node = (BEAT_KNOT_SCENE if FightRules.is_beat(entry.tick) else KNOT_SCENE).instantiate()
		node.rotation = _get_rope_angle(x)
	else:
		var medallion: TimelineMedallion = MEDALLION_SCENE.instantiate()
		medallion.portrait = entry.action.actor.data.portrait
		medallion.knot_rotation = _get_rope_angle(x)
		node = medallion
	var rope_position := _get_rope_position(x)
	node.position = rope_position - Vector2(0.0, LIFT)
	node.modulate.a = 0.0
	_entries.add_child(node)
	var tween := _create_entry_tween(node)
	tween.tween_property(node, "position:y", rope_position.y, MOVE_DURATION)
	tween.tween_property(node, "modulate:a", _get_alpha(entry), MOVE_DURATION)
	return node


static func _get_alpha(entry: Entry) -> float:
	return GHOST_ALPHA if entry.is_ghost else 1.0


func _remove_entry_node(node: Node2D) -> void:
	var tween := _create_entry_tween(node)
	tween.tween_property(node, "position:y", node.position.y - LIFT, MOVE_DURATION)
	tween.tween_property(node, "modulate:a", 0.0, MOVE_DURATION)
	tween.chain().tween_callback(_free_entry_node.bind(node))


func _free_entry_node(node: Node2D) -> void:
	_entry_tweens.erase(node)
	node.queue_free()


# Stops the tween already moving the node, if any.
func _create_entry_tween(node: Node2D) -> Tween:
	if _entry_tweens.has(node):
		_entry_tweens[node].kill()
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	_entry_tweens[node] = tween
	return tween
