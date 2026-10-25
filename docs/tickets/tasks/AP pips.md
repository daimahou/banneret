---
triage: ready-for-agent
id: 1.2-1.3
requires:
  - "[[Beat and cooldowns]]"
started:
finished:
hours: 1.8
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
- No AP cost on `SkillData`: every skill costs 1. The card's pip stays inert art.
- `FightRules.AP_PER_BEAT` (1) comes back on the beat delta, with the cooldowns, on both sides, capped at `max_ap`.
- At 0 AP `get_usable_skills` is empty: the cards take the unusable grey ink, nothing more.
- Choosing spends 1 AP and removes nothing. A character can have several pending actions, so a removal names its action, not its actor. The dropped action and its crossed-out medallion go.
- The fight stops for any standing hero holding AP, pending actions or not. Pass lets one step through, as now.
- During a stop the selected hero stays selected until their AP is spent or none of their skills is usable; then the next hero with AP. The stop lasts until a Pass or until no standing hero holds AP.
- `RandomBrain` chooses for any character with AP and a usable skill, pending or not: an enemy spends all its AP.
- A cancelled action (actor or target fallen) refunds nothing.
- Nameplate: five pip slots along the frame from the existing `ApPip`, at the frame's hook spacing. A character shows `max_ap` empty rings (`art/ui/ap_pip.png`) and a filled pip on each one held: `art/ui/ap_pip_full.png`, a placeholder the human replaces. Enemies the same.

## Testing decisions

- `tests/fight/fight_rules_test.gd`: choosing spends 1 AP; a beat gives 1 back, capped; 0 AP leaves no usable skill; one actor's two actions both pend and resolve at their own ticks; a fallen actor loses all its pending actions.
- Brains: an enemy with 2 AP schedules twice; the player's hero stays selected while holding AP, then the next hero with AP.
- Pips are judged by playing.

## Out of scope

- Energy, colored AP.
- Enemies past AP 1.
- AP cost as data, skills that change AP, regen other than 1 per beat.
- A preview of the pip a skill would spend.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
