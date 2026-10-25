---
triage: ready-for-agent
id: 1.2-1.3
requires:
  - "[[Beat and cooldowns]]"
started: 2026-10-25
finished: 2026-10-25
hours: 1.4
parent: "[[Warrior kit]]"
---
# Done when

- A skill costs 1 AP; AP regenerates one pip per beat and carries over up to a cap — see [[AP economy]].
- A hero schedules as many skills as his AP allows; each resolves at its own delay.
- Every character's AP shows on its nameplate.
- Reschedule is gone: a stop no longer replaces a pending action, the player spends AP instead.

## Implementation decisions

- `CharacterData.max_ap`: 1 to 5, default 1; `warrior.tres` holds 2.
- `Character.ap` starts at `max_ap` and carries from one fight to the next, like cooldowns.
- `SkillData.ap_cost`, default 1; every warrior skill costs 1. The card's pip stays inert art.
- `FightRules.AP_PER_BEAT` (1) comes back on the beat delta, with the cooldowns, on both sides, capped at `max_ap`.
- `get_usable_skills` leaves out a skill costing more AP than held: its card takes the unusable grey ink, nothing more.
- Choosing spends the skill's cost and removes nothing. A character can have several pending actions, so a removal names its action, not its actor. The dropped action and its crossed-out medallion go.
- The fight stops for any free hero, pending actions or not: standing, holding AP and a usable skill. Pass lets one step through, as now.
- During a stop the selected hero stays selected while free; then the first free hero. The stop lasts until a Pass or until no hero is free.
- `RandomBrain` chooses for any character with AP and a usable skill, pending or not: an enemy spends all its AP.
- A cancelled action (actor or target fallen) refunds nothing.
- Nameplate: five pip slots along the frame from the existing `ApPip`, at the frame's hook spacing. A character shows `max_ap` empty rings (`art/ui/ap_pip.png`) and a filled pip on each one held: `art/ui/ap_pip_full.png`, a placeholder the human replaces. Enemies the same.

## Testing decisions

- `tests/fight/fight_rules_test.gd`: choosing spends the skill's cost; a beat gives 1 back, capped; a skill costing more than held is not usable; one actor's two actions both pend and resolve at their own ticks; a fallen actor loses all its pending actions.
- Brains: an enemy with 2 AP schedules twice; the player's hero stays selected while holding AP, then the next hero with AP.
- Pips are judged by playing.

## Out of scope

- Energy, colored AP.
- Enemies past AP 1.
- Skills that change AP, regen other than 1 per beat.
- A preview of the pip a skill would spend.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
