class_name FightModel
extends RefCounted
# The fight's state. It does nothing but apply a delta, and signal what changed.

signal tick_changed(tick: int)
@warning_ignore("unused_signal") signal health_changed(character: Character, amount: int)
@warning_ignore("unused_signal") signal character_fell(character: Character)
@warning_ignore("unused_signal") signal ap_changed(character: Character)
@warning_ignore("unused_signal") signal action_added(action: Action)
@warning_ignore("unused_signal") signal action_resolved(action: Action)
@warning_ignore("unused_signal") signal action_cancelled(action: Action)
signal changed

enum Side { HERO, ENEMY }

var tick := 0
var heroes: Array[Character] = []
var enemies: Array[Character] = []
# The pending actions, in the order they resolve.
var timeline: Array[Action] = []
var next_action_id := 0
# The deltas applied, in order: since the fight started, or on a preview since its last sync.
var history: Array[Delta] = []

# The fight as it will stand once an action lands, played out on copies of this fight's characters and actions.
# Built on first use; from then on it syncs after every delta applied here.
var preview: FightModel:
	get:
		if _preview == null:
			# `FightModel.new` here would hold this script to itself, and leak it at exit.
			_preview = new([], [])
			_preview.sync(self)
		return _preview

var _preview: FightModel


func _init(fight_heroes: Array[Character], fight_enemies: Array[Character]) -> void:
	heroes = fight_heroes
	enemies = fight_enemies


func apply(delta: Delta) -> void:
	if delta.ticks != 0:
		tick += delta.ticks
		tick_changed.emit(tick)
	for change in delta.changes:
		change.apply(self)
	history.append(delta)
	if _preview != null:
		_preview.sync(self)
	changed.emit()


# Becomes a copy of `fight_model`, keeping nothing of its own but an empty history.
func sync(fight_model: FightModel) -> void:
	tick = fight_model.tick
	next_action_id = fight_model.next_action_id
	heroes = _duplicate_characters(fight_model.heroes)
	enemies = _duplicate_characters(fight_model.enemies)
	timeline = []
	for action in fight_model.timeline:
		var copy := Action.new()
		copy.id = action.id
		copy.actor = get_character(action.actor.id)
		copy.skill = action.skill
		copy.target = get_character(action.target.id)
		copy.resolve_tick = action.resolve_tick
		timeline.append(copy)
	history = []
	changed.emit()


# Null when the timeline is empty.
func get_next_action() -> Action:
	return null if timeline.is_empty() else timeline[0]


# Null for an id not in this fight, -1 included.
func get_character(character_id: int) -> Character:
	for character in heroes + enemies:
		if character.id == character_id:
			return character
	return null


# The pending action of this id, or null.
func get_action(action_id: int) -> Action:
	for action in timeline:
		if action.id == action_id:
			return action
	return null


# Whether an action of this id resolved, or was cancelled, in the history.
func has_resolved(action_id: int) -> bool:
	return history.any(func(delta: Delta) -> bool: return delta.is_resolving_action(action_id))


func has_cancelled(action_id: int) -> bool:
	return history.any(func(delta: Delta) -> bool: return delta.is_cancelling_action(action_id))


func get_side(character: Character) -> FightModel.Side:
	return FightModel.Side.HERO if character in heroes else FightModel.Side.ENEMY


func get_standing(side: FightModel.Side) -> Array[Character]:
	return (heroes if side == FightModel.Side.HERO else enemies).filter(func(character: Character) -> bool: return not character.is_fallen())


func is_over() -> bool:
	return get_standing(FightModel.Side.HERO).is_empty() or get_standing(FightModel.Side.ENEMY).is_empty()


func is_won() -> bool:
	return get_standing(FightModel.Side.ENEMY).is_empty() and not get_standing(FightModel.Side.HERO).is_empty()


static func _duplicate_characters(characters: Array[Character]) -> Array[Character]:
	var copies: Array[Character] = []
	for character in characters:
		copies.append(character.duplicate())
	return copies
