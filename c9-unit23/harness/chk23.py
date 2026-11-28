"""Course 9 unit 23's checks (python3 -I -B harness/chk23.py SUBCOMMAND ...), run from c9-unit23/ (unit 22's chk22.py's machinery).

Each capture's check reads the masked capture file the receipt wrote (.r-NAME.new) and prints "ok ..." or "FAIL ..." lines and one
"VALUES ..." line; any FAIL exits 1 (a line it cannot parse is a FAIL line, exit 1, never a traceback). `static` reads only this unit's
folder, the tree behind its two links (../c9-unit22/after) and git objects of unit 22's commit (d7e0663) - never the live anchor: an
audit hook refuses any open() whose real path lies in the live anchor's folder, so a static read of it exits 1 (flag 19).
Subcommands: static AFTER BEFORE · static-plant live|pieces · gloss README · hook · exq · title-line · interleaved · hashable NAME FILE ·
values README VALS · plants DIR · and one per capture: advisory before pin census spec scrape tags known 404 unknown filters errors
duration api seven surface inert tests harness exercise title.
"""
import hashlib, os, re, subprocess, sys

ANCHOR_DIR = "/c9-" + "tiffinbox"   # LIVE_ANCHOR_PLANT: the live anchor's folder name, assembled so a grep for it finds only this line


def _guard(event, args):
    if event == "open" and args and isinstance(args[0], (str, bytes, os.PathLike)):
        p = os.path.realpath(os.fsdecode(args[0]))
        if (ANCHOR_DIR + "/") in p or p.endswith(ANCHOR_DIR):
            raise SystemExit("FAIL flag 19: a static check read the live anchor (%s)" % p)


H22 = "d7e0663"
LEFT_OUT = ["change", "drop", "bind", "bindblock", "record", "strict", "key", "block", "reach", "limits", "named", "moved", "dev", "factory",
            "timeout", "retry", "mock", "shallow", "paths", "weak", "deep", "ifmatch", "cache", "chrome", "forge", "xff", "refill", "twojvm",
            "lua", "starter", "cost", "literal", "final", "placeholder", "walk", "pageable", "trap", "table", "first", "next"]
GLOSSES = ["A precondition:", "A token bucket:", "A cursor:", "A sparse fieldset:", "A link relation:", "`HAL`:", "A status resource:",
           "A presigned URL:", "A version carrier:", "A snippet:", "A contract:", "Swagger UI:", "A problem type:", "Code generation:",
           "A read timeout:", "A retry:", "An ETag:", "A validator:", "Over-posting:", "Mass assignment:"]
GLOSS = "The RED method: rate, errors and duration."
FILES = "README.md after before exercise harness receipts.md5 receipts.sh"
HARNESS = "chk23.py dur9.py norm.py ops9s3.py s923.py scrape.py src tree23.py"
EXFILES = "README.md SOLUTION.md apply.sh check.sh mappings.txt requests.txt run.sh"
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
    ok(sorted(os.path.relpath(os.path.join(d, f), "harness/src") for d, _, fs in os.walk("harness/src") for f in fs) == ["probe23/Boom.java"], "harness/src holds probe23/Boom.java only")
    ok(" ".join(sorted(x for x in os.listdir("exercise") if x not in (".servers", ".work"))) == EXFILES, "exercise/'s files exactly (no break.sh: the broken state is the empty answer)")
    for t in ("before", "after"):
        ok(os.path.islink(t) and os.readlink(t) == "../c9-unit22/after", "%s is a link whose text is ../c9-unit22/after" % t)
    A, Bt = walk(a), walk(b)
    ok(A == Bt, "the two links are one tree (%d files each)" % len(A))
    ok(not [k for k in A if k.split("/")[0] in ("target", "secrets", ".m2-demo", ".harness") or "/target/" in k], "no target/, secrets/, .m2-demo or .harness through the links")
    for rel in ("pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-core/pom.xml", "tiffinbox-client/pom.xml", "tiffinbox-web/src/main/resources/application.yaml",
                "tiffinbox-web/src/test/resources/openapi/tiffinbox.json", "tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeyFilter.java",
                "tiffinbox-web/src/main/java/com/tiffinbox/web/RateLimitFilter.java"):
        g = gitobj(rel)
        ok(g is not None and md5(g) == A.get(rel), "%s through the link = git show %s:c9-unit22/after/%s" % (rel, H22, rel))
    ok(not [p for p in (os.path.join(d, f) for d, _, fs in os.walk(".") if "/.harness" not in d and "/.m2-demo" not in d for f in fs) if "/src/main/" in p or "/src/test/" in p], "no src/main or src/test path of the tiffinbox modules under c9-unit23/ (the harness class lives in harness/src/probe23/)")
    ok(not [k for k, v in A.items() if "probe23" in open(os.path.join(a, k), "rb").read().decode("utf-8", "replace")], "Boom (probe23) named in no file of the shipped tree")
    rs = open("receipts.sh", encoding="utf-8").read()
    code = [l for l in rs.splitlines() if not l.lstrip().startswith("#")]
    ok(sum(1 for l in code if "tb cap5 21125" in l and '"$CAP5"' in l) == 1 and sum(1 for l in code if "rate-limit.capacity=5" in l) == 1, "the short capacity: one definition (CAP5) and one start (cap5) name it")
    ok(sum(1 for l in code if '"$HIST"' in l and l.strip().startswith("tb ")) == 1 and sum(1 for l in code if "percentiles-histogram.http.server.requests=true" in l) == 1, "the histogram flag: one definition and one labelled start")
    ok(sum(1 for l in code if '"$EXPO"' in l and l.strip().startswith("HJ=1 tb boom 21126")) == 1 and sum(1 for l in code if "exposure.include=" in l) == 1, "the exposure flag: one definition, only on the harness-joined start (21126)")
    ok(sum(1 for l in code if '"$BOOMSRC"' in l and l.strip().startswith("HJ=1 tb ")) == 1 and sum(1 for l in code if "main.sources=" in l) == 1, "the harness's failing route joined on one start only")
    ok(sum(1 for l in code if re.search(r"^\s*(HJ=1 )?tb \w+ 2112[^05-68]", l)) == 0, "every start on 21120, 21125, 21126 (21128: the exercise's run.sh)")
    mv = [l for l in code if "$MV " in l and "$G -" not in l] + [l for l in open("exercise/run.sh", encoding="utf-8").read().splitlines() if "mvn " in l]
    ok(not [l for l in mv if re.search(r" -s | --settings ", l)], "no -s on any Maven line (the default settings)")
    ok(not [l for l in mv if re.search(r"-pl tiffinbox-core(?! -am)", l) or re.search(r"-pl tiffinbox-web(?! -am)", l)], "R.391: no -pl form without -am")
    rd = open("README.md", encoding="utf-8").read()
    body = re.sub(r"```.*?```", "", rd, flags=re.S)
    ok(re.search(r"_(sum|max)\{[^}]*\} [0-9]", rd) is None, "README: no _sum or _max value")
    ok(re.search(r"\bevery `?404`? is\b", body, re.I) is None, "README: no 'every 404 is' outside a quoted block")
    ok(re.search(r"\bE (?:of RED )?(?:is|=) \d", body) is None, "README: no typed E total")
    ok(re.search(r"\b(?:a|every|any) filter'?s? (?:answer|refusal) (?:has|carries) no route\b", body, re.I) is None, "README: no 'a filter's answer has no route' (D1)")
    t = title()
    ok(len(t) <= 60, "the title for search: %d characters (<= 60)" % len(t))
    me = open(__file__, encoding="utf-8").read()
    subs = set(re.findall(r'^    elif cmd == "([a-z0-9-]+)"', me, re.M)) | set(re.findall(r'^    if cmd == "([a-z0-9-]+)"', me, re.M)) | set(CHECKS)
    ok(not (subs & set(LEFT_OUT)), "no left-out subcommand in chk23.py (%s)" % sorted(subs & set(LEFT_OUT)))
    finish(None)


def brief():
    c9 = os.environ.get("C9R") or ""
    return open(os.path.join(c9, "_briefs/UNIT-BRIEFS-S4-OPERATING.md"), encoding="utf-8").read()


def unit23(): return brief().split("\n## Unit 23", 1)[1].split("\n## Unit 24", 1)[0]


def hook(): return re.search(r'^\*\*Hook \(\[S4 §\d+\]\):\*\* "([^"]+)"', unit23(), re.M).group(1)


def exq(): return re.search(r'^\*\*Exercise:\*\* "(Your turn: [^"]+)"', unit23(), re.M).group(1)


def title(): return re.search(r'^\*\*Title for search:\*\* "([^"]+)"', unit23(), re.M).group(1)


# ---- capture checks ----------------------------------------------------------------------------------------------------------------
def budget(t):
    for m in re.finditer(r"^  budget \| (\S+): requests under /api/v1/ \(its access log\): (\d+) · refusal lines: (\d+) · rate limit: capacity (\d+)", t, re.M):
        if m.group(1) == "cap5":
            ok(m.group(4) == "5" and m.group(3) == "3", "cap5: the start line reads capacity 5 (the harness's short capacity), refusal lines %s" % m.group(3))
        else:
            ok(int(m.group(2)) <= BUDGET and m.group(3) == "0" and m.group(4) == "1000", "N11: %s sent %s /api/v1/ requests (<= %d), refusals %s, capacity %s read back" % (m.group(1), m.group(2), BUDGET, m.group(3), m.group(4)))
    return max([int(x) for x in re.findall(r"requests under /api/v1/ \(its access log\): (\d+)", t)] or [0])


ROW = re.compile(r"^  (\S+) \| (\S+) (\d{3}) (\S+) (\S+) error=(\S+) exception=(\S+) count=(\d+) keys=(\S+)$", re.M)


def rows(t, lab):
    return [(m.group(2), m.group(3), m.group(4), m.group(5), m.group(6), m.group(7), int(m.group(8)), m.group(9)) for m in ROW.finditer(t) if m.group(1) == lab]


def c_advisory(t):
    fa = grab(t, r"fetched-at (\S+) \(the hour masked\) · the unit's evidence started (\S+)")
    us = grab(t, r"the unit's evidence started (\S+) ·")
    rd = grab(t, r"^  ~ run date (\S+) ")
    ok(fa is not None and fa == us, "the read is the batch day's (fetched-at %s = the day the unit's evidence started %s, D15)" % (fa, us))
    import datetime as _d
    try: gap = (_d.date.fromisoformat(rd) - _d.date.fromisoformat(us)).days
    except (TypeError, ValueError): gap = None
    ok(gap in (0, 1), "the run's date %s is the start day or the day after it (the start's session resumed; a later day stops, D15)" % rd)
    for m in re.finditer(r"(\S+)/MD5SUMS.txt: (\d+) lines, (\d+) verified", t): ok(m.group(2) == m.group(3) and int(m.group(2)) > 0, "%s: %s of %s verified" % (m.group(1), m.group(3), m.group(2)))
    ok(len(re.findall(r"MD5SUMS.txt: \d+ lines", t)) == 2, "both of the day's MD5SUMS.txt read")
    ok("tomcat page md5 a1a756d985225fb5143eefd9aae3183c " in t, "Tomcat's page = the earlier reads")
    o = re.search(r"(\d+) coordinates queried, (\d+) results, (\d+) with vulns", t)
    ok(o is not None and o.group(3) == "0", "OSV: %s" % (o.group(0) if o else "absent"))
    ok("shipped | spring-boot 4.1.3" in t and "shipped | spring-context 7.0.11" in t and "shipped | tomcat-embed-core 11.0.29" in t and re.search(r"shipped \| jackson-databind [0-9.,]*3\.1\.8", t) and "shipped | micrometer-core 1.17.3" in t,
       "the pins: Boot 4.1.3, Framework 7.0.11, Tomcat 11.0.29, Jackson 3.1.8, Micrometer 1.17.3")
    lib = grab(t, r"BOOT-INF/lib names (\d+) = U22's")
    ok(lib == "167", "BOOT-INF/lib 167 (U22's)")
    ok("verdict: no pin affected; evidence may proceed" in t, "the verdict")
    finish("fetched=%s micrometer=1.17.3 lib=%s" % (fa, lib))


def c_before(t):
    ok("readlink before: ../c9-unit22/after · readlink after: ../c9-unit22/after · the two trees' hashes equal: yes (128 b8956a6e6fc128d08dab3d9885a0c431)" in t, "before = after = ../c9-unit22/after, 128 files b8956a6e")
    ok(grab(t, r"BOOT-INF/lib names (\d+)") == "167", "BOOT-INF/lib 167")
    ok("OPERATIONS 21 PATHS 19 · 36164 B md5 aa8cb98f4ff16d75d073026f0c618328" in t, "the spec: 21 operations, 19 paths, 36,164 B, aa8cb98f")
    ok("RateLimiting -95 · IdempotencyKeys -90 · ConditionalGets -80" in t, "the filters' orders -95, -90, -80")
    ok("capacity: 1000 refill-period: 1m" in t, "the limiter's keys: capacity 1000, refill-period 1m")
    finish("tree=128/b8956a6e lib=167 orders=-95/-90/-80")


def c_pin(t):
    ok(re.search(r"micrometer-core-1\.17\.3\.jar Implementation-Version 1\.17\.3 · micrometer-registry-prometheus-1\.17\.3\.jar 1\.17\.3", t) is not None, "Micrometer 1.17.3 and its Prometheus registry 1.17.3, off the manifests")
    br = re.findall(r"forStatus branch \d+: compares against (\S+) -> (\w+)", t)
    ok(len(br) >= 5, "the outcome rule read off javap (%d branches)" % len(br))
    names = [b[1] for b in br]
    ok(all(x in names for x in ("INFORMATIONAL", "SUCCESS", "REDIRECTION", "CLIENT_ERROR", "SERVER_ERROR", "UNKNOWN")), "the rule names all six outcomes")
    cl = [b for b in br if b[1] == "CLIENT_ERROR"]
    ok(cl and "400" in cl[0][0] and "500" in cl[0][0], "CLIENT_ERROR is the branch between 400 and 500 (a 429 falls in it, by the rule): %s" % (cl[0][0] if cl else "absent"))
    rd = [b for b in br if b[1] == "REDIRECTION"]
    ok(rd and "300" in rd[0][0] and "400" in rd[0][0], "REDIRECTION is the branch between 300 and 400 (a 304)")
    ok(re.search(r"the exposure in application\.yaml: include: health,prometheus$", t, re.M) is not None, "the exposure: health,prometheus")
    ok(re.search(r"percentiles-histogram or distribution in before's application\*\.yaml: 0 · the same grep on a scratch yaml holding the key: 1 \(the control\)", t) is not None, "no histogram key in any yaml (control 1)")
    ok(re.search(r"RateLimitFilter\.java 0 · IdempotencyKeyFilter\.java 1 · a scratch copy of RateLimitFilter\.java with one such line added: 1 \(the control\)", t) is not None, "setPathPattern/findObservationContext: RateLimitFilter 0, IdempotencyKeyFilter 1 (one line names both), control 1")
    ok(len(re.findall(r"IdempotencyKeyFilter\.java:\d+:\s+observe\(req, op\);", t)) == 2, "observe(req, op) called at two sites (the replay, answer())")
    ok("POST /customers required=false;POST /api/v1/customers/{name}/pauses required=true" in t, "the key filter's guarded routes")
    ok(re.search(r"GET /actuator on the default exposure \(21125, harness-free\) -> 200 · links: health health-path prometheus self", t) is not None, "GET /actuator: health, prometheus, self")
    ok("GET /actuator/metrics on the default exposure -> 404 · GET /actuator/mappings -> 404" in t, "/actuator/metrics and /actuator/mappings 404 on the default exposure")
    budget(t)
    finish("micrometer=1.17.3 rule=4xx:CLIENT_ERROR,3xx:REDIRECTION exposure=health,prometheus metrics=404")


def c_census(t):
    m = re.search(r"census before \| controllers (\d+) · final, default-run (\d+) · not final, default-run (\d+) · not final, dev-only (\d+) · other (\d+)", t)
    ok(m is not None and m.groups() == ("17", "11", "1", "5", "0"), "census 17/11/1/5 (U22's)")
    ok("census plant | the counter on an empty source folder: exit 1" in t, "the counter refuses an empty input")
    finish("census=%s" % ("/".join(m.groups()[:4]) if m else ""))


def c_spec(t):
    ok("spec | 36164 B · md5 aa8cb98f4ff16d75d073026f0c618328 · OPERATIONS 21 PATHS 19" in t, "the spec 36,164 B, aa8cb98f, 21/19")
    ok(re.search(r"ops9s3\.py on an empty spec: exit [1-9]", t) is not None, "the counter refuses an empty spec")
    finish("spec=36164 ops=OPERATIONS 21 PATHS 19")


def c_scrape(t):
    ok(re.search(r"scrape s1 \| GET /actuator/prometheus -> 200 · Content-Type text/plain;version=0\.0\.4;charset=utf-8", t) is not None, "the scrape 200, the text format")
    f = grab(t, r"families \| the http_server_requests families: (.*)$")
    ok(f is not None and "http_server_requests_seconds · summary" in f and "http_server_requests_active_seconds · summary" in f, "the families: %s" % f)
    ok(grab(t, r"_bucket lines in scrape1: (\d+)") == "0", "0 _bucket lines")
    ok(re.search(r"digits left after a _sum or _max label set in the masked text: 0 · in the raw text, more than 0: yes", t) is not None, "the mask: no _sum/_max value left (the raw text had them)")
    ok(re.search(r"_(sum|max)\{[^}]*\} [0-9]", t) is None, "no _sum/_max value anywhere in the filed text")
    budget(t)
    finish("families=%s _bucket=0" % (f or "").replace(" · ", ":").replace(";", ","))


def c_tags(t):
    k = grab(t, r"tags \| keys (\d+): (.*)$")
    ks = grab(t, r"tags \| keys \d+: (.*)$")
    ok(k == "6" and ks == "error exception method outcome status uri", "six tag keys: %s" % ks)
    ok(grab(t, r"tags \| error: (.*)$") == "none" and grab(t, r"tags \| exception: (.*)$") == "none", "error and exception read none on every row")
    ok(grab(t, r"tags \| outcome: (.*)$") == "CLIENT_ERROR SUCCESS", "outcome: CLIENT_ERROR, SUCCESS")
    ok(grab(t, r"tags \| status: (.*)$") == "200 400 404", "status: 200 400 404")
    ok(grab(t, r"tags \| method: (.*)$") == "GET", "method: GET")
    finish("keys=6(%s) error=none" % (ks or "").replace(" ", ","))


def c_known(t):
    ok(len(re.findall(r"^  nine \| a\d ", t, re.M)) == 9, "the nine rebuilt from the probe's bodies (9 lines)")
    ok(len(re.findall(r"^  req \| 0\d GET ", t, re.M)) >= 9, "the nine sent")
    m = re.search(r"known \| rows outside /actuator/: (\d+) · their counts' sum (\d+) · the probe's series\.txt rows (\d+), sum (\d+) · equal \(labels and counts\): (\w+)", t)
    ok(m is not None and m.group(1) == "7" and m.group(2) == "9" and m.group(5) == "yes", "7 rows, 9 requests, equal to the probe's series.txt")
    ok("the actuator's own rows in scrape1: none" in t, "scrape1 holds no actuator row (the first read)")
    ok(re.search(r"the sent list per \(method, status\) (.*) · the scrape's (.*) · equal: yes", t) is not None, "the counts equal the requests sent per (method, status), outside /actuator/")
    ok("of the nine: under a route template 7 · under /** (the pattern that catches every path) 2" in t, "7 under a template, 2 under /**")
    ok("old=GET 200 /customers/{name} count 1 " in t, "the old route's row: count 1")
    al = re.findall(r"^  access jvma \| (\S+) (\S+) (\d{3}) ×(\d+)$", t, re.M)
    ok(sum(int(x[3]) for x in al if not x[1].startswith(("/actuator", "/shutdown"))) == 15, "the access log: 15 lines outside /actuator/ and /shutdown - the nine and the second set's six (the second witness)")
    d = re.findall(r"^    (added|changed)\s+(\S+) (\d{3}) (\S+) (\S+) · count (.*)$", t, re.M)
    dd = {(x[1], x[2], x[4]): x[5] for x in d}
    ok(dd.get(("GET", "304", "/api/v1/customers/{name}")) == "1", "the diff: the conditional GET added a 304 row under the template")
    ok(dd.get(("DELETE", "405", "UNKNOWN")) == "1", "the diff: the 405 added under UNKNOWN")
    ok(dd.get(("POST", "201", "/api/v1/customers/{name}/pauses")) == "2", "the diff: the keyed POST and its replay, 201 ×2 under the pauses route")
    ok(dd.get(("POST", "400", "/api/v1/customers/{name}/pauses")) == "1", "the diff: the missing-key refusal 400 under the pauses route")
    ok(dd.get(("GET", "200", "/api/v1/customers/{name}")) == "2 -> 3", "the diff: the second set's first GET")
    ok(dd.get(("GET", "200", "/actuator/prometheus")) is not None, "the diff: the scrape's own row appears in scrape2")
    ok(grab(t, r"the scrape's own row in scrape2: GET 200 SUCCESS /actuator/prometheus count (\d+)") == "2", "the scrape's own row counts the two earlier reads")
    budget(t)
    finish("nine=9 rows=7 template=7 catchall=2 equal_series=yes old=1 second=304,405,201x2,400")


def c_404(t):
    r = re.findall(r"^  404 \| (\S+) (\S+) (\d+)$", t, re.M)
    rr = {x[0]: int(x[2]) for x in r}
    ok(rr == {"/**": 2, "/api/v1/customers/{name}": 1, "/api/v1/customers/{name}/bill": 1}, "the 404 rows: /** 2, the customer template 1, the bill template 1")
    b = re.findall(r"^  404 body \| GET (\S+) -> (.*?) · title", t, re.M)
    kinds = {u: k for u, k in b}
    ok(kinds.get("/api/v1/customers/Nobody", "").startswith("TiffinBox's own problem") and kinds.get("/api/v1/customers/Nobody/bill", "").startswith("TiffinBox's own problem"), "a template's 404: TiffinBox's own problem body")
    ok(kinds.get("/nowhere", "").startswith("Spring's static-resource") and kinds.get("/api/v1/nosuch/route", "").startswith("Spring's static-resource"), "the catch-all's 404: the static-resource problem")
    finish("template=2_rows catchall=/**x2")


def c_unknown(t):
    st = re.findall(r"^  req \| 0\d GET /api/v1/customers/Ravi -> (\d{3})", t, re.M)
    ok(st == ["200"] * 5 + ["429"] * 2, "cap=5: five 200, then two 429 (%s)" % ",".join(st))
    ok(re.search(r"an eighth read's headers .*HTTP/1\.1 429 ", t) is not None and re.search(r"an eighth read's headers .*Content-Type: application/problem\+json ·", t) is not None and re.search(r"an eighth read's headers .*Retry-After: <s>", t) is not None, "the 429's Content-Type application/problem+json (no charset), Retry-After read back and masked")
    c5 = {(x[0], x[1], x[3]): x[6] for x in rows(t, "cap5")}
    ok(c5.get(("GET", "429", "UNKNOWN")) == 3, "the limiter's refusals counted under UNKNOWN (3: the two of the list and the eighth read)")
    ok(c5.get(("GET", "200", "/api/v1/customers/{name}")) == 5, "the five reads under the template")
    ok([x for x in rows(t, "cap5") if x[1] == "429"][0][2] == "CLIENT_ERROR", "the 429's outcome CLIENT_ERROR")
    ok("cap5 | refusal lines in its log: 3" in t, "the limiter's log: 3 refusal lines")
    ok(re.search(r"^  req \| \d\d DELETE /api/v1/customers/Ravi -> 405 .*allow GET,HEAD,PATCH|^  req \| \d\d DELETE /api/v1/customers/Ravi -> 405 .*allow ", t, re.M) is not None, "the 405, its Allow read")
    ja = {(x[0], x[1], x[3]): x[6] for x in rows(t, "jvma")}
    ok(ja.get(("DELETE", "405", "UNKNOWN")) == 1, "the 405 under UNKNOWN")
    ok("rate limit: capacity 5" in t and "the harness's short capacity" in t, "cap=5 labelled, read back")
    budget(t)
    finish("429=UNKNOWN(3,CLIENT_ERROR) 405=UNKNOWN cap=5")


def c_filters(t):
    st = re.findall(r"^  req \| 0\d POST /api/v1/customers/Ravi/pauses\?days=2( Idempotency-Key=<generated>)? -> (\d{3})", t, re.M)
    ok(st == [(" Idempotency-Key=<generated>", "201"), (" Idempotency-Key=<generated>", "201"), ("", "400")], "the keyed POST 201, its replay 201, no key 400")
    ja = {(x[0], x[1], x[3]): x[6] for x in rows(t, "jvma")}
    ok(ja.get(("POST", "201", "/api/v1/customers/{name}/pauses")) == 2, "the route's answer and the key filter's replay: 2 under the pauses route")
    ok(ja.get(("POST", "400", "/api/v1/customers/{name}/pauses")) == 1, "the key filter's missing-key refusal under the pauses route")
    ok(not [k for k in ja if k[0] == "POST" and k[2] == "UNKNOWN"], "no POST under UNKNOWN")
    ok("the replay's witnesses: its body = the first answer's byte for byte: yes · the key filter's REPLAY line is logged at DEBUG (IdempotencyKeyFilter.log: 1), not on the default run: 0 lines" in t, "the replay answered the stored 201 byte for byte (its log line is DEBUG)")
    c5 = [x for x in rows(t, "cap5") if x[1] == "429"]
    ok(c5 and c5[0][3] == "UNKNOWN", "the limiter's refusal under UNKNOWN")
    finish("replay=/api/v1/customers/{name}/pauses(201) refusal=/api/v1/customers/{name}/pauses(400) limiter=UNKNOWN")


def c_errors(t):
    for lab in ("jvma scrape2", "cap5"):
        m = re.search(r"errors %s \| E \(the sum of the in rows' counts\) (\d+) · rows in (\d+) · rows out (\d+) · an error tag other than none: (\d+)" % re.escape(lab), t)
        ok(m is not None and m.group(4) == "0", "%s: the error tag reads none on every row" % lab)
    ins = re.findall(r"^  errors jvma scrape2 \| in  (\S+) (\d{3}) (\S+) (\S+)", t, re.M)
    outs = re.findall(r"^  errors jvma scrape2 \| out (\S+) (\d{3}) (\S+) (\S+)", t, re.M)
    ok(sorted({x[1] for x in ins}) == ["400", "404", "405"], "E's rows on the nine's JVM: the 400, the 404s, the 405 (and the key refusal's 400)")
    ok("304" in {x[1] for x in outs} and all(x[2] in ("SUCCESS", "REDIRECTION") for x in outs), "the 304 (REDIRECTION) is out, with the SUCCESS rows")
    ok(re.search(r"^  errors cap5 \| in  GET 429 CLIENT_ERROR UNKNOWN", t, re.M) is not None, "the 429 is in (CLIENT_ERROR)")
    ok(re.search(r"boom \| the harness's line: 1 \(U23 harness: ", t) is not None, "the harness-joined JVM printed its U23 harness line")
    ok(re.search(r"^  req \| 01 GET /probe23/boom -> 500", t, re.M) is not None, "the harness's failing route: 500")
    b = {(x[0], x[1], x[3]): x for x in rows(t, "boom")}
    bx = b.get(("GET", "500", "/probe23/boom"))
    ok(bx is not None and bx[2] == "SERVER_ERROR" and bx[5] == "IllegalStateException", "its row: SERVER_ERROR, exception IllegalStateException, under its own route")
    ok("status 200 vs 200 · body md5 equal: yes · header names equal: yes" in t, "N3: the shipped route answers the same on the harness-joined JVM")
    ok(re.search(r"GET /actuator/metrics/http\.server\.requests \(the harness's exposure flag\) -> 200", t) is not None, "the metrics endpoint under the harness's exposure flag: 200")
    ok("exercise/mappings.txt = this read without the harness's route: yes" in t, "mappings.txt = the read")
    ok(re.search(r"resource handlers: \S*/\*\*", t) is not None, "/** is a resource handler's pattern")
    budget(t)
    finish("in=CLIENT_ERROR+SERVER_ERROR out=SUCCESS,REDIRECTION(304) 429=in error_tag=none server_error=boom(500,IllegalStateException)")


def c_duration(t):
    ok(re.search(r"duration \| family http_server_requests_seconds · summary", t) is not None, "the duration family http_server_requests_seconds (summary)")
    ok(re.search(r"_bucket lines in scrape1: 0 · the same count on scrape1 with one planted _bucket line: 1 \(the control", t) is not None, "0 buckets by default, control 1")
    ok("hist | _bucket lines with the harness's histogram flag: more than 0: yes" in t, "the harness's histogram flag: buckets appear")
    ok(re.search(r"_(sum|max)\{[^}]*\} [0-9]", t) is None, "no _sum/_max value in the filed text")
    ok("Ship It & Observe" in t, "handed to Ship It & Observe by title")
    budget(t)
    finish("names=http_server_requests_seconds(_count,_sum,_max) _bucket=0 control=1 histogram_flag=buckets")


def c_api(t):
    ok(grab(t, r"api \| pass 1 -> pass 2: (\w+)") == "identical", "the census identical on two passes")
    n = grab(t, r"api \| pass 1 -> pass 2: \w+ \((\d+) requests each\)")
    ok(n is not None and int(n) >= 10, "the census: %s requests each" % n)
    ok(("api: api=%s identical" % n) in t, "= U22's census count")
    budget(t)
    finish("api=%s identical" % n)


def c_seven(t):
    e = grab(t, r"expected ([0-9a-f]{32})"); b = grab(t, r"before: the seven ([0-9a-f]{32})")
    ok(e is not None and b == e, "the seven = %s" % e)
    budget(t)
    finish("seven=%s" % (e or "")[:8])


def c_surface(t):
    e = grab(t, r"expected ([0-9a-f]{32})"); b = grab(t, r"before: the old surface ([0-9a-f]{32})")
    ok(e is not None and b == e, "the old surface = %s" % e)
    ok(grab(t, r"the old surface moved: (\w+) \(the check can fail\)") == "yes", "the S9.14 plant moves the surface")
    budget(t)
    finish("surface=%s" % (e or "")[:8])


def c_inert(t):
    k = re.findall(r"^  inert \| keyed: (.*)$", t, re.M)
    ok(k == ["POST /api/v1/customers/Ravi/pauses?days=2 201 key=yes"] * 2, "exactly two keyed requests, both on the nine's JVM (the key filter's leg)")
    per = re.findall(r"^  inert \| (\S+): requests \d+ · with a key (\d+)$", t, re.M)
    ok(sum(int(x[1]) for x in per if x[0] != "jvma2") == 0 and dict(per).get("jvma2") == "2", "no keyed request outside the second set")
    ok(grab(t, r"inert plant \| a scratch sent list with one keyed request added outside the key filter's leg: keyed (\d+)") == "1", "the plant counts its one keyed line")
    ok("name no Idempotency-Key: 0 · 0" in t, "the seven and the surface name no key")
    finish("keyed=2(jvma) elsewhere=0")


def c_tests(t):
    w = re.search(r"package \| tiffinbox-web \| tests (\d+) failures 0 errors 0 skipped 0", t)
    ok(w is not None and w.group(1) == "88", "the web module 88 green, 0 skipped")
    c = re.search(r"package \| tiffinbox-client \| tests (\d+) failures 0 errors 0 skipped 0", t)
    ok(c is not None and c.group(1) == "5", "the client module 5 green, 0 skipped")
    ok("package | tiffinbox-web | class InputHardeningTest | tests 3 skipped 0" in t, "InputHardeningTest 3 of the 88")
    ok(len(re.findall(r"^  reactor: TiffinBox.* \.\.\. SUCCESS", t, re.M)) == 4, "the reactor's four SUCCESS lines")
    ok(grab(t, r"outside RateLimitFilterTest (\d+)") == "0", "R.555: 0 refusals at the default outside RateLimitFilterTest")
    ok("downloads across the builds: 0" in t, "0 downloads")
    finish("web=%s client=%s its=14(U22) verify=not_run" % (w.group(1) if w else "", c.group(1) if c else ""))


def c_harness(t):
    ok("harness/: " + HARNESS + " · harness/src: probe23/Boom.java · exercise/: " + EXFILES in t, "the folder's files exactly")
    ok(re.search(r"not used \(absent from harness/\): .* - 0 present", t) is not None, "no instrument this unit does not carry")
    ok("Boom named in the tree's jar entries: 0 · in before's files: 0" in t, "Boom in no jar and no shipped file")
    ok("static (ii) beside a scratch copy of the anchor with a byte appended to its compose.yaml (the real anchor untouched): output md5 = (i): yes" in t, "static (ii) = (i)")
    ok("reading the live anchor (its folder name assembled) -> exit 1 · the same path from two pieces -> exit 1" in t, "flag 19's two plants exit 1")
    ok("counted by the receipts' own GNU-form grep: 1 (1 = caught)" in t, "R.564's GNU-sed plant counted")
    ok("c9-unit10/receipts.sh:611=1 c9-unit13/receipts.sh:334=1 c9-unit15/receipts.sh:396=1" in t, "the three frozen receipts' live-anchor pom lines, printed (findings, not edits)")
    ok(re.search(r"every pom: 0 lines", t) is not None, "the derived changed list is empty")
    finish("static=%s" % grab(t, r"as written: output md5 ([0-9a-f]{32})"))


def c_exercise(t):
    for sh in ("bash", "zsh"):
        l = "\n".join(re.findall(r"^  %s \| (.*)$" % sh, t, re.M)); r = "\n".join(re.findall(r"^  %s run \| (.*)$" % sh, t, re.M))
        ok("run exit 0" in l, "%s: run.sh exit 0" % sh)
        ok("FAIL (1) a 404 row's count is missing" in l and "FAIL (3) the not-a-route line" in l and "broken: check exit 1" in l, "%s: the empty answer FAILs clauses 1 and 3" % sh)
        ok("PASS: 3 404 rows counted by uri" in l and "solved: check exit 0" in l, "%s: the solution PASSes" % sh)
        ok("404 rows in the scrape: /** 3 · /api/v1/customers/{name} 2 · /api/v1/customers/{name}/bill 1" in r, "%s: the exercise's scrape: /** 3, the customer template 2, the bill 1" % sh)
    ok("the two shells' scrapes, 404 rows: equal" in t, "bash and zsh -f: the same 404 rows")
    ok("solved = SOLUTION.md's answer block: yes" in t, "the solution's answer = SOLUTION.md's block")
    want = {"none": "(1)", "all": "(2)", "template": "(3)", "unknown": "(3)", "short": "(1)"}
    for v, cl in want.items():
        l = "\n".join(re.findall(r"^  ~ %s bash \| (.*)$" % v, t, re.M))
        if l: ok("check exit 1" in l and ("FAIL " + cl) in l, "refused variant %s: exit 1, clause %s" % (v, cl))
    rb = re.findall(r"^  README: (.*)$", t, re.M); sb = re.findall(r"^  SOLUTION: (.*)$", t, re.M)
    bl = "\n".join(re.findall(r"^  bash \| (.*)$", t, re.M))
    ok(rb and all(x in bl for x in rb), "exercise/README.md's What it prints = the bash run's lines")
    ok(sb and all(x in bl for x in sb), "exercise/SOLUTION.md's What it prints = the bash run's lines")
    finish("broken=FAIL(1,3) solved=PASS(3_rows) catchall=/**")


def c_title(t):
    n = grab(t, r'\((\d+) characters by len\(\)\)')
    ok(n is not None and int(n) <= 60, "the title for search: %s characters (<= 60)" % n)
    ok(grab(t, r"naming http\.server, per-endpoint or prometheus: (\d+)") == "0", "no clash in the registries")
    finish("title_len=%s" % n)


CHECKS = {"advisory": c_advisory, "before": c_before, "pin": c_pin, "census": c_census, "spec": c_spec, "scrape": c_scrape, "tags": c_tags,
          "known": c_known, "404": c_404, "unknown": c_unknown, "filters": c_filters, "errors": c_errors, "duration": c_duration, "api": c_api,
          "seven": c_seven, "surface": c_surface, "inert": c_inert, "tests": c_tests, "harness": c_harness, "exercise": c_exercise, "title": c_title}

PLANTS = [("known", r"(of the nine: under a route template )7", r"\g<1>8", "a count one off (8 under a template)"),
          ("known", r"(old=GET 200 /customers/\{name\} count )1", r"\g<1>2", "the old route's count typed 2"),
          ("known", r"(equal \(labels and counts\): )yes", r"\1NO", "a row of series.txt typed differently"),
          ("known", r"the actuator's own rows in scrape1: none", "the actuator's own rows in scrape1: GET 200 /actuator/prometheus", "a /actuator/prometheus row typed in scrape1"),
          ("known", r"(    added\s+DELETE 405 CLIENT_ERROR )UNKNOWN", r"\1/api/v1/customers/{name}", "the 405 typed under a template"),
          ("tags", r"(tags \| keys )6: error", r"\g<1>7: color error", "a seventh key"),
          ("tags", r"(tags \| error: )none", r"\1true", "the error tag typed non-none"),
          ("404", r"(  404 \| /\*\* \S+ )2", r"\g<1>3", "the catch-all's 404 count typed 3"),
          ("404", r"(  404 \| )/api/v1/customers/\{name\}/bill", r"\1/**", "a template's 404 typed under /**"),
          ("unknown", r"(  cap5 \| GET 429 CLIENT_ERROR )UNKNOWN", r"\1/api/v1/customers/{name}", "the 429 typed under its route"),
          ("unknown", r"(budget \| cap5: .*rate limit: capacity )5", r"\g<1>1000", "the capacity typed 1000 on the cap=5 JVM"),
          ("unknown", r"Retry-After: <s>", "Retry-After: 42", "Retry-After voiced"),
          ("filters", r"(  jvma \| POST 201 CREATED |  jvma \| POST 201 SUCCESS )/api/v1/customers/\{name\}/pauses", r"\1UNKNOWN", "the replay typed UNKNOWN"),
          ("filters", r"(pauses\?days=2 -> )400", r"\g<1>201", "the missing-key refusal typed 201"),
          ("errors", r"(errors cap5 \| )in  (GET 429)", r"\1out \2", "a 429 left out of E"),
          ("errors", r"(errors jvma scrape2 \| )out (GET 304)", r"\1in  \2", "a 304 counted in E"),
          ("errors", r"(an error tag other than none: )0", r"\g<1>1", "the error tag read as E"),
          ("errors", r"(  boom \| GET 500 )SERVER_ERROR", r"\1UNKNOWN", "the SERVER_ERROR row typed otherwise"),
          ("duration", r"(the same count on scrape1 with one planted _bucket line: )1", r"\g<1>0", "_bucket=0 with no planted control"),
          ("duration", r"(series name \(value masked\) http_server_requests_seconds_\w+\{[^}]*\} )<v>", r"\g<1>0.0123", "a _sum value left in a filed text"),
          ("scrape", r"(_bucket lines in scrape1: )0", r"\g<1>4", "buckets typed present by default"),
          ("pin", r"micrometer-core-1\.17\.3\.jar Implementation-Version 1\.17\.3", "micrometer-core-1.17.3.jar Implementation-Version 1.17.2", "Micrometer typed 1.17.2"),
          ("pin", r"(?m)include: health,prometheus$", "include: health,prometheus,metrics", "the exposure typed health,prometheus,metrics"),
          ("pin", r"(GET /actuator/metrics on the default exposure -> )404", r"\g<1>200", "/actuator/metrics typed 200 on the default exposure"),
          ("pin", r"(RateLimitFilter\.java )0( · IdempotencyKeyFilter)", r"\g<1>1\2", "the limiter typed as setting its route"),
          ("pin", r"(with one such line added: )1", r"\g<1>0", "the sources' grep without its planted control"),
          ("before", r"readlink before: \.\./c9-unit22/after", "readlink before: ../c9-unit21/after", "before retargeted"),
          ("before", r"(BOOT-INF/lib names )167", r"\g<1>166", "BOOT-INF/lib typed 166"),
          ("census", r"(controllers )17", r"\g<1>18", "the census typed 18"),
          ("spec", r"spec \| 36164 B", "spec | 36165 B", "the spec one byte off"),
          ("tests", r"(package \| tiffinbox-web \| tests )88", r"\g<1>85", "88 typed 85"),
          ("tests", r"(package \| tiffinbox-web \| tests 88 failures 0 errors 0) skipped 0", r"\1 skipped 1", "Skipped typed 1"),
          ("tests", r"outside RateLimitFilterTest 0", "outside RateLimitFilterTest 1", "a refusal at the default"),
          ("seven", r"before: the seven ([0-9a-f]{31})[0-9a-f]", r"before: the seven \g<1>0", "the seven's md5 one character off"),
          ("surface", r"before: the old surface ([0-9a-f]{31})[0-9a-f]", r"before: the old surface \g<1>0", "the surface's md5 one character off"),
          ("api", r"(pass 1 -> pass 2: )identical", r"\1DIFFER", "the census moved"),
          ("inert", r"(  inert \| cap5: requests \d+ · with a key )0", r"\g<1>1", "a keyed request outside the key filter's leg"),
          ("exercise", r"(  bash \| )solved: check exit 0", r"\1solved: check exit 1", "solution = broken"),
          ("exercise", r"(  zsh \| )broken: check exit 1", r"\1broken: check exit 0", "the empty answer typed passing"),
          ("advisory", r"(fetched-at )2026-11-27", r"\g<1>2026-11-26", "the read one day older than the start"),
          ("advisory", r"(  ~ run date )\S+", r"\g<1>2026-11-29", "a run two days after the start"),
          ("api", r"(  budget \| api: requests under /api/v1/ \(its access log\): )\d+", r"\g<1>61", "a per-JVM request count above the cap"),
          ("seven", r"(  budget \| seven: requests under /api/v1/ \(its access log\): \d+ · refusal lines: )0", r"\g<1>1", "a refusal line in a default-capacity JVM"),
          ("title", r"\((\d+) characters by len\(\)\)", "(61 characters by len())", "a title over 60")]


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
        n += 1
    for nm, line in (("known", "  scrape1 | garbage\n"), ("unknown", "  cap5 | garbage\n"), ("tests", "  package | garbage\n"), ("scrape", "  scrape s1 | garbage\n")):
        r = subprocess.run([sys.executable, "-I", "-B", __file__, nm, "-"], input=line, capture_output=True, text=True)
        ok(r.returncode == 1 and "Traceback" not in r.stderr, "plant an unparseable %s listing: a FAIL line, exit 1, no traceback" % nm); n += 1
    bad = os.path.join(d, ".harness", "work", "unparseable.txt")
    if os.path.isdir(os.path.dirname(bad)):
        open(bad, "w").write("http_server_requests_seconds_count{uri=\"/x\"} \n!!!\n")
        r = subprocess.run([sys.executable, "-I", "-B", os.path.join(os.path.dirname(__file__), "scrape.py"), "rows", bad], capture_output=True, text=True)
        ok(r.returncode == 1 and r.stdout.startswith("FAIL") and "Traceback" not in r.stderr, "plant an unparseable scrape line: scrape.py prints a FAIL line, exit 1, no traceback"); n += 1
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
        ok(sum(1 for l in r if l.startswith("The RED method:")) == 1 and GLOSS in r, "exactly one gloss line, The RED method:, byte for byte (%d words)" % len(GLOSS.split()))
        print("GLOSS %s (%d words; the brief's parenthetical: (rate, errors, duration))" % (GLOSS, len(GLOSS.split())))
        for u in list(range(13, 21)) + [22]:
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
        print("the brief's hooks and exercises: %d + %d (R.534; the gates paragraph's own pattern line is not matched), the interleaved list's md5 %s" % (len(hs), len(es), md5(il.encode())))
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
