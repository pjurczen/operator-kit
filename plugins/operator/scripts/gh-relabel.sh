#!/usr/bin/env bash
# gh-relabel.sh — safe batch label editing for the operator dispatch pipeline.
#
# WHY: the Bash tool runs under zsh, which does NOT word-split unquoted parameter
# expansions — so `R="-R owner/repo"; gh issue edit 5 $R` sends `-R owner/repo` as
# ONE argument and fails ("unknown flag"). This helper runs under bash and builds
# the flag list as an array, so the footgun can't fire. Call it instead of writing
# ad-hoc `gh issue edit` loops.
#
# Usage: bash scripts/gh-relabel.sh <owner/repo> <add-csv|-> <remove-csv|-> <issue>...
#   dispatch : bash scripts/gh-relabel.sh <org>/<repo> worker:lane-1,agent-task needs-triage 793 792 797
#   triage   : bash scripts/gh-relabel.sh <org>/<repo> priority:medium - 785
#   move lane: bash scripts/gh-relabel.sh <org>/<repo> worker:lane-3 worker:lane-2 787 788
set -euo pipefail
[ "$#" -lt 4 ] && { echo "usage: gh-relabel.sh <owner/repo> <add-csv|-> <remove-csv|-> <issue>..." >&2; exit 2; }
repo="$1"; add="$2"; rm="$3"; shift 3
args=()
if [ "$add" != "-" ]; then IFS=',' read -ra A <<< "$add"; for l in "${A[@]}"; do args+=(--add-label "$l"); done; fi
if [ "$rm"  != "-" ]; then IFS=',' read -ra R <<< "$rm";  for l in "${R[@]}"; do args+=(--remove-label "$l"); done; fi
rc=0
for n in "$@"; do
  if gh issue edit "$n" -R "$repo" "${args[@]}" >/dev/null 2>&1; then echo "  ok  #$n"; else echo "  FAIL #$n"; rc=1; fi
done
exit "$rc"
