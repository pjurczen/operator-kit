# Worker monitors reference

Canonical commands for the `working-agent-tasks` worker monitors. **Arm these from here verbatim — never improvise them** (improvised monitors drift). Same model as the operator's side: each command carries a marker `WKMON:<owner>/<repo>:<name>`, and you **reconcile against `ps`** — scan for the marker, arm only the missing (`persistent: true`). Idempotent: never duplicates; self-heals a resume / crash (dead → re-armed next pass).

Substitute `<owner>/<repo>` and the issue/PR number. `${WORKER_ID:+--label worker:$WORKER_ID}` filters to your lane when sharded; unset = repo-wide.

## Reconcile (every pass)
```bash
ps -eo command | grep -F 'WKMON:<owner>/<repo>:<name>' | grep -v grep   # non-empty = alive (leave it); empty = arm it
```

## 1. `discovery` — new `agent-task` in your lane (always armed)
Idle pickup: fires the instant a dispatch lands in your lane, so you don't grind passes between issues.
```bash
prev=""; while true; do cur=$(gh issue list --label agent-task --state open ${WORKER_ID:+--label worker:$WORKER_ID} --json number --jq '[.[].number]|sort|tostring' 2>/dev/null); if [ -n "$cur" ] && [ "$cur" != "$prev" ]; then [ -n "$prev" ] && echo "new agent-task queue: $cur"; prev="$cur"; fi; sleep 90; done # WKMON:<owner>/<repo>:discovery
```

## 2. `comment:#<N>` — corrections/answers on your active issue AND your open PR
Arm one per in-flight issue `#N` (the whole time it's claimed — *especially* while `agent:blocked`) **and** one per open in-review PR (a PR is an issue, so the same command works with the PR number — that's where "don't merge / X is broken" lands). Bots are filtered, and the cursor advances **only on a successful poll**, so a network gap **backfills** the missed window instead of silently skipping it.
```bash
N=<N>; last=$(date -u +%Y-%m-%dT%H:%M:%SZ); while true; do now=$(date -u +%Y-%m-%dT%H:%M:%SZ); if out=$(gh api "repos/<owner>/<repo>/issues/$N/comments?since=$last&sort=created&direction=asc" --jq '.[] | select((.user.login // "") | test("coderabbit|\\[bot\\]|github-actions|vercel|dependabot";"i") | not) | "comment on #\(.issue_url|split("/")|last): \(.body[0:200]|gsub("\n";" "))"' 2>/dev/null); then [ -n "$out" ] && echo "$out"; last=$now; fi; sleep 120; done # WKMON:<owner>/<repo>:comment:#<N>
```
(`$N` is only in the shell URL, never inside the `--jq` string — keep nested double-quotes out of jq.) For **line-level** PR review notes, also poll `pulls/<PR>/comments` under a separate marker `…:comment:#<PR>:review`.

## 3. `merge:#<PR>` — your open in-review PR merged → close out
One per open `agent:in-review` PR you own (sharded: PRs whose issue carries your lane; unsharded: all of them). Fires on the terminal state so you close out the instant it merges — remove `agent:in-review`, close the issue if it didn't auto-close, post the summary, reap the worktree.
```bash
PR=<PR>; while true; do s=$(gh pr view $PR --repo <owner>/<repo> --json state,mergedAt --jq '"\(.state) \(.mergedAt // "-")"' 2>/dev/null); case "$s" in MERGED*) echo "PR #$PR merged -> close out its issue"; break;; CLOSED*) echo "PR #$PR closed unmerged -> check why"; break;; esac; sleep 90; done # WKMON:<owner>/<repo>:merge:#<PR>
```
The `--state all` close-out reconcile (`scripts/closeout-sweep.sh <owner>/<repo>`) stays the **safety net** — a monitor can die in a gap.

## 4. `ci:#<PR>` — your open PR's checks: first FAIL or all-green (one-shot)
Armed **in the same step that opens the PR** and **re-armed after every push to the PR branch** (each push restarts checks; the old monitor exited on the previous run's terminal state). One-shot by design (it exits on the verdict): a red build is YOURS to catch and fix before any human reviewer sees it. On FAIL: treat it exactly like merge-gate feedback — diagnose, fix, push, re-arm.
```bash
PR=<PR>; while true; do out=$(gh pr checks $PR --repo <owner>/<repo> --json name,bucket 2>/dev/null) || { sleep 60; continue; }; fails=$(jq -r '[.[]|select(.bucket=="fail")|.name]|join(",")' <<<"$out"); pending=$(jq -r '[.[]|select(.bucket=="pending")]|length' <<<"$out"); if [ -n "$fails" ]; then echo "PR #$PR CI FAILED: $fails -> diagnose + fix + push + re-arm"; break; fi; if [ "$pending" = "0" ] && [ -n "$out" ] && [ "$out" != "[]" ]; then echo "PR #$PR CI all green"; break; fi; sleep 90; done # WKMON:<owner>/<repo>:ci:#<PR>
```

**No `Monitor` tool?** Fall back to polling each `/loop` pass + re-reading the active issue/PR at checkpoints — same contract, less responsive.
