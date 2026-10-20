# Triage labels

The five canonical roles, each label equal to its name. Written to a ticket's `triage` front-matter field.

| Label | Meaning |
|---|---|
| `needs-triage` | Arrived raw. Not yet read. The template default. |
| `needs-info` | Cannot proceed until a human answers something. |
| `ready-for-agent` | Self-contained enough for `/implement` to start cold. |
| `ready-for-human` | Needs judgement, credentials, or a hand on the controller. |
| `wontfix` | Closed without work. |

`tickets.base` already filters on these strings — its Triage view collects empty, `needs-triage` and `needs-info`; its Archive view collects `wontfix`.

**Triage is only for issues you did not create.** Tickets that `/to-tickets` produced are agent-ready by construction; sending them through `/triage` re-litigates work already done.
