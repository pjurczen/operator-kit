#!/usr/bin/env bash
# bootstrap-labels.sh — create the canonical worker-contract labels in a downstream repo.
#
# A fresh repo ships with only GitHub's defaults, so the dispatcher must create the WHOLE
# set before dispatching (sequence-and-label-at-dispatch) — not just `agent-task`. Idempotent
# via `gh label create --force` (creates or updates).
#
# The label set lives in scripts/labels.psv (machine-readable source of truth; prose contract
# in docs/OPERATOR_MODEL.md — check.sh asserts the two stay in sync).
# Usage: bootstrap-labels.sh <owner>/<repo>
set -euo pipefail
slug="${1:?usage: bootstrap-labels.sh <owner>/<repo>}"
psv="$(dirname -- "$0")/labels.psv"
[ -f "$psv" ] || { echo "missing $psv" >&2; exit 1; }

grep -Ev '^\s*(#|$)' "$psv" | while IFS='|' read -r name color desc; do
  echo "ensuring label: $name (#$color)"
  gh label create "$name" --repo "$slug" --color "$color" --description "$desc" --force
done
echo "done: canonical worker-contract label set ensured in $slug"
