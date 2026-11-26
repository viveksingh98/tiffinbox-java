#!/bin/sh
# Course 9 unit 13's exercise, the solution: restore the sort whitelist in a broken copy (break.sh's), byte for byte as ../after has it.
# Usage: sh apply.sh TREE. HOW (the receipts' refused variants only): unboundcursor, rawsort, fixedelsewhere, typed404.
T=${1:?usage: sh apply.sh TREE}
[ "$(cd "$T" && pwd -P)" != "$(cd "$(dirname "$0")/../after" && pwd -P)" ] || { echo "apply.sh: refused - that is ../after itself"; exit 1; }
F="$T/tiffinbox-web/src/main/java/com/tiffinbox/web/OrderPages.java"
python3 -I - "$F" "${HOW:-solved}" "$T" <<'PY'
import sys
p, how, tree = sys.argv[1], sys.argv[2], sys.argv[3]; s = open(p).read()
b = '        Sort s = SORTS.getOrDefault(sort, Sort.by(Sort.Direction.ASC, sort));\n'
a = '        Sort s = SORTS.get(sort);\n        if (s == null) throw refusal("sort-unknown", "Unknown sort", "sort must be one of " + SORTS.keySet());\n'
if b not in s:
    sys.exit("apply.sh: %s is not break.sh's broken copy" % p)
if how == "solved":
    s = s.replace(b, a)
elif how == "unboundcursor":
    s = s.replace(b, a).replace('            if (!sort.equals(cs)) differ.add(', '            if (false) differ.add(')
elif how == "rawsort":
    s = s.replace(b, '        Sort s = Sort.by(Sort.Direction.ASC, sort);\n        if (!sort.matches("[a-z]+") || sort.equals("nosuch")) throw refusal("sort-unknown", "Unknown sort", "sort must be one of " + SORTS.keySet());\n')
elif how == "typed404":
    s = s.replace(b, a.replace("HttpStatus.BAD_REQUEST", "HttpStatus.BAD_REQUEST")).replace(
        '        return new ErrorResponseException(HttpStatus.BAD_REQUEST, p, null);', '        return new ErrorResponseException(type.equals("sort-unknown") ? HttpStatus.NOT_FOUND : HttpStatus.BAD_REQUEST, p, null);')
elif how == "fixedelsewhere":
    s = s.replace(b, a)
    q = tree + "/tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerReads.java"
    open(q, "a").write("// the fix, said to live here too\n")
open(p, "w").write(s)
print("apply.sh: OrderPages.java - %s" % ("the whitelist check restored" if how == "solved" else "the variant " + how))
PY
