#!/bin/sh
# Course 9 unit 14's exercise: break a COPY of ../after - the customer list's projection removed, so the route reads fields and ignores
# it: every customer comes back whole, whatever a client asks. Usage: sh break.sh TREE   (TREE: a copy of ../after, never ../after itself)
T=${1:?usage: sh break.sh TREE}
[ -d "$T/tiffinbox-web" ] || { echo "break.sh: $T is not a copy of ../after"; exit 1; }
[ "$(cd "$T" && pwd -P)" != "$(cd "$(dirname "$0")/../after" && pwd -P)" ] || { echo "break.sh: refused - that is ../after itself; copy it first"; exit 1; }
F="$T/tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerFields.java"
python3 -I - "$F" <<'PY'
import sys
p = sys.argv[1]; s = open(p).read()
i = s.find('        List<Customer> all = customers.findAll();\n'); j = s.find('        }).toList();\n')
if i < 0 or j < 0:
    sys.exit("break.sh: the projection is not in %s (already broken?)" % p)
j += len('        }).toList();\n')
open(p, "w").write(s[:i] + '        return customers.findAll();\n' + s[j:])
print("break.sh: CustomerFields.java - the projection removed (fields is read, and ignored: every customer comes back whole)")
PY
