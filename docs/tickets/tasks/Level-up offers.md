---
triage: ready-for-agent
id: "1.3-1.2"
requires:
  - "[[Fight sequence and starting party]]"
started:
finished:
hours: 0.1
parent: "[[Combat and progression]]"
---

# Level-up offers

Implement the party's passive and active drafts using placeholder content, between successive fights and through a debug command. [[Skill design]] holds the design; this task defines the implementation scope. Real content and its supporting mechanics follow in [[Progression content]].

## Player flow

- Victory pauses the fight sequence and opens the three-column level-up view. Show all three heroes, their current builds and their offers together.
- Interact with any hero's column to inspect and select their offers while the other columns remain visible. Generate each hero's offers once per draft. Switching heroes or backing out never rerolls them.
- A new active skill shows its effect and costs; a passive shows its effect; an upgrade shows what changes. A class choice also explains which offer-pool changes it brings.
- Selecting an upgrade opens its authored development options. The player can go back until confirming the complete choice. That confirmation consumes the hero's one pick and cannot be undone in this task.
- Heroes at 0 health skip their picks. A hero with no valid offers is skipped with a diagnostic warning identifying the hero and draft type; no substitute reward or cross-draft conversion is granted.
- After every eligible hero confirms, Continue returns to combat. A victory-triggered draft starts the next fight; a command-triggered draft resumes the same fight. If everyone is skipped, return automatically.

## UI reference

![[attachments/party_level_up_simple_talent_options.png]]

- Reusable UI pieces are available in `stage/level_up/assets/`; its `README.md` and `manifest.json` define final pixel sizes, transparency and integration constraints. Review [[attachments/level_up_assets_native_preview.png|the native-size assembly]] and [[attachments/level_up_assets_contact_sheet.png|the piece sheet]]. The set targets 1672 × 941; resolve presentation against the current project viewport without silently scaling individual textures.
- Use this mockup as the reference for layout, visual hierarchy and interaction states. Its names, skills, icons and values illustrate the UI; they do not require implementing that content in this task.
- Three equal hero columns: portrait, name, class and stats; an eight-slot passive build; a separate five-slot active row; offers or talent options; a per-hero Confirm button. Keep all three builds visible for comparison.
- Selecting an upgrade keeps its parent card visible with Back and replaces that column's remaining offer area with the talent choices. Other heroes' offers remain visible. Support up to four talent options without obscuring confirmation controls.
- Keep **Basic / Advanced / Expert** titles and show the resulting rank's value. Inspect the owned skill by hovering its build icon for a tooltip with its current effect and chosen options. No additional draft-type banner or mandatory before/after number notation is needed.
- Preserve sub-skill icons on offer cards and beside owned skills: they communicate development options and selected talents. Keep their tooltips available; do not remove them to simplify the screen.
- Match the wood, parchment and theatre framing. Empty slots and unused sockets are dark and recessed; small sub-skill icons have quieter frames than their parent skill; unselected card borders use muted brass. Reserve the strongest gold highlight for the selected offer or talent.
- Selection is not confirmation: show the selected talent's checkmark and enable that hero's Confirm button. After confirmation, retain the chosen reward and build, clearly mark that column as confirmed, and prevent further changes.
- Keep the shared readiness count and Continue at the bottom. Update readiness only when a hero is confirmed or skipped; Continue remains disabled while a required choice is outstanding.

## Shared pick sequence

- All heroes share the draft type and sequence position. Each eligible hero gets one complete pick at that position; an offer and its internal option are one decision.
- Active picks: **3, 6, 8, 11, 14, 16, 19, 22, 24, 27, 30, 32, 35, 37**. All other positions from 1 through 37 are passive: **23 passive and 14 active**.
- The first two picks are passive. Active picks are spaced two or three positions apart throughout the sequence.
- Advance once after all heroes have confirmed or been skipped, including when all are skipped. Opening an option or confirming one hero never advances the party sequence by itself.
- Victory and the debug command consume the same sequence. A fresh run resets the sequence and every hero's build.
- After position 37, fights continue without drafts. The debug command reports that progression is complete and makes no change. Do not loop the sequence or generate additional rewards.

## Slots and ranks

- Seven acquired passive slots plus one occupied starting-class slot. Passives have Basic, Advanced and Expert ranks; acquisition grants Basic. Advanced and Expert each grant the authored rank effect and a node choice.
- Four acquired active slots plus the starting basic attack. Acquisition grants the first rank; each active, including the starting attack, has two upgrades.
- New offers require an empty slot of their type and a skill the hero does not already own. The starting class and basic attack retain their dedicated slots.
- Upgrade offers require a non-maximal owned skill with at least one eligible development at its next rank. Rank requirements and class restrictions apply before sampling.
- An active upgrade changes that action's authored expression. Passive and class effects belong to that hero. Do not mutate shared definitions or another hero's build when applying a pick.

## Offer generation

- Each draft starts with **two new-skill offers and one upgrade offer**, all within the current passive or active type.
- New-skill offers use positive authored weights; initial eligible passive entries have equal weights. The class can add exclusive entries and change weights on shared entries. Placeholder active entries can use equal weights; the system supports authored weights.
- All eligible owned skills have equal chances for an upgrade offer, including the class slot. A skill with more internal options does not receive a greater chance.
- Sample distinct skills without replacement. An upgrade offer names one owned skill, not one of its individual development options.
- If one category cannot fill its places, draw the remaining places from the other category in the same draft. Always show three distinct offers when possible; otherwise show all valid offers.
- Internal upgrade options are authored, not randomly sampled: normally three and at most four eligible options. Show fewer if content or eligibility leaves fewer. Invalid content with more than four eligible options must be diagnosed rather than silently sampled down.
- No valid offers is an incomplete-content condition during scheduled progression: warn and skip as described above. It must not leave Continue permanently disabled.

## Class and ascension

- The starting class already occupies its passive slot. Its first upgrade offers specializations; the second offers the chosen specialization's ascensions. Both consume a normal passive pick.
- There are no investment thresholds in other passives and no bonus class pick for filling a slot. Class and ascension options are chosen freely inside the offered class upgrade.
- Choosing a class closes competing specialization paths, applies its effect, unlocks its exclusive entries and adjusts shared new-skill offer weights. Unconventional shared picks remain possible.
- Shared passive and active upgrades evaluate class-specific options when their offers are generated. Existing confirmed options are never retroactively changed.
- Ascension applies an authored capstone effect. This task demonstrates that path with a placeholder; it does not require a new catalogue of ascension skills.

## Placeholder content

- Use clearly labelled, replaceable placeholder definitions for all three starting heroes. They may share fixture content; the implementer may choose temporary names and values.
- Provide enough examples to exercise new passive and active acquisition, both ranks of upgrades, class and ascension selection, weighted offers, exclusive entries and class-dependent options. A complete production pool is not required.
- Use existing damage, stagger, timing and resource capabilities for small observable example effects. Do not implement the proposed Power system, Rage, Appease or other new combat systems just to demonstrate progression.
- Include test configurations with full slots, maximum ranks, insufficient offers and no valid offers. Real skill design, balance and new mechanics belong to [[Progression content]].
- Use existing stage and UI assets where practical, following the mockup's three-column layout, offer/talent states and visual hierarchy. Placeholder content may use existing icons; new final artwork is not required.

## Level-up command

- Add **`levelup`** to the existing debug console. It requests the next scheduled party draft without requiring victory and consumes a normal sequence position.
- Pause combat at a safe boundary, after any in-progress action presentation/resolution completes. Also handle the player already waiting to choose an action; the command must not require scheduling an attack just to open progression.
- While a draft is open, combat time and action resolution do not advance and combat input cannot schedule actions. Preserve the fight, its pending actions, health, AP and cooldowns.
- Continue resumes the same fight with the new build. Already scheduled actions keep their originally scheduled skill behaviour; subsequent actions use the upgraded version. Refresh skill choices and previews after the draft, without resetting cooldowns through an upgrade.
- Ignore overlapping requests with a diagnostic message while a draft is requested or open. Reject requests when there is no active run or the run is being reset. Do not end the fight or grant victory.
- If the fight ends before a requested pause can open, discard the pending request and let the normal victory/defeat flow handle progression; do not grant two drafts for one pending request and victory.

## Implementation starting points

- `run/run_controller.gd`: `_play_fights` currently chains fights after `HOLD_DURATION`; insert the victory draft before creating the next encounter. Defeat still starts a fresh run.
- `run/run_model.gd`: owns the party. The party draft sequence belongs to the run, and per-hero progression must survive successive fights.
- `character/character.gd`, `character/character_data.gd` and `skill/skill_data.gd`: existing runtime characters and shared definitions. Preserve independent hero progression, including when definitions are shared.
- `fight/fight_controller.gd` and `fight/player_brain.gd`: coordinate the safe pause with action resolution and waiting player input; avoid a second combat loop.
- `stage/offer/offer_presenter.gd`: existing offer presentation is available for reuse. Adapt presentation without changing the agreed interaction.
- `debug/debug_commands.gd`: debug-only console commands belong here and call the game's exposed behaviour.
- Existing preview simulation copies character state; progression effects must be represented consistently in previews and actual resolution.

## Done when

- Victory and `levelup` both use the specified draft flow, sequence, eligibility, sampling and fallback rules.
- All three heroes can acquire and upgrade placeholder content independently; choices persist into combat and reset on a fresh run.
- Class selection changes later offer eligibility, weights and upgrade options without rewriting earlier choices.
- Confirmation applies exactly one complete choice; backing out or switching heroes changes neither the offers nor the build.
- Fallen, exhausted and content-starved heroes cannot stall the flow. Completing position 37 stops further drafts without ending the combat loop.
- Command-triggered progression freezes and resumes the same fight without advancing time, losing pending actions, resetting cooldowns or duplicating drafts.
- The flow is playable using existing assets, and placeholder effects agree between previews and combat.
- The UI follows the reference's simultaneous three-hero layout, visible build and sub-skill icons, in-column talent selection, restrained framing and clear selection/confirmation states.

## Validation

- Exercise the whole sequence through run progression: every hero gets the same type, the count advances once per completed party draft, skipped heroes do not desynchronize it, completion stops drafts, and a new run resets it.
- Use controlled random draws to check new-skill weights, equal per-skill upgrade sampling, no duplicates, eligibility filtering and every fallback case. Avoid flaky frequency-based tests.
- Check full slots, maximum ranks, fewer than three offers, empty pools, class-exclusive unlocks, three/four-option content and non-retroactive choices.
- Check that confirm/back/switch actions preserve offers and apply the choice once, to one hero only. Acquiring and upgrading an active must change subsequent combat behaviour without leaking into another hero or queued action.
- Exercise command requests while waiting for input, during action resolution, while a draft is open, and as a fight ends. Confirm that combat resumes once with its preserved state.
- Run the checks in [[feedback-loop]], including the existing combat and preview tests. Judge visual layout and real input by playing, not by headless layout assertions.
- Compare the running view against the reference at the game's actual size: inspect build and sub-skill tooltips, three/four-option layouts, switching between columns, selected versus confirmed states, readiness and Continue. All choices and controls must remain readable and accessible.

## Out of scope

- Map-node level-up triggers and map pacing: [[Map and events]].
- Production skill design, class balance, new combat mechanics and final art.
- Respec, rerolls, save/load and revival.

## Tickets

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
