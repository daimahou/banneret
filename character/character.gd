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


func _init(character_data: CharacterData) -> void:
	id = _next_id
	_next_id += 1
	data = character_data
	for skill_data in data.skills:
		skills.append(Skill.new(skill_data))
	if data.class_talent != null:
		talents.append(Talent.new(data.class_talent))
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


func has_free_talent_slot() -> bool:
	return talents.size() < TALENT_SLOTS


func has_talent(talent_data: TalentData) -> bool:
	return talents.any(func(talent: Talent) -> bool: return talent.data == talent_data)


func add_talent(talent: Talent) -> void:
	_change_talents(func() -> void: talents.append(talent))


func upgrade_talent(talent: Talent, perk: TalentPerk) -> void:
	_change_talents(talent.upgrade.bind(perk))


func duplicate() -> Character:
	var copy := Character.new(data)
	copy.id = id
	copy.health = health
	copy.ap = ap
	copy.skills.assign(skills.map(func(skill: Skill) -> Skill: return skill.duplicate()))
	copy.talents.assign(talents.map(func(talent: Talent) -> Talent: return talent.duplicate()))
	return copy


# A fallen hero stays at 0.
func _change_talents(change: Callable) -> void:
	var old_max_health := get_max_health()
	var old_max_ap := get_max_ap()
	change.call()
	if not is_fallen():
		health = _get_followed(health, old_max_health, get_max_health())
	ap = _get_followed(ap, old_max_ap, get_max_ap())


# A gain in max raises the current value by as much; a loss only clamps it to the new max.
static func _get_followed(current: int, old_max: int, new_max: int) -> int:
	return mini(current + maxi(0, new_max - old_max), new_max)


func _get_talent_amount(stat: HeroModifier.Stat) -> int:
	var amount := 0
	for talent in talents:
		amount += talent.get_amount(stat)
	return amount
