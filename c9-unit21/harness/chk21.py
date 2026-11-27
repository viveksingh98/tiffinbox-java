"""Course 9 unit 21's checks (python3 -I -B harness/chk21.py SUBCOMMAND ...), run from c9-unit21/.

Each capture's check reads the masked capture file the receipt wrote (.r-NAME.new) and prints "ok ..." or "FAIL ..." lines and one
"VALUES ..." line; any FAIL exits 1 (a line it cannot parse is a FAIL line, exit 1, never a traceback). `static` reads only this unit's
frozen after/, before (the link to ../c9-unit20/after) and git objects of unit 20's commit (f73a7c3:c9-unit20/after/...) - never the live
anchor: an audit hook refuses any open() whose real path lies in the live anchor's folder, so a static read of it exits 1 (flag 18).
Subcommands: static AFTER BEFORE · static-plant live|pieces · gloss README · hook · exq · title-line · interleaved · hashable NAME FILE ·
values README VALS · plants DIR · and one per capture: advisory before change census factory timeout retry mock resilience4j spec moved
api seven surface tests harness exercise inert title.
"""
import hashlib, os, re, subprocess, sys

ANCHOR_DIR = "/c9-" + "tiffinbox"   # LIVE_ANCHOR_PLANT: the live anchor's folder name, assembled so a grep for it finds only this line


def _guard(event, args):
    if event == "open" and args and isinstance(args[0], (str, bytes, os.PathLike)):
        p = os.path.realpath(os.fsdecode(args[0]))
        if (ANCHOR_DIR + "/") in p or p.endswith(ANCHOR_DIR):
            raise SystemExit("FAIL flag 18: a static check read the live anchor (%s)" % p)


H20 = "f73a7c3"
LEFT_OUT = ["shallow", "paths", "weak", "deep", "ifmatch", "cache", "chrome", "moving", "identity", "metrics", "limiter", "limit", "forge",
            "xff", "refill", "scope", "twojvm", "lua", "defaults", "restart", "proxy", "declared", "signed", "presign", "sealed", "expect",
            "specwire", "blob", "bills", "poll", "accept", "callpg", "html", "walk", "pageable", "trap", "table", "first", "next"]
GLOSSES = ["A precondition:", "A token bucket:", "A cursor:", "A sparse fieldset:", "A link relation:", "`HAL`:", "A status resource:",
           "A presigned URL:", "A version carrier:", "A snippet:", "A contract:", "Swagger UI:", "A problem type:", "Code generation:",
           "A read timeout:", "A retry:", "An ETag:", "A validator:"]
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


CT = "tiffinbox-client/src/test/java/com/tiffinbox/client/"
EXPECTED_CHANGED = ["A " + CT + "PaymentCaller.java", "A " + CT + "PaymentRetryTest.java", "A " + CT + "Payments.java", "M README.md"]
BYTE_EQUAL = ["Dockerfile", "compose.yaml", "pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-core/pom.xml", "tiffinbox-client/pom.xml",
              CT + "TiffinBoxClientTest.java", "tiffinbox-web/src/main/resources/application.yaml",
              "tiffinbox-web/src/main/resources/application-dev.yaml", "tiffinbox-web/src/test/resources/openapi/tiffinbox.json",
              "tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerReads.java", "tiffinbox-web/src/main/java/com/tiffinbox/web/IdempotencyKeys.java"]


def walk(r):
    out = {}
    for d, ds, fs in os.walk(r):
        for f in fs:
            p = os.path.join(d, f); out[os.path.relpath(p, r)] = md5(open(p, "rb").read())
    return out


def gitobj(rel):
    top = os.environ.get("REPO") or subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True).stdout.strip()
    r = subprocess.run(["git", "-C", top, "show", "%s:c9-unit20/after/%s" % (H20, rel)], capture_output=True)
    return r.stdout if r.returncode == 0 else None


def static(a, b):
    sys.addaudithook(_guard)
    A, Bt = walk(a), walk(b)
    ch = sorted(["A " + k for k in A if k not in Bt] + ["D " + k for k in Bt if k not in A] + ["M " + k for k in A if k in Bt and A[k] != Bt[k]])
    ok(ch == sorted(EXPECTED_CHANGED), "the changed set (after/ against before, derived) is flag 2's: %s" % " · ".join(ch))
    for rel in BYTE_EQUAL:
        g = gitobj(rel)
        ok(g is not None and md5(g) == A.get(rel), "%s byte-equal to git show %s:c9-unit20/after/%s" % (rel, H20, rel))
    sm = [k for k in A if "/src/main/" in k and A[k] != Bt.get(k)] + [k for k in Bt if "/src/main/" in k and k not in A]
    ok(not sm, "no src/main path of any module changed (%d)" % len(sm))
    ok(not [k for k in ch if k.endswith("pom.xml")], "no pom changed")
    ok(not [k for k in ch if k.startswith(("tiffinbox-web/", "tiffinbox-core/"))], "nothing under tiffinbox-web/ or tiffinbox-core/ changed")
    for k in sorted(Bt):
        if "/src/test/" in k and k in A and A[k] != Bt[k]: ok(False, "an existing test file was edited: " + k)
    ok(True, "every existing test file byte-equal to before's (%d files)" % sum(1 for k in Bt if "/src/test/" in k))
    cl = [k for k in A if k.startswith("tiffinbox-client/") and "Idempotency-Key" in open(os.path.join(a, k), encoding="utf-8", errors="replace").read()]
    ok(cl == [CT + "Payments.java"], "the interface is the only client file naming Idempotency-Key (%s)" % cl)
    every = ""
    for k in sorted(A):
        if k.endswith((".java", ".xml", ".yaml", ".md", ".json")): every += open(os.path.join(a, k), encoding="utf-8", errors="replace").read()
    ok("ClientHttpRequestInterceptor" not in every, "no interceptor anywhere in after/ (D1)")
    ok(re.search(r"resilience4j", every, re.I) is None, "no file of after/ names resilience4j (C4)")
    main = "".join(open(os.path.join(a, k), encoding="utf-8").read() for k in A if "/src/main/" in k and k.endswith(".java"))
    ok("EnableResilientMethods" not in main and "@Retryable" not in main, "@EnableResilientMethods and @Retryable in no src/main file")
    new = {n: open(os.path.join(a, CT + n), encoding="utf-8").read() for n in ("Payments.java", "PaymentCaller.java", "PaymentRetryTest.java")}
    ok(not any(re.search(r"Probe|probe\.|BLUE|/probe/", v) for v in new.values()), "no probe or BLUE name in a shipped file")
    t = new["PaymentRetryTest.java"]
    ok(re.search(r"@(org\.junit\.jupiter\.api\.(condition\.)?)?(Disabled|EnabledIf|DisabledIf|EnabledOn|DisabledOn|EnabledFor|DisabledFor)\w*", t) is None, "PaymentRetryTest: no disabling or conditional annotation, simple or fully qualified")
    tc = re.sub(r'"[^"\n]*"', '""', t)
    ok(re.search(r"RANDOM_PORT|DEFINED_PORT|LocalServerPort|\bSocket\b|Thread\.sleep|(?<![\d.])\d{4,5}(?![\d.])", tc) is None, "PaymentRetryTest: no port, no socket, no sleep, no 4-5 digit literal outside a string")
    ok("MockRestServiceServer.bindTo(builder)" in t and "times(3)" in t and "server.verify()" in t, "PaymentRetryTest: bindTo(builder), times(3), verify()")
    c = new["PaymentCaller.java"]
    ok("@Retryable(maxRetries = 2, delay = 10, includes = {ResourceAccessException.class, HttpServerErrorException.class})" in c, "the caller: the narrow includes, maxRetries 2 (C2 (a))")
    ok("public Payments.Payment pay(String key, Payments.Charge charge)" in c and "return payments.pay(key, charge);" in c, "the caller: the key a parameter, sent as given (C1 (a))")
    p = new["Payments.java"]
    ok('@HttpExchange("/payments")' in p and 'Payment pay(@RequestHeader("Idempotency-Key") String key, @RequestBody Charge charge);' in p, "the interface: Course 6's shape plus the one header parameter")
    readme = open(os.path.join(a, "README.md"), encoding="utf-8").read()
    card = readme.split("## Course 9 · unit 21", 1)
    ok(len(card) == 2, "the anchor README has a unit 21 card")
    if len(card) == 2:
        body = card[1].split("\n## ", 1)[0]
        bad = [l for l in body.splitlines() if re.search(r"(?<![\d.,])85(?![\d.,])", l) and "unit 20" not in l]
        ok(not bad, "the card gives 85 as unit 20's count only (%d lines otherwise)" % len(bad))
        ok("are 5 (1 at unit 20)" in body, "the card gives the client's 1 as unit 20's count")
    ok("Course 9's seventeenth change to this folder (U21)" in readme, "the header note names the seventeenth change")
    me = open(__file__, encoding="utf-8").read()
    subs = set(re.findall(r'^    elif cmd == "([a-z0-9-]+)"', me, re.M)) | set(re.findall(r'^    if cmd == "([a-z0-9-]+)"', me, re.M)) | set(CHECKS)
    ok(not (subs & set(LEFT_OUT)), "no left-out subcommand in chk21.py (%s)" % sorted(subs & set(LEFT_OUT)))
    finish(None)


def brief():
    c9 = os.environ.get("C9R") or ""
    return open(os.path.join(c9, "_briefs/UNIT-BRIEFS-S4-OPERATING.md"), encoding="utf-8").read()


def unit21(): return brief().split("\n## Unit 21", 1)[1].split("\n## Unit 22", 1)[0]


def hook(): return re.search(r'^\*\*Hook \(\[S4 §\d+\]\):\*\* "([^"]+)"', unit21(), re.M).group(1)


def exq(): return re.search(r'^\*\*Exercise:\*\* "(Your turn: [^"]+)"', unit21(), re.M).group(1)


def title(): return re.search(r'^\*\*Title for search:\*\* "([^"]+)"', unit21(), re.M).group(1)


# ---- capture checks ----------------------------------------------------------------------------------------------------------------
def budget(t):
    for m in re.finditer(r"^  budget \| (\S+): requests under /api/v1/ \(its access log\): (\d+) · refusal lines: (\d+)", t, re.M):
        ok(int(m.group(2)) <= BUDGET and m.group(3) == "0", "N11: %s sent %s /api/v1/ requests (<= %d), refusals %s" % (m.group(1), m.group(2), BUDGET, m.group(3)))
    return max([int(x) for x in re.findall(r"requests under /api/v1/ \(its access log\): (\d+)", t)] or [0])


def probe(t, lab):
    return [l for l in re.findall(r"^  %s \| PROBE21 (.*)$" % re.escape(lab), t, re.M)]


def stubsum(t, lab):
    m = re.search(r"^  %s stub \| POST /payments (\d+) · with the key header (\d+) · distinct keys (\d+) · 201 answers (\d+) · GET /payments/slow (\d+) · GET /status/404 (\d+)$" % re.escape(lab), t, re.M)
    if not m: raise ValueError("no stub summary for %s" % lab)
    return [int(x) for x in m.groups()]


def c_advisory(t):
    fa = grab(t, r"fetched-at (\S+) \(the hour masked\) · run date (\S+)")
    rd = grab(t, r"run date (\S+) ·")
    ok(fa is not None and fa == rd, "the read is the batch day's (fetched-at %s = run date %s)" % (fa, rd))
    for m in re.finditer(r"(\S+)/MD5SUMS.txt: (\d+) lines, (\d+) verified", t): ok(m.group(2) == m.group(3) and int(m.group(2)) > 0, "%s: %s of %s verified" % (m.group(1), m.group(3), m.group(2)))
    ok(len(re.findall(r"MD5SUMS.txt: \d+ lines", t)) == 2, "both of the day's MD5SUMS.txt read")
    ok("tomcat page md5 a1a756d985225fb5143eefd9aae3183c " in t, "Tomcat's page = the earlier reads")
    o = re.search(r"(\d+) coordinates queried, (\d+) results, (\d+) with vulns", t)
    ok(o is not None and o.group(3) == "0", "OSV: %s" % (o.group(0) if o else "absent"))
    lib = re.search(r"lib names before (\d+) · after (\d+) · by name: (\w+) · tiffinbox-client/pom.xml byte-equal: (\w+)", t)
    ok(lib is not None and lib.group(1) == lib.group(2) == "167" and lib.group(3) == "equal" and lib.group(4) == "yes", "BOOT-INF/lib 167 = 167 by name; the client pom byte-equal")
    ok("shipped | spring-context 7.0.11" in t and "shipped | spring-boot 4.1.3" in t and "shipped | tomcat-embed-core 11.0.29" in t, "the pins: Boot 4.1.3, Framework 7.0.11, Tomcat 11.0.29")
    ok("verdict: no pin affected; evidence may proceed" in t, "the verdict")
    finish("fetched=%s lib=%s->%s" % (fa, lib.group(1) if lib else "", lib.group(2) if lib else ""))


def c_before(t):
    m = re.search(r"before \| the client's test class path .*?: (\d+) jars · httpclient5 (\d+) · (.*)$", t, re.M)
    ok(m is not None and m.group(2) == "0", "before: the client module's test class path holds no httpclient5 (%s jars)" % (m.group(1) if m else "?"))
    ok(m is not None and all(x in m.group(3) for x in ("spring-boot-restclient-4.1.3.jar", "spring-boot-restclient-test-4.1.3.jar", "spring-test-7.0.11.jar")), "before: restclient 4.1.3, restclient-test 4.1.3, spring-test 7.0.11 on it")
    ok(re.search(r"before \| tiffinbox-client \| tests 1 failures 0 errors 0 skipped 0", t) is not None, "before: the client's one test green")
    pr = probe(t, "before-factory")
    ok(any("factory org.springframework.http.client.JdkClientHttpRequestFactory" in l for l in pr), "before: the builder's factory is JdkClientHttpRequestFactory")
    ok(any("httpclient5 on the class path: false" in l for l in pr), "before: no HttpClient 5 seen by the caller")
    ok("before | the committed spec: operations 21 · paths 19" in t or re.search(r"before \| the committed spec: .*21.*19", t) is not None, "before: the spec's 21 / 19")
    ok("36164 B md5 aa8cb98f4ff16d75d073026f0c618328" in t, "before: the spec 36,164 B aa8cb98f")
    ok(grab(t, r"BOOT-INF/lib names (\d+)") == "167", "before: BOOT-INF/lib 167")
    ok("web=85" in t and "client=1" in t and "its=14" in t, "before: U20's web 85, client 1, ITs 14")
    finish("client_cp=%s httpclient5=0 factory=JdkClientHttpRequestFactory client=1 lib=%s" % (m.group(1) if m else "", grab(t, r"BOOT-INF/lib names (\d+)")))


def c_change(t):
    ch = grab(t, r"changed \(derived: .*?\): (.*)$")
    got = sorted((ch or "").split(" · "))
    ok(got == sorted(EXPECTED_CHANGED), "the derived changed list is flag 2's (%d paths)" % len(got))
    ok(re.search(r"modules: tiffinbox-core tiffinbox-web tiffinbox-client \(3\) -> tiffinbox-core tiffinbox-web tiffinbox-client \(3\)", t) is not None, "three modules -> three")
    ok("files naming Idempotency-Key in tiffinbox-client 1 (Payments.java)" in t, "one client file names the key header: the interface")
    ok("ClientHttpRequestInterceptor 0 · resilience4j (any case) 0 · @EnableResilientMethods in src/main 0 · Probe/probe./BLUE in the new files 0" in t, "no interceptor, no resilience4j, nothing in src/main, no probe name")
    ok(not re.search(r"byte-equal to before's: no", t), "the listed files byte-equal to before's")
    ok("src/main of every module byte-equal to before's: yes" in t and "tiffinbox-web/ and tiffinbox-core/ byte-equal: yes" in t, "src/main, web and core untouched")
    ok(re.search(r"the client's test class path before -> after \(by name\): (\w+) -> \1 · added 0 · removed 0", t) is not None, "the client's test class path unchanged by name")
    g = re.search(r"the generated client \(after/'s build\): (\d+) files \(.java (\d+)\) · added 0 · removed 0 · moved 0", t)
    ok(g is not None, "the generated client: 0 added, 0 removed, 0 moved")
    ok("ApiApi.add1's parameters (the generated source): String name, Integer days · @RequestHeader in ApiApi: 0" in t, "ApiApi.add1 has no key parameter (name, days; no @RequestHeader)")
    ok("lines naming httpclient5 0 · resilience4j 0 · micrometer" in t, "the client's dependency tree: no httpclient5, no resilience4j")
    ok("Payment pay(@RequestBody Charge charge); -> this unit Payment pay(@RequestHeader(\"Idempotency-Key\") String key, @RequestBody Charge charge);" in t, "the one parameter added to Course 6's signature")
    finish("changed=%d generated=%s/%s cp=unchanged" % (len(got), g.group(1) if g else "", g.group(2) if g else ""))


def c_census(t):
    b = grab(t, r"census before \| controllers (.*)$"); a = grab(t, r"census after \| controllers (.*)$")
    ok(b is not None and a == b, "the census before = after: %s" % b)
    sb = grab(t, r"the spec's counts .*?before (.*?) · after"); sa = grab(t, r"the spec's counts .*? · after (.*)$")
    ok(sb is not None and sb == sa, "the spec's counts equal: %s" % sb)
    nums = re.findall(r"\d+", b or "")
    finish("census=%s" % "/".join(nums[:4]) if len(nums) >= 4 else "census=")


def c_factory(t):
    m = probe(t, "factory-module"); h = probe(t, "factory-hc5")
    ok(any("factory org.springframework.http.client.JdkClientHttpRequestFactory" in l for l in m), "the module's class path: JdkClientHttpRequestFactory")
    ok(any("httpclient5 on the class path: false" in l for l in m), "the module's class path: no HttpClient 5")
    ok(any("factory org.springframework.http.client.HttpComponentsClientHttpRequestFactory" in l for l in h), "the harness's HttpClient 5 class path: HttpComponentsClientHttpRequestFactory (labelled)")
    ok(any("httpclient5 on the class path: true" in l for l in h), "the harness's HttpClient 5 class path: HttpClient 5 present")
    ok(any("builder org.springframework.web.client.DefaultRestClientBuilder" in l for l in m), "the builder bean: DefaultRestClientBuilder")
    um = grab(t, r"^  factory-module stub \| GET /status/200 -> 200 · headers \[[^]]*\] · user-agent (\S+)")
    uh = grab(t, r"^  factory-hc5 stub \| GET /status/200 -> 200 · headers \[[^]]*\] · user-agent (\S+)")
    ok(um is not None and um.startswith("Java-http-client/"), "the module's User-Agent at the stub: %s" % um)
    ok(uh is not None and uh.startswith("Apache-HttpClient/"), "the HttpClient 5 User-Agent at the stub: %s" % uh)
    hm = grab(t, r"^  factory-module stub \| GET /status/200 -> 200 · headers \[([^]]*)\]")
    ok(hm is not None and "Upgrade" in hm and "Http2-settings" in hm, "the JDK client's request offers an upgrade (Upgrade, Http2-settings)")
    cp = re.search(r"class paths \| the module's: (\d+) jars, httpclient5 (\d+)", t)
    ok(cp is not None and cp.group(2) == "0", "the module's class path: httpclient5 0")
    ok(re.search(r"the web jar's BOOT-INF/lib: httpclient5-5\.6\.5\.jar \(the web module's", t) is not None, "the web module's class path has HttpClient 5 (D3)")
    finish("module=JdkClientHttpRequestFactory ua_module=%s hc5=HttpComponentsClientHttpRequestFactory ua_hc5=%s cp=%s" % (um, uh, cp.group(1) if cp else ""))


def c_timeout(t):
    n = probe(t, "timeout-none"); m = probe(t, "timeout-module"); h = probe(t, "timeout-hc5")
    ok(any("setting spring.http.clients.read-timeout = absent" in l for l in n), "no read timeout: the setting absent on the caller's start line")
    ok(any("defaultValue present: false" in l for l in n), "the metadata's entry for spring.http.clients.read-timeout has no default")
    ok(any(l == 'timeout: GET /slow -> 200 {"slow":true} · returned no earlier than the stub\'s delay: true' for l in n), "no read timeout: 200 {\"slow\":true} after the stub's whole delay (true)")
    ok(any("setting spring.http.clients.read-timeout = <set>" in l for l in m), "1 s: the run flag read back on the caller's start line")
    ok(any(re.fullmatch(r'timeout: GET /slow -> org\.springframework\.web\.client\.ResourceAccessException: I/O error on GET request for "http://127\.0\.0\.1:<stub>/slow": Request cancelled', l) for l in m), "the module's class path: ResourceAccessException ... Request cancelled")
    ok(any(l.startswith("timeout root -> java.net.http.HttpTimeoutException: Request cancelled · returned no earlier than the stub's delay: false") for l in m), "the module's class path: root java.net.http.HttpTimeoutException (the caller gave up before the delay)")
    ok(any(re.fullmatch(r'timeout: GET /slow -> org\.springframework\.web\.client\.ResourceAccessException: I/O error on GET request for "http://127\.0\.0\.1:<stub>/slow": Read timed out', l) for l in h), "the HttpClient 5 class path: Read timed out (labelled)")
    ok(any(l.startswith("timeout root -> java.net.SocketTimeoutException: Read timed out") for l in h), "the HttpClient 5 class path: root java.net.SocketTimeoutException")
    ok(re.search(r"^  timeout-module stub \| GET /slow\?ms=<ms> -> no answer written", t, re.M) is not None, "the stub saw the request; the caller had given up before the stub's answer (none written when the stub was stopped)")
    ok(re.search(r"^  timeout-none stub \| GET /slow\?ms=<ms> -> 200", t, re.M) is not None, "no read timeout: the stub wrote its 200")
    finish("none=200_waited module=Request_cancelled/HttpTimeoutException hc5=Read_timed_out/SocketTimeoutException default=absent")


def c_retry(t):
    ids = lambda lab: re.findall(r"^  %s \| PROBE21 POST /payments -> 201 · payment (pay-\d+) · PAID$" % re.escape(lab), t, re.M)
    s1 = stubsum(t, "retry-onekey"); i1 = ids("retry-onekey")
    ok(s1[0] == 3 and s1[1] == 3 and s1[2] == 1 and s1[3] == 3, "one key: 3 POSTs at the stub, the key on each, 1 distinct key, 3 x 201 (%s)" % s1[:4])
    ok(i1 == ["pay-1", "pay-2", "pay-3"], "one key: the stub made three payments %s (it honours no key)" % i1)
    l1 = grab(t, r"^  retry-onekey \| PROBE21 retry payment 1: (.*)$")
    ok(l1 == "after 3 attempts -> org.springframework.web.client.ResourceAccessException · root java.net.http.HttpTimeoutException: Request cancelled", "one key: 3 attempts, then the harness's lost reply's root (%s)" % l1)
    ok(s1[4] == 3, "one key: the harness's lost reply - GET /payments/slow after each POST (%d)" % s1[4])
    s2 = stubsum(t, "retry-keyper"); i2 = ids("retry-keyper")
    ok(s2[0] == 3 and s2[2] == 3, "the key minted inside the method: 3 POSTs, 3 distinct keys (%s)" % s2[:3])
    ok(i2 == ["pay-1", "pay-2", "pay-3"], "the key per attempt: three payments %s" % i2)
    s3 = stubsum(t, "retry-404narrow"); l3 = grab(t, r"^  retry-404narrow \| PROBE21 retry payment 1: (.*)$") or ""
    ok(s3[5] == 1 and l3.startswith("after 1 attempts -> org.springframework.web.client.HttpClientErrorException$NotFound"), "a remote 404 under the narrow includes: 1 request at the stub, 1 attempt (%s)" % s3[5])
    s4 = stubsum(t, "retry-404wide"); l4 = grab(t, r"^  retry-404wide \| PROBE21 retry payment 1: (.*)$") or ""
    ok(s4[5] == 3 and l4.startswith("after 3 attempts -> org.springframework.web.client.HttpClientErrorException$NotFound"), "a remote 404 under includes = RestClientException: 3 requests at the stub, 3 attempts (%s)" % s4[5])
    s5 = stubsum(t, "retry-hc5"); l5 = grab(t, r"^  retry-hc5 \| PROBE21 retry payment 1: (.*)$") or ""
    ok(s5[0] == 3 and s5[2] == 1 and l5.endswith("root java.net.SocketTimeoutException: Read timed out"), "the HttpClient 5 class path: 3 POSTs, 1 key, root Read timed out (labelled)")
    st = grab(t, r"^  retry-onekey \| PROBE21 settings PaymentCaller\.pay · (.*)$")
    ok(st == "maxRetries 2 · delay 10 · jitter 0 · multiplier 1.0 · includes [org.springframework.web.client.ResourceAccessException, org.springframework.web.client.HttpServerErrorException]", "the shipped settings read back: %s" % st)
    df = grab(t, r"^  retry-onekey \| PROBE21 defaults @Retryable \(spring-context-7\.0\.11\.jar\) · (.*)$")
    ok(df is not None and df.startswith("maxRetries 3 · delay 1000 · jitter 0 · multiplier 1.0"), "the annotation's defaults on 7.0.11: %s" % df)
    ok("the harness's lost reply: a later call in the same method" in t, "the lost reply labelled")
    ok(grab(t, r"^  retry-onekey \| PROBE21 caller bean (\S+)") == "com.tiffinbox.client.PaymentCaller$$SpringCGLIB$$N", "the caller is a proxy (its class from the running context)")
    finish("onekey=%d/%d/%s keyper=%d/%d 404narrow=%d 404wide=%d hc5=%d/%d" % (s1[0], s1[2], ",".join(i1), s2[0], s2[2], s3[5], s4[5], s5[0], s5[2]))


def c_mock(t):
    ok(re.search(r"mock \| class PaymentRetryTest \| tests 4 failures 0 errors 0 skipped 0", t) is not None, "PaymentRetryTest: 4 green, 0 skipped")
    ok(re.search(r"mock \| class TiffinBoxClientTest \| tests 1 failures 0 errors 0 skipped 0", t) is not None, "TiffinBoxClientTest: 1 green, unmoved")
    ok("PaymentRetryTest: one key - requests 3 · distinct keys 1 · attempts 3 · answers IOException, 500, 201 · payment pay-1" in t, "the mock: 3 requests, one key, 3 attempts")
    ok("PaymentRetryTest: three 500s - attempts 3 · the key matched on each" in t, "the mock: times(3), the key matched on each")
    ok("PaymentRetryTest: two payments - requests 2 · distinct keys 2" in t, "the mock: two payments, two keys")
    ok("PaymentRetryTest: a 404 - attempts 1 · org.springframework.web.client.HttpClientErrorException$NotFound" in t, "the mock: a 404 sent once")
    ok("PaymentRetryTest: factory org.springframework.test.web.client.MockRestServiceServer$MockClientHttpRequestFactory (no socket)" in t, "the mock's factory: MockClientHttpRequestFactory, no socket")
    ok("what it does not test: the timeout and the slow path, the stub's three charges, a real HTTP client's behaviour, and whether any server honours the key" in t, "what the mock does not test, said")
    finish("tests=4 requests=3 distinct=1 factory=MockClientHttpRequestFactory")


def c_resilience4j(t):
    ok(grab(t, r"r4 core \| calls (\d+)") == "3" and grab(t, r"RETRY events (\d+)") == "2", "the core Retry: 3 calls, 2 RETRY events")
    ok(re.search(r"r4 core \| R4CORE jar resilience4j-retry-2\.4\.0\.jar", t) is not None, "its version read off the jar: 2.4.0")
    m = re.search(r"r4 starter without micrometer-core \| exit (\d+) · started: (\d+) · the innermost cause: (.*)$", t, re.M)
    ok(m is not None and m.group(1) != "0" and m.group(2) == "0" and "io.micrometer.core.instrument.MeterRegistry" in m.group(3), "the starter without micrometer-core does not start (%s)" % (m.group(3) if m else ""))
    w = re.search(r"r4 starter with micrometer-core 1\.17\.3 \| exit (\d+) · R4 started: Boot 4\.1\.3 · retry beans: (.*?) · the Boot 4 verifier: (\d+)", t)
    ok(w is not None and w.group(1) == "0" and "retryRegistry" in w.group(2), "with micrometer-core: it starts, retryRegistry among the beans")
    ok("the anchor: files naming resilience4j in after/ 0" in t, "never on the anchor")
    finish("core_calls=3 events=2 without=%s with=started" % ((m.group(3).split(":")[0].split(".")[-1]) if m else ""))


def c_spec(t):
    ok("(servers removed, json.dump indent 2, ensure_ascii False, a final newline): equal" in t, "the served spec = the committed file")
    ok("byte-equal: yes" in t and "bytes before 36164 · after 36164" in t, "the committed file unchanged by this unit (36,164 B)")
    ok("the operations' ids before -> after: equal" in t, "the operations' ids equal")
    ok(re.search(r"OpenApiSpecTest on the committed file: tests 1 failures 0 errors 0", t) is not None, "OpenApiSpecTest passes")
    budget(t)
    finish("spec=%s ops=%s" % (grab(t, r"bytes before (\d+)"), grab(t, r"before: (.*?) · after:")))


def c_moved(t):
    js = re.findall(r"jar \| (the web jar|the core jar|the client's main jar): entries (\d+) -> (\d+) · added (\d+) .*? · removed (\d+) · shared entries whose CRC moved (\d+)", t)
    ok(len(js) == 3, "three jars compared")
    for j in js: ok(j[3] == "0" and j[4] == "0" and j[5] == "0", "%s: 0 added, 0 removed, 0 moved (%s entries)" % (j[0], j[2]))
    ok("the client's main jar names Payment: 0" in t, "the client's main jar holds none of the new classes")
    lib = re.search(r"BOOT-INF/lib names: before (\d+) · after (\d+) · added (\d+) · removed (\d+)", t)
    ok(lib is not None and lib.group(1) == lib.group(2) == "167" and lib.group(3) == lib.group(4) == "0", "BOOT-INF/lib 167 = 167, 0 added, 0 removed")
    finish("moved=0 web=%s core=%s client=%s lib=%s->%s" % (tuple(x[2] for x in js) + (lib.group(1) if lib else "", lib.group(2) if lib else "")) if len(js) == 3 else "moved=")


def c_api(t):
    ok(grab(t, r"api \| before -> after/: (\w+)") == "identical", "the /api/v1/ census identical on both trees")
    n = grab(t, r"api \| before -> after/: \w+ \((\d+) requests each\)")
    ok(n is not None and int(n) >= 10, "the census: %s requests each" % n)
    budget(t)
    finish("api=%s identical" % n)


def c_seven(t):
    e = grab(t, r"expected ([0-9a-f]{32})"); b = grab(t, r"before: the seven ([0-9a-f]{32})"); a = grab(t, r"after: the seven ([0-9a-f]{32})")
    ok(e is not None and b == e and a == e, "the seven = %s on both" % e)
    budget(t)
    finish("seven=%s" % (e or "")[:8])


def c_surface(t):
    e = grab(t, r"expected ([0-9a-f]{32})"); b = grab(t, r"before: the old surface ([0-9a-f]{32})"); a = grab(t, r"after: the old surface ([0-9a-f]{32})")
    ok(e is not None and b == e and a == e, "the old surface = %s on both" % e)
    budget(t)
    finish("surface=%s" % (e or "")[:8])


def c_tests(t):
    ok("mvn package exit 0" in t, "package exit 0")
    w = re.search(r"package \| tiffinbox-web \| tests (\d+) failures 0 errors 0 skipped 0", t)
    ok(w is not None and w.group(1) == "85", "package: the web module 85 green, 0 skipped")
    c = re.search(r"package \| tiffinbox-client \| tests (\d+) failures 0 errors 0 skipped 0", t)
    ok(c is not None and c.group(1) == "5", "package: the client module 5 green (1 + 4), 0 skipped")
    ok(re.search(r"package \| client \| class PaymentRetryTest \| tests 4 failures 0 errors 0 skipped 0", t) is not None and re.search(r"package \| client \| class TiffinBoxClientTest \| tests 1 failures 0 errors 0 skipped 0", t) is not None, "the client's classes: PaymentRetryTest 4, TiffinBoxClientTest 1")
    ok(re.search(r"the client before \(before's own build\): 1 -> after: 5 · PaymentRetryTest's @Test lines 4", t) is not None, "the client 1 -> 5")
    ok("disabling or conditional annotations 0 · ports, sockets or sleeps (string literals removed) 0" in t, "the test class: no disabling annotation, no port, no sleep")
    ok(re.search(r"test files moved before -> after:  · new: PaymentCaller\.java,PaymentRetryTest\.java,Payments\.java", t) is not None, "no existing test file moved; three new")
    ok(grab(t, r"outside RateLimitFilterTest (\d+)") == "0", "R.555: 0 refusals at the default outside RateLimitFilterTest")
    tw = re.search(r"twin \| tiffinbox-web \| tests (\d+) failures 0 errors 0 skipped 0", t); tc = re.search(r"twin \| tiffinbox-client \| tests (\d+) failures 0 errors 0 skipped 0", t)
    ok(tw is not None and tw.group(1) == "85" and tc is not None and tc.group(1) == "5", "the Docker-free twin: the same counts")
    v = re.search(r"verify exit 0 · ITs tests (\d+) failures 0 errors 0 · classes (\d+)", t)
    ok(v is not None and v.group(1) == "14" and v.group(2) == "5", "verify: %s" % (v.group(0) if v else "absent"))
    ok(re.search(r"IT bindings: [1-9]\d* lines · not 127\.0\.0\.1: 0", t) is not None, "IT bindings: all 127.0.0.1")
    ok("Testcontainers containers after: 0 · images pulled: 0" in t, "no container left, nothing pulled")
    co = re.search(r"clientonly \| tiffinbox-client \| tests (\d+) failures 0 errors 0 skipped 0", t)
    ok(co is not None and co.group(1) == "5", "the client-only form (-pl tiffinbox-client -am): the same 5")
    ok("downloads across the builds: 0" in t, "0 downloads")
    lib = re.search(r"BOOT-INF/lib: before (\d+) · after (\d+) · added (\d+) · removed (\d+)", t)
    ok(lib is not None and lib.group(1) == lib.group(2) == "167" and lib.group(3) == "0" and lib.group(4) == "0", "BOOT-INF/lib 167 = 167")
    ok("the test classes that name MockRestServiceServer (grep -l): PaymentRetryTest,TiffinBoxClientTest" in t, "two classes name MockRestServiceServer")
    finish("web=%s client=1->%s its=%s lib=%s->%s" % (w.group(1) if w else "", c.group(1) if c else "", v.group(1) if v else "", lib.group(1) if lib else "", lib.group(2) if lib else ""))


def c_harness(t):
    ok("harness/: chk21.py dur9.py ops9s3.py s921.py src stub tree21.py · harness/src: probe21/Caller21.java r4/R4.java r4/R4Core.java" in t, "the folder's files exactly")
    ok("cdp.mjs cdp9.mjs seal9.py chrome20.py loc9.py src/probe - 0 present" in t, "no instrument this unit does not carry")
    ok(re.search(r"a byte appended to after/compose\.yaml .*?: exit 1 · a FAIL names it: [1-9]", t) is not None, "static (ii) on a scratch copy moved by one byte: exit 1")
    ok("output md5 = (i): yes" in t, "static (iii) in a folder copy with no sibling anchor: the same output")
    ok("reading the live anchor (its folder name assembled) -> exit 1 · the same path from two pieces -> exit 1" in t, "flag 18's two plants exit 1")
    ok("c9-unit10/receipts.sh:611=1 c9-unit13/receipts.sh:334=1 c9-unit15/receipts.sh:396=1" in t, "the three frozen receipts' live-anchor pom lines, printed (findings, not edits)")
    finish("static=%s" % grab(t, r"as written: output md5 ([0-9a-f]{32})"))


def c_exercise(t):
    for sh in ("bash", "zsh"):
        bl = "\n".join(re.findall(r"^  broken %s \| (.*)$" % sh, t, re.M)); sl = "\n".join(re.findall(r"^  solved %s \| (.*)$" % sh, t, re.M))
        ok("check exit 1" in bl and "payment 1: 3 attempts, 3 distinct key(s)" in bl and "FAIL (2)" in bl, "broken, %s: FAIL on clause 2 (three keys for one payment at the stub)" % sh)
        ok("FAIL (1) the tree's client tests are red: oneKeyOnEveryAttempt theCallersKeyOnEachOfThreeRequests" in bl, "broken, %s: the shipped test's key methods red, named" % sh)
        ok("check exit 0" in sl and "\nPASS" in "\n" + sl and "payment 1: 3 attempts, 1 distinct key(s) · payment 2: 3 attempts, 1 distinct key(s) · distinct across the two: 2" in sl, "solved, %s: PASS (one key per payment, two across)" % sh)
    for v in ("none", "constant", "onlyfirst", "swallow", "fixedelsewhere"):
        l = "\n".join(re.findall(r"^  ~ %s bash \| (.*)$" % v, t, re.M))
        if l: ok("check exit 1" in l, "refused variant %s: exit 1" % v)
    finish("broken=FAIL(3_keys) solved=PASS")


def c_inert(t):
    ok(grab(t, r"carrying a key: (\d+)") == "0", "no request with the key header reached a TiffinBox JVM")
    ok(int(grab(t, r"TiffinBox access-log lines: (\d+)") or 0) > 0, "the access logs were read")
    ok(grab(t, r"TiffinBox's ports in the callers' stub URLs: (\d+)") == "0", "no caller pointed at a TiffinBox port")
    finish("keyed=0")


def c_title(t):
    n = grab(t, r'\((\d+) characters by len\(\)\)')
    ok(n is not None and int(n) <= 60, "the title for search: %s characters (<= 60)" % n)
    ok('"Spring Boot RestClient: Timeouts and Status Handlers"' in t, "Course 6's search title printed beside it")
    finish("title_len=%s" % n)


CHECKS = {"advisory": c_advisory, "before": c_before, "change": c_change, "census": c_census, "factory": c_factory, "timeout": c_timeout,
          "retry": c_retry, "mock": c_mock, "resilience4j": c_resilience4j, "spec": c_spec, "moved": c_moved, "api": c_api, "seven": c_seven,
          "surface": c_surface, "tests": c_tests, "harness": c_harness, "exercise": c_exercise, "inert": c_inert, "title": c_title}

PLANTS = [("factory", r"(factory-module \| PROBE21 builder \S+ · factory )org\.springframework\.http\.client\.JdkClientHttpRequestFactory", r"\1org.springframework.http.client.HttpComponentsClientHttpRequestFactory", "the module's factory typed HttpComponents"),
          ("factory", r"(class paths \| the module's: \d+ jars, httpclient5 )0", r"\g<1>1", "the client module's HttpClient 5 count typed 1"),
          ("timeout", r"(timeout-hc5 \| PROBE21 timeout root -> java\.net\.SocketTimeoutException: )Read timed out", r"\1Request cancelled", "Request cancelled typed on the HttpClient 5 class path"),
          ("timeout", r"(timeout-module \| PROBE21 timeout root -> )java\.net\.http\.HttpTimeoutException: Request cancelled", r"\1java.net.SocketTimeoutException: Read timed out", "Read timed out typed on the module's"),
          ("timeout", r"(timeout-none \| PROBE21 metadata \S+ · spring\.http\.clients\.read-timeout · defaultValue present: )false", r"\1true", "the metadata's default typed present"),
          ("timeout", r"(returned no earlier than the stub's delay: )true", r"\1false", "the wait typed short"),
          ("retry", r"(retry-onekey stub \| POST /payments 3 · with the key header 3 · distinct keys )1", r"\g<1>3", "the key typed 3 distinct in the one-key leg"),
          ("retry", r"(retry-keyper stub \| POST /payments 3 · with the key header 3 · distinct keys )3", r"\g<1>1", "the key typed 1 in the key-per-attempt leg"),
          ("retry", r"(retry-404narrow stub \| POST /payments 0 · .*? · GET /status/404 )1", r"\g<1>3", "the 404 typed 3 under the narrow list"),
          ("retry", r"(retry-404wide stub \| POST /payments 0 · .*? · GET /status/404 )3", r"\g<1>1", "the 404 typed 1 under the wide list"),
          ("retry", r"(retry-onekey \| PROBE21 POST /payments -> 201 · payment )pay-2", r"\1pay-3", "a payment id typed one off"),
          ("retry", r"the harness's lost reply: a later call in the same method", "the reply was lost", "the lost-reply label dropped"),
          ("mock", r"MockRestServiceServer\$MockClientHttpRequestFactory \(no socket\)", "JdkClientHttpRequestFactory (no socket)", "the mock's factory typed the JDK's"),
          ("mock", r"  mock \| what it does not test:[^\n]*\n", "", "the not-tested line missing"),
          ("resilience4j", r"(RETRY events )2", r"\g<1>3", "the events typed 3"),
          ("resilience4j", r"(r4 starter without micrometer-core \| exit )\d+( · started: )0", r"\g<1>0\g<2>1", "the start without Micrometer typed successful"),
          ("change", r"(files naming Idempotency-Key in tiffinbox-client )1", r"\g<1>2", "Idempotency-Key in a second file"),
          ("change", r"ClientHttpRequestInterceptor 0", "ClientHttpRequestInterceptor 1", "an interceptor added"),
          ("change", r"(tiffinbox-client/pom.xml byte-equal to before's: )yes", r"\1no", "a pom touched"),
          ("change", r"(src/main of every module byte-equal to before's: )yes", r"\1no", "a src/main file touched"),
          ("tests", r"(package \| tiffinbox-client \| tests 5 failures 0 errors 0) skipped 0", r"\1 skipped 1", "Skipped typed 1"),
          ("tests", r"outside RateLimitFilterTest 0", "outside RateLimitFilterTest 1", "a refusal at the default"),
          ("tests", r"(disabling or conditional annotations )0", r"\g<1>1", "an @EnabledIf on PaymentRetryTest"),
          ("seven", r"after: the seven ([0-9a-f]{31})[0-9a-f]", r"after: the seven \g<1>0", "the seven's md5 one character off"),
          ("surface", r"after: the old surface ([0-9a-f]{31})[0-9a-f]", r"after: the old surface \g<1>0", "the surface's md5 one character off"),
          ("moved", r"(BOOT-INF/lib names: before 167 · after )167", r"\g<1>164", "BOOT-INF/lib typed 164"),
          ("moved", r"(the web jar: entries \d+ -> \d+ · added 0 \[\] · removed 0 · shared entries whose CRC moved )0", r"\g<1>1", "a moved entry"),
          ("api", r"(api \| before -> after/: )identical", r"\1DIFFER", "the census moved"),
          ("spec", r"a final newline\): equal", "a final newline): differ", "the committed file touched"),
          ("exercise", r"(  solved bash \| )check exit 0", r"\1check exit 1", "solution = broken"),
          ("advisory", r"run date (\S+)", "run date 2026-11-28", "the read one day older than the run"),
          ("inert", r"carrying a key: 0", "carrying a key: 1", "a keyed request reaching a TiffinBox JVM"),
          ("spec", r"(  budget \| spec: requests under /api/v1/ \(its access log\): )\d+", r"\g<1>61", "a per-JVM request count above the cap"),
          ("spec", r"(  budget \| spec: requests under /api/v1/ \(its access log\): \d+ · refusal lines: )0", r"\g<1>1", "a refusal line in a default-capacity JVM"),
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
    for nm, line in (("retry", "  retry-onekey | PROBE21 garbage\n"), ("factory", "  factory-module stub | garbage\n"), ("tests", "  package | garbage\n")):
        r = subprocess.run([sys.executable, "-I", "-B", __file__, nm, "-"], input=line, capture_output=True, text=True)
        ok(r.returncode == 1 and "Traceback" not in r.stderr, "plant an unparseable %s listing: a FAIL line, exit 1, no traceback" % nm); n += 1
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
            ok(not any(l.startswith(g) for l in r), "no gloss line (%s) - 21 none new" % g)
        for u in range(13, 21):
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
