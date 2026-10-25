class_name Character
extends RefCounted

static var _next_id := 0

# Unique across the run; a preview's copy shares it with its original.
var id: int
var data: CharacterData
var health: int

# Both carry from one fight to the next. Cooldowns are the beats left before each skill is ready again.
var ap: int
var skill_cooldowns: Dictionary[SkillData, int] = {}


func _init(character_data: CharacterData) -> void:
	id = _next_id
	_next_id += 1
	data = character_data
	health = data.max_health
	ap = data.max_ap


func is_fallen() -> bool:
	return health <= 0


func duplicate() -> Character:
	var copy := Character.new(data)
	copy.id = id
	copy.health = health
	copy.ap = ap
	copy.skill_cooldowns = skill_cooldowns.duplicate()
	return copy
