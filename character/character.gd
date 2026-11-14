class_name Character
extends RefCounted

static var _next_id := 0

var id: int
var data: CharacterData
var health: int
# Carries from one fight to the next.
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
