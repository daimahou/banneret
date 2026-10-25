class_name Delta
extends RefCounted
# What one step does to the fight: the ticks it moves on, and its changes in order. It applies nothing; the fight model applies it.

var ticks := 0
var changes: Array[Change] = []


func add_health(changed: Character, health_amount: int) -> void:
	var change := Change.Health.new()
	change.character = changed
	change.amount = health_amount
	changes.append(change)


func add_action(added: Action) -> void:
	var change := Change.AddAction.new()
	change.action = added
	changes.append(change)


func add_cooldown(character: Character, skill: SkillData, beats: int) -> void:
	var change := Change.Cooldown.new()
	change.character = character
	change.skill = skill
	change.beats = beats
	changes.append(change)


func remove_action(removed_actor: Character) -> void:
	var change := Change.RemoveAction.new()
	change.actor = removed_actor
	changes.append(change)


# The character's health once this delta is applied.
func get_health(character: Character) -> int:
	var health := character.health
	for change in changes:
		if change is Change.Health and (change as Change.Health).character == character:
			health += (change as Change.Health).amount
	return health


func is_removing_action(actor: Character) -> bool:
	return changes.any(func(change: Change) -> bool: return change is Change.RemoveAction and (change as Change.RemoveAction).actor == actor)
