class_name FightRules
# The rules of a fight: given the fight model and one action, the delta it makes. They apply nothing to the fight, and nothing in them is random.


# Every skill the character can use now.
static func get_usable_skills(character: Character) -> Array[SkillData]:
	return character.data.skills


# Every character the skill can be aimed at: the standing characters of the other side.
static func get_targets(fight_model: FightModel, character: Character, _skill: SkillData) -> Array[Character]:
	return fight_model.get_standing(FightModel.Side.ENEMY if fight_model.get_side(character) == FightModel.Side.HERO else FightModel.Side.HERO)


# The chosen action goes on the timeline: it resolves its skill's delay on from now.
static func get_timeline_delta(fight_model: FightModel, action: Action) -> Delta:
	action.resolve_tick = fight_model.tick + action.skill.delay
	var delta := Delta.new()
	delta.add_action(action)
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
