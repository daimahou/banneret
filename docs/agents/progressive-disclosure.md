# Progressive disclosure

How a note shows what is settled and what is still open: settled content goes in the body, open questions go in `> [!frontier]` or `> [!fog]` callouts.

## The body holds only what was agreed

Write the decision. Do not write the argument for it, the alternative it beat, the effort it will take, or the principle it illustrates — unless those were themselves agreed, in which case they are decisions and belong in the body like any other.

Minimalist, and formatted. A table instead of a paragraph enumerating rows, a wikilink instead of a sentence explaining where a thing is decided, an embed instead of a restated list, **bold** on the one word that carries the sentence. A body that reads as terse is correct. A body that reads as persuasive is not.

A count, a path, a filename, a frontmatter field — anything a reader would act on — comes from the source or from the human. Never from the shape of the sentence being written. Check it first. If it is not checkable from here, write the body without it and put the missing fact in a fog. Do not drop the sentence, and do not fill the slot: a guessed value reads as settled.

## Frontier or fog

**The test: can it be answered by deciding?**

- **Frontier** — yes. We have the material and understanding to decide now. Agents don't decide: they raise the question, and may put a provisional answer in the callout body.
- **Fog** — no. Given what we know, it can't be answered yet. It needs research, understanding or more work first.

```markdown
## Death

The player respawns at the last checkpoint.

> [!frontier] Does dying cost anything beyond lost ground?
> Provisional: no. Respawning is already the penalty.

> [!fog] Will checkpoint spacing feel fair, or punishing?
```

Both are design questions. The frontier can be decided today. The fog can't be answered until checkpoints exist and are play-tested, and its answer may reopen the frontier.

## Shared form

- About **this note's content**.
- One per callout. The title states the open point on one line; it need not be phrased as a question. What it needs to be read — the options, the lean, where the doubt came from — goes in the callout body. A body adds what the title lacks; never a paraphrase of it. Most callouts need none.
- **Keep the wording it came from.** A point already stated clearly in discussion goes in as stated. Never compress a clear sentence into a terse question to fit the form.
- Inline, directly under the section it belongs to. There is no `## Frontier` or `## Fog` section.

## Lifecycle

- **Frontier** — answering one is an edit: the answer moves into the body as a plain line, and the callout is deleted. A frontier never survives its own answer.
- **Fog** — a holding pen. Each one is eventually promoted to a frontier, answered into the body, moved to the note it belongs to, or deleted.

## The bar both must clear

A callout earns its place only if a careful reader of this note, its parent, and the goal could not already answer it. Delete on sight:

- **Answered above.** The note already states the answer. Asking again makes the note look less decided than it is.
- **Answered by default.** One obvious answer that no one would argue with is not a decision. Write it in the body as a plain line.
- **Derivable.** The answer follows from what the note already states. Compute it and write it. A question whose answer is a lookup wastes the human's attention, which is the scarce thing this whole model is protecting.
