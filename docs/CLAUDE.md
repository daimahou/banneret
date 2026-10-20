# Banneret — assistant rules

- `docs/` (this folder) = Obsidian vault: design docs, tickets, plans. Godot project = `../`.
- **Brevity.** Docs are short, bullet-first, to the point. No filler, no restating. The user must be able to read and edit them quickly.
- **Control output.** Don't create files, docs or features nobody asked for. Fewer, smaller changes.

## Tickets
- Every piece of work (including fast prototypes) gets a ticket. Rules: `agents/issue-tracker.md`.

## Git
- Repo root = `../` (one repo covering the Godot project and `docs/`).
- Never work on `main`. One branch per ticket: `<kind>/<id>-<slug>` (e.g. `proto/12-dash-combat`).
- Prototypes stay on their own branch, and are merged only if the user keeps them. Throwaway branches are deleted, never piled into one folder.
- Commit or merge only when asked.
