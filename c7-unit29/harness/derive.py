"""derive.py TREE EDIT... - unit 29's labelled copies, each derived from a copy of after/ by named edits (the anchor change's B and the
wrong fixes). Each edit replaces one exact text, found exactly once, or the script exits 1; receipts.sh prints every copy's diff.
  notx     B: pausedDaysByCustomer without its @Transactional(readOnly = true) - the page with no transaction
  route    a request-thread route: GET /customers/paused on TiffinBoxServer, returning repo.pausedDaysByCustomer()
  eager    wrong fix (b): CustomerEntity's pauses fetch = FetchType.EAGER
  pagetx   wrong fix (d): @Transactional(readOnly = true) on DashboardPage.page (the class still final)
  routetx  wrong fix (d) on the route: @Transactional(readOnly = true) on GET /customers/paused
  unfinal  DashboardPage and TiffinBoxServer without final (the proxy is a subclass)"""
import sys
from pathlib import Path

CJ = "tiffinbox-core/src/main/java/com/tiffinbox/"
WJ = "tiffinbox-web/src/main/java/com/tiffinbox/web/"
TX = "    @org.springframework.transaction.annotation.Transactional(readOnly = true)\n"
EDITS = {
    "notx": [(CJ + "CustomerRepository.java", "    @Transactional(readOnly = true)\n    public Map<String, Integer> pausedDaysByCustomer()",
              "    public Map<String, Integer> pausedDaysByCustomer()")],
    "route": [(WJ + "TiffinBoxServer.java", "    @GetMapping(\"/revenue\")\n",
               "    /** Unit 29's labelled copy: each customer's paused days, read on the request's own thread. */\n"
               "    @GetMapping(\"/customers/paused\")\n    Map<String, Integer> paused() throws Exception {\n"
               "        return repo.pausedDaysByCustomer();\n    }\n\n    @GetMapping(\"/revenue\")\n")],
    "eager": [(CJ + "CustomerEntity.java", "    @OneToMany(mappedBy = \"customer\")\n",
               "    @OneToMany(mappedBy = \"customer\", fetch = jakarta.persistence.FetchType.EAGER)\n")],
    "pagetx": [(WJ + "DashboardPage.java", "    @GetMapping(value = \"/dashboard\", produces = MediaType.TEXT_HTML_VALUE)\n",
                TX + "    @GetMapping(value = \"/dashboard\", produces = MediaType.TEXT_HTML_VALUE)\n")],
    "routetx": [(WJ + "TiffinBoxServer.java", "    @GetMapping(\"/customers/paused\")\n", TX + "    @GetMapping(\"/customers/paused\")\n")],
    "unfinal": [(WJ + "DashboardPage.java", "\nfinal class DashboardPage {", "\nclass DashboardPage {"),
                (WJ + "TiffinBoxServer.java", "\npublic final class TiffinBoxServer {", "\npublic class TiffinBoxServer {")],
}
tree = Path(sys.argv[1])
for name in sys.argv[2:]:
    for f, old, new in EDITS[name]:
        p = tree / f
        s = p.read_text(encoding="utf-8")
        if s.count(old) != 1:
            sys.exit(f"derive.py {name}: {f} holds the text {s.count(old)} times, not once: {old[:60]!r}")
        p.write_text(s.replace(old, new), encoding="utf-8")
print("derived " + tree.name + ": " + " ".join(sys.argv[2:]))
