---
name: working-agent-tasks
description: Pick up an operator-dispatched `agent-task` GitHub issue and carry it to a merged, closed-out PR using THIS repo's own development methodology — claim it, drive the contract labels, prove the work in the PR, and use issue comments as the two-way channel to the operator. Use when running as a downstream worker processing agent-task issues in this repo (e.g. via the /work-queue command or a /loop).
when_to_use: Running as a downstream worker — /work-queue passes, claiming/continuing agent-task issues, close-out sweeps, reacting to operator comments. NOT for deciding what to build (the operator dispatches) or filing discovered work (raising-issues).
---

# Working agent-task issues

You're a **worker** in a downstream repo. An **operator** repo drops work here as GitHub issues labeled **`agent-task`** and tracks a small **label + PR contract** — that contract is the *only* thing it dictates; **how** you build is this repo's own methodology. The issue gives you the goal and acceptance; you own the path to a merged, closed-out PR.

## The contract — the only fixed interface
- **Labels move:** `agent-task` (claimable) → `agent:in-progress` (claimed) → `agent:in-review` (PR open) · `agent:blocked` (waiting on a human). Terminal: **PR merges → issue closed = done**, and landing that is *yours* (Close-out below). *(You'll also see `needs-triage` — the raise channel — and `needs-human` — the operator's escalation to a human; both are applied by others: you apply only the `agent:*` flow labels and file `needs-triage` via `raising-issues`.)*
- **Your PR closes the issue on merge** — **`Closes #N`** in the PR body (a bare `Refs #N` only when an issue genuinely spans several PRs; then close it from the finishing PR).
- **Issue comments are the two-way back-channel.** Outbound: progress + questions. Inbound: the operator/human may comment on your active issue **or your open PR** (merge-gate feedback lands there — a PR is an issue under a different number, so an issue-only watch misses it). **Act on what lands** — a correction reshapes the work; an answer unblocks it. A steer given to you out-of-band (typed into your session) is invisible to the operator — **echo it as an attributed issue comment**.
- **The issue body is the goal** — refine and design freely within its intent + acceptance; stepping beyond it → ask first.

## Claim
Read your lane from `$WORKER_ID` (unset = single-worker default, no lane filter; set, or `worker:*` labels visible → **read [`references/lanes.md`](references/lanes.md) first**):
```bash
gh issue list --label agent-task --state open ${WORKER_ID:+--label "worker:$WORKER_ID"} --json number,labels,title
```
Continue your in-progress issue or take the highest-`priority:*` open one. To claim: add `agent:in-progress`, **remove `agent-task`**, add `worker:$WORKER_ID` if laned, self-assign. **One issue at a time per worker.**

## Monitors — reconcile against `ps`, never blind-arm
Monitors die with the session / a resume and are invisible to `TaskList` — **reconcile each pass**: scan `ps` for the `WKMON:*` markers, arm only the missing, from the **canonical commands** in [`references/monitors.md`](references/monitors.md) (never improvise). The set: **`discovery`** (always — a new dispatch in your lane wakes an idle worker), **`comment:#N`** (your active issue AND each open in-review PR), **`merge:#PR`** (each open `agent:in-review` PR you own — fires the close-out), **`ci:#PR`** (one-shot, armed at PR-open + re-armed after every push — the first failing check is YOURS to fix before any human sees it). No Monitor tool → poll each pass + re-read comments at checkpoints.

## Operating mode — attended unless told otherwise
Read `$WORKER_MODE` (unset or `attended` → **attended**; `autonomous` → autonomous). It governs one thing: **who clears the methodology's gates** — design sign-off, plan approval, the finishing menu. Claim, the label contract, proof, close-out, and monitors are identical in both.
- **Attended** — a human is driving the session: stop at each pipeline gate and hand it over; never self-resolve a gate someone is present to decide. Routine in-the-weeds calls (naming, local trade-offs) stay yours.
- **Autonomous** — unattended `/loop` passes: resolve the gates yourself per **Autonomy** below; reserved for when no human is watching.

## Use this repo's methodology — mandatory, not optional
If this repo defines a planning/execution pipeline (its skills / `CLAUDE.md`, e.g. a library like playbooks), **run it for any non-trivial issue before exploring or writing code** — its human checkpoints follow your **operating mode** (above): `autonomous` resolves them itself; `attended` routes them to the human. **A detailed operator spec is the WHAT, not the planning** — don't skip the pipeline because the spec looks sufficient. The mandate covers **finishing** too: if the repo has a branch-finish/completion procedure, run it as the final build step **so its output lands in the PR** — the contract's push + PR + label steps **compose with, never replace, the repo's own finish** (and it must run at PR-open; the human merges async, after your pass ends).

## Prove it before you open the PR
**Read [`references/proof.md`](references/proof.md) now** — the proof forms per change type. The core rule: the evidence is a **before→after, pasted IN the PR**, for a reviewer reading cold; a red check means `agent:blocked`, never a green-looking PR. Then open the PR (**`Closes #N`** + proof) and set `agent:in-review`.

## Close it out when your PR merges
A human merges **after** your pass ends, so the close-out can't happen in the pass that opened the PR — and **`Closes #N` alone leaves the label on and no summary posted**. Two mechanisms, both yours:
1. **Event-driven:** the `merge:#PR` monitor fires on merge → remove `agent:in-review`, close the issue if it didn't auto-close, post the shipped-summary (if the PR body doesn't already tell it), **re-scan the issue + PR thread for any noted follow-up / cleanup-candidate / "observed" item and file each via `raising-issues` + link it** (notes written mid-build die at close-out, not mid-build), reap the worktree.
2. **The reconcile sweep — every pass, before claiming new work:** list `agent:in-review` issues **`--state all`** (closed ones are the classic miss) and finish any merged one's close-out + worktree cleanup. **Read [`references/footguns.md`](references/footguns.md)** for the sweep mechanics, worktree-reaping safety, and the known traps. `scripts/closeout-sweep.sh <owner>/<repo>` prints the sweep inputs in one pass.

Until you close out, the operator's status view reads a merged PR as still in-flight — close-out is the worker's job (the operator only falls back after a grace window if your session is dead).

## Autonomy — escalate only when you really must
**Autonomous mode:** default to deciding and proceeding — design choices, naming, trade-offs, and your methodology's clarifying/sign-off checkpoints are yours to resolve and record in the plan/PR. **Attended mode:** the pipeline's design/plan/finish gates go to the human (see Operating mode); you still make routine naming/trade-off calls and record them. In **both** modes, set `agent:blocked` **only** for: missing access/secrets you can't self-serve; irreversible/destructive actions (data/infra/money) the issue didn't clearly authorize; scope that contradicts or materially exceeds the issue's intent. When you block: comment the **specific question + options + your recommendation** (a one-line reply should unblock), then continue other work.

## Fixed rules
- **PRs only — never push to the default branch.** A human reviews and merges.
- **Local Claude Code only** (subscription) — never API-billed or Actions paths.
- **Stay in your lane for building.** The one sanctioned cross-repo action is **raising an issue** via the `raising-issues` skill: any discovered/out-of-scope/residual work that needs attention is a **filed `needs-triage` issue in the owning repo, this same pass, linked from your PR** (`Raised #M`) — never a local note, a PR-body mention, or a "happy to file" offer, with no "too minor" exception.
