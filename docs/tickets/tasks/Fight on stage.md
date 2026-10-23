---
triage: ready-for-agent
id: 1.1-3.4
requires:
  - "[[Encounter transition]]"
  - "[[Timeline]]"
started: 2026-10-23
finished: 2026-10-23
hours: 2.4
parent: "[[Encounters]]"
---
# Done when

- The fight plays on stage as it unfolds: actions on the timeline, damage, HP bars, falls; the heroes on the random brain for now.

## Problem

The fight only plays in code; the player cannot watch it.

## Solution

The fight controller awaits the stage only when an action resolves; choices apply at once. The stage stages the blow and applies the delta as it lands; the fight model's signals drive the rope, the health bars and the falls. Ported from prototype C's timeline rope and `play_action`.

## Implementation decisions

- **Pacing** — `FightController.new(heroes, enemies, seed, stage: Stage = null)`. A resolve awaits `stage.show_action(action, fight_model.apply.bind(delta))`; with no stage the delta applies at once, so `FightRunner` stays instant. Brains decide as fast as they can; only resolves take time.
- **Blow** — `Stage.show_action(action, on_impact)`: the actor's puppet lunges at its target, calls `on_impact` on contact, goes home. The whole delta, tick included, lands at impact.
- **On the model's signals**:
  - Health lost — the target shakes, a damage number floats up off it, its bar drops.
  - Fall — the puppet sinks below the stage front; its bar fades out.
  - Timeline or tick — the rope refreshes, once per delta.
- **Timeline rope** — `stage/timeline/timeline_rope.gd`, prototype C's rope cut down: a knot per coming tick, a medallion after the knot of its resolve tick, chosen last first on a shared tick. No tassels, beats or preview ghosts.
  - `Rope` — an invisible `Line2D` traced over the rope drawn in `background.png`; its points are set by hand in the scene. The drawn ties are `Ties`, kept clear.
  - `art/timeline/knot.png`, `medallion.png` — copied from the prototype.
  - Medallions drop in and lift out on short tweens, not awaited.
- **Portrait** — `CharacterData.portrait: Texture2D`; placeholder `AtlasTexture` crops of each puppet's head.
- **Health bar** — in the bottom half, below the stage front, at its puppet's x; a frame, a fill and `health/max`. Same for both sides. Slides in and out with its puppet; no sway.
- **End** — a ~1 s hold, then `show_mission`; only the standing puppets slide out. `Fight won` / `Run lost` stay in LimboConsole.

## Testing decisions

- `FightController` with no stage plays the same seeded fight as before.
- Motion, timing and layout are judged by playing.

## Out of scope

- The player's choices, preview ghosts — [[Hero choices]].
- Beats, tassels, skill effects, a speed or skip control.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
