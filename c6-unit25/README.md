# c6-unit25 — RestClient

Course 6 · Spring Web MVC · Section 5 (Calling Out), its first unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**
(Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5), curl 8.7.1, 2026-10-27. Core Java II's `HttpClient` lesson called a local server
with the JDK's own client, dug the numbers out of a string with `indexOf`, set two timeouts by hand, and learnt that a four-oh-four throws
nothing. This unit does the same job with **Spring's `RestClient`** (spring-web) built from **Boot's builder** (spring-boot-restclient):
the same five files, **the same JDK client underneath on this class path**, records instead of `indexOf` — and a four-oh-four that throws,
two timeouts that are Boot keys now (one of them easy to misspell, without a word), and two things Boot's builder decides that
`RestClient.create()` does not.

**No anchor change (brief ⚑4).** `anchor` is the link to `../c6-unit24/after` — the sessions lesson's frozen tree, `c6-tiffinbox` at
Section 4's end (`diff -rq -x target c6-tiffinbox c6-unit24/after` empty on 2026-10-27, at 9e65d38) — read and copied under
`.harness/anchor`, never built in place; this unit freezes no `after/` and touches no other unit's folder. Everything new is **the
course's harness**, never TiffinBox's:

- `harness/pom.xml` — builds nothing; it names **Boot's RestClient starter** under the anchor's parent (Boot 4.1.1), so that Maven's
  `dependency:build-classpath` lists the jars the starter brings (R.26). The anchor's 61 libraries hold Spring's `RestClient` class
  (spring-web) but not Boot's client modules; of the 31 jars the starter's class path lists, 25 are already in the anchor's `lib/` (by
  name, so by version), 4 are starters with no class at all, and **2 hold classes: `spring-boot-restclient` and `spring-boot-http-client`**
  — those two join the class path, `.harness/xlib/` (61 + 2 = 63). httpclient5 is not on it (asserted): with it, every factory sentence
  below would change (brief READ FIRST 4).
- `harness/probe/web` — outside `com.tiffinbox`, compiled with `-parameters` against the anchor's jars and the two, joined by
  `--spring.main.sources` on the extracted jar's class path: `Calls` (an `ApplicationRunner`: the cases `--probe.cases` names, in that order,
  one `CALL …` line per result; with no cases it does nothing; every case that configures Boot's builder configures a `clone()` of it,
  except `leak`, which shows why), `CallRoutes` (`GET /probe/remote?path=/x`: a route on TiffinBox's server that asks the stub for `/x`
  with a client built once from Boot's builder, and catches nothing), `Row` (a record: one customer of Core Java II's files).
- `harness/stub/Stub.java` — **a stub: a small stand-in server that answers like the real one, on this computer.** The JDK's own HTTP
  server (`com.sun.net.httpserver`, the server Core Java II built TiffinBox on), one source file, no dependency, no build: the JDK's source
  launcher runs it (`java … harness/stub/Stub.java --port=19546 --www=harness/stub/www`). It binds `InetAddress.getLoopbackAddress()`
  (asserted on its pid: `127.0.0.1:19546`) and serves each request on a virtual thread: the files of `www/` (Core Java II's five,
  **byte for byte**: `cmp` and md5 against `../c2-unit28/www`), `/status/<code>`, `…/slow?ms=N` (3000 unless named), `/redirect` (302,
  `Location: /ravi.json`), `/events`, `POST /payments` (201 + `Location`; 422 problem+json for amount 0) and `GET /payments/<id>` (200; 404
  problem+json). **It prints every request whole** — `STUB <method> <uri> headers=[…]`, one `STUB-H name: value` per value of each header,
  `STUB-BODY` when a body came — and then its own answer, `STUB-ANSWER <status> <type> <bytes> bytes`: the witness of what a client sent.
  This unit speaks of the files, `/status`, `/slow` and `/redirect`; `/events` and the payments are for the lessons after it, which copy
  this file byte for byte and compare its md5 with this folder's. Core Java II served the same files with `jwebserver`, which answers GET
  and HEAD only (JDK 25's, measured in the brief's probe) — named here, never run.
- `harness/keys.py` reads a jar's configuration metadata under a prefix (the upload lesson's, byte for byte); `harness/meta.py` one key's
  entry, with its deprecation (since, level, replacement); `harness/shutdown.sh` is POST /shutdown with the token read from its file (the
  filters lesson's, byte for byte).
- The exercise's route is `CallRoutes`, so `exercise/` holds only its README and the solution.

No native build, no Docker and no browser: curl and the stub are the clients and the witness, so nothing here says "a browser" (R.115).
Every URL is `127.0.0.1:<port>`.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 7 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top; a bare `java` on this Mac is 23.0.1.) It **dies** when a capture's md5 differs
from `receipts.md5` (it prints the `DIFFERS` line first). **Start it in a process group of its own** (a terminal's foreground job is one):
two receipts started as background jobs of one shell share a group, and one run's clean-up would stop the other's JVMs (R.94). A run takes
about five minutes: `timeouts` waits out the stub's three seconds several times, three times over.

**Runs of record after BLUE S5 (2026-10-28, this script as committed):** the JDK-version mask (R.151) changed six captures' hashes and
nothing else (each new capture against RED A's copy of the old, the version normalised: 0 lines differ); a development run under
`/bin/bash` 3.2 made the six (293 s, `exercise` = published, unchanged); then **287 s under `./receipts.sh`** (/bin/bash 3.2.57, `env -i`
with HOME and a plain PATH, a process group of its own: exit 0, all 7 captures 3/3 = published, every check passed) and **292 s under
`bash receipts.sh`** (Homebrew bash 5.3.9: exit 0, all 7 = published). The sealed fresh clone was not re-run for this change (BLUE S5 ran
unit 28's, whose tree changed); the clone below is the 10-27 one, on the hashes before the mask.

**Runs of record (2026-10-27, before BLUE S5):** **312 s under `./receipts.sh`** (/bin/bash 3.2.57, `env -i` with HOME and a
plain PATH, this folder, a process group of its own: exit 0, all 7 captures 3/3 = published, every check passed) and **298 s under
`bash receipts.sh`** (Homebrew bash 5.3.9, the same: exit 0, all 7 = published). The hashes were first made by a 3.2 run (312 s) and
reproduced, unchanged, by every run since — under both bashes, before and after the last checks were added. **A sealed fresh clone**, by
the recipe below: this folder's files as committed, beside a `git clone` of the repository (the anchor
link by `readlink`: `../c6-unit24/after`), `.m2-demo` absent at the start, a `file://` copy of 4,440 files made from this folder's
`.m2-demo`; the pre-flight: exit 1, 221 `Downloading from sealed: file://`, 0 from http(s) — **exit 0, all 7 = published, every check
passed, 297 s**; the first two builds said `offline: no`, as a fresh clone's must (the anchor's log: 1,066 downloads, every one from
`file://`; the harness POM's runs with `-q`, which prints none), every capture's build `offline: yes`; **`_remote.repositories` by
repository id: 694 `>sealed=` (in 492 artifact folders), 0 `central`**, no line with another id.

Published hashes: change `f746464baa10f38a848d3c23983923a3` · same `4bf510b34539ae198f701fe5864f6a10` · status `f1d359afaa4aefdd44bc8b3325d3074a` · timeouts `005fe920322306c405f81ebaa328cb5f` · defaults `c8b2f3fa027a5b46425a7003c79ac610` · failure `1ebac860f4d9a5346b49edf3e0cf3130` · exercise `841602d150543aa82a86c3971623caa8`.

### A sealed fresh clone — the recipe (RED S4 #405)

A sealed clone proves that a fresh clone's first build fetches only from a copy you control: `-Duser.home` in the sealed `.mavenrc` (Java on
macOS ignores `$HOME`, so Maven would never read settings kept there), Maven's own `<proxies>` at a refusing port (its resolver ignores
`-Dhttp.proxyHost`), a mirror `*` → `file://`; a pre-flight that refuses to start unless an absent artifact fails having asked `file://`
alone; a post-check counting `_remote.repositories` by repository id (0 `central`). The recipe, step by step:

```bash
S=/tmp/sealed-25                                   # an empty folder of your own; T = your tiffinbox-java clone
mkdir -p "$S/home/.m2" && git clone -q "file://$T" "$S/tiffinbox-java"
rsync -a --exclude _remote.repositories --exclude '*.lastUpdated' --exclude resolver-status.properties "$T/c6-unit25/.m2-demo/" "$S/central/"
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
cd "$S/tiffinbox-java/c6-unit25" && $E ./receipts.sh            # a process group of its own (a terminal's foreground job is one)
# post-check: every artifact's origin, by repository id - each line must say sealed; 0 central
find .m2-demo -name _remote.repositories -exec cat {} + | grep -o '>[^=]*=' | sort | uniq -c
```

## The commands this unit adds

`anchor/README.md` — the anchor's own — gives every line `receipts.sh` runs or derives from (`mvn -B package`, the run line, the extract
line, the class-path line, the readiness line, the Content-Type line) but these fifteen, which are this unit's, each read from the block
below and asserted to be exactly this (on the anchor's port 18431; each capture swaps in its own port):

```bash
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.http.clients.read-timeout=1s
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.http.client.read-timeout=1s
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.http.clients.connect-timeout=1s
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.http.clients.redirects=dont-follow
mvn -o -B -q -Dmaven.repo.local="$M2" -f harness/pom.xml dependency:build-classpath -Dmdep.outputFile="$PWD/.harness/harness.cp"
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:.harness/xlib/*" harness/probe/web/CallRoutes.java harness/probe/web/Calls.java harness/probe/web/Row.java
java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19546 --www=harness/stub/www
for f in harness/stub/www/*.json; do echo "$(md5 -q "$f") $(md5 -q "$C2/www/${f##*/}") ${f##*/}"; done
grep -o 'HTTP2-Settings: [A-Za-z0-9+/=]*' "$C2/README.md"
python3 harness/keys.py .harness/xlib/spring-boot-http-client-4.1.1.jar spring.http.clients.
python3 harness/meta.py .harness/xlib/spring-boot-http-client-4.1.1.jar spring.http.client.read-timeout
curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' 'http://127.0.0.1:18431/probe/remote?path=/status/500'
curl -s -o .harness/prom.txt -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/prometheus
```

The first two are the anchor's run line and its class-path line with `-Duser.language=en -Duser.country=US` after `java` — asserted — and
every java line a capture starts takes the same two options in the same place, the stub's too (`at()`; a last check refuses any capture's
java line without them, and the exercise's). The next four are the pinned class-path line with one Boot key as an option: **A** the read
timeout, plural, as Boot 4.1's metadata spells it; **B** the same key in Boot 3's spelling, the singular (asserted to be A with that one
change); **C** the connect timeout alone; and the redirects key at `dont-follow` (`defaults` C). Every capture adds, after the class-path
line's jar and `lib/*`, `../xlib/*` (the two jars) and `../hc` (the harness), and joins its classes with `--spring.main.sources=` and its
cases with `--probe.cases=` (`hcp()`). The Maven line lists the harness POM's class path into `.harness/harness.cp` (`$PWD`: this folder);
the javac line compiles the harness's three files and nothing else; the stub's line runs `Stub.java` from this folder. The `for` line
prints, for each of this unit's `www/` files, its md5 and the md5 of Core Java II's file of the same name (`$C2` is `../c2-unit28`, Core
Java II's `HttpClient` lesson's folder); the `grep` line reads the `HTTP2-Settings` value Core Java II's README printed. The two metadata
lines read `spring-boot-http-client-4.1.1.jar` (one of the two jars). The remote line is the anchor's Content-Type line at the harness
route (`rq()` swaps the port and the stub's path); the scrape line saves `/actuator/prometheus` to a file, read by a declared filter.

## The repository, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from `../../spring-web-mvc/_research/m2-seed-s5/`
alone — 5,925 files (the seed's 5,926 less Finder's `.DS_Store`; the Section 4 seed + Section 5's 35 files, among them the 4.1.1 client
jars), no `com/tiffinbox`. **Nothing was downloaded** for this unit: every build said `offline: yes`. A fresh clone's `.m2-demo` is empty
(git ignores it): the first two builds — `.harness/pre`, and the harness POM's class path, before any capture — fill it from Maven Central
(or the sealed copy) and say `offline: no`. **At run time** every request goes to `127.0.0.1`, and nothing binds 8080, 18425, 35729 or 19549.

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 32 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/anchor/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) when the script runs, and sent only by `../c5-unit11/curlset.sh` and `harness/shutdown.sh` on curl's standard input, to
TiffinBox — never to the stub. Every capture's raw output is searched for it before masking (0 in all of them), and so are the log of every
JVM that served, **the stub's dump of every run** (0: the token never reached the stub, R.137) and every file this unit ships: 0 everywhere.
The header's name, `X-Shutdown-Token`, is counted too: 0 in every log and every dump. No canary is needed for the one place a remote body
reaches TiffinBox's log (`failure`): the body is the stub's own. The exercise makes a token of its own (`openssl rand -hex 13`), counted
0 times in its log and in its stub's dump, never printed.

## The locale — pinned per JVM, printed, asserted

Every java line this script starts — TiffinBox's and the stub's — carries `-Duser.language=en -Duser.country=US` before `-jar`, `-cp` or
the source file (S4.1, R.100), and every one prints its locale (`Calls`, `CallRoutes`, `Stub`) — `en_US`, asserted in every capture that
starts one (R.124). Receipts run under bash (`#!/bin/bash`), never zsh, where the two options would arrive as one word. The harness's own
lines are ASCII (a JVM under the C locale writes `?` for anything else).

## The folders, the names and the ports

- `.harness/pre` — the anchor built before any capture; `.harness/anchor` — the anchor, copied, with a config tree, built and extracted
  (`change`); `.harness/harness.cp` — the harness POM's class path; `.harness/xlib` — the two jars; `.harness/hc` — the harness's classes;
  `.harness/stub.out` — the stub's dump; `.harness/prom.txt` — the scrape; `.harness/mine` — the exercise's copy.
- **Ports** (brief ⚑1, 19540-19549): TiffinBox 19540-19544, one JVM at a time (`change` 19540-19542, `same` 19540, `status` 19541-19542,
  `timeouts` 19543-19544, `defaults` 19540-19541, `failure` 19542, the exercise 19544); the stub 19546, one per capture; **19549 never
  bound** — `failure` asserts it free, then calls it ("the stub is down"); 19545, 19547 and 19548 unused. All ten, 18425, 8080 and 35729 are
  checked free first; a TiffinBox that listens on 8080, 35729 or 19549 is killed and the script dies. Each TiffinBox is stopped by POST
  /shutdown and its pid waited for; the stub, which has no shutdown route, by its pid (exit 143).

## Masks, filters and hygiene — every one, declared

1. **Paths, the token, the user** (`gsub()`, literals escaped), in every line: the demo token → `[masked: the 32-character token]`; this
   folder → `…`; the folder above → `…/..`; home → `~`; the user name, as a whole word → `<user>`. **The JDK's version in the client's
   `User-Agent`** (R.136): `Java-http-client/<digits and dots>` → `Java-http-client/<version>`; the raw value is asserted to be a
   `Java-http-client/` version and printed once on the terminal, never in a capture. **The JDK's version in Boot's first line** (R.151, RED S5
   #426): ` using Java <digits and dots>` → ` using Java <version>` in every line — the same mask text as units 26-28 — the version printed once
   on the terminal (`(terminal only) the JDK is 25.0.4.1 …`); it was hashed before BLUE S5, so another JDK patch would have changed six of the seven hashes.
   A last check fails if any capture holds `/Users/`,
   `/private/`, `/home/`, `/var/folders/`, a unit number, Boot's process line, a log time, an unmasked timestamp, a thread number, a JDK
   version (a client's, or ` using Java <digits>`), a platform word, a stack frame, `:8080` or `:35729`, a carriage return, a duration, or a command with a URL that is not
   `127.0.0.1`'s.
2. **Spring's error timestamp** (`tsmask`): `"timestamp":"<anything>"` → `"timestamp":"…"`, both forms, in every answer printed and in the
   seven (problem details and Boot's four keys here: the mask runs, and the seven print its count, 0).
3. **The stub's dump** (`sdump`, `sreqs`, `sonly`): **whole** where a capture reads what a client sent (`same`: every line, every header,
   every value, each after a `|`, counted); elsewhere **one line per request** — its method and URI, its header count, and the stub's answer
   (`sreqs`; an answer printed after a later request's line would be printed as "a late answer", never dropped); in `timeouts`, where a call is
   cancelled, **the requests only** (`sonly`) — the stub's answer to a cancelled call lands when its own wait ends, and where that line falls
   in the dump is timing (R.121), so the answers are cut and the cut is said. Each filter is checked on a planted dump first (a header given
   twice, a request with no answer, a late answer).
4. **The scrape** (`promf`): `/actuator/prometheus` kept to `^http_client_requests_seconds_count`, sorted, the kept lines counted; the
   others are the JVM's own meters, whose number moves from run to run (207 and 210 in two runs of the same capture), so their count is a
   bound: "over 150" (R.53). Checked on a planted scrape first.
5. **Log lines** (`logl`, `recs`): from their logger on, as the log prints the logger — `o.s.web.servlet.PageNotFound` is **Spring MVC's**
   (the seven's 405); `o.a.c.c.C.[.[.[/].[dispatcherServlet]` is **Tomcat's** — `org.apache.catalina.core…`, its container for the
   `dispatcherServlet` servlet, shortened by Boot's log pattern; its line reads "Servlet.service() for servlet [dispatcherServlet] … threw
   exception". Boot's first line is cut before ` with PID`. A
   WARN or ERROR record is its level, logger and message, the exception line under it, its stack frames bounded ("over 40") and its other
   lines counted, never shown. **Counted by the log's own line shape** (`<ISO date> LEVEL <pid> --- [`), never a bare `' ERROR'`, which a
   harness line could satisfy (R.120; checked on a planted log first). Every TiffinBox run ends with its WARN and ERROR counts and **the
   number of its lines that say "deprecat"** (log and error stream).
6. **The harness's lines** (`calls`): the `CALL` lines, in the order `Calls` printed them, whole, after its `done` (which must be there).
7. **A′ against A** (`asame`): A's block and A′'s, their labels aside, compared line for line in the capture itself ("yes").
8. **No duration** anywhere: a timeout is judged by the call's outcome — `answered:` or `cancelled:`, the harness's own two words — against a
   stub that waits three seconds, three times the one-second timeout (R.139); no clock is read.
9. **On this Mac**: `lsof` by pid (or by port), the address column alone — never a command name (R.18).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops TiffinBox (`$pid`), the stub (`$spid`) and the
exercise's shell (`$xpid`, with every process under it — `killtree`), sweeps its own process group for any TiffinBox JVM, stub or Maven left,
deletes the capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched. No `wait` in the
script, its checks or the exercise is bare: each names its pid (R.105; a check refuses a bare one); nothing is stopped by name (a check
refuses `pkill` and `killall`). See "Found on the way" for the measured interrupt.

## 1 · change — what joins

The anchor built offline and extracted: **61 libraries**, no Boot RestClient module, no httpclient5. The harness POM's class path: 31
jars, 25 already in `lib/` by name, 6 not — four starters with **0 classes** (a starter is its POM's dependencies) and the two that hold
classes, `spring-boot-restclient` (29) and `spring-boot-http-client` (88), joined: **61 + 2 = 63**. The harness compiled (javac printed
nothing). Whose classes, read off the jars: `RestClient` and `JdkClientHttpRequestFactory` are **spring-web**'s (Framework's);
`RestClientAutoConfiguration` and `RestTemplateBuilder` **spring-boot-restclient**'s; `JdkClientHttpRequestFactoryBuilder` and
`HttpClientSettings` **spring-boot-http-client**'s (R.134). The seven on a fresh JVM of the jar, then on the harness line with the two
jars and the harness joined: `466c20ed…` both times, **the same, byte for byte: 7**, 1 WARN each (`PageNotFound`, the seven's 405). Then
the beans, read off the running context by type: **`restClientBuilder`, scope prototype** — a new `DefaultRestClientBuilder` for every
place that asks (two constructor parameters of `Calls`: two objects, `false`); `restTemplateBuilder` (Boot 4.1.1 still makes one);
`clientHttpRequestFactoryBuilder` = **`JdkClientHttpRequestFactoryBuilder`**; `httpClientSettings`; **no `RestClient` bean and no
`RestTemplate` bean** — Boot hands out the builder, you build the client. The request factory read off three clients (reflection on the
client's own field): Boot's builder bean, `RestClient.create()` and `RestClient.builder()` all get **`JdkClientHttpRequestFactory`** — the
JDK's `HttpClient`, on this class path.

`.r-change.out` · md5 `f746464baa10f38a848d3c23983923a3` · 3 of 3

```
the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline), its jar extracted (the README's line):
$ cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the anchor · offline: yes · exit 0
$ cd .harness/anchor && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
  the anchor's libraries (its extracted lib/): 61 · Boot's RestClient module among them: 0 · httpclient5: 0
what Boot's RestClient starter brings - the harness POM's class path (this unit's line), each jar it lists by name against the anchor's lib/:
$ mvn -o -B -q -Dmaven.repo.local="$M2" -f harness/pom.xml dependency:build-classpath -Dmdep.outputFile="$PWD/.harness/harness.cp"
  built the harness POM's class path · offline: yes · exit 0
  the jars it lists: 31 · in the anchor's lib/ already, by name (the version is in the name): 25 · not:
    spring-boot-starter-restclient-4.1.1.jar · classes: 0 · not joined: no class - a starter is its POM's dependencies
    spring-boot-starter-4.1.1.jar · classes: 0 · not joined: no class - a starter is its POM's dependencies
    spring-boot-starter-logging-4.1.1.jar · classes: 0 · not joined: no class - a starter is its POM's dependencies
    spring-boot-starter-jackson-4.1.1.jar · classes: 0 · not joined: no class - a starter is its POM's dependencies
    spring-boot-restclient-4.1.1.jar · classes: 29 · joined (.harness/xlib)
    spring-boot-http-client-4.1.1.jar · classes: 88 · joined (.harness/xlib)
  the class path the harness runs on: the anchor's 61 libraries + 2 = 63
the harness, compiled against the anchor's own jars and those two - with -parameters (this unit's line):
$ javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:.harness/xlib/*" harness/probe/web/CallRoutes.java harness/probe/web/Calls.java harness/probe/web/Row.java
  exit 0 · what javac printed: 0 lines · its classes: probe/web/CallRoutes.class probe/web/Calls$1.class probe/web/Calls$MenuMissing.class probe/web/Calls.class probe/web/Row.class
whose classes - each read off the one jar on that class path that holds it (unzip -l, by name):
  RestClient · in: spring-web-7.0.9.jar
  JdkClientHttpRequestFactory · in: spring-web-7.0.9.jar
  RestClientAutoConfiguration · in: spring-boot-restclient-4.1.1.jar
  RestTemplateBuilder · in: spring-boot-restclient-4.1.1.jar
  JdkClientHttpRequestFactoryBuilder · in: spring-boot-http-client-4.1.1.jar
  HttpClientSettings · in: spring-boot-http-client-4.1.1.jar
the seven - the anchor, the README's run line (its locale pinned), port 19540, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19540
  listens on: 127.0.0.1:19540 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19540/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19540 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0 · lines that say "deprecat": 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
the seven - the anchor on its class path, the two jars and the harness joined (Calls, CallRoutes; no cases), port 19541, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19541 --spring.main.sources=probe.web.Calls,probe.web.CallRoutes
  listens on: 127.0.0.1:19541 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19541/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19541 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0 · lines that say "deprecat": 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
the lines that moved - the README's run line's seven against the harness line's, masked, line for line:
  lines that differ: 0 · the same, byte for byte: 7 (1 2 3 4 5 6 7)
the client's beans - the same line, the cases beans and factory, port 19542, a fresh JVM (no stub: neither case calls one):
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19542 --spring.main.sources=probe.web.Calls --probe.cases=beans,factory
  listens on: 127.0.0.1:19542 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19542/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Calls): en_US
  the harness's lines (Calls), in the order they printed: 12
    the JVM's locale: en_US
    beans RestClient.Builder: restClientBuilder (scope prototype) -> org.springframework.web.client.DefaultRestClientBuilder
    beans RestTemplateBuilder: restTemplateBuilder (scope singleton) -> org.springframework.boot.restclient.RestTemplateBuilder
    beans ClientHttpRequestFactoryBuilder: clientHttpRequestFactoryBuilder (scope singleton) -> org.springframework.boot.http.client.JdkClientHttpRequestFactoryBuilder
    beans HttpClientSettings: httpClientSettings (scope singleton) -> org.springframework.boot.http.client.HttpClientSettings
    beans RestClient: no bean
    beans RestTemplate: no bean
    beans two injection points, one builder object: false
    factory Boot's builder bean: org.springframework.http.client.JdkClientHttpRequestFactory
    factory RestClient.create(): org.springframework.http.client.JdkClientHttpRequestFactory
    factory RestClient.builder(): org.springframework.http.client.JdkClientHttpRequestFactory
    done
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19542 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19542 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 2 · same — Core Java II's job, through RestClient

Core Java II's five files, md5 for md5 (5 of 5; `customers.json` 307 bytes, as Core Java II's README printed). The stub on
`127.0.0.1:19546`, read off its pid, `en_US`. The job: `retrieve().body(new ParameterizedTypeReference<List<Row>>(){})` — **four `Row`
records**, each with its month (meals a day × price × 30), **month total 24300** — Core Java II's `AsyncCalls` total, with no `indexOf`;
`body(Row.class)` for one file (`/{f}`, `meera.json`). The factory read off three clients again: `JdkClientHttpRequestFactory`. **What the
client sent** — the stub's dump of both requests, whole (18 lines: two requests, seven header lines and an answer each): `connection:
Upgrade, HTTP2-Settings`, `upgrade: h2c`, `http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA` — **equal** to the value Core
Java II's README printed (48 characters each, compared in the receipt), `host`, `user-agent: Java-http-client/<version>` — and **two
`accept-encoding` values, `gzip` and `deflate`**, and **no `Accept` header** (0: `body(...)` into a record or a list sent none).

`.r-same.out` · md5 `4bf510b34539ae198f701fe5864f6a10` · 3 of 3

```
the files - this unit's www/ against Core Java II's (this unit's line):
$ for f in harness/stub/www/*.json; do echo "$(md5 -q "$f") $(md5 -q "$C2/www/${f##*/}") ${f##*/}"; done
  4d31cc0a22001b3e7c32039403f1e169 4d31cc0a22001b3e7c32039403f1e169 customers.json
  9c7a89abebc65ff24084c7dc20334945 9c7a89abebc65ff24084c7dc20334945 meera.json
  aac4c7331ac8d1c6582f98cd75be6e0a aac4c7331ac8d1c6582f98cd75be6e0a priya.json
  17fcfbe710b521778d2df671dcf74cc3 17fcfbe710b521778d2df671dcf74cc3 ravi.json
  8fcb5f742744e02a06c3f06606272b26 8fcb5f742744e02a06c3f06606272b26 sunil.json
  the same md5, file by file: 5 of 5 · customers.json: 307 bytes
the stub - this unit's line, from this folder, port 19546:
$ java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19546 --www=harness/stub/www
  the stub listens on: 127.0.0.1:19546 · loopback only: yes · its locale: en_US
the job - the anchor on its class path, the two jars and the harness joined (Calls), the cases factory and same, port 19540, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19540 --spring.main.sources=probe.web.Calls --probe.cases=factory,same
  listens on: 127.0.0.1:19540 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19540/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Calls): en_US
  the harness's lines (Calls), in the order they printed: 11
    the JVM's locale: en_US
    factory Boot's builder bean: org.springframework.http.client.JdkClientHttpRequestFactory
    factory RestClient.create(): org.springframework.http.client.JdkClientHttpRequestFactory
    factory RestClient.builder(): org.springframework.http.client.JdkClientHttpRequestFactory
    same Row[name=Ravi, mealsPerDay=2, pricePerMeal=120, veg=true] - a month: 7200
    same Row[name=Meera, mealsPerDay=1, pricePerMeal=150, veg=true] - a month: 4500
    same Row[name=Sunil, mealsPerDay=3, pricePerMeal=100, veg=false] - a month: 9000
    same Row[name=Priya, mealsPerDay=1, pricePerMeal=120, veg=true] - a month: 3600
    same rows: 4 - month total: 24300
    same one file, body(Row.class): Row[name=Meera, mealsPerDay=1, pricePerMeal=150, veg=true]
    done
what the client sent, and what the stub answered - the stub's dump of the job's requests:
  the stub's dump since, whole: 18 lines
    | STUB GET /customers.json headers=[Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent]
    | STUB-H accept-encoding: gzip
    | STUB-H accept-encoding: deflate
    | STUB-H connection: Upgrade, HTTP2-Settings
    | STUB-H host: 127.0.0.1:19546
    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
    | STUB-H upgrade: h2c
    | STUB-H user-agent: Java-http-client/<version>
    | STUB-ANSWER 200 application/json 307 bytes
    | STUB GET /meera.json headers=[Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent]
    | STUB-H accept-encoding: gzip
    | STUB-H accept-encoding: deflate
    | STUB-H connection: Upgrade, HTTP2-Settings
    | STUB-H host: 127.0.0.1:19546
    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
    | STUB-H upgrade: h2c
    | STUB-H user-agent: Java-http-client/<version>
    | STUB-ANSWER 200 application/json 73 bytes
  the request for customers.json: Accept headers: 0 · accept-encoding values: gzip deflate · the same headers as meera.json's, by name: yes
the HTTP2-Settings value - Core Java II's README (this unit's line), against the stub's dump:
$ grep -o 'HTTP2-Settings: [A-Za-z0-9+/=]*' "$C2/README.md"
  HTTP2-Settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
  Core Java II's: 48 characters · the stub saw: 48 characters · equal: yes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19540 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19540 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the stub: stopped by its pid · exit 143 · listening on 19546 now: 0 · requests in its dump: 2 · the demo token 0 times · X-Shutdown-Token 0 times
```

## 3 · status — the four-oh-four, and the statuses around it

`week-9.json` (the stub: 404 `text/plain`, 9 bytes) through `retrieve()`: **`HttpClientErrorException$NotFound`, status 404, message
`404 Not Found: "not found"`** — the stub's own body inside the message; its classes up: `NotFound > HttpClientErrorException >
HttpStatusCodeException > RestClientResponseException > RestClientException > NestedRuntimeException`, a `RestClientException`. Core Java
II's `HttpClient` threw nothing on the same status: **`exchange((req, res) -> res.getStatusCode())`** gives that way back — `404 NOT_FOUND`,
no exception, opted into. A **status handler** — code that runs for chosen statuses before the body is read — `onStatus(is4xxClientError, …)`
throws the harness's own `MenuMissing`; `defaultStatusHandler(isError, …)` on a **clone** of the builder: `MenuMissing` for the 404 and the
500, and a later client from another clone gets `NotFound` again. 500 → `HttpServerErrorException$InternalServerError` (its message holds
the stub's JSON); 503 → `$ServiceUnavailable`. **C (labelled)**: the second injected builder configured with a default status handler and
built, then built again — **the later client carries the handler** (`MenuMissing`): a builder is mutable (R.141); configure a `clone()`, or
one builder per client. 0 WARN, 0 ERROR: every exception here was caught by the harness.

`.r-status.out` · md5 `f1d359afaa4aefdd44bc8b3325d3074a` · 3 of 3

```
the stub - this unit's line, port 19546:
$ java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19546 --www=harness/stub/www
  the stub listens on: 127.0.0.1:19546 · loopback only: yes · its locale: en_US
the statuses - the anchor on its class path, the two jars and the harness joined (Calls), five cases, port 19541, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19541 --spring.main.sources=probe.web.Calls --probe.cases=404,exchange,onstatus,default,5xx
  listens on: 127.0.0.1:19541 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19541/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Calls): en_US
  the harness's lines (Calls), in the order they printed: 11
    the JVM's locale: en_US
    404 org.springframework.web.client.HttpClientErrorException$NotFound - status 404 - message: 404 Not Found: "not found"
    404 its classes, up: NotFound > HttpClientErrorException > HttpStatusCodeException > RestClientResponseException > RestClientException > NestedRuntimeException - a RestClientException: true
    exchange /week-9.json -> 404 NOT_FOUND - no exception
    onstatus probe.web.Calls$MenuMissing | message: no menu at /week-9.json, the stub said 404 | cause: none
    default /week-9.json probe.web.Calls$MenuMissing | message: the stub said 404 for /week-9.json | cause: none
    default /status/500 probe.web.Calls$MenuMissing | message: the stub said 500 for /status/500 | cause: none
    default a later client, another clone: org.springframework.web.client.HttpClientErrorException$NotFound
    5xx /status/500 org.springframework.web.client.HttpServerErrorException$InternalServerError - status 500 - message: 500 Internal Server Error: "{"status":500,"from":"stub"}"
    5xx /status/503 org.springframework.web.client.HttpServerErrorException$ServiceUnavailable - status 503 - message: 503 Service Unavailable: "{"status":503,"from":"stub"}"
    done
  the stub's dump since, one line a request (its headers counted - same prints them whole):
    GET /week-9.json · headers: 7 · the stub answered 404 text/plain 9 bytes
    GET /week-9.json · headers: 7 · the stub answered 404 text/plain 9 bytes
    GET /week-9.json · headers: 7 · the stub answered 404 text/plain 9 bytes
    GET /week-9.json · headers: 7 · the stub answered 404 text/plain 9 bytes
    GET /status/500 · headers: 7 · the stub answered 500 application/json 28 bytes
    GET /week-9.json · headers: 7 · the stub answered 404 text/plain 9 bytes
    GET /status/500 · headers: 7 · the stub answered 500 application/json 28 bytes
    GET /status/503 · headers: 7 · the stub answered 503 application/json 28 bytes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19541 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19541 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - one injected builder configured, then built twice, never cloned (the case leak), port 19542, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19542 --spring.main.sources=probe.web.Calls --probe.cases=leak
  listens on: 127.0.0.1:19542 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19542/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Calls): en_US
  the harness's lines (Calls), in the order they printed: 4
    the JVM's locale: en_US
    leak the client it was configured for: probe.web.Calls$MenuMissing
    leak a later client, the same builder: probe.web.Calls$MenuMissing
    done
  the stub's dump since, one line a request:
    GET /week-9.json · headers: 7 · the stub answered 404 text/plain 9 bytes
    GET /week-9.json · headers: 7 · the stub answered 404 text/plain 9 bytes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19542 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19542 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the stub: stopped by its pid · exit 143 · listening on 19546 now: 0 · requests in its dump: 10 · the demo token 0 times · X-Shutdown-Token 0 times
```

## 4 · timeouts — the key's spelling, A/B/A′; C and D labelled

Boot's own metadata (`spring-boot-http-client-4.1.1.jar`): 7 keys under `spring.http.clients.` — **plural** — `connect-timeout` and
`read-timeout` among them, **no default for either**; the singular `spring.http.client.read-timeout` is declared too, **deprecated since
4.0.0** (level not given: the metadata format's default, a warning), its replacement `spring.http.clients.read-timeout`. A **timeout**: a
connect timeout bounds getting the connection; a read timeout bounds the wait for the answer. Against the stub's `/slow?ms=3000` — its
own setting, three seconds, three times the timeout — each a fresh JVM, judged by the outcome line: **A** `--spring.http.clients.read-timeout=1s`
→ **cancelled**: `ResourceAccessException`, message `I/O error on GET request for "http://127.0.0.1:19546/slow": Request cancelled`, cause
`java.net.http.HttpTimeoutException: Request cancelled` (Core Java II's own run said `request timed out`: the words differ); **B** the same
key in Boot 3's spelling, `--spring.http.client.read-timeout=1s` → **answered** `{"slow":true}` — the key changed nothing, **0 WARN and
0 lines that say "deprecat"**; **A′** = A, its `$` line shown, line for line the same; **C (labelled)** `--spring.http.clients.connect-timeout=1s`
alone → answered (connecting worked); **D (labelled)** no key → answered. The stub saw five calls, one per JVM; its answers are cut
(declared above).

`.r-timeouts.out` · md5 `005fe920322306c405f81ebaa328cb5f` · 3 of 3

```
the keys - what Boot's own metadata declares (in spring-boot-http-client-4.1.1.jar, one of the two jars the starter adds; this unit's lines):
$ python3 harness/keys.py .harness/xlib/spring-boot-http-client-4.1.1.jar spring.http.clients.
  spring.http.clients.connect-timeout · default none · Duration
  spring.http.clients.cookie-handling · default none · HttpCookieHandling
  spring.http.clients.imperative.factory · default none · ImperativeHttpClientsProperties$Factory
  spring.http.clients.reactive.connector · default none · ReactiveHttpClientsProperties$Connector
  spring.http.clients.read-timeout · default none · Duration
  spring.http.clients.redirects · default none · HttpRedirects
  spring.http.clients.ssl.bundle · default none · String
  7 keys under spring.http.clients.
$ python3 harness/meta.py .harness/xlib/spring-boot-http-client-4.1.1.jar spring.http.client.read-timeout
  spring.http.client.read-timeout · default none · Duration
    deprecated · since 4.0.0 · level: not given · replacement: spring.http.clients.read-timeout
the stub - this unit's line, port 19546 (its /slow?ms=3000 answers after three seconds):
$ java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19546 --www=harness/stub/www
  the stub listens on: 127.0.0.1:19546 · loopback only: yes · its locale: en_US
A - the anchor on its class path, the two jars and the harness joined (Calls, the case slow), the read timeout at one second, port 19543, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19543 --spring.main.sources=probe.web.Calls --probe.cases=slow --spring.http.clients.read-timeout=1s
  listens on: 127.0.0.1:19543 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19543/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Calls): en_US
  the harness's lines (Calls), in the order they printed: 3
    the JVM's locale: en_US
    slow /slow?ms=3000 cancelled: org.springframework.web.client.ResourceAccessException | message: I/O error on GET request for "http://127.0.0.1:19546/slow": Request cancelled | cause: java.net.http.HttpTimeoutException: Request cancelled
    done
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19543 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19543 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the same, the key in Boot 3's spelling (the singular), port 19544, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19544 --spring.main.sources=probe.web.Calls --probe.cases=slow --spring.http.client.read-timeout=1s
  listens on: 127.0.0.1:19544 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19544/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Calls): en_US
  the harness's lines (Calls), in the order they printed: 3
    the JVM's locale: en_US
    slow /slow?ms=3000 answered: {"slow":true}
    done
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19544 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19544 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, port 19543, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19543 --spring.main.sources=probe.web.Calls --probe.cases=slow --spring.http.clients.read-timeout=1s
  listens on: 127.0.0.1:19543 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19543/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Calls): en_US
  the harness's lines (Calls), in the order they printed: 3
    the JVM's locale: en_US
    slow /slow?ms=3000 cancelled: org.springframework.web.client.ResourceAccessException | message: I/O error on GET request for "http://127.0.0.1:19546/slow": Request cancelled | cause: java.net.http.HttpTimeoutException: Request cancelled
    done
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19543 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19543 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
C (labelled) - the connect timeout alone, at one second, port 19544, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19544 --spring.main.sources=probe.web.Calls --probe.cases=slow --spring.http.clients.connect-timeout=1s
  listens on: 127.0.0.1:19544 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19544/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Calls): en_US
  the harness's lines (Calls), in the order they printed: 3
    the JVM's locale: en_US
    slow /slow?ms=3000 answered: {"slow":true}
    done
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19544 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19544 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
D (labelled) - no timeout key at all, port 19543, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19543 --spring.main.sources=probe.web.Calls --probe.cases=slow
  listens on: 127.0.0.1:19543 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19543/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Calls): en_US
  the harness's lines (Calls), in the order they printed: 3
    the JVM's locale: en_US
    slow /slow?ms=3000 answered: {"slow":true}
    done
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19543 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19543 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the requests the stub saw, one line a request:
    GET /slow?ms=3000 · headers: 7
    GET /slow?ms=3000 · headers: 7
    GET /slow?ms=3000 · headers: 7
    GET /slow?ms=3000 · headers: 7
    GET /slow?ms=3000 · headers: 7
    its answers: cut - after a cancelled call, where its answer lands in the dump is timing
  the stub: stopped by its pid · exit 143 · listening on 19546 now: 0 · requests in its dump: 5 · the demo token 0 times · X-Shutdown-Token 0 times
```

## 5 · defaults — what Boot's builder decides

A **redirect** — an answer that says "ask over there" (302 + `Location`): `/redirect` through **Boot's builder → 200, Ravi's row** (the
client followed it: the stub saw `/redirect`, then `/ravi.json`); through **`RestClient.create()` → 302 `moved`** (not followed — with the
JDK factory, on this class path). An **observation** — Spring's record of one call, its timing and tags, kept by Micrometer and read on
`/actuator/prometheus`: in **one scrape of the same JVM**, the builder's two calls under the template **`uri="/{f}"` (2)** and its redirect
(`uri="/redirect"`, 1); `create()`'s three calls, under `/{name}`, which the stub saw, **nowhere** (2 lines kept). **C (labelled)**
`--spring.http.clients.redirects=dont-follow` → Boot's builder 302 too, and no request for `ravi.json`.

`.r-defaults.out` · md5 `c8b2f3fa027a5b46425a7003c79ac610` · 3 of 3

```
the stub - this unit's line, port 19546 (its /redirect answers 302, Location: /ravi.json):
$ java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19546 --www=harness/stub/www
  the stub listens on: 127.0.0.1:19546 · loopback only: yes · its locale: en_US
both ways in one JVM - the anchor on its class path, the two jars and the harness joined (Calls), the cases redirect and metrics, port 19540, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19540 --spring.main.sources=probe.web.Calls --probe.cases=redirect,metrics
  listens on: 127.0.0.1:19540 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19540/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Calls): en_US
  the harness's lines (Calls), in the order they printed: 5
    the JVM's locale: en_US
    redirect Boot's builder: /redirect -> 200 { "name": "Ravi",  "mealsPerDay": 2, "pricePerMeal": 120, "veg": true  }
    redirect RestClient.create(): /redirect -> 302 moved
    metrics Boot's builder: 2 calls, uri template /{f} - RestClient.create(): 3 calls, uri template /{name}
    done
  the stub's dump since, one line a request:
    GET /redirect · headers: 7 · the stub answered 302 text/plain 5 bytes
    GET /ravi.json · headers: 7 · the stub answered 200 application/json 73 bytes
    GET /redirect · headers: 7 · the stub answered 302 text/plain 5 bytes
    GET /ravi.json · headers: 7 · the stub answered 200 application/json 73 bytes
    GET /ravi.json · headers: 7 · the stub answered 200 application/json 73 bytes
    GET /priya.json · headers: 7 · the stub answered 200 application/json 73 bytes
    GET /priya.json · headers: 7 · the stub answered 200 application/json 73 bytes
    GET /priya.json · headers: 7 · the stub answered 200 application/json 73 bytes
what was observed - one scrape of the same JVM's /actuator/prometheus (this unit's line):
$ curl -s -o .harness/prom.txt -w ' %{http_code}\n' http://127.0.0.1:19540/actuator/prometheus
   200
  kept: 2 of the scrape's lines, by the filter ^http_client_requests_seconds_count, sorted · the others not shown: over 150 (their number moves from run to run: the JVM's own meters)
    http_client_requests_seconds_count{client_name="127.0.0.1",error="none",exception="none",method="GET",outcome="SUCCESS",status="200",uri="/redirect"} 1
    http_client_requests_seconds_count{client_name="127.0.0.1",error="none",exception="none",method="GET",outcome="SUCCESS",status="200",uri="/{f}"} 2
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19540 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19540 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - the redirects key at dont-follow (this unit's line, as an option), the case redirect, port 19541, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19541 --spring.main.sources=probe.web.Calls --probe.cases=redirect --spring.http.clients.redirects=dont-follow
  listens on: 127.0.0.1:19541 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19541/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Calls): en_US
  the harness's lines (Calls), in the order they printed: 4
    the JVM's locale: en_US
    redirect Boot's builder: /redirect -> 302 moved
    redirect RestClient.create(): /redirect -> 302 moved
    done
  the stub's dump since, one line a request:
    GET /redirect · headers: 7 · the stub answered 302 text/plain 5 bytes
    GET /redirect · headers: 7 · the stub answered 302 text/plain 5 bytes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19541 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19541 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the stub: stopped by its pid · exit 143 · listening on 19546 now: 0 · requests in its dump: 10 · the demo token 0 times · X-Shutdown-Token 0 times
```

## 6 · failure — when the other side fails

`19549`, where no stub runs, asserted free; the case `down` there → **`ResourceAccessException`, message `I/O error on GET request for
"http://127.0.0.1:19549/customers.json": null`, cause `java.net.ConnectException: null`** — the JDK's exception carries no message. Then
the harness route, which calls the stub and catches nothing (curl's own `Accept: */*`): the stub's **500** → TiffinBox's answer **500
`application/json`, Boot's four keys** (`timestamp`, `status`, `error`, `path`; no trace, no message, no stub body), and **1 ERROR —
Tomcat's `[dispatcherServlet]` — whose line holds the stub's own words** (`500 Internal Server Error: "{"status":500,"from":"stub"}"`): the
stub's words, in TiffinBox's log; the stub's **404** → TiffinBox's **500** too, 1 ERROR (`404 Not Found: "not found"`) — two statuses for one
request, the stub's answer and TiffinBox's, both printed; the control, `ravi.json` → 200 `text/plain` (the stub's JSON as a string), 0/0.
The stub's dump: 3 requests, the demo token 0 times, `X-Shutdown-Token` 0 times.

`.r-failure.out` · md5 `1ebac860f4d9a5346b49edf3e0cf3130` · 3 of 3

```
the stub - this unit's line, port 19546:
$ java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19546 --www=harness/stub/www
  the stub listens on: 127.0.0.1:19546 · loopback only: yes · its locale: en_US
  19549, where no stub runs: listening 0 (lsof, by port)
a route that calls the stub - the anchor on its class path, the two jars and the harness joined (Calls, CallRoutes), the case down, port 19542, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19542 --spring.main.sources=probe.web.Calls,probe.web.CallRoutes --probe.cases=down
  listens on: 127.0.0.1:19542 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19542/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Calls): en_US
  the JVM's locale (the harness's CallRoutes): en_US
  the harness's lines (Calls), in the order they printed: 3
    the JVM's locale: en_US
    down org.springframework.web.client.ResourceAccessException | message: I/O error on GET request for "http://127.0.0.1:19549/customers.json": null | cause: java.net.ConnectException: null
    done
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' 'http://127.0.0.1:19542/probe/remote?path=/status/500'
  TiffinBox's answer, curl's exit code 0 · WARN lines it added: 0 · ERROR lines: 1:
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/remote"} 500 · Content-Type: [application/json]
  the stub's answer, from its dump:
    GET /status/500 · headers: 7 · the stub answered 500 application/json 28 bytes
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.springframework.web.client.HttpServerErrorException$InternalServerError: 500 Internal Server Error: "{"status":500,"from":"stub"}"] with root cause
      org.springframework.web.client.HttpServerErrorException$InternalServerError: 500 Internal Server Error: "{"status":500,"from":"stub"}"
      its stack frames: over 40, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' 'http://127.0.0.1:19542/probe/remote?path=/week-9.json'
  TiffinBox's answer, curl's exit code 0 · WARN lines it added: 0 · ERROR lines: 1:
  {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/remote"} 500 · Content-Type: [application/json]
  the stub's answer, from its dump:
    GET /week-9.json · headers: 7 · the stub answered 404 text/plain 9 bytes
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.springframework.web.client.HttpClientErrorException$NotFound: 404 Not Found: "not found"] with root cause
      org.springframework.web.client.HttpClientErrorException$NotFound: 404 Not Found: "not found"
      its stack frames: over 40, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' 'http://127.0.0.1:19542/probe/remote?path=/ravi.json'
  TiffinBox's answer, curl's exit code 0 · WARN lines it added: 0 · ERROR lines: 0:
  { "name": "Ravi",  "mealsPerDay": 2, "pricePerMeal": 120, "veg": true  }
   200 · Content-Type: [text/plain;charset=UTF-8]
  the stub's answer, from its dump:
    GET /ravi.json · headers: 7 · the stub answered 200 application/json 73 bytes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 2 · lines that say "deprecat": 0
$ harness/shutdown.sh 19542 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19542 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the stub: stopped by its pid · exit 143 · listening on 19546 now: 0 · requests in its dump: 3 · the demo token 0 times · X-Shutdown-Token 0 times
```

## 7 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s seven lines, then `SOLUTION.md`'s four, in one `env -i` shell (HOME and the PATH this script was started with,
/bin/bash with no profile), started in this folder: as shipped (`T=--spring.http.client.read-timeout=1s`) **`the slow call: 200 · Request
cancelled in its log: 0`**; the solution (`T=--spring.http.clients.read-timeout=1s`, the last line unchanged) **`the slow call: 500 ·
Request cancelled in its log: 1`** — the client's call cancelled after one second, TiffinBox's 500, its one ERROR Tomcat's, its root cause
`java.net.http.HttpTimeoutException: Request cancelled`. Each leaves the shell in this folder, 19544 and 19546 free; both JVMs pin and
print `en_US`; the copy's own token 0 times in its log and its stub's dump.

`.r-exercise.out` · md5 `841602d150543aa82a86c3971623caa8` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 7 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine/xlib && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/
  $ mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
  $ T=--spring.http.client.read-timeout=1s
  $ M="$PWD/.m2-demo" && H="$PWD/harness" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && mvn -o -B -q -Dmaven.repo.local="$M" -f "$H/pom.xml" dependency:build-classpath -Dmdep.outputFile="$PWD/../harness.cp" && rm -f ../xlib/* && tr ':' '\n' < ../harness.cp | while IFS= read -r j; do [ -e "tiffinbox-web/target/extracted/lib/${j##*/}" ] || ! unzip -l "$j" | grep -q '\.class$' || cp "$j" ../xlib/; done && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*:../xlib/*" "$H"/probe/web/*.java && { java -Duser.language=en -Duser.country=US "$H/stub/Stub.java" --port=19546 --www="$H/stub/www" > ../stub.log 2>&1 & } && s=$! && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19544 --spring.main.sources=probe.web.CallRoutes "$T" > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do grep -q '^STUB listening' ../stub.log && [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19544/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -o ../answer.txt -w '%{http_code}' 'http://127.0.0.1:19544/probe/remote?path=/slow'); "$H/shutdown.sh" 19544 secrets/tiffinbox/shutdown-token > /dev/null; kill "$s"; wait "$s"; wait "$p" && echo "the slow call: $a · Request cancelled in its log: $(grep -c '^java.net.http.HttpTimeoutException: Request cancelled$' ../run.log)")
  exit 0 · what they printed:
    the slow call: 200 · Request cancelled in its log: 0
  the shell is now in: this unit's folder · the JVM's locale in its log: en_US (CallRoutes), in the stub's: en_US · the copy's own token in its log: 0 times, in the stub's dump: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19544 now: 0 · on 19546: 0
the solution's 4 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ T=--spring.http.clients.read-timeout=1s
  $ M="$PWD/.m2-demo" && H="$PWD/harness" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && mvn -o -B -q -Dmaven.repo.local="$M" -f "$H/pom.xml" dependency:build-classpath -Dmdep.outputFile="$PWD/../harness.cp" && rm -f ../xlib/* && tr ':' '\n' < ../harness.cp | while IFS= read -r j; do [ -e "tiffinbox-web/target/extracted/lib/${j##*/}" ] || ! unzip -l "$j" | grep -q '\.class$' || cp "$j" ../xlib/; done && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*:../xlib/*" "$H"/probe/web/*.java && { java -Duser.language=en -Duser.country=US "$H/stub/Stub.java" --port=19546 --www="$H/stub/www" > ../stub.log 2>&1 & } && s=$! && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19544 --spring.main.sources=probe.web.CallRoutes "$T" > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do grep -q '^STUB listening' ../stub.log && [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19544/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -o ../answer.txt -w '%{http_code}' 'http://127.0.0.1:19544/probe/remote?path=/slow'); "$H/shutdown.sh" 19544 secrets/tiffinbox/shutdown-token > /dev/null; kill "$s"; wait "$s"; wait "$p" && echo "the slow call: $a · Request cancelled in its log: $(grep -c '^java.net.http.HttpTimeoutException: Request cancelled$' ../run.log)")
  exit 0 · what they printed:
    the slow call: 500 · Request cancelled in its log: 1
  the shell is now in: this unit's folder · the JVM's locale in its log: en_US (CallRoutes), in the stub's: en_US · the copy's own token in its log: 0 times, in the stub's dump: 0 times · WARN lines in its log: 0 · ERROR lines: 1 · listening on 19544 now: 0 · on 19546: 0
  the solution's ERROR record in its log (.harness/mine/run.log), from its logger on:
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.springframework.web.client.ResourceAccessException: I/O error on GET request for "http://127.0.0.1:19546/slow": Request cancelled] with root cause
      java.net.http.HttpTimeoutException: Request cancelled
      its stack frames: over 40, its other lines: 2 - none shown
```

## Exercise

**Your turn:** the README gives the client a one-second read timeout, yet the slow kitchen still makes it wait. Fix the key, and call again.
`exercise/README.md` has the commands (copy the anchor, give the copy a token of its own, `T=--spring.http.client.read-timeout=1s`); its
last line, in a subshell, builds the copy offline, reads the harness POM's class path, joins the two jars, compiles the harness, starts the
stub on 19546 and TiffinBox on 19544 with `CallRoutes` joined and `$T` as an option, calls `GET /probe/remote?path=/slow` with curl, stops
both, waits for both pids and prints — as shipped — `the slow call: 200 · Request cancelled in its log: 0`. Done is `the slow call: 500 ·
Request cancelled in its log: 1` (`T=` spelt as Boot 4.1's metadata spells it, the last line unchanged). Measured answer:
`exercise/solution/`. Run `./receipts.sh` once first on a fresh clone.

## The ledger rows and hand-offs this unit pays

- **X1** "C6 U25 ← C2 U28 (`HttpClient`): Same job, framework ergonomics" — **paid**, each half measured here, Core Java II's numbers
  re-read off disk on 2026-10-27 (its README: `jwebserver -p 8234`, `body bytes: 307`, `week-9.json: 404`, month total `24300`, the
  `HTTP2-Settings` value; its `ApiCall.java`: `connectTimeout(Duration.ofSeconds(2))`, `.timeout(Duration.ofSeconds(5))` — asserted by the
  receipt): the same five files (md5 = Core Java II's, `same`); the same JDK client underneath (the factory read off three clients,
  `change`, `same`); the same `HTTP2-Settings` value (compared with Core Java II's README, `same`); the month total 24300 from records, no
  `indexOf` (`same`); Core Java II's "does not throw on a four-oh-four" turned into an exception, and `exchange()` for Core Java II's way
  (`status`); its two timeouts re-run by outcome (`timeouts`: the connect timeout cannot fire while connecting works — its sentence holds;
  the read timeout cancels the call).
- **The roadmap's "fluent API, status handlers"** — `retrieve()`, `body(…)`, `toEntity`, `exchange`, `onStatus`, `defaultStatusHandler`
  (`same`, `status`, `defaults`).
- **S4 CARRIED, "a local stub on the unit's own ports"** — `harness/stub/Stub.java` on 19546, loopback asserted on its pid (brief ⚑3).
- **C6-31's glosses** for this unit: a stub, a client (re-glossed), a builder bean, a request factory, a status handler, a timeout (connect
  vs read, re-glossed from Core Java II), a redirect, an observation (re-glossed) — each at first spoken use, gated by the builder.
- **The hand-offs this unit must agree with:** the sessions lesson's up-next, "Next: RestClient" — this unit's title (`js.TITLES`, R.63);
  Core Java II's three lines — "Neither has a default" (Boot's metadata: still no default for either key, `timeouts`), "does not throw on a
  four-oh-four" (still true of `HttpClient`; RestClient's `retrieve()` throws, `status`), "Connect timeout would not have saved you" (C:
  answered) — none contradicted.

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-27) |
|---|---|---|---|
| 1 | Every 25 capture on `c6-unit24/after` + the unit's own harness | the probe's `base/`, a copy | **all seven captures here**, on `anchor/` → `../c6-unit24/after` |
| 2 | The stub as this unit's own copy; `www/` md5 = `c2-unit28/www`'s | the probe's `stub/`, `www/` not compared | **`harness/stub/`**; 5 of 5 md5 equal and `cmp` byte for byte (`same`, and a check) |
| 3 | The `HTTP2-Settings` string compared with C2 U28's README by the receipt | equal by eye in the probe | **compared in `same`: 48 characters each, equal: yes** |
| 4 | Apache's factory (httpclient5 joined) | r25ap/r25apj | **not spoken** — httpclient5 is asserted absent; every factory sentence says "on this class path" |
| 13 | The exercise as viewers run it | end states on sketches | **README then SOLUTION in one `env -i` shell, exit 0 each** (`exercise`, and "Found on the way") |
| 14 | `localhost` instead of `127.0.0.1` in a client URL | not run | **not spoken** — every URL is `127.0.0.1:<port>` (a check refuses `localhost` in the harness, the stub and the exercise) |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **`accept-encoding` is two values, not one.** The brief (READ FIRST 4, the probe's dump) has `accept-encoding: gzip`. This stub prints one
  line per value of each header, and the JDK client under Spring's factory sent **two: `gzip` and `deflate`** (`same`). The probe's stub
  printed only the first value of each header (`getFirst`), so the second was a cut nobody counted. The voice says "gzip and deflate"; who
  adds them is not measured here, so it is not said.
- **A stub's answer to a cancelled call is not a witness.** After a read timeout the stub's thread still finishes its wait and writes; where
  that line lands in the dump is timing, so `timeouts` prints the requests only and says why.
- **The scrape's size moves** (207, 210 lines in two runs of one capture: the JVM's own meters): the cut is a bound, "over 150".
- **The builder's two facts, both said**: a new builder per injection point (`change`: scope prototype, two objects) and a mutable builder
  (`status` C: the handler carried into a later client) — the brief's hazard, "say both or neither".
- **Boot 3's spelling** `spring.http.client.read-timeout` is declared in Boot 4.1.1's metadata, deprecated since 4.0.0 with no level
  (a warning, by the format's default) — and still, given as an option, **0 WARN and 0 lines that say "deprecat"**: the metadata warns an
  IDE, not the running application. (The brief: "the replacement read from the metadata" — read, `timeouts`.)
- **The brief's sketch and this tree agree** on every other line of its unit block: two jars beside 61; the beans by name; no `RestClient`
  bean; `JdkClientHttpRequestFactory` three ways; four records, 24300; the h2c offer and no `Accept`; `NotFound`, 404, `404 Not Found: "not
  found"`, the classes up to `RestClientException`; `exchange` → 404, no exception; `onStatus`; the cloned builder's handler; 500/503; the
  three timeout outcomes and B's silence; the redirect flip and `dont-follow`; `/{f}` observed, `create()` not; the remote 500 and 404 as
  TiffinBox's 500, one Tomcat ERROR each with the stub's body; the stub down: `: null`, `ConnectException: null`.

## Found on the way

- **Every check fails on a planted fault first** (R.65): the checks block runs alone (`cap()` dropped, the build and the wipe skipped,
  each run in a session of its own) on the published captures with one thing changed per plant (`plants.py`, this unit's scratch folder),
  the file restored after each — **57 plants, 57 stops under /bin/bash 3.2 and 57 under bash 5.3**, each naming its own check; the unplanted
  files pass before and after under both, and the published captures' md5s are unchanged. They change a capture (61 libraries; 61 + 2 = 63;
  the builder's scope; two injections one object; the missing `RestClient` bean; a factory; the seven's hash; "byte for byte: 7"; a class's
  owner; the md5 5 of 5; 24300; the `HTTP2-Settings` compare; the `Accept` count; a dropped `accept-encoding` value; an unmasked client
  version; the stub's locale; its request count; the 404's message; `exchange`'s "no exception"; the later clone; C's carried handler; the
  503's class; A answered; B cancelled; D cancelled; B's "deprecat" count; A′ against A; A′'s `$` line; the deprecation's "since"; the
  redirect's 200; an observation for `/{name}`; the kept count; an ERROR count; 19549 bound; the down case's cause; the stub's body in the
  ERROR line; a token in the stub's dump; the exercise's two end lines; a port left open; a thread number; a duration; an absolute path; a
  stub line without its locale; a platform word; a raw token) or a shipped file (a bare `wait`; Boot 3's key in SOLUTION.md and in this
  README outside its sections; a builder configured without `clone()`; the stub bound to every interface; Core Java II's file edited;
  `localhost`; a second "browser"; a stop by name; `keys.py` edited; the Done line; SOLUTION's third line).
- **Two plants first went uncaught**, and each is a sharper check now: a dropped `accept-encoding: deflate` line passed, because
  `meera.json`'s request still had one (now the `customers.json` request is compared whole, line for line); a changed `T=` in SOLUTION.md
  passed, because that check lived only inside the exercise capture (now the shipped exercise files are checked at the bottom too).
- **Filters checked on planted inputs inside the script itself**, before any capture: the record filter and the level counts (a harness
  line that ends in "ERROR", one WARN and one ERROR record: 1 and 1 by line shape — a bare `' ERROR'` gives 2), the stub's dump filters (a
  header given twice, a request with no answer, a late answer), the scrape filter, and the masks (two `Java-http-client/` versions, the token).
- **Found while building:** (1) the harness's `CALL` lines first printed `?` for `·`: a JVM started under the C locale writes ASCII — the
  harness's lines are ASCII now. (2) The scrape's line count moved between runs (207, 210): a bound now. (3) The stub's answer to a cancelled
  call landed at a different place in the dump from run to run: cut in `timeouts`, and said. (4) The first plant run stopped the author's
  own tool shell: the checks' `sweep()` (correctly) killed every process of its process group whose command line named the stub — and the
  plant runner had started them in the tool shell's group, whose own command line held the plant text. The runner now starts each check in a
  session of its own (R.94's rule, met the hard way); no other process was touched, and every planted file was restored (the published md5s
  checked). (5) A planted check's `| head -1` made awk report a write error: the filter's output is read into a variable now (R.96).
- **SIGINT**, measured: the script started as a terminal starts its foreground job (`python3` with `SIG_DFL` and `os.setpgrp()`, `env -i`,
  /bin/bash 3.2), SIGINT to its process group during `same`, while the stub and a TiffinBox JVM ran (5 processes in the group): **exit 130**;
  5 s later 0 processes in the group; 19540-19549, 8080, 18425 and 35729 free; no `.r-lock`, no unfinished capture run; the published
  captures unchanged (md5).
- **The exercise as viewers run it**, beyond the capture: README then SOLUTION in one `env -i` shell; the SOLUTION's `T=` lives in that
  shell, and a new shell needs SOLUTION's whole block (it repeats the exports and sets `T`). Both JVMs are subshell jobs waited by pid; 19544
  and 19546 free after each run.

## For RED

- This unit reads `../c6-unit24/after` only (no change), and ships the section's stub: **26 and 27 copy `harness/stub/Stub.java` byte for
  byte** and compare its md5 with this folder's (`42b656ddba1e9f80107495c65dacc975`); its routes beyond this unit's (`/events`, the payments) are shipped,
  unspoken here — 26's and 27's captures measure them.
- **Re-check:** both bashes 3/3, the sealed clone (`central` 0 by repository id), SIGINT during a capture's JVM with the stub running; every
  "sent / not sent" line against the stub's dump (`same`: two `accept-encoding` values, no `Accept`, the `HTTP2-Settings` equal to Core
  Java II's); the `User-Agent` mask (`Java-http-client/<version>`, the raw value on the terminal only); the "observed / not observed" pair in
  one scrape (`defaults`: `/{f}` 2, `/{name}` absent); A/B judged by the outcome words (`answered:` / `cancelled:`), never a clock; B's
  0 WARN and 0 "deprecat" lines; that every capture but `leak` configures a clone of the builder; the remote body inside Tomcat's ERROR line
  (`failure`) said as the stub's words in TiffinBox's log; 19549 free before the `down` case; the exercise under Java 23 (refused at
  compile), with `JAVA_HOME` unset (Homebrew's 26), and twice in one shell; that no harness class reached the anchor; the 0/0 counts by line
  shape; Boot 3's client key only where the lesson needs it (R.138).
