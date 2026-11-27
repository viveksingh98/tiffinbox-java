#!/bin/sh
# Course 9 unit 18's exercise, the solution: declare the signed download's return type again as ResponseEntity<StreamingResponseBody>,
# byte for byte as ../after has it. Usage: sh apply.sh TREE. HOW (the receipts' refused variants only): object, fixedelsewhere,
# hardcoded, nosignature.
T=${1:?usage: sh apply.sh TREE}
HERE=$(cd "$(dirname "$0")" && pwd -P)
[ "$(cd "$T" && pwd -P)" != "$(cd "$HERE/../after" && pwd -P)" ] || { echo "apply.sh: refused - that is ../after itself"; exit 1; }
W="$T/tiffinbox-web/src/main/java/com/tiffinbox/web"
python3 -I - "$W" "${HOW:-solved}" "$HERE/../after/tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerBills.java" <<'PY'
import sys
w, how, ref = sys.argv[1:4]; p = w + "/CustomerBills.java"; s = open(p).read()
broken = "    ResponseEntity<?> signedBill("
fixed = "    ResponseEntity<StreamingResponseBody> signedBill("
if s.count(broken) != 1:
    sys.exit("apply.sh: %s is not break.sh's broken copy" % p)
ret = "            throw refusal(HttpStatus.FORBIDDEN, \"link-expired\", \"Link expired\", \"the link has expired\");\n        }\n        return csv(customer(name));\n"
if how == "solved":
    s = s.replace(broken, fixed, 1)
elif how == "object":
    s = s.replace(broken, "    ResponseEntity<Object> signedBill(", 1)
    s = s.replace(ret, ret.replace("        return csv(customer(name));\n", "        ResponseEntity<StreamingResponseBody> r = csv(customer(name));\n        return ResponseEntity.status(r.getStatusCode()).headers(r.getHeaders()).body(r.getBody());\n"), 1)
elif how == "fixedelsewhere":
    s = s.replace(broken, fixed, 1)
    o = w + "/OrderResources.java"; open(o, "a").write("// the fix, made in the wrong file as well\n")
elif how == "hardcoded":
    s = s.replace(broken, fixed, 1)
    s = s.replace(ret, ret.replace("        return csv(customer(name));\n", "        StreamingResponseBody fixedBody = out -> out.write(\"day,amount\\n\".getBytes(StandardCharsets.UTF_8));\n        return ResponseEntity.ok().contentType(CSV).body(fixedBody);\n"), 1)
elif how == "nosignature":
    s = s.replace(broken, fixed, 1)
    s = s.replace("        if (!MessageDigest.isEqual(expected.getBytes(StandardCharsets.US_ASCII), sig.getBytes(StandardCharsets.US_ASCII))) {",
                  "        if (false && !MessageDigest.isEqual(expected.getBytes(StandardCharsets.US_ASCII), sig.getBytes(StandardCharsets.US_ASCII))) {", 1)
else:
    sys.exit("apply.sh: unknown HOW " + how)
open(p, "w").write(s)
if how == "solved":
    assert s == open(ref).read(), "apply.sh: the solved file is not ../after's CustomerBills.java"
print("apply.sh: CustomerBills.java - %s" % ("the signed download declared ResponseEntity<StreamingResponseBody> again (= ../after's file)" if how == "solved" else "the refused variant " + how))
PY
