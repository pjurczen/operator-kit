---
name: design
description: >
  Turn an intent for a non-trivial feature into a human-APPROVED design before any spec or
  dispatch — clarifying questions with proposed answers, 2–3 distinct approaches with
  trade-offs, a design doc in docs/features/, and an explicit human sign-off. Use whenever
  someone proposes or asks to design/build something that is a NEW product surface, a new
  endpoint or data flow, spans repos (needs a contract/seam), or touches auth/security/cost/
  data exposure — "we should build X", "make X real", "design X end to end" — even when the
  ask sounds settled enough to spec immediately. Runs BEFORE spec; do not jump from
  intent to handoff specs for above-bar work. Not for work below the bar (bug fixes, chores,
  UI increments inside an already-approved design) or features whose approved design already
  exists in docs/features/.
when_to_use: A NEW above-bar feature proposed ("we should build X", "make X real", "design X end to end"). Runs BEFORE spec. NOT for below-bar work (bug fixes, chores, UI increments in an approved design) or a feature already designed in docs/features/.
---

# Designing a feature — the approval gate before specs

Turn "we should build X" into a design the **human has actually approved**, *then* let
`spec` derive per-repo specs from it. The point: design decisions (auth model, data
flow, contracts, what's v1 vs deferred) are the **human's calls to make upfront** — not the
operator's calls to make silently and present as post-hoc veto items. A spec written before
the design conversation freezes those calls in the wrong order.

This is the **operator-level** design: the product **WHAT/WHY and the seams between repos**.
The downstream workers own the implementation HOW with their own design→plan methodology —
don't do their job here, and don't let this doc decay into implementation detail.

## Does this feature clear the bar?
Run this skill when the work is any of:
1. a **new product surface** (a page/window/tool a user meets for the first time),
2. a **new endpoint or data flow**,
3. **cross-repo** (two+ repos must agree on a contract),
4. **security / cost / identity / data-exposure relevant** (auth, tokens, spend, PII).

Below the bar — bug fixes, chores, copy/UI increments *inside* an already-approved design —
skip straight to `spec`. The bar cuts both ways: skipping design on an above-bar
feature hands the human faits accomplis; forcing design on a nav-link change taxes velocity
for nothing. When genuinely unsure, ask which side it's on — that one-liner is cheaper than
either mistake.

<HARD-GATE>
No "Decided" decision-log entry, no handoff spec, no dispatch, and no implementation artifact
for above-bar work until the human has approved the design — **including mid-loop.** The
operator never approves its own design: if a tick surfaces an above-bar feature, prepare the
proposal (steps 1–3), surface it as a human gate on the human-task queue, and park the lane.
Work other lanes; don't let the gate rot into a silent default.
</HARD-GATE>

## Steps

### 1. Ground
Pull what's already known before proposing anything: prior decisions in your decision log, lessons (`docs/lessons/` or your knowledge store),
`docs/features/` (does a design already cover this?), the roadmap + live repo state, and
ground-truth any number you'll lean on (`.claude/references/data-sources.md`).
If the intent bundles several independent features, say so and split — each gets its own pass.

### 2. Clarify — questions WITH proposed answers
Identify the decisions the design hinges on (purpose, users, constraints, success criteria,
v1 boundary — not implementation details). Put them to the human **batched, each with your
proposed answer and a one-line why** — concrete beats open-ended; the human adjusts a default
faster than they fill a blank. Use `AskUserQuestion` when interactive; a crisp checklist
message when not. Don't interrogate what grounding already answered.

### 3. Propose 2–3 genuinely distinct approaches
Not one approach and two strawmen — distinct shapes with real trade-offs (build cost, risk,
reversibility, what each forecloses). Lead with your recommendation and the reason.
Conversational, not a comparison matrix. Apply the operator lenses (below) here, where they
can still change the shape — not retroactively in the spec.

### 4. Human picks — then write the design doc
After the human picks/amends an approach, write `docs/features/<YYYY-MM-DD>-<slug>.md`:
- the **chosen approach** and the rejected ones (one line each on *why not*),
- the **cross-repo seam**: the frozen contract each repo builds against,
- the **named tradeoffs**: security/identity/abuse, cost, data exposure — surfaced, with the
  call that was made,
- **measurement**: what signal proves the feature worked (instrumentation implications, and
  how production signal stays distinguishable from dev/preview/test traffic),
- **v1 boundary + out-of-scope**, and open follow-ups.
- a **hardness verdict** — is this **hard** (a novel abstraction, no proven in-repo analog, or
  the robustness lens flagged degeneration risk)? A hard design ships **spike-then-steer**
  (`spec`): the first deliverable is a thin slice putting the risky seam under a real
  case, then a STOP for human steering before the full build. A bounded design (known shape,
  proven analog) dispatches normally.

### 5. Self-review, then the human review gate
Re-read fresh: placeholders/TBDs, internal contradictions, scope (one feature or several?),
ambiguity (any requirement readable two ways → pick one). Fix inline. Then ask the human to
review the written doc and **wait for explicit approval** — "looks good" in conversation is
not approval of the doc.

### 6. Hand off
Only now: log the strategic call in your decision log (linking the design doc), then
`spec` derives one spec per repo **from the approved design** (specs cite it), then
`dispatch`. If design conversation surfaced work for a human (infra, accounts), queue
it as human-task items.

## Operator lenses (apply during step 3, not after)
- **Encode your architectural invariants** — never a design that violates the constraints in
  `CONFIG.md` §Architectural invariants.
- **Security/cost named, not defaulted** — who can spend/see what; abuse limits; the lean
  option is allowed but only as an *informed* human call.
- **Seams frozen, internals free** — design the contract between repos tightly; leave each
  repo's internals to its worker.
- **Measurement is part of the design** — a probe feature that can't be measured isn't done;
  name how production signal stays separable from dev/preview/test.
- **YAGNI** — strip anything v1 doesn't need; record it as deferred, not designed.
- **Robustness — does the abstraction hold under load?** If the design puts an *unreliable
  component* on a load-bearing seam — an LLM at a generation/sampling boundary, a heuristic
  classifier, anything asked to *maintain* a structural property it can't guarantee — run the
  **failure-mode pass**: how does it degenerate under real load, and what's the deterministic
  alternative? If the honest answer is "we'd fence it with post-hoc patches," the abstraction
  is wrong — move the unreliable component **off** the structural boundary (make structure
  deterministic; use the model only for bounded content-fill).

## Don't
- Don't write or edit handoff specs, code, or issues before step 5's approval.
- Don't bury the design inside a spec — the design doc is the artifact of record.
- Don't re-run this for features whose approved design exists; amend that doc instead
  (material amendments re-gate on the human).
- Don't pad: a small above-bar feature gets a short doc; brevity isn't skipping.

## Disciplines
- On an open "should we / how build X", lead with the mapped option space, not one point.
- A "complete / end-to-end" ask gets the canonical dimension set in pass one, not piecemeal.
- Load-bearing "reuse X" claims are costed/verified against real code, never asserted.
- Keep unreliable components off load-bearing boundaries; hard designs ship spike-then-steer.
