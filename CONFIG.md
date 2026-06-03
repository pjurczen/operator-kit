# CONFIG — fill this in to adopt operator-kit

operator-kit ships generic. This file is the **one place** you bind it to your operation. The skills reference these values; fill them in (and delete the guidance once you have).

## 1 · Downstream repos
The repos the operator dispatches work to. `dispatch-handoff` / `monitor-handoff` operate on these.

| Repo | Role | Default branch |
|---|---|---|
| `<org>/<repo>` | <what it implements> | `main` |

## 2 · Status board
Where in-flight work is shown to humans (see [`.claude/references/board.md`](.claude/references/board.md)).
- **Tool:** <Asana / Linear / Jira / GitHub Projects>
- **IDs:** <workspace / team / project / board / list IDs>
- **Dispatch target:** <which project/board new dispatches land in>

## 3 · Living status doc
The "read this first" snapshot `refresh-status` keeps current, and `operator-cycle` reads on Sense.
- **Path:** `<e.g. docs/STATUS.md>`
- **Cadence:** <e.g. weekly, or on material change>

## 4 · Decision log
The append-only record of *strategic* decisions (with the why + revisit date) that `operator-cycle` reads/writes.
- **Path:** `<e.g. docs/DECISION_LOG.md>`

## 5 · Data sources (ground-truth)
Record your canonical read-only queries and their data-quality caveats in [`.claude/references/data-sources.md`](.claude/references/data-sources.md).

## 6 · Architectural invariants
Any constraints a change must preserve, that `write-handoff` should encode into every spec (a worker can't infer them).
- <e.g. "X is the source of truth; never extend Y">

## 7 · Worker plugin
Enable the worker side in each downstream repo:
1. Once per machine: `claude plugin marketplace add <org>/<this-repo>`
2. In each downstream repo's `.claude/settings.json`: `{ "enabledPlugins": { "operator-worker@operator-kit": true } }`
3. Run a worker there: `/loop /operator-worker:work-queue`
4. Create the contract labels in each repo: `agent-task`, `agent:in-progress`, `agent:in-review`, `agent:blocked`, `priority:high|medium|low`.
