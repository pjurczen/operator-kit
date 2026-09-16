# CONFIG — fill this in to adopt operator-kit

operator-kit ships generic. This file is the **one place** you bind it to your operation. The skills reference these values; fill them in (and delete the guidance once you have).

## 1 · Downstream repos
The repos the operator dispatches work to. `dispatch` / `monitor` operate on these; list the same repos, as full `org/repo` names, in `.claude/operator.json` (`repos`) — the launcher, the monitors and the verify gate read that file — and keep the two canonical markers in `.claude/references/monitors.md` in sync (short names sorted, joined with `+`).

| Repo | Role | Default branch | Lanes (if sharded) |
|---|---|---|---|
| `<org>/<repo>` | <what it implements> | `main` | unsharded (one worker) |

## 2 · Status view (work-stream status)
Where in-flight agent work is shown (see the operator plugin's `references/board.md`). Pick one:
- **In-repo roadmap doc** — e.g. `docs/ROADMAP.md`, edited in place; **or**
- **Project board** — Asana / Linear / Jira / GitHub Projects (record workspace/team/project/board/list IDs + which one new dispatches land in).

This is the *agent-work* status view — keep it distinct from the human-task tracker (§3).

## 3 · Human-task tracker
Where the operator files **human** tasks (merge gates, decisions, external/infra actions) — see the operator plugin's `references/human-tasks.md`. **Never mirror agent-work status here.**
- **Tool:** <Asana / Linear / a shared list>
- **IDs:** <workspace / project / section / default assignee>

## 4 · Living status doc
The "read this first" snapshot `status` keeps current, and `cycle` reads on Sense. **Holds the current objective.**
- **Path:** `<e.g. docs/STATUS.md>`
- **Cadence:** <e.g. weekly, or on material change>

## 5 · Decision log
The append-only record of *strategic* decisions (with the why + revisit date) that `cycle` reads/writes.
- **Path:** `<e.g. docs/DECISION_LOG.md>`

## 6 · Opportunities backlog
Where `opportunities` writes its ranked, proposed backlog.
- **Path:** `<e.g. docs/OPPORTUNITIES.md>`

## 7 · Data sources (ground-truth)
Record your canonical read-only queries and their data-quality caveats in `.claude/references/data-sources.md`.

## 8 · Architectural invariants
Any constraints a change must preserve, that `spec` encodes into every spec (a worker can't infer them).
- <e.g. "X is the source of truth; never extend Y">

## 9 · Plugins
Both sides install from the operator-kit marketplace.
1. Once per machine: `claude plugin marketplace add pjurczen/operator-kit`
2. This operator repo's `.claude/settings.json`: `{ "enabledPlugins": { "operator@operator-kit": true } }` — then `/operator:init` (already done if you are reading a scaffolded copy of this file).
3. Each downstream repo's `.claude/settings.json`: `{ "enabledPlugins": { "operator-worker@operator-kit": true } }`
4. Create the contract labels in each downstream repo: `bash scripts/operator bootstrap-labels <org>/<repo>` (the canonical set ships with the plugin).
5. Run a worker there:
   - Attended (a human driving): `/loop /operator-worker:work-queue`
   - Autonomous (unattended): `WORKER_MODE=autonomous claude`, then `/loop /operator-worker:work-queue`
   - Sharded (N workers on one repo): launch each with `WORKER_ID=<lane>` and lane-label every dispatch.
6. Update both plugins with `claude plugin update`; `scripts/operator` resolves the new install path on its next call.

## 10 · Sensitive directories
`/operator:init` merged one deny rule into `.claude/settings.json` as an example — `Read(./private/**)` — for a directory that must never reach a session's context (personal notes, exported transcripts, credentials). Point it at your own sensitive paths, or remove it; keep such directories gitignored as well, since a deny rule guards the session, not the repo.

## 11 · Knowledge store (optional)
By default the operator's knowledge is files: this repo's docs plus `docs/lessons/`, searched with `grep`. The disciplines — ground before asserting, fail-stop when central, write to the right place — are in the operator plugin's `references/knowledge-store.md`. To bind an MCP-backed store instead (example: the plugin's `examples/gbrain.md`), record:
- **Server name:** `<mcp server>` · **tools to allow-list:** `<search, query, get_page, put_page>`
- **Central?** `yes` → the operator halts when the store is unreachable; `no` → it degrades to files and says so
- **Indexes:** `<docs/ …>` (read-only) · **Owns:** `<lessons/, meetings/, people/ …>` (store-native)
