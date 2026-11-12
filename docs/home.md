# Banneret

A rogue-like about building an RPG party through a gauntlet of challenges, adapting to randomized skill offers to make a build that can beat the run.
> [!NOTE] How to launch Claude
> SHELL=/bin/bash claude

## Pitch

- Defeat a challenge, level up, decide towards the build, fight the next challenge — until the run is won or lost.

## Overview

- Genre: j-RPG turn-based combat with Slay the spire progression

## Features

- Platform: PC, Steam deck


## Story

- The game is a play staged by a theatre troupe. The theatre is its presentation, never part of the story.
- The story: a banneret and a small band defy the lord.
- The **coach** is the band. It grows as the banneret rallies people along the road.
- Rallied people serve in camp; they don't fight.

## Gameplay

The player controls a **party of three** - the gameplay loop is divided into several sections:

| Section   |                                                      |
| --------- | ---------------------------------------------------- |
| Run       | Entire loop from start to finish                     |
| Act       | Several missions concluded with a boss encounter     |
| Mission   | Several events concluded with an encounter           |
| Event     | Offers choice of benefits that compound into a build |
| Encounter | A fight designed to test the build                   |
| Camp      | Between missions: gold spent on the band's roles     |

### Team selection

Player chooses 3 heroes to embark on the quest.
- Each hero is a certain preset that seeds the build possibilities

### Mission map

- A mission is the band on its way somewhere; its encounter is the lord's men catching up. It is shown from the start.
- A map node is a place. Its offers are **deeds**, each with a reward and a price in infamy — e.g. raid the jail: the prisoners join the band, infamy rises.

> [!frontier] What a map node's icon tells: going road A over road B needs clear, measurable pros and cons.

### Camp

Between missions the band makes camp. Each rallied role sells for gold:

| Role        | Sells                                              |
| ----------- | -------------------------------------------------- |
| Smith       | Weapon levels                                      |
| Armourer    | Armour levels                                      |
| Drillmaster | Skills and skill upgrades the band's people teach  |
| Surgeon     | Heals                                              |

- Weapon and armour levels are equipment tiers, as in Darkest Dungeon.
- Skill offers are random because each rallied person brings their own teachings: who the band met decides what it is offered.

> [!frontier] More roles — e.g. a Scout selling what the next encounter holds.

### Encounter resolution

Each encounter is designed to counter specific builds, so the player will have to read the information available to deduce what type of encounter they may expect over the course of the run - which then feeds information that factors into the build decisions.

### Acts

The game is divided into 3 different acts, which culminate into a boss fight. At the start of a run, 3 bosses are selected from the pool of existing bosses, each with their particularities.

### Boss buff events

During the progression of each act, the player will be faced with a particular type of events - a boss buff event. Each act boss comes with several buffs that stacks up and modify the final encounter, during those boss buff events, the player may chose one of them to dispel - this decision will affect the final challenge and may be considered part of the build decisions.

### Final encounter

After defeating the boss of each acts, the player faces the lord: the final challenge that is the ultimate test for their builds. The final challenge is modified based on the act bosses - so the game stays fresh each run.