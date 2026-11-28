#!/bin/sh
# Course 9 unit 24's exercise, the solution: sh apply.sh TREE (a copy break.sh rewrote). ONE printed edit: the method goes back to
# ../after's handler - 410 Gone, a problem detail of type route-retired, and the Link to the successor (SOLUTION.md quotes it).
# HOW=<variant> applies a refused variant instead (the receipts' R.196 runs): remove, json, notype, successor, broken.
[ -n "$1" ] && [ -d "$1/tiffinbox-web" ] || { echo "usage: sh apply.sh TREE"; exit 2; }
A=$(cd "$(dirname "$0")/../after" && pwd)
python3 -I - "$1/tiffinbox-web/src/main/java/com/tiffinbox/web" "$A/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java" "${HOW:-solved}" <<'PY'
import sys, re
d, a, how = sys.argv[1], sys.argv[2], sys.argv[3]
p = d + "/TiffinBoxServer.java"; s = open(p, encoding="utf-8").read()
rx = re.compile(r"    // Course 9, unit 24 - the timeline's first step \(a copy only, never shipped\)[^\n]*\n    @GetMapping\(\"/customers/\{name\}\"\)\n    ResponseEntity<Customer> customer\(.*?\n    \}\n", re.S)
m = rx.search(s)
if not m: print("apply.sh: the broken method is not there (run break.sh first)"); sys.exit(1)
sol = re.search(r'    @GetMapping\("/customers/\{name\}"\)\n    ResponseEntity<ProblemDetail> customer\(@PathVariable String name\) \{\n.*?\n    \}\n', open(a, encoding="utf-8").read(), re.S).group(0)
if how == "solved": new = sol
elif how == "remove": new = ""
elif how == "json": new = sol.replace("        return ResponseEntity.status(HttpStatus.GONE)\n", "        return ResponseEntity.status(HttpStatus.GONE).contentType(org.springframework.http.MediaType.APPLICATION_JSON)\n").replace("        problem.setType(TiffinBoxErrors.ROUTE_RETIRED);\n", "")
elif how == "notype": new = sol.replace("        problem.setType(TiffinBoxErrors.ROUTE_RETIRED);\n", "")
elif how == "successor": new = sol
elif how == "broken": print("apply.sh: HOW=broken leaves the broken method as it is"); sys.exit(0)
else: print("apply.sh: unknown HOW=%s" % how); sys.exit(2)
s = s[:m.start()] + new + s[m.end():]
open(p, "w", encoding="utf-8").write(s)
if how == "successor":
    q = d + "/CustomerReads.java"; r = open(q, encoding="utf-8").read()
    old = "        CustomerRepository.Versioned found = repo.findVersioned(name).orElseThrow(() -> new CustomerNotFound(name));\n"
    if r.count(old) != 1: print("apply.sh: CustomerReads' read line is not there"); sys.exit(1)
    open(q, "w", encoding="utf-8").write(r.replace(old, "        CustomerRepository.Versioned found = repo.findVersioned(name).filter(v -> false).orElseThrow(() -> new CustomerNotFound(name));\n", 1))
print("applied %s: TiffinBoxServer.customer%s" % (how, {"solved": " = ../after's handler (410, route-retired, the Link)", "remove": " removed with its mapping (the bare removal)", "json": ": 410 as application/json, no type", "notype": ": 410 problem detail, no type (about:blank)", "successor": " = ../after's handler, and the successor's read changed to answer the not-found"}[how]))
PY
