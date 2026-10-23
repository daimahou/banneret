class_name SkillData
extends Resource

@export var name: String
# Ticks from choosing to resolving: the slower the skill, the higher.
@export var delay: int
# Applied in order when the skill resolves.
@export var effects: Array[Effect] = []
