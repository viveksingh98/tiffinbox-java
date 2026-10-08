# c5-unit21 — Actuator: Endpoints and What They Cost

Course 5 · Spring Boot · Section 4, its first unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1, GraalVM CE
25.3.4.1** (native-image 25.0.4.1), 2026-10-07. Boot's Actuator is endpoints — small reports on a running application — and its
starter, added to TiffinBox, reaches nothing: to Boot, TiffinBox is no web application (its server is the JDK's own), so Boot's HTTP
side of Actuator never starts, and JMX is off. This unit counts what the starter brings, reads Boot's own reasons in its condition
report, measures the two ways out Boot offers (JMX; Spring MVC on Tomcat), puts Boot's endpoints on TiffinBox's own server with one
class of Boot's parts, serves them on the JVM, under Spring's AOT step and in the native binary — after fixing the AOT step's view of
the class path, which the new dependency broke — breaks the exposure list on purpose, and reads what each endpoint hands to whoever
can reach it, down to the shutdown token inside a heap dump.

**The anchor changes (brief ⚑1-⚑3):**
- `tiffinbox-web/pom.xml`: **`spring-boot-starter-actuator`**; and in Boot's plugin, **three `<excludes>`** —
  `org.springframework.boot:spring-boot-docker-compose`, `tools.jackson.core:jackson-databind`, `tools.jackson.core:jackson-core` —
  the jars the native plugin's exclusions keep out of the binary since the hints lesson, now kept out of Spring's AOT step too (⚑2).
- `tiffinbox-web/src/main/java/com/tiffinbox/web/ActuatorRoutes.java` (**new**, 189 lines with its imports and comments): Boot's own
  `WebEndpointDiscoverer` as a bean, through two filters — exposure (`management.endpoints.web.exposure.*`, `health` unless told
  otherwise) and access (`management.endpoint.<id>.access`, `OperationFilter.byAccess`); Boot's `HealthEndpointWebExtension`, guarded
  by `@ConditionalOnAvailableEndpoint`; and an `HttpHandler` that matches each request's path and verb to an operation, gathers its
  arguments as Spring MVC's adapter does — the path's variables, a write's JSON body (`415` without a JSON `Content-Type`, `400` when
  it is empty or no JSON object), then the query string (one value a String, several a list) — passes the `Accept` header, invokes
  it, and writes the answer with TiffinBox's own Jackson 2, in the type asked for — 400 for an argument Boot can't map, 404 for a path
  no operation has, 405 for a known path with another verb, 500 for an `Exception` or a `LinkageError` (⚑1; the request handling is
  RED C5-S4 #2, #4 and #46's fix, made here in 2026-10-08's revision and carried unchanged into every later tree).
- `TiffinBoxServer.java`: one constructor parameter (`HttpHandler actuator`), its field and assignment, and
  `server.createContext("/actuator", actuator)` — plus a Javadoc paragraph. The seven routes and the stop are unchanged.
- `application.yaml`: `management.endpoints.web.exposure.include: health`, with a comment — Boot's default, written down; under AOT
  and in the binary, this line is what they expose (⚑3).
- `.gitignore` (the anchor's): `*.hprof` — a heap dump holds the shutdown token (`tour`), so none is ever committed. Not in the
  brief's list: added because the anchor README now shows how to take one.
- **`TiffinBoxApp.java` is not edited** (`change`: byte for byte the same), so RED S2 #8 stays deferred (⚑11).

When this unit was made, `c5-tiffinbox` and this unit's `after/` held the change and the anchor README's new section, and nothing
else; the anchor has moved on since — it is unit 26's `after/` now. **Units 22 and 25 start from `after/`** (see the last section).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 11 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) It runs for 12 to 14 minutes on a quiet Mac, longer under load. **This revision's runs of record (2026-10-08, RED C5-S4 part A's fixes), the Mac otherwise quiet:** **807 s under `./receipts.sh`** (/bin/bash 3.2.57, in place, exit 0) and **769 s under `bash receipts.sh`** (Homebrew bash 5.3.9, from a sealed clone, exit 0 — "From a clone", below), every capture 3/3 and = published, the start's band judged in 3 of 3 captures in each (9 · start), the native builds 131-138 s. The six hashes that moved (`ways`, `change`, `aot`, `tour`, `start`, `native`) were published from a 3.2 run under the load of three other units' receipts (3,104 s, load 290-400; the load gate refused the band in 3 of 3, as designed, and `start` still hashed as the quiet runs did), every capture 3/3; an earlier run as heavily loaded printed the same hashes for the five it printed. The first revision's runs of record, 2026-10-07: 732 s (5.3) and 824 s (3.2).
It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first, so you can see which one moved).
Published hashes: cost `dd1a71a025aa1571b83c3d47cff049e1` · why `ec2878bb84cc567e3cf203ad88dd3e33` · ways `21bc5a1d5afd3b939526a303e5d01a95` · change `c1943610299f2d4031a86a3d1df890cf` · serve `aa7baf0abced50c67d59d4cf87a7cb8e` · aot `18ee0a7447caa0fcc0a41e68661833ef` · exposure `6a49363e956dec88b50495dfe1c43d50` · tour `eabfff26723fa7ad719a781ec9bffde0` · start `b0894b7d49ae387463ad525543620fe6` · native `35c9f010689cb93adb7bc28e5e075322` · exercise `c7fe11d598cbde47a071c473a226b896`

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else. It refuses a variable that does not name a
`bin/native-image`, and one whose `native-image --version` is not `native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1` — another
GraalVM prints other lines, so the captures could not match. The GraalVM's folder is never printed: every capture masks it as
`$GRAALVM_HOME`. Only `native` needs it: every Maven run and every `java` here is the plain JDK 25.0.4.1.

**Without a GraalVM** (`GRAALVM_HOME` not set): `receipts.sh` still runs. It fills `.m2-demo` (its first build), makes every
capture but `native` — `cost`, `why`, `ways`, `change`, `serve`, `aot`, `exposure`, `tour`, `start` — and the exercise's, each
checked against `receipts.md5`, then stops where the native build would start, naming this section (exit 1).

## The repository, and what was downloaded

Every build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen): `../c5-unit20/.m2-demo`, then
`../../spring-boot/_research/m2-seed-s4/` added (`rsync -a --ignore-existing`: Actuator 4.1.1 and its parts, Micrometer 1.17.1, the
Prometheus client, DevTools — the 40 files Section 4's probes took from Maven Central on 2026-10-06), **less `com/tiffinbox/`** (every
native build installs its own two modules first): 5,418 files before this unit's own installs. **Nothing was downloaded** for this unit: every build said `offline:
yes`, the native-profile ones included. Spring MVC and Tomcat, for `ways`' copy, were already in the seed.

**One way out is not Maven's.** GraalVM's native plugin reads its metadata repository (a zip,
`graalvm-reachability-metadata-1.1.8-repository.zip`, 3,362,517 bytes, from Maven Central) from the Maven repository — and when the
zip is not there it does not fail, even under `-o`: it downloads one from GitHub. So (1) the first build is the README's native
install, which needs nearly every artifact any capture's Maven line needs, the zip included — on a fresh clone it fills `.m2-demo`
from Maven Central, once — and a second build before the captures (`.harness/fill`: the previous tree with Actuator's and Spring
MVC's starters) fetches what only `ways` builds, Tomcat and Spring's web jars, so that every build inside a capture says `offline:
yes`; (2) a native-profile build while the zip is not in `.m2-demo` goes to Maven Central at once, never offline first;
(3) after the first build the script checks Boot's parent POM, Actuator 4.1.1, the native plugin 1.1.8 and the zip are in `$M2`; (4)
every build's log is searched for the plugin's own download line — found, the build's line says `offline: no` and the run stops.

**From a clone, sealed — this revision (2026-10-08, RED C5-S4 part A's fixes; brief S4.2).** The repository was cloned (`git clone`
of its HEAD) into an empty folder, and the seven folders this revision changes — `c5-unit21` to `c5-unit26` and `c5-tiffinbox` — put
in exactly as the commit holds them (212 files, nothing git ignores: no `.m2-demo`, no `.harness/`, no `.r-*` anywhere; `README.md`
is the only file of this unit's folder changed since, by this paragraph, the run-times note and 9 · start's band; the
other folders' later changes touch nothing this run reads). `bash receipts.sh` (Homebrew bash
5.3.9) ran under `env -i`, with a `HOME` whose `.mavenrc` points Maven's `user.home` there (Java reads `user.home` from the account,
not from `$HOME`) and every Java proxy property at a port that refuses (127.0.0.1:9), and whose Maven settings send every repository
to a `file://` copy of Central's files made from the units' `.m2-demo` (4,060 files: TiffinBox's own installs, `_remote.repositories`,
`*.lastUpdated`, `resolver-status.properties` and `.DS_Store` left out, `maven-metadata-central.xml` served as `maven-metadata.xml`);
`http_proxy`, `https_proxy`, their capitals and `ALL_PROXY` at the same refusing port; `GRAALVM_HOME` set. **Exit 0 after 769 s** — all
11 captures = published, every spoken number asserted, 0 raw demo tokens, the start's band judged in 3 of 3. Two builds said
`offline: no` — the first (GraalVM's metadata repository was not in the empty `.m2-demo`) and the fill build (Spring MVC's and Tomcat's
jars) — and between them took 516 files, every one from the `file://` copy, 0 from anywhere else; every later build said `offline:
yes`; `.m2-demo` ended with 1,398 files; the build logs hold 0 `https://repo` lines and 0 lines of the native plugin's metadata
download. **The first revision's clone test (2026-10-07) was not sealed:** its `HOME` held Maven settings and no `.mavenrc`, so Maven
read the account's settings (RED C5-S4 #9 measured it: `Reading user settings from` the account's home) and went to Maven Central
itself. Two clone runs before that one had failed; both causes are fixed in this script (Found on the way): the proxy took curl's
requests for 127.0.0.1, and macOS adds a variable to the JVM's environment.

## The demo token — fake, and never printed; the heap dump

TiffinBox does not start without its shutdown token. Every run starts in a folder under `.harness/` holding a config tree,
`secrets/tiffinbox/shutdown-token` (`-rw-------`, folders `drwx------`), with a 26-character demo token that is fake and looks it;
`receipts.sh` writes it when it runs. The token never reaches a command line: the seven requests and `harness/ttfr.py` read it from
the file. Every capture is masked — the token becomes `[masked: the 26-character token]` — and `receipts.sh` counts the raw token in
each run's own output **before** masking (`.harness/raw-*`: 0 in all 33 capture runs), then in every capture, this README, the
exercise, the harness, `receipts.md5`, the anchor README and `application.yaml`, and in the **bytes of the binary** each run builds:
0 each. The builder counts it again in the script, the deck and the prompter: 0.

Two answers here hold the token, and neither is ever printed: the heap dump (`tour`) and env's answer under
`--management.endpoint.env.show-values=always` (`tour`). Each is written beside its config tree under `.harness/`, read by a named
method — `grep -a -o` counts copies, `grep -c -a -F` counts lines — and deleted in the same step; the exit trap deletes both names
again, and the last checks fail if either is left. The exercise makes a random token of its own, which it never prints either.

## The folders, the variables and the ports

- `.harness/before/` — the previous tree, `../c5-unit20/after`, copied; `.harness/after/` — `after/` copied and built with the
  README's native install (the run's first build), extracted: the class path the harness compiles against (`.harness/hc`);
  `.harness/fill/` — the second build before the captures (the previous tree with both starters), only to fill `.m2-demo`.
- `cost`: `.harness/cost-prev/` (the previous tree) and `.harness/cost-a1/` (the previous tree plus the starter, one `perl` line);
  `why`, `ways`' JMX runs and `start` reuse them. `ways`: `.harness/ways-mvc/` (the previous tree plus the starter and Spring MVC's).
  `serve`: `.harness/serve/` (after/, built the README's plain way); `exposure`, `tour` and `start` reuse its jar. `aot`:
  `.harness/aot-b/` (after/ without Boot's plugin's configuration) and `.harness/aot-a/` (after/), each `-Pnative package`. `native`:
  `.harness/nat/`. The exercise: `.harness/mine/`.
- On screen: `$CURLSET` = `../c5-unit11/curlset.sh`, the comparison set since the secrets lesson; `$M2` = this unit's `.m2-demo`;
  `$GRAALVM_HOME` = the GraalVM; `$pid` = the process the script started (the Tomcat copy's `kill`). Every other command is printed
  whole.
- Ports (brief ⚑10, 19000-19009, checked free with `lsof` before anything is wiped; 18425 and 8080 too): `cost` 19000 (the previous
  tree), 19001 (with the starter) · `why` 19001 · `ways` 19002 (JMX), 19003 (the Tomcat copy's TiffinBox), 19004 (its Tomcat, on
  127.0.0.1) · `serve` 19005 · `aot` 19006 · `exposure` 19005 · `tour` 19007 · `start` 19008 · `native` 19006 · the exercise 19009.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM and the token** (`gsub()`, the patterns escaped as literals), in every line of every capture: the demo token
   → `[masked: the 26-character token]`; the GraalVM's folder → `$GRAALVM_HOME`; this folder's absolute path → `…` (also
   URL-encoded); the folder above it → `…/..`; the home folder → `~`; the user name → `<user>`. A last check fails if any capture
   still holds `/Users/`, `/private/`, `/home/` or `/var/folders/`, the GraalVM's folder, or a unit number.
2. **Boot's log** is counted, never printed whole: its first line from its message on, cut before ` with PID`. A start that fails
   prints the exception Boot's `Application run failed` line names and every `Caused by:` line under it, in order, each cut after the
   bean or the factory method it names, with the log's lines between them counted; then Boot's failure-analysis banner, counted
   (`APPLICATION FAILED TO START`), and the stack frames, counted (lines starting `at `) — never the line total (S4.19).
3. **The condition report** (`why`): its header and the four blocks named, each whole, in the report's order, every gap counted.
4. **The harness's own listener** (`harness/inspect/harness/Inspect.java`, package `harness`, joined with
   `--spring.main.sources=harness.Inspect` to the extracted jar's exploded run — TiffinBox's own main) prints names and counts only:
   Boot's kind of application, the bean definitions (its own left out), the auto-configuration classes registered out of the
   candidates Boot's imports files list (the candidates that became bean definitions), the endpoint beans by id, the
   `EndpointsSupplier` beans, Boot's MBeans; over JMX, the names in health's answer — never a value (health's details hold disk sizes
   and an absolute path).
5. **Actuator's answers** (`tour`) are saved under `.harness/serve/`, read as JSON (`python3`), counted and deleted: beans (how many,
   their named dependencies, how many name the jar's absolute path — never which), conditions (positive, negative, unconditional),
   env (its property sources by name — the config tree and `application.yaml` by label — and each one's key count; for
   `systemEnvironment` only whether its names are the run's own, against `env -0` from the same folder, the shell's `_` and macOS's
   `__CF_USER_TEXT_ENCODING` aside; the
   values that are not `******`, and the raw token in the answer), mappings (whole, keys sorted), metrics (names under `tiffinbox.`,
   and the first part of every name — never a value), threaddump (TiffinBox's `HTTP-Dispatcher` among the threads — never a stack).
   Sizes are judged against a floor (`over 40,000 bytes`) — never in a capture; the terminal shows them (S4.9).
6. **Maven's and native-image's logs** are read, never printed whole: each build's `offline`/`exit` line; native-image's goal, the
   GraalVM it found, the builder's Java, its three warnings (the file URL cut), the eight stage names, the warning count and `BUILD
   SUCCESS`, the rest counted; every log searched for the plugin's metadata-repository download line.
7. **No duration is captured**: native builds are judged against a bound (1 minute or more, under 20 minutes — the brief's ERRATA,
   RED C5-S4 #8); `start` prints the reference's median against a floor; the other two medians' ratios to it, and the seconds, go to
   the terminal, and the band the voice states is judged there behind a load gate (9 · start).
8. **Hygiene:** `receipts.sh` unsets every `TIFFINBOX_*`, `SPRING_*`, `MANAGEMENT_*`, `SERVER_*` and `LOGGING_*` variable, `DEBUG`,
   `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`, `_JAVA_OPTIONS`, `MAVEN_OPTS`, `MAVEN_ARGS` and `NATIVE_IMAGE_OPTIONS` before it runs anything
   (a `MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE` of yours would otherwise widen the list); it puts `127.0.0.1` and `localhost` first
   in `no_proxy` and `NO_PROXY` (every request it makes goes to `127.0.0.1`; an `http_proxy` of yours would otherwise receive curl's
   requests instead of TiffinBox); it refuses to run twice at once in this folder (`.r-lock`), with a `secrets/` in this folder, or
   with a `secrets/`, a `tiffinbox-local.yaml` or a `target/` in `after/`.
   **S4.16:** a last check greps this script, this README, the anchor's and the exercise's for an exposure list with a star and fails
   on any line that neither excludes configprops nor is the break's own command.

**Interrupted.** `receipts.sh`'s exit trap stops the process it started in the background (a TiffinBox jar, exploded run
or binary), if one still runs, then `sweep()`s this run's process group for anything of this run — a TiffinBox JVM (its jar or the
extracted class path), a binary, native-image's driver or its builder JVM (`java @…/vminvocation.args`: no class name to look for),
the clock — TERM, then KILL after 5 s; then it deletes a heap dump or an `always` env answer if one is there, and, after an interrupt
only, the capture runs left unfinished (`.r-NAME.1-3`; after a failed check they stay, for the diff the message names); then it drops
the lock. Maven, native-image and `harness/ttfr.py` run in the foreground: Ctrl-C reaches them directly. Every command in the trap is
guarded, so `set -e` cannot end it early. **Tested 2026-10-07, twice**, with `receipts.sh` as a job of its own process group (job
control on, as a terminal's foreground job is) and `SIGINT` sent to the whole group: **(1) during `cost`**, 30 s in, while the copy with the starter ran exploded with the harness (in the group: 3 processes, one of them that TiffinBox JVM) — **exit 130**; 5 s later 0 processes in the group, and anywhere 0 TiffinBox JVMs, binaries, native-image processes, Maven runs or clocks; 18425, 8080 and 19000-19009 free; `.r-lock` gone; no heap dump, no env answer and no unfinished capture file left; **(2) during the native build**, 391 s in, 20 s after native-image's builder JVM appeared (in the group: 5 processes — Maven, the native-image driver and its builder among them) — **exit 130**; 5 s later 0 processes in the group, and anywhere 0 TiffinBox JVMs, binaries, native-image processes, Maven runs or clocks; the ports free; `.r-lock` gone; no heap dump, no env answer and no unfinished capture file left — and the captures made before the interrupt still equal to `receipts.md5`.

## 1 · cost — the starter, counted

The previous tree, and a copy with one line more in `tiffinbox-web/pom.xml` — Actuator's starter, inserted by the `perl` shown —
each built the README's plain way; their executable jars compared (the names under `BOOT-INF/lib`, the bytes, the imports files of
the extracted jars); then each extracted jar run exploded, as the README runs it (TiffinBox's own main), with the harness's listener
joined: what Boot built. With the starter, `/actuator/health` is asked: TiffinBox's own server answers, `No context found for
request`. Both runs end with the seven. **The starter reaches nothing**: 0 `EndpointsSupplier` beans (the beans that hand endpoints
to an adapter — Boot's web discoverer, its JMX discoverer), 0 MBeans, one address.

`.r-cost.out` · md5 `dd1a71a025aa1571b83c3d47cff049e1` · 3 of 3

```
the previous tree - the anchor as the hints lesson left it - and a copy of it with one dependency more, Actuator's starter;
each built the README's plain way, offline:
$ cd .harness/cost-prev && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the previous tree · offline: yes · exit 0
$ perl -0pi -e 's|\n  </dependencies>|\n    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-actuator</artifactId></dependency>\n  </dependencies>|' .harness/cost-a1/tiffinbox-web/pom.xml
  lines added: 1
$ cd .harness/cost-a1 && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the previous tree plus the starter · offline: yes · exit 0
the two executable jars:
  jars under BOOT-INF/lib: 31 and 39 · only in the first: 0 · only in the second: 8 -
    HdrHistogram-2.2.2.jar micrometer-core-1.17.1.jar micrometer-jakarta9-1.17.1.jar spring-boot-actuator-4.1.1.jar spring-boot-actuator-autoconfigure-4.1.1.jar spring-boot-health-4.1.1.jar spring-boot-micrometer-metrics-4.1.1.jar spring-boot-micrometer-observation-4.1.1.jar
  bytes: 16135694 and 18215046 · added: 2079352
  each extracted (the README's extract): the jars that hold an auto-configuration imports file, and the candidates they list - 2 jars, 13 candidates · 6 jars, 74 candidates
each run exploded, as the README runs the extracted jar - TiffinBox's own main - with the harness's own listener joined
(--spring.main.sources=harness.Inspect: harness/inspect/harness/Inspect.java, not TiffinBox's). The previous tree, port 19000:
$ cd .harness/cost-prev && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19000 --spring.main.sources=harness.Inspect
  harness: Boot's kind of application: NONE · the context: AnnotationConfigApplicationContext
  harness: bean definitions, this harness's own left out: 59
  harness: auto-configuration classes registered: 10 of the 13 candidates - the rest 10
  harness: endpoint beans: 0 - no Actuator on this class path
  harness: Boot's MBeans (org.springframework.boot): 0
$ $CURLSET 19000 .harness/cost-prev/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
with the starter, port 19001:
$ cd .harness/cost-a1 && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19001 --spring.main.sources=harness.Inspect
  harness: Boot's kind of application: NONE · the context: AnnotationConfigApplicationContext
  harness: bean definitions, this harness's own left out: 134
  harness: auto-configuration classes registered: 31 of the 74 candidates - Actuator's 5 · Micrometer's 11 · health's 5 · the rest 10
  harness: endpoint beans: 1 - health · beans that hand endpoints to an adapter (EndpointsSupplier): 0
  harness: Boot's MBeans (org.springframework.boot): 0
  every address this process listens on (lsof): 127.0.0.1:19001
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19001/actuator/health
  <h1>404 Not Found</h1>No context found for request 404
$ $CURLSET 19001 .harness/cost-a1/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```

## 2 · why — the condition report

The copy with the starter, its jar run as the README runs it with `--debug`. Boot's own words for each Actuator piece that stayed
out: web endpoints (`@ConditionalOnWebApplication`), JMX endpoints (`spring.jmx.enabled`), health's web extension (servlet classes),
and the heap dump endpoint (its access, NONE).

`.r-why.out` · md5 `ec2878bb84cc567e3cf203ad88dd3e33` · 3 of 3

```
the copy with the starter (built by capture cost), its jar run as the README runs it, with --debug - Boot's condition report,
port 19001. Its blocks for Actuator's web endpoints, its JMX endpoints, health's web extension and the heap dump endpoint, each
whole, in the report's order; the rest of the report, counted:
$ cd .harness/cost-a1 && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19001 --debug
  listens on: 127.0.0.1:19001
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ $CURLSET 19001 .harness/cost-a1/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
    CONDITIONS EVALUATION REPORT
    … 304 lines not shown …
       HealthEndpointWebExtensionConfiguration:
          Did not match:
             - did not find servlet web application classes (OnWebApplicationCondition)
    … 1 line not shown …
       HeapDumpWebEndpointAutoConfiguration:
          Did not match:
             - @ConditionalOnAvailableEndpoint the configured access for endpoint 'heapdump' is NONE (OnAvailableEndpointCondition)
    … 69 lines not shown …
       JmxEndpointAutoConfiguration:
          Did not match:
             - @ConditionalOnBooleanProperty (spring.jmx.enabled=true) did not find property 'spring.jmx.enabled' (OnPropertyCondition)
    … 139 lines not shown …
       WebEndpointAutoConfiguration:
          Did not match:
             - @ConditionalOnWebApplication did not find reactive or servlet web application classes (OnWebApplicationCondition)
    … 35 lines not shown …
  the report's sections: 4 - Positive matches, Negative matches, Exclusions, Unconditional classes
```

## 3 · ways — JMX, and Spring MVC on Tomcat

**JMX:** the copy with the starter, exploded with the harness, `--spring.jmx.enabled=true` — 1 MBean (`Health`), and over JMX its
answer carries details (names printed: `diskSpace` with `exists free path threshold total`); every endpoint on JMX, configprops
excluded — 11 MBeans. The endpoint classes in the jars, read by their annotation (`javap -v` on every class an endpoint annotation
names): 19 ids, 3 of them `@WebEndpoint` — HTTP only; `heapdump`'s and `shutdown`'s carry `defaultAccess=NONE`. **Spring MVC on Tomcat:** a copy of
the previous tree with the starter and Spring MVC's starter — 12 more jars; run with TiffinBox on 19003 and Tomcat told
`--server.port=19004 --server.address=127.0.0.1` (left unset, the address is Tomcat's default — every interface, the probes measured;
never run here, S4.3), health,
mappings, loggers and metrics exposed: two addresses, Tomcat's health (`{"groups":…,"status":"UP"}` — its keys in another order: Tomcat's JSON is Jackson 3's), mappings
naming none of TiffinBox's five paths. **Boot's own adapter, asked eight requests** — the eight `tour` asks the bridge: `Accept:
application/json` → `200 application/json`; `metrics/jvm.threads.states?tag=state:nowhere` → 404 (the query filters); a write in
`text/plain` → 415; `{"configuredLevel":"LOUD"}` → 400; DEBUG → 204; **a JSON write with an empty body → 204, and the level reset**
(`{"effectiveLevel": "INFO"}`, keys sorted); `/actuator` → 200, its links. After the seven's POST /shutdown, TiffinBox's server stops —
and 2 s later the JVM still runs, listening on Tomcat's port; `kill $pid` (SIGTERM) ends it: 143.

`.r-ways.out` · md5 `21bc5a1d5afd3b939526a303e5d01a95` · 3 of 3

```
way 1, JMX - the copy with the starter (capture cost), run exploded with the harness joined, as cost runs it, port 19002:
$ cd .harness/cost-a1 && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19002 --spring.main.sources=harness.Inspect --spring.jmx.enabled=true
  harness: Boot's kind of application: NONE · the context: AnnotationConfigApplicationContext
  harness: bean definitions, this harness's own left out: 148
  harness: auto-configuration classes registered: 33 of the 74 candidates - Actuator's 6 · Micrometer's 11 · health's 5 · the rest 11
  harness: endpoint beans: 1 - health · beans that hand endpoints to an adapter (EndpointsSupplier): 1 - jmxAnnotationEndpointDiscoverer
  harness: Boot's MBeans (org.springframework.boot): 1 - Health
  harness: over JMX, Health's operation health answers - the names in it, every value left out: (components(diskSpace(details(exists free path threshold total) status) livenessState(status) ping(status) readinessState(status) ssl(details(expiringChains invalidChains validChains) status)) groups status)
$ $CURLSET 19002 .harness/cost-a1/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
every endpoint on JMX, configprops excluded (the exposure lesson below says why):
$ cd .harness/cost-a1 && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19002 --spring.main.sources=harness.Inspect --spring.jmx.enabled=true --management.endpoints.jmx.exposure.include='*' --management.endpoints.jmx.exposure.exclude=configprops
  harness: Boot's kind of application: NONE · the context: AnnotationConfigApplicationContext
  harness: bean definitions, this harness's own left out: 174
  harness: auto-configuration classes registered: 46 of the 74 candidates - Actuator's 18 · Micrometer's 12 · health's 5 · the rest 11
  harness: endpoint beans: 11 - beans conditions env health info loggers mappings metrics sbom scheduledtasks threaddump · beans that hand endpoints to an adapter (EndpointsSupplier): 1 - jmxAnnotationEndpointDiscoverer
  harness: Boot's MBeans (org.springframework.boot): 11 - Beans Conditions Env Health Info Loggers Mappings Metrics Sbom Scheduledtasks Threaddump
  harness: over JMX, Health's operation health answers - the names in it, every value left out: (components(diskSpace(details(exists free path threshold total) status) livenessState(status) ping(status) readinessState(status) ssl(details(expiringChains invalidChains validChains) status)) groups status)
$ $CURLSET 19002 .harness/cost-a1/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  endpoint classes in the jars, by their annotation (javap -v): 19 - ids: auditevents beans conditions configprops env health heapdump httpexchanges info logfile loggers mappings metrics prometheus sbom scheduledtasks shutdown startup threaddump
  of them web-only (@WebEndpoint), each class and its annotation:
    HeapDumpWebEndpoint · @WebEndpoint(id="heapdump", defaultAccess=NONE)
    LogFileWebEndpoint · @WebEndpoint(id="logfile")
    PrometheusScrapeEndpoint · @WebEndpoint(id="prometheus")
  the ones whose annotation sets defaultAccess=NONE - off unless switched on: heapdump shutdown
way 2, Spring MVC on Tomcat - a copy of the previous tree with Actuator's starter and Spring MVC's, built offline:
$ perl -0pi -e 's|\n  </dependencies>|\n    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-actuator</artifactId></dependency>\n  </dependencies>|' .harness/ways-mvc/tiffinbox-web/pom.xml
  lines added: 1
$ perl -0pi -e 's|\n  </dependencies>|\n    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-webmvc</artifactId></dependency>\n  </dependencies>|' .harness/ways-mvc/tiffinbox-web/pom.xml
  lines added: 1
$ cd .harness/ways-mvc && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the copy with Spring MVC · offline: yes · exit 0
  jars under BOOT-INF/lib: 51 - against the starter alone's 39: 12 more -
    jackson-core-3.1.5.jar jackson-databind-3.1.5.jar spring-boot-http-converter-4.1.1.jar spring-boot-jackson-4.1.1.jar spring-boot-servlet-4.1.1.jar spring-boot-tomcat-4.1.1.jar spring-boot-web-server-4.1.1.jar spring-boot-webmvc-4.1.1.jar spring-web-7.0.9.jar spring-webmvc-7.0.9.jar tomcat-embed-core-11.0.24.jar tomcat-embed-websocket-11.0.24.jar
its jar, run as the README runs it - TiffinBox on 19003 - with Tomcat told its port, 19004, and its address, 127.0.0.1; health,
mappings, loggers and metrics exposed on it:
$ cd .harness/ways-mvc && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19003 --server.port=19004 --server.address=127.0.0.1 --management.endpoints.web.exposure.include=health,mappings,loggers,metrics
  every address this process listens on (lsof): 127.0.0.1:19003 127.0.0.1:19004
  Tomcat's own line: Tomcat started on port 19004 (http) with context path '/'
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19004/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19004/actuator/health
  {"groups":["liveness","readiness"],"status":"UP"} 200
$ curl -s -o .harness/ways-mappings.json http://127.0.0.1:19004/actuator/mappings
  its answer: the kinds of mapping it lists - dispatcherServlets servletFilters servlets · mentions of TiffinBox's five paths (/customers /revenue /dashboard /kitchen /shutdown): 0
Boot's own adapter, asked how it reads a request - the tour below asks the bridge the same eight:
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' -H 'Accept: application/json' http://127.0.0.1:19004/actuator/health
  200 application/json
$ curl -s -o /dev/null -w '%{http_code}\n' 'http://127.0.0.1:19004/actuator/metrics/jvm.threads.states?tag=state:nowhere'
  404
$ curl -s -o /dev/null -w '%{http_code}\n' -X POST -H 'Content-Type: text/plain' -d '{"configuredLevel":"DEBUG"}' http://127.0.0.1:19004/actuator/loggers/com.tiffinbox
  415
$ curl -s -o /dev/null -w '%{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":"LOUD"}' http://127.0.0.1:19004/actuator/loggers/com.tiffinbox
  400
$ curl -s -o /dev/null -w '%{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":"DEBUG"}' http://127.0.0.1:19004/actuator/loggers/com.tiffinbox
  204
$ curl -s -o /dev/null -w '%{http_code}\n' -X POST -H 'Content-Type: application/json' -d '' http://127.0.0.1:19004/actuator/loggers/com.tiffinbox
  204
$ curl -s http://127.0.0.1:19004/actuator/loggers/com.tiffinbox | python3 -c 'import json, sys; print(json.dumps(json.load(sys.stdin), sort_keys=True))'
  {"effectiveLevel": "INFO"}
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19004/actuator
  200
$ $CURLSET 19003 .harness/ways-mvc/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  2 s after POST /shutdown - still running: yes · listening on: 127.0.0.1:19004
$ kill $pid
  exit 143 · listening on 19003 and 19004 now: 0 and 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```

## 4 · change — the previous tree against after/

`diff -rq` of the two trees (copied under `.harness/`), then each file: ActuatorRoutes.java counted, and its key lines (`grep -n`:
the discoverer and its two filters, the health extension, the handler, a write only as JSON and its `415`, the query merged, the
type asked for, the `400` and the catch);
the lines TiffinBoxServer.java, application.yaml and the web POM gain that are neither comment nor blank, and what `diff` removes
(TiffinBoxServer's constructor line, now split); the anchor README's new section, counted; TiffinBoxApp.java compared byte for byte.
The sixth file, `.gitignore`, gains two lines — a comment and `*.hprof` — listed by `diff -rq`, not printed.

`.r-change.out` · md5 `c1943610299f2d4031a86a3d1df890cf` · 3 of 3

```
the previous tree against after/, both copied under .harness/ - the files that differ:
$ diff -rq -x target -x secrets .harness/before .harness/after
  Files .harness/before/.gitignore and .harness/after/.gitignore differ
  Files .harness/before/README.md and .harness/after/README.md differ
  Files .harness/before/tiffinbox-web/pom.xml and .harness/after/tiffinbox-web/pom.xml differ
  Only in .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web: ActuatorRoutes.java
  Files .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java and .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java differ
  Files .harness/before/tiffinbox-web/src/main/resources/application.yaml and .harness/after/tiffinbox-web/src/main/resources/application.yaml differ
  tiffinbox-web/src/main/java/com/tiffinbox/web/ActuatorRoutes.java - new: 189 lines · imports 42 · comment lines 25 · blank 11 · beans (@Bean) 3 - its key lines (grep -n):
    66: WebEndpointDiscoverer webEndpointDiscoverer(ApplicationContext context, ParameterValueMapper mapper,
    68: var exposure = new IncludeExcludeEndpointFilter<>(ExposableWebEndpoint.class, env,
    71: advisors.orderedStream().toList(), List.of(exposure), List.of(OperationFilter.byAccess(access)));
    76: @ConditionalOnAvailableEndpoint(endpoint = HealthEndpoint.class)
    77: HealthEndpointWebExtension healthEndpointWebExtension(HealthContributorRegistry registry,
    84: HttpHandler actuatorHandler(WebEndpointsSupplier endpoints) {
    97: for (ExposableWebEndpoint endpoint : endpoints.getEndpoints()) {
    100: Map<String, Object> arguments = match(predicate.getPath(), path);
    104: if (!predicate.getConsumes().isEmpty()) {
    107: respond(exchange, 415, "application/json", Map.of("error", "unsupported media type"));
    110: arguments.putAll(fields(exchange.getRequestBody().readAllBytes()));
    112: query(exchange.getRequestURI().getRawQuery()).forEach((name, values) ->
    114: Object result = operation.invoke(new InvocationContext(SecurityContext.NONE, arguments,
    119: String type = predicate.getProduces().stream().filter(accept::contains).findFirst()
    126: respond(exchange, status, type, result);
    132: } catch (InvalidEndpointRequestException e) {
    134: } catch (Exception | LinkageError e) {
  tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java - the lines it gains that are neither comment nor blank:
    import com.sun.net.httpserver.HttpHandler;
        private final HttpHandler actuator;
        TiffinBoxServer(CustomerRepository repo, Dashboard dashboard, OrderQueue kitchen, TiffinBoxProperties settings,
                        HttpHandler actuator) {
            this.actuator = actuator;
            server.createContext("/actuator", actuator);
    (diff adds 9 lines, removes 1 - TiffinBoxServer(CustomerRepository repo, Dashboard dashboard, OrderQueue kitchen, TiffinBoxProperties settings) {)
  tiffinbox-web/src/main/resources/application.yaml - the lines it gains that are neither comment nor blank:
    management:
      endpoints:
        web:
          exposure:
            include: health
    (diff adds 8 lines, removes 0)
  tiffinbox-web/pom.xml - the lines it gains that are neither comment nor blank:
        <dependency>
          <groupId>org.springframework.boot</groupId>
          <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
            <configuration>
              <excludes>
                <exclude>
                  <groupId>org.springframework.boot</groupId>
                  <artifactId>spring-boot-docker-compose</artifactId>
                </exclude>
                <exclude>
                  <groupId>tools.jackson.core</groupId>
                  <artifactId>jackson-databind</artifactId>
                </exclude>
                <exclude>
                  <groupId>tools.jackson.core</groupId>
                  <artifactId>jackson-core</artifactId>
                </exclude>
              </excludes>
            </configuration>
    (diff adds 27 lines, removes 0)
  README.md - the anchor's README: lines added 110, removed 0 - its new section (not shown)
  TiffinBoxApp.java against the previous tree's, byte for byte: the same
```

## 5 · serve — after/, as the README builds and runs it

Readiness first — asked until it answers 200 (every 0.25 s, up to 60 s, not printed: the race is the next unit's) — then each request
once: health (`UP`, its two groups, no details), liveness, env (404: not exposed), a POST to health (405: the path exists, the verb
does not), the addresses the process listens on (one), and the seven, all shown.

`.r-serve.out` · md5 `aa7baf0abced50c67d59d4cf87a7cb8e` · 3 of 3

```
after/, copied to .harness/serve with a config tree, built the README's plain way; its jar run as the README runs it, port 19005:
$ cd .harness/serve && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built after/ · offline: yes · exit 0
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19005
  listens on: 127.0.0.1:19005
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
readiness first - asked until it answers 200, a bounded poll, not printed - then each request once:
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19005/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19005/actuator/health
  {"status":"UP","groups":["liveness","readiness"]} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19005/actuator/health/liveness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19005/actuator/env
  404
$ curl -s -X POST -w ' %{http_code}\n' http://127.0.0.1:19005/actuator/health
  {"error":"method not allowed"} 405
  every address this process listens on (lsof): 127.0.0.1:19005
$ $CURLSET 19005 .harness/serve/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```

## 6 · aot — Spring's AOT step, without and with Boot's plugin's excludes

**B** — after/ with Boot's plugin's configuration deleted (the `perl` shown; 20 lines; 0 excludes left), built with the README's AOT
line (`mvn -B -Pnative package`, offline): Spring's generated code holds `JacksonEndpointAutoConfiguration__BeanDefinitions.java` —
process-aot read Maven's class path, where the optional Compose module brings Jackson 3 — and its metadata names a Docker Compose
package 3 times. Run the plain way, B's jar serves the seven; run with the generated code (`-Dspring.aot.enabled=true`), TiffinBox's
server opens its port, then the start fails on `endpointJsonMapper`: `NoClassDefFoundError: tools/jackson/databind/json/JsonMapper`
— no failure analysis, exit 1. **A** — after/: no Jackson configuration generated, 0 Compose entries; the AOT jar serves health and the
seven. **The list under AOT:** A's jar with the README's flag line (health and env): the plain way → env 200; with the generated code →
env 404 — the endpoints were decided when the jar was built. **C** (labelled): the same AOT jar with a run-time list of env alone —
health and readiness `{"error":"not found"}` 404, env 404: a run-time list still filters what was built, so it can narrow the list,
never widen it (RED C5-S4 #7).

`.r-aot.out` · md5 `18ee0a7447caa0fcc0a41e68661833ef` · 3 of 3

```
B - after/ without Boot's plugin's three excludes (a copy, the plugin's configuration deleted), built with the README's AOT line:
the profile native, from Boot's parent - Spring's AOT step, on the plain JDK - offline:
$ perl -0pi -e 's|(<artifactId>spring-boot-maven-plugin</artifactId>\n).*?(      </plugin>)|$1$2|s' .harness/aot-b/tiffinbox-web/pom.xml
  lines deleted: 20 · excludes left in the file: 0
$ cd .harness/aot-b && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean package
  built B · offline: yes · exit 0
  Spring's generated code (target/spring-aot/main/sources): bean-definition classes 64 · for Actuator's Jackson configuration: JacksonEndpointAutoConfiguration__BeanDefinitions.java
  its reachability-metadata.json: reflection entries 399 · naming a Docker Compose package (...docker.compose...): 3 · naming Jackson 3 (tools.jackson): 0
B's jar, run the plain way, port 19006:
$ cd .harness/aot-b && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19006
  listens on: 127.0.0.1:19006
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ $CURLSET 19006 .harness/aot-b/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
B's jar, run with the generated code - the README's AOT line, port 19006:
$ cd .harness/aot-b && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19006
  TiffinBox's own line, before it stopped: TiffinBox listening on http://127.0.0.1:19006
  then: Application run failed - the exception, then each cause, each cut after the bean or the method it names; the lines between, counted:
    org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'endpointJsonMapper' …
    … 24 lines not shown …
    Caused by: java.lang.NoClassDefFoundError: tools/jackson/databind/json/JsonMapper
    … 12 lines not shown …
    Caused by: java.lang.ClassNotFoundException: tools.jackson.databind.json.JsonMapper
  Boot's failure analysis (its banner, APPLICATION FAILED TO START): 0 · stack frames (lines starting 'at '): 40
  exit 1 · listening on 19006 now: 0
A - after/ itself, the same build:
$ cd .harness/aot-a && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean package
  built A · offline: yes · exit 0
  Spring's generated code (target/spring-aot/main/sources): bean-definition classes 63 · for Actuator's Jackson configuration: none
  its reachability-metadata.json: reflection entries 394 · naming a Docker Compose package (...docker.compose...): 0 · naming Jackson 3 (tools.jackson): 0
$ cd .harness/aot-a && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19006
  listens on: 127.0.0.1:19006
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19006/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19006/actuator/health
  {"status":"UP","groups":["liveness","readiness"]} 200
$ $CURLSET 19006 .harness/aot-a/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
the exposure list under AOT - A's jar with the README's flag line (health and env exposed), the plain way, then the AOT way:
$ cd .harness/aot-a && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19006 --management.endpoints.web.exposure.include=health,env
  listens on: 127.0.0.1:19006
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19006/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19006/actuator/env
  200
$ $CURLSET 19006 .harness/aot-a/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
$ cd .harness/aot-a && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19006 --management.endpoints.web.exposure.include=health,env
  listens on: 127.0.0.1:19006
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19006/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19006/actuator/env
  404
$ $CURLSET 19006 .harness/aot-a/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
C (labelled) - the same AOT jar, the list given at run time without health (env alone): the endpoints were fixed at build
time, and the run-time list still filters them - health, liveness and readiness go (no readiness to wait for: Boot's started
line instead):
$ cd .harness/aot-a && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19006 --management.endpoints.web.exposure.include=env
  listens on: 127.0.0.1:19006
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19006/actuator/health
  {"error":"not found"} 404
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19006/actuator/health/readiness
  {"error":"not found"} 404
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19006/actuator/env
  404
$ $CURLSET 19006 .harness/aot-a/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```

## 7 · exposure — the break (A/B/A′, and C)

**A** — after/'s jar, the anchor's list: health 200, env 404, the seven. **B** — the same jar, the list a star: TiffinBox's server
opens its port, then the start fails on `configurationPropertiesReportEndpoint` — `NoClassDefFoundError:
com/fasterxml/jackson/datatype/jsr310/JavaTimeModule`: configprops needs Jackson 2's time module, and TiffinBox's Jackson 2 (Course 2's
library) carries none (its three jars listed); Boot prints no failure analysis; 41 stack frames; exit 1. **A′** = A re-run, the same
command, the same answers. **C** (labelled, not A′) — a star, configprops excluded: it starts, and of the 19 endpoint ids the jars
declare (read in `ways`), 11 answer 200 — the eleven JMX carried — and 8 answer 404: configprops (excluded), heapdump and shutdown
(access NONE by default), prometheus (no registry jar in the jar yet: the metrics unit's), and auditevents, httpexchanges, logfile and
startup (each waits for something TiffinBox does not configure — not measured one by one).

`.r-exposure.out` · md5 `6a49363e956dec88b50495dfe1c43d50` · 3 of 3

```
A - after/'s jar (built by capture serve), the anchor's list (application.yaml: health), port 19005:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19005
  listens on: 127.0.0.1:19005
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19005/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19005/actuator/health
  {"status":"UP","groups":["liveness","readiness"]} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19005/actuator/env
  404
$ $CURLSET 19005 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
B - the same jar, the list a star: every endpoint:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19005 --management.endpoints.web.exposure.include='*'
  TiffinBox's own line, before it stopped: TiffinBox listening on http://127.0.0.1:19005
  then: Application run failed - the exception, then each cause, each cut after the bean or the method it names; the lines between, counted:
    org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'configurationPropertiesReportEndpoint' …
    … 26 lines not shown …
    Caused by: org.springframework.beans.BeanInstantiationException: Failed to instantiate [org.springframework.boot.actuate.context.properties.ConfigurationPropertiesReportEndpoint]: Factory method 'configurationPropertiesReportEndpoint' threw exception …
    … 5 lines not shown …
    Caused by: java.lang.NoClassDefFoundError: com/fasterxml/jackson/datatype/jsr310/JavaTimeModule
    … 7 lines not shown …
    Caused by: java.lang.ClassNotFoundException: com.fasterxml.jackson.datatype.jsr310.JavaTimeModule
  Boot's failure analysis (its banner, APPLICATION FAILED TO START): 0 · stack frames (lines starting 'at '): 41
  exit 1 · listening on 19005 now: 0
  TiffinBox's Jackson in the jar's BOOT-INF/lib: jackson-annotations-2.22.jar jackson-core-2.22.2.jar jackson-databind-2.22.2.jar · Jackson 2's time module (jackson-datatype-jsr310) among them: 0
A' - A again:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19005
  listens on: 127.0.0.1:19005
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19005/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19005/actuator/health
  {"status":"UP","groups":["liveness","readiness"]} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19005/actuator/env
  404
$ $CURLSET 19005 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
C - labelled, not A': a star, configprops excluded:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19005 --management.endpoints.web.exposure.include='*' --management.endpoints.web.exposure.exclude=configprops
  listens on: 127.0.0.1:19005
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19005/actuator/health/readiness
  {"status":"UP"} 200
every endpoint id the jars declare (capture ways read them), each asked once with the README's env line, its id in env's place:
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19005/actuator/ID - for each ID
  200, 11: beans conditions env health info loggers mappings metrics sbom scheduledtasks threaddump
  not 200, 8: auditevents:404 configprops:404 heapdump:404 httpexchanges:404 logfile:404 prometheus:404 shutdown:404 startup:404
  prometheus' registry (micrometer-registry-prometheus) among the jar's BOOT-INF/lib: 0
$ $CURLSET 19005 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```

## 8 · tour — what each endpoint hands over

One run with C's flags; each answer saved, read and counted (Masks 5): beans (153, 6 of them naming the jar's absolute path),
conditions, env (6 sources; every value `******`; the environment's names exactly the run's; the config tree's source name carrying
this folder's absolute path), mappings (empty: TiffinBox's routes are not Spring MVC's), metrics (no `tiffinbox.` name yet),
threaddump (TiffinBox's `HTTP-Dispatcher` among the threads), heapdump (404: access NONE, even exposed). Then env's masking, one run
each: `show-values=when-authorized` → `******` (no Spring Security: nobody is authorized); `=always` → the token in clear, 2 raw copies
in the entry's answer (the property and its source's entry) — counted, never printed, deleted. Then the heap dump, switched on for one
run (`access=read-only`), the JVM's temporary folder set to an empty one of its own: `JAVA PROFILE 1.0.2`, over 20,000,000 bytes, the
token in it 3 times (`grep -a -o`) on 3 lines (`grep -c -a -F`); deleted, and nothing left in the JVM's temporary folder. **The
bridge, asked the eight** Boot's own adapter answered in `ways` (this run exposes loggers and metrics): the same answers but two — a
JSON write with an empty body → **400**, the level kept (`{"configuredLevel": "DEBUG", "effectiveLevel": "DEBUG"}`), where Boot's
adapter resets it; `/actuator` → **404** (the bridge has no links page).

`.r-tour.out` · md5 `eabfff26723fa7ad719a781ec9bffde0` · 3 of 3

```
one run with C's flags - every endpoint but configprops - from .harness/serve (capture serve built it), port 19007; each answer
saved beside the config tree, read as JSON, counted - never a value, never a name of this Mac's - and its size against a floor:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19007 --management.endpoints.web.exposure.include='*' --management.endpoints.web.exposure.exclude=configprops
  listens on: 127.0.0.1:19007
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19007/actuator/health/readiness
  {"status":"UP"} 200
$ cd .harness/serve && curl -s -o beans.json -w '%{http_code}\n' http://127.0.0.1:19007/actuator/beans
  200
$ cd .harness/serve && curl -s -o conditions.json -w '%{http_code}\n' http://127.0.0.1:19007/actuator/conditions
  200
$ cd .harness/serve && curl -s -o env.json -w '%{http_code}\n' http://127.0.0.1:19007/actuator/env
  200
$ cd .harness/serve && curl -s -o mappings.json -w '%{http_code}\n' http://127.0.0.1:19007/actuator/mappings
  200
$ cd .harness/serve && curl -s -o metrics.json -w '%{http_code}\n' http://127.0.0.1:19007/actuator/metrics
  200
$ cd .harness/serve && curl -s -o threaddump.json -w '%{http_code}\n' http://127.0.0.1:19007/actuator/threaddump
  200
$ cd .harness/serve && curl -s -o heap.hprof -w '%{http_code}\n' http://127.0.0.1:19007/actuator/heapdump
  404
  beans · over 40,000 bytes: yes · beans listed: 153 · their dependencies, named: 148 · beans whose resource names the jar's absolute path (not shown): 6
  conditions · over 30,000 bytes: yes · positive matches 91 · negative matches 62 · unconditional classes 11
  env · over 5,000 bytes: yes · property sources 6, keys in each: commandLineArgs (3) · systemProperties (60) · systemEnvironment (the names of the variables this run was started with - the same as env -0 lists from the same folder, the shell's _ and macOS's __CF_USER_TEXT_ENCODING aside: yes) · the config tree (1) · application.yaml (13) · applicationInfo (2)
    values that are not ******: 0 · the demo token in the answer, raw: 0 · the config tree's source name carries this folder's absolute path: yes
  mappings · the whole answer, keys sorted: {"contexts": {"application": {"mappings": {}, "parentId": null}}}
  metrics · names under tiffinbox.: 0 · the first part of every name: application disk executor jvm logback process system
  threaddump · over 10,000 bytes: yes · TiffinBox's server thread among the threads it lists, with its stack: HTTP-Dispatcher
  heapdump · what curl wrote into heap.hprof: {"error":"not found"} - the answer's own body, not a heap
the bridge, asked how it reads a request - the eight Boot's own adapter answered in capture ways:
$ curl -s -o /dev/null -w '%{http_code} %{content_type}\n' -H 'Accept: application/json' http://127.0.0.1:19007/actuator/health
  200 application/json
$ curl -s -o /dev/null -w '%{http_code}\n' 'http://127.0.0.1:19007/actuator/metrics/jvm.threads.states?tag=state:nowhere'
  404
$ curl -s -o /dev/null -w '%{http_code}\n' -X POST -H 'Content-Type: text/plain' -d '{"configuredLevel":"DEBUG"}' http://127.0.0.1:19007/actuator/loggers/com.tiffinbox
  415
$ curl -s -o /dev/null -w '%{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":"LOUD"}' http://127.0.0.1:19007/actuator/loggers/com.tiffinbox
  400
$ curl -s -o /dev/null -w '%{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":"DEBUG"}' http://127.0.0.1:19007/actuator/loggers/com.tiffinbox
  204
$ curl -s -o /dev/null -w '%{http_code}\n' -X POST -H 'Content-Type: application/json' -d '' http://127.0.0.1:19007/actuator/loggers/com.tiffinbox
  400
$ curl -s http://127.0.0.1:19007/actuator/loggers/com.tiffinbox | python3 -c 'import json, sys; print(json.dumps(json.load(sys.stdin), sort_keys=True))'
  {"configuredLevel": "DEBUG", "effectiveLevel": "DEBUG"}
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19007/actuator
  404
$ $CURLSET 19007 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
env's masking, switched for one run each - the README's flag line (health and env exposed), one flag more, the token's entry asked:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19007 --management.endpoints.web.exposure.include=health,env --management.endpoint.env.show-values=when-authorized
  listens on: 127.0.0.1:19007
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19007/actuator/health/readiness
  {"status":"UP"} 200
$ cd .harness/serve && curl -s -o env-entry.json -w ' %{http_code}\n' http://127.0.0.1:19007/actuator/env/tiffinbox.shutdown-token
   200
  its value: ****** · the demo token in the answer, raw (grep -a -o): 0
  the answer deleted: yes
$ $CURLSET 19007 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19007 --management.endpoints.web.exposure.include=health,env --management.endpoint.env.show-values=always
  listens on: 127.0.0.1:19007
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19007/actuator/health/readiness
  {"status":"UP"} 200
$ cd .harness/serve && curl -s -o env-entry.json -w ' %{http_code}\n' http://127.0.0.1:19007/actuator/env/tiffinbox.shutdown-token
   200
  its value: not ****** - not printed · the demo token in the answer, raw (grep -a -o): 2
  the answer deleted: yes
$ $CURLSET 19007 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
the heap dump, switched on for one run - the README's two lines; the JVM's temporary folder set to an empty one of its own:
$ cd .harness/serve && java -Djava.io.tmpdir=../tmp -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19007 --management.endpoints.web.exposure.include=health,heapdump --management.endpoint.heapdump.access=read-only
  listens on: 127.0.0.1:19007
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19007/actuator/health/readiness
  {"status":"UP"} 200
$ cd .harness/serve && curl -s -o heap.hprof -w '%{http_code}\n' http://127.0.0.1:19007/actuator/heapdump
  200
  its first bytes: JAVA PROFILE 1.0.2 · over 20,000,000 bytes: yes
  the demo token in it - copies (grep -a -o): 3 · lines holding it (grep -c -a -F): 3
  the file deleted: yes · files left in the JVM's temporary folder: 0
$ $CURLSET 19007 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```

## 9 · start — the start, timed from outside; the band behind a load gate

`harness/ttfr.py` (the hints lesson's clock) forks the command, asks `/kitchen` until the first 200, then POST /shutdown with the token,
and prints the time from the fork to that first 200. Three jars — the previous tree's (the reference), the copy with the starter,
after/'s (starter and bridge) — six rounds, the three in turn, round 1 a warm-up; each jar's median of its five counted runs. **The
capture holds only what a busy machine cannot move** (RED C5-S4 #1: the ratios ran from 0.94 to 3.40 at load 17-140, and `start`
drifted in 4 of 4 runs): 18 of 18 runs answered and stopped, 5 of 6 counted, the reference's median over 1 s. The other two jars'
ratios to it, and every second, go to the terminal, and the band the voice states — each Actuator jar's median over the reference's,
and under a quarter more — is judged there **behind a load gate**: the 1-minute load average under this Mac's core count (8) before
the rounds (waited for, up to 2 minutes: the native build runs just before) and after them. Judged, a miss stops the run; refused,
the run says so on the terminal and goes on; the last check says how many of the three captures judged it. `start` runs last,
after the native build and the exercise. `/kitchen` answers before Boot calls TiffinBox ready (the next unit's race), so the ratio
is to a first answer, and the voice says so (RED C5-S4 #3). **The band, judged on a quiet Mac:** the starter's medians 1.097-1.156 of the previous jar's, after/'s 1.127-1.182 (the load gate open in 6 of the 6 timed captures of this revision's two runs of record, 2026-10-08 — `./receipts.sh` in place and `bash receipts.sh` from a sealed clone; the reference's medians 1.257-1.288 s; one-minute load averages 5.36-7.91). Under load the same ratios ran from 0.94 to 3.40 (RED C5-S4 #1): never in the capture, and judged only behind the gate.

`.r-start.out` · md5 `b0894b7d49ae387463ad525543620fe6` · 3 of 3

```
the start, timed from outside: harness/ttfr.py forks the command, asks /kitchen until the first 200, then sends POST /shutdown
with the token. Three jars, each run as the README runs it from beside its config tree, port 19008; 6 rounds, each round the
three in turn; round 1 a warm-up:
  1 the previous tree's jar (capture cost) - $ cd .harness/cost-prev && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19008
  2 that tree plus Actuator's starter (capture cost) - $ cd .harness/cost-a1 && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19008
  3 after/'s jar (capture serve) - $ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19008
  every run: a 200, then exit 0 after POST /shutdown: 18 of 18
each jar's median, the middle of its counted runs; the reference against a floor (the seconds, and the other two jars' ratios
to it, go to the terminal: a busy machine moves them):
  each jar's runs counted: 5 of 6 - round 1 left out
  1 the previous tree's jar: its median over 1 s: yes
```

## 10 · native — after/'s binary

After/, copied with a config tree, built with the README's two Maven lines (the native install, then `native:compile-no-fork` on the
web module), offline: 8 of 8 stages, `BUILD SUCCESS`, and three warnings about deprecated options (`--no-fallback`, from Spring's generated
`native-image.properties`; `FallbackThreshold`; `DynamicProxyConfigurationResources`); 0 tokens in the binary's bytes. Run from beside its config tree: `Starting AOT-processed`,
readiness, health with its groups, the seven; with the README's env flag added to the binary's run line, env 404 — the list built in. Each native build took 117-148 s in the first revision's runs (bound: 1 minute or more, under 20 minutes — a run under the load of three receipts at once took 211-456 s).

`.r-native.out` · md5 `35c9f010689cb93adb7bc28e5e075322` · 3 of 3

```
after/, copied to .harness/nat with a config tree; the README's two Maven lines, offline; $GRAALVM_HOME names the GraalVM:
$ cd .harness/nat && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean install
  built .harness/nat (both modules, into $M2) · offline: yes · exit 0
$ cd .harness/nat && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -pl tiffinbox-web native:compile-no-fork
  its lines, in order (the rest - 152 lines - not shown):
    --- native:1.1.8:compile-no-fork (default-cli) @ tiffinbox-web ---
    Found GraalVM installation from GRAALVM_HOME variable.
    Java version: 25.0.4.1+1, vendor version: GraalVM CE 25.3.4.1+1.1
    Warning: Using a deprecated option --no-fallback from 'META-INF/native-image/com.tiffinbox/tiffinbox-web/native-image.properties' in '…'. No effect, no replacement available
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
    The build process encountered 3 warnings.
    BUILD SUCCESS
  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 20 minutes · offline: yes
  file: Mach-O 64-bit executable · the demo token in its bytes: 0
its binary, run from beside its config tree as the README runs it, port 19006:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19006
  listens on: 127.0.0.1:19006
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19006/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19006/actuator/health
  {"status":"UP","groups":["liveness","readiness"]} 200
$ $CURLSET 19006 .harness/nat/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
the same binary, with the README's flag that exposes env:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19006 --management.endpoints.web.exposure.include=health,env
  listens on: 127.0.0.1:19006
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19006/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19006/actuator/env
  404
$ $CURLSET 19006 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```

## 11 · exercise — the exercise, run as written

`exercise/README.md`'s commands and `exercise/solution/SOLUTION.md`'s one line, read from the files and run exactly as written: the
config tree holds the token, and env shows it masked.

`.r-exercise.out` · md5 `c7fe11d598cbde47a071c473a226b896` · 3 of 3

```
exercise/README.md's commands, run exactly as written from this folder - 5 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine/run/secrets/tiffinbox && rsync -a --exclude target after/ .harness/mine/after/
  $ mvn -o -B -q -f .harness/mine/after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package
  $ chmod 700 .harness/mine/run/secrets .harness/mine/run/secrets/tiffinbox && (umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/run/secrets/tiffinbox/shutdown-token)
  exit 0 · printed: 0 line(s)
the solution's line (exercise/solution/SOLUTION.md), run exactly as written, from this folder:
$ (cd .harness/mine/run && exec java -jar ../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19009 --management.endpoints.web.exposure.include=health,env > ../run.log 2>&1) & for i in $(seq 120); do curl -sf -o /dev/null http://127.0.0.1:19009/actuator/health/readiness && break; sleep 0.25; done; curl -s http://127.0.0.1:19009/actuator/env/tiffinbox.shutdown-token | python3 -c 'import json, sys; p = json.load(sys.stdin)["property"]; print(p["source"] + " · tiffinbox.shutdown-token = " + p["value"])' | sed "s|'.*/secrets'|'…/secrets'|"; harness/shutdown.sh 19009 .harness/mine/run/secrets/tiffinbox/shutdown-token; wait
Config tree '…/secrets' · tiffinbox.shutdown-token = ******
POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19009 now: 0
```

## Exercise

**Your turn:** expose the env endpoint for one run, then find the property source that holds tiffinbox.shutdown-token, and what it
shows. `exercise/README.md` has the commands; done is the line `Config tree '…/secrets' · tiffinbox.shutdown-token = ******`; the
measured answer, run exactly as written in a clean `env -i` shell, is `exercise/solution/SOLUTION.md`.

## RE-MEASURE — the brief's numbers this unit settles

| # | What | 10-06 probe | 10-07 probe | This unit (receipts, 2026-10-07) |
|---|---|---|---|---|
| 1 | Heap dump: size, and the token count | 25,820,969 bytes (bridge, `read-only`); 3 raw copies (`grep -a -o`) | 37,083,969 bytes (Tomcat, `unrestricted`); 3 lines (`grep -c -a -F`) | **floor: over 20,000,000 bytes** (this Mac: 26,568,881-27,056,479 bytes over the six heap dumps of the two runs of record); **3 copies (`grep -a -o`) on 3 lines (`grep -c -a -F`)**, the two methods agreeing, 3/3 in every run |
| 2 | Actuator's start, fork → first 200, against the previous jar's | 1.11× (loaded) | 1.20× (1.15× under load 179) | **over 1×, under 1.25× — judged behind the load gate (RED C5-S4 #1):** this revision's runs of record, quiet (load 5.4-7.9), the starter 1.10-1.16×, the starter and the bridge 1.13-1.18× (six timed captures, medians of five, interleaved); the first revision's 1.12-1.18× and 1.13-1.19× (load 5.0-8.0); under load 17-140 (RED's runs) 0.94-3.40× — so the ratios never enter the capture |
| 3 | Answer sizes: beans · conditions · threaddump · metrics (loggers: the logging unit's) | 52,523 · 41,487 · 21,839 · 928 bytes (bridge) | 51,323 · 41,532 · 19,811 · 913 characters (in-process) | **floors only on screen — over 40,000 · over 30,000 · over 10,000** (this Mac, over this bridge: beans 53,404 · conditions 41,690 · threaddump 20,306-21,846 · metrics 913-928 bytes (env 11,122-11,190, which grows with the shell's variables)); a path-dependent size is no witness (beans names the jar's absolute path 6 times) |
| — | The exercise's masked line | — | `"value":"******"`, source `Config tree '<path>/run/./secrets'` (Tomcat) | **`Config tree '…/secrets' · tiffinbox.shutdown-token = ******`** — the same over the bridge |

## Found on the way

- **The brief's bridge had no access filter.** Boot's own web adapter filters operations twice — exposure, and access
  (`management.endpoint.<id>.access`, `OperationFilter.byAccess(EndpointAccessResolver)`, the resolver a bean of
  `EndpointAutoConfiguration`). Without the second, `--management.endpoint.loggers.access=read-only` would leave the loggers write
  operation callable over the bridge (not measured here: the logging unit's lock); `ActuatorRoutes` passes it, and answers 405 when the
  path exists and the verb does not, as Boot's adapter and TiffinBox's own router do.
- **Auto-configuration classes registered: 10 → 31, not 11 → 32.** The probes counted bean names that contain "AutoConfiguration",
  which takes in `org.springframework.boot.autoconfigure.AutoConfigurationPackages` — a registrar's bean, not an auto-configuration.
  The harness counts the imports files' candidates that became bean definitions (`ImportCandidates`).
- **The metadata's Compose entries are 3 with Actuator** only when counted as the brief did — any name holding `docker.compose`: the
  Compose module's two listeners and Micrometer's own Compose connection factory. With the excludes: 0.
- **The jar's size depends on how the dependency is written**: the jar carries its POM, so the starter as one line or as four changes
  the bytes the jar gains (2,079,352 here against the probes' 2,079,345). "About two megabytes" holds for either.
- **`show-values=always` leaves the token twice in one answer**, not once: `/actuator/env/tiffinbox.shutdown-token` names the value in
  its `property` summary and again under its property source.
- **A heap dump leaves no file behind**: with `-Djava.io.tmpdir` set to an empty folder of its own, 0 files were there after the
  answer (Boot's `HeapDumpWebEndpoint` writes the dump to a temporary file and deletes it once sent; the file itself is not captured).
- **The start ratio's scope.** TiffinBox answers `/kitchen` from `@PostConstruct`, mid-refresh: Actuator's beans created after
  `TiffinBoxServer` are not in the clock's number, so the ratio is to a first answer, before Boot calls TiffinBox ready — RED C5-S4 #3
  measured the gap from TiffinBox's line to Boot's started line at 0.14-0.68 s before Actuator, 0.91-1.79 s after; the voice says
  "to its first answer, which comes before ready".
- **Environment names belong to the shell.** An env answer lists the variables the process was started with — even a script's own
  (`DEVRUNS`, an experiment's variable, appeared in one); so the capture compares the names with `env -0` instead of counting them.
  And `_` belongs to the shell: under bash 5.3 the JVM's environment held `_`, under /bin/bash 3.2 it did not — the first run of
  record under 5.3 said "the same names: no" for that alone, so the comparison leaves `_` out on both sides. One more belongs to
  macOS: CoreFoundation writes `__CF_USER_TEXT_ENCODING` into a process's environment when it is missing. A shell opened in a
  terminal already holds it; under `env -i` (the clone run above) the JVM held it and `env -0` did not, and `tour` said "no" for that
  alone (measured again with a one-line Java program that prints `System.getenv()`'s names). The comparison leaves it out too.
- **A proxy in your environment takes curl's requests for 127.0.0.1 too.** The first clone run set `http_proxy` and the rest to a
  port that refuses: curl sent every request for `127.0.0.1` there (`curl -v`: "Uses proxy env variable http_proxy"), each of the
  seven answered `000`, the `POST /shutdown` never arrived, and `cost` stopped on "still running 15 s after POST /shutdown".
  `receipts.sh` now puts `127.0.0.1` and `localhost` first in `no_proxy` and `NO_PROXY` (Hygiene, above). `harness/ttfr.py` uses
  `http.client`, which reads no proxy variable.

## For units 22 and 25 — and for RED

**Start from `../c5-unit21/after`** (the anchor has moved on since: `../c5-tiffinbox` is unit 26's `after/`). What you can rely on — measured here unless
a line says otherwise:
- `/actuator` is TiffinBox's own server's context, served by `ActuatorRoutes.actuatorHandler`: exposure from
  `management.endpoints.web.exposure.*` (the anchor: `health`), access from `management.endpoint.<id>.access`. **Health groups,
  liveness and readiness exist** (`{"status":"UP","groups":["liveness","readiness"]}`); details and components are hidden by default
  (the brief's merge check: `/actuator/health/<component>` answers 404 unless components are shown — not re-measured here). A new
  `HealthIndicator` bean should need no change to the bridge — the health operation reads Boot's registry of contributors — and a
  readiness group (`management.endpoint.health.group.readiness.include`) is Boot's own setting; unit 22 measures both.
- The handler gathers an operation's arguments as Spring MVC's adapter does (RED C5-S4 #2, #4, #46 — fixed here, 2026-10-08): path
  variables (`{name}`, `{*path}`), then — for a write that takes arguments — a JSON body, refused `415` without a JSON `Content-Type`
  (`application/json`, Boot's two vendor types; any parameters, any case) and `400` when it is empty or no JSON object, then the
  query string (one value a String, several a list — the query wins over the body, as in Boot's adapter); the `Accept` header (Boot's
  `Producible` argument: prometheus' formats; and the answer's type: `application/json` asked, `application/json` given). Boot's
  `InvalidEndpointRequestException` (a missing argument, `ParameterMappingException` for one Boot can't map) → 400. It takes the
  status and the content type from a `WebEndpointResponse` (health's 503 for DOWN arrives that way), streams a `Resource`, writes a
  String as text and anything else as JSON with TiffinBox's Jackson 2; no match → 404, a known path with another verb → 405, an
  `Exception` or a `LinkageError` → 500 `{"error":"<class>"}`. **Measured against Boot's own adapter** (`ways` and `tour`, eight
  requests each; and in BLUE's one-JVM probe, the bridge and Tomcat side by side, over 30 more — RED C5-S4's part A adjudication): the same answers but two — a JSON write with an
  empty body (or `null`, or an empty body and a query): the bridge `400`, Boot's adapter `204` and the level reset or set; and
  `/actuator`: the bridge 404, Boot's adapter its links. A cross-origin page cannot write a level through either: its no-preflight
  types (`text/plain`, a form) get 415, and a JSON write needs a preflight neither allows (the bridge: 405; Boot's: no
  `Access-Control-Allow-Origin`).
- **Under AOT and in the binary the endpoints are the built ones** — `prometheus` must go into `application.yaml` (⚑3) to reach the
  binary; a flag widens the list on the plain JVM only. A run-time list still filters what was built: without `health` it takes
  health, liveness and readiness away (`aot` C).
- Every health assertion waits for readiness: `ready()` in `receipts.sh` (every 0.25 s, up to 60 s, not printed).
- The seed: `.m2-demo` = `../c5-unit20/.m2-demo` + `../../spring-boot/_research/m2-seed-s4/`, less `com/tiffinbox/` — Micrometer's
  Prometheus registry and DevTools are in it.
- Ports: 22 on 19010-19019, 25 on 19040-19049 (⚑10); nothing of this unit listens after it ends (`Interrupted`).
- **Unit 25** (DevTools in a copy under `.harness/dev/`): ⚑2's excludes are in Boot's plugin now; DevTools optional would need one more
  `<exclude>` there for the AOT step and one more native-plugin `<exclusion>` (the brief's measurement), neither in the anchor. The web
  module now holds one more class, `ActuatorRoutes` (a `@Configuration(proxyBeanMethods = false)`, so no CGLIB subclass) and its
  handler's lambda: the probe's count of `RestartClassLoader`'s classes (6) was made before it — re-count on this tree. A restart
  should rebuild the bridge's beans with the context, and `/actuator` is created in `start()`, each time the server opens (unit 25
  measures it).
- **The first answer is not readiness** (the brief's measurement, unit 22's race to capture): `/kitchen` answers while readiness still
  says 503; this unit's captures never assert health before readiness.
