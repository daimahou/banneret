@tool
extends EditorPlugin
# Project > Tools > Run fights: plays the party's fight many times in a headless Godot of its own, so the editor is never at risk, and prints the summary in the Output panel.

const RUN_FIGHTS := "Run fights"
const SCRIPT := "res://fight/fight_runner.gd"
const FIGHTS := 1000
const FIRST_SEED := 1

var _thread: Thread


func _enter_tree() -> void:
	add_tool_menu_item(RUN_FIGHTS, _run_fights)


func _exit_tree() -> void:
	remove_tool_menu_item(RUN_FIGHTS)
	if _thread != null:
		_thread.wait_to_finish()


func _run_fights() -> void:
	if _thread != null and _thread.is_alive():
		return
	if _thread != null:
		_thread.wait_to_finish()
	print("Running %d fights…" % FIGHTS)
	_thread = Thread.new()
	_thread.start(_play_fights)


# On the thread: the editor stays usable while the fights play.
func _play_fights() -> void:
	var arguments := [
		"--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", SCRIPT,
		"--", "--fights=%d" % FIGHTS, "--seed=%d" % FIRST_SEED,
	]
	var output: Array = []
	OS.execute(OS.get_executable_path(), arguments, output, true)
	_print_output.call_deferred("".join(output))


func _print_output(text: String) -> void:
	for line in text.split("\n"):
		if not line.is_empty() and not line.begins_with("Godot Engine"):
			print(line)
