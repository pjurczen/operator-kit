---
name: find-opportunities
description: >
  The operator's generative engine — mines your live data sources (product analytics,
  usage/conversation logs, catalog/database density, error tracking, ad spend, SEO) for the
  highest-leverage openings and writes a ranked, evidenced opportunities backlog. Use to
  generate or refresh the backlog, line up work for an idle downstream worker, or as the
  periodic develop-pass. PROPOSES ONLY — never creates issues or dispatches; the human
  approves candidates into the roadmap.
when_to_use: '"refresh the backlog", "find opportunities", "line up work for the idle worker", the weekly develop-pass, or when Decide is short on candidates. NOT for "what should we do next" in general (operator-cycle owns that — its Decide step invokes this when candidates run short), executing decided work, or single-topic research.'
context: fork
---

# Find opportunities — the operator's generative engine

Sweep the live data for high-leverage openings, rank them against the current objective, and stage them as a ranked backlog the human can approve into the roadmap. Without this pass the operator only executes work that already exists — and idle workers starve.

## Hard guard — propose only
Read-only mining plus one artifact: an opportunities backlog doc (`docs/OPPORTUNITIES.md` by default). **Never** create GitHub issues, apply labels, or dispatch from here — an engine that dispatched its own ideas would self-widen the operator's authority (forbidden; `operator-retro`'s leash rule). Output = a proposal, full stop.

## 1. Sweep — one blind lens per source, in parallel
Ground first (prior opportunities, decisions, recent work) so the sweep extends rather than re-surfaces. Then one subagent per source, concurrent, each blind to the others; every candidate carries a real number from the live system. Queries + hygiene: [`data-sources.md`](../../references/data-sources.md). Adapt the lenses to your sources — common ones:
- **Product analytics** — funnel drop-offs, engagement gaps (apply the bot/crawler exclusion caveat).
- **Usage / conversation logs** — where users ask for something the product doesn't answer.
- **Catalog / database density** — thin areas, high-traffic-undercovered segments, missing key data.
- **Error tracking** — production errors degrading the experience.
- **Ad spend / SEO** — cheap-converting queries to lean into, wasted spend to cut, near-miss ranks. **Never auto-spend paid-API credits** — request a fresh export by name and skip the lens if none exists, noting the gap.

## 2. Verify the leads + dedup
A lens's number is a **lead, not a fact** — confirm each load-bearing claim against the source before it earns a place, especially the *semantics* (rows that exist ≠ items in a usable state). **Verify what ranks, before you rank it** — an unverified number never anchors a top slot; too costly to verify now → rank conservatively or park pending check. Negative results too: absence in one source is a lead — check the **system of record** before concluding "we don't have it". Then cut candidates already in-flight or done (open `agent-task` issues, the current backlog, recent decision-log entries).

## 3. Rank against the current objective
**State the objective you're ranking against in the doc header — pulled from the living status doc's current objective, never assumed.** Rank by how much each survivor advances *that* objective; tie-break with your strategy's decision framework + impact/effort.
- Off-objective finds go in **Parked**, not inflated to look like priorities.
- **The objective's biggest lever may not be data-minable** (outreach, a pilot, narrative) — if so, say it at the top; an honest "the buildable backlog isn't the main lever" beats a padded list.

## 4. Write + surface
Deepen the top 1–3 yourself, then refresh the backlog doc per [`references/opportunities-template.md`](references/opportunities-template.md) (read it now) and surface the top 3 with a recommended next dispatch. **Nothing dispatched.** Commit per `operator-cycle` → Track.

## Cadence & cost
Develop-speed: weekly or on-demand. Read-heavy — lean on the fork context; local, subscription-billed.

## Disciplines
- A subagent's number or status claim is a lead — verify at the primary source before ranking or relaying.
- Ground the sweep first; treat results as needs-confirm on load-bearing facts.
- Map levers honestly — name the non-buildable lever instead of padding the list.
