# The feedback loop

**Exit 0 is green, anything else is red.**

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://path/to/script.gd
```

A `SceneTree` script that calls `quit(0)` exits 0 and one that calls `quit(100)` exits 100 — checked against this project, headless, with `DisplayServer.get_name()` returning `headless`.

## The tests

**gdUnit4 runs the suite**, from `addons/gdUnit4/`, over every `_test.gd` under `tests/`:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . \
  -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a tests
```

`--ignoreHeadlessMode` is not optional. gdUnit4 refuses a headless run without it, because a test driving input reads as passing when no input arrives — the flag says the suite makes no such test, which is the same rule the section below states.

`tests/` mirrors the project root, and the run writes `reports/`, which git ignores. A test double several suites share is a `class_name` under `tests/doubles/`, the one folder there that mirrors nothing; a double one suite uses is an inner class of that suite.

**A test asserts behaviour, never a stored value.** A test that sets a field and reads it back proves nothing. Neither does one that checks a constant or a default against a particular value. The values in a `.tres` are placeholders and are never tested.

**Tests never cover layout.** Positions, sizes and spacing are judged by playing.

## The binary

`/Applications/Godot.app/Contents/MacOS/Godot` is 4.7.2 stable, matching `project.godot`'s `config/features`. `Godot_4.8.app` is also installed and is not it. Override for one run with a different path.

## Import before you run

**A file the editor has never scanned does not load headless.** Godot keeps a `.png`'s uid and its import settings in a `.import` sidecar it writes on scan, and `--script` never scans. So a resource referencing a fresh texture fails with `No loader found for resource: <path> (expected type: Texture2D)`, and the `.tres` that references it fails to parse after it.

Run the scan whenever an asset lands or changes, then the script:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --import
```

**A new `class_name` is invisible until the same scan runs.** Godot registers global classes into `.godot/global_script_class_cache.cfg` on scan, so a fresh script's `class_name` fails to resolve in every file that names it — the errors read as `Identifier "Foo" not declared in the current scope`, pointing at the callers rather than at the script that was never scanned.

This bites hardest on imported art, where a tool writes the asset and Godot has never opened the project since. The importer that wrote the file cannot fix it — a sidecar is the editor's to write.

**An `.aseprite` needs the scan twice.** The spritesheet importer shells out to Aseprite, which writes into the folder Godot is mid-scan of, and the first pass after a cache wipe imports one body and fails the rest with `Can't find file ... during file reimport`. **The run still exits 0**, so the failure is silent and only the missing `SpriteFrames` says so. Running the scan a second time imports them all with no errors:

```bash
rm -rf .godot/imported
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --import
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --import
```

## Headless has no input

Godot delivers no `InputEvent` without a window, so a test needing real input cannot run here. Anything needing real input is `feel` work, judged by playing rather than asserted.
