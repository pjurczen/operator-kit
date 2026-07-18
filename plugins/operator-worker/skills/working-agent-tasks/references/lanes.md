# Lanes — running several workers on one repo (read when `$WORKER_ID` is set or you see `worker:*` labels)

By default a repo runs **one worker, no lane**: `$WORKER_ID` unset, every `gh` filter omits the lane, you act repo-wide. Several workers share one GitHub identity, so lanes are what keep them from colliding:

- **Launch each worker with a distinct id** — `WORKER_ID=lane-1 claude` (separate sessions). The env var is read throughout the session; relaunch with the **same** id after a resume.
- **The operator shards the queue** — every dispatch carries a `worker:<lane>` label, so lanes' queues are disjoint. You claim only `worker:$WORKER_ID` issues, stamp that label on claim, and scope monitors + close-out to issues carrying your lane. The lane label **is** the per-worker ownership marker the shared account otherwise lacks — both the claim race and the close-out race disappear.
- **All-or-nothing per repo.** Sharding is on only when *every* worker runs with an id **and** the operator lane-labels *every* dispatch. Guards:
  - **No `$WORKER_ID` but the `agent-task` queue carries `worker:*` labels** → the repo is sharded and you're mis-launched. **Stop and surface it** (claiming would collide); relaunch with your lane.
  - **You have a lane but see an `agent-task` issue with no `worker:*` label** → flag the unsharded dispatch to the operator (a comment on it), don't claim it.
- **After a restart, re-identify your work by the lane label** (issues/PRs carrying `worker:$WORKER_ID`), never by in-context memory.

*(Lanes are statically assigned at launch. Dynamic claim-on-startup — grabbing the lowest free lane — is a clean future upgrade, not built.)*
