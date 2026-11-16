# c7-unit36 — Flyway: Versioned Migrations

Course 7, Section 6's first unit to be built, and **Section 6's first change to the anchor** (brief flag 1, C1, "Flyway, Database
retired"): `before` is the link to `../c7-unit34/after` (its tree's hash pinned), `after/` is this unit's tree, and `../c7-tiffinbox`
equals `after/` from this unit's commit on. A **schema migration** is a numbered SQL file that runs once per database; Flyway records
each one it applies in that database's **history table**, `flyway_schema_history`, and a later start applies only what the table does
not list. TiffinBox's tables and its seed become two migrations, and the class that dropped and re-seeded both tables at every start is
retired. When a migration fails, PostgreSQL rolls it back whole and the history table has no row for it; H2 keeps half of it, records
the failure, and needs the hand cleanup and `repair()` — both measured here. Both databases: PostgreSQL 18.6 in one container per run
(the pinned image, a fresh database per JVM) and H2 2.5.250 (in the harness JVM's memory, or on an H2 server over TCP where a second
connection must read it). 38 moves the anchor next (C2); 35 and 37 are harness units on `../c7-unit34/after` and on this `after/`.

Nine captures, each run in three passes by `receipts.sh` and hashed (`receipts.md5`); every number and string below is asserted right
after its capture by `harness/chk36.py`, against another witness of the same run — the history table read by a second connection (psql
in the container, H2's own Shell over TCP) beside Flyway's own lines — never against a typed figure.

<!-- runs: begin -->
**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`, `DOCKER_CONFIG=$HOME/.docker`),
`.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s6/` alone (6,933 files), the image `postgres@sha256:77f58511…`
present (`docker -H "$DH" image inspect`, the full digest), one container per run, removed with its volume at its end. Development runs
fixed the captures and the checks; the published hashes are the development passes' and every run of record matched them. **The runs
of record, on the script as committed (`receipts.sh` md5 printed by `md5 -q` and named in the commit message):** 377 s under
`./receipts.sh` (/bin/bash 3.2.57, 2026-11-16 from 16:34 CET), 376 s under `bash receipts.sh` (Homebrew bash 5.3.9, from 16:41 CET) and
399 s from a sealed fresh clone (below, from 16:47 CET): each exit 0, all 9 captures 3/3 = published, every check passed, every Maven
run `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`, the anchor's `diff -rq` empty at the start and the end, `before/`'s
tree pinned at both, the container removed with its volume (the volume count the same at the start and the end of each run), the
images unchanged, nothing listening on 20150-20159 at the end; each terminal log through `check_unit7.py 36 --runlog` — `RESULT (run
logs): PASS` (the unit gate: no 36 script yet). **Nothing was downloaded.**

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at `298c26e` into a path **with a space** (`…/sealed
36/tiffinbox-java`, in the session's scratch folder), this commit's files put in as git will take them (`git ls-files -m -o
--exclude-standard c7-unit36 c7-tiffinbox c7-unit34 .gitignore`, links kept: 85 files copied, `Database.java` deleted); the clone's
`.m2-demo` seeded from a file copy of the seed; dead proxies for http and https in its environment (`127.0.0.1:9`);
`DOCKER_CONFIG=$HOME/.docker` and `C7_BUILDERS` (the course's `_builders`, for `guard`) in its `env -i`; `./receipts.sh`. The three
runs ran on this README before this paragraph and the interrupt results were written (the only changes since; the gates were
re-run on the final text: `s36` refused 0, and the interrupt runs passed every start gate on it).
<!-- runs: end -->

Published hashes (`receipts.md5`, every capture 3/3 in every run):

```
guard fc2a4ff65e61aa5296ddc02cd5198be5
jars 78da621a170663ba169ca1f47e4be026
anchor 66b8fb5680a7baf7a854ebb63be99497
fail 7eec7c1db9c224c735dff7e9efdf89d4
traps 7443f48dd32acbadb4b7166d960e9f1c
seven f06e2268adf4a05713f2394de394707c
tests 9050c994f6455a9535f171ac5d6d1e59
xcheck eccd86090d8e43d78bd296cbe3569cf7
exercise 50eb087ce86e2cc3f05f451e2cfcaaad
```

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line; a SQL string typed in
this README outside this block and the blocks the runs printed is refused):

<!-- values: begin -->
the values the video may say: on PostgreSQL 18.6 and H2 2.5.250, Flyway 12.4.0, Spring Boot 4.1.2, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - guard: the four shipped builders (s703, s706, s707, s709) compare after/ with the live anchor behind an existence check: on the moved anchor each runs to exit 0 with the note "c7-tiffinbox's …/Database.java is gone from the live anchor (unit 36 retired it)"; with the guard taken out, FileNotFoundError, four of four · jars: the libraries 94, Flyway's three: flyway-core-12.4.0, flyway-database-postgresql-12.4.0, spring-boot-flyway-4.1.2; (i) without spring-boot-flyway: 0 Flyway lines, exit 0, tables (none), no history table - "Flyway ran" refused, Flyway 12.4.0 still on the class path; (ii) without flyway-database-postgresql: exit 1, FlywayException: Unsupported Database: PostgreSQL 18.6 ← flywayInitializer ← entityManagerFactory; (iii) all three: 8 Flyway lines, every one before HHH000001, the URL's password masked by Flyway (********), Successfully applied 2 migrations … now at version v2, ddl-auto validate passing, the history table by psql 2 rows success t, PostgreSQL names V1's foreign key pause_customer_id_fkey; (iv) on H2: one WARN per start, Using H2 2.5.250 which is newer than the version Flyway has been verified with. The latest verified version of H2 is 2.3.232. · anchor: TiffinBox on PostgreSQL + the harness's driver (after/'s lib/ holds none): B (before/): POST Kavya 201, psql 5 rows; the restart - GET /customers/Kavya 404, 4 customers listed, psql 4 rows (the drop-and-seed: C7-1 cause 2); A (after/): JVM 1 Migrating … "1 - customer and pause", "2 - seed", POST Kavya 201, psql 5 rows, history 2 rows success t; JVM 2 Current version of schema "public": 2 · Schema "public" is up to date. No migration necessary. - GET /customers/Kavya 200, 5 listed, psql 5 rows, history still 2; GET /dashboard 200 with 4 SQL lines (HTML and JSON), the JSON's four keys; A' = A; with --spring.flyway.enabled=false: exit 1, Schema validation: missing table [customer] · fail: a V3 whose second statement is misspelt - on PostgreSQL: Migration of schema "public" to version "3 - add phone" failed! Changes successfully rolled back. · SQL State 42601 · ERROR: syntax error at or near "VARCHAR", exit 1; the history table holds rows 1-2 only, phone absent; run 2 the same; the file fixed: Successfully applied 1 migration … now at version v3, no repair; on H2: … failed! Please restore backups and roll back database and code! · Unknown data type: "EMAIL"; the history table: the -1 << Flyway Schema History table created >> TABLE row and 3 add phone success FALSE, PHONE present; run 2 and the file fixed alone: Validate failed: Migrations have failed validation · Detected failed migration to version 3 (add phone). · Please remove any half-completed changes then run repair to fix the schema history., exit 1; repair() (a FlywayMigrationStrategy bean): Successfully repaired schema history table · Manual cleanup of the remaining effects of the failed migration may still be required. - then Duplicate column name "PHONE", success FALSE again; the column dropped by a second connection + repair(): now at version v3, success TRUE, PHONE and EMAIL · traps: on PostgreSQL: a comment edited in an applied V1 - Migration checksum mismatch for migration version 1, -> Applied to database : 1709288716 (the history table's, by psql) -> Resolved locally : -466835208, exit 1; a schema seeded without Flyway - Found non-empty schema(s) "public" but no schema history table, exit 1; baseline-on-migrate - Successfully baselined schema with version: 1, then V2 fails SQL State 23505 duplicate key value violates unique constraint "customer_name_key", rolled back, the history table: the << Flyway Baseline >> BASELINE row alone; baseline-version 2 - up to date, exit 0; V1_5 added after v2 - Detected resolved migration not applied to database: 1.5., exit 1, with out-of-order=true [out of order], exit 0; clean() - Unable to execute clean as it has been disabled with the 'flyway.cleanDisabled' property. (info: 1 SUCCESS, 2 SUCCESS) · seven: 466c20ed7e0d5439cb052f32ce09de1b on before/ and after/ (H2 over TCP), SQL lines during it 6 on both; after/'s start: 2 Migrating lines, Successfully applied 2 migrations 1, Flyway's H2 WARN 1 · tests: 18 (14/3/1) on after/ from Surefire's reports, offline - a guard, C7-4 re-run; its log: Successfully applied 2 migrations 1, is up to date. No migration necessary 1 (the two contexts share one in-memory database), Flyway's H2 WARN 2 · xcheck: Hibernate's script over after/'s libraries 7f6942f0ed8bf296d661f629557f26c6 = the index lesson's, byte for byte (no mapping moved); R.80, V1 against it: meal_type VARCHAR(10) vs enum ('NON_VEG','VEG','VEGAN'), version DEFAULT 0 vs none, the foreign key unnamed in V1 (PostgreSQL: pause_customer_id_fkey) vs Hibernate's FK<name>, the column order differs; the index and the identity columns agree · exercise: one JVM, H2 in memory, Flyway's API: migrate - success=false for 3, the phone column left; migrate again - Detected failed migration to version 3 (add phone).; the solution: the corrected file, the column dropped, repair() (removed failed 1), migrate() - now at version v3, success=true (18 words)
<!-- values: end -->

### C1 — the change, file by file, and every sentence it rewrote (R.250)

`diff -rq before after` (the `anchor` capture prints it): eleven files changed, one deleted, one folder new.

- `tiffinbox-web/pom.xml` — `spring-boot-starter-flyway` and `flyway-database-postgresql`, both managed by Boot's parent (no version typed;
  the build resolves Flyway 12.4.0 and `spring-boot-flyway` 4.1.2), with a comment saying why each is there; and the unit 03 comment that
  named the `Database` class as the one that opened `DriverManager` connections now says it was retired.
- `tiffinbox-core/src/main/resources/db/migration/V1__customer_and_pause.sql` and `V2__seed.sql` — **new**, derived from `before/`'s
  `Database.java` by `harness/mkv.py` (its CREATE statements dedented, each ended by `;`; its seed's values one INSERT each, the pauses
  by name), never retyped: the receipt runs the script on `before/` and compares its output with both files byte for byte.
- `tiffinbox-core/src/main/java/com/tiffinbox/Database.java` — **deleted**.
- `CustomerRepository.java` — `@DependsOn("database")` and its import removed; the unit 17 Javadoc paragraph rewritten, not deleted:
  "Course 7, unit 36: Flyway creates and seeds the tables before Hibernate starts, so the order needs no annotation and the class is
  retired".
- `application.yaml` — `ddl-auto: validate` with the comment `# validate: Hibernate checks the migrated schema and writes nothing`
  (R.330); its two comments that named `Database` (unit 03's DataSource comment and "Database creates the tables") rewritten.
- `TiffinBoxWebTest.java` — the import gone; `theSliceLeavesTheDatabaseOut` asserts `getBeanNamesForType(DataSource.class)` empty, with a
  Javadoc line saying the class it named is retired (the test keeps its name, its meaning and the count 18).
- `FeedTest.java` — a comment on the shared in-memory database (the hazard below).
- Javadocs: `CustomerEntity` (six mentions), `PauseEntity` (three), `Customer` (one), `TiffinBoxServer` (one), `TiffinBoxApp` (one) — each
  sentence that named `Database` as the schema's or the seed's owner now names V1 or V2 and says the class was retired.
- The anchor README — the header's first sentence about `Database` carries "*Course 7, unit 36: retired*", a unit 36 header note
  ("Section 6's first change to this folder") and a `## Course 7 · unit 36` section. Its older dated sections keep their history.

**The R.250 gate runs before any build** (`python3 -I -B harness/chk36.py r250 after`): every sentence in `after/`'s sources, YAML, POMs,
migrations and tests that names `Database` must say it was retired (two exceptions, named: Flyway's own `Unsupported Database` in the
POM comment, and the test's method name); the README must carry the header note, the retirement note and the section; the YAML's
`ddl-auto` must be `validate` and carry its comment. **No mapping moves in C1:** Hibernate's own script is unit 34's, byte for byte
(`xcheck`), so the anchor README's sentences about its md5 stay true and are not edited. **The JSON dashboard keeps its four keys.**

## Step 36.0 — the four builders' guards (R.331, RED #1800)

Before the anchor commit: `grep -n 'filecmp\|Database.java\|c7-tiffinbox'` over `_builders/s7*.py`, `check_unit7.py` and
`qa_java7.py` — 203 lines, filed with this run's notes (the step's own scratch file); `check_unit7.py` and `qa_java7.py` name none of
the three. The builders that `filecmp` a file against the live anchor: `s703.py:46`, `s706.py:51`, `s707.py:55`, `s709.py:55` (each
lists `Database.java`), `s715.py:52`, `s716.py:57` (they list no file C1 deletes — safe, as the brief says). In the four, the
`filecmp.cmp` now sits behind an existence check — two lines added before it, its `if` become `elif`, every other line byte-equal:

```
    if not os.path.exists(f"{R}/../c7-tiffinbox/{p}"):
        print(f"note: c7-tiffinbox's {p} is gone from the live anchor (unit 36 retired it); after/ is checked against b2e0641")
    elif not filecmp.cmp(f"{A_}/{p}", f"{R}/../c7-tiffinbox/{p}", shallow=False):
```

(`s703.py`'s; `s706.py`, `s707.py` and `s709.py` the same with `{R}/after/{p}` and their pinned commits `f4c3653`, `d84bf1b`, `9853dae`).
`_builders/` is outside this repository: the four edits are committed nowhere; this README and the `guard` capture are their record.
**A tooling edit, not a published-video change:** videos 03, 06, 07 and 09 are built, and the guard changes none of their outputs (on
the unmoved anchor the existence check is always true). **The plant** and **the re-run on the moved anchor** are the `guard` capture
(below): `harness/guard.py` reads each builder's `SRCF` and its comparison loop by `ast` from the shipped file and runs the loop as
shipped — its `git show <sha>` assert included — on the live anchor, then once with the two added lines taken out again.

## The captures — what each one shows

### 1 · guard — step 36.0 on the live anchor

```text
s703.py: the guard - present: lines 46-48 (the existence check, its note, then the filecmp as before)
note: c7-tiffinbox's tiffinbox-core/src/main/java/com/tiffinbox/Database.java is gone from the live anchor (unit 36 retired it); after/ is checked against b2e0641
exit of guard.py: 0
```

Each of the four: the comparison step as shipped exits 0 with the note; with the guard taken out it stops on `FileNotFoundError` for
`c7-tiffinbox/…/Database.java` — the crash RED #1800 named, shown once per builder and never shipped. The capture needs the course's
`_builders` folder beside this repository (or `C7_BUILDERS`); a clone without it skips the capture and says so — it is the author's
tooling, not TiffinBox's.

### 2 · jars — which jars run Flyway in Boot 4.1 (PostgreSQL, then H2)

Four harness JVMs (`probe.f.FMain`, `probe.f0.F0Main`: TiffinBox's two entities, no web server), each printing Flyway's own
`VersionPrinter.getVersion()` (R.329) beside Hibernate's, Spring Data's, Spring Framework's and Boot's version lines:

```text
(i) flyway-core and flyway-database-postgresql WITHOUT spring-boot-flyway (Boot's Flyway module) - a labelled run, PostgreSQL:
PROBE version: Flyway 12.4.0
exit 0 · its WARN lines: 2 · its org.flywaydb lines: 0
(none)
the history check (R.313): 1 refusal - no flyway_schema_history: "Flyway ran" is refused for this run
PROBE cause: org.flywaydb.core.api.FlywayException: Unsupported Database: PostgreSQL 18.6
INFO  [main] org.flywaydb.core.FlywayExecutor : Database: jdbc:postgresql://127.0.0.1:20158/u36j3?user=sa&password=******** (PostgreSQL 18.6)
INFO  [main] org.flywaydb.core.internal.command.DbMigrate : Migrating schema "public" to version "1 - customer and pause"
INFO  [main] org.flywaydb.core.internal.command.DbMigrate : Migrating schema "public" to version "2 - seed"
INFO  [main] org.flywaydb.core.internal.command.DbMigrate : Successfully applied 2 migrations to schema "public", now at version v2 (execution time <t>)
PROBE emf hibernate.hbm2ddl.auto = validate
pause_customer_id_fkey
WARN  [main] org.flywaydb.core.internal.database.base.Database : Using H2 2.5.250 which is newer than the version Flyway has been verified with. The latest verified version of H2 is 2.3.232.
```

(i) is R.313's plant as a labelled run: `flyway-core` on the class path, nothing runs it, the second connection finds no table and no
history table, and the check refuses the reading. (ii) without Flyway's PostgreSQL module the start stops — the refusal's three lines
grepped from that step's log (R.303). (iii) all three: the eight Flyway lines, every one before Hibernate's `HHH000001` (R.197, the line
numbers read off the log), `validate` passing, the history table by psql. Flyway masks the URL's password in its own `Database:` line.
(iv) on H2: one WARN per start, named and counted — not a failure.

### 3 · anchor — TiffinBox B / A / A′ on PostgreSQL + the harness's driver (the failure receipt is B)

```text
-> 201 {"name":"Kavya","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}
-> 404
-> 200 · customers listed: 4 (Meera Priya Ravi Sunil)
Flyway: INFO Current version of schema "public": 2
Flyway: INFO Schema "public" is up to date. No migration necessary.
-> 200 · customers listed: 5 (Kavya Meera Priya Ravi Sunil)
it never listened; exit 1 · its line (grep -o): Schema validation: missing table [customer] · org.flywaydb lines: 0
```

Every PostgreSQL start in this capture is TiffinBox from its own extracted jar + the harness's driver (`.m2-demo`'s
`postgresql-42.7.14.jar` appended to the class path; R.335 — `.harness/before`, `.harness/after` and `.harness/after2` asserted to hold
no `postgresql-*.jar`), its URL in its own config tree (`secrets/tiffinbox/jdbc-url`, 0600, deleted after the stop). **B** (`before/`):
Kavya added (201, psql 5 rows), the restart on the same database answers 404 for her and psql counts 4 — the drop-and-seed, C7-1's cause
2. **A** (`after/`): the first JVM migrates V1 and V2; Kavya added; the restart on 20152 finds the history table at version 2, runs
nothing, and answers 200 for her (5 listed, psql 5 rows, the history table still two rows); `GET /dashboard` answers with the same count of SQL lines (the values block)
between its markers, HTML and JSON alike. **A′** = A on a second copy built again. The refusal: `--spring.flyway.enabled=false` on a
fresh database stops at `validate` — loud, never a quiet empty table. The 18 tests passed on both trees: a guard, never a witness of the
restart (R.190). TiffinBox's own database still lives in memory by default; the lesson called `Capstone: TiffinBox on Postgres` moves it.

### 4 · fail — a third migration whose second statement is misspelt, on both databases (R.314)

| | PostgreSQL 18.6 | H2 2.5.250 (over TCP) |
|---|---|---|
| run 1 | `… failed! Changes successfully rolled back.` · `SQL State  : 42601` · exit 1 | `… failed! Please restore backups and roll back database and code!` · `Unknown data type: "EMAIL"` · exit 1 |
| the history table after it | rows 1-2 only; `phone` absent | the `-1` TABLE row, rows 1-2, and `3 … add phone … FALSE`; `PHONE` present |
| run 2 | the same failure | `Detected failed migration to version 3 (add phone).` · exit 1 |
| the file fixed alone | `Successfully applied 1 migration …` · exit 0 · no repair | still `Detected failed migration` · exit 1 |
| `repair()` + the fixed file | — | `Successfully repaired schema history table` · then `Duplicate column name "PHONE"` · `FALSE` again |
| the column dropped + `repair()` | — | `now at version v3` · `TRUE` · `PHONE`, `EMAIL` |

```text
ERROR [main] org.flywaydb.core.internal.command.DbMigrate : Migration of schema "public" to version "3 - add phone" failed! Changes successfully rolled back.
ERROR [main] org.flywaydb.core.internal.command.DbMigrate : Migration of schema "PUBLIC" to version "3 - add phone" failed! Please restore backups and roll back database and code!
3              | 3       | add phone                                 | SQL   | V3__add_phone.sql          | SA           | FALSE
-1             | null    | << Flyway Schema History table created >> | TABLE |                            | SA           | TRUE
Detected failed migration to version 3 (add phone).
Please remove any half-completed changes then run repair to fix the schema history.
INFO  [main] org.flywaydb.core.internal.command.DbRepair : Manual cleanup of the remaining effects of the failed migration may still be required.
```

On PostgreSQL the failed file is rolled back whole and the history table has no row for it: correct the file and start again. On H2
the first statement stays, Flyway records the failed migration, and only the hand cleanup plus `repair()` applies it. `repair()` here is
a `FlywayMigrationStrategy` bean — the hook Boot gives instead of a command (five lines in `harness/src/probe/f/FMain.java`, printed in
the capture); Flyway's API from the same jar does the same (the exercise).

### 5 · traps — PostgreSQL

```text
Migration checksum mismatch for migration version 1
PROBE cause: org.flywaydb.core.api.FlywayException: Found non-empty schema(s) "public" but no schema history table. Use baseline() or set baselineOnMigrate to true to initialize the schema history table.
INFO  [main] org.flywaydb.core.internal.command.DbBaseline : Successfully baselined schema with version: 1
Message    : ERROR: duplicate key value violates unique constraint "customer_name_key"
Detected resolved migration not applied to database: 1.5.
PROBE clean refused: org.flywaydb.core.api.FlywayException: Unable to execute clean as it has been disabled with the 'flyway.cleanDisabled' property.
```

A comment is enough for a checksum mismatch: V1's first line edited after it was applied stops the next start (the two checksums are
printed as Flyway derives them, and the applied one equals the history table's, read by psql). A schema made without Flyway (V1 and V2
run by psql) is refused until a baseline; `baseline-on-migrate` at Boot's default version 1 then runs V2 into the unique name (`23505`),
rolled back, leaving the baseline row alone; the baseline at version 2 is the fix for a running TiffinBox's database (measured: up to
date, exit 0). A migration numbered below the last applied one is refused unless `out-of-order` is set; `clean()` is disabled by
default (Flyway's API — Boot has no key for it — with `info()` beside it). The next step for a database that must keep running while
its schema changes is expand-contract, named by Course 18 (`Ship It & Observe`) in its lesson called `Database Migrations in a Pipeline`.

### 6 · seven, 7 · tests, 8 · xcheck

```text
exit 0 · the seven responses: 7 lines · md5 466c20ed7e0d5439cb052f32ce09de1b
its log before the seven: Migrating lines 2 · 'Successfully applied 2 migrations' 1 · Flyway's H2 WARN 1
in all: 3 reports · tests 18 · failures 0 · errors 0 · skipped 0
its log's Flyway lines - 'Successfully applied 2 migrations': 1 · 'is up to date. No migration necessary': 1 · Flyway's H2 WARN ('newer than the version Flyway has been verified with'): 2
meal_type: V1 `meal_type VARCHAR(10) NOT NULL` · Hibernate's script `meal_type enum ('NON_VEG','VEG','VEGAN') not null`
version: V1 `version BIGINT NOT NULL DEFAULT 0` · Hibernate's script `version bigint not null`
```

The seven is unchanged on H2 (a guard). The tests: 18 on `after/`, offline (C7-4 re-run, 14/3/1). **The hazard (RED #1812):**
`FullStackTest`'s context and `FeedTest`'s share one in-memory database in Surefire's JVM — the first migrates it, the second finds it
migrated (the log's two lines above), and nothing re-seeds it now, so the Kavya `FeedTest` adds stays there for the rest of the JVM; a
later test that counts customers uses a database of its own (the test's comment says so). xcheck (R.80, R.252): Hibernate's script over
`after/`'s libraries with Flyway's jars left out equals the index lesson's `xcheck.sql`, byte for byte — no mapping moved. V1 against
it, named: `meal_type` (V1's `VARCHAR(10)`, the script's `enum`), `version` (V1's `DEFAULT 0`, none in the script), the foreign key
(unnamed in V1 — PostgreSQL names it `pause_customer_id_fkey`, read in `jars` — where the script names its own), and the column order;
the index and the identity columns agree, and `validate` accepts V1's schema on both databases (`jars` iii and iv).

### 9 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md` and `SOLUTION.md`, each block read from the file and run in ONE `env -i` shell, bash then `zsh -f`; each file's
"What it prints" block is asserted equal to the run. RE-MEASURE 1 settled: ONE JVM on H2 in memory reproduces the half-applied column
and the refusal that the probe measured across JVMs over TCP.

## Call-backs, by title (R.224)

- The lesson called `Ids and Generation Strategies` (06): V1's `GENERATED BY DEFAULT AS IDENTITY` columns, carried verbatim.
- The lesson called `Optimistic Locking with @Version` (27): V1's `version BIGINT NOT NULL DEFAULT 0`, carried verbatim.
- The lesson called `Reading the SQL Hibernate Writes` (34): the index `pause_customer_id_idx` in V1, and Hibernate's script unchanged.
- The lesson called `Never Use ddl-auto in Production` (35, the next lesson by number; built after this one): `validate`, its bridge.
- The lesson called `Capstone: TiffinBox on Postgres` (39): where TiffinBox's own database leaves memory.

## The commands this unit adds

```
javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/src/probe/f/V.java harness/src/probe/f/Run.java harness/src/probe/f/FMain.java harness/src/probe/f/FApi.java harness/src/probe/f0/F0Main.java harness/src/probe/x/XMain.java
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../$LIBS/*:../../.m2-demo/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar" $MC "${A[@]}"
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../../.m2-demo/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.datasource.username=sa --logging.level.org.hibernate.SQL=debug
cd .harness/run && exec perl -e 'alarm 3000; exec @ARGV' java -Duser.language=en -Duser.country=US -Dh2.bindAddress=127.0.0.1 -cp "../after/tiffinbox-web/target/extracted/lib/h2-2.5.250.jar" org.h2.tools.Server -tcp -tcpPort 20157 -ifNotExists
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../after/tiffinbox-web/target/extracted/lib/h2-2.5.250.jar" org.h2.tools.Shell -url "jdbc:h2:tcp://127.0.0.1:20157/mem:$DB" -user sa -password '' -sql "$Q"
docker -H "$DH" run -d --pull never --name c7u36-pg -p 127.0.0.1:20158:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v "$U/.harness/secrets/pgpw:/run/pgpw:ro" postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
docker -H "$DH" exec c7u36-pg pg_isready -U sa -h 127.0.0.1 -q
docker -H "$DH" exec c7u36-pg psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c "drop database if exists $DB with (force)" -c "create database $DB"
docker -H "$DH" exec c7u36-pg psql -U sa -d "$DB" -qAt -v ON_ERROR_STOP=1 -c "$Q"
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.org.hibernate.SQL=debug
```

## The repository, and the network

Every Maven run is `mvn -o` against this unit's own `.m2-demo`, seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s6/`
alone (6,933 files; Flyway 12.4.0, its PostgreSQL module, Boot's Flyway module and the PostgreSQL driver 42.7.14 in it). Four Maven runs
before the captures (`before/`'s and `after/`'s packages with their tests, A′'s with `-DskipTests`) and one in `tests`; each prints
`offline: yes` and its `Downloaded from` count, 0. **No network act:** `docker run --pull never`, the version sweep is the brief's
(`_research/spring-boot-metadata-2026-11-16.xml`, `flyway-core-metadata-2026-11-16.xml`: Flyway 12.11.0 and 13.12.2 exist, the BOM
manages 12.4.0, not adopted).

## The folders, the harness and the ports

- `before` → `../c7-unit34/after` (a link; its tree hashed by `harness/tree36.py`, unit 33's `tree33.py` byte for byte, and pinned);
  `after/` this unit's tree; `../c7-tiffinbox` = `after/` (`diff -rq` at the start and the end; a note if a later unit moves it, R.211).
- `harness/src/probe/f` — `FMain` (TiffinBox's entities, the repair strategy behind `--probe.repair=true`), `Run` (the context, the
  native count, the cause chain), `V` (the version lines; the PostgreSQL URL built inside the JVM from `-Dpg.db` and the 0600 password
  file, so the password is on no command line), `FApi` (Flyway's API: `info()`, `clean()`), `ex/Ex` (the exercise's program, compiled by
  the exercise itself); `probe/f0/F0Main` (the labelled run); `probe/x/XMain` (unit 29's, byte for byte). `harness/mig` — the edited
  V1, the failing and fixed V3, V1_5. `harness/mkv.py` (V1 and V2 from `Database.java`), `guard.py` (step 36.0), `chk36.py` (the
  checks), `s36.py` (the prose gate), `dur7.py` (the builders' file, md5 asserted), `surefire.py` (the testing lesson's), `logback.xml`.
- Ports 20150-20159: 20150 B · 20151, 20152 A · 20153 A′ · 20154 the seven · 20155 the refusal · 20157 the H2 server · 20158 the
  container · 20156 and 20159 never bound; all ten free at the start and the end.

## Masks, filters and hygiene — every one, declared

Masked in every capture: the token, the password (`<pw>`), this folder and its parent, the home folder, the user name, JDK versions,
identity hashes, a lambda's address, Flyway's `(execution time …)` (R.264: `<t>`) and the time figure in H2's Shell's row line. Filtered: a
harness JVM's log shows its version lines, Flyway's own lines, `HHH000001`, the harness's `PROBE` lines and a refusal's own lines, each
once in order (Boot repeats a refusal in every cause); TiffinBox's Flyway lines are shown by their message; the foreign key's generated
name in Hibernate's script is `FK<name>`. Raw token and password copies counted before the mask and asserted 0 after it. **Docker:**
every call names its socket (`docker -H "$DH"`, R.332) and the baselines (images, volumes) are asserted non-empty first; the container
is removed with its volume (`rm -fv`) and the volume count is asserted unchanged across the run (R.322).

## Interrupted

Ctrl-C at any point: the trap stops what the run started (a JVM, a Maven, the exercise's shell, the H2 server), sweeps its process
group, removes the container with its volume, deletes a config-tree URL left under `.harness/`, drops the unfinished capture passes and
exits 130.

Measured on the script as committed, `env -i ./receipts.sh` started as its own process group and sent SIGINT as a terminal sends it, at
five points: **mid-build** (a Maven run), **mid-harness** (a harness JVM on PostgreSQL in `jars`), **mid-container** (just after
`pg_isready`), **mid-H2-server** (just after the server listened) and **mid-TiffinBox on PostgreSQL** (a TiffinBox JVM on 20150-20153 in
`anchor`): each exit 130, no JVM of this run left, no container `c7u36-pg`, the volume count the same as before the run, nothing listening on
20150-20159, no `.r-lock`, no unfinished capture pass, the published captures unchanged. A SIGTERM mid-TiffinBox (an aborted test
driver, not planned) ended the same way.

## The ledger rows this unit pays

- **C7-1 cause 2 — paid (scoped: with the harness's driver):** the drop-and-seed is retired; on PostgreSQL + the harness's driver a
  customer added survives a restart (`anchor` A/A′) where `before/` loses her (B). Cause 1 (`jdbc:h2:mem:`) stays the default.
- **C7-4 — re-run:** 18 tests on `after/` (`tests`).
- S4/S5 CARRIED: V1 carries `version … DEFAULT 0` and the index.
- Course 18 (`Ship It & Observe`), the lesson called `Database Migrations in a Pipeline`: expand-contract, named once by its roadmap words, as above.

## RE-MEASURE — the brief's items this unit settles

1 (the exercise in one JVM: settled, it reproduces); 5 (C1 as the frozen tree with its R.250 set rewritten: settled, 18 tests, the
seven); 10 (the repeatable-seed loser: not voiced, not measured); 14 (Flyway's H2 WARN in the tests' log and the shared database:
settled, two WARN lines, one migrate and one up-to-date).

## What differed from the brief

- **The root `.gitignore`:** the brief's "Before any batch" puts the `c7-unit35`…`c7-unit40` lines in 35's commit; the batch order builds
  36 first, so this unit's commit adds them — five lines per unit in 34's form, 30 lines after `c7-unit34/**/secrets/`.
- **`guard` needs the builders:** the capture reads `../../data-jpa-hibernate/_builders` beside this repository (or `C7_BUILDERS`); a
  clone without it skips the capture, says so on the terminal and does not hash it. The sealed clone ran with `C7_BUILDERS` set.
- **The re-run of each builder's comparison step** is `harness/guard.py`'s form (BLUE's `g/guard.py`, extended): the loop is read by
  `ast` from the shipped file and run as shipped — not each builder from a scratch copy; a builder run would also rebuild decks.
- **The exercise is TiffinBox's own V1 and V2** from its core jar plus a V3 of the exercise's, through Flyway's API — not a Diner of
  its own: the failure needs a real column to leave behind. Its solution changes one line, the steps (`A`); the corrected file is
  written by the block beside the broken one and chosen by a step (`fixed`), so README and SOLUTION differ in that one line.
- **The `flyway.enabled=false` refusal** was measured with `ddl-auto: validate` (the shipped YAML): `Schema validation: missing table
  [customer]`. The `ddl-auto=none` variant (`Table "CUSTOMER" not found`) was not run.
- **The checksums in the checksum trap** are printed as Flyway derives them (not masked): the run is deterministic, and the applied one
  is asserted equal to the history table's, read by psql.
- **The baseline at version 2** is measured too (exit 0, up to date), one more JVM in `traps`.
- **TiffinBox's own JVMs print no Flyway version line** (Boot prints none): for them R.329 is the jar on their class path —
  `flyway-core-12.4.0.jar`'s `org/flywaydb/core/internal/version.txt`, the file `VersionPrinter.getVersion()` reads, printed by `unzip -p`.
  Every harness JVM that loads Flyway prints the line itself, and the receipt asserts it per JVM. xcheck's JVM runs on `after/`'s
  libraries with Flyway's jars left out, so it loads none (unit 29's `XMain`, byte for byte, has no version line of its own).
- **18/18 on B as a guard** comes from `before/`'s own build with its tests (34 built `before/` with `-DskipTests`).
- **H2's history table** is read by `org.h2.tools.Shell` over TCP (the server on 20157) — its own JVM, the column names quoted lower
  case; its row line's time figure is masked. On PostgreSQL by `psql` in the container (the URL's password never on a command line;
  the harness builds its URL inside the JVM from `-Dpg.db` and the 0600 password file).
- **The anchor's POM comment and the YAML comment** that named `Database` are in the R.250 set and rewritten, as are the two new
  migrations' first lines (each says the class was retired).

## Planted faults — each caught (R.65, R.226)

On a scratch mirror of this folder (its files and `.m2-demo` cloned, the sibling units linked), each fault planted alone, `env -i
./receipts.sh` run, and the edit undone: every one **exit 1, no capture written, `receipts.md5` unchanged**, stopped by the check named.

- **R.313** `In the labelled run (i) Flyway ran.` in the README → the prose gate (a migration claim without the history table).
- **R.314** `On PostgreSQL Flyway records the failed migration, so run repair.` → the prose gate (H2's story on a PostgreSQL sentence).
- **R.250** the drop-and-seed left in `after/` (a comment `// Database creates and seeds the tables at every start.` in `CustomerEntity`)
  → the R.250 gate before any build.
- **R.190** `18/18 proves the migration works.` → the prose gate.
- **R.264** `Flyway applied both in 26 milliseconds.` → dur7.
- **R.330** `ddl-auto: update` in `after/`'s YAML → the R.330 gate.
- **R.335** `From this unit TiffinBox runs on PostgreSQL.` → the prose gate.
- **R.332** the pin dropped (`dk() { docker "$@"; }`) under `DOCKER_HOST=tcp://127.0.0.1:1` → the baseline check (`info` fails before any
  comparison); and one call written as `docker port` → the static check (every call on the pinned socket).
- **R.322** `dk rm -f` (no `-v`) in the clean-up → the static check (and the volume count at the end, which the runs of record assert).
- **R.302** a typed history-row count with no read beside it → the typed-count gate.
- A typed hash (Hibernate's script's md5 in prose) → the prose gate; a dish name → R.215; a to-do marker line → the placeholder check; a typed
  INSERT statement outside the blocks → R.225; `The second start is quick.` → dur7.
- V2 retyped (one price changed) → the migrations' byte-for-byte comparison with `harness/mkv.py`'s output from `before/`'s
  `Database.java`; `before` pinned to the wrong link → the tree check.

**Check plants** — a copy of a published capture changed one way, `harness/chk36.py` run on it, exit 1 each: the history rows removed from
`jars` (iii) (R.313); the labelled run's refusal line reworded to `Flyway ran` (R.313); Flyway's version line removed from three JVM
blocks (R.329); Boot's version line changed (R.246); `HHH000001`'s version changed in `xcheck`; a PostgreSQL history row added for V3
(R.314); H2's `FALSE` row turned `TRUE` (R.314); "+ the harness's driver" removed from B's line (R.335); B's restart answering 200 (B
said to keep her — the failure receipt inverted); A's restart listing four; the dashboard's SQL lines changed; an execution time left
unmasked (R.264); one builder's guard reported missing (R.331); the seven's md5 one character off (a wrong published hash); the tests
summing 17; V1's `DEFAULT 0` dropped from the R.80 line; the exercise's solution never reaching v3 (R.196: solved = broken); the spoken
line's word count off by one; the two checksums made equal; the baseline's `23505` removed. **R.331's own plant** runs inside every
`guard` capture: each builder's comparison loop with its guard taken out stops on `FileNotFoundError`.

**Not run as a full-run plant** (each needs the container and the ports, a whole run): after/'s `lib/` holding a planted driver with
R.335's `[ ! -e … ]` line removed — the `jars` capture's library count and every PostgreSQL line would move, so its published hash would
stop the run; a published hash edited in `receipts.md5` — `pub` stops at the first capture whose md5 differs (each run of record prints `= published` for every capture).

## The anchor moved on — the re-run of 34 (R.211)

`grep -n 'filecmp\|Database.java\|c7-tiffinbox'` before the commit (R.211, step 36.0), over `_builders/s7*.py`,
`~/Desktop/PromptVidya-Automation/check_unit7.py` and `qa_java7.py`: the builders 34's README lists, plus `s729`-`s734` (Section 5's
scripts, written since); the four that compare `Database.java` against the live anchor are guarded (Step 36.0); `check_unit7.py` and
`qa_java7.py` — no line. **`s717.py` run once after the move** (a scratch copy with `_builders/dur7.py` beside it, so its `OUT` is the
copy's folder and nothing is written into the course; `~/.venvs/slides2video/bin/python s717.py`): exit 0, **twenty** `note: c7-tiffinbox
has moved on since f620c1a …` lines (34 saw thirteen; `Database.java` was already among them, now as `Only in …/after/…: Database.java`;
C1 adds seven: `Customer.java`, `tiffinbox-core/src/main/resources` (new), `tiffinbox-web/pom.xml`, `TiffinBoxServer.java`,
`application.yaml`, `FeedTest.java`, `TiffinBoxWebTest.java`), then `anchor: after/ = f620c1a:c7-tiffinbox in its 4 changed files; diff -rq
against the live c7-tiffinbox: 20 lines` — the expected sign.

**`../c7-unit34/receipts.sh`** (unchanged: its `md5 -q` is the one 34's commit message names) — the previous anchor-change unit — run once
on the moved anchor, `./receipts.sh` (/bin/bash 3.2.57), from 15:36 CET: **exit 0 in 532 s**; its note at its start and its end (`(after/
and ../c7-tiffinbox differ - the anchor has moved past the tree this unit froze: Files after/…/Customer.java and …`), all 9 captures 3/3
= published, `receipts.md5` unchanged (`md5 -q` the same before and after), its log through `check_unit7.py 34 --runlog` PASS. Its
`docker rm -f` kept the container's anonymous volume (R.322 is Section 6's rule; that script is not edited): the one volume it left,
created 15:36:38, was removed by hand right after. 33, 32, 31 and earlier were not re-run (RED #1200). The dated "Re-run after unit 36
moved the anchor" paragraph is in `../c7-unit34/README.md` (its own "Section 6 builds over it" sentences stay true and are not edited).

## The root .gitignore

The repository's `.gitignore` gains the five lines per unit for `c7-unit35` … `c7-unit40` (30 lines, after `c7-unit34/**/secrets/`): this unit's
commit carries them, because the brief's line assumed 35 would be built first.

## For RED

- **TiffinBox on PostgreSQL + the harness's driver keeps 34's config-tree form:** the URL with its password in `secrets/tiffinbox/jdbc-url`, 0600, deleted after
  the stop. With `Database` retired, a URL without the password and Boot's own `spring.datasource.password` would now work (nothing opens
  a `DriverManager` connection any more) — not measured, carried to the capstone.
- **R.250's gate is per sentence over `after/`'s code, YAML, POMs, migrations and tests;** the anchor README is checked for the header
  note, the retirement note on its first `Database` sentence and the unit 36 section — its older dated sections (Course 5-7 history)
  keep sentences that name `Database` as it was then.
- **The `guard` capture's notes name file paths and "unit 36"** — the only capture exempt from the unit-number hygiene rule.
- **`theSliceLeavesTheDatabaseOut` now asserts no `DataSource`:** a `@WebMvcTest` slice never had one, so the assertion is weaker than the
  old one was the day it was written; it keeps the count and the meaning the brief asked for.
- **The shared in-memory database in the tests** (RED #1812) is said in `FeedTest`'s comment and here; no test counts customers today.
- **The 34 re-run's volume:** 34's script removes its container with `docker rm -f` (no `-v`); its one leftover volume was removed by
  hand right after (named in 34's README). The orchestrator's sweep count, 315, held at this run's start and end.
- **Not measured:** the repeatable-seed loser (`R__seed.sql`); `{vendor}` locations; Flyway's Maven build extension; Liquibase (37).
