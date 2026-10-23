# Combat

How an encounter plays: the party against its enemies, until one side falls.

## Sides

- The **party** of 3 heroes against the encounter's enemies.
- Heroes and enemies make the same decisions: the player decides for the heroes, chance for the enemies.

> [!fog] Scripted enemy actions — reactions, planned actions (e.g. self-destruct after X ticks).

## Timeline

- A chosen skill **queues** on the timeline at its resolve tick.
- The earliest resolves first.
- Ties are broken in LIFO

> [!frontier] When does a hero or enemy choose — only once it has nothing queued?

> [!frontier] Who chooses first when both sides are free?
> Provisional: enemies first, so the player reads their intent before choosing.

- Both sides' pending actions show on the timeline — reading it is the decision.

## Skills

- One skill for now: **direct damage** to one target on the other side.

> [!fog] More skills — speeds, area, support, self.

> [!fog] Cooldowns.

> [!fog] Statuses — what they do, and when they tick.

> [!fog] A beat — a recurring tick on which cooldowns and statuses resolve.

## Outcome

- The fight ends when one side has fallen.
- A defeat loses the run.
