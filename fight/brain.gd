class_name Brain
extends RefCounted
# Decides one side's actions: the fight controller awaits one from it whenever the side may choose.

var side := FightModel.Side.HERO


func is_stop_requested() -> bool:
	return false


func is_waiting() -> bool:
	return false


# A paused brain takes no choice until it is resumed.
func set_paused(_is_paused: bool) -> void:
	pass


func dispose() -> void:
	pass


# Null to pass.
func get_next_action(_fight_model: FightModel) -> Action:
	await (Engine.get_main_loop() as SceneTree).process_frame
	return null
