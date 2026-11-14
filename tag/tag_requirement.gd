@tool
class_name TagRequirement
extends Resource

@export var tag: StringName
@export_range(1, 1, 1, "or_greater") var count := 1


func _validate_property(property: Dictionary) -> void:
	if property.name == "tag":
		TagLibrary.hint_tag(property)
