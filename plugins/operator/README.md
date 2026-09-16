# operator plugin

The operator side of [operator-kit](../../README.md): the skills that turn strategy into specs and dispatched GitHub issues, a session-start hook with live state, the verify gate, and the scaffold that turns any repo into an operator host.

## What it installs

| Skill | Does |
|---|---|
| `/operator:init` | Scaffold this repo as an operator host (run once; idempotent) |
| `/operator:cycle` | The loop: sense → decide → act → track, with the human-task checklist every tick |
| `/operator:design` | Founder-approved design gate for above-bar features |
| `/operator:spec` | Author a self-contained handoff spec |
| `/operator:dispatch` | Open the labelled GitHub issue in the target repo |
| `/operator:monitor` | Watch dispatched issues, triage, merge gates, stale close-outs |
| `/operator:retro` | Self-improvement pass; lessons land in skills, checks and `docs/lessons/` |
| `/operator:status` | Refresh the living status doc from ground truth |
| `/operator:opportunities` | Mine the backlog (proposes only) |
| `/operator:check` | Run the verify gate against this host repo |

Plus a **SessionStart hook** (orientation + live state), the **references** (`board.md`, `human-tasks.md`, `knowledge-store.md`), the **contract** ([`docs/OPERATOR_MODEL.md`](docs/OPERATOR_MODEL.md)) and the **scripts** (`check.sh`, `monitor-status.sh`, `bootstrap-labels.sh`, `gh-relabel.sh`, `labels.psv`).

## The seam: what the plugin owns and what your repo owns

| Plugin-owned (versioned, updates with `claude plugin update`) | Host-owned (state, written once by `/operator:init`, yours to edit) |
|---|---|
| skills, hook, contract doc, references, scripts, templates | `CONFIG.md`, `.claude/operator.json`, `.claude/operator-orientation.md`, `.claude/references/{data-sources,monitors}.md`, `docs/{features,handoffs,lessons}/`, `.claude/skill-eval/`, `scripts/operator`, permission rules in `.claude/settings.json` |

## Why `scripts/operator` exists

Permission rules in `.claude/settings.json` cannot reference `${CLAUDE_PLUGIN_ROOT}`, and the plugin's install path changes with every version. The launcher resolves the current install path at run time (from `~/.claude/plugins/installed_plugins.json`, or `$OPERATOR_PLUGIN_ROOT` when set) and runs the requested plugin script, so one literal rule, `Bash(bash scripts/operator:*)`, covers every script and survives updates.

```
bash scripts/operator --root                       # where the plugin is installed right now
bash scripts/operator monitor-status               # liveness of the canonical monitors
bash scripts/operator bootstrap-labels <org>/<repo> # create the contract labels in a downstream repo
bash scripts/operator check                        # the verify gate
```

## Install

```
claude plugin marketplace add pjurczen/operator-kit
# in your operator repo's .claude/settings.json:
#   { "enabledPlugins": { "operator@operator-kit": true } }
/operator:init
```

Then fill `CONFIG.md` and `repos` in `.claude/operator.json`, set the two markers in `.claude/references/monitors.md`, enable `operator-worker@operator-kit` in each product repo and run `bash scripts/operator bootstrap-labels <org>/<repo>` for each. `/operator:check` should then be green.

## Local development

Test an uncached checkout with `claude --plugin-dir /path/to/operator-kit/plugins/operator` and `export OPERATOR_PLUGIN_ROOT=/path/to/operator-kit/plugins/operator` so the launcher and the gate find it. Hook smoke test: `CLAUDE_PROJECT_DIR=$PWD /path/to/plugins/operator/hooks/session-start | python3 -m json.tool`.

The worker side lives in [`operator-worker`](../operator-worker/README.md).
