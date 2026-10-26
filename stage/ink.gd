class_name Ink
extends RefCounted

# Ordered weakest first.
enum Highlight { DIMMED, NONE, TRAVELLED, HOVERED }

# A highlight without a color keeps the ink's own.
const COLORS: Dictionary[Highlight, Color] = {
	Highlight.TRAVELLED: Color("a0701e"),
	Highlight.HOVERED: Color("2f6fb5"),
}
const DIMMED_ALPHA := 0.35

const RECOLOR_SHADER := preload("res://stage/ink_recolor.gdshader")


static func create_material(highlight: Ink.Highlight) -> ShaderMaterial:
	if highlight not in COLORS:
		return null
	return create_color_material(COLORS[highlight])


static func create_color_material(ink_color: Color) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = RECOLOR_SHADER
	material.set_shader_parameter("ink_color", ink_color)
	return material


static func get_alpha(highlight: Ink.Highlight) -> float:
	return DIMMED_ALPHA if highlight == Highlight.DIMMED else 1.0
