class_name CharacterData
extends Resource

# As many pips as a nameplate holds.
const MAX_AP := 5

@export var name: String
@export var max_health: int
@export_range(1, MAX_AP) var max_ap := 1
@export var puppet: Texture2D
@export var portrait: Texture2D
@export var skills: Array[SkillData] = []
