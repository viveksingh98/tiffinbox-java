# c7-unit05 — Entity States

Course 7 · Data with JPA & Hibernate · Section 1 (ORM from First Principles), its fifth unit · Verified on **JDK 25.0.4.1, Apache
Maven 3.9.16, Spring Boot 4.1.2** (Spring Framework 7.0.10, Hibernate ORM 7.4.13.Final, Spring Data JPA 4.1.2, Jakarta Persistence
3.2.0, HikariCP 7.0.2, H2 2.5.250 — the anchor's own pin), 2026-11-01. **H2, in memory, every capture**: no Postgres, no container, no
native build. An entity is always in one of four states, and you can tell which by one thing: the SQL that runs, or does not, when
the transaction ends. **Transient** — a new object Hibernate has never seen: no id, nothing tracks it. **Managed** — an object the
persistence context tracks: its changes are written at the commit. **Detached** — an object it tracked once and no longer does (its
transaction ended, or `detach` let it go): a change to it reaches no table. **Removed** — an object `remove` was called on: its
DELETE runs at the commit. **`merge`** — the way back from detached: Hibernate loads the row again and copies the detached object's
state onto the managed copy, which it returns. Each claim here is measured on the EntityManager Spring injects, inside a
`TransactionTemplate` (R.183), and every count has two witnesses — the SQL log's lines and Hibernate's `Statistics` (R.184).

**No anchor change.** `anchor` is the link to `../c7-unit03/after` — the tree the first-entity lesson froze — and the script dies unless
`diff -rq -x .m2-demo -x target -x secrets anchor/ ../c7-tiffinbox` is empty, at its start and again at its end: it was, in every run of
record. The anchor is copied under `.harness/anchor` and built there, never in place. No file of `c7-tiffinbox/` changed.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 9 captures, 3 runs each; every spoken number asserted after its capture; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the `JAVA_HOME` export on its first line after the shebang and dies unless `java -version` and `javac -version`
say 25; a bare `java` on this Mac is 23.0.1.) It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line
first). **Start it in a process group of its own** (a terminal's foreground job is one): `sweep()` stops only processes of its own group.
`.m2-demo` must be seeded first (below) — or the first build runs once more without `-o`, and its `offline:` line names the artifact
it missed and the repositories that answered.

**Runs (2026-11-01), each `env -i`** (`HOME` = a home of its own whose `.mavenrc` sets `-Duser.home` there and whose `settings.xml`
names only two dead proxies, `127.0.0.1:9` — so no Maven run could reach the network; `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:
/sbin`; `http(s)_proxy` dead too), a session of its own, `.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s1/`
alone (6,608 files). Five development runs fixed the captures and the checks (the fifth made every capture 3/3 and stopped at "no published hash"
with every check passed; its md5s are `receipts.md5`); one pair of runs passed on an earlier script, then the empty-repository trial
(below) showed `mbuild`'s missing-artifact name printing on two lines, a one-place fix, and the runs of record again. **The runs of record, on the script as committed (`receipts.sh` md5 `8388b0c39f3880c4ff1dac9cc610ae2c`): 204 s under `./receipts.sh`** (/bin/bash
3.2.57) **and 218 s under `bash receipts.sh`** (Homebrew bash 5.3.9): each exit 0, all 9 captures 3/3 = published, every check
passed, the build `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`; each terminal log through `check_unit7.py 05
--runlog` — `0 grep error line(s)`, `RESULT (run logs): PASS` (the unit gate itself answers "no 05-*.md … nothing to check": no
script yet). **Nothing was downloaded** for this unit.

Published hashes: transient `37677508547b8c0ee090663bef4ef179` · managed `f065b500566f4d05ed0aebaea0a0a872` · detached `92597e8c32640b5f0373ba7b42cec16f` · merge `927e8c35b9e0b7c65b45df50c265b38e` · persistdetached `7aea3b652b381d16c8af360c6355761a` · removed `5d614afed4c7a611f3053d6fe66865b2` · states `e1fabcf0f065ed27e57eceb0ee5a1e0f` · tests `92ec7e1851904415fe1bcb60200fa4a0` · exercise `6ea17142e278ff549eb9ee9a86f09aee`.

### A sealed fresh clone — the recipe (R.129)

**Paste it into bash** (type `bash` first if your Terminal is zsh: zsh does not split the unquoted `$E`).

**Run (2026-11-01):** a `git clone` of tiffinbox-java at `f805104` into a path **with a space** (`…/sealed 05 seeded/tiffinbox-java`),
with `c7-unit05/` and `.gitignore` put in as git would take them (`git ls-files -co --exclude-standard`: 13 files, each
`cmp`-equal to the working tree; `anchor` → `../c7-unit03/after` by `readlink`); a `file://` copy of the seed (4,967 files:
`_remote.repositories`, `*.lastUpdated` and `resolver-status.properties` left out); pre-flight: exit 1, 221 `Downloading from
sealed: file://`, 0 from http(s); the clone's `.m2-demo` **seeded from that copy** (4,967 files — as a viewer seeds it, "The
repository" below); `/bin/bash` 3.2, `env -i`, a session of its own: **exit 0 in 195 s, all 9 = published, every check
passed**; the build said **`offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`**; after the run the clone's `.m2-demo`
still held 4,967 files (0 gained, 0 `_remote.repositories`). Its terminal log through `--runlog`:
PASS. (The builders' `dur7.py` is not beside a clone: its md5 is the check.)

```bash
S=/tmp/sealed05; W="/tmp/sealed 05"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
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
cd "$W/tiffinbox-java/c7-unit05" && readlink anchor && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E ./receipts.sh            # a process group of its own
```

(The clone's own `c7-unit05/` is the committed one once this unit is in git; before its commit it was put in as above.)

**The `offline:` label, settled (the question RED was handed from the persistence-context lesson's sealed run).** That run printed
`offline: no - the offline build could not resolve an artifact, so Maven Central was asked` while its `.m2-demo` filled with 691
artifacts, every one `>sealed=`, 0 `central`. Read off `../c7-unit04/receipts.sh` (`mbuild`, not edited here) and its recipe: **the
recipe ran the clone with an empty `.m2-demo`** (git ignores it), so the `-o` build had nothing to resolve from and failed; `mbuild`
then re-ran the line without `-o` and printed a fixed sentence. That sentence named Maven Central, but in the clone the only
repository Maven could reach was the settings' mirror `sealed` (`mirrorOf *`, a `file://` copy of the seed) — **no artifact outside
the seed, no `-o` missing on any build: a correct fallback with a wrong label**. The first-entity lesson's sealed run did the same for
all three of its builds (its log, `rec-sealed.log` in that agent's scratch: three `offline: no - … Maven Central was asked`, 859
`>sealed=`, 0 `central`); its `offline: yes` was the `tests` capture's line, which counts the tests build's own `Downloading` lines
after the first build had filled `.m2-demo`. **This unit:** the recipe seeds the clone's `.m2-demo` from the `file://` copy before the
run, so the build is offline and says `offline: yes` with 0 `Downloaded from` lines; and `mbuild`'s fallback label is now read off the
log — the artifact the offline build named, every repository the retry downloaded from by id and URL scheme with its count, and the
count over http(s) — so it can never name a repository the log does not. **Measured on a second clone with an empty `.m2-demo`**
(`…/sealed 05 empty/tiffinbox-java`, the same recipe without the seeding line; stopped by SIGINT once the build line had printed):
`built .harness/anchor (the anchor, the README's package line; its tests ran) · offline: no - the offline build could not resolve
org.springframework.boot:spring-boot-starter-parent:pom:4.1.2 from .m2-demo, so it ran once more without -o; that run downloaded from:
sealed (file) 691; of them over http(s): 0 · exit 0 · 'Downloaded from' lines in its log: 691` — and its `_remote.repositories`: 691
`>sealed=`, 0 `central`; the offline attempt's log (kept beside, `build-anchor-offline.log`) names it: `Cannot access sealed
(file://…) in offline mode and the artifact org.springframework.boot:spring-boot-starter-parent:pom:4.1.2 has not been downloaded from
it before`. Then SIGINT: exit 130, nothing left (`empty-repo` in "Interrupted").

## The commands this unit adds

```bash
java -Duser.language=en -Duser.country=US -cp "../hc:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 "${V[@]}"
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/src/probe/jpa/Five.java harness/src/probe/jpa/Probe.java harness/src/probe/jpa/St.java harness/src/probe/jpa/Steps.java
```

`receipts.sh` reads four lines from the anchor's README (`anchor/README.md`, each asserted there whole): `mvn -B package`, `mvn -B
clean test`, the extract line and the extracted-jar run line. Each line above is asserted in this README, and **the harness line** is
asserted to be the anchor's extracted-jar line (`java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:…/lib/*"
com.tiffinbox.web.TiffinBoxServer`) with one change: the locale, `../hc:` first on the class path and `"${V[@]}"` after it — `V` is the
run's options array (R.193), printed as `$ V=(…)` before each run. Every Maven line runs offline: `-o -B -Dmaven.repo.local="$M2"`
after `mvn`, `clean` before `package`. Every java line runs from `.harness/anchor`, where a config tree holds the demo token.

## The repository, and the network

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s1/` alone (6,608 files) before the runs of record. **Nothing was downloaded** by a
receipt: every build said `offline: yes` with 0 `Downloaded from` lines, the tests' log holds 0 `Downloading from` lines, and the
runs' `HOME` named only dead proxies. A clone whose `.m2-demo` is empty runs its first build once more without `-o`, and the
`offline: no - …` line names the missing artifact and the repositories that answered (above). After the build the script asserts
`.m2-demo` holds `spring-boot-starter-parent-4.1.2.pom`, `hibernate-core-7.4.13.Final.jar`, `spring-boot-starter-data-jpa-4.1.2.jar` and
`jakarta.persistence-api-3.2.0.jar`. **At run time** nothing leaves `127.0.0.1` (no capture sends a request at all), and every
database is H2 in the JVM's own memory, gone with it. No network was used by this unit except the final `git push`.

## The demo token

`TOKEN=` near the top of `receipts.sh` (39 characters), fake and meant to look it: it guards nothing but demo servers on 127.0.0.1. It
is written into `.harness/*/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600, git-ignored) of every copy; no command of this
unit sends it (every harness JVM ends itself). Before every start the script lists that `secrets/` folder (the token's file, nothing
else — R.158), and a last check counts one listing per start. Every capture's raw output, the log of every JVM, every build log,
every Surefire report and every file this unit ships: the token 0 times.

## The locale

Every java line carries `-Duser.language=en -Duser.country=US`; a last check refuses a capture's java line without it; the test fork's
comes from the POM's `argLine`. **The harness prints ASCII** (` | ` between facts): a JVM started under this script's `LC_ALL=C`
writes its standard output in ASCII.

## The folders, the harness and the ports

- `anchor` — the link to `../c7-unit03/after` (= `../c7-tiffinbox`). `.harness/anchor` — copied, with a config tree, built with the
  README's `mvn -B package` (its 18 tests run), its jar extracted there (the anchor's own line, 91 libraries); `.harness/hc` — the
  harness, compiled; `.harness/tests` — `tests`' copy; `.harness/mine.log` — the exercise's log.
- **The harness** — the course's, never TiffinBox's (`harness/src/probe/jpa`, package `probe.jpa`, outside `com.tiffinbox`; a check
  refuses `probe.jpa` anywhere in the anchor's code). **`Probe.java` and `Steps.java` are the first-entity lesson's, byte for byte**
  (md5 `fc0c06932cd2cd8c912f304328b367b8` / `e316b9418711b0c142d3b7c7519d9215`, asserted, and `cmp` against `../c7-unit03/harness`);
  they act only on `--probe.steps`, which no run here sets (`St` borrows their `p()` and `jar()`). This unit adds two: **`Five`**
  (`@Configuration @Import({Probe, St})`, joined by `--spring.main.sources=probe.jpa.Five`) and **`St`** (an `ApplicationRunner` that
  does nothing unless the run sets **`--probe.st`**, runs the named steps in order outside any HTTP request, prints `PROBE` lines, then
  `System.exit(SpringApplication.exit(ctx))`). Its steps, each on the EntityManager Spring injects, each boundary a `TransactionTemplate`
  over the context's transaction manager: `transient`, `managed`, `setup` (Kavya persisted with 3 meals in a transaction of her own —
  the database gives her **id 5**, after the four rows `Database` seeds), `change` (find, set 2, commit), `detach` (the same with
  `em.detach(c)` after the find — **one line of `St.java`**, `if (detach) em.detach(c);`, is all that differs), `merge`,
  `persistdetached`, `mergedetached`, `removed`, and the exercise's `ex-detach`, `ex-merge`, `ex-plain` (each persists Kavya with 2
  first). Every span of database work prints `PROBE <span> begin` / `PROBE <span> end` around it and then `PROBE <span> | statements …
  | loads … | inserts … | updates … | deletes … | flushes … | transactions …` (Hibernate's `Statistics`, `hibernate.generate_statistics=true`
  in every run's `V`, cleared after each span); a line ending ` - before commit` is printed inside the transaction after its work.
  After each step **the anchor's own `CustomerRepository`** (Course 2's SQL on its own `DriverManager` connection) reads Kavya back.
  `harness/surefire.py` (the testing lesson's, `cmp`-checked) reads Surefire's reports; `harness/dur7.py` is Course 7's builders'
  duration pattern, byte for byte (md5 `41667fed9ffcefe171389eed7e654e66` asserted; `cmp` against
  `../../../data-jpa-hibernate/_builders/dur7.py` when that file is beside the clone).
- **Ports** (§P, 19840-19849): `transient` 19840 · `managed` 19841 · `detached` 19842 · `merge` 19843 · `persistdetached` 19844 ·
  `removed` 19845 · `exercise` 19846 · 19849 never bound. Every JVM is waited for by its pid before the next on its port; a harness JVM
  exits by itself (bounded, 120 s); the script asserts nothing listens on the port after each. 18425, 8080 and 35729 checked free first
  and last; `states` and `tests` bind none.

## Masks, filters and hygiene — every one, declared

1. **`mask()`** (`gsub()`, literals escaped; checked first on a planted line): the token → `[masked: the 39-character token]`; this
   folder → `…`, the folder above → `…/..`, home → `~`, the user name → `<user>`; ` using Java <version>` (R.151); H2's generated
   database name → `jdbc:h2:mem:<uuid>` (none appears here); **an identity hash → `@…`** (`merge`'s pair, Course 4 §2b — they differ
   every run).
2. **A JVM's log** (`view`): in order, the harness's `PROBE` lines and the lines of the loggers each capture names (level, logger as
   Boot printed it, message cut at 260 characters, trailing spaces dropped); after `Application run failed` the exception's first line
   and its distinct `Caused by:` lines; frames never. `wit SPAN`: the SQL logger's lines between a span's markers, counted by kind
   (select · insert · update · delete), beside the span's `Statistics` — statements, inserts, updates, deletes — and whether they agree
   (R.184). `order SPAN`: the same lines on each side of the span's ` - before commit` line (R.192, R.197). `jlog`: Hikari's `Added
   connection … url=` line (R.185), Hibernate's version line, WARN and ERROR lines counted. `hres`: the exit code and Boot's first line.
   `trio`: the exit code, the exception's type and the rest of its first line, from the line after `Application run failed`.
3. **A Maven log**: its `$` line, exit code, `BUILD` line, `offline` (its `Downloading from` lines counted); Surefire's reports
   (`surefire.py`) with the console's summary beside their sum (R.144); Hibernate's `Initialized JPA EntityManagerFactory` lines and
   `org.hibernate.SQL` lines counted; WARN and ERROR counted.
4. **Hygiene, checked last over every capture**: no absolute path, no unit number, no Boot process line, no time, no log time, no
   thread number, no proxy class number, no JDK/OS version token, no unmasked generated database name, no unmasked identity hash, no
   random port, no stack frame; every `$` line's URL 127.0.0.1's; every java line pinned; one `secrets/` listing per start; no
   `pkill`/`killall`; no bare `wait`; no variable holding several options in one string (R.193); no harness class in `com.tiffinbox`;
   **no `*.mv.db`, `*.trace.db` or `data/` anywhere in this folder outside `.harness/`** (R.195). No duration is captured. **`duration
   words: 0`** — dur7's `DUR` over this README and the exercise's two files, before the build: a match stops the run (R.172; Section 1
   states no duration; `check_unit7.py`'s own gate for section 1 is the tooling session's).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the Maven it
waits for (`$mpid`, with every process under it — Surefire's fork — `killtree`), the exercise's shell (`$xpid`, with every process under
it), sweeps its own process group for any TiffinBox JVM, Maven or Surefire fork left, deletes the capture runs it had not finished
(`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched. No `wait` in the script or the exercise is bare.

**Measured (2026-11-01):** `./receipts.sh` (/bin/bash 3.2) started in a session of its own **with SIGINT at its default**
(`signal.signal(SIGINT, SIG_DFL)` before `setsid`/`exec` — a background job of a non-interactive shell would inherit it ignored), `kill
-INT` to that group once the named process was in it, the state read 5 s later — four trials, each **exit 130, nothing left**:

```
fork: processes in the group at SIGINT 5 · exit 130 · 5 s later in the group: 0 · java/surefire/maven of the run anywhere: 0 · ports listening 19300-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
jvm: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · java/surefire/maven of the run anywhere: 0 · ports listening 19300-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
exercise: processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · java/surefire/maven of the run anywhere: 0 · ports listening 19300-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
empty-repo: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · java/surefire/maven of the run anywhere: 0 · ports listening 19300-20399: 0 · .r-lock: no · captures: none yet (a fresh clone)
```

`fork` — Surefire's `surefirebooter` (the build's tests); `jvm` — the first harness JVM (`transient`, 19840); `exercise` — the
exercise's JVM on 19846, under the `env -i` bash the capture starts (the trap stops that shell with every process under it);
`empty-repo` — the sealed clone with an empty `.m2-demo`, interrupted once the build's `offline:` line had printed (the next process,
the harness JVM, about to start).

## 1 · transient — a new object, asked inside the transaction (R.194)

The harness, Hibernate's SQL logger at DEBUG, port 19840, step `transient`: `new CustomerEntity("Kavya", 2, 110, "VEG")`, then one
`TransactionTemplate` (`in a transaction: true`) in which the EntityManager Spring injects is asked about it — **`the new Kavya: id
null | contains false | statements so far 0`** — and, as the control in the same transaction, about a customer it finds (customer 1):
**`the control, found in the same transaction: Ravi | contains true - before commit`**. The transient's own two witnesses: the SQL
logger's lines between `transient begin` and the new Kavya's line **0**, `Statistics` read on that line **0**. The whole span: 1 SELECT
(the control's) — the log's line and `statements 1`, they agree. Asked again **outside** any transaction: `the new Kavya contains false
| the control contains false` — the injected EntityManager has no persistence context there, so a found entity says `false` too: that
reading is printed, labelled "never a state's witness", and never used (R.194). The anchor's repository: `no Kavya - not in the table`.
Hikari on `jdbc:h2:mem:tiffinbox`.

## 2 · managed — the INSERT at persist, the UPDATE at the commit (R.192, R.197)

Step `managed`, Hibernate's SQL logger at DEBUG and its bind logger (`org.hibernate.orm.jdbc.bind`) at TRACE, port 19841, in the order
the log printed them: `before persist: id null`; **`insert into customer (meal_type,meals_per_day,name,price_per_meal,id) values
(?,?,?,?,default)`** with its four binds (`VEG`, `2`, `Kavya`, `110`); **`after persist(): id 5 | contains true`**; `field set to 3, no
save called, contains true - before commit`; then **`update customer set meal_type=?,meals_per_day=?,name=?,price_per_meal=? where
id=?`** with five binds (`VEG`, `3`, `Kavya`, `110`, `5` — every column, R.191); `managed end - after commit`. **The order** (R.192,
R.197): insert lines before the line `after persist()` **1**; around ` - before commit`: before it insert 1, update 0; after it,
before `managed end`, update 1. So the INSERT ran when `persist` was called (IDENTITY asks the database for the id), and the UPDATE
waited for the commit. `statements 2 | loads 0 | inserts 1 | updates 1 | deletes 0 | flushes 1 | transactions 1` — the log's 2 lines
(insert 1, update 1) and `Statistics`, they agree. The anchor's repository reads **3**.

## 3 · detached — A/B/A′: one line, `detach`, and the change never reaches the table

Port 19842, a fresh JVM each, steps `setup` (Kavya persisted with 3 meals, id 5, the anchor reads 3) then the step under test:
- **A** — `change`: find Kavya (`loaded: Kavya | mealsPerDay 3 | contains true`), set 2, commit: `contains true - before commit`, then
  the UPDATE **after** the marker (before it: select 1; after it: update 1); `statements 2 | … | updates 1 | … | flushes 1`, the log's
  2 lines agree; the anchor's repository reads **2**.
- **B** — one flip, the step `detach`: the same code with `em.detach(c)` after the find — `St.java line 156: if (detach) em.detach(c);`
  is printed in the capture, the one line that differs. `loaded: … contains true`, then **`field set to 2, no save called, contains
  false - before commit`**, then nothing: after the marker 0 SQL lines; **`statements 1 | loads 1 | inserts 0 | updates 0 | deletes 0 |
  flushes 0 | transactions 1`** (the log's 1 line, the SELECT, agrees); the anchor's repository reads **3** — the table kept the old
  value. The transaction committed; it had nothing to write, and `Statistics` counted no flush at all (`flushes 0`; A's commit counts
  one).
- **A′** — A again: identical, line for line (checked).

The flip is named by the step and the line; A's `contains true` before the commit and B's `false` are read inside the transaction.

## 4 · merge — the way back: another object, a SELECT, an UPDATE at the commit

Port 19843, steps `setup` then `merge`: `merge-load` — find Kavya in a transaction that ends (1 SELECT, `statements 1`, they agree):
the instance it returns is detached once the template commits. `field set to 2 on that instance, outside any transaction`. Then
`merge(det)` in a new `TransactionTemplate`: a SELECT (merge loads the row again), **`merge returned same object: false |
identityHashCode det @… m @… | the pair equal: false`** (the two hashes masked, Course 4 §2b — they differ every run), **`contains(det)
false | contains(m) true | m.mealsPerDay 2 - before commit`**, then the UPDATE after the marker (before it: select 1; after it: update
1); `statements 2 | loads 1 | inserts 0 | updates 1 | deletes 0 | flushes 1 | transactions 1`, the log's 2 lines agree. The anchor's
repository reads **2**. `merge` does not attach the object you pass: it returns another one, and the one you passed stays detached.

## 5 · persistdetached — the failure receipt (Course 4 §2e) and its A′

Port 19844, steps `setup` then:
- **B — the failure** (`persistdetached`): Kavya found in a transaction that ends (`persistdetached-load`: 1 SELECT, they agree; `loaded
  Kavya | id 5`), then `persist(det)` in a new `TransactionTemplate`. The harness prints what was thrown, each type with the jar it was
  loaded from — **`thrown: jakarta.persistence.EntityExistsException (in jakarta.persistence-api-3.2.0.jar)`** · **`its cause:
  org.hibernate.PersistentObjectException (in hibernate-core-7.4.13.Final.jar)`** — and throws it on: Boot ends the run, `ERROR
  o.s.boot.SpringApplication: Application run failed`, `jakarta.persistence.EntityExistsException: Detached entity passed to persist:
  com.tiffinbox.CustomerEntity`, `Caused by: org.hibernate.PersistentObjectException: Detached entity passed to persist:
  com.tiffinbox.CustomerEntity`. **The trio** (Course 4 §2e): **exit 1 · `jakarta.persistence.EntityExistsException` · `Detached entity
  passed to persist: com.tiffinbox.CustomerEntity`**. The span: **0** SQL lines, `statements 0 | … | flushes 0 | transactions 1` (the
  rolled-back one) — they agree; the anchor's repository still reads 3. Jakarta's type is the one a caller catches; Hibernate's is the
  one that found the problem — both said, by jar.
- **A′** — the same instance through `merge` in place of `persist` (`mergedetached`, unchanged): exit 0, `merge returned same object:
  false`, 1 SELECT, `updates 0` (nothing changed, nothing written), the anchor reads 3; no `Application run failed`.

## 6 · removed — `contains` false at once, the DELETE at the commit

Port 19845, steps `setup` (the anchor reads 3) then `removed`: find Kavya (`contains true`), `remove`: **`remove(c) called, contains
false - before commit`**, then **`delete from customer where id=?`** after the marker (before it: select 1, delete 0; after it: delete
1); `statements 2 | loads 1 | inserts 0 | updates 0 | deletes 1 | flushes 1 | transactions 1`, the log's 2 lines agree. The anchor's
repository: **`no Kavya - not in the table`**. `contains` turned false at `remove`, before any SQL: like a detached object's — so the
state is told by the SQL, not by `contains` alone.

## 7 · states — the table, read from the captures

Built by `states()` from the four captures' files (`.r-transient.out`, `.r-managed.out`, `.r-detached.out`'s B block,
`.r-removed.out`) — each cell is a line the script reads there, never typed; `c_states` asserts the rows:

```
  state     | the step (capture)     | statements (Statistics, the state's own span) | contains, asked inside the transaction | the anchor's repository reads Kavya's mealsPerDay
  transient | transient (transient)  | 0 (before the control) | false | no Kavya - not in the table
  managed   | managed (managed)      | 2 (insert 1 · update 1 · delete 0) | true | 3
  detached  | detach (detached, B)   | 1 (insert 0 · update 0 · delete 0) | false | 3
  removed   | removed (removed)      | 2 (insert 0 · update 0 · delete 1) | false | no Kavya - not in the table
  and back: detached -> merge (merge) | 2 (insert 0 · update 1 · delete 0) | contains(det) false | contains(m) true | 2
```

Three of the four say `false` to `contains`: the column that tells them apart is the SQL.

## 8 · tests — TiffinBox's tests, no change (C7-4, R.144, R.190)

`cd .harness/tests && mvn -o -B -Dmaven.repo.local="$M2" clean test` (the anchor's `mvn -B clean test`, offline): exit 0, BUILD SUCCESS,
offline: yes; Surefire's reports `TiffinBoxWebTest` 14, `FullStackTest` 3, `FeedTest` 1 — **18**, failures 0, errors 0, skipped 0; the
console's summary the same. In the tests' log: 2 `Initialized JPA EntityManagerFactory` lines, `org.hibernate.SQL` lines 0 — the 18
guard, they do not witness (none asks Hibernate anything); WARN 1, ERROR 2 (the tests' own kitchen-on-fire cases). The capture is
byte-identical to the persistence-context lesson's (`92ec7e1851904415fe1bcb60200fa4a0` both — the token is never printed in it).

## 9 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s five lines, then `exercise/SOLUTION.md`'s two blocks (each the README's with one line changed: `V`'s step
`ex-detach` → `ex-merge`, and → `ex-plain`), each block sourced in one `env -i` shell (`HOME`, the `PATH` the script was started
with), started in this folder — `/bin/bash --noprofile --norc`, then `/bin/zsh -f`; each block starts its own JVM on 19846, which
persists Kavya with 2 (`setup | statements 1 | … | inserts 1`, id 5, the anchor reads 2) and then changes her to 3. In both shells: the
README → `exit 0`, **`ex-detach | statements 1 | loads 1 | inserts 0 | updates 0 | deletes 0 | flushes 0 | transactions 1`**, the anchor
reads **2**; the solution → `exit 0`, **`ex-merge | statements 3 | loads 2 | inserts 0 | updates 1 | deletes 0 | flushes 2 |
transactions 2`**, **3**; the other solution → `exit 0`, **`ex-plain | statements 2 | loads 1 | inserts 0 | updates 1 | deletes 0 |
flushes 1 | transactions 1`**, **3**; the shell back in this folder, nothing listening on 19846; bash's and zsh's output the same.
Broken ≠ solved by the value the anchor reads (2 ≠ 3) and `updates`, not by the exit code (all three exit 0) — R.196.

## Exercise

**Your turn:** the README changes a customer after detaching it, and the database never hears. Make the change reach the table. (21
words.) `exercise/README.md` ships it broken (its options array runs `--probe.st=ex-detach`: the anchor reads **2**),
`exercise/SOLUTION.md` beside it (`--probe.st=ex-merge` → **3**; and the other solution, `--probe.st=ex-plain` — no detach at all —
→ **3**); all three measured by the `exercise` capture, each from a fresh JVM.

## The ledger rows and hand-offs this unit pays

- **C7-6 — glossed** (managed / detached, contract §10; transient, removed, merge with them): the first paragraph above, each by what
  the SQL shows; the table (§7).
- **C7-4 — re-run**: 18 from Surefire's XML on the anchor, unchanged (§8); carried to U39.
- No other row: C7-1, C7-3 untouched (the URL stays `mem:`; `Database` still seeds; IDENTITY on the existing table).

## RE-MEASURE — the brief's items this unit settles

| # | Settled here |
|---|---|
| 7 | 05's states on `03/after` with the harness as shipped: transient 0 · `contains` false (in the transaction, beside the control's true); managed INSERT at persist + UPDATE at commit, 2 statements, true, 3; detached B 1 statement, updates 0, flushes 0, false, the table keeps 3; merge SELECT + UPDATE, another object, det false / m true, 2; persistdetached the trio, 0 statements; removed false, DELETE at commit, Kavya gone |
| 10 | the exercise as viewers run it, bash and `/bin/zsh -f`, `env -i`: README `ex-detach` updates 0 → 2; SOLUTION `ex-merge` updates 1 → 3, `ex-plain` updates 1 → 3; fresh JVMs |
| 17 | `transient` with `contains` inside the transaction and its control (`true`), and asked outside (`false` for both — never a witness); `ex-detach`/`ex-merge`/`ex-plain` each from a fresh JVM: BLUE's counts reproduced (1·0·0 / 3·1·2 / 2·1·1 statements·updates·flushes) |

## What differed from the brief

1. **The states run on Kavya, one JVM per capture, and the detached capture's A changes her 3 → 2** (the brief's beats name no values;
   its "the database keeps 3" and "reads 2" came from the probe's single JVM, where D1 set 3 before D2 and M1). Here each capture's JVM
   starts with `setup` (Kavya persisted with 3, id 5) so every capture stands alone: A reads **2** (the new value), B keeps **3**, merge
   reads **2**, `managed` (persist 2, set 3 before the commit) reads **3** — the brief's 3 · 3 · 2 are `managed`, `detached` B and
   `merge`. A is the brief's "find, change, commit → UPDATE (the database reads the new value)".
2. **`managed` shows both halves in one transaction**: the INSERT at `persist` (before `after persist()` and before the marker) and an
   UPDATE at the commit for a change made after `persist` — the brief's "a change → UPDATE at commit (04's, called back)" measured
   here on the new entity, not only called back.
3. **`transient`'s 0 statements are the transient's own span** (the lines before the control's `find`, read twice: the log's 0 and
   `Statistics`' `statements so far 0`); the span as a whole has the control's 1 SELECT.
4. **`persistdetached` prints both types with their jars before the trio** — the harness catches the exception only to print it, then
   throws it on, so the run fails as Boot fails a run (exit 1) and the counts line still prints (`finally`). Its **A′ is `merge` of
   the same instance** (unchanged: 1 SELECT, `updates 0`, exit 0) — the brief named the failure receipt and Course 4 §2e's A′ without
   saying which run it is.
5. **`removed` is checked against `setup`'s read** (the anchor read 3 before the remove) as well as `no Kavya` after it.
6. **The `states` table carries a fifth, labelled line — the way back, `merge`** (2 statements, `contains(det) false | contains(m)
   true`, 2), read from `.r-merge.out` like the four rows.
7. **The exercise's other solution, `ex-plain`, is a second block in `SOLUTION.md`**, run as written in the same shell after the
   first — so all three expected values come from their own fresh JVMs (R.196), in bash and in zsh.
8. **The `offline:` label tells the truth by reading the log** (`mbuild`, above), and the sealed recipe seeds the clone's `.m2-demo`
   from the `file://` copy — the persistence-context and first-entity lessons' sealed runs printed "Maven Central was asked" where
   only the `file://` mirror answered (explained above; their files not edited).
9. **`tests` is byte-identical to the persistence-context lesson's capture** (`92ec7e18…`): the same 18 on the same tree, no token in it.
10. **`duration words: 0` is gated over this README and the exercise's two files** (no script or deck exists yet), with dur7 copied
   into `harness/` (md5 asserted; `cmp`-checked against the builders' file when it is beside the clone).
11. **One more hygiene check: no `*.mv.db`, `*.trace.db` or `data/` in this folder outside `.harness/`** (R.195's class; every database
   here is H2 in memory).

## Planted faults — each caught (R.65)

In the captures, every run: `detached` B (`detach`) reads 1 · 1, `updates 0`, `flushes 0`, 3 where A reads 2 · 2, `updates 1`, 2;
`transient`'s control reads `contains true` beside the new object's `false`, in one transaction; `persistdetached` B exits 1 where its
A′ exits 0. On the sealed clone (a copy; `receipts.md5` emptied so the run reaches the checks, except for the hash and duration
plants; the clone restored from the working tree after each):
- **`detach` removed from B** (`St.java`'s `if (detach) em.detach(c);` deleted) → B: `contains true - before commit`, the UPDATE,
  `statements 2 | … | updates 1 | … | flushes 1`, the anchor reads 2 — died `*** detached B: detach - no UPDATE, the table keeps 3:
  expected the line: the two witnesses for detach - … 1 (select 1 · insert 0 · update 0 · delete 0) · Statistics: statements 1 ·
  inserts/updates/deletes 0 0 0 · they agree: yes ***` (exit 1, 75 s).
- **`contains` asked outside the transaction** (`transient`'s two `contains` lines moved after the template; the control still found
  inside it) → `the control, found in the same transaction: Ravi | contains false`, and the new object's line now after the find
  (`statements so far 1`) — died `*** transient: contains false inside the transaction, beside the control's true; 0 statements:
  expected the line: PROBE the control, found in the same transaction: Ravi | contains true - before commit ***` (exit 1, 24 s). The
  new object's `false` alone would have passed this plant: the control is what fails (R.194).
- **The persist-detached catch widened so no exception leaves it** (`St.java`'s `throw e;` deleted: the exception printed, then
  swallowed) → exit 0, no `Application run failed`, the trio `exit 0 ·  · ` — died `*** persistdetached B: the failure receipt:
  expected the line: the trio (Course 4 §2e): exit 1 · jakarta.persistence.EntityExistsException · Detached entity passed to persist:
  com.tiffinbox.CustomerEntity ***` (exit 1, 101 s).
- **`merge` replaced by `persist`** in the `merge` step (the brief's plant) → `Application run failed`,
  `jakarta.persistence.EntityExistsException: Detached entity passed to persist`, exit 1, the span's witnesses 0 · none · `they agree:
  no` — died `*** merge: … expected the line: the two witnesses for merge - … 2 (select 1 · insert 0 · update 1 · delete 0) · … they
  agree: yes ***` (exit 1, 83 s).
- **A duration word planted in this README** (dur7's word for the unit `sec`+`onds`, in the first paragraph) → died before the build,
  `*** dur7.DUR found duration words (Section 1 states none, R.172): README.md line 6: … (the planted word);duration words: 1 ***` (exit 1, 1 s).
- **A wrong published hash** (`receipts.md5`'s `transient` with its last digit changed) → `transient … DIFFERS from the published …`,
  `*** transient is not the published capture … ***` (exit 1, 27 s).

## Found on the way

- **The persistence-context lesson's sealed `offline: no - … Maven Central was asked`** was a correct fallback with a fixed label: an
  empty `.m2-demo` in the clone, the retry served by the `file://` mirror `sealed` (691 `>sealed=`, 0 `central`); the first-entity
  lesson's three sealed builds printed the same (859, 0). No artifact outside the seed. Settled above; RED owns those files.
- **`detach` before the commit leaves the commit nothing to flush, and `Statistics` counts no flush** (`flushes 0`), where A's commit,
  with one managed entity, counts one — and `transient`'s commit, with a found but unchanged entity, counts one too (`flushes 1`,
  statements 1: the SELECT). A flush is said only with a statement beside it (R.184).
- **`merge` of an unchanged detached instance writes nothing** (A′ of `persistdetached`: 1 SELECT, `updates 0`): the UPDATE in `merge`
  comes from the change, not from `merge` itself.
- **The rolled-back `persist` counts as a transaction** (`transactions 1`, `statements 0`).
- Editing `receipts.sh` while a run of it is in flight breaks the run (bash reads the script as it goes: a development run died with
  exit 127 after an edit) — every run of record ran on an unchanged file.

## CARRIED

- Two ways into one database (Hikari for Hibernate, `DriverManager` for `Database`/`CustomerRepository`) → the unit that retires
  `CustomerRepository`'s strings (Section 2/3's brief).
- The id strategy that delays INSERTs to the commit (R.192: IDENTITY inserts at `persist`) → the ids lesson (U06's brief).
- `check_unit7.py`'s `DUR_SECTIONS` gaining section 1 → the tooling session; this unit's own gate stands meanwhile.
- The persistence-context lesson's `mbuild` label (`offline: no - … Maven Central was asked` on its sealed clone): found and explained
  here (above), **not edited** — RED owns that file; the first-entity lesson's `mbuild` carries the same sentence.

## For RED

Re-run from a clean tree (seeded `.m2-demo`, `HOME` with dead proxies) in a process group of its own; the plants above; ports
20220-20239 for any re-run of this unit's JVMs outside its script. Evidence by an Opus 5.5 agent on 2026-11-01.
