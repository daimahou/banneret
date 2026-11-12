class_name Build
extends RefCounted
# A character's skills as the run develops them. Its own, never its definition's: heroes sharing a definition develop apart.

const PASSIVE_SLOTS := 7
const ACTIVE_SLOTS := 4

# Null for a character with no class.
var class_skill: OwnedSkill
var passives: Array[OwnedSkill] = []
var actives: Array[OwnedSkill] = []

var _starting_active_count := 0


func _init(character_data: CharacterData) -> void:
	if character_data.starting_class != null:
		class_skill = OwnedSkill.new(character_data.starting_class)
	for skill in character_data.skills:
		actives.append(OwnedSkill.new(skill))
	_starting_active_count = actives.size()


# Null for a character with no class.
func get_class_data() -> ClassData:
	if class_skill == null:
		return null
	var class_data := class_skill.skill as ClassData
	for talent in class_skill.talents:
		if talent.granted_class != null:
			class_data = talent.granted_class
	return class_data


func get_owned(kind: Learnable.Kind) -> Array[OwnedSkill]:
	if kind == Learnable.Kind.ACTIVE:
		return actives.duplicate()
	var owned: Array[OwnedSkill] = []
	if class_skill != null:
		owned.append(class_skill)
	owned.append_array(passives)
	return owned


func owns(skill: Learnable) -> bool:
	return get_owned(skill.get_kind()).any(func(owned: OwnedSkill) -> bool: return owned.skill == skill)


func has_free_slot(kind: Learnable.Kind) -> bool:
	if kind == Learnable.Kind.ACTIVE:
		return actives.size() < _starting_active_count + ACTIVE_SLOTS
	return passives.size() < PASSIVE_SLOTS


func learn(skill: Learnable) -> void:
	if skill.get_kind() == Learnable.Kind.ACTIVE:
		actives.append(OwnedSkill.new(skill))
	else:
		passives.append(OwnedSkill.new(skill))


func create_skills() -> Array[SkillData]:
	var passive_mods: Array[SkillMod] = []
	for owned in get_owned(Learnable.Kind.PASSIVE):
		passive_mods.append_array(owned.get_mods())
	var skills: Array[SkillData] = []
	for owned in actives:
		skills.append((owned.skill as SkillData).create_expression(owned.get_mods() + passive_mods))
	return skills
