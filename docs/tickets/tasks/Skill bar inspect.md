---
triage: ready-for-agent
id: 1.2-1.2.3
requires:
  - "[[Skill cards]]"
started: 2026-10-25
finished:
hours:
parent: "[[Beat and cooldowns]]"
---
# Done when

- Hovering a medallion highlights its actor and shows the actor's skills, the medallion's skill drawn armed — always, even while aiming.
- Hovering a character shows their skills, enemies included — except while a skill is armed.
- When the hover ends, the bar reverts to the selected hero.
- While the bar shows anyone but the selected hero, its clicks and digit keys are rejected.

## Implementation decisions

- Built on `PlayerBrain.hovered_action` / `hovered_character` and the stage's hover ink.
- An inspected enemy shows its cooldowns like a hero: the bar reads the character, not the player.

## Testing decisions

- Rejected input while inspecting: a `PlayerBrain` test if it fits the existing ones; the rest judged by playing.

## Out of scope

- Hovering a ghost.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
