# c6-unit08 — Request Bodies and HttpMessageConverter

Course 6 · Spring Web MVC · Section 2 (Controllers and Binding), its third unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16,
Spring Boot 4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5 for Spring), **GraalVM CE 25.3.4.1** (native-image
25.0.4.1), **Docker on OrbStack**, 2026-10-14. Until this unit no route took a request's body: a new customer POSTed to `/customers`
as JSON got Spring MVC's 405. This unit gives TiffinBox **`POST /customers`**, whose parameter is the request's body
(`@RequestBody Customer`), and measures who reads it (the first of Spring MVC's six message converters that can read a `Customer`
from the body's media type — the JSON one, on Jackson 3), how JSON becomes the Course 1 record (its canonical constructor), what
happens to JSON that doesn't fit (Spring's 400 and one WARN line, or nothing at all), what nothing checks yet (H2's refusals, 500s),
what the request's `Content-Type` decides (A/B/A′: 200, then 415), and what is left of TiffinBox's own Jackson 2 (nothing but the
annotations jar both Jacksons read).

**The anchor changes (brief ⚑2, ⚑7, ⚑9).** `after/` is this unit's frozen copy of `../c6-tiffinbox` after the change, and
`diff -rq -x target ../c6-tiffinbox after/` is empty. "Before" is `../c6-unit07/after` — the binding lesson's frozen tree, which
`c6-tiffinbox` equalled at c9a2d97. Both trees are read and copied under `.harness/`, never built in place. The change:
`TiffinBoxServer.java` — **`POST /customers`**, new (`Customer add(@RequestBody Customer customer)`: stores the record and returns it,
200; 197 lines → 215); `tiffinbox-core`'s `CustomerRepository.java` — **`add(Customer)`**, new (one `INSERT`, the four values parameters
of the SQL; 64 → 80); `tiffinbox-web/pom.xml` — **`com.fasterxml.jackson.core:jackson-databind` out**, two comments rewritten; `pom.xml` —
**`<jackson-2-bom.version>2.22.2</jackson-2-bom.version>` out**, with its comment; and the anchor's `README.md` (the unit section, and
sixteen history notes amended in place — fourteen the change made false, and two already false on the previous tree: Course 5's
configprops note, which names Jackson 2, and its mappings note's five rows, which the binding lesson left). `application.yaml`, `spring.factories`, the Dockerfile,
`compose.yaml` and the other classes are unchanged — 20 of the tree's 25 files byte for byte — and the jar holds 56 libraries where it
held 58 (`change`, `jackson`).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 9 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) **Docker must
answer** (`docker info`; on OrbStack `orb start` is tried once if it does not), with `eclipse-temurin:25-jre` already on it: the
script never pulls. It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first). One native
build per `forms` run (three per receipt), judged against a bound (under 20 minutes); its seconds go to the terminal only. **Start it
in a process group of its own** (a terminal's foreground job is one): two receipts started as background jobs of one shell share a
group, and one run's clean-up would stop the other's JVMs (Section 1's finding, brief S2.4).

**Runs of record (2026-10-14, this script as committed):** **1,016 s under `./receipts.sh`** (/bin/bash 3.2.57, this folder, its own
process group, exit 0, all 9 = published, every check passed; the three native builds 193, 200 and 195 s) and **962 s under `bash receipts.sh`**
(Homebrew bash 5.3.9, the same; 175, 188 and 207 s). The hashes were made by earlier runs of this script, every capture 3/3 each time:
a first run under `bash receipts.sh` made seven of them and stopped, as it must, at "no published hash"; `unchecked`'s and `jackson`'s
were made again, by a run without a GraalVM under `./receipts.sh`, once their cuts were counted; `change`'s moved when the anchor README
gained five more amended notes — its new value, computed from the old capture, was reproduced 3/3 by both runs of record. Two more full
runs, one under each bash, passed before the sealed clone found a drift ("Found on the way"); the runs of record are of the fixed script.
And **1,071 s from a sealed fresh clone under `./receipts.sh`** (/bin/bash 3.2.57): `git clone` of the local repository (HEAD c9a2d97)
with `c6-unit08` and `c6-tiffinbox` put in from the working tree as git would take them (59 files, 0 differences; the clone's status
the same six lines as the repository's) — nothing git ignores: no `.m2-demo`, no `.harness/`, no `.r-*` — run under `env -i`, with a
`HOME` whose `.mavenrc` points Maven's `user.home` there and every Java proxy property at a port that refuses (127.0.0.1:9), and whose
Maven settings send every repository to a `file://` copy of Central's files made from `.m2-demo` (4,372 files: TiffinBox's own installs,
`_remote.repositories`, `*.lastUpdated`, `resolver-status.properties` and `.DS_Store` left out, `maven-metadata-central.xml` served as
`maven-metadata.xml`); `http_proxy`, `https_proxy`, their capitals and `ALL_PROXY` at the same refusing port; `GRAALVM_HOME` set;
`DOCKER_CONFIG=~/.docker`; `PATH` Homebrew's and the system's — the exercise's `env -i` shell got the same; its own process group. Exit
0, all 9 = published, every check passed (native builds 206, 203 and 200 s). Three pre-capture builds said `offline: no` — after/'s native install
(GraalVM's metadata repository was not in the empty `.m2-demo`), the previous tree's package (Jackson 2, which after/ no longer needs)
and the previous tree's class path (the dependency plugin's own dependencies) — and every capture's build said `offline: yes`. The clone's
`.m2-demo` ended with 707 artifact files (jars, POMs and the metadata zip; TiffinBox's own installs left out), and its
`_remote.repositories` entries name one repository, 707 of 707 `sealed` — the `file://` copy — 0 another; the native plugin's metadata
download lines: 0; `github` in the run's logs: 15 lines — 14 artifact paths under `com/github/` fetched from the `file://` copy, and native-image's printed link to its own build-output documentation, never fetched. **Interrupted** (below): exit 130, nothing left. **The exercise as viewers run it**
is the `exercise` capture itself — `exercise/README.md`, then `SOLUTION.md`, in one `env -i` `/bin/bash --noprofile --norc` shell, the
shell in `c6-unit08/` after each — and, by hand, the same two blocks in one `env -i` `zsh -f` shell: `status: 415 · its Accept header: application/json, application/*+json · customers now: 4`, then `status: 200 · its Accept header: none · customers now: 5`, the shell in `c6-unit08/` after each, 19379 free.

Published hashes: change `67b91bdc076302552d0de44eaf129264` · chain `453d3ef7d3eb4f7ad291b1bfc2770801` · body `2e750fe2fe0d2cff2d1b675c4ec217bd` · misfit `1c4196c88ebc7d89f971e827346d3de8` · unchecked `25068b5bb4f1ed581e97a2082984d75e` · ctype `d9b635fd220eda36bd63409379df9186` · jackson `b8159a1bdf46a54fa926f5d470aa45ab` · exercise `fd145077ff74d3a64fab7580e0867459` · forms `2bf8eda170a8732b3e5a39a8103bb472`.

## The commands this unit adds

`after/README.md` — the anchor's own — gives every line `receipts.sh` runs or derives from but seven, which are this unit's, each read
from the block below and asserted to be exactly this (on the anchor's port 18431; each capture swaps in its own port):

```bash
curl -s http://127.0.0.1:18431/actuator/mappings | python3 harness/table.py
curl -s http://127.0.0.1:18431/actuator/mappings | python3 harness/table.py row '/customers'
curl -s -w ' %{http_code} · Accept: [%header{accept}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:18431/customers
curl -s -w ' %{http_code} · Accept: [%header{accept}]\n' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:18431/customers
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,configprops
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:18431/actuator/configprops
mvn -B -q dependency:build-classpath -Dmdep.outputFile=target/cp.txt
```

The first two read the routing table, `/actuator/mappings` exposed for one run by the request-mapping lesson's line (`change`): whole,
and its two `/customers` rows with every key. The third is the anchor README's new POST line with the answer's `Accept` header printed
(`[]` when it has none) — `ctype`'s A and A′ — and the fourth is the same line with one option out, the request's `Content-Type`
(`ctype` B; the script asserts the two differ by exactly that option, and that the third is the anchor's line plus the `Accept` field).
The fifth exposes `configprops` alone for one run and the sixth asks it (`jackson` C) — never every endpoint (R.42). The last writes the
class path Maven lists for each module into its `target/cp.txt` (`jackson`). The anchor README's own new line —
`curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Asha",…}' http://127.0.0.1:18431/customers` — is the
shape of every POST a capture sends to TiffinBox and the harness (`pc`: its port, its path and its body swapped, the body single-quoted
as the README writes it); the request-mapping lesson's lines give the TRACE run and the exposure, the embedded-Tomcat lesson's the web
group at DEBUG, and Course 5's lines the condition report (`--debug`) and the missing-class demo.

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else, refuses one whose `native-image --version` is not
`native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1`, and never prints its folder (`$GRAALVM_HOME` in every capture). Only `forms`
needs it. **Without a GraalVM** the script still fills `.m2-demo`, makes the eight other captures, each checked against `receipts.md5`,
then stops where the native build would start (exit 1).

## The repository, Docker, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from the previous unit's `.m2-demo`
(`../c6-unit07/.m2-demo`, its `com/tiffinbox` left out: a stale install would satisfy `-pl tiffinbox-web native:compile-no-fork`)
and `../../spring-web-mvc/_research/m2-seed-s2/` — together exactly the S2 seed: 5,837 files, `diff -rq` against it 0 differences,
no `com/tiffinbox`. **Nothing was downloaded** for this unit: every build said `offline: yes` — the seed already held everything after/
needs once Jackson 2 is out, `jackson-annotations-2.21.jar` included (Jackson 3's) — the native plugin read its metadata repository from
`.m2-demo` (`file:`), and every native build log holds 0 lines of the plugin's own download (`Downloaded GraalVM reachability metadata
repository from http`, `Failed to download from http`). A fresh clone's `.m2-demo` is empty (git ignores it): the first build —
`after/`'s `mvn -B -Pnative install`, before any capture — fills it from Maven Central and says `offline: no`; every capture's build then
says `offline: yes`. The install writes `com/tiffinbox` into this unit's `.m2-demo` — fine here, and never copied into a seed.
**Docker:** no pull — `docker build` prints its `load metadata` line and the base image's digest, and `its lines that say pull: 0`. The
image (`tiffinbox-body:1.0.0`) and the container (`tiffinbox-body`) are this script's own names, checked absent first and removed on every
exit; the build cache is not pruned (`.dockerignore` keeps `secrets/` out of every build context, so it holds no token).

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 26 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/*/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) when the script runs, mounted read-only into the container (`:ro`), and sent only by `../c5-unit11/curlset.sh` and
`harness/shutdown.sh` on curl's standard input. Every capture's raw output is searched for it before masking (0 in all of them), and so
are the log of every JVM that served (the `--debug` runs' and the DEBUG run's among them), the container's log (`docker logs`), every file
this unit ships, the binary's bytes, and every blob of the image (`docker save`, each gzip layer unpacked; `forms`): 0 everywhere. A
request body is printed whole at DEBUG (`body`) — so no body here carries the token, and none should carry a secret. The exercise makes a
token of its own (`openssl rand -hex 13`: 26 hexadecimal digits), counted 0 times in its own log and never printed.

## The folders, the names and the ports

- `after/` — the anchor after this change (= `../c6-tiffinbox`). `.harness/before`, `.harness/after` — the two trees, copied, each
  with a config tree, built and extracted (`change`); `.harness/nat` — after/'s native build (`forms`); `.harness/hc` — the harness's
  classes, compiled against after/'s own jar with `-parameters`; `.harness/after/tiffinbox-web/target/hang` — the last course's
  missing-class copy (`jackson`); `.harness/mine` — the exercise's copy.
- **The harness** — the course's, never TiffinBox's (package `probe.web`, outside `com.tiffinbox`), each class joined by
  `--spring.main.sources` on the extracted jar's class path: `harness/probe/web/Converters.java` (`/probe/converters`: the message
  converters Spring MVC's `RequestMappingHandlerAdapter` holds, in its order, each with its media types; then, for three media types,
  which of them say yes to `canRead` or `canWrite` for a `com.tiffinbox.Customer`; the JSON converter's mapper — its class, and whether it
  is Boot's bean `jacksonJsonMapper` — and one setting, `FAIL_ON_UNKNOWN_PROPERTIES`, read back with `isEnabled` from that mapper and from a
  plain `JsonMapper.builder().build()`); `harness/probe/web/Body.java` (`/probe/body/plate`: a record of its own, `Plate`, whose compact
  constructor counts its calls, read from a JSON body and answered with the count, on one line); `harness/table.py` (the request-mapping
  lesson's reader of `/actuator/mappings`, copied unchanged); `harness/shutdown.sh` (POST `/shutdown` with the token read from its file —
  the binding lesson's, copied unchanged).
- **Ports** (brief ⚑1, 19370-19379): after/'s jar 19370 · the previous tree 19371 · after/ with the harness joined 19372 · the AOT jar
  19374 · the image 19377 · the binary 19378 · the exercise 19379; 19373, 19375 and 19376 are never bound. 18425 (TiffinBox's default)
  and 8080 (Tomcat's) are checked free and never bound on this Mac (18425 only inside the container); a run that listens on 8080 is
  killed and the script dies.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM, the token, the user** (`gsub()`, literals escaped), in every line: the demo token → `[masked: the 26-character
   token]` (its length read off the token); the GraalVM's folder → `$GRAALVM_HOME`; this folder → `…`; the folder above → `…/..`; home →
   `~`; the user name, as a whole word → `<user>`. A last check fails if any capture holds `/Users/`, `/private/`, `/home/`,
   `/var/folders/`, the GraalVM's folder, a unit number, Boot's process line, a log time, an unmasked timestamp, a thread number, a stack
   frame, a `sha256:` ID other than the base image's digest, `:8080` or a carriage return.
2. **Spring's error timestamp** (`tsmask`, `gsub`): `"timestamp":"<anything>"` → `"timestamp":"…"` and `"timestamp":<digits>` →
   `"timestamp":…` — both forms — in every answer printed and in the seven, which are hashed after it (two lines changed: `/nowhere`'s
   and GET /shutdown's).
3. **WARN and ERROR lines** (`logl`, `erec`): from their level and logger on, as the log prints the logger (`.w.s.m.s.DefaultHandlerExceptionResolver`
   is Spring MVC's; `o.a.c.c.C.[.[.[/].[dispatcherServlet]` Tomcat's; `o.s.boot.*` Boot's — read off the log, never typed); an identity hash
   after `@` → `@…`; in an ERROR record, **H2's constraint and index names** — the quoted string after `violation: ` — → `"…"`, and the record's
   next line (the SQL statement, H2's error code at its end) is printed, its stack frames bounded ("over 50, not shown"). A request's lines
   are those the log gained between two points where it stopped growing (`wans`, `erec`: each answer's last line ends with `· WARN lines it
   added: N`, and each such line follows).
4. **DEBUG** (`body`): the lines one request added, from the logger on — all of them, counted ("all 6"); the start's and the readiness
   polls' DEBUG lines come before the mark and are not printed.
5. **The condition report** (`jackson`, `j2rep`): of Boot's `--debug` report, only the entries that name Jackson 2's endpoint mapper —
   `Jackson2EndpointAutoConfiguration`, its bean, and the Spring MVC configurer that uses it — each with its list (matched / did not match)
   and its first reason; then how many entries in each list name `Jackson2` (the rest of the report, never printed).
6. **Orders that move between runs, sorted** (each says so on screen): the routes inside one block of `RequestMappingHandlerMapping`'s
   TRACE lines (`change`), and the routing table's rows with details (`harness/table.py`).
7. **The POMs and the Java files** (`xcode`, `code`): their lines that are not comments (an XML comment may span lines; a Java comment
   line starts `*`, `/**`, `*/` or `//`), blank lines dropped; the POMs' diff is git's (`--diff-algorithm=patience`, `-U0`), which shows the
   removed `<dependency>` block whole; the Java files' is `diff -U0`'s.
8. **The native build's lines**: its plugin goals, the GraalVM line, the Java version, each `Warning:` — the file a warning names
   (`in 'file:…'`, or `in 'null'`) → `in '…'` — the eight stages cut after their name, the warnings count and `BUILD SUCCESS`; the rest
   counted, never shown.
9. **`docker build --progress=plain`** through a filter: its `load metadata` line, its `FROM` line (the base image's digest), its naming
   line, step numbers and timings cut (checked on a planted log first); lines that say pull, counted; the rest bounded ("fewer than 300").
10. **Inside the container**: `/proc/net/tcp` and `tcp6`, LISTEN rows only, the address decoded. **On this Mac**: `lsof` by pid (or by
    port, for Docker's forwarder), the address column alone — never a command name (R.18).
11. **A URL that holds a character the shell reads** (`;`, `?`, `&`, `*`, `{`, `}`) is single-quoted on the command line, and every JSON
    body is single-quoted, so the printed command is the one that ran.

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`, `$fpid`, and
the exercise's shell `$xpid` with every process under it — `killtree`, by parent pid), sweeps its own process group for any TiffinBox
JVM, binary or `native-image` left, removes the container and the image, deletes the capture runs it had not finished (`.r-NAME.1-3`),
and removes `.r-lock`. The published captures are untouched.

**Measured** on this script (2026-10-14), started as a terminal starts its foreground job (SIGINT at its default, a process group of
its own — from a script, `python3 -c 'import os, signal, sys; signal.signal(signal.SIGINT, signal.SIG_DFL); os.setpgrp();
os.execvp(sys.argv[1], sys.argv[1:])' ./receipts.sh`): SIGINT to its process group during the native build (345 s in, native-image's
builder running for 25 s — 5 processes in the group, 2 of them java): **exit 130** 0.3 s later; 5 s later 0 processes in the group and 0
anywhere naming this folder, no image builder left; 19370-19379, 8080 and 18425 free; no container, no image, no `.r-lock`, no
unfinished capture run; the published captures unchanged. (A first attempt at this test waited for the builder by its main class's name,
which the builder's command line never shows — it starts `java @…/vminvocation.args`, as `sweep()` already knew — so it missed the first
build; that run was stopped by SIGINT between two builds, exit 130, and left nothing either.)

## 1 · change — the previous tree against after/, and a new customer, POSTed

The two trees, built offline and extracted; the harness compiled against after/'s jar. Five files differ — `README.md`, both POMs,
`CustomerRepository.java`, `TiffinBoxServer.java` — and none is added or deleted; 20 of after/'s 25 files are byte for byte the previous
tree's. `TiffinBoxServer.java` 197 → 215 lines; its code lines naming `@RequestBody` 0 → 1, the routes 6 → 7, and its code diff only adds
(the import, then `@PostMapping("/customers")` and `Customer add(@RequestBody Customer customer)`: store it, return it);
`CustomerRepository.java` 64 → 80, `add`'s eleven code lines only added (one `INSERT`, four parameters). The jar's `BOOT-INF/lib` 58 → 56
(by name in `jackson`). Then the anchor README's new line, a new customer as JSON: on the previous tree **Spring MVC's 405** and one WARN
line, `Request method 'POST' is not supported` — no mapping took POST on `/customers`; on after/, run with the request-mapping lesson's
TRACE line, **200 and the record**, read back by name with the binding lesson's line. At TRACE, before Boot's started line,
`RequestMappingHandlerMapping` lists seven of TiffinBox's routes — `{POST [/customers]}: add(Customer)` the new one — and Boot's two, `9
mappings`; the routing table has 16 rows, TiffinBox's seven, two of them `/customers` (GET and POST), the POST row's `consumes = []`: the
route names no media type.

`.r-change.out` · md5 `67b91bdc076302552d0de44eaf129264` · 3 of 3

```
the previous tree and after/, both copied under .harness/ with a config tree, each built with the README's line (offline):
$ cd .harness/before && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the previous tree · offline: yes · exit 0
$ cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built after/ · offline: yes · exit 0
both jars extracted (the README's line) - the class path the harness runs on:
$ cd .harness/before && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
$ cd .harness/after && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
the harness, compiled against after/'s own jar - with -parameters:
$ javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/probe/web/*.java
  exit 0
the files that differ:
$ diff -rq -x target -x secrets .harness/before .harness/after
  Files .harness/before/README.md and .harness/after/README.md differ
  Files .harness/before/pom.xml and .harness/after/pom.xml differ
  Files .harness/before/tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java and .harness/after/tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java differ
  Files .harness/before/tiffinbox-web/pom.xml and .harness/after/tiffinbox-web/pom.xml differ
  Files .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java and .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java differ
the two Java files, their lines (wc -l), before -> after:
  TiffinBoxServer.java: 197 -> 215
  CustomerRepository.java: 64 -> 80
  TiffinBoxServer.java, its lines that are neither comment nor blank: 110 -> 116, of them - imports left out - naming a request body (@RequestBody): 0 -> 1 · a route (@GetMapping, @PostMapping): 6 -> 7
  its code lines' diff (diff -U0 of the lines above, its file names cut) - hunks: 2 · lines out: 0 · in: 6 - whole:
    @@ -9,0 +10 @@
    +import org.springframework.web.bind.annotation.RequestBody;
    @@ -55,0 +57,5 @@
    +    @PostMapping("/customers")
    +    Customer add(@RequestBody Customer customer) throws Exception {
    +        repo.add(customer);
    +        return customer;
    +    }
  CustomerRepository.java, its code lines: 53 -> 64 - its code lines' diff, the same way - hunks: 1 · lines out: 0 · in: 11 - whole:
    @@ -36,0 +37,11 @@
    +    public void add(Customer customer) throws SQLException {
    +        try (var c = db.open();
    +             var ps = c.prepareStatement(
    +                 "INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?)")) {
    +            ps.setString(1, customer.name());
    +            ps.setInt(2, customer.mealsPerDay());
    +            ps.setInt(3, customer.pricePerMeal());
    +            ps.setString(4, customer.mealType());
    +            ps.executeUpdate();
    +        }
    +    }
  pom.xml and tiffinbox-web/pom.xml: Jackson 2 out - their lines in jackson
the executable jar's BOOT-INF/lib: 58 jars -> 56 · removed 3 · added 1 - by name in jackson
  README.md - the anchor's README: lines added 108, removed 15 - its new section and the history notes the change made false (not shown)
  after/'s files: 25 · byte for byte the previous tree's: 20 · the five above differ: 5
a new customer, as JSON - this unit's line in the anchor's README - before: the previous tree, the README's run line, port 19371:
$ cd .harness/before && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19371
  listens on: 127.0.0.1:19371 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19371/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19371/customers
  {"timestamp":"…","status":405,"error":"Method Not Allowed","path":"/customers"} 405 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpRequestMethodNotSupportedException: Request method 'POST' is not supported]
$ harness/shutdown.sh 19371 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19371 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
after - after/, the request-mapping lesson's line - Spring MVC's mapping logger at TRACE, the kitchen at DEBUG - port 19370:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19370 --logging.level.kitchen=debug --logging.level.org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping=trace
  listens on: 127.0.0.1:19370 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19370/actuator/health/readiness
  {"status":"UP"} 200
  Spring MVC's RequestMappingHandlerMapping, its lines before Boot's started line (logger: level, message; a block's routes sorted):
    s.w.s.m.m.a.RequestMappingHandlerMapping: TRACE
      c.t.w.TiffinBoxServer:
        {GET [/customers/{name}]}: customer(String)
        {GET [/customers]}: customers(MealType)
        {GET [/dashboard]}: dashboard()
        {GET [/kitchen]}: kitchen()
        {GET [/revenue]}: revenue()
        {POST [/customers]}: add(Customer)
        {POST [/shutdown]}: shutdown(String,HttpServletResponse)
    s.w.s.m.m.a.RequestMappingHandlerMapping: TRACE
      o.s.b.w.a.e.BasicErrorController:
        { [/error], produces [text/html]}: errorHtml(HttpServletRequest,HttpServletResponse)
        { [/error]}: error(HttpServletRequest)
    s.w.s.m.m.a.RequestMappingHandlerMapping: DEBUG 9 mappings in 'requestMappingHandlerMapping'
  then Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19370 (http) with context path '/'
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19370/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19370/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ harness/shutdown.sh 19370 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19370 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the routing table - after/, mappings exposed for one run (the request-mapping lesson's line), port 19370:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19370 --management.endpoints.web.exposure.include=health,prometheus,mappings
  listens on: 127.0.0.1:19370 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19370/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19370/actuator/mappings | python3 harness/table.py
  contexts: 1 (application) · kinds: 3 (dispatcherServlets servletFilters servlets)
  dispatcherServlets · dispatcherServlet: 16 rows, in the table's order - a run of rows with details sorted by pattern (produces lists cut: 5 · class names cut to their last part: 9)
    1  {GET [/actuator], produces [application/vnd.spring-boot.actuator.v3+json … 2 more]} -> Actuator root web endpoint
    2  {GET [/actuator/health], produces [application/vnd.spring-boot.actuator.v3+json … 2 more]} -> Actuator web endpoint 'health'
    3  {GET [/actuator/health/**], produces [application/vnd.spring-boot.actuator.v3+json … 2 more]} -> Actuator web endpoint 'health-path'
    4  {GET [/actuator/mappings], produces [application/vnd.spring-boot.actuator.v3+json … 2 more]} -> Actuator web endpoint 'mappings'
    5  {GET [/actuator/prometheus], produces [text/plain;version=0.0.4;charset=utf-8 … 2 more]} -> Actuator web endpoint 'prometheus'
    6  {GET [/customers]} -> TiffinBoxServer#customers(MealType)
    7  {POST [/customers]} -> TiffinBoxServer#add(Customer)
    8  {GET [/customers/{name}]} -> TiffinBoxServer#customer(String)
    9  {GET [/dashboard]} -> TiffinBoxServer#dashboard()
   10  { [/error], produces [text/html]} -> BasicErrorController#errorHtml(HttpServletRequest, HttpServletResponse)
   11  { [/error]} -> BasicErrorController#error(HttpServletRequest)
   12  {GET [/kitchen]} -> TiffinBoxServer#kitchen()
   13  {GET [/revenue]} -> TiffinBoxServer#revenue()
   14  {POST [/shutdown]} -> TiffinBoxServer#shutdown(String, HttpServletResponse)
   15  /webjars/** -> ResourceHttpRequestHandler [classpath [META-INF/resources/webjars/]]
   16  /** -> ResourceHttpRequestHandler [classpath [META-INF/resources/], classpath [resources/], classpath [static/], classpath [public/], ServletContext [/]]
  rows with details: 14 · without: 2 · naming a verb: 12 (GET 10 POST 2)
  TiffinBox's rows (its own handler, or a TiffinBoxServer method): 7 · naming a verb: 7 (GET 5 POST 2)
  servletFilters: 5, by name: characterEncodingFilter, formContentFilter, requestContextFilter, Tomcat WebSocket (JSR356) Filter, webMvcObservationFilter · on /* : 5
  servlets: 1 · dispatcherServlet on /
$ curl -s http://127.0.0.1:19370/actuator/mappings | python3 harness/table.py row '/customers'
  the row for /customers: 2
  /customers - 3 keys: details handler predicate
    details.handlerMethod.className = com.tiffinbox.web.TiffinBoxServer
    details.handlerMethod.descriptor = (Lcom/tiffinbox/MealType;)Ljava/util/List;
    details.handlerMethod.name = customers
    details.requestMappingConditions.consumes = []
    details.requestMappingConditions.headers = []
    details.requestMappingConditions.methods = ["GET"]
    details.requestMappingConditions.params = []
    details.requestMappingConditions.patterns = ["/customers"]
    details.requestMappingConditions.produces = []
    handler = com.tiffinbox.web.TiffinBoxServer#customers(MealType)
    predicate = {GET [/customers]}
  /customers - 3 keys: details handler predicate
    details.handlerMethod.className = com.tiffinbox.web.TiffinBoxServer
    details.handlerMethod.descriptor = (Lcom/tiffinbox/Customer;)Lcom/tiffinbox/Customer;
    details.handlerMethod.name = add
    details.requestMappingConditions.consumes = []
    details.requestMappingConditions.headers = []
    details.requestMappingConditions.methods = ["POST"]
    details.requestMappingConditions.params = []
    details.requestMappingConditions.patterns = ["/customers"]
    details.requestMappingConditions.produces = []
    handler = com.tiffinbox.web.TiffinBoxServer#add(Customer)
    predicate = {POST [/customers]}
$ harness/shutdown.sh 19370 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19370 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 2 · chain — Spring MVC's message converters, and which one reads a Customer

after/ with the harness's `Converters` joined. The `RequestMappingHandlerAdapter` holds **six message converters**, in the order it asks
them, each with its media types; asked for a `com.tiffinbox.Customer`, `application/json` gets **one yes of six** — the sixth,
`JacksonJsonHttpMessageConverter`, which can read one and write one — and a form (`application/x-www-form-urlencoded`) and `text/plain`
none. The JSON converter's mapper is `tools.jackson.databind.json.JsonMapper`, Boot's bean `jacksonJsonMapper` itself. And
`FAIL_ON_UNKNOWN_PROPERTIES`, read back from that mapper and from a plain `JsonMapper` built with no setting at all: **false, both** —
Jackson 3's own default ignores a property it does not know. Core Java II's Jackson lesson measured Jackson 2's default the other way:
"the default is strict — an unknown field is an error, not a shrug" (its deck, read by the builder).

`.r-chain.out` · md5 `453d3ef7d3eb4f7ad291b1bfc2770801` · 3 of 3

```
after/ on the README's class-path line with the harness's Converters joined, port 19372:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19372 --spring.main.sources=probe.web.Converters
  listens on: 127.0.0.1:19372 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19372/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19372/probe/converters
  message converters: 6 - RequestMappingHandlerAdapter's, in the order it asks them
    1 ByteArrayHttpMessageConverter [application/octet-stream, */*]
    2 StringHttpMessageConverter [text/plain, */*]
    3 ResourceHttpMessageConverter [*/*]
    4 ResourceRegionHttpMessageConverter [*/*]
    5 AllEncompassingFormHttpMessageConverter [application/x-www-form-urlencoded, multipart/form-data, multipart/mixed, multipart/related]
    6 JacksonJsonHttpMessageConverter [application/json, application/*+json]
  asked of each, for a com.tiffinbox.Customer - canRead or canWrite, by media type - those that say yes:
    application/json: 1 of 6 - 6 JacksonJsonHttpMessageConverter (read yes, write yes)
    application/x-www-form-urlencoded: 0 of 6
    text/plain: 0 of 6
  the JSON converter's mapper (6 JacksonJsonHttpMessageConverter): tools.jackson.databind.json.JsonMapper · Boot's bean jacksonJsonMapper itself: yes
  FAIL_ON_UNKNOWN_PROPERTIES - Boot's mapper: false · a plain JsonMapper (JsonMapper.builder().build()): false
   200
$ harness/shutdown.sh 19372 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19372 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 3 · body — one POST at DEBUG, and a record the harness counts the constructions of

after/ with Boot's `web` group at DEBUG (the embedded-Tomcat lesson's line): the anchor's POST → 200 and the record, and **all six**
lines the log gained for it — the `DispatcherServlet`'s `POST "/customers"`, the mapping's `Mapped to …#add(Customer)`, then Spring
MVC's `RequestResponseBodyMethodProcessor`: `Read "application/json;charset=UTF-8" to [Customer[name=Asha, mealsPerDay=2,
pricePerMeal=110, mealType=VEG]]` — the body, every value — `Using 'application/json'…` and `Writing [Customer[…]]`, and `Completed 200
OK`; the customer read back by name. Then the harness's `Body`: its record `Plate` has a compact constructor that counts its calls, and
two POSTs answer `canonical constructor calls so far: 1`, then `2` — Jackson builds a record through its canonical constructor, once per
body.

`.r-body.out` · md5 `2e750fe2fe0d2cff2d1b675c4ec217bd` · 3 of 3

```
after/, the README's line with Boot's web group at DEBUG (the embedded-Tomcat lesson's), port 19370 - one new customer, this unit's line in the anchor's README:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19370 --logging.level.web=debug
  listens on: 127.0.0.1:19370 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19370/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19370/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - all 6:
    o.s.web.servlet.DispatcherServlet: POST "/customers", parameters={}
    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to com.tiffinbox.web.TiffinBoxServer#add(Customer)
    m.m.a.RequestResponseBodyMethodProcessor: Read "application/json;charset=UTF-8" to [Customer[name=Asha, mealsPerDay=2, pricePerMeal=110, mealType=VEG]]
    m.m.a.RequestResponseBodyMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
    m.m.a.RequestResponseBodyMethodProcessor: Writing [Customer[name=Asha, mealsPerDay=2, pricePerMeal=110, mealType=VEG]]
    o.s.web.servlet.DispatcherServlet: Completed 200 OK
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19370/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ harness/shutdown.sh 19370 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19370 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
a record of the harness's own, Body.Plate, whose compact constructor counts its calls - after/ on the README's class-path line with Body joined, port 19372:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19372 --spring.main.sources=probe.web.Body
  listens on: 127.0.0.1:19372 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19372/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Ravi","count":2}' http://127.0.0.1:19372/probe/body/plate
  Plate[name=Ravi, count=2] · canonical constructor calls so far: 1 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Meera","count":1}' http://127.0.0.1:19372/probe/body/plate
  Plate[name=Meera, count=1] · canonical constructor calls so far: 2 200
$ harness/shutdown.sh 19372 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19372 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 4 · misfit — bodies that don't fit the record

after/'s jar, each body sent as the anchor's line sends one (`Content-Type: application/json`). Refused, **400** — Boot's body, which names
no reason, and **one WARN line each**, Spring MVC's `DefaultHandlerExceptionResolver` with Jackson's message inside: malformed JSON
(`Unexpected end-of-input`), an empty body (`Required request body is missing`), an array (`Cannot deserialize value of type
com.tiffinbox.Customer from Array value`), no `mealsPerDay` (``Cannot map `null` into type `int` ``, `FAIL_ON_NULL_FOR_PRIMITIVES`), trailing
text after the object (`Unrecognized token 'extra'`). **Stored, 200, no WARN line:** an unknown property — `loyaltyPoints`, Core Java II's
own unknown field — dropped; `"2"` read as 2; **`2.7` stored as 2**, and read back as 2. The run's WARN lines: 5, one per 400.

`.r-misfit.out` · md5 `1c4196c88ebc7d89f971e827346d3de8` · 3 of 3

```
after/, the README's run line, port 19370 - bodies that don't fit the record, each sent as this unit's line sends one (its Content-Type application/json):
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19370
  listens on: 127.0.0.1:19370 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19370/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Kiran","mealsPerDay":2' http://127.0.0.1:19370/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Unexpected end-of-input: expected close marker for Object (start marker at [Source: REDACTED (`StreamReadFeature.INCLUDE_SOURCE_IN_LOCATION` disabled); byte offset: #UNKNOWN])]
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '' http://127.0.0.1:19370/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: Required request body is missing: com.tiffinbox.Customer com.tiffinbox.web.TiffinBoxServer.add(com.tiffinbox.Customer) throws java.lang.Exception]
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '[{"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}]' http://127.0.0.1:19370/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot deserialize value of type `com.tiffinbox.Customer` from Array value (token `JsonToken.START_ARRAY`)]
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Kiran","pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19370/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot map `null` into type `int` (set `DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES` to 'false' to allow)]
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} extra' http://127.0.0.1:19370/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Unrecognized token 'extra': was expecting (JSON String, Number, Array, Object or token 'null', 'true' or 'false')]
and three that are stored:
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG","loyaltyPoints":5}' http://127.0.0.1:19370/customers
  {"name":"Kiran","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Lata","mealsPerDay":"2","pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19370/customers
  {"name":"Lata","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19370/customers
  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19370/customers/Mohan
  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 5
$ harness/shutdown.sh 19370 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19370 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 5 · unchecked — what nothing checks yet

after/'s jar. `{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}` → **200, stored**, and `/customers` lists it first (five
customers). A misspelt key, `"mealTyp"`, is ignored, so the meal type arrives as `null`: **500**, and Tomcat's ERROR line holds H2's
refusal — `JdbcSQLIntegrityConstraintViolationException: NULL not allowed for column "MEAL_TYPE"`, the SQL statement, H2's code `[23502-250]`
— with a trace of over 50 frames (not shown); `Ravi` again → **500**, `Unique index or primary key violation` (H2's index and row names
cut), `[23505-250]`, the same exception class — the response lesson decides 409 by that code. The misspelt customer was not stored
(`/customers/Rohan` 404). The run's log: 0 WARN lines, 2 ERROR.

`.r-unchecked.out` · md5 `25068b5bb4f1ed581e97a2082984d75e` · 3 of 3

```
after/, the README's run line, port 19370 - a body nothing checks yet:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19370
  listens on: 127.0.0.1:19370 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19370/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19370/customers
  {"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"} 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19370/customers
  [{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"},{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 · WARN lines it added: 0
a misspelt key, then a name that is taken - the database refuses each:
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Rohan","mealsPerDay":1,"pricePerMeal":110,"mealTyp":"VEG"}' http://127.0.0.1:19370/customers
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers"} 500
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException: NULL not allowed for column "MEAL_TYPE"; SQL statement:
      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [23502-250]] with root cause
    its stack frames: over 50, its other lines: 4 - none shown · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"}' http://127.0.0.1:19370/customers
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers"} 500
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLIntegrityConstraintViolationException: Unique index or primary key violation: "…"; SQL statement:
      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [23505-250]] with root cause
    its stack frames: over 50, its other lines: 4 - none shown · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19370/customers/Rohan
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Rohan"} 404 · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 2
$ harness/shutdown.sh 19370 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19370 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 6 · ctype — the request's Content-Type (A/B/A′)

**A** — after/'s jar, this unit's line (the anchor's POST, the answer's `Accept` header printed): 200, the record, `Accept: []`, 0 WARN.
**B** — the same line with one option out, `-H 'Content-Type: application/json'`: curl's `--data` then names a form,
`application/x-www-form-urlencoded`, and Spring MVC answers **415**, Boot's body, with **`Accept: [application/json, application/*+json]`**
— the media types it can read a `Customer` from — and one WARN line, `HttpMediaTypeNotSupportedException: Content-Type
'application/x-www-form-urlencoded;charset=UTF-8' is not supported`; `/customers/Asha` is then 404: nothing was stored. **A′** — A
again, on a fresh JVM: A's lines, line for line (asserted).

`.r-ctype.out` · md5 `d9b635fd220eda36bd63409379df9186` · 3 of 3

```
A - after/, the README's run line, port 19370 - a new customer, its Content-Type named (this unit's line, the answer's Accept header printed):
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19370
  listens on: 127.0.0.1:19370 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19370/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Accept: [%header{accept}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19370/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · Accept: [] · WARN lines it added: 0
$ harness/shutdown.sh 19370 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19370 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the same line without its -H 'Content-Type: application/json', one option out: curl names a form for --data, port 19370:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19370
  listens on: 127.0.0.1:19370 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19370/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Accept: [%header{accept}]\n' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19370/customers
  {"timestamp":"…","status":415,"error":"Unsupported Media Type","path":"/customers"} 415 · Accept: [application/json, application/*+json] · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotSupportedException: Content-Type 'application/x-www-form-urlencoded;charset=UTF-8' is not supported]
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19370/customers/Asha
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Asha"} 404 · WARN lines it added: 0
$ harness/shutdown.sh 19370 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19370 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, on a fresh JVM:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19370
  listens on: 127.0.0.1:19370 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19370/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Accept: [%header{accept}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19370/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200 · Accept: [] · WARN lines it added: 0
$ harness/shutdown.sh 19370 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19370 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 7 · jackson — one Jackson left (⚑7, the brief's RE-MEASURE 8)

The two POMs' lines that are not comments: `pom.xml` loses one, the pin `<jackson-2-bom.version>2.22.2</jackson-2-bom.version>`;
`tiffinbox-web/pom.xml` four, the `jackson-databind` dependency. The jar's `BOOT-INF/lib`: **58 → 56** — out `jackson-annotations-2.22.jar`,
`jackson-core-2.22.2.jar`, `jackson-databind-2.22.2.jar`; in `jackson-annotations-2.21.jar`. Every jar of each tree's `lib/` read, by
package: `com/fasterxml/jackson/databind/` 812 classes → 0, `core/` 213 → 0, `annotation/` stays (77 → 75: 2.22's classes against
2.21's), Jackson 3's the same. Maven's class path for `tiffinbox-web` — the one the native build reads — loses the same two Jackson 2
jars. Who still reads the annotations: `jackson-databind-3.1.5.jar`'s manifest imports `com.fasterxml.jackson.annotation;version="[2.21,3)"`.
Why 2.21: Boot 4.1.1's own `<jackson-2-bom.version>` is `2.21.5` (the previous tree's `pom.xml` set it to `2.22.2`), and Jackson 3's BOM
sets `<jackson.version.annotations>2.21</jackson.version.annotations>`. Boot's condition report (Course 5's `--debug` line):
`Jackson2EndpointAutoConfiguration` and its `jackson2EndpointJsonMapper` **matched** on the previous tree (3 entries naming `Jackson2`
matched, 2 did not); on after/ it **did not match** — `@ConditionalOnClass did not find required class
'com.fasterxml.jackson.databind.ObjectMapper'` — and none matched: Actuator builds no Jackson 2 mapper. The last course's missing-class
lines, from after/'s folder: the copy, exit 0; the `zip` that deletes `JDK14Util` from `jackson-databind-2.22.2.jar` → **exit 12**, `zip
error: Nothing to do!` — there is no such jar. **C (labelled):** configprops exposed alone for one run (this unit's line): 200 on the
previous tree and on after/ — the anchor README's Course 5 note that every endpoint at once stops the start (`JavaTimeModule`, Jackson 2's
time module) does not hold on Spring MVC's Actuator, on either tree.

`.r-jackson.out` · md5 `b8159a1bdf46a54fa926f5d470aa45ab` · 3 of 3

```
the two POMs, their lines that are not comments - the previous tree's against after/'s (git's patience diff, -U0, the file names cut):
  pom.xml - hunks: 1 · lines out: 1 · in: 0:
    @@ -19 +18,0 @@
    -    <jackson-2-bom.version>2.22.2</jackson-2-bom.version>
  tiffinbox-web/pom.xml - hunks: 1 · lines out: 4 · in: 0:
    @@ -19,4 +18,0 @@
    -    <dependency>
    -      <groupId>com.fasterxml.jackson.core</groupId>
    -      <artifactId>jackson-databind</artifactId>
    -    </dependency>
the executable jar's BOOT-INF/lib: 58 jars -> 56
  removed 3: jackson-annotations-2.22.jar jackson-core-2.22.2.jar jackson-databind-2.22.2.jar · added 1: jackson-annotations-2.21.jar
  their jars named jackson, after: jackson-annotations-2.21.jar jackson-core-3.1.5.jar jackson-databind-3.1.5.jar spring-boot-jackson-4.1.1.jar
  the classes in those jars, by package - every jar of each tree's extracted lib/ read, before -> after:
    com/fasterxml/jackson/databind/: 812 -> 0
    com/fasterxml/jackson/core/: 213 -> 0
    com/fasterxml/jackson/annotation/: 77 -> 75
    tools/jackson/databind/: 904 -> 904
    tools/jackson/core/: 211 -> 211
the class path Maven lists for tiffinbox-web - the one the native build reads (this unit's line, offline) - its jars named jackson:
$ cd .harness/before && mvn -o -B -Dmaven.repo.local="$M2" -q dependency:build-classpath -Dmdep.outputFile=target/cp.txt
  built the class path of .harness/before · offline: yes · exit 0
  jackson-annotations-2.22.jar jackson-core-2.22.2.jar jackson-core-3.1.5.jar jackson-databind-2.22.2.jar jackson-databind-3.1.5.jar spring-boot-jackson-4.1.1.jar spring-boot-starter-jackson-4.1.1.jar
$ cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" -q dependency:build-classpath -Dmdep.outputFile=target/cp.txt
  built the class path of .harness/after · offline: yes · exit 0
  jackson-annotations-2.21.jar jackson-core-3.1.5.jar jackson-databind-3.1.5.jar spring-boot-jackson-4.1.1.jar spring-boot-starter-jackson-4.1.1.jar
who still reads the annotations - after/'s jackson-databind-3.1.5.jar, its manifest's Import-Package for them: com.fasterxml.jackson.annotation;version="[2.21,3)"
which version - Boot's BOM ($M2/org/springframework/boot/spring-boot-dependencies/4.1.1/spring-boot-dependencies-4.1.1.pom): <jackson-2-bom.version>2.21.5</jackson-2-bom.version> - the property the previous tree's pom.xml set: <jackson-2-bom.version>2.22.2</jackson-2-bom.version> · Jackson 3's BOM ($M2/tools/jackson/jackson-bom/3.1.5/jackson-bom-3.1.5.pom): <jackson.version.annotations>2.21</jackson.version.annotations>
Actuator's Jackson 2 mapper - Boot's condition report (the last course's --debug line) - before: the previous tree, port 19371:
$ cd .harness/before && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19371 --debug
  listens on: 127.0.0.1:19371 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19371/actuator/health/readiness
  {"status":"UP"} 200
    Jackson2EndpointAutoConfiguration - matched: @ConditionalOnClass found required classes 'com.fasterxml.jackson.databind.ObjectMapper', 'org.springframework.http.converter.json.Jackson2ObjectMapperBuilder' (OnClassCondition)
    Jackson2EndpointAutoConfiguration#jackson2EndpointJsonMapper - matched: @ConditionalOnBooleanProperty (management.endpoints.jackson2.isolated-object-mapper=true) matched (OnPropertyCondition)
    WebMvcEndpointManagementContextConfiguration#endpointJackson2ObjectMapperWebMvcConfigurer - matched: @ConditionalOnBean (types: org.springframework.boot.actuate.endpoint.jackson.EndpointJackson2ObjectMapper; SearchStrategy: all) found bean 'jackson2EndpointJsonMapper' (OnBeanCondition)
    the report's entries in its two lists: over 100, the others not shown
    entries naming Jackson2, in the report's two lists: matched 3 · did not match 2
$ harness/shutdown.sh 19371 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19371 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
after - after/, port 19370:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19370 --debug
  listens on: 127.0.0.1:19370 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19370/actuator/health/readiness
  {"status":"UP"} 200
    Jackson2EndpointAutoConfiguration - did not match: @ConditionalOnClass did not find required class 'com.fasterxml.jackson.databind.ObjectMapper' (OnClassCondition)
    WebMvcEndpointManagementContextConfiguration#endpointJackson2ObjectMapperWebMvcConfigurer - did not match: @ConditionalOnBean (types: org.springframework.boot.actuate.endpoint.jackson.EndpointJackson2ObjectMapper; SearchStrategy: all) did not find any beans of type org.springframework.boot.actuate.endpoint.jackson.EndpointJackson2ObjectMapper (OnBeanCondition)
    the report's entries in its two lists: over 100, the others not shown
    entries naming Jackson2, in the report's two lists: matched 0 · did not match 4
$ harness/shutdown.sh 19370 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19370 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the last course's missing-class lines (the anchor's README) - a copy of the extracted jar, then one class out of Jackson 2's jar - from after/'s folder:
$ cd .harness/after && rm -rf tiffinbox-web/target/hang && mkdir tiffinbox-web/target/hang && cp tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar tiffinbox-web/target/hang/ && cp -R tiffinbox-web/target/extracted/lib tiffinbox-web/target/hang/lib
  exit 0
$ cd .harness/after && zip -q -d tiffinbox-web/target/hang/lib/jackson-databind-2.22.2.jar 'com/fasterxml/jackson/databind/jdk14/JDK14Util*'
  exit 12 · what it printed: zip error: Nothing to do! (tiffinbox-web/target/hang/lib/jackson-databind-2.22.2.jar)
C (labelled) - configprops, exposed alone for one run (this unit's line) - before: the previous tree, port 19371:
$ cd .harness/before && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19371 --management.endpoints.web.exposure.include=health,configprops
  listens on: 127.0.0.1:19371 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19371/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19371/actuator/configprops
  200
$ harness/shutdown.sh 19371 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19371 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
after - after/, port 19370:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19370 --management.endpoints.web.exposure.include=health,configprops
  listens on: 127.0.0.1:19370 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19370/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19370/actuator/configprops
  200
$ harness/shutdown.sh 19370 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19370 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 8 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s commands, then `exercise/solution/SOLUTION.md`'s, read from the files and run as written, one after the other in
ONE shell a viewer could have — `env -i` (HOME, and the PATH the script was started with), `/bin/bash --noprofile --norc`, started in
this folder: as shipped `status: 415 · its Accept header: application/json, application/*+json · customers now: 4` (one WARN line in its
log), then the solution — the same last line with `-H 'Content-Type: application/json'` added, and nothing else (asserted) —
`status: 200 · its Accept header: none · customers now: 5`, the shell in this unit's folder after each, the copy's own token 0 times in
its log.

`.r-exercise.out` · md5 `fd145077ff74d3a64fab7580e0867459` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 7 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
  $ mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package)
  $ (cd .harness/mine/after && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19379 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19379/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s -D ../head.txt -o ../body.txt --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19379/customers; n=$(curl -s http://127.0.0.1:19379/customers | grep -o '"name":"' | wc -l | tr -d ' '); ../../../harness/shutdown.sh 19379 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && a=$(grep -i '^accept:' ../head.txt | sed 's/^[^:]*: *//' | tr -d '\r') && echo "status: $(sed -n '1s/^HTTP\/1\.1 \([0-9]*\).*/\1/p' ../head.txt) · its Accept header: ${a:-none} · customers now: $n")
  exit 0 · what they printed:
    status: 415 · its Accept header: application/json, application/*+json · customers now: 4
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 1
the solution's 3 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ (cd .harness/mine/after && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19379 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19379/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s -D ../head.txt -o ../body.txt -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19379/customers; n=$(curl -s http://127.0.0.1:19379/customers | grep -o '"name":"' | wc -l | tr -d ' '); ../../../harness/shutdown.sh 19379 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && a=$(grep -i '^accept:' ../head.txt | sed 's/^[^:]*: *//' | tr -d '\r') && echo "status: $(sed -n '1s/^HTTP\/1\.1 \([0-9]*\).*/\1/p' ../head.txt) · its Accept header: ${a:-none} · customers now: $n")
  exit 0 · what they printed:
    status: 200 · its Accept header: none · customers now: 5
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · listening on 19379 now: 0
```


## 9 · forms — every form still serves (⚑16, R.40, S2.20)

`after/`'s native build (the README's two Maven lines, offline: 8 of 8 stages, Mach-O, 0 token bytes, 0 download lines); Spring's
generated `reachability-metadata.json` names `com.tiffinbox.Customer` (its declared fields and constructors, four accessors) — the record a
route reads now, as well as returns. Then **1** the jar, **2** the AOT jar, **3** the binary, **4** the image (built here from after/'s
Dockerfile, its layers searched: 0 tokens; published on `127.0.0.1:19377` alone): each the seven `87ca7efc…` on a fresh start, exit 0;
then, on a second start of each, the new route — the anchor's POST 200 and the record, read back by name, the same body with no
`Content-Type` 415 with its `Accept` header, and `2.7` meals stored as 2, read back — 4 of 4 each (RE-MEASURE 15); loopback counted form
by form.

`.r-forms.out` · md5 `2bf8eda170a8732b3e5a39a8103bb472` · 3 of 3

```
the native build - after/ copied to .harness/nat with a config tree; the README's two Maven lines, offline; $GRAALVM_HOME names the GraalVM:
$ cd .harness/nat && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean install
  built .harness/nat (both modules, into $M2) · offline: yes · exit 0
$ cd .harness/nat && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -pl tiffinbox-web native:compile-no-fork
  its lines, in order (the rest - 199 lines - not shown):
    --- native:1.1.8:compile-no-fork (default-cli) @ tiffinbox-web ---
    Found GraalVM installation from GRAALVM_HOME variable.
    Java version: 25.0.4.1+1, vendor version: GraalVM CE 25.3.4.1+1.1
    Warning: Using a deprecated option --no-fallback from 'META-INF/native-image/com.tiffinbox/tiffinbox-web/native-image.properties' in '…'. No effect, no replacement available
    Warning: Using a deprecated option --enable-http from 'META-INF/native-image/org.springframework/spring-web/native-image.properties' in '…'. Use reachability metadata instead. Add this entry to META-INF/native-image/reachability-metadata.json:
    Warning: Using a deprecated option --enable-https from 'META-INF/native-image/org.springframework/spring-web/native-image.properties' in '…'. Use reachability metadata instead. Add this entry to META-INF/native-image/reachability-metadata.json:
    Warning: Option 'FallbackThreshold' is deprecated and might be removed in a future release: It no longer has any effect, and no replacement is available. Please refer to the GraalVM release notes.
    Warning: Option 'DynamicProxyConfigurationResources' is deprecated and might be removed in a future release: This can be caused by a proxy-config.json file in your META-INF directory. Consider including proxy configuration in the reflection section of reachability-metadata.json instead.. Please refer to the GraalVM release notes.
    [1/8] Initializing...
    [2/8] Performing analysis...
    [3/8] Building universe...
    [4/8] Parsing methods...
    [5/8] Inlining methods...
    [6/8] Compiling methods...
    [7/8] Laying out methods...
    [8/8] Creating image...
    The build process encountered 5 warnings.
    BUILD SUCCESS
  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: under 20 minutes · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes
  file: Mach-O 64-bit executable · the demo token in its bytes: 0
what Spring's AOT step registered for the native build - the record a route reads and the routes return, and the enum a route's parameter is:
  Spring's generated metadata (spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json): reflection entries naming com.tiffinbox.Customer: 1 - all declared fields · all declared constructors · 4 methods (mealType mealsPerDay name pricePerMeal)
  Spring's generated metadata (spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json): reflection entries naming com.tiffinbox.MealType: 1 - all declared fields · 1 methods (<init>)
1 the jar - .harness/after, the README's run line, port 19370:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19370
  listens on: 127.0.0.1:19370 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19370/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19370 (http) with context path '/'
$ $CURLSET 19370 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the new route, on a second start of the jar:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19370
  listens on: 127.0.0.1:19370 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19370/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19370/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19370/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code} · Accept: [%header{accept}]\n' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19370/customers
  {"timestamp":"…","status":415,"error":"Unsupported Media Type","path":"/customers"} 415 · Accept: [application/json, application/*+json]
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19370/customers
  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19370/customers/Mohan
  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ harness/shutdown.sh 19370 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19370 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19374:
$ cd .harness/nat && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19374
  listens on: 127.0.0.1:19374 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19374/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19374 (http) with context path '/'
$ $CURLSET 19374 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the new route, on a second start of the AOT jar:
$ cd .harness/nat && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19374
  listens on: 127.0.0.1:19374 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19374/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19374/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19374/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code} · Accept: [%header{accept}]\n' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19374/customers
  {"timestamp":"…","status":415,"error":"Unsupported Media Type","path":"/customers"} 415 · Accept: [application/json, application/*+json]
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19374/customers
  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19374/customers/Mohan
  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ harness/shutdown.sh 19374 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19374 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
3 the binary - .harness/nat, the README's line, port 19378:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19378
  listens on: 127.0.0.1:19378 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19378/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19378 (http) with context path '/'
$ $CURLSET 19378 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the new route, on a second start of the binary:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19378
  listens on: 127.0.0.1:19378 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19378/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19378/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19378/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code} · Accept: [%header{accept}]\n' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19378/customers
  {"timestamp":"…","status":415,"error":"Unsupported Media Type","path":"/customers"} 415 · Accept: [application/json, application/*+json]
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19378/customers
  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19378/customers/Mohan
  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ harness/shutdown.sh 19378 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19378 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19377:
$ cd .harness/after && docker build --progress=plain -t tiffinbox-body:1.0.0 .
  exit 0 · its lines, through the filter:
    [internal] load metadata for docker.io/library/eclipse-temurin:25-jre
    [builder 1/4] FROM docker.io/library/eclipse-temurin:25-jre@sha256:fcd7fd7b387f94bb2ac461478a7436ad8e349924c374ea8313919624dceae636
    naming to docker.io/library/tiffinbox-body:1.0.0
  its lines that say pull: 0 · its other lines: fewer than 300, not shown
  the image saved (docker save): 15 blobs, its 11 layers among them, each read whole (gzip ones unpacked) · the demo token in them: 0
$ cd .harness/after && docker run -d --name tiffinbox-body --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19377:18425 tiffinbox-body:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19377/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19377
  on this Mac, listening on port 19377: 127.0.0.1:19377
$ $CURLSET 19377 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
$ docker wait tiffinbox-body
  0
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  its log (docker logs): Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1 · the demo token 0 times · X-Shutdown-Token 0 times
  then the new route, on a second container of the image:
$ cd .harness/after && docker run -d --name tiffinbox-body --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19377:18425 tiffinbox-body:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19377/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19377
  on this Mac, listening on port 19377: 127.0.0.1:19377
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19377/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19377/customers/Asha
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code} · Accept: [%header{accept}]\n' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19377/customers
  {"timestamp":"…","status":415,"error":"Unsupported Media Type","path":"/customers"} 415 · Accept: [application/json, application/*+json]
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19377/customers
  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19377/customers/Mohan
  {"name":"Mohan","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 200
$ harness/shutdown.sh 19377 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
$ docker wait tiffinbox-body
  0
  exit 0 · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times
four forms, one tree: the seven (masked) 4 of 4 times 87ca7efc8584dcccd40e6b956db1de9b · the new customer's record (POSTed, then read back) 8 of 8 · no Content-Type 415 4 of 4 · two point seven meals stored as 2 8 of 8 (POSTed, then read back)
  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127.0.0.1 alone yes
```


## Exercise

**Your turn:** the README's POST answers 415. Read the Accept header in the answer, add the one header it asks for, and post again.
`exercise/README.md` has the commands (copy `after/` with a token of its own, build the jar offline); its last line, in a subshell,
starts TiffinBox on 19379, POSTs Asha with `--data` and no `Content-Type`, counts the customers, stops TiffinBox and prints — as shipped —
`status: 415 · its Accept header: application/json, application/*+json · customers now: 4`. Done is `status: 200 · its Accept header:
none · customers now: 5`. Measured answer: `exercise/solution/SOLUTION.md` (the README's two `export` lines, then the same line with the
one header added), run in the same shell. Run `./receipts.sh` once first on a fresh clone.

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-14) |
|---|---|---|---|
| 7 | 08's POST status (200) and its exercise's end state | the chain end answers 201 | **200 and the record** (`change`, `ctype`, `forms`); the exercise **415 → 200**, 4 → 5 customers (`exercise`) |
| 8 | 58 → 56, annotations 2.22 → 2.21, Actuator's Jackson 2 condition, on 08's tree | s06/s12/s12p | **58 → 56 (3 out, 1 in); `jackson-annotations-2.22` → `-2.21`; `Jackson2EndpointAutoConfiguration` matched → did not match** (`jackson`) |
| 15 | the image of every chain unit | once, on the chain end | **built from after/'s Dockerfile, 0 pulls, its layers 0 tokens, `127.0.0.1:19377` alone, the seven `87ca7efc…` and the new route, `docker wait` 0** (`forms`) |
| 16 | the exercise as viewers run it | end state on a sketch | **one `env -i` shell: 415, then 200** (`exercise`) |

## Found on the way

- **Every new check fails on a planted fault first** (R.65): the checks block run alone on copies of the published captures, one line
  changed per plant — a file that differs taken out; 197 → 216 lines; `@RequestBody` 0 → 2; a hunk line changed; a code line out; 57 jars; 19 files the same; the POST before as 404; the POST after as 201; the new mapping gone; 8 mappings; 15 rows; `consumes` naming a type; 7 converters; the sixth not writing; a form read by one; a plain mapper strict; 7 DEBUG lines; 3 meals read; 3 constructor calls; a 400 without its WARN; another reason; 2.7 stored as 3; 4 WARN lines; the stored body refused; not listed first; 23503; a trace of 48 frames; the report's cut as 99; the misspelt customer found; B as 400; B's Accept header cut; A′ unlike A; B's customer stored; 57 jars in `jackson`; one Jackson 2 class left; no import; Boot's version as 2.22.2; Actuator's Jackson 2 configuration matching after; `zip` exit 0; configprops 500; 6 customers done; a second header in the solution; 3 of 4 forms; the binary not loopback; a raw token in one capture run; a carriage return in a capture — **47 plants, 47 stops**, each naming its check; the unplanted copies pass. The
  exercise's `SOLUTION.md` export checks are the request-mapping lesson's, verbatim (shown failing there).
- **Jackson 3 ignores an unknown property by its own default.** The brief and the correction comment speak of "the unknown-properties
  default"; read off two mappers, `FAIL_ON_UNKNOWN_PROPERTIES` is false on Boot's `jacksonJsonMapper` **and on a plain
  `JsonMapper.builder().build()`** (`chain`). So the difference from Core Java II's lesson — whose Jackson 2 refused one by default, "the
  default is strict" on its deck — is Jackson's major version, not Boot's configuration, and the voice says so ("Jackson three ignores
  it, in Boot's mapper … and in a plain one").
- **A body is in the log at DEBUG already.** The binding lesson's hand-off expected `@RequestBody` to show at TRACE (Spring MVC's
  `HandlerMethod` `Arguments:` line); one level sooner, with Boot's `web` group at DEBUG, `RequestResponseBodyMethodProcessor` prints the
  body it read, every value (`body`). Said on screen and in the anchor README.
- **Maven's dependency tree would have pointed at the wrong module.** `dependency:tree -Dincludes=com.fasterxml.jackson.core` on after/
  draws `jackson-annotations` under the optional `spring-boot-docker-compose` — Maven draws each artifact once, under the first
  declaration that reaches it — though the jar holds it through Spring MVC's starter. So `jackson` reads the jar's `lib/`, the class path
  Maven lists (`build-classpath`) and Jackson 3's own manifest instead, and never the tree.
- **`diff -U0` split the removed dependency block.** On the POM's non-comment lines it printed `-groupId`, `-artifactId`, `-</dependency>`,
  `-<dependency>` (the neighbours' identical tags shift the hunk); git's patience diff prints the block whole, and `jackson` uses it.
- **Course 5's configprops note was false already.** The anchor README's "every endpoint at once stops the start — `JavaTimeModule`, for
  `configprops`" (Course 5's actuator lesson, on TiffinBox's own server and its bridge) does not hold on Spring MVC's Actuator: configprops,
  exposed alone, answers 200 on the previous tree too (`jackson` C). Amended here because it names Jackson 2; the line itself exposes every
  endpoint (R.42), so it is not run. For RED: which Section 1 change made it false is not measured.
- **The anchor README's history notes** — sixteen, each amended in place (*Course 6, unit 08*). Eleven about Jackson 2: the
  embedded-Tomcat section's "one jar holds two Jacksons", the request-mapping section's 58 libraries and its `JDK14Util` paragraph,
  Course 5's pin (unit 03), the Compose module's "beside Jackson 2" (unit 17), the binary's class path (unit 20), configprops (unit
  21), the missing-class demo (unit 26), and Course 3's Requirements, Build and Versions sections. Five about the routes and the jar:
  the request-mapping section's "six routes, 8 mappings, 15 rows" note, the binding section's "six … 8 mappings … 15 rows" and its
  "the same 58 libraries", Course 5's mappings note ("five of `requestMappingHandlerMapping`'s rows", left at five by the binding
  lesson) and its logging note's "six … 8 mappings" — seven routes, 9 mappings, 16 rows and 56 libraries now.
- **The sealed clone caught a drift the development runs could not.** Its first run of `jackson` said `built the class path of
  .harness/before · offline: no` and the two after it `offline: yes`: the dependency plugin's `build-classpath` (this unit's line) needs
  the plugin's own dependencies, which no earlier build needed, so a fresh clone's empty `.m2-demo` fetched them inside the capture —
  `cap()` stopped the run (`jackson drifts across three runs`). The development runs never saw it: their `.m2-demo` was the whole seed.
  The script now lists both trees' class paths once before any capture (`build-cp0`, `build-cp`, beside the other pre-capture builds),
  and every run of record — the sealed clone's among them — is of that script.

## For unit 09 — and RED

- **Start from `../c6-unit08/after`** (= `../c6-tiffinbox`): `TiffinBoxServer` is a `final` `@RestController` (never `@Validated` on it:
  brief S2.19) with seven request mappings — `@GetMapping` `/customers` (`List<Customer> customers(@RequestParam(required = false)
  MealType mealType)`), `/customers/{name}` (`Customer customer(@PathVariable String name)`: a name nobody has →
  `ResponseStatusException` 404), **`@PostMapping("/customers")` — `Customer add(@RequestBody Customer customer) throws Exception`:
  `repo.add(customer)`, then `return customer` — 200 and the record**, `/revenue`, `/dashboard`, `/kitchen` (`Map<String, Object>`),
  `@PostMapping("/shutdown")` (`@RequestHeader(name = "X-Shutdown-Token", required = false) String token, HttpServletResponse response`).
  `CustomerRepository` has `findAll`, `findByName`, **`add(Customer)`** (one `INSERT`, four parameters, `executeUpdate()`; H2's NOT NULL
  and UNIQUE constraints are the only refusal), `monthRevenue`, `pausedDays`. TiffinBoxServer.java 215 lines, CustomerRepository.java 80.
- **One Jackson: Jackson 3, Boot's.** `tiffinbox-web/pom.xml` has no `jackson-databind` 2, the parent no `<jackson-2-bom.version>`; the jar
  holds **56** libraries, `jackson-annotations-2.21.jar` among them (Jackson 3 imports `com.fasterxml.jackson.annotation`), and
  `jackson-core-3.1.5.jar`, `jackson-databind-3.1.5.jar`. Boot's condition report: `Jackson2EndpointAutoConfiguration` does not match
  (no `ObjectMapper`). So 09's beat "use-jackson2-defaults" and "preferred-json-mapper=jackson2" run with **no Jackson 2 in the jar** — the
  brief's own hazard for `preferred-json-mapper` was measured with Jackson 2 present (s06): re-measure it on 09's tree, or don't say it.
- **Boot's mapper, as this unit read it** (the harness's `Converters`): the JSON converter's mapper is Boot's bean `jacksonJsonMapper`,
  `tools.jackson.databind.json.JsonMapper`; **`FAIL_ON_UNKNOWN_PROPERTIES` is false on it and on a plain `JsonMapper.builder().build()`** —
  Jackson 3's own default, not Boot's setting. The correction comment's first difference ("the unknown-properties default") is Jackson 2
  → 3; 09's `bean` beat should read every feature it names off the bean and, where it says "Boot's default", off a plain mapper too.
- **The seven are unchanged: `87ca7efc8584dcccd40e6b956db1de9b`** (masked; two lines change under the mask), in all four forms. Run
  them first, on a fresh JVM (S2.11): a POST before them moves three lines (a stored customer is listed).
- **Counts, here:** 9 mappings at TRACE (TiffinBox's 7 + Boot's 2), 16 routing-table rows (TiffinBox's 7: GET 5, POST 2), 6 message
  converters (the sixth `JacksonJsonHttpMessageConverter`, the only one that reads or writes a `Customer`), 56 libraries.
- **What a POST does on this tree, measured:** the anchor's line → 200 and the record; no `Content-Type` → 415 + `Accept: application/json,
  application/*+json` + 1 WARN; malformed, empty, an array, a missing `int`, trailing text → 400 + 1 WARN each; an unknown property,
  `"2"`, **`2.7` → stored, 200, 0 WARN (2.7 stored as 2: 09's key ends it)**; `""`/0/−5/`LUNCH` → 200, stored; a misspelt key → 500 (H2
  23502, Tomcat's ERROR line, over 50 frames); a taken name → 500 (23505). 09's `float` A′ must start a fresh JVM (or post a fresh name).
- **At DEBUG, a body is in the log whole:** `RequestResponseBodyMethodProcessor : Read "application/json;charset=UTF-8" to [Customer[…]]`.
  No capture may POST anything secret with the web group at DEBUG (and TRACE still prints POST /shutdown's token: the binding lesson's
  `trace`).
- **The anchor README's history notes about Jackson 2** are amended (11, "Course 6, unit 08"); 09 adds `application.yaml`'s first-document
  key — check its line number against the `---` (S1-R.87) and grep the README for `accept-float-as-int`, `2.7`, `stored as 2`.
- **Harness on the class path:** `javac -parameters` (S2.16); answers on one line; a JSON body single-quoted; a URL with `;`, `?`, `&`,
  `{` or `}` single-quoted. The POST line builder `pc PORT PATH 'BODY'` is asserted against the anchor README's line.
- **Native:** no hint in the tree; Spring's AOT metadata names `Customer` (a route reads it and returns it); native builds here: see
  "Runs of record". The image: `tiffinbox-body:1.0.0` is this unit's name — take your own.
- **The interrupt test** starts the receipts as a terminal starts its foreground job (SIGINT at its default, a process group of its own) —
  the binding lesson's `python3 -c '… os.setpgrp(); os.execvp(…)'` line; a plain background job ignores SIGINT.
- **Ports 19370-19379 are this unit's;** 09 has 19380-19389.
- **Not done here:** Jackson's configuration (09); `ResponseEntity`, 201 and 409 (10); validation (12); converters (13); the POM's
  `<description>` still says "the router" (stale since the request-mapping lesson; not this unit's change — for RED).
