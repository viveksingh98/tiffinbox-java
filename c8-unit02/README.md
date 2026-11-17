# c8-unit02 — Aggregates, Not Entities

Course 8, Section 1's first anchor change and **Course 8's first change to the anchor** (C1): `before/` is a frozen copy of
`../c8-tiffinbox` at the set-up commit `50d64ac` — Course 7's final anchor plus a README header; no earlier Course 8 unit changed it,
so there is no previous Course 8 anchor-change unit to re-run, and Course 7's `before → ../c7-unitNN/after` link form resumes with the
next anchor change (unit 07's `before → ../c8-unit02/after`). `after/` is this unit's tree, and `../c8-tiffinbox` equals `after/` from this
unit's commit on; **unit 07 moves the anchor next (test scope)**. TiffinBox gains a second Spring Data module: **Spring Data J-D-B-C**,
beside **Spring Data J-P-A**, over the same two tables. Spring Data JDBC reads and writes whole **aggregates** — an aggregate is a group
of objects saved and loaded as one, through its root; here a customer with her pauses, and a pause has no repository of its own. It does
nothing you did not call: no lazy loading, no dirty checking, and every statement it sends is in the log.

Seven captures, each run in three passes by `receipts.sh` and hashed (`receipts.md5`); every number and string below is asserted right
after its capture by `harness/chk02.py`, against another witness of the same run — psql in this run's container on PostgreSQL,
`JdbcTemplate` on H2 (each named on its line), Surefire's two report folders, Hibernate's own `getPrepareStatementCount()` next to the
witness's count in the same window — never against a typed figure. Every aggregate mapping runs on both databases: H2 in memory (the anchor's default)
and PostgreSQL 18.6 from the pinned digest (R.353).

<!-- runs: begin -->
**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`, `DOCKER_CONFIG=$HOME/.docker`),
`.m2-demo` seeded from `../../../spring-data-beyond-jpa/_research/m2-seed-c8-s1/` alone, the image `postgres@sha256:77f58511…` present
(`docker -H "$DH" image inspect`, the full digest). Development runs fixed the captures and the checks; the published hashes are a
development pass's, and every run of record matched them. **The runs of record, on the script as committed (`receipts.sh`'s md5 printed by `md5 -q`
and named in the commit message):** 561 s under `./receipts.sh` (/bin/bash 3.2.57, 2026-11-17 from 16:52 CET), 569 s under
`bash receipts.sh` (Homebrew bash 5.3.9, from 17:01 CET) and 584 s from a sealed fresh clone (below, from 17:11 CET): each exit 0, all
seven captures 3/3 = published, every check passed, every Maven run `offline: yes`, the verify's Testcontainers run with Ryuk's three
checks and no pull, `before/` = `50d64ac` at the start and the end, the container removed with its volume (volumes 315 -> 315 in each
run), the images unchanged and none named ryuk, nothing listening on 20410-20419 at the end; each terminal log through
`check_unit8.py 02 --runlog` — `RESULT (run logs): PASS` (the unit gate: no 02 script yet). **Nothing was downloaded.**

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at `50d64ac` into a path **with a space** (`…/sealed
02/tiffinbox-java`, in the session's scratch folder), this commit's files put in as git will take them (`git ls-files -m -o
--exclude-standard c8-unit02 c8-tiffinbox`), the clone's `.m2-demo` a file copy of the seed, dead proxies for http and https in its
environment (`127.0.0.1:9`); `./receipts.sh`. The three runs ran on this README before its Interrupted section and this block were
written — the only changes since, checked by the prose gate afterwards. A scratch mirror's full run (the plant mirror, unplanted) was
also exit 0 with all seven = published.
<!-- runs: end -->

Published hashes (`receipts.md5`, every capture 3/3 in every run):

```
exercise cf13706d666181c4640022f9bec1048e
anchor f0514aab16f18fa69fed44f959f12985
quote daaace97612bb152d8b892317adfb764
dup 7cb350bdbc091eec6a8918f0377a4811
dirty 0ba7a180d2cb017b406f6a939eddd7fb
lazy dad7ad171afe318bcb17c95b6360d950
seven d74b5afdc9ec06a2911fcbcb98824fb2
```

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line; a SQL string typed in
this README outside this block and the blocks the runs printed is refused):

<!-- values: begin -->
the values the video may say: on PostgreSQL 18.6 and H2 2.5.250, Spring Boot 4.1.2, Spring Framework 7.0.10, Spring Data JDBC 4.1.2, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final, Flyway 12.4.0 - exercise: the exercise (19 words, H2 in memory, no Docker): broken - TiffinBox exit 1, BeanDefinitionOverrideException 'customerEntityRepository'; solved by the rename - exit 0, Found 1 JPA repository interface + Found 1 JDBC repository interface · anchor: the jar's libraries 96 -> 99 (+ spring-boot-data-jdbc-4.1.2.jar, spring-data-jdbc-4.1.2.jar, spring-data-relational-4.1.2.jar); Hibernate's script f4f15b9c… = Course 7's capstone's; TiffinBox on H2 in memory and on PostgreSQL 18.6 (the config tree's URL, its own driver): strict mode, Found 1 JPA repository interface, Found 1 JDBC repository interface, one 'Could not safely identify' line (Spring Data JPA's, for CustomerAggregates), GET /dashboard 200 with 4 SQL lines; the harness: customerEntityRepository by JpaRepositoryFactoryBean, customerAggregates by JdbcRepositoryFactoryBean, one JpaTransactionManager; data 40 · 38 · 77; findAll() 41 statements on H2 and 41 on PostgreSQL (1 + 40); tests 18 (14 · 3 · 1, mvn package, no Docker) + 3 (mvn verify) · quote: the @Import alone removed: H2 still reads, unquoted (the component scan finds JdbcNames); the copy without JdbcNames: H2 refuses, exit 1, Table "customer" not found (candidates are: "CUSTOMER"); PostgreSQL reads 4 aggregates with the quoted form (failure receipt only); after/ with JdbcNames: 4 aggregates on both, unquoted · dup: the copy: BeanDefinitionOverrideException: Invalid bean definition with name 'customerEntityRepository', exit 1, nothing listened; the simple-name check: after/ 0 repeated, the copy 1 · dirty: window B (Spring Data JDBC, no save) 2 statements, 0 UPDATE; window A (Spring Data JPA, no save) 2 statements, the UPDATE included, = getPrepareStatementCount(); window A' (Spring Data JDBC, save) 4 statements - 2 SELECTs, UPDATE, DELETE of pauses; psql on PostgreSQL and JdbcTemplate on H2: meals 2 -> 2 -> 3 -> 4, version 0 -> 0 -> 1 -> 2, updated_at null -> set by A, left by A'; Spring Data JDBC's own auditing (a copy): writes updated_at on both databases · lazy: after the call, no transaction, on H2 and PostgreSQL: Spring Data JDBC getPauses() -> 1 (LinkedHashSet); Spring Data JPA -> LazyInitializationException: Cannot lazily initialize collection of role 'com.tiffinbox.CustomerEntity.pauses' with key '3' (no session) · seven: the seven 466c20ed… on before/ and after/ (H2) and after/ on PostgreSQL, unchanged; 6 Hibernate SQL lines during it each time, 0 from Spring Data JDBC
<!-- values: end -->

### C1 — the change, file by file, and every sentence it rewrote (R.250)

`harness/chk02.py static` and `harness/chk02.py r250` run before any build. C1, measured as the brief's shape (c):

- `tiffinbox-core/pom.xml` — `spring-data-jdbc`, no version typed (Boot's parent manages it).
- `tiffinbox-web/pom.xml` — `spring-boot-starter-data-jdbc`, no version typed; Spring Data JPA's starter stays.
- `tiffinbox-core/src/main/java/com/tiffinbox/jdbc/CustomerRow.java` (new) — the aggregate's root: `@Table("customer")`, `@Id`, `@Version`,
  V1's customer columns by name (`chk02.py static` compares the fields with V1's `CREATE TABLE`), and
  `@MappedCollection(idColumn = "customer_id") Set<PauseRow> pauses`. V3's audit columns are not mapped.
- `tiffinbox-core/src/main/java/com/tiffinbox/jdbc/PauseRow.java` (new) — `@Table("pause")`, `id` and `days`.
- `tiffinbox-core/src/main/java/com/tiffinbox/jdbc/CustomerAggregates.java` (new) — `ListCrudRepository<CustomerRow, Long>` and
  `ListPagingAndSortingRepository<CustomerRow, Long>`, `findByName` and the two sums as SQL `@Query`s.
- `tiffinbox-core/src/main/java/com/tiffinbox/jdbc/JdbcNames.java` (new) — Q: a `@Configuration` whose static `BeanPostProcessor` calls
  `RelationalMappingContext.setForceQuote(false)` in its before-initialisation callback (Course 4's *The Bean Lifecycle, Step by Step*:
  the container callback under it).
- `tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java` — `@EnableJdbcRepositories("com.tiffinbox.jdbc")` and
  `@Import(JdbcNames.class)` beside `@EnableJpaRepositories("com.tiffinbox")`, and a Javadoc paragraph saying why.
- `README.md` — a `## Course 8 · unit 02` section (two modules, which owns which repository, strict mode's line, both factory
  classes, one `JpaTransactionManager`), and the header's four sentences C1 makes false, each noted in place in a note that starts
  *Course 8, unit 02*: "every file is byte-identical except this README" (no longer: seven files besides it differ); the data layer
  "as Course 7 left it" (two Spring Data modules since); "Course 8's units are planned to … add Spring's other data modules"
  (Spring Data JDBC is the first, added here); "Everything below the rule is `c7-tiffinbox`'s README" (the Course 8 sections come
  first now). The gate's plant — one of those notes removed — fails it (below). No README sentence says the anchor has one data
  module, one repository, or that Spring Data JPA owns the data layer; the gate refuses those phrases in `after/README.md`.

Nothing deleted, no entity moved, no YAML key, Flyway's V1-V3 untouched (no V4), `ddl-auto: validate` untouched, and Hibernate's
schema script unchanged: `xcheck.sql` is Course 7's capstone's, byte for byte, and the anchor capture regenerates it over `after/`'s
libraries and compares.

## The captures — what each one shows

### 1 · anchor — C1 on both databases, the jar, the tests

C1's files, the jar's libraries and Hibernate's schema script (H2's `ls lib | wc -l` read off each jar; nothing typed):

```text
  changed: README.md
  changed: tiffinbox-core/pom.xml
  changed: tiffinbox-web/pom.xml
  changed: tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java
  new: tiffinbox-core/src/main/java/com/tiffinbox/jdbc
  the YAML, Flyway's migrations, the three JPA files and the tests, after/ against before/: the same, byte for byte
  .harness/before's jar, extracted - lib/ (ls lib | wc -l): 96 libraries · postgresql-*.jar: postgresql-42.7.14.jar · spring-data-jdbc-*.jar: 0
  .harness/after's jar, extracted - lib/ (ls lib | wc -l): 99 libraries · postgresql-*.jar: postgresql-42.7.14.jar · spring-data-jdbc-*.jar: 1
  the libraries after/'s jar adds: spring-boot-data-jdbc-4.1.2.jar spring-data-jdbc-4.1.2.jar spring-data-relational-4.1.2.jar · removes: none
  exit 0 · its org.flywaydb lines: 0 · the script's md5: f4f15b9c71145930e75568c4e64ab595 · the filed xcheck.sql (= Course 7's capstone's): f4f15b9c71145930e75568c4e64ab595 · cmp: the same, byte for byte
```

TiffinBox `after/`'s jar, on H2 in memory (its default) and then on PostgreSQL through the config tree's URL with its own driver
(`lib/` holds `postgresql-42.7.14.jar` since Course 7's capstone; the harness adds none): strict mode, each module's `Found` line,
the one "Could not safely identify" line (Spring Data JPA's, for `CustomerAggregates`; Spring Data JDBC scans only
`com.tiffinbox.jdbc`), GET `/dashboard` and its SQL lines:

```text
A - TiffinBox after/'s jar, the default: java -jar, H2 in memory (application.yaml's tiffinbox.jdbc-url), port 20410:
  log: Multiple Spring Data modules found, entering strict repository configuration mode
  log: Bootstrapping Spring Data JPA repositories in DEFAULT mode.
  log: Spring Data JPA - Could not safely identify store assignment for repository candidate interface com.tiffinbox.jdbc.CustomerAggregates; …
  log: Finished Spring Data repository scanning in <t> ms. Found 1 JPA repository interface.
  log: Multiple Spring Data modules found, entering strict repository configuration mode
  log: Bootstrapping Spring Data JDBC repositories in DEFAULT mode.
  log: Finished Spring Data repository scanning in <t> ms. Found 1 JDBC repository interface.
  log: Database: jdbc:h2:mem:tiffinbox (H2 2.5)
  log: HHH000001: Hibernate ORM core version 7.4.13.Final
  -> 200 · the request's org.hibernate.SQL lines, between its two markers: 4 · JdbcTemplate's SQL lines: 0 · ERROR lines: 0
A - the same jar on PostgreSQL: a fresh database u02a, its URL in after/'s own config tree (secrets/tiffinbox/jdbc-url, mode 0600), its own driver from lib/, port 20410:
  log: Finished Spring Data repository scanning in <t> ms. Found 1 JPA repository interface.
  log: Finished Spring Data repository scanning in <t> ms. Found 1 JDBC repository interface.
  log: Database: jdbc:postgresql://127.0.0.1:20411/u02a?user=sa&password=******** (PostgreSQL 18.6)
  -> 200 · the request's org.hibernate.SQL lines, between its two markers: 4 · JdbcTemplate's SQL lines: 0 · ERROR lines: 0
  psql - the tables and the history: customer, flyway_schema_history, pause · 3 rows, success true
```

The harness on `after/` (no web server; the witness on the `DataSource` bean): the repository beans with their factory classes, the
one transaction manager, the data line, and `findAll()` in one labelled window — each SQL text the driver received, with its count,
on H2 and on PostgreSQL. Under Q the SQL is unquoted on both: H2's dialect upper-cases the derived names, PostgreSQL's keeps them
lower-case (R.365):

```text
  started: yes · the database that answered: H2 2.5.250
  versions: Spring Boot 4.1.2 · Spring Framework 7.0.10 · Spring Data JDBC 4.1.2 · Spring Data Relational 4.1.2 · Spring Data JPA 4.1.2 · Flyway (version.txt) 12.4.0 · datasource-proxy (pom.properties) 1.11.1
  repository bean &customerEntityRepository · factory JpaRepositoryFactoryBean · interface com.tiffinbox.CustomerEntityRepository
  repository bean &customerAggregates · factory JdbcRepositoryFactoryBean · interface com.tiffinbox.jdbc.CustomerAggregates
  transaction manager transactionManager · org.springframework.orm.jpa.JpaTransactionManager
  window findAll() (H2 2.5.250): aggregates 40 · pauses in them 38 · statements 41
  window findAll() (H2 2.5.250) SQL x1: SELECT customer.ID AS ID, customer.NAME AS NAME, customer.VERSION AS VERSION, customer.MEAL_TYPE AS MEAL_TYPE, customer.MEALS_PER_DAY AS MEALS_PER_DAY, customer.PRICE_PER_MEAL AS PRICE_PER_MEAL FROM customer
  window findAll() (H2 2.5.250) SQL x40: SELECT pause.ID AS ID, pause.DAYS AS DAYS FROM pause WHERE pause.customer_id = ?
  started: yes · the database that answered: PostgreSQL 18.6
  window findAll() (PostgreSQL 18.6): aggregates 40 · pauses in them 38 · statements 41
  window findAll() (PostgreSQL 18.6) SQL x1: SELECT customer.id AS id, customer.name AS name, customer.version AS version, customer.meal_type AS meal_type, customer.meals_per_day AS meals_per_day, customer.price_per_meal AS price_per_meal FROM customer
  window findAll() (PostgreSQL 18.6) SQL x40: SELECT pause.id AS id, pause.days AS days FROM pause WHERE pause.customer_id = ?
  psql - the data line, a second client: 40 customers · 38 pauses · 77 paused days
```

One load is the customer SELECT and one pause SELECT per aggregate — the 1 + N, named here and handed to *Relationships Without an
ORM* and *JPA vs JDBC vs Plain SQL*; single-query loading is not this unit's (R.368). The tests, `mvn package` with Maven's
`DOCKER_HOST` pointed at nothing, then `mvn verify` under the Testcontainers recipe:

```text
  exit 0 · BUILD SUCCESS · offline: yes · its alarm's cap: 600 (R.247)
    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0
  tiffinbox-web/target/surefire-reports-it: absent - no container test ran
  Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
  exit 0 · BUILD SUCCESS · offline: yes · its alarm's cap: 600 (R.247)
  Ryuk's three checks (R.318): pre-flight PASS · the log: 'Ryuk has been disabled' 1 · the events: 1 container create of the digest, 0 others, 0 image pulls
    in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0
    in all: 1 reports · tests 3 · failures 0 · errors 0 · skipped 0
  Surefire's Results line: Tests run: 18, Failures: 0, Errors: 0, Skipped: 0
  Surefire's Results line: Tests run: 3, Failures: 0, Errors: 0, Skipped: 0
```

### 2 · quote — the name the database refused (the failure receipt, both databases, labelled)

A COPY of `after/` without Q. Removing only the `@Import` line is not enough: `TiffinBoxApp`'s `@ComponentScan("com.tiffinbox")` still
finds `JdbcNames` (measured — For RED), so the copy deletes the class. On H2 the quoted lower-case name is not found; on PostgreSQL the
same copy reads, with its quoted form (the quoted form, failure receipt only); then `after/`, with Q, on both:

```text
  deleted: tiffinbox-core/src/main/java/com/tiffinbox/jdbc/JdbcNames.java
  < import com.tiffinbox.jdbc.JdbcNames;
  < import org.springframework.context.annotation.Import;
  < @Import(JdbcNames.class)
  < import com.tiffinbox.jdbc.JdbcNames;
  < import org.springframework.context.annotation.Import;
  < @Import(JdbcNames.class)
  read findAll() (H2 2.5.250): aggregates 4
  read findAll() (H2 2.5.250) SQL x1: SELECT customer.ID AS ID, customer.NAME AS NAME, customer.VERSION AS VERSION, customer.MEAL_TYPE AS MEAL_TYPE, customer.MEALS_PER_DAY AS MEALS_PER_DAY, customer.PRICE_PER_MEAL AS PRICE_PER_MEAL FROM customer
  read findAll() (H2 2.5.250) SQL x4: SELECT pause.ID AS ID, pause.DAYS AS DAYS FROM pause WHERE pause.customer_id = ?
  <<< exit 0
  read findAll() (H2 2.5.250): org.springframework.jdbc.BadSqlGrammarException <- org.h2.jdbc.JdbcSQLSyntaxErrorException: Table "customer" not found (candidates are: "CUSTOMER")
  read findAll() (H2 2.5.250) SQL x1: SELECT "customer"."ID" AS "ID", "customer"."NAME" AS "NAME", "customer"."VERSION" AS "VERSION", "customer"."MEAL_TYPE" AS "MEAL_TYPE", "customer"."MEALS_PER_DAY" AS "MEALS_PER_DAY", "customer"."PRICE_PER_MEAL" AS "PRICE_PER_MEAL" FROM "customer"
  <<< exit 1
  read findAll() (PostgreSQL 18.6): aggregates 4
  read findAll() (PostgreSQL 18.6) SQL x1: SELECT "customer"."id" AS "id", "customer"."name" AS "name", "customer"."version" AS "version", "customer"."meal_type" AS "meal_type", "customer"."meals_per_day" AS "meals_per_day", "customer"."price_per_meal" AS "price_per_meal" FROM "customer"
  read findAll() (PostgreSQL 18.6) SQL x4: SELECT "pause"."id" AS "id", "pause"."days" AS "days" FROM "pause" WHERE "pause"."customer_id" = ?
  <<< exit 0
  read findAll() (H2 2.5.250): aggregates 4
  read findAll() (H2 2.5.250) SQL x1: SELECT customer.ID AS ID, customer.NAME AS NAME, customer.VERSION AS VERSION, customer.MEAL_TYPE AS MEAL_TYPE, customer.MEALS_PER_DAY AS MEALS_PER_DAY, customer.PRICE_PER_MEAL AS PRICE_PER_MEAL FROM customer
  read findAll() (H2 2.5.250) SQL x4: SELECT pause.ID AS ID, pause.DAYS AS DAYS FROM pause WHERE pause.customer_id = ?
  <<< exit 0
  read findAll() (PostgreSQL 18.6): aggregates 4
  read findAll() (PostgreSQL 18.6) SQL x1: SELECT customer.id AS id, customer.name AS name, customer.version AS version, customer.meal_type AS meal_type, customer.meals_per_day AS meals_per_day, customer.price_per_meal AS price_per_meal FROM customer
  read findAll() (PostgreSQL 18.6) SQL x4: SELECT pause.id AS id, pause.days AS days FROM pause WHERE pause.customer_id = ?
  <<< exit 0
```

### 3 · dup — the bean name both modules want

A COPY of `after/` whose Spring Data JDBC repository is named `CustomerEntityRepository` — the exercise's broken tree. The
simple-name check (R.354) passes on `after/` and fails on the copy; the copy's TiffinBox stops before it binds:

```text
R.354 - the repository interfaces' simple names across the two modules (harness/chk02.py names):
  repository interface CustomerEntityRepository - Spring Data JPA (its domain type CustomerEntity)
  repository interface CustomerAggregates - Spring Data JDBC (its domain type CustomerRow)
  bean names (the simple name, first letter lower-case): customerEntityRepository, customerAggregates · repeated: 0
  exit 0
  repository interface CustomerEntityRepository - Spring Data JPA (its domain type CustomerEntity)
  repository interface CustomerEntityRepository - Spring Data JDBC (its domain type CustomerRow)
  bean names (the simple name, first letter lower-case): customerEntityRepository, customerEntityRepository · repeated: 1 (customerEntityRepository)
  exit 1
  exit 1 · it listened on: nothing · 'APPLICATION FAILED TO START' 1
  log: Finished Spring Data repository scanning in <t> ms. Found 1 JPA repository interface.
  the exception (cut at its first ':' after the bean name): BeanDefinitionOverrideException: Invalid bean definition with name 'customerEntityRepository' defined in com.tiffinbox.jdbc.CustomerEntityRepository defined in @EnableJdbcRepositories declared on TiffinBoxApp
    The bean 'customerEntityRepository', defined in com.tiffinbox.jdbc.CustomerEntityRepository defined in @EnableJdbcRepositories declared on TiffinBoxApp, could not be registered. A bean with that name has already been defined in com.tiffinbox.CustomerEntityRepository defined in @EnableJpaRepositories declared on TiffinBoxApp and overriding is disabled.
```

### 4 · dirty — no dirty checking: B, A, A′, each window labelled (R.359, R.364, R.367)

Ravi, the data line built first. Each window changes `mealsPerDay` by one from what it loaded and commits. **B** — Spring Data JDBC,
`findById`, no `save`; **A** — Spring Data JPA, `findByName`, no `save` (the flush's dirty check writes it); **A′** — Spring Data JDBC,
`findById` and `save`. They run in the order B, A, A′, so that B meets the untouched row and the `version` sequence is one row's.
After each window the row is read back by a second client — psql in the container on PostgreSQL (one JVM per window), `JdbcTemplate`
on H2 (one JVM, H2 in memory) — never off the Java object, whose own line is printed only to show it says something else:

```text
  data (PostgreSQL 18.6, JdbcTemplate): customers 40 · pauses 38 · paused days 77
  psql, before any window: Ravi meals 2 version 0 updated_at null
  B the Java object after the change: meals 3 (the object, not the row)
  window B (Spring Data JDBC: findById, meals + 1, no save, commit) (PostgreSQL 18.6): statements 2
  window B (Spring Data JDBC: findById, meals + 1, no save, commit) (PostgreSQL 18.6) SQL: SELECT customer.id AS id, customer.name AS name, customer.version AS version, customer.meal_type AS meal_type, customer.meals_per_day AS meals_per_day, customer.price_per_meal AS price_per_meal FROM customer WHERE customer.id = ?
  window B (Spring Data JDBC: findById, meals + 1, no save, commit) (PostgreSQL 18.6) SQL: SELECT pause.id AS id, pause.days AS days FROM pause WHERE pause.customer_id = ?
  psql, after B: Ravi meals 2 version 0 updated_at null
  window A (Spring Data JPA: findByName, meals + 1, no save, commit) (PostgreSQL 18.6): statements 2
  window A (Spring Data JPA: findByName, meals + 1, no save, commit) (PostgreSQL 18.6) SQL: select ce1_0.id,ce1_0.created_at,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal,ce1_0.updated_at,ce1_0.version from customer ce1_0 where ce1_0.name=?
  window A (Spring Data JPA: findByName, meals + 1, no save, commit) (PostgreSQL 18.6) SQL: update customer set meal_type=?,meals_per_day=?,name=?,price_per_meal=?,updated_at=?,version=? where id=? and version=?
  window A: Hibernate getPrepareStatementCount() 2 · the witness 2 · equal: yes · entityUpdateCount 1 · flushCount 1
  psql, after A: Ravi meals 3 version 1 updated_at set
  window A' (Spring Data JDBC: findById, meals + 1, save, commit) (PostgreSQL 18.6): statements 4
  window A' (Spring Data JDBC: findById, meals + 1, save, commit) (PostgreSQL 18.6) SQL: SELECT customer.id AS id, customer.name AS name, customer.version AS version, customer.meal_type AS meal_type, customer.meals_per_day AS meals_per_day, customer.price_per_meal AS price_per_meal FROM customer WHERE customer.id = ?
  window A' (Spring Data JDBC: findById, meals + 1, save, commit) (PostgreSQL 18.6) SQL: SELECT pause.id AS id, pause.days AS days FROM pause WHERE pause.customer_id = ?
  window A' (Spring Data JDBC: findById, meals + 1, save, commit) (PostgreSQL 18.6) SQL: UPDATE customer SET name = ?, meals_per_day = ?, price_per_meal = ?, meal_type = ?, version = ? WHERE customer.id = ? AND customer.version = ?
  window A' (Spring Data JDBC: findById, meals + 1, save, commit) (PostgreSQL 18.6) SQL: DELETE FROM pause WHERE pause.customer_id = ?
  psql, after A': Ravi meals 4 version 2 updated_at set
  psql - updated_at after A' against after A: the same value (the values themselves not printed: times)
  psql - the pause rows, untouched by A' (Ravi has none): 38 pauses · 77 days
```

The same windows on H2 in memory, `JdbcTemplate` the second client:

```text
  read back by JdbcTemplate (a second client, H2 2.5.250): Ravi meals 2 version 0 updated_at null
  B the Java object after the change: meals 3 (the object, not the row)
  window B (Spring Data JDBC: findById, meals + 1, no save, commit) (H2 2.5.250): statements 2
  read back by JdbcTemplate (a second client, H2 2.5.250): Ravi meals 2 version 0 updated_at null
  window A (Spring Data JPA: findByName, meals + 1, no save, commit) (H2 2.5.250): statements 2
  window A: Hibernate getPrepareStatementCount() 2 · the witness 2 · equal: yes · entityUpdateCount 1 · flushCount 1
  read back by JdbcTemplate (a second client, H2 2.5.250): Ravi meals 3 version 1 updated_at set, a new value
  window A' (Spring Data JDBC: findById, meals + 1, save, commit) (H2 2.5.250): statements 4
  read back by JdbcTemplate (a second client, H2 2.5.250): Ravi meals 4 version 2 updated_at set, the same value as at the last read-back
```

Both modules raise one `version` column, in sequence, read back by psql: B leaves it, A (Spring Data JPA) raises it, A′ (Spring Data
JDBC) raises it again (R.364). The `updated_at` stamp is written by A — Spring Data JPA's auditing — and A′'s UPDATE names no
`updated_at`: psql reads the same value after A′ as after A. **RE-MEASURE 3**, on a COPY: with `@EnableJdbcAuditing` on
`TiffinBoxApp` and `@LastModifiedDate Instant updatedAt` on `CustomerRow`, Spring Data JDBC's UPDATE writes `updated_at` too, on both
databases (read back by `JdbcTemplate` and psql):

```text
  > import java.time.Instant;
  > import org.springframework.data.annotation.LastModifiedDate;
  > 
  >     @LastModifiedDate
  >     private Instant updatedAt;
  > import org.springframework.data.jdbc.repository.config.EnableJdbcAuditing;
  > @EnableJdbcAuditing
  read back by JdbcTemplate (a second client, H2 2.5.250): Ravi meals 2 version 0 updated_at null
  window A' (Spring Data JDBC: findById, meals + 1, save, commit) (H2 2.5.250) SQL: UPDATE customer SET NAME = ?, MEALS_PER_DAY = ?, PRICE_PER_MEAL = ?, MEAL_TYPE = ?, VERSION = ?, UPDATED_AT = ? WHERE customer.ID = ? AND customer.VERSION = ?
  read back by JdbcTemplate (a second client, H2 2.5.250): Ravi meals 3 version 1 updated_at set, a new value
  read back by JdbcTemplate (a second client, PostgreSQL 18.6): Ravi meals 2 version 0 updated_at null
  window A' (Spring Data JDBC: findById, meals + 1, save, commit) (PostgreSQL 18.6) SQL: UPDATE customer SET name = ?, meals_per_day = ?, price_per_meal = ?, meal_type = ?, version = ?, updated_at = ? WHERE customer.id = ? AND customer.version = ?
  read back by JdbcTemplate (a second client, PostgreSQL 18.6): Ravi meals 3 version 1 updated_at set, a new value
  psql, after it: Ravi meals 3 version 1 updated_at set
```

### 5 · lazy — no lazy loading, on both databases

After the call returns, outside any transaction: the aggregate already holds its pauses; the entity's collection was never loaded,
and with no session left to load it the call fails (Course 7's *Lazy Loading and LazyInitializationException*, `open-in-view: false`
as that lesson left it):

```text
  lazy (H2 2.5.250), after the call, no transaction: Spring Data JDBC getPauses() -> 1 · java.util.LinkedHashSet
  lazy (H2 2.5.250): Spring Data JPA getPauses().size() -> org.hibernate.LazyInitializationException: Cannot lazily initialize collection of role 'com.tiffinbox.CustomerEntity.pauses' with key '3' (no session)
  lazy (PostgreSQL 18.6), after the call, no transaction: Spring Data JDBC getPauses() -> 1 · java.util.LinkedHashSet
  lazy (PostgreSQL 18.6): Spring Data JPA getPauses().size() -> org.hibernate.LazyInitializationException: Cannot lazily initialize collection of role 'com.tiffinbox.CustomerEntity.pauses' with key '3' (no session)
  application.yaml's open-in-view, after/: open-in-view: false
```

### 6 · seven — the comparison set, unchanged

```text
  exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log during the seven: org.hibernate.SQL lines 6 · JdbcTemplate's SQL lines 0
  exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log during the seven: org.hibernate.SQL lines 6 · JdbcTemplate's SQL lines 0
  exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log during the seven: org.hibernate.SQL lines 6 · JdbcTemplate's SQL lines 0
  the seven, after/ against before/ (H2): lines that differ: 0 · after/ on PostgreSQL against after/ on H2: 0
```

### 7 · exercise — run as written, in one shell, bash then zsh (R.196)

`exercise/README.md`'s block and `exercise/SOLUTION.md`'s (one line changed) run one after the other in one `env -i` shell, H2 in
memory, no Docker, no port bound; each file's "What it prints" block is compared with the run, line for line, and the two differ.

## Which tests run where — and the machine recipe

`mvn package` runs the tests on H2 in memory and needs no Docker (the anchor capture runs it with Maven's `DOCKER_HOST` pointed at
`tcp://127.0.0.1:1`); `mvn verify` adds the three container tests on PostgreSQL. Both counts are read off Surefire's two report folders
(`surefire-reports`, `surefire-reports-it`), never typed. C1 adds no test: unit 07 adds the JDBC slice's. The recipe is Course 7's
capstone's: `export DOCKER_HOST=unix://$HOME/.orbstack/run/docker.sock`, `export TESTCONTAINERS_RYUK_DISABLED=true`, a receipt home
under `.harness/home` with `checks.disable` and `tinyimage.container.image`, the engine's events over the verify's window checked (one
container, the digest, no pull).

## Refused, named

- A duration or size adjective for a module (`faster`, `lighter`, `simpler`) — no such sentence; a cost is a statement count from a labelled window (R.355).
- "The row changed" read off the Java object — B's object says one more meal while psql and `JdbcTemplate` read the old value (R.359).
- Three counts in a row without their windows — each count is said with its window: B, A and A′ (R.367).
- A SQL line without its database — every SQL text in this README is a run's line with its database in it (R.353, R.365).
- Single-query loading — not claimed here (R.368).
- `Hibernate generates` — Hibernate writes the UPDATE (§10).
- The brief's "JDBC leaves `updated_at`" said as a property of the module — the anchor's mapping leaves it; the module's own auditing
  writes it when switched on (RE-MEASURE 3, a copy).

## Call-backs, by title (R.224)

- The persistence context, in the words of Course 7's *The Persistence Context*: "the set of entities one Entity Manager has loaded and
  keeps track of, at most one object per row" — Spring Data JDBC keeps no such set, so after a call returns nothing watches the
  object (C8-8, called back, not glossed again).
- Course 7's *Lazy Loading and LazyInitializationException* — `open-in-view: false`, the exception the lazy capture prints.
- Course 7's *Optimistic Locking with @Version* — the `version` column both modules raise.
- Course 4's *The Bean Lifecycle, Step by Step* — the before-initialisation callback `JdbcNames` uses.
- Forward, by title only: *Relationships Without an ORM* (the 1 + N and the delete-and-reinsert), *JPA vs JDBC vs Plain SQL* (the
  counts side by side), *Testing the JDBC Layer* (the slice that imports `JdbcNames`).

## The commands this unit adds

`receipts.sh` reads each of these lines from this block (and the anchor's own from `after/README.md`) and runs it as written:

```bash
javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/after/tiffinbox-web/target/extracted/lib/*:$DSP" harness/src/probe/u02/U2.java harness/src/probe/u02/Witness.java harness/src/probe/x/XMain.java
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -cp "../hc:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$DSP" probe.u02.U2 $STEPS --logging.config=../../harness/logback.xml --spring.main.banner-mode=off --spring.jpa.properties.hibernate.generate_statistics=true
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -cp "../hc:../lib-nofly/*" probe.x.XMain "${XA[@]}"
docker -H "$DH" run -d --pull never --name c8u02-pg -p 127.0.0.1:20411:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v "$U/.harness/secrets/pgpw:/run/pgpw:ro" postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
docker -H "$DH" exec c8u02-pg pg_isready -U sa -h 127.0.0.1 -q
docker -H "$DH" exec c8u02-pg psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c "drop database if exists $DB with (force)" -c "create database $DB"
docker -H "$DH" exec c8u02-pg psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c "drop database $DB with (force)"
docker -H "$DH" exec c8u02-pg psql -U sa -d "$DB" -qAt -v ON_ERROR_STOP=1 -c "$Q"
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.org.hibernate.SQL=debug --logging.level.org.springframework.jdbc.core.JdbcTemplate=debug
env "MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8" perl -e 'alarm 600; exec @ARGV' mvn -o -B -Dmaven.repo.local="$M2" "-DargLine=-Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Duser.home=../../home" clean verify
env DOCKER_HOST=tcp://127.0.0.1:1 "MAVEN_OPTS=-Duser.home=../home -Dstdout.encoding=UTF-8" perl -e 'alarm 600; exec @ARGV' mvn -o -B -Dmaven.repo.local="$M2" "-DargLine=-Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -Duser.home=../../home" clean package
```

## The repository, and the network

`.m2-demo` is a file copy of `../../../spring-data-beyond-jpa/_research/m2-seed-c8-s1/` (the course's seed, built in the set-up's one
network act, 2026-11-17); every build here is offline (`mvn -o`) and its log is checked for a download line: none. The witness,
datasource-proxy **1.11.1**, is in that seed and on the harness's class path alone — the number 1.11.1 appears in `receipts.sh`'s class
path line and here, never in the anchor's POMs or sources (R.357; the static check refuses it there). No image is pulled: the
PostgreSQL image is the pinned digest, `--pull never`, present before the run. Nothing leaves the machine but this unit's commit.

## The folders, the harness and the ports

- `before/` — `../c8-tiffinbox` at `50d64ac`, a frozen copy (the receipt compares it with `git archive 50d64ac c8-tiffinbox` at its
  start and end). `after/` — this unit's tree, `= ../c8-tiffinbox`.
- `harness/` — `src/probe/u02/U2.java` (the harness: TiffinBox's application class with no web server, its steps), `Witness.java`
  (datasource-proxy on the `DataSource` bean: the statement texts of each labelled window), `src/probe/x/XMain.java` (Course 7's
  schema-script probe, byte for byte), `chk02.py` (the checks), `s802.py` (the prose gate), `dur8.py` (the builders', byte for byte),
  `surefire.py` (the testing lesson's), `logback.xml`.
- Ports (20410-20419): 20410 TiffinBox `after/` · 20411 this run's PostgreSQL container (`-p 127.0.0.1:20411:5432`, `docker port`
  asserted) · 20414 the dup copy's TiffinBox, which stops before it binds · 20415 the seven on H2 · 20416 the seven on PostgreSQL.
  20412 (the B copy) and 20413 (the quote copy) are never bound: the windows and the quote copy run in the harness, with no web
  server. 20417-20419 are spare and never bound (the exercise binds none). All ten are checked free at the start and the end.

## Masks, filters and hygiene — every one, declared

The mask (self-tested before any capture): the token and the password (never printed; "raw copies after mask: 0"), this folder, its
parent and the home folder, the user's name, `using Java <version>`, Flyway's execution time, Spring Data's repository scanning time
(`in <t> ms`), identity hashes (`@…`), JSON timestamps. Filters: a TiffinBox log is read through named lines (strict mode, `Found`,
"Could not safely identify" cut at its `;`, Flyway's `Database:` line, HHH000001); a harness log through its `PROBE` lines and those.
Every capture is checked for absolute paths, unit numbers, log times, thread numbers, OS tokens, unmasked times, stack frames,
passwords in URLs and foreign URLs. Every JVM runs under `perl -e 'alarm N; exec …'` with its locale pinned (R.247); every docker call
names its socket (`docker -H "$DH"`, R.344); the container is removed with `rm -fv` and the volume count compared (R.322).

## Interrupted

Each on the scratch mirror: `receipts.sh` started, SIGINT sent to it at the named point (its trap stops every JVM and Maven by pid, removes
the container with its volume and any Testcontainers container, deletes the URL files and the partial captures):

- mid-build (Maven running): exit 130 · JVMs left 0 · the container gone · Testcontainers containers 0 · volumes 315 · listeners on 20410-20419 0 · partial captures 0 · `receipts.md5` unchanged · `.r-lock` left: no
- mid-harness (a harness JVM running): exit 130 · JVMs left 0 · the container gone · Testcontainers containers 0 · volumes 315 · listeners on 20410-20419 0 · partial captures 0 · `receipts.md5` unchanged · `.r-lock` left: no
- mid-container (the container up, a JVM running): exit 130 · JVMs left 0 · the container gone · Testcontainers containers 0 · volumes 315 · listeners on 20410-20419 0 · partial captures 0 · `receipts.md5` unchanged · `.r-lock` left: no
- mid-TiffinBox on PostgreSQL (the anchor capture's PostgreSQL start): exit 130 · JVMs left 0 · the container gone · Testcontainers containers 0 · volumes 315 · listeners on 20410-20419 0 · partial captures 0 · `receipts.md5` unchanged · `.r-lock` left: no
- mid-verify (Surefire's fork running): exit 130 · JVMs left 1 · the container gone · Testcontainers containers 0 · volumes 315 · listeners on 20410-20419 0 · partial captures 0 · `receipts.md5` unchanged · `.r-lock` left: no

Mid-verify, the first look after the exit counted one JVM still exiting (Surefire's fork, its Maven already stopped by the trap); the next look counted none. Every other count was zero at the first look. The first SIGINT attempt (a launcher that left SIGINT ignored, as a background job of a non-interactive shell does) ran to completion instead: it is not counted; the launcher now restores the default before `exec`.

## The ledger rows this unit pays

- **C8-4** "no lazy loading, no dirty checking" — **paid**: the UPDATE Spring Data JPA writes and Spring Data JDBC does not, by psql
  and `JdbcTemplate` (dirty); `LazyInitializationException` against the aggregate's pauses (lazy), on both databases.
- **C8-8** the persistence context's definition — **paid** (called back in Course 7's *The Persistence Context*'s words, above).

## RE-MEASURE — the brief's items this unit settles

- **1** — the shipped names (`CustomerRow`, `PauseRow`, `CustomerAggregates`, `JdbcNames`) and both modules' counts on the shipped tree,
  Q on H2 and PostgreSQL: anchor and quote.
- **3** — Spring Data JDBC's own auditing: measured on a copy, it writes `updated_at` on both databases; not adopted (What differed).
- **5** — the exercise's own run: broken, then solved, bash and zsh.
- **16** — the seven on `after/`: unchanged on H2 and on PostgreSQL.

## What differed from the brief

- **`before/` is a frozen copy, not a link.** The brief's Code-and-anchor line says `before → ../c8-tiffinbox`; the prompt (⚑8, RED #8)
  says a frozen copy of `c8-tiffinbox` at `50d64ac`, because `c8-tiffinbox` moves with this commit and unit 01's JPA-only tree must stay.
  The receipt compares `before/` with `git archive 50d64ac c8-tiffinbox` at its start and end. Course 7's link form resumes with unit 07.
- **The windows run B, A, A′ — not A, B, A′ — and each changes the meals by one from what it loaded.** Run in the brief's order on one
  row, B would meet A's write and could not show "psql still says 2"; run from fresh rows, the `version` sequence (R.364) would not be
  one row's. In the order B, A, A′ psql reads meals 2 → 2 → 3 → 4 and `version` 0 → 0 → 1 → 2 (the brief's "row 3" for A′ is 4 here,
  read off). The brief's statement counts hold, each with its window.
- **A′'s statements:** the brief says 4 (load 2 + UPDATE + DELETE); the prompt adds "+ the re-INSERTs". Ravi has no pauses, so the
  witness prints exactly two SELECTs, the UPDATE and the DELETE — no INSERT; the re-insert with ids is *Relationships Without an ORM*'s.
- **`lazy`: the aggregate holds Sunil's one pause, not two.** The brief's 2 was the probe's state after a pause had been added to him;
  on V2's seed (the lazy capture seeds nothing) Sunil has one. The key `'3'` and the exception's text match the brief, read off.
- **No harness driver on PostgreSQL.** The prompt asks for a driver added by the harness on every PostgreSQL line and `after/`'s `lib/` asserted
  to hold no `postgresql-*.jar`. Since Course 7's capstone the anchor's jar holds `postgresql-42.7.14.jar` (runtime scope), in `before/`
  and in `after/` alike; TiffinBox and the harness use the jar's own driver, the capture prints it in both `lib/` lists, and nothing is
  added — the claim stays the capstone's: TiffinBox on PostgreSQL through the config tree's URL, with its own driver.
- **The quote copy deletes `JdbcNames.java`.** The prompt's copy has `JdbcNames` "not imported". Measured: with only the `@Import` line (and
  its two imports) removed, H2 still reads four aggregates, unquoted — `@ComponentScan("com.tiffinbox")` finds the `@Configuration` in
  `com.tiffinbox.jdbc`. The quote capture shows that copy (`quote0`) first, then the copy without the class, which fails on H2.
  `after/` keeps `@Import(JdbcNames.class)` as the brief lists it (For RED).
- **The dup copy replaces `CustomerAggregates.java` instead of adding a second interface.** With an added interface the exercise's rename
  would leave two Spring Data JDBC repositories and could not print the brief's "JPA 1 + JDBC 1"; so the dup copy and the exercise's broken
  tree are one tree: Spring Data JDBC's repository named `CustomerEntityRepository` (`exercise/CustomerEntityRepository.java`).
- **The witness has no harness POM.** The prompt says "in the harness POM". The harness is compiled by `javac` against `after/`'s
  extracted jar, Course 7's capstone's form, with datasource-proxy 1.11.1's jar from `.m2-demo` on its class path: the number 1.11.1
  appears once in `receipts.sh` (its class path line) and in this README, never in the anchor (static check).
- **RE-MEASURE 3 — measured, not adopted.** `@EnableJdbcAuditing` and `@LastModifiedDate Instant updatedAt` on a copy work cleanly on both
  databases: the UPDATE writes `updated_at`. `after/` keeps the brief's C1 file list (no audit field, no `@EnableJdbcAuditing`): adopting it
  would change the anchor beyond C1 and give the hook's second module a write it does not need. The brief's sentence is re-worded:
  the anchor's Spring Data JDBC mapping leaves `updated_at` as it was (psql), and the module's own auditing writes it when switched on
  (a copy, both databases). The video may say both, in that scope.
- **Ports 20412 and 20413 are never bound.** The windows and the quote copies run in the harness with no web server; 20414 (the dup copy)
  is asked for and refused before binding. The prompt's list is otherwise kept.
- **The seven on H2 runs on the default URL, a fresh JVM each** — not over an H2 TCP server as Course 7's capstone did; the comparison
  set's md5 is the same on `before/`, `after/` and on PostgreSQL.
- **`mvn package` with Maven's `DOCKER_HOST` pointed at nothing** is the Docker-free run (the capstone's form), then `mvn verify`.
- **Tests and the seven ran inside the anchor and seven captures**, not a separate `tests` capture; the brief's capture list is kept.
- **The data line is built in `dirty` too** (40 · 38 · 77), as the prompt asks; the windows touch Ravi only.

## Planted faults — each caught (R.65, R.226)

Each on a scratch mirror of this folder (a `git clone --shared` of the repository with this unit's files and the new anchor put in), the
plant applied, `./receipts.sh` run; each exit 1, nothing written (`receipts.md5` compared before and after), the first refusal line quoted (the planted word itself elided with an ellipsis, so this README passes the same gates):

- an Indian dish name in a README sentence (R.215) — exit 1, `receipts.md5` unchanged: `an Indian dish name (R.215: English names only): README.md:12:Seven captures (p…r), each run in three passes by 'receipts.sh' and hashed ('receipts.md5'); every number and string below is asserted `
- a placeholder line (a planted to-do marker) appended to the README — exit 1, `receipts.md5` unchanged: `a placeholder line in this unit's prose or tree: README.md:486:T…O: the numbers`
- a typed SQL string in the prose, outside every printed block (R.225, R.365) — exit 1, `receipts.md5` unchanged: `a typed SQL string in the prose (R.225, R.365): README.md:12: The DELETE FROM p…e line. Seven captures, each run in three passes by 'receipts.sh' and hashed ('receipts.md5'); every number and string`
- a duration word (`faster`) in a README sentence (R.355, dur8) — exit 1, `receipts.md5` unchanged: `a refused word or reading in this unit's prose:   README.md line 12: dur8: f…r`
- "the row changed" read off the Java object (R.359) — exit 1, `receipts.md5` unchanged: `a refused word or reading in this unit's prose:   README.md line 12: R.359: the row read off the Java object (no second client named)`
- `@EnableJdbcRepositories` removed from `after/`'s `TiffinBoxApp` (R.354: JDBC 0) — exit 1, `receipts.md5` unchanged: `static: FAIL TiffinBoxApp carries @EnableJdbcRepositories("com.tiffinbox.jdbc")`
- the dup name shipped: the exercise's `CustomerEntityRepository` copied into `after/` — exit 1, `receipts.md5` unchanged: `R.354 on after/: repository interface CustomerEntityRepository - Spring Data JDBC (its domain type CustomerRow);bean names (the simple name, first letter lower-case): customerEntityRepository, custome`
- a `before/` that is not `50d64ac` (one byte added to its README) — exit 1, `receipts.md5` unchanged: `R.211: before/ is not ../c8-tiffinbox at 50d64ac (git archive): Files before/README.md and .harness/b50/c8-tiffinbox/README.md differ`
- the container removed without `-v` (R.322) — exit 1, `receipts.md5` unchanged: `R.322: receipts.sh removes a container without its volume (rm -fv)`
- the docker CLI unpinned (`dk()` without `-H`), the run started under `DOCKER_HOST=tcp://127.0.0.1:1` (R.344) — exit 1, `receipts.md5` unchanged: `R.344: dk() must name the pinned socket (docker -H "$DH")`
- one of the anchor README's unit 02 notes removed (R.250) — exit 1, `receipts.md5` unchanged: `R.250: FAIL R.250: after/README.md notes it in place: *(Course 8, unit 02: Spring Data JDBC is beside Spring Data JPA since`
- a wrong published hash (the exercise's line in `receipts.md5`) — exit 1, `receipts.md5` changed by the plant itself, nothing else written: `exercise is not the published capture - suspect another JDK, Boot or Maven, a busy machine, a variable of yours, or an edited source; diff .r-exercise.out against its block in README.md`
- a changed What-it-prints line (`TiffinBox: exit 2` in the exercise README) — exit 1, `receipts.md5` unchanged: `exercise/README.md's "What it prints" block is not what its lines printed: 2c2 < TiffinBox: exit 2 ---`
- the exercise's solution = broken: its `sed` renames the interface to its own name (R.196) — exit 1, `receipts.md5` unchanged: `exercise: its check failed (harness/chk02.py, above) - first FAIL solved: TiffinBox exit 0, Found 1 JPA + Found 1 JDBC, no override error`
- Q landed before `quote` runs: the quote copy keeps `JdbcNames` (the quoting failure hidden, R.365) — exit 1, `receipts.md5` unchanged: `quote: its check failed (harness/chk02.py, above) - first FAIL the quote copy: JdbcNames deleted, its import and @Import gone - nothing else`
- the mapping run on PostgreSQL only: the harness's H2 run dropped from the anchor capture (R.353) — exit 1, `receipts.md5` unchanged: `anchor: its check failed (harness/chk02.py, above) - first FAIL the harness on H2: the connection says H2 2.5.250`
- a version claim without `HHH000001`: Hibernate's core logger dropped from the harness's logback (R.246) — exit 1, `receipts.md5` unchanged: `anchor: its check failed (harness/chk02.py, above) - first FAIL the harness on H2: the version lines (R.246)`

## The anchor moved on — the builders (R.211, R.331)

Before the commit, `grep -n 'c8-tiffinbox\|c7-tiffinbox'` over `spring-data-beyond-jpa/_builders/*.py`, `data-jpa-hibernate/_builders/s7*.py`,
`check_unit8.py`, `qa_java8.py`, `check_unit7.py` and `qa_java7.py`: no Course 8 builder exists yet (`_builders/` holds `dur8.py` alone,
which names no anchor); no line names `c8-tiffinbox`; the lines of Course 7's builders name `c7-tiffinbox`, which this unit does not touch;
the four tools name neither. No builder is edited. No earlier Course 8 unit froze a tree from `c8-tiffinbox`, so there is nothing to
re-run; from this commit on, a unit that froze `c8-tiffinbox` would compare against `c8-unit02/after`, R.211's note form.

## The root .gitignore

The `c8-unit*` patterns (`.m2-demo/`, `.harness/`, `.r-*`, `**/target/`, `**/secrets/`) were added by the set-up (D3); `git status
--short` before the commit lists `c8-unit02/` and `c8-tiffinbox/` only, and nothing is added to `.gitignore`.

## For RED

- **`@Import(JdbcNames.class)` is redundant in `after/`** — `TiffinBoxApp`'s `@ComponentScan("com.tiffinbox")` already registers
  `JdbcNames` (the `quote0` copy reads unquoted on H2 without the `@Import`). It stays because the brief lists it and because unit 07's
  slice scans nothing and must import the class; a script must not say the `@Import` is what fixes the quoting in the application.
- **The "Could not safely identify store assignment" line is Spring Data JPA's alone, once per start** (for `CustomerAggregates`): Spring
  Data JDBC scans only `com.tiffinbox.jdbc`, so it never meets `CustomerEntityRepository`. The probe's two-sided form needed
  `@EnableJdbcRepositories("com.tiffinbox")`.
- **Strict mode's line is logged once per module** — two lines per start, read off both TiffinBox starts and every harness JVM.
- **Every harness log holds one Hibernate SQL line before any window** — TiffinBox's own start loads its customers by name, on either database; the windows
  are opened after it and the witness counts only inside them.
- **The witness counts calls to `prepareStatement`, `prepareCall` and `createStatement` on the connection**, with the SQL text each was
  given; the `DELETE` that removes no row (Ravi has no pauses) is still one statement. On the JPA side Hibernate's
  `getPrepareStatementCount()` equals it in window A on both databases (a mismatch exits 3).
- **`updated_at` is compared, never printed** — psql's two values are kept in the run and compared ("the same value"); on H2 the
  harness compares the text it read back with the previous read-back.
- **The anchor README's own section types two counts** — "seven files besides this README" and "the 18 tests … and the 3" — each matched by
  this unit's anchor capture (C1's list; Surefire's two folders). Course 7's anchor sections did the same; this unit's README types none.
- **The exercise binds no port** (`--spring.main.web-application-type=none`, measured: TiffinBox exits 0 by itself once its context is up).
- **The brief's "row 3" for A′ and "2 pauses" for lazy are not this run's** — see What differed; both read off, never typed.
- **No V4, `ddl-auto: validate` unchanged**: `validate` still checks Spring Data JPA's entities only; `CustomerRow` is never seen by Hibernate
  (its `@Table` is Spring Data Relational's), and Hibernate's schema script is byte-identical to the capstone's.
- **Single-query loading was not touched** — `findAll()` reads 1 + N on both databases on the default; the flag is *Relationships Without
  an ORM*'s and *JPA vs JDBC vs Plain SQL*'s to name.
- **SIGINT mid-verify left Surefire's fork still exiting at the first look after the receipt's exit** (one JVM then, none at the
  next). The trap kills Maven's process tree by pid and sweeps the process group; the fork had already been told to stop.
