# Combat

How an encounter plays: the party against its enemies, until one side falls.

## Sides

- The **party** of 3 heroes against the encounter's enemies.
- Heroes and enemies make the same decisions: the player decides for the heroes, chance for the enemies.

> [!fog] Scripted enemy actions — reactions, planned actions (e.g. self-destruct after X ticks).

## Timeline

- A chosen skill **queues** on the timeline at its resolve tick.
- The earliest resolves first.
- Ties are broken in LIFO, to counter what is there; but an action chosen on top of its actor's own queues after them, in the order chosen.

> [!frontier] When does a hero or enemy choose — only once it has nothing queued?
> Idea: while its pending actions are fewer than its AP — [[AP economy]].

> [!fog] Stops: click a knot to run the fight until that tick, or stop every beat.
> Running to a knot may also need to stop when something new lands on the rope before it.

> [!fog] What a skill costs beyond its cooldown — [[Energy]].

> [!frontier] Who chooses first when both sides are free?
> Provisional: enemies first, so the player reads their intent before choosing.

- Both sides' pending actions show on the timeline — reading it is the decision.

## Skills

- One skill for now: **direct damage** to one target on the other side.

> [!fog] More skills — speeds, area, support, self.

> [!fog] Cooldowns.

> [!fog] Statuses — what they do, and when they tick.

> [!fog] A beat — a recurring tick on which cooldowns and statuses resolve.
> Named beat or round once the stop model is chosen.

## Outcome

- The fight ends when one side has fallen.
- A defeat loses the run.
