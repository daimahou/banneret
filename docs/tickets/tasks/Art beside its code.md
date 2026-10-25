---
triage: needs-info
id: 1.2-1.7
requires:
  - "[[Beat and cooldowns]]"
started:
finished:
hours: 0.2
parent: "[[Warrior kit]]"
---
# Done when

- Every image lives in the folder of the code that uses it; `art/` is gone.
- Art a resource owns sits beside it: puppets and portraits beside their `hero/` and `enemy/` `.tres`, skill icons beside their skill.
- The rule is written down: a line in `gdscript conventions.md`, or an ADR.

## Implementation decisions

- Each `.png` moves with its `.import`, so its uid survives.
- Git LFS tracks by extension, so `.gitattributes` stays as it is.
- Art shared by several elements of the stage (background, front) goes to `stage/`.

## Open questions

- Convention line or ADR.

## Out of scope

- Redrawing any art.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
