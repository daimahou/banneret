class_name Flat
extends Control

signal map_node_pressed(map_node: MapNode)
signal map_node_mouse_entered(map_node: MapNode)
signal map_node_mouse_exited(map_node: MapNode)

# Ordered weakest first: a road dash on several roads shows the strongest highlight among them.
enum Highlight { DIMMED, NONE, TRAVELLED, HOVERED }

const INK_COLORS: Dictionary[Highlight, Color] = {
	Highlight.TRAVELLED: Color("a0701e"),
	Highlight.HOVERED: Color("2f6fb5"),
}
const DIMMED_ALPHA := 0.35

const INK_RECOLOR_SHADER := preload("res://stage/ink_recolor.gdshader")

class RoadDash:
	var texture: Texture2D
	var position: Vector2
	var rotation: float
	var roads: Array[RoadLayout.Road] = []


var _road_dashes: Array[RoadDash] = []
var _road_dash_highlights: Dictionary[RoadDash, Highlight] = {}
var _map_node_buttons: Dictionary[MapNode, TextureButton] = {}
var _ink_materials: Dictionary[Highlight, ShaderMaterial] = {}
# Recolored dashes draw on a layer of their own, since a shader applies to a whole canvas item.
var _recolored_layers: Dictionary[Highlight, Node2D] = {}

@onready var _battle_illustration: TextureRect = $BattleIllustration


func _ready() -> void:
	for highlight: Highlight in INK_COLORS:
		var ink_material := ShaderMaterial.new()
		ink_material.shader = INK_RECOLOR_SHADER
		ink_material.set_shader_parameter("ink_color", INK_COLORS[highlight])
		_ink_materials[highlight] = ink_material
		var layer := Node2D.new()
		layer.material = ink_material
		layer.draw.connect(_draw_road_dashes.bind(layer, highlight))
		add_child(layer)
		_recolored_layers[highlight] = layer


func _draw() -> void:
	_draw_road_dashes(self, Highlight.NONE)
	_draw_road_dashes(self, Highlight.DIMMED)


func show_column(mission_map_layout: MissionMapLayout, flat_index: int) -> void:
	clear()
	for map_node in mission_map_layout.get_map_nodes(flat_index):
		_add_map_node_button(map_node, mission_map_layout.get_map_node_position(map_node))
	_road_dashes = mission_map_layout.get_road_dashes(flat_index)
	_redraw_road_dashes()


# Shows `region` of the battle illustration in place of the column.
func show_battle(battleground: Texture2D, region: Rect2) -> void:
	clear()
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = battleground
	atlas_texture.region = region
	_battle_illustration.texture = atlas_texture
	_battle_illustration.show()


func clear() -> void:
	for button: TextureButton in _map_node_buttons.values():
		button.queue_free()
	_map_node_buttons.clear()
	# Reassigned, not cleared: the layout owns the array.
	_road_dashes = []
	_road_dash_highlights = {}
	_battle_illustration.hide()
	_redraw_road_dashes()


# A road dash without a highlight shows none.
func set_road_dash_highlights(road_dash_highlights: Dictionary[RoadDash, Highlight]) -> void:
	_road_dash_highlights = road_dash_highlights
	_redraw_road_dashes()


func set_map_node_highlight(map_node: MapNode, highlight: Highlight, is_pickable: bool) -> void:
	var button := _map_node_buttons[map_node]
	button.disabled = not is_pickable
	button.material = _ink_materials.get(highlight)
	button.modulate.a = _get_alpha(highlight)


func _draw_road_dashes(canvas_item: CanvasItem, highlight: Highlight) -> void:
	var modulate_color := Color(1.0, 1.0, 1.0, _get_alpha(highlight))
	for road_dash in _road_dashes:
		if _road_dash_highlights.get(road_dash, Highlight.NONE) != highlight:
			continue
		canvas_item.draw_set_transform(road_dash.position, road_dash.rotation)
		canvas_item.draw_texture(road_dash.texture, -road_dash.texture.get_size() / 2.0, modulate_color)
	canvas_item.draw_set_transform(Vector2.ZERO)


func _redraw_road_dashes() -> void:
	queue_redraw()
	for layer: Node2D in _recolored_layers.values():
		layer.queue_redraw()


func _get_alpha(highlight: Highlight) -> float:
	return DIMMED_ALPHA if highlight == Highlight.DIMMED else 1.0


# Disabled until the scenery highlights it, so a column shown mid-transition can't be picked.
func _add_map_node_button(map_node: MapNode, map_node_position: Vector2) -> void:
	var button := TextureButton.new()
	button.disabled = true
	button.texture_normal = MapNode.EVENT_ICONS[map_node.event_type]
	button.position = map_node_position - button.texture_normal.get_size() / 2.0
	button.pressed.connect(map_node_pressed.emit.bind(map_node))
	button.mouse_entered.connect(map_node_mouse_entered.emit.bind(map_node))
	button.mouse_exited.connect(map_node_mouse_exited.emit.bind(map_node))
	add_child(button)
	_map_node_buttons[map_node] = button
