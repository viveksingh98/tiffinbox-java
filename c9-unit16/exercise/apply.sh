#!/bin/sh
# Course 9 unit 16's exercise, the solution: build the customer link by the Method form again in a broken copy (break.sh's), byte for byte as
# ../after has it, and keep CustomerReads final. Usage: sh apply.sh TREE. HOW (the receipts' refused variants only): unfinal, literal,
# dropped, fixedelsewhere.
T=${1:?usage: sh apply.sh TREE}
HERE=$(cd "$(dirname "$0")" && pwd -P)
[ "$(cd "$T" && pwd -P)" != "$(cd "$HERE/../after" && pwd -P)" ] || { echo "apply.sh: refused - that is ../after itself"; exit 1; }
W="$T/tiffinbox-web/src/main/java/com/tiffinbox/web"
python3 -I - "$W" "${HOW:-solved}" <<'PY'
import sys
w, how = sys.argv[1:3]; p = w + "/OrderResources.java"; s = open(p).read()
broken = '                linkTo(methodOn(CustomerReads.class).one(order.customer())).withRel("customer"));\n'
sig_b = '    EntityModel<OrderPages.OrderView> orderResource(@PathVariable Long id, HttpServletRequest request) throws java.sql.SQLException {\n'
sig = '    EntityModel<OrderPages.OrderView> orderResource(@PathVariable Long id, HttpServletRequest request) {\n'
fixed = '                linkTo(CustomerReads.class, CUSTOMER_ONE, order.customer()).withRel("customer"));\n'
if broken not in s or sig_b not in s:
    sys.exit("apply.sh: %s is not break.sh's broken copy" % p)
if how == "solved":
    s = s.replace(broken, fixed).replace(sig_b, sig)
elif how == "unfinal":
    r = w + "/CustomerReads.java"; c = open(r).read(); open(r, "w").write(c.replace("final class CustomerReads", "class CustomerReads"))
elif how == "literal":
    s = s.replace(broken, '                Link.of(request.getRequestURL().toString().replaceAll("/api/v1/orders/.*", "") + "/api/v1/customers/" + order.customer(), "customer"));\n').replace(sig_b, sig)
    s = s.replace("import org.springframework.hateoas.EntityModel;\n", "import org.springframework.hateoas.EntityModel;\nimport org.springframework.hateoas.Link;\n")
elif how == "dropped":
    s = s.replace('                linkTo(methodOn(OrderResources.class).orderResource(id, null)).withSelfRel(),\n' + broken,
                  '                linkTo(methodOn(OrderResources.class).orderResource(id, null)).withSelfRel());\n').replace(sig_b, sig)
elif how == "fixedelsewhere":
    s = s.replace(broken, fixed).replace(sig_b, sig)
    r = w + "/OrderPages.java"; c = open(r).read(); open(r, "w").write(c.replace("    static final int DEFAULT_SIZE = 5;", "    static final int DEFAULT_SIZE = 5; // the exercise touched this file"))
else:
    sys.exit("apply.sh: HOW must be one of solved, unfinal, literal, dropped, fixedelsewhere")
open(p, "w").write(s)
print("apply.sh: %s" % how)
PY
