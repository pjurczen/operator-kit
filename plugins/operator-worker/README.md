# operator-worker plugin

The **downstream worker side** of [operator-kit](../../README.md), packaged as a Claude Code plugin so every worker repo gets the same copy — versioned, updatable, and impossible to drift.

An **operator** repo dispatches work as GitHub issues labeled `agent-task`. This plugin is what a **downstream repo** uses to pick those up and turn them into PRs.

## What's inside
- **`working-agent-tasks` skill** — the label/PR contract + how to ask the operator questions. It deliberately **delegates *how to build*** to the repo's own framework. This is the fixed part — that's why it's vendored, not copied.
- **`/work-queue` command** — a thin loop driver. Run a worker with `/loop /operator-worker:work-queue`.

## Why a plugin (and not copies)
The worker side is identical across every downstream repo, so copying it would mean N copies to keep in sync. As a plugin:
- the **source of truth is one place** (the operator repo's marketplace), version-controlled;
- each worker repo **declares** it in `.claude/settings.json` (also version-controlled) — no copied files to rot;
- updates propagate with `claude plugin update`, and the shared **contract can't drift** because nobody hand-edits a local copy.

Customization isn't lost: *how you build* lives in each repo's own framework (not in the skill), and a repo that needs a different command can add a project-level `.claude/commands/work-queue.md` that shadows the plugin's.

## Enable it in a worker repo
The operator repo **is** the marketplace. Once, per machine:
```
claude plugin marketplace add <your-org>/<operator-repo>
```
Then enable it in the worker repo (commit this — it's the version-controlled record that the repo uses the plugin):
```jsonc
// <worker-repo>/.claude/settings.json
{ "enabledPlugins": { "operator-worker@operator-kit": true } }
```

## Run a worker
From the worker repo:
- **Self-paced:** `/loop /operator-worker:work-queue` — processes issues as they appear, idles when the queue is empty.
- **Fixed cadence:** `/loop 15m /operator-worker:work-queue`.
- One worker per repo at a time; loops are session-bound and subscription-billed (the machine must stay awake).

## The contract is canonical elsewhere
The label/PR contract this plugin honors has its single source of truth in the operator repo's [`docs/OPERATOR_MODEL.md`](../../docs/OPERATOR_MODEL.md). Change it there, bump this plugin's version, and `plugin update` the repos.
