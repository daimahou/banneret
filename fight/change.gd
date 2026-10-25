class_name Change
extends RefCounted
# One difference a delta makes to the fight; each kind is an inner class that applies itself.


func apply(_fight_model: FightModel) -> void:
	pass


class Health:
	extends Change

	var character: Character
	var amount: int

	func apply(fight_model: FightModel) -> void:
		character.health += amount
		fight_model.health_changed.emit(character, amount)
		if character.is_fallen():
			fight_model.character_fell.emit(character)


# On a shared tick the action chosen last resolves first.
class AddAction:
	extends Change

	var action: Action

	func apply(fight_model: FightModel) -> void:
		var index := fight_model.timeline.find_custom(func(other: Action) -> bool: return other.resolve_tick >= action.resolve_tick)
		fight_model.timeline.insert(fight_model.timeline.size() if index == -1 else index, action)
		fight_model.action_added.emit(action)


class Cooldown:
	extends Change

	var character: Character
	var skill: SkillData
	var beats: int

	func apply(_fight_model: FightModel) -> void:
		character.skill_cooldowns[skill] = beats


class Ap:
	extends Change

	var character: Character
	var amount: int

	func apply(fight_model: FightModel) -> void:
		character.ap += amount
		fight_model.ap_changed.emit(character)


class RemoveAction:
	extends Change

	var action: Action

	func apply(fight_model: FightModel) -> void:
		fight_model.timeline.erase(action)
		fight_model.action_removed.emit(action)
