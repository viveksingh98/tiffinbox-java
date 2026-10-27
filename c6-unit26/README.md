# c6-unit26 — HTTP Interface Clients: @HttpExchange

Course 6 · Spring Web MVC · Section 5 (Calling Out), its second unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**
(Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5), curl 8.7.1, 2026-10-27. TiffinBox wants to charge each customer's month. This
unit writes the payment client as **one Java interface** — a method per call, Spring's `@HttpExchange` annotations for the paths — and
**no implementation at all**: Spring builds the object that answers for it at startup, a **JDK dynamic proxy** (the kind Course 4 opened,
`java.lang.reflect.Proxy`), and Boot points it at the payment service from one key of its **service group**. The payment service is the
stub; no real one is named or called.

**No anchor change (brief ⚑4).** `anchor` is the link to `../c6-unit24/after` — the sessions lesson's frozen tree, `c6-tiffinbox` at
Section 4's end (`diff -rq -x target c6-tiffinbox c6-unit24/after` empty on 2026-10-27, at `a2bafb0`) — read and copied under
`.harness/anchor`, never built in place; this unit freezes no `after/` and touches no other unit's folder. Everything new is **the
course's harness**, never TiffinBox's:

- `harness/pom.xml` — builds nothing; it names **Boot's RestClient starter** under the anchor's parent (Boot 4.1.1), so that Maven's
  `dependency:build-classpath` lists the jars it brings (R.26). As in the RestClient lesson: 31 jars, 25 already in the anchor's `lib/`,
  4 starters with no class, **2 joined — `spring-boot-restclient` and `spring-boot-http-client`** (61 + 2 = 63). Spring's HTTP interface
  client is spring-web's (already among the 61); Boot's service groups live in those two jars. httpclient5 is not on the class path
  (asserted), so the JDK's `HttpClient` is the request factory underneath (the RestClient lesson's measurement, cited, not repeated).
- `harness/probe/web` — outside `com.tiffinbox`, compiled with **`-parameters`** (`@PathVariable String id` is named by its parameter,
  S2.16) against the anchor's jars and the two, joined by `--spring.main.sources` on the extracted jar's class path:
  **`Payments`** (the interface: `@HttpExchange("/payments")`; `@PostExchange Payment pay(@RequestBody Charge)`; `@PostExchange
  ResponseEntity<Payment> payForEntity(…)`; `@GetExchange("/{id}") Payment find(@PathVariable String id)`; `@GetExchange("/slow") String
  slow()`), **`Charge`** and **`Payment`** (records), **`PaymentConfig`** (one line: `@ImportHttpServices(group = "payments", types =
  Payments.class)` — spring-web 7.0.9's, `org.springframework.web.service.registry`), **`Pays`** (an `ApplicationRunner`: the cases
  `--probe.cases` names, one `PAY …` line each; with no cases it does nothing), **`PayRoutes`** (`GET /probe/pay`: pays Ravi's month through
  the interface and catches nothing — the exercise's route).
- `harness/stub/` — **the RestClient lesson's stub, copied byte for byte**: `Stub.java` md5 `42b656ddba1e9f80107495c65dacc975` =
  `../c6-unit25/harness/stub/Stub.java`'s, and its five `www/` files (asserted at the top of `receipts.sh`, and shown in `interface`: 6 of
  6). **No route added**: its `POST /payments` (201 + `Location`; 422 problem+json for `"amount":0`), `GET /payments/<id>` (200; 404
  problem+json) and `…/slow` (three seconds unless `?ms=` names another wait) were shipped in the RestClient lesson for this one. It binds
  `InetAddress.getLoopbackAddress()` (asserted on its pid: `127.0.0.1:19556`) and prints every request whole — the witness of what the
  client sent. **A stub** is a small stand-in server that answers like the real one, on this computer.
- `harness/aot-app/` — **a five-class application of its own** (`App`, `PaymentConfig`, `Payments`, `Charge`, `Payment` in `probe.aot`), its
  own POM (the anchor's parent, the RestClient starter, `process-aot` bound): the anchor and the harness cannot be processed ahead of time
  together, because the harness joins TiffinBox only at run time. Built from a copy (`.harness/aot`), offline; no web server, no port.
- `harness/hints.py` reads the `reachability-metadata.json` that `process-aot` writes (its JDK-proxy hints, and one type's entry);
  `harness/keys.py` (the upload lesson's, byte for byte), `harness/meta.py` (the RestClient lesson's, byte for byte, unused by a capture
  here) and `harness/shutdown.sh` (the filters lesson's, byte for byte).

**Two types named `HttpExchange` (R.146).** The stub's code uses **the JDK server's `com.sun.net.httpserver.HttpExchange`** (module
`jdk.httpserver` — the server Course 6 put on its slide in the servlet section: "HttpServer, HttpExchange, HttpHandler"); the lesson's
subject is **Spring's `@HttpExchange`** (`org.springframework.web.service.annotation`, spring-web). `proxy` reads both off the running JVM
(an annotation from `spring-web-7.0.9.jar`; a type from module `jdk.httpserver`); every capture and every slide that shows both says which,
by package.

No native build, no Docker and no browser: curl and the stub are the clients and the witness, so nothing here says "a browser" (R.115).
**"Ahead of time" is said of the AOT app on the JVM (`-Dspring.aot.enabled=true`), never "in the binary":** no native image of a client
was built (brief ⚑4 loser A, CARRIED). Every URL is `127.0.0.1:<port>`.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 7 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top; a bare `java` on this Mac is 23.0.1.) It **dies** when a capture's md5 differs
from `receipts.md5` (it prints the `DIFFERS` line first). **Start it in a process group of its own** (a terminal's foreground job is one):
two receipts started as background jobs of one shell share a group, and one run's clean-up would stop the other's JVMs (R.94).

**Runs of record (2026-10-27, this script as committed):** **228 s under `./receipts.sh`** (/bin/bash 3.2.57, `env -i` with HOME and a
plain PATH, this folder, a session — so a process group — of its own: exit 0, all 7 captures 3/3 = published, every check passed) and
**229 s under `bash receipts.sh`** (Homebrew bash 5.3.9, the same: exit 0, all 7 = published). The hashes were first made by a 3.2 run and
reproduced, unchanged, by every run since, under both bashes. **A sealed fresh clone**, by the recipe below: a `git clone` of the
repository at `a2bafb0` with this folder's files beside it (the `anchor` link by `readlink`: `../c6-unit24/after`), `.m2-demo` absent at
the start, a `file://` copy of 4,440 files made from this folder's `.m2-demo`; the pre-flight: exit 1, 221 `Downloading from sealed:
file://`, 0 from http(s) — **exit 0, all 7 = published, every check passed, 231 s**; the three builds before the captures said `offline:
no`, as a fresh clone's must (the anchor's log: 533 downloads, the AOT app's: 19, every one from `file://`; the harness POM's runs with
`-q`, which prints none), every capture's build `offline: yes`; **`_remote.repositories` by repository id: 713 `>sealed=` (in 504
artifact folders), 0 `central`**, no line with another id.

Published hashes: interface `cf0a201687b189a28e3c3d55a061732d` · proxy `c1f65cdf35858aab07e3d5f2f8ea721c` · calls `473f6d7b472f8a3e85fe0e601f5bd3f2` · group `78694faea587c3d5614b27655bc02488` · aot `603c9317f4f6f015235bd1d8a1eee8a9` · ways `d86df4e2d7ebd6baf99826e915f6111f` · exercise `3b6a993aee34df472c51db1cf37aa216`.

### A sealed fresh clone — the recipe (RED S4 #405, fixed)

`-Duser.home` in the sealed `.mavenrc` (Java on macOS ignores `$HOME`, so Maven would never read settings kept there), Maven's own
`<proxies>` at a refusing port (its resolver ignores `-Dhttp.proxyHost`), a mirror `*` → `file://`; a pre-flight that refuses to start
unless an absent artifact fails having asked `file://` alone; a post-check counting `_remote.repositories` by repository id (0 `central`):

```bash
S=/tmp/sealed-26                                   # an empty folder of your own; T = your tiffinbox-java clone
mkdir -p "$S/home/.m2" && git clone -q "file://$T" "$S/tiffinbox-java"
rsync -a --exclude _remote.repositories --exclude '*.lastUpdated' --exclude resolver-status.properties "$T/c6-unit26/.m2-demo/" "$S/central/"
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
cd "$S/tiffinbox-java/c6-unit26" && $E ./receipts.sh            # a process group of its own (a terminal's foreground job is one)
# post-check: every artifact's origin, by repository id - each line must say sealed; 0 central
find .m2-demo -name _remote.repositories -exec cat {} + | grep -o '>[^=]*=' | sort | uniq -c
```

## The commands this unit adds

```bash
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.http.serviceclient.payments.base-url=http://127.0.0.1:19556
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.http.serviceclient.payments.base-url=http://127.0.0.1:19556 --spring.http.serviceclient.payments.read-timeout=1s
mvn -o -B -q -Dmaven.repo.local="$M2" -f harness/pom.xml dependency:build-classpath -Dmdep.outputFile="$PWD/.harness/harness.cp"
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:.harness/xlib/*" harness/probe/web/Charge.java harness/probe/web/PayRoutes.java harness/probe/web/Payment.java harness/probe/web/PaymentConfig.java harness/probe/web/Payments.java harness/probe/web/Pays.java
java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19556 --www=harness/stub/www
for f in Stub.java www/customers.json www/meera.json www/priya.json www/ravi.json www/sunil.json; do echo "$(md5 -q "harness/stub/$f") $(md5 -q "$S25/$f") $f"; done
sed -n '/^@HttpExchange/,$p' harness/probe/web/Payments.java
grep -n '^@' harness/probe/web/PaymentConfig.java
grep -n 'HttpExchange' harness/stub/Stub.java
python3 harness/keys.py .harness/xlib/spring-boot-http-client-4.1.1.jar spring.http.serviceclient
javap -cp .harness/xlib/spring-boot-http-client-4.1.1.jar org.springframework.boot.http.client.autoconfigure.HttpClientProperties org.springframework.boot.http.client.autoconfigure.HttpClientSettingsProperties
mvn -o -B -Dmaven.repo.local="$M2" clean package
grep -n 'getClient' target/spring-aot/main/sources/probe/aot/Payments__BeanDefinitions.java
python3 ../../harness/hints.py target/spring-aot/main/resources/META-INF/native-image/probe.aot/aot-app/reachability-metadata.json probe.aot.Charge probe.aot.Payment probe.aot.Payments
java -Duser.language=en -Duser.country=US -jar target/aot-app-1.0.0.jar --spring.http.serviceclient.payments.base-url=http://127.0.0.1:19556
java -Duser.language=en -Duser.country=US -Dspring.aot.enabled=true -jar target/aot-app-1.0.0.jar --spring.http.serviceclient.payments.base-url=http://127.0.0.1:19556
curl -s -o .harness/prom.txt -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/prometheus
```

`anchor/README.md` — the anchor's own — gives five lines `receipts.sh` runs or derives from (`mvn -B package`, the run line, the extract
line, the class-path line, the readiness line); the nineteen above are this unit's, each read from this block and asserted to be exactly
this (on the anchor's port 18431; each capture swaps in its own port). The first two are the anchor's run and class-path lines with
`-Duser.language=en -Duser.country=US` after `java` — asserted — and every java line a capture starts takes the same two options in the same
place, the stub's and the AOT app's too (a last check refuses any capture's java line without them, and the exercise's). The next two are
the pinned class-path line with **the group's base URL** (`--spring.http.serviceclient.payments.base-url=http://127.0.0.1:19556`), then
with **the group's own read timeout** too (asserted to be exactly that). Every capture adds, after the class-path line's jar and `lib/*`,
`../xlib/*` (the two jars) and `../hc` (the harness), and joins its classes with `--spring.main.sources=` and its cases with
`--probe.cases=` (`hcp()`). The `for` line prints, for the stub and its five files, this folder's md5 and the RestClient lesson's (`$S25` is
`../c6-unit25/harness/stub`). `sed`, `grep` and `grep` print the interface, the configuration's annotations and the stub's own
`HttpExchange` line. `keys.py` and `javap` read `spring-boot-http-client-4.1.1.jar`. The AOT app's lines run from `.harness/aot` (the copy):
its build, the generated line, its hints, then its jar on the JVM and with `-Dspring.aot.enabled=true` (asserted to be the JVM line with
that one option). The scrape line saves `/actuator/prometheus` to a file, read by a declared filter.

## The repository, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from `../../spring-web-mvc/_research/m2-seed-s5/`
alone — 5,925 files (the seed's 5,926 less Finder's `.DS_Store`), no `com/tiffinbox`. **Nothing was downloaded** for this unit: every
build said `offline: yes`, and the AOT app's build — `process-aot` and the repackage included — added **0 files** to `.m2-demo` (`aot`).
A fresh clone's `.m2-demo` is empty (git ignores it): the first three builds — `.harness/pre`, the harness POM's class path and
`.harness/aot-pre`, before any capture — fill it from Maven Central (or the sealed copy) and say `offline: no`. **At run time** every
request goes to `127.0.0.1`, and nothing binds 8080, 18425, 35729 or 19559.

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 32 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/anchor/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) when the script runs, and sent only by `../c5-unit11/curlset.sh` and `harness/shutdown.sh` on curl's standard input, to
TiffinBox — never to the stub. Every capture's raw output is searched for it before masking (0 in all of them), and so are the log of
every JVM that ran (TiffinBox's and the AOT app's), **the stub's dump of every run** (0: the token never reached the stub, R.137) and every
file this unit ships: 0 everywhere. The header's name, `X-Shutdown-Token`, is counted too: 0 in every log and every dump. No remote body
reaches TiffinBox's log in this unit's captures but the exercise's, and there the ERROR line holds the JDK client's words, not the stub's.
The exercise makes a token of its own (`openssl rand -hex 13`), counted 0 times in its log and its stub's dump, never printed.

## The locale — pinned per JVM, printed, asserted

Every java line this script starts — TiffinBox's, the stub's and the AOT app's — carries `-Duser.language=en -Duser.country=US` right after
`java` (S4.1, R.100), and every one prints its locale (`Pays`, `PayRoutes`, `App`, `Stub`) — `en_US`, asserted in every capture that
starts one (R.124). Receipts run under bash (`#!/bin/bash`), never zsh, where the two options would arrive as one word.

## The folders, the names and the ports

- `.harness/pre`, `.harness/aot-pre` — the anchor and the AOT app built before any capture; `.harness/anchor` — the anchor, copied, with a
  config tree, built and extracted (`interface`); `.harness/harness.cp`, `.harness/xlib`, `.harness/hc` — the harness POM's class path, the
  two jars, the harness's classes; `.harness/aot` — the AOT app's copy, built in `aot`; `.harness/stub.out` — the stub's dump;
  `.harness/prom.txt` — the scrape; `.harness/mine` — the exercise's copy.
- **The bean's name has a `#` in it** — `payments#probe.web.Payments` (the group, `#`, the interface): quoted wherever it is printed.
- **Ports** (brief ⚑1, 19550-19559): TiffinBox 19550-19554, one JVM at a time (`interface` 19550-19551, `proxy` 19552, `calls` 19553,
  `group` 19550-19551, `ways` 19552-19553, the exercise 19554); the stub 19556, one per run that needs one (`ways` starts a fresh one for A,
  B and A′, so each starts again at `pay-1`); **19559 never bound** (asserted free, `ways`); the AOT app has no server and no port; 19555,
  19557 and 19558 unused. All ten, 18425, 8080 and 35729 are checked free first; a TiffinBox that listens on 8080, 35729 or 19559 is killed and
  the script dies. Each TiffinBox is stopped by POST /shutdown and its pid waited for; the stub, which has no shutdown route, by its pid
  (exit 143); the AOT app exits on its own (exit 0), its pid waited for.

## Masks, filters and hygiene — every one, declared

1. **Paths, the token, the user** (`gsub()`, literals escaped), in every line: the demo token → `[masked: the 32-character token]`; this
   folder → `…`; the folder above → `…/..`; home → `~`; the user name, as a whole word → `<user>`. **The JDK's version in the client's
   `User-Agent`** (R.136): `Java-http-client/<digits and dots>` → `Java-http-client/<version>`, the raw value printed once on the terminal.
   **A JDK proxy class's number**: `$Proxy<digits>` → `$Proxy<n>` (it moves with the class path — `$Proxy84` in TiffinBox's JVM, another
   number in the AOT app's), the raw class name printed once on the terminal; CGLIB's `$$SpringCGLIB$$<digits>` → `$$SpringCGLIB$$<n>`. A
   last check fails if any capture holds `/Users/`, `/private/`, `/home/`, `/var/folders/`, a unit number, Boot's process line, a log time,
   an unmasked timestamp, a thread number, a client's JDK version, a proxy number, a platform word, a stack frame, `:8080` or `:35729`, a
   carriage return, a duration, or a command with a URL that is not `127.0.0.1`'s. (Boot's first line keeps "using Java 25.0.4.1": the
   JDK this unit is verified on, which `receipts.sh` requires.)
2. **Spring's error timestamp** (`tsmask`): both forms → `…`, in every answer printed and in the seven (the mask runs; the seven print its
   count, 0).
3. **The stub's dump** (`sdump`, `sreqs`, `sonly`): **whole** where a capture reads what a client sent (`calls`: every line, every header,
   every value, every body, each after a `|`, counted — 54 lines); elsewhere **one line per request** with its header count and the stub's
   answer (`sreqs`); in `group`, where a call is cancelled, **the requests only** (`sonly`) — the stub's answer to a cancelled call lands when
   its own wait ends, and where that line falls is timing, so the answers are cut and the cut is said. Each filter is checked on a planted
   dump first (a header given twice, a body, a request with no answer, a late answer).
4. **The scrape** (`promf`): `/actuator/prometheus` kept to `^http_client_requests_seconds_count`, sorted, the kept lines counted; the others
   are the JVM's own meters, whose number moves from run to run, so their count is a bound: "over 150" (R.53).
5. **Log lines** (`logl`, `recs`): from their logger on — `o.s.web.servlet.PageNotFound` is **Spring MVC's** (the seven's 405);
   `o.a.c.c.C.[.[.[/].[dispatcherServlet]` is **Tomcat's** (its container for the `dispatcherServlet`, shortened by Boot's log pattern).
   A WARN or ERROR record is its level, logger and message, the exception line under it, its stack frames bounded ("over 40") and its other
   lines counted, never shown. **Counted by the log's own line shape**, never a bare `' ERROR'` (checked on a planted log first). Every
   TiffinBox run ends with its WARN and ERROR counts and the number of its lines that say "deprecat".
6. **The harness's lines** (`pays`): the `PAY` lines, in the order `Pays` printed them, whole, after its `done` (which must be there); the AOT
   app's `AOT` lines, whole.
7. **javap** (`group`): its 22 lines kept to the two class lines and their setters (8), the cut counted.
8. **A′ against A** (`asame`): A's block and A′'s, their labels aside, compared line for line in the capture itself ("yes").
9. **No duration** anywhere: a timeout is judged by the call's outcome — `answered:` or `cancelled:`, the harness's own two words —
   against a stub that waits three seconds, three times the one-second timeout (R.139); no clock is read.
10. **On this Mac**: `lsof` by pid (or by port), the address column alone — never a command name (R.18).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops TiffinBox or the AOT app (`$pid`), the stub
(`$spid`) and the exercise's shell (`$xpid`, with every process under it — `killtree`), sweeps its own process group for any TiffinBox
JVM, AOT app, stub or Maven left, deletes the capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published
captures are untouched. No `wait` is bare: each names its pid (R.105; a check refuses a bare one); nothing is stopped by name (a check
refuses `pkill` and `killall`). See "Found on the way" for the measured interrupt.

## 1 · interface — one interface, no implementation

The anchor built offline and extracted: **61 libraries**, no Boot RestClient module, no httpclient5. The harness POM's class path, as
in the RestClient lesson: 31 jars, 25 already in `lib/`, four starters with **0 classes**, and `spring-boot-restclient` (29 classes) and
`spring-boot-http-client` (88) joined: **61 + 2 = 63**. The harness compiled with `-parameters` (javac printed nothing). The stub against
the RestClient lesson's: **6 of 6 md5 equal**, no route added. **The interface, whole**: `@HttpExchange("/payments")` on the type, a
method per call (`@PostExchange` twice, `@GetExchange` twice) — **4 methods, and no class in the harness implements it** (also a check
on every harness source: no `implements … Payments`, no `new Payments(`). **The configuration's one line**:
`@ImportHttpServices(group = "payments", types = Payments.class)`. Beside it, **the stub's own `HttpExchange`** — line 89 of `Stub.java`,
`void send(HttpExchange ex, …)`: the JDK server's type (`import module jdk.httpserver;`), not Spring's. Whose classes, read off the jars
(R.134): `org.springframework.web.service.annotation.HttpExchange`, `ImportHttpServices`, `HttpServiceProxyFactory`, `RestClientAdapter` —
**spring-web**'s; `HttpServiceClientAutoConfiguration` **spring-boot-restclient**'s; `HttpServiceClientProperties`
**spring-boot-http-client**'s. The seven on a fresh JVM of the jar, then on the harness line with `PaymentConfig`, `Pays` and
`PayRoutes` joined and the group's base URL: `466c20ed…` both times, **the same, byte for byte: 7**, 1 WARN each (`PageNotFound`, Spring
MVC's, the seven's 405).

`.r-interface.out` · md5 `cf0a201687b189a28e3c3d55a061732d` · 3 of 3

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
$ javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:.harness/xlib/*" harness/probe/web/Charge.java harness/probe/web/PayRoutes.java harness/probe/web/Payment.java harness/probe/web/PaymentConfig.java harness/probe/web/Payments.java harness/probe/web/Pays.java
  exit 0 · what javac printed: 0 lines · its classes: probe/web/Charge.class probe/web/PayRoutes.class probe/web/Payment.class probe/web/PaymentConfig.class probe/web/Payments.class probe/web/Pays.class
the stub - this folder's copy against the RestClient lesson's ($S25), md5 for md5 (this unit's line):
$ for f in Stub.java www/customers.json www/meera.json www/priya.json www/ravi.json www/sunil.json; do echo "$(md5 -q "harness/stub/$f") $(md5 -q "$S25/$f") $f"; done
  42b656ddba1e9f80107495c65dacc975 42b656ddba1e9f80107495c65dacc975 Stub.java
  4d31cc0a22001b3e7c32039403f1e169 4d31cc0a22001b3e7c32039403f1e169 www/customers.json
  9c7a89abebc65ff24084c7dc20334945 9c7a89abebc65ff24084c7dc20334945 www/meera.json
  aac4c7331ac8d1c6582f98cd75be6e0a aac4c7331ac8d1c6582f98cd75be6e0a www/priya.json
  17fcfbe710b521778d2df671dcf74cc3 17fcfbe710b521778d2df671dcf74cc3 www/ravi.json
  8fcb5f742744e02a06c3f06606272b26 8fcb5f742744e02a06c3f06606272b26 www/sunil.json
  the same md5, file by file: 6 of 6 · routes this unit adds to it: 0
the interface - the whole of it, from its annotation on (this unit's line):
$ sed -n '/^@HttpExchange/,$p' harness/probe/web/Payments.java
  @HttpExchange("/payments")
  public interface Payments {
  
      @PostExchange
      Payment pay(@RequestBody Charge charge);
  
      @PostExchange
      ResponseEntity<Payment> payForEntity(@RequestBody Charge charge);
  
      @GetExchange("/{id}")
      Payment find(@PathVariable String id);
  
      @GetExchange("/slow")
      String slow();
  }
  its methods: 4 · a class in harness/ that implements it: 0
the configuration - its annotations (this unit's line):
$ grep -n '^@' harness/probe/web/PaymentConfig.java
  7:@Configuration
  8:@ImportHttpServices(group = "payments", types = Payments.class)
the stub's own HttpExchange - the JDK server's type, in the stub's code (this unit's line):
$ grep -n 'HttpExchange' harness/stub/Stub.java
  89:void send(HttpExchange ex, int code, String type, String body) throws java.io.IOException {
whose classes - each read off the one jar on that class path that holds it (unzip -l, by name):
  org.springframework.web.service.annotation.HttpExchange · in: spring-web-7.0.9.jar
  org.springframework.web.service.registry.ImportHttpServices · in: spring-web-7.0.9.jar
  org.springframework.web.service.invoker.HttpServiceProxyFactory · in: spring-web-7.0.9.jar
  org.springframework.web.client.support.RestClientAdapter · in: spring-web-7.0.9.jar
  org.springframework.boot.restclient.autoconfigure.service.HttpServiceClientAutoConfiguration · in: spring-boot-restclient-4.1.1.jar
  org.springframework.boot.http.client.autoconfigure.service.HttpServiceClientProperties · in: spring-boot-http-client-4.1.1.jar
the seven - the anchor, the README's run line (its locale pinned), port 19550, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19550
  listens on: 127.0.0.1:19550 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19550/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19550 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0 · lines that say "deprecat": 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
the seven - the anchor on its class path, the two jars and the harness joined (PaymentConfig, Pays, PayRoutes; the group's base URL; no cases), port 19551, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19551 --spring.main.sources=probe.web.PaymentConfig,probe.web.Pays,probe.web.PayRoutes --spring.http.serviceclient.payments.base-url=http://127.0.0.1:19556
  listens on: 127.0.0.1:19551 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19551/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19551 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0 · lines that say "deprecat": 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
the lines that moved - the README's run line's seven against the harness line's, masked, line for line:
  lines that differ: 0 · the same, byte for byte: 7 (1 2 3 4 5 6 7)
```

## 2 · proxy — who implements it

One fresh JVM, no stub (no case calls one). **The two `HttpExchange` types, read off the running JVM**:
`org.springframework.web.service.annotation.HttpExchange` — an annotation, from `spring-web-7.0.9.jar`;
`com.sun.net.httpserver.HttpExchange` — not an annotation, from module `jdk.httpserver`. The owners again, at run time. **The bean**, by
type: `'payments#probe.web.Payments'` — the group's name, `#`, the interface (quoted: the `#` is part of the name); beside it six beans
whose name says `httpservice`, among them **`httpServiceProxyRegistry`** (`HttpServiceProxyRegistry`, spring-web's) and Boot's two
auto-configurations and two group configurers. **What answers for the interface**: class `jdk.proxy2.$Proxy<n>` (the number masked; on
the terminal it read `$Proxy84`), its superclass **`java.lang.reflect.Proxy`**, `Proxy.isProxyClass` **true**,
`AopUtils.isJdkDynamicProxy` **true**, `isCglibProxy` false; its interfaces `SpringProxy`, `Advised`, `DecoratingProxy`, `Payments`; its
invocation handler **`JdkDynamicAopProxy`** — Spring AOP's JDK proxy: the kind Course 4 built by hand (a class the JDK makes at run time,
parent `Proxy`, every call to one handler). 0 WARN, 0 ERROR.

`.r-proxy.out` · md5 `c1f65cdf35858aab07e3d5f2f8ea721c` · 3 of 3

```
who answers for the interface - the anchor on its class path, the two jars and the harness joined (PaymentConfig, Pays), the group's base URL, the cases types, beans and proxy, port 19552, a fresh JVM (no stub: no case calls one):
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19552 --spring.main.sources=probe.web.PaymentConfig,probe.web.Pays --probe.cases=types,beans,proxy --spring.http.serviceclient.payments.base-url=http://127.0.0.1:19556
  listens on: 127.0.0.1:19552 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19552/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Pays): en_US
  the harness's lines (Pays), in the order they printed: 20
    the JVM's locale: en_US
    types org.springframework.web.service.annotation.HttpExchange | an annotation: true | from: spring-web-7.0.9.jar
    types com.sun.net.httpserver.HttpExchange | an annotation: false | from: module jdk.httpserver
    types org.springframework.web.service.registry.ImportHttpServices | from: spring-web-7.0.9.jar
    types org.springframework.web.service.invoker.HttpServiceProxyFactory | from: spring-web-7.0.9.jar
    types org.springframework.web.client.support.RestClientAdapter | from: spring-web-7.0.9.jar
    beans of type Payments: ['payments#probe.web.Payments']
    beans whose name says httpservice: 6
    beans 'httpServiceClientProperties' -> org.springframework.boot.http.client.autoconfigure.service.HttpServiceClientProperties
    beans 'httpServiceProxyRegistry' -> org.springframework.web.service.registry.HttpServiceProxyRegistry
    beans 'org.springframework.boot.http.client.autoconfigure.service.HttpServiceClientPropertiesAutoConfiguration' -> org.springframework.boot.http.client.autoconfigure.service.HttpServiceClientPropertiesAutoConfiguration
    beans 'org.springframework.boot.restclient.autoconfigure.service.HttpServiceClientAutoConfiguration' -> org.springframework.boot.restclient.autoconfigure.service.HttpServiceClientAutoConfiguration
    beans 'restClientCustomizerHttpServiceGroupConfigurer' -> org.springframework.boot.restclient.autoconfigure.service.RestClientCustomizerHttpServiceGroupConfigurer
    beans 'restClientPropertiesHttpServiceGroupConfigurer' -> org.springframework.boot.restclient.autoconfigure.service.PropertiesRestClientHttpServiceGroupConfigurer
    beans in the context: 319
    proxy class: jdk.proxy2.$Proxy<n> | its superclass: java.lang.reflect.Proxy
    proxy Proxy.isProxyClass: true | AopUtils.isJdkDynamicProxy: true | AopUtils.isCglibProxy: false
    proxy interfaces: [org.springframework.aop.SpringProxy, org.springframework.aop.framework.Advised, org.springframework.core.DecoratingProxy, probe.web.Payments]
    proxy invocation handler: org.springframework.aop.framework.JdkDynamicAopProxy
    done
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19552 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19552 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 3 · calls — five calls through the interface, and what the stub saw

The stub on `127.0.0.1:19556`, read off its pid, `en_US`. Through the interface: `pay(new Charge("Ravi", 7200))` →
**`Payment[id=pay-1, status=PAID, customer=Ravi, amount=7200]`** (the stub's JSON read into the record); `payForEntity(…)` → **201**,
**`Location: /payments/pay-2`**, the record; `find("pay-1")` → the record. Errors come through the interface as RestClient's exceptions:
`find("pay-99")` → **`HttpClientErrorException$NotFound`**, 404, the stub's problem body in its message; amount 0 →
**`HttpClientErrorException$UnprocessableContent`**, **422** (Framework 7's name for it: `422 Unprocessable Content`). **The stub's dump,
whole** (54 lines): each POST carries **`content-type: application/json`** and **`transfer-encoding: chunked`** — the body is sent in
chunks, with **no `content-length`** header (0 of 5 requests) — and its body `{"customer":"Ravi","amount":7200}`; **no request carries an
`Accept` header** (0 of 5, R.136); the JDK client's h2c offer and two `accept-encoding` values as in the RestClient lesson; the
`User-Agent`'s version masked. The stub accepts a chunked body; a server that refused one would refuse these POSTs (named, not measured).
0 tokens in the dump.

`.r-calls.out` · md5 `473f6d7b472f8a3e85fe0e601f5bd3f2` · 3 of 3

```
the stub - this unit's line, port 19556:
$ java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19556 --www=harness/stub/www
  the stub listens on: 127.0.0.1:19556 · loopback only: yes · its locale: en_US
the calls - the anchor on its class path, the two jars and the harness joined (PaymentConfig, Pays), the group's base URL, the case calls, port 19553, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19553 --spring.main.sources=probe.web.PaymentConfig,probe.web.Pays --probe.cases=calls --spring.http.serviceclient.payments.base-url=http://127.0.0.1:19556
  listens on: 127.0.0.1:19553 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19553/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Pays): en_US
  the harness's lines (Pays), in the order they printed: 7
    the JVM's locale: en_US
    calls pay -> Payment[id=pay-1, status=PAID, customer=Ravi, amount=7200]
    calls payForEntity -> 201 | Location: /payments/pay-2 | Payment[id=pay-2, status=PAID, customer=Meera, amount=4500]
    calls find pay-1 -> Payment[id=pay-1, status=PAID, customer=Ravi, amount=7200]
    calls find pay-99 -> org.springframework.web.client.HttpClientErrorException$NotFound | status 404 | message: 404 Not Found: "{"title":"Not Found","status":404,"detail":"no payment pay-99"}"
    calls pay amount 0 -> org.springframework.web.client.HttpClientErrorException$UnprocessableContent | status 422 | message: 422 Unprocessable Content: "{"title":"Unprocessable","status":422,"detail":"amount must be positive"}"
    done
what the client sent, and what the stub answered - the stub's dump of the five calls:
  the stub's dump since, whole: 54 lines
    | STUB POST /payments headers=[Accept-encoding, Connection, Content-type, Host, Http2-settings, Transfer-encoding, Upgrade, User-agent]
    | STUB-H accept-encoding: gzip
    | STUB-H accept-encoding: deflate
    | STUB-H connection: Upgrade, HTTP2-Settings
    | STUB-H content-type: application/json
    | STUB-H host: 127.0.0.1:19556
    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
    | STUB-H transfer-encoding: chunked
    | STUB-H upgrade: h2c
    | STUB-H user-agent: Java-http-client/<version>
    | STUB-BODY {"customer":"Ravi","amount":7200}
    | STUB-ANSWER 201 application/json 62 bytes
    | STUB POST /payments headers=[Accept-encoding, Connection, Content-type, Host, Http2-settings, Transfer-encoding, Upgrade, User-agent]
    | STUB-H accept-encoding: gzip
    | STUB-H accept-encoding: deflate
    | STUB-H connection: Upgrade, HTTP2-Settings
    | STUB-H content-type: application/json
    | STUB-H host: 127.0.0.1:19556
    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
    | STUB-H transfer-encoding: chunked
    | STUB-H upgrade: h2c
    | STUB-H user-agent: Java-http-client/<version>
    | STUB-BODY {"customer":"Meera","amount":4500}
    | STUB-ANSWER 201 application/json 63 bytes
    | STUB GET /payments/pay-1 headers=[Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent]
    | STUB-H accept-encoding: gzip
    | STUB-H accept-encoding: deflate
    | STUB-H connection: Upgrade, HTTP2-Settings
    | STUB-H host: 127.0.0.1:19556
    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
    | STUB-H upgrade: h2c
    | STUB-H user-agent: Java-http-client/<version>
    | STUB-ANSWER 200 application/json 62 bytes
    | STUB GET /payments/pay-99 headers=[Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent]
    | STUB-H accept-encoding: gzip
    | STUB-H accept-encoding: deflate
    | STUB-H connection: Upgrade, HTTP2-Settings
    | STUB-H host: 127.0.0.1:19556
    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
    | STUB-H upgrade: h2c
    | STUB-H user-agent: Java-http-client/<version>
    | STUB-ANSWER 404 application/problem+json 63 bytes
    | STUB POST /payments headers=[Accept-encoding, Connection, Content-type, Host, Http2-settings, Transfer-encoding, Upgrade, User-agent]
    | STUB-H accept-encoding: gzip
    | STUB-H accept-encoding: deflate
    | STUB-H connection: Upgrade, HTTP2-Settings
    | STUB-H content-type: application/json
    | STUB-H host: 127.0.0.1:19556
    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
    | STUB-H transfer-encoding: chunked
    | STUB-H upgrade: h2c
    | STUB-H user-agent: Java-http-client/<version>
    | STUB-BODY {"customer":"Sunil","amount":0}
    | STUB-ANSWER 422 application/problem+json 73 bytes
  the requests: 5 · POSTs: 3 · POSTs with content-type: application/json: 3 · with transfer-encoding: chunked: 3 · requests with a content-length header: 0 · with an Accept header: 0 · bodies: 3
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19553 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19553 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the stub: stopped by its pid · exit 143 · listening on 19556 now: 0 · requests in its dump: 5 · the demo token 0 times · X-Shutdown-Token 0 times
```

## 4 · group — the group's own keys, its own timeout, its observations

**The keys, from Boot's own metadata** (`spring-boot-http-client-4.1.1.jar`): one key, `spring.http.serviceclient`, of type
`Map<String, HttpClientProperties>` — a group's name, then that class's properties. `javap` on the class (its 22 lines kept to the class
lines and setters, 8): `HttpClientProperties` has `setBaseUrl` and `setDefaultHeader`; its parent `HttpClientSettingsProperties` has
`setRedirects`, `setConnectTimeout`, **`setReadTimeout`**, `setCookieHandling` — so `spring.http.serviceclient.payments.base-url` and
`…payments.read-timeout`. **The group's read timeout at one second**, against the stub's `/payments/slow` (its own three-second wait):
the five calls answered as before, and `slow()` → **`ResourceAccessException … Request cancelled`**, cause
`java.net.http.HttpTimeoutException: Request cancelled`. **One scrape of the same JVM**: every call observed under its **URI template** —
`uri="/payments"` (201 ×2, 422 ×1), `uri="/payments/{id}"` (200 ×1, 404 ×1; no line names `pay-1` or `pay-99`), and the cancelled
`uri="/payments/slow"` (5 kept lines). **C (labelled)**: the base URL alone, no timeout key → `slow()` **answered** `{"slow":true}` after
the stub's whole wait: the timeout was the group's key, and there is no default. Outcomes only, never a clock; the stub's answers cut
(two `GET /payments/slow`, each a fresh JVM).

`.r-group.out` · md5 `78694faea587c3d5614b27655bc02488` · 3 of 3

```
the group's keys - what Boot's own metadata declares (in spring-boot-http-client-4.1.1.jar, one of the two jars the starter adds), and the class each group binds to (this unit's lines):
$ python3 harness/keys.py .harness/xlib/spring-boot-http-client-4.1.1.jar spring.http.serviceclient
  spring.http.serviceclient · default none · HttpClientProperties>
  1 keys under spring.http.serviceclient
$ javap -cp .harness/xlib/spring-boot-http-client-4.1.1.jar org.springframework.boot.http.client.autoconfigure.HttpClientProperties org.springframework.boot.http.client.autoconfigure.HttpClientSettingsProperties
  what javap printed: 22 lines · kept: its two class lines and their setters, 8 lines
  class org.springframework.boot.http.client.autoconfigure.HttpClientProperties extends org.springframework.boot.http.client.autoconfigure.HttpClientSettingsProperties
    set setBaseUrl(java.lang.String);
    set setDefaultHeader(java.util.Map<java.lang.String, java.util.List<java.lang.String>>);
  abstract class org.springframework.boot.http.client.autoconfigure.HttpClientSettingsProperties
    set setRedirects(org.springframework.boot.http.client.HttpRedirects);
    set setConnectTimeout(java.time.Duration);
    set setReadTimeout(java.time.Duration);
    set setCookieHandling(org.springframework.boot.http.client.HttpCookieHandling);
the stub - this unit's line, port 19556 (its /payments/slow answers after three seconds):
$ java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19556 --www=harness/stub/www
  the stub listens on: 127.0.0.1:19556 · loopback only: yes · its locale: en_US
the group's read timeout at one second - the anchor on its class path, the two jars and the harness joined (PaymentConfig, Pays), the cases calls and slow, port 19550, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19550 --spring.main.sources=probe.web.PaymentConfig,probe.web.Pays --probe.cases=calls,slow --spring.http.serviceclient.payments.base-url=http://127.0.0.1:19556 --spring.http.serviceclient.payments.read-timeout=1s
  listens on: 127.0.0.1:19550 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19550/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Pays): en_US
  the harness's lines (Pays), in the order they printed: 8
    the JVM's locale: en_US
    calls pay -> Payment[id=pay-1, status=PAID, customer=Ravi, amount=7200]
    calls payForEntity -> 201 | Location: /payments/pay-2 | Payment[id=pay-2, status=PAID, customer=Meera, amount=4500]
    calls find pay-1 -> Payment[id=pay-1, status=PAID, customer=Ravi, amount=7200]
    calls find pay-99 -> org.springframework.web.client.HttpClientErrorException$NotFound | status 404 | message: 404 Not Found: "{"title":"Not Found","status":404,"detail":"no payment pay-99"}"
    calls pay amount 0 -> org.springframework.web.client.HttpClientErrorException$UnprocessableContent | status 422 | message: 422 Unprocessable Content: "{"title":"Unprocessable","status":422,"detail":"amount must be positive"}"
    slow /payments/slow cancelled: org.springframework.web.client.ResourceAccessException | message: I/O error on GET request for "http://127.0.0.1:19556/payments/slow": Request cancelled | cause: java.net.http.HttpTimeoutException: Request cancelled
    done
what was observed - one scrape of the same JVM's /actuator/prometheus (this unit's line):
$ curl -s -o .harness/prom.txt -w ' %{http_code}\n' http://127.0.0.1:19550/actuator/prometheus
   200
  kept: 5 of the scrape's lines, by the filter ^http_client_requests_seconds_count, sorted · the others not shown: over 150 (their number moves from run to run: the JVM's own meters)
    http_client_requests_seconds_count{client_name="127.0.0.1",error="NotFound",exception="NotFound",method="GET",outcome="CLIENT_ERROR",status="404",uri="/payments/{id}"} 1
    http_client_requests_seconds_count{client_name="127.0.0.1",error="ResourceAccessException",exception="ResourceAccessException",method="GET",outcome="UNKNOWN",status="CLIENT_ERROR",uri="/payments/slow"} 1
    http_client_requests_seconds_count{client_name="127.0.0.1",error="UnprocessableContent",exception="UnprocessableContent",method="POST",outcome="CLIENT_ERROR",status="422",uri="/payments"} 1
    http_client_requests_seconds_count{client_name="127.0.0.1",error="none",exception="none",method="GET",outcome="SUCCESS",status="200",uri="/payments/{id}"} 1
    http_client_requests_seconds_count{client_name="127.0.0.1",error="none",exception="none",method="POST",outcome="SUCCESS",status="201",uri="/payments"} 2
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19550 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19550 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - the group's base URL alone, no timeout key, the case slow, port 19551, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19551 --spring.main.sources=probe.web.PaymentConfig,probe.web.Pays --probe.cases=slow --spring.http.serviceclient.payments.base-url=http://127.0.0.1:19556
  listens on: 127.0.0.1:19551 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19551/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Pays): en_US
  the harness's lines (Pays), in the order they printed: 3
    the JVM's locale: en_US
    slow /payments/slow answered: {"slow":true}
    done
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19551 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19551 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the requests the stub saw, one line a request:
    POST /payments · headers: 9
    POST /payments · headers: 9
    GET /payments/pay-1 · headers: 7
    GET /payments/pay-99 · headers: 7
    POST /payments · headers: 9
    GET /payments/slow · headers: 7
    GET /payments/slow · headers: 7
    its answers: cut - after a cancelled call, where its answer lands in the dump is timing
  the stub: stopped by its pid · exit 143 · listening on 19556 now: 0 · requests in its dump: 7 · the demo token 0 times · X-Shutdown-Token 0 times
```

## 5 · aot — C (labelled): ahead of time, on the five-class app

**Labelled C, on its own app, on the JVM** (⚑7): `harness/aot-app/` — `App`, `PaymentConfig`, `Payments`, `Charge`, `Payment`; its
interface is the harness's without `slow()`, its configuration line the same (both compared). Built from a copy, offline, **0 files**
added to `.m2-demo`, `process-aot` ran once. **Ahead of time**, Boot's build ran the application's configuration once and wrote what it
found as Java source: five classes for `probe.aot`, among them **`Payments__BeanDefinitions`**, whose line builds the bean as
**`getBean("httpServiceProxyRegistry", HttpServiceProxyRegistry.class).getClient("payments", Payments.class)`**. The hints it wrote for a
native image (`reachability-metadata.json`): **one JDK-proxy hint — `[Payments, SpringProxy, Advised, DecoratingProxy]`** — and binding
hints for `Charge` and `Payment` (fields, constructors, accessors) and the interface's three methods. Then the jar against the stub: **on
the JVM** — "Starting App …"; **with `-Dspring.aot.enabled=true`** — Boot's **"Starting AOT-processed App …"**; in both, the same kind of
proxy (`jdk.proxy2.$Proxy<n>`, `isJdkDynamicProxy` true, the four interfaces) and `pay` → the record (pay-1, then pay-2: one stub). No web
server in its jar (0 server jars): it pays once and exits 0. **No native image was built**: nothing here says "in the binary".

`.r-aot.out` · md5 `603c9317f4f6f015235bd1d8a1eee8a9` · 3 of 3

```
C (labelled) - ahead of time, on the aot app: harness/aot-app/, its own POM, five classes, Boot's RestClient starter, no web server (the anchor and the harness cannot be processed together: the harness joins TiffinBox only at run time):
  its classes: probe/aot/App.java probe/aot/Charge.java probe/aot/Payment.java probe/aot/PaymentConfig.java probe/aot/Payments.java
  its interface's annotation and method lines, against the harness's without its slow method: the same: yes · its configuration's annotation lines, against the harness's: the same: yes
built from a copy (.harness/aot), offline, its process-aot goal bound in its POM (this unit's line):
$ cd .harness/aot && mvn -o -B -Dmaven.repo.local="$M2" clean package
  built the AOT app · offline: yes · exit 0
  files .m2-demo gained: 0 · harness/aot-app/target: absent · process-aot ran: 1
  the classes it generated for probe.aot (target/spring-aot/main/sources): App__ApplicationContextInitializer.java App__BeanDefinitions.java App__BeanFactoryRegistrations.java PaymentConfig__BeanDefinitions.java Payments__BeanDefinitions.java
the generated bean definition - what builds the payments bean ahead of time (this unit's line):
$ cd .harness/aot && grep -n 'getClient' target/spring-aot/main/sources/probe/aot/Payments__BeanDefinitions.java
  20:    return registeredBean.getBeanFactory().getBean("httpServiceProxyRegistry", HttpServiceProxyRegistry.class).getClient("payments", Payments.class);
the hints it wrote for a native image (this unit's line):
$ cd .harness/aot && python3 ../../harness/hints.py target/spring-aot/main/resources/META-INF/native-image/probe.aot/aot-app/reachability-metadata.json probe.aot.Charge probe.aot.Payment probe.aot.Payments
  reflection entries: 333 · resource entries: 23
  JDK-proxy hints: 1
    proxy: [probe.aot.Payments, org.springframework.aop.SpringProxy, org.springframework.aop.framework.Advised, org.springframework.core.DecoratingProxy]
    probe.aot.Charge · allDeclaredFields allDeclaredConstructors · methods: amount() customer()
    probe.aot.Payment · allDeclaredFields allDeclaredConstructors · methods: amount() customer() id() status()
    probe.aot.Payments · nothing whole · methods: find(java.lang.String) pay(probe.aot.Charge) payForEntity(probe.aot.Charge)
the stub - this unit's line, port 19556:
$ java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19556 --www=harness/stub/www
  the stub listens on: 127.0.0.1:19556 · loopback only: yes · its locale: en_US
on the JVM - the app's jar, the group's base URL (this unit's line):
$ cd .harness/aot && java -Duser.language=en -Duser.country=US -jar target/aot-app-1.0.0.jar --spring.http.serviceclient.payments.base-url=http://127.0.0.1:19556
  exit 0 · Boot's first line: Starting App v1.0.0 using Java 25.0.4.1
  its lines (App), in the order they printed: 4
    the JVM's locale: en_US
    proxy class: jdk.proxy2.$Proxy<n> | Proxy.isProxyClass: true | AopUtils.isJdkDynamicProxy: true
    proxy interfaces: [org.springframework.aop.SpringProxy, org.springframework.aop.framework.Advised, org.springframework.core.DecoratingProxy, probe.aot.Payments]
    pay -> Payment[id=pay-1, status=PAID, customer=Ravi, amount=7200]
  WARN lines in its log: 0 · ERROR lines: 0 · server jars in its jar (Tomcat, Jetty, Undertow, Netty): 0 - it serves nothing, and listens nowhere
  its log: the demo token 0 times · X-Shutdown-Token 0 times
ahead of time - the same jar with -Dspring.aot.enabled=true: the generated code instead of the configuration classes (this unit's line):
$ cd .harness/aot && java -Duser.language=en -Duser.country=US -Dspring.aot.enabled=true -jar target/aot-app-1.0.0.jar --spring.http.serviceclient.payments.base-url=http://127.0.0.1:19556
  exit 0 · Boot's first line: Starting AOT-processed App v1.0.0 using Java 25.0.4.1
  its lines (App), in the order they printed: 4
    the JVM's locale: en_US
    proxy class: jdk.proxy2.$Proxy<n> | Proxy.isProxyClass: true | AopUtils.isJdkDynamicProxy: true
    proxy interfaces: [org.springframework.aop.SpringProxy, org.springframework.aop.framework.Advised, org.springframework.core.DecoratingProxy, probe.aot.Payments]
    pay -> Payment[id=pay-2, status=PAID, customer=Ravi, amount=7200]
  WARN lines in its log: 0 · ERROR lines: 0 · server jars in its jar (Tomcat, Jetty, Undertow, Netty): 0 - it serves nothing, and listens nowhere
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the stub's dump since, one line a request:
    POST /payments · headers: 9 · the stub answered 201 application/json 62 bytes
    POST /payments · headers: 9 · the stub answered 201 application/json 62 bytes
  the stub: stopped by its pid · exit 143 · listening on 19556 now: 0 · requests in its dump: 2 · the demo token 0 times · X-Shutdown-Token 0 times
```

## 6 · ways — who builds the proxy: A/B/A′

19559 asserted free. Each run a fresh stub and a fresh JVM. **A** — the group's client (`@ImportHttpServices`, Boot's builder
underneath): the proxy (`JdkDynamicAopProxy`, the four interfaces), `pay` → the record, the stub saw 1 POST, and the scrape holds
**`uri="/payments"`, `status="201"`, count 1** — observed. **B** — the same interface by hand:
`HttpServiceProxyFactory.builderFor(RestClientAdapter.create(RestClient.create(stub))).build().createClient(Payments.class)` → the same
kind of proxy (**the same class as the group's: true**), `pay` → `Payment[id=pay-1, …, customer=Priya, amount=3600]`; then the group's
`pay` in the same JVM. The stub saw **2 POSTs**; the one scrape still holds **1 line, count 1** — the group's call; the hand-made call was
**not observed** (R.140, both ways in one scrape): `RestClient.create()` is not Boot's builder. **A′** = A, its `$` line shown, its block
the same as A's line for line ("yes").

`.r-ways.out` · md5 `d86df4e2d7ebd6baf99826e915f6111f` · 3 of 3

```
  19559, never bound: listening 0 (lsof, by port)
A - the group's client (@ImportHttpServices, Boot's builder underneath), the cases proxy and pay, a fresh stub, port 19552, a fresh JVM:
$ java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19556 --www=harness/stub/www
  the stub listens on: 127.0.0.1:19556 · loopback only: yes · its locale: en_US
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19552 --spring.main.sources=probe.web.PaymentConfig,probe.web.Pays --probe.cases=proxy,pay --spring.http.serviceclient.payments.base-url=http://127.0.0.1:19556
  listens on: 127.0.0.1:19552 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19552/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Pays): en_US
  the harness's lines (Pays), in the order they printed: 7
    the JVM's locale: en_US
    proxy class: jdk.proxy2.$Proxy<n> | its superclass: java.lang.reflect.Proxy
    proxy Proxy.isProxyClass: true | AopUtils.isJdkDynamicProxy: true | AopUtils.isCglibProxy: false
    proxy interfaces: [org.springframework.aop.SpringProxy, org.springframework.aop.framework.Advised, org.springframework.core.DecoratingProxy, probe.web.Payments]
    proxy invocation handler: org.springframework.aop.framework.JdkDynamicAopProxy
    pay the group's client -> Payment[id=pay-1, status=PAID, customer=Ravi, amount=7200]
    done
  the stub's dump since, one line a request:
    POST /payments · headers: 9 · the stub answered 201 application/json 62 bytes
  what was observed - one scrape of the same JVM's /actuator/prometheus (this unit's line):
$ curl -s -o .harness/prom.txt -w ' %{http_code}\n' http://127.0.0.1:19552/actuator/prometheus
   200
  kept: 1 of the scrape's lines, by the filter ^http_client_requests_seconds_count, sorted · the others not shown: over 150 (their number moves from run to run: the JVM's own meters)
    http_client_requests_seconds_count{client_name="127.0.0.1",error="none",exception="none",method="POST",outcome="SUCCESS",status="201",uri="/payments"} 1
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19552 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19552 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the stub: stopped by its pid · exit 143 · listening on 19556 now: 0 · requests in its dump: 1 · the demo token 0 times · X-Shutdown-Token 0 times
B - the same interface by hand (HttpServiceProxyFactory over RestClient.create(), the case hand), then the group's pay, a fresh stub, port 19553, a fresh JVM:
$ java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19556 --www=harness/stub/www
  the stub listens on: 127.0.0.1:19556 · loopback only: yes · its locale: en_US
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19553 --spring.main.sources=probe.web.PaymentConfig,probe.web.Pays --probe.cases=hand,pay --spring.http.serviceclient.payments.base-url=http://127.0.0.1:19556
  listens on: 127.0.0.1:19553 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19553/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Pays): en_US
  the harness's lines (Pays), in the order they printed: 9
    the JVM's locale: en_US
    hand class: jdk.proxy2.$Proxy<n> | its superclass: java.lang.reflect.Proxy
    hand Proxy.isProxyClass: true | AopUtils.isJdkDynamicProxy: true | AopUtils.isCglibProxy: false
    hand interfaces: [org.springframework.aop.SpringProxy, org.springframework.aop.framework.Advised, org.springframework.core.DecoratingProxy, probe.web.Payments]
    hand invocation handler: org.springframework.aop.framework.JdkDynamicAopProxy
    hand the same class as the group's: true
    hand pay -> Payment[id=pay-1, status=PAID, customer=Priya, amount=3600]
    pay the group's client -> Payment[id=pay-2, status=PAID, customer=Ravi, amount=7200]
    done
  the stub's dump since, one line a request:
    POST /payments · headers: 9 · the stub answered 201 application/json 63 bytes
    POST /payments · headers: 9 · the stub answered 201 application/json 62 bytes
  what was observed - one scrape of the same JVM's /actuator/prometheus (this unit's line):
$ curl -s -o .harness/prom.txt -w ' %{http_code}\n' http://127.0.0.1:19553/actuator/prometheus
   200
  kept: 1 of the scrape's lines, by the filter ^http_client_requests_seconds_count, sorted · the others not shown: over 150 (their number moves from run to run: the JVM's own meters)
    http_client_requests_seconds_count{client_name="127.0.0.1",error="none",exception="none",method="POST",outcome="SUCCESS",status="201",uri="/payments"} 1
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19553 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19553 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the stub: stopped by its pid · exit 143 · listening on 19556 now: 0 · requests in its dump: 2 · the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, a fresh stub, port 19552, a fresh JVM:
$ java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19556 --www=harness/stub/www
  the stub listens on: 127.0.0.1:19556 · loopback only: yes · its locale: en_US
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19552 --spring.main.sources=probe.web.PaymentConfig,probe.web.Pays --probe.cases=proxy,pay --spring.http.serviceclient.payments.base-url=http://127.0.0.1:19556
  listens on: 127.0.0.1:19552 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19552/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Pays): en_US
  the harness's lines (Pays), in the order they printed: 7
    the JVM's locale: en_US
    proxy class: jdk.proxy2.$Proxy<n> | its superclass: java.lang.reflect.Proxy
    proxy Proxy.isProxyClass: true | AopUtils.isJdkDynamicProxy: true | AopUtils.isCglibProxy: false
    proxy interfaces: [org.springframework.aop.SpringProxy, org.springframework.aop.framework.Advised, org.springframework.core.DecoratingProxy, probe.web.Payments]
    proxy invocation handler: org.springframework.aop.framework.JdkDynamicAopProxy
    pay the group's client -> Payment[id=pay-1, status=PAID, customer=Ravi, amount=7200]
    done
  the stub's dump since, one line a request:
    POST /payments · headers: 9 · the stub answered 201 application/json 62 bytes
  what was observed - one scrape of the same JVM's /actuator/prometheus (this unit's line):
$ curl -s -o .harness/prom.txt -w ' %{http_code}\n' http://127.0.0.1:19552/actuator/prometheus
   200
  kept: 1 of the scrape's lines, by the filter ^http_client_requests_seconds_count, sorted · the others not shown: over 150 (their number moves from run to run: the JVM's own meters)
    http_client_requests_seconds_count{client_name="127.0.0.1",error="none",exception="none",method="POST",outcome="SUCCESS",status="201",uri="/payments"} 1
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19552 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19552 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the stub: stopped by its pid · exit 143 · listening on 19556 now: 0 · requests in its dump: 1 · the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
```

## 7 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s seven lines, then `SOLUTION.md`'s four, in one `env -i` shell (HOME and the PATH this script was started with,
/bin/bash with no profile), started in this folder. As shipped (`B=` empty): **`readiness: 200 · the pay call: 500 · its payment: none ·
URI with undefined scheme in its log: 1 · requests the stub saw: 0`** — TiffinBox started, 0 WARN, readiness 200; the call failed before
any request left (the stub saw 0); TiffinBox's 500 and one ERROR, **Tomcat's `[dispatcherServlet]`**, root cause
`java.lang.IllegalArgumentException: URI with undefined scheme`, its first stack frame in module **`java.net.http`** — the JDK's own
client's words. The solution (`B=--spring.http.serviceclient.payments.base-url=http://127.0.0.1:19556`, the last line unchanged):
**`readiness: 200 · the pay call: 200 · its payment: pay-1 · URI with undefined scheme in its log: 0 · requests the stub saw: 1`**, 0
ERROR. Each leaves the shell in this folder, 19554 and 19556 free; both JVMs pin and print `en_US`; the copy's own token 0 times in its log
and its stub's dump.

`.r-exercise.out` · md5 `3b6a993aee34df472c51db1cf37aa216` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 7 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine/xlib && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/
  $ mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
  $ B=
  $ M="$PWD/.m2-demo" && H="$PWD/harness" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && mvn -o -B -q -Dmaven.repo.local="$M" -f "$H/pom.xml" dependency:build-classpath -Dmdep.outputFile="$PWD/../harness.cp" && rm -f ../xlib/* && tr ':' '\n' < ../harness.cp | while IFS= read -r j; do [ -e "tiffinbox-web/target/extracted/lib/${j##*/}" ] || ! unzip -l "$j" | grep -q '\.class$' || cp "$j" ../xlib/; done && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*:../xlib/*" "$H"/probe/web/*.java && { java -Duser.language=en -Duser.country=US "$H/stub/Stub.java" --port=19556 --www="$H/stub/www" > ../stub.log 2>&1 & } && s=$! && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19554 --spring.main.sources=probe.web.PaymentConfig,probe.web.PayRoutes $B > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do grep -q '^STUB listening' ../stub.log && [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19554/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && r=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19554/actuator/health/readiness) && a=$(curl -s -o ../answer.txt -w '%{http_code}' http://127.0.0.1:19554/probe/pay); "$H/shutdown.sh" 19554 secrets/tiffinbox/shutdown-token > /dev/null; kill "$s"; wait "$s"; wait "$p" && echo "readiness: $r · the pay call: $a · its payment: $(grep -o 'pay-[0-9]*' ../answer.txt || echo none) · URI with undefined scheme in its log: $(grep -c '^java.lang.IllegalArgumentException: URI with undefined scheme$' ../run.log) · requests the stub saw: $(grep -c '^STUB [A-Z]* /' ../stub.log)")
  exit 0 · what they printed:
    readiness: 200 · the pay call: 500 · its payment: none · URI with undefined scheme in its log: 1 · requests the stub saw: 0
  the shell is now in: this unit's folder · the JVM's locale in its log: en_US (PayRoutes), in the stub's: en_US · the copy's own token in its log: 0 times, in the stub's dump: 0 times · WARN lines in its log: 0 · ERROR lines: 1 · listening on 19554 now: 0 · on 19556: 0
  the README's ERROR record in its log (.harness/mine/run.log, kept before the solution's run), from its logger on:
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalArgumentException: URI with undefined scheme] with root cause
      java.lang.IllegalArgumentException: URI with undefined scheme
      its stack frames: over 40, its other lines: 2 - none shown
  the first stack frame under its root cause is in the module: java.net.http (the JDK's HttpClient)
the solution's 4 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ B=--spring.http.serviceclient.payments.base-url=http://127.0.0.1:19556
  $ M="$PWD/.m2-demo" && H="$PWD/harness" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && mvn -o -B -q -Dmaven.repo.local="$M" -f "$H/pom.xml" dependency:build-classpath -Dmdep.outputFile="$PWD/../harness.cp" && rm -f ../xlib/* && tr ':' '\n' < ../harness.cp | while IFS= read -r j; do [ -e "tiffinbox-web/target/extracted/lib/${j##*/}" ] || ! unzip -l "$j" | grep -q '\.class$' || cp "$j" ../xlib/; done && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*:../xlib/*" "$H"/probe/web/*.java && { java -Duser.language=en -Duser.country=US "$H/stub/Stub.java" --port=19556 --www="$H/stub/www" > ../stub.log 2>&1 & } && s=$! && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19554 --spring.main.sources=probe.web.PaymentConfig,probe.web.PayRoutes $B > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do grep -q '^STUB listening' ../stub.log && [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19554/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && r=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19554/actuator/health/readiness) && a=$(curl -s -o ../answer.txt -w '%{http_code}' http://127.0.0.1:19554/probe/pay); "$H/shutdown.sh" 19554 secrets/tiffinbox/shutdown-token > /dev/null; kill "$s"; wait "$s"; wait "$p" && echo "readiness: $r · the pay call: $a · its payment: $(grep -o 'pay-[0-9]*' ../answer.txt || echo none) · URI with undefined scheme in its log: $(grep -c '^java.lang.IllegalArgumentException: URI with undefined scheme$' ../run.log) · requests the stub saw: $(grep -c '^STUB [A-Z]* /' ../stub.log)")
  exit 0 · what they printed:
    readiness: 200 · the pay call: 200 · its payment: pay-1 · URI with undefined scheme in its log: 0 · requests the stub saw: 1
  the shell is now in: this unit's folder · the JVM's locale in its log: en_US (PayRoutes), in the stub's: en_US · the copy's own token in its log: 0 times, in the stub's dump: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19554 now: 0 · on 19556: 0
```


## Exercise

**Your turn:** the README's payment client starts fine and fails on every call. Tell the group where the payment service lives, and pay again.
`exercise/README.md` has the commands (copy the anchor, give the copy a token of its own, `B=` — empty); its last line, in a subshell,
builds the copy offline, reads the harness POM's class path, joins the two jars, compiles the harness, starts the stub on 19556 and
TiffinBox on 19554 with `PaymentConfig` and `PayRoutes` joined and `$B` as its options, calls `GET /probe/pay` with curl, stops both, waits
for both pids and prints — as shipped — `readiness: 200 · the pay call: 500 · its payment: none · URI with undefined scheme in its log: 1 ·
requests the stub saw: 0`. **The check looks at the call, not the start** (R.65): readiness answered 200, the log has 0 WARN lines, and
only the call fails. Done is `readiness: 200 · the pay call: 200 · its payment: pay-1 · URI with undefined scheme in its log: 0 ·
requests the stub saw: 1` (`B=--spring.http.serviceclient.payments.base-url=http://127.0.0.1:19556`, the last line unchanged). "Pay again"
is the README's curl to the harness route — curl only. Measured answer: `exercise/solution/`. Run `./receipts.sh` once first on a fresh
clone.

## The ledger rows and hand-offs this unit pays

- **The roadmap's "a payment client that is one interface and no implementation"** — `interface` (4 methods, 0 classes implement it) and
  `proxy` (Spring's JDK proxy answers for it), the calls through it (`calls`), the group's settings (`group`), who builds it (`ways`), and
  ahead of time on the JVM (`aot`, labelled C). The payment service is the stub, "a payment service" on a chip only — never a brand, never
  called (⚑8).
- **S4 CARRIED** — "a local stub on the unit's own ports": the RestClient lesson's stub, copied byte for byte (md5 asserted), on 19556,
  loopback asserted on its pid. "Reading a stream": unspoken here (the brief's §Step 11; CARRIED to Course 12 by title).
- **C6-31's glosses** for this unit: an HTTP interface, a service group, a proxy (re-glossed: Course 4's JDK proxy), ahead-of-time
  (re-glossed), the stub (re-glossed, one line) — each at first spoken use, gated by the builder.
- **Course 4's proxy promise, re-used by title** (no ledger row): "What a Proxy Actually Is" built a JDK proxy by hand — an object of a
  class the JDK made at run time, whose parent class is `Proxy`, every call sent to one handler. `proxy` shows exactly that: superclass
  `java.lang.reflect.Proxy`, `Proxy.isProxyClass` true, the handler `JdkDynamicAopProxy`.
- **H-04**, the servlet section's slide that names "the JDK's server (HttpServer, HttpExchange, HttpHandler…)": the stub is that server, and
  every place here that shows both `HttpExchange` types says which (R.146).
- **The RestClient lesson's up-next**, "Next: HTTP Interface Clients, HttpExchange." — this unit's title (`js.TITLES`, R.63). Its facts are
  cited, not re-captured: the two jars, the JDK factory on this class path, no `Accept` header, and `accept-encoding` as **two values**
  (`gzip`, `deflate`) — the same two values reach the stub from the interface's client (`calls`, every request).

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-27) |
|---|---|---|---|
| 1 | Every 26 capture on `c6-unit24/after` + the unit's own harness | the probe's `base/`, a copy | **all seven captures here**, on `anchor/` → `../c6-unit24/after` |
| 2 | The stub as this unit's own copy; its md5 = 25's | the probe's `stub/` | **`harness/stub/`**, `Stub.java` md5 `42b656dd…` = `../c6-unit25`'s, 6 of 6 files (`interface`, and a check at the top) |
| 5 | 26's AOT capture on its own `harness/aot-app/` | `h26/` (4 classes, offline) | **`aot`, labelled C**: five classes, offline, 0 files fetched; the generated `getClient` line; one JDK-proxy hint (the four interfaces); `Charge`/`Payment` hints; "Starting AOT-processed App"; the same proxy kind, the record |
| 6 | `@PathVariable String id` without `-parameters` | not run | **not spoken** — the harness compiles with `-parameters` (a check asserts it, here and in the exercise) |
| 13 | The exercise as viewers run it | end states on sketches | **README then SOLUTION in one `env -i` shell, exit 0 each** (`exercise`, and "Found on the way") |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **The metadata does not list `spring.http.serviceclient.payments.base-url`.** Boot 4.1.1's metadata declares one key,
  `spring.http.serviceclient`, a **map** from a group's name to `HttpClientProperties`; its `base-url` and `read-timeout` are that class's
  setters (`setBaseUrl`, and `setReadTimeout` from `HttpClientSettingsProperties`) — read off the jar with `javap` (`group`). The brief's
  "every Boot key spelled from Boot's metadata" is met by the map's type and the class it binds, not by a listed key.
- **The JDK proxy class is shared.** The hand-made client (B) is not just "the same proxy kind" — it is **the same class** as the group's
  (`hand the same class as the group's: true`): the JDK reuses one proxy class per interface list.
- **"0 observations" is shown as "1, not 2"** (R.140, both ways in one scrape): B's JVM pays once by hand and once through the group; the
  stub saw **2** POSTs and the scrape holds **1** `uri="/payments"` line, count 1 — the group's.
- **The failed call's words are the JDK client's.** `URI with undefined scheme` is thrown inside module `java.net.http` (the first stack
  frame under the root cause, `exercise`): with no base URL the client hands the JDK's `HttpClient` a bare `/payments`.
- **The group's timed-out call is observed too** — `uri="/payments/slow"`, `outcome="UNKNOWN"`, `status="CLIENT_ERROR"`,
  `exception="ResourceAccessException"` (`group`); shown, not spoken.
- **The AOT capture adds the JVM run beside the AOT run**, so "Starting AOT-processed" distinguishes (the JVM run says "Starting App").
- **The brief's sketch and this tree agree** on every other line of its unit block: the bean `payments#probe.web.Payments`;
  `jdk.proxy2.$Proxy<n>`, `isProxyClass`/`isJdkDynamicProxy` true, `Advised`, `DecoratingProxy`, `Payments`, `SpringProxy`;
  `httpServiceProxyRegistry`; `pay` → `Payment[id=pay-1, status=PAID, …]`; `payForEntity` → 201 + `Location /payments/pay-2`; the POST's
  `content-type: application/json`, `transfer-encoding: chunked`, no `Accept`; `NotFound`; `$UnprocessableContent` 422; the group's
  read timeout → `Request cancelled`; `uri="/payments/{id}"`, `uri="/payments"`; the AOT `getClient` line and hints; no base URL → the app
  starts, 0 WARN, `IllegalArgumentException: URI with undefined scheme`, 0 requests at the stub.

## Found on the way

- **Every check fails on a planted fault first** (R.65): the checks block runs alone (`cap()` dropped, the builds and the wipe skipped, each
  run in a session of its own) on the published captures with one thing changed per plant (`plants.py`, this unit's scratch folder), the
  file restored after each — **68 plants, 68 stops under /bin/bash 3.2 and 68 under bash 5.3**, each naming its own check; the unplanted
  files pass before and after under both, and the published md5s are unchanged. They change a capture (61 libraries; 61 + 2 = 63; the
  stub's md5; 6 of 6; an implementation of the interface; the one line; the stub's `HttpExchange`; an owner; the seven's hash; "byte for
  byte: 7"; an interface line; the JDK's `HttpExchange` module; the unquoted bean name; an unmasked proxy number; CGLIB for JDK; three
  interfaces for four; the handler; the record; the `Location`; the 422's class; a `content-length` for `chunked`; an `Accept`; an
  unmasked client version; a token in the dump; the metadata's key; a lost setter; an answered timeout; C cancelled; an observation tagged
  with an id; the kept count; files fetched by the AOT build; the `getClient` group; the proxy hint and its interfaces; "AOT-processed" on
  the wrong run, and missing; the AOT record; 19559 bound; "the same class" false; A′ ≠ A; A′ without its `$` line; B observed twice; a
  POST missing; both exercise lines; the JDK client's module; a port left open; an ERROR count; the locale; the stub's bind; a sixth AOT
  class; a duration; an absolute path; a raw token) or a shipped file (SOLUTION's key; the README shipping the key; a bare `wait`; a stop
  by name; `localhost`; a second "browser"; the Done line; `-parameters` dropped; Boot 3's client key in this README; a harness class that
  implements `Payments`; a wildcard import of Spring's `HttpExchange`; the stub's bind; `keys.py` edited; a native profile in the AOT POM).
- **Two plants first stopped on another check** — "AOT-processed" planted on the JVM run and removed from the AOT run each stopped on the
  first-line check of the run it touched, not the one the plant named: the plant's label was corrected, both checks stand.
- **Filters checked on planted inputs inside the script itself**, before any capture: the record filter and the level counts (a harness line
  that says "ERROR", one WARN and one ERROR record: 1 and 1 by line shape — a bare `' ERROR'` gives 2), the stub's dump filters (a header
  given twice, a body, a request with no answer, a late answer), the scrape filter, and the masks (two `Java-http-client/` versions, two
  proxy numbers, CGLIB's number, the token).
- **Found while building:** (1) the stub's answer to the group's cancelled call never reached the dump in one probe run and landed late in
  another: `group` prints the requests only, and says why. (2) The owners line first printed `HttpExchange · in: spring-web-7.0.9.jar` —
  a bare `HttpExchange` beside the stub's: every owner is printed by its full name now (R.146). (3) `$Proxy84` in TiffinBox's JVM,
  `$Proxy47` in the AOT app's (both printed on the terminal only): the number moves with the class path, masked everywhere. (4) The sorted
  scrape puts `NotFound` before `none`: the deck's rows follow the capture's order (the builder asserts it).
- **SIGINT**, measured: the script started as a terminal starts its foreground job (`python3` with `SIG_DFL` and `os.setpgrp()`, `env -i`,
  /bin/bash 3.2), SIGINT to its process group during `calls`, while the stub and a TiffinBox JVM ran (5 processes in the group): **exit
  130**; 5 s later 0 processes in the group; 19550-19559, 8080, 18425 and 35729 free; no `.r-lock`, no unfinished capture run; the published
  captures unchanged (md5).
- **The exercise as viewers run it**, beyond the capture: README then SOLUTION in one `env -i` shell — the README's run and the solution's
  are two runs of the same last line in one shell, the stub restarting at `pay-1` each time; `B=` lives in that shell, and a new shell needs
  SOLUTION's whole block (it repeats the exports and sets `B`). Both JVMs are subshell jobs waited by pid; 19554 and 19556 free after each.

## For RED

- This unit reads `../c6-unit24/after` only (no change), and copies the RestClient lesson's stub byte for byte (md5 asserted; no route
  added). The AOT capture is **labelled C** and runs a five-class app of its own **on the JVM**: nothing here says "in the binary".
- **Re-check:** both bashes 3/3, the sealed clone (`central` 0 by repository id), SIGINT during a capture's JVM with the stub running;
  **the proxy-number mask** (`$Proxy<n>`, the raw class name on the terminal only, and the AOT app's number differs from TiffinBox's);
  **the two `HttpExchange` types on every slide that shows both** (package named: Spring's annotation from spring-web, the JDK server's type
  from `jdk.httpserver`); every "sent / not sent" line against the stub's dump (`calls`: `content-type: application/json`,
  `transfer-encoding: chunked`, 0 `content-length`, 0 `Accept`); the "observed / not observed" pair in one scrape (`ways` B: 2 POSTs, 1
  observation); the group's timeout judged by `answered:` / `cancelled:`, never a clock; the bean name quoted; the exercise under Java 23
  (refused at compile), with `JAVA_HOME` unset (Homebrew's 26), and twice in one shell; that no harness class reached the anchor; Boot 3's
  client key nowhere (R.138).
