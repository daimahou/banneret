extends SceneTree
# Plays the party against the encounter's enemies many times, no view, and prints how it went:
# godot --headless --path . --script res://fight/fight_runner.gd -- --fights=1000 --seed=1


class Outcome:
	extends RefCounted

	var is_won := false
	var ticks := 0
	# By character, heroes then enemies.
	var healths: Array[int] = []


func _initialize() -> void:
	var options := {"fights": 1000, "seed": 1}
	for argument in OS.get_cmdline_user_args():
		var parts := argument.trim_prefix("--").split("=")
		if parts.size() == 2 and options.has(parts[0]):
			options[parts[0]] = int(parts[1])
	var outcomes: Array[Outcome] = []
	# Each fight is seeded from its number; a fight takes two seeds, one per brain.
	for number in options["fights"]:
		outcomes.append(await _play(options["seed"] + number * 2))
	print(_get_summary(outcomes))
	quit(0)


func _play(fight_seed: int) -> Outcome:
	var fight_controller := FightController.new(RunModel.new().party, _create_enemies(), fight_seed)
	await fight_controller.play()
	var fight_model := fight_controller.fight_model
	var outcome := Outcome.new()
	outcome.is_won = fight_model.is_won()
	outcome.ticks = fight_model.tick
	for character in fight_model.heroes + fight_model.enemies:
		outcome.healths.append(character.health)
	return outcome


func _get_summary(outcomes: Array[Outcome]) -> String:
	var wins := outcomes.filter(func(outcome: Outcome) -> bool: return outcome.is_won).size()
	var ticks: Array[int] = []
	for outcome in outcomes:
		ticks.append(outcome.ticks)
	ticks.sort()
	var lines: Array[String] = [
		"%d fights" % outcomes.size(),
		"Heroes win %.1f%%" % (100.0 * wins / outcomes.size()),
		"Ticks: %d fewest, %d median, %d most" % [ticks[0], ticks[floori(ticks.size() / 2.0)], ticks[-1]],
		"Health left on average, out of its most:",
	]
	var cast := RunModel.new().party + _create_enemies()
	for index in cast.size():
		var total := 0
		for outcome in outcomes:
			total += outcome.healths[index]
		lines.append("  %-10s %5.1f / %d" % [cast[index].data.name, float(total) / outcomes.size(), cast[index].data.max_health])
	return "\n".join(lines)


func _create_enemies() -> Array[Character]:
	var enemies: Array[Character] = []
	for enemy_data in RunController.ENCOUNTER_ENEMIES:
		enemies.append(Character.new(enemy_data))
	return enemies
