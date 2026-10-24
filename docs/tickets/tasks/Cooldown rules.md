---
triage: ready-for-agent
id: 1.2-1.2.1
requires:
started: 2026-10-24
finished: 2026-10-24
hours: 0.6
parent: "[[Beat and cooldowns]]"
---
# Done when

- Beats fall every `BEAT_TICKS` (4) ticks, fight-wide, tick 0 included.
- A skill goes on cooldown when chosen and is ready again on the Nth beat crossed after it.
- The warrior has Strike, Bash and Overpower; Bash and Overpower go on cooldown.
- The rope marks each beat with its own knot and ends on a beat.
- The skill bar shows a skill on cooldown disabled, dimmed, with its remaining beats.

## Implementation decisions

- `BEAT_TICKS` is one constant, easy to tweak.
- `SkillData.cooldown`: in beats, 0 = none.
- Cooldowns live on the character, not the player: the rule binds enemies too; a designer gives an enemy a cooldown or not.
- `FightRules.get_usable_skills` filters out skills on cooldown, so `RandomBrain` and `PlayerBrain.arm_skill` (click and digit key) obey it.
- A rescheduled skill keeps its cooldown: choosing is the commitment.
- Bash: 4 damage, delay 2, cd 2. Overpower: 18 damage, delay 6, cd 3. Plain damage only — stagger is [[Bash and effect preview]], the heavy blow [[Overpower skill]].
- A skill registry, `skill/skill_registry.tres`, a yard `Registry` scanning `res://skill/` for `SkillData`, like `hero/hero_registry.tres`.
- Beat knot: `art/timeline/beat_knot.png`, a recolored copy of `knot.png`, at the same size. The human replaces it.
- The rope reaches the first beat at or after the furthest pending or ghost action.

## Testing decisions

- `tests/fight/fight_rules_test.gd`: cooldown starts on choice, counts beats crossed (Bash chosen at tick 5 is ready at tick 12), a skill on cooldown is not usable, enemies obey it.
- Beat knots, rope end and the dimmed button are judged by playing.

## Out of scope

- Skill cards — [[Skill cards]].
- Skipping when no skill is ready: the existing Pass covers it.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
