#!/bin/sh
# Course 9 unit 17's exercise: break a COPY of ../after - the status resource's Retry-After removed, so GET /api/v1/billing-runs/{id}
# answers the run's state and never says when to come back. Usage: sh break.sh TREE   (TREE: a copy of ../after, never ../after itself)
T=${1:?usage: sh break.sh TREE}
[ -d "$T/tiffinbox-web" ] || { echo "break.sh: $T is not a copy of ../after"; exit 1; }
[ "$(cd "$T" && pwd -P)" != "$(cd "$(dirname "$0")/../after" && pwd -P)" ] || { echo "break.sh: refused - that is ../after itself; copy it first"; exit 1; }
F="$T/tiffinbox-web/src/main/java/com/tiffinbox/web/BillingRuns.java"
python3 -I - "$F" <<'PY'
import sys
p = sys.argv[1]; s = open(p).read()
head, sep, tail = s.partition("    ResponseEntity<BillingRunView> billingRun(")
a = "        ResponseEntity.BodyBuilder answer = ResponseEntity.ok();\n        if (view.state() == State.RUNNING) {\n            answer.header(HttpHeaders.RETRY_AFTER, COME_BACK);\n        }\n"
if not sep or a not in tail:
    sys.exit("break.sh: the status resource's Retry-After is not in %s (already broken?)" % p)
open(p, "w").write(head + sep + tail.replace(a, "        ResponseEntity.BodyBuilder answer = ResponseEntity.ok();\n", 1))
print("break.sh: BillingRuns.java - the status resource's Retry-After removed (GET /api/v1/billing-runs/{id} never sends it)")
PY
