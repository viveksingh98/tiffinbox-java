"""Unit 13's labelled copies of after/ (python3 -I -B harness/variants.py NAME AFTER OUT): AFTER copied to OUT (no target/, no
secrets/), then ONE line of tiffinbox-core's CustomerRepository.java changed - findByName's annotation - and the change printed as a
unified diff. Nothing else in the copy moves; the receipt builds each copy offline from its own sources (-pl tiffinbox-web -am).
  nounless    @Cacheable(cacheNames = "customer")                                    - the empty answer kept (nulls, nonull)
  syncunless  @Cacheable(cacheNames = "customer", sync = true, unless = "#result == null")  - the failure receipt (syncunless)"""
import difflib, os, shutil, sys

NAME, A, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
F = "tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java"
OLD = '    @Cacheable(cacheNames = "customer", unless = "#result == null")\n'
NEW = {"nounless": '    @Cacheable(cacheNames = "customer")\n',
       "syncunless": '    @Cacheable(cacheNames = "customer", sync = true, unless = "#result == null")\n'}[NAME]
if os.path.exists(OUT): shutil.rmtree(OUT)
shutil.copytree(A, OUT, ignore=shutil.ignore_patterns("target", "secrets", ".m2-demo"))
p = os.path.join(OUT, F); s = open(p, encoding="utf-8").read()
if s.count(OLD) != 1: print("FAIL the anchor's findByName annotation is not in " + F + " once"); sys.exit(1)
t = s.replace(OLD, NEW)
open(p, "w", encoding="utf-8").write(t)
d = [l for l in difflib.unified_diff(s.splitlines(), t.splitlines(), "after/" + F, NAME + "/" + F, lineterm="", n=0) if not l.startswith("@@")]
print("\n".join(d))
