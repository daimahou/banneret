class_name PassiveData
extends Learnable
# A passive skill: its rank effects change every active skill of the hero who owns it.

# Null for a passive with no effect of its own at Basic rank.
@export var mod: SkillMod


func get_basic_mods() -> Array[SkillMod]:
	var mods: Array[SkillMod] = []
	if mod != null:
		mods.append(mod)
	return mods
