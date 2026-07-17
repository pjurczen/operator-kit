# CONFIG — fill this in to adopt operator-kit

operator-kit ships generic. This file is the **one place** you bind it to your operation. The skills reference these values; fill them in (and delete the guidance once you have).

## 1 · Downstream repos
The repos the operator dispatches work to. `dispatch-handoff` / `monitor-handoff` operate on these; keep the same short-name list in [`scripts/monitor-status.sh`](scripts/monitor-status.sh) and [`.claude/references/monitors.md`](.claude/references/monitors.md).

| Repo | Role | Default branch | Lanes (if sharded) |
|---|---|---|---|
| `<org>/<repo>` | <what it implements> | `main` | unsharded (one worker) |

## 2 · Status view (work-stream status)
Where in-flight agent work is shown (see [`.claude/references/board.md`](.claude/references/board.md)). Pick one:
- **In-repo roadmap doc** — e.g. `docs/ROADMAP.md`, edited in place; **or**
- **Project board** — Asana / Linear / Jira / GitHub Projects (record workspace/team/project/board/list IDs + which one new dispatches land in).

This is the *agent-work* status view — keep it distinct from the human-task tracker (§3).

## 3 · Human-task tracker
Where the operator files **human** tasks (merge gates, decisions, external/infra actions) — see [`.claude/references/human-tasks.md`](.claude/references/human-tasks.md). **Never mirror agent-work status here.**
- **Tool:** <Asana / Linear / a shared list>
- **IDs:** <workspace / project / section / default assignee>

## 4 · Living status doc
The "read this first" snapshot `refresh-status` keeps current, and `operator-cycle` reads on Sense. **Holds the current objective.**
- **Path:** `<e.g. docs/STATUS.md>`
- **Cadence:** <e.g. weekly, or on material change>

## 5 · Decision log
The append-only record of *strategic* decisions (with the why + revisit date) that `operator-cycle` reads/writes.
- **Path:** `<e.g. docs/DECISION_LOG.md>`

## 6 · Opportunities backlog
Where `find-opportunities` writes its ranked, proposed backlog.
- **Path:** `<e.g. docs/OPPORTUNITIES.md>`

## 7 · Data sources (ground-truth)
Record your canonical read-only queries and their data-quality caveats in [`.claude/references/data-sources.md`](.claude/references/data-sources.md).

## 8 · Architectural invariants
Any constraints a change must preserve, that `write-handoff` encodes into every spec (a worker can't infer them).
- <e.g. "X is the source of truth; never extend Y">

## 9 · Worker plugin
Enable the worker side in each downstream repo:
1. Once per machine: `claude plugin marketplace add <org>/<this-repo>`
2. In each downstream repo's `.claude/settings.json`: `{ "enabledPlugins": { "operator-worker@operator-kit": true } }`
3. Create the contract labels in each repo: `bash scripts/bootstrap-labels.sh <org>/<repo>` (creates the whole canonical set from [`scripts/labels.psv`](scripts/labels.psv)).
4. Run a worker there:
   - Attended (a human driving): `/loop /operator-worker:work-queue`
   - Autonomous (unattended): `WORKER_MODE=autonomous claude`, then `/loop /operator-worker:work-queue`
   - Sharded (N workers on one repo): launch each with `WORKER_ID=<lane>` and lane-label every dispatch.
