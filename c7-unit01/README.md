# c7-unit01 — The Object-Relational Mismatch, Named

Course 7 · Data with JPA & Hibernate · Section 1 (ORM from First Principles), its first unit · Verified on **JDK 25.0.4.1, Apache
Maven 3.9.16** (BSD grep 2.6.0 at `/usr/bin/grep`; H2 2.5.250, HikariCP 7.1.0 and slf4j-simple 2.0.17 — the versions Course 2's POM
names, read from it), 2026-11-03. **H2, in memory**: no Postgres, no container, no Boot JVM, no port bound. ORM, object-relational
mapping, is the work of moving data between objects and the rows of tables. Course 2 did that work by hand, in one class:
`JdbcCustomerRepository`, from the lesson *TiffinBox on a Real Database: The JDBC Repository*. This unit opens that class again,
counts what was written by hand — the SQL as strings, the mapping in both directions, the `SQLException`s, a connection per method,
the id and the dialect — with one named command per count, and runs it to show the one problem no grep can see: two reads of the same
row give two different objects. Objects have identity, references and types; rows have keys, columns and strings — each count is a
place where the two meet by hand.

**No anchor change.** `anchor` is the link to `../c7-unit03/after` — the tree the first-entity lesson froze — and the script dies unless
`diff -rq -x .m2-demo -x target -x secrets anchor/ ../c7-tiffinbox` is empty, at its start and again at its end: it was, in every run of
record. Nothing is built from the anchor: the `file` capture reads its `CustomerRepository` and its settings off the tree. **Course 2's
folder, `../c2-unit38`, is never built in place and never changed**: its sources and POM are copied into `.harness/c2` (each
`cmp`-checked) and compiled there; the script dies if `../c2-unit38` holds a `target/` or a `data/`, first and last.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 4 captures, 3 runs each; every spoken number asserted after its capture; a published-md5 mismatch stops it
```

(`receipts.sh` carries the `JAVA_HOME` export on its first line after the shebang and dies unless `java -version` and `javac -version`
say 25; a bare `java` on this Mac is 23.0.1.) It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line
first). **Start it in a process group of its own** (a terminal's foreground job is one): `sweep()` stops only processes of its own group.
`.m2-demo` must be seeded first (below) — or the one Maven run happens once more without `-o`, and its `offline:` line names the
artifact it missed and the repositories that answered.

**Runs (2026-11-03), each `env -i`** (`HOME` = a home of its own whose `.mavenrc` sets `-Duser.home` there and whose `settings.xml`
names only two dead proxies, `127.0.0.1:9` — so no Maven run could reach the network; `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:
/sbin`; `http(s)_proxy` dead too), a session of its own, `.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s1/`
alone (6,608 files). Six development runs fixed the captures and the checks (the sixth made every capture 3/3 and stopped at "no published hash" with every check passed; its md5s are `receipts.md5`); then two changes that leave every capture byte for byte as published — R.162's check moved to the front of the `file` checks, and H2's statement time removed from the trace ("Found on the way") — and the runs of record. **The runs of record, on the script as committed (`receipts.sh` md5 `c8d605c5c26c8dcea285d9a3c23a9bf0`): 9 s under
`./receipts.sh`** (/bin/bash 3.2.57) **and 10 s under `bash receipts.sh`** (Homebrew bash 5.3.9): each exit 0, all 4 captures 3/3 =
published, every check passed, the Maven run `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`; each terminal log
through `check_unit7.py 01 --runlog` — `0 grep error line(s)`, `RESULT (run logs): PASS` (the unit gate itself answers "no 01-*.md …
nothing to check": no script yet). **No run of record downloaded anything** (the empty-repository trial below read 231 artifacts
from the `file://` copy of the seed, and nothing over http(s)). After this README's numbers were written, the same two runs on the tree as committed:
13 s and 13 s, each exit 0, all 4 = published, `--runlog` PASS.

**Re-run after unit 06 moved the anchor (2026-11-04).** `../c7-unit06`'s commit changed `../c7-tiffinbox` (its `Database.java`, `CustomerEntity.java`, README), so this script's equality checks against it became notes, never stops (R.211, the Course 6 form on the terminal): anchor/ is still the frozen tree this unit measured. `receipts.sh` md5 **since: `dfd00c76a6ab902d731f011b8b34c9e2`** (the anchor checks and the lines and comments that said "= ../c7-tiffinbox"; nothing inside a capture). One run on the moved anchor, `./receipts.sh` (/bin/bash 3.2.57), `env -i` as above: exit 0 in 9 s, the note printed, all 4 captures 3/3 = published, `receipts.md5` unchanged, `check_unit7.py --runlog` PASS. The `file` capture still prints "(anchor/ = ../c7-tiffinbox)" inside its hashed text (line 232 of the script): true of the tree it read, `../c7-unit03/after`, the anchor until unit 06.

Published hashes: file `878b8d1d97f251f0d5801267d67a22b7` · count `86ccb6cc9f27d9df2415242948647f3b` · identity `fba7feef01c8a33b6613d96e7e43fbd1` · exercise `d1f416f7bc6ff73d49a8b88776404f30`.

### A sealed fresh clone — the recipe (R.129)

**Paste it into bash** (type `bash` first if your Terminal is zsh: zsh does not split the unquoted `$E`).

**Run (2026-11-03):** a `git clone` of tiffinbox-java at `0cdd9b4` into a path **with a space** (`…/sealed 01/tiffinbox-java`), with `c7-unit01/` and `.gitignore` put in as git would take them (`git ls-files -co --exclude-standard`: 9 files, each `cmp`-equal to the working tree; `anchor` → `../c7-unit03/after` by `readlink`); a `file://` copy of the seed (4,967 files: `_remote.repositories`, `*.lastUpdated` and `resolver-status.properties` left out); pre-flight: exit 1, 221 `Downloading from sealed: file://`, 0 from http(s) — `sealed: file:// only`; the clone's `.m2-demo` **seeded from that copy** (4,967 files); `/bin/bash` 3.2, `env -i`, a session of its own, with this unit's files as committed: **exit 0 in 14 s, all 4 = published, every check passed**; the Maven run said **`offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`**; after the run the clone's `.m2-demo` still held 4,967 files (0 gained, 0 `_remote.repositories`). Its terminal log through `--runlog`: PASS. (The builders' `dur7.py` is not beside a clone: its md5 is the check.) **And with an empty `.m2-demo`** (a copy of the clone, the seeding line left out; same script): `offline: no - the offline run could not resolve org.apache.maven.plugins:maven-dependency-plugin:jar:3.7.0 from .m2-demo, so it ran once more without -o; that run downloaded from: sealed (file) 231; of them over http(s): 0 · exit 0 · 'Downloaded from' lines in its log: 231` — its `_remote.repositories`: 231 `>sealed=`, 0 `>central=` — and then exit 0, all 4 = published: the label names the one repository that answered, never one the log does not.

```bash
S=/tmp/sealed01; W="/tmp/sealed 01"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
mkdir -p "$S/home/.m2" "$W" && git clone -q "file://$T" "$W/tiffinbox-java"
rsync -a --exclude _remote.repositories --exclude '*.lastUpdated' --exclude resolver-status.properties "$T/../../data-jpa-hibernate/_research/m2-seed-c7-s1/" "$S/central/"
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
cd "$W/tiffinbox-java/c7-unit01" && readlink anchor && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E ./receipts.sh            # a process group of its own
```

(The clone's own `c7-unit01/` is the committed one once this unit is in git; before its commit it was put in as above.)

## The commands this unit adds

```bash
mvn -o -B -Dmaven.repo.local="$M2" dependency:build-classpath -Dmdep.outputFile=cp.txt
javac -d .harness/classes -cp "$(cat .harness/c2/cp.txt)" .harness/c2/src/main/java/*.java harness/C7Identity.java
java -Duser.language=en -Duser.country=US -cp "../classes:$(cat ../c2/cp.txt)" C7Identity
```

`receipts.sh` reads two lines from Course 2's README (`../c2-unit38/README.md`, each asserted there whole, in its backquotes): `mvn -q
dependency:build-classpath -Dmdep.outputFile=cp.txt` and `java -cp "target/classes:$(cat cp.txt)" RepoDemo` — Course 2's own way to
run its classes on a class path. Each line above is asserted in this README, and two are asserted to be derived: **the class-path
line** is Course 2's with `-q` made `-o -B -Dmaven.repo.local="$M2"`, nothing else (run from `.harness/c2`, the copy); **the run line**
is Course 2's with the locale, `../classes` for `target/classes`, `../c2/cp.txt` for `cp.txt` and the harness `C7Identity` for
`RepoDemo`, nothing else (run from `.harness/run`). The `javac` line compiles Course 2's six sources (as copied) and the harness
together into `.harness/classes`; it initialises nothing, so `RepoDemo` and `Db` are compiled and never run.

## The repository, and the network

The one Maven run is `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s1/` alone (6,608 files) before the runs of record: `rsync -a
../../../data-jpa-hibernate/_research/m2-seed-c7-s1/ .m2-demo/` from this folder. It resolves the class path of Course 2's POM
(`maven-dependency-plugin` 3.7.0, Maven 3.9.16's own binding, from the seed) and nothing else. **Nothing was downloaded** by a receipt:
it said `offline: yes` with 0 `Downloaded from` lines, and the runs' `HOME` named only dead proxies. A clone whose `.m2-demo` is
empty runs it once more without `-o`, and the `offline: no - …` line names the missing artifact and the repositories that answered
(`mbuild`, the entity-states lesson's, the label read off the log). After the run the script asserts the class path is exactly the
POM's three dependencies at the POM's versions (read from the copy of the POM, never typed) plus the one they bring —
`h2-2.5.250.jar HikariCP-7.1.0.jar slf4j-api-2.0.17.jar slf4j-simple-2.0.17.jar` — every jar under `.m2-demo`. **At run time**
nothing is sent anywhere: no capture binds a port or opens a socket, and the one database is H2 in the JVM's own memory, gone with
it. No network was used by this unit except the final `git push`.

## The demo token

None. No TiffinBox server starts in this unit, so no config tree and no shutdown token exist here; the entity-states lesson's token
checks have nothing to count.

## The locale

The one java line carries `-Duser.language=en -Duser.country=US`; a last check refuses a capture's java line without it. **The
harness prints ASCII** (` | ` between facts): a JVM started under this script's `LC_ALL=C` writes its standard output in ASCII.

## The folders, the harness and the ports

- `anchor` — the link to `../c7-unit03/after` (= `../c7-tiffinbox`), read only. `../c2-unit38` — Course 2's lesson, read only.
  `.harness/c2` — its `pom.xml` and `src/main/java` (six sources), copied and `cmp`-checked; `cp.txt` is written there by the
  class-path line. `.harness/classes` — Course 2's classes and the harness, compiled. **`.harness/run` — the identity JVM's working
  directory**, emptied before each run and asserted empty after it.
- **The harness** — `harness/C7Identity.java`, **in the default package** (Course 2's classes have none, so a packaged harness could
  not see them). It **never names `Db`** (a check refuses the word outside comments): Course 2's `Db` opens `./data/tiffinbox` — a file
  database in whatever folder the JVM runs in — in its static initialiser, at the first touch. Instead it seeds its own table through
  `DriverManager` with **Db.reset's `CREATE TABLE customers` and its `INSERT INTO customers` rows, text for text** (8 and 5 lines; the
  script compares both blocks with `Db.java`'s), and builds its pool with **a `pool()` that is `Db.pool()`, line for line** (nine lines,
  compared whole: `setJdbcUrl(URL)`, `setUsername(USER)`, `setPassword(PASS)`, `setMaximumPoolSize(5)`, `setPoolName("tiffinbox-pool")`),
  with its own `USER` and `PASS` equal to `Db`'s (`"sa"`, `""`) and only its `URL` this run's: `jdbc:h2:mem:c7identity;DB_CLOSE_DELAY=-1;
  TRACE_LEVEL_SYSTEM_OUT=3` — H2 in memory, H2's trace to standard output at level 3, the setting BLUE's re-measurement used. Then
  `findById(1)` twice on Course 2's `JdbcCustomerRepository`, each find bracketed by `C7 … begin` / `C7 … end` lines, and `C7 same
  object: … | equal records: …`.
- `harness/dur7.py` is Course 7's builders' duration pattern, byte for byte (md5 `41667fed9ffcefe171389eed7e654e66` asserted; `cmp`
  against `../../../data-jpa-hibernate/_builders/dur7.py` when that file is beside the clone).
- **Ports** (§P, 19800-19809): **none bound** — the identity run is a plain JVM, no server. All ten are checked free (`lsof`) first and
  last, 19809 among them.

## Masks, filters and hygiene — every one, declared

1. **`mask()`** (`gsub()`, literals escaped; checked first on a planted line): this folder → `…`, the folder above → `…/..`, home →
   `~`, the user name → `<user>`; ` using Java <version>` (R.151; none appears); **H2's object numbers → `conn<n>`, `prep<n>`** (H2
   numbers every connection and statement it traces; the numbers are machine data, the *distinct* count is read before the mask and
   printed); an identity hash → `@…` (none appears: the harness prints `==`'s answer, not the objects' hashes).
2. **The identity JVM's log** (`hv`): in order, the harness's `C7` lines, Hikari's lines from the main thread (logger and level
   dropped), and — between the first find's `begin` and the second find's `end` — H2's trace of each `prepareStatement` and each
   `SELECT … FROM customers WHERE id = ?`. H2's timestamps, its query plans, its other traced calls and the pool's background work are
   never printed, and H2's statement time ` t:N` (a time, printed only when a statement takes long enough to register) is removed from the
   SELECT lines — no duration is captured. Then the lines the script reads from the raw log: per find, the `prepareStatement` and `SELECT` lines counted; the
   connection each `prepareStatement` was made on, and how many distinct; the database files after the run.
3. **The Maven run**: its `offline` label, exit code and `Downloaded from` count, on the terminal (not in a capture).
4. **Hygiene, checked last over every capture**: no absolute path; no unit number **but Course 2's folder name, `c2-unit38`** (the
   lesson opens that file by its path); no process line, no time; no JDK/OS version token; no unmasked H2 object number or identity
   hash; no H2 statement time `t:N`; no stack frame or uncaught exception; no `$` line with a URL; every java line pinned; **no bare `grep` on a `$` line** (every
   count is `/usr/bin/grep`'s); no `pkill`/`killall`; no bare `wait`; no variable holding several options in one string (R.193); the
   harness in the default package, naming no `Db`; **no `*.mv.db`, `*.trace.db` or `data/` anywhere in this folder — `.harness/`
   included — or in the repository's root** (R.195); `../c2-unit38` without a `target/` or a `data/`. No duration is captured.
   **`duration words: 0`** — dur7's `DUR` over this README and the exercise's two files, before anything runs: a match stops the run
   (R.172; Section 1 states no duration; `check_unit7.py`'s own gate for section 1 is the tooling session's).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the Maven it
waits for (`$mpid`, with every process under it — `killtree`), the exercise's shell (`$xpid`, with every process under it), sweeps its
own process group for a `C7Identity` JVM or a Maven left, deletes the capture runs it had not finished (`.r-NAME.1-3`), and removes
`.r-lock`. The published captures are untouched. No `wait` in the script is bare.

**Measured (2026-11-03):** `./receipts.sh` (/bin/bash 3.2) started in a session of its own **with SIGINT at its default**
(`signal.signal(SIGINT, SIG_DFL)` before `setsid`/`exec` — a background job of a non-interactive shell would inherit it ignored),
`kill -INT` to that group once the named process (or file) was there, the state read 5 s later — four trials, each **exit 130,
nothing left**:

```
maven: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · C7Identity/maven of the run anywhere: 0 · ports listening 19300-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
jvm: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · C7Identity/maven of the run anywhere: 0 · ports listening 19300-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
count: processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · C7Identity/maven of the run anywhere: 0 · ports listening 19300-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
exercise: processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · C7Identity/maven of the run anywhere: 0 · ports listening 19300-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
```

`maven` — the class-path run (Maven's launcher in the group); `jvm` — the identity JVM (`C7Identity` in the group); `count` — the
script alone, its first `count` run being written (`.r-count.1`); `exercise` — the exercise capture, its `env -i` shell started
(`.harness/ex-shell.out`). An earlier `exercise` trial, interrupted too late, instead found a drift in `identity` — the first finding
below.

## 1 · file — Course 2's class, read off disk, and the anchor's beside it (C7-2, R.162, R.169)

The lesson by its title, read from the first line of Course 2's README: **"TiffinBox on a Real Database: The JDBC Repository"**. Its
class, `../c2-unit38/src/main/java/JdbcCustomerRepository.java`: **`wc -l` 114**, md5 **`17b9ab390ffe7187231d34e35cf7a869`**, 0
`package` lines (the default package), `12:public final class JdbcCustomerRepository implements Repository<Customer, Long> {`,
`14:    private final DataSource ds;                       // a pool, not a Connection`. Its URL, off `Db.java` (which builds that
pool): **`17:    public static final String URL  = "jdbc:h2:./data/tiffinbox";`** — **a file**: H2 opens `./data/tiffinbox.mv.db`,
relative to the working directory. **Beside it, the anchor's own class** — in the tree this course starts from: `anchor/tiffinbox-core/
src/main/java/com/tiffinbox/CustomerRepository.java`, `wc -l` 80, `1:package com.tiffinbox;`, **`11:@Component`**, `12:public final
class CustomerRepository {`; its URL off `application.yaml`: **`3:  jdbc-url: jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1`** — **in
memory**, opened by `Database` through `DriverManager`. The anchor holds **0** files naming `JdbcCustomerRepository`. So: this course
*starts from* TiffinBox's tree (the anchor) and *opens on* Course 2's class (R.169) — two classes, two databases, never one for the
other. **R.162's check** reads both labelled lines the script computes — the class labelled Course 2's must sit in Course 2's folder,
have no package, no `@Component`, the class name `JdbcCustomerRepository` and a file URL; the anchor's must sit in the anchor, in
`com.tiffinbox`, with one `@Component`, the name `CustomerRepository` and an in-memory URL — and fails if the anchor's class is ever
labelled Course 2's (planted, below).

## 2 · count — ten named patterns, one command each (⚑9, R.187)

The list — the brief's ten patterns, in its order, each with its kind; `receipts.sh` holds it (`PATTERNS`), runs each entry as the
command below, prints its matched text with `grep -noE`, and asserts that text at those lines, not the count alone:

```bash
/usr/bin/grep -oE '(SELECT|MERGE INTO|DELETE FROM) ' ../c2-unit38/src/main/java/JdbcCustomerRepository.java | wc -l
/usr/bin/grep -oE 'rs\.get[A-Z]' ../c2-unit38/src/main/java/JdbcCustomerRepository.java | wc -l
/usr/bin/grep -oE 'ps\.set[A-Z]' ../c2-unit38/src/main/java/JdbcCustomerRepository.java | wc -l
/usr/bin/grep -oE 'MealType\.valueOf|mealType\(\)\.name\(\)' ../c2-unit38/src/main/java/JdbcCustomerRepository.java | wc -l
/usr/bin/grep -oE 'catch \(SQLException e\)' ../c2-unit38/src/main/java/JdbcCustomerRepository.java | wc -l
/usr/bin/grep -oE 'throw new IllegalStateException\("' ../c2-unit38/src/main/java/JdbcCustomerRepository.java | wc -l
/usr/bin/grep -oE 'ds\.getConnection\(\)' ../c2-unit38/src/main/java/JdbcCustomerRepository.java | wc -l
/usr/bin/grep -oE 'setAutoCommit|commit\(\)|rollback\(' ../c2-unit38/src/main/java/JdbcCustomerRepository.java | wc -l
/usr/bin/grep -oE 'KEY \(id\)' ../c2-unit38/src/main/java/JdbcCustomerRepository.java | wc -l
/usr/bin/grep -oE 'getGeneratedKeys' ../c2-unit38/src/main/java/JdbcCustomerRepository.java | wc -l
```

| # | kind | count | matched at (grep -noE) |
|---|---|---|---|
| 1 | K1 SQL as strings | **6** | 22 `SELECT `, 36 `SELECT `, 50 `MERGE INTO `, 69 `DELETE FROM `, 80 `SELECT `, 96 `SELECT ` (five literals and one text block) |
| 2 | K2 mapping by hand | **7** | 87, 102, 111 ×3, 112 ×2 — **seven reads in four lines**: `grep -c` gives 4 (it counts lines), `-o \| wc -l` 7 (one per match) |
| 3 | K2 | **9** | 39, 53, 54, 55, 56, 57, 70, 84, 99 (five of them in `save`, 53-57) |
| 4 | K2 | **2** | 56 `mealType().name()` (the enum written as a string), 112 `MealType.valueOf` (read back) |
| 5 | K3 `SQLException` by hand | **6** | 29, 43, 61, 72, 89, 105 — one catch per method |
| 6 | K3 | **7** | 30, 44, 59, 62, 73, 90, 106 — six translations and `save wrote … rows` (59) |
| 7 | K4 no unit of work | **6** | 23, 37, 51, 68, 82, 97 — one borrow per method |
| 8 | K4 | **0** | — no `setAutoCommit`, no `commit()`, no `rollback(`: every statement commits on its own |
| 9 | K6 the id and the dialect | **1** | 50 `KEY (id)` — H2's `MERGE INTO … KEY (id)`; the caller supplies the id (`ps.setLong(1, c0.id())`, 53) |
| 10 | K6 | **0** | — `getGeneratedKeys` never appears: the database makes no id here |
| — | **K5 no identity** | run, not grepped | the `identity` capture (§3) |

The capture ends with the list counted by the script: **`the list: counts 10 · kinds 6 (K1 K2 K3 K4 K5 K6)`** — counts = the
entries of `PATTERNS`, kinds = their distinct tags plus K5 (R.187, R.196: a count of counts is the builder's count of a named list,
never typed). The title's number is `kinds`. A check refuses any other line, so a ninth or an eleventh entry fails it (planted, below).
This README carries the same ten commands, word for word — a check reads them here, one for one. Every count is `/usr/bin/grep`
(BSD grep 2.6.0): in the Bash tool's zsh, and in many interactive zsh setups, `grep` is an alias for ugrep, which rejects `\(`.

## 3 · identity — Course 2's repository, run as Course 2 ran it (R.195; RE-MEASURE 8)

First what the script reads from the two files: `CREATE TABLE customers: 8 lines in Db.java · the harness's the same: yes`, `INSERT
INTO customers: 5 lines · the harness's the same: yes`; `Db.pool()` printed whole (nine lines) and `the harness's pool(): the same 9
lines: yes · USER "sa" = Db's "sa" · PASS "" = Db's "" · URL - Db's "jdbc:h2:./data/tiffinbox", the harness's
"jdbc:h2:mem:c7identity;DB_CLOSE_DELAY=-1;TRACE_LEVEL_SYSTEM_OUT=3"`; `lines of the harness that name Db (comments aside): 0`. Then the
run line from `.harness/run`, a fresh JVM each of the three runs: `exit 0`; Hikari's `tiffinbox-pool - Starting...`, **`Added
connection conn<n>: url=jdbc:h2:mem:c7identity user=SA`**, `Start completed.`; the first find — H2's trace **`/**/PreparedStatement
prep<n> = conn<n>.prepareStatement("SELECT id, name, email, meal_type, active FROM customers WHERE id = ?");`** and **`/*SQL l:69
#:1*/SELECT id, name, email, meal_type, active FROM customers WHERE id = ? {1: CAST(1 AS BIGINT)};`**, then `Customer[id=1, name=Meera,
email=meera@tiffinbox.test, mealType=VEG, active=true]`; the second find — the same two trace lines, the same record; **`C7 same
object: false | equal records: true`**; the pool's shutdown. Read from the raw trace: **`the first find - prepareStatement 1 · SELECT
1 | the second find - prepareStatement 1 · SELECT 1`** and **`the connections the two prepareStatements were made on: conn<n> conn<n> -
distinct: 1`** — one connection, borrowed from the pool twice (each `findById` calls `ds.getConnection()` and closes it, which hands it
back). So: two `prepareStatement`s, two SELECTs, one connection, two objects whose records are equal — `equals` true, `==` false. Not
"two different customers": the same row, read twice, built twice. This class has no place to keep an object it already loaded.

**Database files after the run (R.195)**: `in .harness/run/, the JVM's working directory: 0 entries`; the brief's `find . -name
'*.mv.db' -not -path './.harness/*'`: `0 lines`; `this folder, .harness/ included (*.mv.db, *.trace.db, data/): 0 · the repository's
root (../data, ../*.mv.db, ../*.trace.db): 0`. These are the first checks after the capture.

## 4 · exercise — run as written, in one shell, bash then zsh (R.164, R.196)

`exercise/README.md`'s three lines, then `exercise/SOLUTION.md`'s (the README's with its first line changed: the pattern `P`), each
block sourced in one `env -i` shell (`HOME`, the `PATH` the script was started with), started in this folder — `/bin/bash --noprofile
--norc`, then `/bin/zsh -f`. In both shells: the README → `exit 0`, **`54:.name()`, `56:.name()`, `112:MealType.valueOf`, `3`** (line 54
is `ps.setString(2, c0.name())`: the customer's `name()` getter); the solution → `exit 0`, **`56:mealType().name()`,
`112:MealType.valueOf`, `2`**; the shell back in this folder after each block; bash's and zsh's output the same. The check reads the
matched text at the matched lines and then the count — for each block, the whole sequence — so a pattern that gives 2 with the wrong
text fails it; and the solution's pattern must be the list's fourth entry. Broken 3 ≠ solved 2 (R.196); each from its own shell run.

## Exercise

**Your turn:** the README counts enum conversions with a pattern that also catches a getter. Fix the pattern until it counts two.
(22 words by `wc -w`, "Your turn:" included.) `exercise/README.md` ships it broken (`P='MealType\.valueOf|\.name\(\)'` → **3**,
`54:.name()` among them), `exercise/SOLUTION.md` beside it (`P='MealType\.valueOf|mealType\(\)\.name\(\)'` → **2**, exactly
`56:mealType().name()` and `112:MealType.valueOf`); both measured by the `exercise` capture, in bash and in zsh.

## The ledger rows and hand-offs this unit pays

- **C7-2 — paid**: Course 2's `JdbcCustomerRepository` on screen — its file, its 114 lines, its md5, its URL off `Db.java:17` (a file),
  its lesson by title — with the anchor's `@Component CustomerRepository` and its in-memory URL beside it, each read off disk, R.162's
  check on both (§1); the run of the class itself (§3).
- **C7-1 — not paid here** (no fact of this unit calls back Course 6's restart; it stays the capstone's).
- No other row.

## RE-MEASURE — the brief's items this unit settles

| # | Settled here |
|---|---|
| 8 | 01's identity run in `c7-unit01`'s harness, from `.harness/run/`, on `Db.pool()`'s nine lines (only the URL in memory): `findById(1)` twice → prepareStatement 1 · SELECT 1 per find, **one connection (distinct 1)**, `same object: false · equal records: true`, exit 0, 3/3 ×3 runs of record; H2's `connN`/`prepN` masked, the distinct count asserted; no database file anywhere after it. Plants: the unpooled `JdbcDataSource` → distinct 2; a `Db.reset(c)` call → `data/tiffinbox.mv.db` under `.harness/run/` (below) |
| 10 | the exercise as viewers run it: `env -i`, `/bin/bash --noprofile --norc` and `/bin/zsh -f`, README then SOLUTION in one shell: 3 (`54:.name()` among them) → 2 (`56:mealType().name()`, `112:MealType.valueOf`). No JVM in this exercise, so "Java 23 refused" has nothing to refuse |
| 18 | the ten counts with `/usr/bin/grep` in bash: 6/7/9/2/6/7/6/0/1/0 — BLUE §4's, each with its matched text at its lines; `rs.get` 7 occurrences in 4 lines; `counts 10 · kinds 6`; the 9th/11th-entry plants fail it |

## What differed from the brief

1. **The R.195 check is wider than the brief's command, because the brief's cannot fail on its own plant.** The brief: "after the run
   the receipt asserts `find . -name '*.mv.db' -not -path './.harness/*'` → 0 lines". But the harness runs *in* `.harness/run/`, so a
   `Db` call writes `.harness/run/data/tiffinbox.mv.db` — inside `.harness/`, where that `find` does not look: on the planted
   `Db.reset(c)` it printed **0 lines** (measured, below). The capture prints the brief's line and three more, and the checks read all
   of them, first after the capture: **`.harness/run/` (the JVM's working directory) has 0 entries** (emptied before each run); **0
   `*.mv.db`, `*.trace.db` or `data/` anywhere in this folder, `.harness/` included** (`.m2-demo` aside); **0 in the repository's root**
   (`../data`, `../*.mv.db`, `../*.trace.db`). The plant fails the first (`1 entries`) and the second (`2`: the folder and the file).
   The same "no database file anywhere" check runs again last, beside the hygiene checks, and once before anything runs.
2. **The harness prints `same object: false | equal records: true`** — ` | ` where the brief wrote ` · `: the JVM runs under the
   script's `LC_ALL=C` and writes ASCII (the entity-states lesson's harness made the same choice).
3. **The class path is resolved by Course 2's own README line, offline, on a copy of Course 2's POM** — `mvn -q
   dependency:build-classpath -Dmdep.outputFile=cp.txt` with `-q` made `-o -B -Dmaven.repo.local="$M2"` (asserted as a derivation),
   run in `.harness/c2` through the entity-states lesson's `mbuild` (its `offline:` label read off the log); then `javac` compiles the
   six copied sources and the harness. Maven ran once per receipt; `offline: yes` in every run of record. The versions on the class
   path are read from the POM's copy, never typed.
4. **H2's object numbers are masked as `conn<n>` and `prep<n>`** (the brief named `connN`; the statements' numbers are machine data
   too), and **H2's statement time `t:N` is removed** from the SELECT lines (found on the way). The distinct connection count is read
   from the raw trace before the mask.
5. **The physical connections H2 saw opened are not captured.** Hikari fills the pool to its `minimumIdle` (= `maximumPoolSize`, 5)
   from a background thread, so how many opened before the JVM ends depends on the machine (BLUE: 1 at once, 5 after 2,000 of its
   waits — "Found on the way"); the fact the lesson needs — both `prepareStatement`s on the same connection — does not, and that is the
   one asserted (`distinct: 1`), 3/3 under load too.
6. **The harness seeds all four of `Db.reset`'s customers, text for text** (the `INSERT INTO customers` block whole, 5 lines, and the
   `CREATE TABLE customers` block, 8 lines), so the comparison with `Db.java` is two whole blocks, not a hand-picked row; only the
   `customers` table (the class reads no other).
7. **The anchor's URL is read off `application.yaml:3`** (`tiffinbox.jdbc-url`), with `Database` named as the class that opens it:
   the anchor's `CustomerRepository` names no URL itself — it asks `Database`, which uses `DriverManager` on that setting.
8. **The `file` capture names Course 2's folder, `c2-unit38`, in its paths** (the brief's beat opens that file by its path): the
   hygiene check that refuses unit numbers allows exactly that folder name, and refuses any other.
9. **The count commands carry `| wc -l` exactly as R.187 names them**, so they print the count as macOS's `wc` does, padded with
   spaces; the checks trim it. `rs.get`'s `grep -cE` is printed beside its count, with a computed line: `occurrences 7 (grep -o, one per
   match) · lines 4 (grep -c counts lines, not matches)`.
10. **The exercise keeps the pattern in a variable, `P`, on the block's first line**, so `SOLUTION.md` is the README's block with one
   line changed (the entity-states lesson's rule); the blocks export no `JAVA_HOME` — they start no JVM, so R.93's exports (and
   RE-MEASURE 10's "Java 23 refused") have nothing to guard. The spoken line is **22 words by `wc -w`**, "Your turn:" included (the brief
   said 21); the check is "25 or fewer", as the entity-states lesson's.
11. **No demo token, no config tree, no Boot JVM**, so the entity-states lesson's token and `secrets/` checks are not carried; its
   locale, kill-by-pid, bare-`wait`, options-array and path checks are.
12. **The plants ran on a copy of the sealed clone**, refreshed from the working tree before each, `receipts.md5` emptied so the run
   reaches the checks (except for the hash and duration plants).

## Planted faults — each caught (R.65)

On a copy of the sealed clone (refreshed from this folder before each plant; `receipts.md5` emptied so the run reaches the checks,
except for the hash and duration plants), `./receipts.sh`, `env -i`, a session of its own — each **exit 1** at the check named:
- **The enum pattern back to `\.name\(\)`** (the list's fourth entry `MealType\.valueOf|\.name\(\)`) → died `*** count: pattern 4
  (MealType\.valueOf|\.name\(\)) - grep -oE | wc -l printed 3, expected 2 ***` (4 s).
- **RED #21's `valueOf|mealType\(\)` as the solution's `P`** → the solution printed `56:mealType()`, `112:valueOf`, `2` — the count right,
  the text wrong — died `*** exercise: the solution - exactly 56:mealType().name() and 112:MealType.valueOf, and 2 (the text at the
  lines, not the count alone) ***` (9 s).
- **An eleventh entry** (`'COLS'`, a K6 tag) → `the list: counts 11 · kinds 6 (…)` — died `*** count: the list - counts 10 · kinds 6:
  expected the line: the list: counts 10 · kinds 6 (K1 K2 K3 K4 K5 K6) ***` (4 s). **A ninth** (`getGeneratedKeys` removed) →
  `counts 9 · kinds 6` — the same check (3 s).
- **The unpooled `JdbcDataSource`** (the probe's: `org.h2.jdbcx.JdbcDataSource` with the same URL, user and password handed to the
  repository in place of the pool) → `the connections the two prepareStatements were made on: conn<n> conn<n> - distinct: 2` — died
  `*** identity: one connection, borrowed twice (an unpooled source makes two): expected the line: … - distinct: 1 ***` (7 s).
- **A `Db.reset(c)` call** in the harness's seed (after its INSERT) → `Db` initialised, its pool opened `./data/tiffinbox` in the JVM's
  working directory: **`.harness/run/data/tiffinbox.mv.db`, 16,384 bytes**; the capture: `in .harness/run/, the JVM's working
  directory: 1 entries`, **the brief's `find … -not -path './.harness/*'`: 0 lines**, `this folder, .harness/ included …: 2` — died
  `*** identity: R.195 - the run wrote nothing into .harness/run/ (a call into Course 2's Db writes data/tiffinbox.mv.db there):
  expected the line: in .harness/run/, the JVM's working directory: 0 entries ***` (6 s). (The file stayed in the plant's copy, in
  the scratch folder; nothing outside it.)
- **The anchor's class named as Course 2's** (`C2F` set to `anchor/…/CustomerRepository.java`) → `R.162: the class labelled Course 2's
  - NOT in Course 2's folder · package lines 1 · @Component lines 1 · class CustomerRepository …` — died `*** file: R.162 - the class
  labelled Course 2's must be c2-unit38's JdbcCustomerRepository (no package, no @Component, a file database), never the anchor's: … ***`
  (3 s).
- **H2's statement time left in the trace** (`hv`'s removal replaced by an insertion of ` t:1` before `*/SELECT`, so all three runs
  agree) → died `*** identity: the SELECT, with its bind: expected the line: H2 trace: /*SQL l:69 #:1*/SELECT … ***` (6 s); the
  hygiene check that refuses `t:N` in any capture stands behind it.
- **A wrong published hash** (`receipts.md5`'s `file` with its last digit changed) → `file … 3/3  DIFFERS from the published …b8`,
  `*** file is not the published capture … ***` (3 s).
- **A duration word planted in this README** (dur7's word for the unit `sec`+`onds`, in the first paragraph) → died before anything
  ran, `*** dur7.DUR found duration words (Section 1 states none, R.172): README.md line 6: … (the planted word);duration words: 1 ***` (1 s).

## Found on the way

- **H2's trace prints a statement's time once it is long enough to register**: `/*SQL l:69 #:1 t:1*/SELECT …`. A SIGINT trial that
  polled the process table without pause loaded the machine enough for one of three `identity` runs to print `t:1`, and the
  capture drifted (`*** identity drifts across three runs ***`, exit 1 — `cap()` doing its job). `hv` now removes ` t:N` from the
  SELECT lines and a hygiene check refuses it; with twelve busy loops beside two full runs the raw trace held `t:20` and every capture
  stayed = published.
- **The brief's own `find` could not see the `Db` plant**: with the JVM in `.harness/run/`, `-not -path './.harness/*'` excludes exactly
  where the file lands (What differed, 1).
- **Hikari fills Course 2's pool in the background** (`minimumIdle` defaults to `maximumPoolSize`), so the number of physical
  connections in the trace is timing; the connection a second `getConnection()` returns on the same thread is the one the first
  handed back (Hikari's bag keeps a per-thread list) — `distinct: 1` in every run, loaded or not.
- **Course 2's POM still names its artifact `c2-unit31`** (copied forward from an earlier Course 2 unit; harmless — the POM resolves the
  same class path). Not changed: Course 2's folder is read only.
- **`maven-dependency-plugin` 3.7.0** is Maven 3.9.16's own binding for `dependency:`; it is in the seed (the empty-repository trial's
  first missing artifact).
- **bash 3.2 misreads `$(cat <<'X' … X)` when the here-document holds a quote or a parenthesis** (`syntax error near unexpected token
  ';;'`, reported far below the cause); bash 5.3 parses it. The list is read with `read -r -d ''` instead.
- **A trailing space at the end of a line does not survive every editor**: the first pattern ends in one (`'(SELECT|MERGE INTO|DELETE
  FROM) '`), so the list holds each pattern in single quotes.
- **`grep -c` and `grep -o | wc -l` differ exactly where the lesson says**: `rs\.get[A-Z]` is 4 lines, 7 matches (111 holds three, 112
  two).

## CARRIED

- `check_unit7.py`'s `DUR_SECTIONS` gaining section 1 → the tooling session; this unit's own gate stands meanwhile.
- The first-entity and persistence-context lessons' `mbuild` label (`offline: no - … Maven Central was asked` on their sealed clones)
  → RED's fix of those two receipts (FACTORY-NEXT, 2026-11-01 11:30); this unit carries the entity-states lesson's `mbuild`, not edited
  there.
- The persistence context that hands back the same object *inside one transaction* → *The Persistence Context* (this unit shows only
  that Course 2's class has no place to keep one; it says nothing about JPA's answer).

## For RED

Re-run from a clean tree (seeded `.m2-demo`, `HOME` with dead proxies) in a process group of its own; the plants above; ports
20240-20259 for any re-run of this unit outside its script (none is needed: it binds none). Evidence by a Claude Opus 5.5 agent on 2026-11-03.
