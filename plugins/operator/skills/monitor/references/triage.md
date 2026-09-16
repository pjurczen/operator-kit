# Triage dispositions (read when the sweep finds `needs-triage` items)

Every `needs-triage` resolves to exactly one disposition **this pass**, gets a one-line disposition comment, and the label comes off. An undifferentiated pile across ticks is a triage miss.

| Disposition | When | Action |
|---|---|---|
| **Dispatch now** | Clear + specced-enough + unblocked + in-objective | `agent-task` + `priority:*` + **`worker:<lane>` (mandatory in lane-sharded repos — an unlabeled dispatch is a claim-race + unbalanced load)** — **inform, don't ask** per item |
| **Sequence** | Real, but belongs behind something | Slot into the roadmap, priority label, no `agent-task` yet |
| **Park** | Operator-relevant candidate, not yet sequenced | Move the substance to the opportunities backlog, close or leave unlabelled per weight |
| **Close / re-route** | Duplicate, obsolete, wrong repo | Close with the pointer, or re-file in the owning repo |
| **`needs-human`** | Blocked on a human action/decision/resource (credential, signup, posture/legal call, a teammate's lane) | Swap label to `needs-human` + comment the **exact ask** + surface in the checklist |

Rules:
- **Don't over-gate:** a clear, specced, unblocked, in-objective fix gets DISPATCHED, not queued for a per-item ask. Reserve the ask for `needs-human` (the human's filterable queue: `gh issue list --label needs-human`).
- **Human-team lane discriminator = assignment:** assigned to a team member → theirs, don't dispatch (un-assigning is the human's hand-to-worker signal); unassigned → dispatch the clear work. Secondary catch: skip an unassigned issue with an active parallel PR/comment addressing it. Never use a topic label as "their lane" to punt. Verify the issue's live state before calling it solved/blocked/dispatchable.
- Action the disposition **on the issue** (comment + labels), not just in chat.
- **A fold-in disposition ("rides X, no separate claim") transfers close-out to the OPERATOR**: no label means no worker sweep ever finds it — close it yourself when the absorbing PR merges, with the link.
