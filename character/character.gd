class_name Character
extends RefCounted

var data: CharacterData
var health: int
# Beats left before each skill is ready again; they carry from one fight to the next.
var skill_cooldowns: Dictionary[SkillData, int] = {}


func _init(character_data: CharacterData) -> void:
	data = character_data
	health = data.max_health


func is_fallen() -> bool:
	return health <= 0
