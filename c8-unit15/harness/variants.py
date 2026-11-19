"""Unit 15's labelled copies of after/ (python3 -I -B harness/variants.py NAME AFTER OUT): AFTER copied to OUT (no target/, no
secrets/), then ONE line of tiffinbox-web's sources changed, and the change printed as a unified diff. No capture of record runs a
copy: stale's keyspace events OFF is the repository harness's own configuration over the shipped classes (harness/src/probe/u15/H15.java,
h15.mode=off), and startstop's adapter failure is the shipped RedisDatastore itself in that harness. These copies serve the planted
faults alone: each is checked by chk15.py static on its own tree, in a scratch mirror, never beside a run of record.
  noprofile  RedisDatastore without @Profile("dev") - ON_STARTUP on the default run (static's ⚑4 check)
  uuid       the start's ids from UUID.randomUUID() - ids that differ each start (static's deterministic-id check; anchor's three starts)
  nottl      the start's save without the time to live (null) - every order untimed (static's save check; ttl's PTTL > 0)
  off        RedisDatastore with keyspace events OFF - the stale index in the shipped tree (static's ⚑6 check; stale's count())"""
import difflib, os, shutil, sys

NAME, A, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
W = "tiffinbox-web/src/main/java/com/tiffinbox/web/"
F, OLD, NEW = {"noprofile": (W + "RedisDatastore.java", '@Profile("dev")\n', '// @Profile("dev")\n'),
               "uuid": (W + "TiffinBoxServer.java", 'orders.save(new KitchenOrder(c.name() + "-" + (day + 1), ', 'orders.save(new KitchenOrder(java.util.UUID.randomUUID().toString(), '),
               "nottl": (W + "TiffinBoxServer.java", "order.value(), orderTtl));", "order.value(), null));"),
               "off": (W + "RedisDatastore.java", "enableKeyspaceEvents = EnableKeyspaceEvents.ON_STARTUP)", "enableKeyspaceEvents = EnableKeyspaceEvents.OFF)")}[NAME]
if os.path.exists(OUT): shutil.rmtree(OUT)
shutil.copytree(A, OUT, ignore=shutil.ignore_patterns("target", "secrets", ".m2-demo"))
p = os.path.join(OUT, F); s = open(p, encoding="utf-8").read()
if s.count(OLD) != 1: print("FAIL the line to change is not in " + F + " once"); sys.exit(1)
t = s.replace(OLD, NEW)
open(p, "w", encoding="utf-8").write(t)
d = [l for l in difflib.unified_diff(s.splitlines(), t.splitlines(), "after/" + F, NAME + "/" + F, lineterm="", n=0) if not l.startswith("@@")]
print("\n".join(d))
