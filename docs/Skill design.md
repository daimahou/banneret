# Skill design

A hero develops their skills and talents through separate drafts. Classes shape the available choices; skill upgrades progressively give familiar actions a particular identity.

## Levelling up

- Each level-up gives each hero **one pick from three offers**.
- All three heroes share the same draft type at each level-up. Spread talent and skill picks across progression, mixing stretches of two talent picks per skill pick with stretches of one each. Do not reserve skill catch-up for the end.
- Full development comprises **23 talent picks and 14 skill picks per hero**. An offer and its perk together form one decision: 37 per hero, 111 across the party at maximum development.

- Skill picks occur at party level-ups **3, 6, 8, 11, 14, 16, 19, 22, 24, 27, 30, 32, 35, 37**. All other picks from 1 through 37 are talent picks. New runs reset to pick 1; debug level-ups consume the next pick in the same sequence.
- Completing or skipping all heroes' picks advances the sequence once. After pick 37, the combat prototype continues fights without further drafts; the level-up command reports completion rather than restarting the sequence.

- Each draft offers **two new entries and one upgrade to an owned one**, within the current draft's type: talent or skill.
- The run selects the talent or skill offered for upgrade with equal chances among eligible owned ones, including the class slot.
- The player chooses its perk from the authored eligible perks, not a random sample: target three perks, with a maximum of four.
- Switching heroes or returning from a perk does not reroll offers.
- Missing new-entry or upgrade offers are filled from the other category within the same draft. Show three distinct offers whenever possible, or all valid offers if fewer than three remain.
- Fallen heroes skip their picks; the shared draft sequence still advances.
- No gems, points or talent tree.

> [!frontier] Level-up trigger and map pacing
> Proposed: completing each map node grants one level-up, including non-fight events. Aim for two to three fights per two skill picks. The combat-only milestone uses victory as its temporary trigger.

- A scheduled level-up must have a valid offer in the intended content set. No valid offers indicates incomplete content, not a normal progression outcome.

- During placeholder development, report missing content and skip that hero's pick if no valid offers exist. Do not invent a reward or convert the pick to the other draft type. If every hero is skipped, finish the level-up automatically so testing can continue.

## Talents

- Talents and skills develop through **Basic, Advanced and Expert**.
- A talent provides its rank's effect; Advanced and Expert also offer a perk.
- Shared talents support several classes. Some talents are exclusive to one class; shared talents can contain class-specific perks.
- Perks reflect the hero's class and ascension when the upgrade is taken. Becoming a class later does not reopen or replace earlier selections. Pick order is intentional.

- Seven acquired talent slots plus the starting class slot. Each acquired talent has three ranks; the class has two upgrades. Rows are presentation only, not class requirements or triggers.

> [!frontier] Power and rank values
> Proposed: a scalable attack Power stat, used differently by skills. Offense illustrates the model with Basic +2, Advanced +4 and Expert +6 attack Power, plus perks at Advanced and Expert. Exact values and whether those bonuses are totals per rank remain to be specified.

## Classes

- The class is a talent that starts in its own slot, such as **Warrior**, and develops through the talent draft's upgrade offer.
- Upgrading Warrior offers a choice of specialization, such as Paladin, Berserker or Marshal. The player chooses within the class offer; qualification through other talent investments is not required.
- Choosing Paladin closes the competing specialization paths and leaves Paladin's ascensions as its subsequent class-upgrade choices. An offered Paladin upgrade lets the player choose its ascension freely.
- Class selection consumes the level-up pick. Filling an ordinary talent slot does not also grant a class choice.
- The initial talent Bag has equal offer weights. A class adds its exclusive talents and changes the weights of existing talents: Paladin can favour defensive choices while retaining the possibility of an unconventional build.
- A class establishes a direction through its talent effect, offer weights, exclusive content and class-specific perks.
- An ascension is a **capstone** that alters a mechanic towards its fantasy. Its effect provides the defining moment; it does not require a separate catalogue of additional skills.

> [!frontier] Class content and offer weights
> Author the starting classes, specializations, ascension effects, exclusive talents and weight changes. Class-slot upgrades have the same chance as other eligible owned talent upgrades.

## Skills

- Skills are the actions used in combat. Their acquisition and upgrades use the skill draft, separately from talent progression.
- A skill upgrade develops that particular skill into an expression of itself, changing behaviour rather than only increasing numbers.
- Shared perks can coexist with class-specific perks. A known skill can acquire a class-specific perk when upgraded after specializing.
- The player inspects and chooses the perk inside the offered upgrade. The class does not automatically convert all of the hero's skills.
- The basic attack is part of this intended development: a Warrior's Strike can develop differently as a Paladin or Berserker.

- Four acquired skills plus the starting basic attack. Acquired skills have three ranks; the basic attack has two upgrades.

> [!frontier] Skill perks
> Author the eligible perks at each upgrade of each skill.

> [!fog] Warcry and Appease example
> Illustrative direction, not an authored skill rule: Warcry builds Rage; a Paladin development makes the skill become Appease while the hero has Rage, draining it into self-healing. The change belongs visibly to the skill. Exact effects and values remain to be designed.

> [!frontier] Skill Bag
> Specify the initial skill Bag, class-exclusive skills and any class-dependent offer weights.

## A skill stands alone

- The base form has an effect of its own and is useful when acquired; development strengthens and gives it identity during the run.
- A mechanic a skill produces has an effect of its own. [[Rage]] is not only a resource to spend.
- A skill can become valuable through its own upgrades, another skill, another hero, a relic, or its class and ascension. No single partner is required.
- Design shared skills across several possible builds, alongside exclusive skills where the class needs its own design space.

## Where an improvement lives

| Choice | Role |
|---|---|
| Skill development | Changes a particular action and how it is used |
| Talent development | Builds stats and interactions across the hero's kit |
| Class | Establishes a direction and shapes subsequent offers and perks |
| Ascension | Transforms a mechanic as a build-defining capstone |

> [!frontier] Overlapping talent effects
> Define how effects on the same mechanic combine when authoring the affected content.

> [!fog] Gameplay tags
> Tags gate offers and perks today. Later they could carry gameplay: an effect grants `frozen` to a target for a while, another deals extra damage to a frozen target.

> [!frontier] Respec
> Whether a separate respec opportunity exists remains open. Class changes themselves never revise earlier choices.
