# Domain

- **`docs/agents/context.md`** — the glossary. Every term the project uses in a specific sense.
- **`docs/agents/adr/`** — one file per hard-to-reverse decision, `NNNN-kebab-title.md`.

## Reading

Read [[context|context]] before naming anything — a test, a class, a ticket.

Read the ADRs covering the area you are touching, once there are any. An ADR is binding until superseded; a change that contradicts one is a change that needs a new ADR, not a workaround.

## Writing

**Never add a term on your own initiative.** `/grill-with-docs` writes to [[context|context]], and so does any agent the human asks — but answering a question in conversation is not a reason to add a term, and neither is having just made a decision. Propose it and let the human say yes.

A term enters when it starts carrying weight — when it appears in a ticket title, a class name, or a spec.

### The rules

**Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others under _Avoid_.

**Keep definitions tight.** One or two sentences max. Define what it **is**, not what it does.

**Only terms specific to this project's context.** General programming concepts — timeouts, error types, utility patterns — do not belong, even where the project uses them extensively. Before adding a term, ask: is this a concept unique to this context, or a general programming concept? Only the former belongs.

**Group under subheadings when natural clusters emerge.** If all terms belong to one cohesive area, a flat list is fine.

## Writing an ADR

A decision becomes an ADR when reversing it later would mean rewriting code that already exists. `adr-format.md` has the bar and the template.

## Writing markdown in this vault

One line per paragraph — no hard wrapping. Obsidian reflows a file the moment it opens it, so a hard-wrapped document comes back as a whitespace-only diff and every real change afterwards is buried in re-wrap noise. This applies to every markdown file here: ADRs, `CONTEXT.md`, `CLAUDE.md`, tickets.