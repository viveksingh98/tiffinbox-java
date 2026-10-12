# c6-unit05 — /actuator/mappings: Every Route, Listed

Course 6 · Spring Web MVC · Section 1 (The Servlet Layer), its fifth and last unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16,
Spring Boot 4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24), 2026-10-13. The last course asked Boot for its routing table —
`/actuator/mappings`, exposed by a flag for one run — and got one context with nothing in it: TiffinBox's routes were its own. Since
the embedded-Tomcat lesson they are rows in Spring MVC's table. This unit prints the table, reads what each kind of row says, finds
the two rows that catch every path, and shows the one place a flag cannot add the endpoint at all.

**No anchor change.** `anchor` is the link to `../c6-unit04/after` — the tree the embedded-Tomcat lesson froze, equal to
`../c6-tiffinbox` when this unit was made (`diff -rq -x target`: empty). "The previous tree" is `../c5-unit27/after`, the anchor as
Course 5 left it: TiffinBox's own server and its Actuator bridge, `ActuatorRoutes`. Both are read and copied under `.harness/`, never
built in place. No native build and no Docker: the AOT jar (`exposure`) is the profile native's jar run with
`-Dspring.aot.enabled=true`, and no GraalVM is needed.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 6 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top; a bare `java` on this Mac is 23.0.1.) It **dies** when a capture's md5
differs from `receipts.md5` (it prints the `DIFFERS` line first).

**Runs of record (2026-10-13, this script as committed):** **166 s under `./receipts.sh`** (/bin/bash 3.2.57, this folder, exit 0,
all 6 = published, every check passed); **174 s under `bash receipts.sh`** (Homebrew bash 5.3.9, the same); **186 s from a sealed
fresh clone under `./receipts.sh`** (/bin/bash 3.2.57): `git clone` of the local repository (HEAD e25e54c) plus this unit's working
files — nothing git ignores: no `.m2-demo`, no `.harness/`, no `.r-*` — run under `env -i`, with a `HOME` whose `.mavenrc` points
Maven's `user.home` there (Java reads `user.home` from the account, not from `$HOME`) and every Java proxy property at a port that
refuses (127.0.0.1:9), and whose Maven settings send every repository to a `file://` copy of Central's files made from `.m2-demo`
(4,377 files: TiffinBox's own installs, `_remote.repositories`, `*.lastUpdated`, `resolver-status.properties` and `.DS_Store` left
out, `maven-metadata-central.xml` served as `maven-metadata.xml`); `http_proxy`, `https_proxy`, their capitals and `ALL_PROXY` at the
same refusing port; `PATH` the system's and Homebrew's, so `python3` was the system's 3.9.6 there (3.14.7 in this folder's runs) —
the same captures. Exit 0, all 6 = published, every check passed. The first pre-capture build said `offline: no` (GraalVM's metadata
repository was not in the empty `.m2-demo`) and took **523 artifacts, every one from the `file://` copy, 0 from anywhere else**; the
second said `offline: yes`, and so did every capture's build; `.m2-demo` ended with 1,405 files; the sealed `HOME` ended holding its
`.mavenrc`, its `.m2/settings.xml` and the system Python's bytecode cache (`Library/Caches/com.apple.python`). Load averages 4.8-5.7
during these runs (other units' receipts ran alongside). Earlier runs, on revisions of this script, found the two faults under "Found
on the way" that the script itself had: rows in a moving order, and an escaped `…`.

Published hashes: table `452ba448ecb8e205a92d57433320b149` · adapter `b9cfe3b9589e5416f2db62da7b32c056` · rows `fe3370d32a3fa12bf19942d063e5cb32` · catchall `5283262f2f1e8e2d61917201321652bb` · exposure `8305170c0b56f2599d536b2b95766854` · exercise `4ad5cd04417c1c204e969ccc50ef9705`.

## The commands — the anchor's lines, and the ten this unit adds

Every command a capture runs is a whole line of `anchor/README.md` — the anchor's own `mvn -B package` and `mvn -B -Pnative package`,
its run line, its web log group line, its AOT line, its readiness, `/customers` and status-and-type `curl` lines — or a whole line of
this README, each read by `readme()` or `mine()`, asserted, then run with its port changed, or in its offline form (`mvn -o -B
-Dmaven.repo.local="$M2" … -DskipTests clean …`). This unit's run lines are the anchor's run line, or its AOT line, plus options
only; the other lines read Actuator's answers through the course's harness, `harness/table.py`, or send one wrong verb:

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,mappings
curl -s http://127.0.0.1:18431/actuator/mappings | python3 harness/table.py
curl -s http://127.0.0.1:18431/actuator/mappings | python3 harness/table.py count
curl -s http://127.0.0.1:18431/actuator/mappings | python3 harness/table.py row /actuator/health /customers
curl -s http://127.0.0.1:18431/actuator | python3 harness/table.py links
curl -s -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/mappings
curl -s -X DELETE -w ' %{http_code} allow=%header{allow}\n' http://127.0.0.1:18431/customers
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,mappings --logging.level.web=debug
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,mappings --logging.level.web=debug --spring.web.resources.add-mappings=false
java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,mappings
```

- **`--management.endpoints.web.exposure.include=health,prometheus,mappings`** — the anchor's own list (`application.yaml`:
  `health,prometheus`) plus `mappings`, for this one run. A list given at run time replaces the file's, so the two it already had are
  named again. Never `*` (`receipts.sh` greps every script and README for it). **On the plain JVM only:** under Spring's AOT step the
  list is fixed when the jar is built, and a flag adds nothing there (`exposure`). The same list throughout, so the break's A is the
  table itself.
- **`--logging.level.web=debug`** — the anchor's own option: Boot's `web` log group, Spring MVC's loggers among them, at DEBUG.
- **`--spring.web.resources.add-mappings=false`** — Boot's static-resource mappings off; Boot's own metadata says `true` by default
  (`catchall`).
- **`harness/table.py`** — the course's reader, never TiffinBox's: Python 3, the standard library only. It reads one Actuator answer on
  its standard input (curl fetches; it only reads) and prints the routing table (`contexts`, kinds, every row as `pattern -> handler`,
  the counts), its counts on one line (`count`), every key of the rows for given patterns (`row`), the names of `/actuator`'s links
  (`links`), or TiffinBox's own rows and the verbs the table gives them (`tiffinbox`, the exercise's). Its cuts and its order are
  declared below (Masks, 4).
- **The DELETE line** prints the answer's body, its status and its `Allow` header (`allow=`, empty when there is none); `rows` sends it
  to `/actuator/health` (its path changed) and to `/customers`.
- Start TiffinBox from a copy of the anchor that holds a config tree with a token (`secrets/tiffinbox/shutdown-token`), and run the
  `curl … | python3 harness/table.py` lines from this folder, with the port you started it on.

## The repository, and what was downloaded

`.m2-demo` (git-ignored) was seeded once from `../c6-unit04/.m2-demo` — without `com/tiffinbox`, which that unit's install wrote
(brief ⚑17) — and `../../spring-web-mvc/_research/m2-seed-s1/`: 5,827 files, never from Central first. Every Maven build runs
offline (`-o`) against it and says so: every build here said `offline: yes`, and the profile native's build (`exposure`) read GraalVM's
metadata repository from `.m2-demo` (`file:`) — its log holds 0 lines of the plugin's own download (`Downloaded GraalVM reachability
metadata repository from http`, `Failed to download from http`; the run stops on either). **Downloads in this unit: none** (0 files,
0 bytes). A fresh clone's `.m2-demo` is empty: the first build — the anchor with the profile native, before any capture — fills it
from Maven Central and says `offline: no`; every capture's build then says `offline: yes` (the sealed clone, above).

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 26 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/*/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) when the script runs, and sent only by `../c5-unit11/curlset.sh` and `harness/shutdown.sh`, on curl's standard input.
Every capture's raw output is searched for it before masking (0 in all of them), and so are the log of every JVM that served and every
file this unit ships: 0 everywhere. The exercise makes a token of its own (26 random characters), counted 0 times in its own log and
never printed.

## The folders, the names and the ports

- `anchor` → `../c6-unit04/after`. `.harness/after`, `.harness/before`, `.harness/aot` — the anchor, the previous tree, and the anchor
  built with the profile native, each copied with a config tree; `.harness/pre`, `.harness/pre0` — the first builds, which fill
  `.m2-demo` on a fresh clone; `.harness/mine` — the exercise's copy.
- **The harness** — the course's, never TiffinBox's: `harness/table.py` (above) and `harness/shutdown.sh` (POST /shutdown on
  127.0.0.1, the token read from its file and handed to curl on its standard input, a 5-second limit — the embedded-Tomcat lesson's,
  copied byte for byte).
- **Ports** (brief ⚑1, 19340-19349): `table` 19340 · the previous tree 19341 · `adapter`'s anchor 19342 · `rows` 19343 · `catchall`
  19344 · the AOT jar 19345 · the exercise 19349; 19346-19348 unused, checked free. 18425 (TiffinBox's default) and 8080 (Tomcat's)
  are checked free and never bound; a run that listens on 8080 is killed and the script dies.

## Masks, filters and hygiene — every one, declared

1. **Paths, the token, the user** (`mask()`, `gsub`, literals escaped), in every line: the token → `[masked: the 26-character token]`
   (its length read off the token); a GraalVM's folder, if `GRAALVM_HOME` is set → `$GRAALVM_HOME`; this folder → `…`; the folder above
   → `…/..`; home → `~`; the user name → `<user>`, as a whole word only, last.
2. **Spring's error timestamp** (`tsmask`, `gsub`): `"timestamp":"<anything>"` → `"timestamp":"…"` and `"timestamp":<digits>` →
   `"timestamp":…` — an ISO-8601 string (Jackson 3, here) and epoch milliseconds. The seven are hashed after it; each `seven` line says
   how many lines it changed (0 on TiffinBox's own server, 1 on Tomcat: `/nowhere`). The same function the embedded-Tomcat lesson
   checked on four planted lines.
3. **JSON keys sorted** (`sortj`, and inside `harness/table.py`): Jackson 2 and Jackson 3 order keys differently. A line whose keys
   moved says `(keys sorted)`; nothing is escaped (`…` stays `…`).
4. **`harness/table.py`'s cuts and order**, each counted on the table's header line: a `produces [a || b || c]` list keeps its first
   type (`produces [a … 2 more]`: 5 rows here); a Java class name before `#` keeps its last part
   (`BasicErrorController#error(HttpServletRequest)`: 2 rows). `row` prints every key whole. The rows keep the table's own order,
   **except** that a run of consecutive rows with details — the ones a `RequestMappingInfo` describes: Actuator's five, `/error`'s two —
   is sorted by pattern: the table gives those in the order of a hash, which moved between two runs here (Found on the way). TiffinBox's
   five and the two static rows keep the table's order. An answer that is not a routing table is named by its status, never printed.
5. **DEBUG lines** (`catchall`, Boot's `web` group): from their logger on; an identity hash after `@` → `@…`; the date in the error
   map's `timestamp=` → `timestamp=…`; a WARN line says `WARN`. For each request, every DEBUG and WARN line after the log stopped growing
   is shown, and the lines of any other level in the same stretch are counted (0 here).
6. **A running TiffinBox's log**: Boot's first line cut before ` with PID`; Tomcat's line and TiffinBox's own from their message on;
   at start, the handler mappings that logged their patterns (DEBUG), from their message on.
7. **On this Mac**: `lsof` by pid, the address column alone — never a command name (R.18).
8. **A last check** fails if any capture holds `/Users/`, `/private/`, `/home/`, `/var/folders/`, a unit number, Boot's process line,
   a log time, an unmasked timestamp, a thread number, a stack frame, an identity hash or `:8080`; and if any script or README exposes
   every endpoint.

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`, the
exercise's `$xpid`), sweeps its process group for any TiffinBox JVM left, deletes the capture runs it had not finished (`.r-NAME.1-3`),
and removes `.r-lock`. The published captures are untouched. **Measured** (the receipt in its own process group, SIGINT to the whole group once 19344 listened — `catchall`'s A, about 52 s in):
**exit 130**; 0 processes left in the group; 19340-19349, 8080 and 18425 free; no JVM with its folder here; no `.r-lock`; no
unfinished capture run; the published captures unchanged.

## 1 · table — the routing table, filled (C6-4)

The anchor on the plain JVM with the exposure list for one run; Tomcat's own line, the address read off the process; the table read by
`harness/table.py`: 1 context, 3 kinds (`dispatcherServlets`, `servletFilters`, `servlets`); 14 rows for the `DispatcherServlet` —
Actuator's 5, **TiffinBox's 5 (rows 6-10, `TiffinBox route /customers` …)**, `/error` ×2, `/webjars/**` and `/**`; 7 with details, 7
without, 5 naming a verb (all GET); 5 filters, each on `/*`; 1 servlet. The check that each TiffinBox row is named for its own path
(and no handler is a lambda's generated name) passes here, and fails on a planted copy of the same answer. Then the seven, with
`mappings` exposed: `571faaea…`, the comparison set since the embedded-Tomcat lesson.

`.r-table.out` · md5 `452ba448ecb8e205a92d57433320b149` · 3 of 3

```
the anchor, copied under .harness/ with a config tree, built with its README's line (offline):
$ cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the anchor · offline: yes · exit 0
  the exposure list it was built with (application.yaml): include: health,prometheus
the anchor on the plain JVM, the exposure list given for this one run (this unit's line), port 19340:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19340 --management.endpoints.web.exposure.include=health,prometheus,mappings
  listens on: 127.0.0.1:19340 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19340/actuator/health/readiness
  {"status":"UP"} 200
  Tomcat's own line: Tomcat started on port 19340 (http) with context path '/'
$ curl -s http://127.0.0.1:19340/actuator/mappings | python3 harness/table.py
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
  TiffinBox's rows (a handler named "TiffinBox route /…"): 5 · each named for its own path: 5 · a lambda's name ($$Lambda): 0
  servletFilters: 5, by name: characterEncodingFilter, formContentFilter, requestContextFilter, Tomcat WebSocket (JSR356) Filter, webMvcObservationFilter · on /* : 5
  servlets: 1 · dispatcherServlet on /
the same check - every TiffinBox row named for its path, no lambda - run on a planted copy of this answer, /kitchen's handler given a lambda's name:
  TiffinBox's rows (a handler named "TiffinBox route /…"): 4 · each named for its own path: 4 · a lambda's name ($$Lambda): 1
the seven - the comparison set, with mappings exposed:
$ $CURLSET 19340 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 1 · md5 571faaea42e87e85add8c9548c64c961
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 2 · adapter — who answers /actuator: the bridge against Boot's own adapter (C6-16, C6-12)

The previous tree, one JVM run with the same flag: its bridge (`ActuatorRoutes.java`, 196 lines; Boot's `WebMvcEndpointHandlerMapping`
in none of its jar's 46 libraries); TiffinBox's own line; `/actuator/mappings` → `{"contexts":{"application":{"mappings":{},"parentId":null}}}`
— 1 context, 0 kinds, Course 5's finale's answer again; health and the scrape with their content types; `/actuator` 404; the seven,
`115c36ba…`. Then the anchor: the bridge deleted, Boot's class in `spring-boot-webmvc-4.1.1.jar` (one of 58); the table's counts (14 · 5 ·
1); **the same two content types**; `/actuator` 200, its links `health health-path mappings prometheus self`.

`.r-adapter.out` · md5 `b9cfe3b9589e5416f2db62da7b32c056` · 3 of 3

```
before - the previous tree: TiffinBox's own server, and its bridge (ActuatorRoutes), copied with a config tree, built with the README's line (offline):
$ cd .harness/before && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the previous tree · offline: yes · exit 0
  ActuatorRoutes.java: 196 lines · Boot's adapter, WebMvcEndpointHandlerMapping, in its jar's libraries: in none (of its 46 jars)
the previous tree, the same line, port 19341:
$ cd .harness/before && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19341 --management.endpoints.web.exposure.include=health,prometheus,mappings
  listens on: 127.0.0.1:19341 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19341/actuator/health/readiness
  {"status":"UP"} 200
  its own line: TiffinBox listening on http://127.0.0.1:19341
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19341/actuator/mappings
  {"contexts":{"application":{"mappings":{},"parentId":null}}} 200
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19341/actuator/health
  200 application/vnd.spring-boot.actuator.v3+json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19341/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19341/actuator
  404 application/json
$ $CURLSET 19341 .harness/before/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
after - the anchor (built in table): Tomcat, and Boot's own Actuator adapter:
  ActuatorRoutes.java: deleted · Boot's adapter, WebMvcEndpointHandlerMapping, in its jar's libraries: spring-boot-webmvc-4.1.1.jar (of its 58 jars)
the anchor, the same line, port 19342:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19342 --management.endpoints.web.exposure.include=health,prometheus,mappings
  listens on: 127.0.0.1:19342 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19342/actuator/health/readiness
  {"status":"UP"} 200
  Tomcat's own line: Tomcat started on port 19342 (http) with context path '/'
$ curl -s http://127.0.0.1:19342/actuator/mappings | python3 harness/table.py count
  contexts: 1 (application) · kinds: 3 (dispatcherServlets servletFilters servlets) · rows: dispatcherServlet 14, servletFilters 5, servlets 1
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19342/actuator/health
  200 application/vnd.spring-boot.actuator.v3+json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19342/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19342/actuator
  200 application/vnd.spring-boot.actuator.v3+json
$ curl -s http://127.0.0.1:19342/actuator | python3 harness/table.py links
  the links: health health-path mappings prometheus self
$ harness/shutdown.sh 19342 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19342 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 3 · rows — what a row says

`harness/table.py row`: Actuator's health row has 3 keys — `details` (its handler method, Boot's
`AbstractWebMvcEndpointHandlerMapping.OperationHandler#handle`; its conditions, `methods ["GET"]`, its pattern, the three types it
produces), `handler`, `predicate`; TiffinBox's `/customers` row has 2 — `handler = TiffinBox route /customers`, `predicate = /customers`
— and no `details` at all. Then DELETE on each path: Spring answers health itself — its JSON 405 and `Allow: GET`; TiffinBox's own
handler answers `/customers` — `{"error":"method not allowed"}`, 405, no `Allow` header: the table never knew the verb.

`.r-rows.out` · md5 `fe3370d32a3fa12bf19942d063e5cb32` · 3 of 3

```
the anchor on the plain JVM, the exposure list given for this one run (this unit's line), port 19343:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19343 --management.endpoints.web.exposure.include=health,prometheus,mappings
  listens on: 127.0.0.1:19343 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19343/actuator/health/readiness
  {"status":"UP"} 200
  Tomcat's own line: Tomcat started on port 19343 (http) with context path '/'
$ curl -s http://127.0.0.1:19343/actuator/mappings | python3 harness/table.py row /actuator/health /customers
  the row for /actuator/health: 1
  /actuator/health - 3 keys: details handler predicate
    details.handlerMethod.className = org.springframework.boot.webmvc.actuate.endpoint.web.AbstractWebMvcEndpointHandlerMapping.OperationHandler
    details.handlerMethod.descriptor = (Ljakarta/servlet/http/HttpServletRequest;Ljava/util/Map;)Ljava/lang/Object;
    details.handlerMethod.name = handle
    details.requestMappingConditions.consumes = []
    details.requestMappingConditions.headers = []
    details.requestMappingConditions.methods = ["GET"]
    details.requestMappingConditions.params = []
    details.requestMappingConditions.patterns = ["/actuator/health"]
    details.requestMappingConditions.produces[0].mediaType = application/vnd.spring-boot.actuator.v3+json
    details.requestMappingConditions.produces[0].negated = false
    details.requestMappingConditions.produces[1].mediaType = application/vnd.spring-boot.actuator.v2+json
    details.requestMappingConditions.produces[1].negated = false
    details.requestMappingConditions.produces[2].mediaType = application/json
    details.requestMappingConditions.produces[2].negated = false
    handler = Actuator web endpoint 'health'
    predicate = {GET [/actuator/health], produces [application/vnd.spring-boot.actuator.v3+json || application/vnd.spring-boot.actuator.v2+json || application/json]}
  the row for /customers: 1
  /customers - 2 keys: handler predicate
    handler = TiffinBox route /customers
    predicate = /customers
a wrong verb on each row's path - DELETE: the answer, its status, and the Allow header (empty when there is none):
$ curl -s -X DELETE -w ' %{http_code} allow=%header{allow}\n' http://127.0.0.1:19343/actuator/health
  {"error":"Method Not Allowed","path":"/actuator/health","status":405,"timestamp":"…"} 405 allow=GET    (keys sorted)
$ curl -s -X DELETE -w ' %{http_code} allow=%header{allow}\n' http://127.0.0.1:19343/customers
  {"error":"method not allowed"} 405 allow=
$ harness/shutdown.sh 19343 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19343 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 4 · catchall — the two rows that catch every path (A/B/A′)

Boot's metadata (`spring.web.resources.add-mappings` default `true`). **A** — the anchor with Boot's web log group at DEBUG: at start,
`Patterns [/webjars/**, /**] in 'resourceHandlerMapping'` beside TiffinBox's `tiffinBoxRoutes`; the table, 14 rows, the two static ones
last; `/customers` → `Mapped to TiffinBox route /customers`; `/nowhere` → `Mapped to ResourceHttpRequestHandler […]`, `Resource not
found`, `NoResourceFoundException`, the ERROR dispatch to `BasicErrorController#error` — 10 lines — and Spring's JSON 404. **B** —
`--spring.web.resources.add-mappings=false`: no `resourceHandlerMapping` at start; 12 rows, neither `**` row; `/nowhere` → `No mapping
for GET /nowhere` (WARN), `NoHandlerFoundException`, the same ERROR dispatch — 10 lines — and **the same 404 body** (masked). **A′** = A,
line for line.

`.r-catchall.out` · md5 `5283262f2f1e8e2d61917201321652bb` · 3 of 3

```
Boot's own metadata, in the anchor's jar: spring.web.resources.add-mappings default true (spring-boot-autoconfigure-4.1.1.jar)
A - the anchor on the plain JVM, the exposure list for this one run, Boot's web log group at DEBUG (this unit's line), port 19344:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19344 --management.endpoints.web.exposure.include=health,prometheus,mappings --logging.level.web=debug
  listens on: 127.0.0.1:19344 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19344/actuator/health/readiness
  {"status":"UP"} 200
  Tomcat's own line: Tomcat started on port 19344 (http) with context path '/'
  at start, the handler mappings that logged their patterns: Patterns [/customers, /dashboard, /kitchen, /revenue, /shutdown] in 'tiffinBoxRoutes'|2 mappings in 'requestMappingHandlerMapping'|Patterns [/webjars/**, /**] in 'resourceHandlerMapping'
$ curl -s http://127.0.0.1:19344/actuator/mappings | python3 harness/table.py
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
  TiffinBox's rows (a handler named "TiffinBox route /…"): 5 · each named for its own path: 5 · a lambda's name ($$Lambda): 0
  servletFilters: 5, by name: characterEncodingFilter, formContentFilter, requestContextFilter, Tomcat WebSocket (JSR356) Filter, webMvcObservationFilter · on /* : 5
  servlets: 1 · dispatcherServlet on /
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19344/customers
  200 application/json
  its lines at DEBUG and WARN - 3 (its other lines: 0):
    o.s.web.servlet.DispatcherServlet: GET "/customers", parameters={}
    o.s.w.s.handler.SimpleUrlHandlerMapping: Mapped to TiffinBox route /customers
    o.s.web.servlet.DispatcherServlet: Completed 200 OK
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19344/nowhere
  {"error":"Not Found","path":"/nowhere","status":404,"timestamp":"…"} 404    (keys sorted)
  its lines at DEBUG and WARN - 10 (its other lines: 0):
    o.s.web.servlet.DispatcherServlet: GET "/nowhere", parameters={}
    o.s.w.s.handler.SimpleUrlHandlerMapping: Mapped to ResourceHttpRequestHandler [classpath [META-INF/resources/], classpath [resources/], classpath [static/], classpath [public/], ServletContext [/]]
    o.s.w.s.r.ResourceHttpRequestHandler: Resource not found for path [nowhere]
    .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.servlet.resource.NoResourceFoundException: No static resource nowhere for request '/nowhere'.]
    o.s.web.servlet.DispatcherServlet: Completed 404 NOT_FOUND
    o.s.web.servlet.DispatcherServlet: "ERROR" dispatch for GET "/error", parameters={}
    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to org.springframework.boot.webmvc.autoconfigure.error.BasicErrorController#error(HttpServletRequest)
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Writing [{timestamp=…, status=404, error=Not Found, path=/nowhere}]
    o.s.web.servlet.DispatcherServlet: Exiting from "ERROR" dispatch, status 404
$ harness/shutdown.sh 19344 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19344 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the same, and the static-resource mappings off (this unit's line):
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19344 --management.endpoints.web.exposure.include=health,prometheus,mappings --logging.level.web=debug --spring.web.resources.add-mappings=false
  listens on: 127.0.0.1:19344 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19344/actuator/health/readiness
  {"status":"UP"} 200
  Tomcat's own line: Tomcat started on port 19344 (http) with context path '/'
  at start, the handler mappings that logged their patterns: Patterns [/customers, /dashboard, /kitchen, /revenue, /shutdown] in 'tiffinBoxRoutes'|2 mappings in 'requestMappingHandlerMapping'
$ curl -s http://127.0.0.1:19344/actuator/mappings | python3 harness/table.py
  contexts: 1 (application) · kinds: 3 (dispatcherServlets servletFilters servlets)
  dispatcherServlets · dispatcherServlet: 12 rows, in the table's order - a run of rows with details sorted by pattern (produces lists cut: 5 · class names cut to their last part: 2)
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
  rows with details: 7 · without: 5 · naming a verb: 5 (GET 5)
  TiffinBox's rows (a handler named "TiffinBox route /…"): 5 · each named for its own path: 5 · a lambda's name ($$Lambda): 0
  servletFilters: 5, by name: characterEncodingFilter, formContentFilter, requestContextFilter, Tomcat WebSocket (JSR356) Filter, webMvcObservationFilter · on /* : 5
  servlets: 1 · dispatcherServlet on /
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19344/customers
  200 application/json
  its lines at DEBUG and WARN - 3 (its other lines: 0):
    o.s.web.servlet.DispatcherServlet: GET "/customers", parameters={}
    o.s.w.s.handler.SimpleUrlHandlerMapping: Mapped to TiffinBox route /customers
    o.s.web.servlet.DispatcherServlet: Completed 200 OK
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19344/nowhere
  {"error":"Not Found","path":"/nowhere","status":404,"timestamp":"…"} 404    (keys sorted)
  its lines at DEBUG and WARN - 10 (its other lines: 0):
    o.s.web.servlet.DispatcherServlet: GET "/nowhere", parameters={}
    WARN o.s.web.servlet.PageNotFound: No mapping for GET /nowhere
    WARN o.s.web.servlet.PageNotFound: No endpoint GET /nowhere.
    .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.servlet.NoHandlerFoundException: No endpoint GET /nowhere.]
    o.s.web.servlet.DispatcherServlet: Completed 404 NOT_FOUND
    o.s.web.servlet.DispatcherServlet: "ERROR" dispatch for GET "/error", parameters={}
    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to org.springframework.boot.webmvc.autoconfigure.error.BasicErrorController#error(HttpServletRequest)
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Writing [{timestamp=…, status=404, error=Not Found, path=/nowhere}]
    o.s.web.servlet.DispatcherServlet: Exiting from "ERROR" dispatch, status 404
$ harness/shutdown.sh 19344 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19344 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19344 --management.endpoints.web.exposure.include=health,prometheus,mappings --logging.level.web=debug
  listens on: 127.0.0.1:19344 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19344/actuator/health/readiness
  {"status":"UP"} 200
  Tomcat's own line: Tomcat started on port 19344 (http) with context path '/'
  at start, the handler mappings that logged their patterns: Patterns [/customers, /dashboard, /kitchen, /revenue, /shutdown] in 'tiffinBoxRoutes'|2 mappings in 'requestMappingHandlerMapping'|Patterns [/webjars/**, /**] in 'resourceHandlerMapping'
$ curl -s http://127.0.0.1:19344/actuator/mappings | python3 harness/table.py
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
  TiffinBox's rows (a handler named "TiffinBox route /…"): 5 · each named for its own path: 5 · a lambda's name ($$Lambda): 0
  servletFilters: 5, by name: characterEncodingFilter, formContentFilter, requestContextFilter, Tomcat WebSocket (JSR356) Filter, webMvcObservationFilter · on /* : 5
  servlets: 1 · dispatcherServlet on /
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19344/customers
  200 application/json
  its lines at DEBUG and WARN - 3 (its other lines: 0):
    o.s.web.servlet.DispatcherServlet: GET "/customers", parameters={}
    o.s.w.s.handler.SimpleUrlHandlerMapping: Mapped to TiffinBox route /customers
    o.s.web.servlet.DispatcherServlet: Completed 200 OK
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19344/nowhere
  {"error":"Not Found","path":"/nowhere","status":404,"timestamp":"…"} 404    (keys sorted)
  its lines at DEBUG and WARN - 10 (its other lines: 0):
    o.s.web.servlet.DispatcherServlet: GET "/nowhere", parameters={}
    o.s.w.s.handler.SimpleUrlHandlerMapping: Mapped to ResourceHttpRequestHandler [classpath [META-INF/resources/], classpath [resources/], classpath [static/], classpath [public/], ServletContext [/]]
    o.s.w.s.r.ResourceHttpRequestHandler: Resource not found for path [nowhere]
    .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.servlet.resource.NoResourceFoundException: No static resource nowhere for request '/nowhere'.]
    o.s.web.servlet.DispatcherServlet: Completed 404 NOT_FOUND
    o.s.web.servlet.DispatcherServlet: "ERROR" dispatch for GET "/error", parameters={}
    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to org.springframework.boot.webmvc.autoconfigure.error.BasicErrorController#error(HttpServletRequest)
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Writing [{timestamp=…, status=404, error=Not Found, path=/nowhere}]
    o.s.web.servlet.DispatcherServlet: Exiting from "ERROR" dispatch, status 404
$ harness/shutdown.sh 19344 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19344 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 5 · exposure — C (labelled): the AOT jar (R.69; RE-MEASURE 9)

The anchor built with the profile native (offline; the exposure list it was built with, `health,prometheus`), run with the anchor
README's AOT line and the same flag: `Starting AOT-processed TiffinBoxServer`; `/actuator/mappings` → 404; the links `health health-path
prometheus self` — no `mappings`. On the plain JVM the same flag lists it (`adapter`).

`.r-exposure.out` · md5 `8305170c0b56f2599d536b2b95766854` · 3 of 3

```
C (labelled) - the AOT jar: the anchor built with the profile native (its README's line: Spring's AOT step, run at build), copied with a config tree:
$ cd .harness/aot && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean package
  built the anchor, the profile native · offline: yes · exit 0
  the exposure list it was built with (application.yaml): include: health,prometheus
the anchor README's AOT line, the same exposure list for this one run (this unit's line), port 19345:
$ cd .harness/aot && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19345 --management.endpoints.web.exposure.include=health,prometheus,mappings
  listens on: 127.0.0.1:19345 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19345/actuator/health/readiness
  {"status":"UP"} 200
  Tomcat's own line: Tomcat started on port 19345 (http) with context path '/'
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19345/actuator/mappings
  404 application/json
$ curl -s http://127.0.0.1:19345/actuator | python3 harness/table.py links
  the links: health health-path prometheus self
$ harness/shutdown.sh 19345 .harness/aot/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19345 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 6 · exercise — the exercise, run as written

`exercise/README.md`'s commands, read from the file and run exactly as written (as shipped: `mapping`, singular), then
`exercise/solution/SOLUTION.md`'s line (`mappings`).

`.r-exercise.out` · md5 `4ad5cd04417c1c204e969ccc50ef9705` · 3 of 3

```
exercise/README.md's commands, run exactly as written from this folder - 7 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/tree/
  $ mkdir -p .harness/mine/tree/secrets/tiffinbox && chmod 700 .harness/mine/tree/secrets .harness/mine/tree/secrets/tiffinbox
  $ (umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/tree/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/tree && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package)
  $ cd .harness/mine/tree && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19349 --management.endpoints.web.exposure.include=health,prometheus,mapping > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19349/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s http://127.0.0.1:19349/actuator/mappings > ../answer.json && ../../../harness/shutdown.sh 19349 secrets/tiffinbox/shutdown-token > /dev/null && wait && python3 ../../../harness/table.py tiffinbox < ../answer.json
  exit 0 · what they printed:
    TiffinBox's rows: 0 · not a routing table: status 404
  the copy's own token in its log: 0 times · listening on 19349 now: 0
  its log, at INFO (Boot's default): Exposing 2 endpoints beneath base path '/actuator' · lines that name mapping: 0 · WARN: 0 · ERROR: 0
the solution's line (exercise/solution/SOLUTION.md), run exactly as written, from this folder:
$ cd .harness/mine/tree && { java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19349 --management.endpoints.web.exposure.include=health,prometheus,mappings > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19349/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s http://127.0.0.1:19349/actuator/mappings > ../answer.json && ../../../harness/shutdown.sh 19349 secrets/tiffinbox/shutdown-token > /dev/null && wait && python3 ../../../harness/table.py tiffinbox < ../answer.json
  exit 0 · what it printed:
    TiffinBox's rows: 5 · the verbs the table gives them: none
  the copy's own token in its log: 0 times · listening on 19349 now: 0
  its log, at INFO (Boot's default): Exposing 3 endpoints beneath base path '/actuator' · lines that name mapping: 0 · WARN: 0 · ERROR: 0
```

## Exercise

**Your turn:** expose mappings for one run, count TiffinBox's own rows, and name the verbs the table gives them. `exercise/README.md`
has the commands (copy the anchor with a token of its own, build it offline); its last line starts TiffinBox on 19349 with an exposure
list for one run, saves `/actuator/mappings`, stops it, and reads the answer with `harness/table.py tiffinbox` — as shipped it prints
`TiffinBox's rows: 0 · not a routing table: status 404` (`mapping` names no endpoint). Done is `TiffinBox's rows: 5 · the verbs the
table gives them: none`. Measured answer: `exercise/solution/SOLUTION.md`. Run `./receipts.sh` once first on a fresh clone.

## RE-MEASURE — the brief's item this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-13) |
|---|---|---|---|
| 9 | `mappings` under AOT with the exposure flag | not run on the switch tree | **`/actuator/mappings` → 404; the links `health health-path prometheus self`** — the AOT jar, the same flag (`exposure`) |

## Found on the way

- **Two runs, two orders.** The rows a `RequestMappingInfo` describes — Actuator's five, `/error`'s two — came out of the table in
  another order in each of two runs; TiffinBox's five and the two static rows did not move (each from a `SimpleUrlHandlerMapping`'s
  table). `harness/table.py` sorts each run of rows with details by pattern, and says so on its header line; the captures went 3 of 3
  only after that.
- **No `details: null`.** TiffinBox's rows carry no `details` key at all: Boot's adapter leaves a null out (0 `null` in its answer, and
  no `parentId`), where the bridge printed `"parentId":null` (`adapter`, before). The voice says "two things": a path and a handler's
  name.
- **A misspelt endpoint id is silent.** `--management.endpoints.web.exposure.include=health,prometheus,mapping` starts, names no
  `mapping` in its log, and logs no WARN or ERROR; the one hint is Actuator's count at INFO — `Exposing 2 endpoints beneath base path
  '/actuator'` against 3 (`exercise`).
- **Two curl lines came out escaped** at first: Python's JSON writer escapes `…` as `…` unless told not to. `sortj` and
  `harness/table.py` read and write UTF-8 themselves, whatever your locale.

## For RED (part B: 04-05)

- The table's 14 rows, TiffinBox's 5 named for their paths, the planted lambda caught (`table`); the bridge measured, not cited
  (`adapter`); A/B/A′ on `spring.web.resources.add-mappings` with one exposure list throughout (`catchall` — the brief's 13 → 11 came
  from `health,mappings`; here 14 → 12); the AOT jar's 404 (`exposure`).
- Departures from the brief, argued in the script's Director's Note: one exposure list; no `details` key (not `details: null`); the
  RequestMappingInfo runs sorted; nothing in the voice says "logged" (B's two `PageNotFound` lines are WARN, shown from a DEBUG run).
- Section 2's first lesson, *@RestController and Request Mapping*, turns TiffinBox's five rows into Spring's own: verbs in the
  `predicate`, `details` with a handler method — this unit's `rows` is the before.
