---
triage: ready-for-agent
id: 1.3-1.2
requires:
  - "[[Fight sequence and starting party]]"
started: 2026-11-14
finished:
hours: 2.6
total_hours: 6.9
extra_hours: 0.5
parent: "[[Combat and progression]]"
---

# Level-up offers

Implement the party's talent and skill drafts with placeholder content, between fights and through a debug command. [[Skill design]] holds the design; real content follows in [[Progression content]].

## Problem Statement

Heroes never change during a run: they win a fight and enter the next with the same basic attack. The player has no build decisions, so fights cannot reward or demand different strategies, and the design's progression (talents, skills, ranks, perks, class, specialization, ascension) cannot be tested.

## Solution

After each victory, a full-screen level-up shows all three heroes side by side, each with their build and three offers from the shared draft. Each hero selects one pick (an offer and its perk); Continue confirms them all, then the next fight starts with the new builds. A `levelup` console command opens the same level-up mid-fight and resumes the same fight. Placeholder content exercises every rule; tags gate class-dependent content.

## User Stories

1. As a player, I want a level-up after each victory, so that winning develops my party.
2. As a player, I want to see all three heroes' builds and offers at once, so that I can compare and plan the party together.
3. As a player, I want every hero to share the same draft type, so that the party develops in step.
4. As a player, I want two new talents or skills and one upgrade per hero, so that I choose between breadth and depth.
5. As a player, I want offers not to reroll when I switch heroes or go back, so that I cannot fish for better offers.
6. As a player, I want a new skill offer to show its effects and costs, so that I know what I'm adding to my actions.
7. As a player, I want a new talent offer to show its effect, so that I know what my hero gains.
8. As a player, I want an upgrade offer to show what changes and its perks, so that I can choose a direction for that skill or talent.
9. As a player, I want the class upgrade to show the specializations it opens, so that I understand the direction I commit to.
10. As a player, I want to open an upgrade, browse its perks and go back, so that I can explore before deciding.
11. As a player, I want to change my selections until I continue, so that I never commit by accident.
12. As a player, I want a selected offer marked, so that I see who is ready.
13. As a player, I want a readiness count and a Continue button enabled only when every required pick is made, so that I know when I can move on.
14. As a player, I want fallen heroes to skip their pick, so that the level-up does not wait on someone who cannot fight.
15. As a player, I want the level-up to close by itself when every hero is skipped, so that I'm never stuck.
16. As a player, I want hovering an owned skill or talent to show its current effect and chosen perks, so that I can read my build.
17. As a player, I want perk icons beside owned skills and talents, so that I see each one's development at a glance.
18. As a player, I want an upgraded skill to behave differently in the next fight, so that my choice matters in combat.
19. As a player, I want talents to raise my hero's max health or AP, with current rising by the same amount, so that a gain is felt at once.
20. As a player, I want a specialization to close competing ones, so that the class choice is a real commitment.
21. As a player, I want ascensions offered only for my specialization, so that the capstone fits my direction.
22. As a player, I want class-exclusive talents, skills and perks to appear once I specialize, so that the class shapes my later offers.
23. As a player, I want earlier picks never changed by a later class choice, so that pick order is meaningful.
24. As a player, I want previews to show my upgraded skills and talents exactly as combat will resolve them, so that I can trust them.
25. As a player, I want progression to stop cleanly after the 37th level-up, so that fights continue without empty drafts.
26. As a player, I want a new run to reset the level-up count and every build, so that each run starts fresh.
27. As a player, I want cooldowns to survive an upgrade, so that upgrading is never a free reset.
28. As a developer, I want a `levelup` command that opens the next level-up mid-fight, so that I can test progression without winning fights.
29. As a developer, I want the command to wait for a safe boundary or act at once while the player chooses, so that no action is cut in half.
30. As a developer, I want the paused fight to resume exactly where it was, so that health, AP, cooldowns and the timeline are preserved.
31. As a developer, I want a mid-fight upgrade to apply at once, including to actions already on the timeline, so that I see its effect immediately.
32. As a developer, I want overlapping or invalid `levelup` requests rejected with a message, so that drafts are never duplicated.
33. As a developer, I want a request discarded when the fight ends first, so that one victory never grants two level-ups.
34. As a developer, I want the command to report completion after the 37th level-up, so that I know progression is over.
35. As a developer, I want a warning naming the hero and draft when a hero has no valid offers, so that missing content is visible.
36. As a developer, I want content with more than four eligible perks diagnosed, so that authoring errors are not silently hidden.
37. As a designer, I want skills and talents to share one shape (base, then two ranks of modifiers and perks), so that authoring is uniform.
38. As a designer, I want the class to be a talent whose rank perks are specializations and ascensions, so that the class needs no special system.
39. As a designer, I want perks to grant tags and talents, skills and perks to require tag stacks, so that I can gate class content without content knowing about other content.
40. As a designer, I want to pick tags from a dropdown fed by a tag library, so that tags are never misspelled.
41. As a designer, I want tags hidden from the player, so that they stay an authoring tool.
42. As a designer, I want placeholder content that exercises every rule, so that the system is proven before real content arrives.

## Implementation Decisions

### Level-up count

- The run counts its level-ups, 1 to 37; each level-up's number sets its draft. Skill drafts at **3, 6, 8, 11, 14, 16, 19, 22, 24, 27, 30, 32, 35, 37**; every other one is a talent draft (23 talent, 14 skill).
- The count advances once when the picks are confirmed or every hero is skipped, including when all are skipped. Victory and `levelup` advance the same count. After the 37th, no more level-ups.
- A new run is a new `RunModel`: count and builds reset.

### Model

- **`Skill`** wraps **`SkillData`** as `Character` wraps `CharacterData`. `SkillData` is the preset: its stats (delay, cooldown, AP cost), effects, and `ranks` — exactly 2 entries (Advanced, Expert). The preset itself is Basic.
- A skill rank holds effects, skill modifiers and perks. A skill perk holds effects and skill modifiers. Rank and perk effects add to what the skill does on resolve; they never edit an effect they did not add.
- `Skill` holds its rank and chosen perks and exposes the resulting stats and effects. Shared `SkillData` is never mutated.
- **`Talent`** wraps **`TalentData`**: hero modifiers and 2 ranks, each of hero modifiers and perks; a talent perk holds hero modifiers. Talents own no effects; skills own no hero modifiers.
- **Modifiers** are flat. Skill modifiers target delay, cooldown or AP cost. Hero modifiers target max health or max AP (max AP capped at `MAX_AP`).
- Every resource follows one rule: gaining max raises current by the same amount; losing max leaves current unchanged unless it exceeds the new max, then it is clamped. A fallen hero stays at 0.
- **Class** is a talent in a dedicated slot, named by `CharacterData`. Rank-2 perks are specializations; rank-3 perks are ascensions, gated by the specialization's tag.
- `Character` holds its skills (basic attack in its dedicated slot, then up to 4 acquired) and talents (class in its dedicated slot, then up to 7 acquired), built from `CharacterData`. Its max health and max AP derive from data plus talent modifiers.
- `Action` holds the hero's live `Skill`; a mid-fight upgrade applies to actions already on the timeline.
- Each `Skill` holds its own cooldown; the per-character cooldown dictionary goes away. An upgrade never resets it.
- A `Skill` has an id kept by `duplicate()`. Simulation copies characters with their skills and remaps each action's skill by id, as it remaps actors, so previews and resolution agree.

### Tags

- A **`TagLibrary`** resource lists the tags; it feeds the editor dropdowns on every tag field.
- `Character` holds tag counts, with counted grant and strip. Nothing strips in this task.
- `TalentData`, `SkillData` and perks list tags they grant: on acquisition, or when the perk is picked. Ranks grant nothing.
- `TalentData`, `SkillData` and perks list requirements: a tag and a minimum count (default 1). All must be met. No OR or NOT.
- Tags are never shown to the player. In this task they are used for gating only.

### Offers

- Two **Bags**, one of `TalentData` and one of `SkillData`, hold the placeholder entries.
- A level-up offer is either a new talent or skill (an entry from the draft's Bag) or an upgrade of one owned talent or skill. It is its own type; the mission map's `Offer` is untouched.
- A new entry is eligible if the hero has a free slot of its kind, does not own it, and meets its requirements.
- An owned talent or skill is eligible for upgrade if it is below Expert and its next rank has at least one perk whose requirements the hero meets. Dedicated slots (class, basic attack) are included.
- Each draft draws two new entries and one upgrade, distinct, uniformly, without replacement. A category that cannot fill its places fills from the other. Fewer than three valid offers shows all of them. No weights.
- An upgrade offer names the talent or skill, never a perk. Its perks are the authored eligible ones in order (normally 3, at most 4). More than 4 eligible is diagnosed with an error, never sampled down.
- One run-level `RandomNumberGenerator`, separate from fight seeds, draws every offer. Tests inject it.
- A hero with no valid offers is skipped with a warning naming the hero and draft type. No substitute reward, no conversion to the other draft.

### Level-up

- **`LevelUp`**: a model object the run creates for its next level-up. It holds the draft type, each hero's offers (drawn once), each hero's state (pending, confirmed, skipped), and accepts one selection per pending hero (an offer and, for an upgrade, a perk), changeable until confirmed. Confirming applies every selection at once, each to its hero only, and cannot be undone. It is complete once no hero is pending; completion advances the run.
- Fallen heroes are skipped.

### Flow

- `RunController`: after a victory, if a level-up remains, show the view, await completion, then start the next fight. Defeat still starts a fresh run.
- `FightController` accepts a level-up request and pauses at a safe boundary: after the action being presented and resolved, or at once while the player brain waits. No second combat loop. While paused, time and resolution do not advance and input cannot schedule actions. Resuming continues the same loop; skill choices and previews refresh.
- `levelup` (in `DebugCommands`) calls the run's exposed request. Rejected with a message when no run is playing, the run is resetting, a request is pending or a level-up is open. After the 37th level-up it reports completion and changes nothing. A fight ending before the pause discards the request; victory then follows its normal flow.

### View

- Full-screen overlay scene in the level-up feature folder, beside its assets. The fight is hidden behind it.
- Three equal columns: portrait, name, class and stats; eight talent slots; five skill slots; offers or perks. Shared readiness count and Continue at the bottom; no per-hero Confirm.
- Selecting an upgrade keeps its card with Back and replaces the column's remaining offers with its perks (up to four). Other columns stay visible.
- Rank titles **Basic / Advanced / Expert** with the resulting rank's value. Hover an owned talent or skill for its current effect and chosen perks. Perk icons on offer cards and beside owned entries, with tooltips.
- Selection shows the check and makes the hero ready; it can still change. Continue is enabled once every hero is ready and confirms all picks at once.
- Assets: scale the level-up PNGs offline from the 1672 × 941 canvas to 3840 × 2160 (×2.2966) and update their README and manifest. Nodes stay at scale 1 × 1. The human redraws them at that size later.
- Match the reference: wood, parchment, theatre framing; dark recessed empty slots; quieter frames on perk icons; muted brass on unselected cards; strongest gold only on the selected offer or perk.

![[attachments/party_level_up_simple_talent_options.png]]

- Its names, skills, icons and values illustrate the UI only. See also [[attachments/level_up_assets_native_preview.png|the native-size assembly]] and [[attachments/level_up_assets_contact_sheet.png|the piece sheet]].

### Placeholder content

- Invent nothing. Skill Bag: Placeholder A, B, C. Talent Bag: Placeholder A, B, C. One placeholder class shared by the three heroes. Seven files in all.
- Each holds its 2 ranks and generic perks (Perk A, B, C) as sub-resources in its own file. No effects, no modifiers: they do nothing.
- Only tags are used: the class's specialization perks grant a tag, its ascension perks require it.
- Every rule needing observable content (effects, modifiers, class-exclusive entries, four and five perks, full slots, empty Bags) is covered by test doubles, not game content.

## Testing Decisions

- Tests assert behaviour through public interfaces, never stored values or `.tres` placeholder numbers. Test content is doubles under the tests' doubles folder.
- **`RunModel` / `LevelUp`** (main seam, pure): the level-up count and draft types, advance once per completed level-up including all-skipped, stop after the 37th, reset with a new run; offer counts, distinctness, fallbacks between categories, fewer than three, none; slot and rank limits; tag grants and stacked requirements on entries and perks; perk ordering and the >4 diagnostic; offers stable across repeated reads; a pick applies once, to one hero; earlier picks unchanged by a later specialization. Randomness through an injected scripted RNG; no frequency tests.
- **`FightController`** (existing): a request mid-action pauses after resolution; a request while the player waits pauses at once; resume preserves timeline, health, AP and cooldowns and plays on once; a request discarded when the fight ends. Prior art: `fight_controller_test`, `debug_commands_test`.
- **`Simulation` / `FightModel`** (existing): an upgraded skill's stats and added effects change resolution and the preview agrees; talent max health/AP gains follow the resource rule; an upgrade does not reset a cooldown; a simulation's cooldowns never leak into the fight; an upgrade reaches an action already queued. Prior art: `simulation_test`, `fight_rules_test`.
- **`RunController`** (existing): victory opens a level-up before the next fight. Prior art: `run_controller_test`.
- No layout tests. The view, real input and tooltips are judged by playing at the game's size, against the reference. Run [[feedback-loop]] including existing combat and preview tests.

## Out of Scope

- Offer weights of any kind, including class-dependent weights: [[Progression content]].
- Map-node level-up triggers and pacing: [[Map and events]].
- A damage or stagger bonus stat, and any new combat mechanic (Power, Rage, Appease).
- Gameplay use of tags, tag stripping content, OR/NOT requirements.
- Production content, balance and final art.
- Respec, rerolls, save/load, revival.

## Further Notes

- Tags are planned to carry gameplay later: an effect could grant `frozen` to a target for a while, and another deal extra damage to a frozen target. Keep the tag system general enough for that.
- No ADRs exist yet; none was written for this task.

## Tickets

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
