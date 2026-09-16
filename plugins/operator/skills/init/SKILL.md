---
name: init
description: Scaffold this repository as an operator host — CONFIG.md, .claude/operator.json, the orientation, references, docs/ (features, handoffs, lessons), the skill-eval template, the scripts/operator launcher and the permission rules. Run once per operator repo; safe to re-run (never overwrites).
disable-model-invocation: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash(bash scripts/operator:*)
  - Bash(bash *scripts/init-scaffold.sh*)
  - Bash(python3:*)
  - Bash(chmod +x scripts/operator)
  - Bash(ls:*)
---

# Initialize an operator host

Scaffold the files the operator skills expect in this repository. The plugin owns the skills, the contract and the scripts; this repo owns the state (`CONFIG.md`, specs, designs, decision log, status doc, lessons). Everything below is idempotent — existing files are reported as `skip:` and left alone.

1. **Resolve the plugin root.** It is `${CLAUDE_PLUGIN_ROOT}`. If that reads as a literal or is empty, use `$OPERATOR_PLUGIN_ROOT` when set; otherwise run
   `python3 -c 'import json,os;e=json.load(open(os.path.expanduser("~/.claude/plugins/installed_plugins.json")))["plugins"]["operator@operator-kit"];print(max(e,key=lambda x:x["lastUpdated"])["installPath"])'`.
   If none resolves, stop and say so — do not guess a path.
2. **Run the scaffold:** `bash "<plugin root>/scripts/init-scaffold.sh"` and show its `created:` / `skip:` / `gitignore:` lines and the settings merge result.
3. **Check the launcher:** `ls -l scripts/operator` must show it executable; if not, `chmod +x scripts/operator`.
4. **CLAUDE.md:** if the scaffold skipped it because one already existed, print the contents of `<plugin root>/templates/CLAUDE.md` and ask the user to merge the operator section into their file. Never edit their `CLAUDE.md` yourself.
5. **Tell the user what to fill in**, as a checklist:
   - `CONFIG.md` §1–§8 (repos, status view, human-task tracker, status doc, decision log, backlog, data sources, invariants)
   - `repos` in `.claude/operator.json` (full `org/repo` names) — the launcher and the monitors read this file
   - the two canonical markers in `.claude/references/monitors.md` (`OPMON:all:label:<a+b>` and `OPMON:all:comment:<a+b>`, short repo names sorted and joined with `+`)
   - per downstream repo: enable `operator-worker@operator-kit` there, then `bash scripts/operator bootstrap-labels <org>/<repo>`
6. **Run the gate:** `bash scripts/operator check` and report its output. On a fresh scaffold the placeholder repos in `.claude/operator.json` fail the repo-list check by design — say that this clears once step 5 is done.
7. **Report** the created / skipped table and the three follow-ups (fill CONFIG + operator.json, set the markers, bootstrap labels).
