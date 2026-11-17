"""Unit 35's checks (python3 -I -B harness/chk35.py MODE ...). Each capture's mode reads its capture (.r-NAME.out) and asserts every
number and string the video may say against another witness of the same run - the catalogue and the rows read by a second connection
(psql in the container, probe.d.Db over TCP on H2) before and after the JVM, beside Hibernate's SQL logger and the EMF's own property
(R.188) - never against a typed figure; it prints "ok ..." lines and one "VALUES ..." line, and exits 1 on the first failed assertion.
Every run's database dies with it (R.178: PostgreSQL's drop + the listing, H2's SHUTDOWN + IFEXISTS); a GenerationTarget WARN is the
damage shown, counted twice and read beside "ready: yes" (R.315, R.213's labelled exception); validate's verdicts are 7.4.13's texts
(R.316, R.241). "changes" prints the cell lines; "table" builds the README's table from them (R.261); "wib" gives an exercise file's
"What it prints" block as the bash run printed it."""
import re, sys

MODE = sys.argv[1]


def ok(cond, what):
    if not cond:
        print("FAIL " + what); sys.exit(1)
    print("ok    " + what)


def lines(p):
    return open(p, encoding="utf-8").read().splitlines()


VERS = ["PROBE version: Hibernate 7.4.13.Final", "PROBE version: Spring Data JPA 4.1.2", "PROBE version: Spring Framework 7.0.10",
        "PROBE version: Spring Boot 4.1.2", "INFO  [main] org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final",
        "PROBE class path: Flyway (absent: ClassNotFoundException) · Liquibase (absent: ClassNotFoundException) · Testcontainers (absent: ClassNotFoundException)"]
SUM = re.compile(r"^  exit (\d+) · SQL lines before closing: (\d+) · after closing: (\d+) · GenerationTarget WARN lines: (\d+) · WARN lines: (\d+)$")


def runs(L):
    """label -> dict(db, before, jvm, exit, sqlb, sqla, gen, after, drop, pre)"""
    out = {}; order = []
    heads = [i for i, l in enumerate(L) if l.startswith("-- ")]
    for k, a in enumerate(heads):
        b = heads[k + 1] if k + 1 < len(heads) else len(L)
        m = re.match(r"^-- (\S+) · (PostgreSQL|H2 over TCP|H2 in the JVM's memory)", L[a])
        if not m: continue
        lab, db = m.group(1), m.group(2)
        B = L[a + 1:b]
        # the failure receipt and the chain follow the last run: cut there
        for j, l in enumerate(B):
            if not l.startswith(" "): B = B[:j]; break
        cpx = [j for j, l in enumerate(B) if l.startswith("  $ CPX=")]
        sm = [j for j, l in enumerate(B) if SUM.match(l)]
        ok(len(cpx) == 1 and len(sm) == 1 and cpx[0] < sm[0], "%s: one JVM, its view and its counts" % lab)
        r = {"db": db, "pre": [l for l in B[:cpx[0]] if l.startswith("  length:") or l.startswith("  the over-long name") or re.match(r"^    rows \d+$", l)]}
        r["before"] = [l[4:] for l in B[:cpx[0]] if l.startswith("    ") and not l.startswith("    seed:") and not re.match(r"^    rows \d+$", l)]
        r["jvm"] = [l[4:] for l in B[cpx[0] + 1:sm[0]]]
        g = SUM.match(B[sm[0]]).groups()
        r["exit"], r["sqlb"], r["sqla"], r["gen"], r["warn"] = [int(x) for x in g]
        r["after"] = [l[4:] for l in B[sm[0] + 1:] if l.startswith("    ") and "the database after SHUTDOWN" not in l]
        r["drop"] = [l for l in B[sm[0] + 1:] if "the databases named u35" in l or "the database after SHUTDOWN" in l]
        out[lab] = r; order.append(lab)
    return out, order


def common(lab, r):
    j = r["jvm"]
    for v in VERS: ok(v in j, "%s: %s" % (lab, v[:60]))
    sq = [x for x in j if x.startswith("DEBUG [main] org.hibernate.SQL : ")]
    cl = j.index("PROBE >>> closing the context") if "PROBE >>> closing the context" in j else len(j)
    ok(len([x for x in j[:cl] if x in sq]) == r["sqlb"] and len([x for x in j[cl:] if x in sq]) == r["sqla"],
       "%s: the SQL lines shown = the counts, before and after closing (%d, %d)" % (lab, r["sqlb"], r["sqla"]))
    gw = [x for x in j if "GenerationTarget encountered exception accepting command" in x]
    ok(len(gw) == r["gen"], "%s: the GenerationTarget WARN lines shown (%d) = the log's count (%d)" % (lab, len(gw), r["gen"]))
    ready = [x for x in j if x.startswith("PROBE ready: ")]
    ok(len(ready) == 1, "%s: one ready line" % lab)
    ok((ready[0] == "PROBE ready: yes") == (r["exit"] == 0), "%s: %s beside exit %d" % (lab, ready[0], r["exit"]))
    if r["db"] != "H2 in the JVM's memory":
        if r["db"] == "PostgreSQL":
            ok(len(r["drop"]) == 1 and r["drop"][0].endswith("drop database %s with (force) · the databases named u35… now: (none)" % lab),
               "%s: R.178 - the database dropped, none named u35… left" % lab)
        else:
            ok(len(r["drop"]) == 1 and r["drop"][0].strip().startswith("the database after SHUTDOWN: gone (IFEXISTS=TRUE refused"),
               "%s: R.178 - the in-memory database shut down, gone" % lab)
    return sq, gw


def emf(r):
    e = [x for x in r["jvm"] if x.startswith("PROBE emf hibernate.hbm2ddl.auto = ")]
    return e[0].split(" = ", 1)[1] if e else None


def cat(C, key):
    return [x for x in C if x.startswith(key)]


def colmap(C):
    d = {}
    for x in C:
        m = re.match(r"^col customer\.(\S+) (.*)$", x)
        if m: d[m.group(1)] = m.group(2)
    return d


def rows(C):
    x = cat(C, "rows customer ")
    return x[0] if x else None


def stmts(sq):
    return [x.split(" : ", 1)[1] for x in sq]


VALS = []
# ---- default ----------------------------------------------------------------------------------------------------------------
if MODE == "default":
    R, O = runs(lines(sys.argv[2]))
    ok(O == ["u35dpg", "u35dtcp", "u35dmem"], "default: three labelled JVMs - PostgreSQL, H2 over TCP, H2 in memory")
    for lab in ("u35dpg", "u35dtcp"):
        r = R[lab]; sq, gw = common(lab, r)
        ok(emf(r) == "null", "%s: hibernate.hbm2ddl.auto off the EMF = null (Boot sets nothing)" % lab)
        ok(r["sqlb"] == 0 and r["sqla"] == 0 and not gw and r["exit"] == 0, "%s: 0 SQL lines, exit 0" % lab)
        ok(r["before"] == r["after"] and rows(r["after"]) == "rows customer 4 · pause 2", "%s: the catalogue and rows unchanged: %s" % (lab, rows(r["after"])))
    r = R["u35dmem"]; sq, gw = common("u35dmem", r)
    ok(emf(r) == "create-drop", "u35dmem: hibernate.hbm2ddl.auto off the EMF = create-drop")
    st = stmts(sq)
    six = st[:r["sqlb"]]; two = st[r["sqlb"]:]
    ok(r["sqlb"] == 6 and r["sqla"] == 2, "u35dmem: 6 SQL lines at start, 2 after closing (the logger's count)")
    ok(six[0] == "drop table if exists customer cascade" and six[1] == "drop table if exists pause cascade" and six[2].startswith("create table customer (")
       and six[3].startswith("create table pause (") and six[4] == "create index pause_customer_id_idx on pause (customer_id)"
       and six[5].startswith("alter table if exists pause add constraint FK") and six[5].endswith(" foreign key (customer_id) references customer"),
       "u35dmem: the six at start - two drops, two create table, the index, the foreign key")
    ok(two == ["drop table if exists customer cascade", "drop table if exists pause cascade"], "u35dmem: the two after closing: the drops")
    VALS.append("Boot's default (no key), hibernate.hbm2ddl.auto off the EMF: PostgreSQL null, H2 over TCP null, jdbc:h2:mem: create-drop; SQL lines 0, 0 and %d at start (%s) + %d after closing (%s); PostgreSQL and H2 over TCP: %s unchanged"
                % (r["sqlb"], "; ".join(six[:2] + [six[2][:20] + "…", six[3][:17] + "…", six[4], "the foreign key"]), r["sqla"], "; ".join(two), rows(R["u35dpg"]["after"])))

# ---- values -----------------------------------------------------------------------------------------------------------------
elif MODE == "values":
    R, O = runs(lines(sys.argv[2]))
    want = ["u35v%s%s" % (v, d) for d in ("pg", "h2") for v in ("create", "createdrop", "update", "validate")]
    ok(O == want, "values: eight runs, PostgreSQL then H2 over TCP")
    parts = []
    for d, name in (("pg", "PostgreSQL"), ("h2", "H2")):
        r = R["u35vcreate" + d]; sq, gw = common("u35vcreate" + d, r)
        ok(emf(r) == "create" and r["exit"] == 0, "create %s: the EMF says create, exit 0" % name)
        ok(rows(r["before"]) == "rows customer 4 · pause 2" and rows(r["after"]) == "rows customer 0 · pause 0", "create %s: rows by the second connection %s -> %s" % (name, rows(r["before"]), rows(r["after"])))
        b, a = colmap(r["before"]), colmap(r["after"])
        ok(b["version"] == "bigint not null default 0" and a["version"] == "bigint not null", "create %s: version - %s -> %s (the default 0 gone)" % (name, b["version"], a["version"]))
        ok(list(b) == ["id", "name", "meals_per_day", "price_per_meal", "meal_type", "version"], "create %s: Database's column order: %s" % (name, ", ".join(b)))
        ok(list(a) != list(b) and set(a) == set(b), "create %s: Hibernate's column order: %s" % (name, ", ".join(a)))
        fkb = [x.split()[2] for x in cat(r["before"], "constraint pause ") if "FOREIGN KEY" in x]
        fka = [x.split()[2] for x in cat(r["after"], "constraint pause ") if "FOREIGN KEY" in x]
        ok(len(fkb) == 1 and len(fka) == 1 and fkb != fka and fka[0].lower().startswith("fk"), "create %s: the foreign key renamed %s -> %s" % (name, fkb[0], fka[0]))
        if d == "pg":
            chk = [x for x in cat(r["after"], "constraint customer customer_meal_type_check CHECK ")]
            ok(len(chk) == 1 and not cat(r["before"], "constraint customer customer_meal_type_check"), "create PostgreSQL: a CHECK added - customer_meal_type_check")
            ok(a["meal_type"] == "character varying(10) not null", "create PostgreSQL: meal_type %s" % a["meal_type"])
            extra = "meal_type %s + the CHECK customer_meal_type_check" % a["meal_type"]
        else:
            ok(b["meal_type"] == "character varying(10) not null" and a["meal_type"] == "enum not null", "create H2: meal_type %s -> %s" % (b["meal_type"], a["meal_type"]))
            extra = "meal_type %s -> %s" % (b["meal_type"], a["meal_type"])
        ncreate = r["sqlb"]
        r2 = R["u35vcreatedrop" + d]; common("u35vcreatedrop" + d, r2)
        ok(emf(r2) == "create-drop" and r2["exit"] == 0 and rows(r2["before"]) == "rows customer 4 · pause 2", "create-drop %s: the EMF says create-drop, the seeded rows before" % name)
        ok(r2["after"][:1] == ["tables: (none)"] and "rows: (no table)" in r2["after"], "create-drop %s: after the JVM - tables: (none)" % name)
        ok(r2["sqla"] >= 2, "create-drop %s: %d SQL lines after closing (the drops)" % (name, r2["sqla"]))
        for v in ("update", "validate"):
            r3 = R["u35v%s%s" % (v, d)]; sq3, gw3 = common("u35v%s%s" % (v, d), r3)
            ok(emf(r3) == v and r3["exit"] == 0 and r3["sqlb"] == 0 and r3["sqla"] == 0 and not gw3, "%s %s with the anchor's own mapping: 0 SQL lines, exit 0" % (v, name))
            ok(r3["before"] == r3["after"], "%s %s: the catalogue and the rows unchanged (%s)" % (v, name, rows(r3["after"])))
        parts.append("%s: create - %d SQL lines, rows %s -> %s, version %s -> %s, %s, the foreign key %s -> %s, the columns in Hibernate's order (%s); create-drop - after the JVM tables: (none); update and validate with the anchor's own mapping - 0 SQL lines, catalogue and rows unchanged, exit 0"
                     % (name, ncreate, rows(r["before"]).replace("rows ", ""), rows(r["after"]).replace("rows ", ""), b["version"], a["version"], extra, fkb[0], fka[0], ", ".join(a)))
    VALS.append(" · ".join(parts) + " - S2 ⓘ3 closed: validate passes on both")

# ---- changes and table --------------------------------------------------------------------------------------------------------
elif MODE in ("changes", "table"):
    L = lines(sys.argv[2])
    R, O = runs(L)
    V = [("rename", "u35rename%su", "u35rename%sv"), ("rename2", "u35renametwo%su", None), ("len40", "u35len%su", "u35len%sv"),
         ("len40, an over-long name in the table", "u35lenlong%su", None), ("drop", "u35drop%su", "u35drop%sv"), ("type", "u35type%su", "u35type%sv")]
    want = []
    for d in ("pg", "h2"):
        want += ["u35rename%su" % d, "u35rename%sv" % d, "u35renametwo%su" % d, "u35len%su" % d, "u35lenlong%su" % d, "u35len%sv" % d,
                 "u35drop%su" % d, "u35drop%sv" % d, "u35type%su" % d, "u35type%sv" % d]
    ok(O == want, "changes: twenty runs, PostgreSQL then H2 over TCP")
    CH = {"rename": "int mealsADay (column mealsaday)", "rename2": "Integer mealsDaily (column meals_daily)", "len40": "@Column(length = 40) on name",
          "len40, an over-long name in the table": "the same, a name longer than the new length in the table", "drop": "pricePerMeal removed", "type": "mealsPerDay as a String"}
    cells = []; facts = {}
    for d, name in (("pg", "PostgreSQL"), ("h2", "H2")):
        for v, ul, vl in V:
            r = R[ul % d]; sq, gw = common(ul % d, r)
            ok(emf(r) == "update", "%s %s: the EMF says update" % (v, name))
            st = stmts(sq); b, a = colmap(r["before"]), colmap(r["after"])
            if v == "rename":
                ok(st == ["alter table if exists customer add column mealsaday integer not null"], "rename %s: update ran %s" % (name, st))
                txt = 'ERROR: column "mealsaday" of relation "customer" contains null values' if d == "pg" else 'NULL not allowed for column "MEALSADAY";'
                ok(len(gw) == 1 and gw[0].endswith("via JDBC [%s]" % txt), "rename %s: the database refused it - the WARN: …[%s]" % (name, txt))
                ok(r["exit"] == 0 and r["before"] == r["after"], "rename %s: ready: yes, exit 0 - the start went on, the catalogue unchanged (R.315's damage)" % name)
                start = "refused by the database (WARN: %s), ready: yes, exit 0" % txt; catl = "unchanged - no mealsaday column"
                facts["warn" + d] = gw[0].split(" : ", 1)[1]
            elif v == "rename2":
                ok(st == ["alter table if exists customer add column meals_daily integer"], "rename2 %s: update ran %s" % (name, st))
                ok(r["exit"] == 0 and not gw and a.get("meals_daily") == "integer" and "meals_per_day" in a, "rename2 %s: meals_daily added, meals_per_day kept" % name)
                mp = cat(r["after"], "meals_per_day: "); md = cat(r["after"], "meals_daily: ")
                n = int(re.search(r"rows customer (\d+)", rows(r["after"])).group(1))
                ok(mp == cat(r["before"], "meals_per_day: ") and md == ["meals_daily: " + " ".join(["null"] * n)], "rename2 %s: %s kept, %s" % (name, mp[0], md[0]))
                start = "applied, ready: yes, exit 0"; catl = "meals_daily integer added (%s); meals_per_day kept (%s)" % (md[0].split(": ")[1], mp[0].split(": ")[1])
            elif v == "len40":
                ok(st == ["alter table if exists customer alter column name set data type varchar(40)"], "len40 %s: update ran %s" % (name, st))
                ok(r["exit"] == 0 and not gw and b["name"] == "character varying(60) not null" and a["name"] == "character varying(40) not null",
                   "len40 %s: the column narrowed - name %s -> %s" % (name, b["name"], a["name"]))
                ok(rows(r["after"]) == rows(r["before"]), "len40 %s: rows %s" % (name, rows(r["after"])))
                start = "applied, ready: yes, exit 0"; catl = "name %s -> %s" % (b["name"].replace(" not null", ""), a["name"].replace(" not null", ""))
                facts["B" + d] = (st[0], b["name"], a["name"])
            elif v.startswith("len40, "):
                ok(st == ["alter table if exists customer alter column name set data type varchar(40)"], "len40 + the over-long name %s: update ran the same statement" % name)
                nm = [x for x in r["pre"] if x.startswith("  the over-long name")]; ln = [x for x in r["pre"] if x.startswith("  length:")]
                ok(len(nm) == 1 and len(ln) == 1, "len40 + the over-long name %s: the name and its printed length" % name)
                s = nm[0].split(": ", 1)[1]; m = re.match(r"^  length: (\d+) characters \(\$\{#LONG\}\)$", ln[0])
                ok(m is not None and int(m.group(1)) == len(s), "len40 + the over-long name %s: the printed length (%s) = the name's own length (%d) - R.302" % (name, m.group(1) if m else "?", len(s)))
                lim = int(re.search(r"varchar\((\d+)\)$", st[0]).group(1))
                ok(len(s) > lim, "len40 + the over-long name %s: longer than the new length (%d > %d, both read off the run)" % (name, len(s), lim))
                ok(("customers: " in "".join(r["after"])) and any(x.startswith("customers: ") and s in x for x in r["after"]), "len40 + the over-long name %s: the name is in the table after" % name)
                txt = "ERROR: value too long for type character varying(40)" if d == "pg" else 'Value too long for column "NAME CHARACTER VARYING(40)"'
                ok(len(gw) == 1 and txt in gw[0], "len40 + the over-long name %s: refused - the WARN: …%s" % (name, txt))
                ok(r["exit"] == 0 and a["name"] == "character varying(60) not null" and r["before"] != r["after"] and colmap(r["before"]) == a,
                   "len40 + the over-long name %s: ready: yes, exit 0 - the start went on, the column stays %s" % (name, a["name"]))
                start = "refused by the database (WARN: %s), ready: yes, exit 0" % txt; catl = "name stays %s" % a["name"].replace(" not null", "")
                facts["len" + d] = (len(s), m.group(1)); facts["lwarn" + d] = txt; facts["stays"] = a["name"].replace(" not null", "")
            elif v == "drop":
                ok(st == [] and r["exit"] == 0 and not gw and r["before"] == r["after"], "drop %s: update ran 0 statements, the catalogue and rows unchanged" % name)
                ok(a["price_per_meal"] == "integer not null" and cat(r["after"], "price_per_meal: ") == cat(r["before"], "price_per_meal: "),
                   "drop %s: price_per_meal stays - %s, %s" % (name, a["price_per_meal"], cat(r["after"], "price_per_meal: ")[0]))
                start = "nothing to run, ready: yes, exit 0"; catl = "unchanged - price_per_meal %s, its values kept" % a["price_per_meal"]
            elif v == "type":
                ok(st == ["alter table if exists customer alter column meals_per_day set data type varchar(255)"], "type %s: update ran %s" % (name, st))
                ok(r["exit"] == 0 and not gw and b["meals_per_day"] == "integer not null" and a["meals_per_day"] == "character varying(255) not null",
                   "type %s: the column retyped - meals_per_day %s -> %s" % (name, b["meals_per_day"], a["meals_per_day"]))
                start = "applied, ready: yes, exit 0"; catl = "meals_per_day %s -> %s" % (b["meals_per_day"].replace(" not null", ""), a["meals_per_day"].replace(" not null", ""))
            upd = st[0] if st else "0 statements"
            if vl:
                rv = R[vl % d]; sqv, gwv = common(vl % d, rv)
                ok(emf(rv) == "validate" or rv["exit"] == 1, "%s %s: validate" % (v, name))
                ok(rv["sqlb"] == 0 and rv["sqla"] == 0 and not gwv and rv["before"] == rv["after"], "%s %s: validate wrote nothing - 0 SQL lines, the catalogue unchanged" % (v, name))
                causes = [x for x in rv["jvm"] if x.startswith("PROBE cause: ")]
                if v == "rename":
                    msg = "Schema validation: missing column [mealsaday] in table [customer]"
                    ok(rv["exit"] == 1 and causes and causes[-1] == "PROBE cause: org.hibernate.tool.schema.spi.SchemaManagementException: " + msg, "rename %s: validate refused - %s, exit 1" % (name, msg))
                    vv = "refused, exit 1: " + msg
                    if d == "pg":
                        ch = [c.split(": ")[1] for c in causes]
                        ok(ch == ["org.springframework.beans.factory.BeanCreationException", "jakarta.persistence.PersistenceException", "org.hibernate.tool.schema.spi.SchemaManagementException"],
                           "the chain: " + " <- ".join(ch))
                        chain = [x for x in L if " <- " in x and x.startswith("  org.")]
                        ok(chain == ["  " + " <- ".join(ch)], "the capture's chain line = the three PROBE cause lines")
                        facts["chain"] = " <- ".join(ch)
                elif v == "type":
                    f = "int4" if d == "pg" else "integer"
                    msg = "Schema validation: wrong column type encountered in column [meals_per_day] in table [customer]; found [%s (Types#INTEGER)], but expecting [varchar(255) (Types#VARCHAR)]" % f
                    ok(rv["exit"] == 1 and causes and causes[-1] == "PROBE cause: org.hibernate.tool.schema.spi.SchemaManagementException: " + msg, "type %s: validate refused - …found [%s (Types#INTEGER)]…, exit 1" % (name, f))
                    vv = "refused, exit 1: " + msg; facts["Ap" + d] = msg
                else:
                    ok(rv["exit"] == 0 and emf(rv) == "validate" and not causes, "%s %s: validate passes, exit 0%s" % (v, name, " - it checks no length (R.316)" if v == "len40" else ""))
                    vv = "passes, exit 0"
                    if v == "len40": facts["A" + d] = vv
            else:
                vv = "not run - a missing column, as rename's" if v == "rename2" else "not run - as len40's (no length checked)"
            cells.append([v, name, CH[v], upd, start, catl, vv])
    fr = [x for x in L if x.startswith("  B  ") or x.startswith("  A  ") or x.startswith("  A' ")]
    ok(len(fr) == 3, "the failure receipt: three labelled lines, B, A, A'")
    ok(fr[0] == "  B  len40 · update:   %s · exit 0" % facts["Bpg"][0], "B: len40 update narrowed the column - " + facts["Bpg"][0])
    ok(fr[1] == "  A  len40 · validate: PROBE ready: yes · exit 0 · SQL lines 0", "A: len40 validate passed the same entity - it checks no length")
    ok(fr[2] == "  A' type · validate:  PROBE ready: no · exit 1 · " + facts["Appg"].split(";")[0], "A': type validate refused the type change")
    if MODE == "changes":
        for c in cells: print("cell | " + " | ".join(c))
        VALS.append(("the four changes, update then validate, both databases - rename: update ran alter table if exists customer add column mealsaday integer not null, refused (PostgreSQL %s; H2 %s), ready: yes, exit 0, the catalogue unchanged; validate %s, exit 1; "
                     "rename2: add column meals_daily integer applied, meals_per_day kept with its values; len40: %s, the column narrowed %s -> %s (B), validate passes, exit 0 (A: it checks no length); "
                     "with a name of %s characters (its printed length) in the table: the same statement refused (%s / %s), ready: yes, exit 0, the column stays %s; drop: 0 statements, price_per_meal stays; "
                     "type: alter column meals_per_day set data type varchar(255), the column retyped; validate (A') %s (H2: found [integer (Types#INTEGER)]), exit 1; the chain %s")
                    % ('[ERROR: column "mealsaday" of relation "customer" contains null values]', '[NULL not allowed for column "MEALSADAY";]', "Schema validation: missing column [mealsaday] in table [customer]",
                       facts["Bpg"][0], facts["Bpg"][1].replace(" not null", ""), facts["Bpg"][2].replace(" not null", ""), facts["lenpg"][1], facts["lwarnpg"], facts["lwarnh2"], facts["stays"],
                       facts["Appg"], facts["chain"]))
        VALS.append("the WARN: " + facts["warnpg"])
    else:
        R2 = lines(sys.argv[3])
        a = [i for i, l in enumerate(R2) if l == "<!-- changes table: begin -->"]; b = [i for i, l in enumerate(R2) if l == "<!-- changes table: end -->"]
        ok(len(a) == 1 and len(b) == 1 and a[0] < b[0], "README.md holds one changes table between its markers")
        esc = lambda x: x.replace("|", "\\|")
        built = ["| the change | database | the entity | `update` ran (the SQL logger) | the start | the catalogue after (the second connection) | `validate` |", "|---|---|---|---|---|---|---|"]
        built += ["| %s |" % " | ".join(esc(x) for x in c) for c in cells]
        have = R2[a[0] + 1:b[0]]
        for i, (x, y) in enumerate(zip(built, have)):
            ok(x == y, "the table's line %d is the one the cell lines build%s" % (i + 1, "" if x == y else " - README: " + y[:90] + " · built: " + x[:90]))
        ok(len(built) == len(have), "README.md's changes table = the %d cell lines, cell for cell (R.261: never typed)" % len(cells))

# ---- xcheck -----------------------------------------------------------------------------------------------------------------
elif MODE == "xcheck":
    L = lines(sys.argv[2]); x34, filed = sys.argv[3], sys.argv[4]
    m = [l for l in L if l.startswith("  the anchor's md5: ")]
    ok(len(m) == 1, "xcheck: the md5 line")
    h = re.match(r"^  the anchor's md5: ([0-9a-f]{32}) · the filed xcheck.sql: ([0-9a-f]{32}) · cmp: the same, byte for byte · the index lesson's xcheck.sql: ([0-9a-f]{32}) · diff: 0 lines$", m[0])
    ok(h is not None and h.group(1) == h.group(2) == h.group(3) == x34 == filed, "xcheck: Hibernate's script over the anchor = xcheck.sql = the index lesson's, byte for byte, diff 0 lines")
    ok("  exit 0 · HHH000001: 1" in L, "xcheck: exit 0, HHH000001 once")
    VALS.append("Hibernate's script over the anchor's libraries %s = the index lesson's xcheck.sql, byte for byte (diff 0 lines)" % h.group(1))

# ---- exercise and wib -----------------------------------------------------------------------------------------------------------
elif MODE in ("exercise", "wib"):
    L = lines(sys.argv[2])
    def printed(sh, which):
        a = [i for i, l in enumerate(L) if l.startswith("in %s (" % sh)][0]
        if which == "readme":
            s = [i for i in range(a, len(L)) if L[i].startswith("  the block's exit ")][0]; e = [i for i in range(s, len(L)) if L[i].startswith("  the shell is now in:")][0]
        else:
            s = [i for i in range(a, len(L)) if L[i].startswith("  then the solution's lines")][0]; e = [i for i in range(s, len(L)) if L[i].startswith("  the shell is now in:")][0]
        return [l[4:] for l in L[s + 1:e]]
    if MODE == "wib":
        print("\n".join(printed("bash", "readme" if sys.argv[3].endswith("README.md") else "sol"))); sys.exit(0)
    bb, bs, zb, zs = printed("bash", "readme"), printed("bash", "sol"), printed("zsh", "readme"), printed("zsh", "sol")
    ok(bb == zb and bs == zs, "exercise: bash and zsh print the same, both blocks")
    ok(bb[0] == "the JVM: exit 0" and "SQL : alter table if exists diner alter column meals_per_day set data type varchar(255)" in bb
       and bb[-1] == "PROBE after the start: diner.meals_per_day character varying(255)" and "PROBE before the start: diner.meals_per_day integer" in bb,
       "exercise, broken: update retyped the integer column - alter column … set data type varchar(255), exit 0")
    msg = "PROBE refused: SchemaManagementException: Schema validation: wrong column type encountered in column [meals_per_day] in table [diner]; found [integer (Types#INTEGER)], but expecting [varchar(255) (Types#VARCHAR)]"
    ok(bs[0] == "the JVM: exit 1" and msg in bs and bs[-1] == "PROBE after the start: diner.meals_per_day integer" and not any(x.startswith("SQL : ") for x in bs),
       "exercise, solved: validate refused the start - found [integer (Types#INTEGER)], exit 1, the column unchanged, 0 SQL lines")
    md = [re.search(r"(broken|solved)'s md5 \(what it printed\): ([0-9a-f]{32})", l) for l in L]
    md = [m.group(2) for m in md if m]
    ok(len(md) == 4 and md[0] == md[2] and md[1] == md[3] and md[0] != md[1], "exercise: broken ≠ solved (md5), the same in both shells (R.196)")
    VALS.append("one JVM, H2 in memory, a diner table of its own: update - alter table if exists diner alter column meals_per_day set data type varchar(255), integer -> character varying(255), exit 0; the solution validate - wrong column type … found [integer (Types#INTEGER)], exit 1, the column still integer (%s words)" % sys.argv[3])
else:
    print("FAIL unknown mode " + MODE); sys.exit(1)
print("VALUES " + " · ".join(VALS))
