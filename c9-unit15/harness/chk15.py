#!/usr/bin/env python3
"""Course 9 unit 15's checker (python3 -I -B harness/chk15.py MODE ...), on chk14.py's shared machinery (ok / fail / need, the listing
parser that ends with a FAIL line and exit 1, never a traceback). Each capture's check reads the capture's own lines and checks them
against another witness of the same run (curl's size against the saved file's bytes and Content-Length, the access log against curl's
lines, the counter's totals against its own listing, Surefire's XML against the reactor line, the census against its rows ...).
Prints "ok ..." / "FAIL ..." lines and one "VALUES k=v ..." line; exit 1 on any FAIL.

Modes: CAPTURE FILE (advisory before pin starter cost moved literal final placeholder seven surface inert exercise) · hashable CAPTURE
FILE (the capture minus its run-variant lines, those starting "  ~") · static UNITDIR RECEIPTS · gloss README · gloss-line · hook · exq ·
interleaved · values README VALS · plants CAPDIR (each planted fault made to FAIL first).
Left out of this unit (no anchor change): see LEFT_OUT - a capture of that name in this checker or in receipts.sh is a static failure."""
import hashlib, json, os, re, subprocess, sys

FAILS = []
VALS = {}
LEFT_OUT = ["cha" + "nge", "fu" + "ll", "fie" + "lds", "ref" + "use", "vi" + "ew", "m" + "jv", "flo" + "or", "gro" + "wn", "und" + "er",
            "pa" + "ge", "cli" + "ents", "ya" + "ml", "sp" + "ec", "te" + "sts", "wa" + "lk", "page" + "able", "tr" + "ap", "rest" + "art",
            "ta" + "ble", "fi" + "rst", "ne" + "xt", "cur" + "sor"]
CAPS = ["advisory", "before", "pin", "starter", "cost", "moved", "literal", "final", "placeholder", "seven", "surface", "inert", "exercise"]
GLOSS = "A link relation: the name of where a link goes."
BRIEF = os.path.join(os.environ.get("C9R", ""), "_briefs/UNIT-BRIEFS-S3-PAYLOADS.md")
SEED4 = ["Meera", "Priya", "Ravi", "Sunil"]


def ok(m):
    print("ok " + m)


def fail(m):
    FAILS.append(m)
    print("FAIL " + m)


def need(cond, m):
    (ok if cond else fail)(m)
    return cond


def lines(f):
    return open(f, encoding="utf-8", errors="replace").read().splitlines()


def grab(ls, rx, what):
    """the first match of rx over the lines, or a FAIL line (never a traceback)"""
    for l in ls:
        m = re.search(rx, l)
        if m:
            return m
    fail("unparsable: no line for " + what)
    return None


def grab_all(ls, rx):
    return [m for m in (re.search(rx, l) for l in ls) if m]


ONE = re.compile(r"^  ([\w-]+) \| GET (\S+?)(?: \((.*)\))? -> (\d+) (\S*) (\d+) · file (\d+) B md5 ([0-9a-f]{32}) · Content-Length (\S+)$")


def gets(ls, lab):
    out = []
    for l in ls:
        m = ONE.match(l)
        if m and m.group(1) == lab:
            out.append(dict(path=m.group(2), desc=m.group(3) or "", code=int(m.group(4)), ctype=m.group(5), size=int(m.group(6)),
                            file=int(m.group(7)), md5=m.group(8), cl=m.group(9)))
    return out


def same_size(g, what):
    return need(g["size"] == g["file"] and (g["cl"] == "none" or g["cl"] == str(g["file"])),
                "%s: curl's size %d = the saved file's %d B = Content-Length %s" % (what, g["size"], g["file"], g["cl"]))


def find(gs, path, desc=None):
    for g in gs:
        if g["path"] == path and (desc is None or g["desc"] == desc):
            return g
    fail("unparsable: no GET %s (%s)" % (path, desc_sub))
    return dict(path=path, desc="", code=0, ctype="", size=-1, file=-2, md5="", cl="none")


# ---- the captures -------------------------------------------------------------------------------------------------------------------------
def c_advisory(ls):
    m = grab(ls, r"fetched-at (\S+) \(the hour masked\) · run date (\S+)", "the dates")
    if m:
        need(m.group(1) == m.group(2), "S9.36: the filed read (%s) is the run's day (%s) - a later day is a STOP" % (m.group(1), m.group(2)))
    m = grab(ls, r"MD5SUMS\.txt: (\d+) lines, (\d+) verified", "MD5SUMS")
    if m:
        need(m.group(1) == m.group(2) and int(m.group(1)) > 0, "every MD5SUMS line verified (%s/%s)" % (m.group(2), m.group(1)))
    m = grab(ls, r"spring rows (\d+) · naming Spring Framework (\d+) · naming HATEOAS (\d+)", "the spring rows")
    if m:
        need(m.group(1) == "25" and m.group(2) == "0", "the spring index: 25 rows, 0 naming Spring Framework")
        VALS["adv_rows"] = m.group(1); VALS["adv_hateoas"] = m.group(3)
    m = grab(ls, r"tomcat page md5 ([0-9a-f]{32})", "the tomcat page")
    if m:
        need(m.group(1) == "a1a756d985225fb5143eefd9aae3183c", "Tomcat's page = the 2026-11-24 read (a1a756d9)")
    want = {"spring-hateoas": "3.1.4", "spring-boot-starter-hateoas": "4.1.3", "spring-boot-hateoas": "4.1.3", "spring-plugin-core": "4.1.0",
            "json-path": "2.10.0", "json-smart": "2.6.1", "tomcat-embed-core": "11.0.29", "jackson-databind": "3.1.8", "spring-web": "7.0.11"}
    got = {m.group(1): m.group(2) for m in grab_all(ls, r"t3 tree \| \S+?:([\w-]+) (\S*)$")}
    need(got == want, "the coordinates the probe's t3 tree names = the ones this unit stands on (%s)" % ", ".join("%s %s" % kv for kv in sorted(got.items())))
    need(any(l == "  verdict: no pin affected; evidence may proceed" for l in ls), "the verdict line")


def c_before(ls):
    g = gets(ls, "before")
    for x in g:
        same_size(x, "before " + x["path"])
    a = find(g, "/api/v1/customers/Ravi"); b = find(g, "/api/v1/customers", ""); c = find(g, "/customers")
    need(a["code"] == 200 and a["ctype"] == "application/json", "before: GET /api/v1/customers/Ravi 200 application/json (%d B)" % a["file"])
    need(b["code"] == 200 and c["code"] == 200 and b["md5"] == c["md5"], "before: U14's full list = the old /customers, byte for byte (%d B)" % c["file"])
    for p in ("/probe/hal/customers/Ravi", "/probe/entry"):
        x = find(g, p)
        need(x["code"] == 404, "before: the harness's route %s is not in before (%d)" % (p, x["code"]))
    m = grab(ls, r"mappings (\d+) · with probe in the path (\d+)", "the mappings")
    if m:
        need(m.group(2) == "0", "before: 0 mappings with probe in the path (of %s)" % m.group(1)); VALS["before_mappings"] = m.group(1)
    m = grab(ls, r"BOOT-INF/lib names (\d+) · naming hateoas (\d+)", "lib")
    if m:
        need(m.group(2) == "0", "before: no hateoas jar on the class path (%s names)" % m.group(1)); VALS["lib_before"] = m.group(1)
    VALS["plain"] = a["file"]; VALS["old_list"] = c["file"]


def c_pin(ls):
    m = grab(ls, r"MANIFEST Implementation-Version (\S+)", "the manifest")
    if m:
        need(m.group(1) == "3.1.4", "Spring HATEOAS's jar says Implementation-Version %s" % m.group(1)); VALS["hateoas"] = m.group(1)
    m = grab(ls, r"HAL classes (\d+) · referencing tools/jackson/databind (\d+) · referencing com/fasterxml/jackson/databind (\d+)", "the HAL package")
    if m:
        n, t3, t2 = map(int, m.groups())
        need(n > 0 and t3 > 0 and t2 == 0, "the HAL package: %d classes, %d reference Jackson 3's databind, %d Jackson 2's" % (n, t3, t2))
        VALS["hal_classes"] = "%d/%d/%d" % (n, t3, t2)
    m = grab(ls, r"<spring-hateoas\.version>([^<]+)</spring-hateoas\.version>", "the BOM line")
    if m:
        need(m.group(1) == VALS.get("hateoas"), "the Boot 4.1.3 BOM manages spring-hateoas %s = the jar's" % m.group(1))
    m = grab(ls, r"jackson in lib/: (.*)$", "jackson")
    if m:
        need("jackson-databind-3.1.8.jar" in m.group(1), "tools.jackson databind 3.1.8 in the copy's lib/")


def c_starter(ls):
    m = grab(ls, r"lines added (\d+) removed (\d+) · the tests copy's pom = the JVM copy's: (\w+)", "the edit's counts")
    if m:
        need(m.group(1) == "5" and m.group(2) == "0" and m.group(3) == "yes", "the ONE pom edit: 5 lines added (a comment and the dependency), 0 removed, the same in both copies")
    need(sum(1 for l in ls if l.startswith("  edit | >") and "spring-boot-starter-hateoas" in l) == 1, "the edit names spring-boot-starter-hateoas once")
    need(not any(l.startswith("  edit | >") and "<version>" in l for l in ls), "no version in the edit (Boot manages it)")
    m = grab(ls, r"git diff --stat f3724ca -- '\*pom\.xml': (\d+) lines · before's web pom = c9-tiffinbox's: (\w+)", "the pom guard")
    if m:
        need(m.group(1) == "0" and m.group(2) == "yes", "no pom of the repository moved; before's web pom = c9-tiffinbox's")
    b = grab(ls, r"build \| before WITH tests: exit (\d+) · (.*)$", "before's build"); h = grab(ls, r"build \| the copy WITH tests: exit (\d+) · (.*)$", "the copy's build")
    if b and h:
        need(b.group(1) == "0" and b.group(2).count("SUCCESS") == 4, "before WITH its tests: exit 0, the four reactor lines SUCCESS")
        VALS["copy_build"] = "exit%s" % h.group(1)
        VALS["copy_reactor"] = "%dS/%dF/%dK" % (h.group(2).count("SUCCESS"), h.group(2).count("FAILURE"), h.group(2).count("SKIPPED"))
    t = {m.group(1): tuple(map(int, m.groups()[1:])) for m in grab_all(ls, r"tests \| tiffinbox-(\w+) \| before tests (\d+) failures (\d+) errors (\d+) skipped (\d+) · the copy tests (\d+) failures (\d+) errors (\d+) skipped (\d+)$")}
    if need("web" in t and "client" in t, "the Surefire totals of both modules on both trees"):
        w = t["web"]
        need(w[0] == 62 and w[1] == w[2] == w[3] == 0, "before: web 62 tests, 0 failures, 0 errors, 0 skipped (U14's)")
        VALS["web_before"] = w[0]; VALS["web_copy"] = "%d/%d/%d/%d" % w[4:8]; VALS["client"] = "%d/%d" % (t["client"][0], t["client"][4])
    moved = [m.group(1) + " " + m.group(2) for m in grab_all(ls, r"tests \| class (\w+) (\w+) \| .*  MOVED$")]
    m = grab(ls, r"classes that differ: (\d+) \(of (\d+)\)", "the class count")
    if m:
        need(int(m.group(1)) == len(moved), "the classes that differ (%s) = the MOVED lines (%d)" % (m.group(1), len(moved)))
        VALS["classes_moved"] = ",".join(x.split()[1] for x in moved) or "none"
    m = grab(ls, r"lib \| before (\d+) names · the copy (\d+) names", "lib counts")
    added = [m2.group(1) for m2 in grab_all(ls, r"lib \| added (\S+)$")]; removed = grab_all(ls, r"lib \| removed (\S+)$")
    if m:
        need(int(m.group(2)) - int(m.group(1)) == len(added) - len(removed), "the copy's lib/ - before's = the added names (%d) - the removed (%d)" % (len(added), len(removed)))
        need(len(removed) == 0, "no jar removed by the starter")
        need("spring-hateoas-3.1.4.jar" in added, "spring-hateoas-3.1.4.jar among the added")
        VALS["lib"] = "%s->%s" % m.groups(); VALS["lib_added"] = len(added)
    m = grab(ls, r"jar \| only the copy, outside BOOT-INF/lib/: (.*)$", "the jar's entries")
    if m:
        need(m.group(1) == "none", "the copy's jar adds entries only under BOOT-INF/lib/")


def c_cost(ls):
    g = gets(ls, "cost")
    for x in g:
        same_size(x, "cost " + x["path"] + " " + x["desc"])
    p = find(g, "/api/v1/customers/Ravi"); h = find(g, "/probe/hal/customers/Ravi", "Accept: application/hal+json")
    hj = find(g, "/probe/hal/customers/Ravi", "Accept: application/json"); ha = find(g, "/probe/hal/customers/Ravi", "Accept: */*")
    o = find(g, "/customers"); a = find(g, "/api/v1/customers"); c = find(g, "/probe/hal/customers", "Accept: application/hal+json")
    need(p["code"] == 200 and h["code"] == 200 and h["ctype"] == "application/hal+json", "the shipped route and the harness's HAL route answer 200, the HAL one application/hal+json")
    need(hj["md5"] == h["md5"] and ha["md5"] == h["md5"], "the HAL body is the same under Accept application/json and */* (served as %s and %s)" % (hj["ctype"], ha["ctype"]))
    need(o["md5"] == a["md5"], "U14's full list = the old /customers on the copy, byte for byte")
    hl = {m.group(1): m for m in grab_all(ls, r"^  cost hal ([\w-]+) \| members (\[.*?\]) · embedded (\S+) · hrefs (\d+) · hosts (\S+) · bytes (\d+) · re-serialized compact (\w+) · without every _links member (\d+) B · the _links members (\d+) B$")}
    if need(set(hl) == {"one", "four", "host-localhost", "host-longer"}, "the four HAL readings parsed"):
        one, four = hl["one"], hl["four"]
        need(int(one.group(6)) == h["file"] and int(four.group(6)) == c["file"], "the readings' bytes = curl's files (%d, %d)" % (h["file"], c["file"]))
        need(one.group(7) == "equal" and four.group(7) == "equal", "the bodies are compact JSON (re-serialized byte-equal): the rule's subtraction holds")
        need(int(one.group(8)) == p["file"], "the HAL body without its _links member = the shipped route's %d B, byte count" % p["file"])
        need(int(one.group(8)) + int(one.group(9)) == h["file"], "the arithmetic: %s + %s = %d" % (one.group(8), one.group(9), h["file"]))
        need(one.group(2).startswith("['_links'"), "the _links member is the first member (%s)" % one.group(2))
        need(four.group(3) == "['customerList']", "the collection's embedded key customerList")
        VALS["four_nolinks"] = four.group(8); VALS["four_links"] = four.group(9)
        need(one.group(5) == "http://127.0.0.1:<port>" and four.group(5) == "http://127.0.0.1:<port>", "every href carries the request's host 127.0.0.1:<port>")
        hlh, hlg = hl["host-localhost"], hl["host-longer"]
        need(hlh.group(5) == "http://localhost:<port>" and hlg.group(5) == "http://api.tiffinbox.localhost:<port>", "with a Host header the hrefs carry that host")
        n = int(one.group(4))
        need(int(hlh.group(6)) == h["file"] + n * (9 - 9), "Host localhost (9 characters, as 127.0.0.1): the same bytes (%s)" % hlh.group(6))
        need(int(hlg.group(6)) == h["file"] + n * (23 - 9), "Host api.tiffinbox.localhost (23 characters): %d links x 14 more = %s B" % (n, hlg.group(6)))
        VALS["hal_one"] = h["file"]; VALS["links"] = one.group(9); VALS["plain"] = p["file"]; VALS["hal_four"] = c["file"]; VALS["old_list"] = o["file"]
        VALS["host_longer"] = hlg.group(6); VALS["json_ctype"] = hj["ctype"]
    acc = [l for l in ls if l.startswith("  access | ")]
    need(len(acc) == len(g), "the access log holds one line per request (%d = %d)" % (len(acc), len(g)))
    for x, l in zip(g, acc):
        m = re.match(r"  access \| GET (\S+) (\d+) (\d+) ", l)
        if not m:
            fail("unparsable access line: " + l[:80]); continue
        need(m.group(1) == x["path"] and int(m.group(2)) == x["code"] and int(m.group(3)) == x["file"], "access: %s %s %s = curl's" % m.groups())


def c_moved(ls):
    need(sum(1 for l in ls if re.match(r"  build diff \| [<>] ", l)) == 2, "the two builds' source differs in one line each way")
    need(any('build diff | > ' in l and '"/probe/members/{name}"' in l for l in ls) and any('build diff | < ' in l and '"/probe/people/{name}"' in l for l in ls), "the one line: the literal /probe/people -> /probe/members")
    cl = grab_all(ls, r"classes \| (\S+) A \w+ B \w+ (equal|differ)$")
    need([m.group(1) for m in cl if m.group(2) == "differ"] == ["probe/u15/U15Moved.class"], "only U15Moved.class differs between the builds (%d classes)" % len(cl))
    f = grab_all(ls, r"follow \| (build [AB]) .* · (written-path client GET /probe/people/Ravi -> (\d+) (\S+) · members (\[.*?\]) · name=(\S+)|link-following client GET /probe/entry -> (\d+), its link 'ravi' -> (\S+) -> (\d+) (\S+) · members (\[.*?\]) · name=(\S+))$")
    r = {}
    for m in f:
        r[(m.group(1), "w" if m.group(3) else "f")] = m
    if need(len(r) == 4, "the four follow lines parsed"):
        need(r[("build A", "w")].group(3) == "200" and r[("build A", "w")].group(6) == "Ravi", "build A: the written-path client 200, Ravi")
        need(r[("build A", "f")].group(7) == "200" and r[("build A", "f")].group(8) == "http://127.0.0.1:<port>/probe/people/Ravi" and r[("build A", "f")].group(9) == "200", "build A: the follower 200 via /probe/people/Ravi")
        w = r[("build B", "w")]
        need(w.group(3) == "404" and w.group(6) == "None" and "'name'" not in w.group(5), "build B: the written-path client 404, no name member (%s %s)" % (w.group(4), w.group(5)))
        fb = r[("build B", "f")]
        need(fb.group(7) == "200" and fb.group(8) == "http://127.0.0.1:<port>/probe/members/Ravi" and fb.group(9) == "200" and fb.group(12) == "Ravi", "build B: the follower 200, Ravi, via the link /probe/members/Ravi")
        VALS["moved"] = "%s/%s" % (w.group(3), fb.group(9)); VALS["moved_404_type"] = w.group(4)
    for side, member in (("A", "/probe/people/Ravi"), ("B", "/probe/members/Ravi")):
        acc = [re.match(r"  access %s \| GET (\S+) (\d+) " % side, l) for l in ls if l.startswith("  access %s | " % side)]
        if any(a is None for a in acc):
            fail("unparsable access line (%s)" % side); continue
        p = [(a.group(1), a.group(2)) for a in acc]
        want = [("/probe/people/Ravi", "200" if side == "A" else "404"), ("/probe/entry", "200"), (member, "200")]
        need(p == want, "build %s's access log: the written client's ONE request, then the follower's TWO (entry, then the link it read): %s" % (side, p))


def c_literal(ls):
    oc = grab(ls, r"ops committed \| OPERATIONS (\d+) PATHS (\d+)", "the committed counts")
    os_ = grab(ls, r"ops served \(servers removed\) \| OPERATIONS (\d+) PATHS (\d+)", "the served counts")
    ops = grab_all(ls, r"ops committed \|   (GET|POST|PUT|PATCH|DELETE) +(\S+) +(\S+)$")
    if oc and os_:
        need(int(oc.group(1)) == len(ops), "the committed count (%s) = its listing's lines (%d)" % (oc.group(1), len(ops)))
        need(oc.groups() == os_.groups(), "the served document's counts = the committed file's (%s / %s)" % oc.groups())
        VALS["ops"] = oc.group(1); VALS["paths"] = oc.group(2)
    need(any(l.endswith("as parsed JSON: equal") for l in ls), "the served document (servers removed) = the committed file")
    m = grab(ls, r"the committed spec (\d+) B md5 ([0-9a-f]{32})", "the spec")
    if m:
        VALS["spec_bytes"] = m.group(1); VALS["spec_md5"] = m.group(2)[:8]
    pc = grab(ls, r"paths \| PATH_CONSTANTS (\d+) FILES (\d+)", "the constants count")
    rows = grab_all(ls, r"paths \|   (\w+\.java):(\d+) (PATH_\w+)$")
    if pc:
        need(int(pc.group(1)) == len(rows), "the constants count (%s) = its listing's lines (%d)" % (pc.group(1), len(rows)))
        need(int(pc.group(2)) == len({r.group(1) for r in rows}), "the files count (%s) = the distinct files in the listing" % pc.group(2))
        VALS["constants"] = pc.group(1); VALS["const_files"] = pc.group(2)
    t = grab(ls, r"table \| constants (\d+) · distinct strings (\d+) · @HttpExchange methods (\d+)", "the table's totals")
    tr = grab_all(ls, r"table \| (PATH_\w+) +(\w+) +(\S+) +method (\w+) +operationId (\S+)$")
    if t and pc:
        need(t.group(1) == pc.group(1) and t.group(3) == pc.group(1), "the table: %s constants, %s methods = the counter's %s" % (t.group(1), t.group(3), pc.group(1)))
        need(len(tr) == int(t.group(3)) and all(r.group(5) != "None" for r in tr), "every constant pairs with an operationId of the spec")
        VALS["distinct"] = t.group(2)
        if oc: need(t.group(3) == oc.group(1), "one constant per operation: %s = %s" % (t.group(3), oc.group(1)))
    need(any("PATH_CUSTOMER_FIELDS" in r.group(1) and r.group(5) == "customerFields" for r in tr), "U14's operation customerFields pairs with PATH_CUSTOMER_FIELDS")
    need(any(r.group(1) == "PATH_ORDER_PAGE" and r.group(5) == "orderPage" for r in tr), "U13's operation orderPage pairs with PATH_ORDER_PAGE")
    m = grab(ls, r"vocabulary \| .*: (\d+)$", "the link vocabulary")
    if m:
        VALS["link_vocab"] = m.group(1)
    m = grab(ls, r"its \.java files (\d+)", "the generated set")
    if m:
        VALS["client_files"] = m.group(1)
    p1 = grab(ls, r"plant \| ops on an empty spec \(\{\}\) -> exit (\d+) · (.*)$", "the empty spec"); p2 = grab(ls, r"plant \| paths on an empty directory -> exit (\d+) · (.*)$", "the empty dir")
    if p1 and p2:
        need(p1.group(1) == "1" and "REFUSED" in p1.group(2) and p2.group(1) == "1" and "REFUSED" in p2.group(2), "R.527: the counter refuses an empty spec and an empty directory (exit 1, REFUSED)")
    need(any("c9-unit12/after's client (RED3 #3), another tree" in l for l in ls), "the probe's 13 read and named another tree's")


def c_final(ls):
    rows = grab_all(ls, r"census \| (\w+) +final (yes|no) +dev-only (yes|no) +(\S+):(\d+)$")
    m = grab(ls, r"census \| controllers (\d+) · final, default-run (\d+) · not final, dev-only (\d+) · other (\d+)", "the census totals")
    if m:
        need(int(m.group(1)) == len(rows), "the census total (%s) = its rows (%d)" % (m.group(1), len(rows)))
        need(int(m.group(2)) == sum(1 for r in rows if r.group(2) == "yes" and r.group(3) == "no"), "the final default-run count = its rows")
        VALS["census"] = "%s/%s/%s" % m.groups()[1:4]
    need(any("excluded by the rule: TiffinBoxErrors" in l for l in ls), "the census's excluded line: TiffinBoxErrors (@RestControllerAdvice)")
    need(not any(r.group(1) == "TiffinBoxErrors" for r in rows), "TiffinBoxErrors is not counted")
    need(any(r.group(1) == "CustomerReads" and r.group(2) == "yes" for r in rows), "CustomerReads is a final controller")
    f = {m.group(1): m.group(2) for m in grab_all(ls, r"^  final \| (methodOn|methodOnRoot|methodForm|nonFinal): (.*)$")}
    g = gets(ls, "final")
    if g:
        same_size(g[0], "final /probe/hal/final"); need(g[0]["code"] == 200, "the harness's final route answers 200")
    need(f.get("methodOn", "").startswith("org.springframework.aop.framework.AopConfigException: Could not generate CGLIB subclass of class com.tiffinbox.web.CustomerReads"),
         "methodOn() on the final CustomerReads: AopConfigException 'Could not generate CGLIB subclass' (from this run's body)")
    need(f.get("methodOnRoot", "").startswith("java.lang.IllegalArgumentException: Cannot subclass final class com.tiffinbox.web.CustomerReads"), "its root cause: Cannot subclass final class")
    need(f.get("methodForm") == "http://127.0.0.1:<port>/api/v1/customers/Ravi", "the Method form builds the link on the final class")
    need(f.get("nonFinal") == "http://127.0.0.1:<port>/probe/hal/customers/Ravi", "methodOn() on the non-final harness class builds its link")
    need(sum(1 for l in ls if re.search(r"source \| \d+:final class CustomerReads .*\(CustomerReads\.java\) · \d+:final class CustomerFields", l)) == 1, "the two declaration lines with their numbers")


def c_placeholder(ls):
    for side, route in (("unset", "/probe/people/Ravi"), ("set", "/probe/members/Ravi")):
        g = gets(ls, "ph-" + side)
        for x in g:
            same_size(x, "ph-%s %s" % (side, x["path"]))
        r = find(g, route); e = find(g, "/probe/entry")
        need(r["code"] == 200 and e["code"] == 200, "%s: the route %s and the entry point answer 200" % (side, route))
        m = grab(ls, r"ph-%s \| the entry's body: (.*)$" % side, "the entry body (%s)" % side)
        if m:
            need("${probe.customers-path" in m.group(1), "%s: the entry's link holds the placeholder as written (%s)" % (side, m.group(1)[:90]))
        m = grab(ls, r"ph-%s \| the link followed .* -> (\d+) (\S+) (\d+) B · title (.*)$" % side, "the follow (%s)" % side)
        if m:
            need(m.group(1) == "400", "%s: the link followed is refused 400 (%s)" % (side, m.group(2)))
            VALS["ph_" + side] = m.group(1)
        m = grab(ls, r"ph-%s \| the JVM log on the refusal: (.*)$" % side, "the JVM log (%s)" % side)
        if m:
            need("o.apache.coyote.http11.Http11Processor" in m.group(1) and "Invalid character found in the request target" in m.group(1),
                 "%s: the refuser named by the JVM log: Tomcat's Http11Processor, 'Invalid character found in the request target'" % side)
        acc = [l for l in ls if l.startswith("  access %s | " % side)]
        need(len(acc) == len(g) + 1 and acc[-1].startswith("  access %s | GET - 400 " % side) and not any("${" in l for l in acc),
             "%s: the access log holds curl's %d requests and one GET with no path, 400 - the request target refused before a path was read" % (side, len(g)))
    VALS["refuser"] = "Http11Processor"


def c_seven(ls):
    m = grab(ls, r"expected ([0-9a-f]{32})", "the expectation")
    got = {x.group(1): x.group(2) for x in grab_all(ls, r"^  (before|copy): the seven ([0-9a-f]{32})")}
    if m and need(len(got) == 2, "the seven on both"):
        need(got["before"] == m.group(1) and got["copy"] == m.group(1), "the seven on before and on the copy with the starter = %s" % m.group(1)[:8])
        VALS["seven"] = m.group(1)[:8]


def c_surface(ls):
    m = grab(ls, r"expected ([0-9a-f]{32})", "the expectation")
    got = {x.group(1): x.group(2) for x in grab_all(ls, r"^  (before|copy): the old surface ([0-9a-f]{32}) \((\d+) requests")}
    if m and need(len(got) == 2, "the old surface on both"):
        need(got["before"] == m.group(1) and got["copy"] == m.group(1), "the old surface on before and on the copy = %s" % m.group(1)[:8])
        VALS["surface"] = m.group(1)[:8]
    need(any("~ plant (21042" in l and "moved, as planted" in l for l in ls), "the S9.14 plant moved the surface (the check can fail)")


def c_inert(ls):
    m = grab(ls, r"lines naming the key header across the captures: (\d+)", "the count"); n = grab(ls, r"in harness/follow\.py, harness/src and exercise/: (\d+)", "the harness")
    if m and n:
        need(m.group(1) == "0" and n.group(1) == "0", "no request of this unit names the key header")


def c_exercise(ls):
    need(any(re.match(r"  build\.sh -> exit 0 · built:", l) for l in ls), "build.sh built both servers")
    need(any("check.sh client.py (no --allow-broken) -> exit 1 · check.sh: refused" in l for l in ls), "check.sh refuses client.py itself as the file under test")
    mA = grab(ls, r"measured \| server A \(.*\): the client printed: (.*) \(exit (\d+)\)$", "the broken client on A")
    mB = grab(ls, r"measured \| server B \(.*\): the client printed: (.*) \(exit (\d+)\)$", "the broken client on B")
    eA = grab(ls, r"measured \| server A: the client's requests: (.*) · the entry point's link: (\S+)$", "A's requests"); eB = grab(ls, r"measured \| server B: the client's requests: (.*) · the entry point's link: (\S+)$", "B's requests")
    if mA and mB and eA and eB:
        need(mA.group(1) == "the member -> 200|Ravi" and mA.group(2) == "0", "measured: the broken client against A reads Ravi (200)")
        need(mB.group(1) == "the member -> 404" and mB.group(2) == "1", "measured: the broken client against B gets 404, on the route the exercise names")
        need(eA.group(1) == "GET /probe/people/Ravi 200" and eB.group(1) == "GET /probe/people/Ravi 404", "the access logs: the broken client's one request each")
        need(eA.group(2).endswith("/probe/people/Ravi") and eB.group(2).endswith("/probe/members/Ravi"), "the entry point answers with its link on both builds (people, members)")
        VALS["ex_broken"] = "200/404"
    for v in ("broken", "solved"):
        for sh in ("bash", "zsh"):
            blk = [l for l in ls if l.startswith("  %s %s | " % (v, sh))]
            want = "0" if v == "solved" else "1"
            need(any(l.endswith("check exit " + want) for l in blk), "%s under %s: check exit %s" % (v, sh, want))
            if v == "solved":
                need(any(l.endswith("PASS - every clause holds") for l in blk), "solved under %s: PASS" % sh)
    var = {m.group(1): m for m in grab_all(ls, r"^  variant (\w+) bash \| check exit (\d+)$")}
    need(sorted(var) == ["bothpaths", "entryonly", "ignore404", "wired"], "the four refused variants ran (%s)" % ",".join(sorted(var)))
    for v, n in var.items():
        need(n.group(2) == "1", "the refused variant %s fails (R.196)" % v)
    VALS["ex_variants"] = sum(1 for n in var.values() if n.group(2) == "1")
    need(any(l.endswith("the lines apply.sh writes: yes") for l in ls), "SOLUTION.md's lines = apply.sh's")
    rd = [l[len("  README: "):] for l in ls if l.startswith("  README: ")]
    sd = [l[len("  SOLUTION: "):] for l in ls if l.startswith("  SOLUTION: ")]
    meas = [l[len("  measured | "):] for l in ls if l.startswith("  measured | ")]
    sol = [l[len("  solved bash | "):] for l in ls if l.startswith("  solved bash | ") and not l.endswith(("check exit 0",))]
    need(rd == meas[:len(rd)] and len(rd) >= 4, "exercise/README.md's What it prints = the measured broken answer (%d lines)" % len(rd))
    need(sd == sol, "exercise/SOLUTION.md's What it prints = the solved run under bash (%d lines)" % len(sd))


def hashable(name, f):
    for l in lines(f):
        if l.startswith("  ~"):
            continue
        print(l)


# ---- static ---------------------------------------------------------------------------------------------------------------------------
def git(*a):
    return subprocess.run(["git"] + list(a), capture_output=True, text=True).stdout


def static(unit, receipts):
    u = os.path.abspath(unit)
    for t in ("before", "after"):
        need(os.path.islink(os.path.join(u, t)) and os.readlink(os.path.join(u, t)) == "../c9-unit14/after", "%s is a link whose text is ../c9-unit14/after" % t)
    os.chdir(os.path.dirname(u))
    units = ["c9-tiffinbox"] + ["c9-unit%02d" % i for i in range(1, 15)]
    need(git("diff", "--stat", "f3724ca", "--", *units) == "", "git diff --stat f3724ca -- c9-tiffinbox c9-unit01 .. c9-unit14: empty")
    need(git("diff", "--stat", "f3724ca", "--", "*pom.xml") == "", "git diff --stat f3724ca -- '*pom.xml': empty")
    os.chdir(u)
    walked = []
    for d, ds, fs in os.walk("."):
        ds[:] = [x for x in ds if x not in (".harness", ".m2-demo")]
        walked += [os.path.join(d, f) for f in fs] + [os.path.join(d, x) for x in ds]
    need(not any("tiffinbox-web/src/main" in p for p in walked), "no tiffinbox-web/src/main path under c9-unit15/ (the harness lives in harness/src/probe/u15/)")
    need(not any(os.path.basename(p) in ("target", "secrets") for p in walked), "no target/ or secrets/ in this folder")
    me = open(__file__, encoding="utf-8").read(); rs = open(receipts, encoding="utf-8").read()
    for n in LEFT_OUT:
        need(not re.search(r"^def c_%s\(" % n, me, re.M) and not re.search(r"^cap %s " % n, rs, re.M), "the left-out capture %s is in neither the checker nor receipts.sh" % n)
    hs = "".join(open(os.path.join(d, f), encoding="utf-8", errors="replace").read() for d, _, fs in os.walk("harness") for f in fs if f != "chk15.py")
    need("probe.u14" not in hs and "probe.u13" not in hs, "no probe.u13 / probe.u14 class in harness/")
    need("compression" not in re.sub(r"(?m)^#.*$", "", rs).replace("no compression flag anywhere", ""), "no compression token in receipts.sh's commands")
    need(len(re.findall(r"--spring\.main\.sources=probe\.u15\.U15Config", rs)) >= 1 and "src=\"--spring.main.sources=probe.u15.U15Config\"" in rs, "the harness is joined only through tb's HARNESS argument")
    need(" -pl tiffinbox-core" not in rs, "no -pl tiffinbox-core form")
    r = open("README.md", encoding="utf-8").read()
    prose = re.sub(r"```.*?```", "", r, flags=re.S)
    prose = re.sub(r"<!-- values: begin -->.*?<!-- values: end -->", "", prose, flags=re.S)
    nocode = re.sub(r"`[^`]*`", "", prose)
    for w in ("thirteen", "13 / 6", "174.0", "70.5", "X-Forwarded"):
        need(w not in nocode, "README: no '%s' outside code spans and capture blocks" % w)
    need("most teams" not in nocode, "README: 'most teams' only inside a code span with its source")
    for m in re.finditer(r"`[^`]*most teams[^`]*`", prose):
        need(re.search(r"\[RM :387\]|\[SET", prose[m.end():m.end() + 40]) is not None, "README: the quoted 'most teams' carries its source")
    need(not re.search(r"\bmore than (?:double|twice)\b|\b(?:two|three) times\b|\d ?%|\bper (?:item|customer)\b", nocode), "README: no typed ratio, percentage or per-item figure")
    need("excluded by the rule: TiffinBoxErrors" in r, "README: the census's excluded line")
    lit = os.path.join(u, ".r-literal.out")
    if os.path.exists(lit):
        m = re.search(r"PATH_CONSTANTS (\d+) FILES (\d+)", open(lit, encoding="utf-8").read())
        need(m is not None and ("constants=%s" % m.group(1)) in r, "README: the PATH_* count = the literal capture's print")
    need(not re.search(r"(?<![\w.:<])\d{1,2}:\d{2}(?::\d{2})? ?(?:CET|UTC)?\b", nocode.split("## Runs of record")[0]), "README: no clock figure before the runs section")


def unit15():
    t = open(BRIEF, encoding="utf-8").read()
    return t.split("## Unit 15", 1)[1].split("\n## ", 1)[0]


def hook():
    m = re.search(r'\*\*Hook \(\[S3 §9\]\):\*\* "([^"]+)"', unit15())
    print(m.group(1) if m else "FAIL no hook line")


def exq():
    m = re.search(r'\*\*Exercise:\*\* "(Your turn: [^"]+)"', unit15())
    print(m.group(1) if m else "FAIL no exercise line")


def interleaved():
    t = open(BRIEF, encoding="utf-8").read().split("\n")
    gate = [l for l in t if l.startswith("**Gates on this brief's own lines")]
    body = [l for l in t if not l.startswith("**Gates on this brief's own lines")]
    hs = [m.group(1) for m in (re.search(r'\*\*Hook \(\[S3 §\d+\]\):\*\* "([^"]+)"', l) for l in body) if m]
    es = [m.group(1) for m in (re.search(r'\*\*Exercise:\*\* "([^"]+)"', l) for l in body) if m]
    h = hashlib.md5("\n".join(x for p in zip(hs, es) for x in p).encode()).hexdigest()
    if len(gate) != 1 or len(hs) != 6 or len(es) != 6 or h != "1f1f7d32df49d49e39df4ba58a94f9b2":
        fail("the interleaved list: %d + %d (gates paragraph lines %d), md5 %s" % (len(hs), len(es), len(gate), h))
        return
    print("the brief's hooks and exercises: %d + %d (the gates paragraph's own pattern line excluded: %d), interleaved md5 %s = S3B's" % (len(hs), len(es), len(gate), h))


def gloss(readme):
    ls = lines(readme)
    need(sum(1 for l in ls if l.startswith("A link relation:")) == 1, "exactly one README line starts 'A link relation:'")
    need(GLOSS in ls, "the gloss line byte for byte")
    need(len(GLOSS.split()) <= 25, "the gloss %d words (<= 25)" % len(GLOSS.split()))
    for g in ("A sparse fieldset:", "A cursor:", "A version carrier:", "A snippet:", "A contract:", "Swagger UI:", "A problem type:", "Code generation:"):
        need(not any(l.startswith(g) for l in ls), "no second gloss of an earlier unit's kind (%s)" % g)
    base = os.path.dirname(os.path.dirname(os.path.abspath(readme)))
    for u, g in (("06", None), ("08", None), ("09", None), ("10", None), ("11", None), ("12", None), ("13", "A cursor:"), ("14", "A sparse fieldset:")):
        p = os.path.join(base, "c9-unit%s/README.md" % u)
        if os.path.exists(p):
            gl = [l for l in lines(p) if re.match(r"^A [a-z ]+:|^Swagger UI:|^Code generation:", l)]
            need(len(gl) <= 2, "unit %s's README keeps its own gloss lines (%d, read)" % (u, len(gl)))
    print("VALUES gloss_words=%d" % len(GLOSS.split()))


def values(readme, vals):
    t = open(readme, encoding="utf-8").read()
    m = re.search(r"<!-- values: begin -->\n```\n(.*?)\n```\n<!-- values: end -->", t, re.S)
    if not m:
        fail("README.md has no values block")
        return
    want = [l.rstrip() for l in vals.strip().splitlines()]
    got = [l.rstrip() for l in m.group(1).strip().splitlines()]
    need(got == want, "the README's values block = this run's values (%d lines)" % len(want))
    if got != want:
        for a in want:
            if a not in got:
                print("  this run: " + a)
        for a in got:
            if a not in want:
                print("  README:   " + a)


# ---- plants: each made to FAIL first ------------------------------------------------------------------------------------------------------
def plants(capdir):
    def run(name, text):
        global FAILS
        f0 = FAILS
        FAILS = []
        import io, contextlib
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            try:
                FN[name](text.splitlines())
            except Exception as e:  # noqa
                fail("unparsable (%s)" % e.__class__.__name__)
        n = len(FAILS)
        FAILS = f0
        return n
    P = [("advisory", "the filed read one day older than the run", lambda t: re.sub(r"(· run date )2026-11-26", r"\g<1>2026-11-27", t, count=1)),
         ("before", "the harness's route answering on before", lambda t: re.sub(r"(GET /probe/entry \(Accept: application/hal\+json\) -> )404", r"\g<1>200", t, count=1)),
         ("pin", "3.1.3 typed", lambda t: t.replace("Implementation-Version 3.1.4", "Implementation-Version 3.1.3", 1)),
         ("pin", "HAL on Jackson 2 typed", lambda t: re.sub(r"referencing com/fasterxml/jackson/databind 0", "referencing com/fasterxml/jackson/databind 3", t, count=1)),
         ("starter", "BOOT-INF/lib typed 157 on the copy", lambda t: re.sub(r"(lib \| before 157 names · the copy )\d+", r"\g<1>157", t, count=1)),
         ("starter", "the starter edit applied to before's own pom", lambda t: re.sub(r"(git diff --stat f3724ca -- '\*pom\.xml': )0", r"\g<1>2", t, count=1)),
         ("starter", "a moved class typed as not moved", lambda t: re.sub(r"(classes that differ: )(\d+)", lambda m: m.group(1) + str(int(m.group(2)) + 1), t, count=1)),
         ("cost", "a byte count one off", lambda t: re.sub(r"(cost \| GET /probe/hal/customers/Ravi \(Accept: application/hal\+json\) -> 200 application/hal\+json )(\d+)", lambda m: m.group(1) + str(int(m.group(2)) + 1), t, count=1)),
         ("cost", "the host omitted from a HAL number", lambda t: t.replace("hosts http://127.0.0.1:<port>", "hosts none", 1)),
         ("cost", "the _links bytes typed one off", lambda t: re.sub(r"(cost hal one \| .* the _links members )(\d+)", lambda m: m.group(1) + str(int(m.group(2)) - 1), t, count=1)),
         ("moved", "the written-path status typed 200 against build B", lambda t: re.sub(r"(build B .* written-path client GET /probe/people/Ravi -> )404", r"\g<1>200", t, count=1)),
         ("moved", "the follower's access-log request count typed 1", lambda t: re.sub(r"(?m)^  access B \| GET /probe/entry .*\n", "", t, count=1)),
         ("moved", "the two builds' diff touched by a second line", lambda t: re.sub(r"(classes \| probe/u15/U15Hal\.class A \w+ B \w+ )equal", r"\1differ", t, count=1)),
         ("literal", "the constants count one off", lambda t: re.sub(r"(paths \| PATH_CONSTANTS )(\d+)", lambda m: m.group(1) + str(int(m.group(2)) + 1), t, count=1)),
         ("literal", "the counter not refusing an empty spec", lambda t: re.sub(r"(ops on an empty spec \(\{\}\) -> exit )1 · .*", r"\g<1>0 · OPERATIONS 0 PATHS 0", t, count=1)),
         ("literal", "the count taken on c9-unit12/after's probe file", lambda t: re.sub(r"(ops committed \| OPERATIONS )\d+( PATHS )\d+", r"\g<1>13\g<2>11", t, count=1)),
         ("final", "methodOn typed as working on CustomerReads", lambda t: re.sub(r"(final \| methodOn: ).*", r"\g<1>http://127.0.0.1:<port>/api/v1/customers/Ravi", t, count=1)),
         ("final", "the census rule loosened so the advice class counts", lambda t: re.sub(r"(?m)^  census \| excluded by the rule: TiffinBoxErrors.*$", "  census | TiffinBoxErrors   final yes dev-only no  TiffinBoxErrors.java:27", t, count=1)),
         ("placeholder", "the 400 typed 200", lambda t: re.sub(r"(ph-unset \| the link followed .* -> )400", r"\g<1>200", t, count=1)),
         ("placeholder", "the route's 400 with no log line", lambda t: re.sub(r"(ph-unset \| the JVM log on the refusal: ).*", r"\1", t, count=1)),
         ("placeholder", "the placeholder typed resolved in the link", lambda t: re.sub(r"(ph-unset \| the entry's body: ).*", r'\1{"_links":{"ravi":{"href":"http://127.0.0.1:<port>/probe/people/Ravi"}}}', t, count=1)),
         ("seven", "the seven's md5 one character off", lambda t: re.sub(r"(copy: the seven )(\w)", lambda m: m.group(1) + ("0" if m.group(2) != "0" else "1"), t, count=1)),
         ("surface", "the S9.14 plant not seen", lambda t: t.replace("moved, as planted", "EQUAL (the plant was not seen)", 1)),
         ("exercise", "the broken state's answer borrowed from another route", lambda t: re.sub(r"(measured \| server B \(.*\): the client printed: )the member -> 404 \(exit 1\)", r"\g<1>the member -> 200|Ravi (exit 0)", t, count=1)),
         ("exercise", "solution = broken", lambda t: re.sub(r"(?m)^(  solved bash \| .*)check exit 0$", r"\1check exit 1", t, count=1)),
         ("exercise", "a refused variant typed passing", lambda t: re.sub(r"(?m)^(  variant \w+ bash \| check exit )1$", r"\g<1>0", t, count=1)),
         ("cost", "an access-log line the checker cannot parse", lambda t: re.sub(r"(?m)^  access \| GET ", "  access | GOT ", t, count=1)),
         ("inert", "a key header typed", lambda t: re.sub(r"(across the captures: )0", r"\g<1>1", t, count=1))]
    n = 0
    for cap, what, mut in P:
        f = os.path.join(capdir, ".r-%s.new" % cap)
        if not os.path.exists(f):
            f = os.path.join(capdir, ".r-%s.out" % cap)
        t = open(f, encoding="utf-8").read()
        t2 = mut(t)
        if t2 == t:
            fail("plant %s / %s: the mutation did not apply" % (cap, what))
            continue
        base = run(cap, t)
        got = run(cap, t2)
        if base == 0 and got > 0:
            ok("plant %s / %s: FAIL (%d), exit 1, no traceback" % (cap, what, got))
            n += 1
        else:
            fail("plant %s / %s: not caught (base %d, planted %d)" % (cap, what, base, got))
    # the prose plants: each XU15 plant refused by s915.py's self-test (it asserts them before it runs); the README plants on a scratch copy
    here = os.path.dirname(os.path.abspath(__file__))
    import tempfile, shutil
    tmp = tempfile.mkdtemp(prefix="c9u15-plant-")
    try:
        rd = open(os.path.join(capdir, "README.md"), encoding="utf-8").read()
        for what, txt in (("thirteen typed", rd + "\nThe probe counted thirteen.\n"), ("most teams typed", rd + "\nMost teams skip hypermedia.\n"),
                          ("a ratio typed", rd + "\nThe links make it more than double.\n"), ("per item typed", rd + "\nIt is that many bytes per item.\n"),
                          ("generated clients in general", rd + "\nGenerated clients can't follow links.\n"), ("a duration word", rd + "\nIt answers instantly.\n"),
                          ("a status in digits", rd + "\nThe follower gets 200 back.\n"), ("a second gloss", rd + "\nA sparse fieldset: only the fields asked for.\n")):
            p = os.path.join(tmp, "README.md"); open(p, "w", encoding="utf-8").write(txt)
            r = subprocess.run([sys.executable, "-I", "-B", os.path.join(here, "s915.py"), os.path.join(here, "dur9.py"), p], capture_output=True, text=True)
            last = (r.stdout.strip().splitlines() or [""])[-1]
            if r.returncode == 0 and not last.endswith("refused: 0"):
                ok("plant README / %s: refused by s915.py (%s)" % (what, last.split("· ")[-1])); n += 1
            else:
                fail("plant README / %s: not refused (%s)" % (what, last))
    finally:
        shutil.rmtree(tmp)
    print("VALUES plants=%d" % n)


FN = {n: globals()["c_" + n] for n in CAPS}

if __name__ == "__main__":
    a = sys.argv[1:]
    try:
        if a[0] in FN:
            FN[a[0]](lines(a[1]))
            print("VALUES " + " ".join("%s=%s" % kv for kv in VALS.items()))
        elif a[0] == "hashable":
            hashable(a[1], a[2])
        elif a[0] == "static":
            static(a[1], a[2])
        elif a[0] == "gloss":
            gloss(a[1])
        elif a[0] == "gloss-line":
            print(GLOSS)
        elif a[0] == "hook":
            hook()
        elif a[0] == "exq":
            exq()
        elif a[0] == "interleaved":
            interleaved()
        elif a[0] == "values":
            values(a[1], a[2])
        elif a[0] == "plants":
            plants(a[1])
        else:
            fail("unknown mode " + a[0])
    except Exception as e:  # a listing it cannot parse is a FAIL line, never a traceback
        fail("unparsable (%s: %s)" % (e.__class__.__name__, str(e)[:120]))
    sys.exit(1 if FAILS else 0)
