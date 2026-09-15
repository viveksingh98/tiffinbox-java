# Exercise 27 — the class that is not in the binary

`start/reflect-config.json` is the reachability metadata for a closed-world build of this
project. It was written by someone who tested the default path — `plain` — and it is
correct for that path.

```
python3 - <<'PY'
import json
names = {e["name"] for e in json.load(open("start/reflect-config.json"))}
want  = {l.split("=",1)[1].strip()
         for l in open("../src/main/resources/formatters.properties")
         if l.startswith(("plain=","ledger="))}
print("named in formatters.properties:", len(want))
print("covered by the metadata:       ", len(want & names))
print("missing:                       ", sorted(want - names))
PY
```

**Start state:** two formatter classes are named in `formatters.properties`, **one** of them
is covered. A binary built from this metadata starts, runs `plain` correctly, and dies on
`ledger` with `ClassNotFoundException` — at run time, in production, on the path nobody
tested.

**End state:** the same script prints `covered: 2` and `missing: []`, with **0 lines of Java
changed**.

Two things worth noticing while you do it:

1. The fix is **data**, not code. That is the whole shape of closed-world configuration.
2. The check above needs **no GraalVM at all**. It is eight lines of Python over two files
   you already have, it runs in CI, and it costs no build minutes. A team that cannot
   afford a native build on every push can still afford this.

The answer is `solution/reflect-config.json`, and `../receipts.sh solution` runs both states
and stops if the start state already covers everything.
