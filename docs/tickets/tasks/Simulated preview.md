---
triage: needs-info
id: 1.2-1.8
requires:
  - "[[AP pips]]"
started: 2026-10-25
finished:
hours:
parent: "[[Warrior kit]]"
---
# Done when

- Arming or hovering a skill previews it: the fight played out, no brains, until the skill lands; what the simulation does before it shows apart from what the skill itself does.
- Hovering a medallion previews the fight played out until that action lands.

## Settled in the Bash grill

- Shown skill: the hovered one, else the armed one. Only the armed skill has a target: the hovered character if the skill reaches them, else the aimed one. A hovered character it cannot reach = no target. No target: ghost and AP only.
- The real play-out with its cumulated consequences: every resolve and beat, on a copy of the state, through the same code as `FightController`. It returns a simulation delta and a skill delta.
- Health: the simulation's damage hatched, the skill's pulsing; the label shows the new number, coloured by direction, pulsing softly. AP spent, AP refilled and cooldowns show too.
- Every action that would be cancelled is crossed out, the skill's own ghost included. The two-stroke cross comes back from before `71aea8f`.
- No simulation tests: it runs the code the fight tests already cover.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
