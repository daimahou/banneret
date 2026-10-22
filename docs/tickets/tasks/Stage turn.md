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
- Reaching the encounter turns the stage: the coach sinks under the stage front, the flats turn to the battle illustration, the party and the enemy slide in from the sides.
- `end_encounter` turns it back, onto a new mission.

## Problem

The encounter ends the mission without a fight; the stage only knows how to show the mission map.

## Solution

The stage turns between the mission map and the fight in three beats, and turns back through the same beats in reverse.

## Implementation decisions

- **Puppet** — `stage/puppet.gd`, a `Node2D` with a sprite whose origin is its stick foot. Sways on a looping sine tween of its rotation, from a random phase so puppets don't rock in step; it keeps swaying while it moves.
- The coach becomes a puppet.
- `CharacterData` gains `puppet: Texture2D`.
- **Enemy** — `enemy/brigand.tres`, a placeholder `CharacterData`. The encounter's enemies are the fixed `[brigand]` until [[Timeline]] gives the encounter a model.
- **Turn to the fight** — `Stage.show_encounter(party, enemies)`, returns when the turn is done:
  1. The coach rotates and slides down until hidden under the front.
  2. The flats turn one after another, left to right: width scales to 0 about the centre, the column is replaced by the flat's slice of `battle.png`, width scales back.
  3. The heroes slide in from the left, the enemy from the right, onto the stage floor.
- **Turn back** — puppets slide out, the flats turn to the new mission's map, the coach rises back in at the start.
- **Flow** — `RunController` answers `mission_ended` with `show_encounter`. It registers `end_encounter`, which turns back onto a new mission from `randi()`. A `map_seed` during the encounter turns back the same way, onto its seed.
- No map node is pickable while the stage turns or shows the fight.

## Testing decisions

- Seam: `RunController`, the run scene built headless.
  - Reaching the encounter puts one puppet per hero and enemy on stage.
  - `end_encounter` leaves no puppet but the coach, starts a new mission, and keeps the same hero instances.
- Timing and motion are feel work, judged by playing.

## Out of scope

- The fight itself, health, names — [[Timeline]], [[Fight on stage]].
- Enemies drawn per encounter.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
