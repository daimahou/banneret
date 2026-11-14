class_name Character
extends RefCounted

const SKILL_SLOTS := 5
const TALENT_SLOTS := 8

static var _next_id := 0

var id: int
var data: CharacterData
var health: int
var ap: int
var skills: Array[Skill] = []
var talents: Array[Talent] = []

var _tag_counts: Dictionary[StringName, int] = {}


func _init(character_data: CharacterData) -> void:
	id = _next_id
	_next_id += 1
	data = character_data
	for skill_data in data.skills:
		add_skill(Skill.new(skill_data))
	if data.class_talent != null:
		add_talent(Talent.new(data.class_talent))
	health = get_max_health()
	ap = get_max_ap()


func is_fallen() -> bool:
	return health <= 0


func get_max_health() -> int:
	return data.max_health + _get_talent_amount(HeroModifier.Stat.MAX_HEALTH)


func get_max_ap() -> int:
	return mini(CharacterData.MAX_AP, data.max_ap + _get_talent_amount(HeroModifier.Stat.MAX_AP))


func has_free_skill_slot() -> bool:
	return skills.size() < SKILL_SLOTS


func has_skill(skill_data: SkillData) -> bool:
	return skills.any(func(skill: Skill) -> bool: return skill.data == skill_data)


func get_skill(skill_id: int) -> Skill:
	for skill in skills:
		if skill.id == skill_id:
			return skill
	return null


func add_skill(skill: Skill) -> void:
	skills.append(skill)
	_grant_tags(skill.data.granted_tags)


# Null raises the rank alone.
func upgrade_skill(skill: Skill, perk: SkillPerk) -> void:
	skill.upgrade(perk)
	if perk != null:
		_grant_tags(perk.granted_tags)


func has_free_talent_slot() -> bool:
	return talents.size() < TALENT_SLOTS


func has_talent(talent_data: TalentData) -> bool:
	return talents.any(func(talent: Talent) -> bool: return talent.data == talent_data)


func add_talent(talent: Talent) -> void:
	_change_talents(func() -> void: talents.append(talent))
	_grant_tags(talent.data.granted_tags)


# Null raises the rank alone.
func upgrade_talent(talent: Talent, perk: TalentPerk) -> void:
	_change_talents(talent.upgrade.bind(perk))
	if perk != null:
		_grant_tags(perk.granted_tags)


func grant_tag(tag: StringName) -> void:
	_tag_counts[tag] = _tag_counts.get(tag, 0) + 1


func strip_tag(tag: StringName) -> void:
	if _tag_counts.get(tag, 0) <= 1:
		_tag_counts.erase(tag)
	else:
		_tag_counts[tag] -= 1


func meets_requirements(requirements: Array[TagRequirement]) -> bool:
	return requirements.all(func(requirement: TagRequirement) -> bool:
		return _tag_counts.get(requirement.tag, 0) >= requirement.count)


func duplicate() -> Character:
	var copy := Character.new(data)
	copy.id = id
	copy.health = health
	copy.ap = ap
	copy._tag_counts = _tag_counts.duplicate()
	copy.skills.assign(skills.map(func(skill: Skill) -> Skill: return skill.duplicate()))
	copy.talents.assign(talents.map(func(talent: Talent) -> Talent: return talent.duplicate()))
	return copy


# A gain in max raises the current value by as much; a loss only clamps it to the new max. A fallen hero stays at 0.
func _change_talents(change: Callable) -> void:
	var old_max_health := get_max_health()
	var old_max_ap := get_max_ap()
	change.call()
	if not is_fallen():
		health = clampi(health + maxi(0, get_max_health() - old_max_health), 0, get_max_health())
	ap = clampi(ap + maxi(0, get_max_ap() - old_max_ap), 0, get_max_ap())


func _grant_tags(tags: Array[StringName]) -> void:
	for tag in tags:
		grant_tag(tag)


func _get_talent_amount(stat: HeroModifier.Stat) -> int:
	var amount := 0
	for talent in talents:
		amount += talent.get_amount(stat)
	return amount
