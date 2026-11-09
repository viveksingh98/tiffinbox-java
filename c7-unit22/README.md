# c7-unit22 — Bulk Updates and the Stale Context

Course 7 · Data with JPA & Hibernate · Section 3 (Querying), its eighth and last unit, and **the fifth on Section 3's frozen anchor —
no change to the anchor** (brief ⚑11): `anchor` is the link to `../c7-unit17/after`. Verified on **JDK 25.0.4.1, Apache Maven 3.9.16,
Spring Boot 4.1.2** (Spring Data JPA 4.1.2, Hibernate ORM 7.4.13.Final, Jakarta Persistence 3.2.0, H2 2.5.250 — the anchor's pin),
2026-11-09, **on H2 only** (brief ⚑2: every capture says so in its own lines). A **bulk update** — a JPQL `update` run by a repository
method marked `@Modifying` — goes straight to the database: Hibernate turns it into one SQL statement and never looks at the entities
it already holds. The persistence context (*The Persistence Context*) is not told: a customer it loaded before keeps the old value, and
the next `findById` hands that same stale object back without asking the database. Measured: the failure with no transaction of the
caller's (and with one, and without `@Modifying`); the stale context seen three ways; `clearAutomatically`; a pending change before the
bulk statement under `bump`, `bumpClear` and `bumpFlush`; and what bulk deletes skip — the cascade.

**No anchor change (brief ⚑11).** `anchor` → `../c7-unit17/after` (`readlink` asserted), Section 3's frozen anchor. `receipts.sh` prints
`diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox` at its start and end — empty in every run of record —
and, from any later anchor change on, prints a note instead (R.211). The anchor is copied under `.harness/anchor` and built there with
its README's package line (offline; its 18 tests run inside that build), its jar extracted with the anchor's own line; the harness runs
over those 91 libraries. TiffinBox's build gains nothing; TiffinBox itself is not started by this unit.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 7 captures, 3 runs each; every spoken number checked after its capture; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version` and `javac -version` say 25.) It **dies** when a
check after a capture fails, and when a capture's md5 differs from `receipts.md5` (the capture's checks run first, then the `DIFFERS`
line). **Start it in a process group of its own** (a terminal's foreground job is one): `sweep()` stops only processes of its own group.
`.m2-demo` must be seeded first (below). No Docker, no container, no password, no token: every database is H2 in a JVM's memory, and no
JVM here binds a port.

**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`), a session of its own
(`perl -MPOSIX -e 'setsid; exec @ARGV'`), `.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681
files, an APFS clone of the folder). Development runs (a scratch copy of this script, `.r-dev.sh`, git-ignored, whose values-line and
published-hash stops print instead of stopping) fixed the captures and the checks; the first full run wrote every capture 3/3, and those
md5s are `receipts.md5`. **The runs of record, on the script as committed (`receipts.sh` md5 `0a02855994dd3c22790faa3bcfe6b58b`): 456 s
under `./receipts.sh`** (/bin/bash 3.2.57, 2026-11-09 from 07:40 CET, beside three plant mirrors), **187 s under `bash receipts.sh`**
(Homebrew bash 5.3.9, from 07:52 CET) **and 184 s from a sealed fresh clone** (below, from 07:55 CET): each exit 0, all 7 captures 3/3 =
published, every check passed, the anchor's build `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`, the anchor note empty
at the start and the end, nothing listening on 18425, 8080, 35729 or 20010-20019 at the end; each terminal log through
`check_unit7.py 22 --runlog` — `0 grep error line(s)`, `RESULT (run logs): PASS`. The builders' `_builders/dur7.py` over this README and
the exercise's two files: 0 duration words. **Nothing was downloaded**, and this unit made no network act. **On the tree as committed** —
this README final — one more `./receipts.sh` (`env -i`, a session of its own): see the commit message.

Published hashes: notx `7d4a916f6f1b0fb2460e5caa1bd0a24c` · stale `4a3d993f7b6fcf989455fcd870dcd36d` · clear `93050004a39c5f419270c768fe95b0af` · flush `f90815978f7e8475277d6fa91331e485` · cascade `be2cd4db195def189ffb51a443969580` · xcheck `7f83aec27d6d9f2791b7bd5fde7712f4` · exercise `faa46ff32d9fde8a6214d1ce9debb380`.

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line, R.225 — a SQL string or
a statement count typed anywhere else in this README is refused):

the values the video may say: notx, on Spring Data JPA 4.1.2 - B bump(VEG) with no transaction of the caller's: org.springframework.dao.InvalidDataAccessApiUsageException: No active transaction for update or delete query <- first cause jakarta.persistence.TransactionRequiredException: No active transaction for update or delete query; 0 statements; JpaTransactionManager: no line · A bumpTx(VEG): Creating new transaction with name [org.springframework.data.jpa.repository.support.SimpleJpaRepository.bumpTx]; update customer ce1_0 set meals_per_day=(ce1_0.meals_per_day+1) where ce1_0.meal_type=?; 1 statement; 2 rows updated · C bumpNoModifying(VEG): org.springframework.dao.InvalidDataAccessApiUsageException: Query executed via 'getResultList()' or 'getSingleResult()' must be a 'select' query [update CustomerEntity c set c.mealsPerDay = c.mealsPerDay + 1 where c.mealType = :type] <- first cause java.lang.IllegalStateException; 0 statements; rolled back · stale (one transaction): findById(1) -> id 1 · Ravi · mealsPerDay 2 · bump(VEG) -> update customer ce1_0 set meals_per_day=(ce1_0.meals_per_day+1) where ce1_0.meal_type=? -> 2 rows updated (1 statement) · the Ravi object -> mealsPerDay 2 · em.contains(ravi) true · findById(1) again -> mealsPerDay 2 · same instance true (0 statements) · before the commit, the second connection reads 1 | Ravi | VEG | 2 | 120 · the native read in the same transaction (select meals_per_day from customer where id = ?) -> meals_per_day 3 · em.refresh -> mealsPerDay 3 · after the commit, the second connection reads 1 | Ravi | VEG | 3 | 120 · clear: B bump -> mealsPerDay 2 · em.contains(ravi) true; findById again mealsPerDay 2 · same instance true · A bumpClear -> mealsPerDay 2 · em.contains(ravi) false; findById again (1 statement: select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where ce1_0.id=?) -> mealsPerDay 3 · same instance false · flush, Hibernate 7.4.13.Final, flush mode AUTO: Meera changed in the object, then bump, bumpClear and bumpFlush alike ran update customer set meal_type=?,meals_per_day=?,name=?,price_per_meal=? where id=?, then update customer ce1_0 set meals_per_day=(ce1_0.meals_per_day+1) where ce1_0.meal_type=?; after the commit, the second connection reads 2 | Meera | NON_VEG | 3 | 150 · cascade: deleteById(3) (Sunil, no cascade) -> 2 statements, org.springframework.dao.DataIntegrityViolationException <- org.hibernate.exception.ConstraintViolationException <- org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException, Referential integrity constraint violation: "CONSTRAINT_<n>: PUBLIC.PAUSE FOREIGN KEY(CUSTOMER_ID) REFERENCES PUBLIC.CUSTOMER(ID) (CAST(3 AS BIGINT))", rolled back, Sunil kept · the pair: deleteById -> 5 statements, c_customer 1 · c_pause 2 -> c_customer 0 · c_pause 0 · the JPQL bulk delete -> delete from c_customer c1_0 where c1_0.name=? -> org.springframework.dao.DataIntegrityViolationException, rolled back, c_customer 1 · c_pause 2 kept · deleteAll() on c_customer 3 · c_pause 3 -> 4 SELECTs then 6 DELETEs (3 c_pause, 3 c_customer) = 10 statements · deleteAllInBatch() on c_customer 3 · c_pause 3 -> delete from c_customer c1_0 -> org.springframework.dao.DataIntegrityViolationException, c_customer 3 · c_pause 3 kept · xcheck: f595637014e786fa38606859951e4f97 · exercise: @Modifying -> mealsPerDay 2 (0 statements); @Modifying(clearAutomatically = true) -> mealsPerDay 3 (1 statement) (24 words)

### The stale context, three witnesses (S3.13)

`stale` shows one bulk update inside one transaction (a `TransactionTemplate`) from three sides, each its own call between markers:
**the loaded object's field** (Ravi, loaded before the update: still the old value, `em.contains` true; `findById` again returns the
same instance with no statement between its markers), **a native read in the same transaction** (`em.createNativeQuery` of the
`customer` table's `meals_per_day` for id 1 — it sees the new value: the database, asked inside the same transaction, disagrees with
the object), and **a second connection after the commit** (plain JDBC — `DriverManager` on the same `jdbc:h2:mem:u22` URL, a connection
of its own outside Hibernate and outside Spring's transaction — the new value). The same second connection read **before** the commit
returns the old value: the update is not committed yet, so it cannot be the witness inside the transaction (the plant "a second
connection instead of the native read" reads the old value and S3.13's check stops the run). `em.refresh` reads the row again, one
SELECT, the new value. "The database disagrees" is said only beside the native read (S3.13).

### The flush beat's scope (READ FIRST 9, S3.15)

`flush` is one claim, scoped: **on Hibernate 7.4.13.Final, flush mode AUTO** (both read in the capture — the version lines, and
`EntityManager.getFlushMode()` printed inside the transaction), a change made to a loaded entity and not flushed is written by its own
UPDATE **before** the bulk statement, under `bump`, `bumpClear` and `bumpFlush` alike — the order read off the log, line by line —
and the second connection reads the change after the commit. So this unit never says "clearAutomatically loses your change" nor
"flushAutomatically is useless": the first is false here, the second is one capture under one flush mode (`flushAutomatically` under
another flush mode is CARRIED). The script refuses such a line in this unit's prose, by the flush capture's check.

### The constraint-name mask (the brief's hazard)

H2 names a foreign key it was given without a name itself — `CONSTRAINT_` and a number in hex — and the refusal's message quotes it.
Every capture prints it as `CONSTRAINT_<n>` (awk `gsub`, self-tested before any capture, declared below); `cascade`'s checks assert the
masked message, and the hygiene check refuses any `CONSTRAINT_` followed by a hex digit in a capture. The mask removed: Planted faults.

### A sealed fresh clone — the recipe (R.129)

**Paste it into bash.** Unit 21's recipe, with this unit's folder:

```bash
S=/tmp/sealed22; W="/tmp/sealed 22"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
mkdir -p "$S/home/.m2" "$W" && git clone -q "file://$T" "$W/tiffinbox-java"
rsync -a --exclude _remote.repositories --exclude '*.lastUpdated' --exclude resolver-status.properties "$T/../../data-jpa-hibernate/_research/m2-seed-c7-s3/" "$S/central/"
printf 'MAVEN_OPTS="-Duser.home=%s $MAVEN_OPTS"\n' "$S/home" > "$S/home/.mavenrc"
cat > "$S/home/.m2/settings.xml" <<XML
<settings>
  <mirrors><mirror><id>sealed</id><mirrorOf>*</mirrorOf><url>file://$S/central</url></mirror></mirrors>
  <proxies>
    <proxy><id>dead-http</id><active>true</active><protocol>http</protocol><host>127.0.0.1</host><port>9</port></proxy>
    <proxy><id>dead-https</id><active>true</active><protocol>https</protocol><host>127.0.0.1</host><port>9</port></proxy>
  </proxies>
</settings>
XML
X=http://127.0.0.1:9; E="env -i HOME=$S/home PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin http_proxy=$X https_proxy=$X HTTP_PROXY=$X HTTPS_PROXY=$X"
$E JAVA_HOME=/opt/homebrew/opt/openjdk@25 mvn -B -Dmaven.repo.local="$S/preflight-m2" org.apache.maven.plugins:maven-dependency-plugin:3.8.1:get -Dartifact=org.example.sealed:absent:1 > "$S/preflight.log" 2>&1
[ $? != 0 ] && grep -q 'Downloading from sealed: file://' "$S/preflight.log" && ! grep -qE 'Downloading from [^ ]+: https?://' "$S/preflight.log" && echo "sealed: file:// only" || echo "NOT SEALED - do not run receipts.sh"
cd "$W/tiffinbox-java/c7-unit22" && readlink anchor && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E ./receipts.sh            # a process group of its own
```

**Run (2026-11-09, from 07:55 CET):** a `git clone` of tiffinbox-java at `680daba` into a path **with a space** (`…/sealed 22/tiffinbox-java`,
in the session's scratch folder), this unit's files put in as git takes them (the one untracked path, `c7-unit22/`, its files `cmp`-equal
to the working tree, `anchor` → `../c7-unit17/after` by `readlink`); a `file://` copy of the s3 seed (5,023 files once
`_remote.repositories`, `*.lastUpdated` and `resolver-status.properties` are left out); pre-flight: exit 1, 221 `Downloading from sealed:
file://`, 0 from http(s); the clone's `.m2-demo` seeded from that copy; `/bin/bash` 3.2, `env -i` with the dead proxies, a session of its
own: **exit 0 in 184 s, all 7 = published, every check passed**; the build `offline: yes · exit 0 · 'Downloaded from' lines in its log:
0`; after the run `.m2-demo` held 5,023 files, 0 `_remote.repositories`. Its terminal log through `--runlog`: PASS. (The clone's README
was this file before its last prose was filled in; this README passes the same gates in the run on the tree as committed.)

## The commands this unit adds

```
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/src/probe/q/Main.java harness/src/probe/q/Run.java harness/src/probe/q/Seed.java harness/src/probe/q/casc/CCustomer.java harness/src/probe/q/casc/CPause.java harness/src/probe/q/casc/Tables.java harness/src/probe/q/repo/CCustomers.java harness/src/probe/q/repo/Customers.java harness/src/probe/x/XMain.java
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.q.Main "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.x.XMain "${A[@]}"
```

**The harness line** compiles the harness against the anchor's extracted libraries with `-parameters` (as Boot's parent compiles
TiffinBox). **The two java lines** run the harness and xcheck's context from `.harness/run` (`V` the JVM flags — the scenario
`-Ds=notx|stale|clear|flush|cascade` and the variant `-Dv=A|B` for `clear`, `-Dv=bump|bumpClear|bumpFlush` for `flush` — and `A` the
arguments, R.193, each printed as `$ V=(…)` / `$ A=(…)`, `A` with `printf %q`). Every java line runs under `perl -e 'alarm 240; exec
@ARGV'` (R.247: macOS has no `timeout`; an alarm that fires ends the JVM with exit 142, which the runner refuses); the exercise's JVM
under its own alarm. The lines read from `anchor/README.md` (2, each asserted whole) are its package line, `mvn -B package`, and its
extract line.

## The repository, and the network

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681 files). One build: the anchor's `package` (its 18 tests run),
`offline: yes` with 0 `Downloaded from` lines in every run of record (the label is derived from the build log, never typed). After it
the script asserts `.m2-demo` holds `spring-boot-starter-parent-4.1.2.pom`, `hibernate-core-7.4.13.Final.jar`, `spring-data-jpa-4.1.2.jar`
and `h2-2.5.250.jar`. **At run time** no JVM binds a port; every database is H2 in a JVM's memory (the harness's `jdbc:h2:mem:u22`,
xcheck's `jdbc:h2:mem:x22`, the exercise's `jdbc:h2:mem:ex`). **No network act**: the section's dated sweep is the brief's
(`../../../data-jpa-hibernate/_research/spring-boot-metadata-2026-11-07.xml`: the 4.1 line ends 4.1.2, `4.2.0-RC2` not GA — ⚑6, R.223).
Spring Data JPA's version is printed by every harness JVM from its jar's manifest (`JpaRepository.class.getPackage()
.getImplementationVersion()` → `4.1.2`), beside Hibernate's `HHH000001` line and `Version.getVersionString()` (S3.15, R.246) — before
the context starts. No processor, no Querydsl, no Docker in this unit.

## The locale

The JVM ignores `LC_ALL` on macOS: every JVM this script starts carries `-Duser.language=en -Duser.country=US` on its java line, and the
hygiene check refuses a java line without it (and one without its alarm).

## The folders, the harness and the ports

- `anchor` → `../c7-unit17/after` (a link; `readlink` asserted) — Section 3's frozen anchor, never built in place.
- `harness/` — `src/probe/q/Main.java` (a Spring Boot context, `WebApplicationType.NONE`: it binds no port; `@EntityScan({"com.tiffinbox",
  "probe.q.casc"})` — the anchor's entities and the harness's cascade pair — and `@EnableJpaRepositories("probe.q.repo")`: `Found 2 JPA
  repository interfaces.`; the version lines before the context starts; a failed start printed as its class, message and each cause,
  exit 1), `src/probe/q/repo/Customers.java` (`extends JpaRepository<CustomerEntity, Long>`, five methods carrying one JPQL bulk update,
  `update CustomerEntity c set c.mealsPerDay = c.mealsPerDay + 1 where c.mealType = :type`: `bump` (`@Modifying`), `bumpClear`
  (`@Modifying(clearAutomatically = true)`), `bumpFlush` (`@Modifying(flushAutomatically = true)`), `bumpTx` (`@Transactional` on the
  method, `@Modifying`), `bumpNoModifying` (the `@Query` alone)), `src/probe/q/repo/CCustomers.java` (`extends JpaRepository<CCustomer,
  Long>`, the inherited `deleteById`, `deleteAll`, `deleteAllInBatch`, and `@Modifying @Query("delete from CCustomer c where c.name = :n")
  int bulkDelete(String)`), `src/probe/q/casc/CCustomer.java` and `CPause.java` (the harness's own pair on `c_customer`/`c_pause`,
  named apart from the anchor's: `@OneToMany(mappedBy = "customer", cascade = CascadeType.ALL, orphanRemoval = true)`; the pause's
  `@ManyToOne(fetch = LAZY, optional = false) @JoinColumn(name = "customer_id")`), `src/probe/q/casc/Tables.java` (the pair's two
  tables, created by plain JDBC once the shipped `Database` has seeded its own — `ddl-auto` is none; `c_pause.customer_id` references
  `c_customer(id)`, as the anchor's pause references its customer), `src/probe/q/Run.java` (one scenario per JVM; each call between
  `PROBE >>> label` and `PROBE <<< label · statements (getPrepareStatementCount) …` — Hibernate's Statistics cleared before each call;
  JpaTransactionManager's DEBUG lines between the same markers; an exception printed as its class and message, its first cause, then
  each further cause, a newline in a message as ` ⏎ `; the second connection — `DriverManager` on the run's URL), `src/probe/q/Seed.java`
  (unit 18's, byte for byte: the shipped `Database` built in code on the run's own H2 URL; its `createAndSeed` seeds 1 Ravi, 2 Meera,
  3 Sunil, 4 Priya and two pauses — Sunil 3 days, Priya 2 — each read back by the second connection in every harness JVM),
  `src/probe/x/XMain.java` (xcheck's context, unit 21's: `@EntityScan("com.tiffinbox")` alone, outside `probe.q`, so no repository, no
  seed and not the cascade pair), `src/probe/q/ex/ExApp.java` (the exercise's — compiled only by the exercise), `logback.xml` (unit
  18's with one logger added, `org.springframework.orm.jpa.JpaTransactionManager` at DEBUG — S3.2; one line per event, no stack trace —
  `%nopex`), `dur7.py` (the builders', byte for byte, md5 `41667fed…`). English names only (R.215): Ravi, Meera, Sunil, Priya, Kavya.
- `exercise/` — `README.md`, `SOLUTION.md`.
- `.harness/` (git-ignored, rebuilt by every run): `anchor` (the copy, built, extracted); `hc` (the harness); `run` (the JVMs' working
  folder); `ex` (the exercise's copy); the logs. `.r-NAME.1-3` while a capture runs; `.r-NAME.out` its result (git-ignored).
- **Ports (§P, 20010-20019): none bound.** All ten, and 18425 (TiffinBox's default), 8080 and 35729, are checked free at the start and the
  end; 20019 is the one the brief names "never bound" — and so is every other.

## Masks, filters and hygiene — every one, declared

Masks (awk `gsub` only, each with a planted self-test line before any capture): this folder → `…`, the folder above → `…/..`, home → `~`,
the user name → `<user>`; ` using Java <version>`; an identity hash → `@…` (JpaTransactionManager's connection handle); the JDK proxy
class's number → `$Proxy<n>`; an EntityManager's identity → `SessionImpl(<n><open>)`; Spring Data's scan line's figure → `<n>`; H2's
generated `CONSTRAINT_<n>` (in the foreign-key refusal's message and Spring's `constraint […]`), `CONSTRAINT_INDEX_<n>`. `xcheck` prints
Hibernate's generated foreign-key name as `FK<name>` (its md5 is taken of the file itself). Filters: none of a logged line — a harness
JVM's log is printed whole (trailing spaces dropped), H2's two-line refusal messages as Logback wrote them; the exceptions as `Run`
prints them (a newline in a message as ` ⏎ `). Hygiene, over every capture: no absolute path, unit number, log time, timestamp, thread
number, JDK or OS token, figure of elapsed time, stack frame, unmasked proxy number, identity or generated name, URL; every JVM pinned
and under its alarm; no kill by name, no bare `wait`, no one-string multi-option variable; no H2 database file (R.195); no dish name
(R.215). The prose gates, before any build: no duration word (dur7, R.172); no dish name; no placeholder line and no empty "What it
prints" block in the exercise's files; no Spring Data property exception named by its 3.x package (S3.10); no SQL string in this README
outside the values line (R.225, R.227: Hibernate's aliases and the heads of the statements the logger writes); no statement count typed
in the prose (R.184, R.225: a number before statements, SELECTs, DELETEs, UPDATEs or INSERTs). After `flush`: no line saying the
pending change is lost under `clearAutomatically` or that `flushAutomatically` is of no use.

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the Maven or the
`javac` it waits for (`$mpid`, with every process under it), the exercise's shell (`$xpid`), sweeps its own process group for any harness
or exercise JVM (`probe.q.`, `probe.x.`), `javac` or Maven left, deletes the capture runs it had not finished (`.r-NAME.1-3`), and
removes `.r-lock`. The published captures are untouched. No `wait` in the script or the exercise is bare.

**Measured (2026-11-09, the sealed clone, the script as committed):** `./receipts.sh` (/bin/bash 3.2) started in a session of its own
**with SIGINT at its default** (`perl -MPOSIX -e '$SIG{INT}="DEFAULT"; setsid; exec …'`), `kill -INT` to its group once the named
process was in it, the state read 5 s later — three trials, each **exit 130, nothing left**:

```
build: processes in the group at SIGINT 5 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
harness: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
exercise: processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
```

`build` — the anchor's Maven build, its Surefire fork running; `harness` — the first harness JVM (`notx`, `probe.q.Main`); `exercise` —
the exercise's JVM (`probe.q.ex.ExApp`, inside the exercise's `env -i` bash). `pgrep -x java` afterwards: none.

## 1 · notx — the failure receipt (S3.2, S3.10, RED #914)

One harness JVM, three calls, no transaction around them. **B** — `bump(VEG)` with no transaction of the caller's: it throws, and the
capture reads off the log **the class with its package, its message, and its first cause** — each asserted (S3.10): Spring's
`InvalidDataAccessApiUsageException` carrying Jakarta Persistence's `TransactionRequiredException`, both with the same message (the probe
notes' "no TRE in the chain" is wrong — RED #914). No statement between B's markers (the SQL log and Statistics), and **no
JpaTransactionManager line at all**: a declared query method has no transaction of its own and none is made for it (READ FIRST 3). The
second connection reads the seed unchanged. **A** — `bumpTx(VEG)`, `@Transactional` on the method: `Creating new transaction with name
[…bumpTx]`, the bulk statement, committed, Ravi and Sunil one meal more. **C** — `bumpNoModifying(VEG)` (`@Query` without `@Modifying`)
inside a `TransactionTemplate`: the same exception class, another message, another first cause (`IllegalStateException`; Hibernate's
`IllegalSelectQueryException` after it), no statement, the transaction rolled back, nothing changed. B and C share a class: the message
and the first cause are what tell them apart — the check asserts it.

## 2 · stale — the stale context, three witnesses (S3.13; the hook)

One harness JVM, one `TransactionTemplate` around seven calls (one transaction created, one committed — counted): `findById(1)` (one
SELECT, `Participating in existing transaction`), `bump(VEG)` (the bulk statement, two rows, JpaTransactionManager silent between its
markers), the Ravi object, `findById(1)` again, the second connection before the commit, the native read, `em.refresh`; then the second
connection after the commit and the whole table (Ravi and Sunil changed, Meera and Priya not). The three witnesses: above.

## 3 · clear — `clearAutomatically` (the brief's labels B/A/A′)

Three harness JVMs, each one `TransactionTemplate`: `findById(1)`, the bulk method, the Ravi object, `findById(1)` again. **B** — `bump`:
the stale context (the object old, managed; `findById` the same instance, no statement). **A** — `bumpClear`: after the bulk statement
the context is cleared — the Ravi object is **detached** (`em.contains` false) and **still holds the old value**; `findById` runs a
SELECT and returns **another instance with the new value**. **A′** — A in a fresh JVM, the same lines (R.1).

## 4 · flush — the pending change (READ FIRST 9; scoped above)

Three harness JVMs — `bump`, `bumpClear`, `bumpFlush` — each one `TransactionTemplate`: the flush mode printed (`AUTO`); `findById(2)`
(Meera); `meera.setMealsPerDay(3)` in the object only (the second connection still reads the old value); the bulk method: **two
statements, the entity's UPDATE first and the bulk statement second** (the order asserted line by line; Statistics: one entity update);
the Meera object (managed under `bump` and `bumpFlush`, detached under `bumpClear`, its field 3 in all three); after the commit the
second connection reads Meera's 3. The three JVMs ran the same statements in the same order (asserted).

## 5 · cascade — what bulk deletes skip

One harness JVM. **E** — the anchor's `deleteById(3)` (Sunil; `CustomerEntity.pauses` has no cascade, and his pause holds a foreign key
to him): `deleteById`'s own transaction, Sunil loaded, his DELETE at the commit, refused — `DataIntegrityViolationException` ← Hibernate's
`ConstraintViolationException` ← H2's `JdbcSQLIntegrityConstraintViolationException`, its message with the constraint name masked —
rolled back after the commit exception; Sunil and his pause kept (read back). **The cascade pair:** Kavya and two pauses seeded through
`save` (the cascade inserts them), read back; **E2** `deleteById` → the customer, its pauses, each pause deleted, then the customer (the
statements in order); read back empty. Ravi and two pauses seeded, read back; **E3** the JPQL bulk delete in a `TransactionTemplate` →
the bulk statement → the same refusal chain (`C_PAUSE`'s key this time), rolled back, the pauses kept (read back). **F** —
`deleteAll()` on rows **its own step seeds in a fresh state** (the pair's rows deleted by the second connection, then Meera with one
pause, Priya with two and Ravi with none saved), **printed before it runs** (RED #926: the probe's count held only because the earlier
refused delete left rows behind): a SELECT of every customer, a SELECT of pauses per customer, then every pause and every customer
deleted one by one — each count derived from the log and the rows printed before (asserted: pause SELECTs = customers, DELETEs = pauses +
customers, total = the log's lines = Statistics'). **F2** — `deleteAllInBatch()` on a fresh state seeded the same way → one bulk
statement → the refusal, the rows kept.

## 6 · xcheck — the harness's DDL script, against the owning-side lesson's (R.212, RE-MEASURE 3)

`probe.x.XMain` — the anchor's entities alone (`@EntityScan("com.tiffinbox")`, no repository: `Found 0 JPA repository interfaces.`, no
seed, the cascade pair excluded — asserted: no `c_customer`/`c_pause` in the script), `scripts.action=create` into
`.harness/run/hibernate-ddl.sql` (a file, never run): two `create table` lines and one `alter table`, md5
**`f595637014e786fa38606859951e4f97`** = unit 09's published script md5 (its README names it; its `xcheck` capture `9072c6f1…`, asserted)
— no mapping moved since the owning-side lesson, as ⚑3 says for 18-22.

## 7 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s block, then `SOLUTION.md`'s, read from the files, in ONE `env -i` shell — `/bin/bash --noprofile --norc`, then the
same in `/bin/zsh -f`: the README's app (`ExApp`, in `probe.q.ex`, `@EntityScan("com.tiffinbox")`, the shipped `Database` on its own H2, a
repository of its own in the same file with one bulk update over every customer, and a runner that loads Ravi, runs the update and reads
Ravi again in one transaction) → `the JVM: exit 0`, `Found 1 JPA repository interface.`, the update's rows, and **the second read
returning the old value with no statement** (= `stale`'s `findById` again, asserted); the solution (one line: `@Modifying(clearAutomatically
= true)`) → **the new value, read by a statement** (= `clear` A's, asserted). Both exit 0 — the stale read is silent — so broken ≠ solved
is the value and the statement, never the exit code. Bash and zsh print the same; the shell ends in this folder. **Each exercise file's
"What it prints" block is compared with what the run printed, line for line** (a placeholder, an empty block or a changed line stops the
run).

## Exercise

**Your turn:** the README raises everyone's meals with one update and then reads Ravi's old number. Make the next read come from the
database. (24 words, `wc -w`, R.203 — the brief's line, unchanged.) `exercise/README.md` and `exercise/SOLUTION.md`.

## The ledger rows and hand-offs this unit pays

- **Section 3 owns no ledger row** (`PROMISE-LEDGER-2026-11-01.md`); this unit settles none and opens none.
- **RE-MEASURE 1** (the exercise as files) and **3** (xcheck) — below.
- Hand-offs by title: *The Persistence Context*, *Entity States* (managed / detached, flush) — called back; *Batching and the Write
  Path* (U33) — `flushAutomatically` under another flush mode (CARRIED). This is Section 3's last unit: the section's evidence is complete.

## RE-MEASURE — the brief's items this unit settles

| # | Settled here |
|---|---|
| 1 | the exercise as README + SOLUTION files, bash and zsh, `env -i`: the old value with no statement, exit 0 / the new value read by a statement, exit 0; each file's "What it prints" = the run |
| 3 | xcheck for 22: the harness's script with `@EntityScan("com.tiffinbox")` alone = `f5956370…` (unit 09's), on the frozen anchor, the cascade pair excluded |

## What differed from the brief

1. **The anchor's `deleteById(Sunil)` shows fewer SELECTs than the brief's "`select` ×2".** The brief's "`select` ×2" is the probe's Step 10 E,
   which looked Sunil up by name first (`findByName`) and then called `deleteById`; this unit calls `deleteById(3)` alone (Sunil's id,
   read off the seed every JVM prints), so the log shows `deleteById`'s own `findById` and the DELETE — the count in the values line,
   read off the log and Statistics.
2. **The refusal's chain has three links, read off the log**: `DataIntegrityViolationException` ← Hibernate's `ConstraintViolationException`
   ← H2's `JdbcSQLIntegrityConstraintViolationException`. The brief writes "`DataIntegrityViolationException` ← the H2
   `JdbcSQLIntegrityConstraintViolationException`" — the first cause is Hibernate's; H2's is the second. Both asserted (S3.10).
3. **`deleteAll()`'s fresh state is three customers and three pauses — Meera one, Priya two, Ravi none** — seeded by the step itself after
   the pair's rows are deleted by the second connection (plain JDBC, outside Hibernate), and printed before `deleteAll()` runs (RED #926).
   `deleteAllInBatch()` gets the same fresh state. The cascade pair's ids keep counting across those deletes (H2's identity is not reset):
   the refusal messages name the ids that the seeding order gives — the same in every JVM.
4. **`notx` is one JVM with three calls labelled B, A, C** (B the failure receipt, A `bumpTx`, C `bumpNoModifying`), not three JVMs: no
   call changes what the next one meets except A's two rows, which C's rollback leaves as they are (both read back). `clear` is three
   JVMs, B/A/A′, as the brief labels it; `flush` three JVMs, one per method, so each meets the seed's Meera.
5. **The two cascade-pair tables are created by a harness class (`probe.q.casc.Tables`) by plain JDBC**, as the probe's Seed did —
   `ddl-auto` stays none — so `Seed.java` stays unit 18's byte for byte.
6. **The second connection is `DriverManager` on the same URL** (the brief's first option), a JDBC connection of its own — not a second
   `Database`.
7. **`notx` C's first cause is `java.lang.IllegalStateException`** (the probe saw it): asserted with its message, the same as the
   wrapper's; Hibernate's `IllegalSelectQueryException` is the next link (printed, in the values line only as the first cause's class).
8. **The exercise's update has no `where` clause** ("raises everyone's meals", the brief's line): `raiseMeals()` changes all four rows;
   the read it checks is Ravi's, whose numbers match `stale`'s and `clear`'s (2, then 3), each asserted against those captures.
9. **The statements of `flush` are the same three ways and are said once**: the capture prints all three JVMs; the values line names the
   statements and their order once, for `bump`, `bumpClear` and `bumpFlush` alike (asserted equal).
10. **The plant "`@Transactional` on `notx` B"** is run as the brief words it — `@Transactional` added to `bump` in `Customers.java` — and
    `notx` runs first, so its exception check is the one that stops the run (Planted faults).
11. **No TiffinBox JVM, no token**: the captures need neither (⚑3).
12. **The plants ran on scratch mirrors** (unit 21's form), each running the mirror's whole `receipts.sh` as committed.

## Planted faults — each caught (R.65, R.226)

Each on a scratch mirror of this folder (its neighbours linked: `../c7-unit17`, `../c7-tiffinbox`, `../c7-unit09`; its `.m2-demo` an APFS
clone of the s3 seed), one fault at a time, the mirror's whole `receipts.sh`, `env -i`, a session of its own, **all on the script as
committed**, three mirrors at a time; each **exit 1, nothing written to this folder**, the mirror's `receipts.md5` unchanged, no JVM of
the mirror left. The line that stopped each:

| plant | where | caught by |
|---|---|---|
| `bumpClear` in `stale` (the brief's) | `harness/src` | `stale: the loaded object still says the old value and is still managed (witness 1, S3.13): mealsPerDay 2 · em.contains(ravi) false` |
| the native read swapped for a second connection inside the transaction (the brief's) | `harness/src` | `stale native read: …` — R.184's two witnesses (the SQL log's lines and `getPrepareStatementCount()`) both show no statement where a native read runs one: the count fires first; the call read the old value (`the second connection reads 1 \| Ravi \| VEG \| 2 \| 120`, in the mirror's capture), which the value check after it refuses |
| `@Transactional` on `bump` — `notx` B in a transaction (the brief's) | `harness/src` | `notx B: no exception - expected org.springframework.dao.InvalidDataAccessApiUsageException` |
| "clearAutomatically loses the change" in the prose (the brief's) | `README.md` | `a line of the prose says what flush contradicts - on Hibernate 7.4.13.Final, flush mode AUTO the pending change's UPDATE ran before the bulk statement …` (after `flush`) |
| **the first cause dropped from `notx`'s check** (RED #914): B made to throw a stand-in `InvalidDataAccessApiUsageException` with the same message and no cause, and the check reduced to class + message | `harness/src`, `receipts.sh` | **the weak check PASSED** (`notx: B … <- first cause none (the same message) …` printed) — only the published hash stopped it: `notx is not the published capture …` |
| the same stand-in, the real check (class, message, first cause) | `harness/src` | `notx B: the first cause's class: none - expected jakarta.persistence.TransactionRequiredException (S3.10, RED #914)` |
| `deleteAll()` on E3's leftover rows, not its own seed (RED #926) | `harness/src` | `cascade F: deleteAll() runs on the rows its own step seeded, printed first: c_customer 3 · c_pause 3 (RED #926): c_customer 1 · c_pause 2` |
| a wrong published hash (`notx`'s last digit) | `receipts.md5` | `notx is not the published capture …` (after its checks passed) |
| a version claim without `HHH000001` (`org.hibernate.orm.core` at WARN) | `harness/logback.xml` | `notx: the version lines - getVersionString(), Hibernate's HHH000001 and Spring Data JPA's 4.1.2 - once in each of its 1 harness JVMs` |
| a version claim without `4.1.2` (`Main.java`'s Spring Data line removed) | `harness/src` | the same check (S3.15) |
| an Indian dish name | `README.md` | `an Indian dish name (R.215: English names only)` (before any build) |
| a placeholder line in an exercise file (unit 16's own placeholder word, in its "What it prints" block) | `exercise/README.md` | `a placeholder line in this unit's prose - the exercise's blocks hold the measured output` |
| a changed line in a "What it prints" block (`mealsPerDay 4`) | `exercise/SOLUTION.md` | `exercise/SOLUTION.md's "What it prints" block is not what the solution's lines printed` |
| a typed SQL string in prose (the batch delete's SQL) | `README.md` | `a typed SQL string in README.md outside the values line (R.225, R.227)` |
| a typed statement count in prose ("deleteAll() runs" with its count) | `README.md` | `a typed statement count - each is read off a capture, and only the values line states it (R.184, R.225)` |
| xcheck: a wrong unit 09 md5 | `receipts.sh` | `../c7-unit09/README.md must name f595…4f98 - Boot's script md5 (R.212)` |
| the constraint-name mask removed | `receipts.sh` | the mask's self-test, before any capture: `mask: the planted … H2's generated names must be masked` |
| the same, the self-test skipped too | `receipts.sh` | `cascade E: H2's message, its generated constraint name masked (the brief's hazard): … "CONSTRAINT_48: …` — **the 3/3 held** (H2 named the key the same in every JVM); the masked-message check stopped it (and the hygiene regex `CONSTRAINT_` + a hex digit stands behind it) |
| a duration word | `README.md` | `dur7.DUR found a duration word - this unit speaks no time (R.172)` |

**Not run:** none of the brief's or the prompt's plants was left out. A first round on an earlier script (md5 `98f17e54…`) caught every
plant but two the wrong way or not at all — `@Transactional` on `bump` stopped at `notx`'s statement count before its exception check,
`bumpClear` in `stale` at the JVM's exit (a `refresh` of the detached Ravi marks the transaction for rollback) before the witness check,
and "clearAutomatically … is lost" passed the refusal's wording; the checks were reordered (each capture's own claim first, its version
and exit lines last) and the refusal widened (`lost`), and the whole table above re-ran on the script as committed.

## Found on the way

- **The declared bulk method leaves JpaTransactionManager silent even inside the caller's transaction**: between `bump`'s markers in
  `stale` there is no `Participating in existing transaction` line — the inherited `findById` prints one, the declared `@Query` method
  none: it has no `@Transactional` of its own and simply runs on the transaction's EntityManager (READ FIRST 3, from the other side).
- **`deleteById` and `deleteAll()` issue their DELETEs at the commit**, after `Initiating transaction commit` in the log; the refused one
  is rolled back "after commit exception" (JpaTransactionManager's words). The bulk deletes run at the call.
- **`deleteAll()` deletes customer by customer**: a customer's pauses, then the customer, in the order of the first SELECT's rows.

## CARRIED

- **`flushAutomatically` under other flush modes** (22 measured AUTO only) → not this course's, unless U33 (*Batching and the Write
  Path*) sets `FlushModeType.COMMIT` (the brief's CARRIED, unchanged).
- **A bulk update's effect on the second-level cache** → not measured (no second-level cache in TiffinBox).

## For RED

- **The three witnesses** rest on three calls in one capture; "the database disagrees" is said beside the native read alone. Ask whether
  the slide shows the second connection's before-commit read too (it returns the old value — the uncommitted update is not visible to it)
  or leaves it out to keep the beat clean.
- **The flush beat's scope** ("Hibernate 7.4.13.Final, flush mode AUTO") is in the values line; ask whether the voice says the patch
  version or "Hibernate 7.4" (the brief's).
- **`clearAutomatically` detaches every managed entity, not Ravi alone** — measured for Ravi (and Meera in `flush`'s `bumpClear`); the
  "every" is the code's reading (R.201). Ask whether the voice says "clears the persistence context" (measured: two objects detached) or
  narrows it.
- **The constraint name is masked** in every capture; ask whether a slide shows `CONSTRAINT_<n>` or cuts the quoted message after
  `Referential integrity constraint violation`.
- **The first-cause plant** (RED #914): with the cause dropped from the check, a stand-in exception with the same class and message
  passes it (shown) — only the published hash then catches it; with the cause asserted, the check itself does (Planted faults).
