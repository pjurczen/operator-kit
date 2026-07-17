---
name: refresh-status
description: Refresh the living status doc from verified live data — re-run the ground-truth queries and update the metrics, priorities, open issues, and date. Use on a regular cadence, or when the operation's state has materially changed.
when_to_use: The periodic status refresh, or when the operation's state has materially changed. It's the operator-cycle sense/track step made explicit. NOT for strategy changes (decision log) or generating new work (find-opportunities).
---

# Refresh the living status doc

Keep the **living status doc** (your "read this first" snapshot — see [`CONFIG.md`](../../../CONFIG.md) for its path) true to reality. It drifts fast; a stale snapshot produces stale advice, so re-derive from source rather than editing by memory.

## Do
1. **Pull verified numbers** via [`data-sources.md`](../../references/data-sources.md) — run the canonical, read-only queries and **apply the documented data-quality caveats** (exclude known-bad/bot/test data). Never carry the old doc figures forward unchecked.
2. **Check in-flight** — run `monitor-handoff` (or list open `agent-task` issues) so the snapshot reflects what's actually moving.
3. **Scan for state changes** worth recording — new health/error signals, external/coordination changes, anything that shifts the plan.
4. **Update the doc, in place:**
   - Metrics → the freshly verified figures; keep the *(verified YYYY-MM-DD)* annotation honest.
   - Top priorities + open issues → current reality; fill any `[UPDATE ME]` / `[confirm]` placeholders, don't leave them.
   - The `Last updated:` footer (absolute date).
5. **Report** what changed — especially any metric that moved materially, or a fresh contradiction with stated strategy.

## Don't
- **Don't fabricate.** If a source isn't reachable, say so in the doc rather than guess.
- **Don't quote polluted data** — apply the data-quality caveats in `data-sources.md` (e.g. exclude bot/crawler traffic) every time.
- **Don't rewrite the candid strategic reads** unless they actually changed — this refreshes *facts + current priorities*, not the strategy.
- **Don't log** the refresh in the decision log — that's for strategic decisions, not routine upkeep. (A material *finding* that changes the plan, though, may warrant its own strategic entry.)

## Boundaries
- This refreshes *facts*, not *strategy*. A changed number might prompt a strategic decision — that's `operator-cycle`'s job, logged in the decision log, not here.
- Keep the doc honest about uncertainty: mark figures you couldn't verify.
