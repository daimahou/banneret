class_name LevelUpPerkIcon
extends TextureRect
# One perk socket: empty, or a perk's icon with its name and what it adds as the tooltip. It shows what it is told.

const SOCKET_TEXTURE := preload("res://level_up/assets/talent_socket.png")
const EMPTY_TEXTURE := preload("res://level_up/assets/talent_socket_empty.png")

@onready var _icon: TextureRect = $Icon


func _make_custom_tooltip(for_text: String) -> Object:
	return LevelUpTooltip.new(for_text)


# Null empties the socket.
func show_perk(perk: Perk) -> void:
	texture = EMPTY_TEXTURE if perk == null else SOCKET_TEXTURE
	_icon.texture = null if perk == null else perk.icon
	tooltip_text = "" if perk == null else "\n".join(_get_tooltip_lines(perk))


static func _get_tooltip_lines(perk: Perk) -> PackedStringArray:
	var lines := PackedStringArray([perk.name])
	if not perk.get_description().is_empty():
		lines.append(perk.get_description())
	return lines
