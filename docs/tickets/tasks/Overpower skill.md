---
triage: ready-for-agent
id: 1.2-1.5
requires:
  - "[[Bash and effect preview]]"
started: 2026-10-26
finished:
hours: 0.2
parent: "[[Warrior kit]]"
---
# Done when

- [[Overpower]] is staged as a slow, heavy blow, apart from Strike and Bash: the warrior winds up, slams in, and the set shakes at impact. Its 18 damage is already in.

## Implementation decisions

- `SkillData.Blow` `{ QUICK, HEAVY }`, `QUICK` by default; `HEAVY` on `overpower.tres`. `Stage.show_action` plays the action's blow; the stage never reads a skill's name.
- `QUICK` is today's lunge, unchanged.
- `HEAVY`: the actor draws back, leans back and rears up, holds, then slams in leaning forward. At impact: a hit-stop, the target flashed in the damage red, an ink burst with paper flecks at the point of contact, the target knocked back and reeling, the set shaking. The actor straightens and walks back slower.
- Hit-stop: `Engine.time_scale` drops for a moment of real time. A scene-tree timer that ignores time scale restores it, so a freed stage cannot leave the game slowed.
- The set shakes behind the frame: `Background`, `Scenery`, `TimelineRope` and `Puppets` move under a `StageSet` control; `Front`, the nameplates and the skill bar stay put, so no edge ever shows. The shake runs in real time and decays, so it keeps rattling through the hit-stop.
- Lean and lift are the puppet's: its sprite turns on its feet.
- Damage numbers grow with the damage, so 18 reads bigger than 4.
- `ImpactBurst`: a jagged cut-out star drawn in code, paper fill and ink outline, that pops and fades, with flecks from a `CPUParticles2D`. A placeholder until the effects pass.

## Testing decisions

- No test: all of it is staging, judged by playing.

## Out of scope

- Upgrades.
- Sprites or frames for the blow, sound.
- A charging pose while Overpower waits on the timeline.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
