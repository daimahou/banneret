class_name RunController
extends Node

var run_model := RunModel.new()

var _mission_controller: MissionController
var _is_in_encounter := false

@onready var _stage: Stage = $Stage


func _enter_tree() -> void:
	LimboConsole.register_command(start_mission, "map_seed", "Rebuild the mission map from a seed")
	LimboConsole.register_command(end_encounter, "end_encounter", "End the encounter and start a new mission")
	LimboConsole.register_command(start_fight, "fight", "Skip the mission: play the encounter at once, from a seed or a random one")


func _exit_tree() -> void:
	LimboConsole.unregister_command(start_mission)
	LimboConsole.unregister_command(end_encounter)
	LimboConsole.unregister_command(start_fight)


func _ready() -> void:
	LimboConsole.info("Party: %s" % ", ".join(run_model.party.map(func(hero: Character) -> String: return hero.data.name)))
	await _stage.laid_out
	start_mission(randi())


# Null until the stage is laid out.
func get_mission_controller() -> MissionController:
	return _mission_controller


# Replaces the current mission; the party stays the run's. Over the fight, the stage plays the transition back.
func start_mission(map_seed: int) -> void:
	if _stage.is_in_transition():
		LimboConsole.warn("The stage is in a transition")
		return
	if _mission_controller != null:
		_mission_controller.dispose()
	_is_in_encounter = false
	_mission_controller = MissionController.new(_stage, map_seed)
	_mission_controller.mission_ended.connect(_on_mission_ended)


func end_encounter() -> void:
	if not _is_in_encounter:
		LimboConsole.warn("No encounter to end")
		return
	start_mission(randi())


# For debugging: from the autoexec script, it waits for the first mission, so a launch goes straight to the fight.
func start_fight(fight_seed := randi()) -> void:
	if _mission_controller == null:
		await _stage.laid_out
	if _stage.is_in_transition() or _is_in_encounter:
		LimboConsole.warn("The stage is in a transition or a fight")
		return
	await _start_encounter(fight_seed)


func _on_mission_ended() -> void:
	await _start_encounter(randi())


func _start_encounter(fight_seed: int) -> void:
	_is_in_encounter = true
	var enemies: Array[Character] = []
	for enemy_data in RunModel.ENCOUNTER_ENEMIES:
		enemies.append(Character.new(enemy_data))
	await _stage.show_encounter(run_model.party, enemies)
	await _play_fight(enemies, fight_seed)


# A win stays on the fight until `end_encounter`; a defeat loses the run, and a new one starts.
func _play_fight(enemies: Array[Character], fight_seed: int) -> void:
	LimboConsole.info("Fight seed: %d" % fight_seed)
	var fight_controller := FightController.new(run_model.party, enemies, fight_seed)
	fight_controller.action_resolved.connect(_on_action_resolved)
	await fight_controller.play()
	if fight_controller.fight_model.is_won():
		LimboConsole.info("Fight won")
		return
	LimboConsole.info("Run lost")
	run_model = RunModel.new()
	start_mission(randi())


func _on_action_resolved(action: Action) -> void:
	LimboConsole.info("%s: %s on %s, %d health left" % [action.actor.data.name, action.skill.name, action.target.data.name, action.target.health])
