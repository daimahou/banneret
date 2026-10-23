class_name RunController
extends Node

const HOLD_DURATION := 0.4

var run_model := RunModel.new()
var fight_controller: FightController
# The heroes play themselves while set, in this fight and the next ones; set during a stop, the player's brain passes first.
var is_hero_brain_random := false:
	set(value):
		is_hero_brain_random = value
		if fight_controller != null:
			_set_hero_brain()

var _mission_controller: MissionController
var _fight_seed := 0

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
	if fight_controller != null:
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
	if fight_controller != null:
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
	LimboConsole.info("Fight seed: %d" % fight_seed)
	_fight_seed = fight_seed
	fight_controller = FightController.new(run_model.party, enemies, fight_seed, _stage)
	await _stage.show_encounter(fight_controller.fight_model)
	_set_hero_brain()
	await get_tree().create_timer(HOLD_DURATION).timeout
	await _play_fight()


# The new brain takes over before the old one passes, so the heroes' next turn to choose is already its.
func _set_hero_brain() -> void:
	var player_brain := fight_controller.hero_brain as PlayerBrain
	if is_hero_brain_random:
		fight_controller.hero_brain = RandomBrain.new(FightModel.Side.HERO, _fight_seed)
		_stage.show_choices(null)
		if player_brain != null:
			player_brain.pass_stop()
	elif player_brain == null:
		player_brain = PlayerBrain.new()
		fight_controller.hero_brain = player_brain
		_stage.show_choices(player_brain)


# Either way the stage goes back to a new mission, after a hold on the fight's end; a defeat loses the run first, and a new one starts.
func _play_fight() -> void:
	fight_controller.action_resolved.connect(_on_action_resolved)
	await fight_controller.play()
	_stage.show_choices(null)
	await get_tree().create_timer(HOLD_DURATION).timeout
	var is_won := fight_controller.fight_model.is_won()
	fight_controller = null
	if is_won:
		LimboConsole.info("Fight won")
	else:
		LimboConsole.info("Run lost")
		run_model = RunModel.new()
	start_mission(randi())


func _on_action_resolved(action: Action) -> void:
	LimboConsole.info("%s: %s on %s, %d health left" % [action.actor.data.name, action.skill.name, action.target.data.name, action.target.health])
