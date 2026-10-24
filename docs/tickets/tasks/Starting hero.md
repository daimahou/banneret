---
triage: ready-for-agent
id: 1.2-1.1
requires:
started:
finished:
hours:
parent: "[[Warrior kit]]"
---
# Done when

- A run starts with one hero, the warrior; the party can hold any number of heroes.

## Problem

The party is fixed at three heroes, and the slice grows it one hero at a time.

## Solution

`RunModel` builds the party from a starting hero instead of `PARTY_HERO_IDS`. Everything downstream already reads the party's size: `PuppetLayout`, the health bars, `PlayerBrain`'s hero cycling.

## Implementation decisions

- The warrior is the base class: `knight` is renamed `warrior` — id, `.tres` and name. Its puppet and portrait stay.

## Testing decisions

- `RunController`: a new run holds only the starting hero, at full health.
- One hero on stage, with Tab cycling and selection, is judged by playing.

## Out of scope

- Adding a hero during a run.
- The warrior's skills — [[Warrior kit]].

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
