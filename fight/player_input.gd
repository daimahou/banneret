class_name PlayerInput
extends Node
# The player's input in a fight: the keys, the mouse on puppets and medallions, the skill bar. Each becomes a call on the brain.

var _brain: PlayerBrain
var _stage: Stage


func _init(brain: PlayerBrain, stage: Stage) -> void:
	_brain = brain
	_stage = stage


func _ready() -> void:
	_stage.skill_bar.skill_pressed.connect(_on_skill_pressed)
	_stage.skill_bar.skill_hovered.connect(_on_skill_hovered)
	_stage.skill_bar.stop_pressed.connect(_on_stop_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var point := _stage.get_global_mouse_position()
		_brain.hover_character(_stage.get_character_at(point))
		_brain.hover_action(_stage.get_action_at(point))
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
		_brain.pick(character)
	elif click.button_index == MOUSE_BUTTON_RIGHT:
		_brain.disarm()
	else:
		return
	get_viewport().set_input_as_handled()


func _handle_key(key: InputEventKey) -> void:
	match key.keycode:
		KEY_SPACE:
			_brain.request_stop()
		KEY_P:
			_brain.pass_stop()
		KEY_TAB:
			_brain.cycle_hero(-1 if key.shift_pressed else 1)
		KEY_ESCAPE:
			_brain.disarm()
		KEY_ENTER, KEY_KP_ENTER:
			_brain.confirm()
		KEY_LEFT:
			_brain.cycle_aim(-1)
		KEY_RIGHT:
			_brain.cycle_aim(1)
		_:
			if key.keycode < KEY_1 or key.keycode > KEY_9:
				return
			_brain.press_number(key.keycode - KEY_1)
	get_viewport().set_input_as_handled()


func _on_skill_pressed(skill: SkillData) -> void:
	_brain.arm_skill(skill)


func _on_skill_hovered(skill: SkillData) -> void:
	_brain.hover_skill(skill)


# The one button: Pass while stopped, Stop while the fight runs.
func _on_stop_pressed() -> void:
	if _brain.is_waiting():
		_brain.pass_stop()
	else:
		_brain.request_stop()
