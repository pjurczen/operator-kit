# Handoffs

Implementation specs the operator authors and dispatches downstream. Each file here is a **self-contained spec** for one feature in one repo, written by `spec` and dispatched by `dispatch` (which inlines it into a GitHub issue).

- **Point-in-time, not canonical.** Once dispatched, the implementation detail becomes canonical in the **downstream repo**, next to its code — not here. A handoff is the brief, not the record of what shipped.
- **Naming:** `YYYY-MM-DD-<slug>.md`.
- **Self-contained:** no links back into this repo; the worker only ever sees the issue body.

This directory is scaffolded empty by `/operator:init` — your dispatched specs accumulate here.
