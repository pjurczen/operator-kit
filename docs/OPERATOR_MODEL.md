# Operator model — orchestration via GitHub issues

**This doc is the architecture & rationale (the WHY/shape).** The executable workflow (the HOW) lives in the skills — [`operator-cycle`](../.claude/skills/operator-cycle/SKILL.md) (the loop) → [`implementing-feature`](../.claude/skills/implementing-feature/SKILL.md) → spokes `write-handoff` / `dispatch-handoff` / `monitor-handoff`. Procedures live in the skills; design and contract live here.

The operator is a **coordinator, not an implementer**. Its job is to turn strategy into **downstream GitHub issues** and to keep a **status board** in sync by **watching those issues and reacting** to their updates. *How* each downstream repo does the work is **opaque** to the operator — each repo runs its own local Claude Code worker; the operator relies only on a shared **label/PR contract** (below). All compute is local Claude Code (**subscription**); the GitHub API is free. **This is NOT GitHub Actions** — GitHub is just the queue.

## Operator scope — what the operator owns
- **Dispatch:** create GitHub issues in target repos from ready specs (`docs/handoffs/`).
- **Board management:** a **feature task** per feature, with a **subtask per issue** (a feature spans repos → many issues); mirror each from its issue/PR, and the parent rolls up.
- **Watch & react:** poll the issues it created, detect state changes, update the board, surface blockers.
- **Define the interface:** the label/PR contract that downstream workers honor.

**Out of scope (downstream):** *how* a repo picks up and executes an issue — its own loop, worktrees, concurrency, cleanup. The operator is agnostic to all of it.

## Why this shape (and what it rejects)
- ❌ **CI-hosted agent (e.g. a GitHub Action)** — typically bills as API tokens + CI minutes. Rejected: it doesn't run on your local Claude Code subscription.
- ❌ **Operator spawns nested agent subprocesses** — works, but each is a sub-process of the operator, not an independently observable session. Rejected: no independent visibility/control.
- ✅ **GitHub issues as the bus + independent local loops** — durable state, each worker its own visible session, async decoupling, all subscription-billed.

## The interface — the contract between operator and workers
The only thing both sides must agree on (everything else is private to each side):
- **Labels:** `agent-task` (claimable) → `agent:in-progress` (claimed) → `agent:in-review` (PR open) · `agent:blocked` (needs a human) · + a priority label (`priority:high` / `priority:medium` / `priority:low`).
- **The PR references the issue** (`Refs #N`); the PR is the work artifact.
- **Comments** carry progress and questions.
- **Issue closed = done.**

The operator *reads* these to drive the board; workers *write* these as they progress. Neither needs to know the other's internals.

## Diagram

```
┌──────────────── operator repo (coordinator) ─────────────────┐
│ sense → decide → act → track                                 │
│                                                              │
│ DISPATCH   open a GitHub issue (agent-task,                  │
│            spec inlined) + mirror on the board               │
│ WATCH      poll issues/PRs · update the board ·              │
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
