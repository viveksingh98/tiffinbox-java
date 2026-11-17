# c7-unit39 — Capstone: TiffinBox on Postgres

Course 7, Section 7's capstone, and **Course 7's last change to the anchor** (brief flag 1, C3): `before` is the link to
`../c7-unit38/after` (its tree's hash pinned), `after/` is this unit's tree — **Course 7's final anchor and the starting point of Course 8, *Spring Data beyond JPA*** —
and `../c7-tiffinbox` equals `after/` from this unit's commit on. Unit 40 changes the repository's root README only. TiffinBox's jar
holds PostgreSQL's driver now, and **TiffinBox runs on PostgreSQL — the config tree's URL or the dev profile — with its own driver**:
its schema is Flyway's three migrations, it reads a window of customers by keyset, it loads the dashboard in one statement, and three
tests in a real PostgreSQL container fail if that statement count ever grows. On PostgreSQL — the config tree's URL or the dev profile —
Kavya, lost after every restart since the last course, stays; the default in-memory run still forgets her, by design. The 18 tests stay on H2
in memory and need no Docker; the three new ones need Docker and run at `mvn verify` alone.

Six captures, each run in three passes by `receipts.sh` and hashed (`receipts.md5`); every number and string below is asserted right
after its capture by `harness/chk39.py`, against another witness of the same run — psql in this run's container, Surefire's two report
folders, the test's own JdbcTemplate, Testcontainers' own log lines and the engine's events over each Maven run's window — never
against a typed figure.

<!-- runs: begin -->
**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`, `DOCKER_CONFIG=$HOME/.docker`),
`.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s6/` alone, the image `postgres@sha256:77f58511…` present
(`docker -H "$DH" image inspect`, the full digest). Development runs fixed the captures and the checks; the published hashes are the
development passes', and every run of record matched them. **The runs of record, on the script as committed (`receipts.sh` md5 printed
by `md5 -q` and named in the commit message):** 518 s under `./receipts.sh` (/bin/bash 3.2.57, 2026-11-17 from 07:05 CET), 578 s under
`bash receipts.sh` (Homebrew bash 5.3.9, from 07:14 CET) and 597 s from a sealed fresh clone (below, from 07:30 CET): each exit 0, all 6
captures 3/3 = published, every check passed, every Maven run `offline: yes`, every Testcontainers run with Ryuk's three checks and no
pull, the anchor's `diff -rq` empty at the start and the end, `before/`'s tree pinned at both, this run's container removed with its
volume, the compose copy taken down with its volume, no Testcontainers container left (volumes 315 -> 315 in each run), the images
unchanged and none named ryuk, `~/.testcontainers.properties` absent, nothing listening on 20180-20189 at the end; each terminal log
through `check_unit7.py 39 --runlog` — `RESULT (run logs): PASS` (the unit gate: no 39 script yet). **Nothing was downloaded.**

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at `5266441` into a path **with a space** (`…/sealed
39/tiffinbox-java`, in the session's scratch folder), this commit's files put in as git will take them (`git ls-files -m -o
--exclude-standard c7-unit39 c7-tiffinbox c7-unit38 .gitignore`, links kept); the clone's `.m2-demo` seeded from a file copy of the seed;
dead proxies for http and https in its environment (`127.0.0.1:9`); `./receipts.sh`. Its first attempt (07:24 CET) stopped at R.318's
events check — **a container another session created on the same engine** (`ubuntu:24.04`, not this unit's) landed inside the verify's
window: `container creates 2, not the digest 1` — the check doing its job; the second attempt, from 07:30 CET, is the run of record.
The three runs ran on this README before the plants, the interrupt results and the closing sections were written — the only changes
since; a fourth run on the final text is recorded in the commit message.
<!-- runs: end -->

Published hashes (`receipts.md5`, every capture 3/3 in every run):

```
anchor 7b9015a14b917db3482103320aab55b1
dev 60d4f2763e61af67ba124621a0cf256c
tests 6ac654f42e1393391e8585fe1ec9d931
seven e6048268a31c0c3c707bca768df944bd
xcheck c40a503acf4f967990a07ee4ffd968c3
exercise 181cbc74e17b37bbc446343611d47c8c
```

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line; a SQL string typed in
this README outside this block and the blocks the runs printed is refused):

<!-- values: begin -->
the values the video may say: on PostgreSQL 18.6 and H2 2.5.250, Testcontainers 2.0.5, Flyway 12.4.0, Spring Boot 4.1.2, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - anchor: the jar's libraries 94 -> 96 (+ postgresql-42.7.14.jar, + checker-qual); B (before/'s jar on the config tree's URL, no driver): exit 1, nothing listened, Failed to load driver class org.postgresql.Driver <- ClassNotFoundException: org.postgresql.Driver; A (after/'s jar, its own driver, the config tree's URL): Flyway migrates V1-V3, history 3 rows success t, POST Kavya 201, GET /dashboard 200 with 4 SQL lines (HTML and JSON), the JSON's four keys, stopped by its pid; psql between the JVMs: 5 rows, 5 Kavya; JVM 2: Schema "public" is up to date. No migration necessary., GET /customers/Kavya 200, 5 listed; the anchor's EMF hibernate.hbm2ddl.auto = validate; A' (the default java -jar, H2 in memory): POST Kavya 201, the restart -> GET /customers/Kavya 404, 4 listed; C7-3: V1's GENERATED BY DEFAULT AS IDENTITY twice, id YES BY DEFAULT by psql, unit 06's syntax error at or near "AUTO_INCREMENT" quoted · dev: a COPY of compose.yaml (project c7u39-dev, 127.0.0.1:20187): the dev profile from Maven's class path - Using Docker Compose file, Container c7u39-dev-postgres-1 Started and Healthy, Flyway migrates V1-V3, HHH10001005 Database JDBC URL [jdbc:postgresql://127.0.0.1:20187/tiffinbox] while tiffinbox.jdbc-url still says jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1 (two URLs, one used), POST Kavya 201, the stop leaves the container Exited (0) and the volume c7u39-dev_data; JVM 2: up to date, GET /customers/Kavya 200 through the named volume; down -v: 0 containers, 0 volumes, 0 networks left · tests: which tests run where: 18 on H2 in memory, 3 on PostgreSQL in a container; mvn verify under the recipe (DOCKER_HOST=unix://$HOME/.orbstack/run/docker.sock, TESTCONTAINERS_RYUK_DISABLED=true, a receipt home): exit 0, surefire-reports 18 (TiffinBoxWebTest 14, FullStackTest 3, FeedTest 1) + surefire-reports-it CustomerEntityRepositoryIT 3 = 21, failures 0, errors 0; Testcontainers version: 2.0.5, Found Docker environment with Environment variables, Ryuk has been disabled 1, 1 container create of the digest, 0 image pulls, 0 containers left; the mapped port read off the run, masked <port>; IT: PostgreSQL 18.6, flyway_schema_history 3 rows, hbm2ddl.auto validate, a saved customer's stamps set (the slice's @EnableJpaAuditing); customers 40 · paused days 77 · prepareStatementCount 1 (days 77 != 1 + N = 41); windows 10 · 10 · 10 · 10, hasNext false on the fourth; the keyset SQL select ce1_0.id,ce1_0.created_at,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal,ce1_0.updated_at,ce1_0.version from customer ce1_0 where ce1_0.name>? or ce1_0.name=? and ce1_0.id>? order by ce1_0.name,ce1_0.id fetch first ? rows only; mvn package with Maven's DOCKER_HOST at nothing: exit 0, 18, 0 container creates; mvn verify the same: exit 1, 18 + 1 = 19 (the IT class errors 1), Could not find a valid Docker environment, BUILD FAILURE; the N+1 plant: expected: 1L but was: 41L (customers 40 · paused days 77 · prepareStatementCount 41), exit 1; the same N+1 with getQueryExecutionCount(): green, exit 0 - shown, never shipped · seven: 466c20ed7e0d5439cb052f32ce09de1b on before/ and after/ (H2 over TCP) and on after/ on PostgreSQL (its own driver, the config tree's URL) - the same bytes; SQL lines during it 6 on all three · xcheck: Hibernate's script over after/'s libraries f4f15b9c71145930e75568c4e64ab595 = the auditing lesson's, byte for byte (the keyset method and the tests move no mapping) · exercise: the data slice on embedded H2 (no Docker), 40 customers, paused days 77, the N+1 read: getQueryExecutionCount() counts 1 and the test passes (Maven exit 0); the solution getPrepareStatementCount() counts 41 -> expected: 1L but was: 41L, Maven exit 1 (25 words)
<!-- values: end -->

### C3 — the change, file by file, and every sentence it rewrote (R.250)

`harness/chk39.py r250` runs before any build: C3's file list (two new, three changed, none deleted or renamed), the files C3 leaves
alone (`application.yaml`, `compose.yaml`, the `Dockerfile`), and every sentence of `after/` that C3 makes false.

- `tiffinbox-web/pom.xml` — `org.postgresql:postgresql` in **run-time** scope: the executable jar gains the driver and the library it
  brings, `checker-qual` (the `anchor` capture prints both jar names and both counts). In **test** scope, four more, every version
  Boot's parent's (Testcontainers 2.0.5, no version typed): `spring-boot-starter-data-jpa-test`, `spring-boot-testcontainers`,
  `testcontainers-postgresql`, `testcontainers-junit-jupiter`. And Surefire's second execution, `container-tests` (phase
  `integration-test`, goal `test`, includes `**/*IT.java`, report folder `target/surefire-reports-it`); Surefire's own execution keeps
  its default includes, which leave `*IT` out — `chk39.py static` asserts the pom's text: one `<includes>`, one `<execution>`, no Failsafe.
  The comments say why: `package`, `install`, `-Pnative` and the Dockerfile's `mvn -B package` need no Docker; `verify` does.
- `tiffinbox-web/src/test/java/slice/DataSlice.java` — **new**: the data slice's configuration, beside the web slice's `WebSlice`, with
  a Javadoc saying why a slice needs its own: `@SpringBootConfiguration`, `@EntityScan("com.tiffinbox")`,
  `@EnableJpaRepositories("com.tiffinbox")` and **`@EnableJpaAuditing`**. Measured once, in development, without that last line:
  the IT's saved customer kept both stamps null, `IT a saved customer's stamps: createdAt null · updatedAt null`, and its count test
  failed on the check that follows it (Surefire: failures 1) — the slice needs the auditing listener the application switches on in
  `TiffinBoxApp`, and the shipped IT asserts the stamps set.
- `tiffinbox-web/src/test/java/com/tiffinbox/CustomerEntityRepositoryIT.java` — **new**: `@DataJpaTest` (Hibernate's statistics on, in
  its properties only), `@ContextConfiguration(classes = DataSlice.class)`, `@Testcontainers`, one `@Container @ServiceConnection`
  `PostgreSQLContainer` from `postgres@sha256:77f58511…` (`asCompatibleSubstituteFor("postgres")`), no `@AutoConfigureTestDatabase`.
  Three tests: the migrations are the schema; the dashboard's read is one prepared statement; forty customers ten at a time by keyset.
  The count test's fixture pauses every generated customer for two days, and the test asserts the days differ from one more than the
  customers **before** it asserts the count (R.333). Its comment carries the counter sentence of *N+1, Measured*, byte for byte (R.252).
- `tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntityRepository.java` — `Window<CustomerEntity>
  findFirst10ByOrderByNameAsc(ScrollPosition position)` and a Javadoc paragraph: keyset paging, the id Spring Data adds as the
  tie-breaker (R.235), a web route that pages left to Course 9's *REST APIs Done Right*.
- `README.md` (the anchor's) — a header note (Section 7's capstone: Course 7's final anchor, C3), a unit 39 section (its build section:
  which commands need Docker, the OrbStack lines, Docker Desktop not measured; which tests run where), and a unit 39 note on every
  sentence C3 made false: unit 06's "TiffinBox declares no Postgres driver"; unit 36's "this tree holds no PostgreSQL driver" and "the
  capstone moves TiffinBox's own database" (it keeps the default and adds the driver); Course 5's *Docker Compose for Development*'s "Postgres runs beside TiffinBox,
  not under it" (C7-7) and "the Postgres driver on the class path (not in this project)"; Course 6's *Testing the Web Layer*'s "`package` and `install` run
  the tests now" (still the eighteen; `verify` runs three more); the "Verified" section's `mvn -o -B verify` (it needs Docker since); the
  stale Build section gains a pointer. Kept, true where scoped: every "18 tests" that is a unit's own history or Surefire's own
  execution; unit 38's "Unit 39 changes it next (C3)". `chk39.py r250` asserts each note beside its sentence, every "no PostgreSQL driver"
  within reach of a unit 39 note, and no new PROBE or RED word in any file C3 touched.

## The captures — what each one shows

### 1 · anchor — B / A / A′ on PostgreSQL with TiffinBox's own driver, and the default (the failure receipt is B)

Every start here is `java -jar` on a jar this unit built, its URL in its own config tree (`secrets/tiffinbox/jdbc-url`, mode 0600,
under `.harness/`, unit 34's form) — **nothing is added to any class path**: `before/`'s `lib/` holds no `postgresql-*.jar` and
`after/`'s holds its own, both printed (R.335, the inverted form: no line of this unit says the harness adds a driver). One container
per run, `c7u39-pg`, from the pinned image (`--pull never`, `127.0.0.1:20188`, `docker port` asserted), a fresh database per run
of TiffinBox, dropped after it.

- **B — `before/`'s jar (38/after), port 20180:** refused. The run's lines:

```text
exit 1 · it listened on: nothing · ready: no · 'Failed to load driver class org.postgresql.Driver' lines in its log: 7 · 'Application run failed': 1
Caused by: java.lang.RuntimeException: Failed to load driver class org.postgresql.Driver
Caused by: java.lang.ClassNotFoundException: org.postgresql.Driver
psql - the database it was given: tables 0
```

  The chain runs from Flyway's bean through the DataSource to the class loader (each `Caused by:` once, in the capture). The driver is
  what this unit adds; a restart on 38/after is never shown as keeping a customer.
- **A — `after/`'s jar, its own driver, JVM 1 on 20181:** Flyway migrates the fresh database, V1 to V3; psql reads the history table
  (three rows, `success` t) and the two identity columns (`id YES BY DEFAULT`, V1's `GENERATED BY DEFAULT AS IDENTITY` — C7-3 cited);
  Kavya's POST answers 201; `GET /dashboard` answers 200 in HTML and JSON, the SQL logger's lines between each request's markers
  counted, the JSON's four keys. Stopped by its pid. **Between the JVMs, nothing running**, psql reads the customers: Kavya is there.
  **JVM 2 on 20182**, the same jar on the same database: Flyway says `Schema "public" is up to date. No migration necessary.`, and
  **`GET /customers/Kavya` answers 200** — the hook, with both witnesses (psql between the JVMs and the second JVM's answer). Then
  `probe.u.Emf` reads the anchor's own EntityManagerFactory on that database: `hibernate.hbm2ddl.auto = validate`, and it started
  (R.330), with its version lines (Flyway 12.4.0 among them, R.329).
- **A′ — the default, `java -jar` with no URL (application.yaml's H2 in memory), two JVMs on 20183:** Kavya's POST answers 201; the
  restart answers **404** for her, four customers listed. C7-1's first cause is avoided by configuration on PostgreSQL, not retired: the
  default in-memory run still forgets her, by design.
- C7-3, cited: V1 holds the identity line twice and no `AUTO_INCREMENT`; the refusal is quoted from the README of *Ids and Generation
  Strategies* (its `pgstart` capture), and Flyway's failed V3 on both databases from the README of *Flyway: Versioned Migrations* (its
  `fail` capture) — the two halves of Course 11's sentence (below).

### 2 · dev — the dev profile on a COPY of the anchor's compose.yaml (labelled: a copy)

`after/compose.yaml` copied to `.harness/dev/` with its project name `c7u39-dev` and its port `127.0.0.1:20187` (the diff is printed:
two lines) — never `tiffinbox-dev`, never 18881. TiffinBox from Maven's class path (the `dependency:build-classpath` line of Course 5's *Docker Compose for Development*; it
holds `spring-boot-docker-compose`), `--spring.profiles.active=dev`, cwd that folder, Boot's own docker CLI calls given the pinned
socket through `DOCKER_HOST`. JVM 1: `Using Docker Compose file …/.harness/dev/compose.yaml`, the container created, started and
healthy, Flyway's three migrations, Kavya's POST 201; the stop leaves the container `Exited (0)` and its named volume `c7u39-dev_data`.
JVM 2: the container started again, `up to date`, `GET /customers/Kavya` 200 through the named volume. Then `docker -H "$DH" compose -p
c7u39-dev -f .harness/dev/compose.yaml down -v`: no container, volume or network of that project left (printed).

**Which database answered** (R.325) is Hibernate's `HHH10001005` line, printed in both JVMs:

```text
HHH10001005 - the database Hibernate connected to: Database JDBC URL [jdbc:postgresql://127.0.0.1:20187/tiffinbox]
the YAML's tiffinbox.jdbc-url, after/ (no flag here changes it): jdbc-url: jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1
```

Two URLs, one used: on Maven's class path the dev profile's service connection beats `spring.datasource.url`, whatever
`tiffinbox.jdbc-url` says.

### 3 · tests — 18 on H2 in memory, 3 on PostgreSQL in a container, read from two report folders

**Which tests run where: 18 on H2 in memory, 3 on PostgreSQL in a container.** `after/` copied to `.harness/tests`; the README's two
export lines and its verify line, offline, with a receipt home (below):

- **verify, under the recipe** → exit 0. `surefire-reports` (read by `harness/surefire.py`): TiffinBoxWebTest 14, FullStackTest 3,
  FeedTest 1; `surefire-reports-it`: CustomerEntityRepositoryIT 3 — failures 0 and errors 0 in both (R.321: the sum is read off the two
  folders, never typed; the values block quotes it). The IT's own lines, the port masked:

```text
IT the database: jdbc:postgresql://localhost:<port>/test?loggerLevel=OFF · PostgreSQL 18.6
IT flyway_schema_history: 3 rows [1 customer and pause true, 2 seed true, 3 customer audit columns true]
IT customers 40 · paused days 77 · prepareStatementCount 1
IT window 4: 10 customers, from Customer 0000031 to Sunil · hasNext false
```

  The keyset read's SQL is Hibernate's own line (the slice's `show-sql`), quoted in the values block: the WHERE on the name and then
  the id, the same two in the ORDER BY — the id is the tie-breaker Spring Data adds (R.235). The days are not one more than the
  customers on the count line (R.333, asserted by the check too).
- **package, with Maven's `DOCKER_HOST` pointed at nothing** (`env DOCKER_HOST=tcp://127.0.0.1:1 mvn …`, Maven's env alone — R.332;
  the pinned CLI answers meanwhile, a non-empty image list) → exit 0, the 18, no `surefire-reports-it`, no container created (R.334: the
  Dockerfile's `mvn -B package` is the same command).
- **R.179 — verify, the same env** → exit 1, `BUILD FAILURE`, `Could not find a valid Docker environment`; the 18 pass, then the
  container class counts one error in place of its three tests (`surefire-reports-it`: tests 1, errors 1) — never "passed" (R.321).
- **The two plants of R.320**, on a scratch copy of `after/` whose web tests are the plant alone (the IT copied, renamed, its lines that
  differ printed), each under the recipe — shown, never shipped: the N+1 read (`findAll(Sort.by("name"))`) under the shipped counter →
  **exit 1**, `expected: 1L but was: 41L`, the count line `IT customers 40 · paused days 77 · prepareStatementCount 41`; the same N+1
  asserted by `getQueryExecutionCount()` → **exit 0, green**, the same count line. The shipped IT asserts `getPrepareStatementCount()`
  (grep, printed).

Every Testcontainers run (the verify and the two plants) passes **Ryuk's three checks** (R.318): the pre-flight before Maven, the log's
`Ryuk has been disabled` once, and the events — one `container create`, its image the digest, no `image pull`; no Testcontainers
container left after it. The mapped port is read off each run (Testcontainers' JDBC URL line and the test's own URL agree) and masked
as `<port>` (R.319); the last check of the whole receipt greps every capture for those numbers and refuses them.

### 4 · seven, 5 · xcheck

**seven:** before/ and after/ on H2 over TCP (the run's H2 server on 20184, a database per JVM, shut down after it), and after/ on
PostgreSQL (its own driver, the config tree's URL, a fresh database): the same seven responses, byte for byte, on all three — the
md5 in the values block, the one unit 31 published; no JSON carries a time or an id. **xcheck:** Hibernate's DDL over after/'s
libraries without Flyway's jars = `xcheck.sql` = `../c7-unit38/xcheck.sql`, diff 0: the keyset method and the tests move no mapping.

### 6 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s block, then `exercise/SOLUTION.md`'s, read from the files and run in ONE `env -i` shell (no `DOCKER_HOST` in it,
printed), `/bin/bash --noprofile --norc` then `/bin/zsh -f`; each file's "What it prints" block = what it printed. **Here the broken
test is GREEN and the solution is RED** — the lesson's point: the README's test counts the queries, and it passes while the page runs
one statement per customer; the solution counts the statements, and fails, `expected: 1L but was: 41L`. The data slice on an embedded
H2 database (Boot's `Replacing 'dataSource' DataSource bean with embedded version`, counted): RE-MEASURE 4, filed.

## Which tests run where — and the machine recipe

**18 on H2 in memory, 3 on PostgreSQL in a container.** `mvn package`, `mvn install`, `-Pnative` and the Dockerfile's `mvn -B package`
run the 18 and need no Docker; `mvn verify` runs the 18, then the three container tests, and needs Docker. **The recipe on OrbStack**
(the anchor README's build lines; R.318, R.319, R.332): Testcontainers 2.0.5 does not find OrbStack by itself — `/var/run/docker.sock`
is a dead Docker Desktop socket on this Mac and it ignores the docker CLI's context — so the one line
`export DOCKER_HOST=unix://$HOME/.orbstack/run/docker.sock`; and `export TESTCONTAINERS_RYUK_DISABLED=true`, because Ryuk, Testcontainers'
cleanup container, is another image every viewer would pull, and only that env switches it off (a `ryuk.disabled` file key is
ignored). The receipt adds: a pre-flight before any Maven run (`curl --unix-socket … /_ping` answers `OK`, the env set, the receipt
home's `.testcontainers.properties` holding `checks.disable=true` and `tinyimage.container.image=postgres@sha256:77f58511…` and no
`ryuk.*` key — else it stops before Maven); the receipt home as `user.home` of Maven's JVM (`MAVEN_OPTS=-Duser.home=../home`) and of
both Surefire forks (`-DargLine=… -Duser.home=../../home`, the forks' own folder: a path with a space survives neither `MAVEN_OPTS` nor
`argLine`); `~/.testcontainers.properties` asserted absent before and after; every docker call through `docker -H "$DH"` with non-empty
baselines first; no image named ryuk before or after; the image list equal; the volume count equal. **On Docker Desktop** the default
discovery is expected to work — not measured here (no Docker Desktop ran on the author's Mac). With Ryuk off a test JVM killed by force
leaves its container: the trap removes `label=org.testcontainers=true` containers with `-fv` (measured under SIGINT, below).

## The pinned sentences (R.252)

- *N+1, Measured*'s counter sentence, byte for byte from `../c7-unit30/pinned.txt`, in the IT's comment (asserted by `chk39.py static`):
  "Hibernate's statistics count every statement it prepares; the count of queries leaves out the collection loads."
- **Course 11's** *Testcontainers vs H2, Honestly* (`../../_briefs/TRACK-ROADMAP.md:487`), in `pinned.txt` for Course 11, line 1, byte for
  byte: "H2 accepted TiffinBox's old AUTO_INCREMENT line and kept a half-applied migration; PostgreSQL refused the first and rolled back
  the second." — its first half from *Ids and Generation Strategies*' capture (H2 read both id forms as one column; PostgreSQL refused
  `syntax error at or near "AUTO_INCREMENT"`), its second from *Flyway: Versioned Migrations*' (H2 kept the half-applied column and its
  `success=FALSE` row; PostgreSQL rolled the failed file back whole); the `anchor` capture quotes both READMEs' lines, and
  `chk39.py static` asserts both say so. `pinned.txt`'s line 2 is Course 11's *The Persistence Layer* counter (`:492`, asserting query
  counts): `SessionFactory.getStatistics().getPrepareStatementCount()`.

## Refused, named

- **The native binary** (C7-14 closed) — the profile of Course 5's *AOT Processing and Native Image*; Course 7 builds no binary. The
  ledger's sentence (RED #1810):

```
the pom's native profile is Course 5's; no Course 7 unit runs it — `native-image` is not installed here
```

- **The static metamodel**: the capstone's tests use no typed criteria — not built.

## Call-backs, by title (R.224)

Course 5's *Docker Compose for Development* (the dev profile's service connection, the copy's form); Course 6's *Testing the Web Layer*
(a test slice, the web slice beside the data slice); *N+1, Measured* (the counter sentence and `getPrepareStatementCount()`); *Ids and
Generation Strategies* (C7-3); *Flyway: Versioned Migrations* (the history table, the failed V3); *Auditing and Soft Deletes* (the
stamps the slice needs); Course 9's *Pagination, Filtering and Sorting as an API Concern* in *REST APIs Done Right*
(`TRACK-ROADMAP.md:385`: the web route that pages); Course 10's *Spring Security — complete*, whose "users in a database"
(`TRACK-ROADMAP.md:61`) will be a table in this migration folder; Course 11's *Testcontainers vs H2, Honestly* (`:487`) and *The
Persistence Layer* (`:492`). Unit 40, *What's Next: Not Everything Is a Relation*, closes the course and changes the root README only.

## The commands this unit adds

The lines `receipts.sh` reads from this file and runs (each checked by `grep -x` before it runs):

```bash
docker -H "$DH" exec c7u39-pg psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c "drop database if exists $DB with (force)" -c "create database $DB"
docker -H "$DH" compose -p c7u39-dev -f .harness/dev/compose.yaml down -v
docker -H "$DH" exec c7u39-pg psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c "drop database $DB with (force)"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -cp "../hc:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" probe.u.Emf --logging.config=../../harness/logback.xml --logging.level.org.hibernate.orm.core=info --spring.main.banner-mode=off
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -cp "../hc:../$LIBS/*" $MC "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../hc:../after/tiffinbox-web/target/extracted/lib/h2-2.5.250.jar" probe.u.Db "jdbc:h2:tcp://127.0.0.1:20184/mem:$DB;DB_CLOSE_DELAY=-1" $OP "$Q"
cd .harness/run && exec perl -e 'alarm 3000; exec @ARGV' java -Duser.language=en -Duser.country=US -Dh2.bindAddress=127.0.0.1 -cp "../after/tiffinbox-web/target/extracted/lib/h2-2.5.250.jar" org.h2.tools.Server -tcp -tcpPort 20184 -ifNotExists
javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/after/tiffinbox-web/target/extracted/lib/*" harness/src/probe/u/U.java harness/src/probe/u/Db.java harness/src/probe/u/Emf.java harness/src/probe/x/XMain.java
docker -H "$DH" exec c7u39-pg psql -U sa -d "$DB" -qAt -v ON_ERROR_STOP=1 -c "$Q"
docker -H "$DH" exec c7u39-pg pg_isready -U sa -h 127.0.0.1 -q
docker -H "$DH" run -d --pull never --name c7u39-pg -p 127.0.0.1:20188:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v "$U/.harness/secrets/pgpw:/run/pgpw:ro" postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.org.hibernate.SQL=debug
env "MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8" perl -e 'alarm 600; exec @ARGV' mvn -o -B -Dmaven.repo.local="$M2" "-DargLine=-Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Duser.home=../../home" clean verify
env DOCKER_HOST=tcp://127.0.0.1:1 "MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8" perl -e 'alarm 600; exec @ARGV' mvn -o -B -Dmaven.repo.local="$M2" "-DargLine=-Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Duser.home=../../home" clean $GOAL
```

## The repository, and the network

Every Maven run is `mvn -o` against this unit's own `.m2-demo`, seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s6/` alone
(`postgresql-42.7.14`, `testcontainers-2.0.5`, `testcontainers-postgresql`, `testcontainers-junit-jupiter`, `spring-boot-testcontainers`
and `spring-boot-starter-data-jpa-test` are in it; `maven-failsafe-plugin` is not, asserted — Surefire's second execution needs nothing
new); every build's log is checked for a download line. The PostgreSQL image is used by its digest (`--pull never` for this run's
container; Testcontainers by the digest, no pull event; the compose copy's `postgres:18-alpine` tag is the same local image, no pull
event). Nothing leaves the machine; every listener is on 127.0.0.1.

## The folders, the harness and the ports

`before` → `../c7-unit38/after` (its tree pinned by `harness/tree39.py`, unit 33's `tree33.py` byte for byte); `after/` this unit's tree;
`exercise/`: `README.md`, `SOLUTION.md`, `CountersTest.java`; `pinned.txt`; `xcheck.sql` (= unit 38's); `harness/`: `chk39.py` (the
checks), `s39.py` (the prose gate, unit 38's `s38.py` carried with this unit's readings), `dur7.py` (the builders', as shipped),
`surefire.py` (the testing lesson's, byte for byte — run once per report folder), `logback.xml`, and `src/`: `probe.u.U` (version
lines), `probe.u.Db` (H2's shutdown, the second connection's form), `probe.u.Emf` (the anchor's EMF), `probe.x.XMain` (unit 29's, byte
for byte). Ports: 20180 B · 20181-20182 A · 20183 A′ · 20184 the H2 TCP server · 20185 the seven's TiffinBox · 20186 the dev profile's
TiffinBox · 20187 the compose copy's PostgreSQL · 20188 this run's container · 20189 never bound; Testcontainers' port is OrbStack's,
read off each run and masked; all ten free at the start and the end.

## Masks, filters and hygiene — every one, declared

Masked in every capture: the token, the password (`<pw>`), this folder and its parent, the home folder (`~`), the user name, JDK versions,
identity hashes, a lambda's address, Flyway's `(execution time …)` and Testcontainers' `started in PT…S` (R.264: `<t>`), and
**Testcontainers' mapped port, by the number each run read off** (`localhost:<port>`, R.319 — never a range). Filtered: TiffinBox's
Flyway lines by their message, Boot's compose lines by their message, a Maven run by its exit, its BUILD line, the engine's events and
Surefire's reports; a Testcontainers run by its own lines. Raw token and password copies counted before the mask and asserted 0 after
it; the last check refuses any read-off port number in any capture. **Docker:** every call names its socket (R.332), the baselines
non-empty first; this run's container removed with its volume (`rm -fv`), the compose copy with `down -v`, Testcontainers' containers by
their label with `-fv` in the trap; the volume count asserted unchanged (R.322); no image named ryuk, before or after.

## Interrupted

Ctrl-C at any point: the trap stops what the run started (a JVM, a Maven run and its Surefire fork, the exercise's shell, the H2
server), sweeps its process group, removes this run's container with its volume, removes any Testcontainers container (label
`org.testcontainers=true`) with `-fv`, takes the compose copy's project down with `-v`, deletes a config-tree URL left under
`.harness/`, drops the unfinished capture passes and exits 130.

Measured on the script as committed, `env -i ./receipts.sh` started as its own process group and sent SIGINT as a terminal sends it, at
six points: **mid-build** (a Maven run), **mid-H2-server** (just after the server listened), **mid-container** (just after
`pg_isready`), **mid-TiffinBox on PostgreSQL** (A's JVM listening in `anchor`), **mid-compose** (the copy's container running in `dev`:
the trap printed its `down -v` line) and **mid-verify** (a Testcontainers container running: the test JVM's own shutdown removed it
before the trap looked, so the trap's label sweep found none to remove): each exit 130, no JVM of this run left, no container
`c7u39-pg`, no Testcontainers container, no container or volume of the project `c7u39-dev`, the volume count the same as before the
run (315 -> 315), nothing listening on 20180-20189, no `.r-lock`, no unfinished capture pass, no config-tree URL left, the published
captures unchanged.

## The ledger rows this unit pays

**C7-1 — paid, scoped:** cause 2 retired at unit 36; cause 1 avoided on PostgreSQL by configuration (the config tree's URL or the dev
profile: the restart, psql between the JVMs, the second JVM's 200); the default `java -jar` still `jdbc:h2:mem:` and still forgets her
(A′'s 404) — said. **C7-3 — cited** (the identity columns; unit 06's refusal quoted). **C7-4 — closed:** Surefire's 18 + the IT's 3, read
from two report folders; `package` stays 18 and Docker-free; `@DataJpaTest` in the same `src/test`. **C7-7 — paid:** Postgres runs
under TiffinBox now — its schema, its migrations, three of its tests. **C7-14 — closed:** Course 7 builds no binary (the sentence
above). Pinned for later courses: Course 11's two, *Testcontainers vs H2, Honestly* and *The Persistence Layer* (above); the migration folder as where the users table of Course 10, *Spring Security — complete*, will go.

## RE-MEASURE — the brief's items this unit settles

**4** — the exercise on embedded H2, both counters: measured and filed (`exercise`: 1 and 41, the days beside them). **7** — C3 on
38/after: 3/3 under the receipt's Testcontainers recipe (the receipt home, the ping, the events, the volume count) in every run of
record. **8** — the `dev` capture on a copy of the anchor's own `compose.yaml` (project renamed, port 20187), `down -v` after it and in
the trap.

## What differed from the brief

1. **The receipt home reaches each JVM by a relative path** (`MAVEN_OPTS=-Duser.home=../home` for Maven's JVM, `-Duser.home=../../home`
   in `argLine` for both Surefire forks — each one's own working folder): the brief's absolute `<.harness/home>` broke on the first
   development run, because this unit's folder sits in a path with a space and neither `MAVEN_OPTS` nor `argLine` keeps a quoted
   space (`Could not find or load main class Content.LearnProgrammingWithVivek…`). `-Dstdout.encoding=UTF-8` joins both: under the
   receipt's `LC_ALL=C` Maven printed the IT's `·` as `?`.
2. **The pre-flight runs right before the first Maven run that can start Testcontainers** (the `tests` capture's verify), after
   the `anchor` and `dev` captures — not before the receipt's `-DskipTests` builds, which start no container. The Ryuk-env plant
   therefore stops there: before Maven, after the two earlier captures, no pull.
3. **The two counter plants run on a scratch copy of `after/` whose web tests are the plant alone** (the 18 deleted from the copy, the
   shipped IT replaced by the renamed plant), one `mvn verify` each under the recipe: each plant's exit is its own (1 and 0), and its
   container is the only one in its window.
4. **The compose copy needs no password**: the anchor's `compose.yaml` uses `POSTGRES_HOST_AUTH_METHOD: trust` on 127.0.0.1, and the
   copy changes only its project name and port (the diff is printed). This run's own container keeps its generated 0600 password.
5. **Ports:** the seven's TiffinBox binds 20185 for all three runs (H2 twice, then PostgreSQL); the EMF JVM binds no port (20182 is only
   asserted free around it); A′'s two JVMs both use 20183. B and A start with `java -jar` on the built jar (the extracted folder is
   used for the library counts and the harness's class path only).
6. **"PROBE (0)" and "RED (0)" in `after/`** are read as "C3 adds none": the anchor README carries older row numbers (`RED B2 #116`,
   `RED C5-S2 #8`, Courses 5 and 6's history); `chk39.py r250` refuses any PROBE word and any RED or PROBE word C3 adds. The IT's own
   lines start `IT `, not `PROBE`.
7. **`surefire.py` is run once per report folder**, byte for byte the testing lesson's (not extended).
8. **R.318's log and events plants, R.319's raw port, R.329's missing version line and R.332's unpinned CLI are shown as check plants**
   on copies of the `tests` capture (each `chk39.py tests` exit 1), and the unpinned CLI is measured directly under an exported
   `DOCKER_HOST=tcp://127.0.0.1:1` (an empty list, exit 1, beside the pinned CLI's images) — a full receipt run per plant would cost a
   run of record each.
9. **The exercise's `EX` line uses commas, not `·`:** the exercise runs in `env -i`, where Maven's console has no UTF-8 locale.
10. **`@EnableJpaAuditing` in the slice** — measured once in development (the stamps null, the count test failed on the stamp check
    before its count), so `DataSlice` carries it and the IT asserts the stamps set.
11. **HHH000001 twice in the verify log** — one per Surefire fork (the 18's and the IT's); Boot's banner once per context.
12. **The volume count is asserted at the end only**: while this run's container is up it holds one anonymous volume of its own.
13. **The anchor was moved with `rsync --delete`** from `after/` (no ignored file existed in `c7-tiffinbox`; `git status` showed only C3).

## Planted faults — each caught (R.65, R.226)

**Receipt plants** — each on a fresh scratch mirror of this folder (the siblings it reads linked read-only), `./receipts.sh` in `env -i`;
each exit 1, the captures unchanged, no Testcontainers container left, no image named ryuk, no pull:

- R.320 — the plant puts `getQueryExecutionCount()` in the shipped IT's assertion → `chk39.py static` stops before any build.
- R.333 — the fixture's pauses at one day (days = 1 + N) → static stops.
- R.334 — the IT renamed `CustomerEntityRepositoryTest` → static stops; and measured on a scratch copy: `mvn -o package` with Maven's
  `DOCKER_HOST` at nothing → exit 1, `Tests run: 19, Failures: 0, Errors: 1`, `BUILD FAILURE` — the reason the class is an IT.
- R.252 — `pinned.txt`'s sentence for Course 11's *Testcontainers vs H2, Honestly* one word off → static stops.
- R.322 — `rm -f` without `-v` in `pgrm` → the static grep stops.
- R.250 — one unit 39 note removed from the anchor README → `chk39.py r250` stops.
- R.318 pre-flight — the Ryuk env dropped and `ryuk.disabled=true` written into the receipt home → the run reaches the `tests` capture
  and stops there, `Maven not started`, before any Testcontainers JVM: no pull, no ryuk image.
- A wrong published hash (one hex digit of `anchor`'s) → `anchor is not the published capture`.
- The mask's `started in PT…S` rule broken → the mask's self-test stops (R.264).
- A changed "What it prints" line in `exercise/README.md` → the exercise comparison stops (`3c3`).
- Prose, each one sentence added to this README → `s39` refuses it (quoted here as code, which the gate does not read): `19 passed`
  (R.321), `On 38/after the restart keeps her` (R.335), `Kavya stays` (RED #1807), `tiffinbox.jdbc-url is the database that answered`
  (R.325), `The tests need Docker` (R.334), a typed library count (R.302), an Indian dish name (R.215), `a few seconds` (dur7).

**Check plants** — a copy of one capture with one edit, read by `chk39.py`; each exit 1 on its FAIL line: the Ryuk log line counted 0
(R.318 log); a second `container create` of `testcontainers/ryuk:0.14.0` in the events line (R.318 events); the raw port in the IT's
URL (R.319); `Testcontainers version: 2.0.5` counted 0 (R.329); the pinned CLI's baseline empty during the plant (R.332); the IT's
no-Docker report read as errors 0 (R.321); the N+1 plant green (R.320); the days at 41 (R.333); a container-test report under
`package` (R.334); the dev run's `HHH10001005` URL an H2 one (R.325); B started (R.335); A′'s restart answering 200 (C7-1's scope); Kavya
missing from psql between the JVMs (the hook); the solution printing Maven exit 0 (R.196); the seven on PostgreSQL differing; xcheck's
diff not 0. And measured directly: the docker CLI **unpinned** under an exported `DOCKER_HOST=tcp://127.0.0.1:1` — `docker images -q`
exit 1, an empty list (`Cannot connect to the Docker daemon`), where `docker -H "$DH" images -q` lists the images: the comparison that
passes on two empty lists, which R.332's non-empty baselines refuse. **A check that cannot fail** (R.276): every check above failed on
its plant.

## The anchor moved on — the builders, and the re-run of 38 (R.211, R.331)

`grep -n 'c7-tiffinbox\|filecmp' _builders/*.py ~/Desktop/PromptVidya-Automation/check_unit7.py
~/Desktop/PromptVidya-Automation/qa_java7.py` before the commit (R.211, ⚑1): `check_unit7.py` and `qa_java7.py` — no line; the four
builders step 36.0 guarded (`s703`, `s706`, `s707`, `s709`) keep their `os.path.exists` line; `s715.py` and `s716.py` `filecmp` files
36, 38 and 39 keep against the live anchor, and C3 changes two of them (`CustomerEntityRepository.java` and the README) while deleting
or renaming none, so each comparison prints a note and never stops; `s717.py`-`s734.py` diff the live tree and print notes. **Each run
once from a scratch copy with `_builders/dur7.py` beside it** (`~/.venvs/slides2video/bin/python sNNN.py`, nothing written into the
course): `s715.py` exit 0 with 5 `note:` lines, `s716.py` exit 0 with 4 (both as unit 38 saw them: C3's two files were already among
them), `s717.py` exit 0 with 22 — unit 38's twenty and C3's two new test files (`Only in …/c7-tiffinbox/…: CustomerEntityRepositoryIT.java`,
`… slice: DataSlice.java`). No builder fails on the moved anchor; none was edited.

**`../c7-unit38/receipts.sh`** (unchanged: its `md5 -q` the one 38's commit message names) — the previous anchor-change unit — run
once on the moved anchor, `./receipts.sh` (/bin/bash 3.2.57) in `env -i` with `DOCKER_CONFIG=$HOME/.docker`, from 06:13 CET: **exit 0
in 315 s**; its note at its start and its end (`(after/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit froze:
Files after/README.md and ../c7-tiffinbox/README.md differ;…`), all 7 captures 3/3 = published, `receipts.md5` unchanged (`md5 -q` the
same before and after), its container removed with its volume (315 -> 315), its log through `check_unit7.py 38 --runlog` PASS. 35, 36
and 37 were not re-run (RED #1200). The dated "Re-run after unit 39 moved the anchor" paragraph is in `../c7-unit38/README.md`; its
own "39 moves the anchor next (C3)" sentences stay true and are not edited.

## The root .gitignore

`c7-unit39/`'s five lines (`.m2-demo/`, `.harness/`, `.r-*`, `**/target/`, `**/secrets/`) landed in unit 36's commit — verified, not
edited.

## For RED

- **Kavya's restart is scoped** in every sentence of this README: on PostgreSQL — the config tree's URL or the dev profile — she stays;
  the default in-memory run forgets her (A′'s 404). The scripts must carry the same scope (RED #1807).
- **The counts are read, never typed:** the two report folders give the sum on a verify with Docker; without Docker the IT class
  counts one error in place of its three tests (the values block). The script may say the numbers the values block says.
- **The keyset SQL** is Hibernate's own line from the slice's `show-sql`; the tie-breaker is Spring Data's, in both the WHERE and the
  ORDER BY.
- **Testcontainers' port moves every run** (OrbStack's, outside the operating system's 49152-65535): masked by the number read off, refused raw by the last check.
- **Docker Desktop is not measured** — the README says the default discovery is expected to work there, and says it was not measured.
- **The engine's events window** counts every container created on the engine during a Maven run; another session's container in that
  window would fail the check (none did).
- **The plants' scratch copies** hold no web test; their exits are their own. The wrong counter's plant prints the same count line as
  the N+1 plant and passes — the shipped IT is the right counter's.
