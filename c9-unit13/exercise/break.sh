#!/bin/sh
# Course 9 unit 13's exercise: break a COPY of ../after - the order list's sort whitelist removed, so the cursor route takes any sort a
# client sends (its name goes to Spring Data as a property). Usage: sh break.sh TREE   (TREE: a copy of ../after, never ../after itself)
T=${1:?usage: sh break.sh TREE}
[ -d "$T/tiffinbox-web" ] || { echo "break.sh: $T is not a copy of ../after"; exit 1; }
[ "$(cd "$T" && pwd -P)" != "$(cd "$(dirname "$0")/../after" && pwd -P)" ] || { echo "break.sh: refused - that is ../after itself; copy it first"; exit 1; }
F="$T/tiffinbox-web/src/main/java/com/tiffinbox/web/OrderPages.java"
python3 -I - "$F" <<'PY'
import sys
p = sys.argv[1]; s = open(p).read()
a = '        Sort s = SORTS.get(sort);\n        if (s == null) throw refusal("sort-unknown", "Unknown sort", "sort must be one of " + SORTS.keySet());\n'
b = '        Sort s = SORTS.getOrDefault(sort, Sort.by(Sort.Direction.ASC, sort));\n'
if a not in s:
    sys.exit("break.sh: the whitelist check is not in %s (already broken?)" % p)
open(p, "w").write(s.replace(a, b))
print("break.sh: OrderPages.java - the whitelist check removed (an unknown sort now goes to Spring Data as a property name)")
PY
