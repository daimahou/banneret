---
triage: ready-for-agent
id: 1.1-1.1.2
requires:
  - "[[Map layout]]"
started: 2026-10-21
finished: 2026-10-21
hours: 1.5
parent: "[[Mission map]]"
---
# Done when

- The player picks a connected node and the coach moves to it.
- Arriving on an encounter node ends the mission (stub).

## Problem

The mission map is only a picture: the coach can't travel it, and the map doesn't show where the party has been or can still go.

## Solution

Clicking a pickable map node makes the coach travel to it along the stage floor; the mission map shows the trail, the open choices and what is out of reach.

## User stories

1. As the player, I want to click a connected map node, so that I choose my route.
2. As the player, I want the coach to slide under that node's flat, so that I see the party travel.
3. As the player, I want the roads I travelled and my current map node in golden brown, so that I see my trail.
4. As the player, I want a hovered choice and its road in blue, so that I see where a pick leads before committing.
5. As the player, I want choices I passed up and everything out of reach dimmed, so that only real options stand out.
6. As the designer, I want the encounter to end the mission as a signal, so that the encounter can hook in later.
7. As the designer, I want the mission to play headless, so that the simulation is testable without the scene.

## Implementation decisions

- **MVC.** The simulation plays headless; scenes only render it and route input.
  - **Model** — `MissionModel`, pure data over a `MissionMap`: `travel_to`, current node, open nodes, `is_mission_ended`, and a `Visitation` (closed, ahead, open, travelled, current) per map node and per road. No signals.
  - **Controller** — `MissionController`, root of `mission.tscn` (the main scene): generates the map, registers `map_seed`. On a click on an open node: sets the model, then awaits `Stage.show_travel`; input is ignored until it returns. Then, if the mission ended: logs `Mission ended: encounter reached`, emits `mission_ended`.
  - **View** — `Stage`: draws the model, tweens the coach, owns hover.
- **Travel**: the coach tweens on x to the centre of the node's flat over `TRAVEL_DURATION`, eased by `TRAVEL_TRANSITION` and `TRAVEL_EASE`, y unchanged.
- **Open**: off the map, every column-1 node; then the current node's next nodes; none once the mission ended.
- **Look per visitation**:
  - Travelled map nodes and roads (lead-in included) — golden brown.
  - Open, ahead — normal. Closed — dimmed (`DIMMED_ALPHA`).
  - Hovered (blue) — an open node and the road to it from the current node, only while the coach is still. A node already under the mouse lights up as the coach arrives.
  - A merged dash shows its strongest road: hovered > travelled > normal > dimmed.
- **Timing**: the model changes on click, so the view redraws at once; the coach then travels while nothing is pickable.
- **Recolour**: one `canvas_item` shader moves each pixel towards the colour as far as it is dark — ink takes it, light fills keep theirs. Dashes draw on a recoloured layer per colour; icons take the material.
- `map_seed <n>` keeps its name; it starts a fresh model, resetting the coach and the trail.

## Testing decisions

- Seam: `MissionModel` — missions played on hand-built maps: open nodes before and after travel, visitation of passed-up choices, travelled roads and lead-ins, the encounter ending the mission.
- `MissionMap.get_next_map_nodes` keeps its own tests.
- Travel animation and colours are judged by eye in the running scene.

## Out of scope

- Hop / wobble animation, hover polish beyond the colour.
- Renaming `map_seed` — waits for the map-to-map transition.
- What happens on a non-encounter node — [[One event]].

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
