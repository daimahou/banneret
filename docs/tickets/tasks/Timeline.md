---
triage: ready-for-agent
id: 1.1-3.3
requires:
  - "[[Party]]"
started: 2026-10-23
finished: 2026-10-23
parent: "[[Encounters]]"
---
# Done when

- An encounter plays headless on a timeline, seeded: one direct-damage skill, a random brain on each side, until one side falls.
- A chosen skill queues on the timeline at its resolve tick; the earliest resolves first.
- A win leaves the party as the fight left it; a defeat loses the run.

## Problem

There is no fight: nothing acts, deals damage or decides a winner.

## Solution

Ported from prototype C's `fight/`, cut to one skill on one character of the other side: pure rules hand back a delta, the fight model applies it, a controller drives both brains until one side falls.

## Implementation decisions

- **Skill** in `skill/`:
  - `SkillData` — `Resource`: `name`, `delay` (ticks from choosing to resolving), `damage`.
  - `strike.tres` — the one skill, placeholder numbers.
  - `CharacterData` gains `skills: Array[SkillData]`; knight, rogue, mage and brigand hold `strike`.
- **Fight** in `fight/`:
  - `Action` — `actor`, `skill`, `target`, `resolve_tick`. No factory.
  - `FightModel` — the tick, the run's hero and enemy `Character`s held directly (no copy), the timeline of pending actions. Applies a `Delta` and signals each change.
  - `Delta` — the ticks it moves on and its `Change`s: `Health`, `AddAction`, `RemoveAction`. Applies nothing.
  - `FightRules` — pure: `get_choices`, `get_timeline_delta`, `get_resolve_delta`.
  - `Brain` — awaited `get_next_action(fight_model)`: an action for one of its side's free characters, or null. `RandomBrain` picks at random among the first free character's choices, seeded per side (`seed`, `seed + 1`).
  - `FightController` — `RefCounted`, `FightController.new(heroes, enemies, seed)`; `play()` loops until one side has fallen.
  - `FightRunner` — headless `SceneTree` script over `FightController`: `--fights=N --seed=S`, prints win %, ticks and health left; `print`, never LimboConsole.
- **Rules**:
  - A character chooses only when it has no pending action; the choice resolves at `tick + delay`.
  - Each step: a free enemy chooses; else, nothing due this tick, a free hero chooses; else the next action resolves.
  - On a shared tick the action chosen last resolves first.
  - A character falls at 0 health: it loses its pending action, and every action aimed at it is cancelled, freeing its actor.
- **Run** — `RunController` plays the fight once `show_encounter` returns, logs each resolved action and the outcome to LimboConsole. Either way the stage goes back to a new mission; a defeat first logs `Run lost` and replaces `run_model`. `end_encounter` is gone: the fight is over before it could be called.

## Testing decisions

- `FightRules`: a choice resolves `delay` ticks on; on a shared tick the action chosen last resolves first; a hit takes its damage off; a fallen character loses its pending action; an action aimed at a fallen character is cancelled and its actor freed.
- `FightController`: every enemy chooses before any hero; every fight ends with one side fallen; the same seed plays the same fight; a win leaves the heroes' health as the fight left it.
- The defeat → new run hookup is judged by playing.

## Out of scope

- The beat, cooldowns, statuses, any reach but one character of the other side.
- The fight on stage — [[Fight on stage]]; the player's choices — [[Hero choices]].

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
