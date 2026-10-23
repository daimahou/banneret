---
triage: ready-for-agent
id: 1.1-1.1.1.3
requires:
  - "[[Stage art]]"
  - "[[Mission map generation]]"
started: 2026-10-20
finished: 2026-10-21
hours: 3
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
- A **flat** is a `Control` in an `HBoxContainer`, so all flats share one size and spacing. It is handed one column and draws it; it never knows the column's index. Mission map columns and flats are not the same count by design — 4 each for now, more columns than flats is an error until scrolling exists.
- A row places a map node evenly down its flat, plus the stored jitter. Jitter towards a neighbouring row of the same column is capped, so neighbours stay `MAP_NODE_MIN_SPACING` apart.
- Map nodes are `TextureButton`s on the flat, icon from the `EventType` table. No click behaviour yet.
- **Roads**: each curve is computed once in stage space — a `Curve2D` bent sideways by the stored wobble, its bend kept within the flats' height. Dashes stop short of each end node's icon (half its width plus a small gap). Inside each flat it crosses, the curve's span gets a run of dashes — against the road's node when the span touches one, centred otherwise, so the slack falls at the seams — spaced by each sprite's own width plus a const gap, each turned along the curve with a little seeded tilt and a random variant; a variant too wide gives way to one that fits, and a span too short for any, but at least half the narrowest, still gets the narrowest. So a road breaks only at the gaps between flats.
- **Road dashes, two passes**: lay out every road, then prune. A dash overlapping a kept dash from another road merges into the one it overlaps most, and the merged dash is re-checked until it overlaps none; it takes the average position and rotation of all merged into it. Near a node two roads share, dashes merge as soon as they are near: roads out of one node start as one, roads into one node join before arriving. A road's first dash never merges with a road from another node, so each map node shows its own way out.
- Each dash is drawn by the flat whose rectangle contains it, after merging; one left in a gap is dropped.
- Flat 1's incoming roads start on an imaginary flat 0, one flat-width to its left, each at its own node's height, so they come in side by side. No road starts at the coach.
- A fresh mission map takes a random seed and prints it; `map_seed <n>` is registered with limbo_console.

## Testing decisions

- Drawing is judged by eye in the running scene. The generator is covered by [[Mission map generation]].
- Road geometry lives in `RoadLayout`, apart from the scene. Seam: `RoadLayout.prune_road_dashes` — the merge rules (branches from one node merge, first steps from different nodes don't, a merged dash keeps every road it absorbed).

## Out of scope

- Clicking a map node, moving the coach — [[Coach travel]].
- Offers dropping from the ceiling — [[One event]].
- Flat turning animation, scrolling for longer mission maps, flat art.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
