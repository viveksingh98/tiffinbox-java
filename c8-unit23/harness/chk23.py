"""Unit 23's checks (python3 -I -B harness/chk23.py NAME ARG...), each re-deriving its numbers from a capture or from the shipped files,
never from the README's prose; every check prints "ok ..." or "FAIL ...", and one "VALUES ..." line (what the video may say), and exits 1
on a FAIL. Names:
  static        the family base: s823.py's XFAM_S4B, TIMEPAT_S4B, XU19-XU22 blocks equal to s822.py's (md5), no XEXEMPT_S4B; u23check's
                XFAM_S4B_U23 lines equal to s822's XFAM_S4B lines; tree23.py's code = tree22.py's; dur8.py = unit 02's; and every body
                cell of table.md through dur8, XFAM_S4B and XU23 (0 hits)
  honestread    prints the honest capture: the numbers read off c8-unit01 statements, c8-unit18 oneread and rename, by section name
  rule FILE     the checker's report on the shipped table: exit 0, 25 cells, the measured / unmeasured counts, the seven named
  replay FILE   the five replays: each number beside its cell's number in table.md, equal
  honest FILE   PostgreSQL's cost cell in table.md carries exactly the numbers honest read
  feature FILE  the scratch copy with the feature word: exit 1, bad 1, the cell named; the shipped table exit 0 in the same run
  seven FILE MD5  the seven on the one tree: 7 lines, md5 = MD5 (unit 22's seven, read off its README's capture block)
  exercise FILE the exercise in bash and zsh: broken exit 1 bad 1, solved exit 0, unmeasured exit 1, a feature word elsewhere exit 1
  numbers README RULE  the voiced counts: "twenty-five cells", "N of them unmeasured" = the checker's count, the five replays' numbers
  cellof STORE COLUMN  prints that cell of table.md (the receipt prints each replay's cell beside its number)"""
import hashlib, importlib.util, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__)); U = os.path.dirname(HERE); REPO = os.path.dirname(U)
FAILS = []; VALUES = []


def ok(c, msg):
    print(("ok " if c else "FAIL ") + msg)
    if not c: FAILS.append(msg)


def rd(p): return open(p, encoding="utf-8").read()


def block(src, start):
    """The text from the line that starts with `start` to the next line that is exactly '}' (a dict) or the line itself (a one-liner)."""
    i = src.find("\n" + start)
    if i < 0: return None
    i += 1
    if src[i:].split("\n", 1)[0].rstrip().endswith("{"):
        j = src.find("\n}\n", i); return src[i:j + 2]
    return src[i:].split("\n", 1)[0]


def md5(s): return hashlib.md5(s.encode()).hexdigest() if s is not None else None


def ck():
    spec = importlib.util.spec_from_file_location("u23check", os.path.join(HERE, "u23check.py")); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m); return m


def table():
    m = ck(); rows = m.parse(rd(os.path.join(U, "table.md")))
    return {(r[0], c): r[i + 1] for r in rows for i, c in enumerate(m.COLS)}


def cnum(cell, cap):
    """The numbers of the cell's segment for one capture reference."""
    i = cell.find("`" + cap + "`")
    if i < 0: return None
    rest = cell[i + len(cap) + 2:]; j = rest.find("`unit")
    return re.findall(r"(?<![\w.])\d+(?![\w])", rest if j < 0 else rest[:j])


def static():
    s3, s2 = rd(os.path.join(HERE, "s823.py")), rd(os.path.join(REPO, "c8-unit22", "harness", "s822.py"))
    for b in ("XFAM_S4B = {", "TIMEPAT_S4B = re.compile(", "XU19 = {", "XU20 = {", "XU21 = {", "XU22 = {"):
        x, y = block(s3, b), block(s2, b)
        ok(x is not None and md5(x) == md5(y), "%s s823.py = s822.py's slice (md5 %s)" % (b.split(" ")[0], md5(x)))
    ok(not re.search(r"^XEXEMPT_S4B\s*=", s3, re.M), "no XEXEMPT_S4B in s823.py (§BUILDERS 3)")
    u = rd(os.path.join(HERE, "u23check.py"))
    xf = block(s2, "XFAM_S4B = {").split("\n")
    for name in ("S4B: best database / right tool (U23)", "S4B: a vector store promise (flag 10)"):
        a = [l for l in u.split("\n") if l.strip().startswith('"' + name + '"')]
        b = [l for l in xf if l.strip().startswith('"' + name + '"')]
        ok(len(a) == 1 and len(b) == 1 and a[0].strip() == b[0].strip(), "u23check.py's XFAM_S4B_U23 member \"%s\" = s822.py's line, byte for byte" % name)
    t3 = rd(os.path.join(HERE, "tree23.py")).split('"""', 2)[2]; t2 = rd(os.path.join(REPO, "c8-unit22", "harness", "tree22.py")).split('"""', 2)[2]
    ok(t3 == t2, "tree23.py's code = tree22.py's (the docstring alone names unit 23)")
    ok(rd(os.path.join(HERE, "dur8.py")) == rd(os.path.join(REPO, "c8-unit02", "harness", "dur8.py")), "dur8.py = unit 02's, byte for byte")
    # every body cell through dur8, XFAM_S4B and XU23 (the cells are quotes of captures: their numbers are the captures')
    sys.argv = [sys.argv[0], os.path.join(HERE, "dur8.py")]
    sp = importlib.util.spec_from_file_location("s823", os.path.join(HERE, "s823.py")); g = importlib.util.module_from_spec(sp)
    import io, contextlib
    with contextlib.redirect_stdout(io.StringIO()): sp.loader.exec_module(g)
    hits = []
    for k, c in table().items():
        v = [w.group(0) for w in g.m.DUR.finditer(c)] + g.s4b(c, c) + g.u23(c, c)
        if v: hits.append("%s · %s: %s" % (k[0], k[1], v))
    ok(not hits, "the 25 body cells through dur8, XFAM_S4B and XU23: %d hits%s" % (len(hits), (" - " + "; ".join(hits[:3])) if hits else ""))
    VALUES.append("the family base byte-equal to unit 22's")


def sec(unit, cap):
    m = ck(); s = m.section(unit, cap)
    return s


def honestread():
    s1 = sec("01", "statements"); s4 = sec("18", "oneread"); s5 = sec("18", "rename")
    def grab(s, pat):
        for l in s[2]:
            m = re.search(pat, l)
            if m: return m
        return None
    j = grab(s1, r"page Spring Data JDBC .*the witness (\d+) · of them SELECTs from pause by customer_id (\d+)")
    p = grab(s1, r"page JPA: the witness (\d+) · Hibernate getPrepareStatementCount\(\) (\d+)")
    jz = grab(s1, r"page Spring Data JDBC .*Hibernate getPrepareStatementCount\(\) (\d+)")
    o = grab(s4, r"rows \(psql -At \| wc -l\): (\d+) · PostgreSQL's log between the markers: statements (\d+) · JOIN in it (\d+)")
    r3 = grab(s5, r"the three tables, labelled .*-> UPDATE (\d+)")
    r4 = grab(s5, r"the four tables: .*-> UPDATE (\d+)")
    mg = grab(s5, r"op update · ns tiffinbox\.menu · nMatched (\d+) · nModified (\d+)")
    print("-- honest: PostgreSQL's cost cell, each number read off the shipped capture by its section's name (S8.97), never typed:")
    print("  c8-unit01/README.md :%d (statements, %s): Spring Data JDBC's page, the witness %s · of them SELECTs from pause by customer_id %s · its Hibernate getPrepareStatementCount() %s" % (s1[0], s1[1], j.group(1), j.group(2), jz.group(1)))
    print("  c8-unit01/README.md :%d (statements): Spring Data JPA's page, the witness %s · Hibernate getPrepareStatementCount() %s - C8-9's pinned counter applies here, to the JPA side's %s; the JDBC witness %s is datasource-proxy's, not Hibernate's counter" % (s1[0], p.group(1), p.group(2), p.group(1), j.group(1)))
    print("  c8-unit18/README.md :%d (oneread, %s): PostgreSQL's four tables, one menu: statements %s · JOIN in it %s · rows %s" % (s4[0], s4[1], o.group(2), o.group(3), o.group(1)))
    print("  c8-unit18/README.md :%d (rename, %s): the three tables, labelled: UPDATE %s · the four tables: UPDATE %s · MongoDB's half: one update op, nMatched %s · nModified %s" % (s5[0], s5[1], r3.group(1), r4.group(1), mg.group(1), mg.group(2)))


def honest(f):
    t = rd(f); c = table()[("PostgreSQL", "a cost that grows")]
    j = re.search(r"the witness (\d+) · of them SELECTs from pause by customer_id (\d+)", t); p = re.search(r"Spring Data JPA's page, the witness (\d+) · Hibernate getPrepareStatementCount\(\) (\d+)", t)
    o = re.search(r"statements (\d+) · JOIN in it (\d+) · rows (\d+)", t); r = re.search(r"the three tables, labelled: UPDATE (\d+) · the four tables: UPDATE (\d+) · MongoDB's half: one update op, nMatched (\d+) · nModified (\d+)", t)
    ok(all([j, p, o, r]), "honest printed the four readings")
    if not all([j, p, o, r]): return
    ok(p.group(1) == p.group(2), "C8-9's counter = the JPA witness (%s = %s)" % (p.group(2), p.group(1)))
    ok(cnum(c, "unit01/statements") == [j.group(1), j.group(2), p.group(1)], "the cost cell's unit01/statements numbers %s = honest's [%s, %s, %s]" % (cnum(c, "unit01/statements"), j.group(1), j.group(2), p.group(1)))
    ok(cnum(c, "unit18/oneread") == [o.group(1), o.group(2), o.group(3)], "the cost cell's unit18/oneread numbers %s = honest's [%s, %s, %s]" % (cnum(c, "unit18/oneread"), o.group(1), o.group(2), o.group(3)))
    ok(cnum(c, "unit18/rename") == [r.group(1), r.group(4)], "the cost cell's unit18/rename numbers %s = honest's [%s, %s] (three tables, MongoDB's documents)" % (cnum(c, "unit18/rename"), r.group(1), r.group(4)))
    ok(r.group(1) == r.group(4), "the tie: the three tables' UPDATE %s = MongoDB's nModified %s" % (r.group(1), r.group(4)))
    VALUES.append("honest: Spring Data JDBC's page the witness %s (%s of them one SELECT per customer) beside JPA's %s (getPrepareStatementCount %s); oneread statements %s, JOIN %s, rows %s; rename three tables UPDATE %s, MongoDB nModified %s (the four tables UPDATE %s)" % (j.group(1), j.group(2), p.group(1), p.group(2), o.group(1), o.group(2), o.group(3), r.group(1), r.group(4), r.group(2)))


def rule(f):
    t = rd(f)
    e = re.search(r"^  the checker's exit: (\d+)$", t, re.M); last = re.search(r"^cells (\d+) · measured (\d+) · unmeasured (\d+) · bad (\d+)$", t, re.M)
    ok(e and e.group(1) == "0", "rule: the checker's exit 0 on the shipped table")
    ok(bool(last), "rule: the checker's count line")
    if not last: return
    cells = len(re.findall(r"^cell ", t, re.M)); un = re.search(r"^unmeasured \((\d+)\): (.*)$", t, re.M)
    names = un.group(2).split("; ") if un else []
    ok(cells == int(last.group(1)) == 25, "rule: 25 cells, each with its line (%d)" % cells)
    ok(len(names) == int(un.group(1)) == int(last.group(3)), "rule: the unmeasured cells named %d = the count %s" % (len(names), last.group(3)))
    ok(int(last.group(2)) + int(last.group(3)) == 25 and last.group(4) == "0", "rule: measured %s + unmeasured %s = 25, bad 0" % (last.group(2), last.group(3)))
    meas_lines = len(re.findall(r"^cell .*: \d+ capture\(s\)$", t, re.M))
    ok(meas_lines == int(last.group(2)), "rule: the cells with a capture, counted off their lines (%d) = measured %s" % (meas_lines, last.group(2)))
    bs = re.search(r"Sections 1-3 (\d+) · Section 4 Part A (\d+) · Section 4 Part B (\d+)", t)
    ok(bs and sum(map(int, bs.groups())) == int(last.group(2)), "rule: by section %s add up to measured" % (bs.groups() if bs else None,))
    refs = re.findall(r"^  (unit\d\d/[a-z0-9]+) · class (\S+) · c8-unit\d\d/README\.md :(\d+) · receipts\.md5 \"([a-z0-9]+) ([0-9a-f]{32})\"", t, re.M)
    ok(len(refs) >= int(last.group(2)), "rule: every capture reference printed with its README line and its md5 line (%d)" % len(refs))
    VALUES.append("rule: 25 cells, %s measured, %s unmeasured (%s), by section 1-3 %s / 4A %s / 4B %s, checker exit 0" % (last.group(2), last.group(3), "; ".join(names), *bs.groups()))


def replay(f):
    t = rd(f); c = table()
    def num(pat):
        m = re.search(pat, t, re.M); return m
    r1 = num(r"^  the three tables, labelled: \$ psql -c \"UPDATE f3\.item_allergen SET allergen = 'soya' WHERE allergen = 'soy'\" -> UPDATE (\d+)$")
    ok(bool(r1) and cnum(c[("PostgreSQL", "a cost that grows")], "unit18/rename")[0] == r1.group(1), "replay 1 PostgreSQL: UPDATE %s = the cell's unit18/rename %s" % (r1 and r1.group(1), cnum(c[("PostgreSQL", "a cost that grows")], "unit18/rename")[0]))
    m1 = num(r"rows: f3\.menu (\d+) · f3\.menu_item (\d+) · f3\.item_allergen (\d+) · of them soy (\d+)")
    ok(bool(m1) and m1.group(4) == r1.group(1), "replay 1: the rows the UPDATE touched = the soy rows counted before it (%s)" % (m1 and m1.group(4)))
    r2 = num(r"^  PROBE stale: the read, the write around the cache, the read again \(PostgreSQL [0-9.]+, in the JVM, Caffeine\): .* the cached read says (\d+), the row now (\d+) \(JdbcTemplate\)$")
    p2 = num(r"^  the receipt at pause 1, psql \(a second client, PostgreSQL\): Ravi's row says (\d+)$")
    ok(bool(r2) and [r2.group(1), r2.group(2)] == cnum(c[("Caffeine", "a silent wrong answer")], "unit12/stale"), "replay 2 Caffeine: the cached read says %s, the row now %s = the cell's %s" % (r2 and r2.group(1), r2 and r2.group(2), cnum(c[("Caffeine", "a silent wrong answer")], "unit12/stale")))
    ok(bool(p2) and r2 and p2.group(1) == r2.group(2), "replay 2: psql's row (%s) = the row the JVM read back" % (p2 and p2.group(1)))
    r3 = num(r"^  the JVM's exit: (\d+) · then curl /actuator/health on 20620: (\d+) · listening on 20620: 0$")
    ok(bool(r3) and [r3.group(1), r3.group(2)] == cnum(c[("Redis", "the store absent at start")], "unit14/absent"), "replay 3 Redis absent: exit %s, health %s = the cell's %s" % (r3 and r3.group(1), r3 and r3.group(2), cnum(c[("Redis", "the store absent at start")], "unit14/absent")))
    b3 = num(r"^  its first exception line: (Error creating bean with name '[a-zA-Z]+')")
    ok(bool(b3) and bool(num(r"RedisConnectionFailureException: Unable to connect to Redis\" 1")), "replay 3: the bean its log names first (%s) and the Redis connection failure, counted" % (b3 and b3.group(1)))
    r4 = num(r"^  PROBE summeal: groups (\d+) · sorted by total, then _id: (.*) · their sum (\d+)$")
    tot = re.findall(r"[A-Z][a-z]+ (\d+)", r4.group(2)) if r4 else []
    ok(bool(r4) and len(tot) == int(r4.group(1)) and set(tot) == {"0"} and r4.group(3) == "0", "replay 4 MongoDB: groups %s, every total 0, their sum %s" % (r4 and r4.group(1), r4 and r4.group(3)))
    ok(bool(r4) and [r4.group(1), "0", r4.group(3)] == cnum(c[("MongoDB", "a silent wrong answer")], "unit19/silent"), "replay 4: = the cell's %s" % cnum(c[("MongoDB", "a silent wrong answer")], "unit19/silent"))
    k4 = num(r"^  PROBE pipeline: groups (\d+) · sorted by total, then _id: .* · their sum (\d+)$")
    ok(bool(k4) and k4.group(1) == "4" and int(k4.group(2)) > 0, "replay 4: the control in the same JVM, sum(\"value\"), groups %s, their sum %s" % (k4 and k4.group(1), k4 and k4.group(2)))
    ok(not num(r"lines naming an Exception [1-9]"), "replay 4: no Exception line in the harness JVM's log")
    r5 = num(r"^  curl on 20624: dishes_std match name veg -> (\d+) \[\]$")
    ok(bool(r5) and [r5.group(1)] == cnum(c[("Elasticsearch", "a silent wrong answer")], "unit21/nohit"), "replay 5 Elasticsearch: dishes_std veg -> %s [] = the cell's %s" % (r5 and r5.group(1), cnum(c[("Elasticsearch", "a silent wrong answer")], "unit21/nohit")))
    c5 = num(r"^  curl on 20624: dishes_std match name vegetarian -> 1 \[1\] · the shipped dishes match name veg -> 1 \[1\]$")
    g5 = num(r"^  GET /dishes/search\?q=veg \(TiffinBox, 20620\) -> 200 \[\{\"id\":\"1\",\"name\":\"Vegetarian Lunch Box\"")
    ok(bool(c5) and bool(g5), "replay 5: the controls in the same run - vegetarian 1 [1] on dishes_std, the shipped dishes veg 1 [1] by curl and by TiffinBox")
    n5 = num(r"_cat/indices dishes_std -> dishes_std green open 1 0 (\d+)"); pr = num(r"the rows \(psql, c8u23-pg, the dev start's V4\): (\d+)")
    ok(bool(n5) and bool(pr) and n5.group(1) == pr.group(1) == "10", "replay 5: the ten rows indexed, _cat/indices %s = psql %s" % (n5 and n5.group(1), pr and pr.group(1)))
    ok(bool(num(r"DELETE /dishes_std -> acknowledged true")), "replay 5: dishes_std deleted")
    VALUES.append("replay (22/after): 1 PostgreSQL three tables UPDATE %s · 2 Caffeine the cached read says %s, the row now %s · 3 Redis absent exit %s, health %s (%s) · 4 MongoDB $sum over a String, groups %s, every total 0 · 5 Elasticsearch dishes_std veg %s []" % (r1 and r1.group(1), r2 and r2.group(1), r2 and r2.group(2), r3 and r3.group(1), r3 and r3.group(2), b3 and b3.group(1), r4 and r4.group(1), r5 and r5.group(1)))


def feature(f):
    t = rd(f)
    a = re.search(r"^  the copy with the feature word: the checker's exit (\d+) · (cells 25 · measured \d+ · unmeasured \d+ · bad (\d+))$", t, re.M)
    b = re.search(r"^  the shipped table, the same run: the checker's exit (\d+) · cells 25 · measured \d+ · unmeasured \d+ · bad (\d+)$", t, re.M)
    n = re.findall(r"^BAD (.*)$", t, re.M)
    ok(bool(a) and a.group(1) == "1" and a.group(3) == "1", "feature: the copy exits 1, bad 1")
    ok(len(n) == 1 and n[0].startswith("Elasticsearch · a silent wrong answer:") and "a feature word: powerful" in n[0], "feature: the one bad cell is the Elasticsearch silent-wrong-answer cell, its feature word named")
    ok(bool(b) and b.group(1) == "0" and b.group(2) == "0", "feature: the shipped table exits 0 in the same run")
    VALUES.append("feature: powerful full-text search in the Elasticsearch silent-wrong-answer cell -> exit 1, bad 1; the shipped table exit 0")


def seven(f, want):
    t = rd(f); m = re.search(r"exit 0 · the seven responses: (\d+) lines · md5 ([0-9a-f]{32})", t)
    ok(bool(m) and m.group(1) == "7" and m.group(2) == want, "seven: 7 lines, md5 = unit 22's (%s)" % want)
    VALUES.append("the seven: md5 %s on the one tree" % (m and m.group(2)))


def exercise(f):
    t = rd(f)
    for sh in ("bash", "zsh"):
        sec_ = t.split("in %s " % sh, 1)[1] if ("in %s " % sh) in t else ""
        sec_ = sec_.split("\nin zsh ", 1)[0]
        b = re.search(r"the README's lines: exit (\d+) · (cells 25 · measured \d+ · unmeasured \d+ · bad (\d+))", sec_)
        s = re.search(r"SOLUTION\.md's lines: exit (\d+) · cells 25 · measured \d+ · unmeasured \d+ · bad (\d+)", sec_)
        ok(bool(b) and b.group(1) == "1" and b.group(3) == "1", "exercise (%s): the broken table exit 1, bad 1" % sh)
        ok(bool(s) and s.group(1) == "0" and s.group(2) == "0", "exercise (%s): the solution exit 0, bad 0" % sh)
    u = re.search(r"\"unmeasured\" in that cell: exit (\d+) · bad (\d+)", t); fw = re.search(r"a feature word elsewhere .*: exit (\d+) · bad (\d+)", t)
    ok(bool(u) and u.groups() == ("1", "1"), "exercise: \"unmeasured\" in the measured cell -> exit 1, bad 1 (the checker's list knows the capture)")
    ok(bool(fw) and fw.group(1) == "1", "exercise: a feature word in another cell -> exit 1")
    VALUES.append("exercise: broken exit 1 bad 1, solved exit 0, unmeasured in that cell exit 1, a feature word elsewhere exit 1")


W = {"zero": 0, "one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10, "eleven": 11, "twelve": 12,
     "eighteen": 18, "twenty-five": 25, "thirty": 30}


def numbers(readme, rulef):
    t = rd(readme); r = rd(rulef)
    last = re.search(r"^cells (\d+) · measured (\d+) · unmeasured (\d+)", r, re.M)
    for m in re.finditer(r"\b(twenty-five|\d+)\s+cells\b", t, re.I):
        v = W.get(m.group(1).lower(), None) if not m.group(1).isdigit() else int(m.group(1))
        ok(v == int(last.group(1)), "S8.95: \"%s\" = the checker's %s cells" % (m.group(0), last.group(1)))
    hits = list(re.finditer(r"\b([a-z-]+|\d+)\s+of\s+them\s+unmeasured\b", t, re.I))
    ok(len(hits) >= 1, "S8.95: the gloss's \"N of them unmeasured\" is said")
    for m in hits:
        v = W.get(m.group(1).lower(), None) if not m.group(1).isdigit() else int(m.group(1))
        ok(v == int(last.group(3)), "S8.95: \"%s\" = the checker's unmeasured %s" % (m.group(0), last.group(3)))
    for m in re.finditer(r"\b([a-z-]+|\d+)\s+(?:of\s+them|cells)\s+measured\b", t, re.I):
        if m.group(1).lower() in W or m.group(1).isdigit():
            v = W.get(m.group(1).lower()) if not m.group(1).isdigit() else int(m.group(1))
            ok(v == int(last.group(2)), "S8.95: \"%s\" = the checker's measured %s" % (m.group(0), last.group(2)))
    VALUES.append("numbers: 25 cells, %s unmeasured, %s measured - the checker's" % (last.group(3), last.group(2)))


def main(a):
    n = a[0]
    if n == "static": static()
    elif n == "honestread": honestread(); return 0
    elif n == "cellof": print(table()[(a[1], a[2])]); return 0
    elif n == "rule": rule(a[1])
    elif n == "replay": replay(a[1])
    elif n == "honest": honest(a[1])
    elif n == "feature": feature(a[1])
    elif n == "seven": seven(a[1], a[2])
    elif n == "exercise": exercise(a[1])
    elif n == "numbers": numbers(a[1], a[2])
    else: print("FAIL no check named " + n); return 1
    print("VALUES " + " · ".join(VALUES))
    return 1 if FAILS else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
