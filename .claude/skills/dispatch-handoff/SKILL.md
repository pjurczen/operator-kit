---
name: dispatch-handoff
description: Dispatch a ready handoff spec to a downstream repo by opening a labeled GitHub issue (spec inlined) and creating a linked task on the board. Use to send/hand off already-specced work to a downstream repo; requires the spec to exist in docs/handoffs/.
---

# Dispatch a handoff (open the issue + board task)

Drop a ready spec into a downstream repo as a **GitHub issue** (the work queue) and mirror it as a **board task** (the human status view). You do **not** run code or launch the worker — that repo's own loop picks the issue up. GitHub issues are just the queue; **never** GitHub Actions or any API-billed path. Map: `implementing-feature`. Contract + rationale: [`docs/OPERATOR_MODEL.md`](../../../docs/OPERATOR_MODEL.md).

## Preconditions
1. The spec exists at `docs/handoffs/<file>.md`. If not → `write-handoff` first.
2. Target repo is one of your configured downstream repos (see [`CONFIG.md`](../../../CONFIG.md)).
3. The contract labels exist in that repo (`agent-task` + a `priority:` label). If missing, create them once via the GitHub tool — setup, not per-dispatch.
4. **Gate:** get a human's OK on each dispatch for now; auto-dispatch routine work later. Always gate anything touching infra, data, or money.

## Steps
1. **Open the GitHub issue** (GitHub MCP `issue_write`, or `gh`):
   - target repo from `CONFIG.md`
   - title: `[handoff] <slug>`
   - body: the **full spec text inlined** so the issue is self-contained (the worker has no access to this repo), plus a backlink line to the spec of record.
   - labels: `agent-task` + the priority label.
2. **Mirror on the board** — a feature can span repos, so model it as a **parent feature task + one subtask per issue** (see [`references/board.md`](../../references/board.md)):
   - Find the feature's parent task (create it only on the feature's *first* issue).
   - Add a subtask for *this* issue; store the **issue URL** on it (the idempotency key — don't duplicate a subtask that already carries it).
   - Back-link the board task URL into the issue → two-way link.

The **record of the dispatch is the issue + the linked board task** — don't add routine dispatches to your decision log (that's for strategic calls only).

## The contract you're writing into
You set `agent-task`. The downstream worker then drives `agent:in-progress` → `agent:in-review` / `agent:blocked`, references the issue from its PR, and closing the issue = done. `monitor-handoff` reads these back to keep the board in sync — you don't watch the work itself.

## Idempotency
Before creating either object, check whether an issue/board task for this slug already exists. **Update, don't duplicate.**
