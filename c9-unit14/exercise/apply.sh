#!/bin/sh
# Course 9 unit 14's exercise, the solution: restore the whitelist projection in a broken copy (break.sh's), byte for byte as ../after has
# it. Usage: sh apply.sh TREE. HOW (the receipts' refused variants only): typed200, 404, dropunknown, rawmap, fixedelsewhere.
T=${1:?usage: sh apply.sh TREE}
HERE=$(cd "$(dirname "$0")" && pwd -P)
[ "$(cd "$T" && pwd -P)" != "$(cd "$HERE/../after" && pwd -P)" ] || { echo "apply.sh: refused - that is ../after itself"; exit 1; }
F="$T/tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerFields.java"
python3 -I - "$F" "${HOW:-solved}" "$T" "$HERE/../after/tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerFields.java" <<'PY'
import sys
p, how, tree, ref = sys.argv[1:5]; s = open(p).read(); r = open(ref).read()
b = '        return customers.findAll();\n'
i = r.find('        List<Customer> all = customers.findAll();\n'); j = r.find('        }).toList();\n') + len('        }).toList();\n')
a = r[i:j]
if b not in s:
    sys.exit("apply.sh: %s is not break.sh's broken copy" % p)
if how == "solved":
    pass
elif how == "typed200":
    a = a.replace('            if (!FIELDS.containsKey(f)) throw refusal("field-unknown", "Unknown field", "unknown field " + f + "; the fields are " + FIELDS.keySet());\n',
                  '            if (!FIELDS.containsKey(f)) return all;\n')
elif how == "404":
    s = s.replace('        return new ErrorResponseException(HttpStatus.BAD_REQUEST, p, null);',
                  '        return new ErrorResponseException(type.equals("field-unknown") ? HttpStatus.NOT_FOUND : HttpStatus.BAD_REQUEST, p, null);')
elif how == "dropunknown":
    a = a.replace('            if (!FIELDS.containsKey(f)) throw refusal("field-unknown", "Unknown field", "unknown field " + f + "; the fields are " + FIELDS.keySet());\n',
                  '            if (!FIELDS.containsKey(f)) continue;\n')
elif how == "rawmap":
    a = a.replace('            FIELDS.forEach((name, read) -> { if (asked.contains(name)) m.put(name, read.apply(c)); });\n',
                  '            for (String f : asked) m.put(f, FIELDS.get(f).apply(c));\n')
elif how == "fixedelsewhere":
    open(tree + "/tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerReads.java", "a").write("// the fix, said to live here too\n")
if how != "solved" and a == r[i:j] and how in ("typed200", "dropunknown", "rawmap"):
    sys.exit("apply.sh: the variant %s did not apply" % how)
open(p, "w").write(s.replace(b, a))
print("apply.sh: CustomerFields.java - %s" % ("the whitelist projection restored" if how == "solved" else "the variant " + how))
PY
