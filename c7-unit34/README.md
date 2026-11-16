# c7-unit34 — Reading the SQL Hibernate Writes

Course 7, Section 5's sixth and last unit, and **Section 5's third and last change to the anchor** (brief flag 1, C3, "the index"):
`before` is the link to `../c7-unit31/after` (its tree's hash pinned — units 32 and 33 pin the same), `after/` is this unit's tree, and
`../c7-tiffinbox` equals `after/` from this unit's commit on. **`after/` is Section 5's frozen anchor: Section 6 builds over it.** Four
ways to see what Hibernate sent — a print, a logger with its values, counters, and a driver that writes the finished statement — then
one statement traced on PostgreSQL to a mapping that never asked for an index, and fixed in TiffinBox. Both databases (brief
flag 7): H2 2.5.250 in the harness JVM's memory, and PostgreSQL 18.6 — one container per run from the pinned image, a fresh database per
JVM. TiffinBox itself runs on PostgreSQL for the anchor capture (RE-MEASURE 8; the first unit to do so) and on H2 over TCP for the seven.

Nine captures, each run in three passes by `receipts.sh` and hashed (`receipts.md5`); every number and string below is asserted right after
its capture by `harness/chk34.py`, against another witness of the same run — never against a typed figure.

<!-- runs: begin -->
**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`, `DOCKER_CONFIG=$HOME/.docker`),
`.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s5/` alone (6,772 files), the image `postgres@sha256:77f58511…`
present (`docker image inspect`, the full digest), one container per run, removed at its end. A measuring run (12:41 CET) fixed T before
any run of record; development runs fixed the captures and the checks; the published hashes are the development passes' and every
run of record matched them. **The runs of record, on the script as committed (`receipts.sh` md5 printed by `md5 -q` and named in the
commit message):** 555 s under `./receipts.sh` (/bin/bash 3.2.57, 2026-11-15 from 13:48 CET), 594 s under `bash receipts.sh` (Homebrew
bash 5.3.9, from 13:57 CET) and 590 s from a sealed fresh clone (below, from 14:07 CET): each exit 0, all 9 captures 3/3 = published,
every check passed, every Maven run `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`, the anchor note empty at the start
and the end, `before/`'s tree pinned at both, the container removed and nothing listening on 20130-20139 at the end; each terminal log
through `check_unit7.py 34 --runlog` — `RESULT (run logs): PASS` (the unit gate: no 34 script yet). **Each run of record held twelve
`slow` JVMs per database** (four per capture run, three capture runs), and its own table check passed: every PostgreSQL ratio at or
above T = 7 in every JVM of every run (the smallest margin over the three runs is printed by each run's check line; the table below is
the development run's, checked by every run). **Nothing was downloaded.** The load averages read before and after each `slow` capture
run lay between 3.9 and 7.5 across the three runs (context, not a correction).

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at `936616d` into a path **with a space** (`…/sealed
34b/tiffinbox-java`, in the session's scratch folder), this commit's files put in as git will take them (`git ls-files -m -o
--exclude-standard c7-unit34 c7-tiffinbox c7-unit31`, links kept: 73 files); the clone's `.m2-demo` seeded from a file copy of the seed;
dead proxies for http and https in its environment (`127.0.0.1:9`); **`DOCKER_CONFIG=$HOME/.docker`** in its `env -i`; `./receipts.sh`.
An earlier sealed pass (from 13:40 CET, on the script before the `SQL_SLOW` change) stopped at `slow drifts across three runs` — two
lines with the index in one PostgreSQL JVM — and is why that count is tabled, not hashed (What differed); the three runs of record
above were all made after the change. The three runs ran on this README before this paragraph, the plants and the interrupt results
were written (those are the only changes since; the gates were re-run on the final text: `s34` refused 0, the table, text-block and
values checks pass on the final run's captures).
**Re-run after unit 36 moved the anchor (2026-11-16).** `../c7-unit36`'s commit changed `../c7-tiffinbox` — Section 6's first anchor change (C1, Flyway: `Database.java` deleted, `db/migration/V1__customer_and_pause.sql` and `V2__seed.sql` new, Boot's Flyway starter and Flyway's PostgreSQL module in `tiffinbox-web/pom.xml`, `ddl-auto: validate`, the sentences that named `Database` rewritten; its README) — so this script's anchor check prints the note at its start and end, never a stop (R.211): `after/` is still this unit's tree, which 35's `anchor` and 36's `before` link to. `receipts.sh` unchanged (its `md5 -q` the one 34's commit message names). One run on the moved anchor, `./receipts.sh` (/bin/bash 3.2.57), from 15:36 CET: exit 0 in 532 s, the note printed at the start and the end, all 9 captures 3/3 = published, `receipts.md5` unchanged (`md5 -q` the same before and after), its log through `check_unit7.py 34 --runlog` PASS. This script removes its container with `docker rm -f`, which keeps the image's anonymous volume (R.322, Section 6's rule): the re-run left one volume, created 15:36:38 by its container, and it was removed by hand after the run (the count back to its value before it); this script is not edited. 33's, 32's, 31's and earlier receipts were not re-run (RED #1200: their notes fire the same way; their links do not move).
<!-- runs: end -->

Published hashes (`receipts.md5`, every capture 3/3 in every run):

```
ways 32dd42875b98f04027928cdb734c202a
spy e2ac224152b2d90879021003aaa12449
dsproxy 3a569839bb35a44aef8d1c79d03f7672
slow af2e26348c028f0869add4c0ab0ccd72
anchor 244da09c25a52c03d4c65100dd0db026
seven 780b74b63db82027c223514e60758ec1
tests 93ee996f41781983c91746a1c734afc4
xcheck b4a9049f6780e8a1d1510b4c5079b749
exercise 68451faafc70cf241d5a8ae321b817f5
```

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line, R.225 — a SQL string
typed in this README outside this block, the `slow` table and the blocks the runs printed is refused):

<!-- values: begin -->
the values the video may say: on H2 2.5.250 and PostgreSQL 18.6, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - ways: the one read (Sunil [3], her id 3) is 2 statements - Statistics.getPrepareStatementCount = the proxy's prepareStatement, every way; (i) show-sql: 2 'Hibernate:' lines on stdout between the read's markers, no logger, no level, no binds (0 HTE_ lines at start, not counted); (ii) the OFF run (org.hibernate.SQL and org.hibernate OFF, no core level pinned): the same 2 lines, beside its control - effective level OFF, isDebugEnabled() false, 0 org.hibernate logger lines where the ON run has 6; (iii) binding parameter (1:VARCHAR) <- [Sunil] · binding parameter (1:BIGINT) <- [3]; (iv) format_sql: the first statement over 12 log lines; (v) highlight_sql: ESC[34m on 2 lines of the log file, 6 times; (vi) use_sql_comments: /* SELECT c FROM CustomerEntity c WHERE c.name = :name */ on the first statement, none on the collection's · spy: p6spy 3.9.1 (128891 bytes, printed by ls -l); on H2 the URL jdbc:p6spy:h2:… without a user name: exit 1, 'Wrong user name or password [28000-250]', Boot's pool user name null - with --spring.datasource.username=sa it runs (0 WARN, 0 JVM warnings) and spy.log writes each statement with its binds inlined: …where ce1_0.name='Sunil' · …where p1_0.customer_id=3; on PostgreSQL every spy.log line carries the URL with the password: 10 of 10 raw, 0 after the mask, the file deleted · dsproxy: datasource-proxy 1.11.1 (216737 bytes): 2 lines in the read, e.g. …Query:["select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal,ce1_0.version from customer ce1_0 where ce1_0.name=?"], Params:[(Sunil)] - 'jdbc:' 0 in its lines; Boot 4.1.2's BOM names neither tool (0 lines) · slow: the fixed design: the seed and 2000 generated customers with 100 pauses each (2004 customers, 200002 pauses, counted back), M 50 lookups per half, W 5 warm-up rounds, R 9 timed, each round without and with the index, the order reversed every other round; 4 JVMs per database per capture run, 12 per database in the three runs; the lookup's statement select pe1_0.id,pe1_0.customer_id,pe1_0.days from pause pe1_0 where pe1_0.customer_id=?; on PostgreSQL pg_indexes [pause_pkey] -> [pause_customer_id_idx, pause_pkey], the plan without: Seq Scan on pause pe1_0 (actual rows=100.00 loops=1) · Rows Removed by Filter: 199902, with: Bitmap Index Scan on pause_customer_id_idx (actual rows=100.00 loops=1); on PostgreSQL ratio >= 7: true in every JVM, on this Mac; on H2 [CONSTRAINT_INDEX_4, PRIMARY_KEY_4] -> [CONSTRAINT_INDEX_4, PAUSE_CUSTOMER_ID_IDX, PRIMARY_KEY_4], one plan both sides (/* PUBLIC.CONSTRAINT_INDEX_4: CUSTOMER_ID = CAST(1004 AS BIGINT) */) - H2's ratios numbers on the chip, no threshold; SQL_SLOW at a configured 5 ms (hibernate.log_slow_query, read off the EMF): lines in every PostgreSQL JVM without the index, more than with it in each (the counts tabled) - a chip, never a verdict · anchor: TiffinBox on PostgreSQL with 2004 customers and 200002 pauses (its seed + the generator, counted back): B (before/) pg_indexes [pause_pkey], the lazy collection's statement explained: Seq Scan on pause p1_0 (actual rows=100.00 loops=1) · Rows Removed by Filter: 199902; A (after/) [pause_customer_id_idx, pause_pkey], ->  Bitmap Index Scan on pause_customer_id_idx (actual rows=100.00 loops=1); A' = A; GET /dashboard 200 on each, 4 SQL lines in the whole request (the fourth read is one statement since the fetch plan moved into the anchor) · seven: 466c20ed7e0d5439cb052f32ce09de1b on before/ and after/, SQL lines during it 6 on both · tests: 18 (14/3/1) on after/, offline · xcheck: Hibernate's script moved, 9cf92b8cae3abfd0f1c0706bfe7a4373 -> 7f6942f0ed8bf296d661f629557f26c6, one line added: create index pause_customer_id_idx on pause (customer_id); · exercise: the README: 3 lines, index lines 0, md5 13401762a6f471154830cd96790e4660; the solution: 4 lines, index lines 1, md5 f079135b1c6e39a57d23af6ae03a225e - create index break_day_diner_id_idx on break_day (diner_id); (23 words)
<!-- values: end -->

### C3 — the change, file by file, and every sentence it rewrote (R.250)

Two source files and the anchor's README, nothing else (`diff -rq before after`, in the `anchor` capture):

- `tiffinbox-core/src/main/java/com/tiffinbox/PauseEntity.java` — `@Table(name = "pause")` becomes `@Table(name = "pause", indexes =
  @Index(name = "pause_customer_id_idx", columnList = "customer_id"))`, with `import jakarta.persistence.Index;`. Its class Javadoc gains
  a paragraph that starts *Course 7, unit 34*: the foreign key column carries an index — the column every read of a customer's pauses
  filters on; PostgreSQL makes none for a foreign key, H2 makes one for the constraint by itself; `Database`'s DDL creates it by hand
  (`ddl-auto: none`) and `@Index` says the same in the mapping, so Hibernate's own schema script creates it too. Its unit 09 paragraph
  ("The foreign key lives in this table … so this side owns the relationship") stays true and is kept.
- `tiffinbox-core/src/main/java/com/tiffinbox/Database.java` — after the pause table, `st.execute("CREATE INDEX pause_customer_id_idx ON
  pause (customer_id)");`, and a comment that starts *Course 7, unit 34*. The drop order is unchanged: `DROP TABLE IF EXISTS pause` comes
  first and drops the index with its table — measured, not assumed: every `slow` JVM runs the shipped `createAndSeed()` a second time on
  its own database, with the index already there, and it returns with the same index list (both databases).
- `README.md` (the anchor's) — **every sentence C3 makes false, rewritten (R.250) and the DDL sentence said as moved (R.252):** no
  sentence in `after/` quoted the old script's md5 as TiffinBox's current one (grepped: 0); the four sentences that said Hibernate's own
  DDL "is unit 27's, byte for byte" (29's and 31's header notes, 29's and 31's sections) each carry the note *(Course 7, unit 34: it moved
  there — one line, the index on `pause.customer_id`; its section below.)*; unit 09's sentence on Hibernate's DDL for the two entities
  gains *(Course 7, unit 34: and an index on `customer_id` since …)*; the header gains unit 34's note (Section 5's frozen anchor) and the
  file a `## Course 7 · unit 34 — the index` section. No other sentence of `after/` says the pause table has no index (grepped for
  "names no index", "creates none", "no index on the pause", "0 index lines": 0).

`CustomerEntity`, the repositories, the web module, the templates and both test classes are untouched; the eighteen tests pass on `after/`
(`tests`; 18/18 is a guard — R.190). The gate runs in `receipts.sh` before any build. Plant: the `@Index` left out of `after/`'s
`PauseEntity` — the gate stops first (C3's line missing); with the gate's line kept and only the annotation's effect removed, `xcheck`
would print the old script and A's index list `[pause_pkey]` (Planted faults, C1).

## The captures — what each one shows

### 1 · ways — one read, six ways (H2; S5.13, R.296)

The one read — `findByName("Sunil")` and her pauses, inside one `TransactionTemplate` — in six harness JVMs on H2, one option set each;
the three witnesses (Statistics, the JDBC proxy, the SQL logger where it is on) agree in every one. (i) `spring.jpa.show-sql=true` with the
SQL logger at WARN: the read's statements printed on standard output, each on a line that starts `Hibernate:` — no logger name, no level,
no bound value:

```text
Hibernate: select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal,ce1_0.version from customer ce1_0 where ce1_0.name=?
Hibernate: select p1_0.customer_id,p1_0.id,p1_0.days from pause p1_0 where p1_0.customer_id=?
```

(ii) **The OFF run:** show-sql on, `--logging.level.org.hibernate.SQL=off` and `--logging.level.org.hibernate=off`, and a logback file
that pins no Hibernate core level (RED #1509: the probe's pinned `org.hibernate.orm.core` at INFO, so its OFF run was not off). The two
lines still print between the read's markers, and the control says the level took — no log level silences show-sql, because show-sql
is not a logger: in the OFF run the effective level of `org.hibernate.SQL` is OFF, `isDebugEnabled()` false, and the whole log holds no
`org.hibernate` logger line, where the ON run (iii) has them:

```text
PROBE the level control: org.hibernate.SQL's effective level (logback) OFF · LoggerFactory.getLogger("org.hibernate.SQL").isDebugEnabled() false · org.hibernate's effective level OFF
read off its log - 'Hibernate:' lines (show-sql, stdout) inside the read's markers: 2 · outside them: 0 (of them create global temporary table HTE_: 0)
read off its log - org.hibernate logger lines in the whole log (grep -cE '^LEVEL [thread] org.hibernate...'): 0 · org.hibernate.SQL lines inside the read's markers: 0 · bind lines (org.hibernate.orm.jdbc.bind) inside them: 0
```

(iii) The SQL logger at DEBUG and the bind logger, `org.hibernate.orm.jdbc.bind`, at TRACE: each statement as a log line, then its bound
value — Sunil's name, then her id as the second connection reads it:

```text
TRACE [main] org.hibernate.orm.jdbc.bind : binding parameter (1:VARCHAR) <- [Sunil]
TRACE [main] org.hibernate.orm.jdbc.bind : binding parameter (1:BIGINT) <- [3]
```

(iv) `hibernate.format_sql=true`: each statement over several log lines, one clause or column per line (the count is the values line's).
(v) `hibernate.highlight_sql=true`: the keywords wrapped in terminal colour codes — written into the log file itself, counted there with
`grep` and shown once through `cat -v`:

```text
DEBUG [main] org.hibernate.SQL : ^[[34mselect^[[0m ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal,ce1_0.version ^[[34mfrom^[[0m customer ce1_0 ^[[34mwhere^[[0m ce1_0.name=?
```

(vi) `hibernate.use_sql_comments=true`: the derived query's JPQL as a comment in front of its statement; the collection's statement has
none:

```text
DEBUG [main] org.hibernate.SQL : /* SELECT c FROM CustomerEntity c WHERE c.name = :name */ select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal,ce1_0.version from customer ce1_0 where ce1_0.name=?
```

And `Statistics` prints counts, never text: `getPrepareStatementCount()` beside the proxy's `prepareStatement`, in every JVM. The brief's
"3 `HTE_` lines at start" were the probe's harness entities' temporary tables; this harness maps the anchor's two entities alone, and the
count is printed: 0 (What differed).

### 2 · spy — p6spy as the driver (H2 and PostgreSQL; S5.12, S5.20, RE-MEASURE 14)

p6spy 3.9.1 from `harness/tools/pom.xml` (offline, from the section's seed; its jar named and sized by `dependency:list` and `ls -l`,
R.302 — the values line), the URL `jdbc:p6spy:h2:…` / `jdbc:p6spy:postgresql:…`, the driver class `com.p6spy.engine.spy.P6SpyDriver`, and
`spy.properties` (`harness/spy.properties`, copied into the JVMs' folder `.harness/run`: the real drivers, the file appender, `spy.log`, one
line per statement). **The failing start, filed (S5.20):** on H2, without Boot's user name, the start stops — Boot gives its default user
`sa` to an embedded URL only, and the wrapped URL does not look embedded: Boot's pool prints its user name as null, the shipped
`Database`'s seed fails, exit 1, and the step's own log holds the line; the fixed run beside it adds `--spring.datasource.username=sa`:

```text
PROBE Boot's pool (HikariDataSource): driver class com.p6spy.engine.spy.P6SpyDriver · user name (getUsername()) null
PROBE caused by: org.h2.jdbc.JdbcSQLInvalidAuthorizationSpecException: Wrong user name or password [28000-250]
the failing start's step - exit 1 · its line (grep -o): Wrong user name or password [28000-250]
PROBE Boot's pool (HikariDataSource): driver class com.p6spy.engine.spy.P6SpyDriver · user name (getUsername()) sa
```

`spy.log` is the one witness that prints a runnable statement: the prepared SQL and, in its last field, the same SQL with the values
inlined — `name='Sunil'`, `customer_id=3`. **On PostgreSQL every line carries the JDBC URL, the password with it:** the raw file is grepped
for the generated password before the mask (every line holds it — the count is the values line's), masked into `.harness/spy-pg.masked.log`,
the raw file deleted; raw copies after the mask: 0; `spy.log` is ignored by git (the root `.gitignore`) and never committed:

```text
<time>|<ms>|statement|connection <n>|url jdbc:p6spy:postgresql://127.0.0.1:20138/u34spy?user=sa&password=<pw>|select p1_0.customer_id,p1_0.id,p1_0.days from pause p1_0 where p1_0.customer_id=?|select p1_0.customer_id,p1_0.id,p1_0.days from pause p1_0 where p1_0.customer_id=3
```

0 WARN lines and 0 JVM warnings on the fixed H2 run, counted. p6spy is adopted for the beat (the contract's Section 5 item: resolution
only, loopback); the loser "p6spy is what you will meet in old code" is false here — it runs on JDK 25, Boot 4.1.2 and Hibernate 7.4.13.

### 3 · dsproxy — datasource-proxy around Boot's pool (H2)

`datasource-proxy 1.11.1` (its jar named and sized, the values line) wraps Boot's pool through a `BeanPostProcessor`:
`ProxyDataSourceBuilder.create(ds).name("tiffinbox").logQueryBySlf4j(SLF4JLogLevel.INFO)`. One line per statement, its query and its
parameters, the connection's number and the time masked (S5.12) — and no URL: `jdbc:` in none of its lines:

```text
INFO  [main] net.ttddyy.dsproxy.listener.logging.SLF4JQueryLoggingListener : Name:tiffinbox, Connection:<n>, Time:<ms>, Success:True, Type:Prepared, Batch:False, QuerySize:1, BatchSize:0, Query:["select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal,ce1_0.version from customer ce1_0 where ce1_0.name=?"], Params:[(Sunil)]
```

Spring Boot 4.1.2's BOM names neither tool (`grep` over its pom: 0 lines), so both versions are written in `harness/tools/pom.xml`; the
third-party decorator starters are not named here (no capture prints them).

### 4 · `slow` — the lookup by the foreign key, a fixed design (⚑6, S5.11, S5.17, R.207, R.236, R.245, R.300)

Each JVM: the shipped `Database` on a fresh database (H2 in its memory, or the container's), the shipped seed run again (the
index there — it returns), then the generator on a second connection — 2,000 customers with 100 pauses each, counted back as the seed
plus the generator — then the lookup of one customer's pauses, `select p from PauseEntity p where p.customer.id = :id`, whose statement
is read off Hibernate's SQL logger once (the statement the lazy collection and every N+1 select filters the same way). M 50 lookups per
half, the ids rotating over every customer, each lookup's rows checked against the second connection's count; W 5 warm-up rounds and R
9 timed; **each round two halves, without the index and with it — the index dropped or created (and `analyze pause` on PostgreSQL) between
the halves, even rounds without first, odd rounds with first**, every round's order printed and checked (S5.17: the grouped design — all
without, then all with — is refused; it is the probe's, and it carried an order effect). The SQL logger at WARN; the counting proxy and
Statistics on in both halves alike. The mapping's index matters only when a schema is created; here the index is dropped and created by
SQL on the harness's own run, so the harness needs no `before/` mapping.

**The index lists, from the catalogue** (both databases) and **the plan pair** (PostgreSQL: `explain (analyze, timing off, summary off,
costs off, buffers off)` of the captured statement, its `?` bound to the id the run reads for `Customer 0001000` — no cost and no time in
it, R.245; the same pair in every JVM of the run):

```text
PROBE indexes on pause without the index: [pause_pkey]
PROBE plan without the index: Seq Scan on pause pe1_0 (actual rows=100.00 loops=1)
PROBE plan without the index:   Filter: (customer_id = 1004)
PROBE plan without the index:   Rows Removed by Filter: 199902
PROBE indexes on pause with the index: [pause_customer_id_idx, pause_pkey]
PROBE plan with the index: Bitmap Heap Scan on pause pe1_0 (actual rows=100.00 loops=1)
PROBE plan with the index:   Recheck Cond: (customer_id = 1004)
PROBE plan with the index:   Heap Blocks: exact=100
PROBE plan with the index:   ->  Bitmap Index Scan on pause_customer_id_idx (actual rows=100.00 loops=1)
PROBE plan with the index:         Index Cond: (customer_id = 1004)
PROBE plan with the index:         Index Searches: 1
```

PostgreSQL makes no index for a foreign key; H2 makes one for the constraint itself, and the new index is a second index on the same
column that H2's plan does not use — one plan on both sides:

```text
PROBE indexes on pause without the index: [CONSTRAINT_INDEX_4, PRIMARY_KEY_4]
PROBE indexes on pause with the index: [CONSTRAINT_INDEX_4, PAUSE_CUSTOMER_ID_IDX, PRIMARY_KEY_4]
```

**The ratio** (R.207, R.236): each JVM's median without the index over its median with it, printed per JVM, masked in the capture, tabled
below — every JVM of the run of record, both databases. **T was fixed before the runs of record from a measuring run** (alternated, the
same design: six JVMs per database at 12:41 CET; its figures are in What differed): T = 7, the largest
integer leaving a margin of at least 2 below the smallest measured PostgreSQL ratio; it is in the script (`TT=7`) and asserted below every
PostgreSQL JVM. On this Mac, on PostgreSQL, the lookup without the index is slow beside the one with it in every JVM of the run: `ratio >= T:
true`. H2's ratios are numbers on a chip — no threshold, never characterised (S5.9, S5.11).

**The `SQL_SLOW` chip:** `hibernate.log_slow_query=5` as a run option, printed back off the EntityManagerFactory's properties (R.201);
Hibernate's `org.hibernate.SQL_SLOW` logger at INFO; its lines counted per half over the timed rounds and tabled, each line's figure
masked. At a configured `hibernate.log_slow_query=5` the logger printed lines in every PostgreSQL JVM without the index, more than with
it in each — a chip, never a verdict: how many lines it printed moves from JVM to JVM (the table), because the lookups' own figures sit
just above the configured value without the index, and an odd lookup with it can cross it too (the sealed clone's first pass printed two
lines with the index in one JVM; a development pass at 3 printed one); so neither count is hashed, both are tabled, and the check asserts
only "more than 0 without, and more without than with" per PostgreSQL JVM. Its margin line, the smallest figure a line reported without
the index against the configured value, is under the table.

The load averages (`sysctl -n vm.loadavg`) before and after each capture run's `slow` are under the table, as context, not as a
correction.

<!-- slow-table: begin -->
| database | capture run | JVM | ratio without / with | medians (ms): without · with | SQL_SLOW lines: without · with | smallest logged time (ms) |
|---|---|---|---|---|---|---|
| H2 | 1 | 1 | 1.12 | 15.5 · 13.9 | 0 · 0 | none |
| PostgreSQL | 1 | 1 | 11.02 | 404.4 · 36.7 | 450 · 0 | 6 |
| H2 | 1 | 2 | 1.00 | 13.5 · 13.5 | 0 · 0 | none |
| PostgreSQL | 1 | 2 | 9.22 | 347.8 · 37.7 | 115 · 0 | 6 |
| H2 | 1 | 3 | 0.98 | 14.7 · 15.0 | 0 · 0 | none |
| PostgreSQL | 1 | 3 | 10.52 | 408.9 · 38.9 | 450 · 0 | 6 |
| H2 | 1 | 4 | 0.93 | 13.3 · 14.3 | 0 · 0 | none |
| PostgreSQL | 1 | 4 | 10.19 | 363.6 · 35.7 | 195 · 0 | 6 |
| H2 | 2 | 1 | 0.99 | 14.4 · 14.6 | 0 · 0 | none |
| PostgreSQL | 2 | 1 | 9.72 | 346.1 · 35.6 | 42 · 0 | 6 |
| H2 | 2 | 2 | 0.94 | 14.1 · 15.0 | 0 · 0 | none |
| PostgreSQL | 2 | 2 | 11.68 | 397.7 · 34.1 | 450 · 0 | 6 |
| H2 | 2 | 3 | 1.01 | 15.7 · 15.5 | 0 · 0 | none |
| PostgreSQL | 2 | 3 | 8.93 | 347.8 · 38.9 | 58 · 0 | 6 |
| H2 | 2 | 4 | 0.94 | 13.4 · 14.2 | 0 · 0 | none |
| PostgreSQL | 2 | 4 | 10.17 | 393.4 · 38.7 | 450 · 0 | 6 |
| H2 | 3 | 1 | 1.04 | 14.4 · 13.8 | 0 · 0 | none |
| PostgreSQL | 3 | 1 | 9.08 | 355.2 · 39.1 | 180 · 0 | 6 |
| H2 | 3 | 2 | 1.00 | 13.8 · 13.9 | 0 · 0 | none |
| PostgreSQL | 3 | 2 | 8.24 | 351.4 · 42.6 | 54 · 0 | 6 |
| H2 | 3 | 3 | 0.97 | 14.2 · 14.6 | 0 · 0 | none |
| PostgreSQL | 3 | 3 | 10.03 | 401.4 · 40.0 | 450 · 0 | 6 |
| H2 | 3 | 4 | 1.05 | 14.3 · 13.7 | 0 · 0 | none |
| PostgreSQL | 3 | 4 | 9.60 | 337.8 · 35.2 | 42 · 0 | 6 |

margin: the smallest PostgreSQL ratio without / with the index 8.24 - T 7 = 1.24
SQL_SLOW margin: the smallest time a SQL_SLOW line reported on PostgreSQL, without the index, 6 - the configured 5 = 1
load average, capture run 1 - load average before: { 5.21 4.73 4.62 }
load average, capture run 1 - load average after: { 4.00 4.40 4.50 }
load average, capture run 2 - load average before: { 4.00 4.40 4.50 }
load average, capture run 2 - load average after: { 3.86 4.31 4.46 }
load average, capture run 3 - load average before: { 3.86 4.31 4.46 }
load average, capture run 3 - load average after: { 3.60 4.11 4.37 }
<!-- slow-table: end -->

### 5 · anchor — the change, and TiffinBox B / A / A′ on PostgreSQL (the failure receipt is B; RE-MEASURE 8)

TiffinBox itself on PostgreSQL — the first unit to run it there since `../c7-unit06` (the brief's plan was U39; 34 needs it because the
sequential scan is PostgreSQL's alone). Each of **B** (`before/`, port 20130), **A** (`after/`, 20131) and **A′** (`after/` copied and
built again, 20132): a fresh database in the container; TiffinBox from its extracted jar with the PostgreSQL driver beside it (TiffinBox
declares none — unit 06's form); its URL, password in it, written by this script into the tree's own config tree,
`secrets/tiffinbox/jdbc-url` (mode 0600) — the `optional:configtree:./secrets/` import the anchor's `application.yaml` already declares
reads it as `tiffinbox.jdbc-url`, so the password is on no command line and in no environment; `--spring.datasource.username=sa`; and
`--logging.level.org.hibernate.orm.connections.pooling=warn`, which keeps Hibernate's start-up line that prints the URL (password and
all) out of the log — TiffinBox's log holds no raw copy of the password, counted before any mask. The shipped `Database` drops and seeds at
start, so the generator runs after TiffinBox is ready, on a second connection (the harness's `GenMain`, plain JDBC): the same 2,000
customers with 100 pauses each, counted back; then the indexes on `pause` from `pg_indexes`, then the plan of the lazy collection's own
statement — read off the `ways` capture's SQL logger, not typed — then `GET /dashboard`:

```text
PROBE indexes on pause (pg_indexes): [pause_pkey]
PROBE plan: Seq Scan on pause p1_0 (actual rows=100.00 loops=1)
PROBE indexes on pause (pg_indexes): [pause_customer_id_idx, pause_pkey]
PROBE plan: Bitmap Heap Scan on pause p1_0 (actual rows=100.00 loops=1)
PROBE plan:   ->  Bitmap Index Scan on pause_customer_id_idx (actual rows=100.00 loops=1)
```

B is the failure receipt: on `before/` the statement scans the whole pause table and removes every other customer's rows; on `after/` the
shipped `Database` made the index and the statement reads it; A′ = A, line for line. The dashboard answers 200 on all three with the same
count of SQL lines in the whole request (between two markers; the fourth read is one statement since the fetch plan moved into the
anchor) — the page is unchanged; its read is the dashboard's join, and the collection's statement is the one the plan pair explains.

### 6 · seven, 7 · tests, 8 · xcheck

**seven** — the comparison set on `before/` and `after/` (port 20133), TiffinBox's database on the H2 TCP server (`mem:…` on
127.0.0.1:20137): the same md5 on both trees (the seed's seven; no import), and the same count of SQL lines during it — an index changes no
statement. **tests** — TiffinBox's eighteen on `after/`, offline, from Surefire's reports (14/3/1): a guard (R.190); **C7-4 paid again,
carried to U39**. **xcheck** — Hibernate's DDL script over `after/`'s libraries (`probe.x.XMain`, `scripts.action=create`, never run),
filed as `xcheck.sql`, and over `before/`'s beside it:

```text
create index pause_customer_id_idx on pause (customer_id);
the lines that differ (diff, the batching lesson's xcheck.sql against after/'s script): added 1 · removed 0:
```

**The DDL sentence, said as moved (R.252):** Hibernate's schema script is no longer the one from the lesson called Optimistic Locking
with At-Version: unit 34 adds one line to it, the index — both md5s printed by `xcheck` and in the values line, never typed. 34 is the
first unit since 27 whose `xcheck.sql` differs from the unit before it.

### 9 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s lines, then `exercise/SOLUTION.md`'s, read from the files and run in one `env -i` shell, `/bin/bash`, then again in
`/bin/zsh -f`; each file's "What it prints" block equals the run, line for line; broken and solved print differently.

## Call-backs, by title (R.224)

- The lesson called `Optimistic Locking with At-Version` (27) — the DDL sentence, said as moved (above).
- The lesson called `Your First Entity and EntityManager` (03) — the first in this course to show Hibernate's SQL logger and show-sql
  (`grep` over `scripts-and-decks/*.md`: 03 is the first file that names either).
- The lesson called `Paging and Sorting` (20) — its query plans; this unit's plan pair is the same `explain` form.
- Section 5's earlier lessons, by title from `java7_series.py`: the lesson called `Lazy Loading and LazyInitializationException`, the
  lesson called `N+1, Measured`, the lesson called `JOIN FETCH vs @EntityGraph vs @BatchSize`, the lesson called `The Second-Level Cache`,
  the lesson called `Batching and the Write Path` — the statement timed is the one the lazy collection runs, and the one every N+1 select
  runs.
- Course 2's lesson called `SQL in 15 Minutes: TiffinBox Tables in H2` (read off `java2_series.TITLES["34"]`) — where TiffinBox's tables
  were first written as SQL.
- The lesson called `Flyway: Versioned Migrations` (36) — its first migration carries the index (CARRIED).

## The developer boundary

Past this is database administration — a future course 20, *Databases for Java Developers* (`TRACK-ROADMAP.md:1099`).

## The commands this unit adds

The tools' pom (offline); the harness, compiled once against `after/`'s extracted libraries and the tools' jars; the harness's JVM (`V`
the flags, `A` the arguments, R.193; `$CPX` adds p6spy's or datasource-proxy's jar where a capture needs it); the generator's JVM beside a
running TiffinBox; `XMain`'s JVM (`$T` the tree); TiffinBox on PostgreSQL; the H2 TCP server; the container, its readiness, a fresh
database per JVM; TiffinBox's run line with the SQL logger:

```
mvn -B dependency:list dependency:copy-dependencies -DoutputDirectory=../tools
javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*:.harness/tools/*" harness/src/probe/q/DsProxyImpl.java harness/src/probe/q/Gen.java harness/src/probe/q/GenMain.java harness/src/probe/q/H.java harness/src/probe/q/Main.java harness/src/probe/q/Run.java harness/src/probe/q/Seed.java harness/src/probe/q/Slow.java harness/src/probe/q/SqlCounter.java harness/src/probe/x/XMain.java
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../after/tiffinbox-web/target/extracted/lib/*:../../.m2-demo/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar$CPX" probe.q.Main "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../after/tiffinbox-web/target/extracted/lib/*:../../.m2-demo/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar" probe.q.GenMain
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -cp "../hc:../$T/tiffinbox-web/target/extracted/lib/*" probe.x.XMain "${A[@]}"
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../../.m2-demo/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.datasource.username=sa --logging.level.org.hibernate.SQL=debug
cd .harness/run && exec perl -e 'alarm 3000; exec @ARGV' java -Duser.language=en -Duser.country=US -Dh2.bindAddress=127.0.0.1 -cp "../after/tiffinbox-web/target/extracted/lib/h2-2.5.250.jar" org.h2.tools.Server -tcp -tcpPort 20137 -ifNotExists
docker run -d --pull never --name c7u34-pg -p 127.0.0.1:20138:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v "$U/.harness/secrets/pgpw:/run/pgpw:ro" postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
docker exec c7u34-pg pg_isready -U sa -h 127.0.0.1 -q
docker exec c7u34-pg psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c "drop database if exists $DB with (force)" -c "create database $DB"
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.org.hibernate.SQL=debug
```

The anchor's own lines are read from `after/README.md` and asserted whole: its package line (`mvn -B package`, offline; `-DskipTests` on
`before/` and A′, the tests run on `after/` — a guard), its test line, its extract line, its run line and its token line. On PostgreSQL the
harness gets `-Dpg.db=NAME -Dpg.pwfile=../secrets/pgpw` and builds the URL inside the JVM (`jdbc:p6spy:postgresql:` with `-Dspy=true`): the
password is on no command line, every printed URL is cut before its `?`.

## The repository, and the network

Every Maven run is `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s5/` alone (6,772 files). p6spy 3.9.1 and `datasource-proxy 1.11.1` come from it through
`harness/tools/pom.xml`; the seed's cache jars are on no class path here. Five Maven runs before the captures: `before/`'s package
(`-DskipTests`), `after/`'s package (its tests run), A′'s package (`-DskipTests`), the tools' `dependency:list` +
`dependency:copy-dependencies`, and in `tests` `after/`'s `clean test`; each `offline: yes`, 0 `Downloaded from` lines, as the build lines
print. **At run time** the harness binds no port; its H2 databases are in its JVM's memory; its PostgreSQL databases are fresh ones in the
container, loopback only; TiffinBox's databases are fresh ones in the container (`anchor`) or on the H2 server (the seven). **No network
act** (`docker run --pull never`): the section's dated sweep is the brief's (`_research/spring-boot-metadata-2026-11-13.xml`,
`spring-data-bom-metadata-2026-11-13.xml`, `hibernate-core-metadata-2026-11-13.xml`: no 4.1.x patch, Hibernate 7.4.15 exists and is not
adopted — ⚑8, R.223). Every harness JVM prints `Version.getVersionString()`, Spring Data JPA's version, Spring Framework's from
`spring-tx`'s manifest and Hibernate's `HHH000001` line (S4.13, asserted per JVM by `chk34.py` — the OFF run excepted by design: every
`org.hibernate` logger is off there, which is what it measures), and its database line.

## The locale

The JVM ignores `LC_ALL` on macOS: every JVM this script starts carries `-Duser.language=en -Duser.country=US` on its java line, and the
hygiene check refuses a java line without it (and one without its alarm).

## The folders, the harness and the ports

- `before` → `../c7-unit31/after` (a link; `readlink` asserted, its tree hashed by `harness/tree34.py` and pinned — the pin 32 and 33
  hold); `after/` this unit's tree; `../c7-tiffinbox` equal to `after/` (`diff -rq` at the start and the end; a note if a later unit moves it,
  R.211). Never built in place: copied to `.harness/before`, `.harness/after`, `.harness/after2` (A′) and `.harness/tests`.
- `harness/src/probe/q` — `Main` (the context: `@EntityScan("com.tiffinbox")`, `@EnableJpaRepositories("com.tiffinbox")`,
  `WebApplicationType.NONE`), `Seed` (the shipped `Database` on the run's database; Boot's pool's user name printed, the counting proxy
  around it, datasource-proxy around that with `-Ddsp=true`), `Run` (the scenarios `read` and `slow`, the level control), `Slow` (the
  fixed design), `Gen` (the generator), `GenMain` (the second connection beside TiffinBox), `H` (the second connection, the catalogue, the
  plans, the witnesses), `SqlCounter` (the SQL logger's events and texts; the `SQL_SLOW` logger's events and their smallest time),
  `DsProxyImpl` (compiled against datasource-proxy's jar, loaded by name), `ex/ExApp` (the exercise, compiled only by its own lines).
  `harness/src/probe/x/XMain.java` is unit 29's, byte for byte. No `Thread.sleep` in `harness/src` (grepped).
- `harness/logback.xml` (one line per event; `org.hibernate.SQL` at DEBUG the one Hibernate level it pins — `HHH000001` comes from a run
  option, `--logging.level.org.hibernate.orm.core=info`, in every JVM but the OFF run, RED #1509), `harness/spy.properties`,
  `harness/tools/pom.xml`, `harness/chk34.py` (the checks), `harness/s34.py` (the prose gate, its self-test first), `harness/tree34.py`
  (unit 33's `tree33.py`, byte for byte), `harness/surefire.py` (the testing lesson's, byte for byte), `harness/dur7.py` (the builders'
  `dur7.py`, byte for byte, untouched).
- **Ports (§P, 20130-20139):** 20130 B · 20131 A · 20132 A′ · 20133 the seven (`before/`, then `after/`) · 20137 the H2 TCP server
  (`127.0.0.1` alone, asserted) · 20138 the container (`docker port` asserted: `127.0.0.1:20138` alone) · 20134-20136 and 20139 never bound;
  the harness JVMs bind none. All ten are asserted free at the start and the end (and 18425, 8080, 35729).
- **Alarms (R.247):** every harness JVM and TiffinBox `alarm 240` — a `slow` JVM on PostgreSQL is the generator plus 14 rounds × 2 halves × 50
  lookups, 28 index drops or creates and analyses, which the measuring run's JVMs ran well inside the cap on a machine at load 4-5; the
  script's own wait gives up at 250; the H2 server `alarm 3000` (it lives for the whole run); the exercise's JVM `alarm 120`.

## Masks, filters and hygiene — every one, declared

- **Masked** in every capture (the mask's self-test runs first on planted lines): the PostgreSQL password (`<pw>`), the TiffinBox token,
  this folder and its parent (plain and `%20`-encoded), the home folder, the user name, the JDK's version, an EntityManager's identity, an
  identity hash, a lambda's address, Spring Data's scan figure, H2's build date, a response's timestamp, a request thread's number, a
  virtual thread's number; **p6spy's** time and elapsed fields and its connection number; **datasource-proxy's** `Connection:` and
  `Time:`; **`SQL_SLOW`'s** per-line figure; **in `slow`**: every timed value, every median, every ratio and every `SQL_SLOW` count and
  smallest time — the figures go to `.r-slow.table` alone.
- **Filtered**: `SQL_SLOW`'s lines are counted, not shown; TiffinBox's requests are summarised by counts between two markers; `spy.log`
  shows the read's two statements (and one line in full on PostgreSQL), masked.
- **Hygiene**, asserted at the end: raw password and token copies 0 in every raw capture run, every capture, the `slow` table and every log
  (TiffinBox's on PostgreSQL included); no `spy.log` on disk; no absolute path, unit number, time, masked figure left bare, unmasked ratio,
  thread number, OS token, unmasked identity, password, URL but TiffinBox's own or stack frame in any capture; every JVM pinned (locale) and
  under its alarm; no kill by name; no bare wait; no sleep or polling loop in `harness/src`; no H2 file.

## Interrupted

`receipts.sh` traps INT and TERM: it stops the JVM (harness or TiffinBox — the TiffinBox pid kept aside while the generator's JVM runs),
any Maven or javac and every process under it, the exercise's shell, the H2 server; sweeps its process group; removes the container if
it started it (`CSTARTED` set before `docker run`, `pgrm` retrying until `docker ps -a` no longer names it); deletes a `spy.log` a run
left; removes the capture's unfinished runs; exits 130. A leftover-container guard refuses to start while a container named `c7u34-pg`
exists.

**Measured (2026-11-15, from 14:18 CET, on the scratch mirror):** `receipts.sh` started `env -i` in a session of its own **with SIGINT at
its default** (`perl -MPOSIX -e '$SIG{INT}="DEFAULT"; setsid; exec …'`), `kill -INT` to its group once the named process was in it, the
state read 5 s after its exit — six trials:

```
build (org.codehaus.plexus.classworlds.launcher.Launcher seen: 1): processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · container c7u34-pg: 0 · .r-lock: no · unfinished runs: 0 · spy.log: 0 · captures unchanged: yes · java left (pgrep -x java): 0
h2server (org.h2.tools.Server seen: 1): processes in the group at SIGINT 7 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · container c7u34-pg: 0 · .r-lock: no · unfinished runs: 0 · spy.log: 0 · captures unchanged: yes · java left (pgrep -x java): 0
harness (-Ds=read seen: 1): processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · container c7u34-pg: 0 · .r-lock: no · unfinished runs: 0 · spy.log: 0 · captures unchanged: yes · java left (pgrep -x java): 0
container (-Dpg.db=u34spy seen: 1): processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · container c7u34-pg: 0 · .r-lock: no · unfinished runs: 0 · spy.log: 0 · captures unchanged: yes · java left (pgrep -x java): 0
slow (-Ds=slow seen: 1): processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · container c7u34-pg: 0 · .r-lock: no · unfinished runs: 0 · spy.log: 0 · captures unchanged: yes · java left (pgrep -x java): 0
tiffinbox (com.tiffinbox.web.TiffinBoxServer seen: 1): processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · container c7u34-pg: 0 · .r-lock: no · unfinished runs: 0 · spy.log: 0 · captures unchanged: yes · java left (pgrep -x java): 0
```

`build` — `before/`'s Maven build; `h2server` — the H2 TCP server just up, before the container; `harness` — the first harness JVM (`ways`
on H2); `container` — p6spy's PostgreSQL JVM (`-Dpg.db=u34spy`), the container up; `slow` — the first timing JVM; `tiffinbox` — TiffinBox
on PostgreSQL (`anchor` B, on 20130; the H2 server and the container up). The container was gone after each, nothing listened in
19800-20399, and `pgrep -x java` showed none.

## Exercise

"Your turn: the README's schema script has no index on a pause's customer. Add one in the mapping, so Hibernate's script creates it."
(Its word count is printed by the receipt with `wc -w` and asserted equal to the brief's.) A Spring Boot application of its own (`Diner`
and `Break` — this exercise's customer and pause, the break owning the foreign key — H2 in memory, no port, no container, not TiffinBox's
tables): the README's lines print Hibernate's schema script with no index line; the solution's one changed line adds `@Index` to
`Break`'s `@Table`, and the script gains one line, the index — another md5. Broken ≠ solved by the printed lines and the md5 (R.196); the
check derives the solution's line count from the broken one's. PG-free (RED #1512, BLUE's decision (b)): the plan pair on PostgreSQL stays
the `slow` beat, not the exercise. **R.200:** the lesson called `JOIN FETCH vs @EntityGraph vs @BatchSize` has the fetch plan as its
exercise and the lesson called `Batching and the Write Path` the ordering of the inserts; this one is the index.

## The ledger rows and hand-offs this unit pays

- **C7-4 "TiffinBox has tests now" — paid again** (`tests`: eighteen on `after/`, 14/3/1, offline); carried to U39.
  `PROMISE-LEDGER-2026-11-01.md` is not edited here.
- **No pinned sentence of 34's own** (the brief's §LEDGER); the DDL sentence (R.252) moves here, and every later unit cites this lesson
  by its title.
- **`after/` is Section 5's frozen anchor; Section 6 builds over it; U36's first migration carries the index** (CARRIED).

## RE-MEASURE — the brief's items this unit settles

- **8 (TiffinBox B/A on PostgreSQL with generated pauses):** settled — `anchor`: B, A, A′ on fresh databases, the generator after
  readiness on a second connection, counted back; `pg_indexes` and the plan of the lazy collection's own statement on the anchor's own
  tables through the shipped `Database`.
- **9 (T over at least ten PostgreSQL JVMs in alternated rounds; the `SQL_SLOW` chip with the configured value read off the run and the
  margin line):** settled — twelve JVMs per database in each run of record, alternated rounds, T fixed from a measuring run before them,
  the table and both margin lines above; the configured value read off the EntityManagerFactory.
- **10 (the exercise as README + SOLUTION files, bash + zsh, `env -i`):** settled — `exercise`.
- **14 (p6spy's H2 failing start beside the fixed run; the raw-copies count before and after the mask):** settled — `spy`.

## What differed from the brief

- **TiffinBox ran on PostgreSQL for `anchor` (RE-MEASURE 8)** — the brief planned it for U39; 34 needs it because the sequential scan
  is PostgreSQL's alone (H2 indexes the foreign key itself). The shipped `Database` had run on PostgreSQL inside 31-33's harness; here
  TiffinBox's own start on the container's fresh database was ready on `before/`, `after/` and A′, with nothing changed in the anchor
  beyond C3. **How the password reached it:** neither `SPRING_DATASOURCE_PASSWORD` nor a `spring.config.import` flag — `Database` opens
  its own `DriverManager` connection with `sa` and an empty password, so the password must ride in `tiffinbox.jdbc-url` itself (unit 06's
  finding); the script writes that URL into the tree's own config tree, `secrets/tiffinbox/jdbc-url` (mode 0600), which the anchor's
  `application.yaml` already imports (`optional:configtree:./secrets/`). On no command line, in no environment. Hibernate's start-up line
  that prints the URL (password included, unit 06's `HHH10001005`) is kept out of the log by `--logging.level.org.hibernate.orm.connections.pooling=warn`;
  the raw password count in every TiffinBox log is 0, asserted before any mask. The file is deleted after each start.
- **TiffinBox's start on PostgreSQL** uses unit 06's class-path form (`java -cp "<extracted jar>:lib/*:<the driver from .m2-demo>"
  com.tiffinbox.web.TiffinBoxServer`, `L_TPG`), not the README's `java -jar` line: the jar's class path holds no PostgreSQL driver
  (TiffinBox declares none).
- **The H2 TCP server's port, 20137** — the brief's band gives the server no port (as 31 and 33 found); 20137 is free in it and asserted.
  It serves only the seven (TiffinBox on H2 over TCP, 31's form). 20134-20136 and 20139 were never bound: `spy` and `dsproxy` run in the
  harness, so p6spy's failing start is the harness JVM's own exit 1 with the `28000-250` line, not a TiffinBox start on 20134.
- **The `ways` beat counts no `HTE_` line** — the brief's "3 `HTE_` lines at start" were the probe's harness entities' temporary tables
  (`w_customer`, `w_pause`, `x_seq`); this harness maps the anchor's two entities alone, and the count printed is 0. The read's two
  `Hibernate:` lines are counted between the step's markers as the brief asks.
- **The OFF run's version line:** `HHH000001` is absent from that one JVM by design (every `org.hibernate` logger off is what it
  measures); its three `PROBE` version lines are there, and every other JVM carries `HHH000001` from a run option
  (`--logging.level.org.hibernate.orm.core=info`) rather than a logback pin (RED #1509).
- **T = 7, not the probe's figures:** the measuring run (alternated, six JVMs per database plus the development passes, before the runs
  of record) printed PostgreSQL ratios from a little over nine to a little under twelve — lower than the probe's grouped 13.4-13.7 (an
  order effect, as RED #1510 predicted on H2) — under a load of 4-5. T = 7 is the largest integer with a margin of at least 2 below the
  smallest; a margin of 1 (T = 8) was refused as too close for 36 more JVMs on a loaded machine. The measuring run's table is kept in
  the session's scratch folder (`measure-slow.table`), not here.
- **The `SQL_SLOW` chip is tabled, not hashed** (the brief's "K lines without, 0 with"): at 5, one measuring-run JVM logged only a part of
  its lookups without the index (their figures sit at the configured value, RED #1505's histogram); a development pass at 3 printed one
  line with the index in one JVM of twelve, and the first sealed-clone pass at 5 printed two in one JVM (its capture drifted and the run
  stopped). "0 with" is therefore not a fact of this machine: both counts go to the table, and the check asserts more than 0 without the
  index and more without than with, per PostgreSQL JVM. The configured value stays the brief's 5. The three runs of record were run again
  on the script with this change.
- **The plans' id is 1004, not the probe's 1000:** the plans bind the id the run reads for `Customer 0001000` (the seed's four come first),
  printed by the run.
- **`seven` on H2 over TCP** (the brief's form for 34) rather than TiffinBox's own in-memory database (31's): the md5 is the same, and the
  SQL lines during the seven are the same on both trees.
- **The `slow` capture and the anchor's plan explain different statements of the same shape:** `slow` times the JPQL lookup the brief
  names (its alias `pe1_0`); `anchor` explains the lazy collection's own statement as TiffinBox's Hibernate sent it in `ways` (its alias
  `p1_0`). Both filter on `customer_id`, and both plans flip the same way.
- **Check plants on captures, not full receipt runs, for the late checks** (see Planted faults): a full mirror run per plant takes a
  whole run; the prose and gate plants are true receipt runs on a mirror (they stop before any build), the check plants feed `chk34.py`
  the capture a planted run would print.
- **Not measured:** the decorator starters for a `DataSource` (no capture prints them — not named); a slide's own `explain` form beyond the
  plan pair; TiffinBox on PostgreSQL for any route but `/dashboard`.

## Planted faults — each caught (R.65, R.226)

On a scratch mirror of this folder (its files, its captures and `.m2-demo` cloned, the sibling units linked, a git repository of its
own), 2026-11-15 from 14:29 CET. **Receipt plants** — each edits one file of the mirror, runs its `receipts.sh` `env -i`, and puts the
file back; each stops before any build, so nothing is written (the gate that stopped it, shortened):

```
P1  "slow" on an H2 sentence (S5.11): exit 1 - the prose gate: dur7: slow; S5.9/S5.11 a duration word in a sentence about H2
P2  "slow" beside the SQL_SLOW chip without the threshold line (S5.11): exit 1 - the prose gate: dur7: slow
P3  an H2 ratio characterised, "makes no difference" (S5.9): exit 1 - the prose gate: S5.9 a verdict on a ratio
P4  "ten times quicker", the family unscoped (S5.18): exit 1 - the prose gate: dur7: quicker; R.301's family: ten times
P5  a typed hash in prose (R.302, R.252): exit 1 - the prose gate: R.302/R.252 a typed md5
P6  the plan's costs typed on a README line (R.245): exit 1 - the prose gate: R.245 a plan's cost or rows in prose: cost=
P7  a typed jar count (R.302): exit 1 - the prose gate: R.302 a jar or byte count typed
P8  a dish name (R.215): exit 1 - an Indian dish name (R.215: English names only)
P9  a placeholder line: exit 1 - a placeholder line in this unit's prose
P10 a typed SQL string outside the captured blocks (R.225): exit 1 - a typed SQL string or plan line in the prose
P11 a grouped timing described as the design (S5.17): exit 1 - the prose gate: S5.17 a grouped timing as the design
P12 a raw password URL in prose (S5.12): exit 1 - the prose gate: S5.12 a password or a raw p6spy line in prose
P13 "no log level silences show-sql" without the OFF run's control (S5.13): exit 1 - the prose gate, per paragraph
P14 the developer boundary named twice: exit 1 - the prose gate: named once
P15 the old md5 kept as current in after/'s README (R.250, R.252): exit 1 - R.250: a sentence C3 makes false is still in after/
P16 the @Index left out of after/'s PauseEntity (C3): exit 1 - C3: after/'s PauseEntity names the index in its @Table
P17 18/18 as a witness (R.190): exit 1 - the prose gate: R.190 the 18 tests as a witness
P18 a call-back without its title (R.224): exit 1 - the prose gate: R.224 a call-back without its title
```

**P16, which check catches it first:** the R.250 / C3 gate, before any build. Behind it, `xcheck` would print the old script (`before/`'s
script — the one without `@Index` — is the old md5, printed in every run). **A's index list would not catch it**, against the prompt's
expectation: `Database` creates the index by hand, so `pg_indexes` on A still lists it without the annotation; A's list catches the other
half of C3 (the `CREATE INDEX` line left out), which is check plant C7's reading.

**Check plants** — `harness/chk34.py` fed a scratch copy of a capture edited as the planted run would print it (the unedited captures
pass the same checks, exit 0):

```
C1  the grouped (un-alternated) timing: exit 1 - R.300 - even rounds without -> with, odd rounds with -> without
C2  the OFF option dropped: exit 1 - (ii) the control: effective level OFF, isDebugEnabled() false, org.hibernate OFF - got DEBUG, true, WARN
C3  p6spy's H2 failing-start step dropped: exit 1 - three JVMs: H2 without the user name, H2 with it, PostgreSQL (the 28000-250 grep finds nothing)
C4  an unmasked spy.log line (the URL with a password): exit 1 - PostgreSQL: a masked line carries the URL with password=<pw>
C5  a PostgreSQL ratio below T in the README's table: exit 1 - every PostgreSQL ratio >= T = 7 (below it: [6.95])
C6  B's explain fed A's plan (an index scan): exit 1 - B (the failure receipt): a sequential scan and its removed rows
C7  A's index list fed B's ([pause_pkey]): exit 1 - A: pg_indexes on pause, the shipped Database made the index
C8a no Framework version line: exit 1 - the version line once in the JVM (S4.13)
C8b no HHH000001: exit 1 - HHH000001 once in the JVM (S4.13)
C9  H2's plan fed the new index: exit 1 - H2: one plan both sides, its constraint index - the new index unused
C10 no SQL_SLOW line without the index on a PostgreSQL JVM: exit 1 - more than 0 without the index, and more without than with, in every JVM
```

**The R.211 note:** a byte added to the mirror's `after/pom.xml` — the script prints `(after/ and ../c7-tiffinbox differ - the anchor has
moved past the tree this unit froze: Files after/pom.xml and ../c7-tiffinbox/pom.xml differ)` and `the anchor (start): after/ is this
unit's tree (C3) - a later anchor change has moved ../c7-tiffinbox on` and goes on (a note, never a stop; interrupted there, exit 130,
nothing left, the byte taken back). **The mask's self-test** runs on planted lines (the password in a p6spy line among them) before any
capture in every run; **the password in a log** is caught by the raw counts (`raw password copies in its log: 0` per PostgreSQL JVM, the
TiffinBox logs' `the password 0 times`, and the hygiene pass over every capture and log).

Not run as plants (each needs a whole run on the mirror): a wrong published hash in `receipts.md5` (the `pub` step — every run of record
printed `= published` against it), a changed What-it-prints line and the exercise's solution set equal to the broken block (the `exercise`
capture's own checks); the drift checks were exercised for real twice (the `SQL_SLOW` passes, What differed).

## The anchor moved on — the re-run of 31 (R.211, RED #1200)

`grep -n c7-tiffinbox` before the commit (R.211, the brief's EVIDENCE BATCHES), over `_builders/*.py`,
`~/Desktop/PromptVidya-Automation/check_unit7.py` and `qa_java7.py`: the same 22 builders 31's README lists — `s701.py`-`s707.py`,
`s709.py`, `s715.py`, `s716.py` (each reads `git show <sha>:c7-tiffinbox/…`), `s717.py`-`s728.py` (each asserts its `after/` against `git
show <sha>:c7-tiffinbox/<p>` and prints a `note:` line per live difference); `check_unit7.py` and `qa_java7.py` — no line; no `s729`…`s734`
exists yet (Section 5's scripts are not written). **`s717.py` run once after the move** (a scratch copy with `_builders/dur7.py` beside it,
so its `OUT` is the copy's folder and nothing is written into the course; `~/.venvs/slides2video/bin/python s717.py`): exit 0, **thirteen**
`note: c7-tiffinbox has moved on since f620c1a …` lines (31 saw twelve; C3 touches two files, and `Database.java` was already among the
twelve, so the one new line is `PauseEntity.java`), then `anchor: after/ = f620c1a:c7-tiffinbox in its 4 changed files; diff -rq against
the live c7-tiffinbox: 13 lines` — the expected sign.

**`../c7-unit31/receipts.sh`** (unchanged: its `md5 -q` is the one 31's README names) — the previous anchor-change unit — run once on the
moved anchor, `./receipts.sh` (/bin/bash 3.2.57), `env -i`, from 12:07 CET: **exit 0 in 306 s**; its note at its start and its end
(`(after/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit froze: Files after/README.md and
../c7-tiffinbox/README.md differ;Files after/…/Database.java and …;Files after/…/PauseEntity.java and …`), all 9 captures 3/3 = published,
`receipts.md5` unchanged (`md5 -q` the same before and after), its log through `check_unit7.py 31 --runlog` PASS. 32, 33,
30 and 29 were not re-run (RED #1200: their notes fire the same way; 32's and 33's `anchor` link to `../c7-unit31/after`, 30's to
`../c7-unit29/after` — neither moved). 32's and 33's tree pins were run once (`python3 -I harness/tree32.py anchor/`, `tree33.py`): both
print the pinned hash. The dated "Re-run after unit 34 moved the anchor" paragraph is in `../c7-unit31/README.md` (its own "34 moves the
anchor next (C3)" sentences stay true and are not edited).

## CARRIED

- **The index in the migration** — U36 (*Flyway: Versioned Migrations*): its V1 must carry `pause_customer_id_idx` (and 27's `version NOT
  NULL DEFAULT 0`).
- **The time-meaning family (S5.18 / R.301)** — carried in `harness/s34.py` (BLUE's `tm.py` regexes, copied); `dur7.py` untouched.
- **p6spy's URL leak** — Course 18 (secrets in logs), if its brief wants a call-back; not a promise.
- **`Database`'s seed and its `DriverManager` path** (C7-1 cause 2) — U36 and U39, unchanged here.

## For RED

- **The ratio is a design's, not a fact about Postgres:** M 50 lookups of a hundred pauses each per half, over the generator's rows; another table size,
  another M, another machine moves it. T = 7 is asserted, not the ratio; the video says the threshold line and "on this Mac".
- **The alternated PostgreSQL ratio sits below the probe's grouped one** (see What differed): the grouped design put every "with" round
  after the "without" rounds had warmed the JVM and the database. The H2 side shows the same order effect the other way round (BLUE's
  grouped H2 figure against the alternated ones in this table).
- **`SQL_SLOW` is a chip:** its count depends on the configured value and on where each lookup's execute time falls against it; the
  measuring run showed it riding on 5. It never carries the lesson's verdict word — that word is gated on the threshold line (s34).
- **The plan pair is from `explain (analyze …)`:** it runs the statement. Its heap-blocks line follows the generator's layout (one
  `INSERT … SELECT` per pause number, so a customer's hundred pauses sit in a hundred blocks); the plans are equal in every JVM of a run and
  across the three runs (the capture's md5) — if another layout moved that line, the 3/3 would catch it.
- **H2's second index is unused, said as captured:** H2's planner picks its own constraint index on both sides; the new index is in the
  catalogue and in no plan. Nothing here says more of H2's lookups than the printed numbers on the chip.
- **The OFF run proves the level took, not that nothing else prints:** it prints the effective level, `isDebugEnabled()` and the count of
  `org.hibernate` logger lines (0) beside show-sql's two lines; Boot's and Spring's own INFO lines are not Hibernate's and are not counted.
- **p6spy's H2 refusal is Boot's default user, not p6spy's:** Boot gives `sa` to an embedded URL only; `jdbc:p6spy:h2:mem:…` does not look
  embedded, so the pool connects with no user and H2 refuses it. The same refusal is BLUE's on a TCP URL (RED #1511).
- **TiffinBox on PostgreSQL holds its password in its config tree for the life of one start** (`.harness/<tree>/secrets/tiffinbox/jdbc-url`,
  mode 0600, deleted after the stop); a later unit that runs TiffinBox on PostgreSQL may prefer a URL without the password and a pool
  password — `Database`'s own `DriverManager` connection is the reason this one cannot (C7-1 cause 2, carried to U36/U39).
- **Not measured here:** the plan with a covering or a composite index; `lower(name)` or `@Enumerated` defeating an index (no TiffinBox
  query does either — ⚑6's losers); the dashboard's own plan (its read is a join over every customer).
