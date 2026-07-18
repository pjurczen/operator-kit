#!/usr/bin/env bash
# Verification checks for operator-kit.
# This repo holds no product code; these guard its real failure modes:
# config validity, permission-rule syntax, plugin-version drift, broken doc
# links, skill frontmatter, skill cleanliness, and label-contract sync.
# Usage: bash scripts/check.sh   (exit 0 = all checks pass)
set -uo pipefail
cd "$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

fail=0

python3 - <<'PY'
import json, os, re, sys, glob
fail = 0
def err(m):
    global fail; print("FAIL:", m); fail = 1
def ok(m): print("ok:  ", m)

# 1. JSON parse
for f in [".claude/settings.json", ".claude/settings.local.json"]:
    if os.path.exists(f):
        try:
            json.load(open(f)); ok(f"json parse {f}")
        except Exception as e:
            err(f"invalid JSON {f}: {e}")

# 2. Permission-rule lint: a ':*' must sit immediately before the closing ')'
#    (the /doctor bug: ':*' buried mid-pattern is silently skipped by Claude Code)
for f in [".claude/settings.json", ".claude/settings.local.json"]:
    if not os.path.exists(f): continue
    try: data = json.load(open(f))
    except Exception: continue
    perms = data.get("permissions", {})
    bad = []
    for bucket in ("allow", "deny", "ask"):
        for rule in perms.get(bucket, []):
            i = 0
            while True:
                j = rule.find(":*", i)
                if j < 0: break
                if j + 2 >= len(rule) or rule[j + 2] != ")":
                    bad.append((bucket, rule)); break
                i = j + 2
    if bad:
        for b, r in bad: err(f"permission ':*' not at pattern end in {f} [{b}]: {r}")
    else:
        ok(f"permission-rule lint {f}")

# 3. Plugin version consistency (plugin.json == marketplace.json entry)
try:
    pj = json.load(open("plugins/operator-worker/.claude-plugin/plugin.json"))["version"]
    mk = json.load(open(".claude-plugin/marketplace.json"))
    mver = next((p.get("version") for p in mk.get("plugins", [])
                 if "operator-worker" in (p.get("source", "") + p.get("name", ""))), None)
    if mver is None:
        err("operator-worker not found in marketplace.json")
    elif pj != mver:
        err(f"plugin version drift: plugin.json={pj} marketplace.json={mver}")
    else:
        ok(f"plugin version consistent ({pj})")
except Exception as e:
    err(f"version check error: {e}")

# 4. Doc link check: relative markdown links resolve.
#    Broken internal links are this repo's top correctness risk.
md_files = []
for pat in ["docs/**/*.md", ".claude/**/*.md", "plugins/**/*.md", "*.md"]:
    md_files += glob.glob(pat, recursive=True)
link_re = re.compile(r"\]\(([^)]+)\)")
broken = []
for md in sorted(set(md_files)):
    base = os.path.dirname(md)
    txt = open(md, encoding="utf-8", errors="replace").read()
    for m in link_re.finditer(txt):
        url = m.group(1).strip()
        if url.startswith(("http://", "https://", "mailto:", "#", "tel:")): continue
        path = url.split("#", 1)[0].split("?", 1)[0]
        if not path: continue
        target = os.path.normpath(os.path.join(base, path))
        if not os.path.exists(target):
            broken.append(f"{md} -> {url}")
if broken:
    for b in broken: err(f"broken link {b}")
else:
    ok(f"doc links ({len(set(md_files))} files)")

# 5. Skill frontmatter: name: + description: present
skill_files = glob.glob(".claude/skills/*/SKILL.md") + glob.glob("plugins/*/skills/*/SKILL.md")
for sf in sorted(skill_files):
    txt = open(sf, encoding="utf-8").read()
    if not txt.startswith("---"):
        err(f"no frontmatter {sf}"); continue
    parts = txt.split("---", 2)
    if len(parts) < 3:
        err(f"unterminated frontmatter {sf}"); continue
    head = parts[1]
    miss = [k for k in ("name:", "description:") if k not in head]
    if miss:
        err(f"frontmatter missing {miss} {sf}")
    else:
        ok(f"frontmatter {sf}")

# 6. Skill MCP tools must be granted by the settings allow-list (wildcard-aware).
#    A skill's `allowed-tools` is NOT a harness permission: a loop skill (run every
#    tick, possibly unattended) whose MCP tool isn't allow-listed silently prompts /
#    is denied, and the step gets glossed.
def _allow(path):
    if not os.path.exists(path): return []
    try: return json.load(open(path)).get("permissions", {}).get("allow", [])
    except Exception: return []
allow_rules = _allow(".claude/settings.json") + _allow(".claude/settings.local.json")
def _covered(tool):
    for r in allow_rules:
        if r == tool or (r.endswith("*") and tool.startswith(r[:-1])): return True
    return False
tool_re = re.compile(r"^\s*-\s*(mcp__\S+)\s*$")
gaps = []
for sf in sorted(skill_files):
    txt = open(sf, encoding="utf-8").read()
    if not txt.startswith("---"): continue
    parts = txt.split("---", 2)
    if len(parts) < 3: continue
    for line in parts[1].splitlines():
        m = tool_re.match(line)
        if m and not _covered(m.group(1)):
            gaps.append(f"{sf} -> {m.group(1)}")
if gaps:
    for g in gaps: err(f"skill MCP tool not granted by settings allow-list: {g}")
else:
    ok("skill MCP allowed-tools all granted by settings allow-list")

# 7. Skill cleanliness lint. Skills are clean, timeless procedures: no incident
#    stories (inline #issue refs), no dated content, and a bounded body budget.
issueref_re = re.compile(r"#\d{2,4}\b")
lint_files = sorted(set(skill_files + ["CLAUDE.md", ".claude/operator-orientation.md"]
                        + glob.glob(".claude/references/*.md")))
warns = []
for f in lint_files:
    if not os.path.exists(f): continue
    txt = open(f, encoding="utf-8").read()
    parts = txt.split("---", 2)
    body = parts[2] if (txt.startswith("---") and len(parts) >= 3) else txt
    if f.endswith("SKILL.md"):
        n = len(issueref_re.findall(body))                     # (a) accretion cruft
        if n > 0:
            err(f"{f}: {n} inline #issue ref(s) in body (incident stories belong in a lesson/decision log)")
        if "lint:allow-dates" not in txt:                      # (b) dated content in a procedure
            if re.search(r"\b20\d\d-\d\d-\d\d\b", body):
                err(f"{f}: dated content in body (procedures are timeless; history -> decision log)")
        wc = len(body.split())                                 # (c) body size budget
        if wc > 1300:
            err(f"{f}: body {wc} words (>1300 — move detail to references/)")
        elif wc > 900:
            warns.append(f"{f}: body {wc} words (>900 — nearing the budget)")
for w in warns: print("warn:", w)
ok(f"skill cleanliness lint ({len(lint_files)} files, {len(warns)} warn)")

# 8. Label-contract sync: scripts/labels.psv == the label table in docs/OPERATOR_MODEL.md,
#    and every contract-shaped label literal in skills/docs is a member of the set.
psv = {}
try:
    for line in open("scripts/labels.psv", encoding="utf-8"):
        line = line.strip()
        if not line or line.startswith("#"): continue
        name, color, _ = line.split("|", 2)
        psv[name] = color.lower()
except Exception as e:
    err(f"labels.psv unreadable: {e}")
ct = {}
row_re = re.compile(r"^\|\s*`([^`]+)`\s*\|\s*`#([0-9a-fA-F]{6})`\s*\|")
if os.path.exists("docs/OPERATOR_MODEL.md"):
    for line in open("docs/OPERATOR_MODEL.md", encoding="utf-8"):
        m = row_re.match(line.strip())
        if m: ct[m.group(1)] = m.group(2).lower()
else:
    err("docs/OPERATOR_MODEL.md missing")
if psv and ct:
    if psv != ct:
        only_psv = sorted(set(psv) - set(ct)); only_ct = sorted(set(ct) - set(psv))
        diffc = sorted(k for k in set(psv) & set(ct) if psv[k] != ct[k])
        err(f"label-set drift psv vs OPERATOR_MODEL.md: only-psv={only_psv} only-model={only_ct} color-mismatch={diffc}")
    else:
        ok(f"label set psv == OPERATOR_MODEL.md ({len(psv)} labels)")
label_lit_re = re.compile(r"\b(agent-task|agent:[a-z-]+|priority:[a-z]+|needs-triage|needs-human)\b")
scan = sorted(set(lint_files
                  + ["docs/OPERATOR_MODEL.md", "plugins/operator-worker/README.md"]
                  + glob.glob("plugins/operator-worker/skills/*/references/*.md")
                  + glob.glob("plugins/operator-worker/commands/*.md")))
bad_lits = []
for f in scan:
    if not os.path.exists(f): continue
    for mt in label_lit_re.findall(open(f, encoding="utf-8").read()):
        if mt not in psv:
            bad_lits.append(f"{f}: '{mt}'")
if bad_lits:
    for b in sorted(set(bad_lits)): err(f"unknown contract label literal {b}")
else:
    ok(f"contract label literals all canonical ({len(scan)} files)")

sys.exit(1 if fail else 0)
PY
[ $? -ne 0 ] && fail=1

if [ $fail -ne 0 ]; then echo "== CHECK FAILED =="; exit 1; fi
echo "== ALL CHECKS PASSED =="; exit 0
