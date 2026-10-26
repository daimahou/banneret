class_name FightRules
# The rules of a fight: given the fight model and one action, the delta it makes. They apply nothing to the fight, and nothing in them is random.


const BEAT_TICKS := 4
const AP_PER_BEAT := 1


static func get_usable_skills(fight_model: FightModel, character: Character) -> Array[SkillData]:
	var skills: Array[SkillData] = []
	for skill in character.data.skills:
		if get_cooldown_beats(character, skill) == 0 and character.ap >= skill.ap_cost:
			skills.append(skill)
	return skills


static func is_ready(fight_model: FightModel, character: Character) -> bool:
	return not get_usable_skills(fight_model, character).is_empty()


static func get_cooldown_beats(character: Character, skill: SkillData) -> int:
	return character.skill_cooldowns.get(skill, 0)


static func is_beat(tick: int) -> bool:
	return tick % BEAT_TICKS == 0


static func get_beat_at_or_after(tick: int) -> int:
	return ceili(tick / float(BEAT_TICKS)) * BEAT_TICKS


# Whether the next beat comes before the next action resolves; on a shared tick, the beat comes first.
static func is_beat_next(fight_model: FightModel) -> bool:
	var next_action := fight_model.get_next_action()
	return next_action == null or get_beat_at_or_after(fight_model.tick + 1) <= next_action.resolve_tick


# Every character the skill can be aimed at: the standing characters of the other side.
static func get_targets(fight_model: FightModel, character: Character, _skill: SkillData) -> Array[Character]:
	return fight_model.get_standing(FightModel.Side.ENEMY if fight_model.get_side(character) == FightModel.Side.HERO else FightModel.Side.HERO)


static func get_timeline_delta(fight_model: FightModel, action: Action) -> Delta:
	action.resolve_tick = fight_model.tick + action.skill.delay
	var delta := Delta.new()
	delta.add_action(action)
	delta.add_ap(action.actor, -action.skill.ap_cost)
	if action.skill.cooldown > 0:
		delta.add_cooldown(action.actor, action.skill, action.skill.cooldown)
	return delta


static func get_beat_delta(fight_model: FightModel) -> Delta:
	var delta := Delta.new()
	delta.ticks = get_beat_at_or_after(fight_model.tick + 1) - fight_model.tick
	for character in fight_model.heroes + fight_model.enemies:
		var regained := mini(AP_PER_BEAT, character.data.max_ap - character.ap)
		if regained > 0:
			delta.add_ap(character, regained)
		for skill in character.skill_cooldowns:
			var beats := character.skill_cooldowns[skill]
			if beats > 0:
				delta.add_cooldown(character, skill, beats - 1)
	return delta


static func get_resolve_delta(fight_model: FightModel, action: Action) -> Delta:
	var delta := Delta.new()
	delta.ticks = action.resolve_tick - fight_model.tick
	delta.resolve_action(action)
	for effect in action.skill.effects:
		effect.add_changes(fight_model, delta, action)
	return delta


static func add_damage(fight_model: FightModel, delta: Delta, character: Character, damage: int) -> void:
	var health := delta.get_health(character)
	var dealt := mini(damage, health)
	delta.add_health(character, -dealt)
	if dealt == health:
		_add_fall(fight_model, delta, character)


# Moved in timeline order, the character's actions keep their order.
static func add_stagger(fight_model: FightModel, delta: Delta, character: Character, ticks: int) -> void:
	for action in fight_model.timeline:
		if action.actor == character and not delta.is_removing_action(action):
			delta.move_action(action, action.resolve_tick + ticks)


# A fallen character loses its pending actions, and every action aimed at it is cancelled; no AP comes back.
static func _add_fall(fight_model: FightModel, delta: Delta, character: Character) -> void:
	for action in fight_model.timeline:
		if delta.is_removing_action(action):
			continue
		if action.actor == character or action.target == character:
			delta.cancel_action(action)
