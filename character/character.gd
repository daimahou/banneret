class_name Character
extends RefCounted

const SKILL_SLOTS := 5

static var _next_id := 0

var id: int
var data: CharacterData
var health: int
var ap: int
var skills: Array[Skill] = []


func _init(character_data: CharacterData) -> void:
	id = _next_id
	_next_id += 1
	data = character_data
	health = data.max_health
	ap = data.max_ap
	for skill_data in data.skills:
		skills.append(Skill.new(skill_data))


func is_fallen() -> bool:
	return health <= 0


func has_free_skill_slot() -> bool:
	return skills.size() < SKILL_SLOTS


func has_skill_data(skill_data: SkillData) -> bool:
	return skills.any(func(skill: Skill) -> bool: return skill.data == skill_data)


func get_skill(skill_id: int) -> Skill:
	for skill in skills:
		if skill.id == skill_id:
			return skill
	return null


func duplicate() -> Character:
	var copy := Character.new(data)
	copy.id = id
	copy.health = health
	copy.ap = ap
	copy.skills.assign(skills.map(func(skill: Skill) -> Skill: return skill.duplicate()))
	return copy
