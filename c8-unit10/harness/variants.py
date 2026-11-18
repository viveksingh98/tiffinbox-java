"""Unit 10's harness copy, derived from the shipped file at run time - never a typed copy (python3 -I -B harness/variants.py TREE).
TREE is a copy of after/; one variant is written into it, and asserted to differ from its source by exactly the named change (else
exit 1, nothing written):
  nonames   application.yaml without spring.cache.cache-names (its one line removed; the comment above it and the Caffeine spec
            unchanged) - the failure receipt and the exercise's broken state
It prints the removed line (diff-style, < removed)."""
import difflib, os, sys
tree = sys.argv[1]
P = os.path.join(tree, "tiffinbox-web/src/main/resources/application.yaml")
src = open(P, encoding="utf-8").read()
old = "  cache:\n    cache-names: customers\n    caffeine:\n"
if src.count(old) != 1:
    print("variant nonames: the shipped lines moved (spring.cache.cache-names: customers above caffeine:)"); sys.exit(1)
dst = src.replace(old, "  cache:\n    caffeine:\n")
d = [l for l in difflib.unified_diff(src.splitlines(), dst.splitlines(), lineterm="", n=0) if l[:1] in "+-" and not l.startswith(("+++", "---"))]
if d != ["-    cache-names: customers"]:
    print("variant nonames: its change is not the named one: %s" % d); sys.exit(1)
open(P, "w", encoding="utf-8").write(dst)
print("tiffinbox-web/src/main/resources/application.yaml - from after/'s:")
for l in d:
    print("  < " + l[1:].strip())
