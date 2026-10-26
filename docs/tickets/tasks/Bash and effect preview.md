---
triage: ready-for-agent
id: 1.2-1.4
requires:
  - "[[Simulated preview]]"
  - "[[Preview presenter]]"
started: 2026-10-26
finished:
hours: 0.5
parent: "[[Warrior kit]]"
---
# Done when

- [[Bash]] deals its damage and [[Stagger|staggers]] the target: all its pending actions move 2 ticks later, landing after the actions already on that tick, in their order. Staged: at impact the medallions slide to their new spots.
- A move in a preview hangs as a moved ghost where the action would land, with a curved arrow from the real medallion to it that clears the other medallions.

## Implementation decisions

- `StaggerEffect.ticks`, 2 on `bash.tres`. The card reads `Stagger 2`, the number in `STAGGER_COLOR` `2f5d8a`. No tooltip.
- A change moving one action by id: its resolve tick, re-sorted after the actions already there. It emits `FightModel.action_moved`, as the other changes emit theirs; the rope follows `changed`, as now. The preview's history holds it as the action's move. Moving the target's actions in timeline order keeps their order.
- A lethal Bash still moves the target's actions: the move stays in the history, so a preview shows them moved and crossed. The target may be healed before the Bash lands. On the timeline, a move of an action the fall already cancelled does nothing.
- Each `TimelineEntry` carries the `id` the rope matches its node by from one show to the next. The presenter builds the medallions; `create_entries` adds the knots.
- The presenter hangs a moved ghost for each action the preview's history moves, at its last moved tick, with an id apart from the real medallion's: both show at once. Style `MOVED`, or `CROSSED` when the preview cancels the action. The real medallion keeps its style (faded, crossed). Several moves: one ghost, one arrow.
- The rope draws `MOVED` as the actor's portrait in its own ring at `MOVED_ALPHA` 0.75, stronger than ghost alpha so it reads at a glance, `art/timeline/medallion_moved.png`: a placeholder, `medallion.png` tinted toward `2f5d8a` at the same size, which the human replaces with a dotted ring. The real medallion stays put until the move happens.
- No pulse: the rope has none.
- Arrows are the presenter's: it computes them from where the rope says each ring settles (`get_ring_bottom`, `get_ring_bottoms`) and hands them to `PreviewArrows`, a widget that only draws; the presenter makes it beside the rope and frees it when disposed. The rope knows nothing of arrows.
- One arrow per move: an arc below the medallions, from the real medallion's bottom to the ghost's, sagging deeper the longer it runs, so nested arcs nest; overlapping ones may cross. It passes under every medallion between its ends. `2f5d8a`, 6 px, the moved ghost's alpha, a filled arrowhead at the ghost. It fades in at the settled spots, and out when the presenter shows none.
- At impact the preview re-syncs: the ghost lifts and fades as any removed entry, while the real medallion slides into its slot.

## Testing decisions

- `tests/fight/fight_rules_test.gd`: Stagger moves every pending action of the target, after those already on that tick, in their order, and emits `action_moved`; a lethal Bash still moves what the fall cancels; a target with nothing pending only takes damage.
- `tests/stage/preview_presenter_test.gd`: a moved action gives a moved ghost at its preview tick, keyed apart from its real medallion, which stays at its own tick; two moves give one ghost at the last tick; a move then a cancel gives a crossed ghost; a lethal Bash hangs the target's actions moved and crossed.
- The look is judged by playing.

## Out of scope

- Stability and anything else that resists the stagger.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
