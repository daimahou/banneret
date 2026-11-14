---
triage: ready-for-agent
id: "1.3-1.2.4"
parent: "[[Level-up offers]]"
requires:
  - "[[Skill upgrades]]"
started: 2026-11-14
finished:
hours:
---
Talents, talent drafts and the class as a talent: [[Level-up offers]].

# Done when

- `Talent` wraps `TalentData`: hero modifiers and 2 ranks, each of hero modifiers and perks; a talent perk holds hero modifiers. Talents own no effects.
- Hero modifiers are flat and target max health or max AP (capped at `MAX_AP`). Gaining max raises current by the same amount; losing max leaves current unchanged unless above the new max, then clamped. A fallen hero stays at 0.
- Talent drafts offer two new talents and one upgrade under the same rules as skills. 7 talent slots beside the class slot.
- The class is a talent in its dedicated slot, named by `CharacterData`: its rank-2 perks are specializations, its rank-3 perks ascensions. Taking rank 2 closes the other specializations.
- The view shows the eight-slot talent row, talent offers and perks, and hover tooltips like skills.
- Max health and AP shown on nameplates and in previews follow the talents.

## Implementation decisions

- Talent Bag: Placeholder A, B, C, with ranks and perks as sub-resources. One placeholder class shared by the three heroes. They do nothing.
- Ascensions are not gated yet: [[Tags and class gating]].

## Testing decisions

- `LevelUp` with doubles: talent drafts, slot limit, class upgrades, earlier picks unchanged by a later specialization.
- `Character` / `FightModel` with doubles: the max-resource rule for health and AP, the AP cap.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
