---
name: refresh-status
description: Refresh the living status doc from verified live data — re-run the ground-truth queries and update the metrics, priorities, open issues, and date. Use on a regular cadence, or when the operation's state has materially changed.
---

# Refresh the status doc

Keep the **living status doc** (your "read this first" snapshot — see [`CONFIG.md`](../../../CONFIG.md) for its path) accurate. Stale numbers drive bad decisions, so re-derive them from source rather than editing by memory.

## Steps
1. **Re-run the ground-truth queries** in [`references/data-sources.md`](../../references/data-sources.md) against your live systems. Use the canonical, read-only queries recorded there — and apply any documented data-quality caveats (exclude known-bad/bot/test data).
2. **Update** the status doc's metrics, current priorities, in-flight work, and open issues to match what you found.
3. **Stamp the date** (absolute, e.g. `2026-01-15`) and fill any `[UPDATE ME]` / `[confirm]` placeholders rather than leaving them.
4. **Don't fabricate.** If a number isn't available from a connected source, say so explicitly instead of guessing. Accurate-but-incomplete beats confident-but-wrong.

## Boundaries
- This refreshes *facts*, not *strategy*. A changed number might prompt a strategic decision — that's `operator-cycle`'s job, logged in the decision log, not here.
- Keep the status doc honest about uncertainty: mark figures you couldn't verify.
