# c6-unit31 — Capstone: The TiffinBox Web App

Course 6 · Spring Web MVC · Section 6 (Close), its third unit, and **the anchor's last change in this course** · Verified on **JDK
25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5, Hibernate Validator
9.1.3.Final, Thymeleaf 3.1.5; JUnit Jupiter 6.0.3, Mockito 5.23.0, Surefire 3.5.6), **GraalVM CE 25.3.4.1** (native-image 25.0.4.1),
**Docker on OrbStack**, curl 8.7.1, 2026-10-29. A **capstone**: the application Course 6 built, walked once and measured — its boxes,
one path with two answers, its routes, the seven, the four files Course 5's web jobs lived in — and three jobs it still owed, done:
a name length nobody checked (#385), a **bulk upload** (many customers in one request) and a feed of new customers (an **event
stream**: one answer that stays open while the server writes events into it), whose streams end when the context closes so that
**graceful shutdown** (Boot waits for open requests before Tomcat stops) has none left to wait for. The tests are extended, and the
anchor is proven in its four forms.

**The anchor changes (brief ⚑4) — the last time in Course 6.** `after/` is this unit's frozen copy of `../c6-tiffinbox` after the
change, and `diff -rq -x target ../c6-tiffinbox after/` is empty at this unit's commit: `c6-tiffinbox` = `c6-unit31/after`, **the tree
Course 7 starts from**. "Before" is `before/`, the link to `../c6-unit28/after` — the testing lesson's frozen tree, which `c6-tiffinbox`
equalled before this unit (`diff -rq -x target` empty, checked first) and which units 29 and 30 read through their `anchor` links. Both
trees are copied under `.harness/` and built there, never in place. What changed (the anchor README's unit 31 section says it whole):

- `tiffinbox-core/src/main/java/com/tiffinbox/Customer.java` — `@NotBlank @Size(max = 60) String name`; the Javadoc's "A value breaks
  at most one rule of its component" is gone (sixty-one spaces break two), the paragraph that says why is new.
- `tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java` — `fieldMessages` keeps every message a field earned, sorted,
  joined by `; `; the 400's detail counts the rules broken (`getFieldErrorCount`); a stored customer is told to the feed; its
  Javadoc's one-message sentence rewritten.
- `DashboardPage.java` — the form's stored customer is told to the feed.
- `CustomerFeed.java` (new) — `GET /customers/feed`, `text/event-stream`, an `SseEmitter(0L)` per listener; a comment line
  `:listening` first; event `customer-added` with the record; every emitter completed on `ContextClosedEvent`.
- `CustomerImport.java` (new) — `POST /customers/import`, multipart part `file`, CSV rows checked by Boot's validator and stored by the
  same repository; `{"file", "added", "refused": {"line N": why}}`.
- `src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java` (+5), `FullStackTest.java` (+1), `FeedTest.java` (new, 1): 18 tests.
- `README.md` — the anchor's: its unit 31 section, and the history notes the change made false (below).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 9 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.) **`PATH` must name
`/usr/sbin`** (a test JVM runs the harness's `lsof` from it). **Docker must answer**, with `eclipse-temurin:25-jre` already on it: the
script never pulls. It **dies** when a capture's md5 differs from `receipts.md5`. One native build per `forms` run (three per receipt),
each bounded at 20 minutes; its seconds go to the terminal only, and so does the size of the Hibernate Validator metadata file it made
(R.145). **Start it in a process group of its own** (a terminal's foreground job is one): two receipts started as background jobs of
one shell share a group, and one run's clean-up would stop the other's processes.

**Runs (2026-10-29), each `env -i`** (`HOME`, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`, `GRAALVM_HOME`,
`DOCKER_CONFIG=~/.docker`), a process group of its own, `.m2-demo` re-seeded from `_research/m2-seed-s6/` alone. Development runs (on a
copy of the script, never the file under a running bash) fixed the captures and the checks; the last made every capture 3/3 and
stopped at "no published hash", every check passed; its md5s are `receipts.md5`. **The runs of record, on the script as committed:
1,159 s under `./receipts.sh`** (/bin/bash 3.2.57) **and 1,120 s under `bash receipts.sh`** (Homebrew bash 5.3.9): each exit 0, all 9
captures 3/3 = published, every check passed, every build `offline: yes`; native builds under the 20-minute bound (their seconds on the
terminal only). **Nothing was downloaded** for this unit outside the sealed clone's `file://` copy.

Published hashes: tour `335e1bd4d258084ff9bd0bce0db62d16` · seven `31dfef90413a30ee880b9a949bb05e96` · retired `e1f0e4199a3e11d44628dc90f2623fd2` · length `93081fae569f2404abe5a6bc38209da9` · upload `4d234ee2de026a539fc6e578e916e643` · feed `522ea3bb87afaacf7a7ba8244e7c8c35` · tests `c26600790ea89fa1651ed25aeda554e7` · exercise `4d7b8c9e0a7dd2837dbe32696b5bcd90` · forms `e2e84b5e0b742f8036ee65a280126f7f`.

### A sealed fresh clone — the recipe (R.129; RED S4 #405, unit 28's form)

**Paste it into bash** (type `bash` first if your Terminal is zsh): zsh does not split the unquoted `$E`, so the pre-flight would print
`NOT SEALED` — safe, but for the wrong reason (RED S6 #550).

**Run (2026-10-29):** a `git clone` of tiffinbox-java at b884170, with `c6-unit31/` and `c6-tiffinbox/` put in as git would
take them (`git ls-files -co --exclude-standard`: 91 files, each `cmp`-equal to the working tree; `before` → `../c6-unit28/after` by
`readlink`); a `file://` copy of the seed (4,441 files); pre-flight: exit 1, 221 `Downloading from sealed: file://`, 0 from http(s);
`/bin/bash` 3.2, `env -i`, a group of its own: **exit 0 in 1,038 s, all 9 = published, every check passed**; the first build said
`offline: no` (the metadata zip, from the sealed mirror), every capture's build `offline: yes`; `_remote.repositories` by repository id:
**631 `>sealed=`, 5 `>=`** (TiffinBox's own modules, installed by the run), **0 `central`**; build logs: 631 `Downloaded from sealed`, 0
from http(s). The clone ran the tests (its `package` and `install` builds do) and built the binary three times.

```bash
S=/tmp/sealed-31                                   # an empty folder of your own; T = your tiffinbox-java clone
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
X=http://127.0.0.1:9; E="env -i HOME=$S/home PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin http_proxy=$X https_proxy=$X HTTP_PROXY=$X HTTPS_PROXY=$X no_proxy=127.0.0.1,localhost NO_PROXY=127.0.0.1,localhost GRAALVM_HOME=$GRAALVM_HOME DOCKER_CONFIG=$HOME/.docker"
$E JAVA_HOME=/opt/homebrew/opt/openjdk@25 mvn -B -Dmaven.repo.local="$S/preflight-m2" org.apache.maven.plugins:maven-dependency-plugin:3.8.1:get -Dartifact=org.example.sealed:absent:1 > "$S/preflight.log" 2>&1
[ $? != 0 ] && grep -q 'Downloading from sealed: file://' "$S/preflight.log" && ! grep -qE 'Downloading from [^ ]+: https?://' "$S/preflight.log" && echo "sealed: file:// only" || echo "NOT SEALED - do not run receipts.sh"
cd "$S/tiffinbox-java/c6-unit31" && readlink before && $E ./receipts.sh            # a process group of its own
find .m2-demo -name _remote.repositories -exec cat {} + | grep -o '>[^=]*=' | sort | uniq -c     # every line sealed; 0 central
```

## The commands this unit adds

```bash
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,mappings
java -Duser.language=en -Duser.country=US -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
curl -s http://127.0.0.1:18431/dashboard
curl -s http://127.0.0.1:18431/actuator/mappings
curl -s http://127.0.0.1:18431/customers
curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:18431/customers
curl -s -w ' %{http_code}\n' -H 'Accept-Language: de' -H 'Content-Type: application/json' --data '{"name":"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:18431/customers
curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"                                                             ","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:18431/customers
curl -s -w ' %{http_code} · Location: [%header{location}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data 'name=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:18431/customers
curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":0,"mealType":"VEG"}' http://127.0.0.1:18431/customers
curl -s -w ' %{http_code}\n' -F "file=@harness/import.csv;type=text/csv" http://127.0.0.1:18431/customers/import
curl -s -w ' %{http_code}\n' -H 'Accept-Language: de' -F "file=@harness/import.csv;type=text/csv" http://127.0.0.1:18431/customers/import
curl -s -w ' %{http_code}\n' -F "upload=@harness/import.csv;type=text/csv" http://127.0.0.1:18431/customers/import
rsync -a harness/test/ .harness/COPY/tiffinbox-web/src/test/
f=tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerFeed.java && sed '/@EventListener(ContextClosedEvent.class)/d' "$f" > "$f.new" && mv "$f.new" "$f"
mvn -B -pl tiffinbox-web -Dtest=StreamWait clean test
```

The lines `receipts.sh` reads from the anchor's README (`after/README.md`, 18 lines, each asserted there whole) include this unit's two:
`curl -s -w ' %{http_code}\n' -F "file=@customers.csv;type=text/csv" http://127.0.0.1:18431/customers/import` and `curl -s -N
http://127.0.0.1:18431/customers/feed`. Each line above is an anchor line with one change, and the script asserts that too: the java
lines pin the JVM's locale; the 61-letter, 61-space, `de` and invalid POSTs are the anchor's POST with the name (or the body, or one
header) changed; the 61-letter form is the anchor's form line with the name changed; the upload lines are the anchor's upload with the
harness's file (and, once, its part named `upload`, or `Accept-Language: de`); the dashboard and list lines are the anchor's page line
without its header (and, for the list, another path); the StreamWait line is the anchor's test line with another `-Dtest`. The name of
61 letters is 61 `A`s; the name of 61 spaces is 61 spaces. Every Maven line runs offline against `.m2-demo`: `-o -B
-Dmaven.repo.local="$M2"` after `mvn`, and `clean` before a lifecycle phase the README line names without it.

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else, refuses one whose `native-image --version` is not
`native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1`, and never prints its folder (`$GRAALVM_HOME` in every capture). Only `forms`
needs it. **Without a GraalVM** the script makes the eight other captures, each checked against `receipts.md5`, then stops where the
native build would start (exit 1).

## The repository, Docker, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../spring-web-mvc/_research/m2-seed-s6/` alone (5,926 files, = `m2-seed-s5` byte for byte) before each run of record. **Nothing was
downloaded** for this unit: every build said `offline: yes`, every test run's log holds 0 `Downloading from` lines, the native plugin
read its metadata repository from `.m2-demo` (its zip, checked present after the first build), and every native build's log holds 0
lines of the plugin's own download (the run would stop on one). A fresh clone's `.m2-demo` is empty (git ignores it): the first build —
`after/`'s `mvn -B -Pnative install`, before any capture — fills it from Maven Central (in the sealed clone, from the `file://` copy) and
says `offline: no`. **Docker:** no pull — `docker build` prints its `load metadata` line and the base image's digest, and `its lines that
say pull: 0`. The image (`tiffinbox-capstone:1.0.0`) and the container (`tiffinbox-capstone`) are this script's own names, checked absent
first and removed on every exit. A container that is not this script's (`open-webui`, on this Mac) is never touched or counted. **At run
time** every request goes to `127.0.0.1`.

## The demo token, and the tests' literal

The demo token — `TOKEN=` at the top of `receipts.sh`, 32 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/*/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) of every copy, mounted read-only into the container, and sent only by `../c5-unit11/curlset.sh` and `harness/shutdown.sh` on
curl's standard input. **Before every start** the script lists that `secrets/` folder — the token's file and nothing else, or the run
stops (R.158: a file there is a key) — and a last check counts one listing per start in every capture. Every capture's raw output is
searched for the token before masking (0 in all of them), and so are the log of every JVM that served (and the header's name,
`X-Shutdown-Token`, 0 in every log), the container's logs, every Maven log and every Surefire report, every build log, every file this unit
ships (all of `after/` among them), the binary's bytes and every blob of the image (`docker save`): 0 everywhere. **The tests never read
it**: they run in `tiffinbox-web/`, where no `secrets/` folder is (`Census`: `a secrets folder there: no`), and the settings record's
required token comes from the tests' own `properties`: **`not-the-real-token` — a literal written in the tests, not a secret**.

## The locale — pinned per JVM, and the test JVM's by the POM

Every java line this script starts carries `-Duser.language=en -Duser.country=US` before `-jar` (S6.1), and a last check refuses any
capture's java line without them; the exercise's java lines carry them too. A test JVM is Surefire's own fork; the POM's `argLine` pins
it, and every test run's reports say `en_US` (a check asserts it for every one). **The binary takes no JVM options**: its messages are
the ones its build fixed — it answers `Accept-Language: de` in English (`forms`), where the jar, the AOT jar and the image answer in
German. Every request that gets a validator's message says which `Accept-Language` it sent (none, or `de`).

## The folders, the names and the ports

- `after/` — the anchor after this change (= `../c6-tiffinbox`); `before` — the link to `../c6-unit28/after`. `.harness/pre` — the first
  build (after/, `-Pnative install`: it fills `.m2-demo` and installs both modules); `.harness/before`, `.harness/after` — the two trees,
  copied, each with a config tree, built with the README's `mvn -B package` before the captures (each runs its tree's tests: 11 and
  18); `.harness/noend` — `feed` C's copy; `.harness/tests` — `tests`' copy, the harness's test sources added; `.harness/nat` — after/'s
  native build; `.harness/mine` — the exercise's copy of its CSV.
- **The harness** — the course's, never TiffinBox's (package `probe.web`, outside `com.tiffinbox`; `harness/test`, copied into a copy's
  `tiffinbox-web/src/test`, never into `after/`): `Census` (the testing lesson's, byte for byte, with its `spring.factories`) — once per
  test class it prints the context's beans, MockMvc's filters, the web server, this test JVM's listening sockets read with `lsof` off its
  own pid (the server's port `<port>`, another cached context's `<another context's port>`), the JVM's locale, and an `EXCHANGE` line for
  every answer MockMvc completes; `StreamWait` — TiffinBox's slice, the feed asked for with MockMvcTester's default exchange (a test class
  Surefire runs only when `-Dtest` names it). `harness/surefire.py` (the testing lesson's, byte for byte) reads Surefire's reports;
  `harness/shutdown.sh` is the CORS lesson's, byte for byte; `harness/import.csv` is the upload's file (a header, Chetan, a 61-letter
  name, `Dev,x,…`, Ravi).
- **Ports** (brief ⚑1, 19600-19609): after/'s jar 19600 · the AOT jar 19601 · the binary 19602 · the image 19603 (published on
  127.0.0.1) · the tour's run 19604 · the previous tree's jar 19605 · `feed` C's copy 19606 · the port-taken pair 19607 · 19609 checked
  free and never bound. 18425, 8080 and 35729 are checked free first. **A test's server** (`FullStackTest`, `FeedTest`) takes the port the
  system picks — macOS's ephemeral range here, 49152-65535 (§P's exception, R.147) — read off the test JVM's pid by `Census`, loopback
  asserted, masked.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM, the token, the user, a request thread's number, the Java version, the connector** (`gsub()`, literals escaped):
   the token → `[masked: the 32-character token]`; the GraalVM's folder → `$GRAALVM_HOME`; this folder → `…`; the folder above → `…/..`;
   home → `~`; the user name → `<user>`; `tomcat-handler-<n>`; `$$SpringCGLIB$$<n>`; ` using Java <version>` (R.151, printed once on the
   terminal); `http-nio-127.0.0.1-<port>` (S6.22). The mask is checked on a planted line first (the JDK version, the connector name, the
   token).
2. **A Maven log** is never printed whole (`mrun`): its `$` line, its exit code and `BUILD` line, `offline` (its `Downloading from` lines
   counted), Surefire's reports read by `harness/surefire.py`, **Surefire's console summary beside the reports' sum** (R.144: never the
   console alone), Surefire's own line about a fork that would not exit (counted), the harness's `CENSUS` lines (sorted by test class)
   and `EXCHANGE` lines (in the order they ran), Mockito's and the JVM's console lines (counted), its WARN and ERROR records (`recs`:
   level, logger, message, the exception line under it; frames bounded "over 40"; an identity hash `@…`; a line over 200 characters cut,
   the rest counted), and a count of the rest. The token and the tests' literal counted in the log and every report.
3. **A JVM's log**: Boot's first line; the lines of named loggers (`blog`: Boot's `GracefulShutdown`, Framework's
   `DefaultLifecycleProcessor`), each labelled by its logger; its WARN and ERROR records (`recs`) or counts.
4. **Answers**: a JSON body as its bytes, keys sorted (`sortj`, said `(keys sorted)`), Spring's timestamp `…`; a page as its `<title>`
   (a form's page with every message beside a field; the dashboard with its table's rows counted); the listener's file every line (a blank
   one shown `(blank)`), its events, data, id and comment lines counted; the seven as `curlset.sh` prints them; `/actuator/mappings`
   parsed: the dispatcher's rows counted, TiffinBox's listed. The native build's lines through a declared filter (stages, warnings, BUILD),
   the rest counted; `docker build`'s through `blines`.
5. **Hygiene, checked last over every capture:** no absolute path, no GraalVM folder, no unit number (a folder name with one included),
   no Boot process line, no Surefire booter path, no test time, no log time, no timestamp, no thread number, no OS or JDK version token
   (` using Java [0-9]` among them), no connector port, no random port, no stack frame; every `$` line's URL is `127.0.0.1`'s; every java
   line pinned; one `secrets/` listing per start; no `pkill`/`killall`; no bare `wait`; no Boot 3 error or client key; no `-p` without
   `127.0.0.1:`; no harness class in `com.tiffinbox`. No duration is captured: the native build's seconds go to the terminal only; Boot's
   own `30000ms` stays inside Framework's log line.

## The Hibernate Validator file (R.145)

GraalVM's native plugin maps two directories of its metadata repository to one file,
`META-INF/native-image/org.hibernate.validator/hibernate-validator/9.1.3.Final/reachability-metadata.json`, and the last one written
wins: 2,306 or 157,308 bytes, build to build. `forms` reads the file each native build made, in `target/classes` and in the jar (the
same), prints its size on the terminal — never in a capture, never hashed — and asserts the binary's validation answers (the invalid
customer's three messages, the size message); a last check refuses a run whose builds printed no size, or a size neither of the two.
**A binary whose validation failed would stop the run** (exit 3, "STOP (R.145) … do not re-run"); none did.

**Measured here** — every `forms` run of this unit that reached its end, the sizes as the terminal printed them: `2306 157308 157308` · `157308 157308 2306` (development) · `157308 157308 2306` (3.2 run of record) · `157308 157308 157308`
(5.3 run of record) · `157308 157308 157308` (the sealed clone) · `2306 157308 157308` (RED B's run) · `2306 157308 157308` (BLUE S6, 3.2)
· `2306 2306 2306` (BLUE S6, 5.3) — **24 native builds: 2,306 bytes 8 times, 157,308 bytes 16 times, and every binary validated** (the three messages, the size message, the seven `466c20ed…`, the upload, its event, the page, a graceful
shutdown — each `forms` capture 3/3 and its checks passed).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the listener (`$lpid`, curl -N), the JVMs it
started (`$pid`, `$pid2`), the Maven it waits for (`$mpid`, with every process under it — Surefire's fork, `native-image`'s driver and
builder — `killtree`), the exercise's shell (`$xpid`, with every process under it), sweeps its own process group for any TiffinBox JVM,
binary, listener, Maven, Surefire fork or `native-image` left, removes the container and the image, deletes the capture runs it had not
finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched. No `wait` in the script or the exercise is bare.

**Measured (2026-10-30, RED S6 #540 — the builder's own terminal lines were lost with its session, so these are RED B's, re-recorded on
the script as committed at `0458d2b`, the R.147 check of #548 aside, which runs after every capture):** `./receipts.sh` (/bin/bash 3.2)
started in a process group of its own with SIGINT at its default, `kill -INT` to that group once the condition held, the state read
5 s later — five trials, each **exit 130, nothing left**:

```
jvm: processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · java/curl-feed/surefire/native-image of the run anywhere: 0 · ports listening: none · container: 0 · image: no · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
fork: processes in the group at SIGINT 5 · exit 130 · 5 s later in the group: 0 · java/curl-feed/surefire/native-image of the run anywhere: 0 · ports listening: none · container: 0 · image: no · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
listener: processes in the group at SIGINT 9 · exit 130 · 5 s later in the group: 0 · java/curl-feed/surefire/native-image of the run anywhere: 0 · ports listening: none · container: 0 · image: no · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
native2: processes in the group at SIGINT 4 · exit 130 · 5 s later in the group: 0 · java/curl-feed/surefire/native-image of the run anywhere: 0 · ports listening: none · container: 0 · image: no · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
container: processes in the group at SIGINT 3 · exit 130 · 5 s later in the group: 0 · java/curl-feed/surefire/native-image of the run anywhere: 0 · ports listening: none · container: 0 · image: no · .r-lock: no · unfinished runs: 0 · captures unchanged: yes
```

`jvm` — a capture's JVM listening on 1960x; `fork` — Surefire's `surefirebooter` in the group; `listener` — the feed's `curl -s -N`;
`native2` — inside `forms`, the condition `pgrep -g <group> -f 'svm.hosted|native-image'` (and `pgrep -fl 'svm.hosted|native-image|tiffinbox-web'`
empty after); `container` — `tiffinbox-capstone` running. **The builder's own native trial never interrupted the build**: its
condition looked for `com.oracle.svm` in `ps -axo command=`, which macOS truncates, so the run went on to `forms … 3/3 = published`
(RED B's first native trial, with the same condition, did the same: "the run ended before the condition"); RED B's `pgrep` trial
(`native2`) did interrupt it. The commit message's "SIGINT during a JVM, the listener, the test fork, the native build and the
container: exit 130, nothing left" rests on these five lines.

## 1 · tour — the boxes, one path two answers, the routes

Every `.java` file of after/'s main sources, its declaration's annotations read off the lines above it: **18 classes** (7 core, 11 web);
`@RestController` 3 (`TiffinBoxServer`, `CustomerImport`, `CustomerFeed`), `@Controller` 1 (`DashboardPage`), `@RestControllerAdvice` 1
(`TiffinBoxErrors`), `@Component` 6 (`CustomerRepository`, `Dashboard`, `Database`, `OrderQueue`, `KitchenHealthIndicator`,
`KitchenMetrics`), `@Configuration` 1 and its three companions on `TiffinBoxApp`, `@ConfigurationProperties` 1; no annotation on 5
(`Customer` and `TiffinBoxProperties` are records — the latter with two —, `MealType`, `CustomerNotFound`, the bare-argument pair).
`@Service`, `@Repository`, `@Entity` as an annotation line anywhere in after/'s sources: 0 each. The four boxes: the controller's four
classes by Spring's annotation; service — no class so named, none so annotated, the work in `Dashboard` and `OrderQueue`, each a
`@Component`; repository — `CustomerRepository`, TiffinBox's own class name, a `@Component`; entity — `Customer`, a record. The run
(`--management.endpoints.web.exposure.include=health,prometheus,mappings`, the mappings lesson's line, for this run): `/dashboard` asked
for HTML → `<title>Dashboard · TiffinBox</title>` (its table's rows: 5); curl's own `Accept` → the JSON, four customers; the routing table
21 rows, TiffinBox's 12 (listed: `CustomerFeed#feed` producing `text/event-stream`, `CustomerImport#importCsv` consuming
`multipart/form-data`, `DashboardPage` 3, `TiffinBoxServer` 7), the other 9 Actuator's, Boot's `/error` and the static files'.

## 2 · seven — the same seven, and TiffinBox's own server's

After/'s jar (19600) and the previous tree's (19605), a fresh JVM each: `466c20ed…` both, exit 0, the timestamp mask 0; lines that differ
0, the same byte for byte 7. TiffinBox's own server's seven, read from the servlet lesson's README (its first block that runs
`$CURLSET`, the anchor the last course left): 7 lines, md5 `115c36ba…`, the md5 that README publishes beside them. After/'s against them,
line by line: **5 the same, 2 differ** — `GET /nowhere` (the JDK's `<h1>404 Not Found</h1>` → Spring MVC's problem detail `No static
resource nowhere.`) and `GET /shutdown` (TiffinBox's `{"error":"method not allowed"}` → the 405 problem detail), each printed with the
lessons that changed it, by title. (The frozen `../c6-unit01/.r-before.out` is git-ignored, so a clone has none: the published block is
read, and when the frozen file is present a last check asserts its seven are the same lines.)

## 3 · retired — Course 5's four web files

In the tree the last course left (`../c5-unit27/after`) and in after/: `ActuatorRoutes.java` 196 lines → no file, `Route.java` 24 → no
file, `PortTakenFailureAnalyzer.java` 51 → no file, `TiffinBoxServer.java` 277 → 309 lines (548 in all, the four); files of those three
names anywhere in after/: 0. `TiffinBoxServer.java`'s imports of `com.sun.net.httpserver`: 3 → 0, and 0 in all of after/'s sources; it is
a `@RestController`, and its Javadoc says "TiffinBox no longer runs a server of its own". Each job's replacement by its lesson's title:
embedded Tomcat, Boot's Actuator on Spring MVC and Boot's `PortInUseFailureAnalyzer` (*Embedded Tomcat, Threads and Connectors*), Spring
MVC's request mappings (*@RestController and Request Mapping*). TiffinBox's own `spring.factories` names one analyzer,
`BareArgumentAnalyzer`; `spring-boot-web-server-4.1.1.jar`'s names `PortInUseFailureAnalyzer` (R.134, the class file in that jar). A second
TiffinBox on 19607, which the first holds: exit 1, the first still the one listener; its log's one ERROR line is Boot's
`LoggingFailureAnalysisReporter`, and the report under it: `Web server failed to start. Port 19607 was already in use.` / `Identify and
stop the process that's listening on port 19607 or configure this application to listen on another port.` Both JVMs waited for by pid.

## 4 · length — A/B/A′; C (labelled)

**A** (after/, `@NotBlank @Size(max = 60)`, 19600): the 61-letter POST → **400** `the customer breaks 1 rule`, `"name":"size must be
between 0 and 60"`; `Accept-Language: de` → `Größe muss zwischen 0 und 60 sein`; the form's POST → 200, the form page with `size must be
between 0 and 60` beside the name; `/customers` still the four; WARN 0, ERROR 0. **B** (the previous tree, 19605): the same POST →
**500**, Boot's four keys (`error`, `path`, `status`, `timestamp`); `/customers` the four; its log's one ERROR record, Tomcat's
`[dispatcherServlet]`, `Request processing failed: org.h2.jdbc.JdbcSQLDataException: Value too long for column "NAME CHARACTER
VARYING(60)"…` (H2's refusal, its message in the log twice: the record and its root cause). **A′** = A, its `$` line shown; "the same:
yes". **C (labelled)** — 61 spaces, three fresh JVMs, no `Accept-Language`: each `the customer breaks 2 rules`, `"name":"must not be blank;
size must be between 0 and 60"`; the three answers: 1 distinct (R.160).

## 5 · upload — a bulk upload

`harness/import.csv`: a header, `Chetan,1,100,VEG`, a 61-letter name, `Dev,x,90,VEGAN`, `Ravi,2,120,VEG`. `curl -F
"file=@harness/import.csv;type=text/csv"` (no `Accept-Language`) → 200 `{"added":1,"file":"import.csv","refused":{"line 3":"name: size
must be between 0 and 60","line 4":"not a number: For input string: \"x\"","line 5":"a customer named Ravi already exists"}}` (keys
sorted); `/customers` lists Chetan with the four; the file in a part named `upload` → **400** problem detail `Required part 'file' is
not present.` (Spring MVC's); WARN 0, ERROR 0. A fresh JVM, `Accept-Language: de` → the same, line 3 `name: Größe muss zwischen 0 und 60
sein`.

## 6 · feed — who joined; C (labelled)

After/'s jar (19600); the listener, `curl -s -N http://127.0.0.1:19600/customers/feed > .harness/feed.txt &` (to a file, S6.8; waited
for by its pid), connected when its first line, `:listening`, is in the file. The JSON API's Asha (201), the form's Lata (302 →
`/dashboard`), the upload's Chetan (`added 1`): **3 `customer-added` events**, each a `data:` line with the record's JSON, no `id:` line,
one comment line. POST /shutdown with the listener connected → 200; the JVM exits 0; the listener ends, **curl exit 0**; Boot's
`GracefulShutdown`: `Commencing graceful shutdown. Waiting for active requests to complete`, `Graceful shutdown complete`; lines that say
a bean was still running after the phase's timeout: 0. **C (labelled)** — a copy (`.harness/noend`) with `CustomerFeed`'s
`@EventListener(ContextClosedEvent.class)` line taken out (one line, the diff whole), built with the README's package line: its 18 tests
pass, and **Surefire's line that a fork would not exit: 1** (`Surefire is going to kill self fork JVM …`); its jar (19606), a listener, one
JSON add (1 event), POST /shutdown → Framework's `DefaultLifecycleProcessor`: `Shutdown phase 2147482623 ends with 1 bean still running
after timeout of 30000ms: [webServerGracefulShutdown]` (Boot's number, in Framework's own line — no clock read) and Boot's `Graceful
shutdown aborted with one or more requests still active`; the listener cut off, curl exit 18.

## 7 · tests — TiffinBox's tests, from Surefire's reports; C (labelled)

`.harness/tests` (after/, the harness's `Census` and `StreamWait` added); the README's `mvn -B clean test`, offline: exit 0, the reports —
**`TiffinBoxWebTest` 14, `FullStackTest` 3, `FeedTest` 1: 18 tests, 0 failures, 0 errors** (each method's verdict), the fork `en_US`;
Surefire's console summary the same (R.144: shown beside the reports, never alone); Surefire's fork line 0. `Census`: `FullStackTest`'s and
`FeedTest`'s Tomcat on a port in macOS's ephemeral range, not the course's, the test JVM's sockets `127.0.0.1:<port>` (and, in
`FeedTest`'s JVM, `FullStackTest`'s cached context's `127.0.0.1:<another context's port>`); the slice's context 132 beans, 9 TiffinBox's
(the three mocks, the four controllers, the advice, the settings record); the whole application's 295, 13. `EXCHANGE` lines for every
answer MockMvc completed — the feed's `200 text/event-stream`, body `:listening`; the upload's 200; the 61-letter and 61-space 400s; the
form page's title. One WARN (Spring MVC's `PageNotFound`, the 405 test), two Tomcat ERROR records (the failing-repository tests). **C
(labelled)** — `-Dtest=StreamWait`: exit 1, `ERROR theTesterWaitsForTheStreamsEnd - java.lang.IllegalStateException`, `Async result for
handler [com.tiffinbox.web.CustomerFeed#feed()] was not set during the specified timeToWait=0` (R.161): MockMvcTester waits for an async
answer's result, and an endless stream has none.

## 8 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s seven lines, then `exercise/solution/SOLUTION.md`'s seven, in one `env -i` shell (`/bin/bash --noprofile --norc`,
started in this folder): as shipped `{"file":"customers.csv","added":0,"refused":{"line 1":"4 values expected, 1 found","line 2":"4
values expected, 1 found","line 3":"4 values expected, 1 found"}} 200`; after the solution's `sed` (commas for semicolons, from the
shipped file: idempotent) and the README's last four lines again — a fresh TiffinBox —, `{"file":"customers.csv","added":2,"refused":{}}
200`; the shell in this unit's folder after each, nothing listening on 19600, the token 0 times in the JVM's log.

## 9 · forms — four forms, the tests run by the build

The native build of after/ (`.harness/nat`): `mvn -B -Pnative install` ran the 18 tests (3 reports, 0 failures, the fork `en_US`,
Surefire's fork line 0), then `native:compile-no-fork`: 8 of 8 stages, `BUILD SUCCESS`, offline, 0 lines of the plugin's own download;
`Mach-O 64-bit executable`, the token 0 in its bytes, the tests' literal 0, `TiffinBoxWebTest`/`FullStackTest`/`FeedTest`/`WebSlice` 0
each; the HV file's size on the terminal (above). **The jar** (19600), **the AOT jar** (19601, `Starting AOT-processed …`), **the binary**
(19602), **the image** (`tiffinbox-capstone:1.0.0`, published on `127.0.0.1:19603`, `[::]:18425` inside): each one's address loopback; the
seven `466c20ed…`, exit 0; then on a second start, a listener connected: the invalid customer's three messages, the 61-letter name (no
`Accept-Language`: the size message; `de`: German from the jar, the AOT jar and the image, **English from the binary** — its messages
fixed at build), the upload's answer, the one event it made (Chetan), the page's title, and POST /shutdown — `Graceful shutdown
complete`, the listener's curl exit 0. `four forms, one tree: … 4 of 4` for each. The image: its base image's digest printed, 0 pulls,
0 tokens in its layers (`docker save`). No form's shutdown waited out the phase (0 lines). No hint was added for the feed, the upload or
the record they carry.

## Exercise

**Your turn:** the README's upload refuses every row of a good list. Read why, fix the file, and upload again. `exercise/README.md`
copies `exercise/customers.csv` (Esha and Farid, `;` between values) to `.harness/mine/`, starts after/'s jar from `.harness/after` on
19600 (a subshell job, waited for by its pid), uploads the copy with the anchor README's `curl -F` line and stops TiffinBox with POST
/shutdown. As shipped: `added 0`, every line `4 values expected, 1 found`. Done: `{"file":"customers.csv","added":2,"refused":{}} 200`.
Measured answer: `exercise/solution/SOLUTION.md`. Run `./receipts.sh` once first on a fresh clone (it builds `.harness/after`, with its
config tree). Each run starts a fresh TiffinBox: a second upload of the same names into one running TiffinBox would be two
refusals, `a customer named Esha already exists` (S6.4).

## The anchor's README — what this unit changed in it

`../c6-tiffinbox/README.md` (= `after/README.md`) gains its `## Course 6 · unit 31` section (after unit 28's) with this unit's two lines
(the upload, the listener), and **history notes amended in place** (S6.12), found by grepping it for `length`, `61`, `rule`, `message`,
`rows`, `routes`, `graceful`, `shutdown`, `eleven`, `nine`, `two tests`, `upload` and `event`, each hit read:
- the header — this tree, `c6-unit31/after`, is where Course 7 starts (C6-21's successor note);
- unit 06's and unit 07's routing-table histories — twelve routes, 21 rows (`tour`);
- the "What stops it" paragraph — an event stream holds the shutdown's wait unless something ends it; `CustomerFeed` does (`feed`);
- unit 12's "A value breaks at most one rule of its component" — no longer; seven constraints; every message kept (`length` C);
- unit 22's "nothing checks the length" and its forms line's "error page for the 61-letter name" — true of that tree; a 400 since, and no
  request this course sends reaches the error page any more (`FullStackTest` proves it);
- unit 28's "eleven", "nine tests", "two tests" (four places in its section) and the four Course 3/4/5 notes unit 28 added ("eleven tests
  first", "eleven since") — eighteen since (`tests`).
Left as they were, and still true (each read): every other `/customers` line; Course 5's graceful-shutdown keys; unit 22's 19-row line
(its own count, then); the root README (not this unit's: the finale changes it, ⚑11).

## The ledger rows and hand-offs this unit pays

| Row | Paid how | Where |
|---|---|---|
| **C6-11** the seven compare servers | `466c20ed…` on after/ and the previous tree, 7 the same; vs TiffinBox's own server's `115c36ba…`: 5 the same, 2 differ, each named with its lessons | `seven` |
| **C6-12** the four files, 548 lines | three gone (no file), `TiffinBoxServer` kept as a name with no server (0 imports), Boot's `PortInUseFailureAnalyzer` measured where Course 5's analyzer stood | `retired` |
| **C6-23** pages and endpoints | `/dashboard` the page and the JSON, one path; the form; the upload and the feed | `tour`, `length`, `upload`, `feed` |
| **C6-24** the four boxes | counted off the tree: the controller by Spring's annotation, the repository by TiffinBox's class name, no service, the entity a record | `tour` |
| **#385** `@Size(max = 60)` (S4 AMENDMENT, deferred here) | fixed in tiffinbox-core; A/B with the previous tree; 61 spaces deterministic; four forms (the ledger row is its owner's to close) | `length`, `forms` |
| S4 CARRIED — upload and SSE into the anchor | `CustomerImport`, `CustomerFeed`, TiffinBox's own jobs (not 20's menu nor 21's clocked feed), in four forms | `upload`, `feed`, `forms` |
| S5 CARRIED — 28's tests extended; the HV file a check | 18 tests from the reports; R.145's size per build, every binary validated | `tests`, `forms` |
| H-22 "nothing checks the name's length" | called back by title; 22's line stays true of 22's tree | script |
| C6-31 glosses | a capstone, a bulk upload, an event stream (re-gloss), graceful shutdown (re-gloss) | script |

## RE-MEASURE — the brief's items this unit settles

| # | What | Settled |
|---|---|---|
| 8 | 31's changes as the anchor's own files | after/ (`tests`: 14 + 3 + 1) |
| 9 | the exercise on 31/after | `exercise` |
| 10 | `fieldMessages` both messages, sorted; 61 spaces in 3 JVMs | `length` C: one answer |
| 11 | the feed's completion in the image | `forms` (POST /shutdown; `docker stop` not measured) |
| 12 | four forms on 31/after, the image included; HV size per build | `forms` |
| 13 | the port-taken pair as two TiffinBox JVMs | `retired` |
| 14 | `/actuator/mappings` on 31/after | `tour`: 21 / 12 |
| 17 | the exercise as viewers run it | one `env -i` shell (`exercise`) |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

1. **An event stream sends no headers until its first bytes** (Tomcat 11.0.24, Spring MVC 7.0.9 here): with nothing written, a listener's
   curl had no status line and the JDK's HttpClient's response did not complete — so `CustomerFeed` writes a comment line, `:listening`,
   first. The brief's sketch had none, and its test waited on the feed's count instead.
2. **Components are six, not four**: the kitchen's health indicator and meters are `@Component`s too (the brief named the core four).
3. **Framework's line names `[webServerGracefulShutdown]`**, not `[webServer]` (the brief's probe).
4. **The two differing lines of the seven changed twice each**: `/nowhere` became Boot's four keys in *Embedded Tomcat, Threads and
   Connectors* and a problem detail in *ProblemDetail and RFC 9457*; `GET /shutdown`'s body Boot's in *@RestController and Request
   Mapping*, a problem detail in *ProblemDetail and RFC 9457* (read off those lessons' READMEs).
5. **TiffinBox's own server's seven are read from the servlet lesson's README**, not from `.r-before.out` (git-ignored; a clone lacks it).
6. **The 400 counts the rules broken**, not the fields: 61 spaces are `breaks 2 rules` (the three-message answer unchanged, each field one).
7. **"Two boxes have Spring's names" is sharpened**: one box (the controller) wears Spring's annotation; the repository wears the word in
   TiffinBox's own class name; the voice says it so.
8. **The one-message map's nondeterminism is the brief's probe's**, not re-measured (a capture of it could not be 3/3); the voice does not
   claim it.

## Found on the way

- **The bash's dynamic scope.** `retired` used a loop variable `i` it had not declared local, inside `cap()`'s own loop over `i`: the
  capture ran once and wrote `.r-retired.9`. Every function's counters are `local` since.
- **An event stream's headers wait for its first bytes** (LINES 1): the first FeedTest timed out waiting for the response; curl's header
  file stayed empty until an add. The comment line `:listening` is TiffinBox's fix, and the receipts' listener waits for it.
- **A capture that names a folder** (`../c6-unit28/after`, `../c5-unit27/after`, `../c6-unit01/README.md`) is a unit number in a
  capture: the labels say "the previous tree", "the servlet lesson's anchor", "that lesson's README" since.
- **The exercise's line count**: SOLUTION has as many lines as the README (two exports, the fix in place of the copy, the last four);
  the first check expected one fewer.
- **Census's `EXCHANGE` line for the feed** holds the comment's two newlines: the line is read alone (`grep '^EXCHANGE '`), and its body
  reads `:listening`.
- **The probe's `[webServer]`** was another bean's name: this tree's line names `webServerGracefulShutdown`.
- **Planted faults** (R.65, S6.10): every check above was shown failing on a planted fault before it was trusted — 42 plants, each on a
  fresh copy of the final captures and files, run through the script's own checks (its builds and captures cut out), under `/bin/bash` 3.2
  and Homebrew bash 5.3: 42 of 42 stopped, each with its own words, under each. The brief's list: `@Size` removed (A's 400 a 500 → the
  `length A` check), `fieldMessages` back to one message (one JVM `must not be blank` → `length C`), the `ContextClosedEvent` listener
  removed (A's shutdown line Framework's 30000ms one → `feed`), the form's add not publishing (2 events → `feed`), the test count from the
  console only (the reports' line gone → `tests`, R.144), the HV size line missing and a size neither file's (→ R.145), a second file in
  `secrets/` (the pre-start listing stops the run, R.158 — run on `sec()` itself, both bashes). **The tallies (RED B, 2026-10-30, re-recorded —
the builder's tally lines were lost with its session; RED S6 #544):** `plants: 41 caught, 0 missed (under /bin/bash)` and `plants: 41
caught, 0 missed (under /opt/homebrew/bin/bash)`, and the 42nd (R.158, `sec()` on a config tree with `server.ssl.key` beside the token)
exit 1 under both, exit 0 on the clean tree under both. **Plant 43 (BLUE S6, RED S6 #548):** the R.147 loopback check could never fail —
its pattern was split by a quoting slip, so grep printed `brackets ([ ]) not balanced` and the "nothing but loopback" half passed
whatever it read; fixed (`grep -vE "^127\.0\.0\.1:<[a-z' ]+>\$"`, a grep that cannot run fails the check too) and planted: FeedTest's
sockets line given `*:<another context's port> 127.0.0.1:<port>` → stopped, `tests: FeedTest's sockets loopback only (R.147)`, under
each bash (`plants: 42 caught, 0 missed` under `/bin/bash` and under `/opt/homebrew/bin/bash` — RED B's 41 and plant 43, on a check-only
copy of the final captures and files after BLUE's runs of record; no `brackets` line in either; the R.158 `sec()` plant not re-run: `sec()`
is unchanged). And: a raw token in a capture and in a
  shipped file; an unmasked ` using Java 25.0.4.1`; a random port; a connector name with its port; a java line without its locale; a URL
  not 127.0.0.1's; a start without its listing; the seven on one tree only; four the same; an `@Service`; 20 rows; `ActuatorRoutes` still a
  file; the second TiffinBox started; B with no ERROR line; A′ not A; the upload's `added 2`; the no-file 400 gone; the listener cut off in
  A; a clean shutdown in C; a held fork in `tests`; FeedTest's server on every address; StreamWait passing; the exercise still refusing;
  the binary German to `de`; the binary's three messages gone; a token in an image layer; a form that held its shutdown; a bare `wait`; a
  `pkill`; a harness class in `com.tiffinbox`; a port published on every address; Boot 3's error key; a German fork.

## BLUE S6 (2026-10-30) — what changed after RED S6, and what re-ran

- **`receipts.sh`**: the R.147 "loopback only" check (#548) — the one code change; it runs after every capture, so no capture changed
  because of it — all nine published md5s reproduced, 3/3, under both bashes.
- **The anchor README** (`after/README.md` = `../c6-tiffinbox/README.md`, byte for byte; `diff -rq -x target` empty): "What stops it"
  names `[webServerGracefulShutdown]` (#551); the "When it breaks" note says the error page is kept honest by `FullStackTest` — a failing
  repository, asked for HTML, gets the page — never that the test proves no request reaches it (#546); the unit 28 section's bean counts
  carry "132 / 9 and 295 / 13 since" (#552). No shipped code, test or POM changed, so the jar, the AOT jar, the binary and the image are
  the same build inputs; `forms` re-ran in both runs of record all the same.
- **This README**: the SIGINT "Measured" paragraph (#540), the plant tallies and plant 43 (#544, #548), "paste it into bash" (#550).
- **The voice and deck** (`_builders/s631.py`): the A′ panel's label and `$` line (#542), slide 8's error-page sentence (#546), three
  glosses (#563); 669 spoken words, `check_unit6.py 31` PASS.
- **Re-run (R.104):** this unit, both bashes — **1,300 s under `./receipts.sh`** (/bin/bash 3.2.57) and **1,076 s under `bash
  receipts.sh`** (5.3.9), each `env -i`, a process group of its own: exit 0, all 9 = published, every check passed, no `grep:` or `brackets`
  line in either terminal; the HV file per native build `2306 157308 157308` (3.2) and `2306 2306 2306` (5.3), every binary validated; the
  exercise outside the receipt (README + SOLUTION + SOLUTION in one `env -i /bin/zsh -f` shell and in one bash shell → `added 0`, every
  line `4 values expected, 1 found`, then `added 2`, `refused {}` twice; SOLUTION alone with `/usr/bin`'s java 23.0.1 first and
  `JAVA_HOME` unset → `added 2`; 19600 free); `../c6-unit32/` (`memory` reads this tree), both bashes; `../c5-unit30/` 3/3
  under both bashes (its header comment changed, #553).

## For RED

- **Read `../c6-unit31/after`** (= `../c6-tiffinbox` now): `Customer.java` (`@Size(max = 60)`, its Javadoc), `TiffinBoxServer.java`
  (`fieldMessages`, `invalid`, the feed), `DashboardPage.java`, `CustomerFeed.java`, `CustomerImport.java`; the tests (14 + 3 + 1). `mvn -B
  clean test` from a clone of it: 18 tests, 0 failures, no fork held.
- **Re-check (RED B):** the four forms (the seven `466c20ed7e0d5439cb052f32ce09de1b`, the messages, the size message — English from the
  binary to `de` —, the upload, its event, the page, a graceful shutdown with a listener connected, the HV file's size per native build
  and that binary's validation); 5 the same / 2 differ against TiffinBox's own server's `115c36ba…`; the 61-spaces answer across fresh
  JVMs; the shutdown with a listener in all four forms, and C's; every anchor README line the change made false (the notes above) — and
  any this unit missed; the Javadoc rewrites (Customer, TiffinBoxServer); the plants.
- **SIGINT** during a capture's JVM, during the feed's listener, during Maven's test fork, during the native build and while the
  container runs; the sealed clone by the recipe above (`central` 0 by repository id).
- **Ports** 19600-19609 are this unit's; the image `tiffinbox-capstone:1.0.0` / container `tiffinbox-capstone` are this unit's names. RED B
  runs on 19640-19659; a receipt re-run binds this unit's own ports, so RED never runs while this unit's receipts run.
