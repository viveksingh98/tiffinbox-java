#!/bin/sh
# Course 9 unit 21's exercise, the start: sh break.sh TREE (a copy of ../after - never ../after itself). ONE edit, printed: the key's
# minting moves INSIDE the retried method - PaymentCaller.pay ignores the key it was given and sends a new one on every attempt.
[ -n "$1" ] && [ -d "$1/tiffinbox-client" ] || { echo "usage: sh break.sh TREE (a copy of ../after)"; exit 2; }
T=$(cd "$1" && pwd); A=$(cd "$(dirname "$0")/../after" && pwd)
[ "$T" != "$A" ] || { echo "break.sh refuses ../after itself: copy it first"; exit 2; }
python3 -I - "$T/tiffinbox-client/src/test/java/com/tiffinbox/client/PaymentCaller.java" <<'PY'
import sys
p = sys.argv[1]; s = open(p, encoding="utf-8").read()
old = "        return payments.pay(key, charge);\n"
new = "        return payments.pay(UUID.randomUUID().toString(), charge);   // a new key on every attempt\n"
if s.count(old) != 1: print("break.sh: PaymentCaller.pay is not the shipped line"); sys.exit(1)
open(p, "w", encoding="utf-8").write(s.replace(old, new, 1))
print("edited PaymentCaller.pay:\n- " + old.strip() + "\n+ " + new.strip())
PY
