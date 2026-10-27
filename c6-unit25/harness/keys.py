#!/usr/bin/env python3
"""keys.py JAR PREFIX: the configuration keys a jar's own metadata (META-INF/spring-configuration-metadata.json) declares under
PREFIX, in the metadata's order - each key's name, its default as the metadata gives it ("none" when it gives none) and its type;
then how many. Reads the jar; changes nothing; no network."""
import json, sys, zipfile

jar, prefix = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(jar) as z:
    meta = json.loads(z.read("META-INF/spring-configuration-metadata.json"))
keys = [p for p in meta.get("properties", []) if p["name"].startswith(prefix)]
for p in keys:
    d = p.get("defaultValue")
    d = "none" if d is None else (str(d).lower() if isinstance(d, bool) else str(d))
    print("%s · default %s · %s" % (p["name"], d, p.get("type", "?").rsplit(".", 1)[-1]))
print("%d keys under %s" % (len(keys), prefix))
