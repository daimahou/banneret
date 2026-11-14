---
triage: ready-for-agent
id: "1.3-1.2.5"
parent: "[[Level-up offers]]"
requires:
  - "[[Talents and class]]"
started: 2026-11-14
finished:
hours:
---
Tags for designers, used to gate class content: [[Level-up offers]].

# Done when

- A `TagLibrary` resource lists the tags; every tag field in the inspector picks from it in a dropdown.
- `Character` holds tag counts, with counted grant and strip.
- Talents and skills grant their tags when acquired; perks when picked. Ranks grant nothing.
- Talents, skills and perks list requirements: a tag and a minimum count (default 1); all must be met. An unmet entry is never offered; an unmet perk is never listed; an upgrade with no eligible perk is not offered.
- The placeholder class's specialization perks grant a tag and its ascension perks require it: only the chosen specialization's ascensions are offered.
- Tags are never shown to the player.

## Testing decisions

- `LevelUp` with doubles: grants on acquisition and pick, stacked requirements, a class-exclusive talent and skill, a class-specific perk on a shared entry, ascension gating.

## Out of scope

- Gameplay tags (e.g. `frozen`), stripping content, OR / NOT requirements.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
