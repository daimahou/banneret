class_name PlayerInput
extends Node
# The player's input in a fight: the keys, the mouse on puppets and medallions, the skill bar. It reports what the player did, and knows nothing of what it means.

signal stop_pressed
signal pass_pressed
signal stop_button_pressed
signal hero_cycled(step: int)
signal number_pressed(index: int)
signal aim_cycled(step: int)
signal confirm_pressed
signal cancel_pressed
# Null when the cursor is on no puppet, or no medallion.
signal character_hovered(character: Character)
signal action_hovered(action: Action)
signal character_clicked(character: Character)
signal skill_pressed(skill: SkillData)
signal skill_hovered(skill: SkillData)

var _stage: Stage


func _init(stage: Stage) -> void:
	_stage = stage


func _ready() -> void:
	_stage.skill_bar.skill_pressed.connect(skill_pressed.emit)
	_stage.skill_bar.skill_hovered.connect(_on_skill_hovered)
	_stage.skill_bar.stop_pressed.connect(stop_button_pressed.emit)


func _on_skill_hovered(skill: SkillData) -> void:
	character_hovered.emit(null)
	action_hovered.emit(null)
	skill_hovered.emit(skill)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var point := _stage.get_global_mouse_position()
		character_hovered.emit(_stage.get_character_at(point))
		action_hovered.emit(_stage.get_action_at(point))
		return
	var click := event as InputEventMouseButton
	if click != null:
		_handle_click(click)
		return
	var key := event as InputEventKey
	if key != null and key.pressed and not key.echo:
		_handle_key(key)


func _handle_click(click: InputEventMouseButton) -> void:
	if not click.pressed:
		return
	if click.button_index == MOUSE_BUTTON_LEFT:
		var character := _stage.get_character_at(_stage.get_global_mouse_position())
		if character == null:
			return
		character_clicked.emit(character)
	elif click.button_index == MOUSE_BUTTON_RIGHT:
		cancel_pressed.emit()
	else:
		return
	get_viewport().set_input_as_handled()


func _handle_key(key: InputEventKey) -> void:
	match key.keycode:
		KEY_SPACE:
			stop_pressed.emit()
		KEY_P:
			pass_pressed.emit()
		KEY_TAB:
			hero_cycled.emit(-1 if key.shift_pressed else 1)
		KEY_ESCAPE:
			cancel_pressed.emit()
		KEY_ENTER, KEY_KP_ENTER:
			confirm_pressed.emit()
		KEY_LEFT:
			aim_cycled.emit(-1)
		KEY_RIGHT:
			aim_cycled.emit(1)
		_:
			if key.keycode < KEY_1 or key.keycode > KEY_9:
				return
			number_pressed.emit(key.keycode - KEY_1)
	get_viewport().set_input_as_handled()
