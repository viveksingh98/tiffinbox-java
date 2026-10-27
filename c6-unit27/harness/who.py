#!/usr/bin/env python3
"""who.py NAME JAR...: which class files in the jars name the class NAME (slashes: org/springframework/web/client/RestTemplate) -
a class file names another class in its constant pool, by that string, when it uses it: as a type, a field, a call, a cast. A match
is the string followed by anything that cannot continue a Java name (so RestTemplateBuilder, in another package, is not
RestTemplate; RestTemplate$X, a class nested in it, is). Prints one line for each jar where some class file names NAME, and for each
of TiffinBox's own jars (tiffinbox-*) whatever it holds - the jar's name, its class files, how many name NAME - and under it each of
them, sorted; then how many jars it read where none does (counted, not listed), and the totals. Reads the jars; changes nothing; no
network."""
import re, sys, zipfile

name, jars = sys.argv[1].encode(), sys.argv[2:]
pat = re.compile(re.escape(name) + rb"(?![A-Za-z0-9_])")
tot = hit = none = 0
for j in jars:
    with zipfile.ZipFile(j) as z:
        cls = [e for e in z.namelist() if e.endswith(".class")]
        found = sorted(e for e in cls if pat.search(z.read(e)))
    tot += len(cls); hit += len(found)
    base = j.rsplit("/", 1)[-1]
    if not found and not base.startswith("tiffinbox-"):
        none += 1
        continue
    print("%s · class files: %d · naming it: %d" % (j.rsplit("/", 1)[-1], len(cls), len(found)))
    for e in found:
        print("    " + e[:-6].replace("BOOT-INF/classes/", "").replace("/", "."))
print("jars where no class file names it: %d (not listed)" % none)
print("jars read: %d · class files read: %d · naming %s: %d" % (len(jars), tot, sys.argv[1].replace("/", "."), hit))
