class_name FightModel
extends RefCounted
# The fight's state: it changes only by applying a delta, and signals what changed.

signal tick_changed(tick: int)
@warning_ignore("unused_signal") signal health_changed(character: Character, amount: int)
@warning_ignore("unused_signal") signal character_fell(character: Character)
@warning_ignore("unused_signal") signal ap_changed(character: Character)
@warning_ignore("unused_signal") signal action_added(action: Action)
@warning_ignore("unused_signal") signal action_resolved(action: Action)
@warning_ignore("unused_signal") signal action_cancelled(action: Action)
@warning_ignore("unused_signal") signal action_moved(action: Action)
signal changed

enum Side { HERO, ENEMY }

var tick := 0
var heroes: Array[Character] = []
var enemies: Array[Character] = []
# The pending actions, in the order they resolve.
var timeline: Array[Action] = []
var next_action_id := 0
var history: Array[Delta] = []


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
	changed.emit()


# The history is not copied: a preview's history holds only what the preview plays out.
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


func get_next_action() -> Action:
	return null if timeline.is_empty() else timeline[0]


# On a shared tick, the action chosen last resolves first, to counter what is there; but an actor's own actions resolve in the order they were chosen.
func get_timeline_index(actor_id: int, resolve_tick: int) -> int:
	var resolves_after_it := func(action: Action) -> bool:
		return action.resolve_tick > resolve_tick or action.resolve_tick == resolve_tick and action.actor.id != actor_id
	var index := timeline.find_custom(resolves_after_it)
	return timeline.size() if index == -1 else index


func get_character(character_id: int) -> Character:
	for character in heroes + enemies:
		if character.id == character_id:
			return character
	return null


func get_action(action_id: int) -> Action:
	for action in timeline:
		if action.id == action_id:
			return action
	return null


func has_resolved(action_id: int) -> bool:
	return history.any(func(delta: Delta) -> bool: return delta.is_resolving_action(action_id))


func has_cancelled(action_id: int) -> bool:
	return history.any(func(delta: Delta) -> bool: return delta.is_cancelling_action(action_id))


func get_moved_tick(action_id: int) -> int:
	var moved_tick := -1
	for delta in history:
		var delta_tick := delta.get_moved_tick(action_id)
		if delta_tick != -1:
			moved_tick = delta_tick
	return moved_tick


func get_lowest_ap(character_id: int) -> int:
	var ap := get_character(character_id).ap
	var lowest := ap
	for index in range(history.size() - 1, -1, -1):
		ap -= history[index].get_ap_gain(character_id)
		lowest = mini(lowest, ap)
	return lowest


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
