"""Unit 37's checks (python3 -I -B harness/chk37.py MODE ...). Each capture's mode reads its capture (.r-NAME.out) and asserts every
number and string the video may say against another witness of the same run - the tables read by a second connection (psql in the
container, H2's Shell over TCP) beside Liquibase's and Flyway's own lines, the changelog files themselves, the trap's log - never
against a typed figure; it prints "ok ..." lines and one "VALUES ..." line, and exits 1 on the first failed assertion. Every JVM's
block is checked for its version lines (R.329: Liquibase 5.0.4 in every JVM that loads Liquibase, Flyway 12.4.0 where Flyway's jars
are on the class path; Hibernate, Spring Data JPA, Framework and Boot in all; HHH000001 where Hibernate starts) and its trap count
(R.317: 0, but the one labelled default run). A rollback's witness is databasechangelog's count and the rows (R.328), never "done".
"table" builds the README's comparison table from the compare capture's cell lines (R.261); "wib" gives an exercise file's "What it
prints" block as the bash run printed it."""
import os, re, sys

MODE = sys.argv[1]
DEFAULT_RUN = "u37adef"


def ok(cond, what):
    if not cond:
        print("FAIL " + what); sys.exit(1)
    print("ok    " + what)


def lines(p):
    return open(p, encoding="utf-8").read().splitlines()


VERS = ["PROBE version: Hibernate 7.4.13.Final", "PROBE version: Spring Data JPA 4.1.2", "PROBE version: Spring Framework 7.0.10",
        "PROBE version: Spring Boot 4.1.2", "PROBE version: Flyway 12.4.0"]
HHH = "INFO [main] org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final"
LQV = "PROBE version: Liquibase 5.0.4"
END = re.compile(r"^  exit (\d+) · WARN lines: (\d+) · the trap's request lines during this JVM: (\d+)$")


def jvms(L):
    """label -> dict(cmd, view, exit, warn, trap, after) - the JVM's view lines, then the lines after it up to the next JVM or heading"""
    out = {}
    idx = [i for i, l in enumerate(L) if l.startswith("  JVM ")]
    for k, a in enumerate(idx):
        lab = L[a][6:]
        ok(lab not in out, "%s: one JVM of that label" % lab)
        nxt = idx[k + 1] if k + 1 < len(idx) else len(L)
        ends = [j for j in range(a, nxt) if END.match(L[j])]
        ok(len(ends) == 1 and L[a + 1].startswith("$ CPC="), "%s: its command line and one closing count line" % lab)
        e = ends[0]
        m = END.match(L[e])
        out[lab] = {"cmd": L[a + 1], "view": [x[4:] for x in L[a + 2:e]], "exit": int(m.group(1)), "warn": int(m.group(2)),
                    "trap": int(m.group(3)), "after": L[e + 1:nxt]}
    return out


def common(J):
    for lab, j in J.items():
        v = j["view"]
        for x in VERS: ok(x in v, "%s: %s (R.329)" % (lab, x))
        lq = ":../lq/*" in j["cmd"]
        ok((LQV in v) == lq, "%s: Liquibase's version line 5.0.4 %s - its class path %s the harness's Liquibase jars (R.329)" % (lab, "printed" if lq else "absent", "holds" if lq else "holds no"))
        if lq: ok("--spring.liquibase.analytics-enabled=false" in j["cmd"] or "-Dliquibase.analytics.enabled=false" in j["cmd"] or lab == DEFAULT_RUN,
                  "%s: a Liquibase JVM with its analytics key (R.317)" % lab)
        if "MC=probe.l.LMain" in j["cmd"] and "PROBE ready: yes" in v:
            ok(HHH in v, "%s: HHH000001 7.4.13.Final (a start that went on; a killed or refused start stops before Hibernate, its version line above)" % lab)
        want = 1 if lab == DEFAULT_RUN else 0
        ok(j["trap"] == want, "%s: the trap's request lines %d = %d (R.317)" % (lab, j["trap"], want))


def summary(v):
    s = {}
    for k in ("Run", "Previously run", "Total change sets"):
        m = [x for x in v if re.match(r"^INFO \[main\] liquibase\.util : %s: \d+$" % k, x)]
        s[k] = int(m[0].rsplit(" ", 1)[1]) if len(m) == 1 else None
    r = [x for x in v if "Update has been successful. Rows affected: " in x]
    s["rows"] = int(r[0].rsplit(" ", 1)[1]) if len(r) == 1 else None
    return s


def psql(after, q):
    """the output lines of the psql query whose command line contains q (the first one after a JVM)"""
    for i, l in enumerate(after):
        if l.startswith("  $ DB=") and q in l:
            o = []
            for x in after[i + 1:]:
                if not x.startswith("    "): break
                o.append(x[4:])
            return o
    return None


def psql_after(L, lab, q):
    """the first psql read containing q after the JVM labelled lab - whatever runs between them"""
    a = L.index("  JVM " + lab)
    for i in range(a, len(L)):
        if L[i].startswith("  $ DB=") and q in L[i]:
            o = []
            for x in L[i + 1:]:
                if not x.startswith("    "): break
                o.append(x[4:])
            return o
    return None


def ready(j, yes):
    v = j["view"]
    ok(("PROBE ready: yes" in v) == yes and ("PROBE ready: no" in v) != yes and j["exit"] == (0 if yes else 1),
       "ready: %s beside exit %d" % ("yes" if yes else "no", j["exit"]))


def inserts(p):
    t = open(p, encoding="utf-8").read()
    return len(re.findall(r"^INSERT INTO customer ", t, re.M)), len(re.findall(r"^INSERT INTO pause ", t, re.M))


HQ = "Q=\"select id, author, filename, orderexecuted"
LK = "Q=\"select id, locked, lockgranted"
RW = "Q=\"select 'customers ' ||"

if MODE == "formats":
    L = lines(sys.argv[2]); CL = sys.argv[3]; J = jvms(L); common(J)
    wc = {f: len(open(os.path.join(CL, "changelog." + f), encoding="utf-8").read().splitlines()) for f in ("sql", "yaml", "xml")}
    fl = [l for l in L if l.startswith("  the files (wc -l): ")]
    ok(len(fl) == 1, "the files line")
    for f, n in wc.items(): ok(("changelog.%s %d" % (f, n)) in fl[0], "changelog.%s: %d lines printed = the file's own count" % (f, n))
    fw = re.search(r"V1__customer_and_pause\.sql (\d+) · V2__seed\.sql (\d+) · total (\d+)", fl[0])
    ok(fw and int(fw.group(1)) + int(fw.group(2)) == int(fw.group(3)), "Flyway's two files: %s + %s = %s" % fw.groups())
    nc, np = inserts(os.path.join(CL, "changelog.sql"))
    sums = {}
    for f in ("sql", "yaml", "xml"):
        lab = "u37f" + f; j = J[lab]; v = j["view"]; s = summary(v)
        ready(j, True)
        ok("PROBE emf hibernate.hbm2ddl.auto = validate" in v, "%s: validate, off the EntityManagerFactory" % lab)
        ok(s["Run"] == 2 and s["Previously run"] == 0 and s["Total change sets"] == 2, "%s: Run: %s · Previously run: %s · Total change sets: %s" % (lab, s["Run"], s["Previously run"], s["Total change sets"]))
        ok(j["warn"] == 0, "%s: 0 WARN lines" % lab)
        r = psql(j["after"], RW); ok(r == ["customers %d · pauses %d" % (nc, np)], "%s: psql %s = the changelog's INSERTs (%d customers, %d pauses)" % (lab, r, nc, np))
        ok(s["rows"] == nc + np, "%s: Rows affected: %s = the rows psql reads (%d + %d)" % (lab, s["rows"], nc, np))
        h = psql(j["after"], HQ)
        ok(len(h) == s["Run"] and [x.split("|")[0] for x in h] == ["1", "2"] and all(x.split("|")[2] == "db/changelog/changelog." + f for x in h),
           "%s: databasechangelog %d rows = Run, ids 1-2, filename db/changelog/changelog.%s (the class path's name, R.328)" % (lab, len(h), f))
        sums[f] = [x.split("|")[5] for x in h]
        ok(psql(j["after"], LK) == ["1|f|f|"], "%s: databasechangeloglock 1 row, locked=f" % lab)
        t = psql(j["after"], "from pg_tables"); ok(t == ["customer, databasechangelog, databasechangeloglock, pause"], "%s: the tables %s" % (lab, t))
        c = psql(j["after"], "from information_schema.columns"); ok(c and c[1] == "databasechangeloglock: id, locked, lockgranted, lockedby", "%s: the lock table's columns" % lab)
    side = [l for l in L if re.match(r"^  (sql|yaml|xml): 9:", l)]
    ok(side == ["  %s: %s" % (f, " ".join(sums[f])) for f in ("sql", "yaml", "xml")], "the checksums side by side = the md5sum column")
    same = sums["yaml"] == sums["xml"]; diff = sums["sql"] != sums["yaml"]
    ok(same and diff, "checksums: YAML = XML, SQL differs (read, not assumed)")
    print("VALUES the changelog's lines SQL %d · YAML %d · XML %d (Flyway's V1 + V2: %s + %s = %s) · each format: Run: 2 · Previously run: 0 · Total change sets: 2 · Rows affected: %d · customers %d · pauses %d · databasechangelog 2 rows · databasechangeloglock 1 row unlocked · validate passes · 0 WARN · checksums YAML = XML, SQL its own"
          % (wc["sql"], wc["yaml"], wc["xml"], fw.group(1), fw.group(2), fw.group(3), nc + np, nc, np))

elif MODE == "analytics":
    L = lines(sys.argv[2]); J = jvms(L); common(J)
    ok(any('"name": "spring.liquibase.analytics-enabled"' in l for l in L), "the key's name read off spring-boot-liquibase's metadata")
    d = J["u37adef"]; ok("--spring.liquibase.analytics-enabled" not in d["cmd"] and "liquibase.analytics" not in d["cmd"], "the default run carries NO analytics setting")
    tl = [l for l in d["after"] if l.startswith("    <time> ")]
    ok(tl == ["    <time> CONNECT config.liquibase.com:443 HTTP/1.1"] and d["trap"] == 1, "the default run: the trap's log holds 1 line, CONNECT config.liquibase.com:443 (the filed step, R.303)")
    ready(d, True); ok(summary(d["view"])["Run"] == 2, "the default run still migrates: Run: 2")
    k = J["u37akey"]; ok("--spring.liquibase.analytics-enabled=false" in k["cmd"] and k["trap"] == 0, "the key: 0 trap lines")
    f = J["u37afly"]; ok(":../lq/*" not in f["cmd"] and f["trap"] == 0 and any("Successfully applied 2 migrations" in x for x in f["view"]), "the Flyway JVM (no Liquibase jar): 0 trap lines, Flyway applied 2")
    for lab in ("u37adef", "u37akey", "u37afly"): ok(psql(J[lab]["after"], RW) == ["customers 4 · pauses 2"], "%s: customers 4 · pauses 2" % lab)
    side = [l for l in L if l.startswith("the three, side by side")]
    ok(side == ["the three, side by side - the trap's request lines: default %d · the key %d · Flyway %d" % (d["trap"], k["trap"], f["trap"])], "the three side by side = the per-JVM counts")
    print("VALUES the trap's request lines: no key 1 (CONNECT config.liquibase.com:443, answered 403, nothing forwarded; the migration still ran, Run: 2) · spring.liquibase.analytics-enabled=false 0 · Flyway 0")

elif MODE == "lock":
    L = lines(sys.argv[2]); J = jvms(L); common(J)
    for p in ("u37lock", "u37lockp"):
        b = J[p + "k"]
        ok(b["exit"] == 137 and "PROBE closed, exit 0" not in b["view"], "%sk: B killed by the receipt, exit 137" % p)
        ok("INFO [main] liquibase.ui : Running Changeset: db/changelog/changelog.sql::3::tiffinbox" in b["view"] and not any("::3::tiffinbox ran successfully" in x for x in b["view"]), "%sk: killed while changeset 3 ran" % p)
        lk = psql_after(L, p + "k", LK); ok(lk == ["1|t|t|<host> (<ip>)"], "%sk: the second connection after the kill: %s - locked=t, granted, lockedby masked (the B check)" % (p, lk))
        h = psql(b["after"], HQ); ok([x.split("|")[0] for x in h] == ["1", "2"], "%sk: databasechangelog rows 1-2, no row for 3" % p)
        ok(psql(b["after"], "backend(s) running pg_sleep") == ["1 backend(s) running pg_sleep"] and psql(b["after"], "terminated") == ["1 terminated"], "%sk: the sleeping backend found and terminated (1)" % p)
        bl = [i for i, l in enumerate(b["after"]) if l.startswith("  $ DB=") and "backend(s) running pg_sleep" in l]
        ok(len(bl) == 2 and b["after"][bl[1] + 1] == "    0 backend(s) running pg_sleep", "%sk: 0 sleeping backends before the next step" % p)
    r = J["u37lockr"]; ready(r, False)
    ok("-Dliquibase.changelogLockWaitTimeInMinutes=0" in r["cmd"], "the refused start: the wait set to 0 by its system property")
    ok("PROBE cause: liquibase.exception.LockException: Could not acquire change log lock. Currently locked by <host> (<ip>) since <time>" in r["view"], "the refused start: LockException, Could not acquire change log lock (R.303)")
    ok(psql(r["after"], LK) == ["1|t|t|<host> (<ip>)"], "after the refused start: still locked=t")
    for a, n in (("u37locka", "u37lockb"), ("u37lockpa", "u37lockpb")):
        x = J[a]; v = x["view"]
        ok("PROBE locks listed: 1" in v and "PROBE forceReleaseLocks(): done" in v and x["exit"] == 0, "%s: listLocks() 1, forceReleaseLocks() done" % a)
        ok(v.index("PROBE locks listed: 1") < v.index("PROBE forceReleaseLocks(): done"), "%s: listed before the release" % a)
        ok(psql(x["after"], LK) == ["1|f|f|"], "%s: the second connection: locked=f" % a)
        y = J[n]; s = summary(y["view"]); ready(y, True)
        ok(s["Run"] == 1 and s["Previously run"] == 2 and s["Total change sets"] == 3, "%s: Run: %s · Previously run: %s · Total change sets: %s" % (n, s["Run"], s["Previously run"], s["Total change sets"]))
        h = psql(y["after"], HQ); ok([q.split("|")[0] for q in h] == ["1", "2", "3"] and psql(y["after"], LK) == ["1|f|f|"], "%s: 3 rows, unlocked" % n)
    w = [l for l in J["u37locka"]["view"] if l.startswith("PROBE lock wait: ")]
    m = re.match(r"^PROBE lock wait: key (liquibase\.changelogLockWaitTimeInMinutes) · default (\d+) · this JVM's value (\d+)$", w[0]) if w else None
    ok(m is not None, "the lock wait's key and default, read off GlobalConfiguration: %s" % (w[0] if w else None))
    kl = [i for i, l in enumerate(L) if l.startswith("Boot 4.1's Liquibase keys")]
    keys = L[kl[0] + 1].split(); cnt = L[kl[0] + 2]
    ok(cnt.startswith("  keys: %d · grep -c release: %d " % (len(keys), len([k for k in keys if "release" in k]))), "Boot's keys counted from the listed names: %s" % cnt.strip())
    ok(not any("release" in k for k in keys), "Boot 4.1 has no release key")
    print("VALUES B: kill -9 while changeset 3 ran (exit 137) -> databasechangeloglock locked=t, lockedby <host> (<ip>), databasechangelog rows 1-2; the sleeping backend 1 terminated -> the next start (wait 0): LockException: Could not acquire change log lock, exit 1 · A: listLocks() 1, forceReleaseLocks() -> locked=f -> Run: 1 · Previously run: 2 · A' the same · the lock wait: a configured wait, %s by default (%s) · Boot's Liquibase keys %d, release keys 0"
          % (m.group(2), m.group(1), len(keys)))

elif MODE == "fail":
    L = lines(sys.argv[2]); J = jvms(L); common(J)
    j = J["u37fail"]; ready(j, False); v = j["view"]
    ok(any(x.startswith("PROBE cause: liquibase.exception.MigrationFailedException: Migration failed for changeset db/changelog/changelog.sql::3::tiffinbox") for x in v), "PostgreSQL: Migration failed for changeset ...::3::tiffinbox")
    ok("PROBE cause: org.postgresql.util.PSQLException: ERROR: syntax error at or near \"VARCHAR\"" in v, "PostgreSQL: syntax error at or near \"VARCHAR\"")
    h = psql(j["after"], HQ); ok([x.split("|")[0] for x in h] == ["1", "2"], "PostgreSQL: databasechangelog rows 1-2 only - no row for the failed changeset")
    c = psql(j["after"], "table_name = 'customer'"); ok(c and "phone" not in c[0], "PostgreSQL: customer has no phone column - changeset 3 rolled back whole (%s)" % c)
    ok(psql(j["after"], LK) == ["1|f|f|"], "PostgreSQL: the lock released")
    k = J["u37failh2"]; ready(k, False)
    ok("PROBE cause: org.h2.jdbc.JdbcSQLNonTransientException: Unknown data type: \"EMAIL\"; SQL statement:" in k["view"], "H2: Unknown data type: \"EMAIL\"")
    a = k["after"]; ix = [i for i, l in enumerate(a) if "FROM DATABASECHANGELOG ORDER BY" in l]
    rws = [l for l in a[ix[0] + 2:ix[0] + 8] if re.match(r"^    \d+ +\| tiffinbox", l)] if ix else []
    ok([r.split()[0] for r in rws] == ["1", "2"], "H2: DATABASECHANGELOG rows 1-2 only - no row for the failed changeset")
    ok("    ID, NAME, MEALS_PER_DAY, PRICE_PER_MEAL, MEAL_TYPE, VERSION, PHONE" in a, "H2: CUSTOMER holds PHONE - half-applied (R.314: H2's, not PostgreSQL's)")
    ok("    ID INTEGER NOT NULL, LOCKED BOOLEAN NOT NULL, LOCKGRANTED TIMESTAMP, LOCKEDBY CHARACTER VARYING" in a, "H2: the lock table's shape, read off Liquibase's own table")
    k2 = J["u37failh2b"]; ready(k2, False)
    ok("PROBE cause: org.h2.jdbc.JdbcSQLSyntaxErrorException: Duplicate column name \"PHONE\"; SQL statement:" in k2["view"], "H2, the next start: Duplicate column name \"PHONE\"")
    ok(summary(k2["view"])["Previously run"] == 2, "H2, the next start: Previously run: 2 (changeset 3 again)")
    p = J["u37path"]; ready(p, True)
    ok("file:../files/changelog.sql" in p["cmd"] and sum(1 for x in J.values() if "change-log=file:" in x["cmd"]) == 2, "the file: form only in the labelled path-identity step (u37path, u37pathm)")
    ok(psql(p["after"], "select id, filename") == ["1|file:../files/changelog.sql", "2|file:../files/changelog.sql"], "the file: run's rows are named by its path")
    m = J["u37pathm"]; ready(m, False)
    ok("PROBE cause: org.postgresql.util.PSQLException: ERROR: relation \"customer\" already exists" in m["view"] and summary(m["view"])["Previously run"] == 0, "the moved file: Previously run: 0 -> relation \"customer\" already exists")
    w = J["u37rbw"]; wa = w["after"]
    ok("PROBE rollback(1): done" in w["view"] and not any(x.startswith("Rolling Back Changeset") for x in w["view"]), "rollback wrong: done, no changeset rolled back")
    ok(psql(wa, "rows' from databasechangelog") == ["2 rows"] and psql(wa, RW) == ["customers 4 · pauses 2"], "rollback wrong: the witness (R.328) - still 2 rows, customers 4 · pauses 2: a done that did nothing")
    r = J["u37rbr"]; ra = r["after"]
    ok(psql(J["u37rb"]["after"], "select id, filename") == ["1|db/changelog/changelog.sql", "2|db/changelog/changelog.sql"], "rollback right: Boot's rows named db/changelog/changelog.sql")
    ok("Rolling Back Changeset: db/changelog/changelog.sql::2::tiffinbox" in r["view"], "rollback right: Rolling Back Changeset ...::2::tiffinbox")
    ok(psql(ra, "rows' from databasechangelog") == ["1 rows"] and psql(ra, RW) == ["customers 0 · pauses 0"], "rollback right: the witness (R.328) - 1 row, customers 0 · pauses 0")
    s = J["u37sumb"]; ready(s, False)
    pr = [x for x in s["view"] if x.startswith("PROBE validation: ")]
    md = psql(s["after"], "select id, md5sum")
    mm = re.match(r"^PROBE validation: db/changelog/changelog\.sql::1::tiffinbox was: (9:[0-9a-f]{32}) but is now: (9:[0-9a-f]{32})$", pr[1]) if len(pr) == 2 else None
    ok(pr and pr[0] == "PROBE validation: 1 changesets check sum" and mm and md[0] == "1|" + mm.group(1) and mm.group(1) != mm.group(2), "the checksum: 1 changesets check sum · was = row 1's md5sum by psql, is now another")
    b = J["u37both"]; ready(b, False)
    ok(summary(b["view"])["Run"] == 2 and any("FlywayException: Found non-empty schema(s) \"public\" but no schema history table" in x for x in b["view"]), "both: Liquibase Run: 2, then Flyway refuses the non-empty schema")
    ok("--spring.flyway.enabled=false" not in b["cmd"], "both: the anchor's Flyway on")
    u = J["u37undo"]
    ok("PROBE migrate(): migrations executed 2" in u["view"] and "PROBE undo() refused: org.flywaydb.core.internal.license.FlywayRedgateEditionRequiredException: Flyway Redgate Edition Required: undo is not supported by OSS Edition" in u["view"], "Flyway's undo(): refused - a labelled step (R.303, RED #1806 re-filed)")
    ok(psql(u["after"], "from flyway_schema_history") == ["1 true", "2 true"], "undo: the history table still 1, 2 true")
    print("VALUES a failed changeset on PostgreSQL: Migration failed ... syntax error at or near \"VARCHAR\", no row for it, phone absent, unlocked · on H2: Unknown data type: \"EMAIL\", no row for it, PHONE present, the next start Duplicate column name \"PHONE\" · the path: file: rows named by the path, the moved copy -> relation \"customer\" already exists · rollback wrong: done, 2 rows, customers 4 · rollback right: 1 row, customers 0 · pauses 0 · the checksum: 1 changesets check sum, was %s but is now %s · both: Liquibase Run: 2, then Flyway's non-empty schema refusal · undo(): Flyway Redgate Edition Required" % (mm.group(1), mm.group(2)))

elif MODE == "compare":
    L = lines(sys.argv[2])
    cells = [l for l in L if l.startswith("cell ")]
    rows = {}
    for c in cells:
        m = re.match(r"^cell ([^|]+) \| (flyway|liquibase|both) \| (.+)$", c)
        ok(m is not None, "a cell line: %s" % c[:60])
        rw, col, val = m.group(1), m.group(2), m.group(3)
        ok(not re.search(r"^·|· ·|·$|:\s*·| \(\s*\)|:\s*$|^\s|\s$|  ", val) and val.strip(), "%s / %s: no empty piece (%s)" % (rw, col, val[:60]))
        ok(not re.search(r"\b(better|simpler|heavier|lighter|safer|easier|faster|slower|worse|cleaner)\b", val, re.I), "%s / %s: no adjective" % (rw, col))
        rows.setdefault(rw, {})[col] = val
    ok(all(("flyway" in v and "liquibase" in v) or list(v) == ["both"] for v in rows.values()), "every row has both columns (or one cell for both)")
    print("VALUES the comparison: %d rows, every cell a printed line" % len(rows))

elif MODE == "table":
    L = lines(sys.argv[2]); R = lines(sys.argv[3])
    out = ["| | Flyway 12.4.0 | Liquibase 5.0.4 |", "|---|---|---|"]
    order = []; rows = {}
    for l in L:
        m = re.match(r"^cell ([^|]+) \| (flyway|liquibase|both) \| (.+)$", l)
        if m:
            if m.group(1) not in rows: order.append(m.group(1)); rows[m.group(1)] = {}
            rows[m.group(1)][m.group(2)] = m.group(3)
    for r in order:
        c = rows[r]
        out.append("| %s | %s | %s |" % (r, c.get("flyway", "(one run, both tools)"), c.get("liquibase", c.get("both"))) if "both" not in c else "| %s | (one run, both tools) | %s |" % (r, c["both"]))
    a = [i for i, l in enumerate(R) if l == "<!-- compare table: begin -->"]; b = [i for i, l in enumerate(R) if l == "<!-- compare table: end -->"]
    ok(len(a) == 1 and len(b) == 1, "README.md: one compare table block")
    got = R[a[0] + 1:b[0]]
    if got != out:
        for x, y in zip(got + [""] * 40, out + [""] * 40):
            if x != y: print("  README: " + x[:150]); print("  built:  " + y[:150]); break
    ok(got == out, "R.261: README.md's table = the table the cell lines build (%d rows)" % len(order))

elif MODE == "xcheck":
    L = lines(sys.argv[2]); x36, filed = sys.argv[3], sys.argv[4]
    s = [l for l in L if l.startswith("  the anchor's md5: ")]
    m = re.match(r"^  the anchor's md5: ([0-9a-f]{32}) · the filed xcheck\.sql: ([0-9a-f]{32}) · cmp: the same, byte for byte · the Flyway lesson's xcheck\.sql: ([0-9a-f]{32}) · diff: 0 lines$", s[0]) if s else None
    ok(m and m.group(1) == m.group(2) == m.group(3) == x36 == filed, "Hibernate's script = the filed xcheck.sql = the Flyway lesson's (md5 read off the files)")
    ok("  exit 0 · HHH000001: 1 · the trap's request lines: 0" in L, "xcheck: exit 0, HHH000001 once, 0 trap lines")
    print("VALUES xcheck: Hibernate's DDL script over the anchor's libraries md5 %s = the Flyway lesson's xcheck.sql, diff 0 lines" % m.group(1))

elif MODE in ("exercise", "wib"):
    L = lines(sys.argv[2])
    def blocks(sh):
        a = L.index([l for l in L if l.startswith("in %s (" % sh)][0])
        br = []; so = []; cur = None
        for l in L[a + 1:]:
            if l.startswith("in "): break
            if l.startswith("  the block's exit "): cur = br; continue
            if l.startswith("  then the solution's lines"): cur = so; continue
            if l.startswith("  the shell is now in"): cur = None; continue
            if cur is not None and l.startswith("    "): cur.append(l[4:])
        return br, so
    bb, bs = blocks("bash"); zb, zs = blocks("zsh")
    if MODE == "wib":
        print("\n".join(bb if sys.argv[3].endswith("README.md") else bs)); sys.exit(0)
    ok(bb == zb and bs == zs, "the exercise prints the same in bash and zsh")
    ok("PROBE update() refused: CommandExecutionException: liquibase.exception.LockException: Could not acquire change log lock.  Currently locked by a killed start since <time>" in bb
       and "PROBE after: DATABASECHANGELOGLOCK id 1 locked true" in bb and "PROBE after: no diner table" in bb, "broken: update refused (LockException), still locked, no diner table")
    ok("PROBE forceReleaseLocks(): done" in bs and "PROBE summary: Run: 2" in bs and "PROBE after: DATABASECHANGELOGLOCK id 1 locked false" in bs, "solved: forceReleaseLocks(), Run: 2, unlocked")
    dr = [l for l in bs if l.startswith("PROBE after: diner rows ")]; cr = [l for l in bs if l.startswith("PROBE after: DATABASECHANGELOG rows ")]
    ok(dr and cr and int(cr[0].rsplit(" ", 1)[1]) == 2, "solved: DATABASECHANGELOG rows 2 = Run: 2")
    ok(bb != bs, "broken and solved print differently (R.196)")
    ok(all("the trap's request lines during this shell: 0" in l for l in L if l.startswith("  the shell is now in") and "solved's" in l), "the exercise's JVMs: 0 trap lines (bash and zsh)")
    F = lines(sys.argv[4]); ex = open("harness/src/probe/l/ex/Ex.java", encoding="utf-8").read()
    shape = "    ID INTEGER NOT NULL, LOCKED BOOLEAN NOT NULL, LOCKGRANTED TIMESTAMP, LOCKEDBY CHARACTER VARYING"
    ok(shape in F and "CREATE TABLE DATABASECHANGELOGLOCK (ID INT NOT NULL, LOCKED BOOLEAN NOT NULL, LOCKGRANTED TIMESTAMP, LOCKEDBY VARCHAR(255)" in ex,
       "the exercise's lock table: the shape Liquibase wrote on H2 in fail (ID, LOCKED, LOCKGRANTED, LOCKEDBY, NOT NULL on the first two)")
    words = int(sys.argv[3])
    print("VALUES exercise: H2 in memory, one JVM - broken: the lock row set by SQL, update refused (Could not acquire change log lock); solved: forceReleaseLocks() then update, Run: 2, %s; the spoken line %d words" % (dr[0][len("PROBE after: "):], words))
else:
    sys.exit("unknown mode " + MODE)
