#!/bin/sh
# Course 9 unit 17's exercise, the solution: send Retry-After again from the status resource while the run is RUNNING, and not once it is
# finished - byte for byte as ../after has it. Usage: sh apply.sh TREE. HOW (the receipts' refused variants only): always, never,
# fixedelsewhere, statehardcoded.
T=${1:?usage: sh apply.sh TREE}
HERE=$(cd "$(dirname "$0")" && pwd -P)
[ "$(cd "$T" && pwd -P)" != "$(cd "$HERE/../after" && pwd -P)" ] || { echo "apply.sh: refused - that is ../after itself"; exit 1; }
W="$T/tiffinbox-web/src/main/java/com/tiffinbox/web"
python3 -I - "$W" "${HOW:-solved}" "$HERE/../after/tiffinbox-web/src/main/java/com/tiffinbox/web/BillingRuns.java" <<'PY'
import sys
w, how, ref = sys.argv[1:4]; p = w + "/BillingRuns.java"; s = open(p).read()
head, sep, tail = s.partition("    ResponseEntity<BillingRunView> billingRun(")
broken = "        ResponseEntity.BodyBuilder answer = ResponseEntity.ok();\n        return answer.body(view);\n"
cond = "        ResponseEntity.BodyBuilder answer = ResponseEntity.ok();\n        if (view.state() == State.RUNNING) {\n            answer.header(HttpHeaders.RETRY_AFTER, COME_BACK);\n        }\n        return answer.body(view);\n"
if not sep or broken not in tail:
    sys.exit("apply.sh: %s is not break.sh's broken copy" % p)
if how == "solved":
    fix = cond
elif how == "always":
    fix = "        ResponseEntity.BodyBuilder answer = ResponseEntity.ok();\n        answer.header(HttpHeaders.RETRY_AFTER, COME_BACK);\n        return answer.body(view);\n"
elif how == "never":
    fix = broken
elif how == "fixedelsewhere":
    fix = cond
    o = w + "/OrderResources.java"; open(o, "a").write("// the fix, made in the wrong file as well\n")
elif how == "statehardcoded":
    fix = cond.replace("return answer.body(view);", "return answer.body(new BillingRunView(view.id(), State.RUNNING, null));")
    fix = fix.replace("        if (view.state() == State.RUNNING) {\n            answer.header(HttpHeaders.RETRY_AFTER, COME_BACK);\n        }\n",
                      "        answer.header(HttpHeaders.RETRY_AFTER, COME_BACK);\n")
else:
    sys.exit("apply.sh: unknown HOW " + how)
s = head + sep + tail.replace(broken, fix, 1)
open(p, "w").write(s)
if how == "solved":
    assert s == open(ref).read(), "apply.sh: the solved file is not ../after's BillingRuns.java"
print("apply.sh: BillingRuns.java - %s" % ("Retry-After sent again while RUNNING, not once finished (= ../after's file)" if how == "solved" else "the refused variant " + how))
PY
