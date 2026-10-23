---
triage: ready-for-agent
id: 1.1-3.2.2
requires:
  - "[[Encounter art]]"
started: 2026-10-22
finished: 2026-10-23
hours: 3
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

- **Puppet** — `stage/puppet/puppet.gd`, a `Node2D` with a sprite whose origin is its stick foot. Sways on a looping sine tween of its rotation, from a random phase so puppets don't rock in step; it keeps swaying while it moves.
- The coach becomes a puppet.
- **Puppets** — a `Control` on the stage marking where puppets stand; the coach and the fight puppets are its children, feet on its bottom edge.
- `CharacterData` gains `puppet: Texture2D`.
- **Rogue** — `hero/archer.tres` becomes `hero/rogue.tres` ("Rogue"), in `PARTY_HERO_IDS`; puppet `art/puppet/rogue.png`.
- **Enemy** — `enemy/brigand.tres`, a placeholder `CharacterData`. The encounter's enemies are the fixed `[brigand]` until [[Timeline]] gives the encounter a model.
- **Stand positions** — `PuppetLayout`: heroes spread across the left half of the puppets area, enemies across the right half, a middle gap kept clear; front of each line towards the middle. Party order = `PARTY_HERO_IDS`, the first at the front. They enter and leave beyond the curtains.
- **Scenery** — `stage/scenery/scenery.gd` on the flats' `HBoxContainer`. Owns the flats: shows and flips them, tracks hover, works out every node and road dash highlight. Flats only draw.
- **Mission map layout** — `MissionMapLayout`, computed once per mission from the flat size, separation and count: map node positions and road dashes per flat, in flat space. A road dash's highlight is the flat's, not the layout's.
- **Battle illustration** — `art/stage/battleground.png`, centred on the scenery; each flat shows the part under it. Bigger is cropped; smaller warns.
- **Flip** — the whole `Flat` scales x to 0 about its centre, its content swaps, scales back.
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
  - `PuppetLayout.get_stand_positions(area, count, side)` — one position per puppet, front first, inside its half, clear of the middle gap, on the area's bottom edge.
  - `MissionMapLayout.create(...)` — every map node and road dash inside its flat; neighbouring nodes keep their spacing despite jitter.
- Flow, timing and motion are judged by playing.
- `tests/run/run_controller_test.gd` stays as is.

## Out of scope

- The fight itself, health, names — [[Timeline]], [[Fight on stage]].
- Enemies drawn per encounter.
- Flat panel art.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
