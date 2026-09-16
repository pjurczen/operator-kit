# Handoff-spec skeleton (the house format)

File: `docs/handoffs/<YYYY-MM-DD>-<slug>.md`. The spec gets **inlined into a GitHub issue and read with no access to this repo** — inline everything the worker needs; never rely on it opening operations docs.

```markdown
# <Title>

**For:** the `<repo>` agent
**Created:** <YYYY-MM-DD>
**Decision:** <link to the decision-log entry / issue-comment ruling — the exact anchor>
**Source / context:** <links to the design/feature docs this derives from>

## Goal
<One paragraph: the outcome in product terms, and why it matters.>

## Scope (do exactly this)
<Numbered, concrete deliverables. Tight — one coherent slice.>

## Hard constraints
<Architectural / product guardrails the agent must honor — bake in the
architectural invariants from CONFIG.md; name them, don't assume they're inferable.>

## Out of scope
<Adjacent things to explicitly leave alone — the cheapest scope-creep prevention.>

## Acceptance
<Checklist of objectively checkable "done" conditions — verifiable, not vibes.>

## Validation
<The proof the worker must run and **paste into the PR** — the *form* (passing
automated test red→green / before-after API response / SQL result / migration
dry-run) and *what it must show*. State the outcome, not the exact command —
the worker resolves commands from its repo's CLAUDE.md "how to verify".
If nothing is automatable, say so and why.>
```

Section guidance:
- **Goal** answers "why does this matter" in product terms — a worker that understands the why makes better micro-decisions.
- **Scope** is one coherent slice for ONE repo. A feature spanning repos → a separate spec per repo, dispatched as separate issues, tracked as one roadmap item.
- **Hard constraints** carry the operator's architectural discipline (SKILL.md §Architectural discipline) — that's the operator's value-add over a bare feature request.
- **Validation, mock-built cross-repo consumer:** split *build* proof from *release* proof — (a) name the producer dependency (repo/endpoint/contract), (b) set the release-gate ("do not release to prod until `<producer>` is live AND the real integration is E2E-verified"), (c) require a release proof against the **real** producer. Mock-tested = build-done, not release-ready. Contract: `docs/OPERATOR_MODEL.md` §Lifecycle 4.
- Tell the agent: **"when unsure, stop and leave a PR note"** — surface ambiguity rather than guess.
