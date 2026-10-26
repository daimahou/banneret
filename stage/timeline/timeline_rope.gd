class_name TimelineRope
extends Node2D
# The timeline, strung across the top of the stage: a knot for each tick to come, and a medallion with its actor's portrait for each action, hung after the knot of the tick it resolves on.
# The rope's shape is its line's points, traced by hand over the rope drawn on the background; each thing on it hangs where the line passes. It hangs the entries it is told, each in its style: a ghost or a faded one at ghost alpha, a crossed one under a cross.

const KNOT_SCENE := preload("res://stage/timeline/timeline_knot.tscn")
const BEAT_KNOT_SCENE := preload("res://stage/timeline/timeline_beat_knot.tscn")
const MEDALLION_SCENE := preload("res://stage/timeline/timeline_medallion.tscn")

const KNOT_SPACING := 72.0
const MEDALLION_SPACING := 148.0
# Nothing hangs this close to either side of a tie.
const TIE_CLEARANCE := 24.0

const GHOST_ALPHA := 0.4

const MOVE_DURATION := 0.3
# A thing on the rope drops this far onto it as it comes, and lifts as far off it as it goes, in design units.
const LIFT := 24.0

var _shown_entries: Array[TimelineEntry] = []
var _entry_nodes: Dictionary[String, Node2D] = {}
var _entry_tweens: Dictionary[Node2D, Tween] = {}
var _highlighted_actors: Array[Character] = []

@onready var _rope: Line2D = $Rope
@onready var _ties: Node2D = $Ties
@onready var _entries: Node2D = $Entries


# Left to right.
func show_entries(entries: Array[TimelineEntry]) -> void:
	_shown_entries = entries
	_refresh()


# The medallions of these actors hang highlighted.
func set_marks(actors: Array[Character]) -> void:
	_highlighted_actors = actors
	_show_marks()


func clear_marks() -> void:
	_highlighted_actors = []
	_show_marks()


# The action whose medallion is under the point, in global space, or null. A ghost is no action yet.
func get_action_at(global_point: Vector2) -> Action:
	for entry in _shown_entries:
		var is_pending := not entry.is_knot() and not entry.is_ghost
		if is_pending and (_entry_nodes[entry.get_key()] as TimelineMedallion).has_point(global_point):
			return entry.action
	return null


func clear() -> void:
	_shown_entries = []
	_highlighted_actors = []
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


func _refresh() -> void:
	var placed: Dictionary[String, Node2D] = {}
	var tie_xs := _get_tie_xs()
	var x := _get_rope_start_x()
	for entry in _shown_entries:
		var spacing := KNOT_SPACING if entry.is_knot() else MEDALLION_SPACING
		x = _get_left_x_past_ties(x, spacing, tie_xs)
		x += spacing / 2.0
		var key := entry.get_key()
		var node: Node2D = _entry_nodes.get(key)
		if node == null:
			node = _add_entry_node(entry, x)
		else:
			# A ghost keeps its node as the hero or the skill changes.
			if not entry.is_knot():
				(node as TimelineMedallion).portrait = entry.portrait
			# A move cuts any fade in short, so it finishes the fade too.
			var tween := _create_entry_tween(node)
			tween.tween_property(node, "position", _get_rope_position(x), MOVE_DURATION)
			tween.tween_property(node, "modulate:a", _get_alpha(entry), MOVE_DURATION)
			tween.tween_property(node, "rotation" if entry.is_knot() else "knot_rotation", _get_rope_angle(x), MOVE_DURATION)
		if not entry.is_knot():
			(node as TimelineMedallion).set_cancelled(entry.style == TimelineEntry.Style.CROSSED)
		placed[key] = node
		x += spacing / 2.0
	for key in _entry_nodes:
		if not placed.has(key):
			_remove_entry_node(_entry_nodes[key])
	_entry_nodes = placed
	_show_marks()


func _show_marks() -> void:
	for entry in _shown_entries:
		if not entry.is_knot() and not entry.is_ghost:
			var medallion: TimelineMedallion = _entry_nodes[entry.get_key()]
			medallion.set_highlighted(entry.action.actor in _highlighted_actors)


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


func _add_entry_node(entry: TimelineEntry, x: float) -> Node2D:
	var node: Node2D
	if entry.is_knot():
		node = (BEAT_KNOT_SCENE if entry.is_beat else KNOT_SCENE).instantiate()
		node.rotation = _get_rope_angle(x)
	else:
		var medallion: TimelineMedallion = MEDALLION_SCENE.instantiate()
		medallion.portrait = entry.portrait
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


static func _get_alpha(entry: TimelineEntry) -> float:
	return GHOST_ALPHA if entry.is_ghost or entry.style == TimelineEntry.Style.FADED else 1.0


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
