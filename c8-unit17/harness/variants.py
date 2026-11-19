"""Unit 17's labelled copies of after/ (python3 -I -B harness/variants.py NAME AFTER OUT): AFTER copied to OUT (no target/, no
secrets/), then the lines below changed, and the change printed as a unified diff. They are labelled wherever they print: a copy is
never the anchor's (R.392). sync's rows (b), (c) and (d) run them; rows (a) and every other capture run after/ itself.
  nolocking   RedisCaching's writer without enableLocking() - immediateWrites() alone, nothing else (sync's rows b and d)
  hold        CustomerRepository.findAll() first calls u17Hold(): on the harness's caller thread (u17-caller) and only under
              -Du17.hold=FILE, it polls FILE on a count (the harness holds - planted, labelled; cap 2400 reads), so the two JVMs
              overlap for sure; every other thread, and every run without the property, passes straight through (sync's row c)
  nolockhold  both changes at once (sync's row d)"""
import difflib, os, shutil, sys

NAME, A, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
W = "tiffinbox-web/src/main/java/com/tiffinbox/web/"
RC = W + "RedisCaching.java"
CR = "tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java"
NOLOCK = (RC, "writer -> writer.immediateWrites().enableLocking()));", "writer -> writer.immediateWrites()));")
HOLD = (CR, "    public List<Customer> findAll() throws SQLException {\n        return customers.findAll(",
        "    public List<Customer> findAll() throws SQLException {\n        u17Hold();\n        return customers.findAll(")
HOLDM = (CR, "    private static Customer toRecord(CustomerEntity e) {",
         "    // unit 17's labelled copy: the harness holds its caller here (planted) - a file polled on a count, never a sleep relied on\n"
         "    private static void u17Hold() {\n"
         "        String f = System.getProperty(\"u17.hold\");\n"
         "        if (f == null || !Thread.currentThread().getName().equals(\"u17-caller\")) return;\n"
         "        try {\n"
         "            for (int i = 0; i < 2400 && !java.nio.file.Files.exists(java.nio.file.Path.of(f)); i++) Thread.sleep(50);\n"
         "        } catch (InterruptedException x) {\n"
         "            Thread.currentThread().interrupt();\n"
         "        }\n"
         "    }\n\n"
         "    private static Customer toRecord(CustomerEntity e) {")
F = {"nolocking": [NOLOCK], "hold": [HOLD, HOLDM], "nolockhold": [NOLOCK, HOLD, HOLDM]}[NAME]
if os.path.exists(OUT): shutil.rmtree(OUT)
shutil.copytree(A, OUT, ignore=shutil.ignore_patterns("target", "secrets", ".m2-demo"))
for f, old, new in F:
    p = os.path.join(OUT, f); s = open(p, encoding="utf-8").read()
    if s.count(old) != 1: print("FAIL the lines to change are not in " + f + " once"); sys.exit(1)
    t = s.replace(old, new)
    open(p, "w", encoding="utf-8").write(t)
    d = [l for l in difflib.unified_diff(s.splitlines(), t.splitlines(), "after/" + f, NAME + "/" + f, lineterm="", n=0) if not l.startswith("@@")]
    print("\n".join(d))
