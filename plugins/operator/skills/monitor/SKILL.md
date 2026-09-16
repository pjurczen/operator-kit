---
name: monitor
description: The operator's watch-&-react poll — read the dispatched GitHub issues across downstream repos, reflect their state on the status view, triage worker-raised issues, proof-read merge gates, and surface anything a human must act on. Use to check on in-flight work, sync status, after every dispatch, or as the steady-state loop tick.
when_to_use: Checking in-flight/dispatched work ("what's the status", "any blockers", "sync the status view"), immediately after any dispatch, before ending a session with work in flight, and as cycle's sense step. NOT for dispatching (dispatch) or generating new work (opportunities).
allowed-tools:
  - Bash(gh issue list:*)
  - Bash(gh issue view:*)
  - Bash(gh issue edit:*)
  - Bash(gh issue close:*)
  - Bash(gh issue comment:*)
  - Bash(gh pr list:*)
  - Bash(gh pr view:*)
  - Bash(gh api repos/*)
  - Bash(bash scripts/operator:*)
---

# Monitor handoffs (watch & react)

Live monitor state (armed = present below; anything MISSING → arm from `.claude/references/monitors.md`):
!`bash scripts/operator monitor-status 2>/dev/null || echo "(monitors: run /operator:init, then list repos in .claude/operator.json)"`

Read dispatched-issue state, **reflect it on the status view** ([`board.md`](../../references/board.md)), and **surface every human action in the in-tick checklist** (`cycle` step 4). Contract: [`OPERATOR_MODEL.md`](../../docs/OPERATOR_MODEL.md).

Stance: **watch the issue, not the PR** — labels + closure + comments are the interface; PR/CI is the worker's lane, read **once per gate** (when `agent:in-review` appears) and when direct-polling merge state. **Be comment-aware** — load-bearing substance (corrections, deviations, questions, FYIs) lands as comments that fire no label monitor. Filter bot authors; skip your own echo (shared account). Arm monitors **only** from the canonical commands in `.claude/references/monitors.md`.

## Each pass
1. **Collect, from all directions, across ALL active repos:**
   - Unclaimed: open `agent-task` issues. In-flight: `agent:in-progress` / `agent:in-review` / `agent:blocked` + every issue behind an active roadmap item (a claim *removes* `agent-task` — an agent-task-only query goes blind past Dispatched).
   - **New comments since last pass** on every in-flight issue (per-issue last-seen timestamp) — a comment is as actionable as a label move: contract correction → propagate to design-of-record + specs; question → answer on the issue; deviation → judge it.
   - **All open issues regardless of label** + the `needs-triage` sweep — report the true per-repo open count, never just the agent-labelled slice.
   - **Lane-label check (sharded repos):** any open `agent-task` in a lane-sharded repo **without a `worker:<lane>` label is a mis-dispatch** — assign the lane on sight (claim-race + load-balance risk otherwise).
2. **Triage every `needs-triage` to a disposition** — read [`references/triage.md`](references/triage.md) now if any exist; label comes off this pass.
3. **Reflect state on the status view** as items move (dispatched → in progress → in review → done). Multi-issue items roll up: Blocked if any blocked; Done only when every issue is merged.
4. **Work the gates and blockers:**
   - `agent:blocked` → pull the blocking question from the latest comment, surface it with a recommendation (+ push if the human is away). A silently-blocked issue is the main failure mode.
   - `agent:in-review` → **read [`references/merge-gate.md`](references/merge-gate.md) now** and run its checks (direct-poll merged state, proof-in-PR, proof-scope vs blast radius, mock-consumer release gate, pipeline hops) before surfacing the merge-gate item — **including its stale-in-review operator fallback close-out** when the PR merged well before the worker's close-out and the worker is dead.
5. **Catch unfiled follow-ups.** A worker's "observed, not addressed" note or "happy to file" offer is a dead letter — get it filed as a `needs-triage` issue (nudge the worker or file it yourself); never downgrade it to a backlog note.
6. **Hard-flagged work: watch the tremors, not just the labels.** For work the design marked **hard** (spike-then-steer), the "watch the issue, not the PR" stance **inverts** — read the PR each pass for **degeneration signals**: interface/contract version churn, **patch accretion** (compensating guard / coercion / `ensure_*` commits piling up), scope ballooning past the plan. Those mean *the abstraction is failing* — surface **"design may be degenerating — re-steer or kill?"** to the human **mid-flight**, don't wait for the merge gate (by then it's the whole feature).

## After a merge
Reflect **Done**, clear the checklist item, then two questions on what shipped:
- **Consumer:** a new contract/endpoint/capability → *who consumes it?* A shipped producer with no consumer is unrealized value — route the consumer work unprompted.
- **Cold visitor:** a materially changed public surface → open it as a stranger; report the 5-second read (what is this / why over the obvious alternative / what next); failure → route a fix. For a user-facing **milestone**, run the fuller experiential audit (journeys, latency-as-felt, motion, stranger read) before calling it roadmap-Done.

## Don't
- Don't touch the work (no PR edits, no branch pushes) — you report and route; humans review and merge.
- Don't log routine status to the decision log — the issue + status view are the record.
- Don't stand up a mirror task board; the status view + checklist are canonical. (The human-task tracker carries **human** tasks only — never agent-work status; [`human-tasks.md`](../../references/human-tasks.md).)

## Disciplines
- Watch the issue; worker owns PR close-out.
- Comment-aware on both sides; canonical monitors only.
- Sweep all issues + all repos before any "nothing in flight".
- Verify state each pass; never assert from monitor silence.
- Triage to a disposition, not a pile.
- Follow-ups needing attention are filed issues, the same pass.
- An unrecorded "per your steer" is needs-confirm, not fact.
- Hard work: watch mid-flight tremors, re-steer before the merge gate.
