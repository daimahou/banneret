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

**A name documents itself; a comment on every declaration is noise.** See Comments.

## Comments

**A comment says why, never what.** The code tells the computer what to do; a comment tells a human why it is done that way. A comment saying what the code does is a name or a structure not yet written: rename or restructure, then delete it. No comment is better than a wrong or confusing one.

**The test: could the reader learn it from the declaration and the lines below?** Then it is narration, however short or true. A comment earns its place only with what is not there to read: a reason, a rule decided elsewhere, a surprise.

**What qualifies**

- **A game rule** the code applies: `# On a shared tick, the beat comes first.`
- **A reason** the reader would otherwise undo: `# Stronger than a ghost's: it must read at a glance.`
- **A gotcha**, what surprises or breaks if the line is taken at face value: `# A move cuts any fade in short, so it finishes the fade too.`
- **A value's meaning** the declaration cannot show: a unit, a space, an order, what null or -1 means. `# Null for a skill shown before its target is chosen.` over `var target: Character`.
- **A class header**, the one place a *what* belongs: the class's role in the architecture, what drives it and what it drives. No implementation details, unless the reader needs them before reading the class. A class whose name and folder make its role plain has none.

**What does not qualify**

- Restating the name below it.
- Narrating the lines below it, or when a coroutine returns: `# Null unless it is pending.` over a loop that returns null when no pending action matches.
- Stating an exception without its reason: `# Becomes a copy of fight_model, with an empty history.` leaves the reader asking why. `# The history is not copied: a preview's history holds only what the preview plays out.` answers it.
- A header walking through the implementation.
- A sentence the reader must read twice.

**Keep or delete; never compress.** A comment worth keeping is a whole sentence that reads at once. Cut down to a fragment, `# Over the history.` or `# Both in the entries' space.`, it says less and reads worse. There is no length cap: a comment is judged by what it says and how it is written.

**A comment standing in for a name is replaced by the name.**

```gdscript
# Once this delta is applied.
func get_health(character: Character) -> int:
```

becomes

```gdscript
func get_resolved_health(character: Character) -> int:
```

and

```gdscript
# The medallions of these actors hang highlighted.
func set_marks(actors: Array[Character]) -> void:
```

becomes

```gdscript
func highlight_actors(actors: Array[Character]) -> void:
```

**A header says the role, not the steps.**

```gdscript
# The timeline, strung across the top of the stage: a knot for each tick to come, and a medallion with its actor's portrait for each action, hung after the knot of the tick it resolves on.
# The rope's shape is its line's points, traced by hand over the rope drawn on the background; each thing on it hangs where the line passes. It hangs the entries it is told, each in its style: a ghost or a faded one at ghost alpha, a crossed one under a cross.
```

keeps the role and the one gotcha:

```gdscript
# The timeline, strung across the top of the stage. It hangs the entries it is told, each in its style.
# The rope's shape is its line's points, traced by hand over the rope drawn on the background.
```

**One comment per unit of declarations.** Group them into logical units, a blank line between units, and the unit carries the comment:

```gdscript
# A blow: the actor's puppet lunges at its target, stopping `LUNGE_GAP` short of it, then goes home, and the stage pauses before the next one. In design units and seconds.
const LUNGE_GAP := 220.0
const LUNGE_DURATION := 0.25
const RETURN_DURATION := 0.35
const BLOW_PAUSE := 0.25
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
