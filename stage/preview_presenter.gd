class_name PreviewPresenter
extends RefCounted
# Writes the preview over the fight on stage: the nameplates, the inspected character's cooldowns and the rope. The stage and the brain write the fight.

const ARROW_GAP := 8.0
# Per unit of length, so a longer arrow runs under a shorter one.
const ARROW_SAG := 0.25

# Null once disposed: a refresh still queued writes nothing.
var _fight_model: FightModel
var _preview_model: FightModel
var _nameplates: Array[Nameplate] = []
var _skill_bar: SkillBar
var _timeline_rope: TimelineRope
var _preview_arrows: PreviewArrows
# Whose skills the bar shows, or null.
var _inspected: Character
# The action the preview plays out until it lands, or null.
var _shown_action: Action
var _is_refresh_queued := false


func _init(fight: FightModel, preview: FightModel, nameplates: Array[Nameplate], bar: SkillBar, rope: TimelineRope) -> void:
	_fight_model = fight
	_preview_model = preview
	_nameplates = nameplates
	_skill_bar = bar
	_timeline_rope = rope
	_preview_arrows = PreviewArrows.new()
	_timeline_rope.add_sibling(_preview_arrows)
	_fight_model.changed.connect(_queue_refresh)
	_preview_model.changed.connect(_queue_refresh)
	_queue_refresh()


func dispose() -> void:
	_fight_model.changed.disconnect(_queue_refresh)
	_preview_model.changed.disconnect(_queue_refresh)
	_preview_arrows.queue_free()
	_fight_model = null


func show_choice(inspected: Character, shown_action: Action) -> void:
	_inspected = inspected
	_shown_action = shown_action
	_queue_refresh()


static func get_health_style(preview_model: FightModel, character: Character) -> PreviewPulse.Style:
	return PreviewPulse.get_style(preview_model.get_character(character.id).health - character.health)


# A pip held now or once the preview lands shows held. It shows lost when spent by then, and gained when held by
# then but not all the way: gained, or spent and got back.
static func get_pip_states(preview_model: FightModel, character: Character) -> Array[Nameplate.Pip]:
	var previewed := preview_model.get_character(character.id)
	var lowest_ap := preview_model.get_lowest_ap(character.id)
	var states: Array[Nameplate.Pip] = []
	for index in character.data.max_ap:
		var is_held_previewed := index < previewed.ap
		if is_held_previewed and index >= lowest_ap:
			states.append(Nameplate.Pip.GAINED)
		elif index >= character.ap:
			states.append(Nameplate.Pip.EMPTY)
		else:
			states.append(Nameplate.Pip.HELD if is_held_previewed else Nameplate.Pip.LOST)
	return states


# Fewer beats left is better.
static func get_cooldown_style(preview_model: FightModel, character: Character, skill: SkillData) -> PreviewPulse.Style:
	var previewed := preview_model.get_character(character.id)
	var gain := FightRules.get_cooldown_beats(character, skill) - FightRules.get_cooldown_beats(previewed, skill)
	return PreviewPulse.get_style(gain)


static func get_timeline_entries(fight_model: FightModel, preview_model: FightModel, shown: Action) -> Array[TimelineEntry]:
	var actions: Array[Action] = fight_model.timeline.duplicate()
	var is_ghost_shown := shown != null and shown not in actions
	if is_ghost_shown:
		actions.insert(fight_model.get_timeline_index(shown.actor.id, shown.resolve_tick), shown)
	var medallions := TimelineEntry.create_medallions(actions)
	for medallion in medallions:
		medallion.is_ghost = is_ghost_shown and medallion.action == shown
		if preview_model.has_cancelled(medallion.action.id):
			medallion.style = TimelineEntry.Style.CROSSED
		elif preview_model.has_resolved(medallion.action.id) and medallion.action != shown:
			medallion.style = TimelineEntry.Style.FADED
	for action in fight_model.timeline:
		var moved_tick := preview_model.get_moved_tick(action.id)
		if moved_tick != -1:
			medallions.append(_create_moved_ghost(preview_model, action, moved_tick))
	return TimelineEntry.create_entries(fight_model.tick, medallions)


static func _create_moved_ghost(preview_model: FightModel, moved: Action, moved_tick: int) -> TimelineEntry:
	var ghost := TimelineEntry.create_medallion(moved)
	ghost.id = _get_moved_ghost_id(moved)
	ghost.tick = moved_tick
	ghost.is_ghost = true
	var is_cancelled := preview_model.has_cancelled(moved.id)
	ghost.style = TimelineEntry.Style.CROSSED if is_cancelled else TimelineEntry.Style.MOVED
	return ghost


static func _get_moved_ghost_id(moved: Action) -> String:
	return "moved %d" % moved.id


func _queue_refresh() -> void:
	if not _is_refresh_queued:
		_is_refresh_queued = true
		_refresh.call_deferred()


func _refresh() -> void:
	_is_refresh_queued = false
	if _fight_model == null:
		return
	for nameplate in _nameplates:
		# Null for a nameplate unused, or showing a character of another fight.
		var previewed := null if nameplate.character == null else _preview_model.get_character(nameplate.character.id)
		if previewed != null:
			var style := get_health_style(_preview_model, nameplate.character)
			nameplate.show_health(previewed.health, previewed.data.max_health, style)
			nameplate.show_pips(get_pip_states(_preview_model, nameplate.character))
	_show_cooldowns()
	_timeline_rope.show_entries(get_timeline_entries(_fight_model, _preview_model, _shown_action))
	_preview_arrows.show_arrows(_get_arrows())


func _show_cooldowns() -> void:
	var previewed := null if _inspected == null else _preview_model.get_character(_inspected.id)
	if previewed == null:
		return
	var skills := _inspected.data.skills
	for index in skills.size():
		var beats := FightRules.get_cooldown_beats(previewed, skills[index])
		_skill_bar.show_cooldown(index, beats, get_cooldown_style(_preview_model, _inspected, skills[index]))


func _get_arrows() -> Array[PreviewArrows.Arrow]:
	var ring_bottoms := _timeline_rope.get_ring_bottoms()
	var arrows: Array[PreviewArrows.Arrow] = []
	for action in _fight_model.timeline:
		if _preview_model.get_moved_tick(action.id) != -1:
			var start := _timeline_rope.get_ring_bottom(TimelineEntry.get_medallion_id(action))
			var end := _timeline_rope.get_ring_bottom(_get_moved_ghost_id(action))
			arrows.append(_create_arrow(start, end, ring_bottoms))
	return arrows


static func _create_arrow(start: Vector2, end: Vector2, ring_bottoms: Array[Vector2]) -> PreviewArrows.Arrow:
	var gap := Vector2(0.0, ARROW_GAP)
	var arrow := PreviewArrows.Arrow.new()
	arrow.start = start + gap
	arrow.end = end + gap
	# A quadratic curve reaches only halfway to its control point.
	var control_y := maxf(arrow.start.y, arrow.end.y) + 2.0 * ARROW_SAG * absf(arrow.end.x - arrow.start.x)
	for ring_bottom in ring_bottoms:
		var weight := inverse_lerp(arrow.start.x, arrow.end.x, ring_bottom.x)
		if weight > 0.0 and weight < 1.0:
			var ends_y := (1.0 - weight) * (1.0 - weight) * arrow.start.y + weight * weight * arrow.end.y
			control_y = maxf(control_y, (ring_bottom.y + ARROW_GAP - ends_y) / (2.0 * weight * (1.0 - weight)))
	arrow.control = Vector2((arrow.start.x + arrow.end.x) / 2.0, control_y)
	return arrow
