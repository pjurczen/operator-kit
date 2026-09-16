# Feature designs

Human-approved feature designs the operator authors via `/operator:design` — the **artifact of record** for an above-bar feature (a new product surface, a new endpoint/data flow, cross-repo work, or anything touching auth/security/cost/data exposure).

- **The design is decided and approved here, before any spec.** `spec` derives per-repo specs *from* the approved design and cites it; `dispatch` opens the issues.
- **What a design holds:** the chosen approach (+ rejected ones, one line each on why not), the cross-repo seam/contract, the named tradeoffs (security/cost/data exposure), the measurement plan, the v1 boundary, and a hardness verdict.
- **Naming:** `YYYY-MM-DD-<slug>.md`.

This directory is scaffolded empty by `/operator:init` — your approved designs accumulate here.
