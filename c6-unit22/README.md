# c6-unit22 — Serving HTML: Thymeleaf

Course 6 · Spring Web MVC · Section 4 (The Rest of MVC), its fifth unit and the first link of its anchor chain (22 → 23 → 24) ·
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5, Hibernate
Validator 9.1.3.Final, **Thymeleaf 3.1.5**), **GraalVM CE 25.3.4.1** (native-image 25.0.4.1), **Docker on OrbStack**, **headless Chrome
155** driven by **node 26** (both optional), 2026-10-22. Since the course began TiffinBox has answered every client in JSON: a browser
that asked for `/dashboard` got braces. This unit gives a person a page: Boot's Thymeleaf starter, a `@Controller` whose routes return a
view's name, four templates — the dashboard, a form, the fragments they share, an error page — and a stylesheet. It measures that the
seven do not move, who answers which client, the shared pieces, a form that refuses in words and redirects after its POST, a real
browser's request and the server's record of it, what breaks and how it reads, the template cache with and without DevTools, and that
the jar, the AOT jar, the native binary and the image all serve every page.

**The anchor changes (brief ⚑2, ⚑3).** `after/` is this unit's frozen copy of `../c6-tiffinbox` after the change, and
`diff -rq -x target ../c6-tiffinbox after/` is empty at this unit's commit. "Before" is `before/`, the link to `../c6-unit16/after` — the
problem-detail lesson's frozen tree, which `c6-tiffinbox` equalled before this unit (`diff -rq -x target` empty, checked first). Both
trees are read and copied under `.harness/`, never built in place. Two files changed and six are new (`change`):

- `tiffinbox-web/pom.xml` — 130 → 137 lines: `spring-boot-starter-thymeleaf`, with a three-line comment. The executable jar's libraries
  56 → 61: `attoparser-2.0.7.RELEASE`, `spring-boot-thymeleaf-4.1.1`, `thymeleaf-3.1.5.RELEASE`, `thymeleaf-spring6-3.1.5.RELEASE`,
  `unbescape-1.1.6.RELEASE` (none removed).
- `DashboardPage.java` (new, 100 lines, 63 of code) — package-private, final, `@Controller`, `@ImportRuntimeHints(DashboardPage.TemplateHints.class)`:
  `GET /dashboard` `produces = text/html` → `dashboard` (the model: `view`, and `customerCount`, counted in Java); `GET /customers/new`
  `produces = text/html` → `customer-form` (a new `Customer("", 1, 120, "VEG")`); `POST /customers` `consumes =
  application/x-www-form-urlencoded`, `@Valid @ModelAttribute("customer") Customer` + `BindingResult` → the form again, or — a taken name,
  H2's SQLSTATE 23505 — the form with `a customer named X already exists` on the name, or `redirect:/dashboard`; every other
  `SQLException` stays Spring MVC's 500. `TemplateHints` registers `Dashboard.View` and `Customer` with `INVOKE_PUBLIC_METHODS`.
- `templates/fragments.html` (12 lines: `head(title)`, `header`, `footer`), `templates/dashboard.html` (15), `templates/customer-form.html`
  (17: `th:object`, four `th:field`, four `th:errors`), `templates/error/5xx.html` (12) — **four templates; no `error/404.html`** (brief
  ⚑3 loser A; `errors` C) — and `static/css/tiffinbox.css` (5 lines).
- `README.md` — the anchor's: its unit 22 section, and eight history notes made false by this change (below).

25 of `after/`'s 33 files are byte for byte the previous tree's; the jar's `com/tiffinbox/web` classes 9 → 11.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 9 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.) **Docker must answer**, with
`eclipse-temurin:25-jre` already on it: the script never pulls. It **dies** when a capture's md5 differs from `receipts.md5`. One native
build per `forms` run (three per receipt), each bounded at 20 minutes; its seconds go to the terminal only. **Start it in a process
group of its own** (a terminal's foreground job is one): two receipts started as background jobs of one shell share a group, and one
run's clean-up would stop the other's processes (R.94).

**Runs (2026-10-22):** each `env -i` (HOME and a plain PATH, `GRAALVM_HOME`, `DOCKER_CONFIG=~/.docker`), a process group of its own,
`.m2-demo` re-seeded from `_research/m2-seed-s4/` alone. **1,509 s under `./receipts.sh`** (/bin/bash 3.2.57): all 9 captures 3/3, every
check passed, then — as designed for a first run — "no published hash"; **1,605 s under `bash receipts.sh`** (Homebrew bash 5.3.9): the
same nine hashes, which went into `receipts.md5`. Then `exercise` gained its cut's label (160 characters) and `negotiate` the previous
tree's two answers the voice rests on — Chrome's Accept got JSON ("a person gets braces") and a form's type got a 415 ("used to be a four
fifteen"); each changed hash was taken from one run and confirmed 3/3 by the next full runs: **1,340 s, 1,252 s and 1,269 s under
`./receipts.sh`** (the last stopped at a check that read one line too many — it now reads the answer's three — and the checks then passed on
those captures), and a full run under `./receipts.sh` that a SIGINT test meant to interrupt (its detector missed the build): exit 0, all 9
= published. **A sealed fresh clone**, the script as committed (`git clone` of tiffinbox-java at 68decd8, this unit's and the anchor's 81
files put in as git would take them — 0 differing from the working tree, `before` → `../c6-unit16/after` by `readlink`; `env -i`, a
`HOME` of its own whose `.mavenrc` points every Java proxy at a refusing port, Maven settings sending every repository to a `file://`
copy of Central's files made from `_research/m2-seed-s4/` (4,425 files), the proxy variables at the same refusing port, `GRAALVM_HOME`,
`DOCKER_CONFIG`, `/bin/bash` 3.2, a process group of its own): **exit 0, all 9 = published, every check passed, 1,244 s; 720 artifacts,
every one from the `file://` copy** — its first build said `offline: no`, as a fresh clone's must, DevTools' `dependency:get` the same,
every capture's build `offline: yes`. (The first sealed run stopped at the start-up check: DevTools' jar, which no build fetches, was not
in the empty `.m2-demo` — fixed, "Found on the way"; the second passed, 1,280 s, before the 415 line was added.) **A last run on the finished files** (this README, the anchor's,
everything as committed but this sentence): **1,273 s under `bash receipts.sh`** (Homebrew bash 5.3.9), exit 0, all 9 = published. Every native
build took 258-271 s (terminal only), under the 20-minute bound.

**Runs after BLUE S4 part 2 (2026-10-23; RED S4 #381, #404, #405):** `receipts.sh` changed — the platform masked beside Chrome's version
(`browser` re-hashed: `ef15ea30…` → `e5813b31…`, the other eight unchanged) and DevTools' exit 1 asserted (R.109). One development run
(bash 3.2, 1,677 s; a first attempt stopped at `browser`'s 3/3 — one Chrome exited 2 at `Browser.close`, macOS display-link errors, while a
probe Chrome of BLUE's ran beside it; re-run alone, clean) fixed the new hash; then, each `env -i` (HOME, a plain PATH, `GRAALVM_HOME`,
`DOCKER_CONFIG`), a session of its own: **1,334 s under `./receipts.sh`** (/bin/bash 3.2.57) and **1,341 s under `bash receipts.sh`**
(Homebrew bash 5.3.9), each exit 0, all 9 captures 3/3 = published, every check passed. The sealed-clone paragraph above was written before
RED S4 #405: as described it does not seal — the recipe below does, and BLUE ran it on unit 24, the chain's last link (its README).

Published hashes: change `cc0facce09584f595e74e510a5383f72` · negotiate `272886cf940f405e2663a98867216752` · fragments `8a74be8243572993861dff36c7fe07cf` · form `8e9129aef35d677a0bf43274241c3f06` · errors `a336d7be70d7526c4c76318e033ef369` · devtools `cdd84a4a529abacdbb04c2817c27d7ed` · exercise `3056eabd5017a806d02b291728decab6` · browser `e5813b3124b0138e7f856156221ee50b` · forms `b339f789b47d58abffe4e54a165dfd6b`.

### A sealed fresh clone — the recipe (RED S4 #405)

A sealed clone proves that a fresh clone's first build fetches only from a copy you control. **The earlier text of this paragraph did not
seal** (RED S4 #405, measured): a `HOME` of its own whose `.mavenrc` set only `-Dhttp(s).proxyHost`, with Maven settings in `$HOME/.m2`,
fetched from Maven Central — Java on macOS ignores `$HOME` (`user.home` stays your own folder, so Maven never read those settings), and
Maven's resolver ignores the `-Dhttp.proxyHost` properties (it takes its proxies from `settings.xml`). The recipe that seals, step by step,
with a pre-flight that refuses to start unless the only remote is `file://` and a post-check of where every artifact came from:

```bash
S=/tmp/sealed-22                                   # an empty folder of your own; T = your tiffinbox-java clone
mkdir -p "$S/home/.m2" && git clone -q "file://$T" "$S/tiffinbox-java"
rsync -a --exclude _remote.repositories --exclude '*.lastUpdated' --exclude resolver-status.properties "$T/c6-unit22/.m2-demo/" "$S/central/"
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
X=http://127.0.0.1:9; E="env -i HOME=$S/home PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin http_proxy=$X https_proxy=$X HTTP_PROXY=$X HTTPS_PROXY=$X no_proxy=127.0.0.1,localhost NO_PROXY=127.0.0.1,localhost GRAALVM_HOME=$GRAALVM_HOME DOCKER_CONFIG=$HOME/.docker"     # this unit's native build and image need both (your own GraalVM and Docker)
# pre-flight: an artifact that exists nowhere, asked for through the sealed settings - it must fail, having asked file:// and nothing else
$E JAVA_HOME=/opt/homebrew/opt/openjdk@25 mvn -B -Dmaven.repo.local="$S/preflight-m2" org.apache.maven.plugins:maven-dependency-plugin:3.8.1:get -Dartifact=org.example.sealed:absent:1 > "$S/preflight.log" 2>&1
[ $? != 0 ] && grep -q 'Downloading from sealed: file://' "$S/preflight.log" && ! grep -qE 'Downloading from [^ ]+: https?://' "$S/preflight.log" && echo "sealed: file:// only" || echo "NOT SEALED - do not run receipts.sh"
cd "$S/tiffinbox-java/c6-unit22" && $E ./receipts.sh            # a process group of its own (a terminal's foreground job is one)
# post-check: every artifact's origin, by repository id - each line must say sealed; 0 central
find .m2-demo -name _remote.repositories -exec cat {} + | grep -o '>[^=]*=' | sort | uniq -c
```

## The commands this unit adds

`after/README.md` — the anchor's own — gives every line `receipts.sh` runs or derives from but seventeen, which are this unit's, each
read from the block below and asserted to be exactly this (on the anchor's port 18431; each capture swaps in its own port):

```bash
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,mappings
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/classes:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/classes:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.thymeleaf.cache=false
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/classes:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.template.provider.cache=false
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Keys
javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/probe/web/Dump.java harness/probe/web/Keys.java harness/probe/web/Trace.java
curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:18431/dashboard
curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data 'name=Lata&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:18431/customers
sed -i '' 's/rendered on the server/edited while it runs/' tiffinbox-web/target/classes/templates/fragments.html
"$CHROME" --headless=new --user-data-dir="$PWD/.harness/chrome" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 --host-resolver-rules='MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' --remote-debugging-address=127.0.0.1 --remote-debugging-port=19519 --log-net-log="$PWD/.harness/netlog.json" about:blank
node harness/cdp.mjs 19519 open http://127.0.0.1:18431/dashboard .harness/ev.json
node harness/cdp.mjs 19519 form http://127.0.0.1:18431/customers/new .harness/ev.json 'name=Kiran&mealsPerDay=1&pricePerMeal=130&mealType=VEGAN'
node harness/cdp.mjs 19519 close
python3 harness/net.py .harness/ev.json 18431
python3 harness/netlog.py .harness/netlog.json 18431
```

The first three are the anchor's run line, class-path line and routing-table line (the request-mapping lesson's, `mappings` exposed for
one run) with `-Duser.language=en -Duser.country=US` after `java`. The **folder line** is the class-path line with the web module's
`target/classes` in place of its jar — templates read from a folder, so an edit while TiffinBox runs can be seen (`devtools`); the next
two are it with one option more, Thymeleaf's cache off and Boot's template-availability cache off. The DevTools line is the class-path
line with DevTools' jar from `.m2-demo` and the harness added, Live Reload off (35729 is never bound) and the harness's `Keys` joined.
The javac line compiles the harness's three classes against after/'s libraries. The page line is the anchor's new `curl -s -H 'Accept:
text/html' …/dashboard` with the headers and the body sent to files (`-D`, `-o`) and curl's status and Content-Type printed; the form
line is the anchor's new form POST the same way. The `sed` line is the edit made while TiffinBox runs. The Chrome line starts headless
Chrome with a profile made fresh under `.harness/chrome`, sealed (a dead proxy at `127.0.0.1:9`, every host name unresolvable but
127.0.0.1), its DevTools protocol on `127.0.0.1:19519`, a NetLog; `cdp.mjs` opens a page or fills and sends the form, then closes
Chrome; `net.py` reads Chrome's record of a visit's page requests, `netlog.py` the NetLog. Every other request is one of those with its
port, path, Accept, one header or its body swapped (`gq`, `fq`, `oq`, `sq`), or the problem-detail lesson's line with curl's
Content-Type printed (`tq`, `pq`); `nq` is the request-body lesson's POST without its `Content-Type`. The form bodies are Lata's (the
anchor's line), the validation lesson's four broken rules as a form (`name=&mealsPerDay=9&pricePerMeal=0&mealType=LUNCH`), letters for a
number (`mealsPerDay=two`) and a name of 61 letters — the customer table's `name` column is `VARCHAR(60)` (`tiffinbox-core`'s
`Database.java`, checked).

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else, refuses one whose `native-image --version` is not
`native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1`, and never prints its folder (`$GRAALVM_HOME` in every capture). Only `forms`
needs it. **Without a GraalVM** the script makes the eight other captures, each checked against `receipts.md5`, then stops where the
native build would start (exit 1).

## The browser

The `browser` capture needs **Chrome** (`CHROME=` at the top of `receipts.sh`: the app on the author's Mac) and **node 22 or later** (its
built-in WebSocket drives Chrome's DevTools protocol; nothing is installed). Both are optional: without them every curl capture runs and
is checked, and the script stops at the browser step with exit 2, naming this section — before the native build. Chrome runs headless
with a profile made fresh under `.harness/` for each run (never a user profile), sealed to 127.0.0.1, and is stopped by its pid — never
by its name (the author's own Chrome runs beside it, untouched). **Chrome auto-updates.** Its version is printed to the terminal only,
and masked in every capture (`User-Agent`'s `Chrome/<version>`, `sec-ch-ua`'s brand list whole), so a new Chrome that sends the same
request keeps the hash; one that sends anything else — a header more, an Accept string changed (Chrome 155's adds `image/jxl` to the one
earlier lessons typed) — changes it, and `cap()` dies: read the diff, then publish the new hash with the version in this README.
**Chrome's Accept header is captured from Chrome** (`browser`, visit 1) and the curl captures send that same string (`CHROMEA`): the
checks assert that the header Chrome sent, and the one the server read, are it (R.116). Chrome's own record is its DevTools protocol's
network events; no developer-tools panel is filmed or used.

## The repository, Docker, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../spring-web-mvc/_research/m2-seed-s4/` alone (5,891 files: the S3 seed and Thymeleaf's 54) and re-seeded so before each run of
record. **Nothing was downloaded** for this unit: every build said `offline: yes`, the native plugin read its metadata repository from
`.m2-demo`, and every native build log holds 0 lines of the plugin's own download. A fresh clone's `.m2-demo` is empty (git ignores it):
the first build — `after/`'s `mvn -B -Pnative install`, before any capture — fills it from Maven Central and says `offline: no`. DevTools is no dependency of the tree, so no build fetches it: when its jar is not in `.m2-demo`, it is fetched by name
(`dependency:get`, offline first, the DevTools lesson's way), and the line says which.
**Docker:** no pull — `docker build` prints its `load metadata` line and the base image's digest, and `its lines that say pull: 0`. The
image (`tiffinbox-pages:1.0.0`) and the container (`tiffinbox-pages`) are this script's own names, checked absent first and removed on
every exit. **At run time** every request goes to `127.0.0.1`.

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 30 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/*/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored), mounted read-only into the container, and sent only by `../c5-unit11/curlset.sh` and `harness/shutdown.sh` on curl's
standard input. Every capture's raw output is searched for it before masking (0 in all of them), and so are the log of every JVM that
served, the container's log, every file this unit ships, the binary's bytes and every blob of the image (`docker save`): 0 everywhere.
The header's name is counted too: 0 in every log. No capture sends a secret anywhere else, so no canary is needed. `Dump` prints every
page request's headers whole and passes POST /shutdown through unprinted. The exercise makes a token of its own (`openssl rand -hex 16`),
counted 0 times in its own log and never printed.

## The locale — pinned per JVM, and the request's language

Every java line this script starts carries `-Duser.language=en -Duser.country=US` before `-jar` or `-cp` (S4.1), and a last check refuses
any capture's java line without them; the harness's `Keys` prints the JVM's locale (`en_US`). **The request's `Accept-Language` beats it**
(S4.17): Hibernate Validator's messages on the form and Thymeleaf's `Content-Language` follow the language a request names — every
capture says which it sent; none: the JVM's, pinned (`form`: `de` → German messages and `Content-Language: de`). Chrome runs with
`--lang=en-US` and sends `Accept-Language: en-US,en;q=0.9` (`browser`). The binary's line passes no locale option; its pages say
`Content-Language: en` where the jar's say `en-US`, and its messages are English (`forms`).

## The folders, the names and the ports

- `after/` — the anchor after this change (= `../c6-tiffinbox`); `before` — the link to `../c6-unit16/after`. `.harness/before`,
  `.harness/after` — the two trees, copied, each with a config tree, built and extracted (`change`); `.harness/typo` — after/'s build with
  the exercise's template in its classes folder (`errors`); `.harness/c404` — after/'s build with `harness/c404/404.html` as
  `templates/error/404.html` in its classes folder (`errors` C); `.harness/fold` — after/'s build, its classes folder edited while
  TiffinBox runs (`devtools`); `.harness/nat` — after/'s native build, and `.harness/natb` — the previous tree built with the native
  profile, for its AOT metadata (`forms`); `.harness/hc` — the harness's classes; `.harness/chrome` — Chrome's profile, made fresh,
  removed on every exit; `.harness/mine` — the exercise's copy.
- **The harness** — the course's, never TiffinBox's (package `probe.web`, outside `com.tiffinbox`), joined by `--spring.main.sources`:
  `Dump` — a filter bean at the front of Boot's filters that prints every page request whole (its method, its path, every header in the
  order Tomcat holds them) and, when the request is done, its status, every header a filter can read (a Date's value not printed) and
  how many bytes of body the server wrote (never the body); Actuator's paths, POST /shutdown, `/css/` and `/favicon.ico` pass through
  unprinted (whether a browser asks for the stylesheet or the icon again is its cache's call — the next lesson's subject — so how many
  there are is not a witness); the CORS lesson's `Dump`, its body line changed to a count. `Keys` — once TiffinBox has started, the JVM's
  locale, every property source whose name says devtools with its keys and values, and what the environment answers for five keys.
  `Trace` — the CORS lesson's, byte for byte (checked): `HOOK`, a running number, the line. `harness/cdp.mjs`, `net.py` (new) and
  `netlog.py` (the CORS lesson's, byte for byte), `harness/shutdown.sh` (the CORS lesson's, byte for byte).
- **Ports** (brief ⚑1, 19510-19519): after/'s jar 19510 · the previous tree 19511 · a folder class path 19512 · DevTools 19513 · the AOT
  jar 19514 · the image 19515 · the binary 19516 · the browser's TiffinBox 19517 · the exercise 19518 · Chrome's DevTools port 19519. All
  ten, 18425, 8080 and 35729 are checked free first; a run that listens on 8080 or 35729 is killed and the script dies.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM, the token, the user, a request thread's number, Chrome's version** (`gsub()`, literals escaped), in every
   line: the demo token → `[masked: the 30-character token]`; the GraalVM's folder → `$GRAALVM_HOME`; this folder → `…`; the folder above
   → `…/..`; home → `~`; the user name, as a whole word → `<user>`; `tomcat-handler-<digits>` inside a message (Thymeleaf's ERROR line
   names its thread) → `tomcat-handler-<n>`; `Chrome/<digits>` → `Chrome/<version>`; a `sec-ch-ua:` value, whole → `(its brands and their
   versions: masked)`. **The platform** (RED S4 #381): the User-Agent's first brackets → `Mozilla/5.0 (<platform masked>)` and
   `sec-ch-ua-platform`'s value → `(<platform masked>)` — a viewer's Chrome on Linux or Windows sends other words there, so they never
   reach a hash; the terminal prints them instead (`Chrome … on Darwin arm64`). A last check fails if any capture holds an absolute path, the GraalVM's folder, a unit number, Boot's process
   line, a log time, an unmasked timestamp, a date, a thread number, a stack frame, a whole HTML page (`<html` or `<!doctype`), a Chrome
   version, the platform (`Macintosh`, `Mac OS X`, `Windows NT`, `X11;`, `Linux x86`, a quoted `sec-ch-ua-platform`), a `sha256:` ID other than the base image's digest, `:8080` or `:35729`, a carriage return, a java line without its locale,
   or a command with a URL that is not `127.0.0.1`'s.
2. **Spring's error timestamp** (`tsmask`): both forms → `…`, in every JSON answer printed and in the seven (the mask changes 0 lines:
   the seven hold no timestamp since the problem-detail lesson).
3. **A page is never printed whole** (`pagef`): a TiffinBox page as its `<title>`, its `<h1>`, its line and byte counts, and only what
   the capture asks for — `rows` (the counts line, tags taken out, and the table's first column), `form` (each input's name and value, and
   the message after it), `frag` (its `<head>` lines, `<header>` and `<footer>` lines, whole), `foot` (its `<footer>` line), `err` (its
   `<p>` lines, tags taken out), `sum` (nothing more); Boot's Whitelabel page as its `<h1>` and error line, its created date masked; any
   other HTML as its `<h1>` and length; JSON as its bytes. **The headers** (`heads`): the status line and the headers a page's answer
   turns on — `Content-Type`, `Content-Language`, `Location`, `Content-Length`, `Transfer-Encoding`, `Set-Cookie` — the rest counted.
   Each filter is checked on planted inputs before any capture.
4. **Log lines** (`logl`, `recs`): matched by the log's own line shape (a date first: R.120 — `Dump`'s and `Keys`' lines can never count
   as a level), printed from their logger on: `o.a.c.c.C.[.[.[/].[dispatcherServlet]` is **Tomcat's**; `org.thymeleaf.TemplateEngine`
   **Thymeleaf's**; `o.s.web.servlet.PageNotFound` **Spring MVC's**. A WARN or ERROR record: its level, logger and message, then its
   exception line, its frames bounded ("over 40") and its other lines counted, none shown.
5. **The harness's lines** (`hk`): printed in the order they ran, numbered from 1 for each request or visit; a falling running number
   stops the run.
6. **Chrome's record** (`net.py`): each document request, each hop of a redirect, its status and type (a redirect's Location), a form's
   body as Chrome sent it, and every header Chrome put on the wire, whole; the page's other requests named and not listed.
7. **Spring's AOT metadata** (`aotcmp`), **the native build's lines**, **docker build's lines**, **inside the container** and **on this
   Mac**: as the problem-detail lesson's receipts declare them; `aotcmp` names the new entries that are TiffinBox's or Thymeleaf's and
   counts the rest, and for an entry that differs, its methods and its other keys on each side.
8. **A′ against A** (`asame`): A's block and A′'s, their labels aside, compared line for line in the capture itself ("yes").

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the exercise's
shell (`$xpid`, with every process under it) and Chrome (`$cpid`, with every process under it — `killtree`), sweeps its own process group
for any TiffinBox JVM, binary, Maven or `native-image` left and every process started with this unit's own Chrome profile, removes the
container and the image, deletes Chrome's profile and the capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The
published captures are untouched. No `wait` in the script, its checks or the exercise is bare (a check refuses one).

**Measured** on the script as committed (2026-10-22), started as a terminal starts its foreground job (SIGINT at its default, a process
group of its own — from a script, `python3` with `signal.signal(signal.SIGINT, signal.SIG_DFL)` and `os.setpgrp()`), SIGINT to the
group three times: **during a capture's JVM** (`negotiate`, TiffinBox listening on 19510; 4 processes in the group), **during Chrome**
(`browser`, this unit's Chrome and its helpers running — 14 processes in the group), and **during the native build** (`forms`,
native-image's analysis running — 5 processes in the group). Each time: **exit 130** within 2 s; 5 s later 0 processes in the group, 0
TiffinBox JVMs, binaries or native-image builders anywhere, 0 Chrome processes with this unit's profile and the profile folder gone;
19510-19519, 8080, 18425 and 35729 free; no `tiffinbox-pages` container or image; no `.r-lock`; no unfinished capture run; the published
captures unchanged (md5 of all nine, before and after); the author's own Chrome — 31 processes — the same before and after.

## 1 · change — a starter, a controller, four templates, a stylesheet

Both trees copied under `.harness/`, built with the README's line (offline) and extracted; the harness compiled against after/'s libraries (three classes, `-parameters`). **Two files differ** — the anchor's `README.md` and `tiffinbox-web/pom.xml` — and three paths are only after/'s: `DashboardPage.java`, `static/`, `templates/`; 25 of 33 files byte for byte, 6 new. The POM's diff whole (the starter and its comment); `DashboardPage`'s code lines whole; each template's `th:` attributes counted; `error/404.html`: no. Boot's own metadata for Thymeleaf's prefix (`classpath:/templates/`), suffix (`.html`) and cache (default **true**). The jar: 56 → 61 libraries, the five named, none removed; 9 → 11 web classes; the four templates and the stylesheet inside it.

`.r-change.out` · md5 `cc0facce09584f595e74e510a5383f72` · 3 of 3

```
the previous tree and after/, both copied under .harness/ with a config tree, each built with the README's line (offline):
$ cd .harness/before && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the previous tree · offline: yes · exit 0
$ cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built after/ · offline: yes · exit 0
both jars extracted (the README's line) - the class path the harness runs on:
$ cd .harness/before && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
$ cd .harness/after && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
the harness, compiled against after/'s own libraries - with -parameters:
$ javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/probe/web/Dump.java harness/probe/web/Keys.java harness/probe/web/Trace.java
  exit 0 · its classes: probe/web/Dump$Tee$1.class probe/web/Dump$Tee.class probe/web/Dump.class probe/web/Keys.class probe/web/Trace.class
the files that differ, and the files only one tree has:
$ diff -rq -x target -x secrets .harness/before .harness/after
  Files .harness/before/README.md and .harness/after/README.md differ
  Files .harness/before/tiffinbox-web/pom.xml and .harness/after/tiffinbox-web/pom.xml differ
  Only in .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web: DashboardPage.java
  Only in .harness/after/tiffinbox-web/src/main/resources: static
  Only in .harness/after/tiffinbox-web/src/main/resources: templates
  after/'s files: 33 · byte for byte the previous tree's: 25 · new: 6 · those that differ: 2
  tiffinbox-web/pom.xml: 130 lines -> 137
  its diff (diff -U0, its file names cut) - hunks: 1 · lines out: 0 · in: 7 - whole:
    @@ -65,0 +66,7 @@
    +    <!-- Course 6: Thymeleaf, through Boot's starter - a template engine: it fills an HTML file's th:* attributes from the
    +         model a @Controller hands it, on the server, so a client that asks for HTML gets a finished page. Boot's module
    +         configures the engine and a view resolver for classpath:/templates/*.html. Boot's parent manages its version. -->
    +    <dependency>
    +      <groupId>org.springframework.boot</groupId>
    +      <artifactId>spring-boot-starter-thymeleaf</artifactId>
    +    </dependency>
  DashboardPage.java (new): 100 lines · its lines that are neither comment nor blank: 63 - whole:
    package com.tiffinbox.web;
    import com.tiffinbox.Customer;
    import com.tiffinbox.CustomerRepository;
    import com.tiffinbox.Dashboard;
    import jakarta.validation.Valid;
    import org.springframework.aot.hint.MemberCategory;
    import org.springframework.aot.hint.RuntimeHints;
    import org.springframework.aot.hint.RuntimeHintsRegistrar;
    import org.springframework.context.annotation.ImportRuntimeHints;
    import org.springframework.http.MediaType;
    import org.springframework.stereotype.Controller;
    import org.springframework.ui.Model;
    import org.springframework.validation.BindingResult;
    import org.springframework.web.bind.annotation.GetMapping;
    import org.springframework.web.bind.annotation.ModelAttribute;
    import org.springframework.web.bind.annotation.PostMapping;
    import java.sql.SQLException;
    @Controller
    @ImportRuntimeHints(DashboardPage.TemplateHints.class)
    final class DashboardPage {
        private static final String NAME_TAKEN = "23505";
        static final class TemplateHints implements RuntimeHintsRegistrar {
            @Override
            public void registerHints(RuntimeHints hints, ClassLoader loader) {
                hints.reflection().registerType(Dashboard.View.class, MemberCategory.INVOKE_PUBLIC_METHODS);
                hints.reflection().registerType(Customer.class, MemberCategory.INVOKE_PUBLIC_METHODS);
            }
        }
        private final Dashboard dashboard;
        private final CustomerRepository repo;
        DashboardPage(Dashboard dashboard, CustomerRepository repo) {
            this.dashboard = dashboard;
            this.repo = repo;
        }
        @GetMapping(value = "/dashboard", produces = MediaType.TEXT_HTML_VALUE)
        String page(Model model) throws Exception {
            Dashboard.View view = dashboard.load();
            model.addAttribute("view", view);
            model.addAttribute("customerCount", view.customers().size());
            return "dashboard";
        }
        @GetMapping(value = "/customers/new", produces = MediaType.TEXT_HTML_VALUE)
        String form(Model model) {
            model.addAttribute("customer", new Customer("", 1, 120, "VEG"));
            return "customer-form";
        }
        @PostMapping(value = "/customers", consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE)
        String add(@Valid @ModelAttribute("customer") Customer customer, BindingResult errors) throws SQLException {
            if (errors.hasErrors()) {
                return "customer-form";
            }
            try {
                repo.add(customer);
            } catch (SQLException e) {
                if (NAME_TAKEN.equals(e.getSQLState())) {
                    errors.rejectValue("name", "taken", "a customer named " + customer.name() + " already exists");
                    return "customer-form";
                }
                throw e;
            }
            return "redirect:/dashboard";
        }
    }
  the templates and the stylesheet (new) - their lines:
    templates/fragments.html: 12 · its th: attributes: th:fragment ×3, th:href ×3, th:text ×1
    templates/dashboard.html: 15 · its th: attributes: th:each ×1, th:replace ×3, th:text ×8
    templates/customer-form.html: 17 · its th: attributes: th:action ×1, th:errors ×4, th:field ×4, th:if ×4, th:object ×1, th:replace ×3
    templates/error/5xx.html: 12 · its th: attributes: th:href ×1, th:text ×2
    static/css/tiffinbox.css: 5 · its th: attributes: none
  templates/error/404.html in after/: no
  README.md - the anchor's README: lines added 100, removed 8 - its new section and the history notes the change made false (not shown)
  Boot's own metadata for Thymeleaf's keys (spring-boot-thymeleaf-4.1.1.jar, META-INF/spring-configuration-metadata.json):
  spring.thymeleaf.prefix - type String · default "classpath:/templates/" · Prefix that gets prepended to view names when building a URL.
  spring.thymeleaf.suffix - type String · default ".html" · Suffix that gets appended to view names when building a URL.
  spring.thymeleaf.cache - type Boolean · default true · Whether to enable template caching.
the executable jar's BOOT-INF/lib: 56 jars -> 61 · only after/'s: attoparser-2.0.7.RELEASE.jar spring-boot-thymeleaf-4.1.1.jar thymeleaf-3.1.5.RELEASE.jar thymeleaf-spring6-3.1.5.RELEASE.jar unbescape-1.1.6.RELEASE.jar · only the previous tree's: 0
the classes in the jar's com/tiffinbox/web: 9 -> 11 · only after/'s: DashboardPage$TemplateHints.class DashboardPage.class
the jar's templates and static files: static/css/tiffinbox.css templates/customer-form.html templates/dashboard.html templates/error/5xx.html templates/fragments.html
```

## 2 · negotiate — the seven, the routing table, one URL with two answers

The seven on both trees, each on a fresh JVM: `466c20ed…` both, the mask 0, **the same, byte for byte: 7**, one WARN line each (Spring MVC's `PageNotFound`). The routing table (`/actuator/mappings`, exposed for one run): **16 → 19 rows**, TiffinBox's routes 7 → 10 — two `GET /dashboard` (the page producing `text/html`, the JSON producing anything), two `POST /customers` (the form's consuming a form's type), `GET /customers/new` (HTML); on the previous tree, `/dashboard` for Chrome's whole Accept → the JSON (the braces a browser got before this lesson), and the request-body lesson's POST without its Content-Type → the 415 problem detail. Then, on after/, `/dashboard` for curl's own `*/*` and for `application/json` → the JSON; for `text/html` and for Chrome 155's whole Accept (sent by curl; `browser` shows Chrome sends it) → `200 text/html;charset=UTF-8`, `Content-Language: en-US`, the page (its counts and its table's first column); `/customers/new` for JSON → the 404 problem detail `no customer named new` (the old route reads `new` as a name), for HTML → the form; `Accept-Language: de` → `Content-Language: de`. 0 WARN, 0 ERROR.

`.r-negotiate.out` · md5 `272886cf940f405e2663a98867216752` · 3 of 3

```
the seven - the previous tree, the README's run line, port 19511, a fresh JVM:
$ cd .harness/before && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19511
  listens on: 127.0.0.1:19511 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19511/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19511 .harness/before/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
the seven - after/, the README's run line, port 19510, a fresh JVM:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19510
  listens on: 127.0.0.1:19510 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19510/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19510 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
the lines that moved - the previous tree's seven against after/'s, masked, line for line:
  lines that differ: 0 · the same, byte for byte: 7 (1 2 3 4 5 6 7)
the routing table - the previous tree, the README's routing-table line, port 19511:
$ cd .harness/before && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19511 --management.endpoints.web.exposure.include=health,prometheus,mappings
  listens on: 127.0.0.1:19511 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19511/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19511/actuator/mappings
  the dispatcher servlet's rows: 16 · TiffinBox's routes: 7, sorted by path:
    GET  /customers        TiffinBoxServer#customers    produces: any · consumes: any
    POST /customers        TiffinBoxServer#add          produces: any · consumes: any
    GET  /customers/{name} TiffinBoxServer#customer     produces: any · consumes: any
    GET  /dashboard        TiffinBoxServer#dashboard    produces: any · consumes: any
    GET  /kitchen          TiffinBoxServer#kitchen      produces: any · consumes: any
    GET  /revenue          TiffinBoxServer#revenue      produces: any · consumes: any
    POST /shutdown         TiffinBoxServer#shutdown     produces: any · consumes: any
  then the dashboard for a browser's whole Accept header (Chrome's, sent by curl), on the previous tree:
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' http://127.0.0.1:19511/dashboard
  curl's line: 200 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: application/json · Content-Length: 92 · headers not shown: 1
  body: {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  and the request-body lesson's POST without its Content-Type (curl's --data names a form's type), on the previous tree:
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19511/customers
  curl's line: 415 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 415 · Content-Type: application/problem+json · Transfer-Encoding: chunked · headers not shown: 2
  body: {"detail":"Content-Type 'application/x-www-form-urlencoded;charset=UTF-8' is not supported.","instance":"/customers","status":415,"title":"Unsupported Media Type"}
$ harness/shutdown.sh 19511 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19511 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the routing table - after/, port 19510:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19510 --management.endpoints.web.exposure.include=health,prometheus,mappings
  listens on: 127.0.0.1:19510 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19510/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19510/actuator/mappings
  the dispatcher servlet's rows: 19 · TiffinBox's routes: 10, sorted by path:
    GET  /customers        TiffinBoxServer#customers    produces: any · consumes: any
    POST /customers        DashboardPage#add            produces: any · consumes: application/x-www-form-urlencoded
    POST /customers        TiffinBoxServer#add          produces: any · consumes: any
    GET  /customers/new    DashboardPage#form           produces: text/html · consumes: any
    GET  /customers/{name} TiffinBoxServer#customer     produces: any · consumes: any
    GET  /dashboard        DashboardPage#page           produces: text/html · consumes: any
    GET  /dashboard        TiffinBoxServer#dashboard    produces: any · consumes: any
    GET  /kitchen          TiffinBoxServer#kitchen      produces: any · consumes: any
    GET  /revenue          TiffinBoxServer#revenue      produces: any · consumes: any
    POST /shutdown         TiffinBoxServer#shutdown     produces: any · consumes: any
$ harness/shutdown.sh 19510 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19510 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
one URL, two answers - after/, the README's run line, port 19510; no request names a language (Accept-Language) unless its line says so:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19510
  listens on: 127.0.0.1:19510 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19510/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19510/dashboard
  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]} 200 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: application/json' http://127.0.0.1:19510/dashboard
  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]} 200 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19510/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · 22 lines, 926 bytes - not shown but these:
    the counts: Customers: 4 · This month: 24300 · Paused days: 5
    the table, first column: Meera Priya Ravi Sunil
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' http://127.0.0.1:19510/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · 22 lines, 926 bytes - not shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: application/json' http://127.0.0.1:19510/customers/new
  {"detail":"no customer named new","instance":"/customers/new","status":404,"title":"Customer not found","name":"new"} 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19510/customers/new
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Add a customer · TiffinBox</title> · <h1>TiffinBox</h1> · 21 lines, 806 bytes - not shown
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' -H 'Accept-Language: de' http://127.0.0.1:19510/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: de · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · 22 lines, 926 bytes - not shown
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19510 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19510 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 3 · fragments — the head, the header and the footer, shared

The template lines that name `th:fragment` (fragments.html: three) or `th:replace` (each page: three; the error page: neither); then both pages asked for HTML, their `<head>` lines, `<header>` line and `<footer>` line printed whole: **7 lines each, 1 differs** — the `<title>`, the fragment's parameter.

`.r-fragments.out` · md5 `8a74be8243572993861dff36c7fe07cf` · 3 of 3

```
the template lines that put them there - after/'s templates, the lines that name th:fragment or th:replace:
$ grep -n -e 'th:fragment' -e 'th:replace' tiffinbox-web/src/main/resources/templates/fragments.html
  3:<head th:fragment="head(title)">
  9:<header th:fragment="header"><h1>TiffinBox</h1><nav><a th:href="@{/dashboard}">Dashboard</a> · <a th:href="@{/customers/new}">Add a customer</a></nav></header>
  10:<footer th:fragment="footer"><p>TiffinBox · rendered on the server</p></footer>
$ grep -n -e 'th:fragment' -e 'th:replace' tiffinbox-web/src/main/resources/templates/dashboard.html
  3:<head th:replace="~{fragments :: head('Dashboard')}"></head>
  5:<header th:replace="~{fragments :: header}"></header>
  13:<footer th:replace="~{fragments :: footer}"></footer>
$ grep -n -e 'th:fragment' -e 'th:replace' tiffinbox-web/src/main/resources/templates/customer-form.html
  3:<head th:replace="~{fragments :: head('Add a customer')}"></head>
  5:<header th:replace="~{fragments :: header}"></header>
  15:<footer th:replace="~{fragments :: footer}"></footer>
$ grep -n -e 'th:fragment' -e 'th:replace' tiffinbox-web/src/main/resources/templates/error/5xx.html
  none - it names neither
the two pages - after/, the README's run line, port 19510:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19510
  listens on: 127.0.0.1:19510 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19510/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19510/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · 22 lines, 926 bytes - not shown but these:
    | <head>
    |   <meta charset="utf-8">
    |   <title>Dashboard · TiffinBox</title>
    |   <link rel="stylesheet" href="/css/tiffinbox.css">
    | </head>
    | <header><h1>TiffinBox</h1><nav><a href="/dashboard">Dashboard</a> · <a href="/customers/new">Add a customer</a></nav></header>
    | <footer><p>TiffinBox · rendered on the server</p></footer>
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19510/customers/new
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Add a customer · TiffinBox</title> · <h1>TiffinBox</h1> · 21 lines, 806 bytes - not shown but these:
    | <head>
    |   <meta charset="utf-8">
    |   <title>Add a customer · TiffinBox</title>
    |   <link rel="stylesheet" href="/css/tiffinbox.css">
    | </head>
    | <header><h1>TiffinBox</h1><nav><a href="/dashboard">Dashboard</a> · <a href="/customers/new">Add a customer</a></nav></header>
    | <footer><p>TiffinBox · rendered on the server</p></footer>
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19510 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19510 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the dashboard's head, header and footer lines against the form's, line for line: 7 and 7 lines · lines that differ: 1 - <title>Dashboard · TiffinBox</title> against <title>Add a customer · TiffinBox</title>
```

## 4 · form — a form-backing object, a redirect, messages

The form's inputs (its form-backing object: `name` empty, 1, 120, `VEG`); Lata's POST (the anchor's line) → **302**, `Location: http://127.0.0.1:19510/dashboard`, `Content-Length: 0`, no body — the dashboard then lists Lata, 5 customers. The four broken rules → 200, the form, **four messages**, no Accept-Language sent: the JVM's English; with `Accept-Language: de`: German, `Content-Language: de`. `mealsPerDay=two` → Spring's raw conversion message. Lata again → `a customer named Lata already exists`. The JSON POST → 201. The request-body lesson's POST without its Content-Type → **200, the form, one raw message** (it was a 415). 0 WARN, 0 ERROR.

`.r-form.out` · md5 `8e9129aef35d677a0bf43274241c3f06` · 3 of 3

```
the form - after/, the README's run line, port 19510; no request names a language unless its line says so:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19510
  listens on: 127.0.0.1:19510 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19510/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19510/customers/new
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Add a customer · TiffinBox</title> · <h1>TiffinBox</h1> · 21 lines, 806 bytes - not shown but these:
    name = ""
    mealsPerDay = "1"
    pricePerMeal = "120"
    mealType = "VEG"
    messages on the page: 0
a valid form - the anchor's line - then the page it redirects to:
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data 'name=Lata&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:19510/customers
  curl's line: 302 · Content-Type: [] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 302 · Location: http://127.0.0.1:19510/dashboard · Content-Language: en-US · Content-Length: 0 · headers not shown: 1
  body: none (0 bytes)
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19510/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · 23 lines, 1000 bytes - not shown but these:
    the counts: Customers: 5 · This month: 31500 · Paused days: 5
    the table, first column: Lata Meera Priya Ravi Sunil
four rules broken:
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data 'name=&mealsPerDay=9&pricePerMeal=0&mealType=LUNCH' http://127.0.0.1:19510/customers
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Add a customer · TiffinBox</title> · <h1>TiffinBox</h1> · 21 lines, 1036 bytes - not shown but these:
    name = "" · its message: must not be blank
    mealsPerDay = "9" · its message: must be less than or equal to 3
    pricePerMeal = "0" · its message: must be greater than or equal to 1
    mealType = "LUNCH" · its message: must match "VEG|NON_VEG|VEGAN"
    messages on the page: 4
the same, the request naming German:
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept-Language: de' --data 'name=&mealsPerDay=9&pricePerMeal=0&mealType=LUNCH' http://127.0.0.1:19510/customers
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: de · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Add a customer · TiffinBox</title> · <h1>TiffinBox</h1> · 21 lines, 1041 bytes - not shown but these:
    name = "" · its message: darf nicht leer sein
    mealsPerDay = "9" · its message: muss kleiner-gleich 3 sein
    pricePerMeal = "0" · its message: muss größer-gleich 1 sein
    mealType = "LUNCH" · its message: muss mit "VEG|NON_VEG|VEGAN" übereinstimmen
    messages on the page: 4
letters for a number:
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data 'name=Om&mealsPerDay=two&pricePerMeal=120&mealType=VEG' http://127.0.0.1:19510/customers
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Add a customer · TiffinBox</title> · <h1>TiffinBox</h1> · 21 lines, 941 bytes - not shown but these:
    name = "Om"
    mealsPerDay = "two" · its message: Failed to convert value of type java.lang.String to required type int; For input string: "two"
    pricePerMeal = "120"
    mealType = "VEG"
    messages on the page: 1
a name that is taken:
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data 'name=Lata&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:19510/customers
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Add a customer · TiffinBox</title> · <h1>TiffinBox</h1> · 21 lines, 873 bytes - not shown but these:
    name = "Lata" · its message: a customer named Lata already exists
    mealsPerDay = "2"
    pricePerMeal = "120"
    mealType = "VEG"
    messages on the page: 1
the JSON POST beside it - the request-body lesson's line, curl's Content-Type printed:
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19510/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
the request-body lesson's POST without its Content-Type - curl's --data names a form's type:
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19510/customers
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Add a customer · TiffinBox</title> · <h1>TiffinBox</h1> · 21 lines, 1022 bytes - not shown but these:
    name = ""
    mealsPerDay = "" · its message: Failed to convert value of type null to required type int; Failed to convert from type [null] to type [@jakarta.validation.constraints.Min @jakarta.validation.constraints.Max int] for value [null]
    pricePerMeal = ""
    mealType = ""
    messages on the page: 1
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19510/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · 24 lines, 1074 bytes - not shown but these:
    the counts: Customers: 6 · This month: 38100 · Paused days: 5
    the table, first column: Asha Lata Meera Priya Ravi Sunil
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19510 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19510 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 5 · errors — what nobody handles; a template that is wrong; C, error/404.html

A name of 61 letters (the column holds 60) → **500**: for HTML TiffinBox's own error page (`<title>Something broke · TiffinBox</title>`, `The server failed on /customers: status 500.`), for curl Boot's JSON body; 1 ERROR, Tomcat's, H2's 22001 in it. The copy whose dashboard template says `view.custmers` (the exercise's, in its classes folder; the folder line): `/dashboard` for HTML → 500, the error page, **2 ERROR** — Thymeleaf's `TemplateEngine` (the template, the expression, its line) then Tomcat's (`EL1008E` under it); curl's JSON `/dashboard` → 200; the form → 200. **C (labelled):** a copy with `templates/error/404.html` — `/nowhere` for HTML, `/nowhere` and Nobody with Chrome's Accept → the 404 problem details; the 404 page never rendered.

`.r-errors.out` · md5 `a336d7be70d7526c4c76318e033ef369` · 3 of 3

```
a refusal nobody handles - a name of 61 letters, the customer table's column holds 60 - after/, the README's run line, port 19510:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19510
  listens on: 127.0.0.1:19510 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19510/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html' --data 'name=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:19510/customers
  curl's line: 500 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 1
  HTTP/1.1 500 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 2
  the page: <title>Something broke · TiffinBox</title> · <h1>TiffinBox could not answer</h1> · 12 lines, 298 bytes - not shown but these:
    The server failed on /customers: status 500.
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLDataException: Value too long for column "NAME CHARACTER VARYING(60)": "'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' (61)"; SQL statement:
      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [22001-250]] with root cause
      its stack frames: over 40, its other lines: 4 - none shown
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data 'name=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:19510/customers
  curl's line: 500 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 1
  HTTP/1.1 500 · Content-Type: application/json · Transfer-Encoding: chunked · headers not shown: 2
  body: {"timestamp":"…","status":500,"error":"Internal Server Error","path":"/customers"}
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLDataException: Value too long for column "NAME CHARACTER VARYING(60)": "'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' (61)"; SQL statement:
      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [22001-250]] with root cause
      its stack frames: over 40, its other lines: 4 - none shown
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 2
$ harness/shutdown.sh 19510 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19510 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
a template that is wrong - after/'s build copied to .harness/typo, its dashboard template replaced by the exercise's in its classes folder; the folder line, port 19512:
$ cp harness/exercise/dashboard.html .harness/typo/tiffinbox-web/target/classes/templates/dashboard.html
  exit 0
$ diff after/tiffinbox-web/src/main/resources/templates/dashboard.html .harness/typo/tiffinbox-web/target/classes/templates/dashboard.html
  10c10
  <     <tr th:each="c : ${view.customers}">…
  ---
  >     <tr th:each="c : ${view.custmers}">…
$ cd .harness/typo && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/classes:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19512
  listens on: 127.0.0.1:19512 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19512/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19512/dashboard
  curl's line: 500 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 2
  HTTP/1.1 500 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 2
  the page: <title>Something broke · TiffinBox</title> · <h1>TiffinBox could not answer</h1> · 12 lines, 298 bytes - not shown but these:
    The server failed on /dashboard: status 500.
    ERROR org.thymeleaf.TemplateEngine: [THYMELEAF][tomcat-handler-<n>] Exception processing template "dashboard": Exception evaluating SpringEL expression: "view.custmers" (template: "dashboard" - line 10, col 9)
      org.thymeleaf.exceptions.TemplateProcessingException: Exception evaluating SpringEL expression: "view.custmers" (template: "dashboard" - line 10, col 9)
      its stack frames: over 40, its other lines: 4 - none shown
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.thymeleaf.exceptions.TemplateProcessingException: Exception evaluating SpringEL expression: "view.custmers" (template: "dashboard" - line 10, col 9)] with root cause
      org.springframework.expression.spel.SpelEvaluationException: EL1008E: Property or field 'custmers' cannot be found on object of type 'com.tiffinbox.Dashboard$View' - maybe not public or not valid?
      its stack frames: over 40, its other lines: 2 - none shown
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19512/dashboard
  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]} 200 · Content-Type: [application/json] · WARN lines it added: 0 · ERROR lines: 0
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19512/customers/new
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Add a customer · TiffinBox</title> · <h1>TiffinBox</h1> · 21 lines, 806 bytes - not shown
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 2
$ harness/shutdown.sh 19512 .harness/typo/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19512 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - templates/error/404.html: after/'s build copied to .harness/c404, the harness's 404 page put in its classes folder; the folder line, port 19512:
$ cp harness/c404/404.html .harness/c404/tiffinbox-web/target/classes/templates/error/404.html
  exit 0
  the copy's error templates: 404.html 5xx.html
$ cd .harness/c404 && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/classes:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19512
  listens on: 127.0.0.1:19512 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19512/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19512/nowhere
  curl's line: 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 404 · Content-Type: application/problem+json · Transfer-Encoding: chunked · headers not shown: 1
  body: {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"}
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' http://127.0.0.1:19512/nowhere
  curl's line: 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 404 · Content-Type: application/problem+json · Transfer-Encoding: chunked · headers not shown: 1
  body: {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"}
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' http://127.0.0.1:19512/customers/Nobody
  curl's line: 404 · Content-Type: [application/problem+json] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 404 · Content-Type: application/problem+json · Transfer-Encoding: chunked · headers not shown: 1
  body: {"detail":"no customer named Nobody","instance":"/customers/Nobody","status":404,"title":"Customer not found","name":"Nobody"}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19512 .harness/c404/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19512 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 6 · devtools — DevTools' keys; A/B/A′ spring.thymeleaf.cache; C spring.template.provider.cache

Boot's metadata: `spring.thymeleaf.cache` default true; `spring.template.provider.cache` — 0 entries in the 61 libraries' metadata, named once in Boot's `TemplateAvailabilityProviders.class`. DevTools on the class path (Live Reload off, 35729: 0): one property source, **10 keys** — `spring.thymeleaf.cache = false`, `spring.template.provider.cache = false` among them. **A** (the folder line): the dashboard's footer, the edit (`sed`), the dashboard's footer **unchanged**, the form's (first asked) **edited**; **B** (`--spring.thymeleaf.cache=false`): the edit on the dashboard's next request; **A′** = A, its `$` line shown, `yes`. **C (labelled):** the error page taken out of the classes folder before the start and put back while running — Boot's default: the Whitelabel page both times; `--spring.template.provider.cache=false`: the Whitelabel page, then TiffinBox's.

`.r-devtools.out` · md5 `cdd84a4a529abacdbb04c2817c27d7ed` · 3 of 3

```
the keys - Boot's metadata for Thymeleaf's cache (spring-boot-thymeleaf-4.1.1.jar), and for Boot's template-availability cache in every library's metadata; the name in Boot's own class:
  spring.thymeleaf.cache - type Boolean · default true · Whether to enable template caching.
  spring.template.provider.cache - entries in the 61 libraries' metadata: 0
$ unzip -p .harness/after/tiffinbox-web/target/extracted/lib/spring-boot-autoconfigure-4.1.1.jar org/springframework/boot/autoconfigure/template/TemplateAvailabilityProviders.class | grep -ac 'spring.template.provider.cache'
  1
DevTools - after/'s extracted jar with DevTools' jar (from $M2) and the harness on its class path, Live Reload off, the harness's Keys joined, port 19513:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19513 --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Keys
  listens on: 127.0.0.1:19513 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19513/actuator/health/readiness
  {"status":"UP"} 200
  the harness's lines it printed, in order: 18
     1 Keys the JVM's locale: en_US
     2 Keys the property source devtools: 10 keys
     3 Keys   server.servlet.jsp.init-parameters.development = true
     4 Keys   server.servlet.session.persistent = true
     5 Keys   spring.mvc.log-resolved-exception = true
     6 Keys   spring.template.provider.cache = false
     7 Keys   spring.thymeleaf.cache = false
     8 Keys   spring.web.error.include-binding-errors = always
     9 Keys   spring.web.error.include-message = always
    10 Keys   spring.web.error.include-stacktrace = always
    11 Keys   spring.web.resources.cache.period = 0
    12 Keys   spring.web.resources.chain.cache = false
    13 Keys property sources whose name says devtools: 1
    14 Keys the environment's spring.thymeleaf.cache: false
    15 Keys the environment's spring.template.provider.cache: false
    16 Keys the environment's spring.web.resources.cache.period: 0
    17 Keys the environment's spring.web.resources.chain.cache: false
    18 Keys the environment's server.servlet.session.persistent: true
  listening on 35729 (Live Reload) now: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19513 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 1 · listening on 19513 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
a folder class path - after/'s build copied to .harness/fold, the web module's classes folder in place of its jar (this unit's folder line):
A - Boot's default, port 19512:
$ cd .harness/fold && cp tiffinbox-web/src/main/resources/templates/fragments.html tiffinbox-web/target/classes/templates/fragments.html
  exit 0
$ cd .harness/fold && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/classes:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19512
  listens on: 127.0.0.1:19512 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19512/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19512/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · 22 lines, 926 bytes - not shown but these:
    | <footer><p>TiffinBox · rendered on the server</p></footer>
$ cd .harness/fold && sed -i '' 's/rendered on the server/edited while it runs/' tiffinbox-web/target/classes/templates/fragments.html
  exit 0
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19512/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · 22 lines, 926 bytes - not shown but these:
    | <footer><p>TiffinBox · rendered on the server</p></footer>
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19512/customers/new
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Add a customer · TiffinBox</title> · <h1>TiffinBox</h1> · 21 lines, 804 bytes - not shown but these:
    | <footer><p>TiffinBox · edited while it runs</p></footer>
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19512 .harness/fold/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19512 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - Thymeleaf's cache off for this run (this unit's line), port 19512:
$ cd .harness/fold && cp tiffinbox-web/src/main/resources/templates/fragments.html tiffinbox-web/target/classes/templates/fragments.html
  exit 0
$ cd .harness/fold && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/classes:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19512 --spring.thymeleaf.cache=false
  listens on: 127.0.0.1:19512 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19512/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19512/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · 22 lines, 926 bytes - not shown but these:
    | <footer><p>TiffinBox · rendered on the server</p></footer>
$ cd .harness/fold && sed -i '' 's/rendered on the server/edited while it runs/' tiffinbox-web/target/classes/templates/fragments.html
  exit 0
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19512/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · 22 lines, 924 bytes - not shown but these:
    | <footer><p>TiffinBox · edited while it runs</p></footer>
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19512/customers/new
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Add a customer · TiffinBox</title> · <h1>TiffinBox</h1> · 21 lines, 804 bytes - not shown but these:
    | <footer><p>TiffinBox · edited while it runs</p></footer>
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19512 .harness/fold/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19512 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, a fresh JVM, port 19512:
$ cd .harness/fold && cp tiffinbox-web/src/main/resources/templates/fragments.html tiffinbox-web/target/classes/templates/fragments.html
  exit 0
$ cd .harness/fold && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/classes:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19512
  listens on: 127.0.0.1:19512 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19512/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19512/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · 22 lines, 926 bytes - not shown but these:
    | <footer><p>TiffinBox · rendered on the server</p></footer>
$ cd .harness/fold && sed -i '' 's/rendered on the server/edited while it runs/' tiffinbox-web/target/classes/templates/fragments.html
  exit 0
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19512/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · 22 lines, 926 bytes - not shown but these:
    | <footer><p>TiffinBox · rendered on the server</p></footer>
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19512/customers/new
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Add a customer · TiffinBox</title> · <h1>TiffinBox</h1> · 21 lines, 804 bytes - not shown but these:
    | <footer><p>TiffinBox · edited while it runs</p></footer>
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19512 .harness/fold/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19512 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
C (labelled) - Boot's template-availability cache: the error page taken out of the folder before the start, put back while it runs - Boot's default, port 19512:
$ cd .harness/fold && rm tiffinbox-web/target/classes/templates/error/5xx.html
  exit 0
$ cd .harness/fold && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/classes:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19512
  listens on: 127.0.0.1:19512 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19512/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html' --data 'name=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:19512/customers
  curl's line: 500 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 1
  HTTP/1.1 500 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Content-Length: 288 · headers not shown: 2
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLDataException: Value too long for column "NAME CHARACTER VARYING(60)": "'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' (61)"; SQL statement:
      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [22001-250]] with root cause
      its stack frames: over 40, its other lines: 4 - none shown
$ cd .harness/fold && cp tiffinbox-web/src/main/resources/templates/error/5xx.html tiffinbox-web/target/classes/templates/error/5xx.html
  exit 0
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html' --data 'name=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:19512/customers
  curl's line: 500 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 1
  HTTP/1.1 500 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Content-Length: 288 · headers not shown: 2
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLDataException: Value too long for column "NAME CHARACTER VARYING(60)": "'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' (61)"; SQL statement:
      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [22001-250]] with root cause
      its stack frames: over 40, its other lines: 4 - none shown
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 2
$ harness/shutdown.sh 19512 .harness/fold/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19512 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C - the same, that cache off for this run (this unit's line), port 19512:
$ cd .harness/fold && rm tiffinbox-web/target/classes/templates/error/5xx.html
  exit 0
$ cd .harness/fold && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/classes:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19512 --spring.template.provider.cache=false
  listens on: 127.0.0.1:19512 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19512/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html' --data 'name=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:19512/customers
  curl's line: 500 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 1
  HTTP/1.1 500 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Content-Length: 288 · headers not shown: 2
  the Whitelabel page (Boot's) - its <h1>: Whitelabel Error Page · its error line: There was an unexpected error (type=Internal Server Error, status=500). · its created date: masked · its paragraphs: 1, not shown
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLDataException: Value too long for column "NAME CHARACTER VARYING(60)": "'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' (61)"; SQL statement:
      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [22001-250]] with root cause
      its stack frames: over 40, its other lines: 4 - none shown
$ cd .harness/fold && cp tiffinbox-web/src/main/resources/templates/error/5xx.html tiffinbox-web/target/classes/templates/error/5xx.html
  exit 0
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html' --data 'name=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:19512/customers
  curl's line: 500 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 1
  HTTP/1.1 500 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 2
  the page: <title>Something broke · TiffinBox</title> · <h1>TiffinBox could not answer</h1> · 12 lines, 298 bytes - not shown but these:
    The server failed on /customers: status 500.
    ERROR o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org.h2.jdbc.JdbcSQLDataException: Value too long for column "NAME CHARACTER VARYING(60)": "'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' (61)"; SQL statement:
      INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES (?, ?, ?, ?) [22001-250]] with root cause
      its stack frames: over 40, its other lines: 4 - none shown
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 2
$ harness/shutdown.sh 19512 .harness/fold/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19512 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
$ cd .harness/fold && cp tiffinbox-web/src/main/resources/templates/fragments.html tiffinbox-web/target/classes/templates/fragments.html
  exit 0
```

## 7 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s seven lines, then `SOLUTION.md`'s four, in one `env -i` `/bin/bash` shell started in this folder: as shipped `the dashboard: 500 · text/html;charset=UTF-8 · Something broke · TiffinBox`, 2 ERROR lines (Thymeleaf's names `view.custmers`); the solution `the dashboard: 200 · text/html;charset=UTF-8 · Dashboard · TiffinBox`, 0; the shell in this folder after each; the copy's template = after/'s, byte for byte.

`.r-exercise.out` · md5 `3056eabd5017a806d02b291728decab6` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 7 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
  $ cp harness/exercise/dashboard.html .harness/mine/after/tiffinbox-web/src/main/resources/templates/dashboard.html
  $ mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 16 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19518 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19518/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o ../page.html -w '%{http_code} · %{content_type}' -H 'Accept: text/html' http://127.0.0.1:19518/dashboard); ../../../harness/shutdown.sh 19518 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the dashboard: $s · $(sed -n 's/.*<title>\(.*\)<\/title>.*/\1/p' ../page.html)")
  exit 0 · what they printed:
    the dashboard: 500 · text/html;charset=UTF-8 · Something broke · TiffinBox
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 2 · listening on 19518 now: 0
  its ERROR lines, from their logger on, the request thread's number masked, each cut at 160 characters:
    org.thymeleaf.TemplateEngine: [THYMELEAF][tomcat-handler-<n>] Exception processing template "dashboard": Exception evaluating SpringEL expression: "view.custmers"
    o.a.c.c.C.[.[.[/].[dispatcherServlet]: Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed: org
the solution's 4 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ f=.harness/mine/after/tiffinbox-web/src/main/resources/templates/dashboard.html && sed 's/view\.custmers/view.customers/' "$f" > "$f.new" && mv "$f.new" "$f"
  $ M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19518 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19518/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && s=$(curl -s -o ../page.html -w '%{http_code} · %{content_type}' -H 'Accept: text/html' http://127.0.0.1:19518/dashboard); ../../../harness/shutdown.sh 19518 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the dashboard: $s · $(sed -n 's/.*<title>\(.*\)<\/title>.*/\1/p' ../page.html)")
  exit 0 · what they printed:
    the dashboard: 200 · text/html;charset=UTF-8 · Dashboard · TiffinBox
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19518 now: 0
  the copy's template against after/'s: the same, byte for byte
```

## 8 · browser — a real browser, two witnesses for every claim

TiffinBox on its class path with `Dump`; headless Chrome, its profile made fresh (`yes`), its DevTools port on 127.0.0.1. **Visit 1**, the dashboard's address typed: the page Chrome shows (Meera … Sunil); Chrome's own record — `GET /dashboard` 200, its 14 headers as sent, **`Accept:` the string the curl captures send**, `Accept-Language: en-US,en;q=0.9`, `Sec-Fetch-Site: none`; the server's record agrees (15 request lines, `200`, `Content-Language: en-US`, 926 bytes). **Visit 2**, the form filled and sent: three documents — `GET /customers/new` 200, `POST /customers` → **302** `Location: …/dashboard`, the form's body as Chrome sent it, `Content-Type: application/x-www-form-urlencoded`, `Origin: http://127.0.0.1:19517`, `Sec-Fetch-Site: same-origin`; then `GET /dashboard` 200 — Kiran in the table; `Dump` saw the same three. **Visit 3**, four rules broken: the form again, four messages in English. Chrome exit 0, its profile removed; its NetLog: every address 127.0.0.1. 0 WARN, 0 ERROR.

`.r-browser.out` · md5 `e5813b3124b0138e7f856156221ee50b` · 3 of 3

```
TiffinBox - after/ on its class path (the README's line), Dump joined (the server's record of every page request, whole), port 19517:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19517 --spring.main.sources=probe.web.Dump
  listens on: 127.0.0.1:19517 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19517/actuator/health/readiness
  {"status":"UP"} 200
Chrome - headless, a profile of its own, sealed to 127.0.0.1 (its proxy a dead address, every name but 127.0.0.1 unresolvable), its DevTools protocol on 127.0.0.1:19519:
$ "$CHROME" --headless=new --user-data-dir="$PWD/.harness/chrome" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 --host-resolver-rules='MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' --remote-debugging-address=127.0.0.1 --remote-debugging-port=19519 --log-net-log="$PWD/.harness/netlog.json" about:blank
  its profile, .harness/chrome, made fresh for this run (it did not exist before this line): yes
  Chrome's DevTools port: 127.0.0.1:19519 · loopback only: yes
visit 1 - the dashboard's address, typed:
$ node harness/cdp.mjs 19519 open http://127.0.0.1:19517/dashboard .harness/ev.json
  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard · its table, first column: Meera Priya Ravi Sunil
$ python3 harness/net.py .harness/ev.json 19517
  Chrome's own record (its DevTools protocol) - the documents the tab asked TiffinBox for: 1
    GET /dashboard - the answer Chrome got: 200 text/html
      as Chrome sent it, its 14 headers:
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Connection: keep-alive
        Host: 127.0.0.1:19517
        Sec-Fetch-Dest: document
        Sec-Fetch-Mode: navigate
        Sec-Fetch-Site: none
        Sec-Fetch-User: ?1
        Upgrade-Insecure-Requests: 1
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
        sec-ch-ua: (its brands and their versions: masked)
        sec-ch-ua-mobile: ?0
        sec-ch-ua-platform: (<platform masked>)
  the page's other requests - its stylesheet, the site's icon - not listed: whether Chrome asks for them again is its cache's call
  the server's record:
    the harness's lines it printed, in order: 23
       1 Dump            > GET /dashboard
       2 Dump            >   Host: 127.0.0.1:19517
       3 Dump            >   Connection: keep-alive
       4 Dump            >   sec-ch-ua: (its brands and their versions: masked)
       5 Dump            >   sec-ch-ua-mobile: ?0
       6 Dump            >   sec-ch-ua-platform: (<platform masked>)
       7 Dump            >   Upgrade-Insecure-Requests: 1
       8 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
       9 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
      10 Dump            >   Sec-Fetch-Site: none
      11 Dump            >   Sec-Fetch-Mode: navigate
      12 Dump            >   Sec-Fetch-User: ?1
      13 Dump            >   Sec-Fetch-Dest: document
      14 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      15 Dump            >   Accept-Language: en-US,en;q=0.9
      16 Dump            < 200 GET /dashboard
      17 Dump            <   Content-Type: text/html;charset=UTF-8
      18 Dump            <   Content-Language: en-US
      19 Dump            <   Transfer-Encoding: chunked
      20 Dump            <   Date: (the time: not printed)
      21 Dump            <   Keep-Alive: timeout=60
      22 Dump            <   Connection: keep-alive
      23 Dump            <   body: 926 bytes
    WARN lines they added: 0 · ERROR lines: 0
visit 2 - the form, filled in and sent:
$ node harness/cdp.mjs 19519 form http://127.0.0.1:19517/customers/new .harness/ev.json 'name=Kiran&mealsPerDay=1&pricePerMeal=130&mealType=VEGAN'
  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard · its table, first column: Kiran Meera Priya Ravi Sunil
$ python3 harness/net.py .harness/ev.json 19517
  Chrome's own record (its DevTools protocol) - the documents the tab asked TiffinBox for: 3
    GET /customers/new - the answer Chrome got: 200 text/html
      as Chrome sent it, its 14 headers:
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Connection: keep-alive
        Host: 127.0.0.1:19517
        Sec-Fetch-Dest: document
        Sec-Fetch-Mode: navigate
        Sec-Fetch-Site: none
        Sec-Fetch-User: ?1
        Upgrade-Insecure-Requests: 1
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
        sec-ch-ua: (its brands and their versions: masked)
        sec-ch-ua-mobile: ?0
        sec-ch-ua-platform: (<platform masked>)
    POST /customers - the answer Chrome got: 302 · Location: http://127.0.0.1:19517/dashboard
      the form's body, as Chrome sent it: name=Kiran&mealsPerDay=1&pricePerMeal=130&mealType=VEGAN
      as Chrome sent it, its 18 headers:
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Cache-Control: max-age=0
        Connection: keep-alive
        Content-Length: 56
        Content-Type: application/x-www-form-urlencoded
        Host: 127.0.0.1:19517
        Origin: http://127.0.0.1:19517
        Referer: http://127.0.0.1:19517/customers/new
        Sec-Fetch-Dest: document
        Sec-Fetch-Mode: navigate
        Sec-Fetch-Site: same-origin
        Upgrade-Insecure-Requests: 1
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
        sec-ch-ua: (its brands and their versions: masked)
        sec-ch-ua-mobile: ?0
        sec-ch-ua-platform: (<platform masked>)
    GET /dashboard - the answer Chrome got: 200 text/html
      as Chrome sent it, its 15 headers:
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Cache-Control: max-age=0
        Connection: keep-alive
        Host: 127.0.0.1:19517
        Referer: http://127.0.0.1:19517/customers/new
        Sec-Fetch-Dest: document
        Sec-Fetch-Mode: navigate
        Sec-Fetch-Site: same-origin
        Upgrade-Insecure-Requests: 1
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
        sec-ch-ua: (its brands and their versions: masked)
        sec-ch-ua-mobile: ?0
        sec-ch-ua-platform: (<platform masked>)
  the page's other requests - its stylesheet, the site's icon - not listed: whether Chrome asks for them again is its cache's call
  the server's record:
    the harness's lines it printed, in order: 69
       1 Dump            > GET /customers/new
       2 Dump            >   Host: 127.0.0.1:19517
       3 Dump            >   Connection: keep-alive
       4 Dump            >   sec-ch-ua: (its brands and their versions: masked)
       5 Dump            >   sec-ch-ua-mobile: ?0
       6 Dump            >   sec-ch-ua-platform: (<platform masked>)
       7 Dump            >   Upgrade-Insecure-Requests: 1
       8 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
       9 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
      10 Dump            >   Sec-Fetch-Site: none
      11 Dump            >   Sec-Fetch-Mode: navigate
      12 Dump            >   Sec-Fetch-User: ?1
      13 Dump            >   Sec-Fetch-Dest: document
      14 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      15 Dump            >   Accept-Language: en-US,en;q=0.9
      16 Dump            < 200 GET /customers/new
      17 Dump            <   Content-Type: text/html;charset=UTF-8
      18 Dump            <   Content-Language: en-US
      19 Dump            <   Transfer-Encoding: chunked
      20 Dump            <   Date: (the time: not printed)
      21 Dump            <   Keep-Alive: timeout=60
      22 Dump            <   Connection: keep-alive
      23 Dump            <   body: 806 bytes
      24 Dump            > POST /customers
      25 Dump            >   Host: 127.0.0.1:19517
      26 Dump            >   Connection: keep-alive
      27 Dump            >   Content-Length: 56
      28 Dump            >   Cache-Control: max-age=0
      29 Dump            >   sec-ch-ua: (its brands and their versions: masked)
      30 Dump            >   sec-ch-ua-mobile: ?0
      31 Dump            >   sec-ch-ua-platform: (<platform masked>)
      32 Dump            >   Upgrade-Insecure-Requests: 1
      33 Dump            >   Content-Type: application/x-www-form-urlencoded
      34 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      35 Dump            >   Origin: http://127.0.0.1:19517
      36 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
      37 Dump            >   Sec-Fetch-Site: same-origin
      38 Dump            >   Sec-Fetch-Mode: navigate
      39 Dump            >   Sec-Fetch-Dest: document
      40 Dump            >   Referer: http://127.0.0.1:19517/customers/new
      41 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      42 Dump            >   Accept-Language: en-US,en;q=0.9
      43 Dump            < 302 POST /customers
      44 Dump            <   Location: http://127.0.0.1:19517/dashboard
      45 Dump            <   body: 0 bytes
      46 Dump            > GET /dashboard
      47 Dump            >   Host: 127.0.0.1:19517
      48 Dump            >   Connection: keep-alive
      49 Dump            >   Cache-Control: max-age=0
      50 Dump            >   Upgrade-Insecure-Requests: 1
      51 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      52 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
      53 Dump            >   Sec-Fetch-Site: same-origin
      54 Dump            >   Sec-Fetch-Mode: navigate
      55 Dump            >   Sec-Fetch-Dest: document
      56 Dump            >   sec-ch-ua: (its brands and their versions: masked)
      57 Dump            >   sec-ch-ua-mobile: ?0
      58 Dump            >   sec-ch-ua-platform: (<platform masked>)
      59 Dump            >   Referer: http://127.0.0.1:19517/customers/new
      60 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      61 Dump            >   Accept-Language: en-US,en;q=0.9
      62 Dump            < 200 GET /dashboard
      63 Dump            <   Content-Type: text/html;charset=UTF-8
      64 Dump            <   Content-Language: en-US
      65 Dump            <   Transfer-Encoding: chunked
      66 Dump            <   Date: (the time: not printed)
      67 Dump            <   Keep-Alive: timeout=60
      68 Dump            <   Connection: keep-alive
      69 Dump            <   body: 1003 bytes
    WARN lines they added: 0 · ERROR lines: 0
visit 3 - the form sent breaking four rules:
$ node harness/cdp.mjs 19519 form http://127.0.0.1:19517/customers/new .harness/ev.json 'name=&mealsPerDay=9&pricePerMeal=0&mealType=LUNCH'
  the page Chrome shows: Add a customer · TiffinBox · its address: /customers · its messages: must not be blank | must be less than or equal to 3 | must be greater than or equal to 1 | must match "VEG|NON_VEG|VEGAN"
$ python3 harness/net.py .harness/ev.json 19517
  Chrome's own record (its DevTools protocol) - the documents the tab asked TiffinBox for: 2
    GET /customers/new - the answer Chrome got: 200 text/html
      as Chrome sent it, its 14 headers:
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Connection: keep-alive
        Host: 127.0.0.1:19517
        Sec-Fetch-Dest: document
        Sec-Fetch-Mode: navigate
        Sec-Fetch-Site: none
        Sec-Fetch-User: ?1
        Upgrade-Insecure-Requests: 1
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
        sec-ch-ua: (its brands and their versions: masked)
        sec-ch-ua-mobile: ?0
        sec-ch-ua-platform: (<platform masked>)
    POST /customers - the answer Chrome got: 200 text/html
      the form's body, as Chrome sent it: name=&mealsPerDay=9&pricePerMeal=0&mealType=LUNCH
      as Chrome sent it, its 18 headers:
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        Accept-Encoding: gzip, deflate, br, zstd
        Accept-Language: en-US,en;q=0.9
        Cache-Control: max-age=0
        Connection: keep-alive
        Content-Length: 49
        Content-Type: application/x-www-form-urlencoded
        Host: 127.0.0.1:19517
        Origin: http://127.0.0.1:19517
        Referer: http://127.0.0.1:19517/customers/new
        Sec-Fetch-Dest: document
        Sec-Fetch-Mode: navigate
        Sec-Fetch-Site: same-origin
        Upgrade-Insecure-Requests: 1
        User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
        sec-ch-ua: (its brands and their versions: masked)
        sec-ch-ua-mobile: ?0
        sec-ch-ua-platform: (<platform masked>)
  the page's other requests - its stylesheet, the site's icon - not listed: whether Chrome asks for them again is its cache's call
  the server's record:
    the harness's lines it printed, in order: 50
       1 Dump            > GET /customers/new
       2 Dump            >   Host: 127.0.0.1:19517
       3 Dump            >   Connection: keep-alive
       4 Dump            >   sec-ch-ua: (its brands and their versions: masked)
       5 Dump            >   sec-ch-ua-mobile: ?0
       6 Dump            >   sec-ch-ua-platform: (<platform masked>)
       7 Dump            >   Upgrade-Insecure-Requests: 1
       8 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
       9 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
      10 Dump            >   Sec-Fetch-Site: none
      11 Dump            >   Sec-Fetch-Mode: navigate
      12 Dump            >   Sec-Fetch-User: ?1
      13 Dump            >   Sec-Fetch-Dest: document
      14 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      15 Dump            >   Accept-Language: en-US,en;q=0.9
      16 Dump            < 200 GET /customers/new
      17 Dump            <   Content-Type: text/html;charset=UTF-8
      18 Dump            <   Content-Language: en-US
      19 Dump            <   Transfer-Encoding: chunked
      20 Dump            <   Date: (the time: not printed)
      21 Dump            <   Keep-Alive: timeout=60
      22 Dump            <   Connection: keep-alive
      23 Dump            <   body: 806 bytes
      24 Dump            > POST /customers
      25 Dump            >   Host: 127.0.0.1:19517
      26 Dump            >   Connection: keep-alive
      27 Dump            >   Content-Length: 49
      28 Dump            >   Cache-Control: max-age=0
      29 Dump            >   sec-ch-ua: (its brands and their versions: masked)
      30 Dump            >   sec-ch-ua-mobile: ?0
      31 Dump            >   sec-ch-ua-platform: (<platform masked>)
      32 Dump            >   Upgrade-Insecure-Requests: 1
      33 Dump            >   Content-Type: application/x-www-form-urlencoded
      34 Dump            >   User-Agent: Mozilla/5.0 (<platform masked>) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      35 Dump            >   Origin: http://127.0.0.1:19517
      36 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
      37 Dump            >   Sec-Fetch-Site: same-origin
      38 Dump            >   Sec-Fetch-Mode: navigate
      39 Dump            >   Sec-Fetch-Dest: document
      40 Dump            >   Referer: http://127.0.0.1:19517/customers/new
      41 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      42 Dump            >   Accept-Language: en-US,en;q=0.9
      43 Dump            < 200 POST /customers
      44 Dump            <   Content-Type: text/html;charset=UTF-8
      45 Dump            <   Content-Language: en-US
      46 Dump            <   Transfer-Encoding: chunked
      47 Dump            <   Date: (the time: not printed)
      48 Dump            <   Keep-Alive: timeout=60
      49 Dump            <   Connection: keep-alive
      50 Dump            <   body: 1036 bytes
    WARN lines they added: 0 · ERROR lines: 0
$ node harness/cdp.mjs 19519 close
  Chrome exit 0 · listening on 19519 now: 0 · its profile removed
$ python3 harness/netlog.py .harness/netlog.json 19517
  Chrome's NetLog - every address it connected to or tried, its own background requests included: 127.0.0.1 only: yes · ports 19517 among them: yes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19517 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19517 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 9 · forms — every form serves every page (⚑7, R.103, R.127)

One native build of after/ (8 of 8 stages, offline, Mach-O, 0 tokens in its bytes; its seconds to the terminal only). Spring's AOT metadata, the previous tree's against after/'s: **670 → 687** reflection entries — `Dashboard$View` with `allPublicMethods` and `Customer`'s public methods (the hint), `DashboardPage`, Thymeleaf's engine, resolver, view resolver, properties and configuration classes — and `templates/**`, `static/**` as resources. Then the jar, the AOT jar, the binary and the image (published on 127.0.0.1:19515 alone): the seven `466c20ed…` 4 of 4; on a second start of each, the dashboard (Meera … Sunil), the form, four messages, Lata's 302 on its own port, the dashboard with Lata, **TiffinBox's error page for the 61-letter name — the binary's too (RE-MEASURE 7)**, and the JSON 201. The binary's pages say `Content-Language: en`. The image: no pull, 0 tokens in its layers, its log 1 ERROR (the 500's).

`.r-forms.out` · md5 `b339f789b47d58abffe4e54a165dfd6b` · 3 of 3

```
the native build - after/ copied to .harness/nat with a config tree; the README's two Maven lines, offline; $GRAALVM_HOME names the GraalVM:
$ cd .harness/nat && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean install
  built .harness/nat (both modules, into $M2) · offline: yes · exit 0
$ cd .harness/nat && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -pl tiffinbox-web native:compile-no-fork
  its lines, in order (the rest - 203 lines - not shown):
    --- native:1.1.8:compile-no-fork (default-cli) @ tiffinbox-web ---
    Found GraalVM installation from GRAALVM_HOME variable.
    Java version: 25.0.4.1+1, vendor version: GraalVM CE 25.3.4.1+1.1
    Warning: Using a deprecated option --no-fallback from 'META-INF/native-image/com.tiffinbox/tiffinbox-web/native-image.properties' in '…'. No effect, no replacement available
    Warning: Using a deprecated option --enable-http from 'META-INF/native-image/org.springframework/spring-web/native-image.properties' in '…'. Use reachability metadata instead. Add this entry to META-INF/native-image/reachability-metadata.json:
    Warning: Using a deprecated option --enable-https from 'META-INF/native-image/org.springframework/spring-web/native-image.properties' in '…'. Use reachability metadata instead. Add this entry to META-INF/native-image/reachability-metadata.json:
    Warning: Option 'FallbackThreshold' is deprecated and might be removed in a future release: It no longer has any effect, and no replacement is available. Please refer to the GraalVM release notes.
    Warning: Option 'DynamicProxyConfigurationResources' is deprecated and might be removed in a future release: This can be caused by a proxy-config.json file in your META-INF directory. Consider including proxy configuration in the reflection section of reachability-metadata.json instead.. Please refer to the GraalVM release notes.
    [1/8] Initializing...
    [2/8] Performing analysis...
    [3/8] Building universe...
    [4/8] Parsing methods...
    [5/8] Inlining methods...
    [6/8] Compiling methods...
    [7/8] Laying out methods...
    [8/8] Creating image...
    The build process encountered 5 warnings.
    BUILD SUCCESS
  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes
  file: Mach-O 64-bit executable · the demo token in its bytes: 0
what Spring's AOT step registered - the previous tree built with the README's native-profile line too (.harness/natb), then its metadata against after/'s:
$ cd .harness/natb && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean package
  built the previous tree, the profile native · offline: yes · exit 0
  Spring's generated metadata (spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json) - the previous tree's against after/'s: reflection entries 670 -> 687 · types only the previous tree registers: none · only after/: 17 · entries that differ: 1
    only after/: com.tiffinbox.Dashboard$View - allPublicMethods · 0 methods
    only after/: com.tiffinbox.web.DashboardPage - 3 methods
    only after/: org.springframework.boot.thymeleaf.autoconfigure.TemplateEngineConfigurations$DefaultTemplateEngineConfiguration - 0 methods
    only after/: org.springframework.boot.thymeleaf.autoconfigure.ThymeleafAutoConfiguration - 0 methods
    only after/: org.springframework.boot.thymeleaf.autoconfigure.ThymeleafAutoConfiguration$DefaultTemplateResolverConfiguration - 0 methods
    only after/: org.springframework.boot.thymeleaf.autoconfigure.ThymeleafAutoConfiguration$ThymeleafWebMvcConfiguration - 0 methods
    only after/: org.springframework.boot.thymeleaf.autoconfigure.ThymeleafAutoConfiguration$ThymeleafWebMvcConfiguration$ThymeleafViewResolverConfiguration - 0 methods
    only after/: org.springframework.boot.thymeleaf.autoconfigure.ThymeleafProperties - fields · 27 methods
    only after/: org.springframework.boot.thymeleaf.autoconfigure.ThymeleafProperties$Reactive - fields · 9 methods
    only after/: org.springframework.boot.thymeleaf.autoconfigure.ThymeleafProperties$Servlet - fields · 5 methods
    only after/: org.springframework.boot.thymeleaf.autoconfigure.ThymeleafTemplateAvailabilityProvider - allDeclaredConstructors · 0 methods
    only after/: org.thymeleaf.ITemplateEngine - 0 methods
    only after/: org.thymeleaf.spring6.ISpringTemplateEngine - 0 methods
    only after/: org.thymeleaf.spring6.SpringTemplateEngine - allDeclaredFields · 0 methods
    only after/: org.thymeleaf.spring6.templateresolver.SpringResourceTemplateResolver - 0 methods
    only after/: org.thymeleaf.spring6.view.ThymeleafViewResolver - allDeclaredFields · 0 methods
    only after/: org.thymeleaf.templateresolver.ITemplateResolver - 0 methods
    only after/, the rest: 0 (not named)
    differs: com.tiffinbox.Customer - its methods only before: none · only after: none · its other keys only before: none · only after: allPublicMethods
  resource entries: 26 -> 30 · only after/: static static/** templates templates/**
1 the jar - .harness/after, the README's run line, port 19510:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19510
  listens on: 127.0.0.1:19510 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19510/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19510 (http) with context path '/'
$ $CURLSET 19510 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then every page, on a second start of the jar:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19510
  listens on: 127.0.0.1:19510 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19510/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19510/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · 22 lines, 926 bytes - not shown but these:
    the counts: Customers: 4 · This month: 24300 · Paused days: 5
    the table, first column: Meera Priya Ravi Sunil
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19510/customers/new
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Add a customer · TiffinBox</title> · <h1>TiffinBox</h1> · 21 lines, 806 bytes - not shown
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data 'name=&mealsPerDay=9&pricePerMeal=0&mealType=LUNCH' http://127.0.0.1:19510/customers
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Add a customer · TiffinBox</title> · <h1>TiffinBox</h1> · 21 lines, 1036 bytes - not shown but these:
    name = "" · its message: must not be blank
    mealsPerDay = "9" · its message: must be less than or equal to 3
    pricePerMeal = "0" · its message: must be greater than or equal to 1
    mealType = "LUNCH" · its message: must match "VEG|NON_VEG|VEGAN"
    messages on the page: 4
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data 'name=Lata&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:19510/customers
  curl's line: 302 · Content-Type: []
  HTTP/1.1 302 · Location: http://127.0.0.1:19510/dashboard · Content-Language: en-US · Content-Length: 0 · headers not shown: 1
  body: none (0 bytes)
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19510/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · 23 lines, 1000 bytes - not shown but these:
    the counts: Customers: 5 · This month: 31500 · Paused days: 5
    the table, first column: Lata Meera Priya Ravi Sunil
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html' --data 'name=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:19510/customers
  curl's line: 500 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 500 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 2
  the page: <title>Something broke · TiffinBox</title> · <h1>TiffinBox could not answer</h1> · 12 lines, 298 bytes - not shown but these:
    The server failed on /customers: status 500.
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19510/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Content-Type: [application/json]
$ harness/shutdown.sh 19510 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19510 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19514:
$ cd .harness/nat && java -Duser.language=en -Duser.country=US -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19514
  listens on: 127.0.0.1:19514 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19514/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19514 (http) with context path '/'
$ $CURLSET 19514 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then every page, on a second start of the AOT jar:
$ cd .harness/nat && java -Duser.language=en -Duser.country=US -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19514
  listens on: 127.0.0.1:19514 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19514/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19514/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · 22 lines, 926 bytes - not shown but these:
    the counts: Customers: 4 · This month: 24300 · Paused days: 5
    the table, first column: Meera Priya Ravi Sunil
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19514/customers/new
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Add a customer · TiffinBox</title> · <h1>TiffinBox</h1> · 21 lines, 806 bytes - not shown
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data 'name=&mealsPerDay=9&pricePerMeal=0&mealType=LUNCH' http://127.0.0.1:19514/customers
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Add a customer · TiffinBox</title> · <h1>TiffinBox</h1> · 21 lines, 1036 bytes - not shown but these:
    name = "" · its message: must not be blank
    mealsPerDay = "9" · its message: must be less than or equal to 3
    pricePerMeal = "0" · its message: must be greater than or equal to 1
    mealType = "LUNCH" · its message: must match "VEG|NON_VEG|VEGAN"
    messages on the page: 4
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data 'name=Lata&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:19514/customers
  curl's line: 302 · Content-Type: []
  HTTP/1.1 302 · Location: http://127.0.0.1:19514/dashboard · Content-Language: en-US · Content-Length: 0 · headers not shown: 1
  body: none (0 bytes)
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19514/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · 23 lines, 1000 bytes - not shown but these:
    the counts: Customers: 5 · This month: 31500 · Paused days: 5
    the table, first column: Lata Meera Priya Ravi Sunil
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html' --data 'name=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:19514/customers
  curl's line: 500 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 500 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 2
  the page: <title>Something broke · TiffinBox</title> · <h1>TiffinBox could not answer</h1> · 12 lines, 298 bytes - not shown but these:
    The server failed on /customers: status 500.
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19514/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Content-Type: [application/json]
$ harness/shutdown.sh 19514 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19514 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
3 the binary - .harness/nat, the README's line, port 19516:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19516
  listens on: 127.0.0.1:19516 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19516/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19516 (http) with context path '/'
$ $CURLSET 19516 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then every page, on a second start of the binary:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19516
  listens on: 127.0.0.1:19516 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19516/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19516/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · 22 lines, 926 bytes - not shown but these:
    the counts: Customers: 4 · This month: 24300 · Paused days: 5
    the table, first column: Meera Priya Ravi Sunil
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19516/customers/new
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Add a customer · TiffinBox</title> · <h1>TiffinBox</h1> · 21 lines, 806 bytes - not shown
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data 'name=&mealsPerDay=9&pricePerMeal=0&mealType=LUNCH' http://127.0.0.1:19516/customers
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Add a customer · TiffinBox</title> · <h1>TiffinBox</h1> · 21 lines, 1036 bytes - not shown but these:
    name = "" · its message: must not be blank
    mealsPerDay = "9" · its message: must be less than or equal to 3
    pricePerMeal = "0" · its message: must be greater than or equal to 1
    mealType = "LUNCH" · its message: must match "VEG|NON_VEG|VEGAN"
    messages on the page: 4
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data 'name=Lata&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:19516/customers
  curl's line: 302 · Content-Type: []
  HTTP/1.1 302 · Location: http://127.0.0.1:19516/dashboard · Content-Language: en · Content-Length: 0 · headers not shown: 1
  body: none (0 bytes)
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19516/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · 23 lines, 1000 bytes - not shown but these:
    the counts: Customers: 5 · This month: 31500 · Paused days: 5
    the table, first column: Lata Meera Priya Ravi Sunil
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html' --data 'name=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:19516/customers
  curl's line: 500 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 500 · Content-Type: text/html;charset=UTF-8 · Content-Language: en · Transfer-Encoding: chunked · headers not shown: 2
  the page: <title>Something broke · TiffinBox</title> · <h1>TiffinBox could not answer</h1> · 12 lines, 298 bytes - not shown but these:
    The server failed on /customers: status 500.
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19516/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Content-Type: [application/json]
$ harness/shutdown.sh 19516 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19516 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19515:
$ cd .harness/after && docker build --progress=plain -t tiffinbox-pages:1.0.0 .
  exit 0 · its lines, through the filter:
    [internal] load metadata for docker.io/library/eclipse-temurin:25-jre
    [builder 1/4] FROM docker.io/library/eclipse-temurin:25-jre@sha256:fcd7fd7b387f94bb2ac461478a7436ad8e349924c374ea8313919624dceae636
    naming to docker.io/library/tiffinbox-pages:1.0.0
  its lines that say pull: 0 · its other lines: fewer than 300, not shown
  the image saved (docker save): 15 blobs, its 11 layers among them, each read whole (gzip ones unpacked) · the demo token in them: 0
$ cd .harness/after && docker run -d --name tiffinbox-pages --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19515:18425 tiffinbox-pages:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19515/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19515
  on this Mac, listening on port 19515: 127.0.0.1:19515
$ $CURLSET 19515 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
$ docker wait tiffinbox-pages
  0
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log (docker logs): Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1 · the demo token 0 times · X-Shutdown-Token 0 times
  then every page, on a second container of the image - TiffinBox listens on 18425 inside it:
$ cd .harness/after && docker run -d --name tiffinbox-pages --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19515:18425 tiffinbox-pages:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19515/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19515
  on this Mac, listening on port 19515: 127.0.0.1:19515
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19515/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · 22 lines, 926 bytes - not shown but these:
    the counts: Customers: 4 · This month: 24300 · Paused days: 5
    the table, first column: Meera Priya Ravi Sunil
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19515/customers/new
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Add a customer · TiffinBox</title> · <h1>TiffinBox</h1> · 21 lines, 806 bytes - not shown
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data 'name=&mealsPerDay=9&pricePerMeal=0&mealType=LUNCH' http://127.0.0.1:19515/customers
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Add a customer · TiffinBox</title> · <h1>TiffinBox</h1> · 21 lines, 1036 bytes - not shown but these:
    name = "" · its message: must not be blank
    mealsPerDay = "9" · its message: must be less than or equal to 3
    pricePerMeal = "0" · its message: must be greater than or equal to 1
    mealType = "LUNCH" · its message: must match "VEG|NON_VEG|VEGAN"
    messages on the page: 4
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' --data 'name=Lata&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:19515/customers
  curl's line: 302 · Content-Type: []
  HTTP/1.1 302 · Location: http://127.0.0.1:19515/dashboard · Content-Language: en-US · Content-Length: 0 · headers not shown: 1
  body: none (0 bytes)
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19515/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 1
  the page: <title>Dashboard · TiffinBox</title> · <h1>TiffinBox</h1> · 23 lines, 1000 bytes - not shown but these:
    the counts: Customers: 5 · This month: 31500 · Paused days: 5
    the table, first column: Lata Meera Priya Ravi Sunil
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html' --data 'name=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA&mealsPerDay=2&pricePerMeal=120&mealType=VEG' http://127.0.0.1:19515/customers
  curl's line: 500 · Content-Type: [text/html;charset=UTF-8]
  HTTP/1.1 500 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · headers not shown: 2
  the page: <title>Something broke · TiffinBox</title> · <h1>TiffinBox could not answer</h1> · 12 lines, 298 bytes - not shown but these:
    The server failed on /customers: status 500.
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Content-Type: application/json' --data '{"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19515/customers
  {"name":"Asha","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · Content-Type: [application/json]
$ harness/shutdown.sh 19515 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
$ docker wait tiffinbox-pages
  0
  exit 0 · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times · WARN lines: 0 · ERROR lines: 1
four forms, one tree: the seven (masked) 4 of 4 times 466c20ed7e0d5439cb052f32ce09de1b · the dashboard page: 8 of 8 · the form's four messages: 4 of 4 · a valid POST, 302 to the dashboard: 4 of 4 · the error page: 4 of 4
  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127.0.0.1 alone yes
  the locale: options on the binary's and the image's run lines: 0 (none passed: the binary runs as the README writes it, the image as its ENTRYPOINT, java -jar)
```


## Exercise

**Your turn:** the README's dashboard answers five hundred with TiffinBox's error page. Find the misspelt name in the template, fix it,
and reload. `exercise/README.md` has the commands (copy `after/`, put the harness's `dashboard.html` — `view.custmers` — in the copy's
templates, give the copy a token of its own); its last line, in a subshell, builds the copy offline, starts it on 19518 from the copy's
folder, asks `/dashboard` for HTML, stops it, waits for its JVM and prints — as shipped — `the dashboard: 500 ·
text/html;charset=UTF-8 · Something broke · TiffinBox`. Done is `the dashboard: 200 · text/html;charset=UTF-8 · Dashboard · TiffinBox`.
Measured answer: `exercise/solution/SOLUTION.md` (the README's two `export` lines, the line that makes `view.custmers` `view.customers` —
idempotent — and the README's last line again), run in the same shell. "Reload" is the README's last line again. Run `./receipts.sh` once
first on a fresh clone.

## The anchor's README — what this unit changed in it

`../c6-tiffinbox/README.md` (= `after/README.md`) gains its `## Course 6 · unit 22` section (after unit 16's, before Course 5's README
begins) with the anchor's two new lines — `curl -s -H 'Accept: text/html' http://127.0.0.1:18431/dashboard` and the form's POST — and
**eight history notes amended in place**, each an *(Course 6, unit 22: …)* note — found by grepping the README for `415`, `form`,
`urlencoded`, `rows`, `mappings`, `libraries`, `Whitelabel`, `HTML`, `/dashboard` (S2.22, S4.11), each hit read:
- the embedded-Tomcat section's starter bullet (the jar's 58 → 56 libraries) → 61, Thymeleaf's five;
- the request-mapping section's routing table (unit 12's "still 9 mappings") → ten routes, 19 rows, `DashboardPage`'s three;
- the path-variable section's routing table (unit 12's note) → ten routes, 19 rows;
- the request-body section's routing table ("16 rows, two of them `/customers`") → 19 rows, three `/customers`, the form's consuming
  `application/x-www-form-urlencoded`;
- the request-body section's "none reads a `Customer` from a form" → still none of the converters; Spring MVC's data binder binds a form
  onto a `Customer` since, on `DashboardPage`'s POST;
- the request-body section's 415 without the Content-Type (after unit 16's note) → no longer a 415: the form's route answers 200 with the
  form and one raw message;
- the request-body section's "the form's 415" in every form (after unit 09's note) → gone;
- the problem-detail section's "the Whitelabel page for HTML" for what nobody caught → TiffinBox's own `templates/error/5xx.html`; curl's
  own Accept still Boot's body.

Left as they were, and still true (each read): the capstone's run section's `curl -s http://127.0.0.1:18425/dashboard` (curl's own Accept:
still the JSON); the request-mapping section's route list (`/revenue`, `/dashboard` and `/kitchen` — TiffinBoxServer's, unchanged); every
"the executable jar holds the same N libraries" line of an earlier unit (each that unit's own count, history); the exception-handler
section's Whitelabel 404 for the tree before it (history); Course 5's sections, the Actuator bridge's 415 included (`/actuator/loggers`, not
`/customers`). `c6-tiffinbox/README.md`: 100 lines added and 8 removed against the previous tree's (`change`) — the 8 are the lines the notes rewrapped.

## The ledger rows and hand-offs this unit pays

| Row | Paid how | Where |
|---|---|---|
| **C6-23** "the menu becomes web pages" | the dashboard rendered on the server and the form, as pages, in all four forms | `negotiate`, `form`, `forms` |
| **C6-18** templates (Course 5's DevTools defaults) | `spring.thymeleaf.cache` — Boot's default true, by effect (A/B/A′) — and `spring.template.provider.cache` — no metadata entry, by effect (C); DevTools' 10 keys on this class path | `devtools` |
| the roadmap's "dashboard rendered server-side; fragments and forms" | `th:fragment`/`th:replace`, `th:object`/`th:field`/`th:errors` | `fragments`, `form` |
| S3 CARRIED: `templates/error/404.html`; DevTools' template cache | 404 settled — never rendered on this anchor (C); `error/5xx.html` shipped and proven in the binary; the cache above | `errors`, `forms`, `devtools` |
| **C6-31** "if a course uses it, a course teaches it" | every new term glossed at first use (template, view, fragment, form-backing object, redirect-after-POST); Chrome's own record named, no panel used | the script |
| H-14 (C6/14 named templates → *Serving HTML: Thymeleaf*) | the 10th DevTools key is Thymeleaf's own, on this class path (14 counted 9 on its) | `devtools` |

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-22) |
|---|---|---|---|
| 7 | 22's binary on 22's own tree (the hint + the Java-side count); `error/5xx.html` in the binary | build 4 on the chain's sketch; the error page never | **the binary serves every page: the dashboard (twice), the form, its four messages, the 302, and TiffinBox's error page for the 61-letter name — 4 of 4 forms; AOT 670 → 687, `Dashboard$View` and `Customer`'s public methods the hint's** (`forms`) |
| 8 | 22's image | never run | **the image: the seven `466c20ed…`, every page as the jar's, published on 127.0.0.1 alone, 0 tokens in its 11 layers** (`forms`) |
| 14 | the exercise as viewers run it | end states on sketches | **one `env -i` shell: 500 the error page, then 200 the dashboard; SOLUTION twice: the same** (`exercise`, and below) |
| 15 | the `typeMismatch` message key (⚑3 loser D) | not run | **not run: the raw message is shown as a hazard and the key named** (`form`) |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **Four templates, not five** (brief: "five templates fragments/dashboard/customer-form/error/5xx"): the list names four; the fifth was
  the `error/404.html` the brief rules out.
- **The 500 is TiffinBox's own** (brief: "a 500 as HTML", the probe's harness `/probe/boom`): a name of 61 letters overflows the
  customer table's `VARCHAR(60)` — nothing checks a name's length, in JSON or in the form — so the error page is shown on TiffinBox's own
  route and proven in all four forms, the binary included, with no harness (a `@Size(max = 60)` on `Customer.name` is the fix; not this
  lesson's file: carried, below).
- **A taken name is a field error on the form** (the probe's sketch answered it with a 500: its form never read the SQLSTATE).
- **The 415 is gone** (not in the brief): the request-body lesson's POST without its Content-Type is a form's type, and reaches
  `DashboardPage`'s POST — 200, the form, one raw message. Said on screen, noted in the anchor's README.
- **The template cache is per page** (brief: "an edited template shows on the next request with cache=false, never with true"): with the
  cache on, the dashboard — already rendered — keeps the old fragment, while the form, rendered for the first time after the edit, reads
  it (A shows both).
- **`spring.template.provider.cache` has no metadata entry** (brief: "named"): Boot reads it in `TemplateAvailabilityProviders` (the
  class's bytes name it once) — measured by effect, C: an error page added while TiffinBox runs stays unseen until it is false.
- **The binary's `Content-Language` is `en`**, the jar's `en-US` (not in the brief): its run line takes no locale option.
- **Under DevTools the JVM exits 1 after POST /shutdown** (the jar exits 0): Java's launcher, explained in "Found on the way"; asserted, not spoken (`devtools`).

## Found on the way

- **The sealed clone found a fresh-clone defect, fixed before the runs of record:** DevTools is no dependency of the tree, so on a
  fresh clone's empty `.m2-demo` no build fetched its jar and the run stopped at the start-up check. `receipts.sh` now fetches it by name
  (`dependency:get`, offline first, as the DevTools lesson does) — the sealed run's line says `offline: no`, as a fresh clone's must.
- **Every new check fails on a planted fault first** (R.65, S4.10): the checks block runs alone — `receipts.sh` with no build and no
  capture, `cap()` only recording a 0 raw count — on the published captures with one thing changed per plant (`plants.py`, this unit's
  scratch folder): **58 plants, 58 stops under /bin/bash 3.2 and 58 under bash 5.3**, each naming its own check (the same 58 lines
  under both). Forty-seven change one line of a capture (the jar's count, the files byte for byte, the cache's default, the
  controller's annotation, the Java-side count, a 404 template in after/; the seven's sameness, the rows, the page's `produces`, the previous tree's JSON for Chrome and its 415, the JSON
  for curl, `Content-Language: de`, `no customer named new`; the differing fragment line, the error page naming a fragment; the 302, the
  German messages, the taken name, the JSON 201, the old 415's message, Lata in the table, a WARN; the error page's title, Thymeleaf's
  logger, the typo's ERROR count, C's problem detail, Boot's JSON 500; DevTools' count, A′, A's footer, the provider cache's metadata,
  35729, C's second answer; the exercise's two lines; forms' 8 of 8, the binary's loopback, the hint's type, the AOT count, the binary's
  token, its `Content-Language`; Chrome's Accept, `same-origin`, the seal, the server's 302, the fresh profile); four plant a hygiene
  fault in a capture (an absolute path, a whole HTML page, Chrome's version, an unpinned java line); seven change a shipped file (the
  spoken exercise line, the fixed template, a bare `wait` in the solution, Boot 3's error key in this README, a stop by name in
  `cdp.mjs`, the raw token in `net.py`, the harness named in after/'s code). The unplanted copies pass, before and after; every capture is
  restored byte for byte (md5).
- **Three filters fail on planted inputs inside the script itself**, before any capture: the level counts (a `Dump` line that says
  `ERROR` is no ERROR line — R.120), the record filter, the harness's running number, the page filter's four modes, a Whitelabel page, a
  JSON body and an empty body, the header filter, and the masks (Chrome's version, a request thread's number).
- **The exercise as viewers run it**, beyond the capture: README then SOLUTION, then SOLUTION again, in one `env -i` `zsh -f` shell →
  `the dashboard: 500 …`, `the dashboard: 200 …`, `the dashboard: 200 …`, each exit 0, the shell left in `c6-unit22/`, the name fixed once;
  the README's last line alone in an `env -i` `/bin/bash` shell without the exports — its `java` 23 — ends with `exit 1` and prints no line (its Maven build fails under 23,
  so no JVM starts); 19518 free after each.
- **The probe's sketch and this tree agree** where they overlap (brief READ FIRST 9; S4 notes Steps 6 and 9): the seven `466c20ed…`, lib 56
  → 61, the page for HTML and Chrome's Accept and JSON for `*/*`, the four messages, `two`'s raw message, error/404.html dead, the 10
  DevTools keys, the binary's page with the hint and the Java-side count — each now a line of this unit's own captures. Where they part:
  the sketch's form answered a taken name with a 500 (this tree's: a message on the name), and its edit test asked one page (this unit's
  A asks two, and the cache turns out per page).
- **Chrome** (155.0.8059.85, headless) asked for `/css/tiffinbox.css` and `/favicon.ico` on the first visit (seen in this unit's
  scratch; `Dump` and `net.py` skip both on purpose — how often a browser asks again is the next lesson's subject, never a witness here);
  the favicon is a 404 problem detail.
- **DevTools' JVM exits 1 — explained and asserted** (RED S4 #404; R.109): DevTools' restarter runs the application again on a
  thread of its own (`restartedMain`) and ends the first `main` thread by throwing its `SilentExitException`; the handler it installs
  (`SilentExitExceptionHandler`, javap of spring-boot-devtools-4.1.1) stays silent and calls `System.exit(0)` only when that thread is
  the last one alive — it is not, so it just returns, and Java's launcher, whose `main` thread ended with an uncaught exception, exits
  1 when the last thread stops after POST /shutdown. A ten-line probe (a `main` that starts a thread, then throws with a silent
  handler) exits 1 the same way. `receipts.sh` asserts it now: each DevTools JVM a capture stops, on DevTools' port (19513), exits 1, and
  every other JVM a capture stops exits 0. Not spoken.
- **The binary's default locale** answers `Content-Language: en`, the jar's (pinned) `en-US`; the image's `en-US`.

## For unit 23 — and RED

- **Read `../c6-unit22/after`** (= `../c6-tiffinbox` now): `DashboardPage`, the four templates, `static/css/tiffinbox.css` (5 lines),
  linked from `fragments.html` as `th:href="@{/css/tiffinbox.css}"` — 23's content versioning rewrites that link; `error/5xx.html` links
  it too. The CSS answers `Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT` with no `Cache-Control` (seen in this unit's scratch, not
  captured; 23 measures it).
- **The seven** stay `466c20ed7e0d5439cb052f32ce09de1b`; the routing table is 19 rows.
- **Chrome:** 155.0.8059.85 on this Mac; the Accept string is `CHROMEA` in `receipts.sh`; `cdp.mjs` here opens a page and sends a form
  (`open`, `form`), `net.py` lists documents only — 23 needs the stylesheet's requests, so its `net.py` must list subresources (and their
  `from cache`); `Dump` here skips `/css/` and `/favicon.ico` on purpose — 23 must not.
- **Carried:** `@Size(max = 60)` on `Customer.name` (a 61-letter name is a 500 in JSON and the form alike) — a change to `tiffinbox-core`,
  outside 22's files; the `typeMismatch` message; CSRF for the form (Course 10).
- **Ports** 19510-19519 are this unit's; 23 has 19520-19529. The image `tiffinbox-pages:1.0.0` / container `tiffinbox-pages` are this
  unit's names.
