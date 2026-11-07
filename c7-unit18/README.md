# c7-unit18 — Criteria API and Specifications

Course 7 · Data with JPA & Hibernate · Section 3 (Querying), its fourth unit, and **the first on Section 3's frozen anchor — no change
to the anchor** (brief ⚑11): `anchor` is the link to `../c7-unit17/after`. Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot
4.1.2** (Spring Data JPA 4.1.2, Hibernate ORM 7.4.13.Final, hibernate-processor 7.4.13.Final, Jakarta Persistence 3.2.0, H2 2.5.250 —
the anchor's pin), 2026-11-07, **on H2 only** (brief ⚑2: 18 is an H2 unit; every capture says so in its own lines). A search with three
optional filters is three `if`s — or eight query methods. A **specification** is one filter as an object — one condition of a query's
`where` clause, built in code by JPA's Criteria API — and Spring Data JPA 4.1 combines the ones a search has and skips the ones it does
not. The field names in those conditions are strings, unless the compiler writes them: `hibernate-processor`, run by `javac` over the
entity sources, writes the **static metamodel**, a class per entity whose fields name the entity's fields. Measured: the same
`findAll(spec)` call with none, one, two and three filters; `Specification.allOf(list)` beside `unrestricted().and(…)`; `count(spec)` and
a page; the old idiom `where(null).and(…)` refused; a misspelt field name as a string failing at the call, and in the metamodel failing
`javac`; the processor running only when asked.

**No anchor change (brief ⚑11).** `anchor` → `../c7-unit17/after` (`readlink` asserted), Section 3's frozen anchor. `receipts.sh` prints
`diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox` at its start and end — empty in every run of record —
and, from any later anchor change on, prints a note instead (R.211). The anchor is copied under `.harness/anchor` and built there with
its README's package line (offline; its 18 tests run inside that build), its jar extracted with the anchor's own line; the harness runs
over those 91 libraries. The entity sources the processor reads — `CustomerEntity.java`, `MealType.java`, `PauseEntity.java` — are byte
copies of the anchor's (`.harness/ents/`, each md5 asserted equal to the frozen tree's, printed by `meta`). TiffinBox's build gains no
processor; TiffinBox itself is not started by this unit.

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
files, an APFS clone of the folder). Development runs (a scratch copy of this script, `.r-dev.sh`, git-ignored, whose two README gates
and the published-hash stop print instead of stopping) fixed the captures and the checks — Found on the way; the first full run wrote
every capture 3/3, and those md5s are `receipts.md5`. **The runs of record, on the script as committed (`receipts.sh` md5 `b099e22a73af2bab34d7682f7daa9272`): 186 s under
`./receipts.sh`** (/bin/bash 3.2.57, 2026-11-07 from 21:32 CET, beside the sealed clone's run) **and 158 s under `bash receipts.sh`**
(Homebrew bash 5.3.9, from 21:35 CET, beside the SIGINT trials): each exit 0, all 5 captures 3/3 = published, every check passed, both
builds `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`, the anchor note empty at the start and the end, nothing listening
on 18425, 8080, 35729 or 19970-19979 at the end; each terminal log through `check_unit7.py 18 --runlog` — `0 grep error line(s)`,
`RESULT (run logs): PASS` (the unit gate itself answers "no 18-*.md … nothing to check": no script yet). The builders'
`_builders/dur7.py` over this README and the exercise's two files: 0 duration words. **Nothing was downloaded**, and this unit made no
network act. **On the tree as committed** — this README final — one more `./receipts.sh` (`env -i`, a session of its own): exit 0 in 127 s (from 21:39 CET), all 5 = published, `--runlog` PASS.

Published hashes: spec `fb76cb020b6d2a5d304b2b24e25081da` · nulls `edeb043d2dd6b5365c50568f9a14ec74` · meta `3d52c5577cf64d7c7962e157cd55c676` · xcheck `aee0b2af0f4a4b538ea881066c683c22` · exercise `10587fb5836c27fb59bf9506347edd86`.

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line, R.225 — a SQL string, a
count of the processor's files or a number typed anywhere else is refused):

the values the video may say: the search, 4 calls, README.md's table composed from spec - none, one, two, three filters: one SELECT each · allOf(list) = unrestricted().and(...): yes (cmp of the two logged lines: equal) · count(spec): select count(ce1_0.id) from customer ce1_0 where lower(ce1_0.name) like ? escape '' -> 3 · findAll(spec, PageRequest.of(0, 1, Sort.by("name"))): 2 statements, total 3 · pages 3 · page 0: [Meera] · the Criteria like writes escape '' (spec), the derived Containing wrote escape '\' (the derived-query lesson's table, its derived capture 314e79d6305573120462d7a215f3557d) · where(null), on Spring Data JPA 4.1.2: java.lang.IllegalArgumentException: Specification must not be null, 0 statements; and(null): java.lang.IllegalArgumentException: Other specification must not be null · allOf(list): select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where lower(ce1_0.name) like ? escape '' · Specification: 13 members, 0 Deprecated (javap -v), the -Xlint:deprecation compile 0 warnings · the processor, hibernate-processor 7.4.13.Final with -proc:full -processorpath (19 jars): 13 files by find - CustomerEntity_.java, PauseEntity_.java and 11 in entity/index; on the class path alone: 0 · r.get("nmae"), at the call: org.springframework.dao.InvalidDataAccessApiUsageException: Could not resolve attribute 'nmae' of 'com.tiffinbox.CustomerEntity' <- org.hibernate.query.sqm.PathElementException: Could not resolve attribute 'nmae' of 'com.tiffinbox.CustomerEntity' · r.get(CustomerEntity_.name): select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where ce1_0.name=? · CustomerEntity_.nmae: javac exit 1, harness/src/probe/q/typo/MetaTypo.java:16: error: cannot find symbol · symbol: variable nmae · location: class CustomerEntity_ · xcheck: f595637014e786fa38606859951e4f97 · exercise: java.lang.IllegalArgumentException: Specification must not be null; allOf(filters): select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where lower(ce1_0.name) like ? escape '' and ce1_0.meals_per_day>=?, [Ravi] (23 words)

### The search table — composed from `spec`

The hook: the same `findAll(search(name, type, min))` call, the filters given growing one at a time — one SELECT each (the SQL logger's
lines and `Statistics`' `getPrepareStatementCount`, both 1, R.184). `search` collects the non-null filters into a list and hands it to
`Specification.allOf(list)`. The SELECT has no `order by`, so the rows are printed **sorted by the harness** (S3.7). Every row is
composed by `receipts.sh` from the capture and compared with this table — a SQL string typed here, or a row changed, is refused.
**For the deck builder:** the `like` condition ends `escape ''` — two single quotes, an empty escape character, as Hibernate writes
`cb.like` with none given; the derived-query lesson's `Containing` wrote `escape '\'` (one backslash inside single quotes) — quote each
from its own capture, never one for the other (both are in the values line).

<!-- spec: the search table -->
| filters | the call | the `where` clause Hibernate logged (from `customer ce1_0` on) | returned |
|---|---|---|---|
| 0 | `findAll(search(null, null, null))` | no where clause | 4 rows · names, sorted by the harness: [Meera, Priya, Ravi, Sunil] |
| 1 | `findAll(search("r", null, null))` | `where lower(ce1_0.name) like ? escape ''` | 3 rows · names, sorted by the harness: [Meera, Priya, Ravi] |
| 2 | `findAll(search("r", VEG, null))` | `where lower(ce1_0.name) like ? escape '' and ce1_0.meal_type=?` | 1 rows · names, sorted by the harness: [Ravi] |
| 3 | `findAll(search("r", VEG, 2))` | `where lower(ce1_0.name) like ? escape '' and ce1_0.meal_type=? and ce1_0.meals_per_day>=?` | 1 rows · names, sorted by the harness: [Ravi] |

Each SELECT names the entity's five columns before `from customer ce1_0` (asserted, not repeated here). The seed, read by a second
connection in every harness JVM: 1 Ravi VEG 2 meals a day, 2 Meera NON_VEG 1, 3 Sunil VEG 3, 4 Priya VEGAN 1.

### A sealed fresh clone — the recipe (R.129)

**Paste it into bash.** Unit 17's recipe, with this unit's folder:

```bash
S=/tmp/sealed18; W="/tmp/sealed 18"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
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
cd "$W/tiffinbox-java/c7-unit18" && readlink anchor && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E ./receipts.sh            # a process group of its own
```

**Run (2026-11-07, from 21:32 CET):** a `git clone` of tiffinbox-java at `d7c80f1` into a path **with a space** (`…/sealed 18/tiffinbox-java`,
in the session's scratch folder), this commit's change put in as git takes it (the 17 paths `git ls-files -o --exclude-standard` listed
— all under `c7-unit18/` — each `cmp`-equal to the working tree, `anchor` → `../c7-unit17/after` by `readlink`); a `file://` copy of the
s3 seed (5,023 files once `_remote.repositories`, `*.lastUpdated` and `resolver-status.properties` are left out); pre-flight: exit 1,
221 `Downloading from sealed: file://`, 0 from http(s); the clone's `.m2-demo` seeded from that copy; `/bin/bash` 3.2, `env -i` with the
dead proxies, a session of its own: **exit 0 in 185 s, all 5 = published, every check passed**; both builds `offline: yes · exit 0 ·
'Downloaded from' lines in its log: 0`; after the run `.m2-demo` held 5,023 files, 0 `_remote.repositories`. Its terminal log through
`--runlog`: PASS. (The clone's README was this file before its last prose was filled in; this README passes the same gates in the run on
the tree as committed.)

## The commands this unit adds

```
cd .harness/proc && mvn -o -B -Dmaven.repo.local="$M2" dependency:build-classpath -Dmdep.outputFile=cp.txt
javac -proc:full -processorpath "$PP" -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" -s .harness/msrc -d .harness/mcls .harness/ents/CustomerEntity.java .harness/ents/MealType.java .harness/ents/PauseEntity.java
javac -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:$PP" -s .harness/ctl/src -d .harness/ctl/cls .harness/ents/CustomerEntity.java .harness/ents/MealType.java .harness/ents/PauseEntity.java
javac -parameters -Xlint:deprecation -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:.harness/mcls" harness/src/probe/q/Filters.java harness/src/probe/q/Main.java harness/src/probe/q/Run.java harness/src/probe/q/Seed.java harness/src/probe/q/repo/Customers.java harness/src/probe/x/XMain.java
javac -d .harness/tc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:.harness/mcls" harness/src/probe/q/typo/MetaTypo.java
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../mcls:../anchor/tiffinbox-web/target/extracted/lib/*" probe.q.Main "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.x.XMain "${A[@]}"
```

**The processor's class path** (S3.17/R.248, RED #901): `harness/proc/pom.xml` names `org.hibernate.orm:hibernate-processor` alone, at the
version Boot's parent manages (no number typed); the first line asks Maven, offline, for the jars it needs — every one under `$M2`,
written to `.harness/proc/cp.txt` — and `PP` is that list (`PP=$(cat .harness/proc/cp.txt)`: each jar by name, joined by `:`, no
wildcard — a `lib/*` after `-processorpath` is not expanded, the probe's Step 11). **The metamodel line** runs the processor over the
anchor's entity sources with `-proc:full -processorpath "$PP"`, generated sources into `.harness/msrc` (`-s`), classes into
`.harness/mcls` (`-d`); the build keeps only the two metamodel classes there (the anchor's jar has the entities). **The control line** is
the same `javac` with the same jars on the class path alone and no processor flag — on JDK 25 it runs no processor and says nothing
(`meta` counts what it wrote). **The harness line** compiles the harness against the anchor's libraries and the metamodel classes, with
`-parameters` (as Boot's parent compiles TiffinBox) and `-Xlint:deprecation` (its output counted by `nulls`). **The typo line** compiles
`MetaTypo.java` alone — it names `CustomerEntity_.nmae`, and `javac` must refuse it. **The two java lines** run the harness and xcheck's
context from `.harness/run` (`V` the JVM flags — the scenario `-Ds=spec|nulls|meta` and the variant `-Dv=A|B` — and `A` the arguments,
R.193, each printed as `$ V=(…)` / `$ A=(…)`, `A` with `printf %q`). Every java line runs under `perl -e 'alarm 240; exec @ARGV'` (R.247:
macOS has no `timeout`; an alarm that fires ends the JVM with exit 142, which the runner refuses); the exercise's JVM under its own
alarm. The lines read from `anchor/README.md` (2, each asserted whole) are its package line, `mvn -B package`, and its extract line.
`meta` prints its processor run with `.harness/meta-run/` in place of `.harness/m` (a fresh folder each run); `javap` (the JDK's,
printed as it runs) reads `Specification` off `spring-data-jpa-4.1.2.jar`.

## The repository, and the network

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681 files; ⚑8: the s3 seed holds `hibernate-processor` 7.4.13.Final and
`jandex` 3.3.2, which the processor's class path needs). Two builds: the anchor's `package` (its 18 tests run) and the processor POM's
`dependency:build-classpath`; each `offline: yes` with 0 `Downloaded from` lines in every run of record (the label is derived from the
build log, never typed). After the anchor's build the script asserts `.m2-demo` holds `spring-boot-starter-parent-4.1.2.pom`,
`hibernate-core-7.4.13.Final.jar`, `spring-data-jpa-4.1.2.jar`, `h2-2.5.250.jar` and `hibernate-processor-7.4.13.Final.jar`. **At run
time** no JVM binds a port; every database is H2 in a JVM's memory (the harness's `jdbc:h2:mem:u18`, xcheck's `jdbc:h2:mem:x18`, the
exercise's `jdbc:h2:mem:ex`). **No network act**: the section's dated sweep is the brief's
(`../../../data-jpa-hibernate/_research/spring-boot-metadata-2026-11-07.xml`, md5 `2ccae19d…`: the 4.1 line ends 4.1.2, no 4.1.3;
`4.2.0-RC2` not GA — ⚑6, R.223). Spring Data JPA's version is printed by every harness JVM from its jar's manifest
(`JpaRepository.class.getPackage().getImplementationVersion()` → `4.1.2`), beside Hibernate's `HHH000001` line and
`Version.getVersionString()` (S3.15, R.246) — before the context starts; the processor names its own version in `javac`'s output
(`Note: Hibernate compile-time tooling 7.4.13.Final`, asserted).

## The locale

The JVM ignores `LC_ALL` on macOS: every JVM this script starts carries `-Duser.language=en -Duser.country=US` on its java line, and the
hygiene check refuses a java line without it (and one without its alarm).

## The folders, the harness and the ports

- `anchor` → `../c7-unit17/after` (a link; `readlink` asserted) — Section 3's frozen anchor, never built in place.
- `harness/` — `src/probe/q/Main.java` (a Spring Boot context, `WebApplicationType.NONE`: it binds no port; `@EntityScan("com.tiffinbox")`
  — the anchor's entities — and `@EnableJpaRepositories("probe.q.repo")`; the version lines before the context starts; a failed start
  printed as its class, message and each cause, exit 1), `src/probe/q/repo/Customers.java` (`extends JpaRepository<CustomerEntity, Long>,
  JpaSpecificationExecutor<CustomerEntity>` — nothing of its own), `src/probe/q/Filters.java` (the three filters, each a
  `Specification<CustomerEntity>`: `nameContains(text)` — `cb.like(cb.lower(r.get("name")), "%text%")`, `mealType(type)` — `cb.equal`,
  `minMeals(min)` — `cb.ge`; the field names as strings), `src/probe/q/Run.java` (one scenario per JVM; `search(name, type, min)` collects
  the non-null filters and returns `Specification.allOf(list)`; each call between `PROBE >>> label` and `PROBE <<< label · statements
  (getPrepareStatementCount) …` — Hibernate's Statistics cleared before each call; the rows of a `findAll(spec)` printed sorted by the
  harness, S3.7), `src/probe/q/Seed.java` (unit 17's, byte for byte: the shipped `Database` built in code on the run's own H2 URL; its
  `createAndSeed` seeds 1 Ravi, 2 Meera, 3 Sunil, 4 Priya and two pauses), `src/probe/q/typo/MetaTypo.java` (`CustomerEntity_.nmae` —
  compiled only by `meta`, and refused), `src/probe/x/XMain.java` (xcheck's context: `@EntityScan("com.tiffinbox")` alone, outside
  `probe.q`, so no repository and no seed), `src/probe/q/ex/ExApp.java` (the exercise's — compiled only by the exercise), `proc/pom.xml`
  (the processor's class path, above), `logback.xml` (one line per event, no stack trace — `%nopex`: the harness prints an exception's
  class, message and causes itself, R.241), `dur7.py` (the builders', byte for byte, md5 `41667fed…`). English names only (R.215): Ravi,
  Meera, Sunil, Priya.
- `exercise/` — `README.md`, `SOLUTION.md`.
- `.harness/` (git-ignored, rebuilt by every run): `anchor` (the copy, built, extracted); `proc` (the POM's copy, `cp.txt`); `ents` (the
  entity sources' copies); `msrc`, `mcls` (the build's metamodel); `hc` (the harness); `run` (the JVMs' working folder); `meta-run`, `ctl`,
  `tc` (`meta`'s own processor run, control and typo compile); the logs. `.r-NAME.1-3` while a capture runs; `.r-NAME.out` its result
  (git-ignored).
- **Ports (§P, 19970-19979): none bound.** All ten, and 18425 (TiffinBox's default), 8080 and 35729, are checked free at the start and the
  end; 19979 is the one the brief names "never bound" — and so is every other.

## Masks, filters and hygiene — every one, declared

Masks (awk `gsub` only, each with a planted self-test line before any capture): this folder → `…`, the folder above → `…/..`, home → `~`,
the user name → `<user>`; ` using Java <version>`; an identity hash → `@…`; the JDK proxy class's number → `$Proxy<n>`; an
EntityManager's identity → `SessionImpl(<n><open>)`; Spring Data's scan line's figure → `<n>`; H2's generated `CONSTRAINT_<n>`,
`CONSTRAINT_INDEX_<n>`. `meta` prints the processor's class path by its first jar with `.m2-demo`'s path as `$M2`; `xcheck` prints
Hibernate's generated foreign-key name as `FK<name>` (its md5 is taken of the file itself). Filters: a harness JVM's log is printed whole
(trailing spaces dropped); `javap` is counted or its member lines printed, never its header (a path, a date, a checksum); `javac`'s
output is printed whole. Hygiene, over every capture: no absolute path, unit number, log time, timestamp, thread number, JDK or OS token,
figure of elapsed time, stack frame, unmasked proxy number, identity or generated name, URL; every JVM pinned and under its alarm; no
kill by name, no bare `wait`, no one-string multi-option variable; no H2 database file (R.195); no dish name (R.215). The prose gates,
before any build: no duration word (dur7, R.172); no dish name; no placeholder line and no empty "What it prints" block in the exercise's
files; no Spring Data property exception named by its 3.x package (S3.10, RED #931); no Spring Data or Boot 2/3 version credited with
`where(null)` (RED #931); no typed count of the processor's files (S3.17, RED #902); no SQL string in this README outside the search
table and the values line (R.225). After `nulls`: no line claiming a `Deprecated` member of `Specification` while `javap` counts 0.

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the Maven or the
`javac` it waits for (`$mpid`, with every process under it), the exercise's shell (`$xpid`), sweeps its own process group for any harness
or exercise JVM (`probe.q.`, `probe.x.`), `javac` or Maven left, deletes the capture runs it had not finished (`.r-NAME.1-3`), and
removes `.r-lock`. The published captures are untouched. No `wait` in the script or the exercise is bare. Every `javac` runs like a
build — in the background, its pid in `$mpid`, waited for — so an interrupt during one is handled like an interrupt during Maven.

**Measured (2026-11-07, the sealed clone, the script as committed):** `./receipts.sh` (/bin/bash 3.2) started in a session of its own
**with SIGINT at its default** (`perl -MPOSIX -e '$SIG{INT}="DEFAULT"; setsid; exec …'` — a background job of a script inherits SIGINT
ignored: unit 15's README, Interrupted), `kill -INT` to its group once the named process was in it, the state read 5 s later — three
trials, each **exit 130, nothing left**:

```
build: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
javac: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
harness: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
```

`build` — the first Maven (the anchor's package, its Surefire fork); `javac` — the build's processor run (`javac -proc:full …`);
`harness` — the first harness JVM (`spec`, `probe.q.Main`). `pgrep -fl java` afterwards: none.

## 1 · spec — the search: none, one, two, three filters (the hook)

One harness JVM. The four calls of the search table, one SELECT each; the `where` clause grows by exactly the filter added (asserted:
the two-filter clause is the one-filter clause plus `and` the meal type's condition, the three-filter clause that plus the meals'
condition). Then the two ways to combine three filters: `Specification.allOf(nameContains("r"), mealType(VEG), minMeals(2))` and
`Specification.<CustomerEntity>unrestricted().and(nameContains("r")).and(mealType(VEG)).and(minMeals(2))` — **the same SQL, byte for
byte**, both equal to the search's three-filter SQL, the same rows (`[Ravi]`); `unrestricted()` alone — no `where` clause, four rows.
`count(nameContains("r"))` — one statement, a `count` of the ids with the same `where` clause, `3`. `findAll(nameContains("r"),
PageRequest.of(0, 1, Sort.by("name")))` — two statements: the page's SELECT (`order by` the name, `offset ? rows fetch first ? rows only`)
and then its count query; `total 3 · pages 3 · page 0: [Meera]` (*Paging and Sorting*, unit 20, named forward). Each statement count is
the SQL logger's lines and `Statistics` together (R.184); the SQL strings are in the values line.

## 2 · nulls — 4.x refuses null (the failure receipt; S3.9, S3.10)

First, the API read off Spring Data JPA's jar: `javap` of `org.springframework.data.jpa.domain.Specification` — its member lines (static
`unrestricted()`, `where(…)` in two forms, `not`, `allOf` and `anyOf` each for varargs and an `Iterable`; default `and`/`or` in two forms
each; `toPredicate`), the count in the values line; `javap -v` counts **0** `Deprecated` attributes and 0 `java/lang/Deprecated`
annotations; the harness's own `javac -Xlint:deprecation` compile (its `Specification` calls among the sources) printed nothing. Said
"on Spring Data JPA 4.1" with the version line beside it (S3.15). **B** (one JVM): the old idiom — `Specification.where(null)`, then
`.and(nameContains("r"))` (the `null` cast to `Specification<CustomerEntity>`: `where` has two one-argument forms) — refused **at the
call**, after its marker, before any SQL (0 statements, the JVM's exit 0 — a call failure, S3.9): **`java.lang.IllegalArgumentException:
Specification must not be null`**, no cause (class and message asserted, R.241); beside it `unrestricted().and(null)` →
`IllegalArgumentException: Other specification must not be null`, 0 statements. No version is credited with accepting the idiom (RED
#931: no other Spring Data jar on this machine). **A** and **A′** (two fresh JVMs): `Specification.allOf(List.of(nameContains("r")))` —
the filters the search has — the search table's one-filter SQL, `[Meera, Priya, Ravi]`; A′ prints what A printed.

## 3 · meta — strings vs the metamodel (S3.17)

**The processor.** The anchor's three entity sources (copies, md5 each = the anchor's, printed) through `javac -proc:full -processorpath
"$PP"` into a fresh `.harness/meta-run/`: exit 0, `Note: Hibernate compile-time tooling 7.4.13.Final`; **the generated files counted by
`find … -type f`** in the capture and named one by one — `com/tiffinbox/CustomerEntity_.java`, `com/tiffinbox/PauseEntity_.java` and the
processor's own index under `entity/index/` (named, not explained — R.201; its files' names begin with a dot, so only a `find`, never an
`ls`, sees them all); their counts are in the values line, never typed (RED #902), and the folder equals the build's (`diff -r`).
`CustomerEntity_.java`'s lines: `@StaticMetamodel(CustomerEntity.class)`, `@Generated("org.hibernate.processor.HibernateProcessor")`,
`public abstract class CustomerEntity_`, `public static volatile SingularAttribute<CustomerEntity, String> name;`. **The control:** the
same `javac`, the same jars on the class path alone, no processor flag — exit 0, nothing printed, **0** files (the entities' three
classes and no `CustomerEntity_`). **B** (one JVM): `r.get("nmae")` compiled (the string is not checked) and fails **at the call**, 0
statements: `org.springframework.dao.InvalidDataAccessApiUsageException: Could not resolve attribute 'nmae' of
'com.tiffinbox.CustomerEntity'` ← `org.hibernate.query.sqm.PathElementException` with the same message (class, message, first cause
asserted, S3.10). **A** and **A′** (two fresh JVMs): `CustomerEntity_.name`, as Hibernate filled it at start —
`com.tiffinbox.CustomerEntity#name(BASIC)`, its Java type `java.lang.String` — in `cb.equal(r.get(CustomerEntity_.name), "Ravi")`: one
SELECT, `where` on the name column, `[Ravi]`. **The refusal:** `MetaTypo.java`, `CustomerEntity_.nmae` — `javac` exit 1, `error: cannot
find symbol`, `symbol: variable nmae`, `location: class CustomerEntity_`, 0 classes written. The voice: a misspelt string compiles and
fails when the query is built; a misspelt metamodel field never compiles.

## 4 · xcheck — the harness's DDL script, against the owning-side lesson's (R.212, RE-MEASURE 3)

`probe.x.XMain` — the anchor's entities alone (`@EntityScan("com.tiffinbox")`, no repository: `Found 0 JPA repository interfaces.`, no
seed), `scripts.action=create` into `.harness/run/hibernate-ddl.sql` (a file, never run): two `create table` lines and one `alter table`,
md5 **`f595637014e786fa38606859951e4f97`** = unit 09's published script md5 (its README names it; its `xcheck` capture `9072c6f1…`,
asserted) — no mapping moved since the owning-side lesson, as ⚑3 says for 18-22.

## 5 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s block, then `SOLUTION.md`'s, read from the files, in ONE `env -i` shell — `/bin/bash --noprofile --norc`, then the
same in `/bin/zsh -f`: the README's app (`ExApp`, in `probe.q.ex`, `@EntityScan("com.tiffinbox")`, the shipped `Database` on its own H2, a
repository of its own in the same file, and a runner whose search has a name and a least number of meals but no meal type) →
`the JVM: exit 1`, `Found 1 JPA repository interface.`, `PROBE threw: java.lang.IllegalArgumentException: Specification must not be
null` — the refusal `nulls` B shows, nothing else, no SQL; the solution (one line: `Specification.allOf(filters)`) → `exit 0`, `Found 1`,
one SQL line with the name's and the meals' conditions and no meal type, `PROBE customers: [Ravi]`. Bash and zsh print the same; the
shell ends in this folder. **Each exercise file's "What it prints" block is compared with what the run printed, line for line** (unit
16 shipped two placeholder lines under such a heading; here a placeholder, an empty block or a changed line stops the run).

## Exercise

**Your turn:** the README's search passes a filter it does not have, and Spring Data four refuses it. Combine the filters it has.
(23 words, `wc -w`, R.203 — the brief's line, unchanged.) `exercise/README.md` and `exercise/SOLUTION.md`.

## The ledger rows and hand-offs this unit pays

- **Section 3 owns no ledger row** (`PROMISE-LEDGER-2026-11-01.md`); this unit settles none and opens none.
- **RE-MEASURE 1** (the exercise as files), **3** (xcheck for 18-22) and **10** (the processor resolved from `.m2-demo` seeded from s3,
  offline) — below.
- Hand-offs by title: *Projections: Four Kinds* (19); *Paging and Sorting* (20) — `spec`'s page and its count; *Query by Example and
  Querydsl* (21) — the other typed way to build a query, with its own processor.

## RE-MEASURE — the brief's items this unit settles

| # | Settled here |
|---|---|
| 1 | the exercise as README + SOLUTION files, bash and zsh, `env -i`: `Specification must not be null`, exit 1 / `[Ravi]`, exit 0; each file's "What it prints" = the run |
| 3 | xcheck for 18: the harness's script with `@EntityScan("com.tiffinbox")` alone = `f5956370…` (unit 09's), on the frozen anchor |
| 10 | `hibernate-processor` resolved from `.m2-demo` seeded from s3, offline (`offline: yes`, 0 downloads), its jars named one by one after `-processorpath` |

## What differed from the brief

1. **Three harness JVMs for `nulls`** (B, A, A′) and three for `meta` (B, A, A′) — the brief lists `nulls` as "B/A′"; A is run too, so
   A′ = A is a comparison of two fresh JVMs (R.1).
2. **The rows of a `findAll(spec)` are printed sorted by the harness**: the SELECT has no `order by` (the hook keeps the plain
   `findAll(spec)` call), so S3.7 forbids printing them in the database's order; the count of rows is printed beside them. The page has
   `Sort.by("name")` and prints its content as returned.
3. **`where(null)` is written `where((Specification<CustomerEntity>) null)`**: `Specification` declares `where(Specification)` and
   `where(PredicateSpecification)` (javap), so a bare `null` is ambiguous to `javac`. The exercise's broken line passes a `null`
   variable instead — `Specification.where(byType)` with `byType = null` — the same call at run time, no cast on screen.
4. **The string typo's first cause is `org.hibernate.query.sqm.PathElementException`**, not `UnknownPathException` (that is the JPQL
   typo's, unit 17); the class and message are read off the chain and asserted (S3.10, RED #914 lists `PathElementException` among
   `InvalidDataAccessApiUsageException`'s causes).
5. **The processor's file count is the one this unit's sources give** — the two metamodel sources and the index files under
   `entity/index`, each count in the values line, derived by `find`: the brief's "13 / 11 / 4 / 9 by which sources and which reading" —
   this unit compiles the three entity sources alone (the probe compiled its harness's own classes beside them). Most of the index's
   file names begin with a dot; `find` counts them all.
6. **The processor's jar list comes from Maven** (`dependency:build-classpath` on a POM that names the processor alone, offline) rather
   than typed paths: the list is explicit (each jar by name, asserted a `.jar` under `.m2-demo` and present) and its version is Boot's
   (no number typed); a second offline build, labelled like the first.
7. **The metamodel classes are the only generated output on the harness's class path**: the processor's run also compiles the three
   entity copies; the build deletes those three classes from `.harness/mcls`, so the JVMs map the anchor jar's own entities.
8. **`meta`'s processor run is a second one, into a fresh folder** — the build's run (for the harness's compile) is the first; the
   capture's is asserted equal to the build's by `diff -r`, so each of the three capture runs counts what it wrote itself.
9. **xcheck runs a context of its own, `probe.x.XMain`** (outside `probe.q`, so Boot's scan finds neither the harness's repository nor its
   seed); Hibernate's foreign-key name is printed masked (`FK<name>`) while the md5 is of the file as written.
10. **The derived lesson's `escape '\'` is read off unit 16's README** (its `findByNameContainingIgnoreCase("r")` row), with 16's `derived`
    capture hash asserted, not re-run — as unit 17 read 16's typo message.
11. **The exercise's search has a name and a least number of meals, no meal type** (the brief: "`allOf(filters)` → `where lower(…) like ? …`") — the solution's SQL is the name's condition and the meals' condition, `[Ravi]`.
12. **No TiffinBox JVM, no token**: the unit's captures need neither (⚑3: harness units vary queries, not routes), so the demo-token
    machinery of units 15-17 is not here; the ports are checked free and none is bound.
13. **The plants ran on scratch mirrors** (as units 15-17), each mirror's script keeping `spec` (later checks read its values) and the
    planted capture; a gate plant stops before any build.

## Planted faults — each caught (R.65)

Each on a scratch mirror of this folder (its neighbours linked: `../c7-unit17`, `../c7-tiffinbox`, `../c7-unit09`, `../c7-unit16`; its
`.m2-demo` an APFS clone of this one's), one fault at a time, the mirror's `receipts.sh` keeping only `spec` and the planted fault's
capture(s) (What differed 13), `env -i`, a session of its own; each **exit 1, nothing written to this folder**, no JVM of the mirror left
(`pgrep -fl java`: none). The line that stopped each:

| plant | where | caught by |
|---|---|---|
| `where(null)` in A (`nulls` A's call `Specification.where(null).and(nameContains("r"))`) | `harness/src` | `nulls A/A': 1 statements - the SQL log's lines (0) and getPrepareStatementCount() (0) both (R.184)` |
| the processor on the class path only (the metamodel's line: `-proc:full -processorpath "$PP"` dropped, `$PP` on `-cp`) | `receipts.sh`, `README.md` | `the generated files: 0 (find .harness/msrc -type f) - the processor never ran, and CustomerEntity_ was not written (S3.17/R.248 …)` |
| the metamodel's typo compiled (`MetaTypo.java`: `CustomerEntity_.name`) | `harness/src` | `meta: CustomerEntity_.nmae - javac must refuse it, exit 1: exit 0` |
| a `Deprecated` claimed ("the static where method" said deprecated, in section 2) | `README.md` | `a line says something in Specification is … - javap counts 0 Deprecated attributes in it on Spring Data JPA 4.1.2 (nulls)` (after `nulls`) |
| a typed SQL `where` clause in the search table (row 2's `escape ''` dropped) | `README.md` | `README.md's search table is not the capture's - each row is composed from spec …` |
| a typed SQL string in prose (a `where` on the name column, in section 1) | `README.md` | `a typed SQL string in README.md outside the search table and the values line (R.225, R.227)` (before any build) |
| a typed generated-file count (the index's count, typed in section 3) | `README.md` | `a typed count of the processor's files - meta counts them by find, and only the values line states them (R.225, S3.17)` |
| `unrestricted().and` made to differ from `allOf` (the chain's last `.and(minMeals(2))` dropped) | `harness/src` | `spec: Specification.allOf(three filters) and unrestricted().and(...).and(...).and(...) must log the same SQL, byte for byte …` |
| a wrong published hash (`spec`'s last digit) | `receipts.md5` | `spec is not the published capture …` (after its checks passed) |
| a version claim without `HHH000001` (`org.hibernate.orm.core` at WARN) | `harness/logback.xml` | `spec: the version lines - getVersionString(), Hibernate's HHH000001 and Spring Data JPA's 4.1.2 - once in each of its 1 harness JVMs (R.222, S3.15/R.246)` |
| a version claim without `4.1.2` (`Main.java`'s Spring Data line removed) | `harness/src` | the same check (S3.15) |
| an Indian dish name | `README.md` | `an Indian dish name (R.215: English names only)` |
| a duration word | `README.md` | `dur7.DUR found a duration word - this unit speaks no time (R.172)` |
| a placeholder line in an exercise file (unit 16's own placeholder word, put back in its "What it prints" block) | `exercise/README.md` | `a placeholder line in this unit's prose - the exercise's blocks hold the measured output` (before any build) |
| a changed line in a "What it prints" block (`[Ravi, Sunil]`) | `exercise/SOLUTION.md` | `exercise/SOLUTION.md's "What it prints" block is not what the solution's lines printed` |
| xcheck: a wrong unit 09 md5 | `receipts.sh` | `../c7-unit09/README.md must name f595…4e98 - Boot's script md5 (R.212)` |
| exercise: the solution's `sed` matches nothing | `exercise/SOLUTION.md` | `exercise: the solution - allOf(filters), the customers it finds: expected the line: the JVM: exit 0` |

The brief's four for 18 (its line 529) are the first four rows; one per capture class: `spec` (the chain), `nulls` (`where(null)` in
A), `meta` (the typo compiled; the processor on the class path), `xcheck` (unit 09's md5), `exercise` (the `sed`; a block's line).

## Found on the way

- **A folder name is a duration word** to `dur7.py`: the first draft named the processor's source folder by the two-letter abbreviation
  of a thousandth of a time unit, and the prose gate stopped the run on this README's command lines; renamed `msrc` / `mcls`.
- **A path with a space**: the first draft checked the processor's jars with `for f in $(…)`, which split this folder's path
  (`Youtube Content`); the check now reads the list one line at a time.
- **The index's file names begin with a dot** (`entity/index/.VEG` …): an `ls` of the folder shows only the two without one; the count is `find`'s.
- **`Specification.where(null)` does not compile** without a cast (two one-argument `where` forms) — What differed 3.
- **The string typo fails with `PathElementException`** under `InvalidDataAccessApiUsageException` — What differed 4.

## CARRIED

- **Hibernate's static metamodel in TiffinBox** (⚑11's loser) → U39's brief, if the capstone's `@DataJpaTest` wants typed criteria.
- **The processor's `entity/index` files** — named, not explained (R.201); a later unit that explains them captures what reads them.
- **Querydsl's processor** (21) — the same S3.17 discovery rule, its own POM property; 21's agent measures it.

## For RED

- **"Spring Data four refuses it"** rests on 4.1.2's `IllegalArgumentException` (the version line in the same JVM); nothing here says
  which version first refused it. Ask whether the spoken "four" is narrow enough, or the slide should say "4.1".
- **"Byte for byte"** is the two logged SQL lines compared as strings (`allOf` vs the `unrestricted().and` chain); the bound values are
  not logged. Ask whether a slide may say "the same query" or only "the same SQL".
- **"Fails at the call"** for `r.get("nmae")` is the log's order (after the marker, 0 statements, exit 0); that Hibernate resolves the
  path when the query is built is the code's reading (R.201). Ask whether the voice says "when the query is built" or only "at the call".
- **The processor's count** depends on which sources it reads (What differed 5); ask whether the voice says the number at all, or only
  "two metamodel classes and an index".
- **The control shows a silent build** — exit 0, no line, no `CustomerEntity_` — and the harness would then fail to compile; this unit's
  build stops on the `find` count before that (plant). Ask whether the slide shows the control's empty output or its missing class.
- **The exercise's broken line is not the brief's literal `where(null).and(…)`** but `where(byType)` with `byType = null` (What differed
  3); ask whether the spoken line still fits.
