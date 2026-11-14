class_name LevelUpBuildIcon
extends TextureRect
# The icon of a skill or talent in a hero's build, with its description as the tooltip.


func _make_custom_tooltip(for_text: String) -> Object:
	return LevelUpTooltip.new(for_text)
