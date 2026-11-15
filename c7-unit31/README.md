# c7-unit31 — JOIN FETCH vs @EntityGraph vs @BatchSize

Course 7 · Data with JPA & Hibernate · Section 5 (Performance), its third unit and **its second change to the anchor** (brief ⚑1, C2;
the course's eleventh): `before` is the link to `../c7-unit29/after`, `after/` is this unit's tree, and `../c7-tiffinbox` equals `after/`
from this unit's commit on. Units 32 and 33 build over `after/` through links (`anchor → ../c7-unit31/after`) and change nothing in it;
**unit 34 moves the anchor next** (C3), its `before` the link to `../c7-unit31/after`. Verified on **JDK 25.0.4.1, Apache Maven 3.9.16,
Spring Boot 4.1.2** (Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate ORM 7.4.13.Final), 2026-11-15, **on H2 2.5.250 and
PostgreSQL 18.6** (brief ⚑7: one container per run). Three ways to ask for the pauses up front: join them into the customers' query,
name them in an entity graph, or let Hibernate fetch them in groups. Two print one statement, one prints a statement per group — and
each has a case where it changes what the page shows. TiffinBox's dashboard takes the entity graph.

**The anchor changes (C2).** `receipts.sh` prints `diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c7-tiffinbox` at its
start and end — empty in every run of record — and, should a later unit change the anchor, prints a note instead, never a stop
(R.211). `before/`'s tree is hashed at the start and the end (`harness/tree31.py`, unit 30's `tree30.py` byte for byte): 43 files,
`573dbb79…`, the pin unit 30 holds — this unit never edits `../c7-unit29/after`. Each tree is copied under `.harness/` and built there
with the README's package line, offline; the harness runs over `after/`'s extracted libraries (their count printed by the build step).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 9 captures, 3 runs each; every spoken number checked after its capture; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version` and `javac -version` say 25.) It **dies** when a
check after a capture fails, and when a capture's md5 differs from `receipts.md5`. **Start it in a process group of its own** (a
terminal's foreground job is one): `sweep()` stops only processes of its own group. `.m2-demo` must be seeded first (below), and the
image `postgres@sha256:77f58511…` must be on the machine (`docker image inspect`; the script never pulls).

<!-- runs: begin -->
**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`), a session of its own
(`perl -MPOSIX -e 'setsid; exec @ARGV'`), `.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681
files), the image `postgres@sha256:77f58511…` present (`docker image inspect`), one container per run, removed at its end. Development
runs fixed the captures and the checks; a full passing run wrote every capture 3/3 with the same md5s as the development passes, and
those are `receipts.md5`. **The runs of record, on the script as committed (`receipts.sh` md5 `a7ee1ab5ebd33847f5cbc4774ff365c4`): 375 s under `./receipts.sh`**
(/bin/bash 3.2.57, 2026-11-15 from 07:53 CET), **532 s under `bash receipts.sh`** (Homebrew bash 5.3.9, from 07:59 CET) **and 725 s from a
sealed fresh clone** (below, from 08:08 CET): each exit 0, all 9 captures 3/3 = published, every check passed, every Maven run `offline:
yes · exit 0 · 'Downloaded from' lines in its log: 0`, the anchor note empty at the start and the end, `before/`'s tree pinned at both, the
container removed and nothing listening on 20100-20109 at the end; each terminal log through `check_unit7.py 31 --runlog` —
`RESULT (run logs): PASS` (the unit gate: no 31 script yet). Each run's PostgreSQL work is 3/3 inside it (RE-MEASURE 11). **Nothing was
downloaded.**

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at `810fd56` into a path **with a space** (`…/sealed
31/tiffinbox-java`, in the session's scratch folder), this commit's files put in as git will take them (`git ls-files -m -o
--exclude-standard c7-unit31 c7-tiffinbox c7-unit29`, links kept); the clone's `.m2-demo` seeded from a file copy of the seed; dead
proxies for http and https in its environment (`127.0.0.1:9`); **`DOCKER_CONFIG=$HOME/.docker`** in its `env -i` (unit 28's finding:
OrbStack's `docker` needs its config to find its context); `./receipts.sh`.
The three runs' times differ (375 / 532 / 725 s) with the machine's load (`uptime` read 15.5 during the sealed run; another session's
container, `cc20`, not this unit's, was running); no capture moved — every md5 is the published one in all three. The sealed clone ran on
this README before its runs paragraph was written (the paragraph is the only change since; the gates were re-run on the final text:
`s31` refused 0, the table, text-block and values checks pass on the final run's captures).
**Re-run after unit 34 moved the anchor (2026-11-15).** `../c7-unit34`'s commit changed `../c7-tiffinbox` — Section 5's third and last anchor change (C3: `PauseEntity.java`'s `@Table` names `@Index(name = "pause_customer_id_idx", columnList = "customer_id")`; `Database.java` creates the index after the pause table; its README) — so this script's anchor check prints the note at its start and end, never a stop (R.211): `after/` is still this unit's tree, which 32's and 33's `anchor` and 34's `before` link to. `receipts.sh` unchanged (md5 `a7ee1ab5ebd33847f5cbc4774ff365c4`). One run on the moved anchor, `./receipts.sh` (/bin/bash 3.2.57), `env -i`, from 12:07 CET: exit 0 in 306 s, the note printed at the start and the end, all 9 captures 3/3 = published, `receipts.md5` unchanged (md5 `09f8e71e6691223a37ff39c95715ccc2` before and after), its log through `check_unit7.py 31 --runlog` PASS. 32's, 33's, 30's and 29's receipts were not re-run (RED #1200: their notes fire the same way; 32's and 33's `anchor` link to `../c7-unit31/after`, which did not move).
<!-- runs: end -->

Published hashes: fix `ad480c4f3f693dc9445dbc60fac2507c` · sql `f43205ab272b7b8ec168c945460fb5f7` · paging `92626ee9c2f69c93c17bb52e382803b5` · bags `c38bebd27576f473386ea6f044b986fa` · anchor `fb67836b1f45d26c73225d38b7f1babc` · seven `0c0b2a135aa4da15fdd875e0359d58df` · tests `5f294bb9b1ba11ec01733810b781ba42` · xcheck `aa5d83d01ab45dcc4f7f85b58da076fa` · exercise `30f955edfd9010c82c33e53559052f00`.

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line, R.225 — a SQL string
typed in this README outside this block and the blocks the runs printed is refused):

<!-- values: begin -->
the values the video may say: on H2 2.5.250 and PostgreSQL 18.6, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - fix: none · statements 41 · rows read 78 · customers shown 40 · Statistics.getCollectionFetchCount 40 · Statistics.getEntityLoadCount 78 ; left join fetch · statements 1 · rows read 40 · customers shown 40 · Statistics.getCollectionFetchCount 0 · Statistics.getEntityLoadCount 78 ; inner join fetch · statements 1 · rows read 38 · customers shown 38 · Statistics.getCollectionFetchCount 0 · Statistics.getEntityLoadCount 76 ; @EntityGraph(attributePaths = "pauses") · statements 1 · rows read 40 · customers shown 40 · Statistics.getCollectionFetchCount 0 · Statistics.getEntityLoadCount 78 ; @NamedEntityGraph(name = "BCustomer.pauses") as a fetchgraph hint · statements 1 · rows read 40 · customers shown 40 · Statistics.getCollectionFetchCount 0 · Statistics.getEntityLoadCount 78 ; @BatchSize(size = 16) · statements 4 · rows read 78 · customers shown 40 · Statistics.getCollectionFetchCount 3 · Statistics.getEntityLoadCount 78 ; @Fetch(FetchMode.SUBSELECT) · statements 2 · rows read 78 · customers shown 40 · Statistics.getCollectionFetchCount 1 · Statistics.getEntityLoadCount 78 ; the DTO group-by projection · statements 1 · rows read 40 · customers shown 40 · Statistics.getCollectionFetchCount 0 · Statistics.getEntityLoadCount 0 ; default_batch_fetch_size=16 · statements 4 · rows read 78 · customers shown 40 · Statistics.getCollectionFetchCount 3 · Statistics.getEntityLoadCount 78 ; derived: @BatchSize(size = 16) - 1 + ceil(40 / 16) = 4 = its statements; ceil(40 / 16) = 3 = Statistics.getCollectionFetchCount ; derived: default_batch_fetch_size=16 - 1 + ceil(40 / 16) = 4 = its statements; ceil(40 / 16) = 3 = Statistics.getCollectionFetchCount ; the inner join fetch drops Meera and Ravi ; database: H2 - in (?,...) placeholders 16 · 16 · 16 - each list the read-off size 16, the last batch padded to it (40 ids asked for in 48 placeholders) ; database: H2 - in (?,...) placeholders 16 · 16 · 16 - each list the read-off size 16, the last batch padded to it (40 ids asked for in 48 placeholders) ; database: PostgreSQL - = any (?) bound array lengths 16 · 16 · 8 - one array parameter per statement, none over the read-off size 16, 40 ids in all ; database: PostgreSQL - = any (?) bound array lengths 16 · 16 · 8 - one array parameter per statement, none over the read-off size 16, 40 ids in all · sql: the join: select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,p1_0.customer_id,p1_0.id,p1_0.days,ce1_0.price_per_meal,ce1_0.version from customer ce1_0 left join pause p1_0 on ce1_0.id=p1_0.customer_id order by ce1_0.name ; the graph's = the left join fetch's without distinct ; SUBSELECT: select p1_0.customer_id,p1_0.id,p1_0.days from pause p1_0 where p1_0.customer_id in (select t1_0.id from customer t1_0) ; database: H2 - select p1_0.customer_id,p1_0.id,p1_0.days from pause p1_0 where p1_0.customer_id in (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) ; database: PostgreSQL - select p1_0.customer_id,p1_0.id,p1_0.days from pause p1_0 where p1_0.customer_id = any (?) · paging: both databases: left join fetch + setMaxResults(10): 1 statement over a derived table, rows read 10 for 10 customers shown (one pause each), rows read 30 after the second seed (three pauses each); @EntityGraph + PageRequest.of(0, 10, Sort.by("name")): 2 statements (the derived table, then select count(*) from customer ce1_0), total 40; no fetch + a page: 12 statements (1 + the count + 10); WARN lines 0 · HHH90003004 lines 0 · bags: two Lists: java.lang.IllegalArgumentException: org.hibernate.loader.MultipleBagFetchException: cannot simultaneously fetch multiple bags: [probe.w.ent.BCustomer.orders, probe.w.ent.BCustomer.pauses] (0 statements, after createQuery returned) ; two Sets: 1 statement, rows read 7 = Meera 1 x 1 + Priya 1 x 1 + Ravi 1 x 2 + Sunil 1 x 3, customers shown 4 with distinct and 4 without · anchor: B (before/): GET /dashboard (HTML and JSON) 44 SQL lines in the whole request (sessions 1 1 1 41), the read's session preparing 41 ; A (after/): 4 SQL lines in the whole request (sessions 1 1 1 1), the read's session preparing 1, Creating new transaction with name [com.tiffinbox.CustomerRepository.pausedDaysByCustomer] ; the Paused days column = the second connection row by row: Meera 0 · Priya 2 · Ravi 0 · Sunil 3, every imported customer 0 ; GET /customers 1 SQL line, 40 entries ; A' = A · seven: 466c20ed7e0d5439cb052f32ce09de1b on before/ and after/, SQL lines during it 10 -> 6 · tests: 18 (14/3/1) on after/, offline · xcheck: 9cf92b8cae3abfd0f1c0706bfe7a4373 · exercise: the README: 10 diners 11 · 40 diners 41; the solution: 10 diners 1 · 40 diners 1 (19 words)
<!-- values: end -->

### C2 — the change, file by file, and every sentence it rewrote (R.250)

`diff -rq before after` (the `anchor` capture prints it, and each source's diff whole) — two files and the anchor's README:
- **`tiffinbox-core/…/CustomerEntityRepository.java`** — `import org.springframework.data.jpa.repository.EntityGraph;`,
  `import java.util.List;`, and a fourth method of its own: **`@EntityGraph(attributePaths = "pauses") List<CustomerEntity>
  findAllByOrderByNameAsc();`** — Spring Data derives the query from the name (every customer, by name), and the entity graph names the
  collection to fetch with it. **Sentences rewritten:** the class Javadoc's "one method of its own, findByName" (true when unit 16 wrote
  it, false as the class's whole list now) → "its first method of its own"; "two queries written by hand" → "two more methods, their
  queries written by hand"; a new paragraph for unit 31's method, which also says that `findAll(Sort)` is still inherited and still used,
  by `CustomerRepository.findAll()`.
- **`tiffinbox-core/…/CustomerRepository.java`** — `pausedDaysByCustomer()` reads `customers.findAllByOrderByNameAsc()` instead of
  `customers.findAll(Sort.by("name"))`; **its `@Transactional(readOnly = true)` is kept** (RE-MEASURE 2: the graph and the transaction
  together). **Sentences rewritten:** the method's Javadoc ("her pauses - a lazy collection, read here", "One SELECT for the customers
  and one per customer for her pauses") → the pauses fetched with the customers in one SELECT by the entity graph, and why the
  transaction stays: it is the read's boundary, on the virtual thread that reads (29's lesson); the entity graph is the read's fetch plan
  (31's). The class Javadoc's unit 29 paragraph ("read through her pauses, a lazy collection") → the fourth read, its own transaction,
  and a unit 31 sentence naming the graph. `findAll()` — the list, `GET /customers` — **is not changed**: the list shows no pause, so it
  fetches none (the `anchor` capture: one SQL line, 40 entries, on B and A alike).
- **`README.md` (the anchor's)** — a unit 31 note in the header, unit 29's sentence on the page's statements annotated *(Course 7,
  unit 31: no longer …)*, and a unit 31 section. **No mapping moves:** Hibernate's DDL for the entities is unit 27's, byte for byte
  (`9cf92b8c…`, `xcheck`) — the anchor README's DDL sentences stay true, and say so.

**The R.250 gate runs before any build:** after/'s `CustomerEntityRepository` holds the annotation and the method; `pausedDaysByCustomer`'s
body reads `findAllByOrderByNameAsc()` and no `findAll(Sort.by(`; its `@Transactional(readOnly = true)` sits on the line above it;
`customers.findAll(Sort.by("name"))` appears once in `CustomerRepository`, in `findAll()`; "a lazy collection", "read through her
pauses", "One SELECT for the customers and one per customer" (in `CustomerRepository`), "one method of its own" and "two queries
written by hand" (in `CustomerEntityRepository`) appear nowhere; the anchor README's note and section are there; `before/` holds no
`findAllByOrderByNameAsc`. **The plant `findAll(Sort.by("name"))` left in `pausedDaysByCustomer` is caught by this grep** (the gate
dies before any build — Planted faults); were the grep gone, `anchor`'s A check would catch it too (A's read session would prepare one
statement per customer more than the graph's one).

**The plant not run: the graph on the list's `findAll`.** Putting `@EntityGraph(attributePaths = "pauses")` on the list route's read
(`CustomerRepository.findAll()`, `GET /customers`) would make the list read the pause table for nothing — a fix applied where no lesson
asks for it; the `anchor` capture's list line (one SQL line on A) is the line that would move. Named here, not run (one more build and a
start for a beat no script says).

### The table — the same 40 customers through each fetch plan (`fix`; S5.5, both databases)

The harness (`probe.w`, over `after/`'s libraries; the shipped `Database` on each run's database; unit 20's generator by one JDBC batch
with `-Dn=36` — 36 customers `Customer 0000001`…, one pause each by `INSERT … SELECT` — the customers and pauses then counted back on
the second connection, never typed) reads the page — every customer by name, her paused days summed — through each fetch plan, in a read-only
transaction, one step each. Each step clears `Statistics` first and prints the three witnesses after it (`getPrepareStatementCount()`,
the `org.hibernate.SQL` appender's events, the JDBC proxy's `prepareStatement`, and its `executeQuery`), the rows read (the proxy's
`ResultSet.next()` that answered true), `Statistics`' collection fetches and entity loads, the customers shown, and the id lists its
statements asked for. **Every label is read off the run:** `@BatchSize`'s size by reflection on `BCustomer.pauses` (and the collection
persister's batch size beside it), `@Fetch`'s mode by reflection on `TCustomer.pauses`, the entity graph's paths off the anchor's own
method, the named graph off `BCustomer`'s class, `default_batch_fetch_size` off the `EntityManagerFactory`'s properties (a run option on
the anchor's own `CustomerEntity`, no annotation; its persister's batch size beside it). The harness entities **map the anchor's own
tables** (`customer`, `pause`, and the harness's `meal_order`) with other fetch settings; `ddl-auto none` keeps them off the schema.

**The table, as the check printed it** (`harness/chk31.py fix`: each row checked against the second connection's counts — none: one
statement for the list and one per customer; the joins and graphs: one statement, rows read = pauses + the customers with no pause;
the batches: statements derived `1 + ceil(N / size)` from the shown N and the read-off size; SUBSELECT: the list and one statement for
every collection; the DTO: no entity loaded — and the two databases' rows the same, row by row). `receipts.sh` asserts every line
between the markers below is a line the check printed (S5.5): a typed cell, a typed label, a row the run did not print, fails.

<!-- table: begin -->
```text
  row: none · statements 41 · rows read 78 · customers shown 40 · Statistics.getCollectionFetchCount 40 · Statistics.getEntityLoadCount 78
  row: left join fetch · statements 1 · rows read 40 · customers shown 40 · Statistics.getCollectionFetchCount 0 · Statistics.getEntityLoadCount 78
  row: inner join fetch · statements 1 · rows read 38 · customers shown 38 · Statistics.getCollectionFetchCount 0 · Statistics.getEntityLoadCount 76
  row: @EntityGraph(attributePaths = "pauses") · statements 1 · rows read 40 · customers shown 40 · Statistics.getCollectionFetchCount 0 · Statistics.getEntityLoadCount 78
  row: @NamedEntityGraph(name = "BCustomer.pauses") as a fetchgraph hint · statements 1 · rows read 40 · customers shown 40 · Statistics.getCollectionFetchCount 0 · Statistics.getEntityLoadCount 78
  row: @BatchSize(size = 16) · statements 4 · rows read 78 · customers shown 40 · Statistics.getCollectionFetchCount 3 · Statistics.getEntityLoadCount 78
  row: @Fetch(FetchMode.SUBSELECT) · statements 2 · rows read 78 · customers shown 40 · Statistics.getCollectionFetchCount 1 · Statistics.getEntityLoadCount 78
  row: the DTO group-by projection · statements 1 · rows read 40 · customers shown 40 · Statistics.getCollectionFetchCount 0 · Statistics.getEntityLoadCount 0
  row: default_batch_fetch_size=16 · statements 4 · rows read 78 · customers shown 40 · Statistics.getCollectionFetchCount 3 · Statistics.getEntityLoadCount 78
  derived: @BatchSize(size = 16) - 1 + ceil(40 / 16) = 4 = its statements; ceil(40 / 16) = 3 = Statistics.getCollectionFetchCount
  derived: default_batch_fetch_size=16 - 1 + ceil(40 / 16) = 4 = its statements; ceil(40 / 16) = 3 = Statistics.getCollectionFetchCount
  the inner join fetch: customers shown 38 of 40 - Meera and Ravi gone, the customers with no pause (the second connection)
  the two databases' rows: the same, row by row (9 rows)
```
<!-- table: end -->

**The inner join drops Meera and Ravi.** `join fetch` without `left` prints one statement too — and shows only the customers that have
a pause: Meera and Ravi, the seeded two with none (the second connection's `not exists` read in the same JVM), are not on its page.
The "customers shown" column is the check that catches it; a statement count alone would not.

**The batch's id lists, by database (S2.12)** — the JDBC proxy recorded each batch statement's list as it was prepared:

```text
  database: H2 - @BatchSize(size = 16), each batch statement's id list (JDBC proxy): in (?,...) placeholders 16 · 16 · 16 - each list the read-off size 16, the last batch padded to it (40 ids asked for in 48 placeholders)
  database: H2 - default_batch_fetch_size=16, each batch statement's id list (JDBC proxy): in (?,...) placeholders 16 · 16 · 16 - each list the read-off size 16, the last batch padded to it (40 ids asked for in 48 placeholders)
  database: PostgreSQL - @BatchSize(size = 16), each batch statement's id list (JDBC proxy): = any (?) bound array lengths 16 · 16 · 8 - one array parameter per statement, none over the read-off size 16, 40 ids in all
  database: PostgreSQL - default_batch_fetch_size=16, each batch statement's id list (JDBC proxy): = any (?) bound array lengths 16 · 16 · 8 - one array parameter per statement, none over the read-off size 16, 40 ids in all
  database: H2 - the batch statement, sent 3 x for 40 customers at @BatchSize(size = 16): select p1_0.customer_id,p1_0.id,p1_0.days from pause p1_0 where p1_0.customer_id in (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
  database: PostgreSQL - the batch statement, sent 3 x for 40 customers at @BatchSize(size = 16): select p1_0.customer_id,p1_0.id,p1_0.days from pause p1_0 where p1_0.customer_id = any (?)
```

Each batch statement asks for the ids of the customers whose pauses are not loaded yet. On H2 the list is `in (?,…)` with the read-off
size of placeholders every time — the last batch padded to the size, so 40 ids travel in 48 placeholders. On PostgreSQL it is one array
parameter, its length the ids left — the last array shorter than the size, nothing padded.

**Loser B, the alternative that loads no entity:** the DTO group-by projection (the row `the DTO group-by projection`, `Statistics.getEntityLoadCount` 0)
— a record per row, `name` and the summed days, one statement — the lesson called *Projections: Four Kinds* (19) showed a record
projection; this one sums in the database. It is not the anchor's: 31's title compares the three entity fetch plans, and the dashboard's
fourth read returns entities' data through the repository it already has (⚑1).

### The SQL (`sql`, both databases)

`harness/chk31.py sql` over the same steps, each text once with how many times it was sent (read off Hibernate's SQL logger):

```text
  the left join fetch's statement (both databases): select distinct ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,p1_0.customer_id,p1_0.id,p1_0.days,ce1_0.price_per_meal,ce1_0.version from customer ce1_0 left join pause p1_0 on ce1_0.id=p1_0.customer_id order by ce1_0.name
  the entity graph's statement (both databases) = the left join fetch's without its distinct: - 'select distinct ' + 'select '
  the inner join fetch's statement (both databases): select distinct ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,p1_0.customer_id,p1_0.id,p1_0.days,ce1_0.price_per_meal,ce1_0.version from customer ce1_0 join pause p1_0 on ce1_0.id=p1_0.customer_id order by ce1_0.name
  SUBSELECT's second statement (both databases): select p1_0.customer_id,p1_0.id,p1_0.days from pause p1_0 where p1_0.customer_id in (select t1_0.id from customer t1_0)
  database: H2 - the batch statement, sent 3 x for 40 customers at @BatchSize(size = 16): select p1_0.customer_id,p1_0.id,p1_0.days from pause p1_0 where p1_0.customer_id in (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
  database: PostgreSQL - the batch statement, sent 3 x for 40 customers at @BatchSize(size = 16): select p1_0.customer_id,p1_0.id,p1_0.days from pause p1_0 where p1_0.customer_id = any (?)
  every other text: the same on both databases
```

The entity graph's statement and the left join fetch's are the same join; the JPQL `distinct` reaches the SQL, the graph's derived
query has none. SUBSELECT's second statement re-runs the customers' query as a subquery, so every collection loads in one statement.

### Paging with a collection fetch — cut in the database (`paging`; S5.6, both databases)

```text
  both databases: left join fetch + setMaxResults(10): 1 statement over a derived table, rows read 10 for 10 customers shown (one pause each), rows read 30 after the second seed (three pauses each); @EntityGraph + PageRequest.of(0, 10, Sort.by("name")): 2 statements (the derived table, then select count(*) from customer ce1_0), total 40; no fetch + a page: 12 statements (1 + the count + 10); WARN lines 0 · HHH90003004 lines 0
  the derived table's statement (both databases): select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,p1_0.customer_id,p1_0.id,p1_0.days,ce1_0.price_per_meal,ce1_0.version from (select ce1_0.id,ce1_0.version,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 order by ce1_0.name offset ? rows fetch first ? rows only) ce1_0(id,version,meal_type,meals_per_day,name,price_per_meal) left join pause p1_0 on ce1_0.id=p1_0.customer_id order by ce1_0.name
```

Hibernate 7.4.13 cuts the page in a derived table — the ten customers first, then their pauses joined to them — so the rows read are
the pauses of the ten shown: one each, then, after the second seed (two more pauses for every generated customer, `INSERT … SELECT` on
the second connection in the same JVM), three each. The JVM's log holds no WARN line and no `HHH90003004` line on either database
(`grep -c`, printed). The entity graph's page is a page in the sense of the lesson called *Paging and Sorting* (20) — a query and a
count. Without a fetch, a page of ten is one statement for the page, one for the count, and one more for each customer shown.

### Two collections fetched together (`bags`, both databases)

The seeded four, the harness's `meal_order` (two orders for Ravi, three for Sunil, by plain JDBC after the seed) as the second
collection:

```text
  both databases: two Lists fetched - java.lang.IllegalArgumentException: org.hibernate.loader.MultipleBagFetchException: cannot simultaneously fetch multiple bags: [probe.w.ent.BCustomer.orders, probe.w.ent.BCustomer.pauses], 0 statements, raised by getResultList after createQuery returned
  both databases: two Sets fetched - 1 statement, rows read 7 = Meera 1 x 1 + Priya 1 x 1 + Ravi 1 x 2 + Sunil 1 x 3 (each customer's pauses x orders, a customer with none counted once - the second connection's counts), customers shown 4 with distinct and 4 without
```

Two `List`s are two bags: Hibernate refuses to fetch both in one query — on 7.4.13 the refusal comes when the query runs
(`getResultList`), after `createQuery` returned, and no statement is sent. Two `Set`s are fetched in one statement whose rows are the
product of each customer's pauses and orders; Hibernate de-duplicates the customers itself, so the page shows four with or without
`distinct`.

### TiffinBox — B, A, A′ (`anchor`; the failure receipt is B)

Each tree on its own port, its database on the H2 TCP server (`jdbc:h2:tcp://127.0.0.1:20107/mem:…`, `--spring.datasource.username=sa`
— unit 29 filed the start without it, `Wrong user name or password [28000-250]`; not re-filed here), `POST /customers/import` of 36
generated lines (unit 20's generator, `harness/csv31.py`), then `GET /dashboard` as HTML and as JSON and `GET /customers` — each
request's SQL lines counted between two markers this script appends to the JVM's log (the whole request: the dashboard's four reads,
four sessions — S5.2), the read's own session (`pausedDaysByCustomer`'s, bound by its thread from its `Creating new transaction` line
to its session-metrics block), and the HTML table's "Paused days" column parsed by its header against the second connection's
`group by` (H2's `Shell` over TCP, the same database, while TiffinBox runs), row by row, all 40:

```text
  B (before/ = ../c7-unit29/after): the import added 36; GET /dashboard, HTML and JSON alike: 44 SQL lines in the whole request (its 4 sessions: 1 1 1 41), the read's own session (pausedDaysByCustomer) preparing 41 = 1 + 40 customers
  A (after/): the import added 36; GET /dashboard, HTML and JSON alike: 4 SQL lines in the whole request (its 4 sessions: 1 1 1 1), the read's own session (pausedDaysByCustomer, its transaction kept: Creating new transaction; the derived method no transaction of its own, Participating 0) preparing 1
  B and A: the Paused days column (by its header, column 6) = the second connection's sum, row by row, 40 rows - Meera 0 · Priya 2 · Ravi 0 · Sunil 3, every imported customer 0; GET /customers 1 SQL line, 40 entries; A' = A
```

**B is the failure receipt** (S5.15): the unchanged page sends one statement for the customers and one more for each customer's pauses
inside the read's session. **A** — the graph and the read's transaction together (RE-MEASURE 2) — sends one statement in that session,
so the whole request is the list, the two sums and the graph's one join. The comparison of B's and A's columns, row by row against the
second connection, is the check that the graph changed the count and not the page (the inner join would lose Meera and Ravi here: a
plant). The derived method carries no transaction of its own — A's read session shows `Participating in existing transaction` 0
where B's `findAll(Sort)` (SimpleJpaRepository's own `@Transactional`) shows 1; the read's transaction is `pausedDaysByCustomer`'s, the
manager's `Creating new transaction with name [com.tiffinbox.CustomerRepository.pausedDaysByCustomer]` line present on both. A′ (`after/`
copied again and built again) prints what A printed.

### The seven, the tests, the DDL (`seven`, `tests`, `xcheck`)

```text
  exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log's org.hibernate.SQL lines during the seven: 10
  exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log's org.hibernate.SQL lines during the seven: 6
  the seven, after/ against before/: lines that differ: 0
  exit 0 · BUILD SUCCESS · offline: yes
    TEST-com.tiffinbox.web.FeedTest.xml: tests 1 · failures 0 · errors 0 · skipped 0
    TEST-com.tiffinbox.web.FullStackTest.xml: tests 3 · failures 0 · errors 0 · skipped 0
    TEST-com.tiffinbox.web.TiffinBoxWebTest.xml: tests 14 · failures 0 · errors 0 · skipped 0
    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0
  Surefire's console summary (its Results line): tests 18 · failures 0 · errors 0 · skipped 0 · the reports' sum the same: yes
  its md5: 9cf92b8cae3abfd0f1c0706bfe7a4373 · the filed xcheck.sql: 9cf92b8cae3abfd0f1c0706bfe7a4373 · cmp: the same, byte for byte · the lazy-loading lesson's xcheck.sql: the same, byte for byte
```

The seven `466c20ed…` on both trees, 0 lines differ (the JSON `/dashboard` keeps its four keys) — a guard; the SQL lines during the seven
move with the JSON dashboard's fourth read (29's README said its `before/` → `after/` pair; this unit's `before/` is 29's `after/`). The
eighteen tests 14/3/1 from Surefire's reports on `after/`, offline — **C7-4 paid** for C2 (guards: `TiffinBoxWebTest` mocks
`CustomerRepository` and `Dashboard`, `FullStackTest` mocks `CustomerRepository`; `sP6` had 18/18 too, and the tests were not changed).
Hibernate's DDL over `after/`: no mapping moved — **"And Hibernate's D-D-L script has the same hash as in the lesson called Optimistic
Locking with At-Version."** (R.252, 27's title, voiced "At-Version").

## The commands this unit adds

The harness, compiled once against `after/`'s extracted libraries; its JVM (the PostgreSQL driver from `.m2-demo`), its arguments in
two arrays (`V` the flags, `A` the arguments, R.193); `xcheck`'s JVM; the H2 server; its `Shell` (`$DB` the run's database name, `$Q`
the query); the import's file and its upload; the container, its readiness and a fresh database per JVM; the seven's run line:

```
javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/src/probe/w/Gen.java harness/src/probe/w/H.java harness/src/probe/w/Main.java harness/src/probe/w/Row.java harness/src/probe/w/Run.java harness/src/probe/w/Seed.java harness/src/probe/w/SqlCounter.java harness/src/probe/w/ent/BCustomer.java harness/src/probe/w/ent/BOrder.java harness/src/probe/w/ent/BPause.java harness/src/probe/w/ent/TCustomer.java harness/src/probe/w/ent/TOrder.java harness/src/probe/w/ent/TPause.java harness/src/probe/w/repo/FetchRepo.java harness/src/probe/x/XMain.java
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../after/tiffinbox-web/target/extracted/lib/*:../../.m2-demo/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar" probe.w.Main "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -cp "../hc:../after/tiffinbox-web/target/extracted/lib/*" probe.x.XMain "${A[@]}"
cd .harness/run && exec perl -e 'alarm 3000; exec @ARGV' java -Duser.language=en -Duser.country=US -Dh2.bindAddress=127.0.0.1 -cp "../after/tiffinbox-web/target/extracted/lib/h2-2.5.250.jar" org.h2.tools.Server -tcp -tcpPort 20107 -ifNotExists
cd .harness/run && perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../after/tiffinbox-web/target/extracted/lib/h2-2.5.250.jar" org.h2.tools.Shell -url "jdbc:h2:tcp://127.0.0.1:20107/mem:$DB" -user sa -password '' -sql "$Q"
python3 -I harness/csv31.py "$N" > .harness/import.csv
curl -s --noproxy '*' -F 'file=@.harness/import.csv;type=text/csv' http://127.0.0.1:20100/customers/import
docker run -d --pull never --name c7u31-pg -p 127.0.0.1:20108:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v "$U/.harness/secrets/pgpw:/run/pgpw:ro" postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
docker exec c7u31-pg pg_isready -U sa -h 127.0.0.1 -q
docker exec c7u31-pg psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c "drop database if exists $DB with (force)" -c "create database $DB"
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.org.hibernate.SQL=debug
```

TiffinBox itself runs the anchor README's own line (`java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431`,
read from `after/README.md` and asserted whole), its port changed, under the alarm with the locale pinned, followed by
`--tiffinbox.jdbc-url=…`, `--spring.datasource.username=sa`, the SQL logger, the transaction manager's DEBUG lines, Hibernate's session
metrics (DEBUG) and `generate_statistics=true` (printed whole in the capture). On PostgreSQL the harness gets `-Dpg.db=NAME
-Dpg.pwfile=../secrets/pgpw` and builds `jdbc:postgresql://127.0.0.1:20108/NAME` inside the JVM (unit 28's form): the password is on no
command line, every printed URL is cut before its `?`.

## The repository, and the network

Every Maven run is `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681 files; the brief allows s3 or s5 for 31 — s3 holds every class this
unit runs, the PostgreSQL driver 42.7.14 among them). Three Maven runs before the captures — `after/` with its tests (the build's summary
lines summed and asserted 18 · 0 · 0 · 0), `before/` and A′ with `-DskipTests` — and one inside a capture, in each of its three runs:
`tests`; every one `offline: yes`, 0 `Downloaded from` lines. **At run time** the harness binds no port; its H2 databases are in its
JVM's memory (`jdbc:h2:mem:u31`, xcheck's `x31`, the exercise's `ex`); its PostgreSQL databases are fresh ones in the container
(`u31fix`, `u31dbf`, `u31paging`, `u31bags`), loopback only; TiffinBox's are on the H2 server, loopback only; TiffinBox listens on
`127.0.0.1` only and is asked by `curl` on the loopback. **No network act** (`docker run --pull never`): the section's dated sweep is the
brief's (`_research/spring-boot-metadata-2026-11-13.xml`, `spring-data-bom-metadata-2026-11-13.xml`,
`hibernate-core-metadata-2026-11-13.xml`: no 4.1.x patch, Hibernate 7.4.15 exists and is not adopted — ⚑8, R.223). Every harness JVM
prints `Version.getVersionString()`, Spring Data JPA's version (`4.1.2`), Spring Framework's from `spring-tx`'s manifest (`7.0.10`) and
Hibernate's `HHH000001` line before the context starts (S4.13), and its database line: `select version()` cut before ` on `, the URL
cut before `?`, the JDBC driver's name and version from its metadata.

## The locale

The JVM ignores `LC_ALL` on macOS: every JVM this script starts carries `-Duser.language=en -Duser.country=US` on its java line, and the
hygiene check refuses a java line without it (and one without its alarm).

## The folders, the harness and the ports

- `before` → `../c7-unit29/after` (a link; `readlink` asserted; its tree hashed, 43 files `573dbb79…`); `after/` — this unit's tree,
  `../c7-tiffinbox` at this commit. Neither is built in place.
- `xcheck.sql` — Hibernate's script for `after/`'s two entities, filed (md5 `9cf92b8c…`, = `../c7-unit29/xcheck.sql`).
- `harness/` — `src/probe/w/Main.java` (a Spring Boot context, `WebApplicationType.NONE`, `@EntityScan({"com.tiffinbox", "probe.w.ent"})`,
  `@EnableJpaRepositories({"com.tiffinbox", "probe.w.repo"})`; the version lines first; the PostgreSQL URL from `-Dpg.db` and
  `-Dpg.pwfile`), `Run.java` (the scenarios `fix`, `dbf`, `paging`, `bags`; every label built from reflection or the EMF), `H.java`
  (helpers, the second connection, the JDBC proxy with the rows read and the id lists), `Seed.java` (the shipped `Database`; Boot's pool
  wrapped in the proxy; the `meal_order` table), `Gen.java` (unit 20's generator; the second seed), `Row.java` (the DTO), `SqlCounter.java`,
  `ent/` (`BCustomer` with `@BatchSize(size = 16)` on its pauses, another `List` and a `@NamedEntityGraph`; `TCustomer` with
  `@Fetch(FetchMode.SUBSELECT)` on its pauses and two `Set`s; their pauses and orders — all on the anchor's tables and `meal_order`),
  `repo/FetchRepo.java` (the two join fetches, the paged graph, the DTO); `src/probe/x/XMain.java` (xcheck's context, unit 29's byte for
  byte); `src/probe/w/ex/ExApp.java` (the exercise's, compiled only by the exercise); `chk31.py` (every check); `s31.py` (the prose gate);
  `seg31.py`, `csv31.py`, `tree31.py` (unit 30's `seg30.py`, `csv30.py`, `tree30.py`, byte for byte); `logback.xml`; `dur7.py` (the
  builders', md5 `41667fed…`); `surefire.py` (`../c6-unit28/harness/surefire.py`, byte for byte). No `Thread.sleep` in `harness/src`
  (asserted). English names only (R.215): Ravi, Meera, Sunil, Priya.
- `exercise/` — `README.md`, `SOLUTION.md`.
- `.harness/` (git-ignored, rebuilt by every run): `before`, `after`, `after2` (A′), `tests`, `hc`, `run`, `secrets/pgpw` (0600), the
  logs, the second connection's reads, the token's files (0600). `.r-NAME.1-3` while a capture runs; `.r-NAME.out` its result.
- **Ports (§P, 20100-20109):** 20100 anchor B · 20101 A · 20102 A′ · 20103 `seven` (before/, then after/) · **20107 the H2 TCP server** ·
  **20108 the container** (`docker port` asserted: `5432/tcp -> 127.0.0.1:20108`) · 20104-20106 and 20109 never bound. All ten, 18425, 8080
  and 35729 are checked free at the start and the end; each start checks its own port free first.

## Masks, filters and hygiene — every one, declared

Masks (awk `gsub` only, a planted self-test line before any capture): the generated token → `[masked: the token]`; **the generated
PostgreSQL password → `<pw>`** (raw password copies after the mask: 0, printed); this folder → `…`, the folder above → `…/..`, home →
`~`, the user name → `<user>`; ` using Java <version>`; an identity hash → `@…`; an EntityManager's identity → `SessionImpl(<n><open>)`;
a lambda class's address; Spring Data's scan figure; a session-metrics time figure → `<ns> ns`; a virtual thread's number, Tomcat's
handler thread's; the H2 Shell's row-count figure. Filters: a harness JVM's log whole but its `org.hibernate.SQL` lines (counted; with
`texts`, each text once with how many times it was sent); a TiffinBox request by its lines between its two markers, summarised by
`seg31.py`; an HTML answer by its table, parsed by `chk31.py table`. Hygiene, over every capture: raw token and password copies 0 (and
0 in every harness log on PostgreSQL before the mask); no absolute path, unit number, log time, timestamp, numbered thread, JDK, OS or
image token, elapsed figure, stack frame, unmasked identity, password, URL but TiffinBox's own loopback ports 20100-20103; every JVM
pinned and under its alarm; no kill by name, no bare `wait`; no `Thread.sleep` in the harness; no H2 database file outside `.harness`; no
dish name. **The prose gates, before any build** (over this README and `exercise/`): `s31`, per sentence, with a 34-case self-test —
R.172 (dur7's words), R.264 (S4.7's duration meanings, 29's ordinal refinement carried), **R.301** (BLUE's `tm.py` regex), the pace
words, R.287, R.190, S5.1, S5.2, R.249, R.224 (the title rules of unit 30 and of Course 17), **S5.6** (R.289), **S2.12** (each batch list
beside its database), and **the inner join's lost customers** (both names beside its count) — the refused readings are listed in
`harness/s31.py`'s docstring and self-test; no dish name; no
placeholder and no empty "What it prints" block; no typed SQL outside the values block and the printed blocks (R.225); **R.302**: the
counts this unit prints are typed nowhere in the prose outside those blocks, in `receipts.sh`, `chk31.py` and the harness's sources;
**S5.5**: the table's lines are the check's.

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid` — a harness JVM or
TiffinBox), the H2 server (`$spid`), the Maven or `javac` it waits for (`$mpid`, with every process under it), the exercise's shell
(`$xpid`), sweeps its own process group for any harness, exercise, H2 or TiffinBox JVM, Surefire fork, `javac`, Maven or `docker exec`
left, **removes the container** (`pgrm`: `docker rm -f` until `docker ps -a` names it no more; `CSTARTED` is set before `docker run`),
deletes the capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched.

**Measured (2026-11-15, from 07:30 CET, on scratch mirrors of this folder — its files and `.m2-demo` cloned, `c7-unit29`, `c7-unit30`, `c5-unit11` and `c6-unit28` linked, `c7-tiffinbox` copied; the published captures copied in):** `receipts.sh` (/bin/bash 3.2) started `env -i` in a session of its own **with SIGINT at its default** (`perl -MPOSIX -e '$SIG{INT}="DEFAULT"; setsid; exec …'`), `kill -INT` to its group once the named process was in it, the state read 5 s after its exit — five trials:

```
build (surefirebooter seen: 2): processes in the group at SIGINT 5 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · container c7u31-pg: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
harness (probe.w.Main seen: 1): processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · container c7u31-pg: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
tiffinbox (tiffinbox.port=2010 seen: 1): processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · container c7u31-pg: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
container (-Dpg.db=u31fix seen: 1): processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · container c7u31-pg: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
h2server (org.h2.tools.Shell seen: 1): processes in the group at SIGINT 5 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · container c7u31-pg: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
```

`build` — `after/`'s Maven build, its Surefire fork running; `harness` — the first harness JVM (`fix` on H2); `container` — the first harness JVM on PostgreSQL (`-Dpg.db=u31fix`), the container up; `tiffinbox` — TiffinBox's first start in `anchor` (B, port 20100); `h2server` — the H2 server running and its `Shell` (the second connection) in `anchor`. The container was gone after each (`docker ps -a`), and `pgrep -x java` showed none. The first three trials ran on the script one step before the committed one (two changes after them, before `container` and `h2server`: B's header line no longer names the frozen tree's path, and the unit-number hygiene leaves out the quoted diff lines — neither touches the trap).

## 1 · fix — the table (S5.5; both databases)

Two harness JVMs per database (the plans; the run option); see *The table* above.

## 2 · sql — the statements, each text once (S2.12)

One harness JVM per database; see *The SQL* above.

## 3 · paging — a page of ten with a fetch (S5.6)

One harness JVM per database, the second seed inside it; see *Paging* above.

## 4 · bags — two collections fetched together

One harness JVM per database; see *Two collections fetched together* above.

## 5 · anchor — the change, and TiffinBox B / A / A′ (the failure receipt is B)

The change (`diff -rq`, each source's diff whole), B, A, A′; see *TiffinBox* above.

## 6 · seven — before/ and after/, a guard (R.190)

`466c20ed7e0d5439cb052f32ce09de1b` on both, 0 lines differ.

## 7 · tests — TiffinBox's eighteen, on after/ (C7-4)

Surefire's XML: 18 (14/3/1) on `after/`, offline — guards, never witnesses (R.190).

## 8 · xcheck — the DDL over after/ (R.252)

`9cf92b8cae3abfd0f1c0706bfe7a4373`, the same as unit 29's (and 27's): no mapping moved.

## 9 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s lines, then `SOLUTION.md`'s, exactly as written, in one `env -i` shell, `/bin/bash`, then `/bin/zsh -f`; each
file's "What it prints" block compared with the run, line for line.

## Exercise

"Your turn: the README's page runs one more statement for every customer. Make it one statement, without writing JPQL." (19 words by
`wc -w`.) A Spring Boot application of its own (`Diner` and `Break`, its own tables in its own H2 — not TiffinBox's customers), its
statement count read from `getPrepareStatementCount()` at two N (10 and 40 diners, R.249): the README's page, through `findAll(Sort)`,
counts one plus one per diner; the solution's one line puts `@EntityGraph(attributePaths = "breaks")` on the repository's derived
`findAllByOrderByNameAsc()` and reads the page through it — one statement at both N. Broken ≠ solved by the printed lines (R.196).

## The ledger rows and hand-offs this unit pays

- **C7-4 — paid for C2** ("TiffinBox has tests now", 18): 18 from Surefire's XML after the change (`tests`); carried to U39
  (`../../../data-jpa-hibernate/_briefs/PROMISE-LEDGER-2026-11-01.md`, not edited here).
- **Call-backs by title** (R.224, each read in its script first where it exists): *Projections: Four Kinds* (19, a record projection —
  Loser B's DTO), *Paging and Sorting* (20, "a page: a query and a count"), *Optimistic Locking with @Version* (27, the DDL sentence, voiced
  "At-Version"); *Lazy Loading and LazyInitializationException* (29, the read's transaction) and *N+1, Measured* (30, the count this unit
  takes down) by title from `java7_series.py` (their scripts do not exist yet). Forward: Course 17's *The N+1 Problem and DataLoader*
  (U06), by title only, if a script names N+1's future.
- **34 moves the anchor next (C3)**; 32 and 33 build over `after/` through links.

## RE-MEASURE — the brief's items this unit settles

- **2** C2 = the graph and the read's transaction together: settled (`anchor`: A's whole dashboard request is the four sessions'
  one statement each, the read's session preparing one; the manager's `Creating new transaction … pausedDaysByCustomer` line on A; 18/18;
  the seven `466c20ed…`).
- **10** the exercise as README + SOLUTION, bash + zsh, `env -i`: settled (`exercise`).
- **11** 31's PostgreSQL runs inside the receipt, 3/3 per database: settled (`fix`, `sql`, `paging`, `bags` — each capture runs both
  databases in each of its three runs, a fresh database per JVM, one container per run of record).

## What differed from the brief

- **`MultipleBagFetchException` is raised when the query runs, not at `createQuery`.** The brief (and the probe's notes) say "at
  `createQuery`"; the probe's step did not tell the two apart. Here the step prints `createQuery returned` before it calls
  `getResultList()`, and that line is in the capture before the exception on both databases — so the refusal comes from
  `getResultList()`, 0 statements sent. The exception's text is the brief's, the class names this harness's (`probe.w.ent.BCustomer`).
- **PostgreSQL's last batch array is not padded.** The brief's "the bound array's length" is measured as 16 · 16 · 8 (the
  proxy reads the array bound by `setArray`/`setObject`), against H2's 16 · 16 · 16 placeholders (the last list padded). Both are printed
  as `database:` lines (S2.12); the statement count is the same, 1 + ceil(40 / 16), on both.
- **The derived method carries no transaction of its own.** A's read session shows `Participating in existing transaction` 0 (B's
  `findAll(Sort)`, SimpleJpaRepository's own `@Transactional(readOnly = true)`, shows 1): a query method declared on the interface runs
  inside `pausedDaysByCustomer`'s transaction without a transaction interceptor of its own. The check asserts 1 on B and 0 on A.
- **The H2 TCP server's port is 20107.** The brief's band gives the server no port (20100-20103 TiffinBox's, 20108 the container, 20109
  never bound); 20107 is the band's last free one before the container, as 29 used its …8 and 30 its …8 (both H2-only). 20104-20106 and
  20109 are never bound (asserted free at the start and the end).
- **The `seven` capture runs both trees on 20103** in turn (the brief gives `seven` one port); each JVM is stopped and the port checked
  free before the next starts.
- **The harness entities follow the probe's arrangement:** `BCustomer` holds `@BatchSize(size = 16)` on its pauses, another `List`
  (orders, on the harness table `meal_order` — the anchor has no second collection) and the `@NamedEntityGraph`; `TCustomer` holds
  SUBSELECT on its pauses and two `Set`s. So the two-`List` refusal is `BCustomer`'s and the two-`Set` fetch is `TCustomer`'s. The `none`
  row and the graph row use the anchor's own `CustomerEntity` (the graph on the anchor's own repository method, C2's), the
  `default_batch_fetch_size` row too (a run option, no annotation).
- **The `sql` capture is its own run of the `fix` scenario** (one JVM per database, the texts printed after the log) rather than a
  scenario of its own: the texts are those the table's rows sent. The paging texts are in `paging` itself.
- **Paging's two seeds are one JVM:** after the first three steps (one pause each), the second connection adds two more pauses to every
  generated customer (`INSERT … SELECT`, twice) and the `left join fetch` step runs again — the rows read follow the pauses of the ten
  shown, read back on the second connection (`pauses each: [3, …]`).
- **The seed:** `m2-seed-c7-s3` (6,681 files, the PostgreSQL driver 42.7.14 in it) — the brief allows s3 or s5 for 31.
- **`DOCKER_CONFIG`:** the sealed clone's run sets `DOCKER_CONFIG=$HOME/.docker` (unit 28's finding: `env -i` drops it, and OrbStack's
  `docker` needs its config to find its context); the two runs in this folder pass `HOME` only, as 28's did.
- **The page's counts typed nowhere:** the R.302 grep over the prose refuses the bare counts the table and the page print (the
  none row's statements and rows read, B's request, the inner join's shown) and a lone digit before "SQL lines", "statements" or
  "lines"; over `receipts.sh`, `chk31.py` and the harness sources the same whole words. A lone digit is not grepped in the scripts (it
  is in versions, sections and ports); the checks derive every count from another witness instead (`chk31.py`: `1 + ceil(N / size)`,
  `1 + customers`, the sessions' sum).
- **The prose gate `s31`** is a file (`harness/s31.py`, 30's form) with a 34-case self-test; the inner-join rule refuses a sentence that
  refuses a sentence on the inner join's count without both names beside it, since its shown count may not be typed (R.302).
- **The exercise** is a Boot application of its own (`Diner`, `Break`, a repository `Diners`): broken = `findAll(Sort)` + the breaks;
  the solution's one line is a `sed` with two expressions — the graph on the derived method and the call to it — one line of the block
  (the check: the README's block and the solution's differ by one line).

## Planted faults — each caught (R.65, R.226)

**On scratch mirrors of this folder** (its files copied and `.m2-demo` cloned, `c7-unit29`, `c7-unit30`, `c5-unit11` and `c6-unit28`
linked, `c7-tiffinbox` copied; `receipts.md5` the published one), `./receipts.sh` `env -i` in a session of its own; each **exit 1**,
`receipts.md5` and `README.md` unchanged by the run. The late captures' plants ran with only that capture kept in the mirror's
`receipts.sh` (its other `cap` lines left out, nothing else changed):

| plant | caught by |
|---|---|
| a sentence placing a fetched page's cut outside the database | `s31`: S5.6 (R.289) |
| a sentence saying Hibernate prints the paging warning's code | `s31`: S5.6, the code named as printed |
| H2 said to ask with an array parameter (PostgreSQL's list said for H2) | `s31`: S2.12 |
| the inner join's count of statements said without the two names | `s31`: the inner join's lost customers |
| a dish name in `exercise/README.md` | R.215 |
| a to-do marker line | the placeholder gate |
| a typed SQL string outside the printed blocks | R.225 |
| a number-word before "times", with a pace word | dur7 and R.301's family |
| a typed library count | R.302 |
| B's request count typed in the prose | R.302 |
| the eighteen tests voiced as the fix's evidence | R.190 |
| `findAll(Sort.by("name"))` left in `after/`'s `pausedDaysByCustomer` | the R.250 gate, before any build (`C2 (R.250): pausedDaysByCustomer must read through findAllByOrderByNameAsc()`) |
| `@BatchSize(size = 40)` on `BCustomer.pauses`, the README's row unchanged (fix's hash taken out of the mirror's `receipts.md5` so the run reaches the table check) | S5.5: the table check — the run printed `@BatchSize(size = 40) · statements 2`, `1 + ceil(40 / 40) = 2`, H2's list `in (?,...) placeholders 40`; README's `@BatchSize(size = 16)` row is not a printed line (BLUE's measurement, here on both databases; the capture's md5 moved too) |
| a wrong published hash (`xcheck`) | `xcheck is not the published capture` |
| the password's `gsub` taken out of the mask | the mask self-test |
| a changed What-it-prints line (the solution's 40-diner count) | the exercise's block-against-run comparison |
| the solution's two `sed` expressions made to match nothing (solved = broken) | the exercise check: the solution printed the README's two counts (R.196) |
| a byte added to the mirror's `after/README.md` | the R.211 note at the start (`after/ and ../c7-tiffinbox differ …`), and the run went on (a note, not a stop); that mirror ran `xcheck` alone, so it stopped at the table check after it |

**On copies of this run's captures** (scratch, `harness/chk31.py` fed each planted copy; each exit 1 where the unplanted capture
passes, exit 0):

```
C1 a typed cell in README's table (the @BatchSize row's statements typed 2): exit 1 - S5.5: README.md's table holds a line the fix check did not print
C2 A's dashboard fed B's segment (its whole request, its read's session): exit 1 - the read's session prepares one statement, and every session one: [41], [1, 1, 1, 41]
C3 A's column fed a page without Meera's and Ravi's rows (38 rows): exit 1 - the Paused days column (column 6, 38 rows) = the second connection's sum, row by row (40 rows); the status-only check (A's HTML dashboard -> 200) passes
C4 the Framework version line taken out (fix), HHH000001 taken out (bags): exit 1 each - the line once: ...
C5 the inner join's row written as every customer shown: exit 1 - the customers with no pause gone ([]; the second connection: ['Meera', 'Ravi'])
```

Not run as plants: the graph on the list's `findAll` (named in C2's section); a typed jar count in a script (no script prints one).

## The anchor moved on — the re-run of 29 (R.211, RED #1200)

`grep -n c7-tiffinbox` before the commit (R.211, the brief's EVIDENCE BATCHES), over `_builders/*.py`,
`~/Desktop/PromptVidya-Automation/check_unit7.py` and `qa_java7.py`: the same 22 builders 29's README lists — `s701.py`-`s707.py`,
`s709.py`, `s715.py`, `s716.py` (each reads `git show <sha>:c7-tiffinbox/…`), `s717.py`-`s728.py` (each asserts its `after/` against `git
show <sha>:c7-tiffinbox/<p>` and prints a `note:` line per live difference); `check_unit7.py` and `qa_java7.py` — no line; no `s729`,
`s730` or `s731` exists yet. **`s717.py` run once after the move** (a scratch copy with `_builders/dur7.py` beside it, so its `OUT` is the
copy's folder and nothing is written into the course; `~/.venvs/slides2video/bin/python s717.py`): exit 0, **twelve** `note: c7-tiffinbox
has moved on since f620c1a …` lines (29 saw eleven; C2 touches two files, and `CustomerRepository.java` was already among the eleven,
so the one new line is `CustomerEntityRepository.java`), then `anchor: after/ = f620c1a:c7-tiffinbox in its 4 changed files; diff -rq
against the live c7-tiffinbox: 12 lines` — the expected sign.

**`../c7-unit29/receipts.sh`** (unchanged, md5 `254edb72da5e12239c862da4bbf4c1d6`) — the previous anchor-change unit — run once on the
moved anchor, `./receipts.sh` (/bin/bash 3.2.57), `env -i`, a session of its own, from 07:02:24 CET: **exit 0 in 406 s**; its note at
its start and its end (`(after/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit froze: Files after/README.md
and ../c7-tiffinbox/README.md differ;Files after/…/CustomerEntityRepository.java and …`), all 7 captures 3/3 = published,
`receipts.md5` unchanged (`71201a4f8bb5c700d9bf74df1a7b2c3d` before and after), its log through `check_unit7.py 29 --runlog` PASS.
30, 28, 27 and 26 were not re-run (RED #1200: their notes fire the same way; 30's `anchor` links to `../c7-unit29/after`, which did not
move). The dated "Re-run after unit 31 moved the anchor" paragraph is in `../c7-unit29/README.md` (its own "unit 31 moves the anchor
next" sentence stays true and is not edited).

## CARRIED

- **The index** — unit 34 (C3) adds `pause_customer_id_idx` to `PauseEntity` and `Database`; the graph's join reads the pause table by
  its foreign key, which PostgreSQL leaves unindexed (⚑6).
- **The list route** — `GET /customers` keeps `findAll(Sort)`, one statement, no pauses; the graph on it is a named plant, not run.
- **N+1's future** — Course 17's *The N+1 Problem and DataLoader* (U06), named by title only.
- **Bytecode enhancement** — unit 29's README names it, not measured.

## For RED

- **Every table cell is a check's printed line, and the check derives it:** none = 1 + customers (the generator's count read back);
  the joins and graphs = one statement, rows read = pauses + the customers with no pause (the second connection's `not exists` read);
  the batches = `1 + ceil(N / size)` from the shown N and the size read off the field / the EMF, `Statistics.getCollectionFetchCount`
  = `ceil(N / size)`; the two databases' rows equal. The README's table lines must each be a line the check printed (S5.5).
- **`@BatchSize(size = 40)` under the old row** fails twice: the row's label carries the read-off 40 (so the README's `@BatchSize(size =
  16)` line is not printed — S5.5's table check), and the capture's md5 moves (`fix is not the published capture`). See Planted faults.
- **The inner join's lost customers are named from the second connection,** not typed: the check compares the seeded names missing from
  the inner join's page with the `not exists` read.
- **The anchor's A check fails on B's log** (B's read session prepares one statement per customer more than one) and **the column check
  fails on a page without Meera's and Ravi's rows** while a status-only check passes (Planted faults).
- **The `createQuery` correction** (What differed) rests on one printed line, `createQuery returned`, before the exception in the same
  step; a slide should say "when the query runs".
- **PostgreSQL's arrays 16 · 16 · 8** are the proxy's reading of the bound parameter; the SQL text alone shows one `?`.
- **Not measured here:** the graph on the list route (named plant, not run); a page of a different size; `@BatchSize` on the anchor's
  entity (only the harness entity and the run option); PostgreSQL for TiffinBox itself (U39).
