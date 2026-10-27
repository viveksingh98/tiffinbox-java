#!/usr/bin/env python3
"""deps.py JAR CLASS: what the class files say about deprecation - CLASS and every class nested in it (CLASS$...), each read from
JAR with `javap -v -p` (every member, the private ones too). A class file marks a deprecated class or member with a Deprecated
attribute, and @Deprecated adds a runtime annotation whose since= and forRemoval= it carries. One line per class file: its name,
javap's line count, its members (fields and methods: javap's descriptor lines), the Deprecated attributes on the class and on its
members, and each deprecated thing by name with its annotation's values; then the total. Reads the jar; changes nothing; no network."""
import re, subprocess, sys, zipfile

jar, cls = sys.argv[1], sys.argv[2]
base = cls.replace(".", "/")
with zipfile.ZipFile(jar) as z:
    names = sorted(e[:-6].replace("/", ".") for e in z.namelist()
                   if e == base + ".class" or (e.startswith(base + "$") and e.endswith(".class")))
tot = 0
for n in names:
    out = subprocess.run(["javap", "-v", "-p", "-cp", jar, n], capture_output=True, text=True, check=True).stdout.splitlines()
    members = sum(1 for l in out if re.match(r"^    descriptor: ", l))
    on_class, found, last, ann = 0, [], None, None
    for i, l in enumerate(out):
        if re.match(r"^  [^ #].*;$", l) and not l.startswith("  Last modified"):
            last = l.strip().rstrip(";")
        if l == "Deprecated: true":
            on_class += 1
            found.append(("the class", i))
        elif l == "    Deprecated: true":
            found.append((last, i))
    said = []
    for what, i in found:
        vals = []
        for l in out[i + 1:i + 8]:
            m = re.match(r"^ +(since|forRemoval)=(.*)$", l)
            if m: vals.append("%s=%s" % m.groups())
            if l.strip() == ")": break
        said.append("%s (@Deprecated%s)" % (what, "(" + ", ".join(vals) + ")" if vals else ""))
    tot += len(found)
    print("%s · javap: %d lines · members: %d · Deprecated attributes: on the class %d, on members %d%s"
          % (n, len(out), members, on_class, len(found) - on_class, "".join(" · " + s for s in said)))
print("class files read: %d · Deprecated attributes in all: %d" % (len(names), tot))
