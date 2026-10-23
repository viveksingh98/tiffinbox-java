# c6-unit21 — SSE and Streaming Responses

Course 6 · Spring Web MVC · Section 4 (The Rest of MVC), its fourth unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot
4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5), curl 8.7.1, 2026-10-22. A normal answer is one reply and done; a feed is
a reply that keeps coming. This unit hands curl a stream of **server-sent events** from TiffinBox — an **emitter** on the server, a
`text/event-stream` on the wire — reads the wire format as it arrives (curl's `-N`), prints who runs on which thread and which dispatch,
and finds out what ends a stream: its last event, a timeout with nothing sent (read three ways, never timed), a timeout mid-stream, and a
reader that leaves.

**No anchor change (brief ⚑2).** `anchor` is the link to `../c6-unit16/after` — the problem-detail lesson's frozen tree, `c6-tiffinbox` at
Section 3's end (`diff -rq -x target c6-tiffinbox c6-unit16/after` empty on 2026-10-22) — read and copied under `.harness/anchor`, never
built in place; this unit freezes no `after/` and touches no other unit's folder. Everything new is **the course's harness**, never
TiffinBox's — `harness/probe/web`, outside `com.tiffinbox`, compiled with `-parameters` against the anchor's own jar and joined by
`--spring.main.sources` on the extracted jar's class path:

- `Feed` — a `@RestController`: `GET /probe/feed?orders=N` (`produces = text/event-stream`) returns an `SseEmitter` with **no timeout of
  its own**. TiffinBox emits no events — its kitchen cooks once, at start — so **the cadence is the harness's**: a platform thread,
  `kitchen-clock` (a daemon), sends one event every 200 ms, walking **TiffinBox's own customers** (`CustomerRepository.findAll()`, injected)
  in the anchor's order, each event `id:<n>` / `event:order` / `data:{"order":n,"customer":…,"mealsPerDay":…,"kitchenCooked":…}` — the last
  read from **TiffinBox's own `OrderQueue`** (`cooked()`, injected) at the moment of the send. `orders=0`: no event and no clock;
  `orders=-1`: endless. **Every callback — `onTimeout`, `onError`, `onCompletion` — stops the clock** and prints its state; a send that
  fails stops it too and keeps its exception, which `onError` prints beside the container's own (one line, so two threads never race
  for the order). An endless feed prints its first send only: how many follow is timing (R.121).
- `Timeouts` — at start, `spring.mvc.async.request-timeout` as Spring's environment holds it and **Tomcat's connector's async timeout**
  (`TomcatWebServer.getTomcat().getConnector().getAsyncTimeout()`); and a filter on `/probe/feed`, REQUEST dispatch only, that prints, as
  the dispatch leaves, **the request's own async context's timeout**. A timeout here is read, never timed (⚑11).
- `OnceAsync` — a `OncePerRequestFilter` bean whose `shouldNotFilterAsyncDispatch()` answers `false` (`dispatch` C).
- The filters lesson's `Trace`, `Hooks`, `Interceptor`, `PlainFilter`, `OnceFilter`, `EveryFilter`, `EveryRegistration`, `ProbeOops` — **byte
  for byte** (checked with `cmp` against `../c6-unit18/harness/probe/web/`), so the hooks that lesson measured are the hooks that run here.
- `harness/keys.py` — reads a jar's `META-INF/spring-configuration-metadata.json` (the upload lesson's, byte for byte);
  `harness/shutdown.sh` — POST `/shutdown` with the token read from its file (the filters lesson's, byte for byte).
- `exercise/KitchenFeed.java` — the exercise's feed (`GET /kitchen/feed?orders=N`); the solution is one variable, so `exercise/solution/`
  holds only `SOLUTION.md`.

No native build (the binary's SSE — 3 events and the 503 — was measured on the probe's sketch; CARRIED to the capstone, brief ⚑2 loser A),
no Docker and no browser: curl is the consumer (the roadmap's), so nothing here says "a browser" (R.115).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 6 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top; a bare `java` on this Mac is 23.0.1.) It **dies** when a capture's md5 differs
from `receipts.md5` (it prints the `DIFFERS` line first). **Start it in a process group of its own** (a terminal's foreground job is one):
two receipts started as background jobs of one shell share a group, and one run's clean-up would stop the other's JVMs (R.94). A run
takes several minutes: `timeout` A and A′ each wait for Tomcat's own async timeout, three times.

**Runs of record (2026-10-23, BLUE S4 part 1, this script as committed):** **503 s under `./receipts.sh`** (/bin/bash 3.2.57, `env -i` with
HOME and a plain PATH, this folder, a session of its own: exit 0, all 6 captures 3/3 = published, every check passed) and **496 s under
`bash receipts.sh`** (Homebrew bash 5.3.9, the same: exit 0, all 6 = published). **How the hashes were made:** one development run (bash
3.2, 579 s, each capture 3/3) fixed `timeout` (D: curl bounded to ten seconds, RED S4 #350) and `gone` (the OS's words masked, RED S4 #349);
it stopped only at the exercise card's spoken line, which this change rewrote (RED S4 #353) and the check now reads; `events`, `dispatch`,
`committed` and `exercise` reproduced their earlier hashes unchanged. **The sealed fresh clone** of 2026-10-22 (at 66732c9, 479 s) followed
the earlier text of the recipe, which RED S4 #405 measured to leak as written, so its "every one from the `file://` copy" is not a proof from
that text. It was **not re-run** for this change: only captures changed (no dependency, plugin or build step), which a sealed clone cannot
tell from a seeded run. The fixed recipe below was measured once, on c6-unit18 (its README gives the counts).

Published hashes: events `fefc45b7cf4d0a953f024275e3538257` · dispatch `13a32aafa14472a7c6861338c8dc21e9` · timeout `80887a7c60587e5821342829afd6843a` · committed `1695bed65367ebb06913c524e09de0a4` · gone `23c7d84808f566705fd4641a0100882f` · exercise `f07806ddfb8c7534938d84014a6c0426`.

### A sealed fresh clone — the recipe (RED S4 #405)

A sealed clone proves that a fresh clone's first build fetches only from a copy you control. **The earlier text of this paragraph did not
seal** (RED S4 #405, measured): a `HOME` of its own whose `.mavenrc` set only `-Dhttp(s).proxyHost`, with Maven settings in `$HOME/.m2`,
fetched from Maven Central — Java on macOS ignores `$HOME` (`user.home` stays your own folder, so Maven never read those settings), and
Maven's resolver ignores the `-Dhttp.proxyHost` properties (it takes its proxies from `settings.xml`). The recipe that seals, step by step,
with a pre-flight that refuses to start unless the only remote is `file://` and a post-check of where every artifact came from:

```bash
S=/tmp/sealed-21                                   # an empty folder of your own; T = your tiffinbox-java clone
mkdir -p "$S/home/.m2" && git clone -q "file://$T" "$S/tiffinbox-java"
rsync -a --exclude _remote.repositories --exclude '*.lastUpdated' --exclude resolver-status.properties "$T/c6-unit21/.m2-demo/" "$S/central/"
printf 'MAVEN_OPTS="-Duser.home=%s"\n' "$S/home" > "$S/home/.mavenrc"     # mvn reads $HOME/.mavenrc; Java then reads this user.home
cat > "$S/home/.m2/settings.xml" <<XML
<settings>
  <mirrors><mirror><id>sealed</id><mirrorOf>*</mirrorOf><url>file://$S/central</url></mirror></mirrors>
  <proxies>
    <proxy><id>dead-http</id><active>true</active><protocol>http</protocol><host>127.0.0.1</host><port>9</port></proxy>
    <proxy><id>dead-https</id><active>true</active><protocol>https</protocol><host>127.0.0.1</host><port>9</port></proxy>
  </proxies>
</settings>
XML
X=http://127.0.0.1:9; E="env -i HOME=$S/home PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin http_proxy=$X https_proxy=$X HTTP_PROXY=$X HTTPS_PROXY=$X no_proxy=127.0.0.1,localhost NO_PROXY=127.0.0.1,localhost"
# pre-flight: an artifact that exists nowhere, asked for through the sealed settings - it must fail, having asked file:// and nothing else
$E JAVA_HOME=/opt/homebrew/opt/openjdk@25 mvn -B -Dmaven.repo.local="$S/preflight-m2" org.apache.maven.plugins:maven-dependency-plugin:3.8.1:get -Dartifact=org.example.sealed:absent:1 > "$S/preflight.log" 2>&1
[ $? != 0 ] && grep -q 'Downloading from sealed: file://' "$S/preflight.log" && ! grep -qE 'Downloading from [^ ]+: https?://' "$S/preflight.log" && echo "sealed: file:// only" || echo "NOT SEALED - do not run receipts.sh"
cd "$S/tiffinbox-java/c6-unit21" && $E ./receipts.sh            # a process group of its own (a terminal's foreground job is one)
# post-check: every artifact's origin, by repository id - each line must say sealed; 0 central
find .m2-demo -name _remote.repositories -exec cat {} + | grep -o '>[^=]*=' | sort | uniq -c
```

## The commands this unit adds

`anchor/README.md` — the anchor's own — gives every line `receipts.sh` runs or derives from (`mvn -B package`, the run line, the extract
line, the class-path line, the readiness line, the Content-Type line) but these ten, which are this unit's, each read from the block below
and asserted to be exactly this (on the anchor's port 18431; each capture swaps in its own port):

```bash
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.mvc.async.request-timeout=2s
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/probe/web/EveryFilter.java harness/probe/web/EveryRegistration.java harness/probe/web/Feed.java harness/probe/web/Hooks.java harness/probe/web/Interceptor.java harness/probe/web/OnceAsync.java harness/probe/web/OnceFilter.java harness/probe/web/PlainFilter.java harness/probe/web/ProbeOops.java harness/probe/web/Timeouts.java harness/probe/web/Trace.java
python3 harness/keys.py .harness/anchor/tiffinbox-web/target/extracted/lib/spring-boot-webmvc-4.1.1.jar spring.mvc.async.
javap -cp .harness/anchor/tiffinbox-web/target/extracted/lib/spring-boot-webmvc-4.1.1.jar org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler
unzip -p .harness/anchor/tiffinbox-web/target/extracted/lib/spring-webmvc-7.0.9.jar org/springframework/web/servlet/mvc/method/annotation/ResponseEntityExceptionHandler.class | grep -ac 'Response already committed. Ignoring'
curl --help all | grep -e '--no-buffer'
curl -s -N -D - 'http://127.0.0.1:18431/probe/feed?orders=3'
curl -s -N -D .harness/head.txt -o .harness/body.txt -w ' %{http_code} · Content-Type: [%{content_type}]\n' --max-time 60 'http://127.0.0.1:18431/probe/feed?orders=0'
```

The first two are the anchor's run line and its class-path line with `-Duser.language=en -Duser.country=US` after `java` — asserted — and
every java line a capture starts takes the same two options in the same place (`at()`; a last check refuses any capture's java line without
them, and the exercise's). The third is the pinned class-path line with Boot's timeout key for Spring MVC as an option (`timeout` B, `committed`).
The javac line compiles the harness's eleven files and nothing else. The metadata line reads the anchor's own `spring-boot-webmvc` jar; the
`javap` line prints Boot's handler's class line; the `unzip | grep -ac` line counts the WARN's sentence in Spring MVC's
`ResponseEntityExceptionHandler` class. The help line is curl's own word for `-N`. The stream line is curl reading the feed as it arrives,
the headers first (`-D -`, `sq()` swaps the port). The saved-answer line is the anchor's Content-Type line with `-N`, `-D` and `-o`
(headers and body to files, both removed before each request — R.119), a bound on curl's time and the feed (`gq()` swaps the port, the
number of orders and the bound: `--max-time 2` is `gone`'s, `--max-time 10` is `timeout` D's); each derivation is asserted.

## The repository, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from `../../spring-web-mvc/_research/m2-seed-s4/`
alone — 5,890 files (the seed's 5,891 less Finder's `.DS_Store`; the S3 seed + the Thymeleaf 54, which this unit does not use), no
`com/tiffinbox`. **Nothing was downloaded** for this unit: every build said `offline: yes`, and `.m2-demo` held 5,890 files after every
run. A fresh clone's `.m2-demo` is empty (git ignores it): the first build — `.harness/pre`, before any capture — fills it from Maven
Central and says `offline: no`. **At run time** every request goes to `127.0.0.1`, and nothing binds 8080, 18425 or 35729.

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 31 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/anchor/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) when the script runs, and sent only by `../c5-unit11/curlset.sh` and `harness/shutdown.sh` on curl's standard input. Every
capture's raw output is searched for it before masking (0 in all of them), and so are the log of every JVM that served, and every file this
unit ships: 0 everywhere. The header's name, `X-Shutdown-Token`, is counted too: 0 in every log. No capture sends a secret toward an answer,
so this unit plants no canary. The exercise makes a token of its own (`openssl rand -hex 13`), counted 0 times in its own log, never printed.

## The locale — pinned per JVM, printed, asserted

Every java line this script starts carries `-Duser.language=en -Duser.country=US` before `-jar` or `-cp` (S4.1, R.100), and every harness
JVM prints its locale (`Feed`; the exercise's `KitchenFeed`) — `en_US`, asserted in every capture that starts one (S4.23). Receipts run under
bash (`#!/bin/bash`), never zsh, where the two options would arrive as one word (brief READ FIRST 13). The harness's own lines are ASCII.

## The folders, the names and the ports

- `.harness/pre` — the anchor built before any capture; `.harness/anchor` — the anchor, copied, with a config tree, built and extracted
  (`events`); `.harness/hc` — the harness's classes; `.harness/sse.txt` — what the stream line printed; `.harness/head.txt`,
  `.harness/body.txt` — what the saved-answer line saved; `.harness/seven-19500.txt` — the seven's answers, the anchor's data every event
  is judged against; `.harness/mine` — the exercise's copy.
- **Ports** (brief ⚑1, 19500-19509): `events` — the seven 19500, the feed 19501 · `dispatch` 19502, C 19503 · `timeout` — A and A′ 19504,
  B 19505 · `committed` 19506 · `gone` 19507 · the exercise 19509 (19508 unused). Captures run one after another, each JVM stopped (and its
  port checked free) before the next starts. All ten, 18425, 8080 and 35729 are checked free first; a run that listens on 8080 or 35729 is
  killed and the script dies. A JVM with an open stream is stopped by POST /shutdown after its stream has ended, and its pid is waited for
  and asserted gone (the clock is a daemon thread, so it never holds the JVM: R.79).

## Masks, filters and hygiene — every one, declared

1. **Paths, the token, the user** (`gsub()`, literals escaped), in every line: the demo token → `[masked: the 31-character token]`; this
   folder → `…`; the folder above → `…/..`; home → `~`; the user name, as a whole word → `<user>`; a generated class's number →
   `$$SpringCGLIB$$<n>`. A last check fails if any capture holds `/Users/`, `/private/`, `/home/`, `/var/folders/`, a unit number, Boot's
   process line, a log time, an unmasked timestamp, a date, a thread number, a stack frame, a whole HTML page, `:8080` or `:35729`, a
   carriage return, a duration, a count of an endless stream's events, or a command with a URL that is not `127.0.0.1`'s.
   **The OS's words** (RED S4 #349): in any line, `java.io.IOException: <message>` → `java.io.IOException: <the OS's words>` (up to the
   harness's next ` - `); the raw message is asserted to be there and printed on the terminal, never in a capture.
2. **Spring's error timestamp** (`tsmask`): `"timestamp":"<anything>"` → `"timestamp":"…"`, both forms, in every answer printed and in the
   seven (problem details here: the mask runs, and the seven print its count, 0).
3. **What curl printed** (`strm`, the stream line): every line as it came, its carriage return and trailing space dropped, `Date`'s value →
   `…`, counted, each after a `|` (a blank line is `|` alone). **Headers curl saved** (`hdrs`): the same, counted, then whether a
   `Content-Length` and a `Transfer-Encoding` came. **A body curl saved**: a problem detail whole (`answer`); a stream judged by `evs` —
   every event whole (`id:`, `event:order`, `data:`, a blank line), the ids from 1 in order, each event's customer the next in the anchor's
   own list with its meals a day, its kitchen count the anchor's (both read from the seven's `GET /customers` and `GET /kitchen`), whether
   the last line is blank — then, for a bounded stream, how many and every line; for an endless one, **never how many** (timing, R.121) and
   its first event only. Each filter is checked on planted inputs first (a stream out of order, with a stranger, with a wrong count, cut
   inside an event).
4. **Log lines** (`logl`, `recs`): from their logger on, as the log prints the logger — `o.s.web.servlet.PageNotFound` is **Spring MVC's**
   (the seven's 405); `o.s.b.w.a.ProblemDetailsExceptionHandler` is **Boot's** class
   (`org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler`, read off its jar by `javap`), which extends **Spring
   MVC's** `ResponseEntityExceptionHandler`, whose bytes hold the sentence "Response already committed. Ignoring" (counted: 1). Boot's first
   line is cut before ` with PID`. Every request ends its answer's line with `· WARN lines it added: N · ERROR lines: M` — **counted by the
   log's own line shape** (`<ISO date> LEVEL <pid> --- [`), never a bare `' ERROR '`, which the harness's own lines could satisfy (R.120;
   checked on a planted log first: a harness line that says ERROR and one record give 1, where a bare count gives 2).
5. **Harness lines** (`hk`): printed after each request — after the stream's `onCompletion` has printed (`done_`, waited for, bounded) — in
   the order they printed, numbered from 1, the JVM's running number checked to rise (a planted falling number stops the run) and never
   shown; a thread's own number is `<n>` (the harness prints it so).
6. **A′ against A** (`asame`): A's block and A′'s, their labels aside, compared line for line in the capture itself ("yes").
7. **No duration** anywhere: the timeouts are values read (the environment, the connector, the request's async context), never a clock;
   curl's `--max-time` bounds a run, and only its exit code is printed.
8. **On this Mac**: `lsof` by pid (or by port), the address column alone — never a command name (R.18).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`, and the exercise's
shell `$xpid` with every process under it — `killtree`), sweeps its own process group for any TiffinBox JVM or Maven left, deletes the
capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched. No `wait` in the script, its
checks or the exercise is bare: each names its pid (R.105; a check refuses a bare one). See "Found on the way" for the measured interrupt.

## 1 · events — the stream, as it came

The anchor built offline and extracted; the harness compiled; the seven on a fresh JVM of the jar (`466c20ed…`, unchanged since the problem-detail lesson, 1 WARN `PageNotFound`); the anchor's own data as the seven read it (four customers in order, `ordersCooked` 120). curl's own help for `-N`. Then `Feed` joined, and `curl -s -N -D -`: `200`, `Content-Type: text/event-stream`, `Transfer-Encoding: chunked`, then three events in the wire form — `id:`, `event:`, `data:`, a blank line — Meera, Priya, Ravi, each with the kitchen's 120; curl exit 0 when the emitter completes. The handler returned before the first send, on Tomcat's request thread; the sends ran on `kitchen-clock`.

`.r-events.out` · md5 `fefc45b7cf4d0a953f024275e3538257` · 3 of 3

```
the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline), its jar extracted (the README's line):
$ cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the anchor · offline: yes · exit 0
$ cd .harness/anchor && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
the harness, compiled against the anchor's own jar - with -parameters (this unit's line):
$ javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/probe/web/EveryFilter.java harness/probe/web/EveryRegistration.java harness/probe/web/Feed.java harness/probe/web/Hooks.java harness/probe/web/Interceptor.java harness/probe/web/OnceAsync.java harness/probe/web/OnceFilter.java harness/probe/web/PlainFilter.java harness/probe/web/ProbeOops.java harness/probe/web/Timeouts.java harness/probe/web/Trace.java
  exit 0 · its classes: probe/web/EveryFilter.class probe/web/EveryRegistration.class probe/web/Feed.class probe/web/Hooks.class probe/web/Interceptor.class probe/web/OnceAsync.class probe/web/OnceFilter.class probe/web/PlainFilter.class probe/web/ProbeOops.class probe/web/Timeouts$Leaving.class probe/web/Timeouts.class probe/web/Trace.class
the seven - the anchor, the README's run line (its locale pinned), port 19500, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19500
  listens on: 127.0.0.1:19500 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19500/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19500 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
the anchor's own data, as the seven read it (.harness/seven-19500.txt):
  GET /customers, in its order: Meera (1 a day) Priya (1 a day) Ravi (2 a day) Sunil (3 a day)
  GET /kitchen: ordersCooked 120
curl's own help for -N (this unit's line):
$ curl --help all | grep -e '--no-buffer'
  -N, --no-buffer Disable buffering of the output stream
the feed - the anchor on its class path, the harness joined (Feed), port 19501: three events, read as they came (this unit's line):
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19501 --spring.main.sources=probe.web.Feed
  listens on: 127.0.0.1:19501 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19501/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Feed): en_US
$ curl -s -N -D - 'http://127.0.0.1:19501/probe/feed?orders=3'
  curl's exit code: 0 · what it wrote to its error stream: 0 bytes · WARN lines it added: 0 · ERROR lines: 0
  what curl printed, as it came: 17 lines, the headers first (each line's carriage return and trailing space dropped, Date's value masked):
    | HTTP/1.1 200
    | Content-Type: text/event-stream
    | Transfer-Encoding: chunked
    | Date: …
    |
    | id:1
    | event:order
    | data:{"order":1,"customer":"Meera","mealsPerDay":1,"kitchenCooked":120}
    |
    | id:2
    | event:order
    | data:{"order":2,"customer":"Priya","mealsPerDay":1,"kitchenCooked":120}
    |
    | id:3
    | event:order
    | data:{"order":3,"customer":"Ravi","mealsPerDay":2,"kitchenCooked":120}
    |
  the stream, after the headers: 3 events · every one whole (id, event, data, then a blank line), the ids from 1 in order, each event's customer the next in the anchor's list with the anchor's meals a day, its kitchen count the anchor's: yes · the last line blank: yes
  the harness's lines it printed, in order: 5
     1 Feed            the handler returns the emitter, nothing sent yet, on tomcat-handler-<n> (virtual: true) - orders asked: 3
     2 Feed            sent event 1 (Meera) on kitchen-clock (virtual: false)
     3 Feed            sent event 2 (Priya) on kitchen-clock (virtual: false)
     4 Feed            sent event 3 (Ravi) on kitchen-clock (virtual: false) - the last asked: complete()
     5 Feed            onCompletion on tomcat-handler-<n> (virtual: true) - the clock: stopped
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19501 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19501 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 2 · dispatch — who runs, on which dispatch; C labelled

The filters lesson's hooks joined. REQUEST: every filter in, `preHandle`, the handler returns the emitter, the filters out with 200 — no `postHandle`, no `afterCompletion`. Three sends on the clock's thread. Then the ASYNC dispatch: `EveryFilter` (registered for every dispatch type) and the interceptor's `preHandle` again, `postHandle` (committed true), `afterCompletion`; `PlainFilter` (a REQUEST-only filter bean) and `OnceFilter` (a `OncePerRequestFilter`) never see it. C (labelled): `OnceAsync` — the skip turned off — runs on the ASYNC dispatch too.

`.r-dispatch.out` · md5 `13a32aafa14472a7c6861338c8dc21e9` · 3 of 3

```
the hooks - the anchor on its class path, the harness joined (Feed and the filters lesson's Hooks, PlainFilter, OnceFilter, EveryRegistration), port 19502: the same three events:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19502 --spring.main.sources=probe.web.Feed,probe.web.Hooks,probe.web.PlainFilter,probe.web.OnceFilter,probe.web.EveryRegistration
  listens on: 127.0.0.1:19502 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19502/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Feed): en_US
$ curl -s -N -D .harness/head.txt -o .harness/body.txt -w ' %{http_code} · Content-Type: [%{content_type}]\n' --max-time 60 'http://127.0.0.1:19502/probe/feed?orders=3'
  curl's line: 200 · Content-Type: [text/event-stream] · curl's exit code: 0 · WARN lines it added: 0 · ERROR lines: 0
  the headers curl saved, as they came: 4 lines, the status line first (Date's value masked):
    HTTP/1.1 200
    Content-Type: text/event-stream
    Transfer-Encoding: chunked
    Date: …
  Content-Length: none · Transfer-Encoding: chunked
  the body curl saved: 3 events · every one whole (id, event, data, then a blank line), the ids from 1 in order, each event's customer the next in the anchor's list with the anchor's meals a day, its kitchen count the anchor's: yes · the last line blank: yes
    | id:1
    | event:order
    | data:{"order":1,"customer":"Meera","mealsPerDay":1,"kitchenCooked":120}
    |
    | id:2
    | event:order
    | data:{"order":2,"customer":"Priya","mealsPerDay":1,"kitchenCooked":120}
    |
    | id:3
    | event:order
    | data:{"order":3,"customer":"Ravi","mealsPerDay":2,"kitchenCooked":120}
    |
  the harness's lines it printed, in order: 17
     1 EveryFilter     in  REQUEST /probe/feed
     2 PlainFilter     in  REQUEST /probe/feed
     3 OnceFilter      in  REQUEST /probe/feed
     4 Interceptor     preHandle       REQUEST /probe/feed handler Feed#feed
     5 Feed            the handler returns the emitter, nothing sent yet, on tomcat-handler-<n> (virtual: true) - orders asked: 3
     6 OnceFilter      out REQUEST /probe/feed status 200
     7 PlainFilter     out REQUEST /probe/feed status 200
     8 EveryFilter     out REQUEST /probe/feed status 200
     9 Feed            sent event 1 (Meera) on kitchen-clock (virtual: false)
    10 Feed            sent event 2 (Priya) on kitchen-clock (virtual: false)
    11 Feed            sent event 3 (Ravi) on kitchen-clock (virtual: false) - the last asked: complete()
    12 EveryFilter     in  ASYNC /probe/feed
    13 Interceptor     preHandle       ASYNC /probe/feed handler Feed#feed
    14 Interceptor     postHandle      ASYNC /probe/feed status 200 committed true
    15 Interceptor     afterCompletion ASYNC /probe/feed status 200 exception none
    16 EveryFilter     out ASYNC /probe/feed status 200
    17 Feed            onCompletion on tomcat-handler-<n> (virtual: true) - the clock: stopped
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19502 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19502 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - the same, and OnceAsync beside them (a once-per-request filter that runs on the ASYNC dispatch), port 19503:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19503 --spring.main.sources=probe.web.Feed,probe.web.Hooks,probe.web.PlainFilter,probe.web.OnceFilter,probe.web.EveryRegistration,probe.web.OnceAsync
  listens on: 127.0.0.1:19503 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19503/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Feed): en_US
$ curl -s -N -D .harness/head.txt -o .harness/body.txt -w ' %{http_code} · Content-Type: [%{content_type}]\n' --max-time 60 'http://127.0.0.1:19503/probe/feed?orders=3'
  curl's line: 200 · Content-Type: [text/event-stream] · curl's exit code: 0 · WARN lines it added: 0 · ERROR lines: 0
  the headers curl saved, as they came: 4 lines, the status line first (Date's value masked):
    HTTP/1.1 200
    Content-Type: text/event-stream
    Transfer-Encoding: chunked
    Date: …
  Content-Length: none · Transfer-Encoding: chunked
  the body curl saved: 3 events · every one whole (id, event, data, then a blank line), the ids from 1 in order, each event's customer the next in the anchor's list with the anchor's meals a day, its kitchen count the anchor's: yes · the last line blank: yes
    | id:1
    | event:order
    | data:{"order":1,"customer":"Meera","mealsPerDay":1,"kitchenCooked":120}
    |
    | id:2
    | event:order
    | data:{"order":2,"customer":"Priya","mealsPerDay":1,"kitchenCooked":120}
    |
    | id:3
    | event:order
    | data:{"order":3,"customer":"Ravi","mealsPerDay":2,"kitchenCooked":120}
    |
  the harness's lines it printed, in order: 21
     1 EveryFilter     in  REQUEST /probe/feed
     2 PlainFilter     in  REQUEST /probe/feed
     3 OnceFilter      in  REQUEST /probe/feed
     4 OnceAsync       in  REQUEST /probe/feed
     5 Interceptor     preHandle       REQUEST /probe/feed handler Feed#feed
     6 Feed            the handler returns the emitter, nothing sent yet, on tomcat-handler-<n> (virtual: true) - orders asked: 3
     7 OnceAsync       out REQUEST /probe/feed status 200
     8 OnceFilter      out REQUEST /probe/feed status 200
     9 PlainFilter     out REQUEST /probe/feed status 200
    10 EveryFilter     out REQUEST /probe/feed status 200
    11 Feed            sent event 1 (Meera) on kitchen-clock (virtual: false)
    12 Feed            sent event 2 (Priya) on kitchen-clock (virtual: false)
    13 Feed            sent event 3 (Ravi) on kitchen-clock (virtual: false) - the last asked: complete()
    14 EveryFilter     in  ASYNC /probe/feed
    15 OnceAsync       in  ASYNC /probe/feed
    16 Interceptor     preHandle       ASYNC /probe/feed handler Feed#feed
    17 Interceptor     postHandle      ASYNC /probe/feed status 200 committed true
    18 Interceptor     afterCompletion ASYNC /probe/feed status 200 exception none
    19 OnceAsync       out ASYNC /probe/feed status 200
    20 EveryFilter     out ASYNC /probe/feed status 200
    21 Feed            onCompletion on tomcat-handler-<n> (virtual: true) - the clock: stopped
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19503 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19503 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 3 · timeout — nothing comes, A/B/A′

Boot's metadata for `spring.mvc.async.`: one key, `request-timeout`, no default. A: the key `null` in Spring's environment, Tomcat's connector's async timeout 30000 ms, the request's own async context 30000 ms; a feed asked for no events → `503 application/problem+json` `{"instance":"/probe/feed","status":503,"title":"Service Unavailable"}`, `Connection: close`, `onTimeout`, 0 WARN 0 ERROR. B (`--spring.mvc.async.request-timeout=2s`): the environment `2s`, the connector still 30000, the request's context 2000 ms — the same 503, byte for byte. A′ = A. **D (labelled) — the key by its effect, a bound and not a
clock** (RED S4 #350): the same request with curl bounded to ten seconds (`--max-time 10`). A's JVM, the key unset: `000`, curl's exit 28 —
curl gave up first, no status — and the server's own 30000 ms timeout comes later, to nobody (`onTimeout`, `onCompletion`, 0 WARN 0 ERROR;
`fq` waits for the stream's `onCompletion`, as for every stream: a wait, never timed). B's JVM, two seconds: the 503, inside the bound.
(`hdrs` now says so when curl wrote no header file, instead of failing on it.)

`.r-timeout.out` · md5 `80887a7c60587e5821342829afd6843a` · 3 of 3

```
the key - what Boot's own metadata declares under spring.mvc.async. (in spring-boot-webmvc-4.1.1.jar, from the anchor's extracted lib/; this unit's line):
$ python3 harness/keys.py .harness/anchor/tiffinbox-web/target/extracted/lib/spring-boot-webmvc-4.1.1.jar spring.mvc.async.
  spring.mvc.async.request-timeout · default none · Duration
  1 keys under spring.mvc.async.
A - the anchor on its class path, the harness joined (Feed, Timeouts), the key unset, port 19504: a feed asked for no events:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19504 --spring.main.sources=probe.web.Feed,probe.web.Timeouts
  listens on: 127.0.0.1:19504 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19504/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Feed): en_US
  the harness at start: Timeouts spring.mvc.async.request-timeout in Spring's environment: null - Tomcat's connector, its async timeout: 30000 ms
$ curl -s -N -D .harness/head.txt -o .harness/body.txt -w ' %{http_code} · Content-Type: [%{content_type}]\n' --max-time 60 'http://127.0.0.1:19504/probe/feed?orders=0'
  curl's line: 503 · Content-Type: [application/problem+json] · curl's exit code: 0 · WARN lines it added: 0 · ERROR lines: 0
  the headers curl saved, as they came: 5 lines, the status line first (Date's value masked):
    HTTP/1.1 503
    Content-Type: application/problem+json
    Transfer-Encoding: chunked
    Date: …
    Connection: close
  Content-Length: none · Transfer-Encoding: chunked
  the body curl saved, whole (0 newlines):
    | {"instance":"/probe/feed","status":503,"title":"Service Unavailable"}
  the harness's lines it printed, in order: 4
     1 Feed            the handler returns the emitter, nothing sent yet, on tomcat-handler-<n> (virtual: true) - orders asked: 0
     2 Timeouts        the REQUEST dispatch leaves; the request is async, its timeout: 30000 ms
     3 Feed            onTimeout on tomcat-handler-<n> (virtual: true) - the clock: none - no events were asked
     4 Feed            onCompletion on tomcat-handler-<n> (virtual: true) - the clock: none - no events were asked
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19504 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19504 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the same, the key at two seconds for this run (this unit's line: the key, as an option), port 19505:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19505 --spring.main.sources=probe.web.Feed,probe.web.Timeouts --spring.mvc.async.request-timeout=2s
  listens on: 127.0.0.1:19505 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19505/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Feed): en_US
  the harness at start: Timeouts spring.mvc.async.request-timeout in Spring's environment: 2s - Tomcat's connector, its async timeout: 30000 ms
$ curl -s -N -D .harness/head.txt -o .harness/body.txt -w ' %{http_code} · Content-Type: [%{content_type}]\n' --max-time 60 'http://127.0.0.1:19505/probe/feed?orders=0'
  curl's line: 503 · Content-Type: [application/problem+json] · curl's exit code: 0 · WARN lines it added: 0 · ERROR lines: 0
  the headers curl saved, as they came: 5 lines, the status line first (Date's value masked):
    HTTP/1.1 503
    Content-Type: application/problem+json
    Transfer-Encoding: chunked
    Date: …
    Connection: close
  Content-Length: none · Transfer-Encoding: chunked
  the body curl saved, whole (0 newlines):
    | {"instance":"/probe/feed","status":503,"title":"Service Unavailable"}
  the harness's lines it printed, in order: 4
     1 Feed            the handler returns the emitter, nothing sent yet, on tomcat-handler-<n> (virtual: true) - orders asked: 0
     2 Timeouts        the REQUEST dispatch leaves; the request is async, its timeout: 2000 ms
     3 Feed            onTimeout on tomcat-handler-<n> (virtual: true) - the clock: none - no events were asked
     4 Feed            onCompletion on tomcat-handler-<n> (virtual: true) - the clock: none - no events were asked
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19505 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19505 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, a fresh JVM, port 19504:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19504 --spring.main.sources=probe.web.Feed,probe.web.Timeouts
  listens on: 127.0.0.1:19504 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19504/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Feed): en_US
  the harness at start: Timeouts spring.mvc.async.request-timeout in Spring's environment: null - Tomcat's connector, its async timeout: 30000 ms
$ curl -s -N -D .harness/head.txt -o .harness/body.txt -w ' %{http_code} · Content-Type: [%{content_type}]\n' --max-time 60 'http://127.0.0.1:19504/probe/feed?orders=0'
  curl's line: 503 · Content-Type: [application/problem+json] · curl's exit code: 0 · WARN lines it added: 0 · ERROR lines: 0
  the headers curl saved, as they came: 5 lines, the status line first (Date's value masked):
    HTTP/1.1 503
    Content-Type: application/problem+json
    Transfer-Encoding: chunked
    Date: …
    Connection: close
  Content-Length: none · Transfer-Encoding: chunked
  the body curl saved, whole (0 newlines):
    | {"instance":"/probe/feed","status":503,"title":"Service Unavailable"}
  the harness's lines it printed, in order: 4
     1 Feed            the handler returns the emitter, nothing sent yet, on tomcat-handler-<n> (virtual: true) - orders asked: 0
     2 Timeouts        the REQUEST dispatch leaves; the request is async, its timeout: 30000 ms
     3 Feed            onTimeout on tomcat-handler-<n> (virtual: true) - the clock: none - no events were asked
     4 Feed            onCompletion on tomcat-handler-<n> (virtual: true) - the clock: none - no events were asked
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19504 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19504 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
D (labelled) - the key by its effect, a bound and not a clock: the same request with curl bounded to ten seconds (this unit's line, --max-time 10); A's JVM, the key unset, port 19504:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19504 --spring.main.sources=probe.web.Feed,probe.web.Timeouts
  listens on: 127.0.0.1:19504 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19504/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Feed): en_US
  the harness at start: Timeouts spring.mvc.async.request-timeout in Spring's environment: null - Tomcat's connector, its async timeout: 30000 ms
$ curl -s -N -D .harness/head.txt -o .harness/body.txt -w ' %{http_code} · Content-Type: [%{content_type}]\n' --max-time 10 'http://127.0.0.1:19504/probe/feed?orders=0'
  curl's line: 000 · Content-Type: [] · curl's exit code: 28 · WARN lines it added: 0 · ERROR lines: 0
  the headers curl saved, as they came: 0 lines, the status line first (Date's value masked):
  Content-Length: none · Transfer-Encoding: none
  the body curl saved: nothing
  the harness's lines it printed, in order: 4
     1 Feed            the handler returns the emitter, nothing sent yet, on tomcat-handler-<n> (virtual: true) - orders asked: 0
     2 Timeouts        the REQUEST dispatch leaves; the request is async, its timeout: 30000 ms
     3 Feed            onTimeout on tomcat-handler-<n> (virtual: true) - the clock: none - no events were asked
     4 Feed            onCompletion on tomcat-handler-<n> (virtual: true) - the clock: none - no events were asked
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19504 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19504 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
then B's JVM, the key at two seconds, port 19505:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19505 --spring.main.sources=probe.web.Feed,probe.web.Timeouts --spring.mvc.async.request-timeout=2s
  listens on: 127.0.0.1:19505 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19505/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Feed): en_US
  the harness at start: Timeouts spring.mvc.async.request-timeout in Spring's environment: 2s - Tomcat's connector, its async timeout: 30000 ms
$ curl -s -N -D .harness/head.txt -o .harness/body.txt -w ' %{http_code} · Content-Type: [%{content_type}]\n' --max-time 10 'http://127.0.0.1:19505/probe/feed?orders=0'
  curl's line: 503 · Content-Type: [application/problem+json] · curl's exit code: 0 · WARN lines it added: 0 · ERROR lines: 0
  the headers curl saved, as they came: 5 lines, the status line first (Date's value masked):
    HTTP/1.1 503
    Content-Type: application/problem+json
    Transfer-Encoding: chunked
    Date: …
    Connection: close
  Content-Length: none · Transfer-Encoding: chunked
  the body curl saved, whole (0 newlines):
    | {"instance":"/probe/feed","status":503,"title":"Service Unavailable"}
  the harness's lines it printed, in order: 4
     1 Feed            the handler returns the emitter, nothing sent yet, on tomcat-handler-<n> (virtual: true) - orders asked: 0
     2 Timeouts        the REQUEST dispatch leaves; the request is async, its timeout: 2000 ms
     3 Feed            onTimeout on tomcat-handler-<n> (virtual: true) - the clock: none - no events were asked
     4 Feed            onCompletion on tomcat-handler-<n> (virtual: true) - the clock: none - no events were asked
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19505 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19505 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 4 · committed — time runs out mid-stream

B's key, an endless feed: `200 text/event-stream`, every event curl saved whole and the last line blank, curl exit 0 — a clean end; the server's `onTimeout`, then one WARN, `o.s.b.w.a.ProblemDetailsExceptionHandler : Response already committed. Ignoring: …AsyncRequestTimeoutException`. Its class, read off the jar with `javap`, extends Spring MVC's `ResponseEntityExceptionHandler`, whose bytes hold the sentence once.

`.r-committed.out` · md5 `1695bed65367ebb06913c524e09de0a4` · 3 of 3

```
mid-stream - the anchor on its class path, the harness joined (Feed, Timeouts), B's key (two seconds), port 19506: an endless feed:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19506 --spring.main.sources=probe.web.Feed,probe.web.Timeouts --spring.mvc.async.request-timeout=2s
  listens on: 127.0.0.1:19506 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19506/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Feed): en_US
  the harness at start: Timeouts spring.mvc.async.request-timeout in Spring's environment: 2s - Tomcat's connector, its async timeout: 30000 ms
$ curl -s -N -D .harness/head.txt -o .harness/body.txt -w ' %{http_code} · Content-Type: [%{content_type}]\n' --max-time 60 'http://127.0.0.1:19506/probe/feed?orders=-1'
  curl's line: 200 · Content-Type: [text/event-stream] · curl's exit code: 0 · WARN lines it added: 1 · ERROR lines: 0
  the headers curl saved, as they came: 4 lines, the status line first (Date's value masked):
    HTTP/1.1 200
    Content-Type: text/event-stream
    Transfer-Encoding: chunked
    Date: …
  Content-Length: none · Transfer-Encoding: chunked
  the body curl saved: its events - how many is timing, not shown · every one whole (id, event, data, then a blank line), the ids from 1 in order, each event's customer the next in the anchor's list with the anchor's meals a day, its kitchen count the anchor's: yes · the last line blank: yes · its first event:
    | id:1
    | event:order
    | data:{"order":1,"customer":"Meera","mealsPerDay":1,"kitchenCooked":120}
  the harness's lines it printed, in order: 5
     1 Feed            the handler returns the emitter, nothing sent yet, on tomcat-handler-<n> (virtual: true) - orders asked: endless
     2 Timeouts        the REQUEST dispatch leaves; the request is async, its timeout: 2000 ms
     3 Feed            sent event 1 (Meera) on kitchen-clock (virtual: false) - an endless feed prints its first send only
     4 Feed            onTimeout on tomcat-handler-<n> (virtual: true) - the clock: stopped
     5 Feed            onCompletion on tomcat-handler-<n> (virtual: true) - the clock: stopped
    WARN o.s.b.w.a.ProblemDetailsExceptionHandler: Response already committed. Ignoring: org.springframework.web.context.request.async.AsyncRequestTimeoutException
      its stack frames: 0, its other lines: 0 - none shown
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
$ harness/shutdown.sh 19506 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19506 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
whose WARN - Boot's handler, read off its jar (this unit's line), then its sentence, counted in Spring MVC's class (this unit's line):
$ javap -cp .harness/anchor/tiffinbox-web/target/extracted/lib/spring-boot-webmvc-4.1.1.jar org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler
  Compiled from "ProblemDetailsExceptionHandler.java"
  class org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler extends org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler {
    org.springframework.boot.webmvc.autoconfigure.ProblemDetailsExceptionHandler();
  }
$ unzip -p .harness/anchor/tiffinbox-web/target/extracted/lib/spring-webmvc-7.0.9.jar org/springframework/web/servlet/mvc/method/annotation/ResponseEntityExceptionHandler.class | grep -ac 'Response already committed. Ignoring'
  1
```

## 5 · gone — the reader leaves

The key unset, an endless feed, `curl --max-time 2`: curl's exit code 28 (its status line still says 200; every event it saved whole). The server learns of it at a send: `onError` — `AsyncRequestNotUsableException: Servlet container error notification for disconnected client`, the failed send on the clock's thread `…failed to flushBuffer: java.io.IOException: <the OS's words>` — then `onCompletion`; the clock stopped;
0 WARN 0 ERROR. **The OS's words are masked** (RED S4 #349): the exception's message is the kernel's text for the failed write (`Broken pipe`
on this Mac; a Linux kernel may say `Connection reset by peer`), so the capture keeps only that it is a `java.io.IOException`; the check
asserts that on the raw line (kept in `.harness/gone-os.txt`), and the terminal prints the words, never a capture.

`.r-gone.out` · md5 `23c7d84808f566705fd4641a0100882f` · 3 of 3

```
the reader leaves - the anchor on its class path, the harness joined (Feed, Timeouts), the key unset, port 19507: an endless feed, curl bounded to two seconds:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19507 --spring.main.sources=probe.web.Feed,probe.web.Timeouts
  listens on: 127.0.0.1:19507 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19507/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Feed): en_US
  the harness at start: Timeouts spring.mvc.async.request-timeout in Spring's environment: null - Tomcat's connector, its async timeout: 30000 ms
$ curl -s -N -D .harness/head.txt -o .harness/body.txt -w ' %{http_code} · Content-Type: [%{content_type}]\n' --max-time 2 'http://127.0.0.1:19507/probe/feed?orders=-1'
  curl's line: 200 · Content-Type: [text/event-stream] · curl's exit code: 28 · WARN lines it added: 0 · ERROR lines: 0
  the headers curl saved, as they came: 4 lines, the status line first (Date's value masked):
    HTTP/1.1 200
    Content-Type: text/event-stream
    Transfer-Encoding: chunked
    Date: …
  Content-Length: none · Transfer-Encoding: chunked
  the body curl saved: its events - how many is timing, not shown · every one whole (id, event, data, then a blank line), the ids from 1 in order, each event's customer the next in the anchor's list with the anchor's meals a day, its kitchen count the anchor's: yes · the last line blank: yes · its first event:
    | id:1
    | event:order
    | data:{"order":1,"customer":"Meera","mealsPerDay":1,"kitchenCooked":120}
  the harness's lines it printed, in order: 5
     1 Feed            the handler returns the emitter, nothing sent yet, on tomcat-handler-<n> (virtual: true) - orders asked: endless
     2 Timeouts        the REQUEST dispatch leaves; the request is async, its timeout: 30000 ms
     3 Feed            sent event 1 (Meera) on kitchen-clock (virtual: false) - an endless feed prints its first send only
     4 Feed            onError on tomcat-handler-<n> (virtual: true): AsyncRequestNotUsableException: Servlet container error notification for disconnected client - the failed send, on the clock's thread: AsyncRequestNotUsableException: ServletResponse failed to flushBuffer: java.io.IOException: <the OS's words> - the clock: stopped
     5 Feed            onCompletion on tomcat-handler-<n> (virtual: true) - the clock: stopped
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19507 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19507 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 6 · exercise — the exercise, run as written, in one shell

exercise/README.md's eight lines, then SOLUTION.md's four, in one `env -i` `/bin/bash` shell: `the feed: 503 application/problem+json · events: 0`, then `the feed: 200 text/event-stream · events: 3`; the shell left in this folder after each; each log en_US, 0/0, its own token 0 times; 19509 free.

`.r-exercise.out` · md5 `f07806ddfb8c7534938d84014a6c0426` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 8 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/ && cp exercise/KitchenFeed.java .harness/mine/KitchenFeed.java
  $ mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
  $ printf 'spring.mvc.async.request-timeout: 2s\n' > .harness/mine/anchor/tiffinbox-local.yaml
  $ N=0
  $ M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*" ../KitchenFeed.java && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19509 --spring.main.sources=probe.web.KitchenFeed > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19509/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -N -o ../feed.txt -w '%{http_code} %{content_type}' "http://127.0.0.1:19509/kitchen/feed?orders=$N"); ../../../harness/shutdown.sh 19509 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the feed: $a · events: $(grep -c '^data:' ../feed.txt)")
  exit 0 · what they printed:
    the feed: 503 application/problem+json · events: 0
  the shell is now in: this unit's folder · the stream it saved: 0 data lines · the JVM's locale in its log: en_US · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19509 now: 0
the solution's 4 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ N=3
  $ M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*" ../KitchenFeed.java && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19509 --spring.main.sources=probe.web.KitchenFeed > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19509/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -N -o ../feed.txt -w '%{http_code} %{content_type}' "http://127.0.0.1:19509/kitchen/feed?orders=$N"); ../../../harness/shutdown.sh 19509 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the feed: $a · events: $(grep -c '^data:' ../feed.txt)")
  exit 0 · what they printed:
    the feed: 200 text/event-stream · events: 3
  the shell is now in: this unit's folder · the stream it saved: 3 data lines · the JVM's locale in its log: en_US · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19509 now: 0
  the stream the solution saved, .harness/mine/feed.txt, whole:
    | id:1
    | event:order
    | data:Meera
    |
    | id:2
    | event:order
    | data:Priya
    |
    | id:3
    | event:order
    | data:Ravi
    |
  the key file the README wrote, .harness/mine/anchor/tiffinbox-local.yaml, whole: 1 line
    spring.mvc.async.request-timeout: 2s
```

## Exercise

**Your turn:** the README's feed waits, then answers five oh three. Read the timeout key, ask for three orders, and count the events.
`exercise/README.md` has the commands (copy the anchor and `KitchenFeed.java`, give the copy a token of its own, write
`spring.mvc.async.request-timeout: 2s` into the copy's `tiffinbox-local.yaml`, `N=0`); its last line, in a subshell, builds the copy
offline, compiles the class, starts it on 19509, asks the feed for `N` orders with `curl -N`, stops it, waits for its JVM and prints — as
shipped — `the feed: 503 application/problem+json · events: 0`. Done is `the feed: 200 text/event-stream · events: 3` (`N=3`, the last line
unchanged). Measured answer: `exercise/solution/`. Run `./receipts.sh` once first on a fresh clone.

## The ledger rows and hand-offs this unit pays

- **The roadmap's U21 line** — "a live kitchen feed consumed by `curl`", **scoped** (brief "ROADMAP LINES SHARPENED"): **a feed** of the
  anchor's own data — its customers (`CustomerRepository`) and its kitchen's cooked count (`OrderQueue`) — on **the harness's cadence**,
  consumed by `curl -N` (`events`). TiffinBox emits no events of its own (its kitchen cooks once, at start: `kitchenCooked` is 120 in every
  event, as the seven's `GET /kitchen`), so nothing here is called "live".
- **C6-31's U21 flag** ("`curl` reading a stream"): `-N` glossed at first use — curl's own help line is in `events`
  (`-N, --no-buffer  Disable buffering of the output stream`); every new term glossed (server-sent events, an emitter; an async dispatch
  and a committed response re-glossed).
- **The upload lesson's open question** — does a `OncePerRequestFilter` skip the ASYNC dispatch? **Settled here** (`dispatch`): the filters
  lesson's `OnceFilter` never runs on it; `OnceAsync`, the same kind of filter with `shouldNotFilterAsyncDispatch()` false, does — so Boot
  registers the bean for the ASYNC dispatch, and the skip is the class's own default.

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-22) |
|---|---|---|---|
| 2 | Every 21 capture on its own harness and `16/after` | the probe's `base/`, a synthetic feed (`order n cooked`) | **all six captures here; every event the anchor's own customer and kitchen count**, judged against the seven's answers |
| 6 | 21's default async timeout, read off Tomcat | one 31-second run | **read three ways, never timed**: the key `null` in Spring's environment (Boot's metadata: no default); **Tomcat's connector's async timeout 30000 ms**; the request's own async context 30000 ms (B: the key `2s` → the context 2000 ms, the connector still 30000) |
| 14 | The exercise as viewers run it | end states on sketches | **README then SOLUTION in one `env -i` shell, exit 0 each** (`exercise`, and "Found on the way") |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **The reader leaves: the server learns of it from a failed send, and the notice says "disconnected client".** The brief's sketch had
  "`Broken pipe`, then `onError`". Measured: `onError` carries Spring MVC's `AsyncRequestNotUsableException: Servlet container error
  notification for disconnected client`; the send that failed, on the clock's thread, threw `AsyncRequestNotUsableException: ServletResponse
  failed to flushBuffer: java.io.IOException: Broken pipe` (its message masked in the capture since BLUE S4 part 1 — the OS's words). Both are printed, on one line (`gone`); neither is a WARN or an ERROR (0/0).
  How many sends the server made after curl left is timing, and never printed.
- **Who logs the committed WARN.** "Boot's WARN" (brief S4.5) is the logger's name: `o.s.b.w.a.ProblemDetailsExceptionHandler`, Boot's
  class — but the class is a one-constructor subclass of **Spring MVC's** `ResponseEntityExceptionHandler` (`javap`), and the sentence lives in
  the parent's bytes (counted once). The voice says "logged under Boot's handler".
- **A 503 for a stream that sent nothing is not a committed answer**: it comes with `Connection: close` and `Transfer-Encoding: chunked`, a
  fresh problem detail (`instance`, `status`, `title`; no `detail`), and no WARN — the answer had not been committed, so the handler could
  still answer. After an event, the same timeout cannot change the 200 the client already has (`committed`).
- **On the REQUEST dispatch of a stream the interceptor runs `preHandle` only** — no `postHandle`, no `afterCompletion` until the ASYNC
  dispatch (`dispatch`: one interceptor line on REQUEST, three on ASYNC).
- **The default timeout is the connector's, and the key does not change it**: B's `2s` reaches the request's async context (2000 ms) while
  Tomcat's connector still reads 30000 ms (`timeout` B) — Spring MVC sets the timeout per request.
- **The brief's sketch and this tree agree** on every other line of its unit block: `text/event-stream`, chunked, `id:`/`event:`/`data:`/a
  blank line, curl exit 0 at `complete()`; the handler returns at once on a request thread and the sends run on another; the ASYNC dispatch
  runs the interceptor's `preHandle` again, `postHandle` (committed true) and `afterCompletion`; the REQUEST-only filter bean and the
  `OncePerRequestFilter` never see it; no event before the timeout → `503 application/problem+json`; events then the timeout → a clean end
  (curl exit 0) and one WARN "Response already committed. Ignoring"; `--max-time` → curl exit 28.

## Found on the way

- **Every new check fails on a planted fault first** (R.65): the checks block runs alone (`cap()` dropped, the build and the wipe skipped)
  on the published captures with one thing changed per plant (`plants.py`, this unit's scratch folder), the file restored after each —
  **49 plants, 49 stops under /bin/bash 3.2 and 49 under bash 5.3**, each naming its own check; the unplanted files pass before and after
  under both, and the published captures' md5s are unchanged. They change a capture (the seven's hash and its logger; the anchor's list and
  its kitchen count; curl's `-N` line; the locale; the stream's `Content-Type`, its chunking, a fourth event, curl's exit code, the event
  judge, a send's thread; a PlainFilter line on ASYNC, `postHandle`'s committed, `OnceAsync` for `OnceFilter`; the key's metadata default,
  A's environment, B's 2000 ms, `Connection: close`, the 503's title, its WARN count, A′; `committed`'s exit code, its WARN's logger, the
  `extends`, the last blank line, a second event shown; `gone`'s exit 28, its Broken pipe, a count of its events, its 0/0; the exercise's two
  lines, Ravi's event, the port free; a thread's number, Boot's PID line, an unpinned java line, an absolute path, a duration) or a shipped
  file (a bare `wait` in the exercise; SOLUTION.md's `N=3`; the spoken exercise line; `Feed` not reading `OrderQueue`; an `onError` not
  registered; `OnceAsync` keeping the skip; this README's B line; Boot 3's error key in this README; a second "browser" in the exercise).
- **Three plants first went uncaught**, and each is a sharper check or plant now: "browser" was counted by lines, so a second one on the
  same line passed (now counted by occurrence); a plant that commented out `onError` left its call on the line (the plant now renames it);
  and an endless stream's count planted in a place an earlier check already stopped (moved where only the R.121 check can see it).
- **Filters checked on planted inputs inside the script itself**, before any capture: the record filter, the level counts (a planted log
  with a harness line naming the ERROR dispatch, one WARN and one ERROR record: 1 and 1 by line shape — a bare `' ERROR '` gives 2), the
  harness-line filter (a falling running number stops the run), the header filter, the stream filter (carriage returns, the trailing space,
  `Date`, blank lines) and the event judge (a planted list of two customers: a whole stream → yes; out of order, a stranger, a wrong kitchen
  count → no; cut inside an event → the last line not blank).
- **Found while building:** (1) the first run of `gone` printed the send's failure from the clock's thread as its own line, and the
  container's `onError` on another — two threads' lines, in either order. The harness now keeps the send's exception and `onError` prints it,
  waiting up to 5 s for it: one line, one order, 3/3 every run since. (2) The first full run recursed: this unit's capture `gone` had the name
  of the receipt's own helper that waits for a JVM to leave; the helper is `exited()` now. Interrupting that run, the author's clean-up used
  `pkill -f receipts.sh` from the tool's shell — a name match, which R.79's spirit forbids; it could have reached another unit's receipts.sh started at that moment - none was running when checked right after;
  every later stop here was by pid or process group.
- **SIGINT**, measured: the script started as a terminal starts its foreground job (`python3` with `SIG_DFL` and `os.setpgrp()`, `env -i`,
  /bin/bash 3.2), SIGINT to its process group during `timeout` A, while curl held a feed open on 19504 (4 processes in the group, one of
  them TiffinBox's JVM): **exit 130**; 5 s later 0 processes in the group, 0 TiffinBox JVMs anywhere; 19500-19509, 8080, 18425 and 35729
  free; no `.r-lock`, no unfinished capture run; the published captures unchanged (md5). Measured twice.
- **The exercise as viewers run it**, beyond the capture: the `exercise` capture runs README then SOLUTION in one `env -i` shell, and the
  SOLUTION's `N=3` lives in that shell; a new shell needs both lines of SOLUTION's block (they set `N`), which is why it repeats the exports
  and sets `N` itself. 19509 free after each.

## For RED

- This unit reads `../c6-unit16/after` only (no change).
- **Re-check:** both bashes, the sealed clone, SIGINT during a capture's JVM; that every endless stream is judged, never counted (`evs`
  `first`); that the 30000 ms is read (the connector, the request's context), never timed; the WARN's logger and the class that holds its
  sentence; that `onError`'s one line carries both exceptions in a fixed order (the container's notice, then the failed send, waited for up
  to 5 s); that the filters lesson's eight classes are byte for byte (`cmp`); that `OnceAsync` is the only difference in `dispatch` C; the
  exercise under Java 23 and twice in one shell; that no harness class reached the anchor; the 0/0 counts by line shape.
