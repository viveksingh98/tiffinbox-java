# c7-unit04 — The Persistence Context

Course 7 · Data with JPA & Hibernate · Section 1 (ORM from First Principles), its fourth unit · Verified on **JDK 25.0.4.1, Apache
Maven 3.9.16, Spring Boot 4.1.2** (Spring Framework 7.0.10, Hibernate ORM 7.4.13.Final, Spring Data JPA 4.1.2, Jakarta Persistence
3.2.0, HikariCP 7.0.2, H2 2.5.250 — the anchor's own pin), 2026-11-01. **H2, in memory, every capture**: no Postgres, no container, no
native build. Ask Hibernate for the same customer twice and the database hears once; change a field, call no save, and an UPDATE runs
anyway. Both come from the **persistence context** — the set of entities one EntityManager has loaded and keeps track of, at most one
object per row — and in the EntityManager Spring injects it lives exactly as long as the transaction. Each claim here is measured, and
each names its boundary and its EntityManager (R.183).

**No anchor change.** `anchor` is the link to `../c7-unit03/after` — the tree the first-entity lesson froze — and the script dies unless
`diff -rq -x .m2-demo -x target -x secrets anchor/ ../c7-tiffinbox` is empty, at its start and again at its end: it was, in every run of
record. The anchor is copied under `.harness/anchor` and built there, never in place. No file of `c7-tiffinbox/` changed.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 7 captures, 3 runs each; every spoken number asserted after its capture; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the `JAVA_HOME` export on its first line after the shebang and dies unless `java -version` and `javac -version`
say 25; a bare `java` on this Mac is 23.0.1.) It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line
first). **Start it in a process group of its own** (a terminal's foreground job is one): `sweep()` stops only processes of its own group.
`.m2-demo` must be seeded first (below) — on a clone whose `.m2-demo` is empty the build runs once more without `-o`, and its
`offline: no - …` line names the artifact the offline build missed and the repositories the retry's log names ("The repository, and
the network").

**Runs, each `env -i`** (`HOME` = a home of its own whose `.mavenrc` sets `-Duser.home` there and whose `settings.xml`
names only two dead proxies, `127.0.0.1:9` — so no Maven run could reach the network; `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:
/sbin`; `http(s)_proxy` dead too), a session of its own, `.m2-demo` seeded from `../../../data-jpa-hibernate/_research/m2-seed-c7-s1/`
alone (6,608 files). On 2026-11-01 two development runs fixed the captures and the checks (the second made every capture 3/3 and
stopped at "no published hash" with every check passed; its md5s are `receipts.md5`); then one more pair of runs and one sealed-clone
run before the checks were reordered (witness lines first, so a plant dies on its count), and the first runs of record (170 s and
184 s). **The runs of record (2026-11-03, after the `offline:` label fix — For RED), on the script as committed (`receipts.sh` md5
`ff545c8cac565d0d9fe724ac2ebce80c`): 312 s under `./receipts.sh`** (/bin/bash 3.2.57) **and 207 s under `bash receipts.sh`** (Homebrew bash
5.3.9): each exit 0, all 7 captures 3/3 = published (every hash the one published on 2026-11-01), every check passed, the build
`offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`; each terminal log through `check_unit7.py 04 --runlog` — `0 grep
error line(s)`, `RESULT (run logs): PASS` (the unit gate itself answers "no 04-*.md … nothing to check": no script yet). **Nothing was
downloaded** for this unit.

Published hashes: twofinds `0bfeb2b7de1bf6bbbc3791272855b587` · own `3efa24349b9e49dd0ef67332bcb8d850` · request `79969e215a8bc25e32c5c2b25fd94ab7` · dirty `d63a21cc7afb1999ec6f11b9ea04b6ce` · boundary `4a577ed538c89d8a17f7c8922a01b412` · tests `92ec7e1851904415fe1bcb60200fa4a0` · exercise `389ebf1c5cab7cedb13b972e8d308091`.

### A sealed fresh clone — the recipe (R.129)

**Paste it into bash** (type `bash` first if your Terminal is zsh: zsh does not split the unquoted `$E`).

**Run (2026-11-03):** a `git clone` of tiffinbox-java at `cd9eac2` into a path **with a space** (`…/sealed 04 seeded/tiffinbox-java`),
with this unit's two edited files (`receipts.sh`, `README.md`) put in as git would take them (`git ls-files -co --exclude-standard`:
13 files under `c7-unit04/`, each `cmp`-equal to the working tree; `anchor` → `../c7-unit03/after` by `readlink`); a `file://`
copy of the seed (4,967 files: `_remote.repositories`, `*.lastUpdated` and `resolver-status.properties` left out); pre-flight: exit
1, 221 `Downloading from sealed: file://`, 0 from http(s); the clone's `.m2-demo` **seeded from that copy** (4,967 files — as
a viewer seeds it, "The repository" below); `/bin/bash` 3.2, `env -i`, a session of its own: **exit 0 in 437 s, all 7 =
published, every check passed**; the build said **`offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`**; after the run
the clone's `.m2-demo` held 4,967 files (0 `_remote.repositories`). Its terminal log through `--runlog`: PASS. (The builders'
`dur7.py` is not beside a clone: its md5 is the check.)

```bash
S=/tmp/sealed04; W="/tmp/sealed 04"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
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
cd "$W/tiffinbox-java/c7-unit04" && readlink anchor && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E ./receipts.sh            # a process group of its own
```

(The clone's own `c7-unit04/` is the committed one once this unit is in git; before its commit it was put in as above.)

**An empty `.m2-demo` — the label, derived from the log (2026-11-03).** A second clone (`…/sealed 04 empty/tiffinbox-java`, the same
recipe without the seeding line) printed `offline: no - the offline build could not resolve org.springframework.boot:spring-boot-starter-parent:pom:4.1.2 from .m2-demo, so it ran once more without -o; that run downloaded from: sealed (file) 691; of them over http(s): 0 · exit 0 · 'Downloaded from' lines in its log: 691`; the offline attempt's log (kept beside, `.harness/build-anchor-offline.log`)
names it: `Cannot access sealed (file://…) in offline mode and the artifact org.springframework.boot:spring-boot-starter-parent:pom:4.1.2 has not been downloaded from it before`; the clone's `_remote.repositories`: 691 `>sealed=`, 0 `central`; then **exit 0 in 337 s, all 7 =
published**; its terminal log through `--runlog`: PASS. The label names the one repository the retry's log names, the `file://`
mirror `sealed`, and the count over http(s), 0.

## The commands this unit adds

```bash
java -Duser.language=en -Duser.country=US -cp "../hc:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 "${V[@]}"
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/src/probe/jpa/Four.java harness/src/probe/jpa/Pc.java harness/src/probe/jpa/Probe.java harness/src/probe/jpa/Steps.java harness/src/probe/jpa/Web.java
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/probe/twofinds
kill "$pid"
```

`receipts.sh` reads five lines from the anchor's README (`anchor/README.md`, each asserted there whole): `mvn -B package`, `mvn -B
clean test`, the extract line, the extracted-jar run line and the health `curl`. Each line above is asserted in this README, and the
derived ones are asserted to be an anchor line with one change: **the harness line** is the anchor's extracted-jar line (`java -cp
"tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:…/lib/*" com.tiffinbox.web.TiffinBoxServer`) with the locale, `../hc:` first on
the class path and `"${V[@]}"` after it — `V` is the run's options array (R.193), printed as `$ V=(…)` before each run (an element with a
shell character in it, the trace run's URL, single-quoted); **the route's `curl`** is the anchor's health line with the path
`/probe/twofinds`. `kill "$pid"` stops the JVM a `request` run started, by its pid (R.30). Every Maven line runs offline: `-o -B
-Dmaven.repo.local="$M2"` after `mvn`, `clean` before `package`. Every java line runs from `.harness/anchor`, where a config tree holds
the demo token.

## The repository, and the network

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s1/` alone (6,608 files) before the runs of record. **Nothing was downloaded** by a
receipt: every build said `offline: yes` with 0 `Downloaded from` lines, the tests' log holds 0 `Downloading from` lines, and the
runs' `HOME` named only dead proxies. A clone whose `.m2-demo` is empty (git ignores it) runs the build once more without `-o`, and
the `offline: no - …` line names the artifact the offline build missed, every repository the retry's log says it downloaded from (id,
URL scheme, count) and the count over http(s) — it never names a repository the log does not (measured above). After the build the script asserts `.m2-demo` holds `spring-boot-starter-parent-4.1.2.pom`,
`hibernate-core-7.4.13.Final.jar` and `spring-boot-starter-data-jpa-4.1.2.jar`. **At run time** every request goes to `127.0.0.1`, and
every database is H2 in the JVM's own memory, gone with it. **One dated look at Maven Central, outside every receipt** (CARRIED from
the first-entity lesson): 2026-11-01T09:45:11+0100, `curl -sS -m 10 -o metadata.xml
https://repo1.maven.org/maven2/org/springframework/boot/spring-boot-starter-parent/maven-metadata.xml` into the agent's scratch
folder (md5 `8f50ccc3cedaff9bbc53ff3b8502d499`, `lastUpdated` 20261022123848): the newest GA is **4.1.2**; 4.1.3 is absent; 4.2.0 GA is
absent (its newest is **4.2.0-RC1**, which Maven's `<release>` tag names). ⚑1 stands: no re-brief.

## The demo token

`TOKEN=` near the top of `receipts.sh` (38 characters), fake and meant to look it: it guards nothing but demo servers on 127.0.0.1. It
is written into `.harness/*/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600, git-ignored) of every copy; no command of this
unit sends it (the `request` JVMs are stopped by their pids). Before every start the script lists that `secrets/` folder (the token's
file, nothing else — R.158), and a last check counts one listing per start. Every capture's raw output, the log of every JVM (27 per
run), every build log, every Surefire report and every file this unit ships: the token 0 times.

## The locale

Every java line carries `-Duser.language=en -Duser.country=US`; a last check refuses a capture's java line without it; the test fork's
comes from the POM's `argLine` (the reports say `en`/`US`). **The harness prints ASCII** (` | ` between facts): a JVM started under this
script's `LC_ALL=C` writes its standard output in ASCII.

## The folders, the harness and the ports

- `anchor` — the link to `../c7-unit03/after` (= `../c7-tiffinbox`). `.harness/anchor` — copied, with a config tree, built with the
  README's `mvn -B package` (its 18 tests run), its jar extracted there (the anchor's own line, 91 libraries); `.harness/hc` — the
  harness, compiled; `.harness/tests` — `tests`' copy; `.harness/mine.log` — the exercise's log.
- **The harness** — the course's, never TiffinBox's (`harness/src/probe/jpa`, package `probe.jpa`, outside `com.tiffinbox`; a check
  refuses `probe.jpa` anywhere in the anchor's code). **`Probe.java` and `Steps.java` are the first-entity lesson's, byte for byte**
  (md5 `fc0c06932cd2cd8c912f304328b367b8` / `e316b9418711b0c142d3b7c7519d9215`, asserted, and `cmp` against `../c7-unit03/harness`);
  they act only on `--probe.steps`, which no run here sets. This unit adds three: **`Four`** (`@Configuration @Import({Probe, Pc,
  Web})`, joined by `--spring.main.sources=probe.jpa.Four`), **`Pc`** (an `ApplicationRunner` that does nothing unless the run sets
  **`--probe.pc`**, runs the named steps in order outside any HTTP request, prints `PROBE` lines, then
  `System.exit(SpringApplication.exit(ctx))`) and **`Web`** (`GET /probe/twofinds`: two finds of customer 1 in a request, no transaction;
  it answers open-in-view's property and `OpenEntityManagerInViewInterceptor` bean count, `same object`, `in a transaction`, and
  `Statistics`' statements and loads). `Pc`'s steps: `twofinds-tx` (two `find(CustomerEntity.class, 1L)` inside one
  `TransactionTemplate` over the context's transaction manager), `twofinds-notx` (the same two on the EntityManager Spring injects, no
  transaction), `own` (the same two on `emf.createEntityManager()`, no transaction), `dirty` (`find`, `setMealsPerDay(3)`, no save, one
  `TransactionTemplate`), `boundary` (the transaction manager's class and the injected EntityManager's handler, each with its jar). Each
  step clears Hibernate's `Statistics` (`hibernate.generate_statistics=true` in every run's `V`), prints `PROBE <step> begin` / `PROBE
  <step> end` around its database work, then its counts line; `same object (a == b)` comes with the two `System.identityHashCode`s
  (`@%08x`, masked in the captures — they differ every run, Course 4 §2b) and whether the pair is equal. Customer 1 is Ravi, the first
  row `Database` seeds (2 meals a day). `harness/surefire.py` (the testing lesson's, `cmp`-checked) reads Surefire's reports;
  `harness/dur7.py` is Course 7's builders' duration pattern, byte for byte (md5 `41667fed9ffcefe171389eed7e654e66` asserted; `cmp`
  against `../../../data-jpa-hibernate/_builders/dur7.py` when that file is beside the clone).
- **Ports** (§P, 19830-19839): `twofinds` 19830 · `own` 19831 · `request` 19832 · `dirty` 19833 · `boundary` 19834 · `exercise` 19835 ·
  19839 never bound. Every JVM is waited for by its pid before the next on its port; a harness JVM with steps exits by itself (bounded,
  120 s); a `request` JVM is stopped by its pid; the script asserts nothing listens on the port after each. 18425, 8080 and 35729 checked
  free first and last; `tests` binds none.

## Masks, filters and hygiene — every one, declared

1. **`mask()`** (`gsub()`, literals escaped; checked first on a planted line): the token → `[masked: the 38-character token]`; this
   folder → `…`, the folder above → `…/..`, home → `~`, the user name → `<user>`; ` using Java <version>` (R.151); H2's generated
   database name → `jdbc:h2:mem:<uuid>` (none appears here); **an identity hash → `@…`**; **H2's trace connection number →
   `conn<n>`** (H2 numbers every connection it opens, Hikari's background fills among them).
2. **A JVM's log** (`view`): in order, the harness's `PROBE` lines and the lines of the loggers each capture names (level, logger as
   Boot printed it, message cut at 260 characters, trailing spaces dropped); after `Application run failed` the exception's first line
   and its distinct `Caused by:` lines (none happened); frames never; **H2's trace lines never printed whole** — only the JDBC calls
   `setAutoCommit(…)`, `commit()`, `rollback()` between a step's markers, counted and listed in order. `jlog`: Hikari's `Added
   connection … url=` line (R.185), Hibernate's version line, WARN and ERROR lines counted. `hres`: the exit code and Boot's first line.
3. **A Maven log**: its `$` line, exit code, `BUILD` line, `offline` (its `Downloading from` lines counted); Surefire's reports
   (`surefire.py`) with the console's summary beside their sum (R.144); Hibernate's `Initialized JPA EntityManagerFactory` lines and
   `org.hibernate.SQL` lines counted; WARN and ERROR counted.
4. **Hygiene, checked last over every capture**: no absolute path, no unit number, no Boot process line, no time, no log time, no
   thread number, no proxy class number, no JDK/OS version token, no unmasked generated database name, **no unmasked identity hash**,
   no random port, no stack frame; every `$` line's URL 127.0.0.1's; every java line pinned; one `secrets/` listing per start; no
   `pkill`/`killall`; no bare `wait`; no variable holding several options in one string (R.193); no harness class in `com.tiffinbox`.
   No duration is captured. **`duration words: 0`** — dur7's `DUR` over this README and the exercise's two files, before the build: a
   match stops the run (R.172; Section 1 states no duration; `check_unit7.py`'s own gate for section 1 is the tooling session's).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the Maven it
waits for (`$mpid`, with every process under it — Surefire's fork — `killtree`), the exercise's shell (`$xpid`, with every process under
it), sweeps its own process group for any TiffinBox JVM, Maven or Surefire fork left, deletes the capture runs it had not finished
(`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched. No `wait` in the script or the exercise is bare.

**Measured (2026-11-01):** `./receipts.sh` (/bin/bash 3.2) started in a session of its own **with SIGINT at its default**
(`signal.signal(SIGINT, SIG_DFL)` before `setsid`/`exec` — a background job of a non-interactive shell would inherit it ignored), `kill
-INT` to that group once the named process was in it, the state read 5 s later — three trials, each **exit 130, nothing left**:

```
fork: processes in the group at SIGINT 5 · exit 130 · 5 s later in the group: 0 · java/surefire/maven of the run anywhere: 0 · ports listening 19300-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
harness: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · java/surefire/maven of the run anywhere: 0 · ports listening 19300-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
jvm: processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · java/surefire/maven of the run anywhere: 0 · ports listening 19300-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
```

`fork` — Surefire's `surefirebooter` (the build's tests); `harness` — `twofinds`' harness JVM on 19830; `jvm` — `request`'s serving JVM
on 19832 (the one `kill "$pid"` stops in a normal run).

## 1 · twofinds — two finds, one SELECT or two (A/B/A′, R.183, R.184)

The harness, Hibernate's SQL logger at DEBUG, port 19830, a fresh JVM each:
- **A** — step `twofinds-tx`: both finds inside one `TransactionTemplate` on **the EntityManager Spring injects**; `in a transaction:
  true`; **one** `select ce1_0.id,ce1_0.meal_type,ce1_0.meals_per_day,ce1_0.name,ce1_0.price_per_meal from customer ce1_0 where
  ce1_0.id=?` between the markers; `first find -> Ravi | second -> Ravi`; **`same object (a == b): true`**, the identity hashes equal;
  `statements 1 | loads 1 | updates 0 | flushes 1 | transactions 1`. **The two witnesses** (R.184): SELECT lines the SQL logger printed
  between `twofinds-tx begin` and its end **1** · `Statistics` statements **1** · they agree: yes. (`flushes 1` is the commit's flush
  with nothing to write; the one statement is the SELECT — never "it flushed a SELECT".) Hikari on `jdbc:h2:mem:tiffinbox`.
- **B** — one flip, the harness's step: `twofinds-notx` — the same two finds on the same injected EntityManager, **no transaction**,
  from an `ApplicationRunner`, outside any request; `in a transaction: false`; **two** SELECT lines; **`same object (a == b): false`**,
  the identity hashes differ; `contains the first, asked afterwards: false`; `statements 2 | loads 2 | updates 0 | flushes 0 |
  transactions 0`; the two witnesses 2 · 2 · agree. With no transaction, the shared proxy Spring injects opened a new EntityManager — a
  new persistence context — for each call (RED #8).
- **A′** — A again, line for line (its `$` lines too; the identity hashes masked).

## 2 · own — the named contrast: an EntityManager the code makes (labelled C, R.183)

Step `own`, port 19831: `emf.createEntityManager()`, two finds, **no transaction** (`in a transaction: false`) → **one** SELECT,
**`same object (a == b): true`**, **`contains true | joinedToTransaction false`**, `statements 1 | loads 1 | updates 0 | flushes 0 |
transactions 0` (the two witnesses 1 · 1 · agree); `a JDK proxy: true | handler
org.springframework.orm.jpa.ExtendedEntityManagerCreator$ExtendedEntityManagerInvocationHandler (in spring-orm-7.0.10.jar)`. A
persistence context does not need a transaction: this one lives as long as the EntityManager the code holds. The one Spring injects
is bound to the transaction (§5).

## 3 · request — two finds in an HTTP request, no transaction (labelled C/D, ⚑4)

`GET /probe/twofinds` (the route's `curl` above, port 19832), one JVM per open-in-view value, the harness joined with no step (the JVM
serves), started, waited for until readiness answers 200, asked once, **stopped by its pid** (`kill "$pid"`: SIGTERM, exit 143, nothing
left listening):
- **C** — open-in-view as the anchor ships it (`application.yaml`: `false`, no option): `open-in-view: property false |
  OpenEntityManagerInViewInterceptor beans 0 | same object (a == b): false | in a transaction: false | statements 2 | loads 2 200`; the
  SQL logger's SELECT lines in that JVM **2** (the request's alone: Hibernate wrote no SQL at the start) · the route's `Statistics` 2 ·
  agree.
- **D** — C with one flip, `--spring.jpa.open-in-view=true`: `property true | … beans 1 | same object (a == b): true | in a transaction:
  false | statements 1 | loads 1 200`; SELECT lines **1** · 1 · agree.

Without a transaction, the request decided: open-in-view's interceptor holds one EntityManager open for the whole request. That is why
the anchor switched it off (the first-entity lesson, ⚑4) — and why this unit's "no transaction" control (§1 B) runs outside a request.

## 4 · dirty — a field changed, no save, and an UPDATE at the commit (R.191, R.197)

Step `dirty`, SQL at DEBUG and binds at TRACE, port 19833, in the order the log printed them: `dirty begin`; the SELECT and its bind
`(1:BIGINT) <- [1]`; `loaded: Ravi | mealsPerDay 2`; **the marker `field set to 3, no save called, before commit`**; then **`update
customer set meal_type=?,meals_per_day=?,name=?,price_per_meal=? where id=?`** with five binds — `[VEG]`, `[3]`, `[Ravi]`, `[120]`, `[1]`
(every column written, not only the one that changed); `dirty end - after commit`; `statements 2 | loads 1 | updates 1 | flushes 1 |
transactions 1`; **`anchor repo reads Ravi's mealsPerDay: 3`** (TiffinBox's own `CustomerRepository`, over its own `DriverManager`
connection). The order, read from the log around the named marker: SELECTs before it **1** · UPDATEs before it **0** · UPDATEs after it,
before `after commit`, **1**; the two witnesses — SQL lines between the markers 2 · `Statistics` statements 2 · agree. No `save`,
`persist` or `merge` was called: Hibernate compared the entity it loaded with its snapshot at the flush before the commit (**dirty
checking**) and wrote the difference.

## 5 · boundary — what decides (R.183; C7-11 named)

- **The template's lines**, read from `Pc.java` (`grep -n`): line 72 `TransactionTemplate tx = new TransactionTemplate(tm);`, line 78
  `CustomerEntity[] ab = tx.execute(s -> {`, line 111 `tx.executeWithoutResult(s -> {`.
- **Read off the context and the field** (step `boundary`, port 19834): `transaction manager:
  org.springframework.orm.jpa.JpaTransactionManager (in spring-orm-7.0.10.jar)`; `injected EntityManager: a JDK proxy: true | handler
  org.springframework.orm.jpa.SharedEntityManagerCreator$SharedEntityManagerInvocationHandler (in spring-orm-7.0.10.jar)` — the shared
  proxy that hands each call to the transaction's EntityManager, or to a new one when there is no transaction.
- **B (labelled: H2's trace on Boot's URL)** — steps `twofinds-tx,twofinds-notx` in one JVM, `V` adds
  `'--spring.datasource.url=jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1;TRACE_LEVEL_SYSTEM_OUT=3'` (the same database; Hikari's line still
  `url=jdbc:h2:mem:tiffinbox`). H2's trace, between each step's markers, the JDBC calls Course 2 taught by hand:
  **in a transaction (`twofinds-tx`): `setAutoCommit(false)` 1 · `commit()` 2 · `setAutoCommit(true)` 1 · `rollback()` 0**, in order
  `setAutoCommit(false)`, `commit()`, `setAutoCommit(true)`, `commit()` (the second `commit()` is the one JDBC runs when auto-commit is
  switched back on, as H2's trace prints it); **without one (`twofinds-notx`): 0 · 0 · 0 · 0**. The counts lines match §1 (1 and 2
  statements). And before the steps, TiffinBox's own `Database` seeding its table on its `DriverManager` connection: `setAutoCommit(false)`
  1 · `commit()` 1 — `Database.java` line 46 `c.setAutoCommit(false);`, line 72 `c.commit();`: Course 2's pattern, written by hand in the
  anchor, beside the one `JpaTransactionManager` runs for the template. **C7-11** (Course 2's transactions under `@Transactional`) is
  named here and paid by *`@Transactional`: What the Proxy Does* and the batching lesson.

## 6 · tests — TiffinBox's tests, no change (C7-4, R.144, R.190)

`cd .harness/tests && mvn -o -B -Dmaven.repo.local="$M2" clean test` (the anchor's `mvn -B clean test`, offline): exit 0, BUILD SUCCESS,
offline: yes; Surefire's reports `TiffinBoxWebTest` 14, `FullStackTest` 3, `FeedTest` 1 — **18**, failures 0, errors 0, skipped 0; the
console's summary the same; the fork `en`/`US`. In the tests' log: 2 `Initialized JPA EntityManagerFactory` lines, `org.hibernate.SQL`
lines 0 — the 18 guard, they do not witness (none asks Hibernate anything); WARN 1, ERROR 2 (the tests' own kitchen-on-fire cases).

## 7 · exercise — run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s five lines, then `exercise/SOLUTION.md`'s (the README's with one line changed: `V`'s step `twofinds-notx` →
`twofinds-tx`), each block sourced in one `env -i` shell (`HOME`, the `PATH` the script was started with), started in this folder —
`/bin/bash --noprofile --norc`, then `/bin/zsh -f`; each block starts its own JVM on 19835. In both shells: the README → `exit 0`, `in a
transaction: false`, **`same object (a == b): false`**, **`statements 2`**; the solution → `exit 0`, `in a transaction: true`, **`same
object (a == b): true`**, **`statements 1`**; the shell back in this folder, nothing listening on 19835; bash's and zsh's output the same.
Broken ≠ solved by the counts and `same object`, not by the exit code (both halves exit 0).

## Exercise

**Your turn:** the README's two finds hit the database twice. Give them one transaction and watch it drop to one. (20 words.)
`exercise/README.md` ships it broken (its options array runs `--probe.pc=twofinds-notx`), `exercise/SOLUTION.md` beside it
(`--probe.pc=twofinds-tx`); both measured by the `exercise` capture, each from a fresh JVM.

## The ledger rows and hand-offs this unit pays

- **C7-6 — paid** (the persistence context, glossed at first use): §1 defines it by what it does — one `find` answered from it, one object
  per row inside a transaction; §2 shows it does not need a transaction; §4 shows dirty checking and the flush before the commit.
- **C7-4 — re-run**: 18 from Surefire's XML on the anchor, unchanged (§6); carried to U39.
- **C7-11 — named**: Course 2's `setAutoCommit(false)` / `commit()` shown under the template, counted from H2's trace (§5); paid at U23/U33.
- **C7-10** (self-invocation) — not shown here; named by title only, *`@Transactional`: What the Proxy Does*.

## RE-MEASURE — the brief's items this unit settles

| # | Settled here |
|---|---|
| 6 | `request` on `03/after`: open-in-view `false` by YAML → 2, two objects; `true` by flag → 1, one object; the bean count per run |
| 10 | the exercise as viewers run it, bash and `/bin/zsh -f`, `env -i`: README `statements 2`/`false`, SOLUTION `statements 1`/`true`, fresh JVMs |
| 16 | `own` (application-managed EntityManager): 1 SELECT, same object, `contains true`, `joinedToTransaction false`; the injected EntityManager's handler `SharedEntityManagerCreator$SharedEntityManagerInvocationHandler`; the trace counts 1 · 2 · 1 / none |
| 12 | 4.1.3's absence, re-checked (one dated metadata fetch, above): absent; 4.2.0 GA absent (4.2.0-RC1) |

## What differed from the brief

1. **The harness is 03's `probe.jpa.*` plus three classes, not plus `Web` alone.** `Probe`/`Steps` stay byte for byte (md5 asserted),
   and `Steps` ends the JVM after its own steps — so this unit's steps live in a second runner, `Pc`, on its own property
   (`--probe.pc`), with `Four` joining `Probe`, `Pc` and `Web` (`--spring.main.sources=probe.jpa.Four`).
2. **Every find asks for customer 1 (Ravi, seeded), and `dirty` changes Ravi (2 → 3)** — the probe's F1/F2/D1 used Kavya (id 5) after a
   persist. No persist runs in this unit; the facts are the same (1 vs 2 SELECTs, `true`/`false`, `updates 1`, the anchor reads 3).
3. **The trace run (`boundary` B) puts `TRACE_LEVEL_SYSTEM_OUT=3` on `spring.datasource.url` alone** (Boot's URL; `tiffinbox.jdbc-url`
   unchanged), and runs F1 and F2 in one JVM between markers: F1 `setAutoCommit(false)` 1 · `commit()` 2 · `setAutoCommit(true)` 1, F2
   none — RED's counts, re-run. **Beyond the brief:** the same trace shows the anchor's `Database` seeding with `setAutoCommit(false)` 1 ·
   `commit()` 1 before the steps, and the receipt prints `Database.java`'s two lines.
4. **`request`'s route answers open-in-view's value per run itself** (the property and the interceptor bean count, R.194) beside `same
   object` and `Statistics`; each JVM is stopped by SIGTERM to its pid and exits **143** (the brief named no exit code).
5. **The exercise's two halves both exit 0**: broken ≠ solved is `statements 2`/`false` against `statements 1`/`true` (R.196).
6. **`tests` runs the anchor's own `mvn -B clean test`**, not `clean verify` (as the first-entity lesson; the same 18).
7. **`duration words: 0` is gated over this README and the exercise's two files** (no script or deck exists yet), with dur7 copied into
   `harness/` (md5 asserted; `cmp`-checked against the builders' file when it is beside the clone — a sealed clone has no
   `data-jpa-hibernate/`).
8. **Each capture's checks run right after it** (the first-entity lesson checked at the end), so a planted fault stops the run at its
   capture.
9. **⚑1's 4.1.3 look ran** (this agent had network for one fetch): 4.1.3 absent, 4.2.0 GA absent (4.2.0-RC1 present) — the first-entity
   lesson's CARRIED item, settled for today.

## Planted faults — each caught (R.65)

In the captures, every run: `twofinds` B (no transaction) reads 2 · 2 and `false` where A reads 1 · 1 and `true`; `request` C (open-in-view
false) 2 where D reads 1. On the sealed clone (a copy; `receipts.md5` emptied so the run reaches the checks, except for the hash plant;
the clone restored from the working tree after each):
- **The transaction removed from A** (`Pc.java`'s `twofinds-tx`: `tx.execute(s -> …)` replaced by calling the same lambda directly) →
  2 SELECT lines, `Statistics` 2, `same object: false` — died `*** twofinds A: one SELECT, one object: expected the line: the two
  witnesses - … 1 · Statistics: statements 1 · they agree: yes ***` (exit 1, 38 s).
- **The template's propagation flipped to `PROPAGATION_NOT_SUPPORTED`** (one line after `new TransactionTemplate(tm)`) → `in a
  transaction: false`, but **still 1 SELECT and `same object: true`**, `flushes 0 | transactions 0` — died on the counts line `***
  twofinds A: … expected the line: PROBE twofinds-tx | statements 1 | loads 1 | updates 0 | flushes 1 | transactions 1 ***` (exit 1, 39
  s). The SELECT count alone would have passed this plant (Found on the way).
- **`own` run on the injected EntityManager** (`own.find` → `em.find`) → 2 · 2, `same object: false`, `contains false` — died `*** own:
  one SELECT, one object, no transaction: expected the line: the two witnesses - … 1 · Statistics: statements 1 · they agree: yes ***`
  (exit 1, 48 s).
- **The "before commit" marker moved after the template** → `SELECTs before it: 1 · UPDATEs before it: 1 · UPDATEs after it, before
  after commit: 0` — died `*** dirty: expected the line: the order around the marker 'before commit' (R.197): … UPDATEs before it: 0 ·
  UPDATEs after it, before after commit: 1 ***` (exit 1, 81 s).
- **open-in-view flipped in `request` C without its label** (`--spring.jpa.open-in-view=true` added to C's `V` in `receipts.sh`) → C
  answers `property true | … beans 1 | … statements 1` — died `*** request C: open-in-view must be false here, the anchor's own value
  (interceptor beans 0) - C is labelled with no open-in-view option ***` (exit 1, 78 s).
- **A duration word planted in this README** (dur7's word for the unit `sec`+`onds`, in the first paragraph) → died before the build,
  `*** dur7.DUR found duration words (Section 1 states none, R.172): README.md line 6: …;duration words: 1 ***` (exit 1, 1 s).
- **A wrong published hash** (`receipts.md5`'s `twofinds` with its last digit changed) → `twofinds … DIFFERS from the published …`,
  `*** twofinds is not the published capture … ***` (exit 1, 46 s).

## Found on the way

- **A `TransactionTemplate` with `PROPAGATION_NOT_SUPPORTED` runs its callback with no transaction (`in a transaction: false`,
  `transactions 0`) — and the injected EntityManager still answered both finds from one persistence context (1 SELECT, the same
  object)**: Spring's transaction synchronization binds one EntityManager for the template's scope even without a transaction. So
  "lives as long as the transaction" is said of the default template (`PROPAGATION_REQUIRED`) only, and the checks read `transactions 1`
  and `in a transaction: true` beside the SELECT count. Measured once, as a plant; not a beat (CARRIED).
- In a `TransactionTemplate`, H2 traces **two** `commit()` calls: Spring's, and the one inside `setAutoCommit(true)` (JDBC commits when
  auto-commit is switched back on).
- The anchor's own `Database` runs Course 2's `setAutoCommit(false)` … `commit()` at every start (H2's trace shows it before any step).
- `emf.createEntityManager()` returns a JDK proxy too (handler `ExtendedEntityManagerCreator$ExtendedEntityManagerInvocationHandler`):
  both EntityManagers in this unit are Spring's proxies; their proxy class numbers are never printed.
- Importing `harness/dur7.py` writes a `__pycache__/` beside it unless Python runs with `-B`: the gate runs `python3 -I -B` (the first
  development run stopped on "harness/ holds another file").

## CARRIED

- Two ways into one database (Hikari for Hibernate, `DriverManager` for `Database`/`CustomerRepository`) → the unit that retires
  `CustomerRepository`'s strings (Section 2/3's brief).
- The self-invocation trap → *`@Transactional`: What the Proxy Does* (U23).
- Open-in-view as a wrong fix → *Lazy Loading and `LazyInitializationException`* (U29).
- `check_unit7.py`'s `DUR_SECTIONS` gaining section 1 → the tooling session; this unit's own gate stands meanwhile.
- The template's scope without a transaction (`PROPAGATION_NOT_SUPPORTED`: one persistence context, no transaction — Found on the way)
  → *`@Transactional`: What the Proxy Does* (U23), where propagation is taught; measured here once, as a plant.
- 4.2.0: RC1 on 2026-11-01 — the next dated metadata look decides whether ⚑1 re-opens (no GA today).

## For RED

Re-run from a clean tree (seeded `.m2-demo`, `HOME` with dead proxies) in a process group of its own; the plants above; ports
20220-20239 for any re-run of this unit's JVMs outside its script. Evidence by an Opus 5.5 agent on 2026-11-01.

- **2026-11-03:** the `offline:` label was a fixed sentence (`Maven Central was asked`) while the only repository the log names was
  the `file://` mirror; replaced by the derived label (unit 05's `mbuild`); captures unchanged (hashes equal); runs of record re-done.
  `receipts.sh` changed in two places only: the header's "The network" comment and `mbuild` (with its comment; `grep` there is
  `/usr/bin/grep`); the label line is printed on the terminal, outside every capture. The sealed recipe now seeds the clone's
  `.m2-demo` from the `file://` copy (above). **Plant** (a copy, `.m2-demo` empty, a `settings.xml` whose mirror is a dead
  `http://127.0.0.1:9/` repository): the offline build failed, and the retry's log holds one `Downloading from dead: http://127.0.0.1:9/…/spring-boot-starter-parent-4.1.2.pom` line, `Could not transfer artifact org.springframework.boot:spring-boot-starter-parent:pom:4.1.2 from/to dead (http://127.0.0.1:9/)` and 0 `Downloaded from` lines; no `offline:` line was printed — the run died `*** build failed: .harness/anchor (…) - Maven could resolve Boot's parent and plugins neither from .m2-demo nor from a repository it could reach: … ***` (exit 1, 6 s). No line of the run names a repository its log does not. **SIGINT** during the build's Maven (bash 3.2, a session of its own, SIGINT at its
  default): exit 130; 5 s later 0 processes in its group, nothing listening on 19830-19839, no `.r-lock`, 0 unfinished runs, the 7 captures unchanged. RED fix by a Claude Opus 5.5 agent on 2026-11-03.
