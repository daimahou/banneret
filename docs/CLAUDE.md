# Banneret — assistant rules

- `docs/` (this folder) = Obsidian vault: design docs, tickets, plans. Godot project = `../`.
- **Brevity.** Docs are short, bullet-first, to the point. No filler, no restating. The user must be able to read and edit them quickly.
- **Writing notes:** follow [[progressive-disclosure]] (body vs. frontier vs. fog).
- **Control output.** Don't create files, docs or features nobody asked for. Fewer, smaller changes.

## Git

- Repo root = `../` (one repo covering the Godot project and `docs/`).
- Never work on `main`. One branch per ticket: `<id>-<slug>` (e.g. `1.1-1.2-dash-combat`), squash-merged to `main`, then deleted.
- Exception: ticket authoring (tickets, their templates, the tracker rules) goes straight to `main` — no ticket, no branch.
- Prototypes stay on their own branch, and are merged only if the user keeps them. Throwaway branches are deleted, never piled into one folder.
- Commit or merge only when asked.

## Agent skills

### Issue tracker

Tickets live in `docs/tickets/` and are read and written by the vault's own rules. See [[issue-tracker]].

### Domain docs

Single-context, held in the vault. See @agents/domain.md.

### Grilling

A grill is always on a ticket that already exists. Read the ticket, its milestone and the design notes they link before the first question. Every question names a decision the code needs that those notes leave open; what they already settle is stated as settled, and the questions stay inside the ticket's scope.

## Code

**Read `docs/agents/gdscript conventions.md` before writing a script** - project code conventions.

**`docs/agents/feedback-loop.md` is how a change is checked** — the headless run, the gdUnit4 suite, the import scan.
