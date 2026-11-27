#!/bin/sh
# Course 9 unit 19's exercise: the solution, applied to a broken TREE - the key line back to the client's address only, as
# ../after's RateLimitFilter.java has it (the file then byte-equal to ../after's). HOW=<variant> applies one of the receipt's
# refused variants instead (each must FAIL check.sh): trustxff, headerlast, fixedelsewhere. Usage: sh apply.sh TREE
T=${1:?usage: sh apply.sh TREE}
HERE=$(cd "$(dirname "$0")" && pwd -P); AFTER=$(cd "$HERE/../after" && pwd -P)
[ "$(cd "$T" && pwd -P)" != "$AFTER" ] || { echo "apply.sh: refused - that is ../after itself"; exit 1; }
python3 -I - "$T" "$AFTER" "${HOW:-solved}" <<'PY' || exit 1
import sys, os
t, a, how = sys.argv[1:4]
rel = "tiffinbox-web/src/main/java/com/tiffinbox/web/RateLimitFilter.java"
f = os.path.join(t, rel); s = open(f, encoding="utf-8").read()
broken = 'buckets.forAddress(request.getHeader("X-Api-Key") != null ? request.getHeader("X-Api-Key") : request.getRemoteAddr())'
if s.count(broken) != 1: sys.exit("apply.sh: the broken key line is not in RateLimitFilter.java once")
fix = {"solved": "buckets.forAddress(request.getRemoteAddr())",
       "fixedelsewhere": "buckets.forAddress(request.getRemoteAddr())",
       "trustxff": 'buckets.forAddress(request.getHeader("X-Forwarded-For") != null ? request.getHeader("X-Forwarded-For") : request.getRemoteAddr())',
       "headerlast": 'buckets.forAddress(request.getRemoteAddr() != null ? request.getRemoteAddr() : request.getHeader("X-Api-Key"))'}[how]
open(f, "w", encoding="utf-8").write(s.replace(broken, fix))
if how == "fixedelsewhere":
    g = os.path.join(t, "tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeys.java")
    open(g, "a", encoding="utf-8").write("// edited elsewhere\n")
if how == "solved":
    same = open(f, "rb").read() == open(os.path.join(a, rel), "rb").read()
    print("apply.sh: the key line back to the address only; RateLimitFilter.java byte-equal to ../after's: " + ("yes" if same else "no"))
    if not same: sys.exit(1)
else:
    print("apply.sh: variant " + how)
PY
