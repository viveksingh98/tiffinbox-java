# c6-unit23 — Static Resources and Cache Headers

Course 6 · Spring Web MVC · Section 4 (The Rest of MVC), its sixth unit and the second link of its anchor chain (22 → 23 → 24) ·
Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Thymeleaf 3.1.5),
**GraalVM CE 25.3.4.1** (native-image 25.0.4.1), **Docker on OrbStack**, **headless Chrome 155** driven by **node 26** (both optional),
2026-10-22. The serving lesson gave TiffinBox a page and a stylesheet. Change that stylesheet, build, restart — and a browser keeps
showing the old one without asking. This unit reads the headers a **static resource** (a file the server sends as it is, no controller
in between) comes with, finds out why "has it changed?" gets the wrong answer, and gives the file a name that changes when the file
does: Boot's content version strategy and a year's cache lifetime, three keys in `application.yaml`. It measures that the seven do not
move, whose date `Last-Modified` is, what a real browser does with no lifetime, with `no-cache` and with a versioned name — each seen by
Chrome and by the server — what the ETag the static handler sends is worth, what DevTools changes, and every form: jar, AOT jar, native
binary and image.

**The anchor changes (brief ⚑2, ⚑4).** `after/` is this unit's frozen copy of `../c6-tiffinbox` after the change, and `diff -rq -x
target ../c6-tiffinbox after/` is empty at this unit's commit. "Before" is `before/`, the link to `../c6-unit22/after` — the serving
lesson's frozen tree, which `c6-tiffinbox` equalled before this unit (`diff -rq -x target` empty, checked first). Both trees are read and
copied under `.harness/`, never built in place. One file changed, besides the anchor's README (`change`):

- `tiffinbox-web/src/main/resources/application.yaml` — 106 → 122 lines: in its **first document** (R.87: lines 77, 78, 80; the first
  `---` at 115; the document's `spring:` key at 23), under `spring:`, a 7-line comment and `web.resources.chain.strategy.content.enabled:
  true`, `...content.paths: /**` and `web.resources.cache.period: 365d`. Boot's metadata: `enabled` `false` by default, `paths` `["/**"]`
  by default (written down, as `application.yaml` writes Actuator's default exposure), `cache.period` no default.
- `README.md` — the anchor's: its unit 23 section, and one history note made false (below).

31 of `after/`'s 33 files are byte for byte the previous tree's; the jar's 61 libraries are the same names. **The new build**: each tree
copied with `harness/newbuild/tiffinbox.css` — the stylesheet with one line added, `footer { color: #555; }`, 200 → 224 bytes, md5
`10ba2401…` → `c10b71bc…` — in place of its own, built the same way (`.harness/before-new`, `.harness/after-new`): the "changed
stylesheet" every capture asks about.

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
`.m2-demo` re-seeded from `_research/m2-seed-s4/` alone. **1,241 s under `./receipts.sh`** (/bin/bash 3.2.57): all 9 captures 3/3, every
check passed, then — as designed for a first run — "no published hash"; their hashes went into `receipts.md5`. **1,459 s under `bash
receipts.sh`** (Homebrew bash 5.3.9): exit 0, all 9 = published. **A sealed fresh clone**, the script as committed (`git clone` of
tiffinbox-java at 0fbb3dc, this unit's and the anchor's 49 files put in as git would take them — 0 differing from the working tree,
`before` → `../c6-unit22/after` by `readlink`; `env -i`, a `HOME` of its own whose `.mavenrc` points every Java proxy at a refusing port,
Maven settings sending every repository to a `file://` copy of Central's files made from `_research/m2-seed-s4/` (4,425 files), the
proxy variables at the same refusing port, `GRAALVM_HOME`, `DOCKER_CONFIG`, `/bin/bash` 3.2, a process group of its own): **exit 0, all 9
= published, every check passed, 1,434 s; 720 artifacts, every one from the `file://` copy** (and TiffinBox's own three, installed by
the run) — its first build and DevTools' `dependency:get` said `offline: no`, as a fresh clone's must, every capture's build `offline:
yes`. **1,490 s under `./receipts.sh`** (/bin/bash 3.2.57) on the finished files, exit 0, all 9 = published; then the planted faults found
three gaps in the checks ("Found on the way") and two checks were added. **A last run on the finished files** (this README, the anchor's, everything as committed but this paragraph's last sentences and the
plants' line): **1,465 s under `bash receipts.sh`** (Homebrew bash 5.3.9), exit 0, all 9 = published, every check passed. (The sealed
clone ran the script before those two checks were added; the captures it made are the same nine.) Every native build took 149-265 s (terminal only), under the 20-minute bound; the SIGINT runs (below) interrupted three
more.

Published hashes: change `2fed6abb0481bb6717d09779299e3458` · headers `6505d479627f072e7a433ddb957714b3` · date `17db2c5ef8135d062845b06848459a2f` · versioned `cdac645d568923702e3bc12f656fa831` · etag `20edf69daa0dcf872fdecf8a40631adf` · devtools `4ad8107ad2700aa417b6f809576f152a` · exercise `b0175b3604d7ad33a01375817b74f8c2` · browser `c1fc64e0dfd77980ed601012caa93af2` · forms `d251cfdbeedcd05325ff593fd208722e`.

## The commands this unit adds

`after/README.md` — the anchor's own — gives every line `receipts.sh` runs or derives from but twenty-two, which are this unit's, each
read from the block below and asserted to be exactly this (on the anchor's port 18431; each capture swaps in its own port):

```bash
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --management.endpoints.web.exposure.include=health,prometheus,mappings
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --spring.web.resources.chain.strategy.content.enabled=false
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/classes:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/classes:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.web.resources.chain.cache=false
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.main.sources=probe.web.Dump
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.main.sources=probe.web.Dump --spring.web.resources.cache.cachecontrol.no-cache=true
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Keys
javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/probe/web/Dump.java harness/probe/web/Keys.java harness/probe/web/Trace.java
cp harness/newbuild/tiffinbox.css .harness/after-new/tiffinbox-web/src/main/resources/static/css/tiffinbox.css
curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:18431/dashboard
curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:18431/css/tiffinbox.css
curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' -H 'If-Modified-Since: Tue, 15 Sep 2026 00:00:00 GMT' http://127.0.0.1:18431/css/tiffinbox.css
cp ../../harness/newbuild/tiffinbox.css tiffinbox-web/target/classes/static/css/tiffinbox.css
"$CHROME" --headless=new --user-data-dir="$PWD/.harness/chrome" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 --host-resolver-rules='MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' --remote-debugging-address=127.0.0.1 --remote-debugging-port=19529 --log-net-log="$PWD/.harness/netlog.json" about:blank
node harness/cdp.mjs 19529 open http://127.0.0.1:18431/dashboard .harness/ev.json
node harness/cdp.mjs 19529 again http://127.0.0.1:18431/dashboard .harness/ev.json
node harness/cdp.mjs 19529 reload .harness/ev.json
node harness/cdp.mjs 19529 close
python3 harness/net.py .harness/ev.json 18431
python3 harness/netlog.py .harness/netlog.json 18431
```

The first three are the anchor's run line, class-path line and routing-table line with `-Duser.language=en -Duser.country=US` after
`java`; the fourth is the run line with the content strategy off for one run (`versioned` B). The **folder line** is the class-path line
with the web module's `target/classes` in place of its jar — a stylesheet replaced while TiffinBox runs is read from a folder — and the
next is it with the resource chain's cache off (`devtools` F). The **Dump line** is the class-path line with the harness's classes and
`Dump` joined (the browser's TiffinBox), and the next is it with `Cache-Control: no-cache` on the static files (C, D). The DevTools line
is the class-path line with DevTools' jar from `.m2-demo` and the harness added, Live Reload off (35729 is never bound) and `Keys` joined.
The javac line compiles the harness's three classes against after/'s libraries; the `cp` line makes after/'s new build (the previous
tree's is the same `cp` into `.harness/before-new`, printed in `change`). The page line is the anchor's `curl -s -H 'Accept: text/html'
…/dashboard` with the headers and the body sent to files; the **stylesheet line** is the anchor's new header line with the headers and
the body sent to files, curl's status and size printed (`%{size_download}`: a 304's body is never read from a file curl may not have
written, R.119) and the plain name; the conditional line is it with `If-Modified-Since: Tue, 15 Sep 2026 00:00:00 GMT` — the build's
fixed time, which every `Last-Modified` here is checked against. The second `cp` is the stylesheet replaced while TiffinBox runs. The
Chrome line starts headless Chrome with a profile made fresh under `.harness/chrome`, sealed (a dead proxy at `127.0.0.1:9`, every host
name unresolvable but 127.0.0.1), its DevTools protocol on `127.0.0.1:19529`, a NetLog; `cdp.mjs` opens the dashboard in a new tab,
types its address again in that tab, or reloads it, then closes Chrome; `net.py` reads Chrome's record of a visit, `netlog.py` the
NetLog. Every other request is one of those with its port, path or one or two request headers changed (`gq`, `cq`), the anchor's own
link line (`R_LINK`) with its port, or the Chrome lines with the TiffinBox port (`vq`, `aq`).

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else, refuses one whose `native-image --version` is not
`native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1`, and never prints its folder (`$GRAALVM_HOME` in every capture). Only `forms`
needs it. **Without a GraalVM** the script makes the eight other captures, each checked against `receipts.md5`, then stops where the
native build would start (exit 1).

## The browser

The `browser` capture needs **Chrome** (`CHROME=` at the top of `receipts.sh`) and **node 22 or later** (its built-in WebSocket drives
Chrome's DevTools protocol; nothing is installed). Both are optional: without them every curl capture runs and is checked, and the
script stops at the browser step with exit 2, naming this section — before the native build. Each of the four visitors is a Chrome of
its own: started with a profile made fresh under `.harness/` (never a user profile; the capture says it did not exist), sealed to
127.0.0.1, stopped by its pid — never by its name (the author's own Chrome runs beside it, untouched) — and its profile removed. One
tab is the visitor: `open` makes it, `again` types the address into it again, `reload` reloads it, so every visit after the first
meets what Chrome kept. Between two visits TiffinBox may be **replaced on the same port** by its new build (POST /shutdown, then the new
build's JVM): the address — and so Chrome's cache entry — stays the same. **Chrome auto-updates.** Its version is printed to the
terminal only, and masked in every capture (`User-Agent`'s `Chrome/<version>`, `sec-ch-ua`'s brand list whole), so a new Chrome that
behaves the same keeps the hash; one that caches differently or sends another header changes it, and `cap()` dies: read the diff, then
publish the new hash with the version in this README. **Chrome keeps the stylesheet by its own rule** when an answer gives no lifetime
(HTTP's caching RFC lets a cache guess one; how Chrome guesses is not measured here); what it did is measured on Chrome 155 with a
`Last-Modified` 37 days old — never a TiffinBox setting. Chrome's own record is its DevTools protocol's network events (`net.py`: the
page and its stylesheet, each from Chrome's cache or from the server, the headers that ask about a kept copy, and the answer's
`Cache-Control`, `ETag`, `Last-Modified`, `Content-Length`); no developer-tools panel is filmed or used.

## The repository, Docker, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../spring-web-mvc/_research/m2-seed-s4/` alone (5,891 files) and re-seeded so before each run of record. **Nothing was downloaded**
for this unit: every build said `offline: yes`, the native plugin read its metadata repository from `.m2-demo`, and every native build
log holds 0 lines of the plugin's own download. A fresh clone's `.m2-demo` is empty (git ignores it): the first build — `after/`'s `mvn
-B -Pnative install`, before any capture — fills it from Maven Central and says `offline: no`; DevTools' jar, which no build fetches, is
then fetched by name (`dependency:get`, offline first). **Docker:** no pull — `docker build` prints its `load metadata` line and the base
image's digest, and `its lines that say pull: 0`. The image (`tiffinbox-static:1.0.0`) and the container (`tiffinbox-static`) are this
script's own names, checked absent first and removed on every exit. **At run time** every request goes to `127.0.0.1`.

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 30 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/*/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored), mounted read-only into the container, and sent only by `../c5-unit11/curlset.sh` and `harness/shutdown.sh` on curl's
standard input. Every capture's raw output is searched for it before masking (0 in all of them), and so are the log of every JVM that
served, the container's log, every file this unit ships, the binary's bytes and every blob of the image (`docker save`): 0 everywhere.
The header's name is counted too: 0 in every log. No capture sends a secret anywhere else, so no canary is needed. `Dump` prints every
request's headers whole and passes POST /shutdown through unprinted. The exercise makes a token of its own (`openssl rand -hex 16`),
counted 0 times in its own log and never printed.

## The locale — pinned per JVM

Every java line this script starts carries `-Duser.language=en -Duser.country=US` before `-jar` or `-cp` (S4.1), and a last check refuses
any capture's java line without them; the harness's `Keys` prints the JVM's locale (`en_US`). No capture here prints a message a locale
words; the pages' `Content-Language: en-US` is the JVM's (no request names a language but Chrome's `en-US,en;q=0.9`, `--lang=en-US`).
The binary's line passes no locale option.

## The folders, the names and the ports

- `after/` — the anchor after this change (= `../c6-tiffinbox`); `before` — the link to `../c6-unit22/after`. `.harness/before`,
  `.harness/after` — the two trees, copied, each with a config tree, built and extracted; `.harness/before-new`, `.harness/after-new` —
  the new builds (`change`); `.harness/fold` — after/'s build, its classes folder's stylesheet replaced while TiffinBox runs
  (`devtools`); `.harness/nat` — after/'s native build, and `.harness/natb` — the previous tree built with the native profile, for its AOT
  metadata (`forms`); `.harness/hc` — the harness's classes; `.harness/chrome` — Chrome's profile, made fresh, removed after each visitor
  and on every exit; `.harness/mine` — the exercise's copy.
- **The harness** — the course's, never TiffinBox's (package `probe.web`, outside `com.tiffinbox`), joined by `--spring.main.sources`:
  `Dump` — the serving lesson's filter with one path fewer skipped: every request but Actuator's, POST /shutdown and `/favicon.ico`
  printed whole (method, path, every header in Tomcat's order), then its status, every header a filter can read (a Date's value not
  printed) and the bytes of body the server wrote — **the stylesheet's requests included**, the one difference (checked: its code
  differs from the serving lesson's in that one condition). `Keys` — the serving lesson's, byte for byte: the JVM's locale, every
  property source whose name says devtools with its keys, and what the environment answers for five keys. `Trace` — the CORS lesson's,
  byte for byte. `harness/newbuild/tiffinbox.css` (after/'s stylesheet and one line, checked); `harness/cdp.mjs` and `net.py` (new),
  `netlog.py` and `shutdown.sh` (the CORS lesson's, byte for byte).
- **Ports** (brief ⚑1, 19520-19529): after/'s jar 19520 · the previous tree 19521 · a new build 19522 · DevTools 19523 · a folder class
  path, then the image 19524 · the AOT jar 19525 · the binary 19526 · the browser's TiffinBox 19527 · the exercise 19528 · Chrome's
  DevTools port 19529. All ten, 18425, 8080 and 35729 are checked free first; a run that listens on 8080 or 35729 is killed and the
  script dies.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM, the token, the user, a request thread's number, Chrome's version** (`gsub()`, literals escaped), in every
   line: the demo token → `[masked: the 30-character token]`; the GraalVM's folder → `$GRAALVM_HOME`; this folder → `…`; the folder above
   → `…/..`; home → `~`; the user name, as a whole word → `<user>`; `tomcat-handler-<digits>` → `tomcat-handler-<n>`; `Chrome/<digits>` →
   `Chrome/<version>`; a `sec-ch-ua:` value, whole → `(its brands and their versions: masked)`. A last check fails if any capture holds
   an absolute path, the GraalVM's folder, a unit number, Boot's process line, a log time, an unmasked timestamp, **a date other than the
   build's fixed time** (`Tue, 15 Sep 2026 00:00:00 GMT`, and `09-15-2026 00:00` as unzip lists it), a thread number, a stack frame, a
   whole HTML page, a Chrome version, a `sha256:` ID other than the base image's digest, `:8080` or `:35729`, a carriage return, a java
   line without its locale, or a command with a URL that is not `127.0.0.1`'s.
2. **Headers** (`hall`): the status line and every header, whole, in the order they came, on one line; a `Date` header's value → `(the
   time - not printed)`; a `Last-Modified` other than the build's fixed time → `(another time - not printed)` (a folder class path's
   file time, `devtools` F; the binary's, `forms` — `lmwhere` says where it falls). `vals` reads `Last-Modified`, `ETag` and
   `Cache-Control` off the same headers, `none` when absent.
3. **Bodies**: a page (`pagef`) as its `<title>`, its line and byte counts and its stylesheet's `<link>` line; a stylesheet (`bodyf`) as
   its bytes and md5; a JSON answer as its bytes, the timestamp masked; no file → `no file - curl wrote none` (the files are removed before
   each request). Each filter is checked on planted inputs before any capture.
4. **Log lines** (`logl`, `recs`): matched by the log's own line shape (R.120); printed from their logger on.
5. **The harness's lines** (`hk`): printed in the order they ran, numbered from 1 for each request or visit; a falling running number stops
   the run.
6. **Chrome's record** (`net.py`) and the **NetLog** (`netlog.py`): as "The browser" says; the site's icon named, never counted.
7. **The jar's entry dates** (`zdates`): every entry's date as the listing gives it, counted by value.
8. **Spring's AOT metadata** (`aotcmp`), **the native build's lines**, **docker build's lines**, **inside the container** and **on this
   Mac**: as the serving lesson's receipts declare them; `aotcmp` now also names new entries whose type says `Resource`.
9. **A′ against A** and **E′ against E** (`asame`): the blocks, their labels aside, compared line for line in the capture itself.

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`), the exercise's
shell (`$xpid`, with every process under it) and Chrome (`$cpid`, with every process under it — `killtree`), sweeps its own process group
for any TiffinBox JVM, binary, Maven or `native-image` left and every process started with this unit's own Chrome profile, removes the
container and the image, deletes Chrome's profile and the capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The
published captures are untouched. No `wait` in the script, its checks or the exercise is bare (a check refuses one).

**Measured** on the script as committed (2026-10-22), started as a terminal starts its foreground job (SIGINT at its default, a process
group of its own — from a script, `python3` with `signal.signal(signal.SIGINT, signal.SIG_DFL)` and `os.setpgrp()`), SIGINT to the
group three times: **during a capture's JVM** (`headers`, TiffinBox listening on 19521; 8 processes in the group), **during Chrome**
(`browser`, this unit's Chrome and its helpers running — 15 processes in the group, 11 of them Chrome's), and **during the native build**
(`forms`, native-image running — 5 processes in the group). Each time: **exit 130** within 1 s; 5 s later 0 processes in the group, 0
TiffinBox JVMs, binaries or native-image builders anywhere, 0 Chrome processes with this unit's profile and the profile folder gone;
19520-19529, 8080, 18425 and 35729 free; no `tiffinbox-static` container or image; no `.r-lock`; no unfinished capture run; the published
captures unchanged (md5 of all nine, before and after); the author's own Chrome — 31 processes — the same before and after.

## 1 · change — three keys; the new build

The previous tree and after/, copied and built (offline), and each copied again with the new stylesheet and built: four jars, extracted;
the harness compiled; the files that differ; `application.yaml`'s diff whole and where its keys sit; Boot's metadata for the keys; the new
stylesheet against after/'s; the jars' libraries.

`.r-change.out` · md5 `2fed6abb0481bb6717d09779299e3458` · 3 of 3

```
the previous tree and after/, both copied under .harness/ with a config tree, each built with the README's line (offline):
$ cd .harness/before && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the previous tree · offline: yes · exit 0
$ cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built after/ · offline: yes · exit 0
the new build - each tree copied again, the harness's stylesheet in place of its own (this unit's line, for after/'s; the same for the previous tree's), built the same way:
$ cp harness/newbuild/tiffinbox.css .harness/after-new/tiffinbox-web/src/main/resources/static/css/tiffinbox.css
  exit 0
$ cp harness/newbuild/tiffinbox.css .harness/before-new/tiffinbox-web/src/main/resources/static/css/tiffinbox.css
  exit 0
$ cd .harness/before-new && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the previous tree's new build · offline: yes · exit 0
$ cd .harness/after-new && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built after/'s new build · offline: yes · exit 0
the four jars extracted (the README's line) - the class path the harness runs on:
$ cd .harness/before && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
$ cd .harness/after && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
$ cd .harness/before-new && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
$ cd .harness/after-new && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
the harness, compiled against after/'s own libraries - with -parameters:
$ javac -parameters -d .harness/hc -cp ".harness/after/tiffinbox-web/target/extracted/lib/*" harness/probe/web/Dump.java harness/probe/web/Keys.java harness/probe/web/Trace.java
  exit 0 · its classes: probe/web/Dump$Tee$1.class probe/web/Dump$Tee.class probe/web/Dump.class probe/web/Keys.class probe/web/Trace.class
the files that differ, and the files only one tree has:
$ diff -rq -x target -x secrets .harness/before .harness/after
  Files .harness/before/README.md and .harness/after/README.md differ
  Files .harness/before/tiffinbox-web/src/main/resources/application.yaml and .harness/after/tiffinbox-web/src/main/resources/application.yaml differ
  after/'s files: 33 · byte for byte the previous tree's: 31 · new: 0 · those that differ: 2
  tiffinbox-web/src/main/resources/application.yaml: 106 lines -> 122
  its diff (diff -U0, its file names cut) - hunks: 1 · lines out: 0 · in: 16 - whole:
    @@ -64,0 +65,16 @@
    +  # Course 6: the static files under static/ - the pages' stylesheet. Each one's address carries the md5 of its content
    +  # (/css/tiffinbox-<md5>.css: Boot's resource chain, which also rewrites every page's link to it), and its answer lets a
    +  # browser keep it a year (Cache-Control: max-age=31536000). A changed file is a new address, so a kept copy is never the
    +  # wrong one. Without these keys a browser kept the stylesheet with no lifetime given, and Last-Modified - the build's
    +  # fixed time, project.build.outputTimestamp in the root pom.xml, the same for every build - called a changed file
    +  # unchanged. paths: /** is Boot's own default (every file), written down. Above the "---": below it, only the rush
    +  # profile would version its files.
    +  web:
    +    resources:
    +      chain:
    +        strategy:
    +          content:
    +            enabled: true
    +            paths: /**
    +      cache:
    +        period: 365d
  where the keys sit in after/'s application.yaml (line numbers; the first document ends at the first ---):
    web: line 72 · content's enabled: line 77 · paths: line 78 · cache's period: line 80 · the first ---: line 115 · the first document's spring: key, at its first column: line 23
  README.md - the anchor's README: lines added 49, removed 1 - its new section and the history notes the change made false (not shown)
  Boot's own metadata for the keys (spring-boot-autoconfigure-4.1.1.jar, META-INF/spring-configuration-metadata.json):
  spring.web.resources.chain.strategy.content.enabled - type Boolean · default false · Whether to enable the content Version Strategy.
  spring.web.resources.chain.strategy.content.paths - type String[] · default ["/**"] · List of patterns to apply to the content Version Strategy.
  spring.web.resources.cache.period - type Duration · default null · Cache period for the resources served by the resource handler. If a duration suffix is not specified, seconds will be used. Can be overridden by the 'spring.web.resources.cache.cachecontrol' properties.
  spring.web.resources.chain.enabled - type Boolean · default null · Whether to enable the Spring Resource Handling chain. By default, disabled unless at least one strategy has been enabled.
the new build's stylesheet against after/'s:
$ diff after/tiffinbox-web/src/main/resources/static/css/tiffinbox.css harness/newbuild/tiffinbox.css
  5a6
  > footer { color: #555; }
$ md5 -q after/tiffinbox-web/src/main/resources/static/css/tiffinbox.css harness/newbuild/tiffinbox.css
  10ba2401fd96e2e382866a731d207fc4
  c10b71bcdaab1872b81fd1f9d1965761
  their bytes: 200 and 224 · the new builds against their trees, the files that differ: 1 and 1
the executable jar's BOOT-INF/lib: 61 jars -> 61 · the same names: yes · Spring MVC's among them: spring-webmvc-7.0.9.jar
```

## 2 · headers — the seven; what a static file comes with

The seven on both trees, each on a fresh JVM, compared line for line (`466c20ed…` both, the same, byte for byte: 7; one WARN each,
Spring MVC's `PageNotFound`). Then the previous tree: the page's answer — **no validator, no lifetime** — and the stylesheet's,
whole: `Last-Modified`, `Accept-Ranges`, `Content-Type`, `Content-Length`; **no `Cache-Control`, no `ETag`**; the body the file's own
bytes. Its own date sent back → **`304`, 0 bytes, no body file** (a 304 is a validator's answer: "not modified, keep your copy").
`Accept-Ranges: bytes` is on every static answer here, and no claim of this lesson's.

`.r-headers.out` · md5 `6505d479627f072e7a433ddb957714b3` · 3 of 3

```
the seven - the previous tree, the README's run line, port 19521, a fresh JVM:
$ cd .harness/before && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19521
  listens on: 127.0.0.1:19521 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19521/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19521 .harness/before/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
the seven - after/, the README's run line, port 19520, a fresh JVM:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19520
  listens on: 127.0.0.1:19520 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19520/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19520 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
the lines that moved - the previous tree's seven against after/'s, masked, line for line:
  lines that differ: 0 · the same, byte for byte: 7 (1 2 3 4 5 6 7)
what a static file comes with - the previous tree, the README's run line, port 19521:
$ cd .harness/before && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19521
  listens on: 127.0.0.1:19521 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19521/actuator/health/readiness
  {"status":"UP"} 200
the page, and the stylesheet it links:
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19521/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 22 lines, 926 bytes - not shown but its stylesheet link <link rel="stylesheet" href="/css/tiffinbox.css">
  the page's validators and lifetime - Last-Modified: none · ETag: none · Cache-Control: none
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19521/css/tiffinbox.css
  curl's line: 200 · 200 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
  the stylesheet's validators and lifetime - Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: none · Cache-Control: none
  the file in the tree it came from: 10ba2401fd96e2e382866a731d207fc4 · the body's md5 the same: yes
the stylesheet asked again as a cache that holds it asks - its own Last-Modified sent back (this unit's line):
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' -H 'If-Modified-Since: Tue, 15 Sep 2026 00:00:00 GMT' http://127.0.0.1:19521/css/tiffinbox.css
  curl's line: 304 · 0 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 304 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Date: (the time - not printed)
  body: no file - curl wrote none
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19521 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19521 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 3 · date — whose date

`Last-Modified` is the root POM's `project.build.outputTimestamp` (R.122): the POM's line, the stylesheet's entry in the previous
tree's jar and its new build's — 200 and 224 bytes, the same date — and every entry of both jars, 218 of 218, dated by it. Served: the
two builds' answers carry the same `Last-Modified`, the POM's time written as HTTP writes a date, other bodies (other md5s). Asked as a
cache holding the old file asks — the old build's date — **the new build answers 304**: the changed file is called unchanged. Which
validator matched: the date (`If-Modified-Since`); no ETag was sent or exists.

`.r-date.out` · md5 `17db2c5ef8135d062845b06848459a2f` · 3 of 3

```
the root POM's fixed build time - the line, in the previous tree and in after/:
$ grep -n outputTimestamp .harness/before/pom.xml
  32:    <project.build.outputTimestamp>2026-09-15T00:00:00Z</project.build.outputTimestamp>
$ grep -n outputTimestamp .harness/after/pom.xml
  32:    <project.build.outputTimestamp>2026-09-15T00:00:00Z</project.build.outputTimestamp>
the stylesheet's entry in two jars - the previous tree's and its new build's (unzip -l: its entry line; the listing's header and total lines, 4, not shown):
$ unzip -l .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar BOOT-INF/classes/static/css/tiffinbox.css
  200  09-15-2026 00:00   BOOT-INF/classes/static/css/tiffinbox.css
  its entries: 218 · each one's date as the listing gives it: 09-15-2026 00:00 ×218
$ unzip -l .harness/before-new/tiffinbox-web/target/tiffinbox-web-1.0.0.jar BOOT-INF/classes/static/css/tiffinbox.css
  224  09-15-2026 00:00   BOOT-INF/classes/static/css/tiffinbox.css
  its entries: 218 · each one's date as the listing gives it: 09-15-2026 00:00 ×218
the previous tree, the README's run line, port 19521:
$ cd .harness/before && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19521
  listens on: 127.0.0.1:19521 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19521/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19521/css/tiffinbox.css
  curl's line: 200 · 200 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19521 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19521 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
its new build - the stylesheet with one line more - the README's run line, port 19522:
$ cd .harness/before-new && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19522
  listens on: 127.0.0.1:19522 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19522/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19522/css/tiffinbox.css
  curl's line: 200 · 224 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 224 · Date: (the time - not printed)
  body: 224 bytes · md5 c10b71bcdaab1872b81fd1f9d1965761
  the two answers' Last-Modified, the same: yes · the root POM's time, written as HTTP writes a date: Tue, 15 Sep 2026 00:00:00 GMT - the same as theirs: yes
the new build asked as a cache that holds the OLD file asks - the date the previous build sent (this unit's line):
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' -H 'If-Modified-Since: Tue, 15 Sep 2026 00:00:00 GMT' http://127.0.0.1:19522/css/tiffinbox.css
  curl's line: 304 · 0 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 304 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Date: (the time - not printed)
  body: no file - curl wrote none
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19522 .harness/before-new/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19522 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 4 · versioned — A/B/A′, the content strategy

**A** (after/ as shipped): the anchor's own line reads the page's link — **`/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css`**, the
md5 `md5 -q` computes for the file (`the link's name carries it: yes`, computed, never typed) — and that answer carries
**`Cache-Control: max-age=31536000`** (a year), a weak `ETag` (the same md5) and the POM's `Last-Modified`. **The plain name still
answers** — 200, with the year's `Cache-Control`, no `ETag`. After/'s new build links **another name, its own md5**; the old name there →
**404** (a problem detail: no file has that content). **B** (`--spring.web.resources.chain.strategy.content.enabled=false`, a flag on
the tree that has the keys — RE-MEASURE 10): the plain link on both builds, the year still on it, and the new build answers the old
date **304**. **A′** = A, its `$` lines shown; the capture compares A′'s block with A's, line for line: `yes`.

`.r-versioned.out` · md5 `cdac645d568923702e3bc12f656fa831` · 3 of 3

```
A - after/ as shipped (the keys on), the README's run line, port 19520 - the page's link by the anchor's own line:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19520
  listens on: 127.0.0.1:19520 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19520/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -H 'Accept: text/html' http://127.0.0.1:19520/dashboard | grep -o '/css/[^"]*'
  /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
$ md5 -q .harness/after/tiffinbox-web/src/main/resources/static/css/tiffinbox.css
  10ba2401fd96e2e382866a731d207fc4 · the link's name carries it: yes
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19520/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 200 · 200 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
  its validators and lifetime - Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Cache-Control: max-age=31536000
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19520/css/tiffinbox.css
  curl's line: 200 · 200 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
  the plain name's validators and lifetime - Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: none · Cache-Control: max-age=31536000
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19520 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19520 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then .harness/after-new - its new build - the same line, port 19522:
$ cd .harness/after-new && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19522
  listens on: 127.0.0.1:19522 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19522/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -H 'Accept: text/html' http://127.0.0.1:19522/dashboard | grep -o '/css/[^"]*'
  /css/tiffinbox-c10b71bcdaab1872b81fd1f9d1965761.css
$ md5 -q .harness/after-new/tiffinbox-web/src/main/resources/static/css/tiffinbox.css
  c10b71bcdaab1872b81fd1f9d1965761 · the link's name carries it: yes
  the link, against the previous build's: different
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19522/css/tiffinbox-c10b71bcdaab1872b81fd1f9d1965761.css
  curl's line: 200 · 224 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"c10b71bcdaab1872b81fd1f9d1965761" · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 224 · Date: (the time - not printed)
  body: 224 bytes · md5 c10b71bcdaab1872b81fd1f9d1965761
  its validators and lifetime - Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"c10b71bcdaab1872b81fd1f9d1965761" · Cache-Control: max-age=31536000
  the previous build's link, asked of this build:
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19522/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 404 · 181 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 404 · Content-Disposition: inline;filename=f.txt · Content-Type: application/problem+json · Transfer-Encoding: chunked · Date: (the time - not printed)
  body: {"detail":"No static resource css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css.","instance":"/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css","status":404,"title":"Not Found"}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19522 .harness/after-new/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19522 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the content strategy off for this run (this unit's line), port 19520:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19520 --spring.web.resources.chain.strategy.content.enabled=false
  listens on: 127.0.0.1:19520 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19520/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -H 'Accept: text/html' http://127.0.0.1:19520/dashboard | grep -o '/css/[^"]*'
  /css/tiffinbox.css
$ md5 -q .harness/after/tiffinbox-web/src/main/resources/static/css/tiffinbox.css
  10ba2401fd96e2e382866a731d207fc4 · the link's name carries it: no
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19520/css/tiffinbox.css
  curl's line: 200 · 200 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
  its validators and lifetime - Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: none · Cache-Control: max-age=31536000
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19520 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19520 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then .harness/after-new - its new build - the same line, port 19522:
$ cd .harness/after-new && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19522 --spring.web.resources.chain.strategy.content.enabled=false
  listens on: 127.0.0.1:19522 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19522/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -H 'Accept: text/html' http://127.0.0.1:19522/dashboard | grep -o '/css/[^"]*'
  /css/tiffinbox.css
$ md5 -q .harness/after-new/tiffinbox-web/src/main/resources/static/css/tiffinbox.css
  c10b71bcdaab1872b81fd1f9d1965761 · the link's name carries it: no
  the link, against the previous build's: the same
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19522/css/tiffinbox.css
  curl's line: 200 · 224 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 224 · Date: (the time - not printed)
  body: 224 bytes · md5 c10b71bcdaab1872b81fd1f9d1965761
  its validators and lifetime - Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: none · Cache-Control: max-age=31536000
  asked as a cache that holds the previous build's file asks - that build's Last-Modified (this unit's line):
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' -H 'If-Modified-Since: Tue, 15 Sep 2026 00:00:00 GMT' http://127.0.0.1:19522/css/tiffinbox.css
  curl's line: 304 · 0 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 304 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Date: (the time - not printed)
  body: no file - curl wrote none
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19522 .harness/after-new/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19522 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, fresh JVMs, port 19520:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19520
  listens on: 127.0.0.1:19520 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19520/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -H 'Accept: text/html' http://127.0.0.1:19520/dashboard | grep -o '/css/[^"]*'
  /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
$ md5 -q .harness/after/tiffinbox-web/src/main/resources/static/css/tiffinbox.css
  10ba2401fd96e2e382866a731d207fc4 · the link's name carries it: yes
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19520/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 200 · 200 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
  its validators and lifetime - Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Cache-Control: max-age=31536000
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19520/css/tiffinbox.css
  curl's line: 200 · 200 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
  the plain name's validators and lifetime - Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: none · Cache-Control: max-age=31536000
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19520 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19520 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then .harness/after-new - its new build - the same line, port 19522:
$ cd .harness/after-new && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19522
  listens on: 127.0.0.1:19522 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19522/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -H 'Accept: text/html' http://127.0.0.1:19522/dashboard | grep -o '/css/[^"]*'
  /css/tiffinbox-c10b71bcdaab1872b81fd1f9d1965761.css
$ md5 -q .harness/after-new/tiffinbox-web/src/main/resources/static/css/tiffinbox.css
  c10b71bcdaab1872b81fd1f9d1965761 · the link's name carries it: yes
  the link, against the previous build's: different
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19522/css/tiffinbox-c10b71bcdaab1872b81fd1f9d1965761.css
  curl's line: 200 · 224 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"c10b71bcdaab1872b81fd1f9d1965761" · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 224 · Date: (the time - not printed)
  body: 224 bytes · md5 c10b71bcdaab1872b81fd1f9d1965761
  its validators and lifetime - Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"c10b71bcdaab1872b81fd1f9d1965761" · Cache-Control: max-age=31536000
  the previous build's link, asked of this build:
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19522/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 404 · 181 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 404 · Content-Disposition: inline;filename=f.txt · Content-Type: application/problem+json · Transfer-Encoding: chunked · Date: (the time - not printed)
  body: {"detail":"No static resource css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css.","instance":"/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css","status":404,"title":"Not Found"}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19522 .harness/after-new/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19522 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
```

## 5 · etag — the validator that matches nothing

The routing table (`mappings` exposed for this run): the `/**` row is Spring MVC's `ResourceHttpRequestHandler` over five locations.
Its versioned answer's `ETag` sent back alone (`If-None-Match`), as `*`, and beside `If-Modified-Since` (as a browser sends both) →
**200 and the whole file, each time**; the date alone → **304**. One handler, Spring Framework 7.0.9's, four requests (S4.13): the
ETag here is sent, and matched by nothing.

`.r-etag.out` · md5 `20edf69daa0dcf872fdecf8a40631adf` · 3 of 3

```
the handler that serves static files - after/, the README's routing-table line (mappings exposed for this run), port 19520:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19520 --management.endpoints.web.exposure.include=health,prometheus,mappings
  listens on: 127.0.0.1:19520 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19520/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19520/actuator/mappings
  the dispatcher servlet's rows: 19 · those whose handler is Spring MVC's ResourceHttpRequestHandler: 2
    /webjars/** -> ResourceHttpRequestHandler [classpath [META-INF/resources/webjars/]]
    /** -> ResourceHttpRequestHandler [classpath [META-INF/resources/], classpath [resources/], classpath [static/], classpath [public/], ServletContext [/]]
$ curl -s -H 'Accept: text/html' http://127.0.0.1:19520/dashboard | grep -o '/css/[^"]*'
  /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19520/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 200 · 200 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
  its validators and lifetime - Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Cache-Control: max-age=31536000
its ETag sent back alone (If-None-Match), the way a cache that holds this file asks:
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' -H 'If-None-Match: W/"10ba2401fd96e2e382866a731d207fc4"' http://127.0.0.1:19520/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 200 · 200 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
If-None-Match: * (any copy at all):
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' -H 'If-None-Match: *' http://127.0.0.1:19520/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 200 · 200 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
both validators, the ETag and the date - what a browser sends:
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' -H 'If-Modified-Since: Tue, 15 Sep 2026 00:00:00 GMT' -H 'If-None-Match: W/"10ba2401fd96e2e382866a731d207fc4"' http://127.0.0.1:19520/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 200 · 200 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
the date alone (If-Modified-Since):
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' -H 'If-Modified-Since: Tue, 15 Sep 2026 00:00:00 GMT' http://127.0.0.1:19520/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 304 · 0 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 304 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Date: (the time - not printed)
  body: no file - curl wrote none
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19520 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19520 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 6 · devtools — DevTools' two keys; E/F/E′ the chain's cache

Boot's metadata: `spring.web.resources.cache.period` no default, `spring.web.resources.chain.cache` `true`. DevTools on the previous
tree's class path (Keys: 10 keys on this class path, `spring.web.resources.cache.period = 0`, `spring.web.resources.chain.cache =
false`; the environment's period `0`): the stylesheet answers **`Cache-Control: no-store`** — a period of 0 is no-store, not a zero
max-age. DevTools on after/: the environment's period is **`365d`** — `application.yaml`'s key beats DevTools' default (a config file's
key wins: RE-MEASURE 9, settled with `application.yaml` itself) — and the answer keeps `max-age=31536000`. Exit 1 each (DevTools' JVM,
R.109), 35729 free. **E/F/E′** — a folder class path, no DevTools: the stylesheet in the classes folder replaced while TiffinBox runs
(this unit's `cp` line). **E** (Boot's default, the chain's cache on): the page keeps the old name, which now answers **404** — the
file has another md5. **F** (`--spring.web.resources.chain.cache=false`): the page links the new name at once, 200, 224 bytes. **E′** =
E. Why DevTools turns that cache off.

`.r-devtools.out` · md5 `4ad8107ad2700aa417b6f809576f152a` · 3 of 3

```
the keys - Boot's metadata (spring-boot-autoconfigure-4.1.1.jar):
  spring.web.resources.cache.period - type Duration · default null · Cache period for the resources served by the resource handler. If a duration suffix is not specified, seconds will be used. Can be overridden by the 'spring.web.resources.cache.cachecontrol' properties.
  spring.web.resources.chain.cache - type Boolean · default true · Whether to enable caching in the Resource chain.
  spring.web.resources.cache.cachecontrol.no-cache - type Boolean · default null · Indicate that the cached response can be reused only if re-validated with the server.
DevTools on the previous tree - its extracted jar with DevTools' jar (from $M2) and the harness on its class path, Live Reload off, the harness's Keys joined, port 19523:
$ cd .harness/before && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19523 --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Keys
  listens on: 127.0.0.1:19523 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19523/actuator/health/readiness
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
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19523/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 22 lines, 926 bytes - not shown but its stylesheet link <link rel="stylesheet" href="/css/tiffinbox.css">
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19523/css/tiffinbox.css
  curl's line: 200 · 200 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Cache-Control: no-store · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
  the stylesheet's validators and lifetime - Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: none · Cache-Control: no-store
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19523 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 1 · listening on 19523 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
DevTools on after/ - the same line, port 19523:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19523 --spring.devtools.livereload.enabled=false --spring.main.sources=probe.web.Keys
  listens on: 127.0.0.1:19523 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19523/actuator/health/readiness
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
    16 Keys the environment's spring.web.resources.cache.period: 365d
    17 Keys the environment's spring.web.resources.chain.cache: false
    18 Keys the environment's server.servlet.session.persistent: true
  listening on 35729 (Live Reload) now: 0
$ curl -s -D .harness/head.txt -o .harness/body.html -w ' %{http_code} · Content-Type: [%{content_type}]\n' -H 'Accept: text/html' http://127.0.0.1:19523/dashboard
  curl's line: 200 · Content-Type: [text/html;charset=UTF-8] · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Content-Type: text/html;charset=UTF-8 · Content-Language: en-US · Transfer-Encoding: chunked · Date: (the time - not printed)
  the page: <title>Dashboard · TiffinBox</title> · 22 lines, 959 bytes - not shown but its stylesheet link <link rel="stylesheet" href="/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css">
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19523/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 200 · 200 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
  the stylesheet's validators and lifetime - Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Cache-Control: max-age=31536000
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19523 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 1 · listening on 19523 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
a folder class path - after/'s build copied to .harness/fold, the web module's classes folder in place of its jar (this unit's folder line):
E - the resource chain's cache as Boot sets it, port 19524:
$ cd .harness/fold && cp tiffinbox-web/src/main/resources/static/css/tiffinbox.css tiffinbox-web/target/classes/static/css/tiffinbox.css
  exit 0
$ cd .harness/fold && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/classes:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19524
  listens on: 127.0.0.1:19524 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19524/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -H 'Accept: text/html' http://127.0.0.1:19524/dashboard | grep -o '/css/[^"]*'
  /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
$ cd .harness/fold && cp ../../harness/newbuild/tiffinbox.css tiffinbox-web/target/classes/static/css/tiffinbox.css
  exit 0
$ md5 -q .harness/fold/tiffinbox-web/target/classes/static/css/tiffinbox.css
  c10b71bcdaab1872b81fd1f9d1965761
$ curl -s -H 'Accept: text/html' http://127.0.0.1:19524/dashboard | grep -o '/css/[^"]*'
  /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19524/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 404 · 181 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 404 · Content-Disposition: inline;filename=f.txt · Content-Type: application/problem+json · Transfer-Encoding: chunked · Date: (the time - not printed)
  body: {"detail":"No static resource css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css.","instance":"/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css","status":404,"title":"Not Found"}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19524 .harness/fold/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19524 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
F - the chain's cache off for this run (this unit's line), port 19524:
$ cd .harness/fold && cp tiffinbox-web/src/main/resources/static/css/tiffinbox.css tiffinbox-web/target/classes/static/css/tiffinbox.css
  exit 0
$ cd .harness/fold && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/classes:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19524 --spring.web.resources.chain.cache=false
  listens on: 127.0.0.1:19524 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19524/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -H 'Accept: text/html' http://127.0.0.1:19524/dashboard | grep -o '/css/[^"]*'
  /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
$ cd .harness/fold && cp ../../harness/newbuild/tiffinbox.css tiffinbox-web/target/classes/static/css/tiffinbox.css
  exit 0
$ md5 -q .harness/fold/tiffinbox-web/target/classes/static/css/tiffinbox.css
  c10b71bcdaab1872b81fd1f9d1965761
$ curl -s -H 'Accept: text/html' http://127.0.0.1:19524/dashboard | grep -o '/css/[^"]*'
  /css/tiffinbox-c10b71bcdaab1872b81fd1f9d1965761.css
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19524/css/tiffinbox-c10b71bcdaab1872b81fd1f9d1965761.css
  curl's line: 200 · 224 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: (another time - not printed) · ETag: W/"c10b71bcdaab1872b81fd1f9d1965761" · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 224 · Date: (the time - not printed)
  body: 224 bytes · md5 c10b71bcdaab1872b81fd1f9d1965761
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19524 .harness/fold/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19524 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
E' - E again, a fresh JVM, port 19524:
$ cd .harness/fold && cp tiffinbox-web/src/main/resources/static/css/tiffinbox.css tiffinbox-web/target/classes/static/css/tiffinbox.css
  exit 0
$ cd .harness/fold && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/classes:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19524
  listens on: 127.0.0.1:19524 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19524/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -H 'Accept: text/html' http://127.0.0.1:19524/dashboard | grep -o '/css/[^"]*'
  /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
$ cd .harness/fold && cp ../../harness/newbuild/tiffinbox.css tiffinbox-web/target/classes/static/css/tiffinbox.css
  exit 0
$ md5 -q .harness/fold/tiffinbox-web/target/classes/static/css/tiffinbox.css
  c10b71bcdaab1872b81fd1f9d1965761
$ curl -s -H 'Accept: text/html' http://127.0.0.1:19524/dashboard | grep -o '/css/[^"]*'
  /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19524/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 404 · 181 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 404 · Content-Disposition: inline;filename=f.txt · Content-Type: application/problem+json · Transfer-Encoding: chunked · Date: (the time - not printed)
  body: {"detail":"No static resource css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css.","instance":"/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css","status":404,"title":"Not Found"}
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19524 .harness/fold/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19524 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
E' against E, its label aside, line for line the same: yes
$ cd .harness/fold && cp tiffinbox-web/src/main/resources/static/css/tiffinbox.css tiffinbox-web/target/classes/static/css/tiffinbox.css
  exit 0
```

## 7 · exercise — the exercise, run as written, in one shell

`.r-exercise.out` · md5 `b0175b3604d7ad33a01375817b74f8c2` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 8 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
  $ cp harness/newbuild/tiffinbox.css .harness/mine/after/tiffinbox-web/src/main/resources/static/css/tiffinbox.css
  $ printf 'spring.web.resources.chain.strategy.content.enabled: false\n' > .harness/mine/after/tiffinbox-local.yaml
  $ mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 16 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19528 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19528/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && c=$(curl -s -H 'Accept: text/html' http://127.0.0.1:19528/dashboard | grep -o '/css/[^"]*') && if [ "$c" = /css/tiffinbox.css ]; then s=$(curl -s -o ../css.out -w '%{http_code} · %{size_download} bytes' -H 'If-Modified-Since: Tue, 15 Sep 2026 00:00:00 GMT' "http://127.0.0.1:19528$c"); else s=$(curl -s -o ../css.out -w '%{http_code} · %{size_download} bytes' "http://127.0.0.1:19528$c"); fi; ../../../harness/shutdown.sh 19528 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the stylesheet: $c · $s")
  exit 0 · what they printed:
    the stylesheet: /css/tiffinbox.css · 304 · 0 bytes
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19528 now: 0
the solution's 4 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ f=.harness/mine/after/tiffinbox-local.yaml && sed 's/content\.enabled: false/content.enabled: true/' "$f" > "$f.new" && mv "$f.new" "$f"
  $ M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19528 > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19528/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && c=$(curl -s -H 'Accept: text/html' http://127.0.0.1:19528/dashboard | grep -o '/css/[^"]*') && if [ "$c" = /css/tiffinbox.css ]; then s=$(curl -s -o ../css.out -w '%{http_code} · %{size_download} bytes' -H 'If-Modified-Since: Tue, 15 Sep 2026 00:00:00 GMT' "http://127.0.0.1:19528$c"); else s=$(curl -s -o ../css.out -w '%{http_code} · %{size_download} bytes' "http://127.0.0.1:19528$c"); fi; ../../../harness/shutdown.sh 19528 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the stylesheet: $c · $s")
  exit 0 · what they printed:
    the stylesheet: /css/tiffinbox-c10b71bcdaab1872b81fd1f9d1965761.css · 200 · 224 bytes
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19528 now: 0
  the copy's tiffinbox-local.yaml: spring.web.resources.chain.strategy.content.enabled: true · the copy's stylesheet's md5: c10b71bcdaab1872b81fd1f9d1965761
```

## 8 · browser — a real browser, two witnesses for every claim

Four visitors, each a Chrome with a fresh sealed profile, each NetLog 127.0.0.1 only, eleven visits in all; every request seen twice:
in Chrome's own record and in the server's (`Dump`). **1 — the previous tree:** visit 1 fetches the stylesheet (200, `Last-Modified`
only); then the previous tree's new build replaces TiffinBox on the same port (curl confirms it serves the new file: 224 bytes, its
md5) — visit 2 (the address typed again) and visit 3 (a reload): the stylesheet **from Chrome's own cache, nothing sent**, the footer
still `rgb(0, 0, 0)`; the server's record: the page alone, each time — the reload's page request carries `Cache-Control: max-age=0`,
the stylesheet none. **C (labelled) — `no-cache`:** visit 2 asks with `If-Modified-Since` and gets **304 — in Chrome's record and in
the server's log, 0 bytes**; visit 3, on the new build: 304 again, the old colour. **2 — after/:** visit 1 fetches the versioned name;
on after/'s new build, visit 2's page links the new name, Chrome fetches it (200, the server's record names it) and the footer is
`rgb(85, 85, 85)`; visit 3 (a reload): the new name from Chrome's cache, the server asked for the page alone. **D (labelled) — after/
with `no-cache`:** visit 2 sends both validators, `If-Modified-Since` and `If-None-Match`, and gets 200 and the whole file.

`.r-browser.out` · md5 `c1fc64e0dfd77980ed601012caa93af2` · 3 of 3

```
1 the previous tree - no keys - its class path (the README's line), Dump joined (the server's record of every request, whole), port 19527; Chrome headless, a profile of its own, sealed to 127.0.0.1 (its proxy a dead address, every name but 127.0.0.1 unresolvable), its DevTools protocol on 127.0.0.1:19529:
  TiffinBox - .harness/before, port 19527:
$ cd .harness/before && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19527 --spring.main.sources=probe.web.Dump
  listens on: 127.0.0.1:19527 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19527/actuator/health/readiness
  {"status":"UP"} 200
$ "$CHROME" --headless=new --user-data-dir="$PWD/.harness/chrome" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 --host-resolver-rules='MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' --remote-debugging-address=127.0.0.1 --remote-debugging-port=19529 --log-net-log="$PWD/.harness/netlog.json" about:blank
  its profile, .harness/chrome, made fresh for this visitor (it did not exist before this line): yes
  Chrome's DevTools port: 127.0.0.1:19529 · loopback only: yes
visit 1 - the dashboard's address, typed into a new tab:
$ node harness/cdp.mjs 19529 open http://127.0.0.1:19527/dashboard .harness/ev.json
  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard · its stylesheet: /css/tiffinbox.css · its footer, coloured by it: rgb(0, 0, 0)
$ python3 harness/net.py .harness/ev.json 19527
  Chrome's own record (its DevTools protocol) - the requests the tab made to TiffinBox, the site's icon aside: 2
    Document GET /dashboard - from the server: 200 text/html
      the headers Chrome sent that ask about a kept copy: none · its other headers: 14, not shown
      the answer's: none of Cache-Control, ETag, Last-Modified, Content-Length
    Stylesheet GET /css/tiffinbox.css - from the server: 200 text/css
      the headers Chrome sent that ask about a kept copy: none · its other headers: 13, not shown
      the answer's: Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Content-Length: 200
  the site's icon (/favicon.ico) - not listed: TiffinBox has none, and whether Chrome asks for it again is its own call
  the server's record:
    the harness's lines it printed, in order: 46
       1 Dump            > GET /dashboard
       2 Dump            >   Host: 127.0.0.1:19527
       3 Dump            >   Connection: keep-alive
       4 Dump            >   sec-ch-ua: (its brands and their versions: masked)
       5 Dump            >   sec-ch-ua-mobile: ?0
       6 Dump            >   sec-ch-ua-platform: "macOS"
       7 Dump            >   Upgrade-Insecure-Requests: 1
       8 Dump            >   User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
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
      24 Dump            > GET /css/tiffinbox.css
      25 Dump            >   Host: 127.0.0.1:19527
      26 Dump            >   Connection: keep-alive
      27 Dump            >   sec-ch-ua-platform: "macOS"
      28 Dump            >   User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      29 Dump            >   sec-ch-ua: (its brands and their versions: masked)
      30 Dump            >   sec-ch-ua-mobile: ?0
      31 Dump            >   Accept: text/css,*/*;q=0.1
      32 Dump            >   Sec-Fetch-Site: same-origin
      33 Dump            >   Sec-Fetch-Mode: no-cors
      34 Dump            >   Sec-Fetch-Dest: style
      35 Dump            >   Referer: http://127.0.0.1:19527/dashboard
      36 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      37 Dump            >   Accept-Language: en-US,en;q=0.9
      38 Dump            < 200 GET /css/tiffinbox.css
      39 Dump            <   Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT
      40 Dump            <   Accept-Ranges: bytes
      41 Dump            <   Content-Type: text/css
      42 Dump            <   Content-Length: 200
      43 Dump            <   Date: (the time: not printed)
      44 Dump            <   Keep-Alive: timeout=60
      45 Dump            <   Connection: keep-alive
      46 Dump            <   body: 200 bytes
    WARN lines they added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19527 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19527 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  TiffinBox - .harness/before-new - the new build, on the same port, port 19527:
$ cd .harness/before-new && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19527 --spring.main.sources=probe.web.Dump
  listens on: 127.0.0.1:19527 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19527/actuator/health/readiness
  {"status":"UP"} 200
  the new build's stylesheet, asked by curl at the plain name (no validator sent):
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19527/css/tiffinbox.css
  curl's line: 200 · 224 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 224 · Date: (the time - not printed)
  body: 224 bytes · md5 c10b71bcdaab1872b81fd1f9d1965761
visit 2 - the address typed again:
$ node harness/cdp.mjs 19529 again http://127.0.0.1:19527/dashboard .harness/ev.json
  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard · its stylesheet: /css/tiffinbox.css · its footer, coloured by it: rgb(0, 0, 0)
$ python3 harness/net.py .harness/ev.json 19527
  Chrome's own record (its DevTools protocol) - the requests the tab made to TiffinBox, the site's icon aside: 2
    Document GET /dashboard - from the server: 200 text/html
      the headers Chrome sent that ask about a kept copy: none · its other headers: 14, not shown
      the answer's: none of Cache-Control, ETag, Last-Modified, Content-Length
    Stylesheet GET /css/tiffinbox.css - from Chrome's own cache, nothing sent: 200
  the site's icon (/favicon.ico) - not listed: TiffinBox has none, and whether Chrome asks for it again is its own call
  the server's record:
    the harness's lines it printed, in order: 23
       1 Dump            > GET /dashboard
       2 Dump            >   Host: 127.0.0.1:19527
       3 Dump            >   Connection: keep-alive
       4 Dump            >   sec-ch-ua: (its brands and their versions: masked)
       5 Dump            >   sec-ch-ua-mobile: ?0
       6 Dump            >   sec-ch-ua-platform: "macOS"
       7 Dump            >   Upgrade-Insecure-Requests: 1
       8 Dump            >   User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
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
visit 3 - the page reloaded:
$ node harness/cdp.mjs 19529 reload .harness/ev.json
  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard · its stylesheet: /css/tiffinbox.css · its footer, coloured by it: rgb(0, 0, 0)
$ python3 harness/net.py .harness/ev.json 19527
  Chrome's own record (its DevTools protocol) - the requests the tab made to TiffinBox, the site's icon aside: 2
    Document GET /dashboard - from the server: 200 text/html
      the headers Chrome sent that ask about a kept copy: Cache-Control: max-age=0 · its other headers: 14, not shown
      the answer's: none of Cache-Control, ETag, Last-Modified, Content-Length
    Stylesheet GET /css/tiffinbox.css - from Chrome's own cache, nothing sent: 200
  the site's icon (/favicon.ico) - not listed: TiffinBox has none, and whether Chrome asks for it again is its own call
  the server's record:
    the harness's lines it printed, in order: 24
       1 Dump            > GET /dashboard
       2 Dump            >   Host: 127.0.0.1:19527
       3 Dump            >   Connection: keep-alive
       4 Dump            >   Cache-Control: max-age=0
       5 Dump            >   sec-ch-ua: (its brands and their versions: masked)
       6 Dump            >   sec-ch-ua-mobile: ?0
       7 Dump            >   sec-ch-ua-platform: "macOS"
       8 Dump            >   Upgrade-Insecure-Requests: 1
       9 Dump            >   User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      10 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
      11 Dump            >   Sec-Fetch-Site: none
      12 Dump            >   Sec-Fetch-Mode: navigate
      13 Dump            >   Sec-Fetch-User: ?1
      14 Dump            >   Sec-Fetch-Dest: document
      15 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      16 Dump            >   Accept-Language: en-US,en;q=0.9
      17 Dump            < 200 GET /dashboard
      18 Dump            <   Content-Type: text/html;charset=UTF-8
      19 Dump            <   Content-Language: en-US
      20 Dump            <   Transfer-Encoding: chunked
      21 Dump            <   Date: (the time: not printed)
      22 Dump            <   Keep-Alive: timeout=60
      23 Dump            <   Connection: keep-alive
      24 Dump            <   body: 926 bytes
    WARN lines they added: 0 · ERROR lines: 0
$ node harness/cdp.mjs 19529 close
  Chrome exit 0 · listening on 19529 now: 0 · its profile removed
$ python3 harness/netlog.py .harness/netlog.json 19527
  Chrome's NetLog - every address it connected to or tried, its own background requests included: 127.0.0.1 only: yes · ports 19527 among them: yes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19527 .harness/before-new/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19527 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - the previous tree with Cache-Control: no-cache on its static files (this unit's line), a new visitor:
  TiffinBox - .harness/before, port 19527:
$ cd .harness/before && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19527 --spring.main.sources=probe.web.Dump --spring.web.resources.cache.cachecontrol.no-cache=true
  listens on: 127.0.0.1:19527 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19527/actuator/health/readiness
  {"status":"UP"} 200
$ "$CHROME" --headless=new --user-data-dir="$PWD/.harness/chrome" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 --host-resolver-rules='MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' --remote-debugging-address=127.0.0.1 --remote-debugging-port=19529 --log-net-log="$PWD/.harness/netlog.json" about:blank
  its profile, .harness/chrome, made fresh for this visitor (it did not exist before this line): yes
  Chrome's DevTools port: 127.0.0.1:19529 · loopback only: yes
visit 1 - the dashboard's address, typed into a new tab:
$ node harness/cdp.mjs 19529 open http://127.0.0.1:19527/dashboard .harness/ev.json
  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard · its stylesheet: /css/tiffinbox.css · its footer, coloured by it: rgb(0, 0, 0)
$ python3 harness/net.py .harness/ev.json 19527
  Chrome's own record (its DevTools protocol) - the requests the tab made to TiffinBox, the site's icon aside: 2
    Document GET /dashboard - from the server: 200 text/html
      the headers Chrome sent that ask about a kept copy: none · its other headers: 14, not shown
      the answer's: none of Cache-Control, ETag, Last-Modified, Content-Length
    Stylesheet GET /css/tiffinbox.css - from the server: 200 text/css
      the headers Chrome sent that ask about a kept copy: none · its other headers: 13, not shown
      the answer's: Cache-Control: no-cache · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Content-Length: 200
  the site's icon (/favicon.ico) - not listed: TiffinBox has none, and whether Chrome asks for it again is its own call
  the server's record:
    the harness's lines it printed, in order: 47
       1 Dump            > GET /dashboard
       2 Dump            >   Host: 127.0.0.1:19527
       3 Dump            >   Connection: keep-alive
       4 Dump            >   sec-ch-ua: (its brands and their versions: masked)
       5 Dump            >   sec-ch-ua-mobile: ?0
       6 Dump            >   sec-ch-ua-platform: "macOS"
       7 Dump            >   Upgrade-Insecure-Requests: 1
       8 Dump            >   User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
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
      24 Dump            > GET /css/tiffinbox.css
      25 Dump            >   Host: 127.0.0.1:19527
      26 Dump            >   Connection: keep-alive
      27 Dump            >   sec-ch-ua-platform: "macOS"
      28 Dump            >   User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      29 Dump            >   sec-ch-ua: (its brands and their versions: masked)
      30 Dump            >   sec-ch-ua-mobile: ?0
      31 Dump            >   Accept: text/css,*/*;q=0.1
      32 Dump            >   Sec-Fetch-Site: same-origin
      33 Dump            >   Sec-Fetch-Mode: no-cors
      34 Dump            >   Sec-Fetch-Dest: style
      35 Dump            >   Referer: http://127.0.0.1:19527/dashboard
      36 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      37 Dump            >   Accept-Language: en-US,en;q=0.9
      38 Dump            < 200 GET /css/tiffinbox.css
      39 Dump            <   Cache-Control: no-cache
      40 Dump            <   Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT
      41 Dump            <   Accept-Ranges: bytes
      42 Dump            <   Content-Type: text/css
      43 Dump            <   Content-Length: 200
      44 Dump            <   Date: (the time: not printed)
      45 Dump            <   Keep-Alive: timeout=60
      46 Dump            <   Connection: keep-alive
      47 Dump            <   body: 200 bytes
    WARN lines they added: 0 · ERROR lines: 0
visit 2 - the address typed again, the same TiffinBox:
$ node harness/cdp.mjs 19529 again http://127.0.0.1:19527/dashboard .harness/ev.json
  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard · its stylesheet: /css/tiffinbox.css · its footer, coloured by it: rgb(0, 0, 0)
$ python3 harness/net.py .harness/ev.json 19527
  Chrome's own record (its DevTools protocol) - the requests the tab made to TiffinBox, the site's icon aside: 2
    Document GET /dashboard - from the server: 200 text/html
      the headers Chrome sent that ask about a kept copy: none · its other headers: 14, not shown
      the answer's: none of Cache-Control, ETag, Last-Modified, Content-Length
    Stylesheet GET /css/tiffinbox.css - from the server: 304 text/css
      the headers Chrome sent that ask about a kept copy: If-Modified-Since: Tue, 15 Sep 2026 00:00:00 GMT · its other headers: 13, not shown
      the answer's: Cache-Control: no-cache · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT
  the site's icon (/favicon.ico) - not listed: TiffinBox has none, and whether Chrome asks for it again is its own call
  the server's record:
    the harness's lines it printed, in order: 42
       1 Dump            > GET /dashboard
       2 Dump            >   Host: 127.0.0.1:19527
       3 Dump            >   Connection: keep-alive
       4 Dump            >   sec-ch-ua: (its brands and their versions: masked)
       5 Dump            >   sec-ch-ua-mobile: ?0
       6 Dump            >   sec-ch-ua-platform: "macOS"
       7 Dump            >   Upgrade-Insecure-Requests: 1
       8 Dump            >   User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
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
      24 Dump            > GET /css/tiffinbox.css
      25 Dump            >   Host: 127.0.0.1:19527
      26 Dump            >   Connection: keep-alive
      27 Dump            >   sec-ch-ua-platform: "macOS"
      28 Dump            >   User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      29 Dump            >   sec-ch-ua: (its brands and their versions: masked)
      30 Dump            >   sec-ch-ua-mobile: ?0
      31 Dump            >   Accept: text/css,*/*;q=0.1
      32 Dump            >   If-Modified-Since: Tue, 15 Sep 2026 00:00:00 GMT
      33 Dump            >   Sec-Fetch-Site: same-origin
      34 Dump            >   Sec-Fetch-Mode: no-cors
      35 Dump            >   Sec-Fetch-Dest: style
      36 Dump            >   Referer: http://127.0.0.1:19527/dashboard
      37 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      38 Dump            >   Accept-Language: en-US,en;q=0.9
      39 Dump            < 304 GET /css/tiffinbox.css
      40 Dump            <   Cache-Control: no-cache
      41 Dump            <   Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT
      42 Dump            <   body: 0 bytes
    WARN lines they added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19527 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19527 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  TiffinBox - .harness/before-new - the new build, on the same port, port 19527:
$ cd .harness/before-new && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19527 --spring.main.sources=probe.web.Dump --spring.web.resources.cache.cachecontrol.no-cache=true
  listens on: 127.0.0.1:19527 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19527/actuator/health/readiness
  {"status":"UP"} 200
  the new build's stylesheet, asked by curl at the plain name (no validator sent):
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19527/css/tiffinbox.css
  curl's line: 200 · 224 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Cache-Control: no-cache · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 224 · Date: (the time - not printed)
  body: 224 bytes · md5 c10b71bcdaab1872b81fd1f9d1965761
visit 3 - the address typed again:
$ node harness/cdp.mjs 19529 again http://127.0.0.1:19527/dashboard .harness/ev.json
  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard · its stylesheet: /css/tiffinbox.css · its footer, coloured by it: rgb(0, 0, 0)
$ python3 harness/net.py .harness/ev.json 19527
  Chrome's own record (its DevTools protocol) - the requests the tab made to TiffinBox, the site's icon aside: 2
    Document GET /dashboard - from the server: 200 text/html
      the headers Chrome sent that ask about a kept copy: none · its other headers: 14, not shown
      the answer's: none of Cache-Control, ETag, Last-Modified, Content-Length
    Stylesheet GET /css/tiffinbox.css - from the server: 304 text/css
      the headers Chrome sent that ask about a kept copy: If-Modified-Since: Tue, 15 Sep 2026 00:00:00 GMT · its other headers: 13, not shown
      the answer's: Cache-Control: no-cache · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT
  the site's icon (/favicon.ico) - not listed: TiffinBox has none, and whether Chrome asks for it again is its own call
  the server's record:
    the harness's lines it printed, in order: 42
       1 Dump            > GET /dashboard
       2 Dump            >   Host: 127.0.0.1:19527
       3 Dump            >   Connection: keep-alive
       4 Dump            >   sec-ch-ua: (its brands and their versions: masked)
       5 Dump            >   sec-ch-ua-mobile: ?0
       6 Dump            >   sec-ch-ua-platform: "macOS"
       7 Dump            >   Upgrade-Insecure-Requests: 1
       8 Dump            >   User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
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
      24 Dump            > GET /css/tiffinbox.css
      25 Dump            >   Host: 127.0.0.1:19527
      26 Dump            >   Connection: keep-alive
      27 Dump            >   sec-ch-ua-platform: "macOS"
      28 Dump            >   User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      29 Dump            >   sec-ch-ua: (its brands and their versions: masked)
      30 Dump            >   sec-ch-ua-mobile: ?0
      31 Dump            >   Accept: text/css,*/*;q=0.1
      32 Dump            >   If-Modified-Since: Tue, 15 Sep 2026 00:00:00 GMT
      33 Dump            >   Sec-Fetch-Site: same-origin
      34 Dump            >   Sec-Fetch-Mode: no-cors
      35 Dump            >   Sec-Fetch-Dest: style
      36 Dump            >   Referer: http://127.0.0.1:19527/dashboard
      37 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      38 Dump            >   Accept-Language: en-US,en;q=0.9
      39 Dump            < 304 GET /css/tiffinbox.css
      40 Dump            <   Cache-Control: no-cache
      41 Dump            <   Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT
      42 Dump            <   body: 0 bytes
    WARN lines they added: 0 · ERROR lines: 0
$ node harness/cdp.mjs 19529 close
  Chrome exit 0 · listening on 19529 now: 0 · its profile removed
$ python3 harness/netlog.py .harness/netlog.json 19527
  Chrome's NetLog - every address it connected to or tried, its own background requests included: 127.0.0.1 only: yes · ports 19527 among them: yes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19527 .harness/before-new/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19527 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
2 after/ - the keys - the same line as 1, a new visitor:
  TiffinBox - .harness/after, port 19527:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19527 --spring.main.sources=probe.web.Dump
  listens on: 127.0.0.1:19527 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19527/actuator/health/readiness
  {"status":"UP"} 200
$ "$CHROME" --headless=new --user-data-dir="$PWD/.harness/chrome" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 --host-resolver-rules='MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' --remote-debugging-address=127.0.0.1 --remote-debugging-port=19529 --log-net-log="$PWD/.harness/netlog.json" about:blank
  its profile, .harness/chrome, made fresh for this visitor (it did not exist before this line): yes
  Chrome's DevTools port: 127.0.0.1:19529 · loopback only: yes
visit 1 - the dashboard's address, typed into a new tab:
$ node harness/cdp.mjs 19529 open http://127.0.0.1:19527/dashboard .harness/ev.json
  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard · its stylesheet: /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css · its footer, coloured by it: rgb(0, 0, 0)
$ python3 harness/net.py .harness/ev.json 19527
  Chrome's own record (its DevTools protocol) - the requests the tab made to TiffinBox, the site's icon aside: 2
    Document GET /dashboard - from the server: 200 text/html
      the headers Chrome sent that ask about a kept copy: none · its other headers: 14, not shown
      the answer's: none of Cache-Control, ETag, Last-Modified, Content-Length
    Stylesheet GET /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css - from the server: 200 text/css
      the headers Chrome sent that ask about a kept copy: none · its other headers: 13, not shown
      the answer's: Cache-Control: max-age=31536000 · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Content-Length: 200
  the site's icon (/favicon.ico) - not listed: TiffinBox has none, and whether Chrome asks for it again is its own call
  the server's record:
    the harness's lines it printed, in order: 48
       1 Dump            > GET /dashboard
       2 Dump            >   Host: 127.0.0.1:19527
       3 Dump            >   Connection: keep-alive
       4 Dump            >   sec-ch-ua: (its brands and their versions: masked)
       5 Dump            >   sec-ch-ua-mobile: ?0
       6 Dump            >   sec-ch-ua-platform: "macOS"
       7 Dump            >   Upgrade-Insecure-Requests: 1
       8 Dump            >   User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
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
      23 Dump            <   body: 959 bytes
      24 Dump            > GET /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
      25 Dump            >   Host: 127.0.0.1:19527
      26 Dump            >   Connection: keep-alive
      27 Dump            >   sec-ch-ua-platform: "macOS"
      28 Dump            >   User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      29 Dump            >   sec-ch-ua: (its brands and their versions: masked)
      30 Dump            >   sec-ch-ua-mobile: ?0
      31 Dump            >   Accept: text/css,*/*;q=0.1
      32 Dump            >   Sec-Fetch-Site: same-origin
      33 Dump            >   Sec-Fetch-Mode: no-cors
      34 Dump            >   Sec-Fetch-Dest: style
      35 Dump            >   Referer: http://127.0.0.1:19527/dashboard
      36 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      37 Dump            >   Accept-Language: en-US,en;q=0.9
      38 Dump            < 200 GET /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
      39 Dump            <   Cache-Control: max-age=31536000
      40 Dump            <   Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT
      41 Dump            <   ETag: W/"10ba2401fd96e2e382866a731d207fc4"
      42 Dump            <   Accept-Ranges: bytes
      43 Dump            <   Content-Type: text/css
      44 Dump            <   Content-Length: 200
      45 Dump            <   Date: (the time: not printed)
      46 Dump            <   Keep-Alive: timeout=60
      47 Dump            <   Connection: keep-alive
      48 Dump            <   body: 200 bytes
    WARN lines they added: 0 · ERROR lines: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19527 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19527 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  TiffinBox - .harness/after-new - the new build, on the same port, port 19527:
$ cd .harness/after-new && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19527 --spring.main.sources=probe.web.Dump
  listens on: 127.0.0.1:19527 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19527/actuator/health/readiness
  {"status":"UP"} 200
  the new build's stylesheet, asked by curl at the plain name (no validator sent):
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19527/css/tiffinbox.css
  curl's line: 200 · 224 bytes · WARN lines it added: 0 · ERROR lines: 0
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 224 · Date: (the time - not printed)
  body: 224 bytes · md5 c10b71bcdaab1872b81fd1f9d1965761
visit 2 - the address typed again:
$ node harness/cdp.mjs 19529 again http://127.0.0.1:19527/dashboard .harness/ev.json
  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard · its stylesheet: /css/tiffinbox-c10b71bcdaab1872b81fd1f9d1965761.css · its footer, coloured by it: rgb(85, 85, 85)
$ python3 harness/net.py .harness/ev.json 19527
  Chrome's own record (its DevTools protocol) - the requests the tab made to TiffinBox, the site's icon aside: 2
    Document GET /dashboard - from the server: 200 text/html
      the headers Chrome sent that ask about a kept copy: none · its other headers: 14, not shown
      the answer's: none of Cache-Control, ETag, Last-Modified, Content-Length
    Stylesheet GET /css/tiffinbox-c10b71bcdaab1872b81fd1f9d1965761.css - from the server: 200 text/css
      the headers Chrome sent that ask about a kept copy: none · its other headers: 13, not shown
      the answer's: Cache-Control: max-age=31536000 · ETag: W/"c10b71bcdaab1872b81fd1f9d1965761" · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Content-Length: 224
  the site's icon (/favicon.ico) - not listed: TiffinBox has none, and whether Chrome asks for it again is its own call
  the server's record:
    the harness's lines it printed, in order: 48
       1 Dump            > GET /dashboard
       2 Dump            >   Host: 127.0.0.1:19527
       3 Dump            >   Connection: keep-alive
       4 Dump            >   sec-ch-ua: (its brands and their versions: masked)
       5 Dump            >   sec-ch-ua-mobile: ?0
       6 Dump            >   sec-ch-ua-platform: "macOS"
       7 Dump            >   Upgrade-Insecure-Requests: 1
       8 Dump            >   User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
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
      23 Dump            <   body: 959 bytes
      24 Dump            > GET /css/tiffinbox-c10b71bcdaab1872b81fd1f9d1965761.css
      25 Dump            >   Host: 127.0.0.1:19527
      26 Dump            >   Connection: keep-alive
      27 Dump            >   sec-ch-ua-platform: "macOS"
      28 Dump            >   User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      29 Dump            >   sec-ch-ua: (its brands and their versions: masked)
      30 Dump            >   sec-ch-ua-mobile: ?0
      31 Dump            >   Accept: text/css,*/*;q=0.1
      32 Dump            >   Sec-Fetch-Site: same-origin
      33 Dump            >   Sec-Fetch-Mode: no-cors
      34 Dump            >   Sec-Fetch-Dest: style
      35 Dump            >   Referer: http://127.0.0.1:19527/dashboard
      36 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      37 Dump            >   Accept-Language: en-US,en;q=0.9
      38 Dump            < 200 GET /css/tiffinbox-c10b71bcdaab1872b81fd1f9d1965761.css
      39 Dump            <   Cache-Control: max-age=31536000
      40 Dump            <   Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT
      41 Dump            <   ETag: W/"c10b71bcdaab1872b81fd1f9d1965761"
      42 Dump            <   Accept-Ranges: bytes
      43 Dump            <   Content-Type: text/css
      44 Dump            <   Content-Length: 224
      45 Dump            <   Date: (the time: not printed)
      46 Dump            <   Keep-Alive: timeout=60
      47 Dump            <   Connection: keep-alive
      48 Dump            <   body: 224 bytes
    WARN lines they added: 0 · ERROR lines: 0
visit 3 - the page reloaded:
$ node harness/cdp.mjs 19529 reload .harness/ev.json
  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard · its stylesheet: /css/tiffinbox-c10b71bcdaab1872b81fd1f9d1965761.css · its footer, coloured by it: rgb(85, 85, 85)
$ python3 harness/net.py .harness/ev.json 19527
  Chrome's own record (its DevTools protocol) - the requests the tab made to TiffinBox, the site's icon aside: 2
    Document GET /dashboard - from the server: 200 text/html
      the headers Chrome sent that ask about a kept copy: Cache-Control: max-age=0 · its other headers: 14, not shown
      the answer's: none of Cache-Control, ETag, Last-Modified, Content-Length
    Stylesheet GET /css/tiffinbox-c10b71bcdaab1872b81fd1f9d1965761.css - from Chrome's own cache, nothing sent: 200
  the site's icon (/favicon.ico) - not listed: TiffinBox has none, and whether Chrome asks for it again is its own call
  the server's record:
    the harness's lines it printed, in order: 24
       1 Dump            > GET /dashboard
       2 Dump            >   Host: 127.0.0.1:19527
       3 Dump            >   Connection: keep-alive
       4 Dump            >   Cache-Control: max-age=0
       5 Dump            >   sec-ch-ua: (its brands and their versions: masked)
       6 Dump            >   sec-ch-ua-mobile: ?0
       7 Dump            >   sec-ch-ua-platform: "macOS"
       8 Dump            >   Upgrade-Insecure-Requests: 1
       9 Dump            >   User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      10 Dump            >   Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/jxl,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
      11 Dump            >   Sec-Fetch-Site: none
      12 Dump            >   Sec-Fetch-Mode: navigate
      13 Dump            >   Sec-Fetch-User: ?1
      14 Dump            >   Sec-Fetch-Dest: document
      15 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      16 Dump            >   Accept-Language: en-US,en;q=0.9
      17 Dump            < 200 GET /dashboard
      18 Dump            <   Content-Type: text/html;charset=UTF-8
      19 Dump            <   Content-Language: en-US
      20 Dump            <   Transfer-Encoding: chunked
      21 Dump            <   Date: (the time: not printed)
      22 Dump            <   Keep-Alive: timeout=60
      23 Dump            <   Connection: keep-alive
      24 Dump            <   body: 959 bytes
    WARN lines they added: 0 · ERROR lines: 0
$ node harness/cdp.mjs 19529 close
  Chrome exit 0 · listening on 19529 now: 0 · its profile removed
$ python3 harness/netlog.py .harness/netlog.json 19527
  Chrome's NetLog - every address it connected to or tried, its own background requests included: 127.0.0.1 only: yes · ports 19527 among them: yes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19527 .harness/after-new/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19527 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
D (labelled) - after/ with Cache-Control: no-cache (this unit's line), a new visitor:
  TiffinBox - .harness/after, port 19527:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19527 --spring.main.sources=probe.web.Dump --spring.web.resources.cache.cachecontrol.no-cache=true
  listens on: 127.0.0.1:19527 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19527/actuator/health/readiness
  {"status":"UP"} 200
$ "$CHROME" --headless=new --user-data-dir="$PWD/.harness/chrome" --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-domain-reliability --use-mock-keychain --password-store=basic --lang=en-US --proxy-server=http://127.0.0.1:9 --host-resolver-rules='MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' --remote-debugging-address=127.0.0.1 --remote-debugging-port=19529 --log-net-log="$PWD/.harness/netlog.json" about:blank
  its profile, .harness/chrome, made fresh for this visitor (it did not exist before this line): yes
  Chrome's DevTools port: 127.0.0.1:19529 · loopback only: yes
visit 1 - the dashboard's address, typed into a new tab:
$ node harness/cdp.mjs 19529 open http://127.0.0.1:19527/dashboard .harness/ev.json
  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard · its stylesheet: /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css · its footer, coloured by it: rgb(0, 0, 0)
$ python3 harness/net.py .harness/ev.json 19527
  Chrome's own record (its DevTools protocol) - the requests the tab made to TiffinBox, the site's icon aside: 2
    Document GET /dashboard - from the server: 200 text/html
      the headers Chrome sent that ask about a kept copy: none · its other headers: 14, not shown
      the answer's: none of Cache-Control, ETag, Last-Modified, Content-Length
    Stylesheet GET /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css - from the server: 200 text/css
      the headers Chrome sent that ask about a kept copy: none · its other headers: 13, not shown
      the answer's: Cache-Control: no-cache · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Content-Length: 200
  the site's icon (/favicon.ico) - not listed: TiffinBox has none, and whether Chrome asks for it again is its own call
  the server's record:
    the harness's lines it printed, in order: 48
       1 Dump            > GET /dashboard
       2 Dump            >   Host: 127.0.0.1:19527
       3 Dump            >   Connection: keep-alive
       4 Dump            >   sec-ch-ua: (its brands and their versions: masked)
       5 Dump            >   sec-ch-ua-mobile: ?0
       6 Dump            >   sec-ch-ua-platform: "macOS"
       7 Dump            >   Upgrade-Insecure-Requests: 1
       8 Dump            >   User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
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
      23 Dump            <   body: 959 bytes
      24 Dump            > GET /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
      25 Dump            >   Host: 127.0.0.1:19527
      26 Dump            >   Connection: keep-alive
      27 Dump            >   sec-ch-ua-platform: "macOS"
      28 Dump            >   User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      29 Dump            >   sec-ch-ua: (its brands and their versions: masked)
      30 Dump            >   sec-ch-ua-mobile: ?0
      31 Dump            >   Accept: text/css,*/*;q=0.1
      32 Dump            >   Sec-Fetch-Site: same-origin
      33 Dump            >   Sec-Fetch-Mode: no-cors
      34 Dump            >   Sec-Fetch-Dest: style
      35 Dump            >   Referer: http://127.0.0.1:19527/dashboard
      36 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      37 Dump            >   Accept-Language: en-US,en;q=0.9
      38 Dump            < 200 GET /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
      39 Dump            <   Cache-Control: no-cache
      40 Dump            <   Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT
      41 Dump            <   ETag: W/"10ba2401fd96e2e382866a731d207fc4"
      42 Dump            <   Accept-Ranges: bytes
      43 Dump            <   Content-Type: text/css
      44 Dump            <   Content-Length: 200
      45 Dump            <   Date: (the time: not printed)
      46 Dump            <   Keep-Alive: timeout=60
      47 Dump            <   Connection: keep-alive
      48 Dump            <   body: 200 bytes
    WARN lines they added: 0 · ERROR lines: 0
visit 2 - the address typed again, the same TiffinBox:
$ node harness/cdp.mjs 19529 again http://127.0.0.1:19527/dashboard .harness/ev.json
  the page Chrome shows: Dashboard · TiffinBox · its address: /dashboard · its stylesheet: /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css · its footer, coloured by it: rgb(0, 0, 0)
$ python3 harness/net.py .harness/ev.json 19527
  Chrome's own record (its DevTools protocol) - the requests the tab made to TiffinBox, the site's icon aside: 2
    Document GET /dashboard - from the server: 200 text/html
      the headers Chrome sent that ask about a kept copy: none · its other headers: 14, not shown
      the answer's: none of Cache-Control, ETag, Last-Modified, Content-Length
    Stylesheet GET /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css - from the server: 200 text/css
      the headers Chrome sent that ask about a kept copy: If-Modified-Since: Tue, 15 Sep 2026 00:00:00 GMT · If-None-Match: W/"10ba2401fd96e2e382866a731d207fc4" · its other headers: 13, not shown
      the answer's: Cache-Control: no-cache · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Content-Length: 200
  the site's icon (/favicon.ico) - not listed: TiffinBox has none, and whether Chrome asks for it again is its own call
  the server's record:
    the harness's lines it printed, in order: 50
       1 Dump            > GET /dashboard
       2 Dump            >   Host: 127.0.0.1:19527
       3 Dump            >   Connection: keep-alive
       4 Dump            >   sec-ch-ua: (its brands and their versions: masked)
       5 Dump            >   sec-ch-ua-mobile: ?0
       6 Dump            >   sec-ch-ua-platform: "macOS"
       7 Dump            >   Upgrade-Insecure-Requests: 1
       8 Dump            >   User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
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
      23 Dump            <   body: 959 bytes
      24 Dump            > GET /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
      25 Dump            >   Host: 127.0.0.1:19527
      26 Dump            >   Connection: keep-alive
      27 Dump            >   sec-ch-ua-platform: "macOS"
      28 Dump            >   User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/<version> Safari/537.36
      29 Dump            >   sec-ch-ua: (its brands and their versions: masked)
      30 Dump            >   sec-ch-ua-mobile: ?0
      31 Dump            >   Accept: text/css,*/*;q=0.1
      32 Dump            >   If-None-Match: W/"10ba2401fd96e2e382866a731d207fc4"
      33 Dump            >   If-Modified-Since: Tue, 15 Sep 2026 00:00:00 GMT
      34 Dump            >   Sec-Fetch-Site: same-origin
      35 Dump            >   Sec-Fetch-Mode: no-cors
      36 Dump            >   Sec-Fetch-Dest: style
      37 Dump            >   Referer: http://127.0.0.1:19527/dashboard
      38 Dump            >   Accept-Encoding: gzip, deflate, br, zstd
      39 Dump            >   Accept-Language: en-US,en;q=0.9
      40 Dump            < 200 GET /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
      41 Dump            <   Cache-Control: no-cache
      42 Dump            <   Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT
      43 Dump            <   ETag: W/"10ba2401fd96e2e382866a731d207fc4"
      44 Dump            <   Accept-Ranges: bytes
      45 Dump            <   Content-Type: text/css
      46 Dump            <   Content-Length: 200
      47 Dump            <   Date: (the time: not printed)
      48 Dump            <   Keep-Alive: timeout=60
      49 Dump            <   Connection: keep-alive
      50 Dump            <   body: 200 bytes
    WARN lines they added: 0 · ERROR lines: 0
$ node harness/cdp.mjs 19529 close
  Chrome exit 0 · listening on 19529 now: 0 · its profile removed
$ python3 harness/netlog.py .harness/netlog.json 19527
  Chrome's NetLog - every address it connected to or tried, its own background requests included: 127.0.0.1 only: yes · ports 19527 among them: yes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19527 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19527 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 9 · forms — every form serves the versioned stylesheet (⚑7, R.103)

The native build of after/ (8 of 8 stages, offline, Mach-O, 0 tokens); Spring's AOT metadata against the previous tree's: 687 → 690
reflection entries, the three new ones the resource chain's configuration (`WebMvcAutoConfiguration$ResourceChainCustomizerConfiguration`,
`$ResourceChainResourceHandlerRegistrationCustomizer`, `$ResourceHandlerRegistrationCustomizer`) — classes only the keys switch on.
Then the jar, the AOT jar, the binary and the image: each one's address (loopback; the image published on 127.0.0.1 alone), the seven
`466c20ed…`, and on a second start the page's link (the anchor's own line), the versioned stylesheet, and asked by the POM's date and by
its ETag. **RE-MEASURE 11, settled:** all four link the versioned name and answer it with the year and the ETag; the ETag gets 200 in all
four. **The binary's `Last-Modified` is not the POM's time:** it is a time inside this run's own native build (between the native step's
start and end, read off the clock, never printed), so the POM's date gets **200** there — the jar, the AOT jar and the image answer it
304.

`.r-forms.out` · md5 `d251cfdbeedcd05325ff593fd208722e` · 3 of 3

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
  Spring's generated metadata (spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json) - the previous tree's against after/'s: reflection entries 687 -> 690 · types only the previous tree registers: none · only after/: 3 · entries that differ: 0
    only after/: org.springframework.boot.webmvc.autoconfigure.WebMvcAutoConfiguration$ResourceChainCustomizerConfiguration - 0 methods
    only after/: org.springframework.boot.webmvc.autoconfigure.WebMvcAutoConfiguration$ResourceChainResourceHandlerRegistrationCustomizer - 0 methods
    only after/: org.springframework.boot.webmvc.autoconfigure.WebMvcAutoConfiguration$ResourceHandlerRegistrationCustomizer - 0 methods
    only after/, the rest: 0 (not named)
  resource entries: 30 -> 30 · only after/: none
1 the jar - .harness/after, the README's run line, port 19520:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19520
  listens on: 127.0.0.1:19520 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19520/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19520 (http) with context path '/'
$ $CURLSET 19520 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the stylesheet, on a second start of the jar:
$ cd .harness/after && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19520
  listens on: 127.0.0.1:19520 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19520/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -H 'Accept: text/html' http://127.0.0.1:19520/dashboard | grep -o '/css/[^"]*'
  /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19520/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 200 · 200 bytes
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' -H 'If-Modified-Since: Tue, 15 Sep 2026 00:00:00 GMT' http://127.0.0.1:19520/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 304 · 0 bytes
  HTTP/1.1 304 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Date: (the time - not printed)
  body: no file - curl wrote none
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' -H 'If-None-Match: W/"10ba2401fd96e2e382866a731d207fc4"' http://127.0.0.1:19520/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 200 · 200 bytes
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
  this form's answers: the link carries the file's md5: yes · Cache-Control: max-age=31536000 · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Last-Modified: the root POM's time · asked with the root POM's time: 304 · asked with its ETag: 200
$ harness/shutdown.sh 19520 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19520 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19525:
$ cd .harness/nat && java -Duser.language=en -Duser.country=US -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19525
  listens on: 127.0.0.1:19525 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19525/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19525 (http) with context path '/'
$ $CURLSET 19525 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the stylesheet, on a second start of the AOT jar:
$ cd .harness/nat && java -Duser.language=en -Duser.country=US -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19525
  listens on: 127.0.0.1:19525 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19525/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -H 'Accept: text/html' http://127.0.0.1:19525/dashboard | grep -o '/css/[^"]*'
  /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19525/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 200 · 200 bytes
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' -H 'If-Modified-Since: Tue, 15 Sep 2026 00:00:00 GMT' http://127.0.0.1:19525/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 304 · 0 bytes
  HTTP/1.1 304 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Date: (the time - not printed)
  body: no file - curl wrote none
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' -H 'If-None-Match: W/"10ba2401fd96e2e382866a731d207fc4"' http://127.0.0.1:19525/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 200 · 200 bytes
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
  this form's answers: the link carries the file's md5: yes · Cache-Control: max-age=31536000 · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Last-Modified: the root POM's time · asked with the root POM's time: 304 · asked with its ETag: 200
$ harness/shutdown.sh 19525 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19525 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
3 the binary - .harness/nat, the README's line, port 19526:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19526
  listens on: 127.0.0.1:19526 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19526/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19526 (http) with context path '/'
$ $CURLSET 19526 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  then the stylesheet, on a second start of the binary:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19526
  listens on: 127.0.0.1:19526 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19526/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -H 'Accept: text/html' http://127.0.0.1:19526/dashboard | grep -o '/css/[^"]*'
  /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19526/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 200 · 200 bytes
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: (another time - not printed) · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' -H 'If-Modified-Since: Tue, 15 Sep 2026 00:00:00 GMT' http://127.0.0.1:19526/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 200 · 200 bytes
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: (another time - not printed) · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' -H 'If-None-Match: W/"10ba2401fd96e2e382866a731d207fc4"' http://127.0.0.1:19526/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 200 · 200 bytes
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: (another time - not printed) · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
  this form's answers: the link carries the file's md5: yes · Cache-Control: max-age=31536000 · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Last-Modified: a time inside this run's native build · asked with the root POM's time: 200 · asked with its ETag: 200
$ harness/shutdown.sh 19526 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19526 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
4 the image - after/'s Dockerfile (the README's build line, this script's tag), the README's run line with your user, published on 127.0.0.1:19524:
$ cd .harness/after && docker build --progress=plain -t tiffinbox-static:1.0.0 .
  exit 0 · its lines, through the filter:
    [internal] load metadata for docker.io/library/eclipse-temurin:25-jre
    [builder 1/4] FROM docker.io/library/eclipse-temurin:25-jre@sha256:fcd7fd7b387f94bb2ac461478a7436ad8e349924c374ea8313919624dceae636
    naming to docker.io/library/tiffinbox-static:1.0.0
  its lines that say pull: 0 · its other lines: fewer than 300, not shown
  the image saved (docker save): 15 blobs, its 11 layers among them, each read whole (gzip ones unpacked) · the demo token in them: 0
$ cd .harness/after && docker run -d --name tiffinbox-static --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19524:18425 tiffinbox-static:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19524/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19524
  on this Mac, listening on port 19524: 127.0.0.1:19524
$ $CURLSET 19524 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
$ docker wait tiffinbox-static
  0
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log (docker logs): Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1 · the demo token 0 times · X-Shutdown-Token 0 times
  then the stylesheet, on a second container of the image - TiffinBox listens on 18425 inside it:
$ cd .harness/after && docker run -d --name tiffinbox-static --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19524:18425 tiffinbox-static:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19524/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19524
  on this Mac, listening on port 19524: 127.0.0.1:19524
$ curl -s -H 'Accept: text/html' http://127.0.0.1:19524/dashboard | grep -o '/css/[^"]*'
  /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' http://127.0.0.1:19524/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 200 · 200 bytes
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' -H 'If-Modified-Since: Tue, 15 Sep 2026 00:00:00 GMT' http://127.0.0.1:19524/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 304 · 0 bytes
  HTTP/1.1 304 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · Date: (the time - not printed)
  body: no file - curl wrote none
$ curl -s -D .harness/head.txt -o .harness/body.out -w ' %{http_code} · %{size_download} bytes\n' -H 'If-None-Match: W/"10ba2401fd96e2e382866a731d207fc4"' http://127.0.0.1:19524/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  curl's line: 200 · 200 bytes
  HTTP/1.1 200 · Cache-Control: max-age=31536000 · Last-Modified: Tue, 15 Sep 2026 00:00:00 GMT · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Accept-Ranges: bytes · Content-Type: text/css · Content-Length: 200 · Date: (the time - not printed)
  body: 200 bytes · md5 10ba2401fd96e2e382866a731d207fc4
  this form's answers: the link carries the file's md5: yes · Cache-Control: max-age=31536000 · ETag: W/"10ba2401fd96e2e382866a731d207fc4" · Last-Modified: the root POM's time · asked with the root POM's time: 304 · asked with its ETag: 200
$ harness/shutdown.sh 19524 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
$ docker wait tiffinbox-static
  0
  exit 0 · its log (docker logs): the demo token 0 times · X-Shutdown-Token 0 times · WARN lines: 0 · ERROR lines: 0
four forms, one tree: the seven (masked) 4 of 4 times 466c20ed7e0d5439cb052f32ce09de1b · the link with the file's md5, a year's lifetime and its ETag: 4 of 4 · Last-Modified the root POM's time: 3 of 4 · asked with that time, 304: 3 of 4 · asked with its ETag, 200: 4 of 4
  loopback, form by form: the jar yes · the AOT jar yes · the binary yes · the image, published on 127.0.0.1 alone yes
  the locale: options on the binary's and the image's run lines: 0 (none passed: the binary runs as the README writes it, the image as its ENTRYPOINT, java -jar)
```

## Exercise

**Your turn:** the README's new stylesheet still gets three oh four. Switch on content versioning, read the page's link, and ask again.
`exercise/README.md` has the commands (copy `after/`, put the harness's new stylesheet in the copy, write the copy a `tiffinbox-local.yaml`
that switches the strategy off, give the copy a token of its own); its last line, in a subshell, builds the copy offline, starts it on
19528 from the copy's folder, reads the page's link, asks for it as a browser that kept the old build's stylesheet would — the kept
link with the kept date, any other link plainly — stops it, waits for its JVM and prints — as shipped — `the stylesheet:
/css/tiffinbox.css · 304 · 0 bytes`. Done is `the stylesheet: /css/tiffinbox-c10b71bcdaab1872b81fd1f9d1965761.css · 200 · 224 bytes`.
Measured answer: `exercise/solution/SOLUTION.md` (the README's two `export` lines, the line that makes the local file's `false` `true` —
idempotent — and the README's last line again), run in the same shell. Run `./receipts.sh` once first on a fresh clone.

## The anchor's README — what this unit changed in it

`../c6-tiffinbox/README.md` (= `after/README.md`) gains its `## Course 6 · unit 23` section (after unit 22's, before Course 5's README
begins) with the anchor's two new lines — the page's stylesheet link (`curl … | grep -o '/css/[^"]*'`) and the versioned stylesheet's
headers — and **one history note amended in place**, found by grepping the README for `css`, `stylesheet`, `static`, `Cache-Control`,
`max-age`, `ETag`, `Last-Modified`, `304`, `first document`, `line N` and `---` (S2.22, S4.11), each hit read:
- the problem-detail section's "one key in the first document (line 64, above the `---` at 99)" → the `---` is at 115 since.

Left as they were, and still true (each read): the reproducible-build section's fixed build time (every archive entry stamped with it —
this unit adds what that means for `Last-Modified`, in its own section); the embedded-Tomcat section's "a file in `static/` there answers
200" (the plain name still answers, `versioned` A); the serving section's stylesheet and `static/**` resources (unchanged files; the binary
serves the stylesheet, `forms`); every `/nowhere` 404 (`No static resource nowhere.` — the seven unchanged).
`c6-tiffinbox/README.md`: lines added and removed against the previous tree's in `change`.

## The ledger rows and hand-offs this unit pays

| Row | Paid how | Where |
|---|---|---|
| **C6-18** static resources (Course 5's DevTools defaults) | `spring.web.resources.cache.period` (0 → `no-store`; `application.yaml`'s `365d` wins) and `spring.web.resources.chain.cache` (false; by effect, E/F/E′) — read off the environment and shown against the shipped keys | `devtools` |
| the roadmap's "versioned URLs; a 304" | the versioned link and its year (A/B/A′); the 304 by date (`headers`, `date`, B); a real 304 in Chrome's record and the server's log (C) — "in the network tab" sharpened: Chrome's own record (⚑8) | `versioned`, `date`, `browser` |
| **C6-31**'s U23 flag | no developer-tools panel: Chrome's own record named; every new term glossed (static resource, validator, 304, cache lifetime, versioned URL, ETag) | the script |
| S3 CARRIED: DevTools' two resource defaults | settled above | `devtools` |

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-22) |
|---|---|---|---|
| 8 | 23's image | never run | **the image: the seven `466c20ed…`, the versioned link, the year, the ETag; published on 127.0.0.1 alone, 0 tokens in its 11 layers** (`forms`) |
| 9 | DevTools' `cache.period = 0` against `application.yaml`'s `365d` | a config file's key won (`tiffinbox-local.yaml`) | **`application.yaml`'s key wins too: the environment reads `365d`, the answer `max-age=31536000`; on a tree without it DevTools' `0` is `no-store`** (`devtools`) |
| 10 | B as a flag off on 23/after; the new-build tree | two trees, keys passed | **B on after/ with the keys: the plain link on both builds, the new build 304 for the old date; the new builds made from `harness/newbuild/tiffinbox.css`** (`versioned`) |
| 11 | the versioned link and headers from the binary | build 4 of the sketch | **the binary links the versioned name, `max-age=31536000`, the ETag — and its `Last-Modified` is its own build's time: the POM's date gets 200 there** (`forms`) |
| 14 | the exercise as viewers run it | end states on sketches | **one `env -i` shell: 304, 0 bytes, then the new name, 200, 224 bytes** (`exercise`, and below) |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **The binary's `Last-Modified` is its own** (brief and R.122: "the POM's `project.build.outputTimestamp`"): true for the jar, the AOT
  jar and the image; in the native binary the stylesheet's `Last-Modified` is a time inside its own native build, so the POM's date gets
  200 there (`forms`). R.122 holds for a packaged jar; a binary is said apart.
- **DevTools' period of 0 is `Cache-Control: no-store`** (brief: "cache.period=0"): read off the answer (`devtools`).
- **The chain's cache, by effect** (brief: "read off the environment"): with it on, a stylesheet replaced while TiffinBox runs keeps its
  old name in the page — and that name answers 404 (E/F/E′).
- **The old versioned name answers 404 on the new build** (not in the brief): no file has that content there. A page is never kept (no
  validator, no lifetime), so a browser meets the new link at once (`browser` 2).
- **The plain name keeps the year's lifetime** (brief: "the plain URL still answers 200"): it does, with `Cache-Control:
  max-age=31536000` and no ETag — a page that linked it would be stale for a year.
- **`paths: /**` is Boot's own default** (brief ⚑4 lists it as a key): kept, written down, said so in the YAML's comment.
- **Chrome kept the old stylesheet across a reload too** (brief: "on a revisit and on reload"): measured with the new build in place —
  the reload re-asked for the page alone (`Cache-Control: max-age=0`), the stylesheet from Chrome's cache.

## Found on the way

- **Every new check fails on a planted fault first** (R.65, S4.10): the checks block runs alone — `receipts.sh` with no build and no
  capture, `cap()` doing nothing — on the published captures with one thing changed per plant (`plants.py`, this unit's scratch folder):
  **60 plants, 60 stops under /bin/bash 3.2 and 60 under bash 5.3**, each
  naming its own check (the same 60 lines under both). Forty-eight change one line of a capture (the files byte for byte, the YAML's
  period, the first `---` above the keys, the strategy's default, the libraries, the new stylesheet's bytes; the seven's md5 and their
  sameness, a `Cache-Control` on the plain answer, an ETag on the page, a 304's body counted from a file, PageNotFound's WARN; the jar's
  entry dates, the POM's time, the new build's 304; the link's md5, the new name, the year's max-age, the old name's 404, B's plain link
  and its 304, A′, B's `$` line; the ETag's 200 and the plain answer's, the resource handler's row, the date's 304; DevTools' key count,
  `no-store`, `365d`, its exit 1, E's 404, F's new name, 35729; the exercise's two lines and its ERROR count; Chrome's cache on the new
  build, the seal, C's 304, the fresh profile, the new colour, D's two validators; the forms' summary, the binary's own date, its
  loopback, the AOT count); four plant a hygiene fault in a capture (an absolute path, a machine date, Chrome's version, an unpinned java
  line); eight change a shipped file (the spoken exercise line, a bare `wait` in the solution, a stop by name in `cdp.mjs`, the raw token
  in `net.py`, Boot 3's error key in this README, the harness named in after/'s code, a second line in the new stylesheet, the `/css/`
  skip put back in `Dump`). The unplanted copies pass, before and after; every file is restored byte for byte (md5). Three of the plants
  first went uncaught — a plant on the plain answer of the ETag capture, one on its `If-None-Match` answer that hit the plain line, and
  `no-store` in the header line (only the `vals` line was asserted): two checks were added (the plain answer's status and ETag, the
  header line whole) and the plants made exact.
- **Two of this script's own faults, caught before the runs of record:** a `case` written inside `$( … )` in a double-quoted string
  printed its own source (bash read the pattern's `)` as the substitution's end) — now a function, `carries()`; and a folder class
  path's stylesheet answered `Last-Modified` with the file's time on disk, which no hash survives — `hall` prints the build's fixed time
  and masks any other (planted: a filter check).
- **The exercise as viewers run it**, beyond the capture: README then SOLUTION, then SOLUTION again, in one `env -i` `zsh -f` shell →
  `the stylesheet: /css/tiffinbox.css · 304 · 0 bytes`, then the new name `· 200 · 224 bytes` twice, each exit 0, the shell left in
  `c6-unit23/`, the local file's key switched once (one line, `true`); the README's last line alone in an `env -i` `/bin/bash` shell
  without the exports — its `java` 23 — ends with `exit 1` and prints no line (its Maven build fails under 23, so no JVM starts); 19528
  free after each.
- **`lmwhere` can say all three**: run alone with a window of the next five minutes, it called the POM's date "the root POM's time", a
  date ten seconds into the window "a time inside this run's native build" and one a hundred seconds before it "another time".
- **The probe's sketch and this tree agree** where they overlap (S4 notes Step 7, Step 9, Step 10): the plain answer's headers and the
  304, the same date on a changed file, the versioned link and its year, the ETag's 200s by curl and in Chrome, Chrome's cache with no
  lifetime and on reload, the 304 with `no-cache`, a config file's key over DevTools' default — each now a line of this unit's captures.
  Where they part: the binary's date (the sketch never printed it), DevTools' `no-store` (the sketch never asked), the chain's cache and
  the old name's 404 (never measured there).
- **Chrome asked for `/favicon.ico`** on a fresh visit (seen in scratch; `Dump` and `net.py` skip it on purpose — TiffinBox has none, and
  how often Chrome asks again is its own call).

## For unit 24 — and RED

- **Read `../c6-unit23/after`** (= `../c6-tiffinbox` now): `application.yaml`'s first document ends at line 115 (24 adds
  `server.servlet.session.tracking-modes` there: re-count, R.87); the dashboard links `/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css`
  — a change to `dashboard.html` does not move it, a change to the stylesheet does; the page is 959 bytes (22 lines) with the versioned
  link.
- **The seven** stay `466c20ed7e0d5439cb052f32ce09de1b`; the routing table 19 rows.
- **Chrome:** 155.0.8059.85; `cdp.mjs` here keeps one tab (`open`, `again`, `reload`) — 24's cookie visits need the same tab or the same
  profile; `Dump` here prints the stylesheet's requests.
- **RED:** re-run the sealed clone, both bashes, SIGINT during a JVM, Chrome and the native build; the binary's `Last-Modified`
  (`lmwhere`'s window is the native step's start and end; outside it the function says "another time" — "Found on the way"); Chrome's heuristic for a
  date 37 days old (a much later run moves the date's age, not its outcome while the heuristic lifetime stays above the run's minutes).
- **Ports** 19520-19529 are this unit's; 24 has 19530-19539. The image `tiffinbox-static:1.0.0` / container `tiffinbox-static` are this
  unit's names.
