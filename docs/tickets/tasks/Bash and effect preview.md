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
- An action the delta already cancels is not moved: a lethal Bash moves nothing.
- The presenter hangs a moved ghost for each action the preview's history moves, at its last moved tick, keyed apart from the real medallion. The real medallion keeps its style (faded, crossed); the ghost is crossed too when the preview cancels the action. Several moves: one ghost, one arrow.
- Moved ghost: the actor's portrait in its own ring at ghost alpha, `art/timeline/medallion_moved.png`: a placeholder, `medallion.png` tinted toward `2f5d8a` at the same size, which the human replaces with a dotted ring. The real medallion stays put until the move happens.
- No pulse: the rope has none.
- Arrow drawn in code, one per move: an arc below the medallions, from the real medallion's bottom to the ghost's, sagging deeper the longer it runs, so nested arcs nest; overlapping ones may cross. `2f5d8a`, 6 px, ghost alpha, an arrowhead at the ghost. It fades out with its ghost.
- At impact the preview re-syncs: the ghost lifts and fades as any removed entry, while the real medallion slides into its slot.

## Testing decisions

- `tests/fight/fight_rules_test.gd`: Stagger moves every pending action of the target, after those already on that tick, in their order, and emits `action_moved`; a lethal Bash moves nothing; a target with nothing pending only takes damage.
- `tests/stage/preview_presenter_test.gd`: a moved action gives a moved ghost at its preview tick, keyed apart from its real medallion, which stays at its own tick; two moves give one ghost at the last tick; a move then a cancel gives a crossed ghost.
- The look is judged by playing.

## Out of scope

- Stability and anything else that resists the stagger.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
