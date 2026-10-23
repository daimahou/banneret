class_name FightModel
extends RefCounted
# The fight's state. It does nothing but apply a delta, and signal what changed.

signal tick_changed(tick: int)
signal health_changed(character: Character, amount: int)
signal character_fell(character: Character)
signal action_added(action: Action)
signal action_removed(action: Action)

enum Side { HERO, ENEMY }

var tick := 0
var heroes: Array[Character] = []
var enemies: Array[Character] = []
# The pending actions, in the order they resolve.
var timeline: Array[Action] = []


func _init(fight_heroes: Array[Character], fight_enemies: Array[Character]) -> void:
	heroes = fight_heroes
	enemies = fight_enemies


func apply(delta: Delta) -> void:
	if delta.ticks != 0:
		tick += delta.ticks
		tick_changed.emit(tick)
	for change in delta.changes:
		change.apply(self)


# Null when the timeline is empty.
func get_next_action() -> Action:
	return null if timeline.is_empty() else timeline[0]


func get_action(actor: Character) -> Action:
	for action in timeline:
		if action.actor == actor:
			return action
	return null


func get_side(character: Character) -> FightModel.Side:
	return FightModel.Side.HERO if character in heroes else FightModel.Side.ENEMY


func get_standing(side: FightModel.Side) -> Array[Character]:
	return (heroes if side == FightModel.Side.HERO else enemies).filter(func(character: Character) -> bool: return not character.is_fallen())


func is_over() -> bool:
	return get_standing(FightModel.Side.HERO).is_empty() or get_standing(FightModel.Side.ENEMY).is_empty()


func is_won() -> bool:
	return get_standing(FightModel.Side.ENEMY).is_empty() and not get_standing(FightModel.Side.HERO).is_empty()
