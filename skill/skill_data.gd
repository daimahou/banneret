class_name SkillData
extends Resource

enum Blow { QUICK, HEAVY }

@export var name: String
# Null shows the placeholder.
@export var icon: Texture2D
@export var delay: int
@export var cooldown: int
@export var ap_cost := 1
@export var blow := Blow.QUICK
@export var effects: Array[Effect] = []
