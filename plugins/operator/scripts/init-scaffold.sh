#!/usr/bin/env bash
# init-scaffold.sh — the mechanical part of /operator:init. Copies the plugin's templates into the
# host repo (never overwriting), makes the launcher executable, adds .gitignore lines, and merges
# the permission rules into .claude/settings.json. Idempotent: re-running reports `skip:` lines.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOST="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$HOST" || { echo "init: cannot cd to $HOST" >&2; exit 1; }
created=0; skipped=0

copy_if_absent() {  # src (relative to templates/) dst (relative to host)
  local src="$ROOT/templates/$1" dst="$2"
  if [ -e "$dst" ]; then echo "skip:    $dst (exists)"; skipped=$((skipped+1)); return 0; fi
  mkdir -p "$(dirname "$dst")" && cp "$src" "$dst" && echo "created: $dst" && created=$((created+1))
}

copy_if_absent CONFIG.md CONFIG.md
copy_if_absent CLAUDE.md CLAUDE.md
copy_if_absent operator.json .claude/operator.json
copy_if_absent operator-orientation.md .claude/operator-orientation.md
copy_if_absent references/data-sources.md .claude/references/data-sources.md
copy_if_absent references/monitors.md .claude/references/monitors.md
copy_if_absent skill-eval/cases.csv .claude/skill-eval/cases.csv
copy_if_absent skill-eval/README.md .claude/skill-eval/README.md
copy_if_absent skill-eval/.gitignore .claude/skill-eval/.gitignore
copy_if_absent docs/features/README.md docs/features/README.md
copy_if_absent docs/handoffs/README.md docs/handoffs/README.md
copy_if_absent docs/lessons/README.md docs/lessons/README.md
copy_if_absent docs/lessons/dedup-before-dispatch.md docs/lessons/dedup-before-dispatch.md
copy_if_absent docs/lessons/verify-state-dont-assert-from-monitor-silence.md docs/lessons/verify-state-dont-assert-from-monitor-silence.md
copy_if_absent scripts/operator scripts/operator
chmod +x scripts/operator 2>/dev/null || true

touch .gitignore
for line in 'private/' '.claude/settings.local.json' '.claude/skill-eval/artifacts/'; do
  grep -qxF "$line" .gitignore || { printf '%s\n' "$line" >> .gitignore; echo "gitignore: + $line"; }
done

python3 "$ROOT/scripts/merge-settings.py" "$ROOT/templates/settings.rules.json" .claude/settings.json
echo "init-scaffold: created $created, skipped $skipped"
