# Banneret

The vocabulary of the game: how a run is structured and what the player sees on stage.

## Stage

**Stage**:
The theatre frame the run is played in.
_Avoid_: board, screen, scene

**Flat**:
One vertical panel at the back of the stage, holding one column of the mission map.
_Avoid_: panel, slot

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

**Bag**:
The content an event's offers are drawn from, e.g. skills.
_Avoid_: pool, category, registry
