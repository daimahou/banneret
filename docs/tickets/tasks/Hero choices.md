---
triage: needs-info
id: 1.1-3.5
requires:
  - "[[Fight on stage]]"
started:
finished:
parent: "[[Encounters]]"
---
# Done when

- The player chooses each hero's skill and target, with buttons and keys, in place of the heroes' random brain.
- The player can pass, and can reschedule a busy hero.
- The rope shows where a skill would resolve before it is chosen; hovering a medallion shows who acts.

## Problem

The player has no say in the fight.

## Solution

A `PlayerBrain` replaces the heroes' `RandomBrain` on stage; it only turns input into the hero, skill and target picked, and asks `FightRules` what is legal. `FightRunner` keeps random brains. Ported from prototype C's `PlayerBrain` and `FightControls`.

## Decisions so far

- **Flow** — hero → skill (armed) → valid targets tinted → target → confirmed. Another skill can be armed while one is armed. Esc or right click disarms the skill.
- **Hero** — when the fight waits on the heroes, the first free hero is selected. Tab cycles the heroes. After a confirm, the next free hero is selected.
- **Reschedule** — a busy hero can be selected and given a new action; its pending action is dropped, its progress lost.
- **Skills** — plain themed buttons in the bottom half, name only; a tooltip carries the rest (delay, effects). Art comes once we know what the player reads.
- **Keys** — 1–N arms a skill. Once one is armed, 1–N picks among the valid targets, left to right on screen; the same number again, or Enter, confirms. Targets can also be clicked on their puppet.
- **Pass** — a button and `P`: the next action resolves even with heroes free; then they are asked again. Not Space: too easy to hit by accident.
- **Puppets** — a free hero hops instead of swaying; the selected hero stops hopping and stands raised. Valid targets and hovered-medallion actors are tinted.
- **Preview ghost** — an armed or hovered skill hangs a faded medallion where it would resolve on the rope.
- **Medallion hover** — tints its actor's puppet, so two brigands can be told apart.
- **Tests** — none for `PlayerBrain`, it only maps input. Rescheduling is a rule change: `FightRules` tests cover it.

## Open for the grill

- **Reschedule while all heroes are busy:** the fight only waits when a hero is free. Can the player interrupt a running fight to reschedule, or only during a wait?
- **Reschedule rule:** does the new action's resolve tick start from now, and does dropping the old one count as a choice for the shared-tick order?

## Out of scope

- Who an enemy aims at.
- Art for buttons, tint and marks.
- More skills, reaches, cooldowns.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
