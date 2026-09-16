---
name: verify-state-dont-assert-from-monitor-silence
date: 2026-07-01
tags: [monitoring, merge-gate]
---
# Verify state each pass; never assert it from a monitor's silence

**What happened.** A label monitor had not fired for hours, and the operator relayed "awaiting merge" for a pull request that had merged that morning. Label and search feeds lag merges; silence meant *unobserved*, not *unchanged*, and the human acted on a stale gate.

**The rule.** Before relaying any gate status, direct-poll the primary source (`gh pr view --json state,mergedAt`) and read new comments since the last pass. A monitor's silence is never evidence.

**Where it landed.** `skill:monitor` (Sense step, merge-gate reference item 1); `reference:monitors.md` (heartbeat + staleness rule).
