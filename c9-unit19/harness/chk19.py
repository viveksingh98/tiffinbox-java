"""Course 9 unit 19's checks (python3 -I -B harness/chk19.py SUBCOMMAND ...), run from c9-unit19/.

Each capture's check reads the masked capture file the receipt wrote (.r-NAME.new) and prints "ok ..." or "FAIL ..." lines and one
"VALUES ..." line; any FAIL exits 1 (a line it cannot parse is a FAIL line, exit 1, never a traceback). `static` reads only this unit's
frozen after/, before (the link to ../c9-unit18/after) and git objects of unit 18's commit (c5406fc:c9-unit18/after/...) - never the live
anchor: an audit hook refuses any open() whose real path lies in the live anchor's folder, so a static read of it exits 1 (flag 31).
Subcommands: static AFTER BEFORE · static-plant live|pieces · gloss README · gloss-line · hook · exq · interleaved · hashable NAME FILE ·
values README VALS · plants DIR · and one per capture: advisory before change census limit forge refill scope twojvm defaults spec moved
api seven surface tests harness exercise inert.
"""
import hashlib, os, re, subprocess, sys

ANCHOR_DIR = "/c9-" + "tiffinbox"   # LIVE_ANCHOR_PLANT: the live anchor's folder name, assembled so a grep for it finds only this line


def _guard(event, args):
    if event == "open" and args and isinstance(args[0], (str, bytes, os.PathLike)):
        p = os.path.realpath(os.fsdecode(args[0]))
        if (ANCHOR_DIR + "/") in p or p.endswith(ANCHOR_DIR):
            raise SystemExit("FAIL flag 31: a static check read the live anchor (%s)" % p)


GLOSS = "A token bucket: a count of requests that refills."
H18 = "c5406fc"
LEFT_OUT = ["proxy", "declared", "signed", "presign", "sealed", "expect", "specwire", "blob", "bills", "poll", "accept", "callpg", "html",
            "walk", "pageable", "trap", "table", "first", "next", "section"]
OUT = []


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


# ---- static (flag 31: after/, before and git objects only) -------------------------------------------------------------------------
EXPECTED_CHANGED = ["A tiffinbox-web/src/main/java/com/tiffinbox/web/RateLimitFilter.java",
                    "A tiffinbox-web/src/main/java/com/tiffinbox/web/RateLimiting.java",
                    "A tiffinbox-web/src/test/java/com/tiffinbox/web/RateLimitFilterTest.java",
                    "M README.md", "M pom.xml", "M tiffinbox-web/pom.xml", "M tiffinbox-web/src/main/resources/application.yaml"]
BYTE_EQUAL = ["tiffinbox-web/src/main/java/com/tiffinbox/web/" + n + ".java" for n in
              ("TiffinBoxErrors", "TiffinBoxOpenApi", "TiffinBoxApiVersioning", "IdempotencyKeys", "IdempotencyKeyFilter", "CustomerBills")] + \
             ["Dockerfile", "compose.yaml", "tiffinbox-web/src/main/resources/application-dev.yaml", "tiffinbox-core/pom.xml",
              "tiffinbox-client/pom.xml", "tiffinbox-web/src/test/resources/openapi/tiffinbox.json"]


def walk(r):
    out = {}
    for d, ds, fs in os.walk(r):
        for f in fs:
            p = os.path.join(d, f); out[os.path.relpath(p, r)] = md5(open(p, "rb").read())
    return out


def gitobj(rel):
    top = subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True).stdout.strip()
    r = subprocess.run(["git", "-C", top, "show", "%s:c9-unit18/after/%s" % (H18, rel)], capture_output=True)
    return r.stdout if r.returncode == 0 else None


def static(a, b):
    sys.addaudithook(_guard)
    A, Bt = walk(a), walk(b)
    ch = sorted(["A " + k for k in A if k not in Bt] + ["D " + k for k in Bt if k not in A] + ["M " + k for k in A if k in Bt and A[k] != Bt[k]])
    ok(ch == sorted(EXPECTED_CHANGED), "the changed set (after/ against before, derived) is flag 2's: %s" % " · ".join(ch))
    for rel in BYTE_EQUAL:
        g = gitobj(rel)
        ok(g is not None and md5(g) == A.get(rel), "%s byte-equal to git show %s:c9-unit18/after/%s" % (rel, H18, rel))
    for k in sorted(Bt):
        if k.startswith("tiffinbox-web/src/test/") and k in A:
            if A[k] != Bt[k]: ok(False, "an existing test file was edited: " + k)
    ok(True, "every existing test file byte-equal to before's (%d files)" % sum(1 for k in Bt if k.startswith("tiffinbox-web/src/test/")))
    f = open(os.path.join(a, EXPECTED_CHANGED[0][2:]), encoding="utf-8").read()
    ok(re.search(r"^public final class RateLimitFilter extends OncePerRequestFilter \{", f, re.M) is not None, "RateLimitFilter is final and extends OncePerRequestFilter")
    ok(len(re.findall(r"getHeaders?\(", f)) == 0, "RateLimitFilter reads no request header (getHeader( / getHeaders(: 0)")
    ok("getWriter(" not in f and "getOutputStream()" in f and "setContentLength(" in f, "RateLimitFilter writes the refusal as bytes with its Content-Length (getWriter(: 0)")
    c = open(os.path.join(a, EXPECTED_CHANGED[1][2:]), encoding="utf-8").read()
    pats = re.findall(r'addUrlPatterns\(([^)]*)\)', c)
    ok(pats == ['"/api/v1/*"'], "RateLimiting registers exactly /api/v1/* (%s)" % pats)
    ok('"/*"' not in c, "no /* pattern in RateLimiting")
    ok("ORDER = -95" in c, "RateLimiting's order -95 (IdempotencyKeys' -90 runs after it)")
    src = ""
    for d, ds, fs in os.walk(os.path.join(a, "tiffinbox-web/src/main")):
        for x in fs:
            if x.endswith(".java"): src += open(os.path.join(d, x), encoding="utf-8").read()
    ok("X-Api-Key" not in src and "X-Forwarded-For" not in src, "no X-Api-Key and no X-Forwarded-For string in src/main")
    new = f + c
    ok("X-Forwarded" not in new, "no X-Forwarded string in the two new classes")
    ok(re.search(r"\bProbe|probe\.s4|THE PROBE|\bR4\b", src) is None, "no probe name in src/main")
    pp = open(os.path.join(a, "pom.xml"), encoding="utf-8").read(); wp = open(os.path.join(a, "tiffinbox-web/pom.xml"), encoding="utf-8").read()
    ok(pp.count("<bucket4j.version>8.23.0</bucket4j.version>") == 1 and pp.count("bucket4j.version>") == 2, "bucket4j.version once in the parent POM")
    ok("8.23.0" not in wp and wp.count("${bucket4j.version}") == 2, "tiffinbox-web/pom.xml names Bucket4j by ${bucket4j.version} only (twice; no literal 8.23.0)")
    ok(re.search(r"Course 9, unit 19: Bucket4j, the token bucket.*?spring-boot-starter-parent|newest the course's sweep", pp, re.S) is not None, "the pin's R.515 comment (the sweep's newest, the measured surface)")
    y = open(os.path.join(a, "tiffinbox-web/src/main/resources/application.yaml"), encoding="utf-8").read()
    ok(re.search(r"# Course 9, unit 19:.*\n(  #.*\n)*  rate-limit:\n    capacity: 1000\n    refill-period: 1m\n", y) is not None, "application.yaml: the two keys under a reason comment, the default 1000 per 1m")
    ok(y.index("rate-limit:") < y.index("\n---\n"), "the keys above the ---")
    t = open(os.path.join(a, EXPECTED_CHANGED[2][2:]), encoding="utf-8").read()
    ok(re.search(r"@(org\.junit\.jupiter\.api\.(condition\.)?)?(Disabled|EnabledIf|DisabledIf|EnabledOn|DisabledOn|EnabledFor|DisabledFor)\w*", t) is None, "RateLimitFilterTest: no disabling or conditional annotation, simple or fully qualified")
    tc = re.sub(r'"[^"\n]*"', '""', t)
    ok(re.search(r"RANDOM_PORT|DEFINED_PORT|LocalServerPort|\bSocket\b|(?<![\d.])\d{4,5}(?![\d.])", tc) is None, "RateLimitFilterTest: no port, no socket, no 4-5 digit literal outside a string")
    rd = open(os.path.join(a, "README.md"), encoding="utf-8").read()
    card = rd.split("## Course 9 · unit 19", 1)
    ok(len(card) == 2, "the anchor README has a unit 19 card")
    if len(card) == 2:
        body = card[1].split("\n## ", 1)[0]
        bad = [l for l in body.splitlines() if re.search(r"(?<![\d.,])(78|164)(?![\d.,])", l) and "unit 18" not in l]
        ok(not bad, "the card gives 78 and 164 as unit 18's counts only (%d lines otherwise)" % len(bad))
    ok("Course 9's fifteenth change to this folder (U19)" in rd, "the header note names the fifteenth change")
    me = open(__file__, encoding="utf-8").read()
    subs = set(re.findall(r'^    elif cmd == "([a-z0-9-]+)"', me, re.M)) | set(re.findall(r'^    if cmd == "([a-z0-9-]+)"', me, re.M)) | set(re.findall(r'^    "([a-z0-9]+)": ', me, re.M))
    ok(not (subs & set(LEFT_OUT)), "no left-out subcommand in chk19.py (%s)" % sorted(subs & set(LEFT_OUT)))
    finish(None)


# ---- the brief's lines -------------------------------------------------------------------------------------------------------------
def brief():
    c9 = os.environ.get("C9R") or ""
    return open(os.path.join(c9, "_briefs/UNIT-BRIEFS-S4-OPERATING.md"), encoding="utf-8").read()


def unit19(): return brief().split("\n## Unit 19", 1)[1].split("\n## Unit 20", 1)[0]


def hook(): return re.search(r'^\*\*Hook \(\[S4 §6\]\):\*\* "([^"]+)"', unit19(), re.M).group(1)


def exq(): return re.search(r'^\*\*Exercise:\*\* "(Your turn: [^"]+)"', unit19(), re.M).group(1)


# ---- capture checks ----------------------------------------------------------------------------------------------------------------
def statuses(t, lab):
    return [int(x) for x in re.findall(r"^  %s #\d+ \| .*? -> (\d{3}) " % re.escape(lab), t, re.M)]


def c_advisory(t):
    fa = grab(t, r"fetched-at (\S+) \(the hour masked\) · run date (\S+)")
    rd = grab(t, r"run date (\S+) ·")
    ok(fa is not None and fa == rd, "the read is the batch day's (fetched-at %s = run date %s)" % (fa, rd))
    for m in re.finditer(r"(\S+)/MD5SUMS.txt: (\d+) lines, (\d+) verified", t): ok(m.group(2) == m.group(3) and int(m.group(2)) > 0, "%s: %s of %s verified" % (m.group(1), m.group(3), m.group(2)))
    ok("tomcat page md5 a1a756d985225fb5143eefd9aae3183c " in t, "Tomcat's page = the earlier reads")
    ok(re.search(r"\| 25 November 19, 2026$", t, re.M) is not None or "25 November 19, 2026" in t, "Spring's first page: 25 rows of November 19, 2026")
    o = re.search(r"(\d+) coordinates queried, (\d+) results, (\d+) with vulns", t)
    ok(o is not None and o.group(3) == "0" and o.group(1) == o.group(2), "OSV: %s" % (o.group(0) if o else "absent"))
    ok(len(re.findall(r"licence \| bucket4j\S+ 8\.23\.0: The Apache Software License, Version 2\.0", t)) == 3, "the three Bucket4j POMs: Apache-2.0")
    ok("verdict: no pin affected; evidence may proceed" in t, "the verdict")
    finish("fetched=%s lib=%s" % (fa, grab(t, r"lib names before (\d+ · after \d+)")))


def c_before(t):
    s = statuses(t, "before")
    ok(s == [200] * 7, "seven reads on before: %s" % s)
    ok(grab(t, r"refusal lines in the JVM's log: (\d+)") == "0" and grab(t, r"the setting's line in the start's log: (\d+)") == "0" and grab(t, r"rate-limit keys in before's application.yaml: (\d+)") == "0", "no limiter on before")
    ok(grab(t, r"BOOT-INF/lib names (\d+)") == "164", "before's lib 164")
    m = grab(t, r"before \| mappings (\d+) · under /api/v1/ (\d+)")
    finish("before=7x200 lib=164 mappings=%s %s" % (m, grab(t, r"the committed spec: (.*?) ·")))


def c_change(t):
    ch = grab(t, r"changed \(derived: .*?\): (.*)$")
    got = sorted((ch or "").split(" · "))
    ok(got == sorted(EXPECTED_CHANGED), "the derived changed list is flag 2's (%d paths)" % len(got))
    ok("header reads (getHeader( / getHeaders(): 0" in t and "getWriter(: 0" in t, "the filter reads no header and writes no getWriter body")
    ok(re.search(r"src/main: X-Api-Key 0 lines · X-Forwarded-For 0 · X-Forwarded in the two new classes 0 · Probe/R4/probe.s4 0 · @Component in the two new classes 0", t) is not None, "src/main names no header, no probe; no @Component")
    ok(re.search(r"bucket4j.version in the parent POM: 1 line\(s\) · the literal 8.23.0 in tiffinbox-web/pom.xml: 0", t) is not None, "the pin once, by property")
    ok(not re.search(r"byte-equal to before's: no", t), "the listed files byte-equal to before's")
    ok(grab(t, r"handler names added: (\d+)") == "0", "no handler added")
    ok("bucket4j_jdk17-core-8.23.0.jar bucket4j_jdk17-lettuce-8.23.0.jar bucket4j_jdk17-redis-common-8.23.0.jar lettuce-core-7.5.2.RELEASE.jar" in t, "the jar: the three Bucket4j jars and Lettuce 7.5.2.RELEASE")
    ok(re.search(r"lettuce-core:jar:7\.5\.2\.RELEASE", t) is not None, "dependency:tree resolves lettuce-core 7.5.2.RELEASE")
    finish("changed=%d" % len(got))


def c_census(t):
    b = grab(t, r"census before \| controllers (.*)$"); a = grab(t, r"census after \| controllers (.*)$")
    ok(b is not None and a == b, "the census before = after: %s" % b)
    ok(t.count("not a controller by the rule: RateLimit") == 2, "RateLimitFilter and RateLimiting excluded by the rule, named")
    sb = grab(t, r"the spec's counts .*?before (.*?) · after"); sa = grab(t, r"the spec's counts .*? · after (.*)$")
    ok(sb == sa, "the spec's counts equal: %s" % sb)
    nums = re.findall(r"\d+", b or "")
    finish("census=%s spec=%s" % ("/".join(nums[:4]), sb))


def c_limit(t):
    s = statuses(t, "limit")
    ok(s == [200] * 5 + [429] * 2, "seven reads at cap=5: %s" % s)
    r = [l for l in t.splitlines() if re.match(r"  limit #\d+ \| .* -> 429 ", l)]
    for l in r:
        m = re.search(r"Content-Type (\S+) · Content-Length (\d+) · curl (\d+) B · file (\d+) B", l)
        ok(m is not None and m.group(1) == "application/problem+json" and m.group(2) == m.group(3) == m.group(4), "the refusal's bytes by Content-Length, curl and the file: %s" % (str(m.groups()) if m else l[:80],))
        ok("Retry-After: <n> (an integer: yes)" in l, "Retry-After an integer")
        ok("members type,title,status,detail,instance · type tag:tiffinbox.example,2026:rate-limited" in l and "instance /api/v1/customers/Ravi" in l, "the problem's members and type")
    ok(re.search(r"a charset other than UTF-8: no · Retry-After an integer >= 1 and <= the period's seconds \(60, read off application.yaml's 1m\): yes · Content-Length = the body's bytes: yes · chunked: no", t) is not None, "python: no non-UTF-8 charset, Retry-After within the period, Content-Length the bytes, not chunked")
    ok(grab(t, r"statuses ((?:\d{3} ?)+) · the refusals' %b") == "200 200 200 200 200 429 429", "the access log's seven statuses")
    b = grab(t, r"the refusals' %b (\S+)"); cl = grab(t, r"-> 429 · Content-Type \S+ · Content-Length (\d+)")
    ok(b == cl, "the access log's %%b = Content-Length (%s, %s)" % (b, cl))
    ok(grab(t, r"refusal lines in the JVM's log: (\d+)") == "2" and grab(t, r"the address named in them: (\d+)") == "0", "two refusal lines, no address in them")
    ok(grab(t, r"Redis connection lines in the default run's log .*?: (\d+)") == "0", "the default run touches no Redis")
    ok("capacity 5 per refill period <period>, the buckets in this JVM" in t, "the setting read back by the start line (cap=5)")
    m429 = re.search(r"metrics \| count (\d+) · method GET · outcome (\S+) · status 429 · uri (\S+)", t)
    m200 = re.search(r"metrics \| count (\d+) · method GET · outcome SUCCESS · status 200 · uri (\S+)", t)
    ok(m429 is not None and m429.group(1) == "2" and m429.group(2) == "CLIENT_ERROR", "metrics: the refusals counted %s, CLIENT_ERROR" % (m429.group(1) if m429 else "-"))
    ok(m200 is not None and m200.group(1) == "5", "metrics: the five 200s counted")
    if "charset other than UTF-8: yes" in t: ok(False, "charset: a non-UTF-8 charset on the refusal")
    finish("statuses=%s body=%sB ct=application/problem+json metrics429=%s uri429=%s uri200=%s" % (",".join(map(str, s)), cl, m429.group(1) if m429 else "", m429.group(3) if m429 else "", m200.group(2) if m200 else ""))


def c_forge(t):
    ok(t.count("requests until the first refusal: 6") == 1 and t.count("requests until the first refusal, no header: 6") == 2, "the address's bucket emptied by its sixth request (anchor, copy, xff)")
    for lab in ("anchor X-Api-Key forged-1", "anchor X-Api-Key forged-2", "anchor X-Forwarded-For 10.0.0.1"):
        ok(re.search(r"^  %s \| .* -> 429 " % re.escape(lab), t, re.M) is not None, "%s -> 429 (counted under the address)" % lab)
    for lab, want in (("copy (a made-up key) X-Api-Key forged-1", "200"), ("copy (a made-up key) X-Api-Key forged-2", "200"), ("copy (a made-up key) no header again", "429")):
        ok(re.search(r"^  %s \| .* -> %s " % (re.escape(lab), want), t, re.M) is not None, "%s -> %s" % (lab, want))
    xs = re.findall(r"^  xff \(flag=on\) X-Forwarded-For (\S+) \| .* -> (\d{3}) ", t, re.M)
    ok(len(xs) == 3, "flag=on: three forged addresses answered")
    sev = grab(t, r"X-Forwarded-For 10\.0\.0\.1, its seventh \| .* -> (\d{3}) ")
    finish("anchor=429x3 copy=200,200,429 xff=%s xff_seventh=%s" % (",".join(s for a, s in xs), sev))


def c_refill(t):
    s = statuses(t, "refill")
    ok(s == [200] * 5 + [429], "five 200 and a refusal: %s" % s)
    ok("Retry-After within the period: yes" in t, "the refusal's Retry-After within the short period")
    ok("the first request after the wait: 200" in t, "the first request after the wait: 200")
    k = grab(t, r"before the next refusal: (\d+) · the next answer: (\d+)")
    ok(k == "5" and grab(t, r"the next answer: (\d+)") == "429", "the bucket gave back %s, then the next refusal" % k)
    ok(re.search(r"refill the next refusal \| .* -> 429 .*Retry-After: <n> \(an integer: yes\)", t) is not None, "the next refusal's Retry-After read again")
    finish("after_wait=200 given_back=%s" % k)


SCOPE_API = ["/api/v1/orders?size=5", "/api/v1/customers/Ravi/bill", "/api/v1/nosuch/route"]
SCOPE_OUT = ["/customers/Ravi", "/revenue", "/dashboard", "/v3/api-docs", "/actuator/health", "/api/1.0/customers/Ravi"]


def c_scope(t):
    ok("requests until the first refusal: 6" in t, "the address's bucket emptied")
    g = dict(re.findall(r"^  scope \| GET (\S+) -> (\d{3})$", t, re.M))
    for p in SCOPE_API: ok(g.get(p) == "429", "GET %s -> 429 (the address's bucket, not the route's)" % p)
    for p in SCOPE_OUT: ok(g.get(p) not in (None, "429"), "GET %s -> %s (outside /api/v1/*: never counted)" % (p, g.get(p)))
    ok(grab(t, r"with a key \(KEYPOST.*?\) -> (\d{3})") == "429", "the keyed POST -> 429 (the limiter first)")
    for m in ("HEAD", "OPTIONS", "PATCH"): ok(grab(t, r"^  scope \| %s \S+ -> (\d{3})$" % m) == "429", "%s on an /api/v1/ path -> 429" % m)
    finish(" ".join("%s=%s" % (p, g.get(p)) for p in SCOPE_API + SCOPE_OUT))


def c_twojvm(t):
    ok(t.count('The following 1 profile is active: "dev"') == 2, "both JVMs under the profile dev")
    ok(len(re.findall(r"^  dev-[ab] \| The following 1 profile is active: \"dev\" · rate limit: capacity 5 per refill period <period>, the buckets in Redis \(tiffinbox:api-rate:\*, through RedisClient of LettuceConnectionFactory\)$", t, re.M)) == 2, "both: the buckets in Redis through Boot's LettuceConnectionFactory's client")
    seq = grab(t, r"the sequence \(A = 21080, B = 21085\): (.*)$")
    ok(seq == "A200 A200 A200 B200 B200 B429 A429", "two JVMs, one bucket: %s" % seq)
    ok(grab(t, r"the keys under tiffinbox:api-rate:\* \(--scan, inside the container\): (\S+) ·") == "tiffinbox:api-rate:127.0.0.1", "one key, tiffinbox:api-rate:127.0.0.1")
    ok(re.search(r"tiffinbox:api-rate:127\.0\.0\.1: TYPE string · STRLEN \d+ · PTTL positive: yes", t) is not None, "the key: a string, its PTTL positive")
    rb = grab(t, r"rows before the keyed POST: (\d+)"); ra = grab(t, r"idempotency_key rows after: (\d+)")
    ok(rb is not None and rb == ra and grab(t, r"on B after the refusal -> (\d{3})") == "429", "the refused keyed POST wrote no key row on PostgreSQL (%s -> %s)" % (rb, ra))
    ok(grab(t, r"the six replies: (.*?) ·") == "1 2 3 4 5 6" and grab(t, r" · GET (\d+) · TTL") == "6" and "TTL positive: yes" in t, "Course 8's counter: 1 2 3 4 5 6, GET 6, a TTL")
    ok("FLUSHALL before the leg: OK · keys 0" in t, "Redis emptied before the leg")
    finish("seq=%s key=tiffinbox:api-rate:127.0.0.1 strlen=%s lua=1-6 rows=%s->%s" % (seq, grab(t, r"STRLEN (\d+)"), rb, ra))


def c_defaults(t):
    d = re.search(r"default \| tiffinbox-web tests (\d+) failures (\d+) errors (\d+) skipped (\d+)", t)
    ok(d is not None and d.group(2) == d.group(3) == d.group(4) == "0", "the web suite at the default: %s" % (d.group(0) if d else "absent"))
    ok(grab(t, r"outside RateLimitFilterTest \(its own capacity of three\): (\d+)") == "0", "the default: 0 refusals in the suite outside RateLimitFilterTest's own context")
    ctx = grab(t, r"the settings' start lines \(one per test context\): (\d+)")
    p = re.search(r"plant \(cap 5\) \| tiffinbox-web tests (\d+) failures (\d+) errors (\d+) skipped (\d+) · failing classes (\d+) (.*)$", t, re.M)
    ok(p is not None and int(p.group(2)) + int(p.group(3)) > 0, "the plant at 5 is red: %s" % (p.group(0) if p else "absent"))
    ok(grab(t, r"plant \| the build's exit: (\d+)") not in (None, "0"), "the plant's build exits non-zero (a green plant is a FAIL)")
    pr = grab(t, r"plant \| .*?refusal lines in its log, by class: (.*)$")
    finish("tests=%s refusals_default=0 contexts=%s plant_failures=%s plant_classes=%s %s plant_refusals=%s" % (d.group(1) if d else "", ctx, p.group(2) if p else "", p.group(5) if p else "", p.group(6).replace(" ", ",") if p else "", (pr or "").replace(" ", ",")))


def c_spec(t):
    ok("(servers removed, json.dump indent 2, ensure_ascii False, a final newline): equal" in t, "the served spec = the committed file")
    ok("byte-equal: yes" in t, "the committed file unchanged by this unit")
    ok("the operations' ids before -> after: equal" in t, "the operations' ids equal")
    ok("ops9s3.py on an empty spec: exit 1" in t, "ops9s3.py refuses an empty spec")
    ok(grab(t, r"the served document's 429 responses: (\d+)") == "0", "no operation documents the refusal")
    ok(re.search(r"OpenApiSpecTest on the committed file: tests 1 failures 0 errors 0", t) is not None, "OpenApiSpecTest passes")
    ok("tiffinbox-client byte-equal before -> after/: yes" in t, "the client untouched")
    finish("spec=%s ops=%s" % (grab(t, r"bytes before (\d+)"), grab(t, r"before: (.*?) · after:")))


def c_moved(t):
    b = re.findall(r"^  before \| (.*)$", t, re.M); a = re.findall(r"^  after \| (.*)$", t, re.M)
    b = [x for x in b if not x.startswith("requests sent")]; a = [x for x in a if not x.startswith("requests sent")]
    mv = [x for x, y in zip(b, a) if x != y]
    ok(len(b) == len(a) and len(b) > 30, "U18's list on both trees (%d requests each)" % len(b))
    ok(not mv, "moved lines: %d" % len(mv))
    for x in mv: OUT.append("note moved: " + x)
    j = re.search(r"jar \| the web jar's entries: added (\d+) (\[.*?\]) · removed (\d+) · shared entries whose CRC moved (\d+) (\[.*?\])", t)
    ok(j is not None and j.group(3) == "0", "the jar: added %s, removed %s, moved %s" % (j.group(1), j.group(3), j.group(4)) if j else "the jar line")
    lib = re.search(r"BOOT-INF/lib names: before (\d+) · after (\d+) · added: (.*?) · removed: (\d+)", t)
    finish("moved=%d jar_added=%s jar_moved=%s lib=%s->%s" % (len(mv), j.group(1) if j else "", j.group(5) if j else "", lib.group(1) if lib else "", lib.group(2) if lib else ""))


def c_api(t):
    ok(re.search(r"api \| before -> after/: byte-identical \((\d+) requests each\)", t) is not None, "the /api/v1/ census byte-identical on before and after/")
    finish("api=%s" % grab(t, r"byte-identical \((\d+) requests each\)"))


def c_seven(t):
    e = grab(t, r"expected ([0-9a-f]{32})"); b = grab(t, r"before: the seven ([0-9a-f]{32})"); a = grab(t, r"after: the seven ([0-9a-f]{32})")
    ok(e is not None and b == e and a == e, "the seven = %s on both" % e)
    finish("seven=%s" % (e or "")[:8])


def c_surface(t):
    e = grab(t, r"expected ([0-9a-f]{32})"); b = grab(t, r"before: the old surface ([0-9a-f]{32})"); a = grab(t, r"after: the old surface ([0-9a-f]{32})")
    ok(e is not None and b == e and a == e, "the old surface = %s on both" % e)
    finish("surface=%s" % (e or "")[:8])


def c_tests(t):
    ok("mvn package exit 0" in t, "package exit 0")
    w = re.search(r"package \| tiffinbox-web \| tests (\d+) failures 0 errors 0 skipped 0", t)
    ok(w is not None, "package: the web module green, 0 skipped")
    ok(re.search(r"package \| tiffinbox-client \| tests 1 failures 0 errors 0 skipped 0", t) is not None, "the client: 1 test")
    rl = re.search(r"class RateLimitFilterTest \| tests (\d+) failures 0 errors 0 skipped 0", t)
    ok(rl is not None, "RateLimitFilterTest green")
    wb = grab(t, r"web tests before \(unit 18's values block\): (\d+)")
    ok(w is not None and rl is not None and wb is not None and int(w.group(1)) == int(wb) + int(rl.group(1)), "web %s = unit 18's %s + RateLimitFilterTest's %s" % (w.group(1) if w else "", wb, rl.group(1) if rl else ""))
    ok("disabling or conditional annotations 0 · ports or sockets (string literals removed) 0" in t, "the test class: no disabling annotation, no port")
    ok(re.search(r"test files moved before -> after:  · new: RateLimitFilterTest.java", t) is not None, "no existing test file moved; one new")
    tw = re.search(r"twin \| tiffinbox-web \| tests (\d+) failures 0 errors 0 skipped 0", t)
    ok(tw is not None and w is not None and tw.group(1) == w.group(1), "the Docker-free twin: the same counts")
    v = re.search(r"verify exit 0 · ITs tests (\d+) failures 0 errors 0 · classes (\d+)", t)
    ok(v is not None and v.group(1) == "14" and v.group(2) == "5", "verify: %s" % (v.group(0) if v else "absent"))
    ok(re.search(r"IT bindings: \d+ lines · not 127\.0\.0\.1: 0", t) is not None, "IT bindings: all 127.0.0.1")
    ok("Testcontainers containers after: 0 · images pulled: 0" in t, "no container left, nothing pulled")
    wo = re.search(r"webonly \| tiffinbox-web \| tests (\d+) failures 0 errors 0 skipped 0", t)
    ok(wo is not None and w is not None and wo.group(1) == w.group(1), "the web-only form: the same counts")
    ok("downloads across the builds: 0" in t, "0 downloads")
    lib = re.search(r"BOOT-INF/lib: before (\d+) · after (\d+) · added (.*?) · removed (\d+)", t)
    ok(lib is not None and lib.group(4) == "0", "BOOT-INF/lib: 0 removed")
    finish("web=%s client=1 ratelimit=%s its=%s lib=%s->%s added=%s" % (w.group(1) if w else "", rl.group(1) if rl else "", v.group(1) if v else "", lib.group(1) if lib else "", lib.group(2) if lib else "", (lib.group(3) if lib else "").replace(" ", ",")))


def c_harness(t):
    ok("harness/: chk19.py dur9.py ops9s3.py s919.py tree19.py · exercise/: README.md SOLUTION.md apply.sh break.sh check.sh · harness Java files: 0" in t, "the folder's files exactly")
    ok("presign/ src/ - 0 present" in t, "no earlier instrument")
    ok(re.search(r"a byte appended to after/compose\.yaml .*?: exit 1 · a FAIL names it: [1-9]", t) is not None, "static on a scratch copy moved by one byte: exit 1")
    ok("reading the live anchor (its folder name assembled) -> exit 1 · the same path from two pieces -> exit 1" in t, "flag 31's two plants exit 1")
    finish("static=%s" % grab(t, r"as written: output md5 ([0-9a-f]{32})"))


def c_exercise(t):
    for sh in ("bash", "zsh"):
        bl = "\n".join(re.findall(r"^  broken %s \| (.*)$" % sh, t, re.M)); sl = "\n".join(re.findall(r"^  solved %s \| (.*)$" % sh, t, re.M))
        ok("check exit 1" in bl and "FAIL (2) a forged X-Api-Key after the 429 answered 200, 200" in bl, "broken, %s: FAIL on clause 2 (the forged key answered 200, 200)" % sh)
        ok("check exit 0" in sl and "\nPASS" in "\n" + sl, "solved, %s: PASS" % sh)
    for v in ("trustxff", "headerlast", "fixedelsewhere"):
        l = "\n".join(re.findall(r"^  ~ %s bash \| (.*)$" % v, t, re.M))
        if l: ok("check exit 1" in l, "refused variant %s: exit 1" % v)
    finish("broken=FAIL solved=PASS")


def c_inert(t):
    ok(grab(t, r"keyed requests in this run's captures: (\d+)") == "2", "two keyed requests, both named")
    finish("keyed=2")


CHECKS = {"advisory": c_advisory, "before": c_before, "change": c_change, "census": c_census, "limit": c_limit, "forge": c_forge,
          "refill": c_refill, "scope": c_scope, "twojvm": c_twojvm, "defaults": c_defaults, "spec": c_spec, "moved": c_moved, "api": c_api,
          "seven": c_seven, "surface": c_surface, "tests": c_tests, "harness": c_harness, "exercise": c_exercise, "inert": c_inert}

PLANTS = [("limit", r"(  limit #6 \| .*?) -> 429 ", r"\1 -> 200 ", "a status list one off"),
          ("limit", r"a charset other than UTF-8: no", "a charset other than UTF-8: yes", "charset=ISO-8859-1 on the refusal (the probe's form)"),
          ("limit", r"Retry-After: <n> \(an integer: yes\)", "Retry-After: <n> (an integer: no)", "Retry-After not an integer"),
          ("limit", r"type tag:tiffinbox\.example,2026:rate-limited", "type tag:tiffinbox.example,2026:limited", "the body's type altered"),
          ("forge", r"(  anchor X-Api-Key forged-1 \| .*?) -> 429 ", r"\1 -> 200 ", "the anchor's forged header typed 200"),
          ("forge", r"(  copy \(a made-up key\) X-Api-Key forged-1 \| .*?) -> 200 ", r"\1 -> 429 ", "the made-up key typed 429"),
          ("refill", r"the first request after the wait: 200", "the first request after the wait: 429", "the first post-wait request typed 429"),
          ("scope", r"GET /revenue -> \d{3}", "GET /revenue -> 429", "an old route typed 429"),
          ("scope", r"GET /api/v1/nosuch/route -> 429", "GET /api/v1/nosuch/route -> 404", "the unknown route typed 404 after the bucket is empty"),
          ("twojvm", r"the six replies: 1 2 3 4 5 6", "the six replies: 1 2 3 4 5 7", "the Lua replies typed 1 2 3 4 5 7"),
          ("twojvm", r"B200 B200 B429", "B200 B200 B200", "the second JVM's refusal changed"),
          ("twojvm", r"PTTL positive: yes", "PTTL positive: no", "the key's PTTL not positive"),
          ("defaults", r"plant \| the build's exit: \d+", "plant | the build's exit: 0", "the plant's build green"),
          ("defaults", r"\(its own capacity of three\): 0", "(its own capacity of three): 1", "a refusal typed at the default"),
          ("spec", r"a final newline\): equal", "a final newline): differ", "the committed file touched"),
          ("seven", r"after: the seven ([0-9a-f]{31})[0-9a-f]", r"after: the seven \g<1>0", "the seven's md5 one character off"),
          ("tests", r"(package \| tiffinbox-web \| tests \d+ failures 0 errors 0) skipped 0", r"\1 skipped 1", "Skipped typed 1"),
          ("exercise", r"(  solved bash \| )check exit 0", r"\1check exit 1", "solution = broken"),
          ("advisory", r"run date (\S+)", "run date 2026-11-28", "the read one day older than the run")]


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
    r = subprocess.run([sys.executable, "-I", "-B", __file__, "limit", "-"], input="  limit #1 | garbage line\n", capture_output=True, text=True)
    ok(r.returncode == 1 and "Traceback" not in r.stderr, "plant an unparseable listing: a FAIL line, exit 1, no traceback")
    for l in OUT: print(l)
    print("VALUES plants=%d" % (n + 1))
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
        ok(sum(1 for l in r if l.startswith("A token bucket:")) == 1, "exactly one line starts A token bucket:")
        ok(sum(1 for l in r if l == GLOSS) == 1, "the gloss line byte for byte")
        for g in ("A cursor:", "A sparse fieldset:", "A link relation:", "`HAL`:", "A status resource:", "A presigned URL:", "A version carrier:", "A snippet:", "A contract:", "Swagger UI:", "A problem type:", "Code generation:"):
            ok(not any(l.startswith(g) for l in r), "no second gloss line (%s)" % g)
        finish(None)
    elif cmd == "gloss-line":
        print(GLOSS)
    elif cmd == "hook":
        print(hook())
    elif cmd == "exq":
        print(exq())
    elif cmd == "interleaved":
        b = brief(); hs = re.findall(r'^\*\*Hook \(\[S4 §\d+\]\):\*\* "([^"]+)"', b, re.M); es = re.findall(r'^\*\*Exercise:\*\* "(Your turn: [^"]+)"', b, re.M)
        if len(hs) != 6 or len(es) != 6: print("the extractor found %d hooks and %d exercises, not 6 + 6" % (len(hs), len(es))); sys.exit(1)
        il = "\n".join(x for p in zip(hs, es) for x in p) + "\n"
        print("the brief's hooks and exercises: %d + %d (R.534), the interleaved list's md5 %s (a new pin: S4B pins none)" % (len(hs), len(es), md5(il.encode())))
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
