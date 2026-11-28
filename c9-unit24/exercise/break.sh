#!/bin/sh
# Course 9 unit 24's exercise, the start: sh break.sh TREE (a copy of ../after - never ../after itself). ONE method of TiffinBoxServer.java
# is rewritten, printed: the retired route goes back to the deprecation timeline's first step - it answers 200 with the customer and says
# it is going (Deprecation, Sunset, and a Link to its successor). The same edit as ../harness/mirror/announce.diff makes on before.
[ -n "$1" ] && [ -d "$1/tiffinbox-web" ] || { echo "usage: sh break.sh TREE (a copy of ../after)"; exit 2; }
T=$(cd "$1" && pwd); A=$(cd "$(dirname "$0")/../after" && pwd)
[ "$T" != "$A" ] || { echo "break.sh refuses ../after itself: copy it first"; exit 2; }
python3 -I - "$T/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java" <<'PY'
import sys, re
p = sys.argv[1]; s = open(p, encoding="utf-8").read()
m = re.search(r'    @GetMapping\("/customers/\{name\}"\)\n    ResponseEntity<ProblemDetail> customer\(@PathVariable String name\) \{\n.*?\n    \}\n', s, re.S)
if not m: print("break.sh: the retired route's method is not there"); sys.exit(1)
new = '''    // Course 9, unit 24 - the timeline's first step (a copy only, never shipped): the route still answers 200, and says it is going
    @GetMapping("/customers/{name}")
    ResponseEntity<Customer> customer(@PathVariable String name) throws Exception {
        Customer found = repo.findByName(name)
                .orElseThrow(() -> new CustomerNotFound(name));
        return ResponseEntity.ok()
                .header("Deprecation", "@1798761600")
                .header("Sunset", "Thu, 01 Jul 2027 00:00:00 GMT")
                .header("Link", "</api/v1/customers/" + org.springframework.web.util.UriUtils.encodePathSegment(name, StandardCharsets.UTF_8) + ">; rel=\\"successor-version\\"")
                .body(found);
    }
'''
open(p, "w", encoding="utf-8").write(s[:m.start()] + new + s[m.end():])
print("rewrote TiffinBoxServer.customer: GET /customers/{name} answers 200 with the customer, Deprecation, Sunset and a Link to /api/v1/customers/<name>")
PY
