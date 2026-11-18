"""Unit 09's copies, derived from the shipped files at run time - never a typed copy (python3 -I -B harness/variants.py VARIANT DIR).
DIR is a copy; one variant is written into it and asserted to differ from its source by exactly the named change (else exit 1,
nothing written). It prints the lines it added or changed (diff-style: < removed, > added).
  caffeine DIR    a copy of the anchor (../c8-unit08/after): tiffinbox-web/pom.xml gains com.github.ben-manes.caffeine:caffeine
                  (no version typed: Boot's parent manages it), right after spring-boot-starter-cache
  redis DIR       the same, with org.springframework.boot:spring-boot-starter-data-redis
  both DIR        the same, with both (Caffeine first, then the Redis starter)
  finalclass DIR  a copy of harness/src/probe/u09: FinalOne.java's Reads becomes a final class (one word added)
  key DIR         a copy of harness/src/probe/u09: H09.java's kSpel gets a key of its own, "#root.methodName + ':' + #a" (the
                  exercise's solution - the method's name in its key)"""
import difflib, os, sys

V, D = sys.argv[1], sys.argv[2]
ANCHOR = "    <dependency>\n      <groupId>org.springframework.boot</groupId>\n      <artifactId>spring-boot-starter-cache</artifactId>\n    </dependency>\n"
DEP = {"caffeine": ("com.github.ben-manes.caffeine", "caffeine"), "redis": ("org.springframework.boot", "spring-boot-starter-data-redis")}


def dep(g, a):
    return "    <dependency>\n      <groupId>%s</groupId>\n      <artifactId>%s</artifactId>\n    </dependency>\n" % (g, a)


def one(s, old, new):
    if s.count(old) != 1:
        print("variant %s: the shipped text moved (%d matches): %s" % (V, s.count(old), old.strip().splitlines()[0])); sys.exit(1)
    return s.replace(old, new)


if V in ("caffeine", "redis", "both"):
    P, rel = os.path.join(D, "tiffinbox-web/pom.xml"), "tiffinbox-web/pom.xml"
    names = ["caffeine", "redis"] if V == "both" else [V]
    src = open(P, encoding="utf-8").read()
    dst = one(src, ANCHOR, ANCHOR + "".join(dep(*DEP[n]) for n in names))
    want = []
    for n in names: want += ["+" + l for l in dep(*DEP[n]).splitlines()]
elif V == "finalclass":
    P, rel = os.path.join(D, "FinalOne.java"), "FinalOne.java"
    src = open(P, encoding="utf-8").read()
    dst = one(src, "    public static class Reads {\n", "    public static final class Reads {\n")
    want = ["-    public static class Reads {", "+    public static final class Reads {"]
elif V == "key":
    P, rel = os.path.join(D, "H09.java"), "H09.java"
    src = open(P, encoding="utf-8").read()
    dst = one(src, '        @Cacheable(cacheNames = "h09:keys", key = "#a")\n', '        @Cacheable(cacheNames = "h09:keys", key = "#root.methodName + \':\' + #a")\n')
    want = ['-        @Cacheable(cacheNames = "h09:keys", key = "#a")', '+        @Cacheable(cacheNames = "h09:keys", key = "#root.methodName + \':\' + #a")']
else:
    print("no variant " + V); sys.exit(1)
d = [l for l in difflib.unified_diff(src.splitlines(), dst.splitlines(), lineterm="", n=0) if l[:1] in "+-" and not l.startswith(("+++", "---"))]
if sorted(d) != sorted(want):
    print("variant %s: its change is not the named one: %s" % (V, d)); sys.exit(1)
open(P, "w", encoding="utf-8").write(dst)
print("%s - variant %s, from the shipped file's:" % (rel, V))
for l in want:
    print("  %s %s" % ("<" if l[0] == "-" else ">", l[1:].strip()))
