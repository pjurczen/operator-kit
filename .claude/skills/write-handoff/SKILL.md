---
name: write-handoff
description: Author an implementation spec for a decided feature into docs/handoffs/ in the house format, ready to dispatch. Use when turning a settled priority into a concrete downstream task, before dispatching it.
---

# Write a handoff spec

Turn a decided feature into a **self-contained spec** a downstream worker can build from with no access to this repo. The spec gets **inlined into a GitHub issue** at dispatch, so it must stand alone.

Write it to `docs/handoffs/<YYYY-MM-DD>-<slug>.md`.

## House format
```
# <Title>

**For:** <target repo> · **Created:** <YYYY-MM-DD>
**Context:** why this, in 2-3 sentences. Link nothing this repo-private — restate what's needed.

## Goal
What "done" achieves, and why it matters. The intent that bounds the work.

## Scope
The concrete change. Specific enough to build, loose enough to let the repo
choose *how*. Name files/areas only if you genuinely know them.

## Acceptance
- [ ] Observable, checkable criteria. The worker self-verifies against these.

## Out of scope
What NOT to do — the boundary that turns "scope creep" into "ask first".
```

## Principles
- **Goal, not implementation.** State intent + acceptance; let the repo's own framework decide the how (that's the contract — see [`OPERATOR_MODEL.md`](../../../docs/OPERATOR_MODEL.md)).
- **Self-contained.** No links into this repo; the worker only sees the issue. Restate any context it needs.
- **Encode your project's invariants.** If your system has architectural constraints a change must preserve, state them explicitly in the spec — a worker can't infer them. (Keep these in [`CONFIG.md`](../../../CONFIG.md) so every spec applies them consistently.)
- **One spec per repo.** A feature spanning repos gets one spec each — they dispatch as separate issues under one feature task on the board.

Once the spec exists, hand off with `dispatch-handoff`.
