---
triage: ready-for-agent
id: 1.1-3.5
requires:
  - "[[Fight on stage]]"
started: 2026-10-23
finished:
hours: 1
parent: "[[Encounters]]"
---
# Done when

- The player chooses each hero's skill and target, with buttons, keys and clicks, in place of the heroes' random brain.
- The player can stop the fight, pass, and reschedule a busy hero.
- The rope shows a ghost where a skill would resolve; a medallion and its puppet highlight each other.

## Problem

The player has no say in the fight.

## Solution

A `PlayerBrain` replaces the heroes' `RandomBrain` on stage. It turns input into the hero, skill and target picked, and asks `FightRules` what is legal. The fight stops for a free hero, or when the player asks; the player gives orders, then passes or lets the fight run on. Ported from prototype C's `PlayerBrain` and `FightControls`.

## Implementation decisions

- **Stop** — the controller asks the hero brain when nothing is due this tick, or when it asked for a stop: `Brain.is_stop_requested()`, false by default. A requested stop lands after the blow playing, even between actions on the same tick.
- **Stop ends** — a stop for a free hero ends once no hero is free. A requested stop lasts until Pass.
- **Pass** — the brain returns null: the next action resolves.
- **Reschedule** — `get_timeline_delta` drops the actor's pending action, if any, in the same delta. The new action resolves `delay` on from now, chosen last. No cancelling without a replacement.
- **Hero brain** — `FightController` takes the hero brain, a `PlayerBrain` by default; `FightRunner` passes a `RandomBrain` on the fight's seed. `fight toggle_player_brain` toggles random heroes: debug keeps the state, and swaps the hero brain now and on each `RunController.fight_started`. A waiting player brain hands on the random brain's choice, or passes.
- **Selection** — when a stop starts, the first free hero is selected, else the first hero. After a confirm, the next free hero. Tab / Shift+Tab cycle the heroes; a click selects one. Nothing is pickable while the fight runs.
- **Arm** — 1–N or a button arms a skill; another skill replaces it. Esc or right click disarms.
- **Aim** — arming aims the first valid target, left to right on screen. With a skill armed, 1–N aims a target; the same number again confirms. Arrows cycle the aim. An aim from arming or arrows never counts as the first digit press. Enter confirms the aimed target; a click on a valid target confirms it.
- **Controls** — one fixed row at the bottom of the heroes' half, below the health bars: the selected hero's skills, a gap, the Stop/Pass button. Plain themed buttons, no key labels.
  - The button reads Stop while the fight runs, Pass while stopped. Space stops: the button shows held down until the stop lands. P passes.
  - The skill of the hero's pending action is outlined; the armed skill shows pressed.
  - Skill tooltip, card-like: name, `Delay: X`, a line per effect from `Effect.get_description()`.
- **Puppets**:
  - A free hero hops during a stop; the selected hero stands raised and still; every other puppet sways.
  - Hover brightens a pickable puppet. Valid targets tinted red, the aimed one a stronger red. A digit press bobs the aimed puppet down.
- **Rope**:
  - Ghost — the armed or hovered skill hangs faded where it would resolve.
  - Red X — on the pending action a reschedule would drop, while a skill is armed.
  - Selecting or hovering a puppet highlights its medallion; hovering a medallion brightens its puppet, always.
- Looks are placeholders, tuned by playing.

## Testing decisions

- `FightRules`: a reschedule drops the old action; the new one resolves `delay` on from now.
- `FightController`: a hero brain that requests a stop is asked with an action due.
- No tests for `PlayerBrain`: it maps input. Input and looks are judged by playing.

## Out of scope

- Who an enemy aims at.
- Art for buttons, highlights and marks.
- More skills, reaches, cooldowns.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
