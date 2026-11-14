# c7-unit30 — N+1, Measured

Course 7 · Data with JPA & Hibernate · Section 5 (Performance), its second unit. **No change to the anchor** (brief ⚑1): `anchor` is
the link to `../c7-unit29/after` — TiffinBox as unit 29 left it, `../c7-tiffinbox` at unit 29's commit — and nothing here edits it;
**unit 31 moves the anchor next** (C2); 30 never touched it. Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.2**
(Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate ORM 7.4.13.Final), 2026-11-14, **on H2 2.5.250** only (brief ⚑7: every count
here is H2's; the probe's PostgreSQL run printed the same counts, and this unit does not re-run it). One query lists the customers;
then Hibernate runs one more for each customer whose pauses the page reads. The count grows with the list — and the counter you might
reach for first, the count of queries, does not see it.

**The anchor does not change.** `receipts.sh` hashes the anchor's tree (`harness/tree30.py`: every file's path and md5, 43 files) and
dies unless it is the tree unit 29 committed — a shipped unit's `after/` is frozen, so a byte added there is a failed receipt (R.211). It
also prints `diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox` at its start and end — empty in every run of
record — and, should a later unit move the anchor (31 will), prints a note instead, never a stop. The anchor is copied under `.harness/`
and built there with its README's package line, offline (its 18 tests run: a guard, R.190); the harness runs over the copy's
extracted libraries (91).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 7 captures, 3 runs each; every spoken number checked after its capture; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version` and `javac -version` say 25.) It **dies** when a
check after a capture fails, and when a capture's md5 differs from `receipts.md5`. **Start it in a process group of its own** (a
terminal's foreground job is one): `sweep()` stops only processes of its own group. `.m2-demo` must be seeded first (below).

<!-- runs: begin -->
**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`), a session of its own
(`perl -MPOSIX -e 'setsid; exec @ARGV'`), `.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681
files). Development runs fixed the captures and the checks; a full passing run wrote every capture 3/3 with the same md5s as the
development passes, and those are `receipts.md5`. **The runs of record, on the script as committed (`receipts.sh` md5
`ff1f10000cb0d5578a3ea554fa7cdd75`): 180 s under `./receipts.sh`** (/bin/bash 3.2.57, 2026-11-14 from 18:22 CET), **185 s under `bash
receipts.sh`** (Homebrew bash 5.3.9, from 18:26 CET) **and 188 s from a sealed fresh clone** (below, from 18:29 CET): each exit 0, all 7
captures 3/3 = published, every check passed, both Maven runs `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`, the
anchor's tree = pinned and the anchor note empty at the start and the end, nothing listening on 20090-20099 at the end; each terminal
log through `check_unit7.py 30 --runlog` — `RESULT (run logs): PASS` (the unit gate: no 30 script yet). **Nothing was downloaded.**

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at `9714b74` into a path **with a space** (`…/sealed
30/tiffinbox-java`, in the session's scratch folder), this commit's 24 files put in as git will take them (`git ls-files -o
--exclude-standard c7-unit30`, the `anchor` link kept); the clone's `.m2-demo` seeded from a file copy of the seed; dead proxies for http
and https in its environment (`127.0.0.1:9`); `./receipts.sh` `env -i`. Every build is `-o` and printed `offline: yes` with 0
`Downloaded from` lines.
<!-- runs: end -->

Published hashes: count `34b323b926975553b748582c6c3ecc26` · page `a048532b156683e4f41a16a07949c4ba` · inverse `8a73bf493c7d434fc54af4f1fcc68f69` · nested `fc765923c01708806740872facc93975` · sql `6a64402c127b92be6fe81fd7be42512f` · xcheck `6a2ad84d24ed0be0cd98453137ae0fef` · exercise `6b7c25afec6843230e90fb30dfe95cf4`.

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line, R.225 — a SQL string
typed in this README outside this block is refused; so is either of the page's two counts typed outside this block and the text
blocks the runs printed, R.302):

<!-- values: begin -->
the values the video may say: on H2 2.5.250, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - count: at 40 customers (-Dn=36, the second connection's count): Statistics.getPrepareStatementCount 41 · org.hibernate.SQL lines 41 · JDBC proxy prepareStatement 41 · executeQuery 41 · Statistics.getQueryExecutionCount 1 · Statistics.getCollectionFetchCount 40 · Statistics.getEntityLoadCount 78 · at 10 customers (-Dn=6, the second connection's count): Statistics.getPrepareStatementCount 11 · org.hibernate.SQL lines 11 · JDBC proxy prepareStatement 11 · executeQuery 11 · Statistics.getQueryExecutionCount 1 · Statistics.getCollectionFetchCount 10 · Statistics.getEntityLoadCount 18 · derived from the two points (10 customers, 11 statements) and (40 customers, 41 statements): statements = 1 + 1 x customers (one plus one per customer) · the count of queries 1 at both N, the statement count moves with N · the read-only read's session (HHH000401, 40 customers): <ns> ns preparing 41 JDBC statements · <ns> ns executing 41 JDBC statements · <ns> ns executing 0 flushes (flushing a total of 0 entities and 0 collections); the control (labelled, read-write): <ns> ns executing 1 flushes (flushing a total of 78 entities and 40 collections) · page: TiffinBox on H2 over TCP - POST /customers/import of 36 generated lines -> 200, added 36, 36 SQL lines during it (one INSERT each, IDENTITY); GET /dashboard (HTML and JSON) -> 200, 44 SQL lines in the whole request (its sessions: 4, preparing 1 1 1 41), the read's own session (pausedDaysByCustomer): preparing 41 JDBC statements, executing 41, no flush; GET /customers -> 200, 1 SQL line, 40 entries; Paused days Meera 0 · Priya 2 · Ravi 0 · Sunil 3, every imported customer 0 · inverse: at 38 pauses (40 customers, -Dn=36): Statistics.getPrepareStatementCount 39 · org.hibernate.SQL lines 39 · JDBC proxy prepareStatement 39 · Statistics.getEntityFetchCount 38 · Statistics.getQueryExecutionCount 1 · at 8 pauses (10 customers, -Dn=6): Statistics.getPrepareStatementCount 9 · org.hibernate.SQL lines 9 · JDBC proxy prepareStatement 9 · Statistics.getEntityFetchCount 8 · Statistics.getQueryExecutionCount 1 · derived from the two points (8, 9) and (38, 39): statements = 1 + 1 x pauses · nested: at 40 customers (-Dn=36): Statistics.getPrepareStatementCount 41 · org.hibernate.SQL lines 41 · JDBC proxy prepareStatement 41 · Statistics.getCollectionFetchCount 40 · Statistics.getEntityLoadCount 78 · at 10 customers (-Dn=6): Statistics.getPrepareStatementCount 11 · org.hibernate.SQL lines 11 · JDBC proxy prepareStatement 11 · Statistics.getCollectionFetchCount 10 · Statistics.getEntityLoadCount 18 · derived from the two points (10, 11) and (40, 41): statements = 1 + 1 x customers · sql: the list's statement (sent 1 x): select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal,ce1_0.version from customer ce1_0 order by ce1_0.name · the pauses' statement (sent 40 x, one per customer): select p1_0.customer_id,p1_0.id,p1_0.days from pause p1_0 where p1_0.customer_id=? · xcheck: 9cf92b8cae3abfd0f1c0706bfe7a4373 · exercise: the README: 10 diners 1 · 40 diners 1; the solution: 10 diners 11 · 40 diners 41 (24 words) · pinned.txt: ad7bd3fe8510b8199ff33833b6715ee6
<!-- values: end -->

## The count, at two N (`count`; S5.1, R.249)

The harness (brief ⚑3) is a Spring Boot context with no web server over the anchor's libraries: the shipped `Database` seeds its four
customers and two pauses into this JVM's own H2, then unit 20's generator (`harness/src/probe/v/Gen.java`, on a second connection, outside
Hibernate) adds `-Dn` customers — `Customer 0000001`…, meal types cycling, a price of 100 — by one JDBC batch, and one pause of one day
for each of them by one `INSERT … SELECT`; the second connection then counts the customers and the pauses back (a count over each table,
S3.12 — the count is read, never computed). The page's read is the anchor's own: `findAll(Sort.by("name"))` through Spring Data, then
every customer's pauses, in a **read-only** `TransactionTemplate`. Each step clears Hibernate's statistics first and prints three
witnesses after it — `Statistics.getPrepareStatementCount()`, the `org.hibernate.SQL` logger's events counted by an appender, and a
JDBC proxy around Boot's pool counting `prepareStatement` (and `executeQuery`) — with Statistics' other counters beside them, each under
the name of the method it came from. The receipt runs **N = 36 and N = 6** and derives the line from the two points; it prints:

```text
  at 40 customers (-Dn=36, the second connection's count): Statistics.getPrepareStatementCount 41 · org.hibernate.SQL lines 41 · JDBC proxy prepareStatement 41 · executeQuery 41 · Statistics.getQueryExecutionCount 1 · Statistics.getCollectionFetchCount 40 · Statistics.getEntityLoadCount 78
  at 10 customers (-Dn=6, the second connection's count): Statistics.getPrepareStatementCount 11 · org.hibernate.SQL lines 11 · JDBC proxy prepareStatement 11 · executeQuery 11 · Statistics.getQueryExecutionCount 1 · Statistics.getCollectionFetchCount 10 · Statistics.getEntityLoadCount 18
  derived from the two points (10 customers, 11 statements) and (40 customers, 41 statements): statements = 1 + 1 x customers (one plus one per customer)
```

**The failure receipt (S5.1):** `Statistics.getQueryExecutionCount()` reads the same at both N while the statement count moves with N —
it counts the JPQL and HQL queries Hibernate ran (the list's one), and a collection load is not a query. A test that asserted it would
pass on the N+1. `chk30.py count` asserts the three witnesses equal at each N, the count of queries the same at both N and different
from the statement count, `getCollectionFetchCount()` equal to the customers the second connection counted, `getEntityLoadCount()`
equal to customers plus pauses, and the line derived from the two points — "one plus one per customer" is derived, never typed, and a
run with one N fails the derivation (R.249). The statement counter is named on its command line (`--counter`): fed
`Statistics.getQueryExecutionCount` instead, it exits 1 (planted, below).

**The session metrics (RE-MEASURE 12, settled):** with `org.hibernate.session.metrics` at DEBUG (a run option) Hibernate logs one block
per session at its close (`HHH000401: Logging session metrics:`). The page's read, read-only, logs a block with no flush at its commit;
the read-write control — the same read in a read-write `TransactionTemplate`, labelled, one more step in the same JVM — flushes every
entity and collection it loaded. Each time figure is masked (`<ns>`); the blocks the context's own start logs (each reading 0) are
counted, not shown:

```text
  PROBE >>> the page: findAll(Sort.by("name")), then every customer's pauses - in a read-only transaction
  DEBUG [main] org.hibernate.session.metrics : HHH000401: Logging session metrics:
      <ns> ns preparing 41 JDBC statements
      <ns> ns executing 41 JDBC statements
      <ns> ns executing 0 flushes (flushing a total of 0 entities and 0 collections)
  PROBE counts: Statistics.getPrepareStatementCount 41 · org.hibernate.SQL lines 41 · JDBC proxy prepareStatement 41 · JDBC proxy executeQuery 41 · Statistics.getQueryExecutionCount 1 · Statistics.getCollectionFetchCount 40 · Statistics.getEntityLoadCount 78 · Statistics.getEntityFetchCount 0 · Statistics.getConnectCount 1 · JDBC proxy getConnection 1
  PROBE >>> the control, labelled: the same read in a read-write transaction
  DEBUG [main] org.hibernate.session.metrics : HHH000401: Logging session metrics:
      <ns> ns preparing 41 JDBC statements
      <ns> ns executing 41 JDBC statements
      <ns> ns executing 1 flushes (flushing a total of 78 entities and 40 collections)
  PROBE counts: Statistics.getPrepareStatementCount 41 · org.hibernate.SQL lines 41 · JDBC proxy prepareStatement 41 · JDBC proxy executeQuery 41 · Statistics.getQueryExecutionCount 1 · Statistics.getCollectionFetchCount 40 · Statistics.getEntityLoadCount 78 · Statistics.getEntityFetchCount 0 · Statistics.getConnectCount 1 · JDBC proxy getConnection 1
```

## On TiffinBox (`page`; S5.2)

TiffinBox itself, on the anchor's jar (port 20090) and on the anchor copied and built again (A′, port 20091), its database on an **H2
TCP server** (127.0.0.1:20098, only local connections, `-ifNotExists`) so that a second connection — H2's own `Shell` — counts what
TiffinBox stored; `--spring.datasource.username=sa` with the TCP URL (unit 29 filed the `28000-250` start without it, its `anchor`
capture; not re-filed here). Run options only: the SQL logger, the transaction manager and the session metrics at DEBUG, Hibernate's
statistics on. The import's file is unit 20's generator again (`harness/csv30.py`, N = 36 lines and a header, `name,mealsPerDay,
pricePerMeal,mealType`), sent by `curl -F` to `POST /customers/import`. Each request runs between two markers the script appends to
TiffinBox's log, and `harness/seg30.py` reads the lines between them: the request's SQL lines, the session-metrics blocks it closed, and
**the read's own session** — the virtual thread whose transaction manager line is `Creating new transaction with name
[com.tiffinbox.CustomerRepository.pausedDaysByCustomer]`, from that line to the first session-metrics block on the same thread. A count
on this page always names its scope: **the whole request** (the SQL lines between its markers — the dashboard's four reads, four
sessions) or **the read's session** (its block). Nothing is batched: the anchor's ids are IDENTITY, so the import is one INSERT per line,
each its own transaction and session (unit 26's `add`) — no batch claim (R.206). No pause is imported, so every imported customer's
"Paused days" is 0. It prints:

```text
  the generated file: .harness/import.csv - a header and 36 lines (wc -l: 37)
$ curl -s --noproxy '*' -F 'file=@.harness/import.csv;type=text/csv' http://127.0.0.1:20090/customers/import
  -> 200 {"file":"import.csv","added":36,"refused":{}}
  between its markers: SQL lines 36 (INSERTs into customer 36) · WARN lines 0 · ERROR lines 0
  session-metrics blocks (HHH000401) it closed: 36 · their 'preparing N JDBC statements', N by N: 1 x36
$ curl -s --noproxy '*' -H 'Accept: text/html' http://127.0.0.1:20090/dashboard
  -> 200
  between its markers: SQL lines 44 (INSERTs into customer 0) · WARN lines 0 · ERROR lines 0
  session-metrics blocks (HHH000401) it closed: 4 · their 'preparing N JDBC statements', N by N: 1 x3 · 41 x1
  the read's session - its thread's lines from 'Creating new transaction with name [com.tiffinbox.CustomerRepository.pausedDaysByCustomer]' to that thread's next session-metrics block: SQL lines 41 · 'Participating in existing transaction' 1 · the block (HHH000401), each time figure masked:
    <ns> ns preparing 41 JDBC statements
    <ns> ns executing 41 JDBC statements
    <ns> ns executing 0 flushes (flushing a total of 0 entities and 0 collections)
  the table: the header 'Paused days' is column 6 · rows 40 · the seeded customers: Meera 0 · Priya 2 · Ravi 0 · Sunil 3 · the imported ('Customer …'): 36, Paused days 0
$ curl -s --noproxy '*' -H 'Accept: application/json' http://127.0.0.1:20090/dashboard
  -> 200
  between its markers: SQL lines 44 (INSERTs into customer 0) · WARN lines 0 · ERROR lines 0
  session-metrics blocks (HHH000401) it closed: 4 · their 'preparing N JDBC statements', N by N: 1 x3 · 41 x1
  the read's session - its thread's lines from 'Creating new transaction with name [com.tiffinbox.CustomerRepository.pausedDaysByCustomer]' to that thread's next session-metrics block: SQL lines 41 · 'Participating in existing transaction' 1 · the block (HHH000401), each time figure masked:
    <ns> ns preparing 41 JDBC statements
    <ns> ns executing 41 JDBC statements
    <ns> ns executing 0 flushes (flushing a total of 0 entities and 0 collections)
  the JSON (python3 -I): customers 40 · names 40
$ curl -s --noproxy '*' -H 'Accept: application/json' http://127.0.0.1:20090/customers
  -> 200 · entries parsed (python3 -I): 40
  between its markers: SQL lines 1 (INSERTs into customer 0) · WARN lines 0 · ERROR lines 0
  session-metrics blocks (HHH000401) it closed: 1 · their 'preparing N JDBC statements', N by N: 1 x1
```

`chk30.py page` asserts: the import's `added` = the generated file's lines = its INSERTs = its sessions; each dashboard request's SQL
lines = the sum of its sessions' `preparing` figures, the read's block's `preparing` = `executing` = its thread's SQL lines = 1 + the
customers the second connection counts, no flush (the read is `@Transactional(readOnly = true)`), `findAll` joining it
(`Participating`); `GET /customers` one SQL line and as many entries as the second connection counts; the "Paused days" column found by
its header, the four seeded customers' values equal to the second connection's sums, every imported row 0; A′ printing what A printed.
The seven (`466c20ed…`, unit 29's) are not re-run here: the import changes the JSON bodies, and 29's hash stands for the seeded tree.

## The inverse, and the nested projection (`inverse`, `nested`)

The inverse: every pause by one JPQL query, then each pause's customer's name — each customer a lazy proxy, initialised by its own
SELECT by id (`Statistics.getEntityFetchCount()` = the pauses). The nested projection is unit 19's `WithPauses` (`getName()`,
`List<DaysOnly> getPauses()`), its shape copied exactly into `harness/src/probe/v/repo/Proj.java`, through
`findAllProjectedByOrderByNameAsc()` in a read-only transaction: Spring Data loads the entities and their collections, so the nested
projection is one plus one per customer too — S3's CARRIED "1 + N", measured. Both at both N, both lines derived:

```text
  at 38 pauses (40 customers, -Dn=36): Statistics.getPrepareStatementCount 39 · org.hibernate.SQL lines 39 · JDBC proxy prepareStatement 39 · Statistics.getEntityFetchCount 38 · Statistics.getQueryExecutionCount 1
  at 8 pauses (10 customers, -Dn=6): Statistics.getPrepareStatementCount 9 · org.hibernate.SQL lines 9 · JDBC proxy prepareStatement 9 · Statistics.getEntityFetchCount 8 · Statistics.getQueryExecutionCount 1
  derived from the two points (8, 9) and (38, 39): statements = 1 + 1 x pauses
  at 40 customers (-Dn=36): Statistics.getPrepareStatementCount 41 · org.hibernate.SQL lines 41 · JDBC proxy prepareStatement 41 · Statistics.getCollectionFetchCount 40 · Statistics.getEntityLoadCount 78
  at 10 customers (-Dn=6): Statistics.getPrepareStatementCount 11 · org.hibernate.SQL lines 11 · JDBC proxy prepareStatement 11 · Statistics.getCollectionFetchCount 10 · Statistics.getEntityLoadCount 18
  derived from the two points (10, 11) and (40, 41): statements = 1 + 1 x customers
```

## The SQL (`sql`)

The page's two statement texts, read off Hibernate's SQL logger and each shown once; how many times each was sent is counted by the
receipt, never listed. They are in the values block above (R.225: a SQL text in this README sits there alone).


## The DDL did not move (R.252, `xcheck`)

Hibernate's script over the anchor's libraries is `9cf92b8cae3abfd0f1c0706bfe7a4373`, `cmp` equal to `xcheck.sql` (filed here, a copy of
`../c7-unit29/xcheck.sql`, itself unit 27's): **the same hash as in the lesson called Optimistic Locking with At-Version.**

## Pinned sentences (R.252)

Byte-equal in this unit's script and in the units that consume them; `pinned.txt` holds the three lines below and `receipts.sh` checks
its md5 (`ad7bd3fe8510b8199ff33833b6715ee6`) and each line, whole, in this README. Unit 39's agent and Course 17's diff against `pinned.txt`.

- Unit 39's counter sentence (the test that asserts the query count; Course 11 U14 *The Persistence Layer* is another consumer of the
  counter, `TRACK-ROADMAP.md:492`):

```pinned
Hibernate's statistics count every statement it prepares; the count of queries leaves out the collection loads.
```

- Course 17 U06's sentence, named forward by its title — on screen *The N+1 Problem and DataLoader* as `TRACK-ROADMAP.md:728` spells it,
  the voice says "N plus one":

```pinned
One query for the list and one more for each row is the N plus one, whatever sends the extra queries.
```

- The counter:

```pinned
SessionFactory.getStatistics().getPrepareStatementCount()
```

## Call-backs, by title (R.224)

- Course 2 U36 *Transactions and Batches: All or Nothing* (`~/Desktop/PromptVidya-Automation/java2_series.py:81`, read): statements
  were already a thing you counted.
- *Projections: Four Kinds* (Course 7 U19): its nested projection, measured here at scale (its README's CARRIED line).
- *Paging and Sorting* (Course 7 U20): the generator — `Customer 0000001`…, one JDBC batch, counted back on a second connection.
- *Lazy Loading and LazyInitializationException* (Course 7 U29, `java7_series.py`): the page and its read's transaction this unit counts;
  its script is written after this evidence, so it is named by title only.
- *Optimistic Locking with At-Version* (Course 7 U27): the DDL hash sentence.
- Forward: Course 17 U06 *The N+1 Problem and DataLoader* (title only); unit 31 *JOIN FETCH vs @EntityGraph vs @BatchSize* moves the
  anchor next and owns "the same page at 2" (SUBSELECT's).

## The commands this unit adds

The harness, compiled once against the anchor's extracted libraries; its JVM, its arguments in two arrays (`V` the flags — `-Ds` the
scenario, `-Dn` the generator's N — `A` the arguments, R.193); `xcheck`'s JVM; the H2 server; its `Shell` (the second connection; `$DB`
the run's database name, `$Q` the query); the import's file and its POST (the port changed for A′):

```
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/src/probe/v/Gen.java harness/src/probe/v/H.java harness/src/probe/v/Main.java harness/src/probe/v/Run.java harness/src/probe/v/Seed.java harness/src/probe/v/SqlCounter.java harness/src/probe/v/repo/Proj.java harness/src/probe/x/XMain.java
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.v.Main "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.x.XMain "${A[@]}"
cd .harness/run && exec perl -e 'alarm 3000; exec @ARGV' java -Duser.language=en -Duser.country=US -Dh2.bindAddress=127.0.0.1 -cp "../anchor/tiffinbox-web/target/extracted/lib/h2-2.5.250.jar" org.h2.tools.Server -tcp -tcpPort 20098 -ifNotExists
cd .harness/run && perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../anchor/tiffinbox-web/target/extracted/lib/h2-2.5.250.jar" org.h2.tools.Shell -url "jdbc:h2:tcp://127.0.0.1:20098/mem:$DB" -user sa -password '' -sql "$Q"
python3 -I harness/csv30.py "$N" > .harness/import.csv
curl -s --noproxy '*' -F 'file=@.harness/import.csv;type=text/csv' http://127.0.0.1:20090/customers/import
```

TiffinBox itself runs the anchor README's own line (`java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431`,
read from `anchor/README.md` and asserted whole), its port changed, under the alarm with the locale pinned, followed by
`--tiffinbox.jdbc-url=…`, `--spring.datasource.username=sa`, `--logging.level.org.hibernate.SQL=debug`,
`--logging.level.org.springframework.orm.jpa.JpaTransactionManager=debug`, `--logging.level.org.hibernate.session.metrics=debug` and
`--spring.jpa.properties.hibernate.generate_statistics=true` (printed whole in its capture).

## The repository, and the network

Every Maven run is `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681 files; = s4 = unit 29's; the brief allows s3 or s5 for 30 — s3 has
every class this unit runs). Two Maven runs before the captures — the anchor with its tests (its summary lines summed and asserted 18 · 0
· 0 · 0, a guard) and A′'s copy with `-DskipTests`; each `offline: yes`, 0 `Downloaded from` lines. **At run time** the harness binds no
port; its databases are H2 in its JVM's memory (`jdbc:h2:mem:u30`, xcheck's `x30`, the exercise's `ex`); TiffinBox's are on the H2
server, loopback only; TiffinBox listens on `127.0.0.1` only and is asked by `curl` on the loopback. **No network act**: the section's
dated sweep is the brief's (`_research/spring-boot-metadata-2026-11-13.xml`, `spring-data-bom-metadata-2026-11-13.xml`,
`hibernate-core-metadata-2026-11-13.xml`: no 4.1.x patch, Hibernate 7.4.15 exists and is not adopted — R.223). Spring Framework's
version is printed by every harness JVM from `spring-tx`'s manifest (`7.0.10`), beside Spring Data JPA's (`4.1.2`),
`Version.getVersionString()` and Hibernate's `HHH000001` line (S4.13), before the context starts; `chk30.py` asserts each once per JVM.

## The locale

The JVM ignores `LC_ALL` on macOS: every JVM this script starts carries `-Duser.language=en -Duser.country=US` on its java line, and the
hygiene check refuses a java line without it (and one without its alarm).

## The folders, the harness and the ports

- `anchor` → `../c7-unit29/after` (a link; `readlink` asserted, its tree hashed and pinned). Never built in place.
- `xcheck.sql` — Hibernate's script for the anchor's two entities, filed (md5 `9cf92b8c…`, = `../c7-unit29/xcheck.sql`).
- `pinned.txt` — the three pinned lines (R.252).
- `harness/` — `src/probe/v/Main.java` (a Spring Boot context, `WebApplicationType.NONE`, `@EntityScan("com.tiffinbox")`,
  `@EnableJpaRepositories({"com.tiffinbox", "probe.v.repo"})` — `Found 2 JPA repository interfaces.`; the three version lines first),
  `Run.java` (the scenarios `count`, `metrics`, `inverse`, `nested` — `-Dproj=flat` reads unit 19's flat projection instead, the plant's
  run — each step clearing the counters first and printing the three witnesses after it), `Gen.java` (unit 20's generator, on the
  second connection), `H.java` (helpers, the second connection, the JDBC proxy), `Seed.java` (the shipped `Database` on the run's
  database; Boot's pool wrapped in the proxy by a `BeanPostProcessor`), `SqlCounter.java` (the SQL logger's events), `repo/Proj.java`
  (unit 19's `WithPauses` and a flat `NameOnly`, over the anchor's `CustomerEntity`); `src/probe/x/XMain.java` (xcheck's context, unit
  29's byte for byte); `src/probe/v/ex/ExApp.java` (the exercise's, compiled only by the exercise); `chk30.py` (the checks after each
  capture), `seg30.py` (a request's lines between its markers), `csv30.py` (the import's file), `tree30.py` (the anchor's tree hash),
  `s30.py` (the prose gate); `logback.xml`; `dur7.py` (the builders', byte for byte, md5 `41667fed…`). No `Thread.sleep` in
  `harness/src` (asserted). English names only (R.215): Ravi, Meera, Sunil, Priya.
- `exercise/` — `README.md`, `SOLUTION.md`.
- `.harness/` (git-ignored, rebuilt by every run): `anchor`, `anchor2` (A′), `hc`, `run`, the logs, each request's segment, the import's
  file, the token's file (0600). `.r-NAME.1-3` while a capture runs; `.r-NAME.out` its result (git-ignored).
- **Ports (§P, 20090-20099):** 20090 `page` · 20091 `page` A′ · **20098 the H2 TCP server** · 20092-20097 and 20099 never bound; the
  harness JVMs bind none. All ten, 18425, 8080 and 35729 are checked free at the start and the end; each start checks its own port free first.

## Masks, filters and hygiene — every one, declared

Masks (awk `gsub` only, a planted self-test line before any capture): the generated token → `[masked: the token]`; this folder → `…`,
the folder above → `…/..`, home → `~`, the user name → `<user>`; ` using Java <version>`; an identity hash → `@…`; an EntityManager's
identity → `SessionImpl(<n><open>)`; a lambda class's address → `$$Lambda/<n>`; Spring Data's scan figure → `<n>`; **a session-metrics
time figure → `<ns>`** (S5.2); a virtual thread's number → `virtual-<n>`, Tomcat's handler thread's → `omcat-handler-<n>`; the H2 Shell's
row-count figure. Filters: a harness JVM's log whole, but its `org.hibernate.SQL` lines counted, not shown (the `sql` capture shows each
text once), and the session-metrics blocks outside every step (the context's own start) counted, not shown; a TiffinBox request by its
lines between its two markers, summarised by `seg30.py`; an HTML answer by its status (its table parsed), a JSON answer by its counts
(parsed), the import's answer whole. Hygiene, over every capture: raw token copies 0; no absolute path, unit number, log time,
timestamp, numbered thread, JDK or OS token, time figure, stack frame, unmasked identity, URL but TiffinBox's own
loopback ports 20090-20091; every JVM pinned and under its alarm; no kill by name, no bare `wait`; no `Thread.sleep` in the harness; no
H2 database file outside `.harness`; no dish name. **The prose gates, before any build** (over this README and `exercise/`): `s30`, per
sentence, with a 27-case self-test — carried from unit 29's `s29`: dur7's words (R.172), S4.7's duration meanings (R.264), **R.301's
family** (BLUE's `tm.py` regex: a cost word only in a sentence that names a printed number of statements, connections or sessions; "N
times" refused), the words for pace, R.287 (Hibernate 5/6's wordings), R.190 (the eighteen voiced as a witness); and this unit's:
**S5.1** (the count of queries said as a statement count), **S5.2** (a page's count with no scope word — session or request), **R.249**
(a "one plus one per customer" beside one N only), **R.224** (Course 17's title word for the loader, alone, without the title); no dish name; no placeholder and no empty
"What it prints" block; no typed SQL outside the values block (R.225); **R.302** — neither of the page's two counts typed in the
prose outside the text blocks and the values block, nor in `receipts.sh` or `harness/`, and every line of a text block one a run printed;
**R.252** — `pinned.txt`'s md5 and its lines in this README.

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid` — a harness JVM or
TiffinBox), the H2 server (`$spid`), the Maven or `javac` it waits for (`$mpid`, with every process under it), the exercise's shell
(`$xpid`), sweeps its own process group for any harness, exercise, H2 or TiffinBox JVM, Surefire fork, `javac` or Maven left, deletes
the capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched.

**Measured (2026-11-14, from 18:17 CET, on scratch mirrors of this folder — its files and `.m2-demo` cloned, `c7-unit29` and
`c7-tiffinbox` linked, the published captures copied in):** `receipts.sh` (/bin/bash 3.2) started `env -i` in a session of its own **with
SIGINT at its default** (`perl -MPOSIX -e '$SIG{INT}="DEFAULT"; setsid; exec …'`), `kill -INT` to its group once the named process was in
it, the state read 5 s after its exit — four trials:

```
build (surefirebooter seen: 2): processes in the group at SIGINT 5 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
harness (probe.v.Main seen: 1): processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
tiffinbox (tiffinbox.port=2009 seen: 1): processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
h2server (org.h2.tools.Shell seen: 1): processes in the group at SIGINT 5 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
```

`build` — the anchor's Maven build, its Surefire fork running; `harness` — the first harness JVM (`count`, `probe.v.Main`); `tiffinbox` —
TiffinBox's first start in `page` (port 20090); `h2server` — the H2 server running and its `Shell` (the second connection) in `page`.
`pgrep -x java` afterwards: none.

## 1 · count — the page at two N, the failure receipt, the session metrics (S5.1, R.249, RE-MEASURE 12)

Three harness JVMs: N = 36, N = 6, and the metrics JVM at N = 36 (the read-only read, then the read-write control, labelled).

## 2 · page — TiffinBox, the import, the dashboard, the list; A′ (S5.2)

Two TiffinBox JVMs on the H2 server, each with the import, the dashboard as HTML and as JSON, `GET /customers` and the second connection.

## 3 · inverse — every pause, then its customer

Two harness JVMs, N = 36 and N = 6.

## 4 · nested — unit 19's nested projection (S3 CARRIED)

Two harness JVMs, N = 36 and N = 6.

## 5 · sql — the two statement texts, each once

One harness JVM at N = 36, its SQL logger's lines grouped by text in the order they first appear.

## 6 · xcheck — the DDL over the anchor (R.252)

`9cf92b8cae3abfd0f1c0706bfe7a4373`, unit 29's and unit 27's: no mapping moved.

## 7 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s lines, then `SOLUTION.md`'s, exactly as written, in one `env -i` shell, `/bin/bash`, then `/bin/zsh -f`; each
file's "What it prints" block compared with the run, line for line.

## Exercise

"Your turn: the README prints the page's query count, and it stays the same however many customers there are. Print the count that
grows." (24 words by `wc -w`.) A Spring Boot application of its own (`Diner` and `Break`, its own tables in its own H2 in memory, no
port — not TiffinBox's customers): the README's run prints `getQueryExecutionCount()` — the same at 10 diners and at 40; the
solution's one line returns `getPrepareStatementCount()` instead — one plus one per diner at both. Broken ≠ solved by the printed lines
(their md5s differ), not the exit code (R.196).

## The ledger rows and hand-offs this unit pays

- **No ledger row paid** (§LEDGER: 30 pays none; `PROMISE-LEDGER-2026-11-01.md` untouched).
- **Pinned:** unit 39's counter and sentence; Course 17 U06's sentence (title only); Course 11 U14 *The Persistence Layer* as another
  consumer of the counter (a roadmap plan, not a ledger row).
- **§ROADMAP, U30:** the roadmap's "Hibernate statistics printing … queries" → prepared statements (`getPrepareStatementCount`), the statistic named
  for queries printing one at every N — the numbers in the values block.

## RE-MEASURE — the brief's items this unit settles

- **5 — 30's count on 29/after with 36 imported (the probe's `sP3`):** settled on the anchor by `page` (TiffinBox's own jar, built offline
  here, A′ on another build) — the whole request's and the read's session figures in the values block, equal to the probe's.
- **12 — the session-metrics block read with a read-only transaction:** settled by `count`'s metrics JVM — the read-only read's block
  carries no flush (`executing 0 flushes`); the read-write control (labelled) carries the flush of every entity and collection it
  loaded; and TiffinBox's own read (`@Transactional(readOnly = true)`) flushes nothing either (`page`).

## What differed from the brief

- **The page's database: the H2 TCP server, not the embedded URL** (the brief left the choice): the import's `added` and `GET /customers`'
  parsed length are two witnesses inside TiffinBox's JVM; the second connection (`org.h2.tools.Shell` over TCP: the customers, the
  pauses, the seeded sums) is the S3.12 form and needs one server JVM and three `Shell` runs per TiffinBox. Port 20098, loopback only.
- **The metrics block and the control (RE-MEASURE 12):** the read-write control is one more step in the metrics JVM, so it is measured
  and labelled, not named as unmeasured; its flush line's entities and collections are checked against that step's
  `getEntityLoadCount()` and `getCollectionFetchCount()`, never typed. The metrics are a third JVM in `count` (the counts at two N
  run without the metrics logger, so their logs carry no block).
- **TiffinBox's read-only read flushes nothing either** (`page`): an extra line the brief did not plan, asserted for both dashboard
  requests and A′.
- **The import's "36 SQL lines"** came with one session-metrics block per line (36 sessions, each preparing one statement: each `add`
  is its own transaction, unit 26) — printed and asserted (sessions = lines added).
- **The request's count is checked against its sessions:** the whole request's SQL lines = the sum of the four sessions' `preparing`
  figures — the S5.2 scope made a check, not a sentence only.
- **The anchor-diff plant:** the brief's R.211 form prints a note, never a stop, when `anchor/` and `../c7-tiffinbox` differ (unit 31
  will make them differ). A byte added to `../c7-unit29/after` must still fail, so `receipts.sh` pins the anchor's tree hash
  (`harness/tree30.py`: 43 files, `573dbb79…`) at the start and the end; the `diff -rq` against `../c7-tiffinbox` stays the note.
- **The typed-count grep (R.302)** covers the prose outside fenced blocks and the values block, and `receipts.sh` and `harness/`
  — `s30.py`'s self-test aside (its refused cases are the plants' sentences). README's text blocks are checked to be lines a run
  printed, so a count in them is printed, not typed.
- **`s30.py`, `chk30.py`, `seg30.py`, `csv30.py` and `tree30.py` are files in `harness/`**, not heredocs in `receipts.sh` (29 wrote
  its gate into `.harness/`): RED and unit 39's agent can run each one alone.
- **The exercise's application is its own** (`Diner`/`Break` in its own H2, as unit 29's): 4 named diners and 6 more, then up to 36
  more — 10 and 40 diners, no TiffinBox table. Its N values (6, 36) are in `ExApp.java`'s runner.
- **`sql` runs its own JVM** (`-Ds=count` at N = 36): the texts are read off that JVM's SQL logger lines, grouped by text in the order
  they first appear; `count`'s view counts those lines and does not show them.
- **Unit numbers in captures:** the hygiene check refuses "unit N" in any capture, so the steps say "the nested projection" and
  xcheck's line "the lazy-loading lesson's xcheck.sql" (unit 29's).
- **No `surefire.py`, no seven, no `tests` capture:** the anchor's 18 tests run in its build and are asserted from the build's summary
  lines (a guard, as unit 28 did); the seven are not re-run (the import changes the JSON bodies; 29's `466c20ed…` stands for the seed).
- **The seed: `m2-seed-c7-s3`** (= s4 = unit 29's), 6,681 files, cloned into `.m2-demo` (`cp -c`).
- **The ports 20092-20097 are checked free and never bound**, beside 20099.

## Planted faults — each caught (R.65, R.226)

Each on a scratch mirror (this folder's files and `.m2-demo` cloned, `c7-unit29`'s `after/`, `xcheck.sql` and `XMain.java` copied,
`c7-tiffinbox` linked), one edit, `receipts.sh` run `env -i` in a session of its own; every one **exit 1**, and the mirror's tracked files
hashed before and after: **unchanged in all 16** (nothing written). 2026-11-14, 18:03-18:17 CET.

| Plant (the brief's line 426 first) | Edit | Caught by |
|---|---|---|
| S5.1 — the count from `getQueryExecutionCount()` | `SC=Statistics.getQueryExecutionCount` | `chk30.py count`: "the three witnesses differ" at both N; "the count of queries must not be the statement count" |
| S5.2 — "the dashboard runs" a count, unscoped | a sentence "The dashboard runs … queries." in README | `s30.py`: "S5.2: a page's count with no scope" |
| R.302 — a count typed | "(… of them)" with the read's count in a README sentence | the typed-count grep, README line 49 |
| R.249 — a trend over one N | the N = 6 step removed (`for n in $NIMP`) | `chk30.py count`: "the line needs two points at two N - got 1 point(s), 1 N" |
| `nested` fed the flat projection | `PROJ=flat` (`NameOnly`, one statement) | `chk30.py nested`: the step is not the nested projection; collection fetches 0 ≠ customers |
| RE-MEASURE 12 — the metrics check fed the control | `RO=` the control's label | `chk30.py count`: "metrics, the read: no flush at its commit - its flush line: … executing 1 flushes …" |
| R.252 — `pinned.txt` one byte changed | `loads.` → `loads!` | the pinned md5 |
| a wrong published hash | `count 34b…` → `34c…` in `receipts.md5` | `pub`: "count is not the published capture" |
| S4.13 — a version line missing | `Main.java` no longer prints Framework's | `chk30.py count`: the Framework line, once per JVM, at both N |
| R.215 — a dish name | one in README | the dish grep |
| a placeholder | a line holding the placeholder grep's first word | the placeholder grep |
| a changed What-it-prints line | the README's second count changed | the exercise check: "What it prints" ≠ the run |
| R.225 — typed SQL | a pause SELECT under "The SQL" heading | the typed-SQL grep |
| R.301 + a duration word | a ratio word and a pace word (the plant's sentence, in its log) in README | `s30.py`: dur7's word, R.301's family, the pace word |
| R.196 — solution = broken | `SOLUTION.md`'s sed keeps `getQueryExecutionCount()` | the exercise check: "the solution's 1 + the diners at both" FAIL |
| R.211 — the anchor diff | one byte appended to the mirror's `c7-unit29/after/README.md` | the anchor tree hash, at the start |

**Not run as a plant:** the every-unit "typed jar count" (S5.19) — this unit prints no jar count (it says "91 libraries" from `ls | wc
-l` only in its terminal log); a check that cannot fail (R.276) is answered by the list above: each check named here failed once.

## CARRIED

- **"The same page at 2"** → unit 31 (SUBSELECT's, or a batch size ≥ N's); the anchor's fix prints 1 there, and C2 moves the anchor.
- **PostgreSQL** → unit 31 onwards (brief ⚑7: 30 is H2 only; the probe's PG run is the sketch's, not re-run).
- **Unit 39's test** asserts `getPrepareStatementCount()` (`pinned.txt`); Course 11 U14 the same counter.

## For RED

- **Where a planted fault could hide:** the count check takes its statement counter by name (`--counter`); a run of record passes
  `Statistics.getPrepareStatementCount`. The three witnesses must be equal, so a counter that is not a statement count fails against
  the proxy even when the SQL lines agree (planted). The derivation needs two distinct N; one N fails it (planted).
- **The read's session block is bounded by thread:** from the transaction manager's `Creating new transaction with name
  [com.tiffinbox.CustomerRepository.pausedDaysByCustomer]` on a virtual thread to the first `HHH000401` block on the same thread;
  virtual threads are one per task (`newVirtualThreadPerTaskExecutor`), so a name is not reused inside a request. The block's
  `preparing` must equal that thread's SQL lines and 1 + the second connection's customers.
- **The count of queries reads 1** at every N in this harness (`findAll(Sort)` is one query) and in the exercise; chk30 does not
  type 1 — it asserts the value the same at both N and different from the statement count.
- **H2 only.** The probe printed the same counts on PostgreSQL (`u30n36-pg.log`); this unit says "on H2" and does not re-run it.
- **`<ns>`:** every session-metrics time figure is masked (the receipt's mask and `seg30.py`); the hygiene check refuses a digit
  before " ns " in any capture.
- **Numbers the video may say** are in the values block; the prose names none of the page's two counts (R.302 grep, 0).
- **Not measured here:** PostgreSQL; a batch fetch or fetch join (unit 31's); a page larger than 40 customers.
