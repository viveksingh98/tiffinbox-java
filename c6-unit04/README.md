# c6-unit04 — Embedded Tomcat, Threads and Connectors

Course 6 · Spring Web MVC · Section 1 (The Servlet Layer), its fourth unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16,
Spring Boot 4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24), **GraalVM CE 25.3.4.1** (native-image 25.0.4.1), **Docker on
OrbStack**, 2026-10-12. TiffinBox's own server — the JDK's `HttpServer`, one virtual thread per answer since Core Java II — hands its
job to **embedded Tomcat**, under Spring MVC's `DispatcherServlet`. Who listens, and on which address; on whose threads; what stops
it; which of the seven answers change; and whether every form still serves — each measured, before and after.

**The anchor changes (brief ⚑2-⚑9).** `after/` is this unit's frozen copy of `../c6-tiffinbox` after the change, and
`diff -rq -x target ../c6-tiffinbox after/` is empty. "Before" is `../c5-unit27/after` — the anchor as Course 5 left it, which
`c6-tiffinbox`'s first commit copied (README aside). Both trees are read and copied under `.harness/`, never built in place. The
change: `tiffinbox-web/pom.xml` (+ `spring-boot-starter-webmvc`; − the Boot plugin's two Jackson 3 `<exclude>`s, − the native
plugin's two `<exclusion>`s), `TiffinBoxServer.java` (the server half out; the servlet API; named handlers; POST /shutdown closes the
context), `RouteMapping.java` (new: one `SimpleUrlHandlerMapping`), `ActuatorRoutes.java` and `PortTakenFailureAnalyzer.java`
(deleted), `META-INF/spring.factories` (the analyzer's key out), `application.yaml` (the alias in its first document, virtual threads
on), `BareArgumentAnalyzer.java` (one Javadoc line) and the anchor's `README.md` (the unit section and ten history notes). The
Dockerfile and `compose.yaml` are unchanged.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 10 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) **Docker must
answer** (`docker info`; on OrbStack `orb start` is tried once if it does not), with `eclipse-temurin:25-jre` already on it: the
script never pulls. It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first). One native
build per `forms` run (three per receipt), judged against a bound (under 20 minutes); its seconds go to the terminal only.

**Runs of record (2026-10-13, this script as committed — after RED part B's fixes):** **1,603 s under `./receipts.sh`** (/bin/bash
3.2.57, this folder, exit 0, all 10 = published, every check passed; the three native builds 282, 309 and 261 s) and **1,120 s under
`bash receipts.sh`** (Homebrew bash 5.3.9, the same; 185, 190 and 189 s); and **1,115 s from a sealed fresh clone under `./receipts.sh`** (/bin/bash 3.2.57): `git clone` of the local repository (HEAD
1ecd413) with `c6-unit04`, `c6-unit05` and `c6-tiffinbox` replaced by their working-tree files as they are committed (71 files, 0
differences) — nothing git ignores: no `.m2-demo`, no `.harness/`, no `.r-*` — run under `env -i`, with a `HOME` whose `.mavenrc`
points Maven's `user.home` there (Java reads `user.home` from the account, not from `$HOME`) and every Java proxy property at a port
that refuses (127.0.0.1:9), and whose Maven settings send every repository to a `file://` copy of Central's files made from
`.m2-demo` (4,364 files: TiffinBox's own installs, `_remote.repositories`, `*.lastUpdated`, `resolver-status.properties` and
`.DS_Store` left out, `maven-metadata-central.xml` served as `maven-metadata.xml`); `http_proxy`, `https_proxy`, their capitals and
`ALL_PROXY` at the same refusing port; `GRAALVM_HOME` set; `DOCKER_CONFIG=~/.docker` (see "Found on the way"); `PATH` the system's
and Homebrew's — the exercise's `env -i` shell got the same. Exit 0, all 10 = published, every check passed (native builds 202, 213
and 216 s). The first pre-capture build said `offline: no` (GraalVM's metadata repository was not in the empty `.m2-demo`) and took
**536 artifacts, every one from the `file://` copy, 0 from anywhere else** (`github` in the run's log: 0); the second said `offline:
yes`, and so did every capture's build; `.m2-demo` ended with 1,451 files. **Interrupt tests** (the receipt in its own process
group, SIGINT to the group): during the native build (479 s in, GraalVM's builder running — 5 processes in the group, 2 of them java):
**exit 130** 0.5 s later; 5 s later 0 processes in the group and 0 anywhere naming this folder; 19330-19339, 8080 and 18425 free; no
container, no image, no `.r-lock`, no unfinished capture run; the published captures unchanged. Load averages 10-100 during these runs (unit 05's receipts ran alongside, in its own process
group). Earlier runs, on revisions of this script: before RED part B — 901 s under bash 5.3 and a sealed fresh clone (961 s, HEAD
6206374; 536 artifacts from the `file://` copy only), 1,446 s and 861 s under /bin/bash 3.2, 1,283 s and 1,156 s under bash 5.3; after
it, BLUE's development runs, and one run stopped by SIGINT during `pool` (exit 130 in about a second; 5 s later 0 processes in its
group, every port free, no container, no image, no `.r-lock`, no unfinished capture run) when `bind` gained the image's layer count.

Published hashes: change `a520a10c1617e4601e6c5466a8798e01` · bind `0f6b837f1a885bf420511258b5205a72` · seven `d03f63370acd17f09bd2703d24896015` · seam `d9e791e58ab1850f677db6e4c14455f9` · pool `7445b2809ee20b9553efb8800da8bf9f` · threads `bb5a6a17b8bcc75b797b8ecb00099056` · stop `76a54614d0a8cf3e74d924d7c379197d` · taken `5fc14d56624b91148a008e94bf9c7bd5` · exercise `cb9eb4276f128f6b17329336da7f4ff2` · forms `69c29202be33c5e9067deea238424ddd`.

## The commands this unit adds

`after/README.md` — the anchor's own — gives every line `receipts.sh` runs or derives from but five, which are this unit's, each
read from the block below and asserted to be exactly this (on the anchor's port 18431; each capture swaps in its own port):

```bash
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --logging.level.org.apache.coyote.http11.Http11NioProtocol=info
java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431 --server.shutdown=immediate
curl -s -D - -o /dev/null http://127.0.0.1:18431/customers
curl -s -m 30 -o /dev/null -w '%{http_code}\n' 'http://127.0.0.1:18431/probe/slow?ms=3000'
curl -s http://127.0.0.1:18431/probe/inflight
```

The first switches Tomcat's own connector logger to INFO (`bind` F: its lines name the address; Boot's logging defaults hold
that logger at WARN). The second makes Boot's shutdown immediate (`stop` B). The third prints one answer's status line and
headers (`seven`: what the seven leave out). The last two are the harness's (`harness/probe/web/Threads.java`, joined on the
class-path line): a slow request of three seconds, and how many slow requests are in flight (`stop`).

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else, refuses one whose `native-image --version` is not
`native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1`, and never prints its folder (`$GRAALVM_HOME` in every capture). Only `forms`
needs it. **Without a GraalVM** the script still fills `.m2-demo`, makes the nine other captures, each checked against
`receipts.md5`, then stops where the native build would start (exit 1).

## The repository, Docker, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded from
`../../spring-web-mvc/_research/m2-seed-s1/` (5,827 files, 353 MB; it holds no `com/tiffinbox`, brief ⚑17). **Nothing was
downloaded** for this unit: every build said `offline: yes`, the native plugin read its metadata repository from `.m2-demo`
(`file:`), and every native build log holds 0 lines of the plugin's own download (`Downloaded GraalVM reachability metadata repository
from http`, `Failed to download from http`). A fresh clone's `.m2-demo` is empty (git ignores it): the first build — `after/`'s
`mvn -B -Pnative install`, before any capture — fills it from Maven Central and says `offline: no`; every capture's build then says
`offline: yes`. The install writes `com/tiffinbox` into this unit's `.m2-demo` — fine here, and never copied into a seed. **Docker:**
no pull — `docker build` prints its `load metadata` line and the base image's digest, and `its lines that say pull: 0`. The image
(`tiffinbox-tomcat:1.0.0`) and the container (`tiffinbox-tomcat`) are this script's own names, checked absent first and removed on
every exit; the build cache is not pruned (`.dockerignore` keeps `secrets/` out of every build context, so it holds no token).

## The demo token — fake, and never printed

The demo token — `TOKEN=` at the top of `receipts.sh`, 26 characters, fake and meant to look it — guards nothing but a demo server on 127.0.0.1 that every capture stops. It is
written into `.harness/*/secrets/tiffinbox/shutdown-token` (a config tree, mode 0600, git-ignored) when the script runs, mounted
read-only into the container (`:ro`), and sent only by `../c5-unit11/curlset.sh` and `harness/shutdown.sh` on curl's standard input.
Every capture's raw output is searched for it before masking (0 in all of them), and so are the log of every JVM that served, every
start that ended by itself, the container's log (`docker logs`), every file this unit ships, the binary's bytes, and every blob of
the image (`docker save`, each gzip layer unpacked: 15 blobs, 11 layers; `bind`): 0 everywhere.
The exercise makes a token of its own (26 random characters), counted 0 times in its own log and never printed.

## The folders, the names and the ports

- `after/` — the anchor after this change (= `../c6-tiffinbox`). `.harness/before`, `.harness/after` — the two trees, copied, each
  with a config tree; `.harness/noalias` — `after/` with the alias's three lines taken out of `application.yaml` (B); `.harness/aot` —
  `after/` built with the profile native (`threads` C); `.harness/nat` — `after/`'s native build (`forms`); `.harness/hc` — the
  harness's classes, compiled against `after/`'s own jar; `.harness/mine` — the exercise's copy.
- **The harness** — the course's, never TiffinBox's: `harness/probe/web/Threads.java` (package `probe.web`, outside `com.tiffinbox`;
  joined by `--spring.main.sources=probe.web.Threads` on the README's class-path line — the extracted jar plus `../hc`): `/probe/slow`
  (half a second, or `?ms=`, then the answering thread's name and whether it is virtual), `/probe/inflight` (how many slow answers
  are on their way), `/probe/threads` (every live platform thread, daemon or not, and its class), `/probe/executor` (Boot's
  `applicationTaskExecutor`: its class, and the thread a task ran on); and
  `harness/probe/web/Converters.java` (`--spring.main.sources=probe.web.Converters`, `seven`'s DEBUG run): `/probe/converters`, the
  message converters Spring MVC's `RequestMappingHandlerAdapter` holds, and each JSON one's class and mapper. `harness/slow8.sh` sends
  eight `/probe/slow` at once; `harness/shutdown.sh` POSTs /shutdown with the token read from its file.
- **Ports** (brief ⚑1, 19330-19339): after/'s jar 19330 (`bind` F and `stop` too) · the previous tree 19331 (and E's
  `--tiffinbox.port`, never bound) · E's `--server.port` and the idle pools 19332 · threads 19333 · the AOT jar 19334 · B's
  `--tiffinbox.port` 19335 (nothing reads it there) and 19336 (Tomcat, every interface: B only; `taken` C and D, never bound) · the
  image 19337 · the binary 19338 · the exercise 19339. 18425 (TiffinBox's default) and 8080 (Tomcat's) are checked free and never bound on this Mac (18425 only inside the
  container); a run that listens on 8080 is killed and the script dies.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM, the token, the user** (`gsub()`, literals escaped), in every line: the token → `[masked: the 26-character
   token]` (its length read off the token); the GraalVM's folder → `$GRAALVM_HOME`; this folder → `…`; the folder above → `…/..`;
   home → `~`; the user name → `<user>`. A last check fails if any capture holds `/Users/`, `/private/`, `/home/`, `/var/folders/`,
   the GraalVM's folder, a unit number, Boot's process line, a log time, an unmasked timestamp, a thread number, a stack frame, a
   `sha256:` ID other than the base image's digest, or `:8080`.
2. **Spring's error timestamp** (`tsmask`, `gsub`): `"timestamp":"<anything>"` → `"timestamp":"…"` and `"timestamp":<digits>` →
   `"timestamp":…` — an ISO-8601 string (Jackson 3, here) and epoch milliseconds (Jackson 2's converter). The seven are hashed after
   it; each `seven` line says how many lines it changed (0 on TiffinBox's own server, 1 on Tomcat). Checked first on four planted
   lines: 4 distinct before it, 2 after (`seven`).
3. **A thread's number** (`tnum`, `gsub`): `-exec-<n>` → `-exec-N`, `tomcat-handler-<n>` → `tomcat-handler-N`, `task-<n>` → `task-N`,
   `Catalina-utility-<n>` → `Catalina-utility-N`. Distinct threads are counted **before** the mask. The port in Tomcat's pool names
   (`http-nio-127.0.0.1-19333-exec-N`) is this unit's own and stays.
4. **DEBUG lines** (`seven`, Boot's `web` group): from their logger on; an identity hash after `@` → `@…`; the date in the error
   map's `timestamp=` → `timestamp=…`. The lines of `GET /nowhere` alone are shown, every one of them, between two points where the
   log stopped growing; the DEBUG lines before them — the start, the readiness polls, `/probe/converters` — are bounded ("more than
   20": the polls move their number). The binary's DEBUG run (`forms`) shows its two lines for `GET /customers`; its other lines are
   bounded ("more than 40") — the readiness polls move them too.
5. **A start that ended by itself** (`fails()`) is read after it exited, never printed whole: `APPLICATION FAILED TO START`, frames,
   `Caused by:` and folded frames counted, and Boot's two Tomcat lines (`Tomcat initialized`, `Tomcat started`, logged by Boot's
   `TomcatWebServer`) counted; WARN/ERROR lines from their level on, a WARN cut after
   its exception's class; each exception's first line; Boot's hint; the analysis from `Description:` on; the banner counted.
   **Never a line total** (R.45, R.77).
6. **A running TiffinBox's log**: Boot's first line cut before ` with PID`; TiffinBox's own line from its message on; Boot's started
   line, and Tomcat's own connector lines (`bind` F), from their logger on (`logger: message`).
7. **The native build's lines**: its plugin goals, the GraalVM line, the Java version, each `Warning:` — the file a warning names
   (`in 'file:…'`, or `in 'null'`, which native-image prints when the path holds a space) → `in '…'` — the eight stages cut after
   their name, the warnings count and `BUILD SUCCESS`; the rest counted, never shown.
8. **`docker build --progress=plain`** through a filter: its `load metadata` line, its `FROM` line (the base image's digest), its
   naming line, step numbers and timings cut (` done` and ` 0.0s done`; checked on a planted log first); lines that say pull, counted;
   the rest bounded ("fewer than 300": 55 with every step cached, more on a first build).
9. **The idle threads** (`pool`): the server's platform threads only (`http-nio-`, `container-`, `Catalina-`), each with its class,
   identical lines counted; whose: a class of Boot's (`org.springframework.boot`, `container-0`'s `TomcatWebServer$1`) or the rest,
   Tomcat's (`org.apache.tomcat`, or a plain `Thread` its connector names `http-nio-…`); the JVM's other platform threads — the
   virtual-thread scheduler's carriers among them, whose number moves — bounded ("fewer than 40"), never counted.
10. **The scrape** (`seam`): its `_count` lines for TiffinBox's paths — Boot's `http_server_requests` and `tiffinbox_requests` —
   read until two reads half a second apart agree; Actuator's own series left out and bounded ("fewer than 10": the readiness polls
   and the reads move their counts); then what each timer counted, summed from those lines.
11. **Inside the container**: `/proc/net/tcp` and `tcp6`, LISTEN rows only, the address decoded (`[::]`, `0.0.0.0`, `127.0.0.1`).
    **On this Mac**: `lsof` by pid (or by port, for Docker's forwarder), the address column alone — never a command name (R.18).

## Interrupted

Ctrl-C (SIGINT to the foreground process group) stops it with **exit 130**: the trap stops the JVM it started (`$pid`, `$fpid`, a
slow request's curl `$spid`, and the exercise's shell `$xpid` with every process under it — `killtree`, by parent pid), sweeps its process group for any TiffinBox JVM, binary or `native-image` left, removes the container and the
image, deletes the capture runs it had not finished (`.r-NAME.1-3`), and removes `.r-lock`. The published captures are untouched.
**Measured** on this script (2026-10-13): SIGINT to the group during the native build — exit 130 in 0.5 s, and 5 s later nothing of
the run left (above); and once during `pool`, a JVM listening — exit 130, nothing left.

## 1 · change — the previous tree against after/

Both trees built with the README's line (offline); `diff -rq`; the three files that did the server's jobs, by their lines; the new handler mapping's code; the POM and the factories file, their non-comment lines that differ, and the YAML's with a line around each (`diff -U1`: `spring:` sits above the three lines that switch virtual threads on — `spring.threads.virtual.enabled`, never `server.…`); the files that did not change; the jar's `BOOT-INF/lib` before and after — 46 → 58, removed 0, added 12, Jackson 3 among them. The jar extracted (the README's line) for the harness.

`.r-change.out` · md5 `a520a10c1617e4601e6c5466a8798e01` · 3 of 3

```
the previous tree and after/, both copied under .harness/ with a config tree, each built with the README's line (offline):
$ cd .harness/before && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the previous tree · offline: yes · exit 0
$ cd .harness/after && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built after/ · offline: yes · exit 0
after/'s jar, extracted (the README's line) - the class path the harness joins, in pool and threads:
$ cd .harness/after && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0
the files that differ:
$ diff -rq -x target -x secrets .harness/before .harness/after
  Files .harness/before/README.md and .harness/after/README.md differ
  Files .harness/before/tiffinbox-web/pom.xml and .harness/after/tiffinbox-web/pom.xml differ
  Only in .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web: ActuatorRoutes.java
  Files .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/BareArgumentAnalyzer.java and .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web/BareArgumentAnalyzer.java differ
  Only in .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web: PortTakenFailureAnalyzer.java
  Only in .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web: RouteMapping.java
  Files .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java and .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java differ
  Files .harness/before/tiffinbox-web/src/main/resources/META-INF/spring.factories and .harness/after/tiffinbox-web/src/main/resources/META-INF/spring.factories differ
  Files .harness/before/tiffinbox-web/src/main/resources/application.yaml and .harness/after/tiffinbox-web/src/main/resources/application.yaml differ
the three files that did the server's jobs, their lines (wc -l), before -> after:
  TiffinBoxServer.java: 277 -> 285
  ActuatorRoutes.java: 196 -> deleted
  PortTakenFailureAnalyzer.java: 51 -> deleted
  TiffinBoxServer.java, its lines that are neither comment nor blank: 194 -> 188 · naming the JDK's server (HttpServer, HttpExchange, HttpHandler, com.sun.net.httpserver): 10 -> 0 · the servlet API's (HttpServletRequest, HttpServletResponse): 0 -> 6
  RouteMapping.java - new; its lines that are neither comment nor blank: 11
    package com.tiffinbox.web;
    import org.springframework.context.annotation.Bean;
    import org.springframework.context.annotation.Configuration;
    import org.springframework.web.servlet.handler.SimpleUrlHandlerMapping;
    @Configuration(proxyBeanMethods = false)
    class RouteMapping {
        @Bean
        SimpleUrlHandlerMapping tiffinBoxRoutes(TiffinBoxServer server) {
            return new SimpleUrlHandlerMapping(server.handlers(), 0);
        }
    }
  tiffinbox-web/pom.xml - its lines that are neither comment nor blank, the ones that differ:
    >     <dependency>
    >       <groupId>org.springframework.boot</groupId>
    >       <artifactId>spring-boot-starter-webmvc</artifactId>
    >     </dependency>
    <             <exclude>
    <               <groupId>tools.jackson.core</groupId>
    <               <artifactId>jackson-databind</artifactId>
    <             </exclude>
    <             <exclude>
    <               <groupId>tools.jackson.core</groupId>
    <               <artifactId>jackson-core</artifactId>
    <             </exclude>
    <             <exclusion>
    <               <groupId>tools.jackson.core</groupId>
    <               <artifactId>jackson-databind</artifactId>
    <             </exclusion>
    <             <exclusion>
    <               <groupId>tools.jackson.core</groupId>
    <               <artifactId>jackson-core</artifactId>
    <             </exclusion>
  tiffinbox-web/pom.xml - <dependency> 7 -> 8 · Boot's plugin's <exclude> 3 -> 1 · the native plugin's <exclusion> 3 -> 1
  tiffinbox-web/src/main/resources/application.yaml - its lines that are neither comment nor blank, the ones that differ, each with a line around it (diff -U1, its file names cut):
    @@ -10,3 +10,9 @@
         - VEGAN
    +server:
    +  address: ${tiffinbox.address}
    +  port: ${tiffinbox.port}
     spring:
    +  threads:
    +    virtual:
    +      enabled: true
       profiles:
  tiffinbox-web/src/main/resources/META-INF/spring.factories - its lines that are neither comment nor blank, before then after:
    before org.springframework.context.ApplicationListener=com.tiffinbox.web.BareArgumentGuard
    before org.springframework.boot.diagnostics.FailureAnalyzer=com.tiffinbox.web.PortTakenFailureAnalyzer,com.tiffinbox.web.BareArgumentAnalyzer
    after  org.springframework.context.ApplicationListener=com.tiffinbox.web.BareArgumentGuard
    after  org.springframework.boot.diagnostics.FailureAnalyzer=com.tiffinbox.web.BareArgumentAnalyzer
  BareArgumentAnalyzer.java - its Javadoc lines that differ: 1 · its lines that are neither comment nor blank, against the previous tree's: the same
  README.md - the anchor's README: lines added 160, removed 6 - its new section and the history notes the change made false (not shown)
  tiffinbox-core against the previous tree's (diff -rq -x target): 0 files differ
  Route.java against the previous tree's, byte for byte: the same
  TiffinBoxApp.java against the previous tree's, byte for byte: the same
  BareArgumentGuard.java against the previous tree's, byte for byte: the same
  KitchenHealthIndicator.java against the previous tree's, byte for byte: the same
  KitchenMetrics.java against the previous tree's, byte for byte: the same
  pom.xml against the previous tree's, byte for byte: the same
  Dockerfile against the previous tree's, byte for byte: the same
  compose.yaml against the previous tree's, byte for byte: the same
  .dockerignore against the previous tree's, byte for byte: the same
the executable jar's BOOT-INF/lib: 46 jars -> 58 · removed 0 · added 12:
    jackson-core-3.1.5.jar
    jackson-databind-3.1.5.jar
    spring-boot-http-converter-4.1.1.jar
    spring-boot-jackson-4.1.1.jar
    spring-boot-servlet-4.1.1.jar
    spring-boot-tomcat-4.1.1.jar
    spring-boot-web-server-4.1.1.jar
    spring-boot-webmvc-4.1.1.jar
    spring-web-7.0.9.jar
    spring-webmvc-7.0.9.jar
    tomcat-embed-core-11.0.24.jar
    tomcat-embed-websocket-11.0.24.jar
  Jackson 3 (tools.jackson) in the jar: before 0 -> after 2 · Jackson 2 (jackson-databind 2.x): before 1 -> after 1
```

## 2 · bind — the address the log hides (D: A/B/A′), E, F, the container

Boot's own metadata (`server.address` no default, `server.port` 8080); where the alias sits — and the check failing on a planted copy (S1.19); **A** after/: `127.0.0.1:19330` read off the process; Boot's started line — its logger `o.s.boot.tomcat.TomcatWebServer`, Boot's class — names the port, not the address, and Tomcat's own connector lines at Boot's default levels: 0; **B (labelled)** after/ with the alias's three lines taken out (`diff -U0`), the README's two-name line: `*:19336` — every interface — stopped by its pid as soon as Tomcat listened (exit 143; both ports free; the listen-address check says `no`); **A′** = A; **E (labelled)** both names: Boot's `--server.port` wins (19332; 19331 never bound); **F (labelled)** Tomcat's own connector logger at INFO (this README's line): `Initializing ProtocolHandler ["http-nio-127.0.0.1-19330"]` and `Starting …` — the connector names the address — and Boot's `defaults.xml` holds that logger at `WARN`; the container: the image from `after/`'s Dockerfile — saved (`docker save`) and every blob searched, each gzip layer unpacked: 0 tokens — inside `[::]:18425`, `docker port` and this Mac's listener `127.0.0.1:19337` (on OrbStack), `docker wait` 0.

`.r-bind.out` · md5 `0f6b837f1a885bf420511258b5205a72` · 3 of 3

```
Boot's own metadata, in after/'s jar: server.address no default (spring-boot-web-server-4.1.1.jar) · server.port default 8080 (spring-boot-web-server-4.1.1.jar)
where the alias sits - after/'s application.yaml, then a planted copy with the same three lines moved below the "---" (the check must fail there):
  after/: server: line 19 · address: ${tiffinbox.address} line 20 · port: ${tiffinbox.port} line 21 · the first "---" line 77 · in the first document: yes
  the planted copy: server: line 82 · address: ${tiffinbox.address} line 83 · port: ${tiffinbox.port} line 84 · the first "---" line 74 · in the first document: no
A - after/, the README's run line, port 19330:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19330
  listens on: 127.0.0.1:19330 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19330/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19330 (http) with context path '/'
  Tomcat's own connector lines in this log, at Boot's default levels: 0
$ harness/shutdown.sh 19330 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19330 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B (labelled) - after/ without the alias: its three lines taken out of application.yaml, then built; the README's two-name line - nothing reads --tiffinbox.port there now, so Tomcat's port is Boot's own name, 19336 - stopped as soon as Tomcat listens:
$ diff -U0 after/tiffinbox-web/src/main/resources/application.yaml .harness/noalias/tiffinbox-web/src/main/resources/application.yaml
  @@ -19,3 +18,0 @@
  -server:
  -  address: ${tiffinbox.address}
  -  port: ${tiffinbox.port}
$ cd .harness/noalias && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built after/ without the alias · offline: yes · exit 0
$ cd .harness/noalias && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19335 --server.port=19336
  listens on: *:19336 · loopback only: no
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19336 (http) with context path '/'
  stopped by its pid at once (SIGTERM): exit 143
  listening now: 19335 0 · 19336 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19330
  listens on: 127.0.0.1:19330 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19330/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19330 (http) with context path '/'
  Tomcat's own connector lines in this log, at Boot's default levels: 0
$ harness/shutdown.sh 19330 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19330 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
E (labelled) - after/, both names given: the README's two-name line, ports 19331 (--tiffinbox.port) and 19332 (--server.port):
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19331 --server.port=19332
  listens on: 127.0.0.1:19332 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19332/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19332 (http) with context path '/'
  listening now: 19331 0 · 19332 1
$ harness/shutdown.sh 19332 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19332 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
F (labelled) - after/, Tomcat's own connector logger at INFO (README.md: the run line, one logging option added), port 19330:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19330 --logging.level.org.apache.coyote.http11.Http11NioProtocol=info
  listens on: 127.0.0.1:19330 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19330/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19330 (http) with context path '/'
  Tomcat's own connector lines - logger: message:
    o.a.coyote.http11.Http11NioProtocol: Initializing ProtocolHandler ["http-nio-127.0.0.1-19330"]
    o.a.coyote.http11.Http11NioProtocol: Starting ProtocolHandler ["http-nio-127.0.0.1-19330"]
  Boot's logging defaults for that logger (spring-boot-4.1.1.jar, org/springframework/boot/logging/logback/defaults.xml): <logger name="org.apache.coyote.http11.Http11NioProtocol" level="WARN"/>
$ harness/shutdown.sh 19330 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19330 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the container - after/'s Dockerfile (the README's two lines, Maven's above, then Docker), the README's run line with your user, published on 127.0.0.1:19337:
$ cd .harness/after && docker build --progress=plain -t tiffinbox-tomcat:1.0.0 .
  exit 0 · its lines, through the filter:
    [internal] load metadata for docker.io/library/eclipse-temurin:25-jre
    [builder 1/4] FROM docker.io/library/eclipse-temurin:25-jre@sha256:fcd7fd7b387f94bb2ac461478a7436ad8e349924c374ea8313919624dceae636
    naming to docker.io/library/tiffinbox-tomcat:1.0.0
  its lines that say pull: 0 · its other lines: fewer than 300, not shown
  the image: user ubuntu · entrypoint ["java","-jar","application.jar"] · its environment's TIFFINBOX_ADDRESS: 0.0.0.0
  the image saved (docker save): 15 blobs, its 11 layers among them, each read whole (gzip ones unpacked) · the demo token in them: 0
$ cd .harness/after && docker run -d --name tiffinbox-tomcat --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19337:18425 tiffinbox-tomcat:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19337/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19337
  on this Mac, listening on port 19337: 127.0.0.1:19337
$ harness/shutdown.sh 19337 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
$ docker wait tiffinbox-tomcat
  0
  its log (docker logs): Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 18425 (http) with context path '/' · the demo token 0 times · X-Shutdown-Token 0 times
  listening now: 19337 0
```

## 3 · seven — the comparison set, before and after (C6-11)

The seven on the previous tree (TiffinBox's own server: `115c36ba…`, the mask changes 0 lines) and on after/ (Tomcat: the mask changes 1 line, `571faaea…`); before each, one answer's status line and header names (this README's line), which the seven do not print: `[HTTP/1.1 200 OK]`, `Date Content-type Content-length` → `[HTTP/1.1 200 ]`, `Content-Type Content-Length Date` — so "six lines match" means status, type and body; the mask on planted lines; the diff — one line, `5c5`, `GET /nowhere`; why, at Boot's `web` log group's DEBUG (on the class-path layout, the harness's `Converters` joined): TiffinBox's handler mapping at start (`Patterns [/customers, /dashboard, /kitchen, /revenue, /shutdown]`); Spring MVC's one JSON converter, `JacksonJsonHttpMessageConverter`, its mapper Jackson 3's `tools.jackson.databind.json.JsonMapper`; then every line of `GET /nowhere` (10; the ones before it bounded) — Spring MVC's static-resource handler, which Boot maps to `/**`, `NoResourceFoundException`, the ERROR dispatch to Boot's `BasicErrorController`, JSON.

`.r-seven.out` · md5 `d03f63370acd17f09bd2703d24896015` · 3 of 3

```
before - the previous tree, TiffinBox's own server: the README's run line, port 19331:
$ cd .harness/before && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19331
  listens on: 127.0.0.1:19331 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19331/actuator/health/readiness
  {"status":"UP"} 200
  its own line: TiffinBox listening on http://127.0.0.1:19331
$ curl -s -D - -o /dev/null http://127.0.0.1:19331/customers
  its status line: [HTTP/1.1 200 OK] · its headers, by name: Date Content-type Content-length
$ $CURLSET 19331 .harness/before/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 0 · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
after - after/, Tomcat: the README's run line, port 19330:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19330
  listens on: 127.0.0.1:19330 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19330/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19330 (http) with context path '/'
$ curl -s -D - -o /dev/null http://127.0.0.1:19330/customers
  its status line: [HTTP/1.1 200 ] · its headers, by name: Content-Type Content-Length Date
$ $CURLSET 19330 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 1 · md5 571faaea42e87e85add8c9548c64c961
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the seven, the timestamp masked:
    GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
    GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
    GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
    GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
    GET   /nowhere    -> 404 application/json  {"timestamp":"…","status":404,"error":"Not Found","path":"/nowhere"}
    GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
    POST  /shutdown   -> 200 application/json  {"stopping":true}
the mask, checked first on four planted lines - two timestamps as ISO-8601 strings, two as epoch milliseconds:
  distinct lines before it: 4 · after it: 2 · {"timestamp":"…","status":404} {"timestamp":…,"status":404}
before against after, the lines that differ (diff):
  5c5
  < GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  ---
  > GET   /nowhere    -> 404 application/json  {"timestamp":"…","status":404,"error":"Not Found","path":"/nowhere"}
why - after/ on the README's class-path line with the harness's Converters joined, Boot's web log group at DEBUG (the README's option), port 19330: the DispatcherServlet starts at the first request (a readiness poll); Spring MVC's JSON converters; then GET /nowhere, alone:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19330 --spring.main.sources=probe.web.Converters --logging.level.web=debug
  listens on: 127.0.0.1:19330 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19330/actuator/health/readiness
  {"status":"UP"} 200
  at start, TiffinBox's handler mapping: Patterns [/customers, /dashboard, /kitchen, /revenue, /shutdown] in 'tiffinBoxRoutes'
$ curl -s http://127.0.0.1:19330/probe/converters
  converters: 6 · for application/json: 1
  org.springframework.http.converter.json.JacksonJsonHttpMessageConverter · its mapper: tools.jackson.databind.json.JsonMapper
  the DEBUG lines before it - the start, the readiness polls (their number moves), /probe/converters: more than 20, not shown
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19330/nowhere
  404 application/json
  its lines at DEBUG - all 10 of them:
    o.s.web.servlet.DispatcherServlet: GET "/nowhere", parameters={}
    o.s.w.s.handler.SimpleUrlHandlerMapping: Mapped to ResourceHttpRequestHandler [classpath [META-INF/resources/], classpath [resources/], classpath [static/], classpath [public/], ServletContext [/]]
    o.s.w.s.r.ResourceHttpRequestHandler: Resource not found for path [nowhere]
    .w.s.m.s.DefaultHandlerExceptionResolver: Resolved [org.springframework.web.servlet.resource.NoResourceFoundException: No static resource nowhere for request '/nowhere'.]
    o.s.web.servlet.DispatcherServlet: Completed 404 NOT_FOUND
    o.s.web.servlet.DispatcherServlet: "ERROR" dispatch for GET "/error", parameters={}
    s.w.s.m.m.a.RequestMappingHandlerMapping: Mapped to org.springframework.boot.webmvc.autoconfigure.error.BasicErrorController#error(HttpServletRequest)
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Using 'application/json', given [*/*] and supported [application/json, application/*+json]
    o.s.w.s.m.m.a.HttpEntityMethodProcessor: Writing [{timestamp=…, status=404, error=Not Found, path=/nowhere}]
    o.s.web.servlet.DispatcherServlet: Exiting from "ERROR" dispatch, status 404
$ harness/shutdown.sh 19330 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19330 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 4 · seam — Course 5's other checks, before and after; two timers

`/customersXYZ`, `/customers/`, `/kitchen/anything`: 200 → 404; `/actuator`: 404 → 200 (Boot's links); `/actuator/health` and the scrape: the same content types from the bridge and from Boot's adapter; HEAD 405, `Accept: application/xml` 200 JSON and DELETE 405 on both; the scrape's count lines: Boot's `http_server_requests` (every 404 here `uri="/**"`) beside `tiffinbox_requests`, and what each counted — 6 requests sent to TiffinBox's paths, Boot's timer 6, TiffinBox's 3 (its handler's own answers), the three 404s on Boot's alone.

`.r-seam.out` · md5 `d9e791e58ab1850f677db6e4c14455f9` · 3 of 3

```
before - the previous tree, TiffinBox's own server: the README's run line, port 19331:
$ cd .harness/before && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19331
  listens on: 127.0.0.1:19331 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19331/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19331/customersXYZ
  200 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19331/customers/
  200 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19331/kitchen/anything
  200 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19331/actuator
  404 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19331/actuator/health
  200 application/vnd.spring-boot.actuator.v3+json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19331/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' -I http://127.0.0.1:19331/customers
  405 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' -H 'Accept: application/xml' http://127.0.0.1:19331/customers
  200 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' -X DELETE http://127.0.0.1:19331/customers
  405 application/json
$ harness/shutdown.sh 19331 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19331 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
after - after/, Tomcat: the README's run line, port 19330:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19330
  listens on: 127.0.0.1:19330 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19330/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19330 (http) with context path '/'
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19330/customersXYZ
  404 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19330/customers/
  404 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19330/kitchen/anything
  404 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19330/actuator
  200 application/vnd.spring-boot.actuator.v3+json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19330/actuator/health
  200 application/vnd.spring-boot.actuator.v3+json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19330/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' -I http://127.0.0.1:19330/customers
  405 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' -H 'Accept: application/xml' http://127.0.0.1:19330/customers
  200 application/json
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' -X DELETE http://127.0.0.1:19330/customers
  405 application/json
the two timers now - the scrape's count lines for TiffinBox's paths:
  http_server_requests_seconds_count{error="none",exception="none",method="DELETE",outcome="CLIENT_ERROR",status="405",uri="/customers"} 1
  http_server_requests_seconds_count{error="none",exception="none",method="GET",outcome="CLIENT_ERROR",status="404",uri="/**"} 3
  http_server_requests_seconds_count{error="none",exception="none",method="GET",outcome="SUCCESS",status="200",uri="/customers"} 1
  http_server_requests_seconds_count{error="none",exception="none",method="HEAD",outcome="CLIENT_ERROR",status="405",uri="/customers"} 1
  tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 1
  tiffinbox_requests_seconds_count{route="UNKNOWN",status="405"} 2
  Actuator's own series, left out: fewer than 10 (the readiness polls and these reads move their counts)
  requests sent to TiffinBox's paths: 6 · counted by Boot's timer: 6 · by TiffinBox's: 3 · the 404s on Boot's: 3 · on TiffinBox's: 0
$ harness/shutdown.sh 19330 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19330 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 5 · pool — the server's platform threads, idle (A/B/A′)

Boot's metadata (`server.tomcat.threads.max` 200, `min-spare` 10, `spring.threads.virtual.enabled` false); **A** after/ as built (virtual threads on): 5 platform threads, each with its class — Tomcat's Acceptor and Poller (daemons, plain `Thread`s its connector names) and 2 `Catalina-utility` (`TaskThread`, not daemons), and `container-0`, whose class is Boot's (`org.springframework.boot.tomcat.TomcatWebServer$1`: Boot starts it, not a daemon); no exec thread; **B** `--spring.threads.virtual.enabled=false`: + 10 `exec` threads (daemons); **A′** = A.

`.r-pool.out` · md5 `7445b2809ee20b9553efb8800da8bf9f` · 3 of 3

```
Boot's own metadata, in after/'s jar: server.tomcat.threads.max default 200 (spring-boot-tomcat-4.1.1.jar) · server.tomcat.threads.min-spare default 10 (spring-boot-tomcat-4.1.1.jar) · spring.threads.virtual.enabled default false (spring-boot-autoconfigure-4.1.1.jar)
A - after/ as built (virtual threads on, application.yaml): the README's class-path line (the jar extracted, change) with the harness joined, port 19332:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19332 --spring.main.sources=probe.web.Threads
  listens on: 127.0.0.1:19332 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19332/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19332/probe/threads
  2 × Catalina-utility-N non-daemon · org.apache.tomcat.util.threads.TaskThread
  1 × container-0 non-daemon · org.springframework.boot.tomcat.TomcatWebServer$1
  1 × http-nio-127.0.0.1-19332-Acceptor daemon · java.lang.Thread
  1 × http-nio-127.0.0.1-19332-Poller daemon · java.lang.Thread
  the server's platform threads: 5 · of a class of Boot's (org.springframework.boot): 1 · Tomcat's, the rest: 4 · not daemons among them: 3 · the JVM's other platform threads: fewer than 40, not shown
$ harness/shutdown.sh 19332 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19332 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the same with virtual threads off (the README's option):
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19332 --spring.main.sources=probe.web.Threads --spring.threads.virtual.enabled=false
  listens on: 127.0.0.1:19332 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19332/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19332/probe/threads
  2 × Catalina-utility-N non-daemon · org.apache.tomcat.util.threads.TaskThread
  1 × container-0 non-daemon · org.springframework.boot.tomcat.TomcatWebServer$1
  1 × http-nio-127.0.0.1-19332-Acceptor daemon · java.lang.Thread
  1 × http-nio-127.0.0.1-19332-Poller daemon · java.lang.Thread
  10 × http-nio-127.0.0.1-19332-exec-N daemon · org.apache.tomcat.util.threads.TaskThread
  the server's platform threads: 15 · of a class of Boot's (org.springframework.boot): 1 · Tomcat's, the rest: 14 · not daemons among them: 3 · the JVM's other platform threads: fewer than 40, not shown
$ harness/shutdown.sh 19332 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19332 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19332 --spring.main.sources=probe.web.Threads
  listens on: 127.0.0.1:19332 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19332/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19332/probe/threads
  2 × Catalina-utility-N non-daemon · org.apache.tomcat.util.threads.TaskThread
  1 × container-0 non-daemon · org.springframework.boot.tomcat.TomcatWebServer$1
  1 × http-nio-127.0.0.1-19332-Acceptor daemon · java.lang.Thread
  1 × http-nio-127.0.0.1-19332-Poller daemon · java.lang.Thread
  the server's platform threads: 5 · of a class of Boot's (org.springframework.boot): 1 · Tomcat's, the rest: 4 · not daemons among them: 3 · the JVM's other platform threads: fewer than 40, not shown
$ harness/shutdown.sh 19332 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19332 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 6 · threads — whose thread answers (A/B/A′, C) — C6-14, X3

**A** after/ as built: eight slow requests at once → 8 answers on 8 distinct `tomcat-handler-N` virtual threads; Boot's executor a `SimpleAsyncTaskExecutor`, its task on a virtual thread; **B** the README's two options, virtual threads off and two pool threads: 8 answers on 2 `http-nio-127.0.0.1-19333-exec-N` platform threads; `ThreadPoolTaskExecutor`; **A′** = A; **C (labelled)** the AOT jar with `--spring.threads.virtual.enabled=false` at run time: `tomcat-handler-N` — the build decided (S1.9).

`.r-threads.out` · md5 `bb5a6a17b8bcc75b797b8ecb00099056` · 3 of 3

```
A - after/ as built (virtual threads on, application.yaml): the README's class-path line (the jar extracted, change) with the harness joined, port 19333:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19333 --spring.main.sources=probe.web.Threads
  listens on: 127.0.0.1:19333 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19333/actuator/health/readiness
  {"status":"UP"} 200
$ harness/slow8.sh 19333
  8 × tomcat-handler-N virtual=true
  answers: 8 · distinct threads (their numbers, counted before the mask): 8
$ curl -s http://127.0.0.1:19333/probe/executor
  SimpleAsyncTaskExecutor task-N virtual=true
$ harness/shutdown.sh 19333 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19333 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the README's pool line's two options: virtual threads off, two pool threads at most:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19333 --spring.main.sources=probe.web.Threads --spring.threads.virtual.enabled=false --server.tomcat.threads.max=2
  listens on: 127.0.0.1:19333 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19333/actuator/health/readiness
  {"status":"UP"} 200
$ harness/slow8.sh 19333
  8 × http-nio-127.0.0.1-19333-exec-N virtual=false
  answers: 8 · distinct threads (their numbers, counted before the mask): 2
$ curl -s http://127.0.0.1:19333/probe/executor
  ThreadPoolTaskExecutor task-N virtual=false
$ harness/shutdown.sh 19333 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19333 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19333 --spring.main.sources=probe.web.Threads
  listens on: 127.0.0.1:19333 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19333/actuator/health/readiness
  {"status":"UP"} 200
$ harness/slow8.sh 19333
  8 × tomcat-handler-N virtual=true
  answers: 8 · distinct threads (their numbers, counted before the mask): 8
$ curl -s http://127.0.0.1:19333/probe/executor
  SimpleAsyncTaskExecutor task-N virtual=true
$ harness/shutdown.sh 19333 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19333 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - the AOT jar: after/ built with the profile native (the README's line), run with the README's AOT line - virtual threads off at run time, TiffinBox's line at DEBUG, each line its thread's whole name and the message - port 19334:
$ cd .harness/aot && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean package
  built after/, the profile native (Spring's AOT step) · offline: yes · exit 0
$ cd .harness/aot && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19334 --spring.threads.virtual.enabled=false --logging.level.kitchen=debug --logging.pattern.console='%thread %msg%n'
  listens on: 127.0.0.1:19334 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19334/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19334/customers
  200 application/json
  TiffinBox's line for it: tomcat-handler-N GET /customers -> 200
$ harness/shutdown.sh 19334 .harness/aot/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19334 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```

## 7 · stop — what stops it, with a request in flight (C6-15; A/B/A′)

Boot's metadata (`server.shutdown` `graceful`, `spring.lifecycle.timeout-per-shutdown-phase` 30s); after/ on the README's class-path line with the harness joined (so a request can be in flight: `/probe/slow?ms=3000`, three seconds, sent in the background; `/probe/inflight` says `1` before the POST — this README's two lines); **A** Boot's default: POST /shutdown → 200; the slow request answers **200**; the log after the POST — `Commencing graceful shutdown. Waiting for active requests to complete`, `Graceful shutdown complete`; exit 0, the port free; **B** `--server.shutdown=immediate` (this README's line): the slow request gets **no answer** (`000`, curl exit 52 — the connection closed), 0 lines after the POST, exit 0; **A′** = A.

`.r-stop.out` · md5 `76a54614d0a8cf3e74d924d7c379197d` · 3 of 3

```
Boot's own metadata, in after/'s jar: server.shutdown default graceful (spring-boot-web-server-4.1.1.jar) · spring.lifecycle.timeout-per-shutdown-phase default 30s (spring-boot-autoconfigure-4.1.1.jar)
A - Boot's default: after/ on the README's class-path line with the harness joined, port 19330 - a slow request in flight, then POST /shutdown:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19330 --spring.main.sources=probe.web.Threads
  listens on: 127.0.0.1:19330 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19330/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -m 30 -o /dev/null -w '%{http_code}\n' 'http://127.0.0.1:19330/probe/slow?ms=3000' &
$ curl -s http://127.0.0.1:19330/probe/inflight
  1
$ harness/shutdown.sh 19330 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19330 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the slow request's answer: 200 · curl exit 0
  its log after the POST, from the message on - 2 line(s):
    Commencing graceful shutdown. Waiting for active requests to complete
    Graceful shutdown complete
B - the same, Boot's shutdown made immediate (README.md's option):
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19330 --spring.main.sources=probe.web.Threads --server.shutdown=immediate
  listens on: 127.0.0.1:19330 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19330/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -m 30 -o /dev/null -w '%{http_code}\n' 'http://127.0.0.1:19330/probe/slow?ms=3000' &
$ curl -s http://127.0.0.1:19330/probe/inflight
  1
$ harness/shutdown.sh 19330 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19330 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the slow request's answer: 000 · curl exit 52
  its log after the POST, from the message on - 0 line(s):
A' - A again:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19330 --spring.main.sources=probe.web.Threads
  listens on: 127.0.0.1:19330 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19330/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -m 30 -o /dev/null -w '%{http_code}\n' 'http://127.0.0.1:19330/probe/slow?ms=3000' &
$ curl -s http://127.0.0.1:19330/probe/inflight
  1
$ harness/shutdown.sh 19330 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19330 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the slow request's answer: 200 · curl exit 0
  its log after the POST, from the message on - 2 line(s):
    Commencing graceful shutdown. Waiting for active requests to complete
    Graceful shutdown complete
```

## 8 · taken — a port taken, before and after; C and D (labelled)

**before**: TiffinBox's own analyzer — exit 1, 0 frames, `TiffinBox could not listen on 127.0.0.1:19331: …` and its action naming `--tiffinbox.port`: the address and a setting named; the previous tree's libraries register 21 failure analyzers, and none holds Boot's sentence; **after**: Boot's analyzer — exit 1, 0 frames, `Web server failed to start. Port 19330 was already in use.` and its action: neither the address nor a setting named; the class that holds that sentence, `org.springframework.boot.web.server.PortInUseFailureAnalyzer` (`spring-boot-web-server-4.1.1.jar`); the libraries now register 24 (`spring-boot-tomcat` 1 and `spring-boot-web-server` 2 more); the factories file names one of TiffinBox's (the key removed: RE-MEASURE 5); **C** a bare number: exit 2 before the banner, 0 of Boot's Tomcat lines, never bound; **D** an address this Mac does not have (`192.0.2.1`): exit 1, the trace (39 frames), `Unable to start embedded Tomcat server`, `Can't assign requested address`.

`.r-taken.out` · md5 `5fc14d56624b91148a008e94bf9c7bd5` · 3 of 3

```
before - the previous tree on port 19331, then the same line again while it holds the port:
$ cd .harness/before && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19331
  listens on: 127.0.0.1:19331 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19331/actuator/health/readiness
  {"status":"UP"} 200
$ cd .harness/before && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19331
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0 · Boot's Tomcat lines 0
  WARN s.c.a.AnnotationConfigApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.BeanCreationException …
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  the hint Boot logs: Error starting ApplicationContext. To display the condition evaluation report re-run your application with 'debug' enabled.
  Description:
  TiffinBox could not listen on 127.0.0.1:19331: something else already listens there.
  Action:
  Stop the program on that port, or start TiffinBox on another: --tiffinbox.port=<a free port>.
  its log: the banner's :: Spring Boot :: line 1
  its standard error: 0 lines · the demo token in its log: 0
  its two sentences name the address: yes · a setting (--…): yes
$ harness/shutdown.sh 19331 .harness/before/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19331 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the failure analyzers its libraries register (META-INF/spring.factories): 21 (spring-boot 18, spring-boot-autoconfigure 2, spring-boot-micrometer-metrics 1)
  the library class that holds Boot's sentence ("was already in use."): none
after - after/ on port 19330, then the same line again while it holds the port:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19330
  listens on: 127.0.0.1:19330 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19330/actuator/health/readiness
  {"status":"UP"} 200
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19330
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0 · Boot's Tomcat lines 1
  WARN ConfigServletWebServerApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.context.ApplicationContextException …
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  the hint Boot logs: Error starting ApplicationContext. To display the condition evaluation report re-run your application with 'debug' enabled.
  Description:
  Web server failed to start. Port 19330 was already in use.
  Action:
  Identify and stop the process that's listening on port 19330 or configure this application to listen on another port.
  its log: the banner's :: Spring Boot :: line 1
  its standard error: 0 lines · the demo token in its log: 0
  its two sentences name the address: no · a setting (--…): no
$ harness/shutdown.sh 19330 .harness/after/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19330 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the failure analyzers its libraries register (META-INF/spring.factories): 24 (spring-boot 18, spring-boot-autoconfigure 2, spring-boot-micrometer-metrics 1, spring-boot-tomcat 1, spring-boot-web-server 2)
  the library class that holds Boot's sentence ("was already in use."): org.springframework.boot.web.server.PortInUseFailureAnalyzer (spring-boot-web-server-4.1.1.jar)
  after/'s spring.factories, the analyzers it names: com.tiffinbox.web.BareArgumentAnalyzer
C (labelled) - after/, a bare argument: the README's old command, its ports 19335 and 19336:
$ cd .harness/after && TIFFINBOX_PORT=19335 java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar 19336
  exit 2
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0 · Boot's Tomcat lines 0
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  Description:
  TiffinBox reads no bare arguments: argument 1 of 1 is 19336.
  Action:
  To set the port, give it as an option: --tiffinbox.port=19336.
  its log: the banner's :: Spring Boot :: line 0
  its standard error: 0 lines · the demo token in its log: 0
  listening now: 19335 0 · 19336 0
D (labelled) - after/, an address this Mac does not have: the README's line, port 19336:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19336 --tiffinbox.address=192.0.2.1
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 0 · stack frames 39 = 20 + 3 + 3 + 3 + 10 · Caused by: 4 · frames folded as common 88 · Boot's Tomcat lines 1
  WARN ConfigServletWebServerApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.context.ApplicationContextException …
  ERROR o.s.boot.SpringApplication: Application run failed
  org.springframework.context.ApplicationContextException: Failed to start bean 'webServerStartStop'
  Caused by: org.springframework.boot.web.server.WebServerException: Unable to start embedded Tomcat server
  Caused by: java.lang.IllegalArgumentException: standardService.connector.startFailed
  Caused by: org.apache.catalina.LifecycleException: Protocol handler start failed
  Caused by: java.net.BindException: Can't assign requested address
  the hint Boot logs: Error starting ApplicationContext. To display the condition evaluation report re-run your application with 'debug' enabled.
  its log: the banner's :: Spring Boot :: line 1
  its standard error: 0 lines · the demo token in its log: 0
  listening now: 19336 0
```

## 9 · exercise — the exercise, run as written, in one shell

`exercise/README.md`'s commands, exactly as written — its last line, as shipped, prints `threads that answered: 8` — then `exercise/solution/SOLUTION.md`'s three lines, in the **same** shell, as a viewer pastes them: `threads that answered: 2`. The shell is `env -i` — none of this script's variables reach it, only `HOME` and the `PATH` you started `receipts.sh` with — `/bin/bash --noprofile --norc`, started in this folder; each block's exit code and the folder it left the shell in are printed (`this unit's folder`, both times: the JVM runs in a subshell). SOLUTION.md starts with the README's two `export` lines (checked), so a new shell gets JDK 25 too.

`.r-exercise.out` · md5 `cb9eb4276f128f6b17329336da7f4ff2` · 3 of 3

```
exercise/README.md's commands, then the solution's lines (exercise/solution/SOLUTION.md), exactly as written, one after the other in ONE shell - env -i (HOME, and the PATH this script was started with), /bin/bash --noprofile --norc, started in this folder:
the README's 8 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
  $ mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
  $ (umask 077 && openssl rand -hex 13 > .harness/mine/after/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine/after && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null)
  $ javac -d .harness/mine/hc -cp ".harness/mine/after/tiffinbox-web/target/extracted/lib/*" harness/probe/web/Threads.java
  $ (cd .harness/mine/after && { java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19339 --spring.main.sources=probe.web.Threads --server.tomcat.threads.max=2 > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19339/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && ../../../harness/slow8.sh 19339 > ../slow.txt && ../../../harness/shutdown.sh 19339 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && echo "threads that answered: $(sort -u ../slow.txt | wc -l | tr -d ' ')")
  exit 0 · what they printed:
    threads that answered: 8
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times
the solution's 3 lines, next, in the same shell:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ (cd .harness/mine/after && { java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19339 --spring.main.sources=probe.web.Threads --server.tomcat.threads.max=2 --spring.threads.virtual.enabled=false > ../run.log 2>&1 & } && for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19339/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done && ../../../harness/slow8.sh 19339 > ../slow.txt && ../../../harness/shutdown.sh 19339 secrets/tiffinbox/shutdown-token > /dev/null && wait $! && echo "threads that answered: $(sort -u ../slow.txt | wc -l | tr -d ' ')")
  exit 0 · what they printed:
    threads that answered: 2
  the shell is now in: this unit's folder · the copy's own token in its log: 0 times · listening on 19339 now: 0
```

## 10 · forms — every form still serves (R.40)

`after/`'s native build (the README's two Maven lines, offline: 8 of 8 stages, Mach-O, 0 token bytes, 0 download lines); then **1** the jar, **2** the AOT jar, **3** the binary — and the binary at DEBUG: `Mapped to TiffinBox route /customers` and TiffinBox's line, both on `tomcat-handler-N` (the named handler in the binary: RE-MEASURE 5), its other lines bounded — **4** the image (its presence checked first: `docker run` would otherwise try to pull it): each the seven `571faaea…`, each exit 0, each with Boot's two graceful-shutdown lines in its log (4 of 4); loopback counted form by form — the jar, the AOT jar and the binary by their listeners, the image by `docker port`.

`.r-forms.out` · md5 `69c29202be33c5e9067deea238424ddd` · 3 of 3

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
  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: under 20 minutes · its lines that say the metadata repository was downloaded over http, or failed to: 0 · offline: yes
  file: Mach-O 64-bit executable · the demo token in its bytes: 0
1 the jar - .harness/after, the README's run line, port 19330:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19330
  listens on: 127.0.0.1:19330 · loopback only: yes
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19330/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19330 (http) with context path '/'
$ $CURLSET 19330 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 1 · md5 571faaea42e87e85add8c9548c64c961
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  Boot's graceful-shutdown lines in its log: 2
2 the AOT jar - .harness/nat (the profile native's jar), the README's AOT line, port 19334:
$ cd .harness/nat && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19334
  listens on: 127.0.0.1:19334 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19334/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19334 (http) with context path '/'
$ $CURLSET 19334 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 1 · md5 571faaea42e87e85add8c9548c64c961
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  Boot's graceful-shutdown lines in its log: 2
3 the binary - .harness/nat, the README's line, port 19338:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19338
  listens on: 127.0.0.1:19338 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19338/actuator/health/readiness
  {"status":"UP"} 200
  Boot's started line - logger: message: o.s.boot.tomcat.TomcatWebServer: Tomcat started on port 19338 (http) with context path '/'
$ $CURLSET 19338 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 1 · md5 571faaea42e87e85add8c9548c64c961
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  Boot's graceful-shutdown lines in its log: 2
  the binary at DEBUG - the README's line with Boot's web group and the kitchen at DEBUG, each line its thread's whole name and the message, port 19338:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19338 --logging.level.web=debug --logging.level.kitchen=debug --logging.pattern.console='%thread %msg%n'
  listens on: 127.0.0.1:19338 · loopback only: yes
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19338/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://127.0.0.1:19338/customers
  200 application/json
  its lines for GET /customers that name a handler, and TiffinBox's own: tomcat-handler-N Mapped to TiffinBox route /customers|tomcat-handler-N GET /customers -> 200 · its other lines - the start, the readiness polls (their number moves), the rest of this request: more than 40, not shown
  its WARN lines: 1 (JvmGcMetrics: GC notifications will not be available - the native binary's known line)
$ harness/shutdown.sh 19338 .harness/nat/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19338 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
4 the image - tiffinbox-tomcat:1.0.0 (the bind capture's), the README's run line with your user, published on 127.0.0.1:19337:
$ cd .harness/after && docker run -d --name tiffinbox-tomcat --user "$(id -u):$(id -g)" -m 512m -v "$PWD/secrets:/app/secrets:ro" -p 127.0.0.1:19337:18425 tiffinbox-tomcat:1.0.0
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19337/actuator/health/readiness
  {"status":"UP"} 200
  inside the container, listening: [::]:18425
  docker port: 18425/tcp -> 127.0.0.1:19337
  on this Mac, listening on port 19337: 127.0.0.1:19337
$ $CURLSET 19337 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
$ docker wait tiffinbox-tomcat
  0
  exit 0 · the seven responses: 7 lines · lines the timestamp mask changed: 1 · md5 571faaea42e87e85add8c9548c64c961
  its log (docker logs): Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1 · the demo token 0 times · X-Shutdown-Token 0 times
  Boot's graceful-shutdown lines in its log: 2
four forms, one tree: the seven (masked) 4 of 4 times 571faaea42e87e85add8c9548c64c961 · Boot's two graceful-shutdown lines 4 of 4 times
  loopback, form by form: the jar yes · the AOT jar yes · the binary yes (its DEBUG run among them) · the image, published on 127.0.0.1 alone yes
```

## Exercise

**Your turn:** start TiffinBox with virtual threads off and two pool threads, send eight slow requests, and count the threads that
answered. `exercise/README.md` has the commands (copy `after/` with a token of its own, build and extract the jar offline, compile
the harness); its last line, in a subshell, starts TiffinBox with `--server.tomcat.threads.max=2` and — as shipped — prints `threads
that answered: 8`: virtual threads are still on, and the pool is never used. Done is `threads that answered: 2`. Measured answer:
`exercise/solution/SOLUTION.md` (the README's two `export` lines, then the same line with `--spring.threads.virtual.enabled=false`),
run in the same shell. Run `./receipts.sh` once first on a fresh clone.

## RE-MEASURE — the brief's items this unit settles

| # | Item (brief) | Before | This unit (receipts, 2026-10-12) |
|---|---|---|---|
| 5 | the named handler in the binary; the analyzer's `spring.factories` key removed | a lambda in the probe's binary; the analyzer kept in the sketch | **`tomcat-handler-N Mapped to TiffinBox route /customers`** in the binary (`forms`); **Boot's two sentences, exit 1, 0 frames**, the factories file naming `BareArgumentAnalyzer` alone (`taken`) |
| 6 | Boot's task executor with virtual threads on; the README's "eight platform threads" sentence | not measured | **`SimpleAsyncTaskExecutor`, its task on a virtual thread**; off: `ThreadPoolTaskExecutor` (`threads` A/B); the anchor README's unit-19 note amended |
| 7 | the masked md5 of the seven on this unit's tree | `571faaea…` on the probe's sketch | **`571faaea42e87e85add8c9548c64c961`** — the jar, the AOT jar, the binary and the image, 3/3 each (`seven`, `forms`) |
| 8 | graceful shutdown with a slow request in flight | not measured | **A: a three-second request in flight answers 200 after POST /shutdown, the two graceful lines; B `--server.shutdown=immediate`: no answer (000, curl exit 52); A′ = A** (`stop`) |

## Found on the way

- **Every new check fails on a planted fault first** (R.65; BLUE, 2026-10-13, the checks block run on copies of the captures, each
  copy restored byte for byte): the YAML's `spring:` shown as `server:`; 2 connector lines at Boot's levels; B's copy with one line
  more than the alias's three; `level="INFO"` in Boot's defaults; Tomcat's status line read as `200 OK`; a 404 on TiffinBox's timer;
  `container-0` counted Tomcat's; B's slow request answered, A's dropped; Boot's sentences said to name the address; 21 analyzers;
  no analyzer class; the README's commands leaving the shell in the copy; the image off loopback; 3 of 4 forms with graceful lines —
  15 plants, 15 stops, each naming its check. SOLUTION.md without its `JAVA_HOME` line, and with another JDK's: both refused. The
  image's token counter, on a planted gzip blob holding the token: 1.
- **README, then SOLUTION, in one shell broke both** (RED part B #41). The old last line `cd`-ed into the copy and stayed there, so
  SOLUTION's `cd .harness/mine/after` failed (`No such file or directory`, exit 1); and SOLUTION had no `export JAVA_HOME`, so in a
  new shell on this Mac `java` was 23.0.1 — `UnsupportedClassVersionError` in the copy's log, and the line still printed
  `threads that answered: 0`, exit 0: a silent wrong answer (BLUE re-ran both in one `env -i` shell, 2026-10-13). Now the JVM runs in
  a subshell, SOLUTION.md starts with the README's two exports, `wait $!` ends the line with a failed JVM's own exit code, and
  `exercise` runs both blocks in one `env -i` shell and prints where each left it.
- **`tr -dc … < /dev/urandom | head -c 26` hangs when SIGPIPE is ignored** (a launcher that ignores it: RED's Python one): `tr`
  never sees `head` leave, spins at 100% CPU, and the old trap stopped only the exercise's subshell. The token now comes from
  `openssl rand -hex 13` (26 hexadecimal digits), and the trap stops the exercise's shell with every process under it (`killtree`).
- **The line that names the port is Boot's.** `Tomcat started on port …` is logged by `o.s.boot.tomcat.TomcatWebServer`; Tomcat's
  own connector (`o.a.coyote.http11.Http11NioProtocol`) logs `Initializing ProtocolHandler ["http-nio-127.0.0.1-19330"]` — the
  address — at INFO, and Boot's `org/springframework/boot/logging/logback/defaults.xml` (in `spring-boot-4.1.1.jar`) sets that logger
  to WARN (`bind` F). The pool's `container-0` is Boot's too: its class is `TomcatWebServer$1` (`pool`).
- **Graceful shutdown, measured** (RE-MEASURE 8): a three-second request in flight answers 200 after POST /shutdown; with
  `--server.shutdown=immediate` it gets no answer (`000`, curl exit 52) and Boot logs no graceful line (`stop`).
- **A missing image is a pull.** A run of `forms` without `bind` (a partial run) found no `tiffinbox-tomcat:1.0.0`, and `docker run`
  asked Docker Hub for it (`pull access denied`). `forms` now checks the image is there first, and dies naming the cause.
- **The default log pattern cuts a thread's name.** Logback prints the last 15 characters (`[omcat-handler-2]`, `[mcat-handler-10]`):
  a mask would have to rebuild the name. `threads` C and the binary's DEBUG run use `--logging.pattern.console='%thread %msg%n'`
  (the README's lines), which prints the whole name.
- **Boot's extract tool refuses a folder that is not empty** (`… already exists and is not empty`; `--force` overrides it). The jar
  is extracted once per `change` run, right after its clean build, and `pool` and `threads` use that.
- **`BareArgumentAnalyzer`'s Javadoc named the deleted analyzer** ("like PortTakenFailureAnalyzer"): one line changed, its code the
  same (`change`).
- **The harness cannot join an AOT run** (`--spring.main.sources` adds nothing to an AOT-processed context), so C reads the thread
  from TiffinBox's own DEBUG line.
- **A path with a space changes a native-image warning.** The spring-web jar's `native-image.properties` warning ends `in 'null'`
  when `.m2-demo`'s path holds a space (this folder's), and `in 'file:…'` when it does not (the sealed clone): the first sealed run's
  `forms` differed in those two lines alone. Both now become `in '…'` (mask 7), and `forms` was republished.
- **A sealed `HOME` hides Docker's CLI plugins and context.** Under `env -i` with a new `HOME`, `docker` found no `buildx` (so
  `--progress` was an unknown flag) and the default socket, not OrbStack's. The sealed runs pass `DOCKER_CONFIG=~/.docker` — like
  `DOCKER_HOST`, it says which Docker answers, and the script keeps it.
- **Every 404 is one series** in Boot's timer: `uri="/**"` for `/customersXYZ`, `/customers/` and `/kitchen/anything` alike (3).

## For unit 05 — and RED

- **RED part B (2026-10-13)** found 28 rows on units 04-05 (2 HIGH, 7 MEDIUM, 18 LOW, 1 OK); BLUE's adjudication, one line per row, is
  appended to `spring-web-mvc/_briefs/RED-C6-S1-2026-10-13.md` (outside this repository). Every fix above is in this commit.
- **Start from `../c6-unit04/after`** (= `../c6-tiffinbox`): TiffinBox on Tomcat, its five paths in one `SimpleUrlHandlerMapping`
  bean named `tiffinBoxRoutes`, each handler a `RouteHandler` whose `toString()` is `TiffinBox route /<path>` (named, never a lambda —
  measured in the JVM's and the binary's DEBUG lines); the exposure list is still `health,prometheus` (expose `mappings` by a flag,
  for one run, on the JVM: under AOT and in the binary a flag adds nothing).
- **The seven's comparison set is now `571faaea42e87e85add8c9548c64c961`, masked** (`tsmask`: the timestamp → `…`, both forms);
  `115c36ba…` is TiffinBox's own server's. `GET /nowhere` is Spring's JSON 404 (Jackson 3, ISO-8601 timestamp).
- **Threads:** virtual threads are on in `application.yaml` (`tomcat-handler-N`); a run-time `=false` works on the JVM only.
  Idle with virtual threads: 5 server platform threads — 4 Tomcat's, and `container-0`, whose class is Boot's — 3 not daemons.
  Thread names carry the port.
- **Bind:** every JVM listens on `127.0.0.1:<--tiffinbox.port>` through the alias in the YAML's first document (lines 19-21, the
  first `---` at 77); `--server.port` beats `--tiffinbox.port`. Receipts pass `--tiffinbox.port=` from their own range.
- **Jackson:** two in one jar — Jackson 2 (`com.fasterxml`, 2.22.2) writes TiffinBox's five answers through its own `ObjectMapper`,
  Jackson 3 (`tools.jackson`, 3.1.5) Spring's: Spring MVC's one JSON converter is `JacksonJsonHttpMessageConverter` on Jackson 3's
  `JsonMapper` (`seven`, the harness's `Converters`). Health's keys come out in Jackson 3's order (sort before comparing). The jar:
  58 libraries.
- **Two timers:** Boot's `http_server_requests` counts every answer, `tiffinbox_requests` only TiffinBox's handler's (CARRIED to
  Section 2).
- **Boot's started line** (`o.s.boot.tomcat.TomcatWebServer`) names the port only; Tomcat's own connector line names the address, at
  INFO, which Boot's logging defaults hold at WARN (`bind` F). Captures label it "Boot's started line", never "Tomcat's own line".
- **Not done here:** `Route` and `scanRoutes()` (Section 2's first lesson); the probe-era Jetty swap (unit 02's).
