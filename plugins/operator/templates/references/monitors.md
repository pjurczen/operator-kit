# Monitors reference

Canonical definitions for the operator's background `Monitor` tasks — a lightweight way to get woken on issue-state changes across the downstream repos between ticks. **Arm these from here verbatim — never improvise the commands, never arm from memory** (improvised monitors drift). This file is the single source; the **reconcile** makes the live set *equal* this file, deterministically. Used by `cycle` (sense step) and `monitor`.

Monitors are optional convenience, not the source of truth — the per-tick explicit `gh issue list` sweep in `monitor` is always the authority. If your harness has no `Monitor` tool, skip this file and poll each tick.

## Properties (read first)
- **The monitor is a process; it dies with the CLI.** It dies when the session ends, the model switches, or you **resume** a session (the restored *context* still says "armed" — a trap). **Never trust the context's "armed" belief — reconcile against the status script.**
- **`ps`-visible ≠ working — the loop must actually word-split.** The load-bearing gotcha: the Monitor tool runs commands in **zsh**, and `for r in $repos` does **not** split an unquoted variable in zsh (it does in bash). So the loop runs **once** with `r` = the whole `"a b c"` string, every `gh … --repo <org>/a b c …` is malformed → empty, and the monitor silently detects nothing while both `ps` and the heartbeat report "healthy". **Fix: `for r in ${=repos}`** (force zsh field-splitting). Defense-in-depth also lives in the commands: each loop writes a heartbeat (`date +%s > /tmp/operator-opmon/<type>.hb`; `monitor-status.sh` flags a stale / absent heartbeat as **MISSING**), and each `gh` is `timeout 30`-wrapped so a hung call can't freeze the loop. The heartbeat proves the *loop* is alive, not that polls succeed — **the per-tick explicit `gh issue list` sweep in `monitor` stays the authority.**
- **Markered + `ps`-visible.** Each monitor's command carries a marker `OPMON:all:<type>:<repo-set>` — the **repo set is encoded in the marker** (short names, `+`-joined, sorted), so changing the active-repo set changes the *wanted* marker: the stale monitor stops matching, a fresh one gets armed, and the stale one ages out at session end (bounded duplicate pings; a monitor armed *this session* can be stopped cleanly with `TaskStop`).
- **Watch the *issue*, not the PR** (operator side) — PR/CI state is the worker's lane; see `monitor`.
- **Shared GitHub account** — worker, human, and operator may post as one user; recognize and skip your own comment echoes (the bot-filter handles review bots).

## Which repos
One `repos` list (in `.claude/operator.json` and the commands below) covers every **active** downstream repo (the placeholder is `repo-a repo-b` — fill it in). To change the set: edit `repos` in `.claude/operator.json` **and** the two commands here (marker included) — the reconcile then swaps the monitors naturally.

## The reconcile — arm the missing (every `cycle` sense step)
1. `bash scripts/operator monitor-status` — prints exactly which of the **2** canonical markers are MISSING (or `OK: all 2 …`). A marker counts as running only if it is **both** `ps`-visible **and** heartbeat-fresh — a wedged/zombie monitor (stale heartbeat) is reported MISSING with a `kill its PID + re-arm` hint, not a false OK.
2. For each missing one, arm the command below (`persistent: true`). Never duplicates (you only arm what `ps` doesn't show); self-heals a resume / restart / crash; drift dies (the live set converges to this file).

## Operator monitors — the canonical set (2 processes, all repos each)

### 1. Label monitor (agent-flow transitions + needs-triage, all repos) — marker `OPMON:all:label:repo-a+repo-b`
```bash
mkdir -p /tmp/operator-opmon; date +%s > /tmp/operator-opmon/label.hb; owner="<org>"; repos="repo-a repo-b"; typeset -A prev; while true; do for r in ${=repos}; do cur=$(timeout 30 gh issue list --repo $owner/$r --state open --limit 100 --json number,labels --jq '[.[] | select(((.labels | length) == 0) or ([.labels[].name] | any(startswith("agent") or . == "needs-triage"))) | {n: .number, l: [.labels[].name | select(startswith("agent") or . == "needs-triage")]}] | sort_by(.n) | tostring' 2>/dev/null); if [ -n "$cur" ] && [ "$cur" != "${prev[$r]:-}" ]; then [ -n "${prev[$r]:-}" ] && echo "$r issue change -> agent-issues=$cur"; prev[$r]="$cur"; fi; done; date +%s > /tmp/operator-opmon/label.hb; sleep 90; done # OPMON:all:label:repo-a+repo-b
```
Fires on agent-flow / `needs-triage` transitions + closures, per repo — **and on issues with NO labels at all** (they surface as `{"n":N,"l":[]}`; an unlabeled open issue is a mis-filed raise, invisible to the label-filtered triage sweep — treat `l:[]` as `needs-triage`). `persistent: true`.

### 2. Comment monitor (human substance, bots filtered, all repos) — marker `OPMON:all:comment:repo-a+repo-b`
```bash
mkdir -p /tmp/operator-opmon; date +%s > /tmp/operator-opmon/comment.hb; owner="<org>"; repos="repo-a repo-b"; typeset -A last; n0=$(date -u +%Y-%m-%dT%H:%M:%SZ); for r in ${=repos}; do last[$r]=$n0; done; while true; do for r in ${=repos}; do now=$(date -u +%Y-%m-%dT%H:%M:%SZ); if out=$(timeout 30 gh api "repos/$owner/$r/issues/comments?since=${last[$r]}&sort=created&direction=asc" --jq '.[] | select((.user.login // "") | test("coderabbit|\\[bot\\]|github-actions|vercel|dependabot";"i") | not) | "comment on #\(.issue_url|split("/")|last): \(.body[0:200]|gsub("\n";" "))"' 2>/dev/null); then [ -n "$out" ] && printf '%s\n' "$out" | sed "s|^|$r |"; last[$r]=$now; fi; done; date +%s > /tmp/operator-opmon/comment.hb; sleep 120; done # OPMON:all:comment:repo-a+repo-b
```
Fires on new **human** issue comments (worker corrections/deviations/questions/FYIs — a comment fires no label monitor, hence this one). **Per-repo cursor advances only on a successful poll** — an outage window backfills on reconnect instead of silently skipping. `persistent: true`.

## Worker monitors (different home, same reconcile)
The worker's monitors live in the **`operator-worker` plugin** (`plugins/operator-worker/skills/working-agent-tasks/references/monitors.md`) — marker `WKMON:*`, same ps-reconcile pattern, inherently per-issue/per-PR (discovery, active-issue comments, PR merge, CI). The two sides are symmetric: the operator watches the worker's comments; the worker watches the operator's.
