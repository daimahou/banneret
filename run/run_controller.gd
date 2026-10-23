class_name RunController
extends Node

# The fight's end stays on stage this long, in seconds.
const END_HOLD_DURATION := 1.0

var run_model := RunModel.new()

var _mission_controller: MissionController
# Set while a fight plays on stage.
var _fight_controller: FightController

@onready var _stage: Stage = $Stage


func _enter_tree() -> void:
	LimboConsole.register_command(start_mission, "map_seed", "Rebuild the mission map from a seed")
	LimboConsole.register_command(start_fight, "fight", "Skip the mission: play the encounter at once, from a seed or a random one")


func _exit_tree() -> void:
	LimboConsole.unregister_command(start_mission)
	LimboConsole.unregister_command(start_fight)


func _ready() -> void:
	LimboConsole.info("Party: %s" % ", ".join(run_model.party.map(func(hero: Character) -> String: return hero.data.name)))
	await _stage.laid_out
	start_mission(randi())
	_start_fight_from_arguments()


# Null until the stage is laid out.
func get_mission_controller() -> MissionController:
	return _mission_controller


# Replaces the current mission; the party stays the run's. Over the fight, the stage plays the transition back.
func start_mission(map_seed: int) -> void:
	if _stage.is_in_transition():
		LimboConsole.warn("The stage is in a transition")
		return
	if _fight_controller != null:
		LimboConsole.warn("A fight is playing")
		return
	if _mission_controller != null:
		_mission_controller.dispose()
	_mission_controller = MissionController.new(_stage, map_seed)
	_mission_controller.mission_ended.connect(_on_mission_ended)


# For debugging: from the autoexec script, it waits for the first mission, so a launch goes straight to the fight.
func start_fight(fight_seed := randi()) -> void:
	if _mission_controller == null:
		await _stage.laid_out
	if _stage.is_in_transition():
		LimboConsole.warn("The stage is in a transition")
		return
	if _fight_controller != null:
		LimboConsole.warn("A fight is playing")
		return
	await _start_encounter(fight_seed)


# For debugging: `--fight` or `--fight=<seed>` on the command line, e.g. in Debug > Customize Run Instances, goes straight to the fight.
func _start_fight_from_arguments() -> void:
	for argument in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		if argument == "--fight":
			start_fight(randi())
			return
		if argument.begins_with("--fight="):
			start_fight(int(argument.trim_prefix("--fight=")))
			return


func _on_mission_ended() -> void:
	await _start_encounter(randi())


func _start_encounter(fight_seed: int) -> void:
	var enemies: Array[Character] = []
	for enemy_data in RunModel.ENCOUNTER_ENEMIES:
		enemies.append(Character.new(enemy_data))
		enemies.append(Character.new(enemy_data))
	LimboConsole.info("Fight seed: %d" % fight_seed)
	_fight_controller = FightController.new(run_model.party, enemies, fight_seed, _stage)
	await _stage.show_encounter(_fight_controller.fight_model)
	await _play_fight()


# Either way the stage goes back to a new mission, after a hold on the fight's end; a defeat loses the run first, and a new one starts.
func _play_fight() -> void:
	_fight_controller.action_resolved.connect(_on_action_resolved)
	await _fight_controller.play()
	await get_tree().create_timer(END_HOLD_DURATION).timeout
	var is_won := _fight_controller.fight_model.is_won()
	_fight_controller = null
	if is_won:
		LimboConsole.info("Fight won")
	else:
		LimboConsole.info("Run lost")
		run_model = RunModel.new()
	start_mission(randi())


func _on_action_resolved(action: Action) -> void:
	LimboConsole.info("%s: %s on %s, %d health left" % [action.actor.data.name, action.skill.name, action.target.data.name, action.target.health])
