"""Course 9 unit 22's checks (python3 -I -B harness/chk22.py SUBCOMMAND ...), run from c9-unit22/ (unit 21's chk21.py's machinery).

Each capture's check reads the masked capture file the receipt wrote (.r-NAME.new) and prints "ok ..." or "FAIL ..." lines and one
"VALUES ..." line; any FAIL exits 1 (a line it cannot parse is a FAIL line, exit 1, never a traceback). `static` reads only this unit's
frozen after/, before (the link to ../c9-unit21/after) and git objects of unit 21's commit (afba429:c9-unit21/after/...) - never the live
anchor: an audit hook refuses any open() whose real path lies in the live anchor's folder, so a static read of it exits 1 (flag 20).
Subcommands: static AFTER BEFORE · static-plant live|pieces · gloss README · hook · exq · title-line · interleaved · hashable NAME FILE ·
values README VALS · plants DIR · and one per capture: advisory before change census drop bind record strict key limits spec moved
api seven surface tests harness exercise title.
"""
import hashlib, os, re, subprocess, sys

ANCHOR_DIR = "/c9-" + "tiffinbox"   # LIVE_ANCHOR_PLANT: the live anchor's folder name, assembled so a grep for it finds only this line


def _guard(event, args):
    if event == "open" and args and isinstance(args[0], (str, bytes, os.PathLike)):
        p = os.path.realpath(os.fsdecode(args[0]))
        if (ANCHOR_DIR + "/") in p or p.endswith(ANCHOR_DIR):
            raise SystemExit("FAIL flag 20: a static check read the live anchor (%s)" % p)


H21 = "afba429"
LEFT_OUT = ["factory", "timeout", "retry", "mock", "resilience4j", "inert", "dev", "bindblock", "named", "shallow", "paths", "weak", "deep", "ifmatch", "cache", "chrome", "moving", "identity", "metrics", "limiter", "limit", "forge",
            "xff", "refill", "scope", "twojvm", "lua", "defaults", "restart", "proxy", "declared", "signed", "presign", "sealed", "expect",
            "specwire", "blob", "bills", "poll", "accept", "callpg", "html", "walk", "pageable", "trap", "table", "first", "next"]
GLOSSES = ["A precondition:", "A token bucket:", "A cursor:", "A sparse fieldset:", "A link relation:", "`HAL`:", "A status resource:",
           "A presigned URL:", "A version carrier:", "A snippet:", "A contract:", "Swagger UI:", "A problem type:", "Code generation:",
           "A read timeout:", "A retry:", "An ETag:", "A validator:", "Over-posting:"]
GLOSS = "Mass assignment: a body that sets fields the API never offered."
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


CPJ = "tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerPatches.java"
TST = "tiffinbox-web/src/test/java/com/tiffinbox/web/InputHardeningTest.java"
EXPECTED_CHANGED = ["A " + TST, "M " + CPJ, "M README.md"]
BYTE_EQUAL = ["Dockerfile", "compose.yaml", "pom.xml", "tiffinbox-web/pom.xml", "tiffinbox-core/pom.xml", "tiffinbox-client/pom.xml",
              "tiffinbox-web/src/main/resources/application.yaml", "tiffinbox-web/src/main/resources/application-dev.yaml",
              "tiffinbox-web/src/test/resources/openapi/tiffinbox.json", "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java",
              "tiffinbox-web/src/test/java/com/tiffinbox/web/CustomerPatchesTest.java"]
STRICT = "            c = json.readerFor(Customer.class).with(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES).readValue(doc.toString());"
OLDREAD = "            c = json.readValue(doc.toString(), Customer.class);"


def walk(r):
    out = {}
    for d, ds, fs in os.walk(r):
        for f in fs:
            p = os.path.join(d, f); out[os.path.relpath(p, r)] = md5(open(p, "rb").read())
    return out


def gitobj(rel):
    top = os.environ.get("REPO") or subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True).stdout.strip()
    r = subprocess.run(["git", "-C", top, "show", "%s:c9-unit21/after/%s" % (H21, rel)], capture_output=True)
    return r.stdout if r.returncode == 0 else None


def static(a, b):
    sys.addaudithook(_guard)
    A, Bt = walk(a), walk(b)
    ch = sorted(["A " + k for k in A if k not in Bt] + ["D " + k for k in Bt if k not in A] + ["M " + k for k in A if k in Bt and A[k] != Bt[k]])
    ok(ch == sorted(EXPECTED_CHANGED), "the changed set (after/ against before, derived) is flag 2's: %s" % " · ".join(ch))
    for rel in BYTE_EQUAL:
        g = gitobj(rel)
        ok(g is not None and md5(g) == A.get(rel), "%s byte-equal to git show %s:c9-unit21/after/%s" % (rel, H21, rel))
    g = gitobj(CPJ)
    ok(g is not None and md5(g) == Bt.get(CPJ), "before's CustomerPatches.java = git show %s:c9-unit21/after/%s" % (H21, CPJ))
    sm = sorted([k for k in A if "/src/main/" in k and A[k] != Bt.get(k)] + [k for k in Bt if "/src/main/" in k and k not in A])
    ok(sm == [CPJ], "one src/main path of any module changed: %s" % sm)
    ok(not [k for k in ch if k.endswith("pom.xml")], "no pom changed")
    ok(not [k for k in ch if k.startswith(("tiffinbox-core/", "tiffinbox-client/"))], "nothing under tiffinbox-core/ or tiffinbox-client/ changed")
    for k in sorted(Bt):
        if "/src/test/" in k and k in A and A[k] != Bt[k]: ok(False, "an existing test file was edited: " + k)
    ok(True, "every existing test file byte-equal to before's (%d files)" % sum(1 for k in Bt if "/src/test/" in k))
    old = open(os.path.join(b, CPJ), encoding="utf-8").read().splitlines(); new = open(os.path.join(a, CPJ), encoding="utf-8").read().splitlines()
    import difflib
    dl = [l for l in difflib.ndiff(old, new) if l[:1] in "+-"]
    code = [l for l in dl if not re.match(r"^[+-] +(\*|//)", l)]
    ok(code == ["- " + OLDREAD, "+ import tools.jackson.databind.DeserializationFeature;", "+ " + STRICT] or sorted(code) == sorted(["- " + OLDREAD, "+ import tools.jackson.databind.DeserializationFeature;", "+ " + STRICT]),
       "CustomerPatches.java: the one read line and its import, nothing else in code (%d code lines)" % len(code))
    yml = open(os.path.join(a, "tiffinbox-web/src/main/resources/application.yaml"), encoding="utf-8").read()
    ok(re.search(r"fail-on-unknown", yml, re.I) is None, "the global key is in no yaml of after/ (BLUE's (b′): never the anchor)")
    main = "".join(open(os.path.join(a, k), encoding="utf-8").read() for k in A if "/src/main/" in k and k.endswith(".java"))
    code = [l for l in main.splitlines() if "FAIL_ON_UNKNOWN_PROPERTIES" in l and not re.match(r"^\s*(\*|//|/\*)", l)]
    ok(len(code) == 1, "FAIL_ON_UNKNOWN_PROPERTIES in one code line of src/main (%d; the class comment names it too)" % len(code))
    ok(main.count("readerForUpdating") == 0, "no readerForUpdating in src/main (no shipped route reads a body onto an entity)")
    t = open(os.path.join(a, TST), encoding="utf-8").read()
    ok(not re.search(r"Probe|probe\.|BLUE|/probe/", t), "no probe or BLUE name in the new test")
    ok(re.search(r"@(org\.junit\.jupiter\.api\.(condition\.)?)?(Disabled|EnabledIf|DisabledIf|EnabledOn|DisabledOn|EnabledFor|DisabledFor)\w*", t) is None, "InputHardeningTest: no disabling or conditional annotation, simple or fully qualified")
    tc = re.sub(r'"[^"\n]*"', '""', t)
    ok(re.search(r"RANDOM_PORT|DEFINED_PORT|LocalServerPort|\bSocket\b|Thread\.sleep|(?<![\d.\w])\d{4,5}(?![\d.])", tc) is None, "InputHardeningTest: no port, no socket, no sleep, no 4-5 digit literal outside a string")
    ok(re.search(r'"(Content-Type|If-Match|Idempotency-Key|Accept)"', t) is None, "InputHardeningTest: no header-name literal (contentType(), the constants)")
    ok(re.search(r"isEqualTo\((?:200|201|400|422)\)", t) is None, "InputHardeningTest: the statuses are named constants")
    ok("webAppContextSetup(ctx)" in t and "the patched customer cannot be read at admin" in t and '"mealType").asString()).isEqualTo("must not be null")' in t, "InputHardeningTest: MockMvc over the context, the 422's detail, the mealTyp pin")
    readme = open(os.path.join(a, "README.md"), encoding="utf-8").read()
    card = readme.split("## Course 9 · unit 22", 1)
    ok(len(card) == 2, "the anchor README has a unit 22 card")
    if len(card) == 2:
        body = card[1].split("\n## ", 1)[0]
        ok("(85 at unit 21)" in body, "the card gives 85 as unit 21's count")
        ok(re.search(r"\bcompatible\b", body) is None, "the card never says compatible (S9.37's U22 row: a named change)")
        ok("S9.37" in body, "the card names S9.37")
    ok("Course 9's eighteenth change to this folder (U22)" in readme, "the header note names the eighteenth change")
    me = open(__file__, encoding="utf-8").read()
    subs = set(re.findall(r'^    elif cmd == "([a-z0-9-]+)"', me, re.M)) | set(re.findall(r'^    if cmd == "([a-z0-9-]+)"', me, re.M)) | set(CHECKS)
    ok(not (subs & set(LEFT_OUT)), "no left-out subcommand in chk22.py (%s)" % sorted(subs & set(LEFT_OUT)))
    finish(None)


def brief():
    c9 = os.environ.get("C9R") or ""
    return open(os.path.join(c9, "_briefs/UNIT-BRIEFS-S4-OPERATING.md"), encoding="utf-8").read()


def unit22(): return brief().split("\n## Unit 22", 1)[1].split("\n## Unit 23", 1)[0]


def hook(): return re.search(r'^\*\*Hook \(\[S4 §\d+\]\):\*\* "([^"]+)"', unit22(), re.M).group(1)


def exq(): return re.search(r'^\*\*Exercise:\*\* "(Your turn: [^"]+)"', unit22(), re.M).group(1)


def title(): return re.search(r'^\*\*Title for search:\*\* "([^"]+)"', unit22(), re.M).group(1)


# ---- capture checks ----------------------------------------------------------------------------------------------------------------
def budget(t):
    for m in re.finditer(r"^  budget \| (\S+): requests under /api/v1/ \(its access log\): (\d+) · refusal lines: (\d+)", t, re.M):
        ok(int(m.group(2)) <= BUDGET and m.group(3) == "0", "N11: %s sent %s /api/v1/ requests (<= %d), refusals %s" % (m.group(1), m.group(2), BUDGET, m.group(3)))
    return max([int(x) for x in re.findall(r"requests under /api/v1/ \(its access log\): (\d+)", t)] or [0])


def c_advisory(t):
    fa = grab(t, r"fetched-at (\S+) \(the hour masked\) · run date (\S+)")
    rd = grab(t, r"run date (\S+) ·")
    ok(fa is not None and fa == rd, "the read is the batch day's (fetched-at %s = run date %s)" % (fa, rd))
    for m in re.finditer(r"(\S+)/MD5SUMS.txt: (\d+) lines, (\d+) verified", t): ok(m.group(2) == m.group(3) and int(m.group(2)) > 0, "%s: %s of %s verified" % (m.group(1), m.group(3), m.group(2)))
    ok(len(re.findall(r"MD5SUMS.txt: \d+ lines", t)) == 2, "both of the day's MD5SUMS.txt read")
    ok("tomcat page md5 a1a756d985225fb5143eefd9aae3183c " in t, "Tomcat's page = the earlier reads")
    o = re.search(r"(\d+) coordinates queried, (\d+) results, (\d+) with vulns", t)
    ok(o is not None and o.group(3) == "0", "OSV: %s" % (o.group(0) if o else "absent"))
    lib = re.search(r"lib names before (\d+) · after (\d+) · by name: (\w+) · the four poms byte-equal: (\d+) differ", t)
    ok(lib is not None and lib.group(1) == lib.group(2) == "167" and lib.group(3) == "equal" and lib.group(4) == "0", "BOOT-INF/lib 167 = 167 by name; the four poms byte-equal")
    ok("shipped | spring-context 7.0.11" in t and "shipped | spring-boot 4.1.3" in t and "shipped | tomcat-embed-core 11.0.29" in t and "shipped | jackson-databind 2.21.8,3.1.8" in t, "the pins: Boot 4.1.3, Framework 7.0.11, Tomcat 11.0.29, Jackson 3.1.8")
    ok("verdict: no pin affected; evidence may proceed" in t, "the verdict")
    finish("fetched=%s lib=%s->%s jackson=3.1.8" % (fa, lib.group(1) if lib else "", lib.group(2) if lib else ""))


def c_before(t):
    ok(grab(t, r"lines naming fail-on-unknown: (\d+)") == "0", "before: the yaml names no fail-on-unknown key")
    ok("accept-float-as-int: false" in t, "before: Course 6's deserialization map (accept-float-as-int: false)")
    ok("c = json.readValue(doc.toString(), Customer.class);" in t, "before: readBack reads with the shared mapper")
    ok(grab(t, r"FAIL_ON_UNKNOWN_PROPERTIES named in src/main: (\d+) files") == "0", "before: FAIL_ON_UNKNOWN_PROPERTIES in no src/main file")
    ok(grab(t, r"BOOT-INF/lib names (\d+)") == "167", "before: BOOT-INF/lib 167")
    ok("web=85" in t and "client=1->5" in t and "its=14" in t, "before: U21's web 85, client 5, ITs 14")
    finish("key=absent read=readValue lib=%s web=85" % grab(t, r"BOOT-INF/lib names (\d+)"))


def c_change(t):
    ch = grab(t, r"changed \(derived: .*?\): (.*)$")
    got = sorted((ch or "").split(" · "))
    ok(got == sorted(EXPECTED_CHANGED), "the derived changed list is flag 2's (%d paths)" % len(got))
    ok(re.search(r"modules: tiffinbox-core tiffinbox-web tiffinbox-client \(3\) -> tiffinbox-core tiffinbox-web tiffinbox-client \(3\)", t) is not None, "three modules -> three")
    m = re.search(r"code lines added \(not comments\) (\d+) · code lines removed (\d+)", t)
    ok(m is not None and m.group(1) == "2" and m.group(2) == "1", "the diff: 2 code lines added (the import, the read), 1 removed")
    ok("> " + STRICT.strip() in t or STRICT.strip() in t, "the strict read line printed")
    ok(not re.search(r"byte-equal to before's: no", t), "the listed files byte-equal to before's (poms, yaml, spec)")
    ok("src/main files moved (every module): " + CPJ + " · tiffinbox-core/ and tiffinbox-client/ byte-equal: yes" in t, "one src/main file moved; core and client untouched")
    ok("src/main files naming FAIL_ON_UNKNOWN_PROPERTIES CustomerPatches.java · readerFor( in src/main code lines 1 · yaml lines naming fail-on-unknown 0 · Probe/probe./BLUE in the new test 0" in t, "the switch in one file, one reader, no yaml key, no probe name")
    ok(len(re.findall(r"^ +@Test$", t, re.M)) == 3, "the new test printed whole: 3 @Test")
    finish("changed=%d src_main=1 code=+2-1 key=none" % len(got))


def c_census(t):
    b = grab(t, r"census before \| controllers (.*)$"); a = grab(t, r"census after \| controllers (.*)$")
    ok(b is not None and a == b, "the census before = after: %s" % b)
    sb = grab(t, r"the spec's counts .*?before (.*?) · after"); sa = grab(t, r"the spec's counts .*? · after (.*)$")
    ok(sb is not None and sb == sa, "the spec's counts equal: %s" % sb)
    nums = re.findall(r"\d+", b or "")
    finish("census=%s" % "/".join(nums[:4]) if len(nums) >= 4 else "census=")


def c_drop(t):
    for side in ("before", "after"):
        p = re.search(r"^  drop %s \| POST /customers .* -> (\d+) " % side, t, re.M)
        ok(p is not None and p.group(1) == "201", "drop %s: the hook's request answers 201" % side)
        r = grab(t, r"^  drop %s \| GET /customers/Mohan \(the old read back\) -> 200 · (.*)$" % side)
        ok(r is not None and "version" not in r and "admin" not in r and '"mealsPerDay":1' in r, "drop %s: read back with the record's four members, none of the extras" % side)
        w = re.search(r"^  drop %s \| the JVM's log: WARN lines naming the read (\d+) \(the same grep on a copy with one planted WARN line: (\d+)" % side, t, re.M)
        ok(w is not None and w.group(1) == "0" and w.group(2) == "1", "drop %s: the log says nothing (0), the grep counts a planted line (1, R.566)" % side)
    ok("drop | before -> after/: identical" in t, "the old POST's answer is unmoved by the change")
    finish("hook=201 kept=4_members said=0 before=after")


def cases(t, db):
    return re.findall(r"^  %s \| case \| (.*?) \| .*?-> (\d{3})" % db, t, re.M)


def c_bind(t):
    ok("members | the entity's getters (javap -p, after/'s core classes): id,name,mealsPerDay,pricePerMeal,mealType,pauses,version,createdAt,updatedAt" in t, "the entity's nine getter-visible members")
    for db in ("h2", "pg"):
        ok(re.search(r"^  %s \| case \| 1 existing id \| Sunil <- .* -> 200" % db, t, re.M) is not None, "%s: the failure receipt answers 200" % db)
        ok(re.search(r"^  %s \| case \| 1 existing id \| outcome: id=another row overwritten \(row 1\); name=another row overwritten \(row 1\)" % db, t, re.M) is not None, "%s: Sunil's body with Ravi's id overwrote row 1" % db)
        ok(re.search(r"^  %s \| read \| GET /api/v1/customers/Ravi -> 404 · GET /api/v1/customers/Mallory -> 200" % db, t, re.M) is not None, "%s: Ravi 404, Mallory 200" % db)
        ok(re.search(r"^  %s \| case \| 1 existing id \| Sunil <- .*\| the URL's row \(row 3\) at v0 · the sent id's row \(row 1, Ravi\) at v0 \|" % db, t, re.M) is not None, "%s: R.567 - both rows' versions printed" % db)
        ok(re.search(r"^  %s \| case \| 3b version differing \| .* -> 409 \(the harness's route answers 409 for any exception\)" % db, t, re.M) is not None, "%s: a differing version 409, labelled the harness's catch-all" % db)
        ok(not re.search(r"^  %s \| case \| .* -> 409(?! \(the harness's route answers 409 for any exception\))" % db, t, re.M), "%s: every 409 labelled the harness's (R.567)" % db)
        ok(re.search(r"StaleObjectStateException", t) is not None, "%s: Hibernate's version check named" % db)
        for mem, w in (("mealsPerDay", "written"), ("pricePerMeal", "written"), ("mealType", "written"), ("name", "written")):
            ok(re.search(r"^  %s \| case \| member %s \| outcome: %s=%s" % (db, mem, mem, w), t, re.M) is not None, "%s: %s %s" % (db, mem, w))
        ok(re.search(r"^  %s \| case \| C3 createdAt \(POST-created row\) \| outcome: createdAt=not written" % db, t, re.M) is not None, "%s: createdAt not written on a POST-created row" % db)
        ok(re.search(r"^  %s \| key \| PROBE-KEY FAIL_ON_UNKNOWN_PROPERTIES=false" % db, t, re.M) is not None, "%s: the running mapper's FAIL_ON_UNKNOWN_PROPERTIES false (before)" % db)
        budget(t)
    ok("the statuses, H2 against PostgreSQL 18.6: equal" in t, "H2 = PostgreSQL by status")
    m = re.search(r"psql against the companion read: (\d+) equal, (\d+) differ", t)
    ok(m is not None and int(m.group(1)) > 10 and m.group(2) == "0", "psql = the companion read on every PostgreSQL case")
    sh = grab(t, r"^  h2 \| normalised: python3 -I harness/norm.py statuses \S+ \| md5 -q -> ([0-9a-f]{32})")
    sp = grab(t, r"^  pg \| normalised: python3 -I harness/norm.py statuses \S+ \| md5 -q -> ([0-9a-f]{32})")
    ok(sh is not None and sh == sp, "R.565: the normalised statuses' md5 printed beside its command, equal")
    finish("receipt=Ravi_overwritten_404 version_differing=409_hibernate createdAt=not_written statuses=%s h2=pg" % (sh or "")[:8])


def c_record(t):
    for db in ("h2", "pg"):
        ok(re.search(r"^  %s \| case \| R1 record route, Mallory's body \| .* -> 400 " % db, t, re.M) is not None, "%s: R1 Mallory's two-member body refused whole (400)" % db)
        ok(re.search(r"^  %s \| case \| R2 record route, Mallory's body made whole \| .* -> 200 " % db, t, re.M) is not None, "%s: R2 200" % db)
        ok(re.search(r"^  %s \| read \| R2 record route, Mallory's body made whole \| GET /api/v1/customers/Ravi -> 200 · GET /api/v1/customers/Mallory -> 404" % db, t, re.M) is not None, "%s: R2 Ravi's row untouched (Ravi 200, Mallory 404)" % db)
        ok(re.search(r"^  %s \| rows \| R2 record route, Mallory's body made whole \| companion read: 1\|Ravi\|" % db, t, re.M) is not None, "%s: row 1 is still Ravi" % db)
        ok(re.search(r"^  %s \| case \| C1 control: .* -> 200 " % db, t, re.M) is not None, "%s: the control (the entity route) 200" % db)
        ok(re.search(r"^  %s \| read \| C1 control: .*\| GET /api/v1/customers/Ravi -> 404 · GET /api/v1/customers/Mallory -> 200" % db, t, re.M) is not None, "%s: the control overwrote Ravi's row on the same JVM" % db)
        budget(t)
    ok("(norm.py rows): equal" in t, "H2 = PostgreSQL (rows and answers, normalised)")
    m = re.search(r"psql against the companion read: (\d+) equal, (\d+) differ", t)
    ok(m is not None and int(m.group(1)) >= 5 and m.group(2) == "0", "psql = the companion read")
    rh = grab(t, r"^  h2 \| normalised: python3 -I harness/norm.py rows \S+ \| md5 -q -> ([0-9a-f]{32})")
    finish("R1=400 R2=200_ravi_kept R3=200_priya_kept control=overwrite rows=%s" % (rh or "")[:8])


def c_strict(t):
    ok(grab(t, r"inventory \| @RequestBody in after/'s src/main \(grep -rn\): (\d+) routes") == "4", "the inventory: 4 @RequestBody routes")
    ok("inventory | readBack( in after/'s src/main: CustomerPatches.java:" in t, "readBack's lines listed")
    ok("out of reach by construction" in t and "not a witness for this change" in t, "each item measured or named out of reach; the non-witnesses labelled (R.511)")
    for db in ("h2", "pg"):
        m = re.search(r"^  %s \| (\d+) lines, (\d+) moved, the rest byte-equal" % db, t, re.M)
        ok(m is not None and m.group(2) == "3", "%s: exactly 3 reach lines moved (%s)" % (db, m.group(0) if m else "absent"))
        mv = re.findall(r"^  MOVED %s \| before.*?PATCH merge (\w+) \{(\w+):" % db, t, re.M)
        ok(sorted(mv) == sorted([("Priya", "version"), ("Meera", "admin"), ("Sunil", "loyaltyPoints")]), "%s: the three moved are the merge patch's extra-member rows: %s" % (db, mv))
        afters = re.findall(r"^  MOVED %s \| before.*\n(.*)$" % db, t, re.M)
        for who, mem in (("Priya", "version"), ("Meera", "admin"), ("Sunil", "loyaltyPoints")):
            ok(any(re.search(r"\| after .*PATCH merge %s .* -> 422 application/problem\+json .* detail the patched customer cannot be read at %s$" % (who, mem), l) for l in afters), "%s: %s -> 422 naming %s" % (db, who, mem))
        budget(t)
    ok("before H2 = before PostgreSQL: yes · after/ H2 = after/ PostgreSQL: yes" in t, "H2 = PostgreSQL on both trees")
    s = re.search(r"the side-by-side file \(paste \+ awk, BSD-safe\): (\d+) lines", t)
    ok(s is not None and int(s.group(1)) > 0, "R.564: the side-by-side file is not empty")
    hb = grab(t, r"^  before-h2 \| python3 -I harness/norm.py reach \S+ \| md5 -q -> ([0-9a-f]{32})")
    ha = grab(t, r"^  after-h2 \| python3 -I harness/norm.py reach \S+ \| md5 -q -> ([0-9a-f]{32})")
    finish("moved=3/%s merge_extra=200->422 before=%s after=%s" % (grab(t, r"^  h2 \| (\d+) lines") or "", (hb or "")[:8], (ha or "")[:8]))


def c_key(t):
    for db in ("key-h2", "key-pg"):
        ok(re.search(r"^  %s \| PROBE-KEY FAIL_ON_UNKNOWN_PROPERTIES=true" % db, t, re.M) is not None, "%s: the running mapper's FAIL_ON_UNKNOWN_PROPERTIES true (the run flag)" % db)
        m = re.search(r"^  %s \| (\d+) lines, (\d+) moved" % db, t, re.M)
        ok(m is not None and m.group(2) == "10", "%s: 10 reach lines moved (%s)" % (db, m.group(0) if m else "absent"))
        budget(t)
    mt = grab(t, r"key \| the misspelt mealTyp \(Course 6's typo case\): before (.*?) · the key (.*)$")
    ok(mt is not None and "400" in t and re.search(r"the misspelt mealTyp .*: before 400 .* · the key 400 .*Failed to read request", t) is not None, "the misspelt mealTyp: 400 naming mealType -> 400 Failed to read request (the cost)")
    ok(re.search(r"\+loyaltyPoints \(Course 6's\): before 201 .* · the key 400 .*Failed to read request", t) is not None, "loyaltyPoints: 201 -> 400 under the key")
    finish("moved=10 mealTyp=named->Failed_to_read_request loyaltyPoints=201->400 mapper=true")


def c_limits(t):
    lim = dict(re.findall(r"^  \(i\) library default \| StreamReadConstraints\.(getMax\w+)\(\) = (-?\d+)$", t, re.M))
    ok(len(lim) >= 5, "Jackson 3's read constraints read off the library: %d getters" % len(lim))
    ok("jackson-core 3.1.8" in t, "jackson-core 3.1.8 (the shipped jar)")
    ok(len(re.findall(r"^  \(iii\) Boot's metadata \| ", t, re.M)) == 6, "six request-size keys looked up in Boot's metadata")
    ok("not captured, not said" in t, "(ii) the running mapper's own: not captured, said")
    finish("nesting=%s string=%s number=%s" % (lim.get("getMaxNestingDepth", ""), lim.get("getMaxStringLength", ""), lim.get("getMaxNumberLength", "")))


def c_spec(t):
    ok("(servers removed, json.dump indent 2, ensure_ascii False, a final newline): equal" in t, "the served spec = the committed file")
    ok("byte-equal: yes" in t and "bytes before 36164 · after 36164" in t, "the committed file unchanged by this unit (36,164 B)")
    ok("the operations' ids before -> after: equal" in t, "the operations' ids equal")
    ok(re.search(r"the merge patch's documented answers \(the committed file\): .*\b422\b", t) is not None, "the merge patch's 422 documented before this unit")
    ok(re.search(r"OpenApiSpecTest on the committed file: tests 1 failures 0 errors 0", t) is not None, "OpenApiSpecTest passes")
    budget(t)
    finish("spec=%s ops=%s" % (grab(t, r"bytes before (\d+)"), grab(t, r"before: (.*?) · after:")))


def c_moved(t):
    js = re.findall(r"jar \| (the web jar|the core jar): entries (\d+) -> (\d+) · added (\d+) .*? · removed (\d+) · shared entries whose CRC moved (\d+) (.*)$", t, re.M)
    ok(len(js) == 2, "two jars compared")
    for j in js:
        if j[0] == "the web jar": ok(j[3] == "0" and j[4] == "0" and j[5] == "2" and j[6] == "['BOOT-INF/classes/com/tiffinbox/web/CustomerPatches$Refused.class', 'BOOT-INF/classes/com/tiffinbox/web/CustomerPatches.class']", "the web jar: 0 added, 0 removed, 2 moved - both compiled from CustomerPatches.java (the class and its nested Refused)")
        else: ok(j[3] == "0" and j[4] == "0" and j[5] == "0", "the core jar: 0 moved")
    ok("the web jar names InputHardeningTest: 0" in t, "the test is in no jar")
    lib = re.search(r"BOOT-INF/lib names: before (\d+) · after (\d+) · added (\d+) · removed (\d+)", t)
    ok(lib is not None and lib.group(1) == lib.group(2) == "167" and lib.group(3) == lib.group(4) == "0", "BOOT-INF/lib 167 = 167, 0 added, 0 removed")
    finish("moved=2(CustomerPatches.java) web=%s core=%s lib=%s->%s" % (tuple(x[2] for x in js) + (lib.group(1) if lib else "", lib.group(2) if lib else "")) if len(js) == 2 else "moved=")


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
    n = re.search(r"need \| InputHardeningTest on before \| tests (\d+) failures (\d+) errors (\d+) skipped (\d+)", t)
    ok(n is not None and n.group(1) == "3" and n.group(2) == "1" and n.group(3) == "0", "the need-measure: on before the new test is red (3 run, 1 failure)")
    ok(re.search(r"need \| red methods: aMergePatchNamingAMemberTheRecordLacksIs422 ", t) is not None, "the need-measure: the 422 test is the red one; the mealTyp pin is green on before")
    w = re.search(r"package \| tiffinbox-web \| tests (\d+) failures 0 errors 0 skipped 0", t)
    ok(w is not None and w.group(1) == "88", "package: the web module 88 green (85 + 3), 0 skipped")
    c = re.search(r"package \| tiffinbox-client \| tests (\d+) failures 0 errors 0 skipped 0", t)
    ok(c is not None and c.group(1) == "5", "package: the client module 5 green, 0 skipped")
    ok("package | class InputHardeningTest | tests 3 failures 0 errors 0 skipped 0" in t, "InputHardeningTest 3 green")
    ok("@Test lines 3 · disabling or conditional annotations 0 · ports, sockets, sleeps or 4-5 digit literals (string literals removed) 0 · header-name literals in it (\"Content-Type\", \"If-Match\", \"Idempotency-Key\") 0 · statuses as named constants 4" in t, "the test class: no disabling annotation, no port, no literal header name, statuses as constants")
    ok(grab(t, r"outside RateLimitFilterTest (\d+)") == "0", "R.555: 0 refusals at the default outside RateLimitFilterTest")
    ok(re.search(r"test files moved before -> after:  · new: InputHardeningTest\.java$", t, re.M) is not None, "no existing test file moved; one new")
    v = re.search(r"verify exit 0 · ITs tests (\d+) failures 0 errors 0 · classes (\d+)", t)
    ok(v is not None and v.group(1) == "14" and v.group(2) == "5", "verify: %s" % (v.group(0) if v else "absent"))
    vw = re.search(r"verify \| tiffinbox-web \| tests (\d+) failures 0 errors 0 skipped 0", t)
    ok(vw is not None and vw.group(1) == "88", "verify: the web module's Surefire tests 88")
    ok(re.search(r"IT bindings: [1-9]\d* lines · not 127\.0\.0\.1: 0", t) is not None, "IT bindings: all 127.0.0.1")
    ok("Testcontainers containers after: 0 · images pulled: 0" in t, "no container left, nothing pulled")
    ok("downloads across the builds: 0" in t, "0 downloads")
    finish("need=red(1/3) web=85->%s client=%s its=%s" % (w.group(1) if w else "", c.group(1) if c else "", v.group(1) if v else ""))


def c_harness(t):
    ok("harness/: bind.py chk22.py dur9.py norm.py ops9s3.py reach.py rec.py s922.py src tree22.py · harness/src: probe22/Bind.java probe22/Limits.java probe22b/Rec.java" in t, "the folder's files exactly")
    ok("cdp.mjs cdp9.mjs seal9.py chrome20.py loc9.py stub src/probe21 - 0 present" in t, "no instrument this unit does not carry")
    ok(re.search(r"a byte appended to after/compose\.yaml .*?: exit 1 · a FAIL names it: [1-9]", t) is not None, "static (ii) on a scratch copy moved by one byte: exit 1")
    ok("output md5 = (i): yes" in t, "static (iii) in a folder copy with no sibling anchor: the same output")
    ok("reading the live anchor (its folder name assembled) -> exit 1 · the same path from two pieces -> exit 1" in t, "flag 20's two plants exit 1")
    ok("counted by the receipts' own GNU-form grep: 1 (1 = caught)" in t, "R.564's GNU-sed plant counted")
    ok("c9-unit10/receipts.sh:611=1 c9-unit13/receipts.sh:334=1 c9-unit15/receipts.sh:396=1" in t, "the three frozen receipts' live-anchor pom lines, printed (findings, not edits)")
    finish("static=%s" % grab(t, r"as written: output md5 ([0-9a-f]{32})"))


def c_exercise(t):
    for sh in ("bash", "zsh"):
        bl = "\n".join(re.findall(r"^  broken %s \| (.*)$" % sh, t, re.M)); sl = "\n".join(re.findall(r"^  solved %s \| (.*)$" % sh, t, re.M))
        ok("check exit 1" in bl and "FAIL (1) another customer's id reached Ravi's row" in bl and "Ravi reads back: Ravi 404 · Mallory: Mallory 3 100 VEG" in bl, "broken, %s: FAIL (1) - Ravi's row overwritten (Ravi 404, Mallory)" % sh)
        ok("FAIL (2) another customer's id reached Priya's row" in bl, "broken, %s: FAIL (2) - Priya's row overwritten" % sh)
        ok("check exit 0" in sl and "\nPASS" in "\n" + sl and "Ravi reads back: Ravi 2 120 VEG · Mallory: Mallory 404" in sl and "Sunil reads back: Sunil 2 100 VEG" in sl, "solved, %s: PASS (Ravi and Priya untouched, Sunil written)" % sh)
    for v in ("none", "strict", "nowrite"):
        l = "\n".join(re.findall(r"^  ~ %s bash \| (.*)$" % v, t, re.M))
        if l: ok("check exit 1" in l, "refused variant %s: exit 1" % v)
    finish("broken=FAIL(ravi_overwritten) solved=PASS")


def c_title(t):
    n = grab(t, r'\((\d+) characters by len\(\)\)')
    ok(n is not None and int(n) <= 60, "the title for search: %s characters (<= 60)" % n)
    ok("a 'blocked' claim in it: 0" in t, "the title makes no blocked claim")
    finish("title_len=%s" % n)


CHECKS = {"advisory": c_advisory, "before": c_before, "change": c_change, "census": c_census, "drop": c_drop, "bind": c_bind, "record": c_record,
          "strict": c_strict, "key": c_key, "limits": c_limits, "spec": c_spec, "moved": c_moved, "api": c_api, "seven": c_seven,
          "surface": c_surface, "tests": c_tests, "harness": c_harness, "exercise": c_exercise, "title": c_title}

PLANTS = [("bind", r"(h2 \| case \| 1 existing id \| outcome: id=)another row overwritten \(row 1\)", r"\1not written", "the failure receipt typed not written"),
          ("bind", r"(the statuses, H2 against PostgreSQL 18\.6: )equal", r"\1DIFFER", "H2 and PostgreSQL typed different"),
          ("bind", r" \(the harness's route answers 409 for any exception\)", "", "the 409 unlabelled - read as TiffinBox's"),
          ("bind", r"the sent id's row \(row 1, Ravi\) at v0", "no id sent", "R.567's sent-id version dropped"),
          ("bind", r"(h2 \| key \| PROBE-KEY FAIL_ON_UNKNOWN_PROPERTIES=)false", r"\1true", "before's mapper typed strict"),
          ("record", r"(h2 \| read \| R2 record route, Mallory's body made whole \| GET /api/v1/customers/Ravi -> )200", r"\g<1>404", "the record route typed as overwriting"),
          ("record", r"(h2 \| read \| C1 control: .*?\| GET /api/v1/customers/Ravi -> )404", r"\g<1>200", "the control typed as not overwriting"),
          ("strict", r"(h2 \| \d+ lines, )3( moved)", r"\g<1>10\2", "the strict read typed as moving 10 (the key's count)"),
          ("strict", r"(the side-by-side file \(paste \+ awk, BSD-safe\): )\d+", r"\g<1>0", "R.564: an empty side-by-side file"),
          ("strict", r"(?m)(cannot be read at )admin$", r"\1version", "a 422 naming the wrong member"),
          ("key", r"(key-h2 \| \d+ lines, )10( moved)", r"\g<1>3\2", "the key typed as moving only the merge patch"),
          ("key", r"(key-h2 \| PROBE-KEY FAIL_ON_UNKNOWN_PROPERTIES=)true", r"\1false", "the key's mapper typed off"),
          ("drop", r"(drop before \| POST /customers .* -> )201", r"\g<1>400", "the hook's request typed refused on before"),
          ("drop", r"(the same grep on a copy with one planted WARN line: )1", r"\g<1>0", "R.566: the WARN grep's positive control missing"),
          ("drop", r"before -> after/: identical", "before -> after/: DIFFER", "the old POST typed as moved"),
          ("change", r"code lines added \(not comments\) 2", "code lines added (not comments) 3", "a second code line in src/main"),
          ("change", r"(yaml lines naming fail-on-unknown )0", r"\g<1>1", "the global key on the anchor"),
          ("change", r"(tiffinbox-web/pom.xml byte-equal to before's: )yes", r"\1no", "a pom touched"),
          ("before", r"(lines naming fail-on-unknown: )0", r"\g<1>1", "the key typed present on before"),
          ("tests", r"(need \| InputHardeningTest on before \| tests 3 failures )1", r"\g<1>0", "the need-measure typed green (the test does not see the change)"),
          ("tests", r"(package \| tiffinbox-web \| tests 88 failures 0 errors 0) skipped 0", r"\1 skipped 1", "Skipped typed 1"),
          ("tests", r"outside RateLimitFilterTest 0", "outside RateLimitFilterTest 1", "a refusal at the default"),
          ("tests", r"(header-name literals in it \(\"Content-Type\", \"If-Match\", \"Idempotency-Key\"\) )0", r"\g<1>1", "a header-name literal in the test"),
          ("seven", r"after: the seven ([0-9a-f]{31})[0-9a-f]", r"after: the seven \g<1>0", "the seven's md5 one character off"),
          ("surface", r"after: the old surface ([0-9a-f]{31})[0-9a-f]", r"after: the old surface \g<1>0", "the surface's md5 one character off"),
          ("moved", r"(BOOT-INF/lib names: before 167 · after )167", r"\g<1>164", "BOOT-INF/lib typed 164"),
          ("moved", r"(the web jar: entries \d+ -> \d+ · added 0 \[\] · removed 0 · shared entries whose CRC moved )2", r"\g<1>1", "only one web jar entry typed moved"),
          ("moved", r"(the core jar: entries \d+ -> \d+ · added 0 \[\] · removed 0 · shared entries whose CRC moved )0", r"\g<1>1", "a moved core entry"),
          ("api", r"(api \| before -> after/: )identical", r"\1DIFFER", "the census moved"),
          ("spec", r"a final newline\): equal", "a final newline): differ", "the committed file touched"),
          ("exercise", r"(  solved bash \| )check exit 0", r"\1check exit 1", "solution = broken"),
          ("exercise", r"(  broken zsh \| )check exit 1", r"\1check exit 0", "the broken copy typed passing"),
          ("advisory", r"run date (\S+)", "run date 2026-11-28", "the read one day older than the run"),
          ("spec", r"(  budget \| spec: requests under /api/v1/ \(its access log\): )\d+", r"\g<1>61", "a per-JVM request count above the cap"),
          ("spec", r"(  budget \| spec: requests under /api/v1/ \(its access log\): \d+ · refusal lines: )0", r"\g<1>1", "a refusal line in a default-capacity JVM"),
          ("limits", r"jackson-core 3\.1\.8", "jackson-core 3.0.0", "the limits read off another jar"),
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
    for nm, line in (("bind", "  h2 | case | garbage\n"), ("strict", "  MOVED h2 | garbage\n"), ("tests", "  package | garbage\n")):
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
            ok(not any(l.startswith(g) for l in r), "no second gloss line (%s)" % g)
        ok(sum(1 for l in r if l.startswith("Mass assignment:")) == 1 and GLOSS in r, "exactly one gloss line, Mass assignment:, byte for byte (%d words)" % len(GLOSS.split()))
        print("GLOSS %s (%d words)" % (GLOSS, len(GLOSS.split())))
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
