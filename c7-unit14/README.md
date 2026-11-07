# c7-unit14 — Money in the Database

Course 7 · Data with JPA & Hibernate · Section 2 (Mapping), its ninth and last unit — **a harness unit: no change to the anchor** ·
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.2** (Hibernate ORM 7.4.13.Final, Jakarta Persistence 3.2.0, H2
2.5.250 — the anchor's pin — Hibernate Validator 9.1.5.Final from the anchor's own libraries, and **PostgreSQL 18.6** in a container,
the PostgreSQL JDBC driver **42.7.14**), 2026-11-05. Course 2 kept money in a `BigDecimal` and rounded it on purpose
(`setScale(2, HALF_UP)`). A `BigDecimal` in a `numeric(10,2)` column keeps that promise its own way: **`120.105` goes in — the bind
logger shows Hibernate sending `<- [120.105]` — and the row holds `120.11`**, with no error and no warning, on H2 and on PostgreSQL.
**The database rounds the fraction; it refuses the integer digits** (`123456789.00`: H2 `Value too long for column "AMOUNT NUMERIC(10,
2)"`, PostgreSQL `numeric field overflow`, a `DataException` each). **The only refusal before SQL is the one you write**:
`@Digits(integer = 8, fraction = 2)` → `ConstraintViolationException … during persist time`, **0 statements**. That is C7-9, paid
with the rounding said, not hidden.

**Which database answered — every capture says it in its own lines** (§4.4, S2.12: a `database:` line per factory, the PostgreSQL ones
with `select version()` and the driver's version from the connection's metadata): `ddl`, `values`, `double`, `digits` (A, B, A′) —
**H2 and PostgreSQL, each run beside the other**; `digits`' S2.4 check — H2 (a script written, never run) and the class files
(`javap`); `course2` reads files only (no JVM); `xcheck` and `exercise` — H2 only. Every H2 database lives in a JVM's memory; every
PostgreSQL factory gets a fresh database in the container.

**No anchor change.** `anchor` is the link to `../c7-unit09/after`, the tree Section 2 froze. `receipts.sh` prints `diff -rq -x .m2-demo
-x target -x secrets anchor/ ../c7-tiffinbox` at its start and end — empty in every run of record — and, from any later anchor change
on, prints a note instead, never a stop (R.211). The anchor is copied under `.harness/anchor` and built there, never in place. **The
anchor's own money stays an `INT` of rupees** — `Database.java`'s `price_per_meal INT NOT NULL`, `CustomerEntity`'s `int pricePerMeal`,
read and asserted at the start (⚑4's loser, CARRIED below): named once here, never changed.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 7 captures, 3 runs each; every spoken value checked after its capture; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version`, `javac -version` and `javap -version` say 25.)
It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first), and when a check after a capture
fails. **Start it in a process group of its own** (a terminal's foreground job is one), with SIGINT at its default: `sweep()` stops only
processes of its own group. `.m2-demo` must be seeded first (below). **Docker must answer** (OrbStack here) and **the image must already
be on the computer** (`docker image inspect postgres@sha256:77f58511…`; a receipt never pulls — a missing image stops it with the
`docker pull` line to type). No TiffinBox JVM.

**Runs, each `env -i`** (`HOME` the user's, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`), a process group of its own,
`.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s2/` alone (6,613 files). The first development run passed
every check and stopped only where it must — no published hash yet, and this README's values line still a placeholder; its seven
hashes were published as they were, and no capture has changed since.
Development runs fixed the checks (the first passed every check and stopped only where it must — no published hash, the values line
a placeholder; its seven hashes were published as they were, and no capture has changed since; a plant then found an arithmetic error
in S2.4's check — Found on the way — fixed before the runs of record). **The runs of record, on the script as committed (`receipts.sh`
md5 `fbf41b618da42cebf241894d40c88ef2`): 125 s under `./receipts.sh`** (/bin/bash 3.2.57) **and 148 s under `bash receipts.sh`**
(Homebrew bash 5.3.9): each exit 0, all 7 captures 3/3 = published, every check passed, both builds `offline: yes · exit 0 · 'Downloaded
from' lines in its log: 0`, the container up on `127.0.0.1:19938` only and removed, 0 raw passwords, the anchor note empty at the start
and the end, nothing listening on 18425, 8080, 35729 or 19930-19939 at the end; each terminal log through `check_unit7.py 14 --runlog` —
`0 grep error line(s)`, `RESULT (run logs): PASS`. The builders' `_builders/dur7.py` over this README and the exercise's two files: 0
duration words. Those runs had this README as then drafted (its run-of-record, interrupt and plant paragraphs since filled in; no
command line, no `mine()` line and no values line changed). **On the tree as committed** — this README final — one more `./receipts.sh`: exit 0 in 134 s, all 7 = published, `--runlog` PASS. **Nothing was downloaded**, and this unit made no network act.

**Re-run after unit 15 moved the anchor (2026-11-07).** `../c7-unit15`'s commit changed `../c7-tiffinbox` — Section 3's first anchor change (a new `CustomerEntityRepository.java`; `CustomerRepository.java`'s `findAll` and `add` over it; `@EnableJpaRepositories` on `TiffinBoxApp`; the core POM; `CustomerEntity.java`'s Javadoc; its README) — so this script's anchor check prints the note at its start and end, never a stop (R.211): anchor/ is still the link to `../c7-unit09/after`, the frozen tree this unit measured. `receipts.sh` unchanged (md5 `fbf41b618da42cebf241894d40c88ef2`). One run on the moved anchor, `./receipts.sh` (/bin/bash 3.2.57), `env -i`, a session of its own, from 17:41 CET: exit 0 in 171 s, the note printed at the start and the end, all 7 captures 3/3 = published, its container (`c7-u14-pg`, 127.0.0.1:19938) started and removed as designed, `receipts.md5` unchanged, `check_unit7.py 14 --runlog` PASS.

Published hashes: course2 `54b9f91f4923bc7faebb185564e45cde` · ddl `c1b6688e68dd8aeb7261fe7758bc2caf` · values `9bb07fa9ae1d5c5951626c524fc7fdea` · double `776798cb3b185c97d4b6fa7f33f6baf5` · digits `a66b7e9de360205d9505d50a0785c86d` · xcheck `2222f82bc8913bf1a89068373db3ec2b` · exercise `e21136d6d8f2e4cbace1e534d7230225`.

### A sealed fresh clone — the recipe (R.129)

**Paste it into bash.** Unit 13's recipe, with this unit's folder (`DOCKER_CONFIG`: the OrbStack context lives in `~/.docker`; the
clone's `HOME` is the sealed one):

```bash
S=/tmp/sealed14; W="/tmp/sealed 14"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
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
cd "$W/tiffinbox-java/c7-unit14" && readlink anchor && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E DOCKER_CONFIG=$HOME/.docker ./receipts.sh            # a process group of its own
```

In a clone, `java2_series.py` (on the author's Desktop) and the builders' `dur7.py` are not beside it: the terminal says so for each,
and the values this script holds for them — asserted against both files on every run where they are there — are the check. Course
2's three files (`../c2-unit21/Money.java`, `Rounding.java`, `README.md`) are in this repository and are read, md5 by md5, in every run.
**Run (2026-11-05):** a `git clone` of tiffinbox-java at `c7856c6` into a path **with a space** (`…/sealed 14/tiffinbox-java`, in the
session's scratch), this commit's 19 files put in as git takes them (`git ls-files -o --exclude-standard c7-unit14`; `anchor` →
`../c7-unit09/after` by `readlink`; `receipts.sh` the committed `fbf41b61…`); a `file://` copy of the s2 seed (4,971 files); pre-flight:
exit 1, 221 `Downloading from sealed: file://`, 0 from http(s); the clone's `.m2-demo` seeded from that copy; `/bin/bash` 3.2, `env -i`
with the dead proxies and `DOCKER_CONFIG`, a session of its own: **exit 0 in 207 s, all 7 = published, every check passed**; both
builds `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`; after the run `.m2-demo` held 4,971 files, 0
`_remote.repositories`; the terminal said that the builders' `dur7.py`, `java2_series.py` and unit 09's captures are not beside the clone
(the values held for them are the checks). Its terminal log through `--runlog`: PASS.

## The commands this unit adds

```bash
docker run -d --pull never --name c7-u14-pg -e POSTGRES_USER=sa -e POSTGRES_PASSWORD="$PGPW" -p 127.0.0.1:19938:5432 postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873
mvn -o -B -Dmaven.repo.local="$M2" dependency:build-classpath -Dmdep.outputFile=classpath.txt
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:.harness/drv/*" harness/src/probe/map/H.java harness/src/probe/map/Main.java harness/src/probe/map/money/*.java
java -Duser.language=en -Duser.country=US -Duser.timezone=UTC -Dlogback.configurationFile=../../harness/logback.xml "${V[@]}" -cp "../hc:../anchor/tiffinbox-web/target/extracted/lib/*:../drv/*" probe.map.Main "${A[@]}"
javap -v -p -cp .harness/hc "$K"
```

**The container** (one per run, started after the build and before the captures, removed at the end and by every exit — `$PGPW` is the
run's generated password, printed masked); **the driver** (run in `.harness/drvpom`, a copy of `harness/pom.xml`: Boot 4.1.2's parent and
`org.postgresql:postgresql` with no version written — Boot's managed **42.7.14**, with `checker-qual-3.55.1`, both copied to
`.harness/drv`); the harness compiled against the anchor's extracted jar (91 libraries, among them `hibernate-validator-9.1.5.Final.jar`,
`jakarta.validation-api-3.1.1.jar`, `tomcat-embed-el-11.0.27.jar` — asserted) and the driver; **the harness line** (run from
`.harness/run`: `V` its JVM flags — on PostgreSQL `-Ddb=pg -Dpg.port=19938 -Dpg.passfile=../pg/password`, the bind logger
`-Dbind=TRACE`; `A` its arguments; R.193, each printed as `$ V=(…)` / `$ A=(…)`); **`javap`** (S2.4's reading of a class file, `K` the
class, printed as `$ K=…`). The lines read from `anchor/README.md` (2, each asserted whole): `mvn -B package` and the extract line — unit
13's.

## The repository, and the network

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s2/` alone (6,613 files). Two builds: the anchor's `package` (its 18 tests run inside
it) and the driver's `dependency:build-classpath`, each `offline: yes` with 0 `Downloaded from` lines in every run of record (the label
is derived from the build log, never typed). After them the script asserts `.m2-demo` holds `spring-boot-starter-parent-4.1.2.pom`,
`hibernate-core-7.4.13.Final.jar`, `h2-2.5.250.jar`, `postgresql-42.7.14.jar` and `hibernate-validator-9.1.5.Final.jar`. **The
validator is in the seed** (`org/hibernate/validator/hibernate-validator/9.1.5.Final`, with `jakarta.validation-api` 3.1.1) because
the anchor's `tiffinbox-web` depends on `spring-boot-starter-validation` (Course 5's `TiffinBoxProperties`): the `digits` and `exercise`
refusals are measured, offline. **The image is never pulled** (`--pull never`; its id asserted equal to the digest before the run). **At
run time** nothing leaves the computer: H2 in a harness JVM's memory, PostgreSQL on `127.0.0.1:19938`. **No network act**: this unit
reads no version file — unit 06 made Section 2's dated sweep (`../../../data-jpa-hibernate/_research/spring-boot-metadata-2026-11-04.xml`:
4.1.2 the newest 4.1.x GA; R.223), and no Section 2 unit speaks a "newest" fact. **What ran on 42.7.14** (the AMENDMENT's "U14 on
42.7.14 → its unit's receipt"): every PostgreSQL factory of this unit — `ddl`, `values` (the rounding and the overflow), `double`,
`digits` — each printing `driver PostgreSQL JDBC Driver 42.7.14` from the connection's metadata, never typed. The probe's U14 PostgreSQL
values (42.7.13, then one `u14 write Bill` on 42.7.14) are the same as this unit's.

## The locale and the zone

Every java line carries `-Duser.language=en -Duser.country=US -Duser.timezone=UTC`; a last check refuses a capture's java line without
them. The locale matters here: **the validator's message** (`numeric value out of bounds (<8 digits>.<2 digits> expected)`) is the
`en` bundle's. A `TZ` (and `PGTZ`) variable of yours is planted with a canary and unset before anything runs. The test fork's locale
comes from the POM's `argLine`. **The harness prints ASCII** (` | ` between facts).

## The folders, the harness, the database and the ports

- `anchor` — the link to `../c7-unit09/after` (asserted: a link, that target). `.harness/anchor` — its copy, built with the README's
  `mvn -B package` offline, its jar extracted (91 libraries); `.harness/drv` — the driver; `.harness/hc` — the harness, compiled;
  `.harness/run` — where every harness JVM starts (its scripts land there); `.harness/pg` — the password's file (mode 0600, the folder
  0700) and the container's id; `.harness/ex` — the exercise's classes.
- **The harness** — the course's, never TiffinBox's (`harness/src/probe/map`, package `probe.map`; a check refuses `probe.map` anywhere in
  the anchor's code). `H.java` is unit 13's, its comment brought up to date (one `EntityManagerFactory` per factory a run asks for,
  `PersistenceConfiguration` over the classes the run names, Boot's two naming strategies, statistics on, `drop-and-create` on the run's
  own database only; the JDBC proxy counting the driver's calls; the PostgreSQL path — a fresh database per factory through the
  container's `sa` database, `select version()` cut before ` on `, the URL, the user, the driver's name and version from the connection's
  metadata; unit 13's two-JVM H2 file paths kept, unused here). Every JVM prints `org.hibernate.Version.getVersionString()` first and
  Hibernate's own `HHH000001` line (its core logger at INFO — R.222, #311). Scenarios (`Main.java`): `ddl NAME FILE NAME2 FILE2`, `values
  NAME AMOUNT…`, `double NAME`, `digits NAME A|B`, `script FILE CLASS…`, `ex NAME`, `xcheck FILE`. **No result is typed in the harness**:
  the amounts are the receipt's arguments (`VALS`, `OVER`) or Course 2's loop (thirty additions of `120.10`), and every amount printed is
  one Java computed or a database handed back — a check refuses `120.11`, `3693.08`, `3602.99…`, `"3603"` and `-120.11` in `harness/src`
  before anything is built.
- **Entities** (`probe.map.money`, English names only — S2.10, R.215; one column, `amount`, apart from the anchor's tables): `Bill`
  (`@Column(precision = 10, scale = 2) BigDecimal` — `values`, `digits` B), `PlainBill` (a bare `BigDecimal`), `DoubleBill` (a `double`),
  `DigitsOnlyBill` (`@Digits(integer = 8, fraction = 2)` alone), **`DigitsBill`** (`@Digits(integer = 8, fraction = 2) @Column(precision =
  10, scale = 2)` — `digits` A and **the shipped class S2.4's check reads**), **`ScaleThreeBill`** (DigitsBill with `@Column(precision =
  10, scale = 3)` — **the planted `scale = 3`, shipped as its own class** so a capture shows the check that cannot fail; the receipt asserts
  its source is `DigitsBill.java` but its name, its comment and that one number), `SixDigitsBill` (`@Digits(integer = 6, fraction = 2)
  @Column(precision = 10, scale = 2)`); and the exercise's `probe.map.ex.Bill` (`@Column(precision = 10, scale = 2)`, no `@Digits`;
  never compiled into `.harness/hc`, asserted). `harness/logback.xml` — unit 13's, its comment naming this lesson (the bind logger
  `org.hibernate.orm.jdbc.bind` at `-Dbind=`, TRACE in `values` and the exercise); `harness/pom.xml` — unit 13's driver POM (`u14-driver`);
  `harness/dur7.py` — the builders', md5 `41667fed…`, byte for byte.
- **The database** (S2.9): `postgres@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873` (`postgres:18-alpine`,
  PostgreSQL 18.6), `docker run -d --pull never --name c7-u14-pg`, `POSTGRES_USER=sa`, **a 24-character password generated per run**
  (`head -c 4096 /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | head -c 24` — unit 07's bounded form), published on **`127.0.0.1:19938` only**
  (`docker port` asserted to be `5432/tcp -> 127.0.0.1:19938` and nothing else), `pg_isready` awaited, **removed** (`docker rm -f`) at the
  end — asserted gone (`docker ps -a --filter name=c7-u14-pg`: 0 lines) — and by the EXIT trap. Before it: Docker answers, the image's id
  equals the digest, no container of that name exists. `open-webui` (someone else's, `0.0.0.0:3000`) is never touched: the script names
  only its own container. **The second connection** (the row as the database holds it) is the driver's own, not Hibernate's, not counted:
  `getString` for a `numeric`, `getDouble` then `Double.toString` for a `float(53)` — and, labelled as the database's text, not the
  value, `amount::text` (PostgreSQL) / `cast(amount as varchar)` (H2).
- **Ports** (§P, 19930-19939): **19938 the container's**, on 127.0.0.1; **19939 never bound** (asserted free at the start, after the
  container is up, and at the end). 19930-19937, 18425, 8080 and 35729 checked free first and last; nothing of this unit binds them.

## Masks, filters and hygiene — every one, declared

1. **`mask()`** (`gsub()`, literals escaped; checked first on planted lines, the planted password among them): **the database password →
   `[masked: the 24-character password]`**; this folder → `…`, the folder above → `…/..`, home → `~`, the user name → `<user>`; ` using Java
   <version>`; an identity hash → `@…`; Hibernate's generated constraint names → `FK<hash>` / `UK<hash>`; H2's generated index and
   constraint names → `PRIMARY_KEY_<n>`, `CONSTRAINT_<n>` (none appears in this unit's captures; kept from unit 13, checked on the plants).
2. **The password, counted raw** (S2.9): every raw capture run — before the mask — must hold it **0** times, else the run stops naming
   the capture; at the end every file of this folder but `.m2-demo` holds it **once**: its own file.
3. **A harness log** (`hview`): every line, trailing spaces dropped (the PostgreSQL overflow's `Detail:` line included). **A Maven log**:
   never printed in a capture. **Course 2's files** (`course2`): `sed -n` of `Money.java` 10-24 and 38-45, `Rounding.java` 15-17,
   `README.md` 4-5, trailing spaces dropped. **`javap -v -p`** (`digits`' S2.4 part): only the `amount` field's `RuntimeVisibleAnnotations`
   — the annotation names and their `name=value` lines; javap's header (the class file's path, its date, its checksum) and the constant
   pool indexes are not printed (a check refuses `Last modified`, `SHA-256 checksum`, `Classfile ` in every capture).
4. **Hygiene, checked last over every capture** (unit 13's list): no absolute path, **no unit number — except `course2`, which names
   Course 2's folder, `../c2-unit21/…`, by design** — no time, no log time, no thread number, no JDK/OS version token, no unmasked
   generated name, **no port but the container's 19938**, no per-run timing figure, no stack frame, no javap header; every java line
   pinned — locale and zone; `GenerationTarget encountered exception` 0 in every harness log (R.213) and right after each capture
   (`nowarn`, S2.8); no SQL keyword as a field name; **no H2 database file anywhere in this folder or beside it** (R.195); no
   `pkill`/`killall`; no bare `wait`; no one-string multi-option variable (R.193); no Indian dish name in any capture (R.215).
5. **Duration words** (R.172): `dur7.DUR` over this README and the exercise's two files must find **0** — this unit speaks no time.
   **Dish names** (R.215, S2.10): unit 13's 43 words, whole words, any case, refused in `exercise/`, `harness/src` and this README before
   anything is built, and in every capture at the end.
6. **"Hibernate rounds"** (S2.14, R.219): the phrase — `rounds`, `rounded`, `rounding`, `round` after `Hibernate`, any case — is refused
   unquoted in this README and `exercise/` — checked right after the `values` capture, so the die line quotes **that capture's** bind
   value (`<- [120.105]`) and its rows (`120.11` / `120.11`), the witnesses that forbid it. (Quoted, as here, it is the sentence named as
   never said.)
7. **Typed values**: a result-shaped literal in `harness/src` stops the run before the build; and this README's line of the values the
   video may say is compared with the values the checks read from the captures (below).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the Maven it
waits for (`$mpid`, with every process under it — Surefire's fork), the exercise's shell (`$xpid`), sweeps its own process group for any
harness JVM, Maven or Surefire fork left, **removes the container** (`docker rm -f c7-u14-pg`, if this run started it), deletes the
capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched. No `wait` in the script or
the exercise is bare.

**Measured (2026-11-05, a scratch mirror holding the seven published captures, the script as committed):** `./receipts.sh` (/bin/bash
3.2) started in a session of its own with SIGINT at its default, `kill -INT` to its group once the named point was reached, the state
read 5 s later — each **exit 130, nothing left, the container gone**:

```
build: processes in the group at SIGINT 5 · container up at SIGINT 0 · exit 130 · 5 s later in the group: 0 · container 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java: 0
harness: processes in the group at SIGINT 3 · container up at SIGINT 1 · exit 130 · 5 s later in the group: 0 · container 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java: 0
container: processes in the group at SIGINT 3 · container up at SIGINT 1 · exit 130 · 5 s later in the group: 0 · container 0 · ports listening 19800-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes · java: 0
```

`build` — the anchor's Maven (its Surefire fork running), before the container; `harness` — the first harness JVM (`ddl` on H2), the
container up; `container` — the first PostgreSQL harness JVM (`-Ddb=pg`, its fresh database open in the container). `pgrep -f
probe.map.Main` afterwards: none; `docker ps -a --filter name=c7-u14-pg`: 0 lines.

## 1 · course2 — Course 2's money lesson, read off its files (C7-9's promise; no JVM)

The title, *Money, Overflow and the Bill That Was Wrong* — `java2_series.py`'s `"21"` entry, read off the file (R.63, #306's form);
`Money.java` (md5 `490ab5a990f35f88a6b7fb798b868d27`) lines 10-24 by `sed -n` — the thirty additions of `120.10` in a `double`
(`dTotal += 120.10`), in a `BigDecimal`, in paise — and 38-45 — the bill, the fee, the gross and **`due = gross.setScale(2,
RoundingMode.HALF_UP)`**; `Rounding.java` (md5 `a7ce857d8d92aa02b7f5512fbbad9289`) 15-17 — `1.005` as a double and as a `BigDecimal`;
its `README.md` (md5 `d7ca9f3e2b697c7abe83f94cd5759d8b`) lines 4-5, the measured output: **`double total = 3602.999999999998`**,
**`BigDecimal total = 3603.00`**, **`fee 90.07500 scale 5`**, **`due 3693.08 scale 2`**, and `new BigDecimal("1.005").setScale(2,HALF_UP)
= 1.01` — each asserted once in the capture.

## 2 · ddl — the columns (H2 and PostgreSQL; validation as found and switched off — four scripts, byte-equal)

One JVM per database, two factories over the seven entities: Bean Validation as Hibernate finds it, then
`jakarta.persistence.validation.mode=NONE`. Every script, on both databases, both modes:

| entity | annotations | Hibernate's DDL |
|---|---|---|
| `Bill` | `@Column(precision = 10, scale = 2)` | `amount numeric(10,2)` |
| `PlainBill` | none — a bare `BigDecimal` | **`amount numeric(38,2)`** (Hibernate's default scale is 2, not 0) |
| `DoubleBill` | a `double` | **`amount float(53) not null`** |
| `DigitsOnlyBill` | `@Digits(integer = 8, fraction = 2)` | `numeric(10,2)` — precision = integer + fraction |
| `DigitsBill` | `@Digits(8, 2)` + `@Column(10, 2)` | `numeric(10,2)` |
| `ScaleThreeBill` | `@Digits(8, 2)` + **`@Column(10, 3)`** | **`numeric(10,2)` — `@Digits` decides the scale** |
| `SixDigitsBill` | **`@Digits(6, 2)`** + `@Column(10, 2)` | **`numeric(8,2)` — `@Digits` decides the precision** |

**With validation switched off the DDL is the same, byte for byte** (`cmp`, both databases): the DDL step reads `@Digits` whatever the
persist-time validation mode. **H2's script = PostgreSQL's, byte for byte.** So a DDL capture cannot tell whether `@Digits` and
`@Column(precision, scale)` agree — S2.4's check reads both off the class (`digits`, below).

## 3 · values — what Hibernate sent, what the object holds, what the row holds (H2 and PostgreSQL; S2.14)

One JVM per database, one `Bill` per value, **each in its own transaction**, then the 11-digit value in a fresh JVM (a fresh database):

| value persisted | bind logger (what Hibernate sent) | the managed `Bill` after the flush, same persistence context | the row, second connection | a new EntityManager | H2 = PostgreSQL |
|---|---|---|---|---|---|
| `3603.00` | `<- [3603.00]` | `3603.00` | `3603.00` | `3603.00` | yes |
| **`120.105`** | **`<- [120.105]`** | `120.105` | **`120.11`** | **`120.11`** | yes |
| `120.104` | `<- [120.104]` | `120.104` | `120.10` | `120.10` | yes |
| `-120.105` | `<- [-120.105]` | `-120.105` | `-120.11` | `-120.11` | yes |
| `3693.07500` (Course 2's gross) | `<- [3693.07500]` | `3693.07500` | `3693.08` (Course 2's `due`) | `3693.08` | yes |
| `123456789.00` | `<- [123456789.00]` | — | — (rows: `[0]`) | — | **no: the message** |

Each stored value: **one INSERT, counted three ways** (the SQL logger's `insert into bill` line, `getPrepareStatementCount()` 1, the
driver's `prepareStatement` 1 — R.184); **0 `WARN` and 0 `ERROR` lines in the whole rounding JVM's log, asserted**, on both databases:
the rounding is silent. `em.find(Bill, id)` in the same persistence context returns that very object (`true`), still holding the value
it was given — **measured** (the probe's "Not measured" line, R.201): after the flush the managed object says `120.105` while the row
says `120.11`, until something reads the row again. **The failure receipt:** `123456789.00` — **exit 1**, `PROBE EXCEPTION
org.hibernate.exception.DataException: could not execute statement [...`, caused by **H2 `org.h2.jdbc.JdbcSQLDataException: Value too
long for column "AMOUNT NUMERIC(10, 2)": "123456789.00 (11)"`** / **PostgreSQL `org.postgresql.util.PSQLException: ERROR: numeric field
overflow`** (its `Detail:` line: `A field with precision 10, scale 2 must round to an absolute value less than 10^8.`), Hibernate's
`HHH000247` WARN pair before it, one INSERT prepared and executed, **nothing stored**. Each database's message is checked against its
own block and refused in the other's.

## 4 · double — Course 2's lesson, now in a column (H2 and PostgreSQL)

Course 2's loop, thirty additions of `120.10` in a `double` → **`3602.999999999998`**, stored in a `DoubleBill` (`float(53) not null`)
beside `new BigDecimal("3603.00").doubleValue()` = `3603.0`; two INSERTs (three ways). **Read through JDBC** (`getDouble`, then
`Double.toString`): `[id 1: 3602.999999999998, id 2: 3603.0]` on both databases; a new EntityManager reads the same;
`thirty additions == 3603.00 after the round trip: false`. **The database's own text** — labelled, not the value: H2 `3603.0`;
**PostgreSQL `3603`** for the whole double (`amount::text`) — the brief's hazard, shown and kept off the slide as a stored value.

## 5 · digits — the refusal you write (A/B/A′, H2 and PostgreSQL) and S2.4's check (R.209)

`120.105`, one transaction, per database:

- **A — `DigitsBill`** (`@Digits(integer = 8, fraction = 2)` beside `@Column(precision = 10, scale = 2)`): **`refused at persist:
  jakarta.validation.ConstraintViolationException: Validation failed for classes [probe.map.money.DigitsBill] during persist time for
  groups [jakarta.validation.groups.Default, ]`**, the violation `probe.map.money.DigitsBill.amount = 120.105: numeric value out of bounds
  (<8 digits>.<2 digits> expected)`; **0 statements, counted three ways** — no `insert` line in the SQL log, `getPrepareStatementCount()`
  0, the driver's `prepareStatement` 0 — and `rows in digits_bill: [0]`. Exit 0 (the harness catches the refusal and prints it).
- **B — `Bill`** (no `@Digits`): one INSERT (three ways), the row `120.11`, a new EntityManager `120.11`; nothing refuses.
- **A′ — A again, a fresh JVM, a fresh database:** every line A printed, its database name aside (compared whole).

**S2.4's check** — the two annotations are one fact (R.209, R.174's shape, U03's `@Size`/`@Column(length)` finding): one H2 JVM writes
Hibernate's DDL for `DigitsBill` and `ScaleThreeBill` to a file (never run); `javap -v -p` reads each class file's `amount` field:

| class | read off the class file | DDL | the DDL-only check (`@Digits` vs DDL) | **S2.4's check** (`@Digits` vs `@Column` vs DDL) |
|---|---|---|---|---|
| `DigitsBill` (shipped) | `Digits(integer=8, fraction=2)` · `Column(precision=10, scale=2)` | `numeric(10,2)` | pass | **pass** |
| `ScaleThreeBill` (the planted `scale = 3`) | `Digits(integer=8, fraction=2)` · `Column(precision=10, scale=3)` | `numeric(10,2)` | **pass — the check that cannot fail** | **FAIL** |

The DDL still says `numeric(10,2)` on the plant: a check fed the DDL alone passes it; the check that reads both annotations off the
shipped class fails it. (And a plant on the shipped `DigitsBill` itself — `scale = 3` — stops the receipt: Planted faults.)

## 6 · xcheck — the harness's DDL against Boot's, as unit 09 captured it (R.212, RED #308; H2)

The harness's own EntityManagerFactory over `com.tiffinbox.CustomerEntity` and `com.tiffinbox.PauseEntity` (from the anchor's jar)
writes `xcheck.sql`: three lines, **md5 `f595637014e786fa38606859951e4f97` = Boot's script as unit 09 captured it** (#308) — the md5 read
from `../c7-unit09/README.md` (asserted there) and that capture's own published md5 `9072c6f1…` read from `../c7-unit09/receipts.md5`
before any build. **No Boot run.** When `../c7-unit09/.r-xcheck.out` is on disk with its published md5, Boot's three lines are read
from it and each asserted in this capture too.

## 7 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196; H2 in memory, one fresh JVM per block)

`exercise/README.md`'s 7 lines, then `exercise/SOLUTION.md`'s (the README's with one line changed: the copy of `Bill.java` made with
`sed`, `    @Column(precision = 10, scale = 2)` → `    @Digits(integer = 8, fraction = 2) @Column(precision = 10, scale = 2)`), each
block sourced in one `env -i` shell, `/bin/bash --noprofile --norc` then `/bin/zsh -f`, **each block its own fresh JVM**. In both shells:
the README → `binding parameter (1:NUMERIC) <- [120.105]`, one INSERT (`getPrepareStatementCount` 1, `prepareStatement` 1), **`read back
by a new EntityManager: amount 120.11`**; the solution → **`refused at persist: jakarta.validation.ConstraintViolationException: …
[probe.map.ex.Bill] during persist time …`**, the violation, **`statements prepared (getPrepareStatementCount) 0`**, `prepareStatement
0`, no INSERT line; each JVM exit 0; the shell back in this folder; bash's output = zsh's. Broken (`120.11` stored) ≠ solved (refused).

## Exercise

**Your turn:** the README saves a bill of 120.105 and the table quietly keeps 120.11. Make it refuse the third decimal before any SQL.
(24 words, `wc -w` on the quoted sentence, asserted in `receipts.sh`.) `exercise/README.md` ships `Bill.amount` with no `@Digits`,
`exercise/SOLUTION.md` beside it; broken ≠ solved, each half from its own fresh JVM, measured by the `exercise` capture (R.196).

## What the video may say — and the capture each comes from

- **The hook (`values`, both databases):** `120.105` goes in — **`<- [120.105]`** on the bind line — and **`120.11`** comes out (the row
  by a second connection and a new EntityManager), no error, no warning (0 WARN asserted), "on H2 and on PostgreSQL" (both
  `database:` lines in the capture, S2.12).
- the values the video may say: 120.105 bound [120.105], the row 120.11 (H2) and 120.11 (PostgreSQL) · 120.104 -> 120.10 · -120.105 -> -120.11 · 3693.07500 -> 3693.08 · 3603.00 -> 3603.00 · 123456789.00 refused - H2 'Value too long for column "AMOUNT NUMERIC(10, 2)"', PostgreSQL 'numeric field overflow' · the double 3602.999999999998 and 3603.0 read through JDBC (PostgreSQL's own text of the second: 3603) · A refused with 0 statements
  (`receipts.sh` compares this line with the values its checks read — a typed value fails it.)
- **Who rounds: the database.** Never `"Hibernate rounds"` (S2.14, R.219): the bind logger shows Hibernate sending
  `binding parameter (1:NUMERIC) <- [120.105]`; the row holds `120.11`. The voice says "the database rounds it", per database or
  "on both". The managed object still says `120.105` after the flush (`values`, measured in the same persistence context) — may be said
  as what the capture prints ("the object in memory still says one-twenty point one-oh-five"), never as a mechanism (R.201).
- **Both ways, per database** (§4.4): the fraction rounded quietly — `120.104` → `120.10`, `-120.105` → `-120.11` (away from zero),
  Course 2's gross `3693.07500` → `3693.08`, the same `due` Course 2's `setScale(2, HALF_UP)` gave; the integer digits refused loudly —
  H2 "Value too long for column", PostgreSQL "numeric field overflow", each said with its database, never one for the other.
- **The columns** (`ddl`, H2 = PostgreSQL): `@Column(precision = 10, scale = 2)` → `numeric(10,2)`; a bare `BigDecimal` → `numeric(38,2)`;
  a `double` → `float(53)`. **"`@Digits` decides the column here"** — `@Digits(6,2)` beside `@Column(10,2)` → `numeric(8,2)`; `@Column(scale
  = 3)` beside `@Digits(fraction = 2)` → `numeric(10,2)`; the same with validation switched off. Never "`@Column` makes numeric(10,2)" (S2.4).
- **The double** (`double`, both databases): `3602.999999999998`, stored and read back exactly so — "Course 2's error, now in a column";
  the value is the one read through JDBC. PostgreSQL's text `3603` is never shown as the stored value.
- **The refusal you write** (`digits` A, A′, both databases): `ConstraintViolationException … during persist time`, `numeric value out of
  bounds (<8 digits>.<2 digits> expected)`, **0 statements** — "before any SQL", with the count's three witnesses on the slide.
- **S2.4's check** (`digits`): the slide that says the two annotations agree shows the class file's two lines and the DDL; the planted
  `scale = 3` shows the DDL-only check passing and S2.4's failing.
- "Hibernate 7" for the version; each capture prints `7.4.13.Final` twice per JVM (`HHH000001` and `getVersionString()`, R.222) and, on
  PostgreSQL, the driver's `42.7.14` and `select version()`'s `PostgreSQL 18.6` (S2.17, S2.9). The harness's DDL = Boot's (`xcheck`).
- **Glossed at first use** (contract §10): precision (all the digits a column keeps) and scale (the digits after the point). Course 2's
  lesson called back by its title.
- **Not said:** any duration of the machine (R.172); the rounding rule's name for each database (HALF_UP-like is the probe's reading —
  this unit captured five values, `120.105` up, `120.104` down, `-120.105` away from zero, `3693.07500` up; say what they show); why the
  validator runs at persist (the message says "during persist time" — quote it, no mechanism); anything about the anchor's own money
  column beyond "it stays whole rupees".

## The ledger rows and hand-offs this unit pays

- **C7-9 — paid.** Course 2 U21's money "enforced by DDL": **the DDL enforces the integer digits — refused** (`values`' overflow, a
  `DataException` on both databases, nothing stored) **and rounds the fraction — said exactly so** (`values`: `<- [120.105]` bound,
  `120.11` stored, silently, on both); **`@Digits` refuses before SQL** (`digits` A and A′: 0 statements three ways, both databases;
  the exercise in two shells); the column itself from `ddl` (`numeric(10,2)`, H2 = PostgreSQL), Course 2's lesson by its title and its
  files (`course2`), its double's error in a column (`double`).
- RE-MEASURE 1 (the exercise as README + SOLUTION) and 12 (`xcheck` on `09/after`) are settled here (below).

## RE-MEASURE — the brief's items this unit settles

| # | Settled here |
|---|---|
| 1 | the exercise as README + SOLUTION files, bash and zsh, `env -i`: `120.11` stored / refused with 0 statements, a fresh JVM each half |
| 12 | `xcheck` on `09/after`: `f595637014e786fa38606859951e4f97` (Boot's script as 09 captured it) |

And the AMENDMENT's "U14 on 42.7.14": every PostgreSQL value of the probe's Step 9 table re-run on the 42.7.14 driver (printed by each
factory) — the same: `120.105` → `120.11`, `120.104` → `120.10`, `-120.105` → `-120.11`, `3693.07500` → `3693.08`, the overflow a
`DataException` with `numeric field overflow`, the double `3602.999999999998`, `@Digits` refusing with 0 statements. The probe's "Not
measured" line (what the managed entity holds after the flush) is measured: `120.105`, the same object.

## What differed from the brief

1. **The validator IS in the seed** — `org/hibernate/validator/hibernate-validator/9.1.5.Final` and `jakarta.validation-api` 3.1.1, and
   in the anchor's own extracted libraries (with `tomcat-embed-el-11.0.27`, the EL the validator's messages need) — so the `digits` and
   `exercise` refusals are measured, offline; none is labelled "not measured".
2. **The planted `scale = 3` ships as a class, `ScaleThreeBill`** — so the `digits` capture shows the DDL-only check passing on it and
   S2.4's failing, every run (the brief: "shown passing … shown failing"). The receipt asserts its source is `DigitsBill.java` but for its
   name, its comment and that one number. It is also the `ddl` table's `@Digits(8,2) + @Column(10,3)` row. The plant on the shipped
   class itself (`DigitsBill` given `scale = 3`) is run too and stops the receipt (Planted faults).
3. **A refusal is printed, not thrown out of the JVM**: `digits` A/A′ and the exercise catch the `ConstraintViolationException` and print
   it with the counts after it (0 statements needs a line after the refusal), exit 0. The overflow — the brief's failure receipt — ends
   its JVM with exit 1. The overflow runs in a JVM of its own, so its `rows in bill: [0]` is that database's whole table.
4. **The values capture holds two JVMs per database** (five values, one transaction each; then the overflow), not one per value; each
   value's block is checked on its own (bind, managed object, one INSERT three ways, row, new EntityManager).
5. **The managed object after the flush is measured** (the probe's "Not measured" line, R.201): `120.105` and `em.find` returns the same
   object — so it may be said as what the capture prints.
6. **The double capture stores a second row**, `new BigDecimal("3603.00").doubleValue()` = `3603.0`, to show the hazard the brief names
   (PostgreSQL's `::text` prints `3603`) beside the JDBC read (`3603.0`); H2's text is `3603.0`.
7. **`course2` quotes Course 2's README lines 4-5 whole** (the measured output Course 2 recorded) beside `Money.java` 10-24 and 38-45
   and `Rounding.java` 15-17; each of the brief's six strings is asserted once. `course2` is exempt from the "no unit number" hygiene
   check (it names `../c2-unit21/…` on purpose). Course 2's three files are in this repository (unit 13's script was not) — read in
   every run, a clone included; only the title's file is outside.
8. **`-Duser.timezone=UTC` stays on every java line** though this unit speaks no zone — unit 13's pin and check, kept (one less source
   of a machine difference).
9. **`digits` runs on both databases** (the brief names no database for it); A′ is compared with A line for line.
10. **Plants on copies** (unit 13's form), one after another: every run needs the one container name and port 19938.
11. **No H2 file database** in this unit (unit 13's two-JVM path is kept in `H.java`, unused); the R.195 check stays (no `*.mv.db`
    anywhere in the folder or beside it).
12. **The CARRIED anchor money column is asserted**, not only named: `Database.java`'s `price_per_meal INT NOT NULL` and
    `CustomerEntity`'s `private int pricePerMeal;`, read off the frozen tree at the start.

## Planted faults — each caught (R.65)

On copies (What differed, 10) — a scratch mirror reset from this folder before each, `receipts.sh` `fbf41b61…` (the one committed) —
one after another, each **exit 1**, nothing written to this folder; after each: 0 listeners on 19800-20399, no harness JVM, no
container, no `.r-lock`. Seventeen; the capture a plant changes was taken out of the copy's `receipts.md5`, so its check speaks:
- **`@Digits` removed from A** (`DigitsBill` keeps only `@Column(precision = 10, scale = 2)`) → `*** digits A on H2: 0 statements - no
  insert in the SQL log, getPrepareStatementCount() 0, the driver's prepareStatement 0 (R.184) ***` (223 s). (The `ddl` capture is
  unchanged by it — `@Column(10, 2)` gives the same `numeric(10,2)`.)
- **S2.4's check fed the DDL only** (its condition loses the `@Column` comparison) → it **passes** on `ScaleThreeBill`, and the receipt
  stops: `*** S2.4: S2.4's check fails on the plant: expected the line:   S2.4's check - … numeric(10,2) = Column(10,3) = numeric(10,2):
  FAIL ***` (118 s). The `digits` capture shows the DDL-only check passing on the plant in every run.
- **The shipped class planted** (`DigitsBill` given `@Column(precision = 10, scale = 3)`) → the DDL still `numeric(10,2)` (the `ddl`
  capture unchanged) → `*** S2.4: DigitsBill's two annotations and its DDL: expected the line:   read off the class file:
  Digits(integer=8, fraction=2) | Column(precision=10, scale=2) · … ***` (120 s).
- **"Hibernate rounds" in a README line** (a bullet, unquoted, saying the amount is rounded by Hibernate to two decimals) → `*** "Hibernate rounds" is false (S2.14,
  R.219) - the values capture's bind line says Hibernate sent <- [120.105] and its row holds 120.11 (H2) / 120.11 (PostgreSQL): the
  database rounds. Said in: README.md:314: … ***` (71 s), right after `values`.
- **A typed `120.11`** (the harness printing `"120.11"` for the row when the value is `120.105`) → `*** a typed result in the harness -
  … Main.java:117:120.11 ***` (3 s), before anything is built.
- **The overflow messages swapped between the databases** (this README's values line: H2 `numeric field overflow`, PostgreSQL `Value too
  long…`) → `*** README.md does not state the values these captures give (… H2 'Value too long for column "AMOUNT NUMERIC(10, 2)"',
  PostgreSQL 'numeric field overflow' …) ***` (145 s); each block's own check also refuses the other database's message.
- **The double read as text on PostgreSQL claimed as the stored value** (the JDBC read changed to `getString`, PostgreSQL's text `3603`)
  → `*** double on PostgreSQL: the stored doubles, read through JDBC: expected the line: … [id 1: 3602.999999999998, id 2: 3603.0] ***`
  (171 s) — H2's block passes (its text is `3603.0`); PostgreSQL's fails.
- **A raw database password in a capture** (`H.ds` printing it in the `database:` line) → `*** ddl: its raw output (run 1) held the
  database password - the mask would hide it; nothing may print it (S2.9) ***` (47 s).
- **A wrong image digest** → `*** the image is not on this computer: docker pull postgres@sha256:…a1874 ***` (1 s).
- **A wrong published hash** (`receipts.md5`'s `course2`) → `*** course2 is not the published capture … ***` (88 s).
- **A version claim without `HHH000001`** (`harness/logback.xml` without its `org.hibernate.orm.core` logger) → `*** ddl: the version
  lines - getVersionString() and Hibernate's HHH000001 - once in each of its 2 harness JVMs (R.222) ***` (44 s).
- **`xcheck` against a wrong 09 md5** (`X09` …`e4f96`) → `*** ../c7-unit09/README.md no longer states Boot's script md5 …e4f96 - the
  number this unit compares with ***` (65 s), before any capture.
- **A dish name** (one in this README) → `*** an Indian dish name (R.215: English names only): README.md:409: … ***` (1 s).
- **One per capture class:** `values` — the bind logger left at INFO → `*** values on H2: 3603.00 kept: the bind logger - Hibernate sent
  the value whole: expected the line:   TRACE org.hibernate.orm.jdbc.bind : binding parameter (1:NUMERIC) <- [3603.00] ***` (85 s);
  `course2` — `sed -n 11,24p` → `*** course2: Money.java lines 10-24 (15) and 38-45 (8) ***` (33 s); `ddl` — `PlainBill` given
  `@Column(precision = 10, scale = 2)` → `*** ddl on H2: the script - expected, every line: … ***` (50 s); `double`, `digits`, `xcheck`
  above; `exercise` — `SOLUTION.md`'s `sed` given a pattern that matches nothing → `*** exercise: the solution - refused, 0 statements:
  expected the line:     PROBE refused at persist: jakarta.validation.ConstraintViolationException: … ***` (148 s).

## Found on the way

- **PostgreSQL's overflow message says "round"**: its `Detail:` line — `A field with precision 10, scale 2 must round to an absolute value
  less than 10^8.` — the database's own word for what it does to the fraction. Printed in `values` (the log whole); not a beat.
- **Hibernate logs the overflow as two WARN lines** (`HHH000247: ErrorCode: 22001, SQLState: 22001` on H2; `ErrorCode: 0, SQLState:
  22003` on PostgreSQL) before the exception — the overflow is loud twice; the rounding never.
- **The IDENTITY INSERT differs by database** (unit 06's finding, again): H2 `insert into bill (amount,id) values (?,default)`, PostgreSQL
  `insert into bill (amount) values (?)`; PostgreSQL also logs `set client_min_messages = WARNING` before its DDL. Not a beat.
- **The second factory in one JVM logs no second `HHH000001`** (`ddl`'s two factories): the version line is once per JVM; `ver()` counts
  JVMs, the `database:` lines count factories.
- **S2.4's check died silently on a class without `@Digits`** (the first `@Digits removed` plant): `$((di + df))` with no number is an
  arithmetic error, and bash ends the whole command line it sits on — the `digits` capture and its checks were skipped and the run went
  on to `xcheck`, to stop only at the values line. Now a missing `@Digits` prints `(no @Digits)` and the capture goes on to its own
  check, which stops the run (the plant above). Fixed before the runs of record.
- **The first run on the final tree stopped at its own "Hibernate rounds" check** — this README's plant paragraph quoted the planted
  line unquoted; reworded, the run passed. The check reads prose as prose.
- `HHH000489: No JTA platform available …` (INFO) in every factory — deterministic, kept (unit 13's).

## CARRIED

- **Money in the anchor** — `price_per_meal` stays an `INT` of whole rupees (`Database.java`, `CustomerEntity.pricePerMeal`; the record
  `Customer`, `monthlyBill`, the web layer's JSON and the seven read an int): ⚑4's loser, not this course's move; named once here.
- **The rounding rule's name per database** (HALF_UP vs HALF_EVEN) → not measured beyond the five values (no `x.xx5` with an even
  second decimal, e.g. `120.125`); the voice says what the five show.
- **`@Digits` on a `double` or with `@DecimalMax`/`@DecimalMin`** → not measured; no beat needs them.
- **`@Column(precision, scale)` on PostgreSQL's `money` type or `columnDefinition`** → not measured; the beat is `numeric`.
- **Validation on update (`preUpdate`)** → not measured; the beat is persist.
- `xcheck` compares with unit 09's `f595637014e786fa38606859951e4f97` (unchanged by this unit).
- The builder (s714) must: cite two `database:` lines for every cross-database slide (`ddl`, `values`, `double`, `digits` — S2.12); put
  the bind line `<- [120.105]` beside every `120.11`; refuse `"Hibernate rounds"` in SAY lines (S2.14) and the dish-name list (R.215);
  quote each overflow message with its own database; show `executeBatch`-free three-way counts beside "0 statements"; assert `duration
  words: 0` (R.172).

## For RED

Re-run from a clean tree (seeded `.m2-demo`, the image present, Docker answering) in a process group of its own with SIGINT at its
default; ports 20240-20279 for any re-run of this unit's JVMs or a container outside its script. Worth breaking: a value with an even
second decimal and a 5 after it (`120.125`) on each database (HALF_UP vs HALF_EVEN — not measured, CARRIED); whether `@Digits` is checked
on update as well as persist; whether Hibernate Validator's message changes with a non-`en` locale (pinned here); whether
`hibernate.validator.apply_to_ddl=false` makes `@Column` decide the DDL again (not measured — S2.4's check would then still hold the two
equal on the shipped class); whether the managed object's `120.105` survives `em.refresh` (not run: the beat says only what the
capture prints).
Evidence by a Claude Opus 5.5 agent on 2026-11-05.
