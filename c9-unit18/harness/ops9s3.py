#!/usr/bin/env python3
"""BLUE C9-S3 (2026-11-26): one counter, one printed rule each (R.507's class).
  ops   SPEC.json [--exclude-prefix P ...]   -> operations = (path, method) pairs in the spec, minus excluded path prefixes; refuses an empty spec
  paths SRC_DIR                              -> PATH_* string constants in the generated client's api/*.java; refuses a dir with none
  media SPEC.json PATH_SUBSTR ...            -> for each path containing a substring: method, status, response media types, schema ref
"""
import json, os, re, sys

METHODS = {"get", "put", "post", "delete", "patch", "head", "options", "trace"}

def ops(spec, excl):
    d = json.load(open(spec))
    out = []
    for p, item in d.get("paths", {}).items():
        if any(p.startswith(e) for e in excl):
            continue
        for m, op in item.items():
            if m in METHODS:
                out.append((p, m.upper(), op.get("operationId")))
    if not out:
        sys.exit("REFUSED: no operations counted")
    print("RULE: operations = (path, method) pairs under paths, excluded prefixes", excl)
    for o in sorted(out):
        print("  %-6s %-48s %s" % (o[1], o[0], o[2]))
    print("OPERATIONS", len(out), "PATHS", len({o[0] for o in out}))

def paths(src):
    rx = re.compile(r'\bString\s+(PATH_[A-Z0-9_]+)\s*=')
    hits, files = [], set()
    for root, _, fs in os.walk(src):
        for f in fs:
            if f.endswith(".java") and os.sep + "api" + os.sep in os.path.join(root, f) + os.sep:
                for n, line in enumerate(open(os.path.join(root, f)), 1):
                    m = rx.search(line)
                    if m:
                        hits.append((f, n, m.group(1))); files.add(f)
    if not hits:
        sys.exit("REFUSED: no PATH_ constants found")
    print("RULE: lines matching 'String PATH_<NAME> =' in api/*.java")
    for h in hits:
        print("  %s:%d %s" % h)
    print("PATH_CONSTANTS", len(hits), "FILES", len(files))

def media(spec, subs):
    d = json.load(open(spec))
    for p, item in d.get("paths", {}).items():
        if not any(s in p for s in subs):
            continue
        for m, op in item.items():
            if m not in METHODS:
                continue
            for st, r in op.get("responses", {}).items():
                for mt, c in (r.get("content") or {}).items():
                    sch = c.get("schema", {})
                    print("  %-6s %-40s %s %-24s %s" % (m.upper(), p, st, mt, sch.get("$ref") or sch.get("type")))

if __name__ == "__main__":
    a = sys.argv[1:]
    if a[0] == "ops":
        ex = []
        if "--exclude-prefix" in a:
            i = a.index("--exclude-prefix"); ex = a[i + 1:]; a = a[:i]
        ops(a[1], ex)
    elif a[0] == "paths":
        paths(a[1])
    elif a[0] == "media":
        media(a[1], a[2:])
