# c6-unit28 — Testing the Web Layer

Course 6 · Spring Web MVC · Section 5 (Calling Out), its fourth and last unit, and the section's only anchor change · Verified on
**JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5, Hibernate Validator
9.1.3.Final, Thymeleaf 3.1.5; JUnit Jupiter 6.0.3, AssertJ 3.27.7, Mockito 5.23.0, Surefire 3.5.6), **GraalVM CE 25.3.4.1** (native-image
25.0.4.1), **Docker on OrbStack**, 2026-10-28. TiffinBox has answered requests since the course began, and it has never had a test.
This unit gives it its first: a **test** (code that runs TiffinBox's code and checks one answer, so a change that breaks it fails the
build), a **test slice** (`@WebMvcTest`: Spring MVC and TiffinBox's web classes started alone, the rest of the application left out),
**mocks** (stand-ins Mockito makes, which answer only what a test tells them) put in the slice by **`@MockitoBean`**, requests through
**MockMvc** (Spring's request simulator: the `DispatcherServlet` runs, with no socket and no Tomcat), and one **full-stack test** (the
whole application on a real Tomcat, called over a socket) on a **random port** (one the operating system picks free when Tomcat
starts). It measures what the slice needed to start, what it answers, what it never runs — said plainly — and the real server's answer
to the same failure, and it proves the anchor in its four forms with the tests in it.

**The anchor changes (brief ⚑4, ⚑5) — the only time in Section 5.** `after/` is this unit's frozen copy of `../c6-tiffinbox` after the
change, and `diff -rq -x target ../c6-tiffinbox after/` is empty at this unit's commit: `c6-tiffinbox` = `c6-unit28/after` at the
section's end. "Before" is `before/`, the link to `../c6-unit24/after` — the sessions lesson's frozen tree, which `c6-tiffinbox`
equalled before this unit (`diff -rq -x target` empty, checked first) and which units 25-27 read through their `anchor` links. Both
trees are copied under `.harness/` and built there, never in place. One file changed and three are new, besides the anchor's README
(`change`):

- `tiffinbox-web/pom.xml` — 137 → 152 lines, two hunks, nothing out: `spring-boot-starter-webmvc-test` in **test scope** (five lines, and a
  comment) and a `<properties>` block with **`argLine`** = `-Duser.language=en -Duser.country=US` (Surefire passes it to the test JVM).
  Nothing in `<build>` changed (`<build>` line for line the previous tree's).
- `tiffinbox-web/src/test/java/slice/WebSlice.java` (new, 27 lines) — `@SpringBootConfiguration`, `@ComponentScan(basePackages =
  "com.tiffinbox", excludeFilters = @Filter(type = CUSTOM, classes = TypeExcludeFilter.class))`, `@EnableConfigurationProperties
  (TiffinBoxProperties.class)`: the configuration the slice starts from, in package `slice`, outside `com.tiffinbox` (R.143).
- `tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java` (new) — nine tests: `@WebMvcTest(properties =
  "tiffinbox.shutdown-token=not-the-real-token")`, `@ContextConfiguration(classes = WebSlice.class)`, three `@MockitoBean`s
  (`CustomerRepository`, `Dashboard`, `OrderQueue`), `MockMvcTester` and, once, `MockMvc`.
- `tiffinbox-web/src/test/java/com/tiffinbox/web/FullStackTest.java` (new) — two tests: `@SpringBootTest(classes = TiffinBoxApp.class,
  webEnvironment = RANDOM_PORT, properties = "tiffinbox.shutdown-token=not-the-real-token")`, `@AutoConfigureRestTestClient`, one
  `@MockitoBean` (`CustomerRepository`), `RestTestClient`.
- `README.md` — the anchor's: its unit 28 section, and the history notes the tests made false (below).

31 of `after/`'s 36 files are byte for byte the previous tree's. The executable jar's 61 libraries are the same names; of its 218
entries one differs, the copy of the POM Maven puts in every jar; `tiffinbox-core`'s jar is byte for byte the previous tree's.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 7 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.) **`PATH` must name
`/usr/sbin`**: a test JVM inherits it, and the harness's `Census` runs `lsof` from it (the probe's own failure: `Cannot run program
"lsof"`); the script refuses to start without it. **Docker must answer**, with `eclipse-temurin:25-jre` already on it: the script never
pulls. It **dies** when a capture's md5 differs from `receipts.md5`. One native build per `forms` run (three per receipt), each bounded at
20 minutes; its seconds go to the terminal only, and so does the size of the Hibernate Validator metadata file it made (R.145, "The
Hibernate Validator file" below). **Start it in a process group of its own** (a terminal's foreground job is one): two receipts started
as background jobs of one shell share a group, and one run's clean-up would stop the other's processes (R.94).

**Runs (2026-10-28):** each `env -i` (`HOME`, `PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin`, `GRAALVM_HOME`,
`DOCKER_CONFIG=~/.docker`), a process group of its own, `.m2-demo` re-seeded from `_research/m2-seed-s5/` alone. Development runs fixed
the hashes (a run with no `receipts.md5` makes every capture 3/3 and then stops at "no published hash"): one found a race — the JVM's own
console warning and the others reach Maven's log in either order, so a bash 5.3 run's `slice` drifted — and `slice`'s shown lines are
sorted since (its hash re-published); one sealed-clone run found a capture that fetched Maven's dependency plugin itself (`offline: no`
once, then `yes`: a drift), and the first build fetches it since. **The runs of record, on the script as committed: 981 s under
`./receipts.sh`** (/bin/bash 3.2.57) **and 1,002 s under `bash receipts.sh`** (Homebrew bash 5.3.9): each exit 0, all 7 captures 3/3 =
published, every check passed; native builds 159-168 s here and in the sealed clone (terminal only, under the 20-minute bound). **A sealed fresh clone by the recipe
below** (`git clone` of tiffinbox-java at 3ca49a0, this unit's and the anchor's files put in as git would take them — 0 differing from
the working tree, `before` → `../c6-unit24/after` by `readlink`; a `file://` copy of 4,441 files; pre-flight: exit 1, 221 `Downloading
from sealed: file://`, 0 from http(s); `/bin/bash` 3.2, `env -i`, a group of its own): **exit 0 in 975 s, all 7 = published, every check
passed; the first build and the dependency-plugin line said `offline: no`, as a fresh clone's must, every capture's build `offline: yes`;
`_remote.repositories` by repository id: 802 `>sealed=`, 0 `central`** — the 5 lines with no id are TiffinBox's own three modules,
installed by the run; build logs: 802 `Downloaded from sealed`, 0 http(s). The clone ran the tests (its `package` and `install` builds do) and built the binary.
**Nothing was downloaded** for this unit outside the sealed clone's `file://` copy. The exercise by hand: README, then SOLUTION twice, in
one `env -i` shell — `exit 1 · … failures 1` and its two lines, then `exit 0 · … failures 0` twice (idempotent), the shell still in
`c6-unit28`; SOLUTION alone in a fresh shell whose `JAVA_HOME` is the Mac's openjdk 23 (`java -version`: 23.0.1) — `exit 0 · … failures
0` (its exports come first); the README's last line alone with `JAVA_HOME` = 23 — refused at compile (`release version 25 not supported`
in `.harness/mine/test.log`; the line prints `exit 1 · RevenueTest:` and `sed`'s "No such file"); the same line with no `JAVA_HOME` —
Homebrew's `mvn` runs on its openjdk 26.0.2.1 and passes. Planted faults: 33 of 33 stop under each bash ("Found on the way").

Published hashes: change `6718da19d26287c405f8276c3b8fb624` · slice `caf0232b9d3429272fcd8cc0bb20b498` · requests `4b2b78cfef4fa62065cc4d80bceb4951` · untested `57eb93281036262d002d7feb602a77da` · fullstack `87afa0a3acf2da027d0e1262042e044b` · exercise `8d38b0b5f0478b9f7377f677d273e9b1` · forms `c6fd936b099b211f480a6c41339b90b5`.

### A sealed fresh clone — the recipe (R.129; RED S4 #405), with one change

The recipe unit 24 publishes, with one change this unit needs: the `.mavenrc` keeps the caller's own `MAVEN_OPTS` after the sealing
`-Duser.home` (`MAVEN_OPTS="-Duser.home=… $MAVEN_OPTS"`). `mvn` reads `$HOME/.mavenrc` after the caller's environment and the recipe's
file *assigns* `MAVEN_OPTS`, so `change`'s one command that sets `MAVEN_OPTS` itself (German words, to show they never reach the test JVM)
would lose them in the clone and print `Default locale: en_US` — a capture that differs only because the seal ate the variable. The
`-Duser.home` stays first, so the seal is the same.

```bash
S=/tmp/sealed-28                                   # an empty folder of your own; T = your tiffinbox-java clone
mkdir -p "$S/home/.m2" && git clone -q "file://$T" "$S/tiffinbox-java"
rsync -a --exclude _remote.repositories --exclude '*.lastUpdated' --exclude resolver-status.properties "$T/c6-unit28/.m2-demo/" "$S/central/"
printf 'MAVEN_OPTS="-Duser.home=%s $MAVEN_OPTS"\n' "$S/home" > "$S/home/.mavenrc"     # mvn reads $HOME/.mavenrc; Java then reads this user.home
cat > "$S/home/.m2/settings.xml" <<XML
<settings>
  <mirrors><mirror><id>sealed</id><mirrorOf>*</mirrorOf><url>file://$S/central</url></mirror></mirrors>
  <proxies>
    <proxy><id>dead-http</id><active>true</active><protocol>http</protocol><host>127.0.0.1</host><port>9</port></proxy>
    <proxy><id>dead-https</id><active>true</active><protocol>https</protocol><host>127.0.0.1</host><port>9</port></proxy>
  </proxies>
</settings>
XML
X=http://127.0.0.1:9; E="env -i HOME=$S/home PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin http_proxy=$X https_proxy=$X HTTP_PROXY=$X HTTPS_PROXY=$X no_proxy=127.0.0.1,localhost NO_PROXY=127.0.0.1,localhost GRAALVM_HOME=$GRAALVM_HOME DOCKER_CONFIG=$HOME/.docker"     # this unit's native build and image need both (your own GraalVM and Docker)
# pre-flight: an artifact that exists nowhere, asked for through the sealed settings - it must fail, having asked file:// and nothing else
$E JAVA_HOME=/opt/homebrew/opt/openjdk@25 mvn -B -Dmaven.repo.local="$S/preflight-m2" org.apache.maven.plugins:maven-dependency-plugin:3.8.1:get -Dartifact=org.example.sealed:absent:1 > "$S/preflight.log" 2>&1
[ $? != 0 ] && grep -q 'Downloading from sealed: file://' "$S/preflight.log" && ! grep -qE 'Downloading from [^ ]+: https?://' "$S/preflight.log" && echo "sealed: file:// only" || echo "NOT SEALED - do not run receipts.sh"
cd "$S/tiffinbox-java/c6-unit28" && $E ./receipts.sh            # a process group of its own (a terminal's foreground job is one)
# post-check: every artifact's origin, by repository id - each line must say sealed; 0 central
find .m2-demo -name _remote.repositories -exec cat {} + | grep -o '>[^=]*=' | sort | uniq -c
```

The `$T/c6-unit28/.m2-demo/` it copies is this unit's, seeded from `../../spring-web-mvc/_research/m2-seed-s5/` alone (5,926 files: the
S4 seed and Section 5's 35 files — the test starter's four modules among them). The clone runs the tests (`package` and `install` do now) and
builds the binary.

## The commands this unit adds

`after/README.md` — the anchor's own — gives every line `receipts.sh` runs or derives from but these, which are this unit's, each read
from the block below and asserted to be exactly this (on the anchor's port 18431 where a port appears; each capture swaps in its own;
`COPY` is the name of the copy a capture makes under `.harness/`). Each is the anchor's line with one change, and the script asserts
that too: the two java lines pin the JVM's locale; the `-Dtest=`, `-DargLine=` and `MAVEN_OPTS` lines are the README's
`mvn -B -pl tiffinbox-web -Dtest=TiffinBoxWebTest clean test` with that one option changed or added; the deps line is the README's
`mvn -B package` with `dependency:list`; the invalid POST is the README's POST with the slice test's invalid customer. Every Maven
line runs offline against `.m2-demo`: `-o -B -Dmaven.repo.local="$M2"` after `mvn`, and `clean` before a lifecycle phase the README
line names without it.

```bash
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
mvn -B package dependency:list -DoutputFile=target/deps.txt
rsync -a harness/test/ .harness/COPY/tiffinbox-web/src/test/
f=tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java && sed '/@ContextConfiguration(classes = WebSlice.class)/d' "$f" > "$f.new" && mv "$f.new" "$f"
f=tiffinbox-web/src/test/java/com/tiffinbox/web/TiffinBoxWebTest.java && sed 's/@ContextConfiguration(classes = WebSlice.class)/@ContextConfiguration(classes = TiffinBoxApp.class)/' "$f" > "$f.new" && mv "$f.new" "$f"
mvn -B -pl tiffinbox-web -Dtest='TiffinBoxWebTest#theSliceLeavesTheDatabaseOut,FullStackTest' clean test
mvn -B -pl tiffinbox-web -Dtest=TiffinBoxWebTest '-DargLine=-Duser.language=de -Duser.country=DE' clean test
mvn -B -pl tiffinbox-web -Dtest=TiffinBoxWebTest '-DargLine=-Duser.language=en -Duser.country=US -Dspring.mvc.problemdetails.enabled=false' clean test
mvn -B -pl tiffinbox-web -Dtest='TiffinBoxWebTest#aFailingRepositoryLeavesNoStatus,SliceLimits,Chains' clean test
mvn -B -pl tiffinbox-web -Dtest=FullStackTest,Answers clean test
mvn -B -pl tiffinbox-web -Dtest=FullStackTest clean test
sed 's/^package slice;/package com.tiffinbox.web;/; s/^public class WebSlice /public class WebSliceInside /' tiffinbox-web/src/test/java/slice/WebSlice.java > tiffinbox-web/src/test/java/com/tiffinbox/web/WebSliceInside.java
mvn -B -pl tiffinbox-web -Dtest=TemplateCheck clean test
MAVEN_OPTS='-Duser.language=de -Duser.country=DE' mvn -v
MAVEN_OPTS='-Duser.language=de -Duser.country=DE' mvn -B -pl tiffinbox-web -Dtest='TiffinBoxWebTest#theTestsRunInEnglish' clean test
curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":0,"mealType":"VEG"}' http://127.0.0.1:18431/customers
```

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else, refuses one whose `native-image --version` is not
`native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1`, and never prints its folder (`$GRAALVM_HOME` in every capture). Only `forms`
needs it. **Without a GraalVM** the script makes the six other captures, each checked against `receipts.md5`, then stops where the
native build would start (exit 1).

## The repository, Docker, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../spring-web-mvc/_research/m2-seed-s5/` alone (5,926 files) before each run of record. **Nothing was downloaded** for this unit:
every build said `offline: yes`, every test run's log holds 0 `Downloading from` lines, the native plugin read its metadata repository
from `.m2-demo`, and every native build log holds 0 lines of the plugin's own download. A fresh clone's `.m2-demo` is empty (git ignores
it): the first build — `after/`'s `mvn -B -Pnative install`, before any capture — fills it from Maven Central (in the sealed clone,
from the `file://` copy) and says `offline: no`. That first build runs the tests too, so it needs the test starter's jars: the S5 seed
holds them (its 35 files over the S4 seed). **Docker:** no pull — `docker build` prints its `load metadata` line and the base image's
digest, and `its lines that say pull: 0`. The image (`tiffinbox-tests:1.0.0`) and the container (`tiffinbox-tests`) are this script's
own names, checked absent first and removed on every exit. **At run time** every request goes to `127.0.0.1`.

## The demo token, and the tests' literal

The demo token — `TOKEN=` at the top of `receipts.sh`, 30 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/*/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) of every copy, mounted read-only into the container, and sent only by `../c5-unit11/curlset.sh` and `harness/shutdown.sh`
on curl's standard input. Every capture's raw output is searched for it before masking (0 in all of them), and so are the log of every
JVM that served, the container's log, every Maven log and every Surefire report of every test run, every file this unit ships, the
binary's bytes and every blob of the image (`docker save`): 0 everywhere. **The tests never read it**: they run in `tiffinbox-web/`,
where no `secrets/` folder is (the harness's `Census` prints `a secrets folder there: no` and `the settings record's token is the tests'
literal: yes` for every test class), and the settings record's required token comes from the tests' own `properties`:
**`not-the-real-token` — a literal written in the tests, not a secret**, 18 characters (the record asks for 16 or more). Each test run's
line counts it in the log and the reports (0, but 7 in `TemplateCheck`'s, whose failure message prints the test's properties).

## The locale — pinned per JVM, and the test JVM's by the POM

Every java line this script starts carries `-Duser.language=en -Duser.country=US` before `-jar` (S4.1), and a last check refuses any
capture's java line without them. **A test JVM is Surefire's own fork**: `MAVEN_OPTS` reaches Maven's JVM (`change`: `Default locale:
de_DE`) and not the fork (`en_US`); the POM's `argLine` does — `-Duser.language=en -Duser.country=US` — and every test run's reports
say which locale the fork had (`user.language`, `user.country`, read by `harness/surefire.py`): `en_US` in every run but `requests` C,
where `-DargLine` made it `de_DE` for that run (a check asserts both). `TiffinBoxWebTest#theTestsRunInEnglish` prints `the test JVM's
locale: en_US` once and asserts it. The binary's line passes no locale option. MockMvc's request has its own language: `Accept-Language`
absent → English, `de` → German, whatever the fork's locale (`requests` A and C).

## The folders, the names and the ports

- `after/` — the anchor after this change (= `../c6-tiffinbox`); `before` — the link to `../c6-unit24/after`. `.harness/before`,
  `.harness/after` — the two trees, copied, each with a config tree, built; `.harness/skip` — after/ built with `-DskipTests`;
  `.harness/alone`, `sliceA`, `sliceB`, `sliceC`, `req`, `lim`, `full` — copies of after/ (each a capture's own), the harness's test
  sources added (`hcopy`), `alone`'s and `sliceB`'s test changed by one line, `sliceC`'s given a copy of WebSlice inside
  `com.tiffinbox`; `.harness/nat` — after/'s native build; `.harness/pre` — the first build (it fills `.m2-demo` and installs both
  modules, which every `-pl tiffinbox-web` line takes `tiffinbox-core` from); `.harness/mine` — the exercise's copy.
- **The harness** — the course's, never TiffinBox's (package `probe.web`, outside `com.tiffinbox`; `harness/test`, copied into a copy's
  `tiffinbox-web/src/test`, never into `after/`): `Census` — a `TestExecutionListener` (`harness/test/resources/META-INF/spring.factories`
  names it; Spring's TestContext framework runs it around every test class): once per test class it prints the context's beans, all
  counted and TiffinBox's named by the `com.tiffinbox` filter; the servlet context; MockMvc's filters (read off `MockMvc` by
  reflection); the web server, the port's range, and this test JVM's listening sockets (`lsof -nP -a -p <its own pid> -iTCP
  -sTCP:LISTEN`, the server's port shown as `<port>`, another cached context's as `<another context's port>`); the JVM's locale and
  working directory, whether a `secrets/` is there, whether the settings record holds the tests' literal; and it adds one result handler
  to MockMvc (by reflection, as MockMvc's builder would) that prints an `EXCHANGE` line for every answer MockMvc completes. It changes no
  bean. `ChainDump` + `Traced` — a plain filter, registered for the `REQUEST` and the `ERROR` dispatch, that prints the chain a request
  runs in (Tomcat's `ApplicationFilterChain`, as the filters lesson read it; MockMvc's `MockFilterChain`). `SliceLimits` (TiffinBox's slice
  with `Traced`: a repository that throws, a page whose dashboard throws), `Chains` (the full-stack setup with `Traced`), `Answers` (the
  full-stack setup, its answers printed), `TemplateCheck` (`@AutoConfigureTestRestTemplate`) — test classes Surefire runs only when
  `-Dtest` names them (their names match none of its default patterns). `harness/surefire.py` reads Surefire's reports;
  `harness/shutdown.sh` is the CORS lesson's, byte for byte.
- **Ports** (brief ⚑1, 19570-19574): after/'s jar 19570 · the AOT jar 19571 · the binary 19572 · the image 19573 (published on
  127.0.0.1) · the previous tree's jar 19574. All five, 18425, 8080 and 35729 are checked free first. **A test's server** (`FullStackTest`,
  `Chains`, `Answers`) takes the port the system picks — macOS's ephemeral range here, 49152-65535 (`sysctl net.inet.ip.portrange`,
  printed in `fullstack`), never one of the course's 19300-19799 (`Census` checks both) — ⚑1's exception for §P, for BLUE to write; its
  bind is read off the test JVM's pid, and the port is masked in every capture.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM, the token, the user, a request thread's number, the Java version** (`gsub()`, literals escaped), in every line:
   the demo token → `[masked: the 30-character token]`; the GraalVM's folder → `$GRAALVM_HOME`; this folder → `…`; the folder above →
   `…/..`; home → `~`; the user name, as a whole word → `<user>`; `tomcat-handler-<digits>` → `tomcat-handler-<n>`; `$$SpringCGLIB$$<digits>` →
   `$$SpringCGLIB$$<n>`; ` using Java <digits>` → ` using Java <version>` (Boot's first line; the version is printed on the terminal once).
2. **A Maven log** is never printed whole (`mrun`): its `$` line, its exit code and `BUILD` line, `offline` (its `Downloading from` lines
   counted), Surefire's reports read by `harness/surefire.py`, Surefire's console summary beside the reports' sum (R.144: never the
   console alone), the harness's lines (`CENSUS` sorted by test class; `EXCHANGE`, `CHAIN`, `LIMIT`, `ANSWER` in the order they ran —
   the harness prints ASCII, each other character as `\uXXXX`, decoded back by `dec()`), Mockito's and the JVM's console lines (counted;
   shown once, in `slice` A, labelled), its WARN and ERROR records (`recs`: level, logger, message, the exception line under it; frames
   bounded "over 40", other lines counted; an object's identity hash `@…`; a line over 200 characters cut, the rest counted), and a count
   of the rest. The demo token and the tests' literal counted in the log and every report.
3. **Surefire's reports** (`surefire.py`): each report's counts, each test case's verdict (passed, FAILED, ERROR), a failure's type, the
   first two lines of its message and each distinct `Caused by:` line (up to six; an identity hash `@…`; a line over 200 characters cut),
   the fork's `user.language` and `user.country` — never a time, never another property (they hold paths).
4. **Answers**: a JSON body as its bytes, keys sorted (`sortj`), Spring's timestamp `…`; a page as its `<title>`; the seven as
   `curlset.sh` prints them, the timestamp mask's count printed (0). The native build's lines through a declared filter (stages,
   warnings, BUILD), the rest counted; `docker build`'s through `blines` (metadata, base digest, naming), the rest bounded.
5. **Hygiene, checked last over every capture:** no absolute path, no GraalVM folder, no unit number, no Boot process line, no
   Surefire booter path, no test time, no log time, no timestamp, no thread number, no OS or JDK version token (`Java 25.`, `Macintosh`,
   `Darwin`, `arm64` …, R.128), no random port (`127.0.0.1:` or `port ` followed by 49152-65535), no stack frame; every `$` line's URL is
   `127.0.0.1`'s; every java line pinned; no `pkill`/`killall`; no bare `wait`; no Boot 3 error or client key; no `-p` without
   `127.0.0.1:`; no harness class in `com.tiffinbox`. No duration is captured: the native build's seconds go to the terminal only.

## The Hibernate Validator file (R.145)

GraalVM's native plugin maps two directories of its metadata repository — Hibernate Validator's own `9.1.0.Final` and jboss-logging's
`3.5.0.Final` — to one file, `META-INF/native-image/org.hibernate.validator/hibernate-validator/9.1.3.Final/reachability-metadata.json`,
and the last one written wins: 2,306 or 157,308 bytes, build to build (the brief's probe, six builds). `forms` reads the file each native
build made, in `target/classes` and in the jar (the same), prints its size on the terminal — never in a capture, never hashed — and asserts
the binary's validation answer (the invalid customer's three messages). **A binary whose validation failed would stop the run** (exit 3,
"STOP (R.145) … do not re-run"), for BLUE to decide the fix; none did.

**Measured here** — every `forms` run of this unit that reached its end (development runs, runs of record, the sealed clone: 12 runs,
three builds each), the sizes as the terminal printed them: `157308 2306 157308` · `157308 2306 157308` · `157308 157308 157308` ·
`157308 157308 157308` · `157308 2306 157308` · `157308 157308 157308` · `2306 157308 2306` · `157308 157308 157308` · `157308 157308
157308` (the sealed clone) · `157308 2306 157308` · `157308 157308 157308` (the last /bin/bash 3.2 run of record) · `157308 2306 157308`
(the last bash 5.3 run of record). **36 native builds: 2,306 bytes 7 times, 157,308 bytes 29 times, and every binary validated** (the
three messages, the seven `466c20ed…`, the page — each `forms` capture 3/3 and its checks passed). RE-MEASURE 11 settled for these
builds: a binary that shipped the 2,306-byte file answered as the 157,308-byte ones did — here, on this Mac, in 7 builds. Which file a
build gets is still decided by the native plugin's mapping, not by TiffinBox; no capture depends on it, and the receipt still stops if a
binary fails (§BLOCKED stays BLUE's to close in the anchor, or the capstone's).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the Maven it
waits for (`$mpid`, with every process under it — Surefire's fork, `native-image`'s driver and builder — `killtree`), the exercise's
shell (`$xpid`, with every process under it), sweeps its own process group for any TiffinBox JVM, binary, Maven, Surefire fork or
`native-image` left, removes the container and the image, deletes the capture runs it had not finished (`.r-NAME.1-3`), and removes
`.r-lock`. The published captures are untouched. No `wait` in the script or the exercise is bare (a check refuses one).

**Measured** on the script as committed (2026-10-28), started as a terminal starts its foreground job — a process group of its own, SIGINT
at its default (from a script, `python3` with `signal.signal(signal.SIGINT, signal.SIG_DFL)` and `os.setpgrp()`: a job a script starts
in the background inherits SIGINT ignored, and bash cannot trap a signal ignored on entry — my first attempt ran to its end, exit 0, all 7
= published) — SIGINT to the group three times: **during a capture's JVM** (`change`, the previous tree's jar listening on 19574; 4
processes in the group), **during Maven's test fork** (`slice` A, Surefire's fork running; 5 processes), and **during the native build**
(`forms`, native-image's driver and builder running; 4 processes). Each time: **exit 130** within a second; 5 s later 0 processes in the
group, 0 TiffinBox JVMs, Surefire forks, binaries or native-image builders anywhere; 19570-19574, 18425, 8080 and 35729 free; no
`tiffinbox-tests` container or image; no `.r-lock`; no unfinished capture run; the published captures unchanged (md5 of all seven, before
and after).

## 1 · change — the tests' starter, the argLine, three test sources

The previous tree and after/, copied: 2 files differ (the README, `tiffinbox-web/pom.xml`), 3 are new (the three test sources), 31 of
36 byte for byte. The POM's diff, whole: two hunks, 15 lines in, none out — the `<properties>` block with `argLine` and the starter in
test scope; `<build>` line for line the previous tree's. The seven, on each tree's jar, a fresh JVM each: `466c20ed…` both, the same,
byte for byte: 7. Each tree built with the README's `mvn -B package` (and `dependency:list`): the previous tree's build ran no test (no
report; `No tests to run.` twice, core and web), after/'s ran 11 (2 reports, 0 failures, the fork `en_US`; `surefire:3.5.6:test`). The
starter's POM: 5 dependencies, `spring-boot-starter-webmvc` already on the class path, 4 new. The class path Maven resolved for the web
module: 70 artifacts → 103 — compile 67 and runtime 3 both times, **33 new, every one in test scope** (listed whole), none gone; no
`spring-boot-restclient`, `spring-boot-resttestclient` there. The classes the tests use, each read off the jar that holds it (R.134):
`WebMvcTest` — spring-boot-webmvc-test; `SpringBootTest` — spring-boot-test; `MockMvc`, `MockMvcTester`, `MockitoBean`, `RestTestClient`
— spring-test; `AutoConfigureRestTestClient`, `TestRestTemplate` — spring-boot-resttestclient; `TypeExcludeFilter` — spring-boot;
`Mockito` — mockito-core; a class named `MockBean` in any of the test class path's jars: none. The executable jars: 61 libraries, the
same names; 218 entries each, one differs — `META-INF/maven/com.tiffinbox/tiffinbox-web/pom.xml`; tiffinbox-core's jar the same, byte for
byte; no test class in after/'s jar. Course 4's `mvn -q -DskipTests package` (a copy): exit 0, nothing printed, 0 reports, the jar built,
its libraries the same 61. `MAVEN_OPTS='-Duser.language=de -Duser.country=DE' mvn -v` → `Default locale: de_DE`; the same `MAVEN_OPTS`
on one test method → passed, the fork `en_US`, the test's own line `the test JVM's locale: en_US`.

## 2 · slice — alone; A/B/A′; C (labelled)

TiffinBoxApp's annotations (`@Configuration`, `@EnableAutoConfiguration`, `@ComponentScan("com.tiffinbox")`,
`@EnableConfigurationProperties`); a `@SpringBootConfiguration` or `@SpringBootApplication` in after/'s main sources: 0 files; in its test
sources: `slice/WebSlice.java`. The three mocked classes are `public final class`. **Alone** (a copy, `TiffinBoxWebTest`'s
`@ContextConfiguration` line deleted): exit 1, `ERROR (the class: no test method ran) - java.lang.IllegalStateException`, `Unable to find a
@SpringBootConfiguration by searching packages upwards from the test. You can use @ContextConfiguration, @SpringBootTest(classes=...) or
other Spring Test supported mechanisms to explicitly declare the configuration classes to load. …`. **A** (after/ with Census;
`-Dtest='TiffinBoxWebTest#theSliceLeavesTheDatabaseOut,FullStackTest'`): the slice — 130 beans, TiffinBox's 7:
`com.tiffinbox.CustomerRepository#0`, `com.tiffinbox.Dashboard#0`, `com.tiffinbox.OrderQueue#0` (the mocks), `dashboardPage`,
`tiffinBoxErrors`, `tiffinBoxServer`, `tiffinbox-com.tiffinbox.TiffinBoxProperties`; the whole application (`FullStackTest`) — 293, 11
(`customerRepository` the mock, `database`, `kitchenHealthIndicator`, `kitchenMetrics`, `orderQueue`, `tiffinBoxApp` among them);
`theSliceLeavesTheDatabaseOut` passed; MockMvc's 4 filters; Mockito's line and the JVM's five, shown here once, labelled. **B** (the line
changed to `TiffinBoxApp.class`): the slice — 134, TiffinBox's 11 (the application's same names), `FAILED theSliceLeavesTheDatabaseOut -
java.lang.AssertionError`, `Expecting empty but was: ["database"]`, exit 1. **A′** = A (its `$` line: the `mvn` command and the test
method's name). **C (labelled)** (a copy of WebSlice inside `com.tiffinbox.web`, beside the one in `slice`; `FullStackTest`): the
application's context — 294, TiffinBox's 12, `webSliceInside` among them: TiffinBoxApp's scan picked it up (R.143).

## 3 · requests — the slice's answers, without a socket

`TiffinBoxWebTest`, the README's line, Census joined: 9 passed. The answers MockMvc completed, six (`EXCHANGE`): `GET /dashboard` 200
`text/html;charset=UTF-8`, `<title>Dashboard · TiffinBox</title>`; `POST /customers` (no `Accept-Language`) 400 `application/problem+json`,
`the customer breaks 3 rules`, `must be greater than or equal to 1` ×2, `must not be blank`; `GET /shutdown` 405, `Allow: POST`, a problem
detail; `GET /customers` 200 `application/json` Ravi; `GET /customers/Nobody` 404 `application/problem+json`, `"name":"Nobody"`; `POST
/customers` (`Accept-Language: de`) 400, `muss größer-gleich 1 sein` ×2, `darf nicht leer sein`. One WARN, Spring MVC's `PageNotFound`
(the 405). The test's own line `the test JVM's locale: en_US`. **C (labelled)** — `-DargLine=-Duser.language=de -Duser.country=DE` (it
replaces the POM's): the fork `de_DE`; `FAILED theTestsRunInEnglish` (`expected: en_US`, `but was: de_DE`); the six answers the same — no
`Accept-Language` still English. **D (labelled)** — `-DargLine`, the POM's locale and `-Dspring.mvc.problemdetails.enabled=false`
(TiffinBox's key: `true`, line 70 of after/'s `application.yaml`): the 404 and the 400 the same — TiffinBox's own problem details — and the
405 `Content-Type: null`, no body; 9 passed (the 405's test checks the status and `Allow`).

## 4 · untested — what the slice did not run

`-Dtest='TiffinBoxWebTest#aFailingRepositoryLeavesNoStatus,SliceLimits,Chains'`, Census and `Traced` joined. **The slice**
(`SliceLimits`): `GET /revenue` with a repository that throws — the exception nobody handled `jakarta.servlet.ServletException: Request
processing failed: java.lang.IllegalStateException: kitchen on fire`, a response: none (`getResponse()` throws `IllegalStateException:
Request failed with unresolved exception …`); the older `MockMvc.perform` throws the `ServletException`; `GET /dashboard` as HTML with a
dashboard that throws — the same, `page on fire`; each request ran one chain, `REQUEST`, MockMvc's `MockFilterChain` (its filters and
spring-test's `ServletFilterProxy`). **Tomcat** (`Chains`, the full stack): the same failing `GET /revenue` ran `REQUEST` —
`ApplicationFilterChain`, 7 filters (`characterEncodingFilter`, `webMvcObservationFilter`, `formContentFilter`, `requestContextFilter`,
`chainDump`, `resourceUrlEncodingFilter`, `Tomcat WebSocket (JSR356) Filter`) — then `ERROR /error` (5 filters), and answered 500
`application/json`; Tomcat's ERROR record (`[dispatcherServlet]`). MockMvc's filters (`TiffinBoxWebTest`'s): 4; Tomcat's, less the
harness's own: 6. The slice's servlet context `SpringBootMockServletContext`, no web server; the full stack's `ApplicationContextFacade`,
`TomcatWebServer`. `aFailingRepositoryLeavesNoStatus` passed.

## 5 · fullstack — the real server

This Mac's range for a port the system picks: `49152-65535` (`sysctl net.inet.ip.portrange`). `FullStackTest` and `Answers`
(`-Dtest=FullStackTest,Answers`), Census joined: the web server `TomcatWebServer on port <port>`, the port in that range: yes, in the
course's: no; this test JVM's listening socket `127.0.0.1:<port>`; the context 293, 11; the settings record's token the tests' literal,
no `secrets/` in `tiffinbox-web`. The answers (`ANSWER`): `GET /revenue` (a repository that throws) 500 `application/json`
`{"timestamp":"…","status":500,"error":"Internal Server Error","path":"/revenue"}`, its keys 4; `GET /nowhere` 404
`application/problem+json`, `No static resource nowhere.`; `GET /dashboard` as HTML (a repository that throws) 500 `text/html`, `Something
broke · TiffinBox`. Tomcat's ERROR records, three (the two `/revenue` answers — the test's and `Answers`' — and the page), each labelled
by its logger. Both `FullStackTest` tests passed. **C (labelled)** — `TemplateCheck` (`@AutoConfigureTestRestTemplate`): `ERROR nowhere -
java.lang.IllegalStateException`, `Failed to load ApplicationContext …`, its causes ending `NoClassDefFoundError:
org/springframework/boot/restclient/RestTemplateBuilder`, `ClassNotFoundException` for the same class; exit 1.

## 6 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s five lines, then `exercise/solution/SOLUTION.md`'s four, in one `env -i` shell (`/bin/bash --noprofile --norc`,
started in this folder): as shipped `exit 1 · RevenueTest: tests 1 · errors 0 · failures 1` and `Request failed unexpectedly:
jakarta.servlet.ServletException: Request processing failed: java.lang.IllegalStateException: kitchen on fire`; after the solution's line
`exit 0 · RevenueTest: tests 1 · errors 0 · failures 0`; the shell in this unit's folder after each; the demo token 0 times in the copy's
test log; the copy has no `secrets/` (the test needs none).

## 7 · forms — four forms, the tests run by the build

The native build of after/ (`.harness/nat`): `mvn -B -Pnative install` ran the 11 tests (2 reports, 0 failures, the fork `en_US`), then
`native:compile-no-fork`: 8 of 8 stages, `BUILD SUCCESS`, offline, 0 lines of the plugin's own download; `Mach-O 64-bit executable`, the
demo token in its bytes 0, the tests' literal 0, `TiffinBoxWebTest`/`FullStackTest`/`WebSlice` 0 each. The Hibernate Validator file:
its size on the terminal (R.145, above). after/'s plain build ran the 11 too. **The jar** (19570), **the AOT jar** (19571, `Starting
AOT-processed …`), **the binary** (19572), **the image** (`tiffinbox-tests:1.0.0`, published on `127.0.0.1:19573`, `[::]:18425` inside):
each one's address loopback; the seven `466c20ed…`, exit 0, 0 tokens in its log; then, on a second start, the invalid customer → 400
`application/problem+json` with the three messages (keys sorted), and `/dashboard` as HTML → `<title>Dashboard · TiffinBox</title>`.
`four forms, one tree: the seven (masked) 4 of 4 … the invalid customer 400 with the three messages: 4 of 4 · the page's title … 4 of 4`.
The image: its base image's digest printed, 0 pulls, 0 tokens in its 11 layers (15 blobs, `docker save`).

## Exercise

**Your turn:** the README's test expects a five hundred from a failing repository, and fails. Assert what MockMvc really saw, and run it
again. `exercise/README.md` copies `after/` to `.harness/mine/after`, puts `exercise/RevenueTest.java` among its tests (`@WebMvcTest`,
`WebSlice`, the three mocks, a repository that throws, `assertThat(tester.get().uri("/revenue")).hasStatus(500)`), and its last line runs
that one test offline in a subshell (`mvn -o -B -q -Dmaven.repo.local="$M" -pl tiffinbox-web -Dtest=RevenueTest clean test`), then prints
Maven's exit code, the report's counts and — when it failed — the first two lines of its failure: as shipped `exit 1 · RevenueTest: tests
1 · errors 0 · failures 1` / `Request failed unexpectedly: … kitchen on fire`. Done is `exit 0 · RevenueTest: tests 1 · errors 0 ·
failures 0`. Measured answer: `exercise/solution/SOLUTION.md` (the README's two `export` lines, the `sed` that makes the assertion
`hasFailed().failure().hasMessageContaining("kitchen on fire")` — idempotent — and the README's last line again), run in the same shell.
Run `./receipts.sh` once first on a fresh clone (it fills `.m2-demo` and installs `tiffinbox-core` there, which `-pl tiffinbox-web` needs).

## The anchor's README — what this unit changed in it

`../c6-tiffinbox/README.md` (= `after/README.md`) gains its `## Course 6 · unit 28` section (after unit 24's, before Course 5's README
begins) with three lines of its own (`mvn -B clean test`, `mvn -B install`, `mvn -B -pl tiffinbox-web -Dtest=TiffinBoxWebTest clean
test`; the second was already the buildpack section's line) and **five history notes amended in place**, found by grepping the README for
`mvn `, `package`, `install`, `verify`, `test`, `skipTests`, `src/test`, `Surefire` and `downloads` (S2.22, S5.11), each hit read:
- Course 4's `mvn -q -DskipTests package` — true, and now meaningful: `-DskipTests` skips TiffinBox's tests; without it `package` runs
  them, and a failing test fails the build (`change`: the skip build, no report; slice B: a failing test, `BUILD FAILURE`).
- Course 3's "Build" (already marked stale since Course 5 unit 13) — web's `surefire:3.5.6:test`, which said `No tests to run.`, runs the
  eleven tests before the jar is made (`change`).
- Course 3's "Requirements" ("The first build downloads H2 … and Jackson …; after that, nothing") — the tests' class path needs 33 more
  jars, every one in test scope (`change`).
- Course 3's "Verified" (`mvn -o -B verify` → `BUILD SUCCESS`) — measured when TiffinBox had no tests; `package` and `install` run its
  eleven since (`change`, `forms`).
- Course 5 unit 19's native-profile paragraph (what `-Pnative package` runs) — these builds, like every `package` and `install`, run the
  tests first; `-Pnative install` ran them before the binary (`forms`).

Left as they were, and still true (each read): every other `mvn -B package` line (Course 6 unit 04's run block; Course 5's Docker block (unit 16), Actuator block
(unit 21), banner block (unit 27) and `dependency:build-classpath` lines (units 17 and 27)) — each still builds what it says,
now after the tests, which the new section says once for all of them; Course 3's `mvn -B clean install` + `exec:exec` (two commands,
still); Course 3's "Building part of it" table (its `-pl`/`-am` rows are still Maven's behaviour; the tests run in web's build);
Course 3's header's list of what Course 3 would add ("a test source tree" — Course 3's plan, history). The Dockerfile's own comment
(`mvn -B package`) is not this unit's file and stays true.

## The ledger rows and hand-offs this unit pays

| Row | Paid how | Where |
|---|---|---|
| **C6-31**'s U28 flag (MockMvc: if a course uses it, a course teaches it) | MockMvc glossed where it is first used ("Spring's request simulator: the `DispatcherServlet` runs, with no socket and no Tomcat"), used (`requests`), its limits measured (`untested`); a test, a test slice, a mock, `@MockitoBean`, a full-stack test, a random port glossed at first use; Mockito's console lines labelled | script, `requests`, `untested` |
| **S3 CARRIED** "`/error` and the Whitelabel page are not rendered there; problem details assert by `application/problem+json`" | no ERROR dispatch, no `/error`, no `error/5xx.html` in the slice (`untested`); the slice's 404, 400, 405 are `application/problem+json` (`requests`) — the 405's because of TiffinBox's key (D) | `requests`, `untested` |
| **S4 CARRIED** "no ERROR dispatch, no filter chain as the filters lesson printed it; no real preflight cache" | ERROR dispatch measured both ways; MockMvc's 4 filters beside Tomcat's 6, read off each chain; the preflight cache named, not measured | `untested` |
| Roadmap Amendment A (the point-of-use slice; Course 7's `@DataJpaTest` in the same `src/test`) | the anchor's `src/test` exists, with a slice and a full-stack test | `after/` |
| #385 `@Size(max = 60)` (deferred to the capstone) | not paid here: the tests do not pin the 61-letter 500 (the full stack's 500 comes from a mock) | — |

## RE-MEASURE — the brief's items this unit settles

| # | What | Settled |
|---|---|---|
| 8 | the slice and full-stack tests as the anchor's own files | `TiffinBoxWebTest`, `FullStackTest` in after/ (`change`, `slice`, `requests`, `fullstack`) |
| 9 | `argLine` as a POM property | the fork `en_US` in every run but C, which `-DargLine` makes `de_DE`; `MAVEN_OPTS` reaches Maven only (`change`) |
| 10 | the four forms on 28/after, the image included; the HV file per build; the binary's invalid POST | `forms`, 3 builds a run; sizes below |
| 11 | a binary with the 2,306-B HV file | built and validated in this unit's development runs (below) |
| 13 | the exercise as viewers run it | one `env -i` shell (`exercise`); by hand under Java 23 and with no `JAVA_HOME` (below) |
| 15 | Tomcat's chain on 28/after beside MockMvc's | `untested`: 6 (+ the harness's) and 4 |
| 16 | 7/130 and 11/293 on 28/after's class path | `slice` A, A′ |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

1. **The 404 and the 400 are not problem details "because TiffinBox switched them on"** (the brief's `requests` line). `TiffinBoxErrors`
   and `TiffinBoxServer` return their own `ProblemDetail`s; with `spring.mvc.problemdetails.enabled=false` for one run they are unchanged,
   and only the 405 loses its body (`requests` D). The voice says the key of the 405 alone.
2. **Mockito's console lines are six, not five**: Mockito's one, the JVM's five (four `WARNING:` lines and `OpenJDK 64-Bit Server VM
   warning: Sharing is only supported …`).
3. **The bind is read by the harness, inside the test JVM** (`Census`, `lsof` on its own pid), not by `FullStackTest`: a shipped test that
   runs `lsof` would fail on a machine without it; TiffinBox's tests stay portable.
4. **The starter's POM names five dependencies**; Spring MVC's starter is one, already TiffinBox's — four are new.
5. **A 2,306-B Hibernate Validator file shipped in a binary, and that binary validated** (RE-MEASURE 11), here.
6. **The full context's 293 holds `FullStackTest`'s mock** in the repository's place (`customerRepository`, the same 11 names); B's slice
   holds 134 — the same 11 TiffinBox names as the application.
7. **C (WebSlice inside `com.tiffinbox`) measured, not carried**: the application's context 294, TiffinBox's 12.

## Found on the way

- **An edited script under a running bash.** bash reads a script as it runs it: editing `receipts.sh` during the first development run
  shifted the bytes under it. That run was interrupted (SIGINT to its group: exit 130, nothing left) and every later development run ran a
  copy; the runs of record ran the file as committed, untouched while they ran.
- **The test JVM's console is ASCII here.** Under `LC_ALL=C` (this script's), the fork's `System.out` writes `?` for `·` and `ö`: the
  harness's lines came out `130 ? TiffinBox's`, `muss gr??er-gleich`. The harness now prints ASCII with `\uXXXX` escapes (`Census.print`)
  and the script decodes them (`dec`); Boot's own log lines are ASCII.
- **A′ against A** differed by the six console lines A showed once: the comparison sets them aside, and says so.
- **A failure message holds identity hashes** (`WebMergedContextConfiguration@39dec536`, a class loader's `@7a8c5397`): `surefire.py` and
  `recs` mask `@<hex>`; three runs drifted until they did.
- **Another context's port.** Spring caches a test context, so while `Chains` ran, `FullStackTest`'s Tomcat still listened in the same
  JVM: `Census` shows any port not its own context's as `<another context's port>`.
- **A proxied test configuration.** `WebSliceInside`'s bean type is its CGLIB subclass (`WebSliceInside$$SpringCGLIB$$<n>`, masked as
  every capture masks it); the check reads that name.
- **Surefire's default patterns** run `*Test` classes only: `SliceLimits`, `Chains`, `Answers` and `TemplateCheck` are named so they run
  only when `-Dtest` names them — a plain `mvn test` of a harness copy runs TiffinBox's own two classes.
- **Quotes in a `${x/a/b}` replacement, inside double quotes, differ between bash 3.2 and 5.3**: a derivation check passed under 3.2 and
  stopped the first 5.3 run before its first build. Every replacement that holds a quote is a variable now; both bashes run the same lines.
- **`\$` inside a double-quoted `grep -E` pattern** is a bare `$`, an end-of-line anchor: the check for C's 12 beans could not match until
  it became three fixed-string greps.
- **The brief's sentence about the 404** (a problem detail "because TiffinBox switched them on") was tested with a control (`requests` D)
  and found wider than the code: TiffinBox's advice writes its own `ProblemDetail`; only the 405's rests on the key.
- **Planted faults** (R.65): every check above was shown failing on a planted fault before it was trusted — 33 plants, each on a fresh
  copy of the final captures and files, run through the script's own checks (its builds and captures cut out), under `/bin/bash` 3.2 and
  Homebrew bash 5.3: 33 of 33 stopped, each with its own words, under each. The plants: a raw token in a capture run and in this README;
  an absolute path; a JDK version token; a random port; a java line without its locale; a URL that is not 127.0.0.1's; a German fork
  where none was (and an English one where C's was German — the check tells the two apart); one of the 33 test-scope jars gone; a
  second differing jar entry; Maven's own locale English; 131 beans; B's failure turned to a pass; A′ not A; a console line shown twice;
  C's 12 turned to 11; a German message in English; D's 405 with its body back; an ERROR chain in the slice; MockMvc with 5 filters; the
  bind on every address; a fifth key in the 500; TestRestTemplate's cause gone; the exercise's done line failing; the seven 3 of 4; the
  binary's third message gone; a token in an image layer; a bare `wait`; a `pkill`; a harness class in `com.tiffinbox`; Boot 3's error
  key; a port published on every address.

## For RED

- **Read `../c6-unit28/after`** (= `../c6-tiffinbox` now): `tiffinbox-web/pom.xml` (152 lines, the starter at test scope, `argLine`, `<build>`
  untouched); `src/test/java/slice/WebSlice.java`; `TiffinBoxWebTest` (9 tests), `FullStackTest` (2). `mvn -B clean test` from a clone of
  it: 11 tests, 0 failures.
- **Re-check (RED B):** the four forms and the seven `466c20ed7e0d5439cb052f32ce09de1b` in each; the Hibernate Validator file's size in each
  native build you make and that binary's validation answer (the three messages) — a failing binary is a stop (R.145); 7 of 130 and 11 of
  293 (`slice` A) on after/'s class path, 134 / 11 for B, 12 for C; MockMvc's 4 filters beside Tomcat's 6 (`untested`); the bind read off
  the test JVM's pid (`fullstack`: `127.0.0.1:<port>`, the port in 49152-65535); every README line the tests made false (the five notes
  above) — and any this unit missed; the exercise in one shell, under `JAVA_HOME` = the Mac's 23, and with no `JAVA_HOME`.
- **SIGINT** during a capture's JVM, during Maven's test fork and during the native build; the sealed clone by the recipe above
  (`central` 0 by repository id).
- **Ports** 19570-19574 are this unit's; the image `tiffinbox-tests:1.0.0` / container `tiffinbox-tests` are this unit's names. RED B runs
  on 19640-19659; a receipt re-run binds this unit's own ports, so RED never runs while this unit's receipts run.
