---
requires:
  - "[[Warrior kit]]"
id: 1.2-2
former_ids:
  - 1.2-1.6
  - 1.2-1.7
deadline:
started:
finished:
hours: 0.2
parent: "[[First loop]]"
---

## Done when

- Every image lives in the folder of the code that uses it; `art/` is gone. Art a resource owns sits beside it: puppets and portraits beside their `hero/` and `enemy/` `.tres`, skill icons beside their skill.
- The rule is written down: a line in `gdscript conventions.md`, or an ADR.
- The warrior's puppet and portrait, rough but readable, at final size.
- The fight UI is drawn by hand, rough but readable, at final size.

## Implementation decisions

- Each `.png` moves with its `.import`, so its uid survives.
- Git LFS tracks by extension, so `.gitattributes` stays as it is.
- Art shared by several elements of the stage (background, front) goes to `stage/`.

## Open questions

- Convention line or ADR.

## Out of scope

- Redrawing any art but the warrior's and the fight UI's.
- Animation beyond what the stage already does.

## Tickets

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
