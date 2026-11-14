class_name Skill
extends RefCounted

static var _next_id := 0

var id: int
var data: SkillData
# Carries from one fight to the next.
var cooldown_beats := 0


func _init(skill_data: SkillData) -> void:
	id = _next_id
	_next_id += 1
	data = skill_data


func duplicate() -> Skill:
	var copy := Skill.new(data)
	copy.id = id
	copy.cooldown_beats = cooldown_beats
	return copy
