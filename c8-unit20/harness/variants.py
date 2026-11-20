"""Unit 20's labelled copy of after/ (python3 -I -B harness/variants.py NAME AFTER OUT): AFTER copied to OUT (no target/, no secrets/),
then the lines below changed, and the change printed as a unified diff. It is labelled wherever it prints: a copy is never the
anchor's (R.392). noindex runs it.
  nokey   application-dev.yaml without its spring.data.mongodb.auto-index-creation: true - @Indexed on OrderDocument's customer stays,
          the key that lets the mapper create it is gone (the comment above it stays: a copy)"""
import difflib, os, shutil, sys

NAME, A, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
Y = "tiffinbox-web/src/main/resources/application-dev.yaml"
NOKEY = (Y, "  data:\n    mongodb:\n      auto-index-creation: true\n", "")
F = {"nokey": [NOKEY]}[NAME]
if os.path.exists(OUT): shutil.rmtree(OUT)
shutil.copytree(A, OUT, ignore=shutil.ignore_patterns("target", "secrets", ".m2-demo"))
for f, old, new in F:
    p = os.path.join(OUT, f); s = open(p, encoding="utf-8").read()
    if s.count(old) != 1: print("FAIL the lines to change are not in " + f + " once"); sys.exit(1)
    t = s.replace(old, new)
    open(p, "w", encoding="utf-8").write(t)
    d = [l for l in difflib.unified_diff(s.splitlines(), t.splitlines(), "after/" + f, NAME + "/" + f, lineterm="", n=0) if not l.startswith("@@")]
    print("\n".join(d))
