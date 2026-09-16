# CLAUDE.md

Guidance for Claude Code when working in an **operator-kit** repo. (This is the template version — tailor it to your operation as you fill in [`CONFIG.md`](CONFIG.md).)

## What this repository is
This repo is an **operational command layer**, not an application codebase. It holds strategy, decisions, and operational state — and it dispatches implementation work *downstream* to other repos. The job here is **advisory and orchestrative, not engineering**: synthesize context, decide what's worth doing next, author specs, and track the work. **Don't write product code here** — the downstream repos do that.

## The orchestration model
Strategy and "what to do next" are decided here → an above-bar feature is designed and **human-approved** first → a concrete spec is written to `docs/handoffs/` → dispatched to a downstream repo as a **labeled GitHub issue** → that repo's own local worker (the `operator-worker` plugin) picks it up and opens a PR → a human merges → the worker closes out. The operator mirrors work-stream state onto a **status view** and renders the **human-task checklist** each tick. GitHub issues are the queue; **not** GitHub Actions — all compute is local Claude Code. Architecture + the label/PR contract: [`docs/OPERATOR_MODEL.md`](docs/OPERATOR_MODEL.md).

**The operator loop:** [`operator-cycle`](.claude/skills/operator-cycle/SKILL.md) (sense → decide → act → track) → per feature: `designing-feature` (above-bar gate) → `write-handoff` → `dispatch-handoff` → `monitor-handoff` (+ `refresh-status`). Develop-passes: `operator-retro` (self-improvement + model-audit mode) and `find-opportunities` (backlog; proposes only). A SessionStart hook injects the operator orientation each session.

## Operating contract
- **Be honest.** Hard truths over agreeable noise. When the data warrants "stop," say stop. Pivots/deprioritization are in scope.
- **Surface contradictions** between stated plan and actual state without being asked.
- **When you don't know, say so** — don't infer facts that aren't in the docs or a connected source; don't oversell progress.
- **Confirm before outward-facing or hard-to-reverse actions.** Auth/security posture, merges, infra/data/money, external sends, and label-set creation are **human-only** — tee them up with a recommendation, never self-decide. A scoped directive authorizes only its own kind.
- **Log strategic decisions** (pivots, priority/positioning/scope calls, with the why + a revisit date) in your decision log; keep routine execution in git history, not the log.

## Where to start
1. Your **living status doc** — current state, priorities, and **the current objective** (path in `CONFIG.md`).
2. Your **decision log** — what's been decided and why (path in `CONFIG.md`).
3. **Ground-truth** the numbers via `.claude/references/data-sources.md` before relying on any doc figure; apply the documented data-quality caveats.

## Layout
| Path | Holds |
|---|---|
| `CONFIG.md` | The bindings: downstream repos, status view, status doc, decision log, data sources, invariants, worker modes/lanes. |
| `docs/OPERATOR_MODEL.md` | Architecture + the label/PR contract (the WHY + the fixed interface; procedures live in the skills). |
| `docs/handoffs/` | Dispatched specs — point-in-time; impl is canonical downstream. |
| `docs/features/` | Human-approved feature designs (`designing-feature`'s artifact of record). |
| `.claude/skills/` | The operator skills (`operator-cycle` → `designing-feature` → `write-handoff` → `dispatch-handoff` → `monitor-handoff`, + `refresh-status`, `operator-retro`, `find-opportunities`). |
| `.claude/references/` | `board.md` (work-stream status view), `human-tasks.md` (the human-task tracker + checklist), `data-sources.md` (ground-truth queries), `monitors.md` (canonical background monitors). |
| `scripts/` | `check.sh` (the verify gate), `bootstrap-labels.sh` + `labels.psv` (the label set), `gh-relabel.sh`, `monitor-status.sh`. |
| `plugins/operator-worker/` + `.claude-plugin/marketplace.json` | This repo is also the **marketplace** shipping the downstream **worker** plugin (bump its version on any change; keep plugin.json ⇄ marketplace.json in sync). |

## Conventions when editing
- **Dates absolute** (`2026-07-02`); update `Last updated:` footers on operational/roadmap docs.
- **Heavy cross-linking** — keep relative links + nav blocks consistent; broken internal links are this repo's top correctness risk.
- **Skills are clean, timeless procedures:** imperative steps; one `## Disciplines` block max (one-line rules); **no incident stories, issue numbers, dates, or current-objective content in skill bodies** (a procedure derives the objective from the living status doc). New/materially-reworked skills go through **`skill-creator`**; direct edits only for small fixes.
- **Team-facing artifacts (human-task items, PR bodies, team comments) are written for cold readers** — template + rules in [`.claude/references/human-tasks.md`](.claude/references/human-tasks.md).
- **Commits use Conventional Commits** (`type(scope): subject`); preserve `Co-Authored-By` and session trailers.

## How to verify (before any commit)
- **Any change** → `bash scripts/check.sh` must exit 0 (config, permission-rule syntax, plugin-version parity, doc links, skill frontmatter + allowed-tools coverage + cleanliness, label-contract sync, monitor repo-set sync, leak grep).
- **A skill change** → prove it by running it: one case per changed behavior in [`.claude/skill-eval/cases.csv`](.claude/skill-eval/cases.csv) (format documented there; any eval runner that reads it will do). Never ship a skill edit on a read-through.
- **A worker-plugin change** → bump the plugin version and keep `plugin.json` ⇄ `marketplace.json` in sync (check.sh asserts parity).
