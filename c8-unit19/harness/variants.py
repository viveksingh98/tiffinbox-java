"""Unit 19's labelled copy of after/ (python3 -I -B harness/variants.py NAME AFTER OUT): AFTER copied to OUT (no target/, no secrets/),
then the lines below changed, and the change printed as a unified diff. It is labelled wherever it prints: a copy is never the
anchor's (R.392). twice runs it beside after/'s two starts.
  noreset   TiffinBoxServer.start() without copies.reset(): the orders' copy inserted with nothing removed first (twice)"""
import difflib, os, shutil, sys

NAME, A, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
S = "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java"
NORESET = (S, "        if (copies != null) {\n            copies.reset();\n        }\n", "")
F = {"noreset": [NORESET]}[NAME]
if os.path.exists(OUT): shutil.rmtree(OUT)
shutil.copytree(A, OUT, ignore=shutil.ignore_patterns("target", "secrets", ".m2-demo"))
for f, old, new in F:
    p = os.path.join(OUT, f); s = open(p, encoding="utf-8").read()
    if s.count(old) != 1: print("FAIL the lines to change are not in " + f + " once"); sys.exit(1)
    t = s.replace(old, new)
    open(p, "w", encoding="utf-8").write(t)
    d = [l for l in difflib.unified_diff(s.splitlines(), t.splitlines(), "after/" + f, NAME + "/" + f, lineterm="", n=0) if not l.startswith("@@")]
    print("\n".join(d))
