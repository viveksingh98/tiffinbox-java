# c6-unit06 — @RestController and Request Mapping

Course 6 · Spring Web MVC · Section 2 (Controllers and Binding), its first unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16,
Spring Boot 4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5 for Spring), **GraalVM CE 25.3.4.1** (native-image
25.0.4.1), **Docker on OrbStack**, 2026-10-14. Since Core Java II TiffinBox has found its own routes: an annotation of its own
(`Route`), a scan by reflection, a `TreeMap` keyed "VERB path", the verb checked inside its handler. This unit swaps each of those
jobs for Spring MVC's own — `TiffinBoxServer` becomes a **`@RestController`**, its five routes **`@GetMapping`** and **`@PostMapping`**
— and measures what Spring MVC now decides that TiffinBox used to: which verbs, which paths, which patterns, who writes the answers,
who times them, and which of the seven change.

**The anchor changes (brief ⚑2-⚑6, ⚑15-⚑16).** `after/` is this unit's frozen copy of `../c6-tiffinbox` after the change:
`diff -rq -x target ../c6-tiffinbox after/` was empty at this unit's commit (997c0c8), and the later chain units have moved the anchor
on since (RED S2 #24); a fix to this tree goes into every later one (brief S2.21). "Before" is `../c6-unit04/after` — the embedded-Tomcat lesson's frozen tree,
which `c6-tiffinbox` equalled at 79887fd. Both trees are read and copied under `.harness/`, never built in place. The change:
`TiffinBoxServer.java` (`@Component` → `@RestController`; `@Route` → `@GetMapping` ×4 and `@PostMapping`; each route returns its
type, `List<Customer>` or `Map<String, Object>`; `@RegisterReflectionForBinding(Customer.class)` out; deleted with the router:
`scanRoutes()`, `handlers()`, `RouteHandler`, `handle()`, `respond()`, `paths()`, the Jackson 2 `ObjectMapper` field, TiffinBox's own
timer `tiffinbox.requests` and its line per answer at DEBUG; POST /shutdown a controller method — 285 lines → 176), `Route.java` (24
lines) and `RouteMapping.java` (20) **deleted**, and the anchor's `README.md` (the unit section, and the history notes the change made
false, each amended in place), and the web POM's two lines that named the router — its description, and the comment above Spring
MVC's starter (`RouteMapping`, "the Jackson 2 above") — amended (RED S2 #21: every dependency and plugin line the same). The parent POM,
`application.yaml`, `spring.factories`, the Dockerfile, `compose.yaml`, the meters, the indicator, the guard, `TiffinBoxApp.java` and
`tiffinbox-core` are unchanged — byte for byte (`change`).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 11 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) **Docker must
answer** (`docker info`; on OrbStack `orb start` is tried once if it does not), with `eclipse-temurin:25-jre` already on it: the
script never pulls. It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first). One native
build per `forms` run (three per receipt); its seconds, and the 20-minute bound, go to the terminal only — a hashed line must not move
with the machine's load (RED S2 #11). **Start it
in a process group of its own** (a terminal's foreground job is one): two receipts started as background jobs of one shell share a
group, and one run's clean-up would stop the other's JVMs (Section 1's finding, brief S2.4).

**Runs of record (2026-10-14, BLUE A — this script as committed, after RED S2):** **865 s under `./receipts.sh`** (/bin/bash 3.2.57,
this folder, its own process group; every capture 3/3, every check passed; it made the four changed hashes — `change`, `timers`, `stop`,
`forms` — and stopped on "no published hash", as designed; the other seven = published; the native builds 143, 142 and 144 s) and
**990 s under `bash receipts.sh`** (Homebrew bash 5.3.9: exit 0, all 11 = published — the bytes bash 3.2 made — every check passed; 165,
178 and 182 s; load averages 5-12). Before both, `.m2-demo` was re-seeded from `_research/m2-seed-s2/` alone (RED S2 #25): every build
said `offline: yes`. **The exercise as viewers run it**, beyond the capture: README then SOLUTION in one `env -i` `/bin/bash --noprofile
--norc` shell, its `java` 23.0.1 before the exports → `status: 405 · Allow: GET · customers: 0`, then `status: 200 · Allow: none ·
customers: 4`, the shell in `c6-unit06/` after each, 19359 free after. **The first runs** (997c0c8, before RED): 1,384 s under
`./receipts.sh`, 1,079 s under `bash receipts.sh`, 1,118 s from a sealed fresh clone — RED S2 #1 found this README then tripped its own
S2.13 check (fixed above), and RED S2 #2 found `stop` B a race (now held: A/B/A′ above); BLUE's sealed fresh clone ran on the binding
lesson's unit (`../c6-unit07/`, its README).

Published hashes: change `79f5e9033e0213c0f188227ec0b89a95` · scan `bac026c989e99fe1efea1ce07eb5cd7f` · rows `bebbe2fc12ea6d4320a3e993fe348ab6` · verbs `f291e5a20f56e8ad67365606b5481040` · seven `a85e6e5b349bcddc50bf6caba79b35fb` · json `f4b6186bf543ce5e90bd6cd11a5f9c68` · patterns `572218725a798f5fa9c2ff5be7c889b8` · timers `0983a966052639867fe09f913850fcfe` · stop `ab0b487fedc21a6a6f9110e8a97f5e2b` · exercise `31ed311e266aebcca69f6c746241937b` · forms `db1de714de65d90e821c93f54aeecc2a`.

## The commands this unit adds

`after/README.md` — the anchor's own — gives every line `receipts.sh` runs or derives from but ten, which are this unit's, each read
from the block below and asserted to be exactly this (on the anchor's port 18431; each capture swaps in its own port):

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.kitchen=debug --logging.level.org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping=trace
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,mappings
curl -s http://127.0.0.1:18431/actuator/mappings | python3 harness/table.py
curl -s http://127.0.0.1:18431/actuator/mappings | python3 harness/table.py row /customers
curl -s -o /dev/null -w '%{http_code} %{content_type} · Allow: %header{allow} · Content-Length: %header{content-length}\n' http://127.0.0.1:18431/customers
curl -s -D - -o /dev/null http://127.0.0.1:18431/customers
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.mvc.pathmatch.matching-strategy=ant-path-matcher
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --server.shutdown=immediate
zip -q -d tiffinbox-web/target/hang/lib/jackson-databind-3.1.5.jar 'tools/jackson/databind/util/RecordUtil*'
java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" probe.web.Stereotype com.tiffinbox.web.TiffinBoxServer
```

The first starts TiffinBox with its own log group at DEBUG and Spring MVC's mapping logger at TRACE (`scan`). The second exposes
`mappings` for one run, on the plain JVM — under Spring's AOT step a run-time exposure flag adds nothing (the mappings lesson) — and
the next two read its answer with `harness/table.py` (`rows`). The fifth prints one answer's status, type, `Allow` and
`Content-Length` (`verbs`); the sixth one answer's status line and header names (`seven`). The seventh switches Spring MVC to the
legacy parser, by flag, for one run (`patterns` B). The eighth makes Boot's shutdown immediate (`stop` B, with the harness's `SlowAfter` joined). The ninth deletes one class
Jackson 3 needs for a record from the hang copy that the anchor README's missing-class lines make (`json` C). The last reads a class's
annotations the way Spring does (`change`), run from a tree's folder, with the harness's classes in `../hc`.

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else, refuses one whose `native-image --version` is not
`native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1`, and never prints its folder (`$GRAALVM_HOME` in every capture). Only `forms`
needs it. **Without a GraalVM** the script still fills `.m2-demo`, makes the ten other captures, each checked against `receipts.md5`,
then stops where the native build would start (exit 1).

## The repository, Docker, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../spring-web-mvc/_research/m2-seed-s2/` alone — 5,837 files, no `com/tiffinbox` (a stale install would satisfy `-pl tiffinbox-web
native:compile-no-fork`). The first seeding added the previous unit's `.m2-demo` to the seed — the same files, `diff -rq` 0 — which the
brief forbids (RED S2 #25); BLUE re-seeded it from the seed alone on 2026-10-14, before the runs of record. **Nothing was downloaded** for this unit: every build said `offline: yes`, the native plugin read its metadata
repository from `.m2-demo` (`file:`), and every native build log holds 0 lines of the plugin's own download (`Downloaded GraalVM
reachability metadata repository from http`, `Failed to download from http`). A fresh clone's `.m2-demo` is empty (git ignores it):
the first build — `after/`'s `mvn -B -Pnative install`, before any capture — fills it from Maven Central and says `offline: no`; every
capture's build then says `offline: yes`. The install writes `com/tiffinbox` into this unit's `.m2-demo` — fine here, and never copied
into a seed. **Docker:** no pull — `docker build` prints its `load metadata` line and the base image's digest, and `its lines that say
pull: 0`. The image (`tiffinbox-mvc:1.0.0`) and the container (`tiffinbox-mvc`) are this script's own names, checked absent first and
removed on every exit; the build cache is not pruned (`.dockerignore` keeps `secrets/` out of every build context, so it holds no
token).

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 26 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/*/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) when the script runs, mounted read-only into the container (`:ro`), and sent only by `../c5-unit11/curlset.sh` and
`harness/shutdown.sh` on curl's standard input. Every capture's raw output is searched for it before masking (0 in all of them), and so
are the log of every JVM that served, every start that ended by itself, the container's log (`docker logs`), every file this unit
ships, the binary's bytes, and every blob of the image (`docker save`, each gzip layer unpacked; `forms`): 0 everywhere. The exercise
makes a token of its own (`openssl rand -hex 13`: 26 hexadecimal digits), counted 0 times in its own log and never printed.

## The folders, the names and the ports

- `after/` — the anchor after this change (= `../c6-tiffinbox`). `.harness/before`, `.harness/after` — the two trees, copied, each
  with a config tree, built and extracted (`change`); `.harness/nat` — `after/`'s native build (`forms`); `.harness/obj` — `after/` with
  `customers()` returning `Object`, built with the profile native (`forms` C); `.harness/hc` — the harness's classes, compiled against
  `after/`'s own jar with `-parameters`; `.harness/mine` — the exercise's copy.
- **The harness** — the course's, never TiffinBox's (package `probe.web`, outside `com.tiffinbox`): `harness/probe/web/Stereotype.java`
  (a `main`, no server, no Spring context: a class's annotations as `AnnotatedElementUtils.hasAnnotation` reads them — the call Spring
  MVC's `RequestMappingHandlerMapping` makes to decide that a bean is a controller — and the annotations `@RestController` and
  `@Controller` carry); `Converters.java` (`--spring.main.sources=probe.web.Converters`: `/probe/converters`, the message converters
  Spring MVC's `RequestMappingHandlerAdapter` holds, and each JSON one's class and mapper — the embedded-Tomcat lesson's, copied);
  `Patterns.java` (`/probe/menu/{day}`, the literal `/probe/menu/today` beside it, `/probe/files/{*rest}`); `MidPattern.java` (one route
  on `/probe/kitchen/**/today`); `SlowAfter.java` (`--spring.main.sources=probe.web.SlowAfter`: an interceptor on POST `/shutdown` alone
  that holds the request's own thread 2 s after TiffinBox's method returned, so the answer is still in flight when the server is told
  to stop — `stop`); `harness/table.py` (the mappings lesson's reader of `/actuator/mappings`, its one change: TiffinBox's
  rows are the ones whose handler is TiffinBox's — its own named handler, or a `TiffinBoxServer` method — and their verbs are counted);
  `harness/shutdown.sh` (POST `/shutdown`, or the path named, with the token read from its file: the status, type, `Content-Length`,
  body and curl's exit).
- **Ports** (brief ⚑1, 19350-19359): after/'s jar 19350 · the previous tree 19351 · after/ with the harness joined 19352 · the
  mid-path pattern's A/B/A′ 19353 · the AOT jar 19354 · the missing-class copies of after/ 19355 · stop 19356 · the image 19357 · the
  binary 19358 · the exercise 19359. 18425 (TiffinBox's default) and 8080 (Tomcat's) are checked free and never bound on this Mac
  (18425 only inside the container); a run that listens on 8080 is killed and the script dies.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM, the token, the user** (`gsub()`, literals escaped), in every line: the token → `[masked: the 26-character
   token]` (its length read off the token); the GraalVM's folder → `$GRAALVM_HOME`; this folder → `…`; the folder above → `…/..`;
   home → `~`; the user name, as a whole word → `<user>`. A last check fails if any capture holds `/Users/`, `/private/`, `/home/`,
   `/var/folders/`, the GraalVM's folder, a unit number, Boot's process line, a log time, an unmasked timestamp, a thread number, a stack
   frame, a `sha256:` ID other than the base image's digest, or `:8080`.
2. **Spring's error timestamp** (`tsmask`, `gsub`): `"timestamp":"<anything>"` → `"timestamp":"…"` and `"timestamp":<digits>` →
   `"timestamp":…` — both forms. The seven are hashed after it; each `seven` line says how many lines it changed (1 on the previous tree,
   `/nowhere`'s; 2 on after/: `/nowhere`'s and GET /shutdown's). In a JSON answer read with its keys sorted, and in a DEBUG line's error
   map (`timestamp=…,`), the same.
3. **DEBUG and WARN lines** (`logl`): from their level and logger on, as the log prints the logger (`.w.s.m.s.DefaultHandlerExceptionResolver`
   is Spring MVC's; `o.s.boot.*` Boot's; `o.a.*` Tomcat's — read off the log, never typed); an identity hash after `@` → `@…`. The lines
   of one request are those the log gained between two points where it stopped growing; what they cut — the start, the readiness polls —
   is bounded ("more than 20").
4. **Orders that move between runs, sorted** (each says so on screen): the routes inside one block of `RequestMappingHandlerMapping`'s
   TRACE lines (`scan`), TiffinBox's own `route …` lines at start (the scan finds them in the order `getDeclaredMethods` gives), and the
   routing table's rows with details (`harness/table.py`, `rows`).
5. **A start that ended by itself** (`fails()`) is read after it exited, never printed whole: `APPLICATION FAILED TO START`, frames,
   `Caused by:` and folded frames counted, Boot's Tomcat lines counted; WARN/ERROR lines from their level on, a WARN cut after its
   exception's class; each exception's first line; Boot's hint; the analysis from `Description:` on; the banner counted. **Never a line
   total** (R.45, R.77).
6. **A trace in a log that served** (`json`): its frames bounded ("over 50, not shown"), each exception's first line shown.
7. **The scrape** (`timers`): its `_count` lines for both timers, read until two reads half a second apart agree; Actuator's own series
   left out and bounded ("fewer than 10"); then the sums.
8. **The native build's lines**: its plugin goals, the GraalVM line, the Java version, each `Warning:` — the file a warning names (`in
   'file:…'`, or `in 'null'`, which native-image prints when the path holds a space) → `in '…'` — the eight stages cut after their name,
   the warnings count and `BUILD SUCCESS`; the rest counted, never shown. The binary's DEBUG run (`%thread %msg%n`): `tomcat-handler-<n>`
   → `tomcat-handler-N`; its other lines bounded ("more than 40").
9. **`docker build --progress=plain`** through a filter: its `load metadata` line, its `FROM` line (the base image's digest), its naming
   line, step numbers and timings cut (checked on a planted log first); lines that say pull, counted; the rest bounded ("fewer than 300").
10. **Inside the container**: `/proc/net/tcp` and `tcp6`, LISTEN rows only, the address decoded. **On this Mac**: `lsof` by pid (or by
    port, for Docker's forwarder), the address column alone — never a command name (R.18).
11. **A URL that holds a character the shell reads** (`;`, `?`) is single-quoted on the command line, so the printed command is the one
    that ran (`patterns`, `timers`).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`, `$fpid`, and
the exercise's shell `$xpid` with every process under it — `killtree`, by parent pid), sweeps its own process group for any TiffinBox
JVM, binary or `native-image` left, removes the container and the image, deletes the capture runs it had not finished (`.r-NAME.1-3`),
and removes `.r-lock`. The published captures are untouched.

**Measured** on this script (2026-10-14): SIGINT to its process group during the native build (459 s in, GraalVM's image
builder running — 5 processes in the group, 2 of them java, native-image's driver and its builder among them): **exit 130** 0.2 s
later; 5 s later 0 processes in the group and 0 anywhere naming this folder, no image builder left; 19350-19359, 8080 and 18425
free; no container, no image, no `.r-lock`, no unfinished capture run; the published captures unchanged. And once during `forms`'
AOT-jar form ("Found on the way"): the group emptied, the lock removed, every port free, no container.

## 1 · change — the previous tree against after/

Both trees built offline and extracted; the harness compiled against `after/`'s jar with `-parameters`; `diff -rq`: five paths —
`Route.java` and `RouteMapping.java` only in the previous tree, `TiffinBoxServer.java`, the anchor README and the web POM different. The server's
code lines (neither comment nor blank) naming each job the change moves: the router's parts (`@Route`, `scanRoutes`, its `TreeMap`,
`invoke`) 10 → 0, the hint 2 → 0, TiffinBox's own timer → 0, a DEBUG line of TiffinBox's 2 → 0, its own Jackson 2 mapper 3 → 0, Spring
MVC's mapping annotations 0 → 6; of the code diff's 21 hunks, the 6 that change a class or route annotation, whole (the other 15 delete
the router: the big one is printed whole too, in the capture). The harness's `Stereotype`, on each tree's extracted jar: before
`@Component` alone; after `@RestController yes · @Controller yes · @Component yes · @ResponseBody yes`, `@RestController` carrying
`@Controller @ResponseBody` and `@Controller` carrying `@Component` (C6-24). The web POM: its lines that name `RouteMapping` or a router
2 → 0, its one non-comment line changed the description (RED S2 #21). The jar's 58 libraries, unchanged (Jackson 2 among them, until
Course 6's Jackson lessons); eleven files byte for byte the same; `tiffinbox-core` 0 differences.

`.r-change.out` · md5 `79f5e9033e0213c0f188227ec0b89a95` · 3 of 3

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
the harness, compiled against after/'s own jar - with -parameters, so a method's parameter names are in its class file:
$ javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/probe/web/*.java
  exit 0
the files that differ:
$ diff -rq -x target -x secrets .harness/before .harness/after
  Files .harness/before/README.md and .harness/after/README.md differ
  Files .harness/before/tiffinbox-web/pom.xml and .harness/after/tiffinbox-web/pom.xml differ
  Only in .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web: Route.java
  Only in .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web: RouteMapping.java
  Files .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java and .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java differ
the router's two files, and the server, their lines (wc -l), before -> after:
  Route.java: 24 -> deleted
  RouteMapping.java: 20 -> deleted
  TiffinBoxServer.java: 285 -> 176
  TiffinBoxServer.java, its lines that are neither comment nor blank: 188 -> 100, of them naming:
    the router's parts (@Route, scanRoutes, its TreeMap, invoke): 10 -> 0
    the hint (@RegisterReflectionForBinding): 2 -> 0 · the router's annotation's hint, @Reflective, in Route.java: 1 -> the file is deleted
    TiffinBox's own timer (tiffinbox.requests, Timer, MeterRegistry): 6 -> 0 · a DEBUG line of TiffinBox's (LOG.log(DEBUG, …)): 2 -> 0
    its own Jackson 2 mapper (ObjectMapper, JSON.write…): 3 -> 0 · Spring MVC's mapping annotations (@RestController, @GetMapping, @PostMapping): 0 -> 6
  its code lines' diff (diff -U0 of the lines above, its file names cut): 21 hunks, 108 lines out, 20 in - the 6 hunks that change a class or route annotation, whole:
    @@ -29,2 +22 @@
    -@Component
    -@RegisterReflectionForBinding(Customer.class)
    +@RestController
    @@ -55,2 +42,2 @@
    -    @Route(path = "/customers")
    -    Object customers() throws Exception {
    +    @GetMapping("/customers")
    +    List<Customer> customers() throws Exception {
    @@ -59,2 +46,2 @@
    -    @Route(path = "/revenue")
    -    Object revenue() throws Exception {
    +    @GetMapping("/revenue")
    +    Map<String, Object> revenue() throws Exception {
    @@ -63,2 +50,2 @@
    -    @Route(path = "/dashboard")
    -    Object dashboard() throws Exception {
    +    @GetMapping("/dashboard")
    +    Map<String, Object> dashboard() throws Exception {
    @@ -73,2 +60,2 @@
    -    @Route(path = "/kitchen")
    -    Object kitchen() {
    +    @GetMapping("/kitchen")
    +    Map<String, Object> kitchen() {
    @@ -80,3 +67,7 @@
    -    @Route(path = "/shutdown", method = "POST")
    -    Object shutdown() {
    -        stopRequested = true;
    +    @PostMapping("/shutdown")
    +    Map<String, Object> shutdown(HttpServletRequest request, HttpServletResponse response) {
    +        if (!holdsToken(request)) {                  // the server keeps running
    +            response.setStatus(403);
    +            return ordered("error", "forbidden");
    +        }
    +        Thread.ofPlatform().start(context::close);
the class, read by the harness's Stereotype - no server, no context: java on the extracted jar's class path, before then after:
$ cd .harness/before && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" probe.web.Stereotype com.tiffinbox.web.TiffinBoxServer
  TiffinBoxServer - the annotations on the class itself: @Component @RegisterReflectionForBinding
  TiffinBoxServer - as Spring reads it (AnnotatedElementUtils.hasAnnotation): @RestController no · @Controller no · @Component yes · @ResponseBody no
  @RestController - the annotations it carries (java.lang.annotation's left out): @Controller @ResponseBody
  @Controller - the annotations it carries (java.lang.annotation's left out): @Component
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" probe.web.Stereotype com.tiffinbox.web.TiffinBoxServer
  TiffinBoxServer - the annotations on the class itself: @RestController
  TiffinBoxServer - as Spring reads it (AnnotatedElementUtils.hasAnnotation): @RestController yes · @Controller yes · @Component yes · @ResponseBody yes
  @RestController - the annotations it carries (java.lang.annotation's left out): @Controller @ResponseBody
  @Controller - the annotations it carries (java.lang.annotation's left out): @Component
the executable jar's BOOT-INF/lib: 58 jars -> 58 · removed 0 · added 0 · Jackson 2 (jackson-databind 2.x) 1 -> 1 · Jackson 3 (jackson-databind 3.x) 1 -> 1
  README.md - the anchor's README: lines added 145, removed 20 - its new section and the history notes the change made false (not shown)
  tiffinbox-core against the previous tree's (diff -rq -x target): 0 files differ
  tiffinbox-web/pom.xml - the text that named the router, amended: its lines that name RouteMapping or a router 2 -> 0 · its lines that are not comments: 1 out, 1 in - the description:
    -  <description>The HTTP server, the router and the JSON. No SQL in here.</description>
    +  <description>Spring MVC's routes over TiffinBox's core. No SQL in here.</description>
  tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java against the previous tree's, byte for byte: the same
  tiffinbox-web/src/main/java/com/tiffinbox/web/BareArgumentGuard.java against the previous tree's, byte for byte: the same
  tiffinbox-web/src/main/java/com/tiffinbox/web/BareArgumentAnalyzer.java against the previous tree's, byte for byte: the same
  tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenHealthIndicator.java against the previous tree's, byte for byte: the same
  tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenMetrics.java against the previous tree's, byte for byte: the same
  tiffinbox-web/src/main/resources/application.yaml against the previous tree's, byte for byte: the same
  tiffinbox-web/src/main/resources/META-INF/spring.factories against the previous tree's, byte for byte: the same
  pom.xml against the previous tree's, byte for byte: the same
  Dockerfile against the previous tree's, byte for byte: the same
  compose.yaml against the previous tree's, byte for byte: the same
  .dockerignore against the previous tree's, byte for byte: the same
```

## 2 · scan — what registers the routes at start (C6-27)

This unit's line — the kitchen at DEBUG, Spring MVC's `RequestMappingHandlerMapping` at TRACE — on each tree, and its lines up to Boot's
started line. Before: TiffinBox's own five `route …` lines and `routes mapped: […]`; Spring MVC's mapping registers Boot's two `/error`
routes, `2 mappings`. After: none of TiffinBox's own; `c.t.w.TiffinBoxServer:` and its five routes, each with its verb, Boot's two, `7
mappings in 'requestMappingHandlerMapping'` — then Boot's started line: registered before Tomcat started. Core Java II's card,
`@GetMapping("/customers")` — "Spring reads it and wires a web route" — measured for TiffinBox's own route (the DispatcherServlet
lesson measured it for a harness route).

`.r-scan.out` · md5 `bac026c989e99fe1efea1ce07eb5cd7f` · 3 of 3

```
before - the previous tree: this unit's line - TiffinBox's own logger group, kitchen, at DEBUG, and Spring MVC's RequestMappingHandlerMapping at TRACE - port 19351:
$ cd .harness/before && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19351 --logging.level.kitchen=debug --logging.level.org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping=trace
  listens on: 127.0.0.1:19351 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19351/actuator/health/readiness
  {"status":"UP"} 200
  TiffinBox's own lines that name a route, before Boot's started line (logger tiffinbox; the route lines sorted): 5 + 1
    tiffinbox: route GET /customers -> customers()
    tiffinbox: route GET /dashboard -> dashboard()
    tiffinbox: route GET /kitchen -> kitchen()
    tiffinbox: route GET /revenue -> revenue()
    tiffinbox: route POST /shutdown -> shutdown()
    tiffinbox: routes mapped:  [GET /customers, GET /dashboard, GET /kitchen, GET /revenue, POST /shutdown]
  Spring MVC's RequestMappingHandlerMapping, its lines before Boot's started line (logger: level, message; a block's routes sorted):
    s.w.s.m.m.a.RequestMappingHandlerMapping: TRACE
      o.s.b.w.a.e.BasicErrorController:
        { [/error], produces [text/html]}: errorHtml(HttpServletRequest,HttpServletResponse)
        { [/error]}: error(HttpServletRequest)
    s.w.s.m.m.a.RequestMappingHandlerMapping: DEBUG 2 mappings in 'requestMappingHandlerMapping'
  then Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19351 (http) with context path '/'
$ harness/shutdown.sh 19351 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19351 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
after - after/, the same line, port 19350:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19350 --logging.level.kitchen=debug --logging.level.org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping=trace
  listens on: 127.0.0.1:19350 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19350/actuator/health/readiness
  {"status":"UP"} 200
  TiffinBox's own lines that name a route, before Boot's started line (logger tiffinbox; the route lines sorted): 0 + 0
  Spring MVC's RequestMappingHandlerMapping, its lines before Boot's started line (logger: level, message; a block's routes sorted):
    s.w.s.m.m.a.RequestMappingHandlerMapping: TRACE
      c.t.w.TiffinBoxServer:
        {GET [/customers]}: customers()
        {GET [/dashboard]}: dashboard()
        {GET [/kitchen]}: kitchen()
        {GET [/revenue]}: revenue()
        {POST [/shutdown]}: shutdown(HttpServletRequest,HttpServletResponse)
    s.w.s.m.m.a.RequestMappingHandlerMapping: TRACE
      o.s.b.w.a.e.BasicErrorController:
        { [/error], produces [text/html]}: errorHtml(HttpServletRequest,HttpServletResponse)
        { [/error]}: error(HttpServletRequest)
    s.w.s.m.m.a.RequestMappingHandlerMapping: DEBUG 7 mappings in 'requestMappingHandlerMapping'
  then Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19350 (http) with context path '/'
$ harness/shutdown.sh 19350 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19350 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 3 · rows — the routing table, before and after (H3)

`mappings` exposed for one run, on the plain JVM, read by `harness/table.py`: 14 rows on each tree. Before, TiffinBox's five rows hold a
path and a handler's name (`/customers -> TiffinBox route /customers`, 2 keys, no verb); after, a verb, a pattern and a method
(`{GET [/customers]} -> TiffinBoxServer#customers()`, `methods ["GET"]`, `descriptor ()Ljava/util/List;` — the precise return type).

`.r-rows.out` · md5 `bebbe2fc12ea6d4320a3e993fe348ab6` · 3 of 3

```
before - the previous tree, mappings exposed for this one run (this unit's line), port 19351:
$ cd .harness/before && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19351 --management.endpoints.web.exposure.include=health,prometheus,mappings
  listens on: 127.0.0.1:19351 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19351/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19351/actuator/mappings | python3 harness/table.py
  contexts: 1 (application) · kinds: 3 (dispatcherServlets servletFilters servlets)
  dispatcherServlets · dispatcherServlet: 14 rows, in the table's order - a run of rows with details sorted by pattern (produces lists cut: 5 · class names cut to their last part: 2)
    1  {GET [/actuator], produces [application/vnd.spring-boot.actuator.v3+json … 2 more]} -> Actuator root web endpoint
    2  {GET [/actuator/health], produces [application/vnd.spring-boot.actuator.v3+json … 2 more]} -> Actuator web endpoint 'health'
    3  {GET [/actuator/health/**], produces [application/vnd.spring-boot.actuator.v3+json … 2 more]} -> Actuator web endpoint 'health-path'
    4  {GET [/actuator/mappings], produces [application/vnd.spring-boot.actuator.v3+json … 2 more]} -> Actuator web endpoint 'mappings'
    5  {GET [/actuator/prometheus], produces [text/plain;version=0.0.4;charset=utf-8 … 2 more]} -> Actuator web endpoint 'prometheus'
    6  /customers -> TiffinBox route /customers
    7  /dashboard -> TiffinBox route /dashboard
    8  /kitchen -> TiffinBox route /kitchen
    9  /revenue -> TiffinBox route /revenue
   10  /shutdown -> TiffinBox route /shutdown
   11  { [/error], produces [text/html]} -> BasicErrorController#errorHtml(HttpServletRequest, HttpServletResponse)
   12  { [/error]} -> BasicErrorController#error(HttpServletRequest)
   13  /webjars/** -> ResourceHttpRequestHandler [classpath [META-INF/resources/webjars/]]
   14  /** -> ResourceHttpRequestHandler [classpath [META-INF/resources/], classpath [resources/], classpath [static/], classpath [public/], ServletContext [/]]
  rows with details: 7 · without: 7 · naming a verb: 5 (GET 5)
  TiffinBox's rows (its own handler, or a TiffinBoxServer method): 5 · naming a verb: 0
  servletFilters: 5, by name: characterEncodingFilter, formContentFilter, requestContextFilter, Tomcat WebSocket (JSR356) Filter, webMvcObservationFilter · on /* : 5
  servlets: 1 · dispatcherServlet on /
$ curl -s http://127.0.0.1:19351/actuator/mappings | python3 harness/table.py row /customers
  the row for /customers: 1
  /customers - 2 keys: handler predicate
    handler = TiffinBox route /customers
    predicate = /customers
$ harness/shutdown.sh 19351 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19351 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
after - after/, the same line, port 19350:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19350 --management.endpoints.web.exposure.include=health,prometheus,mappings
  listens on: 127.0.0.1:19350 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19350/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19350/actuator/mappings | python3 harness/table.py
  contexts: 1 (application) · kinds: 3 (dispatcherServlets servletFilters servlets)
  dispatcherServlets · dispatcherServlet: 14 rows, in the table's order - a run of rows with details sorted by pattern (produces lists cut: 5 · class names cut to their last part: 7)
    1  {GET [/actuator], produces [application/vnd.spring-boot.actuator.v3+json … 2 more]} -> Actuator root web endpoint
    2  {GET [/actuator/health], produces [application/vnd.spring-boot.actuator.v3+json … 2 more]} -> Actuator web endpoint 'health'
    3  {GET [/actuator/health/**], produces [application/vnd.spring-boot.actuator.v3+json … 2 more]} -> Actuator web endpoint 'health-path'
    4  {GET [/actuator/mappings], produces [application/vnd.spring-boot.actuator.v3+json … 2 more]} -> Actuator web endpoint 'mappings'
    5  {GET [/actuator/prometheus], produces [text/plain;version=0.0.4;charset=utf-8 … 2 more]} -> Actuator web endpoint 'prometheus'
    6  {GET [/customers]} -> TiffinBoxServer#customers()
    7  {GET [/dashboard]} -> TiffinBoxServer#dashboard()
    8  { [/error], produces [text/html]} -> BasicErrorController#errorHtml(HttpServletRequest, HttpServletResponse)
    9  { [/error]} -> BasicErrorController#error(HttpServletRequest)
   10  {GET [/kitchen]} -> TiffinBoxServer#kitchen()
   11  {GET [/revenue]} -> TiffinBoxServer#revenue()
   12  {POST [/shutdown]} -> TiffinBoxServer#shutdown(HttpServletRequest, HttpServletResponse)
   13  /webjars/** -> ResourceHttpRequestHandler [classpath [META-INF/resources/webjars/]]
   14  /** -> ResourceHttpRequestHandler [classpath [META-INF/resources/], classpath [resources/], classpath [static/], classpath [public/], ServletContext [/]]
  rows with details: 12 · without: 2 · naming a verb: 10 (GET 9 POST 1)
  TiffinBox's rows (its own handler, or a TiffinBoxServer method): 5 · naming a verb: 5 (GET 4 POST 1)
  servletFilters: 5, by name: characterEncodingFilter, formContentFilter, requestContextFilter, Tomcat WebSocket (JSR356) Filter, webMvcObservationFilter · on /* : 5
  servlets: 1 · dispatcherServlet on /
$ curl -s http://127.0.0.1:19350/actuator/mappings | python3 harness/table.py row /customers
  the row for /customers: 1
  /customers - 3 keys: details handler predicate
    details.handlerMethod.className = com.tiffinbox.web.TiffinBoxServer
    details.handlerMethod.descriptor = ()Ljava/util/List;
    details.handlerMethod.name = customers
    details.requestMappingConditions.consumes = []
    details.requestMappingConditions.headers = []
    details.requestMappingConditions.methods = ["GET"]
    details.requestMappingConditions.params = []
    details.requestMappingConditions.patterns = ["/customers"]
    details.requestMappingConditions.produces = []
    handler = com.tiffinbox.web.TiffinBoxServer#customers()
    predicate = {GET [/customers]}
$ harness/shutdown.sh 19350 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19350 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 4 · verbs — who decides the verbs (C6-10, H4, H7; C6-7's first half)

The same seven requests on each tree, at Boot's default level: each answer, the WARN lines it added, and a table at the end of each
run. Before, TiffinBox's own handler answers HEAD, OPTIONS, DELETE and GET /shutdown with its own `405`, no `Allow`; an XML `Accept`
header gets 200 JSON; 0 WARN lines. After, Spring MVC decides: HEAD 200 (`Content-Length: 282`), OPTIONS 200 `Allow: GET,HEAD,OPTIONS`,
DELETE 405 `Allow: GET`, GET /shutdown 405 `Allow: POST`, XML only 406 with no body — and each 405 and the 406 adds **one WARN line**,
`.w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpRequestMethodNotSupportedException: …]`; HEAD, OPTIONS
and the 403 add none (S2.17).

`.r-verbs.out` · md5 `f291e5a20f56e8ad67365606b5481040` · 3 of 3

```
before - the previous tree, the README's run line, port 19351:
$ cd .harness/before && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19351
  listens on: 127.0.0.1:19351 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19351/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code} %{content_type} · Allow: %header{allow} · Content-Length: %header{content-length}\n' -I http://127.0.0.1:19351/customers
  405 application/json · Allow:  · Content-Length: 30
  WARN lines it added: 0
$ curl -s -o /dev/null -w '%{http_code} %{content_type} · Allow: %header{allow} · Content-Length: %header{content-length}\n' -X OPTIONS http://127.0.0.1:19351/customers
  405 application/json · Allow:  · Content-Length: 30
  WARN lines it added: 0
$ curl -s -o /dev/null -w '%{http_code} %{content_type} · Allow: %header{allow} · Content-Length: %header{content-length}\n' -X DELETE http://127.0.0.1:19351/customers
  405 application/json · Allow:  · Content-Length: 30
  WARN lines it added: 0
$ curl -s -o /dev/null -w '%{http_code} %{content_type} · Allow: %header{allow} · Content-Length: %header{content-length}\n' http://127.0.0.1:19351/shutdown
  405 application/json · Allow:  · Content-Length: 30
  WARN lines it added: 0
$ curl -s -o /dev/null -w '%{http_code} %{content_type} · Allow: %header{allow} · Content-Length: %header{content-length}\n' -X POST http://127.0.0.1:19351/shutdown
  403 application/json · Allow:  · Content-Length: 21
  WARN lines it added: 0
$ curl -s -o /dev/null -w '%{http_code} %{content_type} · Allow: %header{allow} · Content-Length: %header{content-length}\n' -H 'Accept: application/xml' http://127.0.0.1:19351/customers
  200 application/json · Allow:  · Content-Length: 282
  WARN lines it added: 0
$ curl -s -o /dev/null -w '%{http_code} %{content_type} · Allow: %header{allow} · Content-Length: %header{content-length}\n' http://127.0.0.1:19351/customers
  200 application/json · Allow:  · Content-Length: 282
  WARN lines it added: 0
  these answers, one line each (the request -> status, type, Allow, Content-Length · the WARN lines it added):
    HEAD /customers           -> 405 application/json · Allow: none · Content-Length: 30 · WARN lines: 0
    OPTIONS /customers        -> 405 application/json · Allow: none · Content-Length: 30 · WARN lines: 0
    DELETE /customers         -> 405 application/json · Allow: none · Content-Length: 30 · WARN lines: 0
    GET /shutdown             -> 405 application/json · Allow: none · Content-Length: 30 · WARN lines: 0
    POST /shutdown, no token  -> 403 application/json · Allow: none · Content-Length: 21 · WARN lines: 0
    GET /customers, XML only  -> 200 application/json · Allow: none · Content-Length: 282 · WARN lines: 0
    GET /customers            -> 200 application/json · Allow: none · Content-Length: 282 · WARN lines: 0
  WARN lines in this run's log, at Boot's default level: 0
$ harness/shutdown.sh 19351 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19351 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
after - after/, the same line, port 19350:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19350
  listens on: 127.0.0.1:19350 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19350/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19350 (http) with context path '/'
$ curl -s -o /dev/null -w '%{http_code} %{content_type} · Allow: %header{allow} · Content-Length: %header{content-length}\n' -I http://127.0.0.1:19350/customers
  200 application/json · Allow:  · Content-Length: 282
  WARN lines it added: 0
$ curl -s -o /dev/null -w '%{http_code} %{content_type} · Allow: %header{allow} · Content-Length: %header{content-length}\n' -X OPTIONS http://127.0.0.1:19350/customers
  200  · Allow: GET,HEAD,OPTIONS · Content-Length: 0
  WARN lines it added: 0
$ curl -s -o /dev/null -w '%{http_code} %{content_type} · Allow: %header{allow} · Content-Length: %header{content-length}\n' -X DELETE http://127.0.0.1:19350/customers
  405 application/json · Allow: GET · Content-Length: 
  WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpRequestMethodNotSupportedException: Request method 'DELETE' is not supported]
$ curl -s -o /dev/null -w '%{http_code} %{content_type} · Allow: %header{allow} · Content-Length: %header{content-length}\n' http://127.0.0.1:19350/shutdown
  405 application/json · Allow: POST · Content-Length: 
  WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpRequestMethodNotSupportedException: Request method 'GET' is not supported]
$ curl -s -o /dev/null -w '%{http_code} %{content_type} · Allow: %header{allow} · Content-Length: %header{content-length}\n' -X POST http://127.0.0.1:19350/shutdown
  403 application/json · Allow:  · Content-Length: 21
  WARN lines it added: 0
$ curl -s -o /dev/null -w '%{http_code} %{content_type} · Allow: %header{allow} · Content-Length: %header{content-length}\n' -H 'Accept: application/xml' http://127.0.0.1:19350/customers
  406  · Allow:  · Content-Length: 0
  WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation]
$ curl -s -o /dev/null -w '%{http_code} %{content_type} · Allow: %header{allow} · Content-Length: %header{content-length}\n' http://127.0.0.1:19350/customers
  200 application/json · Allow:  · Content-Length: 282
  WARN lines it added: 0
  these answers, one line each (the request -> status, type, Allow, Content-Length · the WARN lines it added):
    HEAD /customers           -> 200 application/json · Allow: none · Content-Length: 282 · WARN lines: 0
    OPTIONS /customers        -> 200 (no type) · Allow: GET,HEAD,OPTIONS · Content-Length: 0 · WARN lines: 0
    DELETE /customers         -> 405 application/json · Allow: GET · Content-Length: none · WARN lines: 1
    GET /shutdown             -> 405 application/json · Allow: POST · Content-Length: none · WARN lines: 1
    POST /shutdown, no token  -> 403 application/json · Allow: none · Content-Length: 21 · WARN lines: 0
    GET /customers, XML only  -> 406 (no type) · Allow: none · Content-Length: 0 · WARN lines: 1
    GET /customers            -> 200 application/json · Allow: none · Content-Length: 282 · WARN lines: 0
  WARN lines in this run's log, at Boot's default level: 3
$ harness/shutdown.sh 19350 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19350 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 5 · seven — the comparison set, before and after (⚑15, R.80)

Before (the previous tree) `571faaea…`; after `87ca7efc8584dcccd40e6b956db1de9b` — masked, the mask changing two lines now. One line
differs, `6c6`, GET /shutdown: TiffinBox's own `{"error":"method not allowed"}` → Spring's
`{"timestamp":"…","status":405,"error":"Method Not Allowed","path":"/shutdown"}`. The status line and header names of GET /customers, which
the seven do not print, are the same on both (S2.10). The seven log 0 WARN lines before and **1** after, GET /shutdown's. **Why**, C
(labelled): after/ on the class-path line with the harness's `Converters` joined and Boot's `web` group at DEBUG — the JSON converter
(`JacksonJsonHttpMessageConverter`, Jackson 3's `JsonMapper`), then every line of GET /customers (`Mapped to
com.tiffinbox.web.TiffinBoxServer#customers()`, `Using 'application/json'`, `Writing [[Customer[…`) and of GET /shutdown (the WARN,
`Completed 405`, the ERROR dispatch to Boot's `BasicErrorController#error`, `HttpEntityMethodProcessor` writing the map).

`.r-seven.out` · md5 `a85e6e5b349bcddc50bf6caba79b35fb` · 3 of 3

```
before - the previous tree, the README's run line, port 19351:
$ cd .harness/before && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19351
  listens on: 127.0.0.1:19351 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19351/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D - -o /dev/null http://127.0.0.1:19351/customers
  its status line: [HTTP/1.1 200 ] · its headers, by name: Content-Type Content-Length Date
$ $CURLSET 19351 .harness/before/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 1 · md5 571faaea42e87e85add8c9548c64c961
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  its WARN lines, at Boot's default level: 0
after - after/, the same line, port 19350:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19350
  listens on: 127.0.0.1:19350 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19350/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19350 (http) with context path '/'
$ curl -s -D - -o /dev/null http://127.0.0.1:19350/customers
  its status line: [HTTP/1.1 200 ] · its headers, by name: Content-Type Content-Length Date
$ $CURLSET 19350 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  its WARN lines, at Boot's default level: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpRequestMethodNotSupportedException: Request method 'GET' is not supported]
  the seven, the timestamp masked:
    GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
    GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
    GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
    GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
    GET   /nowhere    -> 404 application/json  {"timestamp":"…","status":404,"error":"Not Found","path":"/nowhere"}
    GET   /shutdown   -> 405 application/json  {"timestamp":"…","status":405,"error":"Method Not Allowed","path":"/shutdown"}
    POST  /shutdown   -> 200 application/json  {"stopping":true}
before against after, the lines that differ (diff):
  6c6
  < GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  ---
  > GET   /shutdown   -> 405 application/json  {"timestamp":"…","status":405,"error":"Method Not Allowed","path":"/shutdown"}
C (labelled) - why: after/ on the README's class-path line with the harness's Converters joined, Boot's web log group at DEBUG (the README's option), port 19352 - Spring MVC's JSON converters, then GET /customers and GET /shutdown, each alone:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19352 --spring.main.sources=probe.web.Converters --logging.level.web=debug
  listens on: 127.0.0.1:19352 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19352/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19352/probe/converters
  converters: 6 · for application/json: 1
  org.springframework.http.converter.json.JacksonJsonHttpMessageConverter · its mapper: tools.jackson.databind.json.JsonMapper
  the DEBUG lines before it - the start, the readiness polls (their number moves), /probe/converters: more than 20, not shown
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19352/customers
  200 application/json
  its lines at DEBUG, WARN and ERROR - all 5 of them:
    DEBUG o.s.web.servlet.DispatcherServlet: GET "/customers", parameters={}
    DEBUG s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to com.tiffinbox.web.TiffinBoxServer#customers()
    DEBUG m.m.a.RequestResponseBodyMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
    DEBUG m.m.a.RequestResponseBodyMethodProcessor: Writing [[Customer[name=Meera, mealsPerDay=1, pricePerMeal=150, mealType=NON_VEG], Customer[name=Priya, meals (truncated)...]
    DEBUG o.s.web.servlet.DispatcherServlet: Completed 200 OK
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19352/shutdown
  405 application/json
  its lines at DEBUG, WARN and ERROR - all 8 of them:
    DEBUG o.s.web.servlet.DispatcherServlet: GET "/shutdown", parameters={}
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpRequestMethodNotSupportedException: Request method 'GET' is not supported]
    DEBUG o.s.web.servlet.DispatcherServlet: Completed 405 METHOD_NOT_ALLOWED
    DEBUG o.s.web.servlet.DispatcherServlet: "ERROR" dispatch for GET "/error", parameters={}
    DEBUG s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to org.springframework.boot.webmvc.autoconfigure.error.BasicErrorController#error(HttpServletRequest)
    DEBUG o.s.w.s.m.m.a.HttpEntityMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
    DEBUG o.s.w.s.m.m.a.HttpEntityMethodProcessor: Writing [{timestamp=…, status=405, error=Method Not Allowed, path=/shutdown}]
    DEBUG o.s.web.servlet.DispatcherServlet: Exiting from "ERROR" dispatch, status 405
$ harness/shutdown.sh 19352 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19352 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 6 · json — who writes the answers, by taking a class away (C6-5's first half)

The anchor README's missing-class lines (Course 5's, which delete Jackson 2's `JDK14Util` from a copy of the extracted jar): on the
previous tree `/customers` answers TiffinBox's own `{"error":"ClassNotFoundException"} 500` — Jackson 2 wrote it; on after/ the same lines
leave `/customers` at 200 — Jackson 2 is no longer on its road. C (labelled): Jackson 3's `RecordUtil` deleted instead (this unit's
line) — Boot's 500 body, and Tomcat's ERROR line `Servlet.service() … threw exception [Handler dispatch failed:
java.lang.NoClassDefFoundError: tools/jackson/databind/util/RecordUtil] with root cause`, its trace bounded; `/kitchen`, a map, answers
200 all three times.

`.r-json.out` · md5 `f4b6186bf543ce5e90bd6cd11a5f9c68` · 3 of 3

```
before - the previous tree: the README's lines for a class the answer needs, deleted - Jackson 2's JDK14Util out of a copy of the extracted jar's lib/ - port 19351:
$ cd .harness/before && rm -rf tiffinbox-web/target/hang && mkdir tiffinbox-web/target/hang && cp tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar tiffinbox-web/target/hang/ && cp -R tiffinbox-web/target/extracted/lib tiffinbox-web/target/hang/lib
  exit 0
$ cd .harness/before && zip -q -d tiffinbox-web/target/hang/lib/jackson-databind-2.22.2.jar 'com/fasterxml/jackson/databind/jdk14/JDK14Util*'
  exit 0
$ cd .harness/before && java -jar tiffinbox-web/target/hang/tiffinbox-web-1.0.0.jar --tiffinbox.port=19351 --logging.level.kitchen=debug
  listens on: 127.0.0.1:19351 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19351/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -m 5 -w ' %{http_code}\n' http://127.0.0.1:19351/customers
  {"error":"ClassNotFoundException"} 500
$ curl -s -m 5 -w ' %{http_code}\n' http://127.0.0.1:19351/kitchen
  {"ordersCooked":120,"ordersValue":24300} 200
  its lines at WARN and ERROR since readiness: 1
    ERROR tiffinbox: GET /customers failed
  TiffinBox's own lines for an answer (logger tiffinbox, at DEBUG): GET /customers failed · GET /customers -> 500 · GET /kitchen -> 200
  stack frames in its log: over 50, not shown · its exceptions' first lines:
    java.lang.NoClassDefFoundError: com/fasterxml/jackson/databind/jdk14/JDK14Util
    Caused by: java.lang.ClassNotFoundException: com.fasterxml.jackson.databind.jdk14.JDK14Util
$ harness/shutdown.sh 19351 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19351 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
after - after/, the same lines, port 19355:
$ cd .harness/after && rm -rf tiffinbox-web/target/hang && mkdir tiffinbox-web/target/hang && cp tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar tiffinbox-web/target/hang/ && cp -R tiffinbox-web/target/extracted/lib tiffinbox-web/target/hang/lib
  exit 0
$ cd .harness/after && zip -q -d tiffinbox-web/target/hang/lib/jackson-databind-2.22.2.jar 'com/fasterxml/jackson/databind/jdk14/JDK14Util*'
  exit 0
$ cd .harness/after && java -jar tiffinbox-web/target/hang/tiffinbox-web-1.0.0.jar --tiffinbox.port=19355 --logging.level.kitchen=debug
  listens on: 127.0.0.1:19355 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19355/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -m 5 -w ' %{http_code}\n' http://127.0.0.1:19355/customers
  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200
$ curl -s -m 5 -w ' %{http_code}\n' http://127.0.0.1:19355/kitchen
  {"ordersCooked":120,"ordersValue":24300} 200
  its lines at WARN and ERROR since readiness: 0
  TiffinBox's own lines for an answer (logger tiffinbox, at DEBUG): none
  stack frames in its log: 0
$ harness/shutdown.sh 19355 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19355 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - after/, a Jackson 3 class deleted instead (this unit's line), port 19355:
$ cd .harness/after && rm -rf tiffinbox-web/target/hang && mkdir tiffinbox-web/target/hang && cp tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar tiffinbox-web/target/hang/ && cp -R tiffinbox-web/target/extracted/lib tiffinbox-web/target/hang/lib
  exit 0
$ cd .harness/after && zip -q -d tiffinbox-web/target/hang/lib/jackson-databind-3.1.5.jar 'tools/jackson/databind/util/RecordUtil*'
  exit 0
$ cd .harness/after && java -jar tiffinbox-web/target/hang/tiffinbox-web-1.0.0.jar --tiffinbox.port=19355 --logging.level.kitchen=debug
  listens on: 127.0.0.1:19355 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19355/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -m 5 -w ' %{http_code}\n' http://127.0.0.1:19355/customers
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers"} 500
$ curl -s -m 5 -w ' %{http_code}\n' http://127.0.0.1:19355/kitchen
  {"ordersCooked":120,"ordersValue":24300} 200
  its lines at WARN and ERROR since readiness: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Handler dispatch failed: java.lang.NoClassDefFoundError: tools/jackson/databind/util/RecordUtil] with root cause
  TiffinBox's own lines for an answer (logger tiffinbox, at DEBUG): none
  stack frames in its log: over 50, not shown · its exceptions' first lines:
    java.lang.ClassNotFoundException: tools.jackson.databind.util.RecordUtil
$ harness/shutdown.sh 19355 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19355 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 7 · patterns — A/B/A′, then the literals (C6-3, C6-9, H1)

Boot's metadata: `spring.mvc.pathmatch.matching-strategy` default `path-pattern-parser`. **A** — after/ with the harness's
`MidPattern` (`/probe/kitchen/**/today`): exit 1, `APPLICATION FAILED TO START`, 0 frames, `Invalid mapping pattern detected:`, the
caret under `**`, `{*...} or ** pattern elements should be placed at the start or end of the pattern`, and Boot's action naming the
legacy parser; the port never bound. **B** — the same with the legacy parser by flag: the route answers 200, 0 WARN/ERROR lines (Boot's
own words, "the legacy parser"; nothing here says deprecated). **A′** = A. **The literals** — after/ with the harness's `Patterns`:
`/customersXYZ`, `/customers/`, `/customers.json`, `/CUSTOMERS` 404; `/customers;x=1` 200 (a path parameter is not part of the match);
`/probe/menu/today` → the literal route beside `/probe/menu/{day}`; `{*rest}` → `rest=/a/b/c.txt`; POST /shutdownXYZ, with the token,
404 — and `/customers` still 200 after it; 0 WARN lines for these requests.

`.r-patterns.out` · md5 `572218725a798f5fa9c2ff5be7c889b8` · 3 of 3

```
Boot's own metadata, in after/'s jar: spring.mvc.pathmatch.matching-strategy default path-pattern-parser (spring-boot-webmvc-4.1.1.jar)
A - after/ on the README's class-path line with the harness's MidPattern joined (a route on /probe/kitchen/**/today), port 19353:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19353 --spring.main.sources=probe.web.MidPattern
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0 · Boot's Tomcat lines 1
  WARN ConfigServletWebServerApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.BeanCreationException …
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  the hint Boot logs: Error starting ApplicationContext. To display the condition evaluation report re-run your application with 'debug' enabled.
  Description:
  Invalid mapping pattern detected:
  /probe/kitchen/**/today
                 ^
  {*...} or ** pattern elements should be placed at the start or end of the pattern
  Action:
  Fix this pattern in your application or switch to the legacy parser implementation with 'spring.mvc.pathmatch.matching-strategy=ant_path_matcher'.
  its log: the banner's :: Spring Boot :: line 1
  its standard error: 0 lines · the demo token in its log: 0
  listening now: 19353 0
B - the same with the legacy parser (this unit's option):
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19353 --spring.main.sources=probe.web.MidPattern --spring.mvc.pathmatch.matching-strategy=ant-path-matcher
  listens on: 127.0.0.1:19353 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19353/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19353/probe/kitchen/a/b/today
  200 text/plain;charset=UTF-8
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19353/probe/kitchen/today
  200 text/plain;charset=UTF-8
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19353/customers
  200 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19353/customers/
  404 application/json
  WARN and ERROR lines in its log, from the start: 0
$ harness/shutdown.sh 19353 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19353 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19353 --spring.main.sources=probe.web.MidPattern
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0 · Boot's Tomcat lines 1
  WARN ConfigServletWebServerApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.BeanCreationException …
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  the hint Boot logs: Error starting ApplicationContext. To display the condition evaluation report re-run your application with 'debug' enabled.
  Description:
  Invalid mapping pattern detected:
  /probe/kitchen/**/today
                 ^
  {*...} or ** pattern elements should be placed at the start or end of the pattern
  Action:
  Fix this pattern in your application or switch to the legacy parser implementation with 'spring.mvc.pathmatch.matching-strategy=ant_path_matcher'.
  its log: the banner's :: Spring Boot :: line 1
  its standard error: 0 lines · the demo token in its log: 0
  listening now: 19353 0
the literals - after/ on the class-path line with the harness's Patterns joined (/probe/menu/{day}, /probe/menu/today, /probe/files/{*rest}), the default parser, port 19352:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19352 --spring.main.sources=probe.web.Patterns
  listens on: 127.0.0.1:19352 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19352/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19352/customersXYZ
  404 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19352/customers/
  404 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19352/customers.json
  404 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19352/CUSTOMERS
  404 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' 'http://127.0.0.1:19352/customers;x=1'
  200 application/json
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19352/probe/menu/today
  the literal route: today
   200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19352/probe/menu/mon
  day=mon
   200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19352/probe/menu/mon/lunch
  {"timestamp":"…","status":404,"error":"Not Found","path":"/probe/menu/mon/lunch"} 404
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19352/probe/files/a/b/c.txt
  rest=/a/b/c.txt
   200
$ harness/shutdown.sh 19352 .harness/after/secrets/tiffinbox/shutdown-token /shutdownXYZ
  POST /shutdownXYZ -> 404 application/json · Content-Length: none · {"timestamp":"…","status":404,"error":"Not Found","path":"/shutdownXYZ"} · curl exit 0
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19352/customers
  200 application/json
  WARN lines these requests added, at Boot's default level: 0
$ harness/shutdown.sh 19352 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19352 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 8 · timers — who times and logs each answer (⚑5, H6)

The README's line with the kitchen at DEBUG, six requests on each tree (GET /customers, the same with `?mealType=VEG`,
`/customersXYZ`, DELETE, OPTIONS, and POST /shutdownXYZ with the token). Before: TiffinBox's own four lines (`GET /customers -> 200` ×2,
`UNKNOWN -> 405` ×2) and its timer's two series; Boot's timer files the 405s under `uri="/customers"` (the path mapping matched). After:
0 lines of the kitchen group's, no `tiffinbox_requests` at all; Boot's `uri="/customers"` 2 — with and without the query string, one
series — `uri="/**"` for both 404s, GET's and POST's (the ledger's C6-9, both trees: RED S2 #30), and `uri="UNKNOWN"` for the DELETE 405
and for OPTIONS 200: never "every series names a route". C (labelled): Boot's `web` group at DEBUG
prints the request line as the client typed it, `GET "/customers?mealType=VEG", parameters={masked}` — Course 5's "never what the client
typed" no longer holds at DEBUG.

`.r-timers.out` · md5 `0983a966052639867fe09f913850fcfe` · 3 of 3

```
before - the previous tree, the README's line with the kitchen at DEBUG, port 19351:
$ cd .harness/before && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19351 --logging.level.kitchen=debug
  listens on: 127.0.0.1:19351 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19351/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19351/customers
  200 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' 'http://127.0.0.1:19351/customers?mealType=VEG'
  200 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19351/customersXYZ
  404 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' -X DELETE http://127.0.0.1:19351/customers
  405 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' -X OPTIONS http://127.0.0.1:19351/customers
  405 application/json
$ harness/shutdown.sh 19351 .harness/before/secrets/tiffinbox/shutdown-token /shutdownXYZ
  POST /shutdownXYZ -> 404 application/json · Content-Length: none · {"timestamp":"…","status":404,"error":"Not Found","path":"/shutdownXYZ"} · curl exit 0
  TiffinBox's own lines for these answers (logger tiffinbox, at DEBUG): 4
    DEBUG tiffinbox: GET /customers -> 200
    DEBUG tiffinbox: GET /customers -> 200
    DEBUG tiffinbox: UNKNOWN -> 405
    DEBUG tiffinbox: UNKNOWN -> 405
  the scrape's count lines for both timers (Actuator's own series left out):
    http_server_requests_seconds_count{error="none",exception="none",method="DELETE",outcome="CLIENT_ERROR",status="405",uri="/customers"} 1
    http_server_requests_seconds_count{error="none",exception="none",method="GET",outcome="CLIENT_ERROR",status="404",uri="/**"} 1
    http_server_requests_seconds_count{error="none",exception="none",method="GET",outcome="SUCCESS",status="200",uri="/customers"} 2
    http_server_requests_seconds_count{error="none",exception="none",method="OPTIONS",outcome="CLIENT_ERROR",status="405",uri="/customers"} 1
    http_server_requests_seconds_count{error="none",exception="none",method="POST",outcome="CLIENT_ERROR",status="404",uri="/**"} 1
    tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 2
    tiffinbox_requests_seconds_count{route="UNKNOWN",status="405"} 2
  Actuator's own series, left out: fewer than 10 (the readiness polls and these reads move their counts)
  requests sent: 6 · counted by Boot's timer: 6 · by TiffinBox's: 4 · Boot's series: 5 · TiffinBox's: 2
$ harness/shutdown.sh 19351 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19351 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
after - after/, the same line, port 19350:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19350 --logging.level.kitchen=debug
  listens on: 127.0.0.1:19350 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19350/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19350/customers
  200 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' 'http://127.0.0.1:19350/customers?mealType=VEG'
  200 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19350/customersXYZ
  404 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' -X DELETE http://127.0.0.1:19350/customers
  405 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' -X OPTIONS http://127.0.0.1:19350/customers
  200 
$ harness/shutdown.sh 19350 .harness/after/secrets/tiffinbox/shutdown-token /shutdownXYZ
  POST /shutdownXYZ -> 404 application/json · Content-Length: none · {"timestamp":"…","status":404,"error":"Not Found","path":"/shutdownXYZ"} · curl exit 0
  TiffinBox's own lines for these answers (logger tiffinbox, at DEBUG): 0 · any DEBUG line of the kitchen group's loggers (tiffinbox, com.tiffinbox…): 0
  the scrape's count lines for both timers (Actuator's own series left out):
    http_server_requests_seconds_count{error="none",exception="none",method="DELETE",outcome="CLIENT_ERROR",status="405",uri="UNKNOWN"} 1
    http_server_requests_seconds_count{error="none",exception="none",method="GET",outcome="CLIENT_ERROR",status="404",uri="/**"} 1
    http_server_requests_seconds_count{error="none",exception="none",method="GET",outcome="SUCCESS",status="200",uri="/customers"} 2
    http_server_requests_seconds_count{error="none",exception="none",method="OPTIONS",outcome="SUCCESS",status="200",uri="UNKNOWN"} 1
    http_server_requests_seconds_count{error="none",exception="none",method="POST",outcome="CLIENT_ERROR",status="404",uri="/**"} 1
  Actuator's own series, left out: fewer than 10 (the readiness polls and these reads move their counts)
  requests sent: 6 · counted by Boot's timer: 6 · by TiffinBox's: 0 · Boot's series: 5 · TiffinBox's: 0
$ harness/shutdown.sh 19350 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19350 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - after/, Boot's web log group at DEBUG (the README's line), port 19350 - one request with a query string:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19350 --logging.level.web=debug
  listens on: 127.0.0.1:19350 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19350/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' 'http://127.0.0.1:19350/customers?mealType=VEG'
  200 application/json
  the DispatcherServlet's line for it (level logger: message): DEBUG o.s.web.servlet.DispatcherServlet: GET "/customers?mealType=VEG", parameters={masked}
  its other DEBUG lines: 4, not shown
$ harness/shutdown.sh 19350 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19350 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 9 · stop — POST /shutdown, a controller method (⚑6; A/B/A′)

Boot's metadata: `server.shutdown` default `graceful`. The README's run line — one request, then POST /shutdown with the token:
`200 application/json · Content-Length: 17 · {"stopping":true}`, exit 0, Boot's two graceful lines: the method starts a platform thread
that closes the application context, and returns the answer. Then A/B/A′ with the answer **held in flight** — the harness's `SlowAfter`
keeps POST /shutdown's own thread 2 s after the method returned, so the server is told to stop while the answer is still on its way:
A, Boot's default (graceful: Tomcat waits for requests in flight, this one too) → the answer, 2 graceful lines; B,
`--server.shutdown=immediate` → **no answer at all** (`000`, curl exit 52: an empty reply), 0 graceful lines; A′ = A; exit 0 each time.
**Graceful shutdown is what guarantees the reply** (RED S2 #2): without the hold, an immediate shutdown answers only when the answer
is faster than the close — a race, which RED's run lost once on a busy machine, so no capture rests on it (brief ⚑6, amended).

`.r-stop.out` · md5 `ab0b487fedc21a6a6f9110e8a97f5e2b` · 3 of 3

```
Boot's own metadata, in after/'s jar: server.shutdown default graceful (spring-boot-web-server-4.1.1.jar)
the README's run line, Boot's default, port 19356 - one request, then POST /shutdown:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19356
  listens on: 127.0.0.1:19356 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19356/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19356/customers
  200 application/json
$ harness/shutdown.sh 19356 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19356 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  Boot's graceful-shutdown lines in its log: 2
A - the answer held in flight, Boot's default: after/ on the README's class-path line with the harness's SlowAfter joined (POST /shutdown's thread waits 2 s after the method returned), port 19356:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19356 --spring.main.sources=probe.web.SlowAfter
  listens on: 127.0.0.1:19356 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19356/actuator/health/readiness
  {"status":"UP"} 200
$ harness/shutdown.sh 19356 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19356 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  Boot's graceful-shutdown lines in its log: 2
B - the same, Boot's shutdown made immediate (this unit's option):
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19356 --spring.main.sources=probe.web.SlowAfter --server.shutdown=immediate
  listens on: 127.0.0.1:19356 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19356/actuator/health/readiness
  {"status":"UP"} 200
$ harness/shutdown.sh 19356 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 000 (no type) · Content-Length: none ·  · curl exit 52
  exit 0 · listening on 19356 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  Boot's graceful-shutdown lines in its log: 0
A' - A again:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19356 --spring.main.sources=probe.web.SlowAfter
  listens on: 127.0.0.1:19356 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19356/actuator/health/readiness
  {"status":"UP"} 200
$ harness/shutdown.sh 19356 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19356 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  Boot's graceful-shutdown lines in its log: 2
```

## 10 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s commands, then `exercise/solution/SOLUTION.md`'s, read from the files and run as written, one after the other in
ONE shell a viewer could have — `env -i` (HOME, and the PATH the script was started with), `/bin/bash --noprofile --norc`, started in
this folder: as shipped `status: 405 · Allow: GET · customers: 0`, then the solution `status: 200 · Allow: none · customers: 4`, the shell
in this unit's folder after each, the copy's own token 0 times in its log.

`.r-exercise.out` · md5 `31ed311e266aebcca69f6c746241937b` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 7 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
  $ mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package)
  $ (cd .harness/mine/after && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19359 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19359/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s -X DELETE -D ../head.txt -o ../body.txt http://127.0.0.1:19359/customers; ../../../harness/shutdown.sh 19359 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && a=$(tr -d '\r' < ../head.txt | sed -n 's/^Allow: //p') && echo "status: $(sed -n '1s/^HTTP\/1\.1 \([0-9]*\).*/\1/p' ../head.txt) · Allow: ${a:-none} · customers: $(grep -o '"name"' ../body.txt | wc -l | tr -d ' ')")
  exit 0 · what they printed:
    status: 405 · Allow: GET · customers: 0
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times
the solution's 3 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ (cd .harness/mine/after && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19359 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19359/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s -D ../head.txt -o ../body.txt http://127.0.0.1:19359/customers; ../../../harness/shutdown.sh 19359 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && a=$(tr -d '\r' < ../head.txt | sed -n 's/^Allow: //p') && echo "status: $(sed -n '1s/^HTTP\/1\.1 \([0-9]*\).*/\1/p' ../head.txt) · Allow: ${a:-none} · customers: $(grep -o '"name"' ../body.txt | wc -l | tr -d ' ')")
  exit 0 · what they printed:
    status: 200 · Allow: none · customers: 4
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · listening on 19359 now: 0
```

## 11 · forms — every form still serves (⚑16, R.40, S2.20)

`after/`'s native build (the README's two Maven lines, offline: 8 of 8 stages, Mach-O, 0 token bytes, 0 download lines), with no
`@RegisterReflectionForBinding` code line in the sources; Spring's generated `reachability-metadata.json` names `com.tiffinbox.Customer`
— all its declared fields and constructors, its four accessors — read from the routes' signatures (RE-MEASURE 2); C (labelled), a copy
whose `customers()` returns `Object`: 0 entries. Then **1** the jar, **2** the AOT jar, **3** the binary — and the binary at DEBUG:
`tomcat-handler-N Mapped to com.tiffinbox.web.TiffinBoxServer#customers()` — **4** the image (built here from after/'s Dockerfile, its
layers searched: 0 tokens; published on `127.0.0.1:19357` alone): each the seven `87ca7efc…`, each exit 0; loopback counted form by form.

`.r-forms.out` · md5 `db1de714de65d90e821c93f54aeecc2a` · 3 of 3

```
the native build - after/ copied to .harness/nat with a config tree; the README's two Maven lines, offline; $GRAALVM_HOME names the GraalVM:
$ cd .harness/nat && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean install
  built .harness/nat (both modules, into $M2) · offline: yes · exit 0
$ cd .harness/nat && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -pl tiffinbox-web native:compile-no-fork
  its lines, in order (the rest - 203 lines - not shown):
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
  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes
  file: Mach-O 64-bit executable · the demo token in its bytes: 0
what Spring's AOT step registered for the native build - the record the routes return, with no hint in the tree (code lines naming @RegisterReflectionForBinding in its Java sources: 0):
  Spring's generated metadata (spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json): reflection entries naming com.tiffinbox.Customer: 1 - all declared fields · all declared constructors · 4 methods (mealType mealsPerDay name pricePerMeal)
  C (labelled) - a copy of after/ whose customers() returns Object (its one line changed), built with the profile native (the README's line) - Spring's AOT step only:
  $ diff -U0 after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java .harness/obj/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
    @@ -87 +87 @@
    -    List<Customer> customers() throws Exception {
    +    Object customers() throws Exception {
  $ cd .harness/obj && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean package
    built the copy, the profile native (Spring's AOT step) · offline: yes · exit 0
    Spring's generated metadata (spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json): reflection entries naming com.tiffinbox.Customer: 0
1 the jar - .harness/after, the README's run line, port 19350:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19350
  listens on: 127.0.0.1:19350 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19350/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19350 (http) with context path '/'
$ $CURLSET 19350 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  Boot's graceful-shutdown lines in its log: 2
2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19354:
$ cd .harness/nat && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19354
  listens on: 127.0.0.1:19354 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19354/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19354 (http) with context path '/'
$ $CURLSET 19354 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  Boot's graceful-shutdown lines in its log: 2
3 the binary - .harness/nat, the README's line, port 19358:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19358
  listens on: 127.0.0.1:19358 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19358/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19358 (http) with context path '/'
$ $CURLSET 19358 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  Boot's graceful-shutdown lines in its log: 2
  the binary at DEBUG - the README's line with Boot's web group and the kitchen at DEBUG, each line its thread's whole name and the message, port 19358:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19358 --logging.level.web=debug --logging.level.kitchen=debug --logging.pattern.console='%thread %msg%n'
  listens on: 127.0.0.1:19358 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19358/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19358/customers
  200 application/json
  its line for GET /customers that names the handler: tomcat-handler-N Mapped to com.tiffinbox.web.TiffinBoxServer#customers() · its other lines - the start, the readiness polls (their number moves), the rest of this request: more than 40, not shown
$ harness/shutdown.sh 19358 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19358 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19357:
$ cd .harness/after && docker build --progress=plain -t tiffinbox-mvc:1.0.0 .
  exit 0 · its lines, through the filter:
    [internal] load metadata for docker.io/library/eclipse-temurin:25-jre
    [builder 1/4] FROM docker.io/library/eclipse-temurin:25-jre@sha256:fcd7fd7b387f94bb2ac461478a7436ad8e349924c374ea8313919624dceae636
    naming to docker.io/library/tiffinbox-mvc:1.0.0
  its lines that say pull: 0 · its other lines: fewer than 300, not shown
  the image saved (docker save): 15 blobs, its 11 layers among them, each read whole (gzip ones unpacked) · the demo token in them: 0
$ cd .harness/after && docker run -d --name tiffinbox-mvc --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19357:18425 tiffinbox-mvc:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19357/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19357
  on this Mac, listening on port 19357: 127.0.0.1:19357
$ $CURLSET 19357 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
$ docker wait tiffinbox-mvc
  0
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  its log (docker logs): Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1 · the demo token 0 times · X-Shutdown-Token 0 times
  Boot's graceful-shutdown lines in its log: 2
four forms, one tree: the seven (masked) 4 of 4 times 87ca7efc8584dcccd40e6b956db1de9b
  loopback, form by form: the jar yes · the AOT jar yes · the binary yes (its DEBUG run among them) · the image, published on 127.0.0.1 alone yes
```

## Exercise

**Your turn:** the README's request gets a 405. Read the Allow header, change the verb, and count the customers. `exercise/README.md`
has the commands (copy `after/` with a token of its own, build the jar offline); its last line, in a subshell, starts TiffinBox on
19359, sends `curl -s -X DELETE … /customers`, stops TiffinBox and prints — as shipped — `status: 405 · Allow: GET · customers: 0`.
Done is `status: 200 · Allow: none · customers: 4`. Measured answer: `exercise/solution/SOLUTION.md` (the README's two `export` lines,
then the same line without `-X DELETE`), run in the same shell. Run `./receipts.sh` once first on a fresh clone.

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-14) |
|---|---|---|---|
| 1 | the seven's masked md5 on 06's own tree | `87ca7efc…` on the probe's sketches | **`87ca7efc8584dcccd40e6b956db1de9b`** — the jar, the AOT jar, the binary and the image (`seven`, `forms`) |
| 2 | the binary without `@RegisterReflectionForBinding`, precise types | the chain-end binary only | **the seven in this tree's binary, `/customers` 200**; the generated metadata names `Customer` (1), a copy returning `Object` none (0) (`forms`) |
| 3 | the shutdown reply from a controller method; the seven's WARN count | the probe's 6/6 (+3/3 immediate); 1 WARN | **the README's line: the answer, `Content-Length: 17`, exit 0; the answer held in flight: A graceful → the answer, B immediate → none (curl exit 52), A′ = A** (`stop`, 3 runs × 4; BLUE, after RED S2 #2); **the seven log 1 WARN**, GET /shutdown's (`seven`) |
| 4 | the legacy-parser break's lines on 06's tree | a harness on the chain end | **A/A′ exit 1, 0 frames, the caret under `**`, the rule, Boot's action; B 200, 0 WARN** (`patterns`) |
| 15 | the image of every chain unit | once, on the chain end | **built from after/'s Dockerfile, 0 pulls, its layers 0 tokens, `127.0.0.1:19357` alone, the seven `87ca7efc…`, `docker wait` 0** (`forms`) |
| 16 | the exercise as viewers run it | end state on a sketch | **one `env -i` shell: `status: 405 · Allow: GET · customers: 0`, then `status: 200 · Allow: none · customers: 4`** (`exercise`) |

## Found on the way

- **Every new check fails on a planted fault first** (R.65): the checks block run on copies of the captures, one line changed per
  plant — the router's lines 10 → 1; `@Controller no`; a `@GetMapping` hunk line gone; `6 mappings`; a `route` line of TiffinBox's
  altered; `naming a verb: 4`; HEAD answering 405 after; the 406 with 0 WARN lines; `5c5`; the seven with 2 WARN lines; Jackson 2's
  class out answering 500; B with a WARN line; POST /shutdownXYZ answering 200; OPTIONS under `uri="/customers"`; B (immediate) with
  graceful lines; the exercise's 3 customers; the `Object` copy with Customer registered; 3 of 4 forms — **18 plants, 18 stops**, each
  naming its check. SOLUTION.md without its `JAVA_HOME` line, and with another JDK's: both refused. **BLUE A's checks, the same way**
  (2026-10-14): the web POM no longer differing; a router line left in it; the old description; ten files the same; `after/`'s web POM
  naming the router (S2.22, the POMs too); POST /shutdownXYZ timed under `UNKNOWN`; one request uncounted; `stop` B answering; A without
  the harness's hold; the README's line without its graceful lines; a duration back in `forms`' hashed line — **11 plants, 11 stops**.
- **A semicolon in an `eval`'d URL ends the command.** The first `patterns` run printed `/customers;x=1 → 200` while curl had asked for
  `/customers` alone — the shell ran `x=1` as a second command. Every URL holding `;` or `?` is single-quoted now (`qurl`), and the
  printed command is the one that ran: `'http://127.0.0.1:19352/customers;x=1'`, still 200.
- **Java prints `?` for `·` under `LC_ALL=C`**: `System.out` encodes for the locale, and C's is ASCII. The harness's `Stereotype` writes
  through a UTF-8 `PrintStream` (its first run printed `@RestController no ? @Controller no ? …`).
- **`awk -v` turns `\n` into a newline.** The checks that compare a printed curl line (its `-w '…\n'`) pass the line through awk's
  environment (`aft`), which keeps a backslash a backslash.
- **A 404 logs no WARN line.** The brief's "every 4xx `DefaultHandlerExceptionResolver` resolves logs one" holds here for the 405s
  and the 406, measured; the static-resource 404s (`/customersXYZ` and the rest, POST /shutdownXYZ) add 0 WARN lines (`patterns`),
  and so does the 403, which is TiffinBox's own (`verbs`).
- **HEAD on the previous tree logs nothing either.** Course 5's finale measured a WARN per HEAD on the JDK's server; on Tomcat,
  TiffinBox's own handler answered HEAD 405 with 0 WARN lines (`verbs` before). Spring MVC's HEAD is 200, still 0.
- **The previous tree's 405s were timed under `uri="/customers"`** (Boot's timer: the path mapping matched, the handler refused
  the verb); after/'s are `uri="UNKNOWN"`, with OPTIONS (`timers`).
- **The order of the routes Spring MVC registers moves between runs** — the probe's run listed `revenue` first, this tree's
  `dashboard` — so each TRACE block's routes are sorted, and said to be; TiffinBox's own `route …` lines likewise.
- **The checks' own text matched the check.** S2.13's refusal of Boot 3's error keys found its own message in `receipts.sh`; it now
  names the keys without spelling them. Then this very note, which spelled them, tripped it in `README.md` (RED S2 #1): it spells them
  no more.
- **The seed**: the previous unit's `.m2-demo`, its `com/tiffinbox` left out, adds nothing to `_research/m2-seed-s2/` (`diff -rq`
  of the union against the seed: 0 differences, 5,837 files) — and the brief seeds from the seed alone, so BLUE re-seeded it that way
  (RED S2 #25).
- **The image is built in `forms`** (this unit has no `bind`): its presence is never assumed, so a partial run cannot ask Docker Hub
  for it.
- **The image builder is named by its argument file.** The first interrupt test waited for `NativeImageGeneratorRunner` on a command
  line in the receipts' process group and never saw it — native-image starts its builder JVM with an `@…vminvocation.args` file, so
  the class name is on no command line — and the run went past its first native build; it was stopped by SIGINT to its group during
  the AOT jar's form instead (the group emptied, the lock removed, every port free, no container). The test now waits for
  `vminvocation`, and its 5-second check counted its own `grep` once ("the image builder anywhere 1"); counted again with a pattern
  that cannot match itself: 0.

## For unit 07 — and RED

- **Start from `../c6-unit06/after`** (= `../c6-tiffinbox`): `TiffinBoxServer` is a `final` `@RestController` (never `@Validated` on it:
  brief S2.19) with five request mappings — `@GetMapping` `/customers` (`List<Customer>`), `/revenue`, `/dashboard`, `/kitchen`
  (`Map<String, Object>`), `@PostMapping("/shutdown")` (`Map<String, Object> shutdown(HttpServletRequest, HttpServletResponse)`: no
  token → `response.setStatus(403)`, `{"error":"forbidden"}`; the token → `Thread.ofPlatform().start(context::close)`, `{"stopping":true}`).
  `holdsToken(HttpServletRequest)` still reads `X-Shutdown-Token` from the servlet request: unit 07 moves it to `@RequestHeader`
  (⚑6). Constructor: `CustomerRepository, Dashboard, OrderQueue, TiffinBoxProperties, ConfigurableApplicationContext` — no
  `MeterRegistry` now. Return types stay precise (S2.15): a new route that returns a record names its type.
- **The comparison set is `87ca7efc8584dcccd40e6b956db1de9b`** (masked, `tsmask`: two lines change, `/nowhere`'s and GET /shutdown's
  timestamps); `571faaea…` is the previous tree's. **Run the seven first, on a fresh JVM** (S2.11). The seven log **1 WARN line** at the
  default level (GET /shutdown's, Spring MVC's `DefaultHandlerExceptionResolver`).
- **WARN lines at INFO, measured here:** one per 405 (`HttpRequestMethodNotSupportedException`) and per 406
  (`HttpMediaTypeNotAcceptableException`); none for HEAD, OPTIONS, the 403, or a 404 (`NoResourceFoundException` logs none: `patterns`).
- **The table:** 14 dispatcherServlet rows; TiffinBox's 5 sorted among Actuator's and `/error`'s (all RequestMappingInfo rows now —
  `harness/table.py` sorts the run). At TRACE, TiffinBox's block is `c.t.w.TiffinBoxServer:`; the routes inside a block move order: sort.
  `7 mappings in 'requestMappingHandlerMapping'` (5 + 2) — adding `/customers/{name}` makes it 8.
- **Timers:** `tiffinbox_requests` is gone; Boot's `uri` tag is the mapping's pattern — `UNKNOWN` for 405s and OPTIONS, `/**` for 404s.
  The `kitchen` group logs nothing per request; Boot's `web` group at DEBUG prints `GET "/customers?mealType=VEG", parameters={masked}`.
- **Native:** no hint in the tree; Spring's AOT step registers `Customer` from the signatures (`reachability-metadata.json` under
  `tiffinbox-web/target/spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/`). 160-335 s a build in this unit's runs (load averages up to 58),
  under the 20-minute bound — the seconds and the bound go to the terminal, never into a hashed line (RED S2 #11). The image: `tiffinbox-mvc:1.0.0` is this unit's name — take your own.
- **Jackson:** two in the jar still (58 libraries): Spring MVC's converter writes every TiffinBox answer with Jackson 3; Jackson 2 writes
  none (`json`) — unit 08 takes it out (⚑7).
- **Harness on the class path:** `javac -parameters` (S2.16); a URL with `;` or `?` is single-quoted in `eval`'d commands (it ran
  `/customers` alone before the quoting: "Found on the way").
- **Not done here:** `@PathVariable`, `@RequestParam`, `@RequestHeader` (07); request bodies (08); Jackson's configuration (09);
  `ResponseEntity` (10).

## Dated note — 2026-10-14, after RED S2 (BLUE A)

- **The token at TRACE (RED S2 #3).** `after/README.md`'s Course 5 note "At TRACE, still no token", with this unit's addition "this run
  is not re-measured on this tree", is false here: Tomcat's `org.apache.coyote.http11.Http11InputBuffer` prints each request it received,
  the `X-Shutdown-Token` header and its value among the lines, when its logger is at TRACE (Boot's log labels the record DEBUG) — since
  the embedded-Tomcat lesson. RED measured the token once in such a log on this tree (`--logging.level.root=trace`, a fake token of its
  own, the seven; the seven still `87ca7efc…`). This tree's `POST /shutdown` reads the header off the servlet request, so Spring MVC's
  `HandlerMethod` prints no token here; the binding lesson's `@RequestHeader` adds that second copy, and the same lesson holds both
  loggers at INFO in `application.yaml`'s first document (`../c6-unit07/`, `trace`: 0 copies at `root=trace` and at `web=trace`).
  `after/` stays frozen — its line counts feed hashed captures — so the correction lives here. Never run this tree at TRACE with a real
  token.
- **Every endpoint exposed at once (RED S2 #22, #54).** `after/README.md`'s Course 5 note that exposing every endpoint stops the start on
  Jackson 2's `JavaTimeModule` (for `configprops`) has been false since the embedded-Tomcat lesson put Jackson 3 in the jar: with Jackson 3
  present configprops answers 200 (RED's measurement, on that lesson's tree and on the last course's with Jackson 3 added). The
  request-body lesson's anchor README carries the corrected note.
