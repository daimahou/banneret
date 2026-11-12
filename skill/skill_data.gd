class_name SkillData
extends Learnable

enum Blow { QUICK, HEAVY }

# Null shows the placeholder.
@export var icon: Texture2D
@export var delay: int
@export var cooldown: int
@export var ap_cost := 1
@export var blow := Blow.QUICK
@export var effects: Array[Effect] = []


func get_kind() -> Kind:
	return Kind.ACTIVE


func create_expression(mods: Array[SkillMod]) -> SkillData:
	if mods.is_empty():
		return self
	var expression := duplicate() as SkillData
	expression.effects = effects.duplicate()
	for mod in mods:
		mod.apply(expression)
	return expression
