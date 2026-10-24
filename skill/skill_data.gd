class_name SkillData
extends Resource

@export var name: String
@export var delay: int
@export var cooldown: int
# Applied in order when the skill resolves.
@export var effects: Array[Effect] = []
