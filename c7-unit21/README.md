# c7-unit21 — Query By Example and Querydsl

Course 7 · Data with JPA & Hibernate · Section 3 (Querying), its seventh unit, and **the fourth on Section 3's frozen anchor — no change
to the anchor** (brief ⚑11): `anchor` is the link to `../c7-unit17/after`. Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot
4.1.2** (Spring Data JPA 4.1.2, Hibernate ORM 7.4.13.Final, Querydsl 5.1.0 with the `jakarta` classifier, Jakarta Persistence 3.2.0, H2
2.5.250 — the anchor's pin), 2026-11-09, **on H2 only** (brief ⚑2: every capture says so in its own lines). **Query by Example** asks
with an object — a **probe**: the example object — and Spring Data JPA 4.1 writes a `where` condition for every field of it that is not
`null`. TiffinBox's `CustomerEntity` has two `int` fields, and an `int` left at zero is not `null`: it is a value. **Querydsl** asks with
typed paths that its annotation processor generates from the entity sources — `QCustomerEntity` — and its predicates read like the SQL
they become. Measured: the probe with only the meal type set (0 rows) and the same probe with the two `int`s ignored; a string
matcher, `matchingAny()` against `matching()`, `count(Example)` and the fluent `findBy`; Querydsl's processor running only when asked,
its generated fields, three predicates through `QuerydslPredicateExecutor`, a count and a `JPAQueryFactory` query with `any()`.

**No anchor change (brief ⚑11).** `anchor` → `../c7-unit17/after` (`readlink` asserted), Section 3's frozen anchor. `receipts.sh` prints
`diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox` at its start and end — empty in every run of record —
and, from any later anchor change on, prints a note instead (R.211). The anchor is copied under `.harness/anchor` and built there with
its README's package line (offline; its 18 tests run inside that build), its jar extracted with the anchor's own line; the harness runs
over those 91 libraries plus Querydsl's three run-time jars. The entity sources Querydsl's processor reads — `CustomerEntity.java`,
`MealType.java`, `PauseEntity.java` — are byte copies of the anchor's (`.harness/ents/`, each md5 asserted equal to the frozen tree's,
printed by `querydsl`). TiffinBox's build gains no processor and no Querydsl jar; TiffinBox itself is not started by this unit.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 5 captures, 3 runs each; every spoken number checked after its capture; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version` and `javac -version` say 25.) It **dies** when a
check after a capture fails, and when a capture's md5 differs from `receipts.md5` (the capture's checks run first, then the `DIFFERS`
line). **Start it in a process group of its own** (a terminal's foreground job is one): `sweep()` stops only processes of its own group.
`.m2-demo` must be seeded first (below). No Docker, no container, no password, no token: every database is H2 in a JVM's memory, and no
JVM here binds a port.

**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`), a session of its own
(`perl -MPOSIX -e 'setsid; exec @ARGV'`), `.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681
files, an APFS clone of the folder). Development runs (a scratch copy of this script, `.r-dev.sh`, git-ignored, whose README gates and
the published-hash stop print instead of stopping) fixed the captures and the checks; the first full run wrote every capture 3/3, and
those md5s are `receipts.md5`. **The runs of record, on the script as committed (`receipts.sh` md5 `83ae15548ba3e6393e9468f3cf1b174d`):
160 s under `./receipts.sh`** (/bin/bash 3.2.57, 2026-11-09 from 06:50 CET), **302 s under `bash receipts.sh`** (Homebrew bash 5.3.9,
from 06:53 CET, beside the plant mirrors) **and 129 s from a sealed fresh clone** (below, from 06:59 CET): each exit 0, all 5 captures
3/3 = published, every check passed, every build (the anchor's and the two POMs') `offline: yes · exit 0 · 'Downloaded from' lines in its
log: 0`, the anchor note empty at the start and the end, nothing listening on 18425, 8080, 35729 or 20000-20009 at the end; each terminal
log through `check_unit7.py 21 --runlog` — `0 grep error line(s)`, `RESULT (run logs): PASS` (the unit gate itself answers "no 21-*.md …
nothing to check": no script yet). The builders' `_builders/dur7.py` over this README and the exercise's two files: 0 duration words.
**Nothing was downloaded**, and this unit made no network act. **On the tree as committed** — this README final — one more
`./receipts.sh` (`env -i`, a session of its own): see the commit message.

**Query by Example's raw orders, measured (RE-MEASURE 9, never hashed):** over every JVM this unit's development runs, runs of record
and plant mirrors started, `probe` B's three-term line came in **all six orders** of its three terms (36 JVMs: 9 / 7 / 7 / 5 / 4 / 4), and
`matcher`'s `or` line in both orders (21 JVMs: 11 / 10); each run of record's summary line: B 2, 3 and 3 orders in its 3 JVMs, the `or`
line 2 orders in 3. The normal form was the same in all of them.

Published hashes: probe `da9185925008507377d9c9025333a58f` · matcher `d890d2261a0e68530bf07f885cf792d7` · querydsl `a9999317eb8550dbd2e67dce3b107a29` · xcheck `7d7eb7c2d282e47924e6bc0c2a332c7f` · exercise `27eff00f4974a9a845af8cdb205c2aad`.

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line, R.225 — a SQL string, a
count of the processor's files or a Querydsl field typed anywhere else is refused):

the values the video may say: probe, on Spring Data JPA 4.1.2 - B Example.of(new CustomerEntity(null, 0, 0, VEG)): where and: [ce1_0.meal_type=?, ce1_0.meals_per_day=?, ce1_0.price_per_meal=?] (3 terms in the raw line; the null name, id and pauses: no term) -> 0 rows · names, sorted by the harness: [] · A withIgnorePaths("mealsPerDay", "pricePerMeal"): where and: [ce1_0.meal_type=?] -> 2 rows · names, sorted by the harness: [Ravi, Sunil] · Query by Example's like: escape '\' (where and: [lower(ce1_0.name) like ? escape '\'] -> 3 rows · names, sorted by the harness: [Meera, Priya, Ravi]) · matchingAny(): where or: [ce1_0.meal_type=?, ce1_0.name=?] (md5 08bd46d2a6f29a5d248c074fdfcbf79c) -> 3 rows · names, sorted by the harness: [Meera, Ravi, Sunil] · matching(), the same probe: where and: [ce1_0.meal_type=?, ce1_0.name=?] (md5 30bbd0b1aba49843df4d10cbf19e796d) -> 0 rows · names, sorted by the harness: [] · count(Example): select count(ce1_0.id) from customer ce1_0 where and: [ce1_0.meal_type=?] -> 2 · findBy(..., q -> q.sortBy(Sort.by("name")).first()): select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where and: [ce1_0.meal_type=?] order by ce1_0.name fetch first ? rows only -> Optional[Ravi] · a line mixing and with or: REFUSED, exit 1 · Querydsl 5.1.0 (jakarta), the processor with -proc:full -processorpath (9 jars): 2 files by find - QCustomerEntity.java, QPauseEntity.java; on the class path alone: 0 · QCustomerEntity's fields: NumberPath<Long> id; NumberPath<Integer> mealsPerDay; EnumPath<MealType> mealType; StringPath name; ListPath<PauseEntity, QPauseEntity> pauses; NumberPath<Integer> pricePerMeal · eq(VEG).and(goe(2)): where ce1_0.meal_type=? and ce1_0.meals_per_day>=? -> 2 rows · names, sorted by the harness: [Ravi, Sunil] · containsIgnoreCase("r") with Sort.by("name"): Querydsl's like escape '!' -> 3 rows · names, in the query's order: [Meera, Priya, Ravi] · count(predicate): select count(ce1_0.id) from customer ce1_0 where lower(ce1_0.name) like ? escape '!' -> 3 · pauses.any().days.gt(1): where exists(select 1 from pause p1_0 where p1_0.days>? and ce1_0.id=p1_0.customer_id) order by ce1_0.name -> 2 rows · names, in the query's order: [Priya, Sunil] · EntityPathBase from querydsl-core-5.1.0.jar, JPAQueryFactory from querydsl-jpa-5.1.0-jakarta.jar · xcheck: f595637014e786fa38606859951e4f97 · exercise: Example.of(probe) -> 0; withIgnorePaths -> 2 [Ravi, Sunil] (21 words)

### Query by Example's SQL — its normal form (S3.6/R.237, RED #910)

Spring Data JPA writes a probe's `where` terms in an order that changes from JVM to JVM (the probe's Step 12: three orders in five JVMs;
here, in the first development run, the three-term line of `probe` B came in **three different orders in its three JVMs**, and the `or`
line of `matcher` in two orders over its three). A verbatim hash of that line cannot be 3/3. So every SQL line of `probe` and `matcher`
is captured in a **normal form**, written by `.harness/qbe.awk` (the script writes it before any capture and tests it on planted lines):
the terms of the `where` clause, split on its one connective (` and ` or ` or `), **sorted**, and written under that connective —
`where and: [t1, t2, t3]` or `where or: [t1, t2]`; a line with one term has no connective and is written `and: [t]`; what follows the
`where` clause (`order by …`, `fetch first ? rows only`) is kept as logged. The line in the capture is marked `DEBUG org.hibernate.SQL
(normal form, S3.6) :`; the line after it says how many terms the raw line had, its connective, and that **its term set equals the
normal form's** (each read again from the two texts, asserted). The raw line never enters the capture: it is printed to the terminal
only, with its JVM (`(terminal only, never hashed) probe B, JVM 4, raw: …`), and at the end of the run a summary line counts the
distinct raw orders per query (RE-MEASURE 9). **A line that mixes ` and ` with ` or ` has no normal form: it is `REFUSED`, and the run
stops (exit 1)** — `matcher` shows the refusal on a planted line (written by the script, never logged). The connective is kept, so
`matchingAny()` and `matching()` on the same probe hash differently (RED #910): their two normal forms' md5s are printed in `matcher` and
equal BLUE's (`08bd46d2…` for `or:`, `30bbd0b1…` for `and:`, the brief's AMENDMENT — BLUE hashed the same text). `querydsl`'s SQL is
captured as logged: Querydsl writes the terms in the order the code gives them (3/3 verbatim, measured).

### When each — the choose table (a slide, not a capture)

Three SQLs side by side, each composed by `receipts.sh` and compared with this table: `probe` A's normal form, the Criteria lesson's
one-filter row (read off `../c7-unit18/README.md`'s search table; its `spec` capture `fb76cb020b6d2a5d304b2b24e25081da` asserted in
`../c7-unit18/receipts.md5`) and `querydsl`'s first predicate. No new claim — a row changed or a SQL string typed here stops the run.
The three `like` conditions each lesson measured differ in their escape character (Query by Example's `matcher`, the Criteria lesson's
`spec`, `querydsl`) — each is in the values line, quoted from its own capture, never one for another.

<!-- choose: three SQLs side by side (probe A · the Criteria lesson's spec · querydsl) -->
| asked with | the call | the `where` clause (from `customer ce1_0` on) | returned |
|---|---|---|---|
| Query by Example | `findAll(Example.of(probe, ExampleMatcher.matching().withIgnorePaths("mealsPerDay", "pricePerMeal")))` (probe A) | `where and: [ce1_0.meal_type=?]` | 2 rows · names, sorted by the harness: [Ravi, Sunil] |
| Specification | `findAll(search("r", null, null))` (the Criteria lesson's spec, fb76cb02) | `where lower(ce1_0.name) like ? escape ''` | 3 rows · names, sorted by the harness: [Meera, Priya, Ravi] |
| Querydsl | `findAll(c.mealType.eq(VEG).and(c.mealsPerDay.goe(2)))` (querydsl) | `where ce1_0.meal_type=? and ce1_0.meals_per_day>=?` | 2 rows · names, sorted by the harness: [Ravi, Sunil] |

The voice (the brief's spine): a probe is right when a search is "find customers like this one" and every field you never set is
`null`; a specification when the filters are optional and built in code (unit 18); Querydsl when the query wants typed paths and joins
(`any()`) that read like SQL. The table shows what each wrote; which to pick is the script's, not a measurement.

### A sealed fresh clone — the recipe (R.129)

**Paste it into bash.** Unit 17's recipe, with this unit's folder:

```bash
S=/tmp/sealed21; W="/tmp/sealed 21"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
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
cd "$W/tiffinbox-java/c7-unit21" && readlink anchor && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E ./receipts.sh            # a process group of its own
```


**Run (2026-11-09, from 06:59 CET):** a `git clone` of tiffinbox-java at `cf9bda9` into a path **with a space** (`…/sealed 21/tiffinbox-java`,
in the session's scratch folder), this commit's change put in as git takes it (the 16 paths `git ls-files -o --exclude-standard` listed
— all under `c7-unit21/` — each `cmp`-equal to the working tree, `anchor` → `../c7-unit17/after` by `readlink`); a `file://` copy of the
s3 seed (5,023 files once `_remote.repositories`, `*.lastUpdated` and `resolver-status.properties` are left out); pre-flight: exit 1,
221 `Downloading from sealed: file://`, 0 from http(s); the clone's `.m2-demo` seeded from that copy; `/bin/bash` 3.2, `env -i` with the
dead proxies, a session of its own: **exit 0 in 129 s, all 5 = published, every check passed**; the three builds `offline: yes · exit 0
· 'Downloaded from' lines in its log: 0`; after the run `.m2-demo` held 5,023 files, 0 `_remote.repositories`. Its terminal log through
`--runlog`: PASS. (The clone's README was this file before its last prose was filled in; this README passes the same gates in the run on
the tree as committed.)

## The commands this unit adds

```
cd .harness/apt && mvn -o -B -Dmaven.repo.local="$M2" dependency:build-classpath -Dmdep.outputFile=cp.txt
cd .harness/qd && mvn -o -B -Dmaven.repo.local="$M2" dependency:build-classpath -Dmdep.outputFile=cp.txt
javac -proc:full -processorpath "$AP" -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:$QR" -s .harness/qsrc -d .harness/qcls .harness/ents/CustomerEntity.java .harness/ents/MealType.java .harness/ents/PauseEntity.java
javac -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:$QR:$AP" -s .harness/ctl/src -d .harness/ctl/cls .harness/ents/CustomerEntity.java .harness/ents/MealType.java .harness/ents/PauseEntity.java
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:$QR:.harness/qcls" harness/src/probe/q/Main.java harness/src/probe/q/Run.java harness/src/probe/q/Seed.java harness/src/probe/q/repo/Customers.java harness/src/probe/x/XMain.java
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../qcls:$QR:../anchor/tiffinbox-web/target/extracted/lib/*" probe.q.Main "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.x.XMain "${A[@]}"
```

**Querydsl's two class paths** (⚑7, S3.17/R.248, RED #901): `harness/apt/pom.xml` names `com.querydsl:querydsl-apt` with the `jakarta`
classifier and the Jakarta Persistence API; `harness/qd/pom.xml` names `com.querydsl:querydsl-jpa` with the `jakarta` classifier. Both
write `<version>${querydsl.version}</version>` — Boot's property (5.1.0, read back off the jars' names, never typed): `querydsl-bom`
manages the unclassified artifacts only, so the `jakarta` classifier needs the version written (the probe's Attempt 0: `'dependencies
.dependency.version' … is missing`). The first two lines ask Maven, offline, for each POM's jars — every one under `$M2`, written to
`cp.txt` — and `AP` (the processor path) and `QR` (Querydsl's run-time jars) are those lists (`AP=$(cat .harness/apt/cp.txt)`, each jar by
name, joined by `:`, no wildcard — a `lib/*` after `-processorpath` is not expanded, the probe's Step 11; `jakarta.persistence-api-3.2.0.jar`
is on it by name, asserted: without it the processor cannot load `jakarta.persistence.Entity`). **The Q line** runs the processor over the
anchor's entity sources with `-proc:full -processorpath "$AP"` — the apt jar's `META-INF/services` entry names its processor, so no
`-processor` flag is needed — generated sources into `.harness/qsrc` (`-s`), classes into `.harness/qcls` (`-d`); the build keeps only
the Q classes there (the anchor's jar has the entities). **The control line** is the same `javac` with the same jars on the class
path alone and no processor flag — on JDK 25 it runs no processor and says nothing (`querydsl` counts what it wrote). The brief's other
form, a harness POM with `<maven.compiler.proc>full</maven.compiler.proc>`, is not used here (What differed 1). **The harness line**
compiles the harness against the anchor's libraries, `QR` and the Q classes, with `-parameters` (as Boot's parent compiles TiffinBox).
**The two java lines** run the harness and xcheck's context from `.harness/run` (`V` the JVM flags — the scenario
`-Ds=probe|matcher|querydsl` and the variant `-Dv=A|B` — and `A` the arguments, R.193, each printed as `$ V=(…)` / `$ A=(…)`, `A` with
`printf %q`). Every java line runs under `perl -e 'alarm 240; exec @ARGV'` (R.247: macOS has no `timeout`; an alarm that fires ends
the JVM with exit 142, which the runner refuses); the exercise's JVM under its own alarm. The lines read from `anchor/README.md` (2,
each asserted whole) are its package line, `mvn -B package`, and its extract line. `querydsl` prints its processor run with
`.harness/q-run/` in place of `.harness/q` (a fresh folder each run).

## The repository, and the network

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681 files; ⚑8: the s3 seed holds the upstream `com.querydsl` group at
5.1.0 — `querydsl-apt`, `querydsl-jpa` (both `jakarta`), `querydsl-core`, `querydsl-codegen`, `codegen-utils` — and `mysema-commons-lang`,
`ecj`, `classgraph`, `javax.inject`, which the processor path needs). Three builds: the anchor's `package` (its 18 tests run) and the two
POMs' `dependency:build-classpath`; each `offline: yes` with 0 `Downloaded from` lines in every run of record (the label is derived
from the build log, never typed). After the anchor's build the script asserts `.m2-demo` holds `spring-boot-starter-parent-4.1.2.pom`,
`hibernate-core-7.4.13.Final.jar`, `spring-data-jpa-4.1.2.jar`, `h2-2.5.250.jar`, `querydsl-apt-5.1.0-jakarta.jar` and
`querydsl-jpa-5.1.0-jakarta.jar`. **At run time** no JVM binds a port; every database is H2 in a JVM's memory (the harness's
`jdbc:h2:mem:u21`, xcheck's `jdbc:h2:mem:x21`, the exercise's `jdbc:h2:mem:ex`). **No network act**: the section's dated sweep is the
brief's (`../../../data-jpa-hibernate/_research/spring-boot-metadata-2026-11-07.xml`: the 4.1 line ends 4.1.2, `4.2.0-RC2` not GA —
⚑6, R.223). Spring Data JPA's version is printed by every harness JVM from its jar's manifest
(`JpaRepository.class.getPackage().getImplementationVersion()` → `4.1.2`), beside Hibernate's `HHH000001` line and
`Version.getVersionString()` (S3.15, R.246) — before the context starts. **The fork** (`io.github.openfeign.querydsl` 7.7) is not in the
s3 seed and this unit has no network: it is not measured here (What differed 2).

## The locale

The JVM ignores `LC_ALL` on macOS: every JVM this script starts carries `-Duser.language=en -Duser.country=US` on its java line, and the
hygiene check refuses a java line without it (and one without its alarm).

## The folders, the harness and the ports

- `anchor` → `../c7-unit17/after` (a link; `readlink` asserted) — Section 3's frozen anchor, never built in place.
- `harness/` — `src/probe/q/Main.java` (a Spring Boot context, `WebApplicationType.NONE`: it binds no port; `@EntityScan("com.tiffinbox")`
  — the anchor's entities — and `@EnableJpaRepositories("probe.q.repo")`; the version lines before the context starts; a failed start
  printed as its class, message and each cause, exit 1), `src/probe/q/repo/Customers.java` (`extends JpaRepository<CustomerEntity, Long>,
  QuerydslPredicateExecutor<CustomerEntity>` — Query by Example's methods are `JpaRepository`'s, inherited from `QueryByExampleExecutor`;
  nothing of its own), `src/probe/q/Run.java` (one scenario per JVM; each call between `PROBE >>> label` and `PROBE <<< label ·
  statements (getPrepareStatementCount) …` — Hibernate's Statistics cleared before each call; the rows of a query without an `order by`
  printed sorted by the harness, S3.7; the probe's fields printed before its calls; the class loader's location of `EntityPathBase`,
  `JPAQueryFactory` and `QCustomerEntity`), `src/probe/q/Seed.java` (unit 18's, byte for byte: the shipped `Database` built in code on the
  run's own H2 URL; its `createAndSeed` seeds 1 Ravi, 2 Meera, 3 Sunil, 4 Priya and two pauses — Sunil 3 days, Priya 2 — each read back
  by a second connection in every harness JVM), `src/probe/x/XMain.java` (xcheck's context: `@EntityScan("com.tiffinbox")` alone,
  outside `probe.q`, so no repository and no seed), `src/probe/q/ex/ExApp.java` (the exercise's — compiled only by the exercise),
  `apt/pom.xml` and `qd/pom.xml` (Querydsl's two class paths, above), `logback.xml` (unit 18's, byte for byte: one line per event, no
  stack trace — `%nopex`: the harness prints an exception's class, message and causes itself, R.241), `dur7.py` (the builders', byte
  for byte, md5 `41667fed…`). English names only (R.215): Ravi, Meera, Sunil, Priya.
- `exercise/` — `README.md`, `SOLUTION.md`.
- `.harness/` (git-ignored, rebuilt by every run): `anchor` (the copy, built, extracted); `apt`, `qd` (the POMs' copies, `cp.txt`);
  `ents` (the entity sources' copies); `qsrc`, `qcls` (the build's Q classes); `hc` (the harness); `run` (the JVMs' working folder);
  `q-run`, `ctl` (`querydsl`'s own processor run and its control); `qbe.awk` (the normal form); the logs. `.r-NAME.1-3` while a capture
  runs; `.r-NAME.out` its result (git-ignored).
- **Ports (§P, 20000-20009): none bound.** All ten, and 18425 (TiffinBox's default), 8080 and 35729, are checked free at the start and the
  end; 20009 is the one the brief names "never bound" — and so is every other.

## Masks, filters and hygiene — every one, declared

Masks (awk `gsub` only, each with a planted self-test line before any capture): this folder → `…`, the folder above → `…/..`, home → `~`,
the user name → `<user>`; ` using Java <version>`; an identity hash → `@…`; the JDK proxy class's number → `$Proxy<n>`; an
EntityManager's identity → `SessionImpl(<n><open>)`; Spring Data's scan line's figure → `<n>`; H2's generated `CONSTRAINT_<n>`,
`CONSTRAINT_INDEX_<n>`. `xcheck` prints Hibernate's generated foreign-key name as `FK<name>` (its md5 is taken of the file itself).
**The normal form** (above) rewrites Query by Example's SQL lines in `probe` and `matcher` — the one filter of a logged line in this
unit, declared and self-tested; the raw lines go to the terminal only. Filters: a harness JVM's log is printed whole (trailing spaces
dropped); `javac`'s output is printed whole; `querydsl` prints `QCustomerEntity.java`'s class line and its `public final` field lines
(`grep -nE`, printed as it runs) and the two POMs' jar lists by file name. Hygiene, over every capture: no absolute path, unit number,
log time, timestamp, thread number, JDK or OS token, figure of elapsed time, stack frame, unmasked proxy number, identity or generated
name, URL; every JVM pinned and under its alarm; no kill by name, no bare `wait`, no one-string multi-option variable; no H2 database
file (R.195); no dish name (R.215). The prose gates, before any build: no duration word (dur7, R.172); no dish name; no placeholder line
and no empty "What it prints" block in the exercise's files; no Spring Data property exception named by its 3.x package (S3.10); no
typed count of the processor's files (S3.17, RED #902); no SQL string in this README outside the choose table and the values line
(R.225); no claim of a fixed term order for Query by Example (S3.6). After `querydsl`: every Querydsl field this prose
names (`NumberPath<Long> id`, `StringPath name`, …) must be one the generated `QCustomerEntity.java` holds.

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the Maven or the
`javac` it waits for (`$mpid`, with every process under it), the exercise's shell (`$xpid`), sweeps its own process group for any harness
or exercise JVM (`probe.q.`, `probe.x.`), `javac` or Maven left, deletes the capture runs it had not finished (`.r-NAME.1-3`), and
removes `.r-lock`. The published captures are untouched. No `wait` in the script or the exercise is bare. Every `javac` runs like a
build — in the background, its pid in `$mpid`, waited for — so an interrupt during one is handled like an interrupt during Maven.

**Measured (2026-11-09, the sealed clone, the script as committed):** `./receipts.sh` (/bin/bash 3.2) started in a session of its own
**with SIGINT at its default** (`perl -MPOSIX -e '$SIG{INT}="DEFAULT"; setsid; exec …'`), `kill -INT` to its group once the named
process was in it, the state read 5 s later — three trials, each **exit 130, nothing left**:

```
build: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
apt: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
harness: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
```

`build` — the first Maven (the anchor's package, its Surefire fork); `apt` — the build's processor run (`javac -proc:full …`);
`harness` — the first harness JVM (`probe` B, `probe.q.Main`). `pgrep -x java` afterwards: none.

## 1 · probe — the trap (the failure receipt; the hook)

Three harness JVMs. Each prints the probe first, as the constructor set it: `new CustomerEntity(null, 0, 0, VEG)` → `id null · name null
· mealsPerDay 0 · pricePerMeal 0 · mealType VEG · pauses []`. **B** — `findAll(Example.of(probe))`, the default matcher: one SELECT (the
SQL logger's line and `Statistics`, R.184) whose `where` clause, in its normal form, holds **its terms under `and`** — the meal type's
and **one for each `int` left at zero** — and **0 rows** (no customer eats 0 meals a day at 0 a meal; the seed, read by a second
connection, is in every JVM's log). The null name, the null id and the empty `pauses` list add nothing: no term names them and there is
no join — said as the terms printed (asserted: no term holds the name, the id or the pause table). **A** — the same probe with
`ExampleMatcher.matching().withIgnorePaths("mealsPerDay", "pricePerMeal")`: one term, the meal type's — **Ravi and Sunil**. **A′** — A in
a fresh JVM, the same lines (R.1). The raw line's term count is derived from the raw line itself (the `QBE the raw line:` line), never
typed. The voice: "a probe: the example object" (RED #933; the harness's `PROBE` prefix stays in the capture — For RED).

## 2 · matcher — the matchers (S3.6, RED #910)

One harness JVM, five calls, one SELECT each. A **string matcher**: probe `new CustomerEntity("R", 0, 0, null)`, the two `int`s ignored,
`withIgnoreCase().withStringMatcher(CONTAINING)` → one term, `lower(…) like ?` with Spring Data's escape character (read off the log, in
the values line — R.227), `[Meera, Priya, Ravi]` (sorted by the harness). **`matchingAny()`** against **`matching()`** on one probe —
`new CustomerEntity("Meera", 0, 0, VEG)`, the two `int`s ignored: the same two terms, under `or` → `[Meera, Ravi, Sunil]`, under `and` →
0 rows (Meera is not vegetarian); the capture prints both normal forms' md5s and that they differ — the connective is in the hash.
`count(Example)` with probe A's example → a `count` of the ids, probe A's `where` clause, `2`. The fluent
`findBy(example, q -> q.sortBy(Sort.by("name")).first())` → probe A's `where` clause, `order by` the name (unique — S3.7), `fetch first ?
rows only`, `Optional[Ravi]`. Last, the normal form fed a planted line mixing `and` with `or`: `REFUSED`, `qbe.awk`'s exit 1.

## 3 · querydsl — the processor, the generated class, the predicates (⚑7, S3.17)

**The processor.** The anchor's three entity sources (copies, md5 each = the anchor's, printed) through `javac -proc:full -processorpath
"$AP"` into a fresh `.harness/q-run/`: exit 0, nothing printed; **the generated files counted by `find … -type f`** in the capture and
named — `com/tiffinbox/QCustomerEntity.java` and `com/tiffinbox/QPauseEntity.java`, their count in the values line, never typed — and
equal to the build's (`diff -r`). `QCustomerEntity.java`'s class line (`public class QCustomerEntity extends EntityPathBase<CustomerEntity>`)
and its `public final` fields, read off the file (their types and names in the values line). The jar lists of both POMs are printed
by name; Querydsl's version is read off them (`querydsl-apt`, `querydsl-jpa`, `querydsl-core` must agree). **The control:** the same
`javac`, the same jars on the class path alone, no processor flag — exit 0, nothing printed, **0** files (the entities' three classes and
no Q class; RED #901). **The queries** (one harness JVM): where the class loader found `EntityPathBase` and `JPAQueryFactory` (both in
`.m2-demo`, under `com/querydsl/…`) and `QCustomerEntity` (the processor's output); `findAll(c.mealType.eq(VEG).and(c.mealsPerDay.goe(2)))`
→ the meal type's and the meals' conditions, in the code's order, `[Ravi, Sunil]`; `findAll(c.name.containsIgnoreCase("r"), Sort.by("name"))`
→ `lower(…) like ?` with **Querydsl's** escape character — not Query by Example's (both in the values line, each read off its own log) —
and `order by` the name, `[Meera, Priya, Ravi]`; `count(c.name.containsIgnoreCase("r"))` → `3`; `new JPAQueryFactory(em).selectFrom(c)
.where(c.pauses.any().days.gt(1)).orderBy(c.name.asc()).fetch()` → `where exists(select 1 from pause …)`, `[Priya, Sunil]`.

## 4 · xcheck — the harness's DDL script, against the owning-side lesson's (R.212, RE-MEASURE 3)

`probe.x.XMain` — the anchor's entities alone (`@EntityScan("com.tiffinbox")`, no repository: `Found 0 JPA repository interfaces.`, no
seed), `scripts.action=create` into `.harness/run/hibernate-ddl.sql` (a file, never run): two `create table` lines and one `alter table`,
md5 **`f595637014e786fa38606859951e4f97`** = unit 09's published script md5 (its README names it; its `xcheck` capture `9072c6f1…`,
asserted) — no mapping moved since the owning-side lesson, as ⚑3 says for 18-22.

## 5 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s block, then `SOLUTION.md`'s, read from the files, in ONE `env -i` shell — `/bin/bash --noprofile --norc`, then the
same in `/bin/zsh -f`: the README's app (`ExApp`, in `probe.q.ex`, `@EntityScan("com.tiffinbox")`, the shipped `Database` on its own H2, a
repository of its own in the same file, and a runner that searches by example — the probe `new CustomerEntity(null, 0, 0, MealType.VEG)`,
`Example.of(probe)`) → `the JVM: exit 0`, `Found 1 JPA repository interface.`, **no vegetarian customer** (= `probe` B's rows, asserted),
the matcher ignoring nothing; the solution (one line: `Example.of(probe, ExampleMatcher.matching().withIgnorePaths("mealsPerDay",
"pricePerMeal"))`) → `exit 0`, **Ravi and Sunil** (= `probe` A's, asserted), the matcher ignoring the two paths. Both exit 0 — the probe's
mistake is silent — so broken ≠ solved is the rows, never the exit code. Bash and zsh print the same; the shell ends in this folder.
**Each exercise file's "What it prints" block is compared with what the run printed, line for line** (a placeholder, an empty block or
a changed line stops the run). The exercise's lines print no SQL line: the broken run's three-term line is in a JVM-dependent order
(S3.6; the normal form is the receipt's, not the viewer's) — What differed 6.

## Exercise

**Your turn:** the README searches by example for vegetarian customers and finds nobody. Make the example ignore what you never set.
(21 words, `wc -w`, R.203 — the brief's line, unchanged.) `exercise/README.md` and `exercise/SOLUTION.md`.

## The ledger rows and hand-offs this unit pays

- **Section 3 owns no ledger row** (`PROMISE-LEDGER-2026-11-01.md`); this unit settles none and opens none.
- **RE-MEASURE 1** (the exercise as files), **3** (xcheck), **9** (Query by Example's normal form, 3/3) and **10** (Querydsl and its
  processor resolved from `.m2-demo` seeded from s3, offline) — below.
- Hand-offs by title: *Criteria API and Specifications* (18) — called back in the choose table, by its capture's hash; *Bulk Updates and
  the Stale Context* (22) — next.

## RE-MEASURE — the brief's items this unit settles

| # | Settled here |
|---|---|
| 1 | the exercise as README + SOLUTION files, bash and zsh, `env -i`: 0 vegetarian customers, exit 0 / Ravi and Sunil, exit 0; each file's "What it prints" = the run |
| 3 | xcheck for 21: the harness's script with `@EntityScan("com.tiffinbox")` alone = `f5956370…` (unit 09's), on the frozen anchor |
| 9 | Query by Example's normal form 3/3 in every run of record (`probe` and `matcher`), the raw orders printed per JVM and never hashed; `and:` `30bbd0b1…` and `or:` `08bd46d2…` = BLUE's |
| 10 | Querydsl's apt and run-time jars resolved from `.m2-demo` seeded from s3, offline (`offline: yes`, 0 downloads), named one by one after `-processorpath`; the Q sources counted by `find`, the control's count beside them |

## What differed from the brief

1. **The processor runs from a `javac` line, not a harness POM with `<maven.compiler.proc>full</maven.compiler.proc>`.** The prompt
   allows either; this unit copies unit 18's mechanism (S3.17's "a javac line names `-processorpath`"): `harness/apt/pom.xml` (packaging
   `pom`, never compiled) only lists the apt jars by `dependency:build-classpath`, and the Q line names `-proc:full -processorpath "$AP"`.
   So the brief's plant "no `proc=full` in the harness POM" is run as its equivalent — the Q line without `-proc:full -processorpath`,
   `$AP` on the class path — and the `find` count stops the run (Planted faults). `${querydsl.version}` is written in both POMs, as ⚑7 says.
2. **The `fork` capture is cut.** `io.github.openfeign.querydsl` 7.7 is not in the s3 seed (⚑8 left its 48 files out) and this unit has
   no network. "A maintained fork exists" may be said in the script only as the setup brief's dated read — never as this unit's
   measurement; the recommendation is that the script cut it. Querydsl 5.1.0's release date is not said by this unit (the setup brief's,
   if at all).
3. **Two POMs, not one**: the processor path (`querydsl-apt:jakarta` + `jakarta.persistence-api`) and the run-time jars (`querydsl-jpa:jakarta`
   → `querydsl-core`, `mysema-commons-lang`) are listed apart, so the harness's class path holds no processor jar and the processor path
   holds what the probe's Step 11 named (the apt jar and the API by name). The processor path also carries `querydsl-core`,
   `querydsl-codegen`, `codegen-utils`, `ecj`, `classgraph`, `javax.inject`, `mysema-commons-lang` — Maven's list, printed by name.
4. **The control is a `javac` with every jar of both lists on the class path** (the anchor's libraries, `QR`, `AP`) and no processor flag,
   as unit 18's: exit 0, nothing printed, 0 files.
5. **`matcher`'s probes are the brief's, the two `int`s ignored in each** (the string matcher `"R"`, and `"Meera"` + VEG for `matchingAny()`):
   without `withIgnorePaths` the zeros would add their terms there too (the hook). `count(Example)` and the fluent `findBy` use probe A's
   example (`where` on the meal type alone); the brief named no probe for them.
6. **The exercise prints no SQL line**: its broken run's three-term line comes in a JVM-dependent order, so a "What it prints" block holding
   it could not match the run (S3.6). The exercise's app prints the customers it found and the paths its matcher ignores; the broken and
   the solved runs differ by the rows (0 vs Ravi and Sunil), both exit 0. The SQL is `probe`'s, in its normal form.
7. **A single-term line is written `and: [t]`** (the prompt's form for A): a raw line with one term has no connective; the `QBE the raw
   line:` line says "1 term, no connective" beside it.
8. **The normal form's mixed-line refusal is shown on a planted line inside `matcher`** (written by the script, labelled "never logged"),
   besides the self-test before any capture and the plant (a harness query that really logs a mixed line — Planted faults).
9. **`querydsl`'s SQL is hashed verbatim**: Querydsl writes its predicates in the code's order; 3/3 in every run of record.
10. **Rows of a query without an `order by` are printed sorted by the harness** (S3.7) and labelled so; the three ordered queries (the
    fluent `first()`, Querydsl's `Sort.by("name")` and `orderBy(c.name.asc())`) print theirs in the query's order — the name is unique.
11. **xcheck runs a context of its own, `probe.x.XMain`** (unit 18's form); its md5 is of the file as written.
12. **No TiffinBox JVM, no token**: the captures need neither (⚑3).
13. **The plants ran on scratch mirrors** (unit 18's form), each mirror running the whole `receipts.sh` as committed, four mirrors at a
    time; the raw-hash plant twice (with and without `probe`'s checks — Planted faults).

## Planted faults — each caught (R.65, R.226)

Each on a scratch mirror of this folder (its neighbours linked: `../c7-unit17`, `../c7-tiffinbox`, `../c7-unit09`, `../c7-unit18`; its
`.m2-demo` an APFS clone of this one's), one fault at a time, the mirror's whole `receipts.sh`, `env -i`, a session of its own, on the
script as committed; each **exit 1, nothing written to this folder**, the mirror's `receipts.md5` unchanged, no JVM of the mirror left.
The line that stopped each:

| plant | where | caught by |
|---|---|---|
| Query by Example's raw line hashed (the normal form bypassed: the log copied as it is), `probe`'s checks kept | `receipts.sh` | `probe B: one SELECT of the entity's five columns, its where clause in the normal form: …` (the raw line) — that mirror's three runs happened to log B in one order, so the 3/3 held and the check after it stopped the run |
| the same, `probe`'s checks dropped (S3.6's plant as the brief words it) | `receipts.sh` | `probe drifts across three runs (diff .r-probe.1 .r-probe.2 .r-probe.3)` — the raw orders differ between JVMs (above: six orders in 36 JVMs) |
| `matchingAny()` swapped for `matching()` (RED #910) | `harness/src` | `matcher: matchingAny() - the two terms under or (RED #910): where and: […]` |
| no `-proc:full -processorpath` (the Q line with `$AP` on the class path; README and script alike — S3.17) | `receipts.sh`, `README.md` | `the generated files: 0 (find .harness/qsrc -type f) - the processor never ran, and QCustomerEntity was not written (S3.17/R.248 …)` |
| `withIgnorePaths` in B | `harness/src` | `probe B: the two int zeros are values - the meal type's term and one for each int, under and (the hook): …` (one term) |
| a mixed `and … or` line logged (a derived `findByMealTypeAndMealsPerDayOrName` called in `matcher`) | `harness/src` | `matcher: a Query by Example line the normal form refuses (S3.6): REFUSED: …` |
| a wrong published hash (`probe`'s last digit) | `receipts.md5` | `probe is not the published capture …` (after its checks passed) |
| a version claim without `HHH000001` (`org.hibernate.orm.core` at WARN) | `harness/logback.xml` | `probe: the version lines - getVersionString(), Hibernate's HHH000001 and Spring Data JPA's 4.1.2 - once in each of its 3 harness JVMs` |
| a version claim without `4.1.2` (`Main.java`'s Spring Data line removed) | `harness/src` | the same check (S3.15) |
| an Indian dish name | `README.md` | `an Indian dish name (R.215: English names only)` (before any build) |
| a placeholder line in an exercise file (unit 16's own placeholder word, in its "What it prints" block) | `exercise/README.md` | `a placeholder line in this unit's prose - the exercise's blocks hold the measured output` |
| a changed line in a "What it prints" block (`[Ravi, Priya]`) | `exercise/SOLUTION.md` | `exercise/SOLUTION.md's "What it prints" block is not what the solution's lines printed` |
| a typed SQL string in prose | `README.md` | `a typed SQL string in README.md outside the choose table and the values line (R.225, R.227)` |
| a typed generated-file count | `README.md` | `a typed count of the processor's files - querydsl counts them by find, and only the values line states them` |
| xcheck: a wrong unit 09 md5 | `receipts.sh` | `../c7-unit09/README.md must name f595…4f98 - Boot's script md5 (R.212)` |
| a Querydsl field the generated file does not hold (`NumberPath<Integer>` with a made-up name) | `README.md` | `a Querydsl field in the prose that QCustomerEntity.java does not hold - read the generated file, never memory` |
| a duration word | `README.md` | `dur7.DUR found a duration word - this unit speaks no time (R.172)` |

**Not run:** the brief's fifth plant for 21, "the fork's jars on the upstream run → the provenance check fails" — the fork's jars are not
on this machine (What differed 2); the check it would trip (`EntityPathBase` must load from `com/querydsl/querydsl-core/…`) is in place.
The first try of the mixed-line plant did not compile (a quoting slip in the plant's own edit); it was re-made and run, the row above.

## Found on the way

- **BLUE's two hashes are reproduced exactly**: the md5 of `matchingAny()`'s normal form (the values line) is `08bd46d2a6f29a5d248c074fdfcbf79c`
  and of `matching()`'s `30bbd0b1aba49843df4d10cbf19e796d` — the brief's AMENDMENT names `08bd46d2` and `30bbd0b1`: BLUE hashed the same
  text (the where clause's normal form, no newline).
- **The raw orders vary within one run**: the first development run already showed the three-term line in three orders over its three
  `probe` B JVMs — the 3/3 a raw hash would need is not there (the plant below).
- **No `-processor` flag is needed** for the upstream apt jar: its `META-INF/services/javax.annotation.processing.Processor` entry is found on
  the processor path (the probe's Step 11, reproduced).

## CARRIED

- **The fork** (`io.github.openfeign.querydsl` 7.7) → not measured here (no seed, no network); a later brief that wants it seeds it first.
- **Querydsl in TiffinBox** (⚑11) → none planned; the processor stays in the harness.
- **Query by Example's term order** → a property of Spring Data JPA 4.1.2 on this JDK, measured, not explained (R.201): the normal form
  is this unit's answer; a later Spring Data version re-measures it.

## For RED

- **The fork**: cut (What differed 2); the plant "the fork's jars on the upstream run → the provenance check fails" cannot be run without
  the fork's jars — not run. The provenance check it would trip is in place (`EntityPathBase` must load from `com/querydsl/querydsl-core/…`).
- **The `PROBE` prefix** (RED #933): the harness prints `PROBE` on its own lines in every capture; the script glosses "a probe: the
  example object" and elides the prefix from those slides, the gap counted (R.205) — the script's concern, not this receipt's.
- **"The zero is a value"** rests on the terms printed (two `int` terms in B, none in A) and the rows (0 vs 2); that Spring Data skips
  only `null` fields is the code's reading (R.201). Ask whether the voice says "it ignores null" or only "it used the zeros".
- **The normal form is a rewrite of a logged line**: the slide shows `and: [...]`, not Hibernate's text. Ask whether the slide shows the
  raw line once, labelled "one of the orders", beside the normal form (the raw orders are on the terminal of every run, never hashed).
- **"Querydsl reads like the SQL it becomes"** — the three predicates' SQL is in the capture; the likeness is the voice's.
- **The escape characters**: Query by Example's `like` writes one escape character, Querydsl's another, the Criteria lesson's a third
  (values line; each read off its own log). Ask whether the slide quotes them (backslash / exclamation mark / empty) or leaves them out.
- **The processor's file count** (values line) is a Q source per entity class — `MealType`, an enum, gets none; ask whether the voice
  says the number or only "a Q class per entity".
