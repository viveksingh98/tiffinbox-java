# c7-unit38 — Auditing and Soft Deletes

Course 7, Section 6's fourth unit to be built, and **Section 6's second change to the anchor** (brief flag 1, C2, "audit dates"):
`before` is the link to `../c7-unit36/after` (its tree's hash pinned), `after/` is this unit's tree, and `../c7-tiffinbox` equals
`after/` from this unit's commit on. **Auditing** is two stamps on every save — when a row was created and when it last changed, and
by whom — filled by Spring Data's listener, not by Hibernate and not by the database. A **soft delete** keeps the row: Hibernate sets
a flag instead of deleting it, and adds a clause on that flag to every statement it writes — and to none it does not write. TiffinBox's
customer table gains the two date stamps (`createdAt`, `updatedAt`) and a third migration, V3, that adds their columns; the creation
stamp is `@Column(updatable = false)` because a copy saved from outside the persistence context writes NULL over it (measured here,
with the fix beside it). "Who" (`@CreatedBy`) and the soft delete stay in the harness: TiffinBox has no signed-in user before
Course 10, *Spring Security — complete* (`../../_briefs/TRACK-ROADMAP.md:406`), and no route that deletes a customer. Both databases:
PostgreSQL 18.6 in one container per run (the pinned image, a fresh database per JVM, dropped after it) and H2 2.5.250 on an H2
server over TCP (a database per JVM, shut down after it). **Unit 39 moves the anchor next (C3).**

Seven captures, each run in three passes by `receipts.sh` and hashed (`receipts.md5`); every number and string below is asserted right
after its capture by `harness/chk38.py`, against another witness of the same run — the rows read by a second connection (psql in the
container, the harness's own JDBC class over H2's TCP server) while the harness JVM waits at a labelled pause, beside the SQL Hibernate
wrote — never against a typed figure.

<!-- runs: begin -->
**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`, `DOCKER_CONFIG=$HOME/.docker`),
`.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s6/` alone, the image `postgres@sha256:77f58511…` present
(`docker -H "$DH" image inspect`, the full digest), one container per run, removed with its volume at its end. Development runs fixed
the captures and the checks (each capture in one pass); the published hashes are the development pass's, and every run of record
matched them. **The runs of record, on the script as committed (`receipts.sh` md5 printed by `md5 -q` and named in the commit
message):** 310 s under `./receipts.sh` (/bin/bash 3.2.57, 2026-11-17 from 05:25 CET), 312 s under `bash receipts.sh` (Homebrew bash
5.3.9, from 05:31 CET) and 319 s from a sealed fresh clone (below, from 05:36 CET): each exit 0, all 7 captures 3/3 = published, every
check passed, every Maven run `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`, the anchor's `diff -rq` empty at the
start and the end, `before/`'s tree pinned at both, the container removed with its volume (volumes 315 -> 315 in each run), the images
unchanged, nothing listening on 20170-20179 at the end; each terminal log through `check_unit7.py 38 --runlog` — `RESULT (run logs):
PASS` (the unit gate: no 38 script yet). **Nothing was downloaded.**

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at `6693189` into a path **with a space** (`…/sealed
38/tiffinbox-java`, in the session's scratch folder), this commit's files put in as git will take them (`git ls-files -m -o
--exclude-standard c7-unit38 c7-tiffinbox c7-unit36 .gitignore`, links kept); the clone's `.m2-demo` seeded from a file copy of the seed;
dead proxies for http and https in its environment (`127.0.0.1:9`); `DOCKER_CONFIG=$HOME/.docker` in its `env -i`; `./receipts.sh`.
The three runs ran on this README before the plants, the interrupt results and the closing sections were written, and before
`harness/chk38.py`'s `r250` mode was tightened by a plant (a sentence naming two migrations with a later note within reach had passed;
the R.330 line moved first) — the only changes since; a fourth run on the final text and the final `chk38.py`, `./receipts.sh`, exit 0
from 05:57 CET, 315 s, all 7 captures = published.
<!-- runs: end -->

Published hashes (`receipts.md5`, every capture 3/3 in every run):

```
audit c75f9c93b501e26e53de3722c479d211
anchor 9db071323b622f0fb9bf7f0631abcefa
soft 64580cb32f709089d014f3e0d8742b30
seven d0278e07c6a55dc3850f333ddd10eb23
tests 48e46097a5b51e4d2bab81d81ce70905
xcheck 18f9dab2605a2fd0c4c3c0282b614122
exercise e83f9157590cb225bf868ff906b8f27f
```

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line; a SQL string typed in
this README outside this block, the table of statement kinds and the blocks the runs printed is refused):

<!-- values: begin -->
the values the video may say: on PostgreSQL 18.6 and H2 2.5.250, Flyway 12.4.0, Spring Boot 4.1.2, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - audit: Spring Data's auditing (its listener, a fixed auditor kitchen), the same on both: Instant -> timestamp(6) with time zone; INSERT (created_at,created_by,meals_per_day,name,updated_at,updated_by,version) -> version 0, created_at = updated_at, kitchen twice; an edit -> update a_customer set created_at=?,created_by=?,meals_per_day=?,name=?,updated_at=?,updated_by=?,version=? where id=? and version=? (every column), version 1, updated_at > created_at; an unchanged save -> 0 statements; B: a copy merged -> the same UPDATE, created_at NULL, created_by NULL, updated_by kitchen, version 2; A: @Column(updatable = false) -> update a_customer set meals_per_day=?,name=?,updated_at=?,updated_by=?,version=? where id=? and version=?, created_at kept, created_by kitchen (A' the other database); the empty auditor -> created_by null; Hibernate's own: @CreationTimestamp/@UpdateTimestamp parameters, @CurrentTimestamp(source = DB) -> insert into h_customer (created,db_stamp,meals_per_day,name,updated) values (?,localtimestamp,?,?,?) returning id,db_stamp (PostgreSQL), no returning on H2; Envers not fetched · anchor: TiffinBox on PostgreSQL + the harness's driver (after/'s lib/ holds none): B (before/): history 2 rows, customer's columns without a stamp (the catalogue), POST Kavya 201, her stamps unreadable (column "created_at" does not exist); A (after/): Migrating ... "3 - customer audit columns", history 3 rows success t, created_at and updated_at timestamp(6) with time zone, POST Kavya 201 - her created_at and updated_at set and equal, the four seeded rows NULL and NULL (V2 ran before V3), GET /customers/Kavya 200, 5 listed, GET /dashboard 200 with 4 SQL lines (HTML and JSON), the JSON's four keys; the anchor's EMF hibernate.hbm2ddl.auto = validate, passing; A' = A · soft: @SoftDelete -> deleted boolean not null; remove -> update s_customer set deleted=true where id=? and deleted=false; the old pair its own string; by the second connection s_customer rows 3 flagged 1, o_customer rows 3 flagged 1; the clause in 8 statement kinds (findAll, findById, findByName, jpql, count, page, joinFetch, oldPair), the same on both; the native query -> [Meera, Ravi, Sunil] (no clause); leak 1 -> SQLState 23505 (PostgreSQL: duplicate key value violates unique constraint "s_customer_name_key"; H2: Unique index or primary key violation); leak 2 -> findById(1) Optional.empty, findAll [1, 2], count 2, its customer EntityNotFoundException: No row with the given identifier exists (id '2'); the EAGER optional mapping -> present, its customer null; leak 3 -> org.hibernate.metamodel.UnsupportedMappingException: To-one attribute (probe.sl.LMain$SPauseOpt.customer) cannot be mapped as LAZY as its associated entity is defined with @SoftDelete, exit 1, beside its control (optional = false: built) - and the same mapping in another package built; Where.class 0, SQLRestriction.class 1 · seven: 466c20ed7e0d5439cb052f32ce09de1b on before/ and after/ (H2 over TCP), SQL lines during it 6 on both; after/'s start: 3 Migrating lines, Successfully applied 3 migrations 1 · tests: 18 (14/3/1) on after/ from Surefire's reports, offline - a guard, C7-4 re-run after C2; its log: Successfully applied 3 migrations 1, is up to date 1, Flyway's H2 WARN 2 · xcheck: Hibernate's script over after/'s libraries f4f15b9c71145930e75568c4e64ab595 (the Flyway lesson's was 7f6942f0ed8bf296d661f629557f26c6): one line moved - create table customer gains created_at timestamp(6) with time zone, updated_at timestamp(6) with time zone; validate accepts V1-V3 (anchor, the EMF) · exercise: one JVM, H2 in memory, a Diner of its own: the copy saved (merged) -> update diner set created_at=?,... -> created_at_null=t; the solution @Column(updatable = false) -> the UPDATE without created_at -> created_at_null=f (19 words)
<!-- values: end -->

### C2 — the change, file by file, and every sentence it rewrote (R.250)

`diff -rq before after` names four files, and `harness/chk38.py r250` asserts the list before any build: nothing deleted or renamed
(the builders' grep below), one new file, three changed.

- `tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntity.java` — `@EntityListeners(AuditingEntityListener.class)`; after `version`,
  `@CreatedDate @Column(updatable = false) private Instant createdAt` and `@LastModifiedDate private Instant updatedAt`, each with its
  getter; a Javadoc paragraph "Course 7, unit 38: auditing" (who fills the stamps — Spring Data's listener —, why `updatable = false`,
  the zone-aware column, the four seeded customers without stamps, "who" waiting for Course 10, *Spring Security — complete*). **Rewritten:** the class
  Javadoc's first sentence named the columns V1 creates and V2 seeds; it now names V3's two as well.
- `tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java` — `@EnableJpaAuditing` and its import, and a Javadoc paragraph
  "Course 7, unit 38": without it the listener sets nothing; no `AuditorAware` bean.
- `tiffinbox-core/src/main/resources/db/migration/V3__customer_audit_columns.sql` — **new**: one comment line in the anchor's voice
  and two `ALTER TABLE` statements that add `created_at` and `updated_at`, `TIMESTAMP(6) WITH TIME ZONE`, nullable; no back-fill (below).
- `README.md` (the anchor's) — the header's unit 36 sentence "Flyway's two migrations create and seed the tables" gains the note that a
  third, V3, adds two columns; the header's unit 36 note "Hibernate's own DDL is unit 34's, byte for byte" gains "it moved there"; a
  new header note for this unit (C2, unit 39 next); in the unit 36 section, "the history table at version 2" gains "at version 3
  since" and "Unchanged: the mapping" gains "the mapping moved"; and a new section, "Course 7 · unit 38".

**Kept, and why they stay true** (each read): `application.yaml` keeps `ddl-auto: validate` and its comment (R.330 — `validate`
accepts the two new columns, read off the anchor's own EntityManagerFactory in `anchor`); `PauseEntity`'s "Flyway's two migrations,
which retired the Database class" names V1 and V2, which did; the unit 36 section's heading names the two migrations that unit made.
`grep` over `after/` for the old script's md5: 0 files (the script moved, and units 34's and 36's READMEs keep their own sentences
about their own trees — R.252); for `PROBE`: 0 files. The JSON `/dashboard` keeps its four keys, the record `Customer` carries no stamp,
and the eighteen tests are unchanged (C7-4 re-run, `tests`).

## The captures — what each one shows

### 1 · audit — the stamps, the merge that erases one, and its fix (both databases, R.324)

The harness's own `a_customer` (`probe.a.AMain`): `@EntityListeners(AuditingEntityListener.class)`, `@CreatedDate`/`@LastModifiedDate`
`Instant`, `@CreatedBy`/`@LastModifiedBy` `String`, `@Version`; `@EnableJpaAuditing(auditorAwareRef = "auditor")` with an `AuditorAware`
answering the fixed `kitchen` (a stand-in for the signed-in user Course 10, *Spring Security — complete*, brings). `ddl-auto create-drop` on a fresh database per JVM;
each step is labelled, and after each one the JVM waits while the receipt reads the row by a second connection, then writes `go`.

The column type Hibernate writes for an `Instant` is the zone-aware one *Dates, Times and Zones* chose (C7-8, called back, not re-paid):

```text
SQL : insert into a_customer (created_at,created_by,meals_per_day,name,updated_at,updated_by,version) values (?,?,?,?,?,?,?)
id=1 version=0 meals_per_day=2 created_at_null=f updated_at_null=f created_at=updated_at:t updated_at>created_at:f created_by=kitchen updated_by=kitchen
SQL : update a_customer set created_at=?,created_by=?,meals_per_day=?,name=?,updated_at=?,updated_by=?,version=? where id=? and version=?
id=1 version=1 meals_per_day=3 created_at_null=f updated_at_null=f created_at=updated_at:f updated_at>created_at:t created_by=kitchen updated_by=kitchen
```

The insert sets both stamps to the same time; an edit writes every column (R.191, the version in the where clause as in *Optimistic
Locking with @Version*) and moves only `updated_at`; a save of a loaded customer that changed nothing writes no statement and the
version stays. **B — the leak:** a copy made outside the persistence context (a new object with the id and the version, no stamps) is
saved; Spring Data merges it, Hibernate copies the empty fields onto the loaded row and writes the same UPDATE:

```text
id=1 version=2 meals_per_day=4 created_at_null=t updated_at_null=f created_at=updated_at:f updated_at>created_at:f created_by=null updated_by=kitchen
```

**A — the fix** (`probe.a2.AMain`, `@Column(updatable = false)` on the two created columns): the UPDATE leaves them out, and the row
keeps them; **A′** is the same on the other database (RE-MEASURE 3: H2 settled here, the same as PostgreSQL):

```text
SQL : update a_customer set meals_per_day=?,name=?,updated_at=?,updated_by=?,version=? where id=? and version=?
id=1 version=1 meals_per_day=4 created_at_null=f updated_at_null=f created_at=updated_at:f updated_at>created_at:t created_by=kitchen updated_by=kitchen
```

An auditor that answers `Optional.empty()` leaves `created_by` and `updated_by` null and the dates set. Hibernate's own pair on
`h_customer` — `@CreationTimestamp`/`@UpdateTimestamp` (bound as parameters: the JVM's clock, read twice, so after the insert
`updated` is already later than `created`) and `@CurrentTimestamp(event = {INSERT, UPDATE}, source = DB)`, the database's clock, named
in the SQL itself:

```text
SQL : insert into h_customer (created,db_stamp,meals_per_day,name,updated) values (?,localtimestamp,?,?,?) returning id,db_stamp
SQL : update h_customer set db_stamp=localtimestamp,meals_per_day=?,name=?,updated=? where id=? returning db_stamp
```

On H2 the same statements end without `returning`. TiffinBox takes Spring Data's form, not Hibernate's: Course 8's Spring Data JDBC
(*Aggregates, Not Entities*: "no lazy loading, no dirty checking", `TRACK-ROADMAP.md:328`) keeps the same annotations. Envers (history
tables) is named, not fetched: no jar of it in `after/`'s `lib/`, and every harness JVM's class-path line says it is absent.

### 2 · anchor — TiffinBox B / A / A′ on PostgreSQL + the harness's driver (the failure receipt is B's catalogue)

Every start in this capture is TiffinBox from its own extracted jar + the harness's driver (`.m2-demo`'s PostgreSQL driver on the class
path; `after/`'s `lib/` holds none, asserted — R.335), its URL in its own config tree (`secrets/tiffinbox/jdbc-url`, mode 0600, deleted
after the stop), a fresh database each. **B** (`before/`, 20170): Flyway migrates V1 and V2, the history table by psql holds their
rows, and the catalogue has no column for a stamp — Kavya is added (201), and the stamps' query refuses:

```text
id bigint, name character varying(60), meals_per_day integer, price_per_meal integer, meal_type character varying(10), version bigint
ERROR:  column "created_at" does not exist
```

**A** (`after/`, 20171): Flyway applies V3 after V1 and V2, psql reads the history table and the two new columns, and after Kavya's
POST each customer's stamps, by id:

```text
Flyway: INFO Migrating schema "public" to version "3 - customer audit columns"
3|3|customer audit columns|SQL|V3__customer_audit_columns.sql|sa|t
Ravi created_at_null=t updated_at_null=t created_at=updated_at:f
Meera created_at_null=t updated_at_null=t created_at=updated_at:f
Sunil created_at_null=t updated_at_null=t created_at=updated_at:f
Priya created_at_null=t updated_at_null=t created_at=updated_at:f
Kavya created_at_null=f updated_at_null=f created_at=updated_at:t
```

**The seeded four have no stamps.** V2 wrote them before V3 gave the columns, and V3 back-fills nothing. The alternative this unit names
and does not take is a back-fill `UPDATE customer SET created_at = …, updated_at = …` in V3: it would write a time nobody recorded.
Kavya, added through the entity, has both, the same time. `GET /customers/Kavya` answers 200, the list holds her, and `GET /dashboard`
(HTML and JSON) reads the same statements as before — the JSON's four keys carry no stamp. Then the anchor's own `ddl-auto`, read off
its EntityManagerFactory by `probe.u.Emf` (TiffinBox's application class with no web server, in the same folder and on the same
database): `validate`, and the context starts — `validate` accepts the migrated schema with the two columns (R.330). **A′**
(`after/` copied and built again, 20172) is the same. The eighteen tests are a guard here, never a witness (R.190).

### 3 · soft — the clause per statement kind, the bypass, and the three leaks (both databases, R.323)

The harness's own tables (`probe.s.SMain`): `s_customer` with `@SoftDelete`, `s_pause` whose customer is `@ManyToOne(fetch = LAZY,
optional = false)` — the anchor's own `PauseEntity` shape —, the same pause table read by an EAGER optional mapping, and `o_customer`
with the older pair, `@SQLDelete(sql = "update o_customer set deleted = true where id = ?")` + `@SQLRestriction("deleted = false")`.
Ravi, Meera and Sunil in both tables, a pause for Meera and one for Sunil; Meera removed from both. `@SoftDelete` adds Hibernate's own
`deleted boolean not null` (the old pair needs the field written by hand: the same column), and the two removes are UPDATEs; the second
connection reads every row still there, Meera's flagged. Then each statement kind, a labelled step — the list is read off `SMain` by
the receipt and counted by the check (R.187) — with the clause its SQL carries and what it returned (a row per kind and database,
every cell a `cell` line `chk38.py` read off the capture — R.261):

<!-- cells: begin -->
| database | kind | the clause in its SQL | what it returned |
|---|---|---|---|
| PostgreSQL | findAll | `s1_0.deleted=false` | [Ravi, Sunil] |
| PostgreSQL | findById | `s1_0.deleted=false` | findById(Meera's id) present false |
| PostgreSQL | findByName | `s1_0.deleted=false` | findByName(Meera) present false |
| PostgreSQL | jpql | `s1_0.deleted=false` | [Ravi, Sunil] |
| PostgreSQL | count | `s1_0.deleted=false` | 2 |
| PostgreSQL | page | `s1_0.deleted=false · s1_0.deleted=false` | content [Ravi, Sunil] · total 2 |
| PostgreSQL | joinFetch | `join s_customer c1_0 on c1_0.id=s1_0.customer_id and c1_0.deleted=false` | [2:Sunil] |
| PostgreSQL | oldPair | `(o1_0.deleted = false)` | [Ravi, Sunil] |
| H2 over TCP | findAll | `s1_0.deleted=false` | [Ravi, Sunil] |
| H2 over TCP | findById | `s1_0.deleted=false` | findById(Meera's id) present false |
| H2 over TCP | findByName | `s1_0.deleted=false` | findByName(Meera) present false |
| H2 over TCP | jpql | `s1_0.deleted=false` | [Ravi, Sunil] |
| H2 over TCP | count | `s1_0.deleted=false` | 2 |
| H2 over TCP | page | `s1_0.deleted=false · s1_0.deleted=false` | content [Ravi, Sunil] · total 2 |
| H2 over TCP | joinFetch | `join s_customer c1_0 on c1_0.id=s1_0.customer_id and c1_0.deleted=false` | [2:Sunil] |
| H2 over TCP | oldPair | `(o1_0.deleted = false)` | [Ravi, Sunil] |
<!-- cells: end -->

**The bypass:** a native query, `select * from s_customer order by name`, carries no clause, and the removed Meera comes back as a live
entity — every query Hibernate writes hides her, a native query does not:

```text
PROBE result: [Meera, Ravi, Sunil]
```

**Leak 1 — the name she kept.** A new Meera is refused by the unique name the removed one still holds — on PostgreSQL `duplicate key
value violates unique constraint "s_customer_name_key"`, on H2 `Unique index or primary key violation`, SQLState 23505 on both,
Spring's `DataIntegrityViolationException` over Hibernate's `ConstraintViolationException`. **Leak 2 — the vanishing pause** (the hook):
Meera's pause row is still there; `findById(1)` reads it, then reads her customer with the clause, and answers empty; `findAll` lists it;
and the first pause's customer, read through its getter, throws:

```text
PROBE result: Optional.empty
PROBE result: findAll ids [1, 2] · count() 2
PROBE leak 2 - the first pause from findAll, its customer's name threw: jakarta.persistence.EntityNotFoundException: No row with the given identifier exists for entity [probe.s.SMain$SCustomer with id '2']
```

(the id is Meera's, printed by the seed step). Through the EAGER optional mapping the pause is present and its customer is `null` — a
left join with the clause. Sunil's pauses, read from his side, carry no clause (a pause has no flag). **Leak 3 — a labelled step (R.303,
R.312; RED #1806 re-filed):** a pause whose customer is LAZY and optional, JPA's default, to a soft-deleted customer (`probe.sl.LMain`):
Hibernate refuses the mapping when it builds the factory, and the JVM exits 1 —

```text
PROBE cause: org.hibernate.metamodel.UnsupportedMappingException: To-one attribute (probe.sl.LMain$SPauseOpt.customer) cannot be mapped as LAZY as its associated entity is defined with @SoftDelete
```

— beside its **control**, the `SMain` JVM itself: the same pause with `optional = false`, built and run. **Its second step, measured
and not explained further:** the same mapping in another package (`probe.sm.LMain`, the same source but for the package and the two
table names) builds, and its JVM exits 0. Hibernate 7.4.13 checks the refusal while it builds its entity mappings, in an order the
classes' names decide; the refusal is therefore not a guarantee, and a LAZY optional association to a soft-deleted entity is not proof
that the mapping was checked. **`@Where` is gone:** `unzip -l` of `hibernate-core-7.4.13.Final.jar` finds no `Where.class` (its count
printed by the capture, beside `SQLRestriction.class` and `SoftDelete.class`) — removed in 7.x, not deprecated.

### 4 · seven, 5 · tests, 6 · xcheck

**seven** — the comparison set (`../c5-unit11/curlset.sh`) on `before/` and `after/` over the H2 server: the same md5 on both (the
stamps reach no response), `after/`'s start migrating V1-V3. **tests** — the eighteen tests on `after/`, offline, read from Surefire's
reports (TiffinBoxWebTest, FullStackTest, FeedTest): C7-4 re-run after C2, a guard; the log's Flyway lines counted (one context
migrates V1-V3, the other finds them migrated) and Flyway's H2 WARN counted, not a failure. **xcheck** — Hibernate's DDL over
`after/`'s libraries without Flyway's jars, filed as `xcheck.sql`: it moved in this unit (R.252: the script moved — one line, the
customer table's — and units 34's and 36's sentences about their own scripts stay true of their trees):

```text
> create table customer (meals_per_day integer not null, price_per_meal integer not null, created_at timestamp(6) with time zone, id bigint generated by default as identity, updated_at timestamp(6) with time zone, version bigint not null, name varchar(60) not null unique, meal_type enum ('NON_VEG','VEG','VEGAN') not null, primary key (id));
```

### 7 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s block, then `exercise/SOLUTION.md`'s, read from the files and run in one `env -i` shell; each file's "What it
prints" is compared with the run, line for line. Broken: the copy saved, `created_at_null=t`; solved: `@Column(updatable = false)`,
`created_at_null=f` and the UPDATE without the column. The spoken line's words are counted by `wc -w` and printed by the receipt.

## Call-backs, by title (R.224)

*Dates, Times and Zones* (the zone-aware column an `Instant` maps to — C7-8, called back, not re-paid); *Optimistic Locking with
@Version* (the version in every UPDATE's where clause); *Flyway: Versioned Migrations* (V3 and the history table); Course 10, *Spring
Security — complete* (who made the change); Course 8's *Aggregates, Not Entities* (why the Spring Data form carries forward).

## The commands this unit adds

```
javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/src/probe/u/U.java harness/src/probe/u/Db.java harness/src/probe/a/AMain.java harness/src/probe/a2/AMain.java harness/src/probe/s/SMain.java harness/src/probe/sl/LMain.java harness/src/probe/sm/LMain.java harness/src/probe/x/XMain.java
javac -parameters -d .harness/hc -cp ".harness/hc:.harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/after/tiffinbox-web/target/extracted/lib/*" harness/src/probe/u/Emf.java
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../$LIBS/*:../../.m2-demo/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar" $MC "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -cp "../hc:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../../.m2-demo/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar" probe.u.Emf --logging.config=../../harness/logback.xml --logging.level.org.hibernate.orm.core=info --spring.main.banner-mode=off --spring.datasource.username=sa
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../../.m2-demo/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.datasource.username=sa --logging.level.org.hibernate.SQL=debug
cd .harness/run && exec perl -e 'alarm 3000; exec @ARGV' java -Duser.language=en -Duser.country=US -Dh2.bindAddress=127.0.0.1 -cp "../after/tiffinbox-web/target/extracted/lib/h2-2.5.250.jar" org.h2.tools.Server -tcp -tcpPort 20177 -ifNotExists
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -cp "../hc:../after/tiffinbox-web/target/extracted/lib/h2-2.5.250.jar" probe.u.Db "jdbc:h2:tcp://127.0.0.1:20177/mem:$DB;DB_CLOSE_DELAY=-1" $OP "$Q"
docker -H "$DH" run -d --pull never --name c7u38-pg -p 127.0.0.1:20178:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v "$U/.harness/secrets/pgpw:/run/pgpw:ro" postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
docker -H "$DH" exec c7u38-pg pg_isready -U sa -h 127.0.0.1 -q
docker -H "$DH" exec c7u38-pg psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c "drop database if exists $DB with (force)" -c "create database $DB"
docker -H "$DH" exec c7u38-pg psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c "drop database $DB with (force)"
docker -H "$DH" exec c7u38-pg psql -U sa -d "$DB" -qAt -v ON_ERROR_STOP=1 -c "$Q"
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.org.hibernate.SQL=debug
```

## The repository, and the network

Every Maven run is `mvn -o` against this unit's own `.m2-demo`, seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s6/`
alone (no new jar: Spring Data's auditing is in `spring-data-jpa` and `spring-data-commons`, Hibernate's annotations in
`hibernate-core` — all in the anchor's libraries); every build's log is checked for a download line. The PostgreSQL image is used by
its digest with `--pull never`, and the image list is asserted unchanged across the run. Nothing leaves the machine; every listener is
on 127.0.0.1.

## The folders, the harness and the ports

`before` → `../c7-unit36/after` (its tree pinned by `harness/tree38.py`, unit 33's `tree33.py` byte for byte); `after/` this unit's
tree; `harness/`: `chk38.py` (the checks), `s38.py` (the prose gate, unit 36's `s36.py` carried with this unit's readings),
`dur7.py` (the builders', as shipped), `surefire.py` (the testing lesson's), `logback.xml`, and `src/`: `probe.u.U` (the frame: version
lines, the URL built inside the JVM, labelled steps, pauses), `probe.u.Db` (the second connection on H2), `probe.u.Emf` (the anchor's
EMF), `probe.a`/`probe.a2` (auditing, the fix), `probe.s` (soft deletes), `probe.sl`/`probe.sm` (leak 3's two steps), `probe.x.XMain`
(unit 29's, byte for byte), `probe.u.ex.Ex` (the exercise, compiled by the exercise alone). **Harness rules:** every harness entity
carries an explicit `@Entity(name = …)` (a nested class otherwise resolves to a name the queries cannot find — the brief's hazard,
asserted by a grep); every association is read through its getter (a proxy's field read directly bypasses its loading and reads
`null`). Ports: 20170 B · 20171 A · 20172 A′ · 20173 the seven · 20177 the H2 TCP server · 20178 the container · 20174-20176 and 20179
never bound; all ten free at the start and the end.

## Masks, filters and hygiene — every one, declared

Masked in every capture: the token, the password (`<pw>`), this folder and its parent, the home folder, the user name, JDK versions,
identity hashes, a lambda's address and Flyway's `(execution time …)` (R.264: `<t>`). No time a stamp holds is ever printed: the second
connection prints comparisons (`created_at=updated_at:t`) and nulls, never a value. Filtered: a harness JVM's log shows its version
lines, `HHH000001`, the SQL Hibernate wrote, its WARN lines, the harness's `PROBE` lines and the second connection's reads, in order;
TiffinBox's Flyway lines are shown by their message. Raw token and password copies counted before the mask and asserted 0 after it.
**Docker:** every call names its socket (`docker -H "$DH"`, R.332) and the baselines (images, volumes) are asserted non-empty first; the
container is removed with its volume (`rm -fv`) and the volume count is asserted unchanged across the run (R.322).

## Interrupted

Ctrl-C at any point: the trap stops what the run started (a JVM, a Maven, the exercise's shell, the H2 server, a harness JVM waiting
at a pause — its pipe closed), sweeps its process group, removes the container with its volume, deletes a config-tree URL left under
`.harness/`, drops the unfinished capture passes and exits 130.

Measured on the script as committed, `env -i ./receipts.sh` started as its own process group and sent SIGINT as a terminal sends it, at
five points: **mid-build** (a Maven run), **mid-H2-server** (just after the server listened), **mid-container** (just after
`pg_isready`), **mid-harness** (a harness JVM on PostgreSQL waiting at its first pause in `audit`) and **mid-TiffinBox on PostgreSQL**
(a TiffinBox JVM listening in `anchor`): each exit 130, no JVM of this run left, no container `c7u38-pg`, the volume count the same as
before the run (315 -> 315), nothing listening on 20170-20179, no `.r-lock`, no unfinished capture pass, no config-tree URL left, the
published captures unchanged.

## The ledger rows this unit pays

**C7-4** re-run after C2 (the eighteen tests, `tests`). **C7-8** called back (the zone-aware column), not re-paid. Envers named.

## RE-MEASURE — the brief's items this unit settles

**3** — the `updatable = false` fix on H2: measured, the same as PostgreSQL (`audit`, A′). **6** — C2 on 36/after as frozen: the script
moved as the brief measured it (`xcheck`), the seeded rows' stamps said as NULL, the back-fill named as the alternative and not taken.
**11** — "the index now needs `deleted`": left unvoiced (three rows plan a sequential scan whatever the index; a generated-rows plan is
not part of this unit's captures).

## What differed from the brief

1. **The second connection reads while the JVM waits, not after it exits.** The brief has the rows read after each JVM; `create-drop`
   drops the harness's tables when the context closes, so after the JVM there is nothing to read. Each harness JVM prints
   `PROBE pause NAME` and blocks on a line from a named pipe; the receipt reads the rows by psql (in the container) or by
   `probe.u.Db` (its own JVM, over H2's TCP server) and then writes `go`. The reader is another process on another connection; the
   rows are never read from inside the JVM under test (`receipts.sh` asserts every pause was read).
2. **Leak 3 depends on the classes' names.** The probe's and RED's refusal reproduces (`probe.sl.LMain`), but the same mapping first
   written as `probe.sl.LMain$LCustomer`/`$LPause` built with no refusal, and so does `probe.sm.LMain` — the refusal's own source, its
   package and table names changed. Bisected in development (identity ids, the unique name, the join column, `optional = true`
   written out, the version-line call: none of them decides it); the class names do. The capture files the refusal, its `optional =
   false` control, and the build in the other package as its second step; the README says the refusal is not a guarantee.
3. **B's failure receipt is the catalogue.** `before/` holds no stamp column: psql's column list and the stamps' query refused
   (`column "created_at" does not exist`) — as the brief planned; B does not restart (no restart claim is this unit's).
4. **The anchor's `ddl-auto` is read off its EntityManagerFactory by a harness JVM** (`probe.u.Emf`: TiffinBox's application class, no
   web server, the same folder and database as A's TiffinBox JVM) — TiffinBox's own JVM exposes no such endpoint (Actuator's list is
   health and prometheus).
5. **Builds:** `before/`, `after/` and `after2/` are built with `-DskipTests`; the eighteen tests run once, in `tests` (C7-4), offline.
6. **The exercise's one changed line is the copy** (`cp` → a `sed` that adds `@Column(updatable = false)` as it copies), so README and
   SOLUTION differ by one line as the receipt asserts.
7. **The time a stamp holds is never printed** — the second connection prints comparisons and nulls (`created_at=updated_at:t`,
   `created_at_null=f`): a printed time would differ in every pass.
8. **Hibernate's own pair reads the clock twice:** after the insert `updated` is already later than `created` (the second
   connection's `updated>created:t` at `h-insert`), where Spring Data's listener writes one time into both — a measured difference the
   brief did not list.
9. **RE-MEASURE 11 unvoiced** (the brief's default): no generated-rows plan was run.

## Planted faults — each caught (R.65, R.226)

On a scratch mirror of this folder (its files and `.m2-demo` cloned, the sibling units linked), each fault planted alone and `env -i
./receipts.sh` run: every one **exit 1**, `receipts.md5`, the README and the exercise files unchanged, stopped by the check named.

- **R.323** `Every query hides deleted rows.` → the prose gate (unscoped); a sentence crediting `@Where` as
  Hibernate 7.4's filter → the prose gate (it is absent from the jar).
- The seeded rows' null times hidden: `The four seeded rows have stamps.` → the prose gate.
- **R.324** `Audited fields cannot be lost.` → the prose gate; **the fix dropped** (`@Column(updatable = false)` taken off
  `probe.a2`'s `createdAt`) → `audit`'s check (`A - the merge's UPDATE without the two created columns`) after its three passes — the
  mirror's `.r-audit.out` written, the real folder untouched.
- `Hibernate stamps both columns.` → the prose gate (Spring Data's listener fills them).
- **R.329** Flyway's version line taken out of `probe.u.U` → the first harness JVM's check (`a JVM with Flyway on its class path
  printed no Flyway version line`).
- **R.302** a typed count of statement kinds, and one of libraries, in a README sentence → the prose gate.
- **R.215** a dish name in the README → the dish check. **R.335** `From this unit TiffinBox runs on PostgreSQL.` → the prose gate.
  **R.190** `18/18 proves the fix works.` → the prose gate. A duration word (`instantly`) → S4.7's family.
- **R.250** a sentence naming two migrations left in `after/` (`TiffinBox has two migrations.` in `CustomerEntity`'s Javadoc) → the R.250
  gate before any build (this plant first passed: the rule allowed a unit 38 note anywhere within reach, and the Javadoc's next
  paragraph is one; tightened to the same sentence or the note right after it, and the plant re-run, exit 1); `PROBE` wording left in `after/`'s V3 → the placeholder check. **R.330** `ddl-auto: update` in `after/`'s YAML →
  the R.330 gate.
- **R.322** `dk rm -f` (no `-v`) in the clean-up → the static check. **R.332** the pin dropped (`dk() { docker "$@"; }`) under
  `DOCKER_HOST=tcp://127.0.0.1:1` → the baseline check (`info` fails before any comparison).
- A wrong published hash (`audit`'s, one character off in `receipts.md5`) → `pub` (`audit is not the published capture`).

**Check plants** — a copy of a published capture changed one way, `harness/chk38.py` run on it, exit 1 each (R.276: each check shown
failing): the four seeded rows' read removed, and one of them stamped (the `anchor` check); the LAZY refusal filed without its control
(the control JVM's `ready: yes` turned `no` — R.312); the native query's line without Meera (R.323); `Where.class 1` (R.323); `HHH000001`
naming another version and Boot's version line changed (R.246); the merge's NULL turned into a kept stamp (R.324 — the leak hidden);
the exercise's solution printing `created_at_null=t` (R.196: solved = broken); the spoken line's word count off by one; the tests summing
one fewer; the vanishing pause listed by `findById`; Hibernate's script equal to the Flyway lesson's (R.252); the seven's md5 one
character off. A changed "What it prints" line differs from the run's (the receipt's line-for-line comparison).

## The anchor moved on — the builders, and the re-run of 36 (R.211, R.331)

`grep -n 'c7-tiffinbox\|filecmp' _builders/*.py ~/Desktop/PromptVidya-Automation/check_unit7.py
~/Desktop/PromptVidya-Automation/qa_java7.py` before the commit (R.211, ⚑1): `check_unit7.py` and `qa_java7.py` — no line; the four
builders step 36.0 guarded (`s703`, `s706`, `s707`, `s709`) keep their `os.path.exists` line (read, one each); `s715.py` and `s716.py`
`filecmp` their changed files against the live anchor, and C2 changes three of them (`CustomerEntity.java`, `TiffinBoxApp.java`, the
README) while deleting or renaming none, so each comparison prints a note and never stops; `s717.py`-`s734.py` diff the live tree and
print notes. **Each run once from a scratch copy with `_builders/dur7.py` beside it** (its `OUT` is the copy's folder; nothing is written
into the course; `~/.venvs/slides2video/bin/python sNNN.py`): `s715.py` exit 0 with 5 `note:` lines, `s716.py` exit 0 with 4, `s717.py`
exit 0 with 20 — the twenty unit 36 saw: C2's files were already among them (`CustomerEntity.java`, `TiffinBoxApp.java` and the README
differed since 26 and 36; V3 sits in `tiffinbox-core/src/main/resources`, already `Only in …`), so C2 adds none. No builder fails on the
moved anchor; none was edited.

**`../c7-unit36/receipts.sh`** (unchanged: its `md5 -q` is the one 36's commit message names) — the previous anchor-change unit — run
once on the moved anchor, `./receipts.sh` (/bin/bash 3.2.57) in `env -i`, the course's `_builders` beside the repository so its `guard`
capture ran, from 04:51 CET: **exit 0 in 379 s**; its note at its start and its end (`(after/ and ../c7-tiffinbox differ - the anchor has
moved past the tree this unit froze: Files after/README.md and ../c7-tiffinbox/README.md differ;…`), all 9 captures 3/3 = published,
`receipts.md5` unchanged (`md5 -q` the same before and after), its container removed with its volume (315 -> 315), its log through
`check_unit7.py 36 --runlog` PASS. 35 and 37 were not re-run (RED #1200). The dated "Re-run after unit 38 moved the anchor" paragraph is
in `../c7-unit36/README.md`; its own "38 moves the anchor next (C2)" sentences stay true and are not edited.

## The root .gitignore

Its five `c7-unit38/` lines landed in unit 36's commit (verified, not edited).

## For RED

- **Leak 3 is order-dependent** (What differed, 2): a script that says "Hibernate refuses a LAZY optional to-one to a soft-deleted
  entity" must say it as captured — refused here, built in the other package. RED #1806's filed text stands; its universality does not.
  Worth a line to the brief's owner before 38's script is written.
- **The second connection reads during the JVM** (What differed, 1) — the pause is the harness's; the reads are psql's and
  `probe.u.Db`'s, other processes on other connections.
- **"Every query hides deleted rows" is refused unscoped** (R.323): the native query returned the removed Meera on both databases;
  the table counts the clause in the statement kinds `SMain` names, and only those.
- **The seeded four are NULL** in A and A′ (psql), and V3 back-fills nothing; the back-fill is named as the alternative, not measured.
- **Hibernate's script moved in this unit** (`xcheck.sql`, its md5 in the values block), one line from the Flyway lesson's; units 34's and 36's READMEs keep their own
  md5 sentences, true of their trees (R.252).
- **The fix is the anchor's too:** `CustomerEntity.createdAt` carries `@Column(updatable = false)`; TiffinBox has no route that saves a
  detached copy today, so the anchor's own merge is not run here — the harness's is, on both databases.
- **Not measured:** "who" on the anchor (Course 10, *Spring Security — complete*), `@SoftDelete` on the anchor (no delete route), Envers, the index plan
  (RE-MEASURE 11), a back-fill.
