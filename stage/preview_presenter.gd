class_name PreviewPresenter
extends RefCounted
# The preview, written on stage over the fight: each nameplate's health and pips, the inspected character's cooldowns,
# and the rope. The stage and the brain write the fight; this writes over them once a frame, after any change to either
# model or to the choice. Without it, the stage shows the fight alone.

# Null once disposed: a refresh still queued writes nothing.
var _fight_model: FightModel
var _preview_model: FightModel
var _nameplates: Array[Nameplate] = []
var _skill_bar: SkillBar
var _timeline_rope: TimelineRope
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
	_fight_model.changed.connect(_queue_refresh)
	_preview_model.changed.connect(_queue_refresh)
	_queue_refresh()


func dispose() -> void:
	_fight_model.changed.disconnect(_queue_refresh)
	_preview_model.changed.disconnect(_queue_refresh)
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


# The fight's rope, styled by the preview: an action the preview resolves fades, unless it is the shown one; one it
# cancels is crossed out. The shown action, when the fight lacks it, hangs as a ghost where it would resolve. An action
# the preview moves keeps its medallion, and hangs a moved ghost, in the same style, where it last moves to.
static func get_timeline_entries(fight_model: FightModel, preview_model: FightModel, shown: Action) -> Array[TimelineEntry]:
	var actions: Array[Action] = fight_model.timeline.duplicate()
	var is_ghost_shown := shown != null and shown not in actions
	if is_ghost_shown:
		actions.insert(fight_model.get_timeline_index(shown.actor.id, shown.resolve_tick), shown)
	var moves: Dictionary[Action, int] = {}
	for action in fight_model.timeline:
		var moved_tick := preview_model.get_moved_tick(action.id)
		if moved_tick != -1:
			moves[action] = moved_tick
	var entries := TimelineEntry.create_entries(fight_model.tick, actions, moves)
	for entry in entries:
		if entry.is_knot():
			continue
		if is_ghost_shown and entry.action == shown:
			entry.is_ghost = true
		if preview_model.has_cancelled(entry.action.id):
			entry.style = TimelineEntry.Style.CROSSED
		elif preview_model.has_resolved(entry.action.id) and entry.action != shown:
			entry.style = TimelineEntry.Style.FADED
	return entries


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


func _show_cooldowns() -> void:
	var previewed := null if _inspected == null else _preview_model.get_character(_inspected.id)
	if previewed == null:
		return
	var skills := _inspected.data.skills
	for index in skills.size():
		var beats := FightRules.get_cooldown_beats(previewed, skills[index])
		_skill_bar.show_cooldown(index, beats, get_cooldown_style(_preview_model, _inspected, skills[index]))
