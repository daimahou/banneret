---
triage: ready-for-agent
id: "1.3-1.2.6"
parent: "[[Level-up offers]]"
requires:
  - "[[Skill acquisition]]"
started: 2026-11-14
finished:
hours:
---
The `levelup` debug command and the mid-fight pause: [[Level-up offers]].

# Done when

- `levelup` in the debug console opens the next level-up without a victory and advances the same count.
- The game pauses at once, like any game pause, even mid-action. While open, no time passes, nothing resolves and no action can be scheduled.
- Continue resumes the same fight once: timeline, health, AP and cooldowns preserved; skill choices and previews refresh.
- Rejected with a message when no run is playing or the run is between fights. The run ignores a request while a level-up is open. After the 37th level-up it reports completion and changes nothing.

## Implementation decisions

- The fight knows nothing of level-ups. The run pauses the scene tree, plays the level-up (its view processes while paused), unpauses, then tells the fight its characters changed. The command calls the run's exposed request.
- An action already playing out keeps the effects it was resolved with; only later actions see a level-up's changes.

## Testing decisions

- `DebugCommands`: a request opens the next level-up with the fight held still, a second request is ignored, Continue resumes the same fight with the pick applied and the count advanced; after the 37th nothing changes. Prior art: its existing tests.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
