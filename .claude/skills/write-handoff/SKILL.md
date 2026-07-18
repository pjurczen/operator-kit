---
name: write-handoff
description: Author an implementation spec for a decided feature into docs/handoffs/ in the house format, ready to dispatch downstream. Use whenever a settled priority, approved design, or directed fix needs to become a concrete downstream task — before dispatching it.
when_to_use: Turning a decided feature/fix into a spec ("write the handoff", "spec this for the worker", "prepare the downstream task"). NOT for deciding whether to build (decision log), designing an above-bar feature (designing-feature runs first), or opening the issue (dispatch-handoff).
---

# Write a handoff spec

Turn a **decided** priority into a self-contained spec at `docs/handoffs/<YYYY-MM-DD>-<slug>.md`, ready for `dispatch-handoff`. You specify *what and why* — never *how to write the code*; the downstream worker owns the how. The spec gets **inlined into a GitHub issue** at dispatch, so it must stand alone.

## Preconditions (stop if unmet)
1. **The decision exists** (a decision-log entry or explicit direction). Not decided → settle that first; this skill doesn't decide.
2. **Above the design bar?** (per `designing-feature`'s bar) → a **human-approved design must exist** in `docs/features/`. Derive the spec from it and cite it — the design owns the cross-repo contract and named tradeoffs; the spec carries them to one repo.

## Procedure
1. **Ground** on related decisions, prior specs, and any number you'll cite via [`data-sources.md`](../../references/data-sources.md) — verified data, never stale doc figures.
2. **Mirror the existing analog.** If the feature has a likely analog in your repos (analytics wiring, auth, an integration, a UI pattern), find it and spec to it (`mirror <repo>/<path>`), not a generic approach. A "do it like `<repo>`" means the pattern exists — don't abandon the search on one flaky code-search result.
3. **Verify every inlined artifact live** — URLs, endpoint paths, field names, symbols, *including anything you tell the worker to change, remove, or **reuse*** (grep the **target** repo; your shorthand for a thing is not proof of its name or location). The worker builds on — and writes tests enforcing — whatever you assert.
4. **Write to the skeleton** — read [`references/spec-template.md`](references/spec-template.md) now and follow it, including its Validation and mock-consumer release-gate guidance.
5. **Bake your architectural discipline into Hard constraints** (below).
6. Output: the spec file. It's now ready for `dispatch-handoff`.

## Architectural discipline — the operator's value-add
- **Encode your architectural invariants** ([`CONFIG.md`](../../../CONFIG.md) §Architectural invariants) as Hard constraints — a worker can't infer them, so name them explicitly in every spec they touch.
- **Public / auth / token / data-exposure surface → name the security & identity/abuse implications**, even when the ask is "minimal friction" — the human makes the informed call.
- **Public-contract membership is decided in the spec** by its demanded consumer; "your call" delegation to the worker is for internals only (naming, modules, shape).
- **Cross-repo seams freeze as literals + contract tests, not prose.** Paired specs carry the seam's **exact wire literals** (header names, field names, event types), and each side's acceptance criteria **require a contract test pinning them**. A literal genuinely undecidable at spec time becomes an explicit **blocking reconciliation step** in the consumer's issue — never a "pending the final contract" note that can merge.
- **Cite decisions by link** (exact anchor) — an unlinked "as decided" invites a provenance dispute.

## Hard features ship as a spike-then-steer spec
If `designing-feature` flagged the feature **hard** (novel abstraction / no proven analog / robustness-risk), don't spec the whole build as one autonomous run — a wrong abstraction is invisible until it's the whole feature. Spec the **first deliverable as a thin vertical slice** that puts the risky seam under a *real* case, ending in an explicit **STOP — human steers before the full build**. The spike's Acceptance is "the abstraction held (evidence) / here's where it strains," **not** the finished feature; the full-build spec follows the steer.

## Disciplines
- Verify inlined artifacts against the live surface in the target repo.
- Mirror your existing repo patterns before speccing generic.
- Surface the security tradeoff on exposed surfaces.
- Public-contract membership is never worker-delegated.
- Mock-built consumer: build proof ≠ release proof; name the release-gate.
- Seams freeze as exact literals + contract tests on both sides.
- A spec's "use the existing X pattern" is a reuse claim — cost/verify it in the target repo.
- Hard features ship spike-then-steer, not one autonomous run.
