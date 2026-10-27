#!/usr/bin/env python3
"""hints.py FILE TYPE...: what a reachability-metadata.json (the hints Boot's process-aot wrote for a native image) says - how many
reflection and resource entries it holds; every JDK-proxy hint, its interfaces in the file's order; and, for each TYPE named, its
reflection entry: what it opens (fields, constructors, methods - by name). Reads the file; changes nothing; no network."""
import json, sys

m = json.load(open(sys.argv[1], encoding="utf-8"))
refl = m.get("reflection", [])
print("reflection entries: %d · resource entries: %d" % (len(refl), len(m.get("resources", []))))
proxies = [e["type"]["proxy"] for e in refl if isinstance(e.get("type"), dict) and "proxy" in e["type"]]
print("JDK-proxy hints: %d" % len(proxies))
for p in proxies:
    print("  proxy: [%s]" % ", ".join(p))
for t in sys.argv[2:]:
    es = [e for e in refl if e.get("type") == t]
    if not es:
        print("  %s · no entry" % t)
    for e in es:
        opens = [k for k in ("allDeclaredFields", "allDeclaredConstructors", "allPublicMethods", "allDeclaredMethods") if e.get(k)]
        ms = sorted("%s(%s)" % (x["name"], ", ".join(x.get("parameterTypes", []))) for x in e.get("methods", []))
        print("  %s · %s · methods: %s" % (t, " ".join(opens) if opens else "nothing whole", " ".join(ms) if ms else "none"))
