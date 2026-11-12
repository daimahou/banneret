---
requires:
  - "[[Combat and progression]]"
id: "1.3-2"
deadline:
started:
finished:
parent: "[[Act 1 prototype]]"
---

# Map and events

Start at the first map node and choose a route through fights, relic events and complication events. The map connects the existing combat and progression loop with decisions about rewards and future pressure.

## Done when

- The game starts at the first node of an act map. The player can read the paths ahead and choose among connected nodes.
- Fight nodes launch encounters from the gate's selection. After victory and each hero's level-up choice, the player returns to the map with the party's updated state.
- Relic events offer a choice of relics. The chosen relic's interactions apply for the rest of the run.
- Complication events apply twists that affect upcoming challenges. Their consequences are visible before the player commits, and accumulated twists remain inspectable.
- The map communicates the fight information available to the player, including changes caused by accepted twists.
- Party builds, health, relevant limited resources, relics and twists persist as the player moves between nodes.
- The selected relics and twists come from [[Act 1 prototype]]. Boss-specific effects are completed in [[Boss and complete act]].

> [!frontier] Level-ups from map nodes
> Proposed: each completed node grants one level-up, including relic and complication events. All three heroes share a schedule that spreads passive and active development through a mix of 2:1 and 1:1 stretches. Aim for two to three fights per two active picks; see [[Skill design]].

> [!frontier] Act map structure
> How many nodes and branches make up the act, and what ends the route before the boss is introduced?

> [!frontier] Fight information on the map
> Which details of an encounter are revealed before the player chooses its node?

> [!frontier] Complication choice
> Does visiting a complication node accept a twist shown on the map, or offer a choice of twists on arrival? The gate currently describes both.

## Playtest

- Do party state, relics and accumulated twists change which route is attractive?
- Can players explain an event's consequences before committing and identify the twists affecting their run afterwards?

## Tickets

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
