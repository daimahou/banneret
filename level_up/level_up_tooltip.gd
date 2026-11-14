class_name LevelUpTooltip
extends RichTextLabel
# The tooltip of a skill, talent or perk in the level-up, which shows the colours its text is tagged with.


func _init(shown_text: String) -> void:
	theme_type_variation = &"LevelUpTooltip"
	bbcode_enabled = true
	fit_content = true
	autowrap_mode = TextServer.AUTOWRAP_OFF
	text = shown_text
