# Close-out mechanics + known footguns (read during the reconcile sweep)

## Auto-close is partial
`Closes #N` closes the issue when the PR merges to the default branch — but it does **NOT** remove the `agent:in-review` label and does **NOT** post a summary. An auto-closed issue still *reads* as in-flight to the operator's status view until you finish the close-out: remove the label, ensure the issue is closed (a bare `Refs #N` / stacked PR won't auto-close — close it yourself), post the shipped-summary if the PR body doesn't already tell the story.

## The `--state all` sweep — the single most common miss
`gh issue list` defaults to **open** issues, so auto-closed-but-still-labeled issues are invisible to a default query. Every pass, before claiming new work:
```bash
gh issue list --label "agent:in-review" --state all ${WORKER_ID:+--label worker:$WORKER_ID} --json number,state
```
Or run the bundled **`scripts/closeout-sweep.sh <owner>/<repo>`** — it prints the `--state all` in-review set **and** `git worktree list` in one pass, so both close-out misses surface together. PR merged → finish the close-out; PR not merged → leave it, it's genuinely in review.

## Worktree reaping — reconcile-driven, not merge-event-only
A merged issue's worktree is finished work occupying disk; accumulated, they end in **`ENOSPC` mid-run**. Once a PR is merged and its issue closed-out, remove the worktree you created for it — using *this repo's own worktree practice* (its skill/CLAUDE.md owns the mechanics; this contract fixes the *when*). Do it **in the reconcile sweep**, not only on the merge event, so a cleanup a died monitor missed still gets swept. **Safety:** only after merge + close-out, and **never** remove a worktree with uncommitted or unpushed changes — leave it and flag it rather than discard work.

## Restart amnesia
Monitors die with the session / a resume, and the restored context still *believes* they're armed. Reconcile against `ps` (see `references/monitors.md`); re-identify your in-review PRs by the lane label (or the repo's whole in-review set when unsharded), never from memory.

## `gh`/`jq` quoting
Prefer `gh ... --json <fields>` and read the JSON, or simple `--jq` filters. **Nested double-quotes inside a `--jq '...'` string** (e.g. `join(",")` written with escaped quotes) break jq's parser — use a single-quoted alternative or `--json` + a follow-up parse instead of escaping quotes inside an already-quoted filter.
