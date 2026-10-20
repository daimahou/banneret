# ADR format

ADRs live in `docs/agents/adr/`, numbered sequentially: `0001-slug.md`, `0002-slug.md`. Scan the folder for the highest number and increment.

**Read this before writing one.** Most decisions are not ADRs, and an ADR that should not exist costs more than the one you skipped.

## When to write one

All three must be true:

1. **Hard to reverse.** Changing your mind later has a meaningful cost. If it is easy to reverse, skip it — you will just reverse it.
2. **Surprising without context.** A future reader looks at the code and wonders "why on earth did they do it this way?" If it is not surprising, nobody will wonder.
3. **The result of a real trade-off.** There were genuine alternatives and you picked one for specific reasons. If there was no alternative, there is nothing to record beyond "we did the obvious thing."

An ADR is about the **code**. A decision about how work is planned, tracked or split belongs in `agents/`, not here — a future reader hits it in the tracker, not in the codebase.

### What qualifies

- **Architectural shape.** "The write model is event-sourced, the read model is projected into Postgres."
- **Integration patterns between contexts.** "Ordering and Billing communicate via domain events, not synchronous HTTP."
- **Technology choices that carry lock-in.** Database, message bus, auth provider, deployment target. Not every library — only the ones that would take a quarter to swap out.
- **Boundary and scope decisions.** "Customer data is owned by the Customer context; other contexts reference it by ID only." The explicit no-s are as valuable as the yes-s.
- **Deliberate deviations from the obvious path.** "Manual SQL instead of an ORM, because X." Anything where a reasonable reader would assume the opposite — these stop the next engineer from "fixing" something that was deliberate.
- **Constraints not visible in the code.** "Response times must be under 200ms because of the partner API contract."
- **Rejected alternatives when the rejection is non-obvious.** If GraphQL was considered and REST won for subtle reasons, record it, or someone will suggest GraphQL again in six months.

## The template

```md
# {Short title of the decision}

{1-3 sentences: what's the context, what did we decide, and why.}
```

That is it. An ADR can be a single paragraph. The value is in recording *that* a decision was made and *why*, not in filling out sections.

## Optional sections

Only when they add genuine value. Most ADRs need none of them.

- **Status** frontmatter (`proposed | accepted | deprecated | superseded by ADR-NNNN`) — useful when decisions get revisited.
- **Considered Options** — only when the rejected alternatives are worth remembering.
- **Consequences** — only when non-obvious downstream effects need calling out.

## Amending

A decision that extends an existing ADR without contradicting it is an amendment to that ADR, not a new one — date the amendment in its Status line. A decision that contradicts one supersedes it, and that is a new ADR.
