---
name: working-agent-tasks
description: Pick up an operator-dispatched `agent-task` GitHub issue and carry it to a PR using THIS repo's own development methodology — claim it, drive the contract labels, and use issue comments to ask the operator anything you need. Use when running as a downstream worker processing agent-task issues in this repo (e.g. via the /work-queue command or a /loop).
---

# Working agent-task issues

You're a **worker** in a downstream repo. An **operator** repo dispatches work here as GitHub issues labeled **`agent-task`** and tracks them through a small **label + PR contract**. That contract is the *only* thing it dictates — **how** you build is entirely yours: your repo's framework, your branching, your worktrees, your review gates. The issue gives you the **goal and acceptance**; you own the path to a PR.

## The contract — the only fixed interface
The operator's status board mirrors these four things, so they can't drift. Everything else is your call.

- **Labels move:** `agent-task` (open, claimable) → `agent:in-progress` (claimed) → `agent:in-review` (PR open) · or `agent:blocked` (waiting on the operator / a human).
- **Your PR references the issue** (`Refs #N`, or `Closes #N` if it fully resolves it). The PR is the work artifact and the human merge gate.
- **Issue comments are your back-channel to the operator** — progress notes and any question you need answered.
- **The issue body is the goal** — its intent and acceptance criteria bound the work. Refine and design freely *within* that; if you'd step beyond it, ask first.

## Claim it
List the open `agent-task` issues. If one is already `agent:in-progress` and yours, continue it; otherwise take the highest-`priority:` open one — add `agent:in-progress`, **remove `agent-task`** (so it leaves the unclaimed queue), and self-assign. **One issue at a time per worker**, so two passes never collide on the same work.

## Do it your way
Fulfill the issue with **this repo's own methodology** — whatever development framework lives here, on whatever branch/worktree strategy you normally use. The operator doesn't watch any of this and doesn't want to; it only reads the contract back. When the work is ready for a human, open the PR (referencing the issue) and set `agent:in-review`.

## When you need the operator, ask on the issue
You run unattended, so there's no human at your terminal to interrupt. The issue thread *is* how you reach the operator (the operator agent on its monitor pass, or a human directly):

- Hit a real decision, ambiguity, missing access, or scope beyond the issue's intent? **Comment the specific question on the issue and set `agent:blocked`.** State the options and your recommendation so a one-line reply can unblock you.
- When an answer lands, clear `agent:blocked` → back to `agent:in-progress`, and carry on.
- Ask rather than guess on anything irreversible, cross-cutting, or out of scope. But routine implementation judgment is *yours* — don't set `agent:blocked` to ask permission to do your own job.

## Fixed rules
- **PRs only — never push to the default branch.** A human reviews and merges.
- **Local Claude Code only** (your subscription) — never an API-billed or Actions path.
- **Stay in your lane** — don't touch other repos or the operator's board; the operator mirrors your labels/PR into the board.
