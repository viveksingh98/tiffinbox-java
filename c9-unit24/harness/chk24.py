"""Course 9 unit 24's checks (python3 -I -B harness/chk24.py SUBCOMMAND ...), run from c9-unit24/ (unit 23's chk23.py's machinery).

Each capture's check reads the masked capture file the receipt wrote (.r-NAME.new) and prints "ok ..." or "FAIL ..." lines and one
"VALUES ..." line; any FAIL exits 1 (a line it cannot parse is a FAIL line, exit 1, never a traceback). A moved line of the compat guard
outside the retired route's own requests is "FAIL HOLD ...": the receipt then stops under the HOLD rule. `static` reads only this unit's
folder, the trees of before/ and after/, and git objects of unit 22's commit (d7e0663) - never the live anchor: an audit hook refuses any
open() whose real path lies in the live anchor's folder, so a static read of it exits 1 (flag 14).
Subcommands: static AFTER BEFORE · static-plant live|pieces · gloss README · hook · exq · title-line · interleaved · hashable NAME FILE ·
values README VALS · plants DIR · and one per capture: advisory before census count announce remove compat gone tests spec client api
seven surface moved inert change stale frozen exercise title.
"""
import hashlib, os, re, subprocess, sys

ANCHOR_DIR = "/c9-" + "tiffinbox"   # LIVE_ANCHOR_PLANT: the live anchor's folder name, assembled so a grep for it finds only this line


def _guard(event, args):
    if event == "open" and args and isinstance(args[0], (str, bytes, os.PathLike)):
        p = os.path.realpath(os.fsdecode(args[0]))
        if (ANCHOR_DIR + "/") in p or p.endswith(ANCHOR_DIR):
            raise SystemExit("FAIL flag 14: a static check read the live anchor (%s)" % p)


H22 = "d7e0663"
LEFT_OUT = ["drop", "bind", "bindblock", "record", "strict", "key", "block", "reach", "limits", "named", "scrape", "tags", "known", "unknown",
            "filters", "errors", "duration", "dev", "factory", "timeout", "retry", "mock", "shallow", "paths", "weak", "deep", "ifmatch", "cache",
            "chrome", "forge", "xff", "refill", "twojvm", "lua", "starter", "cost", "literal", "final", "placeholder", "walk", "pageable", "trap",
            "table", "first", "next"]
GLOSSES = ["A precondition:", "A token bucket:", "A cursor:", "A sparse fieldset:", "A link relation:", "`HAL`:", "A status resource:",
           "A presigned URL:", "A version carrier:", "A snippet:", "A contract:", "Swagger UI:", "A problem type:", "Code generation:",
           "A read timeout:", "A retry:", "An ETag:", "A validator:", "Over-posting:", "Mass assignment:", "The RED method:"]
# C-gloss's bound words, "A sunset:", are refused by dur9.py's `Sunset:` header form: the gloss names the date
GLOSS = "A sunset date: the date an endpoint stops answering."
FILES = "README.md after before exercise harness receipts.md5 receipts.sh"
HARNESS = "chk24.py dur9.py mirror norm.py ops9s3.py s924.py scrape.py tree24.py"
EXFILES = "README.md SOLUTION.md apply.sh break.sh check.sh"
CHANGED = {"README.md", "tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerNotFound.java", "tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerReads.java",
           "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxErrors.java", "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java",
           "tiffinbox-web/src/test/java/com/tiffinbox/web/ApiVersionTest.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/CustomerPatchesTest.java",
           "tiffinbox-web/src/test/java/com/tiffinbox/web/CustomerReadsTest.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/RateLimitFilterTest.java",
           "tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java", "tiffinbox-web/src/test/java/com/tiffinbox/web/RetiredRouteTest.java",
           "tiffinbox-web/src/test/resources/openapi/tiffinbox.json"}
# the table of edits (method · the state it pins after unit 24); the need-measure's red list must be these + OpenApiSpecTest's one method
EDITED = ["ApiVersionTest.theOldAddressAnswersAsBefore", "CustomerPatchesTest.aRenameLeavesNothingAtTheOldAddress",
          "CustomerReadsTest.thePublicReadAnswersWhatTheOldAddressAnswers", "RateLimitFilterTest.aRouteOutsideTheApiIsNeverRefused",
          "TiffinBoxWebTest.aNameNobodyHasIsAProblemDetail", "TiffinBoxWebTest.aNameNobodyHasIsTyped"]
SPECRED = "OpenApiSpecTest.theServedDocumentIsTheCommittedOne"
TYPE = "tag:tiffinbox.example,2026:route-retired"
SUCC = "5394e0ebc1b6"   # the successor's 67-byte body for Ravi, md5's first 12 (the count and announce captures print it)
OUT = []
BUDGET = 60


def ok(c, msg):
    OUT.append(("ok " if c else "FAIL ") + msg)
    return c


def finish(values=""):
    for l in OUT: print(l)
    if values is not None: print("VALUES " + values)
    sys.exit(1 if any(l.startswith("FAIL") for l in OUT) else 0)


def grab(text, rx, flags=re.M):
    m = re.search(rx, text, flags)
    return m.group(1) if m else None


def md5(b): return hashlib.md5(b).hexdigest()


def walk(r):
    out = {}
    for d, ds, fs in os.walk(r):
        for f in fs:
            p = os.path.join(d, f); out[os.path.relpath(p, r)] = md5(open(p, "rb").read())
    return out


def gitobj(rel):
    top = os.environ.get("REPO") or subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True).stdout.strip()
    r = subprocess.run(["git", "-C", top, "show", "%s:c9-unit22/after/%s" % (H22, rel)], capture_output=True)
    return r.stdout if r.returncode == 0 else None


def static(a, b):
    sys.addaudithook(_guard)
    ok(" ".join(sorted(x for x in os.listdir(".") if not re.match(r"^\.(m2-demo|harness|r-.*)$", x))) == FILES, "the folder's files exactly: " + FILES)
    ok(" ".join(sorted(os.listdir("harness"))) == HARNESS, "harness/'s files exactly: " + HARNESS)
    ok(sorted(os.listdir("harness/mirror")) == ["announce.diff", "compat0.diff", "remove.diff"], "harness/mirror holds the three named diffs only")
    ok(" ".join(sorted(x for x in os.listdir("exercise") if x not in (".servers", ".work", "check.run", "check.build.log"))) == EXFILES, "exercise/'s files exactly")
    ok(os.path.islink(b) and os.readlink(b) == "../c9-unit23/after", "before is a link whose text is ../c9-unit23/after (C11)")
    ok(os.path.isdir(a) and not os.path.islink(a), "after is a folder, not a link")
    A, Bt = walk(a), walk(b)
    ok(not [k for k in list(A) + list(Bt) if k.split("/")[0] in ("target", "secrets", ".m2-demo", ".harness") or "/target/" in k], "no target/, secrets/, .m2-demo or .harness in either tree")
    ch = {k for k in set(A) | set(Bt) if A.get(k) != Bt.get(k)}
    ok(ch == CHANGED, "the paths after/ moves against before/ are exactly the change's %d (extra %s, missing %s)" % (len(CHANGED), sorted(ch - CHANGED), sorted(CHANGED - ch)))
    ok(not [k for k in ch if k.endswith("pom.xml") or k.startswith(("tiffinbox-core/", "tiffinbox-client/")) or k.endswith(".yaml")], "no pom, no core or client file, no yaml moved")
    for rel in ("pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-core/pom.xml", "tiffinbox-client/pom.xml", "tiffinbox-web/src/main/resources/application.yaml",
                "tiffinbox-web/src/test/resources/openapi/tiffinbox.json", "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java"):
        g = gitobj(rel)
        ok(g is not None and md5(g) == Bt.get(rel), "%s through before's link = git show %s:c9-unit22/after/%s" % (rel, H22, rel))
    for rel in sorted(set(Bt) - ch):
        if A.get(rel) != Bt.get(rel): ok(False, "%s moved outside the change" % rel)
    srv = open(os.path.join(a, "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java"), encoding="utf-8").read()
    ok(srv.count('@GetMapping("/customers/{name}")') == 1 and len(re.findall(r" customer\(@PathVariable String name\)", srv)) == 1, "the mapping and the method name customer( unchanged, once (R.535: the operationId)")
    for rel in sorted(ch):
        if rel.endswith(".java"):
            t = open(os.path.join(a, rel), encoding="utf-8").read()
            ok(not re.search(r"\bprobe|\bBLUE\b|harness", t, re.I), "no probe, BLUE or harness word in %s" % rel.split("/")[-1])
    rs = open("receipts.sh", encoding="utf-8").read()
    code = [l for l in rs.splitlines() if not l.lstrip().startswith("#")]
    ok(not [l for l in code if re.match(r"^\s*USTART=['\"]?20\d\d-", l)], "USTART is read from .harness/ustart, never typed in receipts.sh (ev23's defect)")
    ok(sum(1 for l in code if "rate-limit.capacity=5" in l) == 1, "the short capacity: one definition (CAP5)")
    ok(not [l for l in code if re.search(r"^\s*tb \S+ 21(?!13[0568])\d{3} ", l)], "every TiffinBox start on 21130, 21135, 21136 or 21138")
    mv = [l for l in code if "$MV " in l and "$G -" not in l] + [l for l in open("exercise/check.sh", encoding="utf-8").read().splitlines() if "mvn " in l]
    ok(not [l for l in mv if re.search(r" -s | --settings ", l)], "no -s on any Maven line (the default settings)")
    ok(not [l for l in mv if re.search(r"-pl tiffinbox-core(?! -am)", l) or re.search(r"-pl tiffinbox-(web|client)(?! -am)", l)], "R.391: no -pl form without -am")
    rd = open("README.md", encoding="utf-8").read()
    body = re.sub(r"```.*?```", "", rd, flags=re.S)
    ok(re.search(r"_(sum|max)\{[^}]*\} [0-9]", rd) is None, "README: no _sum or _max value")
    ok(re.search(r"\bnothing breaks\b|\bS9\.37 allows\b", body, re.I) is None, "README: no 'nothing breaks', no 'S9.37 allows' (D8)")
    ok(re.search(r"\b1[78]\d{8}\b", body) is None, "README: no epoch outside a quoted block (R.557)")
    t = title()
    ok(len(t) <= 60, "the title for search: %d characters (<= 60)" % len(t))
    me = open(__file__, encoding="utf-8").read()
    subs = set(re.findall(r'^    elif cmd == "([a-z0-9-]+)"', me, re.M)) | set(re.findall(r'^    if cmd == "([a-z0-9-]+)"', me, re.M)) | set(CHECKS)
    ok(not (subs & set(LEFT_OUT)), "no left-out subcommand in chk24.py (%s)" % sorted(subs & set(LEFT_OUT)))
    finish(None)


def brief():
    c9 = os.environ.get("C9R") or ""
    return open(os.path.join(c9, "_briefs/UNIT-BRIEFS-S4-OPERATING.md"), encoding="utf-8").read()


def unit24(): return brief().split("\n## Unit 24", 1)[1].split("\n## BUILDERS", 1)[0]


def hook(): return re.search(r'^\*\*Hook \(\[S4 §\d+\]\):\*\* "([^"]+)"', unit24(), re.M).group(1)


def exq(): return re.search(r'^\*\*Exercise:\*\* "(Your turn: [^"]+)"', unit24(), re.M).group(1)


def title(): return re.search(r'^\*\*Title for search:\*\* "([^"]+)"', unit24(), re.M).group(1)


# ---- capture checks ----------------------------------------------------------------------------------------------------------------
def budget(t):
    for m in re.finditer(r"^  budget \| (\S+): requests under /api/v1/ \(its access log\): (\d+) · refusal lines: (\d+) · rate limit: capacity (\d+)", t, re.M):
        if m.group(1).startswith("cap5"):
            ok(m.group(4) == "5", "%s: the start line reads capacity 5 (the harness's short capacity), refusal lines %s" % (m.group(1), m.group(3)))
        else:
            ok(int(m.group(2)) <= BUDGET and m.group(3) == "0" and m.group(4) == "1000", "N10: %s sent %s /api/v1/ requests (<= %d), refusals %s, capacity %s read back" % (m.group(1), m.group(2), BUDGET, m.group(3), m.group(4)))


REQ = re.compile(r"^  (?:req|[a-z0-9 ]+ \|)?.*?(\d\d) (GET|HEAD|OPTIONS|PUT|DELETE|POST) (\S+)(?: Accept=\S+)? -> (\d{3}) (\S+) · headers \{([^}]*)\} · (.*?) · framing (\S+) · (\d+) B md5 (\w+) · type (\S+) · title (.*?) · instance (\S+) · detail (.*)$", re.M)


def reqs(t, prefix="  req |"):
    out = []
    for l in t.splitlines():
        if not l.startswith(prefix): continue
        m = re.match(r"^.*?\| (\d\d) (\S+) (\S+)(?: Accept=(\S+))? -> (\d{3}) (\S+) · headers \{([^}]*)\} · (.*?) · framing (\S+) · (\d+) B md5 (\w+) · type (\S+) · title (.*?) · instance (\S+) · detail (.*)$", l)
        if not m: ok(False, "an unparseable request line: %s" % l[:90]); continue
        out.append(dict(n=m.group(1), m=m.group(2), u=m.group(3), acc=m.group(4), st=m.group(5), ct=m.group(6), hn=m.group(7), hd=m.group(8), fr=m.group(9),
                        b=int(m.group(10)), md5=m.group(11), type=m.group(12), title=m.group(13), inst=m.group(14), det=m.group(15)))
    return out


ROW = re.compile(r"^  (\S+) \| (\S+) (\d{3}) (\S+) (\S+) count=(\d+)$", re.M)


def rows(t, lab):
    return [(m.group(2), m.group(3), m.group(4), m.group(5), int(m.group(6))) for m in ROW.finditer(t) if m.group(1) == lab]


def c_advisory(t):
    fa = grab(t, r"^  fetched-at (\S+) ")
    us = grab(t, r"USTART (\S+) \(")
    ok(fa is not None and fa == us, "the read's day %s = the start day %s (C10)" % (fa, us))
    rd = grab(t, r"^  ~ run date (\S+)")
    if rd and us:
        import datetime
        d0 = datetime.date.fromisoformat(us); d1 = datetime.date.fromisoformat(rd)
        ok(0 <= (d1 - d0).days <= 1, "the run date %s is the start day or the next (the day rule)" % rd)
    m = re.search(r"MD5SUMS\.txt: (\d+) lines, (\d+) verified", t)
    ok(m is not None and m.group(1) == m.group(2) and int(m.group(1)) >= 10, "every MD5SUMS line verified (%r)" % (m.groups() if m else None,))
    ok(grab(t, r"tomcat page md5 (\w+)") == "a1a756d985225fb5143eefd9aae3183c", "the Tomcat page = the earlier reads byte for byte")
    ok(re.search(r"osv \(second witness only\): \d+ coordinates queried, \d+ results, 1 with vulns: io\.opentelemetry:opentelemetry-api 1\.62\.0 GHSA-ccrj-gw8r-854m", t) is not None, "OSV: the one hit named (opentelemetry-api 1.62.0)")
    ok(grab(t, r"name W3CTraceContextPropagator \(the method the advisory names\): (\d+) of") == "0", "no other jar names the advisory's class: no caller on the tree")
    for r in ("rfc8594", "rfc9745", "rfc8288", "rfc5829"): ok(re.search(r"rfc \| %s\.txt \d+ B md5 \w{32}" % r, t) is not None, "%s filed and md5'd" % r)
    ok(re.search(r"the successor-version row 1 ", t) is not None, "the IANA registry holds successor-version")
    m = re.search(r"BOOT-INF/lib names (\d+) on before = (\d+) on after", t)
    ok(m is not None and m.group(1) == m.group(2) == "167", "BOOT-INF/lib 167 = 167")
    ok(re.search(r"verdict \(VERDICT\.txt's Verdict line, read\): Verdict: no pin U24 moves is affected; evidence may proceed", t) is not None, "the verdict read: evidence may proceed")
    for a, v in (("spring-boot", "4.1.3"), ("spring-web", "7.0.11"), ("tomcat-embed-core", "11.0.29"), ("micrometer-core", "1.17.3")):
        ok(re.search(r"shipped \| %s %s$" % (a, re.escape(v)), t, re.M) is not None, "shipped %s %s" % (a, v))
    finish("read=%s osv_hits=1 rfcs=4" % fa)


def c_before(t):
    ok(re.search(r"readlink before: \.\./c9-unit23/after · readlink \.\./c9-unit23/after: \.\./c9-unit22/after · the tree 128 b8956a6e6fc128d08dab3d9885a0c431", t) is not None, "before: the two hops and the tree pin (128, b8956a6e)")
    lib = grab(t, r"BOOT-INF/lib names (\d+)"); ok(lib == "167", "BOOT-INF/lib %s (U23: 167)" % lib)
    ok(re.search(r"OPERATIONS 21 PATHS 19 · 36164 B md5 aa8cb98f4ff16d75d073026f0c618328", t) is not None, "the committed spec: 21 operations, 19 paths, 36,164 B, aa8cb98f")
    m = re.search(r"census before \| controllers (\d+) · final, default-run (\d+) · not final, default-run (\d+) · not final, dev-only (\d+)", t)
    cen = "/".join(m.groups()) if m else None
    ok(cen == "17/11/1/5", "the census %s (U23: 17/11/1/5)" % cen)
    w = grab(t, r"before \| tiffinbox-web \| tests (\d+) failures 0 errors 0 skipped 0"); c = grab(t, r"before \| tiffinbox-client \| tests (\d+) failures 0 errors 0 skipped 0")
    ok(w == "88" and c == "5", "tests on before: web %s client %s (U23: 88 / 5)" % (w, c))
    it = grab(t, r"the IT classes \(\*IT\.java, by source, every module\): (\d+)"); ok(it == "5", "the IT classes by source: %s (the 14 IT methods are verify's count, run 1)" % it)
    finish("web=%s client=%s it_classes=%s lib=%s spec=36164 census=%s" % (w, c, it, lib, cen))


def c_census(t):
    v = {}
    for side in ("before", "after"):
        m = re.search(r"census %s \| controllers (\d+) · final, default-run (\d+) · not final, default-run (\d+) · not final, dev-only (\d+) · names (.*)$" % side, t, re.M)
        v[side] = m.groups() if m else None
    ok(v["before"] is not None and v["before"] == v["after"] and "/".join(v["before"][:4]) == "17/11/1/5", "the census before = after = 17/11/1/5, the same names")
    ok("plant | the counter on an empty source folder: exit 1" in t, "the counter refuses an empty input")
    finish("census=%s" % ("/".join(v["before"][:4]) if v["before"] else None))


def c_count(t):
    rs = rows(t, "count")
    old = {r[1]: r[4] for r in rs if r[3] == "/customers/{name}"}
    succ = {r[1]: r[4] for r in rs if r[3] == "/api/v1/customers/{name}"}
    sent = [r for r in reqs(t)]
    want = {}
    for r in sent:
        if re.match(r"^/customers/[^/]+$", r["u"]): want[r["st"]] = want.get(r["st"], 0) + 1
    ok(old == want == {"200": 3, "404": 1}, "the old route's rows %s = the requests sent %s = 200 ×3, 404 ×1" % (old, want))
    ok(succ == {"200": 2}, "the successor's row %s = 200 ×2" % succ)
    acc = dict(((m.group(1), m.group(2), m.group(3)), int(m.group(4))) for m in re.finditer(r"^  access count \| (\S+) (\S+) (\d{3}) ×(\d+)$", t, re.M))
    a_old = {}
    for (m_, u, s), n in acc.items():
        if re.match(r"^/customers/[^/]+$", u) and not u.startswith("/actuator"): a_old[s] = a_old.get(s, 0) + n
    ok(a_old == old, "the access log's old-route lines %s = the scrape's rows (the second witness)" % a_old)
    ok(not re.search(r"_(sum|max|bucket)\{", t), "no _sum, _max or bucket line printed (R.552)")
    ok(not [r for r in rs if r[3].startswith("/actuator")], "the actuator's own rows left out of the count")
    ok(grab(t, r"calls of GET /customers/\{name\} inside src/main: (\d+)") == "0", "no call of the old route inside src/main")
    ok(sent and sent[0]["md5"] == SUCC and sent[4]["md5"] == SUCC, "the old 200 and the successor's 200 carry the same 67 bytes on before")
    budget(t)
    finish("old_200=%s old_404=%s succ_200=%s calls_in_main=0 u23_old=%s" % (old.get("200"), old.get("404"), succ.get("200"), grab(t, r"old=(\d+)")))


def c_announce(t):
    rq = reqs(t)
    r1 = rq[0] if rq else {}
    ok(r1.get("st") == "200" and r1.get("ct") == "application/json", "the timeline's first step: GET /customers/Ravi 200 application/json")
    hd = r1.get("hd", "")
    ok("deprecation='@<epoch>'" in hd and "sunset='<date>'" in hd and "link='</api/v1/customers/Ravi>; rel=\"successor-version\"'" in hd, "the three headers present (the dates masked), the Link names the successor")
    ok(re.search(r"Deprecation: @<epoch> Sunset: <date> Link: </api/v1/customers/Ravi>; rel=\"successor-version\"|Deprecation: @<epoch>.*Sunset: <date>.*Link: </api/v1/customers/Ravi>", t) is not None, "the headers read back by curl, masked")
    ok("body = the successor's body on the same JVM, byte for byte: yes (67 B)" in t, "the body = the successor's 67 bytes")
    ok(re.search(r"Deprecation before Sunset: ok$", t, re.M) is not None, "the dates in order by epoch, converted in python (R.557)")
    ok(re.search(r"Deprecation as epoch \(python, off the @ form\): epoch <n> · Sunset as epoch \(python calendar.timegm of the HTTP date\): epoch <n>", t) is not None, "both epochs converted, masked in the filed text")
    old = {r[1]: r[4] for r in rows(t, "announce") if r[3] == "/customers/{name}"}
    ok(old == {"200": 2, "404": 1}, "the scrape's old-route rows on this JVM %s = the requests sent (200 ×2, 404 ×1)" % old)
    ok("timeline's first step" in t, "labelled the timeline's first step")
    budget(t)
    finish("status=200 headers=Deprecation,Sunset,Link dates=ok body=67")


def c_remove(t):
    rq = reqs(t)
    ok(len(rq) == 3 and rq[0]["st"] == "404" and rq[1]["st"] == "404" and rq[2]["st"] == "200", "the harness's copy: Ravi 404, a typo 404, the successor 200")
    ok(rq and rq[0]["det"] == "No static resource customers/Ravi." and rq[1]["det"] == "No static resource customers/typo-xyz.", "the two details: No static resource customers/<name>.")
    ok("differ only in the name: yes" in t, "an old client cannot tell gone from typo: the two answers differ only in the name")
    ok(rq and rq[0]["type"] == "-" and rq[0]["ct"] == "application/problem+json", "no type of TiffinBox's (about:blank, Spring's own)")
    uri = sorted(set(r[3] for r in rows(t, "remove") if r[1] == "404"))
    ok(uri == ["/**"], "the two 404s counted under %s (no route: the catch-all pattern)" % uri)
    ok("harness's copy" in t, "labelled the harness's copy")
    budget(t)
    finish("status=404 detail=No static resource customers/Ravi. typo=same_but_name")


OLDCLASS = re.compile(r"^(GET|HEAD) /customers/[^/]+$")


def c_compat(t):
    sv = re.search(r"seven \| before (\w+) · after (\w+) · expected (\w+)", t)
    ok(sv is not None and sv.group(1) == sv.group(2) == sv.group(3), "the seven before = after = 466c20ed (not a witness for the retirement)")
    sur = re.findall(r"^  surface \| (.+?)\s+(\d{3}) -> (\d{3}) · (unmoved|MOVED)$", t, re.M)
    ok(len(sur) == 13, "the old surface: %d requests (12 handler methods + /nowhere)" % len(sur))
    mv = [(a.strip(), b, c) for a, b, c, d in sur if d == "MOVED"]
    for lab, b, c in mv:
        q = re.sub(r" \(.*\)$", "", lab)
        if not OLDCLASS.match(q): ok(False, "HOLD the old surface's line moved outside the retired route's requests: %s %s -> %s" % (lab, b, c)); OUT[-1] = OUT[-1].replace("FAIL ", "FAIL HOLD ", 1)
    ok([x[0] for x in mv] == ["GET /customers/Ravi"] and mv[0][1:] == ("200", "410"), "the old surface's moved line: exactly one, GET /customers/Ravi 200 -> 410 (%s)" % mv)
    ok(re.search(r"surface \| before 316a96370fe5c34f58fc6ecca8e9557b ", t) is not None, "the old surface on before = 316a9637 (U23's)")
    ok(re.search(r"census .*/api/v1/ paths\): before -> after identical \((\d+) requests each\)", t) is not None, "the /api/v1/ census identical")
    reach = re.findall(r"^  reach \| (\S+ \S+(?: Accept=\S+)?)\n  reach \|   before: (.*)\n  reach \|   after:  (.*)\n  reach \|   (unmoved|MOVED)$", t, re.M)
    ok(len(reach) == 14, "the reach: %d requests on both trees" % len(reach))
    moved = []
    for q, b, a, m in reach:
        bare = q.split(" Accept=")[0]
        if m == "MOVED":
            moved.append(q)
            if not OLDCLASS.match(bare):
                ok(False, "HOLD a reach line moved outside the retired route's requests: %s" % q); OUT[-1] = OUT[-1].replace("FAIL ", "FAIL HOLD ", 1)
            else:
                ok(a.startswith("410 application/problem+json") or (bare.startswith("HEAD") and a.startswith("410 ")), "%s -> 410 on after" % q)
        else:
            ok(not OLDCLASS.match(bare) or "text/html" in q, "%s unmoved (%s)" % (q, "outside the template" if not OLDCLASS.match(bare) else "the page mapping"))
    succ = [x for x in reach if x[0].startswith("GET /api/v1/customers/Ravi")]
    ok(succ and succ[0][3] == "unmoved" and SUCC in succ[0][1], "the successor unmoved, its 67 bytes")
    for q, b, a, m in reach:
        if q.startswith("GET /customers/Meera%20Joshi"): ok("link='</api/v1/customers/Meera%20Joshi>; rel=\"successor-version\"'" in a, "names: a space -> %20 in the Link")
        if q.startswith("GET /customers/a%3Eb"): ok("link='</api/v1/customers/a%3Eb>; rel=\"successor-version\"'" in a, "names: > -> %3E in the Link")
        if q.startswith("GET /customers/x%0D%0Ay"): ok("link='</api/v1/customers/x%0D%0Ay>; rel=\"successor-version\"'" in a and a.startswith("410 "), "names: an encoded CR LF stays %0D%0A in the Link, status 410")
    c5 = re.findall(r"^  cap5 (before|after) \| \d+ (\S+) (\S+) -> (\d{3})", t, re.M)
    ca = [x for x in c5 if x[0] == "after"]; cb = [x for x in c5 if x[0] == "before"]
    ok(ca and ca[-1][2] == "/customers/Ravi" and ca[-1][3] == "410" and ca[-2][3] == "429", "cap=5: after the address's refusal (429) the old route answers 410, never 429")
    ok(cb and cb[-1][3] == "200" and cb[-2][3] == "429", "cap=5 on before: after the refusal the old route answered 200")
    ok(grab(t, r"the 410 carries an ETag \(U20's filter is /api/v1/ only\): (\d+)") == "0", "U20's filter adds no ETag to the 410")
    budget(t)
    hold = any(l.startswith("FAIL HOLD") for l in OUT)
    finish("moved_surface=%d(%s) moved_reach=%d seven=equal api=identical hold=%s" % (len(mv), ";".join(x[0] for x in mv), len(moved), "yes" if hold else "no"))


def c_gone(t):
    rq = reqs(t)
    ok(len(rq) == 7, "seven requests to after")
    g = rq[0] if rq else {}
    ok(g.get("st") == "410" and g.get("ct") == "application/problem+json" and g.get("type") == TYPE and g.get("title") == "Route retired", "GET /customers/Ravi -> 410 application/problem+json, type route-retired, title Route retired")
    ok("link='</api/v1/customers/Ravi>; rel=\"successor-version\"'" in g.get("hd", ""), "the Link names the successor for Ravi")
    ok("deprecation" not in g.get("hd", "") and "sunset" not in g.get("hd", ""), "no Deprecation, no Sunset on the 410 (C1 (a))")
    ok(len(rq) > 1 and rq[1]["m"] == "HEAD" and rq[1]["st"] == "410" and rq[1]["b"] == 0, "HEAD -> 410, no body")
    ok(len(rq) > 2 and rq[2]["st"] == "410" and rq[2]["det"] == g.get("det"), "a name nobody has: the same 410 (the route no longer says no such customer)")
    ok(len(rq) > 4 and rq[4]["u"] == "/api/v1/customers/Ravi" and rq[4]["st"] == "200" and rq[4]["md5"] == SUCC and rq[4]["b"] == 67, "the successor: 200, the same 67 bytes")
    ok("type = the constant ROUTE_RETIRED (read off after's TiffinBoxErrors.java): yes" in t, "the type = the constant")
    ok("Deprecation present: no · Sunset present: no" in t, "curl reads no date header either")
    old = {}
    for r_ in rows(t, "gone"):
        if r_[3] == "/customers/{name}": old[r_[1]] = old.get(r_[1], 0) + r_[4]
    want = sum(1 for r in rq if re.match(r"^/customers/[^/]+$", r["u"])) + 1
    ok(old == {"410": want}, "the 410 counted under uri=/customers/{name}: %s (sent %d - a handler's 410 keeps its template)" % (old, want))
    ok(not [r for r in rows(t, "gone") if r[3] == "/customers/{name}" and r[2] != "CLIENT_ERROR"], "outcome CLIENT_ERROR")
    ok(re.search(r"U12 \| .*Invalid API version", t) is not None, "U12 called back on its own tree's line")
    budget(t)
    finish("status=410 type=route-retired link=successor counted_410=%s head=410 successor=200/67" % old.get("410"))


def c_tests(t):
    red = re.findall(r"^  need \| red (\S+)$", t, re.M)
    m = re.search(r"need \| red (\d+) in (\d+) classes", t)
    ok(m is not None and int(m.group(1)) == len(red), "the need-measure's red list printed whole (%r)" % (m.groups() if m else None,))
    ok(sorted(red) == sorted(EDITED + [SPECRED]), "red = the table's %d edited methods + OpenApiSpecTest (a red method not in the table, or a table method not red: %s)" % (len(EDITED), sorted(set(red) ^ set(EDITED + [SPECRED]))))
    ed = re.findall(r"^  edited \| (\S+\.\S+)$", t, re.M); ad = re.findall(r"^  added  \| (\S+)$", t, re.M)
    ok(sorted(ed) == sorted(EDITED), "the methods edited before -> after = the table (%s)" % sorted(set(ed) ^ set(EDITED)))
    ok(sorted(ad) == sorted("RetiredRouteTest." + x for x in ("theOldAddressAnswersGoneWithItsType", "itsLinkNamesTheSuccessorForTheNameAsked", "itCarriesNoOtherHeader", "headAnswersTheSameStatus", "theSuccessorStillAnswers")), "added: RetiredRouteTest's five methods")
    w = grab(t, r"package \| tiffinbox-web \| tests (\d+) failures 0 errors 0 skipped 0$"); c = grab(t, r"package \| tiffinbox-client \| tests (\d+) failures 0 errors 0 skipped 0$")
    ok(w is not None and int(w) == 88 + len(ad) and c == "5", "after: web %s (88 + %d) client %s, failures 0, skipped 0" % (w, len(ad), c))
    rr = grab(t, r"class RetiredRouteTest \| tests (\d+) failures 0 errors 0 skipped 0"); ok(rr == "5", "RetiredRouteTest 5 / 0 / 0 / 0 skipped")
    ih = grab(t, r"package \| tiffinbox-web \| class InputHardeningTest \| tests (\d+) failures 0"); ok(ih == "3", "InputHardeningTest 3, untouched and green")
    ok(len(re.findall(r"^  reactor: TiffinBox[A-Za-z ]* \.\.\. SUCCESS$", t, re.M)) == 4, "four SUCCESS lines (the whole reactor)")
    ok(grab(t, r"outside RateLimitFilterTest \(its own context refuses by design\): (\d+)") == "0", "0 refusal lines at the default capacity (R.555)")
    ok(re.search(r"RetiredRouteTest: @Test lines 5 · disabling annotations 0 · ports, sockets, sleeps or 4-5 digit literals \(strings removed\) 0 · header-name literals \(\"Link\", \"Deprecation\", \"Sunset\", \"Content-Type\"\) 0", t) is not None, "the new test: 5 @Test, no port, no 4-5 digit literal, no header-name literal")
    pr = re.findall(r"^  plant \| red (\S+)$", t, re.M)
    ok("plant | mvn exit 0" not in t and len(pr) >= 3 and all(x.startswith("RetiredRouteTest.") for x in pr), "the handler removed: RetiredRouteTest red (%s)" % pr)
    ok("RetiredRouteTest.theSuccessorStillAnswers" not in pr, "the successor's method stays green without the handler")
    ok(grab(t, r"downloads across the builds: (\d+)") == "0", "Downloading from: 0")
    vf = re.search(r"~ verify exit (\d+) · ITs tests (\d+) failures (\d+) errors (\d+) · classes (\d+)", t)
    if vf: ok(vf.groups() == ("0", "14", "0", "0", "5"), "verify: exit 0, the ITs 14 / 0 / 0 in 5 classes")
    finish("red=%d classes=%d web=88->%s client=%s refusals=0 plant_red=%d" % (len(red), len(set(x.split(".")[0] for x in red)), w, c, len(pr)))


def c_spec(t):
    ok(re.search(r"after's committed file 35935 B md5 \w+ · equal byte for byte: yes", t) is not None or re.search(r"equal byte for byte: yes", t) is not None, "the served document = the regenerated committed file, byte for byte")
    b = grab(t, r"after's committed file (\d+) B")
    ok(re.search(r"before's committed file 36164 B md5 aa8cb98f4ff16d75d073026f0c618328", t) is not None, "before's file 36,164 B aa8cb98f")
    ok(re.search(r"operations before 21 after 21 · paths before 19 after 19 · operationIds equal as a set: yes", t) is not None, "21 operations, 19 paths, the operationIds kept")
    mv = grab(t, r"operations that moved: (\d+) ")
    ok(mv == "1" and "GET /customers/{name} operationId customer" in t, "R.535: ONE operation moved, named: GET /customers/{name} (customer)")
    ok("byte-equal (as JSON): 20 of 21" in t, "20 of 21 operations byte-equal")
    ok("components equal: yes · info equal: yes" in t, "components and info unmoved")
    ok(re.search(r"GET /customers/\{name\} before: responses 200,404 · deprecated absent", t) is not None and re.search(r"GET /customers/\{name\} after:  responses 410 · deprecated True", t) is not None, "the entry: 200,404 -> 410 + deprecated")
    ok("wire | status 410 · the entry's response keys 410 · documented: yes" in t, "spec vs wire: the status documented (R.528)")
    ok(re.search(r"wire \| Content-Type application/problem\+json · the entry's media types application/problem\+json · equal: yes · schema #/components/schemas/ProblemDetail", t) is not None, "spec vs wire: the media type and the schema")
    ok("the answer this route sent for Ravi with its instance set to /customers/Nobody: yes" in t, "spec vs wire: the example = the answer")
    ok("ops9s3.py on an empty spec: exit 1" in t or re.search(r"empty spec: exit [1-9]", t) is not None, "ops9s3.py refuses an empty spec")
    finish("ops=21 moved=1(customer) bytes=36164->%s" % b)


def c_client(t):
    ok(re.search(r"on before's spec: mvn -o clean package -pl tiffinbox-client -am exit 0", t) is not None, "the client builds on before's spec")
    for s in ("before's", "after's"):
        ok(re.search(r"client on %s spec \| tests 5 failures 0 errors 0 skipped 0" % s, t) is not None, "the client's 5 tests green on %s spec" % s)
    cb = grab(t, r"client \| cspec: CustomersApi\.customer: (.*?) · @Deprecated"); ca = grab(t, r"client \| after: CustomersApi\.customer: (.*?) · @Deprecated")
    ok(cb is not None and cb.startswith("ResponseEntity<Customer> customer("), "before's spec: %s" % cb)
    ok(ca is not None and ca.startswith("ResponseEntity<Void> customer("), "after's spec: %s (the method kept, its return type changed)" % ca)
    n = grab(t, r"naming /customers/\{name\} or customer\(: (\d+) ·"); c = grab(t, r"planted control line: (\d+) \(R\.566\)")
    ok(n == "0" and c == "1", "the client's tests name neither the old path nor customer( (%s; the control counted %s)" % (n, c))
    dep = grab(t, r"client \| after: CustomersApi\.customer: .*? · @Deprecated on it: (\d+)")
    finish("before_spec=green after_spec=green customer=Customer->Void deprecated_mark=%s" % dep)


def c_api(t):
    ok(re.search(r"api \| before -> after: identical \(11 requests each\)", t) is not None, "the /api/v1/ census: 11 requests, identical (U23: api=11 identical)")
    finish("api=11 identical")


def c_seven(t):
    m = re.search(r"expected (\w{32})\n  before: the seven (\w{32}) \((\d+) lines\) · after: the seven (\w{32})", t)
    ok(m is not None and m.group(1) == m.group(2) == m.group(4), "the seven on before = after = the expected md5")
    finish("seven=%s" % (m.group(2)[:8] if m else None))


def c_surface(t):
    m = re.search(r"expected on before (\w{32})\n  before: the old surface (\w{32}) \((\d+) requests\) · after: (\w{32}) \((\d+) requests\)", t)
    ok(m is not None and m.group(1) == m.group(2), "the old surface on before = 316a9637")
    ok(m is not None and m.group(4) != m.group(2) and m.group(3) == m.group(5) == "13", "on after it moved; 13 requests each")
    bl = re.findall(r"^  (before|after) +\| == (.*?) -> ", t, re.M)
    ok([x[1] for x in bl] == ["GET /customers/Ravi", "GET /customers/Ravi"], "the moved block is GET /customers/Ravi's alone")
    ok("after  | body: " in t and TYPE in t, "the moved block's body: the route-retired problem")
    finish("surface=%s after=%s moved=1" % (m.group(2)[:8] if m else None, m.group(4)[:8] if m else None))


def c_moved(t):
    w = re.search(r"moved \| the web jar: entries (\d+) -> (\d+) · added (\d+) · removed (\d+) · moved (\d+) \(([^)]*)\)", t)
    ok(w is not None and w.group(3) == "0" and w.group(4) == "0", "the web jar: 0 added, 0 removed")
    ok(w is not None and sorted(w.group(6).split(", ")) == ["CustomerNotFound.class", "CustomerReads.class", "TiffinBoxErrors.class", "TiffinBoxServer.class"], "the web jar's moved entries: the four classes of the four edited sources (%s)" % (w.group(6) if w else None))
    ok(re.search(r"moved \| the core jar: entries \d+ -> \d+ · added 0 · removed 0 · moved 0$", t, re.M) is not None, "the core jar: 0 moved")
    cl = re.search(r"moved \| the client jar: entries (\d+) -> (\d+) · added (\d+) · removed (\d+) · moved (\d+)", t)
    ok(cl is not None and cl.group(3) == "0" and cl.group(4) == "0", "the client jar: 0 added, 0 removed")
    ok(re.search(r"BOOT-INF/lib names before 167 after 167 · added 0 · removed 0", t) is not None, "BOOT-INF/lib 167 = 167, 0 added, 0 removed")
    finish("web_moved=%s client_moved=%s lib=167=167" % (w.group(5) if w else None, cl.group(5) if cl else None))


def c_inert(t):
    ok("this receipt's sender sets no Idempotency-Key and sends no body: yes" in t, "no keyed request, no body")
    ok(re.search(r"name no Idempotency-Key: 0 · 0", t) is not None, "the seven and the old surface name no key")
    finish("keyed=0")


def c_change(t):
    ch = re.findall(r"^  change \| ([AMD]) (\S+)$", t, re.M)
    ok({p for _, p in ch} == CHANGED, "the derived changed list = the change's %d paths" % len(CHANGED))
    ok([p for a, p in ch if a == "A"] == ["tiffinbox-web/src/test/java/com/tiffinbox/web/RetiredRouteTest.java"] and not [p for a, p in ch if a == "D"], "one path added (RetiredRouteTest.java), none removed")
    ok(re.search(r"poms moved 0 · core or client sources moved 0 · application\*\.yaml moved 0", t) is not None, "no pom, no core or client source, no yaml")
    ok(re.search(r"modules before tiffinbox-core tiffinbox-web tiffinbox-client · after tiffinbox-core tiffinbox-web tiffinbox-client", t) is not None, "the parent's modules three -> three")
    ok("ROUTE_RETIRED = URI.create(\"tag:tiffinbox.example,2026:route-retired\")" in t, "the constant in the diff")
    ok(re.search(r"@GetMapping\(\"/customers/\{name\}\"\) in after's sources: 1 · its method name: customer · methods named customer\( in TiffinBoxServer: 1", t) is not None, "the mapping and the method name kept, once (R.535)")
    ok(grab(t, r"probe, blue or harness named in a changed source, test or spec of after/ .*?: (\d+) · in the unit 24 card: (?:\d+)") == "0" and grab(t, r"in the unit 24 card: (\d+)") == "0", "no probe, blue or harness word in a changed source, test, spec or the unit 24 card")
    rr = dict(re.findall(r"(\./\S+)=(\d+)", grab(t, r"route-retired named, per file of after/: (.*)$") or ""))
    ok(set(rr) == {"./README.md", "./tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxErrors.java", "./tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java", "./tiffinbox-web/src/test/resources/openapi/tiffinbox.json"}, "route-retired named in the README, the constant, the handler's example and the spec only (%s)" % sorted(rr))
    ok("before -> after the same: yes" in t, "the web jar's BOOT-INF/lib names the same before and after")
    finish("paths=%d added=1 poms=0" % len(ch))


def c_stale(t):
    st = re.findall(r"^  stale \| (\S+) \| (.*?) \| ", t, re.M)
    ok(st and not [x for x in st if x[1] == "UNDISPOSED"], "every stale-word hit has a disposition (%d hits)" % len(st))
    ok("left unrewritten: no" in t, "the README's 'nothing is deprecated or retired here' is rewritten")
    finish("hits=%d undisposed=0" % len(st))


def c_frozen(t):
    ok(len(re.findall(r"^  frozen \| c9-unit1[035]/receipts\.sh:\d+: ", t, re.M)) == 3, "the three flag-31-class lines printed")
    ok("chk15.py:398-399: " in t, "chk15.py :398-:399 printed")
    ok(re.search(r"poms this unit moves \(after/ against before/\): 0 · the committed spec moved: yes", t) is not None, "no pom moved; the spec moved (F-31 named)")
    ok(grab(t, r"the end check, the git diff and the H2 sweep: (\d+)") == "0", "this unit's files: 0 reads of the live anchor outside the allowed lines")
    finish("re_run=0 poms=0 spec_moved=yes")


def c_exercise(t):
    for sh in ("bash", "zsh"):
        ok(re.search(r"^  %s \| \(1\) GET /customers/Ravi -> 200 · application/json · type none · Deprecation: <masked> Sunset: <masked>$" % sh, t, re.M) is not None, "%s: the broken copy answers 200 with the headers" % sh)
        ok(re.search(r"^  %s \| FAIL \(1\) the retired route still answers 200$" % sh, t, re.M) is not None, "%s: the broken copy's FAIL (1)" % sh)
        ok(re.search(r"^  %s \| broken: check exit 1$" % sh, t, re.M) is not None, "%s: broken exit 1" % sh)
        ok(re.search(r"^  %s \| \(1\) GET /customers/Ravi -> 410 · application/problem\+json · type route-retired$" % sh, t, re.M) is not None, "%s: the solved copy answers 410 route-retired" % sh)
        ok(re.search(r"^  %s \| solved: check exit 0$" % sh, t, re.M) is not None, "%s: solved exit 0" % sh)
        ok(len(re.findall(r"^  %s \| \(2\) GET /api/v1/customers/Ravi -> 200 · 67 B · md5 equal to after's: yes$" % sh, t, re.M)) == 2, "%s: the successor unchanged, broken and solved" % sh)
    ok("the announce copy's method (break.sh on a fresh copy of after against before + announce.diff, the method's text): yes" in t, "the broken copy's method = the announce copy's")
    vs = re.findall(r"^  ~ (\w+) bash \| check exit (\d)$", t, re.M)
    if vs: ok(len(vs) == 5 and all(x[1] == "1" for x in vs), "the five refused variants each exit 1 (%s)" % vs)
    rb = [l[len("  README: "):] for l in t.splitlines() if l.startswith("  README: ")]
    sb = [l[len("  SOLUTION: "):] for l in t.splitlines() if l.startswith("  SOLUTION: ")]
    bash = [l[len("  bash | "):] for l in t.splitlines() if l.startswith("  bash | ")]
    i = bash.index("broken: check exit 1") if "broken: check exit 1" in bash else -1
    ok(i > 0 and bash[1:i] == rb, "the README's block = the bash broken run's lines")
    j = bash.index("solved: check exit 0") if "solved: check exit 0" in bash else -1
    ok(j > i + 1 and bash[i + 2:j] == sb, "SOLUTION.md's block = the bash solved run's lines")
    finish("broken=200(FAIL 1) solved=410 shells=bash,zsh")


def c_title(t):
    n = grab(t, r'\((\d+) characters by len\(\)\)')
    ok(n is not None and int(n) <= 60, "the title for search: %s characters (<= 60)" % n)
    ok(grab(t, r"naming 410 or Deprecation in java\*_series\.py: (\d+)") == "0", "no clash in the registries")
    finish("title_len=%s" % n)


CHECKS = {"advisory": c_advisory, "before": c_before, "census": c_census, "count": c_count, "announce": c_announce, "remove": c_remove,
          "compat": c_compat, "gone": c_gone, "tests": c_tests, "spec": c_spec, "client": c_client, "api": c_api, "seven": c_seven,
          "surface": c_surface, "moved": c_moved, "inert": c_inert, "change": c_change, "stale": c_stale, "frozen": c_frozen,
          "exercise": c_exercise, "title": c_title}

PLANTS = [("advisory", r"(  fetched-at )\S+", r"\g<1>2026-11-27", "the read one day older than the start (C10)"),
          ("advisory", r"(  ~ run date )\S+", r"\g<1>2026-11-30", "a run two days after the start (the day rule)"),
          ("advisory", r"1 with vulns", "0 with vulns", "the OSV hit dropped"),
          ("before", r"(BOOT-INF/lib names )167", r"\g<1>166", "BOOT-INF/lib typed 166"),
          ("before", r"(before \| tiffinbox-web \| tests )88", r"\g<1>87", "web 88 typed 87 (R.527)"),
          ("before", r"readlink before: \.\./c9-unit23/after", "readlink before: ../c9-unit22/after", "before's link text changed (C11)"),
          ("census", r"(census after \| controllers )17", r"\g<1>18", "a controller added on after"),
          ("count", r"(  count \| GET 200 SUCCESS /customers/\{name\} count=)3", r"\g<1>4", "the old route's count one off"),
          ("count", r"(  count \| _sum, _max or bucket lines printed by this capture: 0)", "\\1\n  count | http_server_requests_seconds_sum{uri=\"/customers/{name}\"} 0.01", "a _sum line printed (R.552)"),
          ("count", r"(  count \| GET 200 SUCCESS /customers/\{name\} count=3)", "\\1\n  count | GET 200 SUCCESS /actuator/prometheus count=1", "the actuator's row left in the count"),
          ("announce", r"Deprecation before Sunset: ok", "Deprecation before Sunset: NO", "the probe's inverted pair (Sunset before Deprecation, R.557)"),
          ("announce", r"(Deprecation as epoch \(python, off the @ form\): epoch )<n>", r"\g<1>typed", "an epoch typed instead of converted"),
          ("remove", r"No static resource customers/typo-xyz\.", "No static resource customers/other.", "the typo's detail altered"),
          ("compat", r"(  surface \| GET /dashboard \(Accept: application/json\)\s+200 -> 200 · )unmoved", r"\1MOVED", "a moved line outside the retired route's class (HOLD)"),
          ("compat", r"(seven \| before )(\w{31})\w", r"\g<1>\g<2>0", "the seven's md5 off one byte"),
          ("compat", r"(  surface \| GET /customers/Ravi\s+200 -> )410 · MOVED", r"\g<1>200 · unmoved", "the surface's moved-line list one short"),
          ("compat", r"(  reach \| OPTIONS /customers/Ravi\n  reach \|   before: .*\n  reach \|   after:  .*\n  reach \|   )unmoved", r"\1MOVED", "a reach line outside the retired route's class moved (HOLD)"),
          ("gone", r"type tag:tiffinbox\.example,2026:route-retired", "type tag:tiffinbox.example,2026:route-gone", "the type altered"),
          ("gone", r"(-> 410 )application/problem\+json", r"\1application/json", "the Content-Type application/json"),
          ("gone", r"(  req \| 01 GET /customers/Ravi -> 410 \S+ · headers \{[^}]*\} · )", "\\1deprecation='@<epoch>' · ", "Deprecation present on the 410 (C1 (a))"),
          ("gone", r"link='</api/v1/customers/Ravi>; rel=\"successor-version\"'", "link='</api/v1/customers/{name}>; rel=\"successor-version\"'", "the Link a template, not the successor"),
          ("gone", r"(  req \| 05 GET /api/v1/customers/Ravi -> 200 .*? md5 )\w{12}", r"\g<1>000000000000", "the successor's body md5 off"),
          ("tests", r"(  need \| red )TiffinBoxWebTest\.aNameNobodyHasIsTyped\n", r"\1TiffinBoxWebTest.somethingElse\n", "a red method not in the table"),
          ("tests", r"  edited \| RateLimitFilterTest\.aRouteOutsideTheApiIsNeverRefused\n", "", "the table one method short"),
          ("tests", r"(package \| tiffinbox-web \| tests )(\d+)", r"\g<1>92", "a web count typed instead of printed"),
          ("tests", r"plant \| red RetiredRouteTest\.\w+", "plant | red OpenApiSpecTest.x", "the handler removed and RetiredRouteTest green"),
          ("spec", r"operations that moved: 1 \(GET /customers/\{name\} operationId customer\)", "operations that moved: 2 (GET /customers/{name} operationId customer; GET /customers operationId customers)", "a second moved operation (R.535)"),
          ("spec", r"set to /customers/Nobody: yes", "set to /customers/Nobody: NO", "the 410's example altered (R.528)"),
          ("spec", r"equal byte for byte: yes", "equal byte for byte: NO", "the old spec restored (OpenApiSpecTest red)"),
          ("client", r"(naming /customers/\{name\} or customer\(: )0", r"\g<1>1", "a client test naming the old route"),
          ("client", r"(planted control line: )1", r"\g<1>0", "the grep's planted control not counted (R.566)"),
          ("moved", r"(BOOT-INF/lib names before 167 after )167", r"\g<1>168", "a jar added"),
          ("change", r"(in the unit 24 card: )0", r"\g<1>1", "a probe word in the shipped card"),
          ("stale", r"left unrewritten: no", "left unrewritten: YES", "the README's 'nothing is deprecated or retired here' left"),
          ("frozen", r"(poms this unit moves \(after/ against before/\): )0", r"\g<1>1", "a pom moved (a restored die on a changed path)"),
          ("exercise", r"(  bash \| )solved: check exit 0", r"\1solved: check exit 1", "the solution failing"),
          ("exercise", r"(  zsh \| )broken: check exit 1", r"\1broken: check exit 0", "the broken copy passing"),
          ("title", r"\((\d+) characters by len\(\)\)", "(61 characters by len())", "a title over 60"),
          ("compat", r"(  budget \| compat-after: requests under /api/v1/ \(its access log\): )\d+", r"\g<1>61", "a per-JVM request count above the cap"),
          ("gone", r"(  budget \| gone: requests under /api/v1/ \(its access log\): \d+ · refusal lines: )0", r"\g<1>1", "a refusal line in a default-capacity JVM")]


def plants(d):
    n = 0
    for nm, rx, rep, what in PLANTS:
        p = os.path.join(d, ".r-%s.new" % nm)
        if not os.path.exists(p): ok(False, "plant %s: no capture %s" % (what, p)); continue
        t = open(p, encoding="utf-8").read(); t2 = re.sub(rx, rep, t, count=1)
        if t2 == t: ok(False, "plant %s: the pattern did not apply" % what); continue
        r = subprocess.run([sys.executable, "-I", "-B", __file__, nm, "-"], input=t2, capture_output=True, text=True)
        f = [l for l in r.stdout.splitlines() if l.startswith("FAIL")]
        ok(r.returncode == 1 and f and "Traceback" not in r.stderr, "plant (%s) %s: caught - %s" % (nm, what, f[0][5:90] if f else "NOT CAUGHT"))
        if "(HOLD)" in what: ok(any(x.startswith("FAIL HOLD") for x in f), "plant (%s) %s: the HOLD line fires" % (nm, what))
        n += 1
    for nm, line in (("count", "  req | garbage\n"), ("compat", "  reach | garbage\n"), ("tests", "  package | garbage\n"), ("gone", "  req | 01 garbage\n")):
        r = subprocess.run([sys.executable, "-I", "-B", __file__, nm, "-"], input=line, capture_output=True, text=True)
        ok(r.returncode == 1 and "Traceback" not in r.stderr, "plant an unparseable %s listing: a FAIL line, exit 1, no traceback" % nm); n += 1
    # the hook one word changed, the exercise one byte changed, a typed USTART: the gates the receipt runs, on scratch copies
    rs = open(os.path.join(d, "receipts.sh"), encoding="utf-8").read()
    pl = os.path.join(d, ".harness", "work", "static-plant")
    os.makedirs(pl, exist_ok=True)
    rd = open(os.path.join(d, "README.md"), encoding="utf-8").read()
    h = hook(); ok(h in rd and h.replace("six", "seven") not in rd, "plant the hook one word changed: the byte-equal check no longer finds it"); n += 1
    e = exq(); ok(("**Your turn:** " + e[len("Your turn: "):]) in open(os.path.join(d, "exercise/README.md"), encoding="utf-8").read() and len(e.split()) == 21, "plant the exercise: 21 words with 'Your turn:'; one byte changed is not byte-equal; 26 typed as <= 25 refused by the count"); n += 1
    gl = rd.splitlines(); ok(gl.count(GLOSS) == 1 and (gl + [GLOSS]).count(GLOSS) == 2, "plant a second gloss line: counted 2, refused"); n += 1
    ok(not re.search(r"^\s*USTART=['\"]?20\d\d-", rs, re.M) and re.search(r"^\s*USTART=['\"]?20\d\d-", rs + "\nUSTART=2026-11-28\n", re.M), "plant a typed USTART constant: the static check's pattern finds it"); n += 1
    for l in OUT: print(l)
    print("VALUES plants=%d" % n)
    sys.exit(1 if any(l.startswith("FAIL") for l in OUT) else 0)


def main():
    a = sys.argv[1:]
    cmd = a[0] if a else ""
    if cmd == "static":
        static(a[1], a[2])
    elif cmd == "static-plant":
        sys.addaudithook(_guard)
        if a[1] == "live": open("../c9-" + "tiffinbox/pom.xml").read()   # LIVE_ANCHOR_PLANT
        else: open(os.path.join("..", "c9-" + "tiff" + "inbox", "pom.xml")).read()   # LIVE_ANCHOR_PLANT (two pieces)
        sys.exit(0)
    elif cmd == "gloss":
        r = open(a[1], encoding="utf-8").read().splitlines()
        for g in GLOSSES:
            ok(not any(l.startswith(g) for l in r), "no second gloss line (%s)" % g)
        ok(sum(1 for l in r if l.startswith("A sunset")) == 1 and GLOSS in r, "exactly one gloss line, A sunset date:, byte for byte (%d words)" % len(GLOSS.split()))
        print("GLOSS %s (%d words; the brief's parenthetical: (the date an endpoint stops answering))" % (GLOSS, len(GLOSS.split())))
        for u in list(range(13, 21)) + [22, 23]:
            f = "../c9-unit%02d/harness/chk%02d.py" % (u, u)
            gl = re.search(r'^GLOSS = "(.*)"$', open(f, encoding="utf-8").read(), re.M)
            rd = open("../c9-unit%02d/README.md" % u, encoding="utf-8").read().splitlines()
            ok(gl is not None and gl.group(1).replace('\\"', '"') in rd, "U%02d's gloss line byte-equal in its own README" % u)
        finish(None)
    elif cmd == "hook":
        print(hook())
    elif cmd == "exq":
        print(exq())
    elif cmd == "title-line":
        print(title())
    elif cmd == "interleaved":
        b = brief(); hs = re.findall(r'^\*\*Hook \(\[S4 §\d+\]\):\*\* "([^"]+)"', b, re.M); es = re.findall(r'^\*\*Exercise:\*\* "(Your turn: [^"]+)"', b, re.M)
        if len(hs) != 6 or len(es) != 6: print("the extractor found %d hooks and %d exercises, not 6 + 6" % (len(hs), len(es))); sys.exit(1)
        il = "\n".join(x for p in zip(hs, es) for x in p) + "\n"
        print("the brief's hooks and exercises: %d + %d (R.534), the interleaved list's md5 %s" % (len(hs), len(es), md5(il.encode())))
    elif cmd == "hashable":
        t = open(a[2], encoding="utf-8").read().splitlines()
        sys.stdout.write("".join(l + "\n" for l in t if not l.startswith("  ~")))
    elif cmd == "values":
        r = open(a[1], encoding="utf-8").read()
        m = re.search(r"<!-- values: begin -->\n(.*?)<!-- values: end -->", r, re.S)
        got = "\n".join(l for l in (m.group(1) if m else "").splitlines() if l.strip() and l.strip() != "```")
        want = a[2].strip()
        if got != want:
            print("the README's values block differs from this run's:")
            for x, y in zip(got.splitlines() + [""] * 40, want.splitlines()):
                if x != y: print("  README: " + x); print("  run:    " + y)
            sys.exit(1)
        print("the README's values block = this run's (%d lines)" % len(want.splitlines()))
    elif cmd == "plants":
        plants(a[1])
    elif cmd in CHECKS:
        t = sys.stdin.read() if a[1] == "-" else open(a[1], encoding="utf-8").read()
        try:
            CHECKS[cmd](t)
        except SystemExit:
            raise
        except Exception as e:
            print("FAIL %s: the capture could not be parsed (%s: %s)" % (cmd, type(e).__name__, e)); sys.exit(1)
    else:
        print("FAIL unknown subcommand %r" % cmd); sys.exit(1)


main()
