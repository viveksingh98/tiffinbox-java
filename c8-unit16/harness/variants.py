"""Unit 16's labelled copies of after/ (python3 -I -B harness/variants.py NAME AFTER OUT): AFTER copied to OUT (no target/, no
secrets/), then ONE line of tiffinbox-web's sources changed, and the change printed as a unified diff. No capture of record runs a
copy: the copies serve the planted faults alone, each checked by chk16.py static on its own tree (and inside, once, by a dev run on
PostgreSQL), in a scratch mirror, never beside a run of record.
  noprofile  KitchenEvents without @Profile("dev") - the listener on the default run (static's ⚑4 check; default's bean count 0)
  mapof      KitchenEvents' fields from a Map.of - an order that moves from one JVM to the next (static's R.411 check; anchor's order)
  inside     KitchenEvents hearing CustomerAdded with @EventListener - inside add's transaction, before the commit (static's ⚑7
             check; anchor's refused add, whose stream length must not move)"""
import difflib, os, shutil, sys

NAME, A, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
W = "tiffinbox-web/src/main/java/com/tiffinbox/web/"
KE = W + "KitchenEvents.java"
F = {"noprofile": [(KE, '@Profile("dev")\nclass KitchenEvents {', '// @Profile("dev")\nclass KitchenEvents {')],
     "mapof": [(KE, '        var fields = new LinkedHashMap<String, String>();\n        fields.put("type", "customer-added");\n        fields.put("name", e.customer().name());\n        fields.put("mealType", e.customer().mealType());\n',
                '        var fields = java.util.Map.of("type", "customer-added", "name", e.customer().name(), "mealType", e.customer().mealType());\n')],
     "inside": [(KE, "    @TransactionalEventListener\n    void stored(", "    @org.springframework.context.event.EventListener\n    void stored(")]}[NAME]
if os.path.exists(OUT): shutil.rmtree(OUT)
shutil.copytree(A, OUT, ignore=shutil.ignore_patterns("target", "secrets", ".m2-demo"))
for f, old, new in F:
    p = os.path.join(OUT, f); s = open(p, encoding="utf-8").read()
    if s.count(old) != 1: print("FAIL the lines to change are not in " + f + " once"); sys.exit(1)
    t = s.replace(old, new)
    open(p, "w", encoding="utf-8").write(t)
    d = [l for l in difflib.unified_diff(s.splitlines(), t.splitlines(), "after/" + f, NAME + "/" + f, lineterm="", n=0) if not l.startswith("@@")]
    print("\n".join(d))
