class_name FightRules
# The rules of a fight: given the fight model and one action, the delta it makes. They apply nothing to the fight, and nothing in them is random.


const BEAT_TICKS := 4


# Every skill the character can use now: those not on cooldown.
static func get_usable_skills(fight_model: FightModel, character: Character) -> Array[SkillData]:
	return character.data.skills.filter(func(skill: SkillData) -> bool: return get_cooldown_beats(fight_model, character, skill) == 0)


# The beats left to cross before the skill is ready again; 0 when it is.
static func get_cooldown_beats(fight_model: FightModel, character: Character, skill: SkillData) -> int:
	var ticks: int = character.ready_ticks.get(skill, 0) - fight_model.tick
	return maxi(ceili(ticks / float(BEAT_TICKS)), 0)


# A beat falls every BEAT_TICKS ticks, from tick 0.
static func is_beat(tick: int) -> bool:
	return tick % BEAT_TICKS == 0


static func get_beat_at_or_after(tick: int) -> int:
	return ceili(tick / float(BEAT_TICKS)) * BEAT_TICKS


# Every character the skill can be aimed at: the standing characters of the other side.
static func get_targets(fight_model: FightModel, character: Character, _skill: SkillData) -> Array[Character]:
	return fight_model.get_standing(FightModel.Side.ENEMY if fight_model.get_side(character) == FightModel.Side.HERO else FightModel.Side.HERO)


# The chosen action goes on the timeline: it resolves its skill's delay on from now. It replaces its actor's pending action, if any.
# Its skill goes on cooldown now, even if the action is later dropped: it is ready again on the cooldown's last beat crossed, a beat now not counted.
static func get_timeline_delta(fight_model: FightModel, action: Action) -> Delta:
	action.resolve_tick = fight_model.tick + action.skill.delay
	var delta := Delta.new()
	if fight_model.get_action(action.actor) != null:
		delta.remove_action(action.actor)
	delta.add_action(action)
	if action.skill.cooldown > 0:
		var next_beat := get_beat_at_or_after(fight_model.tick + 1)
		delta.add_cooldown(action.actor, action.skill, next_beat + (action.skill.cooldown - 1) * BEAT_TICKS)
	return delta


# The action resolved, the fight moved on to its tick.
static func get_resolve_delta(fight_model: FightModel, action: Action) -> Delta:
	var delta := Delta.new()
	delta.ticks = action.resolve_tick - fight_model.tick
	delta.remove_action(action.actor)
	for effect in action.skill.effects:
		effect.add_changes(fight_model, delta, action)
	return delta


static func add_damage(fight_model: FightModel, delta: Delta, character: Character, damage: int) -> void:
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
