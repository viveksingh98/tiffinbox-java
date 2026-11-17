# c8-unit07 — Testing the JDBC Layer

Course 8, Section 1's last unit and **its second change to the anchor — in test scope only**. `before` is a link to
`../c8-unit02/after` (the link form of Course 7's units resumes here, as unit 02's README said it would: units 03-06 committed nothing under
`../c8-tiffinbox`, and the receipt asserts it); `after/` is this unit's tree, and `../c8-tiffinbox` equals `after/` from this unit's
commit on. **Unit 07 is Section 1's last anchor change; Section 2's first anchor change takes `before → ../c8-unit07/after`.**
TiffinBox gains a test that starts only its JDBC layer: Spring Data JDBC's test slice, `@DataJdbcTest`, started from a configuration
of its own (`slice/JdbcSlice`), on PostgreSQL 18.6 in a container by the digest Course 7's capstone tested against — not on the
in-memory H2 TiffinBox starts with by default — with an `@Sql` fixture that the test's own transaction rolls back. Nothing in
`src/main` changes.

Eight captures, each run three times by `receipts.sh` and hashed (`receipts.md5`); every number and string below is asserted right
after its capture by `harness/chk07.py`, against a second witness of the same run — Surefire's XML reports against Maven's Results
lines, the engine's events against Testcontainers' own log, the connection's product line against Flyway's Database line, V2's seed
rows against the fixture's counts, the repository's `findAll()` against `JdbcTemplate`'s count — never against a typed figure. Every
line below names the database that answered (S8.20): the check is that line, never the exit.

<!-- runs: begin -->
**Runs** — `.m2-demo` seeded from `../../../spring-data-beyond-jpa/_research/m2-seed-c8-s1/` alone, the image `postgres@sha256:77f58511…`
present (its id asserted before every Maven run). Development runs fixed the captures and the checks; the published hashes are a
development run's, and every run of record matched them. **The runs of record, on the script as committed (`receipts.sh`'s md5
4a7c377d…, named in the commit message):** 423 s under `./receipts.sh` (/bin/bash 3.2.57, 2026-11-17 from 23:54 CET), 461 s under
`bash receipts.sh` (Homebrew bash 5.3.9, 2026-11-18 from 00:01 CET) and 454 s from a sealed fresh clone (below, from 00:09 CET): each
exit 0, all eight captures 3/3 = published, every check held, every Maven run `offline: yes`, `.m2-demo`'s file count unchanged,
every Testcontainers run with Ryuk disabled, one create per IT class of the digest and no pull, volumes 315 -> 315 and the images
unchanged (none named ryuk) after every Maven run, `before/` and `after/` = their pins at the start and the end, nothing listening on
20460-20469 at the end; each terminal log through `check_unit8.py 07 --runlog` — `RESULT (run logs): PASS` (the unit gate: no 07
script yet). **Nothing was downloaded.**

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at `4cb088a` into a path **with a space** (`…/sealed
07/tiffinbox-java`, in the session's scratch folder), this commit's files put in as git will take them (`git ls-files -m -o
--exclude-standard c8-unit07 c8-tiffinbox`), the clone's `.m2-demo` a file copy of the seed, `env -i` with `HOME`,
`PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`, `DOCKER_CONFIG=$HOME/.docker` and dead proxies for http and https
(`127.0.0.1:9`); `./receipts.sh`. The three runs ran on this README before this block was written — the only change since, checked
by the prose gate afterwards and by one more run of `./receipts.sh` on the final README (exit 0, all eight = published).
<!-- runs: end -->

Published hashes and the two tree pins (`receipts.md5`, every capture 3/3 in every run):

```
tests 3b7613ba338d905e6955b7bf0463b1a0
slice 9671d94add421ed565b7fce8e715d2f5
sql 366a0d82042f827d6239e1bf7ebe876d
wrongslice 61d2b0e996360d4533e1347e0d2ea668
nocontainer 1b96cf756165095d17eb1b55356cffef
nodocker 273ec9f462e768d61e1a0e971c343258
seven fdf30952af80fe3702bc53a46ae81d2e
exercise dc641e4814e25a7325fe2d74a05675ab
before-tree 51 7ce49e3ec13c212a31ee6ba4618f53ab
after-tree 53 f16230d480e6bf37f47cc98ad6d44c28
```

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line):

<!-- values: begin -->
the values the video may say - exercise: 23 words; Docker and the pinned image needed, the image's id printed first): broken - @Container without @ServiceConnection, mvn exit 0, the database that answered H2 2.5.250, the SELECT upper-case and unquoted; solved by @ServiceConnection - mvn exit 0, PostgreSQL 18.6, the SELECT lower-case and unquoted; bash and zsh the same · tests: mvn verify, offline, PostgreSQL 18.6 from the digest: the two slice tests each print customers 5 · Kavya 1 · test transaction active true, the database jdbc:postgresql://localhost:<port>/test · PostgreSQL 18.6; Surefire per report folder: surefire-reports 18, surefire-reports-it 5 (CustomerEntityRepositoryIT 3 · CustomerAggregatesIT 2), 23 in all, failures 0, errors 0; Testcontainers: 2 container creates (one per IT class), 0 pulls, Ryuk disabled · slice: @DataJdbcTest from slice.JdbcSlice, read off its context inside the first test, PostgreSQL 18.6): EntityManagerFactory 0 · Flyway 1 · PlatformTransactionManager org.springframework.jdbc.support.JdbcTransactionManager · CustomerAggregates 1 · Dashboard 0 · CustomerEntityRepository 0 · JdbcClient 1; spring.sql.init.mode not set, no schema.sql or data.sql (the seed is Flyway's V2 + @Sql); flyway_schema_history [1 true, 2 true, 3 true]; no web server · sql: the @Sql sequence on PostgreSQL 18.6: test 1 customers 5 · Kavya 1, test 2 customers 5 · Kavya 1 (not one more), after the class (a JdbcTemplate of its own on the container) customers 4 · Kavya 0 · wrongslice: Spring Data JPA's DataSlice under @DataJdbcTest - Unable to retrieve @EnableAutoConfiguration base packages, both tests in error, exit 1 · nocontainer: @ServiceConnection removed, @Container kept - green, the database that answered jdbc:h2:mem:<uuid> · H2 2.5.250, findAll() 5, the container created and unused (1 create, 0 pulls); without Q on H2: Table "customer" not found (candidates are: "CUSTOMER"); without Q on PostgreSQL 18.6: green, the SQL quoted · nodocker: mvn verify with Maven's DOCKER_HOST pointed at nothing - Could not find a valid Docker environment, exit 1, after the 18 tests on H2 passed; mvn package the same way - exit 0, 18 tests on H2, no container test · seven: the comparison set on before/'s and after/'s jars (H2, port 20462) - 7 responses each, the same md5 as Course 7's (466c20ed…), 0 lines differ; both modules' Found 1 repository interface lines at each start; Hibernate's schema script = Course 7's capstone's
<!-- values: end -->

## The change, file by file, and every README sentence it rewrote (R.250)

`harness/chk07.py static` and `harness/chk07.py r250` run before any build. The change, against `before/`:

- `tiffinbox-web/pom.xml` — `spring-boot-starter-data-jdbc-test`, **test scope**, no version typed (Boot's parent manages it; the
  seed holds it — the receipt asserts the jar in `.m2-demo` first). Outside comments it is the file's only change.
- `tiffinbox-web/src/test/java/slice/JdbcSlice.java` (new) — `@SpringBootConfiguration`, `@EnableJdbcRepositories("com.tiffinbox.jdbc")`,
  `@Import(JdbcNames.class)`, beside `DataSlice`.
- `tiffinbox-web/src/test/java/com/tiffinbox/jdbc/CustomerAggregatesIT.java` (new) — `@DataJdbcTest`,
  `@ContextConfiguration(classes = JdbcSlice.class)`, `@Testcontainers`, a static `@Container @ServiceConnection` PostgreSQL container
  from the capstone's digest, a class-level `@Sql(statements = …)` inserting Kavya, two tests. Each test prints the database that
  answered from the connection (the port masked in the test itself, R.319), the fixture's counts and the repository's; the first test
  prints what the slice started, `spring.sql.init.mode` and Flyway's history. Named `*IT` (S6.22): Surefire's `container-tests`
  execution runs it, `mvn package` does not.
- `tiffinbox-web/src/test/java/com/tiffinbox/CustomerEntityRepositoryIT.java` — its Javadoc's "which tests run where" sentence, noted
  in place; no code line moved.
- `README.md` — a `## Course 8 · unit 07` section, and every sentence the change makes false noted in place in a note that starts
  *Course 8, unit 07*: the header's test count (the tests Course 7's capstone left, the container ones run by `mvn verify` only); unit 02's "unit 07
  changes this folder next"; unit 02's "the tests … are the same tests, unchanged"; the **Which tests run where** sentence of Course 7's
  *Capstone: TiffinBox on Postgres* section and its `mvn verify` sentence; the oldest build section's "`verify` runs the three container tests since". The gate
  lists the six sentences (found in `before/README.md`, each followed by its note in `after/README.md`) and also refuses any
  test-count phrase outside unit 07's section that has no note within the next few lines; the pom's two Testcontainers comments are
  noted the same way. The plant — one note removed — fails it (below).

Nothing deleted, no YAML key, no V4, Flyway's V1-V3 untouched, `ddl-auto: validate` untouched, nothing in `src/main` — and Hibernate's
schema script is still Course 7's capstone's, byte for byte (the seven capture regenerates it over `after/`'s libraries and compares).

## The captures — what each one shows

### 1 · tests — the hook: two tests, one fixture, PostgreSQL in a container (C8-5)

`mvn verify` on a copy of `after/`, offline, under the anchor's recipe: `DOCKER_HOST` on OrbStack's socket, `TESTCONTAINERS_RYUK_DISABLED=true`
(the env alone), a receipt home under `.harness/home` (`checks.disable`, `tinyimage.container.image`), `-Dstdout.encoding=UTF-8`. The two
slice tests, each with the database that answered:

```text
  JDBC IT test 1 the database: jdbc:postgresql://localhost:<port>/test?loggerLevel=OFF · PostgreSQL 18.6
  JDBC IT test 1 customers 5 · Kavya 1 · test transaction active true
  JDBC IT test 1 through the repository: findByName("Kavya") Kavya · findAll() 5
  JDBC IT test 2 the database: jdbc:postgresql://localhost:<port>/test?loggerLevel=OFF · PostgreSQL 18.6
  JDBC IT test 2 customers 5 · Kavya 1 · test transaction active true
  JDBC IT test 2 through the repository: findByName("Kavya") Kavya · findAll() 5
  the database Flyway saw in the slice (its Database line): Database: jdbc:postgresql://localhost:<port>/test?loggerLevel=OFF (PostgreSQL 18.6) - 2 lines
```

Surefire per report folder, Maven's Results lines beside them, the engine's events over the run's window and Testcontainers' own log
(one create per IT class, the digest, no pull), and both modules' `Found 1 … repository interface` lines (the application starts of
`FullStackTest` and `TiffinBoxWebTest`, and the slice's own JDBC line):

```text
  exit 0 · BUILD SUCCESS · offline: yes · its alarm's cap: 600 (R.247)
  the engine's events over its window (the pinned CLI): image pull 0 · container create 2 (postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873) · Testcontainers' log: 'Creating container for image' 2 · 'Pulling' 0 · 'Ryuk has been disabled' 1
  after it: images 6 (the same list, none named ryuk) · volumes 315 · Testcontainers containers 0 · .m2-demo's files 6966 (unchanged)
    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0
    TEST-com.tiffinbox.CustomerEntityRepositoryIT.xml: tests 3 · failures 0 · errors 0 · skipped 0
    TEST-com.tiffinbox.jdbc.CustomerAggregatesIT.xml: tests 2 · failures 0 · errors 0 · skipped 0
    in all: 2 reports · tests 5 · failures 0 · errors 0 · skipped 0
  Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
  Surefire's Results line: Tests run: 5, Failures: 0, Errors: 0, Skipped: 0
  the verify log: 'Found 1 JPA repository interface' 3 · 'Found 1 JDBC repository interface' 3 · Testcontainers 2.0.5 1
```

### 2 · slice — what `@DataJdbcTest` started, read off its context (S8.20, RE-MEASURE 15, C8-13)

Read off the verify log of the same run of the tests capture (its first test prints it from inside the test). The configuration is named;
the bean table is the context's own `getBeanNamesForType` per type; the second witness is the slice's own log segment (from Surefire's
`Running` line to its `Tests run` line): Spring Data JDBC's `Found` line and no Spring Data JPA one, no Hibernate start, Flyway's
migrations, no web server:

```text
  JDBC IT the configuration: jdbcSlice · slice.JdbcSlice
  JDBC IT beans EntityManagerFactory: 0
  JDBC IT beans Flyway: 1
  JDBC IT beans PlatformTransactionManager: 1 · org.springframework.jdbc.support.JdbcTransactionManager
  JDBC IT beans CustomerAggregates: 1
  JDBC IT beans Dashboard: 0
  JDBC IT beans CustomerEntityRepository: 0
  JDBC IT beans JdbcClient: 1
  JDBC IT spring.sql.init.mode, read off the Environment: (not set)
  JDBC IT spring.sql.init's scripts on the class path: schema.sql false · data.sql false
  JDBC IT flyway_schema_history: rows 3 · the migrations' (a version) [1 true, 2 true, 3 true]
  its log, from 'Running com.tiffinbox.jdbc.CustomerAggregatesIT' to its Tests run line: 'Found 1 JDBC repository interface' 1 · 'Found 1 JPA repository interface' 0 · HHH000001 (Hibernate starting) 0 · 'Successfully applied 3 migrations' 1 · 'Creating container for image' 1 · 'Tomcat started' 0
  listening on 20460 while nothing runs: 0 (the slice binds no port)
```

`spring.sql.init.mode` reads as not set, and no `schema.sql` or `data.sql` is on the class path: the slice's seed is Flyway's V2 plus
the `@Sql` fixture, never `spring.sql.init` (C8-13, scoped to this slice). Flyway's history, read by the test from
`flyway_schema_history` with every name quoted (Flyway's own table is lower-case and quoted on H2, so the same query runs on both).

### 3 · sql — the fixture runs before each test, inside its transaction, and the rollback removes it

A harness copy of the shipped IT (`AfterTheClassIT`, derived by `harness/variants.py` at run time) with one `@AfterAll` hook: a
`JdbcTemplate` of its own on the container's URL, after the class, when no test transaction is left. No psql: the Testcontainers database
is reached by that `JdbcTemplate`, the second client, and port 20461 is never bound.

```text
  exit 0 · BUILD SUCCESS · offline: yes · its alarm's cap: 600 (R.247)
  the engine's events over its window (the pinned CLI): image pull 0 · container create 1 (postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873) · Testcontainers' log: 'Creating container for image' 1 · 'Pulling' 0 · 'Ryuk has been disabled' 1
  JDBC IT test 1 customers 5 · Kavya 1 · test transaction active true
  JDBC IT test 2 customers 5 · Kavya 1 · test transaction active true
  JDBC IT after the class, a JdbcTemplate of its own on the container: customers 4 · Kavya 0
  V2's seed (tiffinbox-core's V2__seed.sql): INSERT INTO customer lines 4
```

### 4 · wrongslice — Spring Data JPA's `DataSlice` under `@DataJdbcTest` (a failure receipt, on a copy)

```text
  exit 1 · BUILD FAILURE · offline: yes · its alarm's cap: 600 (R.247)
  the engine's events over its window (the pinned CLI): image pull 0 · container create 1 (postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873) · Testcontainers' log: 'Creating container for image' 1 · 'Pulling' 0 · 'Ryuk has been disabled' 1
    TEST-com.tiffinbox.jdbc.WrongSliceIT.xml: tests 2 · failures 0 · errors 2 · skipped 0
        Caused by: java.lang.IllegalStateException: Unable to retrieve @EnableAutoConfiguration base packages
  the log's first IllegalStateException line: java.lang.IllegalStateException: Unable to retrieve @EnableAutoConfiguration base packages
```

### 5 · nocontainer — `@ServiceConnection` removed, `@Container` kept: the slice makes its own H2 (S8.20, RED #3)

A harness copy, `NoServiceConnectionIT`: the shipped IT with the one annotation removed. The run exits 0 and both tests pass, and the
database that answered is an embedded H2 the slice made for itself; the container is created and unused:

```text
  exit 0 · BUILD SUCCESS · offline: yes · its alarm's cap: 600 (R.247)
  the engine's events over its window (the pinned CLI): image pull 0 · container create 1 (postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873) · Testcontainers' log: 'Creating container for image' 1 · 'Pulling' 0 · 'Ryuk has been disabled' 1
    TEST-com.tiffinbox.jdbc.NoServiceConnectionIT.xml: tests 2 · failures 0 · errors 0 · skipped 0
  exit 1 · BUILD FAILURE · offline: yes · its alarm's cap: 600 (R.247)
  the engine's events over its window (the pinned CLI): image pull 0 · container create 2 (postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873) · Testcontainers' log: 'Creating container for image' 2 · 'Pulling' 0 · 'Ryuk has been disabled' 1
```

```text
  JDBC IT flyway_schema_history: rows 4 · the migrations' (a version) [1 true, 2 true, 3 true]
  JDBC IT test 1 the database: jdbc:h2:mem:<uuid> · H2 2.5.250 (2026-08-29)
  JDBC IT test 1 customers 5 · Kavya 1 · test transaction active true
  JDBC IT test 1 through the repository: findByName("Kavya") Kavya · findAll() 5
  JDBC IT test 2 the database: jdbc:h2:mem:<uuid> · H2 2.5.250 (2026-08-29)
  JDBC IT test 2 customers 5 · Kavya 1 · test transaction active true
  JDBC IT test 2 through the repository: findByName("Kavya") Kavya · findAll() 5
  the SQL Spring Data JDBC sent for findAll(), its JdbcTemplate log: SELECT customer.ID AS ID, customer.NAME AS NAME, customer.VERSION AS VERSION, customer.MEAL_TYPE AS MEAL_TYPE, customer.MEALS_PER_DAY AS MEALS_PER_DAY, customer.PRICE_PER_MEAL AS PRICE_PER_MEAL FROM customer
```

The same copy without Q (`NoServiceConnectionNoQIT`, started from `JdbcSliceNoQ` — `JdbcSlice` without `@Import(JdbcNames.class)`) on
H2, and the shipped IT without Q on the container (`NoQIT`): H2 refuses the quoted names, PostgreSQL 18.6 reads them quoted (the
quoted form, failure receipt only, labelled):

```text
  exit 1 · BUILD FAILURE · offline: yes · its alarm's cap: 600 (R.247)
  the engine's events over its window (the pinned CLI): image pull 0 · container create 2 (postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873) · Testcontainers' log: 'Creating container for image' 2 · 'Pulling' 0 · 'Ryuk has been disabled' 1
    TEST-com.tiffinbox.jdbc.NoQIT.xml: tests 2 · failures 0 · errors 0 · skipped 0
    TEST-com.tiffinbox.jdbc.NoServiceConnectionNoQIT.xml: tests 2 · failures 0 · errors 2 · skipped 0
        Caused by: org.h2.jdbc.JdbcSQLSyntaxErrorException: Table "customer" not found (candidates are: "CUSTOMER"); SQL statement:
        Caused by: org.h2.jdbc.JdbcSQLSyntaxErrorException: Table "customer" not found (candidates are: "CUSTOMER"); SQL statement:
  NoServiceConnectionNoQIT's own lines (its log, from 'Running' to its Tests run line):
  JDBC IT test 1 the database: jdbc:h2:mem:<uuid> · H2 2.5.250 (2026-08-29)
  JDBC IT test 2 the database: jdbc:h2:mem:<uuid> · H2 2.5.250 (2026-08-29)
  NoServiceConnectionNoQIT: 'Creating container for image' 1 (its log)
  NoQIT's own lines (its log, from 'Running' to its Tests run line):
  JDBC IT test 1 the database: jdbc:postgresql://localhost:<port>/test?loggerLevel=OFF · PostgreSQL 18.6
  JDBC IT test 2 the database: jdbc:postgresql://localhost:<port>/test?loggerLevel=OFF · PostgreSQL 18.6
  NoQIT: 'Creating container for image' 1 (its log)
  the SQL Spring Data JDBC sent for findAll(), its JdbcTemplate log: SELECT "customer"."id" AS "id", "customer"."name" AS "name", "customer"."version" AS "version", "customer"."meal_type" AS "meal_type", "customer"."meals_per_day" AS "meals_per_day", "customer"."price_per_meal" AS "price_per_meal" FROM "customer"
```

### 6 · nodocker — no Docker: `verify` fails, `package` does not (R.179)

Maven's `DOCKER_HOST` pointed at nothing (`tcp://127.0.0.1:1`, Maven's env alone): `mvn verify` runs the tests on H2 in memory, then
the container tests stop; `mvn package` runs the tests on H2 in memory and no container test:

```text
  exit 1 · BUILD FAILURE · offline: yes · its alarm's cap: 600 (R.247)
  the engine's events over its window (the pinned CLI): image pull 0 · container create 0 (none) · Testcontainers' log: 'Creating container for image' 0 · 'Pulling' 0 · 'Ryuk has been disabled' 0
  'Could not find a valid Docker environment': 2 lines
    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0
        Caused by: java.lang.IllegalStateException: Could not find a valid Docker environment. Please see logs and check configuration
    in all: 2 reports · tests 2 · failures 0 · errors 2 · skipped 0
  Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
  Surefire's Results line: Tests run: 2, Failures: 0, Errors: 2, Skipped: 0
  exit 0 · BUILD SUCCESS · offline: yes · its alarm's cap: 600 (R.247)
  the engine's events over its window (the pinned CLI): image pull 0 · container create 0 (none) · Testcontainers' log: 'Creating container for image' 0 · 'Pulling' 0 · 'Ryuk has been disabled' 0
    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0
  tiffinbox-web/target/surefire-reports-it: absent - no container test ran
  Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
```

### 7 · seven — the comparison set on `before/` and `after/`, and Hibernate's script (S8.21, RE-MEASURE 16)

```text
  exit 0 · the script's md5: f4f15b9c71145930e75568c4e64ab595 · xcheck.sql (= Course 7's capstone's): f4f15b9c71145930e75568c4e64ab595 · cmp: the same, byte for byte
-- the seven: before/'s jar, java -jar, H2 in memory (a fresh JVM), port 20462:
  log: Found 1 JPA repository interface.
  log: Found 1 JDBC repository interface.
  exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20462 now: 0
-- the seven: after/'s jar, java -jar, H2 in memory (a fresh JVM), port 20462:
  log: Found 1 JPA repository interface.
  log: Found 1 JDBC repository interface.
  exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20462 now: 0
  the seven, after/ against before/: lines that differ: 0
```

### 8 · exercise — run as written, in one shell, bash then zsh (R.196)

`exercise/README.md`'s block and `exercise/SOLUTION.md`'s (one line changed) run one after the other in one `env -i` shell; each file's
"What it prints" block is compared with the run, line for line, and the two differ. The exercise needs Docker and the pinned image: its
first command prints the image's id. Both blocks exit 0 — the database line is the check:

```text
in bash (/bin/bash --noprofile --norc) - the README's lines, the block's exit 0:
    the image: sha256:77f585114c32
    mvn: exit 0
    EX the database that answered: H2 2.5.250
    EX findAll(): 4 customers
    the first SELECT: SELECT customer.ID AS ID
  then the solution's lines, in the same shell - the block's exit 0:
    the image: sha256:77f585114c32
    mvn: exit 0
    EX the database that answered: PostgreSQL 18.6
    EX findAll(): 4 customers
    the first SELECT: SELECT customer.id AS id
  the shell is now in: this unit's folder · the shell's own output: 0 lines
  after it: images 6 (the same list, none named ryuk) · volumes 315 · Testcontainers containers 0 · .m2-demo's files 6966 (unchanged)
in zsh (/bin/zsh -f) - the README's lines, the block's exit 0:
    the image: sha256:77f585114c32
    mvn: exit 0
    EX the database that answered: H2 2.5.250
    EX findAll(): 4 customers
    the first SELECT: SELECT customer.ID AS ID
  then the solution's lines, in the same shell - the block's exit 0:
    the image: sha256:77f585114c32
    mvn: exit 0
    EX the database that answered: PostgreSQL 18.6
    EX findAll(): 4 customers
    the first SELECT: SELECT customer.id AS id
  the shell is now in: this unit's folder · the shell's own output: 0 lines
  after it: images 6 (the same list, none named ryuk) · volumes 315 · Testcontainers containers 0 · .m2-demo's files 6966 (unchanged)
```

## Which tests run where

`mvn package` runs the tests on H2 in memory and needs no Docker; `mvn verify` adds the container tests — Spring Data JPA's slice
(`CustomerEntityRepositoryIT`) and now Spring Data JDBC's (`CustomerAggregatesIT`) — in Surefire's `container-tests` execution, into
`surefire-reports-it`, no Failsafe (⚑7; the seed holds none, and the receipt asserts it). Both counts are read off Surefire's two report
folders per run, never typed; the totals are in the tests capture and the values line. The slice binds no port: port 20460 is asserted
free while nothing runs.

## Refused, named

- A sentence that puts the test on TiffinBox's own default database — TiffinBox starts on H2 in memory by default; the test runs on PostgreSQL 18.6 by the
  capstone's digest (Amendment A, RED #3).
- A green run said without the database that answered beside it (S8.20) — the nocontainer copy exits 0 on H2 2.5.250.
- A container's port printed raw (R.319) — the IT masks it; the receipt refuses any `localhost:` port in a capture.
- An H2-against-PostgreSQL ranking (C8-17) — every line here says which database answered, and nothing more.
- Failsafe — not in the seed; Surefire's second execution runs the container tests (⚑7).
- A duration word — none; Testcontainers' `started in PT…S`, Boot's `Started … in … seconds`, Surefire's `Time elapsed` and Flyway's
  `(execution time …)` are masked by the receipt (dur8 does not match the last three; the mask's self-test feeds them).
- `Hibernate generates` — never.

## Call-backs, by title (R.224)

- Course 7's *Capstone: TiffinBox on Postgres* (read off `java7_series.py`: `"39": "Capstone: TiffinBox on Postgres"`, line 103) —
  `@DataJpaTest` and `CustomerEntityRepositoryIT` beside this slice; the same digest, `@ServiceConnection` and Testcontainers recipe.
- Course 8's *Aggregates, Not Entities* — `JdbcNames`, the quoting fix, imported by the slice as by `TiffinBoxApp`.

## The commands this unit adds

`receipts.sh` runs Maven as the anchor's README does, offline, from `.m2-demo`, under its alarm (`perl -e 'alarm 600; exec …'`),
`MAVEN_OPTS=-Duser.home=../home`, Surefire's `-DargLine` with the locale, `-Dstdout.encoding=UTF-8` and the receipt home; the harness
copies run one class at a time (`-Dtest=… -Dsurefire.failIfNoSpecifiedTests=false test`), with Spring's `JdbcTemplate` logger at debug
for the SQL lines. Every command is printed in its capture as it ran.

## The repository, and the network

`.m2-demo` is a file copy of `../../../spring-data-beyond-jpa/_research/m2-seed-c8-s1/` (the course's seed); every build is offline
(`mvn -o`), every log is checked for a download line (none), and `.m2-demo`'s file count is asserted unchanged after every Maven run.
No image is pulled: the pinned image's id is asserted before every Maven run, the image list after it (Ryuk's image is not on the
machine and is never asked for: `TESTCONTAINERS_RYUK_DISABLED=true`), and the engine's image events over each run's window are
counted. Nothing leaves the machine but this unit's commit.

## The folders, the harness and the ports

- `before` → `../c8-unit02/after` (a link; the pin `before-tree` = unit 06's `anchor-tree`); `after/` — this unit's tree, `= ../c8-tiffinbox`
  (the pin `after-tree`, the first tree that differs from unit 06's).
- `harness/` — `chk07.py` (the checks), `s807.py` (the prose gate, its self-test first), `dur8.py` (the builders', byte for byte),
  `surefire.py` (the testing lesson's, unit 02's copy), `tree07.py` (the tree pin), `variants.py` (the harness copies, derived from
  `after/`'s files at run time and asserted to differ by their named change alone), `src/probe/x/XMain.java` (Course 7's probe of the
  schema script, unit 29's, byte for byte), `logback.xml` (its log config, unit 02's).
- `exercise/` — `OnWhichDatabaseIT.java`, `README.md`, `SOLUTION.md`. `xcheck.sql` — Course 7's capstone's, byte for byte.
- Ports (20460-20469): 20460 never bound (the slice binds none; asserted free while nothing runs) · 20461 never bound (no container of
  this script's own: the second client is a `JdbcTemplate`) · 20462 TiffinBox for the seven (bound in turn by `before/`'s and `after/`'s
  jars, each stopped by `POST /shutdown`) · 20463-20469 spare, never bound. Testcontainers' host ports are OrbStack's, ephemeral,
  masked. All ten are checked free at the start and the end.

## Masks, filters and hygiene — every one, declared

The mask (self-tested before any capture): this folder, its parent and the home folder, the user's name, `using Java <version>`,
Boot's `Started … in … seconds`, Surefire's `Time elapsed`, Flyway's execution time, Spring Data's scanning time, Testcontainers'
`started in PT…S`, Maven's `Total time`, identity hashes. The IT masks the container's port and H2's generated database name itself
(`localhost:<port>`, `jdbc:h2:mem:<uuid>`). Every capture is checked for absolute paths, times, log times, stack frames, an unmasked H2
name, a raw port and the shutdown token. Every JVM and Maven run is under `perl -e 'alarm N; exec …'` (R.247); every docker call names
its socket (`docker -H "$DH"`, R.344); every container removal is `rm -fv` (R.322, S6.10).

## Interrupted

Each on the scratch mirror (a `git clone --shared` with this unit's files and the new anchor put in): `receipts.sh` started with SIGINT
reset to its default (`perl -e '$SIG{INT} = "DEFAULT"; exec …'` — a background job of a non-interactive shell would ignore it), the
signal sent at the named point; its trap stops every JVM and Maven by pid, sweeps its process group and removes Testcontainers'
containers by label with their volumes:

- mid-build (Maven building the trees): exit 130 · JVMs left 0 (and 0 at a second look) · Testcontainers containers 0 · volumes 315 · listeners on 20460-20469 0 · partial captures 0 · `receipts.md5` unchanged · captures unchanged · `.r-lock` left: no
- mid-verify (the tests capture's `mvn verify`, Surefire's fork running the container tests): exit 130 · JVMs left 0 (and 0 at a second look) · Testcontainers containers 0 · volumes 315 · listeners on 20460-20469 0 · partial captures 0 · `receipts.md5` unchanged · captures unchanged · `.r-lock` left: no
- mid-container (a Testcontainers container up, the exercise's test JVM running): exit 130 · JVMs left 0 (and 0 at a second look) · Testcontainers containers 0 · volumes 315 · listeners on 20460-20469 0 · partial captures 0 · `receipts.md5` unchanged · captures unchanged · `.r-lock` left: no

Unit 02 saw Surefire's fork still exiting at the first look mid-verify; here both looks counted none.

## The ledger rows this unit pays

- **C8-5** Testcontainers and Postgres — **paid**: the digest, `@ServiceConnection`, Course 7's recipe from *Capstone: TiffinBox on Postgres* (`DOCKER_HOST`, Ryuk off by the
  env, the receipt home, `-Dstdout.encoding=UTF-8`, the masked port), the tests capture.
- **C8-13** `spring.sql.init` beside `ddl-auto` — **paid (scoped)**: in this slice the seed is Flyway's V2 plus `@Sql`; `spring.sql.init.mode`
  as read off the context, no `schema.sql` or `data.sql` (the slice capture).
- **C8-17** the H2 sentence of Course 7's *Capstone: TiffinBox on Postgres* — **not contradicted**: no H2-against-PostgreSQL claim; each line names its database.

## RE-MEASURE — the brief's items this unit settles

- **6** — the test count at `verify`, per report folder: the tests capture (the probe's total reproduced; its own count read off the run).
- **15** — `spring.sql.init.mode` and the scripts on the class path: the slice capture.
- **16** — the seven on `before/` and `after/`: unchanged, = Course 7's capstone's comparison set.

## The anchor moved on — the builders (R.211, R.331)

Before the commit, `grep -n 'c8-tiffinbox\|c7-tiffinbox'` over `spring-data-beyond-jpa/_builders/*.py`, `check_unit8.py`, `qa_java8.py` and
`build_java8.py`: no line (grep's exit 1); `_builders/` holds `dur8.py` alone. No builder is edited. Units 01 and 03-06 measured
`c8-unit02/after` through links and pins of their own; this unit leaves that tree as it is (`before-tree` = unit 06's pin), so none of
them moves.

## The root .gitignore

The `c8-unit*` patterns (`.m2-demo/`, `.harness/`, `.r-*`) were added by the set-up; `git status --short` before the commit lists
`c8-unit07/` and `c8-tiffinbox/` only, and nothing is added to `.gitignore`.

## What differed from the brief

- **`slice` is read off the tests capture's verifies, one per run** — not a verify of its own: the slice's context is printed by the
  shipped IT's first test, so each of `slice`'s three runs reads the verify log of the same run of `tests`. Both are 3/3.
- **`nocontainer`'s `findAll()` on H2 reads the same count as on PostgreSQL, not the brief's 4.** With `@Container` kept and
  `@ServiceConnection` removed the slice's embedded H2 is migrated by Flyway too — V2's customers are there — so the fixture's Kavya
  is one more. The brief's 4 was BLUE's probe count; the exercise, which has no `@Sql`, reads V2's customers alone (its capture).
- **Flyway's history on H2 has one more row than on PostgreSQL** — Flyway's own schema-creation row, with no version. The IT reads the
  migrations' rows (a version) — `[1 true, 2 true, 3 true]` on both — and prints the table's row count beside them, so the difference is
  shown and not hidden.
- **H2's product version prints with its build date** (`getDatabaseProductVersion()`), so the nocontainer lines read `H2 2.5.250 (…)`; the
  exercise cuts the parenthesis off.
- **The third window of `sql` is a `JdbcTemplate` in an `@AfterAll` hook of a harness copy**, not psql: the Testcontainers database's port
  is OrbStack's and masked; port 20461 (the brief's psql container, "only if used") is never bound.
- **The seven runs on port 20462**, one of the brief's spare ports — the slice binds none, and the seven needs TiffinBox listening.
- **The `@ServiceConnection` plant is caught by the run, not a static check**: the static check deliberately does not look for the
  annotation (S8.20: the check is the database that answered); the tests capture's product line fails it.
- **The `@Import(JdbcNames.class)` plant is caught before any build** — the static check and `variants.py`'s derivation both refuse it — not by
  a run on H2; the H2 failure itself is the nocontainer capture's `NoServiceConnectionNoQIT`, measured on every run.
- **The `*Test` rename plant is caught by the static check (S6.22) before any build**; its consequence — `mvn package` then needs Docker — was
  measured once on a scratch copy (Planted faults).
- **R.250 noted three more places than the brief names**: `CustomerEntityRepositoryIT`'s Javadoc and the pom's two Testcontainers comments
  said "CustomerEntityRepositoryIT's three tests" / "only CustomerEntityRepositoryIT uses them".
- **No statement witness** (datasource-proxy) in this unit: the counts are `JdbcTemplate`'s and the repository's, each against the other,
  and against V2's seed rows (U02's/U05's form without the witness; U06's row-counting witness is not needed — no capture counts rows).
- **The probe's class name `JdbcSliceIT` became the brief's `CustomerAggregatesIT`**, in `com.tiffinbox.jdbc` beside the repository it tests.
- **`check_unit8.py 07` exits 2 for the unit gate** (no 07 script yet, as the prompt expects); each run log's own check succeeds (`RESULT (run logs)`, its line quoted in Runs).

## Planted faults — each caught (R.65, R.226)

Each on a scratch mirror of this folder (a `git clone --shared` of the repository with this unit's files and the new anchor put in, put
back from this tree before each), the plant applied by a Python script (never sed), `./receipts.sh` run; each exit 1, `receipts.md5`
and every shipped file unchanged by the run (compared before and after; the plants on `after/` re-pin `after-tree` themselves, as a
careless author would, so that the check under test is the one that meets them), the first refusal quoted (a planted word elided):

- an Indian dish name in a README sentence (R.215): `an Indian dish name (R.215: English names only): README.md:7:TiffinBox gains a p…r test that starts only its JDBC layer`
- a placeholder line appended to the README: `a placeholder in this unit's prose or tree: README.md:418:T…O: the numbers`
- a typed SQL string in the prose (R.225, R.365): `README.md line 3: R.225/R.365: a typed SQL string in the prose`
- a duration word in a README sentence (dur8): `README.md line 3: dur8: f…r`
- Amendment A's refused phrase in a README sentence (RED #3): `README.md line 3: Amendment A (RED #3): the database TiffinBox r… on`
- a typed test count (R.302): `README.md line 3: R.302: a capture's number typed in prose`
- F…e said to run the container tests (⚑7): `README.md line 3: ⚑7: … - the tests run in Surefire's container-tests execution`
- a bad `before` target (`../c8-unit06/anchor`, R.211): `R.211: before must be a link to ../c8-unit02/after (it points at: ../c8-unit06/anchor)`
- one of the anchor README's unit 07 notes removed (R.250): `R.250: FAIL R.250: after/README.md notes it in place, right after it: *(Course 8, unit 07 … - `mvn verify` runs the 18, then the three container tests`
- a container removed without its volume in the trap (S6.10, R.322): `S6.10/R.322: receipts.sh removes a container without its volume - every removal is dk rm -fv`
- the docker CLI unpinned (`dk()` without `-H`), the run started under `DOCKER_HOST=tcp://127.0.0.1:1` (R.344): `R.344: dk() must name the pinned socket (docker -H "$DH")`
- `@Import(JdbcNames.class)` dropped from `after/`'s `JdbcSlice` (S8.23): `static: FAIL slice/JdbcSlice.java carries @Import(JdbcNames.class)`
- the IT renamed `*Test` (S6.22): `static: FAIL new: tiffinbox-web/src/test/java/com/tiffinbox/jdbc/CustomerAggregatesTest.java, …` — and, measured once on a
  scratch copy of `after/` with the rename, `mvn -o package` with Maven's `DOCKER_HOST` pointed at nothing: exit 1, the class in error
  with Could not find a valid Docker environment — `package` then needs Docker
- the port printed raw: the IT's port mask removed (R.319): `R.319: tests printed a container's port raw: localhost:3…` (after its first run)
- `@ServiceConnection` removed from `after/`'s IT (S8.20): the run exits 0 — and the tests check refuses it on the database that answered:
  `FAIL both tests: the database that answered is jdbc:postgresql://localhost:<port>/test · PostgreSQL 18.6 (port masked, R.319)`
- a wrong published hash (the tests line in `receipts.md5`): `tests is not the published capture - … diff .r-tests.out against its block in README.md`
- a changed What-it-prints line (`mvn: exit 2` in the exercise README): `exercise/README.md's "What it prints" block is not what its lines printed: 2c2 < mvn: exit 2`
- the exercise's solution = broken (its `sed` matches no line, R.196): `FAIL solved: the database that answered is PostgreSQL 18.6`

Not applicable here, named: a version claim without HHH000001 and a missing version line — this unit's values claim no library version
(Hibernate is not started by the slice, and the slice capture asserts that).

## For RED

- **The shipped IT does not assert which database answered** — by design: with an assertion the nocontainer copy would fail and the
  lesson's point (a green run answered by H2 2.5.250, not PostgreSQL 18.6) could not be shown. The receipt's check is the printed line; a viewer's is too.
- **Two container creates per verify** — one per IT class with a `@Container` (`CustomerEntityRepositoryIT`'s and `CustomerAggregatesIT`'s),
  by the engine's events and by Testcontainers' log, each removed by Testcontainers itself (Ryuk off).
- **The nocontainer copy creates its container and never uses it** — one create, by both witnesses; the slice's DataSource is H2's.
- **Without Q on H2 the error is in Surefire's report** (the exception's `Caused by`), not in the log: the receipt reads both and the
  check reads the report.
- **`spring.sql.init.mode` reads as not set** — the capture prints the property off the context's `Environment` and whether `schema.sql`
  and `data.sql` exist on the class path (neither); Boot's own decision for an embedded database is not printed, and is not claimed.
- **The verify log's `Found` lines are counted, not attributed**: one per context that scans repositories (the two application tests and
  the slice); the check asserts at least one per module, and the slice's own segment holds Spring Data JDBC's line and no JPA one.
- **The no-Docker verify still runs the tests on H2 in memory first** and fails only at the container tests; its exit is Maven's.
- **The exercise exits 0 both ways, on H2 2.5.250 broken and on PostgreSQL 18.6 solved** — `mvn: exit 0` in both blocks; the database line and the SELECT's case are the difference.
