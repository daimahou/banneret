---
triage: ready-for-agent
id: 1.2-1.1
requires:
started:
finished:
hours: 0.2
parent: "[[Warrior kit]]"
---
# Done when

- A run starts with one hero, the warrior; the party can hold any number of heroes.

## Problem

The party is fixed at three heroes, and the slice grows it one hero at a time.

## Solution

`RunModel.PARTY_HERO_IDS` holds only `warrior`. Everything downstream already reads the party's size: `PuppetLayout`, the health bars, `PlayerBrain`'s hero cycling, `FightRunner`.

## Implementation decisions

- The warrior is the base class: `knight` is renamed `warrior` — id, `.tres`, name and `art/puppet/knight.png`. Its puppet art, portrait crop, Strike and 30 health stay.
- `rogue` and `mage` stay in `hero/` and the registry, unused.

## Testing decisions

- The existing `RunController` test covers it as written: a new run holds exactly the listed heroes, at full health.
- One hero on stage, with Tab cycling and selection, is judged by playing.

## Out of scope

- Adding a hero during a run.
- The warrior's skills — [[Warrior kit]].

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
