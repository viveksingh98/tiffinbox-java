# c6-unit19 — CORS and Preflight

Course 6 · Spring Web MVC · Section 4 (The Rest of MVC), its second unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot
4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5), **headless Chrome 155.0.8059.85** driven by **node 26.0.0**, 2026-10-22.
A page served from another **origin** (scheme, host and port: `http://127.0.0.1:19486` is another origin than TiffinBox's
`http://127.0.0.1:19484`, though Chrome calls the two ports `same-site`) asks TiffinBox for its menu with a `PUT`. Before the `PUT`, the
browser sends a question of its own — an `OPTIONS` request, a **preflight**. This unit asks that question by curl, shows the three ways
Spring MVC answers it (`@CrossOrigin`, the CORS registry, a `CorsFilter`), shows the filter that answers every preflight, then runs a real
browser — and records the answer the server sent but the page never got.

**No anchor change (brief ⚑2, loser D).** `anchor` is the link to `../c6-unit16/after` — the problem-detail lesson's frozen tree,
`c6-tiffinbox` at Section 3's end (`diff -rq -x target c6-tiffinbox c6-unit16/after` empty on 2026-10-22) — read and copied under
`.harness/anchor`, never built in place; this unit freezes no `after/` and touches no other unit's folder. Everything new is **the course's
harness**, never TiffinBox's — `harness/probe/web`, outside `com.tiffinbox`, compiled with `-parameters` against the anchor's own jar and
joined by `--spring.main.sources` on the extracted jar's class path:

- `CorsRoutes` — three routes answering GET and PUT with a small map: `/probe/cors/menu` with `@CrossOrigin(origins =
  "http://127.0.0.1:19486")` (no max age set), `/probe/global/menu` and `/probe/filter/menu` with no rule of their own.
- `GlobalCors` — the same rule (that origin, GET and PUT) for `/probe/global/**` through Spring MVC's CORS registry
  (`WebMvcConfigurer.addCorsMappings`).
- `FilterCors` — Spring's `CorsFilter` in a filter registration at `HIGHEST_PRECEDENCE + 10`, its one rule for `/probe/filter/**` (that
  origin, GET and PUT, any header), on a bare `CorsConfiguration`.
- `StarCreds` — a global rule for `/probe/global/**`: `allowedOrigins("*")` and `allowCredentials(true)`.
- `Dump` — the server's witness: a filter bean at `HIGHEST_PRECEDENCE` printing every request whole (method, path, every header in the
  order Tomcat holds them, each name once) and, when it is done, its status, every header a filter can read (each name once; a `Date`
  header's value not printed) and the body, copied on its way out. It skips `/actuator` (readiness polls) and `/shutdown` (its token
  header: the first sketch of `Dump` printed it — found on the way).
- `Trace`, `Hooks`, `Interceptor`, `ProbeOops` — the last lesson's, byte for byte (`receipts.sh` compares them with `../c6-unit18/harness`):
  every harness line goes through `Trace`; `Hooks` adds the handler interceptor and prints the JVM's locale; `Interceptor` names the handler
  in `preHandle` and sets `X-Post-Handle: set` in `postHandle` — so its header in an answer says the interceptor ran.
- `harness/www/cors.html` — the page: `?m=` the method (a `PUT` carries `Content-Type: application/json`), `?u=` the address; it prints
  `answer STATUS BODY`, or `refused: …` when `fetch` throws.
- `harness/cdp.mjs` — drives Chrome over its DevTools protocol with node's own WebSocket (nothing installed): `visit URL OUT` opens one
  tab, saves every Network event it saw and prints the page's line; `close` is `Browser.close`. `harness/net.py` reads the events: each
  request to TiffinBox's port, a preflight before the request it was made for, whether it was **sent** (Chrome reports the headers it put
  on the wire), the status Chrome got, and whether the answer was **handed to the page** or what Chrome's CORS check said instead.
  `harness/netlog.py` reads Chrome's NetLog: every address it connected to or tried is 127.0.0.1.
- `harness/shutdown.sh` — POST `/shutdown` with the token read from its file (the binding lesson's, unchanged).
- `exercise/KitchenCors.java` — the exercise's class (and `exercise/solution/KitchenCors.java`, the measured fix).

No native build and no Docker. **The browser** is Chrome on this Mac, headless (`--headless=new`), with a profile of its own made fresh
under `.harness/chrome` for each run (never a user's: the author's own Chrome was running throughout and was never touched), sealed to
loopback — its proxy a dead address (`127.0.0.1:9`), every host name but `127.0.0.1` unresolvable — and stopped by its pid, never by name.
Chrome and node are optional: without them (or with a node older than 22) `receipts.sh` makes and checks every curl capture, then stops
at the browser step with **exit 2**, saying why.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 5 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines and `CHROME=` — the Chrome app's path — at its top; a bare `java` on this Mac is 23.0.1.)
It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first). Chrome updates itself: a new version
changes what Chrome sends, so a `browser` mismatch after an update names Chrome among its suspects. **Start it in a process group of its
own** (a terminal's foreground job is one): two receipts started as background jobs of one shell share a group (R.94).

**Runs of record (2026-10-23, BLUE S4 part 1, this script as committed):** **314 s under `./receipts.sh`** (/bin/bash 3.2.57, `env -i` with
HOME and a plain PATH, this folder, a session of its own: exit 0, all 5 captures 3/3 = published, every check passed) and **464 s under
`bash receipts.sh`** (Homebrew bash 5.3.9, the same: exit 0, all 5 = published). A first bash 5.3 run died on `browser`'s own drift check:
its second run's first Chrome exited 2 at `Browser.close` (macOS display-link errors in Chrome's log), the other two 0; the re-run passed 3/3
("Found on the way"). **How the hashes were made:** one development run (bash 3.2, 451 s, every check passed, each capture 3/3) fixed `ways`
(B's label: the filter runs on every path) and `browser` (visit 2 after seven seconds, the control D, the platform masked); `preflight`, `star`
and `exercise` reproduced their earlier hashes unchanged. **The sealed fresh clone** of 2026-10-22 (at f175b1f, 460 s) followed the earlier
text of the recipe, which RED S4 #405 measured to leak as written, so its "every one from the `file://` copy" is not a proof from that text.
It was **not re-run** for this change: only captures changed (no dependency, plugin or build step), which a sealed clone cannot tell from a
seeded run. The fixed recipe below was measured once, on c6-unit18 (its README gives the counts).

Published hashes: preflight `9e2e164c8c9cdafef1e7326787aeb985` · ways `f8c3732e728e9af618b6f66209bfa44d` · star `4adff2ac2c2b89ec0d03d34fffddc453` · exercise `cfe0622301da0ac0f41061602fb60d2b` · browser `56f94efc97099e42f155fbc399d7d3b4`.

### A sealed fresh clone — the recipe (RED S4 #405)

A sealed clone proves that a fresh clone's first build fetches only from a copy you control. **The earlier text of this paragraph did not
seal** (RED S4 #405, measured): a `HOME` of its own whose `.mavenrc` set only `-Dhttp(s).proxyHost`, with Maven settings in `$HOME/.m2`,
fetched from Maven Central — Java on macOS ignores `$HOME` (`user.home` stays your own folder, so Maven never read those settings), and
Maven's resolver ignores the `-Dhttp.proxyHost` properties (it takes its proxies from `settings.xml`). The recipe that seals, step by step,
with a pre-flight that refuses to start unless the only remote is `file://` and a post-check of where every artifact came from:

```bash
S=/tmp/sealed-19                                   # an empty folder of your own; T = your tiffinbox-java clone
mkdir -p "$S/home/.m2" && git clone -q "file://$T" "$S/tiffinbox-java"
rsync -a --exclude _remote.repositories --exclude '*.lastUpdated' --exclude resolver-status.properties "$T/c6-unit19/.m2-demo/" "$S/central/"
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
cd "$S/tiffinbox-java/c6-unit19" && $E ./receipts.sh            # a process group of its own (a terminal's foreground job is one)
# post-check: every artifact's origin, by repository id - each line must say sealed; 0 central
find .m2-demo -name _remote.repositories -exec cat {} + | grep -o '>[^=]*=' | sort | uniq -c
```

## The commands this unit adds

`anchor/README.md` — the anchor's own — gives five lines `receipts.sh` runs or derives from (`mvn -B package`, the run line, the extract
line, the class-path line, the readiness line). These twelve are this unit's, each read from the block below and asserted to be exactly
this (on the anchor's port 18431; each capture swaps in its own port, path or origin, and the swap is asserted):

```bash
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/probe/web/CorsRoutes.java harness/probe/web/Dump.java harness/probe/web/FilterCors.java harness/probe/web/GlobalCors.java harness/probe/web/Hooks.java harness/probe/web/Interceptor.java harness/probe/web/ProbeOops.java harness/probe/web/StarCreds.java harness/probe/web/Trace.java
curl -s -D - -o .harness/body.txt -X OPTIONS -H 'Origin: http://127.0.0.1:19486' -H 'Access-Control-Request-Method: PUT' -H 'Access-Control-Request-Headers: content-type' http://127.0.0.1:18431/probe/cors/menu
curl -s -D - -o .harness/body.txt -H 'Origin: http://127.0.0.1:19487' http://127.0.0.1:18431/customers
jwebserver -J-Duser.language=en -J-Duser.country=US -b 127.0.0.1 -p 19486 -d "$PWD/harness/www"
"$CHROME" --headless=new --user-data-dir="$PWD/.harness/chrome" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 --host-resolver-rules='MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' --remote-debugging-address=127.0.0.1 --remote-debugging-port=19489 --log-net-log="$PWD/.harness/netlog.json" about:blank
node harness/cdp.mjs 19489 visit 'http://127.0.0.1:19486/cors.html?m=PUT&u=http://127.0.0.1:18431/probe/cors/menu' .harness/ev.json
node harness/cdp.mjs 19489 close
python3 harness/net.py .harness/ev.json 18431
python3 harness/netlog.py .harness/netlog.json 18431 19486 19487
```

The first two are the anchor's run and class-path lines with `-Duser.language=en -Duser.country=US` after `java` (asserted); every java
line a capture starts takes them in the same place, and every jwebserver line passes them to its JVM with `-J` (a last check refuses any
capture's java or jwebserver line without them). The javac line compiles the harness's nine files and nothing else. The preflight line is
what a browser asks before a cross-origin `PUT` with a JSON body; `pfq()` swaps its port, path and `Origin`. The request line is an actual
request with an `Origin`; `rq()` swaps the port, the path and the `Origin` — or drops the `Origin` header, or adds `-X OPTIONS`. Both print
curl's status line and every header (`-D -`), then the body curl wrote **this time** (the file is removed first, so an answer with no body
prints `[]` — never the previous answer, S4.18). The jwebserver line serves `harness/www` on one port; the Chrome line, the two `cdp.mjs`
lines and the two readers are the browser step, each with its port swapped in (`jw()`, `vq()`, `nq()`, `nlq()`).

## The repository, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from `../../spring-web-mvc/_research/m2-seed-s4/`
alone — 5,891 files, no `com/tiffinbox`. **Nothing was downloaded** for this unit: every build said `offline: yes`, and `.m2-demo` held
5,891 files after each run of record. A fresh clone's `.m2-demo` is empty (git ignores it): the first build — `.harness/pre`, before any
capture — fills it from Maven Central and says `offline: no`. **At run time** every request goes to `127.0.0.1`; nothing binds 8080,
18425 or 35729; Chrome's own background requests (to Google's hosts, made by any fresh profile) go to the dead proxy and fail there — the
NetLog check reads every address Chrome connected to or tried, and each is 127.0.0.1 (how many such attempts a run makes varies, so it is
never counted, R.121).

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 28 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/anchor/secrets/tiffinbox/shutdown-token` (mode 0600, git-ignored) and sent
only by `../c5-unit11/curlset.sh` and `harness/shutdown.sh` on curl's standard input. Every capture's raw output is searched for it before
masking (0 in all of them), and so are the log of every JVM that served and every file this unit ships: 0 everywhere. The header's name,
`X-Shutdown-Token`, is counted too: 0 in every log — `Dump` skips `/shutdown` for exactly that reason. The exercise makes a token of its own
(`openssl rand -hex 13`), counted 0 times in its own log, never printed.

## The locale — pinned per JVM, printed, asserted

Every java line this script starts carries `-Duser.language=en -Duser.country=US` before `-jar` or `-cp`, jwebserver's JVM gets them by
`-J`, and every harness JVM prints its locale (`Hooks`; the exercise's `KitchenCors`) — `en_US`, asserted in every capture that starts one.
Chrome runs with `--lang=en-US`; its requests say `Accept-Language: en-US,en;q=0.9` (captured, S4.17). Receipts run under bash, never zsh.

## The folders, the names and the ports

- `.harness/pre` — the anchor built before any capture; `.harness/anchor` — the anchor, copied, with a config tree, built and extracted
  (`preflight`); `.harness/hc` — the harness's classes; `.harness/body.txt` — curl's body, removed before each request; `.harness/chrome` —
  Chrome's profile, made fresh for each Chrome run and removed when it ends (and in the trap); `.harness/ev.json`, `.harness/netlog.json` —
  Chrome's events and NetLog; `.harness/mine` — the exercise's copy.
- **Ports** (brief ⚑1, 19480-19489): `preflight` — the seven and the routes 19480 · `ways` — the two ways 19481, A and A′ 19482, B 19483 ·
  `star` 19481 · `browser` — TiffinBox 19484, C 19485, the origins 19486 (allowed) and 19487 (not), Chrome's DevTools port 19489 · the exercise
  19488. Captures run one after another, each process stopped and its port checked free before the next starts. All ten, 18425, 8080 and
  35729 are checked free first. `http://127.0.0.1:19487` is only ever an `Origin` header for curl; for Chrome it is a real page.

## Masks, filters and hygiene — every one, declared

1. **Paths, the token, the user** (`gsub()`), in every line: the demo token → `[masked: the 28-character token]`; this folder → `…`; the
   folder above → `…/..`; home → `~`; the user name → `<user>`; a generated class's number → `$$SpringCGLIB$$<n>`.
2. **Chrome's version** (R.116): `Chrome/<digits>` → `Chrome/<version>` (its `User-Agent`), and the whole value of `sec-ch-ua` (its brand list,
   whose names and numbers follow the version) → `(its brands and their versions: masked)`. **The platform** (RED S4 #305, #381): the
   `User-Agent`'s first brackets → `Mozilla/5.0 (<platform masked>)` (here `Macintosh; Intel Mac OS X 10_15_7`) and `sec-ch-ua-platform`'s
   value → `(<platform masked>)` (here `"macOS"`): Chrome on Linux or Windows sends other words there, and a capture must not hash this
   machine. Chrome's version and the platform (`uname -s -m`) are printed once, in the terminal, never in a capture; a last check refuses any
   `Chrome/<digit>`, `v="<digit>`, `Macintosh`, `Mac OS X`, `Windows NT`, `X11;` or a quoted `sec-ch-ua-platform` in a capture. Checked on
   planted lines first (a Mac and a Linux `User-Agent`, both platform values).
3. **curl's headers** (`hdr`): carriage returns and trailing spaces dropped (Tomcat's status line has none after `200`), the blank line after
   the headers dropped, a `Date` header's value → `(the time: not printed)`; Spring's error timestamp → `"timestamp":"…"`. Checked on planted
   headers first.
4. **Log lines** (`logl`, `recs`): from their logger on; counted **by the log's own line shape** (`<ISO date> LEVEL <pid> --- [`), never a bare
   `' ERROR '` (R.120; a planted log with a hook line that says ERROR gives 1, a bare count 2). `o.a.c.c.C.[.[.[/].[dispatcherServlet]` is
   **Tomcat's** logger; `Invalid CORS request` is no log line at all — it is the body Spring's `DefaultCorsProcessor` writes (spring-web,
   not spring-webmvc: `unzip -l`; the brief's S4.5 said "Spring MVC's" — RED S4 #308).
5. **Harness lines** (`hk`): `Dump`'s record and the hooks, in the order they printed, numbered from 1 per request; the JVM's running number
   checked to rise (a planted falling number stops the run), never shown.
6. **Chrome's record** (`net.py`): only the page's requests to TiffinBox's port (not the page itself, which jwebserver served); a preflight's
   headers whole, as Chrome sent them; nothing that differs run to run (request ids, times). **The server's record** (`Dump`): every header,
   none cut.
7. **A′ against A** (`asame`): A's block and A′'s, labels aside, line for line ("yes"); **the two ways** compared answer against answer.
8. **On this Mac**: `lsof` by pid (or by port), the address column alone — never a command name (R.18).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops TiffinBox (`$pid`), the exercise's shell (`$xpid`,
with everything under it), Chrome (`$cpid`, with everything under it) and both jwebservers (`$j1`, `$j2`), each by its pid; sweeps its own
process group for any TiffinBox JVM, Maven or jwebserver left, and the whole machine for any process started with this unit's own Chrome
profile path (never another); removes the profile; deletes the capture runs it had not finished (`.r-NAME.1-3`); and removes `.r-lock`. The
published captures are untouched. No `wait` is bare (R.105), and nothing names `pkill` or `killall` (checked).

## 1 · preflight — the question, asked by curl

The anchor built offline and extracted; the harness compiled; the seven on a fresh JVM of the jar (`466c20ed…`, 1 WARN `PageNotFound`). Then
`CorsRoutes` and `Hooks` joined. **Allowed origin:** `200`, the origin named back, `GET,PUT`, `content-type`, **`Access-Control-Max-Age: 1800`
— which nothing in the harness sets** (the annotation's default; checked: no `maxAge` in any harness file), three `Vary` lines, Spring MVC's
`Allow` with seven methods, and the interceptor ran with handler `PreFlightHttpRequestHandler` (its `X-Post-Handle` header is in the answer).
**Another origin:** `403`, body `Invalid CORS request`, **no `Content-Type`** — not a problem detail, though the anchor has problem details on —
and no harness line: the interceptor never ran. **A path no rule covers** (`/customers`): `200`, `Allow`, **no CORS header at all** — the
server says yes and leaves the browser to refuse. **Actual requests:** the allowed origin's `GET` gets `Access-Control-Allow-Origin`; the other
origin's gets the `403` and the controller never ran; the other origin's `GET /customers` (a **simple request**: a GET with no header of its
own, which a browser sends without asking first) gets `200` and **the whole list**, no CORS header — the controller ran. **No `Origin`:** an
`OPTIONS` is Spring MVC's own answer (`Allow: GET,HEAD,PUT,OPTIONS`, `HttpOptionsHandler`), not a preflight.

`.r-preflight.out` · md5 `9e2e164c8c9cdafef1e7326787aeb985` · 3 of 3

```
the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline), its jar extracted (the README's line):
$ cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the anchor · offline: yes · exit 0
$ cd .harness/anchor && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
the harness, compiled against the anchor's own jar - with -parameters (this unit's line):
$ javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/probe/web/CorsRoutes.java harness/probe/web/Dump.java harness/probe/web/FilterCors.java harness/probe/web/GlobalCors.java harness/probe/web/Hooks.java harness/probe/web/Interceptor.java harness/probe/web/ProbeOops.java harness/probe/web/StarCreds.java harness/probe/web/Trace.java
  exit 0 · its classes: probe/web/CorsRoutes.class probe/web/Dump$Tee$1.class probe/web/Dump$Tee.class probe/web/Dump.class probe/web/FilterCors.class probe/web/GlobalCors.class probe/web/Hooks.class probe/web/Interceptor.class probe/web/ProbeOops.class probe/web/StarCreds.class probe/web/Trace.class
the seven - the anchor, the README's run line (its locale pinned), port 19480, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19480
  listens on: 127.0.0.1:19480 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19480/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19480 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
the routes - the anchor on its class path, CorsRoutes (@CrossOrigin for http://127.0.0.1:19486 on /probe/cors/menu) and Hooks joined, port 19480:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19480 --spring.main.sources=probe.web.CorsRoutes,probe.web.Hooks
  listens on: 127.0.0.1:19480 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19480/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Hooks): en_US
a preflight from the origin the rule allows:
$ curl -s -D - -o .harness/body.txt -X OPTIONS -H 'Origin: http://127.0.0.1:19486' -H 'Access-Control-Request-Method: PUT' -H 'Access-Control-Request-Headers: content-type' http://127.0.0.1:19480/probe/cors/menu
  HTTP/1.1 200
  Vary: Origin
  Vary: Access-Control-Request-Method
  Vary: Access-Control-Request-Headers
  Access-Control-Allow-Origin: http://127.0.0.1:19486
  Access-Control-Allow-Methods: GET,PUT
  Access-Control-Allow-Headers: content-type
  Access-Control-Max-Age: 1800
  X-Post-Handle: set
  Allow: GET, HEAD, POST, PUT, DELETE, OPTIONS, PATCH
  Content-Length: 0
  Date: (the time: not printed)
  body: []
  WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 3
     1 Interceptor     preHandle       REQUEST /probe/cors/menu handler PreFlightHttpRequestHandler
     2 Interceptor     postHandle      REQUEST /probe/cors/menu status 200 committed false
     3 Interceptor     afterCompletion REQUEST /probe/cors/menu status 200 exception none
the same preflight from another origin:
$ curl -s -D - -o .harness/body.txt -X OPTIONS -H 'Origin: http://127.0.0.1:19487' -H 'Access-Control-Request-Method: PUT' -H 'Access-Control-Request-Headers: content-type' http://127.0.0.1:19480/probe/cors/menu
  HTTP/1.1 403
  Vary: Origin
  Vary: Access-Control-Request-Method
  Vary: Access-Control-Request-Headers
  Transfer-Encoding: chunked
  Date: (the time: not printed)
  body: [Invalid CORS request]
  WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 0
a preflight to a path no CORS rule covers:
$ curl -s -D - -o .harness/body.txt -X OPTIONS -H 'Origin: http://127.0.0.1:19486' -H 'Access-Control-Request-Method: PUT' -H 'Access-Control-Request-Headers: content-type' http://127.0.0.1:19480/customers
  HTTP/1.1 200
  X-Post-Handle: set
  Allow: GET, HEAD, POST, PUT, DELETE, OPTIONS, PATCH
  Content-Length: 0
  Date: (the time: not printed)
  body: []
  WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 3
     1 Interceptor     preHandle       REQUEST /customers handler PreFlightHttpRequestHandler
     2 Interceptor     postHandle      REQUEST /customers status 200 committed false
     3 Interceptor     afterCompletion REQUEST /customers status 200 exception none
the actual requests - a GET from the allowed origin, from the other, and a GET of the customer list from the other:
$ curl -s -D - -o .harness/body.txt -H 'Origin: http://127.0.0.1:19486' http://127.0.0.1:19480/probe/cors/menu
  HTTP/1.1 200
  Vary: Origin
  Vary: Access-Control-Request-Method
  Vary: Access-Control-Request-Headers
  Access-Control-Allow-Origin: http://127.0.0.1:19486
  X-Post-Handle: set
  Content-Type: application/json
  Content-Length: 20
  Date: (the time: not printed)
  body: [{"menu":"annotated"}]
  WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 4
     1 Interceptor     preHandle       REQUEST /probe/cors/menu handler CorsRoutes#annotated
     2 CorsRoutes      annotated
     3 Interceptor     postHandle      REQUEST /probe/cors/menu status 200 committed false
     4 Interceptor     afterCompletion REQUEST /probe/cors/menu status 200 exception none
$ curl -s -D - -o .harness/body.txt -H 'Origin: http://127.0.0.1:19487' http://127.0.0.1:19480/probe/cors/menu
  HTTP/1.1 403
  Vary: Origin
  Vary: Access-Control-Request-Method
  Vary: Access-Control-Request-Headers
  Transfer-Encoding: chunked
  Date: (the time: not printed)
  body: [Invalid CORS request]
  WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 0
$ curl -s -D - -o .harness/body.txt -H 'Origin: http://127.0.0.1:19487' http://127.0.0.1:19480/customers
  HTTP/1.1 200
  X-Post-Handle: set
  Content-Type: application/json
  Content-Length: 282
  Date: (the time: not printed)
  body: [[{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]]
  WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 3
     1 Interceptor     preHandle       REQUEST /customers handler TiffinBoxServer#customers
     2 Interceptor     postHandle      REQUEST /customers status 200 committed false
     3 Interceptor     afterCompletion REQUEST /customers status 200 exception none
an OPTIONS with no Origin at all:
$ curl -s -D - -o .harness/body.txt -X OPTIONS http://127.0.0.1:19480/probe/cors/menu
  HTTP/1.1 200
  Allow: GET,HEAD,PUT,OPTIONS
  Accept-Patch:
  X-Post-Handle: set
  Content-Length: 0
  Date: (the time: not printed)
  body: []
  WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 3
     1 Interceptor     preHandle       REQUEST /probe/cors/menu handler HttpOptionsHandler#handle
     2 Interceptor     postHandle      REQUEST /probe/cors/menu status 200 committed false
     3 Interceptor     afterCompletion REQUEST /probe/cors/menu status 200 exception none
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19480 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19480 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 2 · ways — three ways, one answer (A/B/A′)

`@CrossOrigin` and the registry (`GlobalCors`), in one JVM: their preflight answers are **the same line for line**, allowed and refused. A:
`CorsRoutes` alone — the headers. B: `FilterCors` joined — its registration names no path, so the filter runs on every path; its one rule is for `/probe/filter/**` (RED S4 #302): the annotated route's preflight is now **`200`,
`Content-Length: 0`, no CORS header, no harness line** — the `CorsFilter` answered it (it answers every preflight that reaches it, its own
paths with their rule, any other with nothing). On its own path the filter answers with the origin, methods and header but **no `Max-Age` and
no `Allow`**: a bare `CorsConfiguration` gets no defaults, and the request never reaches Spring MVC. An actual `GET` of the annotated route still
gets its header. A′ = A, line for line.

`.r-ways.out` · md5 `f8c3732e728e9af618b6f66209bfa44d` · 3 of 3

```
two ways - CorsRoutes and GlobalCors (the same rule for /probe/global/**, through Spring MVC's CORS registry) and Hooks, port 19481:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19481 --spring.main.sources=probe.web.CorsRoutes,probe.web.GlobalCors,probe.web.Hooks
  listens on: 127.0.0.1:19481 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19481/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Hooks): en_US
$ curl -s -D - -o .harness/body.txt -X OPTIONS -H 'Origin: http://127.0.0.1:19486' -H 'Access-Control-Request-Method: PUT' -H 'Access-Control-Request-Headers: content-type' http://127.0.0.1:19481/probe/cors/menu
  HTTP/1.1 200
  Vary: Origin
  Vary: Access-Control-Request-Method
  Vary: Access-Control-Request-Headers
  Access-Control-Allow-Origin: http://127.0.0.1:19486
  Access-Control-Allow-Methods: GET,PUT
  Access-Control-Allow-Headers: content-type
  Access-Control-Max-Age: 1800
  X-Post-Handle: set
  Allow: GET, HEAD, POST, PUT, DELETE, OPTIONS, PATCH
  Content-Length: 0
  Date: (the time: not printed)
  body: []
  WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 3
     1 Interceptor     preHandle       REQUEST /probe/cors/menu handler PreFlightHttpRequestHandler
     2 Interceptor     postHandle      REQUEST /probe/cors/menu status 200 committed false
     3 Interceptor     afterCompletion REQUEST /probe/cors/menu status 200 exception none
$ curl -s -D - -o .harness/body.txt -X OPTIONS -H 'Origin: http://127.0.0.1:19486' -H 'Access-Control-Request-Method: PUT' -H 'Access-Control-Request-Headers: content-type' http://127.0.0.1:19481/probe/global/menu
  HTTP/1.1 200
  Vary: Origin
  Vary: Access-Control-Request-Method
  Vary: Access-Control-Request-Headers
  Access-Control-Allow-Origin: http://127.0.0.1:19486
  Access-Control-Allow-Methods: GET,PUT
  Access-Control-Allow-Headers: content-type
  Access-Control-Max-Age: 1800
  X-Post-Handle: set
  Allow: GET, HEAD, POST, PUT, DELETE, OPTIONS, PATCH
  Content-Length: 0
  Date: (the time: not printed)
  body: []
  WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 3
     1 Interceptor     preHandle       REQUEST /probe/global/menu handler PreFlightHttpRequestHandler
     2 Interceptor     postHandle      REQUEST /probe/global/menu status 200 committed false
     3 Interceptor     afterCompletion REQUEST /probe/global/menu status 200 exception none
$ curl -s -D - -o .harness/body.txt -X OPTIONS -H 'Origin: http://127.0.0.1:19487' -H 'Access-Control-Request-Method: PUT' -H 'Access-Control-Request-Headers: content-type' http://127.0.0.1:19481/probe/cors/menu
  HTTP/1.1 403
  Vary: Origin
  Vary: Access-Control-Request-Method
  Vary: Access-Control-Request-Headers
  Transfer-Encoding: chunked
  Date: (the time: not printed)
  body: [Invalid CORS request]
  WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 0
$ curl -s -D - -o .harness/body.txt -X OPTIONS -H 'Origin: http://127.0.0.1:19487' -H 'Access-Control-Request-Method: PUT' -H 'Access-Control-Request-Headers: content-type' http://127.0.0.1:19481/probe/global/menu
  HTTP/1.1 403
  Vary: Origin
  Vary: Access-Control-Request-Method
  Vary: Access-Control-Request-Headers
  Transfer-Encoding: chunked
  Date: (the time: not printed)
  body: [Invalid CORS request]
  WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 0
  the annotation's answer and the registry's, line for line - allowed: the same · refused: the same
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19481 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19481 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A - CorsRoutes and Hooks, port 19482:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19482 --spring.main.sources=probe.web.CorsRoutes,probe.web.Hooks
  listens on: 127.0.0.1:19482 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19482/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Hooks): en_US
$ curl -s -D - -o .harness/body.txt -X OPTIONS -H 'Origin: http://127.0.0.1:19486' -H 'Access-Control-Request-Method: PUT' -H 'Access-Control-Request-Headers: content-type' http://127.0.0.1:19482/probe/cors/menu
  HTTP/1.1 200
  Vary: Origin
  Vary: Access-Control-Request-Method
  Vary: Access-Control-Request-Headers
  Access-Control-Allow-Origin: http://127.0.0.1:19486
  Access-Control-Allow-Methods: GET,PUT
  Access-Control-Allow-Headers: content-type
  Access-Control-Max-Age: 1800
  X-Post-Handle: set
  Allow: GET, HEAD, POST, PUT, DELETE, OPTIONS, PATCH
  Content-Length: 0
  Date: (the time: not printed)
  body: []
  WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 3
     1 Interceptor     preHandle       REQUEST /probe/cors/menu handler PreFlightHttpRequestHandler
     2 Interceptor     postHandle      REQUEST /probe/cors/menu status 200 committed false
     3 Interceptor     afterCompletion REQUEST /probe/cors/menu status 200 exception none
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19482 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19482 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the same, FilterCors joined (a CorsFilter in a filter registration that names no path, so it runs on every path; its one rule is for /probe/filter/**), port 19483:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19483 --spring.main.sources=probe.web.CorsRoutes,probe.web.FilterCors,probe.web.Hooks
  listens on: 127.0.0.1:19483 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19483/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Hooks): en_US
$ curl -s -D - -o .harness/body.txt -X OPTIONS -H 'Origin: http://127.0.0.1:19486' -H 'Access-Control-Request-Method: PUT' -H 'Access-Control-Request-Headers: content-type' http://127.0.0.1:19483/probe/cors/menu
  HTTP/1.1 200
  Content-Length: 0
  Date: (the time: not printed)
  body: []
  WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 0
B - the filter's own path:
$ curl -s -D - -o .harness/body.txt -X OPTIONS -H 'Origin: http://127.0.0.1:19486' -H 'Access-Control-Request-Method: PUT' -H 'Access-Control-Request-Headers: content-type' http://127.0.0.1:19483/probe/filter/menu
  HTTP/1.1 200
  Vary: Origin
  Vary: Access-Control-Request-Method
  Vary: Access-Control-Request-Headers
  Access-Control-Allow-Origin: http://127.0.0.1:19486
  Access-Control-Allow-Methods: GET,PUT
  Access-Control-Allow-Headers: content-type
  Content-Length: 0
  Date: (the time: not printed)
  body: []
  WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 0
B - an actual GET of the annotated route:
$ curl -s -D - -o .harness/body.txt -H 'Origin: http://127.0.0.1:19486' http://127.0.0.1:19483/probe/cors/menu
  HTTP/1.1 200
  Vary: Origin
  Vary: Access-Control-Request-Method
  Vary: Access-Control-Request-Headers
  Access-Control-Allow-Origin: http://127.0.0.1:19486
  X-Post-Handle: set
  Content-Type: application/json
  Content-Length: 20
  Date: (the time: not printed)
  body: [{"menu":"annotated"}]
  WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 4
     1 Interceptor     preHandle       REQUEST /probe/cors/menu handler CorsRoutes#annotated
     2 CorsRoutes      annotated
     3 Interceptor     postHandle      REQUEST /probe/cors/menu status 200 committed false
     4 Interceptor     afterCompletion REQUEST /probe/cors/menu status 200 exception none
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19483 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19483 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, a fresh JVM, port 19482:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19482 --spring.main.sources=probe.web.CorsRoutes,probe.web.Hooks
  listens on: 127.0.0.1:19482 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19482/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Hooks): en_US
$ curl -s -D - -o .harness/body.txt -X OPTIONS -H 'Origin: http://127.0.0.1:19486' -H 'Access-Control-Request-Method: PUT' -H 'Access-Control-Request-Headers: content-type' http://127.0.0.1:19482/probe/cors/menu
  HTTP/1.1 200
  Vary: Origin
  Vary: Access-Control-Request-Method
  Vary: Access-Control-Request-Headers
  Access-Control-Allow-Origin: http://127.0.0.1:19486
  Access-Control-Allow-Methods: GET,PUT
  Access-Control-Allow-Headers: content-type
  Access-Control-Max-Age: 1800
  X-Post-Handle: set
  Allow: GET, HEAD, POST, PUT, DELETE, OPTIONS, PATCH
  Content-Length: 0
  Date: (the time: not printed)
  body: []
  WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 3
     1 Interceptor     preHandle       REQUEST /probe/cors/menu handler PreFlightHttpRequestHandler
     2 Interceptor     postHandle      REQUEST /probe/cors/menu status 200 committed false
     3 Interceptor     afterCompletion REQUEST /probe/cors/menu status 200 exception none
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19482 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19482 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
```

## 3 · star — any origin, with credentials

`StarCreds`: the JVM starts with 0 WARN 0 ERROR. Then the preflight, a `GET` with an `Origin` — **and a `GET` with no `Origin` at all** — to
`/probe/global/menu` each get Boot's JSON `500` with `Connection: close`, and one ERROR line each, **Tomcat's**, carrying Spring's own sentence
(`When allowCredentials is true, allowedOrigins cannot contain the special value "*" …`). The interceptor never ran on the request itself (only
on the error dispatch): the rule is checked while the handler is being found. The annotated route beside it answers `200`. The run: 0 WARN,
3 ERROR.

`.r-star.out` · md5 `4adff2ac2c2b89ec0d03d34fffddc453` · 3 of 3

```
star - CorsRoutes, StarCreds (any origin, "*", and credentials, for /probe/global/**) and Hooks, port 19481:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19481 --spring.main.sources=probe.web.CorsRoutes,probe.web.StarCreds,probe.web.Hooks
  listens on: 127.0.0.1:19481 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19481/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Hooks): en_US
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ curl -s -D - -o .harness/body.txt -X OPTIONS -H 'Origin: http://127.0.0.1:19486' -H 'Access-Control-Request-Method: PUT' -H 'Access-Control-Request-Headers: content-type' http://127.0.0.1:19481/probe/global/menu
  HTTP/1.1 500
  Content-Type: application/json
  Transfer-Encoding: chunked
  Date: (the time: not printed)
  Connection: close
  body: [{"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/global/menu"}]
  WARN lines it added: 0 · ERROR lines: 1
  the harness's lines it printed, in order: 3
     1 Interceptor     preHandle       ERROR /error handler BasicErrorController#error
     2 Interceptor     postHandle      ERROR /error status 500 committed true
     3 Interceptor     afterCompletion ERROR /error status 500 exception none
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalArgumentException: When allowCredentials is true, allowedOrigins cannot contain the special value "*" since that cannot be set on the "Access-Control-Allow-Origin" response header. To allow credentials to a set of origins, list them explicitly or consider using "allowedOriginPatterns" instead.] with root cause
      java.lang.IllegalArgumentException: When allowCredentials is true, allowedOrigins cannot contain the special value "*" since that cannot be set on the "Access-Control-Allow-Origin" response header. To allow credentials to a set of origins, list them explicitly or consider using "allowedOriginPatterns" instead.
      its stack frames: 38, its other lines: 2 - none shown
$ curl -s -D - -o .harness/body.txt -H 'Origin: http://127.0.0.1:19486' http://127.0.0.1:19481/probe/global/menu
  HTTP/1.1 500
  Content-Type: application/json
  Transfer-Encoding: chunked
  Date: (the time: not printed)
  Connection: close
  body: [{"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/global/menu"}]
  WARN lines it added: 0 · ERROR lines: 1
  the harness's lines it printed, in order: 3
     1 Interceptor     preHandle       ERROR /error handler BasicErrorController#error
     2 Interceptor     postHandle      ERROR /error status 500 committed true
     3 Interceptor     afterCompletion ERROR /error status 500 exception none
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalArgumentException: When allowCredentials is true, allowedOrigins cannot contain the special value "*" since that cannot be set on the "Access-Control-Allow-Origin" response header. To allow credentials to a set of origins, list them explicitly or consider using "allowedOriginPatterns" instead.] with root cause
      java.lang.IllegalArgumentException: When allowCredentials is true, allowedOrigins cannot contain the special value "*" since that cannot be set on the "Access-Control-Allow-Origin" response header. To allow credentials to a set of origins, list them explicitly or consider using "allowedOriginPatterns" instead.
      its stack frames: 38, its other lines: 2 - none shown
the same GET with no Origin at all - not a cross-origin request:
$ curl -s -D - -o .harness/body.txt http://127.0.0.1:19481/probe/global/menu
  HTTP/1.1 500
  Content-Type: application/json
  Transfer-Encoding: chunked
  Date: (the time: not printed)
  Connection: close
  body: [{"timestamp":"…","status":500,"error":"Internal Server Error","path":"/probe/global/menu"}]
  WARN lines it added: 0 · ERROR lines: 1
  the harness's lines it printed, in order: 3
     1 Interceptor     preHandle       ERROR /error handler BasicErrorController#error
     2 Interceptor     postHandle      ERROR /error status 500 committed true
     3 Interceptor     afterCompletion ERROR /error status 500 exception none
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: java.lang.IllegalArgumentException: When allowCredentials is true, allowedOrigins cannot contain the special value "*" since that cannot be set on the "Access-Control-Allow-Origin" response header. To allow credentials to a set of origins, list them explicitly or consider using "allowedOriginPatterns" instead.] with root cause
      java.lang.IllegalArgumentException: When allowCredentials is true, allowedOrigins cannot contain the special value "*" since that cannot be set on the "Access-Control-Allow-Origin" response header. To allow credentials to a set of origins, list them explicitly or consider using "allowedOriginPatterns" instead.
      its stack frames: 38, its other lines: 2 - none shown
the annotated route, no Origin, beside it:
$ curl -s -D - -o .harness/body.txt http://127.0.0.1:19481/probe/cors/menu
  HTTP/1.1 200
  Vary: Origin
  Vary: Access-Control-Request-Method
  Vary: Access-Control-Request-Headers
  X-Post-Handle: set
  Content-Type: application/json
  Content-Length: 20
  Date: (the time: not printed)
  body: [{"menu":"annotated"}]
  WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 4
     1 Interceptor     preHandle       REQUEST /probe/cors/menu handler CorsRoutes#annotated
     2 CorsRoutes      annotated
     3 Interceptor     postHandle      REQUEST /probe/cors/menu status 200 committed false
     4 Interceptor     afterCompletion REQUEST /probe/cors/menu status 200 exception none
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 3
$ harness/shutdown.sh 19481 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19481 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 4 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s six lines, then `exercise/solution/SOLUTION.md`'s four, read from the files and run as written in ONE `env -i`
`/bin/bash --noprofile --norc` shell started in this folder (S4.4, R.93). As shipped (`@CrossOrigin` on `/kitchen/menu`, and a `CorsFilter`
bean for `/kitchen/admin/**`): `the preflight: 200 · Access-Control-Allow-Origin: [] · Access-Control-Max-Age: []`. The solution copies
`solution/KitchenCors.java` over the copy (idempotent) and runs the README's last line unchanged (asserted): `the preflight: 200 ·
Access-Control-Allow-Origin: [http://127.0.0.1:19486] · Access-Control-Max-Age: [1800]`. Each leaves the shell in this folder, `en_US` in its
log, 0 WARN 0 ERROR, 0 copies of the copy's token, 19488 free; the diff removes 19 lines (the bean and its seven imports) and adds none.

`.r-exercise.out` · md5 `cfe0622301da0ac0f41061602fb60d2b` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 6 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/ && cp exercise/KitchenCors.java .harness/mine/KitchenCors.java
  $ mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*" ../KitchenCors.java && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19488 --spring.main.sources=probe.web.KitchenCors > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19488/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -o /dev/null -w '%{http_code} · Access-Control-Allow-Origin: [%header{access-control-allow-origin}] · Access-Control-Max-Age: [%header{access-control-max-age}]' -X OPTIONS -H 'Origin: http://127.0.0.1:19486' -H 'Access-Control-Request-Method: PUT' -H 'Access-Control-Request-Headers: content-type' http://127.0.0.1:19488/kitchen/menu); ../../../harness/shutdown.sh 19488 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the preflight: $a")
  exit 0 · what they printed:
    the preflight: 200 · Access-Control-Allow-Origin: [] · Access-Control-Max-Age: []
  the shell is now in: this unit's folder · the JVM's locale in its log: en_US · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19488 now: 0
the solution's 4 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ cp exercise/solution/KitchenCors.java .harness/mine/KitchenCors.java
  $ M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*" ../KitchenCors.java && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19488 --spring.main.sources=probe.web.KitchenCors > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19488/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -o /dev/null -w '%{http_code} · Access-Control-Allow-Origin: [%header{access-control-allow-origin}] · Access-Control-Max-Age: [%header{access-control-max-age}]' -X OPTIONS -H 'Origin: http://127.0.0.1:19486' -H 'Access-Control-Request-Method: PUT' -H 'Access-Control-Request-Headers: content-type' http://127.0.0.1:19488/kitchen/menu); ../../../harness/shutdown.sh 19488 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the preflight: $a")
  exit 0 · what they printed:
    the preflight: 200 · Access-Control-Allow-Origin: [http://127.0.0.1:19486] · Access-Control-Max-Age: [1800]
  the shell is now in: this unit's folder · the JVM's locale in its log: en_US · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19488 now: 0
  the change the solution's KitchenCors.java makes (diff -U0, its hunks):
    @@ -3 +2,0 @@
    -import java.util.List;
    @@ -7,3 +5,0 @@
    -import org.springframework.boot.web.servlet.FilterRegistrationBean;
    -import org.springframework.context.annotation.Bean;
    -import org.springframework.core.Ordered;
    @@ -14,3 +9,0 @@
    -import org.springframework.web.cors.CorsConfiguration;
    -import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
    -import org.springframework.web.filter.CorsFilter;
    @@ -35,12 +27,0 @@
    -
    -    @Bean
    -    FilterRegistrationBean<CorsFilter> adminCors() {
    -        CorsConfiguration c = new CorsConfiguration();
    -        c.setAllowedOrigins(List.of("http://127.0.0.1:19486"));
    -        c.setAllowedMethods(List.of("GET"));
    -        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    -        source.registerCorsConfiguration("/kitchen/admin/**", c);
    -        FilterRegistrationBean<CorsFilter> b = new FilterRegistrationBean<>(new CorsFilter(source));
    -        b.setOrder(Ordered.HIGHEST_PRECEDENCE + 10);
    -        return b;
    -    }
```

## 5 · browser — a real browser, two witnesses for every claim

Two origins (jwebserver, the JDK's own file server, on 19486 and 19487), TiffinBox with `Dump`, `CorsRoutes` and `Hooks`, and Chrome. Every
claim has two witnesses (R.115-R.117): **Chrome's own record** of the request — its DevTools protocol's Network events, read by `net.py` —
and **the server's record** — `Dump`, every request whole. No developer-tools panel is used or filmed (brief ⚑8). **Visit 1** (19486, `PUT`):
Chrome sends the `OPTIONS` first — its 13 headers quoted, `Sec-Fetch-Mode: cors`, `Sec-Fetch-Site: same-site` — gets the `200` (Max-Age 1800),
then the `PUT`; the page reads `200`. **Visit 2**, the same page in the same Chrome, **seven seconds later** (`$ sleep 7` — a wait, not a
witness: Chrome keeps an answer that has no `Max-Age` for a few seconds of its own, so visit 2 must come after those to tell the two causes
apart; RED S4 #301): **the `PUT` alone** — no `OPTIONS` in either record: the **preflight cache**, holding the answer under its `Max-Age: 1800`. **Visit 3** (19487, `PUT`): the `OPTIONS` gets the `403`; **the
`PUT` is never sent** (Chrome: `sent: no`, `PreflightMissingAllowOriginHeader`; the server: no `PUT`). **Visit 4** (19487, `GET /customers`):
no preflight; **the server ran it** — the controller, `200`, the whole list in `Dump`'s body line — **and Chrome withheld it from the page**
(`MissingAllowOriginHeader`; the page: `refused: TypeError: Failed to fetch`). For a simple GET, CORS decides what the page may read, not
whether the server runs it; and a client that sends no `Origin` (curl) is never stopped by it (R.126). It is not "never what the server
runs": Spring's CORS check does stop a denied preflight and a denied actual request that carries an `Origin` (`preflight`: the 403s, 0
harness lines; RED S4 #300). **C (labelled, RE-MEASURE 3):** `FilterCors` joined, a fresh profile, the allowed `PUT`: the preflight gets the
empty `200`, no harness line, and **the `PUT` is never sent**. **D (labelled), the control:** in C's Chrome, the filter's own path
`/probe/filter/menu`, whose answer carries **no `Max-Age`**: `OPTIONS` then `PUT`, and **seven seconds later `OPTIONS` again** — the same wait
that visit 2 survived under `Max-Age: 1800`. The NetLog of each Chrome run: every address 127.0.0.1.

`.r-browser.out` · md5 `56f94efc97099e42f155fbc399d7d3b4` · 3 of 3

```
two origins - jwebserver, the JDK's own file server, serving harness/www (cors.html) twice: http://127.0.0.1:19486 (the origin the rules allow) and http://127.0.0.1:19487 (one they do not):
$ jwebserver -J-Duser.language=en -J-Duser.country=US -b 127.0.0.1 -p 19486 -d "$PWD/harness/www"
  listens on: 127.0.0.1:19486 · loopback only: yes
$ jwebserver -J-Duser.language=en -J-Duser.country=US -b 127.0.0.1 -p 19487 -d "$PWD/harness/www"
  listens on: 127.0.0.1:19487 · loopback only: yes
TiffinBox - the anchor on its class path, Dump (the server's record of every request, whole), CorsRoutes and Hooks joined, port 19484:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19484 --spring.main.sources=probe.web.Dump,probe.web.CorsRoutes,probe.web.Hooks
  listens on: 127.0.0.1:19484 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19484/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Hooks): en_US
Chrome - headless, a profile of its own, sealed to 127.0.0.1 (its proxy a dead address, every name but 127.0.0.1 unresolvable), its DevTools protocol on 127.0.0.1:19489:
$ "$CHROME" --headless=new --user-data-dir="$PWD/.harness/chrome" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 --host-resolver-rules='MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' --remote-debugging-address=127.0.0.1 --remote-debugging-port=19489 --log-net-log="$PWD/.harness/netlog.json" about:blank
  its profile, .harness/chrome, made fresh for this run (it did not exist before this line): yes
  listens on: 127.0.0.1:19489 · loopback only: yes
visit 1 - the page on http://127.0.0.1:19486 asks TiffinBox for PUT /probe/cors/menu:
$ node harness/cdp.mjs 19489 visit 'http://127.0.0.1:19486/cors.html?m=PUT&u=http://127.0.0.1:19484/probe/cors/menu' .harness/ev.json
  the page printed: answer 200 {"menu":"annotated"}
$ python3 harness/net.py .harness/ev.json 19484
  Chrome's own record (its DevTools protocol) - the requests the page made to TiffinBox: 2
    OPTIONS /probe/cors/menu - a preflight, for the PUT below · sent: yes · the answer Chrome got: 200
      as Chrome sent it, its 13 headers:
        Accept: */*
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Access-Control-Request-Headers: content-type
        Access-Control-Request-Method: PUT
        Connection: keep-alive
        Host: 127.0.0.1:19484
        Origin: http://127.0.0.1:19486
        Referer: http://127.0.0.1:19486/
        Sec-Fetch-Dest: empty
        Sec-Fetch-Mode: cors
        Sec-Fetch-Site: same-site
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
    PUT /probe/cors/menu - the page's fetch · sent: yes · the answer Chrome got: 200 · handed to the page: yes
  the server's record:
    the harness's lines it printed, in order: 57
       1 Dump            > OPTIONS /probe/cors/menu
       2 Dump            >   Host: 127.0.0.1:19484
       3 Dump            >   Connection: keep-alive
       4 Dump            >   Accept: */*
       5 Dump            >   Access-Control-Request-Method: PUT
       6 Dump            >   Access-Control-Request-Headers: content-type
       7 Dump            >   Origin: http://127.0.0.1:19486
       8 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
       9 Dump            >   Sec-Fetch-Mode: cors
      10 Dump            >   Sec-Fetch-Site: same-site
      11 Dump            >   Sec-Fetch-Dest: empty
      12 Dump            >   Referer: http://127.0.0.1:19486/
      13 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      14 Dump            >   Accept-Language: en-US,en;q=0.9
      15 Interceptor     preHandle       REQUEST /probe/cors/menu handler PreFlightHttpRequestHandler
      16 Interceptor     postHandle      REQUEST /probe/cors/menu status 200 committed false
      17 Interceptor     afterCompletion REQUEST /probe/cors/menu status 200 exception none
      18 Dump            < 200 OPTIONS /probe/cors/menu
      19 Dump            <   Vary: Origin
      20 Dump            <   Vary: Access-Control-Request-Method
      21 Dump            <   Vary: Access-Control-Request-Headers
      22 Dump            <   Access-Control-Allow-Origin: http://127.0.0.1:19486
      23 Dump            <   Access-Control-Allow-Methods: GET,PUT
      24 Dump            <   Access-Control-Allow-Headers: content-type
      25 Dump            <   Access-Control-Max-Age: 1800
      26 Dump            <   X-Post-Handle: set
      27 Dump            <   Allow: GET, HEAD, POST, PUT, DELETE, OPTIONS, PATCH
      28 Dump            <   body: []
      29 Dump            > PUT /probe/cors/menu
      30 Dump            >   Host: 127.0.0.1:19484
      31 Dump            >   Connection: keep-alive
      32 Dump            >   Content-Length: 2
      33 Dump            >   sec-ch-ua-platform: (<platform masked>)
      34 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      35 Dump            >   sec-ch-ua: (its brands and their versions: masked)
      36 Dump            >   Content-Type: application/json
      37 Dump            >   sec-ch-ua-mobile: ?0
      38 Dump            >   Accept: */*
      39 Dump            >   Origin: http://127.0.0.1:19486
      40 Dump            >   Sec-Fetch-Site: same-site
      41 Dump            >   Sec-Fetch-Mode: cors
      42 Dump            >   Sec-Fetch-Dest: empty
      43 Dump            >   Referer: http://127.0.0.1:19486/
      44 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      45 Dump            >   Accept-Language: en-US,en;q=0.9
      46 Interceptor     preHandle       REQUEST /probe/cors/menu handler CorsRoutes#annotated
      47 CorsRoutes      annotated
      48 Interceptor     postHandle      REQUEST /probe/cors/menu status 200 committed false
      49 Interceptor     afterCompletion REQUEST /probe/cors/menu status 200 exception none
      50 Dump            < 200 PUT /probe/cors/menu
      51 Dump            <   Vary: Origin
      52 Dump            <   Vary: Access-Control-Request-Method
      53 Dump            <   Vary: Access-Control-Request-Headers
      54 Dump            <   Access-Control-Allow-Origin: http://127.0.0.1:19486
      55 Dump            <   X-Post-Handle: set
      56 Dump            <   Content-Type: application/json
      57 Dump            <   body: [{"menu":"annotated"}]
    WARN lines they added: 0 · ERROR lines: 0
visit 2 - the same page again, the same Chrome, seven seconds later (a wait, not a witness: Chrome keeps an answer with no max age for a few seconds, D below):
$ sleep 7
$ node harness/cdp.mjs 19489 visit 'http://127.0.0.1:19486/cors.html?m=PUT&u=http://127.0.0.1:19484/probe/cors/menu' .harness/ev.json
  the page printed: answer 200 {"menu":"annotated"}
$ python3 harness/net.py .harness/ev.json 19484
  Chrome's own record (its DevTools protocol) - the requests the page made to TiffinBox: 1
    PUT /probe/cors/menu - the page's fetch · sent: yes · the answer Chrome got: 200 · handed to the page: yes
  the server's record:
    the harness's lines it printed, in order: 29
       1 Dump            > PUT /probe/cors/menu
       2 Dump            >   Host: 127.0.0.1:19484
       3 Dump            >   Connection: keep-alive
       4 Dump            >   Content-Length: 2
       5 Dump            >   sec-ch-ua-platform: (<platform masked>)
       6 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
       7 Dump            >   sec-ch-ua: (its brands and their versions: masked)
       8 Dump            >   Content-Type: application/json
       9 Dump            >   sec-ch-ua-mobile: ?0
      10 Dump            >   Accept: */*
      11 Dump            >   Origin: http://127.0.0.1:19486
      12 Dump            >   Sec-Fetch-Site: same-site
      13 Dump            >   Sec-Fetch-Mode: cors
      14 Dump            >   Sec-Fetch-Dest: empty
      15 Dump            >   Referer: http://127.0.0.1:19486/
      16 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      17 Dump            >   Accept-Language: en-US,en;q=0.9
      18 Interceptor     preHandle       REQUEST /probe/cors/menu handler CorsRoutes#annotated
      19 CorsRoutes      annotated
      20 Interceptor     postHandle      REQUEST /probe/cors/menu status 200 committed false
      21 Interceptor     afterCompletion REQUEST /probe/cors/menu status 200 exception none
      22 Dump            < 200 PUT /probe/cors/menu
      23 Dump            <   Vary: Origin
      24 Dump            <   Vary: Access-Control-Request-Method
      25 Dump            <   Vary: Access-Control-Request-Headers
      26 Dump            <   Access-Control-Allow-Origin: http://127.0.0.1:19486
      27 Dump            <   X-Post-Handle: set
      28 Dump            <   Content-Type: application/json
      29 Dump            <   body: [{"menu":"annotated"}]
    WARN lines they added: 0 · ERROR lines: 0
visit 3 - the page on http://127.0.0.1:19487 asks for the same PUT:
$ node harness/cdp.mjs 19489 visit 'http://127.0.0.1:19487/cors.html?m=PUT&u=http://127.0.0.1:19484/probe/cors/menu' .harness/ev.json
  the page printed: refused: TypeError: Failed to fetch
$ python3 harness/net.py .harness/ev.json 19484
  Chrome's own record (its DevTools protocol) - the requests the page made to TiffinBox: 2
    OPTIONS /probe/cors/menu - a preflight, for the PUT below · sent: yes · the answer Chrome got: 403
      as Chrome sent it, its 13 headers:
        Accept: */*
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Access-Control-Request-Headers: content-type
        Access-Control-Request-Method: PUT
        Connection: keep-alive
        Host: 127.0.0.1:19484
        Origin: http://127.0.0.1:19487
        Referer: http://127.0.0.1:19487/
        Sec-Fetch-Dest: empty
        Sec-Fetch-Mode: cors
        Sec-Fetch-Site: same-site
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
    PUT /probe/cors/menu - the page's fetch · sent: no · no answer · handed to the page: no - Chrome's CORS check: PreflightMissingAllowOriginHeader
  the server's record:
    the harness's lines it printed, in order: 23
       1 Dump            > OPTIONS /probe/cors/menu
       2 Dump            >   Host: 127.0.0.1:19484
       3 Dump            >   Connection: keep-alive
       4 Dump            >   Accept: */*
       5 Dump            >   Access-Control-Request-Method: PUT
       6 Dump            >   Access-Control-Request-Headers: content-type
       7 Dump            >   Origin: http://127.0.0.1:19487
       8 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
       9 Dump            >   Sec-Fetch-Mode: cors
      10 Dump            >   Sec-Fetch-Site: same-site
      11 Dump            >   Sec-Fetch-Dest: empty
      12 Dump            >   Referer: http://127.0.0.1:19487/
      13 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      14 Dump            >   Accept-Language: en-US,en;q=0.9
      15 Dump            < 403 OPTIONS /probe/cors/menu
      16 Dump            <   Vary: Origin
      17 Dump            <   Vary: Access-Control-Request-Method
      18 Dump            <   Vary: Access-Control-Request-Headers
      19 Dump            <   Transfer-Encoding: chunked
      20 Dump            <   Date: (the time: not printed)
      21 Dump            <   Keep-Alive: timeout=60
      22 Dump            <   Connection: keep-alive
      23 Dump            <   body: [Invalid CORS request]
    WARN lines they added: 0 · ERROR lines: 0
visit 4 - the page on http://127.0.0.1:19487 asks for GET /customers:
$ node harness/cdp.mjs 19489 visit 'http://127.0.0.1:19487/cors.html?m=GET&u=http://127.0.0.1:19484/customers' .harness/ev.json
  the page printed: refused: TypeError: Failed to fetch
$ python3 harness/net.py .harness/ev.json 19484
  Chrome's own record (its DevTools protocol) - the requests the page made to TiffinBox: 1
    GET /customers - the page's fetch · sent: yes · the answer Chrome got: 200 · handed to the page: no - Chrome's CORS check: MissingAllowOriginHeader
  the server's record:
    the harness's lines it printed, in order: 22
       1 Dump            > GET /customers
       2 Dump            >   Host: 127.0.0.1:19484
       3 Dump            >   Connection: keep-alive
       4 Dump            >   sec-ch-ua-platform: (<platform masked>)
       5 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
       6 Dump            >   sec-ch-ua: (its brands and their versions: masked)
       7 Dump            >   sec-ch-ua-mobile: ?0
       8 Dump            >   Accept: */*
       9 Dump            >   Origin: http://127.0.0.1:19487
      10 Dump            >   Sec-Fetch-Site: same-site
      11 Dump            >   Sec-Fetch-Mode: cors
      12 Dump            >   Sec-Fetch-Dest: empty
      13 Dump            >   Referer: http://127.0.0.1:19487/
      14 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      15 Dump            >   Accept-Language: en-US,en;q=0.9
      16 Interceptor     preHandle       REQUEST /customers handler TiffinBoxServer#customers
      17 Interceptor     postHandle      REQUEST /customers status 200 committed false
      18 Interceptor     afterCompletion REQUEST /customers status 200 exception none
      19 Dump            < 200 GET /customers
      20 Dump            <   X-Post-Handle: set
      21 Dump            <   Content-Type: application/json
      22 Dump            <   body: [[{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]]
    WARN lines they added: 0 · ERROR lines: 0
$ node harness/cdp.mjs 19489 close
  Chrome exit 0 · listening on 19489 now: 0 · its profile removed
$ python3 harness/netlog.py .harness/netlog.json 19484 19486 19487
  Chrome's NetLog - every address it connected to or tried, its own background requests included: 127.0.0.1 only: yes · ports 19484, 19486, 19487 among them: yes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19484 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19484 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - TiffinBox with FilterCors joined too (a CorsFilter on every path, its one rule for /probe/filter/**), port 19485; Chrome again, a fresh profile:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19485 --spring.main.sources=probe.web.Dump,probe.web.CorsRoutes,probe.web.FilterCors,probe.web.Hooks
  listens on: 127.0.0.1:19485 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19485/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Hooks): en_US
$ "$CHROME" --headless=new --user-data-dir="$PWD/.harness/chrome" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 --host-resolver-rules='MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' --remote-debugging-address=127.0.0.1 --remote-debugging-port=19489 --log-net-log="$PWD/.harness/netlog.json" about:blank
  its profile, .harness/chrome, made fresh for this run (it did not exist before this line): yes
  listens on: 127.0.0.1:19489 · loopback only: yes
C - the page on http://127.0.0.1:19486 asks for PUT /probe/cors/menu:
$ node harness/cdp.mjs 19489 visit 'http://127.0.0.1:19486/cors.html?m=PUT&u=http://127.0.0.1:19485/probe/cors/menu' .harness/ev.json
  the page printed: refused: TypeError: Failed to fetch
$ python3 harness/net.py .harness/ev.json 19485
  Chrome's own record (its DevTools protocol) - the requests the page made to TiffinBox: 2
    OPTIONS /probe/cors/menu - a preflight, for the PUT below · sent: yes · the answer Chrome got: 200
      as Chrome sent it, its 13 headers:
        Accept: */*
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Access-Control-Request-Headers: content-type
        Access-Control-Request-Method: PUT
        Connection: keep-alive
        Host: 127.0.0.1:19485
        Origin: http://127.0.0.1:19486
        Referer: http://127.0.0.1:19486/
        Sec-Fetch-Dest: empty
        Sec-Fetch-Mode: cors
        Sec-Fetch-Site: same-site
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
    PUT /probe/cors/menu - the page's fetch · sent: no · no answer · handed to the page: no - Chrome's CORS check: PreflightMissingAllowOriginHeader
  the server's record:
    the harness's lines it printed, in order: 16
       1 Dump            > OPTIONS /probe/cors/menu
       2 Dump            >   Host: 127.0.0.1:19485
       3 Dump            >   Connection: keep-alive
       4 Dump            >   Accept: */*
       5 Dump            >   Access-Control-Request-Method: PUT
       6 Dump            >   Access-Control-Request-Headers: content-type
       7 Dump            >   Origin: http://127.0.0.1:19486
       8 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
       9 Dump            >   Sec-Fetch-Mode: cors
      10 Dump            >   Sec-Fetch-Site: same-site
      11 Dump            >   Sec-Fetch-Dest: empty
      12 Dump            >   Referer: http://127.0.0.1:19486/
      13 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      14 Dump            >   Accept-Language: en-US,en;q=0.9
      15 Dump            < 200 OPTIONS /probe/cors/menu
      16 Dump            <   body: []
    WARN lines they added: 0 · ERROR lines: 0
D (labelled) - the control: the filter's own path, whose answer carries no max age - the same page on http://127.0.0.1:19486 asks for PUT /probe/filter/menu:
$ node harness/cdp.mjs 19489 visit 'http://127.0.0.1:19486/cors.html?m=PUT&u=http://127.0.0.1:19485/probe/filter/menu' .harness/ev.json
  the page printed: answer 200 {"menu":"filter"}
$ python3 harness/net.py .harness/ev.json 19485
  Chrome's own record (its DevTools protocol) - the requests the page made to TiffinBox: 2
    OPTIONS /probe/filter/menu - a preflight, for the PUT below · sent: yes · the answer Chrome got: 200
      as Chrome sent it, its 13 headers:
        Accept: */*
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Access-Control-Request-Headers: content-type
        Access-Control-Request-Method: PUT
        Connection: keep-alive
        Host: 127.0.0.1:19485
        Origin: http://127.0.0.1:19486
        Referer: http://127.0.0.1:19486/
        Sec-Fetch-Dest: empty
        Sec-Fetch-Mode: cors
        Sec-Fetch-Site: same-site
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
    PUT /probe/filter/menu - the page's fetch · sent: yes · the answer Chrome got: 200 · handed to the page: yes
  the server's record:
    the harness's lines it printed, in order: 51
       1 Dump            > OPTIONS /probe/filter/menu
       2 Dump            >   Host: 127.0.0.1:19485
       3 Dump            >   Connection: keep-alive
       4 Dump            >   Accept: */*
       5 Dump            >   Access-Control-Request-Method: PUT
       6 Dump            >   Access-Control-Request-Headers: content-type
       7 Dump            >   Origin: http://127.0.0.1:19486
       8 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
       9 Dump            >   Sec-Fetch-Mode: cors
      10 Dump            >   Sec-Fetch-Site: same-site
      11 Dump            >   Sec-Fetch-Dest: empty
      12 Dump            >   Referer: http://127.0.0.1:19486/
      13 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      14 Dump            >   Accept-Language: en-US,en;q=0.9
      15 Dump            < 200 OPTIONS /probe/filter/menu
      16 Dump            <   Vary: Origin
      17 Dump            <   Vary: Access-Control-Request-Method
      18 Dump            <   Vary: Access-Control-Request-Headers
      19 Dump            <   Access-Control-Allow-Origin: http://127.0.0.1:19486
      20 Dump            <   Access-Control-Allow-Methods: GET,PUT
      21 Dump            <   Access-Control-Allow-Headers: content-type
      22 Dump            <   body: []
      23 Dump            > PUT /probe/filter/menu
      24 Dump            >   Host: 127.0.0.1:19485
      25 Dump            >   Connection: keep-alive
      26 Dump            >   Content-Length: 2
      27 Dump            >   sec-ch-ua-platform: (<platform masked>)
      28 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      29 Dump            >   sec-ch-ua: (its brands and their versions: masked)
      30 Dump            >   Content-Type: application/json
      31 Dump            >   sec-ch-ua-mobile: ?0
      32 Dump            >   Accept: */*
      33 Dump            >   Origin: http://127.0.0.1:19486
      34 Dump            >   Sec-Fetch-Site: same-site
      35 Dump            >   Sec-Fetch-Mode: cors
      36 Dump            >   Sec-Fetch-Dest: empty
      37 Dump            >   Referer: http://127.0.0.1:19486/
      38 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      39 Dump            >   Accept-Language: en-US,en;q=0.9
      40 Interceptor     preHandle       REQUEST /probe/filter/menu handler CorsRoutes#filtered
      41 CorsRoutes      filtered
      42 Interceptor     postHandle      REQUEST /probe/filter/menu status 200 committed false
      43 Interceptor     afterCompletion REQUEST /probe/filter/menu status 200 exception none
      44 Dump            < 200 PUT /probe/filter/menu
      45 Dump            <   Vary: Origin
      46 Dump            <   Vary: Access-Control-Request-Method
      47 Dump            <   Vary: Access-Control-Request-Headers
      48 Dump            <   Access-Control-Allow-Origin: http://127.0.0.1:19486
      49 Dump            <   X-Post-Handle: set
      50 Dump            <   Content-Type: application/json
      51 Dump            <   body: [{"menu":"filter"}]
    WARN lines they added: 0 · ERROR lines: 0
D again - the same page, the same Chrome, seven seconds later:
$ sleep 7
$ node harness/cdp.mjs 19489 visit 'http://127.0.0.1:19486/cors.html?m=PUT&u=http://127.0.0.1:19485/probe/filter/menu' .harness/ev.json
  the page printed: answer 200 {"menu":"filter"}
$ python3 harness/net.py .harness/ev.json 19485
  Chrome's own record (its DevTools protocol) - the requests the page made to TiffinBox: 2
    OPTIONS /probe/filter/menu - a preflight, for the PUT below · sent: yes · the answer Chrome got: 200
      as Chrome sent it, its 13 headers:
        Accept: */*
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Access-Control-Request-Headers: content-type
        Access-Control-Request-Method: PUT
        Connection: keep-alive
        Host: 127.0.0.1:19485
        Origin: http://127.0.0.1:19486
        Referer: http://127.0.0.1:19486/
        Sec-Fetch-Dest: empty
        Sec-Fetch-Mode: cors
        Sec-Fetch-Site: same-site
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
    PUT /probe/filter/menu - the page's fetch · sent: yes · the answer Chrome got: 200 · handed to the page: yes
  the server's record:
    the harness's lines it printed, in order: 51
       1 Dump            > OPTIONS /probe/filter/menu
       2 Dump            >   Host: 127.0.0.1:19485
       3 Dump            >   Connection: keep-alive
       4 Dump            >   Accept: */*
       5 Dump            >   Access-Control-Request-Method: PUT
       6 Dump            >   Access-Control-Request-Headers: content-type
       7 Dump            >   Origin: http://127.0.0.1:19486
       8 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
       9 Dump            >   Sec-Fetch-Mode: cors
      10 Dump            >   Sec-Fetch-Site: same-site
      11 Dump            >   Sec-Fetch-Dest: empty
      12 Dump            >   Referer: http://127.0.0.1:19486/
      13 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      14 Dump            >   Accept-Language: en-US,en;q=0.9
      15 Dump            < 200 OPTIONS /probe/filter/menu
      16 Dump            <   Vary: Origin
      17 Dump            <   Vary: Access-Control-Request-Method
      18 Dump            <   Vary: Access-Control-Request-Headers
      19 Dump            <   Access-Control-Allow-Origin: http://127.0.0.1:19486
      20 Dump            <   Access-Control-Allow-Methods: GET,PUT
      21 Dump            <   Access-Control-Allow-Headers: content-type
      22 Dump            <   body: []
      23 Dump            > PUT /probe/filter/menu
      24 Dump            >   Host: 127.0.0.1:19485
      25 Dump            >   Connection: keep-alive
      26 Dump            >   Content-Length: 2
      27 Dump            >   sec-ch-ua-platform: (<platform masked>)
      28 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      29 Dump            >   sec-ch-ua: (its brands and their versions: masked)
      30 Dump            >   Content-Type: application/json
      31 Dump            >   sec-ch-ua-mobile: ?0
      32 Dump            >   Accept: */*
      33 Dump            >   Origin: http://127.0.0.1:19486
      34 Dump            >   Sec-Fetch-Site: same-site
      35 Dump            >   Sec-Fetch-Mode: cors
      36 Dump            >   Sec-Fetch-Dest: empty
      37 Dump            >   Referer: http://127.0.0.1:19486/
      38 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      39 Dump            >   Accept-Language: en-US,en;q=0.9
      40 Interceptor     preHandle       REQUEST /probe/filter/menu handler CorsRoutes#filtered
      41 CorsRoutes      filtered
      42 Interceptor     postHandle      REQUEST /probe/filter/menu status 200 committed false
      43 Interceptor     afterCompletion REQUEST /probe/filter/menu status 200 exception none
      44 Dump            < 200 PUT /probe/filter/menu
      45 Dump            <   Vary: Origin
      46 Dump            <   Vary: Access-Control-Request-Method
      47 Dump            <   Vary: Access-Control-Request-Headers
      48 Dump            <   Access-Control-Allow-Origin: http://127.0.0.1:19486
      49 Dump            <   X-Post-Handle: set
      50 Dump            <   Content-Type: application/json
      51 Dump            <   body: [{"menu":"filter"}]
    WARN lines they added: 0 · ERROR lines: 0
$ node harness/cdp.mjs 19489 close
  Chrome exit 0 · listening on 19489 now: 0 · its profile removed
$ python3 harness/netlog.py .harness/netlog.json 19485 19486
  Chrome's NetLog - every address it connected to or tried, its own background requests included: 127.0.0.1 only: yes · ports 19485, 19486 among them: yes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19485 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19485 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the origins:
  the origin on 19486 stopped by its pid · exit 143 · listening on 19486 now: 0
  the origin on 19487 stopped by its pid · exit 143 · listening on 19487 now: 0
```

## Exercise

**Your turn:** the README's preflight comes back with no CORS headers. Find the filter that answers every preflight, remove it, and ask again.
`exercise/README.md` has the commands (copy the anchor and `KitchenCors.java`, give the copy a token of its own); its last line, in a
subshell, builds the copy offline, compiles the class, starts it on 19488, sends the menu's preflight, stops it, waits for its JVM and prints
— as shipped — `the preflight: 200 · Access-Control-Allow-Origin: [] · Access-Control-Max-Age: []`. Done is `the preflight: 200 ·
Access-Control-Allow-Origin: [http://127.0.0.1:19486] · Access-Control-Max-Age: [1800]`. curl only (S4.4: no exercise needs Chrome). Measured
answer: `exercise/solution/`. Run `./receipts.sh` once first on a fresh clone.

## The ledger rows and hand-offs this unit pays

- **The roadmap's U19 line** — "a real preflight in browser devtools; `@CrossOrigin` vs global config": a real preflight in a real browser,
  recorded by Chrome's own network events and by the server (`browser`), and `@CrossOrigin` against the registry and a `CorsFilter` (`ways`).
  "In browser devtools" is sharpened (brief ⚑8): no panel; Chrome's DevTools protocol is named once, as what records the request.
- **C6-31's U19 flag** — "if a course uses it, a course teaches it": no developer-tools panel is used, so none is taught; what records the
  request is named. Glossed at first spoken use: an origin, cross-origin, a preflight, the preflight cache, a simple request.
- **R.86** — decided by the brief (⚑8): curl plus a headless browser, loopback only. Its "ledger C6-33" pointer is stale (the flags are C6-31's;
  for BLUE).

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-22) |
|---|---|---|---|
| 2 | Every 19 capture on its own harness and `16/after` | the probe's `base/` | **all five captures here** |
| 3 | 19's joined `CorsFilter` in Chrome (C) | inferred | **measured (`browser` C): the preflight 200 empty, the `PUT` never sent, `PreflightMissingAllowOriginHeader`** |
| 4 | 19's preflight cache across a receipt's 3 runs | 2 probe runs | **3/3 under each bash and in the clone: a fresh profile per run, visit 1 OPTIONS + PUT, visit 2 PUT alone** |
| 14 | The exercise as viewers run it | end states on sketches | **README then SOLUTION in one `env -i` shell, exit 0 each** (`exercise`, and "Found on the way") |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **`*` + credentials fails a request with no `Origin` too** (`star`): the brief's "every request on the mapping — preflight or GET" holds,
  and is wider than it says: a plain `GET` with no `Origin` header — not a cross-origin request at all — is a 500 as well. The voice says
  "every request we sent to that path, even one with no Origin".
- **"Nobody set that number"** (`Max-Age: 1800`): `javap -c` on spring-web-7.0.9's `CorsConfiguration.applyPermitDefaultValues()`:
  `ldc2_w 1800` → `putfield maxAge` (no named constant), called by `CorsRegistration`'s constructor (the registry) and by
  `RequestMappingHandlerMapping` for `@CrossOrigin` (whose own `maxAge()` defaults to -1) — RED S4 #306. The deck's chip names the method.
- **"A `CorsFilter` answers every preflight that reaches it"** holds for 7.0.9 from the code, beyond the three paths measured: `javap -c
  CorsFilter.doFilterInternal` — `if (!valid || isPreFlight) return;`, never `chain.doFilter` (RED S4 #319).
- **The 403's headers:** besides the three `Vary` lines, `Transfer-Encoding: chunked` (curl) — a body with no `Content-Type`, as the brief said.
- **Chrome's page itself is not counted**: jwebserver serves it, and a second visit of the same page may come from Chrome's cache; `net.py`
  reads only the requests to TiffinBox's port (the page carries a `data:` icon, so Chrome asks no origin for `/favicon.ico`).
- **The brief's sketch and this tree agree** on every other line of its unit block: Max-Age 1800 nobody set, the three `Vary`, the 403 text
  and its missing Content-Type, the unconfigured 200 with `Allow`, the annotation = the registry, the filter's missing `Max-Age` and `Allow`,
  the joined filter's empty 200, and all four browser outcomes.

## Found on the way

- **A Chrome that exits 2** (BLUE S4 part 1, 2026-10-23): one bash 5.3 run's `browser` drifted — its second run's first Chrome exited 2 at
  `Browser.close` (its log: macOS `CVDisplayLinkCreateWithCGDisplay failed`), the other runs 0. The drift check stopped the run, as it
  must; the re-run passed 3/3. Chrome's exit code stays in the capture: a Chrome that cannot close cleanly is a fault worth stopping for.
- **Every new check fails on a planted fault first** (R.65): the checks block runs alone (`cap()` a no-op, the build and the wipe skipped) on
  the published captures with one thing changed per plant, the file restored after each — **46 plants, 46 stops under /bin/bash 3.2 and 46
  under bash 5.3**, each naming its own check; the unplanted files pass before and after under both, and the published captures' md5s are
  unchanged. Thirty-eight change a capture: the allowed preflight's max age and a `Vary` line; a `Content-Type` and a harness line planted on
  the 403; a CORS header on the unconfigured path; a customer removed from the list; the handler's name; the seven's hash; the locale; the
  no-`Origin` `Allow`; the two ways made different; A′ ≠ A; a `Max-Age` on the filter's own path; a CORS header on B's empty answer; a star
  request's ERROR count, its `Connection: close`, the run's total, a WARN at start; the exercise's done line, its folder, an added line in its
  diff; visit 2's request count and a planted `OPTIONS`; visit 3's `sent:` and a planted `PUT` in `Dump`; visit 4's handed-to-the-page and its
  handler; the NetLog's seal; a profile not fresh; Chrome's exit; a hook in C; Chrome's version unmasked; an unpinned jwebserver and java line;
  an unmasked timestamp; an absolute path; the raw token, in a capture and in a raw count. Eight change a shipped file: a `maxAge` in
  `CorsRoutes`, `StarCreds`' rule, the last lesson's `Trace` edited, the spoken exercise line, SOLUTION.md's Done line, a bare `wait` in the
  exercise README, a `pkill` in a harness reader, Boot 3's error key in this README.
- **Filters checked on planted inputs inside the script itself**, before any capture: the level counts (a hook line that says ERROR and one
  record of each level: 1 and 1 by line shape, 2 by a bare `' ERROR '`), the record filter, the harness's lines (a falling running number
  stops the run), the header filter (carriage return, trailing space, `Date`), Chrome's two masks (and nothing else masked).
- **Found while building:** the first sketch of `Dump` printed `POST /shutdown` whole — the demo token in its header, in the log: `Dump` now
  skips `/shutdown`, and `logtok()` (0 tokens, 0 header names in every log) would have stopped the run. The first `C` NetLog line named the
  19487 origin the C page never used ("among them: no"): each Chrome run now names only its own ports. A pkill check first matched the
  sentence in its own comment: it reads command lines only. Chrome loads a page's `/favicon.ico` from the origin unless told otherwise: the
  page carries a `data:` icon.
- **SIGINT**, measured three times, the script started as a terminal starts its foreground job (`python3` with `SIG_DFL` and `os.setpgrp()`,
  `env -i`, /bin/bash 3.2): at 40 s (during the build); 2 s after `preflight`'s harness JVM appeared (1 TiffinBox JVM in the group); and 2 s
  after Chrome appeared in `browser` (318 s; TiffinBox, both jwebservers and Chrome running): **exit 130** each; 5 s later no TiffinBox JVM,
  no jwebserver, no process with this unit's profile, the profile folder gone; 19480-19489, 8080, 18425 and 35729 free; no `.r-lock`, no
  unfinished capture run; the published captures unchanged (md5). The author's own Chrome: 31 processes before, 31 after, every time.
- **The exercise as viewers run it**, beyond the capture: `env -i` `/bin/bash` — the README's six lines, then SOLUTION's four, then SOLUTION's
  four again — prints the shipped line, then the done line twice, exit 0 each, the shell left in `c6-unit19/`; the README's last line alone
  without the exports (`java` 23.0.1) exits 1 and prints no line; 19488 free after each.

## For the next lesson — and RED

- This unit reads `../c6-unit16/after` only (no change). The browser step's method — a fresh sealed profile, `cdp.mjs`, `net.py`,
  `netlog.py`, `Dump` as the server's witness, Chrome's version masked — is here for *Serving HTML: Thymeleaf*, *Static Resources and Cache
  Headers* and *Sessions, Cookies and Flash Attributes* to adapt (their own copies, their own ports).
- **For RED:** re-run under both bashes, the sealed clone, SIGINT during a capture's JVM and during Chrome; check that nothing of Vivek's
  Chrome is touched (its process count before and after); every browser claim's two witnesses (Chrome's `sent:` and the server's `Dump`);
  that `Max-Age: 1800` is set by nothing in the harness; the 403's missing `Content-Type`; the `star` 500 with no `Origin`; the exercise in one
  shell and under Java 23; that no harness class reached the anchor.
