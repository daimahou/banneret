class_name Hero
extends RefCounted

var data: HeroData
var health: int


func _init(hero_data: HeroData) -> void:
	data = hero_data
	health = data.max_health
