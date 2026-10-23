class_name FightRules
# The rules of a fight: given the fight model and one action, the delta it makes. They apply nothing, and nothing in them is random.


# Every action the character could choose now: each of its skills, on each standing character of the other side.
static func get_choices(fight_model: FightModel, character: Character) -> Array[Action]:
	var other_side := FightModel.Side.ENEMY if fight_model.get_side(character) == FightModel.Side.HERO else FightModel.Side.HERO
	var choices: Array[Action] = []
	for skill in character.data.skills:
		for target in fight_model.get_standing(other_side):
			var choice := Action.new()
			choice.actor = character
			choice.skill = skill
			choice.target = target
			choice.resolve_tick = fight_model.tick + skill.delay
			choices.append(choice)
	return choices


static func get_timeline_delta(choice: Action) -> Delta:
	var delta := Delta.new()
	delta.add_action(choice)
	return delta


# The action resolved, the fight moved on to its tick.
static func get_resolve_delta(fight_model: FightModel, action: Action) -> Delta:
	var delta := Delta.new()
	delta.ticks = action.resolve_tick - fight_model.tick
	delta.remove_action(action.actor)
	_add_damage(fight_model, delta, action.target, action.skill.damage)
	return delta


static func _add_damage(fight_model: FightModel, delta: Delta, character: Character, damage: int) -> void:
	var health := delta.get_health(character)
	var dealt := mini(damage, health)
	delta.add_health(character, -dealt)
	if dealt == health:
		_add_fall(fight_model, delta, character)


# A fallen character loses its pending action, and every action aimed at it is cancelled.
static func _add_fall(fight_model: FightModel, delta: Delta, character: Character) -> void:
	for action in fight_model.timeline:
		if delta.is_removing_action(action.actor):
			continue
		if action.actor == character or action.target == character:
			delta.remove_action(action.actor)
