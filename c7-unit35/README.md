# c7-unit35 — Never Use ddl-auto in Production

Course 7, Section 6's second unit to be built (batch 2 of the brief's evidence batches), and **a harness unit with no anchor change**
(brief flag 1): `anchor` is the link to `../c7-unit34/after`, Section 5's frozen anchor, its tree's hash pinned. Hibernate can write the
schema from the entities — `spring.jpa.hibernate.ddl-auto` — and this unit runs that schema step against TiffinBox's real tables: the
shipped `Database` class's own DDL and seed, on throwaway databases. `create` throws the rows away and leaves Hibernate's schema in place
of `Database`'s; `create-drop` throws the tables away; `update` adds, narrows and retypes columns — and when the database refuses one of
its statements, it logs a WARN and the start goes on. `validate` only checks, and it checks presence and type, not a length. In
production the schema is a migration's job: the next lesson, *Flyway: Versioned Migrations*. Both databases: PostgreSQL 18.6 in one
container per run (the pinned image, a fresh database per JVM, dropped after it) and H2 2.5.250 on an H2 server over TCP (a database per
run, shut down after it), plus H2 in a JVM's own memory for Boot's default. TiffinBox itself is never started: every JVM is the
harness's, over the anchor's libraries. This unit runs no tests.

Five captures, each run in three passes by `receipts.sh` and hashed (`receipts.md5`); every number and string below is asserted right
after its capture by `harness/chk35.py`, against another witness of the same run — the catalogue and the rows read by a second
connection (psql in the container, `probe.d.Db` over TCP on H2) before and after the JVM, beside Hibernate's SQL logger and the
EntityManagerFactory's own property — never against a typed figure.

<!-- runs: begin -->
**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`, `DOCKER_CONFIG=$HOME/.docker`),
`.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s5/` alone (a copy, whole), the image `postgres@sha256:77f58511…`
present (`docker -H "$DH" image inspect`, the full digest), one container per run, removed with its volume at its end. Development runs
fixed the captures and the checks; the published hashes are the development passes', and every run of record matched them. **The runs
of record, on the script as committed (`receipts.sh` md5 printed by `md5 -q` and named in the commit message):** 346 s under `./receipts.sh`
(/bin/bash 3.2.57, 2026-11-17 from 02:47 CET), 381 s under `bash receipts.sh` (Homebrew bash 5.3.9, from 02:53 CET) and 379 s from a
sealed fresh clone (below, from 03:00 CET): each exit status success, every capture 3/3 = published, every check passed, the one Maven
run `offline: yes` with no `Downloaded from` line, `anchor/`'s tree pinned at the start and the end, the R.211 note at both, every
`ddl-auto` run's database dropped, the container removed with its volume (the volume count the same at the start and the end of each
run), the images unchanged, nothing listening on 20140-20149 at the end; each terminal log through `check_unit7.py 35 --runlog` —
`RESULT (run logs): PASS` (the unit gate: no 35 script yet). An earlier set of three runs of record (02:14-02:32 CET, the same
captures) was set aside when `harness/s35.py`'s number rule was tightened after a plant it missed; the set above ran on the files as
committed. **Nothing was downloaded.**

**A sealed fresh clone (R.129)** — a `git clone` of tiffinbox-java (`file://`) at `877936e` into a path **with a space** (`…/sealed
35/tiffinbox-java`, in the session's scratch folder), this commit's files put in as git will take them (`git ls-files -o
--exclude-standard c7-unit35`, the link kept); the clone's `.m2-demo` a file copy of the seed; dead proxies for http and https in its
environment (`127.0.0.1:9`); `DOCKER_CONFIG=$HOME/.docker` in its `env -i`; `./receipts.sh`. The three runs ran on this README
before this paragraph was written (the only change since; the prose gate was re-run on the final text: `s35` refused none).
<!-- runs: end -->

Published hashes (`receipts.md5`, every capture 3/3 in every run):

```
default 03c90efe87e6cd089cb7cab676dc095b
values fc41ad04976887d096d5e78ffb23f728
changes cce2fb2d4459f290dce0703466fc4ae0
xcheck 5d442a2fefe8ed326c4e2e39025bca1d
exercise 0e03efb62472e6eb24d7895ff021961e
```

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line):

<!-- values: begin -->
the values the video may say: on PostgreSQL 18.6 and H2 2.5.250, Spring Boot 4.1.2, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final, no Flyway, Liquibase or Testcontainers jar on the class path, tests run: 0 - default: Boot's default (no key), hibernate.hbm2ddl.auto off the EMF: PostgreSQL null, H2 over TCP null, jdbc:h2:mem: create-drop; SQL lines 0, 0 and 6 at start (drop table if exists customer cascade; drop table if exists pause cascade; create table custome…; create table paus…; create index pause_customer_id_idx on pause (customer_id); the foreign key) + 2 after closing (drop table if exists customer cascade; drop table if exists pause cascade); PostgreSQL and H2 over TCP: rows customer 4 · pause 2 unchanged · values: PostgreSQL: create - 8 SQL lines, rows customer 4 · pause 2 -> customer 0 · pause 0, version bigint not null default 0 -> bigint not null, meal_type character varying(10) not null + the CHECK customer_meal_type_check, the foreign key pause_customer_id_fkey -> fkrng439mwjihy7j0wdmaxstwyo, the columns in Hibernate's order (meals_per_day, price_per_meal, id, version, meal_type, name); create-drop - after the JVM tables: (none); update and validate with the anchor's own mapping - 0 SQL lines, catalogue and rows unchanged, exit 0 · H2: create - 6 SQL lines, rows customer 4 · pause 2 -> customer 0 · pause 0, version bigint not null default 0 -> bigint not null, meal_type character varying(10) not null -> enum not null, the foreign key CONSTRAINT_48 -> FKRNG439MWJIHY7J0WDMAXSTWYO, the columns in Hibernate's order (meals_per_day, price_per_meal, id, version, name, meal_type); create-drop - after the JVM tables: (none); update and validate with the anchor's own mapping - 0 SQL lines, catalogue and rows unchanged, exit 0 - S2 ⓘ3 closed: validate passes on both · changes: the four changes, update then validate, both databases - rename: update ran alter table if exists customer add column mealsaday integer not null, refused (PostgreSQL [ERROR: column "mealsaday" of relation "customer" contains null values]; H2 [NULL not allowed for column "MEALSADAY";]), ready: yes, exit 0, the catalogue unchanged; validate Schema validation: missing column [mealsaday] in table [customer], exit 1; rename2: add column meals_daily integer applied, meals_per_day kept with its values; len40: alter table if exists customer alter column name set data type varchar(40), the column narrowed character varying(60) -> character varying(40) (B), validate passes, exit 0 (A: it checks no length); with a name of 45 characters (its printed length) in the table: the same statement refused (ERROR: value too long for type character varying(40) / Value too long for column "NAME CHARACTER VARYING(40)"), ready: yes, exit 0, the column stays character varying(60); drop: 0 statements, price_per_meal stays; type: alter column meals_per_day set data type varchar(255), the column retyped; validate (A') Schema validation: wrong column type encountered in column [meals_per_day] in table [customer]; found [int4 (Types#INTEGER)], but expecting [varchar(255) (Types#VARCHAR)] (H2: found [integer (Types#INTEGER)]), exit 1; the chain org.springframework.beans.factory.BeanCreationException <- jakarta.persistence.PersistenceException <- org.hibernate.tool.schema.spi.SchemaManagementException · the WARN: GenerationTarget encountered exception accepting command : Error executing DDL "alter table if exists customer add column mealsaday integer not null" via JDBC [ERROR: column "mealsaday" of relation "customer" contains null values] · xcheck: Hibernate's script over the anchor's libraries 7f6942f0ed8bf296d661f629557f26c6 = the index lesson's xcheck.sql, byte for byte (diff 0 lines) · exercise: one JVM, H2 in memory, a diner table of its own: update - alter table if exists diner alter column meals_per_day set data type varchar(255), integer -> character varying(255), exit 0; the solution validate - wrong column type … found [integer (Types#INTEGER)], exit 1, the column still integer (26 words)
<!-- values: end -->

## Born on an anchor the live folder had left

The brief's batch order built unit 36 before this one, and 36 moved the live anchor (C1: Flyway, `Database` retired) in its commit
`877936e`. So this unit was born on an anchor `../c7-tiffinbox` had already left: `anchor` is `../c7-unit34/after`, and its tree is
pinned by `harness/tree35.py` (unit 33's `tree33.py`, byte for byte) at the hash and file count the receipt prints at its start and its
end. The R.211 diff `diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox` still runs at both ends; it is not
empty from the first run on, so the receipt prints its note and goes on — the pin is the guard, the note is information (R.211, RED
#1817). The note, as the run prints it to the terminal (the line's count of differing files varies with the live folder, so it is
never in a capture):

```
  note (start): the live anchor moved on in unit 36; this unit stands on c7-unit34/after, pinned - diff -rq anchor/ ../c7-tiffinbox: 13 lines (Files anchor/README.md and ../c7-tiffinbox/README.md differ;Files anchor/tiffinbox-core/src/main/java/com/tiffinbox/Customer.java and ../c7-tiffinbox/tiffinbox-core/src/main/java/com/tiffinbox/Customer.java differ)
```

**The anchor's own YAML (R.330):** the receipt reads `ddl-auto` off `anchor/tiffinbox-web/src/main/resources/application.yaml` and
asserts it is `none` — 34/after's value, Section 5's; 36/after ships `validate`. This unit stands on the tree that ships `none`; its
`ddl-auto` runs are the harness's, each on a database that dies with its run (R.178). 36 moved the anchor before this unit was built;
38 moves it next (C2).

## The captures — what each one shows

Every run of `default` (but its in-memory one), `values` and `changes` has one shape (brief ⚑2): a fresh database (PostgreSQL: a new
database made by psql in the container; H2: a new in-memory database on the TCP server) → the shipped
`Database`'s seed, run from the harness (`probe.d.Db … seed`: `Database.createAndSeed()` on the run's URL, no Spring) → the catalogue
and the rows read by a second connection → ONE harness JVM with the value → the catalogue and the rows again, after the JVM exited →
the database dropped (PostgreSQL: dropped with `force` by psql, then the databases named `u35…` listed: `(none)`; H2: `SHUTDOWN`,
then a connection with `IFEXISTS=TRUE` refused). Each JVM prints its version lines, `HHH000001`, every statement Hibernate's SQL logger
logged, the schema step's WARN lines, the EMF's own `hibernate.hbm2ddl.auto` (R.188: `null` printed as the word), `ready: yes` or
`ready: no` with the exception's causes, a `closing` marker before the context closes; then the counts: SQL lines before and after the
marker, GenerationTarget WARN lines, all WARN lines.

### default — Boot's default, three labelled JVMs (R.188)

No `ddl-auto` key, the anchor's two entities (`probe.d.Main`, `@EntityScan("com.tiffinbox")`). On PostgreSQL and on H2 over TCP Boot
sets nothing — the EMF's property is `null`, Hibernate runs no schema step, and the seeded tables stay as they were; Boot treats a
`tcp:` URL as not embedded. On `jdbc:h2:mem:` Boot's default is `create-drop`: the drops and creates at start, and the two drops again
after the harness's `closing` marker. That is the default that dropped TiffinBox's table at shutdown in *Your First Entity and
EntityManager*.

```text
-- u35dpg · PostgreSQL · probe.d.Main
PROBE emf hibernate.hbm2ddl.auto = null
exit 0 · SQL lines before closing: 0 · after closing: 0 · GenerationTarget WARN lines: 0 · WARN lines: 0
the database dies with its run (R.178): drop database u35dpg with (force) · the databases named u35… now: (none)
-- u35dtcp · H2 over TCP · probe.d.Main
PROBE emf hibernate.hbm2ddl.auto = null
exit 0 · SQL lines before closing: 0 · after closing: 0 · GenerationTarget WARN lines: 0 · WARN lines: 0
the database after SHUTDOWN: gone (IFEXISTS=TRUE refused, error 90146)
-- u35dmem · H2 in the JVM's memory (jdbc:h2:mem:, Boot's embedded database) · probe.d.Main - no seed, no second connection: the database lives and dies in this JVM
DEBUG [main] org.hibernate.SQL : drop table if exists customer cascade
DEBUG [main] org.hibernate.SQL : drop table if exists pause cascade
DEBUG [main] org.hibernate.SQL : create table customer (meals_per_day integer not null, price_per_meal integer not null, id bigint generated by default as identity, version bigint not null, name varchar(60) not null unique, meal_type enum ('NON_VEG','VEG','VEGAN') not null, primary key (id))
DEBUG [main] org.hibernate.SQL : create table pause (days integer not null, customer_id bigint not null, id bigint generated by default as identity, primary key (id))
DEBUG [main] org.hibernate.SQL : create index pause_customer_id_idx on pause (customer_id)
DEBUG [main] org.hibernate.SQL : alter table if exists pause add constraint FKrng439mwjihy7j0wdmaxstwyo foreign key (customer_id) references customer
PROBE emf hibernate.hbm2ddl.auto = create-drop
DEBUG [main] org.hibernate.SQL : drop table if exists customer cascade
DEBUG [main] org.hibernate.SQL : drop table if exists pause cascade
exit 0 · SQL lines before closing: 6 · after closing: 2 · GenerationTarget WARN lines: 0 · WARN lines: 0
```

### values — `create`, `create-drop`, `update`, `validate` with the anchor's own mapping (both databases)

`create` drops `Database`'s tables and writes Hibernate's: the second connection reads the seeded rows before and none after, and the
schema is no longer `Database`'s — `version` without its default, a CHECK on `meal_type` on PostgreSQL (an `enum` column on H2), the
foreign key under Hibernate's name, the columns in Hibernate's order. `create-drop` starts the same way and drops both tables when the
context closes: after the JVM the catalogue lists no table. `update` and `validate` with the anchor's own entities over `Database`'s
schema run no statement and pass on both databases: the anchor's mapping and its hand-written DDL agree as far as Hibernate checks.
**S2 ⓘ3 closed:** on H2 Hibernate's own DDL would write `meal_type` as an `enum` where `Database` writes `CHARACTER VARYING(10)`, and
`validate` passes — it compares JDBC type codes, and both read as VARCHAR (as the probe measured; on PostgreSQL Hibernate's DDL is a
`varchar` with a CHECK, and `validate` passes there too).

```text
-- u35vcreatepg · PostgreSQL · probe.d.Main --spring.jpa.hibernate.ddl-auto=create
col customer.meal_type character varying(10) not null
col customer.version bigint not null default 0
constraint pause pause_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer(id)
rows customer 4 · pause 2
PROBE emf hibernate.hbm2ddl.auto = create
exit 0 · SQL lines before closing: 8 · after closing: 0 · GenerationTarget WARN lines: 0 · WARN lines: 0
col customer.version bigint not null
col customer.meal_type character varying(10) not null
constraint customer customer_meal_type_check CHECK (((meal_type)::text = ANY ((ARRAY['VEG'::character varying, 'NON_VEG'::character varying, 'VEGAN'::character varying])::text[])))
constraint pause fkrng439mwjihy7j0wdmaxstwyo FOREIGN KEY (customer_id) REFERENCES customer(id)
rows customer 0 · pause 0
the database dies with its run (R.178): drop database u35vcreatepg with (force) · the databases named u35… now: (none)
-- u35vcreatedroppg · PostgreSQL · probe.d.Main --spring.jpa.hibernate.ddl-auto=create-drop
col customer.meal_type character varying(10) not null
col customer.version bigint not null default 0
constraint pause pause_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer(id)
rows customer 4 · pause 2
PROBE emf hibernate.hbm2ddl.auto = create-drop
exit 0 · SQL lines before closing: 8 · after closing: 4 · GenerationTarget WARN lines: 0 · WARN lines: 0
tables: (none)
the database dies with its run (R.178): drop database u35vcreatedroppg with (force) · the databases named u35… now: (none)
-- u35vupdatepg · PostgreSQL · probe.d.Main --spring.jpa.hibernate.ddl-auto=update
col customer.meal_type character varying(10) not null
col customer.version bigint not null default 0
constraint pause pause_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer(id)
rows customer 4 · pause 2
PROBE emf hibernate.hbm2ddl.auto = update
exit 0 · SQL lines before closing: 0 · after closing: 0 · GenerationTarget WARN lines: 0 · WARN lines: 0
col customer.meal_type character varying(10) not null
col customer.version bigint not null default 0
constraint pause pause_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer(id)
rows customer 4 · pause 2
the database dies with its run (R.178): drop database u35vupdatepg with (force) · the databases named u35… now: (none)
-- u35vvalidatepg · PostgreSQL · probe.d.Main --spring.jpa.hibernate.ddl-auto=validate
col customer.meal_type character varying(10) not null
col customer.version bigint not null default 0
constraint pause pause_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer(id)
rows customer 4 · pause 2
PROBE emf hibernate.hbm2ddl.auto = validate
exit 0 · SQL lines before closing: 0 · after closing: 0 · GenerationTarget WARN lines: 0 · WARN lines: 0
col customer.meal_type character varying(10) not null
col customer.version bigint not null default 0
constraint pause pause_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer(id)
rows customer 4 · pause 2
the database dies with its run (R.178): drop database u35vvalidatepg with (force) · the databases named u35… now: (none)
-- u35vcreateh2 · H2 over TCP · probe.d.Main --spring.jpa.hibernate.ddl-auto=create
col customer.meal_type character varying(10) not null
col customer.version bigint not null default 0
constraint pause CONSTRAINT_48 FOREIGN KEY
rows customer 4 · pause 2
PROBE emf hibernate.hbm2ddl.auto = create
exit 0 · SQL lines before closing: 6 · after closing: 0 · GenerationTarget WARN lines: 0 · WARN lines: 0
col customer.version bigint not null
col customer.meal_type enum not null
constraint pause FKRNG439MWJIHY7J0WDMAXSTWYO FOREIGN KEY
rows customer 0 · pause 0
the database after SHUTDOWN: gone (IFEXISTS=TRUE refused, error 90146)
-- u35vcreatedroph2 · H2 over TCP · probe.d.Main --spring.jpa.hibernate.ddl-auto=create-drop
col customer.meal_type character varying(10) not null
col customer.version bigint not null default 0
constraint pause CONSTRAINT_48 FOREIGN KEY
rows customer 4 · pause 2
PROBE emf hibernate.hbm2ddl.auto = create-drop
exit 0 · SQL lines before closing: 6 · after closing: 2 · GenerationTarget WARN lines: 0 · WARN lines: 0
tables: (none)
the database after SHUTDOWN: gone (IFEXISTS=TRUE refused, error 90146)
-- u35vupdateh2 · H2 over TCP · probe.d.Main --spring.jpa.hibernate.ddl-auto=update
col customer.meal_type character varying(10) not null
col customer.version bigint not null default 0
constraint pause CONSTRAINT_48 FOREIGN KEY
rows customer 4 · pause 2
PROBE emf hibernate.hbm2ddl.auto = update
exit 0 · SQL lines before closing: 0 · after closing: 0 · GenerationTarget WARN lines: 0 · WARN lines: 0
col customer.meal_type character varying(10) not null
col customer.version bigint not null default 0
constraint pause CONSTRAINT_48 FOREIGN KEY
rows customer 4 · pause 2
the database after SHUTDOWN: gone (IFEXISTS=TRUE refused, error 90146)
-- u35vvalidateh2 · H2 over TCP · probe.d.Main --spring.jpa.hibernate.ddl-auto=validate
col customer.meal_type character varying(10) not null
col customer.version bigint not null default 0
constraint pause CONSTRAINT_48 FOREIGN KEY
rows customer 4 · pause 2
PROBE emf hibernate.hbm2ddl.auto = validate
exit 0 · SQL lines before closing: 0 · after closing: 0 · GenerationTarget WARN lines: 0 · WARN lines: 0
col customer.meal_type character varying(10) not null
col customer.version bigint not null default 0
constraint pause CONSTRAINT_48 FOREIGN KEY
rows customer 4 · pause 2
the database after SHUTDOWN: gone (IFEXISTS=TRUE refused, error 90146)
```

### changes — four entity changes, `update` then `validate` (both databases; R.315, R.316)

Each variant is its own package and `@Entity` (`probe.v.<name>.VMain`) — **the variant maps the anchor's table**, `customer`, with one
change; each runs over a freshly seeded table. The table below is built from the `cell` lines `harness/chk35.py changes` prints from
the capture, and the receipt compares it with this README, cell for cell (R.261: never typed):

<!-- changes table: begin -->
| the change | database | the entity | `update` ran (the SQL logger) | the start | the catalogue after (the second connection) | `validate` |
|---|---|---|---|---|---|---|
| rename | PostgreSQL | int mealsADay (column mealsaday) | alter table if exists customer add column mealsaday integer not null | refused by the database (WARN: ERROR: column "mealsaday" of relation "customer" contains null values), ready: yes, exit 0 | unchanged - no mealsaday column | refused, exit 1: Schema validation: missing column [mealsaday] in table [customer] |
| rename2 | PostgreSQL | Integer mealsDaily (column meals_daily) | alter table if exists customer add column meals_daily integer | applied, ready: yes, exit 0 | meals_daily integer added (null null null null); meals_per_day kept (2 1 3 1) | not run - a missing column, as rename's |
| len40 | PostgreSQL | @Column(length = 40) on name | alter table if exists customer alter column name set data type varchar(40) | applied, ready: yes, exit 0 | name character varying(60) -> character varying(40) | passes, exit 0 |
| len40, an over-long name in the table | PostgreSQL | the same, a name longer than the new length in the table | alter table if exists customer alter column name set data type varchar(40) | refused by the database (WARN: ERROR: value too long for type character varying(40)), ready: yes, exit 0 | name stays character varying(60) | not run - as len40's (no length checked) |
| drop | PostgreSQL | pricePerMeal removed | 0 statements | nothing to run, ready: yes, exit 0 | unchanged - price_per_meal integer not null, its values kept | passes, exit 0 |
| type | PostgreSQL | mealsPerDay as a String | alter table if exists customer alter column meals_per_day set data type varchar(255) | applied, ready: yes, exit 0 | meals_per_day integer -> character varying(255) | refused, exit 1: Schema validation: wrong column type encountered in column [meals_per_day] in table [customer]; found [int4 (Types#INTEGER)], but expecting [varchar(255) (Types#VARCHAR)] |
| rename | H2 | int mealsADay (column mealsaday) | alter table if exists customer add column mealsaday integer not null | refused by the database (WARN: NULL not allowed for column "MEALSADAY";), ready: yes, exit 0 | unchanged - no mealsaday column | refused, exit 1: Schema validation: missing column [mealsaday] in table [customer] |
| rename2 | H2 | Integer mealsDaily (column meals_daily) | alter table if exists customer add column meals_daily integer | applied, ready: yes, exit 0 | meals_daily integer added (null null null null); meals_per_day kept (2 1 3 1) | not run - a missing column, as rename's |
| len40 | H2 | @Column(length = 40) on name | alter table if exists customer alter column name set data type varchar(40) | applied, ready: yes, exit 0 | name character varying(60) -> character varying(40) | passes, exit 0 |
| len40, an over-long name in the table | H2 | the same, a name longer than the new length in the table | alter table if exists customer alter column name set data type varchar(40) | refused by the database (WARN: Value too long for column "NAME CHARACTER VARYING(40)"), ready: yes, exit 0 | name stays character varying(60) | not run - as len40's (no length checked) |
| drop | H2 | pricePerMeal removed | 0 statements | nothing to run, ready: yes, exit 0 | unchanged - price_per_meal integer not null, its values kept | passes, exit 0 |
| type | H2 | mealsPerDay as a String | alter table if exists customer alter column meals_per_day set data type varchar(255) | applied, ready: yes, exit 0 | meals_per_day integer -> character varying(255) | refused, exit 1: Schema validation: wrong column type encountered in column [meals_per_day] in table [customer]; found [integer (Types#INTEGER)], but expecting [varchar(255) (Types#VARCHAR)] |
<!-- changes table: end -->

`update` adds a column for a renamed field and keeps the old one with its values; it narrows a column for a shorter length and retypes
one for a changed type (`alter column … set data type`); it never drops a column for a removed field. When the database refuses its
statement — a NOT NULL column added to a table with rows, a narrowing over a value that does not fit — Hibernate logs the
GenerationTarget WARN and **the start goes on**: `ready: yes`, the JVM's exit status success, the application running on a schema that
lacks its column. That WARN is this lesson's damage, shown (R.315; R.213 refuses a WARN in a schema step everywhere else — this unit is
its one labelled exception). The check reads the WARN line beside `ready: yes`, twice: the line shown and the log's count.

**The over-long name (RED #1805):** built by this script (`printf`, one name repeated), inserted by the second connection before the
narrowing `update`; its length is the run's printed line, and `chk35.py` asserts that line equals the name's own length and that the
name is longer than the length the statement asks for — both read off the run. This README says only what that line says:

```text
the over-long name, built by this script (one name repeated, printf): KavyaKavyaKavyaKavyaKavyaKavyaKavyaKavyaKavya
length: 45 characters (${#LONG})
inserted by the second connection: insert into customer (name, meals_per_day, price_per_meal, meal_type) values ('<the name>', 2, 110, 'VEG')
```

**The failure receipt (R.298):** B — `update` on the length change narrows the column; A — `validate` passes the same entity, it checks
no length (R.316); A′ — `validate` refuses the type change. Three labelled runs, each a filed step above, printed side by side at the
capture's end, with the exception chain of one refusal:

```text
the failure receipt - three labelled runs, side by side (PostgreSQL; each a step above):
B  len40 · update:   alter table if exists customer alter column name set data type varchar(40) · exit 0
A  len40 · validate: PROBE ready: yes · exit 0 · SQL lines 0
A' type · validate:  PROBE ready: no · exit 1 · Schema validation: wrong column type encountered in column [meals_per_day] in table [customer]
the exception chain of one refusal (rename · validate on PostgreSQL, its PROBE cause lines, grep -o):
org.springframework.beans.factory.BeanCreationException <- jakarta.persistence.PersistenceException <- org.hibernate.tool.schema.spi.SchemaManagementException
```

The WARN, as PostgreSQL's run logged it:

```text
WARN  [main] org.hibernate.tool.schema.internal.ExceptionHandlerLoggedImpl : GenerationTarget encountered exception accepting command : Error executing DDL "alter table if exists customer add column mealsaday integer not null" via JDBC [ERROR: column "mealsaday" of relation "customer" contains null values]
```

### xcheck — Hibernate's DDL over the anchor (R.252)

Hibernate's schema generation writes its script over the anchor's libraries (`probe.x.XMain`, unit 29's, `scripts.action=create`, a
file, never run), and it is the index lesson's (*Reading the SQL Hibernate Writes*) byte for byte: `xcheck.sql` is that script, and
the receipt diffs it against `../c7-unit34/xcheck.sql`.

```text
Hibernate's DDL over the anchor's libraries - probe.x.XMain, scripts.action=create (a file, never run):
exit 0 · HHH000001: 1
.harness/ddl-anchor.sql - every line:
create table customer (meals_per_day integer not null, price_per_meal integer not null, id bigint generated by default as identity, version bigint not null, name varchar(60) not null unique, meal_type enum ('NON_VEG','VEG','VEGAN') not null, primary key (id));
create table pause (days integer not null, customer_id bigint not null, id bigint generated by default as identity, primary key (id));
create index pause_customer_id_idx on pause (customer_id);
alter table if exists pause add constraint FK<name> foreign key (customer_id) references customer;
the anchor's md5: 7f6942f0ed8bf296d661f629557f26c6 · the filed xcheck.sql: 7f6942f0ed8bf296d661f629557f26c6 · cmp: the same, byte for byte · the index lesson's xcheck.sql: 7f6942f0ed8bf296d661f629557f26c6 · diff: 0 lines
```

### exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s block, then `exercise/SOLUTION.md`'s, as written, in ONE `env -i` shell, `/bin/bash` and again `/bin/zsh -f`;
each file's "What it prints" block is compared with what it printed. PostgreSQL-free (R.196, R.273): ONE JVM on H2 in its own memory, a
`diner` table of its own. Broken: `update` retypes the integer column. Solved: `validate` refuses the start — the refusal is the
solution's success here; the broken run, the column retyped, is the control (R.312: never the refusal).

## The version lines (R.222, R.246, R.270, R.329)

Every harness JVM prints Hibernate's, Spring Data JPA's, Spring Framework's and Spring Boot's versions before its context starts, and
Hibernate's own `HHH000001` line; `chk35.py` asserts each in every JVM. **No Flyway, Liquibase or Testcontainers jar on this unit's class
path:** the receipt counts them in the anchor's `lib/` (`ls lib | grep -c -i 'flyway\|liquibase\|testcontainers'`) and every JVM prints
the three classes absent — R.329 asks nothing of this unit. The PostgreSQL driver is the harness's: the anchor's `lib/` holds none
(asserted), and every PostgreSQL JVM adds `.m2-demo/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar` — + the harness's driver
(R.335's form).

## Call-backs, by title (R.224)

- *Your First Entity and EntityManager* — Boot's `create-drop` default on TiffinBox's in-memory URL dropped its table at shutdown;
  `default`'s in-memory run shows the same two drops after `closing`.
- *Reading the SQL Hibernate Writes* — Hibernate's DDL script over the anchor, `xcheck`; its hash is the one that lesson filed.
- *Flyway: Versioned Migrations* — the next lesson (registry title, `java7_series.TITLES["36"]`): `validate` beside a migration, never
  `update`.

## The commands this unit adds

Read by `receipts.sh` from this README (each line asserted present, then run):

```bash
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/src/probe/d/V.java harness/src/probe/d/Run.java harness/src/probe/d/Main.java harness/src/probe/d/Db.java harness/src/probe/v/*/VMain.java harness/src/probe/x/XMain.java
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*$CPX" $MC "${A[@]}"
cd .harness/run && exec perl -e 'alarm 3000; exec @ARGV' java -Duser.language=en -Duser.country=US -Dh2.bindAddress=127.0.0.1 -cp "../anchor/tiffinbox-web/target/extracted/lib/h2-2.5.250.jar" org.h2.tools.Server -tcp -tcpPort 20147 -ifNotExists
docker -H "$DH" run -d --pull never --name c7u35-pg -p 127.0.0.1:20148:5432 -e POSTGRES_USER=sa -e POSTGRES_PASSWORD_FILE=/run/pgpw -v "$U/.harness/secrets/pgpw:/run/pgpw:ro" postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
docker -H "$DH" exec c7u35-pg pg_isready -U sa -h 127.0.0.1 -q
docker -H "$DH" exec c7u35-pg psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c "drop database if exists $DB with (force)" -c "create database $DB"
docker -H "$DH" exec c7u35-pg psql -U sa -d postgres -qAt -v ON_ERROR_STOP=1 -c "drop database $DB with (force)" -c "select coalesce(string_agg(datname, ', ' order by datname), '(none)') from pg_database where datname like 'u35%'"
docker -H "$DH" exec c7u35-pg psql -U sa -d "$DB" -qAt -v ON_ERROR_STOP=1 -c "$Q"
```

## The repository, and the network

Every Maven run is `mvn -o` against this unit's own `.m2-demo`, seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s5/`
alone (brief ⚑13: this harness needs no new jar; the PostgreSQL driver 42.7.14 is in it). One Maven run: the anchor's package line,
offline, `-DskipTests` — it prints `offline: yes` and its `Downloaded from` count. **No network act:** `docker run --pull never`; the
version sweep is the brief's (`_research/spring-boot-metadata-2026-11-16.xml`, `spring-data-bom-metadata-2026-11-16.xml`,
`hibernate-core-metadata-2026-11-16.xml`: Hibernate 7.4.16.Final exists, the BOM manages 7.4.13.Final, not adopted).

## The locale

Every JVM runs with `-Duser.language=en -Duser.country=US` (the receipt refuses a capture's JVM line without it), and the harness JVMs
with `-Dstdout.encoding=UTF-8`.

## The folders, the harness and the ports

- `anchor` → `../c7-unit34/after` (a link; `readlink` asserted, its tree hashed and pinned). Never built in place: copied to
  `.harness/anchor` and built there.
- `harness/src/probe/d` — `Main` (the anchor's entities alone, `WebApplicationType.NONE`), `Run` (the context, the EMF's property,
  `ready`, the `closing` marker, the causes), `V` (the version lines, the three absent classes), `Db` (the seed by the shipped
  `Database`, and on H2 the second connection: the catalogue, one statement, the drop), `ex/Ex` (the exercise, compiled only by its own
  lines). `harness/src/probe/v/{rename,rename2,len40,drop,type}/VMain.java` — the variants, each mapping the anchor's table.
  `harness/src/probe/x/XMain.java` is unit 29's. No `Thread.sleep` in `harness/src` (grepped).
- `harness/logback.xml` (one line per event; `org.hibernate.SQL` DEBUG; `org.hibernate.orm.core` INFO by a run option, for
  `HHH000001`; the rest WARN); `harness/chk35.py` (the checks), `harness/s35.py` (the prose gate, its self-test first),
  `harness/tree35.py` (unit 33's `tree33.py`, byte for byte), `harness/dur7.py` (the builders' `dur7.py`, byte for byte, untouched).
- **Ports (§P, 20140-20149):** 20147 the H2 TCP server (`127.0.0.1` alone, asserted); 20148 the container (`docker port` asserted:
  `127.0.0.1:20148` alone); 20140-20146 and 20149 never bound; the harness JVMs bind none. All ten are asserted free at the start and the
  end.
- **Alarms (R.247):** every harness JVM and every `probe.d.Db` JVM `alarm 240`; the H2 server `alarm 3000` (it lives for the whole run);
  the exercise's JVM `alarm 120`.
- **The container:** `c7u35-pg` from the pinned digest, `sa` + a generated password in `.harness/secrets/pgpw` (0600), read by
  `POSTGRES_PASSWORD_FILE` and by the JVMs' `-Dpg.pwfile` (never on a command line, never in a log); every docker call on the pinned
  socket, `docker -H "$DH"` (R.332), the baselines asserted non-empty first; removed with its volume, `rm -fv`, and the volume count
  asserted unchanged (R.322).

## Masks, filters and hygiene — every one, declared

The mask: the password (`<pw>`), this folder (`…`), its parent (`…/..`), the home folder (`~`), the user's name (`<user>`), the JDK's
version (`PROBE version: Java <version>`), identity hashes (`@…`) — self-tested on planted lines first. The filter: a JVM's capture shows
its `PROBE` lines, `HHH000001`, every `org.hibernate.SQL` line and every `org.hibernate.tool.schema` WARN; its counts are read off the whole
log. Hygiene, asserted over every capture: no absolute path, no unit number, no log time, no thread number, no OS or JDK version token,
no time figure, no stack frame, no password, no URL; no raw copy of the password in any raw capture pass or log; no H2
database file outside `.harness`.

## Interrupted

Ctrl-C at any point: the trap stops what the run started (a JVM, a Maven, the exercise's shell, the H2 server), sweeps its process
group, removes the container with its volume, drops the unfinished capture passes and exits 130.

Measured on the script as committed, `env -i ./receipts.sh` started as its own process group (SIGINT at its default, as a terminal
leaves it) and sent SIGINT to the group, at four points: **mid-build** (Maven running), **mid-H2-server** (just after the server
listened), **mid-container** (just after `pg_isready`) and **mid-harness** (a harness JVM on PostgreSQL in `default`): each exit 130,
no container `c7u35-pg`, the volume count the same as before the run, nothing listening on 20140-20149, no `.r-lock`, no unfinished
capture pass, the published captures unchanged, no JVM of this run left. One reading to know: in the mid-build run one Maven process
was still alive when the driver first looked, just after the receipt's exit (the trap sends it SIGTERM and does not wait for it); it was gone within the
settle wait of a re-run of that point (exit 130, nothing left). A first attempt at these interrupts started the receipt as a
background job of a script — which starts it with SIGINT ignored, so the trap never ran; those runs were stopped by SIGTERM (the trap
ran: the container and its volume removed) and are not the measurement.

## Exercise

`exercise/README.md` (the spoken line, its word count printed by the receipt, `wc -w`) and `exercise/SOLUTION.md`; RE-MEASURE 13: both
files run as a viewer runs them, `env -i`, bash then zsh.

## The ledger rows this unit pays

**S2 ⓘ3** (Hibernate's DDL ≠ `Database`'s for `meal_type` on H2) — **closed**: `validate` passes on both databases (`values`). No C7 row
(the brief's §LEDGER: 35 pays none); `PROMISE-LEDGER-2026-11-01.md` not edited.

## RE-MEASURE — the brief's items this unit settles

- **13** — the exercise as README + SOLUTION, bash and zsh, `env -i`: `exercise`.
- Not measured, a README line only (the brief's hazard): `spring.sql.init` beside `ddl-auto` (`defer-datasource-initialization`) —
  any later course that seeds by `data.sql` measures it.

## What differed from the brief

- **The anchor had already moved (R.211).** The brief's batch order (36 → 35) built 36 first, so `../c7-tiffinbox` is 36/after from this
  unit's first run: the receipt's diff is never empty and prints its note; the pin (`harness/tree35.py`) is the guard. The root
  `.gitignore` already held this unit's five lines (landed in 36's commit, as its README says) — verified, not edited: the brief's "in
  35's commit" line was overtaken by the batch order.
- **No tests run.** The anchor is built with `-DskipTests` (no anchor change, nothing to guard); the build line prints its `Tests run:`
  count, and the receipt asserts it is none.
- **The second connection on H2 is a harness class** (`probe.d.Db`, plain JDBC over TCP, its own JVM) rather than H2's Shell — one JVM
  does the seed and the first catalogue read, another the last read and the drop; on PostgreSQL it is psql in the container (36's form).
- **H2's database per run dies by `SHUTDOWN`** (then a connection with `IFEXISTS=TRUE` is refused) — the brief's "dies when the server
  stops" would have kept every run's database alive across the three capture passes; this makes R.178's check per run on both
  databases.
- **`default`, `values` as printed-line blocks, `changes` as the cell table.** The brief asks for a `default` and a `values` table; this
  README shows them as `text` blocks of the lines the runs printed (R.302 checks every line), and only the `changes` table is built
  from `cell` lines (R.261, the brief's table rule).
- **The over-long name** is one name repeated by `printf` in `receipts.sh` (not the probe's fixture: RED #1805), its length printed
  by the script (`${#LONG}`) and asserted by `chk35.py` against the name's own length.
- **`create` logs two more SQL lines on PostgreSQL than on H2** (`set client_min_messages = WARNING` and the guarded drop of
  Hibernate's own foreign key) — both counts read off the logger and printed in `values`.
- **The exercise's entity** is a `Diner` of its own on a `diner` table seeded by plain JDBC in the same JVM (the brief's form); the
  table's `name` column is the entity's default length, so `update` changes one column only.
- **The prose rule for numbers (R.302)** is applied per sentence by `s35.py` to the brief's list of numbers, with an
  exit status, a section, unit, step, course or rule number aside; the counts live in the printed blocks and the values block.

## Planted faults — each caught (R.65, R.226)

Each plant on a scratch mirror of this folder (beside links to the units it reads; `.m2-demo` copied where the plant needs a build) or on
a copy of a published capture; each exit 1, nothing written to this unit (its captures and `receipts.md5` unchanged). Receipt plants,
the mirror's `receipts.sh` run with the one change:

The prose plants, each one sentence added to a README paragraph (quoted here inside a block, which the gate does not read):

```
"update only adds columns." in a README paragraph → `s35`: R.315, update said as adding only.
"validate refuses the length change on the name." → `s35`: R.316, the length run voiced as refused by validate.
"With update the start fails when the database refuses the new column." → `s35`: R.315, a WARN run said as a stop.
"The name has many letters." → `s35`: R.302 (RED #1805), a hand count of letters or characters.
"The column narrowed to 40." → `s35`: R.302, a typed number (first run of this plant: not caught — the rule let a number before a full stop pass; the rule was fixed and the plant re-run, caught).
"The anchor holds 91 libraries." → `s35`: R.302, a jar count typed.
"The kitchen cooks <a dish from the gate's own list>." → the dish-name gate (R.215).
"Hibernate generates the schema." → `s35`: §Voice.
"<a placeholder word from the gate's own list>" alone on a line → the placeholder gate.
"It ran alter table if exists customer add column x integer." → `s35`: typed SQL (R.225).
"The start goes on instantly." → `s35`: S4.7's family.
```

- a byte added to the mirror's copy of `c7-unit34/after/README.md` → the tree pin: R.211, the hash printed beside the pinned one.
- `dk()` unpinned (`docker "$@"`) under `DOCKER_HOST=tcp://127.0.0.1:1` → R.332's baseline: `docker … info` fails, the run stops before
  any comparison.
- `rm -fv` → `rm -f` in `pgrm` → R.322's static check; and with that check taken out and the volume count asserted right after the
  container in the mirror → `R.322: the volume count moved, 315 -> 316`; the one volume that plant left was removed by its id after it.
- the drop step removed (the run lists the databases without dropping its own) → R.178's per-run check in `chk35.py default`:
  `FAIL u35dpg: R.178 - the database dropped, none named u35… left`.
- a wrong published hash (`receipts.md5`'s `default` line, one digit) → `default is not the published capture`.

Check plants, `harness/chk35.py` on an edited copy of a published capture (the published copy passes, exit 0, as the control):

- the GenerationTarget WARN line dropped from `rename` · `update` (PostgreSQL) → `the GenerationTarget WARN lines shown (0) = the log's
  count (1)`.
- the over-long name's `length:` line edited → `the printed length (44) = the name's own length (45) - R.302`.
- a database kept (its name left in the listing) → `R.178 - the database dropped, none named u35… left`.
- `create`'s rows after the JVM edited to the seeded ones → `create PostgreSQL: rows by the second connection …` (R.276: a check shown
  failing).
- `HHH000001` removed → the version line check; Spring Framework's version edited → the same (R.222, R.270).
- the solution's printed block replaced by the broken one, in both shells → `exercise, solved: validate refused the start …` (R.196).
- one cell of the changes table typed in a README copy → `the table's line … is the one the cell lines build` (R.261).

- a changed "What it prints" line (`PROBE ready: yes` → `no` in a copy of `exercise/README.md`) → the receipt's own comparison line,
  run on that copy against the published capture: the two differ (that comparison sits after the `exercise` capture, so the plant ran
  the line alone, not the whole receipt).

Not run as a plant: "a check that cannot fail" as a parsed-source refusal (R.276's `ast` walk is the builders'); this unit's checks
were each shown failing above instead.

## CARRIED

- `spring.sql.init` beside `ddl-auto` — not measured (above).
- The 314 orphaned Docker volumes the earlier Course 7 receipts left (the brief's §BLOCKED) — Vivek's call; this unit adds none
  (the volume count, asserted).

## For RED

- `rename2`'s and the over-long run's `validate` cells say "not run": the brief plans no `validate` for them (the missing column is
  `rename`'s, the length `len40`'s).
- The `default` capture's in-memory run has no second connection by design (the database lives in that JVM); its witness is the SQL
  logger's lines on both sides of the `closing` marker and the EMF's property.
- `exit` is the one word after which a digit is allowed in this README's prose (`s35.py`'s `NUMOK`): an exit status is not one of the
  numbers the video says. RED may want it narrowed.
- The variant entities map only `customer`; `pause` is never in their persistence unit, so `update`/`validate` with a variant leave it
  alone (its rows, its foreign key) — the catalogue shows it.
- H2's constraint and index names are H2's own (`CONSTRAINT_48`, `FKRNG439MWJIHY7J0WDMAXSTWYO`); they are deterministic per fresh
  database and part of the hashed captures.
