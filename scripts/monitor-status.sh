#!/usr/bin/env bash
# monitor-status.sh — operator monitor reconcile, the deterministic "which are missing".
#
# For each canonical operator monitor marker, reports it MISSING unless BOTH:
#   (a) a process carrying that marker is live in `ps`, AND
#   (b) its heartbeat file is fresh (< STALE_AFTER s).
# (b) is the fix for the false-"OK": a ps-visible but wedged/silent monitor (a hung poll
# loop, or one whose output stopped reaching the session) leaves a stale/absent heartbeat
# and now reads MISSING → kill its PID + re-arm. The canonical commands in
# .claude/references/monitors.md write these heartbeats each loop; keep the repos list
# below in sync with them. Arming itself is a Monitor tool call (a script can't issue it).
#
# NOTE: the heartbeat proves the loop is alive; it can't prove GitHub calls succeed, and a
# rare "loop alive but stdout detached" case would still heartbeat. The per-tick explicit
# `gh issue list` sweep in monitor-handoff remains the authority — this check just stops a
# dead/wedged monitor from masquerading as healthy.
set -euo pipefail

# Active downstream repos — SHORT names (no owner/). Fill in for your operation and keep
# this in sync with the two canonical commands in .claude/references/monitors.md.
repos="repo-a repo-b"

set_seg="$(for r in $repos; do echo "${r##*/}"; done | sort | paste -sd+ -)"

HB_DIR="/tmp/operator-opmon"
STALE_AFTER=360   # s; heartbeat older than this (or absent) => wedged/dead => MISSING

ps_markers="$(ps -eo command | grep -oE 'OPMON:[A-Za-z0-9_.+:/-]+' | sort -u || true)"
now="$(date +%s)"

hb_age() {  # echo heartbeat age in seconds for monitor type $1 (999999 if absent)
  local hb="$HB_DIR/$1.hb" mt
  [ -f "$hb" ] || { echo 999999; return; }
  mt="$(stat -f %m "$hb" 2>/dev/null || stat -c %Y "$hb" 2>/dev/null || echo 0)"
  echo $(( now - mt ))
}

missing=""; total=0
for t in label comment; do
  total=$((total + 1))
  marker="OPMON:all:${t}:${set_seg}"
  if ! printf '%s\n' "$ps_markers" | grep -qxF "$marker"; then
    missing="${missing}${marker}"$'\n'
    continue
  fi
  age="$(hb_age "$t")"
  if [ "$age" -gt "$STALE_AFTER" ]; then
    missing="${missing}${marker}  (ps-visible but heartbeat ${age}s stale => wedged; kill its PID + re-arm)"$'\n'
  fi
done

if [ -z "$missing" ]; then
  echo "OK: all $total operator monitors running (heartbeats fresh)"
else
  echo "MISSING ($(printf '%s' "$missing" | grep -c .) of $total) — arm these from monitors.md:"
  printf '%s' "$missing"
fi
