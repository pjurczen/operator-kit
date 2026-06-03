---
name: monitor-handoff
description: The operator's watch-&-react poll — read the dispatched GitHub issues/PRs across downstream repos and mirror their state into the board, surfacing anything blocked. Use to check on in-flight work, sync status, or as the operator's steady-state loop tick.
---

# Monitor handoffs (watch & react)

You dispatched issues; now keep the **board** honest by reading their state and reacting. You don't do the implementation work — you reflect it.

## Each pass
1. **Read** the dispatched issues + their PRs across your configured downstream repos (see [`CONFIG.md`](../../../CONFIG.md)) — by the `agent-task` / `agent:*` labels and linked PRs.
2. **Map** each issue's contract state onto its board subtask:

   | GitHub issue | board subtask |
   |---|---|
   | `agent-task` (open, unclaimed) | Dispatched |
   | `agent:in-progress` | In progress |
   | `agent:in-review` (PR open) | In review |
   | `agent:blocked` | Blocked (+ surface) |
   | closed (merged) | Done |

3. **Roll up the parent.** A feature task is **Blocked** if any child is blocked, **in progress/review** while work is underway, and **Done only when *every* child issue is done**. (See [`references/board.md`](../../references/board.md).)
4. **Surface blockers.** `agent:blocked` means a worker asked a question on the issue and is waiting. Bring it to the human (or answer it yourself if it's yours to answer) — then the worker clears the label and continues.

## Don'ts
- Don't touch the implementation, the worker's branches, or its PR (beyond review/merge, which is the human gate).
- Don't duplicate board tasks — match by the stored issue URL and update in place.
- Don't log routine state changes to the decision log; the issue + board *are* the record.
