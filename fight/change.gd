class_name Change
extends RefCounted
# One difference a delta makes to the fight; each kind is an inner class that applies itself.
# A change names characters and actions by id, so the same delta applies to the fight or to its preview.


func apply(_fight_model: FightModel) -> void:
	pass


class Health:
	extends Change

	var character_id: int
	var amount: int

	func apply(fight_model: FightModel) -> void:
		var character := fight_model.get_character(character_id)
		character.health += amount
		fight_model.health_changed.emit(character, amount)
		if character.is_fallen():
			fight_model.character_fell.emit(character)


# The fight model holds its own action, with the next id.
class AddAction:
	extends Change

	var actor_id: int
	var skill: SkillData
	# -1 for no target.
	var target_id: int
	var resolve_tick: int

	func apply(fight_model: FightModel) -> void:
		var action := Action.new()
		action.id = fight_model.next_action_id
		fight_model.next_action_id += 1
		action.actor = fight_model.get_character(actor_id)
		action.skill = skill
		action.target = fight_model.get_character(target_id)
		action.resolve_tick = resolve_tick
		fight_model.timeline.insert(fight_model.get_timeline_index(actor_id, resolve_tick), action)
		fight_model.action_added.emit(action)


class Cooldown:
	extends Change

	var character_id: int
	var skill: SkillData
	var beats: int

	func apply(fight_model: FightModel) -> void:
		fight_model.get_character(character_id).skill_cooldowns[skill] = beats


class Ap:
	extends Change

	var character_id: int
	var amount: int

	func apply(fight_model: FightModel) -> void:
		var character := fight_model.get_character(character_id)
		character.ap += amount
		fight_model.ap_changed.emit(character)


class ResolveAction:
	extends Change

	var action_id: int

	func apply(fight_model: FightModel) -> void:
		var action := fight_model.get_action(action_id)
		fight_model.timeline.erase(action)
		fight_model.action_resolved.emit(action)


# The action resolves on its new tick after the actions already there.
class MoveAction:
	extends Change

	var action_id: int
	var resolve_tick: int

	func apply(fight_model: FightModel) -> void:
		var action := fight_model.get_action(action_id)
		fight_model.timeline.erase(action)
		action.resolve_tick = resolve_tick
		var resolves_after_it := func(other: Action) -> bool: return other.resolve_tick > resolve_tick
		var index := fight_model.timeline.find_custom(resolves_after_it)
		fight_model.timeline.insert(fight_model.timeline.size() if index == -1 else index, action)
		fight_model.action_moved.emit(action)


class CancelAction:
	extends Change

	var action_id: int

	func apply(fight_model: FightModel) -> void:
		var action := fight_model.get_action(action_id)
		fight_model.timeline.erase(action)
		fight_model.action_cancelled.emit(action)
