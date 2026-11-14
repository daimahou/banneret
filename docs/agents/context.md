# Banneret

The vocabulary of the game: how a run is structured and what the player sees on stage.

## Run

**Run**:
The whole loop from the first mission to a win or a loss; it holds the party between missions.
_Avoid_: board, game state

## Stage

**Stage**:
The theatre frame the run is played in.
_Avoid_: board, screen, scene

**Flat**:
One vertical panel at the back of the stage, holding one column of the mission map.
_Avoid_: panel, slot

**Scenery**:
The flats at the back of the stage, taken as a whole.
_Avoid_: backdrop, flats container

**Transition**:
The stage's change between showing the mission map and showing the fight.
_Avoid_: turn, scene change

**Coach**:
The party's token on the mission map.
_Avoid_: cart, wagon, player marker

**Nameplate**:
A character's portrait, name and readouts, in the row below the stage.
_Avoid_: health bar, frame, unit frame

## Mission

**Mission map**:
The generated graph of map nodes for one mission.
_Avoid_: map, graph, level

**Map node**:
One place on the mission map, holding one event.
_Avoid_: stop, waypoint, node

**Event**:
What happens at a map node; each has a type, an icon and its own data. An encounter is one kind of event.

**Travel**:
The coach's move along one road to the next map node.
_Avoid_: move, step, hop

**Offer**:
One option an event or a level-up puts up for the player to pick.
_Avoid_: option, card, reward

**Character**:
One fighter, a hero or an enemy.
_Avoid_: unit, fighter

**Hero**:
A character the player controls; one member of the party.

**Puppet**:
A character's figure on stage.
_Avoid_: sprite, avatar, actor

**Enemy**:
One opponent the party fights in an encounter.
_Avoid_: monster, foe

**Bag**:
The content an event's offers are drawn from, e.g. skills.
_Avoid_: pool, category, registry

## Fight

**Fight**:
An encounter played out: the party against the enemies, until one side has fallen.
_Avoid_: battle, combat, board

**Tick**:
The fight's unit of time.
_Avoid_: turn, step

**Beat**:
A tick that recurs at a fixed interval across the whole fight; the clock cooldowns count in.
_Avoid_: round

**Timeline**:
The fight's queue of pending actions, in the order they resolve.
_Avoid_: queue, initiative

**Action**:
A character's chosen skill and target, pending on the timeline until its resolve tick.
_Avoid_: move, order

**Medallion**:
An action as shown on the timeline: a token hanging on the rope with its actor's portrait.
_Avoid_: token, icon, card

**Ghost**:
A faded medallion where an action would hang: one not yet chosen, or one a preview would move.
_Avoid_: shadow

**Preview**:
The fight as it will stand once a given action lands, shown on stage beside the fight: its ghost, the AP spent and each effect.

**Simulation**:
The fight played out on a copy, with no brains, until a given action lands.
_Avoid_: forecast, projection

**Stop**:
A pause in the fight while the heroes take orders.
_Avoid_: pause, freeze

**AP**:
The pips a character spends to schedule a skill, one back each beat, held up to a cap.

**Brain**:
What chooses the actions of one side: the player or chance.
_Avoid_: AI, controller

**Effect**:
One thing a skill does when it resolves, e.g. damage.
_Avoid_: outcome, result

**Stagger**:
A pushback of all the target's pending actions, a set number of ticks later on the timeline.
_Avoid_: delay, push, knockback

## Progression

**Skill**:
An action a character can use in a fight.
_Avoid_: ability, active skill, move

**Talent**:
A part of a hero's build that is always in effect.
_Avoid_: passive, passive skill, trait

**Class**:
The talent a hero starts with, which sets the direction of their build.
_Avoid_: job, archetype

**Specialization**:
The direction a class takes at its first upgrade, closing the others.
_Avoid_: subclass

**Ascension**:
A specialization's capstone, taken at the class's second upgrade.

**Build**:
A hero's skills and talents, with their ranks and perks.
_Avoid_: loadout, kit

**Rank**:
A skill's or talent's development stage: Basic, Advanced, Expert.
_Avoid_: level, tier

**Perk**:
One authored choice inside an upgrade.
_Avoid_: node, development option, sub-skill, trait

**Modifier**:
A lasting change to a stat: its skill's own, or its hero's when held by a talent.
_Avoid_: buff, bonus

**Tag**:
A designer's label a character holds in stacks, never shown to the player.
_Avoid_: flag, keyword

**Level-up**:
The party's development at one position of the shared sequence: one pick per hero.
_Avoid_: reward, level

**Draft**:
A level-up's type, talent or skill; every hero shares it.
_Avoid_: round

**Pick**:
One hero's confirmed choice at a level-up: an offer and its perk together.
_Avoid_: choice, selection
