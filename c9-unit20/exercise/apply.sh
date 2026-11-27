#!/bin/sh
# Course 9 unit 20's exercise: the solution, applied to a broken TREE - the If-Match check back in apply, where both PATCH routes
# pass, as ../after's CustomerPatches.java has it (the file then byte-equal to ../after's). HOW=<variant> applies one of the
# receipt's refused variants instead (each must FAIL check.sh): mergeonly, required, fixedelsewhere. Usage: sh apply.sh TREE
T=${1:?usage: sh apply.sh TREE}
HERE=$(cd "$(dirname "$0")" && pwd -P); AFTER=$(cd "$HERE/../after" && pwd -P)
[ "$(cd "$T" && pwd -P)" != "$AFTER" ] || { echo "apply.sh: refused - that is ../after itself"; exit 1; }
python3 -I - "$T" "$AFTER" "${HOW:-solved}" <<'PY' || exit 1
import sys, os
t, a, how = sys.argv[1:4]
rel = "tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerPatches.java"
f = os.path.join(t, rel); s = open(f, encoding="utf-8").read()
read = "        CustomerRepository.Versioned row = repo.findVersioned(name).orElseThrow(() -> new CustomerNotFound(name));\n"
check = """        if (request.checkNotModified(CustomerReads.tag(row.version()))) {
            return refuse(HttpStatus.PRECONDITION_FAILED, "Precondition failed", "the customer has changed since the tag in If-Match was read");
        }
"""
if s.count(read) != 1 or s.count(check) != 0: sys.exit("apply.sh: this is not break.sh's tree (the read once, the check absent)")
if how in ("solved", "fixedelsewhere"):
    s = s.replace(read, read + check)
elif how == "mergeonly":
    m = "        return apply(name, request, Json.createMergePatch(patch)::apply, false);\n"
    s = s.replace(m, "        if (request.checkNotModified(CustomerReads.tag(repo.findVersioned(name).map(CustomerRepository.Versioned::version).orElse(-1L)))) {\n            return refuse(HttpStatus.PRECONDITION_FAILED, \"Precondition failed\", \"stale\");\n        }\n" + m)
elif how == "required":
    s = s.replace(read, read + check + "        if (request.getHeader(\"If-Match\") == null) {\n            return refuse(HttpStatus.PRECONDITION_REQUIRED, \"Precondition required\", \"send If-Match\");\n        }\n")
else: sys.exit("apply.sh: unknown variant " + how)
open(f, "w", encoding="utf-8").write(s)
if how == "fixedelsewhere":
    g = os.path.join(t, "tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerReads.java")
    open(g, "a", encoding="utf-8").write("// edited elsewhere\n")
if how == "solved":
    same = open(f, "rb").read() == open(os.path.join(a, rel), "rb").read()
    print("apply.sh: the If-Match check back in apply; CustomerPatches.java byte-equal to ../after's: " + ("yes" if same else "no"))
    if not same: sys.exit(1)
else:
    print("apply.sh: variant " + how)
PY
