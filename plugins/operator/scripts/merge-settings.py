#!/usr/bin/env python3
"""merge-settings.py RULES_JSON SETTINGS_JSON — idempotent union of permissions.allow/deny/ask.

Creates SETTINGS_JSON if absent, preserves every other key and the existing rule order,
appends only the rules that are missing, and refuses to touch a file that is not valid JSON.
"""
import json, os, sys

if len(sys.argv) != 3:
    sys.exit("usage: merge-settings.py RULES_JSON SETTINGS_JSON")
rules_path, settings_path = sys.argv[1], sys.argv[2]
rules = json.load(open(rules_path)).get("permissions", {})
data = {}
if os.path.exists(settings_path):
    try:
        data = json.load(open(settings_path))
    except Exception as e:
        sys.exit(f"{settings_path}: invalid JSON, not touching it: {e}")
perms = data.setdefault("permissions", {})
added = []
for bucket in ("allow", "deny", "ask"):
    wanted = rules.get(bucket, [])
    if not wanted:
        continue
    have = perms.setdefault(bucket, [])
    for r in wanted:
        if r not in have:
            have.append(r)
            added.append(f"{bucket}: {r}")
if added or not os.path.exists(settings_path):
    os.makedirs(os.path.dirname(settings_path) or ".", exist_ok=True)
    with open(settings_path, "w") as f:
        json.dump(data, f, indent=2)
        f.write("\n")
if added:
    print(f"{settings_path}: {len(added)} rule(s) added" + "".join("\n  + " + a for a in added))
else:
    print(f"{settings_path}: unchanged")
