class_name Character
extends RefCounted

var data: CharacterData
var health: int

# Both carry from one fight to the next. Cooldowns are the beats left before each skill is ready again.
var ap: int
var skill_cooldowns: Dictionary[SkillData, int] = {}


func _init(character_data: CharacterData) -> void:
	data = character_data
	health = data.max_health
	ap = data.max_ap


func is_fallen() -> bool:
	return health <= 0
