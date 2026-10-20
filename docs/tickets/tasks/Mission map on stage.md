---
triage: ready-for-agent
id: "1.1-1.1.1.3"
requires:
  - "[[Stage art]]"
  - "[[Mission map generation]]"
started:
finished:
parent: "[[Map layout]]"
---
# Done when

- Running the main scene shows the stage with a freshly generated mission map across the 4 flats, and logs its seed.
- `map_seed <n>` in limbo_console rebuilds the mission map from seed `n`.

## Problem

The generated mission map has to be seen — on the stage, as flat art that can later turn with its flat.

## Solution

A stage scene: back layer, 4 flats each drawing one column, front layer, the coach standing at far left.

## User stories

1. As the player, I want the mission map painted on the flats, so that the stage is the map.
2. As the player, I want each map node's icon to show its event type, so that I can plan my route.
3. As the player, I want roads that curve and look hand-drawn, so that the mission map feels drawn, not plotted.
4. As the player, I want the coach on the stage floor at far left, so that I see where the party stands.
5. As the designer, I want a road's dashes to belong to the flat they sit on, so that a flat turns with its art when it swaps.
6. As the designer, I want art swapped at another resolution not to move the layout, so that art upgrades are a file swap.
7. As the designer, I want to replay a seed from the console, so that I can inspect a mission map I saw.

## Implementation decisions

- Design resolution 3840×2160 — [[0001-design-resolution-4k]]. Sizes are design units.
- UI is `Control`; figures are `Node2D`. The coach is a `Node2D`, standing still.
- Draw order: back layer → flats → front layer.
- A **flat** is a `Control` placed in the stage scene. It is handed one column and draws it; it never knows the column's index. Mission map columns and flats are not the same count by design — 4 each for now, more columns than flats is an error until scrolling exists.
- A row places a map node evenly down its flat, plus the stored jitter.
- Map nodes are `TextureButton`s on the flat, icon from the `EventType` table. No click behaviour yet.
- **Roads**: each curve is computed once in stage space — a `Curve2D` bent sideways by the stored wobble — and sampled into dash positions spaced by each dash sprite's own width plus a const gap, each dash turned along the curve with a little seeded tilt and a random variant. Each dash is drawn by the flat whose rectangle contains it; dashes in the gaps between flats are dropped.
- Flat 1's incoming roads start at an imaginary flat 0's center, one flat-width to its left. No road starts at the coach.
- A fresh mission map takes a random seed and prints it; `map_seed <n>` is registered with limbo_console.

## Testing decisions

- No automated tests: drawing is judged by eye in the running scene. The generator is covered by [[Mission map generation]].

## Out of scope

- Clicking a map node, moving the coach — [[Coach travel]].
- Offers dropping from the ceiling — [[One event]].
- Flat turning animation, scrolling for longer mission maps, flat art.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
