#!/bin/sh
# Course 9 unit 18's exercise: break a COPY of ../after - the signed download's declared return type made a wildcard, ResponseEntity<?>,
# so GET /api/v1/customers/{name}/bill/signed answers an error while the bill streams fine elsewhere. Usage: sh break.sh TREE
# (TREE: a copy of ../after, never ../after itself)
T=${1:?usage: sh break.sh TREE}
[ -d "$T/tiffinbox-web" ] || { echo "break.sh: $T is not a copy of ../after"; exit 1; }
[ "$(cd "$T" && pwd -P)" != "$(cd "$(dirname "$0")/../after" && pwd -P)" ] || { echo "break.sh: refused - that is ../after itself; copy it first"; exit 1; }
F="$T/tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerBills.java"
python3 -I - "$F" <<'PY'
import sys
p = sys.argv[1]; s = open(p).read()
a = "    ResponseEntity<StreamingResponseBody> signedBill("
if s.count(a) != 1:
    sys.exit("break.sh: the signed download's declared type is not in %s (already broken?)" % p)
open(p, "w").write(s.replace(a, "    ResponseEntity<?> signedBill(", 1))
print("break.sh: CustomerBills.java - the signed download declared ResponseEntity<?> (the bill and the mint untouched)")
PY
