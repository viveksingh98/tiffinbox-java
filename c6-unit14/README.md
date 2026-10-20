# c6-unit14 — Boot's Default Error Response

Course 6 · Spring Web MVC · Section 3 (Errors Done Right), its first unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot
4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5), 2026-10-17. Since the request-mapping lesson every mistake a client can make
gets an answer, and most of them are Boot's: `{"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"}` — a time, the
status, its name, the path. This unit asks TiffinBox for **every error it can give**, as-is, and reads each answer: who writes it (Boot's
**error controller**, `BasicErrorController`, on a second pass — the **error dispatch** — with what Boot's **error attributes**,
`DefaultErrorAttributes`, gather), what it says and what it leaves out (fourteen errors, **five shapes**, no reason in any of them), where
the reason went (one WARN line, Spring MVC's `DefaultHandlerExceptionResolver`, or nothing), what a client that asks for HTML gets (Boot's
**Whitelabel page**, and four of TiffinBox's own answers turned into 406s), what Boot's error keys add (`spring.web.error.include-message`
puts the reason in — and whatever else an exception's message holds, counted with a planted canary), and what DevTools turns on (nine
defaults on this class path, three of them error keys, only with restart enabled). Then it decides whether you would ship it.

**No anchor change (brief ⚑2, ⚑8).** `anchor` is the link to `../c6-unit12/after` — the validation lesson's frozen tree, `c6-tiffinbox` at
Section 2's end — read and copied under `.harness/anchor`, never built in place. `c6-tiffinbox` (now the next lesson's tree) is neither read
nor touched here, and this unit freezes no `after/`. Everything new is **the course's harness**, never TiffinBox's — `harness/probe/web`,
outside `com.tiffinbox`, compiled with `-parameters` against the anchor's own jar and joined by `--spring.main.sources` on the extracted
jar's class path:

- `Boom` — two routes that fail on purpose, because TiffinBox has none that throws an unexpected exception: `/probe/boom` throws an
  `IllegalStateException` ("the kitchen is on fire"); `/probe/boom-note` throws one whose message quotes the request's `X-Order-Note`
  header — the way a real bug puts a client's value into a message. The receipts send a **planted canary** in that header (S3.10):
  26 random hexadecimal digits made when `receipts.sh` starts (`openssl rand -hex 13`, `$NOTE`), never the token, masked in every capture.
- `Who` — reads the running application, as text, and changes nothing: `/probe/who/errors` — the `ErrorController` and `ErrorAttributes`
  beans, how many `ResponseEntityExceptionHandler` beans there are, the `HandlerExceptionResolver` beans in the order the `DispatcherServlet`
  asks them and the resolvers inside Spring MVC's composite, the advice cache's size, the JVM's locale; `/probe/who/devtools` — the
  environment's property source named `devtools`, each key and value, sorted (or none), then for four keys DevTools can set the value the
  environment resolves and the first property source that holds it.
- `harness/shutdown.sh` — POST `/shutdown` with the token read from its file (the binding lesson's, copied unchanged).

**DevTools is a class-path run (⚑8, R.44, S3.13).** No POM changes: `spring-boot-devtools-4.1.1.jar` is read from this unit's repository
(`$M2`, `.m2-demo`, where the S3 seed holds it) and put at the end of the anchor's **extracted** class path — the folders layout, R.44 —
with `-Dspring.devtools.restart.enabled=true` printed on the line (the extracted jar is a packaged application: DevTools must be told) and
`--spring.devtools.livereload.enabled=false` (35729 is never bound, asserted by `lsof`). Exit 1 after POST /shutdown is expected and asserted
(R.47). A second run with `restart.enabled=false` shows the defaults gone.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 7 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) No GraalVM and no Docker
are needed. It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first). **Start it in a process group
of its own** (a terminal's foreground job is one): two receipts started as background jobs of one shell share a group, and one run's clean-up
would stop the other's JVMs (R.94).

**BLUE's runs (2026-10-20, after RED S3's fixes — the S3 brief's AMENDMENT (BLUE S3)):** 361 s under `./receipts.sh` (/bin/bash 3.2.57) and 356 s under `bash receipts.sh` (Homebrew bash 5.3), each `env -i` in a process group of its own, exit 0, every capture 3/3 = published. Captures that changed: path `64ec40cb…` → `6b5603c9…` · html `e40d8ad1…` → `b991dc6b…`; the rest as published before. **SIGINT** (BLUE): to the script's process group during `shapes`' JVM (55 s in; 4 processes, 1 java): exit 130, 0 processes left, no listener, no `.r-lock`, no unfinished run, the captures unchanged (md5). The exercise as viewers run it (one `env -i` /bin/bash, Java 23.0.1 at start): README → `text/html`, SOLUTION twice → `application/json`; SOLUTION alone → `application/json`.

**Runs of record (2026-10-17, this script as committed):** **346 s under `./receipts.sh`** (/bin/bash 3.2.57, `env -i` with HOME and a plain
PATH, this folder, its own process group, `.m2-demo` re-seeded from `_research/m2-seed-s3/` alone: exit 0, all 7 captures 3/3 = published,
every check passed) and **345 s under `bash receipts.sh`** (Homebrew bash 5.3.9, the same, re-seeded: exit 0, all 7 = published). **A
sealed fresh clone**: `git clone` of tiffinbox-java at 12d42f7, this unit's 9 files put in as git would take them (its `.gitignore` lines keep `.m2-demo`, `.harness` and `.r-*` out); `env -i`, a `HOME` of its own whose `.mavenrc` points every Java proxy at a refusing port (127.0.0.1:1, never bound), Maven settings sending every repository to a `file://` copy of Central's files made from this unit's `.m2-demo` (4,373 files), the proxy variables at the same refusing port, `/bin/bash` 3.2, a process group of its own: exit 0 in 350 s, all 7 = published, every check passed; **688 artifacts, every one from the `file://` copy** (512 for the first build, 176 for DevTools' `dependency:get` — Maven's dependency plugin and DevTools' jar; 0 from anywhere else); the first build and the DevTools fetch said `offline: no`, as a fresh clone's must, and every capture's build `offline: yes`. **How the hashes were made:** four development runs (bash 5.3) fixed the filters and the derivations
(Found on the way); the seven hashes of the fourth went into `receipts.md5`; both runs of record reproduced them. **SIGINT**: SIGINT to the script's process group during `shapes`' JVM (52 s in; 3 processes in the group, 1 of them java), the script started as a terminal starts its foreground job (`python3` with `signal.signal(signal.SIGINT, signal.SIG_DFL)` and `os.setpgrp()`, `env -i`, /bin/bash 3.2): **exit 130**; 5 s later 0 processes in the group and 0 anywhere naming this folder or `TiffinBoxServer`; 19430-19439, 8080, 18425 and 35729 free; no `.r-lock`, no unfinished capture run; the published captures unchanged (md5).

Published hashes: path `6b5603c99223d9c900f9ff8a124ce584` · shapes `8fd67ffd6e46683eda60757b7034f50f` · reasons `2d9322452f5a9aa3791968e5463f675b` · html `b991dc6bbb4f61114d3e6f45563feee0` · message `fcf66eea48cc41d5138f526afed1b942` · devtools `1ef2f4accea2a4dc2c4b8172400f4f17` · exercise `c156036038dee6a4bc41d58180107c4a`.

## The commands this unit adds

`anchor/README.md` — the anchor's own — gives every line `receipts.sh` runs or derives from but these thirteen, which are this unit's, each read
from the block below and asserted to be exactly this (on the anchor's port 18431; each capture swaps in its own port):

```bash
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.web.error.include-message=always
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.web.error.include-stacktrace=always
java -Duser.language=en -Duser.country=US -Dspring.devtools.restart.enabled=true -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.devtools.livereload.enabled=false
java -Duser.language=en -Duser.country=US -Dspring.devtools.restart.enabled=false -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.devtools.livereload.enabled=false
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/probe/web/Boom.java harness/probe/web/Who.java
curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:18431/customers/Ravi
curl -s http://127.0.0.1:18431/probe/who/errors
curl -s http://127.0.0.1:18431/probe/who/devtools
curl -s -w ' %{http_code}\n' -H "X-Order-Note: $NOTE" http://127.0.0.1:18431/probe/boom-note
```

The first two are the anchor's run line and its class-path line with `-Duser.language=en -Duser.country=US` after `java` — asserted to be
exactly that — and every java line a capture starts takes the same two options in the same place (`at()`, which must give them back; a last
check refuses any capture's java line without them). The next two are the pinned class-path line with one of Boot's error keys at the end.
The two DevTools lines are the pinned class-path line with restart's option before `-cp`, DevTools' jar at the end of the class path and Live
Reload's option at the end, and nothing else (asserted). The javac line compiles the harness's two files and nothing else. The catalogue's
line is the anchor's one-customer line with curl's `Content-Type` printed (`[]` when there is none); every catalogue request is that line
with its path swapped and, where it needs them, the anchor README's own options (its GET line's meal type, its POST line's `Content-Type`
and body, its 2.7 line, its refused-body line, its `-X POST`) — each kind asserted against the anchor's line. The harness's two questions
are plain GETs; the canary's line is the readiness line with one header and another path (asserted). `$M2` is this unit's `.m2-demo`;
`$NOTE` is the canary (above).

## The repository, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../spring-web-mvc/_research/m2-seed-s3/` alone — 5,837 files, DevTools 4.1.1 among them, no `com/tiffinbox` — and re-seeded so before each
run of record. **Nothing was downloaded** for this unit: every build said `offline: yes`, and DevTools' jar was read from the seed. A fresh
clone's `.m2-demo` is empty (git ignores it): the first build — `.harness/pre`, before any capture — fills it from Maven Central and says
`offline: no`; no POM names DevTools, so the script asks Maven for its jar once, by name (`dependency:get`, offline first, and says which).
**At run time** every request goes to `127.0.0.1`, and nothing binds 8080, 18425 or 35729.

## The demo token, and the canary

The demo token — `TOKEN=` at the top of `receipts.sh`, 26 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/anchor/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) when the script runs, and sent only by `../c5-unit11/curlset.sh` and `harness/shutdown.sh` on curl's standard input. Every
capture's raw output is searched for it before masking (0 in all of them), and so are the log of every JVM that served, and every file this
unit ships: 0 everywhere. The header's name, `X-Shutdown-Token`, is counted too: 0 in every log. **The canary** (S3.10, proposed R.106) is
the only value any capture sends toward an answer: `$NOTE`, made per run, sent in `X-Order-Note` to the harness's `/probe/boom-note`, and
counted raw — before masking — in the answer and in the lines its request added to the log (`message`, `devtools`); every capture shows it
as `[masked: the 26-character canary]`, and a last check finds this run's canary raw in no capture and no shipped file. The exercise makes a
token of its own (`openssl rand -hex 13`), counted 0 times in its own log and never printed.

## The locale — pinned per JVM

Every java line this script starts carries `-Duser.language=en -Duser.country=US` before `-jar` or `-cp` (S3.1, RED B2 #111), and `Who`
prints the JVM's locale (`en_US`). On macOS the JVM takes the Mac's first language, not `LC_ALL`, and Spring's, Jackson's and Tomcat's
messages in this unit's log lines, the messages `include-message` puts in an answer, and Boot's Whitelabel page are text a JVM in another
language could word otherwise. A last check refuses any capture whose java line lacks the two options (the extract line, `-Djarmode=tools`,
prints nothing a locale changes).

## The folders, the names and the ports

- `.harness/pre` — the anchor built before any capture; `.harness/anchor` — the anchor, copied, with a config tree, built and extracted
  (`path`); `.harness/hc` — the harness's classes, compiled against the anchor's own jar with `-parameters`; `.harness/mine` — the
  exercise's copy.
- **Ports** (brief ⚑1, 19430-19439): path 19430 · shapes 19431 · reasons 19432 · html 19433 · message A and A′ 19434, B 19435, C 19436 ·
  devtools, restart enabled 19437, disabled 19438 · the exercise 19439. All ten, 18425 (TiffinBox's default), 8080 (Tomcat's) and 35729
  (DevTools' Live Reload) are checked free first; a run that listens on 8080 or 35729 is killed and the script dies.

## Masks, filters and hygiene — every one, declared

1. **Paths, the token, the canary, the user** (`gsub()`, literals escaped), in every line: the demo token → `[masked: the 26-character
   token]`; the canary → `[masked: the 26-character canary]`; this folder → `…`; the folder above → `…/..`; home → `~`; the user name, as a
   whole word → `<user>`. A last check fails if any capture holds `/Users/`, `/private/`, `/home/`, `/var/folders/`, a unit number, Boot's
   process line, a log time, an unmasked timestamp, a `GMT`, `CET` or `CEST` date, a date in Java's `Date` form, a thread number, a stack
   frame, a trace's frame outside its counted summary, a whole HTML page, `:8080` or `:35729`, a carriage return, or a command with a URL
   that is not `127.0.0.1`'s.
2. **Spring's error timestamp** (`tsmask`, `gsub`): `"timestamp":"<anything>"` → `"timestamp":"…"` and `"timestamp":<digits>` →
   `"timestamp":…` — both forms — in every answer printed and in the seven, which are hashed after it (two lines changed); its form printed
   beside the seven (`tsform`). At DEBUG, `timestamp=…,` in the map Spring MVC logs.
3. **Answers** (`pagef`, S3.6, S3.11): Boot's **Whitelabel page** is printed as its `<h1>` and its error line (`There was an unexpected
   error (type=…, status=…).`); its `created` date — written in the JVM's time zone — is masked, and its paragraph counted, never shown.
   **Tomcat's own error page** (`a%2Fb`) as its `<title>` and `<h1>`, its other characters counted. A page of another shape is counted,
   never shown. A JSON answer that holds a **`trace`** is printed with the trace cut to `"…"`, then the trace's first line and its frames
   (`\tat` lines) and other lines, counted. An empty answer is `(no body)`. Checked on six planted answers before any capture.
4. **Log lines** (`logl`, `recs`, `dbg`): from their logger on, as the log prints the logger —
   `.w.s.m.s.DefaultHandlerExceptionResolver`, `.w.s.m.a.ResponseStatusExceptionResolver`, `o.s.web.servlet.DispatcherServlet`,
   `s.w.s.m.m.a.RequestMappingHandlerMapping`, `o.s.w.s.m.m.a.HttpEntityMethodProcessor`, `o.s.w.s.handler.SimpleUrlHandlerMapping` and
   `o.s.w.s.r.ResourceHttpRequestHandler` are **Spring MVC's**; `o.a.c.c.C.[.[.[/].[dispatcherServlet]` is **Tomcat's**; `BasicErrorController`,
   `DefaultErrorAttributes`, `.e.DevToolsPropertyDefaultsPostProcessor` and the Whitelabel page are **Boot's**; a Jackson message inside a
   WARN is Jackson's message, in Spring's line. Boot's first line is cut before ` with PID`; DevTools' own line, written before logging
   starts (`RestartApplicationListener`), from its level on, counted (`×N`). Every request a capture asks (`rq`) ends its answer's first line
   with `· WARN lines it added: N · ERROR lines: M` — the lines the log gained between two points where it stopped growing — and each WARN
   or ERROR record follows: its level, logger and message, then the exception line under it; its stack frames bounded ("over 40") and its
   other lines counted, none shown (checked on a planted log first). At DEBUG (`dreq`) every log line a request added is printed, counted,
   and the lines that are no log line (a stack trace's) counted, never shown.
5. **The shapes** (`shapesum`): each error answer (a status of 400 or more) given a shape — a JSON answer by its Content-Type and its keys,
   sorted; an HTML page by its `<title>` or `<h1>`; no body by its Content-Type — and the shapes counted, each with its statuses.
6. **A URL that holds a character the shell reads** (`;`, `?`, `&`, `*`, `{`, `}`, a space) is single-quoted on the command line, so the
   printed command is the one that ran.
7. **A′ against A** (`asame`): A's block and A′'s, their labels aside, compared line for line in the capture itself ("yes").
8. **On this Mac**: `lsof` by pid (or by port), the address column alone — never a command name (R.18).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`, and the exercise's
shell `$xpid` with every process under it — `killtree`, by parent pid), sweeps its own process group for any TiffinBox JVM or Maven left,
deletes the capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched. No `wait` in the
script, its checks or the exercise is bare: each names its pid (S3.9; a check refuses a bare one). **Measured**: SIGINT to the script's process group during `shapes`' JVM (52 s in; 3 processes in the group, 1 of them java), the script started as a terminal starts its foreground job (`python3` with `signal.signal(signal.SIGINT, signal.SIG_DFL)` and `os.setpgrp()`, `env -i`, /bin/bash 3.2): **exit 130**; 5 s later 0 processes in the group and 0 anywhere naming this folder or `TiffinBoxServer`; 19430-19439, 8080, 18425 and 35729 free; no `.r-lock`, no unfinished capture run; the published captures unchanged (md5).

## 1 · path — who writes an error answer

**The seven**, on a fresh JVM of the anchor's jar: `87ca7efc…` (masked, 2 lines changed by the mask), as on every tree since the
request-mapping lesson, and one WARN — Spring MVC's `DefaultHandlerExceptionResolver`, GET /shutdown's 405. **Who writes an error answer**
(the harness's `Who`, the class path): one `ErrorController`, Boot's `BasicErrorController`; one `ErrorAttributes`, Boot's
`DefaultErrorAttributes`; 0 `ResponseEntityExceptionHandler` beans; the `DispatcherServlet` asks **2** `HandlerExceptionResolver` beans —
`DefaultErrorAttributes` first, then Spring MVC's composite, whose **3** are `ExceptionHandlerExceptionResolver`,
`ResponseStatusExceptionResolver`, `DefaultHandlerExceptionResolver`; the advice cache holds 0 advices. **At DEBUG** (the embedded-Tomcat
lesson's option): `/probe/boom` — `Failed to complete request` (the `DispatcherServlet`), **Tomcat's** ERROR line, then `"ERROR" dispatch for
GET "/error"`, mapped to `BasicErrorController#error`, the map written by `HttpEntityMethodProcessor`, `Exiting from "ERROR" dispatch, status
500`; `/nowhere` — the static files row takes the path and finds no file, `DefaultHandlerExceptionResolver` resolves the
`NoResourceFoundException`, `Completed 404`, and the same error dispatch, status 404; `/customers/a%2Fb` — **Tomcat's** own HTML 400 page,
and **0 log lines** at DEBUG: Spring never sees it (RED A #133). The container — Tomcat — sends the request back
(C6-8, H-01): that is the measured "who sends it back".

`.r-path.out` · md5 `6b5603c99223d9c900f9ff8a124ce584` · 3 of 3

```
the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline):
$ cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the anchor · offline: yes · exit 0
  and its jar extracted (the README's line) - the class path the harness runs on:
$ cd .harness/anchor && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
the harness, compiled against the anchor's own jar - with -parameters (this unit's line):
$ javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/probe/web/Boom.java harness/probe/web/Who.java
  exit 0 · its classes: probe/web/Boom.class probe/web/Who.class
the seven - the anchor, the README's run line (its locale pinned), port 19430, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19430
  listens on: 127.0.0.1:19430 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19430/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19430 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 2 · md5 87ca7efc8584dcccd40e6b956db1de9b
  the timestamps the mask hid, their form: "timestamp":"dddd-dd-ddTdd:dd:dd.dddZ" ×2
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpRequestMethodNotSupportedException: Request method 'GET' is not supported]
who writes an error answer - the anchor on its class path, the harness's Who and Boom joined, port 19430, read off the running application:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19430 --spring.main.sources=probe.web.Who,probe.web.Boom
  listens on: 127.0.0.1:19430 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19430/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19430/probe/who/errors
  ErrorController beans: basicErrorController - org.springframework.boot.webmvc.autoconfigure.error.BasicErrorController
  ErrorAttributes beans: errorAttributes - org.springframework.boot.webmvc.error.DefaultErrorAttributes
  ResponseEntityExceptionHandler beans: 0
  the HandlerExceptionResolver beans, in the order the DispatcherServlet asks them: 2
    1 errorAttributes - org.springframework.boot.webmvc.error.DefaultErrorAttributes
    2 handlerExceptionResolver - org.springframework.web.servlet.handler.HandlerExceptionResolverComposite
        2.1 org.springframework.web.servlet.mvc.method.annotation.ExceptionHandlerExceptionResolver
        2.2 org.springframework.web.servlet.mvc.annotation.ResponseStatusExceptionResolver
        2.3 org.springframework.web.servlet.mvc.support.DefaultHandlerExceptionResolver
  ExceptionHandlerExceptionResolver's advice cache: 0 advices
  the JVM's locale: en_US
$ harness/shutdown.sh 19430 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19430 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
at DEBUG - the embedded-Tomcat lesson's option (Boot's web group at DEBUG), the same class path, port 19430: a route that throws (the harness's Boom), then a path no route takes, then a name with an encoded slash:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19430 --spring.main.sources=probe.web.Who,probe.web.Boom --logging.level.web=debug
  listens on: 127.0.0.1:19430 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19430/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19430/probe/boom
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/boom"} 500 · Content-Type: [application/json]
  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - its log lines, all 9, and 45 other lines (a stack trace's: frames and blank lines), not shown:
    o.s.web.servlet.DispatcherServlet: GET "/probe/boom", parameters={}
    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to probe.web.Boom#boom()
    o.s.web.servlet.DispatcherServlet: Failed to complete request: java.lang.IllegalStateException: the kitchen is on fire
    o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen is on fire] with root cause
    o.s.web.servlet.DispatcherServlet: "ERROR" dispatch for GET "/error", parameters={}
    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to org.springframework.boot.webmvc.autoconfigure.error.BasicErrorController#error(HttpServletRequest)
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Writing [{timestamp=…, status=500, error=Internal Server Error, path=/probe/boom}]
    o.s.web.servlet.DispatcherServlet: Exiting from "ERROR" dispatch, status 500
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19430/nowhere
  {"timestamp":"…","status":404,"error":"Not Found","path":"/nowhere"} 404 · Content-Type: [application/json]
  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - its log lines, all 10, and 0 other lines (a stack trace's: frames and blank lines), not shown:
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
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19430/customers/a%2Fb
  an HTML page - its <title>: HTTP Status 400 – Bad Request · its <h1>: HTTP Status 400 – Bad Request · its other characters: 349, not shown · then curl's: 400 · Content-Type: [text/html;charset=utf-8]
  the lines the log gained for it, Boot's web group at DEBUG (logger: message) - its log lines, all 0, and 0 other lines (a stack trace's: frames and blank lines), not shown:
$ harness/shutdown.sh 19430 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19430 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 2 · shapes — every error, each answer whole

Fifteen requests, curl's own `Accept: */*` unless a line names one: a meal type in lowercase, a body cut off, 2.7 meals (each Boot's 400);
a body that breaks four rules (the method's own field map, 400); `/customers/a%2Fb` (an encoded slash: **Tomcat's** HTML 400 — Spring never
sees it); POST /shutdown without the token (`{"error":"forbidden"}`, 403); `/nowhere` and `/customers/Nobody` (Boot's 404 — **no name**);
GET /shutdown and DELETE /customers (Boot's 405); Ravi for a client that accepts only XML (**406, no body, no Content-Type**); a form body
(Boot's 415 — the one POST without a JSON `Content-Type`, labelled, R.98); a new name, 201, then the same again (**409, no body**); the
harness's `/probe/boom` (Boot's 500). **Fourteen errors, five shapes** — the capture's own count: Boot's four keys ×9 (400 ×3, 404 ×2, 405 ×2,
415, 500), the field map, Tomcat's page, `{"error"}`, and no body (the 406 and the 409 — no body, no Content-Type: one shape by body; not the same bytes — the 406 also sends an
`Accept` header naming what it could have written, RED A #132).

`.r-shapes.out` · md5 `8fd67ffd6e46683eda60757b7034f50f` · 3 of 3

```
the catalogue - the anchor on its class path, the harness's Boom joined, port 19431, a fresh JVM; curl's own Accept (*/*) unless a line names one:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19431 --spring.main.sources=probe.web.Boom
  listens on: 127.0.0.1:19431 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19431/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' 'http://127.0.0.1:19431/customers?mealType=veg'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · Content-Type: [application/json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":' http://127.0.0.1:19431/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · Content-Type: [application/json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19431/customers
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · Content-Type: [application/json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19431/customers
  {"mealType":"must match \"VEG|NON_VEG|VEGAN\"","mealsPerDay":"must be greater than or equal to 1","name":"must not be blank","pricePerMeal":"must be greater than or equal to 1"} 400 · Content-Type: [application/json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19431/customers/a%2Fb
  an HTML page - its <title>: HTTP Status 400 – Bad Request · its <h1>: HTTP Status 400 – Bad Request · its other characters: 349, not shown · then curl's: 400 · Content-Type: [text/html;charset=utf-8]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -X POST http://127.0.0.1:19431/shutdown
  {"error":"forbidden"} 403 · Content-Type: [application/json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19431/nowhere
  {"timestamp":"…","status":404,"error":"Not Found","path":"/nowhere"} 404 · Content-Type: [application/json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19431/customers/Nobody
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Nobody"} 404 · Content-Type: [application/json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19431/shutdown
  {"timestamp":"…","status":405,"error":"Method Not Allowed","path":"/shutdown"} 405 · Content-Type: [application/json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -X DELETE http://127.0.0.1:19431/customers
  {"timestamp":"…","status":405,"error":"Method Not Allowed","path":"/customers"} 405 · Content-Type: [application/json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19431/customers/Ravi
  (no body) · 406 · Content-Type: []
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' --data 'name=Asha' http://127.0.0.1:19431/customers
  {"timestamp":"…","status":415,"error":"Unsupported Media Type","path":"/customers"} 415 · Content-Type: [application/json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Lata","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19431/customers
  {"name":"Lata","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Content-Type: [application/json]
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Lata","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19431/customers
  (no body) · 409 · Content-Type: []
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19431/probe/boom
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/boom"} 500 · Content-Type: [application/json]
  WARN lines in this run's log, at Boot's default level: 7 · ERROR lines: 1
$ harness/shutdown.sh 19431 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19431 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the error answers: 14 · their shapes: 5
  1 JSON (application/json), its keys: error path status timestamp - 9 answers: 400 400 400 404 404 405 405 415 500
  2 JSON (application/json), its keys: mealType mealsPerDay name pricePerMeal - 1 answers: 400
  3 an HTML page (text/html;charset=utf-8): HTTP Status 400 – Bad Request - 1 answers: 400
  4 JSON (application/json), its keys: error - 1 answers: 403
  5 no body, no Content-Type - 2 answers: 406 409
```

## 3 · reasons — where the reason went

The same requests on a fresh JVM, each answer's status (its body is in `shapes`) and the WARN and ERROR lines it added, at Boot's
default level (S3.14): **one WARN, Spring MVC's `DefaultHandlerExceptionResolver`**, for each 400 Boot answered (the type mismatch, Jackson's
end-of-input, Jackson's 2.7 coercion), both 405s, the 406 and the 415 — **7**; **none** for either 404 (the static files row's
`NoResourceFoundException`, `ResponseStatusException`), the method's own 400, the 403, the 201 and the 409; **the 500: one ERROR, Tomcat's**
(`o.a.c.c.C.[.[.[/].[dispatcherServlet]`), its exception line, over 40 frames. H-08 agrees ("the reason is only in one warning line").

`.r-reasons.out` · md5 `2d9322452f5a9aa3791968e5463f675b` · 3 of 3

```
the same requests - the anchor on its class path, the harness's Boom joined, port 19432, a fresh JVM: each answer's status, then the WARN and ERROR lines it added, at Boot's default level:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19432 --spring.main.sources=probe.web.Boom
  listens on: 127.0.0.1:19432 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19432/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' 'http://127.0.0.1:19432/customers?mealType=veg'
  the answer: 400 · Content-Type: [application/json] · its body: in shapes, not here · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'mealType': Failed to convert value of type 'java.lang.String' to required type 'com.tiffinbox.MealType'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam com.tiffinbox.MealType] for value [veg]]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":' http://127.0.0.1:19432/customers
  the answer: 400 · Content-Type: [application/json] · its body: in shapes, not here · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Unexpected end-of-input within/between Object entries]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19432/customers
  the answer: 400 · Content-Type: [application/json] · its body: in shapes, not here · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot coerce Floating-point value (2.7) to `int` value (but could if coercion was enabled using `CoercionConfig`)]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19432/customers
  the answer: 400 · Content-Type: [application/json] · its body: in shapes, not here · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19432/customers/a%2Fb
  the answer: 400 · Content-Type: [text/html;charset=utf-8] · its body: in shapes, not here · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -X POST http://127.0.0.1:19432/shutdown
  the answer: 403 · Content-Type: [application/json] · its body: in shapes, not here · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19432/nowhere
  the answer: 404 · Content-Type: [application/json] · its body: in shapes, not here · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19432/customers/Nobody
  the answer: 404 · Content-Type: [application/json] · its body: in shapes, not here · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19432/shutdown
  the answer: 405 · Content-Type: [application/json] · its body: in shapes, not here · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpRequestMethodNotSupportedException: Request method 'GET' is not supported]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -X DELETE http://127.0.0.1:19432/customers
  the answer: 405 · Content-Type: [application/json] · its body: in shapes, not here · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpRequestMethodNotSupportedException: Request method 'DELETE' is not supported]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: application/xml' http://127.0.0.1:19432/customers/Ravi
  the answer: 406 · Content-Type: [] · no body · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' --data 'name=Asha' http://127.0.0.1:19432/customers
  the answer: 415 · Content-Type: [application/json] · its body: in shapes, not here · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotSupportedException: Content-Type 'application/x-www-form-urlencoded;charset=UTF-8' is not supported]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Lata","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19432/customers
  the answer: 201 · Content-Type: [application/json] · its body: in shapes, not here · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Lata","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19432/customers
  the answer: 409 · Content-Type: [] · no body · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19432/probe/boom
  the answer: 500 · Content-Type: [application/json] · its body: in shapes, not here · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen is on fire] with root cause
      java.lang.IllegalStateException: the kitchen is on fire
      its stack frames: over 40, its other lines: 2 - none shown
  WARN lines in this run's log, at Boot's default level: 7 · ERROR lines: 1
$ harness/shutdown.sh 19432 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19432 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 4 · html — a client that asks for HTML alone; C, Chrome's whole Accept header

The same requests, each from a client that asks for **HTML alone** — `Accept: text/html`, **sent by curl; no browser ran** (S3.12) — the
406's own XML header made `text/html` too: **13 of 15 answers are Boot's Whitelabel page**, each with its status (`/nowhere`'s 404 — C6-8's other half —
`/customers/Nobody`'s 404, the 400s, the 405s, the 415, the 500); **four become 406s**: the method's field map, the 403's map, Ravi himself,
and **Lata's 201 — she was stored** (the same POST again is a 409) while the client was told 406, each with one WARN (`No acceptable
representation`); Tomcat's `a%2Fb` page and the empty 409 unchanged. 10 WARN, 1 ERROR in all (H-11: Boot sends the 406 as its own HTML page;
the XML 406 is empty — `shapes`). **C (labelled): Chrome's whole Accept header**, sent by curl, the same JVM — Ravi **200, JSON**; a name
nobody has, the Whitelabel 404. A real browser's header ends with `*/*;q=0.8`, so TiffinBox's own answers stay JSON for it: **only a
client that asks for HTML alone gets the 406s** (RED A #128); for an error, both get the Whitelabel page.

`.r-html.out` · md5 `b991dc6bbb4f61114d3e6f45563feee0` · 3 of 3

```
the same requests, each from a client that asks for HTML alone - Accept: text/html, sent by curl (the 406's own XML header made text/html too) - the anchor on its class path, the harness's Boom joined, port 19433, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19433 --spring.main.sources=probe.web.Boom
  listens on: 127.0.0.1:19433 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19433/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' 'http://127.0.0.1:19433/customers?mealType=veg'
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Bad Request, status=400). · its created date: masked · its paragraphs: 1, not shown · then curl's: 400 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'mealType': Failed to convert value of type 'java.lang.String' to required type 'com.tiffinbox.MealType'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam com.tiffinbox.MealType] for value [veg]]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' -H 'Content-Type: application/json' --data '{"name":' http://127.0.0.1:19433/customers
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Bad Request, status=400). · its created date: masked · its paragraphs: 1, not shown · then curl's: 400 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Unexpected end-of-input within/between Object entries]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' -H 'Content-Type: application/json' --data '{"name":"Mohan","mealsPerDay":2.7,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19433/customers
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Bad Request, status=400). · its created date: masked · its paragraphs: 1, not shown · then curl's: 400 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.http.converter.HttpMessageNotReadableException: JSON parse error: Cannot coerce Floating-point value (2.7) to `int` value (but could if coercion was enabled using `CoercionConfig`)]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' -H 'Content-Type: application/json' --data '{"name":"","mealsPerDay":0,"pricePerMeal":-5,"mealType":"LUNCH"}' http://127.0.0.1:19433/customers
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Not Acceptable, status=406). · its created date: masked · its paragraphs: 1, not shown · then curl's: 406 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19433/customers/a%2Fb
  an HTML page - its <title>: HTTP Status 400 – Bad Request · its <h1>: HTTP Status 400 – Bad Request · its other characters: 349, not shown · then curl's: 400 · Content-Type: [text/html;charset=utf-8] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' -X POST http://127.0.0.1:19433/shutdown
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Not Acceptable, status=406). · its created date: masked · its paragraphs: 1, not shown · then curl's: 406 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19433/nowhere
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Not Found, status=404). · its created date: masked · its paragraphs: 1, not shown · then curl's: 404 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19433/customers/Nobody
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Not Found, status=404). · its created date: masked · its paragraphs: 1, not shown · then curl's: 404 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19433/shutdown
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Method Not Allowed, status=405). · its created date: masked · its paragraphs: 1, not shown · then curl's: 405 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpRequestMethodNotSupportedException: Request method 'GET' is not supported]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' -X DELETE http://127.0.0.1:19433/customers
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Method Not Allowed, status=405). · its created date: masked · its paragraphs: 1, not shown · then curl's: 405 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpRequestMethodNotSupportedException: Request method 'DELETE' is not supported]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19433/customers/Ravi
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Not Acceptable, status=406). · its created date: masked · its paragraphs: 1, not shown · then curl's: 406 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' --data 'name=Asha' http://127.0.0.1:19433/customers
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Unsupported Media Type, status=415). · its created date: masked · its paragraphs: 1, not shown · then curl's: 415 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotSupportedException: Content-Type 'application/x-www-form-urlencoded;charset=UTF-8' is not supported]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' -H 'Content-Type: application/json' --data '{"name":"Lata","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19433/customers
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Not Acceptable, status=406). · its created date: masked · its paragraphs: 1, not shown · then curl's: 406 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.HttpMediaTypeNotAcceptableException: No acceptable representation]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' -H 'Content-Type: application/json' --data '{"name":"Lata","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19433/customers
  (no body) · 409 · Content-Type: [] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19433/probe/boom
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown · then curl's: 500 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen is on fire] with root cause
      java.lang.IllegalStateException: the kitchen is on fire
      its stack frames: over 40, its other lines: 2 - none shown
  WARN lines in this run's log, at Boot's default level: 10 · ERROR lines: 1
C (labelled) - Chrome's whole Accept header, sent by curl, the same JVM: TiffinBox's own answer (Ravi), then a name nobody has:
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' http://127.0.0.1:19433/customers/Ravi
  {"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"} 200 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' http://127.0.0.1:19433/customers/Nobody
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Not Found, status=404). · its created date: masked · its paragraphs: 1, not shown · then curl's: 404 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
$ harness/shutdown.sh 19433 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19433 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 5 · message — Boot's error keys (A/B/A′; C, labelled)

Boot's own metadata (`spring-boot-autoconfigure-4.1.1.jar`): `spring.web.error.include-message` default `never`, `include-exception`
`false`, `include-stacktrace` `never`, `include-binding-errors` `never`, `include-path` `always` (§4.5: Boot 4.1's keys; Boot 3's
`server`-prefixed names are refused by a check in every file here). **A**, Boot's default: Nobody's 404 has no message; the type mismatch's
400 none; the canary's 500 none — **the canary 0 times in the answer, 2 in the log** (Tomcat's ERROR line and the exception line: an
exception's message is logged whole whatever the body says). **B**, `--spring.web.error.include-message=always`: `"message":"no customer named
Nobody"`, the type mismatch's reason (`Method parameter 'mealType': Failed to convert value …`), and the 500's message — **the canary 1 time in
the answer**, 2 in the log. **A′** = A (`yes`). **C (labelled)**, `--spring.web.error.include-stacktrace=always` instead: the 500's `trace`,
**44 frames**, its first line the exception and its message — the canary 1 time in the answer. `include-binding-errors` shows nothing on this
tree's own routes — the method answers its refused body itself — so it is cited from the validation lesson's `keys`, not re-claimed (H-12).

`.r-message.out` · md5 `fcf66eea48cc41d5138f526afed1b942` · 3 of 3

```
Boot's error keys, read off its own metadata in the anchor's jars:
  Boot's metadata (spring-boot-autoconfigure-4.1.1.jar) - spring.web.error.include-message · its type: ErrorProperties$IncludeAttribute · its default: "never" · its description: When to include "message" attribute.
  Boot's metadata (spring-boot-autoconfigure-4.1.1.jar) - spring.web.error.include-exception · its type: Boolean · its default: false · its description: Include the "exception" attribute.
  Boot's metadata (spring-boot-autoconfigure-4.1.1.jar) - spring.web.error.include-stacktrace · its type: ErrorProperties$IncludeAttribute · its default: "never" · its description: When to include the "trace" attribute.
  Boot's metadata (spring-boot-autoconfigure-4.1.1.jar) - spring.web.error.include-binding-errors · its type: ErrorProperties$IncludeAttribute · its default: "never" · its description: When to include "errors" attribute.
  Boot's metadata (spring-boot-autoconfigure-4.1.1.jar) - spring.web.error.include-path · its type: ErrorProperties$IncludeAttribute · its default: "always" · its description: When to include "path" attribute.
A - the anchor on its class path (this unit's line), the harness's Boom joined, port 19434: a name nobody has, a meal type no route takes, and a route that quotes a header in its exception's message - the canary in that header:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19434 --spring.main.sources=probe.web.Boom
  listens on: 127.0.0.1:19434 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19434/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19434/customers/Nobody
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Nobody"} 404 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' 'http://127.0.0.1:19434/customers?mealType=veg'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · Content-Type: [application/json] · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'mealType': Failed to convert value of type 'java.lang.String' to required type 'com.tiffinbox.MealType'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam com.tiffinbox.MealType] for value [veg]]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code}\n' -H "X-Order-Note: $NOTE" http://127.0.0.1:19434/probe/boom-note
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/boom-note"} 500 · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen could not read the note [masked: the 26-character canary]] with root cause
      java.lang.IllegalStateException: the kitchen could not read the note [masked: the 26-character canary]
      its stack frames: over 40, its other lines: 2 - none shown
  the canary ($NOTE) in this answer: 0 times · in the lines the log gained for it: 2 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 1
$ harness/shutdown.sh 19434 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19434 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the same, with Boot's include-message key set to always (this unit's line), port 19435:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19435 --spring.web.error.include-message=always --spring.main.sources=probe.web.Boom
  listens on: 127.0.0.1:19435 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19435/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19435/customers/Nobody
  {"timestamp":"…","status":404,"error":"Not Found","message":"no customer named Nobody","path":"/customers/Nobody"} 404 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' 'http://127.0.0.1:19435/customers?mealType=veg'
  {"timestamp":"…","status":400,"error":"Bad Request","message":"Method parameter 'mealType': Failed to convert value of type 'java.lang.String' to required type 'com.tiffinbox.MealType'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam com.tiffinbox.MealType] for value [veg]","path":"/customers"} 400 · Content-Type: [application/json] · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'mealType': Failed to convert value of type 'java.lang.String' to required type 'com.tiffinbox.MealType'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam com.tiffinbox.MealType] for value [veg]]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code}\n' -H "X-Order-Note: $NOTE" http://127.0.0.1:19435/probe/boom-note
  {"timestamp":"…","status":500,"error":"Internal Server Error","message":"the kitchen could not read the note [masked: the 26-character canary]","path":"/probe/boom-note"} 500 · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen could not read the note [masked: the 26-character canary]] with root cause
      java.lang.IllegalStateException: the kitchen could not read the note [masked: the 26-character canary]
      its stack frames: over 40, its other lines: 2 - none shown
  the canary ($NOTE) in this answer: 1 times · in the lines the log gained for it: 2 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 1
$ harness/shutdown.sh 19435 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19435 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, a fresh JVM, port 19434:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19434 --spring.main.sources=probe.web.Boom
  listens on: 127.0.0.1:19434 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19434/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19434/customers/Nobody
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Nobody"} 404 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' 'http://127.0.0.1:19434/customers?mealType=veg'
  {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"} 400 · Content-Type: [application/json] · WARN lines it added: 1 · ERROR lines: 0
    WARN .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.method.annotation.MethodArgumentTypeMismatchException: Method parameter 'mealType': Failed to convert value of type 'java.lang.String' to required type 'com.tiffinbox.MealType'; Failed to convert from type [java.lang.String] to type [@org.springframework.web.bind.annotation.RequestParam com.tiffinbox.MealType] for value [veg]]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code}\n' -H "X-Order-Note: $NOTE" http://127.0.0.1:19434/probe/boom-note
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/boom-note"} 500 · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen could not read the note [masked: the 26-character canary]] with root cause
      java.lang.IllegalStateException: the kitchen could not read the note [masked: the 26-character canary]
      its stack frames: over 40, its other lines: 2 - none shown
  the canary ($NOTE) in this answer: 0 times · in the lines the log gained for it: 2 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 1
$ harness/shutdown.sh 19434 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19434 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
C (labelled) - include-stacktrace set to always instead (this unit's line), port 19436: the route that throws, then the canary's:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19436 --spring.web.error.include-stacktrace=always --spring.main.sources=probe.web.Boom
  listens on: 127.0.0.1:19436 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19436/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19436/probe/boom
  {"timestamp":"…","status":500,"error":"Internal Server Error","trace":"…","path":"/probe/boom"} 500 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 1
    its "trace", cut above: its first line: java.lang.IllegalStateException: the kitchen is on fire · its frames (\tat): 44 · its other lines: 0 - none shown
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen is on fire] with root cause
      java.lang.IllegalStateException: the kitchen is on fire
      its stack frames: over 40, its other lines: 2 - none shown
$ curl -s -w ' %{http_code}\n' -H "X-Order-Note: $NOTE" http://127.0.0.1:19436/probe/boom-note
  {"timestamp":"…","status":500,"error":"Internal Server Error","trace":"…","path":"/probe/boom-note"} 500 · WARN lines it added: 0 · ERROR lines: 1
    its "trace", cut above: its first line: java.lang.IllegalStateException: the kitchen could not read the note [masked: the 26-character canary] · its frames (\tat): 44 · its other lines: 0 - none shown
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen could not read the note [masked: the 26-character canary]] with root cause
      java.lang.IllegalStateException: the kitchen could not read the note [masked: the 26-character canary]
      its stack frames: over 40, its other lines: 2 - none shown
  the canary ($NOTE) in this answer: 1 times · in the lines the log gained for it: 2 times
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 2
$ harness/shutdown.sh 19436 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19436 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 6 · devtools — what DevTools turns on (restart enabled; restart disabled)

**Restart enabled** (the folders layout: the extracted class path, DevTools' jar from `$M2`, `-Dspring.devtools.restart.enabled=true`,
Live Reload off): DevTools' own line before logging starts (`Restart enabled irrespective of application packaging …`, ×2), Boot's
`DevToolsPropertyDefaultsPostProcessor`: `Devtools property defaults active!`; 35729 not bound; the property source `devtools`, read off the
environment: **9 keys on this class path** — `spring.web.error.include-binding-errors`, `include-message`, `include-stacktrace` (always),
`spring.mvc.log-resolved-exception` (true), `spring.template.provider.cache` (false), `spring.web.resources.cache.period` (0),
`spring.web.resources.chain.cache` (false), `server.servlet.session.persistent` (true), `server.servlet.jsp.init-parameters.development`
(true) — and the four DevTools-set keys resolve **from: devtools**. Nobody's 404 gains `message` and a `trace` (46 frames) and **one WARN,
Spring MVC's `ResponseStatusExceptionResolver`** (log-resolved-exception; 0 without DevTools); the 500's trace **44 frames**; **the canary 2
times in the answer** (message and trace); exit **1** after POST /shutdown (R.47). **Restart disabled**: DevTools' line `Restart disabled …`;
the property source **none**, the keys `not set`; Boot's four keys, 0 WARN; the canary 0 in the answer; exit **0**. Course 5's "seven defaults,
six for a web layer" was its class path's count (C6-18): here nine. The template default belongs to *Serving HTML: Thymeleaf*, the two
resource defaults to *Static Resources and Cache Headers*, the session key to *Sessions, Cookies and Flash Attributes* — named, not shown.

`.r-devtools.out` · md5 `1ef2f4accea2a4dc2c4b8172400f4f17` · 3 of 3

```
the anchor's class path, as the README extracts it, with DevTools 4.1.1's jar added from $M2 (the folders layout: this unit's line), restart enabled, Live Reload off, the harness's Who and Boom joined, port 19437:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -Dspring.devtools.restart.enabled=true -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc:$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19437 --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Who,probe.web.Boom
  listens on: 127.0.0.1:19437 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19437/actuator/health/readiness
  {"status":"UP"} 200
  DevTools' line before logging starts:
    INFO org.springframework.boot.devtools.restart.RestartApplicationListener -- Restart enabled irrespective of application packaging due to System property 'spring.devtools.restart.enabled' being set to true ×2
  Boot's DevTools lines in the log (logger: message):
    .e.DevToolsPropertyDefaultsPostProcessor: Devtools property defaults active! Set 'spring.devtools.add-properties' to 'false' to disable
    .e.DevToolsPropertyDefaultsPostProcessor: For additional web related logging consider setting the 'logging.level.web' property to 'DEBUG'
  listening on 35729 (Live Reload's port) now: 0
$ curl -s http://127.0.0.1:19437/probe/who/devtools
  the property source named devtools: 9 keys, sorted
    server.servlet.jsp.init-parameters.development = true
    server.servlet.session.persistent = true
    spring.mvc.log-resolved-exception = true
    spring.template.provider.cache = false
    spring.web.error.include-binding-errors = always
    spring.web.error.include-message = always
    spring.web.error.include-stacktrace = always
    spring.web.resources.cache.period = 0
    spring.web.resources.chain.cache = false
  spring.web.error.include-binding-errors: always · from: devtools
  spring.web.error.include-message: always · from: devtools
  spring.web.error.include-stacktrace: always · from: devtools
  spring.mvc.log-resolved-exception: true · from: devtools
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19437/customers/Nobody
  {"timestamp":"…","status":404,"error":"Not Found","trace":"…","message":"no customer named Nobody","path":"/customers/Nobody"} 404 · Content-Type: [application/json] · WARN lines it added: 1 · ERROR lines: 0
    its "trace", cut above: its first line: org.springframework.web.server.ResponseStatusException: 404 NOT_FOUND "no customer named Nobody" · its frames (\tat): 46 · its other lines: 0 - none shown
    WARN .w.s.m.a.ResponseStatusExceptionResolver: Resolved [org.springframework.web.server.ResponseStatusException: 404 NOT_FOUND "no customer named Nobody"]
      its stack frames: 0, its other lines: 0 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19437/probe/boom
  {"timestamp":"…","status":500,"error":"Internal Server Error","trace":"…","message":"the kitchen is on fire","path":"/probe/boom"} 500 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 1
    its "trace", cut above: its first line: java.lang.IllegalStateException: the kitchen is on fire · its frames (\tat): 44 · its other lines: 0 - none shown
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen is on fire] with root cause
      java.lang.IllegalStateException: the kitchen is on fire
      its stack frames: over 40, its other lines: 2 - none shown
$ curl -s -w ' %{http_code}\n' -H "X-Order-Note: $NOTE" http://127.0.0.1:19437/probe/boom-note
  {"timestamp":"…","status":500,"error":"Internal Server Error","trace":"…","message":"the kitchen could not read the note [masked: the 26-character canary]","path":"/probe/boom-note"} 500 · WARN lines it added: 0 · ERROR lines: 1
    its "trace", cut above: its first line: java.lang.IllegalStateException: the kitchen could not read the note [masked: the 26-character canary] · its frames (\tat): 44 · its other lines: 0 - none shown
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen could not read the note [masked: the 26-character canary]] with root cause
      java.lang.IllegalStateException: the kitchen could not read the note [masked: the 26-character canary]
      its stack frames: over 40, its other lines: 2 - none shown
  the canary ($NOTE) in this answer: 2 times · in the lines the log gained for it: 2 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 2
$ harness/shutdown.sh 19437 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 1 · listening on 19437 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the same with restart disabled (this unit's line), port 19438:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -Dspring.devtools.restart.enabled=false -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc:$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19438 --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Who,probe.web.Boom
  listens on: 127.0.0.1:19438 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19438/actuator/health/readiness
  {"status":"UP"} 200
  DevTools' line before logging starts:
    INFO org.springframework.boot.devtools.restart.RestartApplicationListener -- Restart disabled due to System property 'spring.devtools.restart.enabled' being set to false ×1
  Boot's DevTools lines in the log (logger: message):
    .e.DevToolsPropertyDefaultsPostProcessor: For additional web related logging consider setting the 'logging.level.web' property to 'DEBUG'
  listening on 35729 (Live Reload's port) now: 0
$ curl -s http://127.0.0.1:19438/probe/who/devtools
  the property source named devtools: none
  spring.web.error.include-binding-errors: not set · from: none
  spring.web.error.include-message: not set · from: none
  spring.web.error.include-stacktrace: not set · from: none
  spring.mvc.log-resolved-exception: not set · from: none
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19438/customers/Nobody
  {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Nobody"} 404 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19438/probe/boom
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/boom"} 500 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen is on fire] with root cause
      java.lang.IllegalStateException: the kitchen is on fire
      its stack frames: over 40, its other lines: 2 - none shown
$ curl -s -w ' %{http_code}\n' -H "X-Order-Note: $NOTE" http://127.0.0.1:19438/probe/boom-note
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/boom-note"} 500 · WARN lines it added: 0 · ERROR lines: 1
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen could not read the note [masked: the 26-character canary]] with root cause
      java.lang.IllegalStateException: the kitchen could not read the note [masked: the 26-character canary]
      its stack frames: over 40, its other lines: 2 - none shown
  the canary ($NOTE) in this answer: 0 times · in the lines the log gained for it: 2 times
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 2
$ harness/shutdown.sh 19438 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19438 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 7 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s six lines, then `exercise/solution/SOLUTION.md`'s three, read from the files and run as written in ONE `env -i`
`/bin/bash --noprofile --norc` shell started in this folder (S3.4, R.93). The README's request asks with `Accept: text/html` → `status: 404 ·
Content-Type: text/html;charset=UTF-8`, the saved answer Boot's Whitelabel page; the solution's last line is the README's with that header
made `application/json` (asserted; it changes no file, so a second run gives the same line) → `status: 404 · Content-Type: application/json`,
Boot's four keys. Each leaves the shell in this folder, 0 copies of the copy's token in its log, 19439 free.

`.r-exercise.out` · md5 `c156036038dee6a4bc41d58180107c4a` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 6 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/
  $ mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/anchor && rm -f ../got.txt && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19439 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19439/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o ../got.txt -w '%{http_code} · Content-Type: %{content_type}' -H 'Accept: text/html' http://127.0.0.1:19439/customers/Nobody); ../../../harness/shutdown.sh 19439 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "status: $s")
  exit 0 · what they printed:
    status: 404 · Content-Type: text/html;charset=UTF-8
  the answer it saved (../got.txt), through this script's answer filter:
    the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Not Found, status=404). · its created date: masked · its paragraphs: 1, not shown · then curl's:
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19439 now: 0
the solution's 3 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ M="$PWD/.m2-demo" && (cd .harness/mine/anchor && rm -f ../got.txt && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19439 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19439/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o ../got.txt -w '%{http_code} · Content-Type: %{content_type}' -H 'Accept: application/json' http://127.0.0.1:19439/customers/Nobody); ../../../harness/shutdown.sh 19439 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "status: $s")
  exit 0 · what they printed:
    status: 404 · Content-Type: application/json
  the answer it saved (../got.txt), through this script's answer filter:
    {"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Nobody"}
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19439 now: 0
```

## Exercise

**Your turn:** the README's request gets an HTML page, not JSON. Read its Content-Type, change one header, and read the Content-Type again.
`exercise/README.md` has the commands (copy the anchor, give the copy a token of its own); its last line, in a subshell, builds the copy
offline, starts it on 19439, asks for a customer nobody has with `Accept: text/html`, stops it, waits for its JVM and prints — as shipped —
`status: 404 · Content-Type: text/html;charset=UTF-8`. Done is `status: 404 · Content-Type: application/json`. Measured answer:
`exercise/solution/SOLUTION.md` (the README's two `export` lines, then its last line with one header changed), run in the same shell. Run
`./receipts.sh` once first on a fresh clone. **As viewers run it, beyond the capture:** README then SOLUTION, then SOLUTION again, in one `env -i` `zsh -f` shell → `status: 404 · Content-Type: text/html;charset=UTF-8`, then `… application/json` twice, each exit 0, the shell left in `c6-unit14/`, the copy's token 0 times in its log; SOLUTION alone in an `env -i` `/bin/bash` shell whose `java` is 23.0.1 → `status: 404 · Content-Type: application/json` (its exports first), exit 0; 19439 free after each.

## The ledger rows and hand-offs this unit pays

- **C6-8** ("the 404 page → Boot's Default Error Response"): `/nowhere` read both ways — Boot's four keys to `*/*` (`shapes`) and the
  Whitelabel page to `text/html` (`html`) — and who writes it: Tomcat's error dispatch to `BasicErrorController` (`path`). **Paid.**
- **C6-18** (DevTools' "six of the seven defaults are for a web layer … error pages, templates, static resources: Course 6"): error pages
  paid by name and effect (`devtools`: the three error keys and `log-resolved-exception`, the trace, the WARN, the canary; restart's role
  measured); templates → *Serving HTML: Thymeleaf*, static resources → *Static Resources and Cache Headers* (unchanged owners, named); the
  session key → *Sessions, Cookies and Flash Attributes* (a note for its brief).
- **H-01** (who sends it back: the container — measured, `path`), **H-07** (Boot's body names no reason — `shapes`, `reasons`), **H-08**
  (one WARN each — `reasons`, agreed), **H-11** (`html`), **H-12** (cited), **H-13** (13's up-next names this title). None makes a live video
  false; no correction comment.

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-17) |
|---|---|---|---|
| 1 | The catalogue's answers, Whitelabel by Accept, every WARN/ERROR count, on 14's own harness | the probe's step 1 | **15 requests, 14 errors, 5 shapes; 7 WARN (DHER), 0 for the 404s, 1 ERROR (Tomcat's); Whitelabel 13 of 15, 4 → 406, 10 WARN** (`shapes`, `reasons`, `html`) |
| 12 | 44 frames, 9 DevTools keys, the canary counts | the probe's token-echo route | **44 frames (C and DevTools' 500), 46 for DevTools' 404; 9 keys; the canary 0 / 1 / 1 / 2 / 0 in the answer (A, B, C, DevTools, restart off), 2 in the log every time** (`message`, `devtools`) |
| 13 | the exercise as viewers run it | end state on a sketch | **one `env -i` shell: `text/html`, then `application/json`, both 404** (`exercise`) |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **Five shapes, not six** (brief READ FIRST 2, the unit block's `shapes`): the empty 406 and the empty 409 are the same body shape — none, no
  `Content-Type`, `Content-Length: 0` (the 406 adds an `Accept` header naming what it could have sent) — so the capture's own count, by
  Content-Type and keys, is five. The voice says "no body at all for the
  four oh six and the four oh nine".
- **The method's field map has four fields** on this tree's refused body (the anchor README's own body breaks four rules: `mealType`,
  `mealsPerDay`, `name`, `pricePerMeal`), where the probe's had three.
- **A client that asks for HTML alone is told 406 for a POST that stored a customer** (not in the brief): Lata's 201 under
  `Accept: text/html` became a Whitelabel 406, and the same POST again answered 409. Spoken. A browser's whole header is not that client:
  `html`'s C, Chrome's header → Ravi 200 JSON (RED A #128).
- **Under `text/html` the 406 is a Whitelabel 406** (Ravi asked for as HTML), while the XML 406 stays empty (`shapes`): both measured; the brief's
  "the 406 still empty" holds for its own XML request.
- **DevTools' 404 trace is 46 frames**, its 500's 44 (the brief's 44 for the 500, re-counted: holds).
- **`include-stacktrace` alone puts the canary in the answer once** (the trace's first line carries the message), as the probe found.

## Found on the way

- **Every new check fails on a planted fault first** (R.65): the checks block runs alone, under /bin/bash 3.2, on copies of the published
  captures with one thing changed per plant (`plants.py`, this unit's scratch folder) — **33 plants, 33 stops under /bin/bash 3.2 and 33 under bash 5.3**, each naming its own check; the unplanted
  copy passes. Among them: a capture holding the token, a raw count above 0, an unmasked timestamp, an absolute path, a whole HTML page, an
  unpinned java line, a DevTools line with Live Reload on, a URL that is not loopback, a bare `wait` in SOLUTION.md, Boot 3's error key in this
  README; the rest change one line of a capture each.
- **Two filters fail on planted inputs inside the script itself**, before any capture: the answer filter (a Whitelabel page, Tomcat's page,
  a page of another shape, a trace with a `Caused by`, an empty answer, an epoch timestamp) and the record filter (a WARN with 45 frames, an
  ERROR with 3). Their first runs stopped the script on the planted inputs: the expected character counts had been typed, not counted (80 and
  25, re-counted by hand), a blank line after a trace is one of its "other lines", and the trace's frames were counted on its escaped text
  until the JSON string was decoded.
- **Two derivations failed under /bin/bash 3.2 alone**, on quotes inside `${x/pattern/replacement}` (a `\$M2` in the pattern; single quotes
  in the replacement): bash 5.3 accepted them. Those two derivations are now made by `python3`, the same under both bashes.
- **The probe's sketch and this tree agree** (brief READ FIRST 2-5; S3 notes Steps 1-2): Boot's one body for every Spring MVC error, the
  reason in one WARN or nowhere, Whitelabel for HTML, include-message's leak, DevTools' nine keys and their dependence on restart, exit 1 —
  each now a line of this unit's own captures.

## For unit 15 — and RED

- This unit reads `../c6-unit12/after` only; the next lesson's tree (`../c6-unit15/after` = `c6-tiffinbox`) opens on this unit's `shapes` line 8:
  `/customers/Nobody` → `{"timestamp":"…","status":404,"error":"Not Found","path":"/customers/Nobody"} 404`, 0 WARN — consistent with its
  slide 1.
- **For RED:** re-run under both bashes, the sealed clone, SIGINT during a capture's JVM; check the canary counts (they are raw counts of a
  per-run value — any run reproduces them), the Whitelabel date mask, every WARN/ERROR count and its logger, and that "five shapes" is the
  capture's own count.
