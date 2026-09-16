# Lessons — the default knowledge store

One file per lesson. A lesson is written when a retro finds a failure *class*, not an incident; the incident story is the evidence, the rule is the payload. The operator grounds on this folder before asserting (`grep -ril <topic> docs/lessons/`), and `retro` lands every new lesson three times: the story here, the rule in the owning skill or check, a pointer in memory. See the operator plugin's `references/knowledge-store.md` for the disciplines, and `CONFIG.md` §11 to swap this folder for an MCP-backed store.

## Format

```markdown
---
name: <kebab-case-slug>            # matches the filename
date: <YYYY-MM-DD>
tags: [<area>, <area>]
---
# <one-line rule, as a sentence>

**What happened.** One paragraph. No company, customer or people names; keep the shape of the failure, drop the identifiers.

**The rule.** The operative rule in one or two sentences, phrased so it can be pasted into a skill.

**Where it landed.** `skill:<name>` / `check:<n>` / `reference:<file>` — the mechanical home of the rule. A lesson with no home is not incorporated yet.
```

Naming: the filename is the rule's slug (`verify-state-dont-assert-from-monitor-silence.md`), so a grep on the rule's key words finds it.
