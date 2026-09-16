---
name: dispatch-handoff
description: Dispatch a ready handoff spec to a downstream repo by opening a labeled GitHub issue (spec inlined) and reflecting it on the status view. Use to send/hand off already-specced work to a downstream repo — the moment a spec is settled and unblocked. Requires the spec in docs/handoffs/ (else write-handoff first).
when_to_use: Sending specced work downstream ("dispatch this", "open the issue for the worker", "release the queued item"). Requires the spec in docs/handoffs/. NOT for authoring specs (write-handoff) or watching dispatched work (monitor-handoff).
allowed-tools:
  - Bash(gh issue create:*)
  - Bash(gh issue edit:*)
  - Bash(gh issue list:*)
  - Bash(gh search issues:*)
  - Bash(bash scripts/bootstrap-labels.sh:*)
---

# Dispatch a handoff (open the GitHub issue)

Drop a ready spec into a downstream repo as a **GitHub issue** (the work queue) and reflect it on the **status view** (see [`board.md`](../../references/board.md)). You never run the work — the repo's own worker picks the issue up. Contract (labels, lifecycle, lanes): [`OPERATOR_MODEL.md`](../../../docs/OPERATOR_MODEL.md). All compute is local Claude Code; never GitHub Actions.

## Preconditions
1. **The spec exists** in `docs/handoffs/`. If not → `write-handoff` first.
2. **Auto-dispatch gate:** decided + specced + unblocked + in-roadmap → dispatch autonomously, no per-issue ask. **Still gate:** (a) undecided/unspecced work, (b) a large multi-issue burst (shared quota), (c) a brand-new repo/surface — and never auto-touch infra / data / money / external sends. The routine work around a dispatch (roadmap/doc updates) is always autonomous; don't bundle it into an ask.
3. **Labels exist in the target repo.** A brand-new repo has only GitHub defaults — run `bash scripts/bootstrap-labels.sh <org>/<repo>` to create the whole canonical set (idempotent), never just `agent-task`.
4. **A multi-issue chain is sequenced at dispatch, never left an unsorted pile:** order by dependency, priority label on **every** issue, `agent-task` only on the ready item(s) — flip each dependent as its blocker merges (the operator owns that hand-off). Post the build order on the lead issue. Do this even when the repo's worker isn't wired yet.
5. **Producer↔consumer split: sequence the *release*, not just the build.** Cross-link the issues; track the mock-built consumer as **"built, release-gated on `<producer>` E2E"**, never plain merge-ready ([`OPERATOR_MODEL.md`](../../../docs/OPERATOR_MODEL.md) §Lifecycle 4).
6. **Hard work dispatches spike-then-steer, not as one autonomous run.** If the design flagged the feature **hard**, dispatch the **spike** issue (`agent-task`) and keep the **full-build** issue **blocked on the human's post-spike steer** — a dependency chain: flip it to `agent-task` only after the steer clears. A wrong abstraction is invisible at the merge gate; the spike + steer is where it's caught.

## Steps
1. **Check idempotency** — search the target repo for an existing issue for this slug/title. Update, don't duplicate.
2. **Open the issue** — `gh issue create --repo <org>/<repo>` with title `[handoff] <slug>`, the **full spec text inlined** (the worker can't read this repo) + a backlink line (`Spec of record: <operator-repo>/docs/handoffs/<file>.md`), labels `agent-task` + `priority:*`.
   - **Sharded repo?** Also add `worker:<lane>` — lane assignment is the operator's, dependency-aware: dependents stay in their blocker's lane; independents spread across lanes by active count. Unsharded (default): no lane label. Registry: [`OPERATOR_MODEL.md`](../../../docs/OPERATOR_MODEL.md) §Lanes.
3. **Track it** — reflect the dispatch on the status view. Status stays honest: "Dispatched" only once `agent-task` is actually on the issue; authored-but-parked is Next/Blocked. A dispatch is never a decision-log entry (strategic calls only).
4. **Run a `monitor-handoff` pass immediately** — the worker can claim within minutes (removing `agent-task`), and scheduled ticks starve in long sessions; without the immediate pass your tracking drifts behind reality.

## Disciplines
- Sequence + priority-label the whole chain at dispatch.
- Lane routing is operator work, dependency-aware, never the human's.
- Mock-built consumer releases only on live-producer E2E.
- Act on the reversible; gate only the genuinely gated.
- Hard work dispatches spike-then-steer; the full build waits on the steer.
