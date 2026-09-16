#!/usr/bin/env bash
# Kit-level verify gate: runs the operator plugin's check script in kit mode.
exec bash "$(dirname -- "$0")/../plugins/operator/scripts/check.sh" --kit "$@"
