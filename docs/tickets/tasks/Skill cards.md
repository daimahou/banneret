---
triage: ready-for-agent
id: 1.2-1.2.2
requires:
  - "[[Cooldown rules]]"
started:
finished:
hours: 1.8
parent: "[[Beat and cooldowns]]"
---
# Done when

- Each skill on the bar is a card from the mockup: frame, icon, name, description, delay on the hourglass, inert AP pips and energy drop.
- A skill on cooldown: card dimmed, a clock-wipe over the icon, remaining beats on it.
- Only the armed skill is ever highlighted.

## Implementation decisions

- Art is cut from `banneret.generated/stage_battle/06_delay_hourglass.png` (next to the repo) and resampled offline to final 3840 size (×~2.3); shown 1:1, no scaling. Base files for the human to overwrite — looks don't matter: card frame, hourglass, empty icon slot, AP pip, energy drop.
- `SkillData.icon`: optional `Texture2D`, left empty in every `.tres`; null shows the placeholder slot.
- The description is built from the effects, one line per effect, via `Effect.get_description()`. Each effect colours its own numbers in BBCode (damage red, later heal green); the card draws it in a RichTextLabel.
- The clock-wipe fills to remaining ÷ total beats.
- AP pips and energy drop are static art: no data behind them.
- The pending gold border is removed: selecting a hero highlights no skill but the armed one.

## Testing decisions

- Judged by playing: cards, dimming, wipe, description colours.

## Out of scope

- Real icons and art — the human's.
- AP and energy costs as data — [[AP pips]], [[Energy]].

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
