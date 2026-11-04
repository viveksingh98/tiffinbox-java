# c7-unit07 — Columns, Enums and Converters

Course 7 · Data with JPA & Hibernate · Section 2 (Mapping), its second unit, and **the course's third change to the anchor** ·
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.2** (Hibernate ORM 7.4.13.Final, Jakarta Persistence 3.2.0, H2
2.5.250 — the anchor's pin — HikariCP 7.0.2, **PostgreSQL 18.6** in a container, the PostgreSQL JDBC driver **42.7.14**, the version
Boot 4.1.2 manages), 2026-11-04. An enum stored by its position is a promise that nobody ever reorders it. An **enum ordinal** is
that position — `VEG` is 0, `NON_VEG` 1, `VEGAN` 2, in the order the constants are written — and `@Enumerated(EnumType.ORDINAL)`, JPA's
default, stores it. Measured on H2 and on PostgreSQL 18, side by side, in two builds of the same harness that read one database: the
DDL Hibernate writes for an enum, mapped six ways; what a reorder, an added constant and a renamed one do to rows already written;
a converter, and the one thing it may not share an attribute with; and TiffinBox's own `CustomerEntity`, which now holds the anchor's
`MealType`, stored by its name.

**The anchor changes (brief ⚑1).** `after/` is this unit's frozen copy of `../c7-tiffinbox` after the change; `before` is the link to
`../c7-unit06/after`, the anchor before it. `receipts.sh` prints `diff -rq -x .m2-demo -x target -x secrets after ../c7-tiffinbox` at
its start and end — empty in every run of record — and, from the next anchor change on, prints a note instead (R.211). Both trees are
copied under `.harness/` and built there, never in place. What changed (`anchor` prints the file list and `CustomerEntity.java`'s diff):

- `tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntity.java` — `mealType` is `com.tiffinbox.MealType` (`VEG, NON_VEG, VEGAN`),
  `@Enumerated(EnumType.STRING) @Column(length = 10, nullable = false)`; the constructor takes a `MealType`, `getMealType()` returns
  one; the field's Javadoc says why it is stored by name, and the class's Javadoc a line on the column.
- `README.md` — the anchor's: its unit 07 section, the header's note, and unit 03's history note on `String mealType` (below).
- **Kept, unchanged** (R.180): `Database` (`meal_type VARCHAR(10) NOT NULL`, no check — `anchor` greps it), `CustomerRepository` (it
  writes the meal type as a string, as before), `application.yaml` (`ddl-auto: none`), the 18 tests, the web layer (it reads the record
  `Customer`, never the entity).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 10 captures, 3 runs each; every spoken number checked after its capture; 0 raw tokens and passwords; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version` and `javac -version` say 25.) It **dies** when a
capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first), and when a check after a capture fails. **Start it in
a process group of its own** (a terminal's foreground job is one): `sweep()` stops only processes of its own group. It needs
**Docker** (OrbStack here) and the image `postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873` already on
the computer (`docker image inspect` asserted; a receipt never pulls — a missing image stops it with the `docker pull` line); under
`env -i` hand Docker its config (`DOCKER_CONFIG=~/.docker`: OrbStack's context lives there). `.m2-demo` must be seeded first (below).

**Runs, each `env -i`** (`HOME` = a home of its own whose `.mavenrc` sets `-Duser.home` there and whose `settings.xml` names only two
dead proxies, `127.0.0.1:9`; `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`; `http(s)_proxy` dead too; `DOCKER_CONFIG` the
user's), a session of its own, `.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s2/` alone (6,613 files).
Two development runs fixed the captures and the checks (the first wrote every capture 3/3 with the hygiene passing; the second, after
`javac -parameters` for the builds 2 and the checks written from the first's captures, wrote the md5s that are `receipts.md5`, every
check passing); a first pair of runs of record (333 s, 337 s, both PASS) was made on the script before the `anchor` check's order
was swapped (What differed, 12), and stands superseded. **The runs of record, on the script as committed (`receipts.sh` md5 `f05048bd3944e1d6b0c298c7a09b7d27`): 341 s under
`./receipts.sh`** (/bin/bash 3.2.57) **and 350 s under `bash receipts.sh`** (Homebrew bash 5.3.9): each exit 0, all 10 captures 3/3 =
published, every check passed, each of the three builds `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0` (and `tests`'
`offline: yes`, inside its capture), the container removed, nothing listening on 19860-19869 at the end; each terminal log through
`check_unit7.py 07 --runlog` — `0 grep error line(s)`, `RESULT (run logs): PASS` (the unit gate answers "no 07-*.md … nothing to
check": no script yet). **Nothing was downloaded**, and this unit made no network act.

Published hashes: enumddl `78b996d331b2d6f7a2d859ed4cd76799` · reorder `8568fd7d36d60624741a10aa4e3eb8a9` · added `1a53828d2eda5a59bedf516776f79175` · renamed `02a154baca9f1e9c613ee75644fea038` · converter `216be7bb980af79644e48048bb654097` · anchor `dc5425373a3fb84bfde6979719ddb790` · seven `d853481b3fbd1c0fff98980a656f16d1` · tests `56b0251ebe01abece53c6094c0c379ab` · xcheck `74ea6be752b9be0b775e7abe1f3b907a` · exercise `3cacf3c4b698b1df4513b91b2206f0f3`.

### A sealed fresh clone — the recipe (R.129)

**Paste it into bash.** Unit 06's recipe, with this unit's folder:

```bash
S=/tmp/sealed07; W="/tmp/sealed 07"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
mkdir -p "$S/home/.m2" "$W" && git clone -q "file://$T" "$W/tiffinbox-java"
rsync -a --exclude _remote.repositories --exclude '*.lastUpdated' --exclude resolver-status.properties "$T/../../data-jpa-hibernate/_research/m2-seed-c7-s2/" "$S/central/"
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
X=http://127.0.0.1:9; E="env -i HOME=$S/home PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin http_proxy=$X https_proxy=$X HTTP_PROXY=$X HTTPS_PROXY=$X DOCKER_CONFIG=$HOME/.docker"
$E JAVA_HOME=/opt/homebrew/opt/openjdk@25 mvn -B -Dmaven.repo.local="$S/preflight-m2" org.apache.maven.plugins:maven-dependency-plugin:3.8.1:get -Dartifact=org.example.sealed:absent:1 > "$S/preflight.log" 2>&1
[ $? != 0 ] && grep -q 'Downloading from sealed: file://' "$S/preflight.log" && ! grep -qE 'Downloading from [^ ]+: https?://' "$S/preflight.log" && echo "sealed: file:// only" || echo "NOT SEALED - do not run receipts.sh"
cd "$W/tiffinbox-java/c7-unit07" && readlink before && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E ./receipts.sh            # a process group of its own
```

**Run (2026-11-04):** a `git clone` of tiffinbox-java at `f4c3653` into a path **with a space** (`…/sealed 07/tiffinbox-java`), this
commit's 68 files put in as git takes them (`git ls-files -m` and `-o --exclude-standard`, each `cmp`-equal to the working tree; `before`
→ `../c7-unit06/after` by `readlink`); a `file://` copy of the s2 seed (4,971 files); pre-flight: exit 1, 221 `Downloading from sealed:
file://`, 0 from http(s); the clone's `.m2-demo` seeded from that copy; `/bin/bash` 3.2, `env -i`, a session of its own: **exit 0 in 348
s, all 10 = published, every check passed**; each build `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`; after the run
`.m2-demo` held 4,971 files, 0 `_remote.repositories`; the builders' `dur7.py` is not beside a clone (the terminal says so; its md5 is
the check). Its terminal log through `--runlog`: PASS.

## The commands this unit adds

```bash
docker run -d --pull never --name c7-u07-pg -e POSTGRES_USER=sa -e POSTGRES_PASSWORD="$PGPW" -p 127.0.0.1:19868:5432 postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
docker exec c7-u07-pg psql -q -v ON_ERROR_STOP=1 -U sa -d sa -c 'set client_min_messages = warning' -c 'drop database if exists t1 with (force)' -c 'create database t1'
docker exec c7-u07-pg psql -At -U sa -d t1 -c "select id || '|' || name || '|' || meal_type from customer order by id"
docker exec c7-u07-pg psql -At -U sa -d sa -c "select datname from pg_database where datname = 'u07enum'"
mvn -o -B -Dmaven.repo.local="$M2" dependency:build-classpath -Dmdep.outputFile=classpath.txt
javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*:.harness/drv/*" harness/src/probe/map/H.java harness/src/probe/map/Main.java harness/src/probe/map/enums/*.java
sed 's/{ VEG, NON_VEG, VEGAN }/{ NON_VEG, VEG, VEGAN }/' harness/src/probe/map/enums/MealType.java > .harness/b2src/MealType.java
rsync -a --delete .harness/hc/ .harness/b2/ && javac -parameters -d .harness/b2 .harness/b2src/MealType.java
java -Duser.language=en -Duser.country=US -Dlogback.configurationFile=../../harness/logback.xml "${V[@]}" -cp "../hc:../after/tiffinbox-web/target/extracted/lib/*:../drv/*" probe.map.Main "${A[@]}"
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../drv/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 "${V[@]}"
curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Kavya","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:18431/customers
```

The container (one per run, started before the captures, removed at the end and by every exit); the fresh database `t1` for
TiffinBox's own run (the harness makes its own databases through the container's `sa` database); psql's read of the customer table,
inside the container (the image's local socket, no password); psql's listing of the harness's kept database `u07enum` between the two
builds; the driver, resolved by Maven from `harness/pom.xml` (Boot 4.1.2's parent, `org.postgresql:postgresql` with no version written:
`postgresql-42.7.14.jar` and its runtime dependency `checker-qual-3.55.1.jar`, copied to `.harness/drv/`, the jar's sha1 checked
against its `.sha1`); the harness compiled — **build 1**; **a build 2** — `MealType.java` with its one line of constants changed by
`sed` and compiled with the same `javac -parameters` into a copy of build 1 (the two lines are this README's with `b2` made `bN` and
the constants made the variant's: asserted); **the harness line** (run from `.harness/run`: `V` its JVM flags, `A` its arguments —
R.193, each printed as `$ V=(…)` / `$ A=(…)`; a build 2 run has `../bN:` where build 1 has `../hc:`); **the Postgres run line** — the
anchor's extracted-jar line (`after/README.md`, asserted there) with the locale, `../drv/*` last on the class path and `"${V[@]}"`
after it, `V` holding `--tiffinbox.jdbc-url=jdbc:postgresql://127.0.0.1:19868/t1?user=sa&password=<the password>` and
`--logging.level.org.hibernate.SQL=debug`; Kavya's POST — the anchor README's POST with the name Kavya (asserted: that one change). The
lines read from `after/README.md` (8, each asserted whole) are unit 06's: `mvn -B package`, `mvn -B clean test`, the run line, the
extract line, the extracted-jar line, the POST, the GET of `/customers`, and the first-entity lesson's DDL line.

## The repository, and the network

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s2/` alone (6,613 files: the Section 1 seed plus `org.postgresql:postgresql:42.7.14`).
Four builds: `before/`'s and `after/`'s `package` (each runs its 18 tests), the driver's `dependency:build-classpath`, and `tests`' `clean
test`; each `offline: yes` with 0 `Downloaded from` lines in every run of record (the label is derived from the build log, never typed).
After the builds the script asserts `.m2-demo` holds `spring-boot-starter-parent-4.1.2.pom`, `hibernate-core-7.4.13.Final.jar` and
`postgresql-42.7.14.jar`. **At run time** every request goes to `127.0.0.1`; every database is H2 in a JVM (in memory, or the file
`.harness/run/db/enum.mv.db` for the two builds — deleted after the second, and `.harness/ex/db/ex.mv.db` in the exercise, deleted by
its own last line) or a database in the container, published on `127.0.0.1:19868` only (`docker port` asserted). **No network act**:
this unit reads no version file — unit 06 made Section 2's dated sweep (`../../../data-jpa-hibernate/_research/spring-boot-metadata-2026-11-04.xml`,
md5 `f9f50873…`: 4.1.2 the newest 4.1.x GA, 4.1.3 absent, no 4.2 GA; R.223), and no Section 2 unit speaks a "newest" fact (⚑6).

## The demo token, and the database password

`TOKEN=` at the top of `receipts.sh` (32 characters), fake and meant to look it: it guards nothing but demo servers on 127.0.0.1 that
every capture stops. It is written into `.harness/*/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600, git-ignored) of every
copy, and sent only by `../c5-unit11/curlset.sh` and `harness/shutdown.sh` on curl's standard input; before every start the script
lists that `secrets/` folder (the token's file, nothing else — R.158). The harness builds a `TiffinBoxProperties` record in code for
the shipped `Database`; its seventh component is the literal `harness-only-not-a-secret-u07` in `Main.java` — 29 characters, allowed
by name: no server ever reads it (RED #318).

**The password** (R.214): 24 lower-case letters and digits, generated at every run from 4,096 bytes of `/dev/urandom` (bounded — see
"Found on the way"), never committed, kept in `.harness/pg/password` (mode 0600, the folder 0700). The container gets it as
`POSTGRES_PASSWORD` with `POSTGRES_USER=sa`; the harness reads the file; TiffinBox gets it in `--tiffinbox.jdbc-url` (`?user=sa&password=…`)
— both of its connection paths read that one URL. Hibernate prints the URL once per start (`HHH10001005: Database info:` · `Database JDBC
URL [...]`): the one TiffinBox log on Postgres (`anchor`) is counted (the password raw: 1, in that line) and then masked in place. The
checks count **0 raw copies** in every capture run (the token's count and the password's, 30 raw runs), every capture, every log, and
every file under this folder but `.harness/pg/password` itself. It is visible, while a JVM runs, in that JVM's command line (and in
`docker run`'s, for a moment): a test password for a container that lives for one run.

## The locale

Every java line carries `-Duser.language=en -Duser.country=US`; a last check refuses a capture's java line without it; the test fork's
comes from the POM's `argLine`. **The harness prints ASCII** (` | ` between facts).

## The folders, the harness and the ports

- `after/` — the anchor after this change; `before` — the link to `../c7-unit06/after`. `.harness/before`, `.harness/after` — copied,
  each with a config tree, built with the README's `mvn -B package` offline, each jar extracted (91 libraries); `.harness/drvpom`,
  `.harness/drv` — the driver; `.harness/hc` — the harness, compiled: build 1; `.harness/b1`…`b4` (and `b1src`…`b4src`) — the builds 2;
  `.harness/run` — where every harness JVM starts (its scripts land there; `db/` holds the two builds' H2 file between their JVMs);
  `.harness/pg` — the password's file; `.harness/tests` — `tests`' copy; `.harness/ex` — the exercise's classes and its file database.
- **The harness** — the course's, never TiffinBox's (`harness/src/probe/map`, package `probe.map`; a check refuses `probe.map` anywhere in
  after/'s code). `H.java` is unit 06's with one addition: a database that outlives the JVM — `-Dh2file=./db/enum` (an H2 file, a path
  relative to `.harness/run`) or `-Dfresh=false` (the Postgres database kept, never dropped), its `database:` line saying which. **Not a
  Boot application** (⚑3, R.212): one `EntityManagerFactory` per run, Jakarta Persistence 3.2's `PersistenceConfiguration` over the
  classes the run names, Boot's two naming strategies, statistics on, `drop-and-create` on the run's own database only (R.178; `read`,
  `anchor`, `anchorread` and `xcheck` set it to `none`); the JDBC proxy of unit 06 beside it. Every run prints
  `org.hibernate.Version.getVersionString()` first (R.222) and its `database:` line. Scenarios (`Main.java`): `ddl FILE CLASS…`, `write
  CLASS…` (build 1: its pid, its `MealType` and ordinals, Ravi=VEG, Meera=NON_VEG, Priya=VEGAN in each table, the raw column by a
  second connection), `read CONST CLASS…` (build 2: its pid and `MealType`, each table's raw column, Hibernate's read, then Kavya with
  `CONST`), `both`, `auto FILE`, `anchor FILE`, `anchorread`, `xcheck FILE`. Entities (`probe.map.enums`, English names, one
  `MealType mealType` each): `OrdCustomer` (`ORDINAL`), `BareCustomer` (no annotation), `StrCustomer` (`STRING`), `LenCustomer` (`STRING`,
  `@Column(length = 10)`), `DefCustomer` (`STRING`, `columnDefinition = "varchar(10)"`), `ConvCustomer` (`@Convert(converter =
  MealCode.class)`), `NamedCustomer` (`STRING` + `@JdbcTypeCode(SqlTypes.NAMED_ENUM)`), `BothCustomer` (`@Enumerated` + `@Convert`);
  `MealCode` (codes `veg`, `non-veg`, `vegan` written by hand; a name it has no code for goes in as `?NAME`), `AutoCode` (the same,
  `@Converter(autoApply = true)`), and the harness's own `MealType { VEG, NON_VEG, VEGAN }`. `probe.map.ex.ExCustomer` is the exercise's
  (`ORDINAL`; never compiled into `.harness/hc`, asserted). The harness never `switch`es on a `MealType` (a switch would compile its
  constants into another class, and build 2 would differ in more than one file). `harness/logback.xml`, `harness/pom.xml` — unit 06's,
  their comments naming this lesson; `harness/shutdown.sh` (the CORS lesson's), `harness/surefire.py` (the testing lesson's) and
  `harness/dur7.py` (the builders', md5 `41667fed…`), byte for byte.
- **Ports** (§P, 19860-19869): `anchor`'s TiffinBox run 19860 · `seven` 19861 · `xcheck`'s Boot run 19862 · the container 19868 · 19869
  never bound (asserted free first and last; a JVM that listens there is killed and the run dies); 19863-19867 unused and checked free.
  18425, 8080 and 35729 checked free first and last. The harness's JVMs, `tests` and the exercise bind none.

## Masks, filters and hygiene — every one, declared

1. **`mask()`** (`gsub()`, literals escaped; checked first on a planted line, which is deleted at once — it held the password): the
   token → `[masked: the 32-character token]`; the password → `[masked: the 24-character password]`; this folder → `…`, the folder above
   → `…/..`, home → `~`, the user name → `<user>`; ` using Java <version>`; H2's generated database name; an identity hash → `@…`; **H2's
   generated check-constraint names** → `CONSTRAINT_<n>` (RED #320: `CONSTRAINT_4` and its kin are numbered by H2, not by anyone's
   code); **a harness JVM's pid** → `this JVM's pid: <masked>` — the two-build check compares the unmasked pids before the mask runs.
2. **A harness log** (`hview`): every line, trailing spaces dropped.
3. **A TiffinBox log** (`tview`, unit 06's): the lines of `TiffinBoxServer`, `org.hibernate.orm.core`, `org.hibernate.orm.connections.pooling`
   (with its `Database JDBC URL` and `Database version` lines), Hikari's pool and `org.hibernate.SQL`; the SQL logger's lines and its
   `insert into` lines counted, WARN and ERROR counted.
4. **A Maven log**: its `$` line, exit, `BUILD` line, `offline`; Surefire's reports with the console's summary beside their sum.
5. **Hygiene, checked last over every capture** (unit 06's list): no absolute path, no unit number (a `diff`'s `-`/`+` lines may quote
   one), no Boot process line, no time, no log time, no thread number, no JDK/OS version token, no unmasked generated database name, no
   random port, no per-run timing figure, no stack frame; every `$` line's URL 127.0.0.1's; every java line pinned; one `secrets/` listing
   per TiffinBox start; `GenerationTarget encountered exception` 0 in every harness and Boot log (R.213); no SQL keyword as a harness name;
   **no H2 database file anywhere in this folder, `.harness/` included** (R.195: the two builds' file is deleted by the capture that made
   it, the exercise's by its own block); no `pkill`/`killall`; no bare `wait`; no one-string multi-option variable (R.193); **no Indian
   dish name** in any capture (R.215).
6. **Duration words** (R.172): `dur7.DUR` over this README and the exercise's two files must find **0** — this unit speaks no time; one
   match stops the run before anything is built. **Dish names** (R.215, the course's memory rule — the AI voice mispronounces them):
   41 words — Indian dish names and one more the rule names — whole words, any case, refused in this README, `exercise/` and `harness/src` before anything is
   built, and in every capture at the end. The meal types are `VEG`, `NON_VEG`, `VEGAN`, `EGG`, `VEGETARIAN`.

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the Maven it
waits for (`$mpid`, with every process under it — Surefire's fork), the exercise's shell (`$xpid`), sweeps its own process group for any
TiffinBox JVM, harness JVM (`probe.map.Main`), Maven or Surefire fork left, **removes this run's container** (`docker rm -f c7-u07-pg`,
only if this run started it), deletes the capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published
captures are untouched. No `wait` in the script or the exercise is bare. (`.harness/` keeps what it held — a two-build pair
interrupted between its JVMs would leave `.harness/run/db/enum.mv.db` there, not measured: the trials below interrupt other steps; the
next run's first act is `rm -rf .harness`.)

**Measured (2026-11-04, the sealed clone, the script as committed):** `./receipts.sh` (/bin/bash 3.2) started in a session of its own
**with SIGINT at its default**, `kill -INT` to its group once the named process was in it (and, for the last two, the container up),
the state read 5 s later — three trials, each **exit 130, nothing left, the container gone**:

```
build: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · container c7-u07-pg: gone · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
harness: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · container c7-u07-pg: gone · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
pgjvm: processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · container c7-u07-pg: gone · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
```

`build` — the first Maven (`before/`'s package, its Surefire fork); `harness` — the first harness JVM (`enumddl` on H2, the container
up); `pgjvm` — TiffinBox itself on Postgres (`anchor`, port 19860). `pgrep -fl java` afterwards: none; `docker ps -a`: only a container
that is not this unit's.

## 1 · enumddl — one attribute, six mappings, two databases (R.217)

Hibernate's DDL (a script written, and run on the throwaway database) for one `MealType mealType` attribute mapped six ways, H2 and
PostgreSQL side by side, each with its `database:` line:

| mapping | H2 2.5.250 | PostgreSQL 18.6 |
|---|---|---|
| `ORDINAL`, and no annotation at all (`BareCustomer`) | `meal_type tinyint check ((meal_type between 0 and 2))` | `meal_type smallint check ((meal_type between 0 and 2))` |
| `STRING` | `meal_type enum ('NON_VEG','VEG','VEGAN')` — H2's own enum type, the names **sorted** | `meal_type varchar(255) check ((meal_type in ('VEG','NON_VEG','VEGAN')))` — declaration order |
| `STRING` + `@Column(length = 10)` | `enum ('NON_VEG','VEG','VEGAN')` — the length ignored | `varchar(10) check (… in ('VEG','NON_VEG','VEGAN'))` |
| `STRING` + `columnDefinition = "varchar(10)"` | `meal_type varchar(10)` — **no check at all** | `varchar(10) check (…)` — **the check stays** |
| `@Convert(converter = MealCode.class)` | `varchar(255) check ((meal_type in ('non-veg','veg','vegan')))` | the same — Hibernate ran the converter over every constant to write the check |
| `STRING` + `@JdbcTypeCode(SqlTypes.NAMED_ENUM)` | (not run: Postgres's type) | `create type MealType as enum ('NON_VEG','VEG','VEGAN');`, two `create cast … with inout as implicit`, `meal_type MealType` |

## 2 · reorder — the enum tidied up, two builds, one database (A/B/A′, R.1, R.218)

`the builds`: build 2 for A and A′ is `MealType.java` compiled again unchanged — `diff -rq` of the class directories: **none (0)**, the
two `MealType.class` md5s equal; build 2 for B is the same line with the constants reordered alphabetically, **`{ NON_VEG, VEG, VEGAN }`**
— **`probe/map/enums/MealType.class` (1)**, the md5s differ. Then, on H2 and again on PostgreSQL, three pairs of JVMs: **build 1** writes
Ravi=VEG, Meera=NON_VEG, Priya=VEGAN into `ord_customer`, `str_customer` and `conv_customer` (raw: `0, 1, 2` · `VEG, NON_VEG, VEGAN` ·
`veg, non-veg, vegan`), the database is listed between the JVMs (`enum.mv.db` / `u07enum`), **build 2** reads them back:
- **A** (build 2 = build 1): `Ravi=VEG, Meera=NON_VEG, Priya=VEGAN` in all three tables. **A′** = A, line for line.
- **B** (reordered): `ord_customer read by Hibernate: [Ravi=NON_VEG, Meera=VEG, Priya=VEGAN]` — **the raw column still `0, 1, 2`, no
  WARN, no exception**: Ravi, who ordered vegetarian, is non-veg now. `str_customer` and `conv_customer`: `Ravi=VEG` — by name, or by a
  code written by hand, the reorder changes nothing. **The check constraint Hibernate wrote (`between 0 and 2`) does not catch it**: the
  positions are still in range.
- **The two-build check** (R.218, RED #310), on every pair: two pids, different, each the one this script started; the database there
  between them; **build 2's first SQL a `select`**; then `rm -rf .harness/run/db`, 0 database files left. The JVMs' own `this JVM's pid:`
  lines are masked in the capture (`<masked>`); the check reads them before the mask.

## 3 · added — a fourth constant (EGG)

Build 2 = `{ VEG, NON_VEG, VEGAN, EGG }` (`MealType.class` alone differs). The three rows read as written in all three tables; **Kavya=EGG
is refused** in all three, by the checks Hibernate's DDL wrote — H2: `ord_customer` `Check constraint violation: "CONSTRAINT_<n>: "`
(23513), `str_customer` **`Value not permitted for column "('NON_VEG', 'VEG', 'VEGAN')": "EGG"`** (22030, `DataException` — H2's enum
type), `conv_customer` the check (23513: the converter's fallback `?EGG`); PostgreSQL: each table's `<table>_meal_type_check`, 23514,
`Failing row contains (3, 4, Kavya)` · `(4, EGG, Kavya)` · `(4, ?EGG, Kavya)`. **An added constant fails loudly — on insert.**

## 4 · renamed — VEG becomes VEGETARIAN

Build 2 = `{ VEGETARIAN, NON_VEG, VEGAN }`. **ORDINAL: `Ravi=VEGETARIAN`, quietly** (position 0 has a new name; no WARN), and Kavya=VEGETARIAN
goes in as `0`. **STRING: the read fails — `java.lang.IllegalArgumentException: No enum constant probe.map.enums.MealType.VEG`**; the
converter's too (`PersistenceException: Error attempting to apply AttributeConverter` ← the same); both refuse Kavya=VEGETARIAN (H2
22030 / 23513, PG 23514). **A renamed constant fails loudly by name — on read.** Both databases alike. These checks exist because
Hibernate wrote the DDL; `Database`'s `meal_type VARCHAR(10)` has none (`anchor` prints the line; a renamed constant's insert into it
was not run — RE-MEASURE 4, not spoken).

## 5 · converter — two mappings on one attribute; a converter that applies itself (the failure receipt)

`@Enumerated(EnumType.STRING)` + `@Convert(converter = MealCode.class)` on one attribute (`BothCustomer`), H2 and PostgreSQL: **the
trio — exit 1 · `org.hibernate.AnnotationException: 'AttributeConverter' not allowed for attribute 'mealType' annotated
'@jakarta.persistence.Enumerated'` · the EntityManagerFactory built: no** — 0 SQL lines (a mapping error, before any SQL). `AutoCode`
(`@Converter(autoApply = true)`) beside three attributes: the **unannotated** one gets the codes' check (`varchar(255) check (… in
('non-veg','veg','vegan'))`, both databases); the `ORDINAL` and `STRING` ones **keep their enum mapping** (tinyint/smallint, enum/varchar
+ check) — no error, no WARN.

## 6 · anchor — TiffinBox's own CustomerEntity, on the shipped Database's tables (the change's witness, RED #319)

The change: `diff -rq before after` → `README.md`, `CustomerEntity.java`; its diff (6 hunks); `Database.java`'s column, by `grep -n`:
**`39: meal_type     VARCHAR(10) NOT NULL`**. Then the shipped `Database` (`new Database(new TiffinBoxProperties(…))`, `createAndSeed()`)
seeds this run's database and the anchor's `CustomerEntity`, from `after/`'s jar, reads it — **H2 and PostgreSQL: `[Meera=NON_VEG,
Priya=VEGAN, Ravi=VEG, Sunil=VEG]`**, `getMealType()`'s class `com.tiffinbox.MealType`; Kavya persisted with `VEGAN`, the bind logger:
**H2 `binding parameter (1:ENUM) <- [VEGAN]`, PG `(1:VARCHAR) <- [VEGAN]`**; her row by a second connection `[Kavya=VEGAN]`; the column
`CHARACTER VARYING 10` / `character varying 10` — still `Database`'s. **Hibernate's DDL for the entity** (a file, never run): H2 `meal_type
enum ('NON_VEG','VEG','VEGAN') not null`, PG `meal_type varchar(10) not null check ((meal_type in ('VEG','NON_VEG','VEGAN')))` — not
`Database`'s line on either (ⓘ3: why the anchor's DDL is `Database`'s, and `ddl-auto` stays `none`). **TiffinBox itself on PostgreSQL**
(port 19860, fresh database `t1`): ready, `POST` Kavya (`"mealType":"VEG"`) **201**, psql `1|Ravi|VEG 2|Meera|NON_VEG 3|Sunil|VEG
4|Priya|VEGAN 5|Kavya|VEG`, the SQL logger at DEBUG **0 `insert` lines** — TiffinBox's JDBC repository wrote her (R.221); its log's
`HHH000001: Hibernate ORM core version 7.4.13.Final` and the masked `Database JDBC URL` line (R.220, R.222); then the anchor's
`CustomerEntity` reads `t1`: **`[Kavya=VEG, Meera=NON_VEG, Priya=VEGAN, Ravi=VEG, Sunil=VEG]`**. Its plant — `ORDINAL` on the shipped
field — is below (Planted faults): the seed read fails.

## 7 · seven — a guard (R.190)

`before/`'s jar and `after/`'s, port 19861, a fresh JVM each: **`466c20ed7e0d5439cb052f32ce09de1b` on both**, lines that differ 0; each
log `HHH000001 … 7.4.13.Final`, the pool `url=jdbc:h2:mem:tiffinbox`. Equal by construction: the web layer never reads `CustomerEntity`.

## 8 · tests — TiffinBox's tests (C7-4)

`cd .harness/tests && mvn -o -B -Dmaven.repo.local="$M2" clean test`: exit 0, BUILD SUCCESS, offline: yes; `TiffinBoxWebTest` 14,
`FullStackTest` 3, `FeedTest` 1 — **18**, failures 0, the console's summary the same; 2 `Initialized JPA EntityManagerFactory`, 0 SQL lines:
a guard, not a witness.

## 9 · xcheck — the harness's DDL against Boot's (R.212)

Boot's: `after/`'s jar with the first-entity lesson's DDL line (port 19862, stopped by POST /shutdown) writes `hibernate-ddl.sql`; the
harness's: its own EntityManagerFactory over `com.tiffinbox.CustomerEntity`, `xcheck.sql`. Both one line, `create table customer
(meals_per_day integer not null, price_per_meal integer not null, id bigint generated by default as identity, name varchar(60) not null
unique, meal_type enum ('NON_VEG','VEG','VEGAN') not null, primary key (id));` — **`cmp`: the same, byte for byte, md5
`820b43fcc96665c2d457212a156204eb`** (unit 06's was `6ca9a850…`: the entity changed). **Unit 08 compares its harness's script with this
md5 — "Boot's script as 07 captured it"** (R.212); 10-14 with unit 09's.

## 10 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s 10 lines, then `exercise/SOLUTION.md`'s (the README's with one line changed: the copy of `ExCustomer.java` made
with `sed 's/EnumType.ORDINAL/EnumType.STRING/'`), each block sourced in one `env -i` shell, `/bin/bash --noprofile --norc` then
`/bin/zsh -f`; each block runs build 1 and build 2 in two fresh JVMs. In both: the README → raw `[Ravi=0, Meera=1, Priya=2]`, build 2
**`[Ravi=NON_VEG, Meera=VEG, Priya=VEGAN]`**; the solution → raw `[Ravi=VEG, Meera=NON_VEG, Priya=VEGAN]`, build 2 **`[Ravi=VEG, …]`**;
`.harness/ex/db` gone; the shell back in this folder; bash's output = zsh's.

## Exercise

**Your turn:** the README's enum was reordered and Ravi became non-veg. Change how the column stores it so he stays vegetarian.
(21 words, `wc -w` on the quoted sentence, asserted in `receipts.sh`.) `exercise/README.md` ships `ExCustomer` with `ORDINAL`,
`exercise/SOLUTION.md` beside it; broken (`Ravi=NON_VEG`) ≠ solved (`Ravi=VEG`), each from its own two fresh JVMs, measured by the
`exercise` capture (R.196).

## The anchor's README — what this unit changed in it

- **A new section**, `## Course 7 · unit 07 — enums: …`, after unit 06's: the one file and why, by name and not by position (the reorder,
  the added and renamed constants, with their scope — the checks are Hibernate's DDL's, `Database`'s column has none), what Hibernate
  would generate now (H2's `enum`, Postgres's `varchar(10)` + check) and that nothing runs it, the tests and the seven unchanged, a
  customer added over HTTP read back as `MealType.VEG`.
- **The header** — a note: the meal type is `MealType`, stored by its name, since unit 07.
- **A history note made false, amended in place** (*Course 7, unit 07*): unit 03's `@Column(length = 10, nullable = false) String mealType`.

## The shipped receipts on the moved anchor (R.211)

Unit 06's commit put every Section 1 receipt, and its own, on Course 6's note form; this unit's anchor change is the first to exercise
unit 06's. `../c7-unit06/receipts.sh` (unchanged, md5 `c20d7fb5…`) run once on the moved anchor, `./receipts.sh` (/bin/bash 3.2.57),
`env -i`: **exit 0 in 309 s**, the note `(after/ and ../c7-tiffinbox differ - the anchor has moved past the tree this unit froze: Files
after/README.md and ../c7-tiffinbox/README.md differ;Files after/…/CustomerEntity.java and …)` at its start and end, no line saying "=
../c7-tiffinbox", all 10 captures 3/3 = published, its `receipts.md5` unchanged, `check_unit7.py 06 --runlog` PASS; its README gains a
dated paragraph saying so (the form unit 06 gave units 01-05's). Units 01-05 were not re-run: unit 06 re-ran each on a moved anchor
in the same note form, and nothing in this change touches their frozen trees or scripts. No builder asserts `c7-tiffinbox` against a
unit's tree any more (unit 06's `grep`: the one assert was s703:41, fixed there to compare with `git show b2e0641`).

## The ledger rows and hand-offs this unit pays

- **C7-4 — re-run**: 18, unchanged (`tests`), a guard (R.190).
- No other row is paid here (the brief's §LEDGER: 07 pays C7-4 only). C7-5's check stays unit 03's: this change does not touch `name`.

## RE-MEASURE — the brief's items this unit settles

| # | Settled here |
|---|---|
| 1 | the exercise as README + SOLUTION files, bash and zsh, `env -i`: `Ravi=NON_VEG` / `Ravi=VEG`, two fresh JVMs each |
| 2 | the shipped `Database` built in code on the harness's URL: H2 and PG (`anchor`) |
| 8 | the anchor change on the frozen tree (`07/after`): the field, constructor, getter, Javadoc; the README |
| 10 | the enum two-build swap: a copy of build 1 with `MealType.class` compiled again (`diff -rq`: 1 file; A's copy 0), both md5s printed |
| 12 | `xcheck` on `07/after`: `820b43fc…` (the entity's DDL changed: `meal_type enum (…)`) |
| — | ⚑8's "not yet run on 42.7.14: U07 reorder" — run here on 42.7.14, the probe's results the same |
| 4 | **not settled**: STRING's renamed-constant insert into `Database`'s own `VARCHAR(10)` was not run; the voice says the scoped sentence only ("these checks exist because Hibernate wrote the DDL") |

## What differed from the brief

1. **Build 2 is a copy of build 1's class directory, not a directory ahead of it on the class path** (the brief's Hazards line): the
   AMENDMENT's witness is "the two class directories differ in 1 file", and a copy makes that a `diff -rq` of two directories; the
   exercise, which a viewer runs by hand, keeps the class-path-ahead form (`../ex/reordered:` first).
2. **A build 2 is compiled with `javac -parameters`, like build 1**: without it, A's "unchanged" copy differed from build 1 in
   `MealType.class` (the `MethodParameters` attribute of `valueOf`) — the first development run showed two md5s for one source. With it, A's
   copy is byte-identical (0 files differ) and B's differs in that one class.
3. **The reorder's A/B/A′ inserts nothing** (`read -`): the brief's beat is the read; Kavya's inserts are `added`'s and `renamed`'s.
4. **`anchor` runs TiffinBox itself on Postgres** (the brief's "19860 `anchor` (Boot run)"): the run adds Kavya through the web layer
   (`CustomerRepository`, JDBC, 0 Hibernate `insert` lines) and the anchor's entity reads that database — TiffinBox's own rows, not only
   the harness's seed. The H2 side is the harness's (TiffinBox's H2 lives in its JVM's memory).
5. **The checks run right after each capture**, not all at the bottom (06's form): a planted fault stops the run at its capture.
6. **`NamedCustomer` runs on Postgres only** (the brief's table has no H2 cell for it).
7. **No `sweep` capture**: unit 06 filed the section's dated version read (R.223); this unit cites it and reads no file.
8. **RE-MEASURE 4 not run** (the brief: "only if spoken") — the README and the anchor's section say the scoped sentence only.
9. **The dish-name refusal (R.215) is in this receipt** (a word list over this unit's prose, harness and captures), not only in a builder.
10. **The anchor README's unit 03 note** is amended with a *Course 7, unit 07* note rather than rewritten.
11. **The plants' copies leave out the captures before the planted one** (their hashes stand as published; the planted capture's hash
    removed so its check speaks): a plant on `anchor` need not re-run four two-build captures first. Each plant runs the whole script
    otherwise, in a scratch mirror of the repository (the anchor, `../c7-unit06/after`, the three shared scripts).
12. **`anchor`'s check reads the seed first** — the witness before the diff (RED #319): with the diff first, the `ORDINAL` plant was caught
    by the diff's `@Enumerated(EnumType.STRING)` line (the first plant run), never reaching the seed read the row asks about; the order
    was swapped and the plant run again. And the seed read fails on the first row by name (`NON_VEG`, Meera's), not on `'VEG'`.
13. **`../c7-unit06/README.md` joins this commit** — one dated paragraph: its receipt re-run on the moved anchor (above).

## Planted faults — each caught (R.65)

In every run: `reorder` B's ORDINAL read is the corruption (the check that says it), and `converter`'s refusal is the failure receipt.
On copies (each a copy of this folder in a scratch mirror of the repository — the anchor, `../c7-unit06/after`, the three shared
scripts — `receipts.md5` kept unless the plant says, the captures before the planted one left out where named; the plant made, the run's
terminal log read, the copy reset), each **exit 1**, nothing written to this folder, the container gone, 0 listeners on 19860-19869 — the
`ORDINAL` and version plants on the script as committed, the six others on the script before `anchor`'s check order was swapped (What
differed, 12: no other check moved):
- **STRING in B of `reorder`** (`OrdCustomer`'s `@Enumerated(EnumType.ORDINAL)` → `STRING`; `enumddl` left out — its DDL check would
  speak first; `reorder` out of `receipts.md5`) → `*** reorder H2 B: expected the line:   PROBE ord_customer read by Hibernate: [Ravi=NON_VEG,
  Meera=VEG, Priya=VEGAN] ***` (105 s) — by name, Ravi stays `VEG`, and the hook's check fails.
- **The reorder in one JVM, on H2 in memory** (`Main` given a `writeread` scenario — `write`, then `read`, in one JVM — and `reorder`'s B on
  H2 run as that, with no `-Dh2file`; `reorder` out of `receipts.md5`) → `*** reorder: the two-build check - two JVMs, the database between
  them, build 2's first SQL a SELECT (3 per database; R.218) ***` (112 s) — the md5 line alone would not have seen it (RED #310).
- **`@Enumerated` + `@Convert` caught and printed as a success** (`Main.both()` swallows the `AnnotationException` and prints "the
  EntityManagerFactory was built"; `enumddl`…`renamed` left out; `converter` out of `receipts.md5`) → `*** converter: the trio - exit 1, the
  AnnotationException, no EntityManagerFactory - on both databases ***` (43 s).
- **`ORDINAL` on the shipped field** (`CustomerEntity`'s `@Enumerated(EnumType.STRING)` → `ORDINAL` in `after/` and the mirror's anchor alike;
  `enumddl`…`converter` left out; `anchor` out of `receipts.md5`) → `*** anchor: the seed read through the entity: expected the line:
  PROBE read by Hibernate (the anchor's CustomerEntity): [Meera=NON_VEG, Priya=VEGAN, Ravi=VEG, Sunil=VEG] ***` (54 s). What the capture
  held (measured, RED #319's "unmeasured" row settled): H2 `DataException: Could not extract column [2] from JDBC ResultSet [Data conversion
  error converting "NON_VEG" [22018-250]]` ← `NumberFormatException: For input string: "NON_VEG"`; PostgreSQL `Bad value for type byte :
  NON_VEG` — the first row by name is Meera's; TiffinBox's own rows on Postgres fail the same way at `VEG` (Kavya's, first by name). The
  seed read fails loudly, at the first row — not on `'VEG'` as the brief guessed, on whichever name comes first.
- **A version claim without its version line** (`tview`'s logger list without `org.hibernate.orm.core`: TiffinBox's log view loses its
  `HHH000001` line; `enumddl`…`converter` left out; `anchor` out of `receipts.md5`) → `*** anchor: TiffinBox on Postgres, its rows read
  through the entity: expected the line:     INFO org.hibernate.orm.core: HHH000001: Hibernate ORM core version 7.4.13.Final ***` (55 s)
  (R.222; the harness's `Version.getVersionString()` line is counted in every harness run's check the same way).
- **A wrong digest** (`IMG=…a1874`) → `*** the image is not on this computer: docker pull postgres@sha256:…a1874 ***` (1 s).
- **A wrong published hash** (`receipts.md5`'s `enumddl` with its last digit changed) → `*** enumddl is not the published capture … ***`
  (36 s, after the builds).
- **An Indian dish name** (one README line appended: a plate of a dish whose name is on the list) → `*** an Indian dish name (R.215:
  English names only): README.md:391:… ***` (1 s), before anything is built.

## Found on the way

- **A `tr` that reads `/dev/urandom` never ends where SIGPIPE is ignored.** The first development run was started through a Python
  `setsid` wrapper, which ignores SIGPIPE and passes that on through `exec`: unit 06's password line (`tr -dc … < /dev/urandom | head -c
  24`) ran on after `head` had its 24 characters, and the run sat there. The line now reads 4,096 bytes first (`head -c 4096
  /dev/urandom | tr -dc 'a-z0-9' | head -c 24`), so it ends whatever the signal's setting; the wrapper resets SIGPIPE too.
- `javac` without `-parameters` and with it write different `MealType.class` files for one source (What differed, 2).
- H2's file database keeps its name relative to the JVM's folder (`jdbc:h2:./db/enum` from `.harness/run`); a constraint violation on
  H2 is logged as two WARN lines, the second carrying the SQL on its own line (`insert into … [23513-250]`).
- On Postgres, Hibernate's session starts with `set client_min_messages = WARNING` only when it generates a schema: build 2 (schema
  generation off) logs a `select` first.
- Postgres's failing-row detail names the id the identity column handed out (`(3, 4, Kavya)`: ordinal 3, id 4 — the three rows took 1-3).

## CARRIED

- RE-MEASURE 4 (a renamed constant's insert into `Database`'s unchecked `VARCHAR(10)`) → unspoken here; *Never Use ddl-auto in
  Production* (U35) / *Flyway* (U36) own the schema the checks would live in.
- Hibernate's DDL ≠ `Database`'s for `meal_type` on H2 (ⓘ3; `anchor` prints both) → U35 / U36 (`validate` against a migrated schema).
- `08`'s `xcheck` compares with this unit's md5 `820b43fc…` ("Boot's script as 07 captured it", R.212).
- The builder (s707) must refuse the dish-name list in SAY lines and on slides (R.215) and assert `duration words: 0` (R.172) itself.

## For RED

Re-run from a clean tree (seeded `.m2-demo`, `HOME` with dead proxies, `DOCKER_CONFIG`) in a process group of its own; ports 20200-20279
for any re-run of this unit's JVMs or container outside its script. Worth breaking: whether build 2 could pick up build 1's classes
(the two-build check reads the JVM's own `MealType in this build` line beside the class directories' diff); whether the H2 file could
outlive the capture (R.195: the hygiene finds none, `.harness/` included); the claim "no error anywhere" for the reorder (the check
greps build 2's block for WARN, ERROR and EXCEPTION — not TiffinBox, which never runs a reordered enum); the password's visibility in
`ps` while a JVM runs (a test password, one run's container). Evidence by a Claude Opus 5.5 agent on 2026-11-04.
