#!/bin/sh
# break.sh TREE - makes the exercise's start on a copy of ../after: one python edit of the committed file
# tiffinbox-web/src/test/resources/openapi/tiffinbox.json - the address key of the public read, "/api/v1/customers/{name}", becomes
# "/api/v1/customer/{name}", an address the application does not serve. Nothing else in the tree moves.
[ -n "$1" ] && [ -d "$1" ] || { echo "break.sh TREE"; exit 1; }
rpath=$(cd "$1" && pwd)
[ "$rpath" != "$(cd ../after && pwd)" ] || { echo "break.sh: ../after is unit 10's frozen tree - break a copy of it"; exit 1; }
python3 -I - "$rpath/tiffinbox-web/src/test/resources/openapi/tiffinbox.json" <<'PY'
import sys
f = sys.argv[1]; s = open(f, encoding="utf-8").read()
a = '    "/api/v1/customers/{name}": {\n'; b = '    "/api/v1/customer/{name}": {\n'
assert s.count(a) == 1, ("the public read's address key", s.count(a))
open(f, "w", encoding="utf-8").write(s.replace(a, b))
print("break.sh: the committed file's address key %s -> %s" % (a.strip()[:-3], b.strip()[:-3]))
PY
