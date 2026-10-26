@tool
class_name OfferPresenter
extends Control

signal offer_pressed(offer: Offer)

const POSTER_SCENE := preload("res://stage/offer/poster.tscn")

@export var spacing := 80.0:
	set(value):
		spacing = value
		_lay_out_posters()
@export var stagger := 0.12

@export_group("Preview")
@export var is_preview_shown := true:
	set(value):
		is_preview_shown = value
		_update_preview()
@export_range(1, 6) var preview_count := 3:
	set(value):
		preview_count = value
		_update_preview()

var _posters: Array[Poster] = []


func _ready() -> void:
	resized.connect(_lay_out_posters)
	_update_preview()


func show_offers(offers: Array[Offer]) -> void:
	clear()
	for offer in offers:
		var poster: Poster = POSTER_SCENE.instantiate()
		poster.offer = offer
		poster.pressed.connect(offer_pressed.emit.bind(offer))
		add_child(poster)
		_posters.append(poster)
	_lay_out_posters()
	if _posters.is_empty():
		return
	for index in _posters.size() - 1:
		_posters[index].play_drop(index * stagger)
	await _posters.back().play_drop((_posters.size() - 1) * stagger)
	for poster in _posters:
		poster.is_pickable = true


func hide_offers() -> void:
	if _posters.is_empty():
		return
	for poster in _posters:
		poster.is_pickable = false
	for poster in _posters.slice(0, -1):
		poster.play_lift()
	await _posters.back().play_lift()
	clear()


func clear() -> void:
	for poster in _posters:
		poster.queue_free()
	_posters.clear()


func _update_preview() -> void:
	if not Engine.is_editor_hint() or not is_node_ready():
		return
	clear()
	if not is_preview_shown:
		return
	for index in preview_count:
		var poster: Poster = POSTER_SCENE.instantiate()
		add_child(poster, false, Node.INTERNAL_MODE_BACK)
		_posters.append(poster)
	_lay_out_posters()


func _lay_out_posters() -> void:
	var row_width := -spacing
	for poster in _posters:
		row_width += poster.size.x + spacing
	var x := (size.x - row_width) / 2.0
	for poster in _posters:
		poster.position = Vector2(x, 0.0)
		x += poster.size.x + spacing
