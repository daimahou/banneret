---
requires: []
id: 1.3-1
deadline:
started: 2026-11-12
finished:
total_hours: 3.3
parent: "[[Act 1 prototype]]"
---

# Combat and progression

Start directly in a fight, develop the party through level-up offers, then enter the next fight. This loop establishes combat and build decisions before the map is introduced.

## Scope

- Three distinct starting weapon archetypes: sword, light blade and staff.
- Skill acquisition, skill upgrades, class specialization and ascension are included in this milestone.
- The fight sequence runs directly from fight to level-up to fight. Map routes, relics, complication events and the boss belong to the following milestones.
- In this combat-only milestone, victory triggers one pick per hero. All three heroes share the draft schedule described in [[Skill design]], spreading talent and skill development through a mix of 2:1 and 1:1 stretches.

## Done when

- The game starts in a fight with three heroes, each with their weapon's basic attack.
- The player reads pending actions on the timeline and schedules skills in response. The selected fight mechanics work for heroes and enemies.
- After each victory, each hero chooses one of three offers in the current draft: two new talents or skills and one upgrade. Class specialization and ascension are upgrades in the talent draft. See [[Level-up offers]].
- Once all heroes have made their choices, the next fight starts with their updated builds. Health and relevant limited resources carry between fights; losing the party ends the run.
- A defined sequence of encounters lets the player repeat this loop without developer intervention. Encounters support up to three enemies at once and reinforcements where required.
- The initial skills, classes, enemies and supporting mechanics come from the selections in [[Act 1 prototype]].

> [!frontier] Initial content selection
> Which starting skills, class paths, ascensions, upgrades and enemies are included for the three archetypes? The gate currently selects Warrior and Strike; the rest of this playable set still needs authoring. Supporting mechanics follow that selection.

[[Level-up offers]] specifies the schedule, sampling and fallback rules using placeholders. Author production perks and offer weights system by system in [[Progression content]].

> [!frontier] Map progression pacing
> Proposed: move to one level-up per completed map node when [[Map and events]] is introduced, with two to three fights per two skill picks. Victory is the temporary trigger here.

- Health, AP and cooldowns carry between fights as established in [[Fight sequence and starting party]]. Fallen heroes remain fallen and skip level-up picks.

> [!frontier] New resources and effects between fights
> When adding content, specify what carries, resets or expires for each newly introduced resource or effect.

> [!frontier] Fight sequence and stopping point
> Which encounters make up the sequence, and what happens after its final victory?

## Playtest

- Can the player understand pending actions and the consequences of their skill choices?
- Do level-up offers lead to different builds and change how subsequent fights are played?
- Does carrying resources between fights create meaningful decisions?

## Tickets

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
