#!/usr/bin/env bash
# Verify gate for operator-kit. Two modes:
#   --host (default when run in an operator host repo): settings validity, permission-rule
#          syntax, host doc links, skill allowed-tools coverage, .claude/operator.json,
#          the launcher, monitor wiring.
#   --kit  (auto when .claude-plugin/marketplace.json is in cwd): plugin-version parity, plugin
#          doc links, skill frontmatter + cleanliness, label-contract sync, template
#          consistency, and the leak grep.
# Usage: bash scripts/operator check   |   bash scripts/check.sh --kit   (exit 0 = all pass)
set -uo pipefail
PLUGIN_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
MODE=host; [ -f .claude-plugin/marketplace.json ] && MODE=kit
case "${1:-}" in --host) MODE=host ;; --kit) MODE=kit ;; esac
if [ "$MODE" = host ]; then
  HOST_ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
  if [ -n "${OPERATOR_PLUGIN_ROOT:-}" ]; then PLUGIN_ROOT="$OPERATOR_PLUGIN_ROOT"
  elif [ -x "$HOST_ROOT/scripts/operator" ]; then PLUGIN_ROOT="$(bash "$HOST_ROOT/scripts/operator" --root 2>/dev/null || printf '%s' "$PLUGIN_ROOT")"; fi
  cd "$HOST_ROOT" || { echo "FAIL: cannot cd to $HOST_ROOT"; exit 1; }
else
  cd "$(CDPATH= cd -- "$PLUGIN_ROOT/../.." && pwd)" || exit 1     # plugins/operator -> kit root
  PLUGIN_ROOT="$PWD/plugins/operator"
fi
export MODE PLUGIN_ROOT
echo "== check.sh mode=$MODE  cwd=$PWD  plugin=$PLUGIN_ROOT"

fail=0
python3 - <<'PY'
import json, os, re, sys, glob, subprocess
MODE, PR = os.environ["MODE"], os.environ["PLUGIN_ROOT"]
fail = 0
def err(m):
    global fail; print("FAIL:", m); fail = 1
def ok(m): print("ok:  ", m)
def load(path):
    return json.load(open(path, encoding="utf-8"))
def frontmatter(txt):
    if not txt.startswith("---"): return None, txt
    parts = txt.split("---", 2)
    return (parts[1], parts[2]) if len(parts) >= 3 else (None, txt)

MANIFEST = [  # (src under templates/, dst in host) — mirrors scripts/init-scaffold.sh
    ("CONFIG.md", "CONFIG.md"), ("CLAUDE.md", "CLAUDE.md"),
    ("operator.json", ".claude/operator.json"), ("operator-orientation.md", ".claude/operator-orientation.md"),
    ("references/data-sources.md", ".claude/references/data-sources.md"),
    ("references/monitors.md", ".claude/references/monitors.md"),
    ("skill-eval/cases.csv", ".claude/skill-eval/cases.csv"), ("skill-eval/README.md", ".claude/skill-eval/README.md"),
    ("skill-eval/.gitignore", ".claude/skill-eval/.gitignore"),
    ("docs/features/README.md", "docs/features/README.md"), ("docs/handoffs/README.md", "docs/handoffs/README.md"),
    ("docs/lessons/README.md", "docs/lessons/README.md"),
    ("docs/lessons/dedup-before-dispatch.md", "docs/lessons/dedup-before-dispatch.md"),
    ("docs/lessons/verify-state-dont-assert-from-monitor-silence.md", "docs/lessons/verify-state-dont-assert-from-monitor-silence.md"),
    ("scripts/operator", "scripts/operator"),
]

# 1. JSON parse
json_files = ([".claude/settings.json", ".claude/settings.local.json", ".claude/operator.json"] if MODE == "host" else
              [".claude/settings.json", ".claude-plugin/marketplace.json", "plugins/operator/.claude-plugin/plugin.json",
               "plugins/operator-worker/.claude-plugin/plugin.json", "plugins/operator/hooks/hooks.json",
               "plugins/operator/templates/settings.rules.json", "plugins/operator/templates/operator.json"])
for f in json_files:
    if os.path.exists(f):
        try: load(f); ok(f"json parse {f}")
        except Exception as e: err(f"invalid JSON {f}: {e}")
    elif MODE == "kit":
        err(f"missing {f}")

# 2. Permission-rule lint: a ':*' must sit immediately before the closing ')'
perm_files = [".claude/settings.json", ".claude/settings.local.json"] + (["plugins/operator/templates/settings.rules.json"] if MODE == "kit" else [])
for f in perm_files:
    if not os.path.exists(f): continue
    try: data = load(f)
    except Exception: continue
    perms = data.get("permissions", {}); bad = []
    for bucket in ("allow", "deny", "ask"):
        for rule in perms.get(bucket, []):
            i = 0
            while True:
                j = rule.find(":*", i)
                if j < 0: break
                if j + 2 >= len(rule) or rule[j + 2] != ")": bad.append((bucket, rule)); break
                i = j + 2
    if bad:
        for b, r in bad: err(f"permission ':*' not at pattern end in {f} [{b}]: {r}")
    else: ok(f"permission-rule lint {f}")

# 3. Plugin version parity (kit)
if MODE == "kit":
    try:
        mk = load(".claude-plugin/marketplace.json")
        for name in ("operator", "operator-worker"):
            pj = load(f"plugins/{name}/.claude-plugin/plugin.json")["version"]
            mver = next((p.get("version") for p in mk.get("plugins", []) if p.get("name") == name), None)
            if mver is None: err(f"{name} not found in marketplace.json")
            elif pj != mver: err(f"plugin version drift for {name}: plugin.json={pj} marketplace.json={mver}")
            else: ok(f"plugin version consistent ({name} {pj})")
    except Exception as e: err(f"version check error: {e}")

# 4. Doc link check: relative markdown links resolve
pats = (["docs/**/*.md", ".claude/**/*.md", "*.md"] if MODE == "host" else ["plugins/**/*.md", "*.md"])
md_files = sorted({f for pat in pats for f in glob.glob(pat, recursive=True)})
link_re = re.compile(r"\]\(([^)]+)\)"); broken = []
for md in md_files:
    base = os.path.dirname(md); txt = open(md, encoding="utf-8", errors="replace").read()
    for m in link_re.finditer(txt):
        url = m.group(1).strip()
        if url.startswith(("http://", "https://", "mailto:", "#", "tel:")): continue
        path = url.split("#", 1)[0].split("?", 1)[0]
        if not path: continue
        if not os.path.exists(os.path.normpath(os.path.join(base, path))): broken.append(f"{md} -> {url}")
if broken:
    for b in broken: err(f"broken link {b}")
else: ok(f"doc links ({len(md_files)} files)")

# 5. Skill frontmatter (plugin skills; host may add its own under .claude/skills)
skill_files = sorted(set(glob.glob(f"{PR}/skills/*/SKILL.md") + glob.glob(".claude/skills/*/SKILL.md"))) if MODE == "host" \
              else sorted(glob.glob("plugins/*/skills/*/SKILL.md"))
for sf in skill_files:
    head, _ = frontmatter(open(sf, encoding="utf-8").read())
    if head is None: err(f"no frontmatter {sf}"); continue
    miss = [k for k in ("name:", "description:") if k not in head]
    if miss: err(f"frontmatter missing {miss} {sf}")
    else:
        name = re.search(r"^name:\s*(\S+)", head, re.M)
        folder = os.path.basename(os.path.dirname(sf))
        if name and name.group(1) != folder: err(f"frontmatter name '{name.group(1)}' != folder '{folder}' ({sf})")
        else: ok(f"frontmatter {sf}")

# 6. Skill allowed-tools must be granted by the HOST settings allow-list (host mode)
if MODE == "host":
    def _allow(path):
        if not os.path.exists(path): return []
        try: return load(path).get("permissions", {}).get("allow", [])
        except Exception: return []
    allow_rules = _allow(".claude/settings.json") + _allow(".claude/settings.local.json")
    def _covered(tool):
        for r in allow_rules:
            if r == tool: return True
            if r.endswith("*") and tool.startswith(r[:-1]): return True
            if r.endswith(":*)") and tool.startswith(r[:-3]): return True
        return False
    tool_re = re.compile(r"^\s*-\s*(mcp__\S+|Bash\([^)]*\))\s*$")
    gaps, seen = [], 0
    for sf in skill_files:
        head, _ = frontmatter(open(sf, encoding="utf-8").read())
        if head is None or re.search(r"^disable-model-invocation:\s*true", head, re.M): continue
        for line in head.splitlines():
            m = tool_re.match(line)
            if not m: continue
            seen += 1
            if not _covered(m.group(1)): gaps.append(f"{sf} -> {m.group(1)}")
    if "Bash(bash scripts/operator:*)" not in allow_rules:
        err("host allow-list lacks Bash(bash scripts/operator:*) — the launcher rule (run /operator:init)")
    if gaps:
        for g in gaps: err(f"skill tool not granted by settings allow-list: {g}")
    else: ok(f"skill allowed-tools all granted by settings allow-list ({seen} declared)")

# 7. Cleanliness lint (kit): timeless procedures — no issue refs, dates, [[links]], bounded body
if MODE == "kit":
    issueref_re = re.compile(r"#\d{2,4}\b")
    lint_files = sorted(set(skill_files + glob.glob(f"{PR}/references/*.md") + glob.glob(f"{PR}/templates/references/*.md")
                            + [f"{PR}/templates/CLAUDE.md", f"{PR}/templates/operator-orientation.md"]))
    warns = []
    for f in lint_files:
        if not os.path.exists(f): continue
        txt = open(f, encoding="utf-8").read(); _, body = frontmatter(txt)
        if "[[" in body: err(f"{f}: [[...]] link in body (the kit ships no store; cite inline or drop)")
        if f.endswith("SKILL.md"):
            n = len(issueref_re.findall(body))
            if n > 0: err(f"{f}: {n} inline #issue ref(s) in body (incident stories belong in a lesson/decision log)")
            if "lint:allow-dates" not in txt and re.search(r"\b20\d\d-\d\d-\d\d\b", body):
                err(f"{f}: dated content in body (procedures are timeless; history -> decision log)")
            wc = len(body.split())
            if wc > 1300: err(f"{f}: body {wc} words (>1300 — move detail to references/)")
            elif wc > 900: warns.append(f"{f}: body {wc} words (>900 — nearing the budget)")
    for w in warns: print("warn:", w)
    ok(f"skill cleanliness lint ({len(lint_files)} files, {len(warns)} warn)")

# 8. Label-contract sync (kit): labels.psv == the table in OPERATOR_MODEL.md; literals canonical
if MODE == "kit":
    psv = {}
    try:
        for line in open(f"{PR}/scripts/labels.psv", encoding="utf-8"):
            line = line.strip()
            if not line or line.startswith("#"): continue
            name, color, _ = line.split("|", 2); psv[name] = color.lower()
    except Exception as e: err(f"labels.psv unreadable: {e}")
    ct = {}; row_re = re.compile(r"^\|\s*`([^`]+)`\s*\|\s*`#([0-9a-fA-F]{6})`\s*\|")
    model = f"{PR}/docs/OPERATOR_MODEL.md"
    if os.path.exists(model):
        for line in open(model, encoding="utf-8"):
            m = row_re.match(line.strip())
            if m: ct[m.group(1)] = m.group(2).lower()
    else: err(f"{model} missing")
    if psv and ct:
        if psv != ct:
            err(f"label-set drift psv vs OPERATOR_MODEL.md: only-psv={sorted(set(psv)-set(ct))} only-model={sorted(set(ct)-set(psv))} "
                f"color-mismatch={sorted(k for k in set(psv)&set(ct) if psv[k]!=ct[k])}")
        else: ok(f"label set psv == OPERATOR_MODEL.md ({len(psv)} labels)")
    label_lit_re = re.compile(r"\b(agent-task|agent:[a-z-]+|priority:[a-z]+|needs-triage|needs-human)\b")
    scan = sorted(set(lint_files + [model, "plugins/operator-worker/README.md"]
                      + glob.glob("plugins/operator-worker/skills/*/references/*.md") + glob.glob("plugins/operator-worker/commands/*.md")))
    bad_lits = [f"{f}: '{mt}'" for f in scan if os.path.exists(f)
                for mt in label_lit_re.findall(open(f, encoding="utf-8").read()) if mt not in psv]
    if bad_lits:
        for b in sorted(set(bad_lits)): err(f"unknown contract label literal {b}")
    else: ok(f"contract label literals all canonical ({len(scan)} files)")

# 8b. Monitor repo-set sync: operator.json repos <-> monitors.md canonical markers
cfg_path, mons_path = ((".claude/operator.json", ".claude/references/monitors.md") if MODE == "host"
                       else (f"{PR}/templates/operator.json", f"{PR}/templates/references/monitors.md"))
try:
    if os.path.exists(cfg_path) and os.path.exists(mons_path):
        repos = load(cfg_path).get("repos", [])
        seg = "+".join(sorted(r.split("/")[-1] for r in repos if isinstance(r, str)))
        mons = open(mons_path, encoding="utf-8").read()
        drift = [t for t in ("label", "comment") if f"OPMON:all:{t}:{seg}" not in mons]
        for t in drift: err(f"{mons_path} missing canonical marker OPMON:all:{t}:{seg} (repo-set drift vs {cfg_path})")
        if not drift: ok(f"monitor repo-set sync (markers ...:{seg})")
    elif MODE == "kit":
        err(f"missing {cfg_path} or {mons_path}")
except Exception as e: err(f"monitor-set check error: {e}")

# H. Host-only checks
if MODE == "host":
    if os.path.isfile("scripts/operator") and os.access("scripts/operator", os.X_OK): ok("launcher scripts/operator present and executable")
    else: err("scripts/operator missing or not executable (run /operator:init)")
    if os.path.exists(".claude/operator.json"):
        try:
            cfg = load(".claude/operator.json"); repos = cfg.get("repos")
            if not isinstance(repos, list) or not repos: err(".claude/operator.json: 'repos' must be a non-empty list of org/repo")
            elif any((not isinstance(r, str)) or r.count("/") != 1 or "<" in r for r in repos):
                err(f".claude/operator.json: repos must be real 'org/repo' names, got {repos}")
            else: ok(f"operator.json: marketplace={cfg.get('marketplace', 'operator-kit')} repos={len(repos)}")
        except Exception as e: err(f".claude/operator.json: {e}")
    else: err(".claude/operator.json missing (run /operator:init)")
    missing = [dst for _, dst in MANIFEST if not os.path.exists(dst)]
    for d in missing: print("warn: not scaffolded:", d, "(run /operator:init)")

# K. Kit-only checks: every template in the manifest exists; launcher is executable in git
if MODE == "kit":
    miss = [src for src, _ in MANIFEST if not os.path.exists(f"{PR}/templates/{src}")]
    if miss: err(f"init manifest sources missing under templates/: {miss}")
    else: ok(f"init manifest sources present ({len(MANIFEST)})")
    try:
        mode = subprocess.run(["git", "ls-files", "-s", f"{PR}/templates/scripts/operator"], capture_output=True, text=True).stdout.split()
        if not mode or mode[0] != "100755": err("templates/scripts/operator is not mode 100755 in git")
        else: ok("launcher template executable in git")
    except Exception as e: err(f"git mode check error: {e}")

sys.exit(1 if fail else 0)
PY
[ $? -ne 0 ] && fail=1

# 9. Leak grep (kit only): nothing company-, people-, or secret-shaped may sit in tracked files.
if [ "$MODE" = kit ]; then
  leak_re='buyary|asana|posthog|pj@|christian|taylor|janelle|\bsk-|ghp_|xox[bp]-'
  hits=$(git ls-files -z | xargs -0 grep -n -i -E "$leak_re" -- 2>/dev/null \
    | grep -v -E '^(LICENSE|plugins/operator/scripts/check\.sh|plugins/[^/]+/\.claude-plugin/plugin\.json|\.claude-plugin/marketplace\.json):' \
    | grep -v -F 'Asana / Linear' || true)
  if [ -n "$hits" ]; then echo "FAIL: leak grep (company/people/secret-shaped strings in tracked files):"; printf '%s\n' "$hits"; fail=1
  else echo "ok:   leak grep clean"; fi
fi

if [ $fail -ne 0 ]; then echo "== CHECK FAILED =="; exit 1; fi
echo "== ALL CHECKS PASSED =="; exit 0
