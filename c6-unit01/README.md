# c6-unit01 — What Happens Between curl and Your Method

Course 6 · Spring Web MVC · Section 1 (The Servlet Layer), its first unit, and the course's · Verified on **JDK 25.0.4.1, Apache
Maven 3.9.16, Spring Boot 4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24), 2026-10-12. The last course ended with TiffinBox
answering HTTP through a server of its own — the JDK's `jdk.httpserver`, with the router Core Java II wrote — and Spring's
routing table empty. This unit puts Spring MVC beside it, on a copy, and asks both servers one question: who called your method?
TiffinBox's own server answers from inside `customers()`; the harness's `@RestController` answers from inside Tomcat. Each answer
is the method's own stack, as the JDK's stack walker shows it, and every frame of it is grouped by a declared filter.

**No anchor change (brief ⚑10).** The tree is `../c5-unit27/after`, reached through the link `anchor` (so no capture prints a unit
folder); `before` checks it against `../c5-tiffinbox` (`diff -rq`: 0 differences). It is read and copied under `.harness/`, never
built in place. **The copy** is the anchor with one file changed, `mvc/tiffinbox-web/pom.xml`: the anchor's web-module POM with one
dependency line added (`spring-boot-starter-webmvc`, on one line) and the Boot plugin's two Jackson 3 `<exclude>`s removed (the
Compose module's stays) — `before` prints its `diff -U0`. The course's anchor, `../c6-tiffinbox`, moves onto Spring MVC's server in
*Embedded Tomcat, Threads and Connectors*; this unit never reads it, and its captures are of the frozen tree they name.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 5 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top; a bare `java` on this Mac is 23.0.1.) No GraalVM, no Docker, no native
build. It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first). Run it from a shell whose
own command line names none of `tiffinbox-web-1.0.0.jar`, `com.tiffinbox.web.TiffinBoxServer` or `plexus-classworlds`: on exit it
stops everything in its process group that does (see "Interrupted"). For the same reason, never start two units' `receipts.sh` as
background jobs of one shell: they share its process group, and each one's clean-up would stop the other's JVMs.

**Runs of record (2026-10-13, after RED's part A — the final script):** **492 s under `./receipts.sh`** (/bin/bash 3.2.57, this
folder, exit 0, all 5 captures = published, every check passed); **417 s under `bash receipts.sh`** (Homebrew bash 5.3.9, the same).
Load averages 4-72 during them: units 02-05 ran beside it. The four captures RED's labels touched (`before`, `toy`, `path`, `log`)
were re-published from a first run of the final script (bash 3.2, every capture 3/3) and have not moved since; `exercise` did not
move. Interrupted with SIGINT while a JVM listened: exit 130, nothing left (below). The sealed clone below is of the 2026-10-12
script (224 s); this round's sealed clone was made of *DispatcherServlet, Opened* (`../c6-unit03`), the unit whose exercise changed.
The exercise as a viewer runs it — one `env -i` bash 3.2 shell started in this folder, `exercise/README.md`'s commands then
SOLUTION.md's line: `frames the stack walker shows: 45 · the bottom frame: java.lang.Thread.run` (exit 0), then the same line
with `42` and `java.lang.VirtualThread.run` (exit 0), the shell in this folder after each, nothing left on 19308 or 19309.

Published hashes: before `36a30f7e93618251909ef92e10153091` · toy `20bfc66db96bd08e0cb971e97898b5ee` · path `8e03c4d0f39af296d76271c6fa63b66a` · log `f62a885e11204680883f28d8892251b9` · exercise `7f0ba47c17612be3e861239cbd2b88f5`
(2026-10-12: before `c67cdf96…`, toy `0892f260…`, path `46a78b2a…`, log `486781dc…` — RED's part A changed their labels and `log`'s cut).

## The repository, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2`), seeded from `../../spring-web-mvc/_research/m2-seed-s1/`
(5,827 files; it holds no `com/tiffinbox/`, brief ⚑17). **Nothing was downloaded** for this unit: every build said `offline: yes`.
The three builds — the copy, the anchor, the toy — are the README's plain `mvn -B package`, made before the captures (on a fresh
clone the first one fills `.m2-demo`); no capture builds anything except the exercise, whose README builds its own copy (offline).
No build runs the profile `native`, so GraalVM's metadata repository is never needed; every build's log is still searched for the
native plugin's two download lines, and the run stops on either. At run time nothing leaves 127.0.0.1.

**From a clone, sealed (2026-10-12, brief S1.1, R.49).** The repository was cloned (`git clone` of the local repository's HEAD,
`74582d7`) into an empty folder, and this unit's eight files put in exactly as they are committed (this README then lacked only the numbers of this
paragraph and of the runs-of-record note) — nothing git ignores: no
`.m2-demo`, no `.harness/`, no `.r-*`. `bash receipts.sh` (Homebrew bash 5.3.9) ran under `env -i`, with a `HOME` whose `.mavenrc`
points Maven's `user.home` there (Java reads `user.home` from the account, not from `$HOME`) and every Java proxy property at a port
that refuses (127.0.0.1:9); Maven settings that send every repository to a `file://` copy of Central's files made from `.m2-demo`
(4,377 files: `_remote.repositories`, `*.lastUpdated`, `resolver-status.properties` and `.DS_Store` left out,
`maven-metadata-central.xml` served as `maven-metadata.xml`); `http_proxy`, `https_proxy`, their capitals and `ALL_PROXY` at the same
refusing port. **Exit 0 after 224 s** — all 5 captures = published, every spoken number asserted, 0 raw demo tokens. The first build,
before the captures, said `offline: no`: 522 artifacts, every one `Downloaded from sealed: file://…` (0 from anywhere else); the
anchor's and the toy's said `offline: yes`, and the exercise's own (its README's `mvn -o`, three times) resolved everything from
`.m2-demo`; `.m2-demo` ended with 1,403 files; the sealed `HOME` ended holding its `.mavenrc` and `.m2/settings.xml` alone; the
run's log names `github` 0 times.

## The demo token — fake, and never printed

TiffinBox does not start without its shutdown token. Every run starts in a folder under `.harness/` that holds a config tree,
`secrets/tiffinbox/shutdown-token` (`-rw-------`, folders `drwx------`), with a 26-character demo token that is fake and looks it.
The token never reaches a command line: the seven requests read it from the file. Every capture is masked, and `receipts.sh` counts
the raw token in each run's own output **before** masking (0 in all 15 capture runs) and in the log of **every JVM that served**
(the token and the header's name `X-Shutdown-Token`, in any case: 0); then in every capture, this README, the exercise's files, the
harness, the copy's POM and `receipts.md5`: 0 each. The exercise makes a token of its own (26 random characters): 0 in its log and
in what it printed, counted on each of its runs. The builder counts the demo token again in the script, the deck and the prompter: 0.

## The folders, the names and the ports

- `anchor` → `../c5-unit27/after` (a link, committed). `mvc/tiffinbox-web/pom.xml` — the copy's one changed file.
  `.harness/anchor/`, `.harness/mvc/`, `.harness/toy/` — the anchor, the copy, and the copy with the toy's line, each with a config
  tree, each built once with the README's plain line; `.harness/hc/` — the harness's classes; `.harness/mine/` — the exercise's.
- **The harness** is `harness/probe/path/Stack.java`: one `@RestController` outside `com.tiffinbox`, joined by
  `--spring.main.sources=probe.path.Stack`, compiled against the copy's own extracted jar (the anchor README's `extract` line). Its
  one route, `GET /probe/stack`, answers with the frames the stack walker shows (the method first, numbered down to 1 at the bottom)
  and then the thread that ran it. **The toy's line** lives in `receipts.sh` (`TOYLINE`) and in `.harness/toy/` only: one line added
  to `customers()` in a copy of `TiffinBoxServer.java`, printing the frames when the JVM runs with `-Dprobe.stack=true`; `toy`
  prints its `diff -U0` hunk. `$CURLSET` = `../c5-unit11/curlset.sh`, the seven requests.
- **Ports (brief ⚑1, 19300-19309):** `before` 19300 (the anchor alone, then the copy's TiffinBox) and 19301 (the copy's Tomcat) ·
  `toy` 19302 / 19303 · `path` 19304 / 19305 · `log` 19306 / 19307 · the exercise 19308 / 19309 (TiffinBox's / Tomcat's). 18425
  (TiffinBox's default) and 8080 (Tomcat's) are checked free and never bound. Nothing listened on 19300-19309 before or after any run.
- **Every server listens on 127.0.0.1 alone**, read off its process after readiness (`listening, read off its process: … · on
  127.0.0.1 alone, each a port of this run: yes`). Boot's started line for Tomcat (logger `o.s.boot.tomcat.TomcatWebServer`, Boot's
  class) names the port only. Tomcat's own connector line names the address too — `Initializing ProtocolHandler
  ["http-nio-127.0.0.1-19301"]` — but Boot's logging defaults set its logger, `org.apache.coyote.http11.Http11NioProtocol`, to WARN,
  so at the default levels it never prints (`before`: C, the same run line with that logger at INFO, shows its two lines; the copy's
  own run shows 0). The request threads' names carry the address as well (`http-nio-127.0.0.1-19305-exec-N`, `path`). The receipts
  read the address off the process. Every run passes Tomcat `--server.address=127.0.0.1 --server.port=…`; a last check fails any
  line of this README, the exercise's files or a capture that gives Tomcat a port without that address.
- **Every JVM is stopped by its process id** (`kill "$pid"`, TERM), waited for, and both its ports checked free; the anchor alone
  is stopped by the seven's POST /shutdown (exit 0). While two servers share a JVM, `before` says which one stopped and whether the
  JVM lived: TiffinBox's port closed, the JVM alive 2 s later, still listening on Tomcat's port.

## The commands — the anchor's lines, and the copy's options

`receipts.sh` reads seven lines from `anchor/README.md` (`readme()`) — `mvn -B package`, the run line, the DEBUG line
(`--logging.level.kitchen=debug`), the web line (`--logging.level.web=debug`), the `extract` line, the class-path line and the
readiness curl line — and the eleven lines below from this README (`ours()`), each asserted to be an anchor line with exactly the
copy's options added: Tomcat's address and port (`--server.address=127.0.0.1 --server.port=18432`); for `before`'s C, one logging
option more (`--logging.level.org.apache.coyote.http11.Http11NioProtocol=info`, Tomcat's own connector logger at INFO); and for the
harness's runs its classes on the class path (`../hc`, beside the copy) and its class joined (`--spring.main.sources=probe.path.Stack`). Ports 18431
(TiffinBox's) and 18432 (Tomcat's) become each run's own. The class-path layout of the harness's runs is the extracted jar plus the
harness's classes (`lib/*` is the JVM's own class-path wildcard).

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --server.address=127.0.0.1 --server.port=18432
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --server.address=127.0.0.1 --server.port=18432 --logging.level.org.apache.coyote.http11.Http11NioProtocol=info
java -Dprobe.stack=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.kitchen=debug --server.address=127.0.0.1 --server.port=18432
java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --server.address=127.0.0.1 --server.port=18432 --spring.main.sources=probe.path.Stack
java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --logging.level.web=debug --server.address=127.0.0.1 --server.port=18432 --spring.main.sources=probe.path.Stack
curl -s http://127.0.0.1:18432/probe/stack
curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:18432/probe/stack
curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:18432/nowhere
curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:18431/customers
curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:18431/nowhere
```

## Masks, filters and hygiene — every one, declared

1. **Paths, the token, threads, hashes, timestamps, the user** (`gsub()`, literals escaped), in every line of every capture, in this
   order: the token → `[masked: the N-character token]`, N its own length (26); this folder → `…`; the folder above → `…/..`; home →
   `~`; a Tomcat request thread's number → `exec-N` / `tomcat-handler-N`; an identity hash (a class name, `@`, five or more hex
   digits) → `@<hash>`; Spring's error timestamp → `"timestamp":"<masked: an ISO-8601 time>"` (its JSON, Jackson 3),
   `"timestamp":<masked: epoch milliseconds>` (the same with Jackson 2), and `timestamp=<masked: a date>` (its DEBUG line); last, the
   user name → `<user>`, as a whole word only (by `index()`), so a short name never eats a word it is part of. A last
   check fails if any capture holds `/Users/`, `/private/`, `/home/`, `/var/folders/`, a unit number, Boot's process line, a log
   time, a thread number, an identity hash, a raw timestamp or a build that went online.
2. **A log line** is printed from its logger on — its time, level, process id and thread cut; TiffinBox's answer lines (logger
   `tiffinbox`, `ROUTE -> STATUS`) from their message on. **Spring's lines at DEBUG** (`log`): every DEBUG line a request added,
   counted, and all of them printed. The lines before A are not shown, and counted, all of them, by where they fall: `log` polls
   readiness on TiffinBox's own port (it answers 200 only once the start has finished, and Boot's started line for Tomcat is
   checked present), so the one request that reaches Tomcat before A is the README's readiness line — 17 lines: 7 while the context
   started, 10 with that request, 5 of them the DispatcherServlet's set-up (between its `Initializing Servlet` and `Completed
   initialization` lines). Each request waits until its lines stop moving for half a second and the last one ends a request
   (`Completed …`, or the end of the ERROR dispatch) — up to 20 s, then it dies. **Labels:** the line that says Tomcat started is
   **Boot's started line** — its logger is Boot's class, `o.s.boot.tomcat.TomcatWebServer`, printed with it — and the shutdown lines
   are **Boot's graceful-shutdown lines** (`o.s.boot.tomcat.GracefulShutdown`).
3. **The frames** (`toy`, `path`, the exercise) are the stack walker's: it hides reflection's own frames (`toy` shows why:
   `handle()` calls `customers()` through `handler.invoke(this)`, and no `Method.invoke` frame appears). They are grouped by
   `GROUPAWK` (in `receipts.sh`): each frame takes the first layer whose rule matches its class — the top frame is **your method**;
   `java.lang.Thread`, `java.lang.VirtualThread`, `java.util.concurrent.*`, `org.apache.tomcat.util.threads.*` → **the thread**;
   `org.apache.tomcat.util.net.*`, `org.apache.coyote.*`, `org.apache.catalina.connector.*` → **the connector**;
   `sun.net.httpserver.ServerImpl$Exchange` → **the JDK server**; `org.apache.catalina.core.Standard*`,
   `org.apache.catalina.valves.*`, `org.apache.catalina.authenticator.*` → **the container**;
   `org.apache.catalina.core.ApplicationFilterChain`, `org.springframework.web.filter.*`,
   `org.apache.tomcat.websocket.server.WsFilter`, `com.sun.net.httpserver.Filter$…`, `sun.net.httpserver.AuthFilter`,
   `sun.net.httpserver.ServerImpl$Exchange$LinkHandler` → **the filter chain** (the filters and the chain's own calls: the JDK's
   `LinkHandler` is not a filter, it is the link that hands the server's own chain on to the user chain); `jakarta.servlet.*`,
   `org.springframework.web.servlet.FrameworkServlet` → **the servlet**; `org.springframework.web.servlet.*`,
   `org.springframework.web.method.*` → **Spring MVC**; `com.tiffinbox.*` → **TiffinBox router**; anything else → unmatched
   (counted: 0, or the checks stop the run). Printed bottom to top, each layer with its classes in the order they first appear
   from the bottom (`×k` when a class shows k frames). "The filters themselves" are the classes whose name ends in `Filter`,
   `OncePerRequestFilter` (the base class Spring's filters share) left out.
4. **TiffinBox's timer** (`toy`) is read from a scrape through the bridge (its `tiffinbox_requests_seconds_count` lines, summed),
   only to know when an answer's DEBUG line is written: after each request the script waits until the timer's total equals the
   count of answer lines and nothing moved for half a second.
5. **No duration is captured.** The one fixed wait a capture names — the JVM checked again 2 s after TiffinBox's port closed — is a
   procedure, not a measurement.
6. **Hygiene:** the last course's loop (`sed -E`, a planted canary under every name, the run stops if one survives) over every
   `TIFFINBOX_*`, `SPRING_*`, `MANAGEMENT_*`, `SERVER_*`, `LOGGING_*` variable, `DEBUG`, `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`,
   `_JAVA_OPTIONS`, `MAVEN_OPTS`, `MAVEN_ARGS`, `NATIVE_IMAGE_OPTIONS` (no Docker here, so no `COMPOSE_*`). `127.0.0.1` and
   `localhost` first in `no_proxy`/`NO_PROXY`. One run at a time (`.r-lock`). No capture reads the process's environment, so macOS's
   `__CF_USER_TEXT_ENCODING` (CoreFoundation writes it into a process's environment) changes nothing here. The scripts and READMEs
   are grepped for an exposure list with a star: none.

**Interrupted.** `receipts.sh`'s exit trap stops the JVM it started in the background (`$pid`) if it still runs, then `sweep()`s
this run's process group — a TiffinBox JVM (the exercise's own included), a Maven build: TERM, then KILL after 5 s — deletes the
capture runs left unfinished (`.r-NAME.1-3`) after an interrupt, and drops the lock. A JVM a non-interactive shell starts in the
background ignores SIGINT, so the trap's TERM is what stops it. **Tested 2026-10-13 on the final script:** `./receipts.sh` as a job
of its own process group (`set -m`), SIGINT sent to the whole group the moment `before`'s C listened on 19301 (4 processes in the
group, 1 of them java): **exit 130, 0.7 s later**; 5 s later 0 processes in its group, 0 java processes running in this folder, 18425,
8080 and 19300-19309 free, no `.r-lock`, 0 unfinished capture files, the five published captures intact (a first try that signalled
between two of `before`'s JVMs, 5 processes and no java, ended the same way: exit 130, nothing left). Tested 2026-10-12 on the
earlier script, once `before`'s first JVM listened on 19300: the same.

**Planted faults** (R.65, S1.19; 2026-10-12), each on a copy of the published captures (or of this README, or the exercise's), the
checks run once on each — every check died on its fault, and every check passed on the published captures: the listen-address line
given a wildcard, `*:19301 127.0.0.1:19300` → `before, the copy: listening on 127.0.0.1 alone`; Spring's timestamp left raw in each of
its three forms (ISO-8601, epoch milliseconds, the DEBUG line's date) → `holds Spring's error timestamp, unmasked`, three times; A′'s
last line changed → `log: A' is not A's lines`; C given a DEBUG line → `toy C: no line`; a reflection frame in the toy's stack →
`a reflection frame shows`; a frame no rule took → `path: … frames no rule took: 0`; Boot naming the key once → `exercise: Boot silent
about the misspelt key`; the JVM `gone` after POST /shutdown → `before: TiffinBox's server stopped, the JVM lived`; the demo token
appended raw → `holds the demo token, raw`; `exec-7` → `holds a thread number or an identity hash`, and `Translator@407db139` the same;
a line of this README giving Tomcat a port without its address → `starts Tomcat without --server.address=127.0.0.1`; the seven's md5
changed by one digit → `before: the copy's seven`; 13 jars more → `before: expected …`; the exercise README's Done line changed →
`Done names no such line`. **The live functions too:** `addrs()` given planted listener lists — `*:19301 127.0.0.1:19300` → `…: no`;
`127.0.0.1:8080` beside the run's port → `…: no`; the run's two loopback ports → `…: yes`; `mask()` given raw lines — both JSON
timestamps, the DEBUG date, `exec-12`, `tomcat-handler-3`, an identity hash, the token, the paths and a short user name — masked each,
`openjdk@25` left alone, the same bytes under both bashes. **2026-10-13, the checks RED's part A added**, each on a copy of a published
capture, the checks alone run once on each (`receipts.sh` with its builds and captures taken out), every one died on its fault and
all passed on the published captures, restored byte for byte: C's `Initializing ProtocolHandler` line removed → `before C: Tomcat's
connector line names the address`; Boot's default for that logger given as INFO → `before C: Boot's default level for Tomcat's
connector logger`; two connector lines at the default levels → `before: Tomcat's connector lines hidden at Boot's default levels`;
the started line's logger made Tomcat's (`o.a.catalina.startup.Tomcat`) → `toy: Boot's started line`; the old label "Tomcat's own
lines on the way out" → `path: stopped by its process id, Boot's graceful-shutdown lines`; the cut before A counted 18 → `log:
expected /… counted: 17 …/`; the readiness line on TiffinBox's port, not Tomcat's → `log: the README's readiness line, run once on
Tomcat's port`; the toy's layer named "the filters" again → `toy: expected /…the filter chain…/`.

## 1 · before — where the last course left it, and the copy

The anchor alone: the README's run line, readiness, its one listener, the seven — `115c36ba…`, exit 0. Then the copy: one file
differs, its `diff -U0` (+1 line, the two excludes −8), the jars each executable jar carries (46 → 58: 12 only in the copy's — Tomcat's
two, Jackson 3's two, Spring Framework's web two, Boot's six). **C (labelled):** the copy's run line with one logging option more,
Tomcat's own connector logger at INFO — its two lines, `Initializing ProtocolHandler ["http-nio-127.0.0.1-19301"]` and `Starting …`,
name the address; Boot's logging defaults set that logger to WARN (the line from `spring-boot-4.1.1.jar`). Then the copy's run line
at the default levels: two servers in one JVM, `127.0.0.1:19300` and `127.0.0.1:19301` read off the process, TiffinBox's own line and
Boot's started line (the port only), 0 connector lines; the seven on TiffinBox's port, `115c36ba…` again; then which server stopped
— TiffinBox's port 0 — and that the JVM lived, still listening on Tomcat's port, so it is stopped by its process id: exit 143 (TERM),
Boot's two graceful-shutdown lines, both ports free.

```
where the last course left it - the anchor, TiffinBox's own server alone: the README's run line, from .harness/anchor, port 19300:
$ cd .harness/anchor && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19300
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19300/actuator/health/readiness
  {"status":"UP"} 200
  listening, read off its process: 127.0.0.1:19300 · on 127.0.0.1 alone, each a port of this run: yes
  TiffinBox's own line (19300): TiffinBox listening on http://127.0.0.1:19300
$ $CURLSET 19300 .harness/anchor/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times · WARN lines 0 · ERROR lines 0
the anchor against the last course's own anchor, ../c5-tiffinbox (diff -rq; target/, secrets/, .m2-demo/ and .harness/ left out): 0 differences
the copy - Spring MVC beside TiffinBox's server - against the anchor (diff -rq, target/ and secrets/ left out):
  differs: tiffinbox-web/pom.xml
$ diff -U0 anchor/tiffinbox-web/pom.xml mvc/tiffinbox-web/pom.xml
  @@ -61,0 +62 @@
  +    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-webmvc</artifactId></dependency>
  @@ -85,8 +85,0 @@
  -            <exclude>
  -              <groupId>tools.jackson.core</groupId>
  -              <artifactId>jackson-databind</artifactId>
  -            </exclude>
  -            <exclude>
  -              <groupId>tools.jackson.core</groupId>
  -              <artifactId>jackson-core</artifactId>
  -            </exclude>
the jars each executable jar carries (BOOT-INF/lib):
  the anchor's: 46 · the copy's: 58 · only in the copy's: 12 · only in the anchor's: 0
    + jackson-core-3.1.5.jar
    + jackson-databind-3.1.5.jar
    + spring-boot-http-converter-4.1.1.jar
    + spring-boot-jackson-4.1.1.jar
    + spring-boot-servlet-4.1.1.jar
    + spring-boot-tomcat-4.1.1.jar
    + spring-boot-web-server-4.1.1.jar
    + spring-boot-webmvc-4.1.1.jar
    + spring-web-7.0.9.jar
    + spring-webmvc-7.0.9.jar
    + tomcat-embed-core-11.0.24.jar
    + tomcat-embed-websocket-11.0.24.jar
C (labelled) - the copy's run line with Tomcat's own connector logger at INFO (README.md: one logging option added), from .harness/mvc, ports 19300 and 19301:
$ cd .harness/mvc && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19300 --server.address=127.0.0.1 --server.port=19301 --logging.level.org.apache.coyote.http11.Http11NioProtocol=info
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19301/actuator/health/readiness
  {"status":"UP"} 200
  listening, read off its process: 127.0.0.1:19300 127.0.0.1:19301 · on 127.0.0.1 alone, each a port of this run: yes
  TiffinBox's own line (19300): TiffinBox listening on http://127.0.0.1:19300
  Boot's started line (19301) - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19301 (http) with context path '/'
  Tomcat's own connector lines, before the stop - logger: message:
    o.a.coyote.http11.Http11NioProtocol: Initializing ProtocolHandler ["http-nio-127.0.0.1-19301"]
    o.a.coyote.http11.Http11NioProtocol: Starting ProtocolHandler ["http-nio-127.0.0.1-19301"]
  Boot's logging defaults for that logger (spring-boot-4.1.1.jar, org/springframework/boot/logging/logback/defaults.xml): <logger name="org.apache.coyote.http11.Http11NioProtocol" level="WARN"/>
$ kill "$pid"    # TERM, by its process id
  exit 143 · Boot's graceful-shutdown lines (o.s.boot.tomcat.GracefulShutdown): Commencing graceful shutdown. Waiting for active requests to complete · Graceful shutdown complete
  listening now: 19300 0 · 19301 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times · WARN lines 0 · ERROR lines 0
the copy, two servers in one JVM - the copy's run line (README.md: the anchor's, Tomcat's address and port added), from .harness/mvc, ports 19300 and 19301:
$ cd .harness/mvc && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19300 --server.address=127.0.0.1 --server.port=19301
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19301/actuator/health/readiness
  {"status":"UP"} 200
  listening, read off its process: 127.0.0.1:19300 127.0.0.1:19301 · on 127.0.0.1 alone, each a port of this run: yes
  TiffinBox's own line (19300): TiffinBox listening on http://127.0.0.1:19300
  Boot's started line (19301) - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19301 (http) with context path '/'
  Tomcat's own connector lines in this log, at Boot's default levels: 0
the seven, on TiffinBox's own port:
$ $CURLSET 19300 .harness/mvc/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  after POST /shutdown: TiffinBox's port 19300, listening: 0 · the JVM, 2 s later: alive · it listens on: 127.0.0.1:19301
$ kill "$pid"    # TERM, by its process id
  exit 143 · Boot's graceful-shutdown lines (o.s.boot.tomcat.GracefulShutdown): Commencing graceful shutdown. Waiting for active requests to complete · Graceful shutdown complete
  listening now: 19300 0 · 19301 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times · WARN lines 0 · ERROR lines 0
```

## 2 · toy — TiffinBox's own server, asked who called customers()

One line added to `customers()` in a copy (its hunk first); `GET /customers` on TiffinBox's port → 11 frames, `VirtualThread.run`
at the bottom (TiffinBox's executor gives each request a virtual thread), the JDK's server and its own filter chain (one filter,
`AuthFilter`; the chain's link, `LinkHandler`; three `Filter$Chain` frames), TiffinBox's router (`lambda$start$0`, `handle`), the method. **C (labelled):**
`GET /nowhere` on the same port → the JDK's HTML 404 and 0 TiffinBox lines at DEBUG: TiffinBox's router never ran.

```
the toy path - the copy again, with one line added to TiffinBox's customers() (diff -U0, the anchor's file against the toy's):
$ diff -U0 anchor/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java .harness/toy/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
  @@ -106,0 +107 @@
  +        if (Boolean.getBoolean("probe.stack")) StackWalker.getInstance().forEach(f -> System.out.println("probe: " + f.getClassName() + "." + f.getMethodName()));
$ cd .harness/toy && java -Dprobe.stack=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19302 --logging.level.kitchen=debug --server.address=127.0.0.1 --server.port=19303
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19303/actuator/health/readiness
  {"status":"UP"} 200
  listening, read off its process: 127.0.0.1:19302 127.0.0.1:19303 · on 127.0.0.1 alone, each a port of this run: yes
  TiffinBox's own line (19302): TiffinBox listening on http://127.0.0.1:19302
  Boot's started line (19303) - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19303 (http) with context path '/'
GET /customers on TiffinBox's own port - the method its router calls:
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19302/customers
  200 application/json
  the frames the stack walker shows, printed by the line in customers(): 11
  11 com.tiffinbox.web.TiffinBoxServer.customers
  10 com.tiffinbox.web.TiffinBoxServer.handle
   9 com.tiffinbox.web.TiffinBoxServer.lambda$start$0
   8 com.sun.net.httpserver.Filter$Chain.doFilter
   7 sun.net.httpserver.AuthFilter.doFilter
   6 com.sun.net.httpserver.Filter$Chain.doFilter
   5 sun.net.httpserver.ServerImpl$Exchange$LinkHandler.handle
   4 com.sun.net.httpserver.Filter$Chain.doFilter
   3 sun.net.httpserver.ServerImpl$Exchange.run
   2 java.util.concurrent.ThreadPerTaskExecutor$TaskRunner.run
   1 java.lang.VirtualThread.run
  bottom to top, grouped by the README's filter - frames · layer · classes:
   2  the thread       VirtualThread · ThreadPerTaskExecutor$TaskRunner
   1  the JDK server   ServerImpl$Exchange
   5  the filter chain Filter$Chain ×3 · ServerImpl$Exchange$LinkHandler · AuthFilter
   2  TiffinBox router TiffinBoxServer ×2
   1  your method      TiffinBoxServer.customers
  11  in all · frames no rule took: 0
  how handle() calls the method - the anchor's TiffinBoxServer.java, line 182: respond(exchange, 200, handler.invoke(this)); - reflection (Method.invoke): no frame of it above, the stack walker hides reflection's own
  TiffinBox's lines at DEBUG it added: 1
    GET /customers -> 200
C (labelled) - GET /nowhere on TiffinBox's own port, a path no route declares:
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19302/nowhere
  <h1>404 Not Found</h1>No context found for request 404 text/html
  TiffinBox's lines at DEBUG it added: 0
  the line in customers() printed, in all: 11 frames
$ kill "$pid"    # TERM, by its process id
  exit 143 · Boot's graceful-shutdown lines (o.s.boot.tomcat.GracefulShutdown): Commencing graceful shutdown. Waiting for active requests to complete · Graceful shutdown complete
  listening now: 19302 0 · 19303 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times · WARN lines 0 · ERROR lines 0
```

## 3 · path — the harness's method on Tomcat, asked the same question

The harness's route on Tomcat's port → 45 frames on `http-nio-127.0.0.1-19305-exec-N`, not virtual: the thread 4 · the connector 6 ·
the container 6 · the filter chain 15 (five filters: four of Spring's — `CharacterEncodingFilter`, `ServerHttpObservationFilter`,
`FormContentFilter`, `RequestContextFilter` — and Tomcat's `WsFilter`, each wrapped in `ApplicationFilterChain.doFilter`) · the
servlet 5 · Spring MVC 8 · your method 1; no frame unmatched. Tomcat's context log names the servlet at the first request (readiness's):
`Initializing Spring DispatcherServlet 'dispatcherServlet'` (INFO, the README's default level).

```
the industrial path - the harness's @RestController (probe.path.Stack, outside com.tiffinbox) on Tomcat's port; the class path: the extracted jar plus the harness's classes (README.md):
$ cd .harness/mvc && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19304 --server.address=127.0.0.1 --server.port=19305 --spring.main.sources=probe.path.Stack
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19305/actuator/health/readiness
  {"status":"UP"} 200
  listening, read off its process: 127.0.0.1:19304 127.0.0.1:19305 · on 127.0.0.1 alone, each a port of this run: yes
  TiffinBox's own line (19304): TiffinBox listening on http://127.0.0.1:19304
  Boot's started line (19305) - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19305 (http) with context path '/'
  its log at INFO, from the first request on Tomcat's port (readiness's) - logger: message: o.a.c.c.C.[Tomcat].[localhost].[/]: Initializing Spring DispatcherServlet 'dispatcherServlet'
$ curl -s http://127.0.0.1:19305/probe/stack
  frames the stack walker shows: 45
  45 probe.path.Stack.frames
  44 org.springframework.web.method.support.InvocableHandlerMethod.doInvoke
  43 org.springframework.web.method.support.InvocableHandlerMethod.invokeForRequest
  42 org.springframework.web.servlet.mvc.method.annotation.ServletInvocableHandlerMethod.invokeAndHandle
  41 org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.invokeHandlerMethod
  40 org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.handleInternal
  39 org.springframework.web.servlet.mvc.method.AbstractHandlerMethodAdapter.handle
  38 org.springframework.web.servlet.DispatcherServlet.doDispatch
  37 org.springframework.web.servlet.DispatcherServlet.doService
  36 org.springframework.web.servlet.FrameworkServlet.processRequest
  35 org.springframework.web.servlet.FrameworkServlet.doGet
  34 jakarta.servlet.http.HttpServlet.service
  33 org.springframework.web.servlet.FrameworkServlet.service
  32 jakarta.servlet.http.HttpServlet.service
  31 org.apache.catalina.core.ApplicationFilterChain.doFilter
  30 org.apache.tomcat.websocket.server.WsFilter.doFilter
  29 org.apache.catalina.core.ApplicationFilterChain.doFilter
  28 org.springframework.web.filter.RequestContextFilter.doFilterInternal
  27 org.springframework.web.filter.OncePerRequestFilter.doFilter
  26 org.apache.catalina.core.ApplicationFilterChain.doFilter
  25 org.springframework.web.filter.FormContentFilter.doFilterInternal
  24 org.springframework.web.filter.OncePerRequestFilter.doFilter
  23 org.apache.catalina.core.ApplicationFilterChain.doFilter
  22 org.springframework.web.filter.ServerHttpObservationFilter.doFilterInternal
  21 org.springframework.web.filter.OncePerRequestFilter.doFilter
  20 org.apache.catalina.core.ApplicationFilterChain.doFilter
  19 org.springframework.web.filter.CharacterEncodingFilter.doFilterInternal
  18 org.springframework.web.filter.OncePerRequestFilter.doFilter
  17 org.apache.catalina.core.ApplicationFilterChain.doFilter
  16 org.apache.catalina.core.StandardWrapperValve.invoke
  15 org.apache.catalina.core.StandardContextValve.invoke
  14 org.apache.catalina.authenticator.AuthenticatorBase.invoke
  13 org.apache.catalina.core.StandardHostValve.invoke
  12 org.apache.catalina.valves.ErrorReportValve.invoke
  11 org.apache.catalina.core.StandardEngineValve.invoke
  10 org.apache.catalina.connector.CoyoteAdapter.service
   9 org.apache.coyote.http11.Http11Processor.service
   8 org.apache.coyote.AbstractProcessorLight.process
   7 org.apache.coyote.AbstractProtocol$ConnectionHandler.process
   6 org.apache.tomcat.util.net.NioEndpoint$SocketProcessor.doRun
   5 org.apache.tomcat.util.net.SocketProcessorBase.run
   4 org.apache.tomcat.util.threads.ThreadPoolExecutor.runWorker
   3 org.apache.tomcat.util.threads.ThreadPoolExecutor$Worker.run
   2 org.apache.tomcat.util.threads.TaskThread$WrappingRunnable.run
   1 java.lang.Thread.run
  thread http-nio-127.0.0.1-19305-exec-N · virtual false
  bottom to top, grouped by the README's filter - frames · layer · classes:
   4  the thread       Thread · TaskThread$WrappingRunnable · ThreadPoolExecutor$Worker · ThreadPoolExecutor
   6  the connector    SocketProcessorBase · NioEndpoint$SocketProcessor · AbstractProtocol$ConnectionHandler · AbstractProcessorLight · Http11Processor · CoyoteAdapter
   6  the container    StandardEngineValve · ErrorReportValve · StandardHostValve · AuthenticatorBase · StandardContextValve · StandardWrapperValve
  15  the filter chain ApplicationFilterChain ×6 · OncePerRequestFilter ×4 · CharacterEncodingFilter · ServerHttpObservationFilter · FormContentFilter · RequestContextFilter · WsFilter
   5  the servlet      HttpServlet ×2 · FrameworkServlet ×3
   8  Spring MVC       DispatcherServlet ×2 · AbstractHandlerMethodAdapter · RequestMappingHandlerAdapter ×2 · ServletInvocableHandlerMethod · InvocableHandlerMethod ×2
   1  your method      Stack.frames
  45  in all · frames no rule took: 0
  the filters themselves - each class whose name ends in Filter, bottom to top (OncePerRequestFilter, the base class Spring's filters share, left out): 5 - Spring: CharacterEncodingFilter · Spring: ServerHttpObservationFilter · Spring: FormContentFilter · Spring: RequestContextFilter · Tomcat: WsFilter
$ kill "$pid"    # TERM, by its process id
  exit 143 · Boot's graceful-shutdown lines (o.s.boot.tomcat.GracefulShutdown): Commencing graceful shutdown. Waiting for active requests to complete · Graceful shutdown complete
  listening now: 19304 0 · 19305 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times · WARN lines 0 · ERROR lines 0
```

## 4 · log — the path in Spring's own words

The anchor README's web line (Boot's log group `web` at DEBUG) on the copy, with the harness; readiness polled on TiffinBox's own port,
then the README's readiness line once on Tomcat's — the 17 lines at DEBUG before A counted, not shown. **A** `GET /probe/stack` → 200, 5 lines:
the request, `Mapped to probe.path.Stack#frames()` (the handler mapping), the two lines that write the answer, `Completed 200 OK`.
**B** `GET /nowhere`, a path nobody declared → Spring's JSON 404 (its timestamp masked), 10 lines: the static-resource handler
takes it (`Mapped to ResourceHttpRequestHandler […]`), finds no file, `NoResourceFoundException` (resolved by
`DefaultHandlerExceptionResolver`), `Completed 404 NOT_FOUND`; then the request comes back through the DispatcherServlet — `"ERROR"
dispatch for GET "/error"` — to Boot's `BasicErrorController#error`, which writes the body. (Who sends it back — the container, on
the 404 status — is not captured here; *Boot's Default Error Response* opens that path.) **A′** — A's `$` command again: the same 5 lines.

```
the anchor README's web line (Boot's log group web at DEBUG) on the copy, with the harness - README.md, ports 19306 and 19307:
$ cd .harness/mvc && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19306 --logging.level.web=debug --server.address=127.0.0.1 --server.port=19307 --spring.main.sources=probe.path.Stack
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19307/actuator/health/readiness
  {"status":"UP"} 200
  listening, read off its process: 127.0.0.1:19306 127.0.0.1:19307 · on 127.0.0.1 alone, each a port of this run: yes
  TiffinBox's own line (19306): TiffinBox listening on http://127.0.0.1:19306
  Boot's started line (19307) - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19307 (http) with context path '/'
  Spring's lines at DEBUG before A, not shown - counted: 17 · 7 while the context started, before Boot's started line · 10 with the README's readiness request, the first to reach Tomcat - 5 of them the DispatcherServlet's set-up, between its Initializing Servlet and Completed initialization lines
A - GET /probe/stack on Tomcat's port, the harness's route:
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19307/probe/stack
  200 text/plain;charset=UTF-8
  its lines at DEBUG: 5
    o.s.web.servlet.DispatcherServlet: GET "/probe/stack", parameters={}
    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to probe.path.Stack#frames()
    m.m.a.RequestResponseBodyMethodProcessor: Using 'text/plain', given [*/*] and supported [text/plain, */*, application/json, application/*+json]
    m.m.a.RequestResponseBodyMethodProcessor: Writing ["frames the stack walker shows: 45<EOL>45 probe.path.Stack.frames<EOL>44 org.springframework.web.method.suppo (truncated)..."]
    o.s.web.servlet.DispatcherServlet: Completed 200 OK
B - GET /nowhere on Tomcat's port, a path nobody declared:
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19307/nowhere
  {"timestamp":"<masked: an ISO-8601 time>","status":404,"error":"Not Found","path":"/nowhere"} 404 application/json
  its lines at DEBUG: 10
    o.s.web.servlet.DispatcherServlet: GET "/nowhere", parameters={}
    o.s.w.s.handler.SimpleUrlHandlerMapping: Mapped to ResourceHttpRequestHandler [classpath [META-INF/resources/], classpath [resources/], classpath [static/], classpath [public/], ServletContext [/]]
    o.s.w.s.r.ResourceHttpRequestHandler: Resource not found for path [nowhere]
    .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.servlet.resource.NoResourceFoundException: No static resource nowhere for request '/nowhere'.]
    o.s.web.servlet.DispatcherServlet: Completed 404 NOT_FOUND
    o.s.web.servlet.DispatcherServlet: "ERROR" dispatch for GET "/error", parameters={}
    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to org.springframework.boot.webmvc.autoconfigure.error.BasicErrorController#error(HttpServletRequest)
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Writing [{timestamp=<masked: a date>, status=404, error=Not Found, path=/nowhere}]
    o.s.web.servlet.DispatcherServlet: Exiting from "ERROR" dispatch, status 404
A' - A again:
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19307/probe/stack
  200 text/plain;charset=UTF-8
  its lines at DEBUG: 5
    o.s.web.servlet.DispatcherServlet: GET "/probe/stack", parameters={}
    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to probe.path.Stack#frames()
    m.m.a.RequestResponseBodyMethodProcessor: Using 'text/plain', given [*/*] and supported [text/plain, */*, application/json, application/*+json]
    m.m.a.RequestResponseBodyMethodProcessor: Writing ["frames the stack walker shows: 45<EOL>45 probe.path.Stack.frames<EOL>44 org.springframework.web.method.suppo (truncated)..."]
    o.s.web.servlet.DispatcherServlet: Completed 200 OK
$ kill "$pid"    # TERM, by its process id
  exit 143 · Boot's graceful-shutdown lines (o.s.boot.tomcat.GracefulShutdown): Commencing graceful shutdown. Waiting for active requests to complete · Graceful shutdown complete
  listening now: 19306 0 · 19307 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times · WARN lines 0 · ERROR lines 0
```

## 5 · exercise — the README's commands, as written; the solution; A again

`exercise/README.md`'s commands, run exactly as written from this folder: the copy built in `.harness/mine`, started with the
harness and `--spring.threads.virtual.enable=true` (misspelt, as shipped) → 45 frames, `Thread.run` at the bottom, and its log at
INFO holds 0 lines that name the key, 0 WARN, 0 ERROR (RE-MEASURE 10: "silently", settled). The solution's line
(`spring.threads.virtual.enabled`) → 42 frames, `VirtualThread.run`: 4 frames left (`Thread.run`,
`TaskThread$WrappingRunnable.run`, `ThreadPoolExecutor$Worker.run`, `ThreadPoolExecutor.runWorker`), 1 came, 41 the same. A′ — the
README's run line again → 45.

```
A - exercise/README.md's commands, run exactly as written from this folder - 8 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/mvc/ && cp mvc/tiffinbox-web/pom.xml .harness/mine/mvc/tiffinbox-web/pom.xml
  $ mkdir -p .harness/mine/mvc/secrets/tiffinbox && chmod 700 .harness/mine/mvc/secrets .harness/mine/mvc/secrets/tiffinbox
  $ (umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/mvc/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/mvc && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null)
  $ javac -d .harness/mine/hc -cp ".harness/mine/mvc/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/mine/mvc/tiffinbox-web/target/extracted/lib/*" harness/probe/path/Stack.java
  $ (cd .harness/mine/mvc && exec java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19308 --server.address=127.0.0.1 --server.port=19309 --spring.main.sources=probe.path.Stack --spring.threads.virtual.enable=true > run.log 2>&1) & p=$!; for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19309/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done; curl -s http://127.0.0.1:19309/probe/stack > .harness/mine/stack.txt; kill $p; wait $p; awk 'NR == 1 { f = $0 } $1 == 1 { b = $2 } END { print f " · the bottom frame: " b }' .harness/mine/stack.txt
  exit 0 · printed:
    frames the stack walker shows: 45 · the bottom frame: java.lang.Thread.run
  its log (.harness/mine/mvc/run.log): lines that name spring.threads.virtual.enable 0 · WARN lines 0 · ERROR lines 0 · Tomcat started 1 · TiffinBox listening 1
  listening now: 19308 0 · 19309 0
B - the solution's line (exercise/solution/SOLUTION.md), run exactly as written, from this folder:
$ (cd .harness/mine/mvc && exec java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19308 --server.address=127.0.0.1 --server.port=19309 --spring.main.sources=probe.path.Stack --spring.threads.virtual.enabled=true > run.log 2>&1) & p=$!; for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19309/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done; curl -s http://127.0.0.1:19309/probe/stack > .harness/mine/stack.txt; kill $p; wait $p; awk 'NR == 1 { f = $0 } $1 == 1 { b = $2 } END { print f " · the bottom frame: " b }' .harness/mine/stack.txt
  exit 0 · printed:
    frames the stack walker shows: 42 · the bottom frame: java.lang.VirtualThread.run
  its log (.harness/mine/mvc/run.log): lines that name spring.threads.virtual.enable 0 · WARN lines 0 · ERROR lines 0 · Tomcat started 1 · TiffinBox listening 1
  listening now: 19308 0 · 19309 0
  A's frames against B's: the frames that left 4 · the frames that came 1 · the rest, the same: 41
    left: java.lang.Thread.run
    left: org.apache.tomcat.util.threads.TaskThread$WrappingRunnable.run
    left: org.apache.tomcat.util.threads.ThreadPoolExecutor$Worker.run
    left: org.apache.tomcat.util.threads.ThreadPoolExecutor.runWorker
    came: java.lang.VirtualThread.run
A' - A again: the README's run line, as written:
$ (cd .harness/mine/mvc && exec java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19308 --server.address=127.0.0.1 --server.port=19309 --spring.main.sources=probe.path.Stack --spring.threads.virtual.enable=true > run.log 2>&1) & p=$!; for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19309/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done; curl -s http://127.0.0.1:19309/probe/stack > .harness/mine/stack.txt; kill $p; wait $p; awk 'NR == 1 { f = $0 } $1 == 1 { b = $2 } END { print f " · the bottom frame: " b }' .harness/mine/stack.txt
  exit 0 · printed:
    frames the stack walker shows: 45 · the bottom frame: java.lang.Thread.run
  its log (.harness/mine/mvc/run.log): lines that name spring.threads.virtual.enable 0 · WARN lines 0 · ERROR lines 0 · Tomcat started 1 · TiffinBox listening 1
  listening now: 19308 0 · 19309 0
  the exercise's own token (26 random characters, its config tree's): in its log 0 times · in what it printed 0 times
```

## Exercise

`exercise/README.md` (the task, shipped broken: the option is misspelt and Boot says nothing) and `exercise/solution/SOLUTION.md`
(the one word mended, and the measured line). Done = `frames the stack walker shows: 42 · the bottom frame:
java.lang.VirtualThread.run`, a line of the `exercise` capture; the README's commands and the solution's line run exactly as written.

## Found on the way

- **RED's part A, 2026-10-13 — the labels were Tomcat's where the lines are Boot's.** The line that says Tomcat started is logged by
  Boot's `TomcatWebServer`, and the shutdown lines by Boot's `GracefulShutdown`; the captures now say "Boot's started line" and
  "Boot's graceful-shutdown lines", each with its logger. Tomcat's own connector line names the address — `before`'s C shows it at
  INFO — and Boot's logging defaults set its logger to WARN, so the default run shows 0 of it: the address is read off the process,
  and Tomcat's thread names carry it too (`path`). "The process is the only witness" was wrong, and is gone.
- **A cut that moved.** `log` polled readiness on Tomcat's port, so the lines Spring logged before A were as many as the polls that
  reached Tomcat (RED counted 42 at DEBUG, 20 shown): not a count, and not bounded. `log` alone now polls TiffinBox's own port — it
  answers 200 only once the start has finished, and Boot's started line is checked present — and asks Tomcat once, with the README's
  readiness line: 17 lines before A, 3 of 3 (the brief's S1.13 polls Tomcat's port; that rule's reason, a 503 from TiffinBox's port
  before Tomcat started, is met by polling until 200 and checking the line).
- **`LinkHandler` is not a filter.** The JDK's server runs its own filter chain, then hands it on to the user chain through
  `ServerImpl$Exchange$LinkHandler`; the toy's chain holds one filter, `AuthFilter`. The layer is now "the filter chain" in both
  stacks (the voice already said "its own small filter chain" and "the filter chain").
- **Two receipts, one shell.** Started as two background jobs of one shell, two units' `receipts.sh` share a process group, and the
  first to finish would stop the other's JVMs in its clean-up. Each runs from its own shell (or its own process group).

- **A thread's number moved a hash.** Spring's DEBUG line for A quotes the first 100 characters of the answer. The harness first
  printed its thread first, and `exec-9` against `exec-10` moved the cut by one character — `log` drifted across three runs. The
  harness now prints its thread last; the 100 characters it quotes are frames only.
- **Two masks that were too wide.** The identity-hash mask first took any `@` and hex digits after a word character, and turned the
  exercise's `openjdk@25` into `openjdk@<hash>`; it now needs five or more hex digits (a JVM identity hash has up to eight). And the
  user-name mask (the last course's `gsub`) replaced the name anywhere in a line: planted with a short name, `me`, it turned
  `timestamp` into `ti<user>stamp` before the timestamp mask could see it. It now runs last and takes whole words only. With this
  Mac's user name, no published capture moved (each re-masked: the same md5).
- **The clean-up's reach.** `sweep()` stops anything in the script's process group whose command line names the jar, TiffinBox's
  main class or Maven's launcher — a first run here, started from a shell whose own command text held those names, stopped that
  shell too. Hence the note at the top: run it from a plain command line.
- **The brief's counts, against this run.** Filters: five in all — four of Spring's and Tomcat's `WsFilter` (the brief's "5
  Spring/Boot filters plus Tomcat's" counted Tomcat's twice; the probe's own list names five). A's DEBUG lines at the web group: 5,
  not 3 — the harness answers a `String`, so the two lines that write it appear (the probe's 3 were a TiffinBox route's, through
  `HttpRequestHandlerAdapter`, which writes no line). The DispatcherServlet's frames: 8, plus your method 1 (the probe's "9 Spring MVC
  frames" counted the method in).
- **RE-MEASURE 10, settled:** the misspelt key — 45 frames, and not a line from Boot at INFO (0 naming it, 0 WARN, 0 ERROR).

## For RED (part A)

Re-test the sealed clone, SIGINT and both bashes; the listen-address assertion and the masks (both shown failing above); the survivor
(`before`: TiffinBox's port closed, the JVM alive, stopped by pid, exit 143); A′ = A (`log`, `exercise`). Every voice line about
Tomcat or Spring has its capture: the 45, the layers, the filters, the DispatcherServlet's name in Tomcat's log, the ERROR dispatch.
What this unit does **not** claim: anything about TiffinBox's routes on Spring MVC (the embedded-Tomcat lesson's), Tomcat's default
bind address (the same lesson's labelled break), the thread that keeps the JVM alive (*Servlets, Filters and the Container*), any
duration.
