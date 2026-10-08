#!/usr/bin/env python3
"""The harness's reader of jars and POMs - the course's, never TiffinBox's. Every number it prints is counted from the files
named on its command line, on the day; nothing is typed. receipts.sh runs it; README.md declares each filter.

  jars.py bom POM...             the modules a BOM manages: its <dependencyManagement> entries, those with groupId
                                 org.springframework.boot, and of those the starters (artifactId holds "starter") and the rest
  jars.py props KEY,KEY POM...   the values of those <properties> in each POM ("-" where the POM has none), one row per key,
                                 then how many properties each POM has, and how many of them the table does not show
  jars.py mentions WORD POM...   how many lines of each POM mention WORD, in any case
  jars.py deps POM...            each POM's own <dependencies> (not managed ones), test scope left out: groupId:artifactId
  jars.py meta KEY JAR...        KEY in each jar's META-INF/spring-configuration-metadata.json: its type, and its deprecation
                                 (level, replacement, since) as the jar's own metadata says it
  jars.py annos JAR DESC...      the package-info classes in JAR, and how many of them name each annotation DESC (a class
                                 file's descriptor, as Lorg/jspecify/annotations/NullMarked; - read from the class's bytes)
  jars.py ctors CLASS JAR...     CLASS's public constructors in each jar (javap), by their number of arguments; then, for each
                                 number every jar has, whether the signatures are the same in all of them
  jars.py imports SRC OLDJARS NEWJARS
                                 every org.springframework.boot import in SRC's src/main/java files (one per class), looked up by
                                 its path in the jars of OLDJARS (a colon-separated list) - the same package and name; else
                                 the same simple name in another package of those jars (moved); else not in them - then, for
                                 the ones not in them, which of NEWJARS holds the class
"""
import json, os, re, sys, zipfile
import xml.etree.ElementTree as ET

NS = {"m": "http://maven.apache.org/POM/4.0.0"}


def pom(f):
    return ET.parse(f).getroot()


def bom(files):
    for f in files:
        r = pom(f)
        deps = r.findall("m:dependencyManagement/m:dependencies/m:dependency", NS)
        boot = [d.findtext("m:artifactId", namespaces=NS) for d in deps if d.findtext("m:groupId", namespaces=NS) == "org.springframework.boot"]
        st = [a for a in boot if "starter" in a]
        print(f"{os.path.basename(f)}: entries {len(deps)} · org.springframework.boot {len(boot)} · starters {len(st)} · the rest, modules {len(boot) - len(st)}")


def props(keys, files):
    keys = keys.split(",")
    rows = {f: pom(f) for f in files}
    w = max(len(k) for k in keys)
    print("property".ljust(w) + "  " + "  ".join(os.path.basename(f) for f in files))
    for k in keys:
        print(k.ljust(w) + "  " + "  ".join((rows[f].findtext("m:properties/m:" + k, namespaces=NS) or "-").ljust(len(os.path.basename(f))) for f in files).rstrip())
    for f in files:
        n = len(list(rows[f].find("m:properties", NS)))
        k = sum(1 for k in keys if rows[f].findtext("m:properties/m:" + k, namespaces=NS) is not None)
        print(f"{os.path.basename(f)}: properties {n} · in this table {k} · not shown {n - k}")


def mentions(word, files):
    for f in files:
        print(f"{os.path.basename(f)}: lines that mention {word}, in any case: " + str(sum(1 for line in open(f, encoding="utf-8") if word.lower() in line.lower())))


def deps(files):
    for f in files:
        r = pom(f)
        ds = [d for d in r.findall("m:dependencies/m:dependency", NS) if d.findtext("m:scope", namespaces=NS) != "test"]
        print(f"{os.path.basename(f)}: " + " · ".join(d.findtext("m:groupId", namespaces=NS) + ":" + d.findtext("m:artifactId", namespaces=NS) for d in ds))


def meta(key, files):
    for j in files:
        d = json.loads(zipfile.ZipFile(j).read("META-INF/spring-configuration-metadata.json"))
        hit = [p for p in d.get("properties", []) if p["name"] == key]
        if not hit:
            print(f"{os.path.basename(j)}: {key} - not in its metadata")
            continue
        for p in hit:
            dep = p.get("deprecation")
            how = "not deprecated" if dep is None and not p.get("deprecated") else (
                "deprecated · level " + (dep or {}).get("level", "warning") + " · replacement " + str((dep or {}).get("replacement")) + " · since " + str((dep or {}).get("since")))
            print(f"{os.path.basename(j)}: {key} · type {p.get('type')} · {how}")


def imports(src, olds, news):
    old = set()
    for j in olds.split(":"):
        old |= {n for n in zipfile.ZipFile(j).namelist() if n.endswith(".class")}
    new = {}
    for j in news.split(":"):
        for n in zipfile.ZipFile(j).namelist():
            if n.endswith(".class"):
                new.setdefault(n, os.path.basename(j))
    found = {}
    files = sorted(os.path.join(dp, f) for dp, _, fs in os.walk(src) for f in fs if f.endswith(".java") and "/src/main/java/" in os.path.join(dp, f))
    for f in files:
        for line in open(f, encoding="utf-8"):
            m = re.match(r"import (org\.springframework\.boot\.[\w.]+);", line)
            if m:
                found.setdefault(m.group(1), set()).add(os.path.basename(f))
    same, moved, absent = [], [], []
    for c in sorted(found):
        p = c.replace(".", "/") + ".class"
        if p in old:
            same.append(c)
            continue
        simple = "/" + c.rsplit(".", 1)[1] + ".class"
        there = sorted(n for n in old if n.endswith(simple))
        (moved if there else absent).append((c, there))
    print(f"source files {len(files)} · org.springframework.boot imports, one per class: {len(found)}")
    print(f"the same package and name in 3.5.16's jars: {len(same)}")
    print(f"moved - the same name, another package in 3.5.16's jars: {len(moved)}")
    for c, there in moved:
        print(f"  {c}  (in {', '.join(sorted(found[c]))}) - 3.5.16: {' '.join(t[:-6].replace('/', '.') for t in there)}")
    print(f"in none of them: {len(absent)} - each in TiffinBox's jars, by the jar that holds it:")
    by = {}
    for c, _ in absent:
        by.setdefault(new.get(c.replace(".", "/") + ".class", "(none)"), []).append(c.rsplit(".", 1)[1])
    for j in sorted(by):
        print(f"  {j}: {len(by[j])} - {' '.join(by[j])}")


def annos(j, descs):
    z = zipfile.ZipFile(j)
    pi = [n for n in z.namelist() if n.endswith("/package-info.class")]
    print(f"{os.path.basename(j)}: package-info classes {len(pi)} · " + " · ".join(
        d.strip("L;").rsplit("/", 1)[1] + " " + str(sum(1 for n in pi if d.encode() in z.read(n))) for d in descs))


def ctors(cls, files):
    import subprocess
    sig = {}
    for j in files:
        out = subprocess.run(["javap", "-cp", j, cls], capture_output=True, text=True, check=True).stdout
        mine = {}
        for line in out.splitlines():
            m = re.match(r"\s*public " + re.escape(cls) + r"\((.*)\);$", line)
            if m:
                a, d, n = m.group(1), 0, (1 if m.group(1) else 0)
                for ch in a:
                    d += (ch == "<") - (ch == ">")
                    n += (ch == "," and d == 0)
                mine[n] = a
        sig[j] = mine
        print(f"{os.path.basename(j)}: public constructors {len(mine)} · their arguments: " + ", ".join(str(k) for k in sorted(mine)))
    for k in sorted(set.intersection(*(set(v) for v in sig.values()))):
        same = len({v[k] for v in sig.values()}) == 1
        print(f"the {k}-argument constructor, in every jar above: " + ("the same signature" if same else "different signatures"))


if __name__ == "__main__":
    a = sys.argv[1:]
    {"bom": lambda: bom(a[1:]), "props": lambda: props(a[1], a[2:]), "deps": lambda: deps(a[1:]), "mentions": lambda: mentions(a[1], a[2:]),
     "meta": lambda: meta(a[1], a[2:]), "imports": lambda: imports(a[1], a[2], a[3]),
     "annos": lambda: annos(a[1], a[2:]), "ctors": lambda: ctors(a[1], a[2:])}[a[0]]()
