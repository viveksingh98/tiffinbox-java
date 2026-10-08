# c5-unit30 — What's Next: The Web Layer

Course 5 · Spring Boot · Section 5, its last unit, and the course's · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot
4.1.1**, 2026-10-08. TiffinBox has answered HTTP since Core Java II through a server of its own: the JDK's `jdk.httpserver`, with a
router built by reflection from `@Route`. This unit measures what that server does on today's tree — how it matches a path, what
answers a path it does not know, a wrong verb, another format; what Boot's routing table knows of it — and which of TiffinBox's files
do the web's jobs. The next course, **Spring Web MVC**, hands those jobs to Spring; the video names each one's lesson by title (read
from the track roadmap by the deck's builder) and teaches none of them.

**No code change (brief ⚑14).** The tree is `../c5-unit27/after`, reached through the link `anchor` (so no capture prints a unit
folder). It is read and copied under `.harness/`, never built in place; `pieces` checks the copy against it (`diff -rq`: 0). When this
unit was measured, `diff -rq -x target ../c5-tiffinbox anchor/` was empty: this tree is the anchor, and it goes on to the next course
(ledger P3). **One file outside this folder changes:** the repository's `README.md`: the roadmap line (line 447 then, 456 now — ledger P11; `readme`), and, by BLUE, its title, its folder
map and two course sections, which named Courses 1-3 only (RED C5-S5 #44; `readme` shows them).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 3 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) No GraalVM, no
Docker. It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first). It needs a **full clone**:
`readme` reads the README as commit `53379bd` (the last before this unit) had it, with `git show`.
**Runs of record (2026-10-08):** **37 s under `./receipts.sh`** (/bin/bash 3.2.57, this folder, exit 0, all 3 captures = published,
every check passed); **36 s under `bash receipts.sh`** (Homebrew bash 5.3.9, the same); and the sealed clone below (bash 5.3.9, 38 s).
Load averages about 4.
Published hashes: seam `d1d10087124fad2a0a480783d3e2f91c` · pieces `902a804dcf07a625c70681d80656024b` · readme `bb4db1efcfed9a697474207c7dbec305`

## The repository, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2`), seeded from `../../spring-boot/_research/m2-seed-s5/`
**less `com/tiffinbox/`** (5,568 files; brief S5.3). **Nothing was downloaded** for this unit: the one build said `offline: yes`. It
is the README's plain `mvn -B package`, made before the captures (on a fresh clone it fills `.m2-demo`); no capture builds anything,
and none uses the README's class-path line, so Maven's dependency plugin is not needed (unit 27's finding does not apply). At run time
nothing leaves 127.0.0.1.

**From a clone, sealed (2026-10-08, brief S5.2).** The repository was cloned (`git clone` of the local repository at this unit's
first commit, `dd5852d`) into an empty folder — nothing git ignores: no `.m2-demo`, no `.harness/`, no `.r-*`; this README is the
only file changed since, by this paragraph and the two notes beside it. `bash receipts.sh` (Homebrew bash 5.3.9) ran under `env -i`,
with a `HOME` whose `.mavenrc` points Maven's `user.home` there (Java reads `user.home` from the account, not from `$HOME`) and every
Java proxy property at a port that refuses (127.0.0.1:9); Maven settings that send every repository to a `file://` copy of Central's
files made from `.m2-demo` (4,164 files: TiffinBox's own installs, `_remote.repositories`, `*.lastUpdated`,
`resolver-status.properties` and `.DS_Store` left out, `maven-metadata-central.xml` served as `maven-metadata.xml`); `http_proxy`,
`https_proxy`, their capitals and `ALL_PROXY` at the same refusing port. **Exit 0 after 38 s** — all 3 captures = published, every
spoken number asserted, 0 raw demo tokens. The one build, before the captures, said `offline: no`: 494 artifacts, every one
`Downloaded from sealed: file://…` (0 from anywhere else); `.m2-demo` ended with 1,333 files; the sealed `HOME` ended holding its
`.mavenrc` and `.m2/settings.xml` alone.

## The demo token — fake, and never printed

TiffinBox does not start without its shutdown token. Every run starts in `.harness/serve`, holding a config tree,
`secrets/tiffinbox/shutdown-token` (`-rw-------`, folders `drwx------`), with a 26-character demo token that is fake and looks it.
The token never reaches a command line: the seven requests read it from the file. Every capture is masked, and `receipts.sh` counts
the raw token in each run's own output **before** masking (0 in all 9 capture runs), and in the log of **every JVM that served**
(the token and the header's name `X-Shutdown-Token`, in any case: 0, six runs per receipt); then in every capture, this README, the
harness, the repository's README and `receipts.md5`: 0 each. The builder counts it again in the script, the deck and the prompter: 0.

## The folders, the names and the ports

- `anchor` → `../c5-unit27/after` (a link, committed). `.harness/serve/` — the tree with a config tree, built once with the README's
  plain line; both runs of `seam` start there.
- **The harness** is `harness/shutdown.sh` (unit 29's, unchanged; not used by a capture here) and `harness/Prefix.java` (`seam` E:
  three JDK contexts, no TiffinBox class, its own requests through the JDK's `HttpClient`, stopped before it exits). `$CURLSET` = `../c5-unit11/curlset.sh`,
  the seven requests.
- **Ports (brief ⚑1, 19160-19169):** `seam`'s A-C 19160 · its D 19161 · its E 19162. 18425 (TiffinBox's default) and 8080 (Tomcat's) are checked
  free and never bound. Nothing listened on 19160-19169 before or after any run here.
- **The commands** are the anchor README's, read and asserted (`readme()`): `mvn -B package`; the run line; the DEBUG line
  (`--logging.level.kitchen=debug`); the exposure line with `health,env` → `health,mappings` (D); the readiness line; the `/customers`
  curl line with ` %{content_type}` added after the status — this unit's one change to it, asserted. Each run's port is the unit's.

## Masks, filters and hygiene — every one, declared

1. **Paths, the token, the user** (`gsub()`, literals escaped), in every line: the token → `[masked: the 26-character token]`; this
   folder → `…`; the folder above → `…/..`; home → `~`; the user name → `<user>`. A last check fails if any capture holds `/Users/`,
   `/private/`, `/home/`, `/var/folders/`, a unit number, Boot's process line, a log time, a thread number, a stack frame or a build
   that went online.
2. **TiffinBox's answer lines at DEBUG** (logger `tiffinbox`, `ROUTE -> STATUS`) are printed from their message on, each with what
   its thread is — "a virtual thread" when Boot's log names it `virtual-N` (the number cut), else "another thread"; counted per
   request and per run. The startup's `route …` lines are not answer lines.
3. **The timer** is read from a scrape (`/actuator/prometheus`, through the bridge, which neither logs nor times): its
   `tiffinbox_requests_seconds_count` lines only, sorted. Per request, the series that moved are printed (`(new)` for a series that did
   not exist). **Settling:** TiffinBox writes an answer's line and stops its timer just after the answer leaves, so after each request
   the script waits until the timer's total equals the count of answer lines and nothing moved for half a second (up to 20 s, then
   it dies) — never a fixed sleep before a count.
4. **Actuator's JSON** (`mappings`) is printed with its keys sorted, marked `# keys sorted` (the bridge writes keys in reflection's
   order: the health lesson's finding).
5. **No duration is captured.**
6. **Hygiene:** the S5.15 loop (`sed -E`, a planted canary under every name, the run stops if one survives) over every `TIFFINBOX_*`,
   `SPRING_*`, `MANAGEMENT_*`, `SERVER_*`, `LOGGING_*` variable, `DEBUG`, `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`, `_JAVA_OPTIONS`,
   `MAVEN_OPTS`, `MAVEN_ARGS`, `NATIVE_IMAGE_OPTIONS` (no Docker here, so no `COMPOSE_*`). `127.0.0.1` first in `no_proxy`/`NO_PROXY`.
   One run at a time (`.r-lock`).

**Interrupted.** `receipts.sh`'s exit trap stops the server it started in the background (`$pid`) if it still runs, then `sweep()`s
this run's process group (a TiffinBox JVM, a Maven build) — TERM, then KILL after 5 s — deletes the capture runs left unfinished
(`.r-NAME.1-3`) after an interrupt, and drops the lock. **Tested 2026-10-08 on the final script, from the sealed clone**,
`receipts.sh` as a job of its own process group under `env -i`, and `SIGINT` sent to the whole group once `seam`'s JVM listened on
19160 (3 processes in the group): **exit 130**; 5 s later 0 processes in the group, 0 TiffinBox JVMs; 18425, 8080 and 19160-19169
free; `.r-lock` gone; 0 unfinished capture files.

**Planted faults** (S5.18, 2026-10-08), each on a copy of the published captures, the checks run once on each: B's timer line made
`GET /customersXYZ (new) -> 1` → `seam B: timed as GET /customers`; C given a DEBUG line → `seam C: no line`; B's byte-for-byte made
`no` → `seam B: byte for byte`; `mappings` given one kind → `seam D: 1 context, 0 kinds`; one answer off a virtual thread (13 / 12) →
`seam: every answer line on a virtual thread`; the README line left skipping Web MVC → `readme: expected …`; a typed-path series
counted 1 → `seam: expected …`; the token appended raw to `pieces` → `holds the demo token, raw`; the web files made 5 → `pieces: 4
files, 548`. Each check died on its fault, and every check passed on the published captures. The gate's "magic" check
(`check_unit5.py`, P29) was planted too, on a copy of this unit's triple: one spoken "No magic." → `'magic' reaches no viewer … — found
['magic']`, FAIL.

## 1 · seam — what TiffinBox's own server does

A/B/A′ and C on the README's DEBUG line (port 19160): A `GET /customers`; B `GET /customersXYZ` — the same answer byte for byte,
logged and timed as `GET /customers` (the JDK's contexts match by prefix: `/customers` takes every path that starts with it, and of
several contexts the longest prefix wins — E, below); A′ = A;
C (labelled) `GET /nowhere` — the JDK's HTML 404, no line, no series. Then a trailing slash and a longer path (prefix again), a wrong
verb (TiffinBox's JSON 405, `UNKNOWN`), `Accept: application/xml` (JSON regardless), `/actuator` and `/actuator/mappings` (the bridge's
404, untimed); the timer's series (none names a typed path); the seven and the lines they added (5 routes, 1 `UNKNOWN`, `/nowhere`
none); every answer on a virtual thread, 13 distinct (the thread's number counted before it is cut: a pool of one thread would print
1 — RED C5-S5 #50). D (labelled): the README's exposure line with `mappings`, one run, the JVM (brief S5.22): Boot's routing table,
one context, nothing in it. E (labelled): the JDK's own rule, without TiffinBox — `harness/Prefix.java` (a single source file) makes
three contexts in this order, `/c`, `/customers`, `/customersX`, on 127.0.0.1:19162: `/customersXYZ` reaches `/customersX` (made last),
not `/c` (made first), so the JDK picks the **longest** matching prefix, not the first (RED C5-S5 #42); `/cat` → `/c`, `/nowhere` → 404.

`.r-seam.out` · md5 `d1d10087124fad2a0a480783d3e2f91c` · 3 of 3

```
A, B, A' and C - the README's DEBUG line (the log group kitchen at DEBUG), from .harness/serve, port 19160:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19160 --logging.level.kitchen=debug
  listens on: 127.0.0.1:19160
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19160/actuator/health/readiness
  {"status":"UP"} 200
  the routes TiffinBox mapped, its own log line: [GET /customers, GET /dashboard, GET /kitchen, GET /revenue, POST /shutdown]
A - GET /customers, the path a route declares:
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19160/customers
  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 application/json
  its lines at DEBUG: 1
    GET /customers -> 200    (on a virtual thread)
  the timer's series it moved: 1
    tiffinbox_requests_seconds_count{route="GET /customers",status="200"} (new) -> 1
B - GET /customersXYZ, three letters more:
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19160/customersXYZ
  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 application/json
  the same answer as A's, byte for byte: yes
  its lines at DEBUG: 1
    GET /customers -> 200    (on a virtual thread)
  the timer's series it moved: 1
    tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 1 -> 2
A' - A again:
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19160/customers
  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 application/json
  the same answer as A's, byte for byte: yes
  its lines at DEBUG: 1
    GET /customers -> 200    (on a virtual thread)
  the timer's series it moved: 1
    tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 2 -> 3
C (labelled) - GET /nowhere, a path no route declares:
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19160/nowhere
  <h1>404 Not Found</h1>No context found for request 404 text/html
  the same answer as A's, byte for byte: no
  its lines at DEBUG: 0
  the timer's series it moved: 0
the rest of the server's jobs:
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19160/customers/
  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}] 200 application/json
  the same answer as A's, byte for byte: yes
  its lines at DEBUG: 1
    GET /customers -> 200    (on a virtual thread)
  the timer's series it moved: 1
    tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 3 -> 4
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19160/kitchen/anything
  {"ordersCooked":120,"ordersValue":24300} 200 application/json
  its lines at DEBUG: 1
    GET /kitchen -> 200    (on a virtual thread)
  the timer's series it moved: 1
    tiffinbox_requests_seconds_count{route="GET /kitchen",status="200"} (new) -> 1
$ curl -s -w ' %{http_code} %{content_type}\n' -X DELETE http://127.0.0.1:19160/customers
  {"error":"method not allowed"} 405 application/json
  its lines at DEBUG: 1
    UNKNOWN -> 405    (on a virtual thread)
  the timer's series it moved: 1
    tiffinbox_requests_seconds_count{route="UNKNOWN",status="405"} (new) -> 1
$ curl -s -w ' %{http_code} %{content_type}\n' -H 'Accept: application/xml' http://127.0.0.1:19160/kitchen
  {"ordersCooked":120,"ordersValue":24300} 200 application/json
  its lines at DEBUG: 1
    GET /kitchen -> 200    (on a virtual thread)
  the timer's series it moved: 1
    tiffinbox_requests_seconds_count{route="GET /kitchen",status="200"} 1 -> 2
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19160/actuator
  {"error":"not found"} 404 application/json
  its lines at DEBUG: 0
  the timer's series it moved: 0
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19160/actuator/mappings
  {"error":"not found"} 404 application/json
  its lines at DEBUG: 0
  the timer's series it moved: 0
the timer's series now - their route tags, and how many answers each counted:
  tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 4
  tiffinbox_requests_seconds_count{route="GET /kitchen",status="200"} 2
  tiffinbox_requests_seconds_count{route="UNKNOWN",status="405"} 1
  series whose route is a path as typed (/customersXYZ, /customers/, /kitchen/anything, /nowhere, /actuator): 0
the seven, then the lines they added at DEBUG (read after the server stopped):
$ $CURLSET 19160 .harness/serve/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  their lines at DEBUG: 6
    GET /customers -> 200    (on a virtual thread)
    GET /revenue -> 200    (on a virtual thread)
    GET /dashboard -> 200    (on a virtual thread)
    GET /kitchen -> 200    (on a virtual thread)
    UNKNOWN -> 405    (on a virtual thread)
    POST /shutdown -> 200    (on a virtual thread)
  answered by a route TiffinBox declares: 5 · by TiffinBox's server with no route (UNKNOWN): 1 · never reached TiffinBox (no line): 1
  the answer that never reached TiffinBox: GET /nowhere -> 404 text/html <h1>404 Not Found</h1>No context found for request
this run's answer lines at DEBUG: 13 · on a virtual thread: 13 · distinct virtual threads among them (the number, counted before it is cut): 13 · its WARN lines: 0 · ERROR lines: 0
D (labelled) - Boot's routing table: the README's exposure line with mappings, exposed by flag for one run, on the JVM, port 19161:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19161 --management.endpoints.web.exposure.include=health,mappings
  listens on: 127.0.0.1:19161
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19161/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19161/actuator/mappings    # keys sorted
  {"contexts":{"application":{"mappings":{},"parentId":null}}} 200
  its contexts: 1 - application · the kinds of mapping listed in them: 0
$ $CURLSET 19161 .harness/serve/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
E (labelled) - the JDK's own rule, without TiffinBox: the harness's Prefix, three contexts on 127.0.0.1:19162:
$ java harness/Prefix.java 19162
  harness: contexts created, in this order: /c, /customers, /customersX
  harness: /customersXYZ -> 200 context /customersX
  harness: /customers/ -> 200 context /customers
  harness: /customers -> 200 context /customers
  harness: /cat -> 200 context /c
  harness: /nowhere -> 404 (no context)
  listening on 19162 now: 0
```

## 2 · pieces — the files that do the web's jobs

The web module's nine files, each with its lines and three greps: imports `com.sun.net.httpserver.` · is `public @interface Route `
(the annotation the router reads with `getAnnotation(Route.class)`) · calls `thrownIn(TiffinBoxServer.class, "start"` (explains the
failed bind of the server's start). Four files do one of the three — 548 lines; five do none; the core's seven import nothing of the
server. Counted by grep, not by judgement; which lessons take these jobs is the roadmap's plan, not a measurement.

`.r-pieces.out` · md5 `902a804dcf07a625c70681d80656024b` · 3 of 3

```
the web module's files - lines, and three greps: imports the JDK's HTTP server · is the annotation the router reads · explains the failed bind of the server's start:
$ cd .harness/serve && for f in tiffinbox-web/src/main/java/com/tiffinbox/web/*.java; do echo "$(basename "$f") $(wc -l < "$f" | tr -d " ") · $(grep -c "^import com\.sun\.net\.httpserver\." "$f") · $(grep -c "^public @interface Route " "$f") · $(grep -c "thrownIn(TiffinBoxServer\.class, \"start\"" "$f")"; done
  ActuatorRoutes.java 196 · 2 · 0 · 0
  BareArgumentAnalyzer.java 17 · 0 · 0 · 0
  BareArgumentGuard.java 88 · 0 · 0 · 0
  KitchenHealthIndicator.java 41 · 0 · 0 · 0
  KitchenMetrics.java 43 · 0 · 0 · 0
  PortTakenFailureAnalyzer.java 51 · 0 · 0 · 1
  Route.java 24 · 0 · 1 · 0
  TiffinBoxApp.java 34 · 0 · 0 · 0
  TiffinBoxServer.java 277 · 3 · 0 · 0
  the router reads the annotation: 1 line in TiffinBoxServer.java
  the files that do one of the three: 4 - ActuatorRoutes.java PortTakenFailureAnalyzer.java Route.java TiffinBoxServer.java · 548 lines
  the files that do none: 5 - BareArgumentAnalyzer.java BareArgumentGuard.java KitchenHealthIndicator.java KitchenMetrics.java TiffinBoxApp.java · 223 lines
the core module's files:
$ cd .harness/serve && cat tiffinbox-core/src/main/java/com/tiffinbox/*.java | wc -l | tr -d ' '; ls tiffinbox-core/src/main/java/com/tiffinbox/*.java | wc -l | tr -d ' '; grep -l 'com.sun.net.httpserver' tiffinbox-core/src/main/java/com/tiffinbox/*.java | wc -l | tr -d ' '
  lines 316 · files 7 · that import the JDK's HTTP server 0
the tree against the anchor, without target/ and secrets/ (diff -rq): 0 differences
```

## 3 · readme — the repository's roadmap line (ledger P11)

Before (`git show 53379bd:README.md`): `Spring Boot → JPA`, skipping Spring Web MVC, and Build & Test Like a Pro with it. Now: the
track's 19 courses, named as the roadmap's one-table summary names them, in its order, shortened with `…`; Spring Web MVC after
Spring Boot. The deck's builder checks the names against `TRACK-ROADMAP.md` on the day. Then the README's opening (BLUE, RED
C5-S5 #44): its title names the five courses, lines 1-5 map `c4-unitNN/` and `c5-unitNN/` beside the first three, and it has a
section for Courses 2 to 5.

`.r-readme.out` · md5 `bb4db1efcfed9a697474207c7dbec305` · 3 of 3

```
the roadmap line in the repository's README - as the last commit before this unit had it:
$ git -C .. show 53379bd:README.md | grep -n '^Videos publish'
  447:Videos publish a few per day on the channel. Roadmap: Core Java → Spring Framework → Spring Boot → JPA → REST → Security → … → Spring AI.
and as it is now:
$ grep -n '^Videos publish' ../README.md
  456:Videos publish a few per day on the channel. Roadmap (19 courses): Java Fundamentals → Core Java II → Build & Test Like a Pro → Spring Framework Core → Spring Boot → Spring Web MVC → Data with JPA & Hibernate → … → Spring AI.
  its entries, in order (… counted as one): 9 names · after Spring Boot: Spring Web MVC · Build & Test named: 1
the README's opening - the courses its title names, the folders it maps, and its course sections:
$ sed -n 1p ../README.md
  # TiffinBox — code for *Java Fundamentals*, *Core Java II*, *Build & Test Like a Pro*, *Spring Framework Core* and *Spring Boot* (Learn Programming with Vivek)
  the folders its opening maps (lines 1-5): unitNN/ c2-unitNN/ c3-unitNN/ c4-unitNN/ c5-unitNN/
  its course sections: 2 3 4 5 (Course 1's units: the Units table)
```

## Not captured here — the builder's, by Course 4's finale's method

- **The course's counts** — 30 lessons and 5 sections (`java5_series.py`), 19 courses and the next one, Spring Web MVC, 32 units · 6
  sections (`TRACK-ROADMAP.md`'s one-table summary and its Course 6 heading) — are read by `spring-boot/_builders/s530.py` on the day
  (contract §6c). Neither file is in this repository, so a receipt cannot read them on a clone; the builder prints the roadmap's md5
  in the Director's Note.
- **The next course's lesson titles** (eight jobs → seven lessons) are found in the roadmap's Course 6 list by a key each, each found
  exactly once, never typed. They are a plan, said as one ("is planned to hand … a lesson in the plan"), and carried as PROMISE-LEDGER
  rows C6-1 to C6-8 for Course 6's brief to honour or correct (RED C5-S5 #45). The roadmap's Course 6 also names Undertow (its unit 02), which Boot 4.1.1's BOM no longer manages (the
  Boot 4 lesson: 11 → 0 mentions): not named here; Course 6's brief owns that line.
- **Jackson 3 alone does not move the seven** — cited from the Boot 4 lesson's `swap` C (`../c5-unit28/.r-swap.out`, its published
  md5 `217cf70cd2abb53203adb1afde158f96`, checked by the builder): Jackson 3 declared, the seven `115c36ba…`, 0 lines different.

## Exercise

None: the finale is exempt (contract 7; `check_unit5.py` skips the last unit).

## Found on the way

- **The DEBUG line logs the route, not what was typed** — B's line says `GET /customers`, and its timer series is `GET /customers`'s
  (`1 -> 2`): a client can raise a route's count with a path that route never declared. Nothing in TiffinBox can tell `/customersXYZ`
  from `/customers`.
- **`HEAD /kitchen`** (probed once, not captured): TiffinBox's 405, and the JDK logs a WARN, `sendResponseHeaders: being invoked with
  a content length for a HEAD request` — `respond()` gives a HEAD answer a body length. Not in the seven; carried to Course 6 as
  ledger row C6-10 (RED C5-S5 #49), with the prefix match's write route (`POST /shutdownXYZ` timed as `POST /shutdown`) as C6-9
  (#48).
- **The bridge is neither logged nor timed**: `/actuator` and `/actuator/mappings` (404) add 0 lines and move 0 series — the timer is
  TiffinBox's routes' alone, so a scrape cannot count scrapes.
- **The JDK's 404 never reaches TiffinBox**, so no TiffinBox code can change it: the page, its `text/html` and its wording are the JDK's.

## For RED (part B)

- The DEBUG/timer tag on a prefix match (above): a measured behaviour of the anchor, said on screen, not fixed (⚑14).
- `HEAD`'s WARN (above).
- Whether "naming them here, not teaching them" covers the eight jobs → lessons slide's mapping (the roadmap's plan; ⚑15 claims
  nothing about Spring MVC's answers).
- The counts and titles are the builder's, not a receipt's (above) — a departure from the brief's planned `counts` capture, argued.
- Units 21-26's "not … yet" terminal notes (S5.26, LOW, carried).
