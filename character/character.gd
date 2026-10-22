class_name Character
extends RefCounted

var data: CharacterData
var health: int


func _init(character_data: CharacterData) -> void:
	data = character_data
	health = data.max_health
