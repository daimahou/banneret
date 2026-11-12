---
triage: needs-triage
id: 1.3-1.1
requires: []
started: 2026-11-12
finished:
hours:
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

> [!frontier] Starting hero data
> Proposed: reuse the existing Warrior, Rogue and Mage resources, art and starting stats. All three currently have Strike available; use it as a temporary basic attack for each, removing Bash and Overpower from the Warrior's starting skills. Distinct basic attacks can follow with authored skill content.

> [!frontier] Temporary encounter sequence
> Proposed: repeat the existing Brigand encounter after each victory until the party loses. This establishes the loop without requiring encounter content or a final boss. A finite authored sequence follows later.

> [!frontier] Fallen heroes between fights
> Proposed: a fallen hero stays fallen when the remaining party advances; there is no automatic revival or recovery in this task.

> [!frontier] Continuing and restarting
> Does victory immediately start the next fight or wait for the player to continue? On defeat, should the player get a restart action or restart by relaunching the game?

## Implementation starting points

- `run/run_model.gd` currently creates only the Warrior; Rogue and Mage resources already exist.
- `run/run_controller.gd` currently starts on the map, returns to it after victory, and creates a fresh run after defeat.
- Character state already holds health, AP and cooldowns between fights. Keep that state when advancing rather than rebuilding the party.

## Validation

- Check that normal startup reaches a fight with three controllable heroes and only their basic attacks.
- Check that victory advances exactly once, preserves the party's state, and creates fresh enemies with no actions left over from the previous fight.
- Check partial-party survival and total defeat against the agreed rules.
- Play through successive fights to check hero selection, nameplates, timeline and fight transitions. Run the existing checks described in [[feedback-loop]].

## Out of scope

- Level-up offers, skill upgrades, classes and ascensions.
- New fight mechanics, enemy behaviours and reinforcement waves.
- Map routes, relics, complications and the boss.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
