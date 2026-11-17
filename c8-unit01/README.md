# c8-unit01 — Why Another Data Module

Course 8, Section 1 (Spring Data JDBC), unit 01 — **a harness unit: no anchor change.** It measures the persistence context as a
count on the anchor as unit 02 *Aggregates, Not Entities* left it (both Spring Data modules on one context), and what the module
without one pays instead, on PostgreSQL 18.6 in a container (the store the numbers are measured on) and on H2 in memory beside it.

- `anchor` → `../c8-unit02/after` (a link; both modules; `../c8-tiffinbox` equals it today, `diff -rq` empty, printed by every run).
  `harness/tree01.py` pins its tree: the file count and the md5 in `receipts.md5`'s `anchor-tree` line, written from a run's own output.
- `jpa-only` → `../c8-unit02/before` (a link; **the JPA-only tree**, RED #8): `diff -rq` against `git archive 50d64ac c8-tiffinbox` is
  empty at every run's start, and `receipts.md5`'s `jpa-only-tree` line pins it too.
- Nothing in either tree is edited. Every tree is copied under `.harness/` and built there, offline, from `.m2-demo` (a copy of the
  course's seed `spring-data-beyond-jpa/_research/m2-seed-c8-s1/`).

**The three names, at first use (C8-7, §10):** *Spring Data J-P-A* (`spring-data-jpa`, the module the anchor has used all along, Hibernate under it),
*Spring Data J-D-B-C* (`spring-data-jdbc` with `spring-data-relational`, the module unit 02 added) and *Spring Data* — the umbrella
project whose shared layer is Spring Data Commons (`spring-data-commons`: `Repository`, `Sort`, the derived-query parser) under both.

**The persistence context, in Course 7's words (C8-8, R.204)** — Course 7's *The Persistence Context*, quoted byte for byte from its
script and pinned in `pinned.txt`: "That's the set of entities one Entity Manager has loaded and keeps track of, at most one object per row."
This unit attaches the number Course 7's *What's Next: Not Everything Is a Relation* promised it.

Run it: `./receipts.sh` from this folder (JDK 25, Maven, OrbStack's docker socket, the postgres image by its digest already on the
machine — the script never pulls). Every number below is a line a run printed; the values block is assembled from `harness/chk01.py`'s
output and compared with this file byte for byte.

## The captures — what each one shows

Six captures, each run three times and hashed (`receipts.md5`); each is read back by `harness/chk01.py` against a second witness of
the same run before its hash is compared.

### 1 · data — the data line, before any count (RE-MEASURE 4)

A fresh database in the container; the harness's `seed` step adds the customers and pauses by `JdbcTemplate` outside any window,
then counts; psql, a second client, reads the same line back. V2's own rows are counted first, after Flyway, before the seed.

```text
PROBE before the seed (PostgreSQL 18.6, JdbcTemplate): customers 4 · pauses 2
PROBE data (PostgreSQL 18.6, JdbcTemplate): customers 40 · pauses 38 · paused days 77
psql (a second client, PostgreSQL): 40 customers · 38 pauses · 77 paused days
```

### 2 · context — the number: one transaction, three windows (R.347, R.355, R.357)

ONE `TransactionTemplate`. Window A is Spring Data JPA's `findAllByOrderByNameAsc()` (the dashboard's customer read, its entity graph
fetching the pauses); window B is Spring Data JDBC's `CustomerAggregates.findAll(Sort.by("name"))` in the same transaction; window A′
is A again. After each window the harness reads `Session.getStatistics()` — the persistence context of that transaction — and the
witness's window. On every Spring Data JPA window the witness (datasource-proxy 1.11.1 on the `DataSource` bean) and Hibernate's
`getPrepareStatementCount()` are printed side by side and asserted equal (exit 3 otherwise). The entity count is asserted equal to the
data line's customers plus pauses, derived, never typed; the collection count to one per customer.

```text
PROBE r1 window A (Spring Data JPA findAllByOrderByNameAsc(), PostgreSQL 18.6): customers 40 · pauses in them 38 · the persistence context holds entities 78 · collections 40
PROBE r1 window A: the witness 1 · Hibernate getPrepareStatementCount() 1 · equal: yes
PROBE r1 window B (Spring Data JDBC findAll(Sort.by("name")), the same transaction, PostgreSQL 18.6): aggregates 40 · pauses in them 38 · the witness 41 · the persistence context holds entities 78 · collections 40
PROBE r1 window B: SELECTs from pause by customer_id 40 · other statements 1
PROBE r1 window B (PostgreSQL 18.6) SQL x40: SELECT pause.id AS id, pause.days AS days FROM pause WHERE pause.customer_id = ?
PROBE r1 window A' (A again, PostgreSQL 18.6): customers 40 · the same objects as A's: yes · the persistence context holds entities 78 · collections 40
PROBE r1 the commit (readOnly = false): flushCount 1 · findDirty calls 78 · entityUpdateCount 0 · entityLoadCount over the transaction 78
PROBE r1 readOnly = true, window A (PostgreSQL 18.6): customers 40 · the persistence context holds entities 78 · collections 40
PROBE r1 the commit (readOnly = true): flushCount 0 · findDirty calls 0 · entityUpdateCount 0
the two PostgreSQL JVMs' PROBE lines, diff: 0 lines differ
```

- **The read with the read (R.367):** window B's statements against window A's, both from the witness in one transaction. Window B
  is one customer SELECT plus one SELECT from `pause` per aggregate (the witness's SQL list, sorted and counted by text, R.358); window A
  is one statement, its pauses joined by the entity graph.
- **Spring Data J-D-B-C added none:** the persistence context's count after window B equals the count after window A — two printed
  counts; the delta is derived from them (RED #7). Its aggregates are plain objects; Hibernate never sees them.
- **A′ is the same objects:** the second JPA read returns the very instances window A put in the context — at most one object per row,
  the sentence above, measured (`the same objects as A's: yes`).
- **The flush (RED #6, RE-MEASURE 2):** `DirtyCount`, a Hibernate `Interceptor` named by `hibernate.session_factory.interceptor` on the
  harness's command line, counts `findDirty` — Hibernate calls it once per entity the context holds when a flush runs its dirty check.
  The count is read inside the transaction just before the commit and again after it; the commit's own flush is the difference, beside
  Hibernate's `getFlushCount()` read the same way. Then the same transaction with `readOnly = true`: no flush, no dirty check.
- **Two JVMs (6/6):** PostgreSQL, two JVMs, each on its own fresh database, three rounds each; `diff` of the two JVMs' PROBE lines is
  empty (the SQL lists are sorted and counted, so no order to mask, and no database-state line differs). The same capture runs the
  steps once more on **H2 in memory**: the same counts, every round (chk01 prints `H2 against PostgreSQL: the same counts`). The number's
  store is PostgreSQL 18.6; the slide names it.

### 3 · statements — the other half: the page three ways (R.355, R.367)

The dashboard's whole page from one JVM, a witness window per side: Spring Data JPA's `Dashboard.load()` (the anchor's four reads, on
four virtual threads); Spring Data JDBC — `findAll(Sort.by("name"))` plus the two `@Query` sums, days by name from the aggregates; and
`JdbcClient` with four SQL strings. The harness calls `Dashboard.load()` directly, with no web server: no page is fetched over HTTP, so
TiffinBox never binds 20400. Revenue and paused days are asserted equal on all three sides; the pause SELECTs are counted by a grep of
the witness's SQL list.

```text
PROBE r1 page JPA (Dashboard.load(), PostgreSQL 18.6): customers 40 · revenue 240300 · paused days 77 · days by name 77 · the witness 4 · entityLoadCount 118 · collectionLoadCount 40
PROBE r1 page JPA: the witness 4 · Hibernate getPrepareStatementCount() 4 · equal: yes
PROBE r1 page Spring Data JDBC (findAll(Sort.by("name")) + monthRevenue() + pausedDays(), PostgreSQL 18.6): customers 40 · revenue 240300 · paused days 77 · days by name 77 · the witness 43 · of them SELECTs from pause by customer_id 40 · Hibernate getPrepareStatementCount() 0
PROBE r1 page Spring Data JDBC (PostgreSQL 18.6) SQL x40: SELECT pause.id AS id, pause.days AS days FROM pause WHERE pause.customer_id = ?
PROBE r1 page JdbcClient (four SQL strings, PostgreSQL 18.6): customers 40 · revenue 240300 · paused days 77 · days by name 77 · the witness 4 · Hibernate getPrepareStatementCount() 0
PROBE r1 page: revenue equal on all three: yes · paused days equal: yes
```

**The page with the page (R.367):** Spring Data JDBC's page against Spring Data JPA's page, each its own window of one run. The SQL
above is the witness's text on PostgreSQL 18.6, unquoted under unit 02's `JdbcNames` (on H2 the same capture prints the derived names
upper-case, `customer.ID AS ID`). Spring Data JDBC's default loads each customer's pauses with a SELECT of their own; single-query
loading is not this unit's (unit 03 *Relationships Without an ORM* names it, unit 06 *JPA vs JDBC vs Plain SQL* owns the table). U01
shows the two numbers only.

### 4 · tree — the version lines (⚑1, contract §3: the version-bound unit)

`mvn -o dependency:tree` on a copy of each tree, every module, the lines for the Spring Data jars, Spring Boot, Hibernate and Flyway
(sorted, one line per artifact); the Spring Data train read from Boot's own BOM in `.m2-demo`; the set-up's sweep read from its files on
disk (never online — the course's one network act was the seed build, contract §3, R.223).

```text
tree: org.springframework.data:spring-data-commons:jar:4.1.2:compile
tree: org.springframework.data:spring-data-jdbc:jar:4.1.2:compile
tree: org.springframework.data:spring-data-jpa:jar:4.1.2:compile
tree: org.springframework.data:spring-data-relational:jar:4.1.2:compile
tree: org.springframework.boot:spring-boot:jar:4.1.2:compile
spring-boot-dependencies-4.1.2.pom: <spring-data-bom.version>2026.0.2</spring-data-bom.version>
the sweep, spring-boot.xml: <release>4.2.0-RC2</release> · swept-at.txt: 2026-11-17T11:16:49Z
```

The JPA-only tree prints the same lines without `spring-data-jdbc` and `spring-data-relational`. Every harness JVM prints its own version
line too (Spring Boot, Spring Framework, the four Spring Data modules, Hibernate, Flyway, datasource-proxy) and `HHH000001`; chk01 asserts
one version line across all of them. The one sentence the video says about the next release, dated: 4.2.0 was a release candidate on 17 November 2026, and Course 8 stays on Boot 4.1.

### 5 · alone — what Spring Data JDBC alone would cost the anchor (§4.5; labelled: a COPY, never the anchor)

A copy of `anchor/` with Spring Data JPA's starter removed from `tiffinbox-web/pom.xml` (the probe's `nojpa`, re-measured on unit 02's
tree as committed, RED #8). `mvn package` runs the tests; the jar then starts with `java -jar` on 20402.

```text
removed from tiffinbox-web/pom.xml: <artifactId>spring-boot-starter-data-jpa</artifactId>
the copy's diff against anchor/: 4 lines, all in tiffinbox-web/pom.xml
mvn package: exit 0 · BUILD SUCCESS · Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
the copy's jar: lib/ 82 libraries (anchor/'s 99) · hibernate-core-*.jar: absent · spring-data-jpa-*.jar: present · spring-data-jdbc-*.jar: present
java -jar: exit 1 · listening on 20402: 0 · 'Application run failed' 1
the cause: Could not configure Spring Data JPA auditing-feature because spring-aspects.jar is not on the classpath;
```

The tests stay green because the test-scope JPA starter (`spring-boot-starter-data-jpa-test`) brings Spring Data JPA's starter back onto
the test class path; the jar has no Hibernate and refuses to start at `@EnableJpaAuditing`. Why the course keeps Spring Data JPA beside
Spring Data JDBC: the anchor without it does not start. (This differs from the brief's wording — see *What differed from the brief*.)

### 6 · exercise — run as written, in one shell, bash then zsh (R.196)

`exercise/README.md`'s lines, then `exercise/SOLUTION.md`'s, in ONE `env -i` shell — `/bin/bash --noprofile --norc`, then `/bin/zsh -f`;
each file's "What it prints" block is compared with what its lines printed, line for line. H2 in memory, no Docker, no Maven: the
block compiles `exercise/Ex01.java` against the jar this receipt built. The other solution `SOLUTION.md` names — the read through
`CustomerAggregates` — runs too, a `sed` on a copy, and is checked the same way: Ravi's row read back by `JdbcTemplate` and
`entityUpdateCount`, never which API did the read.

## The values the video may say

Assembled from chk01.py's `VALUES` lines; `receipts.sh` refuses this file unless the line below is byte-equal to what the run assembled.

<!-- values: begin -->
the values the video may say - data: the data line (PostgreSQL 18.6; JdbcTemplate = psql): customers 40 · pauses 38 · paused days 77 · context: the persistence context after window A (PostgreSQL 18.6, two JVMs x 3 rounds): entities 78 · collections 40 - customers 40 + pauses 38; after window B (Spring Data JDBC, the same transaction): entities 78; the read: window B 41 statements (1 + 40 SELECTs from pause) against window A 1 (= getPrepareStatementCount() 1); the commit: flushCount 1 · findDirty calls 78; readOnly = true: flushCount 0 · findDirty calls 0; H2 2.5.250: the same counts · statements: the page (PostgreSQL 18.6, one run, a witness window per side): Spring Data JPA Dashboard.load() 4 (= getPrepareStatementCount() 4; entityLoadCount 118 · collectionLoadCount 40) · Spring Data JDBC 43, of them 40 SELECTs from pause by customer_id · JdbcClient 4; revenue 240300 · paused days 77 on all three; H2 2.5.250: the same counts · tree: the dependency tree (anchor/, mvn -o dependency:tree): spring-data-jpa 4.1.2 · spring-data-jdbc 4.1.2 · spring-data-relational 4.1.2 · spring-data-commons 4.1.2 · Spring Data train 2026.0.2 · spring-boot 4.1.2 · hibernate-core 7.4.13.Final · flyway-core 12.4.0; the sweep (2026-11-17): Boot's newest 4.2.0-RC2 · alone: alone (a copy of anchor/ without Spring Data JPA's starter, never the anchor): mvn package exit 0, BUILD SUCCESS, Tests run: 18, Failures: 0, Errors: 0; the IT compiled: yes; the jar: 82 libraries (anchor/'s 99), hibernate-core absent; java -jar: exit 1 - Could not configure Spring Data JPA auditing-feature because spring-aspects.jar is not on the classpath; · exercise: the exercise (H2 in memory, no Docker; bash and zsh): broken - the persistence context holds 78, flushCount 1, entityUpdateCount 1, Ravi read back by JdbcTemplate meals 3 · version 1; readOnly = true - flushCount 0, entityUpdateCount 0, Ravi meals 2 · version 0; through CustomerAggregates - the context holds 0, entityUpdateCount 0, Ravi meals 2 · version 0; the spoken line 21 words
<!-- values: end -->

The pairs, as the slide must state them (R.367): **the read with the read** — window B's statements against window A's, one
transaction; **the page with the page** — Spring Data JDBC's page against Spring Data JPA's page, one run. A count from one window is
never set beside a count from the other operation. `118` (`getEntityLoadCount()` for the dashboard) is filed and said only if the
script needs it.

## Refused, named

- **The heap bytes (R.361):** the probe's one class histogram (one `jcmd` attach, before the second attach hung) is not a slide fact;
  this harness never attaches `jcmd` (the receipt greps the harness for it) and no capture holds a bytes figure.
- **`faster`, `lighter`, `simpler` (R.355, R.366):** refused by `s801.py` without a count beside them; dur8 words: 0.
- **Single-query loading (R.368):** U03's and U06's; this unit runs Spring Data JDBC on its default only.
- **A page fetched over HTTP:** not needed — the harness calls `Dashboard.load()` itself; 20400 is never bound.

## Call-backs, by title (R.224)

- Course 7's *The Persistence Context* — the definition sentence, byte for byte (`pinned.txt`; the receipt finds it in that script).
- Course 7's *Batching and the Write Path* — its sentence that a batch writer keeps the context to one chunk (C8-11) is not
  contradicted: this unit measures one read in one transaction, not a batch.
- Course 7's *What's Next: Not Everything Is a Relation* — it promised that *Why Another Data Module* attaches a number to the
  persistence context; the number is the values block's.
- Forward, by title only: *Aggregates, Not Entities* (U02 landed the module), *Relationships Without an ORM* (U03 owns the collection's
  SQL), *JPA vs JDBC vs Plain SQL* (U06 owns the table).

## The commands this unit adds

- The harness: `javac -parameters -d .harness/hc -cp "<anchor's jar>:<its lib/*>:$DSP" harness/src/probe/u01/*.java`, then
  `java -cp "../hc:<jar>:<lib/*>:$DSP" probe.u01.U1 <steps>` from `.harness/run`, with
  `--spring.jpa.properties.hibernate.generate_statistics=true` and
  `--spring.jpa.properties.hibernate.session_factory.interceptor=probe.u01.DirtyCount`; on PostgreSQL `--tiffinbox.jdbc-url=` the
  container's database. Steps: `seed`, `context`, `statements`. `$DSP` is datasource-proxy 1.11.1 in `.m2-demo` — on the harness's
  class path only; no harness POM, as unit 02 compiled its harness (the addendum).
- The container: `docker -H "$DH" run -d --pull never --name c8u01-pg -p 127.0.0.1:20401:5432 -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust postgres@sha256:77f58511…`
  — trust on loopback, as `compose.yaml` and the probe chose; no password anywhere. Removed with `docker -H "$DH" rm -fv`.
- The PostgreSQL driver is the anchor jar's own (`postgresql-42.7.14.jar` in its `lib/`, since Course 7's capstone); the harness adds none.

## The repository, and the network

`.m2-demo` is a copy of `spring-data-beyond-jpa/_research/m2-seed-c8-s1/` (6,966 files, `cp -c -R`). Every Maven run is `mvn -o` with
`-Dmaven.repo.local=.m2-demo`; each log is checked for `Downloading from` / `Downloaded from` lines (0, else the run stops). No image
pull, no metadata read, no network act; the sweep is read from its files. One `git fetch` was run by the agent before the work, to
verify `origin/main...main` = `0 0` (a read of the repository's own remote, not a course network act), and one `git push` at the end.

## The folders, the harness and the ports

- `harness/U1.java` (the steps), `harness/Witness.java` (unit 02's witness, its package line alone changed — the receipt diffs it),
  `harness/DirtyCount.java` (the flush counter), `harness/chk01.py` (the checks), `harness/s801.py` (the prose gate, its own
  self-test), `harness/dur8.py` (the builders', as unit 02 shipped it, `cmp`-checked), `harness/tree01.py` (Course 7's tree35.py method),
  `harness/logback.xml` (one line per event, no SQL logger: the statements are the witness's).
- `exercise/Ex01.java`, `exercise/README.md`, `exercise/SOLUTION.md`; `pinned.txt`; `receipts.sh`, `receipts.md5`.
- Ports, 20400-20409: **20401** the container · **20402** the alone copy's TiffinBox (refused before it binds; polled during the run:
  never listening) · **20400** never bound (no page fetched) · **20403-20409** spare, never bound. 18425 and 8080 (the anchor's own
  defaults) are checked free at start and end because the alone copy's tests run. All free at start and end (`lsof`).

## Masks, filters and hygiene — every one, declared

- Captures print selected lines only: each harness JVM's `PROBE` lines, its two `Found … repository interface` lines, Flyway's
  `Database:` line and `HHH000001`; Maven's exit, BUILD and Results lines; the exercise's own `EX` lines.
- The mask (self-tested at the start with a planted `Started … in 3.1 seconds (process running for 4.2)`, a `Time elapsed:` line, a
  scan line, a Flyway execution time and the folders — dur8 must find nothing in the masked text, R.366): the unit's folder → `…`, the
  repository → `…/..`, home → `~`, Boot's started-in, Surefire's elapsed, Flyway's execution time, Spring Data's scan time, Maven's total
  → `<t>`, identity hashes → `@…`.
- Hygiene, every capture: no absolute path, no unmasked time, no log time, no stack frame, no heap figure, the shutdown token absent;
  every `java`/`mvn` line under its alarm; no H2 file outside `.harness`.

## The ledger rows this unit pays

- **C8-2 — paid:** the persistence context's number — the values block's `context` entry: the entities and collections it holds after
  one read, unchanged by Spring Data JDBC's read in the same transaction, with window B's statements for the read and the page's
  statements (`statements`) beside it.
- **C8-7 — paid:** the three names glossed at first use (above; the receipt checks the three glosses are in this file).
- **C8-8 — paid:** Course 7's definition called back in *The Persistence Context*'s own words, byte for byte (`pinned.txt`).
- **C8-11 — checked:** *Batching and the Write Path*'s chunk sentence is about a batch writer; this unit measures one read.

## RE-MEASURE — the brief's items this unit settles

- **2 (the flush, RED #6):** re-filed on the data line of section 1: the commit's flush is one flush whose `findDirty` calls equal the
  entities held; `readOnly = true` makes it none (values block). Both exercise solutions measured.
- **4 (the data line):** built by the receipt before every count, in every JVM, and read back by psql (capture `data`).

## What differed from the brief

- **`alone`:** the brief (from the probe's `nojpa`) says FullStackTest and FeedTest error and the IT does not compile. Re-measured on
  unit 02's tree as committed (RED #8): `mvn package` is green, every test passes, and the IT compiles at test-compile — the test-scope
  `spring-boot-starter-data-jpa-test` puts Spring Data JPA's starter back on the test class path. The failure is the jar's: it holds no
  Hibernate and stops at start with the spring-aspects line (the brief's own cause sentence, now from `java -jar`). `mvn verify` is not
  run: the IT compiled already, and verify needs Docker for Testcontainers, which this unit's limits keep to one container.
- **The flush, read two ways:** before the commit, inside the transaction, the capture prints a non-zero `findDirty` count with
  `flushCount 0` — Hibernate's auto-flush check before window A′'s query ran the dirty check and found nothing to write, without
  counting a flush. The commit's own flush is therefore taken as the difference (after minus before), as stated; RED #6's single-read
  probe could not see this.
- **The container:** trust on loopback, user `tiffinbox`, no password (the probe's and `compose.yaml`'s choice) rather than unit 02's
  generated password file; the database's URL by `--tiffinbox.jdbc-url` on the harness's command line rather than the config tree.
- **No harness driver:** the anchor's jar holds `postgresql-42.7.14.jar` (the addendum); no line says "+ the harness's driver".
- **No harness POM:** datasource-proxy 1.11.1 is on the harness's class path only, compiled as unit 02 compiled its harness.
- **The exercise on H2, no Docker:** it reproduces 3/3 in bash and zsh, so the viewer's version needs no container (the brief left the
  store open). It needs the jar a receipt run built; it runs no Maven.
- **The tree pin and `c8-tiffinbox`:** the anchor's tree today hashes the same as `../c8-tiffinbox`, so a link pointed at
  `c8-tiffinbox` would pass the hash; the link's target is checked by `readlink` first (the plant below).
- **`spring-data-bom` 2026.0.2** is not a node of `dependency:tree` (a BOM is imported, not depended on): it is read from Boot's own
  `spring-boot-dependencies` POM in `.m2-demo`, the file named on the line.

## Runs of record

On the script as committed (`md5 -q receipts.sh` in the block), each exit 0, every capture 3/3 and `= published`, every Maven run
`offline: yes`, volumes 315 → 315, images unchanged, nothing listening on 20400-20409 at the end; each run's log through
`check_unit8.py 01 --runlog` — `RESULT (run logs): PASS` (the unit gate itself exits 2 until a script exists: "no 01-*.md in
scripts-and-decks/ yet").

```
receipts.sh md5 326eccfc23ad5c559c1f44b236157ef4
./receipts.sh        /bin/bash 3.2.57            exit 0   wall clock 192 s
bash receipts.sh     /opt/homebrew/bin/bash 5.3.9 exit 0   wall clock 192 s
sealed clone         git clone file://… into "…/scratchpad/ev01/clone dir/tiffinbox-java" (a path with a space), .m2-demo from the seed,
                     DOCKER_CONFIG=$HOME/.docker, http(s)_proxy pointed at 127.0.0.1:9 (dead): ./receipts.sh exit 0   wall clock 193 s
```

## Interrupted

SIGINT (`kill -INT` on the receipt, started with SIGINT at its default, as a terminal's Ctrl-C reaches it) at three points; after each:

```
SIGINT mid-build      exit 130 · container 0 · volumes 315 · listeners 20400-20409 0 · our JVMs/Maven 0 · partial .r-*.[123] 0 · .r-lock gone · captures (= published): = = = = = =
SIGINT mid-harness    exit 130 · container 0 · volumes 315 · listeners 20400-20409 0 · our JVMs/Maven 0 · partial .r-*.[123] 0 · .r-lock gone · captures (= published): = = = = = =
SIGINT mid-container  exit 130 · container 0 · volumes 315 · listeners 20400-20409 0 · our JVMs/Maven 0 · partial .r-*.[123] 0 · .r-lock gone · captures (= published): = = = = = =
```

Mid-build: during anchor's copy's Maven build. Mid-harness: during the data capture's harness JVM, the container up. Mid-container:
after `docker run`, before the harness. The EXIT trap stops the child's process tree by its pids, removes the container with its
volume and the partial capture files. (A first attempt started the receipt as a background job of a non-interactive shell, where
SIGINT is ignored on entry and cannot be trapped: the receipt ran to its end, exit 0, every capture = published. The test now resets
SIGINT to its default before it starts the receipt.)

## Planted faults — each caught (R.65, R.226)

On the sealed clone after its run of record, one plant at a time, the file restored after each; "nothing written" = the md5 of every
file in the folder but `.m2-demo` before and after the planted run. Plants 1-13 stop `./receipts.sh` in its gates, before any write;
plant 14 runs `harness/chk01.py context` on a doctored copy of the capture.

```
plant  1 78 typed in a SAY-like README line              exit 1 · nothing written: yes · R.302: a capture's number typed in prose: 78
plant  2 the JDBC count dropped (no persistence context) exit 1 · nothing written: yes · R.355: "no persistence context" without its statement count
plant  3 the heap bytes voiced                           exit 1 · nothing written: yes · R.361: a heap or bytes figure: 4,368 B
plant  4 J-D-B-C is faster                               exit 1 · nothing written: yes · dur8: faster
plant  5 43 against 1 on one line                        exit 1 · nothing written: yes · R.367: a pair across two operations: 43 against 1
plant  6 a builder fed Started ... in 3.1 seconds        exit 1 · nothing written: yes · R.366: the mask's self-test - a planted duration line passed it unmasked
plant  7 a wrong hash (the anchor's tree pin)            exit 1 · nothing written: yes · R.211: anchor/'s tree is …, the pin in receipts.md5 is … - the tree moved
plant  8 a typed count in SOLUTION.md                    exit 1 · nothing written: yes · R.302: a capture's number typed in prose: 40 customers
plant  9 a duration word                                 exit 1 · nothing written: yes · dur8: seconds
plant 10 the exercise's solution = broken                exit 1 · nothing written: yes · R.196: SOLUTION.md's block must be the README's with one line changed
plant 11 anchor pointing at c8-tiffinbox                 exit 1 · nothing written: yes · anchor must be a link to ../c8-unit02/after (it points at: ../c8-tiffinbox)
plant 12 the container removed without -v                exit 1 · nothing written: yes · R.322: receipts.sh removes a container without its volume (rm -fv)
plant 13 the docker CLI unpinned                         exit 1 · nothing written: yes · R.344: receipts.sh calls docker without the pinned socket
plant 14 a version line missing (chk01 context)          exit 1 · FAIL context: a version line in every JVM that started (2 of 3)
plants: 14 · caught: 14
```

Plant 6 is this receipt's own mask (the builders' masks are the script stage's, S8.24): the planted line is the brief's, the regex
that refuses it is the mask's `in [0-9.]+ seconds (process running for …)` rule, and the self-test feeds dur8 the masked text.
Plant 11 is caught by the link check, not by the tree pin — the two trees hash the same today (above).

## For RED

- **The pair is two windows of ONE transaction** (the read) and **three windows of ONE JVM** (the page) — never a count from one beside
  a count from the other. Check the values block's wording before the slide's.
- **The flush:** the commit's numbers are differences (after minus before) because window A′'s query triggers Hibernate's auto-flush
  check first — a dirty check over every held entity with no flush counted (the capture's `before the commit` line). Say "at commit"
  on the slide, as measured; the inside-the-transaction count is filed, not spoken.
- **`alone` differs from the brief** (green tests, the IT compiles; the jar refuses at start). The script's "what JDBC alone would cost"
  beat should say the start fails, not the tests.
- **H2:** the same counts as PostgreSQL in `context` and `statements`; the number's store on the slide is PostgreSQL 18.6.
- **Not measured here:** single-query loading (U03/U06), heap bytes (refused), a page over HTTP (not needed), `mvn verify` on the
  `alone` copy (not needed — the IT compiles at package's test-compile).
- **The exercise** needs `.harness/after/` from a receipt run (it compiles against that jar); a viewer runs `./receipts.sh` once first,
  as the README says. It needs no Docker and no Maven of its own.
