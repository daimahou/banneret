---
triage: ready-for-agent
id: 1.2-1.9
requires:
  - "[[Simulated preview]]"
started: 2026-10-25
finished:
hours: 0.9
parent: "[[Warrior kit]]"
---
# Done when

- The nameplates, the skill bar and the rope know nothing of the fight model or its preview: each shows a value in a style, and nothing else.
- The real side writes the fight; `PreviewPresenter` writes the preview over it. Disconnected, the real fight shows alone.
- The fight looks and plays as before, but for an unusable skill: it hangs no ghost.

## Implementation decisions

- One channel per readout: the last call wins. Every UI change goes through the presenter, so the preview always writes after the real side. A widget applies each call at once.
- Style: none, worse or better, the pulse as now. Rope entries also take ghost, faded or crossed.
- Nameplate: `show_health(health, max, style)`. No style: the yellow drains to the fill. A style: the yellow holds where it stands and the label pulses. `show_pips(states)`, each pip held, empty, lost or gained. `show_character` stays as it is.
- Skill bar: `show_skills(skills)` for the whole bar, so the flips stagger; per slot `set_cooldown(slot, beats, style)`; `set_usable(skills)`. The bar no longer reads characters. A card dims on the beats it shows: a cooldown the preview starts dims it.
- Rope: `show_entries(entries)`, each a tick, a key, a portrait and a style; knots included, beats marked. It keeps the layout, the tweens and the hit test, which returns the entry's action. It no longer connects to any model.
- Real side: the brain drives the skill bar; the stage drives the nameplates and the rope on the fight's signals. The rope's real entries come from a static function: the knots up to the next beat, the timeline's order on a shared tick.
- `PreviewPresenter`, `stage/preview_presenter.gd`: a `RefCounted` the stage builds in `show_encounter` and drops in the transition back to the mission. It follows both models, and `show_choices`, which hands it the inspected character and the shown action.
- The rope shows the preview's actions, each styled against the fight: resolved in the preview fades, cancelled is crossed, one the fight lacks hangs as a ghost. The shown action never fades. The ghost is the shown action, when the fight lacks it; the stage hangs none of its own. A ghost the preview cancels is crossed, at full alpha.
- The preview model stays `Stage.preview_model`, synced and played as now.
- Damage numbers, falls, lunges and puppets follow the real fight only.
- Lands before [[Bash and effect preview|Bash]]: its moved ghosts and arrows are a rope style the presenter sets.

## Testing decisions

- `tests/stage/preview_presenter_test.gd`: the comparisons as pure functions on built models: health style, pip states, cooldown styles, entry styles, the ghost.
- The real rope entries: knots up to the next beat, an action due now before any knot, a shared tick in the timeline's order.
- The look is judged by playing.

## Out of scope

- Any new look.
- A screen-wide effect while a preview shows; a broken stick for a previewed fall. Polish, later.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
