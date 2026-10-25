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
One option an event puts up for the player to pick.
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
