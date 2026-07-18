---
description: Advance this repo's operator-dispatched agent-task queue by one issue, via the working-agent-tasks skill. Run once for a single pass, or loop it — /loop /operator-worker:work-queue.
---

Do **one pass** of this repo's `agent-task` queue: invoke the **`working-agent-tasks`** skill and follow it for the next claimable issue (or the one you've already claimed).

The skill owns all the *how* — the contract, claiming, asking the operator, the branch/PR rules. This command only kicks off a single pass; wrap it in `/loop /operator-worker:work-queue` to run a continuous worker.

**Mode:** attended by default — the pipeline's design/plan/finish gates stop for the human driving the session. For an **unattended** continuous worker, export `WORKER_MODE=autonomous` so the loop self-resolves those gates instead of pausing at the first one. Sharded repo? Also export `WORKER_ID=<lane>`.

<!-- Ships in the operator-worker plugin (read-only). To customize for one repo, add a project-level `.claude/commands/work-queue.md` that shadows this one. -->
