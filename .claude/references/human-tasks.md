# Human-tasks reference — the operator-written human-task surface

**Model:** GitHub issues = agent work; a **human-task tracker = human tasks** — the operator *creates* a task for anything only a human can do and *assigns* it to its owner; *completes* it when the item clears. **Never mirror GitHub agent-work status into the tracker** — that mirror is dead weight that rots. The operator's in-tick five-group checklist (`operator-cycle` step 4) is the per-tick rendering; the tracker is the persistent, team-visible store.

Reference implementation is a task tool (Asana / Linear / Jira / a shared list) via its MCP server or API, but the model is tool-agnostic. Put your concrete IDs (workspace / project / section / assignee) in [`CONFIG.md`](../../CONFIG.md), not here.

## The in-tick checklist — five groups, every tick, whole
`operator-cycle` step 4 emits the human-task queue **every tick**, in this fixed format (empty groups render "—", never "all clear"):
- **🔀 Merge gate** — each in-review PR + verdict + base branch (a mock-built consumer → "release-gated", never plain merge-ready)
- **🤔 Decisions** — human calls teed up, each with a recommendation + link
- **🙋 Only you (external)** — outreach / legal / infra / deploys / sends
- **⛔ Blocked** — `agent:blocked` + the blocking question
- **🛠 In-flight** — status across ALL active repos (the operator pipeline ≠ a repo's human-team lane)

## What gets a tracker task
A NEW item in the checklist's human-actionable groups (Merge gate / Decisions / Only you) + **a Blocked item's human ask**. In-flight agent-work status **never** does. Completion is binary (mark complete when the item clears) — the sections are categories, not statuses; there is no status field to maintain. Assignee = ownership (default the operator's human unless the action is clearly another owner's). A `needs-human` GitHub issue stays the filterable *issue* queue; the tracker task carries the same ask for team visibility — link the issue, one task per issue, completed when the label clears.

## The task template — write for a COLD reader
The reader is a **teammate with zero operator context** — they open the task without the roadmap, the session, or the codenames. A task whose meaning needs operator shorthand is a failed task.

**Name:** the action, imperative, plain language, self-contained — a stranger understands it without opening the notes.

**Notes:**
```
Context: 2–3 plain sentences — what's happening and why this lands on you now.
Goal: the outcome this task achieves, one sentence.
What to do:
  1. concrete step (with its labeled link inline)
  2. ...
Done when: the observable check that closes the task.
Recommendation: (decision tasks only) the operator's rec + one-line why.
```

**Writing rules (each violation = rewrite):**
1. **No bare issue/PR numbers or codenames.** Every reference reads "`<repo>` PR — the concurrency fix" with the link; internal shorthand is spelled out in plain words or dropped.
2. **No arrow chains or fragments** ("webhook → rewire → go") — complete sentences; sequences become numbered steps.
3. **Self-contained:** if understanding requires the roadmap or another doc, inline the needed sentence — the link is for depth, not for basic comprehension.
4. **Updating an existing task? Verify its premises against current reality first** (is the surface now live? the gap already fixed? the ask superseded?) — rewrite to the present or complete it; never polish a stale premise into confident prose.
5. **Proper names sourced from auto-transcripts are needs-confirm.** Before a transcript-sourced name lands in a task, an assignment, or a person record: check it against known contacts, or flag it ("name per transcript — confirm").

## Mechanics
- **Dedup before create:** search the tracker (open tasks, text = the issue/PR number or slug). One task per item — update, don't duplicate.
- **Complete** the tick the item clears (merged / decided / sent). Stale-open tasks whose items vanished → verify against the primary source, then complete with a one-line note.
