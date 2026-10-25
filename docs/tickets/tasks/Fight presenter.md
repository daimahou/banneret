---
triage: needs-info
id: 1.2-1.9
requires:
  - "[[Simulated preview]]"
started: 2026-10-25
finished:
hours:
parent: "[[Warrior kit]]"
---
# Done when

- The nameplates, the skill bar and the rope know nothing of the fight model or its preview: each takes plain state through its own API.
- One class follows the fight model and the preview model, compares them, and pushes that state; the comparison rules live there, unit-tested.
- The fight looks and plays as before.

## Starting points

- Nameplate: `show_health(health, previewed_health, max_health)` and `show_pips(states)`, each pip held, empty, lost or gained.
- Skill bar: the cards already take values (`show_skill(skill, cooldown_beats, previewed_beats, delay)`); `show_skills` still takes characters.
- Rope: takes its entries (tick, key, portrait; ghost, faded or crossed) and keeps the layout, the tweens and the hit test, which returns the entry's action.
- The class refreshes at most once a frame, from both models' signals.
- The widgets keep the pulses, the yellow drain and the tweens.
- Its own class, not more of `Stage`.
- Lands before [[Bash and effect preview|Bash]]: its moved ghosts and arrows go into this class, not into the rope as a third check on the models.

## Open for the grill

- The name: **Preview** is the fight once an action lands, so `StagePreview` would blur it. `FightPresenter`, `FightView`, other?
- What else goes through it: damage numbers, falls, puppets, the ghost and the shown action from the brain; or only the preview's differences.
- Who owns the preview model: this class or the stage.
- The test seams.

## Out of scope

- Any new look.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
