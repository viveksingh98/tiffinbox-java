# c7-unit19 — Projections: Four Kinds

Course 7 · Data with JPA & Hibernate · Section 3 (Querying), its fifth unit, and **the second on Section 3's frozen anchor — no change
to the anchor** (brief ⚑11): `anchor` is the link to `../c7-unit17/after`. Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot
4.1.2** (Spring Data JPA 4.1.2, Hibernate ORM 7.4.13.Final, Jakarta Persistence 3.2.0, H2 2.5.250 — the anchor's pin), 2026-11-07, **on
H2 only** (brief ⚑2: 19 is an H2 unit; every capture says so in its own lines). Most screens need two fields, not the entity. Spring
Data can hand back an interface, a record or a type picked per call — a **projection** — and whether the SELECT shrinks depends on
which. Measured: the same derived query, the vegetarian customers, returned as a closed interface (its getters are entity properties),
an open one (a `@Value` SpEL expression over the whole entity), a record, and `findByMealType(type, Class<T>)` with three types; a
nested projection outside a transaction and inside one; `Tuple` and `Object[]` beside them. Every claim about a SELECT has two
witnesses (S3.8): the column list of the SELECT the SQL logger printed for that call, counted by the script from the line itself, and
Hibernate's `Statistics` entity load count for the same call.

**No anchor change (brief ⚑11).** `anchor` → `../c7-unit17/after` (`readlink` asserted), Section 3's frozen anchor. `receipts.sh` prints
`diff -rq -x .m2-demo -x target -x secrets -x .harness anchor/ ../c7-tiffinbox` at its start and end — empty in every run of record —
and, from any later anchor change on, prints a note instead (R.211). The anchor is copied under `.harness/anchor` and built there with
its README's package line (offline; its 18 tests run inside that build), its jar extracted with the anchor's own line; the harness runs
over those 91 libraries and maps the jar's own entities. TiffinBox itself is not started by this unit.

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
files, an APFS clone of the folder). A development run (a scratch copy of this script, `.r-dev.sh`, git-ignored, whose table and values
gates and the published-hash stop print instead of stopping) wrote every capture 3/3, and those md5s are `receipts.md5`. **The runs of
record, on the script as committed (`receipts.sh` md5 `cd5ff20dfafa32b39fcf5f25b9e157b6`): 137 s under `./receipts.sh`** (/bin/bash
3.2.57, 2026-11-07 from 22:01 CET, beside the sealed clone's run) **and 144 s under `bash receipts.sh`** (Homebrew bash 5.3.9, from
22:04 CET, beside the SIGINT trials): each exit 0, all 5 captures 3/3 = published, every check passed, the build `offline: yes · exit 0
· 'Downloaded from' lines in its log: 0`, the anchor note empty at the start and the end, nothing listening on 18425, 8080, 35729 or
19980-19989 at the end; each terminal log through `check_unit7.py 19 --runlog` — `0 grep error line(s)`, `RESULT (run logs): PASS` (the
unit gate itself answers "no 19-*.md … nothing to check": no script yet). The builders' `_builders/dur7.py` over this README and the
exercise's two files: 0 duration words. **Nothing was downloaded**, and this unit made no network act. **On the tree as committed** — this README final — one more `./receipts.sh` (`env -i`, a session of its own): exit 0 in 104 s (from 22:10 CET), all 5 = published, `--runlog` PASS.

Published hashes: four `13f0a3e9aa9e1fbe8c6348ab93a59adb` · nested `cd383f77e49b18a1114da8da4512d9c3` · tuple `8adc62d4efea34aff526c53f7f16f16f` · xcheck `523707c349df0263d0a3fc020840fe43` · exercise `cf26ba383ba984f02bf0508bdd3b8ace`.

**The values the video may say** (composed by `receipts.sh` from the checks' reads and compared with this line, R.225 — a SQL string or
a column count typed anywhere else is refused):

the values the video may say: the projections, 6 calls, README.md's table composed from four - the same rows each time, sorted by the harness: [Ravi VEG, Sunil VEG] · the closed interface: select ce1_0.name,ce1_0.meal_type from customer ce1_0 where ce1_0.meal_type=? (2 columns, 0 entity loads, a JDK proxy) · the open interface (@Value): select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where ce1_0.meal_type=? (5 columns, 2 entity loads) · the record: 2 columns, 0 entity loads · dynamic with NameAndType / NameDto / CustomerEntity: 2 / 2 / 5 columns · four SELECTs: 4 SELECT lines from four calls · nested outside a transaction: org.hibernate.LazyInitializationException: Cannot lazily initialize collection of role 'com.tiffinbox.CustomerEntity.pauses' with key '1' (no session) · nested in a TransactionTemplate: 1 + 2 SELECTs = 3 statements, each further one select p1_0.customer_id,p1_0.id,p1_0.days from pause p1_0 where p1_0.customer_id=? · Tuple (aliases [name, mealType]) and Object[] (length 2): select ce1_0.name,ce1_0.meal_type from customer ce1_0 where ce1_0.meal_type=?, the closed interface's byte for byte · xcheck: f595637014e786fa38606859951e4f97 · exercise: the open Row 5 columns; closed, 2 columns: select ce1_0.name,ce1_0.meal_type from customer ce1_0 where ce1_0.meal_type=?, [Ravi VEG, Sunil VEG] (23 words)

### The projection table — composed from `four`

The hook and the four kinds: the same derived query (`where` on the meal type, the vegetarian customers, Ravi and Sunil) six times,
each with another return type — one SELECT each (the SQL logger's lines and `Statistics`' `getPrepareStatementCount`, both 1, R.184).
The column list is the SELECT line's own, between `select` and `from customer ce1_0`; **how many** is that list counted by the script;
**entity loads** is `Statistics.getEntityLoadCount()` for that call — S3.8's two witnesses side by side. A derived query has no `order
by`, so the rows are printed **sorted by the harness** (S3.7): the same two each time. Every row is composed by `receipts.sh` from the
capture and compared with this table — a column list or a count typed here, or a row changed, is refused.

<!-- four: the projection table -->
| kind | the call | the column list Hibernate logged | how many | entity loads | what came back |
|---|---|---|---|---|---|
| closed | `findNamesByMealType(VEG)` | `ce1_0.name,ce1_0.meal_type` | 2 | 0 | `jdk.proxy2.$Proxy<n>` |
| open | `findLabelsByMealType(VEG)` | `ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal` | 5 | 2 | `jdk.proxy2.$Proxy<n>` |
| record | `findDtosByMealType(VEG)` | `ce1_0.name,ce1_0.meal_type` | 2 | 0 | `probe.q.repo.NameDto` |
| dynamic | `findByMealType(VEG, NameAndType.class)` | `ce1_0.name,ce1_0.meal_type` | 2 | 0 | `jdk.proxy2.$Proxy<n>` |
| dynamic | `findByMealType(VEG, NameDto.class)` | `ce1_0.name,ce1_0.meal_type` | 2 | 0 | `probe.q.repo.NameDto` |
| dynamic | `findByMealType(VEG, CustomerEntity.class)` | `ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal` | 5 | 2 | `com.tiffinbox.CustomerEntity` |
"Four SELECTs" (R.187) is the SELECT lines the first four calls logged — closed, open, record, dynamic with one type — counted (the
values line). `jdk.proxy2.$Proxy<n>` is a JDK proxy (`java.lang.reflect.Proxy.isProxyClass`, printed `true`), the proxy class's number
masked; the voice calls it "a proxy" — *The Persistence Context* (unit 04) glossed the word (RED #903). The seed, read by a second
connection in every harness JVM: 1 Ravi VEG 2 meals a day, 2 Meera NON_VEG 1, 3 Sunil VEG 3, 4 Priya VEGAN 1; two pauses, Sunil's of
three days and Priya's of two.

### A sealed fresh clone — the recipe (R.129)

**Paste it into bash.** Unit 18's recipe, with this unit's folder:

```bash
S=/tmp/sealed19; W="/tmp/sealed 19"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
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
cd "$W/tiffinbox-java/c7-unit19" && readlink anchor && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E ./receipts.sh            # a process group of its own
```

**Run (2026-11-07, from 22:02 CET):** a `git clone` of tiffinbox-java at `8214993` into a path **with a space** (`…/sealed 19/tiffinbox-java`,
in the session's scratch folder), this commit's change put in as git takes it (the 18 paths `git ls-files -o --exclude-standard` listed
— all under `c7-unit19/` — each `cmp`-equal to the working tree, `anchor` → `../c7-unit17/after` by `readlink`); a `file://` copy of the
s3 seed (5,023 files once `_remote.repositories`, `*.lastUpdated` and `resolver-status.properties` are left out); pre-flight: exit 1,
221 `Downloading from sealed: file://`, 0 from http(s); the clone's `.m2-demo` seeded from that copy; `/bin/bash` 3.2, `env -i` with the
dead proxies, a session of its own: **exit 0 in 145 s, all 5 = published, every check passed**; the build `offline: yes · exit 0 ·
'Downloaded from' lines in its log: 0`; after the run `.m2-demo` held 5,023 files, 0 `_remote.repositories`. Its terminal log through
`--runlog`: PASS. (The clone's README was this file before its last prose was filled in; this README passes the same gates in the run on
the tree as committed.)

## The commands this unit adds

```
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/src/probe/q/Main.java harness/src/probe/q/Run.java harness/src/probe/q/Seed.java harness/src/probe/q/repo/Customers.java harness/src/probe/q/repo/Label.java harness/src/probe/q/repo/NameAndType.java harness/src/probe/q/repo/NameDto.java harness/src/probe/q/repo/WithPauses.java harness/src/probe/x/XMain.java
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 "${V[@]}" -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.q.Main "${A[@]}"
perl -e 'alarm 240; exec @ARGV' java -Duser.language=en -Duser.country=US -Dstdout.encoding=UTF-8 -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*" probe.x.XMain "${A[@]}"
```

**The harness line** compiles the harness against the anchor's libraries with `-parameters` (as Boot's parent compiles TiffinBox: the
record's constructor parameter names and the `@Param` names are read at run time). **The two java lines** run the harness and xcheck's
context from `.harness/run` (`V` the JVM flags — the scenario `-Ds=four|nested|tuple` and the variant `-Dv=A|B` — and `A` the arguments,
R.193, each printed as `$ V=(…)` / `$ A=(…)`, `A` with `printf %q`). Every java line runs under `perl -e 'alarm 240; exec @ARGV'` (R.247:
macOS has no `timeout`; an alarm that fires ends the JVM with exit 142, which the runner refuses); the exercise's JVM under its own
alarm. The lines read from `anchor/README.md` (2, each asserted whole) are its package line, `mvn -B package`, and its extract line.

## The repository, and the network

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s3/` alone (6,681 files, an APFS clone of the folder). One build: the anchor's
`package` (its 18 tests run); `offline: yes` with 0 `Downloaded from` lines in every run of record (the label is derived from the build
log, never typed). After it the script asserts `.m2-demo` holds `spring-boot-starter-parent-4.1.2.pom`, `hibernate-core-7.4.13.Final.jar`,
`spring-data-jpa-4.1.2.jar` and `h2-2.5.250.jar`. **At run time** no JVM binds a port; every database is H2 in a JVM's memory (the
harness's `jdbc:h2:mem:u19`, xcheck's `jdbc:h2:mem:x19`, the exercise's `jdbc:h2:mem:ex`). **No network act**: the section's dated sweep
is the brief's (`../../../data-jpa-hibernate/_research/spring-boot-metadata-2026-11-07.xml`, md5 `2ccae19d…`: the 4.1 line ends 4.1.2, no
4.1.3; `4.2.0-RC2` not GA — ⚑6, R.223). Spring Data JPA's version is printed by every harness JVM from its jar's manifest
(`JpaRepository.class.getPackage().getImplementationVersion()` → `4.1.2`), beside Hibernate's `HHH000001` line and
`Version.getVersionString()` (S3.15, R.246) — before the context starts — and asserted once per harness JVM in every capture.

## The locale

The JVM ignores `LC_ALL` on macOS: every JVM this script starts carries `-Duser.language=en -Duser.country=US` on its java line, and the
hygiene check refuses a java line without it (and one without its alarm).

## The folders, the harness and the ports

- `anchor` → `../c7-unit17/after` (a link; `readlink` asserted) — Section 3's frozen anchor, never built in place.
- `harness/` — `src/probe/q/Main.java` (unit 18's, its Javadoc's repository sentence changed: a Spring Boot context,
  `WebApplicationType.NONE`: it binds no port; `@EntityScan("com.tiffinbox")` — the anchor's entities — and
  `@EnableJpaRepositories("probe.q.repo")`; the version lines before the context starts; a failed start printed as its class, message
  and each cause, exit 1), `src/probe/q/repo/Customers.java` (`extends JpaRepository<CustomerEntity, Long>`: `findNamesByMealType`
  → `List<NameAndType>`, `findLabelsByMealType` → `List<Label>`, `findDtosByMealType` → `List<NameDto>`, `<T> List<T>
  findByMealType(MealType, Class<T>)`, `findWithPausesByMealType` → `List<WithPauses>`; `tuplesByMealType` → `List<Tuple>` and
  `arraysByMealType` → `List<Object[]>`, each `@Query("select c.name as name, c.mealType as mealType from CustomerEntity c where
  c.mealType = :type")` — the word between `find` and `By` is ignored by Spring Data's parser), `src/probe/q/repo/NameAndType.java`
  (closed: `getName()`, `getMealType()`), `src/probe/q/repo/Label.java` (open: `@Value("#{target.name + ' ' + target.mealType}")
  getLabel()`), `src/probe/q/repo/NameDto.java` (`record NameDto(String name, MealType mealType)`), `src/probe/q/repo/WithPauses.java`
  (`getName()`, `List<DaysOnly> getPauses()`, `DaysOnly { int getDays(); }`), `src/probe/q/Run.java` (one scenario per JVM; each call
  between `PROBE >>> label` and `PROBE <<< label · statements (getPrepareStatementCount) … · entity loads … · queries …` — Hibernate's
  Statistics cleared before each call; what came back printed as its size, the class of its first element, whether that is a JDK
  proxy, and the rows sorted by the harness, S3.7; the nested A inside `new TransactionTemplate(transactionManager).execute(…)`; the
  pauses read back by a second connection), `src/probe/q/Seed.java` (unit 18's, byte for byte: the shipped `Database` built in code on
  the run's own H2 URL; its `createAndSeed` seeds 1 Ravi, 2 Meera, 3 Sunil, 4 Priya and two pauses), `src/probe/x/XMain.java` (unit
  18's, byte for byte: xcheck's context, `@EntityScan("com.tiffinbox")` alone, outside `probe.q`, so no repository and no seed),
  `src/probe/q/ex/ExApp.java` (the exercise's — compiled only by the exercise), `logback.xml` (unit 18's, its comment's first words
  changed: one line per event, no stack trace — `%nopex`: the harness prints an exception's class, message and causes itself, R.241),
  `dur7.py` (the builders', byte for byte, md5 `41667fed…`). English names only (R.215): Ravi, Meera, Sunil, Priya.
- `exercise/` — `README.md`, `SOLUTION.md`.
- `.harness/` (git-ignored, rebuilt by every run): `anchor` (the copy, built, extracted); `hc` (the harness); `run` (the JVMs' working
  folder); `ex` (the exercise's); the logs. `.r-NAME.1-3` while a capture runs; `.r-NAME.out` its result (git-ignored).
- **Ports (§P, 19980-19989): none bound.** All ten, and 18425 (TiffinBox's default), 8080 and 35729, are checked free at the start and the
  end; 19989 is the one the brief names "never bound" — and so is every other.

## Masks, filters and hygiene — every one, declared

Masks (awk `gsub` only, each with a planted self-test line before any capture): this folder → `…`, the folder above → `…/..`, home → `~`,
the user name → `<user>`; ` using Java <version>`; an identity hash → `@…`; the JDK proxy class's number → `$Proxy<n>`; an
EntityManager's identity → `SessionImpl(<n><open>)`; Spring Data's scan line's figure → `<n>`; H2's generated `CONSTRAINT_<n>`,
`CONSTRAINT_INDEX_<n>`. `xcheck` prints Hibernate's generated foreign-key name as `FK<name>` (its md5 is taken of the file itself).
Filters: a harness JVM's log is printed whole (trailing spaces dropped). Hygiene, over every capture: no absolute path, unit number, log
time, timestamp, thread number, JDK or OS token, figure of elapsed time, stack frame, unmasked proxy number, identity or generated name,
URL; every JVM pinned and under its alarm; no kill by name, no bare `wait`, no one-string multi-option variable; no H2 database file
(R.195); no dish name (R.215). The prose gates, before any build: no duration word (dur7, R.172); no dish name; no placeholder line and
no empty "What it prints" block in the exercise's files; no Spring Data property exception named by its 3.x package (S3.10, RED #931);
no SQL string (a line holding Hibernate's table aliases) in this README or the exercise's files outside the projection table, the values
line and the exercise's measured blocks (R.225); no column count typed unless the line names its projection. After `four`: each line
that gives a projection a column count is held against both of S3.8's witnesses for that kind — the SELECT's list counted, the entity
loads — and a count either witness contradicts stops the run.

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the Maven or the
`javac` it waits for (`$mpid`, with every process under it), the exercise's shell (`$xpid`), sweeps its own process group for any harness
or exercise JVM (`probe.q.`, `probe.x.`), `javac` or Maven left, deletes the capture runs it had not finished (`.r-NAME.1-3`), and
removes `.r-lock`. The published captures are untouched. No `wait` in the script or the exercise is bare.

**Measured (2026-11-07, the sealed clone, the script as committed):** `./receipts.sh` (/bin/bash 3.2) started in a session of its own
**with SIGINT at its default** (`perl -MPOSIX -e '$SIG{INT}="DEFAULT"; setsid; exec …'` — a background job of a script inherits SIGINT
ignored: unit 15's README, Interrupted), `kill -INT` to its group once the named process was in it, the state read 5 s later — three
trials, each **exit 130, nothing left**:

```
build: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
harness: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
exercise: processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
```

`build` — the Maven (the anchor's package); `harness` — the first harness JVM (`four`, `probe.q.Main`); `exercise` — the exercise's JVM
(`probe.q.ex.ExApp`, under its shell). `pgrep -fl java` afterwards: none.

## 1 · four — the four kinds (the hook; S3.8)

One harness JVM. The projection table's six calls, one SELECT each, the same `where` clause, the same two customers. **Closed**
(`NameAndType`): the SELECT asks for the name and the meal type alone, nothing is loaded as an entity, and what comes back is a JDK
proxy over the row. **Open** (`Label`, `@Value("#{target.name + ' ' + target.mealType}")`): the same labels, but the SELECT names every
column the entity maps and both customers are loaded as entities — SpEL reads `target`, the whole entity, so Spring Data cannot know
which fields it needs. **Record** (`NameDto`): the closed interface's SELECT, no entity, a plain object (`probe.q.repo.NameDto`, not a
proxy). **Dynamic** (`findByMealType(VEG, Class<T>)`): the type picked per call decides — `NameAndType.class` and `NameDto.class` ask
for the name and the meal type, `CustomerEntity.class` for every column, and loads the entities. The hook (the closed and the open interface's
column lists) and every count are in the table and the values line, composed from the capture.

## 2 · nested — a projection inside a projection (the failure receipt; S3.2, S3.9, S3.10)

`WithPauses { getName(); List<DaysOnly> getPauses(); }`, the pauses read back first by a second connection (two pauses, Sunil's and
Priya's). **B** (one JVM, no transaction): `findWithPausesByMealType(VEG)` runs its one SELECT — every column, a nested projection is
open — and the first `getPauses()` fails **at the call**, after that statement, the JVM's exit 0 (a call failure, S3.9):
`org.hibernate.LazyInitializationException: Cannot lazily initialize collection of role 'com.tiffinbox.CustomerEntity.pauses' with key
'1' (no session)`, no cause (class and message asserted, the key read off the capture, R.241). A derived query carries no transaction of
its own: the session closed when the repository call returned (S3.2). **A** and **A′** (two fresh JVMs): the same call and every
`getPauses()` inside one `TransactionTemplate` — the customers' SELECT, then one SELECT of the pause table per customer returned, the
statement count read off the log and `Statistics` together and asserted to be 1 + that number of customers; `[Ravi [], Sunil [3]]`;
A′ prints what A printed. One query per row is the shape *N+1, Measured* (unit 30) measures — named forward by title only.

## 3 · tuple — the refused fifth

One harness JVM: the closed interface's call again, then `tuplesByMealType(VEG)` → `List<Tuple>` and `arraysByMealType(VEG)` →
`List<Object[]>`, each from a JPQL query with aliases. **The three SQL lines are byte for byte equal** (asserted, and equal to `four`'s
closed interface's) — `Tuple` and `Object[]` shrink the SELECT as the closed interface does, and load nothing; what they give up is the
type: a `Tuple` is read by alias (`t.get("name", String.class)`; its aliases printed, `[name, mealType]`), an `Object[]` by position
(`a[0]`, `a[1]`; its length printed). Said as why the four kinds exist; no code line on screen depends on it.

## 4 · xcheck — the harness's DDL script, against the owning-side lesson's (R.212, RE-MEASURE 3)

`probe.x.XMain` — the anchor's entities alone (`@EntityScan("com.tiffinbox")`, no repository: `Found 0 JPA repository interfaces.`, no
seed), `scripts.action=create` into `.harness/run/hibernate-ddl.sql` (a file, never run): two `create table` lines and one `alter table`,
md5 **`f595637014e786fa38606859951e4f97`** = unit 09's published script md5 (its README names it; its `xcheck` capture `9072c6f1…`,
asserted) — no mapping moved since the owning-side lesson, as ⚑3 says for 18-22.

## 5 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s block, then `SOLUTION.md`'s, read from the files, in ONE `env -i` shell — `/bin/bash --noprofile --norc`, then the
same in `/bin/zsh -f`: the README's app (`ExApp`, in `probe.q.ex`, `@EntityScan("com.tiffinbox")`, the shipped `Database` on its own H2, a
repository of its own in the same file, and a runner that prints the vegetarian customers through `Row`, an open interface) →
`the JVM: exit 0`, `Found 1 JPA repository interface.`, the labels — and a SELECT of every column, the same SELECT as `four`'s open
interface (asserted); the solution (one source line: `Row` closed, two getters named after properties and the label in a `default`
method) → `exit 0`, the same labels, and the SELECT of `four`'s closed interface (asserted, its column list counted). Broken and solved
differ in the column list alone — both exit 0 — so the check is the list, never the exit code. Bash and zsh print the same; the shell
ends in this folder. **Each exercise file's "What it prints" block is compared with what the run printed, line for line** (unit 16
shipped two placeholder lines under such a heading; here a placeholder, an empty block or a changed line stops the run).

## Exercise

**Your turn:** the README's projection selects every column to show two. Make the SELECT ask only for the name and the meal type.
(23 words, `wc -w`, R.203 — the brief's line, unchanged.) `exercise/README.md` and `exercise/SOLUTION.md`.

## The ledger rows and hand-offs this unit pays

- **Section 3 owns no ledger row** (`PROMISE-LEDGER-2026-11-01.md`); this unit settles none and opens none.
- **RE-MEASURE 1** (the exercise as files) and **3** (xcheck for 18-22) — below.
- Hand-offs by title: *Paging and Sorting* (20); *Lazy Loading and LazyInitializationException* (29) — the nested projection outside a
  transaction; *N+1, Measured* (30) and *JOIN FETCH vs @EntityGraph vs @BatchSize* (31) — its 1 + N SELECTs inside one.

## RE-MEASURE — the brief's items this unit settles

| # | Settled here |
|---|---|
| 1 | the exercise as README + SOLUTION files, bash and zsh, `env -i`: the open `Row` — every column / the closed `Row` — the name and the meal type, each `exit 0`; each file's "What it prints" = the run |
| 3 | xcheck for 19: the harness's script with `@EntityScan("com.tiffinbox")` alone = `f5956370…` (unit 09's), on the frozen anchor |

## What differed from the brief

1. **Six calls in `four`, not four**: the dynamic method is called with each of the three types the brief names; "four SELECTs" (R.187,
   the brief's hazard) is counted from the first four — closed, open, record, dynamic with `NameAndType.class` — and the other two
   dynamic calls are rows of the table beside them.
2. **Every call is the same `where` on the meal type (VEG)** — the probe's method names (`findNamesByMealType`, `findLabelsByMealType`,
   `findDtosByMealType`) — so the rows are the same two customers in every row and only the select list moves; the rows are printed
   sorted by the harness (a derived query has no `order by`, S3.7).
3. **The entity loads for the nested A are Statistics' own figure** (the two customers and the one pause the seed gives the VEG
   customers) and are not a spoken number; the spoken one is the statement count, 1 + one per customer (log and `Statistics`).
4. **The `LazyInitializationException`'s key is read off the capture** and asserted only as digits in the check (the brief's `'1'` is
   what every run of record printed — Ravi, the first row of the SELECT; the order of a derived query's rows is the database's, S3.7),
   so the voice says the class and "no session", the slide quotes the captured line.
5. **The Tuple and Object[] query selects the name and the meal type** (the probe's selected the name and the meals a day, with an
   `order by`): the brief asks for "the same 2-column SQL as the closed interface, byte-equal asserted", so the JPQL names the closed
   interface's two properties and has no `order by`; the closed call runs again in the same JVM, and both are compared with `four`'s.
6. **The exercise's broken and solved both exit 0**: an open projection is not an error; the check is the SELECT's column list
   (counted, and equal to `four`'s open and closed SELECTs). The solution keeps the label — a `default` method on the closed interface —
   so the runner's line and the rows do not change; the record form is named in `SOLUTION.md`, not run.
7. **One build, not two**: no processor here (unit 18's `proc/` and metamodel are not carried); the harness compiles against the
   anchor's libraries alone, with `-parameters` (no `-Xlint:deprecation`: no deprecation claim is made).
8. **The plants ran on scratch mirrors** (as units 15-18), each mirror's script keeping `four` (later checks read its values) and the
   planted capture, and copying this folder's own built anchor in place of its build (the build is the same command every run of
   record ran); a gate plant stops before any build. All 16 ran on the script as committed.

## Planted faults — each caught (R.65)

Each on a scratch mirror of this folder (its neighbours linked: `../c7-unit17`, `../c7-tiffinbox`, `../c7-unit09`; its `.m2-demo` a link
to this one's), one fault at a time, the mirror's `receipts.sh` keeping `four` and the planted fault's capture and copying this
folder's own built anchor in place of the build (What differed 8), `env -i`, a session of its own; each **exit 1, nothing written to
this folder**, no JVM of the mirror left (`pgrep -fl java`: none of the mirrors'). The line that stopped each:

| plant | where | caught by |
|---|---|---|
| the open projection in the solution (`SOLUTION.md`'s `sed` writes `Row`'s `@Value` line back) | `exercise/SOLUTION.md` | `exercise: the solution's SELECT asks for the name and the meal type alone - four's closed interface's (…): … (5, counted from the line)` |
| the nested beat inside a transaction for B (B's call and its `getPauses()` in `tx.execute`) | `harness/src` | `nested B: outside a transaction the first getPauses() must fail - org.hibernate.LazyInitializationException: … (no session), no cause (S3.10/R.241): it did not fail` |
| the brief's "selects two" for the open one (a sentence giving the open interface the closed one's count of columns, in words, added to section 1) | `README.md` | `a line says the open projection selects 2 … - S3.8's two witnesses contradict it: the SELECT's column list 5 (four), entity loads 2 (Statistics)` (after `four`) |
| a typed column count (a sentence giving every SELECT here a count of columns, no projection named, in section 3) | `README.md` | `a typed count of columns - the SELECT line's own list is counted by four, and only the values line and the table state it (S3.8/R.239, R.225)` (before any build) |
| a typed SELECT line (the closed interface's SQL, typed in section 3) | `README.md` | `a typed SQL string outside README.md's composed table and values line and the exercise's measured blocks (R.225, R.227)` (before any build) |
| `Tuple`'s SQL made to differ from the closed interface's (`order by c.name` added to its `@Query`) | `harness/src` | `tuple: Tuple's and Object[]'s SQL must be the closed interface's, byte for byte (and four's): …` (the first SQL ends `order by` the name) |
| a wrong published hash (`four`'s last digit) | `receipts.md5` | `four is not the published capture …` (after its checks passed) |
| a version claim without `HHH000001` (`org.hibernate.orm.core` at WARN) | `harness/logback.xml` | `four: the version lines - getVersionString(), Hibernate's HHH000001 and Spring Data JPA's 4.1.2 - once in each of its 1 harness JVMs (R.222, S3.15/R.246)` |
| a version claim without `4.1.2` (`Main.java`'s Spring Data line removed) | `harness/src` | the same check (S3.15) |
| an Indian dish name | `README.md` | `an Indian dish name (R.215: English names only)` (before any build) |
| a duration word | `README.md` | `dur7.DUR found a duration word - this unit speaks no time (R.172)` (before any build) |
| a placeholder line in an exercise file (unit 16's own placeholder word, put in the README's "What it prints" block) | `exercise/README.md` | `a placeholder line in this unit's prose - the exercise's blocks hold the measured output` (before any build) |
| a changed line in a "What it prints" block (`[Ravi VEG]`) | `exercise/SOLUTION.md` | `exercise/SOLUTION.md's "What it prints" block is not what the solution's lines printed` |
| xcheck: a wrong unit 09 md5 | `receipts.sh` | `../c7-unit09/README.md must name f595…4e98 - Boot's script md5 (R.212)` |
| a typed count in the projection table (the record row's 2 made 3) | `README.md` | `README.md's projection table is not the capture's - each row is composed from four …` (after `four`) |
| nested A on another meal type (VEGAN: one customer, 1 + 1 statements - the count check passes) | `harness/src` | `nested A/A': Ravi with no pause, Sunil with one of three days: expected the line: …` |

The brief's three for 19 (its lines 530-531) are the first three rows; one per capture class: `four` (the claim, the table, the hash,
the versions), `nested` (B in a transaction; A on another type), `tuple` (the `order by`), `xcheck` (unit 09's md5), `exercise` (the
`sed`; a block's line).

## Found on the way

- **The plant "B inside a transaction" was first caught by the statement count** (B's one statement became three), not by the
  exception check the brief names; the check now reads B's exception first, then counts its statements — the plant re-run on the
  script as committed stops at the exception check.
- **A column count beside a projection's name escaped both gates** in the first draft: the typed-count gate let through any line that
  named a kind anywhere, and the claim check read only a kind followed by its count; the gate now lets through only the claim's own
  shape (the kind, then the count), which the claim check reads.
- **macOS `sed` has no `\|` and no `\b`**: the class of what came back is read with `sed -E`, the claim's kind and count with `perl`.
- **A `default` method keeps a projection closed**: the exercise's solution keeps `getLabel()` as a `default` method beside the two
  property getters, and its SELECT is the closed interface's (measured, both shells) — the record would do the same.

## CARRIED

- **The nested projection's 1 + N** → *N+1, Measured* (U30) and *JOIN FETCH vs @EntityGraph vs @BatchSize* (U31) — this unit measures
  the shape for two customers only; the units that own it measure it at scale.
- **The nested projection outside a transaction** → *Lazy Loading and LazyInitializationException* (U29) — named, not explained.
- **A class-based DTO with a JPQL constructor expression** — unit 17's `record` capture showed `select new …Bill(…)`; not repeated here.

## For RED

- **"Whether the SELECT shrinks depends on which"** rests on six calls of one derived query; a `@Query` with a projection return type is
  not measured here. Ask whether the voice must say "a derived query" each time.
- **"Loads the entity"** for the open interface is `Statistics`' entity load count (2 for two rows); that Spring Data then wraps the
  entity in a proxy is the code's reading (R.201) — the capture shows a JDK proxy came back. Ask whether the slide says "loads" or
  "reads every column".
- **The nested B's exception is thrown from the first `getPauses()`**, after the customers' SELECT — a call failure (exit 0); ask whether
  the voice says "outside a transaction" or "after the repository call returned".
- **The exercise's solution is a closed interface with a `default` method**: that a `default` method keeps a projection closed is
  measured here (the column list), not read off Spring Data's documentation; ask whether the slide shows the record instead.
- **"The refused fifth"** — `Tuple`/`Object[]` shrink the SELECT exactly as the closed interface does (byte-equal); the reason given for
  refusing them is the type (by alias, by position), not the SQL. Ask whether "refused" is the word.
