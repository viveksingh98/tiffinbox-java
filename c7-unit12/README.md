# c7-unit12 — Inheritance: Three Strategies

Course 7 · Data with JPA & Hibernate · Section 2 (Mapping), its seventh unit — **a harness unit: no change to the anchor** · Verified on
**JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.2** (Hibernate ORM 7.4.13.Final, Jakarta Persistence 3.2.0, H2 2.5.250 — the
anchor's pin — and **PostgreSQL 18.6** in a container, the PostgreSQL JDBC driver **42.7.14**), 2026-11-05. One abstract `Meal` (id,
title, `int price`) with two kinds — `PlatterMeal` (`int dishes`) and `SaladMeal` (`String dressing`) — stored three ways: one wide
table (`SINGLE_TABLE`), a table per class joined (`JOINED`), a table per concrete class unioned (`TABLE_PER_CLASS`). The same
`select m from Meal m` is **one statement every time** — and PostgreSQL plans it in **3 lines, 11 lines, 5 lines**. And one strategy
refuses the id TiffinBox uses: `TABLE_PER_CLASS` with `IDENTITY` does not start, on either database.

**Which database answered — every capture says it in its own `database:` lines (§4.4, S2.12):** `ddl`, `tpcidentity` and `sql` — H2
**and** PostgreSQL, each run beside the other; **`plans` — the plan slide is PostgreSQL's** (three fresh databases per strategy), H2's
`EXPLAIN` printed beside it and labelled as the query rewritten; `mapped`, `xcheck` and `exercise` — H2 only.

**No anchor change.** `anchor` is the link to `../c7-unit09/after`, the tree Section 2 froze. `receipts.sh` prints `diff -rq -x .m2-demo
-x target -x secrets anchor/ ../c7-tiffinbox` at its start and end — empty in every run of record — and, from any later anchor change
on, prints a note instead, never a stop (R.211). The anchor is copied under `.harness/anchor` and built there, never in place.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 7 captures, 3 runs each; every spoken number checked after its capture; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version` and `javac -version` say 25.) It **dies** when a
capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first), and when a check after a capture fails. **Start it in
a process group of its own** (a terminal's foreground job is one), with SIGINT at its default: `sweep()` stops only processes of its own
group. `.m2-demo` must be seeded first (below). **Docker must answer** (OrbStack here) and **the image must already be on the computer**
(`docker image inspect postgres@sha256:77f58511…`; a receipt never pulls — a missing image stops it with the `docker pull` line to type).
No TiffinBox JVM.

**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`), a session of its own (`setsid`,
SIGINT at its default), `.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s2/` alone (6,613 files). Development
runs fixed the captures and the checks (the second added `mapped`'s full-name query; later edits changed only check order and the
README's dish gate — no capture changed; Found on the way).
**The runs of record, on the script as committed (`receipts.sh` md5 `6e3497ef09265a712cd3a00818a63c14`): 210 s under `./receipts.sh`**
(/bin/bash 3.2.57) **and 220 s under `bash receipts.sh`** (Homebrew bash 5.3.9): each exit 0, all 7 captures 3/3 = published, every
check passed, both builds `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`, the container up on `127.0.0.1:19918` only and
removed, 0 raw passwords, the anchor note empty at the start and the end, nothing listening on 18425, 8080, 35729 or 19910-19919 at the
end; each terminal log through `check_unit7.py 12 --runlog` — `0 grep error line(s)`, `RESULT (run logs): PASS`. The builders'
`_builders/dur7.py` over this README and the exercise's two files: 0 duration words. Those two ran with this README as then drafted
(its run-of-record paragraphs since filled in, no command line changed); **on the tree as committed** — this README final — one more
`./receipts.sh`: exit 0 in 200 s, all 7 = published, `--runlog` PASS. **Nothing was downloaded**, and this unit made no network act.

Published hashes: ddl `fb6f626b1dd1bbe07334314707e3ee40` · tpcidentity `73527536610eb00da03b79ddb635cfc4` · sql `833dfe8fbe4bd5f6a144ae4daa4ffa7a` · plans `6af85915bdb19d6484537d492c06dc8f` · mapped `d54529ac6632e855f240edd50fabae3d` · xcheck `1fed0d75f13d85ed188ccf2046d464ba` · exercise `11950dbab0e36b61e3e047173517de4b`.

### A sealed fresh clone — the recipe (R.129)

**Paste it into bash.** Unit 11's recipe, with this unit's folder and Docker's config handed through `env -i` (`DOCKER_CONFIG`: the
OrbStack context lives in `~/.docker`; the clone's `HOME` is the sealed one):

```bash
S=/tmp/sealed12; W="/tmp/sealed 12"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
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
X=http://127.0.0.1:9; E="env -i HOME=$S/home PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin http_proxy=$X https_proxy=$X HTTP_PROXY=$X HTTPS_PROXY=$X"
$E JAVA_HOME=/opt/homebrew/opt/openjdk@25 mvn -B -Dmaven.repo.local="$S/preflight-m2" org.apache.maven.plugins:maven-dependency-plugin:3.8.1:get -Dartifact=org.example.sealed:absent:1 > "$S/preflight.log" 2>&1
[ $? != 0 ] && grep -q 'Downloading from sealed: file://' "$S/preflight.log" && ! grep -qE 'Downloading from [^ ]+: https?://' "$S/preflight.log" && echo "sealed: file:// only" || echo "NOT SEALED - do not run receipts.sh"
cd "$W/tiffinbox-java/c7-unit12" && readlink anchor && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E DOCKER_CONFIG=$HOME/.docker ./receipts.sh            # a process group of its own
```

**Run (2026-11-05):** a `git clone` of tiffinbox-java at `8ba9069` into a path **with a space** (`…/sealed 12/tiffinbox-java`), this
commit's 30 files put in as git takes them (`git ls-files -o --exclude-standard c7-unit12`; `anchor` → `../c7-unit09/after` by
`readlink`; `receipts.sh` the committed `6e3497ef…`, README.md this one as then drafted — its run-of-record paragraphs since filled in,
no command line changed); a `file://` copy of the s2 seed (4,971 files); pre-flight: exit 1, 221 `Downloading from sealed: file://`, 0
from http(s); the clone's `.m2-demo` seeded from that copy; `/bin/bash` 3.2, `env -i` with the dead proxies and `DOCKER_CONFIG`, a
session of its own: **exit 0 in 204 s, all 7 = published, every check passed**; both builds `offline: yes · exit 0 · 'Downloaded from'
lines in its log: 0`; after the run `.m2-demo` held 4,971 files, 0 `_remote.repositories`; the builders' `dur7.py` and unit 09's captures
are not beside a clone (the terminal says so for each; `dur7.py`'s md5 and Boot's script md5 are the checks). Its terminal log through
`--runlog`: PASS.

## The commands this unit adds

```bash
docker run -d --pull never --name c7-u12-pg -e POSTGRES_USER=sa -e POSTGRES_PASSWORD="$PGPW" -p 127.0.0.1:19918:5432 postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
mvn -o -B -Dmaven.repo.local="$M2" dependency:build-classpath -Dmdep.outputFile=classpath.txt
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:.harness/drv/*" harness/src/probe/map/H.java harness/src/probe/map/Main.java harness/src/probe/map/Shown.java harness/src/probe/map/single/*.java harness/src/probe/map/joined/*.java harness/src/probe/map/tpc/*.java harness/src/probe/map/tpcid/*.java harness/src/probe/map/mapped/*.java
java -Duser.language=en -Duser.country=US -Dlogback.configurationFile=../../harness/logback.xml "${V[@]}" -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*:../drv/*" probe.map.Main "${A[@]}"
```

**The container** (one per run, started after the build and before the captures, removed at the end and by every exit — `$PGPW` is the
run's generated password, printed masked); **the driver** (run in `.harness/drvpom`, a copy of `harness/pom.xml`: Boot 4.1.2's parent and
`org.postgresql:postgresql` with no version written — Boot's managed **42.7.14**, with `checker-qual-3.55.1`, both copied to
`.harness/drv`); the harness compiled against the anchor's extracted jar (91 libraries) and the driver; **the harness line** (run from
`.harness/run`: `V` its JVM flags — on PostgreSQL `-Ddb=pg -Dpg.port=19918 -Dpg.passfile=../pg/password` — `A` its arguments; R.193,
each printed as `$ V=(…)` / `$ A=(…)`). The lines read from `anchor/README.md` (2, each asserted whole): `mvn -B package` and the extract
line — unit 11's.

## The repository, and the network

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s2/` alone (6,613 files). Two builds: the anchor's `package` (its 18 tests run inside
it) and the driver's `dependency:build-classpath`, each `offline: yes` with 0 `Downloaded from` lines in every run of record (the label
is derived from the build log, never typed). After them the script asserts `.m2-demo` holds `spring-boot-starter-parent-4.1.2.pom`,
`hibernate-core-7.4.13.Final.jar`, `h2-2.5.250.jar` and `postgresql-42.7.14.jar`. **The image is never pulled** (`--pull never`; its id
asserted equal to the digest before the run). **At run time** nothing leaves the computer: H2 in a harness JVM's memory, PostgreSQL on
`127.0.0.1:19918`. **No network act**: this unit reads no version file — unit 06 made Section 2's dated sweep
(`../../../data-jpa-hibernate/_research/spring-boot-metadata-2026-11-04.xml`: 4.1.2 the newest 4.1.x GA; R.223), and no Section 2 unit
speaks a "newest" fact.

## The locale

Every java line carries `-Duser.language=en -Duser.country=US`; a last check refuses a capture's java line without it; the test fork's
comes from the POM's `argLine`. **The harness prints ASCII** (` | ` between facts).

## The folders, the harness, the database and the ports

- `anchor` — the link to `../c7-unit09/after` (asserted: a link, that target). `.harness/anchor` — its copy, built with the README's
  `mvn -B package` offline, its jar extracted (91 libraries); `.harness/drv` — the driver; `.harness/hc` — the harness, compiled;
  `.harness/run` — where every harness JVM starts (its scripts land there); `.harness/pg` — the password's file (mode 0600, the folder
  0700) and the container's id; `.harness/ex` — the exercise's classes.
- **The harness** — the course's, never TiffinBox's (`harness/src/probe/map`, package `probe.map`; a check refuses `probe.map` anywhere in
  the anchor's code). `H.java` is unit 11's (one `EntityManagerFactory` per run, `PersistenceConfiguration` over the classes the run
  names, Boot's two naming strategies, statistics on, `drop-and-create` on the run's own database only; the JDBC proxy counting the
  driver's calls) with unit 07's PostgreSQL path (`-Ddb=pg`: **a fresh database per run** — `DROP DATABASE IF EXISTS … WITH (FORCE)` and
  `CREATE DATABASE` through the container's `sa` database — and its `database:` line: `select version()` cut before ` on `, the URL, the
  user, **the driver's name and version from the connection's metadata**), and one addition: **`Insp`, a `StatementInspector`** that keeps
  every SQL string Hibernate prepares — the `plans` capture hands the very string it kept to `EXPLAIN`. Every JVM prints
  `org.hibernate.Version.getVersionString()` first and Hibernate's own `HHH000001` line (its core logger at INFO — R.222, #311).
  Scenarios (`Main.java`): `ddl STRATEGY FILE`, `sql STRATEGY`, `plan STRATEGY ROUNDS`, `mapped FILE`, `start STRATEGY FILE`, `ex
  PACKAGE`, `xcheck FILE`. Every run writes one Platter (120, 3 dishes) and one Salad (90, lemon).
- **Entities** (English names only — S2.10, R.215, RE-MEASURE 9; tables `meal`, `platter_meal`, `salad_meal`, apart from the anchor's
  `customer`/`pause` — S2.7): one package per way of storing them, each with the same three classes — an abstract `Meal` (`@Id
  @GeneratedValue Long id`, `String title`, `int price`), `PlatterMeal extends Meal` (`int dishes`), `SaladMeal extends Meal` (`String
  dressing`), all implementing `probe.map.Shown` (what a meal prints of itself): `probe.map.single` (`SINGLE_TABLE`, `IDENTITY`),
  `probe.map.joined` (`JOINED`, `IDENTITY`), `probe.map.tpc` (`TABLE_PER_CLASS`, `SEQUENCE`), `probe.map.tpcid` (`TABLE_PER_CLASS`,
  `IDENTITY` — the failure receipt), `probe.map.mapped` (`Meal` a `@MappedSuperclass`, `IDENTITY`), and the exercise's `probe.map.ex`
  (`TABLE_PER_CLASS`, `IDENTITY` as shipped; never compiled into `.harness/hc`, asserted). The discriminator's values are the entity
  names, `PlatterMeal` and `SaladMeal`. `harness/logback.xml` — unit 11's, its comment naming this lesson; `harness/pom.xml` — unit 07's
  driver POM (`u12-driver`); `harness/dur7.py` — the builders', md5 `41667fed…`, byte for byte.
- **The database** (S2.9): `postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873` (`postgres:18-alpine`,
  PostgreSQL 18.6), `docker run -d --pull never --name c7-u12-pg`, `POSTGRES_USER=sa`, **a 24-character password generated per run**
  (`head -c 4096 /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | head -c 24` — unit 07's bounded form), published on **`127.0.0.1:19918` only**
  (`docker port` asserted to be `5432/tcp -> 127.0.0.1:19918` and nothing else), `pg_isready` awaited, **removed** (`docker rm -f`) at the
  end — asserted gone (`docker ps -a --filter name=c7-u12-pg`: 0 lines) — and by the EXIT trap. Before it: Docker answers, the image's id
  equals the digest, no container of that name exists. `open-webui` (someone else's, `0.0.0.0:3000`) is never touched: the script names
  only its own container.
- **Ports** (§P, 19910-19919): **19918 the container's**, on 127.0.0.1; **19919 never bound** (asserted free at the start, after the
  container is up, and at the end). 19910-19917, 18425, 8080 and 35729 checked free first and last; nothing of this unit binds them.

## Masks, filters and hygiene — every one, declared

1. **`mask()`** (`gsub()`, literals escaped; checked first on planted lines, the planted password among them): **the database password →
   `[masked: the 24-character password]`**; this folder → `…`, the folder above → `…/..`, home → `~`, the user name → `<user>`; ` using Java
   <version>`; an identity hash → `@…`; Hibernate's generated constraint names → `FK<hash>` / `UK<hash>`; **H2's generated index and
   constraint names → `PRIMARY_KEY_<n>`, `CONSTRAINT_<n>`** (#320 — in H2's `EXPLAIN`: `/* PUBLIC.PRIMARY_KEY_<n> */`). PostgreSQL's
   index names (`platter_meal_pkey`) are the table's name plus `_pkey`, not generated hashes: kept.
2. **The password, counted raw** (S2.9): every raw capture run — before the mask — must hold it **0** times, else the run stops naming
   the capture; at the end every file of this folder but `.m2-demo` holds it **once**: its own file. The harness reads the file and never
   prints it; no URL carries it (the harness logs in through `PGSimpleDataSource`, user and password set apart from the URL).
3. **A harness log** (`hview`): every line, trailing spaces dropped. **A Maven log**: never printed in a capture; its exit, `offline` and
   `Downloaded from` count go to the terminal.
4. **The plan's costs** (R.201): PostgreSQL's `EXPLAIN` prints `cost=`, `rows=` and `width=`; every round prints, right above the plan's
   lines, **"its cost=, rows= and width= are planner estimates for tables never analysed, not measurements"**, and the check refuses a
   plan line without that label above it. They are on screen, labelled — not masked.
5. **Hygiene, checked last over every capture** (unit 11's list): no absolute path, no unit number, no time, no log time, no thread
   number, no JDK/OS version token, no unmasked generated database name, no unmasked constraint or index name, **no port but the
   container's 19918**, no per-run timing figure, no stack frame; every java line pinned; `GenerationTarget encountered exception` 0 in
   every harness log (R.213); no SQL keyword as an entity or field name; no H2 database file anywhere in this folder; no `pkill`/`killall`;
   no bare `wait`; no one-string multi-option variable (R.193); **no Indian dish name** in any capture (R.215).
6. **Duration words** (R.172): `dur7.DUR` over this README and the exercise's two files must find **0** — this unit speaks no time.
   **Dish names** (R.215, S2.10): 43 words, whole words, any case — unit 11's 41 plus `curry`, `curries` (the probe's field) — and
   **the probe's own names for this lesson, `ThaliMeal` / `curries` (RE-MEASURE 9), inside any identifier** — are refused in
   `exercise/` and `harness/src` before anything is built, in this README (except on a line that says "the probe", as history), and in every capture at the end.

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the Maven it
waits for (`$mpid`, with every process under it — Surefire's fork), the exercise's shell (`$xpid`), sweeps its own process group for any
harness JVM, Maven or Surefire fork left, **removes the container** (`docker rm -f c7-u12-pg`, if this run started it), deletes the
capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched. No `wait` in the script
or the exercise is bare.

**Measured (2026-11-05, a scratch mirror holding the seven published captures, the script as committed):** `./receipts.sh` (/bin/bash
3.2) started in a session of its own with SIGINT at its default, `kill -INT` to its group once the named process was in it, the state read
5 s later — each **exit 130, nothing left, the container gone**:

```
build: processes in the group at SIGINT 3 · container up at SIGINT 0 · exit 130 · 5 s later in the group: 0 · container 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java: 0
harness: processes in the group at SIGINT 3 · container up at SIGINT 1 · exit 130 · 5 s later in the group: 0 · container 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java: 0
container: processes in the group at SIGINT 3 · container up at SIGINT 1 · exit 130 · 5 s later in the group: 0 · container 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java: 0
```

`build` — the anchor's Maven (its Surefire fork), before the container; `harness` — the first harness JVM (`ddl` `SINGLE_TABLE` on H2),
the container up; `container` — the first PostgreSQL harness JVM (`-Ddb=pg`, its fresh database open in the container). `pgrep -fl java`
afterwards: none; `docker ps -a --filter name=c7-u12-pg`: 0 lines.

## 1 · ddl — three ways to store one Meal (H2 and PostgreSQL, the scripts byte-equal)

Each strategy's factory writes its script and runs it on its own fresh database, on H2 and then on PostgreSQL; the capture prints both
scripts and `cmp`s them — **H2 = PostgreSQL, byte for byte, for all three** — then the rows each table holds after one Platter and one
Salad, by a second connection (the same on both):

- **`SINGLE_TABLE` — one table:** `create table meal (dishes integer, price integer not null, id bigint generated by default as identity,
  dtype varchar(31) not null check ((dtype in ('PlatterMeal','SaladMeal'))), dressing varchar(255), title varchar(255), primary key
  (id), check (dtype <> 'PlatterMeal' or (dishes is not null)));` — the **discriminator** `dtype`, its values the entity names; the
  platter's `int dishes` (not null in Java) is **a nullable column plus a table check** — a salad row has no dishes. Rows: `1 | PlatterMeal
  | Platter | 120 | 3 | null`, `2 | SaladMeal | Salad | 90 | null | lemon`.
- **`JOINED` — a table per class:** `meal (price, id … identity, title)`, `platter_meal (dishes integer not null, id bigint not null,
  primary key (id))`, `salad_meal (id bigint not null, dressing …)`, and two foreign keys `… (id) references meal` (`FK<hash>`). Rows:
  `meal` `1 | Platter | 120`, `2 | Salad | 90`; `platter_meal` `1 | 3`; `salad_meal` `2 | lemon`.
- **`TABLE_PER_CLASS` (with `SEQUENCE`) — a table per concrete class:** `create sequence meal_seq start with 1 increment by 50;`,
  `platter_meal (dishes integer not null, price integer not null, id bigint not null, title …)`, `salad_meal (price …, id …, dressing …,
  title …)` — **no `meal` table** (asserted); each table repeats `price` and `title`; ids **1 and 2 from the one sequence**.

## 2 · tpcidentity — the id TiffinBox uses, refused (B/A′; B the failure receipt, H2 and PostgreSQL)

- **B — `TABLE_PER_CLASS` + `@GeneratedValue(strategy = GenerationType.IDENTITY)`** (`probe.map.tpcid`), on H2, then on PostgreSQL:
  **exit 1** — **`jakarta.persistence.PersistenceException: Unable to build Hibernate SessionFactory  [persistence unit: u12starttpcid]`**
  ← **`org.hibernate.MappingException: Cannot use identity column key generation with <union-subclass> mapping for:
  probe.map.tpcid.Meal`**; no factory, **no SQL line, no script written** (`(none: no such file)`). The `database:` line and both
  version lines print before it (the JVM reached the database; Hibernate refused the mapping).
- **A′ — the same strategy with `SEQUENCE`** (`probe.map.tpc`), each its own JVM, on both: **it starts**, the script is `ddl`'s
  `TABLE_PER_CLASS` one, `select nextval('meal_seq')` (PostgreSQL) / `next value for meal_seq` (H2), ids 1 and 2.

## 3 · sql — one statement, three shapes (H2 and PostgreSQL)

`select m from Meal m order by m.id` in a new EntityManager, the counters reset: **one statement in every strategy on both databases —
the SQL log's lines between the markers, `getPrepareStatementCount()` and the driver's `prepareStatement`, all three 1** (R.184);
`entities loaded 2`; both back as their own class (`PlatterMeal 1 … ; SaladMeal 2 …`). The `StatementInspector` kept the same one string.

- `SINGLE_TABLE`: `select m1_0.id,m1_0.dtype,m1_0.price,m1_0.title,m1_0.dishes,m1_0.dressing from meal m1_0 order by m1_0.id` — one table.
- `JOINED`: `select m1_0.id,case when m1_1.id is not null then 1 when m1_2.id is not null then 2 end,m1_0.price,m1_0.title,m1_1.dishes,
  m1_2.dressing from meal m1_0 left join platter_meal m1_1 on m1_0.id=m1_1.id left join salad_meal m1_2 on m1_0.id=m1_2.id order by
  m1_0.id` — two `left join`s and a `case` that says which kind.
- `TABLE_PER_CLASS`: `… from (select dishes, price, id, title, null as dressing, 1 as clazz_ from platter_meal union all select null as
  dishes, price, id, title, dressing, 2 as clazz_ from salad_meal) m1_0 order by m1_0.id` on **H2**; on **PostgreSQL** the nulls are typed —
  **`cast(null as varchar) as dressing`**, **`cast(null as integer) as dishes`** — the one SQL text that differs between the two
  databases here (S2.12: both `database:` lines in the capture).

## 4 · plans — the plan slide is PostgreSQL's (three fresh databases; H2's EXPLAIN beside it)

Per strategy, **one PostgreSQL JVM, three rounds, each on a fresh database** (`u12plan<strategy>1..3`, each with its own `database:`
line): the two rows, the polymorphic query, the SQL the inspector kept, then **`explain <that SQL>`** over a second connection (no
`ANALYZE`) — every line, its count and the md5 of the plan text:

| strategy | PostgreSQL 18.6 — the plan slide | lines | md5 ×3 (RE-MEASURE 13) |
|---|---|---|---|
| `SINGLE_TABLE` | `Sort` · `Sort Key: id` · `->  Seq Scan on meal m1_0` | **3** | `f152979c1eb05562eb77e536ee54047f` ×3 |
| `JOINED` | `Nested Loop Left Join` → `Merge Left Join` (`Merge Cond: (m1_0.id = m1_2.id)`) over two `Sort` / `Seq Scan` (meal, salad_meal) + `Index Scan using platter_meal_pkey on platter_meal m1_1` (`Index Cond: (id = m1_0.id)`) | **11** | `206f3486a8ff1b87815f3df5e281c5ae` ×3 |
| `TABLE_PER_CLASS` | `Sort` · `Sort Key: platter_meal.id` · `->  Append` → `Seq Scan on platter_meal`, `Seq Scan on salad_meal` | **5** | `e99f8618d3755f53cb60662e97865541` ×3 |

**RE-MEASURE 13 is settled for all three strategies:** the plan text — costs included — is the same over three fresh databases, md5 per
strategy above. **The costs are planner estimates for tables never analysed, not measurements** (the label printed above every plan,
checked; `rows=70`, `rows=140` for tables that hold one or two rows): a slide shows the plan's shape and keeps the label beside any number.

**H2's `EXPLAIN` beside it** (one H2 JVM per strategy, its own `database:` line), labelled **"the query rewritten, with its index
comments"**: not a plan tree but the SELECT again, quoted and upper-cased, with `/* PUBLIC.PRIMARY_KEY_<n> */`, `/* index sorted */`,
`/* PUBLIC.SALAD_MEAL.tableScan */` comments — **11 / 17 / 47 lines**. The voice says "H2 answers with the query rewritten" and never
calls it a plan.

**The numbers the video may say, as the capture gives them** (checked against this line by `receipts.sh` — a typed count fails it): the plan line counts: PostgreSQL 3 / 11 / 5 · H2 11 / 17 / 47

## 5 · mapped — @MappedSuperclass, the fourth way, not a strategy (H2)

`Meal` is a `@MappedSuperclass` with the id (`IDENTITY`); `PlatterMeal` and `SaladMeal` are the entities. The script: **two tables**,
`platter_meal` and `salad_meal`, **each with its own identity column**, no `meal` table. One Platter, one Salad: **both get id 1** —
`platter_meal [1 | Platter | 120 | 3]`, `salad_meal [1 | Salad | 90 | lemon]`: two id counters, each starting at 1.
- **`select m from Meal m order by m.id` is refused:** `java.lang.IllegalArgumentException: org.hibernate.query.sqm.UnknownEntityException:
  Could not resolve root entity 'Meal'`; **0 statements** reached the driver. `Meal` is no entity: JPQL has no name for it.
- **The same class named in full** — `select m from probe.map.mapped.Meal m` — **is answered**: Hibernate queries every entity that
  extends the class, **2 statements** (one SELECT per table: the SQL lines, `getPrepareStatementCount()` and `prepareStatement`, all 2),
  and both meals come back — **each with id 1**. (Found on the way: the brief's "impossible" holds for the entity name only.)

## 6 · xcheck — the harness's DDL against Boot's, as unit 09 captured it (R.212, RED #308; H2)

The harness's own EntityManagerFactory over `com.tiffinbox.CustomerEntity` and `com.tiffinbox.PauseEntity` (from the anchor's jar)
writes `xcheck.sql`: three lines, **md5 `f595637014e786fa38606859951e4f97` = Boot's script as unit 09 captured it** — the md5 read from
`../c7-unit09/README.md` (asserted there) and that capture's own published md5 `9072c6f1…` read from `../c7-unit09/receipts.md5` before
any build. **No Boot run** (this unit binds no port of its own but the container's). When `../c7-unit09/.r-xcheck.out` is on disk with
its published md5, Boot's three lines are read from it and each asserted in this capture too (a clone has no captures: the md5 is the
comparison).

## 7 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196; H2)

`exercise/README.md`'s 7 lines, then `exercise/SOLUTION.md`'s (the README's with one line changed: the copy of `Meal.java` made with
`sed`, `GenerationType.IDENTITY` → `GenerationType.SEQUENCE`), each block sourced in one `env -i` shell, `/bin/bash --noprofile --norc`
then `/bin/zsh -f`; each block in a fresh JVM. In both: the README → **`exit 1`**, the `PersistenceException` ← `MappingException:
Cannot use identity column key generation with <union-subclass> mapping for: probe.map.ex.Meal`; the solution → **`exit 0`**, `the
EntityManagerFactory was built`, `platter_meal [1 | Platter | 120 | 3]`, `salad_meal [2 | Salad | 90 | lemon]`; the shell back in this
folder; bash's output = zsh's.

## Exercise

**Your turn:** the README stores each meal kind in its own table and Hibernate refuses to start. Give it an id it can use.
(24 words, `wc -w` on the quoted sentence, asserted in `receipts.sh`.) `exercise/README.md` ships `TABLE_PER_CLASS` with `IDENTITY`,
`exercise/SOLUTION.md` beside it; broken (exit 1, the MappingException, no factory) ≠ solved (exit 0, two rows, ids 1 and 2), each from
its own fresh JVM, measured by the `exercise` capture (R.196).

## What the video may say — and the capture each comes from

- **The hook (PostgreSQL, `plans`):** `select m from Meal m` — one statement each time (`sql`, both databases); **its plan is 3 lines,
  11 lines, 5 lines** — "PostgreSQL's plan", the costs labelled planner estimates, never read as measurements. The same plan text on
  three fresh databases each (RE-MEASURE 13).
- **H2 answers `EXPLAIN` with the query rewritten** (11 / 17 / 47 lines, `plans`) — said so, never shown as "H2's plan".
- **Three DDLs, H2 = PostgreSQL** (`ddl`): one table with a `dtype` discriminator (`'PlatterMeal'`, `'SaladMeal'`) and the platter's
  dishes as a table check; three tables joined by id; two whole tables and one `meal_seq`, no `meal` table.
- **Three SQLs** (`sql`): one table; two left joins and a `case`; a `union all` — PostgreSQL's `cast(null as varchar)` beside H2's
  `null` (S2.12: both captures cited).
- **The failure receipt** (`tpcidentity` B, both databases): `TABLE_PER_CLASS` with `IDENTITY` → "Unable to build Hibernate
  SessionFactory" ← "Cannot use identity column key generation with `<union-subclass>` mapping"; with `SEQUENCE` it starts (A′). The
  reason Hibernate gives is the message; **why** is not captured (R.201) — the voice may point at `mapped`, where two identity columns
  each hand out id 1, as what the captures show, not as Hibernate's reasoning.
- **`@MappedSuperclass`** (`mapped`, H2): two tables, two counters, both meals id 1; `select m from Meal m` → "Could not resolve root
  entity 'Meal'"; the class's full name → two SELECTs, both back. Not "impossible to query" — "no entity named Meal".
- The harness's DDL = Boot's (`xcheck`). "Hibernate 7" for the version; each capture prints `7.4.13.Final` twice per JVM (`HHH000001` and
  `getVersionString()`, R.222) and, on PostgreSQL, the driver's `42.7.14` and `select version()`'s `PostgreSQL 18.6` (S2.17, S2.9).
- **Glossed at first use** (contract §10): a discriminator (the `dtype` column). Earlier glosses by title only.

## The ledger rows and hand-offs this unit pays

- No ledger row is paid here (the brief's §LEDGER names none for 12).
- RE-MEASURE 9 and 13 are settled here (below).

## RE-MEASURE — the brief's items this unit settles

| # | Settled here |
|---|---|
| 1 | the exercise as README + SOLUTION files, bash and zsh, `env -i`: exit 1 + the MappingException / exit 0 + two rows, a fresh JVM each half |
| 9 | the probe's `ThaliMeal` / `curries` refused in any name; English names: `PlatterMeal` / `SaladMeal`, `dishes`, "Platter" / "Salad"; the DDL's `check ((dtype in ('PlatterMeal','SaladMeal')))` and `check (dtype <> 'PlatterMeal' or (dishes is not null))`, H2 = PostgreSQL |
| 12 | `xcheck` on `09/after`: `f595637014e786fa38606859951e4f97` (Boot's script as 09 captured it) |
| 13 | PostgreSQL's EXPLAIN text stable over 3 fresh databases for **all three** strategies: `f152979c…` (3 lines) · `206f3486…` (11) · `e99f8618…` (5), each ×3 |

## What differed from the brief

1. **The MappingException names `probe.map.tpcid.Meal`, not "…SaladMeal".** The brief (from the probe's Step 7) quotes `Cannot use
   identity column key generation with <union-subclass> mapping for: …SaladMeal`; this harness's message names the abstract root,
   **`probe.map.tpcid.Meal`**, on H2 and PostgreSQL, 3/3. A scratch run outside the receipt with the classes handed over in the other
   order (Meal last) named `Meal` too (Found on the way). The script and the voice quote the capture: "…mapping for: …Meal".
2. **`mapped` adds the full-name query.** The brief: "`select m from Meal m` impossible — show the failure as a capture". The capture
   shows it (`UnknownEntityException: Could not resolve root entity 'Meal'`), and beside it `select m from probe.map.mapped.Meal m`, which
   Hibernate answers with two SELECTs — measured first in a scratch run, then put in the capture so "impossible" is not said beyond what
   was measured (R.201).
3. **The cost label's words.** The brief's "planner estimates for empty, unanalysed tables": the tables hold the run's two rows when
   `EXPLAIN` runs (the probe's order: write, query, explain), so the label says **"planner estimates for tables never analysed, not
   measurements"** — costs labelled, not masked (the brief allowed either).
4. **The three fresh PostgreSQL databases are three rounds in one JVM per strategy**, each `DROP DATABASE … WITH (FORCE)` / `CREATE
   DATABASE` with its own name and `database:` line, a new EntityManagerFactory each — not three JVMs. RE-MEASURE 13 asks for three
   fresh databases; the JVM is the same, the database, the schema and the factory are new. H2's `EXPLAIN` is one round (in memory).
5. **`ddl` and `sql` run on both databases** (the brief: DDL "H2 = PG", SQL with PG's typed nulls) — every strategy, each database its
   own JVM, the scripts `cmp`ed; **`mapped` runs on H2 only** (the probe found its DDL the same on both; nothing in the beat is
   PostgreSQL's) — said in its heading.
6. **`tpcidentity` is B/A′** as the brief names it (B the refusal, A′ the SEQUENCE start); A′ runs on both databases, each its own JVM.
   There is no A run apart from A′ (the brief's capture list names B/A′ only); `ddl`'s `TABLE_PER_CLASS` is the same mapping as A′.
7. **The ids:** `SINGLE_TABLE`, `JOINED` and `@MappedSuperclass` use `IDENTITY` (TiffinBox's own id strategy, the anchor's
   `CustomerEntity`); `TABLE_PER_CLASS` uses `SEQUENCE` (the only one of the two that starts) — the probe's choice, kept.
8. **One driver line printed per PostgreSQL run** — `driver PostgreSQL JDBC Driver 42.7.14` from the connection's metadata, in the
   `database:` line — rather than a separate version capture (the AMENDMENT: "printed in the capture, never typed"); asserted on every
   PostgreSQL run.
9. **The dish-name list gains `curry` and `curries`**, and the probe's `ThaliMeal` / `curries` are refused inside identifiers (a
   whole-word list cannot see `ThaliMeal`): the brief's plant "the probe's names → S2.10's refusal" needed it. This README names the
   probe's old names once, on a line that says "the probe" — the one exception the check allows.
10. **Plants on copies** (unit 11's form): each a scratch mirror (`c7-unit12` without its captures, `.m2-demo` a link to one scratch copy
    of the s2 seed, `c7-unit09/after`, its README, `receipts.md5` and `.r-xcheck.out`, `c7-tiffinbox`), the planted capture's hash taken
    out of the mirror's `receipts.md5` where named, so its check speaks. **They ran one after another, not side by side**: every run
    needs the one container name and port 19918 (the brief's limit), so two runs at once would collide.
11. **Check order chosen so each plant's named check speaks first:** in `plans` the three-rounds check (RE-MEASURE 13) runs before the
    PostgreSQL `database:` lines, so "one fresh database" and "H2 passed off as the slide" each fail on their own words.

## Planted faults — each caught (R.65)

On copies (What differed, 10), one after another, each **exit 1**, nothing written to this folder; after each: 0 listeners on
19800-20399, no harness JVM, no container. Fifteen, on `receipts.sh` `6e3497ef…` (the one committed):
- **H2's `EXPLAIN` passed off as the plan slide** (`PLANDB=h2`; `plans` out of the mirror's `receipts.md5`) → `*** plans SINGLE_TABLE:
  the plan slide must be PostgreSQL's - the database: line of fresh database 1 (u12plansingle1): expected the line: … ***` (177 s).
- **`SEQUENCE` in `tpcidentity` B** (`TPCB=tpc`; `tpcidentity` out) → `*** tpcidentity B on H2: the failure trio - PersistenceException:
  Unable to build Hibernate SessionFactory: expected the line: … ***` (79 s).
- **The probe's names** (`single/PlatterMeal.java` as the probe's `ThaliMeal` with `curries`) → `*** an Indian dish name, or the probe's …
  (R.215, RE-MEASURE 9: English names only): harness/src/probe/map/single/PlatterMeal.java:5:… ***` (2 s), before anything is built.
- **A typed plan line count** (this README's line given `3 / 12 / 5`) → `*** README.md does not state the plan line counts this capture
  gives ('the plan line counts: PostgreSQL 3 / 11 / 5 · H2 11 / 17 / 47') - a typed count: … 3 / 12 / 5 … ***` (175 s).
- **The plan's raw cost numbers unlabelled** (`Main.plan`'s label cut to "PostgreSQL's EXPLAIN (no ANALYZE):"; `plans` out) → `*** plans
  SINGLE_TABLE: the plan's cost numbers are on screen without their label ('planner estimates for tables never analysed, not
  measurements') in every round ***` (332 s).
- **A wrong image digest** (`IMG`'s last digit) → `*** the image is not on this computer: docker pull postgres@sha256:…a1874 ***` (2 s),
  before any build; no container started.
- **A raw database password in a capture** (`H.ds` printing it in the `database:` line; `ddl` out) → `*** ddl: its raw output (run 1) held
  the database password - the mask would hide it; nothing may print it (S2.9) ***` (32 s) — the mask alone would have hidden it.
- **A wrong published hash** (`receipts.md5`'s `ddl`, last digit) → `*** ddl is not the published capture … ***` (56 s).
- **A version claim without its `HHH000001` line** (`harness/logback.xml` without its `org.hibernate.orm.core` logger; `ddl` out) → `***
  ddl: the version lines - getVersionString() and Hibernate's HHH000001 - once in each of its 6 harness JVMs (R.222) ***` (54 s).
- **`xcheck` against a wrong 09 md5** (`X09` changed) → `*** ../c7-unit09/README.md no longer states Boot's script md5 …e4f96 - the number
  this unit compares with ***` (21 s), before any capture.
- **An EXPLAIN run on one fresh database claimed stable** (`ROUNDS=1`; `plans` out) → `*** plans SINGLE_TABLE: three rounds - three fresh
  databases (RE-MEASURE 13): expected the line: PROBE round 3 of 3: ***` (168 s).
- **One per capture class:** `plans`, `tpcidentity`, `xcheck` above; `ddl` — the platter's `int dishes` made `Integer` (`ddl` out) →
  `*** ddl SINGLE_TABLE on H2: the script - expected, every line: create table meal (dishes integer, … ***` (54 s); `sql` — the SQL logger
  silenced in `sql` (`-Dsql=WARN`; `sql` out) → `*** sql SINGLE_TABLE on H2: the SQL Hibernate sent: expected the line: … ***` (129 s);
  `mapped` — `Meal` made an `@Entity` (`mapped` out) → `*** mapped: two tables, each its own identity, no meal table: the script … ***`
  (171 s); `exercise` — `SOLUTION.md`'s `sed` given a pattern that matches nothing (`IDENTITY )`: the copy unchanged, still one line
  differing; `exercise` out) → `*** exercise: the solution - SEQUENCE, it starts, two rows: expected the line:     exit 0 ***` (193 s).
- An earlier batch on `997a6627…` (`ver plans` first in `chk_plans`) caught the H2 slide and the one-round plants by the `database:`-line
  count instead of their own words; `ver plans` moved last (What differed, 11) and the fifteen re-run. Its `unlabelled` plant deleted a
  line that broke the compile (caught as `the harness did not compile`): replaced by the label cut above.

## Found on the way

- **The full class name answers what the entity name cannot** (`mapped`): `select m from probe.map.mapped.Meal m` → 2 SELECTs, both
  meals; first measured in a scratch run (`t.T`, outside the receipt), then captured.
- **The MappingException names the root, `Meal`,** in either order of the classes handed to `PersistenceConfiguration` (a scratch run
  with `Meal` last: the same message). The probe's `…SaladMeal` is not reproduced here; not chased further.
- **`TABLE_PER_CLASS` + `SEQUENCE` calls `nextval` twice for two rows on PostgreSQL** (`select nextval('meal_seq')` ×2 before the
  commit, `increment by 50`) — printed in `tpcidentity` A′ and `ddl`; not a beat, not voiced.
- **The JDBC metadata's driver line** is `PostgreSQL JDBC Driver 42.7.14`; `select version()` is cut before ` on ` (the build platform).
- **A development run inherited the tool's process group** (started from the agent's own shell, not a session of its own); it ran to
  the end, and every later run — of record, plant, interrupt — was started in a session of its own (`setsid`), as the header says.
- **The README's dish gate split hits on `;`** (its first form): a README line naming the probe's names beside a `;` was cut in two and
  refused though it said "the probe"; the gate now reads whole lines. Two driver batches stopped at it before any capture — no capture
  changed.
- The harness's core logger at INFO prints `HHH000489: No JTA platform available …` in every JVM that builds a factory — deterministic, kept.

## CARRIED

- **Why** `TABLE_PER_CLASS` refuses `IDENTITY` (Hibernate's reasoning) → not captured; the slide shows the message and the voice says
  what it says (R.201).
- **The planner's numbers on analysed tables** (`ANALYZE` first, or real row counts) → not measured; no beat needs them (the brief: "the
  plan's costs are not measurements").
- **`@Inheritance` on the anchor** → none: no TiffinBox entity has kinds; the meals stay harness tables (⚑4).
- **`@DiscriminatorColumn` / `@DiscriminatorValue` renamed** (e.g. `kind`, `'P'`) → not measured; the defaults (`dtype`, entity names) are
  what the capture shows.
- `13-14`'s `xcheck` compares with unit 09's `f595637014e786fa38606859951e4f97` too (unchanged by this unit).
- The builder (s712) must refuse the dish-name list (and the probe's `ThaliMeal`/`curries`) in SAY lines and on slides, assert `duration words: 0`
  (R.172), assert the plan slide cites `plans` with two `database:` lines — PostgreSQL for the slide, H2 beside it (S2.12) — and keep
  the cost label on any slide that shows a `cost=`.

## For RED

Re-run from a clean tree (seeded `.m2-demo`, the image present, Docker answering) in a process group of its own with SIGINT at its
default; ports 20240-20279 for any re-run of this unit's JVMs or a container outside its script. Worth breaking: whether the plan line
counts hold with more rows or after `ANALYZE` (not measured — the hook's numbers are for two-row, never-analysed tables, and the voice
must not generalise them); whether the `JOINED` plan's join order depends on the subclass names (RED #317 saw it flip with the probe's
names — here `platter_meal` is the index scan); whether `@DiscriminatorValue` changes the `dtype` check (not measured); whether the full
class name query (`mapped`) keeps an `order by` across the two tables (measured without one); whether H2's `EXPLAIN` line counts move
with H2's patch (only 2.5.250 measured).
Evidence by a Claude Opus 5.5 agent on 2026-11-05.
