# c6-unit32 — What's Next: Where the Data Lives

Course 6 · Spring Web MVC · Section 6 (Close), its last unit, and the course's · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16,
Spring Boot 4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, H2 2.5.250 from the anchor's jar), curl 8.7.1, 2026-10-30. The finale:
where TiffinBox keeps its customers, measured on the tree the next course starts from — add a customer, restart, and she is gone —
which repository class and which database URL the next course's first lesson names, and the repository's front page, which now names
this course. The course's counts (lessons, sections, courses, the next course and its titles) and what the course measured (captures,
rules, tests) are read by the deck's builder on the day (below: "Not captured here").

**No anchor change (brief ⚑4).** The tree is `../c6-unit31/after` (= `c6-tiffinbox`; `diff -rq -x target ../c6-tiffinbox
../c6-unit31/after` was empty when this unit was measured), reached through the link `anchor`, copied under `.harness/` and built
there, never in place. **Three files outside this folder change, in this unit's commit (⚑11, R.163):** the repository's root
`README.md` (Course 6 joins its title, its folder map and its sections; the roadmap line unchanged), and Course 5's finale's
`../c5-unit30/receipts.sh` (its `readme` capture pinned to the commit before this unit's, `0458d2b`), `receipts.md5` (that capture's
md5) and `README.md` (told: the repository README has moved past that unit, R.73). Course 5's video is unchanged.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 2 captures, 3 runs each; every spoken number from them asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.) No GraalVM, no Docker,
no stub. It **dies** when a capture's md5 differs from `receipts.md5`. It needs a **full clone**: `readme` reads the README as commit
`0458d2b` had it, with `git show`, and runs Course 5's finale's `readmecap` from `../c5-unit30/receipts.sh` (which reads that commit
and `53379bd`). **Start it in a process group of its own** (a terminal's foreground job is one): its clean-up sweeps its own group.

**Re-run by BLUE S6 (2026-10-30), because `memory` reads `../c6-unit31/after`, whose README changed (R.104):** 57 s under
`./receipts.sh` and 59 s under `bash receipts.sh`, each exit 0, both captures 3/3 = published (`5673a150…`, `4e4241dd…`), no `grep:` line;
and **a sealed fresh clone** by the recipe below (a clone of `b50b410` with the 17 files BLUE S6 changed put in, each `cmp`-equal;
pre-flight exit 1, 221 `Downloading from sealed: file://`, 0 http(s)): **exit 0 in 60 s, both = published; `_remote.repositories` by
repository id: 604 `>sealed=`, 0 `central`; build logs 604 `Downloaded from sealed`, 0 http(s)**. **Runs of record (2026-10-30), each in a process group of its own, `.m2-demo` seeded from `_research/m2-seed-s6/` alone, on the
script as committed: 53 s under `./receipts.sh`** (/bin/bash 3.2.57) **and 53 s under `bash receipts.sh`** (Homebrew bash 5.3.9):
each exit 0, both captures 3/3 = published, every check passed, every build `offline: yes`. Development runs before them fixed the
captures and the checks (20 planted faults against the checks, each caught — "Planted faults" below).

Published hashes: memory `5673a1507c1e1980401d21adb4b3e504` · readme `4e4241ddf3eb8a044c7762a1938ee54f`.

### A sealed fresh clone — the recipe (R.129; unit 31's form)

**Paste it into bash** (type `bash` first if your Terminal is zsh): zsh does not split the unquoted `$E`, so the pre-flight would print
`NOT SEALED` — safe, but for the wrong reason (RED S6 #550).

**Run (2026-10-30):** a `git clone` of tiffinbox-java at `0458d2b`, with `c6-unit32/`, the root `README.md` and `c5-unit30/` put
in as git would take them (`git ls-files -co --exclude-standard`: 13 files, each `cmp`-equal to the working tree; `anchor` →
`../c6-unit31/after` by `readlink`); a `file://` copy of the seed (4,441 files); pre-flight: exit 1, 221 `Downloading from sealed:
file://`, 0 from http(s); `/bin/bash` 3.2, `env -i`, a group of its own: **exit 0 in 54 s, both = published, every check passed**;
the first build said `offline: no` (an empty `.m2-demo`, filled from the sealed mirror); `_remote.repositories` by repository id:
**604 `>sealed=`, 0 `central`**; build logs: 604 `Downloaded from sealed`, 0 from http(s).

```bash
S=/tmp/sealed-32                                   # an empty folder of your own; T = your tiffinbox-java clone
mkdir -p "$S/home/.m2" && git clone -q "file://$T" "$S/tiffinbox-java"
rsync -a --exclude _remote.repositories --exclude '*.lastUpdated' --exclude resolver-status.properties "$T/../spring-web-mvc/_research/m2-seed-s6/" "$S/central/"   # or this unit's .m2-demo
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
X=http://127.0.0.1:9; E="env -i HOME=$S/home PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin http_proxy=$X https_proxy=$X HTTP_PROXY=$X HTTPS_PROXY=$X no_proxy=127.0.0.1,localhost NO_PROXY=127.0.0.1,localhost"
$E JAVA_HOME=/opt/homebrew/opt/openjdk@25 mvn -B -Dmaven.repo.local="$S/preflight-m2" org.apache.maven.plugins:maven-dependency-plugin:3.8.1:get -Dartifact=org.example.sealed:absent:1 > "$S/preflight.log" 2>&1
[ $? != 0 ] && grep -q 'Downloading from sealed: file://' "$S/preflight.log" && ! grep -qE 'Downloading from [^ ]+: https?://' "$S/preflight.log" && echo "sealed: file:// only" || echo "NOT SEALED - do not run receipts.sh"
cd "$S/tiffinbox-java/c6-unit32" && readlink anchor && $E ./receipts.sh            # a process group of its own
find .m2-demo -name _remote.repositories -exec cat {} + | grep -o '>[^=]*=' | sort | uniq -c     # every line sealed; 0 central
```

## The commands this unit adds

The anchor README's run line with the JVM's locale pinned (S6.1); its POST line with Kavya's customer (the capstone's `FeedTest`
adds the same one); its `/customers/Ravi` line asking for Kavya:

```
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Kavya","mealsPerDay":1,"pricePerMeal":100,"mealType":"VEG"}' http://127.0.0.1:18431/customers
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers/Kavya
```

C (labelled): the same run line with Course 2's database URL by TiffinBox's own key, `--tiffinbox.jdbc-url` (RED S6 #545; Boot's would be `spring.datasource.url`, and TiffinBox has no DataSource), and H2's own shell reading that file between the JVMs
(`$H2`: the H2 jar the anchor's jar carries, from `.m2-demo`):

```
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --tiffinbox.jdbc-url=jdbc:h2:./data/tiffinbox
java -Duser.language=en -Duser.country=US -cp "$H2" org.h2.tools.Shell -url jdbc:h2:./data/tiffinbox -user sa -sql 'SELECT name FROM customer ORDER BY name'
```

The script asserts each derived line against the anchor README's: the locale after `java`, Kavya's customer for Asha's, Kavya for
Ravi, the one key for C — one change each, nothing else.

## The repository, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2`), seeded from `../../spring-web-mvc/_research/m2-seed-s6/`
alone (5,926 files; no `com/tiffinbox`). **Nothing was downloaded** for this unit: every build said `offline: yes`. H2's shell runs
from the H2 jar the anchor's jar carries (`BOOT-INF/lib/h2-2.5.250.jar`, read off the jar), found in `.m2-demo`.

## The demo token — fake, and never printed

`TOKEN` in `receipts.sh` (32 characters, fake, and meant to look it; never printed here): written into `.harness/serve/secrets/tiffinbox/shutdown-token` (the config
tree, git-ignored) when the script runs; `$CURLSET` and `harness/shutdown.sh` read it from that file. Every capture masks it
(`[masked: the 32-character token]`); the checks count 0 raw copies in every capture's three raw runs, in every JVM's log (with
`X-Shutdown-Token`: 0), in this README, the harness, `receipts.md5` and the repository's README. Before every start the script lists
`secrets/`: the token's file, and nothing else (R.158).

## The folders, the names and the ports

- `anchor` → `../c6-unit31/after` (a link, committed). `.harness/serve/` — the tree with a config tree, built once with the README's
  `mvn -B package` (offline, `-DskipTests clean`: the tests are the capstone's capture). C's file database lands in
  `.harness/serve/data/` and is removed before each C.
- `$CURLSET` = `../c5-unit11/curlset.sh` (the seven) · `$C2` = `../c2-unit38` (Course 2's *TiffinBox on a Real Database: The JDBC
  Repository*) · `$C5` = `../c5-unit30` (Course 5's *What's Next: The Web Layer*) · `$H2` = the H2 jar in `$M2` · `$PIN` = `0458d2b`.
- `harness/shutdown.sh` — POST /shutdown with the token read from its file (the CORS lesson's, `cmp` with `../c6-unit19/harness/`).
  `harness/sql.py` — the SQL counter: reads a Java source as Java's tokens split it (comments skipped, a literal and a text block
  each one string) and counts the strings whose text starts with an SQL statement's first word, per file, with each statement and the
  tables a `CREATE TABLE` names.
- Ports (brief ⚑1): the first JVM 19610, the restart 19611, the seven's fresh JVM 19612 (C reuses 19610 and 19611, each checked free
  before its start); **19619 never bound** (asserted free at the start and the end); 18425, 8080 and 35729 checked free, never bound.

## Masks, filters and hygiene — every one, declared

The token (above); this folder's path `…`, the folder above it `…/..`, the home folder `~`, the user name `<user>`; ` using Java
<version>` in Boot's first line (the version printed on the terminal once, R.151); Tomcat's connector `http-nio-127.0.0.1-<port>`
(S6.22); a problem detail's or Boot's error `timestamp` `…`. A JVM's log: Boot's first line, WARN and ERROR counted (the seven's JVM
logs one WARN: its 405, Course 6's known line). A JSON answer is its bytes with keys sorted. **H2's shell prints `(N rows, T ms)`: the
row count is kept, the time cut** (`(N rows)`; no duration is captured, ⚑10). `harness/sql.py`'s output is filtered to the files that
hold SQL, the files read and the sum printed beside them (S6.6). The last checks refuse, in any capture: an absolute path, a unit
folder or number, Boot's process line, a log line's time, a stack frame, ` using Java [0-9]`, a connector's port, `offline: no`, a
`java` line without `-Duser.language=en -Duser.country=US`.

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`) and the Maven
it waits for (`$mpid`), sweeps its own process group for any TiffinBox JVM or Maven left, deletes the capture runs it had not finished
(`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched. No `wait` is bare.

**Measured (2026-10-30):** SIGINT to the run's process group once a JVM listened — under `./receipts.sh` and under `bash
receipts.sh`, each during the seven's JVM (19612) and during the first JVM (19610): **exit 130** each time, 0 processes left in its
group, the JVM gone, 19610-19612 and 19619 free, no `.r-lock`, no partial capture; the published captures unchanged.

## Planted faults (S6.10)

Each check this unit adds was shown failing before it counted. **`receipts.sh`, 20 of 20 caught** (a published capture corrupted in a
copy, the checks run, the capture restored and its md5 re-checked): Kavya `200` after the restart · an extra list in the restart · the
restart's command with another option · the seven's md5 · the anchor's URL a file · `JdbcCustomerRepository.java` in the anchor ·
`Database` typed as the brief's 2 · C's file without Kavya between the JVMs · C's shell time uncut · a fourth list in C · a `java` line
without the locale · ` using Java 25.0.4.1` unmasked · a unit folder in a capture · no Course 6 section · no `c6-unitNN/` · the roadmap
line changed · Course 5's capture unpinned (0 pinned lines) · Course 5's function reading `../README.md` · Course 5's re-run off its
published md5 · the title without *Spring Web MVC*. Two checks missed their first plant and were fixed (a count of the lists per
JVM; the shell-time check moved ahead of the rows checks). **The builder, 9 of 9:** a count typed as digits on a slide · as words in
the voice (S6.33) · the next course's class named as the anchor's (R.162) · Course 5's finale's count changed · one of its titles
changed (C6-13) · the README's Course 6 count changed · a duration word · a patch number spoken · an unpublished capture. **Course
5's receipt unpinned against the changed README: 1 of 1** (above). **30 in all.**

## 1 · memory — where the data lives

The anchor's database URL (`application.yaml`): `jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1` — **in memory**: the database lives inside
the JVM. The SQL is written by hand: `CustomerRepository` **5** strings (4 SELECT, 1 INSERT), `Database` **6** (2 DROP TABLE, 2
CREATE TABLE, 2 INSERT) — 11 in 2 of 18 sources. The anchor's repository is `CustomerRepository`, a `@Component`; there is no
`JdbcCustomerRepository` in it (0 files, 0 mentions). Course 2's *TiffinBox on a Real Database: The JDBC Repository* (`$C2`) built
`JdbcCustomerRepository` on `Db.URL = "jdbc:h2:./data/tiffinbox"` — **a file** — and that is the class the next course's first lesson
puts on screen (the roadmap, read by the builder; R.162). Then the seven, first, on a fresh JVM: `466c20ed…`, the capstone's. **A**,
the first JVM (19610): 4 names → Kavya `201` → 5 names → Kavya `200`. **The restart** (19611, the same command, its port aside): 4
names, Kavya `404` (TiffinBox's problem detail). **C (labelled)**: the same two runs with Course 2's URL by key — Kavya `201`, 5
names; between the JVMs H2's own shell reads the file: **5 rows, Kavya among them**; the restart: 4 names, Kavya `404`; the file then
**4 rows**. `Database`'s `@PostConstruct` drops both tables and seeds four customers at every start: **on this tree a restart loses
Kavya twice over — the memory, and the start.**

`.r-memory.out` · md5 `5673a1507c1e1980401d21adb4b3e504` · 3 of 3

```
the anchor's database - its URL, as its application.yaml gives it:
$ grep -n 'jdbc' anchor/tiffinbox-web/src/main/resources/application.yaml
  3:  jdbc-url: jdbc:h2:mem:tiffinbox;DB_CLOSE_DELAY=-1
the SQL TiffinBox writes by hand - every Java source of the anchor read by harness/sql.py, the files that hold any:
$ python3 harness/sql.py anchor/tiffinbox-core/src/main/java/com/tiffinbox/*.java anchor/tiffinbox-web/src/main/java/com/tiffinbox/web/*.java
  CustomerRepository.java: 5 SQL strings
    SELECT name, meals_per_day, price_per_meal, meal_type FROM customer ORDER BY name
    SELECT name, meals_per_day, price_per_meal, meal_type FROM customer WHERE name = ?
    INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?)
    SELECT SUM(meals_per_day * price_per_meal * 30) FROM customer
    SELECT COALESCE(SUM(days), 0) FROM pause
    the tables its CREATE TABLE strings make: 0
  Database.java: 6 SQL strings
    DROP TABLE IF EXISTS pause
    DROP TABLE IF EXISTS customer
    CREATE TABLE customer ( id BIGINT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(60) NOT NULL UNIQUE, meals_per_day INT NOT NULL, price_per_meal INT NOT NULL, meal_type VARCHAR(10) NOT NULL )
    CREATE TABLE pause ( id BIGINT AUTO_INCREMENT PRIMARY KEY, customer_id BIGINT NOT NULL REFERENCES customer(id), days INT NOT NULL )
    INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?)
    INSERT INTO pause (customer_id, days) SELECT id, ? FROM customer WHERE name = ?
    the tables its CREATE TABLE strings make: 2 - customer, pause
  files read: 18 · files that hold SQL: 2 · SQL strings in all: 11
the anchor's repository class - its declaration and the annotation above it:
$ grep -n -B1 '^public .*class CustomerRepository' anchor/tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java
  11-@Component
  12:public final class CustomerRepository {
  files named JdbcCustomerRepository.java in the anchor: 0 · the name JdbcCustomerRepository in its sources: 0 files
Course 2's JDBC lesson ($C2) - its title, its repository class, its database's URL:
$ sed -n 1p $C2/README.md | sed 's/^# [^ ]* - //; s/^# [^ ]* — //; s/ (JDK.*$//'
  TiffinBox on a Real Database: The JDBC Repository
$ grep -n '^public .*class JdbcCustomerRepository' $C2/src/main/java/JdbcCustomerRepository.java
  12:public final class JdbcCustomerRepository implements Repository<Customer, Long> {
$ grep -n 'String URL' $C2/src/main/java/Db.java
  17:    public static final String URL  = "jdbc:h2:./data/tiffinbox";
  which is which: the anchor's in memory (jdbc:h2:mem:) · Course 2's a file (jdbc:h2:./ - a path on disk)
the seven, first, on a fresh JVM (port 19612):
  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else
$ cd .harness/serve && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19612
  listens on: 127.0.0.1:19612 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19612/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19612 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times · WARN lines: 1 · ERROR lines: 0
the first JVM (port 19610) - the customers; Kavya added; the customers; Kavya:
  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else
$ cd .harness/serve && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19610
  listens on: 127.0.0.1:19610 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19610/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19610/customers
  [{"mealType":"NON_VEG","mealsPerDay":1,"name":"Meera","pricePerMeal":150},{"mealType":"VEGAN","mealsPerDay":1,"name":"Priya","pricePerMeal":120},{"mealType":"VEG","mealsPerDay":2,"name":"Ravi","pricePerMeal":120},{"mealType":"VEG","mealsPerDay":3,"name":"Sunil","pricePerMeal":100}] 200    (keys sorted)
  its names: Meera Priya Ravi Sunil · 4 customers · 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Kavya","mealsPerDay":1,"pricePerMeal":100,"mealType":"VEG"}' http://127.0.0.1:19610/customers
  {"mealType":"VEG","mealsPerDay":1,"name":"Kavya","pricePerMeal":100} 201    (keys sorted)
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19610/customers
  [{"mealType":"VEG","mealsPerDay":1,"name":"Kavya","pricePerMeal":100},{"mealType":"NON_VEG","mealsPerDay":1,"name":"Meera","pricePerMeal":150},{"mealType":"VEGAN","mealsPerDay":1,"name":"Priya","pricePerMeal":120},{"mealType":"VEG","mealsPerDay":2,"name":"Ravi","pricePerMeal":120},{"mealType":"VEG","mealsPerDay":3,"name":"Sunil","pricePerMeal":100}] 200    (keys sorted)
  its names: Kavya Meera Priya Ravi Sunil · 5 customers · 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19610/customers/Kavya
  {"mealType":"VEG","mealsPerDay":1,"name":"Kavya","pricePerMeal":100} 200    (keys sorted)
$ harness/shutdown.sh 19610 .harness/serve/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19610 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times · WARN lines: 0 · ERROR lines: 0
the restart - the same tree, the same jar, a new JVM (port 19611) - the customers; Kavya:
  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else
$ cd .harness/serve && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19611
  listens on: 127.0.0.1:19611 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19611/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19611/customers
  [{"mealType":"NON_VEG","mealsPerDay":1,"name":"Meera","pricePerMeal":150},{"mealType":"VEGAN","mealsPerDay":1,"name":"Priya","pricePerMeal":120},{"mealType":"VEG","mealsPerDay":2,"name":"Ravi","pricePerMeal":120},{"mealType":"VEG","mealsPerDay":3,"name":"Sunil","pricePerMeal":100}] 200    (keys sorted)
  its names: Meera Priya Ravi Sunil · 4 customers · 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19611/customers/Kavya
  {"detail":"no customer named Kavya","instance":"/customers/Kavya","name":"Kavya","status":404,"title":"Customer not found"} 404    (keys sorted)
$ harness/shutdown.sh 19611 .harness/serve/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19611 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times · WARN lines: 0 · ERROR lines: 0
C (labelled) - the same two JVMs, the database a file: Course 2's URL by flag, one more option on the same run line:
  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else
$ cd .harness/serve && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19610 --tiffinbox.jdbc-url=jdbc:h2:./data/tiffinbox
  listens on: 127.0.0.1:19610 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19610/actuator/health/readiness
  {"status":"UP"} 200
  its names: Meera Priya Ravi Sunil · 4 customers · 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Kavya","mealsPerDay":1,"pricePerMeal":100,"mealType":"VEG"}' http://127.0.0.1:19610/customers
  {"mealType":"VEG","mealsPerDay":1,"name":"Kavya","pricePerMeal":100} 201    (keys sorted)
  its names: Kavya Meera Priya Ravi Sunil · 5 customers · 200
$ harness/shutdown.sh 19610 .harness/serve/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19610 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times · WARN lines: 0 · ERROR lines: 0
  the folder data/ now: tiffinbox.mv.db
between the two JVMs - the file, read by H2's own shell ($H2: the H2 jar the anchor's jar carries, from $M2):
$ cd .harness/serve && java -Duser.language=en -Duser.country=US -cp "$H2" org.h2.tools.Shell -url jdbc:h2:./data/tiffinbox -user sa -sql 'SELECT name FROM customer ORDER BY name'
  NAME
  Kavya
  Meera
  Priya
  Ravi
  Sunil
  (5 rows)
  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else
$ cd .harness/serve && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19611 --tiffinbox.jdbc-url=jdbc:h2:./data/tiffinbox
  listens on: 127.0.0.1:19611 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19611/actuator/health/readiness
  {"status":"UP"} 200
  its names: Meera Priya Ravi Sunil · 4 customers · 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19611/customers/Kavya
  {"detail":"no customer named Kavya","instance":"/customers/Kavya","name":"Kavya","status":404,"title":"Customer not found"} 404    (keys sorted)
$ harness/shutdown.sh 19611 .harness/serve/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19611 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times · WARN lines: 0 · ERROR lines: 0
after the restart - the file, read again:
$ cd .harness/serve && java -Duser.language=en -Duser.country=US -cp "$H2" org.h2.tools.Shell -url jdbc:h2:./data/tiffinbox -user sa -sql 'SELECT name FROM customer ORDER BY name'
  NAME
  Meera
  Priya
  Ravi
  Sunil
  (4 rows)
  listening on 19610, 19611, 19612 now: 0 · on 19619: 0
```

## 2 · readme — the repository's front page, and Course 5's capture of it

The root README as `0458d2b` (the commit before this unit's: Course 6's capstone) had it and as it is now: the title gains *Spring
Web MVC*, the folders its opening maps gain `c6-unitNN/`, the course sections 2-5 gain 6, the roadmap line is the same; this unit's
`## Course 6 — Spring Web MVC` section, whole. Then Course 5's finale's capture of those same lines (`$C5`): its receipt reads `0458d2b`
on 7 lines and `../README.md` on 0 inside its `readmecap`; that function, re-run from its own folder, hashes to its published
`4456fd19…` — the README Course 5 left, still measured.

`.r-readme.out` · md5 `4e4241ddf3eb8a044c7762a1938ee54f` · 3 of 3

```
the repository's README, as the commit before this unit's had it (the last commit of Course 6's capstone):
$ git -C .. show 0458d2b:README.md
  line 1: # TiffinBox — code for *Java Fundamentals*, *Core Java II*, *Build & Test Like a Pro*, *Spring Framework Core* and *Spring Boot* (Learn Programming with Vivek)
  the folders its opening maps (lines 1-5): unitNN/ c2-unitNN/ c3-unitNN/ c4-unitNN/ c5-unitNN/
  its course sections: 2 3 4 5
  its roadmap line: 456:Videos publish a few per day on the channel. Roadmap (19 courses): Java Fundamentals → Core Java II → Build & Test Like a Pro → Spring Framework Core → Spring Boot → Spring Web MVC → Data with JPA & Hibernate → … → Spring AI.
and as it is now:
$ cat ../README.md
  line 1: # TiffinBox — code for *Java Fundamentals*, *Core Java II*, *Build & Test Like a Pro*, *Spring Framework Core*, *Spring Boot* and *Spring Web MVC* (Learn Programming with Vivek)
  the folders its opening maps (lines 1-5): unitNN/ c2-unitNN/ c3-unitNN/ c4-unitNN/ c5-unitNN/ c6-unitNN/
  its course sections: 2 3 4 5 6
  its roadmap line: 463:Videos publish a few per day on the channel. Roadmap (19 courses): Java Fundamentals → Core Java II → Build & Test Like a Pro → Spring Framework Core → Spring Boot → Spring Web MVC → Data with JPA & Hibernate → … → Spring AI.
  the roadmap line, the same before and now: yes
  lines the README gained: 10 · lines it lost: 3
its Course 6 section, whole:
  ## Course 6 — Spring Web MVC
  **TiffinBox on Spring MVC**, in `c6-unitNN/` (32 units, 6 sections), with the long-lived project in `c6-tiffinbox/`: TiffinBox's own
  HTTP server handed over to Spring MVC on embedded Tomcat, one job at a time — the servlet layer, controllers and binding, errors,
  pages, forms and the rest of MVC, calling other services, and a capstone with a bulk upload and an event stream. The same layout as
  Courses 4 and 5: a README and a `receipts.sh` per unit. `c6-tiffinbox/` is the tree the next course, *Data with JPA & Hibernate*,
  starts from.
Course 5's finale's readme capture ($C5) - the README reads in its receipts.sh, and its readme function re-run from there:
$ grep -c 'git -C \.\. show 0458d2b:README.md' $C5/receipts.sh
  7
$ sed -n '/^readmecap() {/,/; }$/p' $C5/receipts.sh | grep -c '\.\./README\.md'
  0
  its readme function, run in its own folder: 12 lines · md5 4456fd199c0cc10b1647683ea7526015 · its receipts.md5's readme: 4456fd199c0cc10b1647683ea7526015 · the same: yes
  its title line, as it reads it: # TiffinBox — code for *Java Fundamentals*, *Core Java II*, *Build & Test Like a Pro*, *Spring Framework Core* and *Spring Boot* (Learn Programming with Vivek)
```

## Not captured here — the builder's, read on the day (contract §6c, R.63, S6.33)

`spring-web-mvc/_builders/s632.py` reads: **32 lessons, 6 sections** and the six section names (`java6_series.py`), checked against the
roadmap's own Course 6 heading; **19 courses** and the next one, ***Data with JPA & Hibernate*, 40 units, 7 sections**, its first
titles (*The Object-Relational Mismatch, Named*; *JPA, Hibernate, Spring Data: Three Different Things*; *Your First Entity and
`EntityManager`*) and its section *Schema and lifecycle* (`TRACK-ROADMAP.md`, md5 `63dddfbe3102c1e555fe6c96b9b787ea` at build);
**235 captures** in the 31 earlier units' `receipts.md5` (per section: The Servlet Layer 35 · Controllers and Binding 71 · Errors Done
Right 28 · The Rest of MVC 49 · Calling Out 27 · Close 25), each `cap()` running each capture 3 times (read off every `receipts.sh`);
**151 rules** (STYLE-CONTRACT §R, R.1-R.151, one line each, at this unit's build — **170 since BLUE S6**, R.1-R.170, re-read 2026-10-30); **18 tests** from the capstone's published `tests` capture (TiffinBoxWebTest
14, FullStackTest 3, FeedTest 1; `../c6-unit31/.r-tests.out` `c26600790ea89fa1651ed25aeda554e7`). **C6-13:** Course 5's finale slide
reads "32 lessons, 6 sections" and names 8 titles; each equals today's — nothing to correct. None of these files but the last is in this
repository, so no receipt can read them on a clone; the builder refuses any of those counts typed into a slide or a spoken line (its
own source is read; planted: it fails). The numbers in this paragraph are the builder's run of 2026-10-30, for the reader.

## The root README and Course 5's pin (⚑11, R.163)

- `../README.md`: line 1 + *Spring Web MVC*; "all six courses"; the folder line + `c6-unitNN/` + `c6-tiffinbox/`; a `## Course 6 —
  Spring Web MVC` section (32 units, 6 sections, `c6-tiffinbox`, the tree the next course starts from); the roadmap line unchanged.
- `../c5-unit30/receipts.sh`: the full-clone check names `0458d2b` too; `readmecap`'s seven reads of `../README.md` read `git -C ..
  show 0458d2b:README.md`, its two `$` lines say so; every label and every check unchanged. `receipts.md5`: readme `bb4db1ef…` →
  `4456fd199c0cc10b1647683ea7526015` (the two `$` lines). `README.md`: told (R.73), its block and hashes republished.
- Runs (2026-10-30, a process group each): **unpinned, README unchanged** — `./receipts.sh` exit 0, readme `bb4db1ef…` = published;
  **pinned, README unchanged** — `./receipts.sh` and `bash receipts.sh` exit 0, all 3 = published (`4456fd19…`); **pinned, README
  changed** — both bashes exit 0, all 3 = published; **unpinned, README changed (planted, a sibling copy with the original
  `receipts.sh` and `receipts.md5`)** — exit 1, `readme md5 fd1db9a5fdd8b4c08320904b1b2e3c9d DIFFERS from the published bb4db1ef…`
  (the roadmap line's number 456 → 463, the title, the folders, the sections): the change without the pin would have broken it.

## Exercise

None: the finale is exempt (contract §7; `check_unit6.py` skips the last unit), as Course 4's and Course 5's last lessons were.

## The ledger rows and hand-offs this unit pays

- **C6-13** — paid: the counts read on the day (32 / 6), Course 5's eight titles compared, equal; nothing to correct, said on camera.
- **§6c / R.59 / R.63** — the next course read from the roadmap (*Data with JPA & Hibernate*), the up-next card the roadmap's next row.
- **S5 CARRIED** — "TiffinBox has tests now" (18, the capstone's reports), said as the fact the next course adds to.
- **C6-31** — J-P-A spelt, Hibernate named, Course 7's concepts by its titles only.
- **R.162 / R.163** (proposed S6.33, S6.34) — both above.

## RE-MEASURE — the brief's items this unit settles

- **#15** C5 U30's `readme` capture pinned to the commit before this unit's, 3/3 both bashes, md5 `4456fd19…` (above).
- **#16** the receipts/rules counts — read by the builder: 235 captures in 31 units, 151 rules at the unit's build; **170 since BLUE S6
  numbered R.152-R.170 (re-read by `s632.py` on 2026-10-30: the voice says "the course's written rules grew to a hundred and seventy as it
  went", RED S6 #556)**.

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **"2 SQL strings in `Database`"** (brief) → **6**: 2 DROP TABLE, 2 CREATE TABLE, 2 INSERT; the brief's 2 is the tables it creates.
- **The hand-off's cause, sharpened:** the brief's beat is "the URL is in memory, so she is gone". Measured (C): with Course 2's file
  URL, the file holds Kavya between the JVMs, and the restart still loses her — `Database` drops both tables and seeds four customers at
  every start. The voice says both causes, scoped "here".

## Found on the way

- **`Database.createAndSeed()` runs at every start** (`@PostConstruct`, `DROP TABLE IF EXISTS` first): a file URL alone would not keep
  TiffinBox's data. The next course's *Schema and lifecycle* section is named on camera, nothing claimed about it.
- **This unit's own `readme` capture reads `../README.md` live** (the README as it is now). A later change to the root README — the
  next course's entry — makes it die on its md5 exactly as Course 5's would have: R.163's pin applies to it too — **carried, by name, in the S6 AMENDMENT's CARRIED: Course 7's setup brief pins c6-unit32's `readme`
  (`cat ../README.md` → `git -C .. show <the commit before that change>:README.md` — the README as `b50b410` left it — its `$` line
  saying so) in the commit that changes the root README, the
  way this unit pinned c5-unit30's** (RED S6 #554, measured: a root README with a planted Course 7 entry makes this unit's receipts exit 1,
  `readme md5 91024945… DIFFERS from the published 4e4241dd…`).
- **Course 5's label "and as it is now:" stays** (the brief: every other line unchanged; Course 5's video shows it); the `$` line under
  it names `0458d2b`, and Course 5's README says the README has moved past that unit; its `receipts.sh` header comment, which still
  said "as it is now", says "as commit 0458d2b (Course 6's capstone) had it" since BLUE S6 (RED S6 #553; c5-unit30 re-run 3/3 under both
  bashes after it: exit 0 in 39 s each, seam `d1d10087…`, pieces `902a804d…`, readme `4456fd19…`, all = published).
- **`../c6-unit31/README.md` held a literal `SIGINT_GO_HERE` line** under "Interrupted" (its builder's lost terminal lines, as the
  brief says) — not touched here; RED B re-recorded the five SIGINT trials and BLUE S6 wrote them in as its "Measured" paragraph
  (RED S6 #540).

## For RED (part B)

- Every count's source: `s632.py`'s derived line (printed at build) against `java6_series.py`, `TRACK-ROADMAP.md` (md5 above), the 31
  `receipts.md5`, STYLE-CONTRACT §R, `../c6-unit31/.r-tests.out`, and Course 5's `30-…-slides.html`.
- The pin's `$` line and Course 5's 3/3 under both bashes (re-run it: `cd ../c5-unit30 && ./receipts.sh`); R.162's two classes and two
  URLs (`memory`); the three planted faults of the brief (a typed count, the unpinned README, the class named as the anchor's) and the
  rest ("Planted faults", above).
- Whether the voice's "two things lose her here" is scoped tightly enough (C is one file URL, on this tree).
