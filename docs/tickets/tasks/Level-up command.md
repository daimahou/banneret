---
triage: ready-for-agent
id: "1.3-1.2.6"
parent: "[[Level-up offers]]"
requires:
  - "[[Skill acquisition]]"
started:
finished:
hours:
---
The `levelup` debug command and the mid-fight pause: [[Level-up offers]].

# Done when

- `levelup` in the debug console opens the next level-up without a victory and advances the same count.
- The fight pauses at a safe boundary: after the action being presented and resolved, or at once while the player is choosing. While open, no time passes, nothing resolves and no action can be scheduled.
- Continue resumes the same fight once: timeline, health, AP and cooldowns preserved; skill choices and previews refresh.
- Rejected with a message when no run is playing, the run is resetting, a request is pending or a level-up is open. After the 37th level-up it reports completion and changes nothing.
- A fight ending before the pause discards the request; victory then opens its own level-up, never two.

## Implementation decisions

- `FightController` accepts a level-up request and awaits it inside its loop; no second combat loop. The command calls the run's exposed request.

## Testing decisions

- `FightController` and `DebugCommands`: a request mid-action, while waiting, while open, and as the fight ends; resume preserves state and plays on once. Prior art: their existing tests.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
