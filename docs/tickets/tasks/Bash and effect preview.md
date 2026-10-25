---
triage: ready-for-agent
id: 1.2-1.4
requires:
  - "[[Simulated preview]]"
  - "[[Preview presenter]]"
started:
finished:
hours: 0.3
parent: "[[Warrior kit]]"
---
# Done when

- [[Bash]] deals its damage and [[Stagger|staggers]] the target: all its pending actions move 2 ticks later, landing after the actions already on that tick, in their order. Staged: at impact the medallions slide to their new spots.
- A move in a preview hangs as a moved ghost where the action would land, with a curved arrow from the real medallion to it that clears the other medallions. It pulses, as every preview difference.

## Implementation decisions

- `StaggerEffect.ticks`, 2 on `bash.tres`. The card reads `Stagger 2`, the number in its own colour. No tooltip.
- A change moving one action by id: its resolve tick, re-sorted after the actions already there; `FightModel.action_moved`, which the rope follows. The preview's history holds it as the action's move. Moving the target's actions in timeline order keeps their order.
- An action the delta already cancels is not moved: a lethal Bash moves nothing.
- Moved ghost: the actor's portrait in a dotted medallion at ghost alpha, `art/timeline/medallion_moved.png`, a placeholder the human replaces. The real medallion stays put until the move happens.
- Arrow drawn in code, one per move: an arc above the rope, higher the longer it runs, so arcs nest; below the medallions if there is no room above.

## Testing decisions

- `tests/fight/fight_rules_test.gd`: Stagger moves every pending action of the target, after those already on that tick, in their order; a lethal Bash moves nothing; a target with nothing pending only takes damage.
- The look is judged by playing.

## Out of scope

- Stability and anything else that resists the stagger.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
