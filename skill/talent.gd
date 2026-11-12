class_name Talent
extends Resource
# One development of a skill, chosen within its upgrade.

@export var name: String
# Null for a talent every class may choose.
@export var required_class: ClassData
# Null for a talent with no effect beyond the class it grants.
@export var mod: SkillMod
# Null for a talent that leaves the hero's class as it is.
@export var granted_class: ClassData
