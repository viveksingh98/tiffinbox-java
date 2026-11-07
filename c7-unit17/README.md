# c7-unit17 — @Query: JPQL and Native

Course 7 · Data with JPA & Hibernate · Section 3 (Querying), its third unit, and **the course's seventh change to the anchor — Section
3's third and last** (brief ⚑1, C3): **`after/` is Section 3's frozen anchor.** Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring
Boot 4.1.2** (Spring Data JPA 4.1.2, Hibernate ORM 7.4.13.Final, Jakarta Persistence 3.2.0, H2 2.5.250 — the anchor's pin — HikariCP
7.0.2), 2026-11-07, **on H2 only** (brief ⚑2: 17 is an H2 unit; every capture says so in its own lines). When a method's name cannot
say the query, the query is written by hand in `@Query`: in **JPQL** — the query language of entities and their fields, which
Hibernate turns into SQL and checks against the entities at start — or as **native SQL**, the database's own language, which is sent
as written. Measured: named parameters with and without `@Param` on a build compiled with `-parameters` and on one without; a
constructor expression that puts the answer straight into a record (two columns, no entity loaded); native SQL logged as declared,
a native page with and without its `countQuery`, and a `Sort` appended to it; a misspelt field stopping the start; and TiffinBox's own
two sums, the last of its five SQL strings to leave — with the start order `Database` gave, kept by `@DependsOn("database")`.

**The anchor changes (brief ⚑1, C3).** `after/` is this unit's frozen copy of `../c7-tiffinbox` after the change; `before` is the link to
`../c7-unit16/after`, the anchor after Section 3's second change. `receipts.sh` prints `diff -rq -x .m2-demo -x target -x secrets -x
.harness after ../c7-tiffinbox` at its start and end — empty in every run of record — and, from any later anchor change on, prints a
note instead (R.211). Every tree is copied under `.harness/` and built there, never in place. What changed (`anchor` prints the file
list and each file's diff):

- `tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntityRepository.java` — two queries of its own, written in JPQL:
  `@Query("select coalesce(sum(c.mealsPerDay * c.pricePerMeal * 30), 0) from CustomerEntity c") long monthRevenue();` and
  `@Query("select coalesce(sum(p.days), 0) from PauseEntity p") long pausedDays();`; its Javadoc gains a unit 17 paragraph.
- `tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java` — `monthRevenue` and `pausedDays` return
  `Math.toIntExact(customers.monthRevenue())` and `…pausedDays()`; their signatures (`int`, `throws SQLException`) unchanged, so
  `Dashboard`, `TiffinBoxServer`'s routes and the tests' mocks are; its SQL strings **2 → 0** (`grep -c prepareStatement`, printed by
  `anchor`); **`Database` leaves its constructor** — the class takes `CustomerEntityRepository` alone — and **`@DependsOn("database")`**
  sits on the class; its Javadoc.
- `tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntity.java` — lines 23-24 of its Javadoc, the sentence about the SQL strings, now
  state the count: "CustomerRepository keeps none of its five SQL strings since Course 7 unit 17" (S3.19, R.250 — checked before any
  build: unit 16's sentence refused anywhere in `after/`'s sources, every sentence about the SQL strings in them and in its README's unit
  17 section stating none).
- `README.md` — the anchor's: its unit 17 section, the header's two notes (the strings, and **Section 3's frozen anchor**), and in-place
  notes on every line that stated a `DriverManager` path of `CustomerRepository`'s, or its count of strings, in the present tense
  (unit 03's "keeps its SQL strings" and "Two ways into one database", unit 06's Postgres paragraph, unit 15's section — its count and
  its "`Database` … still a constructor argument" — and unit 16's section, the same two).
- **Kept, unchanged** (R.180): `Database` (both tables, the seed, its `DriverManager` — the one such path left, ⚑12; its Javadoc names no
  reader, so it is not touched); `TiffinBoxServer` (its `start()` and the Javadoc `anchor` quotes); `TiffinBoxApp`; the core POM;
  `application.yaml`; the 18 tests; the web layer (it reads the record `Customer`).

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
md5s are `receipts.md5`. **The runs of record, on the script as committed (`receipts.sh` md5 `a24fdfdb550ef69eb12b395995853190`): 360 s under `./receipts.sh`**
(/bin/bash 3.2.57, 2026-11-07 from 20:13 CET) **and 560 s under `bash receipts.sh`** (Homebrew bash 5.3.9, from 20:19 CET, beside unit
14's re-run): each exit 0, all 9 captures 3/3 = published, every check passed, each of the five builds `offline: yes · exit 0 · 'Downloaded
from' lines in its log: 0` (and `tests`' `offline: yes`, inside its capture), the anchor note empty at the start and the end, nothing
listening on 18425, 8080, 35729 or 19960-19969 at the end; each terminal log through `check_unit7.py 17 --runlog` — `0 grep error
line(s)`, `RESULT (run logs): PASS` (the unit gate itself answers "no 17-*.md … nothing to check": no script yet). The builders'
`_builders/dur7.py` over this README and the exercise's two files: 0 duration words. **Nothing was downloaded**, and this unit made no
network act. **On the tree as committed** — this README final — one more `./receipts.sh` (`env -i`, a session of its own, from 20:51 CET): exit 0 in 304 s, all 9 = published, `--runlog` PASS.

Published hashes: jpql `28d4cbdfcbf6c3baa2a2be7d43a2726a` · record `0b60c4eb58025804bc9f0e419cb2eab1` · native `bf78efd15f039c7b34b85ea56222f5a1` · typo `d6c7ab37af09d71a900cf334de363d31` · anchor `ddafdc00da1efce581cd66761d19f0ca` · seven `93eb96b5eb51729b202d4a601582061a` · tests `4389ffaa83d60db1b69939bc2e4caf38` · xcheck `42650092415e946ee33863da44d2225f` · exercise `c6ac98e40fb8c3b64bef5146731a47fe`.

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line, R.225 — a number typed
anywhere else is refused):

the values the video may say: the query table, 7 calls, README.md's rows composed from jpql, record and native · without @Param on a build without -parameters, at the call: org.springframework.dao.InvalidDataAccessApiUsageException: For queries with named parameters you need to provide names for method parameters; Use @Param for query method parameters, or when on Java 8+ use the javac flag -parameters <- java.lang.IllegalStateException: For queries with named parameters you need to provide names for method parameters; Use @Param for query method parameters, or when on Java 8+ use the javac flag -parameters · MethodParameters - the anchor's classes CustomerEntityRepository 1 CustomerRepository 4, the harness built with -parameters 2, without 0 · the record: 2 columns, entity loads 0, 4 records (the entity: 5 columns, 4 loads) · a native page with no countQuery: select count(1) FROM customer WHERE meals_per_day >= ? · c.nmae at start: the chain org.springframework.beans.factory.BeanCreationException <- org.springframework.data.repository.query.QueryCreationException <- java.lang.IllegalArgumentException <- org.hibernate.query.sqm.UnknownPathException <- org.hibernate.query.sqm.PathElementException, Could not resolve attribute 'nmae' of 'com.tiffinbox.CustomerEntity' · strings 2 -> 0 · the jar's CustomerRepository before/ (Database, CustomerEntityRepository), prepareStatement 1, @DependsOn 0, after/ (CustomerEntityRepository), prepareStatement 0, @DependsOn value=["database"] · B without @DependsOn: org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'tiffinBoxServer': Invocation of init method failed <- org.springframework.dao.InvalidDataAccessResourceUsageException <- org.hibernate.exception.SQLGrammarException <- org.h2.jdbc.JdbcSQLSyntaxErrorException: Table "CUSTOMER" not found (this database is empty) · POST 201, again 409 · Hibernate SQL lines in the seven's log 4 -> 7, during the seven 2 -> 5, the two sums' SELECTs during it 0 -> 2 · tests 18, the real CustomerRepository in FeedTest (1 test; TiffinBoxWebTest and FullStackTest mock CustomerRepository) · the seven 466c20ed7e0d5439cb052f32ce09de1b · Boot's DDL f595637014e786fa38606859951e4f97 · the exercise's solution: VEG customers [Ravi, Sunil]

### The query table — composed from `jpql`, `record` and `native`

Each row is one call in a harness JVM: the call; its query as its method's `@Query` declares it — read off the class by reflection in
the JVM, never typed; the statement or statements Hibernate's SQL logger printed for it (getPrepareStatementCount beside them, R.184);
what it returned. `receipts.sh` composes these rows from the captures and stops unless the rows under the marker below are exactly they —
a SQL string typed here, or a row changed, is refused. **For the deck builder:** the record row's result holds no `|`; the native rows'
SQL keeps its capitals — Hibernate sent the text as written, `:type` and `:min` as `?`.

<!-- queries: the query table, composed by receipts.sh from the captures jpql, record and native - never typed -->
| call | the query, as its @Query declares it | SQL (Hibernate's SQL logger, H2) | returned |
|---|---|---|---|
| `withParam(VEG, 2)` | `select c from CustomerEntity c where c.mealType = :type and c.mealsPerDay >= :min order by c.name` | `select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where ce1_0.meal_type=? and ce1_0.meals_per_day>=? order by ce1_0.name` | `[Ravi, Sunil]` |
| `bills()` | `select new probe.q.repo.Bill(c.name, c.mealsPerDay * c.pricePerMeal * 30) from CustomerEntity c order by c.name` | `select ce1_0.name,((ce1_0.meals_per_day*ce1_0.price_per_meal)*30) from customer ce1_0 order by ce1_0.name` | `[Bill[name=Meera, bill=4500], Bill[name=Priya, bill=3600], Bill[name=Ravi, bill=7200], Bill[name=Sunil, bill=9000]]` |
| `everyone()` | `select c from CustomerEntity c order by c.name` | `select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 order by ce1_0.name` | `[Meera, Priya, Ravi, Sunil]` |
| `byType("VEG")` | `SELECT name, meals_per_day FROM customer WHERE meal_type = :type ORDER BY name` | `SELECT name, meals_per_day FROM customer WHERE meal_type = ? ORDER BY name` | `[[Ravi, 2], [Sunil, 3]] · each row a Object[] of 2` |
| `pageNoCount(1, PageRequest.of(0, 2))` | `SELECT * FROM customer WHERE meals_per_day >= :min` | `SELECT * FROM customer WHERE meals_per_day >= ? fetch first ? rows only` then `select count(1) FROM customer WHERE meals_per_day >= ?` | `total 4 · pages 2 · rows on page 0: 2 (no order by: the rows themselves not printed, S3.7)` |
| `pageWithCount(1, PageRequest.of(0, 2))` | `SELECT * FROM customer WHERE meals_per_day >= :min · countQuery SELECT count(*) FROM customer WHERE meals_per_day >= :min` | `SELECT * FROM customer WHERE meals_per_day >= ? fetch first ? rows only` then `SELECT count(*) FROM customer WHERE meals_per_day >= ?` | `total 4 · pages 2 · rows on page 0: 2 (no order by: the rows themselves not printed, S3.7)` |
| `pageNoCount(1, PageRequest.of(0, 2, Sort.by("name")))` | `SELECT * FROM customer WHERE meals_per_day >= :min` | `SELECT * FROM customer WHERE meals_per_day >= ? order by name asc fetch first ? rows only` then `select count(1) FROM customer WHERE meals_per_day >= ?` | `total 4 · pages 2 · rows on page 0: 2 · [Meera, Priya]` |

### A sealed fresh clone — the recipe (R.129)

**Paste it into bash.** Unit 16's recipe, with this unit's folder:

```bash
S=/tmp/sealed17; W="/tmp/sealed 17"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
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
cd "$W/tiffinbox-java/c7-unit17" && readlink before && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E ./receipts.sh            # a process group of its own
```

**Run (2026-11-07, from 20:30 CET):** a `git clone` of tiffinbox-java at `4123c0d` into a path **with a space** (`…/sealed 17/tiffinbox-java`,
in the session's scratch folder), this commit's change put in as git takes it (66 files by `git ls-files -m` and `-o --exclude-standard`
at that moment — `c7-unit17/` and `c7-tiffinbox/` — each `cmp`-equal to the working tree, `before` → `../c7-unit16/after` by `readlink`);
a `file://` copy of the s3 seed (5,023 files once `_remote.repositories`, `*.lastUpdated` and `resolver-status.properties` are left out);
pre-flight: exit 1, 221 `Downloading from sealed: file://`, 0 from http(s); the clone's `.m2-demo` seeded from that copy; `/bin/bash` 3.2,
`env -i` with the dead proxies, a session of its own: **exit 0 in 382 s, all 9 = published, every check passed**; each build `offline: yes ·
exit 0 · 'Downloaded from' lines in its log: 0`; after the run `.m2-demo` held 5,023 files, 0 `_remote.repositories`; the builders'
`dur7.py` is not beside a clone (the terminal says so; its md5 is the check). Its terminal log through `--runlog`: PASS. (The clone's
README was this file before its last prose was filled in; this README passes the same gates in the run on the tree as committed. The two
READMEs of units 16 and 14 joined the commit after the clone was made: they are not read by this script.)

## The commands this unit adds

```
javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/src/probe/q/Main.java harness/src/probe/q/Run.java harness/src/probe/q/Seed.java harness/src/probe/q/Typos.java harness/src/probe/q/bad/BadJpql.java harness/src/probe/q/good/GoodJpql.java harness/src/probe/q/repo/Bill.java harness/src/probe/q/repo/Jpql.java harness/src/probe/q/repo/Native.java
javac -d .harness/hc-nop -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/src/probe/q/Main.java harness/src/probe/q/Run.java harness/src/probe/q/Seed.java harness/src/probe/q/Typos.java harness/src/probe/q/bad/BadJpql.java harness/src/probe/q/good/GoodJpql.java harness/src/probe/q/repo/Bill.java harness/src/probe/q/repo/Jpql.java harness/src/probe/q/repo/Native.java
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../after/tiffinbox-web/target/extracted/lib/*" probe.q.Main "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc-nop:../after/tiffinbox-web/target/extracted/lib/*" probe.q.Main "${A[@]}"
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.org.hibernate.SQL=debug
```

The harness compiled twice against `after/`'s extracted jar (91 libraries) — **with `-parameters`** into `.harness/hc` (as Boot's parent
POM compiles TiffinBox: `<parameters>true</parameters>`, read off `spring-boot-starter-parent-4.1.2.pom` by `jpql`) and **without it**
into `.harness/hc-nop` (plain `javac`: the class file keeps no parameter names); **the harness line** for each build (run from
`.harness/run`: `V` its JVM flags — the scenario, `-Ds=jpql|record|native|typo`, and `-Dq=bad|good` for `typo` — and `A` its arguments,
the same six for every harness JVM, R.193, each printed as `$ V=(…)` / `$ A=(…)`, `A` with `printf %q`); **the anchor's run line with
Hibernate's SQL logger on** (`anchor`'s POSTs, `seven`). Every java line runs under `perl -e 'alarm 240; exec @ARGV'` (R.247: macOS has no
`timeout`; an alarm that fires ends the JVM with exit 142, which the harness runner refuses); the exercise's JVM under its own alarm.
The lines read from `after/README.md` (6, each asserted whole) are unit 09's: `mvn -B package`, `mvn -B clean test`, the run line, the
extract line, the GET of `/customers`, and the first-entity lesson's DDL line (the run line with the two schema-generation options:
asserted to be that and nothing else). `javap -v -p` (the JDK's, printed as it runs) reads `MethodParameters` and `CustomerRepository`'s
compiled constructor, annotations and constant pool.

## The repository, and the network

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681 files; ⚑8: every Section 3 unit seeds from s3 — 17 needs only s2's
files). Six builds: `before/`'s and `after/`'s `package` (each runs its 18 tests), anchor B's, B′'s and A′'s `package -DskipTests` (labelled
copies), and `tests`' `clean test`; each `offline: yes` with 0 `Downloaded from` lines in every run of record (the label is derived from
the build log, never typed). After the builds the script asserts `.m2-demo` holds `spring-boot-starter-parent-4.1.2.pom`,
`hibernate-core-7.4.13.Final.jar`, `spring-data-jpa-4.1.2.jar` and `h2-2.5.250.jar`. **At run time** every request goes to `127.0.0.1`;
every database is H2 in a JVM's memory (the harness's `jdbc:h2:mem:u17`, TiffinBox's `jdbc:h2:mem:tiffinbox`, the exercise's
`jdbc:h2:mem:ex`). **No network act**: the section's dated sweep is the brief's
(`../../../data-jpa-hibernate/_research/spring-boot-metadata-2026-11-07.xml`, md5 `2ccae19d…`: the 4.1 line ends 4.1.2, no 4.1.3;
`4.2.0-RC2` not GA — ⚑6, R.223). Spring Data JPA's version is printed by every harness JVM from its jar's manifest
(`JpaRepository.class.getPackage().getImplementationVersion()` → `4.1.2`), beside Hibernate's `HHH000001` line and
`Version.getVersionString()` (S3.15, R.246) — before the context starts, so `typo`'s failed start prints them too.

## The demo token

TiffinBox's runs (`anchor`, `seven`, `xcheck`) start in a copy under `.harness/` holding a config tree with a demo token of 36
characters (`secrets/tiffinbox/shutdown-token`, mode 0600, listed before every start — the token's file and nothing else, R.158); POST
/shutdown sends it from its file on curl's standard input (`harness/shutdown.sh`, `$CURLSET`). Every raw capture run and every log is
counted for it before the mask — 0 every time — and the captures show `[masked: the 36-character token]` where it would be.

## The locale

The JVM ignores `LC_ALL` on macOS: every JVM this script starts carries `-Duser.language=en -Duser.country=US` on its java line, and the
hygiene check refuses a java line without it (and one without its alarm); the test JVM's comes from the POM's `argLine`.

## The folders, the harness and the ports

- `before` → `../c7-unit16/after` (a link; `readlink` asserted); `after/` — this unit's frozen tree (= `../c7-tiffinbox` when committed),
  Section 3's frozen anchor.
- `harness/` — `src/probe/q/Main.java` (a Spring Boot context, `WebApplicationType.NONE`: it binds no port; `@EntityScan("com.tiffinbox")`
  — the anchor's entities — and `@EnableJpaRepositories("probe.q.repo")`; the version lines before the context starts; a failed start
  printed as its class, message and each cause, exit 1), `src/probe/q/repo/Jpql.java` (`withParam` and `withoutParam` — the same JPQL,
  `:type` and `:min`, with and without `@Param`; `bills()`, the constructor expression into `Bill`; `everyone()`, the whole entity),
  `src/probe/q/repo/Bill.java` (`record Bill(String name, int bill)`), `src/probe/q/repo/Native.java` (`byType`, a native SELECT into
  `Object[]` rows; `pageNoCount` and `pageWithCount`, the same native SELECT as a `Page<CustomerEntity>`, the second with a `countQuery`),
  `src/probe/q/Typos.java` (two configurations, each found only when a run asks: `-Dq=bad` enables `probe.q.bad`, `-Dq=good`
  `probe.q.good`), `src/probe/q/bad/BadJpql.java` (`c.nmae`), `src/probe/q/good/GoodJpql.java` (`c.name`), `Seed.java` (the shipped
  `Database` built in code on the run's own H2 URL; its `createAndSeed` seeds 1 Ravi VEG, 2 Meera NON_VEG, 3 Sunil VEG, 4 Priya VEGAN and
  two pauses, Sunil's 3 days and Priya's 2), `Run.java` (one scenario per JVM; each call between `PROBE >>> label` and `PROBE <<< label ·
  statements (getPrepareStatementCount) …` — Hibernate's Statistics cleared before each call; each query's text read off its `@Query` and
  printed as `PROBE declared …`), `src/probe/q/ex/ExApp.java` (the exercise's — compiled only by the exercise), `logback.xml` (one line per
  event, no stack trace — `%nopex`: the harness prints an exception's class, message and causes itself, R.241), `shutdown.sh` (the CORS
  lesson's, byte for byte), `surefire.py` (the testing lesson's, byte for byte), `dur7.py` (the builders', byte for byte, md5
  `41667fed…`). English names only (R.215): Ravi, Meera, Sunil, Priya, Kavya.
- `exercise/` — `README.md`, `SOLUTION.md`.
- `.harness/` (git-ignored, rebuilt by every run): the copies `before`, `after`, `anb` (B), `anb2` (B′), `ana2` (A′), `tests`; `hc` and
  `hc-nop` (the harness's two builds); `run` (the harness's working folder); the logs. `.r-NAME.1-3` while a capture runs; `.r-NAME.out`
  its result (git-ignored).
- **Ports (§P, 19960-19969):** `anchor` B 19960 · A 19961 · B′ 19962 · the POSTs 19963 · `seven` `before/` 19964 · `after/` 19965 · `xcheck`
  19966 · A′ 19967 · 19968 spare (never bound by the script) · 19969 never bound. All ten, and 18425, 8080 and 35729, are checked free at
  the start and the end; a server that listens on 8080, 35729, 19968 or 19969 is killed and the run stops. Every TiffinBox listens on
  `127.0.0.1` only (printed). The harness's JVMs, the tests and the exercise bind none.

## Masks, filters and hygiene — every one, declared

Masks (awk `gsub` only, each with a planted self-test line before any capture): the demo token → `[masked: the 36-character token]`;
this folder → `…`, the folder above → `…/..`, home → `~`, the user name → `<user>`; ` using Java <version>`; a generated H2 name
`jdbc:h2:mem:<uuid>`; an identity hash → `@…` (a JDBC connection handle's among them); the JDK proxy class's number → `$Proxy<n>`; an
EntityManager's identity → `SessionImpl(<n><open>)`; Spring Data's scan line's figure → `<n>`; H2's generated `CONSTRAINT_<n>`,
`CONSTRAINT_INDEX_<n>`; a jar path under this folder. Filters: a harness JVM's log is printed whole (trailing spaces dropped); a TiffinBox
log, the named loggers' lines (Hibernate's core and SQL loggers, `TiffinBoxServer`, the EntityManagerFactory's, Spring Data's
`RepositoryConfigurationDelegate`, Boot's `SpringApplication` and failure reporter) and, for a failed start, the exception's line after
`Application run failed` and each `Caused by:` line — no stack frame, no `... common frames omitted` line; `anchor`'s POST run logs without
its SQL lines (each request prints its own); `javap` is counted or its named lines printed, never its header (a path, a date, a
checksum). Hygiene, over every capture: no absolute path, unit number (but in a line quoted from the anchor's files), log time,
timestamp, thread number, JDK or OS token, random port, figure of elapsed time, stack frame, unmasked proxy number, identity or
generated name, URL other than 127.0.0.1's; every JVM pinned and under its alarm; no kill by name, no bare `wait`, no one-string
multi-option variable; no H2 database file (R.195); no dish name (R.215).

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

`build` — the first Maven (`before/`'s package, its Surefire fork); `harness` — the first harness JVM (`jpql` A, `probe.q.Main`);
`boot` — TiffinBox itself (`anchor` B, port 19960). `pgrep -fl java` afterwards: none.

## 1 · jpql — named parameters: `@Param`, and the names javac keeps

Two harness JVMs, the same JPQL in both — `select c from CustomerEntity c where c.mealType = :type and c.mealsPerDay >= :min order by
c.name` (read off the class), on two methods: `withParam(@Param("type") MealType type, @Param("min") int min)` and `withoutParam(MealType
type, int min)`. Before them, the builds read off the files: Boot's parent POM's `<parameters>true</parameters>` (it is why TiffinBox's
own classes keep their parameter names: `javap -v` counts `MethodParameters` attributes in the anchor's `CustomerEntityRepository` and
`CustomerRepository`, the counts in the values line), and the harness's `Jpql` class in its two builds (`hc`: as many as its methods
with parameters; `hc-nop`: 0). **A** (`hc`, with `-parameters`): `Parameter.isNamePresent()` true, the names `[type, min]`; both methods
bind — one SELECT each, `… where ce1_0.meal_type=? and ce1_0.meals_per_day>=? order by ce1_0.name`, `[Ravi, Sunil]`. **B** (`hc-nop`):
`isNamePresent()` false, `[arg0, arg1]`; `withParam` binds as before; **`withoutParam` fails at the call** — after its marker, 0
statements, the JVM's exit 0 (a call failure, S3.9) — with **`org.springframework.dao.InvalidDataAccessApiUsageException: For queries
with named parameters you need to provide names for method parameters; Use @Param for query method parameters, or when on Java 8+ use
the javac flag -parameters`** ← `java.lang.IllegalStateException` with the same message (class, message, first cause — each asserted,
R.241). The voice says both readings: the anchor's build passes `-parameters` (Boot's parent), so `@Param` is what makes a query
independent of how it was compiled.

## 2 · record — a constructor expression: the record straight out of the query (S3.8)

One harness JVM. `select new probe.q.repo.Bill(c.name, c.mealsPerDay * c.pricePerMeal * 30) from CustomerEntity c order by c.name` →
Hibernate's one SELECT, **`select ce1_0.name,((ce1_0.meals_per_day*ce1_0.price_per_meal)*30) from customer ce1_0 order by ce1_0.name`**;
S3.8's two witnesses — the select list's columns counted at its top level, and Statistics' entity loads for that call — and four
records (the counts in the values line; the records in the query table). Beside it, `select c from CustomerEntity c order by c.name`:
the entity's columns, one entity load per customer. "Selects only its columns" rests on both witnesses at once.

## 3 · native — native SQL, sent as written

One harness JVM. **`byType("VEG")`**: `SELECT name, meals_per_day FROM customer WHERE meal_type = :type ORDER BY name` (as declared) →
Hibernate logged the same text, its capitals kept, `:type` sent as `?` (asserted equal to the declared text with that one change) →
`[[Ravi, 2], [Sunil, 3]]`, each row an `Object[]` of 2, no entity loaded. **A native `Page` without `countQuery`**
(`pageNoCount(1, PageRequest.of(0, 2))`, `SELECT * FROM customer WHERE meals_per_day >= :min`): two statements — the page's `… fetch
first ? rows only`, then **`select count(1) FROM customer WHERE meals_per_day >= ?`**, the count Spring Data JPA 4.1.2 derives from the
native text (asserted: `select count(1) ` and the declared text from its `FROM` on); total 4, two pages. **With `countQuery`**
(`SELECT count(*) FROM customer WHERE meals_per_day >= :min`): the given count, sent as written, the same totals. **With a `Sort`**
(`Sort.by("name")`): `… order by name asc fetch first ? rows only` — Spring Data appended it — and page 0 is `[Meera, Priya]`. The two
unsorted pages print their totals only: their SELECT has no `order by`, so their rows are no capture (S3.7, RED #919). The plan's
"a native page needs `countQuery`" is not what this version does: said as measured, with Spring Data JPA's version beside it (S3.15).

## 4 · typo — a misspelt field in JPQL, and the start stops (the failure receipt; S3.9, S3.10)

Two harness JVMs. **B** (`-Dq=bad`: `BadJpql`, `@Query("select c from CustomerEntity c where c.nmae = :name")`): Spring Data finds the
extra interface (its own scan line), Hibernate's `HHH000001`, **`Initialized JPA EntityManagerFactory`**, then the context's refusal
(`Exception encountered during context initialization`), then `Application run failed`, then the chain, exit 1 — the runner never
ran (no `database:` line): a start failure, the log's order asserted. The chain, read off the JVM's own lines: `BeanCreationException:
Error creating bean with name 'badJpql' … Query validation failed for 'select c from CustomerEntity c where c.nmae = :name'` ←
`QueryCreationException` (the same message) ← `IllegalArgumentException` ← **`org.hibernate.query.sqm.UnknownPathException: Could not
resolve attribute 'nmae' of 'com.tiffinbox.CustomerEntity'`** ← `PathElementException` — and no suggestion anywhere in it (asserted: no
`Did you mean`). **A′** (`-Dq=good`: `GoodJpql`, the same query with `c.name`): the context starts, `Optional[Sunil]`, one SELECT.
**Beside it**, read off the derived-query lesson's README (its `typo` capture published as `4810ffd6…`, both asserted): Spring Data's own
parser, on a misspelt derived name, says `No property 'nmae' found for type 'CustomerEntity'; Did you mean 'name'`. Both stop the start
at the repository's bean, after the EntityManagerFactory; Spring Data's parser suggests a name, Hibernate's JPQL check does not.

## 5 · anchor — the change, the count, the start's order (S3.3: A/B/A′/B′), the compiled class, the 409 guard

The file list (diff -rq), each changed Java file's diff, the interface's code lines; **`grep -c prepareStatement`** over `before/`'s and
`after/`'s `CustomerRepository.java`: **2 → 0** (R.187, a named command); the sentences that state the count (S3.19, each read whole:
`CustomerEntity.java`'s, `CustomerRepository.java`'s, the anchor README's unit 17 section's — each says none or zero). **`start()`'s
Javadoc**, as Course 4 wrote it, quoted off `TiffinBoxServer.java:286-287` — the `*` dropped, the two lines joined — "The container calls
this once every constructor argument exists, so the order is its problem now, not a comment's." (R.224; the lesson that wrote it is not
named: no file this unit reads names it, R.63). **The compiled class** (`javap -v -p` over each tree's own `tiffinbox-core-1.0.0.jar`, the
one TiffinBox runs): `before/`'s `CustomerRepository(com.tiffinbox.Database, com.tiffinbox.CustomerEntityRepository)`, a
`prepareStatement` reference, no `DependsOn`; `after/`'s `CustomerRepository(com.tiffinbox.CustomerEntityRepository)`, no
`prepareStatement`, no `Database`, `org.springframework.context.annotation.DependsOn` with `value=["database"]`. Then four TiffinBox JVMs:
**B** (labelled: `after/` copied to `.harness/anb` with the one line `@DependsOn("database")` removed — asserted the only difference —
built with the README's package line and `-DskipTests`; 19960): it ends by itself, exit 1, never listened, readiness never answered;
after `Initialized JPA EntityManagerFactory` the context refuses and `Application run failed`: **`Error creating bean with name
'tiffinBoxServer': Invocation of init method failed`** ← `InvalidDataAccessResourceUsageException` ← `SQLGrammarException` ←
**`org.h2.jdbc.JdbcSQLSyntaxErrorException: Table "CUSTOMER" not found (this database is empty)`** — `start()` read the customers
before `Database` had made the table: nothing asked for `Database` before `CustomerRepository` any more. **A** (`after/`'s jar; 19961):
started, stopped by POST /shutdown. **B′** (B's tree copied again and built again, `.harness/anb2`; 19962) = B line for line, and **A′**
(`after/` copied again and built again, `.harness/ana2`; 19967) = A (R.1: each a fresh build; the comparison masks only the port and the
folder). **The guard** (`after/`, 19963, Hibernate's SQL logger on): POST Kavya → 201 (one Hibernate INSERT), again → 409 (`a customer
named Kavya already exists`; two WARN lines from `org.hibernate.orm.jdbc.error`, `HHH000247: ErrorCode: 23505, SQLState: 23505` and H2's
message; no ERROR) — the unwrapped `SQLException` path holds.

## 6 · seven — the guard and the witness (R.190, R.194)

`before/`'s jar (19964) and `after/`'s (19965), each a fresh JVM with Hibernate's SQL logger on: the seven
**`466c20ed7e0d5439cb052f32ce09de1b`** on both, 0 lines differ — a guard: it cannot tell the trees apart. **The witness** is the SQL
logger: the log's Hibernate lines in all and during the seven, each tree's (the values line), and the statements during the seven with
how often — on `after/` the two sums' SELECTs, `select coalesce(sum(((ce1_0.meals_per_day*ce1_0.price_per_meal)*30)),0) from customer
ce1_0` and `select coalesce(sum(pe1_0.days),0) from pause pe1_0`, on `before/` neither (the JDBC strings answered `/revenue` and
`/dashboard`). The probe's B2 figure for the whole log is the brief's; this capture counts it, and only the values line states it.

## 7 · tests — TiffinBox's tests (C7-4)

`after/` copied, `mvn -o -B … clean test`: **18** (14/3/1) from Surefire's reports, the console's summary the same; in the tests' log
`Found 1 JPA repository interface.` twice (the two contexts that build the data layer) — a guard (R.190). **Which tests drive the real
repository** (RED #924, counted, never assumed): each test source's `@MockitoBean CustomerRepository` lines — `TiffinBoxWebTest` 1,
`FullStackTest` 1, `FeedTest` 0. So the 18 say the change broke no route's shape; only `FeedTest`'s one test runs the new
`CustomerRepository` itself (its POST of a customer through the real class), and the sums' JPQL is run by `anchor` and `seven`, not by a test.

## 8 · xcheck — Boot's DDL script, against the owning-side lesson's (R.212)

`after/`'s jar with the anchor README's DDL line (19966): the script's md5 **`f595637014e786fa38606859951e4f97`** = unit 09's published
script md5 (its README names it; its `xcheck` capture `9072c6f1…`) — the change moved no mapping (⚑1: measured on B2 by the probe, here
on the frozen anchor itself).

## 9 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s block, then `SOLUTION.md`'s, read from the files, in ONE `env -i` shell — `/bin/bash --noprofile --norc`, then the
same in `/bin/zsh -f`: the README's app (`ExApp`, in `probe.q.ex`, `@EntityScan("com.tiffinbox")`, the shipped `Database` on its own H2,
a repository of its own in the same file — `Customers`, with `@Query("select c from CustomerEntity c where c.mealType = :type order by
c.name") List<CustomerEntity> byType(MealType type)` — and a runner that asks it for the VEG customers), compiled with plain `javac` (no
`-parameters`, asserted) → `the JVM: exit 1`, `Found 1 JPA repository interface.`, `PROBE threw:` the same
`InvalidDataAccessApiUsageException` as `jpql` B, `PROBE caused by:` its `IllegalStateException` — nothing else; the solution (one line:
`@Param("type")` on the parameter) → `exit 0`, `Found 1`, `PROBE VEG customers: [Ravi, Sunil]`. Bash and zsh print the same; the shell
ends in this folder.

## Exercise

**Your turn:** the README's query names its parameter, and this build cannot tell which argument it is. Make the name reach the query.
(23 words, `wc -w`, R.203.) `exercise/README.md` and `exercise/SOLUTION.md`.

## The anchor's README — what this unit changed in it

- **A new section**, `## Course 7 · unit 17 — @Query: JPQL and native; …`, after unit 16's: the three changed files, B's refusal and
  `@DependsOn`'s fix, the count none of five, what changes and what does not (the seven, the 18 tests and Kavya's 201/409 guards; the
  two sums' SELECTs and the compiled class the witnesses; every route through Boot's pool and Hibernate, `Database`'s seed the one
  `DriverManager` path left).
- **The header** — two notes starting *Course 7, unit 17*: the strings note (`CustomerRepository` keeps none) and the Section 3 note
  (**this tree is Section 3's frozen anchor**, units 18-22 link to it).
- **In place**, each a note that starts *Course 7, unit 17*: unit 03's "keeps its SQL strings" (none of the five since), unit 03's "Two
  ways into one database" (`monthRevenue` and `pausedDays` through Hibernate since; `Database`'s seed the one `DriverManager` path),
  unit 06's Postgres paragraph (`CustomerRepository` opens no `DriverManager` connection since), unit 15's section (its count; its
  "`Database` … still a constructor argument"), unit 16's section (its "`monthRevenue` and `pausedDays` keep theirs"; its "still a
  constructor argument").

## Section 3's frozen anchor

`after/` — and `../c7-tiffinbox` at this commit — is the tree units 18-22 measure: each links `anchor → ../c7-unit17/after` and builds
its harness over that link's extracted libraries (brief ⚑1, ⚑3). What it holds, and what a harness unit must never change: `CustomerEntity`
and `PauseEntity` as unit 09 mapped them (Boot's DDL `f5956370…`, `xcheck`); `CustomerEntityRepository` with `findByName` (derived) and
the two JPQL sums; `CustomerRepository` with no SQL string, no `Database` argument and `@DependsOn("database")`; `Database`'s
`createAndSeed` (four customers, two pauses — the rows every Section 3 harness starts from); `TiffinBoxApp`'s
`@EnableJpaRepositories("com.tiffinbox")`; the 18 tests; the seven `466c20ed…`. A harness unit reads these files and their jar — it
copies an entity source only by byte copy with its md5 asserted against this tree (⚑11), and it never writes into `after/` or
`../c7-tiffinbox`. A later section that changes the anchor starts its own chain (`before → ../c7-unit17/after`), and this unit's
receipts print a note from then on, never a stop (R.211).

## The shipped receipts on the moved anchor (R.211)

`../c7-unit16/receipts.sh` (unchanged, md5 `4416a78a…`) run once on the moved anchor, `./receipts.sh` (/bin/bash 3.2.57), `env -i`, a
session of its own, 2026-11-07 from 20:04 CET: **exit 0 in 288 s** (beside this unit's development run), the note `(after/ and
../c7-tiffinbox differ - the anchor has moved past the tree this unit froze: Files after/README.md and ../c7-tiffinbox/README.md
differ;Files after/tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntity.java and …)` at its start and end, all 9 captures 3/3 =
published, `receipts.md5` unchanged, `check_unit7.py 16 --runlog` PASS; its README gains one dated paragraph saying so.

`../c7-unit14/receipts.sh` (unchanged, md5 `fbf41b61…`) run once on the moved anchor the same way, from 20:19 CET: **exit 0 in 301 s**,
its anchor check's note (`anchor/ and ../c7-tiffinbox differ …`) at its start and end, all 7 captures 3/3 = published, its own container
(`c7-u14-pg`, 127.0.0.1:19938, its design) started and removed, `receipts.md5` unchanged, `check_unit7.py 14 --runlog` PASS; its README
gains one dated paragraph.

The other units were not re-run (the brief's order). **The builders** (R.211): `grep -n c7-tiffinbox` over `_builders/*.py`,
`check_unit7.py`, `qa_java7.py` — the four pinned asserts (`s703:44`, `s706:49`, `s707:53`, `s709:53`, each `git show <hash>:c7-tiffinbox/<p>`),
the two tools 0 lines. A scratch copy of `_builders/` (a copy never writes into the course, R.202) ran `s709.py` after the anchor moved,
with the venv's python: exit 0, its two `note: c7-tiffinbox's … has moved on since 9853dae` lines (`CustomerEntity.java`, `README.md`), and
the script, slides and prompter it wrote byte for byte the shipped `09-onetomany-manytoone-and-the-owning-side` files.

## The ledger rows and hand-offs this unit pays

- **C7-4 — re-run**: 18, unchanged (`tests`), a guard (R.190) — the tests that drive the real `CustomerRepository` counted (`FeedTest`).
- **CARRIED "U15 retires `CustomerRepository`'s strings" — settled**: 5 → 3 → 2 → 0 over units 15-17, each by its unit's tool, the seven
  and the 18 tests as guards, the SQL logger and the compiled class as witnesses.
- **CARRIED "two connection paths" — settled for the routes** (⚑12): `CustomerRepository` opens no `DriverManager` connection (0
  `prepareStatement`, no `Database` in its class); every route goes through Boot's pool and Hibernate; `Database`'s seed is the one
  `DriverManager` path left → *Flyway: Versioned Migrations* (U36).
- **Unit 16's CARRIED** — the two sums and `@DependsOn("database")`: done here.
- Hand-offs by title: *Criteria API and Specifications* (18) — a query built in code; *Projections: Four Kinds* (19) — the record of
  `record` is one of them; *Paging and Sorting* (20) — `native`'s page and its count, beside the derived ones.

## RE-MEASURE — the brief's items this unit settles

| # | Settled here |
|---|---|
| 1 | the exercise as README + SOLUTION files, bash and zsh, `env -i`: the call's `InvalidDataAccessApiUsageException`, exit 1 / `[Ravi, Sunil]`, exit 0 |
| 4 | the anchor change C3 (`16/after` → `17/after`) with its comments, Javadoc and README: strings 2 → 0, `CustomerEntity.java:23-24` stating none |
| 5 | 17's B/A/B′/A′ as one receipt's runs, each a fresh build: B and B′ the trio, exit 1; A and A′ ready |
| 12 | whether Hibernate looks at a native query at start: **not run, not said** — the gate refuses the sentence; `native` measures only what a call sends |

## What differed from the brief

1. **`start()`'s Javadoc sentence sits at `TiffinBoxServer.java:286-287`, not `:285-286`** (the brief's and RED #934's line numbers).
   `grep -n` over `c7-unit09/after`, `c7-unit15/after`, `c7-unit16/after` and this `after/` finds "The container calls this once every
   constructor" at 286 and "argument exists, so the order is its problem now, not a comment's." at 287 in all four — no unit changed the
   file; the brief's numbers are one short. The receipt reads 286-287, drops the `*`, joins them, asserts the sentence, asserts a one-line
   grep of the whole sentence finds it 0 times (it is split), and asserts `@PostConstruct` / `void start() throws Exception {` at 289-290
   (the Javadoc is `start()`'s). Course 4's lesson that wrote it is not named: no file this unit reads names it (R.63, R.224).
2. **B's chain has four lines, and its top is a `BeanCreationException`.** The brief's trio — `tiffinBoxServer` · `Invocation of init
   method failed` · `Table "CUSTOMER" not found` — is asserted whole; between them the log puts Spring's
   `InvalidDataAccessResourceUsageException` (the first cause) and Hibernate's `SQLGrammarException`, each asserted in order; H2's
   `JdbcSQLSyntaxErrorException: Table "CUSTOMER" not found (this database is empty)` is the last.
3. **`typo` runs in the harness, not in TiffinBox** — the brief's port list gives it none, and the probe's was a harness bean too: B
   (`-Dq=bad`, `BadJpql`) and A′ (`-Dq=good`, `GoodJpql`), each found only when its run asks (`Typos.java`). No A: A′ is the same JVM shape
   with the field spelt right (as unit 16's `typo`, its What differed 2). 16's message beside it is read off 16's README, with 16's
   published `typo` hash asserted, not re-run.
4. **The seven's SQL-line count is `seven`'s, and the witness is the two sums' SELECTs.** The brief puts "the seven's SQL lines … 7" in
   `anchor`'s A; here A and A′ prove the start (ready, stopped), the POSTs run on their own JVM (19963, the brief's port), and `seven`
   counts the SQL logger on both trees (before/ 19964, after/ 19965): the whole log, the start's share, readiness's, and the seven's own,
   each tree's figure in the values line — the whole log's matches the probe's B2 figure the brief quotes, and is never typed (the plant
   "a typed 7" is refused by the gate). The witness a hash cannot be: the two `coalesce(sum(…))` SELECTs during the seven, none on
   `before/`, both on `after/`.
5. **A jar witness the brief does not name.** `javap -v -p` over each tree's own `tiffinbox-core-1.0.0.jar`: `before/`'s
   `CustomerRepository(Database, CustomerEntityRepository)`, one `prepareStatement` reference, no `DependsOn`; `after/`'s
   `CustomerRepository(CustomerEntityRepository)`, none, `DependsOn(value=["database"])`. It reads the class TiffinBox runs, so the plant
   "`before/`'s jar in `after/`'s place" is stopped by it as well as by the SQL witness (Planted faults).
6. **`Bill` is `record Bill(String name, int bill)`** — `c.mealsPerDay * c.pricePerMeal * 30` is an `Integer` in JPQL (the brief's
   "long/int"); the interface's two sums return `long` (`sum` of an `int` is a `Long` in Hibernate 7.4), and `CustomerRepository` keeps its
   `int` signatures with `Math.toIntExact`, so `Dashboard`, the routes and the tests' mocks are unchanged.
7. **"Logged verbatim" is asserted as the declared text with each named parameter sent as `?`.** The native queries use `:type` and `:min`
   (with `@Param`); Hibernate logs `?` in their place and changes nothing else — capitals, spacing, `ORDER BY` kept. The derived count is
   asserted as `select count(1) ` + the declared text from its `FROM` on.
8. **The two unsorted native pages print their totals only** (S3.7, RED #919: their SELECT has no `order by`); the sorted page prints its
   names. Page size 2 on four rows: page 0 is full, and the count runs.
9. **The version lines are printed by `Main` before the context starts**, so `typo` B — whose runner never runs — prints them too (S3.15,
   R.246: every harness JVM).
10. **`Database.java` is unchanged**: its Javadoc ("an embedded H2 database, created and seeded on startup") names no reader — the brief
    changes it only if it does. Its `DriverManager` is the one such path left (⚑12).
11. **B's copy differs by one line** — `@DependsOn("database")` removed; the import stays (unused, it compiles), asserted the only difference.
12. **The exercise's files point at the capture** (`../receipts.sh`, capture `exercise`, this README's section 9) instead of pasting its
    output; Boot 4.1.2 hands the runner's exception to `ExApp` unwrapped, so the broken half's chain is the same two lines as `jpql` B's
    (asserted equal). The exercise is a harness application over TiffinBox's core jar, as units 15's and 16's were.
13. **The plants ran on scratch mirrors with only the planted capture(s) kept** (as units 15 and 16); harness-only plants checked only port
    19968 so they could run beside a run of record — each still exits 1 at its own check; a gate plant needs no capture at all.
14. **Ports:** as the brief's (19960-19967 bound; 19968 spare and 19969 never bound — both checked free at the start and the end).

## Planted faults — each caught (R.65)

Each on a scratch mirror of this folder (its neighbours linked: `../c7-unit16`, `../c7-unit09`, `../c5-unit11`, `../c6-unit19`,
`../c6-unit28`, `../c7-tiffinbox`), one fault at a time, the mirror's `receipts.sh` keeping only the planted fault's capture(s) (What
differed 13), `env -i`; each **exit 1, nothing written to this folder** (its script, hashes, harness, exercise and `after/` hashed before
and after), no JVM of the mirror left. The line that stopped each:

| plant | where | caught by |
|---|---|---|
| `CustomerEntity.java:23-24` left as unit 16 shipped it ("keeps two of its five …") | `after/` | `CustomerEntity.java:23-24 must state the count grep gives - keeps none of its five SQL strings (S3.19, R.250)` (before any build) |
| `-parameters` on the `hc-nop` build (the script's line and the README's) | `receipts.sh`, `README.md` | `jpql: MethodParameters - the build with -parameters keeps them (2), the build without keeps none (2)` |
| `@DependsOn` kept in B (B's copy a plain copy, its difference check with it) | `receipts.sh` | B became ready and was stopped; `anchor B/B': without @DependsOn the start fails by itself, exit 1, never listening` |
| C without it — `after/`'s `CustomerRepository` without `@DependsOn` | `after/` | A's start: `it never listened on 19961` (it exited: the trio) |
| A′ run on C's tree — `.harness/ana2` copied from B's tree | `receipts.sh` | A′'s start: `it never listened on 19967` |
| a SAY line claiming the native SQL is looked at at start (the brief's unmeasured wording, as one sentence in section 3) | `README.md` | `a line says native SQL is … at start - unmeasured here (the brief's RE-MEASURE 12)` (the gate's message, its claim elided) |
| `before/`'s jar in `after/`'s place (`seven` run first, then `anchor`) | `receipts.sh` | the seven's hash on both — **the guard passed: it cannot tell** (R.190); then the witness: `seven: the witness - the two sums' SELECTs during the seven: before/ none (0), after/ both (0)` |
| a typed count of the seven's SQL lines (the brief's figure, typed before "Hibernate lines", in section 6) | `README.md` | `a typed count of SQL lines - seven counts them, and only the values line states them (R.225)` |
| a typed SQL string in the query table's native row (lower-cased) | `README.md` | `README.md's query table is not the captures' - each row is composed from jpql, record and native …` |
| a wrong published hash (`jpql`'s last digit) | `receipts.md5` | `jpql is not the published capture …` (after its checks passed) |
| no `HHH000001` (`org.hibernate.orm.core` at WARN) | `harness/logback.xml` | `jpql: the version lines - getVersionString(), Hibernate's HHH000001 and Spring Data JPA's 4.1.2 - once in each of its 2 harness JVMs (R.222, S3.15/R.246)` |
| no Spring Data version line (`Main.java`'s line removed) | `harness/src` | the same check (S3.15) |
| an Indian dish name | `README.md` | `an Indian dish name (R.215: English names only)` |
| a duration word | `README.md` | `dur7.DUR found a duration word - this unit speaks no time (R.172)` |
| record: the call loads the entities too (`everyone()` before `bills()`) | `harness/src` | `record bills: 1 statements - the SQL log's lines (2) and getPrepareStatementCount() (2) both (R.184)` |
| typo: B's query spelt right (`c.name`) | `harness/src` | `typo B: never reached the runner: did not expect: PROBE database:` |
| tests: `FeedTest.java` deleted | `after/` | `tests: expected the line: TEST-com.tiffinbox.web.FeedTest.xml: tests 1 …` |
| xcheck: a wrong unit 09 md5 | `receipts.sh` | `xcheck: ../c7-unit09/README.md must name f595…4e98, and its receipts.md5 its xcheck 9072c6f1… (R.212)` |
| exercise: the solution's sed matches nothing | `exercise/SOLUTION.md` | `exercise: the solution - @Param("type"), the two VEG customers: expected the line: the JVM: exit 0` |

(A first try of the hash plant did not run — the plant runner was edited while its loop ran — and a first exercise plant kept only the
`exercise` capture, so the check had no `jpql` B to compare with and stopped on that; both were run again, as the table shows.)

## Found on the way

- **The Javadoc's lines are one further down than the brief says** (What differed 1): read off the file by `grep -n`, then asserted.
- **A derived count without its named parameter.** The first draft of the native check composed `select count(1) FROM … >= :min` — the
  declared text, its parameter unsent; the dev run stopped on it, and the check now sends `:min` as `?` like the rest.
- **Boot 4.1.2 does not wrap a runner's exception**: the exercise's first draft expected a `Failed to execute CommandLineRunner` line
  above the call's exception; the capture shows `InvalidDataAccessApiUsageException` as the top line, its `IllegalStateException` under it.
- **A class annotation in `javap -v`** prints as `org.springframework.context.annotation.DependsOn(` then `value=["database"]` on the next
  line; the first grep (basic regex, a bare `(`) failed with "parentheses not balanced" — now `grep -E`.
- **Unit 16's exercise files carry two placeholder lines** — `EXERCISE-README-OUTPUT` (`../c7-unit16/exercise/README.md`) and
  `EXERCISE-SOLUTION-OUTPUT` (its `SOLUTION.md`), each under "What it prints … measured"; 16's receipt checks the block, not those lines.
  Not changed here (a shipped unit's file outside this commit's four paths); named for the scripts stage.

## CARRIED

- **`Database`'s seed and its `DriverManager` path** (C7-1 cause 2; the last of the two paths) → U36 (Flyway) and U39 (the restart).
- **Whether Hibernate looks at a native query before its first call** — not measured (RE-MEASURE 12); a later unit that wants to say
  it builds its own failure capture.
- **The same native SQL on PostgreSQL** (⚑2's "cut the line, or run it") — cut here: 17 runs H2 only; no slide says "the same text on
  PostgreSQL".
- **The 18 tests drive the sums' JPQL nowhere** (`tests`: `FeedTest` alone runs the real `CustomerRepository`, and it does not read
  the sums) → U39's brief, if the capstone's `@DataJpaTest` wants them under a test.
- **`throws SQLException` on `monthRevenue`/`pausedDays`** — kept for the callers and the mocks; nothing in them throws it now. A later
  unit that touches the signatures may drop it.

## For RED

- **The witnesses can fail; the guards cannot** (R.190): the plant that puts `before/`'s jar in `after/`'s place passes the seven's hash
  (`466c20ed…` on both) and is stopped by the two sums' SELECTs (0 on it) — and the jar's `javap` would stop it too. Ask whether any line a
  script may say rests on the seven's hash alone.
- **B's cause is read off the log, not the container** (R.201): the log shows `start()`'s SELECT failing on an empty database; that
  `Database`'s `createAndSeed` had not run yet is the code's reading (the constructor argument gone), not a capture of the bean order.
  Ask whether "nothing asked for `Database` first any more" is a sentence the voice may say, or only "without `@DependsOn` the table is not
  there when `start()` reads".
- **"Sent as written"** rests on the declared text and the logged text being equal but for `:type`/`:min` → `?` (What differed 7). Ask
  whether a slide may show the declared text as "what Hibernate sent".
- **`select count(1) …`** is Spring Data JPA 4.1.2's derivation from the native text (the version printed beside it, S3.15); the plan said a
  native page needs `countQuery`. Ask whether "Spring Data 4.1 derives it" is narrow enough.
- **The 18 tests** (`tests`): only `FeedTest` runs the real `CustomerRepository`, and none runs the two sums' JPQL — `anchor` and `seven`
  do. Ask whether "the tests still pass" is said with that count beside it (R.190).
- **`-parameters`**: the anchor's classes keep their names (`MethodParameters`, Boot's parent POM's `<parameters>true</parameters>`), so
  TiffinBox itself would bind a `@Param`-less query. Ask whether the voice says "`@Param` makes the query independent of how the class
  was compiled" and nothing stronger.
- **The S3.19 sentence set** here is "SQL string" (as units 15 and 16); `DriverManager` and `JDBC` sentences in `after/`'s sources are
  `Database`'s (true) and `application.yaml`'s comment (true: `Database` opens its own connections). Try a sentence the reader lets through.
- **The exercise is a harness app** (What differed 12): ask whether the spoken line fits it.
