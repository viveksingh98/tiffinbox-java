# c8-unit04 — JdbcClient and Custom Queries

Course 8, Section 1 (Spring Data JDBC), unit 04 — **a harness unit: no anchor change.** It measures what `JdbcClient` does with one
query written by hand — the same JDBC Course 2 wrote in *JDBC: Connect, Query, Map Rows to Records* and *TiffinBox on a Real
Database: The JDBC Repository*, with the loop, the closing and the checked exception taken over by Spring — on PostgreSQL 18.6 in a
container (the hook's store) AND on H2 in memory, the anchor's default: Meera by name four ways and the text the driver received for
each, a custom query the repositories cannot say in one statement, what a missing row and too many rows throw, what `optional()` and
`list()` answer instead, and whether the record `query(Customer.class)` builds is held to its own rules (RE-MEASURE 10).

- `anchor` → `../c8-unit02/after` (a link; both Spring Data modules, `JdbcNames`'s Q imported; `../c8-tiffinbox` equals it today,
  `diff -rq` empty, printed by every run). `harness/tree04.py` pins its tree: the file count and the md5 in `receipts.md5`'s
  `anchor-tree` line, written from a run's own output (the same pin unit 01 and unit 03 filed: the anchor has not moved).
- Nothing in the anchor is edited. The tree is copied under `.harness/` and built there, offline, from `.m2-demo` (a copy of the
  course's seed `spring-data-beyond-jpa/_research/m2-seed-c8-s1/`). The exercise's broken program is `exercise/Ex04.java` as shipped;
  its solution is derived by the one `sed` line in `exercise/SOLUTION.md`, and every run prints that line; neither is committed as a tree.

Run it: `./receipts.sh` from this folder (JDK 25, Maven, OrbStack's docker socket, the postgres image by its digest already on the
machine — the script never pulls). Every number below is a line a run printed; the values block is assembled from `harness/chk04.py`'s
output and compared with this file byte for byte.

## The captures — what each one shows

Six captures, each run 3/3 and hashed (`receipts.md5`); each is read back by `harness/chk04.py` against a second witness of
the same run before its hash is compared. Every statement count is the witness's — datasource-proxy 1.11.1 on the `DataSource` bean,
unit 02's class with its package line alone changed — per labelled window (R.357, R.367); `JdbcTemplate`'s DEBUG log of the same
window is the second count (`Executing prepared SQL statement` lines, asserted equal) and its bracketed SQL is asserted equal to the
text the witness kept. The text the driver received is the witness's: the string handed to `Connection.prepareStatement`. On
PostgreSQL the rows are read back by psql in the container; on H2 in memory by `JdbcTemplate` in the same JVM. Each sequence builds the
data line first (the seed step: V2's rows, then customers by `JdbcTemplate` with one 2-day pause each — RE-MEASURE 4), on a fresh
database per PostgreSQL sequence. Every JdbcClient call goes through the context's own `JdbcClient` bean (one, `DefaultJdbcClient`,
printed by every JVM).

### 1 · client — the hook: Meera by name, four ways (PostgreSQL 18.6; the counts repeated on H2)

psql reads Meera's row before the hook, so the record's text is derived from the row, never typed; chk04 builds
`Customer[name=…, mealsPerDay=…, pricePerMeal=…, mealType=…]` from psql's line and asserts each form's `toString` equal to it.
Then five windows, one call each: `JdbcClient` with `:name` and `query(Customer.class).single()` (the hook), the positional form
`.param("Meera")` with `?`, a lambda `RowMapper` (the explicit form), `new DataClassRowMapper<>(Customer.class)`, and — in a window of
its own, labelled — `JdbcTemplate.queryForObject` with `?`, Course 2's shape.

```text
psql, Meera's row (a second client, PostgreSQL): Meera · 1 · 150 · NON_VEG
PROBE client named (JdbcClient, :name, query(Customer.class).single(), PostgreSQL 18.6): the witness 1 · SELECT 1
PROBE client named (JdbcClient, :name, query(Customer.class).single(), PostgreSQL 18.6) SQL x1: select name, meals_per_day, price_per_meal, meal_type from customer where name = ?
PROBE client named: Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, mealType=NON_VEG]
log client named x1: Executing prepared SQL statement [select name, meals_per_day, price_per_meal, meal_type from customer where name = ?]
PROBE client positional (JdbcClient, ?, query(Customer.class).single(), PostgreSQL 18.6): the witness 1 · SELECT 1
PROBE client lambda (JdbcClient, :name, a lambda RowMapper, single(), PostgreSQL 18.6): the witness 1 · SELECT 1
PROBE client DataClassRowMapper (JdbcClient, :name, new DataClassRowMapper<>(Customer.class), single(), PostgreSQL 18.6): the witness 1 · SELECT 1
PROBE client: the four records equal (equals): true · 4 records
PROBE template (JdbcTemplate.queryForObject, ?, a lambda RowMapper - Course 2's shape, its own window, PostgreSQL 18.6): the witness 1 · SELECT 1
PROBE template: Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, mealType=NON_VEG] · equal to the four: true
```

The four ways, as the capture has them (each cell a line of `client`; the same on H2 2.5.250, chk04 asserts it):

| the call (PostgreSQL 18.6) | prepares (the witness) | the text the driver received | the record | equal |
|---|---|---|---|---|
| `JdbcClient` `:name` · `query(Customer.class).single()` | the window's count | `… where name = ?` | Meera's | yes |
| `JdbcClient` `?` · `.param("Meera")` · `query(Customer.class)` | the window's count | `… where name = ?` | Meera's | yes |
| `JdbcClient` `:name` · a lambda `RowMapper` | the window's count | `… where name = ?` | Meera's | yes |
| `JdbcClient` `:name` · `DataClassRowMapper` | the window's count | `… where name = ?` | Meera's | yes |
| `JdbcTemplate.queryForObject` `?` (its own window) | the window's count | `… where name = ?` | Meera's | yes |

The rows: `single()` returns exactly one record or throws (capture `missing` shows both throws), so each form's one record is its
one row; the witness counts statements, not rows (unit 02's class, unchanged). The hazard is in the text column: the `:name` in the
SQL string is rewritten to `?` before the driver receives it — the same text at the driver for the five calls, on both databases.

### 2 · custom — the query the repositories cannot say in one statement

`select c.name, coalesce(sum(p.days), 0) as paused_days from customer c left join pause p on p.customer_id = c.id group by c.name order by c.name`
through `JdbcClient`, `.query((rs, i) -> …).list()`, one window, on PostgreSQL 18.6 and on H2 2.5.250. psql runs the same SQL in
the container and counts its rows and their sum; chk04 asserts the rows equal the data line's customers (the left join keeps a
customer with no pause as a row, Meera's paused days `0`) and the sum equal the data line's paused days and psql's sum.

```text
psql (a second client, PostgreSQL): 40 customers · 38 pauses · 77 paused days
psql, the same SQL (a second client, PostgreSQL): rows 40 · the sum of paused_days 77
PROBE custom (JdbcClient, one SQL string, list(), PostgreSQL 18.6): the witness 1 · SELECT 1
PROBE custom: rows 40 · the sum of paused_days 77 · Meera Meera:0 · Sunil Sunil:3
PROBE custom (JdbcClient, one SQL string, list(), H2 2.5.250): the witness 1 · SELECT 1
```

The same question through the two repositories is unit 06's to count (*JPA vs JDBC vs Plain SQL*), in its own run — this unit
names no count for it, and never sets the custom query's window beside a window of another run (R.367).

### 3 · missing — the failure receipt: no row, too many rows

On each database: one JVM runs `single()` on "Nobody" and lets the exception end it (exit 1, asserted); a second JVM runs
`optional()` and `list()` on "Nobody" and `single()` on `select name from customer`. The "actual" in the second text is asserted
equal to the data line's customer count. The class chain is printed by the harness (`Class.getSuperclass()` up to `Object`), not
asserted beyond the two names in it: `DataAccessException`, and `RuntimeException` — the exception is unchecked.

```text
PROBE nobody (JdbcClient, "Nobody", single(), PostgreSQL 18.6): the witness 1 · SELECT 1
PROBE a step threw (PostgreSQL 18.6): org.springframework.dao.EmptyResultDataAccessException: Incorrect result size: expected 1, actual 0
exit 1 · its log: ERROR lines 0
PROBE missing optional: Optional.empty
PROBE missing list: size 0
PROBE missing many: org.springframework.dao.IncorrectResultSizeDataAccessException: Incorrect result size: expected 1, actual 40
PROBE a step threw (H2 2.5.250): org.springframework.dao.EmptyResultDataAccessException: Incorrect result size: expected 1, actual 0
```

The texts and the chain are the same on H2 2.5.250 (chk04 asserts it); the chain is in the values block.

### 4 · unchecked — RE-MEASURE 10: the record built from a row that breaks its rules (PostgreSQL 18.6)

The anchor's `Customer` record carries `@Min(1) @Max(3) int mealsPerDay` (the receipt checks the line is there). psql writes a copy
of Meera's row into a schema of this capture's own, `u04x`, with `meals_per_day` `0` — never the anchor's rows: psql reads Meera's
row in `public.customer` before and after, unchanged. `query(Customer.class).single()` on the copy builds the record: no
`ConstraintViolationException`, no ERROR line, exit 0, and the value read back off the record (`mealsPerDay()`) equals psql's and
`JdbcTemplate`'s. Then, after the read, the harness asks the context's own `Validator` about that record, so the capture shows the
rule exists and that nothing applied it on the way in. This is a fifth capture of its own (`unchecked`), not a window of `client`;
on PostgreSQL only (psql writes the copy row; H2 not measured here).

```text
psql, the copy row (a second client, PostgreSQL): Meera · 0 · 150 · NON_VEG
psql, Meera's row in public.customer (a second client, PostgreSQL): Meera · 1 · 150 · NON_VEG
PROBE unchecked: the record built: Customer[name=Meera, mealsPerDay=0, pricePerMeal=150, mealType=NON_VEG] · mealsPerDay() 0 · no exception
PROBE unchecked: the context's Validator (LocalValidatorFactoryBean), asked afterwards by the harness: violations 1 · mealsPerDay: must be greater than or equal to 1
psql, Meera's row in public.customer after (a second client, PostgreSQL): Meera · 1 · 150 · NON_VEG
```

### 5 · seven — the comparison set, unchanged (RE-MEASURE 16)

`anchor/`'s jar, `java -jar` on H2 in memory, port 20430 (loopback), the seven requests of `../c5-unit11/curlset.sh` (the shutdown
token on its standard input, never on a command line), TiffinBox stopped by its own `POST /shutdown`. The md5 is compared with Course
7's `S466`, read off `../c7-unit31/receipts.sh`.

```text
GET /actuator/health/readiness -> 200 · listens on: 127.0.0.1:20430
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20430 now: 0
```

### 6 · exercise — run as written, in one shell, bash then zsh (R.196)

`exercise/README.md`'s lines, then `exercise/SOLUTION.md`'s, in ONE `env -i` shell — `/bin/bash --noprofile --norc`, then `/bin/zsh -f`;
each file's "What it prints" block is compared with what its lines printed, line for line. H2 in memory, no Docker, no Maven, no
port (20432 is never bound): the block compiles `exercise/Ex04.java` against the jar this receipt built. The broken program ends the
Nobody lookup in `single()` and exits 1; the solution's one changed line makes it `optional()`, and the program exits 0. chk04
asserts the broken program's exception text equal to capture `missing`'s — on H2 and on PostgreSQL, the same text — the solved
line equal to `missing`'s `optional()` line, and Meera's lookup equal to capture `client`'s record.

```text
$ sed 's/param("name", "Nobody").query(Customer.class).single()/param("name", "Nobody").query(Customer.class).optional()/' exercise/Ex04.java > .harness/ex/src/probe/ex/Ex04.java
EX lookup Nobody threw: org.springframework.dao.EmptyResultDataAccessException: Incorrect result size: expected 1, actual 0
EX lookup Nobody: Optional.empty
```

## The values the video may say

Assembled from chk04.py's `VALUES` lines; `receipts.sh` refuses this file unless the line below is byte-equal to what the run assembled.

<!-- values: begin -->
the values the video may say - client: PostgreSQL 18.6: JdbcClient.sql("... where name = :name").param("name", "Meera").query(Customer.class).single() -> Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, mealType=NON_VEG] (psql's row: Meera · 1 · 150 · NON_VEG); the driver received `select name, meals_per_day, price_per_meal, meal_type from customer where name = ?` (the witness); the four JdbcClient forms (:name, ?, a lambda RowMapper, DataClassRowMapper) 1 prepare each, the records equal; JdbcTemplate.queryForObject (its own window) 1 prepare, equal; H2 2.5.250: the same counts, the same text; versions: Spring Boot 4.1.2 · Spring Framework 7.0.10 · Spring Data JDBC 4.1.2 · Hibernate 7.4.13.Final · datasource-proxy 1.11.1 · custom: PostgreSQL 18.6: 1 statement, 40 rows, the sum of paused_days 77 (= the data line's 77; psql the second client); H2 2.5.250: 1 statement, 40 rows, the sum of paused_days 77 (= the data line's 77; JdbcTemplate's data line); the same question through the repositories is unit 06's count · missing: single() on Nobody -> org.springframework.dao.EmptyResultDataAccessException: Incorrect result size: expected 1, actual 0 (exit 1; PostgreSQL 18.6 and H2 2.5.250, the same text); optional() -> Optional.empty; list() -> size 0; single() on select name from customer -> org.springframework.dao.IncorrectResultSizeDataAccessException: Incorrect result size: expected 1, actual 40; the class chain (getSuperclass(), printed): org.springframework.dao.EmptyResultDataAccessException -> org.springframework.dao.IncorrectResultSizeDataAccessException -> org.springframework.dao.DataRetrievalFailureException -> org.springframework.dao.NonTransientDataAccessException -> org.springframework.dao.DataAccessException -> org.springframework.core.NestedRuntimeException -> java.lang.RuntimeException -> java.lang.Exception -> java.lang.Throwable -> java.lang.Object · unchecked: RE-MEASURE 10, PostgreSQL 18.6: a copy of Meera's row with meals_per_day 0 (schema u04x, psql) -> query(Customer.class).single() builds Customer[name=Meera, mealsPerDay=0, pricePerMeal=150, mealType=NON_VEG], no exception, mealsPerDay() 0; the context's Validator (LocalValidatorFactoryBean), asked afterwards by the harness: mealsPerDay: must be greater than or equal to 1 · seven: the seven on anchor/ (H2): 466c20ed…, unchanged · exercise: the exercise (20 words, H2 in memory, no Docker): broken - single() on Nobody -> org.springframework.dao.EmptyResultDataAccessException: Incorrect result size: expected 1, actual 0, exit 1; solved - optional() -> Optional.empty, exit 0; Meera's lookup Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, mealType=NON_VEG] in both
<!-- values: end -->

The hook, with its database: on PostgreSQL 18.6, `client.sql("select name, meals_per_day, price_per_meal, meal_type from customer where name = :name").param("name", "Meera").query(Customer.class).single()`
→ `Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, mealType=NON_VEG]`, and the driver received
`select name, meals_per_day, price_per_meal, meal_type from customer where name = ?` (the witness; the same on H2 2.5.250).

## Course 2's block, shown as text only

The try-with-resources block of *JDBC: Connect, Query, Map Rows to Records*, as `../c2-unit35/src/main/java/Connect.java` holds it
(the receipt asserts every line below is a line of that file). It is shown, never run: no Course 2 code runs in this unit.

```java
        try (Connection c = dataSource.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "SELECT id, name, email, meal_type, active FROM customers "
               + "WHERE meal_type = ? ORDER BY id")) {
            ps.setString(1, "NON_VEG");            // 1 is the ?'s position, not a column
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) nonVeg.add(toCustomer(rs));
            }
        }
```

What `JdbcClient` keeps from it, as the captures show it: the prepared statement and its parameter — the driver still receives one
prepared statement with a question mark (`client`, the witness's text). What it removes: the connection and the two resources to
close, the `while (rs.next())` loop (`query(Customer.class)` or a `RowMapper` builds each record), and the checked `SQLException` —
a missing row arrives as `EmptyResultDataAccessException`, a `DataAccessException` and a `RuntimeException` (`missing`'s chain).

## Refused, named

- **`:name` at the driver:** refused by `s804.py`; the witness's text is `… where name = ?` for every call on both databases. The
  `:name` is rewritten to `?` before the driver receives it (the hazard).
- **"Validated" or "checked" said of the record `query(Customer.class)` builds:** refused unless it is said as `unchecked` shows it —
  the record is built with a value its rules refuse, and nothing applies them on that path.
- **A pair of counts from two windows (R.367):** the custom query's window is never set beside the repositories' (unit 06's run).
- **"N times" (R.309):** "four calls, one text at the driver", never a count of times.
- **`faster`, `lighter`, `simpler` (R.355, R.366):** refused without a count beside them; dur8 words: 0.
- **A page fetched over HTTP:** only the seven (port 20430); every count is the harness's direct call (20430 is not used for any
  other capture).

## Call-backs, by title (R.224)

- Course 2's *JDBC: Connect, Query, Map Rows to Records* (unit 35) and *TiffinBox on a Real Database: The JDBC Repository* (unit 38):
  the titles as `~/Desktop/PromptVidya-Automation/java2_series.py` holds them, read on 2026-11-17 —
  `80: "35": "JDBC: Connect, Query, Map Rows to Records",` and `83: "38": "TiffinBox on a Real Database: The JDBC Repository",`
  (`/usr/bin/grep -n`); the brief's titles are byte-equal to them. The receipt checks both titles are in this file.
- Course 6's rule ("a record the database builds is never checked"): no Course 6 unit says it. `/usr/bin/grep -rn -i -E
  'never checked|not checked|checks nothing|seed builds|database or the seed|database builds'` over the Course 6 scripts
  (`spring-web-mvc/scripts-and-decks/*.md`) finds no such sentence, and `java6_series.py`'s titles name none (its unit 12 is *Validation
  on the Way In*, whose script says what validation checks on the way in, not this). The words are the anchor's own: the Javadoc of
  `tiffinbox-core/src/main/java/com/tiffinbox/Customer.java` ("a record the database or the seed builds is never checked"). So the
  title call-back is dropped, as the prompt allows, and the measurement stays (`unchecked`).
- Course 8's *Aggregates, Not Entities* (unit 02, the module this unit reads through) and, forward by title only, *JPA vs JDBC vs
  Plain SQL* (unit 06, the same question through the repositories).

## The commands this unit adds

- The harness: `javac -parameters -d .harness/hc -cp "<anchor's jar>:<its lib/*>:$DSP" harness/src/probe/u04/*.java`, then
  `java -cp "../hc:../after/<jar>:../after/<lib/*>:$DSP" probe.u04.U4 <steps>` from `.harness/run`, with
  `--logging.config=../../harness/logback.xml` (JdbcTemplate at DEBUG) and, on PostgreSQL,
  `--tiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:20431/<db>?user=tiffinbox`. Steps: `seed`, `client`, `custom`, `missing`,
  `nobody`, `unchecked`. `$DSP` is datasource-proxy 1.11.1 in `.m2-demo` — on the harness's class path only; no harness POM (unit 02's form).
- The container: `docker -H "$DH" run -d --pull never --name c8u04-pg -p 127.0.0.1:20431:5432 -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust postgres@sha256:77f58511…`
  — trust on loopback, as units 01 and 03 did; no password anywhere. Removed with `docker -H "$DH" rm -fv`.
- The PostgreSQL driver is the anchor jar's own (`postgresql-42.7.14.jar` in its `lib/`); the harness adds none.

## The repository, and the network

`.m2-demo` is a copy of `spring-data-beyond-jpa/_research/m2-seed-c8-s1/` (6,966 files, `cp -c -R`). Every Maven run is `mvn -o` with
`-Dmaven.repo.local=.m2-demo`; each log is checked for `Downloading from` / `Downloaded from` lines (none, else the run stops). No image
pull, no metadata read, no `git fetch`: `origin/main...main` was read from the local tracking ref. The one network act is the final
`git push`.

## The folders, the harness and the ports

- `harness/src/probe/u04/U4.java` (the steps), `Witness.java` (unit 02's witness, its package line alone changed — the receipt diffs
  it); `harness/chk04.py` (the checks), `harness/s804.py` (the prose gate, its own self-test), `harness/dur8.py` (the builders', as unit
  02 shipped it, `cmp`-checked), `harness/tree04.py` (unit 03's tree03.py method), `harness/logback.xml` (unit 03's, JdbcTemplate's
  logger at DEBUG).
- `exercise/Ex04.java`, `exercise/README.md`, `exercise/SOLUTION.md`; `receipts.sh`, `receipts.md5`.
- Ports, 20430-20439: **20430** TiffinBox for the seven only · **20431** the container · **20432** (the exercise) never bound — H2 in
  memory, no web server · **20433-20439** spare, never bound. 18425 and 8080 (the anchor's own defaults) are checked free at start
  and end. All free at start and end (`lsof`).

## Masks, filters and hygiene — every one, declared

- Captures print selected lines only: each harness JVM's `PROBE` lines, its two `Found … repository interface` lines, Flyway's
  `Database:` line and `HHH000001`; each window's `JdbcTemplate` DEBUG lines (`Executing prepared SQL statement [...]`), sorted with
  their counts; psql's read-backs; the seven's response lines (each `"timestamp"` value masked); the exercise's own `EX` lines.
- The mask (self-tested at the start with a planted `Started … in 3.1 seconds (process running for 4.2)`, a `Time elapsed:` line, a
  scan line, a Flyway execution time and the folders — dur8 must find nothing in the masked text, R.366): the unit's folder → `…`, the
  repository → `…/..`, home → `~`, Boot's started-in, Surefire's elapsed, Flyway's execution time, Spring Data's scan time, Maven's total
  → `<t>`, identity hashes → `@…`.
- Hygiene, every capture: no absolute path, no unmasked time, no log time, no stack frame, the shutdown token absent; every `java`/`mvn`
  line under its alarm; no H2 file outside `.harness`.

## The ledger rows this unit pays

Nothing on the ledger (the brief); the roadmap line `:330` — "Course 2's raw JDBC, industrialised" — is `client` (the same prepared
statement with a question mark at the driver) and `missing` (the checked exception gone); contract §4.4 (Course 2's JDBC under it).

## RE-MEASURE — the brief's items this unit settles

- **10 (a record built by `query(Customer.class)` with an invalid value):** captured (`unchecked`, PostgreSQL 18.6): the record is
  built with `mealsPerDay()` read back off it, no exception; the context's `Validator`, asked afterwards, names `mealsPerDay`.
- **16 (the seven, every unit):** `anchor/` on H2, = `c7-unit31`'s `S466` (`seven`).

## What differed from the brief

- **The rows per call are not a witness count.** The prompt asks for one prepare and one row per form; unit 02's witness counts statements
  only, and the receipt requires it unchanged but for its package line (R.357). The row is shown by `single()` itself — it returns one
  record or throws (`missing` shows both throws) — and by the record equal to psql's row; no `ResultSet.next()` counter was added.
- **JdbcTemplate is shown, in its own window.** The prompt allows `JdbcTemplate.queryForObject` as Course 2's shape only with its count
  on its own labelled line: it is the `template` window, after the four `JdbcClient` windows; `NamedParameterJdbcTemplate` and the two
  templates' bean lines are unit 05's and are not shown here.
- **RE-MEASURE 10 is a fifth capture, `unchecked`, on PostgreSQL only**, with a copy row in schema `u04x` made by psql
  (`create table … as select … where name = 'Meera'`, then `meals_per_day = 0`) — derived from Meera's row, never typed. H2 is not
  measured for it. The `Validator` line is the harness asking after the read, to show the rule exists; it is not a step of
  `JdbcClient`.
- **Course 6's title call-back is dropped:** no Course 6 unit says the rule (Call-backs, above). The rule's words are the anchor's
  Javadoc; the script may quote it as the anchor's comment, by file, not as a unit.
- **The text at the driver is checked against JdbcTemplate's DEBUG text too:** for these queries JdbcTemplate logs
  `Executing prepared SQL query` and `Executing prepared SQL statement [sql]` per call; the second is counted and its SQL compared with
  the witness's. Unlike unit 03's INSERT with an id, no batch line appears (asserted: `Executing SQL batch update` 0 in every window).
- **The exercise runs on H2 in memory, no Docker:** the exception's text was asserted equal on H2 and PostgreSQL (`missing`), so the
  exercise's README states the one text. Its program prints the lookup a route makes; no web server is started (20432 unbound) — the
  route itself is not fetched.
- **`unchecked` seeds the data line too** (the seed step before the copy row), so every PostgreSQL sequence of this unit starts the
  same way; the copy row's capture names no count of customers.
- **No Course 2 code is run.** Its block is text, read off `c2-unit35`'s `Connect.java` by the receipt.

## Runs of record

On the script as committed (`md5 -q receipts.sh` in the block), each run of record ended exit 0 with every capture 3/3 and
`= published`, every Maven run `offline: yes`, volumes and images unchanged, nothing listening on 20430-20439 at the end; each run's
log went through `~/.venvs/slides2video/bin/python ~/Desktop/PromptVidya-Automation/check_unit8.py 04 --runlog <log>` (R.352; R.166's
grep errors only — the unit gate itself waits for a script: "no 04-*.md in scripts-and-decks/ yet"). The three: `./receipts.sh` (the
shebang's `/bin/bash`, 3.2.57), `bash receipts.sh` (Homebrew's bash, 5.3.9), and a sealed fresh clone — `git clone file://…` of this
repository at a local commit of this folder, into a path with a space, `.m2-demo` copied from the seed, `DOCKER_CONFIG=$HOME/.docker`,
`http_proxy`/`https_proxy` pointed at a dead `127.0.0.1:9`.

```
receipts.sh md5 08159b93ec7ec255ba333a5eb2615a5f
./receipts.sh        /bin/bash 3.2.57             exit 0   wall clock 208 s   check_unit8.py 04 --runlog: PASS
bash receipts.sh     /opt/homebrew/bin/bash 5.3.9 exit 0   wall clock 211 s   check_unit8.py 04 --runlog: PASS
sealed clone         git clone file://… (local commit 72897d9) into "…/scratchpad/ev04/clone dir/tiffinbox-java" (a path with a space),
                     .m2-demo from the seed, DOCKER_CONFIG=$HOME/.docker, http(s)_proxy at 127.0.0.1:9 (dead):
                     ./c8-unit04/receipts.sh exit 0   wall clock 218 s   check_unit8.py 04 --runlog: PASS
```

Each: all six captures `= published`, `offline: yes` (one build, `Downloaded from` 0), volumes 315 → 315, images 6 unchanged, the
anchor's pin equal at start and end, nothing listening on 20430-20439 at the end. Two development passes before them produced the
hashes (the second identical to the first but for `unchecked`, whose heading line was reworded between them). The pushed commit is
that local commit amended with this README's runs, interrupts and plants (the script and every capture unchanged — `md5 -q
receipts.sh` above). One more pass of `./receipts.sh` on this README before the push (its plants block filled): exit 0, 209 s, every capture `= published`, `check_unit8.py 04 --runlog` PASS.

## Interrupted

SIGINT (`kill -INT` on the receipt's own pid, started with SIGINT at its default, as a terminal's Ctrl-C reaches it) at three points —
mid-build (the offline Maven build of anchor/'s copy), mid-container (after `docker run`, while `pg_isready` waited, before any harness
JVM), mid-harness (a `probe.u04.U4` JVM running, the container up). After each: the exit, the container, the volume count, the
listeners on 20430-20439, our JVMs and Maven, partial `.r-*.[123]` files, `.r-lock`, and the published captures' md5s.

```
SIGINT mid-build      exit 130 · container 0 · volumes 315 · listeners 20430-20439 0 · our JVMs/Maven 0 · partial .r-*.[123] 0 · .r-lock gone · captures (= published): = = = = = =
SIGINT mid-container  exit 130 · container 0 · volumes 315 · listeners 20430-20439 0 · our JVMs/Maven 0 · partial .r-*.[123] 0 · .r-lock gone · captures (= published): = = = = = =
SIGINT mid-harness    exit 130 · container 0 · volumes 315 · listeners 20430-20439 0 · our JVMs/Maven 0 · partial .r-*.[123] 0 · .r-lock gone · captures (= published): = = = = = =
```

The receipt was started through `perl -e '$SIG{INT} = "DEFAULT"; exec @ARGV'` from a script run in the foreground (a background job
of a non-interactive shell starts with SIGINT ignored). A first mid-harness attempt fired during `javac` instead (its trigger's
pattern `probe.u04.U4` matched the path `probe/u04/*.java`): exit 130, the same clean state; the trigger was narrowed to a `java`
process running `probe.u04.U4` and the point was run again — the line above is that second run. No pass ran to its end by accident.

## Planted faults — each caught (R.65, R.226)

On a scratch mirror (this folder copied, its siblings `c8-unit02`, `c8-tiffinbox`, `c5-unit11`, `c7-unit31`, `c2-unit35` linked
read-only), one plant at a time, the folder restored after each. "Nothing written" = the md5 of every tracked file in the mirror's
folder (and, for the gate plants, its whole listing but `.m2-demo`) before and after the planted run. The brief's 04/05 list first —
the refused claim that the driver receives `:name` (plants 1 and 2: the prose gate and the witness's text) and `optional()` swapped for `single()` in
SOLUTION.md (plant 20: the exercise check) — then the carried set. Plants 1 and 3-15 stop `./receipts.sh` in its gates, before any
write; plants 2 and 16-19 run `harness/chk04.py` on a doctored copy of a capture (plant 2's run also fails "no :name at the driver",
"one text at the driver" and "the same text on H2"); plants 20-22 need the captures, so the mirror's receipt ran its six captures and
stopped at the check after them, exit 1, nothing in the mirror's README, exercise or script changed (its `.harness/` and `.r-*` files
are a run's own and are not counted). A first pass of plant 21 planted nothing (its insertion point was not in this README; exit 0,
recorded, not counted); the line above is the corrected plant.

```
plant  1 `:name` shown at the driver, in README.md (the hazard)         exit 1 · nothing written: yes · a refused word or reading in this unit's prose:   README.md line 309: the hazard: `:name` shown at the driver - the witness's text is `?`
plant  2 `:name` at the driver in the witness text (a doctored client)  exit 1 · FAIL PostgreSQL 18.6, client named: JdbcTemplate's DEBUG text = the text the driver received (the witness)
plant  3 "faster" (dur8)                                                exit 1 · nothing written: yes · a refused word or reading in this unit's prose:   README.md line 309: dur8: faster
plant  4 a wrong hash (the anchor tree pin)                             exit 1 · nothing written: yes · R.211: anchor/'s tree is 51 7ce49e3ec13c212a31ee6ba4618f53ab, the pin in receipts.md5 is 51 00000000000000000000000000000000 - the tree moved
plant  5 a placeholder in the exercise                                  exit 1 · nothing written: yes · a placeholder in this unit's prose: exercise/README.md:36: (the planted to-do line)
plant  6 a dish name                                                    exit 1 · nothing written: yes · an Indian dish name (R.215: English names only): README.md (the planted line)
plant  7 a typed count (R.302)                                          exit 1 · nothing written: yes · a refused word or reading in this unit's prose:   README.md line 309: R.302: a capture's number typed in prose: 40
plant  8 the exercise solution = broken (R.196)                         exit 1 · nothing written: yes · R.196: SOLUTION.md's block must be the README's with one line changed (it is 0 lines apart)
plant  9 the container removed without -v (R.322)                       exit 1 · nothing written: yes · R.322: receipts.sh removes a container without its volume (rm -fv)
plant 10 the docker CLI unpinned, DOCKER_HOST=tcp://127.0.0.1:1 (R.344) exit 1 · nothing written: yes · R.344: dk() must name the pinned socket (docker -H "$DH")
plant 11 the anchor link pointed at c8-tiffinbox (readlink)             exit 1 · nothing written: yes · anchor must be a link to ../c8-unit02/after (it points at: ../c8-tiffinbox)
plant 12 a Course 2 title not byte-equal to java2_series.py             exit 1 · nothing written: yes · R.224: README.md calls Course 2's unit back by its title: TiffinBox on a Real Database: The JDBC Repository
plant 13 "validated" said of the record (RE-MEASURE 10)                 exit 1 · nothing written: yes · a refused word or reading in this unit's prose:   README.md line 309: RE-MEASURE 10: the record query(Customer.class) builds is never checked
plant 14 "N times" (R.309)                                              exit 1 · nothing written: yes · a refused word or reading in this unit's prose:   README.md line 309: R.309: "N times": four times
plant 15 the witness changed beyond its package line (R.357)            exit 1 · nothing written: yes · R.357: harness/src/probe/u04/Witness.java must be unit 02's witness with its package line alone changed
plant 16 no HHH000001 in the JVMs (a doctored custom)                   exit 1 · FAIL custom: HHH000001 in every JVM's log
plant 17 a version line missing in one JVM (a doctored missing)         exit 1 · FAIL missing: a version line in every JVM that started (4 of 5)
plant 18 a too-many count not the data line (a doctored missing)        exit 1 · FAIL PostgreSQL 18.6: single() on every name = 1 prepare, actual = the data line's 40 customers (['org.springframework.dao.IncorrectResultSizeDataAcce
plant 19 the unchecked value not psql (a doctored unchecked)            exit 1 · FAIL mealsPerDay() = psql's and JdbcTemplate's meals_per_day (1)
plant 20 optional() swapped for single() in SOLUTION.md (the exercise check) exit 1 · nothing written: yes · exercise: its check failed (harness/chk04.py)
plant 21 a typed SQL line in a README text block (R.302)                exit 1 · nothing written: yes · R.302: README.md's text blocks must be lines the runs printed - not printed: select c.name, sum(p.days) from customer c join pause p group by c.name
plant 22 a changed What-it-prints line (exercise/SOLUTION.md)           exit 1 · nothing written: yes · exercise/SOLUTION.md's "What it prints" block is not what its lines printed: 4c4 < EX lookup Nobody: Optional[none] ---
plants: 22 · caught: 22
```

## For RED

- **`:name` is the hazard:** the witness keeps the string handed to `prepareStatement`; every form on both databases shows `?`. A
  slide that shows `:name` reaching the driver is false; the `:name` lives in the Java string only.
- **The rows** are not counted by the witness (What differed). If the script says "one row", it is the `single()` contract plus the
  record equal to psql's row.
- **`unchecked` is PostgreSQL only and a copy row in its own schema;** the `Validator` call is the harness's, after the read.
- **`custom`'s rows include Meera with `0`** — the left join; the same question through the repositories is unit 06's run, not a
  number here.
- **Course 6's title is dropped** for want of a unit that says the rule; check the grep if the script names one.
- **Not measured here:** `NamedParameterJdbcTemplate` (unit 05), the two templates' beans (unit 05), H2 for RE-MEASURE 10, a route over
  HTTP, rows by a `ResultSet` counter.
