# CLAUDE.md — developing operator-kit

## What this repository is
A Claude Code **plugin marketplace** with two plugins and no product code: [`plugins/operator`](plugins/operator/README.md) (the operator side: skills, hook, contract, scripts, and the `/operator:init` scaffold) and [`plugins/operator-worker`](plugins/operator-worker/README.md) (the downstream worker side). Adopters install both from this marketplace; nothing here is run as an operator directly. The architecture and the operator↔worker contract live in [`plugins/operator/docs/OPERATOR_MODEL.md`](plugins/operator/docs/OPERATOR_MODEL.md).

## Layout
`.claude-plugin/marketplace.json` — the catalog (versions must match each plugin's `plugin.json`) · `plugins/operator/` — `skills/`, `hooks/`, `references/`, `docs/`, `scripts/`, `templates/` (what `/operator:init` writes into a host), `examples/` · `plugins/operator-worker/` — `commands/`, `skills/`, `scripts/` · `scripts/check.sh` — the kit gate (runs the plugin's check in `--kit` mode).

## Rules
- **Generic only.** No company, product, customer or people names; no tokens or private URLs. `scripts/check.sh` greps for the known patterns; extend the pattern when a new one appears.
- **Skills are clean, timeless procedures:** imperative steps, no incident stories, issue numbers, dates or wiki-links; body budget enforced by the gate.
- **Host-owned vs plugin-owned:** anything a user edits (CONFIG, orientation, data sources, monitors, docs) lives under `templates/` and is scaffolded; skills reference those as bare paths, never as links.
- **Scripts are reached through the host launcher** (`bash scripts/operator <name>`), never by a path into the plugin cache.
- **Version bump on every change under `plugins/<name>/`**, in both `plugin.json` and the marketplace entry; tag the kit (`vX.Y.Z`) on release.
- Commits use Conventional Commits; preserve `Co-Authored-By` and session trailers.

## How to verify (before any commit)
- `bash scripts/check.sh` must print `== ALL CHECKS PASSED ==`.
- `claude plugin validate .` and `claude plugin validate plugins/operator`.
- Hook: `CLAUDE_PROJECT_DIR=$PWD plugins/operator/hooks/session-start | python3 -m json.tool`.
- Scaffold, in a scratch repo: `OPERATOR_PLUGIN_ROOT=$PWD/plugins/operator bash plugins/operator/scripts/init-scaffold.sh` twice (second run: all `skip:`), then `bash scripts/operator check`.
- Live: `claude --plugin-dir plugins/operator` in the scratch repo, `/operator:init`, `/operator:check`.
