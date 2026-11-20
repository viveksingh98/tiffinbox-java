"""Unit 18's labelled copies of after/ (python3 -I -B harness/variants.py NAME AFTER OUT): AFTER copied to OUT (no target/, no
secrets/), then the lines below changed, and the change printed as a unified diff. They are labelled wherever they print: a copy is
never the anchor's (R.392). default runs starteronly and healthkey beside after/ itself; twice runs noreset beside after/'s two starts.
  starteronly  application.yaml without the three-class exclude: the starter alone, as a build would hold it before the list (default)
  healthkey    the same, plus management.health.mongodb.enabled: false - the health key alone, the exercise's broken state (default)
  noreset      TiffinBoxServer.start() without menus.reset(): the fill inserts the thirty days with nothing removed first (twice)"""
import difflib, os, shutil, sys

NAME, A, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
Y = "tiffinbox-web/src/main/resources/application.yaml"
S = "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java"
EXCL = (Y, "  autoconfigure:\n    exclude:\n"
           "      - org.springframework.boot.mongodb.autoconfigure.MongoAutoConfiguration\n"
           "      - org.springframework.boot.data.mongodb.autoconfigure.DataMongoAutoConfiguration\n"
           "      - org.springframework.boot.data.mongodb.autoconfigure.DataMongoRepositoriesAutoConfiguration\n", "")
HKEY = (Y, "  health:\n    redis:\n      enabled: false\n", "  health:\n    redis:\n      enabled: false\n    mongodb:\n      enabled: false\n")
NORESET = (S, "            menus.reset();\n", "")
F = {"starteronly": [EXCL], "healthkey": [EXCL, HKEY], "noreset": [NORESET]}[NAME]
if os.path.exists(OUT): shutil.rmtree(OUT)
shutil.copytree(A, OUT, ignore=shutil.ignore_patterns("target", "secrets", ".m2-demo"))
for f, old, new in F:
    p = os.path.join(OUT, f); s = open(p, encoding="utf-8").read()
    if s.count(old) != 1: print("FAIL the lines to change are not in " + f + " once"); sys.exit(1)
    t = s.replace(old, new)
    open(p, "w", encoding="utf-8").write(t)
    d = [l for l in difflib.unified_diff(s.splitlines(), t.splitlines(), "after/" + f, NAME + "/" + f, lineterm="", n=0) if not l.startswith("@@")]
    print("\n".join(d))
