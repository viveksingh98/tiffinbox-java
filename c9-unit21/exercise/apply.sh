#!/bin/sh
# Course 9 unit 21's exercise, the solution: sh apply.sh TREE. ONE printed edit: PaymentCaller.pay sends the key it was given - minted
# once by Checkout, outside the retried method. HOW=<variant> applies a refused variant instead (the receipts' R.196 runs).
[ -n "$1" ] && [ -d "$1/tiffinbox-client" ] || { echo "usage: sh apply.sh TREE"; exit 2; }
python3 -I - "$1/tiffinbox-client/src/test/java/com/tiffinbox/client" "${HOW:-solved}" <<'PY'
import sys, os
d, how = sys.argv[1], sys.argv[2]; p = os.path.join(d, "PaymentCaller.java"); s = open(p, encoding="utf-8").read()
broken = "        return payments.pay(UUID.randomUUID().toString(), charge);   // a new key on every attempt\n"
if s.count(broken) != 1: print("apply.sh: the broken line is not there"); sys.exit(1)
fix = {"solved": "        return payments.pay(key, charge);\n",
       "constant": "        return payments.pay(\"tiffinbox-key\", charge);\n",
       "onlyfirst": "        return payments.pay(attempts.get() == 1 ? key : UUID.randomUUID().toString(), charge);\n",
       "swallow": "        return payments.pay(key, charge);\n",
       "fixedelsewhere": "        return payments.pay(key, charge);\n",
       "none": broken}[how]
s = s.replace(broken, fix, 1)
if how == "swallow": s = s.replace("    @Retryable(", "    // @Retryable(", 1)
open(p, "w", encoding="utf-8").write(s)
if how == "fixedelsewhere":
    q = os.path.join(d, "Payments.java"); open(q, "a", encoding="utf-8").write("// edited elsewhere\n")
print("edited PaymentCaller.pay (%s):\n- %s\n+ %s" % (how, broken.strip(), fix.strip()))
PY
