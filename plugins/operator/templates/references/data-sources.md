# Data sources (ground-truth)

The operator decides from **facts, not memory**. This file is where you record the **canonical, read-only queries** that re-derive the current state of your operation from live systems — so `status` and `cycle`'s Sense step can trust them instead of stale doc figures.

Fill this in for your operation (this is a template). For each source, record what it answers, the exact query/call, and any caveats.

## Template

### <Source name> — e.g. application database (read-only)
- **Answers:** e.g. "how many records / users / active entities do we have?"
- **How:** the exact MCP tool / SQL / API call (read-only).
- **Caveat:** anything that skews the number — and how to correct for it.

### <Analytics> — e.g. product analytics
- **Answers:** engagement, funnel, retention.
- **How:** the canonical query.
- **⚠️ Data-quality caveat:** document known pollution here. *Example pattern:* bot/crawler traffic can inflate analytics — exclude it (e.g. filter out known crawler channels) before reporting human engagement. Every operation has at least one of these; write yours down so it's applied consistently.

### <Issue tracker> — GitHub
- **Answers:** in-flight dispatched work — open `agent-task` issues, `agent:*` states, linked PRs across your downstream repos.
- **How:** GitHub MCP / `gh` queries by label across the repos listed in `CONFIG.md`.

## Rules
- **Read-only.** Ground-truthing never mutates anything.
- **Record the caveats.** The value of this file is the *corrections* — the gotchas that make a naive query lie. Capture them once; apply them every time.
- **If a source can't answer, say so.** Don't substitute a guess for a missing measurement.
