# operator-kit

**Run a product team as a human-in-the-loop multi-agent workflow on Claude Code.** One operator session decides what to build and dispatches it; worker sessions in each downstream repo build it; GitHub issues are the queue; a human holds the gates. Two plugins, one marketplace.

## The problem it solves

A founder or lead with more scoped work than hands. Coding agents are cheap, but each one still needs the work scoped, sequenced, gated and closed out, and doing that by hand across several repos is a full-time job. operator-kit is the operating layer around the agents: an **operator** plugin that turns strategy into specs and labelled issues, a **worker** plugin that turns issues into pull requests, and a small **contract** between them so neither side needs to know how the other works.

## How it works

```
operator repo  (operator plugin)                 downstream repos  (operator-worker plugin)
────────────────────────────────                 ─────────────────────────────────────────
/operator:cycle  (sense→decide→act→track)
   ├─ design   (above-bar gate)                    working-agent-tasks skill
   ├─ spec     → docs/handoffs/                      ├─ /operator-worker:work-queue  (run via /loop)
   ├─ dispatch → GitHub issue ─────────────────────►  claims the issue, builds in a worktree,
   └─ monitor  ◄── labels / PR ──────────────────────  proves the change, opens a PR, closes out
   status · retro · opportunities · check            └─ raising-issues skill
```

The lifecycle at a glance:

| Label / event | Who | What happens |
|---|---|---|
| `agent-task` | operator | A ready spec is inlined into a GitHub issue in the target repo, sequenced and priority-labelled |
| `agent:in-progress` | worker | A worker session claims the issue, builds in a worktree, proves the change before opening a PR |
| `agent:blocked` | worker | The worker posts the blocking question with a recommendation; the operator surfaces it to the human |
| `agent:in-review` | human | The PR carries before/after evidence; a human reviews at the merge gate — agents never merge |
| close-out | worker, operator fallback | On merge the worker closes the issue with what shipped; if it is silent for ~2 h the operator closes it |
| `needs-triage` → `needs-human` | worker, operator | Workers file follow-ups as issues; the operator triages each to a disposition or to the human's queue |

Both sides meet only at that label and PR contract, defined once in [`plugins/operator/docs/OPERATOR_MODEL.md`](plugins/operator/docs/OPERATOR_MODEL.md) and vendored into the worker plugin so it cannot drift.

## What makes it different

- **GitHub issues are the queue, not CI.** No hosted agents, no API-billed runners. Every worker is an ordinary Claude Code session on a subscription that you can watch and interrupt.
- **The spec travels inside the issue.** A worker needs nothing from the operator's repo; the issue stands alone.
- **A contract, not a shared codebase.** Each repo builds with its own methodology (operator-kit pairs well with [playbooks](https://github.com/pjurczen/playbooks)). The operator never dictates how.
- **Human gates are explicit.** Feature designs, dispatch of undecided work, merges, and anything touching auth, infrastructure, data or money are human decisions, teed up with a recommendation and never self-approved.
- **Attended or autonomous.** A worker driven by a person routes its questions to that person; an unattended worker answers its own gates within the contract and escalates only showstoppers.
- **Plugins, not copies.** Both sides are versioned plugins; `claude plugin update` moves every operator and worker forward. Your operator repo holds only its state, scaffolded by `/operator:init`.
- **A verify gate.** `/operator:check` lints permissions, doc links, skill tool coverage and monitor wiring in your repo; the kit's own gate adds version parity, cleanliness rules and a leak grep.

## Quickstart

```
claude plugin marketplace add pjurczen/operator-kit
```

1. **Operator repo** (any repo that will hold your specs and decisions): enable the plugin in `.claude/settings.json` — `{ "enabledPlugins": { "operator@operator-kit": true } }` — then run `/operator:init`. It scaffolds `CONFIG.md`, `.claude/operator.json`, the orientation, references, `docs/{features,handoffs,lessons}/`, a skill-eval template, the `scripts/operator` launcher and the permission rules. Nothing is overwritten.
2. Fill in `CONFIG.md`, list your downstream repos in `.claude/operator.json`, and set the two canonical monitor markers in `.claude/references/monitors.md`.
3. **Each product repo:** enable `{ "enabledPlugins": { "operator-worker@operator-kit": true } }`, then from the operator repo create the contract labels: `bash scripts/operator bootstrap-labels <org>/<repo>`.
4. Run a worker in each product repo: `/loop /operator-worker:work-queue` (`WORKER_MODE=autonomous` for unattended, `WORKER_ID=<lane>` to shard).
5. In the operator repo: `/operator:check` until it is green, then `/operator:cycle` (or `/loop /operator:cycle`).

## What's inside

- **[`plugins/operator/`](plugins/operator/README.md)** — the operator skills (`cycle`, `design`, `spec`, `dispatch`, `monitor`, `retro`, `status`, `opportunities`, plus `init` and `check`), the session-start hook, the references, the contract doc, the scripts, and the templates `/operator:init` writes into your repo.
- **[`plugins/operator-worker/`](plugins/operator-worker/README.md)** — the worker command and skills that honour the contract in each product repo.
- **`scripts/check.sh`** — the kit's own gate (plugin-version parity, links, skill cleanliness, label-contract sync, leak grep).

## Skill evals and lessons

`/operator:init` scaffolds `.claude/skill-eval/cases.csv` for any skill you add locally, and `docs/lessons/` as the default knowledge store: when a retro finds a failure class, the lesson is written there and its rule lands in a skill or a check. When you want retrieval instead of `grep`, bind an MCP-backed store — [`plugins/operator/examples/gbrain.md`](plugins/operator/examples/gbrain.md) shows one — and the same disciplines apply ([`knowledge-store.md`](plugins/operator/references/knowledge-store.md)).

## Status

v0.4.0 (2026-09). **Breaking:** the operator side is now the `operator` plugin; using this repo as a template is retired — install the plugin and run `/operator:init`. Integrations with specific task trackers or knowledge stores are deliberately out of scope; `CONFIG.md` is where you bind your own.

## License

MIT — see [LICENSE](LICENSE).
