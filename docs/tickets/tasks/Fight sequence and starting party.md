---
triage: ready-for-agent
id: 1.3-1.1
requires: []
started: 2026-11-12
finished: 2026-11-12
hours: 0.7
parent: "[[Combat and progression]]"
---

# Fight sequence and starting party

The first playable step of [[Combat and progression]]: start with three heroes and play successive fights with the same party.

## Done when

- Starting the game enters a fight directly, with the sword, light-blade and staff heroes on stage. No map navigation or debug command is required.
- Each hero starts with only their basic attack. The player can select and command all three heroes through the existing fight controls.
- Winning advances to the next fight with the same party. Enemies are created fresh for each encounter.
- Hero health, AP and remaining cooldowns carry between fights. Pending actions from the previous fight do not carry over.
- Losing the party ends the run in defeat rather than advancing to another encounter.

## Decisions

- **Starting heroes:** the existing Warrior, Rogue and Mage resources, art and stats. All three use Strike as a temporary basic attack; Bash and Overpower come off `warrior.tres` and stay in `skill/` for later offers.
- **Encounter:** three Brigands, repeated after each victory until the party falls.
- **Fallen heroes:** stay at 0 health and in the party; no revival. A falling hero still sinks off stage. In the next fight their puppet is not added and their nameplate stays cleared; the living heroes keep their three-hero stand positions, leaving the fallen hero's place empty.
- **Victory:** the next fight starts on its own after `HOLD_DURATION`, with no continue action.
- **Defeat:** a fresh run starts at once, straight into a fight.
- **Stage at startup:** opens on the fight scenery; heroes and enemies enter from offstage. No mission map, no coach.
- **Stage between fights:** heroes stay in place, the timeline clears, the new enemies slide in from offstage right. No flip, no coach.
- **Mission code:** `mission/` stays, unreachable from play. The `map_seed` and `fight` console commands are removed: fights chain without end, so no mission can start. `--fight=<seed>` seeds the first fight.

## Implementation starting points

- `run/run_model.gd` currently creates only the Warrior; Rogue and Mage resources already exist.
- `run/run_controller.gd` currently starts on the map, returns to it after victory, and creates a fresh run after defeat.
- Character state already holds health, AP and cooldowns between fights. Keep that state when advancing rather than rebuilding the party.
- `Stage.show_encounter` is the only way into a fight: it starts from the mission map, slides the coach off and flips the scenery. Its `_add_puppets` puts every hero on stage, fallen ones included.

## Validation

- Check that normal startup reaches a fight with three controllable heroes and only their basic attacks.
- Check that each fight has three Brigands, and that victory advances exactly once, preserves the party's state, and creates fresh enemies with no actions left over from the previous fight.
- Check that a hero fallen in one fight is absent from the next, with their place left empty, and that total defeat starts a fresh run in a new fight.
- Play through successive fights to check hero selection, nameplates, timeline and fight transitions. Run the existing checks described in [[feedback-loop]].

## Out of scope

- Level-up offers, skill upgrades, classes and ascensions.
- New fight mechanics, enemy behaviours and reinforcement waves.
- Map routes, relics, complications and the boss.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
