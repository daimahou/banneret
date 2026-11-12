---
requires: []
id: 1.3-1
deadline:
started: 2026-11-12
finished:
total_hours: 0.7
parent: "[[Act 1 prototype]]"
---

# Combat and progression

Start directly in a fight, develop the party through level-up offers, then enter the next fight. This loop establishes combat and build decisions before the map is introduced.

## Scope

- Three distinct starting weapon archetypes: sword, light blade and staff.
- Skill acquisition, skill upgrades, class specialization and ascension are included in this milestone.
- The fight sequence runs directly from fight to level-up to fight. Map routes, relics, complication events and the boss belong to the following milestones.
- Each hero levels up after each victory, as specified by the gate. The older once-per-mission rule in [[Skill design]] does not apply to this milestone.

## Done when

- The game starts in a fight with three heroes, each with their weapon's basic attack.
- The player reads pending actions on the timeline and schedules skills in response. The selected fight mechanics work for heroes and enemies.
- After each victory, each hero gains one level and chooses from offers to learn a skill, upgrade an existing skill, or develop a class specialization and its ascension.
- Once all heroes have made their choices, the next fight starts with their updated builds. Health and relevant limited resources carry between fights; losing the party ends the run.
- A defined sequence of encounters lets the player repeat this loop without developer intervention. Encounters support up to three enemies at once and reinforcements where required.
- The initial skills, classes, enemies and supporting mechanics come from the selections in [[Act 1 prototype]].

> [!frontier] Initial content selection
> Which starting skills, class paths, ascensions, upgrades and enemies are included for the three archetypes? The gate currently selects Warrior and Strike; the rest of this playable set still needs authoring. Supporting mechanics follow that selection.

> [!frontier] Level-up offers
> Set the skill-slot limit, number of offers, how new skills compete with upgrades and class picks, and what happens when a category has no eligible offer. Define when class and ascension picks become eligible and which talents the player chooses inside an offered bag.

> [!frontier] Between-fight state
> Specify what carries, resets or expires for every selected resource and effect, and what happens to a fallen hero when the rest of the party wins. Include whether that hero receives the level-up.

> [!frontier] Fight sequence and stopping point
> Which encounters make up the sequence, and what happens after its final victory?

## Playtest

- Can the player understand pending actions and the consequences of their skill choices?
- Do level-up offers lead to different builds and change how subsequent fights are played?
- Does carrying resources between fights create meaningful decisions?

## Tickets

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
