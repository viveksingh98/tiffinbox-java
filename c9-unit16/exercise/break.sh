#!/bin/sh
# Course 9 unit 16's exercise: break a COPY of ../after - the order's customer link built by the proxy form, methodOn(CustomerReads.class),
# on the final CustomerReads (the handler then declares the SQLException CustomerReads.one declares, so the tree still compiles). Usage:
# sh break.sh TREE   (TREE: a copy of ../after, never ../after itself)
T=${1:?usage: sh break.sh TREE}
[ -d "$T/tiffinbox-web" ] || { echo "break.sh: $T is not a copy of ../after"; exit 1; }
[ "$(cd "$T" && pwd -P)" != "$(cd "$(dirname "$0")/../after" && pwd -P)" ] || { echo "break.sh: refused - that is ../after itself; copy it first"; exit 1; }
F="$T/tiffinbox-web/src/main/java/com/tiffinbox/web/OrderResources.java"
python3 -I - "$F" <<'PY'
import sys
p = sys.argv[1]; s = open(p).read()
a = '                linkTo(CustomerReads.class, CUSTOMER_ONE, order.customer()).withRel("customer"));\n'
b = '    EntityModel<OrderPages.OrderView> orderResource(@PathVariable Long id, HttpServletRequest request) {\n'
if a not in s or b not in s:
    sys.exit("break.sh: the Method form is not in %s (already broken?)" % p)
s = s.replace(a, '                linkTo(methodOn(CustomerReads.class).one(order.customer())).withRel("customer"));\n')
s = s.replace(b, '    EntityModel<OrderPages.OrderView> orderResource(@PathVariable Long id, HttpServletRequest request) throws java.sql.SQLException {\n')
open(p, "w").write(s)
print("break.sh: OrderResources.java - the customer link built by methodOn(CustomerReads.class), the proxy form, on the final CustomerReads")
PY
