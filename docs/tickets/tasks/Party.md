---
triage: ready-for-agent
id: 1.1-3.1
requires:
started: 2026-10-22
finished: 2026-10-22
hours: 0.3
parent: "[[Encounters]]"
---
# Done when

- The run starts with a fixed party of 3 heroes, held by the run.

## Problem

Nothing holds the player's state beyond one mission: there are no heroes, and nothing outlives the mission model.

## Solution

A run sits above the mission: it holds the party and starts each mission on the stage.

## Implementation decisions

- **Characters** in `character/`, shared with enemies later:
  - `CharacterData` — `Resource`: name, max health.
  - `Character` — `RefCounted` made from a `CharacterData`; holds health, full at the start. Damage will carry between fights.
- **Heroes** in `hero/`:
  - `knight`, `archer`, `mage` — placeholder `.tres`.
  - `hero_registry.tres` — Yard registry restricted to `CharacterData`, scanning `hero/`; written by hand in Yard's format. A registry, not a bag: the party is not drawn.
- **Run** in `run/`:
  - `RunModel` — holds `party`, loaded from the registry through the fixed `PARTY_HERO_IDS`.
  - `run.tscn` — the main scene: `Run` (`RunController`) with the `Stage`, which outlives any one mission.
  - `RunController` — logs `Party: <names>`, registers `map_seed`, creates the mission once the stage is laid out; `map_seed` disposes the current mission and starts a new one in the same run.
- **Mission**: `mission.tscn` is deleted. `MissionController` is a `RefCounted`, `MissionController.new(stage, map_seed)`; it connects to the stage itself, and `dispose()` disconnects it.
- The mission gets no party until something reads it.

## Testing decisions

- Seam: `RunController`, the run scene built headless — a new run holds the listed heroes at full health; `map_seed` starts a new mission, keeps the same hero instances, and leaves only the new mission answering the stage.
- The `MissionModel` tests stay as they are.

## Out of scope

- Puppets and any party visuals, handing the party to the encounter — [[Encounter transition]].
- Skills — [[Timeline]], [[Fight on stage]].

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
