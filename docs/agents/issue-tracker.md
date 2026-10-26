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
- `hours` — active time in tenths of an hour, written by `tools/ticket_time.py` (see Time).
- `total_hours` — on a ticket with children: its `hours` and all its descendants'. Written by the same script.
- `extra_hours` — time worked outside any session (art, playtesting), added to `hours` by the script. Written only from the human's answer (see Time).

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

- `finished` is the human's ack that the work is done: the agent never sets it on its own judgment.
- A clear ack from the human (e.g. "done, merge") lets the agent fill in `finished` with that day's date. Without one, ask.
- It is set on the branch before the PR merges, so the squash commit carries it.
- At merge the agent runs `python3 tools/ticket_time.py --write` and commits the `hours` with `finished`.

## Time

- A leaf's `hours` = its spec and grill on `main`, and its branch.
- A note's `hours` = its breakdown on `main`.
- The active goal holds the overhead: work on `main` in no ticket (tracker, docs, tooling). Every ticket's `hours` sum to the project's active time.
- **A session works on a ticket only by committing to it.** Sessions run in parallel on unrelated work (mockups, research) count as overhead even on the ticket's branch, and every minute counts once: parallel sessions never multiply time.
- **Commit on `main` at each confirmed step, before going deeper**: a breakdown the human confirms, a grill once its spec is written. The commit carries a `Ticket: <id>` trailer naming the ticket the time goes to: the note broken down, or the leaf specced or grilled. Time on `main` since the previous commit goes to it; without a trailer, to the active goal.
- **Ask about breaks that look like work.** Sessions only log active time: a gap over 15 minutes is a break. When one sits inside otherwise continuous work — above all while waiting on the human for art, a playtest or a review — ask how long they worked and on which ticket, and add it to that ticket's `extra_hours`. Never guess a number. Ask once: a question left unanswered means it was a break. Check `python3 tools/ticket_time.py --gaps` before each commit on `main` and at each merge.
- Before every commit on `main`, run `python3 tools/ticket_time.py --write`, with `--ticket=<id>` when the commit carries a trailer, and commit the `hours` with it. The numbers change only on commit.
