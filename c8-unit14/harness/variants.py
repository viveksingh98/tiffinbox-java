"""Unit 14's labelled copies of after/ (python3 -I -B harness/variants.py NAME AFTER OUT): AFTER copied to OUT (no target/, no
secrets/), then ONE line of tiffinbox-web's sources changed, and the change printed as a unified diff. No capture of record runs a
copy: twice and trap are harness steps over the anchor's own jar (harness/src/probe/u14/U14.java - the shipped Leaderboard.record
called twice, Boot's redisTemplate bean), so these two copies serve the planted faults alone, each built offline from its own
sources (-pl tiffinbox-web -am), each run in a scratch mirror, never beside a run of record.
  noreset    TiffinBoxServer.start() without lb.reset() - the fill without the reset in the shipped tree (anchor's three starts fail)
  noprofile  Leaderboard without @Profile("dev") - the bean on the default run (default's /leaderboard is no longer 404)"""
import difflib, os, shutil, sys

NAME, A, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
F, OLD, NEW = {"noreset": ("tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java", "            lb.reset();\n", "            // lb.reset();\n"),
               "noprofile": ("tiffinbox-web/src/main/java/com/tiffinbox/web/Leaderboard.java", '@Profile("dev")\n', '// @Profile("dev")\n')}[NAME]
if os.path.exists(OUT): shutil.rmtree(OUT)
shutil.copytree(A, OUT, ignore=shutil.ignore_patterns("target", "secrets", ".m2-demo"))
p = os.path.join(OUT, F); s = open(p, encoding="utf-8").read()
if s.count(OLD) != 1: print("FAIL the line to change is not in " + F + " once"); sys.exit(1)
t = s.replace(OLD, NEW)
open(p, "w", encoding="utf-8").write(t)
d = [l for l in difflib.unified_diff(s.splitlines(), t.splitlines(), "after/" + F, NAME + "/" + F, lineterm="", n=0) if not l.startswith("@@")]
print("\n".join(d))
