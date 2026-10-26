@tool
class_name Poster
extends Control

signal pressed

# 0 is rolled up under the top roll, 1 is open: the body scales on y and the bottom roll follows its lower edge.
@export_range(0.0, 1.0) var openness := 1.0:
	set(value):
		openness = value
		_update_openness()

var offer: Offer
# Set by the presenter: hover and clicks only count while the poster hangs still.
var is_pickable := false:
	set(value):
		is_pickable = value
		_update_highlight()

var _is_mouse_over := false
var _hover_material: ShaderMaterial

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _body: Control = $Scroll/Body
@onready var _bottom: Control = $Scroll/Bottom


func _ready() -> void:
	_update_openness()
	if Engine.is_editor_hint():
		return
	%Name.text = offer.name
	%Description.text = offer.description
	_hover_material = Ink.create_material(Ink.Highlight.HOVERED)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _gui_input(event: InputEvent) -> void:
	var mouse_button := event as InputEventMouseButton
	if is_pickable and mouse_button != null and mouse_button.button_index == MOUSE_BUTTON_LEFT and mouse_button.pressed:
		pressed.emit()


# Waits out `delay` above the screen, on the drop's first frame.
func play_drop(delay: float) -> void:
	_animation_player.play(&"drop")
	_animation_player.seek(0.0, true)
	if delay > 0.0:
		_animation_player.pause()
		# A tween of the poster's own, so the wait ends with it if the poster is freed.
		await create_tween().tween_interval(delay).finished
		_animation_player.play()
	await _animation_player.animation_finished


func play_lift() -> void:
	_animation_player.play(&"lift")
	await _animation_player.animation_finished


func _update_openness() -> void:
	if not is_node_ready():
		return
	_body.scale.y = openness
	_bottom.position.y = _body.position.y + _body.size.y * openness


func _update_highlight() -> void:
	material = _hover_material if is_pickable and _is_mouse_over else null


func _on_mouse_entered() -> void:
	_is_mouse_over = true
	_update_highlight()


func _on_mouse_exited() -> void:
	_is_mouse_over = false
	_update_highlight()
