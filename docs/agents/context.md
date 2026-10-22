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

**Transition**:
The stage's change between showing the mission map and showing the fight.
_Avoid_: turn, scene change

**Coach**:
The party's token on the mission map.
_Avoid_: cart, wagon, player marker

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

**Party**:
The player's three heroes.
_Avoid_: team, squad

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
