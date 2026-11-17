# c8-unit03 — Relationships Without an ORM

Course 8, Section 1 (Spring Data JDBC), unit 03 — **a harness unit: no anchor change.** It measures what `@MappedCollection` does
with the pauses inside the customer aggregate — the aggregate as unit 02 *Aggregates, Not Entities* named and landed it, called back
here by title, not glossed again — on PostgreSQL 18.6 in a container AND on H2 in memory, the anchor's default (S8.11, RED #16):
the save that deletes every pause row and inserts the collection again, the unchanged save that does the same, the load —
`findById`, `findAll()`, `findAll(Sort)`, `findAllById` on PostgreSQL and on H2, with single-query loading off (the anchor's) and on (a
harness switch) — the back-reference column `idColumn` names, and a reference to another aggregate held as an id.

- `anchor` → `../c8-unit02/after` (a link; both Spring Data modules, `JdbcNames`'s Q imported; `../c8-tiffinbox` equals it today,
  `diff -rq` empty, printed by every run). `harness/tree03.py` pins its tree: the file count and the md5 in `receipts.md5`'s
  `anchor-tree` line, written from a run's own output.
- Nothing in the anchor is edited. Every tree is copied under `.harness/` and built there, offline, from `.m2-demo` (a copy of the
  course's seed `spring-data-beyond-jpa/_research/m2-seed-c8-s1/`). The one copy that differs — `noid` — is derived by a named edit
  in `receipts.sh` (one line of `CustomerRow.java`), and every run prints its diff; it is never committed as a tree.

Run it: `./receipts.sh` from this folder (JDK 25, Maven, OrbStack's docker socket, the postgres image by its digest already on the
machine — the script never pulls). Every number below is a line a run printed; the values block is assembled from `harness/chk03.py`'s
output and compared with this file byte for byte.

## The captures — what each one shows

Seven captures, each run three times and hashed (`receipts.md5`); each is read back by `harness/chk03.py` against a second witness of
the same run before its hash is compared. Every statement count is the witness's — datasource-proxy 1.11.1 on the `DataSource` bean,
unit 02's class with its package line alone changed — per labelled window (R.357, R.367); `JdbcTemplate`'s DEBUG log of the same
window is the second count (`Executing prepared SQL statement` lines, asserted equal) and the source of the SQL text. On PostgreSQL the
rows are read back by psql in the container; on H2 in memory by `JdbcTemplate` in the same JVM. Each capture builds the data line
first (the seed step: V2's rows, then customers by `JdbcTemplate` with one 2-day pause each — RE-MEASURE 4), on a fresh database per
PostgreSQL sequence.

### 1 · reinsert — the hook: a pause added, the save (S8.14)

Sunil's aggregate is loaded outside the window (`findById`), one 1-day pause is added to its `Set` in Java, and `save()` runs alone in
the window. psql reads Sunil's pause rows (`id:days`), his `version` and the pause identity (`pg_sequences`, `pause_id_seq`'s
`last_value`) before and after, on PostgreSQL 18.6; `JdbcTemplate` reads the rows and the version on H2.

```text
psql (a second client, PostgreSQL): 40 customers · 38 pauses · 77 paused days
psql before (a second client, PostgreSQL): Sunil pauses 1:3 · version 0 · pause identity (pg_sequences, pause_id_seq) last_value 38
PROBE reinsert (Spring Data JDBC save(), Sunil + one 1-day pause, PostgreSQL 18.6): the witness 4 · SELECT 0 · UPDATE 1 · DELETE 1 · INSERT with id 1 · INSERT without id 1
PROBE reinsert (Spring Data JDBC save(), Sunil + one 1-day pause, PostgreSQL 18.6) SQL x1: DELETE FROM pause WHERE pause.customer_id = ?
PROBE reinsert (Spring Data JDBC save(), Sunil + one 1-day pause, PostgreSQL 18.6) SQL x1: INSERT INTO pause (customer_id, days) VALUES (?, ?)
PROBE reinsert (Spring Data JDBC save(), Sunil + one 1-day pause, PostgreSQL 18.6) SQL x1: INSERT INTO pause (customer_id, days, id) VALUES (?, ?, ?)
PROBE reinsert (Spring Data JDBC save(), Sunil + one 1-day pause, PostgreSQL 18.6) SQL x1: UPDATE customer SET name = ?, meals_per_day = ?, price_per_meal = ?, meal_type = ?, version = ? WHERE customer.id = ? AND customer.version = ?
log reinsert (PostgreSQL, JdbcTemplate DEBUG): 'Executing prepared SQL statement' 4 · 'Executing SQL batch update' 1
log reinsert x1: Executing SQL batch update [INSERT INTO pause (customer_id, days, id) VALUES (?, ?, ?)]
log reinsert x1: Executing prepared SQL statement [DELETE FROM pause WHERE pause.customer_id = ?]
log reinsert x1: Executing prepared SQL statement [INSERT INTO pause (customer_id, days) VALUES (?, ?)]
log reinsert x1: Executing prepared SQL statement [INSERT INTO pause (customer_id, days, id) VALUES (?, ?, ?)]
log reinsert x1: Executing prepared SQL statement [UPDATE customer SET name = ?, meals_per_day = ?, price_per_meal = ?, meal_type = ?, version = ? WHERE customer.id = ? AND customer.version = ?]
psql after (a second client, PostgreSQL): Sunil pauses 1:3 39:1 · version 1 · pause identity (pg_sequences, pause_id_seq) last_value 39
PROBE read back by JdbcTemplate (H2 2.5.250): Sunil pauses 1:3 · version 0
PROBE reinsert (Spring Data JDBC save(), Sunil + one 1-day pause, H2 2.5.250): the witness 4 · SELECT 0 · UPDATE 1 · DELETE 1 · INSERT with id 1 · INSERT without id 1
PROBE reinsert (Spring Data JDBC save(), Sunil + one 1-day pause, H2 2.5.250) SQL x1: DELETE FROM pause WHERE pause.customer_id = ?
PROBE reinsert (Spring Data JDBC save(), Sunil + one 1-day pause, H2 2.5.250) SQL x1: INSERT INTO pause (customer_id, DAYS) VALUES (?, ?)
PROBE reinsert (Spring Data JDBC save(), Sunil + one 1-day pause, H2 2.5.250) SQL x1: INSERT INTO pause (customer_id, DAYS, ID) VALUES (?, ?, ?)
PROBE reinsert (Spring Data JDBC save(), Sunil + one 1-day pause, H2 2.5.250) SQL x1: UPDATE customer SET NAME = ?, MEALS_PER_DAY = ?, PRICE_PER_MEAL = ?, MEAL_TYPE = ?, VERSION = ? WHERE customer.ID = ? AND customer.VERSION = ?
PROBE read back by JdbcTemplate (H2 2.5.250): Sunil pauses 1:3 39:1 · version 1
log reinsert (H2, JdbcTemplate DEBUG): 'Executing prepared SQL statement' 4 · 'Executing SQL batch update' 1
log reinsert x1: Executing SQL batch update [INSERT INTO pause (customer_id, DAYS, ID) VALUES (?, ?, ?)]
log reinsert x1: Executing prepared SQL statement [DELETE FROM pause WHERE pause.customer_id = ?]
log reinsert x1: Executing prepared SQL statement [INSERT INTO pause (customer_id, DAYS) VALUES (?, ?)]
log reinsert x1: Executing prepared SQL statement [INSERT INTO pause (customer_id, DAYS, ID) VALUES (?, ?, ?)]
log reinsert x1: Executing prepared SQL statement [UPDATE customer SET NAME = ?, MEALS_PER_DAY = ?, PRICE_PER_MEAL = ?, MEAL_TYPE = ?, VERSION = ? WHERE customer.ID = ? AND customer.VERSION = ?]
```

What it shows, on both databases: the UPDATE of the root's row, the DELETE of every pause row of the customer, the INSERT of the old
pause with its id and the INSERT of the new one without — the witness's count and the log's are equal. The old pause keeps its id
(psql on PostgreSQL and `JdbcTemplate` on H2 read it before and after); the new pause takes the identity's next value, and psql reads
the identity advanced by one on PostgreSQL. `JdbcTemplate`'s log names the INSERT with ids twice — a batch update line and the prepared
statement line (Spring Data JDBC sends the elements that carry ids as a JDBC batch); the witness counts its prepare once. The SQL on
PostgreSQL 18.6 reads in lower case, on H2 2.5.250 with the derived names upper-cased (`DAYS`, `ID`) and the name written in
`idColumn` as written (`customer_id`): the database is named on every line.

### 2 · same — the unchanged save: no diff, ever

On a fresh database: Sunil's aggregate loaded and saved with nothing changed; then Ravi's, who has no pauses. The DELETE is in the
log of both unchanged saves on both databases, so the sentence "no diff, ever" is the capture's (the prompt's condition): Spring Data
JDBC does not compare the collection with what it loaded — it replaces it.

```text
psql before (a second client, PostgreSQL): Sunil pauses 1:3 · version 0 · Ravi pauses (none) · version 0 · pause identity (pg_sequences, pause_id_seq) last_value 38
PROBE same Sunil (Spring Data JDBC save(), Sunil unchanged, PostgreSQL 18.6): the witness 3 · SELECT 0 · UPDATE 1 · DELETE 1 · INSERT with id 1 · INSERT without id 0
PROBE same Sunil (Spring Data JDBC save(), Sunil unchanged, PostgreSQL 18.6) SQL x1: DELETE FROM pause WHERE pause.customer_id = ?
PROBE same Sunil (Spring Data JDBC save(), Sunil unchanged, PostgreSQL 18.6) SQL x1: INSERT INTO pause (customer_id, days, id) VALUES (?, ?, ?)
PROBE same Sunil (Spring Data JDBC save(), Sunil unchanged, PostgreSQL 18.6) SQL x1: UPDATE customer SET name = ?, meals_per_day = ?, price_per_meal = ?, meal_type = ?, version = ? WHERE customer.id = ? AND customer.version = ?
PROBE same Ravi (Spring Data JDBC save(), Ravi unchanged - no pauses, PostgreSQL 18.6): the witness 2 · SELECT 0 · UPDATE 1 · DELETE 1 · INSERT with id 0 · INSERT without id 0
PROBE same Ravi (Spring Data JDBC save(), Ravi unchanged - no pauses, PostgreSQL 18.6) SQL x1: DELETE FROM pause WHERE pause.customer_id = ?
PROBE same Ravi (Spring Data JDBC save(), Ravi unchanged - no pauses, PostgreSQL 18.6) SQL x1: UPDATE customer SET name = ?, meals_per_day = ?, price_per_meal = ?, meal_type = ?, version = ? WHERE customer.id = ? AND customer.version = ?
log same Sunil (PostgreSQL, JdbcTemplate DEBUG): 'Executing prepared SQL statement' 3 · 'Executing SQL batch update' 1
log same Sunil x1: Executing SQL batch update [INSERT INTO pause (customer_id, days, id) VALUES (?, ?, ?)]
log same Sunil x1: Executing prepared SQL statement [DELETE FROM pause WHERE pause.customer_id = ?]
log same Sunil x1: Executing prepared SQL statement [INSERT INTO pause (customer_id, days, id) VALUES (?, ?, ?)]
log same Sunil x1: Executing prepared SQL statement [UPDATE customer SET name = ?, meals_per_day = ?, price_per_meal = ?, meal_type = ?, version = ? WHERE customer.id = ? AND customer.version = ?]
log same Ravi (PostgreSQL, JdbcTemplate DEBUG): 'Executing prepared SQL statement' 2 · 'Executing SQL batch update' 0
log same Ravi x1: Executing prepared SQL statement [DELETE FROM pause WHERE pause.customer_id = ?]
log same Ravi x1: Executing prepared SQL statement [UPDATE customer SET name = ?, meals_per_day = ?, price_per_meal = ?, meal_type = ?, version = ? WHERE customer.id = ? AND customer.version = ?]
psql after (a second client, PostgreSQL): Sunil pauses 1:3 · version 1 · Ravi pauses (none) · version 1 · pause identity (pg_sequences, pause_id_seq) last_value 38
PROBE same Sunil (Spring Data JDBC save(), Sunil unchanged, H2 2.5.250): the witness 3 · SELECT 0 · UPDATE 1 · DELETE 1 · INSERT with id 1 · INSERT without id 0
PROBE same Sunil (Spring Data JDBC save(), Sunil unchanged, H2 2.5.250) SQL x1: DELETE FROM pause WHERE pause.customer_id = ?
PROBE same Sunil (Spring Data JDBC save(), Sunil unchanged, H2 2.5.250) SQL x1: INSERT INTO pause (customer_id, DAYS, ID) VALUES (?, ?, ?)
PROBE same Sunil (Spring Data JDBC save(), Sunil unchanged, H2 2.5.250) SQL x1: UPDATE customer SET NAME = ?, MEALS_PER_DAY = ?, PRICE_PER_MEAL = ?, MEAL_TYPE = ?, VERSION = ? WHERE customer.ID = ? AND customer.VERSION = ?
PROBE same Ravi (Spring Data JDBC save(), Ravi unchanged - no pauses, H2 2.5.250): the witness 2 · SELECT 0 · UPDATE 1 · DELETE 1 · INSERT with id 0 · INSERT without id 0
PROBE same Ravi (Spring Data JDBC save(), Ravi unchanged - no pauses, H2 2.5.250) SQL x1: DELETE FROM pause WHERE pause.customer_id = ?
PROBE same Ravi (Spring Data JDBC save(), Ravi unchanged - no pauses, H2 2.5.250) SQL x1: UPDATE customer SET NAME = ?, MEALS_PER_DAY = ?, PRICE_PER_MEAL = ?, MEAL_TYPE = ?, VERSION = ? WHERE customer.ID = ? AND customer.VERSION = ?
log same Sunil (H2, JdbcTemplate DEBUG): 'Executing prepared SQL statement' 3 · 'Executing SQL batch update' 1
log same Sunil x1: Executing SQL batch update [INSERT INTO pause (customer_id, DAYS, ID) VALUES (?, ?, ?)]
log same Sunil x1: Executing prepared SQL statement [DELETE FROM pause WHERE pause.customer_id = ?]
log same Sunil x1: Executing prepared SQL statement [INSERT INTO pause (customer_id, DAYS, ID) VALUES (?, ?, ?)]
log same Sunil x1: Executing prepared SQL statement [UPDATE customer SET NAME = ?, MEALS_PER_DAY = ?, PRICE_PER_MEAL = ?, MEAL_TYPE = ?, VERSION = ? WHERE customer.ID = ? AND customer.VERSION = ?]
log same Ravi (H2, JdbcTemplate DEBUG): 'Executing prepared SQL statement' 2 · 'Executing SQL batch update' 0
log same Ravi x1: Executing prepared SQL statement [DELETE FROM pause WHERE pause.customer_id = ?]
log same Ravi x1: Executing prepared SQL statement [UPDATE customer SET NAME = ?, MEALS_PER_DAY = ?, PRICE_PER_MEAL = ?, MEAL_TYPE = ?, VERSION = ? WHERE customer.ID = ? AND customer.VERSION = ?]
```

Sunil's pause ids are the same before and after, read by psql on PostgreSQL and by `JdbcTemplate` on H2, and each version rises by
one as psql and `JdbcTemplate` read it; the identity does not move on PostgreSQL (psql). Ravi's save has no INSERT: a customer with no pauses costs the
UPDATE and the DELETE.

### 3 · load — per method, per database (S8.26 = R.368)

On a fresh PostgreSQL database and on H2 in memory, after the data line: four reads, one window each — `findById(Sunil)`, `findAll()`,
`findAll(Sort.by("name"))`, `findAllById` (every customer id, read outside the window). First with single-query loading as the
anchor has it for `findAll()` and the others on PostgreSQL and H2 (off: every JVM prints the mapping context's
`isSingleQueryLoadingEnabled()`), then in a second JVM with
`-Du03.sq=true`, which makes the harness's `SingleQuery` post-processor call `setSingleQueryLoadingEnabled(true)` on the mapping
context before it initialises (BLUE #2's sketch, Q kept: the anchor's `JdbcNames` runs too). The anchor never switches it on: the
receipt greps the anchor for the setter (0), and `JPA vs JDBC vs Plain SQL` (U06) owns the exercise that uses it.

```text
PROBE load findById(Sunil) (PostgreSQL 18.6, single-query loading false): the witness 2 · SELECT 2 · UPDATE 0 · DELETE 0 · INSERT with id 0 · INSERT without id 0
PROBE load findAll() (PostgreSQL 18.6, single-query loading false): the witness 41 · SELECT 41 · UPDATE 0 · DELETE 0 · INSERT with id 0 · INSERT without id 0
PROBE load findAll(Sort.by("name")) (PostgreSQL 18.6, single-query loading false): the witness 41 · SELECT 41 · UPDATE 0 · DELETE 0 · INSERT with id 0 · INSERT without id 0
PROBE load findAllById(40 ids) (PostgreSQL 18.6, single-query loading false): the witness 41 · SELECT 41 · UPDATE 0 · DELETE 0 · INSERT with id 0 · INSERT without id 0
PROBE load findById(Sunil) (PostgreSQL 18.6, single-query loading true): the witness 1 · SELECT 1 · UPDATE 0 · DELETE 0 · INSERT with id 0 · INSERT without id 0
PROBE load findAll() (PostgreSQL 18.6, single-query loading true): the witness 1 · SELECT 1 · UPDATE 0 · DELETE 0 · INSERT with id 0 · INSERT without id 0
PROBE load findAll(Sort.by("name")) (PostgreSQL 18.6, single-query loading true): the witness 41 · SELECT 41 · UPDATE 0 · DELETE 0 · INSERT with id 0 · INSERT without id 0
PROBE load findAllById(40 ids) (PostgreSQL 18.6, single-query loading true): the witness 1 · SELECT 1 · UPDATE 0 · DELETE 0 · INSERT with id 0 · INSERT without id 0
PROBE load findById(Sunil) (H2 2.5.250, single-query loading false): the witness 2 · SELECT 2 · UPDATE 0 · DELETE 0 · INSERT with id 0 · INSERT without id 0
PROBE load findAll() (H2 2.5.250, single-query loading false): the witness 41 · SELECT 41 · UPDATE 0 · DELETE 0 · INSERT with id 0 · INSERT without id 0
PROBE load findAll(Sort.by("name")) (H2 2.5.250, single-query loading false): the witness 41 · SELECT 41 · UPDATE 0 · DELETE 0 · INSERT with id 0 · INSERT without id 0
PROBE load findAllById(40 ids) (H2 2.5.250, single-query loading false): the witness 41 · SELECT 41 · UPDATE 0 · DELETE 0 · INSERT with id 0 · INSERT without id 0
PROBE load findById(Sunil) (H2 2.5.250, single-query loading true): the witness 2 · SELECT 2 · UPDATE 0 · DELETE 0 · INSERT with id 0 · INSERT without id 0
PROBE load findAll() (H2 2.5.250, single-query loading true): the witness 41 · SELECT 41 · UPDATE 0 · DELETE 0 · INSERT with id 0 · INSERT without id 0
PROBE load findAll(Sort.by("name")) (H2 2.5.250, single-query loading true): the witness 41 · SELECT 41 · UPDATE 0 · DELETE 0 · INSERT with id 0 · INSERT without id 0
PROBE load findAllById(40 ids) (H2 2.5.250, single-query loading true): the witness 41 · SELECT 41 · UPDATE 0 · DELETE 0 · INSERT with id 0 · INSERT without id 0
```

Off, on both databases: `findById` reads the customer and then her pauses; `findAll()`, `findAll(Sort.by("name"))` and
`findAllById` read the customers and then one pause SELECT per aggregate — chk03 asserts each count is one plus the window's pause
SELECTs, and those equal to the aggregates read. With single-query loading on, on PostgreSQL 18.6, `findAll()`, `findById` and
`findAllById` are one statement each and `findAll(Sort.by("name"))` is unchanged; on H2 2.5.250 every read with single-query loading
on is the same as off, `findAll()` and `findById` included. Each number is its own window's; none is said for another method or the
other database.

### 4 · noid — the back-reference column (the failure receipt, RE-MEASURE 8)

A COPY of `anchor/` (`.harness/noid`), never the anchor, with `idColumn` removed from `@MappedCollection` — the one line `receipts.sh`
edits and prints. Then `findAll()` on H2 in memory and on PostgreSQL 18.6, each beside `anchor/`'s own read on the same data. Ports
20422 and 20423 are never bound: the harness runs with no web server.

```text
<     @MappedCollection(idColumn = "customer_id")
>     @MappedCollection
PROBE read findAll() (H2 2.5.250): org.springframework.jdbc.BadSqlGrammarException <- org.h2.jdbc.JdbcSQLSyntaxErrorException: Column "PAUSE.CUSTOMER" not found
PROBE read findAll() (H2 2.5.250) SQL x1: SELECT pause.ID AS ID, pause.DAYS AS DAYS FROM pause WHERE pause.CUSTOMER = ?
PROBE read findAll() (H2 2.5.250): aggregates 40
PROBE read findAll() (H2 2.5.250) SQL x40: SELECT pause.ID AS ID, pause.DAYS AS DAYS FROM pause WHERE pause.customer_id = ?
PROBE read findAll() (PostgreSQL 18.6): org.springframework.jdbc.BadSqlGrammarException <- org.postgresql.util.PSQLException: ERROR: column pause.customer does not exist
PROBE read findAll() (PostgreSQL 18.6) SQL x1: SELECT pause.id AS id, pause.days AS days FROM pause WHERE pause.customer = ?
PROBE read findAll() (PostgreSQL 18.6): aggregates 40
PROBE read findAll() (PostgreSQL 18.6) SQL x40: SELECT pause.id AS id, pause.days AS days FROM pause WHERE pause.customer_id = ?
```

Without `idColumn` the module names the back-reference column after the parent's table: `customer`, not V1's `customer_id`. The customer
SELECT runs, the pause SELECT is refused, and the JVM exits 1 — on H2 with `Column "PAUSE.CUSTOMER" not found` (the probe's text,
unchanged under Q: H2 upper-cases the derived name), on PostgreSQL with `ERROR: column pause.customer does not exist` (measured here
for the first time, read off the run). With `idColumn = "customer_id"` — the anchor — both databases read every aggregate.

### 5 · ref — `AggregateReference` (RE-MEASURE 7: captured, so the beat stands)

`PauseRef` is a sketch class in `harness/src` (never the anchor): a pause read as an aggregate of its own over V1's `pause` table,
whose customer — another aggregate — is held as `AggregateReference<CustomerRow, Long>` in a field `customerId` (column `customer_id`
by the default naming). Through `JdbcAggregateTemplate`: one read of Sunil's pause, then one insert of a pause for Ravi, each read back
by `JdbcTemplate` (and on PostgreSQL by psql).

```text
PROBE ref findById (JdbcAggregateTemplate, PauseRef, H2 2.5.250) SQL x1: SELECT pause.ID AS ID, pause.DAYS AS DAYS, pause.CUSTOMER_ID AS CUSTOMER_ID FROM pause WHERE pause.ID = ?
PROBE ref: PauseRef 1 · days 3 · customerId IdOnlyAggregateReference getId() 3 · Sunil's id (JdbcTemplate) 3 · equal: yes · the PauseRef holds a CustomerRow: no
PROBE ref insert (JdbcAggregateTemplate, a new PauseRef for Ravi, H2 2.5.250) SQL x1: INSERT INTO pause (CUSTOMER_ID, DAYS) VALUES (?, ?)
PROBE ref: the new pause read back by JdbcTemplate (H2 2.5.250): customer_id = Ravi's id: yes · days 2
PROBE ref: Ravi's aggregate, read after it (CustomerAggregates): pauses 1 - the pause row belongs to his aggregate too
PROBE ref findById (JdbcAggregateTemplate, PauseRef, PostgreSQL 18.6) SQL x1: SELECT pause.id AS id, pause.days AS days, pause.customer_id AS customer_id FROM pause WHERE pause.id = ?
PROBE ref: PauseRef 1 · days 3 · customerId IdOnlyAggregateReference getId() 3 · Sunil's id (JdbcTemplate) 3 · equal: yes · the PauseRef holds a CustomerRow: no
PROBE ref insert (JdbcAggregateTemplate, a new PauseRef for Ravi, PostgreSQL 18.6) SQL x1: INSERT INTO pause (customer_id, days) VALUES (?, ?)
PROBE ref: the new pause read back by JdbcTemplate (PostgreSQL 18.6): customer_id = Ravi's id: yes · days 2
PROBE ref: Ravi's aggregate, read after it (CustomerAggregates): pauses 1 - the pause row belongs to his aggregate too
psql (a second client, PostgreSQL): the newest pause row: Ravi · days 2 · customer_id = Ravi's id: yes
```

The read selects from `pause` alone — no customer row is read and the object holds no `CustomerRow`: the reference is the id, equal to
Sunil's id as `JdbcTemplate` reads it. The insert writes `customer_id` from the reference. The capture's last harness line is the
caveat the sketch carries: the row it inserted is a row of Ravi's aggregate too — `CustomerAggregates` reads it as his pause — because
`CustomerRow` owns the `pause` table through `@MappedCollection`. A reference between aggregates belongs where the other side does not
own the rows; this sketch only shows what the reference holds and what it reads (U03's beat: "a reference to another aggregate is an
id"). Measured inside the time the brief allowed for it.

### 6 · seven — the comparison set, unchanged (RE-MEASURE 16)

`anchor/`'s jar, `java -jar` on H2 in memory, port 20420 (loopback), the seven requests of `../c5-unit11/curlset.sh` (the shutdown
token on its standard input, never on a command line), TiffinBox stopped by its own `POST /shutdown`. The md5 is compared with Course
7's `S466`, read off `../c7-unit31/receipts.sh`.

```text
GET /actuator/health/readiness -> 200 · listens on: 127.0.0.1:20420
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b · listening on 20420 now: 0
```

### 7 · exercise — run as written, in one shell, bash then zsh (R.196)

`exercise/README.md`'s lines, then `exercise/SOLUTION.md`'s, in ONE `env -i` shell — `/bin/bash --noprofile --norc`, then `/bin/zsh -f`;
each file's "What it prints" block is compared with what its lines printed, line for line. H2 in memory, no Docker, no Maven: the
block compiles `exercise/Ex03.java` against the jar this receipt built and datasource-proxy in `.m2-demo`. The broken test counts the
statements that start with `SELECT`; the save of a loaded aggregate sends none, so it prints zero. The solution counts every statement
the witness kept. chk03 asserts the solved count and the sorted statements equal capture `same`'s H2 window for the same save — the
number holds on H2, so the exercise runs there (the prompt's condition); on PostgreSQL the same window has the same count (`same`).

## The values the video may say

Assembled from chk03.py's `VALUES` lines; `receipts.sh` refuses this file unless the line below is byte-equal to what the run assembled.

<!-- values: begin -->
the values the video may say - reinsert: PostgreSQL 18.6: save() of Sunil + one 1-day pause = 4 statements (UPDATE, DELETE FROM pause WHERE pause.customer_id = ?, INSERT with id, INSERT without id; the with-id INSERT logged by JdbcTemplate as a batch update); psql: pauses 1:3 -> 1:3 39:1, version 0 -> 1, pause identity last_value 38 -> 39; H2 2.5.250: the same 4 statements; JdbcTemplate: pauses 1:3 -> 1:3 39:1, version 0 -> 1 · same: PostgreSQL 18.6: Sunil saved unchanged = 3 statements (UPDATE, DELETE, INSERT with id); Ravi (no pauses) = 2 (UPDATE, DELETE); psql: Sunil's pauses 1:3 -> 1:3, version 0 -> 1; Ravi's version 0 -> 1; the identity unchanged; H2 2.5.250: the same 3 and 2; JdbcTemplate: Sunil's pauses 1:3 -> 1:3, version 0 -> 1 · load: single-query loading off (the anchor's): PostgreSQL 18.6 findById 2 · findAll() 41 · findAll(Sort.by("name")) 41 · findAllById 41; H2 2.5.250 findById 2 · findAll() 41 · findAll(Sort.by("name")) 41 · findAllById 41 - single-query loading on (the harness's SingleQuery, never the anchor): PostgreSQL 18.6 findById 1 · findAll() 1 · findAll(Sort.by("name")) 41 · findAllById 1; H2 2.5.250 findById 2 · findAll() 41 · findAll(Sort.by("name")) 41 · findAllById 41 · noid: H2 2.5.250: the copy without idColumn - findAll() -> org.h2.jdbc.JdbcSQLSyntaxErrorException: Column "PAUSE.CUSTOMER" not found (SQL ... WHERE pause.CUSTOMER = ?), exit 1; anchor/ with idColumn = "customer_id" reads 40 aggregates; PostgreSQL 18.6: the copy without idColumn - findAll() -> org.postgresql.util.PSQLException: ERROR: column pause.customer does not exist (SQL ... WHERE pause.customer = ?), exit 1; anchor/ with idColumn = "customer_id" reads 40 aggregates · ref: H2 2.5.250: AggregateReference<CustomerRow, Long> on a sketch class (PauseRef, never the anchor) - a read = 1 SELECT of pause alone, getId() = Sunil's id by JdbcTemplate, no CustomerRow held; an insert = 1 INSERT, its customer_id = Ravi's id by JdbcTemplate; PostgreSQL 18.6: AggregateReference<CustomerRow, Long> on a sketch class (PauseRef, never the anchor) - a read = 1 SELECT of pause alone, getId() = Sunil's id by JdbcTemplate, no CustomerRow held; an insert = 1 INSERT, its customer_id = Ravi's id by JdbcTemplate and psql · seven: the seven on anchor/ (H2): 466c20ed…, unchanged · exercise: the exercise (23 words, H2 in memory, no Docker): broken - counts SELECTs only, prints 0; solved - every statement the witness kept, 3 (UPDATE, DELETE, INSERT with id), = capture same's H2 window; Sunil's pause ids unchanged by JdbcTemplate
<!-- values: end -->

The hook's statement list, with its database: on PostgreSQL 18.6, `UPDATE customer SET … WHERE customer.id = ? AND customer.version = ?`,
`DELETE FROM pause WHERE pause.customer_id = ?`, `INSERT INTO pause (customer_id, days, id) VALUES (?, ?, ?)` and
`INSERT INTO pause (customer_id, days) VALUES (?, ?)` — counted, never ordered between the two INSERTs (S8.16: the pauses are a `Set`,
its iteration is not fixed; the captures sort the SQL texts).

## Refused, named

- **`new ids` (S8.14):** refused by `s803.py`; the ids survive — psql's and `JdbcTemplate`'s read-backs, before and after, on both
  databases. Only the added pause gets a fresh value from the identity (psql: the identity advanced by one on PostgreSQL).
- **The INSERTs' order (S8.16):** never compared or voiced; the captures print the SQL texts sorted with their counts.
- **`single-query loading changes nothing` (S8.26):** refused; every sentence about it names its method and its database, as the
  `load` table has it (PostgreSQL 18.6: `findAll()`, `findById`, `findAllById` change; `findAll(Sort)` does not; H2 2.5.250: no read changes).
- **`faster`, `lighter`, `simpler` (R.355, R.366):** refused without a count beside them; dur8 words: 0.
- **A `version` sentence without its client (R.364):** every one names psql or `JdbcTemplate`.
- **A page fetched over HTTP:** only the seven (port 20420); every count is the harness's direct call.

## Call-backs, by title (R.224)

- Course 7's *@OneToMany/@ManyToOne and the Owning Side* — the contrast: there the pause's `customer` field was the owning side that
  wrote the foreign key and the list was the inverse side, `mappedBy`, read through it and never written, and here, unlike in
  *@OneToMany/@ManyToOne and the Owning Side*, there is no `mappedBy` and no inverse side — the root owns the collection and writes
  every row of it on every save (`same`).
- Course 8's *Aggregates, Not Entities* — the aggregate, glossed there in Course 7's words and called back here by title only (R.68).
- Forward, by title only: *JPA vs JDBC vs Plain SQL* (U06's exercise switches single-query loading on for `findAll()` on PostgreSQL), *Testing the JDBC Layer* (U07).

## The commands this unit adds

- The harness: `javac -parameters -d .harness/hc -cp "<anchor's jar>:<its lib/*>:$DSP" harness/src/probe/u03/*.java`, then
  `java -cp "../hc:../$HT/<jar>:../$HT/<lib/*>:$DSP" probe.u03.U3 <steps>` from `.harness/run` — `$HT` is `after` (anchor/'s copy) or
  `noid` (the copy) — with `--logging.config=../../harness/logback.xml` (JdbcTemplate at DEBUG) and, on PostgreSQL,
  `--tiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:20421/<db>?user=tiffinbox`; `-Du03.sq=true` switches single-query loading on (the `load` capture's second JVM, `findAll()` and the others, PostgreSQL and H2). Steps: `seed`,
  `ids`, `reinsert`, `same`, `load`, `read`, `ref`. `$DSP` is datasource-proxy 1.11.1 in `.m2-demo` — on the harness's class path only;
  no harness POM (unit 02's form).
- The container: `docker -H "$DH" run -d --pull never --name c8u03-pg -p 127.0.0.1:20421:5432 -e POSTGRES_USER=tiffinbox -e POSTGRES_HOST_AUTH_METHOD=trust postgres@sha256:77f58511…`
  — trust on loopback, as unit 01 and the probe did; no password anywhere. Removed with `docker -H "$DH" rm -fv`.
- The PostgreSQL driver is the anchor jar's own (`postgresql-42.7.14.jar` in its `lib/`); the harness adds none.

## The repository, and the network

`.m2-demo` is a copy of `spring-data-beyond-jpa/_research/m2-seed-c8-s1/` (6,966 files, `cp -c -R`). Every Maven run is `mvn -o` with
`-Dmaven.repo.local=.m2-demo`; each log is checked for `Downloading from` / `Downloaded from` lines (0, else the run stops). No image
pull, no metadata read, no `git fetch`: `origin/main...main` was read from the local tracking ref. The one network act is the final
`git push`.

## The folders, the harness and the ports

- `harness/src/probe/u03/U3.java` (the steps), `Witness.java` (unit 02's witness, its package line alone changed — the receipt diffs
  it), `SingleQuery.java` (the single-query switch, off unless `-Du03.sq=true`), `PauseRef.java` (the `AggregateReference` sketch);
  `harness/chk03.py` (the checks), `harness/s803.py` (the prose gate, its own self-test), `harness/dur8.py` (the builders', as unit 02
  shipped it, `cmp`-checked), `harness/tree03.py` (unit 01's tree01.py method), `harness/logback.xml` (unit 02's, JdbcTemplate's
  logger at DEBUG).
- `exercise/Ex03.java`, `exercise/README.md`, `exercise/SOLUTION.md`; `receipts.sh`, `receipts.md5`.
- Ports, 20420-20429: **20420** TiffinBox for the seven only · **20421** the container · **20422** (the noid copy) and **20423**
  (the `load` capture's second JVM, `findAll()` with the switch on, PostgreSQL and H2) never bound — the harness has no web server · **20424-20429** spare, never bound. 18425 and 8080 (the
  anchor's own defaults) are checked free at start and end. All free at start and end (`lsof`).

## Masks, filters and hygiene — every one, declared

- Captures print selected lines only: each harness JVM's `PROBE` lines, its two `Found … repository interface` lines, Flyway's
  `Database:` line and `HHH000001`; each window's `JdbcTemplate` DEBUG lines (`Executing prepared SQL statement [...]`,
  `Executing SQL batch update [...]`), sorted with their counts; psql's read-backs; the seven's response lines (each `"timestamp"`
  value masked); the exercise's own `EX` lines.
- The mask (self-tested at the start with a planted `Started … in 3.1 seconds (process running for 4.2)`, a `Time elapsed:` line, a
  scan line, a Flyway execution time and the folders — dur8 must find nothing in the masked text, R.366): the unit's folder → `…`, the
  repository → `…/..`, home → `~`, Boot's started-in, Surefire's elapsed, Flyway's execution time, Spring Data's scan time, Maven's total
  → `<t>`, identity hashes → `@…`.
- Hygiene, every capture: no absolute path, no unmasked time, no log time, no stack frame, the shutdown token absent; every `java`/`mvn`
  line under its alarm; no H2 file outside `.harness`.

## The ledger rows this unit pays

Nothing on the ledger (the brief); the roadmap line `:329` — "delete-and-reinsert behaviour shown in the SQL log" — is the `reinsert`
and `same` captures, with the ids by psql beside them (`the rows are recreated with new ids` would be false: S8.14).

## RE-MEASURE — the brief's items this unit settles

- **7 (`AggregateReference`):** captured on both databases (`ref`); the beat stands, as measured, with its caveat.
- **8 (the missing back-reference column on PostgreSQL):** `ERROR: column pause.customer does not exist` (`noid`), H2's unchanged.
- **9 (the exercise):** broken counts the SELECTs and prints zero; solved prints the witness's count, equal to `same`'s H2 window.
- **16 (the seven, every unit):** `anchor/` on H2, = `c7-unit31`'s `S466` (`seven`).

## What differed from the brief

- **The batch line.** The brief says "INSERT (with id)"; `JdbcTemplate`'s DEBUG log shows that INSERT as `Executing SQL batch update`
  AND `Executing prepared SQL statement` — Spring Data JDBC sends the elements that carry ids as a JDBC batch. The count is the
  witness's prepares (one for that INSERT); the log's prepared-statement lines equal it. A script that reads the log aloud says one
  INSERT with the old id, not two.
- **`same` on a fresh database, not after `reinsert`.** The unchanged save is measured on Sunil with his one pause (and Ravi with
  none), so each INSERT is one row. After the add, Sunil's two pauses would both carry ids and go as one batch (one prepare, two rows):
  not measured as a capture, not to be said.
- **The identity, PostgreSQL only.** psql reads `pg_sequences` (`pause_id_seq`'s `last_value`, named, not `currval`); on H2 the new
  pause's id is read by `JdbcTemplate` and is the same value, but H2's identity state is not read.
- **The load windows exclude the id lookups:** Sunil's id and the id list for `findAllById` are read by `JdbcTemplate` before each
  window opens (BLUE's first run counted the lookup inside; this harness never does).
- **Single-query loading is a harness switch, not a tree copy:** `SingleQuery` is a harness `@Configuration` added to the
  `SpringApplication`'s sources, active only with `-Du03.sq=true` (for `findAll()` and the others, on PostgreSQL and H2); it is BLUE's sketch's post-processor with the flag alone. Port 20423
  (the brief's "single-query copy") is never bound.
- **The seven** is added (RE-MEASURE 16 says every unit): unit 01 did not run it; it runs here on H2 only (unit 02 ran it on
  PostgreSQL too, on the same tree).
- **The exercise needs the witness's library:** `Ex03.java` carries its own datasource-proxy listener (the class path names
  `.m2-demo`'s jar), so a viewer needs this unit's `.m2-demo` and one receipt run first.

## Runs of record

On the script as committed (`md5 -q receipts.sh` in the block), each run of record must end exit 0 with every capture 3/3 and
`= published`, every Maven run `offline: yes`, volumes and images unchanged, nothing listening on 20420-20429 at the end; each run's
log goes through `~/.venvs/slides2video/bin/python ~/Desktop/PromptVidya-Automation/check_unit8.py 03 --runlog <log>` (R.352; R.166's
grep errors only — the unit gate itself waits for a script). The three: `./receipts.sh` (the shebang's `/bin/bash`, 3.2.57),
`bash receipts.sh` (Homebrew's bash, 5.3.9), and a sealed fresh clone — `git clone file://…` of this repository with this unit's
commit, into a path with a space, `.m2-demo` copied from the seed, `DOCKER_CONFIG=$HOME/.docker`, `http_proxy`/`https_proxy` pointed
at a dead `127.0.0.1:9`.

```
receipts.sh md5 2e849186d9dc33464da300f9c7953e49
./receipts.sh        /bin/bash 3.2.57             exit 0   wall clock 247 s   check_unit8.py 03 --runlog: PASS
bash receipts.sh     /opt/homebrew/bin/bash 5.3.9 exit 0   wall clock 255 s   check_unit8.py 03 --runlog: PASS
sealed clone         git clone file://… (this unit's commit) into "…/scratchpad/ev03/clone dir/tiffinbox-java" (a path with a space),
                     .m2-demo from the seed, DOCKER_CONFIG=$HOME/.docker, http(s)_proxy at 127.0.0.1:9 (dead):
                     ./receipts.sh exit 0   wall clock 252 s   check_unit8.py 03 --runlog: PASS
```

Each: all seven captures `= published`, `offline: yes` (two builds, `Downloaded from` 0), volumes 315 → 315, images 6 unchanged, the
anchor's pin equal at start and end, nothing listening on 20420-20429 at the end. One more full pass ran by accident (the first
mid-build SIGINT below fired before the receipt could take the signal): exit 0, every capture `= published`. The clone was made
from a local commit of this folder before this section was written; the push carries that commit amended with this README's runs,
interrupts and plants (the script and every capture unchanged — `md5 -q receipts.sh` above).

## Interrupted

SIGINT (`kill -INT` on the receipt's own pid, started with SIGINT at its default, as a terminal's Ctrl-C reaches it) at three points —
mid-build (an offline Maven build of a copy), mid-harness (a harness JVM running, the container up), mid-container (after `docker run`,
before the first harness JVM). After each: the exit, the container, the volume count, the listeners on 20420-20429, our JVMs and Maven,
partial `.r-*.[123]` files, `.r-lock`, and the published captures' md5s.

```
SIGINT mid-build      exit 130 · container 0 · volumes 315 · listeners 20420-20429 0 · our JVMs/Maven 0 · partial .r-*.[123] 0 · .r-lock gone · captures (= published): = = = = = = =
SIGINT mid-container  exit 130 · container 0 · volumes 315 · listeners 20420-20429 0 · our JVMs/Maven 0 · partial .r-*.[123] 0 · .r-lock gone · captures (= published): = = = = = = =
SIGINT mid-harness    exit 130 · container 0 · volumes 315 · listeners 20420-20429 0 · our JVMs/Maven 0 · partial .r-*.[123] 0 · .r-lock gone · captures (= published): = = = = = = =
```

The receipt was started through `perl -e '$SIG{INT} = "DEFAULT"; exec @ARGV'` (a background job of a non-interactive shell starts
with SIGINT ignored). Mid-build fired when Maven was running on anchor/'s copy; mid-container when the container existed and no
harness JVM had started; mid-harness while a `probe.u03.U3` JVM ran. A first mid-build attempt fired on the previous run's build log
before the receipt had started (the signal reached perl before its `DEFAULT`): the receipt ran to its end, exit 0, every capture
`= published` — the trigger now waits for Maven itself.

## Planted faults — each caught (R.65, R.226)

On a scratch mirror (this folder copied, its siblings `c8-unit02`, `c8-tiffinbox`, `c5-unit11`, `c7-unit31` linked read-only), one
plant at a time, the file restored after each. "Nothing written" = the md5 of every file in the mirror's folder but `.m2-demo`, before
and after the planted run. The brief's 03 list first (S8.14, S8.26, S8.16, the `noid` check), then the carried set.
Plants 1-14 stop `./receipts.sh` in its gates, before any write (nothing written: yes); plants 15-18 run `harness/chk03.py` on a doctored copy
of a capture; plants 19-20 need the captures, so the mirror's receipt ran its seven captures (each `= published`) and stopped at the
check after them, exit 1, nothing in the mirror's README or exercise changed.

```
plant  1 "new ids" in a SAY line (S8.14)                                exit 1 · nothing written: yes · S8.14: the ids survive - "new ids"
plant  2 "single-query loading changes nothing" in a SAY line (S8.26)   exit 1 · nothing written: yes · S8.26/R.368: "single-query loading changes nothing"
plant  3 the INSERTs' order compared (S8.16)                            exit 1 · nothing written: yes · S8.16: the INSERTs' order voiced: the first INSERT
plant  4 a wrong hash (the anchor's tree pin)                           exit 1 · nothing written: yes · R.211: anchor/'s tree is …, the pin in receipts.md5 is … - the tree moved
plant  5 a placeholder in the exercise                                  exit 1 · nothing written: yes · a placeholder in this unit's prose: exercise/README.md:44: (the planted to-do line)
plant  6 a dish name                                                    exit 1 · nothing written: yes · an Indian dish name (R.215: English names only)
plant  7 "faster" (dur8)                                                exit 1 · nothing written: yes · dur8: faster
plant  8 a version sentence without its client (R.364)                  exit 1 · nothing written: yes · R.364: a version sentence without its read-back client
plant  9 a typed count (R.302)                                          exit 1 · nothing written: yes · R.302: a capture's number typed in prose
plant 10 the exercise's solution = broken (R.196)                       exit 1 · nothing written: yes · R.196: SOLUTION.md's block must be the README's with one line changed (it is 0 lines apart)
plant 11 the container removed without -v (R.322)                       exit 1 · nothing written: yes · R.322: receipts.sh removes a container without its volume (rm -fv)
plant 12 the docker CLI unpinned, DOCKER_HOST=tcp://127.0.0.1:1 (R.344) exit 1 · nothing written: yes · R.344: dk() must name the pinned socket (docker -H "$DH")
plant 13 the anchor link pointed at c8-tiffinbox                        exit 1 · nothing written: yes · anchor must be a link to ../c8-unit02/after (it points at: ../c8-tiffinbox)
plant 14 the witness changed beyond its package line (R.357)            exit 1 · nothing written: yes · R.357: … must be unit 02's witness with its package line alone changed
plant 15 idColumn removed and the run still green (the noid check)      exit 1 · FAIL H2, the copy: findAll() refused - BadSqlGrammarException and its cause
plant 16 no HHH000001 in one JVM's log                                  exit 1 · FAIL reinsert: HHH000001 in every JVM's log
plant 17 an id re-numbered in psql's after line (S8.14)                 exit 1 · FAIL PostgreSQL: every pause id before is there after, with its days - the ids survive
plant 18 single-query loading claimed on H2 (findAll() 1 with the flag) exit 1 · FAIL H2 2.5.250, load findAll(): the witness 1 = JdbcTemplate's DEBUG statements 41
plant 19 a typed SQL line in a README text block (R.302)                exit 1 · R.302: README.md's text blocks must be lines the runs printed - not printed: …
plant 20 a changed What-it-prints line (exercise/SOLUTION.md)           exit 1 · exercise/SOLUTION.md's "What it prints" block is not what its lines printed
plants: 20 · caught: 20
```

## For RED

- **The INSERT with the old id is one prepare and two log lines** (batch + statement): check that the script counts the witness and
  does not read the log's lines as statements.
- **`same` is a fresh database** (Sunil's one pause); the "after the add" unchanged save (two pauses, one batch) is unmeasured.
- **Single-query loading:** each number is its window's — on PostgreSQL `findById`, `findAll()` and `findAllById` change, `findAll(Sort)`
  does not, and on H2 no read does. The anchor stays off; U06 uses it.
- **`ref` is a sketch over the table `CustomerRow` owns** — its insert lands in Ravi's aggregate (the capture says so). If the script
  keeps the beat, it says the reference holds an id and reads no customer, and does not suggest mapping a pause both ways.
- **`noid` on PostgreSQL** is the first capture of that text; H2's is the probe's, unchanged by Q.
- **Not measured here:** the two-pause unchanged save, H2's identity state, JDBC auditing (unit 02's), a page over HTTP beyond the seven.
