# Feature designs

Human-approved feature designs the operator authors via [`designing-feature`](../../.claude/skills/designing-feature/SKILL.md) — the **artifact of record** for an above-bar feature (a new product surface, a new endpoint/data flow, cross-repo work, or anything touching auth/security/cost/data exposure).

- **The design is decided and approved here, before any spec.** `write-handoff` derives per-repo specs *from* the approved design and cites it; `dispatch-handoff` opens the issues.
- **What a design holds:** the chosen approach (+ rejected ones, one line each on why not), the cross-repo seam/contract, the named tradeoffs (security/cost/data exposure), the measurement plan, the v1 boundary, and a hardness verdict.
- **Naming:** `YYYY-MM-DD-<slug>.md`.

This directory ships empty in the template — your approved designs accumulate here.
