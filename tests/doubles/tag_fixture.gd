class_name TagFixture
extends RefCounted


static func create_requirement(tag: StringName, count := 1) -> TagRequirement:
	var requirement := TagRequirement.new()
	requirement.tag = tag
	requirement.count = count
	return requirement
