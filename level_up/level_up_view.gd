class_name LevelUpView
extends Control
# The level-up, full screen over the stage: one column per hero, the readiness count and Continue. It shows what it is told, and only reports its buttons.

signal offer_selected(hero: Character, offer: LevelUpOffer)
signal continue_pressed

const DISABLED_MODULATE := Color(0.5, 0.5, 0.5)

var _level_up: LevelUp
var _columns: Array[LevelUpColumn] = []

@onready var _ready_label: Label = $ReadyLabel
@onready var _continue_button: TextureButton = $ContinueButton


func _ready() -> void:
	_columns.assign($Columns.get_children())
	for index in _columns.size():
		_columns[index].offer_selected.connect(_on_offer_selected.bind(index))
	_continue_button.pressed.connect(continue_pressed.emit)


func show_level_up(level_up: LevelUp) -> void:
	_level_up = level_up
	for index in _columns.size():
		_columns[index].visible = index < level_up.heroes.size()
		if _columns[index].visible:
			_columns[index].show_hero(level_up, level_up.heroes[index])
	_show_readiness()
	show()


func update_states() -> void:
	for column in _columns:
		if column.visible:
			column.update_state()
	_show_readiness()


func _show_readiness() -> void:
	_ready_label.text = "%d / %d ready" % [_level_up.get_ready_count(), _level_up.heroes.size()]
	_continue_button.disabled = not _level_up.is_ready()
	_continue_button.modulate = DISABLED_MODULATE if _continue_button.disabled else Color.WHITE


func _on_offer_selected(offer: LevelUpOffer, column_index: int) -> void:
	offer_selected.emit(_level_up.heroes[column_index], offer)
