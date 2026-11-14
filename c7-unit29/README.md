# c7-unit29 — Lazy Loading and LazyInitializationException

Course 7 · Data with JPA & Hibernate · Section 5 (Performance), its first unit and **its first change to the anchor** (brief ⚑1, C1;
the course's tenth): `before` is the link to `../c7-unit27/after`, `after/` is this unit's tree, and `../c7-tiffinbox` equals `after/`
from this unit's commit on. Unit 30 builds over `after/` through a link and changes nothing in it; **unit 31 moves the anchor next**
(C2). Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.2** (Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate
ORM 7.4.13.Final), 2026-11-14, **on H2 2.5.250** only (brief ⚑7). A collection Hibernate has not read yet is a placeholder; read it
after its persistence context has closed and Hibernate refuses. TiffinBox's dashboard gains a "Paused days" column that reads each
customer's pauses — and the famous switches either do not reach the threads the dashboard reads on, or put work on every request.
The fix that holds puts the boundary on the read itself.

**The anchor changes (C1).** `receipts.sh` prints `diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c7-tiffinbox` at its
start and end — empty in every run of record — and, should a later unit change the anchor, prints a note instead, never a stop
(R.211). Each tree is copied under `.harness/` and built there with the README's package line, offline; the harness runs over the
copies' extracted libraries (91 each).

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
`254edb72da5e12239c862da4bbf4c1d6`): 397 s under `./receipts.sh`** (/bin/bash 3.2.57, 2026-11-14 from 16:56 CET), **400 s under `bash
receipts.sh`** (Homebrew bash 5.3.9, from 17:02 CET) **and 402 s from a sealed fresh clone** (below, from 17:09 CET): each exit 0, all 7
captures 3/3 = published, every check passed, every Maven run `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`, the anchor
note empty at the start and the end, nothing listening on 20080-20089 at the end; each terminal log through `check_unit7.py 29 --runlog`
— `RESULT (run logs): PASS` (the unit gate: no 29 script yet). **Nothing was downloaded.**

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at `dbb8561` into a path **with a space** (`…/sealed
29/tiffinbox-java`, in the session's scratch folder), this commit's 70 files put in as git will take them (`git ls-files -m -o
--exclude-standard c7-unit29 c7-tiffinbox c7-unit27 .gitignore`, links kept); the clone's `.m2-demo` seeded from a file copy of the seed;
dead proxies for http and https in its environment (`127.0.0.1:9`); `./receipts.sh` `env -i`. (26's and 27's pre-flight — a
`dependency:get` of an absent artifact refused by a `file://` mirror — was not repeated here; every build is `-o` and printed `offline:
yes` with 0 `Downloaded from` lines.)
<!-- runs: end -->

Published hashes: lazy `c2a01a2ff2257b09748c226f2e7bc83c` · anchor `14dae35fd1e41227125f67d16a5de1a1` · wrong `468fbc17bc037bce87a94ab7c6f5cdf4` · seven `363d75c7c41468093b147565bd822729` · tests `2b8860eeef18a6281f9c9fa69d84dc63` · xcheck `75d34620aa3eab9cf9d018297b3acbba` · exercise `9265888c4eb12d7fc65cd9a98fd4c5a7`.

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line, R.225 — a SQL string
typed in this README outside this block is refused):

<!-- values: begin -->
the values the video may say: on H2 2.5.250, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - lazy: findAll outside a transaction 1 statement, Meera's pauses org.hibernate.collection.spi.PersistentBag, Hibernate.isInitialized false, then org.hibernate.LazyInitializationException: Cannot lazily initialize collection of role 'com.tiffinbox.CustomerEntity.pauses' with key '2' (no session) (the key 2: Meera, the first by name); getReferenceById(3): com.tiffinbox.CustomerEntity$HibernateProxy, getId() 3 with 0 statements, getName(): org.hibernate.LazyInitializationException: Could not initialize proxy [com.tiffinbox.CustomerEntity#3] - no session · anchor B (no transaction, 18 tests passed): the page and the JSON 500, the cause on the request thread: java.util.concurrent.ExecutionException: org.hibernate.LazyInitializationException: Cannot lazily initialize collection of role 'com.tiffinbox.CustomerEntity.pauses' with key '2' (no session); the seven's line GET   /dashboard  -> 500 application/json  {"timestamp":"<time>","status":500,"error":"Internal Server Error","path":"/dashboard"} · the H2 user trap: Wrong user name or password [28000-250] · A: 200, Paused days Meera 0 · Priya 2 · Ravi 0 · Sunil 3 (column 6, = the second connection), 8 SQL lines a dashboard request, the manager: Creating new transaction with name [com.tiffinbox.CustomerRepository.pausedDaysByCustomer], Participating in existing transaction · wrong (a): still 500, Opening 2 · Closing 2 a request on the request thread, beans 1; the control 0 · 0, beans 0; the route 200, 5 SQL lines, {"Meera":0,"Priya":2,"Ravi":0,"Sunil":3}; Hikari active 1 after the reads, 1 before the close, 0 after it · (b): GET /customers 1 -> 5 SQL lines, the dashboard 8 -> 12; harness em.find 1, a JPQL list 5 · (c): the page 200, 8 SQL lines; sessionOpenCount 5, getConnection 5, WARN lines 0 · (d): exit 1, java.lang.IllegalArgumentException: Cannot subclass final class com.tiffinbox.web.DashboardPage; un-finaled still 500; the route 200, 5 SQL lines · (e): 5, Hibernate.initialize 5 · seven: 466c20ed7e0d5439cb052f32ce09de1b before and after · tests: 18 (14/3/1), on B 18 · xcheck: 9cf92b8cae3abfd0f1c0706bfe7a4373 · exercise: org.hibernate.LazyInitializationException: Cannot lazily initialize collection of role 'probe.u.ex.Diner.breaks' with key '2' (no session) -> {Meera=0, Priya=2, Ravi=0, Sunil=3} (20 words)
<!-- values: end -->

### C1 — the change, file by file, and every sentence it rewrote (R.250)

`diff -rq before after` (the `anchor` capture prints it, and each source's diff whole) — three files and the anchor's README:
- **`tiffinbox-core/…/CustomerRepository.java`** — `import java.util.LinkedHashMap;`, `import java.util.Map;`, and
  **`public Map<String, Integer> pausedDaysByCustomer()`**: every customer through `customers.findAll(Sort.by("name"))`, her pauses —
  the lazy collection `CustomerEntity.pauses` — summed in Java, **with `@Transactional(readOnly = true)`**, the boundary at the read,
  on the thread that runs it. Its Javadoc says what the transaction keeps open and what B shows without it. The class Javadoc: its
  first line said "Unit 29/31: rows in, records out." — a note older than Course 7 (it came with Core Java II's TiffinBox, commit
  `15c404c`), which a Course 7 reader would take for this unit — now "Rows in, records out (this class's first line, from Core Java
  II's TiffinBox - not Course 7's units)"; the unit 26 paragraph's "TiffinBox's first `@Transactional`, on add" stays true by naming
  the second ("Course 7, unit 29: the second is pausedDaysByCustomer's, below"); a unit 29 paragraph (RED #1515).
- **`tiffinbox-core/…/Dashboard.java`** — `load()` runs `repo::pausedDaysByCustomer` as a **fourth read** on the same
  `Executors.newVirtualThreadPerTaskExecutor()`; `View` gains `Map<String, Integer> pausedDaysByName` **and keeps a three-value
  constructor** (`TiffinBoxWebTest`'s `new Dashboard.View(list, 7200, 0)` compiles unchanged — 18 tests, `tests`); `byName(…)` checks
  the map back the way `customers(…)` checks the list. **R.250's set, rewritten:** the class Javadoc's first sentence (three reads →
  four, and which the fourth is), "submits all three … all three are finished" → four, `// all three, or none` → four; the `View`
  gains a Javadoc that names the four values and the three-value constructor. The gate, before any build: the four old lines are in
  `before/`'s `Dashboard.java` (asserted, 4) and **0 in `after/`** (sources, templates and README, by one regex that also refuses the
  plant "Dashboard reads three").
- **`tiffinbox-web/…/templates/dashboard.html`** — a sixth column, **"Paused days"**, `${view.pausedDaysByName[c.name] ?: 0}`.
  **The hazard (RED #1501):** the `?: 0` and the three-value constructor together mean a tree whose `load()` lost the fourth read still
  renders **200 with a column of zeros** — no exception, and a grep for "Sunil … 3" in the page still finds Sunil's meals cell (3). So
  A's witness is the **table parsed by its header** (`Paused days`, column 6) and compared **row by row** with a second connection's
  sum in the same run, never one grep (plant below, measured).
- **The anchor's README** — the header note for unit 29, a `## Course 7 · unit 29` section, and the unit 27 section's "This tree is
  Section 4's frozen anchor" amended in place (Section 4's anchor stays `../c7-unit27/after`; this folder moved on).
- **No mapping moves:** `CustomerEntity` and `PauseEntity` are untouched; Hibernate's own DDL is unit 27's, `9cf92b8c…`, byte for byte
  (`xcheck`). **The JSON `/dashboard` keeps its four keys**: the seven `466c20ed…` before and after (`seven`).
- **What 29/after carries on purpose:** the page reads one statement for the customers and one per customer for her pauses (8 SQL
  lines a dashboard request: the three old reads, then 1 + 4) — unit 30's subject on TiffinBox itself; fetching what the page needs in
  the query is the lesson called Join Fetch vs EntityGraph vs BatchSize (31), which changes `pausedDaysByCustomer` next.

### The placeholder and the proxy (harness, `lazy`)

`findAll(Sort.by("name"))` with no transaction around the caller (`tx active false`): one statement — `Statistics.getPrepareStatementCount`,
the SQL logger's events and the JDBC proxy's `prepareStatement` each 1 (S5.1) — four customers; the first by name, Meera, has `pauses`
of class `org.hibernate.collection.spi.PersistentBag`, `Hibernate.isInitialized false`; the first read of it throws **7.4.13's text**:
`LazyInitializationException: Cannot lazily initialize collection of role 'com.tiffinbox.CustomerEntity.pauses' with key '2' (no
session)` — the key **derived**, never typed: the harness's second connection reads `id, name … order by name` and the check takes the
first row (2, Meera). `getReferenceById(3)`: class `com.tiffinbox.CustomerEntity$HibernateProxy` (7.4's name), `getId()` 3 with **0
statements** (the three witnesses 0; one connection taken by Spring Data's read-only transaction, nothing sent), `getName()` →
`Could not initialize proxy [com.tiffinbox.CustomerEntity#3] - no session`. A pause loaded inside a transaction, its customer read
after it: the same proxy, the same message (S3 CARRIED). The plan's Hibernate 5/6 wordings are refused by the prose gate (S5.4, R.287).
Called back by title: *The Persistence Context* (04) — the context that closed is the one that lesson opened and closed by hand — and
*@Transactional: What the Proxy Does* (23) — the same word, a different proxy: there Spring's around a bean, here Hibernate's standing
in for an entity.

### TiffinBox — B, A, A′ (S5.15, `anchor`)

Every TiffinBox JVM here runs on **H2 over TCP**: an H2 server JVM (`org.h2.tools.Server -tcp -tcpPort 20088 -ifNotExists`,
`-Dh2.bindAddress=127.0.0.1`, "only local connections"; listening on `127.0.0.1:20088` alone, asserted) started once per run, each
TiffinBox on its own `jdbc:h2:tcp://127.0.0.1:20088/mem:<name>;DB_CLOSE_DELAY=-1` with `--spring.datasource.username=sa`. The second
connection is H2's own `Shell` on the same URL, run by the script after the requests while TiffinBox still runs: the sum by name and
the ids by name. Markers are appended to the JVM's log (opened for append) around each request; every count below is between two
markers (S5.2, R.299), never a whole log's.

- **B — labelled: `after/` without the read's transaction** (`.harness/anb`, `derive.py notx`: the one line out is
  `@Transactional(readOnly = true)`; built with its tests — **18 passed**: the tests did not notice — a guard, R.190), port 20080: `GET
  /customers` 200 (1 SQL line); HTML `/dashboard` twice and JSON `/dashboard` once — **500 each**, and each **bound to its cause**: the
  request thread's `Servlet.service() … threw exception [Request processing failed: java.util.concurrent.ExecutionException:
  org.hibernate.LazyInitializationException: Cannot lazily initialize collection of role 'com.tiffinbox.CustomerEntity.pauses' with key
  '2' (no session)]` (`omcat-handler-<n>`, Boot's cut thread name), the key derived from the second connection's first row by name,
  and the read's SQL on `virtual-<n>` threads (4 lines on 4 of them). The seven's dashboard line on B: `GET /dashboard -> 500` — B's
  seven hash is not published (its 500 body carries a timestamp, masked here).
- **The H2 user trap — labelled** (BLUE #1511, filed as its own step, S5.20): `after/`'s jar on the TCP URL without
  `--spring.datasource.username=sa` → `exit 1`, port 20081 never bound, `Caused by: org.h2.jdbc.JdbcSQLInvalidAuthorizationSpecException:
  Wrong user name or password [28000-250]` (`Database`'s own connection names `sa`; Boot's pool, given a URL it does not treat as
  embedded, names no user). 34's p6spy start is the same mechanism (its own step there).
- **A — `after/`**, port 20081: the page 200 twice, the JSON 200 with its four keys; **the "Paused days" column parsed by its header
  (column 6) and compared row by row with the second connection's sum: Meera 0 · Priya 2 · Ravi 0 · Sunil 3** — Priya is the telling
  row (her meals cell is 1; Sunil's meals are 3 too); the slide says "Priya 2, Sunil 3". **8 SQL lines a dashboard request**, all on
  the virtual threads; the manager's **`Creating new transaction with name [com.tiffinbox.CustomerRepository.pausedDaysByCustomer]`** on
  a virtual thread and `Participating in existing transaction` (findAll joins it). `GET /customers` 1 SQL line.
- **A′** — `after/` copied again and built again (`.harness/ana2`), port 20082: prints what A printed (R.1).

### The four wrong fixes, each with its printed count (S5.3, S5.14, S5.16, S5.20, `wrong`)

- **(a) open-in-view** (`--spring.jpa.open-in-view=true`, the interceptor's DEBUG on, the beans endpoint exposed) on B with a labelled
  request-thread route (`.harness/anr`: `GET /customers/paused` on `TiffinBoxServer`, returning `repo.pausedDaysByCustomer()`), port
  20083: the dashboard **still 500**, the cause bound as on B; per request `Opening JPA EntityManager in OpenEntityManagerInViewInterceptor`
  **2** and `Closing …` **2**, all on the request thread — the second pair is the `/error` dispatch after the exception; the read's SQL
  on `virtual-<n>`; `/actuator/beans` names **1** `OpenEntityManagerInViewInterceptor`. **The control** — the same copy without the flag,
  port 20084: 0 interceptor lines in every request, beans **0**, the route 500; the switch-on check (every dashboard request's 2 / 2 on
  the request thread and one bean) passes on the first and **fails on the control** (S5.16). On the request-thread route, from the
  flag's JVM: **200, 5 SQL lines on the request thread**, `{"Meera":0,"Priya":2,"Ravi":0,"Sunil":3}`, one interceptor Opening. Said:
  open-in-view keeps the persistence context for the request on the request's thread; TiffinBox's dashboard reads on other threads.
  **Its cost, the held connection** (RE-MEASURE 4: measured in the harness, not on TiffinBox — Hikari's MXBean is not exposed by the
  anchor): the interceptor's two calls made by hand on the harness's main thread — Hikari **active 1 after the reads, still 1 before
  the close, 0 after it**: the connection stays taken from the first lazy read to the end of the "request"; the same read on a virtual
  thread refused (`an EntityManager bound here false`). **C7-18 paid** (*Your First Entity and EntityManager*, 03, said the next lesson
  needs open-in-view off and that this lesson comes back to it: the WARN line it printed is about this held context).
- **(b) EAGER** — labelled: B with `@OneToMany(mappedBy = "customer", fetch = jakarta.persistence.FetchType.EAGER)` (`.harness/ane`),
  port 20085: the page 200, the column right; **`GET /customers` 1 → 5 SQL lines**, the dashboard **8 → 12** — EAGER costs every list
  four more statements here. Harness (`ECustomer` on the anchor's own tables): `em.find` **1** statement (a join), a JPQL list **1 + 4**.
- **(c) `hibernate.enable_lazy_load_no_trans=true`** on B, port 20086: the page 200, **8 SQL lines**, the column right. Harness: the read
  with no transaction → 5 statements, **`getConnection` 5, `sessionOpenCount` 5** — a session and a connection per collection, plus the
  list's; its WARN lines: **0** (the count, said — 7.4.13 prints no warning for it).
- **(d) a transaction on the controller** — labelled: B with `@Transactional(readOnly = true)` on `DashboardPage.page`, the class still
  `final` (`.harness/and1`), port 20087 — **its own step, the refusal** (S5.20): `exit 1`, the port never bound, and from that step's
  log `Caused by: org.springframework.aop.framework.AopConfigException: Could not generate CGLIB subclass of class
  com.tiffinbox.web.DashboardPage: Common causes of this problem include using a final class or a non-visible class` ←
  `Caused by: java.lang.IllegalArgumentException: Cannot subclass final class com.tiffinbox.web.DashboardPage` — unit 23's refusal.
  Then **un-finaled** (`.harness/and2`: the route, both transactions, neither controller final), port 20087: ready; `Creating new
  transaction with name [com.tiffinbox.web.DashboardPage.page]` on the request thread, and every `findAll` on the virtual threads
  `Creating new transaction` (2), not `Participating` — **still 500**, the cause bound. The request-thread route with its own
  transaction (`[com.tiffinbox.web.TiffinBoxServer.paused]`): **200, 5 SQL lines**.
- **(e) `Hibernate.initialize`** — inside the read's own transaction: the same 5 statements as the transaction alone (harness, named,
  no beat).
- **The right one** — the boundary at the read (C1): the persistence context lives as long as the read, on the thread that reads;
  its price is said and handed on: 1 + N statements (unit 30, *N+1, Measured*).

**Bytecode enhancement (CARRIED, ⚑2):** not adopted and not measured — Hibernate 7's build plugin (`org.hibernate.orm:hibernate-maven-plugin`)
is in no seed, and `CustomerEntity` has no lazy basic field and no `@OneToOne` inverse side for it to change.

### The DDL did not move (R.252, `xcheck`)

Hibernate's script over `after/`'s libraries is `9cf92b8cae3abfd0f1c0706bfe7a4373`, `cmp` equal to `xcheck.sql` (filed here, a copy of
`../c7-unit27/xcheck.sql`) and to unit 27's own: **the same hash as in the lesson called Optimistic Locking with At-Version.**

## The commands this unit adds

The harness, compiled once against `after/`'s extracted libraries; its JVM, its arguments in two arrays (`V` the flags, `A` the
arguments, R.193); `xcheck`'s JVM; the H2 server; its `Shell` (the second connection; `$DB` the run's database name, `$Q` the query);
the first labelled copy (the others name more edits: `notx route`, `notx eager`, `notx pagetx`, `notx route pagetx routetx unfinal`);
the seven's run line:

```
javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/src/probe/u/H.java harness/src/probe/u/Main.java harness/src/probe/u/Run.java harness/src/probe/u/Seed.java harness/src/probe/u/SqlCounter.java harness/src/probe/u/Svc.java harness/src/probe/u/ent/ECustomer.java harness/src/probe/u/ent/EPause.java harness/src/probe/x/XMain.java
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../after/tiffinbox-web/target/extracted/lib/*" probe.u.Main "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -cp "../hc:../after/tiffinbox-web/target/extracted/lib/*" probe.x.XMain "${A[@]}"
cd .harness/run && exec perl -e 'alarm 3000; exec @ARGV' java -Duser.language=en -Duser.country=US -Dh2.bindAddress=127.0.0.1 -cp "../after/tiffinbox-web/target/extracted/lib/h2-2.5.250.jar" org.h2.tools.Server -tcp -tcpPort 20088 -ifNotExists
cd .harness/run && perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../after/tiffinbox-web/target/extracted/lib/h2-2.5.250.jar" org.h2.tools.Shell -url "jdbc:h2:tcp://127.0.0.1:20088/mem:$DB" -user sa -password '' -sql "$Q"
python3 -I harness/derive.py .harness/anb notx
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.org.hibernate.SQL=debug
```

TiffinBox itself runs the anchor README's own line (`java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431`,
read from `after/README.md` and asserted whole), its port changed, under the alarm with the locale pinned, followed by
`--tiffinbox.jdbc-url=…`, `--spring.datasource.username=sa`, `--logging.level.org.hibernate.SQL=debug` and
`--logging.level.org.springframework.orm.jpa.JpaTransactionManager=debug`, and each wrong fix's own options (printed whole in its
capture).

## The repository, and the network

Every Maven run is `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681 files; the brief allows s3 or s5 for 29 — s3 has every class this
unit runs). Eight Maven runs before the captures — `after/` and B with their tests (each build's summary lines summed and asserted 18 ·
0 · 0 · 0), `before/`, A′, (a), (b), (d) and (d) un-finaled with `-DskipTests` — and one inside a capture, in each of its three runs: `tests`; every one
`offline: yes`, 0 `Downloaded from` lines. **At run time** the harness binds no port; its databases are H2 in its JVM's memory
(`jdbc:h2:mem:u29`, xcheck's `x29`, the exercise's `ex`); TiffinBox's are on the H2 server, loopback only; TiffinBox listens on
`127.0.0.1` only and is asked by `curl` on the loopback. **No network act**: the section's dated sweep is the brief's
(`_research/spring-boot-metadata-2026-11-13.xml`, `spring-data-bom-metadata-2026-11-13.xml`, `hibernate-core-metadata-2026-11-13.xml`:
no 4.1.x patch, Hibernate 7.4.15 exists and is not adopted — ⚑8, R.223). Spring Framework's version is printed by every harness JVM from
`spring-tx`'s manifest (`7.0.10`), beside Spring Data JPA's (`4.1.2`), `Version.getVersionString()` and Hibernate's `HHH000001` line
(S4.13), before the context starts.

## The locale

The JVM ignores `LC_ALL` on macOS: every JVM this script starts carries `-Duser.language=en -Duser.country=US` on its java line, and the
hygiene check refuses a java line without it (and one without its alarm).

## The folders, the harness and the ports

- `before` → `../c7-unit27/after` (a link; `readlink` asserted); `after/` — this unit's tree, `../c7-tiffinbox` at this commit. Neither
  is built in place.
- `xcheck.sql` — Hibernate's script for `after/`'s two entities, filed (md5 `9cf92b8c…`, = `../c7-unit27/xcheck.sql`).
- `harness/` — `src/probe/u/Main.java` (a Spring Boot context, `WebApplicationType.NONE`, `@EntityScan({"com.tiffinbox", "probe.u.ent"})`,
  `@EnableJpaRepositories("com.tiffinbox")` — `Found 1 JPA repository interface.`; the three version lines first), `Run.java` (the
  scenarios `lazy`, `held`, `eager`, `notrans`, `tx`; each step clears the counters first and prints the three witnesses after it; it
  attaches the counting appender once Boot's logging is set up), `Svc.java` (the page's read three ways), `H.java` (helpers, the second
  connection, the JDBC proxy, Hikari's MXBean), `Seed.java` (the shipped `Database` on the run's database; Boot's pool wrapped in the
  proxy by a `BeanPostProcessor`), `SqlCounter.java` (the SQL logger's events), `ent/ECustomer.java` + `ent/EPause.java` (EAGER, on the
  anchor's own tables; `ddl-auto none`); `src/probe/x/XMain.java` (xcheck's context, unit 27's byte for byte); `src/probe/u/ex/ExApp.java`
  (the exercise's, compiled only by the exercise); `derive.py` (the labelled copies' named edits, each an exact text found once);
  `logback.xml`; `dur7.py` (the builders', byte for byte, md5 `41667fed…`); `surefire.py` (`../c6-unit28/harness/surefire.py`, byte for
  byte). No `Thread.sleep` in `harness/src` (asserted). English names only (R.215): Ravi, Meera, Sunil, Priya.
- `exercise/` — `README.md`, `SOLUTION.md`.
- `.harness/` (git-ignored, rebuilt by every run): `before`, `after`, `anb` (B), `ana2` (A′), `anr` ((a)), `ane` ((b)), `and1` ((d)),
  `and2` ((d) un-finaled), `tests`, `hc`, `run`, `s29.py` (the prose gate), `seg.py` (a request's lines between its markers),
  `chk29.py` (A's and B's witnesses), the logs, the second connection's reads, the token's files (0600). `.r-NAME.1-3` while a capture
  runs; `.r-NAME.out` its result (git-ignored).
- **Ports (§P, 20080-20089):** 20080 anchor B (and `seven`'s `before/`) · 20081 the H2 user trap (never bound: its start fails) and A (and
  `seven`'s `after/`) · 20082 A′ · 20083 (a) with the flag, the route in the same JVM · 20084 (a)'s control (the brief's "(a) route" port:
  the route is asked of 20083's JVM, so this port serves the control) · 20085 (b) · 20086 (c) · 20087 (d): the refusal binds none, the
  un-finaled copy listens there · **20088 the H2 TCP server** · 20089 never bound. All ten, 18425, 8080 and 35729 are checked free at
  the start and the end; each start checks its own port free first.

## Masks, filters and hygiene — every one, declared

Masks (awk `gsub` only, a planted self-test line before any capture): the generated token → `[masked: the token]`; this folder → `…`,
the folder above → `…/..`, home → `~`, the user name → `<user>`; ` using Java <version>`; an identity hash → `@…`; an EntityManager's
identity → `SessionImpl(<n><open>)`; a lambda class's address → `$$Lambda/<n>`; Spring Data's scan figure → `<n>`; a generated database
name; a context's start date; H2's constraint names; a 500 body's `"timestamp"` → `<time>`; **a virtual thread's number →
`virtual-<n>`, Tomcat's handler thread's → `omcat-handler-<n>`, the H2 Shell's row-count figure**; a failed start's jar URL →
`[jar:nested:<the jar>]` (before its line is cut). Filters: a harness JVM's log whole; a TiffinBox request by its lines between its two
markers, summarised by `seg.py` (SQL lines by thread kind, the manager's create lines with their thread kind, `Participating`, the
interceptor's Opening/Closing, the request's failure line, WARN lines); an HTML answer by its status (its table parsed by `chk29.py`), a
JSON answer whole (cut at 200); a failed start's WARN and ERROR lines and its `Caused by:` lines. Hygiene, over every capture: raw token
copies 0; no absolute path, unit number (quoted diff lines aside), log time, timestamp, numbered thread, start date, JDK or OS token,
elapsed figure, stack frame, unmasked identity or generated name, URL but TiffinBox's own loopback ports 20080-20087; every JVM pinned
and under its alarm; no kill by name, no bare `wait`; no `Thread.sleep` in the harness; no H2 database file outside `.harness`; no dish
name. **The prose gates, before any build** (over this README, `exercise/` and `after/README.md`'s unit 29 section): `s29`, per
sentence, with a 19-case self-test — dur7's words (R.172), S4.7's duration meanings (R.264; "for the whole request" is not one, and "a
second connection" is an ordinal: both in the self-test), **R.301's family** (BLUE's `tm.py` regex: the cost words only in a sentence that names a printed number of statements, connections or sessions), the brief's three words for pace, **R.286** (an unscoped verdict that open-in-view or a controller transaction
fixes the page), **R.287** (Hibernate 5/6's wordings), **R.190** (the eighteen voiced as the page's evidence); no dish name; no placeholder and no
empty "What it prints" block; no typed SQL outside the values block (R.225); **R.250's sentence set** (above).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid` — a harness JVM or
TiffinBox), the H2 server (`$spid`), the Maven or `javac` it waits for (`$mpid`, with every process under it), the exercise's shell
(`$xpid`), sweeps its own process group for any harness, exercise, H2 or TiffinBox JVM, Surefire fork, `javac` or Maven left, deletes
the capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched.

**Measured (2026-11-14, from 16:33 CET, on scratch mirrors of this folder — its files and `.m2-demo` cloned, `c7-unit27`, `c7-tiffinbox`,
`c5-unit11` and `c6-unit28` linked; the script as committed, the published captures copied in):** `receipts.sh` (/bin/bash 3.2) started
`env -i` in a session of its own **with SIGINT at its default** (`perl -MPOSIX -e '$SIG{INT}="DEFAULT"; setsid; exec …'`), `kill -INT` to
its group once the named process was in it, the state read 5 s after its exit — four trials:

```
build (surefirebooter seen: 2): processes in the group at SIGINT 5 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
harness (probe.u.Main seen: 1): processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
tiffinbox (tiffinbox.port=2008 seen: 1): processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
h2server (org.h2.tools.Shell seen: 1): processes in the group at SIGINT 5 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java left (pgrep -x java): 0
```

`build` — `after/`'s Maven build, its Surefire fork running; `harness` — the first harness JVM (`lazy`, `probe.u.Main`); `tiffinbox` —
TiffinBox's first start in `anchor` (B, port 20080); `h2server` — the H2 server running and its `Shell` (the second connection) in
`anchor`. `pgrep -x java` afterwards: none.

## 1 · lazy — the placeholder and the proxy (harness; S5.4)

One harness JVM over `after/`'s libraries; three steps. See *The placeholder and the proxy* above for every line it asserts.

## 2 · anchor — the change, and TiffinBox B / A / A′ (S5.15; the failure receipt is B)

The change (`diff -rq`, each source's diff whole), B with its cause bound per request, the H2 user trap, A with its parsed column, A′.

## 3 · wrong — the four wrong fixes, each with its count (S5.3, S5.14, S5.16, S5.20)

Six TiffinBox JVMs (one of them the refusal) and four harness JVMs; see the section above.

## 4 · seven — before/ and after/, a guard (R.190)

`466c20ed7e0d5439cb052f32ce09de1b` on both, 0 lines differ — the dashboard's JSON keeps its four keys; Hibernate's SQL lines during the
seven 5 → 10 (the JSON dashboard runs the fourth read too: 1 + 4 more).

## 5 · tests — TiffinBox's eighteen, on after/ (C7-4) — and on B, labelled

Surefire's XML: 18 (14/3/1) on `after/`, offline; and B's reports: 18 too — `TiffinBoxWebTest` mocks `Dashboard`, `FullStackTest`
mocks `CustomerRepository`: the tests did not notice B — guards, never witnesses (R.190).

## 6 · xcheck — the DDL over after/ (R.252)

`9cf92b8cae3abfd0f1c0706bfe7a4373`, the same as unit 27's: no mapping moved.

## 7 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s lines, then `SOLUTION.md`'s, exactly as written, in one `env -i` shell, `/bin/bash`, then `/bin/zsh -f`; each
file's "What it prints" block compared with the run, line for line.

## Exercise

"Your turn: the README's page lists each customer's paused days and fails outside a transaction. Make it work without open-in-view."
(20 words by `wc -w`.) A Spring Boot application of its own (`Diner` and `Break`, its own tables in its own H2 — not TiffinBox's
customers): the README's run throws `LazyInitializationException … role 'probe.u.ex.Diner.breaks' with key '2' (no session)`; the
solution's one line, `@Transactional(readOnly = true)` on the read, prints `{Meera=0, Priya=2, Ravi=0, Sunil=3}`. Broken ≠ solved by the
printed line, not the exit code (R.196).

## The ledger rows and hand-offs this unit pays

- **C7-18 — paid** (U03, *Your First Entity and EntityManager*: open-in-view "the next lesson needs it off, and *Lazy Loading and
  LazyInitializationException* comes back to it"): (a)'s interceptor lines on the request thread, beans 1, the control 0 / 0, the
  dashboard still 500, the request-thread route 200, the held connection (harness).
- **C7-4 — re-run** ("TiffinBox has tests now", 18): 18 from Surefire's XML after C1 (`tests`); carried to U39.
- **Call-backs by title** (R.224, each read in its script first): *Your First Entity and EntityManager* (03, the open-in-view WARN
  line), *The Persistence Context* (04), *@Transactional: What the Proxy Does* (23), *Optimistic Locking with @Version* (27, the DDL
  sentence, voiced "At-Version"). Forward by title: *N+1, Measured* (30), *Join Fetch vs EntityGraph vs BatchSize* (31).

## RE-MEASURE — the brief's items this unit settles

- **1** C1 on the frozen tree with its R.250 set and 18/18: settled (`anchor`, `tests`; 18/18 on `after/` and on B).
- **3** the wrong fixes as labelled copies under `.harness/`, the `final` refusal its own step, (a)'s flag-on run beside its control:
  settled (`wrong`).
- **4** open-in-view's held connection: kept in the harness (Hikari's MXBean), said so — TiffinBox exposes no pool reading during a
  request, and adding one would be a change to the anchor no lesson asks for.
- **10** the exercise as README + SOLUTION, bash + zsh, `env -i`: settled (`exercise`).

## What differed from the brief

- **The seed:** `m2-seed-c7-s3` (6,681 files), as 26-28 used — the brief allows s3 or s5 for 29; every class this unit runs is in s3.
- **The H2 server needs `-ifNotExists`.** The brief's line (`-tcp -tcpPort 20088`, `-tcpAllowOthers` not given, `-Dh2.bindAddress=127.0.0.1`)
  refused TiffinBox's first connection here: `Database "mem:u29b" not found, either pre-create it or allow remote database creation
  (not recommended in secure environments) [90149-250]` (the first development run). `-ifNotExists` lets a client create its database
  on the server; the server still accepts only local connections (its own line: `TCP server running at tcp://localhost:20088 (only
  local connections)`, and `lsof` shows `127.0.0.1:20088` alone, asserted every run). BLUE's runs had the same server; its flags are not
  filed in `$B`, so this is said, not compared.
- **The H2 user trap is filed here** as a labelled step of `anchor` (one JVM, port 20081, never bound) rather than named as 34's; 34 files
  p6spy's own form.
- **(a)'s ports:** the brief's 20083 (a) and 20084 "(a) route". The route is asked of the flag's own JVM (the brief: "from the same JVM"),
  so 20084 serves (a)'s control — the same copy without the flag. The `seven` capture reuses 20080 and 20081 (the brief gives it no port;
  each JVM is stopped and its port checked free before the next starts).
- **B is derived from `after/`** (`derive.py notx`: the one `@Transactional(readOnly = true)` line taken off `pausedDaysByCustomer`),
  not from `before/` with the probe's `edit.py page` — so B differs from A by that line alone (asserted: `diff -rq` names
  `CustomerRepository.java` alone).
- **(a) and (d) need a request-thread route,** which exists only on labelled copies (`anr`, `and2`); (d)'s un-finaled copy carries the
  route with its own `@Transactional(readOnly = true)` (`routetx`) and both controllers un-finaled, since the route's transaction meets
  the same `final` refusal on `TiffinBoxServer`.
- **RE-MEASURE 4 (the held connection) stays in the harness:** TiffinBox exposes no Hikari reading during a request (no pool metrics
  endpoint in the exposure list, none of its routes reads the pool); adding one is an anchor change no lesson asks for. On TiffinBox the
  interceptor's own lines and its bean are the switch-on witness; the held connection is the harness's `Hikari active 1 → 1 → 0`.
- **The dashboard's manager lines on B** show two `SimpleJpaRepository.findAll` transactions (the list and the fourth read's own
  findAll) — `monthRevenue` and `pausedDays` are JPQL queries that log no create line at this level; the brief's "every findAll on the
  virtual threads" is those two, counted.
- **The seven's SQL lines** move 5 → 10 during the seven (the JSON `/dashboard` runs the fourth read too: 1 + 4 more); the hash does not.
  A fact for 30, not a beat here.
- **`CustomerRepository`'s first Javadoc line** ("Unit 29/31: rows in, records out.") is older than Course 7 — it came with Core Java
  II's TiffinBox (commit `15c404c`, by `git log -S`); I did not trace what units 29/31 meant there, and rewrote it to name its origin
  and say it is not Course 7's (RED #1515's "said as Course 7's unit 29" read as: no longer readable as this unit).
- **The prose gate `s29`** (the brief: "your `s29.py` per sentence with a self-test as 28's `s28.py`") is a heredoc inside
  `receipts.sh` (28's form) with a 19-case self-test; S4.7's family is carried with one refinement — the article and the ordinal followed by connection,
  copy, run, JVM, database, read, request, time or dispatch is an ordinal, not a duration (in the self-test both ways); R.301's family is
  BLUE's `tm.py` regex byte for byte in its patterns. `dur7.py` is the builders', unchanged.
- **The exercise is a Boot application of its own** (`Diner`, `Break` — 28's form, its own tables), not the anchor's tables: the solution
  is one line, the same annotation C1 puts on `pausedDaysByCustomer`. The probe's `svctx` shape is the harness's `tx` scenario (e).
- **The plants and the SIGINT trials ran on the script one step before the committed one** (md5 `f8b94f1ab91c7f5efaaf1e89d3355c46`): two
  fixes came after them, both found by the first run of record — the `xcheck` capture named the version unit's folder in its last line
  (the hygiene check refused it; the line now says "the version lesson's xcheck.sql", and `xcheck`'s published hash moved with it), and
  the anchor note at the script's start had been left out (it now prints at the start and the end, as R.211 asks). Neither touches a
  check the plants exercised or the trap the trials exercised.
- **The H2 Shell's row-count line** carries an elapsed figure; it is masked to `(4 rows)` (R.207: no elapsed figure in a
  capture).

## Planted faults — each caught (R.65, R.226)

**The two measured plants of S5.15** (2026-11-14, a scratch script beside this folder: two copies of `after/` built offline from a clone
of `.m2-demo`, their own H2 server on 20088, TiffinBox on 20081, the receipt's own `chk29.py` fed each page or segment — nothing in this
folder written):

```
noread: GET /dashboard (text/html) -> 200
  the naive A check (grep -E "<td>Sunil</td>.*<td>3</td>" on the page): PASS
  A's check: the header 'Paused days' is column 6; the page Meera 0 · Priya 0 · Ravi 0 · Sunil 0; the second connection's sum Meera 0 · Priya 2 · Ravi 0 · Sunil 3 - FAIL
  A's check: exit 1
tpl: GET /dashboard (text/html) -> 500
  the status-only B check (HTML /dashboard 500): PASS
  the request failed with: org.thymeleaf.exceptions.TemplateProcessingException: Exception evaluating SpringEL expression: "view.pausedDaysByNam[c.name] ?: 0" …
  B's check: the key derived - the first customer by name on the second connection: Meera, id 2; the cause line with that key on the request thread: 0; the read's SQL on virtual threads: 4 - FAIL
  B's check: exit 1
```

`noread` = `after/` with the fourth read taken out of `Dashboard.load()` (the three-value constructor fills the map with nothing):
the page renders 200 with a column of zeros, and the grep finds Sunil's meals cell. `tpl` = `after/` with `pausedDaysByNam` in the
template: a 500 whose cause is the template's, not the read's. The template plant runs on A's tree: on B the read throws before any
template renders (BLUE's note, the same here).

**The rest, each on a scratch mirror of this folder** (its files and `.m2-demo` cloned, `c7-unit27`, `c7-tiffinbox`, `c5-unit11`,
`c6-unit28` linked; `receipts.md5` the published one), `./receipts.sh` `env -i` in a session of its own; each **exit 1**, `receipts.md5`
and `README.md` unchanged by the run. The late captures' plants ran with that capture moved first in the mirror's `receipts.sh` (the cap
lines reordered, nothing else) so the run reaches its check without the earlier captures:

| plant | caught by |
|---|---|
| open-in-view's verdict with no route and no thread, in a README line | R.286: an unscoped verdict |
| the plan's old exception text (Hibernate 5/6's collection wording) in a README line | R.287 |
| the eighteen tests voiced as the fix's evidence | R.190 |
| a number-word with "times" | R.301's family |
| the two-word phrase for "with no delay" | S4.7's family |
| one of dur7's pace words, in a README line | dur7 and the brief's three pace words |
| a dish name in `exercise/README.md` | R.215 |
| a to-do marker line | the placeholder gate |
| a typed SQL string outside the values block | R.225 |
| "Dashboard reads three" left in `after/`'s `Dashboard.java` | R.250's grep: after/ still says three reads |
| a wrong published hash (`lazy`) | `lazy is not the published capture` |
| the Framework version line taken out of `Main.java` | `lazy`'s version check (S4.13) |
| (d) with the controller un-finaled but labelled as the refusal | `the server on 20087 is still running (or listens) - its start was to fail` (S5.20) |
| (a)'s `/actuator/beans` read replaced by a typed "beans: 1" | (a)'s switch-on check (S5.16, R.302) |
| (a) run without the flag | (a)'s switch-on check (S5.16) — and every run of record fails the same check on the control, by design |
| the solution's line made the README's (broken = solved) | `exercise: the solution's page: none` (R.196) |
| a changed What-it-prints line (`Sunil=4`) | the exercise's block-against-run comparison |

Not run as plants: a 500 shown without its cause (the capture prints the cause line, and B's check runs inside the capture — the
`tpl` plant above is that case).

## The anchor moved on — the re-run of 27 (R.211, RED #1200)

`grep -n c7-tiffinbox` before the commit (R.211, the brief's EVIDENCE BATCHES), over `_builders/*.py`,
`~/Desktop/PromptVidya-Automation/check_unit7.py` and `qa_java7.py`: 22 builders name it — `s701.py`-`s707.py`, `s709.py`, `s715.py`,
`s716.py` (each reads `git show <sha>:c7-tiffinbox/…`, no live comparison); `s717.py`-`s728.py` but none of `s708`, `s710`-`s714` (each
asserts its `after/` against `git show <sha>:c7-tiffinbox/<p>` and prints a `note:` line per live difference); `check_unit7.py` and
`qa_java7.py` — no line; no `s729` exists yet. **`s717.py` run once after the move** (a scratch copy with `_builders/dur7.py` beside it, so
its `OUT` is the copy's folder and nothing is written into the course; `~/.venvs/slides2video/bin/python s717.py`): exit 0, eleven
`note: c7-tiffinbox has moved on since f620c1a (a later change to the anchor); after/ is checked against f620c1a: …` lines (27 saw nine:
the two new are `Dashboard.java` and `dashboard.html`), then `anchor: after/ = f620c1a:c7-tiffinbox in its 4 changed files; diff -rq
against the live c7-tiffinbox: 11 lines` — the expected sign.

**`../c7-unit27/receipts.sh`** (unchanged, md5 `f5fc28b49cce946c0427e79dd45192a4`) — the previous anchor-change unit — run once on the
moved anchor, `./receipts.sh` (/bin/bash 3.2.57), `env -i`, a session of its own, from 16:05:24 CET: **exit 0 in 439 s**; it printed its
note at its start and its end (`(after/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit froze: Files
after/README.md and ../c7-tiffinbox/README.md differ;Files after/…/CustomerRepository.java and …`), all 9 captures 3/3 = published,
`receipts.md5` unchanged (`0b1bfe1cd6a330cc8facdb760eb233ac` before and after), its log through `check_unit7.py 27 --runlog` PASS. 28, 26,
22 and 17 were not re-run (RED #1200: their notes fire the same way; 28's `anchor` links to `../c7-unit27/after`, which did not move). The
dated "Re-run after unit 29 moved the anchor" paragraph is in `../c7-unit27/README.md`.

## CARRIED

- **Bytecode enhancement** — named above, not measured (no seed holds Hibernate 7's build plugin).
- **The N+1 on TiffinBox** — unit 30 measures it on this tree (44 / 41 with 36 imported customers: RE-MEASURE 5, 30's).
- **The fetch plan** — unit 31 (C2) changes `pausedDaysByCustomer` to the entity graph, its transaction kept (RE-MEASURE 2).
- **The H2 user trap's p6spy form** — unit 34 files its own step.

## For RED

- **The A/B witnesses can fail and did** (S5.15): the fourth read removed renders 200 with a column of zeros — A's parsed check exits 1
  while a `Sunil … 3` grep passes (Sunil's meals cell is 3); a misspelt template field on `after/` answers 500 with a `SpelEvaluationException`
  — B's cause-bound check exits 1 while a status-only check passes (Planted faults). The checks run inside the capture on the raw log
  segment between the markers; the capture prints their verdict lines.
- **(a)'s switch-on check runs on both JVMs every run:** it must pass on the flag's run and fail on the control (asserted) — R.226's
  "a check that can fail" is shown in every run of record, not only in a plant.
- **The held connection is the harness's,** on the main thread with the interceptor's two calls made by hand — not TiffinBox's
  interceptor. A slide that says "TiffinBox held the connection" overstates it; "open-in-view holds the connection until the request
  ends — measured in the harness with the interceptor's own two calls" is what the capture holds.
- **(c)'s 0 WARN lines** is the harness JVM's (root logger at WARN, `grep -c '^WARN '`), and TiffinBox's own request segment also shows
  `WARN lines: 0` for the no-trans page.
- **(d)'s refusal line is cut at 220 characters** in the capture (`… a non-visible clas …`), as every `startfail` line is; the README
  quotes the whole sentence — its tail (`class`) is the log's, read in `.harness/run.out` during development, not in the capture. A
  slide should quote the capture's text up to "final class".
- **The key '2'** is derived in three places, independently: the harness's second connection (`lazy`), H2's Shell on the TiffinBox database
  (`anchor`, `wrong`), and the exercise's own ids (`Diner` Meera, id 2 by insertion order: Ravi 1, Meera 2) — the exercise's key is its
  own table's and is asserted as printed, not derived.
- **Not measured here:** PostgreSQL (⚑7); the N+1 with 36 imported customers (30's); the fetch plans (31's); bytecode enhancement.
