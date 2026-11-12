---
requires: []
id: 1.3-2b
deadline:
started:
finished:
parent: "[[Act 1 prototype]]"
---

# Progression

Heroes grow through coloured gems from the map, spent on empty slots, skills and hero trees, shown on one party wheel.

## Done when

### Heroes and colours

- Six colours: **red** strength, **yellow** light, **blue** intelligence, **green** dexterity, **purple** dark, **grey-blue** balance.
- A hero starts the run as a precursor with one colour (the warrior is red) and only their weapon's basic attack.
- A hero holds four skills: the basic attack and three slots.
- A hero gains two more colours: the first sets the class (warrior + yellow = paladin), the last the ascendancy. Only designed combinations exist.
- Each precursor supports four colours, matching its classes; its hero tree accepts only those. Every colour is supported by at least two precursors, so no gem forces one hero's direction.
- Each hero has a hero tree. Like a skill, it has no nodes until its first gem: the class gem reveals the class branch, the ascendancy gem the ascendancy branch.
- Each class is built around one mechanic: its class tree empowers that mechanic and every skill of the class. An ascendancy turns the mechanic a different way.

### Gems

- **Coloured gems are the only progression**: there are no levels. Every map node gives one gem, fights included, its colour shown on the map. Gems are held by the party until spent.
- Any gem can go to any hero: on an empty slot it brings a new skill; on a skill it evolves that skill; on the hero tree it sets the class, then the ascendancy.
- Converting a gem's colour is never a regular offer: only a rare special event on the map can do it.

### Skills

- A gem spent on an empty slot offers three skills of its colour for that hero's precursor (a red gem on a warrior: three warrior skills; a yellow gem: three paladin skills). Ascendancies have no skills of their own.
- Generic colour skills are regular skills that belong to a colour, not a class (yellow: a plain Heal), available to every hero. A gem of a colour the precursor doesn't support, spent on an empty slot, offers generic skills of that colour, so no gem is ever a dead drop.
- A skill has four stages. Acquired, it has no nodes. The first gem's colour picks the skill's class version and reveals its first set of nodes (a blue gem on a warrior's Strike: Arcane Strike, the spellblade version). The second gem's colour picks one of that class's ascendancy versions and reveals a second set: each ascendancy is bound to a colour (yellow then purple: the martyr Smite), and its nodes are that colour. The third gem fills the ultimate slot: any colour, and it unlocks that colour's mechanic on the skill (a blue gem on Smite: Smite can be channelled). Only one skill per hero can reach its ultimate. A skill never evolves on its own.
- A skill follows its own class's ladder, whatever the hero's class.
- A skill takes only two or three colours (Strike: yellow Smite, red Bash, blue Arcane Strike); a gem fits only skills that take its colour. The precursor pool is small, since each of its skills needs a version per colour it takes.
- Off its class, a coloured skill still works, without the class tree's boosts.
- Every skill tree has a spine shared by all its upgrades; each upgrade adds its own nodes, branching off the spine.

### Node points

- A gem grants node points of its colour. Spent on a skill: 2 points, for that skill's tree only. Spent on the hero tree: 5 points, for any of the hero's trees. Spent on an empty slot: none.
- Points of a colour buy nodes of that colour, in revealed sets only. Earlier revealed nodes stay buyable.
- Skills, colours and purchases are permanent; no respec.

### The wheel

- The party wheel shows each hero's hero tree, in the wedge facing them, and their skill trees. No follower sections.
- Layout reference: ![[party_wheel_gems.svg]]
- Proven on the warrior's basic attack tree.

> [!frontier] Class gem points
> 5 is a starting value; it may be too many.

> [!fog] Gem sinks
> Gems could have uses besides growing heroes. Risky: growing heroes is what players want, so another use is likely a bad trade.

> [!fog] Generic skills in supported offers
> Whether generic colour skills also appear when the gem's colour has a class home. Decide by feel in play.

> [!frontier] Colour mechanics for ultimates
> Each colour needs one mechanic that works on any skill (blue: channeling). Which mechanic per colour, and whether the ultimate gem also grants points.

> [!frontier] When the spine appears
> A skill has no nodes until its first gem. Provisional: the first gem reveals the spine together with its upgrade's nodes.

> [!frontier] Coloured spine and off-colour gems
> Idea: spine nodes each have a colour (Strike: Keen edge, strength; Footwork, dexterity). A gem of a colour the skill doesn't take fills no keystone and only grants points for the spine, so it is never a dead drop. Catch: off-colour spine nodes are hard to fill unless the class also brings that colour.

## Tickets

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
