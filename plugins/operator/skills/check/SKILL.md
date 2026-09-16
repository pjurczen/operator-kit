---
name: check
description: Run the operator verify gate against this host repo (settings validity, permission rules, doc links, skill tool coverage, monitor wiring, operator.json) and report the result. Use before committing operator docs or after changing CONFIG, operator.json or the monitors.
allowed-tools:
  - Bash(bash scripts/operator:*)
---

# Verify gate

Run `bash scripts/operator check` and report its output verbatim: every `FAIL:` and `warn:` line with the one-line fix next to it, or `== ALL CHECKS PASSED ==`.

If `scripts/operator` is missing, stop and point at `/operator:init`; do not locate the plugin by hand.

Do not edit files to make a check pass unless asked — the gate is a report, not a repair.
