---
name: retro
description: The operator's self-improvement pass, two modes. DEFAULT (window/incident) — review what actually happened since the last retro (dispatched-work outcomes, blockers, idle capacity, human corrections, due bets) and turn lessons into committed fixes to the skills/references/CLAUDE.md/decision log. AUDIT mode — the periodic systemic self-audit of the operating model itself (coherence, assumption validity, obsolescence, reality-vs-prose). Use nightly/on-demand for the default; use audit mode after a model-changing decision, a refactor, a run of same-shape corrections, or monthly.
when_to_use: Nightly scheduled run ("run retro"), after a correction or a materially-wrong dispatched result (incident-scoped, run it then and there), judging due decision-log bets. AUDIT mode ("run the model audit/review") after model-changing decisions/refactors/correction-runs or monthly — never every tick. NOT for business-work review (that's the roadmap) or generating new work (opportunities).
---

# Operator retro — self-improvement (window/incident) + model audit

The operator improving the operator. The output is **edits, not a recap** — committed changes to skills, references, CLAUDE.md, and the decision log. **Every human-intervention is an autonomy bug to engineer away** (that's the trajectory: coordinator → autonomous). One genuine fix — or zero — is a fine pass; **don't pad**, don't pathologize normal transitional states (work parked on a prerequisite is expected), and confirm a failure is real + recurring before adding a rule.

**Mode routing:** default = the **window/incident** retro below. "Audit"/"model review" asks, a model-changing decision, a refactor, or ≥2–3 same-shape corrections → **audit mode** (§Audit). Incident-scoped runs diagnose + fix just that incident; the nightly run owns the full window (since the last retro's commits per `git log`; else the last several days).

## Window/incident mode
1. **Gather evidence:** dispatched-work outcomes across repos (merged / stalled / blocked / heavy-rework); idle workers beside claimable backlog (a triage miss, not quiet success); **every human-intervention point and why**; ungrounded operation (load-bearing claims asserted without checking); human corrections (git history + your notes/memory — a correction that never became a rule is itself a miss); due **Revisit** bets in the decision log; doc/roadmap drift vs the window's reality.
2. **Diagnose root cause, not symptom.** Verify the cause against cheap direct evidence (logs, status view, git) before fixing — a plausible cause is not the confirmed one. Sort: process/skill bug (fix here) · bet outcome (judge in the log) · one-off (don't over-fit a rule to a fluke).
3. **Fix — the output is edits:**
   - Skill/reference/CLAUDE.md changes that stop the failure **class**. Material skill reworks go through **`skill-creator`** (evals + trigger optimization; also the tool for eval-checking a skill that failed to fire); direct edits only for small targeted fixes. Vendored/worker skills stay generic (keep the cross-repo `operator-worker` skill free of any one repo's specifics); bump the plugin version when touched.
   - A session revealing a **repeatable process** worth reusing → author it as a skill via `skill-creator`, answering its questions yourself from the session; escalate only genuinely human-only calls. Keep the bar high.
   - **Land the operative rule** as a clean self-sufficient step in the owning skill (or CLAUDE.md for cross-cutting) — never the incident story; re-read the edited skill and strip leftover narrative; run `bash scripts/operator check` (the lint is the verification arm); prune rules a later decision made obsolete.
   - **A lesson lands three times:** story → `docs/lessons/` (or your knowledge store), rule → the owning skill or a check, pointer → memory — verify each landed ([`knowledge-store.md`](../../references/knowledge-store.md)).
   - Judge due bets in the decision log (verdict + reschedule/close the revisit).
   - Commit each fix as its own concern + push.
4. **Report crisply:** reviewed → changed (commits) → **what needs a human**, kept separate, never buried.

## Audit mode — the systemic self-audit
Audits the **model as a system** (skills + CLAUDE.md + references + orientation + their agreement with the decision log), not individual prose. Same edits-not-reports bar; a clean pass is a *clean bill of health*, not a wasted run — this cadence is the most tempting place to pad.
1. **Reality-test against actual behavior — the lead criterion.** Sample recent sessions (git history, decision log): did the operator *follow* each load-bearing skill or route around it and succeed anyway? **A skill consistently ignored-while-things-worked is wrong — not the operator.**
2. **Internal coherence.** For each load-bearing concept (tracking surfaces, dispatch gates, auth posture, the contract), verify every skill/doc/reference says the **same thing** — surface contradictions unprompted.
3. **Assumption validity.** List the foundational assumptions; ask of each: still true, or has reality moved? (A dependency framed optional but relied-upon; a "current" figure gone stale; a described workflow you no longer run.)
4. **Coverage & dead-weight.** A recurring improvised action with no skill, or a dead skill for a dropped workflow — both are drift.

**Self-bias guard (required):** anchor on behavior (criterion 1), and explicitly ask per concept: *"what load-bearing assumption am I rubber-stamping?"* Surface genuine model-doubts to the human — their challenge is the real forcing function. **When a failure flows operator→worker, audit the operator's OWN gates too — the failure that reached the worker passed through `design` / `spec` / `dispatch` / `monitor` first. Auditing only the downstream framework, and treating your own model as the neutral vantage point, is the miss.**

## Hard rule — never widen your own leash
Freely fix reversible, in-repo things and commit. **Never** autonomously expand your own authority (the `cycle` Gates; anything infra/data/money/external). Propose gate changes; never self-apply them.

## Cadence & cost
Develop-speed, never the watch tick. Window mode fires **nightly** (a scheduled local run) **and on-demand the moment a process miss surfaces** — depth is the lever, not frequency. Audit mode: signal-triggered or monthly. Local + subscription-billed only. Clean split: **retro fixes how-we-work; audit mode questions how-we-work-as-a-system; `opportunities` decides what to work on.**

## Disciplines
- Check the cheap evidence before asserting cause.
- A fix that's still silently violable isn't landed — guard the choke-point (a lint/sweep/close-out check).
- Land the operative rule clean; prune obsolete ones.
- The audit questions the model, not just the prose around it — audit your own gates too.
- Any realistic eval prompt is live ammunition — strip every side-effect channel before running one.
