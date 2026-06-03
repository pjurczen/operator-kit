# operator-kit

A Claude Code framework for an **AI operator**: a coordinator repo that turns strategy into dispatched **GitHub-issue tasks** for downstream **worker repos** — then watches them to PRs and keeps a status board in sync. All compute is local Claude Code (your subscription); **GitHub is just the queue, not GitHub Actions**.

It's the skeleton of a setup where one repo decides *what to do* and other repos *do it*, asynchronously, each as its own observable Claude Code session.

## The two sides

```
operator repo (this kit)                         downstream worker repos
─────────────────────────                        ───────────────────────
operator-cycle  (sense→decide→act→track)
   └─ implementing-feature                        operator-worker plugin
        ├─ write-handoff   → docs/handoffs/         └─ working-agent-tasks skill
        ├─ dispatch-handoff → GitHub issue ───────────► /work-queue  (run via /loop)
        └─ monitor-handoff  ◄── labels/PR ────────────  opens a PR, drives labels
   refresh-status (living status doc)
```

They meet **only** at a small **label + PR contract** (`agent-task` → `agent:in-progress` → `agent:in-review` / `agent:blocked`; the PR references the issue). The operator never dictates *how* a repo builds; the worker never needs to see the operator's strategy.

## What's in here
- **`.claude/skills/`** — the operator skills.
- **`.claude/references/`** — the task-board model and the ground-truth/data-sources pattern.
- **`.claude/hooks/` + `.claude/operator-orientation.md`** — a SessionStart hook that orients the operator each session.
- **`docs/OPERATOR_MODEL.md`** — the architecture and the contract (start here for the *why*).
- **`plugins/operator-worker/`** + **`.claude-plugin/marketplace.json`** — this repo is also a plugin **marketplace** that ships the downstream **worker** plugin.
- **`CONFIG.md`** — the one place you bind it to your operation.

## Adopt it
1. Use this repo as a template (or copy it) into your operator repo.
2. Fill in [`CONFIG.md`](CONFIG.md): your downstream repos, status board, status doc, decision log, data sources, architectural invariants.
3. Record your ground-truth queries in [`.claude/references/data-sources.md`](.claude/references/data-sources.md).
4. In each downstream repo: `claude plugin marketplace add <org>/<your-operator-repo>`, enable `operator-worker@operator-kit` in its `.claude/settings.json`, create the contract labels, and run a worker with `/loop /operator-worker:work-queue`.
5. Operate: run `operator-cycle` (or `/loop` it) and let it dispatch.

## Design notes
- **Subscription-billed, local, observable.** No CI-hosted or API-billed agents; each worker is a normal Claude Code session you can watch and interrupt.
- **The contract is the only coupling.** It has one source of truth (`OPERATOR_MODEL.md`); the worker plugin vendors it so it can't drift across repos.
- **Methodology stays local.** Each worker repo builds using its own framework — operator-kit pairs naturally with skill libraries like [playbooks](https://github.com/pjurczen/playbooks).

## License
MIT — see [LICENSE](LICENSE).
