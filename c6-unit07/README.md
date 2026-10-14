# c6-unit07 — @PathVariable, @RequestParam and Defaults

Course 6 · Spring Web MVC · Section 2 (Controllers and Binding), its second unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16,
Spring Boot 4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5 for Spring), **GraalVM CE 25.3.4.1** (native-image
25.0.4.1), **Docker on OrbStack**, 2026-10-14. Until this unit TiffinBox's routes took nothing from a request but its path:
`/customers?mealType=VEGAN` answered all four customers, and `/customers/Ravi` was Spring's 404. This unit gives the routes values
from the request as **method parameters**, each named by an annotation — a path variable, a request parameter, a header — and
measures who fills them (Spring MVC's argument resolvers, by name), what a missing or malformed value gets (Spring's 400 and a WARN
line, or TiffinBox's own answer), what the defaults do, what a parameter costs at TRACE, and which forms still serve.

**The anchor changes (brief ⚑2, ⚑6, ⚑8).** `after/` is this unit's frozen copy of `../c6-tiffinbox` after the change, and
`diff -rq -x target ../c6-tiffinbox after/` is empty. "Before" is `../c6-unit06/after` — the request-mapping lesson's frozen tree,
which `c6-tiffinbox` equalled at 997c0c8. Both trees are read and copied under `.harness/`, never built in place. The change:
`TiffinBoxServer.java` — **`GET /customers/{name}`**, new (`Customer customer(@PathVariable String name)`; a name nobody has throws
`ResponseStatusException` with 404), **`GET /customers`** takes `@RequestParam(required = false) MealType mealType` and keeps that meal
type's customers, and **POST /shutdown** takes its token as `@RequestHeader(name = "X-Shutdown-Token", required = false) String
token` where it read the servlet request's header itself (176 lines → 197); `tiffinbox-core`'s `CustomerRepository.java` —
**`findByName(String)`**, new (50 → 64); and the anchor's `README.md` (the unit section, and the six history notes the change made
false, each amended in place). The POMs, `application.yaml`, `spring.factories`, the Dockerfile, `compose.yaml`, the other five web
classes and the other six core classes are unchanged — 19 files byte for byte — and the jar holds the same 58 libraries (`change`).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 10 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) **Docker must
answer** (`docker info`; on OrbStack `orb start` is tried once if it does not), with `eclipse-temurin:25-jre` already on it: the
script never pulls. It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first). One native
build per `forms` run (three per receipt), judged against a bound (under 20 minutes); its seconds go to the terminal only. **Start it
in a process group of its own** (a terminal's foreground job is one): two receipts started as background jobs of one shell share a
group, and one run's clean-up would stop the other's JVMs (Section 1's finding, brief S2.4).

**Runs of record (2026-10-14, this script as committed):** **1,226 s under `./receipts.sh`** (/bin/bash 3.2.57, this folder, its own
process group, exit 0, all 10 = published, every check passed; the three native builds 204, 220 and 231 s) and **1,093 s under `bash
receipts.sh`** (Homebrew bash 5.3.9, the same; 187, 186 and 180 s). The first run under `./receipts.sh` (1,461 s; 232, 272 and 228 s) made
nine of the hashes — every capture 3/3 — and stopped at a check: `trace`'s Tomcat record held a carriage return ("Found on the way");
`trace`'s hash was made after the fix by a run of `change` and `trace` alone, the same script under /bin/bash 3.2, and every hash is
reproduced by each run of record. And **943 s from a sealed fresh clone under `./receipts.sh`** (/bin/bash 3.2.57): `git clone` of the
local repository (HEAD 997c0c8) with `c6-unit07` and `c6-tiffinbox` put in from the working tree as git would take them (60 files, 0
differences; the clone's status the same four lines as the repository's) — nothing git ignores: no `.m2-demo`, no `.harness/`, no `.r-*`
— run under `env -i`, with a `HOME` whose `.mavenrc` points Maven's `user.home` there and every Java proxy property at a port that refuses
(127.0.0.1:9), and whose Maven settings send every repository to a `file://` copy of Central's files made from `.m2-demo` (4,385 files:
TiffinBox's own installs, `_remote.repositories`, `*.lastUpdated`, `resolver-status.properties` and `.DS_Store` left out,
`maven-metadata-central.xml` served as `maven-metadata.xml`); `http_proxy`, `https_proxy`, their capitals and `ALL_PROXY` at the same
refusing port; `GRAALVM_HOME` set; `DOCKER_CONFIG=~/.docker`; `PATH` Homebrew's and the system's — the exercise's `env -i` shell got the
same; its own process group. Exit 0, all 10 = published, every check passed (native builds 157, 173 and 181 s). The first pre-capture
build said `offline: no` (GraalVM's metadata repository was not in the empty `.m2-demo`) and took **536 artifacts, every one from the
`file://` copy, 0 from anywhere else**; every capture's build said `offline: yes`; the native plugin's metadata download lines: 0;
`github` in the run's logs: 1 line, native-image's printed link to its own build-output documentation, never fetched; `.m2-demo` ended
with 1,451 files. **Interrupted** (below): exit 130, nothing left. **The exercise as viewers run it** is the `exercise` capture itself —
`exercise/README.md`, then `SOLUTION.md`, in one `env -i` `/bin/bash --noprofile --norc` shell, the shell in `c6-unit07/` after each.

Published hashes: change `9d8e3d77e03103117762fc11a2d92cda` · resolvers `b0391d36eaf5f1c34274190cb39aff16` · path `eaa12d4c41c09f6ba51e694ccea2b5e2` · params `22453ca352f857ff76d740af069933e4` · others `ac58b372b50be69d94d44055d8597016` · token `72c7f88edf946de5d668e5bbb9fa282b` · trace `145e4e58497d9a3d7fe3dd996a148678` · timer `085d5198692800ed8a8ce5578183a755` · exercise `b1c7d11b9fcbe6dad84e29b15c06bfbb` · forms `9e6522ab8c94722fa93ac074b24ab9f8`.

## The commands this unit adds

`after/README.md` — the anchor's own — gives every line `receipts.sh` runs or derives from but six, which are this unit's, each read
from the block below and asserted to be exactly this (on the anchor's port 18431; each capture swaps in its own port):

```bash
javap -v -p -cp tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar com.tiffinbox.web.TiffinBoxServer
javap -v -p -cp ../hc0 probe.bare.NoParams
java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc0" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.main.sources=probe.bare.NoParams
curl -s http://127.0.0.1:18431/actuator/mappings | python3 harness/table.py
curl -s http://127.0.0.1:18431/actuator/mappings | python3 harness/table.py row '/customers/{name}'
curl -s http://127.0.0.1:18431/customers/a%2Fb | grep -o '<title>[^<]*</title>'
```

The first reads, with `javap -v -p`, the parameter names javac wrote into `TiffinBoxServer.class` (`resolvers`); the second the same of
the harness's `NoParams`, compiled without `-parameters` on purpose (`resolvers` C); the third starts after/'s class path with that
class joined (`resolvers` C) — each run from a tree's folder, the harness's no-names classes in `../hc0`. The fourth and fifth read the
routing table, `/actuator/mappings` exposed for one run by the request-mapping lesson's line (`change`): whole, and the new route's row
with every key. The last prints the title of Tomcat's own 400 page for an encoded slash (`path`). The anchor README's own new lines —
`curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/customers/Ravi` and the same for `?mealType=VEGAN` — are the shape of every
request a capture sends to TiffinBox's routes and the harness's (`ask`: its port, path and options swapped in); Course 5's lines still
in that README give POST /shutdown with no header, `/customers/7`, and every logger at TRACE.

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else, refuses one whose `native-image --version` is not
`native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1`, and never prints its folder (`$GRAALVM_HOME` in every capture). Only `forms`
needs it. **Without a GraalVM** the script still fills `.m2-demo`, makes the nine other captures, each checked against `receipts.md5`,
then stops where the native build would start (exit 1).

## The repository, Docker, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from the previous unit's `.m2-demo`
(`../c6-unit06/.m2-demo`, its `com/tiffinbox` left out: a stale install would satisfy `-pl tiffinbox-web native:compile-no-fork`)
and `../../spring-web-mvc/_research/m2-seed-s2/` — together exactly the S2 seed: 5,837 files, `diff -rq` against it 0 differences,
no `com/tiffinbox`. **Nothing was downloaded** for this unit: every build said `offline: yes`, the native plugin read its metadata
repository from `.m2-demo` (`file:`), and every native build log holds 0 lines of the plugin's own download (`Downloaded GraalVM
reachability metadata repository from http`, `Failed to download from http`). A fresh clone's `.m2-demo` is empty (git ignores it):
the first build — `after/`'s `mvn -B -Pnative install`, before any capture — fills it from Maven Central and says `offline: no`; every
capture's build then says `offline: yes`. The install writes `com/tiffinbox` into this unit's `.m2-demo` — fine here, and never copied
into a seed. **Docker:** no pull — `docker build` prints its `load metadata` line and the base image's digest, and `its lines that say
pull: 0`. The image (`tiffinbox-bind:1.0.0`) and the container (`tiffinbox-bind`) are this script's own names, checked absent first and
removed on every exit; the build cache is not pruned (`.dockerignore` keeps `secrets/` out of every build context, so it holds no
token).

## The demo token — fake, and never printed; and the trace capture's own

The demo token — `TOKEN=` at the top of `receipts.sh`, 26 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/*/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) when the script runs, mounted read-only into the container (`:ro`), and sent only by `../c5-unit11/curlset.sh` and
`harness/shutdown.sh` on curl's standard input. Every capture's raw output is searched for it before masking (0 in all of them), and so
are the log of every JVM that served, the container's log (`docker logs`), every file this unit ships, the binary's bytes, and every
blob of the image (`docker save`, each gzip layer unpacked; `forms`): 0 everywhere. **`trace` is the one capture whose log is meant to
hold a token** — it measures which loggers write one at TRACE — so it never uses the demo token: `TTOK=` (26 characters, as fake) sits
in two config trees of its own, beside a copy of each tree's jar; each log is counted (the trace token 1 and 2 times, the demo token 0)
and emptied at once, the copies deleted, and the trace token is searched for in every capture's raw output, in every file this unit
ships and in the binary: 0. Spring MVC's WARN line for a missing required header names the header (`X-Shutdown-Token`), never a
value: `token` B's log holds the name 2 times — its two requests without the header — and the token 0, both asserted. The exercise
makes a token of its own (`openssl rand -hex 13`: 26 hexadecimal digits), counted 0 times in its own log and never printed.

## The folders, the names and the ports

- `after/` — the anchor after this change (= `../c6-tiffinbox`). `.harness/before`, `.harness/after` — the two trees, copied, each
  with a config tree, built and extracted (`change`); `.harness/req` — after/ with the header required, one attribute changed, built
  (`token` B); `.harness/trb`, `.harness/tra` — each tree's jar, copied beside a config tree that holds the trace token (`trace`;
  deleted after each run); `.harness/nat` — after/'s native build (`forms`); `.harness/hc` — the harness's classes, compiled against
  after/'s own jar with `-parameters`; `.harness/hc0` — the harness's `NoParams`, compiled without it; `.harness/mine` — the exercise's copy.
- **The harness** — the course's, never TiffinBox's (packages `probe.web` and `probe.bare`, outside `com.tiffinbox`), each joined by
  `--spring.main.sources` on the extracted jar's class path: `harness/probe/web/Resolvers.java` (`/probe/resolvers`: the argument
  resolvers and return-value handlers Spring MVC's `RequestMappingHandlerAdapter` holds, in its order, and for each of TiffinBox's
  request mappings each parameter's type, annotations and name — as Spring's `DefaultParameterNameDiscoverer` reads it — with the first
  resolver whose `supportsParameter` takes it, the adapter's own rule; `/probe/annotations`: the annotations in spring-web's
  `org.springframework.web.bind.annotation` whose `@Target` names `PARAMETER`, read off the jar); `harness/probe/web/Bind.java` (one
  route per binding annotation and default, each answering with the value its parameter got, on one line); `harness/bare/probe/bare/
  NoParams.java` (one path-variable route, compiled without `-parameters`); `harness/table.py` (the request-mapping lesson's reader of
  `/actuator/mappings`, copied unchanged); `harness/shutdown.sh` (POST `/shutdown`, or the path named, with the token read from its file
  — the request-mapping lesson's, with one addition: a fourth argument names the header, which is how the misspelt one is sent).
- **Ports** (brief ⚑1, 19360-19369): after/'s jar 19360 · the previous tree 19361 · after/ with the harness joined 19362 · the harness
  compiled without `-parameters` 19363 · the AOT jar 19364 · the copy whose header is required 19365 · the image 19367 · the binary
  19368 · the exercise 19369; 19366 is never bound. 18425 (TiffinBox's default) and 8080 (Tomcat's) are checked free and never bound on
  this Mac (18425 only inside the container); a run that listens on 8080 is killed and the script dies.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM, the tokens, the user** (`gsub()`, literals escaped), in every line: the demo token → `[masked: the 26-character
   token]` (its length read off the token), the trace token → `[masked: the trace run's token]`; the GraalVM's folder → `$GRAALVM_HOME`;
   this folder → `…`; the folder above → `…/..`; home → `~`; the user name, as a whole word → `<user>`. A last check fails if any capture
   holds `/Users/`, `/private/`, `/home/`, `/var/folders/`, the GraalVM's folder, a unit number, Boot's process line, a log time, an
   unmasked timestamp, a thread number, a stack frame, a `sha256:` ID other than the base image's digest, or `:8080`.
2. **Spring's error timestamp** (`tsmask`, `gsub`): `"timestamp":"<anything>"` → `"timestamp":"…"` and `"timestamp":<digits>` →
   `"timestamp":…` — both forms — in every answer printed and in the seven, which are hashed after it (two lines changed: `/nowhere`'s
   and GET /shutdown's).
3. **WARN and ERROR lines** (`logl`): from their level and logger on, as the log prints the logger (`.w.s.m.s.DefaultHandlerExceptionResolver`
   is Spring MVC's; `o.a.c.c.C.[.[.[/].[dispatcherServlet]` and `o.a.coyote.*` Tomcat's; `o.s.boot.*` Boot's; `o.s.web.method.HandlerMethod`
   Spring's — read off the log, never typed); an identity hash after `@` → `@…`. A request's lines are those the log gained between two
   points where it stopped growing (`ask`, `st`: each answer's last line ends with `· WARN lines it added: N`, and each such line follows).
4. **Orders that move between runs, sorted** (each says so on screen): the routes inside one block of `RequestMappingHandlerMapping`'s
   TRACE lines (`change`), and the routing table's rows with details (`harness/table.py`).
5. **The trace logs** (`held`): never printed; each record that holds the trace token is printed as its level, its logger and its first
   line, and — when the token sits on a later line of the record (Tomcat's request dump) — that line's number and the line, the token
   masked. The record's other lines (the request's `Host`, `User-Agent` and `Accept`) are not printed.
6. **`javap -v -p`** (`mparams`): never printed whole (it names the jar's absolute path); read for how many methods carry a
   `MethodParameters` attribute and the names each named method's attribute holds.
7. **A trace in a log that served** (`frames`): its frames bounded ("over 40, not shown"), each exception's first line shown.
8. **The scrape** (`timer`): Boot's `http_server_requests_seconds_count` lines, read until two reads half a second apart agree;
   Actuator's own series left out and bounded ("fewer than 10"); then the sums.
9. **The native build's lines**: its plugin goals, the GraalVM line, the Java version, each `Warning:` — the file a warning names
   (`in 'file:…'`, or `in 'null'`) → `in '…'` — the eight stages cut after their name, the warnings count and `BUILD SUCCESS`; the rest
   counted, never shown.
10. **`docker build --progress=plain`** through a filter: its `load metadata` line, its `FROM` line (the base image's digest), its naming
    line, step numbers and timings cut (checked on a planted log first); lines that say pull, counted; the rest bounded ("fewer than 300").
11. **Inside the container**: `/proc/net/tcp` and `tcp6`, LISTEN rows only, the address decoded. **On this Mac**: `lsof` by pid (or by
    port, for Docker's forwarder), the address column alone — never a command name (R.18).
12. **A URL that holds a character the shell reads** (`;`, `?`, `&`, `*`, `{`, `}`) is single-quoted on the command line, so the
    printed command is the one that ran.

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`, `$fpid`, and
the exercise's shell `$xpid` with every process under it — `killtree`, by parent pid), sweeps its own process group for any TiffinBox
JVM, binary or `native-image` left, removes the container and the image, deletes the capture runs it had not finished (`.r-NAME.1-3`),
and removes `.r-lock`. The published captures are untouched.

**Measured** on this script (2026-10-14), started as a terminal starts its foreground job (SIGINT at its default, a process group of
its own): SIGINT to its process group during the native build (362 s in, native-image's builder running — 5 processes in the group, 2
of them java): **exit 130** 0.3 s later; 5 s later 0 processes in the group and 0 anywhere naming this folder, no image builder left;
19360-19369, 8080 and 18425 free; no container, no image, no `.r-lock`, no unfinished capture run; the published captures unchanged.

## 1 · change — the previous tree against after/, and what a request can ask

Both trees built offline and extracted; the harness compiled against `after/`'s jar with `-parameters`; `diff -rq`: three files —
`TiffinBoxServer.java`, `CustomerRepository.java` and the anchor README. The server's code lines (neither comment nor blank, imports
left out) naming a binding annotation 0 → 3, the servlet request 3 → 0, `ResponseStatusException` 0 → 1, a route 5 → 6; both Java
files' code diffs, whole. The jar's 58 libraries, unchanged; 19 other files byte for byte the same. Then the problem and its fix, by
this unit's two lines in the anchor README: on the previous tree `/customers/Ravi` is Spring's 404 and `?mealType=VEGAN` answers all
four; on after/ the record, and Priya alone. At TRACE (the request-mapping lesson's line) TiffinBox's six routes with their parameter
types, Boot's two, `8 mappings`, before Boot's started line; the routing table 15 rows, TiffinBox's six each naming a verb, the new
row's `params = []`, and the five servlet filters (Boot's timer among them: `webMvcObservationFilter`).

`.r-change.out` · md5 `9d8e3d77e03103117762fc11a2d92cda` · 3 of 3

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
  Files .harness/before/tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java and .harness/after/tiffinbox-core/src/main/java/com/tiffinbox/CustomerRepository.java differ
  Files .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java and .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java differ
the two Java files, their lines (wc -l), before -> after:
  TiffinBoxServer.java: 176 -> 197
  CustomerRepository.java: 50 -> 64
  TiffinBoxServer.java, its lines that are neither comment nor blank: 100 -> 110, of them - imports left out - naming:
    a value from the request, by Spring MVC's annotation (@PathVariable, @RequestParam, @RequestHeader): 0 -> 3 · the servlet request (HttpServletRequest, getHeader): 3 -> 0
    Spring's status exception (ResponseStatusException): 0 -> 1 · a route (@GetMapping, @PostMapping): 5 -> 6
  its code lines' diff (diff -U0 of the lines above, its file names cut): 9 hunks, 7 lines out, 17 in - whole:
    @@ -3 +2,0 @@
    -import jakarta.servlet.http.HttpServletRequest;
    @@ -6,0 +6 @@
    +import org.springframework.http.HttpStatus;
    @@ -7,0 +8 @@
    +import org.springframework.web.bind.annotation.PathVariable;
    @@ -8,0 +10,2 @@
    +import org.springframework.web.bind.annotation.RequestHeader;
    +import org.springframework.web.bind.annotation.RequestParam;
    @@ -9,0 +13 @@
    +import org.springframework.web.server.ResponseStatusException;
    @@ -43,2 +47,3 @@
    -    List<Customer> customers() throws Exception {
    -        return repo.findAll();
    +    List<Customer> customers(@RequestParam(required = false) MealType mealType) throws Exception {
    +        List<Customer> all = repo.findAll();
    +        return mealType == null ? all : all.stream().filter(c -> c.mealType().equals(mealType.name())).toList();
    @@ -45,0 +51,5 @@
    +    @GetMapping("/customers/{name}")
    +    Customer customer(@PathVariable String name) throws Exception {
    +        return repo.findByName(name)
    +                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "no customer named " + name));
    +    }
    @@ -68,2 +78,3 @@
    -    Map<String, Object> shutdown(HttpServletRequest request, HttpServletResponse response) {
    -        if (!holdsToken(request)) {                  // the server keeps running
    +    Map<String, Object> shutdown(@RequestHeader(name = "X-Shutdown-Token", required = false) String token,
    +                                 HttpServletResponse response) {
    +        if (!holdsToken(token)) {                    // the server keeps running
    @@ -81,2 +92 @@
    -    private boolean holdsToken(HttpServletRequest request) {
    -        String sent = request.getHeader("X-Shutdown-Token");
    +    private boolean holdsToken(String sent) {
  CustomerRepository.java, its code lines: 41 -> 53 - its code lines' diff, the same way: 2 hunks, 0 lines out, 12 in - whole:
    @@ -5,0 +6 @@
    +import java.util.Optional;
    @@ -24,0 +26,11 @@
    +    public Optional<Customer> findByName(String name) throws SQLException {
    +        try (var c = db.open();
    +             var ps = c.prepareStatement(
    +                 "SELECT name, meals_per_day, price_per_meal, meal_type FROM customer WHERE name = ?")) {
    +            ps.setString(1, name);
    +            try (var rs = ps.executeQuery()) {
    +                return rs.next() ? Optional.of(new Customer(rs.getString("name"), rs.getInt("meals_per_day"),
    +                        rs.getInt("price_per_meal"), rs.getString("meal_type"))) : Optional.empty();
    +            }
    +        }
    +    }
the executable jar's BOOT-INF/lib: 58 jars -> 58 · removed 0 · added 0
  README.md - the anchor's README: lines added 90, removed 5 - its new section and the history notes the change made false (not shown)
  the other files, against the previous tree's, byte for byte the same: 19 of 19 (the POMs, the Dockerfile, compose.yaml, .dockerignore, application.yaml, spring.factories, the other five web classes, the other six core classes)
what a request can ask - one customer by name, the vegan ones (this unit's two lines in the anchor's README) - before: the previous tree, the README's run line, port 19361:
$ cd .harness/before && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19361
  listens on: 127.0.0.1:19361 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19361/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19361/customers/Ravi
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Ravi"} 404 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19361/customers?mealType=VEGAN'
  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 · WARN lines it added: 0
$ harness/shutdown.sh 19361 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19361 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
after - after/, the request-mapping lesson's line - Spring MVC's mapping logger at TRACE, the kitchen at DEBUG - port 19360:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19360 --logging.level.kitchen=debug --logging.level.org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping=trace
  listens on: 127.0.0.1:19360 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19360/actuator/health/readiness
  {"status":"UP"} 200
  Spring MVC's RequestMappingHandlerMapping, its lines before Boot's started line (logger: level, message; a block's routes sorted):
    s.w.s.m.m.a.RequestMappingHandlerMapping: TRACE
      c.t.w.TiffinBoxServer:
        {GET [/customers/{name}]}: customer(String)
        {GET [/customers]}: customers(MealType)
        {GET [/dashboard]}: dashboard()
        {GET [/kitchen]}: kitchen()
        {GET [/revenue]}: revenue()
        {POST [/shutdown]}: shutdown(String,HttpServletResponse)
    s.w.s.m.m.a.RequestMappingHandlerMapping: TRACE
      o.s.b.w.a.e.BasicErrorController:
        { [/error], produces [text/html]}: errorHtml(HttpServletRequest,HttpServletResponse)
        { [/error]}: error(HttpServletRequest)
    s.w.s.m.m.a.RequestMappingHandlerMapping: DEBUG 8 mappings in 'requestMappingHandlerMapping'
  then Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19360 (http) with context path '/'
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19360/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19360/customers?mealType=VEGAN'
  [{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"}] 200 · WARN lines it added: 0
$ harness/shutdown.sh 19360 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19360 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the routing table - after/, mappings exposed for one run (the request-mapping lesson's line), port 19360:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19360 --management.endpoints.web.exposure.include=health,prometheus,mappings
  listens on: 127.0.0.1:19360 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19360/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19360/actuator/mappings | python3 harness/table.py
  contexts: 1 (application) · kinds: 3 (dispatcherServlets servletFilters servlets)
  dispatcherServlets · dispatcherServlet: 15 rows, in the table's order - a run of rows with details sorted by pattern (produces lists cut: 5 · class names cut to their last part: 8)
    1  {GET [/actuator], produces [application/vnd.spring-boot.actuator.v3+json … 2 more]} -> Actuator root web endpoint
    2  {GET [/actuator/health], produces [application/vnd.spring-boot.actuator.v3+json … 2 more]} -> Actuator web endpoint 'health'
    3  {GET [/actuator/health/**], produces [application/vnd.spring-boot.actuator.v3+json … 2 more]} -> Actuator web endpoint 'health-path'
    4  {GET [/actuator/mappings], produces [application/vnd.spring-boot.actuator.v3+json … 2 more]} -> Actuator web endpoint 'mappings'
    5  {GET [/actuator/prometheus], produces [text/plain;version=0.0.4;charset=utf-8 … 2 more]} -> Actuator web endpoint 'prometheus'
    6  {GET [/customers]} -> TiffinBoxServer#customers(MealType)
    7  {GET [/customers/{name}]} -> TiffinBoxServer#customer(String)
    8  {GET [/dashboard]} -> TiffinBoxServer#dashboard()
    9  { [/error], produces [text/html]} -> BasicErrorController#errorHtml(HttpServletRequest, HttpServletResponse)
   10  { [/error]} -> BasicErrorController#error(HttpServletRequest)
   11  {GET [/kitchen]} -> TiffinBoxServer#kitchen()
   12  {GET [/revenue]} -> TiffinBoxServer#revenue()
   13  {POST [/shutdown]} -> TiffinBoxServer#shutdown(String, HttpServletResponse)
   14  /webjars/** -> ResourceHttpRequestHandler [classpath [META-INF/resources/webjars/]]
   15  /** -> ResourceHttpRequestHandler [classpath [META-INF/resources/], classpath [resources/], classpath [static/], classpath [public/], ServletContext [/]]
  rows with details: 13 · without: 2 · naming a verb: 11 (GET 10 POST 1)
  TiffinBox's rows (its own handler, or a TiffinBoxServer method): 6 · naming a verb: 6 (GET 5 POST 1)
  servletFilters: 5, by name: characterEncodingFilter, formContentFilter, requestContextFilter, Tomcat WebSocket (JSR356) Filter, webMvcObservationFilter · on /* : 5
  servlets: 1 · dispatcherServlet on /
$ curl -s http://127.0.0.1:19360/actuator/mappings | python3 harness/table.py row '/customers/{name}'
  the row for /customers/{name}: 1
  /customers/{name} - 3 keys: details handler predicate
    details.handlerMethod.className = com.tiffinbox.web.TiffinBoxServer
    details.handlerMethod.descriptor = (Ljava/lang/String;)Lcom/tiffinbox/Customer;
    details.handlerMethod.name = customer
    details.requestMappingConditions.consumes = []
    details.requestMappingConditions.headers = []
    details.requestMappingConditions.methods = ["GET"]
    details.requestMappingConditions.params = []
    details.requestMappingConditions.patterns = ["/customers/{name}"]
    details.requestMappingConditions.produces = []
    handler = com.tiffinbox.web.TiffinBoxServer#customer(String)
    predicate = {GET [/customers/{name}]}
$ harness/shutdown.sh 19360 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19360 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 2 · resolvers — who fills a route's parameters, and by what name

The harness's `Resolvers` on after/'s class path: Spring MVC's adapter holds **28 argument resolvers** and 15 return-value handlers
here, in the order it asks them; TiffinBox's parameters, each with the first resolver that takes it: `@PathVariable String name` → 3
`PathVariableMethodArgumentResolver`, `@RequestParam MealType mealType` → 1 `RequestParamMethodArgumentResolver` (the 27th is the
catch-all for a simple parameter with no annotation), `@RequestHeader String token` → 10 `RequestHeaderMethodArgumentResolver`, the
`HttpServletResponse` → 17. Boot's parent POM, line 113, `<parameters>true</parameters>`; `javap -v -p`: 7 of TiffinBoxServer's
methods carry `MethodParameters`, with `name`, `mealType`, `token response`. C (labelled): the harness's `NoParams`, compiled without
the flag — 0, `no names`; after/ starts with it joined, cleanly (0 WARN/ERROR, Boot's started line); its route answers Boot's 500, and
Tomcat's ERROR line holds Spring's sentence, `Ensure that the compiler uses the '-parameters' flag.` (the trace over 40 frames, not
shown); TiffinBox's own `/customers/Ravi` still 200 in the same JVM.

`.r-resolvers.out` · md5 `b0391d36eaf5f1c34274190cb39aff16` · 3 of 3

```
who fills a route's parameters - after/ on the README's class-path line with the harness's Resolvers joined, port 19362:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19362 --spring.main.sources=probe.web.Resolvers
  listens on: 127.0.0.1:19362 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19362/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19362/probe/resolvers
  argument resolvers: 28 · return-value handlers: 15
    1 RequestParamMethodArgumentResolver
    2 RequestParamMapMethodArgumentResolver
    3 PathVariableMethodArgumentResolver
    4 PathVariableMapMethodArgumentResolver
    5 MatrixVariableMethodArgumentResolver
    6 MatrixVariableMapMethodArgumentResolver
    7 ServletModelAttributeMethodProcessor
    8 RequestResponseBodyMethodProcessor
    9 RequestPartMethodArgumentResolver
   10 RequestHeaderMethodArgumentResolver
   11 RequestHeaderMapMethodArgumentResolver
   12 ServletCookieValueMethodArgumentResolver
   13 ExpressionValueMethodArgumentResolver
   14 SessionAttributeMethodArgumentResolver
   15 RequestAttributeMethodArgumentResolver
   16 ServletRequestMethodArgumentResolver
   17 ServletResponseMethodArgumentResolver
   18 HttpEntityMethodProcessor
   19 RedirectAttributesMethodArgumentResolver
   20 ModelMethodProcessor
   21 MapMethodProcessor
   22 ErrorsMethodArgumentResolver
   23 SessionStatusMethodArgumentResolver
   24 UriComponentsBuilderMethodArgumentResolver
   25 ApiVersionMethodArgumentResolver
   26 PrincipalMethodArgumentResolver
   27 RequestParamMethodArgumentResolver
   28 ServletModelAttributeMethodProcessor
  {GET [/customers/{name}]} customer - parameters: 1
      String name @PathVariable -> 3 PathVariableMethodArgumentResolver
  {GET [/customers]} customers - parameters: 1
      MealType mealType @RequestParam -> 1 RequestParamMethodArgumentResolver
  {GET [/dashboard]} dashboard - parameters: 0
  {GET [/kitchen]} kitchen - parameters: 0
  {GET [/revenue]} revenue - parameters: 0
  {POST [/shutdown]} shutdown - parameters: 2
      String token @RequestHeader -> 10 RequestHeaderMethodArgumentResolver
      HttpServletResponse response -> 17 ServletResponseMethodArgumentResolver
   200
$ harness/shutdown.sh 19362 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19362 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
by name - Boot's parent POM (the parent TiffinBox's POM inherits) sets the compiler's flag; javap reads what javac wrote into the class:
  $M2/org/springframework/boot/spring-boot-starter-parent/4.1.1/spring-boot-starter-parent-4.1.1.pom, its compiler plugin's configuration: line 113: <parameters>true</parameters>
$ cd .harness/after && javap -v -p -cp tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar com.tiffinbox.web.TiffinBoxServer
  its methods with a MethodParameters attribute: 7 · customer(java.lang.String): name · customers(com.tiffinbox.MealType): mealType · shutdown(java.lang.String, jakarta.servlet.http.HttpServletResponse): token response
C (labelled) - a harness route compiled WITHOUT -parameters (the harness's NoParams, /probe/bare/{name}), joined to after/ on the class-path line (this unit's), port 19363:
$ javac -d .harness/hc0 -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/bare/probe/bare/NoParams.java
  exit 0
$ cd .harness/after && javap -v -p -cp ../hc0 probe.bare.NoParams
  its methods with a MethodParameters attribute: 0 · name(java.lang.String): no names
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc0" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19363 --spring.main.sources=probe.bare.NoParams
  listens on: 127.0.0.1:19363 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19363/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19363 (http) with context path '/'
  WARN and ERROR lines in its log, from the start: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19363/probe/bare/Ravi
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/bare/Ravi"} 500
  its lines at WARN and ERROR: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalArgumentException: Name for argument of type [java.lang.String] not specified, and parameter name information not available via reflection. Ensure that the compiler uses the '-parameters' flag.] with root cause
  stack frames in its log: over 40, not shown · its exceptions' first lines:
    java.lang.IllegalArgumentException: Name for argument of type [java.lang.String] not specified, and parameter name information not available via reflection. Ensure that the compiler uses the '-parameters' flag.
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19363/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200 · WARN lines it added: 0
$ harness/shutdown.sh 19363 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19363 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 3 · path — path variables

after/ with the harness's `Bind` joined. `/customers/Ravi` → the record; `/customers/Nobody` → 404, Boot's body in `/nowhere`'s shape
(both asked), 0 WARN lines — `ResponseStatusException` is resolved without one, and the body names no reason (RE-MEASURE 5);
`/customers/Ravi.json` → 404: the whole segment is the name, as the harness's echo shows (`name=[Ravi.json]`); `Sunil%20K` arrives as
`Sunil K`; `/customers/a%2Fb` → `400 text/html;charset=utf-8`, Tomcat's own page (`<title>HTTP Status 400 – Bad Request</title>`), not
Spring's JSON. The run's log: 0 WARN and 0 ERROR lines.

`.r-path.out` · md5 `eaa12d4c41c09f6ba51e694ccea2b5e2` · 3 of 3

```
after/ on the README's class-path line with the harness's Bind joined (its /probe/bind/name/{name} answers with the value it got), port 19362:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19362 --spring.main.sources=probe.web.Bind
  listens on: 127.0.0.1:19362 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19362/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19362/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19362/customers/Nobody
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Nobody"} 404 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19362/nowhere
  {"timestamp":"…","status":404,"error":"Not Found","path":"/nowhere"} 404 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19362/customers/Ravi.json
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Ravi.json"} 404 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19362/probe/bind/name/Ravi.json
  name=[Ravi.json] 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19362/probe/bind/name/Sunil%20K
  name=[Sunil K] 200 · WARN lines it added: 0
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19362/customers/a%2Fb
  400 text/html;charset=utf-8 · WARN lines it added: 0
$ curl -s http://127.0.0.1:19362/customers/a%2Fb | grep -o '<title>[^<]*</title>'
  <title>HTTP Status 400 – Bad Request</title>
  WARN and ERROR lines in its log, from the start: 0
$ harness/shutdown.sh 19362 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19362 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 4 · params — request parameters, and their defaults

TiffinBox's meal type: `VEG` → Ravi and Sunil; `veg` → Spring's 400 and one WARN line, Spring MVC's
`DefaultHandlerExceptionResolver`: `MethodArgumentTypeMismatchException: Method parameter 'mealType': Failed to convert value of type
'java.lang.String' to required type 'com.tiffinbox.MealType'` — Boot's body names no reason; `?mealType=` → all four (an empty value
is no filter); `VEG&mealType=VEGAN` → VEG's two (the first). The harness's routes: `@RequestParam String q` missing → 400 + WARN
`MissingServletRequestParameterException`, `?q=` → `q=[]` (an empty value satisfies "required"); `@RequestParam(defaultValue = "30")
int days` — missing → 30, `?days=` → 30, `?days=10` → 10; `Optional<Integer>` → `Optional.empty`, `Optional[5]`; `List<String>` —
`?tag=a&tag=b` and `?tag=a,b` → `[a, b]`. Two WARN lines in the run, the two 400s'.

`.r-params.out` · md5 `22453ca352f857ff76d740af069933e4` · 3 of 3

```
after/ on the README's class-path line with the harness's Bind joined, port 19362 - TiffinBox's meal type first:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19362 --spring.main.sources=probe.web.Bind
  listens on: 127.0.0.1:19362 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19362/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19362/customers?mealType=VEG'
  [{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19362/customers?mealType=veg'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'mealType': Failed to convert value of type 'java.lang.String' to required type 'com.tiffinbox.MealType'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam com.tiffinbox.MealType] for value [veg]]
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19362/customers?mealType='
  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19362/customers?mealType=VEG&mealType=VEGAN'
  [{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 · WARN lines it added: 0
the harness's routes - required, a default value, Optional, a list:
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19362/probe/bind/param
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/probe/bind/param"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.bind.MissingServletRequestParameterException: Required request parameter 'q' for method parameter type String is not present]
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19362/probe/bind/param?q='
  q=[] 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19362/probe/bind/default
  days=30 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19362/probe/bind/default?days='
  days=30 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19362/probe/bind/default?days=10'
  days=10 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19362/probe/bind/optional
  days=Optional.empty 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19362/probe/bind/optional?days=5'
  days=Optional[5] 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19362/probe/bind/list?tag=a&tag=b'
  tag=[a, b] 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19362/probe/bind/list?tag=a,b'
  tag=[a, b] 200 · WARN lines it added: 0
  WARN lines in this run's log, at Boot's default level: 2
$ harness/shutdown.sh 19362 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19362 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 5 · others — a header, a cookie, a matrix variable, a request attribute — and every binding annotation, counted

The harness's `Bind`: `@RequestHeader("X-Meal")` missing → 400 + WARN `MissingRequestHeaderException`, `-H 'X-Meal: lunch'` →
`meal=lunch`; `@CookieValue("plan")` missing → 400 + WARN `MissingRequestCookieException`, `-b plan=weekly` → `plan=weekly`;
`@MatrixVariable` — `/probe/bind/matrix/mon;veg=yes` → `veg=yes`, read by default on this tree (nothing in it configures matrix
variables), and without it `veg=null`; `@RequestAttribute("slip")`, none set → 400 + WARN `ServletRequestBindingException`. Then the
harness's `Resolvers` reads spring-web-7.0.9.jar: 27 annotations in `org.springframework.web.bind.annotation`, **11 a parameter can
carry**; **6** of them sit on a route this unit's captures ask (TiffinBox's and the harness's code lines) — `@CookieValue`
`@MatrixVariable` `@PathVariable` `@RequestAttribute` `@RequestHeader` `@RequestParam` — and **the other 5**, each its lesson's subject:
`@RequestBody` *Request Bodies and HttpMessageConverter*, `@ModelAttribute` and `@BindParam` *Binding, Converters and Formatters*,
`@RequestPart` *File Upload and Download*, `@SessionAttribute` *Sessions, Cookies and Flash Attributes* (C6-31's pointers; the
roadmap's "every binding annotation with a curl", counted). Three WARN lines in the run.

`.r-others.out` · md5 `ac58b372b50be69d94d44055d8597016` · 3 of 3

```
after/ on the README's class-path line with the harness's Bind and Resolvers joined, port 19362:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19362 --spring.main.sources=probe.web.Bind,probe.web.Resolvers
  listens on: 127.0.0.1:19362 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19362/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19362/probe/bind/header
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/probe/bind/header"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.bind.MissingRequestHeaderException: Required request header 'X-Meal' for method parameter type String is not present]
$ curl -s -w ' %{http_code}\n' -H 'X-Meal: lunch' http://127.0.0.1:19362/probe/bind/header
  meal=lunch 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19362/probe/bind/cookie
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/probe/bind/cookie"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.bind.MissingRequestCookieException: Required cookie 'plan' for method parameter type String is not present]
$ curl -s -w ' %{http_code}\n' -b plan=weekly http://127.0.0.1:19362/probe/bind/cookie
  plan=weekly 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19362/probe/bind/matrix/mon;veg=yes'
  day=mon veg=yes 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19362/probe/bind/matrix/mon
  day=mon veg=null 200 · WARN lines it added: 0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19362/probe/bind/attr
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/probe/bind/attr"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.bind.ServletRequestBindingException: Missing request attribute 'slip' of type String]
every annotation a parameter can carry, read off spring-web's jar (the harness's Resolvers):
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19362/probe/annotations
  spring-web-7.0.9.jar · org.springframework.web.bind.annotation: annotations 27 · a parameter can carry 11: @BindParam @CookieValue @MatrixVariable @ModelAttribute @PathVariable @RequestAttribute @RequestBody @RequestHeader @RequestParam @RequestPart @SessionAttribute
   200
  of them on a route this unit's captures ask (the code lines of TiffinBoxServer.java and the harness's Bind.java): 6 - @CookieValue @MatrixVariable @PathVariable @RequestAttribute @RequestHeader @RequestParam
  the others: 5 - @BindParam @ModelAttribute @RequestBody @RequestPart @SessionAttribute
  WARN lines in this run's log, at Boot's default level: 3
$ harness/shutdown.sh 19362 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19362 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 6 · token — POST /shutdown's header, required or not (A/B/A′)

A — after/, `required = false`: POST /shutdown with no header (Course 5's line in the anchor README) → `{"error":"forbidden"} 403`,
the method's own, 0 WARN; the right token under a misspelt name (`X-Shutdown-Tokn`, `harness/shutdown.sh`'s fourth argument) → the
same 403 — a misspelt header is no header; the right one stops it, exit 0. B — a copy with `required = true` (its `diff -U0`: one
attribute), built offline: no header → Spring MVC's 400, Boot's body, and the WARN line `MissingRequestHeaderException: Required
request header 'X-Shutdown-Token' for method parameter type String is not present`; the misspelt one the same; TiffinBox never says
forbidden; its log names the header 2 times and holds the token 0 (RE-MEASURE 6). A′ = A, line for line.

`.r-token.out` · md5 `72c7f88edf946de5d668e5bbb9fa282b` · 3 of 3

```
A - after/ (its header optional: required = false), the README's run line, port 19360:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19360
  listens on: 127.0.0.1:19360 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19360/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19360/shutdown
  {"error":"forbidden"} 403 · WARN lines it added: 0
$ harness/shutdown.sh 19360 .harness/after/secrets/tiffinbox/shutdown-token /shutdown X-Shutdown-Tokn
  POST /shutdown (the token in a header named X-Shutdown-Tokn) -> 403 application/json · Content-Length: 21 · {"error":"forbidden"} · curl exit 0 · WARN lines it added: 0
$ harness/shutdown.sh 19360 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19360 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - a copy of after/ whose header is required (one attribute changed), built with the README's line, port 19365:
  $ diff -U0 after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java .harness/req/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
    @@ -143 +143 @@
    -    Map<String, Object> shutdown(@RequestHeader(name = "X-Shutdown-Token", required = false) String token,
    +    Map<String, Object> shutdown(@RequestHeader(name = "X-Shutdown-Token", required = true) String token,
  $ cd .harness/req && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
    built the copy · offline: yes · exit 0
$ cd .harness/req && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19365
  listens on: 127.0.0.1:19365 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19365/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19365/shutdown
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/shutdown"} 400 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.bind.MissingRequestHeaderException: Required request header 'X-Shutdown-Token' for method parameter type String is not present]
$ harness/shutdown.sh 19365 .harness/req/secrets/tiffinbox/shutdown-token /shutdown X-Shutdown-Tokn
  POST /shutdown (the token in a header named X-Shutdown-Tokn) -> 400 application/json · Content-Length: none · {"timestamp":"…","status":400,"error":"Bad Request","path":"/shutdown"} · curl exit 0 · WARN lines it added: 1
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.bind.MissingRequestHeaderException: Required request header 'X-Shutdown-Token' for method parameter type String is not present]
$ harness/shutdown.sh 19365 .harness/req/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19365 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 2 times
A' - A again:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19360
  listens on: 127.0.0.1:19360 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19360/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19360/shutdown
  {"error":"forbidden"} 403 · WARN lines it added: 0
$ harness/shutdown.sh 19360 .harness/after/secrets/tiffinbox/shutdown-token /shutdown X-Shutdown-Tokn
  POST /shutdown (the token in a header named X-Shutdown-Tokn) -> 403 application/json · Content-Length: 21 · {"error":"forbidden"} · curl exit 0 · WARN lines it added: 0
$ harness/shutdown.sh 19360 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19360 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 7 · trace — C (labelled): what TRACE prints

Course 5's logging lesson measured "At TRACE, still no token" on TiffinBox's own server; this re-measures it, with the anchor README's
own line (`--logging.level.root=trace`) and the seven, on each tree's jar beside a config tree that holds the trace token. Before (the
previous tree): the seven `87ca7efc…`, the trace token **1** time in the log — Tomcat's `o.a.coyote.http11.Http11InputBuffer` at DEBUG,
`Received [POST /shutdown HTTP/1.1`, the token on the record's line 5, `X-Shutdown-Token: …`: Tomcat prints the request it received,
headers and all, since TiffinBox moved onto Tomcat. After (after/): the same seven, the token **2** times — Tomcat's record, and Spring
MVC's `o.s.web.method.HandlerMethod` at TRACE, `Arguments: [<the token>, …LifecycleHttpServletResponse@…]`: the header is a parameter
now, and Spring prints the arguments it bound. The demo token 0 in both logs. The anchor README's Course 5 note is amended in place.

`.r-trace.out` · md5 `145e4e58497d9a3d7fe3dd996a148678` · 3 of 3

```
C (labelled) - the README's line with every logger at TRACE (Course 5's logging lesson: "At TRACE, still no token"), then the seven; each tree's jar, copied to a folder whose config tree holds a second fake token, the trace run's own (26 characters):
before - the previous tree's jar, port 19361:
$ cd .harness/trb && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19361 --logging.level.root=trace
  listens on: 127.0.0.1:19361 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19361/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19361 .harness/trb/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  its log, the trace run's token in it: 1 · the demo token: 0 · the records that hold the trace run's token (level logger: first line):
    DEBUG o.a.coyote.http11.Http11InputBuffer: Received [POST /shutdown HTTP/1.1  - the token on the record's line 5: X-Shutdown-Token: [masked: the trace run's token]
after - after/'s jar, port 19360:
$ cd .harness/tra && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19360 --logging.level.root=trace
  listens on: 127.0.0.1:19360 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19360/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19360 .harness/tra/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  its log, the trace run's token in it: 2 · the demo token: 0 · the records that hold the trace run's token (level logger: first line):
    DEBUG o.a.coyote.http11.Http11InputBuffer: Received [POST /shutdown HTTP/1.1  - the token on the record's line 5: X-Shutdown-Token: [masked: the trace run's token]
    TRACE o.s.web.method.HandlerMethod: Arguments: [[masked: the trace run's token], org.springframework.web.context.request.async.StandardServletAsyncWebRequest$LifecycleHttpServletResponse@…]
```

## 8 · timer — one series per route

Seven requests on after/'s jar, then the scrape: `uri="/customers/{name}"` 200 ×2 (Ravi, Meera) and 404 ×2 (Nobody, and Course 5's
`/customers/7`, its line in the anchor README); `uri="/customers"` 200 (VEG) and 400 (`veg`); **7 sent, 6 counted** — the encoded
slash, Tomcat's own 400, never reached Boot's timer, a servlet filter. Course 5's metrics lesson's rule, "tagged by the route it
declares — never by URL", kept by Boot's timer, by pattern. One WARN line, the 400's.

`.r-timer.out` · md5 `085d5198692800ed8a8ce5578183a755` · 3 of 3

```
after/, the README's run line, port 19360 - seven requests, then the scrape:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19360
  listens on: 127.0.0.1:19360 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19360/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19360/customers/Ravi
  200 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19360/customers/Meera
  200 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19360/customers/Nobody
  404 application/json
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19360/customers/7
  404
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' 'http://127.0.0.1:19360/customers?mealType=VEG'
  200 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' 'http://127.0.0.1:19360/customers?mealType=veg'
  400 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19360/customers/a%2Fb
  400 text/html;charset=utf-8
  the scrape's count lines for Boot's timer, http_server_requests (Actuator's own series left out):
    http_server_requests_seconds_count{error="none",exception="none",method="GET",outcome="CLIENT_ERROR",status="400",uri="/customers"} 1
    http_server_requests_seconds_count{error="none",exception="none",method="GET",outcome="CLIENT_ERROR",status="404",uri="/customers/{name}"} 2
    http_server_requests_seconds_count{error="none",exception="none",method="GET",outcome="SUCCESS",status="200",uri="/customers"} 1
    http_server_requests_seconds_count{error="none",exception="none",method="GET",outcome="SUCCESS",status="200",uri="/customers/{name}"} 2
  Actuator's own series, left out: fewer than 10 (the readiness polls and these reads move their counts)
  requests sent: 7 · counted by Boot's timer: 6 · series: 4 · their uri tags: /customers /customers/{name}
  WARN lines these requests added, at Boot's default level: 1
$ harness/shutdown.sh 19360 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19360 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 9 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s commands, then `exercise/solution/SOLUTION.md`'s, read from the files and run as written, one after the other in
ONE shell a viewer could have — `env -i` (HOME, and the PATH the script was started with), `/bin/bash --noprofile --norc`, started in
this folder: as shipped `status: 400 · customers: 0 · WARN: Failed to convert value of type 'java.lang.String' to required type
'com.tiffinbox.MealType'`, then the solution `status: 200 · customers: 1 (Priya) · WARN: none`, the shell in this unit's folder after
each, the copy's own token 0 times in its log.

`.r-exercise.out` · md5 `b1c7d11b9fcbe6dad84e29b15c06bfbb` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 7 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
  $ mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package)
  $ (cd .harness/mine/after && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19369 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19369/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s -D ../head.txt -o ../body.txt 'http://127.0.0.1:19369/customers?mealType=vegan'; ../../../harness/shutdown.sh 19369 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && n=$(grep -o '"name":"[^"]*"' ../body.txt | sed 's/^"name":"//; s/"$//' | paste -sd' ' -) && w=$(grep -m1 -o "Failed to convert value of type [^;]*" ../run.log || true) && echo "status: $(sed -n '1s/^HTTP\/1\.1 \([0-9]*\).*/\1/p' ../head.txt) · customers: $(grep -o '"name":"' ../body.txt | wc -l | tr -d ' ')${n:+ ($n)} · WARN: ${w:-none}")
  exit 0 · what they printed:
    status: 400 · customers: 0 · WARN: Failed to convert value of type 'java.lang.String' to required type 'com.tiffinbox.MealType'
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 1
the solution's 3 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ (cd .harness/mine/after && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19369 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19369/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s -D ../head.txt -o ../body.txt 'http://127.0.0.1:19369/customers?mealType=VEGAN'; ../../../harness/shutdown.sh 19369 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && n=$(grep -o '"name":"[^"]*"' ../body.txt | sed 's/^"name":"//; s/"$//' | paste -sd' ' -) && w=$(grep -m1 -o "Failed to convert value of type [^;]*" ../run.log || true) && echo "status: $(sed -n '1s/^HTTP\/1\.1 \([0-9]*\).*/\1/p' ../head.txt) · customers: $(grep -o '"name":"' ../body.txt | wc -l | tr -d ' ')${n:+ ($n)} · WARN: ${w:-none}")
  exit 0 · what they printed:
    status: 200 · customers: 1 (Priya) · WARN: none
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · listening on 19369 now: 0
```

## 10 · forms — every form still serves (⚑16, R.40, S2.20)

`after/`'s native build (the README's two Maven lines, offline: 8 of 8 stages, Mach-O, 0 bytes of either token, 0 download lines);
Spring's generated `reachability-metadata.json` names `com.tiffinbox.Customer` (its declared fields and constructors, four accessors) and
`com.tiffinbox.MealType`. Then **1** the jar, **2** the AOT jar, **3** the binary, **4** the image (built here from after/'s Dockerfile,
its layers searched: 0 tokens; published on `127.0.0.1:19367` alone): each the seven `87ca7efc…` on a fresh start, exit 0; then, on a
second start of each, the new routes — `/customers/Ravi` 200, `/customers/Nobody` 404, `?mealType=VEGAN` → Priya, `?mealType=vegan`
400, POST /shutdown with no header 403 — 4 of 4 each (RE-MEASURE 15; the brief's "every new route in a native binary of its own
unit's tree"); loopback counted form by form.

`.r-forms.out` · md5 `9e6522ab8c94722fa93ac074b24ab9f8` · 3 of 3

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
  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: under 20 minutes · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes
  file: Mach-O 64-bit executable · the demo token in its bytes: 0 · the trace run's: 0
what Spring's AOT step registered for the native build - the record the routes return, and the enum a route's parameter is:
  Spring's generated metadata (spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json): reflection entries naming com.tiffinbox.Customer: 1 - all declared fields · all declared constructors · 4 methods (mealType mealsPerDay name pricePerMeal)
  Spring's generated metadata (spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json): reflection entries naming com.tiffinbox.MealType: 1 - all declared fields · 1 methods (<init>)
1 the jar - .harness/after, the README's run line, port 19360:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19360
  listens on: 127.0.0.1:19360 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19360/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19360 (http) with context path '/'
$ $CURLSET 19360 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the new routes, on a second start of the jar:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19360
  listens on: 127.0.0.1:19360 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19360/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19360/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19360/customers/Nobody
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Nobody"} 404
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19360/customers?mealType=VEGAN'
  [{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"}] 200
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19360/customers?mealType=vegan'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19360/shutdown
  {"error":"forbidden"} 403
$ harness/shutdown.sh 19360 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19360 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19364:
$ cd .harness/nat && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19364
  listens on: 127.0.0.1:19364 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19364/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19364 (http) with context path '/'
$ $CURLSET 19364 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the new routes, on a second start of the AOT jar:
$ cd .harness/nat && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19364
  listens on: 127.0.0.1:19364 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19364/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19364/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19364/customers/Nobody
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Nobody"} 404
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19364/customers?mealType=VEGAN'
  [{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"}] 200
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19364/customers?mealType=vegan'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19364/shutdown
  {"error":"forbidden"} 403
$ harness/shutdown.sh 19364 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19364 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
3 the binary - .harness/nat, the README's line, port 19368:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19368
  listens on: 127.0.0.1:19368 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19368/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19368 (http) with context path '/'
$ $CURLSET 19368 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the new routes, on a second start of the binary:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19368
  listens on: 127.0.0.1:19368 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19368/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19368/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19368/customers/Nobody
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Nobody"} 404
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19368/customers?mealType=VEGAN'
  [{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"}] 200
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19368/customers?mealType=vegan'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19368/shutdown
  {"error":"forbidden"} 403
$ harness/shutdown.sh 19368 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
  exit 0 · listening on 19368 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19367:
$ cd .harness/after && docker build --progress=plain -t tiffinbox-bind:1.0.0 .
  exit 0 · its lines, through the filter:
    [internal] load metadata for docker.io/library/eclipse-temurin:25-jre
    [builder 1/4] FROM docker.io/library/eclipse-temurin:25-jre@sha256:fcd7fd7b387f94bb2ac461478a7436ad8e349924c374ea8313919624dceae636
    naming to docker.io/library/tiffinbox-bind:1.0.0
  its lines that say pull: 0 · its other lines: fewer than 300, not shown
  the image saved (docker save): 15 blobs, its 11 layers among them, each read whole (gzip ones unpacked) · the demo token in them: 0
$ cd .harness/after && docker run -d --name tiffinbox-bind --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19367:18425 tiffinbox-bind:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19367/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19367
  on this Mac, listening on port 19367: 127.0.0.1:19367
$ $CURLSET 19367 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
$ docker wait tiffinbox-bind
  0
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  its log (docker logs): Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1 · the demo token 0 times · X-Shutdown-Token 0 times
  then the new routes, on a second container of the image:
$ cd .harness/after && docker run -d --name tiffinbox-bind --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19367:18425 tiffinbox-bind:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19367/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19367
  on this Mac, listening on port 19367: 127.0.0.1:19367
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19367/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19367/customers/Nobody
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Nobody"} 404
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19367/customers?mealType=VEGAN'
  [{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"}] 200
$ curl -s -w ' %{http_code}\n' 'http://127.0.0.1:19367/customers?mealType=vegan'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19367/shutdown
  {"error":"forbidden"} 403
$ harness/shutdown.sh 19367 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: 17 · {"stopping":true} · curl exit 0
$ docker wait tiffinbox-bind
  0
  exit 0 · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times
four forms, one tree: the seven (masked) 4 of 4 times 87ca7efc8584dcccd40e6b956db1de9b · Ravi 200 4 of 4 · a name nobody has 404 4 of 4 · VEGAN -> Priya 4 of 4 · vegan 400 4 of 4 · no header 403 4 of 4
  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127.0.0.1 alone yes
```

## Exercise

**Your turn:** ask for the vegan customers. The README's request answers 400. Find why in the log, fix the URL, and count them.
`exercise/README.md` has the commands (copy `after/` with a token of its own, build the jar offline); its last line, in a subshell,
starts TiffinBox on 19369, asks `/customers?mealType=vegan`, stops TiffinBox and prints — as shipped — `status: 400 · customers: 0 ·
WARN: Failed to convert value of type 'java.lang.String' to required type 'com.tiffinbox.MealType'`. Done is `status: 200 · customers:
1 (Priya) · WARN: none`. Measured answer: `exercise/solution/SOLUTION.md` (the README's two `export` lines, then the same line with
`mealType=VEGAN`), run in the same shell. Run `./receipts.sh` once first on a fresh clone.

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-14) |
|---|---|---|---|
| 5 | `ResponseStatusException` for `/customers/{name}` in the anchor | a harness route (`Rse`) | **404 in `/nowhere`'s shape, 0 WARN, no reason in the body** — on the jar (`path`) and in all four forms (`forms`) |
| 6 | `required = true` on the token header → 400 (B) | a required harness header | **B: no header and a misspelt one → Spring MVC's 400 + `MissingRequestHeaderException` ×2; A/A′ 403** (`token`) |
| 15 | the image of every chain unit | once, on the chain end | **built from after/'s Dockerfile, 0 pulls, its layers 0 tokens, `127.0.0.1:19367` alone, the seven `87ca7efc…` and the new routes, `docker wait` 0** (`forms`) |
| 16 | the exercise as viewers run it | end state on a sketch | **one `env -i` shell: `status: 400 · customers: 0 · WARN: …MealType'`, then `status: 200 · customers: 1 (Priya) · WARN: none`** (`exercise`) |
| — | "every new route in a native binary of its own unit's tree" (Not measured) | the chain-end binary only | **the binary of this tree: Ravi 200, Nobody 404, VEGAN → Priya, vegan 400, no header 403** (`forms`) |

## Found on the way

- **Every new check fails on a planted fault first** (R.65): the checks block run alone on copies of the published captures, one line
  changed per plant — the binding lines 0 → 2; 7 mappings; Ravi 200 on the previous tree; 14 rows; `params = ["mealType"]`; `customers()`
  without its type; 27 resolvers; the path variable's resolver 4; C with names; C answering 200; Nobody with a WARN line; `%20` undecoded;
  `%2F` as JSON; `veg` without its WARN; `?days=` → 0; `tag=[a,b]`; 10 annotations; matrix `veg=null`; 6 others; B saying forbidden; A′'s
  log with the header's name; B's attribute false; the trace token once after; `HandlerMethodX`; 7 counted; one `/customers/{name}` 200;
  the exercise's 2 customers; its README run with 0 WARN; 3 of 4 forms; `MealType` 0 in the metadata; a raw token in a capture's run; a
  carriage return in a capture — **32 plants, 32 stops**, each naming its check. The exercise's `SOLUTION.md` export checks are
  the request-mapping lesson's, verbatim (shown failing there).
- **Tomcat's request dump ends its lines in CR LF.** The first run's `trace` held two carriage returns — Tomcat prints the request as it
  came — and its Tomcat-record check failed on them. `held` drops `` now, and a last check fails any capture that holds one (shown on a
  plant). Nine of the published hashes come from that first run; `trace`'s from a run of `change` and `trace` alone, the same script,
  /bin/bash 3.2 — and every one is reproduced by the runs of record.
- **A script's background job ignores Ctrl-C.** The first interrupt test started `./receipts.sh` from a script, in a process group of its
  own but as a background job — and a background job of a non-interactive shell starts with SIGINT ignored, which bash cannot trap: the
  SIGINT sent to its group during the native build changed nothing, and the run went on to exit 0, every capture = published (a run of
  record in all but name). Started as a terminal starts its foreground job — SIGINT at its default, its own group — the trap fires (below,
  "Interrupted"). A ten-line probe showed both ways: `still running after SIGINT`, then `exit 130 · trapped`.
- **A parameter is something TRACE prints.** Binding the token as `@RequestHeader String token` puts it in Spring MVC's
  `o.s.web.method.HandlerMethod` TRACE line, `Arguments: [<the token>, …]` — measured in `trace`, with a fake token of its own. The same
  run found that the anchor README's Course 5 note "At TRACE, still no token" was already false on the previous tree: Tomcat's
  `Http11InputBuffer` prints each request it received, headers and all, at DEBUG (once on the previous tree, twice here). The note is
  amended in place; the brief's ⚑6 (`@RequestHeader`) is kept, the hazard named — for RED (see "For unit 08 — and RED").
- **`javap -v` names the jar's absolute path** (`Classfile jar:file:/Users/…`): `mparams` never prints it; it reads the attribute
  counts and names alone. And `javap` without `-p` shows 5 of the 7 methods with names — the private ones (`holdsToken`, `ordered`)
  need `-p`.
- **The previous tree's AOT metadata already named `MealType`** (all its declared fields, its constructor): the configuration
  properties' `List<MealType>`. So `forms` says what the metadata names, never that the new parameter put it there.
- **A header with an explicit name needs no compiled name.** `@RequestHeader(name = "X-Shutdown-Token")` names its header; only the
  path variable and the meal type are found by the parameter's own name — the anchor README and the Javadoc say so.
- **`ResponseStatusException`'s body has the name in its `path`**, though no reason: "names no reason", never "never says which name".
- **A curl answer's status shares its line** only when the body ends without a newline: the harness's routes answer one line, no
  newline, so each request is two lines on screen — the command, then the answer with its WARN count.
- **The checks' own command lines are the README's.** The checks build the request lines they look for (`BQ`, `QQ`) and first assert
  that those builders give the anchor README's own lines back — so a check can never pass on a line the script did not run.

## For unit 08 — and RED

- **Start from `../c6-unit07/after`** (= `../c6-tiffinbox`): `TiffinBoxServer` is a `final` `@RestController` (never `@Validated` on it:
  brief S2.19) with six request mappings — `@GetMapping` `/customers` (`List<Customer> customers(@RequestParam(required = false)
  MealType mealType)`: `null` or empty → all four), `/customers/{name}` (`Customer customer(@PathVariable String name)`: a name nobody
  has → `ResponseStatusException(HttpStatus.NOT_FOUND, "no customer named " + name)` — Boot's 404 body, no reason, 0 WARN), `/revenue`,
  `/dashboard`, `/kitchen` (`Map<String, Object>`), `@PostMapping("/shutdown")` (`Map<String, Object> shutdown(@RequestHeader(name =
  "X-Shutdown-Token", required = false) String token, HttpServletResponse response)`: no token → `response.setStatus(403)`,
  `{"error":"forbidden"}`; the token → a platform thread closes the context, `{"stopping":true}`). `holdsToken(String)`. Constructor
  unchanged. `CustomerRepository` has `findAll`, **`findByName(String)` → `Optional<Customer>`**, `monthRevenue`, `pausedDays` — **no
  `add` yet** (unit 08's, ⚑9). `GET /customers/{name}` and a `POST /customers` share a path prefix but not a mapping.
- **The seven are unchanged: `87ca7efc8584dcccd40e6b956db1de9b`** (masked; two lines change under the mask), in all four forms. Run
  them first, on a fresh JVM (S2.11): from unit 08 on, a POST moves lines 1-3.
- **Counts, here:** 8 mappings at TRACE (TiffinBox's 6 + Boot's 2), 15 routing-table rows, 28 argument resolvers, 15 return-value
  handlers, 58 libraries, 6 message converters (unit 06's `Converters`, not re-measured here). `POST /customers` makes 9 mappings and 16
  rows — measure them.
- **WARN lines at INFO, measured here:** one per type mismatch (`MethodArgumentTypeMismatchException`), per missing required parameter,
  header, cookie or request attribute; none for `ResponseStatusException`'s 404, a static 404, Tomcat's own 400, the method's 403.
- **The trace hazard (open, for RED):** with every logger at TRACE, the token is in the log twice now — Tomcat's DEBUG request dump
  (since the embedded-Tomcat lesson) and Spring MVC's `HandlerMethod` TRACE `Arguments:` line (since this unit). A request body is a
  parameter too: unit 08's `@RequestBody Customer` will be printed by the same line at TRACE — harmless for a customer, but say so.
  Any receipt that runs TRACE with the demo token dies on `logtok` — use a token of the capture's own, as `trace` does.
- **Harness on the class path:** `javac -parameters` (S2.16); answers on one line; a URL with `;`, `?`, `&`, `{` or `}` single-quoted.
- **Native:** no hint in the tree; Spring's AOT step's metadata names `Customer` and `MealType`; 156-227 s a native build in this unit's
  runs. The image: `tiffinbox-bind:1.0.0` is this unit's name — take your own.
- **The interrupt test** starts the receipts as a terminal starts its foreground job: SIGINT at its default, a process group of its own.
  From a script, `python3 -c 'import os, signal, sys; signal.signal(signal.SIGINT, signal.SIG_DFL); os.setpgrp(); os.execvp(…)'` does
  it; a plain background job ignores SIGINT, and the test proves nothing ("Found on the way").
- **Ports 19360-19369 are this unit's;** 08 has 19370-19379.
- **Not done here:** request bodies (08); Jackson's configuration (09); `ResponseEntity` (10); validation (12); converters (13).
