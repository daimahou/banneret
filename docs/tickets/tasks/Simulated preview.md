---
triage: ready-for-agent
id: 1.2-1.8
requires:
  - "[[AP pips]]"
started: 2026-10-25
finished:
hours: 0.8
parent: "[[Warrior kit]]"
---
# Done when

- During a stop, arming or hovering a skill, or hovering a medallion, previews it: the fight played out, no brains, until that action lands; nameplates, cards and rope show the difference.
- During play the preview runs ahead of each blow: it takes the resolve as the lunge starts, the real state catches up at impact.

## Implementation decisions

- Ids: a character takes its own as it is created, unique across the run; an action takes the fight model's next as it is added. `sync` copies the counter, so a ghost gets the id its real action would.
- A `Change` holds ids and looks them up in the model it applies to: one delta applies to either state.
- `RemoveAction` splits into `ResolveAction` and `CancelAction`; `action_removed` into `action_resolved` and `action_cancelled`. Both leave the timeline: it holds pending actions only, `timeline[0]` next.
- `FightModel.history`: the deltas it applied, in order; `sync` clears it. An action's fates are the changes in the preview's history naming it: moved, then resolved or cancelled.
- The preview: a `FightModel` the stage builds for each encounter; no stage, no preview. `sync` deep-copies the tick, the characters, the timeline and the id counter; data resources are shared, never copied. It emits `changed`.
- `FightRules.is_beat_next`, shared with `FightController`.
- On a shared tick, an action chosen on top of its actor's own queues after them: two orders to one character play in the order given. `FightModel.get_timeline_index` places both the action and the rope's ghost.
- `Simulation.run(preview, fight_model, action)`: syncs, adds the action if not pending, steps beats and resolves until it resolves, is cancelled, or the fight ends. No target: the choice only.
- During play: the preview syncs on the fight's `changed`, after every real `apply`; it applies a resolve as the lunge starts, the real state at impact.
- Shown skill: the hovered one, else the armed one. Only the armed skill has a target: the hovered character if the skill reaches them, else the aimed one. A hovered character it cannot reach = no target.
- A hovered medallion wins over a skill, and plays the real timeline without the ghost. A hovered skill of anyone but the hero previews nothing. An unusable skill hangs its ghost and previews nothing.
- Nameplate: yellow from the real health, red from the preview's; the hold goes, the yellow drains to the red at impact. Label: the preview's `health/max`, pulsing softly when it differs.
- A pip lost by landing pulses red; one held at landing but not all the way there (gained, or spent and got back) pulses green; one held all the way stays as it is. The inspected character's cards show the preview's cooldown, the number pulsing where it differs.
- A difference bad for the character is red, a good one green.
- Rope: the ghost as now; a cancelled action takes the two-stroke cross from before `71aea8f`; a resolved one fades to ghost alpha; the shown action never fades.
- A fall shows only `0/max` and its crossed actions.

## Testing decisions

- `tests/fight/fight_model_test.gd`: a delta applied to the preview leaves the real state untouched; `sync` brings them level.
- `tests/fight/fight_rules_test.gd`: a fall cancels, a resolve resolves.
- `tests/fight/simulation_test.gd`: a play-out stops once the action lands; its history holds the cancels and resolves on the way.
- The look is judged by playing.

## Out of scope

- Telling the skill's part from the simulation's.
- Health gains: nothing heals yet.
- Save and replay from the history.
- A mark on a falling puppet.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
