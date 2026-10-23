class_name Ink
extends RefCounted

# Ordered weakest first: a road dash on several roads shows the strongest highlight among them.
enum Highlight { DIMMED, NONE, TRAVELLED, HOVERED }

# A highlight without a color keeps the ink's own.
const COLORS: Dictionary[Highlight, Color] = {
	Highlight.TRAVELLED: Color("a0701e"),
	Highlight.HOVERED: Color("2f6fb5"),
}
const DIMMED_ALPHA := 0.35

const RECOLOR_SHADER := preload("res://stage/ink_recolor.gdshader")


# Null for a highlight that keeps the ink's own color.
static func create_material(highlight: Ink.Highlight) -> ShaderMaterial:
	if highlight not in COLORS:
		return null
	var material := ShaderMaterial.new()
	material.shader = RECOLOR_SHADER
	material.set_shader_parameter("ink_color", COLORS[highlight])
	return material


static func get_alpha(highlight: Ink.Highlight) -> float:
	return DIMMED_ALPHA if highlight == Highlight.DIMMED else 1.0
