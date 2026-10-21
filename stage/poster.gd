class_name Poster
extends Control

signal pressed

const TOP_TEXTURE := preload("res://art/offer/poster_top.png")
const BODY_TEXTURE := preload("res://art/offer/poster_body.png")
const BOTTOM_TEXTURE := preload("res://art/offer/poster_bottom.png")

const FALL_DURATION := 0.7
const UNROLL_DURATION := 0.4
const ROLL_UP_DURATION := 0.3
const LIFT_DURATION := 0.4

const TEXT_MARGIN := 40.0
const TEXT_COLOR := Color("2b2118")
const NAME_FONT_SIZE := 64
const DESCRIPTION_FONT_SIZE := 40

var offer: Offer
# Set by the stage: hover and clicks only count while the poster hangs still.
var is_pickable := false:
	set(value):
		is_pickable = value
		_update_highlight()

var _body := TextureRect.new()
var _bottom := TextureRect.new()
var _is_mouse_over := false
var _hover_material := ShaderMaterial.new()


func _init(poster_offer: Offer) -> void:
	offer = poster_offer
	size = Vector2(
		maxf(TOP_TEXTURE.get_width(), maxf(BODY_TEXTURE.get_width(), BOTTOM_TEXTURE.get_width())),
		TOP_TEXTURE.get_height() + BODY_TEXTURE.get_height() + BOTTOM_TEXTURE.get_height())
	_hover_material.shader = Flat.INK_RECOLOR_SHADER
	_hover_material.set_shader_parameter("ink_color", Flat.INK_COLORS[Flat.Highlight.HOVERED])

	var top := TextureRect.new()
	top.texture = TOP_TEXTURE
	_add_piece(top, 0.0)
	_body.texture = BODY_TEXTURE
	_add_piece(_body, TOP_TEXTURE.get_height())
	_bottom.texture = BOTTOM_TEXTURE
	_add_piece(_bottom, _get_unrolled_bottom_y())
	# The rolls draw over the body's ends.
	move_child(top, -1)

	var text := VBoxContainer.new()
	text.position = Vector2.ONE * TEXT_MARGIN
	text.size = BODY_TEXTURE.get_size() - Vector2.ONE * TEXT_MARGIN * 2.0
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text.use_parent_material = true
	text.add_child(_create_label(offer.name, NAME_FONT_SIZE))
	text.add_child(_create_label(offer.description, DESCRIPTION_FONT_SIZE))
	_body.add_child(text)

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _gui_input(event: InputEvent) -> void:
	var mouse_button := event as InputEventMouseButton
	if is_pickable and mouse_button != null and mouse_button.button_index == MOUSE_BUTTON_LEFT and mouse_button.pressed:
		pressed.emit()


# Falls rolled up from above the frame to `hang_y`, bounces, then unrolls.
func create_drop_tween(hang_y: float, delay: float) -> Tween:
	position.y = -size.y
	_body.scale.y = 0.0
	_bottom.position.y = TOP_TEXTURE.get_height()
	var tween := create_tween()
	tween.tween_interval(delay)
	tween.tween_property(self, "position:y", hang_y, FALL_DURATION).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(_body, "scale:y", 1.0, UNROLL_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(_bottom, "position:y", _get_unrolled_bottom_y(), UNROLL_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	return tween


# Rolls back up, then lifts out of the frame.
func create_lift_tween() -> Tween:
	var tween := create_tween()
	tween.tween_property(_body, "scale:y", 0.0, ROLL_UP_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(_bottom, "position:y", TOP_TEXTURE.get_height(), ROLL_UP_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", -size.y, LIFT_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	return tween


func _get_unrolled_bottom_y() -> float:
	return TOP_TEXTURE.get_height() + BODY_TEXTURE.get_height()


func _add_piece(piece: TextureRect, y: float) -> void:
	piece.position = Vector2((size.x - piece.texture.get_width()) / 2.0, y)
	piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
	piece.use_parent_material = true
	add_child(piece)


func _create_label(label_text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", TEXT_COLOR)
	label.add_theme_font_size_override("font_size", font_size)
	label.use_parent_material = true
	return label


func _update_highlight() -> void:
	material = _hover_material if is_pickable and _is_mouse_over else null


func _on_mouse_entered() -> void:
	_is_mouse_over = true
	_update_highlight()


func _on_mouse_exited() -> void:
	_is_mouse_over = false
	_update_highlight()
