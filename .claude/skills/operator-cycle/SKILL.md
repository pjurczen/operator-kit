---
name: operator-cycle
description: The operator's top-level autonomous loop — each tick senses current state, decides the next highest-value move, acts, and tracks outcomes, always emitting the human-task checklist. Use as the recurring operator tick, whenever asked "what should we do next", or to run operations.
when_to_use: Running operations, the recurring tick, "what should we do next", "run the loop", resuming operator work. Owns the general "what next" question — Decide invokes find-opportunities when candidates run short. NOT for a lone status check (monitor-handoff) or backlog generation alone (find-opportunities).
---

# Operator cycle — the autonomous loop

Live state at invocation (today's date; monitor liveness — arm anything MISSING from the canonical commands in [`monitors.md`](../../references/monitors.md), never from memory):
!`date +%F`
!`bash scripts/monitor-status.sh 2>/dev/null || echo "(monitors: fill in repos in scripts/monitor-status.sh)"`

One tick of running operations: **sense → decide → act → track**. Honest analysis over agreeable noise; surface contradictions unprompted; you coordinate — you never write product code. Contract: [`OPERATOR_MODEL.md`](../../../docs/OPERATOR_MODEL.md).

## 1. Sense
- Run **`monitor-handoff`** — in-flight state, comments, triage, merge gates, across ALL active repos.
- Read your **living status doc** (**the current objective lives here**) + recent **decision log** (context + Revisit-due entries). Paths in [`CONFIG.md`](../../../CONFIG.md).
- Ground the tick's focus in what's already known (prior decisions, features, handoffs) — once per new focus; re-ground on topic shift.
- **Ground the standing objective's defining metric — DERIVED from the living status doc's current objective, never a remembered metric name.** The metric moves when the objective moves; a stale named metric grounds nothing. A quiet tick is the *cue* to ground it, not an excuse to skip.
- Make sure `operator-retro` is scheduled to run nightly (a scheduled local run); re-create it if it's gone.

## 2. Decide
- Pull the next **ready** item from the roadmap — the committed sequence; don't re-derive "what's next" from strategy each tick.
- Reconcile stated priorities vs actual state; name drift and contradictions. **Separate verified state from inferred intent** — confirm before framing a human-gated item as slipping.
- Check **Revisit-due** decisions in the log — did the bet pay off?
- Short on candidates or capacity idle → run `find-opportunities` (proposes only; the human approves into the roadmap).
- Pick the **single highest-value next action**, with its why.

## 3. Act
- Build work: above the design bar → **`designing-feature`** first (human-approved design) → `write-handoff` → `dispatch-handoff` → **an immediate `monitor-handoff` pass**.
- **Fork on the hardness verdict:** bounded (known shape, proven analog) → dispatch + monitor as above; **hard** (novel abstraction / robustness-risk) → dispatch a **spike**, park the full build on the human's steer, and run `monitor-handoff`'s **tremor-watch** (not just label-watch) — the merge gate can't catch a wrong abstraction.
- **Gate polish/eval/tuning lanes behind *feature-complete***; parallelize BUILD freely — the test is "does the lane consume the finished surface?"
- Strategy/doc change → make it; a strategic call → log it.
- Needs a human → surface crisply **with a recommendation** and make the gate **turnkey** (runbook / draft / checklist — not just a flag); don't stall the tick on it.
- The wait reduces to one observable event → arm a Monitor on the **issue-level** signal (labels / closure / comments — never PR/CI); don't grind identical no-op ticks.
- Don't trust a scheduled tick to watch: run `monitor-handoff` after any dispatch **and** before ending a session with work in flight.

## 4. Track & commit
- **The human-task checklist is the tick's headline — emit it EVERY tick, whole, in this fixed format** (never "all clear", never "see above", even on quiet ticks). Empty groups render "—". Template + rules: [`human-tasks.md`](../../references/human-tasks.md):
  - **🔀 Merge gate** — each in-review PR + verdict + base branch (mock-built consumer → "release-gated", never merge-ready)
  - **🤔 Decisions** — human calls teed up, each with a recommendation + link
  - **🙋 Only you (external)** — outreach / legal / infra / deploys / sends
  - **⛔ Blocked** — `agent:blocked` + the blocking question
  - **🛠 In-flight** — status across ALL active repos (operator pipeline ≠ a repo's human-team lane)
- **Human tasks land in the human-task tracker** (create an assigned task for each NEW human-queue item; complete tasks whose items cleared). **Never mirror agent-work status there.** Author every task for a cold reader per [`human-tasks.md`](../../references/human-tasks.md). The checklist renders the queue; the tracker is the persistent store.
- Log **strategic** decisions only in the decision log. Material state change → update the living status doc (or `refresh-status` on cadence). Reflect roadmap statuses as items move.
- **Commit per concern** (never one lump; never a blind `git add -A`) and push if this repo is yours to push.

## Gates — the autonomy boundaries
- **Auto-dispatch** decided + specced + unblocked + in-roadmap work. **Gate:** undecided/unspecced work, large multi-issue bursts (shared quota), brand-new repos/surfaces.
- **Feature designs are never self-approved** — the `designing-feature` gate holds even when the human is away.
- **Never** auto-merge PRs or touch infra / data / money. **External sends** always human-gated.
- **Auth/security posture is never operator-decided** — tee it up with a recommendation, even when a worker asks mid-build; "the data is public anyway" goes in the proposal, not past the gate.
- **A scoped directive authorizes only its own kind** — "close the perf lane" / "close all" closes *that lane's* items; a product / design / strategy / auth decision that merely touches the lane outlives the cleanup → surface it as still-open, never resolve it as a byproduct, and never record a call as human-decided without an explicit human call.
- Committing + pushing this (operator-owned) repo is in-bounds.
- Genuinely unsure → stop and ask — but keep the rest of the tick moving.

## Cadence
The `/loop` tick or a scheduled local run — subscription-billed, never API/Actions. Develop-speed companions: `operator-retro` (nightly + on-demand the moment a process miss surfaces) and `find-opportunities` (weekly / on-demand).

## Disciplines
- Ground the objective-relative metric on quiet ticks.
- The checklist is the headline, every tick, whole.
- Every loop substep reports a visible outcome.
- Verify state; never assert from monitor silence.
- Sweep all repos before "nothing in flight".
- Check the cheap evidence before asserting cause/intent.
- Act on reversible work; don't over-ask or re-ask per item.
