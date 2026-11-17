# c8-unit06 — JPA vs JDBC vs Plain SQL

Course 8, Section 1 (Spring Data JDBC), unit 06 — **a harness unit: no anchor change.** TiffinBox's dashboard page read three ways —
Spring Data JPA (the anchor's own `Dashboard.load()`), Spring Data JDBC (unit 02's `CustomerAggregates`, driven by a harness class),
plain SQL through `JdbcClient` (a harness class with four SQL strings) — counted by ONE statement witness and ONE line counter, on
PostgreSQL 18.6 in a container (the hook's store) and again on H2 in memory, the anchor's default. No time is measured anywhere in
this unit: what it counts is statements, rows and lines (contract §4.3).

- `anchor` → `../c8-unit02/after` (a link; both Spring Data modules, `JdbcNames`'s Q imported; `../c8-tiffinbox` equals it today,
  `diff -rq` empty, printed by every run). `harness/tree06.py` pins its tree: the file count and the md5 in `receipts.md5`'s
  `anchor-tree` line, written from a run's own output (the pin units 01, 03, 04 and 05 filed: the anchor has not moved).
- Nothing in the anchor is edited and no second JPA entity set exists (RED #10): the JPA side is the anchor's `Dashboard`,
  `CustomerRepository` and `CustomerEntityRepository`; the JDBC side is `CustomerAggregates` read by `harness/src/probe/u06/JdbcDashboard.java`;
  the plain-SQL side is `harness/src/probe/u06/PlainSql.java`. All three return the anchor's `Dashboard.View`, so the three answers are
  compared as one record. The tree is copied under `.harness/` and built there, offline, from `.m2-demo` (a copy of the course's seed
  `spring-data-beyond-jpa/_research/m2-seed-c8-s1/`). The exercise's copy — the anchor with one line added to `JdbcNames`,
  `setSingleQueryLoadingEnabled(true)` — is derived under `.harness/sq/` by the receipt and never committed as a tree.

Run it: `./receipts.sh` from this folder (JDK 25, Maven, OrbStack's docker socket, the postgres image by its digest already on the
machine — the script never pulls). Every number below is a line a run printed; the values block is assembled from `harness/chk06.py`'s
output and compared with this file byte for byte.

## The captures — what each one shows

Seven captures, each run 3/3 and hashed (`receipts.md5`); each is read back by `harness/chk06.py` against a second witness of the
same run, ahead of its hash's comparison. The statement witness is datasource-proxy 1.11.1 wrapped around the `DataSource` bean by a
`BeanPostProcessor` — unit 02's `Witness` with its result sets proxied too, so it also counts every `ResultSet.next()` that returned a
row while a window is open (the rows the driver handed over), and with the plant's switch `-Du06.unwired=true` (R.357; the receipt
asserts every other line of unit 02's class is kept). It is on the harness's class path only — never in the anchor. Every count is
the witness's, per labelled window (R.357, R.367); on the JPA side Hibernate's `getPrepareStatementCount()` from the same window is
printed beside it and asserted equal (C8-9, S8.15). Each sequence builds the data line first (V2's rows, then customers by
`JdbcTemplate` with one 2-day pause each — RE-MEASURE 4), on a fresh database per PostgreSQL sequence; psql in the container reads
the data line back as a second client.

### 1 · witness — one witness, the JPA side's two counters (PostgreSQL 18.6; the same on H2)

The `DataSource` bean every side reaches the database through is the witness's `ProxyDataSource`, named `witness`, around Boot's
`HikariDataSource` — unit 05's `beans` capture printed the same wrapper. Its version comes from the jar's `pom.properties`: the
jar's manifest carries no `Implementation-Version` (printed as `null`), so the brief's "from the jar's manifest" could not be kept.
Then the anchor's page in one window, the witness's count beside Hibernate's prepare count:

```text
PROBE data (PostgreSQL 18.6, JdbcTemplate): customers 40 · pauses 38 · paused days 77
  psql (a second client, PostgreSQL): 40 customers · 38 pauses · 77 paused days
PROBE the DataSource bean (PostgreSQL 18.6): net.ttddyy.dsproxy.support.ProxyDataSource named 'witness' around com.zaxxer.hikari.HikariDataSource · DataSource beans 1 · the JdbcClient bean org.springframework.jdbc.core.simple.DefaultJdbcClient
PROBE datasource-proxy's jar manifest: Implementation-Version null (the version line above is its pom.properties)
PROBE witness window (Spring Data JPA Dashboard.load(), PostgreSQL 18.6): revenue 240300 · paused days 77 · days by name 77 · customers 40
PROBE witness window (PostgreSQL 18.6): the witness 4 · Hibernate getPrepareStatementCount() 4 · equal: yes
PROBE witness window (H2 2.5.250): the witness 4 · Hibernate getPrepareStatementCount() 4 · equal: yes
```

The count the JPA side is measured by is `getPrepareStatementCount()` — the statements Hibernate prepared, the same thing the witness
counts at `Connection.prepareStatement` — never Hibernate's query-execution count (R.320). C8-10 (the ledger's optional counter sentence, byte
for byte) is skipped: this unit does not quote it.

### 2 · three — the hook: one page, three ways, three rounds (PostgreSQL 18.6; repeated on H2, labelled)

Each round runs the three sides one after the other, a witness window each. Before any count is printed the three answers are
compared — the customers, the month's revenue, the paused days and the by-name map, as one `Dashboard.View` — and the three name
orders. Round 1 on PostgreSQL:

```text
PROBE r1 answers, before any count (PostgreSQL 18.6): JPA revenue 240300 · paused days 77 · days by name 77 · customers 40 | JDBC revenue 240300 · paused days 77 · days by name 77 · customers 40 | JdbcClient revenue 240300 · paused days 77 · days by name 77 · customers 40 · the three Views' customers, sums and by-name maps equal: yes
PROBE r1 name order (PostgreSQL 18.6): JPA's list = JDBC's = JdbcClient's: yes · first Customer 01 · last Sunil
PROBE r1 JPA (Dashboard.load(), PostgreSQL 18.6): the witness 4 · rows 82 · Hibernate getPrepareStatementCount() 4 · equal: yes
PROBE r1 Spring Data JDBC (JdbcDashboard.load(), PostgreSQL 18.6): the witness 43 · rows 80 · of them SELECT from customer 1 · SELECT from pause by customer_id 40 · other 2 · Hibernate getPrepareStatementCount() 0
PROBE r1 JdbcClient (PlainSql.load(), PostgreSQL 18.6): the witness 4 · rows 82 · Hibernate getPrepareStatementCount() 0
```

Rounds 2 and 3 print the same lines (the capture holds them; `chk06.py` asserts the three rounds equal). The witness's SQL texts,
round 1, sorted and counted — the JPA side's four reads run on four virtual threads, so their SQL order varies between runs (S8.16):
counts and sorted lists only, never order:

```text
PROBE r1 JPA (PostgreSQL 18.6) SQL x1: select ce1_0.id,ce1_0.created_at,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal,ce1_0.updated_at,ce1_0.version from customer ce1_0 order by ce1_0.name
PROBE r1 JPA (PostgreSQL 18.6) SQL x1: select ce1_0.id,ce1_0.created_at,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,p1_0.customer_id,p1_0.id,p1_0.days,ce1_0.price_per_meal,ce1_0.updated_at,ce1_0.version from customer ce1_0 left join pause p1_0 on ce1_0.id=p1_0.customer_id order by ce1_0.name
PROBE r1 JPA (PostgreSQL 18.6) SQL x1: select coalesce(sum(((ce1_0.meals_per_day*ce1_0.price_per_meal)*30)),0) from customer ce1_0
PROBE r1 JPA (PostgreSQL 18.6) SQL x1: select coalesce(sum(pe1_0.days),0) from pause pe1_0
PROBE r1 Spring Data JDBC (the 40 by customer_id: one text) (PostgreSQL 18.6) SQL x1: SELECT customer.id AS id, customer.name AS name, customer.version AS version, customer.meal_type AS meal_type, customer.meals_per_day AS meals_per_day, customer.price_per_meal AS price_per_meal FROM customer ORDER BY customer.name ASC
PROBE r1 Spring Data JDBC (the 40 by customer_id: one text) (PostgreSQL 18.6) SQL x40: SELECT pause.id AS id, pause.days AS days FROM pause WHERE pause.customer_id = ?
PROBE r1 Spring Data JDBC (the 40 by customer_id: one text) (PostgreSQL 18.6) SQL x1: select coalesce(sum(days), 0) from pause
PROBE r1 Spring Data JDBC (the 40 by customer_id: one text) (PostgreSQL 18.6) SQL x1: select coalesce(sum(meals_per_day * price_per_meal * 30), 0) from customer
PROBE r1 JdbcClient (PostgreSQL 18.6) SQL x1: select c.name, coalesce(sum(p.days), 0) from customer c left join pause p on p.customer_id = c.id group by c.name order by c.name
PROBE r1 JdbcClient (PostgreSQL 18.6) SQL x1: select coalesce(sum(days), 0) from pause
PROBE r1 JdbcClient (PostgreSQL 18.6) SQL x1: select coalesce(sum(meals_per_day * price_per_meal * 30), 0) from customer
PROBE r1 JdbcClient (PostgreSQL 18.6) SQL x1: select name, meals_per_day, price_per_meal, meal_type from customer order by name
```

The same rounds on H2 in memory (the same counts; the names Spring Data JDBC writes upper-cased by H2's dialect):

```text
PROBE r1 answers, before any count (H2 2.5.250): JPA revenue 240300 · paused days 77 · days by name 77 · customers 40 | JDBC revenue 240300 · paused days 77 · days by name 77 · customers 40 | JdbcClient revenue 240300 · paused days 77 · days by name 77 · customers 40 · the three Views' customers, sums and by-name maps equal: yes
PROBE r1 JPA (Dashboard.load(), H2 2.5.250): the witness 4 · rows 82 · Hibernate getPrepareStatementCount() 4 · equal: yes
PROBE r1 Spring Data JDBC (JdbcDashboard.load(), H2 2.5.250): the witness 43 · rows 80 · of them SELECT from customer 1 · SELECT from pause by customer_id 40 · other 2 · Hibernate getPrepareStatementCount() 0
PROBE r1 JdbcClient (PlainSql.load(), H2 2.5.250): the witness 4 · rows 82 · Hibernate getPrepareStatementCount() 0
PROBE r1 Spring Data JDBC (the 40 by customer_id: one text) (H2 2.5.250) SQL x1: SELECT customer.ID AS ID, customer.NAME AS NAME, customer.VERSION AS VERSION, customer.MEAL_TYPE AS MEAL_TYPE, customer.MEALS_PER_DAY AS MEALS_PER_DAY, customer.PRICE_PER_MEAL AS PRICE_PER_MEAL FROM customer ORDER BY customer.NAME ASC
```

What each side is: the JPA side is the anchor's `Dashboard.load()`, the anchor's four reads joined in one block — the customers through
`CustomerRepository.findAll()`, the revenue and paused-days JPQL sums, and the by-name map through the entity-graph method
`findAllByOrderByNameAsc()`, the pauses joined in. The Spring Data JDBC side is the repository's `findAll(Sort.by("name"))` — one
SELECT for the customers and then one SELECT per customer for her pauses, Spring Data JDBC's default loading of a collection — plus
its two `@Query` sums, each customer's days summed from her aggregate. The plain-SQL side is four strings through the context's
`JdbcClient`, the by-name map one left join. The rows column is the witness's `ResultSet.next()` count; `chk06.py` derives the JDBC
side's rows from the data line (the customers, the pauses, one row per sum) and the plain side's (the customers, one by-name row per
customer, one row per sum).

**`Sort.by("name")` — C8-6, ⚑10, RED #5.** The Spring Data JDBC side reads the page with `findAll(Sort.by("name"))`, the paging API's
`Sort` from Course 7's *Paging and Sorting*, on Spring Data JDBC 4.1.2; its `ORDER BY` at the driver is in the SQL list above —
`ORDER BY customer.name ASC` on PostgreSQL, `ORDER BY customer.NAME ASC` on H2 (Q's unquoted names, the dialect's case). The plain
SQL writes `order by name` in its string. The JPA side reaches the same order two ways, each printed as what it is: the anchor's
`CustomerRepository.findAll()` calls Spring Data JPA's own `findAll(Sort.by("name"))` (code the anchor already had, not this unit's), and the
by-name read is the derived `findAllByOrderByNameAsc()`; both arrive as `order by ce1_0.name`. C8-6 is paid by the Spring Data JDBC
side's call alone. The three name orders are asserted equal on both databases: the data line's names are ASCII (`Customer 01` …
`Sunil`), and that equality is the check — no claim about collations is made.

### 3 · lines — one counter over each side's own files (S8.18, RE-MEASURE 13)

`harness/loc.py` counts two columns for every file: its lines (the newline count, asserted equal to `wc -l` in the same capture) and
its code lines (not blank, not wholly comment — a `//` line, a Javadoc or block comment line). Its self-test passes on a fixture
with a Javadoc block, a block comment, a line comment, a trailing comment and a block that ends ahead of code, or nothing is counted. One template for all
three sides: the same counter, the same comment policy. **The anchor's JPA files carry Course 7's teaching Javadoc**, so their
lines column is mostly comment; the code-line column is the like-for-like one, and no commented anchor file is set beside a bare
sketch. The JPA side is the anchor's five files the page runs through; the JDBC side is unit 02's three files plus the harness's
`JdbcDashboard` (the page's assembly, as `Dashboard` is the JPA side's), with `JdbcNames` — the quoting fix every Spring Data JDBC
context here imports — counted and labelled on its own; the plain-SQL side is the harness's `PlainSql`. `Customer.java`, the record
the JPA and plain sides map into (and the JDBC side builds), is counted and labelled shared, in no side's total.

```text
loc self-test: the fixture (13 lines: a Javadoc block, a block comment, a line comment, a trailing comment, a block that ends before code, 2 blank) -> lines 13 · code 5 · ok
lines JPA: anchor/tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntity.java · lines 168 · code 84
lines JPA: anchor/tiffinbox-core/src/main/java/com/tiffinbox/PauseEntity.java · lines 64 · code 36
lines JPA: anchor/tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntityRepository.java · lines 62 · code 18
lines JPA: anchor/tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java · lines 121 · code 56
lines JPA: anchor/tiffinbox-core/src/main/java/com/tiffinbox/Dashboard.java · lines 69 · code 37
lines JDBC: anchor/tiffinbox-core/src/main/java/com/tiffinbox/jdbc/CustomerRow.java · lines 88 · code 53
lines JDBC: anchor/tiffinbox-core/src/main/java/com/tiffinbox/jdbc/PauseRow.java · lines 32 · code 20
lines JDBC: anchor/tiffinbox-core/src/main/java/com/tiffinbox/jdbc/CustomerAggregates.java · lines 27 · code 12
lines JDBC: harness/src/probe/u06/JdbcDashboard.java · lines 40 · code 29
lines quoting: anchor/tiffinbox-core/src/main/java/com/tiffinbox/jdbc/JdbcNames.java · lines 33 · code 20
lines SQL: harness/src/probe/u06/PlainSql.java · lines 35 · code 24
lines shared: anchor/tiffinbox-core/src/main/java/com/tiffinbox/Customer.java · lines 33 · code 15
lines JPA total: 5 files · lines 484 · code 231
lines JDBC total: 4 files · lines 187 · code 114
lines quoting total: 1 files · lines 33 · code 20
lines SQL total: 1 files · lines 35 · code 24
lines shared total: 1 files · lines 33 · code 15
```

The probe's sketch counted `CustomerRow` and `PauseRow` before unit 02 shipped them; these are the shipped files (RE-MEASURE 13).
Each side's files also hold methods the page does not call (the anchor's keyset method and `findByName`, `CustomerAggregates.findByName`):
the counter counts files, as S8.18 says, not methods.

### 4 · compare — the decision table, every cell a `cell` line (R.261, R.338, RED #9)

The receipt prints one `cell` line per cell — row · side · value · source — built by `harness/chk06.py cells` from this run's
`three`, `lines` and `compare` logs and from earlier units' captures by hash (each hash read off that unit's `receipts.md5`, each
line read off that unit's README, the value cut out of that line — never typed). The cells this run measures first, in one
transaction on PostgreSQL (the same on H2):

```text
PROBE held after Spring Data JPA findAllByOrderByNameAsc() (PostgreSQL 18.6, one transaction): customers 40 · the witness 1 · the persistence context holds entities 78 · collections 40
PROBE held after Spring Data JDBC findAll(Sort.by("name")) (PostgreSQL 18.6, the same transaction): aggregates 40 · the witness 41 · the persistence context holds entities 78 · collections 40
PROBE held after JdbcClient PlainSql.load() (PostgreSQL 18.6, the same transaction): customers 40 · the witness 4 · the persistence context holds entities 78 · collections 40
PROBE collection save, Spring Data JPA (PostgreSQL 18.6): Sunil's pauses loaded 1 · one PauseEntity persisted and added · flush: the witness 1
PROBE collection save, Spring Data JPA (PostgreSQL 18.6) SQL x1: insert into pause (customer_id,days) values (?,?)
PROBE collection save, Spring Data JPA: Sunil's pause rows by JdbcTemplate (a second client) before 1 · after the rollback 1
PROBE missing row, Spring Data JPA findById(-1L) (PostgreSQL 18.6): Optional.empty
PROBE missing row, Spring Data JPA getReferenceById(-1L).getName() (PostgreSQL 18.6): jakarta.persistence.EntityNotFoundException: No row with the given identifier exists for entity [com.tiffinbox.CustomerEntity with id '-1']
PROBE missing row, Spring Data JDBC findById(-1L) (PostgreSQL 18.6): Optional.empty
PROBE missing row, JdbcClient single() on Nobody (PostgreSQL 18.6): org.springframework.dao.EmptyResultDataAccessException: Incorrect result size: expected 1, actual 0
PROBE the schema's owner (PostgreSQL 18.6, the context's Flyway bean): applied V1 Success, V2 Success, V3 Success · current V3 · spring.jpa.hibernate.ddl-auto validate
```

JPA's flush of one added pause runs inside a transaction that is then rolled back; Sunil's pause rows read by `JdbcTemplate` before
and after are the same. The table:

```text
cell statements for the page · Spring Data JPA · 4 · three (PostgreSQL 18.6, r1-r3; H2 the same)
cell statements for the page · Spring Data JDBC · 43 · three (PostgreSQL 18.6, r1-r3; H2 the same)
cell statements for the page · JdbcClient · 4 · three (PostgreSQL 18.6, r1-r3; H2 the same)
cell rows the driver handed over · Spring Data JPA · 82 · three (PostgreSQL 18.6, the witness's ResultSet.next() count)
cell rows the driver handed over · Spring Data JDBC · 80 · three (PostgreSQL 18.6, the witness's ResultSet.next() count)
cell rows the driver handed over · JdbcClient · 82 · three (PostgreSQL 18.6, the witness's ResultSet.next() count)
cell entities the persistence context holds after the read · Spring Data JPA · 78 entities · 40 collections · compare (PostgreSQL 18.6, one transaction)
cell entities the persistence context holds after the read · Spring Data JDBC · none added (78 -> 78) · compare (PostgreSQL 18.6, the same transaction)
cell entities the persistence context holds after the read · JdbcClient · none added (78 -> 78) · compare (PostgreSQL 18.6, the same transaction)
cell load, change, no save, commit · Spring Data JPA · the flush writes `update customer set meal_type=?,meals_per_day=?,name=?,price_per_meal=?,updated_at=?,version=? where id=? and version=?` · c8-unit02 dirty 0ba7a180 (its README: window A's SQL line)
cell load, change, no save, commit · Spring Data JDBC · 2 statements, no UPDATE; psql after it: meals 2 · version 0 · c8-unit02 dirty 0ba7a180 (its README: window B's lines)
cell the pauses read after the call, no transaction · Spring Data JPA · org.hibernate.LazyInitializationException: Cannot lazily initialize collection of role 'com.tiffinbox.CustomerEntity.pauses' with key '3' (no session) · c8-unit02 lazy dad7ad17 (its README)
cell the pauses read after the call, no transaction · Spring Data JDBC · getPauses() -> 1 · java.util.LinkedHashSet · c8-unit02 lazy dad7ad17 (its README)
cell code lines for the page (lines) · Spring Data JPA · 231 (484) · lines (harness/loc.py, 5 files)
cell code lines for the page (lines) · Spring Data JDBC · 114 (187) (+ JdbcNames, the quoting fix: 33 lines · 20 code) · lines (harness/loc.py, 4 files)
cell code lines for the page (lines) · JdbcClient · 24 (35) · lines (harness/loc.py, 1 files)
cell the schema's owner · Spring Data JPA · Flyway: applied V1 Success, V2 Success, V3 Success · current V3 (ddl-auto validate) · compare (PostgreSQL 18.6, one JVM serves the three sides)
cell the schema's owner · Spring Data JDBC · Flyway: applied V1 Success, V2 Success, V3 Success · current V3 (ddl-auto validate) · compare (PostgreSQL 18.6, one JVM serves the three sides)
cell the schema's owner · JdbcClient · Flyway: applied V1 Success, V2 Success, V3 Success · current V3 (ddl-auto validate) · compare (PostgreSQL 18.6, one JVM serves the three sides)
cell the version column, one row · Spring Data JPA · version 0 -> 1 (the flush, no save) · c8-unit02 dirty 0ba7a180 (its README: psql after A)
cell the version column, one row · Spring Data JDBC · version 1 -> 2 (save) · c8-unit02 dirty 0ba7a180 (its README: psql after A')
cell a missing row · Spring Data JPA · findById -> Optional.empty; getReferenceById(...).getName() -> jakarta.persistence.EntityNotFoundException: No row with the given identifier exists for entity [com.tiffinbox.CustomerEntity with id '-1'] · compare (PostgreSQL 18.6)
cell a missing row · Spring Data JDBC · findById -> Optional.empty · compare (PostgreSQL 18.6)
cell a missing row · JdbcClient · single() -> org.springframework.dao.EmptyResultDataAccessException: Incorrect result size: expected 1, actual 0 · compare (PostgreSQL 18.6)
cell one pause added to a customer's collection, saved · Spring Data JPA · the flush: 1 statement, `insert into pause (customer_id,days) values (?,?)` (rolled back) · compare (PostgreSQL 18.6)
cell one pause added to a customer's collection, saved · Spring Data JDBC · save(): 4 statements - UPDATE 1 · DELETE 1 · INSERT with id 1 · INSERT without id 1 · c8-unit03 reinsert 36ce2916 (its README)
cell the name order (PostgreSQL 18.6) · Spring Data JPA · `order by ce1_0.name` (JpaRepository findAll(Sort.by("name")) through CustomerRepository.findAll(), and the derived findAllByOrderByNameAsc()) · three (r1's SQL list)
cell the name order (PostgreSQL 18.6) · Spring Data JDBC · `ORDER BY customer.name ASC` (findAll(Sort.by("name"))) · three (r1's SQL list)
cell the name order (PostgreSQL 18.6) · JdbcClient · `order by name` (written in the SQL string) · three (r1's SQL list)
dropped load, change, no save, commit · JdbcClient · not measured (no unit's run changes a JdbcClient record)
dropped the pauses read after the call, no transaction · JdbcClient · not measured
dropped the version column, one row · JdbcClient · not measured
dropped one pause added to a customer's collection, saved · JdbcClient · not measured
dropped a test slice per side · all three · not measured here (unit 07 measures the Spring Data JDBC slice)
dropped auditing per side · all three · not measured here (unit 02's RE-MEASURE 3 ran on a copy - not a cell)
the table: 11 rows · 29 cells kept · 4 cells dropped (one per row named above) · 2 rows dropped (a test slice, auditing)
```

No adjective in any cell (`chk06.py` refuses one); the dropped cells are named with why — a cell no run prints is not in the table.
JPA's missing-row cell is measured here (both `findById` and `getReferenceById`), as the brief allowed only if measured; the
plain-SQL cell matches units 04 and 05's text (`c4d016a7`, `ae46e85c`). The JPA side's collection save is measured here; the
Spring Data JDBC side's is unit 03's `reinsert` by hash.

### 5 · plant — the failure receipt (PostgreSQL 18.6)

Two planted faults, each its own JVM, each exit 1. The JDBC page's count asserted equal to the count a reader would assume from the
other two sides; and the witness unwired — the same window as capture `witness`, with `-Du06.unwired=true` so the witness skips
`prepareStatement` — which S8.15's guard catches against Hibernate's count:

```text
PROBE plant43 (Spring Data JDBC JdbcDashboard.load(), PostgreSQL 18.6): the witness 43 · asserted == 4
PROBE a step threw: java.lang.AssertionError: expected: 4 but was: 43
PROBE witness window (PostgreSQL 18.6): the witness 0 · Hibernate getPrepareStatementCount() 4 · equal: NO
PROBE S8.15: the witness and getPrepareStatementCount() disagree on the JPA window
```

### 6 · seven — the comparison set, unchanged (RE-MEASURE 16)

anchor/'s jar, `java -jar`, H2 in memory, port 20450 — the only web server this unit starts — and `../c5-unit11/curlset.sh`:

```text
  exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20450 now: 0
```

That md5 is `S466` in `../c7-unit31/receipts.sh`, read by the receipt, never typed.

### 7 · exercise — run as written, in one shell, bash then zsh (R.196; RED #2, BLUE #2, RE-MEASURE 14)

`exercise/README.md`'s block, then `exercise/SOLUTION.md`'s, in one `env -i` shell; each block starts its own container
(`c8u06-ex`, `127.0.0.1:20452`, `--pull never`, `rm -fv`) and then runs on H2. The copy it compiles with is the anchor with
`setSingleQueryLoadingEnabled(true)` added to `JdbcNames` (the receipt prints the one-line diff); the anchor keeps the default. What the
solution's run printed:

```text
    EX PostgreSQL 18.6: data 40 customers · 38 pauses · single-query loading true
    EX PostgreSQL 18.6: statements 43 · revenue 240300 · paused days 77 · days by name 77 · name order = the JPA side's list: yes
    EX PostgreSQL 18.6: done no - the page still sends one SELECT per customer for her pauses
    EX H2 2.5.250: data 40 customers · 38 pauses · single-query loading true
    EX H2 2.5.250: statements 43 · revenue 240300 · paused days 77 · days by name 77 · name order = the JPA side's list: yes
    EX H2 2.5.250: done no - the page still sends one SELECT per customer for her pauses
    EX PostgreSQL 18.6: data 40 customers · 38 pauses · single-query loading true
    EX PostgreSQL 18.6: statements 3 · revenue 240300 · paused days 77 · days by name 77 · name order = the JPA side's list: yes
    EX PostgreSQL 18.6: done yes - three statements, the same sums, the JPA side's order
    EX H2 2.5.250: data 40 customers · 38 pauses · single-query loading true
    EX H2 2.5.250: statements 43 · revenue 240300 · paused days 77 · days by name 77 · name order = the JPA side's list: yes
    EX H2 2.5.250: done no - the page still sends one SELECT per customer for her pauses
    EX PostgreSQL 18.6: data 40 customers · 38 pauses · single-query loading true
    EX PostgreSQL 18.6: statements 43 · revenue 240300 · paused days 77 · days by name 77 · name order = the JPA side's list: yes
    EX PostgreSQL 18.6: done no - the page still sends one SELECT per customer for her pauses
    EX H2 2.5.250: data 40 customers · 38 pauses · single-query loading true
    EX H2 2.5.250: statements 43 · revenue 240300 · paused days 77 · days by name 77 · name order = the JPA side's list: yes
    EX H2 2.5.250: done no - the page still sends one SELECT per customer for her pauses
    EX PostgreSQL 18.6: data 40 customers · 38 pauses · single-query loading true
    EX PostgreSQL 18.6: statements 3 · revenue 240300 · paused days 77 · days by name 77 · name order = the JPA side's list: yes
    EX PostgreSQL 18.6: done yes - three statements, the same sums, the JPA side's order
    EX H2 2.5.250: data 40 customers · 38 pauses · single-query loading true
    EX H2 2.5.250: statements 43 · revenue 240300 · paused days 77 · days by name 77 · name order = the JPA side's list: yes
    EX H2 2.5.250: done no - the page still sends one SELECT per customer for her pauses
```

The first six `EX` lines above are the README's block (broken: `findAll(Sort.by("name"))` with the flag on), the last six the
solution's (`findAll()` sorted in Java). The check is the witness's count beside the two sums and the name order, never the exit
(R.196): every JVM exits 0. The exercise needs PostgreSQL for its target: with single-query loading on, `findAll()` reads the
customers and their pauses in one statement on PostgreSQL 18.6; `findAll(Sort.by("name"))` does not, and on H2 neither read does —
the H2 lines are measured and printed in the same block.

## The values the video may say

<!-- values: begin -->
the values the video may say - witness: the witness: datasource-proxy 1.11.1 (its version from its pom.properties; the jar's manifest Implementation-Version null), named 'witness', the DataSource bean wrapped by a BeanPostProcessor - net.ttddyy.dsproxy.support.ProxyDataSource around com.zaxxer.hikari.HikariDataSource, one DataSource bean, the JdbcClient bean org.springframework.jdbc.core.simple.DefaultJdbcClient; the JPA page Dashboard.load(): the witness 4 = Hibernate getPrepareStatementCount() 4 (PostgreSQL 18.6; H2 2.5.250 the same), revenue 240300, paused days 77 · three: the hook, the page three ways (PostgreSQL 18.6, three rounds, one witness; repeated on H2 2.5.250, the same counts): Spring Data JPA Dashboard.load() 4 statements (= Hibernate getPrepareStatementCount() 4) · rows 82; Spring Data JDBC (findAll(Sort.by("name")) + monthRevenue() + pausedDays()) 43 statements (1 customer SELECT + 40 pause SELECTs by customer_id + 2 sums) · rows 80; JdbcClient (four SQL strings) 4 statements · rows 82; the answers asserted equal first - revenue 240300, paused days 77, days by name 77, customers 40 on all three; the name order equal on all three (first Customer 01, last Sunil); the ORDER BY at the driver - Spring Data JDBC findAll(Sort.by("name")): PostgreSQL `ORDER BY customer.name ASC`, H2 `ORDER BY customer.NAME ASC`; the JPA side's two customer reads (JpaRepository findAll(Sort.by("name")) through CustomerRepository.findAll(), and the derived findAllByOrderByNameAsc()): `order by ce1_0.name`; the plain SQL: `order by name` · lines: one counter (harness/loc.py, its self-test first; lines = wc -l, code = not blank, not wholly comment): CustomerEntity.java 168 lines · 84 code; PauseEntity.java 64 lines · 36 code; CustomerEntityRepository.java 62 lines · 18 code; CustomerRepository.java 121 lines · 56 code; Dashboard.java 69 lines · 37 code; CustomerRow.java 88 lines · 53 code; PauseRow.java 32 lines · 20 code; CustomerAggregates.java 27 lines · 12 code; JdbcDashboard.java 40 lines · 29 code; JdbcNames.java 33 lines · 20 code; PlainSql.java 35 lines · 24 code; Customer.java 33 lines · 15 code - totals: JPA 5 files · 484 lines · 231 code; JDBC 4 files · 187 lines · 114 code; quoting 1 files · 33 lines · 20 code; SQL 1 files · 35 lines · 24 code; shared 1 files · 33 lines · 15 code (the anchor's JPA files carry Course 7's teaching Javadoc: the code column is the like-for-like one) · compare: the decision table: 11 rows, 29 cells, each a cell line with its source (this run's three, lines, compare; unit 02's dirty and lazy and unit 03's reinsert by hash); dropped: load, change, no save, commit (JdbcClient); the pauses read after the call, no transaction (JdbcClient); the version column, one row (JdbcClient); one pause added to a customer's collection, saved (JdbcClient); a test slice per side (all three); auditing per side (all three); measured here (PostgreSQL 18.6; H2 2.5.250 the same): after the JPA read in one transaction the persistence context holds 78 entities · 40 collections, the JDBC read and the JdbcClient page in the same transaction add none (78 -> 78 -> 78); JPA's flush of one added pause 1 statement (an insert into pause, rolled back); a missing row - JPA findById Optional.empty, getReferenceById(...).getName() jakarta.persistence.EntityNotFoundException: No row with the given identifier exists for entity [com.tiffinbox.CustomerEntity with id '-1']; Spring Data JDBC findById Optional.empty; JdbcClient single() org.springframework.dao.EmptyResultDataAccessException: Incorrect result size: expected 1, actual 0; the schema Flyway's (V1-V3, ddl-auto validate) on all three · plant: the failure receipt (PostgreSQL 18.6): the JDBC page's count asserted == 4 -> java.lang.AssertionError: expected: 4 but was: 43, exit 1; the witness unwired (-Du06.unwired=true, it skips prepareStatement) -> the witness 0 · Hibernate getPrepareStatementCount() 4 · equal: NO, exit 1 (S8.15) · seven: the seven on anchor/ (H2): 466c20ed…, unchanged · exercise: the exercise (20 words; a copy whose JdbcNames switches single-query loading on, never the anchor; its own container on 127.0.0.1:20452, then H2): broken - findAll(Sort.by("name")) + the two sums -> PostgreSQL 18.6 43 statements, H2 2.5.250 43; solved - findAll() sorted in Java + the two sums -> PostgreSQL 18.6 3 statements, H2 2.5.250 43; revenue 240300 and paused days 77 unchanged, the name order = the JPA side's list, on every run
<!-- values: end -->

## Refused, named

- A duration of any kind — no clock is read in the harness (the receipt greps it for sleeps, `nanoTime`, `currentTimeMillis`,
  `Instant.now`, `Duration`); dur8 over this README and the exercise: zero words (S8.24, contract §4.3).
- The duration, cost and quality words (dur8's list and `harness/s806.py`'s, the comparatives R.355 and R.261 name) in any sentence,
  a count beside them or not: `harness/s806.py` refuses them per sentence.
- Hibernate's query-execution count as the JPA side's number (C8-9, R.320): the receipt greps the harness for it (zero), and the
  prose gate refuses it as the count.
- Saying that `Sort.by` reads the page on all three sides is refused (RED #5): the plain SQL writes `order by name`.
- A hand-written table: every cell is a `cell` line the run printed (R.338); the receipt asserts README holds every one.
- A single-query-loading sentence without its method and its database, and the claim that the flag changes nothing (R.368, S8.26).
- The JPA side's SQL order, which varies, never compared (S8.16): counts and sorted lists.
- The commented anchor counted against a bare sketch (S8.18): one counter, both columns, the shipped files.
- `Hibernate generates` — Hibernate prepares the statements the witness counts (§10).

## Call-backs, by title (R.224)

Read off `~/Desktop/PromptVidya-Automation/java7_series.py` and `java8_series.py` (the brief says "Paging and Sorting"; the grep of
`java7_series.py` gives `"20": "Paging and Sorting"` — the same string):

- Course 7's *Paging and Sorting* — `Sort.by`, the paging API's sort the Spring Data JDBC side calls.
- *Why Another Data Module* (unit 01) — the page three ways first counted, and the persistence context's count.
- *Aggregates, Not Entities* (unit 02) — the module, Q, `CustomerAggregates`; the `dirty` and `lazy` captures the table reads.
- *Relationships Without an ORM* (unit 03) — the collection's save (`reinsert`) and single-query loading per method and database (`load`: `findAll()`, `findById`, `findAllById` on PostgreSQL and H2).
- *JdbcClient and Custom Queries* (unit 04) and *JdbcTemplate and NamedParameterJdbcTemplate* (unit 05) — `JdbcClient` and the
  missing-row text the plain-SQL cell matches.

## The commands this unit adds

- `./receipts.sh` — the seven captures, each 3/3, each checked, each compared with `receipts.md5`.
- The harness JVM: `cd .harness/run && perl -e 'alarm 240; exec @ARGV' java … -cp "../hc:<anchor's extracted jar and libraries>:$DSP"
  probe.u06.U6 <steps> [--tiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:20451/<db>?user=tiffinbox]`. Steps: `seed`, `witness`,
  `three`, `compare`, `plant43`. `$DSP` is datasource-proxy 1.11.1 in `.m2-demo` — on the harness's class path only; no harness POM.
- `python3 -I -B harness/loc.py LABEL=FILE …` — the line counter (its self-test first).
- `python3 -I -B harness/chk06.py MODE …` — the checks, and `cells`, the table's builder.

## The repository, and the network

`.m2-demo` is a copy of `spring-data-beyond-jpa/_research/m2-seed-c8-s1/` (`cp -c -R`). Every Maven run is `mvn -o` with
`-Dmaven.repo.local=.m2-demo`; each log is checked for `Downloading from` / `Downloaded from` lines (none, else the run stops). No
image pull (`--pull never`; the image list asserted unchanged), no fetch, no metadata read: nothing leaves the machine.

## The folders, the harness and the ports

- `harness/src/probe/u06/` — `U6.java` (the steps), `Witness.java` (the witness), `JdbcDashboard.java` (the JDBC side),
  `PlainSql.java` (the plain-SQL side). `harness/loc.py`, `harness/chk06.py`, `harness/s806.py` (the prose gate, its self-test
  first), `harness/dur8.py` (the builders' pattern, byte-equal to unit 02's), `harness/tree06.py`, `harness/logback.xml`.
- `.harness/` (ignored): `after/` and `sq/` (the copies), `hc/` (the compiled harness), `run/` (the harness JVM's folder and its
  token), the logs.
- Ports 20450-20459: 20450 TiffinBox for the seven only · 20451 this run's PostgreSQL container (`docker port` asserted
  `127.0.0.1:20451`) · 20452 the exercise's container · 20453-20459 never bound. The page is `Dashboard.load()` called directly in
  the harness JVM, which starts no web server. All ten free at the start and the end (`lsof`).

## Masks, filters and hygiene — every one, declared

- The folders and the home masked (`…`, `~`); Spring Boot's, Spring Data's, Flyway's, Surefire's and Maven's duration words masked
  (`<t>`, R.366; the mask's self-test refuses a planted Boot start line with its duration first); object ids `@…`.
- Each harness JVM's log is filtered to its `PROBE` lines and the strict-mode, `HHH000001` and Flyway `Database:` lines; its ERROR
  line count is printed.
- Every capture is checked for absolute paths, unmasked times, log times, stack frames, the token, and JVMs or Maven without
  their alarm.

## The ledger rows this unit pays

- **C8-9 paid** — the counter: on the JPA side the witness's count equals Hibernate's `getPrepareStatementCount()` in the same run
  (captures `witness` and `three`, both databases).
- **C8-6 paid by the Spring Data JDBC side** — `findAll(Sort.by("name"))` on Spring Data JDBC 4.1.2, its `ORDER BY` at the driver on
  PostgreSQL and H2 (capture `three`).
- **C8-10 skipped** — the ledger's counter sentence is not quoted here; named, not paid.

## RE-MEASURE — the brief's items this unit settles

- **4** — the data line built by the receipt before every count (each `seed` step, psql's line on PostgreSQL).
- **13** — the three sides' files and their line counts as shipped, one template (capture `lines`).
- **14** — single-query loading + `findAll()` on PostgreSQL measured in the exercise; `findAll(Sort)` and H2 measured beside it;
  the Java-sorted name order asserted equal to the JPA side's list.
- **16** — the seven on `anchor/`.

## What differed from the brief

- **The witness counts rows.** Unit 02's class did not; here its result sets are proxied (`proxyResultSet()`) and `ResultSet.next()`
  returning a row is counted — three lines of unit 02's class change (the package line, the builder line, the `Connection` guard
  split for the rows), every other line is kept, asserted by the receipt. The plant's switch lives in the same class.
- **The witness's version is its `pom.properties`'**: the jar's manifest has no version attribute (printed).
- **The JPA side reaches `Sort.by` too**: the anchor's `CustomerRepository.findAll()` calls `findAll(Sort.by("name"))` on Spring Data
  JPA. The brief named the JPA side's order "the derived `findAllByOrderByNameAsc()`"; the page uses both, printed as what each is.
  C8-6 stays the Spring Data JDBC side's, and "all three" stays refused, because the plain SQL writes `order by name`.
- **The JDBC and plain sides are harness classes in files** (`JdbcDashboard`, `PlainSql`) so that the counter counts files on every
  side; `JdbcDashboard` is counted on the JDBC side as `Dashboard` is on the JPA side. `Customer.java` is labelled shared.
- **Decision-table rows**: the brief's "entities held" row is measured in this run's own transaction; JPA's missing-row and
  collection-save cells were measured (the brief allowed them only if measured); the name order is a row of its own; the test slice
  and auditing rows are dropped, and four plain-SQL cells are dropped as not measured.
- **The plant runs on PostgreSQL only** (the hook's store); `three` shows the same count on H2.
- **The exercise starts its own container on 20452** (the brief's "a port if it needs one"), so a viewer's run needs the image;
  without it the H2 line is the outcome, and the README says so.
- **C8-10 skipped**, said above.
- **No wall-clock time is written in this file**, not even the runs of record's: no time is measured in unit 06.

## Runs of record

On the script as committed (`md5 -q receipts.sh` in the block), each run of record ended exit 0 with every capture 3/3 and
`= published`, every Maven run `offline: yes`, volumes and images unchanged, nothing listening on 20450-20459 at the end; each run's
log went through `~/.venvs/slides2video/bin/python ~/Desktop/PromptVidya-Automation/check_unit8.py 06 --runlog <log>` (R.166's grep
errors only — the unit gate itself waits for a script: "no 06-*.md in scripts-and-decks/ yet", exit 2, as the prompt expects). The
three: `./receipts.sh` (the shebang's `/bin/bash`, 3.2.57), `bash receipts.sh` (Homebrew's bash, 5.3.9), and a sealed fresh clone —
`git clone file://…` of this repository at a local commit of this folder, into a path with a space, `.m2-demo` copied from the seed,
`DOCKER_CONFIG=$HOME/.docker`, `http_proxy`/`https_proxy` pointed at a dead `127.0.0.1:9`. No wall-clock figure is written here.

```
receipts.sh md5 53b9022d63cdad2b11a8a59b3f794846
./receipts.sh        /bin/bash 3.2.57             exit 0   check_unit8.py 06 --runlog: PASS
bash receipts.sh     /opt/homebrew/bin/bash 5.3.9 exit 0   check_unit8.py 06 --runlog: PASS
sealed clone         git clone file://… (a local commit of this folder) into "…/scratchpad/ev06/clone dir/tiffinbox-java",
                     .m2-demo from the seed, DOCKER_CONFIG=$HOME/.docker, http(s)_proxy at 127.0.0.1:9 (dead):
                     ./c8-unit06/receipts.sh exit 0   check_unit8.py 06 --runlog: PASS
```

Development passes before them produced the hashes. The plant runs found one gate too loose — the `rm -fv` check matched its own
line, so a container removed without `-v` reached the container check instead (plant 10 below) — and the gate was tightened before
the runs of record. The pushed commit is that local commit amended with this README's runs, interrupts and plants (the script and
every capture unchanged); one more pass of `./receipts.sh` on this README ran before the push, exit 0, every capture `= published`.

## Interrupted

SIGINT (`kill -INT` on the receipt's own pid, started with SIGINT at its default, as a terminal's Ctrl-C reaches it) at three points —
mid-build (the offline Maven build of anchor/'s copy), mid-container (after `docker run`, the container up, before any harness JVM),
mid-harness (a `probe.u06.U6` JVM running, the container up). After each: the exit, the containers, the volume count, the listeners
on 20450-20459, our JVMs and Maven, partial `.r-*.[123]` files, `.r-lock`, and the published captures' md5s.

```
SIGINT mid-build     exit 130 · fired: mvn running · containers c8u06-* 0 · volumes 315 · listeners 20450-20459 0 · our JVMs/Maven 0 · partial .r-*.[123] 0 · .r-lock gone · captures (= published): = = = = = = =
SIGINT mid-container exit 130 · fired: container up, no harness JVM · containers c8u06-* 0 · volumes 315 · listeners 20450-20459 0 · our JVMs/Maven 0 · partial .r-*.[123] 0 · .r-lock gone · captures (= published): = = = = = = =
SIGINT mid-harness   exit 130 · fired: harness JVM running, container up · containers c8u06-* 0 · volumes 315 · listeners 20450-20459 0 · our JVMs/Maven 0 · partial .r-*.[123] 0 · .r-lock gone · captures (= published): = = = = = = =
```

The receipt was started in the foreground of a launcher that writes its pid and then runs
`exec perl -e '$SIG{INT} = q(DEFAULT); exec @ARGV' ./receipts.sh` (a background job of a non-interactive shell starts with SIGINT
ignored); a watcher in the background sent the signal at the point; the mid-harness trigger matched a `java` process running
`probe.u06.U6`, so `javac` could not set it off.

## Planted faults — each caught (R.65, R.226)

On a scratch mirror (this folder copied, its siblings `c8-unit02`, `c8-unit03`, `c8-tiffinbox`, `c5-unit11`, `c7-unit31` linked
read-only), one plant at a time, the folder restored after each. "Nothing written" = the listing and md5 of every file in the
mirror's folder before and after the planted run (plants 31 and 32 need the captures: the mirror's receipt ran its seven captures and
stopped at the check after them, exit 1; its `.harness/` and `.r-*` files are a run's own and are not counted). The brief's 06 list
is plants 1, 2, 20, 21 (the query-execution count), 20 and the `plant` capture (the witness unwired), 22 (the commented anchor beside
the code column), 3 and 23 (an adjective). The doctored-capture plants (20-30) run `harness/chk06.py` on a copy of a published
capture in scratch with one line changed by Python's `re.sub` (macOS `sed` lacks GNU syntax); nothing in the folder is touched.
Plant 28 doctored one shell's line, so the bash/zsh check caught it before the count check.

```
plant  1 getQueryExecutionCount() read by the harness on the JPA side (C8-9/R.320) exit 1 · nothing written: yes · C8-9/R.320: the harness reads getQueryExecutionCount() - the JPA side's count is getPrepareStatementCount(), beside the witness
plant  2 getQueryExecutionCount() said as the JPA side's count, in README.md (C8-9/R.320) exit 1 · nothing written: yes · a refused word or reading in this unit's prose:   README.md line 291: C8-9/R.320: getQueryExecutionCount() as the JPA side's count - the prepare count only
plant  3 an adjective about a side, in README.md (R.261) exit 1 · nothing written: yes · a refused word or reading in this unit's prose:   README.md line 291: R.355/R.261: a cost or quality word (no time and no adjective in unit 06): simpler
plant  4 the planted duration word (dur8) exit 1 · nothing written: yes · a refused word or reading in this unit's prose:   README.md line 291: dur8: (the planted word)
plant  5 a wrong hash (the anchor tree pin) exit 1 · nothing written: yes · R.211: anchor/'s tree is 51 7ce49e3ec13c212a31ee6ba4618f53ab, the pin in receipts.md5 is 51 00000000000000000000000000000000 - the tree moved
plant  6 a placeholder in the exercise exit 1 · nothing written: yes · a placeholder in this unit's prose: exercise/README.md:50:(the planted to-do line)
plant  7 a dish name exit 1 · nothing written: yes · an Indian dish name (R.215: English names only): README.md:291:The page lists each customer's (the planted name) order.
plant  8 a typed count (R.302) exit 1 · nothing written: yes · a refused word or reading in this unit's prose:   README.md line 291: R.302: a capture's number typed in prose: 43
plant  9 the exercise solution = broken (R.196) exit 1 · nothing written: yes · R.196: SOLUTION.md's block must be the README's with one line changed (it is 0 lines apart)
plant 10 the container removed without -v (R.322) exit 1 · nothing written: yes · R.322: receipts.sh removes a container without its volume (rm -fv)
plant 11 the docker CLI unpinned, DOCKER_HOST=tcp://127.0.0.1:1 (R.344) exit 1 · nothing written: yes · R.344: receipts.sh calls docker without the pinned socket (every call is dk): 105:docker info > /dev/null 2>&1 || die "docker -H $DH info failed - is the engine running on that s
plant 12 the anchor link pointed at c8-tiffinbox (readlink) exit 1 · nothing written: yes · anchor must be a link to ../c8-unit02/after (it points at: ../c8-tiffinbox)
plant 13 Sort.by said for all three sides (RED #5) exit 1 · nothing written: yes · a refused word or reading in this unit's prose:   README.md line 291: RED #5: Sort.by said for all three sides - the plain SQL writes order by
plant 14 "single-query loading changes nothing" (R.368) exit 1 · nothing written: yes · a refused word or reading in this unit's prose:   README.md line 291: R.368: "single-query loading changes nothing"
plant 15 the JPA side's SQL order compared (S8.16) exit 1 · nothing written: yes · a refused word or reading in this unit's prose:   README.md line 291: S8.16: the SQL order compared - counts, never order
plant 16 a hand-written table row, no cell line (R.338) exit 1 · nothing written: yes · a refused word or reading in this unit's prose:   README.md line 291: R.338: a hand-written table row - every cell is a `cell` line the run printed, in a text block
plant 17 the witness changed beyond its three lines (R.357) exit 1 · nothing written: yes · R.357: harness/src/probe/u06/Witness.java must keep every line of unit 02's witness but three - its package line, the builder line (+ proxyResultSet) and the Connection guard (split for the 
plant 18 Course 7's paging title not byte-equal to java7_series.py (R.224) exit 1 · nothing written: yes · a refused word or reading in this unit's prose:   README.md line 108: R.224: a call-back without its title;  README.md line 311: R.224: a call-back without its title
plant 19 the exercise's docker unpinned (R.344) exit 1 · nothing written: yes · R.344: exercise/README.md calls docker without the pinned socket (docker -H "$DH")
plant 20 the witness unwired: 0 against Hibernate's count (a doctored witness, S8.15) exit 1 · FAIL PostgreSQL 18.6: the witness = getPrepareStatementCount() on the JPA side (C8-9, S8.15): ('0', '4', 'NO')
plant 21 the JPA count read as getQueryExecutionCount() (a doctored three, C8-9/R.320) exit 1 · FAIL PostgreSQL 18.6 r1: JPA - the witness = getPrepareStatementCount() ([])
plant 22 the anchor's commented lines set beside the code column (a doctored compare, S8.18) exit 1 · FAIL S8.18: the Spring Data JPA code-lines cell is the counter's code column first, its lines column beside it (484 (231))
plant 23 an adjective cell (a doctored compare, R.261) exit 1 · FAIL no adjective in any cell (R.261): ['4, simpler']
plant 24 no HHH000001 in one JVM (a doctored three) exit 1 · FAIL three: HHH000001 in every JVM's log
plant 25 a version line missing in one JVM (a doctored compare) exit 1 · FAIL compare: a version line in every JVM that started (2 of 3)
plant 26 the three answers unequal - the JDBC revenue moved (a doctored three) exit 1 · FAIL PostgreSQL 18.6 r1: the three answers equal, asserted before any count
plant 27 the JDBC page's count not one customer SELECT + one per customer + two sums (a doctored three) exit 1 · FAIL PostgreSQL 18.6 r2: JDBC - the witness 42 = 1 customer SELECT + one pause SELECT per customer (40 = the data line's customers) + the two sums; Hibernate 0
plant 28 the exercise's solution printing the broken count (a doctored exercise) exit 1 · FAIL bash and zsh print the same
plant 29 a cell's earlier capture by a wrong hash (a doctored compare, R.338) exit 1 · FAIL the cell's earlier capture dirty 0ba7a181 by hash = c8-unit02/receipts.md5's
plant 30 a line count that is not wc -l's (a doctored lines) exit 1 · FAIL anchor/tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntity.java: the counter's lines 84 = wc -l 168
plant 31 a changed What-it-prints line (exercise/SOLUTION.md) exit 1 · nothing written: yes · exercise/SOLUTION.md's "What it prints" block is not what its lines printed: 7c7 < EX PostgreSQL 18.6: statements 2 · revenue 240300 · paused days 77 · days by name 77 · name order = the JPA
plant 32 a typed SQL line in a README text block (R.302) exit 1 · nothing written: yes · R.302: README.md's text blocks must be lines the runs printed - not printed: SELECT customer.id AS id FROM customer ORDER BY customer.name ASC
plants: 32 · caught: 32
```

## For RED

- The JPA side's rows equal the plain side's in this data only because each customer has at most one pause (the entity-graph left
  join returns one row per customer); a customer with two pauses would add a row on the JPA side. The rows cell is the run's, not a
  rule.
- The `lines` totals count whole files; methods the page does not call are inside them on both repository sides.
- The JDBC side's `JdbcDashboard` is harness code written for this unit, as `PlainSql` is; the JPA side's assembly is the anchor's.
  Their comment policy is one template (a class Javadoc, no line comments); the code column is the comparison.
- The exercise's broken and solved blocks both carry the flag (in the copy); the viewer changes one line, the read.
- Single-query loading was measured here for `findAll()` and `findAll(Sort)` only, on PostgreSQL and H2; `findById` and `findAllById` are unit 03's `load`.
