---
triage: ready-for-agent
id: 1.3-1.2.1
parent: "[[Level-up offers]]"
requires: []
started: 2026-11-14
finished: 2026-11-14
hours: 0.4
---
Prefactor for [[Level-up offers]]: a hero's skills become runtime objects of their own. No behaviour change.

# Done when

- `Skill` wraps `SkillData` as `Character` wraps `CharacterData`. `Character` holds its own skills, built from its `CharacterData`.
- `Action` holds the actor's live `Skill`.
- Each `Skill` holds its own cooldown. The per-character cooldown dictionary is gone.
- Skill bar, brains, rules, previews and debug commands use `Skill`.
- The existing suite passes unchanged in what it asserts.

## Implementation decisions

- `Skill` has an id kept by `duplicate()`. `Character.duplicate()` copies its skills; the fight model's copy remaps each action's skill to the copied actor's skill of the same id, as it remaps actors. Cooldown changes find the skill the same way.
- `SkillData` stays a shared preset and is never mutated.

## Testing decisions

- Existing fight, simulation, preview and run tests are the safety net. Add one: a simulation's cooldowns never reach the fight it copies.

## Out of scope

- Ranks, perks and anything level-up: later siblings.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
