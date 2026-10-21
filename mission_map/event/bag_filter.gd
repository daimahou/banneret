class_name BagFilter
extends RefCounted

# Empty for now: every entry passes. Conditions become `Registry.where` criteria here.


func get_accepted_ids(registry: Registry) -> Array[StringName]:
	return registry.get_all_string_ids()
