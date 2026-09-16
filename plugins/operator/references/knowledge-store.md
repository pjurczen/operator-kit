# Knowledge store — grounding, fail-stop, and where facts live

The operator reasons over what the company already knows. By default that knowledge is files: the docs in this repo plus `docs/lessons/`, searched with `grep`. Optionally it is an MCP-backed store with retrieval (see `CONFIG.md` §11 and [`examples/gbrain.md`](../examples/gbrain.md)). The disciplines are the same either way.

## Ground before asserting
- On a new topic, a load-bearing claim, or before asking the human a question: search the store first, and say what you grounded on ("grounded on: `<doc or lesson>`").
- Re-ground on topic shifts, not every turn.
- Treat results as **needs-confirm** on load-bearing facts: the store says what was true when written.

## Fail-stop when the store is central
If `CONFIG.md` marks the store as central: store unreachable → retry briefly → **halt the current action and say so** ("store down — pausing"). Never silently work without it; a session that cannot ground will assert from memory and get it wrong. Worker repos stay store-free by design; this rule is the operator's.

## Write to the right place
- **Canonical reference** (product definitions, strategy, the contract, procedures) → docs in git, edited in place; git is the source of truth. If the store indexes `docs/`, re-import after editing.
- **Store-native content** (transcripts, people, companies, lessons) → the store's own write path (`docs/lessons/` by default).
- **Push-stores are invisible to the store.** `CLAUDE.md`, skills, hooks and agent memory are instructions, not knowledge: a company, product or infrastructure fact must never live *only* there.

## Verify through the read path
Claims about canonical docs are verified against the file; claims about store-native content are verified by reading the page back through the store, not by trusting the last write.

## Lessons land three times
Story → `docs/lessons/` (or the store) · rule → the owning skill or a check run by `bash scripts/operator check` · pointer → memory. `retro` verifies all three landed and that the rule reads clean without the story.
