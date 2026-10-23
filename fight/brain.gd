class_name Brain
extends RefCounted
# Decides the actions of one side. Awaited, it gives an action for one of the side's free characters, or null to pass.

var side := FightModel.Side.HERO


# Whether the fight should ask this brain even with an action due, so it can stop the fight between two blows.
func is_stop_requested() -> bool:
	return false


func dispose() -> void:
	pass


# A coroutine, so the awaits on it are not redundant: this one passes after a frame.
func get_next_action(_fight_model: FightModel) -> Action:
	await (Engine.get_main_loop() as SceneTree).process_frame
	return null
