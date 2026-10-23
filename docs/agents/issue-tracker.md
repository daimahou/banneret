# Issue tracker

Issues are Markdown notes in `tickets/`, one per node. No API: create = write the file; close = the human sets `finished` (see Closing).

## Layout

| Folder | Kind | Size | Template |
|---|---|---|---|
| `goals/` | Target | project | `goal.md` |
| `gates/` | Major step; sequential within its goal | weeks | `gate.md` |
| `milestones/` | One usable artifact; body = spec | days | `milestone.md` |
| `tasks/` | One work unit; tasks and subtasks | leaf = one agent session | `ticket.md` |
| `bugs/` | Raw, then triaged | hours | `bug.md` |

- Filename = title. Kind = folder.
- Parenting hierarchy: Goal → Gate → Milestone → Task → Subtask…

## Authorship

- **Direction tickets** — goals, gates, milestones. The human authors them; the agent assists. Edit one only when asked, and only the part asked about. Never create, split, reorder or close one on your own initiative — propose instead.
- **Work tickets** — tasks (and subtasks), bugs. Agent territory: grilled, written, implemented and closed through the skills.

## Frontmatter

- `triage` — see `triage-labels.md`
- `severity` — `major` · `minor` (bugs)
- `parent` — wikilink to node above
- `id` — the node's key (see Key)
- `requires` — wikilinks to blocking **siblings** only
- `started` / `finished` — dates;

## Key

- Stored in `id`. Shown as `Key` in `plan.base` / `tickets.base`.
- Format: `goal.gate-milestone.task`
  - `1.1` = goal 1, gate 1
  - `1.1-1` = milestone 1 of that gate
  - `1.1-1.1` = task 1 of that milestone
  - `1.1-1.1.1` = subtask 1 of that task
- Parallel goal chains take a letter prefix: `M-1`, `A-1`.
- Numbers = where the player meets it, not build order.

## Structure

- `parent` = refinement tree = build order.
- `requires` joins siblings only. A cross-subtree dependency means the decomposition is wrong.
- State a dependency once, where branches divide; children inherit it.
- Grabbable = all `requires` finished (see `Blocked by` in `tickets.base`).
- **Plan breadth-first, build depth-first**: expand all children of the current node, open the first, revisit the remaining siblings on the way back up.
- A task too large for one agent session splits into subtasks **before** grilling. Only leaves are grilled and implemented.

## Lifecycle

- No status field. Neither date = waiting; `started` = current; `finished` = closed; archived 3 days later.
- Never clear `started`.

## Closing

- `finished` is the human's ack that the work is done: only the human sets it, never the agent.
- It is set on the branch before the PR merges, so the squash commit carries it. Not set at merge time → ask the human to set it first.
