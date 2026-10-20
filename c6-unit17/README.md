# c6-unit17 — Error-Handling Traps

Course 6 · Spring Web MVC · Section 3 (Errors Done Right), its last unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot
4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5), 2026-10-18. The problem-detail lesson left TiffinBox answering every error
it or Spring MVC decides in one shape, RFC 9457's. This unit shows what still slips past, each trap on the course's harness and never in
the anchor (S3.18): an exception thrown in a **servlet filter** (it never reaches an advice: Boot's `/error` 500 — unless a filter ahead of
it hands it to Spring MVC's resolvers), a **catch-all** exception handler (it turns real errors into silent 500s, how many decided by its
order), an answer that fails after it is **committed** (the client already has a 200), an answer Tomcat gives **before Spring MVC** sees
the request (the encoded slash; Tomcat's own 500 page when Boot's Whitelabel page is off), and an exception handler **that fails itself**.

**No anchor change (brief ⚑2).** `anchor` is the link to `../c6-unit16/after` — the problem-detail lesson's frozen tree, `c6-tiffinbox` at
Section 3's end — read and copied under `.harness/anchor`, never built in place; this unit freezes no `after/` and touches no other
unit's folder. Everything new is **the course's harness**, never TiffinBox's — `harness/probe/web`, outside `com.tiffinbox`, compiled with
`-parameters` against the anchor's own jar and joined by `--spring.main.sources` on the extracted jar's class path:

- `Boom` — `/probe/boom` throws an `IllegalStateException` ("the kitchen is on fire"): an error nobody decided on.
- `BoomFilter` — a `Filter` bean (a `OncePerRequestFilter`), which **Boot registers** with Tomcat: `X-Boom: state` throws an
  `IllegalStateException` ("the filter is on fire"), `X-Boom: status` a `ResponseStatusException(403, "a filter said no")`; any other
  request goes on.
- `ResolvingFilter` — a filter bean ordered first (`HIGHEST_PRECEDENCE`, so it wraps `BoomFilter`): it catches a `RuntimeException`
  coming back up the chain and hands it to the `handlerExceptionResolver` bean — the composite of resolvers the `DispatcherServlet` asks —
  with no handler; unresolved, it throws it on. The order filters run in is *Filters vs Interceptors vs Advice*'s subject: named here,
  not taught (CARRIED).
- `CatchAll` / `CatchAllFirst` — one `@ExceptionHandler(Exception.class)` each, answering a 500 problem detail "something went wrong" with
  a member naming the class (S3.15: the answer says who wrote it); `CatchAll` at the default order, `CatchAllFirst` at `HIGHEST_PRECEDENCE`.
- `Committed` — `/probe/committed` writes a line, flushes it, throws; `/probe/meals` returns 2,000 meals whose 1,500th fails as Jackson
  writes it; `/probe/short` returns 10 meals whose 5th fails the same way (`committed`'s C).
- `Fragile` — an exception handler with a bug, ordered first, for `NoResourceFoundException`: it reads the exception's cause, which is null.
- `Who` — reads the running application, as text, and changes nothing: the `ResponseEntityExceptionHandler` beans, the
  `ExceptionHandlerExceptionResolver`'s advice cache in the order it asks (each advice's type, order, `@ExceptionHandler` methods), the
  method each advice would answer eight exception types with, the JVM's locale.
- `harness/shutdown.sh` — POST `/shutdown` with the token read from its file (the binding lesson's, unchanged).

No native build and no Docker (the brief: 14 and 17 build neither); no claim here needs another form.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 6 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top; a bare `java` on this Mac is 23.0.1.) It **dies** when a capture's md5 differs
from `receipts.md5` (it prints the `DIFFERS` line first). **Start it in a process group of its own** (a terminal's foreground job is one):
two receipts started as background jobs of one shell share a group, and one run's clean-up would stop the other's JVMs (R.94).

**BLUE's runs (2026-10-20, after RED S3's fixes — the S3 brief's AMENDMENT (BLUE S3)):** 731 s under `./receipts.sh` (/bin/bash 3.2.57) and 505 s under `bash receipts.sh` (Homebrew bash 5.3), each `env -i` in a process group of its own, exit 0, every capture 3/3 = published. Captures that changed: filter `32cc5cd9…` → `0dd3c5c3…` · committed `320d4ca3…` → `0adf3d85…` · tomcat `7d9cb44e…` → `5b82910f…`; the rest as published before. **Sealed clone** (BLUE, /bin/bash 3.2, `env -i`, Maven sent to a `file://` copy of `.m2-demo`, proxies refused): exit 0 in 590 s, 6 of 6 = published, 512 artifacts, every one from the `file://` copy; the clone's `anchor` link compared by `readlink` (`../c6-unit16/after` both) and the tree it points to diffed whole: 0 differences (RED B #213). The exercise as viewers run it (Java 23.0.1 at start): `500 500`, then `405 405` twice; SOLUTION alone `405 405`.

**Runs of record (2026-10-18, this script as committed):** **492 s under `./receipts.sh`** (/bin/bash 3.2.57, `env -i` with HOME and a plain
PATH, this folder, its own process group, `.m2-demo` re-seeded from `_research/m2-seed-s3/` alone: exit 0, all 6 captures 3/3 = published,
every check passed) and **493 s under `bash receipts.sh`** (Homebrew bash 5.3.9, the same: exit 0, all 6 = published). **A sealed fresh
clone**: `git clone` of tiffinbox-java at 4bf61c9, this unit's 15 files put in as git would take them (its `.gitignore` lines keep
`.m2-demo`, `.harness` and `.r-*` out; `anchor` stays the link); `env -i`, a `HOME` of its own whose `.mavenrc` points every Java proxy at a
refusing port (127.0.0.1:9), Maven settings sending every repository to a `file://` copy of Central's files made from this unit's `.m2-demo`
(4,372 files), the proxy variables at the same refusing port, `/bin/bash` 3.2, a process group of its own: exit 0 in 501 s, all 6 =
published, every check passed; **512 artifacts, every one from the `file://` copy, 0 from anywhere else**; the first build said `offline:
no`, as a fresh clone's must, and every capture's build `offline: yes`. **How the hashes were made:** one development run (bash 5.3, each
capture once) fixed the captures; its six hashes went into `receipts.md5`; all three runs of record reproduced them, 3 of 3 each.


Published hashes: filter `0dd3c5c328efcfb23716b0b693a5d713` · catchall `cd295913d5f78d39b4051ffc8864ae85` · committed `0adf3d8595b5bc99842c9811aacade00` · tomcat `5b82910f9615dd96293191ca20ed0776` · handler `eb0ec28eb622d8d108c51c49253a32b3` · exercise `dc0605ea4e3cad199086e8830fcfba4f`.

## The commands this unit adds

`anchor/README.md` — the anchor's own — gives every line `receipts.sh` runs or derives from but these nine, which are this unit's, each read
from the block below and asserted to be exactly this (on the anchor's port 18431; each capture swaps in its own port):

```bash
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.mvc.problemdetails.enabled=false
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.web.error.whitelabel.enabled=false
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/probe/web/Boom.java harness/probe/web/BoomFilter.java harness/probe/web/CatchAll.java harness/probe/web/CatchAllFirst.java harness/probe/web/Committed.java harness/probe/web/Fragile.java harness/probe/web/ResolvingFilter.java harness/probe/web/Who.java
curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'X-Boom: status' http://127.0.0.1:18431/customers/Ravi
curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:18431/customers
curl -s -o .harness/got.txt -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:18431/probe/committed
curl -s http://127.0.0.1:18431/probe/who/advice
```

The first two are the anchor's run line and its class-path line with `-Duser.language=en -Duser.country=US` after `java` — asserted — and
every java line a capture starts takes the same two options in the same place (`at()`; a last check refuses any capture's java line without
them). The next two are the pinned class-path line with one of Boot's keys at the end: problem details off for one run
(`spring.mvc.problemdetails.enabled=false`, the catch-all's first run) and Boot's Whitelabel page off (`spring.web.error.whitelabel.enabled=false`,
`tomcat`'s B). The javac line compiles the harness's eight files and nothing else. The filter's line is the anchor's Content-Type line (the
exception-handler lesson's line with curl's Content-Type printed) with one header, `X-Boom`, and the name Ravi; `bq()` swaps the header's
value and may add one `Accept`. The POST line is the request-body lesson's with Content-Type printed (`pq()` swaps its body — the body cut
after its first key — or its Content-Type: a form's, for the 415). The saved-answer line is the anchor's Content-Type line with `-o
.harness/got.txt` and another path (`gq()`), so the receipt can read what curl got. The harness's question is the one-customer line without
its `-w`, another path. Each derivation is asserted.

## The repository, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from `../../spring-web-mvc/_research/m2-seed-s3/`
alone — 5,837 files, no `com/tiffinbox` — and re-seeded so before each run of record. **Nothing was downloaded** for this unit: every build
said `offline: yes`. A fresh clone's `.m2-demo` is empty (git ignores it): the first build — `.harness/pre`, before any capture — fills it
from Maven Central and says `offline: no`. **At run time** every request goes to `127.0.0.1`, and nothing binds 8080, 18425 or 35729.

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 25 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/anchor/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) when the script runs, and sent only by `../c5-unit11/curlset.sh` and `harness/shutdown.sh` on curl's standard input. Every
capture's raw output is searched for it before masking (0 in all of them), and so are the log of every JVM that served, and every file this
unit ships: 0 everywhere. The header's name, `X-Shutdown-Token`, is counted too: 0 in every log. No capture sends any other secret toward an
answer, so this unit plants no canary (S3.10 applies where a header reaches an answer; none does here). The exercise makes a token of its own
(`openssl rand -hex 13`), counted 0 times in its own log and never printed.

## The locale — pinned per JVM

Every java line this script starts carries `-Duser.language=en -Duser.country=US` before `-jar` or `-cp` (S3.1, RED B2 #111), and `Who`
prints the JVM's locale (`en_US`). On macOS the JVM takes the Mac's first language, not `LC_ALL`, and Spring's, Jackson's and Tomcat's
messages — in the log lines and in the problem details — and Boot's Whitelabel page are text a JVM in another language could word otherwise.
A last check refuses any capture whose java line lacks the two options (the extract line, `-Djarmode=tools`, prints nothing a locale changes).

## The folders, the names and the ports

- `.harness/pre` — the anchor built before any capture; `.harness/anchor` — the anchor, copied, with a config tree, built and extracted
  (`filter`); `.harness/hc` — the harness's classes; `.harness/got.txt` — the last saved answer (`committed`); `.harness/mine` — the
  exercise's copy.
- **Ports** (brief ⚑1, 19460-19469): `filter` — the seven, `Who`, A, A′ and D 19460, B 19461, C 19462, E 19463 · `catchall` — as it ships
  19464, the key off 19465, the key on 19466, ordered first 19467 · `committed` 19468 · `tomcat` — DEBUG 19461, A and A′ 19462, B 19463 ·
  `handler` — as it ships 19464, `Fragile` 19465 · the exercise 19469. Captures run one after another, each JVM stopped (and its port
  checked free) before the next starts. All ten, 18425 (TiffinBox's default), 8080 (Tomcat's) and 35729 (DevTools' Live Reload) are checked
  free first; a run that listens on 8080 or 35729 is killed and the script dies.

## Masks, filters and hygiene — every one, declared

1. **Paths, the token, the user** (`gsub()`, literals escaped), in every line: the demo token → `[masked: the 25-character token]`; this
   folder → `…`; the folder above → `…/..`; home → `~`; the user name, as a whole word → `<user>`; a generated class's number →
   `$$SpringCGLIB$$<n>`. A last check fails if any capture holds `/Users/`, `/private/`, `/home/`, `/var/folders/`, a unit number, Boot's
   process line, a log time, an unmasked timestamp, a `GMT`, `CET` or `CEST` date, a date in Java's `Date` form, a thread number, a stack
   frame, a whole HTML page, `:8080` or `:35729`, a carriage return, or a command with a URL that is not `127.0.0.1`'s.
2. **Spring's error timestamp** (`tsmask`, `gsub`): `"timestamp":"<anything>"` → `"timestamp":"…"` and `"timestamp":<digits>` →
   `"timestamp":…`, in every answer printed and in the seven, which are hashed after it — on this tree the seven carry none (problem details),
   and the mask still runs and prints its count (0). At DEBUG, `timestamp=…,` in the map Spring MVC logs.
3. **Answers** (`pagef`, S3.6, S3.11): Boot's **Whitelabel page** is printed as its `<h1>` and its error line; its `created` date — the
   JVM's time zone — masked, its paragraph counted, never shown. **Tomcat's own pages** (the encoded slash's 400, the Whitelabel-off 500) as
   their `<h1>` and their length, never shown. A JSON answer — a problem detail too — as it came, never re-ordered (S3.16). Checked on planted
   pages before any capture.
4. **A saved answer** (`sumf`, `committed`): a text answer as its lines, quoted, and whether its last line ended; JSON as whether it parses,
   and — a list — how many items, its first and its last; never its byte count (R.45). Checked on four planted answers first.
5. **Log lines** (`logl`, `recs`, `dbg`): from their logger on, as the log prints the logger — `o.a.c.c.C.[.[.[/].[dispatcherServlet]` and
   `o.a.c.c.C.[Tomcat].[localhost]` are **Tomcat's**; `o.s.web.servlet.DispatcherServlet`, `o.s.web.servlet.PageNotFound`,
   `.m.m.a.ExceptionHandlerExceptionResolver`, `s.w.s.m.m.a.RequestMappingHandlerMapping`, `o.s.w.s.m.m.a.HttpEntityMethodProcessor` and
   `m.m.a.RequestResponseBodyMethodProcessor` are **Spring MVC's**; `o.s.b.w.a.ProblemDetailsExceptionHandler`, `BasicErrorController` and
   the Whitelabel page are **Boot's**. Boot's first line is cut before ` with PID`. Every request a capture asks (`rq`) ends its answer's last
   line with `· WARN lines it added: N · ERROR lines: M` — the lines the log gained between two points where it stopped growing — and each
   WARN or ERROR record follows: its level, logger and message, then the exception line under it; its stack frames bounded ("over 40") and
   its other lines counted, none shown (checked on a planted log first). At DEBUG (`dreq`) every log line a request added is printed with its
   level, counted, the DispatcherServlet's counted apart, and the lines that are no log line (a stack trace's) counted, never shown.
6. **A URL that holds a character the shell reads** (`;`, `?`, `&`, `*`, `{`, `}`, a space) is single-quoted on the command line, so the
   printed command is the one that ran.
7. **A′ against A** (`asame`): A's block and A′'s, their labels aside, compared line for line in the capture itself ("yes"); **D against A**
   (`ssame`): the same, the line that started each JVM aside (D joins one class more).
8. **The seven's moved lines** (`moved`): each configuration's masked seven against the anchor's as it ships, line by line.
9. **On this Mac**: `lsof` by pid (or by port), the address column alone — never a command name (R.18).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`, and the exercise's
shell `$xpid` with every process under it — `killtree`, by parent pid), sweeps its own process group for any TiffinBox JVM or Maven left,
deletes the capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched. No `wait` in the
script, its checks or the exercise is bare: each names its pid (S3.9; a check refuses a bare one). **Measured**: SIGINT to the script's process group 13 s in, during `filter`'s A (4 processes in the group, 1 of them TiffinBox's JVM), the script started as a terminal starts its foreground job (`python3` with `SIG_DFL` and `os.setpgrp()`, `env -i`, /bin/bash 3.2): **exit 130**; 5 s later 0 processes in the group and 0 anywhere running TiffinBox; 19460-19469, 8080, 18425 and 35729 free; no `.r-lock`, no unfinished capture run; the published captures unchanged (md5).

## 1 · filter — a filter that throws (A/B/A′; C, D, E labelled)

**The seven**, on a fresh JVM of the anchor's jar: `466c20ed…` (the mask changes 0 lines), one WARN — Spring MVC's `PageNotFound`, GET
/shutdown's 405. **Who answers** (`Who`): Boot's `ProblemDetailsExceptionHandler` at order 0 (`handleException`, 20 exception types), then
`TiffinBoxErrors`; a `ResponseStatusException` is one of Boot's. **A** — `BoomFilter` joined: `X-Boom: status` (a 403
`ResponseStatusException`) and `X-Boom: state` both answer **Boot's `/error` 500** — `{"timestamp","status","error","path"}`, not a problem
detail — the Whitelabel page for HTML, each with **one ERROR line, Tomcat's** (`Servlet.service() … threw exception`, the 403's exception
under it); a request the filter lets through answers as ever. **B** — `ResolvingFilter` ahead of it: `status` → **403
`application/problem+json`** `{"detail":"a filter said no",…}`, 0 ERROR (Boot's handler took it: an `ErrorResponseException`); `state` —
no handler takes an `IllegalStateException` — still Boot's 500, 1 ERROR. **A′** = A. **C** (labelled, B + `CatchAll`): `state` → a 500
problem detail from the catch-all, **0 WARN, 0 ERROR**. **D** (labelled, A + `CatchAll`): line for line A — **the advice never runs** for a
filter's exception. **E** (labelled, A at DEBUG): the request adds 6 log lines, **2 of them the `DispatcherServlet`'s, both the `"ERROR"
dispatch for GET "/error"`** — Tomcat's second pass to Boot's `BasicErrorController`; the request itself never reached Spring MVC. Pays the
roadmap's "an exception thrown in a filter bypassing the advice entirely".

`.r-filter.out` · md5 `0dd3c5c328efcfb23716b0b693a5d713` · 3 of 3

```
the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline), its jar extracted (the README's line):
$ cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the anchor · offline: yes · exit 0
$ cd .harness/anchor && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
the harness, compiled against the anchor's own jar - with -parameters (this unit's line):
$ javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/probe/web/Boom.java harness/probe/web/BoomFilter.java harness/probe/web/CatchAll.java harness/probe/web/CatchAllFirst.java harness/probe/web/Committed.java harness/probe/web/Fragile.java harness/probe/web/ResolvingFilter.java harness/probe/web/Who.java
  exit 0 · its classes: probe/web/Boom.class probe/web/BoomFilter.class probe/web/CatchAll.class probe/web/CatchAllFirst.class probe/web/Committed$Meal.class probe/web/Committed$ShortMeal.class probe/web/Committed.class probe/web/Fragile.class probe/web/ResolvingFilter.class probe/web/Who.class
the seven - the anchor, the README's run line (its locale pinned), port 19460, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19460
  listens on: 127.0.0.1:19460 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19460/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19460 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
who answers - the anchor on its class path, the harness's Who joined, port 19460, read off the running application:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19460 --spring.main.sources=probe.web.Who
  listens on: 127.0.0.1:19460 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19460/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19460/probe/who/advice
  the ResponseEntityExceptionHandler beans: 1
    problemDetailsExceptionHandler - org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler
  ExceptionHandlerExceptionResolver's advice cache, in the order it asks: 2
    1 org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler · its order: 0
        @ExceptionHandler handleException, from ResponseEntityExceptionHandler - takes 20 exception types
    2 com.tiffinbox.web.TiffinBoxErrors · its order: 2147483647
        @ExceptionHandler notFound, its own - takes CustomerNotFound
  a CustomerNotFound, each advice's method for it, in that order: ProblemDetailsExceptionHandler: none · TiffinBoxErrors: notFound
  a NoResourceFoundException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a HttpRequestMethodNotSupportedException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a MethodArgumentTypeMismatchException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a HttpMessageNotReadableException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a MethodArgumentNotValidException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a ResponseStatusException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  an IllegalStateException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: none · TiffinBoxErrors: none
  the JVM's locale: en_US
$ harness/shutdown.sh 19460 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19460 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A - the anchor on its class path, the harness's BoomFilter joined (a filter bean Boot registers), port 19460: X-Boom: status, X-Boom: state, X-Boom: state for HTML (only HTML, sent by curl), then a request the filter lets through:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19460 --spring.main.sources=probe.web.BoomFilter
  listens on: 127.0.0.1:19460 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19460/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'X-Boom: status' http://127.0.0.1:19460/customers/Ravi
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers/Ravi"} 500 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception
      org.springframework.web.server.ResponseStatusException: 403 FORBIDDEN "a filter said no"
      its stack frames: 28, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'X-Boom: state' http://127.0.0.1:19460/customers/Ravi
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers/Ravi"} 500 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception
      java.lang.IllegalStateException: the filter is on fire
      its stack frames: 28, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'X-Boom: state' -H 'Accept: text/html' http://127.0.0.1:19460/customers/Ravi
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown · then curl's: 500 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception
      java.lang.IllegalStateException: the filter is on fire
      its stack frames: 28, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19460/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 3
$ harness/shutdown.sh 19460 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19460 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the same, with the harness's ResolvingFilter joined too (a filter bean ordered first, which hands an exception to Spring MVC's resolvers), port 19461:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19461 --spring.main.sources=probe.web.ResolvingFilter,probe.web.BoomFilter
  listens on: 127.0.0.1:19461 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19461/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'X-Boom: status' http://127.0.0.1:19461/customers/Ravi
  {"detail":"a filter said no","instance":"/customers/Ravi","status":403,"title":"Forbidden"} 403 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'X-Boom: state' http://127.0.0.1:19461/customers/Ravi
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers/Ravi"} 500 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception
      java.lang.IllegalStateException: the filter is on fire
      its stack frames: 31, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'X-Boom: state' -H 'Accept: text/html' http://127.0.0.1:19461/customers/Ravi
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown · then curl's: 500 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception
      java.lang.IllegalStateException: the filter is on fire
      its stack frames: 31, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19461/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 2
$ harness/shutdown.sh 19461 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19461 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, a fresh JVM, port 19460:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19460 --spring.main.sources=probe.web.BoomFilter
  listens on: 127.0.0.1:19460 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19460/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'X-Boom: status' http://127.0.0.1:19460/customers/Ravi
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers/Ravi"} 500 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception
      org.springframework.web.server.ResponseStatusException: 403 FORBIDDEN "a filter said no"
      its stack frames: 28, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'X-Boom: state' http://127.0.0.1:19460/customers/Ravi
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers/Ravi"} 500 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception
      java.lang.IllegalStateException: the filter is on fire
      its stack frames: 28, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'X-Boom: state' -H 'Accept: text/html' http://127.0.0.1:19460/customers/Ravi
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown · then curl's: 500 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception
      java.lang.IllegalStateException: the filter is on fire
      its stack frames: 28, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19460/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 3
$ harness/shutdown.sh 19460 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19460 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
C (labelled) - B with the harness's CatchAll joined (an advice with a handler for Exception), port 19462:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19462 --spring.main.sources=probe.web.ResolvingFilter,probe.web.BoomFilter,probe.web.CatchAll
  listens on: 127.0.0.1:19462 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19462/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'X-Boom: status' http://127.0.0.1:19462/customers/Ravi
  {"detail":"a filter said no","instance":"/customers/Ravi","status":403,"title":"Forbidden"} 403 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'X-Boom: state' http://127.0.0.1:19462/customers/Ravi
  {"detail":"something went wrong","instance":"/customers/Ravi","status":500,"title":"Internal Server Error","handler":"CatchAll"} 500 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19462 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19462 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
D (labelled) - A with the harness's CatchAll joined, port 19460:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19460 --spring.main.sources=probe.web.BoomFilter,probe.web.CatchAll
  listens on: 127.0.0.1:19460 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19460/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'X-Boom: status' http://127.0.0.1:19460/customers/Ravi
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers/Ravi"} 500 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception
      org.springframework.web.server.ResponseStatusException: 403 FORBIDDEN "a filter said no"
      its stack frames: 28, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'X-Boom: state' http://127.0.0.1:19460/customers/Ravi
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers/Ravi"} 500 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception
      java.lang.IllegalStateException: the filter is on fire
      its stack frames: 28, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'X-Boom: state' -H 'Accept: text/html' http://127.0.0.1:19460/customers/Ravi
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown · then curl's: 500 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception
      java.lang.IllegalStateException: the filter is on fire
      its stack frames: 28, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19460/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 3
$ harness/shutdown.sh 19460 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19460 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
D against A, the line that started each JVM aside, line for line the same: yes
E (labelled) - A at DEBUG (the embedded-Tomcat lesson's option: Boot's web group), port 19463 - X-Boom: status, every log line it added:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19463 --spring.main.sources=probe.web.BoomFilter --logging.level.web=debug
  listens on: 127.0.0.1:19463 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19463/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'X-Boom: status' http://127.0.0.1:19463/customers/Ravi
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers/Ravi"} 500 · Content-Type: [application/json]
  the log lines it added, Boot's web group at DEBUG (level logger: message) - all 6, of them Spring MVC's DispatcherServlet's: 2; and 29 other lines (a stack trace's), not shown:
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception
    DEBUG o.s.web.servlet.DispatcherServlet: "ERROR" dispatch for GET "/error", parameters={}
    DEBUG s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to org.springframework.boot.webmvc.autoconfigure.error.BasicErrorController#error(HttpServletRequest)
    DEBUG o.s.w.s.m.m.a.HttpEntityMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
    DEBUG o.s.w.s.m.m.a.HttpEntityMethodProcessor: Writing [{timestamp=…, status=500, error=Internal Server Error, path=/customers/R (truncated)...]
    DEBUG o.s.web.servlet.DispatcherServlet: Exiting from "ERROR" dispatch, status 500
$ harness/shutdown.sh 19463 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19463 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 2 · catchall — a catch-all exception handler, three ways

The same eight wrong requests each time — a path nobody maps, a wrong verb, a meal type no route takes, a body cut off, a form's
Content-Type, a client that accepts only XML, a name nobody has, a route that throws — each with the WARN and ERROR lines it added, and
each configuration's seven on a fresh JVM. **As it ships** (the baseline the silence is counted against, S3.14): 404, 405, 400, 400, 415,
406, 404 problem details; the 405 1 WARN (`PageNotFound`), the rest 0; the route's 500 Boot's body and **1 ERROR** (Tomcat's). **The key
off + `CatchAll`**: Boot's handler bean is gone (`ResponseEntityExceptionHandler beans: 0`), `CatchAll` is first; **all eight 500**,
**0 WARN, 0 ERROR** — the real crash included; the seven `826dbea9…`, lines 5 and 6 moved (404 and 405 → 500). **The key on + `CatchAll`**:
Boot's handler at 0 answers Spring MVC's own six as before (the seven `466c20ed…`, the 405's WARN still there), but `CatchAll` and
`TiffinBoxErrors` share order 2147483647 and the cache lists `CatchAll` first: **Nobody → 500**, the crash → a 500 problem detail, **0
ERROR** where the anchor logs 1. **`CatchAllFirst`** (order -2147483648): ahead of Boot's too — all eight 500, the 405's WARN gone, the seven
`55155d95…` (lines 5 and 6), 0 WARN 0 ERROR. The catch-all's answers name it (`"handler":…`), so its seven are not the brief's `14fb8415…`.

`.r-catchall.out` · md5 `cd295913d5f78d39b4051ffc8864ae85` · 3 of 3

```
the anchor as it ships (the key on), on its class path, the harness's Who and Boom joined, port 19464:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19464 --spring.main.sources=probe.web.Who
  listens on: 127.0.0.1:19464 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19464/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19464 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
  then the advice cache and eight requests, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19464 --spring.main.sources=probe.web.Who,probe.web.Boom
  listens on: 127.0.0.1:19464 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19464/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19464/probe/who/advice
  the ResponseEntityExceptionHandler beans: 1
    problemDetailsExceptionHandler - org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler
  ExceptionHandlerExceptionResolver's advice cache, in the order it asks: 2
    1 org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler · its order: 0
        @ExceptionHandler handleException, from ResponseEntityExceptionHandler - takes 20 exception types
    2 com.tiffinbox.web.TiffinBoxErrors · its order: 2147483647
        @ExceptionHandler notFound, its own - takes CustomerNotFound
  a CustomerNotFound, each advice's method for it, in that order: ProblemDetailsExceptionHandler: none · TiffinBoxErrors: notFound
  a NoResourceFoundException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a HttpRequestMethodNotSupportedException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a MethodArgumentTypeMismatchException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a HttpMessageNotReadableException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a MethodArgumentNotValidException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a ResponseStatusException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  an IllegalStateException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: none · TiffinBoxErrors: none
  the JVM's locale: en_US
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19464/nowhere
  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19464/shutdown
  {"detail":"Method 'GET' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"} 405 · Content-Type: [application/problem+json] · WARN lines it added: 1 · ERROR lines: 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' 'http://127.0.0.1:19464/customers?mealType=veg'
  {"detail":"Failed to convert 'mealType' with value: 'veg'","instance":"/customers","status":400,"title":"Bad Request"} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":' http://127.0.0.1:19464/customers
  {"detail":"Failed to read request","instance":"/customers","status":400,"title":"Bad Request"} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19464/customers
  {"detail":"Content-Type 'application/x-www-form-urlencoded;charset=UTF-8' is not supported.","instance":"/customers","status":415,"title":"Unsupported Media Type"} 415 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19464/customers
  {"detail":"Acceptable representations: [application/json, application/*+json].","instance":"/customers","status":406,"title":"Not Acceptable"} 406 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19464/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19464/probe/boom
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/boom"} 500 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen is on fire] with root cause
      java.lang.IllegalStateException: the kitchen is on fire
      its stack frames: over 40, its other lines: 2 - none shown
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 1
$ harness/shutdown.sh 19464 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19464 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the key off for this run (this unit's line), the harness's CatchAll joined (a handler for Exception, the default order), port 19465:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19465 --spring.main.sources=probe.web.Who,probe.web.CatchAll --spring.mvc.problemdetails.enabled=false
  listens on: 127.0.0.1:19465 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19465/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19465 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 826dbea9b1929049c516cfa786d15e0b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
  the lines that moved, against the anchor as it ships: 2 (5 6) · the same, byte for byte: 5 (1 2 3 4 7)
    line 5, as it ships: GET   /nowhere    -> 404 application/problem+json  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"}
    line 5, here:        GET   /nowhere    -> 500 application/problem+json  {"detail":"something went wrong","instance":"/nowhere","status":500,"title":"Internal Server Error","handler":"CatchAll"}
    line 6, as it ships: GET   /shutdown   -> 405 application/problem+json  {"detail":"Method 'GET' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"}
    line 6, here:        GET   /shutdown   -> 500 application/problem+json  {"detail":"something went wrong","instance":"/shutdown","status":500,"title":"Internal Server Error","handler":"CatchAll"}
  then the advice cache and eight requests, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19465 --spring.main.sources=probe.web.Who,probe.web.Boom,probe.web.CatchAll --spring.mvc.problemdetails.enabled=false
  listens on: 127.0.0.1:19465 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19465/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19465/probe/who/advice
  the ResponseEntityExceptionHandler beans: 0
  ExceptionHandlerExceptionResolver's advice cache, in the order it asks: 2
    1 probe.web.CatchAll · its order: 2147483647
        @ExceptionHandler anything, its own - takes Exception
    2 com.tiffinbox.web.TiffinBoxErrors · its order: 2147483647
        @ExceptionHandler notFound, its own - takes CustomerNotFound
  a CustomerNotFound, each advice's method for it, in that order: CatchAll: anything · TiffinBoxErrors: notFound
  a NoResourceFoundException, each advice's method for it, in that order: CatchAll: anything · TiffinBoxErrors: none
  a HttpRequestMethodNotSupportedException, each advice's method for it, in that order: CatchAll: anything · TiffinBoxErrors: none
  a MethodArgumentTypeMismatchException, each advice's method for it, in that order: CatchAll: anything · TiffinBoxErrors: none
  a HttpMessageNotReadableException, each advice's method for it, in that order: CatchAll: anything · TiffinBoxErrors: none
  a MethodArgumentNotValidException, each advice's method for it, in that order: CatchAll: anything · TiffinBoxErrors: none
  a ResponseStatusException, each advice's method for it, in that order: CatchAll: anything · TiffinBoxErrors: none
  an IllegalStateException, each advice's method for it, in that order: CatchAll: anything · TiffinBoxErrors: none
  the JVM's locale: en_US
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19465/nowhere
  {"detail":"something went wrong","instance":"/nowhere","status":500,"title":"Internal Server Error","handler":"CatchAll"} 500 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19465/shutdown
  {"detail":"something went wrong","instance":"/shutdown","status":500,"title":"Internal Server Error","handler":"CatchAll"} 500 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' 'http://127.0.0.1:19465/customers?mealType=veg'
  {"detail":"something went wrong","instance":"/customers","status":500,"title":"Internal Server Error","handler":"CatchAll"} 500 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":' http://127.0.0.1:19465/customers
  {"detail":"something went wrong","instance":"/customers","status":500,"title":"Internal Server Error","handler":"CatchAll"} 500 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19465/customers
  {"detail":"something went wrong","instance":"/customers","status":500,"title":"Internal Server Error","handler":"CatchAll"} 500 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19465/customers
  {"detail":"something went wrong","instance":"/customers","status":500,"title":"Internal Server Error","handler":"CatchAll"} 500 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19465/customers/Nobody
  {"detail":"something went wrong","instance":"/customers/Nobody","status":500,"title":"Internal Server Error","handler":"CatchAll"} 500 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19465/probe/boom
  {"detail":"something went wrong","instance":"/probe/boom","status":500,"title":"Internal Server Error","handler":"CatchAll"} 500 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19465 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19465 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the key on, as the anchor has it, the harness's CatchAll joined, port 19466:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19466 --spring.main.sources=probe.web.Who,probe.web.CatchAll
  listens on: 127.0.0.1:19466 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19466/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19466 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
  the lines that moved, against the anchor as it ships: 0 (none) · the same, byte for byte: 7 (1 2 3 4 5 6 7)
  then the advice cache and eight requests, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19466 --spring.main.sources=probe.web.Who,probe.web.Boom,probe.web.CatchAll
  listens on: 127.0.0.1:19466 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19466/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19466/probe/who/advice
  the ResponseEntityExceptionHandler beans: 1
    problemDetailsExceptionHandler - org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler
  ExceptionHandlerExceptionResolver's advice cache, in the order it asks: 3
    1 org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler · its order: 0
        @ExceptionHandler handleException, from ResponseEntityExceptionHandler - takes 20 exception types
    2 probe.web.CatchAll · its order: 2147483647
        @ExceptionHandler anything, its own - takes Exception
    3 com.tiffinbox.web.TiffinBoxErrors · its order: 2147483647
        @ExceptionHandler notFound, its own - takes CustomerNotFound
  a CustomerNotFound, each advice's method for it, in that order: ProblemDetailsExceptionHandler: none · CatchAll: anything · TiffinBoxErrors: notFound
  a NoResourceFoundException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · CatchAll: anything · TiffinBoxErrors: none
  a HttpRequestMethodNotSupportedException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · CatchAll: anything · TiffinBoxErrors: none
  a MethodArgumentTypeMismatchException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · CatchAll: anything · TiffinBoxErrors: none
  a HttpMessageNotReadableException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · CatchAll: anything · TiffinBoxErrors: none
  a MethodArgumentNotValidException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · CatchAll: anything · TiffinBoxErrors: none
  a ResponseStatusException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · CatchAll: anything · TiffinBoxErrors: none
  an IllegalStateException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: none · CatchAll: anything · TiffinBoxErrors: none
  the JVM's locale: en_US
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19466/nowhere
  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19466/shutdown
  {"detail":"Method 'GET' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"} 405 · Content-Type: [application/problem+json] · WARN lines it added: 1 · ERROR lines: 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' 'http://127.0.0.1:19466/customers?mealType=veg'
  {"detail":"Failed to convert 'mealType' with value: 'veg'","instance":"/customers","status":400,"title":"Bad Request"} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":' http://127.0.0.1:19466/customers
  {"detail":"Failed to read request","instance":"/customers","status":400,"title":"Bad Request"} 400 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19466/customers
  {"detail":"Content-Type 'application/x-www-form-urlencoded;charset=UTF-8' is not supported.","instance":"/customers","status":415,"title":"Unsupported Media Type"} 415 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19466/customers
  {"detail":"Acceptable representations: [application/json, application/*+json].","instance":"/customers","status":406,"title":"Not Acceptable"} 406 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19466/customers/Nobody
  {"detail":"something went wrong","instance":"/customers/Nobody","status":500,"title":"Internal Server Error","handler":"CatchAll"} 500 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19466/probe/boom
  {"detail":"something went wrong","instance":"/probe/boom","status":500,"title":"Internal Server Error","handler":"CatchAll"} 500 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
$ harness/shutdown.sh 19466 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19466 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the key on, the harness's CatchAllFirst joined instead (the same handler, ordered first), port 19467:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19467 --spring.main.sources=probe.web.Who,probe.web.CatchAllFirst
  listens on: 127.0.0.1:19467 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19467/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19467 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 55155d95c6ffcc18b98856c18abcb279
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
  the lines that moved, against the anchor as it ships: 2 (5 6) · the same, byte for byte: 5 (1 2 3 4 7)
    line 5, as it ships: GET   /nowhere    -> 404 application/problem+json  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"}
    line 5, here:        GET   /nowhere    -> 500 application/problem+json  {"detail":"something went wrong","instance":"/nowhere","status":500,"title":"Internal Server Error","handler":"CatchAllFirst"}
    line 6, as it ships: GET   /shutdown   -> 405 application/problem+json  {"detail":"Method 'GET' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"}
    line 6, here:        GET   /shutdown   -> 500 application/problem+json  {"detail":"something went wrong","instance":"/shutdown","status":500,"title":"Internal Server Error","handler":"CatchAllFirst"}
  then the advice cache and eight requests, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19467 --spring.main.sources=probe.web.Who,probe.web.Boom,probe.web.CatchAllFirst
  listens on: 127.0.0.1:19467 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19467/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19467/probe/who/advice
  the ResponseEntityExceptionHandler beans: 1
    problemDetailsExceptionHandler - org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler
  ExceptionHandlerExceptionResolver's advice cache, in the order it asks: 3
    1 probe.web.CatchAllFirst · its order: -2147483648
        @ExceptionHandler anything, its own - takes Exception
    2 org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler · its order: 0
        @ExceptionHandler handleException, from ResponseEntityExceptionHandler - takes 20 exception types
    3 com.tiffinbox.web.TiffinBoxErrors · its order: 2147483647
        @ExceptionHandler notFound, its own - takes CustomerNotFound
  a CustomerNotFound, each advice's method for it, in that order: CatchAllFirst: anything · ProblemDetailsExceptionHandler: none · TiffinBoxErrors: notFound
  a NoResourceFoundException, each advice's method for it, in that order: CatchAllFirst: anything · ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a HttpRequestMethodNotSupportedException, each advice's method for it, in that order: CatchAllFirst: anything · ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a MethodArgumentTypeMismatchException, each advice's method for it, in that order: CatchAllFirst: anything · ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a HttpMessageNotReadableException, each advice's method for it, in that order: CatchAllFirst: anything · ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a MethodArgumentNotValidException, each advice's method for it, in that order: CatchAllFirst: anything · ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a ResponseStatusException, each advice's method for it, in that order: CatchAllFirst: anything · ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  an IllegalStateException, each advice's method for it, in that order: CatchAllFirst: anything · ProblemDetailsExceptionHandler: none · TiffinBoxErrors: none
  the JVM's locale: en_US
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19467/nowhere
  {"detail":"something went wrong","instance":"/nowhere","status":500,"title":"Internal Server Error","handler":"CatchAllFirst"} 500 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19467/shutdown
  {"detail":"something went wrong","instance":"/shutdown","status":500,"title":"Internal Server Error","handler":"CatchAllFirst"} 500 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' 'http://127.0.0.1:19467/customers?mealType=veg'
  {"detail":"something went wrong","instance":"/customers","status":500,"title":"Internal Server Error","handler":"CatchAllFirst"} 500 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":' http://127.0.0.1:19467/customers
  {"detail":"something went wrong","instance":"/customers","status":500,"title":"Internal Server Error","handler":"CatchAllFirst"} 500 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19467/customers
  {"detail":"something went wrong","instance":"/customers","status":500,"title":"Internal Server Error","handler":"CatchAllFirst"} 500 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19467/customers
  {"detail":"something went wrong","instance":"/customers","status":500,"title":"Internal Server Error","handler":"CatchAllFirst"} 500 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19467/customers/Nobody
  {"detail":"something went wrong","instance":"/customers/Nobody","status":500,"title":"Internal Server Error","handler":"CatchAllFirst"} 500 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19467/probe/boom
  {"detail":"something went wrong","instance":"/probe/boom","status":500,"title":"Internal Server Error","handler":"CatchAllFirst"} 500 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19467 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19467 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 3 · committed — an answer that fails after it has left

A **committed response** is one whose status and first bytes have gone out: nothing can take them back (S3.17: no status is claimed but
the one curl saw). `/probe/committed` — write, flush, throw: curl gets **200** `text/plain;charset=ISO-8859-1`, the line `half an answer`,
and **exit 18** (the answer ended before it was complete); the log gains Tomcat's ERROR (the `IllegalStateException`) and then Boot's
`ProblemDetailsExceptionHandler` WARN `Response already committed. Ignoring: … No converter for [class java.util.LinkedHashMap] with preset
Content-Type 'text/plain;charset=ISO-8859-1'` — the error dispatch's own attempt to write Boot's map into the answer already sent.
`/probe/meals` — 2,000 meals, the 1,500th failing as Jackson writes it: **200** `application/json`, curl **exit 0**, **JSON that parses** —
a list of 1,500, the last `{"number":1500}` with no name (Jackson closes what it opened) — and **one WARN, no ERROR**: Boot's handler took
Jackson's failure, found the answer committed and ignored it. **C (labelled), the same JVM: `/probe/short`** — 10 meals, the 5th failing
the same way, **before anything has gone out**: **500** `application/problem+json`, `{"detail":"Failed to write request",…}`, and **0 WARN,
0 ERROR** — a silent 500, the reason (`meal 5 burned`) in neither the answer nor the log (RED B #200, #201). The 200 needs the answer
committed first: here 1,500 of 2,000.

`.r-committed.out` · md5 `0adf3d8595b5bc99842c9811aacade00` · 3 of 3

```
the anchor on its class path, the harness's Committed joined, port 19468 - a route that writes a line, flushes it and throws; then a route whose JSON fails at its 1,500th item of 2,000:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19468 --spring.main.sources=probe.web.Committed
  listens on: 127.0.0.1:19468 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19468/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o .harness/got.txt -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19468/probe/committed
  curl's line: 200 · Content-Type: [text/plain;charset=ISO-8859-1] · curl's exit code: 18
  what curl got: 1 line of text, the last one ended - 'half an answer'
  WARN lines it added: 1 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the second half burned] with root cause
      java.lang.IllegalStateException: the second half burned
      its stack frames: over 40, its other lines: 2 - none shown
    WARN o.s.b.w.a.ProblemDetailsExceptionHandler: Response already committed. Ignoring: org.springframework.http.converter.HttpMessageNotWritableException: No converter for [class java.util.LinkedHashMap] with preset Content-Type 'text/plain;charset=ISO-8859-1'
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -o .harness/got.txt -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19468/probe/meals
  curl's line: 200 · Content-Type: [application/json] · curl's exit code: 0
  what curl got: JSON that parses - a list of 1500 · its first: {"number":1,"name":"meal 1"} · its last: {"number":1500}
  WARN lines it added: 1 · ERROR lines: 0
    WARN o.s.b.w.a.ProblemDetailsExceptionHandler: Response already committed. Ignoring: org.springframework.http.converter.HttpMessageNotWritableException: Could not write JSON: meal 1500 burned
      its stack frames: 0, its other lines: 0 - none shown
C (labelled) - the same JVM: a short list, 10 meals whose 5th fails as Jackson writes it - before anything has gone out:
$ curl -s -o .harness/got.txt -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19468/probe/short
  curl's line: 500 · Content-Type: [application/problem+json] · curl's exit code: 0
  what curl got: JSON that parses - {"detail":"Failed to write request","instance":"/probe/short","status":500,"title":"Internal Server Error"}
  WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 2 · ERROR lines: 1
$ harness/shutdown.sh 19468 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19468 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 4 · tomcat — before Spring MVC; Boot's Whitelabel page (A/B/A′)

`/customers/a%2Fb` (an encoded slash in a name), with curl's own `Accept: */*` and with `application/json`: **Tomcat's own HTML 400** (by
its `<h1>`, `HTTP Status 400 – Bad Request`) both times, and at `--logging.level.web=debug` the log gains **0 lines** — no filter, no
`DispatcherServlet`; a request Spring MVC takes (`/customers/Ravi`) adds 5, 2 of them the `DispatcherServlet`'s. Pays S2 CARRIED "Tomcat's own
HTML 400 (`%2F`)". **A** — a route that throws, asked for HTML: Boot's Whitelabel 500, 1 ERROR. **B** — `--spring.web.error.whitelabel.enabled=false`:
**Tomcat's own 500 page** (`HTTP Status 500 – Internal Server Error`) and **3 ERROR lines** — Tomcat's for the route, then the error
dispatch failing (`Circular view path [error]`, logged by `[dispatcherServlet]` and by Tomcat's host, `[Tomcat].[localhost]`); for curl's own
Accept the same request is Boot's JSON body (1 ERROR), and a problem detail stays a problem detail. **A′** = A.

`.r-tomcat.out` · md5 `5b82910f9615dd96293191ca20ed0776` · 3 of 3

```
before Spring MVC - the anchor on its class path, the harness's Boom joined, Boot's web group at DEBUG (the embedded-Tomcat lesson's option), port 19461: a name with an encoded slash, curl's own Accept and JSON's; then a request Spring MVC takes:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19461 --spring.main.sources=probe.web.Boom --logging.level.web=debug
  listens on: 127.0.0.1:19461 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19461/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19461/customers/a%2Fb
  an HTML page, not the Whitelabel page - its <h1>: HTTP Status 400 – Bad Request · 431 characters, not shown · then curl's: 400 · Content-Type: [text/html;charset=utf-8]
  the log lines it added, Boot's web group at DEBUG (level logger: message) - all 0, of them Spring MVC's DispatcherServlet's: 0; and 0 other lines (a stack trace's), not shown:
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: application/json' http://127.0.0.1:19461/customers/a%2Fb
  an HTML page, not the Whitelabel page - its <h1>: HTTP Status 400 – Bad Request · 431 characters, not shown · then curl's: 400 · Content-Type: [text/html;charset=utf-8]
  the log lines it added, Boot's web group at DEBUG (level logger: message) - all 0, of them Spring MVC's DispatcherServlet's: 0; and 0 other lines (a stack trace's), not shown:
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19461/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200 · Content-Type: [application/json]
  the log lines it added, Boot's web group at DEBUG (level logger: message) - all 5, of them Spring MVC's DispatcherServlet's: 2; and 0 other lines (a stack trace's), not shown:
    DEBUG o.s.web.servlet.DispatcherServlet: GET "/customers/Ravi", parameters={}
    DEBUG s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to com.tiffinbox.web.TiffinBoxServer#customer(String)
    DEBUG m.m.a.RequestResponseBodyMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
    DEBUG m.m.a.RequestResponseBodyMethodProcessor: Writing [Customer[name=Ravi, mealsPerDay=2, pricePerMeal=120, mealType=VEG]]
    DEBUG o.s.web.servlet.DispatcherServlet: Completed 200 OK
$ harness/shutdown.sh 19461 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19461 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A - the anchor on its class path, the harness's Boom joined, port 19462: a route that throws, for HTML (only HTML, sent by curl) and for curl's own Accept; a path nobody maps, for HTML:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19462 --spring.main.sources=probe.web.Boom
  listens on: 127.0.0.1:19462 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19462/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19462/probe/boom
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown · then curl's: 500 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen is on fire] with root cause
      java.lang.IllegalStateException: the kitchen is on fire
      its stack frames: over 40, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19462/probe/boom
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/boom"} 500 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen is on fire] with root cause
      java.lang.IllegalStateException: the kitchen is on fire
      its stack frames: over 40, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19462/nowhere
  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 2
$ harness/shutdown.sh 19462 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19462 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the same, Boot's Whitelabel page switched off for this run (this unit's line), port 19463:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19463 --spring.main.sources=probe.web.Boom --spring.web.error.whitelabel.enabled=false
  listens on: 127.0.0.1:19463 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19463/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19463/probe/boom
  an HTML page, not the Whitelabel page - its <h1>: HTTP Status 500 – Internal Server Error · 451 characters, not shown · then curl's: 500 · Content-Type: [text/html;charset=utf-8] · WARN lines it added: 0 · ERROR lines: 3
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen is on fire] with root cause
      java.lang.IllegalStateException: the kitchen is on fire
      its stack frames: over 40, its other lines: 2 - none shown
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] threw exception
      jakarta.servlet.ServletException: Circular view path [error]: would dispatch back to the current handler URL [/error] again. Check your ViewResolver setup! (Hint: This may be the result of an unspecified view, due to default view name generation.)
      its stack frames: 36, its other lines: 2 - none shown
    ERROR o.a.c.c.C.[Tomcat].[localhost]: Exception Processing [ErrorPage[errorCode=0, location=/error]]
      jakarta.servlet.ServletException: Circular view path [error]: would dispatch back to the current handler URL [/error] again. Check your ViewResolver setup! (Hint: This may be the result of an unspecified view, due to default view name generation.)
      its stack frames: 36, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19463/probe/boom
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/boom"} 500 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen is on fire] with root cause
      java.lang.IllegalStateException: the kitchen is on fire
      its stack frames: over 40, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19463/nowhere
  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 4
$ harness/shutdown.sh 19463 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19463 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, a fresh JVM, port 19462:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19462 --spring.main.sources=probe.web.Boom
  listens on: 127.0.0.1:19462 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19462/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19462/probe/boom
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown · then curl's: 500 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen is on fire] with root cause
      java.lang.IllegalStateException: the kitchen is on fire
      its stack frames: over 40, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19462/probe/boom
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/boom"} 500 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen is on fire] with root cause
      java.lang.IllegalStateException: the kitchen is on fire
      its stack frames: over 40, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19462/nowhere
  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 2
$ harness/shutdown.sh 19462 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19462 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
```

## 5 · handler — answers that do not fail, and a handler that does

The anchor as it ships: `/nowhere`, and a name nobody has for a client that accepts **only HTML, only an image (`image/png`), only plain
text** — the same 404 problem detail, `application/problem+json`, 0 WARN 0 ERROR each. (The exception-handler lesson's `Map` body gave a
client that accepts only HTML, or only XML, a 500 — its own `status` capture's C; Chrome's whole header got its JSON 404 there; cited, not
re-run — RED B #202.) **`Fragile` joined**, ordered first: its handler throws a
`NullPointerException` while it answers `/nowhere`; Spring MVC logs **one WARN** (`ExceptionHandlerExceptionResolver: Failure in
@ExceptionHandler probe.web.Fragile#noSuchPath`, the NPE under it), hands the exception on, and `DefaultHandlerExceptionResolver` answers it:
**Boot's four keys, 404** — not a problem detail. A name nobody has, which `Fragile` does not take, still gets ours.

`.r-handler.out` · md5 `eb0ec28eb622d8d108c51c49253a32b3` · 3 of 3

```
the anchor as it ships, the README's run line (its locale pinned), port 19464: a path nobody maps; a name nobody has, for a client that accepts only HTML, only an image, only plain text - each sent by curl:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19464
  listens on: 127.0.0.1:19464 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19464/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19464/nowhere
  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19464/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: image/png' http://127.0.0.1:19464/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/plain' http://127.0.0.1:19464/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19464 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19464 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the anchor on its class path with the harness's Fragile joined - an exception handler with a bug, ordered first, for a path nobody maps - and Who, port 19465:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19465 --spring.main.sources=probe.web.Fragile,probe.web.Who
  listens on: 127.0.0.1:19465 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19465/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19465/probe/who/advice
  the ResponseEntityExceptionHandler beans: 1
    problemDetailsExceptionHandler - org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler
  ExceptionHandlerExceptionResolver's advice cache, in the order it asks: 3
    1 probe.web.Fragile · its order: -2147483648
        @ExceptionHandler noSuchPath, its own - takes NoResourceFoundException
    2 org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler · its order: 0
        @ExceptionHandler handleException, from ResponseEntityExceptionHandler - takes 20 exception types
    3 com.tiffinbox.web.TiffinBoxErrors · its order: 2147483647
        @ExceptionHandler notFound, its own - takes CustomerNotFound
  a CustomerNotFound, each advice's method for it, in that order: Fragile: none · ProblemDetailsExceptionHandler: none · TiffinBoxErrors: notFound
  a NoResourceFoundException, each advice's method for it, in that order: Fragile: noSuchPath · ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a HttpRequestMethodNotSupportedException, each advice's method for it, in that order: Fragile: none · ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a MethodArgumentTypeMismatchException, each advice's method for it, in that order: Fragile: none · ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a HttpMessageNotReadableException, each advice's method for it, in that order: Fragile: none · ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a MethodArgumentNotValidException, each advice's method for it, in that order: Fragile: none · ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  a ResponseStatusException, each advice's method for it, in that order: Fragile: none · ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  an IllegalStateException, each advice's method for it, in that order: Fragile: none · ProblemDetailsExceptionHandler: none · TiffinBoxErrors: none
  the JVM's locale: en_US
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19465/nowhere
  {"timestamp":"…","status":404,"error":"Not Found","path":"/nowhere"} 404 · Content-Type: [application/json] · WARN lines it added: 1 · ERROR lines: 0
    WARN .m.m.a.ExceptionHandlerExceptionResolver: Failure in @ExceptionHandler probe.web.Fragile#noSuchPath(NoResourceFoundException)
      java.lang.NullPointerException: Cannot invoke "java.lang.Throwable.getMessage()" because the return value of "org.springframework.web.servlet.resource.NoResourceFoundException.getCause()" is null
      its stack frames: over 40, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19465/customers/Nobody
  {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
$ harness/shutdown.sh 19465 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19465 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 6 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s six lines, then `exercise/solution/SOLUTION.md`'s three, read from the files and run as written in ONE `env -i`
`/bin/bash --noprofile --norc` shell started in this folder (S3.4, R.93). As shipped (`CatchAllFirst` and `Who` joined): `wrong verbs: 500
500`, 0 WARN in the copy's log, the handler list naming `probe.web.CatchAllFirst` first at -2147483648. The solution's last line is the
README's with `probe.web.CatchAllFirst,` taken out of `--spring.main.sources=` (asserted; it changes no file, so a second run gives the same
line): `wrong verbs: 405 405`, 2 WARN, Boot's handler first. Each leaves the shell in this folder, 0 copies of the copy's token in its log,
19469 free.

`.r-exercise.out` · md5 `dc0605ea4e3cad199086e8830fcfba4f` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 6 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/
  $ mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/anchor && rm -f ../handlers.txt && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*" ../../../harness/probe/web/CatchAllFirst.java ../../../harness/probe/web/Who.java && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19469 --spring.main.sources=probe.web.CatchAllFirst,probe.web.Who > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19469/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s -o ../handlers.txt http://127.0.0.1:19469/probe/who/advice; a=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19469/shutdown); b=$(curl -s -o /dev/null -w '%{http_code}' -X DELETE http://127.0.0.1:19469/customers); ../../../harness/shutdown.sh 19469 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "wrong verbs: $a $b")
  exit 0 · what they printed:
    wrong verbs: 500 500
  the handler list it saved (../handlers.txt) - its advice cache, and a wrong verb's line:
    ExceptionHandlerExceptionResolver's advice cache, in the order it asks: 3
      1 probe.web.CatchAllFirst · its order: -2147483648
      2 org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler · its order: 0
      3 com.tiffinbox.web.TiffinBoxErrors · its order: 2147483647
    a HttpRequestMethodNotSupportedException, each advice's method for it, in that order: CatchAllFirst: anything · ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19469 now: 0
the solution's 3 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ M="$PWD/.m2-demo" && (cd .harness/mine/anchor && rm -f ../handlers.txt && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*" ../../../harness/probe/web/CatchAllFirst.java ../../../harness/probe/web/Who.java && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19469 --spring.main.sources=probe.web.Who > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19469/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && curl -s -o ../handlers.txt http://127.0.0.1:19469/probe/who/advice; a=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19469/shutdown); b=$(curl -s -o /dev/null -w '%{http_code}' -X DELETE http://127.0.0.1:19469/customers); ../../../harness/shutdown.sh 19469 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "wrong verbs: $a $b")
  exit 0 · what they printed:
    wrong verbs: 405 405
  the handler list it saved (../handlers.txt) - its advice cache, and a wrong verb's line:
    ExceptionHandlerExceptionResolver's advice cache, in the order it asks: 2
      1 org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler · its order: 0
      2 com.tiffinbox.web.TiffinBoxErrors · its order: 2147483647
    a HttpRequestMethodNotSupportedException, each advice's method for it, in that order: ProblemDetailsExceptionHandler: handleException · TiffinBoxErrors: none
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 2 · ERROR lines: 0 · listening on 19469 now: 0
```

## Exercise

**Your turn:** the README's run turns every wrong verb into a five hundred. Read the handler list, remove the one that's first, and count again.
`exercise/README.md` has the commands (copy the anchor, give the copy a token of its own); its last line, in a subshell, builds the copy
offline, compiles the harness's `CatchAllFirst` and `Who` against it, starts it on 19469 with both joined, saves the handler list, asks GET
/shutdown and DELETE /customers, stops it, waits for its JVM and prints — as shipped — `wrong verbs: 500 500`. Done is `wrong verbs: 405
405`. Measured answer: `exercise/solution/SOLUTION.md`, run in the same shell. Run `./receipts.sh` once first on a fresh clone. **As viewers run it, beyond the capture:** README then SOLUTION, then SOLUTION again, in one `env -i` `zsh -f` shell → `wrong verbs: 500 500`, then `wrong verbs: 405 405` twice, each exit 0, the shell left in `c6-unit17/`, the copy's token 0 times in its log; the README's last line alone in an `env -i` `/bin/bash` shell whose `java` is 23.0.1 → exit 1, no line; 19469 free after each.

## The ledger rows and hand-offs this unit pays

- **The roadmap's U17 line** — "an exception thrown in a filter bypassing the advice entirely": `filter` A and D (the catch-all joined, line
  for line A), E (the request never reached the `DispatcherServlet`); the fix measured as B.
- **S2 CARRIED "Tomcat's own HTML 400 (`%2F`)"** — `tomcat`: the page, both Accepts, 0 log lines at DEBUG. **Paid.**
- **C6-31** ("if a course uses it, a course teaches it") — glossed at first spoken use: a servlet filter (re-glossed), the error dispatch,
  a catch-all, a committed response, the Whitelabel page (re-glossed); the filter order named for *Filters vs Interceptors vs Advice*.
- Section 3's close: none of 14-16's spoken lines becomes false on this tree — "every error in one shape" was said of the errors TiffinBox
  and Spring MVC decide; this unit measures the ones they never see.

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-18) |
|---|---|---|---|
| 9 | The filter traps and the resolving filter on 16/after | s16 (no 403/409 change) | **A: Boot's 500 ×2 (and Whitelabel), 1 ERROR each; B: the 403 a problem detail, 0 ERROR; state still Boot's 500; C: a silent 500 problem detail; D = A** (`filter`) |
| 10 | `OncePerRequestFilter` skipping the ERROR dispatch | inferred, not captured | **not captured — unspoken** (CARRIED to *Filters vs Interceptors vs Advice*) |
| 11 | The catch-all exercise on 16/after | s15 + flag | **`wrong verbs: 500 500` → `405 405`, one `env -i` shell** (`exercise`) |
| 13 | Every exercise as viewers run it | end states on sketches | **README then SOLUTION in one shell, exit 0 each** (`exercise`, and below) |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **The catch-all's seven are `826dbea9…` and `55155d95…`, not `14fb8415…`** (brief READ FIRST 11, the unit block): this unit's catch-all
  names itself in its answer (S3.15), so the bytes differ; the two moved lines are 5 and 6, as the brief said.
- **The key off removes Boot's handler bean** (not in the brief): with `spring.mvc.problemdetails.enabled=false` the context holds 0
  `ResponseEntityExceptionHandler` beans, and the catch-all is the first advice.
- **With the key on, a default-order catch-all keeps the 405's WARN** (the brief: "in every case 0 WARN and 0 ERROR"): `PageNotFound` is
  logged by Boot's handler, which still answers the 405 first; the catch-all silences the 500 (0 ERROR where the anchor logs 1) and takes
  Nobody's 404. Ordered first, the WARN goes too.
- **Boot's "Response already committed. Ignoring" belongs to the error dispatch** (the brief: Tomcat's ERROR and that WARN): it follows
  Tomcat's ERROR, when Boot's error controller tries to write its map into the `text/plain` answer already sent.
- **A list that fails after the answer is committed is a 200 with JSON that parses, and no ERROR at all** (not in the brief): 1,500 of
  2,000 meals, one WARN. **A list that fails before that is a silent 500 problem detail** — `committed`'s C, 10 meals, the 5th: `Failed to
  write request`, 0 WARN 0 ERROR (RED B #200).
- **Whitelabel off: the three ERROR lines carry `Circular view path [error]`** — the error dispatch itself fails before Tomcat writes its page.
- **"The handler that fails" is measured** with a handler that throws (`Fragile`), beside the brief's citation: Spring MVC hands the error to
  the next resolver, and the answer is Boot's four keys, not a problem detail.

## Found on the way

- **Every new check fails on a planted fault first** (R.65): the checks block runs alone (`cap()` a no-op, the build skipped) on the
  published captures with one thing changed per plant (`plants.py`, this unit's scratch folder), the capture restored after each — **39
  plants, 39 stops under /bin/bash 3.2 and 39 under bash 5.3**, each naming its own check; the unplanted files pass under both. Twenty-eight
  change one line of a capture (the seven's hash and its logger; A's ERROR count and B's 403; B's run total; A′, C's silence, D's sameness;
  E's DispatcherServlet count and its error-dispatch line; each catch-all run's seven, moved lines, bean count, Nobody, the crash's ERROR,
  the first's 405 WARN, the baseline's ERROR, the advice order; the committed exit code, the meal count, the meals' ERROR; the slash's lines,
  B's three ERROR, `tomcat`'s A′; `image/png`'s answer, `Fragile`'s WARN; the exercise's line and its WARN count); five plant a hygiene
  fault in a capture (an absolute path, an unpinned java line, a stack frame, the raw token, an unmasked timestamp); six change a shipped
  file (a bare `wait` in the exercise; Boot 3's error key in this README; the spoken exercise line; the Done line in the exercise and in
  SOLUTION.md; `Committed`'s 2,000 meals).
- **Three filters fail on planted inputs inside the script itself**, before any capture: the answer filter (a Whitelabel page, Tomcat's
  page, a timestamp), the record filter (a WARN with 45 frames, an ERROR with 3) and the saved-answer filter (a line of text, JSON that
  parses, JSON that does not, nothing).
- **Three lines failed under /bin/bash 3.2 alone** on the first run of record: a `${x/"literal"/}` pattern with a quoted literal (now a
  variable), and an expected-output line whose `$(…)` sat inside double quotes with an odd number of apostrophes (bash 3.2 paired them with
  the next single quote; now assigned to a variable first). bash 5.3 accepted both.
- **The brief's sketch and this tree agree** on the filter (Boot's 500, the 403 a 500, the resolving filter's 403 problem detail, a
  catch-all's silence) and on Tomcat's two pages; they differ where `LINES OVERTURNED` says.
- **SIGINT**, measured: the script started as a terminal starts its foreground job (`python3` with `SIG_DFL` and `os.setpgrp()`, `env -i`,
  /bin/bash 3.2), SIGINT to its process group 13 s in, during `filter`'s A (4 processes in the group, 1 of them TiffinBox's JVM): **exit
  130**; 5 s later 0 processes in the group, 0 anywhere running TiffinBox; 19460-19469, 8080, 18425 and 35729 free; no `.r-lock`, no
  unfinished capture run; the published captures unchanged (md5).
- **The exercise as viewers run it**, beyond the capture: README then SOLUTION, then SOLUTION again, in one `env -i` `zsh -f` shell →
  `wrong verbs: 500 500`, `wrong verbs: 405 405`, `wrong verbs: 405 405`, each exit 0, the shell left in `c6-unit17/`, the copy's token 0
  times in its log; the README's last line alone in an `env -i` `/bin/bash` shell without the exports — its `java` 23.0.1 — ends with
  `exit 1` and prints no line; 19469 free after each.


## For unit 18 — and RED

- This unit reads `../c6-unit16/after` only (no change). *Filters vs Interceptors vs Advice* inherits: the filter order (`ResolvingFilter`
  needs `HIGHEST_PRECEDENCE` to wrap `BoomFilter`; Boot registers both from `--spring.main.sources`); `OncePerRequestFilter` and the ERROR
  dispatch (unmeasured here; RED B's probe `BoomAll` — the same throw with `shouldNotFilterErrorDispatch()` false — measured Tomcat's own
  500 page and 3 ERROR lines where `BoomFilter` gives Boot's 500 and 1: the skip decides the answer, RED B #214); whether a resolving filter belongs in the anchor (TiffinBox has no filter that throws).
- **For RED:** re-run under both bashes, the sealed clone, SIGINT during a capture's JVM; check every WARN/ERROR count against its logger
  (Tomcat's, Spring MVC's, Boot's), the catch-all's per-run silence against the as-shipped baseline, the committed 200s (curl exit 18 and 0),
  the `sumf` filter, the seven's moved lines, and that no trap reached the anchor.
