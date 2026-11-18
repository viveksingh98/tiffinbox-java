"""Unit 08's harness copy, derived from the shipped file at run time - never a typed copy (python3 -I -B harness/variants.py TREE).
TREE is a copy of after/; one variant is written into it, and asserted to differ from its source by exactly the named change (else
exit 1, nothing written):
  off   TiffinBoxApp.java without @EnableCaching (the annotation's line and its import line removed; the Javadoc unchanged) - the
        failure receipt and the exercise's broken state
It prints the removed lines (diff-style, < removed)."""
import difflib, os, sys
tree = sys.argv[1]
P = os.path.join(tree, "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java")
src = open(P, encoding="utf-8").read()


def one(s, old, new):
    assert s.count(old) == 1, "the shipped line moved: " + old.strip()
    return s.replace(old, new)


dst = one(one(src, "import org.springframework.cache.annotation.EnableCaching;\n", ""), "@EnableJpaAuditing\n@EnableCaching\n", "@EnableJpaAuditing\n")
d = [l for l in difflib.unified_diff(src.splitlines(), dst.splitlines(), lineterm="", n=0) if l[:1] in "+-" and not l.startswith(("+++", "---"))]
if sorted(d) != sorted(["-import org.springframework.cache.annotation.EnableCaching;", "-@EnableCaching"]):
    print("variant off: its change is not the named one: %s" % d); sys.exit(1)
open(P, "w", encoding="utf-8").write(dst)
print("tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java - from after/'s:")
for l in d:
    print("  < " + l[1:].strip())
