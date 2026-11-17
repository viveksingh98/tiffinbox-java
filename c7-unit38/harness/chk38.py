"""Unit 38's checks (python3 -I -B harness/chk38.py MODE ...). Each capture's mode reads its capture (.r-NAME.out) and asserts every
number and string the video may say against another witness of the same run - the rows read by a second connection (psql in the
container, the harness's own JDBC class over H2's TCP server) while the harness JVM waits, beside the SQL Hibernate wrote - never
against a typed figure; it prints "ok ..." lines (and, for soft, "cell ..." lines: the table of statement kinds, R.261) and one
"VALUES ..." line, and exits 1 on the first failed assertion. Two helper modes: r250 (the gate before any build: C2's file list,
every sentence of after/ C2 makes false rewritten, R.330's ddl-auto) and wib (an exercise file's "What it prints" block as the bash
run printed it)."""
import os, re, sys

MODE = sys.argv[1]


def ok(cond, what):
    if not cond:
        print("FAIL " + what); sys.exit(1)
    print("ok    " + what)


def lines(p):
    return open(p, encoding="utf-8").read().splitlines()


def flat(t):
    return re.sub(r"\s+", " ", re.sub(r"\n\s*(?:\*|//|#|--)?\s*", " ", t))


# ---- r250 -------------------------------------------------------------------------------------------------------------------
if MODE == "r250":
    A, B = sys.argv[2], sys.argv[3]
    Y = open(os.path.join(A, "tiffinbox-web/src/main/resources/application.yaml"), encoding="utf-8").read()
    dd = re.findall(r"^\s*ddl-auto:\s*(\S+)", Y, re.M)
    ok(dd == ["validate"], "R.330: the anchor's YAML - ddl-auto: %s (validate only; create, update or none refused)" % ",".join(dd))
    ok("# validate: Hibernate checks the migrated schema and writes nothing" in Y, "R.330: the YAML's comment, by its text")
    def files(r):
        out = set()
        for d, ds, fs in os.walk(r):
            for f in fs: out.add(os.path.relpath(os.path.join(d, f), r))
        return out
    fa, fb = files(A), files(B)
    CE = "tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntity.java"; APP = "tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java"
    V3 = "tiffinbox-core/src/main/resources/db/migration/V3__customer_audit_columns.sql"
    changed = sorted(f for f in fa & fb if open(os.path.join(A, f), "rb").read() != open(os.path.join(B, f), "rb").read())
    ok(sorted(fa - fb) == [V3] and not (fb - fa) and changed == ["README.md", CE, APP],
       "C2's file list: new %s; changed %s; deleted or renamed: %s" % (", ".join(sorted(fa - fb)), ", ".join(changed), ", ".join(sorted(fb - fa)) or "none"))
    ce = open(os.path.join(A, CE), encoding="utf-8").read(); app = open(os.path.join(A, APP), encoding="utf-8").read(); v3 = open(os.path.join(A, V3), encoding="utf-8").read()
    for s in ("@EntityListeners(AuditingEntityListener.class)\npublic class CustomerEntity", "    @CreatedDate\n    @Column(updatable = false)\n    private Instant createdAt;",
              "    @LastModifiedDate\n    private Instant updatedAt;", "public Instant getCreatedAt()", "public Instant getUpdatedAt()", "Course 7, unit 38: auditing"):
        ok(s in ce, "C2: CustomerEntity - " + s.strip().replace("\n", " ")[:80])
    ok("@EnableJpaAuditing\npublic class TiffinBoxApp" in app and "import org.springframework.data.jpa.repository.config.EnableJpaAuditing;" in app and "Course 7, unit 38: @EnableJpaAuditing" in app, "C2: TiffinBoxApp - @EnableJpaAuditing, its import, its Javadoc paragraph")
    st = [l for l in v3.splitlines() if not l.startswith("--")]
    ok(st == ["ALTER TABLE customer ADD COLUMN created_at TIMESTAMP(6) WITH TIME ZONE;", "ALTER TABLE customer ADD COLUMN updated_at TIMESTAMP(6) WITH TIME ZONE;"] and len(v3.splitlines()) == 3,
       "C2: V3 - one comment line and the two ALTER statements, nullable, no back-fill")
    # every sentence C2 makes false or incomplete, rewritten (R.250)
    probe = []; two = []; old = []; ent = []
    ALLOW_TWO = ("Course 7 · unit 36 — Flyway: the schema and the seed become two migrations;", "Flyway's two migrations, which retired the Database class")
    for f in sorted(fa):
        t = open(os.path.join(A, f), encoding="utf-8", errors="replace").read()
        if re.search(r"\bPROBE\b", t): probe.append(f)
        if "7f69" "42f0" in t: old.append(f)
        ft = flat(t)
        for mm in re.finditer(r"\btwo migrations\b", ft):
            here = ft[max(0, mm.start() - 120):mm.end() + 120]
            noted = re.match(r"[^.]*Course 7, unit 38|[^.]*\.\s*\*\(?Course 7, unit 38", ft[mm.end():]) is not None
            if not (noted or any(a in here for a in ALLOW_TWO)): two.append(f + ": " + ft[max(0, mm.start() - 60):mm.end() + 60])
    for b in two: print("R.250: a sentence that still says two migrations: " + b)
    ok(not probe, "after/ holds no PROBE wording: %s" % (", ".join(probe) or "0 files"))
    ok(not old, "R.252: no file of after/ quotes the script's old md5 (it moved; unit 34's and 36's READMEs keep theirs): %s" % (", ".join(old) or "0 files"))
    ok(not two, "R.250: every sentence of after/ that names two migrations is the unit 36 section's own history, PauseEntity's V1/V2 sentence, or carries the unit 38 note")
    s1 = flat(ce).split("<p>")[0]
    ok("V3__customer_audit_columns.sql" in s1, "R.250: CustomerEntity's first paragraph names V3 beside V1 and V2")
    R = open(os.path.join(A, "README.md"), encoding="utf-8").read(); head = R.split("\n## ", 1)[0]
    ok("*Course 7, unit 38: and a third, V3, adds two columns to\nthe customer table.*" in head, "R.250: the header's Database sentence (\"Flyway's two migrations create and seed the tables\") carries the unit 38 note")
    ok("*(Course 7, unit 38, **Section 6's second change to this folder (C2)**" in head and "Unit 39 changes it next (C3)" in head, "the anchor README's header carries unit 38's note, C2, and 39 next (C3)")
    ok(head.count("*(Course 7, unit 38: it moved there — one line, the customer table's\ntwo audit columns; its section below.)*") == 1, "R.250: the header's unit 36 note \"Hibernate's own DDL is unit 34's\" carries the moved-there note")
    sec = R.split("\n## Course 7 · unit 36 — ", 1)[1].split("\n## ", 1)[0]
    ok("*(Course 7, unit 38: at version 3\nsince" in sec and "*(Course 7, unit 38: the\nmapping moved" in sec, "R.250: the unit 36 section's \"history table at version 2\" and \"the mapping unchanged\" sentences carry their unit 38 notes")
    s38 = R.split("\n## Course 7 · unit 38 — ", 1)
    ok(len(s38) == 2 and all(w in s38[1].split("\n## ", 1)[0] for w in ("V3__customer_audit_columns.sql", "NULL", "back-fills nothing", "Spring Security — complete")), "the README's unit 38 section: V3, the seeded rows' NULL, the back-fill named, Course 10 by its title")
    sys.exit(0)

# ---- wib: the block an exercise file must show ------------------------------------------------------------------------------
if MODE == "wib":
    L = lines(sys.argv[2]); f = sys.argv[3]
    b = L.index("in bash (/bin/bash --noprofile --norc) - the README's lines:")
    z = L.index("in zsh (/bin/zsh -f) - the README's lines:")
    B = L[b:z]
    s = [i for i, l in enumerate(B) if l.startswith("  then the solution's lines")][0]
    part = B[1:s] if f.endswith("README.md") else B[s:]
    out = []
    for l in part[1:]:
        if l.startswith("  the shell is now in: "): break
        out.append(l[4:])
    print("\n".join(out)); sys.exit(0)

L = lines(sys.argv[2])
VER = ["  PROBE version: Hibernate 7.4.13.Final", "  PROBE version: Spring Data JPA 4.1.2", "  PROBE version: Spring Framework 7.0.10", "  PROBE version: Spring Boot 4.1.2"]
FLYV = "  PROBE version: Flyway 12.4.0"


def block(L, head, nxt):
    a = [i for i, l in enumerate(L) if l.startswith(head)]
    ok(len(a) == 1, "the block: " + head[:70])
    a = a[0]; b = [i for i in range(a + 1, len(L)) if any(L[i].startswith(n) for n in nxt)]
    return L[a:b[0] if b else len(L)]


def step(X, name):
    a = [i for i, l in enumerate(X) if l.startswith("  PROBE >>> " + name)]
    ok(len(a) == 1, "the step: " + name)
    b = [i for i in range(a[0], len(X)) if X[i].startswith("  PROBE <<< " + name)][0]
    return X[a[0] + 1:b]


def sqls(S):
    return [l[8:] for l in S if l.startswith("  SQL : ")]


def second(X, name):
    a = [i for i, l in enumerate(X) if l.startswith("  SECOND " + name + " - ")]
    ok(len(a) == 1, "the second connection's read at the pause: " + name)
    out = []
    for l in X[a[0] + 1:]:
        if not l.startswith("      "): break
        out.append(l.strip())
    return out


def jvm(X, what, code="0"):
    ok(all(v in X for v in VER) and FLYV in X and "  INFO  [main] org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final" in X,
       "R.246/R.329: %s - the version lines (Flyway 12.4.0: on the class path, disabled) and HHH000001" % what)
    ex = [l for l in X if re.match(r"^  exit \d+ · its WARN lines: \d+ · its SQL lines: \d+$", l)]
    ok(len(ex) == 1 and ex[0].startswith("  exit %s " % code), "%s: exit %s" % (what, code))


def has(X, line, what):
    ok(line in X, what + ": " + line.strip()[:120])


def row(X, pause, what):
    r = second(X, pause); ok(len(r) == 1, what + " - one row: " + (r[0] if r else "none")); return dict(kv.rsplit(":", 1) if re.search(r":[tf]$", kv) else kv.split("=", 1) for kv in r[0].split())


if MODE == "audit":
    has(L, "Envers (history tables): named, not fetched - after/'s lib/ holds 0 envers jars; the harness's class-path line says the same (above)", "Envers: not fetched")
    ok(all("Envers (absent: ClassNotFoundException)" in l for l in L if l.startswith("  PROBE class path: ")), "every harness JVM: Envers absent from its class path")
    V = {}
    for db, nm, nx in (("pg", "PostgreSQL", "H2 over TCP"), ("h2", "H2 over TCP", None)):
        Bk = block(L, "B - probe.a.AMain on " + nm, ["A - probe.a2.AMain on " + nm]); jvm(Bk, nm + " B")
        Ak = block(L, "A - probe.a2.AMain on " + nm, ["the empty auditor - probe.a.AMain on " + nm]); jvm(Ak, nm + " A")
        Ek = block(L, "the empty auditor - probe.a.AMain on " + nm, ["B - probe.a.AMain on " + nx] if nx else ["Envers"]); jvm(Ek, nm + " the empty auditor")
        ddl = [s for s in sqls(Bk) if s.startswith("create table a_customer (")]
        ok(len(ddl) == 1 and "created_at timestamp(6) with time zone," in ddl[0] and "updated_at timestamp(6) with time zone," in ddl[0] and "created_by varchar(255)," in ddl[0],
           nm + ": the DDL create-drop logged - Instant -> timestamp(6) with time zone (nullable), the auditors varchar(255)")
        ins = sqls(step(Bk, "insert")); ok(len(ins) == 1, nm + ": the insert - one statement")
        cols = re.match(r"insert into a_customer \(([a-z_,]+)\) values", ins[0]).group(1)
        ok(cols.replace(",id", "") == "created_at,created_by,meals_per_day,name,updated_at,updated_by,version", nm + ": the INSERT's columns - " + cols)
        r = row(Bk, "insert", nm + " insert")
        ok(r["version"] == "0" and r["created_at_null"] == "f" and r["updated_at_null"] == "f" and r["created_at=updated_at"] == "t" and r["created_by"] == "kitchen" and r["updated_by"] == "kitchen",
           nm + ": after the insert, by the second connection - version 0, both stamps set, created_at = updated_at (one instant), kitchen twice")
        up = [s for s in sqls(step(Bk, "edit")) if s.startswith("update ")]
        ok(up == ["update a_customer set created_at=?,created_by=?,meals_per_day=?,name=?,updated_at=?,updated_by=?,version=? where id=? and version=?"], nm + ": the edit's UPDATE - every column (R.191), where id=? and version=?")
        r = row(Bk, "edit", nm + " edit")
        ok(r["version"] == "1" and r["meals_per_day"] == "3" and r["updated_at>created_at"] == "t" and r["created_at_null"] == "f", nm + ": after the edit - version 1, updated_at > created_at")
        un = [s for s in sqls(step(Bk, "unchanged")) if not s.startswith("select ")]
        ok(un == [], nm + ": the unchanged save - 0 INSERT/UPDATE lines (its SQL: %d select)" % len(sqls(step(Bk, "unchanged"))))
        r = row(Bk, "unchanged", nm + " unchanged"); ok(r["version"] == "1", nm + ": after the unchanged save - version 1")
        mg = [s for s in sqls(step(Bk, "merge")) if s.startswith("update ")]
        ok(mg == up, nm + ": the merge's UPDATE - the same statement, every column")
        r = row(Bk, "merge", nm + " merge")
        ok(r["created_at_null"] == "t" and r["created_by"] == "null" and r["updated_by"] == "kitchen" and r["version"] == "2" and r["meals_per_day"] == "4",
           nm + ": B - after the copy was merged: created_at NULL, created_by NULL, updated_by kitchen, version 2")
        hd = [s for s in sqls(Bk) if s.startswith("create table h_customer (")]
        ok(len(hd) == 1 and "created timestamp(6) with time zone not null" in hd[0] and "db_stamp timestamp(6) with time zone not null" in hd[0], nm + ": Hibernate's own - timestamp(6) with time zone not null")
        hi = sqls(step(Bk, "hibernate-insert")); ok(len(hi) == 1 and "values (?,localtimestamp,?,?,?" in hi[0], nm + ": @CurrentTimestamp(source = DB) - localtimestamp in the SQL text: " + hi[0])
        ok(("returning id,db_stamp" in hi[0]) == (db == "pg"), nm + ": the INSERT %s returning" % ("with" if db == "pg" else "without"))
        he = [s for s in sqls(step(Bk, "hibernate-edit")) if s.startswith("update ")]
        ok(len(he) == 1 and he[0].startswith("update h_customer set db_stamp=localtimestamp,"), nm + ": the edit - db_stamp=localtimestamp: " + he[0])
        r = row(Bk, "h-edit", nm + " h-edit"); ok(r["updated>created"] == "t" and r["db_stamp_null"] == "f", nm + ": Hibernate's own - updated > created after the edit, db_stamp set")
        fx = [s for s in sqls(step(Ak, "merge")) if s.startswith("update ")]
        ok(fx == ["update a_customer set meals_per_day=?,name=?,updated_at=?,updated_by=?,version=? where id=? and version=?"], nm + ": A - the merge's UPDATE without the two created columns")
        r = row(Ak, "merge", nm + " fix merge")
        ok(r["created_at_null"] == "f" and r["created_by"] == "kitchen" and r["version"] == "1", nm + ": A - after the merge: created_at kept (created_at_null=f), created_by kitchen")
        r = row(Ek, "insert", nm + " empty auditor")
        ok(r["created_by"] == "null" and r["updated_by"] == "null" and r["created_at_null"] == "f", nm + ": the empty auditor - created_by null, updated_by null, the stamps still set")
        V[db] = (cols, mg[0], fx[0], hi[0])
    ok(V["pg"][1:3] == V["h2"][1:3], "both databases: the same UPDATE statements (the leak and its fix)")
    print("VALUES Spring Data's auditing (its listener, a fixed auditor kitchen), the same on both: Instant -> timestamp(6) with time zone; INSERT (%s) -> version 0, created_at = updated_at, kitchen twice; an edit -> %s (every column), version 1, updated_at > created_at; an unchanged save -> 0 statements; B: a copy merged -> the same UPDATE, created_at NULL, created_by NULL, updated_by kitchen, version 2; A: @Column(updatable = false) -> %s, created_at kept, created_by kitchen (A' the other database); the empty auditor -> created_by null; Hibernate's own: @CreationTimestamp/@UpdateTimestamp parameters, @CurrentTimestamp(source = DB) -> %s (PostgreSQL), no returning on H2; Envers not fetched"
          % (V["pg"][0], V["pg"][1], V["pg"][2], V["pg"][3]))
    sys.exit(0)

if MODE == "soft":
    kinds = [l for l in L if l.startswith("  the statement kinds, each a labelled step: ")][0].split(": ", 1)[1].split()
    ok(len(kinds) >= 8, "the statement kinds, a named list read off SMain (R.187): " + " ".join(kinds))
    w = [l for l in L if l.startswith("  @Where in Hibernate's jar")][0]
    ok(re.search(r"Where\.class 0 · SQLRestriction\.class 1 · SoftDelete\.class 1$", w) is not None, "R.323: @Where - Where.class 0 in hibernate-core-7.4.13.Final.jar, SQLRestriction.class 1, SoftDelete.class 1")
    V = {}
    for db, nm, nx in (("pg", "PostgreSQL", "H2 over TCP"), ("h2", "H2 over TCP", None)):
        S = block(L, "probe.s.SMain on " + nm, ["leak 3, a labelled step - probe.sl.LMain on " + nm]); jvm(S, nm + " SMain (the control: LAZY, optional = false - built)")
        Lz = block(L, "leak 3, a labelled step - probe.sl.LMain on " + nm, ["leak 3, its second step - probe.sm.LMain on " + nm])
        Mz = block(L, "leak 3, its second step - probe.sm.LMain on " + nm, ["probe.s.SMain on " + nx] if nx else ["@@none"])
        ok("  PROBE ready: yes" in S, nm + ": the control's factory built")
        ddl = [s for s in sqls(S) if s.startswith("create table s_customer (") or s.startswith("create table o_customer (")]
        ok(len(ddl) == 2 and all(d.startswith("create table %s_customer (deleted boolean not null," % t) for d, t in zip(sorted(ddl), "os")), nm + ": the DDL - deleted boolean not null (Hibernate's column; the old pair's field written by hand)")
        rm = sqls(step(S, "remove - Meera, @SoftDelete")); ok(rm[-1] == "update s_customer set deleted=true where id=? and deleted=false", nm + ": @SoftDelete's remove - " + rm[-1])
        ro = sqls(step(S, "remove - Meera, @SQLDelete")); ok(ro[-1] == "update o_customer set deleted = true where id = ?", nm + ": the old pair's remove - its own string")
        rows = second(S, "removed")
        ok(rows == ["s_customer rows=3 flagged=1", "o_customer rows=3 flagged=1", "s_pause rows=2"], nm + ": by the second connection - " + " · ".join(rows))
        ids = [l for l in S if l.startswith("  PROBE ids: ")][0]; mid = re.search(r"Meera (\d+),", ids).group(1)
        cells = []
        for k in kinds:
            X = step(S, "kind " + k); q = sqls(X); res = [l for l in X if l.startswith("  PROBE result: ")]
            frag = [re.search(r"(?:join s_customer \w+ on \S+ and )?\(?\w+\.deleted ?= ?false\)?", s) for s in q]
            ok(q and all(frag) and len(res) == 1, "%s: %s - the clause in every statement (%d)" % (nm, k, len(q)))
            cells.append((k, " · ".join(f.group(0) for f in frag), res[0][len("  PROBE result: "):]))
        for c in cells: print("cell %s | %s | `%s` | %s |" % (nm, c[0], c[1], c[2]))
        bp = step(S, "bypass - a native query")
        ok(sqls(bp) == ["select * from s_customer order by name"] and "  PROBE result: [Meera, Ravi, Sunil]" in bp, nm + ": R.323's bypass - the native query has no clause and returns the removed Meera")
        l1 = step(S, "leak 2 - the pause of the removed customer: findById(1)")
        ok(len(sqls(l1)) == 2 and "deleted=false" in sqls(l1)[1] and "  PROBE result: Optional.empty" in l1, nm + ": leak 2 - findById(1): two selects, the second filtered, Optional.empty")
        has(step(S, "leak 2 - the pauses: findAll, count"), "  PROBE result: findAll ids [1, 2] · count() 2", nm + ": leak 2 - findAll lists it, count 2")
        l3 = step(S, "leak 2 - the first pause from findAll")
        en = [l for l in l3 if "threw: jakarta.persistence.EntityNotFoundException: No row with the given identifier exists for entity [probe.s.SMain$SCustomer with id '%s']" % mid in l]
        ok(len(en) == 1 and "  PROBE   cause: org.hibernate.ObjectNotFoundException: No row with the given identifier exists for entity [probe.s.SMain$SCustomer with id '%s']" % mid in l3,
           nm + ": leak 2 - its customer: EntityNotFoundException <- ObjectNotFoundException, with id '%s' (Meera's, printed by the seed)" % mid)
        eg = step(S, "eager - the same pause")
        ok(any("left join s_customer c1_0 on c1_0.id=" in s and "and c1_0.deleted=false" in s for s in sqls(eg)) and "  PROBE result: present, its customer null" in eg, nm + ": the EAGER optional mapping - left join with the clause, the pause present, its customer null")
        co = step(S, "collection - Sunil's pauses")
        ok(any(s.startswith("select p1_0.customer_id,p1_0.id,p1_0.days from s_pause p1_0 where p1_0.customer_id=?") for s in sqls(co)) and "  PROBE result: 1" in co, nm + ": the collection side - no clause on s_pause, 1")
        l1 = step(S, "leak 1 - a new Meera saved")
        ok(sqls(l1)[0].startswith("insert into s_customer (name,deleted") and "values (?,false" in sqls(l1)[0], nm + ": leak 1 - " + sqls(l1)[0])
        dv = [l for l in l1 if "threw: org.springframework.dao.DataIntegrityViolationException: " in l]
        cv = [l for l in l1 if l.startswith("  PROBE   cause: org.hibernate.exception.ConstraintViolationException: ")]
        txt = 'duplicate key value violates unique constraint "s_customer_name_key"' if db == "pg" else "Unique index or primary key violation"
        ok(len(dv) == 1 and txt in dv[0] and len(cv) == 1 and "  PROBE   SQLState: 23505" in l1, nm + ": leak 1 - DataIntegrityViolationException <- ConstraintViolationException, %s, SQLState 23505" % txt)
        jvm(Lz, nm + " leak 3, LAZY optional", "1")
        rf = [l for l in Lz if "UnsupportedMappingException: To-one attribute (probe.sl.LMain$SPauseOpt.customer) cannot be mapped as LAZY as its associated entity is defined with @SoftDelete" in l]
        ok(len(rf) >= 1 and "  PROBE ready: no" in Lz and "  PROBE <<< closed, exit 1" in Lz, nm + ": leak 3 (R.303, R.312) - refused at start: UnsupportedMappingException, ready: no, exit 1 - beside its control, the SMain JVM above (optional = false: built)")
        ok(any("Unable to build Hibernate SessionFactory" in l for l in Lz), nm + ": leak 3 - its chain names Unable to build Hibernate SessionFactory")
        jvm(Mz, nm + " leak 3's second step", "0")
        ok("  PROBE ready: yes" in Mz and not any("UnsupportedMappingException" in l for l in Mz), nm + ": leak 3's second step - the same mapping in another package: built (the refusal is not a guarantee)")
        um = [l for l in rf if l.startswith("  PROBE cause: org.hibernate.metamodel.UnsupportedMappingException: ")]
        ok(len(um) == 1, nm + ": leak 3 - the refusal's own line")
        V[db] = (cells, um[0].split("cause: ", 1)[1], dv[0].split("threw: ", 1)[1][:160], mid)
    ok([c[:2] for c in V["pg"][0]] == [c[:2] for c in V["h2"][0]] and [c[2] for c in V["pg"][0]] == [c[2] for c in V["h2"][0]], "both databases: the same clause and the same result in every kind")
    print("VALUES @SoftDelete -> deleted boolean not null; remove -> update s_customer set deleted=true where id=? and deleted=false; the old pair its own string; by the second connection s_customer rows 3 flagged 1, o_customer rows 3 flagged 1; the clause in %d statement kinds (%s), the same on both; the native query -> [Meera, Ravi, Sunil] (no clause); leak 1 -> SQLState 23505 (PostgreSQL: duplicate key value violates unique constraint \"s_customer_name_key\"; H2: Unique index or primary key violation); leak 2 -> findById(1) Optional.empty, findAll [1, 2], count 2, its customer EntityNotFoundException: No row with the given identifier exists (id '%s'); the EAGER optional mapping -> present, its customer null; leak 3 -> %s, exit 1, beside its control (optional = false: built) - and the same mapping in another package built; Where.class 0, SQLRestriction.class 1"
          % (len(kinds), ", ".join(kinds), V["pg"][3], V["pg"][1]))
    sys.exit(0)

if MODE == "anchor":
    for nm in ("B - ", "A - ", "A2 - "):
        ok(any(l.startswith(nm + "TiffinBox on PostgreSQL + the harness's driver (.m2-demo/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar on its class path; its lib/ holds none)") for l in L), "R.335: %s's line says + the harness's driver" % nm.strip(" -"))
    for l in ("  changed: README.md", "  changed: tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntity.java", "  changed: tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java",
              "  new: tiffinbox-core/src/main/resources/db/migration/V3__customer_audit_columns.sql", "  the YAML's ddl-auto line, after/: ddl-auto: validate"):
        has(L, l, "C2")
    ok(not any(l.startswith("  deleted: ") for l in L), "C2: no file deleted")
    Bk = block(L, "B - TiffinBox", ["A - TiffinBox"]); Ak = block(L, "A - TiffinBox", ["A2 - TiffinBox"]); Pk = block(L, "A2 - TiffinBox", ["Flyway's version in TiffinBox's JVMs"])
    K = '  -> 201 {"name":"Kavya","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}'
    def histrows(X, which):
        i = [j for j, l in enumerate(X) if l == "  the second connection - the history table" + which + ":"][0]; out = []
        for l in X[i + 1:]:
            if not l.startswith("    "): break
            out.append(l.strip())
        return out
    def colsline(X):
        i = [j for j, l in enumerate(X) if l.startswith("  the second connection - customer's columns")][0]; return X[i + 1].strip()
    hb = histrows(Bk, ""); ok(len(hb) == 2 and all(r.endswith("|sa|t") for r in hb), "B: the history table by psql - %d rows, success t (V1, V2)" % len(hb))
    cb = colsline(Bk); ok("created_at" not in cb and "updated_at" not in cb, "B (the failure receipt - the catalogue): customer's columns have no stamp: " + cb)
    has(Bk, K, "B: POST Kavya 201")
    ok(any('ERROR:  column "created_at" does not exist' in l for l in Bk), "B: the stamps cannot be read - column \"created_at\" does not exist")
    for nm, X in (("A", Ak), ("A'", Pk)):
        ok('  Flyway: INFO Migrating schema "public" to version "3 - customer audit columns"' in X and any(l.startswith('  Flyway: INFO Successfully applied 3 migrations to schema "public", now at version v3') for l in X), nm + ": V3 migrated - Migrating ... \"3 - customer audit columns\", 3 applied")
        h = histrows(X, ""); ok(len(h) == 3 and all(r.endswith("|sa|t") for r in h) and h[2].startswith("3|3|customer audit columns|SQL|V3__customer_audit_columns.sql|"), nm + ": R.313 - the history table by psql, %d rows, success t, the third V3" % len(h))
        c = colsline(X); ok("created_at timestamp(6) with time zone" in c and "updated_at timestamp(6) with time zone" in c, nm + ": customer's columns - " + c)
        has(X, K, nm + ": POST Kavya 201")
        i = [j for j, l in enumerate(X) if l == "  the second connection - each customer's stamps, by id:"][0]; st = [l.strip() for l in X[i + 1:i + 6]]
        ok(len([x for x in st[:4] if re.fullmatch(r"[A-Z][a-z]+ created_at_null=t updated_at_null=t created_at=updated_at:f", x)]) == 4, nm + ": the four seeded rows - no stamps (NULL, NULL): V2 ran before V3: " + ", ".join(x.split()[0] for x in st[:4]))
        ok(st[4] == "Kavya created_at_null=f updated_at_null=f created_at=updated_at:t", nm + ": Kavya - both stamps set, one instant: " + st[4])
        ok(any(l.startswith("  -> 200 {") and '"name":"Kavya"' in l for l in X) and "  -> 200 · customers listed: 5 (Kavya Meera Priya Ravi Sunil)" in X, nm + ": GET /customers/Kavya 200, 5 listed")
        sq = [l for l in X if l.startswith("  -> 200 · the request's org.hibernate.SQL lines, between its two markers: ")]
        ok(len(sq) == 2 and all(l.endswith(": 4 · WARN lines: 0 · ERROR lines: 0") for l in sq), nm + ": GET /dashboard (HTML and JSON) - 4 SQL lines each")
        js = [l for l in X if l.startswith("  its JSON: ")][0]
        ok(sorted(re.findall(r'"(\w+)":', js)) == ["customers", "monthRevenue", "names", "pausedDays"] and "created" not in js.lower(), nm + ": the JSON dashboard keeps its four keys, no stamp")
    has(Ak, "  PROBE emf hibernate.hbm2ddl.auto = validate", "R.330: the anchor's EMF says validate")
    ok("  PROBE ready: yes" in Ak and "  PROBE <<< closed, exit 0" in Ak and '  INFO  [main] org.flywaydb.core.internal.command.DbMigrate : Schema "public" is up to date. No migration necessary.' in Ak, "R.330: validate passing against V1-V3 on PostgreSQL (the Emf JVM started, Flyway up to date)")
    ok(FLYV in Ak and all(v in Ak for v in VER), "R.329/R.246: the Emf JVM's version lines")
    has(L, "Flyway's version in TiffinBox's JVMs (R.329): Boot prints none; the jar on their class path, the file VersionPrinter.getVersion() reads (unzip -p flyway-core-12.4.0.jar org/flywaydb/core/internal/version.txt): 12.4.0", "R.329 for TiffinBox's JVMs")
    print("VALUES TiffinBox on PostgreSQL + the harness's driver (after/'s lib/ holds none): B (before/): history 2 rows, customer's columns without a stamp (the catalogue), POST Kavya 201, her stamps unreadable (column \"created_at\" does not exist); A (after/): Migrating ... \"3 - customer audit columns\", history 3 rows success t, created_at and updated_at timestamp(6) with time zone, POST Kavya 201 - her created_at and updated_at set and equal, the four seeded rows NULL and NULL (V2 ran before V3), GET /customers/Kavya 200, 5 listed, GET /dashboard 200 with 4 SQL lines (HTML and JSON), the JSON's four keys; the anchor's EMF hibernate.hbm2ddl.auto = validate, passing; A' = A")
    sys.exit(0)

if MODE == "seven":
    S466 = sys.argv[3]
    ok(sum(1 for l in L if l == "  exit 0 · the seven responses: 7 lines · md5 " + S466) == 2 and "  the seven, after/ against before/: lines that differ: 0" in L, "the seven %s on before/ and after/ (a guard)" % S466)
    q = [l for l in L if l.startswith("  its log's org.hibernate.SQL lines during the seven: ")]
    ok(len(q) == 2 and q[0] == q[1], "the SQL lines during the seven, the same on both: " + q[0].split(": ")[1])
    has(L, "  its log before the seven: Migrating lines 2 · 'Successfully applied 2 migrations' 1 · 'Successfully applied 3 migrations' 0 · Flyway's H2 WARN 1", "before/: V1 and V2")
    has(L, "  its log before the seven: Migrating lines 3 · 'Successfully applied 2 migrations' 0 · 'Successfully applied 3 migrations' 1 · Flyway's H2 WARN 1", "after/: V1, V2 and V3")
    print("VALUES %s on before/ and after/ (H2 over TCP), SQL lines during it %s on both; after/'s start: 3 Migrating lines, Successfully applied 3 migrations 1" % (S466, q[0].split(": ")[1]))
    sys.exit(0)

if MODE == "tests":
    for l in ("    TEST-com.tiffinbox.web.TiffinBoxWebTest.xml: tests 14 · failures 0 · errors 0 · skipped 0", "    TEST-com.tiffinbox.web.FullStackTest.xml: tests 3 · failures 0 · errors 0 · skipped 0",
              "    TEST-com.tiffinbox.web.FeedTest.xml: tests 1 · failures 0 · errors 0 · skipped 0", "  exit 0 · BUILD SUCCESS · offline: yes", "    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0",
              "  Surefire's console summary (its Results line): tests 18 · failures 0 · errors 0 · skipped 0 · the reports' sum the same: yes"):
        has(L, l, "tests")
    f = [l for l in L if l.startswith("  its log's Flyway lines - ")][0]
    m = re.search(r"'Successfully applied 3 migrations': (\d+) · 'is up to date. No migration necessary': (\d+) · Flyway's H2 WARN \('newer than the version Flyway has been verified with'\): (\d+)$", f)
    ok(m is not None and m.group(1) == "1" and m.group(2) == "1", "tests: one context migrates V1-V3, the other finds them migrated (%s, %s); the H2 WARN counted, not a failure (%s)" % (m.group(1), m.group(2), m.group(3)) if m else "tests: the Flyway line")
    print("VALUES 18 (14/3/1) on after/ from Surefire's reports, offline - a guard, C7-4 re-run after C2; its log: Successfully applied 3 migrations %s, is up to date %s, Flyway's H2 WARN %s" % m.groups())
    sys.exit(0)

if MODE == "xcheck":
    X36, XF, f36, fx = sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6]
    md = [l for l in L if l.startswith("  after/'s md5: ")][0]
    m = re.match(r"^  after/'s md5: ([0-9a-f]{32}) · the filed xcheck\.sql: ([0-9a-f]{32}) · cmp: the same, byte for byte · the Flyway lesson's xcheck\.sql: ([0-9a-f]{32}) · diff: 2 lines$", md)
    ok(m is not None and m.group(2) == XF and m.group(3) == X36 and m.group(1) != X36, "xcheck: Hibernate's script = the filed xcheck.sql, and not the Flyway lesson's - it moved (R.252): " + (m.group(1) if m else md))
    a = open(f36, encoding="utf-8").read().splitlines(); b = open(fx, encoding="utf-8").read().splitlines()
    da = [x for x in a if x not in b]; db = [x for x in b if x not in a]
    ok(len(da) == 1 and len(db) == 1 and da[0].startswith("create table customer (") and db[0].startswith("create table customer (") and a[1:] == b[1:], "xcheck: the one line that moved - create table customer")
    added = [c for c in re.split(r",\s*(?![^()]*\))", db[0][len("create table customer ("):-2]) if c not in re.split(r",\s*(?![^()]*\))", da[0][len("create table customer ("):-2])]
    ok(added == ["created_at timestamp(6) with time zone", "updated_at timestamp(6) with time zone"], "xcheck: the line gains " + ", ".join(added))
    has(L, "  INFO  [main] org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final", "HHH000001")
    has(L, "  exit 0 · its WARN lines: 0 · its org.flywaydb lines: 0 · Flyway's jar on its class path: 0", "no Flyway in the xcheck JVM")
    print("VALUES Hibernate's script over after/'s libraries %s (the Flyway lesson's was %s): one line moved - create table customer gains %s; validate accepts V1-V3 (anchor, the EMF)" % (m.group(1), X36, ", ".join(added)))
    sys.exit(0)

if MODE == "exercise":
    EXW, EXQ = sys.argv[3], sys.argv[4]
    b = L.index("in bash (/bin/bash --noprofile --norc) - the README's lines:"); z = L.index("in zsh (/bin/zsh -f) - the README's lines:")
    ok(L[b + 1:z] == L[z + 1:z + 1 + (z - b - 1)], "exercise: bash and zsh print the same")
    B = L[b:z]; s = [i for i, l in enumerate(B) if l.startswith("  then the solution's lines")][0]
    R, So = B[:s], B[s:]
    has(R, "    PROBE after the copy was saved: created_at_null=t", "the README: the creation stamp NULL after the copy was saved")
    ok(any(l.startswith("    SQL : update diner set created_at=?,") for l in R), "the README: the UPDATE writes created_at")
    has(So, "    PROBE after the copy was saved: created_at_null=f", "the solution: kept")
    ok(any(l.startswith("    SQL : update diner set ") for l in So) and not any(l.startswith("    SQL : update diner set created_at") for l in So), "the solution: the UPDATE without created_at")
    ok(sum(1 for l in B if l.startswith("  the shell is now in: this unit's folder")) == 2, "the shell back in this folder")
    ok(EXW == str(len(EXQ.split())), "the spoken line: %s words (wc -w, and split here)" % EXW)
    print("VALUES one JVM, H2 in memory, a Diner of its own: the copy saved (merged) -> update diner set created_at=?,... -> created_at_null=t; the solution @Column(updatable = false) -> the UPDATE without created_at -> created_at_null=f (%s words)" % EXW)
    sys.exit(0)
sys.exit("unknown mode " + MODE)
