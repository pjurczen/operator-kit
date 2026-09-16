# CLAUDE.md

## What this repository is
An **operator host** for the `operator` plugin (operator-kit). It holds no product code. It holds the operator's **state**: `CONFIG.md` (how this operation is bound), `docs/features/` (designs), `docs/handoffs/` (specs, dispatched as GitHub issues), `docs/lessons/` (what we learned), the living status doc and decision log named in `CONFIG.md`. The skills, the operator↔worker contract and the scripts come from the plugin; run them as `/operator:<skill>` and `bash scripts/operator <script>`.

## Operating contract
- **Be honest** — hard truths over agreeable noise; recommending stop or pivot is expected.
- **Surface contradictions** between stated strategy and actual state, unprompted.
- **When you don't know, say so**; ground load-bearing claims on the docs and `docs/lessons/` first.
- **Human-only calls:** feature designs, dispatch of undecided work, merges, auth/security posture, infra/data/money, external sends — tee them up with a recommendation, never self-decide.
- **Log strategic decisions** in the decision log (path in `CONFIG.md`), never routine execution.

## Where to start (each session)
1. The living status doc (the current objective) and the decision log — paths in `CONFIG.md`.
2. The status view (in-flight work) — `CONFIG.md` §2.
3. `/operator:cycle` for "what should we do next"; `/operator:monitor` for a status check.

## Layout (host-owned)
`CONFIG.md` — the binding · `.claude/operator.json` — repos and marketplace (machine-readable) · `.claude/operator-orientation.md` — what the session-start hook injects · `.claude/references/data-sources.md`, `monitors.md` — ground-truth queries and the canonical monitors · `docs/features/`, `docs/handoffs/`, `docs/lessons/` · `.claude/skill-eval/` — cases for any skill you add locally · `scripts/operator` — the plugin launcher.

## Conventions
- Dates absolute (`2026-01-31`); update `Last updated:` footers on status/roadmap docs.
- Team-facing artifacts (human-task items, PR bodies, comments) are written for cold readers.
- Commits use Conventional Commits; preserve `Co-Authored-By` and session trailers.

## How to verify (before any commit)
`bash scripts/operator check` must exit 0 (or `/operator:check`). A local skill change is proven by running its cases in `.claude/skill-eval/cases.csv`, never shipped on a read-through.
