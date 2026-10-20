class_name Flat
extends Control

const MAP_NODE_MIN_SPACING := 190.0

class RoadDash:
	var texture: Texture2D
	var position: Vector2
	var rotation: float


var _road_dashes: Array[RoadDash] = []
var _rows: Array[int] = []


func _draw() -> void:
	for road_dash in _road_dashes:
		draw_set_transform(road_dash.position, road_dash.rotation)
		draw_texture(road_dash.texture, -road_dash.texture.get_size() / 2.0)
	draw_set_transform(Vector2.ZERO)


func show_column(map_nodes: Array[MapNode]) -> void:
	clear()
	for map_node in map_nodes:
		_rows.append(map_node.row)
	for map_node in map_nodes:
		_add_map_node_button(map_node)


func clear() -> void:
	for child in get_children():
		child.queue_free()
	_road_dashes.clear()
	_rows.clear()
	queue_redraw()


# A road dash's position is in flat space.
func add_road_dash(road_dash: RoadDash) -> void:
	_road_dashes.append(road_dash)
	queue_redraw()


# The jitter towards a neighbouring row of the column is capped, so neighbours stay MAP_NODE_MIN_SPACING apart.
func get_map_node_position(map_node: MapNode) -> Vector2:
	var row_spacing := size.y / MissionMapGenerator.ROW_COUNT
	# Never negative: a flat too short for the spacing loses its jitter towards neighbours rather than pushing them apart.
	var jitter_cap := maxf((row_spacing - MAP_NODE_MIN_SPACING) / 2.0, 0.0)
	var jitter := map_node.jitter
	if map_node.row - 1 in _rows:
		jitter.y = maxf(jitter.y, -jitter_cap)
	if map_node.row + 1 in _rows:
		jitter.y = minf(jitter.y, jitter_cap)
	return Vector2(size.x / 2.0, row_spacing * (map_node.row + 0.5)) + jitter


func _add_map_node_button(map_node: MapNode) -> void:
	var button := TextureButton.new()
	button.texture_normal = MapNode.EVENT_ICONS[map_node.event_type]
	button.position = get_map_node_position(map_node) - button.texture_normal.get_size() / 2.0
	add_child(button)
