# c7-unit03 — Your First Entity and EntityManager

Course 7 · Data with JPA & Hibernate · Section 1 (ORM from First Principles), its third unit, and **the course's first change to the
anchor** · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.2** (Spring Framework 7.0.10, Hibernate ORM 7.4.13.Final,
Spring Data JPA 4.1.2, Jakarta Persistence 3.2.0, HikariCP 7.0.2, H2 2.5.250 — the anchor's own pin — Tomcat 11.0.27, Hibernate
Validator 9.1.5.Final), 2026-11-01. **H2, in memory, every capture**: no Postgres, no container, no native build. One class, one table
that already exists: TiffinBox's customer table, mapped as an **entity** (a class Hibernate maps to a table and keeps track of),
persisted through the `EntityManager` Spring injects, the SQL Hibernate wrote read off its own logger — and the second database the
starter would have opened, the table `ddl-auto` would have dropped, and the length two annotations must agree on, each measured.

**The anchor changes (brief ⚑1-⚑5).** `after/` is this unit's frozen copy of `../c7-tiffinbox` after the change, and the script
dies unless `diff -rq -x .m2-demo -x target -x secrets after ../c7-tiffinbox` is empty — it was, in every run of record:
`c7-tiffinbox` = `c7-unit03/after`, the tree units 04 and 05 read. "Before" is `before/`, the link to `../c6-unit31/after` — the tree
`c7-tiffinbox`'s setup commit copied; `move` reads `c7-tiffinbox` at `5c718e8` out of git and shows `before/` differs from it in
`README.md` alone. Both trees are copied under `.harness/` and built there, never in place. What changed (the anchor README's unit 03
section says it whole):

- `pom.xml` — `spring-boot-starter-parent` **4.1.1 → 4.1.2**, with a comment; the Framework comment amended (7.0.10).
- `tiffinbox-core/pom.xml` — `jakarta.persistence:jakarta.persistence-api`, no version (3.2.0, the parent's): annotations only, as
  Course 5 added `jakarta.validation-api`.
- `tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntity.java` (new) — `@Entity @Table(name = "customer")`, `@Id
  @GeneratedValue(strategy = GenerationType.IDENTITY) Long id`, `@NotBlank @Size(max = 60) @Column(length = 60, nullable = false, unique =
  true) String name`, `int mealsPerDay`, `int pricePerMeal`, `@Column(length = 10, nullable = false) String mealType`, a protected
  no-argument constructor, getters, one setter (`setMealsPerDay`).
- `tiffinbox-web/pom.xml` — `org.springframework.boot:spring-boot-starter-data-jpa`, with a comment.
- `tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java` — `@EntityScan("com.tiffinbox")` (Boot 4's class, in
  `spring-boot-persistence`: `org.springframework.boot.persistence.autoconfigure.EntityScan`), its Javadoc paragraph.
- `tiffinbox-web/src/main/resources/application.yaml` — three keys in the first document, each with a comment:
  `spring.datasource.url: ${tiffinbox.jdbc-url}`, `spring.jpa.hibernate.ddl-auto: none`, `spring.jpa.open-in-view: false`.
- `README.md` — the anchor's: its unit 03 section, the header's note, and two history notes the change made false (below).
- **Kept, unchanged, beside the entity** (R.180): `Customer` (the record), `CustomerRepository` (its SQL strings over
  `DriverManager`), `Database` (drop and re-seed at every start). The 18 tests are unchanged.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 11 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top and dies unless `java -version` and `javac -version` say 25; a bare `java`
on this Mac is 23.0.1.) It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first). **Start it in
a process group of its own** (a terminal's foreground job is one): `sweep()` stops only processes of its own group. `.m2-demo` must be
seeded first (below) — on a clone whose `.m2-demo` is empty each build runs once more without `-o`, and its `offline: no - …` line
names the artifact the offline build missed and the repositories the retry's log names ("The repository, and the network").

**Runs, each `env -i`** (`HOME` = a home of its own whose `.mavenrc` sets `-Duser.home` there and whose
`settings.xml` names only two dead proxies, `127.0.0.1:9` — so no Maven run could reach the network; `PATH=/opt/homebrew/bin:/usr/bin:
/bin:/usr/sbin:/sbin`; `http(s)_proxy` dead too), a session of its own, `.m2-demo` seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s1/` alone (6,608 files). On 2026-11-01 four development runs fixed the captures and
the checks (the last made every capture 3/3 and stopped at "no published hash" with every check passed; its md5s are `receipts.md5`),
then the first runs of record (431 s and 497 s) and one more 3.2 run (the first SIGINT attempt, whose SIGINT the launching shell had
set to ignored — below), each exit 0, all 11 = published. **The runs of record (2026-11-03, after the `offline:` label fix — For
RED), on the script as committed (`receipts.sh` md5 `ada579acd6b423ccbcbbdc646eaee6f9`): 589 s under `./receipts.sh`** (/bin/bash 3.2.57) **and 719 s
under `bash receipts.sh`** (Homebrew bash 5.3.9): each exit 0, all 11 captures 3/3 = published (every hash the one published on
2026-11-01), every check passed, each of the three builds `offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`; each
terminal log through `check_unit7.py 03 --runlog` — `0 grep error line(s)`, `RESULT (run logs): PASS` (the unit gate itself answers
"no 03-*.md … nothing to check": no script yet). **Nothing was downloaded** for this unit.

Published hashes: move `19c8b384c9bfd40fe044fe8780226bf5` · seven `ae7337b4dac2921d21a80a1039ba42ca` · two `021414a66ccdf513c5118fe6ee89afce` · entity `37bfba0b1cddf6aeb703b8b76aa742d5` · scan `26f0276adf60ed9fe591a5080a7bbcfa` · persist `e73efb7af239ff39ae514e508f2e6a20` · ddl `19b12999fc382025f087d5b67289c7f5` · ddlauto `fc47d316662b09827176ebdd005669ed` · osiv `2010bb05e48f434f6653fd67d4e27b97` · tests `cc1a5554ebaa44601802fd124742ef4d` · exercise `022321cac4c62e770d6e593178c4c4cf`.

### A sealed fresh clone — the recipe (R.129; RE-MEASURE 11, the course's first)

**Paste it into bash** (type `bash` first if your Terminal is zsh: zsh does not split the unquoted `$E`).

**Run (2026-11-03):** a `git clone` of tiffinbox-java at `cd9eac2` into a path **with a space** (`…/sealed 03 seeded/tiffinbox-java`),
with this unit's two edited files (`receipts.sh`, `README.md`) put in as git would take them (`git ls-files -co --exclude-standard`:
50 files under `c7-unit03/`, each `cmp`-equal to the working tree; `before` → `../c6-unit31/after` by `readlink`); a `file://`
copy of the seed (4,967 files: `_remote.repositories`, `*.lastUpdated` and `resolver-status.properties` left out); pre-flight: exit
1, 221 `Downloading from sealed: file://`, 0 from http(s); the clone's `.m2-demo` **seeded from that copy** (4,967 files — as
a viewer seeds it, "The repository" below); `/bin/bash` 3.2, `env -i`, a session of its own: **exit 0 in 602 s, all 11 =
published, every check passed**; each of the three builds said **`offline: yes · exit 0 · 'Downloaded from' lines in its log: 0`**;
after the run the clone's `.m2-demo` held 4,967 files (0 `_remote.repositories`). Its terminal log through `--runlog`: PASS.

```bash
S=/tmp/sealed03; W="/tmp/sealed 03"                # S: home, mirror, pre-flight (no space); W: the clone, a space in its path; T = your tiffinbox-java clone
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
cd "$W/tiffinbox-java/c7-unit03" && readlink before && rsync -a "$S/central/" .m2-demo/      # the clone's .m2-demo, seeded from the copy
$E ./receipts.sh            # a process group of its own
```

(The clone's own `c7-unit03/` and `c7-tiffinbox/` are the committed ones once this unit is in git; before its commit they were put in
as above.)

**An empty `.m2-demo` — the label, derived from the log (2026-11-03).** A second clone (`…/sealed 03 empty/tiffinbox-java`, the same
recipe without the seeding line): the first build printed `offline: no - the offline build could not resolve org.springframework.boot:spring-boot-starter-parent:pom:4.1.1 from .m2-demo, so it ran once more without -o; that run downloaded from: sealed (file) 617; of them over http(s): 0 · exit 0 · 'Downloaded from' lines in its log: 617`; the offline attempt's log (kept beside,
`.harness/build-before-offline.log`) names it: `Cannot access sealed (file://…) in offline mode and the artifact org.springframework.boot:spring-boot-starter-parent:pom:4.1.1 has not been downloaded from it before`; the next two builds `offline: no - the offline build could not resolve org.springframework.boot:spring-boot-starter-parent:pom:4.1.2 from .m2-demo, … sealed (file) 169; of them over http(s): 0` and `offline: no - the offline build could not resolve jakarta.persistence:jakarta.persistence-api:jar:3.2.0 from .m2-demo, … sealed (file) 73; of them over http(s): 0`; the clone's
`_remote.repositories`: 859 `>sealed=`, 0 `central`; then **exit 0 in 532 s, all 11 = published**; its terminal log
through `--runlog`: PASS. Each label names the one repository the retry's log names, the `file://` mirror `sealed`, and the count over
http(s), 0.

## The commands this unit adds

```bash
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "../hc:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 "${V[@]}"
javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/after/tiffinbox-web/target/extracted/lib/*" harness/src/probe/jpa/Probe.java harness/src/probe/jpa/Steps.java
sed 's#<version>4.1.1</version>#<version>4.1.2</version>#' pom.xml > pom.xml.new && mv pom.xml.new pom.xml
sed '/^@EntityScan("com.tiffinbox")$/d' after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java > .harness/ov-noscan/TiffinBoxApp.java
javac -parameters -d .harness/ov-noscan/classes -cp ".harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ov-noscan/TiffinBoxApp.java
sed '/^    open-in-view: false$/d' after/tiffinbox-web/src/main/resources/application.yaml > .harness/ov-noosiv/application.yaml
sed -e '/^    @Size(max = 60)$/d' -e 's/@Column(length = 60, /@Column(length = 61, /' after/tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntity.java > .harness/ctl1/CustomerEntity.java
sed -e 's/@Column(length = 60, /@Column(length = 61, /' after/tiffinbox-core/src/main/java/com/tiffinbox/CustomerEntity.java > .harness/ctl2/CustomerEntity.java
javac -parameters -d .harness/ctl1/classes -cp ".harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ctl1/CustomerEntity.java
javac -parameters -d .harness/ctl2/classes -cp ".harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/after/tiffinbox-web/target/extracted/lib/*" .harness/ctl2/CustomerEntity.java
curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":0,"mealType":"VEG"}' http://127.0.0.1:18431/customers
curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:18431/customers
```

The lines `receipts.sh` reads from the anchor's README (`after/README.md`, 10 lines, each asserted there whole) include this unit's
one: `java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
--spring.jpa.properties.jakarta.persistence.schema-generation.scripts.action=create
--spring.jpa.properties.jakarta.persistence.schema-generation.scripts.create-target=hibernate-ddl.sql` (the anchor's run line and the
two schema-generation options; the `ddl` capture passes those two options in `V`). Each line above is asserted, and the derived ones
are asserted to be an anchor line with one change: the pinned java line is the anchor's run line with the locale after `java`; **the
harness line** is the anchor's extracted-jar line (`java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:…/lib/*"
com.tiffinbox.web.TiffinBoxServer`) with the locale, `../hc:` first on the class path and `"${V[@]}"` after it — `V` is the run's
options array (R.193), printed as `$ V=(…)` before each run; an override (a class or a file ahead of the jar) is that line with one more
class-path entry first (`../ov-noscan/classes`, `../ov-noosiv`, `../ctl1/classes`, `../ctl2/classes`). The 61-letter and invalid POSTs
are the anchor's POST with the body changed. Every Maven line runs offline: `-o -B -Dmaven.repo.local="$M2"` after `mvn`, `clean` before
`package`. Every java line runs from `.harness/after` (or `.harness/before`, `.harness/move`), where a config tree holds the demo token.

## The repository, and the network

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../../data-jpa-hibernate/_research/m2-seed-c7-s1/` alone (6,608 files, 433 MB: both parents with and without the starter) before
each run of record. **Nothing was downloaded**: every build said `offline: yes` with 0 `Downloaded from` lines, the tests' log holds 0
`Downloading from` lines, and the runs' `HOME` named only dead proxies. A clone whose `.m2-demo` is empty (git ignores it) runs each
build once more without `-o`, and the `offline: no - …` line names the artifact the offline build missed, every repository the retry's
log says it downloaded from (id, URL scheme, count) and the count over http(s) — it never names a repository the log does not
(measured above). After the builds the script asserts `.m2-demo` holds
`spring-boot-starter-parent-4.1.2.pom`, `hibernate-core-7.4.13.Final.jar` and `spring-boot-starter-data-jpa-4.1.2.jar`. **At run time**
every request goes to `127.0.0.1`, and every database is H2 in the JVM's own memory, gone with it. **⚑1's re-sweep (4.1.3) was not run**:
this agent had no network; 4.1.2 stays measured as of the probe's 07:00 CET check (CARRIED below).

## The demo token

`TOKEN=` at the top of `receipts.sh` (31 characters), fake and meant to look it: it guards nothing but demo servers on 127.0.0.1 that every capture
stops. It is written into `.harness/*/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600, git-ignored) of every copy and sent
only by `../c5-unit11/curlset.sh` and `harness/shutdown.sh` on curl's standard input. Before every start the script lists that
`secrets/` folder (the token's file, nothing else — R.158), and a last check counts one listing per start. Every capture's raw output, the
log of every JVM (75 per run), every build log, every Surefire report and every file this unit ships: the token 0 times.

## The locale

Every java line carries `-Duser.language=en -Duser.country=US`; a last check refuses a capture's java line without it; the test fork's
comes from the POM's `argLine` (the reports say `en`/`US`). **The harness prints ASCII** (` | ` between facts): a JVM started under this
script's `LC_ALL=C` writes its standard output in ASCII, and the first development run printed the harness's `·` as `?`.

## The folders, the harness and the ports

- `after/` — the anchor after this change (= `../c7-tiffinbox`); `before` — the link to `../c6-unit31/after`. `.harness/before`,
  `.harness/move` (the previous tree, parent 4.1.2 — `L_MOVE`), `.harness/after` — copied, each with a config tree, built with the
  README's `mvn -B package` (each runs its 18 tests); after/'s jar extracted there (the anchor's own line, 91 libraries); `.harness/hc`
  — the harness, compiled; `.harness/at5c` — `c7-tiffinbox` at `5c718e8`, from `git archive`; `.harness/ov-noscan`, `.harness/ov-noosiv`,
  `.harness/ctl1`, `.harness/ctl2` — the labelled overrides; `.harness/tests` — `tests`' copy; `.harness/mine.log` — the exercise's log.
- **The harness** — the course's, never TiffinBox's (`harness/src/probe/jpa`, package `probe.jpa`, outside `com.tiffinbox`; a check
  refuses `probe.jpa` anywhere in after/'s code): `Probe` (`@Configuration @Import(Steps.class)`, joined by
  `--spring.main.sources=probe.jpa.Probe`) and `Steps`, an `ApplicationRunner` that does nothing unless the run sets
  **`--probe.steps`** (a Spring property, so it travels in `V`), runs the named steps in order, prints `PROBE` lines, then
  `System.exit(SpringApplication.exit(ctx))`. A step's exception is not caught (except `valid`'s): it ends the run as Boot ends a
  failed one — `Application run failed`, exit 1. The boundary is a `TransactionTemplate` over the context's transaction manager
  (`JpaTransactionManager`, spring-orm, printed by `props`); the EntityManager is the one Spring injects (`@PersistenceContext`); counts
  are Hibernate's `Statistics` (`hibernate.generate_statistics=true` in every harness run's `V`), cleared before each step that
  prints them. Steps: `ds` (the `DataSource` beans and each one's URL, `tiffinbox.jdbc-url`, the EMF's `hibernate.hbm2ddl.auto`),
  `props` (the EMF's `hbm2ddl.auto` and naming strategies, each with the jar its class loads from), `pkg` (Boot's auto-configuration
  packages), `anchor` (`CustomerRepository.findAll()`'s names), `query` (`select c.name from CustomerEntity c order by c.name`), `two`
  (persist Kavya, the id, the counts; does the anchor's repository see her), `persist` (the same with markers: before the transaction,
  after `persist()` before the commit, after the commit), `valid` (persist a 61-letter name; the exception and its violations; the
  counts; the anchor's names after it), `osiv` (the property and the `OpenEntityManagerInViewInterceptor` bean count). **Units 04 and 05
  copy these two files byte for byte (md5 asserted) and add classes of their own beside them.** `harness/shutdown.sh` (the CORS
  lesson's) and `harness/surefire.py` (the testing lesson's), byte for byte, `cmp`-checked.
- **Ports** (§P, 19820-19829): `move` 19820 · `seven` 19821 · `two` 19822 · `entity` and `scan` 19823 · `persist` 19824 · `ddl`
  19825 · `ddlauto` 19826 · `osiv` 19827 · `exercise` 19828 · 19829 never bound. Every JVM is waited for by its pid before the next on
  its port; a harness JVM exits by itself (bounded, 120 s), and the script asserts nothing listens on its port after it. 18425, 8080
  and 35729 checked free first and last; `tests` binds none.

## Masks, filters and hygiene — every one, declared

1. **`mask()`** (`gsub()`, literals escaped; checked first on a planted line): the token → `[masked: the 31-character token]`; this
   folder → `…`, the folder above → `…/..`, home → `~`, the user name → `<user>`; ` using Java <version>` (R.151; the JDK printed once on
   the terminal); **H2's generated database name → `jdbc:h2:mem:<uuid>`** (Boot names a new one every start); an identity hash → `@…`.
2. **A JVM's log** (`view`): in order, the harness's `PROBE` lines, the lines of the loggers each capture names (level, logger as Boot
   printed it, message; `Started TiffinBoxServer` without its seconds; Boot's `Starting …` line left to `hres`; a message cut at 260
   characters, trailing spaces dropped), and after `SpringApplication`'s `Application run failed` the exception's first line and each
   distinct `Caused by:` line (at most four); frames never. `jlog`: Hikari's `Added connection … url=` line (R.185), Hibernate's version
   line, the open-in-view WARN, WARN and ERROR lines counted. `hres`: the exit code and Boot's first line.
3. **A Maven log**: its `$` line, exit code, `BUILD` line, `offline` (its `Downloading from` lines counted); Surefire's reports
   (`surefire.py`) with the console's summary beside their sum (R.144); Hibernate's `Initialized JPA EntityManagerFactory` lines, the
   open-in-view WARN and `org.hibernate.SQL` lines counted; WARN and ERROR counted.
4. **Answers**: a JSON body keys sorted (`(keys sorted)`), Spring's timestamp `…`; a page its `<title>`; the seven as `curlset.sh` prints
   them; a DDL file every line.
5. **Hygiene, checked last over every capture**: no absolute path, no unit number, no Boot process line, no time or Boot's seconds, no
   log time, no thread number, no JDK/OS version token, no unmasked generated database name, no random port, no stack frame; every `$`
   line's URL 127.0.0.1's; every java line pinned; one `secrets/` listing per start; no `pkill`/`killall`; no bare `wait`; **no variable
   holding several options in one string** (R.193, in `receipts.sh`, this README and the exercise's two files); no harness class in
   `com.tiffinbox`. No duration is captured.

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the Maven it
waits for (`$mpid`, with every process under it — Surefire's fork — `killtree`), the exercise's shell (`$xpid`, with every process under
it), sweeps its own process group for any TiffinBox JVM, Maven or Surefire fork left, deletes the capture runs it had not finished
(`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched. No `wait` in the script or the exercise is bare.

**Measured (2026-11-01, on the script as committed):** `./receipts.sh` (/bin/bash 3.2) started in a session of its own **with SIGINT at
its default** (`signal.signal(SIGINT, SIG_DFL)` before `setsid`/`exec`), `kill -INT` to that group once the named process was in it,
the state read 5 s later — three trials, each **exit 130, nothing left**:

```
jvm: processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · java/surefire/maven of the run anywhere: 0 · ports listening 19300-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
fork: processes in the group at SIGINT 5 · exit 130 · 5 s later in the group: 0 · java/surefire/maven of the run anywhere: 0 · ports listening 19300-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
harness: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · java/surefire/maven of the run anywhere: 0 · ports listening 19300-20399: 0 · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
```

`jvm` — the previous tree's jar on 19820 (`move`, the seven's JVM); `fork` — Surefire's `surefirebooter` (the first build's tests);
`harness` — the `two` capture's harness JVM on 19822. **The first attempt was void**: started as a background job of a non-interactive
shell, the script inherited SIGINT *ignored* (a shell cannot trap a signal ignored at its start), so `kill -INT` did nothing and the run
went on to exit 0, all 11 = published. The trials above restore the default first.

## 1 · move — the previous tree, and the move alone (⚑1, R.80, R.70)

`before/` against `c7-tiffinbox` at `5c718e8` (`git -C .. archive`): files that differ — `README.md` alone (the setup's header). The
move: `.harness/move`, one line of the root `pom.xml` (`-    <version>4.1.1</version>` / `+    <version>4.1.2</version>`, hunks 1).
**Tests**, each tree's build: `TiffinBoxWebTest` 14, `FullStackTest` 3, `FeedTest` 1 — 18, failures 0, the console's summary the same
(R.144), the fork `en`/`US`. **`BOOT-INF/lib`**: 61 jars and 61, the same name and version 25, **a new version 36**, only in one 0 — each
listed with both versions: Hibernate Validator 9.1.3.Final → 9.1.5.Final, Jackson 3.1.5 → 3.1.7 (core, databind), SLF4J 2.0.18 → 2.0.20
(and `jul-to-slf4j`), Micrometer 1.17.1 → 1.17.2 (5 jars), Framework 7.0.9 → 7.0.10 (7 jars), Boot 4.1.1 → 4.1.2 (16 modules), Tomcat
11.0.24 → 11.0.27 (3 jars). **The seven** (fresh JVMs, first): `466c20ed7e0d5439cb052f32ce09de1b` on both, lines that differ 0, the
same 7 (each JVM logs one WARN, Spring MVC's `PageNotFound` for the seven's own `GET /shutdown`; no pool, no Hibernate). **The
extras** — the invalid customer's three messages (400, `the customer breaks 3 rules`), the 61-letter name's size message (400, `size
must be between 0 and 60`), `<title>Dashboard · TiffinBox</title>`, health `{"groups":["liveness","readiness"],"status":"UP"} 200`,
readiness `{"status":"UP"} 200` — 5 answers, md5 `bd7b9544f4f91ed215e599790972baa7` on both trees, the same: yes.

## 2 · seven — after/'s jar

The seven on after/'s jar (port 19821, a fresh JVM): `466c20ed7e0d5439cb052f32ce09de1b`, against the previous tree's (from `move`)
lines that differ 0, the same 7. The extras: the same answers, md5 `bd7b9544…`. Its pool: `HikariPool-1 - Added connection conn0:
url=jdbc:h2:mem:tiffinbox` — Boot's `DataSource` on TiffinBox's own database (R.185); `HHH000001: Hibernate ORM core version
7.4.13.Final`; the open-in-view WARN 0; the seven's JVM one WARN (the same `PageNotFound` as before the starter), the extras' 0; ERROR 0.

## 3 · two — which database Hibernate talks to (A/B/C/A′, ⚑2, R.173, R.185)

The harness, steps `ds,two,query`, Boot's condition report logger at DEBUG (one line read from it):
- **A** — after/: `HikariPool-1 … url=jdbc:h2:mem:tiffinbox`; `DataSource beans: 1 [dataSource]`, `dataSource -> jdbc:h2:mem:tiffinbox`;
  `hbm2ddl.auto = null`; **`persist: id 5 | statements 1 | inserts 1`**; **`anchor repo sees Kavya: true`**; the entity query `[Kavya,
  Meera, Priya, Ravi, Sunil]`; exit 0. Boot's condition report: `PooledDataSourceConfiguration matched - @ConditionalOnMissingBean
  (types: javax.sql.DataSource,javax.sql.XADataSource; SearchStrategy: all) did not find any beans` — TiffinBox never had a
  `DataSource`.
- **B** — A plus one option, `--spring.datasource.url=` (empty): `url=jdbc:h2:mem:<uuid>`; `hbm2ddl.auto = null`; **the failure
  receipt**: `Application run failed`, `org.hibernate.exception.SQLGrammarException: Could not prepare statement [Table "CUSTOMER" not
  found (this database is empty); …`, `Caused by: org.h2.jdbc.JdbcSQLSyntaxErrorException: …`, **exit 1** — the persist, on a second
  database with no customer table.
- **C** (labelled: two flips) — B plus `--spring.jpa.hibernate.ddl-auto=create-drop`: `hbm2ddl.auto = create-drop`, **`persist: id 1`**,
  **`anchor repo sees Kavya: false`**, the entity query `[Kavya]` — the INSERT landed where TiffinBox never looks; exit 0.
- **A′** — A again, line for line (its `$` lines too).

## 4 · entity — the class, @EntityScan, the EMF's properties (R.186, R.188)

`CustomerEntity`'s annotation and field lines with their numbers (26 `@Entity`, 27 `@Table(name = "customer")`, 31 IDENTITY, 35
`@Size(max = 60)`, 36 `@Column(length = 60, nullable = false, unique = true)`, …); core's POM `jakarta.persistence-api`, in the jar
`jakarta.persistence-api-3.2.0.jar`; `@EntityScan("com.tiffinbox")` and its import; the class `EntityScan` in
`spring-boot-persistence-4.1.2.jar`. The run (steps `pkg,props,query`, SQL at DEBUG): `auto-configuration packages: [com.tiffinbox.web]`;
`hbm2ddl.auto = null`; `physical_naming_strategy = …PhysicalNamingStrategySnakeCaseImpl (in hibernate-core-7.4.13.Final.jar)`;
`implicit_naming_strategy = org.springframework.boot.hibernate.SpringImplicitNamingStrategy (in spring-boot-hibernate-4.1.2.jar)`;
`transaction manager: org.springframework.orm.jpa.JpaTransactionManager (in spring-orm-7.0.10.jar)`; `select ce1_0.name from customer
ce1_0 order by ce1_0.name` → `[Meera, Priya, Ravi, Sunil]`.

## 5 · scan — an entity Boot does not scan (the failure receipt for a class change, R.186)

**B** (labelled) — `TiffinBoxApp` with the `@EntityScan` line deleted (`L_NOSCAN`, diff 1 line out), compiled
(`com/tiffinbox/web/TiffinBoxApp.class`), **ahead of the jar** on the class path (RE-MEASURE 15: the class override, not a built copy):
`Started TiffinBoxServer` (1 line — the context starts), `auto-configuration packages: [com.tiffinbox.web]`, then the query, not
caught: `Application run failed`, `java.lang.IllegalArgumentException: org.hibernate.query.sqm.UnknownEntityException: Could not
resolve root entity 'CustomerEntity'`, **exit 1**. **A′** — after/ as shipped, the same steps and run line minus the class-path entry:
exit 0, `[Meera, Priya, Ravi, Sunil]`.

## 6 · persist — the INSERT, before the commit (R.171, R.182, R.184, R.192)

Steps `anchor,persist,valid`, `org.hibernate.SQL` at DEBUG and `org.hibernate.orm.jdbc.bind` at TRACE (the loggers named in Hibernate
7.4.13's jar, brief READ FIRST 8), in the order the log printed them: the anchor's `[Meera, Priya, Ravi, Sunil]` (the 4 seeded rows,
read apart — RED #28); `before the transaction: id null`; **`DEBUG org.hibernate.SQL: insert into customer
(meal_type,meals_per_day,name,price_per_meal,id) values (?,?,?,?,default)`** and its four binds — `(1:VARCHAR) <- [VEG]`, `(2:INTEGER)
<- [2]`, `(3:VARCHAR) <- [Kavya]`, `(4:INTEGER) <- [110]`; **then** `after persist(), before commit: id 5 | contains true`; `after commit:
id 5 | statements 1 | inserts 1 | updates 0 | deletes 0 | flushes 1` (the SQL log's 1 line and `Statistics`' 1, R.184); `anchor repo sees
Kavya: true`. The INSERT's place, checked from the log: after "before the transaction", before "after persist(), before commit": yes
(IDENTITY inserts at `persist`). **The 61-letter name**: `jakarta.validation.ConstraintViolationException: Validation failed for classes
[com.tiffinbox.CustomerEntity] during persist time …`, `violation: name - size must be between 0 and 60`, **`statements 0`**, the anchor's
names after it unchanged (Kavya and the four).

## 7 · ddl — the DDL, the controls, and C7-5 (⚑7, R.174, R.194)

`Database.java` line 32: `name          VARCHAR(60) NOT NULL UNIQUE,`. **Shipped** (the anchor's two schema-generation options, a file,
never run — `DDL lines in the log: 0`): `create table customer (meals_per_day integer not null, price_per_meal integer not null, id
bigint generated by default as identity, meal_type varchar(10) not null, name varchar(60) not null unique, primary key (id));` — the
probe's line, character for character. **Control 1** (labelled; no `@Size`, `@Column(length = 61)`, ahead of the jar): `name
varchar(61)`. **Control 2** (labelled; `@Size(max = 60)` kept, `length = 61`): `name varchar(60)` — **the DDL file byte-identical to the
shipped one**: Hibernate takes the validator's limit for the column, so the DDL cannot keep the two annotations equal. **The C7-5 check**
(`javap -v -p` of the field `name`'s annotations, against Hibernate's DDL and `Database.java`): the shipped class (after/'s
`tiffinbox-core-1.0.0.jar`) → `C7-5: @Size(max=60) @Column(length=60) hibernate-ddl varchar(60) Database.java VARCHAR(60)` **PASS**;
the same check on control 2's class and its DDL — `length = 61` planted → `@Size(max=60) @Column(length=61) hibernate-ddl varchar(60)
Database.java VARCHAR(60)` **FAIL**, while its DDL stayed the shipped one. **C7-5 is paid** (the ledger's condition: the check, on the
shipped class, in this receipt).

## 8 · ddlauto — what ddl-auto would have done (⚑3, A/B/B2/A′, R.178, R.197)

Steps `ds,query`, SQL at DEBUG, each run its own JVM and its own in-memory database. **A** — after/: `hbm2ddl.auto = null`, **0** DDL
lines, the query `[Meera, Priya, Ravi, Sunil]`. **B** — `--spring.jpa.hibernate.ddl-auto=create-drop`: in order, `drop table if exists
customer cascade`, `create table customer (…)`, `Initialized JPA EntityManagerFactory`, **`Started TiffinBoxServer`**, `hbm2ddl.auto =
create-drop`, the query `[Meera, Priya, Ravi, Sunil]` (Database replaced Hibernate's table, and seeded it), **`Closing JPA
EntityManagerFactory for persistence unit 'default'`, then `drop table if exists customer cascade`** — TiffinBox's seeded table, at
shutdown; **3** DDL lines (the order checked against the two landmarks, R.197). **B2** — `validate`: `Failed to initialize JPA
EntityManagerFactory`, `Application run failed`, `Caused by: org.hibernate.tool.schema.spi.SchemaManagementException: Schema
validation: missing table [customer]`, **exit 1** (the factory is built before `Database` seeds). **A′** = A.

## 9 · osiv — open-in-view, by the interceptor bean (⚑4, A/B/B2/A′, R.194)

Step `osiv`; the check is "interceptor beans 0", printed PASS or FAIL per run, beside the WARN count (pattern ` WARN
.*spring\.jpa\.open-in-view is enabled by default`). **A** — after/: `property false | OpenEntityManagerInViewInterceptor beans 0`, PASS,
WARN 0. **B** — `--spring.jpa.open-in-view=true`: `property true | … beans 1`, **FAIL**, WARN **0** — the WARN alone could not tell `true`
from `false`. **B2** (labelled) — a copy of `application.yaml` without the key (`L_NOOSIV`, 1 line out), ahead of the jar: `property null
| … beans 1`, FAIL, WARN **1** (`JpaBaseConfiguration$JpaWebConfiguration: spring.jpa.open-in-view is enabled by default. …`). **A′** = A.

## 10 · tests — TiffinBox's tests (C7-4, R.144, R.190)

`cd .harness/tests && mvn -o -B -Dmaven.repo.local="$M2" clean test` (the anchor's `mvn -B clean test`, offline): exit 0, BUILD
SUCCESS, offline: yes; Surefire's reports `TiffinBoxWebTest` 14, `FullStackTest` 3, `FeedTest` 1 — **18**, failures 0, errors 0,
skipped 0; the console's summary the same; the fork `en`/`US`. In the tests' log: **2** `Initialized JPA EntityManagerFactory` lines (the
two full contexts), the open-in-view WARN 0, `org.hibernate.SQL` lines 0 — the 18 guard, they do not witness (none asks Hibernate
anything); WARN 1, ERROR 2 (the tests' own kitchen-on-fire cases, as before the change).

## 11 · exercise — the exercise, run as written, in one shell, bash then zsh (R.164, R.193, R.196)

`exercise/README.md`'s five lines, then `exercise/SOLUTION.md`'s (the README's with one line changed: `V` without
`--spring.datasource.url=`), each block sourced in one `env -i` shell (`HOME`, the `PATH` the script was started with), started in this
folder — `/bin/bash --noprofile --norc`, then `/bin/zsh -f`, a fresh JVM each half. In both shells: the README → `exit 1`,
`dataSource -> jdbc:h2:mem:<uuid>`, `org.hibernate.exception.SQLGrammarException: Could not prepare statement [Table "CUSTOMER" not found
(this database is empty); SQL statement:`; the solution → `exit 0`, `dataSource -> jdbc:h2:mem:tiffinbox`, `persist: id 5 | statements 1
| …`, `anchor repo sees Kavya: true`; the shell back in this folder, nothing listening on 19828; bash's and zsh's output the same.

## Exercise

**Your turn:** the README starts TiffinBox with one option too many, and Hibernate cannot find the customer table. Take it out.
(21 words.) `exercise/README.md` ships it broken (its options array ends with `--spring.datasource.url=`), `exercise/SOLUTION.md` beside
it; both measured by the `exercise` capture, broken ≠ solved (exit 1 ≠ exit 0).

## The anchor's README — what this unit changed in it

- **A new section**, `## Course 7 · unit 03 — the first entity: …`, above the rule, where Course 6's unit sections sat in theirs: the
  seven files, the three keys and why, the DDL line and why it alone cannot show the annotations agree, what the change leaves (the
  seven and the tests the same; two ways into one database; both restart causes standing; "measured without the `dev` profile").
- **The header** — a note: the parent is 4.1.2 since, with the starter and `CustomerEntity` beside `CustomerRepository`.
- **History notes made false, amended in place** (*Course 7, unit 03*): Course 5 unit 01's `spring-boot-starter-parent:4.1.1` /
  Framework 7.0.9 ("4.1.2 and 7.0.10 since"); Course 6 unit 31's tour line `@Entity: 0 each` ("one `@Entity` since"). The history notes
  that record a 4.1.1 measurement (banners, metadata, test-jar contents) stay as measured then.

## The ledger rows and hand-offs this unit pays

- **C7-5 — paid**: `@Size(max = 60)` and `@Column(length = 60)` on one field, read off the shipped class and checked equal to both DDLs;
  the check fails on a planted `length = 61`; the two controls; the 61-letter refusal, 0 statements.
- **C7-4 — re-run**: 18 from Surefire's XML after the move (`move`) and after the starter (`tests`), unchanged; carried to U39.
- **⚑1 — landed**: the pin moved, measured alone (`move`) and with the starter (`seven`).
- **C7-1 — named, not paid**: both causes stand (the URL is `jdbc:h2:mem:`, `Database` drops and re-seeds) — the anchor section says so.
- **C7-3 — untouched**: the `AUTO_INCREMENT` DDL stays; the entity maps IDENTITY onto it.

## RE-MEASURE — the brief's items this unit settles

| # | Settled here |
|---|---|
| 1 | `03/after` frozen = `c7-tiffinbox`; its comments and README written; every capture on it |
| 2 | B by the run option `--spring.datasource.url=`: `jdbc:h2:mem:<uuid>`, `Table "CUSTOMER" not found`, exit 1 (`two`, 3/3 × 3 runs) |
| 3 | `ddlauto` B/B2 as run options on `03/after`: start DROP+CREATE before `Started`, shutdown DROP after `Closing JPA EntityManagerFactory`; `validate` exit 1 |
| 4 | the two DDL controls on copies of `03/after`'s entity, ahead of the jar: 61 / 60 |
| 5 | health's `db` on `03/after`: **not measured** — unspoken |
| 11 | the seed from a sealed clone (2026-11-03): seeded, `offline: yes` on the three builds, 0 `Downloaded from`, exit 0; with an empty `.m2-demo`, 859 `>sealed=`, 0 `central`, exit 0 |
| 12 | 4.1.3's absence: **not re-swept** (no network for this agent) — CARRIED |
| 13 | open-in-view's witness: `false` 0, `true` 1, no key 1 (`osiv`) |
| 14 | the C7-5 check on the shipped class and its `length = 61` plant (`ddl`) |
| 15 | `scan` B: **the recompiled `TiffinBoxApp` ahead of the jar** (chosen; exit 1, the trio) |

## What differed from the brief

1. **`two`'s steps run the persist before the query** (`ds,two,query`), so B fails on the persist, as the brief says — and C's query,
   after the persist, reads **`[Kavya]`**, not the brief's `[]` (BLUE's `two-C` asked before persisting). A and A′ read `[Kavya, Meera,
   Priya, Ravi, Sunil]` for the same reason. Same fact: C's database holds only what Hibernate wrote there.
2. **The tests run with the anchor's own line, `mvn -B clean test`**, not the brief's `clean verify` (no `verify`-only plugin is bound;
   the same Surefire run, 18). The `package` builds of every tree run the same 18 too.
3. **The 61-letter refusal is in `persist`**, not `ddl` (one harness run carries the persist and the refusal).
4. **The harness takes `--probe.steps` as a Spring property** (it travels in `V`, R.193), where the probe and BLUE used a `-D` system
   property; and it **prints ` | ` between facts** (a JVM under `LC_ALL=C` writes ASCII — the first development run printed `·` as `?`).
5. **`move` shows more than the five families the brief names**: 36 of 61 jars at a new version, every one listed (Boot's 16 modules,
   Framework's 7, Micrometer's 5, Tomcat's 3, Jackson's 2, SLF4J's 2 — `jul-to-slf4j` among them — and Hibernate Validator).
6. **The seven's JVM logs one WARN on every tree** — Spring MVC's `PageNotFound`, `Request method 'GET' is not supported`, for the
   seven's own `GET /shutdown` — before and after the change alike; the brief said nothing of it.
7. **`ddlauto` B2's start fails with two ERROR lines**, `LocalContainerEntityManagerFactoryBean`'s `Failed to initialize JPA
   EntityManagerFactory` before Boot's `Application run failed`; the `Caused by` the brief names is the last of three.
8. **`move` reads `before/` against `c7-tiffinbox` at `5c718e8` out of git** (README alone differs) — the brief's "before = anchor at
   `5c718e8`" shown, not assumed; a clone without history cannot run this unit.
9. **⚑1's 4.1.3 re-sweep did not run** (this agent had no network); the move rests on the probe's 07:00 CET check.
10. **Boot's condition line** (`did not find any beans`) is printed in all four of `two`'s runs (one logger at DEBUG in every run's `V`,
    so A/B/C/A′ keep one flip each).
11. Health's `db` (RE-MEASURE 5) and the `dev` profile on Maven's class path (CARRIED to U39) were not measured.

## Planted faults — each caught (R.65)

In the captures, every run: `two` B (no URL) exit 1; `scan` B (no `@EntityScan`) exit 1; `ddl`'s control 2 (`length = 61`) — the C7-5
check FAIL; `osiv` B (`true`) and B2 (no key) — the bean check FAIL; `ddlauto` B2 (`validate`) exit 1. On a copy (the sealed clone,
its `receipts.md5` emptied so the run reaches the checks, after/ and `c7-tiffinbox` changed alike, then restored):
- **`open-in-view: true` planted in `application.yaml`** → `osiv` A reads `property true | … beans 1`, `the check (interceptor beans 0):
  FAIL`, WARN 0 — the run died `*** osiv A: expected the line: PROBE open-in-view: property false | OpenEntityManagerInViewInterceptor
  beans 0 ***` (exit 1, 385 s).
- **`@Column(length = 61)` planted on the shipped entity** → the shipped DDL still `name varchar(60)`; `ddl`'s C7-5 on the shipped class
  `@Size(max=60) @Column(length=61) hibernate-ddl varchar(60) Database.java VARCHAR(60)` FAIL; the run died at the first check that reads
  it, `*** entity: the mapping's lines: expected the line: 36:    @Column(length = 60, nullable = false, unique = true) ***` (exit 1, 391 s).
- **A wrong published hash** (`receipts.md5`'s `move` with its last digit changed) → `move … DIFFERS from the published …`, `*** move is
  not the published capture … ***` (exit 1, 68 s).

## Found on the way

- Hibernate's DDL lines end with a space (`drop table if exists customer cascade `): `view` drops trailing spaces.
- With `hibernate.generate_statistics=true` Hibernate logs a `Session Metrics` block (nanoseconds) at every session's end: never printed
  (only named loggers are).
- A JVM started under `LC_ALL=C` writes `?` for any character outside ASCII on its standard output (the harness's first separator);
  Boot's logs (Logback) wrote `·` correctly in the same run only because no log line held one.
- A background job of a non-interactive shell inherits SIGINT ignored: an interrupt trial must restore the default (above).

## CARRIED

- ⚑1's 4.1.3 / 4.2.0 re-sweep → the next agent with network (a dated `dependency:get`; found → stop and re-brief ⚑1).
- Two ways into one database (Hikari for Hibernate, `DriverManager` for `Database`/`CustomerRepository`) → the unit that retires
  `CustomerRepository`'s strings (Section 2/3's brief).
- `Database`'s seed and the `AUTO_INCREMENT` DDL (C7-1, C7-3) → Section 2's brief and the capstone.
- The `dev` profile on Maven's class path → U39's brief.

## For RED

Re-run from a clean tree (seeded `.m2-demo`, `HOME` with dead proxies) in a process group of its own; the plants above; ports
20200-20219 for any re-run of this unit's JVMs outside its script. Evidence by an Opus 5.5 agent on 2026-11-01.

- **2026-11-03:** the `offline:` label was a fixed sentence (`Maven Central was asked`) while the only repository the log names was
  the `file://` mirror; replaced by the derived label (unit 05's `mbuild`); captures unchanged (hashes equal); runs of record re-done.
  `receipts.sh` changed in two places only: the header's "The network" comment and `mbuild` (with its comment; `grep` there is
  `/usr/bin/grep`); the label line is printed on the terminal, outside every capture. The sealed recipe now seeds the clone's
  `.m2-demo` from the `file://` copy (above), and its seed path is `"$T/../../data-jpa-hibernate/…"` (it read `"$T/../…"`, a folder
  that does not exist; the seed's path from this folder is `../../../data-jpa-hibernate/…`, as unit 04's and 05's READMEs say).
  **Plant** (a copy, `.m2-demo` empty, a `settings.xml` whose mirror is a dead `http://127.0.0.1:9/` repository): the first build's offline attempt failed, and the retry's log holds one `Downloading from dead: http://127.0.0.1:9/…/spring-boot-starter-parent-4.1.1.pom` line, `Could not transfer artifact org.springframework.boot:spring-boot-starter-parent:pom:4.1.1 from/to dead (http://127.0.0.1:9/)` and 0 `Downloaded from` lines; no `offline:` line was printed — the run died `*** build failed: .harness/before (…) - Maven could resolve Boot's parent and plugins neither from .m2-demo nor from a repository it could reach: … ***` (exit 1, 3 s). No line of the run names a repository its log does not.
  **SIGINT** during a build's Maven (bash 3.2, a session of its own, SIGINT at its default): exit 130; 5 s later 0 processes in its group, nothing listening on 19820-19829, no `.r-lock`, 0 unfinished runs, the 11 captures unchanged. RED fix by a Claude Opus 5.5
  agent on 2026-11-03.
