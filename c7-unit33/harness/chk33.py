"""Unit 33's checks (python3 -I -B harness/chk33.py MODE FILE [ARG...]): every number and string the video says, read off its capture
and asserted against another witness of the same run - never against a typed figure. Each mode prints one line per check and a VALUES
line (the values the video may say, composed from what it read). Exit 1 on the first failed check.
  batch    per database: the version lines; the key read off the EntityManagerFactory; N read off the run; per step the three statement
           witnesses (Statistics, the SQL logger, the proxy's prepareStatement) and the batching witnesses (addBatch, executeBatch,
           executeUpdate), the sequence calls counted in the logger's texts, the rows read back, the batch TRACE's counts. IDENTITY (both
           entities): statements = N and executeBatch 0 with the key and without it (R.206); SEQUENCE with the key: statements = the
           sequence calls + 1, addBatch N, executeBatch derived ceil(N / batch_size), the SQL log's lines = the calls + N (printed beside,
           never a witness); saveAll the same derivation; HHH100501 once per keyed JVM, 0 without; H2 = PostgreSQL but the sequence call
  order    per database: without order_inserts executeBatch = addBatch = 2N (a batch per insert), statements = 2N + the calls; with it
           executeBatch = 2 ceil(N / batch_size), statements = the calls + 2
  updates  per database: M = the customers read back (4 + N); with the key statements 2, addBatch M, executeBatch ceil(M / batch_size),
           executeUpdate 0, M rows at version 1, the UPDATE's text ends "where id=? and version=?"; without it statements M + 1,
           executeUpdate M; batch_versioned_data=false (read off) the same counts as the key alone; the grep -a: 0 files hold
           batch_versioned_data, BatchSettings holds the three keys (S5.10)
  chunk    no clear: getEntityCount() = N before the commit, executeBatch N / 50; flush() + clear() every 50: the largest = the batch
           size, 0 at the end, the same executeBatch, statements = the calls + N / 50 (each flush prepares its INSERT again)
  flush    per database: the call order printed; the SQL during the calls only the sequence call; at the commit (after "Initiating
           transaction commit") inserts, then updates, then deletes, whatever the call order; the second connection's rows
  time     per JVM: the design, every round's order (even rounds the base order, odd rounds reversed: R.300), every run's rows read back,
           executeBatch per run (SEQUENCE batch 50: N / 50, the other three 0), the figures masked; PostgreSQL's threshold line true in
           each; then the run's table (.r-time.table): at least ten JVMs per database (R.236), every PostgreSQL SEQUENCE ratio >= T, the
           margin printed
  table    a time table (README.md's, between its markers): the same reading - at least ten rows per database, every PostgreSQL
           SEQUENCE ratio >= T, the margin line = the smallest PostgreSQL ratio - T
  anchor   the labelled copy: the derive's edits, the four files, its tests (a guard), its DDL's md5 and the lines that differ, the
           import (added = the file's lines = the transactions = the "Adding to JDBC batch (1 / 50)" lines, SQL lines = added + the
           sequence calls), the ids on the second connection, the seven = the pinned md5; the anchor with the key: 0 batch lines"""
import math
import re
import sys

mode, files = sys.argv[1], sys.argv[2:]
VALS = []


def need(ok, what):
    print(("  ok    " if ok else "  FAIL  ") + what)
    if not ok:
        sys.exit(1)


def read(f):
    return open(f, encoding="utf-8").read()


VERS = ["  PROBE Hibernate ORM core version (org.hibernate.Version.getVersionString()): 7.4.13.Final",
        "  INFO  [main] org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final",
        "  PROBE Spring Data JPA version (JpaRepository.class.getPackage().getImplementationVersion()): 4.1.2",
        "  PROBE Spring Framework version (Transactional.class.getPackage().getImplementationVersion()): 7.0.10"]
CNT = re.compile(r"PROBE counts: statements: Statistics\.getPrepareStatementCount (\d+) · org\.hibernate\.SQL lines (\d+) · JDBC proxy prepareStatement (\d+) "
                 r"\| batching: JDBC proxy addBatch (\d+) · executeBatch (\d+) · executeUpdate (\d+)$")
TRC = re.compile(r"batch TRACE in this step \(org\.hibernate\.orm\.jdbc\.batch, counted, not shown\): Adding to JDBC batch (\d+) \(at \(1 / 50\): (\d+), at \(50 / 50\): (\d+)\) "
                 r"· Created JDBC batch (\d+) · Executing JDBC batch (\d+)")
SEQ = re.compile(r"^(?:select next value for \w+|select nextval\('\w+'\))$")


def jvms(t):
    """The capture cut at each harness JVM's command line: a list of (the JVM's lines)."""
    out, cur = [], None
    for line in t.splitlines():
        if line.startswith("$ cd .harness/run && ") and "probe.b.Main" in line:
            cur = [line]; out.append(cur)
        elif line.startswith("$ cd .harness/run && "):
            cur = None
        elif cur is not None:
            cur.append(line)
    return out


def info(b):
    d = {"lines": b, "keys": {}, "steps": [], "db": None, "N": None, "exit": None}
    vers(b)
    cur = None
    for l in b:
        m = re.match(r"  PROBE database: (H2 [\d.]+|PostgreSQL [\d.]+) \|", l)
        if m: d["db"] = m.group(1)
        m = re.match(r"  PROBE key \(EntityManagerFactory\.getProperties\(\)\): (\S+) = (\S+)$", l)
        if m: d["keys"][m.group(1)] = m.group(2)
        m = re.match(r"  PROBE N = (\d+)$", l)
        if m: d["N"] = int(m.group(1))
        m = re.match(r"  exit (\d+) · 'GenerationTarget encountered exception': (\d+)$", l)
        if m: d["exit"] = (int(m.group(1)), int(m.group(2)))
        m = re.match(r"  exit (\d+) · on (?:H2|PostgreSQL), JVM \d+: ", l)
        if m: d["exit"] = (int(m.group(1)), 0)
        m = re.match(r"  its WARN lines \(grep -c '\^WARN '\): (\d+) · HHH100501 lines \(grep -c\): (\d+)$", l)
        if m: d["warn"], d["hhh"] = int(m.group(1)), int(m.group(2))
        if l.startswith("  PROBE >>> "):
            cur = {"label": l[len("  PROBE >>> "):], "lines": []}; d["steps"].append(cur); continue
        if cur is not None:
            cur["lines"].append(l)
            m = CNT.search(l)
            if m: cur["c"] = tuple(int(x) for x in m.groups())
            m = re.match(r"  PROBE result: (.*)$", l)
            if m: cur["result"] = m.group(1)
            m = re.match(r"  PROBE SQL texts \(org\.hibernate\.SQL, each once, in first-seen order\): (.*)$", l)
            if m:
                cur["texts"] = [] if m.group(1) == "none" else [(int(x.split(" x ", 1)[0]), x.split(" x ", 1)[1]) for x in m.group(1).split(" ; ")]
            m = TRC.search(l)
            if m: cur["trace"] = tuple(int(x) for x in m.groups())
            if l.startswith("  PROBE <<< "): cur = None
    need(d["db"] is not None and d["exit"] == (0, 0), "a JVM on %s: exit 0, no schema failure" % d["db"])
    return d


def vers(b):
    for v in VERS:
        need(b.count(v) == 1, "the version line once in the JVM: %s" % v.strip())


def seqcalls(s):
    return sum(n for n, t in s.get("texts", []) if SEQ.match(t))


def step(d, frag):
    st = [s for s in d["steps"] if frag in s["label"]]
    need(len(st) == 1 and "c" in st[0], "%s: the step '%s' ran once and printed its counts" % (d["db"], frag))
    return st[0]


def three(s, what):
    a, b, c = s["c"][0], s["c"][1], s["c"][2]
    return a, b, c


def bydb(ds):
    out = {}
    for d in ds:
        out.setdefault(d["db"].split()[0], []).append(d)
    return out


def rows(s, rx):
    m = re.search(rx, s.get("result", ""))
    need(m is not None, "the rows read back: %s" % s.get("result", "-"))
    return [int(x) for x in m.groups()]


if mode == "batch":
    ds = [info(b) for b in jvms(read(files[0]))]
    per = bydb(ds)
    need(sorted(per) == ["H2", "PostgreSQL"] and all(len(v) == 2 for v in per.values()), "two JVMs per database: without the key, then with it")
    res = {}
    for db, (d0, d1) in per.items():
        N = d0["N"]; need(N == d1["N"] and N > 0, "%s: N read off the run, the same in both JVMs: %s" % (db, N))
        need(d0["keys"].get("hibernate.jdbc.batch_size") == "null", "%s: the first JVM has no batch size (read off the EntityManagerFactory)" % db)
        B = d1["keys"].get("hibernate.jdbc.batch_size", "null"); need(B.isdigit(), "%s: the second JVM's hibernate.jdbc.batch_size read off: %s" % (db, B)); B = int(B)
        need(d0.get("hhh") == 0 and d1.get("hhh") == 1, "%s: HHH100501 0 without the key, 1 with it (Boot's INFO line, never a witness)" % db)
        r = {}
        for tag, d in (("off", d0), ("on", d1)):
            for frag, k in (("IDENTITY (probe.b.ent.XIdent", "ident"), ("SEQUENCE allocationSize 50", "seq"), ("the anchor's com.tiffinbox.CustomerEntity", "cust")):
                s = step(d, frag); a, b, c = three(s, frag); ab, eb, eu = s["c"][3:]
                calls = seqcalls(s); tr = s.get("trace")
                need(tr is not None, "%s %s %s: the batch TRACE counted" % (db, tag, k))
                if k == "ident" or k == "cust":
                    if k == "ident": need(rows(s, r"x_ident (\d+)$") == [N], "%s %s IDENTITY: rows read back = N" % (db, tag))
                    else:
                        bf, af = rows(s, r"customer (\d+) before, (\d+) after$"); need(af - bf == N, "%s %s CustomerEntity: rows %d -> %d, N added" % (db, tag, bf, af))
                    need(a == b == c == N, "%s %s %s: statements by three witnesses = N: %d · %d · %d" % (db, tag, k, a, b, c))
                    need(ab == 0 and eb == 0 and eu == N, "%s %s %s: addBatch 0 · executeBatch 0 · executeUpdate N (R.206: an identity INSERT never joins a batch)" % (db, tag, k))
                    need(tr[0] == 0 and tr[4] == 0, "%s %s %s: the batch TRACE: 0 'Adding to JDBC batch', 0 'Executing JDBC batch'" % (db, tag, k))
                    need(calls == 0, "%s %s %s: no sequence call" % (db, tag, k))
                else:
                    need(rows(s, r"x_seq (\d+)$") == [N], "%s %s SEQUENCE: rows read back = N" % (db, tag))
                    need(calls > 0 and b == calls + N, "%s %s SEQUENCE: the SQL log's lines = the sequence calls + N: %d = %d + %d" % (db, tag, b, calls, N))
                    if tag == "off":
                        need(a == c == calls + N and ab == 0 and eb == 0 and eu == N, "%s off SEQUENCE: statements %d = %d calls + N, executeBatch 0, executeUpdate N" % (db, a, calls))
                    else:
                        want = math.ceil(N / B)
                        need(a == c == calls + 1, "%s on SEQUENCE: statements by Statistics and the proxy = the calls + 1 prepared INSERT: %d · %d = %d + 1" % (db, a, c, calls))
                        need(b != a, "%s on SEQUENCE: the SQL log's lines (%d) are not the statements (%d) - the log is never a batch witness (R.206)" % (db, b, a))
                        need(ab == N and eb == want and eu == 0, "%s on SEQUENCE: addBatch N, executeBatch = ceil(N / batch_size) = ceil(%d / %d) = %d" % (db, N, B, want))
                        need(tr[0] == N and tr[2] == N // B and tr[4] == want, "%s on SEQUENCE: the batch TRACE: Adding %d (N), at (50 / 50) %d, Executing %d (= executeBatch)" % (db, tr[0], tr[2], tr[4]))
                r[(tag, k)] = (a, b, c, ab, eb, eu, calls)
        s = step(d1, "saveAll"); a, b, c = three(s, "saveAll"); ab, eb, eu = s["c"][3:]; calls = seqcalls(s)
        bf, af = rows(s, r"x_seq (\d+) before, (\d+) after$")
        need(af - bf == N and a == c == calls + 1 and ab == N and eb == math.ceil(N / B), "%s saveAll: rows +N, statements %d = %d calls + 1, addBatch N, executeBatch ceil(N / batch_size) = %d" % (db, a, calls, eb))
        need([x for x in d0["steps"] if "saveAll" in x["label"]] == [], "%s: saveAll runs only with the key" % db)
        r["saveAll"] = (a, b, c, ab, eb, eu, calls)
        seqtext = [t for s2 in d1["steps"] for n, t in s2.get("texts", []) if SEQ.match(t)]
        r["seqtext"] = sorted(set(seqtext)); r["N"] = N; r["B"] = B
        r["insert"] = [t for n, t in step(d1, "SEQUENCE allocationSize 50")["texts"] if t.startswith("insert")][0]
        res[db] = r
    h, p = res["H2"], res["PostgreSQL"]
    same = all(h[k] == p[k] for k in h if k not in ("seqtext",))
    need(same, "H2 = PostgreSQL for every count, the INSERT's text included")
    need(h["seqtext"] == ["select next value for x_seq_seq"] and p["seqtext"] == ["select nextval('x_seq_seq')"], "the sequence call, two database: lines: H2 %s · PostgreSQL %s" % (h["seqtext"], p["seqtext"]))
    t = read(files[0])
    first = re.search(r"first: (Adding to JDBC batch \(1 / 50\) - \[probe\.b\.ent\.XSeq#INSERT\])", t)
    need(first is not None, "the TRACE's first line: %s" % (first.group(1) if first else "-"))
    N, B = h["N"], h["B"]
    f = lambda k: "statements %d · SQL lines %d · prepareStatement %d · addBatch %d · executeBatch %d · executeUpdate %d" % k[:6]
    VALS.append("N = %d persists in one transaction; without a batch size: IDENTITY %s; SEQUENCE %s (sequence calls %d); the anchor's CustomerEntity %s ; with hibernate.jdbc.batch_size=%d: IDENTITY %s; the anchor's CustomerEntity %s (the failure receipt); SEQUENCE %s (sequence calls %d) - the SQL log's %d lines beside its %d statements, never a witness; derived ceil(%d / %d) = %d; saveAll %s; the batch TRACE %s ×%d, at (50 / 50) ×%d; HHH100501 once per keyed JVM; the sequence call: H2 %s, PostgreSQL %s; H2 = PostgreSQL" % (
        N, f(h[("off", "ident")]), f(h[("off", "seq")]), h[("off", "seq")][6], f(h[("off", "cust")]), B, f(h[("on", "ident")]), f(h[("on", "cust")]), f(h[("on", "seq")]), h[("on", "seq")][6],
        h[("on", "seq")][1], h[("on", "seq")][0], N, B, math.ceil(N / B), f(h["saveAll"]), first.group(1), N, N // B, h["seqtext"][0], p["seqtext"][0]))

elif mode == "order":
    per = bydb([info(b) for b in jvms(read(files[0]))])
    need(sorted(per) == ["H2", "PostgreSQL"] and all(len(v) == 2 for v in per.values()), "two JVMs per database: without order_inserts, then with it")
    res = {}
    for db, (d0, d1) in per.items():
        N = d0["N"]; B = int(d0["keys"]["hibernate.jdbc.batch_size"])
        need(d0["keys"].get("hibernate.order_inserts") == "null" and d1["keys"].get("hibernate.order_inserts") == "true", "%s: order_inserts null, then true (read off)" % db)
        out = []
        for d, on in ((d0, False), (d1, True)):
            s = step(d, "customers, each persisted with one pause"); a, b, c = three(s, ""); ab, eb, eu = s["c"][3:]; calls = seqcalls(s)
            need(rows(s, r"w_customer (\d+) · w_pause (\d+)$") == [N, N], "%s: rows read back N customers, N pauses" % db)
            need(ab == 2 * N and b == calls + 2 * N, "%s: addBatch 2N = %d; the SQL log = the calls + 2N" % (db, ab))
            if not on: need(a == c == calls + 2 * N and eb == 2 * N, "%s without order_inserts: statements %d = calls + 2N, executeBatch %d = 2N - a batch per insert" % (db, a, eb))
            else: need(a == c == calls + 2 and eb == 2 * math.ceil(N / B), "%s with order_inserts: statements %d = calls + 2, executeBatch %d = 2 x ceil(N / %d)" % (db, a, eb, B))
            out.append((a, b, c, ab, eb, eu, calls))
        res[db] = (N, B, out)
    need(res["H2"] == res["PostgreSQL"], "H2 = PostgreSQL for every count")
    N, B, (o0, o1) = res["H2"]
    VALS.append("%d customers each with one pause, batch %d: without order_inserts statements %d, addBatch %d, executeBatch %d (a batch per insert); with hibernate.order_inserts=true statements %d, addBatch %d, executeBatch %d; H2 = PostgreSQL" % (N, B, o0[0], o0[3], o0[4], o1[0], o1[3], o1[4]))

elif mode == "updates":
    t = read(files[0])
    per = bydb([info(b) for b in jvms(t)])
    need(sorted(per) == ["H2", "PostgreSQL"] and all(len(v) == 3 for v in per.values()), "three JVMs per database: the key, no key, the key + batch_versioned_data=false")
    res = {}
    for db, (k5, k0, kn) in per.items():
        need(k5["keys"]["hibernate.jdbc.batch_size"] == "50" and k0["keys"]["hibernate.jdbc.batch_size"] == "null" and kn["keys"]["hibernate.jdbc.batch_versioned_data"] == "false" and kn["keys"]["hibernate.jdbc.batch_size"] == "50",
             "%s: the keys read off: 50 · null · 50 with batch_versioned_data=false" % db)
        B = 50; out = []
        for d in (k5, k0, kn):
            gen = [l for l in d["lines"] if "PROBE generated by plain JDBC" in l]
            m = re.search(r"(\d+) customers · customer rows read back (\d+) · at version 0: (\d+)$", gen[0]) if gen else None
            need(m is not None and int(m.group(2)) == int(m.group(3)) == int(m.group(1)) + 4, "%s: N generated beside the four seeded, all at version 0" % db)
            M = int(m.group(2))
            s = step(d, "edit every CustomerEntity"); a, b, c = three(s, ""); ab, eb, eu = s["c"][3:]
            e, v1, v0 = rows(s, r"entities edited (\d+) · rows at version 1, read back: (\d+) · at version 0: (\d+)$")
            need(e == v1 == M and v0 == 0, "%s: %d entities edited, %d rows at version 1 (second connection)" % (db, e, v1))
            up = [x for n, x in s["texts"] if x.startswith("update customer")]
            need(len(up) == 1 and up[0].endswith(" where id=? and version=?") and b == M + 1, "%s: one UPDATE text, sent M times, ending where id=? and version=?" % db)
            out.append((M, a, b, c, ab, eb, eu, up[0]))
        (M, a, b, c, ab, eb, eu, ut), z, n = out
        need(a == c == 2 and ab == M and eb == math.ceil(M / B) and eu == 0, "%s with the key: statements 2 (the SELECT + one prepared UPDATE), addBatch M, executeBatch ceil(%d / %d) = %d" % (db, M, B, eb))
        need(z[1] == z[3] == M + 1 and z[4] == 0 and z[5] == 0 and z[6] == M, "%s no key: statements M + 1 = %d, executeUpdate M" % (db, z[1]))
        need(n[1:7] == out[0][1:7], "%s: batch_versioned_data=false changes nothing - the same counts as the key alone" % db)
        res[db] = out
    need(res["H2"] == res["PostgreSQL"], "H2 = PostgreSQL for every count and the UPDATE's text")
    g = {}
    for m in re.finditer(r"^\$ K=(\S+); grep -a -r -l -F \"\$K\" \.harness/hibernate-core\n  files holding it: (\d+)\n((?:  \S+\n)*)", t, re.M):
        g[m.group(1)] = (int(m.group(2)), [x.strip() for x in m.group(3).splitlines()])
    need(set(g) == {"batch_versioned_data", "hibernate.jdbc.batch_size", "hibernate.order_inserts", "hibernate.order_updates"}, "the four grep -a lines")
    need(g["batch_versioned_data"][0] == 0, "S5.10: 0 files of hibernate-core-7.4.13.Final.jar hold batch_versioned_data")
    for k in ("hibernate.jdbc.batch_size", "hibernate.order_inserts", "hibernate.order_updates"):
        need(g[k][0] == len(g[k][1]) > 0 and "org/hibernate/cfg/BatchSettings.class" in g[k][1], "%s: %d files, BatchSettings among them" % (k, g[k][0]))
    nf = re.search(r"^  files unpacked: (\d+)$", t, re.M)
    (M, a, b, c, ab, eb, eu, ut), z, n = res["H2"]
    VALS.append("%d CustomerEntity rows edited in one transaction: hibernate.jdbc.batch_size=50 statements %d, addBatch %d, executeBatch %d (derived ceil(%d / 50) = %d), %d rows at version 1; no key statements %d, executeUpdate %d; batch_versioned_data=false the same %d; the UPDATE: %s; grep -a over hibernate-core-7.4.13.Final.jar (%s files): batch_versioned_data 0 files, hibernate.jdbc.batch_size %d, hibernate.order_inserts %d, hibernate.order_updates %d (BatchSettings among them); H2 = PostgreSQL" % (
        M, a, ab, eb, M, math.ceil(M / 50), M, z[1], z[6], n[5], ut, nf.group(1) if nf else "-", g["hibernate.jdbc.batch_size"][0], g["hibernate.order_inserts"][0], g["hibernate.order_updates"][0]))

elif mode == "chunk":
    (d,) = [info(b) for b in jvms(read(files[0]))]
    N = d["N"]; B = int(d["keys"]["hibernate.jdbc.batch_size"])
    s1 = step(d, "no clear"); s2 = step(d, "flush() + clear() every 50")
    m1 = re.search(r"getEntityCount\(\)\): (\d+) · rows read back: x_seq (\d+)$", s1["result"])
    m2 = re.search(r"\(getEntityCount\(\) after each persist\) (\d+) · at the end (\d+) · rows read back: x_seq (\d+)$", s2["result"])
    need(m1 and int(m1.group(1)) == N == int(m1.group(2)), "no clear: getEntityCount() before the commit = N = rows")
    need(s1["c"][3] == N and s1["c"][4] == N // B and s1["c"][0] == s1["c"][2] == seqcalls(s1) + 1, "no clear: addBatch N, executeBatch N / %d = %d, statements = calls + 1 = %d" % (B, s1["c"][4], s1["c"][0]))
    need(m2 and int(m2.group(1)) == B and int(m2.group(2)) == 0 and int(m2.group(3)) == 2 * N, "flush() + clear() every 50: the largest %s = the batch size, %s at the end, rows +N" % (m2.group(1) if m2 else "-", m2.group(2) if m2 else "-"))
    need(s2["c"][3] == N and s2["c"][4] == s1["c"][4], "flush() + clear(): the same executeBatch %d" % s2["c"][4])
    need(s2["c"][0] == s2["c"][2] == seqcalls(s2) + N // 50, "flush() + clear(): statements %d = the calls %d + one prepared INSERT per flush (N / 50 = %d)" % (s2["c"][0], seqcalls(s2), N // 50))
    VALS.append("%d persists in one transaction, batch %d: getEntityCount() %s before the commit, executeBatch %d, statements %d; flush() + clear() every 50: the largest %s, %s at the end, executeBatch %d, statements %d (each flush prepares its INSERT again); derived %d / 50 = %d" % (
        N, B, m1.group(1), s1["c"][4], s1["c"][0], m2.group(1), m2.group(2), s2["c"][4], s2["c"][0], N, N // 50))

elif mode == "flush":
    t = read(files[0])
    bl = jvms(t)
    need(len(bl) == 2, "two JVMs: H2, PostgreSQL")
    res = []
    for b in bl:
        d = info(b)
        call = [l for l in b if "PROBE call order:" in l]
        dur = [l for l in b if "PROBE SQL sent while the five calls ran, in order: " in l]
        at = [l for l in b if "PROBE SQL sent at the commit (the flush), in the order sent: " in l]
        need(len(call) == len(dur) == len(at) == 1, "%s: the call order, the SQL during the calls and at the commit printed" % d["db"])
        during = dur[0].split("in order: ", 1)[1].split(" ; ")
        need(all(SEQ.match(x) for x in during), "%s: the only SQL during the calls is the sequence call: %s" % (d["db"], during))
        sql = [re.sub(r"^\d+ ", "", x) for x in at[0].split("in the order sent: ", 1)[1].split(" ; ")]
        kinds = [x.split()[0] + " " + (x.split()[2] if x.startswith(("insert", "delete")) else x.split()[1]) for x in sql]
        rank = {"insert": 0, "update": 1, "delete": 2}
        need([rank[k.split()[0]] for k in kinds] == sorted(rank[k.split()[0]] for k in kinds), "%s: at the commit inserts, then updates, then deletes: %s" % (d["db"], " · ".join(kinds)))
        co = call[0].split("call order: ", 1)[1]
        need(co.startswith("1 remove") and [w.split()[1] for w in co.split(" · ")] != [{"insert": "persist", "update": "edit", "delete": "remove"}[k.split()[0]] for k in kinds], "%s: the call order (%s) is not the SQL order" % (d["db"], co))
        i1 = next(i for i, l in enumerate(b) if "Initiating transaction commit" in l)
        i2 = next(i for i, l in enumerate(b) if " org.hibernate.SQL : " + sql[0] in l and i > i1)
        need(i1 < i2, "%s: the logger shows the flush's SQL after 'Initiating transaction commit'" % d["db"])
        res.append((d["db"].split()[0], co, during, kinds, sql, d["steps"][0].get("result")))
    need(res[0][1] == res[1][1] and res[0][3] == res[1][3] and res[0][4] == res[1][4] and res[0][5] == res[1][5], "H2 = PostgreSQL: the call order, the flush's SQL and the rows")
    VALS.append("called %s -> flushed at the commit, in the order sent: %s (the SQL: %s); during the calls only the sequence call - H2 %s, PostgreSQL %s; %s" % (
        res[0][1], " · ".join(res[0][3]), " ; ".join(res[0][4]), " ; ".join(res[0][2]), " ; ".join(res[1][2]), res[0][5]))

elif mode in ("time", "table"):
    def table(rows, T, what):
        db = {}
        for r in rows:
            db.setdefault(r[0], []).append(r)
        need(sorted(db) == ["H2", "PostgreSQL"], "%s: rows for H2 and PostgreSQL" % what)
        for k, v in db.items():
            need(len(v) >= 10, "%s: %d JVMs on %s - at least ten per database (R.236)" % (what, len(v), k))
        pgs = [r[1] for r in db["PostgreSQL"]]
        bad = [x for x in pgs if not x >= T]
        need(not bad, "%s: every PostgreSQL SEQUENCE ratio >= T = %g (below it: %s)" % (what, T, bad))
        lo = min(pgs)
        print("  %s: JVMs per database H2 %d · PostgreSQL %d; PostgreSQL SEQUENCE ratio %.2f-%.2f, T = %g, the margin (the smallest - T) %.2f; H2 SEQUENCE %.2f-%.2f (numbers on the chip, no threshold); IDENTITY H2 %.2f-%.2f · PostgreSQL %.2f-%.2f (the control)" % (
            what, len(db["H2"]), len(db["PostgreSQL"]), lo, max(pgs), T, lo - T, min(r[1] for r in db["H2"]), max(r[1] for r in db["H2"]),
            min(r[2] for r in db["H2"]), max(r[2] for r in db["H2"]), min(r[2] for r in db["PostgreSQL"]), max(r[2] for r in db["PostgreSQL"])))
        return db, lo

    if mode == "table":
        T = float(files[1])
        rows = []
        for l in read(files[0]).splitlines():
            m = re.match(r"^\| (H2|PostgreSQL) \| (\d) \| (\d+) \| (\d+\.\d\d) \| (\d+\.\d\d) \|", l)
            if m: rows.append((m.group(1), float(m.group(4)), float(m.group(5))))
        db, lo = table(rows, T, "the table")
        mg = re.search(r"^margin: the smallest PostgreSQL SEQUENCE ratio (\d+\.\d\d) - T (\d+) = (\d+\.\d\d)$", read(files[0]), re.M)
        need(mg is not None and float(mg.group(1)) == lo and float(mg.group(2)) == T and abs(float(mg.group(3)) - (lo - T)) < 0.005, "the table's margin line = the smallest PostgreSQL ratio - T")
    else:
        t = read(files[0]); T = float(files[2]); TJ = int(files[3])
        bl = jvms(t)
        need(len(bl) == 2 * TJ, "%d JVMs in the capture run: %d per database" % (len(bl), TJ))
        dbs = []
        for b in bl:
            d = info(b)
            dbs.append(d["db"].split()[0])
            des = [l for l in b if l.startswith("  PROBE design: ")]
            m = re.match(r"  PROBE design: N (\d+) persists per run in one transaction · W (\d+) warm-up rounds · R (\d+) timed rounds", des[0]) if des else None
            need(m is not None, "%s: the design line" % d["db"])
            N, W, R = (int(x) for x in m.groups())
            base = ["SEQUENCE batch 1", "SEQUENCE batch 50", "IDENTITY batch 1", "IDENTITY batch 50"]
            ords = [re.match(r"  PROBE round (\d+) \((warm-up|timed)\) order: (.*)$", l) for l in b if l.startswith("  PROBE round ")]
            need(len(ords) == W + R and all(o and int(o.group(1)) == i and o.group(2) == ("warm-up" if i < W else "timed") for i, o in enumerate(ords)), "%s: %d rounds printed, W warm-up then R timed" % (d["db"], W + R))
            alt = all(o.group(3).split(", ") == (base if i % 2 == 0 else base[::-1]) for i, o in enumerate(ords))
            need(alt, "%s: R.300 - even rounds %s, odd rounds reversed (within each id strategy batch 1 first, then batch 50 first)" % (d["db"], ", ".join(base)))
            need(any(l == "  PROBE every run's rows read back (count, distinct names, first, last) = N, N, R<round>-0000, R<round>-%04d: %d runs" % (N - 1, 4 * (W + R)) for l in b), "%s: every run's rows read back, %d runs" % (d["db"], 4 * (W + R)))
            for c, want in zip(base, [0, N // 50, 0, 0]):
                need(("  PROBE executeBatch per run (the counting proxy), every round: %s [%d]" % (c, want)) in b, "%s: executeBatch per run %s = %d in every round" % (d["db"], c, want))
            need(sum(1 for l in b if re.match(r"  PROBE timed .* \(ms\): \[<masked>\]$", l)) == 4 and "  PROBE median (ms): SEQUENCE batch 1 <ms> · SEQUENCE batch 50 <ms> · IDENTITY batch 1 <ms> · IDENTITY batch 50 <ms>" in b
                 and "  PROBE ratio SEQUENCE batch 1 / batch 50: <ratio> · ratio IDENTITY batch 1 / batch 50: <ratio>" in b, "%s: the timed values, the medians and the ratios printed and masked" % d["db"])
            if d["db"].startswith("PostgreSQL"):
                need(any(re.match(r"  exit 0 · on PostgreSQL, JVM \d+: SEQUENCE ratio >= %d: true$" % T, l) for l in b), "PostgreSQL: the threshold line, ratio >= %d: true" % T)
            else:
                need(any(re.match(r"  exit 0 · on H2, JVM \d+: its ratios go to the table as numbers - no threshold on H2 \(S5\.9\)$", l) for l in b), "H2: no threshold, its ratios to the table")
        need(dbs == ["H2", "PostgreSQL"] * TJ, "H2 and PostgreSQL in turn, JVM by JVM")
        rows = []
        md = ["| database | capture run | JVM | SEQUENCE batch 1 / 50 | IDENTITY batch 1 / 50 | medians (ms): SEQUENCE 1 · 50 · IDENTITY 1 · 50 |", "|---|---|---|---|---|---|"]
        for l in read(files[1]).splitlines():
            m = re.match(r"^(H2|PostgreSQL) · capture run (\d) · JVM (\d+) · ratio SEQUENCE batch 1 / batch 50: (\d+\.\d\d) · ratio IDENTITY batch 1 / batch 50: (\d+\.\d\d) · median \(ms\): SEQUENCE batch 1 ([\d.]+) · SEQUENCE batch 50 ([\d.]+) · IDENTITY batch 1 ([\d.]+) · IDENTITY batch 50 ([\d.]+)$", l)
            if m:
                rows.append((m.group(1), float(m.group(4)), float(m.group(5))))
                md.append("| %s | %s | %s | %s | %s | %s · %s · %s · %s |" % m.groups())
        db, lo = table(rows, T, "this run's table (.r-time.table)")
        md.append("")
        md.append("margin: the smallest PostgreSQL SEQUENCE ratio %.2f - T %d = %.2f" % (lo, T, lo - T))
        for l in read(files[1]).splitlines():
            if l.startswith("capture run "): md.append("load average, " + l)
        open(files[1] + ".md", "w", encoding="utf-8").write("\n".join(md) + "\n")
        VALS.append("the fixed design: N %d persists per run in one transaction, W %d warm-up rounds, R %d timed, four runs per round (SEQUENCE batch 1 / 50, IDENTITY batch 1 / 50), the order reversed every other round; %d JVMs per database per capture run, %d per database in the three runs; executeBatch per run SEQUENCE batch 50: %d, the other three 0; on PostgreSQL SEQUENCE ratio >= %d: true in every JVM, on this Mac; H2's ratios numbers on the chip, no threshold" % (
            N, W, R, TJ, 3 * TJ, N // 50, T))

elif mode == "anchor":
    t = read(files[0]); bt = read(files[1]); s466 = files[2]
    for f in ("CustomerEntity.java", "PauseEntity.java", "Database.java"):
        need(("  edited tiffinbox-core/src/main/java/com/tiffinbox/" + f) in t, "the derive edited %s" % f)
    need("  edited tiffinbox-web/src/main/resources/application.yaml" in t, "the derive edited application.yaml")
    m = re.search(r"Surefire's summary lines, summed: tests (\d+) · failures (\d+) · errors (\d+) · skipped (\d+) · BUILD SUCCESS", t)
    need(m is not None and int(m.group(1)) > 0 and m.group(2) == m.group(3) == m.group(4) == "0", "the copy's tests pass (a guard, R.190): %s" % (m.group(1) if m else "-"))
    tests = m.group(1)
    m = re.search(r"^  its md5: ([0-9a-f]{32}) · the anchor's \(xcheck\.sql\): ([0-9a-f]{32}) ", t, re.M)
    need(m is not None and m.group(1) != m.group(2), "the copy's DDL md5 differs from the anchor's")
    dmd5, xmd5 = m.group(1), m.group(2)
    dl = re.findall(r"^    ([<>] .*)$", t, re.M)
    nd = re.search(r"^  lines that differ: (\d+)$", t, re.M)
    need(nd is not None and int(nd.group(1)) == len(dl) > 0, "the DDL's lines that differ: %d, each shown" % len(dl))
    imps = re.findall(r"^  -> (\d+) (\{.*\})$\n^  between its markers: org\.hibernate\.SQL lines (\d+) \(of them select nextval / next value: (\d+)\) · 'Adding to JDBC batch' (\d+) \(at \(1 / 50\): (\d+)\) · 'Executing JDBC batch' (\d+) · 'Creating new transaction with name \[com\.tiffinbox\.CustomerRepository\.add\]' (\d+) · WARN lines (\d+) · ERROR lines (\d+)$", t, re.M)
    gen = re.findall(r"^  the generated file: \.harness/import\.csv - a header and (\d+) lines", t, re.M)
    need(len(imps) == 2 and len(gen) == 2 and gen[0] == gen[1], "two imports (the copy, the anchor with the key), the same generated file")
    n = int(gen[0])
    (c, cb, sq, ss, ad, a1, ex, tx, w, e), (c2, cb2, sq2, ss2, ad2, a12, ex2, tx2, w2, e2) = imps
    need(c == c2 == "200" and ('"added":%d,"refused":{}' % n) in cb and ('"added":%d,"refused":{}' % n) in cb2, "both imports: 200, added = the file's lines (%d), refused none" % n)
    need(int(ad) == int(a1) == int(tx) == n and int(sq) == n + int(ss) and int(ss) > 0 and w == e == "0", "the copy: 'Adding to JDBC batch (1 / 50)' %s = transactions %s = added %d - a batch of one per row; SQL lines %s = added + %s sequence call(s)" % (a1, tx, n, sq, ss))
    need(int(ad2) == 0 and int(ex2) == 0 and int(tx2) == n and int(sq2) == n and int(ss2) == 0 and w2 == e2 == "0", "the anchor with batch_size=50: 'Adding to JDBC batch' 0, 'Executing JDBC batch' 0, transactions %s, SQL lines %s - identity columns, no batch" % (tx2, sq2))
    fa = re.search(r"^  its first 'Adding to JDBC batch' line \(the message\): (.*)$", t, re.M).group(1)
    need(fa == "Adding to JDBC batch (1 / 50) - [com.tiffinbox.CustomerEntity#INSERT]", "the copy's batch line: %s" % fa)
    ids = re.search(r"^\$ Q=\"select id, name from customer order by id\"; .*\n((?:  .*\n)+?)  \(\d+ row\(s\)\)$", t, re.M)
    need(ids is not None, "the second connection's customers")
    rl = [l.split("|") for l in ids.group(1).splitlines()[1:]]
    seed = [(int(a.strip()), b.strip()) for a, b in rl[:4]]
    inc = re.search(r"CREATE SEQUENCE customer_seq START WITH 1 INCREMENT BY (\d+)", t)
    need(inc is not None and len(rl) == 4 + n and [i for i, _ in seed] == [1 + k * int(inc.group(1)) for k in range(4)], "the seed's ids step by the sequence's INCREMENT BY %s: %s" % (inc.group(1) if inc else "-", [i for i, _ in seed]))
    sv = re.search(r"^  exit (\d+) · the seven responses: (\d+) lines · md5 ([0-9a-f]{32})$", t, re.M)
    need(sv is not None and sv.group(1) == "0" and sv.group(2) == "7" and sv.group(3) == s466, "the seven on the copy: %s = the anchor's, unchanged (no route's JSON carries an id)" % (sv.group(3) if sv else "-"))
    bc = re.search(r"the anchor's com\.tiffinbox\.CustomerEntity \(IDENTITY\)\n.*\n  PROBE counts: statements: .* \| batching: JDBC proxy addBatch (\d+) · executeBatch (\d+)", bt)
    need(bc is not None and bc.group(2) == "0", "the batch capture's first half of the failure receipt: CustomerEntity executeBatch 0")
    VALS.append("the labelled copy (CustomerEntity and PauseEntity on SEQUENCE, allocationSize 50; Database's sequences; the three keys): its tests %s pass (a guard); its DDL %s (the anchor's %s), %d lines differ; the import of %d: added %d, 'Adding to JDBC batch (1 / 50)' %s, %s transactions (CustomerRepository.add), %s SQL lines (%s sequence call); the seed's ids %s; the seven %s; the anchor with hibernate.jdbc.batch_size=50: 'Adding to JDBC batch' 0, %s transactions, %s SQL lines" % (
        tests, dmd5, xmd5, len(dl), n, n, a1, tx, sq, ss, "/".join(str(i) for i, _ in seed), sv.group(3), tx2, sq2))
else:
    need(False, "no such mode: " + mode)
print("VALUES " + " ; ".join(VALS))
