---
name: dedup-before-dispatch
date: 2026-07-10
tags: [dispatch, triage]
---
# Search open and recently closed issues for the same problem before dispatching a fix

**What happened.** The operator dispatched a fix that a human had already started out of band, and a second time dispatched a duplicate of an issue closed the day before. Both collisions were invisible to the triage sweep because it only looked at agent-labelled issues.

**The rule.** Before any dispatch, search the target repo's open *and* recently closed issues for the same problem (`gh search issues`), and treat an assignment to a human as "theirs, do not dispatch". One problem, one issue.

**Where it landed.** `skill:dispatch-handoff` (pre-dispatch step); `skill:monitor-handoff` (triage disposition rules).
