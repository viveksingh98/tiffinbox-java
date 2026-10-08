# c5-unit23 — Metrics with Micrometer

Course 5 · Spring Boot · Section 4, its third unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1, Micrometer
1.17.1, GraalVM CE 25.3.4.1** (native-image 25.0.4.1), 2026-10-07. Actuator already counted the JVM's threads and memory; TiffinBox's
own orders and answers were counted by nobody, in no format a monitoring server reads. This unit reads what Actuator keeps before
the change — the meters' names, the registry, and a scrape that answers 404 even when exposed — gives TiffinBox Micrometer's
Prometheus registry, counts the kitchen's orders with a function counter over the kitchen's own count, times every answer of
TiffinBox's routes, reads the scrape line by line in both formats, breaks the route tag on purpose (a route against a raw URL), and
re-checks the AOT jar and the native binary — where the scrape needs one hint, taken out one name at a time.

**The anchor changes (brief ⚑5, ⚑3):**
- `tiffinbox-web/pom.xml`: **`io.micrometer:micrometer-registry-prometheus`**, no version (Boot's parent manages Micrometer 1.17.1).
  The executable jar's `BOOT-INF/lib`: 39 jars → 46 — the registry and six `prometheus-metrics-*` jars (the Prometheus client 1.7.0).
- `tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenMetrics.java` (**new**, 43 lines with its imports and comments): a
  `MeterBinder` bean that registers two `FunctionCounter`s, **`tiffinbox.orders.cooked`** and **`tiffinbox.orders.value`**, over
  `OrderQueue::cooked` and `OrderQueue::cookedValue` — read whenever the registry is read; the kitchen keeps counting and
  `tiffinbox-core` gains no dependency. And the native binary's one hint: `@RegisterReflection(classNames =
  "com.sun.management.OperatingSystemMXBean", memberCategories = MemberCategory.INVOKE_PUBLIC_METHODS)`.
- `TiffinBoxServer.java`: a `MeterRegistry` constructor parameter; `handle()`'s body moves into a `try` whose `finally` stops a
  `Timer.Sample` into **`tiffinbox.requests`**, tagged **`route`** — the key of the route TiffinBox declares (`GET /customers`), or
  `UNKNOWN` when no route takes the request's verb — and **`status`** (`exchange.getResponseCode()`). Its routes, its stop and its
  catch are unchanged.
- `ActuatorRoutes.java`: **one code line** (and its comment) — a `byte[]` answer is written as it is. Boot's Prometheus endpoint hands
  the scrape over as bytes, and the bridge wrote every answer but a `Resource` or a `String` as JSON: the scrape answered 200 with Prometheus's content
  type and a body that was one JSON string, base64 of the scrape (`scrape`, C). Not in the brief: found here.
- `application.yaml`: **`management.endpoints.web.exposure.include: health,prometheus`** (⚑3), its comment updated.
- **Not edited:** `tiffinbox-core` (`change`: 0 files differ), `TiffinBoxApp.java` (⚑11) and `KitchenHealthIndicator.java`.

When this unit was made, `c5-tiffinbox` and this unit's `after/` held the change and the anchor README's new section, and nothing
else (`diff -rq -x target ../c5-tiffinbox after` was empty); the anchor has moved on since: `../c5-tiffinbox` is unit 27's `after/` (`diff -rq -x target ../c5-tiffinbox ../c5-unit27/after` is empty). **Unit 24 starts from `after/`** (see the last section).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 8 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) It runs for 25 to 100 minutes on the author's Mac, and its nine native builds decide which. **This revision's runs of record
(2026-10-08, RED C5-S4 part A's fixes):** 6,011 s under `./receipts.sh` (/bin/bash 3.2.57, in place, exit 0, every capture = published)
and 3,775 s under `bash receipts.sh` (Homebrew bash 5.3.9, from a sealed clone, exit 0 — "From a clone", below), beside two to four
other units' receipts (load averages about 120-410; native builds 288-846 s, every one inside the 20-minute bound); the four hashes
that moved (`change`, `scrape`, `timer`, `native`) were published from a 3.2 run, 3/3, every check passed (4,547 s). The first
revision's: 2,550 s under `./receipts.sh`
(/bin/bash 3.2.57) and 1,599 s under `bash receipts.sh` (Homebrew bash 5.3.9) for the two runs of record, 2026-10-07 — the first
while another agent's work held the load average between about 15 and 105 (its native builds 147-463 s), the second on a quieter
Mac (145-158 s); every native build inside the capture's bound, under 20 minutes. The first run published `receipts.md5` (its last
line said so, as designed); the second matched every hash and exited 0.
It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first, so you can see which one moved).
Published hashes: before `f12a734f7395c936d19679752ed83596` · change `a529d6ae3888e8ceea294296518b12f4` · scrape `cc70a200f02044a26014553f10e84a4b` · counter `e9dbf7d48b9648b1281075c35e5f1ac5` · timer `014f7c731608f8234c68357ca7c7aaae` · cardinality `cc1b320d8fa3f5b08a728f5602b684a5` · native `562721510962b6ec02aefdb9c2b82213` · exercise `855f5f36785dc51d0deb8245fb3f49c5`

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else. It refuses a variable that does not name a
`bin/native-image`, and one whose `native-image --version` is not `native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1` — another
GraalVM prints other lines, so the captures could not match. The GraalVM's folder is never printed: every capture masks it as
`$GRAALVM_HOME`. Only `native` needs it: every Maven run and every `java` here is the plain JDK 25.0.4.1.

**Without a GraalVM** (`GRAALVM_HOME` not set): `receipts.sh` still runs. It fills `.m2-demo` (its first build), makes every
capture but `native` — `before`, `change`, `scrape`, `counter`, `timer`, `cardinality` — and the exercise's, each checked against
`receipts.md5`, then stops where the native build would start, naming this section (exit 1).

## The repository, and what was downloaded

Every build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen): `../c5-unit22/.m2-demo` **less `com/tiffinbox/`**
(every run installs its own two modules first), checked against the S4 seed (`spring-boot/_research/m2-seed-s4/`: nothing missing) —
5,418 files before this unit's own installs. **Nothing was downloaded** for this unit: every build said `offline: yes`, the
native-profile ones included. The registry's eight artifacts — `micrometer-registry-prometheus` 1.17.1 and the Prometheus client 1.7.0
(`prometheus-metrics-config`, `-core`, `-exposition-formats`, `-exposition-textformats`, `-model`, `-tracer-common`) — were in the
seed since the brief's probe fetched them from Maven Central once (2026-10-06, the brief's 40 files).

**One way out is not Maven's.** GraalVM's native plugin reads its metadata repository (a zip,
`graalvm-reachability-metadata-1.1.8-repository.zip`, 3,362,517 bytes, from Maven Central) from the Maven repository — and when the
zip is not there it does not fail, even under `-o`: it downloads one from GitHub. So (1) the first build is the README's native
install, which needs nearly every artifact any capture's Maven line needs, the zip included — on a fresh clone it fills `.m2-demo`
from Maven Central, once; (2) a native-profile build while the zip is not in `.m2-demo` goes to Maven Central at once, never
offline first; (3) after the first build the script checks Boot's parent POM, Micrometer 1.17.1 (core and the registry), the native
plugin 1.1.8 and the zip are in `$M2`; (4) every build's log is searched for the plugin's own download line — found, the build's line
says `offline: no` and the run stops. (native-image prints one GitHub address in every build: its documentation link, never a
download.)

**From a clone, sealed — this revision (2026-10-08, RED C5-S4 part A's fixes; brief S4.2).** The repository was cloned (`git clone`
of its HEAD) into an empty folder, and the seven folders this revision changes — `c5-unit21` to `c5-unit26` and `c5-tiffinbox` — put
in exactly as the commit holds them (212 files, nothing git ignores: no `.m2-demo`, no `.harness/`, no `.r-*` anywhere; `README.md`
and `exercise/solution/SOLUTION.md` are the only files of this unit's folder changed since — by this paragraph, the run-times
note and the solution's measured-run date; the other folders' later changes touch nothing this run reads). `bash receipts.sh` (Homebrew bash 5.3.9) ran under
`env -i`, with a `HOME` whose `.mavenrc` points Maven's `user.home` there (Java reads `user.home` from the account, not from `$HOME`)
and every Java proxy property at a port that refuses (127.0.0.1:9), and whose Maven settings send every repository to a `file://`
copy of Central's files made from the units' `.m2-demo` (4,060 files: TiffinBox's own installs, `_remote.repositories`,
`*.lastUpdated`, `resolver-status.properties` and `.DS_Store` left out, `maven-metadata-central.xml` served as `maven-metadata.xml`);
`http_proxy`, `https_proxy`, their capitals and `ALL_PROXY` at the same refusing port; `GRAALVM_HOME` set. **Exit 0 after 3,775 s** —
all 8 captures = published, every spoken number asserted, 0 raw demo tokens. One build said `offline: no` — the first (GraalVM's
metadata repository was not in the empty `.m2-demo`) — and took 508 files, every one from the `file://` copy, 0 from anywhere else;
every later build said `offline: yes`; `.m2-demo` ended with 1,381 files; the build logs hold 0 `https://repo` lines and 0 lines of
the native plugin's metadata download. **The first revision's clone test (2026-10-07) was not sealed:** its `HOME` held Maven
settings and no `.mavenrc`, so Maven read the account's settings (RED C5-S4 #9 measured it) and went to Maven Central itself; RED's
own sealed re-run of that revision (`.mavenrc`, the same `file://` method, no GraalVM) passed 7/7 and stopped as announced.

## The demo token — fake, and never printed

TiffinBox does not start without its shutdown token. Every run starts in a folder under `.harness/` holding a config tree,
`secrets/tiffinbox/shutdown-token` (`-rw-------`, folders `drwx------`), with a 26-character demo token that is fake and looks it;
`receipts.sh` writes it when it runs. The token never reaches a command line: the seven requests read it from the file. Every capture
is masked — the token becomes `[masked: the 26-character token]` — and `receipts.sh` counts the raw token in each run's own output
**before** masking (`.harness/raw-*`: 0 in all 24 capture runs), in **every scrape, metrics answer and beans answer it saves on the way
— each counted, then deleted in the same step** (`gone()`: the run of record counted 69 of them, 0 each), then in every capture,
this README, the exercise, the harness, `receipts.md5`, the anchor README, `application.yaml`, `KitchenMetrics.java`,
`TiffinBoxServer.java`, `ActuatorRoutes.java`, and in the **bytes of the three binaries** each run builds: 0 each. The builder counts
it again in the script, the deck and the prompter: 0. No meter here carries the token: a tag's value is a route, a status, or a
JVM's own name. The exercise makes a random token of its own, which it never prints either.

## The folders, the variables and the ports

- `.harness/before/` — the previous tree, `../c5-unit22/after`, copied (for `change`; its `ActuatorRoutes.java` for `scrape`'s C);
  `.harness/after/` — `after/` copied and built with the README's native install (the run's first build: it fills `.m2-demo` on a
  fresh clone).
- `before`: `.harness/prev/` (the previous tree, built the README's plain way). `scrape`, `counter`, `timer`, `cardinality` A and A′:
  `.harness/serve/` (after/, built the README's plain way); `scrape`'s C: `.harness/oldbridge/` (after/ with the previous tree's
  `ActuatorRoutes.java`); `cardinality` B: `.harness/rawtag/` (after/ with the route tag's one line flipped). `native`:
  `.harness/nat/` (after/, the README's two native lines), `.harness/nat-none/` (the hint's line deleted), `.harness/nat-unix/` (the
  other interface's name in its place). The exercise: `.harness/mine/`. (`native`'s A′ runs `.harness/nat`'s binary again.)
- The harness: `harness/shutdown.sh` (POST /shutdown with the token from a file, the exercise's stop; copied from the health lesson's).
  No Java harness: every capture runs TiffinBox as the README runs it, or a copy with one line changed (shown as a `diff`).
- On screen: `$CURLSET` = `../c5-unit11/curlset.sh`, the comparison set since the secrets lesson; `$M2` = this unit's `.m2-demo`;
  `$GRAALVM_HOME` = the GraalVM. Every other command is printed whole.
- Ports (brief ⚑10, 19020-19029, checked free with `lsof` before anything is wiped; 18425 and 8080 too): `before` 19020 · `scrape`
  19021 · `counter` 19022 · `timer` 19023 · `cardinality` 19024 · `native` 19025 · the exercise 19029; 19026-19028 unused.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM and the token** (`gsub()`, the patterns escaped as literals), in every line of every capture: the demo token
   → `[masked: the 26-character token]`; the GraalVM's folder → `$GRAALVM_HOME`; this folder's absolute path → `…` (also
   URL-encoded); the folder above it → `…/..`; the home folder → `~`; the user name → `<user>`. A last check fails if any capture
   still holds `/Users/`, `/private/`, `/home/` or `/var/folders/`, the GraalVM's folder, a unit number, or a `jvm_`, `process_`,
   `system_`, `disk_`, `executor_` or `application_` sample with a value.
2. **A scrape is never printed whole** (S4.13): it names this computer's memory, threads, processors and load, a disk's sizes and the
   folder TiffinBox runs in (`disk_free_bytes{path="…"}`). Each is written by the README's own curl line (`-o scrape.txt`) beside the
   run's config tree, read through a declared filter, and deleted in the same step (`gone()`); the exit trap deletes any left, and a
   last check fails if one is. The filter prints: its status and content type (curl's `-w`); the first word of each family it declares
   (`# TYPE`), each once; **every `tiffinbox_` line**, whole, in its own order — a timer's `_sum` and `_max` samples **masked by name**
   (`<masked: a duration>`: they vary); three lines of one JVM family, `jvm_threads_live_threads`, its value masked; in `native`, the
   names of its `process_` families. Every other line is **not printed, and counted as a bound — over 150** (162 to 169 here): their
   exact number moves (a collection adds `jvm_gc_pause`; the brief's probes counted 43 and 44 families, and 43 against 58 on another
   tree), so an exact count would be a moving witness (S4.19), and RED C5-S4 #21 asked for the cut counted. `application_ready_time_seconds` — Boot's log-line duration as a gauge — is never printed (S4.9).
3. **Actuator's metrics and beans answers** (exposed by the README's flag line for one run) are written the same way and read as JSON:
   metrics — the first word of every meter name, each once; how many names start `http.` and `tiffinbox.`, and the `tiffinbox.` ones;
   never the total (S4.19); one meter's answer — its name, its `COUNT`, and the names of the tags it offers (never its time
   statistics). Beans — each bean whose name ends in `MeterRegistry`, and its class; never a bean's resource (a class path).
4. **Maven's and native-image's logs** are read, never printed whole: each build's `offline`/`exit` line; native-image's goal, the
   GraalVM it found, the builder's Java, its three warnings (the file URL cut), the eight stage names, the warning count and `BUILD
   SUCCESS`, the rest counted; every log searched for the plugin's metadata-repository download line.
5. **No duration is captured**: each native build is judged against a bound (1 minute or more, under 20 minutes — native builds here
   took up to 8 minutes under load); its seconds go to the terminal.
6. **Hygiene:** `receipts.sh` unsets every `TIFFINBOX_*`, `SPRING_*`, `MANAGEMENT_*`, `SERVER_*` and `LOGGING_*` variable, `DEBUG`,
   `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`, `_JAVA_OPTIONS`, `MAVEN_OPTS`, `MAVEN_ARGS` and `NATIVE_IMAGE_OPTIONS` before it runs anything
   (a `MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE` of yours would otherwise change every exposure); it puts `127.0.0.1` and `localhost`
   first in `no_proxy` and `NO_PROXY`; it refuses to run twice at once in this folder (`.r-lock`), with a `secrets/` in this folder, or
   with a `secrets/`, a `tiffinbox-local.yaml` or a `target/` in `after/`. No capture reads the process's environment, so macOS's
   `__CF_USER_TEXT_ENCODING` (CoreFoundation writes it into a process's environment) changes nothing here. **S4.16:** a last check
   greps this script, this README, the exercise's and every capture for an exposure list with a star, and fails on any.

**Interrupted.** `receipts.sh`'s exit trap stops the process it started in the background (a TiffinBox jar or binary), if one still
runs, then `sweep()`s this run's process group for anything of this run — a TiffinBox JVM (its jar), a binary, native-image's driver
or its builder JVM (`java @…/vminvocation.args`) — TERM, then KILL after 5 s; then it deletes any scrape, metrics or beans answer a
run left, and, after an interrupt only, the capture runs left unfinished (`.r-NAME.1-3`; after a failed check they stay, for the diff
the message names); then it drops the lock. Maven and native-image run in the foreground: Ctrl-C reaches them directly. Every command
in the trap is guarded, so `set -e` cannot end it early. **Tested 2026-10-07 on the final script, twice**, with `receipts.sh` as a job of its own process group (job control on, as a
terminal's foreground job is) and `SIGINT` sent to the whole group: **(1) during `before`**, 17 s in, the moment the previous tree's
jar listened on 19020 (in the group: 3 processes — the script, that TiffinBox JVM, and the filter's `python3`) — **exit 130**; 5 s
later 0 processes in the group, and anywhere 0 processes whose command names this unit's folder; 18425, 8080 and 19020-19029 free;
`.r-lock` gone; no scrape, metrics or beans answer and no unfinished capture file left; **(2) during the native build**, 163 s in,
20 s after native-image's builder JVM appeared (in the group: 5 processes — the script and its subshell, Maven, native-image's
driver, its builder) — **exit 130**, and the same: nothing left, every port free. (The count of processes left is scoped to this
unit's folder: other agents run TiffinBoxes of their own on this Mac, on their own ports.)

## 1 · before — the previous tree: the meters Actuator already keeps, and no scrape

The previous tree, built the README's plain way and run with the README's flag line, which exposes `metrics`, `beans` and
`prometheus` for that run alone (S4.16): the scrape answers 404 — exposed, but there is no Prometheus registry, so there is no
endpoint (the bridge's own `{"error":"not found"}`); the meters' names by first word (never the total), none `http.` and none
`tiffinbox.`; the registry bean, `SimpleMeterRegistry`; one request to TiffinBox, then the names again — still no `http.` name: Boot
times the servers it runs, not TiffinBox's JDK server.

`.r-before.out` · md5 `f12a734f7395c936d19679752ed83596` · 3 of 3

```
the previous tree (the anchor as the health lesson left it), copied to .harness/prev with a config tree, built the README's
plain way; run with the README's flag line - Actuator's metrics endpoints exposed for this run - port 19020:
$ cd .harness/prev && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the previous tree · offline: yes · exit 0
$ cd .harness/prev && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19020 --management.endpoints.web.exposure.include=health,prometheus,metrics,beans
  listens on: 127.0.0.1:19020
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19020/actuator/health/readiness
  {"status":"UP"} 200
the scrape, exposed by the flag:
$ cd .harness/prev && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19020/actuator/prometheus
  404 application/json
  what it wrote: {"error":"not found"}
  the demo token in it: 0 · deleted: yes
the meters' names:
$ cd .harness/prev && curl -s -o metrics.json -w '%{http_code}\n' http://127.0.0.1:19020/actuator/metrics
  200
  its names' first words: application disk executor jvm logback process system · names starting http.: 0 · tiffinbox.: 0
  the demo token in it: 0 · deleted: yes
the registry that keeps them:
$ cd .harness/prev && curl -s -o beans.json -w '%{http_code}\n' http://127.0.0.1:19020/actuator/beans
  200
  the registry bean: simpleMeterRegistry · io.micrometer.core.instrument.simple.SimpleMeterRegistry
  the demo token in it: 0 · deleted: yes
one request to TiffinBox, then the names again:
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19020/customers
  200
$ cd .harness/prev && curl -s -o metrics.json -w '%{http_code}\n' http://127.0.0.1:19020/actuator/metrics
  200
  its names' first words: application disk executor jvm logback process system · names starting http.: 0 · tiffinbox.: 0
  the demo token in it: 0 · deleted: yes
$ $CURLSET 19020 .harness/prev/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```


## 2 · change — the previous tree against after/

`diff -rq` of the two trees (copied under `.harness/`): six entries. The POM's gained lines that are neither comment nor blank;
KitchenMetrics counted, and its key lines (`grep -n`); TiffinBoxServer's key lines now (its diff counted: `handle()`'s body moves into
a `try`, re-indented); ActuatorRoutes' one changed code line; application.yaml's gained line; the anchor README's new section,
counted; tiffinbox-core compared (`diff -rq -x target`: 0 files), `TiffinBoxApp.java` and `KitchenHealthIndicator.java` byte for byte.

`.r-change.out` · md5 `a529d6ae3888e8ceea294296518b12f4` · 3 of 3

```
the previous tree against after/, both copied under .harness/ - the files that differ:
$ diff -rq -x target -x secrets .harness/before .harness/after
  Files .harness/before/README.md and .harness/after/README.md differ
  Files .harness/before/tiffinbox-web/pom.xml and .harness/after/tiffinbox-web/pom.xml differ
  Files .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/ActuatorRoutes.java and .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web/ActuatorRoutes.java differ
  Only in .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web: KitchenMetrics.java
  Files .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java and .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java differ
  Files .harness/before/tiffinbox-web/src/main/resources/application.yaml and .harness/after/tiffinbox-web/src/main/resources/application.yaml differ
  tiffinbox-web/pom.xml - the lines it gains that are neither comment nor blank:
        <dependency>
          <groupId>io.micrometer</groupId>
          <artifactId>micrometer-registry-prometheus</artifactId>
        </dependency>
    (diff adds 8 lines, removes 0)
  tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenMetrics.java - new: 43 lines · imports 7 · comment lines 13 · blank 5 - its key lines (grep -n):
    24: @Component
    25: @RegisterReflection(classNames = "com.sun.management.OperatingSystemMXBean", memberCategories = MemberCategory.INVOKE_PUBLIC_METHODS)
    26: public final class KitchenMetrics implements MeterBinder {
    35: public void bindTo(MeterRegistry registry) {
    36: FunctionCounter.builder("tiffinbox.orders.cooked", kitchen, OrderQueue::cooked)
    39: FunctionCounter.builder("tiffinbox.orders.value", kitchen, OrderQueue::cookedValue)
  tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java - diff adds 29 lines, removes 13 (the body of handle() moves into a try) - its key lines now (grep -n):
    79: HttpHandler actuator, MeterRegistry registry) {
    158: Timer.Sample sample = Timer.start(registry);
    176: } finally {                                  // a route TiffinBox declares, never what the client typed
    177: sample.stop(Timer.builder("tiffinbox.requests").description("TiffinBox's answers, by route and status")
    178: .tag("route", handler != null ? key : "UNKNOWN")
    179: .tag("status", Integer.toString(exchange.getResponseCode()))
  tiffinbox-web/src/main/java/com/tiffinbox/web/ActuatorRoutes.java - its code lines that changed (the comment above them changed too: diff adds 3 lines, removes 2):
    < byte[] body = value == null ? new byte[0]
    > byte[] body = value == null ? new byte[0] : value instanceof byte[] bytes ? bytes
  tiffinbox-web/src/main/resources/application.yaml - the lines it gains that are neither comment nor blank:
            include: health,prometheus
    (diff adds 5 lines, removes 4)
  README.md - the anchor's README: lines added 84, removed 0 - its new section (not shown)
  tiffinbox-core against the previous tree's (diff -rq -x target): 0 files differ
  TiffinBoxApp.java against the previous tree's, byte for byte: the same
  KitchenHealthIndicator.java against the previous tree's, byte for byte: the same
```


## 3 · scrape — after/, as the README builds and runs it; and C, the previous bridge

after/'s jar against the previous tree's (`BOOT-INF/lib`: 39 → 46, the 7 added named); run as the README runs it, no flag —
`application.yaml` exposes health and prometheus: the scrape in Prometheus's text format, then the same scrape asked for in OpenMetrics
by the README's `Accept` line, each through the filter (mask 2), and once more with the `Accept` header a Prometheus 3 server sends
with every scrape (its default scrape protocols; the README's third line): OpenMetrics too — a Prometheus server reads OpenMetrics by
default, and curl, asking for nothing, gets the older text format (RED C5-S4 #18); then the README's flag line: the registry bean and
the names. Then
**C (labelled)**: a copy of after/ whose `ActuatorRoutes.java` is the previous tree's — the one code line `diff` shows — built and
scraped: Prometheus's content type, and a body that is one JSON string; decoded (base64), its first line is the scrape's.

`.r-scrape.out` · md5 `cc70a200f02044a26014553f10e84a4b` · 3 of 3

```
after/, copied to .harness/serve with a config tree, built the README's plain way:
$ cd .harness/serve && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built after/ · offline: yes · exit 0
  its jar's BOOT-INF/lib against the previous tree's: 39 jars -> 46 · added 7: micrometer-registry-prometheus-1.17.1.jar prometheus-metrics-config-1.7.0.jar prometheus-metrics-core-1.7.0.jar prometheus-metrics-exposition-formats-1.7.0.jar prometheus-metrics-exposition-textformats-1.7.0.jar prometheus-metrics-model-1.7.0.jar prometheus-metrics-tracer-common-1.7.0.jar · removed 0
run as the README runs it - no flag: application.yaml exposes health and prometheus - port 19021:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19021
  listens on: 127.0.0.1:19021
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19021/actuator/health/readiness
  {"status":"UP"} 200
the scrape:
$ cd .harness/serve && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19021/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
  its families' first words (# TYPE): application disk executor jvm logback process system tiffinbox
  its tiffinbox_ lines - 6, whole (a timer's sums and maxes masked):
    # HELP tiffinbox_orders_cooked_total Orders the kitchen cooked
    # TYPE tiffinbox_orders_cooked_total counter
    tiffinbox_orders_cooked_total 120.0
    # HELP tiffinbox_orders_value_total What the cooked orders are worth
    # TYPE tiffinbox_orders_value_total counter
    tiffinbox_orders_value_total 24300.0
  three lines of one JVM family (its value masked: this computer's own):
    # HELP jvm_threads_live_threads The current number of live threads including both daemon and non-daemon threads
    # TYPE jvm_threads_live_threads gauge
    jvm_threads_live_threads <masked: this computer's>
  every other line: not printed (memory, threads, processors, a disk and its folder) - over 150, a bound: a collection adds a family
  the demo token in it: 0 · deleted: yes
the same scrape, asked for in OpenMetrics:
$ cd .harness/serve && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' -H 'Accept: application/openmetrics-text; version=1.0.0' http://127.0.0.1:19021/actuator/prometheus
  200 application/openmetrics-text;version=1.0.0;charset=utf-8
  its tiffinbox_ lines - 6, whole:
    # TYPE tiffinbox_orders_cooked counter
    # HELP tiffinbox_orders_cooked Orders the kitchen cooked
    tiffinbox_orders_cooked_total 120.0
    # TYPE tiffinbox_orders_value counter
    # HELP tiffinbox_orders_value What the cooked orders are worth
    tiffinbox_orders_value_total 24300.0
  its last line: # EOF
  the demo token in it: 0 · deleted: yes
  and with the Accept header a Prometheus 3 server sends with every scrape (its default scrape protocols) - the README's line:
$ cd .harness/serve && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' -H 'Accept: application/openmetrics-text;version=1.0.0;q=0.5,application/openmetrics-text;version=0.0.1;q=0.4,text/plain;version=1.0.0;q=0.3,text/plain;version=0.0.4;q=0.2,*/*;q=0.1' http://127.0.0.1:19021/actuator/prometheus
  200 application/openmetrics-text;version=1.0.0;charset=utf-8
  the demo token in it: 0 · deleted: yes
$ $CURLSET 19021 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
the README's flag line - Actuator's metrics endpoints exposed for this run:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19021 --management.endpoints.web.exposure.include=health,prometheus,metrics,beans
  listens on: 127.0.0.1:19021
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19021/actuator/health/readiness
  {"status":"UP"} 200
$ cd .harness/serve && curl -s -o beans.json -w '%{http_code}\n' http://127.0.0.1:19021/actuator/beans
  200
  the registry bean: prometheusMeterRegistry · io.micrometer.prometheusmetrics.PrometheusMeterRegistry
  the demo token in it: 0 · deleted: yes
$ cd .harness/serve && curl -s -o metrics.json -w '%{http_code}\n' http://127.0.0.1:19021/actuator/metrics
  200
  its names' first words: application disk executor jvm logback process system tiffinbox · names starting http.: 0 · tiffinbox.: 2 - tiffinbox.orders.cooked tiffinbox.orders.value
  the demo token in it: 0 · deleted: yes
$ $CURLSET 19021 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
C (labelled) - the bridge as the health lesson left it: a copy of after/ (.harness/oldbridge), its ActuatorRoutes.java the
previous tree's - the code line that differs:
$ diff after/tiffinbox-web/src/main/java/com/tiffinbox/web/ActuatorRoutes.java .harness/oldbridge/tiffinbox-web/src/main/java/com/tiffinbox/web/ActuatorRoutes.java
  < byte[] body = value == null ? new byte[0] : value instanceof byte[] bytes ? bytes
  > byte[] body = value == null ? new byte[0]
$ cd .harness/oldbridge && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the copy · offline: yes · exit 0
$ cd .harness/oldbridge && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19021
  listens on: 127.0.0.1:19021
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19021/actuator/health/readiness
  {"status":"UP"} 200
$ cd .harness/oldbridge && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19021/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
  what it wrote - one JSON string: yes · its first 24 characters: "IyBIRUxQIGFwcGxpY2F0aW9
  that string, decoded (base64) - its first line: # HELP application_ready_time_seconds Time taken for the application to be ready to service requests
  the demo token in it: 0 · deleted: yes
$ $CURLSET 19021 .harness/oldbridge/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```


## 4 · counter — the kitchen's own count, beside the scrape

after/'s jar: `/kitchen` and the scrape's two counters; then the README's line with ten days instead of thirty — the kitchen cooks 40
orders, and both read 40 (the seven hash differently: `/kitchen` answers 40).

`.r-counter.out` · md5 `e9dbf7d48b9648b1281075c35e5f1ac5` · 3 of 3

```
after/'s jar (.harness/serve), run as the README runs it, port 19022:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19022
  listens on: 127.0.0.1:19022
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19022/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19022/kitchen
  {"ordersCooked":120,"ordersValue":24300} 200
$ cd .harness/serve && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19022/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
  tiffinbox_orders_cooked_total 120.0
  tiffinbox_orders_value_total 24300.0
  the demo token in it: 0 · deleted: yes
$ $CURLSET 19022 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
the README's line with ten days instead of thirty:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19022 --tiffinbox.days=10
  listens on: 127.0.0.1:19022
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19022/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19022/kitchen
  {"ordersCooked":40,"ordersValue":8100} 200
$ cd .harness/serve && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19022/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
  tiffinbox_orders_cooked_total 40.0
  tiffinbox_orders_value_total 8100.0
  the demo token in it: 0 · deleted: yes
$ $CURLSET 19022 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 971ad06affd317fbfa4d86a9972ca283
```


## 5 · timer — every route's answer, timed; and C, a tag filter

after/'s jar with the README's flag line (the metrics endpoint exposed for this run): no `tiffinbox_requests` line before the first
answer; the README's status line for each of the four routes, `/nowhere` and `GET /shutdown`, then the README's POST line without the
token; the scrape's `tiffinbox_requests` lines whole, sums and maxes masked; the series counted. **C (labelled)**: the metrics endpoint
asked for the timer — `COUNT 6.0`, tags `route status` — then with the README's `?tag=status:405`: `COUNT 1.0`, the `route` tag left.
Through the bridge, the query string reaches the operation (RED C5-S4 #2: fixed in the Actuator lesson's anchor, carried here; before
the fix both answers were `COUNT 6.0`). What is timed is TiffinBox's own routes — not `/nowhere` (the JDK's 404) and not Actuator's
answers (RED C5-S4 #11); each set of tag values is three series, `_count`, `_sum` and `_max` (#16).

`.r-timer.out` · md5 `014f7c731608f8234c68357ca7c7aaae` · 3 of 3

```
after/'s jar (.harness/serve) with the README's flag line - the metrics endpoint exposed too - port 19023:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19023 --management.endpoints.web.exposure.include=health,prometheus,metrics,beans
  listens on: 127.0.0.1:19023
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19023/actuator/health/readiness
  {"status":"UP"} 200
before TiffinBox has answered anything:
$ cd .harness/serve && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19023/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
  its tiffinbox_requests lines: 0
  the demo token in it: 0 · deleted: yes
the requests, one by one - the four routes, a path no route has, a verb the route does not take, the stop without its token:
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19023/customers
  200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19023/revenue
  200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19023/dashboard
  200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19023/kitchen
  200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19023/nowhere
  404
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19023/shutdown
  405
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19023/shutdown
  {"error":"forbidden"} 403
the scrape:
$ cd .harness/serve && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19023/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
  its tiffinbox_requests lines, whole (sums and maxes masked):
    # HELP tiffinbox_requests_seconds TiffinBox's answers, by route and status
    # TYPE tiffinbox_requests_seconds summary
    tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 1
    tiffinbox_requests_seconds_sum{route="GET /customers",status="200"} <masked: a duration>
    tiffinbox_requests_seconds_count{route="GET /dashboard",status="200"} 1
    tiffinbox_requests_seconds_sum{route="GET /dashboard",status="200"} <masked: a duration>
    tiffinbox_requests_seconds_count{route="GET /kitchen",status="200"} 1
    tiffinbox_requests_seconds_sum{route="GET /kitchen",status="200"} <masked: a duration>
    tiffinbox_requests_seconds_count{route="GET /revenue",status="200"} 1
    tiffinbox_requests_seconds_sum{route="GET /revenue",status="200"} <masked: a duration>
    tiffinbox_requests_seconds_count{route="POST /shutdown",status="403"} 1
    tiffinbox_requests_seconds_sum{route="POST /shutdown",status="403"} <masked: a duration>
    tiffinbox_requests_seconds_count{route="UNKNOWN",status="405"} 1
    tiffinbox_requests_seconds_sum{route="UNKNOWN",status="405"} <masked: a duration>
    # HELP tiffinbox_requests_seconds_max TiffinBox's answers, by route and status
    # TYPE tiffinbox_requests_seconds_max gauge
    tiffinbox_requests_seconds_max{route="GET /customers",status="200"} <masked: a duration>
    tiffinbox_requests_seconds_max{route="GET /dashboard",status="200"} <masked: a duration>
    tiffinbox_requests_seconds_max{route="GET /kitchen",status="200"} <masked: a duration>
    tiffinbox_requests_seconds_max{route="GET /revenue",status="200"} <masked: a duration>
    tiffinbox_requests_seconds_max{route="POST /shutdown",status="403"} <masked: a duration>
    tiffinbox_requests_seconds_max{route="UNKNOWN",status="405"} <masked: a duration>
  series (one per _count line): 6 · a series for /nowhere: 0
  the demo token in it: 0 · deleted: yes
C (labelled) - the metrics endpoint, the timer asked for alone, then filtered by a tag (Boot's ?tag=):
$ cd .harness/serve && curl -s -o metrics.json -w '%{http_code}\n' 'http://127.0.0.1:19023/actuator/metrics/tiffinbox.requests'
  200
  tiffinbox.requests · COUNT 6.0 · the tags it offers: route status
  the demo token in it: 0 · deleted: yes
$ cd .harness/serve && curl -s -o metrics.json -w '%{http_code}\n' 'http://127.0.0.1:19023/actuator/metrics/tiffinbox.requests?tag=status:405'
  200
  tiffinbox.requests · COUNT 1.0 · the tags it offers: route
  the demo token in it: 0 · deleted: yes
$ $CURLSET 19023 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```


## 6 · cardinality — the break (A/B/A′): what the route tag holds

Four URLs in every run, each 200 — `/customers/7`, `/customers/8`, `/customers`, `/customersXYZ` (the JDK server matches a context by
prefix, so all four reach the `/customers` route); then the scrape's `tiffinbox_requests_seconds_count` lines, counted. **A** = after/'s
jar as the README runs it; **B** = a copy of after/ whose route tag holds the raw path, as the client typed it (`diff`: one line);
**A′** = A re-run, the same command.

`.r-cardinality.out` · md5 `cc1b320d8fa3f5b08a728f5602b684a5` · 3 of 3

```
the break: what the route tag holds. Four URLs in every run - three no route declares; port 19024.
A - after/'s jar (.harness/serve), as the README runs it (the tag: the route TiffinBox declares):
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19024
  listens on: 127.0.0.1:19024
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19024/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19024/customers/7
  200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19024/customers/8
  200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19024/customers
  200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19024/customersXYZ
  200
$ cd .harness/serve && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19024/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
  its tiffinbox_requests_seconds_count lines:
    tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 4
  series: 1
  the demo token in it: 0 · deleted: yes
$ $CURLSET 19024 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
B - a copy of after/ (.harness/rawtag) whose tag holds the raw path, as the client typed it - the one line that differs:
$ diff after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java .harness/rawtag/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
  178c178
  <                     .tag("route", handler != null ? key : "UNKNOWN")
  ---
  >                     .tag("route", exchange.getRequestMethod() + " " + exchange.getRequestURI().getPath())
$ cd .harness/rawtag && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the copy · offline: yes · exit 0
$ cd .harness/rawtag && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19024
  listens on: 127.0.0.1:19024
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19024/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19024/customers/7
  200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19024/customers/8
  200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19024/customers
  200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19024/customersXYZ
  200
$ cd .harness/rawtag && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19024/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
  its tiffinbox_requests_seconds_count lines:
    tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 1
    tiffinbox_requests_seconds_count{route="GET /customers/7",status="200"} 1
    tiffinbox_requests_seconds_count{route="GET /customers/8",status="200"} 1
    tiffinbox_requests_seconds_count{route="GET /customersXYZ",status="200"} 1
  series: 4
  the demo token in it: 0 · deleted: yes
$ $CURLSET 19024 .harness/rawtag/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
A' - A again:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19024
  listens on: 127.0.0.1:19024
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19024/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19024/customers/7
  200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19024/customers/8
  200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19024/customers
  200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19024/customersXYZ
  200
$ cd .harness/serve && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19024/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
  its tiffinbox_requests_seconds_count lines:
    tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 4
  series: 1
  the demo token in it: 0 · deleted: yes
$ $CURLSET 19024 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```


## 7 · native — the AOT jar and the binary (S4.14, ⚑12); the hint, one out at a time

after/ built with the README's two native lines: the AOT jar (the README's AOT line) and the binary — readiness, one request, the
scrape (its `process_` families, its `tiffinbox_` samples), the seven. Then Micrometer's own native-image metadata
(`META-INF/native-image/io.micrometer/micrometer-core/reflect-config.json`, read from micrometer-core 1.17.1 in `$M2`) for the
`com.sun.management` interfaces, and whether `ProcessorMetrics` names `getProcessCpuTime`. Then **B**, a copy of after/ built
natively with the hint's line deleted: the scrape answers 500; **C** (labelled), B's binary with the README's line that switches the
CPU-time meter off (`--management.metrics.enable.process.cpu.time=false`, Boot's per-meter switch, read at run time): 200, without
`process_cpu_time_ns_total`; **A′**, A's binary again (no build): 200, every meter — a flipped attribute shown A, B, A′ (RED C5-S4
#19); then **D** (labelled), `com.sun.management.UnixOperatingSystemMXBean` in the hint instead: 200, every meter.

`.r-native.out` · md5 `562721510962b6ec02aefdb9c2b82213` · 3 of 3

```
after/, copied to .harness/nat with a config tree; the README's two Maven lines, offline; $GRAALVM_HOME names the GraalVM:
$ cd .harness/nat && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean install
  built .harness/nat (both modules, into $M2) · offline: yes · exit 0
$ cd .harness/nat && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -pl tiffinbox-web native:compile-no-fork
  its lines, in order (the rest - 154 lines - not shown):
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
the AOT jar - the README's AOT line, port 19025:
$ cd .harness/nat && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19025
  listens on: 127.0.0.1:19025
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19025/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19025/customers
  200
$ cd .harness/nat && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19025/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
  its process_ families: process_cpu_time_ns_total process_cpu_usage process_files_max_files process_files_open_files process_start_time_seconds process_uptime_seconds
  its tiffinbox_ samples (sums and maxes masked):
    tiffinbox_orders_cooked_total 120.0
    tiffinbox_orders_value_total 24300.0
    tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 1
    tiffinbox_requests_seconds_sum{route="GET /customers",status="200"} <masked: a duration>
    tiffinbox_requests_seconds_max{route="GET /customers",status="200"} <masked: a duration>
  the demo token in it: 0 · deleted: yes
$ $CURLSET 19025 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
the binary - the README's line:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19025
  listens on: 127.0.0.1:19025
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19025/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19025/customers
  200
$ cd .harness/nat && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19025/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
  its process_ families: process_cpu_time_ns_total process_cpu_usage process_files_max_files process_files_open_files process_start_time_seconds process_uptime_seconds
  its tiffinbox_ samples (sums and maxes masked):
    tiffinbox_orders_cooked_total 120.0
    tiffinbox_orders_value_total 24300.0
    tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 1
    tiffinbox_requests_seconds_sum{route="GET /customers",status="200"} <masked: a duration>
    tiffinbox_requests_seconds_max{route="GET /customers",status="200"} <masked: a duration>
  the demo token in it: 0 · deleted: yes
$ $CURLSET 19025 .harness/nat/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
Micrometer's own native-image metadata - micrometer-core 1.17.1's reflect-config.json, read from $M2 - for com.sun.management:
  com.sun.management.OperatingSystemMXBean: getCpuLoad getProcessCpuLoad getSystemCpuLoad
  com.sun.management.UnixOperatingSystemMXBean: getMaxFileDescriptorCount getOpenFileDescriptorCount
  getProcessCpuTime - named in Micrometer's ProcessorMetrics class: yes · listed in its metadata: no
B - the hint taken out: a copy of after/ (.harness/nat-none), its @RegisterReflection line deleted:
$ diff after/tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenMetrics.java .harness/nat-none/tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenMetrics.java
  25d24
  < @RegisterReflection(classNames = "com.sun.management.OperatingSystemMXBean", memberCategories = MemberCategory.INVOKE_PUBLIC_METHODS)
$ cd .harness/nat-none && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean install
  built .harness/nat-none (both modules, into $M2) · offline: yes · exit 0
$ cd .harness/nat-none && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -pl tiffinbox-web native:compile-no-fork
  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 20 minutes · offline: yes
  its binary - the README's line, port 19025:
$ cd .harness/nat-none && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19025
  listens on: 127.0.0.1:19025
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19025/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19025/customers
  200
$ cd .harness/nat-none && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19025/actuator/prometheus
  500 application/json
  what it wrote: {"error":"MissingReflectionRegistrationError"}
  the demo token in it: 0 · deleted: yes
$ $CURLSET 19025 .harness/nat-none/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
C (labelled) - B's binary, the README's line that switches the CPU-time meter off (process.cpu.time):
$ cd .harness/nat-none && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19025 --management.metrics.enable.process.cpu.time=false
  listens on: 127.0.0.1:19025
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19025/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19025/customers
  200
$ cd .harness/nat-none && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19025/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
  its process_ families: process_cpu_usage process_files_max_files process_files_open_files process_start_time_seconds process_uptime_seconds
  its tiffinbox_ samples (sums and maxes masked):
    tiffinbox_orders_cooked_total 120.0
    tiffinbox_orders_value_total 24300.0
    tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 1
    tiffinbox_requests_seconds_sum{route="GET /customers",status="200"} <masked: a duration>
    tiffinbox_requests_seconds_max{route="GET /customers",status="200"} <masked: a duration>
  the demo token in it: 0 · deleted: yes
$ $CURLSET 19025 .harness/nat-none/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
A' - A's binary again (.harness/nat, built above) - the README's line:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19025
  listens on: 127.0.0.1:19025
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19025/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19025/customers
  200
$ cd .harness/nat && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19025/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
  its process_ families: process_cpu_time_ns_total process_cpu_usage process_files_max_files process_files_open_files process_start_time_seconds process_uptime_seconds
  its tiffinbox_ samples (sums and maxes masked):
    tiffinbox_orders_cooked_total 120.0
    tiffinbox_orders_value_total 24300.0
    tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 1
    tiffinbox_requests_seconds_sum{route="GET /customers",status="200"} <masked: a duration>
    tiffinbox_requests_seconds_max{route="GET /customers",status="200"} <masked: a duration>
  the demo token in it: 0 · deleted: yes
$ $CURLSET 19025 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
D (labelled) - the other interface's name in its place: a copy of after/ (.harness/nat-unix):
$ diff after/tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenMetrics.java .harness/nat-unix/tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenMetrics.java
  25c25
  < @RegisterReflection(classNames = "com.sun.management.OperatingSystemMXBean", memberCategories = MemberCategory.INVOKE_PUBLIC_METHODS)
  ---
  > @RegisterReflection(classNames = "com.sun.management.UnixOperatingSystemMXBean", memberCategories = MemberCategory.INVOKE_PUBLIC_METHODS)
$ cd .harness/nat-unix && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean install
  built .harness/nat-unix (both modules, into $M2) · offline: yes · exit 0
$ cd .harness/nat-unix && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -pl tiffinbox-web native:compile-no-fork
  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 20 minutes · offline: yes
  its binary - the README's line, port 19025:
$ cd .harness/nat-unix && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19025
  listens on: 127.0.0.1:19025
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19025/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19025/customers
  200
$ cd .harness/nat-unix && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19025/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
  a scrape - its process_ families: process_cpu_time_ns_total process_cpu_usage process_files_max_files process_files_open_files process_start_time_seconds process_uptime_seconds
  its tiffinbox_ samples (sums and maxes masked):
    tiffinbox_orders_cooked_total 120.0
    tiffinbox_orders_value_total 24300.0
    tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 1
    tiffinbox_requests_seconds_sum{route="GET /customers",status="200"} <masked: a duration>
    tiffinbox_requests_seconds_max{route="GET /customers",status="200"} <masked: a duration>
  the demo token in it: 0 · deleted: yes
$ $CURLSET 19025 .harness/nat-unix/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```


## 8 · exercise — the exercise, run as written

`.r-exercise.out` · md5 `855f5f36785dc51d0deb8245fb3f49c5` · 3 of 3

```
exercise/README.md's commands, run exactly as written from this folder - 6 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
  $ mvn -o -B -q -f .harness/mine/after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package
  $ mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
  $ (umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/after/secrets/tiffinbox/shutdown-token)
  exit 0 · printed: 0 line(s)
the solution's line (exercise/solution/SOLUTION.md), run exactly as written, from this folder:
$ (cd .harness/mine/after && exec java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19029 > ../run.log 2>&1) & for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19029/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done; for v in BREW PUT DELETE; do curl -s -o /dev/null -X "$v" http://127.0.0.1:19029/customers; done; curl -s http://127.0.0.1:19029/actuator/prometheus | grep '^tiffinbox_requests_seconds_count'; harness/shutdown.sh 19029 .harness/mine/after/secrets/tiffinbox/shutdown-token; wait
tiffinbox_requests_seconds_count{route="UNKNOWN",status="405"} 3
POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19029 now: 0
```


## Exercise

**Your turn:** call `/customers` with three verbs TiffinBox never declared, then count the request series in the scrape, and say
why. `exercise/README.md` has the commands; done is the line `tiffinbox_requests_seconds_count{route="UNKNOWN",status="405"} 3`; the
measured answer, run exactly as written in a clean `env -i` shell, is `exercise/solution/SOLUTION.md`.

## RE-MEASURE — the brief's items this unit settles

| Item (brief) | The probes | This unit (receipts, 2026-10-07) |
|---|---|---|
| Break B, the raw-path tag | not built (10-06: A only, `route="GET /customers"` 4) | **four series for four URLs** (`route="GET /customers"`, `…/7`, `…/8`, `…XYZ`, 1 each); A and A′ one series, 4 (`cardinality`) |
| Which of the hint's two names is needed alone | not measured (`u23m` carried both) | **either alone serves the scrape**: `OperatingSystemMXBean` (after/: 200, `process_cpu_time_ns_total` present) and `UnixOperatingSystemMXBean` (200, the same families) — the Unix interface extends the other and inherits `getProcessCpuTime()`, and `INVOKE_PUBLIC_METHODS` registers inherited public methods; **neither: 500 `MissingReflectionRegistrationError`**, and with `process.cpu.time` switched off, 200 again (`native`). The anchor keeps the interface that declares the method |
| The scrape over the bridge | 10-06: 200, 10,305 bytes, 43 families (its bridge) | **the anchor's bridge wrote the scrape as one JSON string** (base64) — `ActuatorRoutes` now writes a `byte[]` as it is (`change`, `scrape` C) |
| No `http.server.*` for TiffinBox's requests | 10-07 (Tomcat tree): none for the JDK server | **none, even after a request**, on the bridge tree (`before`, `scrape`) |
| `/nowhere` not timed | 10-06: not timed | **no series**; the JDK's own 404 (`timer`) |
| OpenMetrics | 10-07: no `_total` in the family, `# EOF` | **the same** — `# TYPE tiffinbox_orders_cooked counter`, the sample `…_total 120.0`, last line `# EOF` (`scrape`) |
| The order counter with fewer days | 10-06 (unit 27's probe): 10 days → 40 | **40 and 8100**, `/kitchen` and the scrape alike (`counter`) |
| The bridge and `?tag=` (the task's open item from the health lesson) | not measured | first revision: **dropped** (`COUNT 6.0` with and without `?tag=status:405`); since RED C5-S4 #2's fix in the Actuator lesson's anchor: **passed** — `COUNT 1.0`, the route tag left (`timer` C) |

## Found on the way

- **The bridge wrote the scrape as JSON.** Boot 4.1.1's `PrometheusScrapeEndpoint` answers a `WebEndpointResponse` whose body is a
  `byte[]`; `ActuatorRoutes.respond()` wrote every answer that was neither a `Resource` nor a `String` with TiffinBox's Jackson 2 — and
  Jackson writes a `byte[]` as a base64 string. The answer kept Prometheus's content type (`text/plain;version=0.0.4`), so it looked
  right to anything that reads only the status line. The Actuator lesson never scraped (no registry then: `prometheus` 404), and the
  brief's probe measured its own bridge, not this one. One code line: `value instanceof byte[] bytes ? bytes`.
- **A route key holds a verb a client chooses.** TiffinBox's route key is `VERB path`, and the JDK server hands `handle()` any verb a
  client sends (`BREW`, `PUT`, `DELETE`, `HEAD`, `OPTIONS` each answered 405 in this unit's probe). Tagged with the key, each verb would
  be one more series; the timer tags a verb no route declares as `UNKNOWN` (the exercise measures three verbs, one series).
- **Micrometer's own native metadata misses one method.** micrometer-core 1.17.1 ships `reflect-config.json` with three of
  `com.sun.management.OperatingSystemMXBean`'s methods (`getCpuLoad`, `getProcessCpuLoad`, `getSystemCpuLoad`) and both of
  `UnixOperatingSystemMXBean`'s (`getMaxFileDescriptorCount`, `getOpenFileDescriptorCount`), not `getProcessCpuTime()`, which
  `ProcessorMetrics` names for `process.cpu.time`. The brief's "no metadata registers it" holds for that one method. (The brief's probe
  read the error's own message — `Cannot reflectively invoke method 'public abstract long
  com.sun.management.OperatingSystemMXBean.getProcessCpuTime()'`; here the bridge's wider catch answers 500 with the class's name, and
  switching the meter off pins it instead.)
- **The binary's GC meters.** In the binary Micrometer logs at WARN that GC notifications are unavailable (no
  `GarbageCollectorMXBean` provides them): the binary declares fewer families than the JVM. Not a capture (a log line); named so a
  reader of the binary's log is not surprised.
- **`/customersXYZ` answers the customer list** — a router quirk (the JDK server matches a context by prefix), named on a chip for
  Course 6 (path patterns), not fixed here.

## For unit 24 — and for RED

**Start from `../c5-unit23/after`** (= `../c5-tiffinbox` when this unit was made; the anchor has moved on since: `../c5-tiffinbox` is unit 27's `after/` (`diff -rq -x target ../c5-tiffinbox ../c5-unit27/after` is empty)). What you can rely on — measured here
unless a line says otherwise:
- **`handle()` is now a `try`/`finally`.** The routed body (405, 403, 200/500) sits in a `try`; the `finally` records
  `tiffinbox.requests` with `route` and `status` (`exchange.getResponseCode()` — the status already sent). Your DEBUG line
  (`{verb path} -> {status}`) can read the same status there, after the answer is on the wire; unit 26's wider catch is the inner
  `catch (Exception e)` around `handler.invoke(this)`, unchanged here.
- **Exposure is `health,prometheus`** (application.yaml). `loggers` stays a flag for one JVM run (⚑3); the AOT jar and the binary serve
  the built list only.
- **A timer series per route and status appears with the first answer**; `/actuator/*` requests are not timed (the actuator context is
  the bridge's, not `handle()`). A capture that counts series must count after its own requests, never across runs.
- **The scrape names this computer's numbers and a folder** (`disk_*{path=…}`): never print it whole; filter to `tiffinbox_`, mask
  `_sum`/`_max`.
- **Wait for readiness 200 first** (the kitchen is in readiness), compare JSON with keys sorted, never count Boot's log lines while
  something polls — all as the health lesson said.
- **The bridge passes the query string** — RED decided (C5-S4 #2), and the fix went into the Actuator lesson's anchor and every later
  tree: `ActuatorRoutes.handle()` merges it like Spring MVC's adapter (one value a `String`, several a list), takes a write only as
  JSON (415 otherwise; 400 for an empty body or an argument Boot can't map). `timer` C measures the merge here; unit 24's `lock`
  measures the 415s.
- **The seven** are `115c36ba…` on the jar, the AOT jar and the binary, with or without the hint.
- **The seed:** `.m2-demo` = `../c5-unit22/.m2-demo` less `com/tiffinbox/` (5,418 files); Micrometer's registry and the Prometheus
  client are in it.
- **Ports:** 23 used 19020-19029; nothing of this unit listens after it ends (Interrupted). Unit 24 owns 19030-19039.
