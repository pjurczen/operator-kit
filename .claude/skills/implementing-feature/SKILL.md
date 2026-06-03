---
name: implementing-feature
description: The operator's map for getting a decided feature built downstream — author a spec, dispatch it as a GitHub issue, shepherd it to a merged PR, keep the board in sync. Use when building, dispatching, or handing off work to a downstream repo, or checking on in-flight work.
---

# Implementing a feature (downstream)

This skill is the **map**: the stages, and which **spoke skill / system / tool** to reach for at each. The actual procedures live in the spoke skills. Architecture + rationale: [`docs/OPERATOR_MODEL.md`](../../../docs/OPERATOR_MODEL.md).

You don't write the implementation — you turn a *decided* feature into downstream work and track it to done.

| Stage | Do | Reach for |
|---|---|---|
| **1 · Verify** | Confirm the feature is actually decided (in your decision log / status doc) and clear enough to spec. If not, decide it first (`operator-cycle`). | decision log, status doc |
| **2 · Write** | Author a self-contained implementation spec into `docs/handoffs/`. | `write-handoff` |
| **3 · Dispatch** | Open a labeled GitHub issue (spec inlined) in the target repo + mirror it on the board. | `dispatch-handoff` |
| **4 · Watch & react** | Poll the dispatched issues/PRs; mirror state to the board; surface blockers; answer questions on issues. | `monitor-handoff` |
| **5 · Gate** | A human reviews and merges the PR. You never auto-merge. | the reviewer |
| **6 · Close out** | On merge/close, mark the board done; log it only if it carried a strategic decision. | board, decision log |

**One feature can span repos → many issues (1 : N).** Write one spec per repo, dispatch one issue per repo, and track them under a single feature task on the board (it's done only when *every* child issue is). See [`references/board.md`](../../references/board.md).

**The boundary:** *how* a downstream repo executes its issue — its framework, branches, worktrees — is opaque to you. You only rely on the shared label/PR contract; the worker side (the `operator-worker` plugin) honors it.
