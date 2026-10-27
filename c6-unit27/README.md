# c6-unit27 — RestTemplate: What You Will Meet in Old Code

Course 6 · Spring Web MVC · Section 5 (Calling Out), its third unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**
(Spring Framework 7.0.9, Tomcat 11.0.24, Jackson 3.1.5), curl 8.7.1, 2026-10-28. Older Spring code calls out with **`RestTemplate`**, and a
viewer will read it long before writing any. This unit meets it **once, labelled**: where it stands in Framework 7.0.9 (its class files
carry **no `Deprecated` attribute**, and Boot 4.1.1 still makes a `restTemplateBuilder` bean), the same job beside the RestClient lesson's
client (the same `NotFound`, a message that names the URL, an `Accept` header RestClient does not send), **two request factories** (Boot's
builder: the JDK's `HttpClient`; `new RestTemplate()`: the JDK's `HttpURLConnection`), **the move** — `RestClient.create(template)` keeps
the template's interceptor — and who on this class path still names it. Spring's newer client is `RestClient`; nothing here calls
`RestTemplate` "deprecated" (its class files say otherwise) or anything else its Javadoc might say (no sources jar: unread).

**No anchor change (brief ⚑4).** `anchor` is the link to `../c6-unit24/after` — the sessions lesson's frozen tree, `c6-tiffinbox` at
Section 4's end (`diff -rq -x target c6-tiffinbox c6-unit24/after` empty on 2026-10-28, at `bad0014`; `c6-tiffinbox` at `1ae525a`) — read
and copied under `.harness/anchor`, never built in place; this unit freezes no `after/` and touches no other unit's folder. Everything new
is **the course's harness**, never TiffinBox's:

- `harness/pom.xml` — builds nothing; it names **Boot's RestClient starter** under the anchor's parent (Boot 4.1.1), so that Maven's
  `dependency:build-classpath` lists the jars it brings (R.26). As in the RestClient lesson: 31 jars, 25 already in the anchor's `lib/`,
  4 starters with no class, **2 joined — `spring-boot-restclient` and `spring-boot-http-client`** (61 + 2 = 63). `RestTemplate` itself is
  spring-web's, already among the 61; Boot's `RestTemplateBuilder` and the auto-configuration that makes its bean are
  spring-boot-restclient's. **httpclient5 is not on the class path** (asserted): every factory sentence here is "on this class path".
- `harness/probe/web` — outside `com.tiffinbox`, compiled with `-parameters -Xlint:deprecation` (javac prints nothing) against the anchor's
  jars and the two, joined by `--spring.main.sources` on the extracted jar's class path: **`Templates`** (an `ApplicationRunner`: the cases
  `--probe.cases` names, one `TPL …` line each; with no cases it does nothing; every RestClient it builds from Boot's injected builder is a
  `clone()`, R.141 — Boot's `RestTemplateBuilder` returns a new builder from every method, so the injected one is never changed),
  **`TemplateRoutes`** (`GET /probe/old`: Ravi's row through a template with the interceptor; `GET /probe/moved`: the same call moved to
  RestClient — the exercise's routes; neither catches anything), **`Via`** (an interceptor on a client: it adds `X-Via:
  template-interceptor` to every request), **`Row`** (the RestClient lesson's record, byte for byte).
- `harness/stub/` — **the RestClient lesson's stub, copied byte for byte**: `Stub.java` md5 `42b656ddba1e9f80107495c65dacc975` =
  `../c6-unit25/harness/stub/Stub.java`'s, and its five `www/` files (asserted at the top of `receipts.sh`, and shown in `status`: 6 of 6).
  **No route added**: `GET /<file>` (Core Java II's five; 404 `text/plain` "not found" otherwise) and `GET /redirect` (302 → `/ravi.json`)
  are all this unit asks of it. It binds `InetAddress.getLoopbackAddress()` (asserted on its pid: `127.0.0.1:19566`) and prints every
  request whole — the witness of what each client sent (R.136). **A stub** is a small stand-in server that answers like the real one, on
  this computer.
- `harness/deps.py` — what a class's own class files say about deprecation: the class and every class nested in it, each read with `javap
  -v -p` (every member, private ones too); per class file its members, its `Deprecated` attributes on the class and on members, and each
  deprecated thing by name with `@Deprecated`'s `since`/`forRemoval`. javap's own output is never printed, only its line count.
- `harness/who.py` — which class files in a set of jars **name** a class: a class file names every class it uses (a type, a call, a field)
  in its constant pool, by its slashed name; a match is that string not followed by a letter, digit or `_` (so `RestTemplateBuilder`, in
  Boot's package, is not a match; `RestTemplate$X`, nested in it, is). It lists the jars with a match and TiffinBox's own two, and
  **counts the rest** (R.53, S5.6).
- `harness/shutdown.sh` — POST /shutdown with the token read from its file (the filters lesson's, byte for byte).

**A template**, here, is the class's own word — `RestTemplate` runs the fixed steps of every call (build the request, send it, check the
status, turn the body into the type you asked for) and you hand it the URL and the type: `getForObject(url, Row.class)`. It is not a
Thymeleaf template, the HTML page kind from *Serving HTML: Thymeleaf*. **An interceptor on a client** is code that sees every request a client is
about to send, and may change it before it leaves (*Filters vs Interceptors vs Advice*'s interceptors sat on the server's side). **A
message converter** turns a body into a Java object and back — *Request Bodies and HttpMessageConverter*'s, re-glossed: the template has
five, Jackson's last.

No native build, no Docker and no browser: curl and the stub are the clients and the witness, so nothing here says "a browser" (R.115).
Every URL is `127.0.0.1:<port>`.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 6 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export` lines at its top; a bare `java` on this Mac is 23.0.1.) It **dies** when a capture's md5 differs
from `receipts.md5` (it prints the `DIFFERS` line first). **Start it in a process group of its own** (a terminal's foreground job is one):
two receipts started as background jobs of one shell share a group, and one run's clean-up would stop the other's JVMs (R.94).

**Runs of record (2026-10-28, this script as committed):** **183 s under `./receipts.sh`** (/bin/bash 3.2.57, `env -i` with HOME and a
plain PATH, this folder, a session — so a process group — of its own: exit 0, all 6 captures 3/3 = published, every check passed) and
**186 s under `bash receipts.sh`** (Homebrew bash 5.3.9, the same: exit 0, all 6 = published). The hashes were first made by a 3.2 run and
reproduced, unchanged, by every run since, under both bashes. **A sealed fresh clone**, by the recipe below: a `git clone` of the
repository at `bad0014` with this folder's files beside it (the `anchor` link by `readlink`: `../c6-unit24/after`), `.m2-demo` absent at
the start, a `file://` copy of 4,440 files made from this folder's `.m2-demo`; the pre-flight: exit 1, 221 `Downloading from sealed:
file://`, 0 from http(s) — **exit 0, all 6 = published, every check passed, 191 s**; the four builds before the captures said `offline:
no`, as a fresh clone's must (the anchor's log: 533 downloads, every one from `file://`; the harness POM's and the two `dependency:get`
runs use `-q`, which prints none), every capture's build `offline: yes`; **`_remote.repositories` by repository id: 698 `>sealed=` (in 494
artifact folders), 0 `central`**, no line with another id.

Published hashes: status `8f0191c27c2a068f6ebe1a888a76d76e` · side `d264355cde81fa5fdf8b8e6497f108a1` · factories `d06f7c30ed7cb32afafef16294815736` · migrate `15641cf0af7934b7f1e63945dfd61b82` · who `6e503b495eef4196bdaf934e131891f8` · exercise `fbb61a7e9ffa5a03cdbceb74dccd1f64`.

### A sealed fresh clone — the recipe (RED S4 #405, fixed)

`-Duser.home` in the sealed `.mavenrc` (Java on macOS ignores `$HOME`, so Maven would never read settings kept there), Maven's own
`<proxies>` at a refusing port (its resolver ignores `-Dhttp.proxyHost`), a mirror `*` → `file://`; a pre-flight that refuses to start
unless an absent artifact fails having asked `file://` alone; a post-check counting `_remote.repositories` by repository id (0 `central`):

```bash
S=/tmp/sealed-27                                   # an empty folder of your own; T = your tiffinbox-java clone
mkdir -p "$S/home/.m2" && git clone -q "file://$T" "$S/tiffinbox-java"
rsync -a --exclude _remote.repositories --exclude '*.lastUpdated' --exclude resolver-status.properties "$T/c6-unit27/.m2-demo/" "$S/central/"
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
cd "$S/tiffinbox-java/c6-unit27" && $E ./receipts.sh            # a process group of its own (a terminal's foreground job is one)
# post-check: every artifact's origin, by repository id - each line must say sealed; 0 central
find .m2-demo -name _remote.repositories -exec cat {} + | grep -o '>[^=]*=' | sort | uniq -c
```

## The commands this unit adds

```bash
java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18431
mvn -o -B -q -Dmaven.repo.local="$M2" -f harness/pom.xml dependency:build-classpath -Dmdep.outputFile="$PWD/.harness/harness.cp"
mvn -o -B -q -Dmaven.repo.local="$M2" -f harness/pom.xml dependency:get -Dartifact=org.springframework.boot:spring-boot-resttestclient:4.1.1 -Dtransitive=false
mvn -o -B -q -Dmaven.repo.local="$M2" -f harness/pom.xml dependency:get -Dartifact=org.springframework:spring-test:7.0.9 -Dtransitive=false
javac -parameters -Xlint:deprecation -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:.harness/xlib/*" harness/probe/web/Row.java harness/probe/web/TemplateRoutes.java harness/probe/web/Templates.java harness/probe/web/Via.java
java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19566 --www=harness/stub/www
for f in Stub.java www/customers.json www/meera.json www/priya.json www/ravi.json www/sunil.json; do echo "$(md5 -q "harness/stub/$f") $(md5 -q "$S25/$f") $f"; done
python3 harness/deps.py .harness/anchor/tiffinbox-web/target/extracted/lib/spring-web-7.0.9.jar org.springframework.web.client.RestTemplate
python3 harness/deps.py .harness/xlib/spring-boot-restclient-4.1.1.jar org.springframework.boot.restclient.RestTemplateBuilder
python3 harness/who.py org/springframework/web/client/RestTemplate .harness/anchor/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar .harness/anchor/tiffinbox-web/target/extracted/lib/*.jar .harness/xlib/*.jar
python3 harness/who.py org/springframework/web/client/RestTemplate "$M2/org/springframework/boot/spring-boot-resttestclient/4.1.1/spring-boot-resttestclient-4.1.1.jar" "$M2/org/springframework/spring-test/7.0.9/spring-test-7.0.9.jar"
python3 harness/deps.py .harness/anchor/tiffinbox-web/target/extracted/lib/spring-boot-http-converter-4.1.1.jar org.springframework.boot.http.converter.autoconfigure.HttpMessageConverters
python3 harness/deps.py "$M2/org/springframework/boot/spring-boot-resttestclient/4.1.1/spring-boot-resttestclient-4.1.1.jar" org.springframework.boot.resttestclient.TestRestTemplate
python3 harness/deps.py "$M2/org/springframework/spring-test/7.0.9/spring-test-7.0.9.jar" org.springframework.test.web.client.MockRestServiceServer
grep -rlw RestTemplate anchor/tiffinbox-core/src anchor/tiffinbox-web/src harness/probe/web | sort
curl -s -o .harness/prom.txt -w ' %{http_code}\n' http://127.0.0.1:18431/actuator/prometheus
```

`anchor/README.md` — the anchor's own — gives five lines `receipts.sh` runs or derives from (`mvn -B package`, the run line, the extract
line, the class-path line, the readiness line); the seventeen above are this unit's, each read from this block and asserted to be exactly
this (on the anchor's port 18431; each capture swaps in its own port). The first two are the anchor's run and class-path lines with
`-Duser.language=en -Duser.country=US` after `java` — asserted — and every java line a capture starts takes the same two options in the same
place, the stub's too (a last check refuses any capture's java line without them, and the exercise's). Every capture adds, after the
class-path line's jar and `lib/*`, `../xlib/*` (the two jars) and `../hc` (the harness), and joins its classes with `--spring.main.sources=`
and its cases with `--probe.cases=` (`hcp()`); the stub's address is the harness's default, `http://127.0.0.1:19566`. The two
`dependency:get` lines put the two test modules' jars — `spring-boot-resttestclient` 4.1.1 and `spring-test` 7.0.9, already in the S5 seed —
into `.m2-demo` on a fresh clone, so `who` can read them; neither joins any class path here. The `for` line prints, for the stub and its five
files, this folder's md5 and the RestClient lesson's (`$S25` is `../c6-unit25/harness/stub`). `deps.py` and `who.py` read jars; `grep`
reads sources; the scrape line saves `/actuator/prometheus` to a file, read by a declared filter.

## The repository, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from `../../spring-web-mvc/_research/m2-seed-s5/`
alone — 5,925 files (the seed's 5,926 less Finder's `.DS_Store`), no `com/tiffinbox`. **Nothing was downloaded** for this unit: every
build said `offline: yes`, and the two `dependency:get` runs added **0 files** (5,925 before and after). A fresh clone's `.m2-demo` is empty
(git ignores it): the first four builds — `.harness/pre`, the harness POM's class path and the two `dependency:get` runs, before any capture
— fill it from Maven Central (or the sealed copy) and say `offline: no`. **At run time** every request goes to `127.0.0.1`, and nothing binds
8080, 18425, 35729 or 19569.

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 32 characters, fake and meant to look it — guards nothing but a demo server on
127.0.0.1 that every capture stops. It is written into `.harness/anchor/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600,
git-ignored) when the script runs, and sent only by `../c5-unit11/curlset.sh` and `harness/shutdown.sh` on curl's standard input, to
TiffinBox — never to the stub. Every capture's raw output is searched for it before masking (0 in all of them), and so are the log of
every TiffinBox JVM that ran (7), **the stub's dump of every run** (5: 0 — the token never reached the stub, R.137) and every file this unit
ships: 0 everywhere. The header's name, `X-Shutdown-Token`, is counted too: 0 in every log and every dump. No remote body reaches
TiffinBox's log in this unit (no call fails inside a route). The exercise makes a token of its own (`openssl rand -hex 13`), counted 0
times in its log and its stub's dump, never printed.

## The locale — pinned per JVM, printed, asserted

Every java line this script starts — TiffinBox's and the stub's — carries `-Duser.language=en -Duser.country=US` right after `java` (S4.1,
R.100), and every one prints its locale (`Templates`, `TemplateRoutes`, `Stub`) — `en_US`, asserted in every capture that starts one
(R.124). Receipts run under bash (`#!/bin/bash`), never zsh, where the two options would arrive as one word.

## The folders, the names and the ports

- `.harness/pre` — the anchor built before any capture; `.harness/anchor` — the anchor, copied, with a config tree, built and extracted
  (`status`); `.harness/harness.cp`, `.harness/xlib`, `.harness/hc` — the harness POM's class path, the two jars, the harness's classes;
  `.harness/stub.out` — the stub's dump; `.harness/prom.txt` — the scrape; `.harness/ua.txt` — the raw User-Agents (terminal only);
  `.harness/mine` — the exercise's copy.
- **Ports** (brief ⚑1, 19560-19569): TiffinBox 19560-19564, one JVM at a time (`status` 19560-19561, `side` 19562, `factories` A 19563,
  B 19560, A′ 19563, `migrate` 19561, the exercise 19564); the stub 19566, a fresh one per run that needs one; **19569 never bound**
  (asserted free, `factories`); 19565, 19567 and 19568 unused. All ten, 18425, 8080 and 35729 are checked free first; a TiffinBox that
  listens on 8080, 35729 or 19569 is killed and the script dies. Each TiffinBox is stopped by POST /shutdown and its pid waited for; the
  stub, which has no shutdown route, by its pid (exit 143).

## Masks, filters and hygiene — every one, declared

1. **Paths, the token, the user** (`gsub()`, literals escaped), in every line: the demo token → `[masked: the 32-character token]`; this
   folder → `…`; the folder above → `…/..`; home → `~`; the user name, as a whole word → `<user>`. **The JDK's version in a client's
   `User-Agent`** (R.136): the JDK `HttpClient`'s `Java-http-client/<digits and dots>` → `Java-http-client/<version>`, and
   `HttpURLConnection`'s `Java/<digits and dots>` → `Java/<version>` — both raw values printed once on the terminal (`Java-http-client/25.0.4.1
   Java/25.0.4.1`). A last check fails if any capture holds `/Users/`, `/private/`, `/home/`, `/var/folders/`, a unit number, Boot's process
   line, a log time, an unmasked timestamp, a thread number, a client's JDK version, a platform word, a stack frame, `:8080` or `:35729`, a
   carriage return, a duration, or a command with a URL that is not `127.0.0.1`'s. (Boot's first line keeps "using Java 25.0.4.1": the JDK
   this unit is verified on, which `receipts.sh` requires.)
2. **Spring's error timestamp** (`tsmask`): both forms → `…`, in every answer printed and in the seven (the mask runs; the seven print its
   count, 0).
3. **The stub's dump** (`sdump`): **whole** in `side`, `factories` and `migrate` — every line, every header, every value, each after a `|`,
   counted. Under it, **one line a request** (`reqs`): its method and URI, then the headers a sentence reads — `accept`, `accept-encoding`
   (every value, joined), `upgrade`, `user-agent`, `x-via` — each as sent, `none` when absent; then the counts. Checked on a planted dump
   first (a header given twice is two lines).
4. **The scrape** (`promf`): `/actuator/prometheus` kept to `^http_client_requests_seconds_count`, sorted, the kept lines counted; the others
   are the JVM's own meters, whose number moves from run to run, so their count is a bound: "over 150" (R.53).
5. **javap** (`deps.py`): its output read, never printed — its line count, the members (descriptor lines) and the `Deprecated` attributes
   are. **The class-file search** (`who.py`): the jars with a match and TiffinBox's two are listed, the others **counted** ("jars where no
   class file names it: 59 (not listed)"), and the totals printed.
6. **Log lines** (`logl`, `recs`): from their logger on — `o.s.web.servlet.PageNotFound` is **Spring MVC's** (the seven's 405). Counted by
   the log's own line shape, never a bare `' ERROR'` (checked on a planted log first). Every TiffinBox run ends with its WARN and ERROR
   counts and the number of its lines that say "deprecat".
7. **The harness's lines** (`tpls`): the `TPL` lines, in the order `Templates` printed them, whole, after its `done` (which must be there).
8. **A′ against A** (`asame`): A's block and A′'s, their labels aside, compared line for line in the capture itself ("yes").
9. **No duration** anywhere: no clock is read.
10. **On this Mac**: `lsof` by pid (or by port), the address column alone — never a command name (R.18).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops TiffinBox (`$pid`), the stub (`$spid`) and the
exercise's shell (`$xpid`, with every process under it — `killtree`), sweeps its own process group for any TiffinBox JVM, stub or Maven
left, deletes the capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched. No `wait`
is bare: each names its pid (R.105; a check refuses a bare one); nothing is stopped by name (a check refuses `pkill` and `killall`). See
"Found on the way" for the measured interrupt.

## 1 · status — where it stands

The anchor built offline and extracted: **61 libraries**, no Boot RestClient module, no httpclient5. The harness POM's class path, as
in the RestClient lesson: 31 jars, 25 already in `lib/`, four starters with **0 classes**, and `spring-boot-restclient` (29 classes) and
`spring-boot-http-client` (88) joined: **61 + 2 = 63**. The harness compiled with `-Xlint:deprecation` — **javac printed nothing**: no
deprecated API is used by any harness call, `RestTemplate`'s included. The stub against the RestClient lesson's: **6 of 6 md5 equal**, no
route added. **Where `RestTemplate` stands**, read off its class files (`deps.py`, `javap -v -p`): `RestTemplate` (85 members) and the four
classes nested in it — **5 class files, 0 `Deprecated` attributes, on the class or on any member**: "not deprecated in Framework seven
point zero" is this line, for 7.0.9 (S5.14). **The reader can count one**: on Boot's `RestTemplateBuilder` (60 members) it finds **1** —
`rootUri(String)`, `@Deprecated(forRemoval=true, since="4.1.0")` — the class itself not deprecated. (The harness never calls `rootUri`:
each call names its whole URL.) Whose classes (R.134): `RestTemplate`, `RestClient`, `ClientHttpRequestInterceptor` and both request
factories — **spring-web**'s; `RestTemplateBuilder` and `RestTemplateAutoConfiguration` — **spring-boot-restclient**'s. The seven on a fresh
JVM of the jar, then on the harness line with `Templates` and `TemplateRoutes` joined: `466c20ed…` both times, **the same, byte for byte:
7**, 1 WARN each (`PageNotFound`, Spring MVC's, the seven's 405). **The client beans by name** (case `beans`): **`restTemplateBuilder`**
(singleton, `RestTemplateBuilder`, made by `RestTemplateAutoConfiguration`: Boot 4.1.1 still makes it), **no `RestTemplate` bean**;
`restClientBuilder` (prototype) and no `RestClient` bean, as the RestClient lesson found.

`.r-status.out` · md5 `8f0191c27c2a068f6ebe1a888a76d76e` · 3 of 3

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
the harness, compiled against the anchor's own jars and those two - with javac's deprecation warnings on (this unit's line):
$ javac -parameters -Xlint:deprecation -d .harness/hc -cp ".harness/anchor/tiffinbox-web/target/extracted/lib/*:.harness/xlib/*" harness/probe/web/Row.java harness/probe/web/TemplateRoutes.java harness/probe/web/Templates.java harness/probe/web/Via.java
  exit 0 · what javac printed: 0 lines · its classes: probe/web/Row.class probe/web/TemplateRoutes.class probe/web/Templates.class probe/web/Via.class
the stub - this folder's copy against the RestClient lesson's ($S25), md5 for md5 (this unit's line):
$ for f in Stub.java www/customers.json www/meera.json www/priya.json www/ravi.json www/sunil.json; do echo "$(md5 -q "harness/stub/$f") $(md5 -q "$S25/$f") $f"; done
  42b656ddba1e9f80107495c65dacc975 42b656ddba1e9f80107495c65dacc975 Stub.java
  4d31cc0a22001b3e7c32039403f1e169 4d31cc0a22001b3e7c32039403f1e169 www/customers.json
  9c7a89abebc65ff24084c7dc20334945 9c7a89abebc65ff24084c7dc20334945 www/meera.json
  aac4c7331ac8d1c6582f98cd75be6e0a aac4c7331ac8d1c6582f98cd75be6e0a www/priya.json
  17fcfbe710b521778d2df671dcf74cc3 17fcfbe710b521778d2df671dcf74cc3 www/ravi.json
  8fcb5f742744e02a06c3f06606272b26 8fcb5f742744e02a06c3f06606272b26 www/sunil.json
  the same md5, file by file: 6 of 6 · routes this unit adds to it: 0
where RestTemplate stands - what its class files say about deprecation: the class and every class nested in it, each read with javap -v -p (this unit's line):
$ python3 harness/deps.py .harness/anchor/tiffinbox-web/target/extracted/lib/spring-web-7.0.9.jar org.springframework.web.client.RestTemplate
  org.springframework.web.client.RestTemplate · javap: 4215 lines · members: 85 · Deprecated attributes: on the class 0, on members 0
  org.springframework.web.client.RestTemplate$AcceptHeaderRequestCallback · javap: 633 lines · members: 9 · Deprecated attributes: on the class 0, on members 0
  org.springframework.web.client.RestTemplate$HeadersExtractor · javap: 111 lines · members: 3 · Deprecated attributes: on the class 0, on members 0
  org.springframework.web.client.RestTemplate$HttpEntityRequestCallback · javap: 910 lines · members: 10 · Deprecated attributes: on the class 0, on members 0
  org.springframework.web.client.RestTemplate$ResponseEntityResponseExtractor · javap: 275 lines · members: 5 · Deprecated attributes: on the class 0, on members 0
  class files read: 5 · Deprecated attributes in all: 0
Boot's builder for it - the same reader, on the one class (this unit's line):
$ python3 harness/deps.py .harness/xlib/spring-boot-restclient-4.1.1.jar org.springframework.boot.restclient.RestTemplateBuilder
  org.springframework.boot.restclient.RestTemplateBuilder · javap: 2780 lines · members: 60 · Deprecated attributes: on the class 0, on members 1 · public org.springframework.boot.restclient.RestTemplateBuilder rootUri(java.lang.String) (@Deprecated(forRemoval=true, since="4.1.0"))
  class files read: 1 · Deprecated attributes in all: 1
whose classes - each read off the one jar on that class path that holds it (unzip -l, by name):
  org.springframework.web.client.RestTemplate · in: spring-web-7.0.9.jar
  org.springframework.web.client.RestClient · in: spring-web-7.0.9.jar
  org.springframework.http.client.ClientHttpRequestInterceptor · in: spring-web-7.0.9.jar
  org.springframework.http.client.JdkClientHttpRequestFactory · in: spring-web-7.0.9.jar
  org.springframework.http.client.SimpleClientHttpRequestFactory · in: spring-web-7.0.9.jar
  org.springframework.boot.restclient.RestTemplateBuilder · in: spring-boot-restclient-4.1.1.jar
  org.springframework.boot.restclient.autoconfigure.RestTemplateAutoConfiguration · in: spring-boot-restclient-4.1.1.jar
the seven - the anchor, the README's run line (its locale pinned), port 19560, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19560
  listens on: 127.0.0.1:19560 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19560/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19560 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0 · lines that say "deprecat": 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
the seven - the anchor on its class path, the two jars and the harness joined (Templates, TemplateRoutes; the case beans), port 19561, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19561 --spring.main.sources=probe.web.Templates,probe.web.TemplateRoutes --probe.cases=beans
  listens on: 127.0.0.1:19561 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19561/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Templates): en_US
  the harness's lines (Templates), in the order they printed: 6
    the JVM's locale: en_US
    beans RestTemplateBuilder: restTemplateBuilder (scope singleton) -> org.springframework.boot.restclient.RestTemplateBuilder | made by: org.springframework.boot.restclient.autoconfigure.RestTemplateAutoConfiguration
    beans RestTemplate: no bean
    beans RestClient.Builder: restClientBuilder (scope prototype) -> org.springframework.web.client.DefaultRestClientBuilder | made by: org.springframework.boot.restclient.autoconfigure.RestClientAutoConfiguration
    beans RestClient: no bean
    done
$ $CURLSET 19561 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 466c20ed7e0d5439cb052f32ce09de1b
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  WARN lines in this run's log, at Boot's default level: 1 · ERROR lines: 0 · lines that say "deprecat": 0
    WARN o.s.web.servlet.PageNotFound: Request method 'GET' is not supported
the lines that moved - the README's run line's seven against the harness line's, masked, line for line:
  lines that differ: 0 · the same, byte for byte: 7 (1 2 3 4 5 6 7)
```

## 2 · side — the same job, the same exceptions, other habits

The stub on `127.0.0.1:19566`, read off its pid, `en_US`. One JVM, the case `side`: a template from Boot's builder and a RestClient from
a clone of Boot's builder, each asked for `week-9.json`, which the stub does not have. **Both throw `HttpClientErrorException$NotFound`,
status 404 — the same exception class: true.** Their messages differ: the template's **names the URL** — `404 Not Found on GET request for
"http://127.0.0.1:19566/week-9.json": "not found"` (the stub's port, from this unit's own range) — RestClient's does not (`404 Not Found:
"not found"`, the RestClient lesson's line). Both read Meera's row into the same record. **The template's message converters: 5** —
`ByteArray…`, `String…`, `Resource…`, `AllEncompassingForm…`, and **`JacksonJsonHttpMessageConverter` last**. **The stub's dump, whole (38
lines), and one line a request:** the template sent an **`Accept`** header on both its requests — `text/plain, application/json,
application/*+json, */*` when it was asked for a `String`, **`application/json, application/*+json`** when asked for a `Row` (the types
its converters can read into the type asked for); **RestClient sent none**, on both (S5.13: measured for `String` and `Row`, on the JDK
factory). Everything else matched: the same JDK client underneath (`Java-http-client/<version>`, the h2c offer, `accept-encoding` two
values, `gzip` and `deflate` — the RestClient lesson's measurement, the same here). 0 WARN, 0 ERROR.

`.r-side.out` · md5 `d264355cde81fa5fdf8b8e6497f108a1` · 3 of 3

```
the stub - this unit's line, port 19566:
$ java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19566 --www=harness/stub/www
  the stub listens on: 127.0.0.1:19566 · loopback only: yes · its locale: en_US
side by side - the anchor on its class path, the two jars and the harness joined (Templates), the case side, port 19562, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19562 --spring.main.sources=probe.web.Templates --probe.cases=side
  listens on: 127.0.0.1:19562 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19562/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Templates): en_US
  the harness's lines (Templates), in the order they printed: 8
    the JVM's locale: en_US
    side the template, getForObject /week-9.json -> org.springframework.web.client.HttpClientErrorException$NotFound | status 404 | message: 404 Not Found on GET request for "http://127.0.0.1:19566/week-9.json": "not found"
    side RestClient, retrieve /week-9.json -> org.springframework.web.client.HttpClientErrorException$NotFound | status 404 | message: 404 Not Found: "not found"
    side the same exception class: true
    side the template, getForObject /{f} meera.json, Row.class -> Row[name=Meera, mealsPerDay=1, pricePerMeal=150, veg=true]
    side RestClient, retrieve /{f} meera.json, body(Row.class) -> Row[name=Meera, mealsPerDay=1, pricePerMeal=150, veg=true]
    side the template's message converters: 5 [org.springframework.http.converter.ByteArrayHttpMessageConverter, org.springframework.http.converter.StringHttpMessageConverter, org.springframework.http.converter.ResourceHttpMessageConverter, org.springframework.http.converter.support.AllEncompassingFormHttpMessageConverter, org.springframework.http.converter.json.JacksonJsonHttpMessageConverter]
    done
what the clients sent, and what the stub answered - the stub's dump of the calls, whole:
  the stub's dump since, whole: 38 lines
    | STUB GET /week-9.json headers=[Accept, Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent]
    | STUB-H accept: text/plain, application/json, application/*+json, */*
    | STUB-H accept-encoding: gzip
    | STUB-H accept-encoding: deflate
    | STUB-H connection: Upgrade, HTTP2-Settings
    | STUB-H host: 127.0.0.1:19566
    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
    | STUB-H upgrade: h2c
    | STUB-H user-agent: Java-http-client/<version>
    | STUB-ANSWER 404 text/plain 9 bytes
    | STUB GET /week-9.json headers=[Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent]
    | STUB-H accept-encoding: gzip
    | STUB-H accept-encoding: deflate
    | STUB-H connection: Upgrade, HTTP2-Settings
    | STUB-H host: 127.0.0.1:19566
    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
    | STUB-H upgrade: h2c
    | STUB-H user-agent: Java-http-client/<version>
    | STUB-ANSWER 404 text/plain 9 bytes
    | STUB GET /meera.json headers=[Accept, Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent]
    | STUB-H accept: application/json, application/*+json
    | STUB-H accept-encoding: gzip
    | STUB-H accept-encoding: deflate
    | STUB-H connection: Upgrade, HTTP2-Settings
    | STUB-H host: 127.0.0.1:19566
    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
    | STUB-H upgrade: h2c
    | STUB-H user-agent: Java-http-client/<version>
    | STUB-ANSWER 200 application/json 73 bytes
    | STUB GET /meera.json headers=[Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent]
    | STUB-H accept-encoding: gzip
    | STUB-H accept-encoding: deflate
    | STUB-H connection: Upgrade, HTTP2-Settings
    | STUB-H host: 127.0.0.1:19566
    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
    | STUB-H upgrade: h2c
    | STUB-H user-agent: Java-http-client/<version>
    | STUB-ANSWER 200 application/json 73 bytes
  what each request carried, one line a request:
    GET /week-9.json · accept: text/plain, application/json, application/*+json, */* · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: Java-http-client/<version> · x-via: none
    GET /week-9.json · accept: none · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: Java-http-client/<version> · x-via: none
    GET /meera.json · accept: application/json, application/*+json · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: Java-http-client/<version> · x-via: none
    GET /meera.json · accept: none · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: Java-http-client/<version> · x-via: none
  the requests: 4 · with an Accept header: 2 · with accept-encoding: 4 · with upgrade: 4 · with X-Via: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19562 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19562 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the stub: stopped by its pid · exit 143 · listening on 19566 now: 0 · requests in its dump: 4 · the demo token 0 times · X-Shutdown-Token 0 times
```

## 3 · factories — the request factory: A/B/A′

Each run a fresh stub and a fresh JVM; 19569 asserted free first. **A — the template from Boot's builder**
(`RestTemplateBuilder.build()`): its request factory, read off the template, **`JdkClientHttpRequestFactory`** — the JDK's `HttpClient`, the
RestClient lesson's factory; the stub's dump: `user-agent: Java-http-client/<version>`, **`upgrade: h2c`**, `accept-encoding: gzip`,
`deflate`. **B — `new RestTemplate()`**: **`SimpleClientHttpRequestFactory`** — the JDK's `HttpURLConnection`; the dump: **`user-agent:
Java/<version>`**, **no `upgrade`, no `accept-encoding`**, `connection: keep-alive`. On this class path (no httpclient5, S5.3): what makes a
template decides how it talks — Boot's builder applies Boot's client settings, `new` takes Framework's default. **Both followed the stub's
`/redirect`** (302 → `/ravi.json`, 200, Ravi's row): the dump shows the 302 and the second request, in each. **GET only**: every one of
the nine requests in this capture is a GET (a check), and a non-GET redirect was not run (RE-MEASURE 7: unspoken). Both sent `Accept:
application/json, application/*+json` for a `Row`. **A′ = A**, its `$` line shown, its block the same as A's line for line ("yes").

`.r-factories.out` · md5 `d06f7c30ed7cb32afafef16294815736` · 3 of 3

```
  19569, never bound: listening 0 (lsof, by port)
A - the template from Boot's builder (RestTemplateBuilder.build()), the case boot, a fresh stub, port 19563, a fresh JVM:
$ java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19566 --www=harness/stub/www
  the stub listens on: 127.0.0.1:19566 · loopback only: yes · its locale: en_US
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19563 --spring.main.sources=probe.web.Templates --probe.cases=boot
  listens on: 127.0.0.1:19563 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19563/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Templates): en_US
  the harness's lines (Templates), in the order they printed: 5
    the JVM's locale: en_US
    boot its request factory: org.springframework.http.client.JdkClientHttpRequestFactory
    boot getForObject /{f} meera.json -> Row[name=Meera, mealsPerDay=1, pricePerMeal=150, veg=true]
    boot getForEntity /redirect -> 200 Row[name=Ravi, mealsPerDay=2, pricePerMeal=120, veg=true]
    done
  the stub's dump since, whole: 30 lines
    | STUB GET /meera.json headers=[Accept, Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent]
    | STUB-H accept: application/json, application/*+json
    | STUB-H accept-encoding: gzip
    | STUB-H accept-encoding: deflate
    | STUB-H connection: Upgrade, HTTP2-Settings
    | STUB-H host: 127.0.0.1:19566
    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
    | STUB-H upgrade: h2c
    | STUB-H user-agent: Java-http-client/<version>
    | STUB-ANSWER 200 application/json 73 bytes
    | STUB GET /redirect headers=[Accept, Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent]
    | STUB-H accept: application/json, application/*+json
    | STUB-H accept-encoding: gzip
    | STUB-H accept-encoding: deflate
    | STUB-H connection: Upgrade, HTTP2-Settings
    | STUB-H host: 127.0.0.1:19566
    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
    | STUB-H upgrade: h2c
    | STUB-H user-agent: Java-http-client/<version>
    | STUB-ANSWER 302 text/plain 5 bytes
    | STUB GET /ravi.json headers=[Accept, Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent]
    | STUB-H accept: application/json, application/*+json
    | STUB-H accept-encoding: gzip
    | STUB-H accept-encoding: deflate
    | STUB-H connection: Upgrade, HTTP2-Settings
    | STUB-H host: 127.0.0.1:19566
    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
    | STUB-H upgrade: h2c
    | STUB-H user-agent: Java-http-client/<version>
    | STUB-ANSWER 200 application/json 73 bytes
  what each request carried, one line a request:
    GET /meera.json · accept: application/json, application/*+json · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: Java-http-client/<version> · x-via: none
    GET /redirect · accept: application/json, application/*+json · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: Java-http-client/<version> · x-via: none
    GET /ravi.json · accept: application/json, application/*+json · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: Java-http-client/<version> · x-via: none
  the requests: 3 · with an Accept header: 3 · with accept-encoding: 3 · with upgrade: 3 · with X-Via: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19563 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19563 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the stub: stopped by its pid · exit 143 · listening on 19566 now: 0 · requests in its dump: 3 · the demo token 0 times · X-Shutdown-Token 0 times
B - new RestTemplate(), the case new, a fresh stub, port 19560, a fresh JVM:
$ java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19566 --www=harness/stub/www
  the stub listens on: 127.0.0.1:19566 · loopback only: yes · its locale: en_US
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19560 --spring.main.sources=probe.web.Templates --probe.cases=new
  listens on: 127.0.0.1:19560 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19560/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Templates): en_US
  the harness's lines (Templates), in the order they printed: 5
    the JVM's locale: en_US
    new its request factory: org.springframework.http.client.SimpleClientHttpRequestFactory
    new getForObject /{f} meera.json -> Row[name=Meera, mealsPerDay=1, pricePerMeal=150, veg=true]
    new getForEntity /redirect -> 200 Row[name=Ravi, mealsPerDay=2, pricePerMeal=120, veg=true]
    done
  the stub's dump since, whole: 18 lines
    | STUB GET /meera.json headers=[Accept, Connection, Host, User-agent]
    | STUB-H accept: application/json, application/*+json
    | STUB-H connection: keep-alive
    | STUB-H host: 127.0.0.1:19566
    | STUB-H user-agent: Java/<version>
    | STUB-ANSWER 200 application/json 73 bytes
    | STUB GET /redirect headers=[Accept, Connection, Host, User-agent]
    | STUB-H accept: application/json, application/*+json
    | STUB-H connection: keep-alive
    | STUB-H host: 127.0.0.1:19566
    | STUB-H user-agent: Java/<version>
    | STUB-ANSWER 302 text/plain 5 bytes
    | STUB GET /ravi.json headers=[Accept, Connection, Host, User-agent]
    | STUB-H accept: application/json, application/*+json
    | STUB-H connection: keep-alive
    | STUB-H host: 127.0.0.1:19566
    | STUB-H user-agent: Java/<version>
    | STUB-ANSWER 200 application/json 73 bytes
  what each request carried, one line a request:
    GET /meera.json · accept: application/json, application/*+json · accept-encoding: none · upgrade: none · user-agent: Java/<version> · x-via: none
    GET /redirect · accept: application/json, application/*+json · accept-encoding: none · upgrade: none · user-agent: Java/<version> · x-via: none
    GET /ravi.json · accept: application/json, application/*+json · accept-encoding: none · upgrade: none · user-agent: Java/<version> · x-via: none
  the requests: 3 · with an Accept header: 3 · with accept-encoding: 0 · with upgrade: 0 · with X-Via: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19560 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19560 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the stub: stopped by its pid · exit 143 · listening on 19566 now: 0 · requests in its dump: 3 · the demo token 0 times · X-Shutdown-Token 0 times
A' - A again, a fresh stub, port 19563, a fresh JVM:
$ java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19566 --www=harness/stub/www
  the stub listens on: 127.0.0.1:19566 · loopback only: yes · its locale: en_US
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19563 --spring.main.sources=probe.web.Templates --probe.cases=boot
  listens on: 127.0.0.1:19563 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19563/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Templates): en_US
  the harness's lines (Templates), in the order they printed: 5
    the JVM's locale: en_US
    boot its request factory: org.springframework.http.client.JdkClientHttpRequestFactory
    boot getForObject /{f} meera.json -> Row[name=Meera, mealsPerDay=1, pricePerMeal=150, veg=true]
    boot getForEntity /redirect -> 200 Row[name=Ravi, mealsPerDay=2, pricePerMeal=120, veg=true]
    done
  the stub's dump since, whole: 30 lines
    | STUB GET /meera.json headers=[Accept, Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent]
    | STUB-H accept: application/json, application/*+json
    | STUB-H accept-encoding: gzip
    | STUB-H accept-encoding: deflate
    | STUB-H connection: Upgrade, HTTP2-Settings
    | STUB-H host: 127.0.0.1:19566
    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
    | STUB-H upgrade: h2c
    | STUB-H user-agent: Java-http-client/<version>
    | STUB-ANSWER 200 application/json 73 bytes
    | STUB GET /redirect headers=[Accept, Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent]
    | STUB-H accept: application/json, application/*+json
    | STUB-H accept-encoding: gzip
    | STUB-H accept-encoding: deflate
    | STUB-H connection: Upgrade, HTTP2-Settings
    | STUB-H host: 127.0.0.1:19566
    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
    | STUB-H upgrade: h2c
    | STUB-H user-agent: Java-http-client/<version>
    | STUB-ANSWER 302 text/plain 5 bytes
    | STUB GET /ravi.json headers=[Accept, Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent]
    | STUB-H accept: application/json, application/*+json
    | STUB-H accept-encoding: gzip
    | STUB-H accept-encoding: deflate
    | STUB-H connection: Upgrade, HTTP2-Settings
    | STUB-H host: 127.0.0.1:19566
    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
    | STUB-H upgrade: h2c
    | STUB-H user-agent: Java-http-client/<version>
    | STUB-ANSWER 200 application/json 73 bytes
  what each request carried, one line a request:
    GET /meera.json · accept: application/json, application/*+json · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: Java-http-client/<version> · x-via: none
    GET /redirect · accept: application/json, application/*+json · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: Java-http-client/<version> · x-via: none
    GET /ravi.json · accept: application/json, application/*+json · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: Java-http-client/<version> · x-via: none
  the requests: 3 · with an Accept header: 3 · with accept-encoding: 3 · with upgrade: 3 · with X-Via: 0
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19563 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19563 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the stub: stopped by its pid · exit 143 · listening on 19566 now: 0 · requests in its dump: 3 · the demo token 0 times · X-Shutdown-Token 0 times
A' against A, its label aside, line for line the same: yes
```

## 4 · migrate — the move

One JVM, the case `migrate`. **The old setup**: a template from Boot's builder with `additionalInterceptors(new Via())` — its
interceptors `[probe.web.Via]`, its request factory now `InterceptingClientHttpRequestFactory` (the template wraps its factory to run the
interceptor). **The move, two ways**: `RestClient.create(template)` and `RestClient.builder(template).build()` — each read off the client:
**its interceptors `[probe.web.Via]`**, its request factory **`JdkClientHttpRequestFactory`** (the factory under the template's wrapper;
the interceptor travels as the client's own); each reads Ravi's row. **`RestClient.create()`** beside them, for the record: interceptors
none, the same JDK factory. **The stub's dump, whole (40 lines), one line a request:** `x-via: template-interceptor` on **3 of 4** — the
template's and **both migrated clients'** — and not on `create()`'s; **`Accept` on 1 of 4**, the template's: **the migrated clients still
send none** — RestClient's own habit, which the move does not change. **One scrape**: `uri="/{f}"` **3** — the template's call and both
migrated calls observed (the template's observation travelled with it); `create()`'s call, made under `/{name}`, **absent** (R.140: both
ways in one scrape). 0 WARN, 0 ERROR.

`.r-migrate.out` · md5 `15641cf0af7934b7f1e63945dfd61b82` · 3 of 3

```
the stub - this unit's line, port 19566:
$ java -Duser.language=en -Duser.country=US harness/stub/Stub.java --port=19566 --www=harness/stub/www
  the stub listens on: 127.0.0.1:19566 · loopback only: yes · its locale: en_US
the move - the anchor on its class path, the two jars and the harness joined (Templates), the case migrate, port 19561, a fresh JVM:
$ cd .harness/anchor && java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19561 --spring.main.sources=probe.web.Templates --probe.cases=migrate
  listens on: 127.0.0.1:19561 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19561/actuator/health/readiness
  {"status":"UP"} 200
  the JVM's locale (the harness's Templates): en_US
  the harness's lines (Templates), in the order they printed: 10
    the JVM's locale: en_US
    migrate the template: its interceptors [probe.web.Via] | its request factory org.springframework.http.client.InterceptingClientHttpRequestFactory
    migrate the template, getForObject /{f} ravi.json -> Row[name=Ravi, mealsPerDay=2, pricePerMeal=120, veg=true]
    migrate RestClient.create(template): its interceptors [probe.web.Via] | its request factory org.springframework.http.client.JdkClientHttpRequestFactory
    migrate RestClient.create(template), retrieve /{f} ravi.json -> Row[name=Ravi, mealsPerDay=2, pricePerMeal=120, veg=true]
    migrate RestClient.builder(template).build(): its interceptors [probe.web.Via] | its request factory org.springframework.http.client.JdkClientHttpRequestFactory
    migrate RestClient.builder(template).build(), retrieve /{f} ravi.json -> Row[name=Ravi, mealsPerDay=2, pricePerMeal=120, veg=true]
    migrate RestClient.create(): its interceptors none | its request factory org.springframework.http.client.JdkClientHttpRequestFactory
    migrate RestClient.create(), retrieve /{name} ravi.json -> Row[name=Ravi, mealsPerDay=2, pricePerMeal=120, veg=true]
    done
what the clients sent - the stub's dump of the four calls, whole:
  the stub's dump since, whole: 40 lines
    | STUB GET /ravi.json headers=[Accept, Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent, X-via]
    | STUB-H accept: application/json, application/*+json
    | STUB-H accept-encoding: gzip
    | STUB-H accept-encoding: deflate
    | STUB-H connection: Upgrade, HTTP2-Settings
    | STUB-H host: 127.0.0.1:19566
    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
    | STUB-H upgrade: h2c
    | STUB-H user-agent: Java-http-client/<version>
    | STUB-H x-via: template-interceptor
    | STUB-ANSWER 200 application/json 73 bytes
    | STUB GET /ravi.json headers=[Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent, X-via]
    | STUB-H accept-encoding: gzip
    | STUB-H accept-encoding: deflate
    | STUB-H connection: Upgrade, HTTP2-Settings
    | STUB-H host: 127.0.0.1:19566
    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
    | STUB-H upgrade: h2c
    | STUB-H user-agent: Java-http-client/<version>
    | STUB-H x-via: template-interceptor
    | STUB-ANSWER 200 application/json 73 bytes
    | STUB GET /ravi.json headers=[Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent, X-via]
    | STUB-H accept-encoding: gzip
    | STUB-H accept-encoding: deflate
    | STUB-H connection: Upgrade, HTTP2-Settings
    | STUB-H host: 127.0.0.1:19566
    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
    | STUB-H upgrade: h2c
    | STUB-H user-agent: Java-http-client/<version>
    | STUB-H x-via: template-interceptor
    | STUB-ANSWER 200 application/json 73 bytes
    | STUB GET /ravi.json headers=[Accept-encoding, Connection, Host, Http2-settings, Upgrade, User-agent]
    | STUB-H accept-encoding: gzip
    | STUB-H accept-encoding: deflate
    | STUB-H connection: Upgrade, HTTP2-Settings
    | STUB-H host: 127.0.0.1:19566
    | STUB-H http2-settings: AAEAAEAAAAIAAAAAAAMAAAAAAAQBAAAAAAUAAEAAAAYABgAA
    | STUB-H upgrade: h2c
    | STUB-H user-agent: Java-http-client/<version>
    | STUB-ANSWER 200 application/json 73 bytes
  what each request carried, one line a request:
    GET /ravi.json · accept: application/json, application/*+json · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: Java-http-client/<version> · x-via: template-interceptor
    GET /ravi.json · accept: none · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: Java-http-client/<version> · x-via: template-interceptor
    GET /ravi.json · accept: none · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: Java-http-client/<version> · x-via: template-interceptor
    GET /ravi.json · accept: none · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: Java-http-client/<version> · x-via: none
  the requests: 4 · with an Accept header: 1 · with accept-encoding: 4 · with upgrade: 4 · with X-Via: 3
what was observed - one scrape of the same JVM's /actuator/prometheus (this unit's line):
$ curl -s -o .harness/prom.txt -w ' %{http_code}\n' http://127.0.0.1:19561/actuator/prometheus
   200
  kept: 1 of the scrape's lines, by the filter ^http_client_requests_seconds_count, sorted · the others not shown: over 150 (their number moves from run to run: the JVM's own meters)
    http_client_requests_seconds_count{client_name="127.0.0.1",error="none",exception="none",method="GET",outcome="SUCCESS",status="200",uri="/{f}"} 3
  WARN lines in this run's log, at Boot's default level: 0 · ERROR lines: 0 · lines that say "deprecat": 0
$ harness/shutdown.sh 19561 .harness/anchor/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 application/json · Content-Length: none · {"stopping":true} · curl exit 0
  exit 0 · listening on 19561 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the stub: stopped by its pid · exit 143 · listening on 19566 now: 0 · requests in its dump: 4 · the demo token 0 times · X-Shutdown-Token 0 times
```

## 5 · who — who still names it

No JVM. **The class files that name `RestTemplate`** (`who.py`, the method above: the constant-pool string, not followed by a name
character), on **every jar of the class path the harness runs on** — TiffinBox's own jar, the anchor's 61 libraries (tiffinbox-core among
them) and the two the starter adds: **64 jars, 16,587 class files, 16 name it.** **spring-web, 9**: `RestTemplate` itself and its four
nested classes, `RestClient` and `DefaultRestClientBuilder` (where `RestClient.create(template)` and `builder(template)` live),
`RestGatewaySupport`, `RestTemplateAdapter`. **spring-boot-restclient, 6**: `RestTemplateBuilder`, `RestTemplateCustomizer`,
`RootUriBuilderFactory`, `RestTemplateAutoConfiguration`, `RestTemplateObservationAutoConfiguration`, `ObservationRestTemplateCustomizer`.
**spring-boot-http-converter, 1**: Boot's **`HttpMessageConverters`** — whose own class file is **`@Deprecated(since="4.0.0")`** (read with
`deps.py`). **TiffinBox's own two jars: 0** (11 and 9 class files); the other 59 jars: 0, counted, not listed. **The two test modules'
jars**, read from `.m2-demo` — **not on this class path**: **spring-boot-resttestclient**'s
`TestRestTemplate` (1) and **spring-test**'s `MockRestServiceServer` and its `RestTemplate` builder (2). Their class files:
`TestRestTemplate` — the class not deprecated, **one member of a class nested in it is** (`HttpClientOption.ENABLE_COOKIES`, since 4.1.0,
for removal); `MockRestServiceServer` and its six nested classes — 0. **The sources**: `grep -rlw RestTemplate` over TiffinBox's two
modules finds **0 files**, over the harness 2 (`Templates`, `TemplateRoutes`) — the same grep, so it can find one.

`.r-who.out` · md5 `6e503b495eef4196bdaf934e131891f8` · 3 of 3

```
which class files name RestTemplate - every jar on the class path the harness runs on: TiffinBox's own jar, the anchor's 61 libraries (tiffinbox-core among them), the 2 the starter adds (this unit's line):
$ python3 harness/who.py org/springframework/web/client/RestTemplate .harness/anchor/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar .harness/anchor/tiffinbox-web/target/extracted/lib/*.jar .harness/xlib/*.jar
  tiffinbox-web-1.0.0.jar · class files: 11 · naming it: 0
  spring-boot-http-converter-4.1.1.jar · class files: 45 · naming it: 1
      org.springframework.boot.http.converter.autoconfigure.HttpMessageConverters
  spring-web-7.0.9.jar · class files: 1325 · naming it: 9
      org.springframework.web.client.DefaultRestClientBuilder
      org.springframework.web.client.RestClient
      org.springframework.web.client.RestTemplate$AcceptHeaderRequestCallback
      org.springframework.web.client.RestTemplate$HeadersExtractor
      org.springframework.web.client.RestTemplate$HttpEntityRequestCallback
      org.springframework.web.client.RestTemplate$ResponseEntityResponseExtractor
      org.springframework.web.client.RestTemplate
      org.springframework.web.client.support.RestGatewaySupport
      org.springframework.web.client.support.RestTemplateAdapter
  tiffinbox-core-1.0.0.jar · class files: 9 · naming it: 0
  spring-boot-restclient-4.1.1.jar · class files: 29 · naming it: 6
      org.springframework.boot.restclient.RestTemplateBuilder
      org.springframework.boot.restclient.RestTemplateCustomizer
      org.springframework.boot.restclient.RootUriBuilderFactory
      org.springframework.boot.restclient.autoconfigure.RestTemplateAutoConfiguration
      org.springframework.boot.restclient.autoconfigure.RestTemplateObservationAutoConfiguration
      org.springframework.boot.restclient.observation.ObservationRestTemplateCustomizer
  jars where no class file names it: 59 (not listed)
  jars read: 64 · class files read: 16587 · naming org.springframework.web.client.RestTemplate: 16
the two test modules' jars - in .m2-demo, not on that class path (this unit's line):
$ python3 harness/who.py org/springframework/web/client/RestTemplate "$M2/org/springframework/boot/spring-boot-resttestclient/4.1.1/spring-boot-resttestclient-4.1.1.jar" "$M2/org/springframework/spring-test/7.0.9/spring-test-7.0.9.jar"
  spring-boot-resttestclient-4.1.1.jar · class files: 19 · naming it: 1
      org.springframework.boot.resttestclient.TestRestTemplate
  spring-test-7.0.9.jar · class files: 658 · naming it: 2
      org.springframework.test.web.client.MockRestServiceServer$RestTemplateMockRestServiceServerBuilder
      org.springframework.test.web.client.MockRestServiceServer
  jars where no class file names it: 0 (not listed)
  jars read: 2 · class files read: 677 · naming org.springframework.web.client.RestTemplate: 3
what the class files of three of the classes found say about deprecation - the same reader (this unit's lines):
$ python3 harness/deps.py .harness/anchor/tiffinbox-web/target/extracted/lib/spring-boot-http-converter-4.1.1.jar org.springframework.boot.http.converter.autoconfigure.HttpMessageConverters
  org.springframework.boot.http.converter.autoconfigure.HttpMessageConverters · javap: 1149 lines · members: 19 · Deprecated attributes: on the class 1, on members 0 · the class (@Deprecated(since="4.0.0"))
  org.springframework.boot.http.converter.autoconfigure.HttpMessageConverters$1 · javap: 93 lines · members: 3 · Deprecated attributes: on the class 0, on members 0
  class files read: 2 · Deprecated attributes in all: 1
$ python3 harness/deps.py "$M2/org/springframework/boot/spring-boot-resttestclient/4.1.1/spring-boot-resttestclient-4.1.1.jar" org.springframework.boot.resttestclient.TestRestTemplate
  org.springframework.boot.resttestclient.TestRestTemplate · javap: 2643 lines · members: 63 · Deprecated attributes: on the class 0, on members 0
  org.springframework.boot.resttestclient.TestRestTemplate$CookieSpecCustomizer · javap: 153 lines · members: 4 · Deprecated attributes: on the class 0, on members 0
  org.springframework.boot.resttestclient.TestRestTemplate$HttpClientOption · javap: 225 lines · members: 9 · Deprecated attributes: on the class 0, on members 1 · public static final org.springframework.boot.resttestclient.TestRestTemplate$HttpClientOption ENABLE_COOKIES (@Deprecated(since="4.1.0", forRemoval=true))
  org.springframework.boot.resttestclient.TestRestTemplate$SelfSignedTlsSocketStrategyFactory · javap: 211 lines · members: 4 · Deprecated attributes: on the class 0, on members 0
  org.springframework.boot.resttestclient.TestRestTemplate$TrustSelfSignedStrategy · javap: 90 lines · members: 2 · Deprecated attributes: on the class 0, on members 0
  class files read: 5 · Deprecated attributes in all: 1
$ python3 harness/deps.py "$M2/org/springframework/spring-test/7.0.9/spring-test-7.0.9.jar" org.springframework.test.web.client.MockRestServiceServer
  org.springframework.test.web.client.MockRestServiceServer · javap: 390 lines · members: 13 · Deprecated attributes: on the class 0, on members 0
  org.springframework.test.web.client.MockRestServiceServer$AbstractMockRestServiceServerBuilder · javap: 241 lines · members: 9 · Deprecated attributes: on the class 0, on members 0
  org.springframework.test.web.client.MockRestServiceServer$MockClientHttpRequestFactory · javap: 149 lines · members: 4 · Deprecated attributes: on the class 0, on members 0
  org.springframework.test.web.client.MockRestServiceServer$MockClientHttpRequestFactory$1 · javap: 139 lines · members: 3 · Deprecated attributes: on the class 0, on members 0
  org.springframework.test.web.client.MockRestServiceServer$MockRestServiceServerBuilder · javap: 59 lines · members: 4 · Deprecated attributes: on the class 0, on members 0
  org.springframework.test.web.client.MockRestServiceServer$RestClientMockRestServiceServerBuilder · javap: 190 lines · members: 4 · Deprecated attributes: on the class 0, on members 0
  org.springframework.test.web.client.MockRestServiceServer$RestTemplateMockRestServiceServerBuilder · javap: 184 lines · members: 4 · Deprecated attributes: on the class 0, on members 0
  class files read: 7 · Deprecated attributes in all: 0
the sources - TiffinBox's two modules and the harness, the word RestTemplate (this unit's line):
$ grep -rlw RestTemplate anchor/tiffinbox-core/src anchor/tiffinbox-web/src harness/probe/web | sort
  harness/probe/web/TemplateRoutes.java
  harness/probe/web/Templates.java
  files that name it: under anchor/ 0 · under harness/ 2
```

## 6 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s seven lines, then `exercise/solution/SOLUTION.md`'s four, each exactly as written, one after the other in **one**
shell: `env -i` (HOME and the PATH `receipts.sh` was started with — so neither its `JAVA_HOME` nor its `LC_ALL`), `/bin/bash --noprofile
--norc`, in this folder. The README's run, as shipped (`this.moved = RestClient.create();` in the route's copy): **`the old call: 200 · the
moved call: 200 · requests at the stub with X-Via: 1 of 2 · observed calls: 1`** — both routes answer Ravi's row, but only the old call
carried `X-Via`, and only the old call was observed; nothing failed, and nothing in the log says so (0 WARN, 0 ERROR). The solution's one
line — `RestClient.create()` becomes `RestClient.create(template)` in `.harness/mine/src/TemplateRoutes.java` — and the README's last line,
unchanged: **`the old call: 200 · the moved call: 200 · requests at the stub with X-Via: 2 of 2 · observed calls: 2`**; the moved request
carries `x-via: template-interceptor` and still no `Accept`. After each, the shell is back in this folder, 19564 and 19566 are free, both
JVMs printed `en_US`, and the copy's own token is in neither log.

`.r-exercise.out` · md5 `fbb61a7e9ffa5a03cdbceb74dccd1f64` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 7 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine/xlib && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/anchor/
  $ mkdir -p .harness/mine/anchor/secrets/tiffinbox && chmod 700 .harness/mine/anchor/secrets .harness/mine/anchor/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/anchor/secrets/tiffinbox/shutdown-token)
  $ mkdir -p .harness/mine/src && cp harness/probe/web/*.java .harness/mine/src/
  $ M="$PWD/.m2-demo" && H="$PWD/harness" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && mvn -o -B -q -Dmaven.repo.local="$M" -f "$H/pom.xml" dependency:build-classpath -Dmdep.outputFile="$PWD/../harness.cp" && rm -f ../xlib/* && tr ':' '\n' < ../harness.cp | while IFS= read -r j; do [ -e "tiffinbox-web/target/extracted/lib/${j##*/}" ] || ! unzip -l "$j" | grep -q '\.class$' || cp "$j" ../xlib/; done && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*:../xlib/*" ../src/*.java && { java -Duser.language=en -Duser.country=US "$H/stub/Stub.java" --port=19566 --www="$H/stub/www" > ../stub.log 2>&1 & } && s=$! && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19564 --spring.main.sources=probe.web.TemplateRoutes > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do grep -q '^STUB listening' ../stub.log && [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19564/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -o ../old.txt -w '%{http_code}' http://127.0.0.1:19564/probe/old) && b=$(curl -s -o ../moved.txt -w '%{http_code}' http://127.0.0.1:19564/probe/moved) && o=$(curl -s http://127.0.0.1:19564/actuator/prometheus | awk '/^http_client_requests_seconds_count/ && index($0, "uri=\"/{f}\"") { s += $NF } END { print s + 0 }'); "$H/shutdown.sh" 19564 secrets/tiffinbox/shutdown-token > /dev/null; kill "$s"; wait "$s"; wait "$p" && echo "the old call: $a · the moved call: $b · requests at the stub with X-Via: $(grep -c '^STUB-H x-via: template-interceptor$' ../stub.log) of $(grep -c '^STUB [A-Z]* /' ../stub.log) · observed calls: $o")
  exit 0 · what they printed:
    the old call: 200 · the moved call: 200 · requests at the stub with X-Via: 1 of 2 · observed calls: 1
  the moved call in the route's copy (.harness/mine/src/TemplateRoutes.java): 26:        this.moved = RestClient.create();
  the shell is now in: this unit's folder · the JVM's locale in its log: en_US (TemplateRoutes), in the stub's: en_US · the copy's own token in its log: 0 times, in the stub's dump: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19564 now: 0 · on 19566: 0
  the stub's dump of the README's run, one line a request:
    GET /ravi.json · accept: application/json, application/*+json · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: Java-http-client/<version> · x-via: template-interceptor
    GET /ravi.json · accept: none · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: Java-http-client/<version> · x-via: none
  the requests: 2 · with an Accept header: 1 · with accept-encoding: 2 · with upgrade: 2 · with X-Via: 1
the solution's 4 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ sed -i '' 's/RestClient\.create()/RestClient.create(template)/' .harness/mine/src/TemplateRoutes.java
  $ M="$PWD/.m2-demo" && H="$PWD/harness" && (cd .harness/mine/anchor && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests clean package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null && mvn -o -B -q -Dmaven.repo.local="$M" -f "$H/pom.xml" dependency:build-classpath -Dmdep.outputFile="$PWD/../harness.cp" && rm -f ../xlib/* && tr ':' '\n' < ../harness.cp | while IFS= read -r j; do [ -e "tiffinbox-web/target/extracted/lib/${j##*/}" ] || ! unzip -l "$j" | grep -q '\.class$' || cp "$j" ../xlib/; done && rm -rf ../hc && javac -parameters -d ../hc -cp "tiffinbox-web/target/extracted/lib/*:../xlib/*" ../src/*.java && { java -Duser.language=en -Duser.country=US "$H/stub/Stub.java" --port=19566 --www="$H/stub/www" > ../stub.log 2>&1 & } && s=$! && { java -Duser.language=en -Duser.country=US -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../xlib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19564 --spring.main.sources=probe.web.TemplateRoutes > ../run.log 2>&1 & } && p=$! && for i in $(seq 240); do grep -q '^STUB listening' ../stub.log && [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19564/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && a=$(curl -s -o ../old.txt -w '%{http_code}' http://127.0.0.1:19564/probe/old) && b=$(curl -s -o ../moved.txt -w '%{http_code}' http://127.0.0.1:19564/probe/moved) && o=$(curl -s http://127.0.0.1:19564/actuator/prometheus | awk '/^http_client_requests_seconds_count/ && index($0, "uri=\"/{f}\"") { s += $NF } END { print s + 0 }'); "$H/shutdown.sh" 19564 secrets/tiffinbox/shutdown-token > /dev/null; kill "$s"; wait "$s"; wait "$p" && echo "the old call: $a · the moved call: $b · requests at the stub with X-Via: $(grep -c '^STUB-H x-via: template-interceptor$' ../stub.log) of $(grep -c '^STUB [A-Z]* /' ../stub.log) · observed calls: $o")
  exit 0 · what they printed:
    the old call: 200 · the moved call: 200 · requests at the stub with X-Via: 2 of 2 · observed calls: 2
  the moved call in the route's copy: 26:        this.moved = RestClient.create(template);
  the shell is now in: this unit's folder · the JVM's locale in its log: en_US (TemplateRoutes), in the stub's: en_US · the copy's own token in its log: 0 times, in the stub's dump: 0 times · WARN lines in its log: 0 · ERROR lines: 0 · listening on 19564 now: 0 · on 19566: 0
  the stub's dump of the solution's run, one line a request:
    GET /ravi.json · accept: application/json, application/*+json · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: Java-http-client/<version> · x-via: template-interceptor
    GET /ravi.json · accept: none · accept-encoding: gzip, deflate · upgrade: h2c · user-agent: Java-http-client/<version> · x-via: template-interceptor
  the requests: 2 · with an Accept header: 1 · with accept-encoding: 2 · with upgrade: 2 · with X-Via: 2
```

## Exercise

**Your turn:** the README moved the old call to RestClient and lost its X-Via header. Build the client from the template, and call again.
`exercise/README.md` has the commands (copy the anchor, give the copy a token of its own, copy the harness's four sources to
`.harness/mine/src` — the code the viewer changes, never `harness/`); its last line, in a subshell, builds the copy offline, reads the
harness POM's class path, joins the two jars, compiles the copied sources, starts the stub on 19566 and TiffinBox on 19564 with
`TemplateRoutes` joined, calls `GET /probe/old` and `GET /probe/moved` with curl, reads `/actuator/prometheus` once, stops both, waits for
both pids and prints — as shipped — `the old call: 200 · the moved call: 200 · requests at the stub with X-Via: 1 of 2 · observed calls: 1`.
**The check looks at what was sent, not at a status** (R.65): both calls answer 200 either way; only the stub's dump and the scrape tell the
moved call from the old one. Done is `the old call: 200 · the moved call: 200 · requests at the stub with X-Via: 2 of 2 · observed calls: 2`
(`RestClient.create(template)`, the last line unchanged). "Call again" is the README's curl to the harness routes — curl only. Measured
answer: `exercise/solution/`. Run `./receipts.sh` once first on a fresh clone.

## The ledger rows and hand-offs this unit pays

- **The roadmap's U27, "shown once, labelled, with the migration path"** — one lesson: where it stands (`status`: 0 `Deprecated`
  attributes in 7.0.9, Boot's builder bean), side by side with RestClient (`side`), its two factories as an A/B on screen (`factories`), the
  migration path measured (`migrate`: `RestClient.create(template)` and `RestClient.builder(template)` keep the interceptor, the factory and
  the observation; the exercise moves one call), and who still names it (`who`). Never "deprecated", never "maintenance mode" (⚑8).
- **C6-31's glosses** for this unit: a template (the class's own word, not Thymeleaf's), an interceptor on a client, a message converter
  (re-glossed: *Request Bodies and HttpMessageConverter*) — each at first spoken use, gated by the builder; a stub and a request factory are re-glossed in a few words (the RestClient lesson's).
- **The previous lesson's up-next**, "Next: RestTemplate, What You Will Meet in Old Code." — this unit's title (`js.TITLES`, R.63). **The
  RestClient lesson's facts are cited, not re-captured**: the two jars, `JdkClientHttpRequestFactory` on this class path for every way of
  making a RestClient, no `Accept` header from RestClient, `accept-encoding` as two values, and `retrieve()`'s `NotFound` for `week-9.json` —
  `side` sets the template beside that same `NotFound`.
- **S4 CARRIED** — "a local stub on the unit's own ports": the RestClient lesson's stub, copied byte for byte (md5 asserted), on 19566,
  loopback asserted on its pid.

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-28) |
|---|---|---|---|
| 1 | Every 27 capture on `c6-unit24/after` + the unit's own harness | the probe's `base/`, a copy | **all six captures here**, on `anchor/` → `../c6-unit24/after` |
| 2 | The stub as this unit's own copy; its md5 = 25's | the probe's `stub/` | **`harness/stub/`**, `Stub.java` md5 `42b656dd…` = `../c6-unit25`'s, 6 of 6 files (`status`, and a check at the top); no route added |
| 7 | `new RestTemplate()`'s redirect for a non-GET | not run | **not run, unspoken** — `factories` measured GET only (9 requests, every one a GET, a check) and says so |
| 13 | The exercise as viewers run it | end states on sketches | **README then SOLUTION in one `env -i` shell, exit 0 each** (`exercise`, and "Found on the way"); SOLUTION run twice changes nothing more (its `sed` finds nothing left) |

## LINES OVERTURNED OR SHARPENED BY THIS UNIT'S MEASUREMENT

- **Boot's `RestTemplateBuilder` is not wholly free of deprecation**: one of its 60 members, `rootUri(String)`, is `@Deprecated(forRemoval=true,
  since="4.1.0")` (`status`). The class is not deprecated and its bean is still made; the harness names every URL whole and never calls
  `rootUri`. Neither "Boot's builder is deprecated" nor "nothing about it is" is said.
- **`TestRestTemplate`'s class is not deprecated, but a member of a class nested in it is** — `TestRestTemplate$HttpClientOption.ENABLE_COOKIES`,
  since 4.1.0, for removal (`who`): the probe's "not deprecated" was the class alone.
- **The template's `Accept` follows the type asked for**: `application/json, application/*+json` for a `Row` (the brief's line), and
  `text/plain, application/json, application/*+json, */*` for a `String` (`side`) — both quoted from the dump.
- **`new RestTemplate()` sends `connection: keep-alive`** besides `accept`, `host` and `user-agent: Java/<version>` — no `accept-encoding`,
  no `upgrade` (the brief's line holds; the dump has the rest).
- **"The factory is the template's", sharpened**: the template's own `getRequestFactory()` is an `InterceptingClientHttpRequestFactory`
  wrapping the JDK's; the migrated clients hold the JDK's `JdkClientHttpRequestFactory` and carry the interceptor in a list of their own
  (`migrate`, read off each client).
- **`who`'s numbers, by method**: 16 class files on this class path (spring-web 9 — the class and its four nested classes among them;
  spring-boot-restclient 6; `HttpMessageConverters` 1) and 3 in the two test jars; the brief's "spring-web; Boot's HttpMessageConverters" was
  the anchor's 61 alone, and Boot's restclient module adds six.
- **The exercise's shipped client is `RestClient.create()`, not `RestClient.create(stubUrl)`**: every call in the harness names its whole URL
  (as the template's calls do), so the fix is one token — `create()` → `create(template)` — and the fix is **one line of code in a copy**
  (`sed` on `.harness/mine/src/TemplateRoutes.java`), not an option: the move is a code change. "Not observed" is shown both ways in one
  scrape (1 of 2 calls as shipped, 2 of 2 solved).
- **The brief's sketch and this tree agree** on every other line of its unit block: 0 `Deprecated` attributes on `RestTemplate` (7.0.9);
  the `restTemplateBuilder` bean from `RestTemplateAutoConfiguration`; the same `HttpClientErrorException$NotFound`, the template's message
  naming `http://127.0.0.1:19566/week-9.json`; 5 converters, `JacksonJsonHttpMessageConverter` last; Boot's builder →
  `JdkClientHttpRequestFactory`, h2c; `new RestTemplate()` → `SimpleClientHttpRequestFactory`, `Java/<version>`, no `upgrade`, no
  `accept-encoding`; both followed `/redirect` (GET); `X-Via` on both migrated calls, both observed, still no `Accept`; TiffinBox's own code:
  0.

## Found on the way

- **Every check fails on a planted fault first** (R.65): the checks block runs alone (`cap()` dropped, the builds and the wipe skipped, each
  run in a session of its own) on the published captures with one thing changed per plant (`plants.py`, this unit's scratch folder), the
  file restored after each — **75 plants, 75 stops under /bin/bash 3.2 and 75 under bash 5.3**, each naming its own check; the
  unplanted files pass before and after under both, and the published md5s are unchanged.
- **Filters checked on planted inputs inside the script itself**, before any capture: the record filter and the level counts (a harness line
  that says "ERROR", one WARN and one ERROR record: 1 and 1 by line shape — a bare `' ERROR'` gives 2), the stub's dump filters (a header
  given twice, a body, a request with no answer, a late answer), the scrape filter, and the masks (two `Java-http-client/` versions, a
  `Java/` version, the token).
- **Found while building:** (1) `RestClient.create()`'s interceptor list is `null`, not empty: `Templates` prints `none` for it. (2) The
  template's request factory changes class when an interceptor is added (`InterceptingClientHttpRequestFactory`) — so `factories` reads it
  on templates with none, and `migrate` reads it on the template with one, each said. (3) `javap -v`'s output holds the jar's absolute path
  on its first line: `deps.py` prints counts and names only, never javap's lines. (4) `who.py`'s first form listed every jar (66 lines with
  the test jars): it now lists the jars with a match and TiffinBox's two, and counts the rest.
- **SIGINT**, measured: the script started as a terminal starts its foreground job (`python3` with `SIG_DFL` and `os.setpgrp()`, `env -i`,
  /bin/bash 3.2), SIGINT to its process group during `side`, while the stub and a TiffinBox JVM ran (5 processes in the group): **exit
  130**; 5 s later 0 processes in the group; 19560-19569, 8080, 18425 and 35729 free; no `.r-lock`, no unfinished capture run; the published
  captures unchanged (md5).
- **The exercise as viewers run it**, beyond the capture: README then SOLUTION in one `env -i` shell — the README's run and the solution's are
  two runs of the same last line in one shell; the edit lives in `.harness/mine/src` (the README's copy), so `harness/` is never changed, and
  a fresh `rm -rf .harness/mine` (the README's third line) puts the shipped `create()` back. Both JVMs are subshell jobs waited by pid; 19564
  and 19566 free after each.

## For RED

- This unit reads `../c6-unit24/after` only (no change), and copies the RestClient lesson's stub byte for byte (md5 asserted; no route
  added). Every factory sentence is "on this class path" (no httpclient5, asserted).
- **Re-check:** both bashes 3/3, the sealed clone (`central` 0 by repository id), SIGINT during a capture's JVM with the stub running;
  **the 0-`Deprecated` read** — `deps.py` on `RestTemplate` and its four nested classes (5 class files, 85 members on the class), against
  its non-zero reads (`RestTemplateBuilder.rootUri`, `HttpMessageConverters`, `TestRestTemplate$HttpClientOption.ENABLE_COOKIES`), and that
  no sources jar was read (none in the seed): "not deprecated in Framework seven point zero" rests on these class files alone;
  **the GET-only redirect scope** (`factories`: 9 requests, all GET; a non-GET never run); **`who`'s method** — the constant-pool string with
  a name-boundary, on the 64 jars of the harness's class path plus two test jars read from `.m2-demo` and labelled as not on it; the 59 jars
  counted, not listed; TiffinBox's 0 as class files and as sources (the same grep finds the harness's 2); the `Java/<version>` mask beside
  `Java-http-client/<version>` (raw values on the terminal only); every "sent / not sent" line against the stub's dump (`Accept` 2 of 4 in
  `side`, 1 of 4 in `migrate`; `X-Via` 3 of 4); the observed pair in one scrape (`/{f}` 3, `/{name}` absent); the exercise under Java 23
  (refused at compile), with `JAVA_HOME` unset (Homebrew's 26), and twice in one shell; that no harness class reached the anchor; Boot 3's
  client key nowhere (R.138).
