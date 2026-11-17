# c7-unit37 — Liquibase, and Choosing

Course 7, Section 6's third unit to be built (batch 3 of the brief's evidence batches), and **a harness unit with no anchor change**
(brief flag 5): `anchor` is the link to `../c7-unit36/after`, the tree the previous lesson, *Flyway: Versioned Migrations*, left — today
the same as `../c7-tiffinbox` — its tree's hash pinned. TiffinBox keeps Flyway. Liquibase keeps the same schema as a **changelog** — one
file of **changesets**, each a piece of the schema with an id and an author, run once and recorded — and this unit restates the anchor's
V1 and V2 as a changelog (`harness/db/changelog/`, in SQL, YAML and XML), runs it with Liquibase in the harness's JVMs, and measures what
*Flyway: Versioned Migrations* measured for Flyway: what it adds to the database, what a failure leaves, what an edited file does, what a killed
start leaves, what a rollback does, what identifies an applied script — and what it does on the network at start. Then the table that
chooses, every cell a line the runs printed. Both databases: PostgreSQL 18.6 in one container per run (the pinned image, a fresh
database per JVM, dropped after it) and H2 2.5.250 on an H2 server over TCP, plus H2 in a JVM's own memory for the exercise. TiffinBox
itself is never started: every JVM is the harness's, over the anchor's libraries + the harness's Liquibase jars (+ the harness's driver
on PostgreSQL). This unit runs no tests. The anchor moves next in unit 38 (C2).

Seven captures, each run in three passes by `receipts.sh` and hashed (`receipts.md5`); every number and string below is asserted right
after its capture by `harness/chk37.py`, against another witness of the same run — the tables read by a second connection (psql in the
container, H2's `Shell` over TCP) beside Liquibase's and Flyway's own lines, the changelog files themselves and the trap's log — never
against a typed figure.

<!-- runs: begin -->
**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`, `DOCKER_CONFIG=$HOME/.docker`),
`.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s6/` alone (a copy, whole), the image `postgres@sha256:77f58511…`
present (`docker -H "$DH" image inspect`, the full digest), one container per run, removed with its volume at its end. Development runs
fixed the captures and the checks; the published hashes are the development passes', and every run of record matched them. **The runs
of record, on the script as committed (`receipts.sh` md5 printed by `md5 -q` and named in the commit message):** 296 s under
`./receipts.sh` (/bin/bash 3.2.57, 2026-11-17 from 04:18 CET), 297 s under `bash receipts.sh` (Homebrew bash 5.3.9, from 04:24 CET) and
297 s from a sealed fresh clone (below, from 04:29 CET): each exit status success, every capture 3/3 = published, every check passed, the
one Maven run `offline: yes` with no `Downloaded from` line, `anchor/`'s tree pinned at the start and the end, the R.211 diff empty at both,
every database dropped, the trap's lines counted per JVM (the labelled default run's alone), the container removed with its volume (the
volume count the same at the start and the end of each run), the images unchanged, nothing listening on 20160-20169 at the end; each
terminal log through `check_unit7.py 37 --runlog` — `RESULT (run logs): PASS` (the unit gate: no 37 script yet). An earlier run under
/bin/bash 3.2.57 was set aside: bash 3.2 reports a killed job on stderr with its pid, and `lock`'s three passes drifted on that line —
the two `killb` calls now keep their stderr out of the capture (under bash 5.3.9 the line never printed). **Nothing was downloaded.**

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at `b0272ec` into a path **with a space** (`…/sealed
37/tiffinbox-java`, in the session's scratch folder), this commit's files put in as git will take them (`git ls-files -o
--exclude-standard c7-unit37`, the link kept); the clone's `.m2-demo` a file copy of the seed; dead proxies for http and https in its
environment (`127.0.0.1:9`); `DOCKER_CONFIG=$HOME/.docker` in its `env -i`; `./receipts.sh`. The roadmap is not beside the clone, so its
line printed the note there (read in the other two runs: line 315). The three runs ran on this README before this paragraph, the
interrupt paragraph and the plants table were written (the only changes since; the prose gate re-run on the final text refused none, and
a fourth full run on the final files passed — exit 0, every capture = published).
<!-- runs: end -->

Published hashes (`receipts.md5`, every capture 3/3 in every run):

```
formats 7d303a527d5fec89223cc4114edead82
analytics 442f32cc06f8d5ebf25da5fc06bb8ae6
lock 7df8056bb3094ca479da86508e86cf58
fail 5c987039175f3a98d8c5a42c34878592
compare 62f0100c6186d2f175c80b079aeae5de
xcheck f9e6360833e6d8ea499aa4e2199e9ca8
exercise ea72c930c1ef9ddad3d2226675c15a51
```

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line):

<!-- values: begin -->
the values the video may say: on PostgreSQL 18.6 (+ the harness's driver) and H2 2.5.250, Spring Boot 4.1.2, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final, Liquibase 5.0.4 (+ the harness's Liquibase jars), Flyway 12.4.0 (the anchor's), tests run: 0 - formats: the changelog's lines SQL 29 · YAML 38 · XML 30 (Flyway's V1 + V2: 15 + 7 = 22) · each format: Run: 2 · Previously run: 0 · Total change sets: 2 · Rows affected: 6 · customers 4 · pauses 2 · databasechangelog 2 rows · databasechangeloglock 1 row unlocked · validate passes · 0 WARN · checksums YAML = XML, SQL its own · analytics: the trap's request lines: no key 1 (CONNECT config.liquibase.com:443, answered 403, nothing forwarded; the migration still ran, Run: 2) · spring.liquibase.analytics-enabled=false 0 · Flyway 0 · lock: B: kill -9 while changeset 3 ran (exit 137) -> databasechangeloglock locked=t, lockedby <host> (<ip>), databasechangelog rows 1-2; the sleeping backend 1 terminated -> the next start (wait 0): LockException: Could not acquire change log lock, exit 1 · A: listLocks() 1, forceReleaseLocks() -> locked=f -> Run: 1 · Previously run: 2 · A' the same · the lock wait: a configured wait, 5 by default (liquibase.changelogLockWaitTimeInMinutes) · Boot's Liquibase keys 26, release keys 0 · fail: a failed changeset on PostgreSQL: Migration failed ... syntax error at or near "VARCHAR", no row for it, phone absent, unlocked · on H2: Unknown data type: "EMAIL", no row for it, PHONE present, the next start Duplicate column name "PHONE" · the path: file: rows named by the path, the moved copy -> relation "customer" already exists · rollback wrong: done, 2 rows, customers 4 · rollback right: 1 row, customers 0 · pauses 0 · the checksum: 1 changesets check sum, was 9:0d69134f1b2cd2dd6146e3fa01fa51ef but is now 9:188eb4eaa9e4b2b15b5e8f0256268514 · both: Liquibase Run: 2, then Flyway's non-empty schema refusal · undo(): Flyway Redgate Edition Required · compare: the comparison: 12 rows, every cell a printed line · xcheck: xcheck: Hibernate's DDL script over the anchor's libraries md5 7f6942f0ed8bf296d661f629557f26c6 = the Flyway lesson's xcheck.sql, diff 0 lines · exercise: exercise: H2 in memory, one JVM - broken: the lock row set by SQL, update refused (Could not acquire change log lock); solved: forceReleaseLocks() then update, Run: 2, diner rows 3; the spoken line 25 words
<!-- values: end -->

## The anchor, and the trap

`anchor` is `../c7-unit36/after` (a link; `readlink` asserted), its tree pinned by `harness/tree37.py` (unit 33's `tree33.py`, byte for
byte) at the file count and hash the receipt prints at its start and its end. The R.211 diff `diff -rq -x .m2-demo -x target -x secrets
-x .harness anchor/ ../c7-tiffinbox` runs at both ends: empty today, so the receipt says `anchor/ = ../c7-tiffinbox`; from a later anchor
change on (unit 38's C2 is next) it prints a note and goes on — the pin is the guard, the note is information. The anchor's own YAML
(R.330): the receipt reads `ddl-auto` off `anchor/tiffinbox-web/src/main/resources/application.yaml` — `validate` — and gives every
harness JVM that value (the harness's class path holds the anchor's libraries, not its web module's YAML).

**The trap (R.317, contract §1: a demo never calls the network).** `harness/trap.py` listens on `127.0.0.1:20166` alone for the whole
run. Every harness JVM is started with the trap as its HTTP and HTTPS proxy (`-Dhttp.proxyHost=127.0.0.1 -Dhttp.proxyPort=20166
-Dhttps.proxyHost=127.0.0.1 -Dhttps.proxyPort=20166`, in the JVM line below). For each connection the trap writes the request's first
line to its log, answers `403 Forbidden` and closes: **it forwards nothing** — no byte a JVM sends it leaves the machine. The receipt
writes a marker line into the same log before and after each JVM and counts the lines between them; every JVM's count is asserted empty,
except the one labelled default run of `analytics`, which carries no analytics setting and whose one line is the filed step (R.303).
Every other Liquibase JVM carries `--spring.liquibase.analytics-enabled=false` (Boot's key) or, in the API's JVMs,
`-Dliquibase.analytics.enabled=false`, and the receipt refuses a Liquibase JVM without it before reading its log.

## The captures — what each one shows

### formats — the changelog in three formats (PostgreSQL)

V1 + V2 as one changelog with two changesets: `tiffinbox:1` (the two tables and the index — V1's statements, byte for byte, the receipt
compares them) and `tiffinbox:2` (the four customers and the two pauses — V2's). Each format its own JVM on a fresh database, Liquibase
on, the anchor's Flyway off (`--spring.flyway.enabled=false`: Liquibase's tables are the only migration tables in these runs),
`ddl-auto validate`. The files' lines (`wc -l`, Flyway's two files beside them):

```text
the files (wc -l): changelog.sql 29 · changelog.yaml 38 · changelog.xml 30 · Flyway's two files in the anchor (wc -l): V1__customer_and_pause.sql 15 · V2__seed.sql 7 · total 22
```

Each of the three printed the same summary and the same second-connection reads (SQL's shown; `chk37.py` asserts each format):

```text
INFO [main] liquibase.util : UPDATE SUMMARY
INFO [main] liquibase.util : Run: 2
INFO [main] liquibase.util : Previously run: 0
INFO [main] liquibase.util : Total change sets: 2
INFO [main] liquibase.ui : Liquibase: Update has been successful. Rows affected: 6
PROBE emf hibernate.hbm2ddl.auto = validate
```

```text
customer, databasechangelog, databasechangeloglock, pause
customers 4 · pauses 2
1|tiffinbox|db/changelog/changelog.sql|1|EXECUTED|9:0d69134f1b2cd2dd6146e3fa01fa51ef|sql
2|tiffinbox|db/changelog/changelog.sql|2|EXECUTED|9:9b378d121e3e13eb586e0bcb29758696|sql
1|f|f|
databasechangelog: id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, comments, tag, liquibase, contexts, labels, deployment_id
databasechangeloglock: id, locked, lockgranted, lockedby
```

`Rows affected` is the rows the second connection counts, and `databasechangelog` holds one row per changeset run, named by its file's
name on the class path (R.328). Liquibase adds **two tables** — `databasechangelog` (the history) and `databasechangeloglock` (one row,
the lock that keeps two starts from migrating together). The two changesets' checksums, per format — the YAML and XML forms describe the
same changes and get the same checksums; the SQL form gets its own:

```text
sql: 9:0d69134f1b2cd2dd6146e3fa01fa51ef 9:9b378d121e3e13eb586e0bcb29758696
yaml: 9:7baf353839a2bb8b7a3f50c900b78965 9:4812576fb6a0aa669e2888cdd054f3b9
xml: 9:7baf353839a2bb8b7a3f50c900b78965 9:4812576fb6a0aa669e2888cdd054f3b9
```

The jars: the anchor's `lib/` holds Flyway's and no Liquibase jar and no PostgreSQL driver (asserted — R.335), so every Liquibase JVM here
runs + the harness's Liquibase jars, linked from `.m2-demo` (the set `liquibase-core` needs, printed by `ls` in the receipt's log); the
YAML changelog needs no jar of its own — the anchor's `lib/` already holds Boot's snakeyaml, and the harness's set holds no YAML jar
(both asserted).

### analytics — the network at start (R.317, the hook)

Three labelled JVMs on fresh PostgreSQL databases, each behind the trap. Boot's key, read off `spring-boot-liquibase`'s own metadata:

```text
"name": "spring.liquibase.analytics-enabled"
"description": "Whether to send product usage data and analytics to Liquibase."
```

The labelled default run — Liquibase with no analytics setting — and what the trap logged during it (the time masked):

```text
<time> CONNECT config.liquibase.com:443 HTTP/1.1
```

Liquibase 5.0.4 asked for `config.liquibase.com` on port 443 at start — its analytics settings, fetched over HTTPS; nothing in its log
says so. The trap answered 403 and forwarded nothing, and the migration still ran. The same run with Boot's key, and a Flyway JVM (the
anchor's libraries alone, no Liquibase jar, its Flyway on):

```text
the three, side by side - the trap's request lines: default 1 · the key 0 · Flyway 0
```

### lock — the failure receipt (B, A, A′; PostgreSQL)

**B:** the `lock/` changelog — `changelog.sql` + a changeset 3 that sleeps in the server. The receipt kills the JVM (`kill -9`) once its
log shows changeset 3 running; the JVM's alarm is not what stops it. The second connection, after the kill:

```text
INFO [main] liquibase.ui : Running Changeset: db/changelog/changelog.sql::3::tiffinbox
exit 137 · WARN lines: 0 · the trap's request lines during this JVM: 0
1|t|t|<host> (<ip>)
```

The lock row stays locked (`lockedby` is the host's name and address — masked), and the first two changesets are recorded. The killed JVM's
statement lives on in the server until its sleep ends (the brief's hazard) — the receipt finds it in `pg_stat_activity` and terminates it
before the next step:

```text
1 backend(s) running pg_sleep
1 terminated
0 backend(s) running pg_sleep
```

The next start, with the lock wait set by its system property (`-Dliquibase.changelogLockWaitTimeInMinutes=0`), is refused — a filed
step (R.303):

```text
PROBE cause: liquibase.exception.LockException: Could not acquire change log lock. Currently locked by <host> (<ip>) since <time>
```

The wait the start would otherwise make is **a configured wait, read off the run** — Liquibase's `GlobalConfiguration`, printed by the
API's JVM with its key; this unit never lives it out (R.310, RE-MEASURE 12):

```text
PROBE lock wait: key liquibase.changelogLockWaitTimeInMinutes · default 5 · this JVM's value 5
```

**A:** Liquibase's Java API (`probe.l.LApi`, the same changelog name on the class path) lists the lock and releases it, the second
connection reads it unlocked, and the next start — the `lockok/` changelog, the same name, its changeset 3 a statement that does nothing
(A does not live out the sleep) — runs the one changeset left:

```text
PROBE locks listed: 1
PROBE forceReleaseLocks(): done
INFO [main] liquibase.util : Run: 1
INFO [main] liquibase.util : Previously run: 2
INFO [main] liquibase.util : Total change sets: 3
```

**A′:** the same — kill, terminate, release, start — on a fresh database: the same lines (asserted). The release is the API's; Boot 4.1
has no key for it. Its Liquibase keys, read off its metadata:

```text
keys: 26 · grep -c release: 0 · grep -c lock: 1
```

### fail — a failed changeset, the path as identity, rollback, the checksum, both tools, undo

**A failed changeset, both databases** (the `fail/` changelog: changeset 3 adds `phone`, then misspells `ADD COLUM email`), beside the
Flyway table of *Flyway: Versioned Migrations* (its capture `fail`):

| | PostgreSQL 18.6 | H2 2.5.250 (over TCP) |
|---|---|---|
| the first start | `syntax error at or near "VARCHAR"` · exit 1 | `Unknown data type: "EMAIL"` · exit 1 |
| `databasechangelog` after it | rows for the first two changesets only | rows for the first two changesets only |
| the column | `phone` absent: changeset 3 rolled back whole | `PHONE` present: half-applied |
| the lock | released | released |
| the next start | — | `Duplicate column name "PHONE"` · exit 1 |
| Flyway (*Flyway: Versioned Migrations*) | rolled back, no history row | a `success=FALSE` history row, `PHONE` present |

```text
PROBE cause: org.postgresql.util.PSQLException: ERROR: syntax error at or near "VARCHAR"
id, name, meals_per_day, price_per_meal, meal_type, version
PROBE cause: org.h2.jdbc.JdbcSQLNonTransientException: Unknown data type: "EMAIL"; SQL statement:
ID, NAME, MEALS_PER_DAY, PRICE_PER_MEAL, MEAL_TYPE, VERSION, PHONE
PROBE cause: org.h2.jdbc.JdbcSQLSyntaxErrorException: Duplicate column name "PHONE"; SQL statement:
```

**Liquibase never records a failed changeset, on either database** — `databasechangelog` has no column for success; on PostgreSQL the
failed changeset is rolled back whole, on H2 its first statement stays (H2 commits each DDL statement). The table shape Liquibase writes
for its lock on H2, read here by the second connection, is the one the exercise makes by hand:

```text
ID INTEGER NOT NULL, LOCKED BOOLEAN NOT NULL, LOCKGRANTED TIMESTAMP, LOCKEDBY CHARACTER VARYING
```

**The path as identity (PostgreSQL)** — the one labelled `file:` run of this unit: the changelog named by a `file:` path, then the same
bytes copied to another folder and started on the same database. The rows are named by the path, so the moved copy is new work:

```text
1|file:../files/changelog.sql
2|file:../files/changelog.sql
PROBE cause: org.postgresql.util.PSQLException: ERROR: relation "customer" already exists
```

**Rollback, wrong and right (R.328).** Boot runs `update` only; a rollback is Liquibase's API. On the labelled `file:` run's database the API is
given the class path's name — it reports `done` and rolls back nothing; the witness is the table, never the command's `done`:

```text
2 rows
customers 4 · pauses 2
PROBE rollback(1): done
```

On a fresh database, Boot and the API both on the class path's name — changeset 2's rollback lines run:

```text
Rolling Back Changeset: db/changelog/changelog.sql::2::tiffinbox
1 rows
customers 0 · pauses 0
```

**The checksum.** `changelog.sql` runs, then `sum/` — the same name, one comment added to changeset 1's index line — and the start is
refused; the old checksum is the one the second connection reads in `databasechangelog`:

```text
PROBE validation: 1 changesets check sum
PROBE validation: db/changelog/changelog.sql::1::tiffinbox was: 9:0d69134f1b2cd2dd6146e3fa01fa51ef but is now: 9:188eb4eaa9e4b2b15b5e8f0256268514
```

**Both tools on one class path** — a fresh database, Liquibase on and the anchor's Flyway on. Neither refuses the other; in this run
Liquibase ran first (its two changesets), then Flyway found a schema it did not make — this run's order, not a rule:

```text
PROBE cause: org.flywaydb.core.api.FlywayException: Found non-empty schema(s) "public" but no schema history table. Use baseline() or set baselineOnMigrate to true to initialize the schema history table.
```

**Flyway Community's undo** — Flyway's own API over the anchor's libraries (`probe.l.FUndo`), a fresh database, `migrate()` then
`undo()` — a labelled step of this receipt (R.303; RED #1806's re-measure was the filed capture until this one):

```text
PROBE migrate(): migrations executed 2
PROBE undo() refused: org.flywaydb.core.internal.license.FlywayRedgateEditionRequiredException: Flyway Redgate Edition Required: undo is not supported by OSS Edition
```

### compare — the table (R.261)

Every cell is a `cell` line the `compare` capture prints, read off this unit's captures (`formats`, `analytics`, `lock`, `fail`) or the
anchor's files; three Flyway cells this unit does not re-run — a failed script on each database and an edited script — are read off the
README text blocks of *Flyway: Versioned Migrations* (its captures `fail` and `traps`, their published hashes printed). The Flyway cells from this
unit's own runs: the pieces and the two files' lines (the anchor's files), the tables and the history rows (`analytics`' Flyway JVM),
the network (the same JVM), undo (`fail`'s `undo` JVM), and both on one class path. `receipts.sh` builds the table below from the cell
lines and compares it with this block, line for line:

<!-- compare table: begin -->
| | Flyway 12.4.0 | Liquibase 5.0.4 |
|---|---|---|
| Boot 4.1 pieces | flyway-core + flyway-database-postgresql + spring-boot-flyway (in the anchor's lib/) | commons-collections4 + commons-io + commons-lang3 + commons-text + liquibase-core + opencsv + spring-boot-liquibase (the harness's) |
| files · lines | 2 files · 22 lines (plain SQL) | 1 file · 29 (SQL) / 38 (YAML) / 30 (XML) lines |
| tables it adds | flyway_schema_history | databasechangelog, databasechangeloglock |
| history rows after V1 + seed | 2 (PostgreSQL) | 2 (PostgreSQL) |
| a failed script on PostgreSQL | failed! Changes successfully rolled back. (the Flyway lesson's fail) | Migration failed for changeset db/changelog/changelog.sql::3::tiffinbox · rows 1,2 · phone absent |
| a failed script on H2 | Detected failed migration to version 3 (add phone) (the Flyway lesson's fail) | Unknown data type: "EMAIL" · rows 1,2 · PHONE present · the next start: Duplicate column name "PHONE" |
| an edited script | Migration checksum mismatch for migration version 1 (the Flyway lesson's traps) | 1 changesets check sum · was: 9:0d69134f1b2cd2dd6146e3fa01fa51ef but is now: 9:188eb4eaa9e4b2b15b5e8f0256268514 |
| a killed run | no lock table (its tables: flyway_schema_history); a killed Flyway start not run here | locked=t after kill -9 · the next start: Could not acquire change log lock · until forceReleaseLocks() |
| undo / rollback | undo(): Flyway Redgate Edition Required: undo is not supported by OSS Edition | rollback(1) by the API: 1 rows · customers 0 · pauses 0 after it; Boot runs update only (Boot's keys: 26 · grep -c release: 0) |
| network at start (the trap) | 0 lines | 1 (CONNECT config.liquibase.com:443) with no key · 0 with spring.liquibase.analytics-enabled=false |
| identity of an applied script | version + checksum (Migration checksum mismatch for version 1) | id + author + filename + md5sum · the same file moved: relation "customer" already exists |
| both on one class path | (one run, both tools) | Liquibase Run: 2 · then Flyway: Found non-empty schema(s) "public" but no schema history table |
<!-- compare table: end -->

**TiffinBox keeps Flyway** (brief flag 5), and the cells that decide it are the lock, the network, the identity and the tables: a
killed Liquibase start leaves its lock row locked and refuses every later start until the lock is released by hand; Liquibase calls
the network at start unless its key says no; a Liquibase changeset is identified by its file's path, so a moved changelog is new work;
and Liquibase adds two tables where Flyway adds one — for a schema Flyway's two plain SQL files already keep. The one row where
Liquibase does what Flyway Community does not is undo / rollback: a rollback through its API, where Flyway's `undo` is refused.

### xcheck — Hibernate's DDL over the anchor (R.252)

Hibernate's script over the anchor's libraries, its Flyway off (`--spring.flyway.enabled=false`), equals the previous lesson's
`xcheck.sql`, byte for byte — the same hash as in the lesson called *Reading the SQL Hibernate Writes*; no mapping moved:

```text
the anchor's md5: 7f6942f0ed8bf296d661f629557f26c6 · the filed xcheck.sql: 7f6942f0ed8bf296d661f629557f26c6 · cmp: the same, byte for byte · the Flyway lesson's xcheck.sql: 7f6942f0ed8bf296d661f629557f26c6 · diff: 0 lines
```

### exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s block, then `exercise/SOLUTION.md`'s, read from the files and run as written in ONE `env -i` shell — bash, then
zsh — each file's "What it prints" compared with the run, line for line. The shell's JVMs run behind the trap (the receipt passes the
trap's proxy options in `JDK_JAVA_OPTIONS`, which the java launcher reads) and the trap's count is asserted empty.

## The version lines (R.222, R.246, R.270, R.329)

Every harness JVM prints Hibernate's, Spring Data JPA's, Spring Framework's and Spring Boot's versions, Liquibase's own version call
(`LiquibaseUtil.getBuildVersion()`) and Flyway's (`VersionPrinter.getVersion()`) before anything starts; `chk37.py` asserts Liquibase's
line in every JVM whose class path holds the harness's Liquibase jars, and its absence in every JVM that holds none, and Flyway's in
every JVM (the anchor's `lib/` holds Flyway's jars in all of them); `HHH000001` in every Boot JVM whose start went on (a killed or refused
start stops before Hibernate starts — its version line is printed first). Boot prints no Liquibase version line of its own.

```text
PROBE version: Hibernate 7.4.13.Final
PROBE version: Spring Data JPA 4.1.2
PROBE version: Spring Framework 7.0.10
PROBE version: Spring Boot 4.1.2
PROBE version: Liquibase 5.0.4
PROBE version: Flyway 12.4.0
INFO [main] org.hibernate.orm.core : HHH000001: Hibernate ORM core version 7.4.13.Final
```

The PostgreSQL driver is the harness's (the anchor's `lib/` holds none, asserted): every PostgreSQL JVM adds
`.m2-demo/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar` — + the harness's driver. Liquibase is the harness's (the anchor's
`lib/` holds no Liquibase jar, asserted): + the harness's Liquibase jars.

## Call-backs, by title (R.224)

- *Flyway: Versioned Migrations* — the previous lesson (registry title, `java7_series.TITLES["36"]`): its tree is this unit's anchor,
  its Flyway table sits beside `fail`'s, and its README's text blocks give the comparison's three Flyway cells this unit does not re-run.
  "A migration and its history table" is that lesson's gloss.
- *Never Use ddl-auto in Production* (`java7_series.TITLES["35"]`) — `validate` beside a migration: every harness JVM here runs
  `ddl-auto validate`, the anchor's value, and it passes after each changelog.
- *Reading the SQL Hibernate Writes* — Hibernate's DDL script, `xcheck`; its hash is the one that lesson filed.
- The roadmap's line for this unit, `_briefs/TRACK-ROADMAP.md` (read with `grep -n`, at its line 315 on this unit's day): "the same
  schema as a changelog; the honest comparison" — the comparison is `compare`'s table.

## The commands this unit adds

Read by `receipts.sh` from this README (each line asserted present, then run):

```bash
javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*:.harness/lq/*" harness/src/probe/l/V.java harness/src/probe/l/Run.java harness/src/probe/l/LMain.java harness/src/probe/l/LApi.java harness/src/probe/l/FUndo.java harness/src/probe/x/XMain.java
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dhttp.proxyHost=127.0.0.1 -Dhttp.proxyPort=20166 -Dhttps.proxyHost=127.0.0.1 -Dhttps.proxyPort=20166 -Dhttp.nonProxyHosts= -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc$CPC:../after/tiffinbox-web/target/extracted/lib/*$CPX" $MC "${A[@]}"
cd .harness/run && exec perl -e 'alarm 3000; exec @ARGV' python3 -I ../../harness/trap.py 20166 ../trap.log
cd .harness/run && exec perl -e 'alarm 3000; exec @ARGV' java -Duser.language=en -Duser.country=US -Dh2.bindAddress=127.0.0.1 -cp "../after/tiffinbox-web/target/extracted/lib/h2-2.5.250.jar" org.h2.tools.Server -tcp -tcpPort 20167 -ifNotExists
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../after/tiffinbox-web/target/extracted/lib/h2-2.5.250.jar" org.h2.tools.Shell -url "jdbc:h2:tcp://127.0.0.1:20167/mem:$DB" -user sa -password '' -sql "$Q"
docker -H "$DH" run -d --pull never --name c7u37-pg -p 127.0.0.1:20168:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v "$U/.harness/secrets/pgpw:/run/pgpw:ro" postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
docker -H "$DH" exec c7u37-pg pg_isready -U sa -h 127.0.0.1 -q
docker -H "$DH" exec c7u37-pg psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c "drop database if exists $DB with (force)" -c "create database $DB"
docker -H "$DH" exec c7u37-pg psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c "drop database $DB with (force)" -c "select coalesce(string_agg(datname, ', ' order by datname), '(none)') from pg_database where datname like 'u37%'"
docker -H "$DH" exec c7u37-pg psql -U sa -d "$DB" -qAt -v ON_ERROR_STOP=1 -c "$Q"
```

## The repository, and the network

Every Maven run is `mvn -o` against this unit's own `.m2-demo`, seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s6/`
alone (brief flag 13: Liquibase's jars, `spring-boot-liquibase`, Flyway's and the PostgreSQL driver are in it). One Maven run: the
anchor's package line, offline, `-DskipTests` — it prints `offline: yes` and its `Downloaded from` count. The harness's Liquibase jars
are links into `.m2-demo`. **No network act:** `docker run --pull never`; the trap forwards nothing; the version sweep is the brief's
(`_research/liquibase-core-metadata-2026-11-16.xml`, `flyway-core-metadata-2026-11-16.xml`, `spring-boot-metadata-2026-11-16.xml`,
`spring-data-bom-metadata-2026-11-16.xml`, `hibernate-core-metadata-2026-11-16.xml`: Liquibase 5.0.4 is the newest on that day; Flyway
12.4.0 is the BOM's, newer ones exist, not adopted).

## The locale

Every JVM runs with `-Duser.language=en -Duser.country=US` (the receipt refuses a capture's JVM line without it), and the harness JVMs
with `-Dstdout.encoding=UTF-8`.

## The folders, the harness and the ports

- `anchor` → `../c7-unit36/after` (a link; its tree hashed and pinned). Never built in place: copied to `.harness/after` and built there.
- `harness/src/probe/l` — `LMain` (the anchor's entities alone and Boot's auto-configuration), `Run` (the context with no web server,
  the EMF's property, `ready`, the causes, Liquibase's validation lines), `V` (the version lines; the PostgreSQL URL built inside the JVM
  from `-Dpg.db` and the password file; Liquibase's own log as one line per record in the API's JVMs), `LApi` (Liquibase's Java API: the
  lock wait's default, `listLocks()`, `forceReleaseLocks()`, `rollback(n, null)` — the changelog by its class-path name,
  `ClassLoaderResourceAccessor`), `FUndo` (Flyway's API: `migrate()`, `undo()`), `ex/Ex` (the exercise, compiled only by its own lines).
  `harness/src/probe/x/XMain.java` is unit 29's. No `Thread.sleep` in `harness/src` (grepped).
- `harness/db/changelog/` — `changelog.sql` (formatted SQL), `changelog.yaml`, `changelog.xml`; the variants `fail/`, `lock/`,
  `lockok/`, `sum/` (each `changelog.sql`, each compared with the base by the receipt); `ex/diner.sql` (the exercise's own). The receipt
  copies each variant to its own class-path folder under `.harness/cp/`, so every one is named `classpath:db/changelog/…` (R.328).
- `harness/trap.py` (the trap), `harness/logback.xml` (one line per event; `liquibase` and `org.flywaydb` INFO, `org.hibernate.SQL`
  DEBUG, the rest WARN), `harness/chk37.py` (the checks), `harness/s37.py` (the prose gate, its self-test first), `harness/tree37.py`
  (unit 33's `tree33.py`, byte for byte), `harness/dur7.py` (the builders' `dur7.py`, byte for byte, untouched).
- **Ports (§P, 20160-20169):** 20166 the trap; 20167 the H2 TCP server; 20168 the container (`docker port` asserted: `127.0.0.1:20168`
  alone); each listener asserted on `127.0.0.1` alone; 20160-20165 and 20169 never bound; the harness JVMs bind none. All ten are asserted
  free at the start and the end.
- **Alarms (R.247):** every harness JVM and every H2 `Shell` `alarm 240` (the killed JVM in `lock` B is stopped by the receipt's
  `kill -9`, long before its alarm); the trap and the H2 server `alarm 3000` (they live for the whole run); the exercise's JVM `alarm 120`.
- **The container:** `c7u37-pg` from the pinned digest, `sa` + a generated password in `.harness/secrets/pgpw` (0600), read by
  `POSTGRES_PASSWORD_FILE` and by the JVMs' `-Dpg.pwfile` (never on a command line, never in a log); every docker call on the pinned
  socket, `docker -H "$DH"` (R.332), the baselines asserted non-empty first; removed with its volume, `rm -fv`, and the volume count
  asserted unchanged (R.322).

## Masks, filters and hygiene — every one, declared

The mask: the password (`<pw>`), this folder (`…`), its parent (`…/..`), the home folder (`~`), the user's name (`<user>`), the host's
name and an address beside it in parentheses — `lockedby`'s form — (`<host> (<ip>)`), the host name and the container's address
wherever else they print, a lock's time (`since <time>`), Liquibase's run times (`ran successfully in <n>ms`), Flyway's execution times
(`(execution time <t>)`), Liquibase's deployment id (`<n>`), the JDK's version, identity hashes (`@…`) — self-tested on planted lines
first. The H2 `Shell`'s own timing (`, <n> ms)`) is cut from its lines. The filter: a JVM's capture shows its `PROBE` lines,
`HHH000001`, Liquibase's and Flyway's own lines (each once, the summary's padding squeezed) and the API's `Rolling Back Changeset`
line; its exit, its WARN count and the trap's count are read off the whole log. Hygiene, asserted over every capture: no absolute path,
no unit number, no log time, no thread number, no OS or JDK version token, no time figure, no stack frame, no password, no URL; no raw
copy of the password, the host name or the container's address; no H2 database file outside `.harness`.

## Interrupted

Ctrl-C at any point: the trap stops what the run started (a JVM, a Maven, the exercise's shell, the trap, the H2 server), sweeps its
process group, removes the container with its volume, drops the unfinished capture passes and exits 130.

Measured on the script as committed: `env -i bash receipts.sh` started as its own process group (SIGINT at its default, as a terminal
leaves it), `.harness` cleared first, and SIGINT sent to the group at six points — **mid-build** (Maven running), **mid-trap** (just
after the trap listened), **mid-H2-server** (just after the server listened), **mid-container** (just after `docker run`), **mid-harness**
(the first harness JVM on PostgreSQL in `formats`) and **mid-`lock` B** (the JVM that is killed, while it ran its changesets): each exit
130, no process of the run left (no JVM, no trap, no H2 server, no Maven), no container `c7u37-pg` (so no sleeping backend), the volume
count the same as before the run, nothing listening on 20160-20169, no `.r-lock`, no unfinished capture pass, the published captures
unchanged. A first set of these interrupts was set aside: a `.harness` left by the run before made the driver fire its point as the
receipt started, before its trap was set (bash ended by the signal itself); with `.harness` cleared the six above ran as planned.

## Exercise

`exercise/README.md` (the spoken line, its word count printed by the receipt, `wc -w`) and `exercise/SOLUTION.md`, on H2 in one JVM's
memory: the lock row a killed start leaves, made by plain SQL in Liquibase's own H2 shape, `update` refused; the solution
`forceReleaseLocks()` then `update`. Both commands carry `-Dliquibase.analytics.enabled=false` — a viewer's exercise never calls the
network either (asserted in both files; the receipt runs them behind the trap, no line caught).

## The ledger rows this unit pays

None (the brief's §LEDGER: 37 pays no row); the comparison is the roadmap's "honest comparison". `PROMISE-LEDGER-2026-11-01.md` not
edited.

## RE-MEASURE — the brief's items this unit settles

- **RE-MEASURE 2** — the exercise's lock on H2: **measured as planned** — the lock row set by plain SQL in the shape Liquibase writes on H2 (read off
  `fail`'s H2 run first), `update` refused with `Could not acquire change log lock`, `forceReleaseLocks()` then `update` runs both
  changesets (`exercise`).
- **RE-MEASURE 12** — Liquibase's lock wait default lived out: **never** — read off `GlobalConfiguration` (`lock`), configured, unvoiced (R.310).
- **RE-MEASURE 13** — the exercise as README + SOLUTION, bash and zsh, `env -i`: `exercise`.

## What differed from the brief

- **Liquibase's jars, named.** The brief left it open whether Boot's auto-configuration needs the starter: it does not —
  `spring-boot-starter-liquibase` holds no class, so the harness's set is `spring-boot-liquibase` + `liquibase-core` + the jars
  `liquibase-core` needs here (`opencsv`, `commons-text`, `commons-collections4`, `commons-lang3`, `commons-io`), the versions the s6
  seed's own build resolved (the probe's set), linked from `.m2-demo`; the receipt prints the set with `ls`.
- **A's changeset 3 is a statement that does nothing.** B runs the `lock/` changelog (changeset 3 sleeps in the server) and is killed;
  A and A′ start on `lockok/` — the same class-path name, the same first two changesets, changeset 3 = a statement that does nothing — so
  no start lives out the sleep (the brief offered either; said here and in the capture).
- **A′ repeats B's kill, the termination, the release and the start on a fresh database**; it does not repeat the refused start (B
  holds it) or the wait's read.
- **The path-identity step names its `file:` changelog relatively** (`file:../files/changelog.sql`, from the JVM's folder): in that labelled step the rows
  record the path as given, `file:../files/changelog.sql`, not an absolute one — what the probe saw as `file:<absolute path>` was the probe's
  absolute argument. The identity trap is the same: the moved copy (`file:../moved/changelog.sql`) is new work. A relative path also keeps
  a folder with a space (the sealed clone's) out of the URL.
- **The wrong rollback names the class path's file, not a relative path.** The brief's "the API given the relative name": the name the
  API is given, `db/changelog/changelog.sql` (the class path's), is the relative one beside the labelled `file:` record — it reports `done`, and the
  table says nothing changed.
- **The trap's count is per JVM, by marker lines in the trap's own log**, and the receipt refuses a Liquibase JVM without its key before
  it reads the count — so the R.317 plant (the key dropped) is caught twice; the plant below names the first.
- **The exercise's JVMs run behind the trap through `JDK_JAVA_OPTIONS`** in the receipt's `env -i` (the viewer's command line stays as
  written; the java launcher reads the variable and says so in the log the block greps away).
- **`HHH000001` is asserted in every Boot JVM whose start went on**; a killed start (B) and a refused one (the lock, the failed
  changesets, the checksum, both tools) stop before Hibernate starts, and their version line (`PROBE version: Hibernate 7.4.13.Final`,
  printed first) is asserted in every JVM.
- **The comparison has a twelfth row**, "both on one class path" (the probe's eleven + the `both` run, one cell for the two tools).
- **The roadmap's line is read when the roadmap is beside the repository** (`../../_briefs/TRACK-ROADMAP.md`; line 315, asserted, in
  the receipt's log — not a capture); a fresh clone elsewhere prints a note instead.
- **Flyway's killed start is not measured** (the brief asks for none): its cell says "no lock table … a killed Flyway start not run
  here" — the cell's first half read off the `analytics` Flyway JVM's tables.

## Planted faults — each caught (R.65, R.226)

Each on a scratch mirror (this unit copied whole, `c7-unit36` and `c7-tiffinbox` copied beside it, `c7-unit29` and `c7-unit33` linked),
one fault planted, `bash receipts.sh` run; each **exit 1, the mirror's files unchanged by the run** (their md5s compared before and
after); the receipt's last line quoted in short. The receipt plants ran on the script before its last edit (the two `killb` lines'
stderr kept out of the capture — no plant touches them); the check plants run `harness/chk37.py` or `harness/s37.py` on a copy of a
capture or of this README.

| plant | caught by |
|---|---|
| the analytics key dropped from `u37akey` (a non-default Liquibase JVM) | R.317: the JVM refused before its log is read — "a Liquibase JVM without spring.liquibase.analytics-enabled=false" |
| the same, with that guard taken out | R.317: "the trap caught … request line(s) during u37akey … CONNECT config.liquibase.com:443" |
| the relative-name rollback read as done (the table's lines after it removed from a copy of `fail`) | `chk37.py fail`: "rollback wrong: the witness (R.328)" |
| the lock released before it is read (`forceReleaseLocks()` run before B's psql read) | `chk37.py lock`: the B check, `locked=f` where `locked=t` is asserted |
| a typed cell in the comparison (one cell's line count edited in a copy of this README) | `chk37.py table`: R.261 |
| a Liquibase JVM without its version line (removed from a copy of `formats`) | `chk37.py formats`: R.329 |
| `HHH000001` removed / Boot's version edited / Framework's version edited (copies of `formats`) | `chk37.py formats`: each its line |
| a check that cannot fail (R.276) — the summary's `Run:` edited in a copy of `formats` | `chk37.py formats`: the Run / Previously run / Total line |
| H2's half-applied column said of PostgreSQL | the prose gate (R.314) |
| the refusal named as the control (R.312's sentence) | the prose gate (R.312) |
| a duration word for the lock wait (R.310's family, two words) | the prose gate (R.310) |
| Liquibase said to be offline, with no key named | the prose gate (R.317) |
| a typed jar count | the prose gate (R.302) |
| a dish name in the exercise | R.215 |
| a placeholder line | the placeholder check |
| a typed SQL string in the prose | the prose gate (R.225) |
| a wrong published hash (`receipts.md5`) | "formats is not the published capture" |
| a byte added to the mirror's `anchor/` | R.211: the tree pin |
| a byte added to the mirror's `c7-tiffinbox` | the R.211 note at both ends — the run went on and passed, exit 0 (a note is information, not a stop) |
| the docker CLI unpinned under an exported `DOCKER_HOST=tcp://127.0.0.1:1` | R.332: the first docker call (`info`) fails before any baseline |
| `docker rm -f` without `-v` (written so the static grep misses it) | R.322: "the volume count moved" at the end (the plant's one anonymous volume, made by that run, removed by hand after it — the count back to its start) |
| `lockedby`'s mask line removed | the mask's self-test (its planted `lockedby` lines) |
| a changed What-it-prints line / the solution's block = the broken one | the receipt's exercise comparisons, run alone on a copy (the step extracted verbatim): each exit 1 |

## CARRIED

- Unit 38 moves the anchor next (C2): from then on this unit's R.211 diff prints its note; the pin keeps this unit on `c7-unit36/after`.
- A killed Flyway start (its lock on PostgreSQL) is not measured here — the comparison says so in its cell; any later unit that voices
  it measures it.
- Liquibase's command line and its Maven build extension (other ways to run a rollback) are not fetched — Course 7 runs the API only.

## For RED

- **The trap's zero is a measured zero, not an assumed one:** the same harness, the same JVM line, the key dropped (the labelled default
  run) gives one line — so the trap sees what a Liquibase JVM sends. It catches only what honours the proxy properties; a client that
  ignores them would go around it. Liquibase 5.0.4's analytics fetch honours them (the default run's line).
- **"Refused until the lock is released"** is said as a state (what the table holds and what the next start does), not as a duration:
  the wait itself is set by its system property and its default is read off `GlobalConfiguration` (R.310); no start was left to live it
  out.
- **The `done` that does nothing** is filed as a labelled step and the witness beside it is the table — two rows, four customers;
  `chk37.py` refuses the rollback claim without the second connection's lines after it.
- **H2's half-applied column is H2's** (one DDL statement committed before the misspelt one); PostgreSQL rolls the changeset back whole.
  Each line names its database; the gate refuses H2's wording on a PostgreSQL sentence.
- **The checksums differ between SQL and YAML/XML** for the same schema — Liquibase checksums the change it parsed, and the formatted
  SQL is one raw statement block where YAML and XML are typed changes. Moving a project between formats is new work to Liquibase. Said
  as read; not voiced as a rule beyond these files.
- **"Liquibase ran first"** in the both-tools run is this run's order (one run per pass, three passes the same), not a rule.
- **Flyway's three cells from *Flyway: Versioned Migrations*** are that lesson's printed lines, read off its README's text blocks (which its own
  receipt checks against its captures), with its published hashes printed beside them — not re-run here.
- **The exercise sets Liquibase's lock row by hand**: the table shape is the one Liquibase wrote on H2 in `fail` (column names, types
  and NOT NULLs, read by the second connection), so the refusal is Liquibase reading its own table, not a harness error.
