---
triage: ready-for-agent
id: 1.1-1.1.1.2
requires:
started: 2026-10-20
finished: 2026-10-20
hours: 0.4
parent: "[[Map layout]]"
---
# Done when

- A seed produces a mission map: map nodes, roads between them, and an event on each.
- The gdUnit4 suite proves the next-node choice never offers a road that crosses another.

## Problem

The coach needs a mission map to travel — generated, never crossing, and reproducible from a seed.

## Solution

A pure-data generator in two passes, **layout** then **content**, sharing only the graph.

## User stories

1. As the player, I want a different mission map each mission, so that each run plays differently.
2. As the player, I want at least two different first choices, so that the first decision is real.
3. As the player, I want roads that never cross, so that the mission map reads at a glance.
4. As the player, I want every road to end at the encounter, so that no choice is a dead end.
5. As the designer, I want every layout number as a named const, so that I tweak the design in one place.
6. As the designer, I want content rules in code, in order, so that I add a rule without touching the layout.
7. As the designer, I want a seed in and the same mission map out, so that I can replay a map I saw.

## Implementation decisions

**Layout pass** — seed → graph.
- A 3×3 lattice (columns 1–3) plus column 4: one encounter map node, middle row.
- `PATH_COUNT = 3` paths. A path starts on a random row of column 1; the first two start on different rows.
- A step goes to row −1, 0 or +1 of the next column, picked at random among the candidates that cross no existing road. Same row never crosses, so a candidate always exists.
- Roads `(x−1, a)→(x, b)` and `(x−1, c)→(x, d)` cross when `(a − c)·(b − d) < 0`.
- Lattice cells no path touched are dropped. Every column-3 map node links to the encounter.
- A map node holds column, row, `EventType`, its links to the previous and next column, and its seeded position jitter. A road's seeded wobble is stored too, so the view draws the same mission map from the same seed.
- Every number is a `const` at the top of the generator, grouped per the [[gdscript conventions]].

**Content pass** — graph + mission context + seed → an event on each map node.
- `enum EventType { PLACEHOLDER, ENCOUNTER }`, and one const table maps a type to its icon.
- An ordered list of rules, in code: column 4 → `ENCOUNTER`; any other → a random pick among non-encounter types (only `PLACEHOLDER` for now).
- Mission context = the mission's index in the act. Nothing reads it yet.

## Testing decisions

- Seam: the next-node choice — given a column's existing roads and a starting row, the rows it may step to.
- Known setups in, assert no invalid row is offered (e.g. road 0→1 present: from row 1, row 0 is never offered). See [[feedback-loop]].
- No tests over many seeds; no test reads back a const.

## Out of scope

- Drawing anything — [[Mission map on stage]].
- Mission tiering, neighbour rules, real event types, encounter variants.
- Coach movement — [[Coach travel]].

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
