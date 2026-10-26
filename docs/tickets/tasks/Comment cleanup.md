---
triage: ready-for-agent
id: 1.2-1.10
requires:
started: 2026-10-26
finished:
hours: 1
parent: "[[Warrior kit]]"
---
# Done when

- Every comment in the project's GDScript explains why, never what: a game rule, a reason, a gotcha, or a value's meaning (unit, space, order, what null or -1 means). Any other is deleted, or replaced by a rename or a restructure.
- A class header, the one place a *what* belongs, says the class's role in the architecture, without implementation details unless they matter there. A class whose name and folder make its role plain has none.
- A Comments section in `docs/agents/gdscript conventions.md` says exactly what qualifies and what does not, with bad → good pairs from this cleanup. The golden rule in `docs/CLAUDE.md` links to it.
- `docs/agents/feedback-loop.md` has a step before each commit: list the added comments (`git diff --cached | grep '^+\s*#'`) and tag each as rule, reason, gotcha, value or header, or delete it.
- Behaviour unchanged: the suite passes and the fight runner prints the same numbers.

## Decisions

- One PR: the conventions first, then one commit per folder.
- No length cap: a comment is judged by its content and its writing.
- Renames are allowed, except names a scene or a resource stores: signals connected in a `.tscn`, `@export` vars, `class_name`s a `.tres` names.

## Out of scope

- `addons/`, `tools/`.
- Shader comments stay: they help a reader new to shaders.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
