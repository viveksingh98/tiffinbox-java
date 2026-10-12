# c6-unit03 — DispatcherServlet, Opened

Course 6 · Spring Web MVC · Section 1 · The Servlet Layer · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**
(Spring Framework 7.0.9, Tomcat 11.0.24), 2026-10-12, on an Apple M1 (8 cores, 16 GB) under macOS. In Core Java II you wrote a
router: an annotation (`@Route`), a scan (`scanRoutes()`, by reflection), a `TreeMap` keyed "VERB path", and `Method.invoke` per
request. Spring MVC's `DispatcherServlet` does the same jobs — find the handler, call it, write the answer — through lists of
strategies. This unit opens a running one and reads its lists beside yours, **in one JVM**: TiffinBox's own server (the JDK's) on
one port, Tomcat with Spring MVC on another, both on `127.0.0.1`.

**No anchor change (brief ⚑10).** The tree is `../c5-unit27/after` — the last course's final tree — reached through the link
`anchor` (so no capture prints a unit folder). It is read and **copied** under `.harness/`, never built in place. The copy changes in
one file, its web module's POM, by a program in `receipts.sh` (`webmvc()`), printed as a `diff -U0` in `toy`: Spring MVC's starter
added (`spring-boot-starter-webmvc`, one line), and the Boot plugin's two `tools.jackson.core` `<exclude>`s dropped (the Compose
module's exclude and the native plugin's three exclusions stay). A second copy, `.harness/kept`, adds the starter only and keeps
the excludes: `converters` C. Before anything else `receipts.sh` checks that `anchor/` and `../c5-tiffinbox` hold the same files
(`diff -rq`, build output and secrets aside): both are frozen. Once the anchor moves onto Tomcat (the lesson *Embedded Tomcat,
Threads and Connectors*), this unit still measures the tree it names, and `receipts.sh` says so in the terminal: the anchor has
moved past this tree.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 6 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

**Runs of record (2026-10-12, on the final script; load averages 100-140 — another unit's native build and the other units'
evidence ran alongside):**
- **`./receipts.sh` (/bin/bash 3.2.57): exit 0 after 6 min 9 s** — all 6 captures 3/3 and = published, every check passed.
- **`bash receipts.sh` (Homebrew bash 5.3.9): exit 0 after 4 min 57 s** — the same.
- **From a sealed fresh clone (bash 5.3.9): exit 0 after 3 min 48 s** — all 6 = published, every check passed. The repository was
  cloned (`git clone` of the local repository at `74582d7`) into an empty folder, and this unit's files put in as they are
  committed (nothing git ignores: no `.m2-demo`, no `.harness/`, no `.r-*`). `bash receipts.sh` ran under `env -i`, with a `HOME`
  holding only `.mavenrc` — `-Duser.home` pointed there (Java reads `user.home` from the account, not from `$HOME`) and every Java
  proxy property at a port that refuses (127.0.0.1:9) — and `.m2/settings.xml`, which sends every repository to a `file://` copy of
  Central's files made from `.m2-demo` (4,364 files: TiffinBox's own installs, `_remote.repositories`, `*.lastUpdated`,
  `resolver-status.properties` and `.DS_Store` left out, `maven-metadata-central.xml` served as `maven-metadata.xml`); `http_proxy`,
  `https_proxy`, their capitals and `ALL_PROXY` at the same refusing port. The first build said `offline: no` and took **522
  artifacts, every one `Downloaded from sealed: file://…`, 0 from anywhere else**; the second said `offline: yes`; `.m2-demo` ended
  with 1,403 files; the sealed `HOME` ended holding its `.mavenrc` and `.m2/settings.xml` alone.
- **Interrupted** (SIGINT to the run's own process group — as Ctrl-C sends it to a foreground job — once Tomcat listened on 19325,
  during `scan`'s first run): **exit 130**; 0 processes left in the group, 0 listeners on 19320-19329, no JVM with its folder here,
  no `.r-lock`, no partial capture (`.r-*.[123]`), the published captures unchanged.
- Earlier runs, before the last capture change (`scan` gained `Hello.java`'s whole code): bash 3.2 exit 0 (3 min 44 s), a sealed clone
  exit 0 (5 min 3 s, the same 522 artifacts from the `file://` copy), an interrupt exit 130 with nothing left.

## The repository, and what was downloaded

`.m2-demo` (git-ignored) was seeded once from `spring-web-mvc/_research/m2-seed-s1/` (5,827 files, 353 MB) — never from Central
first. Every Maven build in `receipts.sh` runs offline (`-o`) against it and says so: here both builds printed `offline: yes`, and
their logs hold 0 `Downloading from` / `Downloaded from` lines. **Downloads in this unit: none** (0 files, 0 bytes). On a fresh clone
`.m2-demo` is empty: the first build goes to Maven Central once and says `offline: no` (the sealed clone above). No native build, no
Docker, no GraalVM. At run time nothing leaves `127.0.0.1`: both servers listen there (read off the pid, every run), every request
goes there, and Logback writes to the terminal only.

## The demo token — fake, and never printed

TiffinBox does not start without its shutdown token. Every run starts in `.harness/serve` (or `.harness/kept`), each holding a config
tree, `secrets/tiffinbox/shutdown-token` (`-rw-------`, folders `drwx------`), with a 26-character demo token that is fake and looks
it. The token never reaches a command line: the seven requests (`../c5-unit11/curlset.sh`, md5 `bfa34552…`, checked) read it from
the file. Every capture is masked — the label names the length of the token in the file the run served with, read from that file —
and `receipts.sh` counts the raw token in each run's own output **before** masking (0 in all 18 capture runs), in the log of
**every JVM that served** (the token and the header's name `X-Shutdown-Token`, in any case: 0; 27 JVMs per receipt run, nine per pass) and in
the exercise's log (0); then in every capture, this README, the exercise's two files, the harness and `receipts.md5`: 0 each. The
deck's builder counts it again in the script, the deck and the prompter: 0.

## The folders, the names and the ports

- `anchor` → `../c5-unit27/after` (frozen) · `.harness/serve` the copy · `.harness/kept` the second copy · `.harness/classes` the
  harness's four classes, compiled against the copy's extracted jar · `.harness/mine.log` the exercise's log. `.harness/` is
  git-ignored and wiped when `receipts.sh` starts; it stays after a run, for the exercise.
- **Ports (brief ⚑1, 19320-19329):** `toy` 19320/19321 · `lists` 19322/19323 · `scan` 19324/19325 · `converters` 19326/19327 (A,
  C, A′) · `init` 19328/19329 (A, B, A′) · the exercise 19320/19321. **In each pair the first is TiffinBox's own server, the second
  Tomcat.** 18425 (TiffinBox's default) and 8080 (Tomcat's) are checked free before the run, and never bound.
- **Every JVM is stopped by its pid** (TERM: exit 143), and both of its ports are then checked free; never `pkill java`. Two servers
  share each JVM, so POST /shutdown stops TiffinBox's server only: `toy` shows it, and the JVM living on, answering on Tomcat's
  port (brief S1.3, R.79).
- **Readiness (brief S1.13).** `up()` first waits — reading the pid's listen addresses, no request — until the JVM listens on both
  `127.0.0.1` ports: Tomcat binds last, once every bean exists. Then readiness is polled on **TiffinBox's own server**: its 200 comes
  only after Tomcat started (Boot reports ready after the web server starts), and it never reaches the `DispatcherServlet`, so the
  first request Tomcat sees is always one this script prints. Polling Tomcat's port would initialise the servlet before `lists` and
  `init` read it. **Which server answered (R.81):** every request names its port, and `who()` prints each server's own log line.
- **The bind (R.78):** every run passes `--server.address=127.0.0.1 --server.port=<its own>` (the copy has no alias: brief ⚑10);
  `up()` accepts exactly `127.0.0.1:<TiffinBox's port> 127.0.0.1:<Tomcat's port>` read off the pid, and stops the run at once on a
  wildcard. No wildcard bind is made in this unit (that labelled break is the lesson *Embedded Tomcat, Threads and Connectors*'s).

## The commands

From `anchor/README.md` (the anchor's own; `receipts.sh` reads each through `readme()` and dies if one is gone): `mvn -B package`
(run offline: `-o -B -Dmaven.repo.local="$M2"`, `-DskipTests clean`; `dev()` takes those back out and must give the line again),
the extract line `java -Djarmode=tools -jar … extract --destination tiffinbox-web/target/extracted`, the class-path line
`java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431`,
the two logging flags `--logging.level.kitchen=debug` and `--logging.level.web=debug`, the readiness `curl` line and the
`/customers` `curl` line (its port and path changed, `%{content_type}` added after the status — the one change, asserted).

This unit's own (read through `mine()`): the harness's compile line, and six runs — **the class-path layout: the extracted jar plus
a harness folder** (R.44; no Compose module, no DevTools on it; the `dev` profile off). Each run line is the anchor's class-path
line with `:../classes` added to its class path, its port made this unit's, Tomcat given `127.0.0.1` and a port of its own, and the
run's options; `cpl()` derives each from the anchor's line and `mine()` checks it is this README's, whole:

```
javac -d ../classes -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" ../../harness/probe/*.java
java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../classes" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19320 --server.address=127.0.0.1 --server.port=19321 --spring.main.sources=probe.Hello --logging.level.kitchen=debug
java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../classes" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19322 --server.address=127.0.0.1 --server.port=19323 --spring.main.sources=probe.Strategies
java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../classes" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19324 --server.address=127.0.0.1 --server.port=19325 --spring.main.sources=probe.Hello,probe.Frames --logging.level.kitchen=debug --logging.level.org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping=trace
java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../classes" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19326 --server.address=127.0.0.1 --server.port=19327 --spring.main.sources=probe.Hello,probe.Converters --logging.level.web=debug --logging.level.org.springframework.web.servlet.DispatcherServlet=trace
java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../classes" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19328 --server.address=127.0.0.1 --server.port=19329 --spring.main.sources=probe.Strategies
java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../classes" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19328 --server.address=127.0.0.1 --server.port=19329 --spring.main.sources=probe.Strategies --spring.mvc.servlet.load-on-startup=1
```

Every line runs from `.harness/serve` (`converters` C from `.harness/kept`), printed as `$ cd .harness/serve && …`, through `eval`.
Options only: no run passes a bare word to the guarded tree.

## The harness — four classes, outside `com.tiffinbox`

`harness/probe/*.java`, package `probe`, compiled into `.harness/classes` against the copy's extracted jar, joined by
`--spring.main.sources=…` (R.43, R.76). Each declares one route, so no capture depends on the order reflection lists methods in.
- **`Hello`** — `@GetMapping("/probe/hello")`: `{"hello":"from a harness method"}`, a map a message converter writes.
- **`Frames`** — `@GetMapping("/probe/frames")`: the frames above it on its own thread, as `StackWalker` shows them **with reflection
  frames shown** (`SHOW_REFLECT_FRAMES`), down to `DispatcherServlet.doDispatch`, and how many lie below. The default walker hides
  the two reflection frames (`DirectMethodHandleAccessor.invoke`, `Method.invoke`): 47 here is the brief's 45 plus those two.
- **`Strategies`** — `@GetMapping("/probe/strategies")`: the `DispatcherServlet`'s handler mappings by its public
  `getHandlerMappings()`; its adapters, exception resolvers, view resolvers and four single strategies **by reflection on its
  private fields — a harness, not an API** (Framework 7.0's names: `viewNameTranslator`, not `requestToViewNameTranslator`); each
  list set beside `getBeansOfType(...)` of its type: the count, and whether they are the same objects. Mappings print their order
  and package. Also an `ApplicationReadyEvent` listener that logs, before any request, whether the servlet holds its mappings yet.
- **`Converters`** — `@GetMapping("/probe/converters")`: `RequestMappingHandlerAdapter.getMessageConverters()`, public, in order.

## Masks, filters and hygiene — every one, declared

1. **The token:** `gsub` → `[masked: the N-character token]`, N read from the file served with (26 here). **Paths and names:**
   this folder → `…`, the folder above → `…/..`, the home folder → `~` (each also in its `%20` form), the user name → `<user>`.
2. **Spring's error timestamp, both forms** (brief S1.5, proposed R.88): `"timestamp":"<ISO-8601>"` →
   `"timestamp":"<a time, masked: ISO-8601>"`, `"timestamp":<13+ digits>` → `"timestamp":<a time, masked: epoch milliseconds>` —
   the form stays visible, the value does not. **The milliseconds** of `Completed initialization in N ms` → `…`. Every mask is a
   `gsub` in `mask()`; each is shown working on a planted line every run, before any capture (a check that can fail: R.65).
3. **Log lines** are printed from their level on — time, process id and thread cut (thread numbers never reach a capture) — through
   `logf()`, a declared selection: the entries whose `logger: message` matches the capture's pattern, up to a stop line, **every gap
   counted** (`… N lines not shown …`). A TRACE block's lines are printed under it. **Sorted:** TiffinBox's five `route` lines (a run
   of them) and each TRACE registration block's mapping lines — reflection hands methods back in no specified order (Core Java II
   said so; here the scan logged `dashboard`, `kitchen`, `customers`, `revenue`, `shutdown`, not the file's order), so a capture
   that kept that order could drift. The `TreeMap`'s own INFO line is printed as logged: its order is the map's.
4. **Boot's first line** is cut before ` with PID`. JSON is printed as answered (no Actuator JSON here needs sorting).
5. **Hygiene:** `receipts.sh` unsets every `TIFFINBOX_*`, `SPRING_*`, `MANAGEMENT_*`, `SERVER_*` and `LOGGING_*` variable, `DEBUG`,
   `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`, `_JAVA_OPTIONS`, `MAVEN_OPTS`, `MAVEN_ARGS` and `NATIVE_IMAGE_OPTIONS` first — the last
   course's loop, verbatim (`sed -E`, a canary planted under every name, the run stops if one survives); this unit runs no Docker,
   so no `COMPOSE_*`. It puts `127.0.0.1` and `localhost` first in `no_proxy` and `NO_PROXY`. No capture reads the process's
   environment, so macOS's `__CF_USER_TEXT_ENCODING` (CoreFoundation writes it into a process's environment) changes nothing
   here. It refuses to run twice at once (`.r-lock`), with a `secrets/` in this folder, or with build output or secrets in
   `anchor/`. A last pass greps every capture for an absolute path, a unit number, Boot's process line, a log time, a thread
   number, a stack trace, an unmasked timestamp and a wildcard address (0 each), and the scripts and READMEs for an exposure list
   with a star (0).
6. **Bash:** `shopt -u patsub_replacement` (bash 5.2+ turns `&` in a `${x/a/b}` replacement into the match); nothing bash 3.2 lacks.
   The published hashes were made under both; the runs of record above name each.
7. **Interrupted:** the exit trap stops `$pid` (the JVM this script started) and sweeps the run's process group (a TiffinBox JVM,
   Maven, `javac`), drops a capture's unfinished runs after an interrupt, and removes `.r-lock`; it ignores a second Ctrl-C and
   cannot fail under `set -e`, and the script exits 130.

## 1 · toy — the router you wrote, beside Spring MVC's, in one JVM

The copy's POM against the anchor's; the toy's four pieces by `grep` (five `@Route` lines, `getAnnotation(Route.class)`, `new
TreeMap<String, Method>()`, `routes.put(…)`, `handler.invoke(this)`); one JVM, two servers; its log through the startup selection;
each server asked for its own route and for the other's; the seven on TiffinBox's server; after POST /shutdown, which server stopped
and whether the JVM lived (it did: Tomcat answered readiness); TERM by pid.

```
the copy: the anchor's tree, Spring MVC's starter added to the web module's POM, the Boot plugin's two Jackson 3 excludes dropped:
$ diff -U0 anchor/tiffinbox-web/pom.xml .harness/serve/tiffinbox-web/pom.xml | tail -n +3
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
  the copy's executable jar: 58 jars in BOOT-INF/lib · spring-webmvc 1 · tomcat-embed-core 1
the router you wrote, in the copy's TiffinBoxServer.java - declare, scan into a TreeMap, invoke:
$ cd .harness/serve && grep -nE '@Route\(|getAnnotation\(Route\.class\)|new TreeMap<String, Method>\(\)|routes\.put\(|handler\.invoke\(this\)' tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
  105: @Route(path = "/customers")
  110: @Route(path = "/revenue")
  115: @Route(path = "/dashboard")
  126: @Route(path = "/kitchen")
  138: @Route(path = "/shutdown", method = "POST")
  155: var routes = new TreeMap<String, Method>();
  157: Route r = m.getAnnotation(Route.class);
  160: routes.put(r.method() + " " + r.path(), m);
  182: respond(exchange, 200, handler.invoke(this));
one JVM, two servers - the README's class-path line, the harness's folder added, Tomcat on 127.0.0.1 and a port of its own:
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../classes" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19320 --server.address=127.0.0.1 --server.port=19321 --spring.main.sources=probe.Hello --logging.level.kitchen=debug
  listens on (read off its pid): 127.0.0.1:19320 127.0.0.1:19321
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19320/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19321/actuator/health/readiness
  {"status":"UP"} 200
its log, from its first line to Tomcat's started line - TiffinBox's scan, its TreeMap, both servers' own lines:
  … 17 lines not shown …
  DEBUG tiffinbox: route GET /customers -> customers()
  DEBUG tiffinbox: route GET /dashboard -> dashboard()
  DEBUG tiffinbox: route GET /kitchen -> kitchen()
  DEBUG tiffinbox: route GET /revenue -> revenue()
  DEBUG tiffinbox: route POST /shutdown -> shutdown()
  … 3 lines not shown …
  INFO tiffinbox: routes mapped:  [GET /customers, GET /dashboard, GET /kitchen, GET /revenue, POST /shutdown]
  INFO tiffinbox: TiffinBox listening on http://127.0.0.1:19320
  … 1 line not shown …
  INFO o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19321 (http) with context path '/'
each server asked for its own route, and for the other's - 19320 is TiffinBox's own server, 19321 Tomcat, Spring MVC's server:
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19320/customers
  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 application/json
  TiffinBox's line at DEBUG: GET /customers -> 200
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19320/probe/hello
  <h1>404 Not Found</h1>No context found for request 404 text/html
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19321/customers
  {"timestamp":"<a time, masked: ISO-8601>","status":404,"error":"Not Found","path":"/customers"} 404 application/json
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19321/probe/hello
  {"hello":"from a harness method"} 200 application/json
the seven, on TiffinBox's own server (19320):
$ $CURLSET 19320 .harness/serve/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
after POST /shutdown: TiffinBox's server stopped - listening on 19320: 0 · the JVM: alive · it listens on: 127.0.0.1:19321
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19321/actuator/health/readiness
  {"status":"UP"} 200
$ kill $pid    # TERM, to the JVM this script started
  exit 143 · listening now: 19320 0 · 19321 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  its log, from TERM on: Commencing graceful shutdown. Waiting for active requests to complete · Graceful shutdown complete
```

## 2 · lists — the strategies, read off the running servlet

Before any request reached Tomcat the harness, at ready, finds the servlet's handler mappings `null` (brief S1.6, proposed R.89:
the lists are read when the servlet initialises). After one request (the README's readiness line), the lists: **9 handler mappings
(Actuator's three first, order -100, package `…boot.webmvc.actuate.endpoint.web`), 4 handler adapters, 2 exception resolvers, 4
view resolvers**, and the multipart, locale, view-name and flash-map strategies — every count "here": Actuator's and the harness's
beans are among them. **RE-MEASURE #4 settled:** each list has the same count as the context's beans of that type, and they are the
same objects (identity), all four.

```
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../classes" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19322 --server.address=127.0.0.1 --server.port=19323 --spring.main.sources=probe.Strategies
  listens on (read off its pid): 127.0.0.1:19322 127.0.0.1:19323
  19322 is TiffinBox's own server - its line: TiffinBox listening on http://127.0.0.1:19322 · 19323 is Tomcat, Spring MVC's server - its line: Tomcat started on port 19323 (http) with context path '/'
  before any request reached Tomcat - the harness, at ready: the DispatcherServlet's handler mappings: null
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19323/actuator/health/readiness
  {"status":"UP"} 200
after that one request, the servlet's lists - the harness's Strategies (handler mappings by the servlet's getter, the rest by reflection), each beside the context's own beans of that type:
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19323/probe/strategies
  handler mappings: 9 · the context's beans of that type: 9 · the same objects: yes
  1 AdditionalHealthEndpointPathsWebMvcHandlerMapping (order -100) · org.springframework.boot.webmvc.actuate.endpoint.web
  2 WebMvcEndpointHandlerMapping (order -100) · org.springframework.boot.webmvc.actuate.endpoint.web
  3 ControllerEndpointHandlerMapping (order -100) · org.springframework.boot.webmvc.actuate.endpoint.web
  4 RouterFunctionMapping (order -1) · org.springframework.web.servlet.function.support
  5 RequestMappingHandlerMapping (order 0) · org.springframework.web.servlet.mvc.method.annotation
  6 WelcomePageHandlerMapping (order 2) · org.springframework.boot.webmvc.autoconfigure
  7 BeanNameUrlHandlerMapping (order 2) · org.springframework.web.servlet.handler
  8 WelcomePageNotAcceptableHandlerMapping (order 2147483637) · org.springframework.boot.webmvc.autoconfigure
  9 SimpleUrlHandlerMapping (order 2147483646) · org.springframework.web.servlet.handler
  handler adapters: 4 · the context's beans of that type: 4 · the same objects: yes
  1 RequestMappingHandlerAdapter
  2 HandlerFunctionAdapter
  3 HttpRequestHandlerAdapter
  4 SimpleControllerHandlerAdapter
  exception resolvers: 2 · the context's beans of that type: 2 · the same objects: yes
  1 DefaultErrorAttributes
  2 HandlerExceptionResolverComposite
  view resolvers: 4 · the context's beans of that type: 4 · the same objects: yes
  1 ContentNegotiatingViewResolver
  2 BeanNameViewResolver
  3 ViewResolverComposite
  4 InternalResourceViewResolver
  multipartResolver: StandardServletMultipartResolver
  localeResolver: AcceptHeaderLocaleResolver
  viewNameTranslator: DefaultRequestToViewNameTranslator
  flashMapManager: SessionFlashMapManager
   200 text/plain;charset=UTF-8
$ kill $pid    # TERM, to the JVM this script started
  exit 143 · listening now: 19322 0 · 19323 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 3 · scan — declare, scan, register, invoke, side by side

`Hello.java`'s whole code — 11 lines, its 5 comment lines and 4 blank lines cut and counted — with a check that none of them
registers anything; one start with TiffinBox's logger group at DEBUG and `RequestMappingHandlerMapping` at TRACE: the
toy's five `route` lines and its `routes mapped` line, then Spring MVC's registrations — `p.Hello:` / `{GET [/probe/hello]}:
hello()` — and `4 mappings in 'requestMappingHandlerMapping'` (the harness's two and Boot's two `/error`), all before `Tomcat
started` (asserted in that order). One request's frames: the harness method, then `DirectMethodHandleAccessor.invoke` and
**`Method.invoke`** — the call the toy makes (`handler.invoke(this)`, in `toy`) — then `InvocableHandlerMethod.doInvoke`, the adapter,
`DispatcherServlet.doDispatch`; 47 frames in all with reflection's shown. (The brief planned to cite these top frames from the
lesson *What Happens Between curl and Your Method*; that unit's evidence was made in parallel, so they are measured here, with the
reflection frames the default walker hides.) Then a pattern, not a key: `/probe/helloXYZ` and
`/probe/hello/` 404 on Tomcat (the lesson *@RestController and Request Mapping* opens it, C6-9), while TiffinBox's server answers
`/customersXYZ` with the customers (a prefix, as the last course measured).

```
the harness's route, its whole code - its comment lines (5) and blank lines (4) not shown:
$ grep -nvE '^[[:space:]]*(/\*\*|\*|\*/|$)' harness/probe/Hello.java
  1: package probe;
  3: import java.util.Map;
  5: import org.springframework.web.bind.annotation.GetMapping;
  6: import org.springframework.web.bind.annotation.RestController;
  13: @RestController
  14: public class Hello {
  16:     @GetMapping("/probe/hello")
  17:     Map<String, String> hello() {
  18:         return Map.of("hello", "from a harness method");
  19:     }
  20: }
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../classes" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19324 --server.address=127.0.0.1 --server.port=19325 --spring.main.sources=probe.Hello,probe.Frames --logging.level.kitchen=debug --logging.level.org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping=trace
  listens on (read off its pid): 127.0.0.1:19324 127.0.0.1:19325
its log, from its first line to Tomcat's started line - TiffinBox's scan at DEBUG, Spring MVC's at TRACE:
  … 17 lines not shown …
  DEBUG tiffinbox: route GET /customers -> customers()
  DEBUG tiffinbox: route GET /dashboard -> dashboard()
  DEBUG tiffinbox: route GET /kitchen -> kitchen()
  DEBUG tiffinbox: route GET /revenue -> revenue()
  DEBUG tiffinbox: route POST /shutdown -> shutdown()
  … 3 lines not shown …
  INFO tiffinbox: routes mapped:  [GET /customers, GET /dashboard, GET /kitchen, GET /revenue, POST /shutdown]
  INFO tiffinbox: TiffinBox listening on http://127.0.0.1:19324
  TRACE s.w.s.m.m.a.RequestMappingHandlerMapping:
      p.Hello:
      {GET [/probe/hello]}: hello()
  TRACE s.w.s.m.m.a.RequestMappingHandlerMapping:
      p.Frames:
      {GET [/probe/frames], produces [text/plain]}: frames()
  TRACE s.w.s.m.m.a.RequestMappingHandlerMapping:
      o.s.b.w.a.e.BasicErrorController:
      { [/error], produces [text/html]}: errorHtml(HttpServletRequest,HttpServletResponse)
      { [/error]}: error(HttpServletRequest)
  DEBUG s.w.s.m.m.a.RequestMappingHandlerMapping: 4 mappings in 'requestMappingHandlerMapping'
  … 1 line not shown …
  INFO o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19325 (http) with context path '/'
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19325/actuator/health/readiness
  {"status":"UP"} 200
one request - the frames above the harness's frames(), on its own thread, reflection's shown:
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19325/probe/frames
  1 probe.Frames.frames
  2 jdk.internal.reflect.DirectMethodHandleAccessor.invoke
  3 java.lang.reflect.Method.invoke
  4 org.springframework.web.method.support.InvocableHandlerMethod.doInvoke
  5 org.springframework.web.method.support.InvocableHandlerMethod.invokeForRequest
  6 org.springframework.web.servlet.mvc.method.annotation.ServletInvocableHandlerMethod.invokeAndHandle
  7 org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.invokeHandlerMethod
  8 org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.handleInternal
  9 org.springframework.web.servlet.mvc.method.AbstractHandlerMethodAdapter.handle
  10 org.springframework.web.servlet.DispatcherServlet.doDispatch
  below it: 37 more frames · 47 in all
   200 text/plain;charset=UTF-8
  its line at TRACE: Mapped to probe.Frames#frames()
a pattern, not a key - Tomcat, Spring MVC's server (19325):
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19325/probe/hello
  {"hello":"from a harness method"} 200 application/json
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19325/probe/helloXYZ
  {"timestamp":"<a time, masked: ISO-8601>","status":404,"error":"Not Found","path":"/probe/helloXYZ"} 404 application/json
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19325/probe/hello/
  {"timestamp":"<a time, masked: ISO-8601>","status":404,"error":"Not Found","path":"/probe/hello/"} 404 application/json
and TiffinBox's own server (19324) - three letters more:
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19324/customersXYZ
  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 application/json
$ kill $pid    # TERM, to the JVM this script started
  exit 143 · listening now: 19324 0 · 19325 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 4 · converters — what writes a JSON answer

A: the adapter's **6 message converters, the sixth `JacksonJsonHttpMessageConverter`** (Jackson 3); both Jacksons in the copy's
`lib/`. One request at `--logging.level.web=debug` (the anchor README's flag) and the `DispatcherServlet` at TRACE: `Mapped to
probe.Hello#hello()`, `Using 'application/json', given [*/*] and supported [...]`, `Writing [{hello=from a harness method}]` — the
method returned a map, the converter wrote it — then **`No view rendering, null ModelAndView returned.`**: the view resolvers are
there (`lists`), and a JSON answer never reaches them. C (labelled), the second copy with the last course's two excludes kept: 6
converters, the sixth **`MappingJackson2HttpMessageConverter`** (Jackson 2), Jackson 3 absent from `lib/` — the copy's Jackson 3
converter is there only because the copy dropped those excludes (brief ⚑6, ⚑10). A′ = A, asserted line for line.

```
A - the copy:
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../classes" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19326 --server.address=127.0.0.1 --server.port=19327 --spring.main.sources=probe.Hello,probe.Converters --logging.level.web=debug --logging.level.org.springframework.web.servlet.DispatcherServlet=trace
  listens on (read off its pid): 127.0.0.1:19326 127.0.0.1:19327
  19326 is TiffinBox's own server - its line: TiffinBox listening on http://127.0.0.1:19326 · 19327 is Tomcat, Spring MVC's server - its line: Tomcat started on port 19327 (http) with context path '/'
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19327/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19327/probe/converters
  message converters, the request mapping adapter's: 6
  1 org.springframework.http.converter.ByteArrayHttpMessageConverter
  2 org.springframework.http.converter.StringHttpMessageConverter
  3 org.springframework.http.converter.ResourceHttpMessageConverter
  4 org.springframework.http.converter.ResourceRegionHttpMessageConverter
  5 org.springframework.http.converter.support.AllEncompassingFormHttpMessageConverter
  6 org.springframework.http.converter.json.JacksonJsonHttpMessageConverter
   200 text/plain;charset=UTF-8
  Jackson in this copy's extracted lib/: jackson-databind-2.22.2.jar jackson-databind-3.1.5.jar
one request, and the lines it added at DEBUG and TRACE:
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19327/probe/hello
  {"hello":"from a harness method"} 200 application/json
  TRACE o.s.web.servlet.DispatcherServlet: GET "/probe/hello", parameters={}, headers={masked} in DispatcherServlet 'dispatcherServlet'
  DEBUG s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to probe.Hello#hello()
  DEBUG m.m.a.RequestResponseBodyMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
  DEBUG m.m.a.RequestResponseBodyMethodProcessor: Writing [{hello=from a harness method}]
  TRACE o.s.web.servlet.DispatcherServlet: No view rendering, null ModelAndView returned.
  DEBUG o.s.web.servlet.DispatcherServlet: Completed 200 OK, headers={masked}
$ kill $pid    # TERM, to the JVM this script started
  exit 143 · listening now: 19326 0 · 19327 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - a second copy, the last course's two Jackson 3 excludes kept (only the starter added):
$ diff -U0 anchor/tiffinbox-web/pom.xml .harness/kept/tiffinbox-web/pom.xml | tail -n +3
  @@ -61,0 +62 @@
  +    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-webmvc</artifactId></dependency>
$ cd .harness/kept && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../classes" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19326 --server.address=127.0.0.1 --server.port=19327 --spring.main.sources=probe.Hello,probe.Converters --logging.level.web=debug --logging.level.org.springframework.web.servlet.DispatcherServlet=trace
  listens on (read off its pid): 127.0.0.1:19326 127.0.0.1:19327
  19326 is TiffinBox's own server - its line: TiffinBox listening on http://127.0.0.1:19326 · 19327 is Tomcat, Spring MVC's server - its line: Tomcat started on port 19327 (http) with context path '/'
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19327/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19327/probe/converters
  message converters, the request mapping adapter's: 6
  1 org.springframework.http.converter.ByteArrayHttpMessageConverter
  2 org.springframework.http.converter.StringHttpMessageConverter
  3 org.springframework.http.converter.ResourceHttpMessageConverter
  4 org.springframework.http.converter.ResourceRegionHttpMessageConverter
  5 org.springframework.http.converter.support.AllEncompassingFormHttpMessageConverter
  6 org.springframework.http.converter.json.MappingJackson2HttpMessageConverter
   200 text/plain;charset=UTF-8
  Jackson in this copy's extracted lib/: jackson-databind-2.22.2.jar
$ kill $pid    # TERM, to the JVM this script started
  exit 143 · listening now: 19326 0 · 19327 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again:
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../classes" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19326 --server.address=127.0.0.1 --server.port=19327 --spring.main.sources=probe.Hello,probe.Converters --logging.level.web=debug --logging.level.org.springframework.web.servlet.DispatcherServlet=trace
  listens on (read off its pid): 127.0.0.1:19326 127.0.0.1:19327
  19326 is TiffinBox's own server - its line: TiffinBox listening on http://127.0.0.1:19326 · 19327 is Tomcat, Spring MVC's server - its line: Tomcat started on port 19327 (http) with context path '/'
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19327/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19327/probe/converters
  message converters, the request mapping adapter's: 6
  1 org.springframework.http.converter.ByteArrayHttpMessageConverter
  2 org.springframework.http.converter.StringHttpMessageConverter
  3 org.springframework.http.converter.ResourceHttpMessageConverter
  4 org.springframework.http.converter.ResourceRegionHttpMessageConverter
  5 org.springframework.http.converter.support.AllEncompassingFormHttpMessageConverter
  6 org.springframework.http.converter.json.JacksonJsonHttpMessageConverter
   200 text/plain;charset=UTF-8
  Jackson in this copy's extracted lib/: jackson-databind-2.22.2.jar jackson-databind-3.1.5.jar
one request, and the lines it added at DEBUG and TRACE:
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19327/probe/hello
  {"hello":"from a harness method"} 200 application/json
  TRACE o.s.web.servlet.DispatcherServlet: GET "/probe/hello", parameters={}, headers={masked} in DispatcherServlet 'dispatcherServlet'
  DEBUG s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to probe.Hello#hello()
  DEBUG m.m.a.RequestResponseBodyMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
  DEBUG m.m.a.RequestResponseBodyMethodProcessor: Writing [{hello=from a harness method}]
  TRACE o.s.web.servlet.DispatcherServlet: No view rendering, null ModelAndView returned.
  DEBUG o.s.web.servlet.DispatcherServlet: Completed 200 OK, headers={masked}
$ kill $pid    # TERM, to the JVM this script started
  exit 143 · listening now: 19326 0 · 19327 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 5 · init — when the servlet reads its lists (A/B/A′)

Boot's own default from its metadata: `spring.mvc.servlet.load-on-startup` **-1**. **A** (the default): before any request reached
Tomcat, no `Initializing` line, and the harness at ready finds `null`; the first request (the README's readiness line) brings the
three lines. **B** (`--spring.mvc.servlet.load-on-startup=1`): the three lines come **before `Tomcat started`**, the harness at
ready finds 9, and the first request adds none. **A′ = A**, asserted line for line, its `$` command shown. "Initializing" is logged
at INFO, the default level (R.67).

```
Boot's own default, from its metadata (spring-boot-webmvc-4.1.1.jar, META-INF/spring-configuration-metadata.json):
  spring.mvc.servlet.load-on-startup · java.lang.Integer · default -1 · Load on startup priority of the dispatcher servlet.
A - the default:
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../classes" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19328 --server.address=127.0.0.1 --server.port=19329 --spring.main.sources=probe.Strategies
  listens on (read off its pid): 127.0.0.1:19328 127.0.0.1:19329
  19328 is TiffinBox's own server - its line: TiffinBox listening on http://127.0.0.1:19328 · 19329 is Tomcat, Spring MVC's server - its line: Tomcat started on port 19329 (http) with context path '/'
  before any request reached Tomcat - its log's lines about the DispatcherServlet's start, Tomcat's start and the harness at ready:
  … 22 lines not shown …
  INFO o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19329 (http) with context path '/'
  … 1 line not shown …
  INFO probe: harness, at ready: the DispatcherServlet's handler mappings: null
  the first request to Tomcat - the README's readiness line:
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19329/actuator/health/readiness
  {"status":"UP"} 200
  the lines it added about the DispatcherServlet's start: 3
  INFO o.a.c.c.C.[Tomcat].[localhost].[/]: Initializing Spring DispatcherServlet 'dispatcherServlet'
  INFO o.s.web.servlet.DispatcherServlet: Initializing Servlet 'dispatcherServlet'
  INFO o.s.web.servlet.DispatcherServlet: Completed initialization in … ms
$ kill $pid    # TERM, to the JVM this script started
  exit 143 · listening now: 19328 0 · 19329 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - --spring.mvc.servlet.load-on-startup=1:
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../classes" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19328 --server.address=127.0.0.1 --server.port=19329 --spring.main.sources=probe.Strategies --spring.mvc.servlet.load-on-startup=1
  listens on (read off its pid): 127.0.0.1:19328 127.0.0.1:19329
  19328 is TiffinBox's own server - its line: TiffinBox listening on http://127.0.0.1:19328 · 19329 is Tomcat, Spring MVC's server - its line: Tomcat started on port 19329 (http) with context path '/'
  before any request reached Tomcat - its log's lines about the DispatcherServlet's start, Tomcat's start and the harness at ready:
  … 22 lines not shown …
  INFO o.a.c.c.C.[Tomcat].[localhost].[/]: Initializing Spring DispatcherServlet 'dispatcherServlet'
  INFO o.s.web.servlet.DispatcherServlet: Initializing Servlet 'dispatcherServlet'
  INFO o.s.web.servlet.DispatcherServlet: Completed initialization in … ms
  INFO o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19329 (http) with context path '/'
  … 1 line not shown …
  INFO probe: harness, at ready: the DispatcherServlet's handler mappings: 9
  the first request to Tomcat - the README's readiness line:
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19329/actuator/health/readiness
  {"status":"UP"} 200
  the lines it added about the DispatcherServlet's start: 0
$ kill $pid    # TERM, to the JVM this script started
  exit 143 · listening now: 19328 0 · 19329 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again:
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../classes" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19328 --server.address=127.0.0.1 --server.port=19329 --spring.main.sources=probe.Strategies
  listens on (read off its pid): 127.0.0.1:19328 127.0.0.1:19329
  19328 is TiffinBox's own server - its line: TiffinBox listening on http://127.0.0.1:19328 · 19329 is Tomcat, Spring MVC's server - its line: Tomcat started on port 19329 (http) with context path '/'
  before any request reached Tomcat - its log's lines about the DispatcherServlet's start, Tomcat's start and the harness at ready:
  … 22 lines not shown …
  INFO o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19329 (http) with context path '/'
  … 1 line not shown …
  INFO probe: harness, at ready: the DispatcherServlet's handler mappings: null
  the first request to Tomcat - the README's readiness line:
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19329/actuator/health/readiness
  {"status":"UP"} 200
  the lines it added about the DispatcherServlet's start: 3
  INFO o.a.c.c.C.[Tomcat].[localhost].[/]: Initializing Spring DispatcherServlet 'dispatcherServlet'
  INFO o.s.web.servlet.DispatcherServlet: Initializing Servlet 'dispatcherServlet'
  INFO o.s.web.servlet.DispatcherServlet: Completed initialization in … ms
$ kill $pid    # TERM, to the JVM this script started
  exit 143 · listening now: 19328 0 · 19329 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 6 · exercise — the README's commands, as written, then the solution's

`exercise/README.md` ships broken: its logging option names `RequestMappingHandlerAdapter`, which logs no route (`lines that
register a route: 0`). `solution/SOLUTION.md` names `RequestMappingHandlerMapping`: `{GET [/probe/hello]}: hello()` — the line the
README calls Done, and a line of this capture. Both runs use `-Dspring.context.exit=onRefresh` (the last course's AOT-cache line's
property): the JVM refreshes the context and exits 0 before Tomcat starts (its log's `Tomcat started` lines: 0); nothing is left
listening.

```
exercise/README.md's commands, run exactly as written from this folder - 3 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ cd .harness/serve && java -Dspring.context.exit=onRefresh -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../classes" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19320 --server.address=127.0.0.1 --server.port=19321 --spring.main.sources=probe.Hello --logging.level.org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter=trace > ../mine.log && echo "lines that register a route: $(grep -c '{GET' ../mine.log)"
  lines that register a route: 0
  exit 0 · listening now: 19320 0 · 19321 0 · its log's lines saying Tomcat started: 0 · the demo token in its log: 0
the solution's line (exercise/solution/SOLUTION.md), run exactly as written, from this folder:
$ cd .harness/serve && java -Dspring.context.exit=onRefresh -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../classes" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19320 --server.address=127.0.0.1 --server.port=19321 --spring.main.sources=probe.Hello --logging.level.org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping=trace > ../mine.log && grep -F '[/probe/hello]' ../mine.log | tr -d '\t'
  {GET [/probe/hello]}: hello()
  exit 0 · listening now: 19320 0 · 19321 0 · the demo token in its log: 0
```

## Found on the way

1. **A readiness race (fixed before any hash was published).** Polling TiffinBox's own readiness while the context was still
   creating beans made Spring log `Obtaining singleton bean '…' in thread "" while other thread holds singleton lock …` at INFO —
   one line per request that raced the start, so `toy`'s gap count moved (5 lines, then 4): the capture drifted and `cap()` died.
   `up()` now makes no request until the pid listens on both ports (Tomcat binds after every bean exists).
2. **A BRE `+`** (`grep ' probe +: …'` without `-E`: macOS's basic expressions read `+` as a character) printed an empty harness
   line; caught by the check on that line, which expects the word `null`.
3. **A logger name with no space before it** (`o.s.boot.tomcat.TomcatWebServer`): `who()`'s first pattern found no Tomcat line;
   caught by its check.
4. **Planted faults, each caught every run before any capture:** the bind check given `*:19321 127.0.0.1:19320` (a wildcard) and
   `127.0.0.1:19320` (one server of two) — refused both, accepted the two loopback addresses; each mask given a planted line (an ISO
   timestamp, an epoch timestamp, the milliseconds, the token). The init order checks and the scan order check compare line
   numbers found one pattern at a time (a first version compared `grep -n`'s own increasing output, a check that could not fail).
5. **Reflection's order:** this JVM's scan logged the routes as `dashboard`, `kitchen`, `customers`, `revenue`, `shutdown` — not the
   file's order (`customers` first). Core Java II's lesson said `getDeclaredMethods()` has no specified order; the captures print
   the five lines sorted, and the `TreeMap`'s INFO line as logged.
6. **The brief's 45 frames** are the default stack walker's; this unit's walker shows reflection frames (to show `Method.invoke`),
   so the same path is 47 here. The voice speaks neither total.

## For RED (part A)

Re-test: the sealed clone, SIGINT, both bashes; the listen-address assertion (`up()`, `bindok`); the masks (`mask()`, both timestamp
forms); the survivor (`toy`: TiffinBox's server stopped, the JVM alive on 19321, then TERM by pid). The receipts' md5s:

```
toy 899677faff6a8c27356add7553631035
lists ba7e900dadc6130e37d44f76237d3184
scan d6cbf9927ca314fa90a913ffc35a1510
converters a51c6a7c7ec217c197b0052def6a0faf
init 56789d5a4343fbe5826a1b1cd71917b0
exercise c749c616368a6b150a4227a38927ea2a
```

## Ledger rows paid, and what is handed on

- **C6-1** (the router → *DispatcherServlet, Opened*; the chip "the toy version … a TreeMap of routes"): `toy` shows the toy's
  `TreeMap` and its keys; `lists` and `scan` show Spring MVC's lists beside it. **C6-27** (`@GetMapping` "Spring reads it and wires
  a web route"): `scan`'s TRACE registration, before Tomcat started, for a harness route (TiffinBox's own routes reach Spring MVC's
  table at the anchor's switch; their table is the lesson *`/actuator/mappings`: Every Route, Listed*). **C6-28** (the small, boring
  core of `@GetMapping`): the same — declare, scan, invoke, `Method.invoke` under both; not the same — nine mappings asked in order,
  patterns, four adapters, a message converter. **X1:** Core Java II's numbers are re-read off its script by the deck's builder.
- **Handed on:** the prefix match and the trailing slash (`/probe/helloXYZ`, `/probe/hello/` 404 here) → *@RestController and Request
  Mapping* (C6-9); the converters and Jackson 2/3 → *Request Bodies and HttpMessageConverter* and *Jackson in Spring*; views →
  *Serving HTML: Thymeleaf*. The two Jacksons in one jar are the copy's only (brief ⚑6 moves the anchor there at the switch).
