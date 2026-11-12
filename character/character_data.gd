class_name CharacterData
extends Resource

const MAX_AP := 5

@export var name: String
@export var max_health: int
@export_range(1, MAX_AP) var max_ap := 1
@export var puppet: Texture2D
@export var portrait: Texture2D
# Null for a character with no class.
@export var starting_class: ClassData
@export var skills: Array[SkillData] = []
