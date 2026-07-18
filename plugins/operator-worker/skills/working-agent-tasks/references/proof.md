# Proof standards — what goes in the PR (read before opening any PR)

Run the spec's **Validation** — resolve the command from this repo's `CLAUDE.md` "how to verify" (tests / lint / type-check) plus the repo's own gates — and **paste the output into the PR**. "Implemented" or "lint passed" with no output is **not done**.

**The proof shows the change's effect as a before→after, and it lives IN the PR** — the reviewer reads it cold, later, with no session context. A chat message or a preview only you opened is a side-channel that's gone by review time. Fit the form to the change:

| Change type | Proof form |
|---|---|
| Code | A targeted test, **red→green** |
| Behavior / backend | The e2e or integration run **with the scenario described and the improvement over the prior state spelled out** — what was wrong/missing/slower before, what it does now. A bare "N passed" shows nothing changed; name the before and the after |
| UI / visual | **Before & after screenshots embedded in the PR body.** `gh`/PAT **can't** upload to GitHub's attachment CDN (web-UI-only) — embed headlessly: commit small images into the PR branch and reference them by raw URL. Chat-only screenshots don't count |
| Ops / config | The repo's check-script output |
| Nothing automatable | An explicit "no automated check applies because …" line — never fake one |

Rules:
- **If the check can't pass, set `agent:blocked`** with what failed — never open a green-looking PR over a red check.
- If a mechanism *blocks* landing the evidence in the PR, **say so on the issue** — a silent side-channel downgrade is how the gap stays unfixed.
- **Mock-built consumer of another service's contract = build-done, not release-ready.** Mark the PR **"mock-tested; E2E pending the real `<producer>` being live"**, and before it's release-ready run the **real** end-to-end check against the deployed producer (your build pointed at it, not the mock) — a mock-green PR can still mismatch the real contract.
