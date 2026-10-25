# GDScript

How this project's GDScript is named and laid out.

## Naming

**The engine is the standard.**

Casing is the official style guide's: `PascalCase` for a class and an enum, `snake_case` for a file, a function, a variable and a signal, `CONSTANT_CASE` for a constant and an enum member, a leading `_` for what is private. A signal is past tense — `door_opened`, not `open_door`.

**A method starts with a verb.** `resolve_next()`, `cancel_actions()`, `schedule_skill()`. A method named for a noun reads as a property, and one named for a preposition reads as nothing at all. `Action.of(...)` is a Java idiom that appears nowhere in Godot; the engine writes `create`, `create_empty`, `create_from_string`, `from_angle`.

**A getter is `get_`.** Godot's own surface says `get_child_count()`, `get_cell_source_id()`, `get_used_cells()`, and a bare `floor_layer(row)` sitting beside them reads as a different codebase.

**A field is a noun, and never a preposition.** No member in the whole engine API is called `at`, `of`, `on`, `in` or `by`. A tick an action resolves on is `resolve_tick`. The only one- and two-letter members Godot ships are maths components — `x`, `y`, `z`, `w`, `a`, `b`, `uv` — and nothing else earns that brevity.

**A function is named for what it hands back.** The beat is a unit of four ticks. `Action.create_beat(tick)` does not create a beat — it creates an `Action` — and a reader who takes the name at its word is wrong about the return type. A `create_` prefix promises the thing the function is named after.

Where the name would lie, the function usually belongs elsewhere. Scheduling the beat is something a timeline does, so `Timeline.schedule_beat(tick)` names the verb, the subject and the object, and hands back the action it stood up without claiming to have made a beat. `pass_beat()` on a fighter spends one, which is a thing a beat can have done to it.

**One concept, one word, everywhere.** Naming consistency matters more than any single name being the best one. A tile is a cell in `Cell`, in `MapData`, in `Map` and in the importer, or it is a cell in none of them — a concept that answers to two words reads as two concepts, and the reader spends the file checking whether it is.

Where the code feeds a Godot API, borrow that API's vocabulary rather than inventing a parallel one. `set_cell(coords, source_id, atlas_coords)` is what the engine calls its arguments, so the fields that fill them carry those names. `get_next()`, `advance()`, `is_empty()` and `clear()` arrive already understood.

**A parameter never carries a member's name.** `action.actor = actor` makes the reader work out which `actor` each side is, and a typo that drops the `action.` compiles and does nothing. Godot will not catch it: GDScript warnings are an editor diagnostic and headless prints none, so `treat_warnings_as_errors` never fires on a run.

Where a function's arguments are exactly a class's fields, the function is the problem rather than the names. A four-argument factory that copies its arguments into four members earns nothing over the one caller setting them.

This holds for every factory that is only an assignment list. `Action` ended up with no static functions at all: it carries four fields and one predicate, and the timeline that stands actions up is what builds them.

**A name that needs `and` is doing two things.** `_set_data_and_rebuild` says so in its own name.

**A name says the operation, never a metaphor for it.** `_seat(character)`, `_stand(character)` and `_deal_card()` read as flavour; the reader opens each to learn it adds a tile, a figure or a card. `_add_party_tile(character)`, `_add_figure(character)` and `_add_skill_card()` say so from the call site. The engine's vocabulary — `add_child`, `show`, `apply`, `create`, `register` — is the pool to draw from.

**A name documents itself; a comment on every declaration is noise.** Name the variable or the function so the line reads on its own, and spend a comment only where the name cannot carry the whole of it.

Group declarations into logical units instead — a blank line between units, and at most one comment per unit. `Map`'s constants are three units, not seven declarations:

```gdscript
const WIDTH := 52
const HEIGHT := 60

const ROW_SLOTS := 3

const SLOT_FLOOR := 0
const SLOT_ENTITY := 1
const SLOT_WALL := 2
```

## Line length

**A line of code fits on the screen.** The screen is about 120 columns, counting a tab as 4. A line within it stays whole: there is no cap to wrap at.

**A line too long is shortened by naming part of it**: a local variable, or a function when the part is a rule of its own. One that also repeats elsewhere is a function.

```gdscript
if not _is_waiting or get_inspected_character() != hero or skill not in FightRules.get_usable_skills(_fight_model, hero):
```

becomes

```gdscript
var usable_skills := FightRules.get_usable_skills(_fight_model, hero)
if not _is_waiting or get_inspected_character() != hero or skill not in usable_skills:
```

**Never continue a line with `\`.** It breaks the line without naming anything.

## Packed formats

**The decode function is the format.** Where a resource holds packed bytes, the script that reads them is the only statement of what a record holds and in what order — the importer that writes them follows it, and a change to one is a change to the other.

Do not restate the layout in a comment beside `RECORD_SIZE`; a comment drifts from the decode silently, and then two things claim to be the format.

## Warnings

**A script parses without warnings.** A warning left standing trains the reader to skim past the next one.

Dividing one int by another raises `INTEGER_DIVISION` — Godot cannot tell a deliberate floor from a lost remainder. Answer it in the code rather than silencing it, so the line says which one it is:

```gdscript
return floori(records.size() / float(RECORD_SIZE))
```

**Never reach for `@warning_ignore`.** It hides the question instead of answering it, and the next reader learns nothing from a line that was only made quiet.

## Debug tooling

**Debug tools live in `debug/`, outside the game.** Console commands, debug arguments and debug-only behaviour sit there, and drive the game through what it already exposes: signals, models, public methods. Nothing outside `debug/` registers a command or grows a method for debugging.
