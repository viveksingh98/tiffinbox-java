# c6-unit30 — Web Layer Performance

Course 6 · Spring Web MVC · Section 6 (Close), its second unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**
(Spring Framework 7.0.9, Tomcat 11.0.24), curl 8.7.1 (nghttp2, libz; no brotli, no zstd), 2026-10-29. Two of Boot's switches change what
crosses the wire without a line of TiffinBox changing: **compression** (the server zips the answer; the client unzips it —
`server.compression.enabled`) and **HTTP/2** (one connection, many requests at once — here **h2c**, HTTP/2 without TLS,
`server.http2.enabled`). This unit measures both on one page, **in bytes and in connections, never in a time** (brief ⚑10): bytes are
curl's `%{size_download}` from one JVM, said as bands; connections are counted off curl's own `-v` lines. And it finds the one answer
the compression switch leaves alone — the customers' list, under the floor. Payload design is **Course 9's *Sparse Fieldsets and
Compression***; HTTP/2 over TLS is **Course 10's *TLS and Transport***.

**No anchor change (brief ⚑4).** `anchor` is the link to `../c6-unit28/after` — the web-layer testing lesson's frozen tree, `c6-tiffinbox`
at Section 5's end (`diff -rq -x target c6-tiffinbox c6-unit28/after` empty on 2026-10-29) — read and copied under `.harness/`, never
built in place; this unit freezes no `after/` and touches no other unit's folder. The two switches are run-time flags on the README's run
line, labelled per run. Everything new is **the course's harness**, never TiffinBox's:

- `harness/probe/web/Unzip.java` — outside `com.tiffinbox`, **a main class compiled with `-parameters` against the anchor's own jars and
  run on the anchor's class path** (its extracted `lib/` + `.harness/hc`; not the source launcher): it asks one URL with **the JDK's
  `HttpClient`** (no header; then `Accept-Encoding: gzip` set by hand) and with **Spring's `RestClient.create()`** (its request factory
  read off the client's field `clientRequestFactory`, R.135), printing each answer's status, HTTP version (the JDK's), `Content-Encoding`,
  the bytes handed back and their md5 — nothing is decoded by the harness.
- **Tomcat's access log**, a harness option on `decode` and `h2c` only (`server.tomcat.basedir`, `server.tomcat.accesslog.*`, each read
  off `spring-boot-tomcat-4.1.1.jar`'s metadata in `which`): one line per request — method, path, protocol, status, the request's
  `Upgrade` and `Accept-Encoding`, the answer's `Content-Encoding`.
- `harness/keys.py` (the upload lesson's, byte for byte) and `harness/shutdown.sh` (the filters lesson's, byte for byte).

**No stub** (the clients are curl, the JDK's and Spring's), **no native binary, no Docker, no TLS, no browser.** A labelled capture (`aot`,
C) builds the anchor's AOT jar on a copy. Every URL is `127.0.0.1:<port>`.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 8 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top; a bare `java` on this Mac is 23.) It **dies** when a capture's md5 differs from
`receipts.md5`. **Start it in a process group of its own** (a terminal's foreground job is one): two receipts started as background jobs
of one shell share a group, and one run's clean-up would stop the other's JVMs (R.94).

**Runs of record (BLUE S6, 2026-10-30, the script as committed after RED S6):** **366 s under `./receipts.sh`** (/bin/bash 3.2.57)
and **422 s under `bash receipts.sh`** (Homebrew bash 5.3.9), each `env -i`, a process group of its own: exit 0, all 8 captures 3/3 =
published — six unchanged; `decode` `7b278aad…` → `51ba6c938eda4a91e73d960618e3b993` (the javap read of who unzips for RestClient, RED S6
#510) and `exercise` `4e025847…` → `eed9e1ac0970045666024d78fc1467e7` (the array `V` and the zsh run, #527), made by one development
run first; every check passed (health's chunked answer asserted, #529); no `grep:` line in either terminal. The exercise outside the
receipt, by BLUE S6: README + SOLUTION + SOLUTION in one `env -i /bin/zsh -f` shell and in one `env -i` bash shell → `282 bytes · none`,
then `129 bytes · gzip` twice; SOLUTION alone with `/usr/bin` (java 23.0.1) first and `JAVA_HOME` unset → `129 bytes · gzip`, under each
shell; 19596 free after each. (The runs below are the builder's, on the script before BLUE S6.) **Runs of record (2026-10-29, this
script as committed then):** **268 s under `./receipts.sh`** (/bin/bash 3.2.57, `env -i` with HOME and a
plain PATH, this folder, a session — so a process group — of its own: exit 0, all 8 captures 3/3 = published, every check passed) and
**273 s under `bash receipts.sh`** (Homebrew bash 5.3.9, the same: exit 0, all 8 = published). **A sealed fresh clone**, by the recipe
below: a `git clone` of the repository at `071f634` with this folder's files beside it (the `anchor` link by `readlink`:
`../c6-unit28/after`), `.m2-demo` absent at the start, a `file://` copy of 4,440 files made from this folder's `.m2-demo`; the pre-flight:
exit 1, 221 `Downloading from sealed: file://`, 0 from http(s) — **exit 0, all 8 = published, every check passed, 268 s**; the two
builds before the captures said `offline: no` — the configured repository was asked, the sealed one (GraalVM's metadata zip too) — and
every capture's build `offline: yes`, the AOT copy's included; **`_remote.repositories` by repository id: 605 `>sealed=` (in 405
artifact folders), 0 `central`**, no other id. **Interrupted** twice (SIGINT to the run's process group, SIGINT at its default
disposition): while `which`'s first TiffinBox listened on 127.0.0.1:19590, and while `aot`'s Maven build of the AOT copy ran — **exit
130** both times; afterwards nothing listened on 19590-19599, no process of that group was left, `.r-lock` was gone, no `.r-NAME.[123]`
was left, and the eight published captures were byte for byte what they were. The durations are the terminal's, never a capture's.


Published hashes: which `a6b542a6582d957e60266d55c88fd0bd` · switch `5e0f88c168f38f4cdf0c4442444fe639` · floor `861e5f8abd48d2643eb31dbd289f5c21` · decode `51ba6c938eda4a91e73d960618e3b993` · h2c `7895d870ccf41c3def5b48d470dbc4cc` · together `6f5a19e687d8d4d48e364fbeb1be4604` · aot `0c59fb7ae3cd4471d45d2fd30fd18d35` · exercise `eed9e1ac0970045666024d78fc1467e7`.

### A sealed fresh clone — the recipe (RED S4 #405, fixed; unit 24's)

**Paste it into bash** (type `bash` first if your Terminal is zsh): zsh does not split the unquoted `$E`, so the pre-flight would print
`NOT SEALED` — safe, but for the wrong reason (RED S6 #521).

`-Duser.home` in the sealed `.mavenrc` (Java on macOS ignores `$HOME`), Maven's own `<proxies>` at a refusing port, a mirror `*` →
`file://`; a pre-flight that refuses to start unless an absent artifact fails having asked `file://` alone; a post-check counting
`_remote.repositories` by repository id (0 `central`). The clone's first two builds (`.harness/pre`, `.harness/prea` — the plain and the
native profile) fill `.m2-demo` from the sealed copy and say `offline: no` (the configured repository was asked — the sealed one, never
Central, S6.19); GraalVM's metadata repository zip comes the same way.

```bash
S=/tmp/sealed-30                                   # an empty folder of your own; T = your tiffinbox-java clone
mkdir -p "$S/home/.m2" && git clone -q "file://$T" "$S/tiffinbox-java"
rsync -a --exclude _remote.repositories --exclude '*.lastUpdated' --exclude resolver-status.properties "$T/c6-unit30/.m2-demo/" "$S/central/"
printf 'MAVEN_OPTS="-Duser.home=%s"\n' "$S/home" > "$S/home/.mavenrc"
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
$E JAVA_HOME=/opt/homebrew/opt/openjdk@25 mvn -B -Dmaven.repo.local="$S/preflight-m2" org.apache.maven.plugins:maven-dependency-plugin:3.8.1:get -Dartifact=org.example.sealed:absent:1 > "$S/preflight.log" 2>&1
[ $? != 0 ] && grep -q 'Downloading from sealed: file://' "$S/preflight.log" && ! grep -qE 'Downloading from [^ ]+: https?://' "$S/preflight.log" && echo "sealed: file:// only" || echo "NOT SEALED - do not run receipts.sh"
[ "$(readlink "$S/tiffinbox-java/c6-unit30/anchor")" = ../c6-unit28/after ] && echo "anchor: the link" || echo "anchor is not the link"
cd "$S/tiffinbox-java/c6-unit30" && $E ./receipts.sh            # a process group of its own
find .m2-demo -name _remote.repositories -exec cat {} + | grep -o '>[^=]*=' | sort | uniq -c
```

The clone's files beside it: this folder's files are copied into the clone's `c6-unit30/` before the run when the unit is not committed
yet (`rsync -a --exclude .m2-demo --exclude .harness --exclude '.r-*'`); a clone of the committed repository has them already.

## The commands this unit adds

```bash
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/probe/web/Unzip.java
java -Duser.language=en -Duser.country=US -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:.harness/hc" probe.web.Unzip http://127.0.0.1:18431/customers
python3 harness/keys.py .harness/anchor/tiffinbox-web/target/extracted/lib/spring-boot-web-server-4.1.1.jar server.compression
python3 harness/keys.py .harness/anchor/tiffinbox-web/target/extracted/lib/spring-boot-web-server-4.1.1.jar server.http2
python3 harness/keys.py .harness/anchor/tiffinbox-web/target/extracted/lib/spring-boot-tomcat-4.1.1.jar server.tomcat.accesslog
curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' http://127.0.0.1:18431/customers
curl -s -o .harness/body.bin -w '%{http_code} %{http_version} %{size_download}' http://127.0.0.1:18431/customers
curl -s -v -o /dev/null http://127.0.0.1:18431/customers 2> .harness/v.txt
curl -s -v -Z -H 'Accept: text/html' -o /dev/null -o /dev/null -w '%{http_version} ' http://127.0.0.1:18431/dashboard http://127.0.0.1:18431/css/tiffinbox.css 2> .harness/v.txt
curl -s -o /dev/null -w '%{http_code}' -H 'Content-Type: application/json' --data '{"name":"Guest1","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:18431/customers
jcmd "$pid" VM.system_properties
grep -n -A1 'virtual threads too. Under Spring.s AOT step' anchor/tiffinbox-web/src/main/resources/application.yaml
javap -cp .harness/anchor/tiffinbox-web/target/extracted/lib/spring-web-7.0.9.jar -p org.springframework.http.client.JdkClientHttpRequestFactory 'org.springframework.http.client.JdkClientHttpRequest$DecompressingBodyHandler'
```

`anchor/README.md` — the anchor's own — gives seven lines `receipts.sh` runs or derives from (`mvn -B package`, `mvn -B -Pnative
package`, the run line, the extract line, the readiness line, the line that reads the stylesheet's URL off the page, and the AOT run
line whose three extra options are left off here); the fifteen above are this unit's, each read from this block and asserted (on the
anchor's port 18431; each capture swaps in its own port, path and curl options; `/css/tiffinbox.css` stands for the URL read off the
page). The run lines are the anchor's with `-Duser.language=en -Duser.country=US` after `java` — asserted — and the AOT line is that line
with `-Dspring.aot.enabled=true`, asserted. The options a capture adds after the run line, each spelled from Boot's metadata (a last
check refuses any `--server.*` option, and any `server.compression.*`/`server.http2.*` name, that the metadata of
`spring-boot-web-server` and `spring-boot-tomcat` does not declare, R.138): `--server.compression.enabled=true`,
`--server.http2.enabled=true`, the exercise's `--server.compression.min-response-size=128`, and the access log —
`--server.tomcat.basedir=../tomcat --server.tomcat.accesslog.enabled=true --server.tomcat.accesslog.rotate=false
--server.tomcat.accesslog.buffered=false '--server.tomcat.accesslog.pattern=%m %U %H %s upgrade:%{Upgrade}i accept-encoding:%{Accept-Encoding}i content-encoding:%{Content-Encoding}o'`.
`jcmd "$pid" VM.system_properties` reads the JVM's locale off its pid (`$pid` is the JVM the capture started). The `javap` line
(BLUE S6, RED S6 #510, R.134) reads who unzips for RestClient off spring-web 7.0.9's jar: `JdkClientHttpRequestFactory`'s
`compression` field and `enableCompression(boolean)`, and `JdkClientHttpRequest$DecompressingBodyHandler` with its `decompressStream` —
printed in `decode` by a declared filter, `class |ompression|decompress`, 5 of its 22 lines kept. The curl `-v` lines
write to `.harness/v.txt`; the file is read after curl exits (S6.8).

## The repository, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from `../../spring-web-mvc/_research/m2-seed-s6/`
alone — 5,925 files (the seed's 5,926 less Finder's `.DS_Store`), no `com/tiffinbox`. **Nothing was downloaded** for this unit: every
build said `offline: yes`, `.m2-demo` held 5,925 files before the first run and after the last, and the AOT build gained 0 files
(`aot`). GraalVM's native plugin reads its reachability-metadata repository from `.m2-demo` (`Downloaded … from file:`, counted); a log
line saying it went to http(s) stops the run (checked on a planted log first). At run time every request goes to `127.0.0.1`, and
nothing binds 8080, 18425, 35729 or 19599.

## The demo token — fake, and never printed

`TOKEN=` at the top of `receipts.sh`, 33 characters, fake and meant to look it, written into each copy's
`secrets/tiffinbox/shutdown-token` (a config tree, mode 0600, git-ignored), sent only by `../c5-unit11/curlset.sh` and
`harness/shutdown.sh` on curl's standard input. Every capture's raw output is searched for it before masking (0 in all of them), and so
are the log of every JVM that ran and every file this unit ships: 0 everywhere; `X-Shutdown-Token` 0 in every log. The exercise makes a
token of its own (`openssl rand -hex 13`), counted 0 times in its log, never printed. **One file in `secrets/` is a key** (R.158, S6.29):
before every start the script lists the copy's `secrets/` — the token's file and nothing else, or it stops. This unit runs no TLS, so no
second secret exists.

## The locale — pinned per JVM, read off its pid, asserted

Every java line this script starts carries `-Duser.language=en -Duser.country=US` right after `java` (S6.1); TiffinBox's locale is read
off its pid (`jcmd`), `Unzip` prints its own — `en_US`, asserted in every capture. No request sends `Accept-Language`, and no answer here
is a message in a language.

## The folders and the ports

- `.harness/pre`, `.harness/prea` — the anchor built before any capture (plain; native profile); `.harness/anchor` — the anchor, copied,
  with a config tree, built and extracted (`which`); `.harness/hc` — the harness's class; `.harness/aot` — the AOT copy (`aot`);
  `.harness/tomcat/logs/access_log.log` — the access log; `.harness/v.txt` — curl's `-v` lines; `.harness/f-N.bin` — the fetches' saved
  bytes; `.harness/mine` — the exercise's copy; `.harness/curlhome` — an empty `CURL_HOME`, so no `~/.curlrc` of yours reaches a request.
- **Ports** (brief ⚑1, 19590-19599): TiffinBox 19590-19596, one JVM at a time, each asserted free before its start (`which` 19590-19592;
  `switch` 19590-19591; `floor` 19590; `decode` 19591; `h2c` 19590-19591; `together` 19592; `aot` 19593-19594; the exercise 19596);
  **19599 never bound** (asserted free, `which`); 19595, 19597, 19598 unused. Every TiffinBox is stopped by POST /shutdown and its pid
  waited for; nothing is stopped by name.

## Masks, filters and hygiene — every one, declared

1. **Paths, the token, the user** (`gsub()`, literals escaped): the token → `[masked: the 33-character token]`; this folder → `…`; the
   folder above → `…/..`; home → `~`; the user name → `<user>`. **The JDK's version in Boot's first line** → ` using Java <version>`
   (R.151, printed once on the terminal). **Tomcat's connector name** `http-nio-127.0.0.1-<digits>` → `http-nio-127.0.0.1-<port>` (S6.22;
   no capture prints one, the mask runs). curl's version is printed on the terminal only; its `HTTP2` and `libz` features are asserted.
   A last check refuses an absolute path, a unit number, Boot's process line, a log time, a JDK version, a connector port, a `Date`
   header, a carriage return, an unmasked timestamp, **a duration word**, **a TLS line**, `:8080`/`:35729`/`:18425/`, and a command with a
   URL that is not `127.0.0.1`'s.
2. **An answer** (`fetch`): curl's status and `%{size_download}`, the md5 of the bytes it saved; **every header line counted** (the status
   line among them), **kept by `^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): `** (any case; `Date` is among
   the dropped); for an answer that says `Content-Encoding: gzip` and was saved as it came, `gunzip -c`'s bytes and md5. Checked on a
   planted header block first.
3. **A version line** (`ver`): status, `%{http_version}` (0 for no answer), bytes, the saved bytes' md5 or `nothing saved`, curl's exit.
4. **curl's `-v` lines** (`verb`): written to a file, then read; counted; kept by `^(> GET |> Connection: |> Upgrade: |> HTTP2-Settings: |<
   HTTP/|< Connection: |< Upgrade: |\* Received 101)` (any case). **In parallel** (`par`): kept by `^\* (Connected to |Multiplexed
   connection found|Re-using existing connection|Server doesn't support multiplex)`, the port masked, `sort | uniq -c` (order-free), and
   the `Connected to` lines counted. Both checked on planted files first.
5. **The access log** (`alog`): its lines after a mark taken once readiness has settled — every GET whole, the POSTs counted.
6. **`Unzip`**: its `UNZIP` lines whole, its other lines counted (0).
7. **Log lines**: from their logger on (the seven's 405 WARN is **Spring MVC's** `o.s.web.servlet.PageNotFound`); WARN/ERROR counted by
   the log's own line shape (checked on a planted log first).
8. **A′ against A**: compared line for line in the capture itself (`yes`).
9. **No duration** anywhere (⚑10): no capture prints one, and a check refuses one.

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops TiffinBox or the Maven build (`$pid`, with
every process under it) and the exercise's shell (`$xpid`, likewise), sweeps its own process group for any TiffinBox JVM, `Unzip` JVM or
Maven left, deletes the capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched.
No `wait` is bare (R.105; a check refuses one); nothing is stopped by name (a check refuses it).

## 1 · which — Boot's keys from its own metadata; the seven; the key off and the key on, gzip asked and not

`.r-which.out`, md5 `a6b542a6582d957e60266d55c88fd0bd`, 3 of 3 — whole:

```
the anchor - anchor/, copied under .harness/ with a config tree, built with its README's line (offline), its jar extracted (the README's line):
$ cd .harness/anchor && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the anchor · offline: yes · exit 0
$ cd .harness/anchor && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
  the anchor's libraries (its extracted lib/): 61 · httpclient5, Jetty's or Reactor Netty's client among them: 0
Boot's keys - what spring-boot-web-server's own metadata declares under server.compression and server.http2 (this unit's lines):
$ python3 harness/keys.py .harness/anchor/tiffinbox-web/target/extracted/lib/spring-boot-web-server-4.1.1.jar server.compression
  server.compression.additional-mime-types · default [] · String[]
  server.compression.enabled · default false · Boolean
  server.compression.excluded-user-agents · default none · String[]
  server.compression.mime-types · default ['text/html', 'text/xml', 'text/plain', 'text/css', 'text/javascript', 'application/javascript', 'application/json', 'application/xml'] · String[]
  server.compression.min-response-size · default 2KB · DataSize
  5 keys under server.compression
  the default of server.compression.mime-types, entry by entry: 8 types - text/html · text/xml · text/plain · text/css · text/javascript · application/javascript · application/json · application/xml
$ python3 harness/keys.py .harness/anchor/tiffinbox-web/target/extracted/lib/spring-boot-web-server-4.1.1.jar server.http2
  server.http2.enabled · default false · Boolean
  1 keys under server.http2
  the jars on the class path whose metadata declares server.compression.enabled: spring-boot-web-server-4.1.1.jar
the access log's keys - what spring-boot-tomcat's metadata declares under server.tomcat.accesslog (this unit's line; the harness's option for decode and h2c):
$ python3 harness/keys.py .harness/anchor/tiffinbox-web/target/extracted/lib/spring-boot-tomcat-4.1.1.jar server.tomcat.accesslog
  server.tomcat.accesslog.buffered · default true · Boolean
  server.tomcat.accesslog.check-exists · default false · Boolean
  server.tomcat.accesslog.condition-if · default none · String
  server.tomcat.accesslog.condition-unless · default none · String
  server.tomcat.accesslog.directory · default logs · String
  server.tomcat.accesslog.enabled · default false · Boolean
  server.tomcat.accesslog.encoding · default none · String
  server.tomcat.accesslog.file-date-format · default .yyyy-MM-dd · String
  server.tomcat.accesslog.ipv6-canonical · default false · Boolean
  server.tomcat.accesslog.locale · default none · String
  server.tomcat.accesslog.max-days · default -1 · Integer
  server.tomcat.accesslog.pattern · default common · String
  server.tomcat.accesslog.prefix · default access_log · String
  server.tomcat.accesslog.rename-on-rotate · default false · Boolean
  server.tomcat.accesslog.request-attributes-enabled · default false · Boolean
  server.tomcat.accesslog.rotate · default true · Boolean
  server.tomcat.accesslog.suffix · default .log · String
  17 keys under server.tomcat.accesslog
  server.tomcat.basedir in that metadata: 1
the harness, compiled against the anchor's own jars (this unit's line):
$ javac -parameters -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*" harness/probe/web/Unzip.java
  exit 0 · what javac printed: 0 lines · its classes: probe/web/Unzip.class
  19599, never bound: listening 0 (lsof, by port)
the seven - the anchor, the README's run line (its locale pinned), port 19590, a fresh JVM:
  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19590
  listens on: 127.0.0.1:19590 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
  the JVM's locale, read off its pid (this unit's jcmd line): en_US
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19590/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19590 .harness/anchor/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 application/problem+json  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"}
  GET   /shutdown   -> 405 application/problem+json  {"detail":"Method 'GET' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  the log's WARN and ERROR records during the seven: 1
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the key off - the README's run line, port 19591, a fresh JVM:
  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19591
  listens on: 127.0.0.1:19591 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
  the JVM's locale, read off its pid (this unit's jcmd line): en_US
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19591/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -H 'Accept: text/html' http://127.0.0.1:19591/dashboard | grep -o '/css/[^"]*'
  the stylesheet's URL, read off the page: /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  the page - /dashboard, Accept: text/html:
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept: text/html' http://127.0.0.1:19591/dashboard
  -> 200 962 · md5 94eb3463816e1a310cbc1827ed825692 · its header lines: 5 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2
    Content-Type: text/html;charset=UTF-8
    Transfer-Encoding: chunked
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept: text/html' -H 'Accept-Encoding: gzip' http://127.0.0.1:19591/dashboard
  -> 200 962 · md5 94eb3463816e1a310cbc1827ed825692 · its header lines: 5 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2
    Content-Type: text/html;charset=UTF-8
    Transfer-Encoding: chunked
  the form page - /customers/new, Accept: text/html:
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept: text/html' http://127.0.0.1:19591/customers/new
  -> 200 839 · md5 87df349ae83a86f946fe185e5931153f · its header lines: 5 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2
    Content-Type: text/html;charset=UTF-8
    Transfer-Encoding: chunked
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept: text/html' -H 'Accept-Encoding: gzip' http://127.0.0.1:19591/customers/new
  -> 200 839 · md5 87df349ae83a86f946fe185e5931153f · its header lines: 5 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2
    Content-Type: text/html;charset=UTF-8
    Transfer-Encoding: chunked
  the customers' list - /customers:
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' http://127.0.0.1:19591/customers
  -> 200 282 · md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0 · its header lines: 4 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2
    Content-Type: application/json
    Content-Length: 282
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept-Encoding: gzip' http://127.0.0.1:19591/customers
  -> 200 282 · md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0 · its header lines: 4 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2
    Content-Type: application/json
    Content-Length: 282
  the stylesheet:
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' http://127.0.0.1:19591/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  -> 200 200 · md5 10ba2401fd96e2e382866a731d207fc4 · its header lines: 8 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2
    Content-Type: text/css
    Content-Length: 200
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept-Encoding: gzip' http://127.0.0.1:19591/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  -> 200 200 · md5 10ba2401fd96e2e382866a731d207fc4 · its header lines: 8 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2
    Content-Type: text/css
    Content-Length: 200
  health - /actuator/health:
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' http://127.0.0.1:19591/actuator/health
  -> 200 49 · md5 8678391b43e666ea32ff2bb1f627ab90 · its header lines: 4 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2
    Content-Type: application/vnd.spring-boot.actuator.v3+json
    Transfer-Encoding: chunked
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept-Encoding: gzip' http://127.0.0.1:19591/actuator/health
  -> 200 49 · md5 8678391b43e666ea32ff2bb1f627ab90 · its header lines: 4 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2
    Content-Type: application/vnd.spring-boot.actuator.v3+json
    Transfer-Encoding: chunked
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19591 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19591 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the key on - the README's run line and --server.compression.enabled=true, port 19592, a fresh JVM - then the seven:
  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19592 --server.compression.enabled=true
  listens on: 127.0.0.1:19592 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
  the JVM's locale, read off its pid (this unit's jcmd line): en_US
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19592/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -H 'Accept: text/html' http://127.0.0.1:19592/dashboard | grep -o '/css/[^"]*'
  the stylesheet's URL, read off the page: /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  the page - /dashboard, Accept: text/html:
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept: text/html' http://127.0.0.1:19592/dashboard
  -> 200 962 · md5 94eb3463816e1a310cbc1827ed825692 · its header lines: 6 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 3
    vary: accept-encoding
    Content-Type: text/html;charset=UTF-8
    Transfer-Encoding: chunked
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept: text/html' -H 'Accept-Encoding: gzip' http://127.0.0.1:19592/dashboard
  -> 200 477 · md5 9f593240fa15ea6cef5fffe7f2f4f253 · its header lines: 7 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 4
    vary: accept-encoding
    Content-Encoding: gzip
    Content-Type: text/html;charset=UTF-8
    Transfer-Encoding: chunked
  gunzip -c, the saved bytes: 962 bytes · md5 94eb3463816e1a310cbc1827ed825692
  the form page - /customers/new, Accept: text/html:
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept: text/html' http://127.0.0.1:19592/customers/new
  -> 200 839 · md5 87df349ae83a86f946fe185e5931153f · its header lines: 6 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 3
    vary: accept-encoding
    Content-Type: text/html;charset=UTF-8
    Transfer-Encoding: chunked
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept: text/html' -H 'Accept-Encoding: gzip' http://127.0.0.1:19592/customers/new
  -> 200 435 · md5 ef3feebb3c160a0b465c42715aa989bb · its header lines: 7 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 4
    vary: accept-encoding
    Content-Encoding: gzip
    Content-Type: text/html;charset=UTF-8
    Transfer-Encoding: chunked
  gunzip -c, the saved bytes: 839 bytes · md5 87df349ae83a86f946fe185e5931153f
  the customers' list - /customers:
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' http://127.0.0.1:19592/customers
  -> 200 282 · md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0 · its header lines: 4 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2
    Content-Type: application/json
    Content-Length: 282
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept-Encoding: gzip' http://127.0.0.1:19592/customers
  -> 200 282 · md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0 · its header lines: 4 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2
    Content-Type: application/json
    Content-Length: 282
  the stylesheet:
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' http://127.0.0.1:19592/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  -> 200 200 · md5 10ba2401fd96e2e382866a731d207fc4 · its header lines: 8 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2
    Content-Type: text/css
    Content-Length: 200
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept-Encoding: gzip' http://127.0.0.1:19592/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  -> 200 200 · md5 10ba2401fd96e2e382866a731d207fc4 · its header lines: 8 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2
    Content-Type: text/css
    Content-Length: 200
  health - /actuator/health:
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' http://127.0.0.1:19592/actuator/health
  -> 200 49 · md5 8678391b43e666ea32ff2bb1f627ab90 · its header lines: 4 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2
    Content-Type: application/vnd.spring-boot.actuator.v3+json
    Transfer-Encoding: chunked
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept-Encoding: gzip' http://127.0.0.1:19592/actuator/health
  -> 200 49 · md5 8678391b43e666ea32ff2bb1f627ab90 · its header lines: 4 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2
    Content-Type: application/vnd.spring-boot.actuator.v3+json
    Transfer-Encoding: chunked
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ $CURLSET 19592 .harness/anchor/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 application/problem+json  {"detail":"No static resource nowhere.","instance":"/nowhere","status":404,"title":"Not Found"}
  GET   /shutdown   -> 405 application/problem+json  {"detail":"Method 'GET' is not supported.","instance":"/shutdown","status":405,"title":"Method Not Allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  the log's WARN and ERROR records during the seven: 1
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

**Read:** Boot 4.1.1's `spring-boot-web-server` metadata declares **five** `server.compression` keys (the brief named three: `additional-mime-types` and `excluded-user-agents` are there too) — `enabled` **false**, `min-response-size` **2KB**, `mime-types` with **8** entries, counted one by one — and `server.http2.enabled` **false**. With the key off, gzip asked or not, nothing is compressed and no `Vary` is sent. With the key on and gzip asked: **the page 962 → 477** (`Content-Encoding: gzip` beside `Transfer-Encoding: chunked`, `vary: accept-encoding`), **the form page 839 → 435**, **`/customers` 282 → 282** (`Content-Length: 282`, no `Content-Encoding`), **the stylesheet 200 → 200** (`Content-Length: 200`), **health 49 → 49** (`application/vnd.spring-boot.actuator.v3+json` is not on the list). The unzipped pages have the plain pages' md5s. `vary` appears on the four page answers only — measured, sharper than the probe's "every compressible type". The seven `466c20ed…` on the README's run line and again with the key on (curl's seven ask no gzip): a header claim is read off `curl -D`, never off the seven (R.153). The stylesheet's URL is read off the page by the anchor's README line, never typed.
## 2 · switch — A/B/A′: the key on; no key, gzip asked all the same; A again

`.r-switch.out`, md5 `5e0f88c168f38f4cdf0c4442444fe639`, 3 of 3 — whole:

```
A - the key on: the README's run line and --server.compression.enabled=true, port 19590, a fresh JVM:
  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19590 --server.compression.enabled=true
  listens on: 127.0.0.1:19590 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
  the JVM's locale, read off its pid (this unit's jcmd line): en_US
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19590/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept: text/html' http://127.0.0.1:19590/dashboard
  -> 200 962 · md5 94eb3463816e1a310cbc1827ed825692 · its header lines: 6 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 3
    vary: accept-encoding
    Content-Type: text/html;charset=UTF-8
    Transfer-Encoding: chunked
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept: text/html' -H 'Accept-Encoding: gzip' http://127.0.0.1:19590/dashboard
  -> 200 477 · md5 9f593240fa15ea6cef5fffe7f2f4f253 · its header lines: 7 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 4
    vary: accept-encoding
    Content-Encoding: gzip
    Content-Type: text/html;charset=UTF-8
    Transfer-Encoding: chunked
  gunzip -c, the saved bytes: 962 bytes · md5 94eb3463816e1a310cbc1827ed825692
  the unzipped page against the plain one, md5 for md5: the same
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19590 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19590 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - no key: the README's run line alone, port 19591, a fresh JVM:
  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19591
  listens on: 127.0.0.1:19591 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
  the JVM's locale, read off its pid (this unit's jcmd line): en_US
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19591/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept: text/html' http://127.0.0.1:19591/dashboard
  -> 200 962 · md5 94eb3463816e1a310cbc1827ed825692 · its header lines: 5 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2
    Content-Type: text/html;charset=UTF-8
    Transfer-Encoding: chunked
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept: text/html' -H 'Accept-Encoding: gzip' http://127.0.0.1:19591/dashboard
  -> 200 962 · md5 94eb3463816e1a310cbc1827ed825692 · its header lines: 5 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2
    Content-Type: text/html;charset=UTF-8
    Transfer-Encoding: chunked
  no Content-Encoding: the bytes with gzip asked against the plain ones, md5 for md5: the same
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19591 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19591 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, port 19590, a fresh JVM:
  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19590 --server.compression.enabled=true
  listens on: 127.0.0.1:19590 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
  the JVM's locale, read off its pid (this unit's jcmd line): en_US
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19590/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept: text/html' http://127.0.0.1:19590/dashboard
  -> 200 962 · md5 94eb3463816e1a310cbc1827ed825692 · its header lines: 6 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 3
    vary: accept-encoding
    Content-Type: text/html;charset=UTF-8
    Transfer-Encoding: chunked
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept: text/html' -H 'Accept-Encoding: gzip' http://127.0.0.1:19590/dashboard
  -> 200 477 · md5 9f593240fa15ea6cef5fffe7f2f4f253 · its header lines: 7 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 4
    vary: accept-encoding
    Content-Encoding: gzip
    Content-Type: text/html;charset=UTF-8
    Transfer-Encoding: chunked
  gunzip -c, the saved bytes: 962 bytes · md5 94eb3463816e1a310cbc1827ed825692
  the unzipped page against the plain one, md5 for md5: the same
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19590 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19590 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
```

**A** `--server.compression.enabled=true`: the page 962 plain, **477 with gzip asked**, unzipped = the plain md5 (`94eb3463…`). **B** no key: gzip asked → **962, no `Content-Encoding`**, the same bytes as plain. **A′** = A, its `$` line shown (S6.2); compared line for line in the capture: `yes`.
## 3 · floor — the list under the floor, then grown past it

`.r-floor.out`, md5 `861e5f8abd48d2643eb31dbd289f5c21`, 3 of 3 — whole:

```
the floor - the key on, port 19590, a fresh JVM (it is POSTed to: no other capture's JVM):
  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19590 --server.compression.enabled=true
  listens on: 127.0.0.1:19590 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
  the JVM's locale, read off its pid (this unit's jcmd line): en_US
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19590/actuator/health/readiness
  {"status":"UP"} 200
  the floor in force: server.compression.min-response-size not on the run line - Boot's default, from its metadata (which)
  the list as TiffinBox starts, gzip asked:
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept-Encoding: gzip' http://127.0.0.1:19590/customers
  -> 200 282 · md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0 · its header lines: 4 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2
    Content-Type: application/json
    Content-Length: 282
  grown - thirty customers added:
$ curl -s -o /dev/null -w '%{http_code}' -H 'Content-Type: application/json' --data '{"name":"Guest1","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19590/customers   (then the same with Guest2 ... Guest30)
  their statuses: 201 ×30
  round 1 - plain, then gzip asked:
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' http://127.0.0.1:19590/customers
  -> 200 2403 · md5 bc5535748533a4c827adf3935546b84b · its header lines: 5 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 3
    vary: accept-encoding
    Content-Type: application/json
    Content-Length: 2403
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept-Encoding: gzip' http://127.0.0.1:19590/customers
  -> 200 229 · md5 557506580848e47c344634ee01314d0e · its header lines: 6 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 4
    vary: accept-encoding
    Content-Encoding: gzip
    Content-Type: application/json
    Transfer-Encoding: chunked
  gunzip -c, the saved bytes: 2403 bytes · md5 bc5535748533a4c827adf3935546b84b
  round 1: the unzipped list against the plain one, md5 for md5: the same
  round 1: the gzip bytes against round 1's, md5 for md5: the same
  round 2 - plain, then gzip asked:
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' http://127.0.0.1:19590/customers
  -> 200 2403 · md5 bc5535748533a4c827adf3935546b84b · its header lines: 5 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 3
    vary: accept-encoding
    Content-Type: application/json
    Content-Length: 2403
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept-Encoding: gzip' http://127.0.0.1:19590/customers
  -> 200 229 · md5 557506580848e47c344634ee01314d0e · its header lines: 6 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 4
    vary: accept-encoding
    Content-Encoding: gzip
    Content-Type: application/json
    Transfer-Encoding: chunked
  gunzip -c, the saved bytes: 2403 bytes · md5 bc5535748533a4c827adf3935546b84b
  round 2: the unzipped list against the plain one, md5 for md5: the same
  round 2: the gzip bytes against round 1's, md5 for md5: the same
  round 3 - plain, then gzip asked:
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' http://127.0.0.1:19590/customers
  -> 200 2403 · md5 bc5535748533a4c827adf3935546b84b · its header lines: 5 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 3
    vary: accept-encoding
    Content-Type: application/json
    Content-Length: 2403
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept-Encoding: gzip' http://127.0.0.1:19590/customers
  -> 200 229 · md5 557506580848e47c344634ee01314d0e · its header lines: 6 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 4
    vary: accept-encoding
    Content-Encoding: gzip
    Content-Type: application/json
    Transfer-Encoding: chunked
  gunzip -c, the saved bytes: 2403 bytes · md5 bc5535748533a4c827adf3935546b84b
  round 3: the unzipped list against the plain one, md5 for md5: the same
  round 3: the gzip bytes against round 1's, md5 for md5: the same
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19590 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19590 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

The floor in force is Boot's default (no `min-response-size` on the run line; `2KB` from the metadata, `which`). `/customers` with gzip asked: **282 B, `Content-Length: 282`, not compressed**. Thirty POSTs in this JVM only (R.97; `201 ×30`). Grown: **2,403 B with `Content-Length: 2403`** (and `vary` — over the floor, compressible) → gzip asked **229 B, `Content-Encoding: gzip`, `Transfer-Encoding: chunked`** (the compressed answer loses its length); three rounds, the gzip bytes `55750658…` each time, unzipped = the plain `bc553574…` each time. **Why the page was zipped below the floor:** Tomcat tests the floor against a *known length* — the page is a chunked answer (no `Content-Length`), so there is nothing to test; `/customers` says its length. Never "answers under 2 KB are never compressed" (R.157). 229/2,403 is **about a tenth — a list of near-identical rows**, this list (S6.14); 477/962 **about half**, this page.
## 4 · decode — who unzips: curl, the JDK's HttpClient, RestClient — and Tomcat's access log

`.r-decode.out`, md5 `51ba6c938eda4a91e73d960618e3b993`, 3 of 3 — whole:

```
who unzips - the key on, Tomcat's access log on (the harness's options), port 19591, a fresh JVM, the list grown past the floor:
  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19591 --server.compression.enabled=true --server.tomcat.basedir=../tomcat --server.tomcat.accesslog.enabled=true --server.tomcat.accesslog.rotate=false --server.tomcat.accesslog.buffered=false '--server.tomcat.accesslog.pattern=%m %U %H %s upgrade:%{Upgrade}i accept-encoding:%{Accept-Encoding}i content-encoding:%{Content-Encoding}o'
  listens on: 127.0.0.1:19591 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
  the JVM's locale, read off its pid (this unit's jcmd line): en_US
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19591/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}' -H 'Content-Type: application/json' --data '{"name":"Guest1","mealsPerDay":2,"pricePerMeal":110,"mealType":"VEG"}' http://127.0.0.1:19591/customers   (then the same with Guest2 ... Guest30)
  their statuses: 201 ×30
  curl, plain:
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' http://127.0.0.1:19591/customers
  -> 200 2403 · md5 bc5535748533a4c827adf3935546b84b · its header lines: 5 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 3
    vary: accept-encoding
    Content-Type: application/json
    Content-Length: 2403
  curl, gzip asked by hand:
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept-Encoding: gzip' http://127.0.0.1:19591/customers
  -> 200 229 · md5 557506580848e47c344634ee01314d0e · its header lines: 6 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 4
    vary: accept-encoding
    Content-Encoding: gzip
    Content-Type: application/json
    Transfer-Encoding: chunked
  gunzip -c, the saved bytes: 2403 bytes · md5 bc5535748533a4c827adf3935546b84b
  curl --compressed (it asks, and unzips what it saves):
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' --compressed http://127.0.0.1:19591/customers
  -> 200 229 · md5 bc5535748533a4c827adf3935546b84b · its header lines: 6 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 4
    vary: accept-encoding
    Content-Encoding: gzip
    Content-Type: application/json
    Transfer-Encoding: chunked
  curl --compressed's saved bytes against the plain list, md5 for md5: the same · against the gzip bytes: they differ
  the md5s to compare the clients' lines with - the plain list: bc5535748533a4c827adf3935546b84b · the gzip bytes: 557506580848e47c344634ee01314d0e
  the JDK's HttpClient and Spring's RestClient - the harness's Unzip, on the anchor's class path (this unit's line):
$ java -Duser.language=en -Duser.country=US -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:.harness/hc" probe.web.Unzip http://127.0.0.1:19591/customers
  exit 0 · its UNZIP lines: 7 · its other lines: 0
    the JVM's locale: en_US
    the JDK's HttpClient: its default version HTTP_2
    the JDK's HttpClient, no header added -> 200 HTTP_1_1 | Content-Encoding: none | bytes handed back: 2403 | md5 bc5535748533a4c827adf3935546b84b
    the JDK's HttpClient, Accept-Encoding: gzip set by hand -> 200 HTTP_1_1 | Content-Encoding: gzip | bytes handed back: 229 | md5 557506580848e47c344634ee01314d0e
    RestClient.create(): its request factory org.springframework.http.client.JdkClientHttpRequestFactory
    RestClient.create(), no header added -> 200 | Content-Encoding: none | bytes handed back: 2403 | md5 bc5535748533a4c827adf3935546b84b
  Tomcat's access log since the mark (after readiness) (the harness's pattern - the method, the path, the protocol, the status, the request's Upgrade and Accept-Encoding, the answer's Content-Encoding; - for none): 36 lines, 30 of them POSTs (not shown)
    GET /customers HTTP/1.1 200 upgrade:- accept-encoding:- content-encoding:-
    GET /customers HTTP/1.1 200 upgrade:- accept-encoding:gzip content-encoding:gzip
    GET /customers HTTP/1.1 200 upgrade:- accept-encoding:deflate, gzip content-encoding:gzip
    GET /customers HTTP/1.1 200 upgrade:h2c accept-encoding:- content-encoding:-
    GET /customers HTTP/1.1 200 upgrade:h2c accept-encoding:gzip content-encoding:gzip
    GET /customers HTTP/1.1 200 upgrade:h2c accept-encoding:gzip,deflate content-encoding:gzip
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19591 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19591 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  who unzips for RestClient - read off spring-web's jar (this unit's javap line), kept by the declared filter 'class |ompression|decompress':
$ javap -cp .harness/anchor/tiffinbox-web/target/extracted/lib/spring-web-7.0.9.jar -p org.springframework.http.client.JdkClientHttpRequestFactory 'org.springframework.http.client.JdkClientHttpRequest$DecompressingBodyHandler'
  javap's lines: 22 · kept: 5
    public class org.springframework.http.client.JdkClientHttpRequestFactory implements org.springframework.http.client.ClientHttpRequestFactory {
    private boolean compression;
    public void enableCompression(boolean);
    final class org.springframework.http.client.JdkClientHttpRequest$DecompressingBodyHandler implements java.net.http.HttpResponse$BodyHandler<java.io.InputStream> {
    private static java.io.InputStream decompressStream(java.io.InputStream, java.lang.String);
```

The list grown past the floor (a fresh JVM, 30 POSTs). `curl --compressed`: **229 B on the wire, the plain md5 saved**. The harness's `Unzip` (a main class compiled with `-parameters` against the anchor's `lib/`, run on that class path — not the source launcher): **the JDK's `HttpClient` with no header → 2,403 B plain; with `Accept-Encoding: gzip` set by hand → `Content-Encoding: gzip`, 229 bytes handed back, the gzip md5 — the JDK's HttpClient does not unzip**; **`RestClient.create()` — its request factory read off the client: `JdkClientHttpRequestFactory` (no httpclient5, Jetty or Reactor Netty client on this class path, asserted) — → 2,403 B, the plain md5, no `Content-Encoding` left**. **Tomcat's access log** (a harness option: `server.tomcat.*` keys from `spring-boot-tomcat`'s metadata, the log under `.harness/tomcat/logs`) shows each request: curl `--compressed` asked `deflate, gzip`, the JDK client `gzip`, RestClient **`gzip,deflate`** — the header the *RestClient* lesson's stub printed — and each was sent `content-encoding:gzip`. So RestClient was sent gzip and unzipped it (gzip only; deflate not measured). The JDK client and RestClient each offer `upgrade: h2c` on their first request (ignored here: HTTP/2 off).
## 5 · h2c — A/B/A′: HTTP/2 without TLS on Tomcat 11.0.24

`.r-h2c.out`, md5 `7895d870ccf41c3def5b48d470dbc4cc`, 3 of 3 — whole:

```
A - HTTP/2 on: the README's run line, --server.http2.enabled=true and the access log (the harness's options), port 19590, a fresh JVM:
  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19590 --server.http2.enabled=true --server.tomcat.basedir=../tomcat --server.tomcat.accesslog.enabled=true --server.tomcat.accesslog.rotate=false --server.tomcat.accesslog.buffered=false '--server.tomcat.accesslog.pattern=%m %U %H %s upgrade:%{Upgrade}i accept-encoding:%{Accept-Encoding}i content-encoding:%{Content-Encoding}o'
  listens on: 127.0.0.1:19590 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
  the JVM's locale, read off its pid (this unit's jcmd line): en_US
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19590/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -v --http2 -o /dev/null http://127.0.0.1:19590/customers 2> .harness/v.txt
  curl exit 0 · its -v lines: 25 · kept, by ^(> GET |> Connection: |> Upgrade: |> HTTP2-Settings: |< HTTP/|< Connection: |< Upgrade: |\* Received 101) (any case): 9
    > GET /customers HTTP/1.1
    > Connection: Upgrade, HTTP2-Settings
    > Upgrade: h2c
    > HTTP2-Settings: AAMAAABkAAQAoAAAAAIAAAAA
    < HTTP/1.1 101 
    < Connection: Upgrade
    < Upgrade: h2c
    * Received 101, Switching to HTTP/2
    < HTTP/2 200 
$ curl -s -o .harness/body.bin -w '%{http_code} %{http_version} %{size_download}' http://127.0.0.1:19590/customers
  -> 200 1.1 282 · md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0 · curl exit 0
$ curl -s -o .harness/body.bin -w '%{http_code} %{http_version} %{size_download}' --http2 http://127.0.0.1:19590/customers
  -> 200 2 282 · md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0 · curl exit 0
$ curl -s -o .harness/body.bin -w '%{http_code} %{http_version} %{size_download}' --http2-prior-knowledge http://127.0.0.1:19590/customers
  -> 200 2 282 · md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0 · curl exit 0
$ java -Duser.language=en -Duser.country=US -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:.harness/hc" probe.web.Unzip http://127.0.0.1:19590/customers
  exit 0 · its UNZIP lines: 7 · its other lines: 0
    the JVM's locale: en_US
    the JDK's HttpClient: its default version HTTP_2
    the JDK's HttpClient, no header added -> 200 HTTP_2 | Content-Encoding: none | bytes handed back: 282 | md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0
    the JDK's HttpClient, Accept-Encoding: gzip set by hand -> 200 HTTP_2 | Content-Encoding: none | bytes handed back: 282 | md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0
    RestClient.create(): its request factory org.springframework.http.client.JdkClientHttpRequestFactory
    RestClient.create(), no header added -> 200 | Content-Encoding: none | bytes handed back: 282 | md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0
  Tomcat's access log since the mark (after readiness) (the harness's pattern - the method, the path, the protocol, the status, the request's Upgrade and Accept-Encoding, the answer's Content-Encoding; - for none): 11 lines, 0 of them POSTs (not shown)
    GET /customers HTTP/1.1 101 upgrade:h2c accept-encoding:- content-encoding:-
    GET /customers HTTP/2.0 200 upgrade:h2c accept-encoding:- content-encoding:-
    GET /customers HTTP/1.1 200 upgrade:- accept-encoding:- content-encoding:-
    GET /customers HTTP/1.1 101 upgrade:h2c accept-encoding:- content-encoding:-
    GET /customers HTTP/2.0 200 upgrade:h2c accept-encoding:- content-encoding:-
    GET /customers HTTP/2.0 200 upgrade:- accept-encoding:- content-encoding:-
    GET /customers HTTP/1.1 101 upgrade:h2c accept-encoding:- content-encoding:-
    GET /customers HTTP/2.0 200 upgrade:h2c accept-encoding:- content-encoding:-
    GET /customers HTTP/2.0 200 upgrade:- accept-encoding:gzip content-encoding:-
    GET /customers HTTP/1.1 101 upgrade:h2c accept-encoding:gzip,deflate content-encoding:-
    GET /customers HTTP/2.0 200 upgrade:h2c accept-encoding:gzip,deflate content-encoding:-
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19590 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19590 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the key off: the README's run line and the access log, port 19591, a fresh JVM:
  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19591 --server.tomcat.basedir=../tomcat --server.tomcat.accesslog.enabled=true --server.tomcat.accesslog.rotate=false --server.tomcat.accesslog.buffered=false '--server.tomcat.accesslog.pattern=%m %U %H %s upgrade:%{Upgrade}i accept-encoding:%{Accept-Encoding}i content-encoding:%{Content-Encoding}o'
  listens on: 127.0.0.1:19591 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
  the JVM's locale, read off its pid (this unit's jcmd line): en_US
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19591/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -v --http2 -o /dev/null http://127.0.0.1:19591/customers 2> .harness/v.txt
  curl exit 0 · its -v lines: 19 · kept, by ^(> GET |> Connection: |> Upgrade: |> HTTP2-Settings: |< HTTP/|< Connection: |< Upgrade: |\* Received 101) (any case): 5
    > GET /customers HTTP/1.1
    > Connection: Upgrade, HTTP2-Settings
    > Upgrade: h2c
    > HTTP2-Settings: AAMAAABkAAQAoAAAAAIAAAAA
    < HTTP/1.1 200 
$ curl -s -o .harness/body.bin -w '%{http_code} %{http_version} %{size_download}' http://127.0.0.1:19591/customers
  -> 200 1.1 282 · md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0 · curl exit 0
$ curl -s -o .harness/body.bin -w '%{http_code} %{http_version} %{size_download}' --http2 http://127.0.0.1:19591/customers
  -> 200 1.1 282 · md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0 · curl exit 0
$ curl -s -o .harness/body.bin -w '%{http_code} %{http_version} %{size_download}' --http2-prior-knowledge http://127.0.0.1:19591/customers
  -> 000 0 0 · nothing saved · curl exit 16
$ java -Duser.language=en -Duser.country=US -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:.harness/hc" probe.web.Unzip http://127.0.0.1:19591/customers
  exit 0 · its UNZIP lines: 7 · its other lines: 0
    the JVM's locale: en_US
    the JDK's HttpClient: its default version HTTP_2
    the JDK's HttpClient, no header added -> 200 HTTP_1_1 | Content-Encoding: none | bytes handed back: 282 | md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0
    the JDK's HttpClient, Accept-Encoding: gzip set by hand -> 200 HTTP_1_1 | Content-Encoding: none | bytes handed back: 282 | md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0
    RestClient.create(): its request factory org.springframework.http.client.JdkClientHttpRequestFactory
    RestClient.create(), no header added -> 200 | Content-Encoding: none | bytes handed back: 282 | md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0
  Tomcat's access log since the mark (after readiness) (the harness's pattern - the method, the path, the protocol, the status, the request's Upgrade and Accept-Encoding, the answer's Content-Encoding; - for none): 6 lines, 0 of them POSTs (not shown)
    GET /customers HTTP/1.1 200 upgrade:h2c accept-encoding:- content-encoding:-
    GET /customers HTTP/1.1 200 upgrade:- accept-encoding:- content-encoding:-
    GET /customers HTTP/1.1 200 upgrade:h2c accept-encoding:- content-encoding:-
    GET /customers HTTP/1.1 200 upgrade:h2c accept-encoding:- content-encoding:-
    GET /customers HTTP/1.1 200 upgrade:h2c accept-encoding:gzip content-encoding:-
    GET /customers HTTP/1.1 200 upgrade:h2c accept-encoding:gzip,deflate content-encoding:-
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19591 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19591 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, port 19590, a fresh JVM:
  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19590 --server.http2.enabled=true --server.tomcat.basedir=../tomcat --server.tomcat.accesslog.enabled=true --server.tomcat.accesslog.rotate=false --server.tomcat.accesslog.buffered=false '--server.tomcat.accesslog.pattern=%m %U %H %s upgrade:%{Upgrade}i accept-encoding:%{Accept-Encoding}i content-encoding:%{Content-Encoding}o'
  listens on: 127.0.0.1:19590 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
  the JVM's locale, read off its pid (this unit's jcmd line): en_US
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19590/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -v --http2 -o /dev/null http://127.0.0.1:19590/customers 2> .harness/v.txt
  curl exit 0 · its -v lines: 25 · kept, by ^(> GET |> Connection: |> Upgrade: |> HTTP2-Settings: |< HTTP/|< Connection: |< Upgrade: |\* Received 101) (any case): 9
    > GET /customers HTTP/1.1
    > Connection: Upgrade, HTTP2-Settings
    > Upgrade: h2c
    > HTTP2-Settings: AAMAAABkAAQAoAAAAAIAAAAA
    < HTTP/1.1 101 
    < Connection: Upgrade
    < Upgrade: h2c
    * Received 101, Switching to HTTP/2
    < HTTP/2 200 
$ curl -s -o .harness/body.bin -w '%{http_code} %{http_version} %{size_download}' http://127.0.0.1:19590/customers
  -> 200 1.1 282 · md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0 · curl exit 0
$ curl -s -o .harness/body.bin -w '%{http_code} %{http_version} %{size_download}' --http2 http://127.0.0.1:19590/customers
  -> 200 2 282 · md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0 · curl exit 0
$ curl -s -o .harness/body.bin -w '%{http_code} %{http_version} %{size_download}' --http2-prior-knowledge http://127.0.0.1:19590/customers
  -> 200 2 282 · md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0 · curl exit 0
$ java -Duser.language=en -Duser.country=US -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:.harness/hc" probe.web.Unzip http://127.0.0.1:19590/customers
  exit 0 · its UNZIP lines: 7 · its other lines: 0
    the JVM's locale: en_US
    the JDK's HttpClient: its default version HTTP_2
    the JDK's HttpClient, no header added -> 200 HTTP_2 | Content-Encoding: none | bytes handed back: 282 | md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0
    the JDK's HttpClient, Accept-Encoding: gzip set by hand -> 200 HTTP_2 | Content-Encoding: none | bytes handed back: 282 | md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0
    RestClient.create(): its request factory org.springframework.http.client.JdkClientHttpRequestFactory
    RestClient.create(), no header added -> 200 | Content-Encoding: none | bytes handed back: 282 | md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0
  Tomcat's access log since the mark (after readiness) (the harness's pattern - the method, the path, the protocol, the status, the request's Upgrade and Accept-Encoding, the answer's Content-Encoding; - for none): 11 lines, 0 of them POSTs (not shown)
    GET /customers HTTP/1.1 101 upgrade:h2c accept-encoding:- content-encoding:-
    GET /customers HTTP/2.0 200 upgrade:h2c accept-encoding:- content-encoding:-
    GET /customers HTTP/1.1 200 upgrade:- accept-encoding:- content-encoding:-
    GET /customers HTTP/1.1 101 upgrade:h2c accept-encoding:- content-encoding:-
    GET /customers HTTP/2.0 200 upgrade:h2c accept-encoding:- content-encoding:-
    GET /customers HTTP/2.0 200 upgrade:- accept-encoding:- content-encoding:-
    GET /customers HTTP/1.1 101 upgrade:h2c accept-encoding:- content-encoding:-
    GET /customers HTTP/2.0 200 upgrade:h2c accept-encoding:- content-encoding:-
    GET /customers HTTP/2.0 200 upgrade:- accept-encoding:gzip content-encoding:-
    GET /customers HTTP/1.1 101 upgrade:h2c accept-encoding:gzip,deflate content-encoding:-
    GET /customers HTTP/2.0 200 upgrade:h2c accept-encoding:gzip,deflate content-encoding:-
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19590 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19590 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
```

**A** `--server.http2.enabled=true` (+ the access log): curl `--http2`'s `-v` lines (written to `.harness/v.txt`, then read; 9 kept of 25 by the declared filter): `> Upgrade: h2c` → **`< HTTP/1.1 101`, `< Upgrade: h2c`, `* Received 101, Switching to HTTP/2` (curl's line), `< HTTP/2 200`**; `%{http_version}` **2** with `--http2` and with `--http2-prior-knowledge`, 1.1 with neither; **the JDK's client's own offer → `HTTP_2`** (S5 CARRIED: the offer the RestClient lesson's stub — the JDK's own server — ignored, accepted by Tomcat); the access log: four `101 upgrade:h2c` lines (curl's two, the JDK client's, RestClient's). **B** the key off: the same offer answered **`HTTP/1.1 200`**, `--http2` → 1.1; **prior knowledge → `000`, `%{http_version}` 0, curl exit 16** (the brief said exit 0: measured 16 — the check reads `%{http_version}`, never the exit); the JDK client → `HTTP_1_1`; five offers, none accepted. **A′** = A. The body md5 is the same `09cb28cd…` in every 200. **HTTP/2 over TLS is Course 10's *TLS and Transport*** — named once, a pointer: no TLS ran here (⚑3).
## 6 · together — the page and its stylesheet at once: connections, counted off curl's lines

`.r-together.out`, md5 `6f5a19e687d8d4d48e364fbeb1be4604`, 3 of 3 — whole:

```
the page and its stylesheet at once - HTTP/2 on, port 19592, a fresh JVM; curl -Z (at once), without --parallel-immediate:
  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19592 --server.http2.enabled=true
  listens on: 127.0.0.1:19592 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java <version>
  the JVM's locale, read off its pid (this unit's jcmd line): en_US
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19592/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -H 'Accept: text/html' http://127.0.0.1:19592/dashboard | grep -o '/css/[^"]*'
  the stylesheet's URL, read off the page: /css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css
  HTTP/1.1:
$ curl -s -v -Z --http1.1 -H 'Accept: text/html' -o /dev/null -o /dev/null -w '%{http_version} ' http://127.0.0.1:19592/dashboard http://127.0.0.1:19592/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css 2> .harness/v.txt
  -> %{http_version} per transfer: 1.1 1.1 · curl exit 0 · its -v lines kept, by ^\* (Connected to |Multiplexed connection found|Re-using existing connection|Server doesn't support multiplex), counted: 2
    2 × * Connected to 127.0.0.1 (127.0.0.1) port <port>
  connections curl opened (its "Connected to" lines): 2
  HTTP/2:
$ curl -s -v -Z --http2-prior-knowledge -H 'Accept: text/html' -o /dev/null -o /dev/null -w '%{http_version} ' http://127.0.0.1:19592/dashboard http://127.0.0.1:19592/css/tiffinbox-10ba2401fd96e2e382866a731d207fc4.css 2> .harness/v.txt
  -> %{http_version} per transfer: 2 2 · curl exit 0 · its -v lines kept, by ^\* (Connected to |Multiplexed connection found|Re-using existing connection|Server doesn't support multiplex), counted: 4
    1 × * Connected to 127.0.0.1 (127.0.0.1) port <port>
    1 × * Multiplexed connection found
    1 × * Re-using existing connection with host 127.0.0.1
    1 × * Server doesn't support multiplex yet, wait
  connections curl opened (its "Connected to" lines): 1
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19592 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19592 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

HTTP/2 on, one JVM; curl `-Z` (parallel) **without `--parallel-immediate`**, the page and its stylesheet (the URL read off the page). curl's own `-v` lines (labelled curl's: written to a file, then read, kept by the declared filter and counted with `sort | uniq -c` because parallel transfers write in either order): **HTTP/1.1 → `1.1 1.1`, 2 × `* Connected to` — 2 connections**; **HTTP/2 → `2 2`, 1 × `* Connected to`, `* Multiplexed connection found`, `* Re-using existing connection` — 1 connection**. A count of connections, never a clock (⚑10).
## 7 · aot — C (labelled): the anchor's AOT jar, built on a copy, the two switches on its run line

`.r-aot.out`, md5 `0c59fb7ae3cd4471d45d2fd30fd18d35`, 3 of 3 — whole:

```
C (labelled) - ahead of time: the anchor copied to .harness/aot, a config tree, built with its README's native line (offline, -DskipTests: the copy's tests are the web-layer testing lesson's, and this build is the AOT jar's):
$ cd .harness/aot && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean package
  built the AOT jar (.harness/aot) · offline: yes · exit 0
  files .m2-demo gained: 0 · Spring's AOT step ran (process-aot): 1 · GraalVM's metadata repository read from a file: URL: 1 · from http(s): 0
  the generated bean definitions in the jar (BOOT-INF/classes, *__BeanDefinitions.class): 103
under Spring's AOT step, the anchor's own application.yaml says, threading is fixed when the jar is built (this unit's line):
$ grep -n -A1 'virtual threads too. Under Spring.s AOT step' anchor/tiffinbox-web/src/main/resources/application.yaml
  31:  # and Boot's task executor uses virtual threads too. Under Spring's AOT step, and so in the native binary, this is fixed
  32-  # when the jar is built: a run-time --spring.threads.virtual.enabled changes nothing there, either way.
the AOT jar with the two switches - this unit's AOT line, --server.compression.enabled=true --server.http2.enabled=true, port 19593, a fresh JVM:
  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else
$ cd .harness/aot && java -Duser.language=en -Duser.country=US -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19593 --server.compression.enabled=true --server.http2.enabled=true
  listens on: 127.0.0.1:19593 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java <version>
  the JVM's locale, read off its pid (this unit's jcmd line): en_US
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19593/actuator/health/readiness
  {"status":"UP"} 200
  Boot's AOT line in its log: 1
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept: text/html' http://127.0.0.1:19593/dashboard
  -> 200 962 · md5 94eb3463816e1a310cbc1827ed825692 · its header lines: 6 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 3
    vary: accept-encoding
    Content-Type: text/html;charset=UTF-8
    Transfer-Encoding: chunked
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept: text/html' -H 'Accept-Encoding: gzip' http://127.0.0.1:19593/dashboard
  -> 200 477 · md5 9f593240fa15ea6cef5fffe7f2f4f253 · its header lines: 7 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 4
    vary: accept-encoding
    Content-Encoding: gzip
    Content-Type: text/html;charset=UTF-8
    Transfer-Encoding: chunked
  gunzip -c, the saved bytes: 962 bytes · md5 94eb3463816e1a310cbc1827ed825692
$ curl -s -o .harness/body.bin -w '%{http_code} %{http_version} %{size_download}' --http2-prior-knowledge http://127.0.0.1:19593/customers
  -> 200 2 282 · md5 09cb28cd6fa1ad8b8fe4870ec8bbf0d0 · curl exit 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19593 .harness/aot/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19593 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the AOT jar with neither - this unit's AOT line, port 19594, a fresh JVM:
  secrets/ before the start: tiffinbox/shutdown-token - the token's file, and nothing else
$ cd .harness/aot && java -Duser.language=en -Duser.country=US -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19594
  listens on: 127.0.0.1:19594 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java <version>
  the JVM's locale, read off its pid (this unit's jcmd line): en_US
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19594/actuator/health/readiness
  {"status":"UP"} 200
  Boot's AOT line in its log: 1
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept: text/html' http://127.0.0.1:19594/dashboard
  -> 200 962 · md5 94eb3463816e1a310cbc1827ed825692 · its header lines: 5 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2
    Content-Type: text/html;charset=UTF-8
    Transfer-Encoding: chunked
$ curl -s -o .harness/body.bin -D .harness/head.txt -w '%{http_code} %{size_download}' -H 'Accept: text/html' -H 'Accept-Encoding: gzip' http://127.0.0.1:19594/dashboard
  -> 200 962 · md5 94eb3463816e1a310cbc1827ed825692 · its header lines: 5 · kept, by ^(Content-Type|Content-Encoding|Content-Length|Transfer-Encoding|Vary): (any case): 2
    Content-Type: text/html;charset=UTF-8
    Transfer-Encoding: chunked
$ curl -s -o .harness/body.bin -w '%{http_code} %{http_version} %{size_download}' --http2-prior-knowledge http://127.0.0.1:19594/customers
  -> 000 0 0 · nothing saved · curl exit 16
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0
$ harness/shutdown.sh 19594 .harness/aot/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19594 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

The anchor copied to `.harness/aot` (never built in place), built with its README's `mvn -B -Pnative package` made offline, `-DskipTests` (the copy's tests are the web-layer testing lesson's; this build is the AOT jar's) and `clean`: `offline: yes`, **0 files gained by `.m2-demo`**, process-aot 1, GraalVM's metadata repository read from a `file:` URL (a build that went to http(s) for it stops the run). The anchor's own `application.yaml` says threading is fixed when the jar is built under AOT (*Embedded Tomcat, Threads and Connectors* measured it, `../c6-unit04/`, `threads` C). The AOT jar (`Starting AOT-processed …`) **with both switches → the page 477 gzip, prior knowledge HTTP/2; with neither → 962, no answer (`000`)**: both stay run-time keys ahead of time, unlike virtual threads. The binary is not built (RE-MEASURE 7: unspoken).
## 8 · exercise — the exercise, run as written, in one shell

`.r-exercise.out`, md5 `eed9e1ac0970045666024d78fc1467e7`, 3 of 3 — whole:

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 8 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/
  $ mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
  $ S="$PWD/harness/shutdown.sh"
  $ V=(--server.compression.enabled=true)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19596 "${V[@]}" > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19596/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && b=$(curl -s -o /dev/null -D ../head.txt -H 'Accept-Encoding: gzip' -w '%{size_download}' http://127.0.0.1:19596/customers) && "$S" 19596 secrets/tiffinbox/shutdown-token > ../stop.txt && { wait "$p"; echo "/customers, gzip asked: $b bytes · Content-Encoding: $(tr -d '\r' < ../head.txt | grep -i '^content-encoding: ' | cut -d' ' -f2 | grep . || echo none) · TiffinBox stopped by: POST /shutdown, $(awk '{ print $4 }' ../stop.txt)"; })
  exit 0 · what they printed:
    /customers, gzip asked: 282 bytes · Content-Encoding: none · TiffinBox stopped by: POST /shutdown, 200
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19596 now: 0
the solution's 5 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ S="$PWD/harness/shutdown.sh"
  $ V=(--server.compression.enabled=true --server.compression.min-response-size=128)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && { java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19596 "${V[@]}" > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19596/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && b=$(curl -s -o /dev/null -D ../head.txt -H 'Accept-Encoding: gzip' -w '%{size_download}' http://127.0.0.1:19596/customers) && "$S" 19596 secrets/tiffinbox/shutdown-token > ../stop.txt && { wait "$p"; echo "/customers, gzip asked: $b bytes · Content-Encoding: $(tr -d '\r' < ../head.txt | grep -i '^content-encoding: ' | cut -d' ' -f2 | grep . || echo none) · TiffinBox stopped by: POST /shutdown, $(awk '{ print $4 }' ../stop.txt)"; })
  exit 0 · what they printed:
    /customers, gzip asked: 129 bytes · Content-Encoding: gzip · TiffinBox stopped by: POST /shutdown, 200
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19596 now: 0
the same two blocks again, in ONE new shell - env -i, /bin/zsh -f (zsh, the Mac's Terminal shell; it never splits an unquoted variable):
  the README's lines: exit 0 · what they printed:
    /customers, gzip asked: 282 bytes · Content-Encoding: none · TiffinBox stopped by: POST /shutdown, 200
  the solution's lines: exit 0 · what they printed:
    /customers, gzip asked: 129 bytes · Content-Encoding: gzip · TiffinBox stopped by: POST /shutdown, 200
  the shell is now in: this unit's folder · its copy's own token in its log: 0 times · listening on 19596 now: 0
```



`exercise/README.md`'s block, then `exercise/solution/SOLUTION.md`'s, in ONE `env -i` `/bin/bash` shell, as a viewer pastes them. As shipped
(`V=--server.compression.enabled=true`): **`/customers, gzip asked: 282 bytes · Content-Encoding: none`**; the solution adds
`--server.compression.min-response-size=128` → **`129 bytes · Content-Encoding: gzip`**. Each run is a fresh copy and a fresh JVM and
POSTs nothing, so a second run in the same shell measures the same list (S6.4); `JAVA_HOME` is exported first (the Mac's 23 refuses the
anchor's Java 25; with none, Homebrew's `mvn` runs on 26).

## Exercise

`exercise/README.md`: **Your turn:** the README switches compression on, yet the customer list still arrives unzipped. Find the setting
that skips it, change it, and fetch again. (25 words.) "Fetch again" is the README's curl with `-H 'Accept-Encoding: gzip'` and
`-w '%{size_download}'`. The answer: `server.compression.min-response-size` (the floor) — `exercise/solution/SOLUTION.md`. The options
travel as an array, `V=( … )` passed as `"${V[@]}"`, so the blocks run the same in bash and in zsh, the Mac's Terminal shell (RED S6
#527: the shipped `V="--a --b"` made TiffinBox fail to start in zsh — `Failed to bind properties under 'server.compression.enabled'`);
`exercise` runs README + SOLUTION in one `env -i` bash shell, then in one `env -i /bin/zsh -f` shell: `282 bytes · none`, then `129 bytes ·
gzip`, in each. `JAVA_HOME` is exported first: the Mac's `/usr/bin/java` 23 can neither compile nor run the anchor's Java 25 classes
(class file 69, RED S6 #518).

## The ledger rows and hand-offs this unit pays

- **The roadmap's U30, "compression and HTTP/2 measured before and after on one payload"** (⚑6): the dashboard page — 962 → 477 gzip
  (`which`, `switch`), and its stylesheet's request on one connection (`together`); `/customers` for the floor (`floor`, the exercise).
- **S5 CARRIED** — `accept-encoding` decoded or not: RestClient (JDK factory) unzips, the JDK's HttpClient does not (`decode`); the JDK
  client's h2c offer, ignored by the JDK's own server in the *RestClient* lesson, accepted by Tomcat with the key (`h2c`).
- **S4 CARRIED** — compression of the HTML page (zipped) and the CSS (**not**: 200 B, a known length under the floor, `which`); HTTP/2's
  effect on the stylesheet's request = 2 connections → 1 (`together`).
- **Contract "Known machine items — Section 6"** — h2c shown; ratios only; TLS measured in the probe only (⚑3).
- **C6-31** (glosses) — compression, gzip, a chunked answer (re-gloss), HTTP/2, h2c, an upgrade: each spoken at first use (the builder
  checks).
- **H-29** — the previous lesson's up-next names this lesson's title; this lesson's up-next names *Capstone: The TiffinBox Web App*
  (`java6_series.TITLES["31"]`).

## RE-MEASURE — the brief's items this unit settles

| # | Item | Settled |
|---|---|---|
| 1 | Every 30 capture on `c6-unit28/after` | all eight captures, here |
| 5 | `Unzip` on the anchor's class path (the probe used `Dec.java` by the source launcher) | **a compiled main class** on the extracted `lib/` (`decode`, `h2c`) |
| 6 | deflate | not run: unspoken (RestClient asks `gzip,deflate`; it was sent gzip) |
| 7 | h2c in the binary and the image | not run: unspoken (the AOT jar only, C) |
| 17 | The exercise as viewers run it | `exercise` |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **`--http2-prior-knowledge` against the key off exits 16, not 0** (the brief and the probe said exit 0, `000`): `000` and
  `%{http_version}` 0 hold; the check reads `%{http_version}`, never the exit — the hazard stands, its number changes.
- **`Vary: accept-encoding`** appears on the page answers (chunked) and on the 2,403-B list (over the floor), **not** on the 282-B list,
  the stylesheet or health with the key on (the probe: "every compressible type once the key is on").
- **Five `server.compression` keys** in Boot 4.1.1's metadata, not three (`additional-mime-types`, `excluded-user-agents`).
- **The plain grown list carries `Content-Length: 2403`**; the gzip answer loses it for `Transfer-Encoding: chunked` (measured both).
- **Tomcat's access log** witnesses what RestClient asked for (`gzip,deflate`) and what it was sent (`gzip`) — the claim "RestClient
  unzips" no longer rests on the client's output alone (S6.11).
- The AOT jar's generated `*__BeanDefinitions.class` entries: 103 by this filter (the probe's 137 counted another way; not spoken).

## Found on the way

- **Java's own output charset under `LC_ALL=C` is ASCII**: `Unzip`'s first lines printed `·` as `?`; the separators are `|` now.
- **The access log's mark** moved before the 30 POSTs so the cut is counted (`36 lines, 30 of them POSTs`).
- **curl's `-v` in parallel writes in either order**: kept lines are counted with `sort | uniq -c`, never shown in order.
- **A grep for the AOT comment** matched two yaml comments (threads and exposure); the line now names the threading one.
- The hook (an exercise-shaped problem): the switch is on and the list still arrives unzipped.

- **The planted faults, 33 in all, each caught** (S6.10, R.65) — besides the seven planted inputs the script checks before any capture
  (the level counts, the header filter, the two `-v` filters, the GraalVM-fetch guard both ways, the masks):
  - **27 on planted captures or files** (a copy of the script with its captures skipped re-runs every check): **the floor** — the
    282-B list given `Content-Encoding: gzip` (a "compressed under the floor" claim) → `floor: the list under the floor` fails; the
    grown gzip 229 → 1229 → fails; **the decode md5** — the JDK client's raw body given the plain md5 → `decode:` fails (the JDK's bytes
    must be the gzip bytes); RestClient's access-log line sent no gzip → fails; curl `--compressed` saving the gzip bytes → fails;
    **h2c** — `%{http_version}` 2 on B's `--http2` (the key off) → `h2c B: --http2 -> 1.1` fails; prior knowledge's `%{http_version}`
    2 with the key off → `h2c B: prior knowledge must get no answer` fails; the JDK's client HTTP_1_1 with the key on → fails;
    **together** — 2 connections on HTTP/2 → fails; `Multiplexed connection found` removed → fails; which: 477 → 700, a third
    `Content-Encoding: gzip`, 7 types; switch A′ ≠ A; switch B's bytes differing; aot: 1 file gained, the AOT jar without flags answering
    HTTP/2; one unmasked ` using Java 25.0.4.1` (R.151); a `de_DE` locale (S6.1); the raw token; **a duration (`3 ms`) in a capture**; a
    `Date` header; a start without its `secrets/` listing (R.158); **a Boot key misspelt (the floor as `…compression.min-size`) in
    README.md (R.138)**; the solution's done line 129 → 130; the floor's key named in the README's block; a bare `wait`.
  - **3 on real runs with the fault planted in the script**: **`--parallel-immediate` added to `together`'s HTTP/2 line** → curl opened
    2 connections → `together: HTTP/2 - one connection` fails; **a password file planted in `secrets/server/ssl/`** before `floor`'s start
    → the pre-start listing refuses it (R.158), the JVM never starts; `floor` run with the floor at 128 → the list zipped →
    `floor: the list under the floor` fails.
  - **3 in the builder (⚑10)**: "faster" in a spoken line → refused; "milliseconds" in a spoken line → refused; "latency" in the
    builder's own source → refused.
- **BLUE S6 (2026-10-30), the checks RED S6 asked for, each shown failing first** (a check-only copy of `receipts.sh` — its builds and
  captures cut — on the final captures, baseline exit 0): health's key-on `Transfer-Encoding: chunked` → `Content-Length: 49` → `which ON:
  health is a chunked answer with no Content-Length …` (#529); the zsh run's solution printing the README's `282 bytes · none` →
  `exercise (zsh): the solution: expected the line …129 bytes…`; an unquoted `$V` on both blocks' last line → `exercise/README.md passes V
  unquoted or as one string` (and `b50b410`'s SOLUTION as shipped → refused, #527); spring-web's `enableCompression(boolean)` line removed
  from `decode` → `decode: spring-web's own line …` (#510). The builder: the A′ rows removed from slide 2 and from slide 5 → `S6.2: an A'
  panel without A's label and $ line` (each, #508); a duration word ("quickly") → refused by the shared pattern (`_builders/dur6.py`,
  #511).


## For RED

- Re-check **the floor-vs-chunked claim** (`which`: the page `Transfer-Encoding: chunked` zipped at 962 B; the list `Content-Length: 282`
  not zipped; `floor`: 2,403 B with a length zipped), **the decode md5s per client** (`decode`: curl `--compressed` saves `bc553574…` =
  plain; the JDK's HttpClient hands back `55750658…` = the gzip bytes; RestClient `bc553574…`; the access log's `content-encoding:gzip` on
  RestClient's request), **`%{http_version}` with the key off** (`h2c` B: 1.1 with `--http2`, 0 with prior knowledge, exit 16),
  **the connection count off curl's lines** (`together`: 2 vs 1, `Multiplexed connection found`; `-Z` without `--parallel-immediate`),
  **the duration-word refusal** (the builder's `DUR`, on the script, the deck, the prompter and its own source; the receipts' last
  check on every capture), and **the AOT label** (`aot` is C, labelled in its first line; the binary unspoken).
- Ports for RED A's re-runs of this unit: 19630-19639 (brief ⚑1).
