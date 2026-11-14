---
triage: ready-for-agent
id: "1.3-1.2.2"
parent: "[[Level-up offers]]"
requires:
  - "[[Skill wraps SkillData]]"
started: 2026-11-14
finished: 2026-11-14
hours: 0.3
---
Tracer bullet for [[Level-up offers]]: a victory opens the level-up, each hero picks a new skill, the next fight uses it.

# Done when

- The run counts its level-ups, 1 to 37; each one's number sets its draft (skill drafts at 3, 6, 8, 11, 14, 16, 19, 22, 24, 27, 30, 32, 35, 37; talent otherwise). The count advances once per completed level-up, stops after the 37th, and resets on a new run.
- After a victory, if a level-up remains, the full-screen view opens before the next fight. Defeat still starts a fresh run.
- In a skill draft each standing hero gets up to three new-skill offers from the skill Bag, drawn once: no duplicates, not owned, a free slot (4 beside the basic attack). Fewer valid shows all of them.
- Fallen heroes are skipped. A hero with no valid offer is skipped with a warning naming hero and draft. Talent drafts skip every hero this way until talents exist. All skipped closes the level-up by itself.
- Selecting an offer makes that hero ready; the selection can still change. Switching heroes never rerolls.
- Readiness count and Continue at the bottom; Continue enabled once every hero is ready; it confirms all picks at once and starts the next fight with the new skill on the hero's bar.

## Implementation decisions

- `LevelUp`: model object the run creates for its next level-up; holds the draft, each hero's offers and selection; a hero with no offer is skipped; ready once every hero has a selection or is skipped. The run keeps only its level-up count: confirming a level-up applies every selection at once, each to its hero only, and advances the count.
- A level-up offer is its own type (new entry, or later an upgrade); the mission map's `Offer` is untouched.
- Offers are drawn from the run's seed and the level-up's number, separate from fight seeds, so the same level-up always offers the same; a save needs only the seed and the count. The seed is injectable.
- Skill Bag: Placeholder A, B, C. They do nothing.
- View: full-screen overlay scene in the level-up feature folder. Three columns: portrait, name, class and stats; five skill slots; offers. No per-hero Confirm. The talent row arrives with [[Talents and class]].
- Scale the level-up PNGs offline from 1672 × 941 to 3840 × 2160 (×2.2966); update their README and manifest. Nodes stay at 1 × 1.

## Testing decisions

- `RunModel` / `LevelUp` with an injected seed: draft per count, advance once including all-skipped, stop after the 37th, reset; offer count, distinctness, fewer than three, none; fallen and starved skips; offers stable across reads; a pick applies once to one hero.
- `RunController`: a victory opens a level-up before the next fight (extend its test).
- The view is judged by playing against the reference in [[Level-up offers]].

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
