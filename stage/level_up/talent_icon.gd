class_name TalentIcon
extends TextureRect
# A small socket beside a skill: a talent chosen or on offer, or an upgrade not yet taken.

const SOCKET_TEXTURE := preload("res://stage/level_up/assets/talent_socket.png")
const EMPTY_TEXTURE := preload("res://stage/level_up/assets/talent_socket_empty.png")

@onready var _monogram: Label = $Monogram


# Null shows an empty socket.
func show_talent(talent: Talent, tooltip: String) -> void:
	texture = EMPTY_TEXTURE if talent == null else SOCKET_TEXTURE
	_monogram.text = "" if talent == null else LevelUpText.get_monogram(talent.name)
	tooltip_text = tooltip
