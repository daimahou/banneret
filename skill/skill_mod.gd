class_name SkillMod
extends Resource
# A change to active skills: an active's own mods change that skill, a passive's change every active of its hero.

const MIN_DELAY := 1

@export var damage_change := 0
@export var stagger_change := 0
@export var delay_change := 0
@export var cooldown_change := 0
@export var added_effects: Array[Effect] = []


func apply(skill: SkillData) -> void:
	skill.delay = maxi(MIN_DELAY, skill.delay + delay_change)
	skill.cooldown = maxi(0, skill.cooldown + cooldown_change)
	for index in skill.effects.size():
		skill.effects[index] = skill.effects[index].create_changed(self)
	skill.effects.append_array(added_effects)


func get_description() -> String:
	var lines := PackedStringArray()
	if damage_change != 0:
		lines.append("%+d damage" % damage_change)
	if stagger_change != 0:
		lines.append("%+d stagger" % stagger_change)
	if delay_change != 0:
		lines.append("%+d delay" % delay_change)
	if cooldown_change != 0:
		lines.append("%+d cooldown" % cooldown_change)
	for effect in added_effects:
		lines.append("Adds: %s" % effect.get_description())
	return "\n".join(lines)
