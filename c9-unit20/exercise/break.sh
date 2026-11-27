#!/bin/sh
# Course 9 unit 20's exercise: the broken tree. TREE is a copy of ../after (never ../after itself); one printed edit to
# tiffinbox-web's CustomerPatches.java - the If-Match check both PATCH routes share (in apply) is removed, so a stale tag writes.
# Usage: sh break.sh TREE
T=${1:?usage: sh break.sh TREE}
HERE=$(cd "$(dirname "$0")" && pwd -P); AFTER=$(cd "$HERE/../after" && pwd -P)
[ "$(cd "$T" && pwd -P)" != "$AFTER" ] || { echo "break.sh: refused - that is ../after itself; copy it first"; exit 1; }
F="$T/tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerPatches.java"
python3 -I - "$F" <<'PY' || exit 1
import sys
f = sys.argv[1]; s = open(f, encoding="utf-8").read()
old = """        if (request.checkNotModified(CustomerReads.tag(row.version()))) {
            return refuse(HttpStatus.PRECONDITION_FAILED, "Precondition failed", "the customer has changed since the tag in If-Match was read");
        }
"""
if s.count(old) != 1: sys.exit("break.sh: the If-Match check is not in CustomerPatches.java once")
open(f, "w", encoding="utf-8").write(s.replace(old, ""))
print("break.sh: CustomerPatches.java - the If-Match check in apply (3 lines: if (request.checkNotModified(...)) { return refuse(412 ...); }) removed")
PY
