---
triage: ready-for-agent
id: 1.1-3.2.2
requires:
  - "[[Encounter art]]"
started:
finished:
parent: "[[Encounter transition]]"
---
# Done when

- Every puppet, the coach included, sways gently side to side.
- Reaching the encounter plays the transition: the coach leaves the stage to the right, the flats flip to the battle illustration, the party and the enemy slide in from the sides.
- `end_encounter` plays it back, onto a new mission.

## Problem

The encounter ends the mission without a fight; the stage only knows how to show the mission map.

## Solution

The stage transitions between the mission map and the fight in three beats, and back through the same beats in reverse. Same scene throughout: the flats show a graphic instead of the map, puppets come in from the sides.

## Implementation decisions

- **Puppet** — `stage/puppet.gd`, a `Node2D` with a sprite whose origin is its stick foot. Sways on a looping sine tween of its rotation, from a random phase so puppets don't rock in step; it keeps swaying while it moves.
- The coach becomes a puppet.
- `CharacterData` gains `puppet: Texture2D`.
- **Rogue** — `hero/archer.tres` becomes `hero/rogue.tres` ("Rogue"), in `PARTY_HERO_IDS`; puppet `art/puppet/rogue.png`.
- **Enemy** — `enemy/brigand.tres`, a placeholder `CharacterData`. The encounter's enemies are the fixed `[brigand]` until [[Timeline]] gives the encounter a model.
- **Stand positions** — on the floor line in front of the flats. Heroes spread across the left half of the `Flats` rect, enemies across the right half; front of each line towards the middle. Party order = `PARTY_HERO_IDS`, the first at the front. Computed from the `Flats` rect, so any count lays out. They enter and leave beyond the curtains.
- **Battle illustration** — `art/stage/battleground.png` sits at `Stage.BATTLEGROUND_RECT`, the painted panel area in stage space (~x 971–2909, y 373–1117). Each flat shows the part of the art under its own rect: a crop, no stretch.
- **Flats** — size and layout logic unchanged. A flip = the whole `Flat` scales x to 0 about its centre, its content swaps, scales back.
- **To the fight** — `Stage.show_encounter(party, enemies)`, returns when done:
  1. The coach slides off the stage to the right.
  2. The flats flip one after another, left to right, from the map to their part of the battle illustration.
  3. The heroes slide in from the left, the enemy from the right.
- **Back** — `Stage.show_mission` plays the transition back when the fight is showing, instant otherwise: puppets slide out the way they came, the flats flip to the new mission's map, the coach comes in from the left to its start.
- **Flow** — `RunController` answers `mission_ended` with `show_encounter`. It registers `end_encounter` = `start_mission(randi())`; `map_seed` during the encounter goes back the same way, onto its seed.
- The mission stays alive, idle, through the fight, until a new one replaces it.
- `map_seed` and `end_encounter` are ignored during a transition; `end_encounter` is ignored outside an encounter.
- No map node is pickable during a transition or the fight.

## Testing decisions

- Unit tests only, no scene:
  - `PuppetLayout.get_stand_positions(flats_rect, count, side)` — one position per puppet, front first, inside its half, on the floor line.
  - `Flat.get_battle_region(flat_rect, battleground_rect, texture_size)` — the part of the art under one flat.
- Flow, timing and motion are judged by playing.
- `tests/run/run_controller_test.gd` stays as is.

## Out of scope

- The fight itself, health, names — [[Timeline]], [[Fight on stage]].
- Enemies drawn per encounter.
- Flat size, layout, icon margin, flat panel art — [[Flat fit]].

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
