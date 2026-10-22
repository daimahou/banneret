class_name RegistryFilter
extends RefCounted
## Decides which entries of a [Registry] [method Registry.pick_random] may pick.
##
## Banneret addition: YARD is forked here. Empty for now — every entry passes.
## Conditions land here as [method Registry.where] criteria.


## Returns the string IDs of the entries this filter accepts.
func get_accepted_ids(registry: Registry) -> Array[StringName]:
	return registry.get_all_string_ids()
