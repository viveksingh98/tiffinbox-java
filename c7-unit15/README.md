# c7-unit15 — The Repository You Do Not Write

Course 7 · Data with JPA & Hibernate · Section 3 (Querying), its first unit, and **the course's fifth change to the anchor — Section
3's first** (brief ⚑1, C1) · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.2** (Spring Data JPA 4.1.2, Hibernate ORM
7.4.13.Final, Jakarta Persistence 3.2.0, H2 2.5.250 — the anchor's pin — HikariCP 7.0.2), 2026-11-07, **on H2 only** (brief ⚑2: 15 is an
H2 unit; every capture says so in its own lines). An interface of two lines and Spring Data JPA hands the container a working
repository: **a proxy** — an object that stands in for another and passes its calls on (the gloss *The Persistence Context* gave) —
whose target is a class Spring Data already wrote, `SimpleJpaRepository`. Measured: the bean itself (its class, its target, its
interfaces, its advices in order — S3.1), what each inherited method runs (the SQL, Statistics, the transaction line — S3.2),
`getReferenceById` inside and outside a transaction, the scan that finds the interface only when TiffinBox is told where to look, and
TiffinBox's own data access, two of whose five SQL strings now leave.

**The anchor changes (brief ⚑1, C1).** `after/` is this unit's frozen copy of `../c7-tiffinbox` after the change; `before` is the link to
`../c7-unit09/after`, Section 2's frozen anchor. Unit 16 builds on `after/` (`16/before → ../c7-unit15/after`). `receipts.sh` prints
`diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c7-tiffinbox` at its start and end — empty in every run of record — and,
from any later anchor change on, prints a note instead (R.211). Every tree is copied under `.harness/` and built there, never in place.
What changed (`anchor` prints the file list, each file's diff and the new file's code lines):

- `tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntityRepository.java` — **new**: `public interface CustomerEntityRepository extends
  JpaRepository<CustomerEntity, Long> {}`, no method of its own (`getDeclaredMethods`: 0), and a Javadoc that says why `JpaRepository`.
- `tiffinbox-core/pom.xml` — `org.springframework.data:spring-data-jpa`, no version (Boot's parent's: 4.1.2).
- `tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java` — `@EnableJpaRepositories("com.tiffinbox")` and a Javadoc paragraph.
- `tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java` — the constructor takes `CustomerEntityRepository` beside `Database`;
  `findAll` → `customers.findAll(Sort.by("name"))` mapped to the record; `add` → `customers.save(new CustomerEntity(…))`, Spring's
  `DataIntegrityViolationException` unwrapped to its `getMostSpecificCause()` `SQLException` (the web layer's 23505 → 409 path and
  `TiffinBoxWebTest`'s mock unchanged); its SQL strings **5 → 3** (`grep -c prepareStatement`, printed by `anchor`); its Javadoc.
- `tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntity.java` — lines 23-24 of its Javadoc, the sentence about the SQL strings, now
  state the count: "CustomerRepository keeps three of its five SQL strings since Course 7 unit 15" (S3.19, R.250 — checked before any
  build: the shipped sentence refused anywhere in `after/`, every sentence about the SQL strings in its sources and its README's unit 15
  section stating three).
- `README.md` — the anchor's: its unit 15 section, the header's note, and in-place notes on the lines that stated the JDBC path in the
  present tense (the brief's `:9`, `:18`, `:28`, `:77`, `:96-98`, `:123`).
- **Kept, unchanged** (R.180): `Database` (both tables, the seed) and its place in `CustomerRepository`'s constructor; `findByName`,
  `monthRevenue`, `pausedDays` (their strings); `application.yaml`; the 18 tests; the web layer (it reads the record `Customer`).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 9 captures, 3 runs each; every spoken number checked after its capture; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version`, `javac -version` and `javap -version` say 25.)
It **dies** when a check after a capture fails, and when a capture's md5 differs from `receipts.md5` (the capture's checks run first, then
the `DIFFERS` line). **Start it in a process group of its own** (a terminal's foreground job is one): `sweep()` stops only processes of its
own group. `.m2-demo` must be seeded first (below). No Docker, no container, no password: every database is H2 in a JVM's memory.

**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`), a session of its own
(`perl -MPOSIX -e 'setsid; exec @ARGV'`), `.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681
files, an APFS clone of the folder). Development runs (one run per capture, a scratch copy of this script) fixed the captures and the
checks — Found on the way; the first full run wrote every capture 3/3, each equal to the development run's md5, and those are
`receipts.md5`. **The runs of record, on the script as committed (`receipts.sh` md5 `edbbf87e7faae2fab745160d95f9de0f`): 260 s under `./receipts.sh`** (/bin/bash
3.2.57) **and 288 s under `bash receipts.sh`** (Homebrew bash 5.3.9), 2026-11-07 from 17:53 CET: each exit 0, all 9 captures 3/3 =
published, every check passed, each of the four builds `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0` (and `tests`'
`offline: yes`, inside its capture), the anchor note empty at the start and the end, nothing listening on 18425, 8080, 35729 or
19940-19949 at the end; each terminal log through `check_unit7.py 15 --runlog` — `0 grep error line(s)`, `RESULT (run logs): PASS` (the
unit gate itself answers "no 15-*.md … nothing to check": no script yet). The builders' `_builders/dur7.py` over this README and the
exercise's two files: 0 duration words. **Nothing was downloaded**, and this unit made no network act. **On the tree as committed** — this README final — one more `./receipts.sh` (`env -i`, a session of its own, from 18:17 CET): exit 0 in 282 s, all 9 = published, `--runlog` PASS.

Published hashes: bean `a842e5bf1c0a134bb428ea3a7992541a` · crud `d407d201355fdc9ac91112582817740d` · ref `af9c5393b6f3c5f949b9f0f5148c8974` · scan `ae2c2d6b3b6c045d1981499aaf8dc7d4` · anchor `c1dc5dbf31af0d618360a39d31bf3980` · seven `eea62e0f1da4b75b5c398cd100162a1f` · tests `97ff84b0e86aa46dcbb1e2ef8d0454d6` · xcheck `7607d048cc7e3c6c16448ac90c3e5fcb` · exercise `e5d0a19c56b04534c7d4bad4dac57fd0`.

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line, R.225 — a number typed
anywhere else is refused):

the values the video may say: 7 advices, the third org.springframework.transaction.interceptor.TransactionInterceptor · target SimpleJpaRepository · JpaRepository declares 12 methods (+ 2 compiler bridges), deprecates deleteInBatch getOne getById · strings 5 -> 3 · Hibernate SQL lines in the seven's log 0 -> 4 (during the seven 0 -> 2) · POST 201, again 409 · by-name GETs 0 Hibernate lines · tests 18 · the seven 466c20ed7e0d5439cb052f32ce09de1b · Boot's DDL f595637014e786fa38606859951e4f97

### A sealed fresh clone — the recipe (R.129)

**Paste it into bash.** Unit 09's recipe, with this unit's folder and the s3 seed:

```bash
S=/tmp/sealed15; W="/tmp/sealed 15"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
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
cd "$W/tiffinbox-java/c7-unit15" && readlink before && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E ./receipts.sh            # a process group of its own
```

**Run (2026-11-07, from 18:02 CET):** a `git clone` of tiffinbox-java at `a44c70d` into a path **with a space** (`…/sealed 15/tiffinbox-java`,
in the session's scratch folder), this commit's 65 files put in as git takes them (`git ls-files -m` and `-o --exclude-standard`, each
`cmp`-equal to the working tree, `before` → `../c7-unit09/after` by `readlink`); a `file://` copy of the s3 seed (5,023 files once
`_remote.repositories`, `*.lastUpdated` and `resolver-status.properties` are left out); pre-flight: exit 1, 221 `Downloading from sealed:
file://`, 0 from http(s); the clone's `.m2-demo` seeded from that copy; `/bin/bash` 3.2, `env -i` with the dead proxies, a session of its
own: **exit 0 in 293 s, all 9 = published, every check passed**; each build `offline: yes · exit 0 · 'Downloaded from' lines in its log:
0`; after the run `.m2-demo` held 5,023 files, 0 `_remote.repositories`; the builders' `dur7.py` is not beside a clone (the terminal says
so; its md5 is the check). Its terminal log through `--runlog`: PASS. (The clone's README was this file before its last prose was filled
in; this README passes the same gates in the run on the tree as committed.)

## The commands this unit adds

```
javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/src/probe/q/Main.java harness/src/probe/q/Run.java harness/src/probe/q/Seed.java
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../after/tiffinbox-web/target/extracted/lib/*" probe.q.Main "${A[@]}"
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.org.hibernate.SQL=debug
```

The harness compiled against `after/`'s extracted jar (91 libraries); **the harness line** (run from `.harness/run`: `V` its JVM flags —
the scenario, `-Ds=bean|crud|ref`, `-Dref=A|B`, `-Dtx=DEBUG` — and `A` its arguments, the same six for every harness JVM, R.193, each
printed as `$ V=(…)` / `$ A=(…)`, `A` with `printf %q`); **the anchor's run line with Hibernate's SQL logger on** (`anchor`, `seven`). Every
java line runs under `perl -e 'alarm 240; exec @ARGV'` (R.247: macOS has no `timeout`; an alarm that fires ends the JVM with exit 142,
which the harness runner refuses); the exercise's JVM under `alarm 120`. The lines read from `after/README.md` (6, each asserted whole) are
unit 09's: `mvn -B package`, `mvn -B clean test`, the run line, the extract line, the GET of `/customers`, and the first-entity lesson's DDL
line (the run line with the two schema-generation options: asserted to be that and nothing else).

## The repository, and the network

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681 files; ⚑8: every Section 3 unit seeds from s3 — 15 needs only s2's
files). Five builds: `before/`'s and `after/`'s `package` (each runs its 18 tests), scan B's and scan C's `package -DskipTests` (labelled
copies), and `tests`' `clean test`; each `offline: yes` with 0 `Downloaded from` lines in every run of record (the label is derived from the
build log, never typed). After the builds the script asserts `.m2-demo` holds `spring-boot-starter-parent-4.1.2.pom`,
`hibernate-core-7.4.13.Final.jar`, `spring-data-jpa-4.1.2.jar` and `h2-2.5.250.jar`. **At run time** every request goes to `127.0.0.1`;
every database is H2 in a JVM's memory (the harness's `jdbc:h2:mem:u15`, TiffinBox's `jdbc:h2:mem:tiffinbox`). **No network act**: the
section's dated sweep is the brief's (`../../../data-jpa-hibernate/_research/spring-boot-metadata-2026-11-07.xml`, md5 `2ccae19d…`: the
4.1 line ends 4.1.2, no 4.1.3; `4.2.0-RC2` not GA — ⚑6, R.223). Spring Data JPA's version is printed by every harness JVM from its jar's
manifest (`JpaRepository.class.getPackage().getImplementationVersion()` → `4.1.2`), beside Hibernate's `HHH000001` line and
`Version.getVersionString()` (S3.15, R.246).

## The demo token

TiffinBox's runs (`scan`, `anchor`, `seven`, `xcheck`) start in a copy under `.harness/` holding a config tree with a 36-character demo
token (`secrets/tiffinbox/shutdown-token`, mode 0600, listed before every start — the token's file and nothing else, R.158); POST
/shutdown sends it from its file on curl's standard input (`harness/shutdown.sh`, `$CURLSET`). Every raw capture run and every log is
counted for it before the mask — 0 every time — and the captures show `[masked: the 36-character token]` where it would be.

## The locale

The JVM ignores `LC_ALL` on macOS: every JVM this script starts carries `-Duser.language=en -Duser.country=US` on its java line, and the
hygiene check refuses a java line without it (and one without its alarm); the test JVM's comes from the POM's `argLine`.

## The folders, the harness and the ports

- `before` → `../c7-unit09/after` (a link; `readlink` asserted); `after/` — this unit's frozen tree (= `../c7-tiffinbox` when committed).
- `harness/` — `src/probe/q/Main.java` (a Spring Boot context, `WebApplicationType.NONE`: it binds no port; `@EntityScan("com.tiffinbox")`,
  `@EnableJpaRepositories("com.tiffinbox")` — the anchor's entities and **the anchor's own interface**, the same two values `TiffinBoxApp`
  carries), `Seed.java` (the shipped `Database` built in code on the run's own H2 URL; its `createAndSeed` seeds 1 Ravi, 2 Meera, 3 Sunil,
  4 Priya and two pauses), `Run.java` (one scenario per JVM; each call between `PROBE >>> label` and `PROBE <<< label · statements
  (getPrepareStatementCount) …` — Hibernate's Statistics cleared before each call; rows read back by a second connection, `DriverManager`),
  `src/probe/q/ex/ExApp.java` (the exercise's — compiled only by the exercise), `logback.xml` (one line per event, no stack trace — `%nopex`:
  the harness prints an exception's class, message and causes itself, R.241), `shutdown.sh` (the CORS lesson's, byte for byte),
  `surefire.py` (the testing lesson's, byte for byte), `dur7.py` (the builders', byte for byte, md5 `41667fed…`). English names only
  (R.215): Ravi, Meera, Sunil, Priya, Kavya, Asha, Dev, Nina, Omar.
- `exercise/` — `README.md`, `SOLUTION.md`.
- `.harness/` (git-ignored, rebuilt by every run): the copies `before`, `after`, `scanb`, `scanc`, `tests`; `hc` (the harness's classes);
  `run` (the harness's working folder); the logs. `.r-NAME.1-3` while a capture runs; `.r-NAME.out` its result (git-ignored).
- **Ports (§P, 19940-19949):** scan A 19940 · B 19941 · A′ 19942 · C 19943 · anchor 19944 · seven `before/` 19945 · `after/` 19946 · xcheck
  19947 · 19948 spare (never bound by the script) · 19949 never bound. All ten, and 18425, 8080 and 35729, are checked free at the start
  and the end; a server that listens on 8080, 35729 or 19949 is killed and the run stops. Every TiffinBox listens on `127.0.0.1` only
  (printed). The harness's JVMs, the tests and the exercise bind none.

## Masks, filters and hygiene — every one, declared

Masks (awk `gsub` only, each with a planted self-test line before any capture): the demo token → `[masked: the 36-character token]`;
this folder → `…`, the folder above → `…/..`, home → `~`, the user name → `<user>`; ` using Java <version>`; a generated H2 name
`jdbc:h2:mem:<uuid>`; an identity hash → `@…`; **the JDK proxy class's number → `$Proxy<n>`** (S3.1, R.232: checked by a regex in `bean`
— `$Proxy<n>` present, no `$Proxy` followed by a digit anywhere; the number was the same in every JVM, so 3/3 cannot catch it, RED #911);
an EntityManager's identity → `SessionImpl(<n><open>)`; Spring Data's scan line's time figure → `<n>`; H2's generated
`CONSTRAINT_<n>`, `CONSTRAINT_INDEX_<n>`. Filters: a harness JVM's log is printed whole (trailing spaces dropped); a TiffinBox log, the
named loggers' lines (Hibernate's core and SQL loggers, `TiffinBoxServer`, the EntityManagerFactory's, Spring Data's
`RepositoryConfigurationDelegate`, Boot's `SpringApplication` and failure reporter) and Boot's failure analysis as printed; `anchor`'s
TiffinBox log without its SQL lines (each request prints its own). Hygiene, over every capture: no absolute path, unit number (but in a
line quoted from the anchor's files), log time, timestamp, thread number, JDK or OS token, random port, figure of elapsed time, `javap -v`
header, stack frame, unmasked proxy number, identity or generated name, URL other than 127.0.0.1's; every JVM pinned and under its alarm;
no kill by name, no bare `wait`, no one-string multi-option variable; no H2 database file (R.195); no dish name (R.215).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the Maven it
waits for (`$mpid`, with every process under it — Surefire's fork), the exercise's shell (`$xpid`), sweeps its own process group for any
TiffinBox JVM, harness or exercise JVM (`probe.q.`), Maven or Surefire fork left, deletes the capture runs it had not finished
(`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched. No `wait` in the script or the exercise is bare.

**Measured (2026-11-07, the sealed clone, the script as committed):** `./receipts.sh` (/bin/bash 3.2) started in a session of its own
**with SIGINT at its default** (`perl -MPOSIX -e '$SIG{INT}="DEFAULT"; setsid; exec …'` — a background job of a script inherits SIGINT
ignored, and a first attempt without the reset ran to its end, exit 0: the trials below reset it), `kill -INT` to its group once the
named process was in it, the state read 5 s later — three trials, each **exit 130, nothing left**:

```
build: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
harness: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
boot: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
```

`build` — the first Maven (`before/`'s package, its Surefire fork); `harness` — the first harness JVM (`bean`); `boot` — TiffinBox itself
(`scan` A, port 19940). `pgrep -fl java` afterwards: none of this unit's.

## 1 · bean — the proxy, not the interface (S3.1, R.232)

One harness JVM. The interface declares 0 methods (`getDeclaredMethods`); the bean of its type is `customerEntityRepository`, of class
`jdk.proxy2.$Proxy<n>` — `Proxy.isProxyClass` true, `AopUtils.isJdkDynamicProxy` true — whose target (`Advised.getTargetSource()`) is
`org.springframework.data.jpa.repository.support.SimpleJpaRepository`; it implements `com.tiffinbox.CustomerEntityRepository`, Spring
Data's `Repository` and `TransactionalProxy`; its advices, in order, numbered 1..n (the count is the list's length, R.225): Spring Data's
`CrudMethodMetadataPopulatingMethodInterceptor`, `PersistenceExceptionTranslationInterceptor`, **`TransactionInterceptor`** (the third),
`DefaultMethodInvokingMethodInterceptor`, `QueryExecutorMethodInterceptor`, `ImplementationMethodExecutionInterceptor`,
`PersistenceExceptionTranslationInterceptor` again. `findById(1)` through it: one SELECT (the SQL line and Statistics, R.184). Then
**`javap`** of `JpaRepository` from `after/`'s jars: `extends ListCrudRepository, ListPagingAndSortingRepository, QueryByExampleExecutor`;
`javap -v` read by `.harness/javapv.py` — 14 methods in the class file, of them 2 marked `ACC_BRIDGE` (the compiler's bridges, the two
`Iterable findAll(Example…)`), **12 declared**; `Deprecated` on `deleteInBatch`, `getOne`, `getById` (RED #913). Its parents' first lines,
and `CrudRepository`'s `findAll()` → `java.lang.Iterable<T>` (`ListCrudRepository`'s → `java.util.List<T>`) — the reason the anchor's
interface is `JpaRepository`: `CustomerRepository` needs `findAll(Sort)` and a `List`. The version lines (`HHH000001`, `getVersionString()`
7.4.13.Final, Spring Data JPA 4.1.2) and the `database:` line (H2 2.5.250) once in its JVM.

## 2 · crud — what each inherited method runs (S3.2, R.233; R.184)

One harness JVM, `JpaTransactionManager` at DEBUG. Its calls are counted twice (SQL lines between the markers = `getPrepareStatementCount`),
and a transaction is JpaTransactionManager's own line: `findById(1)`, `findAll()`, `count()` (`select count(*)`), `existsById(1)`
(`select count(*) … where ce1_0.id=?`) — 1 statement each, each `Creating new transaction with name
[org.springframework.data.jpa.repository.support.SimpleJpaRepository.<method>]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT,readOnly`;
`save(a new Kavya)` — `insert into customer (meal_type,meals_per_day,name,price_per_meal,id) values (?,?,?,?,default)` between `before
save(): id null` and `after save(): id 5 · same instance true`, its transaction not `readOnly`; `findById(5)` in its own call (the detached
copy loaded apart — RED #915); `save(the detached copy, mealsPerDay 3)` — a SELECT then an UPDATE, **2**, `same instance false`, a second
connection reads `5 | Kavya | 3`; `deleteById(5)` — SELECT + DELETE, `no row 5`; `deleteById(99)` — the SELECT only, `returned, no
exception`; `saveAll(Asha, Dev, Nina)` — 3 INSERTs, ids 6, 7, 8, one transaction. These are the **inherited** methods' lines only: a
declared query method's transaction is unit 16's capture.

## 3 · ref — getReferenceById, inside and outside a transaction (A/B/A′)

A (a `TransactionTemplate`, a fresh JVM): `com.tiffinbox.CustomerEntity$HibernateProxy`, **no SQL until `before getName()`**, then one
SELECT, `Ravi`; the repository call `Participating in existing transaction`. B (no transaction of the caller's): `getReferenceById`'s own
`readOnly` transaction opens and closes before `getName()` (the log's order, asserted), then **`org.hibernate.LazyInitializationException:
Could not initialize proxy [com.tiffinbox.CustomerEntity#1] - no session`** (class, package, message — it has no cause, R.241), 0
statements. A′ = A, line for line (R.1). *Lazy Loading and LazyInitializationException* (U29) is named forward by title only.

## 4 · scan — TiffinBox finds the interface only when told where (A/B/A′, C labelled — the failure receipt)

TiffinBox itself, four fresh JVMs. **A** (`after/`, 19940): `Finished Spring Data repository scanning in <n>. Found 1 JPA repository
interface.`, started, stopped by POST /shutdown. **B** (labelled: `after/` copied to `.harness/scanb` with the one line
`@EnableJpaRepositories("com.tiffinbox")` taken out of `TiffinBoxApp.java` — asserted the only difference — built with the README's
package line and `-DskipTests`; 19941): **the trio** — it ends by itself, exit 1, never listened, readiness never answered; `Found 0 JPA
repository interfaces.`; Boot's failure analysis: `APPLICATION FAILED TO START` · `Parameter 1 of constructor in
com.tiffinbox.CustomerRepository required a bean of type 'com.tiffinbox.CustomerEntityRepository' that could not be found.` · `Consider
defining a bean of type 'com.tiffinbox.CustomerEntityRepository' in your configuration.` **A′** = A (19942; the same lines, its port
aside). **C** (labelled: `before/` plus `CustomerEntityRepository.java` and the core POM's dependency — asserted the only differences —
no annotation, nothing using the interface; 19943): `Found 0 JPA repository interfaces.`, started — **silent**. Boot's own scan starts in
`TiffinBoxApp`'s package, `com.tiffinbox.web`.

## 5 · anchor — the change, the count, the sentences; TiffinBox's two changed methods over HTTP

The file list (diff -rq), each changed file's diff, the new interface's code lines; **`grep -c prepareStatement`** over `before/`'s and
`after/`'s `CustomerRepository.java`: **5 → 3** (R.187, a named command); the sentences that state the count (S3.19, each read whole:
`CustomerEntity.java`'s, `CustomerRepository.java`'s, the anchor README's unit 15 section's — each says three). Then TiffinBox (`after/`,
19944, its own H2, the SQL logger on), each request's status, body and the log lines it added: **POST Kavya → 201**, one Hibernate
INSERT; **POST Kavya again → 409** (`a customer named Kavya already exists`), one INSERT and **two WARN lines** from
`org.hibernate.orm.jdbc.error` — `HHH000247: ErrorCode: 23505, SQLState: 23505` and H2's `Unique index or primary key violation:
"PUBLIC.CONSTRAINT_<n> INDEX PUBLIC.CONSTRAINT_INDEX_<n> ON PUBLIC.CUSTOMER(NAME NULLS FIRST) …"` — no ERROR (the `SQLException` unwrapped:
the 23505 → 409 path holds); **`GET /customers/Kavya` → 200 and a stranger (`/customers/Omar`) → 404, 0 Hibernate lines each** —
`findByName` is still `CustomerRepository`'s own string (unit 16's "before", RED #932).

## 6 · seven — a guard (R.190), and the witness

`before/`'s jar (19945) and `after/`'s (19946), each a fresh JVM with Hibernate's SQL logger on: the seven
**`466c20ed7e0d5439cb052f32ce09de1b`** on both, 0 lines differ — they cannot tell the two trees apart. **The witness** (R.194): the SQL
logger's lines — `before/` **0** in its whole log; `after/` **4** in its whole log (each `findAll(Sort.by("name"))`'s `select … order by
ce1_0.name`): 1 before `Started TiffinBoxServer` (`TiffinBoxServer.start()`), 1 from there to readiness's 200 (the readiness group's
`kitchen` check), **2 during the seven itself**. `Found 0` → `Found 1`.

## 7 · tests — TiffinBox's tests (C7-4)

`after/` copied, `mvn -o -B … clean test`: **18** (14/3/1) from Surefire's reports, the console's summary the same; in the tests' log
`Found 1 JPA repository interface.` twice (the two contexts that build the data layer) — a guard (R.190).

## 8 · xcheck — Boot's DDL script, against the owning-side lesson's (R.212)

`after/`'s jar with the anchor README's DDL line (19947): the script's md5 **`f595637014e786fa38606859951e4f97`** = unit 09's published
script md5 (its README names it; its `xcheck` capture `9072c6f1…`) — the change moved no mapping.

## 9 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s block, then `SOLUTION.md`'s, read from the files, in ONE `env -i` shell — `/bin/bash --noprofile --norc`, then the
same in `/bin/zsh -f`: the README's app (`ExApp`, in `probe.q.ex`, `@EntityScan("com.tiffinbox")`, a runner that needs TiffinBox's core
repository) → `the JVM: exit 1`, `Found 0 JPA repository interfaces.`, `APPLICATION FAILED TO START`, `Parameter 0 of method kitchen in
probe.q.ex.ExApp required a bean of type 'com.tiffinbox.CustomerEntityRepository' that could not be found.`; the solution (one line: the
copy gains `@EnableJpaRepositories("com.tiffinbox")` beside `@EntityScan`) → `exit 0`, `Found 1 JPA repository interface.`, `PROBE ready: …
target SimpleJpaRepository`. Bash and zsh print the same; the shell ends in this folder.

## Exercise

**Your turn:** the README adds a repository to TiffinBox's core and the application refuses to start. Tell Spring Data where to look.
(22 words, `wc -w`, R.203.) `exercise/README.md` and `exercise/SOLUTION.md`.

## The anchor's README — what this unit changed in it

- **A new section**, `## Course 7 · unit 15 — the repository you do not write: …`, after unit 09's: the new file and the four changed, the
  scan (B's analyzer line, C's silence), the count three of five, what changes and what does not (the seven and the 18 tests guards; the
  SQL logger's 0 → 4; Kavya's 201/409 and the two WARN lines; the by-name GETs still JDBC; `Database` unchanged).
- **The header** — a note: Section 3's first change, the interface, the annotation, three of five strings.
- **In place, the brief's lines** that stated the JDBC path in the present tense: `:9` (the five strings), `:18` (unit 03's note: both
  reach the same database), `:28` ("which keeps its SQL strings"), `:77` ("Two ways into one database"), `:96-98` (unit 06's PostgreSQL
  paragraph — a customer added over HTTP written by JDBC), `:123` (unit 07's "still written by `CustomerRepository` as a string") — each
  gains a note that starts *Course 7, unit 15*.

## The shipped receipts on the moved anchor (R.211)

`../c7-unit09/receipts.sh` (unchanged, md5 `4b0c9581…`) run once on the moved anchor, `./receipts.sh` (/bin/bash 3.2.57), `env -i`, a
session of its own, 2026-11-07 from 17:37 CET: **exit 0 in 235 s** (beside this unit's plant mirrors), the note `(after/ and
../c7-tiffinbox differ - the anchor has moved past the tree this unit froze: Files after/README.md and ../c7-tiffinbox/README.md
differ;Files after/tiffinbox-core/pom.xml and …)` at its start and end, all 8 captures 3/3 = published, `receipts.md5` unchanged,
`check_unit7.py 09 --runlog` PASS; its README gains one dated paragraph saying so.

`../c7-unit14/receipts.sh` (unchanged, md5 `fbf41b61…`) run once on the moved anchor the same way, from 17:41 CET: **exit 0 in 171 s**,
its anchor check's note (`anchor/ and ../c7-tiffinbox differ …`) at its start and end, all 7 captures 3/3 = published, its own container
(`c7-u14-pg`, 127.0.0.1:19938, its design) started and removed, `receipts.md5` unchanged, `check_unit7.py 14 --runlog` PASS; its README
gains one dated paragraph.

Units 01-08 and 10-13 were not re-run (the brief's order): one `grep` shows each of `c7-unit01..14/receipts.sh` prints the note form
(`moved past`/`moved on`: 14 of 14) and dies on `../c7-tiffinbox` only when it is missing (every such `die`: "is missing"). **The
builders** (R.211): `grep -n c7-tiffinbox` over `_builders/*.py`, `check_unit7.py`, `qa_java7.py` — the four pinned asserts (`s703:44`,
`s706:49`, `s707:53`, `s709:53`, each `git show <hash>:c7-tiffinbox/<p>`), the two tools 0 lines. A scratch copy of `_builders/`
(a copy never writes into the course, R.202) ran `s709.py` after 09's re-run, with the venv's python: exit 0, its two `note: c7-tiffinbox's
… has moved on since 9853dae` lines (`CustomerEntity.java`, `README.md`), and the script it wrote byte for byte the shipped
`09-onetomany-manytoone-and-the-owning-side.md`.

## The ledger rows and hand-offs this unit pays

- **C7-4 — re-run**: 18, unchanged (`tests`), a guard (R.190).
- **CARRIED "U15 retires `CustomerRepository`'s strings" — begun**: 2 of 5 (`findAll`, `add`); 16 takes `findByName` (3 → 2), 17 the two sums
  (2 → 0) and `@DependsOn("database")` (READ FIRST 1).
- Hand-offs by title: *Lazy Loading and LazyInitializationException* (U29) — `ref` B's exception; *Derived Query Methods* (16) — the by-name
  route's SQL, 0 Hibernate lines here.

## RE-MEASURE — the brief's items this unit settles

| # | Settled here |
|---|---|
| 1 | the exercise as README + SOLUTION files, bash and zsh, `env -i`: Found 0 + the analyzer's lines, exit 1 / Found 1, ready, exit 0 |
| 4 | the anchor change C1 on the frozen tree (`09/after` → `15/after`) with its comments, Javadoc and README: strings 5 → 3, the seven `466c20ed…`, 4 SQL lines, 18/18, 201/409 |
| 11 | `scan` B as a labelled copy built under `.harness/` (`.harness/scanb`, the one line taken out, asserted) |
| — | "18/18" (the probe's sketch until this receipt, BLUE): `tests` 18 (14/3/1) |

## What differed from the brief

1. **The SQL-count witness, split in three.** The brief's "the `org.hibernate.SQL` count during the seven **0 → 4**" is the whole log's
   count (the probe's sevens polled readiness on `GET /customers`). Measured here: `before/` 0, `after/` **4 in the log** — 1 at the start
   (`TiffinBoxServer.start()`), 1 for readiness's 200 (the `readiness` group includes `kitchen`, whose health check calls `findAll`), **2
   during the seven itself**. The capture prints all three and the check asserts 4 in all and more than 0 during the seven; the values
   line says both (`0 -> 4 (during the seven 0 -> 2)`). Counting from a mark after readiness's 200 keeps it 3/3: readiness is polled
   until it answers 200, and each poll before that is not a fixed number.
2. **H2's duplicate logs two WARN lines, no ERROR** — the brief (from B2) said "`WARN … HHH000247` + an ERROR line". On C1, Hibernate
   7.4.13.Final logs both lines at WARN under `org.hibernate.orm.jdbc.error` (`HHH000247: ErrorCode: 23505, SQLState: 23505`, then H2's
   message); `anchor` asserts `WARN: 2 · ERROR: 0` for that request. The JDBC path's count for the same 409 was not re-run here (not said).
3. **The bean is the anchor's own interface.** ⚑3 names "the unit's repository package"; for 15 the harness's `@EnableJpaRepositories`
   names `com.tiffinbox`, so the bean S3.1 prints is TiffinBox's `CustomerEntityRepository` from `after/`'s core jar — an interface with
   no method of its own (RED #912's condition met by the shipped class itself, `getDeclaredMethods` 0), not a harness copy.
4. **The harness's logging is a Logback file Boot reads** (`--logging.config=…/harness/logback.xml`, `%nopex`: no stack trace in any
   capture; the harness prints an exception's class, message and causes itself, R.241) rather than Boot's console pattern — so a
   harness log carries no PID, thread or time, and the `PROBE` lines and the named loggers' lines are the whole log.
5. **`scan` B and C are built with `-DskipTests`** (labelled): B cannot pass `FullStackTest` (its context fails to start — that is the
   capture), and C's tests are `before/`'s, which `before/`'s own build runs. Each copy is asserted to differ from its source by exactly
   the planned lines (B: the annotation's line; C: the interface and the core POM).
6. **The exercise is a harness application over TiffinBox's core jar**, not a TiffinBox rebuild: `ExApp` (in `probe.q.ex`, outside
   `com.tiffinbox`, as `TiffinBoxApp` is) needs TiffinBox's own `CustomerEntityRepository`; its broken half prints Boot's analyzer lines
   with the runner's name (`Parameter 0 of method kitchen in probe.q.ex.ExApp …`), TiffinBox's (`Parameter 1 of constructor in
   com.tiffinbox.CustomerRepository …`) is `scan` B's. A Maven rebuild per half and per shell would have been four builds per run.
7. **`javap`'s count is read off `javap -v` by a small reader** (`.harness/javapv.py`, counts and names only — `javap -v`'s header holds a
   path, a date and a checksum, never printed): 14 methods, 2 `ACC_BRIDGE`, 12 declared; plain `javap` prints the 14 lines, and the check
   asserts 12 + 2 = 14.
8. **`ref` B's transaction is visible**: `getReferenceById` itself runs in its own `readOnly` transaction (JpaTransactionManager's line),
   which closes before `getName()` — asserted from the log's order. The brief's "B outside" holds: outside the caller's transaction.
9. **The plants ran on a scratch mirror with only the planted capture kept** (the other `cap` lines removed from the mirror's
   `receipts.sh`, the prose gates and the builds kept) — each still exits 1 at its own check; a gate plant needs no capture at all.
10. **Ports:** as the brief's §P (19940-19947 bound; 19948 spare and 19949 never bound — both checked free at the start and the end).
11. **The anchor README's `:96-98` note** (unit 06's PostgreSQL paragraph): unit 15 is H2 only, so the note says a customer added over
   HTTP is written by Hibernate since, on the same URL, and that the PostgreSQL run is not repeated here.

## Planted faults — each caught (R.65)

Each on a scratch mirror of this folder (its neighbours linked: `../c7-unit09`, `../c5-unit11`, `../c6-unit19`, `../c6-unit28`,
`../c7-tiffinbox`), one fault at a time, the mirror's `receipts.sh` keeping only the planted fault's capture (What differed 9), `env -i`;
each **exit 1, nothing written to this folder**, no JVM of the mirror left and nothing listening on 19940-19949 after it. The line that
stopped each:

| plant | where | caught by |
|---|---|---|
| the `$Proxy` mask removed (S3.1) | `mask()` | the mask's self-test first: `mask: … proxy number … must be masked` |
| the mask **and** its self-test line removed | `mask()` | `bean`'s regex: `the JDK proxy's class must print as jdk.proxy2.$Proxy<n> - its number masked (S3.1, R.232): jdk.proxy2.$Proxy121` — not 3/3 (RED #911) |
| `@EnableJpaRepositories` taken out of the solution's `sed` | `exercise/SOLUTION.md` | `exercise: the solution - Found 1, ready: expected the line: the JVM: exit 0` |
| `scan` B run on 15/after (the copy's `grep -v` of the annotation replaced by `cat`) | `receipts.sh` | B became ready and was stopped; the trio check: `expected the line: it ended by itself: exit 1 · listening on 19941: 0 · readiness never answered 200` |
| a typed advice count (the number word before "advices") in a README line | `README.md` | `a typed advice count - the number is len() of bean's printed list, stated only in the values line (R.225)` |
| a SAY line claiming every call is wrapped in its own transaction (the brief's refused sentence, word for word) | `README.md` | the S3.2 (R.233) refusal, its message quoting the claim and the README line |
| `CustomerEntity.java:23-24` left as shipped ("keeps its SQL strings") | `after/` | `a sentence of the anchor still says CustomerRepository keeps its SQL strings - after this change it keeps three of five (S3.19, R.250)` (before any build) |
| the SQL-count witness swapped for the seven's hash — `before/`'s jar put in `after/`'s place (the change not applied) | `receipts.sh` | (a) the shipped check: `seven: after/'s log - 4 Hibernate SQL lines in all, and more than 0 during the seven (0 0)`; (b) the same tree with the SQL-count lines removed from the check, the hash alone: `seven: the guard alone - 466c20ed… on both trees` — **the hash check passed: it cannot fail** (R.190); the run then stopped at `seven … DIFFERS` (the capture itself changed) |
| a wrong published hash (`bean`'s last digit) | `receipts.md5` | `bean md5 a842e5bf… 3/3 DIFFERS from the published …0` |
| no `HHH000001` (`org.hibernate.orm.core` at WARN) | `harness/logback.xml` | `bean: the version lines - getVersionString(), Hibernate's HHH000001 and Spring Data JPA's 4.1.2 - once in each of its 1 harness JVMs (R.222, S3.15/R.246)` |
| no Spring Data version line (`Run.java`'s line removed) | `harness/src` | the same version check (S3.15) |
| an Indian dish name | `README.md` | `an Indian dish name (R.215: English names only)` |
| crud: the detached copy's load moved back into the save step | `harness/src` | `crud findById(Kavya's id) …: 1 statements - the SQL log's lines (0) and getPrepareStatementCount() (0) both (R.184)` |
| ref: B run inside a transaction (`-Dref=A` for B) | `receipts.sh` | `ref B: no call named getReferenceById(1) outside any transaction, then getName()` |
| anchor: the `SQLException` no longer unwrapped (`throw e` only) | `after/` | the change's own diff line: `anchor: the change: expected the line: + if (e.getMostSpecificCause() instanceof SQLException refused) {` |
| tests: `FeedTest.java` deleted | `after/` | `tests: expected the line: TEST-com.tiffinbox.web.FeedTest.xml: tests 1 …` |
| xcheck: a wrong unit 09 md5 | `receipts.sh` | `xcheck: ../c7-unit09/README.md must name f595…4e90, and its receipts.md5 its xcheck 9072c6f1… (R.212)` |

(The first batch's runs of the version, crud, ref, scan, anchor and seven plants stopped at the duration gate instead — this README then
held a duration word, Found on the way — and were run again after it was fixed; the table gives the second runs.)

## Found on the way

- **The readiness group calls `findAll`.** `application.yaml`'s `management.endpoint.health.group.readiness.include: readinessState,kitchen`:
  `KitchenHealthIndicator.health()` calls `repo.findAll()` — since this unit a Hibernate SELECT. A count of SQL lines that starts before
  readiness answers 200 counts the readiness checks too (first draft of `seven`, whole log); the receipt counts from a mark after the 200.
- **`ExApp`'s first grep line carried the unit of the scan's time** (a `sed` that masked it) — `dur7.DUR` refused the exercise files; the
  block now keeps `Found N JPA repository interface(s).` with `grep -o`, no figure of time on screen.
- **The S3.19 check read lines first, not sentences** — the Javadoc's "three of its / five SQL strings" broke over two lines and the line
  check refused it; the check now reads each sentence whole (`.harness/sent.py`: a file's lines joined, a Javadoc's `*` dropped).
- **S3.2's first regex was too wide** ("each inherited method runs (the SQL, Statistics, the transaction line)" matched); narrowed to a
  sentence that says a call or method runs in/inside/within a transaction — the plant line still refused.
- **This README held a duration word for a while** (the unit of the scan's figure, in this section) — `dur7.DUR` stopped the plant
  mirrors copied in that window at the gate; fixed, and those plants run again.
- **The anchor's Javadoc must not say `prepareStatement`**: a Javadoc line quoting `grep -c prepareStatement: 3` made `grep -c` say 4 —
  the count is of lines, so `CustomerRepository`'s Javadoc names the receipt instead (`../c7-unit15, anchor: 5 -> 3`).

## CARRIED

- **`CustomerRepository`'s other three strings** → 16 (`findByName`, 3 → 2) and 17 (`monthRevenue`, `pausedDays`, 2 → 0, `@DependsOn("database")`).
- **The two connection paths** (Hibernate through Boot's pool for `findAll`/`add`; `DriverManager` for the other three and `Database`'s
  seed) → ⚑12: settled by 17; `Database`'s seed → U36 (Flyway).
- **`getReferenceById` outside a transaction** → *Lazy Loading and LazyInitializationException* (U29), by title.
- **A declared query method's transaction** (none — READ FIRST 3) → 16's capture; this unit's `crud` shows inherited methods only.
- **H2's two WARN lines on a duplicate** — said where a slide shows the log (the brief's hazard, measured here as two WARN, no ERROR).
- **The 409's JDBC-path log count** (the brief's "logged 0") — not re-run here; not said.

## For RED

- **The witness can fail; the guards cannot** (R.190): the plant that puts `before/`'s jar in `after/`'s place passes the seven's hash
  check (`466c20ed…` both) and is stopped by the SQL-count check (Planted faults). Ask whether 2 during the seven is enough of a witness
  next to the whole log's 4.
- **`$Proxy<n>`**: the mask's check is the regex (S3.1); the plant without the mask is caught there, not by 3/3.
- **The advice list** is read off `Advised.getAdvisors()` in order; its length is the count (R.225); the voice may not type it anywhere
  but the values line. Ask whether "the transaction interceptor third" is a fact of Spring Data JPA 4.1.2 only (it is printed beside
  4.1.2; S3.15).
- **`scan` C**: before/ plus the interface and the POM's dependency — the only differences, asserted. Ask whether a "silent" C should also
  show that nothing injects the interface (it is `before/`'s `CustomerRepository`, unchanged: `diff -rq` lists only the two files).
- **`anchor`'s request counts** are read from the log lines each request added, after the log stops growing (polled, 0.25 s steps); the
  409 request's two WARN lines are inside its window in every run (3/3).
- **The exercise is a harness app** (What differed 6): ask whether the spoken line ("the README adds a repository to TiffinBox's core and
  the application refuses to start") fits an app that is not TiffinBox but needs TiffinBox's core repository.
- **The S3.2 refusal regex** is narrow by design (What differed / Found on the way): it refuses "every/each/all … call(s)/method(s) … runs in
  a transaction" shapes; try a wording it lets through.
