# c6-unit18 — Filters vs Interceptors vs Advice

Course 6 · Spring Web MVC · Section 4 (The Rest of MVC), its first unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot
4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5), 2026-10-22. Three kinds of code can touch a request on its way through
TiffinBox: a **servlet filter** (Tomcat runs it, before Spring MVC sees the request), a **handler interceptor** (Spring MVC runs it around
the handler, inside the `DispatcherServlet`) and an **advice** (an `@ExceptionHandler` and a `ResponseBodyAdvice`). This unit puts one or
more of each on TiffinBox through the course's harness, prints the order they run in (each hook prints a line), then throws from each and
counts who still gets a say — and who runs twice, when Tomcat's **error dispatch** sends a failed request round again.

**No anchor change (brief ⚑2).** `anchor` is the link to `../c6-unit16/after` — the problem-detail lesson's frozen tree, `c6-tiffinbox` at
Section 3's end (`diff -rq -x target c6-tiffinbox c6-unit16/after` empty on 2026-10-22) — read and copied under `.harness/anchor`, never
built in place; this unit freezes no `after/` and touches no other unit's folder. Everything new is **the course's harness**, never
TiffinBox's — `harness/probe/web`, outside `com.tiffinbox`, compiled with `-parameters` against the anchor's own jar and joined by
`--spring.main.sources` on the extracted jar's class path:

- `Trace` — every hook's line: `HOOK nnnn what ran`, on standard output (Boot's log's stream). The running number is the JVM's, in the
  order the code ran; the receipt checks it rises and numbers the lines from 1 per request (readiness polls pass the filters too).
- `PlainFilter` — a plain `Filter`, joined as a bean (Boot registers a filter bean for the REQUEST dispatch), `@Order(1)`. `X-Chain` (any
  value): print the chain Tomcat built, read by reflection off Tomcat's `ApplicationFilterChain` (each filter's name and class).
  `X-Boom: plain` / `plain-oops` throw an `IllegalStateException` / a `ProbeOops`.
- `OnceFilter` — a Spring `OncePerRequestFilter` bean, `@Order(2)`; it skips the ERROR dispatch (`shouldNotFilterErrorDispatch()` true by
  default) unless `--probe.once.error=true`. `X-Boom: once` throws.
- `EveryFilter` + `EveryRegistration` — a plain `Filter` that is not a bean, registered by a `FilterRegistrationBean` (a **filter
  registration**) for every dispatch type, at the order `--probe.every.order` gives (0 unless named). `X-Chain` prints the chain too;
  `X-Boom: every` throws, on every dispatch.
- `PlainRegistration` — `PlainFilter` (its class still `@Order(1)`) wrapped in a `FilterRegistrationBean` that sets no order (`chain`'s last run).
- `Interceptor` + `Hooks` — a `HandlerInterceptor` added by a `WebMvcConfigurer` with no path pattern; `--probe.exclude=/error` adds one
  `excludePathPatterns` (`dispatch` E). `preHandle` names the handler; `postHandle` sets `X-Post-Handle: set` and says whether the answer
  was already committed; `afterCompletion` names the exception that escaped. `X-Boom: pre` throws on the REQUEST dispatch only, `pre-all`
  on every dispatch, `pre-oops` a `ProbeOops`. `Hooks` prints the JVM's locale.
- `ProbeAdvice` — `@RestControllerAdvice`: `@ExceptionHandler(ProbeOops)` → a 409 problem detail naming itself (`"handler":"ProbeAdvice"`),
  and `ResponseBodyAdvice.beforeBodyWrite` (prints the path and the body's type, changes nothing).
- `ProbeRoutes` / `ProbeOops` — `/probe/ok` (a small map), `/probe/big` (2,000 strings), `/probe/oops` (throws `ProbeOops`), `/probe/boom`
  (throws an `IllegalStateException` nobody handles).
- `harness/shutdown.sh` — POST `/shutdown` with the token read from its file (the binding lesson's, unchanged).
- `exercise/Guard.java` — the exercise's interceptor (and `exercise/solution/Guard.java`, the measured fix).

**This unit's switches are Spring properties** (`probe.*`), read by the harness from Spring's environment, so every run passes options only
(R.8) — the brief wrote B as `-Dprobe.once.error=true`; `--probe.once.error=true` is the same switch. A `PROBE_*` variable of yours would set
them too (relaxed binding): `receipts.sh` removes every one first (a canary planted, the run stops if one survives).

No native build, no Docker and no browser (brief: 18 builds neither; curl only — so nothing here says "a browser", R.115).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 5 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top; a bare `java` on this Mac is 23.0.1.) It **dies** when a capture's md5 differs
from `receipts.md5` (it prints the `DIFFERS` line first). **Start it in a process group of its own** (a terminal's foreground job is one):
two receipts started as background jobs of one shell share a group, and one run's clean-up would stop the other's JVMs (R.94).

**Runs of record (2026-10-22, this script as committed; unchanged by BLUE S4 part 1):** **220 s under `./receipts.sh`** (/bin/bash 3.2.57,
`env -i` with HOME and a plain PATH, this folder, its own process group, `.m2-demo` re-seeded from `_research/m2-seed-s4/` alone: exit 0, all
5 captures 3/3 = published, every check passed; `.m2-demo` still 5,891 files after) and **291 s under `bash receipts.sh`** (Homebrew bash
5.3.9, the same, re-seeded: exit 0, all 5 = published; 5,891 files after). **A sealed fresh clone, by the recipe below** (2026-10-23, BLUE
S4 part 1 — the earlier text of this paragraph, measured by RED S4 #405, does not seal): `git clone` of tiffinbox-java at 81b6d31 through
`file://`, this unit's 20 files put in as git would take them (`git ls-files -co --exclude-standard`; `anchor` stays the link —
`readlink` gives `../c6-unit16/after`, and the tree it points to diffed whole: 0 differences); a `file://` copy of Central's files made
from this unit's `.m2-demo` (4,413 files); **the pre-flight: exit 1, 221 `Downloading from sealed: file://` lines, 0 from `http(s)://`**;
then `./receipts.sh` (/bin/bash 3.2, `env -i`, a session of its own, the proxy variables at 127.0.0.1:9): **exit 0 in 230 s, all 5 =
published**, every check passed; the first build said `offline: no`, as a fresh clone's must; **the post-check: `_remote.repositories`
holds 512 entries, every one `>sealed=`, 0 `>central=`** (352 artifact folders), and the build logs 1,024 `sealed: file://` lines, 0
`http(s)://`. **How the hashes were made:** one development run (bash 3.2, each capture 3/3) fixed the captures; its five hashes went into
`receipts.md5`; every run since reproduced them, 3 of 3 each (bash 5.3 twice, bash 3.2, both sealed clones).

Published hashes: chain `0d12a8f11754c1c03af959332c195af8` · order `701a5c58f9bd5e00ed8413acb919dac4` · throws `f6ce61fba288f52094b2e8334bdfcf43` · dispatch `4ae137a2f004467c61249ba7e4b9ebe4` · exercise `3acd496457dee74f384c662a7dba72ec`.

### A sealed fresh clone — the recipe (RED S4 #405)

A sealed clone proves that a fresh clone's first build fetches only from a copy you control. **The earlier text of this paragraph did not
seal** (RED S4 #405, measured): a `HOME` of its own whose `.mavenrc` set only `-Dhttp(s).proxyHost`, with Maven settings in `$HOME/.m2`,
fetched from Maven Central — Java on macOS ignores `$HOME` (`user.home` stays your own folder, so Maven never read those settings), and
Maven's resolver ignores the `-Dhttp.proxyHost` properties (it takes its proxies from `settings.xml`). The recipe that seals, step by step,
with a pre-flight that refuses to start unless the only remote is `file://` and a post-check of where every artifact came from:

```bash
S=/tmp/sealed-18                                   # an empty folder of your own; T = your tiffinbox-java clone
mkdir -p "$S/home/.m2" && git clone -q "file://$T" "$S/tiffinbox-java"
rsync -a --exclude _remote.repositories --exclude '*.lastUpdated' --exclude resolver-status.properties "$T/c6-unit18/.m2-demo/" "$S/central/"
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
cd "$S/tiffinbox-java/c6-unit18" && $E ./receipts.sh            # a process group of its own (a terminal's foreground job is one)
# post-check: every artifact's origin, by repository id - each line must say sealed; 0 central
find .m2-demo -name _remote.repositories -exec cat {} + | grep -o '>[^=]*=' | sort | uniq -c
```

## The commands this unit adds

`anchor/README.md` — the anchor's own — gives every line `receipts.sh` runs or derives from (`mvn -B package`, the run line, the extract
line, the class-path line, the readiness line, the Content-Type line) but these nine, which are this unit's, each read from the block below
and asserted to be exactly this (on the anchor's port 18431; each capture swaps in its own port):

```bash
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --probe.every.order=5
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --probe.every.order=-2147483648
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --probe.once.error=true
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --probe.exclude=/error
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/probe/web/EveryFilter.java harness/probe/web/EveryRegistration.java harness/probe/web/Hooks.java harness/probe/web/Interceptor.java harness/probe/web/OnceFilter.java harness/probe/web/PlainFilter.java harness/probe/web/PlainRegistration.java harness/probe/web/ProbeAdvice.java harness/probe/web/ProbeOops.java harness/probe/web/ProbeRoutes.java harness/probe/web/Trace.java
curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · X-Post-Handle: [%header{x-post-handle}]\n' -H 'X-Boom: once' http://127.0.0.1:18431/probe/ok
curl -s -o .harness/got.txt -w ' %{http_code} · Content-Type: [%{content_type}] · X-Post-Handle: [%header{x-post-handle}]\n' http://127.0.0.1:18431/probe/big
```

The first two are the anchor's run line and its class-path line with `-Duser.language=en -Duser.country=US` after `java` — asserted — and
every java line a capture starts takes the same two options in the same place (`at()`; a last check refuses any capture's java line without
them, and the exercise's). The next four are the pinned class-path line with one of this unit's keys at the end: the registration's order
5 and `Integer.MIN_VALUE` (`chain`), the `OncePerRequestFilter`'s ERROR-dispatch skip off (`dispatch` B), `/error` excluded from the
interceptor (`dispatch` E). The javac line compiles the harness's eleven files and nothing else. The hook line is the anchor's Content-Type
line with `X-Post-Handle: [%header{x-post-handle}]` added to curl's `-w`, one request header and the harness's `/probe/ok` (`hq()` swaps the
path and the header, or drops it); the saved-answer line is the same with `-o .harness/got.txt` and `/probe/big`, so the receipt can read
what curl got. Each derivation is asserted.

## The repository, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from `../../spring-web-mvc/_research/m2-seed-s4/`
alone — 5,891 files (the S3 seed + the Thymeleaf 54, which this unit does not use), no `com/tiffinbox`. **Nothing was downloaded** for this
unit: every build said `offline: yes`. A fresh clone's `.m2-demo` is empty (git ignores it): the first build — `.harness/pre`, before any
capture — fills it from Maven Central and says `offline: no`. **At run time** every request goes to `127.0.0.1`, and nothing binds 8080,
18425 or 35729.

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 26 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/anchor/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) when the script runs, and sent only by `../c5-unit11/curlset.sh` and `harness/shutdown.sh` on curl's standard input. Every
capture's raw output is searched for it before masking (0 in all of them), and so are the log of every JVM that served, and every file this
unit ships: 0 everywhere. The header's name, `X-Shutdown-Token`, is counted too: 0 in every log. No capture sends a secret toward an answer,
so this unit plants no canary. The exercise makes a token of its own (`openssl rand -hex 13`), counted 0 times in its own log, never printed.

## The locale — pinned per JVM, printed, asserted

Every java line this script starts carries `-Duser.language=en -Duser.country=US` before `-jar` or `-cp` (S4.1, R.100), and every harness
JVM prints its locale (`Hooks`; the exercise's `Guard`) — `en_US`, asserted in every capture that starts one (S4.23). Receipts run under
bash (`#!/bin/bash`), never zsh, where the two options would arrive as one word (brief READ FIRST 13).

## The folders, the names and the ports

- `.harness/pre` — the anchor built before any capture; `.harness/anchor` — the anchor, copied, with a config tree, built and extracted
  (`chain`); `.harness/hc` — the harness's classes; `.harness/got.txt` — the long answer (`order`); `.harness/mine` — the exercise's copy.
- **Ports** (brief ⚑1, 19470-19479): `chain` — the seven and order 0 19470, order 5 19471, `MIN_VALUE` 19472, wrapped 19473 · `order` 19474 ·
  `throws` 19475 · `dispatch` — A and A′ 19476, B 19477, C and D 19478, E 19471 · the exercise 19479. Captures run one after another, each
  JVM stopped (and its port checked free) before the next starts. All ten, 18425, 8080 and 35729 are checked free first; a run that listens
  on 8080 or 35729 is killed and the script dies.

## Masks, filters and hygiene — every one, declared

1. **Paths, the token, the user** (`gsub()`, literals escaped), in every line: the demo token → `[masked: the 26-character token]`; this
   folder → `…`; the folder above → `…/..`; home → `~`; the user name, as a whole word → `<user>`; a generated class's number →
   `$$SpringCGLIB$$<n>`. A last check fails if any capture holds `/Users/`, `/private/`, `/home/`, `/var/folders/`, a unit number, Boot's
   process line, a log time, an unmasked timestamp, a date, a thread number, a stack frame, a whole HTML page, `:8080` or `:35729`, a
   carriage return, or a command with a URL that is not `127.0.0.1`'s.
2. **Spring's error timestamp** (`tsmask`, `pagef`): `"timestamp":"<anything>"` → `"timestamp":"…"`, both forms, in every answer printed and
   in the seven (problem details there: the mask runs and prints its count, 0).
3. **Answers** (`pagef`): **Tomcat's own page** as its `<h1>` and its length, never shown; JSON — a problem detail too — as it came, never
   re-ordered. **A saved answer** (`sumf`): whether it parses, how many items, its first and its last; never its byte count (R.45). Both
   checked on planted inputs before any capture.
4. **Log lines** (`logl`, `recs`): from their logger on, as the log prints the logger — `o.a.c.c.C.[.[.[/].[dispatcherServlet]` and
   `o.a.c.c.C.[Tomcat].[localhost]` are **Tomcat's** (a filter's exception included: Tomcat logs it under the servlet's name),
   `o.s.web.servlet.PageNotFound` is **Spring MVC's**. Boot's first line is cut before ` with PID`. Every request ends its answer's last line
   with `· WARN lines it added: N · ERROR lines: M` — **counted by the log's own line shape** (`<ISO date> LEVEL <pid> --- [`), never a bare
   `' ERROR '`, which the harness's own `… in ERROR /error` lines would satisfy (R.120; checked on a planted log first: a hook line that
   says ERROR and one record give 1, where a bare count gives 3). Each WARN or ERROR record follows: its level, logger and message, the
   exception line under it, its stack frames bounded ("over 40") and its other lines counted — the harness's hook lines skipped.
5. **Hook lines** (`hk`): printed after each request in the order they printed, numbered from 1, the JVM's running number checked to rise
   (a planted falling number stops the run) and never shown; no thread name (virtual threads give one request two).
6. **The chain** (`chn`): `everyFilter`'s reading, one filter a line (name and class), and whether the plain filter read the same.
7. **A′ against A** (`asame`): A's block and A′'s, their labels aside, compared line for line in the capture itself ("yes").
8. **On this Mac**: `lsof` by pid (or by port), the address column alone — never a command name (R.18).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`, and the exercise's
shell `$xpid` with every process under it — `killtree`), sweeps its own process group for any TiffinBox JVM or Maven left, deletes the
capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched. No `wait` in the script, its
checks or the exercise is bare: each names its pid (R.105; a check refuses a bare one). See "Found on the way" for the measured interrupt.

## 1 · chain — the filters' order, read off Tomcat

The anchor built offline and extracted; the harness compiled; the seven on a fresh JVM of the jar (`466c20ed…`, unchanged since the problem-detail lesson, 1 WARN `PageNotFound`). Then one request with `X-Chain: on`, four ways, each on a fresh JVM: the harness's three filters (order 0); the registration at order 5; at `Integer.MIN_VALUE`; and `PlainFilter` wrapped in a registration with no order. Eight filters each time: the four Boot registers (`OrderedCharacterEncodingFilter`, Spring's `ServerHttpObservationFilter`, `OrderedFormContentFilter`, `OrderedRequestContextFilter`), our three, Tomcat's `WsFilter`. The last lesson's `ResolvingFilter` was a filter bean at `HIGHEST_PRECEDENCE` (`../c6-unit17/README.md`, `filter` B): its place is cited there, not repeated; a registration at that order went first here, even ahead of the encoding filter that shares it (one case — which wins a tie is not a rule).

`.r-chain.out` · md5 `0d12a8f11754c1c03af959332c195af8` · 3 of 3

```
the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline), its jar extracted (the README's line):
$ cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the anchor · offline: yes · exit 0
$ cd .harness/anchor && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
the harness, compiled against the anchor's own jar - with -parameters (this unit's line):
$ javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/probe/web/EveryFilter.java harness/probe/web/EveryRegistration.java harness/probe/web/Hooks.java harness/probe/web/Interceptor.java harness/probe/web/OnceFilter.java harness/probe/web/PlainFilter.java harness/probe/web/PlainRegistration.java harness/probe/web/ProbeAdvice.java harness/probe/web/ProbeOops.java harness/probe/web/ProbeRoutes.java harness/probe/web/Trace.java
  exit 0 · its classes: probe/web/EveryFilter.class probe/web/EveryRegistration.class probe/web/Hooks.class probe/web/Interceptor.class probe/web/OnceFilter.class probe/web/PlainFilter.class probe/web/PlainRegistration.class probe/web/ProbeAdvice.class probe/web/ProbeOops.class probe/web/ProbeRoutes.class probe/web/Trace.class
the seven - the anchor, the README's run line (its locale pinned), port 19470, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19470
  listens on: 127.0.0.1:19470 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19470/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19470 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
order 0 - the anchor on its class path, the harness's three filters joined - PlainFilter (a bean, @Order(1)), OnceFilter (a bean, @Order(2)), EveryFilter (in EveryRegistration, a filter registration at order 0) - with Hooks, ProbeAdvice and ProbeRoutes, port 19470:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19470 --spring.main.sources=probe.web.PlainFilter,probe.web.OnceFilter,probe.web.EveryRegistration,probe.web.Hooks,probe.web.ProbeAdvice,probe.web.ProbeRoutes
  listens on: 127.0.0.1:19470 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19470/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Hooks): en_US
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · X-Post-Handle: [%header{x-post-handle}]\n' -H 'X-Chain: on' http://127.0.0.1:19470/probe/ok
  {"answer":"ok"} 200 · Content-Type: [application/json] · X-Post-Handle: [set]
  the chain Tomcat built for it, read from inside everyFilter - 8 filters, in the order Tomcat calls them:
    1 characterEncodingFilter (org.springframework.boot.servlet.filter.OrderedCharacterEncodingFilter)
    2 webMvcObservationFilter (org.springframework.web.filter.ServerHttpObservationFilter)
    3 formContentFilter (org.springframework.boot.servlet.filter.OrderedFormContentFilter)
    4 requestContextFilter (org.springframework.boot.servlet.filter.OrderedRequestContextFilter)
    5 everyFilter (probe.web.EveryFilter)
    6 plainFilter (probe.web.PlainFilter)
    7 onceFilter (probe.web.OnceFilter)
    8 Tomcat WebSocket (JSR356) Filter (org.apache.tomcat.websocket.server.WsFilter)
  read from inside the plain filter too, the same: yes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19470 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19470 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
order 5 - the same, the registration at order 5 for this run (this unit's line), port 19471:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19471 --spring.main.sources=probe.web.PlainFilter,probe.web.OnceFilter,probe.web.EveryRegistration,probe.web.Hooks,probe.web.ProbeAdvice,probe.web.ProbeRoutes --probe.every.order=5
  listens on: 127.0.0.1:19471 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19471/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Hooks): en_US
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · X-Post-Handle: [%header{x-post-handle}]\n' -H 'X-Chain: on' http://127.0.0.1:19471/probe/ok
  {"answer":"ok"} 200 · Content-Type: [application/json] · X-Post-Handle: [set]
  the chain Tomcat built for it, read from inside everyFilter - 8 filters, in the order Tomcat calls them:
    1 characterEncodingFilter (org.springframework.boot.servlet.filter.OrderedCharacterEncodingFilter)
    2 webMvcObservationFilter (org.springframework.web.filter.ServerHttpObservationFilter)
    3 formContentFilter (org.springframework.boot.servlet.filter.OrderedFormContentFilter)
    4 requestContextFilter (org.springframework.boot.servlet.filter.OrderedRequestContextFilter)
    5 plainFilter (probe.web.PlainFilter)
    6 onceFilter (probe.web.OnceFilter)
    7 everyFilter (probe.web.EveryFilter)
    8 Tomcat WebSocket (JSR356) Filter (org.apache.tomcat.websocket.server.WsFilter)
  read from inside the plain filter too, the same: yes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19471 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19471 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
order MIN_VALUE - the same, the registration at Integer.MIN_VALUE for this run (this unit's line), port 19472:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19472 --spring.main.sources=probe.web.PlainFilter,probe.web.OnceFilter,probe.web.EveryRegistration,probe.web.Hooks,probe.web.ProbeAdvice,probe.web.ProbeRoutes --probe.every.order=-2147483648
  listens on: 127.0.0.1:19472 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19472/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Hooks): en_US
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · X-Post-Handle: [%header{x-post-handle}]\n' -H 'X-Chain: on' http://127.0.0.1:19472/probe/ok
  {"answer":"ok"} 200 · Content-Type: [application/json] · X-Post-Handle: [set]
  the chain Tomcat built for it, read from inside everyFilter - 8 filters, in the order Tomcat calls them:
    1 everyFilter (probe.web.EveryFilter)
    2 characterEncodingFilter (org.springframework.boot.servlet.filter.OrderedCharacterEncodingFilter)
    3 webMvcObservationFilter (org.springframework.web.filter.ServerHttpObservationFilter)
    4 formContentFilter (org.springframework.boot.servlet.filter.OrderedFormContentFilter)
    5 requestContextFilter (org.springframework.boot.servlet.filter.OrderedRequestContextFilter)
    6 plainFilter (probe.web.PlainFilter)
    7 onceFilter (probe.web.OnceFilter)
    8 Tomcat WebSocket (JSR356) Filter (org.apache.tomcat.websocket.server.WsFilter)
  read from inside the plain filter too, the same: yes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19472 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19472 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
wrapped - PlainFilter (its class still @Order(1)) inside PlainRegistration, a filter registration that sets no order, joined instead of the bean, port 19473:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19473 --spring.main.sources=probe.web.PlainRegistration,probe.web.OnceFilter,probe.web.EveryRegistration,probe.web.Hooks,probe.web.ProbeAdvice,probe.web.ProbeRoutes
  listens on: 127.0.0.1:19473 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19473/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Hooks): en_US
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · X-Post-Handle: [%header{x-post-handle}]\n' -H 'X-Chain: on' http://127.0.0.1:19473/probe/ok
  {"answer":"ok"} 200 · Content-Type: [application/json] · X-Post-Handle: [set]
  the chain Tomcat built for it, read from inside everyFilter - 8 filters, in the order Tomcat calls them:
    1 characterEncodingFilter (org.springframework.boot.servlet.filter.OrderedCharacterEncodingFilter)
    2 webMvcObservationFilter (org.springframework.web.filter.ServerHttpObservationFilter)
    3 formContentFilter (org.springframework.boot.servlet.filter.OrderedFormContentFilter)
    4 requestContextFilter (org.springframework.boot.servlet.filter.OrderedRequestContextFilter)
    5 everyFilter (probe.web.EveryFilter)
    6 onceFilter (probe.web.OnceFilter)
    7 wrappedPlain (probe.web.PlainFilter)
    8 Tomcat WebSocket (JSR356) Filter (org.apache.tomcat.websocket.server.WsFilter)
  read from inside the plain filter too, the same: yes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19473 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19473 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 2 · order — one request, every hook

Every hook joined, one JVM: `/probe/ok` (11 hook lines: filters in, `preHandle` naming `ProbeRoutes#ok`, the route, `beforeBodyWrite`, `postHandle` — committed false, so its header arrives — `afterCompletion`, filters out in reverse); `/probe/big` (2,000 items, saved and parsed: `postHandle` finds the answer committed and its header never arrives — S4.14: "before the answer was committed" / "after", from the capture); Actuator's health (the filters and `beforeBodyWrite`, **no interceptor line** — the brief's `reach` beat, captured; why — Actuator's own handler mapping — is not measured and not spoken).

`.r-order.out` · md5 `701a5c58f9bd5e00ed8413acb919dac4` · 3 of 3

```
one request - the anchor on its class path, every hook joined, port 19474: a small answer; a long one (2,000 items), saved to a file; Actuator's health:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19474 --spring.main.sources=probe.web.PlainFilter,probe.web.OnceFilter,probe.web.EveryRegistration,probe.web.Hooks,probe.web.ProbeAdvice,probe.web.ProbeRoutes
  listens on: 127.0.0.1:19474 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19474/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Hooks): en_US
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · X-Post-Handle: [%header{x-post-handle}]\n' http://127.0.0.1:19474/probe/ok
  {"answer":"ok"} 200 · Content-Type: [application/json] · X-Post-Handle: [set] · WARN lines it added: 0 · ERROR lines: 0
  the hooks it ran, in the order they printed: 11
     1 EveryFilter     in  REQUEST /probe/ok
     2 PlainFilter     in  REQUEST /probe/ok
     3 OnceFilter      in  REQUEST /probe/ok
     4 Interceptor     preHandle       REQUEST /probe/ok handler ProbeRoutes#ok
     5 ProbeRoutes     ok
     6 ProbeAdvice     beforeBodyWrite /probe/ok body Map1
     7 Interceptor     postHandle      REQUEST /probe/ok status 200 committed false
     8 Interceptor     afterCompletion REQUEST /probe/ok status 200 exception none
     9 OnceFilter      out REQUEST /probe/ok status 200
    10 PlainFilter     out REQUEST /probe/ok status 200
    11 EveryFilter     out REQUEST /probe/ok status 200
$ curl -s -o .harness/got.txt -w ' %{http_code} · Content-Type: [%{content_type}] · X-Post-Handle: [%header{x-post-handle}]\n' http://127.0.0.1:19474/probe/big
  curl's line: 200 · Content-Type: [application/json] · X-Post-Handle: [] · curl's exit code: 0
  what curl got: JSON that parses - a list of 2000 · its first: "0123456789" · its last: "0123456789"
  WARN lines it added: 0 · ERROR lines: 0
  the hooks it ran, in the order they printed: 11
     1 EveryFilter     in  REQUEST /probe/big
     2 PlainFilter     in  REQUEST /probe/big
     3 OnceFilter      in  REQUEST /probe/big
     4 Interceptor     preHandle       REQUEST /probe/big handler ProbeRoutes#big
     5 ProbeRoutes     big
     6 ProbeAdvice     beforeBodyWrite /probe/big body CopiesList
     7 Interceptor     postHandle      REQUEST /probe/big status 200 committed true
     8 Interceptor     afterCompletion REQUEST /probe/big status 200 exception none
     9 OnceFilter      out REQUEST /probe/big status 200
    10 PlainFilter     out REQUEST /probe/big status 200
    11 EveryFilter     out REQUEST /probe/big status 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · X-Post-Handle: [%header{x-post-handle}]\n' http://127.0.0.1:19474/actuator/health
  {"groups":["liveness","readiness"],"status":"UP"} 200 · Content-Type: [application/vnd.spring-boot.actuator.v3+json] · X-Post-Handle: [] · WARN lines it added: 0 · ERROR lines: 0
  the hooks it ran, in the order they printed: 7
     1 EveryFilter     in  REQUEST /actuator/health
     2 PlainFilter     in  REQUEST /actuator/health
     3 OnceFilter      in  REQUEST /actuator/health
     4 ProbeAdvice     beforeBodyWrite /actuator/health body SystemHealthDescriptor
     5 OnceFilter      out REQUEST /actuator/health status 200
     6 PlainFilter     out REQUEST /actuator/health status 200
     7 EveryFilter     out REQUEST /actuator/health status 200
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19474 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19474 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 3 · throws — who still gets a say

One JVM: the controller's `ProbeOops` (the advice's 409; no `postHandle`; `afterCompletion` exception none); the route's `IllegalStateException` (Boot's 500, 1 ERROR — `afterCompletion` sees it at status 200, the filters go out at 200, then the ERROR dispatch runs `everyFilter`, the interceptor on `BasicErrorController#error` and the advice again — not `plainFilter`, not `onceFilter`); the interceptor's `ProbeOops` (**the advice's 409** — S3's open question answered; that interceptor gets no `afterCompletion`); the plain filter's `ProbeOops` (Boot's 500, **no `@ExceptionHandler` line**: the advice is never asked, even for a type it handles).

`.r-throws.out` · md5 `f6ce61fba288f52094b2e8334bdfcf43` · 3 of 3

```
who still gets a say - the anchor on its class path, every hook joined, port 19475: the controller throws a ProbeOops (ProbeAdvice handles it), then an IllegalStateException (nobody does); the interceptor throws a ProbeOops; the plain filter throws a ProbeOops:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19475 --spring.main.sources=probe.web.PlainFilter,probe.web.OnceFilter,probe.web.EveryRegistration,probe.web.Hooks,probe.web.ProbeAdvice,probe.web.ProbeRoutes
  listens on: 127.0.0.1:19475 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19475/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Hooks): en_US
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · X-Post-Handle: [%header{x-post-handle}]\n' http://127.0.0.1:19475/probe/oops
  {"detail":"the controller says oops","instance":"/probe/oops","status":409,"title":"Conflict","handler":"ProbeAdvice"} 409 · Content-Type: [application/problem+json] · X-Post-Handle: [] · WARN lines it added: 0 · ERROR lines: 0
  the hooks it ran, in the order they printed: 11
     1 EveryFilter     in  REQUEST /probe/oops
     2 PlainFilter     in  REQUEST /probe/oops
     3 OnceFilter      in  REQUEST /probe/oops
     4 Interceptor     preHandle       REQUEST /probe/oops handler ProbeRoutes#oops
     5 ProbeRoutes     oops (throws a ProbeOops)
     6 ProbeAdvice     @ExceptionHandler(ProbeOops): the controller says oops
     7 ProbeAdvice     beforeBodyWrite /probe/oops body ProblemDetail
     8 Interceptor     afterCompletion REQUEST /probe/oops status 409 exception none
     9 OnceFilter      out REQUEST /probe/oops status 409
    10 PlainFilter     out REQUEST /probe/oops status 409
    11 EveryFilter     out REQUEST /probe/oops status 409
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · X-Post-Handle: [%header{x-post-handle}]\n' http://127.0.0.1:19475/probe/boom
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/boom"} 500 · Content-Type: [application/json] · X-Post-Handle: [] · WARN lines it added: 0 · ERROR lines: 1
  the hooks it ran, in the order they printed: 15
     1 EveryFilter     in  REQUEST /probe/boom
     2 PlainFilter     in  REQUEST /probe/boom
     3 OnceFilter      in  REQUEST /probe/boom
     4 Interceptor     preHandle       REQUEST /probe/boom handler ProbeRoutes#boom
     5 ProbeRoutes     boom (throws an IllegalStateException)
     6 Interceptor     afterCompletion REQUEST /probe/boom status 200 exception IllegalStateException
     7 OnceFilter      out REQUEST /probe/boom status 200
     8 PlainFilter     out REQUEST /probe/boom status 200
     9 EveryFilter     out REQUEST /probe/boom status 200
    10 EveryFilter     in  ERROR /error
    11 Interceptor     preHandle       ERROR /error handler BasicErrorController#error
    12 ProbeAdvice     beforeBodyWrite /error body LinkedHashMap
    13 Interceptor     postHandle      ERROR /error status 500 committed true
    14 Interceptor     afterCompletion ERROR /error status 500 exception none
    15 EveryFilter     out ERROR /error status 500
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the kitchen is on fire] with root cause
      java.lang.IllegalStateException: the kitchen is on fire
      its stack frames: over 40, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · X-Post-Handle: [%header{x-post-handle}]\n' -H 'X-Boom: pre-oops' http://127.0.0.1:19475/probe/ok
  {"detail":"the interceptor says oops","instance":"/probe/ok","status":409,"title":"Conflict","handler":"ProbeAdvice"} 409 · Content-Type: [application/problem+json] · X-Post-Handle: [] · WARN lines it added: 0 · ERROR lines: 0
  the hooks it ran, in the order they printed: 9
     1 EveryFilter     in  REQUEST /probe/ok
     2 PlainFilter     in  REQUEST /probe/ok
     3 OnceFilter      in  REQUEST /probe/ok
     4 Interceptor     preHandle       REQUEST /probe/ok handler ProbeRoutes#ok
     5 ProbeAdvice     @ExceptionHandler(ProbeOops): the interceptor says oops
     6 ProbeAdvice     beforeBodyWrite /probe/ok body ProblemDetail
     7 OnceFilter      out REQUEST /probe/ok status 409
     8 PlainFilter     out REQUEST /probe/ok status 409
     9 EveryFilter     out REQUEST /probe/ok status 409
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · X-Post-Handle: [%header{x-post-handle}]\n' -H 'X-Boom: plain-oops' http://127.0.0.1:19475/probe/ok
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/ok"} 500 · Content-Type: [application/json] · X-Post-Handle: [] · WARN lines it added: 0 · ERROR lines: 1
  the hooks it ran, in the order they printed: 9
     1 EveryFilter     in  REQUEST /probe/ok
     2 PlainFilter     in  REQUEST /probe/ok
     3 EveryFilter     out REQUEST /probe/ok status 200
     4 EveryFilter     in  ERROR /error
     5 Interceptor     preHandle       ERROR /error handler BasicErrorController#error
     6 ProbeAdvice     beforeBodyWrite /error body LinkedHashMap
     7 Interceptor     postHandle      ERROR /error status 500 committed true
     8 Interceptor     afterCompletion ERROR /error status 500 exception none
     9 EveryFilter     out ERROR /error status 500
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception
      probe.web.ProbeOops: the plain filter says oops
      its stack frames: 29, its other lines: 2 - none shown
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 2
$ harness/shutdown.sh 19475 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19475 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 4 · dispatch — twice (A/B/A′; C, D, E labelled)

A: `X-Boom: once` — the `OncePerRequestFilter` throws, as the class ships: Boot's JSON 500, 1 ERROR, the ERROR dispatch without it. B: `--probe.once.error=true` — it runs on the ERROR dispatch, throws again: **Tomcat's own HTML 500, 3 ERROR** (`[dispatcherServlet]` ×2, `[Tomcat].[localhost]` "Exception Processing ErrorPage"). A′ = A, line for line. C (labelled): the every-dispatch filter throws → the same page, 3 ERROR. D (labelled): the interceptor throws on every dispatch → the same. E (labelled): D with `/error` excluded from the interceptor → Boot's 500, 1 ERROR (S4 RE-MEASURE 1). RED B's `BoomAll` (S3 AMENDMENT 5) reproduced three ways: B, C, D.

`.r-dispatch.out` · md5 `4ae137a2f004467c61249ba7e4b9ebe4` · 3 of 3

```
A - the anchor on its class path, every hook joined, port 19476: X-Boom: once - the OncePerRequestFilter throws, as the class ships (it skips the ERROR dispatch):
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19476 --spring.main.sources=probe.web.PlainFilter,probe.web.OnceFilter,probe.web.EveryRegistration,probe.web.Hooks,probe.web.ProbeAdvice,probe.web.ProbeRoutes
  listens on: 127.0.0.1:19476 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19476/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Hooks): en_US
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · X-Post-Handle: [%header{x-post-handle}]\n' -H 'X-Boom: once' http://127.0.0.1:19476/probe/ok
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/ok"} 500 · Content-Type: [application/json] · X-Post-Handle: [] · WARN lines it added: 0 · ERROR lines: 1
  the hooks it ran, in the order they printed: 11
     1 EveryFilter     in  REQUEST /probe/ok
     2 PlainFilter     in  REQUEST /probe/ok
     3 OnceFilter      in  REQUEST /probe/ok
     4 PlainFilter     out REQUEST /probe/ok status 200
     5 EveryFilter     out REQUEST /probe/ok status 200
     6 EveryFilter     in  ERROR /error
     7 Interceptor     preHandle       ERROR /error handler BasicErrorController#error
     8 ProbeAdvice     beforeBodyWrite /error body LinkedHashMap
     9 Interceptor     postHandle      ERROR /error status 500 committed true
    10 Interceptor     afterCompletion ERROR /error status 500 exception none
    11 EveryFilter     out ERROR /error status 500
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception
      java.lang.IllegalStateException: the once filter is on fire
      its stack frames: 32, its other lines: 2 - none shown
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 1
$ harness/shutdown.sh 19476 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19476 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the same, its skip switched off for this run (this unit's line: shouldNotFilterErrorDispatch() answers false), port 19477:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19477 --spring.main.sources=probe.web.PlainFilter,probe.web.OnceFilter,probe.web.EveryRegistration,probe.web.Hooks,probe.web.ProbeAdvice,probe.web.ProbeRoutes --probe.once.error=true
  listens on: 127.0.0.1:19477 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19477/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Hooks): en_US
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · X-Post-Handle: [%header{x-post-handle}]\n' -H 'X-Boom: once' http://127.0.0.1:19477/probe/ok
  an HTML page, not the Whitelabel page - its <h1>: HTTP Status 500 – Internal Server Error · 451 characters, not shown · then curl's: 500 · Content-Type: [text/html;charset=utf-8] · X-Post-Handle: [] · WARN lines it added: 0 · ERROR lines: 3
  the hooks it ran, in the order they printed: 8
     1 EveryFilter     in  REQUEST /probe/ok
     2 PlainFilter     in  REQUEST /probe/ok
     3 OnceFilter      in  REQUEST /probe/ok
     4 PlainFilter     out REQUEST /probe/ok status 200
     5 EveryFilter     out REQUEST /probe/ok status 200
     6 EveryFilter     in  ERROR /error
     7 OnceFilter      in  ERROR /error
     8 EveryFilter     out ERROR /error status 500
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception
      java.lang.IllegalStateException: the once filter is on fire
      its stack frames: 32, its other lines: 2 - none shown
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] threw exception
      java.lang.IllegalStateException: the once filter is on fire
      its stack frames: 28, its other lines: 2 - none shown
    ERROR o.a.c.c.C.[Tomcat].[localhost]: Exception Processing [ErrorPage[errorCode=0, location=/error]]
      java.lang.IllegalStateException: the once filter is on fire
      its stack frames: 28, its other lines: 2 - none shown
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 3
$ harness/shutdown.sh 19477 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19477 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, a fresh JVM, port 19476:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19476 --spring.main.sources=probe.web.PlainFilter,probe.web.OnceFilter,probe.web.EveryRegistration,probe.web.Hooks,probe.web.ProbeAdvice,probe.web.ProbeRoutes
  listens on: 127.0.0.1:19476 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19476/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Hooks): en_US
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · X-Post-Handle: [%header{x-post-handle}]\n' -H 'X-Boom: once' http://127.0.0.1:19476/probe/ok
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/ok"} 500 · Content-Type: [application/json] · X-Post-Handle: [] · WARN lines it added: 0 · ERROR lines: 1
  the hooks it ran, in the order they printed: 11
     1 EveryFilter     in  REQUEST /probe/ok
     2 PlainFilter     in  REQUEST /probe/ok
     3 OnceFilter      in  REQUEST /probe/ok
     4 PlainFilter     out REQUEST /probe/ok status 200
     5 EveryFilter     out REQUEST /probe/ok status 200
     6 EveryFilter     in  ERROR /error
     7 Interceptor     preHandle       ERROR /error handler BasicErrorController#error
     8 ProbeAdvice     beforeBodyWrite /error body LinkedHashMap
     9 Interceptor     postHandle      ERROR /error status 500 committed true
    10 Interceptor     afterCompletion ERROR /error status 500 exception none
    11 EveryFilter     out ERROR /error status 500
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception
      java.lang.IllegalStateException: the once filter is on fire
      its stack frames: 32, its other lines: 2 - none shown
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 1
$ harness/shutdown.sh 19476 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19476 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
C (labelled) - every hook joined, port 19478: X-Boom: every - the filter EveryRegistration registers for every dispatch type throws:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19478 --spring.main.sources=probe.web.PlainFilter,probe.web.OnceFilter,probe.web.EveryRegistration,probe.web.Hooks,probe.web.ProbeAdvice,probe.web.ProbeRoutes
  listens on: 127.0.0.1:19478 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19478/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Hooks): en_US
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · X-Post-Handle: [%header{x-post-handle}]\n' -H 'X-Boom: every' http://127.0.0.1:19478/probe/ok
  an HTML page, not the Whitelabel page - its <h1>: HTTP Status 500 – Internal Server Error · 451 characters, not shown · then curl's: 500 · Content-Type: [text/html;charset=utf-8] · X-Post-Handle: [] · WARN lines it added: 0 · ERROR lines: 3
  the hooks it ran, in the order they printed: 2
     1 EveryFilter     in  REQUEST /probe/ok
     2 EveryFilter     in  ERROR /error
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception
      java.lang.IllegalStateException: the every-dispatch filter is on fire
      its stack frames: 27, its other lines: 2 - none shown
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] threw exception
      java.lang.IllegalStateException: the every-dispatch filter is on fire
      its stack frames: 25, its other lines: 2 - none shown
    ERROR o.a.c.c.C.[Tomcat].[localhost]: Exception Processing [ErrorPage[errorCode=0, location=/error]]
      java.lang.IllegalStateException: the every-dispatch filter is on fire
      its stack frames: 25, its other lines: 2 - none shown
D (labelled) - the same JVM: X-Boom: pre-all - the interceptor throws on every dispatch:
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · X-Post-Handle: [%header{x-post-handle}]\n' -H 'X-Boom: pre-all' http://127.0.0.1:19478/probe/ok
  an HTML page, not the Whitelabel page - its <h1>: HTTP Status 500 – Internal Server Error · 451 characters, not shown · then curl's: 500 · Content-Type: [text/html;charset=utf-8] · X-Post-Handle: [] · WARN lines it added: 0 · ERROR lines: 3
  the hooks it ran, in the order they printed: 10
     1 EveryFilter     in  REQUEST /probe/ok
     2 PlainFilter     in  REQUEST /probe/ok
     3 OnceFilter      in  REQUEST /probe/ok
     4 Interceptor     preHandle       REQUEST /probe/ok handler ProbeRoutes#ok
     5 OnceFilter      out REQUEST /probe/ok status 200
     6 PlainFilter     out REQUEST /probe/ok status 200
     7 EveryFilter     out REQUEST /probe/ok status 200
     8 EveryFilter     in  ERROR /error
     9 Interceptor     preHandle       ERROR /error handler BasicErrorController#error
    10 EveryFilter     out ERROR /error status 500
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the interceptor is on fire, every dispatch] with root cause
      java.lang.IllegalStateException: the interceptor is on fire, every dispatch
      its stack frames: over 40, its other lines: 2 - none shown
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] threw exception
      java.lang.IllegalStateException: the interceptor is on fire, every dispatch
      its stack frames: 37, its other lines: 2 - none shown
    ERROR o.a.c.c.C.[Tomcat].[localhost]: Exception Processing [ErrorPage[errorCode=0, location=/error]]
      jakarta.servlet.ServletException: Request processing failed: java.lang.IllegalStateException: the interceptor is on fire, every dispatch
      its stack frames: 38, its other lines: 4 - none shown
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 6
$ harness/shutdown.sh 19478 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19478 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
E (labelled) - D with the error path excluded from the interceptor for this run (this unit's line: excludePathPatterns), port 19471:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19471 --spring.main.sources=probe.web.PlainFilter,probe.web.OnceFilter,probe.web.EveryRegistration,probe.web.Hooks,probe.web.ProbeAdvice,probe.web.ProbeRoutes --probe.exclude=/error
  listens on: 127.0.0.1:19471 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19471/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Hooks): en_US
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · X-Post-Handle: [%header{x-post-handle}]\n' -H 'X-Boom: pre-all' http://127.0.0.1:19471/probe/ok
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/ok"} 500 · Content-Type: [application/json] · X-Post-Handle: [] · WARN lines it added: 0 · ERROR lines: 1
  the hooks it ran, in the order they printed: 10
     1 EveryFilter     in  REQUEST /probe/ok
     2 PlainFilter     in  REQUEST /probe/ok
     3 OnceFilter      in  REQUEST /probe/ok
     4 Interceptor     preHandle       REQUEST /probe/ok handler ProbeRoutes#ok
     5 OnceFilter      out REQUEST /probe/ok status 200
     6 PlainFilter     out REQUEST /probe/ok status 200
     7 EveryFilter     out REQUEST /probe/ok status 200
     8 EveryFilter     in  ERROR /error
     9 ProbeAdvice     beforeBodyWrite /error body LinkedHashMap
    10 EveryFilter     out ERROR /error status 500
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalStateException: the interceptor is on fire, every dispatch] with root cause
      java.lang.IllegalStateException: the interceptor is on fire, every dispatch
      its stack frames: over 40, its other lines: 2 - none shown
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 1
$ harness/shutdown.sh 19471 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19471 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 5 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s six lines, then `exercise/solution/SOLUTION.md`'s four, read from the files and run as written in ONE `env -i` `/bin/bash --noprofile --norc` shell started in this folder (S4.4, R.93). As shipped: `the guard: 500 text/html;charset=utf-8 · ERROR lines: 3`. The solution copies `solution/Guard.java` over the copy (idempotent) and runs the README's last line unchanged (asserted): `the guard: 500 application/json · ERROR lines: 1`. Each leaves the shell in this folder, `en_US` in its log, 0 copies of the copy's token, 19479 free; the diff the solution makes is printed (four lines added).

`.r-exercise.out` · md5 `3acd496457dee74f384c662a7dba72ec` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 6 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/ && cp exercise/Guard.java .harness/mine/Guard.java
  $ mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*" ../Guard.java && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19479 --spring.main.sources=probe.web.Guard > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19479/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -o /dev/null -w '%{http_code} %{content_type}' -H 'X-Kitchen: closed' http://127.0.0.1:19479/customers/Ravi); ../../../harness/shutdown.sh 19479 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the guard: $a · ERROR lines: $(grep -cE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +ERROR ' ../run.log)")
  exit 0 · what they printed:
    the guard: 500 text/html;charset=utf-8 · ERROR lines: 3
  the shell is now in: this unit's folder · the JVM's locale in its log: en_US · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 3 · listening on 19479 now: 0
the solution's 4 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ cp exercise/solution/Guard.java .harness/mine/Guard.java
  $ M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*" ../Guard.java && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19479 --spring.main.sources=probe.web.Guard > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19479/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -o /dev/null -w '%{http_code} %{content_type}' -H 'X-Kitchen: closed' http://127.0.0.1:19479/customers/Ravi); ../../../harness/shutdown.sh 19479 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the guard: $a · ERROR lines: $(grep -cE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[^ ]+ +ERROR ' ../run.log)")
  exit 0 · what they printed:
    the guard: 500 application/json · ERROR lines: 1
  the shell is now in: this unit's folder · the JVM's locale in its log: en_US · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 1 · listening on 19479 now: 0
  the change the solution's Guard.java makes (diff -U0, its hunks):
    @@ -2,0 +3 @@
    +import jakarta.servlet.DispatcherType;
    @@ -30,0 +32,3 @@
    +        if (request.getDispatcherType() != DispatcherType.REQUEST) {
    +            return true;
    +        }
```

## Exercise

**Your turn:** the README's interceptor turns a five hundred into Tomcat's own page. Make it skip the error dispatch, and ask again.
`exercise/README.md` has the commands (copy the anchor and the guard, give the copy a token of its own); its last line, in a subshell,
builds the copy offline, compiles `Guard.java`, starts it on 19479, asks for Ravi with `X-Kitchen: closed`, stops it, waits for its JVM and
prints — as shipped — `the guard: 500 text/html;charset=utf-8 · ERROR lines: 3`. Done is `the guard: 500 application/json · ERROR lines: 1`.
Measured answer: `exercise/solution/`. Run `./receipts.sh` once first on a fresh clone.

## The ledger rows and hand-offs this unit pays

- **The roadmap's U18 line** — "three hooks, one request, the order printed": `order`.
- **S3 CARRIED (brief §LEDGER, S3 AMENDMENT 5):** the filter order (`chain`; `ResolvingFilter` cited from `../c6-unit17/README.md`); an
  interceptor's exception (`throws`: it reaches the advice); `OncePerRequestFilter` and the ERROR dispatch (`dispatch`: S3 RE-MEASURE 10,
  `BoomAll` three ways); whether a resolving filter belongs in the anchor — no: TiffinBox has no filter that throws; Course 10's security
  filter chain (brief ⚑2 loser C, CARRIED).
- **H-17** (C6/17's chip "the order of filters, *Filters vs Interceptors vs Advice*" and its unspoken `OncePerRequestFilter` skip): `chain`,
  `dispatch` — spoken here.
- **C6-31** — glossed at first spoken use: a servlet filter (re-glossed), a filter registration, a handler interceptor, a response-body
  advice, the error dispatch (re-glossed), a once-per-request filter.

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-22) |
|---|---|---|---|
| 1 | 18's exercise by `excludePathPatterns("/error")` | not run | **measured as `dispatch` E: Boot's 500, 1 ERROR** — the exercise keeps the dispatch-type fix; SOLUTION names E |
| 2 | Every 18 capture on its own harness and `16/after` | the probe's `base/` | **all five captures here** |
| 14 | The exercise as viewers run it | end states on sketches | **README then SOLUTION in one `env -i` shell, exit 0 each** (`exercise`, and "Found on the way") |
| S3-10 | `OncePerRequestFilter` skipping the ERROR dispatch | inferred in 17 | **`dispatch` A/B/A′** |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **B is an option, not `-D`** (`--probe.once.error=true`): the same switch, read from Spring's environment (R.8).
- **The `reach` beat is half-captured:** the advice's `beforeBodyWrite` runs for Actuator's health and the interceptor does not; the brief's
  "the advice edits Actuator's body" is not measured (this advice changes nothing), so it is not said.
- **The exercise's interceptor is its own class** (`Guard`, `X-Kitchen: closed`) rather than the harness's `pre-all` header: shipped and done
  lines are the brief's (Tomcat's page, 3 ERROR → Boot's JSON 500, 1 ERROR), measured in one shell.
- **The brief's sketch and this tree agree** on every other line of its unit block: the chain, the order, the committed header, who gets a say,
  the ERROR dispatch's hooks, the 3-ERROR page three ways.

## Found on the way

- **Every new check fails on a planted fault first** (R.65): the checks block runs alone (`cap()` a no-op, the build and the wipe skipped)
  on the published captures with one thing changed per plant (`plants.py`, this unit's scratch folder), the file restored after each —
  **40 plants, 40 stops under /bin/bash 3.2 and 40 under bash 5.3**, each naming its own check; the unplanted files pass before and after
  under both, and the published captures' md5s are unchanged. Thirty-one change a capture (the seven's hash and its logger; each of the four
  chains; the plain filter's reading; the locale; the small answer's header, the long answer's `committed true`, its 2,000, Actuator's
  missing interceptor, the order of `beforeBodyWrite` and `postHandle`; the 409s, an `@ExceptionHandler` line planted under the filter's
  throw, the first pass's status 200, the run's ERROR total; A's ERROR count, B's `OnceFilter in ERROR`, A′, E's interceptor on the error
  dispatch, Tomcat's host logger line; the exercise's two lines, its folder and its diff; an absolute path, an unpinned java line, the raw
  token, a stack frame, an unmasked timestamp, a raw-count file); seven change a shipped file (a bare `wait` in the exercise; Boot 3's error
  key in this README; the spoken exercise line; SOLUTION.md's Done line; `ProbeRoutes`'s 2,000; an order in `PlainRegistration`; the
  `OnceFilter`'s switch name). The SOLUTION's "last line = the README's last line" check runs inside `exercise` and is not reachable in
  checks-only mode.
- **Filters checked on planted inputs inside the script itself**, before any capture: the answer filter, the record filter, the saved-answer
  filter (17's, unchanged), and three new: **the level counts** (a planted log with two hook lines naming the ERROR dispatch, one WARN and one
  ERROR record: 1 and 1 by line shape — a bare `' ERROR '` gives 3, so the check distinguishes, R.120), **the record filter skipping hook
  lines**, and **the hook filter** (a falling running number stops the run).
- **Found while building:** the first plant set failed to load on a check that named `Guard` — the anchor's own `BareArgumentGuard` holds the
  word; the "no harness class in the anchor" check now matches whole words. A level count first expected 2 for the planted log, which holds
  two hook lines that say ERROR: it is 3, and the check now says so.
- **SIGINT**, measured: the script started as a terminal starts its foreground job (`python3` with `SIG_DFL` and `os.setpgrp()`, `env -i`,
  /bin/bash 3.2), SIGINT to its process group 13 s in, during `chain` (4 processes in the group, one of them TiffinBox's JVM): **exit 130**;
  5 s later 0 processes in the group, 0 anywhere running TiffinBox; 19470-19479, 8080, 18425 and 35729 free; no `.r-lock`, no unfinished
  capture run; the published captures unchanged (md5).
- **The exercise as viewers run it**, beyond the capture: README then SOLUTION, then SOLUTION again, in one `env -i` `zsh -f` shell →
  `the guard: 500 text/html;charset=utf-8 · ERROR lines: 3`, then `the guard: 500 application/json · ERROR lines: 1` twice, each exit 0, the
  shell left in `c6-unit18/`; the README's last line alone in an `env -i` `/bin/bash` shell without the exports — its `java` 23.0.1 — ends
  with exit 1 and prints no line; 19479 free after each.

## For unit 19 — and RED

- This unit reads `../c6-unit16/after` only (no change). Section 4's later units inherit: the chain (Boot's four, Tomcat's `WsFilter`), the
  interceptor's reach (not Actuator), the ERROR dispatch's hooks.
- **For RED:** re-run under both bashes, the sealed clone, SIGINT during a capture's JVM; check every WARN/ERROR count against its logger
  (all Tomcat's here, `PageNotFound` Spring MVC's) and by line shape; the chain's four Boot filters by class; the committed header (curl's
  `%header{x-post-handle}`, empty when absent); A′ = A; the exercise under Java 23; that no harness class reached the anchor.
