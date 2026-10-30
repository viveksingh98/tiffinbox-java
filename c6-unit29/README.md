# c6-unit29 — API Versioning in Framework 7

Course 6 · Spring Web MVC · Section 6 (Close), its first unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**
(Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5), curl 8.7.1, 2026-10-29. An API changes, and the old clients keep calling.
**API versioning** is a version number the client sends, so one path can answer in two shapes. Spring Framework 7.0.9 has it built in —
a `version` attribute on `@RequestMapping` and `@GetMapping`, read off spring-web 7.0.9 — and Boot 4.1.1 switches it on with eight
`spring.mvc.apiversion.*` keys. This unit measures the mechanism, its trap and both ends: the start failure with no strategy, the four
places a version travels, what a strategy does to TiffinBox's own controller routes, which never asked for a version, the baseline, deprecation
(read off the headers), and the client side against the stub. **Which strategy an API should choose, and how it retires a version, is a
design question: Course 9's *Versioning Strategies*.** Everything here is "in Framework 7.0.9" — the only class files read.

**No anchor change (brief ⚑4).** `anchor` is the link to `../c6-unit28/after` — the web-layer testing lesson's frozen tree, `c6-tiffinbox`
at Section 5's end (`diff -rq -x target c6-tiffinbox c6-unit28/after` empty on 2026-10-29, at `98a23b4`; the `.gitignore` reservation for
units 29-32 is the commit on top) — read and copied under `.harness/anchor`, never built in place; this unit freezes no `after/` and
touches no other unit's folder. It changes nothing in TiffinBox because the measurement says a strategy without a default turns five of
the seven into 400s, POST /shutdown included, and with a default every unversioned answer inherits 1.0's deprecation headers (brief ⚑4,
measured again here: `unversioned`, `deprecation`). Everything new is **the course's harness**, never TiffinBox's:

- `harness/pom.xml` — builds nothing; it names **Boot's RestClient starter** under the anchor's parent (Boot 4.1.1), so that Maven's
  `dependency:build-classpath` lists the jars it brings (R.26). As in the RestClient and HTTP-interface lessons: 31 jars, 25 already in
  the anchor's `lib/`, 4 starters with no class, **2 joined — `spring-boot-restclient` and `spring-boot-http-client`** (61 + 2 = 63; the
  service group's keys and `ApiversionProperties` live in the second). httpclient5 is not on the class path (asserted), so the JDK's
  `HttpClient` is the request factory underneath.
- `harness/probe/web` — outside `com.tiffinbox`, compiled with `-parameters` against the anchor's jars and the two, joined by
  `--spring.main.sources` on the extracted jar's class path: **`Menu`** (`GET /menu` three times: `version = "1.0"` → the customers' names,
  `"1.1+"` → their count, `"2.0"` → the month's total — TiffinBox's own `CustomerRepository`), **`MenuPath`** (the same three on
  `/api/{v}/menu`), **`Deprecations`** (a `StandardApiVersionDeprecationHandler` bean: 1.0 deprecated from 2026-10-01, sunset 2027-04-01, a
  link — Boot hands it to Spring MVC's versioning), **`Versions`** (an `ApplicationRunner`: prints the JVM's locale, then the cases
  `--probe.cases` names — a `RestClient.builder()` with one `ApiVersionInserter` each, built once (R.141) — one `VER …` line each),
  **`MenuApi`** (an HTTP interface — Spring's `@HttpExchange` — for two of the stub's files; `meera()` carries `version = "2.0"`) and
  **`MenuGroup`** (`@ImportHttpServices(group = "menu", types = MenuApi.class)` and a runner that calls both methods once).
- `harness/stub/` — **the RestClient lesson's stub, copied byte for byte**: `Stub.java` md5 `42b656ddba1e9f80107495c65dacc975` =
  `../c6-unit25/harness/stub/Stub.java`'s, and its five `www/` files (asserted at the top of `receipts.sh`, and in `client`: 6 of 6). **No
  route added** — `GET /customers.json`, `/ravi.json`, `/meera.json` and `POST /payments` were enough; the `/1.1/customers.json` the path
  inserter asks for is answered by the stub's own 404 (`text/plain`, `not found`), named as the stub's. It binds
  `InetAddress.getLoopbackAddress()` (asserted on its pid: `127.0.0.1:19587`) and prints every request whole — the witness of what a client
  sent. **A stub** is a small stand-in server that answers like the real one, on this computer.
- `harness/keys.py` (the upload lesson's, byte for byte) and `harness/shutdown.sh` (the filters lesson's, byte for byte).

**Two types named `HttpExchange` (R.146, S6.21).** The stub's code uses **the JDK server's `com.sun.net.httpserver.HttpExchange`** (module
`jdk.httpserver`); `MenuApi` uses **Spring's `@HttpExchange`** (`org.springframework.web.service.annotation`, spring-web). `client` prints
both lines with their files; every slide that shows the word says which, by package.

No native build, no Docker and no browser: curl and the stub are the clients and the witness (R.115). Every URL is `127.0.0.1:<port>`.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 8 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top; a bare `java` on this Mac is 23.) It **dies** when a capture's md5 differs from
`receipts.md5` (it prints the `DIFFERS` line first). **Start it in a process group of its own** (a terminal's foreground job is one): two
receipts started as background jobs of one shell share a group, and one run's clean-up would stop the other's JVMs (R.94).

**Runs of record (BLUE S6, 2026-10-30, the script as committed after RED S6):** **375 s under `./receipts.sh`** (/bin/bash 3.2.57)
and **462 s under `bash receipts.sh`** (Homebrew bash 5.3.9), each `env -i`, a process group of its own: exit 0, all 8 captures 3/3 =
published — seven unchanged, `exercise` `40b8682e…` → `55838e7e6d445cd0b2b5d305570db900` (the array `V`, and the zsh run beside the bash
one, RED S6 #527), made by one development run first; every check passed; no `grep:` line in either terminal. (The runs below are
the builder's, on the script before BLUE S6.) **Runs of record (2026-10-29, this script as committed then):** **296 s under `./receipts.sh`** (/bin/bash 3.2.57, `env -i` with HOME and a
plain PATH, this folder, a session — so a process group — of its own: exit 0, all 8 captures 3/3 = published, every check passed) and
**317 s under `bash receipts.sh`** (Homebrew bash 5.3.9, the same: exit 0, all 8 = published). The hashes were first made by a 3.2
development run and reproduced, unchanged, by every run since, under both bashes (four full runs, an interrupted one, and the sealed
clone). **A sealed fresh clone**, by the recipe below: a `git clone` of the repository at `2d56e4c` with this folder's files beside it
(the `anchor` link by `readlink`: `../c6-unit28/after`), `.m2-demo` absent at the start, a `file://` copy of 4,440 files made from this
folder's `.m2-demo`; the pre-flight: exit 1, 221 `Downloading from sealed: file://`, 0 from http(s) — **exit 0, all 8 = published, every
check passed, 313 s**; the two builds before the captures said `offline: no` — the configured repository was asked, the sealed one (the
anchor's log and the harness POM's: 604 downloads, every one from `file://`), never Central — and every capture's build `offline: yes`;
**`_remote.repositories` by repository id: 765 `>sealed=` (in 530 artifact folders), 0 `central`**, no line with another id. The
durations are the terminal's, never a capture's.

Published hashes: surface `fc139d7a46b1c07918320bca18548aee` · strategy `da872447bb02e32acaf3e0c6e7422e0c` · where `0af0fe7e60f90cf3d15c3cc3fd7db62d` · unversioned `c98eacc28097f3c63186d857c3a87e67` · baseline `e71dea9fb71af2162d36c6059d1ed082` · deprecation `242ecc7cd8e189594d3a24406c3111a9` · client `f41a42073b0c7914974f0a8c4fee62d6` · exercise `55838e7e6d445cd0b2b5d305570db900`.

### A sealed fresh clone — the recipe (RED S4 #405, fixed; unit 24's)

**Paste it into bash** (type `bash` first if your Terminal is zsh): zsh does not split the unquoted `$E`, so the pre-flight would print
`NOT SEALED` — safe, but for the wrong reason (RED S6 #521).

`-Duser.home` in the sealed `.mavenrc` (Java on macOS ignores `$HOME`, so Maven would never read settings kept there), Maven's own
`<proxies>` at a refusing port (its resolver ignores `-Dhttp.proxyHost`), a mirror `*` → `file://`; a pre-flight that refuses to start
unless an absent artifact fails having asked `file://` alone; a post-check counting `_remote.repositories` by repository id (0 `central`):

```bash
S=/tmp/sealed-29                                   # an empty folder of your own; T = your tiffinbox-java clone
mkdir -p "$S/home/.m2" && git clone -q "file://$T" "$S/tiffinbox-java"
rsync -a --exclude _remote.repositories --exclude '*.lastUpdated' --exclude resolver-status.properties "$T/c6-unit29/.m2-demo/" "$S/central/"
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
[ "$(readlink "$S/tiffinbox-java/c6-unit29/anchor")" = ../c6-unit28/after ] && echo "anchor: the link" || echo "anchor is not the link"
cd "$S/tiffinbox-java/c6-unit29" && $E ./receipts.sh            # a process group of its own (a terminal's foreground job is one)
# post-check: every artifact's origin, by repository id - each line must say sealed; 0 central
find .m2-demo -name _remote.repositories -exec cat {} + | grep -o '>[^=]*=' | sort | uniq -c
```

The clone's files beside it: this folder's files are copied into the clone's `c6-unit29/` before the run when the unit is not committed
yet (`rsync -a --exclude .m2-demo --exclude .harness --exclude '.r-*'`); a clone of the committed repository has them already.

## The commands this unit adds

```bash
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
mvn -o -B -q -Dmaven.repo.local="$M2" -f harness/pom.xml dependency:build-classpath -Dmdep.outputFile="$PWD/.harness/harness.cp"
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:.harness/xlib/*" harness/probe/web/Deprecations.java harness/probe/web/Menu.java harness/probe/web/MenuApi.java harness/probe/web/MenuGroup.java harness/probe/web/MenuPath.java harness/probe/web/Versions.java
java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19587 --www=harness/stub/www
for f in Stub.java www/customers.json www/meera.json www/priya.json www/ravi.json www/sunil.json; do echo "$(md5 -q "harness/stub/$f") $(md5 -q "$S25/$f") $f"; done
javap -cp .harness/anchor/tiffinbox-web/target/extracted/lib/spring-web-7.0.9.jar org.springframework.web.bind.annotation.GetMapping org.springframework.web.bind.annotation.RequestMapping
grep -n -E 'GetMapping\(|^public class' harness/probe/web/Menu.java harness/probe/web/MenuPath.java
python3 harness/keys.py .harness/anchor/tiffinbox-web/target/extracted/lib/spring-boot-webmvc-4.1.1.jar spring.mvc.apiversion
javap -v -p -cp .harness/xlib/spring-boot-http-client-4.1.1.jar org.springframework.boot.http.client.autoconfigure.ApiversionProperties
grep -n 'HttpExchange' harness/stub/Stub.java harness/probe/web/MenuApi.java
curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' http://127.0.0.1:18431/menu
curl -s -D .harness/head.txt -o .harness/body.txt -w '%{http_code}' http://127.0.0.1:18431/menu
curl -s -o .harness/mappings.json -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/mappings
```

`anchor/README.md` — the anchor's own — gives five lines `receipts.sh` runs or derives from (`mvn -B package`, the run line, the extract
line, the class-path line, the readiness line); the fourteen above are this unit's, each read from this block and asserted to be exactly
this (on the anchor's port 18431; each capture swaps in its own port, its path and its curl options). The first two are the anchor's run
and class-path lines with `-Duser.language=en -Duser.country=US` after `java` — asserted — and every java line a capture starts takes the
same two options in the same place, the stub's too (a last check refuses any capture's java line without them, and the exercise's). Every
harness run adds, after the class-path line's jar and `lib/*`, `../xlib/*` (the two jars) and `../hc` (the harness), and joins its classes
with `--spring.main.sources=` (`hcp()`); the versioning keys follow as options: `--spring.mvc.apiversion.use.header=API-Version`,
`--spring.mvc.apiversion.use.query-parameter=version`, `'--spring.mvc.apiversion.use.media-type-parameter[application/json]=v'` (quoted:
the brackets), `--spring.mvc.apiversion.use.path-segment=1`, `--spring.mvc.apiversion.default=1.0`, `--spring.mvc.apiversion.required=false`,
`--spring.mvc.apiversion.supported=1.2` — each spelled from Boot's metadata (`surface`, R.138) — and, for the group,
`--spring.http.serviceclient.menu.base-url=http://127.0.0.1:19587`, `….menu.apiversion.insert.header=API-Version` and
`….menu.apiversion.default=1.1` — `default` by the field's `@Name` (R.154, `client`). The `for` line prints, for the stub and its five
files, this folder's md5 and the RestClient lesson's (`$S25` is `../c6-unit25/harness/stub`). The three `curl` lines save an answer's body,
its headers, and `/actuator/mappings` to files, each read by a declared filter.

## The repository, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from `../../spring-web-mvc/_research/m2-seed-s6/`
alone (= `m2-seed-s5` byte for byte) — 5,925 files (the seed's 5,926 less Finder's `.DS_Store`), no `com/tiffinbox`. **Nothing was
downloaded** for this unit: every build said `offline: yes`, and `.m2-demo` held 5,925 files before the first run and after the last. A fresh clone's `.m2-demo` is empty (git ignores it): the first two
builds — `.harness/pre` and the harness POM's class path, before any capture — fill it from Maven Central (or the sealed copy) and say
`offline: no`. **At run time** every request goes to `127.0.0.1`, and nothing binds 8080, 18425, 35729 or 19589.

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 32 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/anchor/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) when the script runs, and sent only by `../c5-unit11/curlset.sh` and `harness/shutdown.sh` on curl's standard input, to
TiffinBox — never to the stub. Every capture's raw output is searched for it before masking (0 in all of them), and so are the log of
every JVM that ran, **the stub's dump of every run** (0: the token never reached the stub, R.137) and every file this unit ships: 0
everywhere. The header's name, `X-Shutdown-Token`, is counted too: 0 in every log and every dump. The exercise makes a token of its own
(`openssl rand -hex 13`), counted 0 times in its log and its seven, never printed.

## The locale — pinned per JVM, printed, asserted

Every java line this script starts — TiffinBox's and the stub's — carries `-Duser.language=en -Duser.country=US` right after `java` (S6.1,
R.100), and every one prints its locale (`Versions`, `Stub`) — `en_US`, asserted in every capture that starts one (R.124). The exercise's
one JVM runs TiffinBox's jar alone (no harness class prints there): its line pins the two options (a last check), and its messages are the
seven's. No request sends `Accept-Language`. Receipts run under bash (`#!/bin/bash`). The exercise's blocks pass their options as an array (`V=( … )`, `"${V[@]}"`), one word
each in bash and in zsh alike, and `exercise` runs them under both (RED S6 #527: the shipped `V="--a --b"` reached TiffinBox as one
word in zsh, the Mac's Terminal shell).

## The folders, the names and the ports

- `.harness/pre` — the anchor built before any capture; `.harness/anchor` — the anchor, copied, with a config tree, built and extracted
  (`surface`); `.harness/harness.cp`, `.harness/xlib`, `.harness/hc` — the harness POM's class path, the two jars, the harness's classes;
  `.harness/stub.out` — the stub's dump; `.harness/body.txt`, `.harness/head.txt`, `.harness/mappings.json` — what the curl lines saved;
  `.harness/seven-*.txt` — each run's seven, masked; `.harness/mine` — the exercise's copy.
- **The bean names with `#`**: the group's client bean is `menu#probe.web.MenuApi` (the group, `#`, the interface) — no capture here prints
  a bean name; where one is written it is quoted.
- **Ports** (brief ⚑1, 19580-19589): TiffinBox 19580-19585, one JVM at a time, each port asserted free before each start (`surface`
  19580; `strategy` 19580-19581; `where` 19580-19583; `unversioned` 19580-19583; `baseline` 19580-19581; `deprecation` 19580-19581; `client`
  19580-19584; the exercise 19585); the stub 19587 (`client`); **19589 never bound** (asserted free, `where`); 19586 and 19588 unused. All
  ten, 18425, 8080 and 35729 are checked free first; a TiffinBox that listens on 8080, 35729 or 19589 is killed and the script dies.
  **A strategy with no default answers POST /shutdown 400** (`"API version is required."`): such a JVM is stopped by its pid, waited for
  (exit 143), its port asserted free — and the line says so (R.152, R.51, R.79); every other TiffinBox is stopped by POST /shutdown and its
  pid waited for; the stub, which has no shutdown route, by its pid (exit 143).

## Masks, filters and hygiene — every one, declared

1. **Paths, the token, the user** (`gsub()`, literals escaped), in every line: the demo token → `[masked: the 32-character token]`; this
   folder → `…`; the folder above → `…/..`; home → `~`; the user name, as a whole word → `<user>`. **The JDK's version in the client's
   `User-Agent`** (R.136, S6.20): `Java-http-client/<digits and dots>` → `Java-http-client/<version>` (no capture prints the header — the
   stub's lines here show three headers — but the mask runs), the raw value printed once on the terminal. **The JDK's version in Boot's
   first line** (R.151): ` using Java <digits and dots>` → ` using Java <version>`, printed once on the terminal. **The handler method a
   failed start names** (`strategy` B): `java.util.Map probe.web.<Class>.<method>() throws …` → `<the first handler method the scan met>` —
   the scan's first, which no rule fixes (R.11). A last check fails if any capture holds `/Users/`, `/private/`, `/home/`,
   `/var/folders/`, a unit number, Boot's process line, a log time, an unmasked timestamp, a thread number, a JDK version, a handler method
   of a failed start, a platform word, a stack frame, a `Date` header, `:8080`, `:35729` or `:18425/`, a carriage return, a duration, or a
   command with a URL that is not `127.0.0.1`'s.
2. **Spring's error timestamp** (`tsmask`): both forms → `…`, in every answer printed and in the seven (the mask runs; the seven print its
   count, 0; `unversioned` C's Boot four keys show `"timestamp":"…"`).
3. **An answer** (`ask`): curl's status and content type, then the body — whole. **An answer's headers** (`heads`): curl `-D` into a
   file, the carriage returns stripped, **every header line counted** (the status line among them) and **kept by the declared filter
   `^(Deprecation|Sunset|Link|Content-Type): `** (any case), then the body (S6.6, R.153). Checked on a planted header block first.
4. **The stub's dump** (`sver`): one line per request — its method and URI, **the three headers a version can ride on** (`api-version`,
   `accept`, `content-type`), each with its value or `none`, **how many headers it had**, and the stub's answer. The others (host,
   user-agent, connection, upgrade, http2-settings, accept-encoding …) are counted, not shown. Checked on a planted dump first.
5. **`/actuator/mappings`** (`mapsf`): every predicate its `dispatcherServlets` list, counted (22), kept by the filter `/menu`, sorted (3).
   The endpoint is exposed for one run only, by a flag on that run's line (R.42; a check counts the flag once in all captures).
6. **Log lines** (`logl`, `recs`): from their logger on — `o.s.web.servlet.PageNotFound` is **Spring MVC's** (the seven's 405);
   `o.s.boot.SpringApplication` is **Boot's** (the start failure, S6.5); `ConfigServletWebServerApplicationContext` is **Boot's** context
   (it cancels the refresh); the root cause, `IllegalStateException: API version specified, but no ApiVersionStrategy configured`, is
   **Framework's** (spring-webmvc's handler mapping — the bean `requestMappingHandlerMapping` it names). A WARN or ERROR record is its
   level, logger and message, the exception line under it, its stack frames bounded ("over 40") and its other lines counted, never shown;
   a failed start's `Caused by:` lines are printed in order. **Counted by the log's own line shape**, never a bare `' ERROR'` (checked on a
   planted log first). Every TiffinBox run ends with its WARN and ERROR counts and the number of its lines that say "deprecat"; every seven
   prints how many lines the log gained during it (**the version 400s log nothing**: 1 line, the 405's WARN).
7. **The harness's lines** (`vers`): the `VER` lines, whole — `Versions`' in the order they printed, then `MenuGroup`'s (two runners: which
   runs first is not fixed, so each one's lines are kept together; the first development run showed both orders).
8. **javap** (`surface`, `client`): the annotation lines and their `version()` (2 of 23 lines … the class lines and the attribute, 4); `-v`
   on `ApiversionProperties` kept to the field and its annotation (4 of 150), the setter counted.
9. **A′ against A** (`asame`): A's block and A′'s, their labels aside, compared line for line in the capture itself ("yes").
10. **No duration** anywhere (⚑10). **On this Mac**: `lsof` by pid (or by port), the address column alone — never a command name (R.18).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops TiffinBox (`$pid`), the stub (`$spid`) and the
exercise's shell (`$xpid`, with every process under it — `killtree`), sweeps its own process group for any TiffinBox JVM, stub or Maven
left, deletes the capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched. No `wait`
is bare: each names its pid (R.105; a check refuses a bare one); nothing is stopped by name (a check refuses `pkill` and `killall`).
**Measured (2026-10-29):** `./receipts.sh` started in a session of its own with SIGINT at its default disposition; `kill -INT` to its
process group while `client`'s stub (127.0.0.1:19587) and a TiffinBox (127.0.0.1:19580) were both listening → **exit 130**; afterwards
nothing listened on 19580-19589, no process of that group was left (the stub included), `.r-lock` was gone, and the eight published
captures were byte for byte what they were before. **Measured again (BLUE S6, 2026-10-30), during the new zsh run:** SIGINT to the
run's group once the exercise's `/bin/zsh -f` shell had TiffinBox listening on 19585 → `processes in the group at SIGINT 6 · exit 130 ·
5 s later in the group: 0 · TiffinBox/stub/zsh-exercise processes anywhere: 0 · ports listening: none · .r-lock: no · unfinished runs: 0 ·
captures unchanged: yes`. (A first try, launched as a background job of a non-interactive shell, ran to its
end: such a job starts with SIGINT ignored, and a shell cannot trap a signal it was started ignoring — the test was re-made, not the
script.)

## 1 · surface — the attribute, the keys, the classes — read off the jars; the seven

`.r-surface.out`, md5 `fc139d7a46b1c07918320bca18548aee`, 3 of 3 — whole:

```
the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline), its jar extracted (the README's line):
$ cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the anchor · offline: yes · exit 0
$ cd .harness/anchor && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
  the anchor's libraries (its extracted lib/): 61 · Boot's RestClient module among them: 0 · httpclient5: 0
the seven - the anchor, the README's run line (its locale pinned), port 19580, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19580
  listens on: 127.0.0.1:19580 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19580/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19580 .harness/anchor/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 application/problem+json  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"}
  GET   /shutdown   -> 405 application/problem+json  {"detail":"Method 'GET' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  the log's lines during the seven: 3 · its WARN and ERROR records among them: 1
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0 · lines that say "deprecat": 0
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
$ javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:.harness/xlib/*" harness/probe/web/Deprecations.java harness/probe/web/Menu.java harness/probe/web/MenuApi.java harness/probe/web/MenuGroup.java harness/probe/web/MenuPath.java harness/probe/web/Versions.java
  exit 0 · what javac printed: 0 lines · its classes: probe/web/Deprecations.class probe/web/Menu.class probe/web/MenuApi.class probe/web/MenuGroup.class probe/web/MenuPath.class probe/web/Versions.class
the version attribute - the two mapping annotations, read off spring-web (this unit's line):
$ javap -cp .harness/anchor/tiffinbox-web/target/extracted/lib/spring-web-7.0.9.jar org.springframework.web.bind.annotation.GetMapping org.springframework.web.bind.annotation.RequestMapping
  what javap printed: 23 lines · kept: each annotation's line and its version attribute, 4 lines
  public interface org.springframework.web.bind.annotation.GetMapping extends java.lang.annotation.Annotation
    public abstract java.lang.String version();
  public interface org.springframework.web.bind.annotation.RequestMapping extends java.lang.annotation.Annotation
    public abstract java.lang.String version();
the harness's handlers - one path, three versions, and the same three in the path (this unit's line):
$ grep -n -E 'GetMapping\(|^public class' harness/probe/web/Menu.java harness/probe/web/MenuPath.java
  harness/probe/web/Menu.java:15:public class Menu {
  harness/probe/web/Menu.java:20:    @GetMapping(path = "/menu", version = "1.0")
  harness/probe/web/Menu.java:25:    @GetMapping(path = "/menu", version = "1.1+")
  harness/probe/web/Menu.java:30:    @GetMapping(path = "/menu", version = "2.0")
  harness/probe/web/MenuPath.java:10:public class MenuPath {
  harness/probe/web/MenuPath.java:11:    @GetMapping(path = "/api/{v}/menu", version = "1.0")
  harness/probe/web/MenuPath.java:14:    @GetMapping(path = "/api/{v}/menu", version = "1.1+")
  harness/probe/web/MenuPath.java:17:    @GetMapping(path = "/api/{v}/menu", version = "2.0")
  mappings with a version: 6 · on /menu: 3 · in TiffinBox's own sources: 0
Boot's keys - what spring-boot-webmvc's own metadata declares under spring.mvc.apiversion (this unit's line):
$ python3 harness/keys.py .harness/anchor/tiffinbox-web/target/extracted/lib/spring-boot-webmvc-4.1.1.jar spring.mvc.apiversion
  spring.mvc.apiversion.default · default none · String
  spring.mvc.apiversion.detect-supported · default none · Boolean
  spring.mvc.apiversion.required · default none · Boolean
  spring.mvc.apiversion.supported · default none · String>
  spring.mvc.apiversion.use.header · default none · String
  spring.mvc.apiversion.use.media-type-parameter · default none · String>
  spring.mvc.apiversion.use.path-segment · default none · Integer
  spring.mvc.apiversion.use.query-parameter · default none · String
  8 keys under spring.mvc.apiversion
  the types keys.py cut, whole (it keeps what follows the last dot): supported java.util.List<java.lang.String> · media-type-parameter java.util.Map<org.springframework.http.MediaType,java.lang.String>
the versioning classes - every class of spring-web-7.0.9.jar's org.springframework.web.accept whose name says ApiVersion, inner classes aside, read with javap (its declaration line):
  public interface ApiVersionDeprecationHandler
  public final class ApiVersionHolder
  public interface ApiVersionParser<V extends java.lang.Comparable<V>>
  public interface ApiVersionResolver
  public interface ApiVersionStrategy
  public class DefaultApiVersionStrategy implements ApiVersionStrategy
  public class HeaderApiVersionResolver implements ApiVersionResolver
  public class InvalidApiVersionException extends ResponseStatusException
  public class MediaTypeParamApiVersionResolver implements ApiVersionResolver
  public class MissingApiVersionException extends ResponseStatusException
  public class NotAcceptableApiVersionException extends InvalidApiVersionException
  public class PathApiVersionResolver implements ApiVersionResolver
  public class QueryApiVersionResolver implements ApiVersionResolver
  public class SemanticApiVersionParser implements ApiVersionParser<SemanticApiVersionParser$Version>
  public class StandardApiVersionDeprecationHandler implements ApiVersionDeprecationHandler
  the classes that implement ApiVersionResolver - the places a version is read: HeaderApiVersionResolver MediaTypeParamApiVersionResolver PathApiVersionResolver QueryApiVersionResolver
  the exceptions, each followed up its parents to the first class outside the package:
    InvalidApiVersionException -> ResponseStatusException
    MissingApiVersionException -> ResponseStatusException
    NotAcceptableApiVersionException -> InvalidApiVersionException -> ResponseStatusException
whose classes - each read off the one jar on that class path that holds it (unzip -l, by name):
  org.springframework.web.bind.annotation.GetMapping · in: spring-web-7.0.9.jar
  org.springframework.web.accept.ApiVersionStrategy · in: spring-web-7.0.9.jar
  org.springframework.web.accept.StandardApiVersionDeprecationHandler · in: spring-web-7.0.9.jar
  org.springframework.web.client.ApiVersionInserter · in: spring-web-7.0.9.jar
  org.springframework.web.servlet.config.annotation.ApiVersionConfigurer · in: spring-webmvc-7.0.9.jar
  org.springframework.boot.webmvc.autoconfigure.WebMvcProperties$Apiversion · in: spring-boot-webmvc-4.1.1.jar
  org.springframework.boot.http.client.autoconfigure.ApiversionProperties · in: spring-boot-http-client-4.1.1.jar
```

## 2 · strategy — A/B/A′: a header strategy with a default; no strategy key; A again

`.r-strategy.out`, md5 `da872447bb02e32acaf3e0c6e7422e0c`, 3 of 3 — whole:

```
A - a header strategy with a default: the harness's Menu and Versions joined, the header API-Version, 1.0 for a request without one, port 19580, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19580 --spring.main.sources=probe.web.Menu,probe.web.Versions --spring.mvc.apiversion.use.header=API-Version --spring.mvc.apiversion.default=1.0
  listens on: 127.0.0.1:19580 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19580/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Versions): en_US
  the harness's lines (Versions', in the order they printed, then MenuGroup's): 2
    done
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' -H 'API-Version: 1.0' http://127.0.0.1:19580/menu
  -> 200 application/json · {"handler":"1.0","body":["Meera","Priya","Ravi","Sunil"]}
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' -H 'API-Version: 1.1' http://127.0.0.1:19580/menu
  -> 200 application/json · {"handler":"1.1+","body":4}
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' -H 'API-Version: 2.0' http://127.0.0.1:19580/menu
  -> 200 application/json · {"handler":"2.0","body":24300}
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' http://127.0.0.1:19580/menu
  -> 200 application/json · {"handler":"1.0","body":["Meera","Priya","Ravi","Sunil"]}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19580 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19580 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the same handlers, no spring.mvc.apiversion key, port 19581, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19581 --spring.main.sources=probe.web.Menu,probe.web.Versions
  exit 1 · listening on 19581: 0 (lsof, by port) · readiness never asked · Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
  its WARN and ERROR records:
    WARN ConfigServletWebServerApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'requestMappingHandlerMapping' defined in class path resource [org/springframework/boot/webmvc/autoconfigure/WebMvcAutoConfiguration$EnableWebMvcConfiguration.class]: Invalid mapping on handler class [probe.web.Menu]: <the first handler method the scan met>
      its stack frames: 0, its other lines: 0 - none shown
    ERROR o.s.boot.SpringApplication: Application run failed
      org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'requestMappingHandlerMapping' defined in class path resource [org/springframework/boot/webmvc/autoconfigure/WebMvcAutoConfiguration$EnableWebMvcConfiguration.class]: Invalid mapping on handler class [probe.web.Menu]: <the first handler method the scan met>
      its stack frames: 37, its other lines: 6 - none shown
  its "Caused by:" lines, in the order they printed: 2 - the last is the root cause
    Caused by: java.lang.IllegalStateException: Invalid mapping on handler class [probe.web.Menu]: <the first handler method the scan met>
    Caused by: java.lang.IllegalStateException: API version specified, but no ApiVersionStrategy configured
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, port 19580, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19580 --spring.main.sources=probe.web.Menu,probe.web.Versions --spring.mvc.apiversion.use.header=API-Version --spring.mvc.apiversion.default=1.0
  listens on: 127.0.0.1:19580 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19580/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Versions): en_US
  the harness's lines (Versions', in the order they printed, then MenuGroup's): 2
    done
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' -H 'API-Version: 1.0' http://127.0.0.1:19580/menu
  -> 200 application/json · {"handler":"1.0","body":["Meera","Priya","Ravi","Sunil"]}
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' -H 'API-Version: 1.1' http://127.0.0.1:19580/menu
  -> 200 application/json · {"handler":"1.1+","body":4}
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' -H 'API-Version: 2.0' http://127.0.0.1:19580/menu
  -> 200 application/json · {"handler":"2.0","body":24300}
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' http://127.0.0.1:19580/menu
  -> 200 application/json · {"handler":"1.0","body":["Meera","Priya","Ravi","Sunil"]}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19580 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19580 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
```

## 3 · where — one fresh JVM per strategy — header, query, media type, path — and the version sent somewhere else

`.r-where.out`, md5 `0af0fe7e60f90cf3d15c3cc3fd7db62d`, 3 of 3 — whole:

```
  19589, never bound: listening 0 (lsof, by port)
the header - Menu and Versions, the header API-Version, no default, port 19580, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19580 --spring.main.sources=probe.web.Menu,probe.web.Versions --spring.mvc.apiversion.use.header=API-Version
  listens on: 127.0.0.1:19580 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19580/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Versions): en_US
  the harness's lines (Versions', in the order they printed, then MenuGroup's): 2
    done
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' -H 'API-Version: 1.0' http://127.0.0.1:19580/menu
  -> 200 application/json · {"handler":"1.0","body":["Meera","Priya","Ravi","Sunil"]}
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' -H 'API-Version: 1.1' http://127.0.0.1:19580/menu
  -> 200 application/json · {"handler":"1.1+","body":4}
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' -H 'API-Version: 2.0' http://127.0.0.1:19580/menu
  -> 200 application/json · {"handler":"2.0","body":24300}
  the control - the version in the query instead:
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' http://127.0.0.1:19580/menu?version=1.0
  -> 400 application/problem+json · {"detail":"API version is required.","instance":"/menu","status":400,"title":"Bad Request"}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19580 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 400 application/problem+json · Content-Length: none · {"detail":"API version is required.","instance":"/shutdown","status":400,"title":"Bad Request"} · curl exit 0
  POST /shutdown answered 400: stopped by its pid · exit 143 · listening on 19580 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the query parameter - Menu and Versions, the parameter version, no default, port 19581, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19581 --spring.main.sources=probe.web.Menu,probe.web.Versions --spring.mvc.apiversion.use.query-parameter=version
  listens on: 127.0.0.1:19581 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19581/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Versions): en_US
  the harness's lines (Versions', in the order they printed, then MenuGroup's): 2
    done
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' http://127.0.0.1:19581/menu?version=1.0
  -> 200 application/json · {"handler":"1.0","body":["Meera","Priya","Ravi","Sunil"]}
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' http://127.0.0.1:19581/menu?version=1.1
  -> 200 application/json · {"handler":"1.1+","body":4}
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' http://127.0.0.1:19581/menu?version=2.0
  -> 200 application/json · {"handler":"2.0","body":24300}
  the control - the version in the header instead:
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' -H 'API-Version: 1.0' http://127.0.0.1:19581/menu
  -> 400 application/problem+json · {"detail":"API version is required.","instance":"/menu","status":400,"title":"Bad Request"}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19581 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 400 application/problem+json · Content-Length: none · {"detail":"API version is required.","instance":"/shutdown","status":400,"title":"Bad Request"} · curl exit 0
  POST /shutdown answered 400: stopped by its pid · exit 143 · listening on 19581 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the media-type parameter - Menu and Versions, the parameter v of application/json, no default, port 19582, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19582 --spring.main.sources=probe.web.Menu,probe.web.Versions '--spring.mvc.apiversion.use.media-type-parameter[application/json]=v'
  listens on: 127.0.0.1:19582 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19582/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Versions): en_US
  the harness's lines (Versions', in the order they printed, then MenuGroup's): 2
    done
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' -H 'Accept: application/json;v=1.0' http://127.0.0.1:19582/menu
  -> 200 application/json;v=1.0 · {"handler":"1.0","body":["Meera","Priya","Ravi","Sunil"]}
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' -H 'Accept: application/json;v=1.1' http://127.0.0.1:19582/menu
  -> 200 application/json;v=1.1 · {"handler":"1.1+","body":4}
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' -H 'Accept: application/json;v=2.0' http://127.0.0.1:19582/menu
  -> 200 application/json;v=2.0 · {"handler":"2.0","body":24300}
  the control - the parameter on Content-Type instead of Accept:
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' -H 'Content-Type: application/json;v=1.0' http://127.0.0.1:19582/menu
  -> 400 application/problem+json · {"detail":"API version is required.","instance":"/menu","status":400,"title":"Bad Request"}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19582 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 400 application/problem+json · Content-Length: none · {"detail":"API version is required.","instance":"/shutdown","status":400,"title":"Bad Request"} · curl exit 0
  POST /shutdown answered 400: stopped by its pid · exit 143 · listening on 19582 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the path segment - MenuPath and Versions, the segment at index 1, no default, port 19583, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19583 --spring.main.sources=probe.web.MenuPath,probe.web.Versions --spring.mvc.apiversion.use.path-segment=1
  listens on: 127.0.0.1:19583 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19583/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Versions): en_US
  the harness's lines (Versions', in the order they printed, then MenuGroup's): 2
    done
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' http://127.0.0.1:19583/api/1.0/menu
  -> 200 application/json · {"handler":"1.0","body":"the path"}
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' http://127.0.0.1:19583/api/1.1/menu
  -> 200 application/json · {"handler":"1.1+","body":"the path"}
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' http://127.0.0.1:19583/api/2.0/menu
  -> 200 application/json · {"handler":"2.0","body":"the path"}
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' http://127.0.0.1:19583/api/v1/menu
  -> 200 application/json · {"handler":"1.0","body":"the path"}
  the control - the version in the header instead, on a path with no segment for it:
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' -H 'API-Version: 1.0' http://127.0.0.1:19583/customers
  -> 400 application/problem+json · {"detail":"Invalid API version: 'No path segment at index 1'.","instance":"/customers","status":400,"title":"Bad Request"}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19583 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 400 application/problem+json · Content-Length: none · {"detail":"Invalid API version: 'No path segment at index 1'.","instance":"/shutdown","status":400,"title":"Bad Request"} · curl exit 0
  POST /shutdown answered 400: stopped by its pid · exit 143 · listening on 19583 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 4 · unversioned — the routes that never asked: no default, the seven; required=false; a default; C problem details off

`.r-unversioned.out`, md5 `c98eacc28097f3c63186d857c3a87e67`, 3 of 3 — whole:

```
a header strategy, no default - Menu and Versions, the header API-Version, port 19580, a fresh JVM - and the seven:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19580 --spring.main.sources=probe.web.Menu,probe.web.Versions --spring.mvc.apiversion.use.header=API-Version
  listens on: 127.0.0.1:19580 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19580/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Versions): en_US
  the harness's lines (Versions', in the order they printed, then MenuGroup's): 2
    done
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' http://127.0.0.1:19580/menu
  -> 400 application/problem+json · {"detail":"API version is required.","instance":"/menu","status":400,"title":"Bad Request"}
$ $CURLSET 19580 .harness/anchor/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 400 application/problem+json  {"detail":"API version is required.","instance":"/customers","status":400,"title":"Bad Request"}
  GET   /revenue    -> 400 application/problem+json  {"detail":"API version is required.","instance":"/revenue","status":400,"title":"Bad Request"}
  GET   /dashboard  -> 400 application/problem+json  {"detail":"API version is required.","instance":"/dashboard","status":400,"title":"Bad Request"}
  GET   /kitchen    -> 400 application/problem+json  {"detail":"API version is required.","instance":"/kitchen","status":400,"title":"Bad Request"}
  GET   /nowhere    -> 404 application/problem+json  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"}
  GET   /shutdown   -> 405 application/problem+json  {"detail":"Method 'GET' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"}
  POST  /shutdown   -> 400 application/problem+json  {"detail":"API version is required.","instance":"/shutdown","status":400,"title":"Bad Request"}
  the log's lines during the seven: 1 · its WARN and ERROR records among them: 1
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
  exit 143 (POST /shutdown answered 400: stopped by its pid) · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 7d36b99ea48f2bb5fc961fbac1fd8a6a
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0 · lines that say "deprecat": 0
  against the seven on the README's run line (surface, md5 466c20ed7e0d5439cb052f32ce09de1b), line for line:
  lines that differ: 5 (1 2 3 4 7) · the same, byte for byte: 2 (5 6)
required=false - the same, and spring.mvc.apiversion.required=false, port 19581, a fresh JVM - and the seven:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19581 --spring.main.sources=probe.web.Menu,probe.web.Versions --spring.mvc.apiversion.use.header=API-Version --spring.mvc.apiversion.required=false
  listens on: 127.0.0.1:19581 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19581/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Versions): en_US
  the harness's lines (Versions', in the order they printed, then MenuGroup's): 2
    done
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' http://127.0.0.1:19581/menu
  -> 200 application/json · {"handler":"2.0","body":24300}
$ $CURLSET 19581 .harness/anchor/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 application/problem+json  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"}
  GET   /shutdown   -> 405 application/problem+json  {"detail":"Method 'GET' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  the log's lines during the seven: 3 · its WARN and ERROR records among them: 1
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0 · lines that say "deprecat": 0
  against the seven on the README's run line, line for line:
  lines that differ: 0 · the same, byte for byte: 7 (1 2 3 4 5 6 7)
a default - the header strategy and a default version, 1.0, port 19582, a fresh JVM - and the seven:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19582 --spring.main.sources=probe.web.Menu,probe.web.Versions --spring.mvc.apiversion.use.header=API-Version --spring.mvc.apiversion.default=1.0
  listens on: 127.0.0.1:19582 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19582/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Versions): en_US
  the harness's lines (Versions', in the order they printed, then MenuGroup's): 2
    done
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' http://127.0.0.1:19582/menu
  -> 200 application/json · {"handler":"1.0","body":["Meera","Priya","Ravi","Sunil"]}
$ $CURLSET 19582 .harness/anchor/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 application/problem+json  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"}
  GET   /shutdown   -> 405 application/problem+json  {"detail":"Method 'GET' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  the log's lines during the seven: 3 · its WARN and ERROR records among them: 1
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0 · lines that say "deprecat": 0
  against the seven on the README's run line, line for line:
  lines that differ: 0 · the same, byte for byte: 7 (1 2 3 4 5 6 7)
C (labelled) - the header strategy, no default, and TiffinBox's problem details switched off for this run (spring.mvc.problemdetails.enabled=false), port 19583, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19583 --spring.main.sources=probe.web.Menu,probe.web.Versions --spring.mvc.apiversion.use.header=API-Version --spring.mvc.problemdetails.enabled=false
  listens on: 127.0.0.1:19583 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19583/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Versions): en_US
  the harness's lines (Versions', in the order they printed, then MenuGroup's): 2
    done
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' http://127.0.0.1:19583/menu
  -> 400 application/json · {"timestamp":"…","status":400,"error":"Bad Request","path":"/menu"}
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' http://127.0.0.1:19583/customers
  -> 400 application/json · {"timestamp":"…","status":400,"error":"Bad Request","path":"/customers"}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19583 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 400 application/json · Content-Length: none · {"timestamp":"…","status":400,"error":"Bad Request","path":"/shutdown"} · curl exit 0
  POST /shutdown answered 400: stopped by its pid · exit 143 · listening on 19583 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 5 · baseline — 1.1+: 1.1, 1.2, 1; then 1.2 supported

`.r-baseline.out`, md5 `e71dea9fb71af2162d36c6059d1ed082`, 3 of 3 — whole:

```
the baseline - the header strategy, a default of 1.0, port 19580, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19580 --spring.main.sources=probe.web.Menu,probe.web.Versions --spring.mvc.apiversion.use.header=API-Version --spring.mvc.apiversion.default=1.0
  listens on: 127.0.0.1:19580 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19580/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Versions): en_US
  the harness's lines (Versions', in the order they printed, then MenuGroup's): 2
    done
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' -H 'API-Version: 1.1' http://127.0.0.1:19580/menu
  -> 200 application/json · {"handler":"1.1+","body":4}
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' -H 'API-Version: 1.2' http://127.0.0.1:19580/menu
  -> 400 application/problem+json · {"detail":"Invalid API version: '1.2.0'.","instance":"/menu","status":400,"title":"Bad Request"}
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' -H 'API-Version: 1' http://127.0.0.1:19580/menu
  -> 200 application/json · {"handler":"1.0","body":["Meera","Priya","Ravi","Sunil"]}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19580 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19580 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
1.2 made a supported version - the same, and spring.mvc.apiversion.supported=1.2, port 19581, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19581 --spring.main.sources=probe.web.Menu,probe.web.Versions --spring.mvc.apiversion.use.header=API-Version --spring.mvc.apiversion.default=1.0 --spring.mvc.apiversion.supported=1.2
  listens on: 127.0.0.1:19581 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19581/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Versions): en_US
  the harness's lines (Versions', in the order they printed, then MenuGroup's): 2
    done
$ curl -s -o .harness/body.txt -w '%{http_code} %{content_type}' -H 'API-Version: 1.2' http://127.0.0.1:19581/menu
  -> 200 application/json · {"handler":"1.1+","body":4}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19581 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19581 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 6 · deprecation — 1.0 marked for removal — read off the headers; the seven beside them; the mappings

`.r-deprecation.out`, md5 `242ecc7cd8e189594d3a24406c3111a9`, 3 of 3 — whole:

```
1.0 marked for removal - Menu, Versions and Deprecations, the header strategy, a default of 1.0, port 19580, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19580 --spring.main.sources=probe.web.Menu,probe.web.Versions,probe.web.Deprecations --spring.mvc.apiversion.use.header=API-Version --spring.mvc.apiversion.default=1.0
  listens on: 127.0.0.1:19580 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19580/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Versions): en_US
  the harness's lines (Versions', in the order they printed, then MenuGroup's): 2
    done
$ curl -s -D .harness/head.txt -o .harness/body.txt -w '%{http_code}' -H 'API-Version: 1.0' http://127.0.0.1:19580/menu
  -> 200 · its header lines: 7 · kept, by ^(Deprecation|Sunset|Link|Content-Type): (any case): 4
    Deprecation: @1790812800
    Link: <http://127.0.0.1/docs/menu-1.0>; rel="deprecation"; type="text/html"
    Sunset: Thu, 1 Apr 2027 00:00:00 GMT
    Content-Type: application/json
    its body: {"handler":"1.0","body":["Meera","Priya","Ravi","Sunil"]}
$ curl -s -D .harness/head.txt -o .harness/body.txt -w '%{http_code}' -H 'API-Version: 2.0' http://127.0.0.1:19580/menu
  -> 200 · its header lines: 4 · kept, by ^(Deprecation|Sunset|Link|Content-Type): (any case): 1
    Content-Type: application/json
    its body: {"handler":"2.0","body":24300}
  an unversioned route, no version sent:
$ curl -s -D .harness/head.txt -o .harness/body.txt -w '%{http_code}' http://127.0.0.1:19580/customers
  -> 200 · its header lines: 7 · kept, by ^(Deprecation|Sunset|Link|Content-Type): (any case): 4
    Deprecation: @1790812800
    Link: <http://127.0.0.1/docs/menu-1.0>; rel="deprecation"; type="text/html"
    Sunset: Thu, 1 Apr 2027 00:00:00 GMT
    Content-Type: application/json
    its body: [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
$ $CURLSET 19580 .harness/anchor/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 application/problem+json  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"}
  GET   /shutdown   -> 405 application/problem+json  {"detail":"Method 'GET' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  the log's lines during the seven: 3 · its WARN and ERROR records among them: 1
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0 · lines that say "deprecat": 0
  against the seven on the README's run line, line for line:
  lines that differ: 0 · the same, byte for byte: 7 (1 2 3 4 5 6 7)
the mappings - Menu and Versions, the header strategy, a default of 1.0, and Actuator's mappings endpoint exposed for this run only, port 19581, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19581 --spring.main.sources=probe.web.Menu,probe.web.Versions --spring.mvc.apiversion.use.header=API-Version --spring.mvc.apiversion.default=1.0 --management.endpoints.web.exposure.include=health,prometheus,mappings
  listens on: 127.0.0.1:19581 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19581/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Versions): en_US
  the harness's lines (Versions', in the order they printed, then MenuGroup's): 2
    done
$ curl -s -o .harness/mappings.json -w ' %{http_code}\n' http://127.0.0.1:19581/actuator/mappings
   200
  the predicates its dispatcherServlets list: 22 · kept, by the filter "/menu", sorted: 3
    {GET [/menu], version [1.0]}
    {GET [/menu], version [1.1+]}
    {GET [/menu], version [2.0]}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19581 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19581 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 7 · client — the other end: the stub, the inserters, the media-type pair end to end, the service group's keys

`.r-client.out`, md5 `f41a42073b0c7914974f0a8c4fee62d6`, 3 of 3 — whole:

```
the stub - this folder's copy against the RestClient lesson's ($S25), md5 for md5 (this unit's line):
$ for f in Stub.java www/customers.json www/meera.json www/priya.json www/ravi.json www/sunil.json; do echo "$(md5 -q "harness/stub/$f") $(md5 -q "$S25/$f") $f"; done
  42b656ddba1e9f80107495c65dacc975 42b656ddba1e9f80107495c65dacc975 Stub.java
  4d31cc0a22001b3e7c32039403f1e169 4d31cc0a22001b3e7c32039403f1e169 www/customers.json
  9c7a89abebc65ff24084c7dc20334945 9c7a89abebc65ff24084c7dc20334945 www/meera.json
  aac4c7331ac8d1c6582f98cd75be6e0a aac4c7331ac8d1c6582f98cd75be6e0a www/priya.json
  17fcfbe710b521778d2df671dcf74cc3 17fcfbe710b521778d2df671dcf74cc3 www/ravi.json
  8fcb5f742744e02a06c3f06606272b26 8fcb5f742744e02a06c3f06606272b26 www/sunil.json
  the same md5, file by file: 6 of 6 · routes this unit adds to it: 0
two types named HttpExchange - the stub's (the JDK server's) and the interface's (Spring's), each line with its file (this unit's line):
$ grep -n 'HttpExchange' harness/stub/Stub.java harness/probe/web/MenuApi.java
  harness/stub/Stub.java:89:void send(HttpExchange ex, int code, String type, String body) throws java.io.IOException {
  harness/probe/web/MenuApi.java:4:import org.springframework.web.service.annotation.HttpExchange;
  harness/probe/web/MenuApi.java:6:/** The course's harness: an HTTP interface (Spring's @HttpExchange, org.springframework.web.service.annotation - not the JDK
  harness/probe/web/MenuApi.java:7: *  server's com.sun.net.httpserver.HttpExchange, which the stub uses) for two of the stub's files. names() asks for no version;
  harness/probe/web/MenuApi.java:9:@HttpExchange
the stub - this unit's line, port 19587:
$ java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19587 --www=harness/stub/www
  the stub listens on: 127.0.0.1:19587 · loopback only: yes · its locale: en_US
the inserters - Menu and Versions, the header strategy, no default, the cases header, query, path, media, mediapost, none and selfheader (RestClient.builder() with one inserter each, every call asking for 1.1), port 19580, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19580 --spring.main.sources=probe.web.Menu,probe.web.Versions --spring.mvc.apiversion.use.header=API-Version --probe.stub=http://127.0.0.1:19587 --probe.self=http://127.0.0.1:19580 --probe.cases=header,query,path,media,mediapost,none,selfheader
  listens on: 127.0.0.1:19580 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19580/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Versions): en_US
  the harness's lines (Versions', in the order they printed, then MenuGroup's): 9
    header -> 200 OK
    query -> 200 OK
    path !! org.springframework.web.client.HttpClientErrorException$NotFound: 404 Not Found: "not found"
    media -> 200 OK
    mediapost -> 201 CREATED
    none !! java.lang.IllegalStateException: No ApiVersionInserter configured
    selfheader -> {"handler":"1.1+","body":4}
    done
  the stub's dump since, one line a request:
    GET /customers.json · api-version: 1.1 · accept: application/json · content-type: none · headers: 9 · the stub answered 200 application/json 307 bytes
    GET /customers.json?version=1.1 · api-version: none · accept: application/json · content-type: none · headers: 8 · the stub answered 200 application/json 307 bytes
    GET /1.1/customers.json · api-version: none · accept: application/json · content-type: none · headers: 8 · the stub answered 404 text/plain 9 bytes
    GET /customers.json · api-version: none · accept: application/json · content-type: none · headers: 8 · the stub answered 200 application/json 307 bytes
    POST /payments · api-version: none · accept: application/json · content-type: application/json;v=1.1 · headers: 10 · the stub answered 201 application/json 62 bytes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19580 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 400 application/problem+json · Content-Length: none · {"detail":"API version is required.","instance":"/shutdown","status":400,"title":"Bad Request"} · curl exit 0
  POST /shutdown answered 400: stopped by its pid · exit 143 · listening on 19580 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the media-type pair end to end - Menu and Versions, the media-type strategy, no default, the case selfmedia (the media-type inserter, Accept: application/json, 1.1, to this JVM's /menu), port 19581, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19581 --spring.main.sources=probe.web.Menu,probe.web.Versions '--spring.mvc.apiversion.use.media-type-parameter[application/json]=v' --probe.self=http://127.0.0.1:19581 --probe.cases=selfmedia
  listens on: 127.0.0.1:19581 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19581/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Versions): en_US
  the harness's lines (Versions', in the order they printed, then MenuGroup's): 3
    selfmedia !! org.springframework.web.client.HttpClientErrorException$BadRequest: 400 Bad Request: "{"detail":"API version is required.","instance":"/menu","status":400,"title":"Bad Request"}"
    done
  the stub's dump since, one line a request:
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19581 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 400 application/problem+json · Content-Length: none · {"detail":"API version is required.","instance":"/shutdown","status":400,"title":"Bad Request"} · curl exit 0
  POST /shutdown answered 400: stopped by its pid · exit 143 · listening on 19581 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the group's default version - the field it binds to, read with javap -v (this unit's line), kept to the field and its annotation:
$ javap -v -p -cp .harness/xlib/spring-boot-http-client-4.1.1.jar org.springframework.boot.http.client.autoconfigure.ApiversionProperties
  what javap printed: 150 lines · kept: 4 lines
    private java.lang.String defaultVersion;
    RuntimeVisibleAnnotations:
    org.springframework.boot.context.properties.bind.Name(
    value="default"
  its setter: 1 (setDefaultVersion)
the group - MenuGroup and Versions, the group menu's base URL, its version in the header API-Version, its default version 1.1 (...apiversion.default), port 19582, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19582 --spring.main.sources=probe.web.MenuGroup,probe.web.Versions --spring.http.serviceclient.menu.base-url=http://127.0.0.1:19587 --spring.http.serviceclient.menu.apiversion.insert.header=API-Version --spring.http.serviceclient.menu.apiversion.default=1.1
  listens on: 127.0.0.1:19582 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19582/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Versions): en_US
  the harness's lines (Versions', in the order they printed, then MenuGroup's): 5
    done
    group ravi -> 73 characters
    group meera -> 73 characters
    group done
  the stub's dump since, one line a request:
    GET /ravi.json · api-version: 1.1 · accept: none · content-type: none · headers: 8 · the stub answered 200 application/json 73 bytes
    GET /meera.json · api-version: 2.0 · accept: none · content-type: none · headers: 8 · the stub answered 200 application/json 73 bytes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19582 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19582 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - the same, the default version spelled by the setter's name (...apiversion.default-version), port 19583, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19583 --spring.main.sources=probe.web.MenuGroup,probe.web.Versions --spring.http.serviceclient.menu.base-url=http://127.0.0.1:19587 --spring.http.serviceclient.menu.apiversion.insert.header=API-Version --spring.http.serviceclient.menu.apiversion.default-version=1.1
  listens on: 127.0.0.1:19583 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19583/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Versions): en_US
  the harness's lines (Versions', in the order they printed, then MenuGroup's): 5
    done
    group ravi -> 73 characters
    group meera -> 73 characters
    group done
  the stub's dump since, one line a request:
    GET /ravi.json · api-version: none · accept: none · content-type: none · headers: 7 · the stub answered 200 application/json 73 bytes
    GET /meera.json · api-version: 2.0 · accept: none · content-type: none · headers: 8 · the stub answered 200 application/json 73 bytes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19583 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19583 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
no group keys for the version - the base URL alone, port 19584, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19584 --spring.main.sources=probe.web.MenuGroup,probe.web.Versions --spring.http.serviceclient.menu.base-url=http://127.0.0.1:19587
  listens on: 127.0.0.1:19584 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19584/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Versions): en_US
  the harness's lines (Versions', in the order they printed, then MenuGroup's): 5
    done
    group ravi -> 73 characters
    group meera -> 73 characters
    group done
  the stub's dump since, one line a request:
    GET /ravi.json · api-version: none · accept: none · content-type: none · headers: 7 · the stub answered 200 application/json 73 bytes
    GET /meera.json · api-version: none · accept: none · content-type: none · headers: 7 · the stub answered 200 application/json 73 bytes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19584 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19584 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the stub: stopped by its pid · exit 143 · listening on 19587 now: 0 · requests in its dump: 11 · the demo token 0 times · X-Shutdown-Token 0 times
```

## 8 · exercise — the exercise, run as written, in one bash shell, then in one zsh shell

`.r-exercise.out`, md5 `55838e7e6d445cd0b2b5d305570db900`, 3 of 3 — whole:

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 8 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/
  $ mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
  $ CURLSET="$PWD/../c5-unit11/curlset.sh"
  $ V=(--spring.mvc.apiversion.use.header=API-Version)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19585 "${V[@]}" > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19585/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && "$CURLSET" 19585 secrets/tiffinbox/shutdown-token > ../seven.txt && if grep -qE '^POST +/shutdown +-> 2' ../seven.txt; then how="POST /shutdown"; else kill "$p" && how="its pid - POST /shutdown answered $(grep -E '^POST +/shutdown' ../seven.txt | awk '{ print $4 }')"; fi && { wait "$p"; echo "the seven: md5 $(md5 -q ../seven.txt) · answered 400: $(grep -c -- ' -> 400 ' ../seven.txt) · TiffinBox stopped by: $how"; })
  exit 0 · what they printed:
    the seven: md5 7d36b99ea48f2bb5fc961fbac1fd8a6a · answered 400: 5 · TiffinBox stopped by: its pid - POST /shutdown answered 400
  the seven it saved (.harness/mine/seven.txt, kept before the solution's run):
    GET   /customers  -> 400 application/problem+json  {"detail":"API version is required.","instance":"/customers","status":400,"title":"Bad Request"}
    GET   /revenue    -> 400 application/problem+json  {"detail":"API version is required.","instance":"/revenue","status":400,"title":"Bad Request"}
    GET   /dashboard  -> 400 application/problem+json  {"detail":"API version is required.","instance":"/dashboard","status":400,"title":"Bad Request"}
    GET   /kitchen    -> 400 application/problem+json  {"detail":"API version is required.","instance":"/kitchen","status":400,"title":"Bad Request"}
    GET   /nowhere    -> 404 application/problem+json  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"}
    GET   /shutdown   -> 405 application/problem+json  {"detail":"Method 'GET' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"}
    POST  /shutdown   -> 400 application/problem+json  {"detail":"API version is required.","instance":"/shutdown","status":400,"title":"Bad Request"}
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times, in the seven: 0 times · WARN lines in its log: 1 · ERROR lines: 0 · listening on 19585 now: 0
the solution's 5 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ CURLSET="$PWD/../c5-unit11/curlset.sh"
  $ V=(--spring.mvc.apiversion.use.header=API-Version --spring.mvc.apiversion.default=1.0)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19585 "${V[@]}" > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19585/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && "$CURLSET" 19585 secrets/tiffinbox/shutdown-token > ../seven.txt && if grep -qE '^POST +/shutdown +-> 2' ../seven.txt; then how="POST /shutdown"; else kill "$p" && how="its pid - POST /shutdown answered $(grep -E '^POST +/shutdown' ../seven.txt | awk '{ print $4 }')"; fi && { wait "$p"; echo "the seven: md5 $(md5 -q ../seven.txt) · answered 400: $(grep -c -- ' -> 400 ' ../seven.txt) · TiffinBox stopped by: $how"; })
  exit 0 · what they printed:
    the seven: md5 466c20ed7e0d5439cb052f32ce09de1b · answered 400: 0 · TiffinBox stopped by: POST /shutdown
  the seven it saved:
    GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
    GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
    GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
    GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
    GET   /nowhere    -> 404 application/problem+json  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"}
    GET   /shutdown   -> 405 application/problem+json  {"detail":"Method 'GET' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"}
    POST  /shutdown   -> 200 application/json  {"stopping":true}
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times, in the seven: 0 times · WARN lines in its log: 1 · ERROR lines: 0 · listening on 19585 now: 0
the same two blocks again, in ONE new shell - env -i, /bin/zsh -f (zsh, the Mac's Terminal shell; it never splits an unquoted variable):
  the README's lines: exit 0 · what they printed:
    the seven: md5 7d36b99ea48f2bb5fc961fbac1fd8a6a · answered 400: 5 · TiffinBox stopped by: its pid - POST /shutdown answered 400
  the solution's lines: exit 0 · what they printed:
    the seven: md5 466c20ed7e0d5439cb052f32ce09de1b · answered 400: 0 · TiffinBox stopped by: POST /shutdown
  the shell is now in: this unit's folder · its copy's own token in its log: 0 times, in the seven: 0 times · listening on 19585 now: 0
```


## Exercise

`exercise/README.md`: **Your turn:** the README turns on header versioning, and old routes now answer four hundred. Give unversioned
requests a version, and run the seven again. (25 words.) As shipped — `V=(--spring.mvc.apiversion.use.header=API-Version)` on TiffinBox's
own jar — the seven hash `7d36b99ea48f2bb5fc961fbac1fd8a6a` (5 answer 400) and POST /shutdown answers 400, so the line stops TiffinBox by
its pid and says so; the solution (`exercise/solution/SOLUTION.md`) adds `--spring.mvc.apiversion.default=1.0` → `466c20ed7e0d5439cb052f32ce09de1b`,
stopped by POST /shutdown. "Run the seven again" is the README's `$CURLSET` line (`../c5-unit11/curlset.sh PORT TOKENFILE`). Both ran in
ONE `env -i` `/bin/bash` shell, the README's block then the solution's, as a viewer pastes them (`exercise`), and again in ONE `env -i`
`/bin/zsh -f` shell — the same two lines (RED S6 #527: the options travel as an array, `"${V[@]}"`, so zsh hands them over as two
words); a second run in the same shell starts a fresh copy and a fresh JVM (S6.4); `JAVA_HOME` is exported first (the Mac's
`/usr/bin/java` 23 can neither compile nor run the anchor's Java 25 classes — class file 69, `UnsupportedClassVersionError` at run, RED
S6 #518; with none, Homebrew's `mvn` runs on 26 and the build succeeds, then the run fails on 23). **Re-run by BLUE S6
(2026-10-30), outside the receipt:** README + SOLUTION + SOLUTION in one `env -i /bin/zsh -f` shell and in one `env -i` bash shell →
`7d36b99e… · 5 · its pid`, then `466c20ed… · 0 · POST /shutdown` twice, the shell back in this folder; SOLUTION alone with `/usr/bin`
(java 23.0.1) first and `JAVA_HOME` unset → `466c20ed… · 0 · POST /shutdown`, under each shell; 19585 free after each.

## The ledger rows and hand-offs this unit pays

- **C6-19** (Med) — Course 5's lines, read off disk 2026-10-29: `spring-boot/scripts-and-decks/28-boot-4-and-framework-7-what-changed.md:153`
  (spoken) "Framework seven's request mappings take a version, for versioned APIs. TiffinBox has no Spring Web yet, so that one belongs to
  the next course."; `c5-unit28/README.md:597` (row 4) "`version()` on `@RequestMapping`/`@GetMapping` in spring-web 7.0.9; not on
  TiffinBox's class path; 6.2 not counted" and `:614` "API versioning is named with its Course 6 lesson." **Paid:** the attribute is read
  off spring-web 7.0.9 by javap (`surface`: `public abstract java.lang.String version();` on both annotations) and used on TiffinBox's own
  data (`Menu`); Boot's eight keys; the four resolvers; the start failure; the unversioned trap; deprecation; the client side.
- **The roadmap's "built-in version mapping; header vs path vs media type" and "⚠ verify GA surface"** — GA in Framework 7.0.9 and Boot
  4.1.1, read off the jars (`surface`), the four places measured (`where`; the query parameter is the jar's fourth).
- **S5 CARRIED — the client side with Section 5's stub** (`client`): every inserter's line in the stub's dump; the group's keys by effect.
- **C6-31** (glosses) — API versioning, a version strategy, a default version, a baseline version, deprecation, sunset (re-glossed), a stub
  (re-gloss), a service group (re-gloss): each spoken at first use (the builder checks).
- **H-28** — Course 6's previous lesson's up-next named this lesson's title; this lesson's up-next names *Web Layer Performance*
  (`java6_series.TITLES["30"]`).

## RE-MEASURE — the brief's items this unit settles

| # | Item | Settled |
|---|---|---|
| 1 | Every 29 capture on `c6-unit28/after` + this unit's harness | all eight captures, here |
| 2 | 29's stub as its own copy, md5 = 25's | `42b656ddba1e9f80107495c65dacc975`, 6 of 6 (`client`) |
| 3 | The media-type client → media-type server, end to end | **measured** (`client`, `selfmedia`): the inserter writes nothing on a GET's Accept, the media-type strategy reads Accept → **400 "API version is required."** |
| 4 | The group's `insert.query-parameter` / `path-segment` / `media-type-parameter` | not run (header only): unspoken |
| 17 | The exercise as viewers run it (one `env -i` shell; `JAVA_HOME` first) | `exercise` |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **The exercise needs no harness** (the brief's sketch ran the harness): TiffinBox's own jar with the header key alone gives the same
  seven, `7d36b99e…` — a strategy turns the unversioned routes into 400s whether or not any mapping is versioned. The exercise runs the
  plain jar, so a viewer needs no `javac`.
- **The path strategy's control** is not "required": a header sent to the path-segment JVM's `/customers` answers **400 "Invalid API version:
  'No path segment at index 1'."** — said so, never as "required".
- **The media-type pair crossed end to end** (RE-MEASURE 3): measured, 400 — no longer an inference.
- **The deprecation link** is `http://127.0.0.1/docs/menu-1.0` (the brief's `v1-retired`): the harness's text, never requested.
- **The group's `default-version`** is client's C (labelled) (R.154): Boot binds `ApiversionProperties.defaultVersion` by its
  `@Name("default")`, so the setter's kebab-case spelling — R.150's rule — binds nothing (ravi sends no version).
- **The runners' order** is not fixed (`Versions` vs `MenuGroup`): `vers` keeps each runner's lines together (found by the first run's
  drift, below).

## Found on the way

- **The two runners' order drifts** (the first development run: `client` 1 ≠ 2 ≠ 3 — `MenuGroup`'s runner and `Versions`' ran in either
  order). `vers` now prints each runner's lines together, `Versions`' first; every later run 3/3.
- **The exercise needs no harness**: TiffinBox's jar with the header key alone gives the seven `7d36b99e…` — measured in a scratch run
  before the exercise was written, then in `exercise` itself.
- **javap prints an annotation as `public interface … extends java.lang.annotation.Annotation`**, not `@interface`: the first filter kept
  nothing but the two `version()` lines; fixed to keep the declaration too (2 + 2 lines).
- **keys.py cuts a generic type at its last dot** (`String>`): `surface` prints the two cut types whole beside it (the HTTP-interface
  lesson's RED #430 pattern).
- **A path in the exercise's `CURLSET` line** (`../c5-unit11/curlset.sh`) tripped the unit-number hygiene check; the check now excepts that
  one line, exactly as written.
- **The brief's exercise line counted 26 words**; the shipped line drops one "the" (25).
- **The planted faults, 23 in all, each caught** — 22 in `receipts.sh`'s checks (19 on planted captures or files, 3 on real JVM runs with
  the fault planted in the harness or the run line) and 1 in the builder:
  1. a strategy JVM's seven checked against `466c20ed…` → `unversioned: the seven 7d36…` fails (5 differ);
  2. strategy B's root cause removed → "Framework's sentence" fails; 3. one of the eight keys dropped → "eight keys" fails (7);
  4. a key given a default → the same check fails; 5. an exception made a `RuntimeException` → "three exceptions" fails (2 of 3);
  6. three resolvers → "four resolvers" fails; 7. the media answer's `Content-Type` without `;v=1.0` → the echo check fails;
  8. 4 lines differ instead of 5 → "5 differ" fails; 9. the seven's log gained 2 lines → "the version 400s log nothing" fails;
  10. the 2.0 answer given `Deprecation` → "2.0 carries none" fails; 11. `/customers` without `Deprecation` → the header-on-unversioned
  check fails; 12. the exposure flag on a second capture → "on one run only" fails; 13. the media GET given `accept: …;v=1.1` → "the media
  inserter's GET carries no version" fails; 14. client C's ravi given `api-version: 1.1` → "the setter's spelling binds nothing" fails;
  15. one unmasked ` using Java 25.0.4.1` line → the hygiene check refuses it (R.151); 16. the failed start's handler method unmasked →
  refused; 17. the setter's spelling of the group's default written in `exercise/README.md` → R.154's check refuses it; 18. the solution's done line changed → fails;
  19. A′ ≠ A → fails; **20. (a real run) the group's default planted as the setter's spelling → `client: the group's default 1.1 on the
  wire` (`api-version: 1.1`) fails** (with the R.154 spelling check set aside for that plant: it fires first otherwise);
  **21. (a real run) the header sent to the query JVM → the query JVM's 1.0 `200` check fails** (it answered 400); **22. (a real run) the
  deprecation bean removed (`@Bean` commented out) → `Deprecation` absent, the check fails**; 23. (the builder) a slide naming the JDK's
  `com.sun.net.httpserver.HttpExchange` alone → `R.146: HttpExchange on a slide without both packages`.
- **BLUE S6 (2026-10-30), the checks RED S6 asked for, each shown failing first** (a check-only copy of `receipts.sh` — its builds and
  captures cut — on the final captures, baseline exit 0): **24.** the zsh run's solution printing the README's line (`7d36b99e…`, as the
  shipped `V="--a --b"` did in zsh) → `exercise (zsh): the solution: expected the line …466c20ed…`; **25.** the zsh run's solution exit 1 →
  `exercise (zsh): the solution's lines, exit 0`; **26.** an unquoted `$V` on both blocks' last line → `exercise/README.md passes V
  unquoted or as one string`; the same check on the README and SOLUTION as `b50b410` shipped them (`V="--a --b"`, `$V`) → refused
  (both); **27.** (the builder) the A′ panel without A′'s label and `$` line → `S6.2: an A' panel without A's label and $ line`; **28.**
  (the builder) a duration word ("quick", "3 ms", "latency") in a SAY line → `⚑10: no duration word` (the shared pattern,
  `_builders/dur6.py`, RED S6 #511).

## For RED

- Re-check **the eight-key metadata read** (`surface`: keys.py on `spring-boot-webmvc-4.1.1.jar`, `default none` for all eight, the two
  cut types whole), **the `@Name("default")` javap read** (`client`), **the seven's 5 differing lines** (`unversioned`: lines 1 2 3 4 7),
  **the header-on-unversioned claim read off headers** (`deprecation`: `/customers` with no version carries `Deprecation`, `Sunset`,
  `Link` — `curl -D`, beside the 2.0 answer without them; the seven `466c20ed…` beside it), **the media-type Content-Type/Accept pair**
  (`client`: the GET's `accept: application/json` with no `v`, the POST's `content-type: application/json;v=1.1`, and the end-to-end 400),
  and **the plants** (above).
- Ports for RED A's re-runs of this unit: 19620-19629 (brief ⚑1).
