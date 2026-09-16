# operator-kit

**Run a product team as a human-in-the-loop multi-agent workflow on Claude Code.** One operator session decides what to build and dispatches it; worker sessions in each downstream repo build it; GitHub issues are the queue; a human holds the gates.

## The problem it solves

A founder or lead with more scoped work than hands. Coding agents are cheap, but each one still needs the work scoped, sequenced, gated and closed out, and doing that by hand across several repos is a full-time job. operator-kit is the operating layer around the agents: an **operator** that turns strategy into specs and labelled issues, a **worker plugin** that turns issues into pull requests, and a small **contract** between them so neither side needs to know how the other works.

## How it works

```
operator repo (this kit)                         downstream worker repos
─────────────────────────                        ───────────────────────
operator-cycle  (sense→decide→act→track)
   ├─ designing-feature (above-bar gate)          operator-worker plugin
   ├─ write-handoff   → docs/handoffs/              ├─ working-agent-tasks skill
   ├─ dispatch-handoff → GitHub issue ───────────────►  /work-queue  (run via /loop)
   └─ monitor-handoff  ◄── labels/PR ────────────────  opens a PR, drives labels, closes out
   refresh-status · operator-retro · find-opportunities   └─ raising-issues skill
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

Both sides meet only at that label and PR contract, defined once in [`docs/OPERATOR_MODEL.md`](docs/OPERATOR_MODEL.md) and vendored into the worker plugin so it cannot drift.

## What makes it different

- **GitHub issues are the queue, not CI.** No hosted agents, no API-billed runners. Every worker is an ordinary Claude Code session on a subscription that you can watch and interrupt.
- **The spec travels inside the issue.** A worker needs nothing from the operator's repo; the issue stands alone.
- **A contract, not a shared codebase.** Each repo builds with its own methodology (operator-kit pairs well with [playbooks](https://github.com/pjurczen/playbooks)). The operator never dictates how.
- **Human gates are explicit.** Feature designs, dispatch of undecided work, merges, and anything touching auth, infrastructure, data or money are human decisions, teed up with a recommendation and never self-approved.
- **Attended or autonomous.** A worker driven by a person routes its questions to that person; an unattended worker answers its own gates within the contract and escalates only showstoppers.
- **A verify gate for the operator itself.** `scripts/check.sh` lints permissions, plugin versions, doc links, skill frontmatter and cleanliness, label-contract sync, monitor wiring, and greps for anything that should not be in a public repo.

## Quickstart

1. Use this repo as a template (or copy it) into your operator repo.
2. Fill in [`CONFIG.md`](CONFIG.md): downstream repos, status view, human-task tracker, status doc, decision log, backlog, data sources, invariants.
3. Create the contract labels in each downstream repo: `bash scripts/bootstrap-labels.sh <org>/<repo>`.
4. In each downstream repo: `claude plugin marketplace add <org>/<your-operator-repo>`, enable `operator-worker@operator-kit` in its `.claude/settings.json`, then run a worker with `/loop /operator-worker:work-queue` (`WORKER_MODE=autonomous` for unattended, `WORKER_ID=<lane>` to shard).
5. In the operator repo, run `operator-cycle` (or `/loop` it). Run `bash scripts/check.sh` before any commit.

## What's inside

- **`.claude/skills/`** — the operator skills: the loop (`operator-cycle`), the per-feature pipeline (`designing-feature` → `write-handoff` → `dispatch-handoff` → `monitor-handoff`), plus `refresh-status`, `operator-retro` (self-improvement and model audit) and `find-opportunities` (backlog).
- **`.claude/references/`** — the status-view model, the human-task template and writing rules, the ground-truth pattern, the canonical background monitors, and the knowledge-store disciplines.
- **`.claude/hooks/session-start`** — orients every session and injects live state (date, monitor liveness, uncommitted drift).
- **`plugins/operator-worker/`** + **`.claude-plugin/marketplace.json`** — this repo is also a plugin marketplace that ships the worker side.
- **`scripts/`** — `check.sh` (the verify gate), the label set and bootstrap, monitor and relabel helpers.
- **`docs/`** — [`OPERATOR_MODEL.md`](docs/OPERATOR_MODEL.md) (the architecture, the contract and the rationale — start here for the why), `features/` and `handoffs/` templates, and `lessons/`.
- **`CONFIG.md`** — the one place you bind the kit to your operation.

## Skill evals

Skills are procedures, and a procedure change is proven by running it. [`.claude/skill-eval/cases.csv`](.claude/skill-eval/cases.csv) holds one case per behavior: whether a prompt should trigger the skill, a literal the answer must contain, or a rubric a judge answers from the transcript. The format is runner-agnostic; the [README there](.claude/skill-eval/README.md) explains a manual run.

## Lessons and knowledge (optional store)

When a retro finds a failure class, the lesson is written to [`docs/lessons/`](docs/lessons/README.md) and its rule lands in the owning skill or check. The operator grounds on that folder before asserting anything load-bearing. When you want retrieval instead of `grep`, bind an MCP-backed store — [`examples/gbrain.md`](examples/gbrain.md) shows one — and the same disciplines apply: ground before asserting, fail-stop when the store is central, keep canonical facts in git ([`knowledge-store.md`](.claude/references/knowledge-store.md)).

## Status

v0.3.0 (2026-09). Integrations with specific task trackers or knowledge stores are deliberately out of scope; `CONFIG.md` is where you bind your own.

## License

MIT — see [LICENSE](LICENSE).
