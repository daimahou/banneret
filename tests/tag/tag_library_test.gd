extends GdUnitTestSuite


func test_every_tag_field_offers_the_library_s_tags() -> void:
	var tags: Array[StringName] = (load(TagLibrary.PATH) as TagLibrary).tags
	var fields := {
		SkillData.new(): &"granted_tags",
		TalentData.new(): &"granted_tags",
		SkillPerk.new(): &"granted_tags",
		TalentPerk.new(): &"granted_tags",
		TagRequirement.new(): &"tag",
	}

	for owner: Resource in fields:
		var property: Dictionary = owner.get_property_list().filter(
			func(listed: Dictionary) -> bool: return listed.name == fields[owner])[0]
		for tag in tags:
			assert_str(property.hint_string).contains(tag)

