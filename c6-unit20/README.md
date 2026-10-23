# c6-unit20 — File Upload and Download

Course 6 · Spring Web MVC · Section 4 (The Rest of MVC), its third unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot
4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5), curl 8.7.1, 2026-10-22. The kitchen sends its weekly menu as a file, and
every customer wants a bill to keep. This unit takes a file in — a **multipart request**, read by Spring MVC as a `MultipartFile` —
finds the size where TiffinBox says no (Boot's limits, read off Boot's own metadata and off the bean Boot built, then crossed by one
byte), and sends a customer's bill out: **streamed**, row by row on another thread, and **whole**, as a `Resource`, each with a
`Content-Disposition` that names the file.

**No anchor change (brief ⚑2).** `anchor` is the link to `../c6-unit16/after` — the problem-detail lesson's frozen tree, `c6-tiffinbox` at
Section 3's end (`diff -rq -x target c6-tiffinbox c6-unit16/after` empty on 2026-10-22) — read and copied under `.harness/anchor`, never
built in place; this unit freezes no `after/` and touches no other unit's folder. Everything new is **the course's harness**, never
TiffinBox's — `harness/probe/web`, outside `com.tiffinbox`, compiled with `-parameters` against the anchor's own jar and joined by
`--spring.main.sources` on the extracted jar's class path:

- `Files` — a `@RestController`: `GET /probe/multipart` reads back Boot's `MultipartConfigElement` bean (the limits Tomcat is given);
  `POST /probe/menu` takes one part, `@RequestPart("menu") MultipartFile menu`, and answers its file name, size, content type and line
  count; `GET /probe/bill/{name}` reads the customer from **TiffinBox's own `CustomerRepository`** (`findByName`, injected — the anchor's
  public class) and answers a `ResponseEntity<StreamingResponseBody>`: `text/csv;charset=UTF-8`, `Content-Disposition` from Spring's
  `ContentDisposition.attachment().filename("bill <name>.csv", UTF_8)`, a header row, one row per day of a 30-day month and the month's
  total (the record's own `monthlyBill()`), written after the handler has returned; `GET /probe/bill-whole/{name}` the same bytes as a
  `ByteArrayResource`. A name nobody has is a 404 with no body, before anything is written. It prints the JVM's locale, and a line at each
  step — the thread named with its number masked (`task-<n>`) and whether it is virtual.
- `Dispatches` — a plain servlet filter in a `FilterRegistrationBean` for **every dispatch type**, on `/probe/bill/*` and
  `/probe/bill-whole/*` only: it prints the dispatch type going in, and the status going out unless the request went async on the way.
- `Refusals` — a `HandlerExceptionResolver` at the highest precedence that **answers nothing**: for a `MaxUploadSizeExceededException` it
  prints the exception at the root of it — Tomcat's own, which says which limit refused — and returns null, so Boot's problem-details
  handler answers exactly as it would without it (the 413s here are Boot's, byte for byte the probe's).
- `Trace` — every harness line: `HOOK nnnn what ran` — the filters lesson's, byte for byte (checked).
- `harness/keys.py` — reads a jar's `META-INF/spring-configuration-metadata.json` and prints the keys under a prefix (name, default, type).
- `harness/shutdown.sh` — POST `/shutdown` with the token read from its file (the filters lesson's, byte for byte).
- `exercise/MenuDesk.java` — the exercise's route (`POST /kitchen/menu`); the solution is one key, so `exercise/solution/` holds only
  `SOLUTION.md`.

The test files — the menu, one byte repeated at four sizes — are made by the receipt (`printf`, `head -c … /dev/zero | tr`) under
`.harness/files/`, never committed (a check refuses one outside `.harness/`). No native build (the binary's multipart was measured on the
probe's sketch; CARRIED to the capstone, brief ⚑2 loser A), no Docker and no browser: curl only, so nothing here says "a browser" (R.115) —
`curl -O -J` is curl's behaviour, not a browser's.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 6 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top; a bare `java` on this Mac is 23.0.1.) It **dies** when a capture's md5 differs
from `receipts.md5` (it prints the `DIFFERS` line first). **Start it in a process group of its own** (a terminal's foreground job is one):
two receipts started as background jobs of one shell share a group, and one run's clean-up would stop the other's JVMs (R.94).

**Runs of record (2026-10-23, BLUE S4 part 1, this script as committed):** **264 s under `./receipts.sh`** (/bin/bash 3.2.57, `env -i` with
HOME and a plain PATH, this folder, a session of its own: exit 0, all 6 captures 3/3 = published, every check passed) and **319 s under
`bash receipts.sh`** (Homebrew bash 5.3.9, the same: exit 0, all 6 = published). **SIGINT** to its process group while `bill`'s
JVM listened on 19496: exit 130 in 139 s, nothing of the group left, the JVM gone, 19490-19499 free, no `.r-lock`, no unfinished run, the
published captures unchanged (md5). **How the hashes were made:** one development run (bash
3.2, 234 s, every check passed, each capture 3/3) fixed `bill` (the `--raw` framing line, RED S4 #344); `limits`, `upload`, `limit`,
`resource` and `exercise` reproduced their earlier hashes unchanged. **The sealed fresh clone** of 2026-10-22 (at 12bc4ff, 720 s) followed
the earlier text of the recipe, which RED S4 #405 measured to leak as written, so its "every one from the `file://` copy" is not a proof from
that text. It was **not re-run** for this change: only a capture changed (one more curl line; no dependency, plugin or build step), which a
sealed clone cannot tell from a seeded run. The fixed recipe below was measured once, on c6-unit18 (its README gives the counts).

Published hashes: limits `a6d33d7a4d8a85712fdd96a986ae1538` · upload `53ac7dccca92f27cc6c43b59d587f100` · limit `9543199f3c29ed51b82fa275691d7327` · bill `8aa5137aae2631774518edf431442e60` · resource `c058f314e4eeed18cd39a316d7ddeee2` · exercise `caf64a386a863c7be143cef0ecb9bac8`.

### A sealed fresh clone — the recipe (RED S4 #405)

A sealed clone proves that a fresh clone's first build fetches only from a copy you control. **The earlier text of this paragraph did not
seal** (RED S4 #405, measured): a `HOME` of its own whose `.mavenrc` set only `-Dhttp(s).proxyHost`, with Maven settings in `$HOME/.m2`,
fetched from Maven Central — Java on macOS ignores `$HOME` (`user.home` stays your own folder, so Maven never read those settings), and
Maven's resolver ignores the `-Dhttp.proxyHost` properties (it takes its proxies from `settings.xml`). The recipe that seals, step by step,
with a pre-flight that refuses to start unless the only remote is `file://` and a post-check of where every artifact came from:

```bash
S=/tmp/sealed-20                                   # an empty folder of your own; T = your tiffinbox-java clone
mkdir -p "$S/home/.m2" && git clone -q "file://$T" "$S/tiffinbox-java"
rsync -a --exclude _remote.repositories --exclude '*.lastUpdated' --exclude resolver-status.properties "$T/c6-unit20/.m2-demo/" "$S/central/"
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
cd "$S/tiffinbox-java/c6-unit20" && $E ./receipts.sh            # a process group of its own (a terminal's foreground job is one)
# post-check: every artifact's origin, by repository id - each line must say sealed; 0 central
find .m2-demo -name _remote.repositories -exec cat {} + | grep -o '>[^=]*=' | sort | uniq -c
```

## The commands this unit adds

`anchor/README.md` — the anchor's own — gives every line `receipts.sh` runs or derives from (`mvn -B package`, the run line, the extract
line, the class-path line, the readiness line, the Content-Type line, the POST of a customer) but these eleven, which are this unit's, each
read from the block below and asserted to be exactly this (on the anchor's port 18431; each capture swaps in its own port):

```bash
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431 --spring.servlet.multipart.max-file-size=2MB
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/probe/web/Dispatches.java harness/probe/web/Files.java harness/probe/web/Refusals.java harness/probe/web/Trace.java
python3 harness/keys.py .harness/anchor/tiffinbox-web/target/extracted/lib/spring-boot-servlet-4.1.1.jar spring.servlet.multipart.
head -c 1048577 /dev/zero | tr '\0' 'm' > .harness/files/menu-1048577.txt
curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · Connection: [%header{connection}]\n' -F 'menu=@.harness/files/menu.csv' http://127.0.0.1:18431/probe/menu
curl -s -D .harness/head.txt -o .harness/body.csv -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:18431/probe/bill/Ravi
cd .harness/dl && curl -s -O -J http://127.0.0.1:18431/probe/bill/Ravi
curl -s --raw -o .harness/raw.txt http://127.0.0.1:18431/probe/bill/Ravi
curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Zoë K","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:18431/customers
```

The first two are the anchor's run line and its class-path line with `-Duser.language=en -Duser.country=US` after `java` — asserted — and
every java line a capture starts takes the same two options in the same place (`at()`; a last check refuses any capture's java line without
them, and the exercise's). The third is the pinned class-path line with Boot's file-size key as an option (`limit` B and C). The javac line
compiles the harness's four files and nothing else. The metadata line reads the anchor's own `spring-boot-servlet` jar. The file line makes
one test file (`mk()` swaps in the size, in both places). The upload line is the anchor's Content-Type line with
`Connection: [%header{connection}]` added to curl's `-w`, one `-F` part and the harness's path (`uq()` swaps the file, or adds `;type=`);
the saved-answer line is the same line with `-D` and `-o` (headers and body to files, both removed before each request — R.119) and the
bill's path (`gq()` swaps the path, or adds one curl option: `-r 0-15`); the `-O -J` line saves under the name the answer gives, from a
folder of its own (`oj()` swaps the path); the `--raw` line keeps the chunked framing, so `chunks()` reads each chunk's size line
(`rawq()` swaps the port; RED S4 #344); the POST is the anchor's POST of Asha with the name `Zoë K` and nothing else. The limits are
read with the anchor's readiness line, its path made `/probe/multipart`. Each derivation is asserted.

## The repository, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from `../../spring-web-mvc/_research/m2-seed-s4/`
alone — 5,891 files (the S3 seed + the Thymeleaf 54, which this unit does not use), no `com/tiffinbox`. **Nothing was downloaded** for this
unit: every build said `offline: yes`. A fresh clone's `.m2-demo` is empty (git ignores it): the first build — `.harness/pre`, before any
capture — fills it from Maven Central and says `offline: no`. **At run time** every request goes to `127.0.0.1`, and nothing binds 8080,
18425 or 35729.

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 32 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/anchor/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) when the script runs, and sent only by `../c5-unit11/curlset.sh` and `harness/shutdown.sh` on curl's standard input. Every
capture's raw output is searched for it before masking (0 in all of them), and so are the log of every JVM that served, and every file this
unit ships: 0 everywhere. The header's name, `X-Shutdown-Token`, is counted too: 0 in every log. No capture sends a secret toward an answer,
so this unit plants no canary. The exercise makes a token of its own (`openssl rand -hex 13`), counted 0 times in its own log, never printed.

## The locale — pinned per JVM, printed, asserted

Every java line this script starts carries `-Duser.language=en -Duser.country=US` before `-jar` or `-cp` (S4.1, R.100), and every harness
JVM prints its locale (`Files`; the exercise's `MenuDesk`) — `en_US`, asserted in every capture that starts one (S4.23). Receipts run under
bash (`#!/bin/bash`), never zsh, where the two options would arrive as one word (brief READ FIRST 13). The harness's own lines are ASCII:
the JVM writes standard output in the shell's encoding (the C locale here), which turned a `·` into `?` on the first run (Found on the way).

## The folders, the names and the ports

- `.harness/pre` — the anchor built before any capture; `.harness/anchor` — the anchor, copied, with a config tree, built and extracted
  (`limits`); `.harness/hc` — the harness's classes; `.harness/files` — the test files; `.harness/head.txt`, `.harness/body.csv` — what curl
  saved; `.harness/streamed-Ravi.csv` — the streamed bill, kept for the comparisons in `resource`; `.harness/dl` — what `curl -O -J` saved;
  `.harness/mine` — the exercise's copy.
- **Ports** (brief ⚑1, 19490-19499): `limits` — the seven 19490, the harness 19491 · `upload` 19492 · `limit` — A and A′ 19493, B 19494,
  C 19495 · `bill` 19496 · `resource` 19497 · the exercise 19499 (19498 unused). Captures run one after another, each JVM stopped (and its
  port checked free) before the next starts. All ten, 18425, 8080 and 35729 are checked free first; a run that listens on 8080 or 35729 is
  killed and the script dies.

## Masks, filters and hygiene — every one, declared

1. **Paths, the token, the user** (`gsub()`, literals escaped), in every line: the demo token → `[masked: the 32-character token]`; this
   folder → `…`; the folder above → `…/..`; home → `~`; the user name, as a whole word → `<user>`; a generated class's number →
   `$$SpringCGLIB$$<n>`. A last check fails if any capture holds `/Users/`, `/private/`, `/home/`, `/var/folders/`, a unit number, Boot's
   process line, a log time, an unmasked timestamp, a date, a thread number, a stack frame, a whole HTML page, `:8080` or `:35729`, a
   carriage return, Tomcat's request size unmasked, a count of bytes curl sent, or a command with a URL that is not `127.0.0.1`'s.
2. **Spring's error timestamp** (`tsmask`, `pagef`): `"timestamp":"<anything>"` → `"timestamp":"…"`, both forms, in every answer printed and
   in the seven (problem details here: the mask runs, and the seven print its count, 0).
3. **Answers** (`pagef`): JSON — a problem detail too — as it came, never re-ordered; an HTML page (none came) as its `<h1>` and its length.
   **Headers curl saved** (`hdrs`): every line as it came, its carriage return and trailing space dropped, `Date`'s value → `…`, counted;
   then whether a `Content-Length` and a `Transfer-Encoding` came. **A body curl saved** (`body`): its lines and bytes counted, whether the
   last line ended, then every line whole (the bill is 32 lines); a test file by its size alone. Each checked on planted inputs first.
4. **Tomcat's request-limit sentence** (`hk`): `its size (<n>) exceeds` → `its size (…) exceeds` — the request's own size is the file plus
   curl's multipart framing (its boundary and part headers), which another curl may frame differently; the limit (`10485760`) is kept.
   **No count of the bytes curl sent before a refusal** is captured: it moves with timing (R.121; brief READ FIRST 7).
5. **Log lines** (`logl`, `recs`): from their logger on, as the log prints the logger — `o.s.web.servlet.PageNotFound` is **Spring MVC's**
   (the seven's 405). Boot's first line is cut before ` with PID`. Every request ends its answer's last line with
   `· WARN lines it added: N · ERROR lines: M` — **counted by the log's own line shape** (`<ISO date> LEVEL <pid> --- [`), never a bare
   `' ERROR '`, which the harness's own lines could satisfy (R.120; checked on a planted log first: a harness line that says ERROR and one
   record give 1, where a bare count gives 2). Each WARN or ERROR record would follow (none did, past the seven's one).
6. **Harness lines** (`hk`): printed after each request in the order they printed, numbered from 1, the JVM's running number checked to rise
   (a planted falling number stops the run) and never shown; a thread's own number is `<n>` (the harness prints it so).
7. **A′ against A** (`asame`): A's block and A′'s, their labels aside, compared line for line in the capture itself ("yes").
8. **On this Mac**: `lsof` by pid (or by port), the address column alone — never a command name (R.18).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`, and the exercise's
shell `$xpid` with every process under it — `killtree`), sweeps its own process group for any TiffinBox JVM or Maven left, deletes the
capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched. No `wait` in the script, its
checks or the exercise is bare: each names its pid (R.105; a check refuses a bare one). See "Found on the way" for the measured interrupt.

## 1 · limits — Boot's limits, read off its metadata and off the bean

The anchor built offline and extracted; the harness compiled; the seven on a fresh JVM of the jar (`466c20ed…`, unchanged since the problem-detail lesson, 1 WARN `PageNotFound`). Then Boot 4.1.1's own metadata for the multipart keys, read out of the anchor's `spring-boot-servlet-4.1.1.jar` by `keys.py`: 7 keys, `max-file-size` default `1MB`, `max-request-size` `10MB`, `file-size-threshold` `0B`, `location` none. Then the harness joined, and the `MultipartConfigElement` Boot built from them, read back off the running application: 1,048,576 / 10,485,760 / 0 / an empty location. Spring's `MB` is 1,024 × 1,024 (B reads `2MB` back as 2,097,152).

`.r-limits.out` · md5 `a6d33d7a4d8a85712fdd96a986ae1538` · 3 of 3

```
the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline), its jar extracted (the README's line):
$ cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the anchor · offline: yes · exit 0
$ cd .harness/anchor && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
the harness, compiled against the anchor's own jar - with -parameters (this unit's line):
$ javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/probe/web/Dispatches.java harness/probe/web/Files.java harness/probe/web/Refusals.java harness/probe/web/Trace.java
  exit 0 · its classes: probe/web/Dispatches$Seen.class probe/web/Dispatches.class probe/web/Files.class probe/web/Refusals.class probe/web/Trace.class
the seven - the anchor, the README's run line (its locale pinned), port 19490, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19490
  listens on: 127.0.0.1:19490 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19490/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19490 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
the keys - what Boot's own metadata declares under spring.servlet.multipart. (in spring-boot-servlet-4.1.1.jar, from the anchor's extracted lib/; this unit's line):
$ python3 harness/keys.py .harness/anchor/tiffinbox-web/target/extracted/lib/spring-boot-servlet-4.1.1.jar spring.servlet.multipart.
  spring.servlet.multipart.enabled · default true · Boolean
  spring.servlet.multipart.file-size-threshold · default 0B · DataSize
  spring.servlet.multipart.location · default none · String
  spring.servlet.multipart.max-file-size · default 1MB · DataSize
  spring.servlet.multipart.max-request-size · default 10MB · DataSize
  spring.servlet.multipart.resolve-lazily · default false · Boolean
  spring.servlet.multipart.strict-servlet-compliance · default false · Boolean
  7 keys under spring.servlet.multipart.
the bean - the anchor on its class path, the harness joined (Files, Dispatches, Refusals), port 19491: Boot's MultipartConfigElement, read back:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19491 --spring.main.sources=probe.web.Files,probe.web.Dispatches,probe.web.Refusals
  listens on: 127.0.0.1:19491 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19491/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Files): en_US
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19491/probe/multipart
  {"maxFileSize":1048576,"maxRequestSize":10485760,"fileSizeThreshold":0,"location":""} 200 · WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19491 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19491 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 2 · upload — a small file in

The menu, three lines of CSV (85 bytes), made with `printf`; sent with `curl -F` as the part `menu`: 200, its name, 85 bytes, 3 lines — and its type `application/octet-stream`, which is curl's guess for `.csv`; with `;type=text/csv` the server repeats `text/csv`. The part's type is the client's word. 0 WARN 0 ERROR.

`.r-upload.out` · md5 `53ac7dccca92f27cc6c43b59d587f100` · 3 of 3

```
a small menu - three lines of CSV, made here (printf):
$ printf 'day,lunch,dinner\nMonday,lentil soup,rice and beans\nTuesday,vegetable curry,flatbread\n' > .harness/files/menu.csv
  its size: 85 bytes · its lines: 3
sent - the anchor on its class path, the harness joined, port 19492: once as curl sends it, once with the part's type named:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19492 --spring.main.sources=probe.web.Files,probe.web.Dispatches,probe.web.Refusals
  listens on: 127.0.0.1:19492 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19492/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Files): en_US
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · Connection: [%header{connection}]\n' -F 'menu=@.harness/files/menu.csv' http://127.0.0.1:19492/probe/menu
  {"file":"menu.csv","bytes":85,"type":"application/octet-stream","lines":3} 200 · Content-Type: [application/json] · Connection: [] · WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 1
     1 Files           menu: part menu, 85 bytes
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · Connection: [%header{connection}]\n' -F 'menu=@.harness/files/menu.csv;type=text/csv' http://127.0.0.1:19492/probe/menu
  {"file":"menu.csv","bytes":85,"type":"text/csv","lines":3} 200 · Content-Type: [application/json] · Connection: [] · WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 1
     1 Files           menu: part menu, 85 bytes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19492 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19492 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 3 · limit — the line, A/B/A′; C labelled

Four test files, one byte repeated: 1,048,576, 1,048,577, 1,500,000 and 12,000,000 bytes. **A** (Boot's limits): 1,048,576 → 200; 1,048,577 and 1,500,000 → `413 application/problem+json` "Maximum upload size exceeded", title "Content Too Large", `Connection: close`, 0 WARN 0 ERROR (quiet because TiffinBox switches problem details on —
`spring.mvc.problemdetails.enabled: true` in the anchor's `application.yaml`; Boot's own default is off, and RED S4 #341's probe measured that
answer as an empty 413 with 2 WARN from `DefaultHandlerExceptionResolver` — not a capture here; `Connection: close` is Tomcat's, for any 413:
`Http11Processor.statusDropsConnection`, RED S4 #345) — `Refusals` names Tomcat's `FileSizeLimitExceededException`, and the route never ran; 12,000,000 → the same 413, Tomcat's `SizeLimitExceededException` (the request's 10,485,760). **B** (`--spring.servlet.multipart.max-file-size=2MB`, an option): the bean reads 2,097,152, and 1,500,000 → 200. **A′** = A, line for line (`asame`). **C** (labelled, B's key): 12,000,000 → 413, the request limit. Statuses, bodies, headers and Tomcat's sentence are asserted; how many bytes curl sent before a refusal is never captured (it moves with timing).

`.r-limit.out` · md5 `9543199f3c29ed51b82fa275691d7327` · 3 of 3

```
the test files - made here, each of one byte repeated (this unit's line, with each size):
$ head -c 1048576 /dev/zero | tr '\0' 'm' > .harness/files/menu-1048576.txt
  its size: 1048576 bytes
$ head -c 1048577 /dev/zero | tr '\0' 'm' > .harness/files/menu-1048577.txt
  its size: 1048577 bytes
$ head -c 1500000 /dev/zero | tr '\0' 'm' > .harness/files/menu-1500000.txt
  its size: 1500000 bytes
$ head -c 12000000 /dev/zero | tr '\0' 'm' > .harness/files/menu-12000000.txt
  its size: 12000000 bytes
A - the anchor on its class path, the harness joined, Boot's limits, port 19493:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19493 --spring.main.sources=probe.web.Files,probe.web.Dispatches,probe.web.Refusals
  listens on: 127.0.0.1:19493 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19493/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Files): en_US
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19493/probe/multipart
  {"maxFileSize":1048576,"maxRequestSize":10485760,"fileSizeThreshold":0,"location":""} 200 · WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · Connection: [%header{connection}]\n' -F 'menu=@.harness/files/menu-1048576.txt' http://127.0.0.1:19493/probe/menu
  {"file":"menu-1048576.txt","bytes":1048576,"type":"text/plain","lines":1} 200 · Content-Type: [application/json] · Connection: [] · WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 1
     1 Files           menu: part menu, 1048576 bytes
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · Connection: [%header{connection}]\n' -F 'menu=@.harness/files/menu-1048577.txt' http://127.0.0.1:19493/probe/menu
  {"detail":"Maximum upload size exceeded","instance":"/probe/menu","status":413,"title":"Content Too Large"} 413 · Content-Type: [application/problem+json] · Connection: [close] · WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 1
     1 Refusals        MaxUploadSizeExceededException - under it, Tomcat's FileSizeLimitExceededException: The field menu exceeds its maximum permitted size of 1048576 bytes.
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · Connection: [%header{connection}]\n' -F 'menu=@.harness/files/menu-1500000.txt' http://127.0.0.1:19493/probe/menu
  {"detail":"Maximum upload size exceeded","instance":"/probe/menu","status":413,"title":"Content Too Large"} 413 · Content-Type: [application/problem+json] · Connection: [close] · WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 1
     1 Refusals        MaxUploadSizeExceededException - under it, Tomcat's FileSizeLimitExceededException: The field menu exceeds its maximum permitted size of 1048576 bytes.
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · Connection: [%header{connection}]\n' -F 'menu=@.harness/files/menu-12000000.txt' http://127.0.0.1:19493/probe/menu
  {"detail":"Maximum upload size exceeded","instance":"/probe/menu","status":413,"title":"Content Too Large"} 413 · Content-Type: [application/problem+json] · Connection: [close] · WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 1
     1 Refusals        MaxUploadSizeExceededException - under it, Tomcat's SizeLimitExceededException: the request was rejected because its size (…) exceeds the configured maximum (10485760)
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19493 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19493 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the same, the file limit raised for this run (this unit's line: Boot's key, as an option), port 19494:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19494 --spring.main.sources=probe.web.Files,probe.web.Dispatches,probe.web.Refusals --spring.servlet.multipart.max-file-size=2MB
  listens on: 127.0.0.1:19494 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19494/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Files): en_US
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19494/probe/multipart
  {"maxFileSize":2097152,"maxRequestSize":10485760,"fileSizeThreshold":0,"location":""} 200 · WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · Connection: [%header{connection}]\n' -F 'menu=@.harness/files/menu-1500000.txt' http://127.0.0.1:19494/probe/menu
  {"file":"menu-1500000.txt","bytes":1500000,"type":"text/plain","lines":1} 200 · Content-Type: [application/json] · Connection: [] · WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 1
     1 Files           menu: part menu, 1500000 bytes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19494 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19494 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, a fresh JVM, port 19493:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19493 --spring.main.sources=probe.web.Files,probe.web.Dispatches,probe.web.Refusals
  listens on: 127.0.0.1:19493 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19493/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Files): en_US
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19493/probe/multipart
  {"maxFileSize":1048576,"maxRequestSize":10485760,"fileSizeThreshold":0,"location":""} 200 · WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · Connection: [%header{connection}]\n' -F 'menu=@.harness/files/menu-1048576.txt' http://127.0.0.1:19493/probe/menu
  {"file":"menu-1048576.txt","bytes":1048576,"type":"text/plain","lines":1} 200 · Content-Type: [application/json] · Connection: [] · WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 1
     1 Files           menu: part menu, 1048576 bytes
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · Connection: [%header{connection}]\n' -F 'menu=@.harness/files/menu-1048577.txt' http://127.0.0.1:19493/probe/menu
  {"detail":"Maximum upload size exceeded","instance":"/probe/menu","status":413,"title":"Content Too Large"} 413 · Content-Type: [application/problem+json] · Connection: [close] · WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 1
     1 Refusals        MaxUploadSizeExceededException - under it, Tomcat's FileSizeLimitExceededException: The field menu exceeds its maximum permitted size of 1048576 bytes.
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · Connection: [%header{connection}]\n' -F 'menu=@.harness/files/menu-1500000.txt' http://127.0.0.1:19493/probe/menu
  {"detail":"Maximum upload size exceeded","instance":"/probe/menu","status":413,"title":"Content Too Large"} 413 · Content-Type: [application/problem+json] · Connection: [close] · WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 1
     1 Refusals        MaxUploadSizeExceededException - under it, Tomcat's FileSizeLimitExceededException: The field menu exceeds its maximum permitted size of 1048576 bytes.
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · Connection: [%header{connection}]\n' -F 'menu=@.harness/files/menu-12000000.txt' http://127.0.0.1:19493/probe/menu
  {"detail":"Maximum upload size exceeded","instance":"/probe/menu","status":413,"title":"Content Too Large"} 413 · Content-Type: [application/problem+json] · Connection: [close] · WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 1
     1 Refusals        MaxUploadSizeExceededException - under it, Tomcat's SizeLimitExceededException: the request was rejected because its size (…) exceeds the configured maximum (10485760)
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19493 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19493 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
C (labelled) - B's key again, a fresh JVM, port 19495: twelve million bytes, over the request's own limit:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19495 --spring.main.sources=probe.web.Files,probe.web.Dispatches,probe.web.Refusals --spring.servlet.multipart.max-file-size=2MB
  listens on: 127.0.0.1:19495 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19495/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Files): en_US
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19495/probe/multipart
  {"maxFileSize":2097152,"maxRequestSize":10485760,"fileSizeThreshold":0,"location":""} 200 · WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 0
$ curl -s -w ' %{http_code} · Content-Type: [%{content_type}] · Connection: [%header{connection}]\n' -F 'menu=@.harness/files/menu-12000000.txt' http://127.0.0.1:19495/probe/menu
  {"detail":"Maximum upload size exceeded","instance":"/probe/menu","status":413,"title":"Content Too Large"} 413 · Content-Type: [application/problem+json] · Connection: [close] · WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 1
     1 Refusals        MaxUploadSizeExceededException - under it, Tomcat's SizeLimitExceededException: the request was rejected because its size (…) exceeds the configured maximum (10485760)
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19495 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19495 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 4 · bill — a customer's bill, streamed

Ravi, as the anchor seeds him (2 meals a day at 120), read by `Files` from TiffinBox's own `CustomerRepository`: 200 `text/csv;charset=UTF-8`, `Transfer-Encoding: chunked`, **no `Content-Length`**, `Content-Disposition: attachment; filename="bill Ravi.csv"; filename*=UTF-8''bill%20Ravi.csv`; the body: 32 lines — the header, 30 days at 240, the month 7,200 (`monthlyBill()`). The harness's lines, in the order the program printed them: `Dispatches` in on the REQUEST dispatch; the handler returns on `tomcat-handler-<n>` with nothing written; the body written on `task-<n>` (Boot's task executor, virtual here), not the handler's thread; then `Dispatches` in and out on the **ASYNC** dispatch. A name nobody has: 404, `Content-Length: 0`, nothing written, one REQUEST dispatch. **The framing** (RED S4 #344): the same bill once more
with `curl --raw`, its chunk-size lines read by `chunks()` — `[595, 0]`: one chunk of 595 bytes, then the empty last one, and the data equal
to the bill byte for byte. Chunked because the code writes line by line after the handler returned, so no length is known when Tomcat
sends; one chunk because Tomcat's buffer held all 595 bytes — "written in pieces" is not what goes out here.

`.r-bill.out` · md5 `8aa5137aae2631774518edf431442e60` · 3 of 3

```
a bill streamed - the anchor on its class path, the harness joined, port 19496: Ravi (a customer the anchor seeds), then a name nobody has:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19496 --spring.main.sources=probe.web.Files,probe.web.Dispatches,probe.web.Refusals
  listens on: 127.0.0.1:19496 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19496/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Files): en_US
$ curl -s -D .harness/head.txt -o .harness/body.csv -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19496/probe/bill/Ravi
  curl's line: 200 · Content-Type: [text/csv;charset=UTF-8] · curl's exit code: 0 · WARN lines it added: 0 · ERROR lines: 0
  the headers curl saved, as they came: 5 lines, the status line first (Date's value masked):
    HTTP/1.1 200
    Content-Disposition: attachment; filename="bill Ravi.csv"; filename*=UTF-8''bill%20Ravi.csv
    Content-Type: text/csv;charset=UTF-8
    Transfer-Encoding: chunked
    Date: …
  Content-Length: none · Transfer-Encoding: chunked
  the body curl saved: 32 lines, 595 bytes, the last one ended:
    | day,customer,meals,price per meal,amount
    | 1,Ravi,2,120,240
    | 2,Ravi,2,120,240
    | 3,Ravi,2,120,240
    | 4,Ravi,2,120,240
    | 5,Ravi,2,120,240
    | 6,Ravi,2,120,240
    | 7,Ravi,2,120,240
    | 8,Ravi,2,120,240
    | 9,Ravi,2,120,240
    | 10,Ravi,2,120,240
    | 11,Ravi,2,120,240
    | 12,Ravi,2,120,240
    | 13,Ravi,2,120,240
    | 14,Ravi,2,120,240
    | 15,Ravi,2,120,240
    | 16,Ravi,2,120,240
    | 17,Ravi,2,120,240
    | 18,Ravi,2,120,240
    | 19,Ravi,2,120,240
    | 20,Ravi,2,120,240
    | 21,Ravi,2,120,240
    | 22,Ravi,2,120,240
    | 23,Ravi,2,120,240
    | 24,Ravi,2,120,240
    | 25,Ravi,2,120,240
    | 26,Ravi,2,120,240
    | 27,Ravi,2,120,240
    | 28,Ravi,2,120,240
    | 29,Ravi,2,120,240
    | 30,Ravi,2,120,240
    | month,Ravi,60,120,7200
  the harness's lines it printed, in order: 5
     1 Dispatches      in  REQUEST /probe/bill/Ravi
     2 Files           bill: the handler returns, nothing written yet, on tomcat-handler-<n> (virtual: true)
     3 Files           bill: the body written, 32 lines, on task-<n> (virtual: true), the handler's thread: no
     4 Dispatches      in  ASYNC /probe/bill/Ravi
     5 Dispatches      out ASYNC /probe/bill/Ravi status 200
the same bill once more, its framing kept - curl --raw writes each chunk's size line too (this unit's line):
$ curl -s --raw -o .harness/raw.txt http://127.0.0.1:19496/probe/bill/Ravi
  curl's exit code: 0 · the chunks' sizes, in bytes, as they came: [595, 0] · their data = the bill above, byte for byte: yes
$ curl -s -D .harness/head.txt -o .harness/body.csv -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19496/probe/bill/Nobody
  curl's line: 404 · Content-Type: [] · curl's exit code: 0 · WARN lines it added: 0 · ERROR lines: 0
  the headers curl saved, as they came: 3 lines, the status line first (Date's value masked):
    HTTP/1.1 404
    Content-Length: 0
    Date: …
  Content-Length: 0 · Transfer-Encoding: none
  the body curl saved: nothing
  the harness's lines it printed, in order: 3
     1 Dispatches      in  REQUEST /probe/bill/Nobody
     2 Files           bill: no customer Nobody - 404, nothing written
     3 Dispatches      out REQUEST /probe/bill/Nobody status 404
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19496 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19496 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 5 · resource — the bill whole, a range of it, a name that is not ASCII

The same bill as a `ByteArrayResource`: `Content-Length: 595`, `Accept-Ranges: bytes`, not chunked — the same 595 bytes as the streamed bill (`cmp`); `-r 0-15` → 206, `Content-Range: bytes 0-15/595`, 16 bytes. Zoë K added with the anchor's POST (201); her streamed bill's disposition: `filename="bill Zoe K.csv"` (the ASCII fallback, `ë` → `e`) and `filename*=UTF-8''bill%20Zo%C3%AB%20K.csv` (the exact name). `curl -O -J`, from a folder of its own, saved `bill Ravi.csv` (the streamed bill, byte for byte) and `bill Zoe K.csv` — curl took the ASCII name (its manual, 8.7.1, `-J`: it does not yet support `filename*`, so curl never chooses; RED S4 #347); the file
inside still says `Zoë K`. **Both names come from Spring's `ContentDisposition`** (spring-web), which `Files.disposition()` gives
`StandardCharsets.UTF_8`: given a charset it writes `filename` and `filename*` for every name — Ravi's ASCII one too (`bill`) — so "twice
when the name is not ASCII" was false (RED S4 #340); with no charset it writes one name, raw (RED's probe, not a capture here).

`.r-resource.out` · md5 `c058f314e4eeed18cd39a316d7ddeee2` · 3 of 3

```
the bill whole - the anchor on its class path, the harness joined, port 19497: Ravi's, as a Resource; then a range of it:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19497 --spring.main.sources=probe.web.Files,probe.web.Dispatches,probe.web.Refusals
  listens on: 127.0.0.1:19497 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19497/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Files): en_US
$ curl -s -D .harness/head.txt -o .harness/body.csv -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19497/probe/bill-whole/Ravi
  curl's line: 200 · Content-Type: [text/csv;charset=UTF-8] · curl's exit code: 0 · WARN lines it added: 0 · ERROR lines: 0
  the headers curl saved, as they came: 6 lines, the status line first (Date's value masked):
    HTTP/1.1 200
    Content-Disposition: attachment; filename="bill Ravi.csv"; filename*=UTF-8''bill%20Ravi.csv
    Accept-Ranges: bytes
    Content-Type: text/csv;charset=UTF-8
    Content-Length: 595
    Date: …
  Content-Length: 595 · Transfer-Encoding: none
  the body curl saved: 32 lines, 595 bytes, the last one ended:
    | day,customer,meals,price per meal,amount
    | 1,Ravi,2,120,240
    | 2,Ravi,2,120,240
    | 3,Ravi,2,120,240
    | 4,Ravi,2,120,240
    | 5,Ravi,2,120,240
    | 6,Ravi,2,120,240
    | 7,Ravi,2,120,240
    | 8,Ravi,2,120,240
    | 9,Ravi,2,120,240
    | 10,Ravi,2,120,240
    | 11,Ravi,2,120,240
    | 12,Ravi,2,120,240
    | 13,Ravi,2,120,240
    | 14,Ravi,2,120,240
    | 15,Ravi,2,120,240
    | 16,Ravi,2,120,240
    | 17,Ravi,2,120,240
    | 18,Ravi,2,120,240
    | 19,Ravi,2,120,240
    | 20,Ravi,2,120,240
    | 21,Ravi,2,120,240
    | 22,Ravi,2,120,240
    | 23,Ravi,2,120,240
    | 24,Ravi,2,120,240
    | 25,Ravi,2,120,240
    | 26,Ravi,2,120,240
    | 27,Ravi,2,120,240
    | 28,Ravi,2,120,240
    | 29,Ravi,2,120,240
    | 30,Ravi,2,120,240
    | month,Ravi,60,120,7200
  the harness's lines it printed, in order: 3
     1 Dispatches      in  REQUEST /probe/bill-whole/Ravi
     2 Files           bill-whole: the handler returns 595 bytes, whole, on tomcat-handler-<n> (virtual: true)
     3 Dispatches      out REQUEST /probe/bill-whole/Ravi status 200
  the same bytes as the streamed bill (bill, above): yes
$ curl -s -D .harness/head.txt -o .harness/body.csv -w ' %{http_code} · Content-Type: [%{content_type}]\n' -r 0-15 http://127.0.0.1:19497/probe/bill-whole/Ravi
  curl's line: 206 · Content-Type: [text/csv;charset=UTF-8] · curl's exit code: 0 · WARN lines it added: 0 · ERROR lines: 0
  the headers curl saved, as they came: 7 lines, the status line first (Date's value masked):
    HTTP/1.1 206
    Content-Disposition: attachment; filename="bill Ravi.csv"; filename*=UTF-8''bill%20Ravi.csv
    Accept-Ranges: bytes
    Content-Range: bytes 0-15/595
    Content-Type: text/csv;charset=UTF-8
    Content-Length: 16
    Date: …
  Content-Length: 16 · Transfer-Encoding: none
  the body curl saved: 0 lines, 16 bytes, the last one cut:
    | day,customer,mea
  the harness's lines it printed, in order: 3
     1 Dispatches      in  REQUEST /probe/bill-whole/Ravi
     2 Files           bill-whole: the handler returns 595 bytes, whole, on tomcat-handler-<n> (virtual: true)
     3 Dispatches      out REQUEST /probe/bill-whole/Ravi status 206
a name that is not ASCII - Zoë K, added with the anchor's own POST (this unit's line: another name), then the streamed bill's headers:
$ curl -s -w ' %{http_code}\n' -H 'Content-Type: application/json' --data '{"name":"Zoë K","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19497/customers
  {"name":"Zoë K","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"} 201 · WARN lines it added: 0 · ERROR lines: 0
  the harness's lines it printed, in order: 0
$ curl -s -D .harness/head.txt -o .harness/body.csv -w ' %{http_code} · Content-Type: [%{content_type}]\n' http://127.0.0.1:19497/probe/bill/Zo%C3%AB%20K
  curl's line: 200 · Content-Type: [text/csv;charset=UTF-8] · curl's exit code: 0 · WARN lines it added: 0 · ERROR lines: 0
  the headers curl saved, as they came: 5 lines, the status line first (Date's value masked):
    HTTP/1.1 200
    Content-Disposition: attachment; filename="bill Zoe K.csv"; filename*=UTF-8''bill%20Zo%C3%AB%20K.csv
    Content-Type: text/csv;charset=UTF-8
    Transfer-Encoding: chunked
    Date: …
  Content-Length: none · Transfer-Encoding: chunked
  the harness's lines it printed, in order: 5
     1 Dispatches      in  REQUEST /probe/bill/Zo%C3%AB%20K
     2 Files           bill: the handler returns, nothing written yet, on tomcat-handler-<n> (virtual: true)
     3 Files           bill: the body written, 32 lines, on task-<n> (virtual: true), the handler's thread: no
     4 Dispatches      in  ASYNC /probe/bill/Zo%C3%AB%20K
     5 Dispatches      out ASYNC /probe/bill/Zo%C3%AB%20K status 200
curl -O -J - each bill saved under the name the answer gives, in a folder of its own (this unit's line):
$ cd .harness/dl && curl -s -O -J http://127.0.0.1:19497/probe/bill/Ravi
  curl's exit code: 0 · it printed: 0 lines
$ cd .harness/dl && curl -s -O -J http://127.0.0.1:19497/probe/bill/Zo%C3%AB%20K
  curl's exit code: 0 · it printed: 0 lines
  the folder now holds: 2 files
    [bill Ravi.csv] · 32 lines · its first: day,customer,meals,price per meal,amount · its last: month,Ravi,60,120,7200
    [bill Zoe K.csv] · 32 lines · its first: day,customer,meals,price per meal,amount · its last: month,Zoë K,60,110,6600
  Ravi's saved bill is the streamed bill, byte for byte: yes
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19497 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19497 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 6 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s seven lines, then `exercise/solution/SOLUTION.md`'s four, read from the files and run as written in ONE `env -i` `/bin/bash --noprofile --norc` shell started in this folder (S4.4, R.93). As shipped: `the menu: 413 application/problem+json`. The solution writes `spring.servlet.multipart.max-file-size: 2MB` into the copy's `tiffinbox-local.yaml` (idempotent) and runs the README's last line unchanged (asserted): `the menu: 200 application/json`. Each leaves the shell in this folder, `en_US` in its log, 0 WARN 0 ERROR, 0 copies of the copy's token, 19499 free.

`.r-exercise.out` · md5 `caf64a386a863c7be143cef0ecb9bac8` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 7 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/ && cp exercise/MenuDesk.java .harness/mine/MenuDesk.java
  $ head -c 1500000 /dev/zero | tr '\0' 'm' > .harness/mine/menu.txt
  $ mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*" ../MenuDesk.java && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19499 --spring.main.sources=probe.web.MenuDesk > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19499/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -o /dev/null -w '%{http_code} %{content_type}' -F 'menu=@../menu.txt' http://127.0.0.1:19499/kitchen/menu); ../../../harness/shutdown.sh 19499 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the menu: $a")
  exit 0 · what they printed:
    the menu: 413 application/problem+json
  the shell is now in: this unit's folder · the menu it sent: 1500000 bytes · the JVM's locale in its log: en_US · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19499 now: 0
the solution's 4 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ printf 'spring.servlet.multipart.max-file-size: 2MB\n' > .harness/mine/anchor/tiffinbox-local.yaml
  $ M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*" ../MenuDesk.java && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19499 --spring.main.sources=probe.web.MenuDesk > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19499/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -o /dev/null -w '%{http_code} %{content_type}' -F 'menu=@../menu.txt' http://127.0.0.1:19499/kitchen/menu); ../../../harness/shutdown.sh 19499 secrets/tiffinbox/shutdown-token > /dev/null && wait "$p" && echo "the menu: $a")
  exit 0 · what they printed:
    the menu: 200 application/json
  the shell is now in: this unit's folder · the menu it sent: 1500000 bytes · the JVM's locale in its log: en_US · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19499 now: 0
  the file the solution wrote, .harness/mine/anchor/tiffinbox-local.yaml, whole: 1 line
    spring.servlet.multipart.max-file-size: 2MB
```

## Exercise

**Your turn:** the README's menu upload answers four thirteen. Read the limit's key, raise it, and upload again.
`exercise/README.md` has the commands (copy the anchor and `MenuDesk.java`, make a 1,500,000-byte menu, give the copy a token of its own);
its last line, in a subshell, builds the copy offline, compiles the class, starts it on 19499, sends the menu, stops it, waits for its JVM
and prints — as shipped — `the menu: 413 application/problem+json`. Done is `the menu: 200 application/json`. Measured answer:
`exercise/solution/`. Run `./receipts.sh` once first on a fresh clone.

## The ledger rows and hand-offs this unit pays

- **The roadmap's U20 line** — "`MultipartFile` menu upload; a bill streamed back; size limits enforced": `upload`, `bill` (+ `resource`),
  `limit`.
- **H-07** (C6/07 put `@RequestPart` on screen with this lesson as its home): the upload route takes `@RequestPart("menu") MultipartFile`
  (`upload`; the route's source is checked), spoken "the request part annotation". `@RequestParam` binds a `MultipartFile` too (the probe's
  sketch used it); not shown here.
- **C6-31** — glossed at first spoken use: a multipart request, a streamed body, `Content-Disposition`, an async dispatch.

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-22) |
|---|---|---|---|
| 2 | Every 20 capture on its own harness and `16/after` | the probe's `base/`, synthetic bill rows | **all six captures here; the bill from the anchor's own `CustomerRepository`** (Ravi, seeded; Zoë K, POSTed) |
| 5 | 20's B pair (1.5 MB file, `2MB` key) | 5,000,000 B under `5MB` | **1,500,000 B → 413 under Boot's limits, → 200 under `2MB` (read back 2,097,152)** (`limit` A/B/A′) |
| 14 | The exercise as viewers run it | end states on sketches | **README then SOLUTION in one `env -i` shell, exit 0 each** (`exercise`, and "Found on the way") |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **The customer is Ravi, not Lata** (the brief's `bill Lata.csv`): the anchor seeds Meera, Priya, Ravi and Sunil (the seven's list);
  Lata was a name earlier lessons POSTed. The non-ASCII name is real data too — Zoë K, added with the anchor's own POST line, then billed.
- **C names its limit.** The brief's C ("a 12 MB file under B → 413, the request limit") cannot be told from the answer: both limits give
  the same problem detail, byte for byte. `Refusals` prints Tomcat's own exception — `FileSizeLimitExceededException` ("The field menu
  exceeds its maximum permitted size of 1048576 bytes.") for 1,048,577 and 1,500,000 bytes, `SizeLimitExceededException` ("… exceeds the
  configured maximum (10485760)") for 12,000,000 — so A's 12,000,000 is the request limit already, and C shows raising the file limit does
  not move it.
- **`@RequestPart`, not `@RequestParam`**, on the upload route (H-07, above).
- **A range request is added** (`resource`: `-r 0-15` → 206, `Content-Range: bytes 0-15/595`, 16 bytes), so `Accept-Ranges: bytes` is not a
  header named without its effect.
- **The async dispatch is shown by a filter of this unit's own** (`Dispatches`, every dispatch type: `in REQUEST`, then `in ASYNC` after the
  body is written), not by citing the filters lesson: that lesson measured a `OncePerRequestFilter` skipping the ERROR dispatch; whether it
  skips the ASYNC one is not measured there or here, and is not said.
- **The exercise sets the key in the copy's `tiffinbox-local.yaml`** (the anchor's `application.yaml` imports it from the folder TiffinBox
  starts in), so the README's last line runs unchanged in the solution; B's option is named in `SOLUTION.md` as the other way.
- **The brief's sketch and this tree agree** on every other line of its unit block: the bean's 1,048,576 / 10,485,760 / 0 / no location;
  the part's type as curl's guess; 1,048,576 → 200, 1,048,577 → 413 problem detail, `Connection: close`, 0 WARN 0 ERROR; over ten
  mebibytes → 413; the streamed bill chunked, no `Content-Length`, `filename` + `filename*`, written on another thread; the `Resource`'s
  `Content-Length` and `Accept-Ranges`; `ë` → `e` in the ASCII filename; `curl -O -J` saving the ASCII name.

## Found on the way

- **Every new check fails on a planted fault first** (R.65): the checks block runs alone (`cap()` dropped, the build and the wipe skipped)
  on the published captures with one thing changed per plant (`plants.py`, this unit's scratch folder), the file restored after each —
  **47 plants, 47 stops under /bin/bash 3.2 and 47 under bash 5.3**, each naming its own check; the unplanted files pass before and after under both, and the published captures' md5s are
  unchanged. They change a capture (the seven's hash and its logger; the metadata's default and count; the bean; curl's guessed type and
  the menu's size; A's 200, A's 413, its `Connection: close`, its WARN count, its file limit, the route running for a refused upload; B's
  read-back; A′; C's request limit; the bill's chunking, its disposition, its month, its thread, its ASYNC dispatch, Nobody's empty body;
  the `Resource`'s `Accept-Ranges`, the 206, the same bytes, the two saved names, the ASCII filename; the exercise's two lines, its folder
  and its key; a thread's number, an unmasked request size, an absolute path, an unpinned java line, the raw token, a timestamp, the locale)
  or a shipped file (a bare `wait` in the exercise; Boot 3's error key in this README; the spoken exercise line; SOLUTION.md's Done line
  and its key line; `@RequestParam` for `@RequestPart`; `Dispatches` on the REQUEST dispatch alone; the repository read; this README's B
  line; `Trace.java` not the filters lesson's; a test file outside `.harness/`).
- **Three plants first went uncaught**, and each is a check now: the dispatch types `Dispatches` is registered for (only the builder checked
  them); SOLUTION.md's key line (checked only inside `exercise`, unreachable in checks-only mode — now also in the checks block); and a bare
  `wait` planted in the exercise README's prose (backticked, which the bare-`wait` pattern rightly ignores) — the plant now goes into the
  command line, where the check stops it.
- **Filters checked on planted inputs inside the script itself**, before any capture: the answer filter, the record filter, the level
  counts (a planted log with a harness line naming the ERROR dispatch, one WARN and one ERROR record: 1 and 1 by line shape — a bare
  `' ERROR '` gives 2, so the check distinguishes, R.120), the harness-line filter (a falling running number stops the run; Tomcat's request
  size masked, its limit kept), the header filter (carriage returns, the trailing space, `Date`) and the body filter (ended, cut, nothing).
- **Found while building:** the first full run printed the body thread's line as `(virtual: true) ? the handler's thread` — the JVM wrote
  the harness's `·` in the C locale's ASCII; the harness's lines are ASCII now. The level-count plant's bare count is 2 here (one harness line
  says ERROR), not the filters lesson's 3; the check says so. `curl` reads `.txt` as `text/plain` and `.csv` as `application/octet-stream`.
- **SIGINT**, measured: the script started as a terminal starts its foreground job (`python3` with `SIG_DFL` and `os.setpgrp()`, `env -i`, /bin/bash 3.2), SIGINT to its process group 32 s in, during `limits` (4 processes in the group, one of them TiffinBox's JVM): **exit 130**; 5 s later 0 processes in the group, 0 TiffinBox JVMs on this unit's ports anywhere; 19490-19499, 8080, 18425 and 35729 free; no `.r-lock`, no unfinished capture run; the published captures unchanged (md5).
- **The exercise as viewers run it**, beyond the capture: README then SOLUTION, then SOLUTION again, in one `env -i` `zsh -f` shell → `the menu: 413 application/problem+json`, then `the menu: 200 application/json` twice, each exit 0, the shell left in `c6-unit20/`; the README's last line alone in an `env -i` `/bin/bash` shell without the exports — its `java` 23.0.1 — ends with exit 1 and prints no line; 19499 free after each.

## For unit 21 — and RED

- This unit reads `../c6-unit16/after` only (no change). Unit 21 inherits: a `StreamingResponseBody` is written on Boot's task executor
  (`task-<n>`, virtual here) after the handler returns, then an ASYNC dispatch; `Dispatches` shows the pattern (every dispatch type).
- **For RED:** re-run under both bashes, the sealed clone, SIGINT during a capture's JVM; check the 413s by status, body and
  `Connection: close` (never bytes sent); that `Refusals` changes no answer (the 413 is the probe's problem detail, byte for byte); the
  mask on Tomcat's request size; that `Accept-Ranges` has its 206; the ASCII filename and curl's choice; the exercise under Java 23 and twice
  in one shell; that no harness class reached the anchor; the 0/0 counts by line shape.
