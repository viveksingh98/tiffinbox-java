# c6-unit02 — Servlets, Filters and the Container

Course 6 · Spring Web MVC · Section 1, The Servlet Layer, its second unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring
Boot 4.1.1** (Spring Framework 7.0.9, Tomcat 11.0.24, Jetty 12.1.12, Servlet 6.1), 2026-10-12. Spring MVC is one servlet among
others, run by a container. A raw servlet and a raw filter of the harness's own — no Spring MVC in them — sit beside the
`DispatcherServlet`: the container decides which servlet takes each request and how it matched, runs the filter around
whichever one answers, and decides when a servlet starts and stops. Changing the container — Tomcat for Jetty, one exclusion
and one dependency — keeps the servlet's bodies and the stack's top, and changes everything the container owns. Undertow is
gone from Boot 4.1. And a second server in one JVM keeps the JVM running after TiffinBox's POST /shutdown — on Tomcat and on
Jetty — held by threads that are not daemons.

**The anchor does not change (brief ⚑10).** The tree is `../c5-unit27/after`, reached through the link `anchor` (so no capture
prints a unit folder): Course 5's last tree, read and copied under `.harness/`, never built in place. Every run checks that
`diff -rq` between `anchor/` and `../c5-tiffinbox/` is empty (both are frozen). `../c6-tiffinbox` is neither read nor run here.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 8 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

**Runs of record (2026-10-12):** **347 s under `./receipts.sh`** (/bin/bash 3.2.57, this folder, exit 0, all 8 captures =
published, every check passed; load averages about 7-35) and **478 s under `bash receipts.sh`** (Homebrew bash 5.3.9, exit 0, all
8 = published; load averages about 24-143, other units' builds beside it); **523 s from a sealed fresh clone** (bash 5.3.9, exit 0,
all 8 = published: "From a clone, sealed", below). Once more after this README took its final text (only its notes changed): 343 s under `./receipts.sh`, exit 0, all 8 =
published. The published hashes were made by `./receipts.sh` (/bin/bash 3.2.57). Interrupt test: "Interrupted", below.

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) It needs `javac`,
`python3`, `curl`, `rsync`, `patch`, `unzip` and `lsof`; no GraalVM and no Docker. It **dies** when a capture's md5 differs from
`receipts.md5` (it prints the `DIFFERS` line first).
Published hashes: jars `4a746bccbf394b63e0737d6e0d27c661` · servlet `da33b8f7ad9eb71033da35a58443486d` · filter `f43d1ee80faafbe7b704e55cd88db985` · life `c16035cfd2362c6c3f74deeae64ce9b0` · swap `d067681f45cbbd8b743abb535e152ca4` · two `9dda9b961e2f89daecb7eba9401e7f93` · undertow `17b6bf1d11087e62f27a964b1991eee1` · exercise `f9b2a9ad88feb63de7786dad7d946aa6`

## The repository, and what was downloaded

Every Maven build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen), seeded on this Mac from
`../../spring-web-mvc/_research/m2-seed-s1/` (5,827 files: Course 5's seed less `com/tiffinbox/`, plus Jetty's starter tree).
**Nothing was downloaded for this unit:** every build said `offline: yes`. Before the captures, the script builds the copy and
its Jetty twin, the starter alone's class path and the BOMs' copy once (`.harness/pre-*`), so that on a fresh clone — whose
`.m2-demo` is empty — those builds are the ones that fill it, and every capture's build says `offline: yes`. A build that
cannot resolve an artifact offline goes to Maven Central once and says so (`offline: no - …`); inside a capture that line
changes the hash and the run stops. No build uses the native profile; every build log is still searched for GraalVM's metadata
download line — found, the run stops. No Docker. At run time nothing leaves `127.0.0.1`: both servers listen there, every
request goes there, and Logback writes to the terminal only.

**From a clone, sealed (2026-10-12, R.28, R.49, S1.1).** The repository was cloned (`git clone` of the local repository's HEAD,
`74582d7`) into an empty folder, and this unit's folder put in exactly as it is committed — git's own list of its untracked, not
ignored files (20): no `.m2-demo`, no `.harness/`, no `.r-*`; `README.md` is the only file changed since (its runs of record, this
paragraph, "Found on the way" and "Interrupted"). `bash receipts.sh` (Homebrew bash 5.3.9) ran under `env -i`, with a `HOME` whose
`.mavenrc` points Maven's `user.home` there (Java reads `user.home` from the account, not from `$HOME`) and every Java proxy
property at a port that refuses (127.0.0.1:9); Maven settings that send every repository to a `file://` copy of Central's files
made from this unit's `.m2-demo` (4,364 files: TiffinBox's own installs, `_remote.repositories`, `*.lastUpdated`,
`resolver-status.properties` and `.DS_Store` left out, `maven-metadata-central.xml` served as `maven-metadata.xml`); `http_proxy`,
`https_proxy`, their capitals and `ALL_PROXY` at the same refusing port; no GraalVM, no Docker. **Exit 0 after 523 s** — all 8
captures = published, every spoken number asserted, 0 raw demo tokens. The four pre-capture builds said `offline: no` (the empty
`.m2-demo`) and fetched what every capture needs — Jetty's 42 jars among it — every one of their 784 download lines from the
`file://` copy, 0 from anywhere else; every capture's build said `offline: yes`; `.m2-demo` ended with 2,112 files; the sealed
`HOME`'s `.m2` held its `settings.xml` alone.

## The demo token — fake, new on every run, and never printed

TiffinBox does not start without its shutdown token. **`receipts.sh` makes a new one on every run** — 26 random lowercase letters
and digits from `/dev/urandom` — and writes it, with no newline, into each copy's config tree, `secrets/tiffinbox/shutdown-token`
(`-rw-------`, folders `drwx------`, git-ignored under `.harness/`). It is in no file this unit ships, `receipts.sh` included,
never on a command line (`$CURLSET` reads it from the file), and never printed: every capture is masked
(`[masked: the 26-character token]`, the length read off the token itself), and `receipts.sh` counts it raw in each capture
run's own output **before** masking (0 in all 24), in the log of every JVM a capture started (the token and the header's name
`X-Shutdown-Token`, in any case: 0), in the exercise's log (its own token: 0), and in every capture, this README, the exercise,
the harness, `receipts.sh` and `receipts.md5`: 0 each. The builder reads the tokens back from `.harness/` only to count them in
the script, the deck and the prompter: 0.

## The folders, the names and the ports

- `anchor` → `../c5-unit27/after` (a link, committed). `.harness/tc/` — the copy: the tree with Spring MVC's starter in and the
  Boot plugin's two Jackson 3 excludes out (`harness/mvc.patch`, brief ⚑10) — Tomcat. `.harness/jt/` — its Jetty twin: the same
  plus `harness/jetty.patch` (one exclusion, one dependency). Both built and extracted by `jars`; the later captures run them.
  `.harness/hc/` — the harness's classes, compiled once against the copy's own extracted jars. `.harness/pre-*` — the
  pre-capture builds. `.harness/starter/`, `.harness/undertow/`, `.harness/boms/` — the harness POMs, copied and built there.
  The exercise: `.harness/mine/`.
- **The harness** (the course's, never TiffinBox's): `harness/web/harness/` — `RawServlet` (an `HttpServlet`: it answers with the
  pattern and the kind of match `getHttpServletMapping()` reports, and prints a line at init, at each service and at destroy, with
  its thread), `RawFilter` (sets `X-Raw-Filter: seen`, hands the request on, prints the servlet that answered and the status),
  `RawServletConfig` (a `ServletRegistrationBean` on `/raw`, `/raw/*`, `*.tiff`), `RawFilterConfig` (a `FilterRegistrationBean` on
  `/*`), `Where` (`@RestController`: `GET /where` — its thread, the thread's context class loader, whether that loader hands back
  the class the application loaded, every frame the stack walker shows; `GET /threads` — every live platform thread that is not a
  daemon, with the class of its `Thread` object). They join a run by `--spring.main.sources`, in package `harness`, never
  `com.tiffinbox` (S1.15). `harness/paths.sh PORT [PATH…]` — GETs, one line each: path, status, content type, the filter's header,
  the answer. `harness/mvc.patch`, `harness/jetty.patch` — the two POM changes. `harness/starter/pom.xml` (Spring MVC's starter
  alone), `harness/undertow/pom.xml` (Undertow's starter on Boot 4.1.1's parent), `harness/boms/pom.xml` (copies Boot's two BOMs).
- **The layout every run uses** (R.44): the executable jar extracted (the anchor README's `extract` line) and the harness's folder
  on the class path, TiffinBox's own `main` — the anchor README's exploded line. Never `java -jar`: the launcher's loader as the
  context loader's parent was not measured, and is not spoken (brief RE-MEASURE 3).
- On screen: `$CURLSET` = `../c5-unit11/curlset.sh` (the seven, POST /shutdown last, the token's header read from the file);
  `$M2` = this unit's `.m2-demo`; `$pid` = the process id of the JVM the capture started.
- **Ports** (brief ⚑1, 19310-19319; checked free with `lsof` before anything is wiped; 18425 and 8080 too, and never bound):
  `servlet`, `life`, `swap`'s A, B and A′ — TiffinBox 19310, the container 19311 · `filter` 19312 / 19313 · `two` D 19314 /
  19315, E 19316 / 19317 · the exercise 19318 / 19319. **Every container is told `--server.address=127.0.0.1`** (Tomcat and Jetty
  listen on every interface without it) and every capture asserts the addresses its JVM listens on: exactly `127.0.0.1:<its two
  ports>` — a wildcard or any other address stops the run (R.78).

## The commands — the anchor README's, and this unit's own

From `anchor/README.md`, read by `readme()` and asserted whole: `mvn -B package` (run as `mvn -o -B -Dmaven.repo.local="$M2"
-DskipTests clean package`, the offline changes reversed and asserted by `dev()`); the `extract` line; the exploded run
`java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer
--tiffinbox.port=18431`, run with its port made the capture's, `:../hc` added to the class path, `--spring.main.sources=…`,
`--server.address=127.0.0.1 --server.port=…` and, in `filter` only, one exposure flag — the changes reversed and asserted by
`unhcp()`; the readiness `curl` line. This unit's own lines, read from this README by `mine()` and asserted whole:

```
cd .harness/tc && patch -s -p1 < ../../harness/mvc.patch && diff -U0 ../../anchor/tiffinbox-web/pom.xml tiffinbox-web/pom.xml | sed 1,2d
cd .harness/jt && patch -s -p1 < ../../harness/mvc.patch && patch -s -p1 < ../../harness/jetty.patch && diff -U0 ../tc/tiffinbox-web/pom.xml tiffinbox-web/pom.xml | sed 1,2d
javac -d .harness/hc -cp ".harness/tc/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/tc/tiffinbox-web/target/extracted/lib/*" harness/web/harness/*.java
cd .harness/starter && mvn -o -B -Dmaven.repo.local="$M2" dependency:build-classpath -Dmdep.outputFile=target/classpath.txt
cd .harness/undertow && mvn -o -B -Dmaven.repo.local="$M2" validate
cd .harness/boms && mvn -o -B -Dmaven.repo.local="$M2" validate
--management.endpoints.web.exposure.include=health,mappings
```

The last line is the one exposure flag, for `filter`'s one run (R.42): `health,mappings`, never a star — a check greps this
unit's scripts, READMEs and captures for one.

## Masks, filters and hygiene — every one, declared

1. **Paths, the token, the user** (`gsub()`, literals escaped), in every line: the token → `[masked: the N-character token]`, N its
   own length; this folder → `…`; the folder above → `…/..`; home → `~`; the user name → `<user>`; a GraalVM's folder, if one is
   named, → `$GRAALVM_HOME`.
2. **Spring's error timestamp** (S1.5, proposed R.88): `"timestamp":"<an ISO-8601 time>"` → `"timestamp":"<time>"` and
   `"timestamp":<digits>` → `"timestamp":<epoch ms>` — both forms, though only the ISO string appears here (Jackson 3 is in the copy's
   jar, ⚑6's state). A last check fails if a capture holds `"timestamp":` followed by a digit or a quoted digit.
3. **Thread numbers and identity hashes** (S1.5): `exec-<n>` → `exec-N`; `qtp<n>-<n>` → `qtp<hash>-N` (Jetty names its pool
   `qtp` + the pool's identity hash); `Scheduler-<n>-` → `Scheduler-<hash>-`; `@<hex>` (four or more) → `@<hash>`. A last check fails if
   a capture holds `exec-<digit>`, `qtp<digit>`, a log time or a stack frame line.
4. **`GET /where`'s answer** (`whereview`): the thread, the context class loader's class and every superclass up to `ClassLoader`, its
   parent, the harness class's own loader, whether the context loader hands back the same class; then the frames the stack walker
   shows, **counted**: from the method down to `DispatcherServlet.doService` (the top — its names hashed with md5), and below it, by
   whose they are — the `DispatcherServlet`'s servlet methods (`FrameworkServlet`, `HttpServlet`), Spring's filters
   (`org.springframework.web.filter`), the harness's, Tomcat's (`org.apache`), Jetty's (`org.eclipse.jetty`), the JDK's — and the
   last frame. The frame list itself is not printed (proposed R.90: "frames the stack walker shows" — it hides reflection's own).
   `filters`: the filters one request passed, outermost first — each filter's own `doFilter` or `doFilterInternal` frame, the
   container's chain frames and `OncePerRequestFilter`'s left out.
5. **`GET /threads`'s answer** (`threadsview`): each thread's name and the class of its `Thread` object, masked as in 3, each
   distinct line once with its count (`x7`). **The container's table** (`/actuator/mappings`): its servlets and its filters, one row
   each — name, patterns sorted, class — sorted by name.
6. **A run's log** is never printed whole: the harness's own lines (`harness: …`); TiffinBox's `TiffinBox listening on …` and the
   container's `… started on port …` line; Boot's two graceful-shutdown lines; the token and the header's name counted. Boot's first
   line (its process id, your user, this folder) is never printed. **A Maven log**: the `built … · offline: … · exit …` line; for
   `undertow` the exit code and the first `'dependencies.dependency.version' …` line (Maven prints it twice).
7. **TiffinBox's own `/customers`** (`servlet`) is cut after its first 30 characters, the cut counted.
8. **No duration is captured.**
9. **Hygiene:** the S5.15 loop copied from `c5-unit26` (`sed -E`, a planted canary under every name, the run stops if one survives)
   over every `TIFFINBOX_*`, `SPRING_*`, `MANAGEMENT_*`, `SERVER_*`, `LOGGING_*` variable, `DEBUG`, `JAVA_TOOL_OPTIONS`,
   `JDK_JAVA_OPTIONS`, `_JAVA_OPTIONS`, `MAVEN_OPTS`, `MAVEN_ARGS`, `NATIVE_IMAGE_OPTIONS` (no Docker here, so no `COMPOSE_*`);
   `127.0.0.1` first in `no_proxy`/`NO_PROXY`. One run at a time (`.r-lock`). No capture lists the environment, so macOS's
   `__CF_USER_TEXT_ENCODING` never reaches one. A last check fails if a captured `java` command passes `--server.port` without
   `--server.address=127.0.0.1`.

## 1 · jars — the copy, its Jetty twin, and the starter alone

The copy is the anchor plus `harness/mvc.patch`: Spring MVC's starter in `tiffinbox-web/pom.xml`, and the Boot plugin's two
`tools.jackson.core` excludes out (brief ⚑10: ⚑6's state for Spring's JSON). Its twin is the same plus `harness/jetty.patch`: one
exclusion (`spring-boot-starter-tomcat`, from inside Spring MVC's starter) and one dependency (`spring-boot-starter-jetty`). Both
built offline, the anchor README's way. **58 jars → 97: 3 out, 42 in.** Tomcat carries the servlet API's classes inside
`tomcat-embed-core`; Jetty brings `jakarta.servlet-api-6.1.0.jar` as a jar of its own (one of the 42). Spring MVC's starter alone,
on Boot 4.1.1's parent: **39 jars** on its class path — the number Course 5 said ("Thirty-nine jars"), re-counted on 4.1.1 (X4).

`.r-jars.out` · md5 `4a746bccbf394b63e0737d6e0d27c661` · 3 of 3

```
the copy - the anchor with Spring MVC's starter in, the Boot plugin's two Jackson 3 excludes out (harness/mvc.patch) - and
its Jetty twin - the same, with one exclusion and one dependency (harness/jetty.patch); each built the anchor README's plain way:
$ cd .harness/tc && patch -s -p1 < ../../harness/mvc.patch && diff -U0 ../../anchor/tiffinbox-web/pom.xml tiffinbox-web/pom.xml | sed 1,2d
  @@ -61,0 +62,4 @@
  +    <dependency>
  +      <groupId>org.springframework.boot</groupId>
  +      <artifactId>spring-boot-starter-webmvc</artifactId>
  +    </dependency>
  @@ -85,8 +88,0 @@
  -            <exclude>
  -              <groupId>tools.jackson.core</groupId>
  -              <artifactId>jackson-databind</artifactId>
  -            </exclude>
  -            <exclude>
  -              <groupId>tools.jackson.core</groupId>
  -              <artifactId>jackson-core</artifactId>
  -            </exclude>
$ cd .harness/tc && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the copy: Tomcat · offline: yes · exit 0
$ cd .harness/jt && patch -s -p1 < ../../harness/mvc.patch && patch -s -p1 < ../../harness/jetty.patch && diff -U0 ../tc/tiffinbox-web/pom.xml tiffinbox-web/pom.xml | sed 1,2d
  @@ -64,0 +65,6 @@
  +      <exclusions>
  +        <exclusion>
  +          <groupId>org.springframework.boot</groupId>
  +          <artifactId>spring-boot-starter-tomcat</artifactId>
  +        </exclusion>
  +      </exclusions>
  @@ -65,0 +72,4 @@
  +    <dependency>
  +      <groupId>org.springframework.boot</groupId>
  +      <artifactId>spring-boot-starter-jetty</artifactId>
  +    </dependency>
$ cd .harness/jt && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built its twin: Jetty · offline: yes · exit 0
the two executable jars:
  jars under BOOT-INF/lib: Tomcat's copy 58 · Jetty's 97
  only in Tomcat's: 3 - spring-boot-tomcat-4.1.1.jar tomcat-embed-core-11.0.24.jar tomcat-embed-websocket-11.0.24.jar
  only in Jetty's: 42 -
    asm-9.10.1.jar asm-commons-9.10.1.jar asm-tree-9.10.1.jar jakarta.enterprise.cdi-api-4.1.0.jar jakarta.enterprise.lang-model-4.1.0.jar jakarta.inject-api-2.0.1.jar jakarta.interceptor-api-2.2.0.jar jakarta.servlet-api-6.1.0.jar jakarta.transaction-api-2.0.1.jar jakarta.websocket-api-2.2.0.jar jakarta.websocket-client-api-2.2.0.jar jetty-alpn-client-12.1.12.jar jetty-annotations-12.1.12.jar jetty-client-12.1.12.jar jetty-compression-common-12.1.12.jar jetty-compression-gzip-12.1.12.jar jetty-compression-server-12.1.12.jar jetty-ee-webapp-12.1.12.jar jetty-ee11-annotations-12.1.12.jar jetty-ee11-plus-12.1.12.jar jetty-ee11-servlet-12.1.12.jar jetty-ee11-webapp-12.1.12.jar jetty-ee11-websocket-jakarta-client-12.1.12.jar jetty-ee11-websocket-jakarta-common-12.1.12.jar jetty-ee11-websocket-jakarta-server-12.1.12.jar jetty-ee11-websocket-jetty-server-12.1.12.jar jetty-ee11-websocket-servlet-12.1.12.jar jetty-http-12.1.12.jar jetty-io-12.1.12.jar jetty-plus-12.1.12.jar jetty-security-12.1.12.jar jetty-server-12.1.12.jar jetty-session-12.1.12.jar jetty-util-12.1.12.jar jetty-websocket-core-client-12.1.12.jar jetty-websocket-core-common-12.1.12.jar jetty-websocket-core-server-12.1.12.jar jetty-websocket-jetty-api-12.1.12.jar jetty-websocket-jetty-common-12.1.12.jar jetty-websocket-jetty-server-12.1.12.jar jetty-xml-12.1.12.jar spring-boot-jetty-4.1.1.jar
$ cd .harness/tc && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0 · lib/ holds 58 jars
$ cd .harness/jt && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0 · lib/ holds 97 jars
  the servlet API's own jar (jakarta.servlet-api): Tomcat's 0 · Jetty's 1 - Tomcat carries the API's classes inside tomcat-embed-core: 1 HttpServlet.class
Spring MVC's starter alone - harness/starter/pom.xml: one dependency, on Boot 4.1.1's parent - and the class path Maven
builds for it:
$ cd .harness/starter && mvn -o -B -Dmaven.repo.local="$M2" dependency:build-classpath -Dmdep.outputFile=target/classpath.txt
  built the starter alone · offline: yes · exit 0
  jars on its class path: 39
  among them: jackson-databind-3.1.5.jar · logback-classic-1.5.38.jar · spring-webmvc-7.0.9.jar · tomcat-embed-core-11.0.24.jar
```


## 2 · servlet — the container's own rules

The raw servlet on three kinds of pattern, beside the `DispatcherServlet` (`/`). **`/raw` EXACT · `/raw/menu/today` PATH ·
`/lunch.tiff` EXTENSION · `/raw/lunch.tiff` PATH — a path pattern and an extension both fit, and the path won · `/customers`,
`/rawXYZ`, `/nowhere` → the default servlet, the `DispatcherServlet`, 404** (Spring's JSON, Jackson 3, the timestamp masked). The
answer reports the container's own decision: `getHttpServletMapping()`. The writer's content type: `text/plain;charset=ISO-8859-1`
— the servlet set `text/plain` and no charset. `X-Raw-Filter: seen` on all seven. The same path asked of TiffinBox's own server
(the JDK's `HttpServer`, no container): 200, and no filter header.

`.r-servlet.out` · md5 `da33b8f7ad9eb71033da35a58443486d` · 3 of 3

```
the copy (built by capture jars), run exploded - the extracted jar and the harness's folder - with the raw servlet on /raw,
/raw/* and *.tiff and the raw filter on /* joined (harness/web/harness/): TiffinBox's own server on 19310, Tomcat on 19311.
The registration, and the line where the servlet asks the container how it matched:
$ grep -n 'bean.setUrlMappings\|= req.getHttpServletMapping()' harness/web/harness/RawServletConfig.java harness/web/harness/RawServlet.java
  harness/web/harness/RawServletConfig.java:18:        bean.setUrlMappings(List.of("/raw", "/raw/*", "*.tiff"));
  harness/web/harness/RawServlet.java:32:        HttpServletMapping m = req.getHttpServletMapping();
$ cd .harness/tc && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19310 --spring.main.sources=harness.RawServletConfig,harness.RawFilterConfig --server.address=127.0.0.1 --server.port=19311
  listens on: 127.0.0.1:19310 127.0.0.1:19311 - TiffinBox's own server, 19310, and the container, 19311
  TiffinBox's own line: TiffinBox listening on http://127.0.0.1:19310
  the container's own line, in the log once readiness answered: Tomcat started on port 19311 (http) with context path '/'
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19310/actuator/health/readiness
  {"status":"UP"} 200
seven requests to Tomcat, 19311 - which servlet the container gave each, as the answer says (the raw servlet's names the
pattern that matched, read from getHttpServletMapping(); a 404 is the DispatcherServlet's):
$ harness/paths.sh 19311
  GET /raw             -> 200 text/plain;charset=ISO-8859-1  X-Raw-Filter: seen  raw servlet: pattern=/raw match=EXACT
  GET /raw/menu/today  -> 200 text/plain;charset=ISO-8859-1  X-Raw-Filter: seen  raw servlet: pattern=/raw/* match=PATH
  GET /lunch.tiff      -> 200 text/plain;charset=ISO-8859-1  X-Raw-Filter: seen  raw servlet: pattern=*.tiff match=EXTENSION
  GET /raw/lunch.tiff  -> 200 text/plain;charset=ISO-8859-1  X-Raw-Filter: seen  raw servlet: pattern=/raw/* match=PATH
  GET /customers       -> 404 application/json  X-Raw-Filter: seen  {"timestamp":"<time>","status":404,"error":"Not Found","path":"/customers"}
  GET /rawXYZ          -> 404 application/json  X-Raw-Filter: seen  {"timestamp":"<time>","status":404,"error":"Not Found","path":"/rawXYZ"}
  GET /nowhere         -> 404 application/json  X-Raw-Filter: seen  {"timestamp":"<time>","status":404,"error":"Not Found","path":"/nowhere"}
the same path asked of TiffinBox's own server, 19310 - the JDK's HttpServer, no servlet container (its answer cut):
$ harness/paths.sh 19310 /customers
  GET /customers       -> 200 application/json  X-Raw-Filter: -  [{"name":"Meera","mealsPerDay" … (252 characters more)
$ kill $pid
  exit 143 · listening on 19310 and 19311 now: 0 and 0
  Boot's lines while it stopped: Commencing graceful shutdown. Waiting for active requests to complete · Graceful shutdown complete
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 3 · filter — what a filter sees; the container's table

The raw filter on `/*`: **its line for all seven requests**, the servlet that answered named by the container (`rawServlet` four
times, `dispatcherServlet` three). The container's table, from `/actuator/mappings` (exposed by a flag for this one run): **2
servlets, 6 filters** — ours; four of Spring's, three of them in Boot's own `Ordered…` classes
(`org.springframework.boot.servlet.filter`), the fourth Spring's `ServerHttpObservationFilter` itself; and Tomcat's `WsFilter`
("Tomcat WebSocket (JSR356) Filter"). One request's path (`GET /where`): **the same 6, outermost first** — Spring's four, then
ours, then Tomcat's.

`.r-filter.out` · md5 `f43d1ee80faafbe7b704e55cd88db985` · 3 of 3

```
the same copy, the raw servlet and the raw filter joined, and the harness's route too (GET /where); mappings exposed by a
flag for this one run - TiffinBox's own server on 19312, Tomcat on 19313. The filter's registration, and its three steps:
$ grep -n 'bean.addUrlPatterns\|resp.setHeader\|chain.doFilter(request\|println(.harness: raw filter' harness/web/harness/RawFilterConfig.java harness/web/harness/RawFilter.java
  harness/web/harness/RawFilterConfig.java:17:        bean.addUrlPatterns("/*");
  harness/web/harness/RawFilter.java:25:        resp.setHeader("X-Raw-Filter", "seen");
  harness/web/harness/RawFilter.java:26:        chain.doFilter(request, response);
  harness/web/harness/RawFilter.java:28:        System.out.println("harness: raw filter " + req.getMethod() + " " + req.getRequestURI() + " -> servlet "
$ cd .harness/tc && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19312 --spring.main.sources=harness.RawServletConfig,harness.RawFilterConfig,harness.Where --server.address=127.0.0.1 --server.port=19313 --management.endpoints.web.exposure.include=health,mappings
  listens on: 127.0.0.1:19312 127.0.0.1:19313 - TiffinBox's own server, 19312, and the container, 19313
  TiffinBox's own line: TiffinBox listening on http://127.0.0.1:19312
  the container's own line, in the log once readiness answered: Tomcat started on port 19313 (http) with context path '/'
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19312/actuator/health/readiness
  {"status":"UP"} 200
$ harness/paths.sh 19313
  7 answers · with the raw filter's header X-Raw-Filter: seen - 7
the raw filter's own lines, in the log's order - the seven, the first requests the container got; the servlet that
answered, as the container names it:
  harness: raw filter GET /raw -> servlet rawServlet (/raw, EXACT) - status 200
  harness: raw filter GET /raw/menu/today -> servlet rawServlet (/raw/*, PATH) - status 200
  harness: raw filter GET /lunch.tiff -> servlet rawServlet (*.tiff, EXTENSION) - status 200
  harness: raw filter GET /raw/lunch.tiff -> servlet rawServlet (/raw/*, PATH) - status 200
  harness: raw filter GET /customers -> servlet dispatcherServlet (/, DEFAULT) - status 404
  harness: raw filter GET /rawXYZ -> servlet dispatcherServlet (/, DEFAULT) - status 404
  harness: raw filter GET /nowhere -> servlet dispatcherServlet (/, DEFAULT) - status 404
the container's table - Boot's /actuator/mappings, its servlets and its filters, each with its patterns:
$ curl -s -o .harness/mappings.json http://127.0.0.1:19313/actuator/mappings
  servlets: 2
    dispatcherServlet / - org.springframework.web.servlet.DispatcherServlet
    rawServlet *.tiff /raw /raw/* - harness.RawServlet
  filters: 6
    characterEncodingFilter /* - org.springframework.boot.servlet.filter.OrderedCharacterEncodingFilter
    formContentFilter /* - org.springframework.boot.servlet.filter.OrderedFormContentFilter
    rawFilter /* - harness.RawFilter
    requestContextFilter /* - org.springframework.boot.servlet.filter.OrderedRequestContextFilter
    Tomcat WebSocket (JSR356) Filter /* - org.apache.tomcat.websocket.server.WsFilter
    webMvcObservationFilter /* - org.springframework.web.filter.ServerHttpObservationFilter
one request's path through them - GET /where, the harness's route, read off the stack of the method it reached:
$ curl -s http://127.0.0.1:19313/where
  the filters it passed, outermost first: 6 - CharacterEncodingFilter · ServerHttpObservationFilter · FormContentFilter · RequestContextFilter · RawFilter · WsFilter
$ kill $pid
  exit 143 · listening on 19312 and 19313 now: 0 and 0
  Boot's lines while it stopped: Commencing graceful shutdown. Waiting for active requests to complete · Graceful shutdown complete
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 4 · life — init, service, destroy

On Tomcat, the raw servlet alone joined: **at startup, 0 lines; the first request runs `init` once, on a request thread
(`http-nio-127.0.0.1-19311-exec-N`); each request runs `service` — 3 requests, 3 lines; `kill $pid` (SIGTERM) → Boot's two
graceful-shutdown lines, and `destroy` once, on `SpringApplicationShutdownHook`**; exit 143, both ports free.

`.r-life.out` · md5 `c16035cfd2362c6c3f74deeae64ce9b0` · 3 of 3

```
the raw servlet's life, on Tomcat - the copy with the raw servlet joined; TiffinBox on 19310, Tomcat on 19311:
$ cd .harness/tc && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19310 --spring.main.sources=harness.RawServletConfig --server.address=127.0.0.1 --server.port=19311
  listens on: 127.0.0.1:19310 127.0.0.1:19311 - TiffinBox's own server, 19310, and the container, 19311
  TiffinBox's own line: TiffinBox listening on http://127.0.0.1:19310
  the container's own line, in the log once readiness answered: Tomcat started on port 19311 (http) with context path '/'
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19310/actuator/health/readiness
  {"status":"UP"} 200
  the raw servlet's lines so far: init 0 · service 0 · destroy 0
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19311/raw
  raw servlet: pattern=/raw match=EXACT 200 text/plain;charset=ISO-8859-1
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19311/raw
  raw servlet: pattern=/raw match=EXACT 200 text/plain;charset=ISO-8859-1
$ curl -s -w ' %{http_code} %{content_type}\n' http://127.0.0.1:19311/raw
  raw servlet: pattern=/raw match=EXACT 200 text/plain;charset=ISO-8859-1
  the raw servlet's lines so far: init 1 · service 3 · destroy 0
$ kill $pid
  exit 143 · listening on 19310 and 19311 now: 0 and 0
  Boot's lines while it stopped: Commencing graceful shutdown. Waiting for active requests to complete · Graceful shutdown complete
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  the raw servlet's lines in all: init 1 · service 3 · destroy 1 - in the log's order:
  harness: raw servlet init - thread http-nio-127.0.0.1-19311-exec-N
  harness: raw servlet service GET /raw
  harness: raw servlet service GET /raw
  harness: raw servlet service GET /raw
  harness: raw servlet destroy - thread SpringApplicationShutdownHook
```


## 5 · swap — the break (A/B/A′): the container

**A** — Tomcat (the copy). **B** — Jetty (the twin: one exclusion, one dependency; the `diff` printed). **A′** — A's command,
re-run: its block equals A's (checked). The same harness (the raw servlet and `Where`; the raw filter left out, so the stack is the
servlet's and the container's alone), the same ports, readiness polled on TiffinBox's own server — so `GET /where` is the
container's first request.

- **The same:** the four answers' bodies (md5 `1d4d22fe…`, A and B); from the method down to `DispatcherServlet.doService`, the same
  **9** frames (their names' md5 the same); below it, the `DispatcherServlet`'s servlet methods (5) and Spring's filters (8).
- **The container's:** frames below the `DispatcherServlet` — **36 on Tomcat, 45 on Jetty** (Tomcat's own 22, Jetty's 31); the
  thread (`http-nio-127.0.0.1-19311-exec-N` / `qtp<hash>-N`, both platform threads); the content type — **`ISO-8859-1` / `iso-8859-1`**,
  the same charset, spelled in another case; **the raw servlet's `init` — at its first request on a request thread (Tomcat) / at
  startup, on `main`, before any request (Jetty)**; the request thread's context class loader — **Boot's embedded web-app class
  loader, `org.springframework.boot.tomcat.TomcatEmbeddedWebappClassLoader`, a Tomcat `ParallelWebappClassLoader`** /
  **Jetty's `org.eclipse.jetty.ee.webapp.WebAppClassLoader`**. On both, its parent is the application class loader, which also
  loaded the harness's class, and `loadClass("harness.Where")` hands back the very class the application loaded: identity is name
  plus loader (Core Java II), and here one loader sits behind both (ledger C6-29).

`.r-swap.out` · md5 `d067681f45cbbd8b743abb535e152ca4` · 3 of 3

```
A - Tomcat: the copy (capture jars built it):
$ cd .harness/tc && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19310 --spring.main.sources=harness.RawServletConfig,harness.Where --server.address=127.0.0.1 --server.port=19311
  listens on: 127.0.0.1:19310 127.0.0.1:19311 - TiffinBox's own server, 19310, and the container, 19311
  TiffinBox's own line: TiffinBox listening on http://127.0.0.1:19310
  the container's own line, in the log once readiness answered: Tomcat started on port 19311 (http) with context path '/'
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19310/actuator/health/readiness
  {"status":"UP"} 200
  the raw servlet's init, before any request reached the container: 0 line(s)
$ curl -s http://127.0.0.1:19311/where
  thread http-nio-127.0.0.1-19311-exec-N · virtual false
  context class loader: org.springframework.boot.tomcat.TomcatEmbeddedWebappClassLoader < org.apache.catalina.loader.ParallelWebappClassLoader < org.apache.catalina.loader.WebappClassLoaderBase < java.net.URLClassLoader < java.security.SecureClassLoader
  its parent: jdk.internal.loader.ClassLoaders$AppClassLoader · the harness class's own loader: jdk.internal.loader.ClassLoaders$AppClassLoader
  the context loader hands back this very class: true
  frames the stack walker shows: 45
    from the method down to DispatcherServlet.doService: 9 - Where.where … DispatcherServlet.doService · their names' md5 1d6b9d043842a9768cbde38ad5994547
    below it: 36 - the servlet's own methods (FrameworkServlet, HttpServlet) 5 · Spring's filters 8 · Tomcat 22 · the JDK 1
    the last frame: java.lang.Thread.run
$ harness/paths.sh 19311 /raw /raw/menu/today /lunch.tiff /raw/lunch.tiff
  GET /raw             -> 200 text/plain;charset=ISO-8859-1  X-Raw-Filter: -  raw servlet: pattern=/raw match=EXACT
  GET /raw/menu/today  -> 200 text/plain;charset=ISO-8859-1  X-Raw-Filter: -  raw servlet: pattern=/raw/* match=PATH
  GET /lunch.tiff      -> 200 text/plain;charset=ISO-8859-1  X-Raw-Filter: -  raw servlet: pattern=*.tiff match=EXTENSION
  GET /raw/lunch.tiff  -> 200 text/plain;charset=ISO-8859-1  X-Raw-Filter: -  raw servlet: pattern=/raw/* match=PATH
  the four answers' bodies: md5 1d4d22fe4dc17f93264eb28499ba9af9 · their content type: text/plain;charset=ISO-8859-1
  the raw servlet's init: 1 line - thread http-nio-127.0.0.1-19311-exec-N
$ kill $pid
  exit 143 · listening on 19310 and 19311 now: 0 and 0
  Boot's lines while it stopped: Commencing graceful shutdown. Waiting for active requests to complete · Graceful shutdown complete
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - Jetty: its twin, one exclusion and one dependency more in tiffinbox-web/pom.xml, against the copy's (capture jars built it):
$ diff -U0 .harness/tc/tiffinbox-web/pom.xml .harness/jt/tiffinbox-web/pom.xml | sed 1,2d
  @@ -64,0 +65,6 @@
  +      <exclusions>
  +        <exclusion>
  +          <groupId>org.springframework.boot</groupId>
  +          <artifactId>spring-boot-starter-tomcat</artifactId>
  +        </exclusion>
  +      </exclusions>
  @@ -65,0 +72,4 @@
  +    <dependency>
  +      <groupId>org.springframework.boot</groupId>
  +      <artifactId>spring-boot-starter-jetty</artifactId>
  +    </dependency>
$ cd .harness/jt && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19310 --spring.main.sources=harness.RawServletConfig,harness.Where --server.address=127.0.0.1 --server.port=19311
  listens on: 127.0.0.1:19310 127.0.0.1:19311 - TiffinBox's own server, 19310, and the container, 19311
  TiffinBox's own line: TiffinBox listening on http://127.0.0.1:19310
  the container's own line, in the log once readiness answered: Jetty started on port 19311 (http/1.1) with context path '/'
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19310/actuator/health/readiness
  {"status":"UP"} 200
  the raw servlet's init, before any request reached the container: 1 line(s) - thread main
$ curl -s http://127.0.0.1:19311/where
  thread qtp<hash>-N · virtual false
  context class loader: org.eclipse.jetty.ee.webapp.WebAppClassLoader < java.net.URLClassLoader < java.security.SecureClassLoader
  its parent: jdk.internal.loader.ClassLoaders$AppClassLoader · the harness class's own loader: jdk.internal.loader.ClassLoaders$AppClassLoader
  the context loader hands back this very class: true
  frames the stack walker shows: 54
    from the method down to DispatcherServlet.doService: 9 - Where.where … DispatcherServlet.doService · their names' md5 1d6b9d043842a9768cbde38ad5994547
    below it: 45 - the servlet's own methods (FrameworkServlet, HttpServlet) 5 · Spring's filters 8 · Jetty 31 · the JDK 1
    the last frame: java.lang.Thread.run
$ harness/paths.sh 19311 /raw /raw/menu/today /lunch.tiff /raw/lunch.tiff
  GET /raw             -> 200 text/plain;charset=iso-8859-1  X-Raw-Filter: -  raw servlet: pattern=/raw match=EXACT
  GET /raw/menu/today  -> 200 text/plain;charset=iso-8859-1  X-Raw-Filter: -  raw servlet: pattern=/raw/* match=PATH
  GET /lunch.tiff      -> 200 text/plain;charset=iso-8859-1  X-Raw-Filter: -  raw servlet: pattern=*.tiff match=EXTENSION
  GET /raw/lunch.tiff  -> 200 text/plain;charset=iso-8859-1  X-Raw-Filter: -  raw servlet: pattern=/raw/* match=PATH
  the four answers' bodies: md5 1d4d22fe4dc17f93264eb28499ba9af9 · their content type: text/plain;charset=iso-8859-1
  the raw servlet's init: 1 line - thread main
$ kill $pid
  exit 143 · listening on 19310 and 19311 now: 0 and 0
  Boot's lines while it stopped: Commencing graceful shutdown. Waiting for active requests to complete · Graceful shutdown complete
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again:
$ cd .harness/tc && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19310 --spring.main.sources=harness.RawServletConfig,harness.Where --server.address=127.0.0.1 --server.port=19311
  listens on: 127.0.0.1:19310 127.0.0.1:19311 - TiffinBox's own server, 19310, and the container, 19311
  TiffinBox's own line: TiffinBox listening on http://127.0.0.1:19310
  the container's own line, in the log once readiness answered: Tomcat started on port 19311 (http) with context path '/'
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19310/actuator/health/readiness
  {"status":"UP"} 200
  the raw servlet's init, before any request reached the container: 0 line(s)
$ curl -s http://127.0.0.1:19311/where
  thread http-nio-127.0.0.1-19311-exec-N · virtual false
  context class loader: org.springframework.boot.tomcat.TomcatEmbeddedWebappClassLoader < org.apache.catalina.loader.ParallelWebappClassLoader < org.apache.catalina.loader.WebappClassLoaderBase < java.net.URLClassLoader < java.security.SecureClassLoader
  its parent: jdk.internal.loader.ClassLoaders$AppClassLoader · the harness class's own loader: jdk.internal.loader.ClassLoaders$AppClassLoader
  the context loader hands back this very class: true
  frames the stack walker shows: 45
    from the method down to DispatcherServlet.doService: 9 - Where.where … DispatcherServlet.doService · their names' md5 1d6b9d043842a9768cbde38ad5994547
    below it: 36 - the servlet's own methods (FrameworkServlet, HttpServlet) 5 · Spring's filters 8 · Tomcat 22 · the JDK 1
    the last frame: java.lang.Thread.run
$ harness/paths.sh 19311 /raw /raw/menu/today /lunch.tiff /raw/lunch.tiff
  GET /raw             -> 200 text/plain;charset=ISO-8859-1  X-Raw-Filter: -  raw servlet: pattern=/raw match=EXACT
  GET /raw/menu/today  -> 200 text/plain;charset=ISO-8859-1  X-Raw-Filter: -  raw servlet: pattern=/raw/* match=PATH
  GET /lunch.tiff      -> 200 text/plain;charset=ISO-8859-1  X-Raw-Filter: -  raw servlet: pattern=*.tiff match=EXTENSION
  GET /raw/lunch.tiff  -> 200 text/plain;charset=ISO-8859-1  X-Raw-Filter: -  raw servlet: pattern=/raw/* match=PATH
  the four answers' bodies: md5 1d4d22fe4dc17f93264eb28499ba9af9 · their content type: text/plain;charset=ISO-8859-1
  the raw servlet's init: 1 line - thread http-nio-127.0.0.1-19311-exec-N
$ kill $pid
  exit 143 · listening on 19310 and 19311 now: 0 and 0
  Boot's lines while it stopped: Commencing graceful shutdown. Waiting for active requests to complete · Graceful shutdown complete
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 6 · two — D and E (labelled): a second server keeps the JVM alive

**D** — the copy: TiffinBox's own server on 19314, Tomcat on 19315. Before POST /shutdown, **5** threads that are not daemons:
`Catalina-utility-1` and `-2` (Tomcat's `TaskThread`s), `DestroyJavaVM` (the thread `main` ran on, waiting for the rest),
`HTTP-Dispatcher` (TiffinBox's own server) and **`container-0` — a `org.springframework.boot.tomcat.TomcatWebServer$1`: Boot's**.
The seven against TiffinBox's own server (`115c36ba…`, POST /shutdown last): TiffinBox's server stops (19314 closes). **2 s later
the JVM is still running, listening on 127.0.0.1:19315 alone, and 4 threads that are not daemons are left** — the dispatcher gone,
Boot's `container-0` and Tomcat's two utility threads still there. Stopped by its pid (SIGTERM): Boot's two graceful-shutdown
lines, exit 143, both ports free. **E** — the same on Jetty (19316 / 19317): alive 2 s later on 19317, held by Jetty's scheduler
and its **8** pool threads (`qtp<hash>-N` ×7 and its acceptor); exit 143. What stops the JVM once Tomcat is TiffinBox's only
server: *Embedded Tomcat, Threads and Connectors* (ledger C6-15, its other half).

`.r-two.out` · md5 `9dda9b961e2f89daecb7eba9401e7f93` · 3 of 3

```
D (labelled) - two servers in one JVM: the copy, TiffinBox's own server on 19314, Tomcat on 19315; the harness's route joined
(GET /threads: every live thread that is not a daemon - a JVM keeps running while one is left):
$ cd .harness/tc && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19314 --spring.main.sources=harness.Where --server.address=127.0.0.1 --server.port=19315
  listens on: 127.0.0.1:19314 127.0.0.1:19315 - TiffinBox's own server, 19314, and the container, 19315
  TiffinBox's own line: TiffinBox listening on http://127.0.0.1:19314
  the container's own line, in the log once readiness answered: Tomcat started on port 19315 (http) with context path '/'
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19314/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19315/threads
  non-daemon threads 5:
    Catalina-utility-1 - a org.apache.tomcat.util.threads.TaskThread
    Catalina-utility-2 - a org.apache.tomcat.util.threads.TaskThread
    DestroyJavaVM - a java.lang.Thread
    HTTP-Dispatcher - a java.lang.Thread
    container-0 - a org.springframework.boot.tomcat.TomcatWebServer$1
$ $CURLSET 19314 .harness/tc/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  2 s after POST /shutdown - still running: yes · listening on: 127.0.0.1:19315
$ curl -s http://127.0.0.1:19315/threads
  non-daemon threads 4:
    Catalina-utility-1 - a org.apache.tomcat.util.threads.TaskThread
    Catalina-utility-2 - a org.apache.tomcat.util.threads.TaskThread
    DestroyJavaVM - a java.lang.Thread
    container-0 - a org.springframework.boot.tomcat.TomcatWebServer$1
$ kill $pid
  exit 143 · listening on 19314 and 19315 now: 0 and 0
  Boot's lines while it stopped: Commencing graceful shutdown. Waiting for active requests to complete · Graceful shutdown complete
  its log: the demo token 0 times · X-Shutdown-Token 0 times
E (labelled) - the same on Jetty: its twin, TiffinBox's own server on 19316, Jetty on 19317:
$ cd .harness/jt && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19316 --spring.main.sources=harness.Where --server.address=127.0.0.1 --server.port=19317
  listens on: 127.0.0.1:19316 127.0.0.1:19317 - TiffinBox's own server, 19316, and the container, 19317
  TiffinBox's own line: TiffinBox listening on http://127.0.0.1:19316
  the container's own line, in the log once readiness answered: Jetty started on port 19317 (http/1.1) with context path '/'
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19316/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s http://127.0.0.1:19317/threads
  non-daemon threads 11:
    DestroyJavaVM - a java.lang.Thread
    HTTP-Dispatcher - a java.lang.Thread
    Scheduler-<hash>-1 - a java.lang.Thread
    qtp<hash>-N - a java.lang.Thread  x7
    qtp<hash>-N-acceptor-0@<hash>-oejs.ServerConnector@<hash>{HTTP/1.1, (http/1.1)}{127.0.0.1:19317} - a java.lang.Thread
$ $CURLSET 19316 .harness/jt/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  2 s after POST /shutdown - still running: yes · listening on: 127.0.0.1:19317
$ curl -s http://127.0.0.1:19317/threads
  non-daemon threads 10:
    DestroyJavaVM - a java.lang.Thread
    Scheduler-<hash>-1 - a java.lang.Thread
    qtp<hash>-N - a java.lang.Thread  x7
    qtp<hash>-N-acceptor-0@<hash>-oejs.ServerConnector@<hash>{HTTP/1.1, (http/1.1)}{127.0.0.1:19317} - a java.lang.Thread
$ kill $pid
  exit 143 · listening on 19316 and 19317 now: 0 and 0
  Boot's lines while it stopped: Commencing graceful shutdown. Waiting for active requests to complete · Graceful shutdown complete
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 7 · undertow — C (labelled): the third server Boot 3 offered

`harness/undertow/pom.xml` names `spring-boot-starter-undertow` on Boot 4.1.1's parent, the version left to the parent, as for every
starter: **`mvn -o validate` → exit 1, `'dependencies.dependency.version' for org.springframework.boot:spring-boot-starter-undertow:jar
is missing.`** Boot's own lists of the versions it manages, copied by `harness/boms/pom.xml`: **3.5.16's BOM mentions Undertow on 11
lines (its starter on 1); 4.1.1's on 0**. Jetty's starter is in both (ledger C6-20, measured twice; contract R.84).

`.r-undertow.out` · md5 `17b6bf1d11087e62f27a964b1991eee1` · 3 of 3

```
C (labelled) - Undertow, asked for the way Boot 3's parent offered it: harness/undertow/pom.xml names its starter on Boot
4.1.1's parent, the version left to the parent:
$ cd .harness/undertow && mvn -o -B -Dmaven.repo.local="$M2" validate
  exit 1
  [ERROR] 'dependencies.dependency.version' for org.springframework.boot:spring-boot-starter-undertow:jar is missing. @ line 24, column 17
Boot's own lists of the versions it manages - its BOM, spring-boot-dependencies - as the last Boot 3 shipped it and as Boot
4.1.1 ships it (harness/boms/pom.xml copies the two files into .harness/boms/target/boms):
$ cd .harness/boms && mvn -o -B -Dmaven.repo.local="$M2" validate
  built the two BOMs' copy · offline: yes · exit 0
  spring-boot-dependencies-3.5.16.pom: lines that mention undertow, in any case: 11 · that name spring-boot-starter-undertow: 1 · that name spring-boot-starter-jetty: 1
  spring-boot-dependencies-4.1.1.pom: lines that mention undertow, in any case: 0 · that name spring-boot-starter-undertow: 0 · that name spring-boot-starter-jetty: 1
```


## 8 · exercise — the exercise, run as written

`exercise/README.md`'s setup and its try line, exactly as written (the registration shipped broken: `/lunch.menu` → the
`DispatcherServlet`, 404), then `exercise/solution/SOLUTION.md`'s line: `/lunch.menu` → `pattern=*.menu match=EXTENSION`,
`/raw/lunch.menu` → `pattern=/raw/* match=PATH` (brief RE-MEASURE 11).

`.r-exercise.out` · md5 `f9b2a9ad88feb63de7786dad7d946aa6` · 3 of 3

```
exercise/README.md's setup, run exactly as written from this folder - 6 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/ && (cd .harness/mine && patch -s -p1 < ../../harness/mvc.patch)
  $ mkdir -p .harness/mine/secrets/tiffinbox && chmod 700 .harness/mine/secrets .harness/mine/secrets/tiffinbox
  $ (umask 077 && LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26 > .harness/mine/secrets/tiffinbox/shutdown-token)
  $ M="$PWD/.m2-demo" && (cd .harness/mine && mvn -o -B -q -Dmaven.repo.local="$M" -DskipTests package && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null)
  exit 0 · printed: 0 line(s) · the token file: 26 characters, mode 600
its try line, as shipped - the registration lists /raw and /raw/* only:
$ exercise/try.sh exercise/RawServletConfig.java /lunch.menu /raw/lunch.menu
  GET /lunch.menu      -> 404 application/json  X-Raw-Filter: -  {"timestamp":"<time>","status":404,"error":"Not Found","path":"/lunch.menu"}
  GET /raw/lunch.menu  -> 200 text/plain;charset=ISO-8859-1  X-Raw-Filter: -  raw servlet: pattern=/raw/* match=PATH
  listening on 19318 and 19319 now: 0 and 0
the solution's line (exercise/solution/SOLUTION.md), run exactly as written, from this folder:
$ exercise/try.sh exercise/solution/RawServletConfig.java /lunch.menu /raw/lunch.menu
  GET /lunch.menu      -> 200 text/plain;charset=ISO-8859-1  X-Raw-Filter: -  raw servlet: pattern=*.menu match=EXTENSION
  GET /raw/lunch.menu  -> 200 text/plain;charset=ISO-8859-1  X-Raw-Filter: -  raw servlet: pattern=/raw/* match=PATH
  listening on 19318 and 19319 now: 0 and 0
  its log (.harness/mine/run.log, the last run's): the exercise's own token 0 times · X-Shutdown-Token 0 times
```


## Exercise

`exercise/README.md`: register the raw servlet on `*.menu` as well, then request `/lunch.menu` and `/raw/lunch.menu`. It ships
broken (`exercise/RawServletConfig.java` lists `/raw` and `/raw/*` only); `exercise/try.sh CONFIG PATH…` compiles the raw servlet
with the registration you name, runs the copy in `.harness/mine` (TiffinBox 19318, Tomcat 19319, both on `127.0.0.1`), asks Tomcat,
and stops the JVM by its pid. The measured answer, run exactly as written: `exercise/solution/`. Run `./receipts.sh` once first on a
fresh clone (it fills `.m2-demo`).

## The ledger rows this unit pays, and the brief's RE-MEASURE items it settles

- **C6-15** — the why: a second server's threads that are not daemons keep the JVM running after TiffinBox's POST /shutdown
  (`two` D, and E on Jetty); `container-0` named, and whose it is (Boot's). The "only server" half → *Embedded Tomcat, Threads and
  Connectors*.
- **C6-17** — Tomcat ↔ Jetty measured (`jars`, `swap`, `two` E); WebFlux and Netty named once as the reactive stack, Course 12's
  (*Reactive Spring*), on camera — the correction of Course 5's live Actuator slide (21-slides:124) the brief recommends. No
  correction comment is posted on that video: Vivek's call (brief §BLOCKED 2).
- **C6-20** — Undertow's exit, measured twice (`undertow`: the starter exit 1; the BOM 11 → 0).
- **C6-29** — the request thread's context class loader on both containers, the same class handed back (`swap`).
- **X4** — Spring MVC's starter alone: 39 jars, on Boot 4.1.1 (`jars`).
- **RE-MEASURE 1** — Jetty beside the JDK server: the JVM lives after POST /shutdown, held by Jetty's pool threads and its scheduler
  (`two` E). **2** — the raw servlet and filter on the two-server copy (`servlet`, `filter`, `life`). **11** — the exercise with
  `*.menu` (`exercise`). **3** — the `java -jar` loader: not spoken, not measured.

## Found on the way

- **Jetty initialises servlets at startup; Tomcat at their first request.** The brief (from the probe, on Tomcat) said "init runs
  once, at the first request, on a request thread". Measured on both: Tomcat ran the raw servlet's `init` — and the
  `DispatcherServlet`'s, `Initializing Servlet 'dispatcherServlet'` — at the first request; Jetty ran both on `main`, before
  `Jetty started`. So the voice says "Tomcat waited", "Jetty ran it at startup", never a rule (`swap`).
- **"The same answers, byte for byte" holds for the bodies, not the headers.** The raw servlet sets `text/plain` and no charset,
  and each container appends one: `text/plain;charset=ISO-8859-1` (Tomcat), `text/plain;charset=iso-8859-1` (Jetty). The bodies'
  md5 is the same (`swap`); the voice says the charset is the same, spelled in another case.
- **Jetty's stack depth moves with the request.** With the raw filter in the path, `GET /where` showed 57 frames on the first
  five requests a fresh Jetty served and 63 from the sixth on — six more frames: Jetty's `AdaptiveExecutionStrategy` running the
  request on a `ReservedThreadExecutor` thread. Measured on seven starts: five with readiness polled on TiffinBox's own server
  (eight `/where` each: 57 ×5, then 63 ×3) and two with one readiness request to Jetty first (fifteen `/where` each: 57 ×4, then
  63 ×11). Tomcat showed 47 on all 30 of 30, in two starts. So `swap` asks `/where` as the container's first request (readiness is polled on TiffinBox's own server, never on the
  container), and Jetty's 54 is its first request's, said so on a chip; the 63 is not on camera.
- **`container-0` is Boot's, not Tomcat's.** The brief named it among "Tomcat's" threads. The class of its `Thread` object is
  `org.springframework.boot.tomcat.TomcatWebServer$1` — Boot's Tomcat web server made it, not a daemon; the two `Catalina-utility`
  threads are Tomcat's (`TaskThread`). Jetty has no such thread: its own pool threads are not daemons (`two` E).
- **A thread's name can hold a space.** `GET /threads` first joined the names with spaces, and Jetty's acceptor is named
  `qtp…-acceptor-0@…-oejs.ServerConnector@…{HTTP/1.1, (http/1.1)}{127.0.0.1:19317}`: the list split it in two. It now answers one
  thread per line.
- **Readiness is polled on TiffinBox's own server.** Polling the container (brief S1.13) sends it a varying number of requests
  before the first one a capture shows (each a line from the raw filter, and on Jetty a step towards the deeper stack above).
  TiffinBox's own readiness answers 200 only once the start has finished, after the container started: each run checks that the
  container's `… started on port …` line is already in the log at that moment, and asserts the addresses its JVM listens on.
- **Every check this unit adds was shown failing once on a planted fault** (R.65, S1.19), on scratch copies — no port bound, no
  JVM started unless named — 21 of 21 caught: the run's token in a capture; Spring's timestamp unmasked; a request thread's number unmasked; A′
  differing from A; the top's names differing between Tomcat and Jetty; the four bodies differing; a container started without
  `--server.address=127.0.0.1`; a star in an exposure list; the exercise's Done line naming no line of the capture; the survivor
  gone after POST /shutdown; `container-0`'s class; a frame count moved; an absolute path in a capture; the frozen trees differing
  (one byte added to a copy of the anchor's README); and, lifted out of `receipts.sh` as written: `loopback()` given
  `*:19311 127.0.0.1:19310` and given `127.0.0.1:19310` alone; `mask()` given an ISO and an epoch timestamp, a thread number, a
  `qtp`, a scheduler and an identity hash, and the token (each masked); `cap()` given a published md5 that differs (it prints
  `DIFFERS`, then stops) and a capture that drifts; the variable loop with a basic `sed` (no alternation: every canary survives,
  the run stops); and `up()` given a run whose container never started (the copy run with `--spring.main.web-application-type=none`
  on 19310: TiffinBox's own readiness answered 200, and no `Tomcat started` line was in the log), stopped by its pid afterwards.
- **A test of the tests went wrong once, harmlessly.** The first planted-function test lifted each function with a `sed` range
  whose end used `\|` — which macOS's `sed` does not read as alternation in a basic expression — so it lifted the rest of the
  script too, and ran it in a scratch folder: nothing was built, copied or started (every function it needed was defined before
  the lifted part). The functions are now lifted by exact start and end lines, and the lifted text is checked to hold no
  top-level command.

## Interrupted

**Tested 2026-10-12 on the final script, twice**, with `receipts.sh` as a job of its own process group (job control on, as a
terminal's foreground job is) and `SIGINT` sent to the whole group: **(1) during `jars`' Maven build**, 24 s in (in the group: the
script, its subshell and Maven's JVM) — **exit 130**; 5 s later 0 processes in the group, and anywhere 0 processes whose command
names this unit's folder; 18425, 8080 and 19310-19319 free; `.r-lock` gone; no unfinished capture file (`.r-*.1-3`); every published
capture unchanged. **(2) during `swap`**, 160 s in, while A's JVM listened on 19310 and 19311 (in the group: the script, that JVM and
a `curl`) — **exit 130**, and the same: nothing left, every port free, no lock, no partial capture, the published captures
unchanged. (An earlier try of (2), 187 s in, gave the same result; its process listing was taken twice, a moment apart, and counted
8 then listed 3 — `curl`, `sleep` and `lsof` come and go — so the listing above is one look, counted from itself.)
