# c7-unit13 — Dates, Times and Zones

Course 7 · Data with JPA & Hibernate · Section 2 (Mapping), its eighth unit — **a harness unit: no change to the anchor** · Verified on
**JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.2** (Hibernate ORM 7.4.13.Final, Jakarta Persistence 3.2.0, H2 2.5.250 — the
anchor's pin — and **PostgreSQL 18.6** in a container, the PostgreSQL JDBC driver **42.7.14**), 2026-11-05. One entity, `OrderLog`,
holds one moment — Course 2's literal, `2026-09-14T18:30:00Z`, never `now()` — five ways: `wall` (`LocalDateTime`), `moment`
(`Instant`), `momentNoZone` (an `Instant` forced onto a `timestamp` column with `@JdbcTypeCode(SqlTypes.TIMESTAMP)` — Course 2's
column), `offsetAt` (`OffsetDateTime` at `+05:30`), `zonedAt` (`ZonedDateTime` in `Asia/Kolkata`). **A writer JVM in UTC, a reader
JVM in Asia/Kolkata, one database between them:** the two zone-less columns come back **`off by                           :
PT5H30M`** — Course 2's line, byte for byte, now printed through J-P-A — on H2 and on PostgreSQL; the `Instant` Hibernate maps by
default comes back `PT0S`, because its column is already **`timestamp(6) with time zone`**. That is C7-8, paid in the column.

**Which database answered, and which zones — every capture says it in its own lines** (§4.4, S2.12: a `database:` line per JVM; a
`JVM zone (TimeZone.getDefault().getID())` line per JVM, the zone its java line gave with `-Duser.timezone`): `ddl`, `zones`, `storage`,
`offset`, `jdbctz` — **H2 and PostgreSQL, each run beside the other**; `course2` reads files only (no JVM); `xcheck` and `exercise` —
H2 only. In `zones` and `jdbctz` H2 is **a file under `.harness/run/db/`** that two JVMs share — absent before the writer, listed between
the two, deleted after the reader and asserted gone (R.195) — and PostgreSQL a database in the container that the reader opens as the
writer left it.

**No anchor change.** `anchor` is the link to `../c7-unit09/after`, the tree Section 2 froze. `receipts.sh` prints `diff -rq -x .m2-demo
-x target -x secrets anchor/ ../c7-tiffinbox` at its start and end — empty in every run of record — and, from any later anchor change
on, prints a note instead, never a stop (R.211). The anchor is copied under `.harness/anchor` and built there, never in place.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 8 captures, 3 runs each; every spoken value checked after its capture; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version` and `javac -version` say 25.) It **dies** when a
capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first), and when a check after a capture fails. **Start it in
a process group of its own** (a terminal's foreground job is one), with SIGINT at its default: `sweep()` stops only processes of its own
group. `.m2-demo` must be seeded first (below). **Docker must answer** (OrbStack here) and **the image must already be on the computer**
(`docker image inspect postgres@sha256:77f58511…`; a receipt never pulls — a missing image stops it with the `docker pull` line to type).
No TiffinBox JVM.

**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`), a session of its own (`setsid`,
SIGINT at its default), `.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s2/` alone (6,613 files). Development
runs fixed the captures and the checks (the first stopped at its own `nowarn` check, which counted the per-JVM summary line as a WARN —
fixed; no capture changed since the second; later edits made the leftover H2 file a stop inside `pair()` — Found on the way).
**The runs of record, on the script as committed (`receipts.sh` md5 `56bf71eb7275b161344685f23f882781`): 272 s under `./receipts.sh`**
(/bin/bash 3.2.57) **and 364 s under `bash receipts.sh`** (Homebrew bash 5.3.9): each exit 0, all 8 captures 3/3 = published, every
check passed, both builds `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`, the container up on `127.0.0.1:19928` only and
removed, 0 raw passwords, `.harness/run/db` gone, the anchor note empty at the start and the end, nothing listening on 18425, 8080, 35729
or 19920-19929 at the end; each terminal log through `check_unit7.py 13 --runlog` — `0 grep error line(s)`, `RESULT (run logs): PASS`.
The builders' `_builders/dur7.py` over this README and the exercise's two files: 0 duration words. Those runs had this README as then
drafted (its run-of-record, interrupt and plant paragraphs since filled in; no command line, no `mine()` line and no gaps line changed).
**On the tree as committed** — this README final — one more `./receipts.sh`: exit 0 in 317 s, all 8 = published, `--runlog` PASS.
**Nothing was downloaded**, and this unit made no network act.

Published hashes: course2 `b41dd1ff8cdc68baa23699af5e4b751f` · ddl `e21431e1b9fbd6f972e63184988a510c` · zones `e884f07e4375a7012ab37ce5b0093ef8` · storage `8df35c84b7c286377d4c11089ce196cb` · offset `b461edb5d0d17e8c1cc30f1c004fa2ee` · jdbctz `0204963e76b26e7988743d41f60cc995` · xcheck `0bfd74c87a9191dbfab10faba2890eb5` · exercise `e5bcb1a44ac2e992f57016e023a0dfa9`.

### A sealed fresh clone — the recipe (R.129)

**Paste it into bash.** Unit 12's recipe, with this unit's folder (`DOCKER_CONFIG`: the OrbStack context lives in `~/.docker`; the
clone's `HOME` is the sealed one):

```bash
S=/tmp/sealed13; W="/tmp/sealed 13"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
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
cd "$W/tiffinbox-java/c7-unit13" && readlink anchor && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E DOCKER_CONFIG=$HOME/.docker ./receipts.sh            # a process group of its own
```

In a clone, Course 2's script (`../../../core-java-2/…`) and `java2_series.py` (on the author's Desktop) are not beside it: the
terminal says so for each, and the values this script holds for them — asserted against both files on every run where they are
there — are the check. `../c2-unit35/src/main/java/Connect.java` is in this repository and is read in every run.
**Run (2026-11-05):** a `git clone` of tiffinbox-java at `247067c` into a path **with a space** (`…/sealed 13/tiffinbox-java`, in the
session's scratch), this commit's 13 files put in as git takes them (`git ls-files -o --exclude-standard c7-unit13`; `anchor` →
`../c7-unit09/after` by `readlink`; `receipts.sh` the committed `56bf71eb…`, README.md this one as then drafted); a `file://` copy of the
s2 seed (4,971 files); pre-flight: exit 1, 221 `Downloading from sealed: file://`, 0 from http(s); the clone's `.m2-demo` seeded from that
copy; `/bin/bash` 3.2, `env -i` with the dead proxies and `DOCKER_CONFIG`, a session of its own: **exit 0 in 420 s, all 8 = published,
every check passed**; both builds `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`; after the run `.m2-demo` held 4,971
files, 0 `_remote.repositories`; the terminal said, for each, that the builders' `dur7.py`, Course 2's script, `java2_series.py` and unit
09's captures are not beside the clone (the values held for them are the checks). Its terminal log through `--runlog`: PASS.

## The commands this unit adds

```bash
docker run -d --pull never --name c7-u13-pg -e POSTGRES_USER=sa -e POSTGRES_PASSWORD="$PGPW" -p 127.0.0.1:19928:5432 postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
mvn -o -B -Dmaven.repo.local="$M2" dependency:build-classpath -Dmdep.outputFile=classpath.txt
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:.harness/drv/*" harness/src/probe/map/H.java harness/src/probe/map/Main.java harness/src/probe/map/log/*.java
java -Duser.language=en -Duser.country=US -Duser.timezone="$Z" -Dlogback.configurationFile=../../harness/logback.xml "${V[@]}" -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*:../drv/*" probe.map.Main "${A[@]}"
```

**The container** (one per run, started after the build and before the captures, removed at the end and by every exit — `$PGPW` is the
run's generated password, printed masked); **the driver** (run in `.harness/drvpom`, a copy of `harness/pom.xml`: Boot 4.1.2's parent and
`org.postgresql:postgresql` with no version written — Boot's managed **42.7.14**, with `checker-qual-3.55.1`, both copied to
`.harness/drv`); the harness compiled against the anchor's extracted jar (91 libraries) and the driver; **the harness line** (run from
`.harness/run`: **`Z` its JVM's zone** — on the java line itself, `-Duser.timezone="$Z"`; `V` its JVM flags — on PostgreSQL `-Ddb=pg
-Dpg.port=19928 -Dpg.passfile=../pg/password`, H2's file `-Ddb=h2file`, a reader's `-Ddb.keep=true`, the two Hibernate settings
`-Dtzs=` / `-Djtz=`; `A` its arguments; R.193, each printed as `$ Z=…` / `$ V=(…)` / `$ A=(…)`). The lines read from
`anchor/README.md` (2, each asserted whole): `mvn -B package` and the extract line — unit 12's.

## The repository, and the network

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s2/` alone (6,613 files). Two builds: the anchor's `package` (its 18 tests run inside
it) and the driver's `dependency:build-classpath`, each `offline: yes` with 0 `Downloaded from` lines in every run of record (the label
is derived from the build log, never typed). After them the script asserts `.m2-demo` holds `spring-boot-starter-parent-4.1.2.pom`,
`hibernate-core-7.4.13.Final.jar`, `h2-2.5.250.jar` and `postgresql-42.7.14.jar`. **The image is never pulled** (`--pull never`; its id
asserted equal to the digest before the run). **At run time** nothing leaves the computer: H2 in a harness JVM's memory or in
`.harness/run/db/`, PostgreSQL on `127.0.0.1:19928`. **No network act**: this unit reads no version file — unit 06 made Section 2's dated
sweep (`../../../data-jpa-hibernate/_research/spring-boot-metadata-2026-11-04.xml`: 4.1.2 the newest 4.1.x GA; R.223), and no Section 2
unit speaks a "newest" fact. **What ran on 42.7.14** (the AMENDMENT's #316): every PostgreSQL JVM of this unit — the driver's version is
printed by each from the connection's metadata (`driver PostgreSQL JDBC Driver 42.7.14`), never typed.

## The locale and the zone

Every java line carries `-Duser.language=en -Duser.country=US` **and `-Duser.timezone=`**; a last check refuses a capture's java line
without both. **Every JVM prints its zone first** (`TimeZone.getDefault().getID()`), and `zchk` asserts, JVM by JVM, that it is the zone
the `$ Z=` line gave (a java line without `-Duser.timezone` falls back to the computer's zone — caught). A `TZ` (and `PGTZ`) variable of
yours is planted with a canary and unset before anything runs. The test fork's locale comes from the POM's `argLine`. **The harness
prints ASCII** (` | ` between facts; Course 2's two labels are ASCII).

## The folders, the harness, the database and the ports

- `anchor` — the link to `../c7-unit09/after` (asserted: a link, that target). `.harness/anchor` — its copy, built with the README's
  `mvn -B package` offline, its jar extracted (91 libraries); `.harness/drv` — the driver; `.harness/hc` — the harness, compiled;
  `.harness/run` — where every harness JVM starts (its scripts land there; **`.harness/run/db/` the H2 file two JVMs share, deleted after
  each reader, by the EXIT trap too**); `.harness/pg` — the password's file (mode 0600, the folder 0700) and the container's id;
  `.harness/ex` — the exercise's classes.
- **The harness** — the course's, never TiffinBox's (`harness/src/probe/map`, package `probe.map`; a check refuses `probe.map` anywhere in
  the anchor's code). `H.java` is unit 12's (one `EntityManagerFactory` per run, `PersistenceConfiguration` over the classes the run
  names, Boot's two naming strategies, statistics on, `drop-and-create` on the run's own database only; the JDBC proxy counting the
  driver's calls; the PostgreSQL path — a fresh database per writer through the container's `sa` database, `select version()` cut before
  ` on `, the URL, the user, the driver's name and version from the connection's metadata) with two additions: **`-Ddb=h2file`** — H2 in
  the file `db/NAME` under the JVM's working directory (`jdbc:h2:file:./db/NAME`), and **`-Ddb.keep=true`**, the reader's: the writer's
  database opened as it is — on H2 with `IFEXISTS=TRUE`, so a missing file fails instead of making an empty one; on PostgreSQL no drop,
  no create — and with no schema step (`schema-generation.database.action=none`). Every JVM prints `org.hibernate.Version.getVersionString()`
  first, its zone and the two settings it was given, and Hibernate's own `HHH000001` line (its core logger at INFO — R.222, #311); every
  factory, **Hibernate's own reading of the two settings, off `SessionFactoryOptions`**: `getDefaultTimeZoneStorageStrategy()` and
  `getJdbcTimeZone()`. Scenarios (`Main.java`): `ddl NAME FILE`, `write NAME`, `read NAME`, `offset NAME`, `ex write|read NAME`,
  `xcheck FILE`. A gap is `Duration.between(read-back instant, the moment written)` — Course 2's order — printed after Course 2's label;
  **no `PT…` literal is allowed in the harness's source** (checked before anything is built).
- **Entities** (English names only — S2.10, R.215): `probe.map.log.OrderLog` (`@Id @GeneratedValue(IDENTITY) Long id`, `wall`, `moment`,
  `momentNoZone`, `offsetAt`, `zonedAt` — **no field named after an SQL keyword**: the probe's `offset`/`zoned` broke H2's DDL with a WARN,
  ⓘ6, S2.8 — table `order_log`, apart from the anchor's `customer`/`pause`), and the exercise's `probe.map.ex.OrderLog` (`placedAt`, a
  `LocalDateTime` as shipped; never compiled into `.harness/hc`, asserted). The settings travel as `-Dtzs=` and `-Djtz=` — the harness
  puts them into the factory's own properties as `hibernate.timezone.default_storage` and `hibernate.jdbc.time_zone` — never as
  `hibernate.*` JVM properties (What differed, 9). `harness/logback.xml` — unit 12's, its comment naming this lesson; `harness/pom.xml` —
  unit 12's driver POM (`u13-driver`); `harness/dur7.py` — the builders', md5 `41667fed…`, byte for byte.
- **The database** (S2.9): `postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873` (`postgres:18-alpine`,
  PostgreSQL 18.6), `docker run -d --pull never --name c7-u13-pg`, `POSTGRES_USER=sa`, **a 24-character password generated per run**
  (`head -c 4096 /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | head -c 24` — unit 07's bounded form), published on **`127.0.0.1:19928` only**
  (`docker port` asserted to be `5432/tcp -> 127.0.0.1:19928` and nothing else), `pg_isready` awaited, **removed** (`docker rm -f`) at the
  end — asserted gone (`docker ps -a --filter name=c7-u13-pg`: 0 lines) — and by the EXIT trap. Before it: Docker answers, the image's id
  equals the digest, no container of that name exists. `open-webui` (someone else's, `0.0.0.0:3000`) is never touched: the script names
  only its own container. **The second connection on PostgreSQL** (the row as the database holds it) runs `set time zone 'UTC'` first —
  said in the line it prints — so the `with time zone` columns' text does not depend on the reader's zone (the driver hands PostgreSQL
  the JVM's zone as the session's).
- **Ports** (§P, 19920-19929): **19928 the container's**, on 127.0.0.1; **19929 never bound** (asserted free at the start, after the
  container is up, and at the end). 19920-19927, 18425, 8080 and 35729 checked free first and last; nothing of this unit binds them.

## Masks, filters and hygiene — every one, declared

1. **`mask()`** (`gsub()`, literals escaped; checked first on planted lines, the planted password among them): **the database password →
   `[masked: the 24-character password]`**; this folder → `…`, the folder above → `…/..`, home → `~`, the user name → `<user>`; ` using Java
   <version>`; an identity hash → `@…`; Hibernate's generated constraint names → `FK<hash>` / `UK<hash>`; H2's generated index and
   constraint names → `PRIMARY_KEY_<n>`, `CONSTRAINT_<n>` (none appears in this unit's captures; kept from unit 12, checked on the plants).
2. **The password, counted raw** (S2.9): every raw capture run — before the mask — must hold it **0** times, else the run stops naming
   the capture; at the end every file of this folder but `.m2-demo` holds it **once**: its own file. The harness reads the file and never
   prints it; no URL carries it (the harness logs in through `PGSimpleDataSource`, user and password set apart from the URL).
3. **A harness log** (`hview`): every line, trailing spaces dropped. **A Maven log**: never printed in a capture; its exit, `offline` and
   `Downloaded from` count go to the terminal. **Course 2's files** (`course2`): `sed -n 80,115p` of `Connect.java`, trailing spaces
   dropped; the script's four capture lines, cut out of line 194's backticks (that line also holds slide prose — not printed).
4. **Hygiene, checked last over every capture** (unit 12's list): no absolute path, **no unit number — except `course2`, which names
   Course 2's folder, `../c2-unit35/…`, by design** — no time, no log time, no thread number, no JDK/OS version token, no unmasked generated
   database name, no unmasked constraint or index name, **no port but the container's 19928**, no per-run timing figure, no stack frame;
   every java line pinned — locale and zone; `GenerationTarget encountered exception` 0 in every harness log (R.213) **and, right after
   each capture, 0 in the capture (`nowarn`, S2.8 — a reserved word speaks there, before the DDL checks)**; no SQL keyword as a field
   name (`order`, `offset`, `user`, `value`, `key`, `zone`, `timestamp`); **no H2 database file anywhere in this folder or beside it at the
   end — and `.harness/run/db` gone** (R.195); no `pkill`/`killall`; no bare `wait`; no one-string multi-option variable (R.193); no
   Indian dish name in any capture (R.215).
5. **Duration words** (R.172): `dur7.DUR` over this README and the exercise's two files must find **0** — this unit speaks no time. The
   bug's gap, `PT5H30M` / "five and a half hours", is a value a capture prints, not a timing of the machine: `dur7.DUR` does not list
   `hours` (its list is unit 06's timing words and the units below an hour) — measured on the
   exercise's sentence and on "the same five and a half hours": 0 hits (For RED). **Dish names** (R.215, S2.10): unit 12's 43 words,
   whole words, any case, refused in `exercise/`, `harness/src` and this README before anything is built, and in every capture at the end.
6. **Typed gaps**: a `"…PT5H30M…"`-shaped literal in `harness/src` stops the run before the build; and this README's line of the gaps
   the video may say is compared with the values the checks read from the captures (below).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the Maven it
waits for (`$mpid`, with every process under it — Surefire's fork), the exercise's shell (`$xpid`), sweeps its own process group for any
harness JVM, Maven or Surefire fork left, **removes the container** (`docker rm -f c7-u13-pg`, if this run started it), **deletes
`.harness/run/db`** (the H2 file two JVMs share), deletes the capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`.
The published captures are untouched. No `wait` in the script or the exercise is bare.

**Measured (2026-11-05, a scratch mirror holding the eight published captures, the script as committed):** `./receipts.sh` (/bin/bash
3.2) started in a session of its own with SIGINT at its default, `kill -INT` to its group once the named point was reached, the state
read 5 s later — each **exit 130, nothing left, the container gone, no H2 file**:

```
build: processes in the group at SIGINT 3 · container up at SIGINT 0 · .harness/run/db at SIGINT no · exit 130 · 5 s later in the group: 0 · container 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java: 0 · .harness/run/db: no
harness: processes in the group at SIGINT 3 · container up at SIGINT 1 · .harness/run/db at SIGINT no · exit 130 · 5 s later in the group: 0 · container 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java: 0 · .harness/run/db: no
container: processes in the group at SIGINT 3 · container up at SIGINT 1 · .harness/run/db at SIGINT no · exit 130 · 5 s later in the group: 0 · container 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java: 0 · .harness/run/db: no
between: processes in the group at SIGINT 2 · container up at SIGINT 1 · .harness/run/db at SIGINT yes · exit 130 · 5 s later in the group: 0 · container 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java: 0 · .harness/run/db: no
```

`build` — the anchor's Maven (its Surefire fork), before the container; `harness` — the first harness JVM (`ddl` on H2), the container
up; `container` — the first PostgreSQL harness JVM (`-Ddb=pg`, its fresh database open in the container); **`between` — `zones`' first
pair on H2, the writer's JVM gone and `.harness/run/db/u13zab.mv.db` on disk, the reader's not started** (on a copy whose `pair()` waits
there — What differed, 11: the only line that differs). `pgrep -f probe.map.Main` afterwards: none; `docker ps -a --filter
name=c7-u13-pg`: 0 lines. (A first batch of these was started by a driver whose background job inherited SIGINT as ignored — bash
cannot trap a signal ignored on entry — and ran to the end, exit 0; the driver now resets SIGINT to its default before `setsid`, as a
terminal does. Found on the way.)

## 1 · course2 — Course 2's lesson, read off its files (C7-8's promise; no JVM)

The title, *JDBC: Connect, Query, Map Rows to Records* — `java2_series.py`'s `"35"` entry, read off the file (R.63, #306's form);
`Connect.java` (md5 `a2b44f17a90c745cccedd10cd8915d8a`) lines 80-115 by `sed -n`: `/// A TIMESTAMP column is a wall clock. A TIMESTAMP
WITH TIME ZONE is a moment.`, the literal `Instant.parse("2026-09-14T18:30:00Z")` (`// fixed, never now()`), `ps.setTimestamp(2,
Timestamp.from(placed), utc)` into `created_at`, `rs.getTimestamp("created_at", kolkata)`, the `created_tz` read as `OffsetDateTime`,
and the two labels, line 105 `stored instant                   : ` and line 108 `off by                           : `; the Course 2
script (`35-jdbc-basics.md`, md5 `0bb5a050af2b08325aa6303ffef002ea`) line 194's ON SCREEN capture, its four lines — **`off by
: PT5H30M` with the label padded to 33 characters** — and the check that this line is line 108's label plus `PT5H30M`.

## 2 · ddl — Hibernate's defaults (H2 and PostgreSQL, the scripts byte-equal; writer zone UTC)

`create table order_log (id bigint generated by default as identity, moment timestamp(6) with time zone, moment_no_zone timestamp(6),
offset_at timestamp(6) with time zone, wall timestamp(6), zoned_at timestamp(6) with time zone, primary key (id));` — **on H2 and on
PostgreSQL, byte for byte** (`cmp`): **`LocalDateTime` → `timestamp(6)`; `Instant` → `timestamp(6) with time zone`; the `Instant` with
`@JdbcTypeCode(SqlTypes.TIMESTAMP)` → `timestamp(6)`; `OffsetDateTime` and `ZonedDateTime` → `timestamp(6) with time zone`.** And
Hibernate's reading of the default storage strategy — **H2 `NATIVE`, PostgreSQL `NORMALIZE_UTC`** (`getDefaultTimeZoneStorageStrategy()`;
the same DDL text, two strategies).

## 3 · zones — two JVMs, two zones, one database between them (A/B/A′; H2 a file, PostgreSQL a kept database)

Per database, three pairs; in each the writer's JVM writes one `OrderLog` (one INSERT) and exits, the receipt lists what lies between
them, the reader's JVM — a new process, another zone — opens the same database with no schema step, prints the row by a second
connection, then reads it back by a new EntityManager (one SELECT): each field, as an instant, and `off by` with Course 2's label.

| pair | writer → reader | `wall` (LocalDateTime) | `momentNoZone` (Instant on `timestamp`) | `moment` (Instant, default) | `offsetAt` read back | `zonedAt` read back |
|---|---|---|---|---|---|---|
| **A and B** | UTC → Asia/Kolkata | `2026-09-14T18:30` → `13:00:00Z` · **B `PT5H30M`** | `2026-09-14T13:00:00Z` · **B `PT5H30M`** | `18:30:00Z` · **A `PT0S`** | H2 `2026-09-15T00:00+05:30` · PostgreSQL `2026-09-14T18:30Z` · `PT0S` | the same as `offsetAt` · `PT0S` |
| **B reversed** | Asia/Kolkata → UTC | `2026-09-15T00:00` → `00:00:00Z` · **`PT-5H-30M`** | `2026-09-15T00:00:00Z` · **`PT-5H-30M`** | `PT0S` | as above · `PT0S` | `PT0S` |
| **A′** | UTC → Asia/Kolkata, fresh JVMs, a fresh database | `PT5H30M` again | `PT5H30M` again | **`PT0S` again** | as A | as A |

The same on **H2 (a file)** and on **PostgreSQL (a database kept between the two JVMs)** — the database says itself in each JVM's
`database:` line (the reader's: "the writer's file, opened as it is" / "the writer's database, opened as it is"). **The row by a second
connection** (UTC writer): H2 `[2026-09-14 18:30:00 | 2026-09-14 18:30:00+00 | 2026-09-14 18:30:00 | 2026-09-15 00:00:00+05:30 |
2026-09-15 00:00:00+05:30]`; PostgreSQL, **its session set to UTC first (`set time zone 'UTC'`, said in the line)**, `[2026-09-14
18:30:00 | 2026-09-14 18:30:00+00 | 2026-09-14 18:30:00 | 2026-09-14 18:30:00+00 | 2026-09-14 18:30:00+00]`; with the Kolkata writer the
two `timestamp` columns hold `2026-09-15 00:00:00` — **the writer's clock face is in the zone-less columns' text, and in neither `with
time zone` column**. **Course 2's line, byte for byte** (`  PROBE off by                           : PT5H30M` = `PROBE ` + the script's ON
SCREEN line): 8 times — under `wall` and `momentNoZone` in A and B, under `wall` in A′, on both databases (S2.19, R.224, RED #322).
Every pair: two JVMs one after the other; **the writer's one INSERT and the reader's one SELECT, each counted three ways** (the SQL
logger's line, `getPrepareStatementCount()` 1, the driver's `prepareStatement` 1 — R.184); one schema step, the writer's; on H2 the file
absent before the writer, `u13zab.mv.db` (and so on) listed between, gone after the reader (R.195).

## 4 · storage — `hibernate.timezone.default_storage` (H2 and PostgreSQL; B the failure receipt, PostgreSQL)

One JVM per setting and database (zone UTC), Hibernate's reading off `SessionFactoryOptions` and the DDL each wrote:

| setting | H2 2.5.250 | PostgreSQL 18.6 |
|---|---|---|
| not set | **NATIVE** · `offset_at`, `zoned_at` `timestamp(6) with time zone` | **NORMALIZE_UTC** · the same DDL |
| `NATIVE` | NATIVE · the same | **B: exit 1 — `org.hibernate.HibernateException: The configured time zone storage type NATIVE is not supported with the configured dialect`**; no factory, no SQL, no script (`(none: no such file)`) |
| `NORMALIZE` | NORMALIZE · `offset_at timestamp(6)`, `zoned_at timestamp(6)` — no zone (`moment` keeps `with time zone`) | the same |
| `COLUMN` | COLUMN · **`offset_at_tz integer, zoned_at_tz integer`** beside the two `with time zone` columns | the same |
| `AUTO` | → **NATIVE** | → **COLUMN** (the two `_tz` columns) |

The `database:` line and both version lines print before B's exception: the JVM reached PostgreSQL; Hibernate refused the setting for
its dialect. **"Hibernate 7's default" is two strategies** — said per database (§4.4).

## 5 · offset — the offset kept, or not (H2 and PostgreSQL; one JVM in UTC)

An `OffsetDateTime` at `+05:30` (`2026-09-15T00:00+05:30`, the same instant as `2026-09-14T18:30:00Z`) and a `ZonedDateTime` in
Asia/Kolkata, written, then read back by a new EntityManager: **H2 `2026-09-15T00:00+05:30`** — the offset kept (NATIVE); **PostgreSQL
`2026-09-14T18:30Z`** — the offset gone (NORMALIZE_UTC), **the same instant**, `off by … PT0S` on both. The `ZonedDateTime` reads back as
an offset on both (H2 `2026-09-15T00:00+05:30`, no `[Asia/Kolkata]`; PostgreSQL `2026-09-14T18:30Z`). The row by a second connection: H2
`offset_at 2026-09-15 00:00:00+05:30`; PostgreSQL (session UTC) `2026-09-14 18:30:00+00`. **Said per database:** "H2 keeps the
`+05:30`; PostgreSQL keeps the moment and drops the offset."

## 6 · jdbctz — C, labelled: `hibernate.jdbc.time_zone=UTC` on both JVMs (H2 and PostgreSQL)

The A-and-B pair again, writer UTC → reader Asia/Kolkata, **both JVMs given `-Djtz=UTC`** (Hibernate reads `getJdbcTimeZone() UTC`
in each): **`momentNoZone` `PT0S` too, and `wall` `PT0S` — but the reader's `LocalDateTime` is `2026-09-15T00:00`**, not the
`2026-09-14T18:30` the writer stored: Hibernate shifted the wall clock to make the instant come out right. The row by a second connection
is A's. **Said as C, the cost of a fix both services must carry** — the column type (A) needs no setting; this one needs the same key in
every JVM that reads or writes the column. (Only both-JVMs was measured; one JVM with the key and one without is not — CARRIED.) A
check refuses `hibernate.jdbc.time_zone` in any JVM outside a block whose heading begins `C - ` (`jtzlabel`, over every capture).

## 7 · xcheck — the harness's DDL against Boot's, as unit 09 captured it (R.212, RED #308; H2)

The harness's own EntityManagerFactory over `com.tiffinbox.CustomerEntity` and `com.tiffinbox.PauseEntity` (from the anchor's jar)
writes `xcheck.sql`: three lines, **md5 `f595637014e786fa38606859951e4f97` = Boot's script as unit 09 captured it** — the md5 read from
`../c7-unit09/README.md` (asserted there) and that capture's own published md5 `9072c6f1…` read from `../c7-unit09/receipts.md5` before
any build. **No Boot run.** When `../c7-unit09/.r-xcheck.out` is on disk with its published md5, Boot's three lines are read from it and
each asserted in this capture too (a clone has no captures: the md5 is the comparison).

## 8 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196; H2, a file, two JVMs per block)

`exercise/README.md`'s 9 lines, then `exercise/SOLUTION.md`'s (the README's with one line changed: the copy of `OrderLog.java` made with
`sed`, `private LocalDateTime placedAt;` → `private Instant placedAt;`), each block sourced in one `env -i` shell, `/bin/bash --noprofile
--norc` then `/bin/zsh -f`; **each block its own two fresh JVMs** — the writer in UTC, the reader in Asia/Kolkata, an H2 file between
them that the block deletes (asserted gone after each block). In both shells: the README → **`off by                           :
PT5H30M`** (`placedAt (LocalDateTime) read back: 2026-09-14T18:30 - as an instant in this JVM's zone: 2026-09-14T13:00:00Z`); the solution
→ **`off by                           : PT0S`** (`placedAt (Instant) read back: 2026-09-14T18:30:00Z`); both JVMs exit 0 in each; the
shell back in this folder; bash's output = zsh's. Broken ≠ solved.

## Exercise

**Your turn:** the README stores the order time as a LocalDateTime and Kolkata reads it five and a half hours early. Store the moment.
(24 words, `wc -w` on the quoted sentence, asserted in `receipts.sh`.) `exercise/README.md` ships `placedAt` as a `LocalDateTime`,
`exercise/SOLUTION.md` beside it; broken (`PT5H30M`) ≠ solved (`PT0S`), each half from its own fresh writer and reader JVMs, measured by
the `exercise` capture (R.196).

## What the video may say — and the capture each comes from

- **The hook (`zones`, both databases):** `off by                           : PT5H30M` — **Course 2's line, byte for byte** (`course2`
  shows Course 2's own; the check compares them), printed by a J-P-A entity read in Kolkata after a UTC JVM wrote it — "on H2 and on
  PostgreSQL" (both `database:` lines in the capture, S2.12).
- the gaps the video may say: B PT5H30M · reversed PT-5H-30M · A and A′ PT0S · C PT0S (its wall clock read 2026-09-15T00:00)
  (`receipts.sh` compares this line with the values its checks read — a typed value fails it.)
- **The column is the fix** (`ddl`, H2 = PostgreSQL): an `Instant` gets `timestamp(6) with time zone` by default; a `LocalDateTime` — and
  an `Instant` forced with `@JdbcTypeCode(SqlTypes.TIMESTAMP)` — get `timestamp(6)`, a column with no zone. The bug needs one of those two;
  the default `Instant` does not have it (`zones` A, A′).
- **Two JVMs, two zones** — always say the writer's and the reader's zone with a number (`zones`: UTC → Asia/Kolkata `PT5H30M`; Asia/Kolkata
  → UTC `PT-5H-30M`); the zones are each JVM's `-Duser.timezone`, printed by the JVM.
- **The defaults differ** (`storage`, S2.12): Hibernate 7's default time-zone storage is **NATIVE on H2, NORMALIZE_UTC on PostgreSQL**;
  NATIVE on PostgreSQL is refused at start — the failure receipt (B) — with "The configured time zone storage type NATIVE is not
  supported with the configured dialect". `COLUMN` adds `offset_at_tz integer`; `AUTO` picks NATIVE (H2) or COLUMN (PostgreSQL).
- **The offset** (`offset`, per database, §4.4): "H2 gives the `+05:30` back; PostgreSQL gives the same instant back in UTC — the
  offset is gone." Never "Hibernate keeps the offset" without the database.
- **C, labelled** (`jdbctz`): `hibernate.jdbc.time_zone=UTC` on both JVMs also gives `PT0S` for the zone-less columns — and makes the
  Kolkata reader's `LocalDateTime` read `2026-09-15T00:00`: a key both services must carry, and a wall clock that is no longer what was
  written. Not "the fix": the fix the unit pays is the column (A).
- The raw rows (`zones`, `offset`) say what the database holds; on PostgreSQL the voice says the second connection's zone was set to UTC.
- The harness's DDL = Boot's (`xcheck`). "Hibernate 7" for the version; each capture prints `7.4.13.Final` twice per JVM (`HHH000001` and
  `getVersionString()`, R.222) and, on PostgreSQL, the driver's `42.7.14` and `select version()`'s `PostgreSQL 18.6` (S2.17, S2.9).
- **Glossed at first use** (contract §10): an offset (`+05:30`, a number of hours from UTC) vs a zone (`Asia/Kolkata`, a place's rules) —
  the `ZonedDateTime` reading back as an offset is the capture that shows the difference. Course 2's lesson called back by its title.
- **Not said:** any duration of the machine (R.172); why PostgreSQL normalises (`timestamptz` keeps no offset — the brief's reading, not
  captured here: R.201, say "PostgreSQL gives it back in UTC" only); what happens when only one service carries `jdbc.time_zone`.

## The ledger rows and hand-offs this unit pays

- **C7-8 — paid.** Course 2 U35's off-by-5:30 "fixed properly at the column level": the column is **`timestamp(6) with time zone`**,
  measured **by the DDL** (`ddl`: Hibernate gives an `Instant` that column, H2 and PostgreSQL byte for byte) **and by `PT0S` across zones**
  (`zones` A and A′: a UTC writer and a Kolkata reader, two JVMs, `moment` `PT0S`, and reversed `PT0S`), **on both databases** — beside the
  bug reproduced through J-P-A with Course 2's own line (`PT5H30M`, B) and its title read off `java2_series.py` (`course2`).
- RE-MEASURE 1 (the exercise as README + SOLUTION) and 12 (`xcheck` on `09/after`) are settled here (below).

## RE-MEASURE — the brief's items this unit settles

| # | Settled here |
|---|---|
| 1 | the exercise as README + SOLUTION files, bash and zsh, `env -i`: `PT5H30M` / `PT0S`, two fresh JVMs (writer UTC, reader Asia/Kolkata) each half, an H2 file between them, deleted |
| 12 | `xcheck` on `09/after`: `f595637014e786fa38606859951e4f97` (Boot's script as 09 captured it) |

And #316's scope: `zones` on driver 42.7.14 — wall/momentNoZone `PT5H30M`, moment/offset/zoned `PT0S`, the offset read `2026-09-14T18:30Z`
on PostgreSQL — the same as RED's re-run and the probe's 42.7.13 run.

## What differed from the brief

1. **Course 2's label is padded.** The brief and RED #322 write it `off by : PT5H30M`; Course 2's `Connect.java` line 108 prints `"off by
   : "` padded to the width of `read by a service in Asia/Kolkata: ` — **`off by                           : PT5H30M`** — and its
   script's ON SCREEN text (line 194) shows the same. The harness prints that, after `PROBE `; the check compares it with line 108's label
   (read by `sed` every run) plus the gap, and with the script's line (S2.19). The brief's plant (`off by: PT5H30M`) is kept as a plant on
   the harness's constant.
2. **A and B are columns of one row, read by one pair of JVMs.** The brief's B (the `LocalDateTime` and the forced `Instant`) and A (the
   default `Instant`) face the same writer and the same reader in one pair — so the bug and the fix meet the same two zones; A′ is that
   pair again with fresh JVMs and a fresh database; the reversed pair is its own pair. Three pairs per database, twelve JVMs.
3. **Course 2's script and title are outside this repository.** When they are beside it (`../../../core-java-2/…`, `~/Desktop/…`) they are
   read and asserted; in a clone the values this script holds for them are the check (unit 12's `dur7.py` / `X09` form). `course2` prints
   the script's four ON SCREEN capture lines, cut out of line 194's backticks, not the whole line (slide prose and emoji around them).
4. **`course2` is exempt from the "no unit number" hygiene check** — it names `../c2-unit35/…`, Course 2's folder, on purpose.
5. **`jdbctz` is a pair on both databases** (the brief: "both JVMs → PT0S"); its label C is enforced over every capture (`jtzlabel`).
6. **`offset` is one JVM per database** (write, then a new EntityManager); the two-JVM offset read is in `zones` too (the Kolkata reader) —
   the same values.
7. **`NORMALIZE` keeps `moment` `with time zone`.** The brief's "NORMALIZE → `timestamp(6)` without zone" is true for `offset_at` and
   `zoned_at`; an `Instant` keeps its zoned column under every setting measured.
8. **NATIVE on PostgreSQL** fails with `org.hibernate.HibernateException` itself (no `PersistenceException` around it, no cause) — the
   brief quotes the message only; the capture's form is the one on screen.
9. **The two settings travel as `-Dtzs=` / `-Djtz=`**, put by the harness into the factory's properties, and **Hibernate's reading is
   printed** (`getDefaultTimeZoneStorageStrategy()`, `getJdbcTimeZone()`) — not `-Dhibernate.…` on the java line, which Hibernate might
   also read from the JVM's properties (not measured; the receipt's form keeps one source).
10. **Plants on copies** (unit 12's form), one after another: every run needs the one container name and port 19928.
11. **SIGINT between the two JVMs** was measured on a copy whose `pair()` waits between the writer's JVM and the reader's (one `sleep`
    added there) — without it the gap is a few shell statements wide; the copy differs from the script by that line only.
12. **The reader opens, never creates**: `-Ddb.keep=true` — on H2 `IFEXISTS=TRUE` (a missing file fails), on PostgreSQL no drop and no
    create, and no schema step.
13. **The exercise runs two JVMs on an H2 file** (the brief: "both JVMs fresh for each"); each block deletes the file, and the capture
    asserts it gone after each block.
14. **`TZ` and `PGTZ` join the canary list** (a variable of yours must not set a JVM's or the driver's zone).
15. **The R.195 check stops inside `pair()`** when the file outlives its reader (an earlier form printed it and checked after the
    capture — but a leftover file makes the next run of the capture differ, and the drift check spoke first).

## Planted faults — each caught (R.65)

On copies (What differed, 10), one after another, each **exit 1**, nothing written to this folder; after each: 0 listeners on
19800-20399, no harness JVM, no container, no `.harness/run/db`. Eighteen, on `receipts.sh` `56bf71eb…` (the one committed); the
capture a plant changes was taken out of the copy's `receipts.md5`, so its check speaks:
- **Both JVMs in one zone** (`ZR=UTC`) → `*** zones A and B on H2: B - the LocalDateTime, Course 2's gap: the read-back line: expected
  the line:   PROBE wall (LocalDateTime) read back: 2026-09-14T18:30 - as an instant in this JVM's zone: 2026-09-14T13:00:00Z ***` (96 s).
- **The NATIVE run on H2** (`NATDB=h2`) → `*** storage B: the NATIVE run must be PostgreSQL's - no block 'B - NATIVE on PostgreSQL' (H2
  keeps an offset: it starts there) ***` (151 s).
- **`jdbc.time_zone` in B without the label** (`ZBX=(-Djtz=UTC)`) → `*** zones: hibernate.jdbc.time_zone is set in 8 JVM line(s)
  outside a block labelled 'C - ' … ***` (94 s).
- **`-Duser.timezone` missing from the java line** (`L_H` and this README's line) → `*** ddl: every JVM prints its zone, the one its
  java line gives (-Duser.timezone) - 2 expected; read (JVMs, wrong, given->printed): 2 2  UTC->Europe/Rome UTC->Europe/Rome ***` (30 s).
- **The H2 file left behind** (`DBRM=0`) → `*** R.195: the H2 file the two JVMs shared is still there after the reader (A and B on H2) -
  .harness/run/db: u13zab.mv.db ***` (32 s).
- **A field named `offset`** (`OrderLog.offsetAt` → `offset`) → `*** ddl: a schema step WARNed - 'GenerationTarget encountered
  exception' 2 times (S2.8, R.213: … Syntax error in SQL statement "create table order_log (… ***` (29 s) — the WARN check, before the
  DDL check and before the static name check at the end.
- **Course 2's label typed with another spacing** (`OFFBY = "off by: "`) → `*** zones A and B on H2: B - the LocalDateTime, Course 2's
  gap: under '…' expected '  PROBE off by                           : PT5H30M' - read '  PROBE off by: PT5H30M' ***` (90 s).
- **A typed `PT5H30M`** (`p(OFFBY + "PT5H30M")`) → `*** a typed gap in the harness - every PT… it prints must come from
  Duration.between: harness/src/probe/map/Main.java:136:"PT5H30M" ***` (2 s), before anything is built.
- **A raw database password in a capture** (`H.ds` printing it in the `database:` line) → `*** ddl: its raw output (run 1) held the
  database password - the mask would hide it; nothing may print it (S2.9) ***` (25 s).
- **A wrong image digest** → `*** the image is not on this computer: docker pull postgres@sha256:…a1874 ***` (1 s).
- **A wrong published hash** (`receipts.md5`'s `course2`) → `*** course2 is not the published capture … ***` (17 s).
- **A version claim without `HHH000001`** (`harness/logback.xml` without its `org.hibernate.orm.core` logger) → `*** ddl: the version
  lines - getVersionString() and Hibernate's HHH000001 - once in each of its 2 harness JVMs (R.222) ***` (30 s).
- **`xcheck` against a wrong 09 md5** (`X09`) → `*** ../c7-unit09/README.md no longer states Boot's script md5 …e4f96 - the number this
  unit compares with ***` (17 s), before any capture.
- **One per capture class:** `zones`, `storage`, `xcheck` above; `course2` — `sed -n 81,115p` → `*** course2: Connect.java lines 80-115,
  36 lines ***` (19 s); `ddl` — `momentNoZone` without `@JdbcTypeCode` → `*** ddl on H2: the script - expected, every line: create table
  order_log (… moment_no_zone timestamp(6), … ***` (28 s); `offset` — the H2 run sent to PostgreSQL → `*** offset: the database: lines -
  1 on H2 2.5.250 and 1 on PostgreSQL 18.6 with driver 42.7.14 (S2.12, S2.17) - read 0 and 2 ***` (163 s); `jdbctz` — the key left off
  both JVMs → `*** jdbctz: C - both JVMs carry hibernate.jdbc.time_zone=UTC, and Hibernate reads it (getJdbcTimeZone() UTC), on both
  databases ***` (188 s); `exercise` — `SOLUTION.md`'s `sed` given a pattern that matches nothing → `*** exercise: the solution - an
  Instant, no gap: expected the line:     PROBE placedAt (Instant) written by this JVM: 2026-09-14T18:30:00Z ***` (257 s).

## Found on the way

- **`NORMALIZE` leaves `moment` zoned** (What differed, 7) — measured in `storage`.
- **The `ZonedDateTime` comes back as an offset on both databases**: H2 `2026-09-15T00:00+05:30` (no `[Asia/Kolkata]`), PostgreSQL
  `2026-09-14T18:30Z` — the zone id is kept by neither under the defaults (`zones`, `offset`).
- **The IDENTITY INSERT differs by database** (unit 06's finding, again): H2 `values (?,?,?,?,?,default)`, PostgreSQL `values (?,?,?,?,?)`;
  on PostgreSQL Hibernate also logs `set client_min_messages = WARNING` before its DDL. Not a beat.
- **The writer's zone shows in the zone-less columns' raw text only** (`2026-09-14 18:30:00` from UTC, `2026-09-15 00:00:00` from Kolkata);
  the `with time zone` columns hold the same text from either writer.
- **`jdbc.time_zone=UTC` with a UTC writer stores what A stores** (the row the same) — the shift is all in the Kolkata reader's read.
- **The test driver's first SIGINT batch ran to the end** (Interrupted): a background job of a non-interactive shell starts with SIGINT
  ignored, and bash cannot trap a signal ignored on entry; with SIGINT reset to its default the four points each exit 130. The receipt's
  own trap was right; the measurement was not, and was redone.
- **The machine's zone is `Europe/Rome`** (the plant without `-Duser.timezone` printed it) — never seen in a capture of record.
- The first development run stopped at `nowarn` (it counted each JVM's own summary line, `exit 0 · 'GenerationTarget encountered
  exception': 0`) — fixed before any capture was published.
- `HHH000489: No JTA platform available …` in every JVM that builds a factory — deterministic, kept (unit 12's).

## CARRIED

- **One service with `hibernate.jdbc.time_zone` and one without** → not measured; the voice says "both services must carry it" as the
  configuration this capture ran, never what the one-sided case prints (R.201).
- **`DEFAULT` and `NORMALIZE_UTC` set explicitly** (the probe ran them: `DEFAULT` → NATIVE / NORMALIZE_UTC) → not run here; no beat needs
  them.
- **`@TimeZoneStorage` on one attribute** (keeping a zone id or an offset per column) → not measured; the beat is the default and the
  global setting.
- **A zone with daylight saving** (Kolkata has none; UTC none) → not measured; the gap is `PT5H30M` for these two zones only.
- **Time columns in the anchor** → none: TiffinBox has no time column; the order times stay a harness table (⚑4).
- `14`'s `xcheck` compares with unit 09's `f595637014e786fa38606859951e4f97` too (unchanged by this unit).
- The builder (s713) must: call a line "Course 2's" only where the slide shows the byte-equal line (`zones`' `off by` line, R.224); cite
  two `database:` lines for every cross-database slide (`ddl`, `zones`, `storage`, `offset`, `jdbctz` — S2.12); say the writer's and the
  reader's zone beside every gap; keep C labelled C; refuse the dish-name list in SAY lines and on slides; assert `duration words: 0`
  (R.172).

## For RED

Re-run from a clean tree (seeded `.m2-demo`, the image present, Docker answering) in a process group of its own with SIGINT at its
default; ports 20240-20279 for any re-run of this unit's JVMs or a container outside its script. Worth breaking: whether a
`-Dhibernate.jdbc.time_zone=UTC` on the java line (not through the harness's settings) is read by Hibernate 7.4 (not measured — What
differed, 9); whether the PostgreSQL driver's session zone (the JVM's) changes the reader's values without `set time zone 'UTC'` (only the
second connection sets it; Hibernate's own connection keeps the JVM's — the read-backs above are with that); a reader in a zone with
daylight saving; `@TimeZoneStorage`; whether H2's `NATIVE` survives an H2 patch (only 2.5.250 measured). **dur7's classification:**
`dur7.DUR` has no `hours` and no ISO-8601 duration — the bug's value (`PT5H30M`, "five and a half hours") is not a duration word to it;
it does list the word for a sixtieth of an hour, so a script that spells the thirty out in that unit would trip the builder's
`duration words: 0` — say "five and a half hours" (the exercise's words) or "five hours thirty".
Evidence by a Claude Opus 5.5 agent on 2026-11-05.
