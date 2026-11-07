# c7-unit16 — Derived Query Methods

Course 7 · Data with JPA & Hibernate · Section 3 (Querying), its second unit, and **the course's sixth change to the anchor — Section
3's second** (brief ⚑1, C2) · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.2** (Spring Data JPA 4.1.2, Hibernate ORM
7.4.13.Final, Jakarta Persistence 3.2.0, H2 2.5.250 — the anchor's pin — HikariCP 7.0.2), 2026-11-07, **on H2 only** (brief ⚑2: 16 is an
H2 unit; every capture says so in its own lines). A **derived query** is a query nobody writes: Spring Data reads a repository method's
name — a subject (`find`, `exists`, `count`, `delete`), `By`, then properties of the entity joined by keywords (`And`, `GreaterThan`,
`ContainingIgnoreCase`, `OrderBy … Desc`, `First`, `Top3`, `Distinct`) — and derives the query from it at start, checking every property
against the entity. Measured: the SQL each keyword produced (read off Hibernate's SQL logger, never typed), that a declared query method
logs no transaction of its own and what that does to a derived delete, that a misspelt property stops TiffinBox's start, the longest
name measured, and TiffinBox's own `findByName`, the third of its five SQL strings to leave.

**The anchor changes (brief ⚑1, C2).** `after/` is this unit's frozen copy of `../c7-tiffinbox` after the change; `before` is the link to
`../c7-unit15/after`, the anchor after Section 3's first change. Unit 17 builds on `after/` (`17/before → ../c7-unit16/after`).
`receipts.sh` prints `diff -rq -x .m2-demo -x target -x secrets -x .harness after ../c7-tiffinbox` at its start and end — empty in every
run of record — and, from any later anchor change on, prints a note instead (R.211). Every tree is copied under `.harness/` and built
there, never in place. What changed (`anchor` prints the file list and each file's diff):

- `tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntityRepository.java` — one method of its own, `Optional<CustomerEntity>
  findByName(String name);`, no query written for it; its Javadoc's unit 15 sentence ("none is declared here") rewritten in place, and a
  unit 16 paragraph.
- `tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java` — `findByName` is `customers.findByName(name).map(CustomerRepository::toRecord)`;
  its signature (`Optional<Customer>`, `throws SQLException`) unchanged, so `TiffinBoxServer`'s route and `TiffinBoxWebTest`'s mock are;
  its SQL strings **3 → 2** (`grep -c prepareStatement`, printed by `anchor`); its Javadoc.
- `tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntity.java` — lines 23-24 of its Javadoc, the sentence about the SQL strings, now
  state the count: "CustomerRepository keeps two of its five SQL strings since Course 7 unit 16" (S3.19, R.250 — checked before any
  build: unit 15's sentence refused anywhere in `after/`'s sources, every sentence about the SQL strings in them and in its README's unit 16
  section stating two).
- `README.md` — the anchor's: its unit 16 section, the header's note, and in-place notes on the lines that stated `findByName`'s JDBC
  path or the count three in the present tense (the header's note on the five strings, unit 03's "keeps its SQL strings", unit 03's "Two
  ways into one database", and unit 15's section — its "keep theirs" line and its by-name sentence).
- **Kept, unchanged** (R.180): `Database` (both tables, the seed) and its place in `CustomerRepository`'s constructor; `monthRevenue`,
  `pausedDays` (their strings); `TiffinBoxApp` (its `@EnableJpaRepositories("com.tiffinbox")`); the core POM; `application.yaml`; the 18
  tests; the web layer (it reads the record `Customer`).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 9 captures, 3 runs each; every spoken number checked after its capture; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version` and `javac -version` say 25.) It **dies** when a
check after a capture fails, and when a capture's md5 differs from `receipts.md5` (the capture's checks run first, then the `DIFFERS`
line). **Start it in a process group of its own** (a terminal's foreground job is one): `sweep()` stops only processes of its own group.
`.m2-demo` must be seeded first (below). No Docker, no container, no password: every database is H2 in a JVM's memory.

**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`), a session of its own
(`perl -MPOSIX -e 'setsid; exec @ARGV'`), `.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681
files, an APFS clone of the folder). Development runs (a scratch copy of this script, `.r-dev.sh`, git-ignored, whose two README gates
print instead of stopping) fixed the captures and the checks — Found on the way; the first full run wrote every capture 3/3, and those
md5s are `receipts.md5`. **The runs of record, on the script as committed (`receipts.sh` md5 `4416a78a11902ffbc7289ff9e36a1d62`): 309 s under `./receipts.sh`**
(/bin/bash 3.2.57, 2026-11-07 from 19:00 CET) **and 303 s under `bash receipts.sh`** (Homebrew bash 5.3.9, from 19:06 CET): each exit 0, all 9
captures 3/3 = published, every check passed, each of the three builds `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`
(and `tests`' `offline: yes`, inside its capture), the anchor note empty at the start and the end, nothing listening on 18425, 8080, 35729
or 19950-19959 at the end; each terminal log through `check_unit7.py 16 --runlog` — `0 grep error line(s)`, `RESULT (run logs): PASS` (the
unit gate itself answers "no 16-*.md … nothing to check": no script yet). The builders' `_builders/dur7.py` over this README and the
exercise's two files: 0 duration words. **Nothing was downloaded**, and this unit made no network act. **On the tree as committed** — this README final — one more `./receipts.sh` (`env -i`, a session of its own, from 19:30 CET): exit 0 in 277 s, all 9 = published, `--runlog` PASS.

**Re-run after unit 17 moved the anchor (2026-11-07).** `../c7-unit17`'s commit changed `../c7-tiffinbox` — Section 3's third and last anchor change (`CustomerEntityRepository.java` declares two JPQL queries, `monthRevenue` and `pausedDays`; `CustomerRepository.java` calls them, its SQL strings 2 → 0, `Database` out of its constructor, `@DependsOn("database")`; `CustomerEntity.java`'s Javadoc; its README); `../c7-unit17/after` is Section 3's frozen anchor — so this script's anchor check prints the note at its start and end, never a stop (R.211): `after/` is still this unit's frozen tree, `../c7-unit17/before` its link. `receipts.sh` unchanged (md5 `4416a78a11902ffbc7289ff9e36a1d62`). One run on the moved anchor, `./receipts.sh` (/bin/bash 3.2.57), `env -i`, a session of its own, from 20:04 CET: exit 0 in 288 s (beside `../c7-unit17`'s development run), the note printed at the start and the end, all 9 captures 3/3 = published, `receipts.md5` unchanged, `check_unit7.py 16 --runlog` PASS.

Published hashes: derived `314e79d6305573120462d7a215f3557d` · tx `69d452776a96d0ac8eb279d01a5afccc` · typo `4810ffd6c152c27361c8256d1c5ff3e1` · long `8a18318cfd43dc0e6b4c1216154c99cc` · anchor `6ef1c182d337d13eb6e2593caf2ae3db` · seven `9edbac048a192d06a21a163643eea6d2` · tests `97ff84b0e86aa46dcbb1e2ef8d0454d6` · xcheck `0424b2179863bc8fd7811e5a57dcbd69` · exercise `3495842242b17abf6792f43c63b30c7a`.

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line, R.225 — a number typed
anywhere else is refused):

the values the video may say: the keyword table, 10 calls - 1 statement each, README.md's rows composed from derived · derived finds log 0 transaction lines, the inherited findById 1 · a derived delete without @Transactional: its SELECT, then org.springframework.dao.InvalidDataAccessApiUsageException: No EntityManager with actual transaction available for current thread - cannot reliably process 'remove' call <- jakarta.persistence.TransactionRequiredException: No EntityManager with actual transaction available for current thread - cannot reliably process 'remove' call · with @Transactional: 1 SELECT + 3 DELETEs · findByNmae: the beans customerImport -> customerRepository -> customerEntityRepository (constructor parameters 0 1), the chain org.springframework.beans.factory.UnsatisfiedDependencyException <- org.springframework.beans.factory.UnsatisfiedDependencyException <- org.springframework.beans.factory.BeanCreationException <- org.springframework.data.repository.query.QueryCreationException <- org.springframework.data.core.PropertyReferenceException · the longest method 124 characters, 5 parameters, one SELECT · strings 3 -> 2 · by-name GETs' Hibernate lines before/ 201:1 200:0 404:0, after/ 201:1 200:1 404:1 (status:lines) · POST 201, again 409 · Hibernate SQL lines in the seven's log 4 -> 4 · tests 18 · the seven 466c20ed7e0d5439cb052f32ce09de1b · Boot's DDL f595637014e786fa38606859951e4f97 · the exercise's solution: Sunil Optional[3|Sunil|3|100|VEG]

### The keyword table — composed from `derived`

Each row is one call in `derived`'s harness JVM: the call, the one statement Hibernate's SQL logger printed for it (getPrepareStatementCount
1 beside it, R.184), what it returned. `receipts.sh` composes these rows from the capture and stops unless the rows under the marker below
are exactly they — a SQL string typed here, or a row changed, is refused. **For the deck builder:** the `like` row's SQL ends `escape '\'`
— one backslash inside single quotes, as Hibernate wrote it; a slide string, an HTML attribute or a Python literal must escape it (the
table's `\|` in the first row's result is Markdown's escape of the record's own `|`, not part of it).

<!-- derived: the keyword table, composed by receipts.sh from the capture `derived` - never typed -->
| call | SQL (Hibernate's SQL logger, H2) | returned |
|---|---|---|
| `findByName("Sunil")` | `select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where ce1_0.name=?` | `Optional[3 \| Sunil \| 3 \| 100 \| VEG]` |
| `findByMealTypeAndMealsPerDayGreaterThan(VEG, 1)` | `select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where ce1_0.meal_type=? and ce1_0.meals_per_day>?` | `[Ravi, Sunil]` |
| `findByNameContainingIgnoreCase("r")` | `select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where upper(ce1_0.name) like upper(?) escape '\'` | `[Ravi, Meera, Priya]` |
| `findByMealTypeOrderByMealsPerDayDesc(VEG)` | `select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where ce1_0.meal_type=? order by ce1_0.meals_per_day desc` | `[Sunil, Ravi]` |
| `findFirstByOrderByPricePerMealDesc()` | `select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 order by ce1_0.price_per_meal desc fetch first ? rows only` | `Optional[Meera]` |
| `findTop3ByOrderByNameAsc()` | `select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 order by ce1_0.name fetch first ? rows only` | `[Meera, Priya, Ravi]` |
| `existsByName("Priya")` | `select ce1_0.id from customer ce1_0 where ce1_0.name=? fetch first ? rows only` | `true` |
| `countByMealType(VEG)` | `select count(ce1_0.id) from customer ce1_0 where ce1_0.meal_type=?` | `2` |
| `findByPausesDaysGreaterThan(1)` | `select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 left join pause p1_0 on ce1_0.id=p1_0.customer_id where p1_0.days>?` | `[Sunil, Priya]` |
| `findDistinctByPausesDaysGreaterThan(1)` | `select distinct ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 left join pause p1_0 on ce1_0.id=p1_0.customer_id where p1_0.days>?` | `[Sunil, Priya]` |

### A sealed fresh clone — the recipe (R.129)

**Paste it into bash.** Unit 15's recipe, with this unit's folder:

```bash
S=/tmp/sealed16; W="/tmp/sealed 16"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
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
cd "$W/tiffinbox-java/c7-unit16" && readlink before && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E ./receipts.sh            # a process group of its own
```

**Run (2026-11-07, from 19:22 CET):** a `git clone` of tiffinbox-java at `4507631` into a path **with a space** (`…/sealed 16/tiffinbox-java`,
in the session's scratch folder), this commit's 65 files put in as git takes them (`git ls-files -m` and `-o --exclude-standard`, each
`cmp`-equal to the working tree, `before` → `../c7-unit15/after` by `readlink`); a `file://` copy of the s3 seed (5,023 files once
`_remote.repositories`, `*.lastUpdated` and `resolver-status.properties` are left out); pre-flight: exit 1, 221 `Downloading from sealed:
file://`, 0 from http(s); the clone's `.m2-demo` seeded from that copy; `/bin/bash` 3.2, `env -i` with the dead proxies, a session of its
own: **exit 0 in 288 s, all 9 = published, every check passed**; each build `offline: yes · exit 0 · 'Downloaded from' lines in its log:
0`; after the run `.m2-demo` held 5,023 files, 0 `_remote.repositories`; the builders' `dur7.py` is not beside a clone (the terminal says
so; its md5 is the check). Its terminal log through `--runlog`: PASS. (The clone's README was this file before its last prose was filled
in; this README passes the same gates in the run on the tree as committed.)

## The commands this unit adds

```
javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/src/probe/q/Main.java harness/src/probe/q/Run.java harness/src/probe/q/Seed.java harness/src/probe/q/repo/Derived.java harness/src/probe/q/repo/NoTx.java harness/src/probe/q/repo/WithTx.java
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../after/tiffinbox-web/target/extracted/lib/*" probe.q.Main "${A[@]}"
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.org.hibernate.SQL=debug
```

The harness compiled against `after/`'s extracted jar (91 libraries); **the harness line** (run from `.harness/run`: `V` its JVM flags —
the scenario, `-Ds=derived|tx|long`, `-Dtx.v=A|B`, `-Dtx=DEBUG` — and `A` its arguments, the same six for every harness JVM, R.193, each
printed as `$ V=(…)` / `$ A=(…)`, `A` with `printf %q`); **the anchor's run line with Hibernate's SQL logger on** (`anchor`, `seven`). Every
java line runs under `perl -e 'alarm 240; exec @ARGV'` (R.247: macOS has no `timeout`; an alarm that fires ends the JVM with exit 142,
which the harness runner refuses); the exercise's JVM under its own alarm. The lines read from `after/README.md` (6, each asserted whole)
are unit 09's: `mvn -B package`, `mvn -B clean test`, the run line, the extract line, the GET of `/customers`, and the first-entity
lesson's DDL line (the run line with the two schema-generation options: asserted to be that and nothing else).

## The repository, and the network

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681 files; ⚑8: every Section 3 unit seeds from s3 — 16 needs only s2's
files). Four builds: `before/`'s and `after/`'s `package` (each runs its 18 tests), typo B's `package -DskipTests` (a labelled copy), and
`tests`' `clean test`; each `offline: yes` with 0 `Downloaded from` lines in every run of record (the label is derived from the build log,
never typed). After the builds the script asserts `.m2-demo` holds `spring-boot-starter-parent-4.1.2.pom`, `hibernate-core-7.4.13.Final.jar`,
`spring-data-jpa-4.1.2.jar` and `h2-2.5.250.jar`. **At run time** every request goes to `127.0.0.1`; every database is H2 in a JVM's memory
(the harness's `jdbc:h2:mem:u16`, TiffinBox's `jdbc:h2:mem:tiffinbox`, the exercise's `jdbc:h2:mem:ex`). **No network act**: the section's
dated sweep is the brief's (`../../../data-jpa-hibernate/_research/spring-boot-metadata-2026-11-07.xml`, md5 `2ccae19d…`: the 4.1 line ends
4.1.2, no 4.1.3; `4.2.0-RC2` not GA — ⚑6, R.223). Spring Data JPA's version is printed by every harness JVM from its jar's manifest
(`JpaRepository.class.getPackage().getImplementationVersion()` → `4.1.2`), beside Hibernate's `HHH000001` line and `Version.getVersionString()`
(S3.15, R.246).

## The demo token

TiffinBox's runs (`typo`, `anchor`, `seven`, `xcheck`) start in a copy under `.harness/` holding a config tree with a demo token of 36
characters (`secrets/tiffinbox/shutdown-token`, mode 0600, listed before every start — the token's file and nothing else, R.158); POST
/shutdown sends it from its file on curl's standard input (`harness/shutdown.sh`, `$CURLSET`). Every raw capture run and every log is
counted for it before the mask — 0 every time — and the captures show `[masked: the 36-character token]` where it would be.

## The locale

The JVM ignores `LC_ALL` on macOS: every JVM this script starts carries `-Duser.language=en -Duser.country=US` on its java line, and the
hygiene check refuses a java line without it (and one without its alarm); the test JVM's comes from the POM's `argLine`.

## The folders, the harness and the ports

- `before` → `../c7-unit15/after` (a link; `readlink` asserted); `after/` — this unit's frozen tree (= `../c7-tiffinbox` when committed).
- `harness/` — `src/probe/q/Main.java` (a Spring Boot context, `WebApplicationType.NONE`: it binds no port; `@EntityScan("com.tiffinbox")` —
  the anchor's entities — and `@EnableJpaRepositories("probe.q.repo")`, the harness's own interfaces), `src/probe/q/repo/Derived.java` (the
  derived methods, over TiffinBox's `CustomerEntity`; the path through `pauses` is the shipped mapping's), `NoTx.java` and `WithTx.java`
  (the same derived delete, `long deleteByMealType(MealType)`, the second marked `@Transactional`), `Seed.java` (the shipped `Database`
  built in code on the run's own H2 URL; its `createAndSeed` seeds 1 Ravi VEG, 2 Meera NON_VEG, 3 Sunil VEG, 4 Priya VEGAN and two pauses,
  Sunil's 3 days and Priya's 2), `Run.java` (one scenario per JVM; each call between `PROBE >>> label` and `PROBE <<< label · statements
  (getPrepareStatementCount) …` — Hibernate's Statistics cleared before each call; rows read back by a second connection, `DriverManager`),
  `src/probe/q/ex/ExApp.java` (the exercise's — compiled only by the exercise), `logback.xml` (one line per event, no stack trace — `%nopex`:
  the harness prints an exception's class, message and causes itself, R.241), `shutdown.sh` (the CORS lesson's, byte for byte),
  `surefire.py` (the testing lesson's, byte for byte), `dur7.py` (the builders', byte for byte, md5 `41667fed…`). English names only
  (R.215): Ravi, Meera, Sunil, Priya, Kavya, Asha, Dev, Omar.
- `exercise/` — `README.md`, `SOLUTION.md`.
- `.harness/` (git-ignored, rebuilt by every run): the copies `before`, `after`, `typob`, `tests`; `hc` (the harness's classes); `run` (the
  harness's working folder); the logs. `.r-NAME.1-3` while a capture runs; `.r-NAME.out` its result (git-ignored).
- **Ports (§P, 19950-19959):** anchor 19950 · seven `before/` 19951 · `after/` 19952 · xcheck 19953 · by-name `before/` 19954 · `after/`
  19955 · typo B 19956 · A′ 19957 · 19958 spare (never bound by the script) · 19959 never bound. All ten, and 18425, 8080 and 35729, are
  checked free at the start and the end; a server that listens on 8080, 35729 or 19959 is killed and the run stops. Every TiffinBox listens
  on `127.0.0.1` only (printed). The harness's JVMs, the tests and the exercise bind none.

## Masks, filters and hygiene — every one, declared

Masks (awk `gsub` only, each with a planted self-test line before any capture): the demo token → `[masked: the 36-character token]`;
this folder → `…`, the folder above → `…/..`, home → `~`, the user name → `<user>`; ` using Java <version>`; a generated H2 name
`jdbc:h2:mem:<uuid>`; an identity hash → `@…` (a JDBC connection handle's among them); the JDK proxy class's number → `$Proxy<n>`; an
EntityManager's identity → `SessionImpl(<n><open>)`; Spring Data's scan line's time figure → `<n>`; H2's generated `CONSTRAINT_<n>`,
`CONSTRAINT_INDEX_<n>`; a jar path under this folder (typo's exception names `…/.harness/typob/…`). Filters: a harness JVM's log is
printed whole (trailing spaces dropped); a TiffinBox log, the named loggers' lines (Hibernate's core and SQL loggers, `TiffinBoxServer`,
the EntityManagerFactory's, Spring Data's `RepositoryConfigurationDelegate`, Boot's `SpringApplication` and failure reporter) and, for a
failed start, the exception's line after `Application run failed` and each `Caused by:` line — no stack frame, no `... common frames
omitted` line; `anchor`'s TiffinBox logs without their SQL lines (each request prints its own). Hygiene, over every capture: no absolute
path, unit number (but in a line quoted from the anchor's files), log time, timestamp, thread number, JDK or OS token, random port, figure
of elapsed time, stack frame, unmasked proxy number, identity or generated name, URL other than 127.0.0.1's; every JVM pinned and under its
alarm; no kill by name, no bare `wait`, no one-string multi-option variable; no H2 database file (R.195); no dish name (R.215).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the Maven it
waits for (`$mpid`, with every process under it — Surefire's fork), the exercise's shell (`$xpid`), sweeps its own process group for any
TiffinBox JVM, harness or exercise JVM (`probe.q.`), Maven or Surefire fork left, deletes the capture runs it had not finished
(`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched. No `wait` in the script or the exercise is bare.

**Measured (2026-11-07, the sealed clone, the script as committed):** `./receipts.sh` (/bin/bash 3.2) started in a session of its own
**with SIGINT at its default** (`perl -MPOSIX -e '$SIG{INT}="DEFAULT"; setsid; exec …'` — a background job of a script inherits SIGINT
ignored: unit 15's README, Interrupted), `kill -INT` to its group once the named process was in it, the state read 5 s later — three
trials, each **exit 130, nothing left**:

```
build: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
harness: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
boot: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
```

`build` — the first Maven (`before/`'s package, its Surefire fork); `harness` — the first harness JVM (`derived`); `boot` — TiffinBox itself
(`typo` B, port 19956). `pgrep -fl java` afterwards: none. (A first try of the trial script matched its own command line and stopped
itself; the run it had started was interrupted by hand the same way — 4 processes in the group, 0 after, `.r-lock` gone — and the three
trials above were made with the script fixed to wait for the run's own session.)

## 1 · derived — the parser: one derived method per keyword

One harness JVM; the interface `probe.q.repo.Derived extends JpaRepository<CustomerEntity, Long>`, no query written in it. Spring Data
finds the harness's three interfaces (`Found 3 JPA repository interfaces.`). Each call: one statement — the SQL line between its markers
and `getPrepareStatementCount` both 1 (R.184) — and what it returned; every keyword's mark asserted in the SQL Hibernate logged: `=` for a
bare property; `and … >` (`And`, `GreaterThan`); `upper(ce1_0.name) like upper(?) escape '\'` (`ContainingIgnoreCase` — Spring Data wraps
the value in `%…%` and escapes it, the bound value not printed here); `order by ce1_0.meals_per_day desc` (`OrderBy … Desc`); `fetch first
? rows only` (`First`, `Top3`); `existsByName` → `select ce1_0.id … fetch first ? rows only` — an id and the first row, **not a count**
(asserted: no `count` in it); `countByMealType` → `select count(ce1_0.id) …`; a property path through the collection,
`findByPausesDaysGreaterThan` → **`left join pause p1_0 on ce1_0.id=p1_0.customer_id where p1_0.days>?`** — a left join, as captured;
`Distinct` → `select distinct`. The table above is this capture's rows. The version lines and the `database:` line (H2 2.5.250) once in its
JVM.

## 2 · tx — no transaction of their own (S3.2, R.233; A/B/A′)

Three fresh JVMs, `JpaTransactionManager` at DEBUG, the same prelude in each: the **inherited** `findById(1)` logs `Creating new
transaction with name [org.springframework.data.jpa.repository.support.SimpleJpaRepository.findById]: PROPAGATION_REQUIRED,ISOLATION_DEFAULT,readOnly`;
the **derived** `findByName("Sunil")`, `existsByName("Priya")` and `countByMealType(VEG)` log **no** `JpaTransactionManager` line at all
between their markers (counted: 0 each); then `saveAll(Asha, Dev)` (inherited, both NON_VEG: Meera, Asha, Dev are NON_VEG). **B** —
`NoTx.deleteByMealType(NON_VEG)`, the method without `@Transactional`: its SELECT runs (1 statement, 3 entity loads), then
**`org.springframework.dao.InvalidDataAccessApiUsageException: No EntityManager with actual transaction available for current thread -
cannot reliably process 'remove' call`** ← **`jakarta.persistence.TransactionRequiredException`** with the same message (class, message,
first cause — each asserted, R.241, RED #914); nothing deleted — a second connection still reads all six rows. **A** — `WithTx.deleteByMealType(NON_VEG)`,
the method `@Transactional`: its own transaction (`Creating new transaction with name [….SimpleJpaRepository.deleteByMealType]:
PROPAGATION_REQUIRED,ISOLATION_DEFAULT` — named after the target class, not readOnly), **1 SELECT, then 3 × `delete from customer where
id=?`** — the SQL log and Statistics both 4, entity deletes 3, result 3 — and the DELETEs are logged after `Committing JPA transaction`:
the derived delete loads the rows and removes them one by one, flushed at the commit. **A′** = A, line for line (R.1).

## 3 · typo — a misspelt property, and TiffinBox does not start (the failure receipt; S3.9, S3.10)

TiffinBox itself, two fresh JVMs. **B** (labelled: `after/` copied to `.harness/typob` with `findByName` misspelt `findByNmae` in
`CustomerEntityRepository.java` and in `CustomerRepository`'s one call — asserted the only two lines that differ — built with the
README's package line and `-DskipTests`; 19956): it ends by itself, exit 1, never listened, readiness never answered; `Found 1 JPA
repository interface.`; the log's order — `Initialized JPA EntityManagerFactory`, then the context's refusal (`Exception encountered during
context initialization`), then `Application run failed` — a start failure, not a call failure (S3.9). The exception, read off the log: its
top line `org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'customerImport' …`, the chain of
beans and constructor parameters read off it (the values line), ending `No property 'nmae' found for type 'CustomerEntity'; Did you mean
'name'`; its causes, each `Caused by:` line kept whole, the last two `org.springframework.data.repository.query.QueryCreationException:
Cannot create query for method [CustomerEntityRepository.findByNmae(java.lang.String)]; …` ← **`org.springframework.data.core.PropertyReferenceException:
No property 'nmae' found for type 'CustomerEntity'; Did you mean 'name'`** — the class with its package as Spring Data JPA 4.1.2 throws it
(S3.10; the 3.x attribution is not made, RED #931). **A′** (`after/`'s jar, `findByName`; 19957): `Found 1`, started, stopped by POST
/shutdown.

## 4 · long — where names stop being readable

One harness JVM. The longest method measured, its name read off `Derived` by reflection, its length counted three ways — `String.length()`
in the JVM, `${#name}` and `printf %s "$name" | wc -c` in this script — and asserted equal (the number is the values line's, R.225); its
five parameters; its **one SELECT**: `… where ce1_0.meal_type in (?,?) and ce1_0.meals_per_day between ? and ? and ce1_0.price_per_meal<=?
and upper(ce1_0.name) like upper(?) escape '\' order by ce1_0.price_per_meal desc,ce1_0.name` → `[Priya]`. *@Query: JPQL and Native SQL*
(17) is the way out, named forward by title only.

## 5 · anchor — the change, the count, the sentences; TiffinBox over HTTP: the guard and the witness

The file list (diff -rq), each changed file's diff, the interface's code lines; **`grep -c prepareStatement`** over `before/`'s and
`after/`'s `CustomerRepository.java`: **3 → 2** (R.187, a named command); the sentences that state the count (S3.19, each read whole:
`CustomerEntity.java`'s, `CustomerRepository.java`'s, the anchor README's unit 16 section's — each says two). Then three TiffinBox JVMs,
each with Hibernate's SQL logger on, each request's status, body and the log lines it added: **the guard** (`after/`, 19950): POST Kavya →
201 (one Hibernate INSERT), again → 409 (`a customer named Kavya already exists`; two WARN lines from `org.hibernate.orm.jdbc.error`,
`HHH000247: ErrorCode: 23505, SQLState: 23505` and H2's message; no ERROR) — the unwrapped `SQLException` path holds. **The witness**
(R.194, RED #917/#932): `before/` (19954) and `after/` (19955), each Kavya added, then `GET /customers/Kavya` → 200 and a stranger
(`/customers/Omar`) → 404 — on `before/` **0 Hibernate lines** for each GET (the JDBC string answered), on `after/` **one each, `select
ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where ce1_0.name=?`**, twice in all.

## 6 · seven — a guard (R.190)

`before/`'s jar (19951) and `after/`'s (19952), each a fresh JVM with Hibernate's SQL logger on: the seven
**`466c20ed7e0d5439cb052f32ce09de1b`** on both, 0 lines differ; the SQL logger's lines the same on both (the values line) — the seven has
no by-name route (`../c5-unit11/curlset.sh`), so nothing in it can tell the two trees apart (RED #917). `Found 1` both.

## 7 · tests — TiffinBox's tests (C7-4)

`after/` copied, `mvn -o -B … clean test`: **18** (14/3/1) from Surefire's reports, the console's summary the same; in the tests' log
`Found 1 JPA repository interface.` twice (the two contexts that build the data layer) — a guard (R.190).

## 8 · xcheck — Boot's DDL script, against the owning-side lesson's (R.212)

`after/`'s jar with the anchor README's DDL line (19953): the script's md5 **`f595637014e786fa38606859951e4f97`** = unit 09's published
script md5 (its README names it; its `xcheck` capture `9072c6f1…`) — the change moved no mapping.

## 9 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s block, then `SOLUTION.md`'s, read from the files, in ONE `env -i` shell — `/bin/bash --noprofile --norc`, then the
same in `/bin/zsh -f`: the README's app (`ExApp`, in `probe.q.ex`, `@EntityScan("com.tiffinbox")`, the shipped `Database` on its own H2, a
repository of its own in the same file — `Customers`, with `findByNmae(String)` — and a runner that asks it for Sunil) → `the JVM: exit
1`, `Found 1 JPA repository interface.`, `PROBE threw: …UnsatisfiedDependencyException: Error creating bean with name 'kitchen' … Error
creating bean with name 'customers' … No property 'nmae' found for type 'CustomerEntity'; Did you mean 'name'`, its causes ending
`…QueryCreationException` ← `org.springframework.data.core.PropertyReferenceException`; the solution (one line: the copy's `findByNmae`
made `findByName`) → `exit 0`, `Found 1`, `PROBE Sunil: Optional[3|Sunil|3|100|VEG]`. Bash and zsh print the same; the shell ends in this
folder.

## Exercise

**Your turn:** the README's repository has a method the application cannot start with. Read the error, and fix the method's name.
(21 words, `wc -w`, R.203.) `exercise/README.md` and `exercise/SOLUTION.md`.

## The anchor's README — what this unit changed in it

- **A new section**, `## Course 7 · unit 16 — derived query methods: …`, after unit 15's: the three changed files, the typo's refusal,
  the count two of five, what changes and what does not (the seven and the 18 tests guards, the SQL logger's lines during the seven the
  same; the by-name GETs' SELECT — none before, one each after; Kavya's 201/409; `Database` unchanged).
- **The header** — two notes starting *Course 7, unit 16*: the strings note (`CustomerRepository` keeps two) and the Section 3 note (the
  interface declares `findByName`).
- **In place**, each a note that starts *Course 7, unit 16*: unit 03's "which keeps its SQL strings" (two of the five since), unit 03's
  "Two ways into one database" (`findByName` through Hibernate since), and unit 15's section — its "`findByName`, `monthRevenue`,
  `pausedDays` keep theirs" and its "`GET /customers/{name}` is still `CustomerRepository`'s own string".

## The shipped receipts on the moved anchor (R.211)

`../c7-unit15/receipts.sh` (unchanged, md5 `edbbf87e…`) run once on the moved anchor, `./receipts.sh` (/bin/bash 3.2.57), `env -i`, a
session of its own, 2026-11-07 from 18:53 CET: **exit 0 in 349 s** (beside this unit's development run), the note `(after/ and
../c7-tiffinbox differ - the anchor has moved past the tree this unit froze: Files after/README.md and ../c7-tiffinbox/README.md
differ;Files after/tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntity.java and …)` at its start and end, all 9 captures 3/3 =
published, `receipts.md5` unchanged, `check_unit7.py 15 --runlog` PASS; its README gains one dated paragraph saying so.

`../c7-unit14/receipts.sh` (unchanged, md5 `fbf41b61…`) run once on the moved anchor the same way, from 18:59 CET: **exit 0 in 161 s**,
its anchor check's note (`anchor/ and ../c7-tiffinbox differ …`) at its start and end, all 7 captures 3/3 = published, its own container
(`c7-u14-pg`, 127.0.0.1:19938, its design) started and removed, `receipts.md5` unchanged, `check_unit7.py 14 --runlog` PASS; its README
gains one dated paragraph.

The other units were not re-run (the brief's order). **The builders** (R.211): `grep -n c7-tiffinbox` over `_builders/*.py`,
`check_unit7.py`, `qa_java7.py` — the four pinned asserts (`s703:44`, `s706:49`, `s707:53`, `s709:53`, each `git show <hash>:c7-tiffinbox/<p>`),
the two tools 0 lines. A scratch copy of `_builders/` (a copy never writes into the course, R.202) ran `s709.py` after the anchor moved,
with the venv's python: exit 0, its two `note: c7-tiffinbox's … has moved on since 9853dae` lines (`CustomerEntity.java`, `README.md`), and
the script, slides and prompter it wrote byte for byte the shipped `09-onetomany-manytoone-and-the-owning-side` files.

## The ledger rows and hand-offs this unit pays

- **C7-4 — re-run**: 18, unchanged (`tests`), a guard (R.190).
- **CARRIED "U15 retires `CustomerRepository`'s strings" — continued**: 3 of 5 (`findAll`, `add`, `findByName`); 17 takes the two sums
  (2 → 0) and `@DependsOn("database")` (READ FIRST 1).
- **Unit 15's CARRIED "a declared query method's transaction (none)"** — measured here (`tx`): 0 lines for the derived finds; a derived
  delete without one refused, with one 1 SELECT + 3 DELETEs.
- Hand-offs by title: *@Query: JPQL and Native* (17) — `long`'s way out; *Bulk Updates and the Stale Context* (22) — a delete that is
  one statement, beside `tx` A's one by one.

## RE-MEASURE — the brief's items this unit settles

| # | Settled here |
|---|---|
| 1 | the exercise as README + SOLUTION files, bash and zsh, `env -i`: the chain, exit 1 / `Optional[3\|Sunil\|3\|100\|VEG]`, exit 0 |
| 2 | C2 on the frozen tree: the by-name SQL witness (before/ 0 lines, after/ one `… where ce1_0.name=?` per GET), the seven `466c20ed…`, 18, 200/404 |
| 4 | the anchor change C2 (`15/after` → `16/after`) with its comments, Javadoc and README: strings 3 → 2, `CustomerEntity.java:23-24` stating two |

## What differed from the brief

1. **The longest method's length is not the brief's.** The brief (and [S3 §2]) give it a length four short of what `long` counts:
   the same name — `findByMealTypeInAndMealsPerDayBetweenAndPricePerMealLessThanEqualAndNameStartingWithIgnoreCaseOrderByPricePerMealDescNameAsc`,
   the probe's, letter for letter — counted here by `String.length()`, `${#name}` and `wc -c` alike, the number in the values line. The
   prose states the length nowhere else (the typed-length gate refuses a number before "characters"), so the plant "a typed 120" is
   refused by that gate, and so would be a typed copy of the right number.
2. **`typo` has B and A′, no A.** The brief names "A′ = `findByName`, ready"; `after/`'s jar itself is that run (19957), and the
   anchor's own start is also `anchor`'s and `seven`'s. B is a labelled copy whose **two** lines differ from `after/` — the interface's
   method and `CustomerRepository`'s call to it (a copy with the interface's line alone does not compile) — asserted the only difference.
3. **The witness runs on two JVMs of its own, and the 409 guard on a third.** The brief's ports name 19950 `anchor`, 19954/19955 the
   by-name runs: 19950 carries Kavya's POST 201/409 (the guard), 19954 (`before/`) and 19955 (`after/`) each add Kavya and then GET her
   and a stranger with the SQL logger on. The witness is each request's own log lines (counted after the log stops growing, polled), as
   unit 15's `anchor`.
4. **The exercise's sentence says "the application", not "TiffinBox"** (21 words, the brief's 20 with one word changed and one added):
   the exercise is a harness application over TiffinBox's core jar — `ExApp`, with a repository of its own in the same file — as unit
   15's was (its What differed 6); TiffinBox's own refusal is `typo` B. Its broken half prints the chain itself (`ExApp.main` catches
   the start's exception and prints its class, message and each cause, one line each — Logback's `%nopex` prints no stack), because the
   harness's Logback shows only the context's one-line refusal.
5. **The exercise's `QueryCreationException` message is shorter than TiffinBox's.** In TiffinBox's log the cause reads `Cannot create
   query for method [CustomerEntityRepository.findByNmae(java.lang.String)]; No property 'nmae' …` (the log prints each `Caused by:` with
   the exception's `toString()`); `ExApp` prints `getMessage()`, which is `No property 'nmae' …` alone. Both captured; each check asserts
   its own form.
6. **`tx` B's and A's interfaces are two**, `NoTx` and `WithTx`, the same method `long deleteByMealType(MealType)` — one marked
   `@Transactional` — so B and A differ by the annotation alone (the probe's A was a differently named `removeByMealType`). The three rows
   come from Meera (seeded NON_VEG) and Asha and Dev (saved NON_VEG by an inherited `saveAll` in each JVM).
7. **A's transaction is named after the target class**: `[org.springframework.data.jpa.repository.support.SimpleJpaRepository.deleteByMealType]`,
   not the interface — as the inherited methods'.
8. **CustomerEntityRepository's unit 15 sentence was rewritten in place** — "Every method CustomerRepository calls on it … is inherited
   from JpaRepository; none is declared here" became false with `findByName`; it now says `findAll(Sort)` and `save` are inherited and that
   unit 16 declares `findByName`. The brief's change list for 16 does not name `CustomerEntity.java`; S3.19 (R.250) needs its lines 23-24
   to state the new count, so it is changed too.
9. **The harness's `@EnableJpaRepositories` names `probe.q.repo` only**: the derived methods are the harness's own interface's, over
   TiffinBox's `CustomerEntity`; TiffinBox's own `findByName` is measured on TiffinBox (`anchor`, `typo`).
10. **`findByNameContainingIgnoreCase("r")`** — the probe passed `"R"`; the result is the same three, the SQL the same (`upper(…) like upper(?)`).
11. **The plants ran on a scratch mirror with only the planted capture kept** (as unit 15's What differed 9) — each still exits 1 at its own
    check; a gate plant needs no capture at all.
12. **Ports:** as the brief's (19950-19957 bound; 19958 spare and 19959 never bound — both checked free at the start and the end).

## Planted faults — each caught (R.65)

Each on a scratch mirror of this folder (its neighbours linked: `../c7-unit15`, `../c7-unit09`, `../c5-unit11`, `../c6-unit19`,
`../c6-unit28`, `../c7-tiffinbox`), one fault at a time, the mirror's `receipts.sh` keeping only the planted fault's capture (What differed
11), `env -i`; each **exit 1, nothing written to this folder**, no JVM of the mirror left and nothing listening on 19950-19959 after it.
The line that stopped each:

| plant | where | caught by |
|---|---|---|
| `findByName` in `typo` B (the copy's two seds replaced by a plain copy, its difference check with them) | `receipts.sh` | B became ready and was stopped; the trio check: `typo B: the trio … expected the line: it ended by itself: exit 1 · listening on 19956: 0 · readiness never answered 200` |
| C2 not applied — `before/`'s built jar put in `after/`'s place (`seven` run first, then `anchor`) | `receipts.sh` | `seven md5 9edbac04… 3/3 = published` — **the guard passed: it cannot tell** (R.190); then the witness: `anchor: after/ - POST 201, GET /customers/Kavya 200 and a stranger 404, one Hibernate line each - the derived findByName: 201:1 200:0 404:0` |
| `@Transactional` added to `tx` B's method (`NoTx.deleteByMealType`) | `harness/src` | `tx B: 1 statements - the SQL log's lines (4) and getPrepareStatementCount() (4) both (R.184)` — B deleted the rows |
| the 3.x class name, `org.springframework.data.mapping.` + `PropertyReferenceException`, in a SAY line | `README.md` | S3.10's refusal: `a line names the exception by the package it does not have on Spring Data JPA 4.1.2 …` |
| a typed length in a SAY line (the notes' number, 120, then the word for its unit) | `README.md` | `a typed length - the longest method's length is counted by long, stated only in the values line (R.225)` |
| a typed SQL string in the keyword table (`countByMealType`'s row: `count(*)` for `count(ce1_0.id)`) | `README.md` | `README.md's keyword table is not derived's - each row is composed from the capture …` (the two rows printed) |
| a wrong published hash (`derived`'s last digit) | `receipts.md5` | `derived md5 314e79d6… 3/3 DIFFERS from the published …e` |
| no `HHH000001` (`org.hibernate.orm.core` at WARN) | `harness/logback.xml` | `derived: the version lines - getVersionString(), Hibernate's HHH000001 and Spring Data JPA's 4.1.2 - once in each of its 1 harness JVMs (R.222, S3.15/R.246)` |
| no Spring Data version line (`Run.java`'s line removed) | `harness/src` | `long: the version lines …` (the same check, S3.15) |
| an Indian dish name | `README.md` | `an Indian dish name (R.215: English names only)` |
| a duration word | `README.md` | `dur7.DUR found a duration word - this unit speaks no time (R.172)` |
| long: the JVM's length off by four | `harness/src` | `long: the name's length counted three ways - String.length() 120, ${#name} and wc -c (124 124) - must agree with the name printed (124)` |
| seven: `after/`'s seven run without the SQL logger | `receipts.sh` | `seven: the seven has no by-name route - the SQL logger's lines are the same on both trees (4 2 / 0 0)` |
| tests: `FeedTest.java` deleted | `after/` | `tests: expected the line: TEST-com.tiffinbox.web.FeedTest.xml: tests 1 …` |
| xcheck: a wrong unit 09 md5 | `receipts.sh` | `xcheck: ../c7-unit09/README.md must name f595…4e90, and its receipts.md5 its xcheck 9072c6f1… (R.212)` |
| exercise: the solution's sed matches nothing (`findByNmae` for `findByNmae`) | `exercise/SOLUTION.md` | `exercise: the solution - Found 1, the derived findByName answers: expected the line: the JVM: exit 0` |
| `CustomerEntity.java:23-24` left as unit 15 shipped it ("keeps three of its five … since Course 7 unit 15") | `after/` | `CustomerEntity.java:23-24 must state the count grep gives - keeps two of its five SQL strings (S3.19, R.250)` (before any build) |

## Found on the way

- **A field separator inside a result.** The first draft of the derived check split each expected row on `|` — and `findByName`'s result,
  `Optional[3 | Sunil | 3 | 100 | VEG]`, holds four; the check now splits on `^`, and the README's table escapes the record's `|` as `\|`.
- **A local variable named `G`** in the anchor check hid the script's grep (`G=/usr/bin/grep`): the first run stopped on `secrets/: No such
  file or directory`; renamed.
- **The longest name's length** (What differed 1): counted, not copied from the notes; it differs from them.
- **Spring Data finds a package-private interface** in the application's own package (`Customers`, top level in `ExApp.java`, not
  nested — a nested interface is found only with `considerNestedRepositories`): measured by the exercise's `Found 1`.
- **The derived delete's DELETEs come at the commit**: `tx` A logs the SELECT, then `Committing JPA transaction`, then the three DELETEs
  (the flush), then the EntityManager's close — the order the capture shows.

## CARRIED

- **`CustomerRepository`'s other two strings** (`monthRevenue`, `pausedDays`) → 17 (2 → 0, `@DependsOn("database")`).
- **The two connection paths** (Hibernate through Boot's pool for `findAll`/`add`/`findByName`; `DriverManager` for the two sums and
  `Database`'s seed) → ⚑12: settled by 17; `Database`'s seed → U36 (Flyway).
- **A derived delete's one-by-one DELETEs** (`tx` A) beside a bulk delete's one statement → *Bulk Updates and the Stale Context* (22).
- **`ContainingIgnoreCase`'s bound value** (`%r%`, escaped) — the SQL shows `upper(?)`, the binding is not printed (TRACE not on here);
  not said.
- **H2's two WARN lines on a duplicate** — said where a slide shows the log (unit 15's, measured again here).

## For RED

- **The witness can fail; the guards cannot** (R.190): the plant that puts `before/`'s jar in `after/`'s place passes the seven's hash and
  its SQL-line counts (both the same on both trees) and is stopped by the by-name witness (Planted faults). Ask whether one SELECT per GET
  is the only line the derived `findByName` adds in TiffinBox (the request's whole window is counted: 1 each).
- **The longest name's length** (What differed 1): ask whether any script or brief line still states the notes' number.
- **`typo`'s chain** is read off TiffinBox's own log (`Caused by:` lines), the bean names and parameter indexes off its top line (R.199);
  ask whether the top line's three nested messages are enough to say "TiffinBox does not start because of one method name" — the root
  cause is the interface's bean, `customerImport` only the first bean that needed it.
- **`tx`'s "no transaction"** is the absence of any `JpaTransactionManager` line between a derived find's markers (counted 0), with the
  inherited `findById`'s line beside it (1). Ask whether a caller's transaction (none here) changes the claim — it would make the derived
  finds participate; the voice may only say "a declared query method has no transaction of its own".
- **The S3.2 refusal regex** is unit 15's, unchanged; try a wording it lets through.
- **The exercise is a harness app** (What differed 4): ask whether the spoken line fits.
- **`existsBy` "not a count"** rests on the SQL text (`select ce1_0.id … fetch first ? rows only`, no `count`) — asserted; Hibernate 7.4.13
  and Spring Data JPA 4.1.2 printed beside it (S3.15).
