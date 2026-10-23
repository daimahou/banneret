class_name DebugCommands
extends Node
# The console's debug commands. They drive the game from outside, through what it exposes; nothing in the game knows of them. Gone from a release build.


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	LimboConsole.register_command(win_fight, "fight_win", "Knock out every enemy: the fight is won")
	LimboConsole.register_command(lose_fight, "fight_lose", "Knock out every hero: the fight, and the run, are lost")
	LimboConsole.register_command(toggle_random_heroes, "fight_random_heroes", "Toggle the heroes between the player's choices and random ones, for this fight")


func _exit_tree() -> void:
	if not OS.is_debug_build():
		return
	LimboConsole.unregister_command(win_fight)
	LimboConsole.unregister_command(lose_fight)
	LimboConsole.unregister_command(toggle_random_heroes)


func win_fight() -> void:
	_knock_out_in_run(FightModel.Side.ENEMY)


func lose_fight() -> void:
	_knock_out_in_run(FightModel.Side.HERO)


func toggle_random_heroes() -> void:
	var run_controller := get_tree().current_scene as RunController
	if run_controller == null or run_controller.fight_controller == null:
		LimboConsole.warn("No fight is playing")
		return
	var fight_controller := run_controller.fight_controller
	await toggle_hero_brain(fight_controller, run_controller.get_node(^"Stage") as Stage)
	LimboConsole.info("Heroes: %s" % ("random" if fight_controller.hero_brain is RandomBrain else "the player's"))


# The player's brain gives way to a random one, or back, and the stage, if any, shows the choices or not. A waiting player brain hands on the random brain's choice as its own, or passes, so the fight plays on.
func toggle_hero_brain(fight_controller: FightController, stage: Stage) -> void:
	var player_brain := fight_controller.hero_brain as PlayerBrain
	if player_brain == null:
		player_brain = PlayerBrain.new()
		fight_controller.hero_brain = player_brain
		if stage != null:
			stage.show_choices(player_brain)
		return
	var random_brain := RandomBrain.new(FightModel.Side.HERO, randi())
	fight_controller.hero_brain = random_brain
	if stage != null:
		stage.show_choices(null)
	if not player_brain.is_waiting():
		return
	var action := await random_brain.get_next_action(fight_controller.fight_model)
	if action == null:
		player_brain.pass_stop()
		return
	player_brain.select_hero(action.actor)
	player_brain.arm_skill(action.skill)
	player_brain.pick(action.target)


# The side falls between two steps of the fight, as if struck down: at once while the player chooses, which then passes; else as the blow playing lands.
func knock_out(fight_controller: FightController, side: FightModel.Side) -> void:
	var player_brain := fight_controller.hero_brain as PlayerBrain
	if player_brain == null or not player_brain.is_waiting():
		await fight_controller.action_resolved
	var fight_model := fight_controller.fight_model
	if fight_model.is_over():
		return
	var delta := Delta.new()
	for character in fight_model.get_standing(side):
		FightRules.add_damage(fight_model, delta, character, character.health)
	fight_model.apply(delta)
	if player_brain != null:
		player_brain.pass_stop()


func _knock_out_in_run(side: FightModel.Side) -> void:
	var run_controller := get_tree().current_scene as RunController
	if run_controller == null or run_controller.fight_controller == null:
		LimboConsole.warn("No fight is playing")
		return
	knock_out(run_controller.fight_controller, side)
