---
id: "1.3"
requires:
  - "[[First loop]]"
deadline:
started: 2026-11-07
finished:
total_hours: 0.8
parent: "[[Vertical slice]]"
---
# Prototype 1 - Core

## Overview

A *run* consists of playing the game from the beginning to defeating the final boss - or being defeated. It is divided into several *acts*, each ending in a boss fight.

The player controls 3 characters - each with several skills which get developed throughout the run.

An *act* is represented by a node map. The player reads the map and decides which path to take to reach the boss. Generally speaking, there are two types of *map node*: a *fight node* - triggering a fight - and an *event node* offering several options to resolve it.

At each level-up, each hero learns a skill or upgrades an existing one. All three heroes share a draft schedule that spreads passive and active development through a mix of two passive picks per active pick and one of each; see [[Skill design]].

> [!frontier] Level-up trigger and map pacing
> Proposed: each completed map node grants one level-up, aiming for two to three fights per two active-skill picks. The combat-only milestone uses victory as its temporary trigger.

Health and relevant limited resources carry between fights.

The game can be summarized as a series of choices the player makes - balancing resources in an effort to defeat the final challenge without running out.

### Map decisions

The *fight node* has different sub-types which can be revealed on the map, giving away some information to the player such as its level or type of enemies one can expect.

The *event node* may take multiple forms and vary in the offers they give - an *relic event* offers the player a choice of relic, while a *complication event* offers a choice of debuff which lasts the rest of the game.

Making a decision on the map is about reading the path ahead and judging which path may be the most favorable based on the current state of the run.

### Combat decisions

A fight takes place on a timeline. Each character schedules skills that resolve at different times. The player reads the timeline and plan his moves in response to whats already on it.

### Build decisions

Passive and active skills develop through separate drafts, each offering two new skills and one upgrade. The run offers the skill to develop; the player chooses its expression from the eligible options. Class upgrades belong to the passive draft and shape subsequent offers. The player adapts each hero’s development to the available offers and the needs of the party. See [[Skill design]].

## The loop

1. Pick the next node on the map.
2. At the difficulty event, accept its twist; at the relic event, pick a relic; at a fight, fight.
3. When a level-up is granted, each hero takes one pick in the shared passive and active draft schedule.
4. Repeat over several nodes, carrying the run's accumulated twists, until the boss.

## Heroes

- Three basic weapon archetypes, starting with only their basic attack; classes and ascendancies emerge through level-up picks.
- Each hero develops both active skills and passive skills. The occupied class slot is upgraded through passive offers: first a specialization, then an ascension.
- Class-specific upgrade options reflect the class held when the skill is upgraded; earlier choices are not retroactively changed.

### Classes

A class gives the hero a passive effect, unlocks exclusive passives and biases the shared offer pool towards its identity while allowing unconventional builds. Its upgrade options can also give shared skills a class-specific expression. Ascension is a capstone that alters a mechanic towards its fantasy.

```base
filters:
  and:
    - gate == this.asLink()
    - file.folder == "classes"
views:
  - type: table
    name: View
    sort:
      - property: file.name
        direction: ASC

```

### Skills

Active skills define the actions a character uses in a fight; their upgrades develop those actions into different expressions of themselves. Passive skills develop through Basic, Advanced and Expert, with additional node choices at Advanced and Expert. Both use their own level-up drafts.

```base
filters:
  and:
    - gate == this.asLink()
    - file.folder == "skills"
views:
  - type: table
    name: View

```

## Fights

A fight opposes the 3 hero characters and up to 3 enemies at a time. A queue may list reinforcement - additional enemies who joins the fight as the player eliminates them.

Enemies create different tactical problems through their skills and behaviour. Their pending actions appear on the timeline, allowing the player to plan a response.

```base
filters:
  and:
    - gate == this.asLink()
    - file.folder == "enemies"
views:
  - type: table
    name: View
    groupBy:
      property: type
      direction: ASC
    order:
      - file.name
      - summary
      - status
    columnSize:
      file.name: 181
      note.summary: 426

```

### Mechanics

```base
filters:
  and:
    - gate == this.asLink()
    - file.folder == "mechanics"
views:
  - type: table
    name: View
    groupBy:
      property: type
      direction: ASC
    order:
      - file.name
      - summary
      - status
    columnSize:
      file.name: 181
      note.summary: 426

```

## Map

### Fight nodes

A fight node leads to an encounter: a group of enemies, potentially supported by reinforcements. Its map information helps the player judge the challenge before choosing a route.

```base
filters:
  and:
    - gate == this.asLink()
    - file.folder == "encounters"
views:
  - type: table
    name: View
    groupBy:
      property: type
      direction: ASC
    order:
      - file.name
      - summary
      - status
    columnSize:
      file.name: 181
      note.summary: 426

```

### Event nodes

#### Relics

Relics add interactions that last for the run and can support several builds. At a relic event, the player chooses an offer based on its value to the current party.

```base
filters:
  and:
    - gate == this.asLink()
    - file.folder == "relics"
views:
  - type: table
    name: View
    groupBy:
      property: type
      direction: ASC
    order:
      - file.name
      - summary
      - status
    columnSize:
      file.name: 181
      note.summary: 426


```

#### Twists

Twists add pressure to the run through stronger upcoming fights, lasting buffs to an encounter type, or a harder boss. Their consequences inform both the player’s route and how they develop the party.

```base
filters:
  and:
    - gate == this.asLink()
    - file.folder == "twists"
views:
  - type: table
    name: View
    groupBy:
      property: type
      direction: ASC
    order:
      - file.name
      - summary
      - status
    columnSize:
      file.name: 181
      note.summary: 426

```


## Done when

- A player can clear or lose Act 1 without developer intervention.
- Playtesting shows at least two substantially different builds reaching the boss.

## Playtest

- Can players explain consequences before committing, and identify the run's accumulated twists afterwards?
- Do rewards change value with party state and accumulated twists?
- Does accepting later pressure create room to develop now?
- Are failures understandable? Does a successful build deliver a satisfying payoff?

## Milestones

![[Children.base#Open milestones]]

![[Children.base#Closed milestones]]
