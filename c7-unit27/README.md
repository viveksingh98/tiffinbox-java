# c7-unit27 — Optimistic Locking with @Version

Course 7 · Data with JPA & Hibernate · Section 4 (Transactions), its fifth unit and **its second and last change to the anchor** (brief
⚑1, C2; the course's ninth): `before` is the link to `../c7-unit26/after`, `after/` is this unit's tree, and `../c7-tiffinbox` equals
`after/` from this unit's commit on. **`after/` is Section 4's frozen anchor**: unit 28 builds over it through its link and changes
nothing in it. Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.2** (Spring Framework 7.0.10, Spring Data JPA 4.1.2,
Hibernate ORM 7.4.13.Final), 2026-11-12, **on H2 2.5.250** only (brief ⚑2: every SQL line H2 = PostgreSQL in the probe but the
INSERT's form; this unit's receipt runs H2, so its claims are said "on H2"). Two people edit the same customer; without a version, the
second save silently wins. A **version column** makes Hibernate check, in the UPDATE itself, that nobody changed the row since it was
read — and the loser gets an exception instead of losing quietly. TiffinBox's customers get one.

**The anchor changes (C2).** `receipts.sh` prints `diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c7-tiffinbox` at its
start and end — empty in every run of record — and, should a later course change the anchor, prints a note instead, never a stop
(R.211). Each tree is copied under `.harness/` and built there with the README's package line, offline; the harness runs over the
copies' extracted libraries (91 each).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 9 captures, 3 runs each; every spoken number checked after its capture; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version` and `javac -version` say 25.) It **dies** when a
check after a capture fails, and when a capture's md5 differs from `receipts.md5`. **Start it in a process group of its own** (a
terminal's foreground job is one): `sweep()` stops only processes of its own group. `.m2-demo` must be seeded first (below).

<!-- runs: begin -->
**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`), a session of its own
(`perl -MPOSIX -e 'setsid; exec @ARGV'`), `.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681
files). Development runs fixed the captures and the checks; two full passing runs wrote every capture 3/3 with the same md5s, and those
are `receipts.md5`. **The runs of record, on the script as committed (`receipts.sh` md5 `f5fc28b49cce946c0427e79dd45192a4`): 310 s under `./receipts.sh`**
(/bin/bash 3.2.57, 2026-11-12 from 07:11 CET), **588 s under `bash receipts.sh`** (Homebrew bash 5.3.9, from 07:17 CET, beside five
plant runs on scratch mirrors), **338 s from a sealed fresh clone** (below, from 07:27 CET) **and 364 s on the tree as committed** (`./receipts.sh`, from 07:42 CET; this README final but this one figure): each exit 0, all 9 captures 3/3 =
published, every check passed, every Maven run `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`, the anchor note empty
at the start and the end, nothing listening on 20060-20069 at the end; each terminal log through `check_unit7.py 27 --runlog` —
`RESULT (run logs): PASS` (the unit gate: no 27 script yet). **Nothing was downloaded.**

**A sealed fresh clone (R.129)** — unit 26's recipe: a `git clone` of tiffinbox-java at `2feb515` (`file://`) into a path **with a space**
(`…/sealed 27/tiffinbox-java`, in the session's scratch folder), this commit's 64 files put in as git will take them (`git ls-files -m -o
--exclude-standard c7-unit27 c7-tiffinbox c7-unit26`, links kept); a mirror of the seed as Maven's only repository (`file://`), dead
proxies for http and https, the pre-flight `dependency:get` of an absent artifact refused with `Downloading from sealed: file://` only;
the clone's `.m2-demo` seeded from that copy; `./receipts.sh` `env -i` (the dead proxies in its environment).
<!-- runs: end -->

Published hashes: version `59491a34d16be4a7e9712d19454e854b` · race `4a10e02c0dc91b5ed18a907394e6e70d` · merge `563508c61fbc64454ebc9947e8411e32` · modes `8f5776a6ed5aa45a0bf4e3795f43453e` · anchor `0395fffa2f762695f1f9eb196c9ee585` · seven `0a546377d3dbbefc1b14219bd097dfe6` · tests `f9fbfce876ab0f49bd54b902e208f243` · xcheck `9fe6285ee92a96c5cf2a9dcfea726dd7` · exercise `e9925d1b992f8cf779d4cca3afab8e81`.

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line, R.225 — a SQL string
typed in this README outside this block is refused; inside it every statement is the logger's, read off the capture):

<!-- values: begin -->
the values the video may say: on H2 2.5.250, Spring Framework 7.0.10, Spring Data JPA 4.1.2, Hibernate 7.4.13.Final - version: insert into customer (meal_type,meals_per_day,name,price_per_meal,version,id) values (?,?,?,?,?,default) binds meal_type=VEG · meals_per_day=2 · name=Kavya · price_per_meal=110 · version=0; an edit: update customer set meal_type=?,meals_per_day=?,name=?,price_per_meal=?,version=? where id=? and version=? binds meal_type=VEG · meals_per_day=3 · name=Kavya · price_per_meal=110 · version=1 · where id=5 · where version=0; read back mealsPerDay 3 · version 1 · race B (no version, 3/3): Ravi 3, both committed, no exception; A (@Version, 3/3): Ravi 7, A threw org.springframework.orm.ObjectOptimisticLockingFailureException: Unexpected row count (expected row count 1 but was 0) [update customer set meal_type=?,meals_per_day=?,name=?,price_per_meal=?,version=? where id=? and version=?] for entity [com.tiffinbox.CustomerEntity with id '1'] ← org.hibernate.StaleObjectStateException ← org.hibernate.StaleStateException · merge: org.springframework.orm.ObjectOptimisticLockingFailureException: Row was already updated or deleted by another transaction for entity [com.tiffinbox.CustomerEntity with id '1'], updates sent 0 · modes: OPTIMISTIC select version as version_ from customer where id=?; OPTIMISTIC_FORCE_INCREMENT update customer set version=? where id=? and version=? (version=1 · where id=1 · where version=0) · anchor B (the entity alone): exit 1, Column "CE1_0.VERSION" not found; SQL statement: SQLState 42S22; A: 201 · 409, the seeded edit binds meal_type=VEG · meals_per_day=3 · name=Ravi · price_per_meal=120 · version=1 · where id=1 · where version=0; C (nullable, 18 tests passed): org.springframework.transaction.TransactionSystemException: Could not commit JPA transaction ← jakarta.persistence.RollbackException: Error while committing the transaction [Cannot invoke "java.lang.Long.longValue()" because "current" is null] ← java.lang.NullPointerException: Cannot invoke "java.lang.Long.longValue()" because "current" is null · seven: 466c20ed7e0d5439cb052f32ce09de1b, SQL lines 7, during the seven 5, both trees; the select lists read ce1_0.version · tests: 18 (14/3/1) · xcheck: f595637014e786fa38606859951e4f97 -> 9cf92b8cae3abfd0f1c0706bfe7a4373, the one line: version bigint not null · exercise: A committed: mealsPerDay 3, Ravi mealsPerDay 3 -> @Version: A threw, Ravi mealsPerDay 7 (22 words)
<!-- values: end -->

### C2 — the change, file by file, and every sentence it rewrote (R.250)

`diff -rq before after` (the `anchor` capture prints it, and each source's diff whole):
- **`tiffinbox-core/…/CustomerEntity.java`** — `import jakarta.persistence.Version;`, **`@Version private Long version`** with its
  Javadoc (Hibernate writes 0 with an INSERT, adds one with every UPDATE and puts the value it read into that UPDATE's where clause, so
  a stale edit changes no row and fails; never set by hand), and **`public Long getVersion()`**. The class Javadoc gains a paragraph for
  unit 27, in its own style: what the column is, that Hibernate checks it in the UPDATE itself, and that it is in neither the record
  `Customer` nor the JSON.
- **`tiffinbox-core/…/Database.java`** — the customer table's last column is now `version BIGINT NOT NULL DEFAULT 0` (`meal_type`'s line
  gains its comma), with a comment above the statements: the column `CustomerEntity`'s `@Version` maps; NOT NULL with a default, because
  the seed's INSERTs name no version and each seeded row must start at 0 — a nullable column would leave them null and the first edit of
  a seeded customer would fail at its commit (C, below). The seed's INSERTs are unchanged; the pause table is untouched.
- **`README.md`** (the anchor's) — a header note (Section 4's second and last change; this tree is Section 4's frozen anchor), the
  `## Course 7 · unit 27` section, and **the four sentences that said Boot's own DDL for the entities is unit 09's** — in the unit 15,
  16, 17 and 26 sections — rewritten in place: "is unit 09's" → "was still unit 09's" (unit 26's: "still unit 09's"), each followed by
  the note *(Course 7, unit 27: it moved there — the `version` column; its section below)*.

**The R.250 gate, before any build:** the old sentences — 6 lines of `before/README.md` (two whole, their prefix three times with the
split one, unit 26's) — 0 in `after/README.md`, the unit 27 note there 4 times; the old md5 (unit 09's) 0 anywhere in `after/` (sources
and prose); in this README the old md5 only on a line that names the new one beside it (decided: the values block and the xcheck
section say both, as R.252 asks). `after/`'s `CustomerEntity` carries the annotation, the field and the getter, `before/`'s none;
`after/`'s `Database` creates the column, `before/`'s has no version. **Kept, still true:** the record `Customer` stays four fields (no
sentence in `after/` states the customer table's column count — grep: none — so none was false); `CustomerEntity`'s `@Size`/`@Column`
paragraph and its "Hibernate's generated DDL takes `@Size`'s limit" (unchanged: the name's line in the script did not move). Unit 09's
own README states the old md5 (its lines 59, 278, 337, 440) — its own history, not edited (that folder is not this unit's).
`TiffinBoxWebTest`, `FullStackTest` and `FeedTest` are untouched: the change forces nothing there — measured 18/18 on `after/` (`tests`,
and inside the `after/` build) and on C.

### The column, the race, a stale copy, two lock modes (harness, `version`, `race`, `merge`, `modes`)

- **The column (`version`, over `after/`'s libraries):** a new customer, Kavya, saved through the anchor's own `CustomerEntityRepository`
  — Hibernate's INSERT names `version` before the id and binds **0** (TiffinBox's own INSERT shape; the values line holds the statement
  and its binds, named by the statement's own column list); an edit in one transaction (`Edit27.edit`, Spring's `@Transactional` through
  its proxy) — the UPDATE is sent at the commit, after the method returned, sets `version` to **1** and carries the old **0** in its
  where clause, `where id=? and version=?`; the second connection reads version 1; read back, `findById` says version 1.
- **The race (`race`, S4.6, S4.18, the failure receipt as B):** two threads named A and B, ordered by two latches — A loads Ravi (meals 2),
  B loads Ravi, B adds 5 and commits, then A adds 1 and commits. The order is read off the capture (the thread on every log line), and
  checked per round by `order.py`: A loaded < B loaded < B's commit < B's UPDATE < A's change < A's commit < A's UPDATE. **B** (over
  `before/`'s libraries — `CustomerEntity` with no version): both commit, no exception, **Ravi 3** — B's +5 is gone; A's UPDATE binds
  meals 3 `where id=1` and writes over it. 3/3 rounds in its JVM (and the capture itself three times, hashed). **A** (over
  `after/`'s): B's UPDATE binds version 1 where version 0 and matches; A's UPDATE binds the same — **where version 0 — and matches no
  row**; A's commit throws **`org.springframework.orm.ObjectOptimisticLockingFailureException: Unexpected row count (expected row count 1
  but was 0) [update …] for entity [com.tiffinbox.CustomerEntity with id '1']`** ← `org.hibernate.StaleObjectStateException` (the same
  message) ← `org.hibernate.StaleStateException` (the statement alone); the manager's `Initiating transaction rollback after commit
  exception`; **Ravi 7**, version 1. 3/3. The messages name `CustomerEntity` itself (RE-MEASURE 6: the probe's race ran on `VCustomer`).
  **A′**: `after/` copied again and built again — prints what A printed (R.1).
- **A stale copy (`merge`):** `findById` returns a copy of Ravi at version 0 (its call's transaction committed; the copy is detached);
  another transaction edits Ravi (version 1); the copy's meals set to 9 and `CustomerEntityRepository.save(stale)` → `merge` loads the
  row (one SELECT), sees version 1 ≠ 0 and throws **`ObjectOptimisticLockingFailureException: Row was already updated or deleted by
  another transaction for entity [com.tiffinbox.CustomerEntity with id '1']`** ← `StaleObjectStateException` — **no UPDATE sent** (0
  update lines between the save's markers), `save`'s transaction rolled back, the row unchanged (meals 3, version 1). **Two messages,
  one class** (READ FIRST 9): the flush's row count, the merge's version check.
- **Lock modes (`modes`):** `em.find(CustomerEntity.class, 1L, LockModeType.OPTIMISTIC)` inside a transaction that changes nothing → at
  the commit one SELECT of the version alone; the row's version stays 0. `OPTIMISTIC_FORCE_INCREMENT` → at the commit an UPDATE of the
  version alone — no data column in its SET — binding version 1 where version 0; meals unchanged, version 1. Both statements are in the
  values line.

S4.8 here: none of these is a database refusal — there is no SQLState: the row count is Hibernate's own check of the JDBC update count
(`StaleStateException`), and the merge's is Hibernate's comparison of two versions. The names are asserted with their packages, each
link of the chain in order. The refused name — Hibernate's older message with its clause about a wrong unsaved value — is in no line of this unit's
prose (a gate, below).

### TiffinBox — B, A, A′, C (S4.9, `anchor`)

A column a proxy reads is proved by a start and by the route its answer could change. **B** (labelled: the entity alone — `after/` with
`before/`'s `Database.java`, so no column; `.harness/anb`, the one file asserted the only difference, built `-DskipTests`): the start
fails by itself, **exit 1**, port 20060 never bound — `HHH000247: ErrorCode: 42122, SQLState: 42S22`, then H2's `Column "CE1_0.VERSION"
not found; SQL statement:`, Boot's `Application run failed` with
`org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'tiffinBoxServer': Invocation of init method
failed` ← `org.springframework.dao.InvalidDataAccessResourceUsageException` ← `org.hibernate.exception.SQLGrammarException` ←
`org.h2.jdbc.JdbcSQLSyntaxErrorException` (S4.8: each class with its package, H2's message, the first cause H2's own, the SQLState
42S22 as Hibernate logged it). The first bean that reads the table at start is `TiffinBoxServer` (its init method, as the message
says). **A** (`after/`): ready; POST Kavya **201**, the same again **409** (`a customer named Kavya already exists`, Hibernate's two
WARN lines for the refused INSERT, 23505); `GET /customers` Kavya Meera Priya Ravi Sunil; then the harness's first edit of a seeded
customer over `after/`'s libraries: Ravi read at **version 0** (the column's default), the UPDATE binds 1 where 0, Ravi 3, version 1.
**A′**: `after/` built again, on 20062 — prints what A printed. **C** (labelled: a nullable column — `after/` with the column's `NOT
NULL DEFAULT 0` taken off, `version BIGINT`, the one line asserted; built with its tests — **18 passed: the tests did not notice**):
TiffinBox starts and answers as A does (201, 409, the same names) — the start does not tell; the first edit of a seeded customer (the
harness over C's libraries): Ravi read at **version null**; the commit fails — **`org.springframework.transaction.TransactionSystemException:
Could not commit JPA transaction`** ← `jakarta.persistence.RollbackException: Error while committing the transaction [Cannot invoke
"java.lang.Long.longValue()" because "current" is null]` ← **`java.lang.NullPointerException: Cannot invoke "java.lang.Long.longValue()"
because "current" is null`** — each link asserted; Ravi unchanged (meals 2, version null). Hibernate's own increment, not a database's
refusal: no SQLState. **The plant "a nullable column in A"** (below) fails the seeded-edit check.

The guards (R.190): the seven `466c20ed…` before and after (the version is in no answer — the record `Customer` stays four fields, the
JSON unchanged, said, not hidden), Hibernate's SQL line count the same, and the 18 tests. The seven's statements **do** differ by one:
`after/`'s select list for `GET /customers` reads the version column too (the values line; the `seven` capture prints the one differing
line) — the proof the column is read.

### The DDL moved (R.252, `xcheck`)

`probe.x.XMain` (`@EntityScan("com.tiffinbox")` alone) twice, `scripts.action=create` (a file, never run). The md5 moved: `f595637014e786fa38606859951e4f97` → **`9cf92b8cae3abfd0f1c0706bfe7a4373`**.
Over `before/`'s libraries the script's md5 is the old one — the owning-side lesson's, unit 09's (its README names it, its published xcheck
capture asserted); over `after/`'s it is the new one, byte for byte the script filed in this folder as
`xcheck.sql` (RED #1209: the receipt files its `.sql`; unit 28's `xcheck` compares with this one). `diff` of the two: **one line** — the
customer table's `create table` — and taken out of `after/`'s line, `, version bigint not null` leaves `before/`'s exactly. **The DDL
callback (R.252) said as moved:** the hash is no longer the one in the lesson called One To Many, Many To One and the Owning Side
(`f595637014…` → `9cf92b8c…`, the one differing line `version bigint not null`); unit 28 says "the same hash as in the lesson called
Optimistic Locking with At-Version".

## The commands this unit adds

```
javac -parameters -d .harness/hc -cp ".harness/before/tiffinbox-web/target/extracted/lib/*" harness/src/probe/t/Edit27.java harness/src/probe/t/H.java harness/src/probe/t/Main.java harness/src/probe/t/Run.java harness/src/probe/t/Seed.java harness/src/probe/x/XMain.java
javac -parameters -d .harness/hce -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/src/probe/t/Edit27.java harness/src/probe/t/H.java harness/src/probe/t/Main.java harness/src/probe/t/Run.java harness/src/probe/t/Seed.java harness/src/probe/x/XMain.java
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../before/tiffinbox-web/target/extracted/lib/*" probe.t.Main "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hce:../after/tiffinbox-web/target/extracted/lib/*" probe.t.Main "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hce:../ana2/tiffinbox-web/target/extracted/lib/*" probe.t.Main "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hce:../anc/tiffinbox-web/target/extracted/lib/*" probe.t.Main "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -cp "../hce:../after/tiffinbox-web/target/extracted/lib/*" probe.x.XMain "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -cp "../hce:../before/tiffinbox-web/target/extracted/lib/*" probe.x.XMain "${A[@]}"
cp before/tiffinbox-core/src/main/java/com/tiffinbox/Database.java .harness/anb/tiffinbox-core/src/main/java/com/tiffinbox/Database.java
perl -pi -e 's/^( +version +BIGINT) +NOT NULL DEFAULT 0$/$1/' .harness/anc/tiffinbox-core/src/main/java/com/tiffinbox/Database.java
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.org.hibernate.SQL=debug
```

**The two `javac` lines** compile the harness twice with `-parameters`: against `before/`'s libraries into `.harness/hc` (`race` B —
26's `CustomerEntity`, no version; `H` reads the version field by reflection, so one source compiles over both trees) and against
`after/`'s into `.harness/hce` (every other harness run, `xcheck` included). **The six java lines** run `probe.t.Main` over `before/`'s
libraries, over `after/`'s, over A′'s (`.harness/ana2`) and over C's (`.harness/anc`) — the last two with `.harness/hce`'s classes: C's
and A′'s `CustomerEntity` are `after/`'s — and `probe.x.XMain` over `after/`'s and over `before/`'s, each from `.harness/run` (`V` the
JVM flags — the scenario `-Ds=version|race|merge|modes|seededit` — `A` the arguments, R.193, each printed as `$ V=(…)` / `$ A=(…)`), each
under `perl -e 'alarm 240; exec @ARGV'` (R.247). **The `cp` line** makes anchor B (the entity alone), **the `perl -pi` line** makes C
(the nullable column); the script asserts each copy differs from `after/` by that file / that one line and nothing else. **The run
line** is the README's run line with Hibernate's SQL logger on, for `seven`. The lines read from `after/README.md` (7, each asserted
whole) are its package, test, extract and run lines, its token line, and its JSON POST and list `curl` lines (the port replaced,
`--noproxy '*'` put in: the loopback).

## The repository, and the network

Every Maven run is `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681 files; s4 = s3, the brief). Five Maven runs before the captures —
`before/`, `after/` and C with their tests (each build's summary lines summed and asserted 18 · 0 · 0 · 0), B and A′ with `-DskipTests` —
and one inside a capture, three times: `tests` (`after/`); every one `offline: yes`, 0 `Downloaded from` lines. After the builds the
script asserts `.m2-demo` holds Boot's parent 4.1.2, `hibernate-core-7.4.13.Final.jar`, `spring-data-jpa-4.1.2.jar`,
`spring-tx-7.0.10.jar` and `h2-2.5.250.jar`. **At run time** the harness binds no port; every database is H2 in a JVM's memory
(`jdbc:h2:mem:u27`, xcheck's `x27`, the exercise's `ex`, TiffinBox's own generated name, masked `<uuid>`); TiffinBox listens on
`127.0.0.1` only and is asked by `curl` on the loopback. **No network act**: the section's dated sweep is the brief's
(`_research/spring-boot-metadata-2026-11-10.xml`, `spring-data-bom-metadata-2026-11-10.xml`: the 4.1 line ends 4.1.2, `4.2.0-RC2` not GA
— ⚑6, R.223). Spring Framework's version is printed by every harness JVM from `spring-tx`'s manifest (`7.0.10`), beside Spring Data JPA's
(`4.1.2`), `Version.getVersionString()` and Hibernate's `HHH000001` line (S4.13), before the context starts.

## The locale

The JVM ignores `LC_ALL` on macOS: every JVM this script starts carries `-Duser.language=en -Duser.country=US` on its java line, and the
hygiene check refuses a java line without it (and one without its alarm).

## The folders, the harness and the ports

- `before` → `../c7-unit26/after` (a link; `readlink` asserted); `after/` — this unit's tree, `../c7-tiffinbox` at this commit, Section
  4's frozen anchor. Neither is built in place.
- `xcheck.sql` — Hibernate's script for `after/`'s two entities, filed (md5 `9cf92b8c…`); the `xcheck` capture `cmp`s its own with it.
- `harness/` — `src/probe/t/Main.java` (unit 26's: a Spring Boot context, `WebApplicationType.NONE`, `@EntityScan` and
  `@EnableJpaRepositories` on `com.tiffinbox` — `Found 1 JPA repository interface.`; the three version lines first), `Run.java` (the
  scenarios `version`, `race`, `merge`, `modes`, `seededit`; the shipped seed again before each part; the race's two threads, A and B,
  and its two `CountDownLatch`es), `Edit27.java` (the edits: `edit` — load by id through `CustomerEntityRepository`, print, the latches,
  add, return: the commit follows in the proxy — and `lock`, a load with a lock mode that changes nothing), `H.java` (unit 26's helpers
  plus the version field read by reflection, `vdesc()`, `ver()`, and `row()`: a customer's meals and version by the second connection),
  `Seed.java` (unit 23's); `src/probe/x/XMain.java` (xcheck's context, unit 24's byte for byte); `src/probe/t/ex/ExApp.java` (the
  exercise's, compiled only by the exercise); `logback.xml` (one line per event with its thread, no stack trace; `org.hibernate.SQL`
  DEBUG, `org.hibernate.orm.jdbc.bind` TRACE, `JpaTransactionManager` DEBUG, the version and start lines at INFO, the rest WARN);
  `dur7.py` (the builders', byte for byte, md5 `41667fed…`); `surefire.py` (the testing lesson's, `../c6-unit28/harness/surefire.py`,
  byte for byte). English names only (R.215): Ravi, Meera, Sunil, Priya, Kavya.
- `exercise/` — `README.md`, `SOLUTION.md`.
- `.harness/` (git-ignored, rebuilt by every run): `before`, `after`, `anb` (B), `ana2` (A′), `anc` (C), `tests` (each a copy, built or
  tested there, each with its `secrets/`), `hc`, `hce`, `run`, `sqlb.py` (a statement and its binds, read off a capture), `order.py`
  (the race's order and binds per round), `ddl-before.sql`, `ddl-after.sql`, `ex`, the logs. `.r-NAME.1-3` while a capture runs;
  `.r-NAME.out` its result (git-ignored).
- **Ports (§P, 20060-20069):** 20060 anchor B (never bound: its start fails) · 20061 anchor A (and its POSTs — the brief's 20063 stays
  unused) · 20062 A′ · 20063 unused · 20064 `seven` before/ · 20065 `seven` after/ · 20066 unused (the brief's `xcheck` port:
  `probe.x.XMain` binds none) · 20067 anchor C · 20068 unused · 20069 never bound. All ten, 18425 (TiffinBox's default), 8080 and 35729
  are checked free at the start and the end; each start checks its own port free first.

## Masks, filters and hygiene — every one, declared

Masks (awk `gsub` only, each with a planted self-test line before any capture): the generated token → `[masked: the token]`; this folder
→ `…`, the folder above → `…/..`, home → `~`, the user name → `<user>`; ` using Java <version>`; an identity hash → `@…`; an
EntityManager's identity → `SessionImpl(<n><open>)`; a lambda class's address → `$$Lambda/<n>`; Spring Data's scan figure → `<n>`;
TiffinBox's generated database name → `jdbc:h2:mem:<uuid>`; an application context's `started on <date>`; H2's constraint names →
`CONSTRAINT_<n>` / `CONSTRAINT_INDEX_<n>`; a 500 body's `"timestamp"` → `<time>`. Filters: a harness JVM's log is printed whole
(trailing spaces dropped); TiffinBox's log per request (`req`): the transaction manager's create / commit / rollback lines, Hibernate's
refusal, WARN and ERROR; a failed start (`startfail`): its WARN and ERROR lines, the exception's own line and every `Caused by:` line, the
stack frames dropped; a JSON answer without its two number fields; the seven by the comparison set's lines; the scripts' foreign-key
names → `FK<name>` on screen (the md5s are the files'). Hygiene, over every capture: raw token copies 0 (each raw run counted before the
mask, and every capture, log and file after); no absolute path, unit number (the anchor capture's quoted diff lines aside), log time,
timestamp, numbered thread, a context's start date, JDK or OS token, figure of elapsed time, stack frame, unmasked identity, lambda
address or generated name, URL but TiffinBox's own loopback ports (`127.0.0.1:20060`-`20067`); every JVM pinned and under its alarm; no
kill by name, no bare `wait`; no `Thread.sleep` in the harness (S4.18); no H2 database file outside `.harness` (R.195); no dish name
(R.215). The prose gates, before any build: no duration word (dur7, R.172) **and no duration meaning** (S4.7's family, R.264;
`_builders/dur7.py` is not edited — two pinned sentences exempt, whole: For RED); no dish name; no placeholder line and no empty "What it
prints" block; **S4.8's refused name** (the old message's clause, by a case-blind grep) over this README, `exercise/`, `after/README.md`'s
unit 27 section and the two changed sources; no SQL string in this README outside its values block (R.225); **R.250's sentence set**
(above).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid` — a harness JVM or
TiffinBox), the Maven or the `javac` it waits for (`$mpid`, with every process under it), the exercise's shell (`$xpid`), sweeps its own
process group for any harness, exercise or TiffinBox JVM, Surefire fork, `javac` or Maven left, deletes the capture runs it had not
finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched.

**Measured (2026-11-12, on scratch mirrors of this folder — its files and `.m2-demo` cloned, `c7-unit26`, `c7-unit09`, `c7-tiffinbox`,
`c5-unit11` and `c6-unit28` linked; the script as committed, the published captures copied in):** `receipts.sh` (/bin/bash 3.2) started
`env -i` in a session of its own **with SIGINT at its default** (`perl -MPOSIX -e '$SIG{INT}="DEFAULT"; setsid; exec …'`), `kill -INT` to
its group once the named process was in it, the state read 5 s after its exit — three trials:

```
build (surefirebooter seen: 2): processes in the group at SIGINT 5 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
harness (probe.t.Main seen: 1): processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
tiffinbox (tiffinbox.port=2006 seen: 1): processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
```

`build` — `before/`'s Maven build, its Surefire fork running; `harness` — the first harness JVM (`version`, `probe.t.Main`); `tiffinbox`
— TiffinBox's first start in `anchor` (B, port 20060, before its start failed). `pgrep -x java` afterwards: none.

## 1 · version — the column

One harness JVM over `after/`'s libraries: the INSERT of a new customer with its binds, an edit's UPDATE at the commit with its binds,
the second connection's reads, and `findById`'s read back. `sqlb.py` names each bound value by the statement's own placeholders.

## 2 · race — two edits of Ravi, B / A / A′ (S4.6, S4.18, the failure receipt)

Three harness JVMs — `before/`'s libraries (B), `after/`'s (A), `.harness/ana2`'s (A′) — three rounds each, the seed again before each
round; every round asserted (who loaded, who committed, who threw, the row after, the order and both UPDATEs' binds), and A′'s
print equal to A's but its classpath.

## 3 · merge — a stale copy (the second message)

One harness JVM over `after/`'s libraries: the copy, the other edit, `save(stale)` between markers — its SQL lines (one SELECT, no
UPDATE), its chain, the row after.

## 4 · modes — OPTIMISTIC and OPTIMISTIC_FORCE_INCREMENT

One harness JVM over `after/`'s libraries; for each mode the seed again, a load with the mode that changes nothing, the statements at
the commit, the row after.

## 5 · anchor — the change, and TiffinBox B/A/A′/C (S4.9)

The change (`diff -rq` and each source's diff, whole); B's failing start on 20060; A on 20061 (POST Kavya twice, `GET /customers`,
stopped by its pid — SIGTERM, exit 143) and the harness's first edit of a seeded customer over `after/`'s libraries; A′ on 20062; C on
20067 and the same edit over C's libraries.

## 6 · seven — before/ and after/, a guard (R.190)

Each tree's jar with Hibernate's SQL logger on, a fresh JVM, the comparison set (`../c5-unit11/curlset.sh`, POST /shutdown last). The
seven `466c20ed7e0d5439cb052f32ce09de1b` on both, 0 lines differ, Hibernate's SQL lines — in the log and during the seven — the same
count on both trees; the statements during the seven the same but one: `after/`'s customers' select reads the version column too
(the diff is printed; the check takes that column out of `after/`'s lines and finds `before/`'s).

## 7 · tests — TiffinBox's eighteen, on after/ (C7-4)

`after/` copied to `.harness/tests`, `mvn -B clean test` offline: `TiffinBoxWebTest` 14, `FullStackTest` 3, `FeedTest` 1 — 18, 0
failures, 0 errors, from Surefire's reports, the console's summary the same.

## 8 · xcheck — the DDL over before/ and after/ (R.212, R.252)

Above: `f595637014…` on `before/` (unit 09's), `9cf92b8c…` on `after/` (= `xcheck.sql`), one line apart.

## 9 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196, S4.16)

The README's lines, then the solution's, in one `env -i` shell, `/bin/bash --noprofile --norc`, then `/bin/zsh -f`; each file's "What it
prints" block compared with the run line for line, bash and zsh asserted equal; the end states checked first. **Broken** (as shipped):
`Diner` has a field called `version` but no `@Version` — B commits 7, A commits 3, Ravi 3, nothing rolled back. **Solved** (one line:
`@Version` on the field): B commits 7, A's commit throws `ObjectOptimisticLockingFailureException` (its UPDATE `where id=? and
version=?` on the exercise's own table) and rolls back after the commit exception, Ravi 7. The same two threads, latches and call path
in both (S4.16). H2 only (the probe measured both databases; 27 ships H2).

## Exercise

`exercise/README.md`, the spoken line (22 words by `wc -w`, R.203 ≤ 25):

Your turn: the README edits Ravi twice at once, and one edit disappears without an error. Make the losing edit fail loudly.
 `exercise/SOLUTION.md` — the one changed line and what it prints.

## The ledger rows and hand-offs this unit pays

- **C7-4** ("TiffinBox has tests now", 18) — **re-run**: 18 after the change (`tests`, and inside `after/`'s build), and 18 on C (the
  nullable column: the tests did not notice) — carried to U39.
- **Course 9's ETags — pinned**, the names as measured on Hibernate 7.4.13.Final / Spring Framework 7.0.10: `@Version private Long
  version`, `getVersion()`, the column `version BIGINT NOT NULL DEFAULT 0`, the UPDATE's `where id=? and version=?`,
  `org.springframework.orm.ObjectOptimisticLockingFailureException`. The version is not in the record or the JSON here (CARRIED: a
  version in the JSON or an ETag header is Course 9's).
- **Section 4's anchor is frozen here**: `c7-unit27/after` = `c7-tiffinbox`; unit 28 builds over it through its link
  (`28/anchor → ../c7-unit27/after`) and moves nothing.
- **U36's migration must carry this column** (`NOT NULL DEFAULT 0` — CARRIED, the brief's).
- Called back by title, no new gloss (R.204, R.224): the lesson called *Rollback Rules* (unit 26 — the anchor's first `@Transactional`,
  the tree this one changes), the lesson called *One To Many, Many To One and the Owning Side* (unit 09 — the DDL hash this unit moves).

## RE-MEASURE — the brief's items this unit settles

- **#1** (the exercise as README + SOLUTION files, bash + zsh, `env -i`) — settled for 27: `exercise` (the probe's `lost`/`u27` end states
  — Ravi 3, then 7 — on an entity of the exercise's own; H2 only).
- **#6** (27's race and `merge` on `CustomerEntity` itself — the messages name it) — settled: `race` and `merge` run on the anchor's own
  entity and repository; both messages say `com.tiffinbox.CustomerEntity with id '1'`.

## What differed from the brief

- **B of `anchor` is `after/` with `before/`'s `Database.java`** (one file, asserted the only difference) — the probe's sV0 shape on
  this tree: the entity carries `@Version`, the table has no column. B is built `-DskipTests` (its `FullStackTest` would start the same
  failing context); its start is the receipt.
- **C is `after/` with the column's `NOT NULL DEFAULT 0` taken off** (sV2's shape), built with its tests (18 passed, said) — and its
  first edit of a seeded customer is a **harness** run over C's libraries (`-Ds=seededit`), not a route: TiffinBox has no route that
  edits a customer. A's seeded edit is the same harness run over `after/`'s libraries. C's TiffinBox is started too (on 20067: 201,
  409, the same names), to show the start does not tell.
- **A′ is in both `race` and `anchor`**: `after/` copied again and built again (`.harness/ana2`), the harness over its libraries and
  TiffinBox on 20062. **Port 20063 is unused**: A's POSTs run inside A's start on 20061 (the brief listed 20063 "POSTs").
- **The race's threads are named A and B, and the logback pattern prints the thread** (`%-5level [%thread] %logger : %msg`, unit 26's
  plus `[%thread]`): S4.18's "the order read off the capture" is read from the thread on each manager, SQL and bind line. Each round's
  order and both UPDATEs' binds are checked by `order.py`; the latches are `CountDownLatch`es with a bound on each wait (60, a guard
  that throws, never an order).
- **The edits are a harness bean's `@Transactional` method** (`Edit27.edit`, through its proxy), not a `TransactionTemplate` (the
  probe's): the brief's ⚑3 loser. Its manager line names `probe.t.Edit27.edit`.
- **`modes` uses `EntityManager.find` with the lock mode** inside `Edit27.lock`, not a repository method with `@Lock` (the probe's
  `VCustomers`): no second repository, so `Found 1 JPA repository interface.` stays every harness JVM's line. The statements are the
  brief's.
- **The exercise's entity is its own, `Diner`** (table `diner`, created by Hibernate, `ddl-auto=create`, in the exercise's own H2), with a
  plain `Long version` field: the solution's one line is `@Version` on it. TiffinBox's `CustomerEntity` carries `@Version` from this unit
  on, so the exercise could not edit it into the broken state with one line. Its messages name `probe.t.ex.Diner`.
- **The INSERT's statement** is read off the capture: `…,version,id) values (?,?,?,?,?,default)` — the brief's, with the bind 0 named by
  the column list (`sqlb.py`).
- **The seven's statements differ by the version column** in one select (the brief: "show the one differing SELECT line"); the check is
  that taking the version column's alias out of `after/`'s lines gives `before/`'s, and that the count of SQL lines is the same.
- **`xcheck` runs `XMain` twice** (over `before/`'s and `after/`'s libraries) so the `diff` is between two scripts of the same receipt
  run; `before/`'s is asserted equal to unit 09's published md5, `after/`'s byte-equal to `xcheck.sql`, filed here (RED #1209/#1214: 26
  filed its script in its capture only; 28's `xcheck` compares with this file).
- **The duration family vs the brief's own exercise line:** the pinned 22-word line holds two words S4.7's family refuses side by
  side ("at", then "once"). The duration gate takes that one sentence, whole and byte for byte, out of a line before the family reads it (an assertion in
  the gate proves the family would refuse it otherwise), beside 26's Course 13 sentence; nothing else is exempt. Everywhere else this
  unit says "at the same time". For RED.
- **The four DDL sentences in `after/README.md` are rewritten in place** ("was still unit 09's" + the unit 27 note), not deleted: they
  are the history of units 15, 16, 17 and 26, true when written, as the anchor README's own rule asks.
- **The anchor was moved before the runs of record** (`rsync -a --delete` of `after/` into `../c7-tiffinbox`, `.m2-demo`/`target`/
  `secrets`/`.harness` excluded): the anchor note is empty at the start and the end of every run of record.
- **No network act**; the push at the end is the only one. The start's `main...origin/main` = `0 0` was read from the local refs.

## Planted faults — each caught (R.65, R.226)

Each on a scratch mirror of this folder (its files and `.m2-demo` cloned; `c7-unit26`, `c7-unit09`, `c7-tiffinbox`, `c5-unit11`,
`c6-unit28` linked), `env -i`, a session of its own, `/bin/bash` 3.2; each **exit 1**, `receipts.md5` and `README.md` unchanged (nothing
written). A plant marked † also takes, in its mirror only, the captures before the one it targets out of the script, so the targeted
check is the one that fires. Five of them (the sleep, B fed to A, the wrong hash, no Framework line, the What-it-prints line) ran side by
side beside run of record 2; none binds a port.

| plant | caught by |
|---|---|
| **a nullable column in A** (`.harness/after` and `.harness/ana2` given `version BIGINT` after the derivations; † `version`…`modes` out) | `anchor A: the seeded row's version 0 (the column's default): expected the line: … Ravi · meals_per_day 2 · version 0` — while `after/`'s build printed its 18 tests, 0 failures (the tests did not notice) |
| **the old md5 kept in `after/README.md`** (a line in its unit 27 section naming the old md5, unit 09's) | R.250: `the old DDL md5 is still in after/: after/README.md`, before any build |
| **the refused message in this README** (Hibernate's older one, with its clause about a wrong unsaved value, quoted whole) | S4.8's refused-name gate, the line quoted, before any build |
| **the race without latches** (`Thread.sleep(1)` in place of both waits; † `version` out) | `race drifts across three runs` — **not 3/3, shown once:** run 1 B: 1 B committed, mealsPerDay 7 · A committed, mealsPerDay 3 · Ravi · meals_per_day 3 / 2 B committed, mealsPerDay 7 · A committed, mealsPerDay 3 · Ravi · meals_per_day 3 / 3 B committed, mealsPerDay 7 · A committed, mealsPerDay 3 · Ravi · meals_per_day 3; run 2 B: 1 B committed, mealsPerDay 7 · A committed, mealsPerDay 3 · Ravi · meals_per_day 7 / 2 B committed, mealsPerDay 8 · A committed, mealsPerDay 3 · Ravi · meals_per_day 8 / 3 B committed, mealsPerDay 8 · A committed, mealsPerDay 3 · Ravi · meals_per_day 8; run 3 B: 1 B committed, mealsPerDay 7 · A committed, mealsPerDay 3 · Ravi · meals_per_day 7 / 2 B committed, mealsPerDay 7 · A committed, mealsPerDay 3 · Ravi · meals_per_day 3 / 3 B committed, mealsPerDay 7 · A committed, mealsPerDay 3 · Ravi · meals_per_day 3 — and in A's JVM some rounds have B throw and A commit 3. With the drift check passed, `order.py`, then the hygiene grep `a harness sleeps (S4.18)` stand behind it |
| **B fed to the A check** (race A run over `before/`'s libraries; † `version` out) | `race A: after/'s CustomerEntity has @Version: expected the line: …` (the first of A's checks; the exception and Ravi 7 checks follow it) |
| **`xcheck.sql` not filed** (removed) | `xcheck.sql is missing`, at the start |
| **a typed `9cf92b8c…` beside the wrong `.sql`** (`xcheck.sql` replaced by `before/`'s script) | `xcheck.sql is not the filed script (md5 9cf92b8c…)`, at the start |
| a wrong published hash (`version`) | `version is not the published capture` |
| no Spring Framework version line (S4.13; `Main.java`'s print removed) | `version: the version lines … (S4.13)` |
| an Indian dish name · a to-do marker line · a typed UPDATE · a duration word and meaning | the dish, placeholder, typed-SQL and duration gates, before any build |
| a changed "What it prints" line (exercise/README.md, the last line; † every capture but `exercise` out) | the exercise's line-for-line comparison: `… Ravi mealsPerDay 4` against the run's 3 |

Not run: a plant on `TiffinBoxWebTest`/`FullStackTest`/`FeedTest` (untouched); the sleep plant with the drift and order checks taken out
(the hygiene grep for `Thread.sleep` in `harness/src` would then fire at the end — not measured as the catching check).

## The anchor moved on — the re-run of 26 (R.211, RED #1200)

`grep -n c7-tiffinbox` before the commit (R.211, the brief's EVIDENCE BATCHES), over `_builders/*.py`,
`~/Desktop/PromptVidya-Automation/check_unit7.py` and `qa_java7.py`: `s701.py`, `s702.py`, `s704.py`, `s705.py` (prose only); `s703.py`,
`s706.py`, `s707.py`, `s709.py`, `s715.py`, `s716.py`, `s717.py` (each asserts `after/` against `git show <sha>:c7-tiffinbox/<p>` and prints
`note:` on a live diff); `s718.py`-`s722.py` (`LIVE` lines); `check_unit7.py` and `qa_java7.py` — no line; no `s723`-`s728` builder exists
yet. **`s717.py` run once after the move** (a scratch copy of it with `_builders/dur7.py` beside it, so its `OUT` is the copy's folder and
nothing is written into the course): exit 0, nine `note: c7-tiffinbox has moved on since f620c1a (a later change to the anchor); after/ is
checked against f620c1a: …` lines (README.md, CustomerAdded.java, CustomerEntity.java, CustomerRepository.java, Database.java,
CustomerFeed.java, CustomerImport.java, DashboardPage.java, TiffinBoxServer.java), then `anchor: after/ = f620c1a:c7-tiffinbox in its 4
changed files; diff -rq against the live c7-tiffinbox: 9 lines` — the expected sign.

**`../c7-unit26/receipts.sh`** (unchanged, md5 `10211df9e2ecbb42bb78ea81d169f7a0`) — the previous anchor-change unit — run once on the moved anchor,
`./receipts.sh` (/bin/bash 3.2.57), `env -i`, a session of its own, from 06:56:21 CET: **exit 0 in 380 s**; it printed its note at its
start and its end (`(after/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit froze: Files after/README.md and
../c7-tiffinbox/README.md differ;Files after/…/CustomerEntity.java and ../c7-tiffinbox/…/CustomerEntity.java differ;…)`), all 10 captures
3/3 = published, `receipts.md5` unchanged, its log through `check_unit7.py 26 --runlog` PASS. 17's and 22's receipts (and RED #1200's
others, 15, 16, 18-21, 23-25) print their notes the same way and were not re-run (26 re-ran 17 and 22 once on its own move). The dated
"Re-run after unit 27 moved the anchor" paragraph is in `../c7-unit26/README.md`.

## CARRIED

- **`_builders/dur7.py` and S4.7's duration-meaning family** — still the tooling's (the brief's CARRIED); this unit's gate carries it,
  with the two pinned sentences exempt (For RED).
- **A version in the JSON / an ETag header** → Course 9 (pinned above).
- **U36's migration** must carry the `version` column, `NOT NULL DEFAULT 0` (the brief's CARRIED).
- **Section 4's anchor is frozen** — 28 builds over `../c7-unit27/after`; a later course that moves `c7-tiffinbox` makes this unit's
  `anchornote` print its note.

## For RED

- **The duration regex (26's finding, FACTORY-NEXT 2026-11-11 "⚠ FOR RED"):** 26's gate is **carried as is** (its Course 13 exemption
  is harmless here — 27 does not say that sentence), and one exemption is added: the brief's pinned exercise line ("…twice at" + "once…") —
  that pair is in S4.7's family, so without it the unit's own pinned line fails its gate. Not tightened to a numeral before "second(s)":
  that pair is not a number-and-unit case, and a tightened family would still refuse it. **The 27 builder needs the same exemption, or
  the brief's exercise line changes** ("twice at the same time" passes; 22 words still) — Vivek's / RED's call; the Course 13 sentence is
  not edited anywhere (R.252).
- **S4.9:** the witnesses differ between B, A and C (B's start, A's and C's seeded edit); the guards (the seven, its SQL line count, the
  18 tests — 18 on C too) are equal — the plant "a nullable column in A" fails the seeded-edit check while the tests pass.
- **S4.8:** the optimistic-lock failures are Hibernate's checks, not database refusals: no SQLState is claimed for them; B's start is a
  database refusal and carries 42S22 as Hibernate's HHH000247 line logged it.
- **The seeded edit is the harness's**, over C's and A's libraries: no TiffinBox route edits a customer. A slide that says "TiffinBox's
  edit failed" is wrong — the seeded row's first edit through the anchor's own repository failed.
- **The race's A′ and A** read the same core jar byte for byte (terminal note) — a fresh build of the same sources; R.1 is met by the
  rebuild, not by different bytes.
- **The exercise's entity is `Diner`, not `CustomerEntity`**: the video must not say the exercise edits TiffinBox's customer.
- **Not measured here:** PostgreSQL (⚑2: H2 only for 27); `PESSIMISTIC_FORCE_INCREMENT` (28's, RE-MEASURE 5); a version in the JSON
  (Course 9).
