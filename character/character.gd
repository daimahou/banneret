class_name Character
extends RefCounted

var data: CharacterData
var health: int
# The tick each skill on cooldown is ready again on.
var ready_ticks: Dictionary[SkillData, int] = {}


func _init(character_data: CharacterData) -> void:
	data = character_data
	health = data.max_health


func is_fallen() -> bool:
	return health <= 0
