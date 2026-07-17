# Board reference

Shared mechanics for the **work-stream status view** — used by `dispatch-handoff` (reflect the dispatch) and `monitor-handoff` (update it as work moves). It is the **agent-work status view**, mirrored from GitHub issue/PR state. It is *not* the source of truth — the issues are. It just makes in-flight work legible.

This is a **separate surface** from the human-task tracker ([`human-tasks.md`](human-tasks.md)): the board mirrors *agent-work status*; the human-task tracker holds *human actions only* and must **never** mirror agent-work status. Keep them distinct.

Implement the status view however fits your operation — an **in-repo roadmap doc** (edited in place, versioned) or a **project board** (Asana / Linear / Jira via its MCP server). Put your choice + concrete IDs/path in [`CONFIG.md`](../../CONFIG.md), not here.

## Model: one feature → many issues (1 : N)
A feature often spans repos (e.g. backend **and** frontend), so it's **one board task : many GitHub issues**, not 1:1:
- **Parent task = the feature** (what humans track).
- **One subtask per GitHub issue** (one per repo's work item); the subtask stores **its issue URL** — the idempotency key.
- Each issue back-links its subtask → two-way link.

**Dispatch idempotency:** find the feature's parent task first; create the parent only on the feature's *first* issue, then add a subtask per issue. Never duplicate a subtask that already carries an issue's URL.

## Status — the parent rolls up from its issues
Each subtask mirrors its issue's contract state:

| GitHub issue | subtask |
|---|---|
| `agent-task` (open) | Dispatched |
| `agent:in-progress` | In progress |
| `agent:in-review` (PR open) | In review |
| `agent:blocked` | Blocked (+ surface) |
| closed (merged) | Done |

**Parent = the rollup:** Blocked if *any* subtask is blocked · in progress/review while work is underway · **Done only when *every* subtask is Done.**

## Configure
Record your board's identifiers (workspace/team/project or board/list IDs) and any status-field conventions in [`CONFIG.md`](../../CONFIG.md). Never invent a target board silently — use the one your config names.
