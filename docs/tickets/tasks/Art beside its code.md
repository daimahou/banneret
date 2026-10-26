---
triage: ready-for-agent
id: 1.2-2.1
requires:
started: 2026-10-26
finished: 2026-10-26
hours: 0.1
parent: "[[Fight art]]"
---
# Done when

- Every image lives in the folder of the code that uses it; `art/` is gone.
- Art a resource owns sits beside it: puppets and portraits beside their `hero/` and `enemy/` `.tres`, skill icons beside their skill.
- The rule is written down: a line in `gdscript conventions.md`, or an ADR.

## Implementation decisions

- Each `.png` moves with its `.import`, so its uid survives.
- Git LFS tracks by extension, so `.gitattributes` stays as it is.
- Art shared by several elements of the stage (background, front) goes to `stage/`.
- A convention line, not an ADR: keeping art beside its code is the usual Godot layout, so it surprises no one.
- `knight.png` is used by nothing and is deleted.

## Out of scope

- Redrawing any art.

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
