---
triage: ready-for-agent
id: "1.3-1.2.3"
parent: "[[Level-up offers]]"
requires:
  - "[[Skill acquisition]]"
started:
finished:
hours:
---
Upgrade offers for skills, with ranks and perks: [[Level-up offers]].

# Done when

- `SkillData` has exactly 2 ranks (Advanced, Expert) after its Basic preset; a rank holds effects, skill modifiers and perks; a perk holds effects and skill modifiers.
- Skill modifiers are flat and target delay, cooldown or AP cost. Rank and perk effects add to what the skill does on resolve; they never edit an effect they did not add.
- A skill draft draws two new skills and one upgrade, distinct and uniform; a category that cannot fill its places fills from the other.
- An owned skill (basic attack included) is upgradable if below Expert and its next rank has a perk. The offer names the skill, never a perk.
- Selecting an upgrade keeps its card with Back and lists its perks in that column (in authored order, up to four, never covering Confirm). Back and switching keep the offers. More than four perks is reported as an error, never sampled down.
- Rank titles Basic / Advanced / Expert with the resulting rank's value. Perk icons on offer cards and beside owned skills; hovering an owned skill shows its current effect and chosen perks.
- The upgraded skill resolves differently, previews agree, its cooldown is kept, and an action already queued uses the upgrade.

## Implementation decisions

- `Skill` holds its rank and chosen perks and exposes the resulting stats and effects.
- Placeholder A, B, C each gain 2 ranks of Perk A, B, C as sub-resources in their own file; still no effects or modifiers.

## Testing decisions

- `LevelUp` with doubles: upgrade eligibility, category fallback, perk order, the more-than-four error, max rank.
- `Simulation` / `FightModel` with doubles: modifiers and added effects change resolution and the preview agrees; cooldown kept; a queued action picks up the upgrade.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
