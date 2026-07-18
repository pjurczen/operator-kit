---
name: raising-issues
description: Surface work you discovered but shouldn't do here — a cross-repo dependency, a follow-up, spun-off tech debt, a bug in another surface — by filing a self-contained GitHub issue labeled `needs-triage` in the owning repo, the same pass you found it. Use whenever, mid-task, you find work outside the current issue's scope, including anything you scope out or note as "observed, not addressed" in a PR. Never label it `agent-task`.
when_to_use: Discovered work that isn't the current issue's — cross-repo needs, follow-ups, residual bugs, scoped-out items. NOT for questions about your current issue (comment on it + agent:blocked if stuck).
---

# Raising issues (surface work, don't bury it)

**The one principle: you raise the *need*; the operator owns the *dispatch*.** The only reliable worker→operator channel is a GitHub issue the operator sweeps — a local note is a dead letter, and a self-`agent-task`'d issue jumps the triage queue and the human gate.

## How
1. **File it in the owning repo** (a backend gap a frontend task exposed → the backend repo; a follow-up to your own work → here; genuinely unsure → your own repo + say so, the operator re-routes).
2. **Self-contained body** — read with no access to your session: *what*, *why* (what breaks or is missing without it), *where* (link the originating issue/PR + files/symbols), enough for a fresh agent to scope it.
   **A failure report against a deployed env additionally states the image/sha it probed and whether a rollout was in flight** — an unstamped env failure wastes a diagnosis cycle (a probe racing a deploy looks like a bug).
3. **Label `needs-triage` ONLY** — never `agent-task` or `priority:*` (operator-only labels):
   ```bash
   gh issue create --repo <owner>/<owning-repo> --title "<outcome>" --label "needs-triage" \
     --body "<self-contained context> · Discovered while working <owner>/<this-repo>#<N>."
   ```
4. **Back-reference** — comment on your current issue: *"Raised <owner>/<repo>#<M> for <the need> — flagged `needs-triage`."*
5. **Don't act on it** — filing is the whole job; return to your claimed issue.

## The timing rule (the one failure this skill exists to prevent)
Anything you **scope out or notice** while building — a residual bug, a follow-up, an "observed, not addressed" PR note — is new work: **file it in the same pass, then link it** (`Raised #M`). *Noticing is not filing*; "happy to file a follow-up" is the anti-pattern — an attention-needing item left in PR prose dies there. **No "too minor to file" exception.**

## When it's NOT this skill
A question/blocker/decision about the issue you're **currently working** → an issue comment on it (+ `agent:blocked` if it stops you).
