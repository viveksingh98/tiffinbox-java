# c8-unit05 — JdbcTemplate and NamedParameterJdbcTemplate

Course 8, Section 1 (Spring Data JDBC), unit 05 — **a harness unit: no anchor change.** It measures the two classes older Spring
codebases are full of, `JdbcTemplate` and `NamedParameterJdbcTemplate`, beside the `JdbcClient` of *JdbcClient and Custom Queries*
(Course 8 unit 04) — on PostgreSQL 18.6 in a container (the hook's store) AND on H2 in memory, the anchor's default: each template's
calls and the text the driver received for each, the same query four ways, how the context's beans of the three APIs are wired to
each other (read off the running context, RE-MEASURE 11), what a missing row and too many rows throw, and what two positional
arguments in the wrong order do (RE-MEASURE 12).

- `anchor` → `../c8-unit02/after` (a link; both Spring Data modules, `JdbcNames`'s Q imported; `../c8-tiffinbox` equals it today,
  `diff -rq` empty, printed by every run). `harness/tree05.py` pins its tree: the file count and the md5 in `receipts.md5`'s
  `anchor-tree` line, written from a run's own output (the same pin units 01, 03 and 04 filed: the anchor has not moved).
- Nothing in the anchor is edited. The tree is copied under `.harness/` and built there, offline, from `.m2-demo` (a copy of the
  course's seed `spring-data-beyond-jpa/_research/m2-seed-c8-s1/`). The exercise's broken program is `exercise/Ex05.java` as shipped;
  its solution is derived by the one `sed` line in `exercise/SOLUTION.md`, and every run prints that line; neither is committed as a tree.

Run it: `./receipts.sh` from this folder (JDK 25, Maven, OrbStack's docker socket, the postgres image by its digest already on the
machine — the script never pulls). Every number below is a line a run printed; the values block is assembled from `harness/chk05.py`'s
output and compared with this file byte for byte.

## The captures — what each one shows

Seven captures, each run 3/3 and hashed (`receipts.md5`); each is read back by `harness/chk05.py` against a second witness of the
same run before its hash is compared. Every statement count is the witness's — datasource-proxy 1.11.1 on the `DataSource` bean,
unit 02's class with its package line alone changed — per labelled window (R.357, R.367); `JdbcTemplate`'s DEBUG log of the same
window is the second count (its bracketed `Executing prepared SQL statement` and `Executing SQL query` lines, asserted equal) and its
bracketed SQL is asserted equal to the text the witness kept. The text the driver received is the witness's: the string handed to
`Connection.prepareStatement`. On PostgreSQL the rows are read back by psql in the container; on H2 in memory by a `JdbcTemplate` of
the harness's own in the same JVM. Each sequence but `beans` builds the data line first (the seed step: V2's rows, then customers by
`JdbcTemplate` with one 2-day pause each — RE-MEASURE 4), on a fresh database per PostgreSQL sequence, and psql reads Meera's row
before the calls, so every record's text is derived from the row, never typed. Every call under test goes through the context's own
beans (`ctx.getBean(JdbcTemplate.class)`, `NamedParameterJdbcTemplate.class`, `JdbcClient.class`); every JVM prints how many of each
the context holds.

### 1 · template — `JdbcTemplate`'s three calls (PostgreSQL 18.6; the same on H2)

Three windows, one call each, through the context's `JdbcTemplate`: `queryForObject(sql, rowMapper, "Meera")` with `?` and a lambda
`RowMapper` (`(rs, i) -> new Customer(rs.getString("name"), rs.getInt("meals_per_day"), rs.getInt("price_per_meal"), rs.getString("meal_type"))`);
`query(sql, rowMapper, "VEG")` — a list, its size asserted equal to psql's count of the VEG customers; `update(…)` on the harness's
own row. That row, Asha, is never one of the seeded customers: on PostgreSQL psql writes it before the harness JVM, reads it before
and after, and deletes it after (0 left); on H2 the harness's own `JdbcTemplate` writes and deletes it outside every window. chk05
asserts the rows affected equal the one row the second client reads back with the new value.

```text
psql, Asha's row before the harness (a second client, PostgreSQL): Asha · 2 · 120 · VEGAN
psql, the VEG customers (a second client, PostgreSQL): 38
PROBE template queryForObject (JdbcTemplate, ?, a lambda RowMapper, "Meera", PostgreSQL 18.6): the witness 1 · SELECT 1
PROBE template queryForObject: Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, mealType=NON_VEG]
PROBE template query (JdbcTemplate, ?, a lambda RowMapper, "VEG", PostgreSQL 18.6): the witness 1 · SELECT 1
PROBE template query: a list, size 38
PROBE template update (JdbcTemplate, update customer set meals_per_day = ? where name = ?, 3, "Asha", PostgreSQL 18.6): the witness 1 · SELECT 0
PROBE template update: 1
psql, Asha's row after the harness (a second client, PostgreSQL): Asha · 3 · 120 · VEGAN
psql, Asha's rows after the delete (a second client, PostgreSQL): 0
PROBE asha: inserted by the harness's JdbcTemplate (H2 2.5.250), outside any window: 1 row · Asha · 2 · 120 · VEGAN
PROBE ashadrop: deleted by the harness's JdbcTemplate (H2 2.5.250), outside any window: 1 row · Asha's row now: (no row)
```

### 2 · named — `NamedParameterJdbcTemplate`, `:name` and the rewrite (PostgreSQL 18.6; the same on H2)

Two windows through the context's `NamedParameterJdbcTemplate`: `queryForObject(sql, Map.of("name", "Meera"), new DataClassRowMapper<>(Customer.class))`
with `… where name = :name`, then the same with `new MapSqlParameterSource("name", "Meera")`. The SQL string holds `:name`; the text
the driver received is `… where name = ?` (the witness) — the `:name` is rewritten before the driver, on both databases.
`DataClassRowMapper` fills the record's constructor from `meals_per_day` and the other columns; the record equals psql's row.

```text
PROBE named Map (NamedParameterJdbcTemplate, :name, Map.of("name", "Meera"), new DataClassRowMapper<>(Customer.class), PostgreSQL 18.6): the witness 1 · SELECT 1
PROBE named Map (NamedParameterJdbcTemplate, :name, Map.of("name", "Meera"), new DataClassRowMapper<>(Customer.class), PostgreSQL 18.6) SQL x1: select name, meals_per_day, price_per_meal, meal_type from customer where name = ?
PROBE named Map: Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, mealType=NON_VEG]
PROBE named MapSqlParameterSource (NamedParameterJdbcTemplate, :name, new MapSqlParameterSource("name", "Meera"), new DataClassRowMapper<>(Customer.class), PostgreSQL 18.6): the witness 1 · SELECT 1
PROBE named: the two records equal (equals): true
```

### 3 · four — the hook: the same query four ways, one text at the driver (PostgreSQL 18.6; the counts repeated on H2)

Four windows, one call each: `JdbcTemplate.queryForObject` with `?` and the lambda `RowMapper`; `NamedParameterJdbcTemplate.queryForObject`
with `:name`, `Map.of` and `DataClassRowMapper`; `JdbcClient` with `:name` and `query(Customer.class).single()`; `JdbcClient` with `?`,
`.param("Meera")` and the lambda `RowMapper`. chk05 asserts each window's count, each record equal to psql's row, `all four equal:
true` (the harness's `equals` over the four records), and one text at the driver across the four windows — the positional SQL
string, byte for byte (R.309, RED #13: four calls, one text; never a count of times).

```text
psql, Meera's row (a second client, PostgreSQL): Meera · 1 · 150 · NON_VEG
PROBE four JdbcTemplate (JdbcTemplate.queryForObject, ?, a lambda RowMapper, PostgreSQL 18.6): the witness 1 · SELECT 1
PROBE four JdbcTemplate (JdbcTemplate.queryForObject, ?, a lambda RowMapper, PostgreSQL 18.6) SQL x1: select name, meals_per_day, price_per_meal, meal_type from customer where name = ?
PROBE four NamedParameterJdbcTemplate (NamedParameterJdbcTemplate.queryForObject, :name, Map.of, new DataClassRowMapper<>(Customer.class), PostgreSQL 18.6) SQL x1: select name, meals_per_day, price_per_meal, meal_type from customer where name = ?
PROBE four JdbcClient named (JdbcClient, :name, .param("name", "Meera"), query(Customer.class).single(), PostgreSQL 18.6) SQL x1: select name, meals_per_day, price_per_meal, meal_type from customer where name = ?
PROBE four JdbcClient positional (JdbcClient, ?, .param("Meera"), query(a lambda RowMapper).single(), PostgreSQL 18.6) SQL x1: select name, meals_per_day, price_per_meal, meal_type from customer where name = ?
PROBE four: all four equal: true · 4 records
PROBE four: the texts the driver received, across the four windows: 4 · distinct 1
```

The four ways, as the capture has them (each cell a line of `four`; the same on H2 2.5.250, chk05 asserts it):

| the API (PostgreSQL 18.6) | the placeholder in the SQL string | prepares (the witness) | the text the driver received | the record | equal |
|---|---|---|---|---|---|
| `JdbcTemplate.queryForObject` · lambda `RowMapper` | `?` | the window's count | `… where name = ?` | Meera's | yes |
| `NamedParameterJdbcTemplate.queryForObject` · `DataClassRowMapper` | `:name` | the window's count | `… where name = ?` | Meera's | yes |
| `JdbcClient` · `query(Customer.class).single()` | `:name` | the window's count | `… where name = ?` | Meera's | yes |
| `JdbcClient` · `.param("Meera")` · lambda `RowMapper` | `?` | the window's count | `… where name = ?` | Meera's | yes |

The rows: `queryForObject` and `single()` return exactly one record or throw (capture `missing` shows the throws), so each call's one
record is its one row, and the record is asserted equal to psql's row; the witness counts statements, not rows (unit 02's class,
unchanged) — the same wording unit 04's README uses.

### 4 · beans — RE-MEASURE 11 and RED #11: the beans and what holds what, off the running context (PostgreSQL 18.6 and H2)

One JVM per database, no statement counted (the step reads the context only, so no data line is built). For each of `JdbcTemplate`,
`NamedParameterJdbcTemplate`, `JdbcClient` and `DataSource`: every bean of that type the context holds (`getBeanNamesForType`), its
name, its class and the bean factory's dependency list for it (`getDependenciesForBean`); then, by reflection and by object identity
(`==`), what each one holds: `JdbcClient`'s one field `namedParamOps` (`DefaultJdbcClient` has no other operations field — `javap -p`
on spring-jdbc 7.0.10), the named template's `getJdbcOperations()`, the template's `getDataSource()`, and the object inside the
witness's `ProxyDataSource` (its `getDataSource()`). chk05 asserts each count equal to the bean lines listed, the classes equal, reflection and the dependency
lists agreeing on every link, and the lines identical on both databases.

```text
PROBE beans: JdbcTemplate bean 'jdbcTemplate' (PostgreSQL 18.6): org.springframework.jdbc.core.JdbcTemplate · the bean factory's dependency list: [dataSource, dataSourceScriptDatabaseInitializer, flyway, flywayInitializer, org.springframework.boot.jdbc.autoconfigure.JdbcTemplateConfiguration, spring.jdbc-org.springframework.boot.jdbc.autoconfigure.JdbcProperties]
PROBE beans: NamedParameterJdbcTemplate bean 'namedParameterJdbcTemplate' (PostgreSQL 18.6): org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate · the bean factory's dependency list: [dataSourceScriptDatabaseInitializer, flyway, flywayInitializer, jdbcTemplate, org.springframework.boot.jdbc.autoconfigure.NamedParameterJdbcTemplateConfiguration]
PROBE beans: JdbcClient bean 'jdbcClient' (PostgreSQL 18.6): org.springframework.jdbc.core.simple.DefaultJdbcClient · the bean factory's dependency list: [dataSourceScriptDatabaseInitializer, flyway, flywayInitializer, namedParameterJdbcTemplate, org.springframework.boot.jdbc.autoconfigure.JdbcClientAutoConfiguration]
PROBE beans: DataSource bean 'dataSource' (PostgreSQL 18.6): net.ttddyy.dsproxy.support.ProxyDataSource · the bean factory's dependency list: [environment, jdbcConnectionDetails, org.springframework.boot.jdbc.autoconfigure.DataSourceConfiguration$Hikari, spring.datasource-org.springframework.boot.jdbc.autoconfigure.DataSourceProperties]
PROBE beans: the JdbcClient's field namedParamOps (reflection, PostgreSQL 18.6): org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate · the same object as the NamedParameterJdbcTemplate bean: true
PROBE beans: the NamedParameterJdbcTemplate's getJdbcOperations() (PostgreSQL 18.6): org.springframework.jdbc.core.JdbcTemplate · the same object as the JdbcTemplate bean: true
PROBE beans: the JdbcTemplate's getDataSource() (PostgreSQL 18.6): net.ttddyy.dsproxy.support.ProxyDataSource · the same object as the DataSource bean: true
PROBE beans: the DataSource bean wraps (the witness's ProxyDataSource.getDataSource(), PostgreSQL 18.6): com.zaxxer.hikari.HikariDataSource
PROBE beans: the beans that depend on 'namedParameterJdbcTemplate' (the bean factory's list, PostgreSQL 18.6): [dataAccessStrategyBean, idGeneratingBeforeSaveCallback, jdbcClient, jdbcConverter, jdbcDialect]
PROBE beans of JdbcTemplate (PostgreSQL 18.6): 1 · org.springframework.jdbc.core.JdbcTemplate
PROBE beans of NamedParameterJdbcTemplate (PostgreSQL 18.6): 1 · org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate
PROBE beans of JdbcClient (PostgreSQL 18.6): 1 · org.springframework.jdbc.core.simple.DefaultJdbcClient
PROBE beans of DataSource (PostgreSQL 18.6): 1 · net.ttddyy.dsproxy.support.ProxyDataSource
```

What the `beans` capture shows, as a chain of objects: the context's `JdbcClient` holds the context's `NamedParameterJdbcTemplate`
bean (its field is that very object, and its dependency list names it), which holds the context's `JdbcTemplate` bean (the same
object), which holds the `DataSource` bean (the same object). So "`JdbcClient` sits on the named template" is what the `beans` capture
shows, read off the run, on both databases. The `DataSource` bean's class, in the `beans` capture, is the witness's `ProxyDataSource` around
Hikari's pool: the harness puts it there with a `BeanPostProcessor` (the `beans` capture names both classes). Spring Data
JDBC's own beans (`dataAccessStrategyBean`, `jdbcConverter`, `jdbcDialect`, `idGeneratingBeforeSaveCallback`) depend on the named
template too (the `beans` capture's dependents line).

### 5 · missing — the failure receipt: no row, too many rows, the positional mix-up (both databases)

One JVM per database, one window per call, each exception caught by the harness and printed (class and message; a message's line
breaks shown as ` / `). "Nobody" through `JdbcTemplate.queryForObject`, `NamedParameterJdbcTemplate.queryForObject` and
`JdbcClient…single()`, each in its own window (unit 04's `missing` capture holds the `JdbcClient` side already; this receipt
re-measures it beside the two templates); then `queryForObject("select name from customer", String.class)` — no argument, so
`JdbcTemplate` uses a plain `Statement`: the witness keeps `(createStatement)` (no SQL text is handed to the connection) and the DEBUG
log says `Executing SQL query [select name from customer]`; the "actual" in its text is asserted equal to the data line's customers.
Then RE-MEASURE 12, the positional mix-up, two ways: two strings swapped (`… where meal_type = ? and name = ?` given `"Meera", "NON_VEG"`)
and a number and a string swapped (`… where name = ? and meals_per_day = ?` given `1, "Meera"`), each followed by its named form with
the same two values.

```text
PROBE missing JdbcTemplate threw: org.springframework.dao.EmptyResultDataAccessException: Incorrect result size: expected 1, actual 0
PROBE missing NamedParameterJdbcTemplate threw: org.springframework.dao.EmptyResultDataAccessException: Incorrect result size: expected 1, actual 0
PROBE missing JdbcClient threw: org.springframework.dao.EmptyResultDataAccessException: Incorrect result size: expected 1, actual 0
PROBE missing many (JdbcTemplate.queryForObject, select name from customer, String.class, PostgreSQL 18.6): the witness 1 · SELECT 0
PROBE missing many (JdbcTemplate.queryForObject, select name from customer, String.class, PostgreSQL 18.6) SQL x1: (createStatement)
log missing many x1: Executing SQL query [select name from customer]
PROBE missing many threw: org.springframework.dao.IncorrectResultSizeDataAccessException: Incorrect result size: expected 1, actual 40
PROBE mixup: the right order for `select name, meals_per_day, price_per_meal, meal_type from customer where meal_type = ? and name = ?` is meal_type, then name; the call passes "Meera", "NON_VEG"
PROBE mixup swapped (JdbcTemplate.queryForObject, meal_type = ? and name = ?, "Meera", "NON_VEG", PostgreSQL 18.6): the witness 1 · SELECT 1
PROBE mixup swapped threw: org.springframework.dao.EmptyResultDataAccessException: Incorrect result size: expected 1, actual 0
PROBE mixup named: Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, mealType=NON_VEG]
PROBE mixup: the right order for `select name, meals_per_day, price_per_meal, meal_type from customer where name = ? and meals_per_day = ?` is name, then meals_per_day; the call passes 1, "Meera"
PROBE mixup types swapped threw: org.springframework.jdbc.BadSqlGrammarException: PreparedStatementCallback; bad SQL grammar [select name, meals_per_day, price_per_meal, meal_type from customer where name = ? and meals_per_day = ?]
PROBE mixup types swapped its cause: org.postgresql.util.PSQLException: ERROR: operator does not exist: character varying = integer / Hint: No operator matches the given name and argument types. You might need to add explicit type casts. / Position: 80
PROBE mixup types swapped (JdbcTemplate.queryForObject, name = ? and meals_per_day = ?, 1, "Meera", H2 2.5.250): the witness 1 · SELECT 1
PROBE mixup types swapped its cause: org.h2.jdbc.JdbcSQLDataException: Data conversion error converting "CHARACTER VARYING to DECFLOAT"; SQL statement: / select name, meals_per_day, price_per_meal, meal_type from customer where name = ? and meals_per_day = ? [22018-250]
PROBE mixup types named: Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, mealType=NON_VEG]
```

What the mix-up shows: two values of the same type swapped are silent — the statement is valid, it asks for a customer named
`NON_VEG` who eats `Meera`, and the answer is no row: the same `EmptyResultDataAccessException` text as a missing customer, on
PostgreSQL 18.6 and on H2 2.5.250 alike (chk05 asserts it). A number and a string swapped are refused by the database, and each
database says it its own way — PostgreSQL 18.6 through `BadSqlGrammarException` (`operator does not exist: character varying =
integer`), H2 2.5.250 through `DataIntegrityViolationException` (`Data conversion error`); the full texts are in the values block.
The named forms with the same two values return Meera's row on both databases, and the driver receives the same text as the swapped
call (the witness: the names are rewritten to `?` before it) — the fix is in how values meet placeholders, not in the statement.

### 6 · seven — the comparison set, unchanged (RE-MEASURE 16)

`anchor/`'s jar, `java -jar` on H2 in memory, port 20440 (loopback), the seven requests of `../c5-unit11/curlset.sh` (the shutdown
token on its standard input, never on a command line), TiffinBox stopped by its own `POST /shutdown`. The md5 is compared with the
`S466` line of `../c7-unit31/receipts.sh`.

```text
GET /actuator/health/readiness -> 200 · listens on: 127.0.0.1:20440
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20440 now: 0
```

### 7 · exercise — run as written, in one shell, bash then zsh (R.196)

`exercise/README.md`'s lines, then `exercise/SOLUTION.md`'s, in ONE `env -i` shell — `/bin/bash --noprofile --norc`, then `/bin/zsh -f`;
each file's "What it prints" block is compared with what its lines printed, line for line. H2 in memory, no Docker, no Maven, no
port (20442-20449 are never bound): the block compiles `exercise/Ex05.java` against the jar this receipt built. The broken program
looks Meera up through the context's `JdbcTemplate` with her two values in the wrong order and exits 1; the solution's one changed
line makes it the context's `NamedParameterJdbcTemplate` with a map — the values still written name first — and the program exits 0.
chk05 asserts the broken program's text equal to capture `missing`'s `mixup swapped` line — the same text on H2 and on PostgreSQL,
so the exercise's README states the one text — and the solved record equal to capture `four`'s.

```text
$ sed 's/jdbc.queryForObject(BY_TYPE_AND_NAME, BY_HAND, "Meera", "NON_VEG")/named.queryForObject(BY_TYPE_AND_NAME_NAMED, Map.of("name", "Meera", "mealType", "NON_VEG"), BY_HAND)/' exercise/Ex05.java > .harness/ex/src/probe/ex/Ex05.java
EX lookup Meera threw: org.springframework.dao.EmptyResultDataAccessException: Incorrect result size: expected 1, actual 0
EX lookup Meera: Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, mealType=NON_VEG]
```

## The values the video may say

Assembled from chk05.py's `VALUES` lines; `receipts.sh` refuses this file unless the line below is byte-equal to what the run assembled.

<!-- values: begin -->
the values the video may say - template: PostgreSQL 18.6: the context's JdbcTemplate - queryForObject(sql, rowMapper, "Meera") with ? -> Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, mealType=NON_VEG] (psql's row: Meera · 1 · 150 · NON_VEG), 1 prepare; query(sql, rowMapper, "VEG") -> a list, size 38 (= psql's count of VEG customers), 1 prepare; update("update customer set meals_per_day = ? where name = ?", 3, "Asha") on the harness's own row -> 1 row affected (Asha by psql: Asha · 2 · 120 · VEGAN -> Asha · 3 · 120 · VEGAN; deleted after), 1 prepare; H2 2.5.250: the same; versions: Spring Boot 4.1.2 · Spring Framework 7.0.10 · Spring Data JDBC 4.1.2 · Hibernate 7.4.13.Final · datasource-proxy 1.11.1 · named: PostgreSQL 18.6: the context's NamedParameterJdbcTemplate - queryForObject("... where name = :name", Map.of("name", "Meera"), new DataClassRowMapper<>(Customer.class)) -> Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, mealType=NON_VEG], 1 prepare, the driver received `select name, meals_per_day, price_per_meal, meal_type from customer where name = ?` (the witness: the :name rewritten to ?); the same with new MapSqlParameterSource("name", "Meera"): 1 prepare, the same text, equal; H2 2.5.250: the same · four: PostgreSQL 18.6 (the hook): the same query four ways - JdbcTemplate (?), NamedParameterJdbcTemplate (:name), JdbcClient (:name), JdbcClient (?) - four calls, 1 prepare each, one text at the driver: `select name, meals_per_day, price_per_meal, meal_type from customer where name = ?` (the witness, four windows); the records = psql's row Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, mealType=NON_VEG]; all four equal: true; H2 2.5.250: the same counts, the same text, all four equal: true · beans: RE-MEASURE 11, read off the running context, PostgreSQL 18.6 and H2 2.5.250 the same - beans of JdbcTemplate: 1 · org.springframework.jdbc.core.JdbcTemplate · beans of NamedParameterJdbcTemplate: 1 · org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate · beans of JdbcClient: 1 · org.springframework.jdbc.core.simple.DefaultJdbcClient · beans of DataSource: 1 · net.ttddyy.dsproxy.support.ProxyDataSource; what JdbcClient is built on: JdbcClient (org.springframework.jdbc.core.simple.DefaultJdbcClient) holds the context's NamedParameterJdbcTemplate bean (its field namedParamOps, by reflection: the same object; its dependency list names it), which holds the context's JdbcTemplate bean (getJdbcOperations(): the same object), which holds the DataSource bean (getDataSource(): the same object; the witness's net.ttddyy.dsproxy.support.ProxyDataSource around com.zaxxer.hikari.HikariDataSource); the beans that depend on the named template: [dataAccessStrategyBean, idGeneratingBeforeSaveCallback, jdbcClient, jdbcConverter, jdbcDialect] · missing: "Nobody" through JdbcTemplate.queryForObject, NamedParameterJdbcTemplate.queryForObject and JdbcClient...single() -> org.springframework.dao.EmptyResultDataAccessException: Incorrect result size: expected 1, actual 0 (the same text, three APIs, each in its own window; PostgreSQL 18.6 and H2 2.5.250 the same); queryForObject("select name from customer", String.class) -> org.springframework.dao.IncorrectResultSizeDataAccessException: Incorrect result size: expected 1, actual 40 (one plain Statement, no argument); the positional mix-up, two strings swapped (meal_type = ? and name = ? given "Meera", "NON_VEG") -> org.springframework.dao.EmptyResultDataAccessException: Incorrect result size: expected 1, actual 0 (no row, both databases), the named form with the same two values -> Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, mealType=NON_VEG]; a number and a string swapped (name = ? and meals_per_day = ? given 1, "Meera") -> PostgreSQL 18.6: org.springframework.jdbc.BadSqlGrammarException: PreparedStatementCallback; bad SQL grammar [select name, meals_per_day, price_per_meal, meal_type from customer where name = ? and meals_per_day = ?], its cause org.postgresql.util.PSQLException: ERROR: operator does not exist: character varying = integer / Hint: No operator matches the given name and argument types. You might need to add explicit type casts. / Position: 80; H2 2.5.250: org.springframework.dao.DataIntegrityViolationException: PreparedStatementCallback; SQL [select name, meals_per_day, price_per_meal, meal_type from customer where name = ? and meals_per_day = ?]; Data conversion error converting "CHARACTER VARYING to DECFLOAT"; SQL statement: / select name, meals_per_day, price_per_meal, meal_type from customer where name = ? and meals_per_day = ? [22018-250]; its named form -> Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, mealType=NON_VEG] · seven: the seven on anchor/ (H2): 466c20ed…, unchanged · exercise: the exercise (21 words, H2 in memory, no Docker): broken - JdbcTemplate.queryForObject("... where meal_type = ? and name = ?", rowMapper, "Meera", "NON_VEG") -> org.springframework.dao.EmptyResultDataAccessException: Incorrect result size: expected 1, actual 0, exit 1; solved - NamedParameterJdbcTemplate.queryForObject("... where meal_type = :mealType and name = :name", Map.of("name", "Meera", "mealType", "NON_VEG"), rowMapper) -> Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, mealType=NON_VEG], exit 0
<!-- values: end -->

The hook, with its database: on PostgreSQL 18.6, the same query four ways — `JdbcTemplate` (`?`), `NamedParameterJdbcTemplate`
(`:name`), `JdbcClient` (`:name`), `JdbcClient` (`?`) — four calls, one text at the driver, the `:name` rewritten to `?` before it:
`select name, meals_per_day, price_per_meal, meal_type from customer where name = ?` (the witness; the same on H2 2.5.250), and
`all four equal: true`.

## Refused, named

- **`:name` at the driver, or a sentence that puts the parameter names in the database:** refused by `s805.py`; the witness's text is `… where name = ?`
  for every call on both databases. The names live in the Java string and the map only.
- **A bean count, or "sits on" / "wraps" / "delegates to", without the `beans` capture (RED #11, RE-MEASURE 11):** refused by `s805.py`
  unless the sentence names the `beans` capture; the counts and the chain are its lines, never the documentation's.
- **The word `legacy` (R.261):** refused; the brief's "older Spring codebases" is the phrase, and no adjective is said about the
  templates themselves.
- **A pair of counts from two windows (R.367):** each call is its own window; the hook's four windows are four calls of one operation,
  compared by their counts and their one text.
- **"N times" (R.309):** "four calls, one text at the driver", never a count of times.
- **`faster`, `lighter`, `simpler` (R.355, R.366):** refused without a count beside them; dur8 words: 0.
- **A page fetched over HTTP:** only the seven (port 20440); every count is the harness's direct call.

## Call-backs, by title (R.224)

- Course 8's *JdbcClient and Custom Queries* (unit 04): `JdbcClient`'s side of the four ways and the missing-row texts are its
  `client` and `missing` captures; this unit re-measures its own windows and cites none of unit 04's numbers. The title as
  `~/Desktop/PromptVidya-Automation/java8_series.py` holds it: `69: "04": "JdbcClient and Custom Queries",` (`/usr/bin/grep -n`,
  2026-11-17), and this unit's own title on the next line, `70: "05": "JdbcTemplate and NamedParameterJdbcTemplate",`.
- Course 2's *JDBC: Connect, Query, Map Rows to Records* (unit `35`) and *TiffinBox on a Real Database: The JDBC Repository* (unit `38`),
  the two JDBC units unit 04 called back, re-read today with unit 04's grep of `java2_series.py`:
  `80: "35": "JDBC: Connect, Query, Map Rows to Records",` and `83: "38": "TiffinBox on a Real Database: The JDBC Repository",` —
  byte-equal to the brief. The receipt checks the three titles are in this file. No Course 2 code is shown or run here.
- No Course 6 unit is cited (unit 04 found none that holds its "never checked" sentence; this unit needs none).

## The commands this unit adds

- The harness: `javac -parameters -d .harness/hc -cp "<anchor's jar>:<its lib/*>:$DSP" harness/src/probe/u05/*.java`, then
  `java -cp "../hc:../after/<jar>:../after/<lib/*>:$DSP" probe.u05.U5 <steps>` from `.harness/run`, with
  `--logging.config=../../harness/logback.xml` (JdbcTemplate at DEBUG) and, on PostgreSQL,
  `--tiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:20441/<db>?user=tiffinbox`. Steps: `seed`, `asha`, `template`, `ashadrop`, `named`,
  `four`, `beans`, `missing`. `$DSP` is datasource-proxy 1.11.1 in `.m2-demo` — on the harness's class path only; no harness POM (unit 02's form).
- The container: `docker -H "$DH" run -d --pull never --name c8u05-pg -p 127.0.0.1:20441:5432 -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust postgres@sha256:77f58511…`
  — trust on loopback, as units 01, 03 and 04 did; no password anywhere. Removed with `docker -H "$DH" rm -fv`.
- The PostgreSQL driver is the anchor jar's own (`postgresql-42.7.14.jar` in its `lib/`); the harness adds none.

## The repository, and the network

`.m2-demo` is a copy of `spring-data-beyond-jpa/_research/m2-seed-c8-s1/` (6,966 files, `cp -c -R`). Every Maven run is `mvn -o` with
`-Dmaven.repo.local=.m2-demo`; each log is checked for `Downloading from` / `Downloaded from` lines (none, else the run stops). No image
pull, no metadata read, no `git fetch`: `origin/main...main` was read from the local tracking ref. The one network act is the final
`git push`.

## The folders, the harness and the ports

- `harness/src/probe/u05/U5.java` (the steps), `Witness.java` (unit 02's witness, its package line alone changed — the receipt diffs
  it); `harness/chk05.py` (the checks), `harness/s805.py` (the prose gate, its own self-test), `harness/dur8.py` (the builders', as unit
  02 shipped it, `cmp`-checked), `harness/tree05.py` (unit 04's tree04.py method), `harness/logback.xml` (unit 04's, JdbcTemplate's
  logger at DEBUG; only its comment names unit 05).
- `exercise/Ex05.java`, `exercise/README.md`, `exercise/SOLUTION.md`; `receipts.sh`, `receipts.md5`.
- Ports, 20440-20449: **20440** TiffinBox for the seven only · **20441** the container · **20442-20449** spare, never bound (the
  exercise runs on H2 in memory with no web server). 18425 and 8080 (the anchor's own defaults) are checked free at start and end. All
  free at start and end (`lsof`).

## Masks, filters and hygiene — every one, declared

- Captures print selected lines only: each harness JVM's `PROBE` lines, its two `Found … repository interface` lines, Flyway's
  `Database:` line and `HHH000001`; each window's `JdbcTemplate` DEBUG lines (`Executing prepared SQL statement [...]`,
  `Executing SQL query [...]`), sorted with their counts; psql's read-backs; the seven's response lines (each `"timestamp"` value
  masked); the exercise's own `EX` lines. An exception's message is printed on one line, its line breaks as ` / ` (the harness's
  `oneLine`).
- The mask (self-tested at the start with a planted `Started … in 3.1 seconds (process running for 4.2)`, a `Time elapsed:` line, a
  scan line, a Flyway execution time and the folders — dur8 must find nothing in the masked text, R.366): the unit's folder → `…`, the
  repository → `…/..`, home → `~`, Boot's started-in, Surefire's elapsed, Flyway's execution time, Spring Data's scan time, Maven's total
  → `<t>`, identity hashes → `@…`.
- Hygiene, every capture: no absolute path, no unmasked time, no log time, no stack frame, the shutdown token absent; every `java`/`mvn`
  line under its alarm; no H2 file outside `.harness`.

## The ledger rows this unit pays

Nothing on the ledger (the brief); the roadmap line `:331` — "the two classes almost every older Spring codebase contains" — is
`template`, `named` and `four` (one statement and one text at the driver for every API) and `missing` (one exception text for a
missing row across the three APIs).

## RE-MEASURE — the brief's items this unit settles

- **11 (how `JdbcClient` is wired to the templates; each template's bean count and class, RED #11):** captured (`beans`, PostgreSQL
  18.6 and H2 2.5.250 the same): the counts and classes are in the values block; the context's `JdbcClient` holds the context's
  `NamedParameterJdbcTemplate` bean, which holds the context's `JdbcTemplate` bean — by reflection, by identity and by the bean
  factory's dependency lists, all read off the run.
- **12 (the positional mix-up):** captured (`missing`, both databases): two strings swapped → no row, the missing-row text; a number
  and a string swapped → the database's refusal, a different exception on each database; the named forms → Meera's row.
- **16 (the seven, every unit):** `anchor/` on H2, = `c7-unit31`'s `S466` (`seven`).

## What differed from the brief

- **The hook names its four calls by API and placeholder; the record mappers differ by call.** `JdbcTemplate` and the positional
  `JdbcClient` use the lambda `RowMapper`, the named template uses `DataClassRowMapper`, the named `JdbcClient` uses
  `query(Customer.class)` — the probe's Step 5 forms. All four records are asserted equal to psql's row and to each other.
- **`update` runs on a row of the harness's own, Asha** (`VEGAN`, so the `query` window's VEG list is untouched): psql writes, reads
  and deletes her on PostgreSQL; the harness's own `JdbcTemplate` on H2, outside every window. The seeded rows are never written.
  The `query` call reads the VEG customers by `?` (a list); its size is asserted equal to psql's count (PostgreSQL) and to the
  harness's `count(*)` (H2) — never typed.
- **Too many rows is a plain `Statement`, not a prepared one.** `queryForObject(sql, String.class)` with no argument makes
  `JdbcTemplate` call `createStatement`; the witness keeps `(createStatement)` (it records the text handed to `prepareStatement`, and
  `createStatement` takes none) and the DEBUG log `Executing SQL query [...]` — both counted, the text read off the log, on both databases. The window's
  count is the witness's, unchanged.
- **The positional mix-up is measured two ways (RE-MEASURE 12).** The prompt's example (`name = ? and meals_per_day = ?`) swaps a
  number and a string: the database refuses it, differently on each database — that is measured and shown, but it is not the silent
  hazard. Two strings swapped (`meal_type = ? and name = ?`) are silent: no row, the same text on both databases. The exercise uses
  the silent one, so it runs the same on H2 as on PostgreSQL.
- **`beans` builds no data line:** the step reads the context only and counts no statement; it runs in a fresh PostgreSQL database
  (Flyway's V1-V3) and on H2.
- **The `DataSource` bean's class is the witness's `ProxyDataSource`**, around `com.zaxxer.hikari.HikariDataSource`: the harness
  wraps the bean with unit 02's `BeanPostProcessor`, as the `beans` capture prints, so the run cannot print the anchor's own class
  for it without the wrapper: the `beans` capture prints both, and names the wrapper as the harness's.
- **Every call under test uses the context's beans**, found by type (each count printed in every JVM); only the seed, Asha's row on H2
  and the H2 read-backs use a `JdbcTemplate` the harness builds itself on the same `DataSource`, outside every window.
- **The `MapSqlParameterSource` form is a second window of `named`** (the prompt's "if it costs nothing"): one prepare, the same text,
  the record equal.
- **The exercise runs on H2 in memory, no Docker:** the swapped call's text was asserted equal on H2 and PostgreSQL (`missing`), so the
  exercise's README states the one text. Its program uses the context's `JdbcTemplate` and `NamedParameterJdbcTemplate` beans.

## Runs of record

On the script as committed (`md5 -q receipts.sh` in the block), each run of record ended exit 0 with every capture 3/3 and
`= published`, every Maven run `offline: yes`, volumes and images unchanged, nothing listening on 20440-20449 at the end; each run's
log went through `~/.venvs/slides2video/bin/python ~/Desktop/PromptVidya-Automation/check_unit8.py 05 --runlog <log>` (R.352; R.166's
grep errors only — the unit gate itself waits for a script: "no 05-*.md in scripts-and-decks/ yet", exit 2, as the prompt expects).
The three: `./receipts.sh` (the shebang's `/bin/bash`, 3.2.57), `bash receipts.sh` (Homebrew's bash, 5.3.9), and a sealed fresh
clone — `git clone file://…` of this repository at a local commit of this folder, into a path with a space, `.m2-demo` copied from
the seed, `DOCKER_CONFIG=$HOME/.docker`, `http_proxy`/`https_proxy` pointed at a dead `127.0.0.1:9`.

```
receipts.sh md5 5b2f680fb7334b5eb5f9dcf4d2d1dd63
./receipts.sh        /bin/bash 3.2.57             exit 0   wall clock 233 s   check_unit8.py 05 --runlog: PASS
bash receipts.sh     /opt/homebrew/bin/bash 5.3.9 exit 0   wall clock 226 s   check_unit8.py 05 --runlog: PASS
sealed clone         git clone file://… (local commit 65d9df3) into "…/scratchpad/ev05/clone dir/tiffinbox-java" (a path with a space),
                     .m2-demo from the seed, DOCKER_CONFIG=$HOME/.docker, http(s)_proxy at 127.0.0.1:9 (dead):
                     ./c8-unit05/receipts.sh exit 0   wall clock 225 s   check_unit8.py 05 --runlog: PASS
```

Each: all seven captures `= published`, `offline: yes` (one build, `Downloaded from` 0), volumes 315 → 315, images 6 unchanged, the
anchor's pin equal at start and end, nothing listening on 20440-20449 at the end. Two development passes before them produced the
hashes (the first one stopped at the values line, as designed, the second ran to its end). The first run of record ran beside the
gate plants (those stop before any write or docker call, in a mirror). The pushed commit is that local commit amended with this
README's runs, interrupts and plants (the script and every capture unchanged — `md5 -q receipts.sh` above). One more pass of `./receipts.sh`
on this README before the push: exit 0, 225 s, every capture `= published`, `check_unit8.py 05 --runlog` PASS (a first try of it
stopped in the gates, exit 1, before any write: the plants block quoted plant 11's and 12's planted words, which the placeholder and
dish gates refuse; those two lines now say "(the planted line)", as unit 04's do).

## Interrupted

SIGINT (`kill -INT` on the receipt's own pid, started with SIGINT at its default, as a terminal's Ctrl-C reaches it) at three points —
mid-build (the offline Maven build of anchor/'s copy), mid-container (after `docker run`, the container up, before any harness JVM),
mid-harness (a `probe.u05.U5` JVM running, the container up). After each: the exit, the container, the volume count, the
listeners on 20440-20449, our JVMs and Maven, partial `.r-*.[123]` files, `.r-lock`, and the published captures' md5s.

```
SIGINT mid-build     exit 130 · fired: mvn running · container 0 · volumes 315 · listeners 20440-20449 0 · our JVMs/Maven 0 · partial .r-*.[123] 0 · .r-lock gone · captures (= published): = = = = = = =
SIGINT mid-container exit 130 · fired: container up, no harness JVM · container 0 · volumes 315 · listeners 20440-20449 0 · our JVMs/Maven 0 · partial .r-*.[123] 0 · .r-lock gone · captures (= published): = = = = = = =
SIGINT mid-harness   exit 130 · fired: harness JVM running, container up · container 0 · volumes 315 · listeners 20440-20449 0 · our JVMs/Maven 0 · partial .r-*.[123] 0 · .r-lock gone · captures (= published): = = = = = = =
```

The receipt was started from a script in the foreground through a launcher that writes its own pid and then runs
`exec perl -e '$SIG{INT} = "DEFAULT"; exec @ARGV' ./receipts.sh` (a background job of a non-interactive shell starts with SIGINT
ignored); a watcher in the background sent the signal at the point. A first attempt of the three stopped before the receipt started
(the launcher used `$BASHPID`, which bash 3.2 lacks: exit 1, no receipt ran, nothing changed); the lines above are the second
attempt. The mid-harness trigger matched a `java` process running `probe.u05.U5` with escaped dots, so `javac`'s
`probe/u05/*.java` could not set it off (unit 04's lesson). No pass ran to its end by accident.

## Planted faults — each caught (R.65, R.226)

On a scratch mirror (this folder copied, its siblings `c8-unit02`, `c8-tiffinbox`, `c5-unit11`, `c7-unit31` linked read-only), one
plant at a time, the folder restored after each. "Nothing written" = the listing and md5 of every file in the mirror's folder but
`.m2-demo` before and after the planted run (for plants 3, 29, 30, which need the captures, the md5 of every tracked file: the mirror's
receipt ran its seven captures and stopped at the check after them, exit 1; its `.harness/` and `.r-*` files are a run's own and are
not counted). The brief's 04/05 list first — the refused claim that shows `:name` at the driver (plant 1: the prose gate; plant 2: the witness's text in a
doctored `four`), the SOLUTION's named query with the arguments still positional (plant 3: the exercise check — the analogue of
unit 04's `optional()`/`single()` plant) and a typed bean count (plant 4: the prose gate on "one `JdbcTemplate`" said without the `beans` capture; plant 5: the
`beans` capture's count line doctored, caught by `chk05.py`) — then this unit's own and the carried set. The doctored-capture plants
(2, 5, 21, 22, 23, 24, 25, 26, 27, 28) run `harness/chk05.py` on a copy of a published capture in scratch with one line changed; nothing in the folder is touched.
A first pass of those planted nothing (BSD `sed` has no `0,/re/` address: the copies came out unchanged, recorded as "changed
nothing", not counted); they were redone with a Python `re.sub` — the lines below.

```
plant  1 `:name` shown at the driver, in README.md (the hazard) exit 1 · nothing written: yes · a refused word or reading in this unit's prose: README.md line 102: the hazard: `:name` shown at the driver - the witness's text is `?`
plant  2 `:name` at the driver in the witness text (a doctored four) exit 1 · FAIL PostgreSQL 18.6, four NamedParameterJdbcTemplate: JdbcTemplate's DEBUG text = the text the driver received (the witness)
plant  3 the SOLUTION's named query with the arguments still positional (the exercise check) exit 1 · nothing written: yes · exercise: its check failed (harness/chk05.py)
plant  4 a typed bean count ("one `JdbcTemplate`") in README.md exit 1 · nothing written: yes · a refused word or reading in this unit's prose: README.md line 102: RED #11: a bean count without the `beans` capture
plant  5 a typed bean count: the beans line doctored to 2 (one bean listed) exit 1 · FAIL beans: every JVM printed its beans of JdbcTemplate line, the same in each ([('1', 'org.springframework.jdbc.core.JdbcTemplate'), ('2', 'org.sprin
plant  6 "named parameters in the database" in README.md exit 1 · nothing written: yes · a refused word or reading in this unit's prose: README.md line 102: the hazard: named parameters in the database - the witness's text is `?`
plant  7 "sits on" without the beans capture, in README.md exit 1 · nothing written: yes · a refused word or reading in this unit's prose: README.md line 102: RE-MEASURE 11: a wiring claim without the `beans` capture
plant  8 the word legacy, in README.md (R.261) exit 1 · nothing written: yes · a refused word or reading in this unit's prose: README.md line 102: R.261: legacy - say older Spring codebases
plant  9 "faster" (dur8) exit 1 · nothing written: yes · a refused word or reading in this unit's prose: README.md line 102: dur8: faster
plant 10 a wrong hash (the anchor tree pin) exit 1 · nothing written: yes · R.211: anchor/'s tree is 51 7ce49e3ec13c212a31ee6ba4618f53ab, the pin in receipts.md5 is 51 00000000000000000000000000000000 - the tree moved
plant 11 a placeholder in the exercise exit 1 · nothing written: yes · a placeholder in this unit's prose: exercise/README.md:35: (the planted to-do line)
plant 12 a dish name exit 1 · nothing written: yes · an Indian dish name (R.215: English names only): README.md:102: (the planted line)
plant 13 a typed count (R.302) exit 1 · nothing written: yes · a refused word or reading in this unit's prose: README.md line 102: R.302: a capture's number typed in prose: 38
plant 14 the exercise solution = broken (R.196) exit 1 · nothing written: yes · R.196: SOLUTION.md's block must be the README's with one line changed (it is 0 lines apart)
plant 15 the container removed without -v (R.322) exit 1 · nothing written: yes · R.322: receipts.sh removes a container without its volume (rm -fv)
plant 16 the docker CLI unpinned, DOCKER_HOST=tcp://127.0.0.1:1 (R.344) exit 1 · nothing written: yes · R.344: dk() must name the pinned socket (docker -H "$DH")
plant 17 the anchor link pointed at c8-tiffinbox (readlink) exit 1 · nothing written: yes · anchor must be a link to ../c8-unit02/after (it points at: ../c8-tiffinbox)
plant 18 a Course 2 title not byte-equal to java2_series.py exit 1 · nothing written: yes · R.224: README.md calls the unit back by its title: TiffinBox on a Real Database: The JDBC Repository
plant 19 "N times" (R.309) exit 1 · nothing written: yes · a refused word or reading in this unit's prose: README.md line 102: R.309: "N times": four times
plant 20 the witness changed beyond its package line (R.357) exit 1 · nothing written: yes · R.357: harness/src/probe/u05/Witness.java must be unit 02's witness with its package line alone changed
plant 21 the wiring doctored: JdbcClient field not the named template bean exit 1 · FAIL PostgreSQL 18.6: reflection and the bean factory agree - JdbcClient's field is the named template bean iff its dependency list names it
plant 22 the positional mix-up doctored to the right row (a doctored missing) exit 1 · FAIL PostgreSQL 18.6: the swapped call (two strings) finds no row - the same text as a missing row ([])
plant 23 the missing-row text differing across the three APIs (a doctored missing) exit 1 · FAIL PostgreSQL 18.6, missing NamedParameterJdbcTemplate: EmptyResultDataAccessException, actual 0 (['org.springframework.dao.EmptyResultDataAccessExc
plant 24 no HHH000001 in the JVMs (a doctored named) exit 1 · FAIL named: HHH000001 in every JVM's log
plant 25 a version line missing in one JVM (a doctored missing) exit 1 · FAIL missing: a version line in every JVM that started (2 of 3)
plant 26 a too-many count not the data line (a doctored missing) exit 1 · FAIL PostgreSQL 18.6: queryForObject on every name -> actual = the data line's 40 customers (['org.springframework.dao.IncorrectResultSizeDataAccessEx
plant 27 the rows affected not the second client's row (a doctored template) exit 1 · FAIL PostgreSQL: the harness's read-backs of Asha = psql's, before and after (['Asha · 2 · 120 · VEGAN'] ['Asha · 3 · 120 · VEGAN'] / ['Asha · 
plant 28 the four texts at the driver not one (a doctored four, H2) exit 1 · FAIL H2 2.5.250, four JdbcClient positional: JdbcTemplate's DEBUG text = the text the driver received (the witness)
plant 29 a changed What-it-prints line (exercise/SOLUTION.md) exit 1 · nothing written: yes · exercise/SOLUTION.md's "What it prints" block is not what its lines printed: 4c4 < EX done: yes - Meera's row ---
plant 30 a typed SQL line in a README text block (R.302) exit 1 · nothing written: yes · R.302: README.md's text blocks must be lines the runs printed - not printed: select name from customer where name = :name
plants: 30 · caught: 30
```

## For RED

- **The text at the driver** is the witness's `prepareStatement` string: `… where name = ?` for all four APIs on both databases. A slide
  that shows `:name` reaching the driver, or puts the parameter names in the database, is false.
- **The bean lines** are the `beans` capture's, on both databases: each count is the number of beans `getBeanNamesForType` listed, and
  each link of the chain is shown twice — by object identity and by the bean factory's dependency list. Nothing is taken from the
  documentation. The `DataSource` class printed is the witness's wrapper.
- **The rows** are not counted by the witness. "One row" is the `queryForObject` / `single()` contract plus the record equal to psql's
  row (unit 04's wording).
- **The mix-up has two outcomes, by the types swapped:** same-type values → no row (silent); a number and a string → the database
  refuses, a different exception class per database. A sentence that says "the wrong order throws a type error" is true only of the
  second; the exercise is the first.
- **The too-many-rows window is a plain `Statement`** (no argument): `(createStatement)` at the witness, the SQL from the DEBUG log.
- **Not measured here:** a route over HTTP, rows by a `ResultSet` counter, `SimpleJdbcInsert` / `SimpleJdbcCall`, batch updates
  through either template.
