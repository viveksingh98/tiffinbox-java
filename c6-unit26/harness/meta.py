#!/usr/bin/env python3
"""meta.py JAR KEY: what a jar's own metadata (META-INF/spring-configuration-metadata.json) says about one key - whether it
declares it, its default ("none" when it gives none), its type, and, when the key is deprecated, since when, at which level
("not given": the metadata format's default, a warning) and the key that replaces it. Reads the jar; changes nothing; no network."""
import json, sys, zipfile

jar, key = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(jar) as z:
    meta = json.loads(z.read("META-INF/spring-configuration-metadata.json"))
found = [p for p in meta.get("properties", []) if p["name"] == key]
if not found:
    print("%s · not declared" % key)
for p in found:
    d = p.get("defaultValue")
    print("%s · default %s · %s" % (key, "none" if d is None else d, p.get("type", "?").rsplit(".", 1)[-1]))
    dep = p.get("deprecation")
    if p.get("deprecated") or dep:
        dep = dep or {}
        print("  deprecated · since %s · level: %s · replacement: %s" % (dep.get("since", "not given"), dep.get("level", "not given"), dep.get("replacement", "none")))
    else:
        print("  not deprecated")
