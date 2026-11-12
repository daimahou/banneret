class_name Character
extends RefCounted

static var _next_id := 0

var id: int
var data: CharacterData
var health: int
var build: Build
# The build's actives as this character uses them; an action keeps the skill it was scheduled with.
var skills: Array[SkillData] = []

# Both carry from one fight to the next.
var ap: int
var skill_cooldowns: Dictionary[SkillData, int] = {}


func _init(character_data: CharacterData) -> void:
	id = _next_id
	_next_id += 1
	data = character_data
	health = data.max_health
	ap = data.max_ap
	build = Build.new(data)
	skills = build.create_skills()


func is_fallen() -> bool:
	return health <= 0


# An upgrade carries its skill's cooldown over.
func update_skills() -> void:
	var updated := build.create_skills()
	var cooldowns: Dictionary[SkillData, int] = {}
	for index in skills.size():
		if skill_cooldowns.has(skills[index]):
			cooldowns[updated[index]] = skill_cooldowns[skills[index]]
	skills = updated
	skill_cooldowns = cooldowns


func duplicate() -> Character:
	var copy := Character.new(data)
	copy.id = id
	copy.health = health
	copy.build = build
	copy.skills = skills.duplicate()
	copy.ap = ap
	copy.skill_cooldowns = skill_cooldowns.duplicate()
	return copy
