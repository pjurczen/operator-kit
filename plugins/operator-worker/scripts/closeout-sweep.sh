#!/usr/bin/env bash
# closeout-sweep.sh — the worker's close-out reconcile, in one deterministic pass.
#
# The contract's terminal state is "issue closed = done": when a worker's PR merges, the
# worker must strip `agent:in-review`, close the issue, and reap the worktree. Two recurring
# misses this sweep surfaces:
#   1) agent:in-review issues across ALL states — a merged-PR issue can still be OPEN, or
#      already closed-but-still-labelled; --state all catches both (a label-only or
#      open-only query misses one). Reconcile each against its PR's merge state.
#   2) leftover git worktrees for already-finished work — reap any whose issue/PR is merged.
# Generic: pass the repo. Usage: closeout-sweep.sh <owner>/<repo>
set -euo pipefail
slug="${1:?usage: closeout-sweep.sh <owner>/<repo>}"

echo "== agent:in-review issues in $slug (state=all — reconcile each vs its PR) =="
gh issue list --repo "$slug" --label "agent:in-review" --state all \
  --json number,state,title \
  --jq '.[] | "#\(.number) [\(.state)] \(.title)"' 2>/dev/null || echo "(gh query failed)"

echo
echo "== git worktrees (reap any whose issue/PR is merged + closed) =="
git worktree list 2>/dev/null || echo "(no worktrees / not a git repo here)"
