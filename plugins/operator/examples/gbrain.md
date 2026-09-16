# Example: binding an MCP knowledge store (gbrain)

[gbrain](https://github.com/garrytan/gbrain) is an open-source (MIT) brain with hybrid search, page storage and an MCP server. This is one way to give the operator a retrieval-backed store instead of the default `docs/lessons/` folder; the disciplines in [`knowledge-store.md`](../references/knowledge-store.md) do not change.

## 1. Run the server and register it

`.mcp.json` in the operator repo:

```json
{
  "mcpServers": {
    "gbrain": { "type": "stdio", "command": "gbrain", "args": ["serve"] }
  }
}
```

## 2. Allow the tools the skills use

In `.claude/settings.json` → `permissions.allow`:

```json
"mcp__gbrain__search",
"mcp__gbrain__query",
"mcp__gbrain__get_page",
"mcp__gbrain__put_page"
```

the verify gate (`bash scripts/operator check`, check 6) asserts that every tool a skill declares in `allowed-tools` is covered here; add the same names to the skills that should call the store (`cycle`, `design`, `spec`, `retro`).

## 3. Decide what it indexes and what it owns

- **Indexes** `docs/` read-only: after editing a canonical doc, re-import (`gbrain import docs/`) so retrieval sees the new text.
- **Owns** store-native pages: meeting transcripts, people, companies, and `lessons/` (move `docs/lessons/` in, or keep files as the canonical copy and import them).
- Direct file reads of the store's own data directory should be denied in `settings.json` so facts flow through the read path.

## 4. Fill in `CONFIG.md` §11

Server name `gbrain`, the four tools above, `central: yes` (the operator fail-stops when it is down), indexed paths, owned prefixes. The retro's "lesson lands three times" rule then writes lessons with `put_page` and links them by slug.

## 5. Verify

Start a session, ask a question only the store can answer, and confirm the answer cites a page. Stop the server and confirm the operator halts with a "store down" message instead of answering from memory.
