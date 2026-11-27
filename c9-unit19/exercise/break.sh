#!/bin/sh
# Course 9 unit 19's exercise: the broken tree. TREE is a copy of ../after (never ../after itself); one printed edit to
# tiffinbox-web's RateLimitFilter.java - its key line reads the header X-Api-Key first, and the client's address only without it:
# a key the caller picks. Usage: sh break.sh TREE
T=${1:?usage: sh break.sh TREE}
HERE=$(cd "$(dirname "$0")" && pwd -P); AFTER=$(cd "$HERE/../after" && pwd -P)
[ "$(cd "$T" && pwd -P)" != "$AFTER" ] || { echo "break.sh: refused - that is ../after itself; copy it first"; exit 1; }
F="$T/tiffinbox-web/src/main/java/com/tiffinbox/web/RateLimitFilter.java"
python3 -I - "$F" <<'PY' || exit 1
import sys
f = sys.argv[1]; s = open(f, encoding="utf-8").read()
old = "buckets.forAddress(request.getRemoteAddr())"
new = 'buckets.forAddress(request.getHeader("X-Api-Key") != null ? request.getHeader("X-Api-Key") : request.getRemoteAddr())'
if s.count(old) != 1: sys.exit("break.sh: the key line is not in RateLimitFilter.java once")
open(f, "w", encoding="utf-8").write(s.replace(old, new))
print("break.sh: RateLimitFilter.java - " + old + " -> " + new)
PY
