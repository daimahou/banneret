class_name DebugCommands
extends Node
# The console's debug commands. They drive the game from outside, through what it exposes; nothing in the game knows of them. Gone from a release build.


# While on, the heroes play themselves, in this fight and the next ones.
var _is_auto_combat_on := false


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	LimboConsole.register_command(win_fight, "fight win", "Knock out every enemy: the fight is won")
	LimboConsole.register_command(lose_fight, "fight lose", "Knock out every hero: the fight, and the run, are lost")
	LimboConsole.register_command(toggle_auto_combat, "fight auto_combat", "Toggle random heroes, in this fight and the next")


func _exit_tree() -> void:
	if not OS.is_debug_build():
		return
	LimboConsole.unregister_command(win_fight)
	LimboConsole.unregister_command(lose_fight)
	LimboConsole.unregister_command(toggle_auto_combat)


func win_fight() -> void:
	_knock_out_in_run(FightModel.Side.ENEMY)


func lose_fight() -> void:
	_knock_out_in_run(FightModel.Side.HERO)


func toggle_auto_combat() -> void:
	var run_controller := get_tree().current_scene as RunController
	if run_controller == null:
		LimboConsole.warn("No run is playing")
		return
	if not run_controller.fight_started.is_connected(_on_fight_started):
		run_controller.fight_started.connect(_on_fight_started.bind(run_controller))
	_is_auto_combat_on = not _is_auto_combat_on
	LimboConsole.info("Auto combat: %s" % ("on" if _is_auto_combat_on else "off"))
	if run_controller.fight_controller != null:
		await set_player_brain(run_controller.fight_controller, _get_stage(run_controller), not _is_auto_combat_on)


# The fight is still awaiting a waiting player brain, so swapping it out is not enough: the player brain plays the random brain's choice as its own, or passes.
func set_player_brain(fight_controller: FightController, stage: Stage, is_on: bool) -> void:
	var player_brain := fight_controller.hero_brain as PlayerBrain
	if is_on:
		if player_brain == null:
			fight_controller.hero_brain = PlayerBrain.new(stage)
		return
	if player_brain == null:
		return
	var random_brain := RandomBrain.new(FightModel.Side.HERO, randi())
	fight_controller.hero_brain = random_brain
	player_brain.dispose()
	if not player_brain.is_waiting():
		return
	var action := await random_brain.get_next_action(fight_controller.fight_model)
	if action == null:
		player_brain.pass_stop()
		return
	player_brain.select_hero(action.actor)
	player_brain.arm_skill(action.skill)
	player_brain.pick(action.target)


# The side falls between two steps of the fight: at once while the player chooses, and the player then passes; otherwise once the action under way resolves.
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


func _on_fight_started(fight_controller: FightController, run_controller: RunController) -> void:
	if _is_auto_combat_on:
		set_player_brain(fight_controller, _get_stage(run_controller), false)


func _get_stage(run_controller: RunController) -> Stage:
	return run_controller.get_node(^"Stage") as Stage


func _knock_out_in_run(side: FightModel.Side) -> void:
	var run_controller := get_tree().current_scene as RunController
	if run_controller == null or run_controller.fight_controller == null:
		LimboConsole.warn("No fight is playing")
		return
	knock_out(run_controller.fight_controller, side)
