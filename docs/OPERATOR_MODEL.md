# Operator model — orchestration via GitHub issues

**This doc is the architecture, rationale, and the operator↔worker contract (the WHY/shape + the fixed interface).** The executable workflow (the HOW) lives in the skills — [`operator-cycle`](../.claude/skills/operator-cycle/SKILL.md) (the loop) → `designing-feature` (above-bar) → `write-handoff` → `dispatch-handoff` → `monitor-handoff` (+ `refresh-status`, and the develop-passes `operator-retro` / `find-opportunities`). Procedures live in the skills; design and contract live here.

The operator is a **coordinator, not an implementer**. Its job is to turn strategy into **downstream GitHub issues** and to keep a **status view** in sync by **watching those issues and reacting** to their updates. *How* each downstream repo does the work is **opaque** to the operator — each repo runs its own local Claude Code worker; the operator relies only on a shared **label/PR contract** (below). All compute is local Claude Code (**subscription**); the GitHub API is free. **This is NOT GitHub Actions** — GitHub is just the queue.

## Operator scope — what the operator owns
- **Dispatch:** create GitHub issues in target repos from ready specs (`docs/handoffs/`), sole applier of `agent-task`.
- **Status of record:** keep the work-stream status view current as work moves (dispatched → in-progress → in-review → merged) — see [`board.md`](../.claude/references/board.md). **Human tasks are a separate surface** (see below) — never mirror agent-work status into it.
- **Watch & react:** poll the issues it created, detect state changes, reflect them in the status view, surface blockers + merge gates in the **human-task checklist**.
- **Define the interface:** the label/PR contract that downstream workers honor.

**Out of scope (downstream):** *how* a repo picks up and executes an issue — its own loop, worktrees, concurrency, cleanup, and its human checkpoints. The operator is agnostic to all of it.

## Why this shape (and what it rejects)
- ❌ **CI-hosted agent (e.g. a GitHub Action)** — typically bills as API tokens + CI minutes. Rejected: it doesn't run on your local Claude Code subscription.
- ❌ **Operator spawns nested agent subprocesses** — works, but each is a sub-process of the operator, not an independently observable session. Rejected: no independent visibility/control.
- ✅ **GitHub issues as the bus + independent local loops** — durable state, each worker its own visible session, async decoupling, all subscription-billed.

## The contract — the fixed interface between operator and workers
The only thing both sides must agree on (everything else is private to each side). **A change to this contract is a coordinated change:** update this doc + the [`operator-worker` plugin](../plugins/operator-worker/README.md) (version bump) + the operator skills together. Machine-readable label set: [`scripts/labels.psv`](../scripts/labels.psv) (`check.sh` asserts this table ↔ psv ↔ skill-usage stay in sync).

### Labels
| Label | Color | Meaning |
|---|---|---|
| `agent-task` | `#0052cc` | Claimable by a downstream worker |
| `agent:in-progress` | `#fbca04` | Worker has claimed and is building |
| `agent:in-review` | `#0e8a16` | PR open, awaiting human merge |
| `agent:blocked` | `#d73a4a` | Needs a human to unblock |
| `priority:high` | `#b60205` | High priority |
| `priority:medium` | `#d4a72c` | Medium priority |
| `priority:low` | `#c5def5` | Low priority |
| `needs-triage` | `#fbca04` | Worker→operator inbox flag (operator triages + applies contract labels) |
| `needs-human` | `#d93f0b` | Operator-triaged: blocked on a human action/decision/resource (the human's queue) |

Lane labels **`worker:<lane>`** (color `#5319e7`) are parametric — created per-repo only when sharding is enabled (a human-gated `gh label create`); see Lanes.

### Lifecycle
1. **Dispatch (operator only).** Sole applier of `agent-task`: issue opened with `agent-task` + a `priority:*` (+ `worker:<lane>` if the repo is sharded), spec inlined, status view updated.
2. **Claim (worker).** Add `agent:in-progress`, **remove `agent-task`**, stamp `worker:<lane>` if laned, self-assign. One issue per worker at a time.
3. **Build (worker, opaque).** The repo's own methodology. Questions/corrections/deviations go on the **issue as comments** — both sides are comment-aware. A hard wall → `agent:blocked` + a comment stating the question **and a recommendation**.
4. **PR (worker).** Body carries **`Closes #N`** (merge auto-closes; a bare `Refs #N` only for multi-PR issues) **and the proof** (before→after evidence appropriate to the change) — then `agent:in-review`. A mock-built cross-repo consumer may **merge** dark but its **release** is gated on the real producer live + integration E2E-verified.
5. **Merge (human).** A human reviews + merges; the operator proof-reads at the gate and never auto-merges.
6. **Close-out (worker primary / operator fallback).** Worker strips `agent:in-review`, ensures the issue is closed, posts a shipped-summary, reaps the worktree — reconciled every pass with `--state all`. **Fallback:** if the PR merged well before close-out happened and the worker session is dead, the operator strips the label, closes the issue, and posts a one-line fallback close-out; worktrees remain the worker's.
7. **Follow-ups (worker → operator).** Any attention-needing discovery is a **filed issue in the owning repo labeled `needs-triage` only** — never `agent-task`/`priority` (that jumps triage + the human gate), never a comment-only "happy to file". Each `monitor-handoff` pass triages every `needs-triage` to a disposition and strips the label; human-blocked ones become `needs-human` with the exact ask.

The operator *reads* these to drive the status view; workers *write* these as they progress. Neither needs to know the other's internals.

## Lanes (N workers on one repo)
Workers share one GitHub identity, so lanes shard the queue: each worker launches with `WORKER_ID=<lane>`, claims only its lane, stamps `worker:<lane>` (the per-worker ownership marker the shared account otherwise lacks). **All-or-nothing per repo** — one unsharded worker, or every worker laned and every dispatch lane-labelled. The operator assigns lanes at dispatch (dependency-aware; dependents stay in-lane). Keep a small active-lane registry (which repo runs which lanes) in [`CONFIG.md`](../CONFIG.md).

## Human tasks — a separate surface, never an agent-work mirror
**GitHub = agent work. A human-task tracker = human tasks** (merge gates, decisions, external/infra actions). The operator *creates* a task for anything only a human can do and *assigns* it to its owner; *completes* it when the item clears. **Never mirror GitHub agent-work status into the human-task tracker** — human tasks only. The operator's in-tick **human-task checklist** (`operator-cycle` step 4, five groups) is the per-tick rendering; the tracker is the persistent, team-visible store. Template + rules: [`human-tasks.md`](../.claude/references/human-tasks.md).

## Human-only decisions (never operator- or worker-decided)
Auth/security posture on any surface; public-contract membership (tools/endpoints/fields); merges; infra/data/money; external sends; label-set creation in a new repo; loosening any of the above. Route via `needs-human` (issues) or a human-task tracker item (non-issue actions), always with a recommendation.

## Diagram

```
┌──────────────── operator repo (coordinator) ─────────────────┐
│ sense → decide → act → track                                 │
│                                                              │
│ DISPATCH   open a GitHub issue (agent-task,                  │
│            spec inlined) + reflect on the status view        │
│ WATCH      poll issues/PRs · update the status view ·        │
│            surface agent:blocked · close on merge            │
└───────────────────┬──────────────────────────────────────────┘
                    │   operator creates the issue ↓  and polls it back ↑
                    ▼
┌─────────── GitHub issues = the contract / the bus ───────────┐
│ agent-task → agent:in-progress → agent:in-review             │
│ agent:blocked    ·    PR references the issue                │
└───────────────────┬──────────────────────────────────────────┘
                    │   consumed however the repo likes
                    ▼
┌────────── downstream repo (opaque to the operator) ──────────┐
│ its own local loop (operator-worker plugin)                  │
│ claims an agent-task issue, builds it, opens a               │
│ PR, and drives the contract labels                           │
└───────────────────┬──────────────────────────────────────────┘
                    ▼
        PR → a human reviews + merges → issue closed
```

## Why the issue carries the spec
Inlining the spec makes each issue self-contained — workers read only their own repo's issues (no cross-repo access into the operator repo, which also avoids exposing sensitive strategy). The canonical spec stays versioned in `docs/handoffs/`; the issue is the dispatched copy.

## Properties
- Subscription-billed only; GitHub API free; **not** CI/Actions.
- Decoupled / async; durable / resumable (all state in GitHub); each worker independently observable; PR-merge is the human gate; `agent:blocked` routes questions back.
- **Shared-quota caveat:** every loop (operator + each worker) draws on the one Claude Code subscription — a real ceiling, managed per-repo, not a model decision.

## The two sides
- **Operator side** (this repo): the skills in `.claude/skills/` + references + the SessionStart hook. Version-controlled here.
- **Worker side** (each downstream repo): the **`operator-worker` plugin** ([`../plugins/operator-worker/`](../plugins/operator-worker/README.md)), shipped from this repo's marketplace and enabled per downstream repo. The contract is its single source of truth — change it here, bump the plugin, `plugin update` the repos.
