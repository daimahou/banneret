@tool
class_name TagLibrary
extends Resource
# Every tag a designer can grant or require: the inspector's tag fields pick from it.

const PATH := "res://tag/tag_library.tres"

@export var tags: Array[StringName] = []


static func hint_tag(property: Dictionary) -> void:
	property.hint = PROPERTY_HINT_ENUM
	property.hint_string = _get_hint_string()


static func hint_tag_array(property: Dictionary) -> void:
	property.hint = PROPERTY_HINT_TYPE_STRING
	property.hint_string = "%d/%d:%s" % [TYPE_STRING_NAME, PROPERTY_HINT_ENUM, _get_hint_string()]


static func _get_hint_string() -> String:
	return ",".join((load(PATH) as TagLibrary).tags)
