class_name LevelUpView
extends Control
# The party's level-up, over the stage: a column for each hero's pick, and Continue once every pick is done.

signal continued

const FONT_SIZE := 32

var _draft: Draft

@onready var _columns: Array[HeroColumn] = [$Board/HeroColumn1, $Board/HeroColumn2, $Board/HeroColumn3]
@onready var _ready_label: Label = $Board/Ready
@onready var _continue_button: TextureButton = $Board/ContinueButton


func _ready() -> void:
	theme = Theme.new()
	theme.default_font_size = FONT_SIZE
	for column in _columns:
		column.pick_changed.connect(_show_readiness)
	_continue_button.pressed.connect(_on_continue_pressed)


func show_draft(draft: Draft) -> void:
	_draft = draft
	for index in _columns.size():
		_columns[index].visible = index < draft.hero_drafts.size()
		if _columns[index].visible:
			_columns[index].show_hero_draft(draft.hero_drafts[index], draft.bag)
	_show_readiness()
	show()
	await continued
	hide()
	_draft = null


func _show_readiness() -> void:
	_ready_label.text = "%d / %d ready" % [_draft.get_done_count(), _draft.hero_drafts.size()]
	_continue_button.disabled = not _draft.is_complete()
	_continue_button.modulate = Color.WHITE if _draft.is_complete() else Color(0.5, 0.5, 0.5)


func _on_continue_pressed() -> void:
	if _draft != null and _draft.is_complete():
		continued.emit()
