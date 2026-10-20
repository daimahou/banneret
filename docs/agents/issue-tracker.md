# Issue tracker

Issues are Markdown notes in `tickets/`, one per node. No API: create = write the file; close = edit it in the same commit as the code.

## Layout

| Folder | Kind | Size | Template |
|---|---|---|---|
| `goals/` | Target; goals run concurrently | project | `goal.md` |
| `gates/` | Major step; sequential within its goal | weeks | `gate.md` |
| `milestones/` | One usable artifact; body = spec | days | `milestone.md` |
| `tasks/` | One work unit | hours | `ticket.md` |
| `bugs/` | Raw, then triaged | hours | `bug.md` |

- Filename = title. Kind = folder.
- Parenting hierarchy: Goal → Gate → Milestone → Task

## Frontmatter

- `triage` — see `triage-labels.md`
- `severity` — `major` · `minor` (bugs)
- `parent` — wikilink to node above
- `id` — number among its siblings, in narrative order
- `requires` — wikilinks to blocking **siblings** only
- `started` / `finished` — dates;

## Key

- Computed from `parent` ids, never stored. Shown as `Key` in `plan.base` / `tickets.base`.
- Format: `goal.gate-milestone.task`
  - `1.1` = goal 1, gate 1
  - `1.1-1` = milestone 1 of that gate
  - `1.1-1.1` = task 1 of that milestone
- `id` = where the player meets it, not build order.

## Structure

- `parent` = refinement tree = build order.
- `requires` joins siblings only. A cross-subtree dependency means the decomposition is wrong.
- State a dependency once, where branches divide; children inherit it.
- Grabbable = all `requires` finished (see `Blocked by` in `tickets.base`).

## Lifecycle

- No status field. Neither date = waiting; `started` = current; `finished` = closed; archived 3 days later.
- Never clear `started`.

## Closing

- The squash commit sets `finished`.
