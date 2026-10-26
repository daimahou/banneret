class_name Delta
extends RefCounted
# What one step does to the fight: the ticks it moves on, and its changes in order. It applies nothing; the fight model applies it.

var ticks := 0
var changes: Array[Change] = []


func add_health(changed: Character, health_amount: int) -> void:
	var change := Change.Health.new()
	change.character_id = changed.id
	change.amount = health_amount
	changes.append(change)


func add_action(added: Action) -> void:
	var change := Change.AddAction.new()
	change.actor_id = added.actor.id
	change.skill = added.skill
	change.target_id = -1 if added.target == null else added.target.id
	change.resolve_tick = added.resolve_tick
	changes.append(change)


func add_cooldown(character: Character, skill: SkillData, beats: int) -> void:
	var change := Change.Cooldown.new()
	change.character_id = character.id
	change.skill = skill
	change.beats = beats
	changes.append(change)


func add_ap(changed: Character, ap_amount: int) -> void:
	var change := Change.Ap.new()
	change.character_id = changed.id
	change.amount = ap_amount
	changes.append(change)


func resolve_action(resolved: Action) -> void:
	var change := Change.ResolveAction.new()
	change.action_id = resolved.id
	changes.append(change)


func move_action(moved: Action, resolve_tick: int) -> void:
	var change := Change.MoveAction.new()
	change.action_id = moved.id
	change.resolve_tick = resolve_tick
	changes.append(change)


func cancel_action(cancelled: Action) -> void:
	var change := Change.CancelAction.new()
	change.action_id = cancelled.id
	changes.append(change)


# The character's health once this delta is applied.
func get_health(character: Character) -> int:
	var health := character.health
	for change in changes:
		if change is Change.Health and (change as Change.Health).character_id == character.id:
			health += (change as Change.Health).amount
	return health


# Spent AP counts below zero.
func get_ap_gain(character_id: int) -> int:
	var gain := 0
	for change in changes:
		if change is Change.Ap and (change as Change.Ap).character_id == character_id:
			gain += (change as Change.Ap).amount
	return gain


func is_removing_action(action: Action) -> bool:
	return is_resolving_action(action.id) or is_cancelling_action(action.id)


func is_resolving_action(action_id: int) -> bool:
	for change in changes:
		if change is Change.ResolveAction and (change as Change.ResolveAction).action_id == action_id:
			return true
	return false


# The tick this delta last moves the action of this id to, or -1.
func get_moved_tick(action_id: int) -> int:
	var moved_tick := -1
	for change in changes:
		if change is Change.MoveAction and (change as Change.MoveAction).action_id == action_id:
			moved_tick = (change as Change.MoveAction).resolve_tick
	return moved_tick


func is_cancelling_action(action_id: int) -> bool:
	for change in changes:
		if change is Change.CancelAction and (change as Change.CancelAction).action_id == action_id:
			return true
	return false
