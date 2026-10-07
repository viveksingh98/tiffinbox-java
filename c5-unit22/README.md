# c5-unit22 — Health Indicators, Liveness and Readiness

Course 5 · Spring Boot · Section 4, its second unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1, GraalVM CE
25.3.4.1** (native-image 25.0.4.1), 2026-10-07. Boot's `/actuator/health` on TiffinBox said UP while TiffinBox's database was gone,
and TiffinBox's own routes answer before Boot calls it live or ready. This unit reads what health is made of — components (health
indicators) and two groups, liveness and readiness — measures the race between TiffinBox's first answer and Boot's own states,
gives the kitchen an indicator of its own, closes the database with a harness and reads every answer, breaks the decision the brief
makes (the kitchen in readiness, never in liveness) on purpose, changes readiness by hand and stops TiffinBox with a SIGTERM, and
re-checks the AOT jar and the native binary.

**The anchor changes (brief ⚑4):**
- `tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenHealthIndicator.java` (**new**, 39 lines with its imports and comments): a
  `HealthIndicator` bean — one more component of `/actuator/health`, named by Boot after the bean, `HealthIndicator` left off:
  **`kitchen`**. UP with `customers` (the rows `CustomerRepository.findAll()` returns) and `ordersCooked` (the kitchen's own count)
  while the database answers; DOWN with `error`, the exception's simple class name — never its message — when it does not.
- `application.yaml`: **`management.endpoint.health.group.readiness.include: readinessState,kitchen`**, with a comment — the kitchen
  joins the readiness group beside Boot's own readiness state; liveness stays Boot's liveness state alone; with probes switched off
  this line stops the start (`kitchen`, below).
- **`ActuatorRoutes.java`, `TiffinBoxServer.java` and `TiffinBoxApp.java` are not edited** (`change`: byte for byte the same) — the
  bridge reads Boot's registry of health contributors, so a new indicator needs no new route; RED S2 #8 stays deferred (⚑11).

`c5-tiffinbox` and this unit's `after/` hold the change and the anchor README's new section, and nothing else (`diff -rq -x target
../c5-tiffinbox after` is empty). **Unit 23 starts from `after/`** (see the last section).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 9 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) It runs for 8 to 27 minutes on the author's Mac, and its three native builds decide which: 1,339 s under `./receipts.sh` (/bin/bash
3.2.57) and 1,598 s under `bash receipts.sh` (Homebrew bash 5.3.9) for the two runs of record, 2026-10-07, while another agent's
native builds held the load average between about 40 and 225 (this unit's native builds: 207-456 s each, every one inside the
capture's bound, under 10 minutes); an earlier full run on a quieter Mac took 503 s, its native builds 114-118 s.
It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first, so you can see which one moved).
Published hashes: parts `9a3ce228ac5426d2a1f8905b395bdac5` · race `5cbff7738f6eff151607ffa9817a8244` · change `c0f81182253084c550d11e7f34044e98` · kitchen `7ce6d5a24c34de2262339c959fa2fd15` · dead `b13f60fd44d1234c04adc9d73fe67464` · groups `ec7f685b75f7291de7d99f949df5fbaf` · trap `20f246deb7d812743684fd83577f858d` · native `11bbe9ceb2ae864839af0a8da58c8ad4` · exercise `e206184a3743ef9e03b94281cff11c86`.

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else. It refuses a variable that does not name a
`bin/native-image`, and one whose `native-image --version` is not `native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1` — another
GraalVM prints other lines, so the captures could not match. The GraalVM's folder is never printed: every capture masks it as
`$GRAALVM_HOME`. Only `native` needs it: every Maven run and every `java` here is the plain JDK 25.0.4.1.

**Without a GraalVM** (`GRAALVM_HOME` not set): `receipts.sh` still runs. It fills `.m2-demo` (its first build), makes every
capture but `native` — `parts`, `race`, `change`, `kitchen`, `dead`, `groups`, `trap` — and the exercise's, each checked against
`receipts.md5`, then stops where the native build would start, naming this section (exit 1).

## The repository, and what was downloaded

Every build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen): `../c5-unit21/.m2-demo` **less `com/tiffinbox/`**
(every run installs its own two modules first) — 5,418 files before this unit's own installs. **Nothing was downloaded** for this
unit: every build said `offline: yes`, the native-profile ones included. This unit adds no dependency: `KitchenHealthIndicator`
uses `spring-boot-health` 4.1.1, which Actuator's starter brought in the Actuator lesson.

**One way out is not Maven's.** GraalVM's native plugin reads its metadata repository (a zip,
`graalvm-reachability-metadata-1.1.8-repository.zip`, 3,362,517 bytes, from Maven Central) from the Maven repository — and when the
zip is not there it does not fail, even under `-o`: it downloads one from GitHub. So (1) the first build is the README's native
install, which needs nearly every artifact any capture's Maven line needs, the zip included — on a fresh clone it fills `.m2-demo`
from Maven Central, once; (2) a native-profile build while the zip is not in `.m2-demo` goes to Maven Central at once, never
offline first; (3) after the first build the script checks Boot's parent POM, `spring-boot-health` 4.1.1, the native plugin 1.1.8
and the zip are in `$M2`; (4) every build's log is searched for the plugin's own download line — found, the build's line says
`offline: no` and the run stops.

**From a clone, sealed (2026-10-07, brief S4.2).** The repository was cloned (at this unit's commit, less this paragraph:
`README.md` is the only file changed since) into an empty folder — no `.m2-demo` in this unit or
in unit 21's, no seed folder — and `./receipts.sh` run under `env -i`: a `HOME` whose Maven settings send every repository to a
`file://` copy of Central's files made from `.m2-demo`, and `http_proxy` and the rest pointed at a port that refuses. **With
`GRAALVM_HOME` set: exit 0 after 927 s** — all 9 captures = published, every spoken number asserted, 0 raw demo tokens. **Without it:
the 8 captures that need no GraalVM = published, the exercise's included, then the stop the script announces (exit 1 after 275 s).**
Both times the first build said `offline: no` (the metadata zip was not in the empty `.m2-demo`) and filled it from the copy, every
later build said `offline: yes`, `.m2-demo` ended with 1,328 files, and `github` appears 0 times in either log.

## The demo token — fake, and never printed

TiffinBox does not start without its shutdown token. Every run starts in a folder under `.harness/` holding a config tree,
`secrets/tiffinbox/shutdown-token` (`-rw-------`, folders `drwx------`), with a 26-character demo token that is fake and looks it;
`receipts.sh` writes it when it runs. The token never reaches a command line: the seven requests and `harness/race.py` read it from
the file. Every capture is masked — the token becomes `[masked: the 26-character token]` — and `receipts.sh` counts the raw token in
each run's own output **before** masking (`.harness/raw-*`: 0 in all 27 capture runs), then in every capture, this README, the
exercise, the harness (`race.py`, `shutdown.sh`, the four classes), `receipts.md5`, the anchor README, `application.yaml`,
`KitchenHealthIndicator.java`, and in the **bytes of the binary** each run builds: 0 each. The builder counts it again in the
script, the deck and the prompter: 0. No answer here holds the token: health never carries it, and no endpoint but health is
exposed. The exercise makes a random token of its own, which it never prints either.

## The folders, the variables and the ports

- `.harness/before/` — the previous tree, `../c5-unit21/after`, copied (for `change`); `.harness/after/` — `after/` copied, built
  with the README's native install (the run's first build) and extracted with the README's extract line: the class path the harness
  compiles against (`.harness/hc`), and the folder `race`, `dead`, `groups` and `trap` run in (the README's exploded run, `../hc`
  added to its class path).
- `parts`: `.harness/prev/` (the previous tree, built the README's plain way and extracted). `kitchen`: `.harness/serve/` (after/,
  built the README's plain way). `native`: `.harness/nat/` (after/, the README's two native lines). The exercise: `.harness/mine/`.
- The harness (`harness/`, never TiffinBox's: its package is `probe.health`, outside `com.tiffinbox`, and it joins a run only by
  `--spring.main.sources`, S4.17): `CloseDb` (once Boot has published `ACCEPTING_TRAFFIC` — it waits for the main thread, which
  publishes it after the ready event's listeners and then ends — H2's `SHUTDOWN` on TiffinBox's in-memory database; then one more
  connection to the same URL, and the tables it finds; then `harness: done`), `Witness` (prints each availability state with the thread that published it, and the context's close),
  `Refuse` (a runner that publishes `REFUSING_TRAFFIC`), `RefuseLater` (after Boot's own `ACCEPTING_TRAFFIC`, a thread that publishes
  `REFUSING_TRAFFIC`, then `harness: done`); `race.py` (forks a command and polls three paths in turn, printing only what holds in
  every run); `shutdown.sh` (POST /shutdown with the token from a file, the exercise's stop).
- On screen: `$CURLSET` = `../c5-unit11/curlset.sh`, the comparison set since the secrets lesson; `$M2` = this unit's
  `.m2-demo`; `$GRAALVM_HOME` = the GraalVM; `$pid` = the process the script started (the SIGTERM in `trap`). Every other command
  is printed whole.
- Ports (brief ⚑10, 19010-19019, checked free with `lsof` before anything is wiped; 18425 and 8080 too): `parts` 19010 · `race`
  19011 · `kitchen` 19012 · `dead` 19013 · `groups` 19014 · `trap` 19015 · `native` 19016 · the exercise 19019; 19017 and 19018
  unused.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM and the token** (`gsub()`, the patterns escaped as literals), in every line of every capture: the demo token
   → `[masked: the 26-character token]`; the GraalVM's folder → `$GRAALVM_HOME`; this folder's absolute path → `…` (also
   URL-encoded); the folder above it → `…/..`; the home folder → `~`; the user name → `<user>`. A last check fails if any capture
   still holds `/Users/`, `/private/`, `/home/` or `/var/folders/`, the GraalVM's folder, a unit number, or a disk's details
   (`"total":`, `"free":`, `"path":`).
2. **Boot's log** is read, never printed whole: its first line from its message on, cut before ` with PID`; its started line cut
   before ` in ` (never the `Started … in` seconds, P23). `race` prints TiffinBox's listening line, Boot's started line and the
   witness's lines, in the log's order, and counts the lines it leaves out — Boot's banner and starting lines, TiffinBox's own —
   **except** Spring's INFO notes that a request's thread obtained a bean while the main thread held the singleton lock: their
   number moves from run to run (1 or 2 here), so the capture names them and does not count them (Found on the way). A start that
   fails with Boot's failure analysis (`kitchen`'s fourth run) prints TiffinBox's own line if its server opened first, the banner and
   the stack frames counted, and the analysis's lines whole (S4.19: never a line total).
3. **Health's answers** are printed whole where they hold no machine data — health and its groups without details, the readiness
   group with the kitchen's details, the kitchen's own path with its details — each JSON object's **keys sorted** (`sortjson`,
   Python's `json`, compact). The bridge writes Boot's health answers with TiffinBox's Jackson 2, which lists an answer's
   properties in the order reflection returns them, and that order moved: in one `kitchen` run of 3 (bash 5.3, while another
   agent's native builds held the load average near 190) the kitchen's answer came as `{"details":…,"status":"UP"}`, in the other
   two as `{"status":"UP","details":…}` — the capture drifted and `cap()` stopped the run. Sorted, a capture holds what the answer
   says; 12 quiet runs by hand all gave `status` first (Found on the way). **Health's whole answer with details** (`dead`: it
   names the disk's total, free and path) is written beside the run's config tree as `health.json`, read as JSON through a filter —
   its status, then each component's status — and deleted in the same step; the exit trap deletes it again, and a last check fails
   if one is left. `kitchen` asks the kitchen alone under the details flag.
4. **Maven's and native-image's logs** are read, never printed whole: each build's `offline`/`exit` line; native-image's goal, the
   GraalVM it found, the builder's Java, its three warnings (the file URL cut), the eight stage names, the warning count and `BUILD
   SUCCESS`, the rest counted; every log searched for the plugin's metadata-repository download line.
5. **No duration is captured**: the native build is judged against a bound (1 minute or more, under 10 minutes); its seconds go to
   the terminal. `race` prints no poll count and no time (S4.9): "`/kitchen` answered 200 at least once while liveness and readiness
   both answered 503".
6. **Hygiene:** `receipts.sh` unsets every `TIFFINBOX_*`, `SPRING_*`, `MANAGEMENT_*`, `SERVER_*` and `LOGGING_*` variable, `DEBUG`,
   `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`, `_JAVA_OPTIONS`, `MAVEN_OPTS`, `MAVEN_ARGS` and `NATIVE_IMAGE_OPTIONS` before it runs anything
   (a `MANAGEMENT_ENDPOINT_HEALTH_SHOW_DETAILS` of yours would otherwise change every health answer); it puts `127.0.0.1` and
   `localhost` first in `no_proxy` and `NO_PROXY` (every request it makes goes to `127.0.0.1`; an `http_proxy` of yours would otherwise
   receive curl's requests instead of TiffinBox); it refuses to run twice at once in this folder (`.r-lock`), with a `secrets/` in this
   folder, or with a `secrets/`, a `tiffinbox-local.yaml` or a `target/` in `after/`. **S4.16:** a last check greps this script, this
   README, the exercise's and every capture for an exposure list with a star, and fails on any.

**Interrupted.** `receipts.sh`'s exit trap stops the process it started in the background (a TiffinBox jar, exploded run or binary),
if one still runs, then `sweep()`s this run's process group for anything of this run — a TiffinBox JVM (its jar or the extracted
class path), a binary, native-image's driver or its builder JVM (`java @…/vminvocation.args`: no class name to look for),
`harness/race.py` — TERM, then KILL after 5 s; then it deletes health's whole answer if a run left it (`health.json`), and, after an
interrupt only, the capture runs left unfinished (`.r-NAME.1-3`; after a failed check they stay, for the diff the message names);
then it drops the lock. Maven, native-image and `harness/race.py` run in the foreground: Ctrl-C reaches them directly. Every command
in the trap is guarded, so `set -e` cannot end it early. **Tested 2026-10-07 on the final script, twice**, with `receipts.sh` as a
job of its own process group (job control on, as a terminal's foreground job is) and `SIGINT` sent to the whole group: **(1) during
`parts`**, 61 s in, while the previous tree ran exploded with `CloseDb` (in the group: 4 processes, one of them that TiffinBox JVM) —
**exit 130**; 5 s later 0 processes in the group, and anywhere 0 TiffinBox JVMs, binaries, native-image processes, Maven runs or
race pollers with a working folder in this unit; 18425, 8080 and 19010-19019 free; `.r-lock` gone; no `health.json` and no
unfinished capture file left; **(2) during the native build**, 325 s in, 20 s after native-image's builder JVM appeared (in the
group: 5 processes — Maven, native-image's driver, its builder) — **exit 130**, and the same: nothing left, every port free. (The
count of processes left is scoped to this unit's folder: another agent runs TiffinBoxes of its own on this Mac, on its own ports.)

## 1 · parts — the previous tree: blind to the database, its components, the switch for its groups

The anchor as the Actuator lesson left it (`../c5-unit21/after`), built the README's plain way and extracted. (1) Its exploded run
with the harness's `CloseDb`: health `UP` with its groups while `/customers` answers 500 — nothing in health touches the database;
the seven hash differently with the database gone (`576b655c…`: `/customers`, `/revenue`, `/dashboard` 500). (2) The README's flag
that shows the components: **five** (`diskSpace`, `livenessState`, `ping`, `readinessState`, `ssl`) and **two groups**; Boot's own
liveness and readiness groups answer `{"status":"UP"}` even with the flag — the groups Boot adds itself show no components. (3) The
README's line that switches the groups off (`management.endpoint.health.probes.enabled=false`), components shown: three components,
the two states gone, liveness and readiness **404**. (4) The older key in its place (`management.health.probes.enabled=false`):
liveness and readiness 200 — it changes nothing; Boot's own metadata, read from `spring-boot-health`'s
`spring-configuration-metadata.json` in the jar's lib, gives its deprecation: since 2.3.2, level `error`, replaced by the first.

`.r-parts.out` · md5 `9a3ce228ac5426d2a1f8905b395bdac5` · 3 of 3

```
the previous tree (the anchor as the Actuator lesson left it), copied to .harness/prev with a config tree, built the README's
plain way and extracted (the README's extract line):
$ cd .harness/prev && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the previous tree · offline: yes · exit 0
1 - the database closed by the harness once TiffinBox is ready: the README's exploded run, the harness joined, port 19010:
$ cd .harness/prev && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19010 --spring.main.sources=probe.health.CloseDb
  listens on: 127.0.0.1:19010
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
  harness: readiness ACCEPTING_TRAFFIC, then H2's SHUTDOWN: the database is closed
  harness: the same URL, connected again: a database with 0 tables
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19010/actuator/health
  {"groups":["liveness","readiness"],"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19010/customers
  {"error":"JdbcSQLSyntaxErrorException"} 500
$ $CURLSET 19010 .harness/prev/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 576b655c5d492c41bc52b79ed5feee76
2 - what health is made of: the README's line that shows the components, the same jar, port 19010:
$ cd .harness/prev && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19010 --management.endpoint.health.show-components=always
  listens on: 127.0.0.1:19010
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19010/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19010/actuator/health
  {"components":{"diskSpace":{"status":"UP"},"livenessState":{"status":"UP"},"ping":{"status":"UP"},"readinessState":{"status":"UP"},"ssl":{"status":"UP"}},"groups":["liveness","readiness"],"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19010/actuator/health/liveness
  {"status":"UP"} 200
$ $CURLSET 19010 .harness/prev/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
3 - the switch for the groups: the README's line, the components shown too:
$ cd .harness/prev && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19010 --management.endpoint.health.probes.enabled=false --management.endpoint.health.show-components=always
  listens on: 127.0.0.1:19010
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
  Boot's started line, waited for (its times cut): Started TiffinBoxServer
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19010/actuator/health
  {"components":{"diskSpace":{"status":"UP"},"ping":{"status":"UP"},"ssl":{"status":"UP"}},"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19010/actuator/health/liveness
   404
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19010/actuator/health/readiness
   404
$ $CURLSET 19010 .harness/prev/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
4 - the older key in its place (management.health.probes.enabled):
$ cd .harness/prev && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19010 --management.health.probes.enabled=false
  listens on: 127.0.0.1:19010
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19010/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19010/actuator/health/liveness
  {"status":"UP"} 200
$ $CURLSET 19010 .harness/prev/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
the two keys, as Boot's own metadata states them (spring-boot-health's spring-configuration-metadata.json, in the jar's lib):
  management.endpoint.health.probes.enabled · default true
  management.health.probes.enabled · default false · deprecated since 2.3.2, level error, replaced by management.endpoint.health.probes.enabled
```


## 2 · race — who answers first, polled from the fork

after/'s jar, extracted by the run's first build, run exploded with the harness's `Witness` (S4.18: this layout, so that the poll and
Boot's own event order come from one run). `harness/race.py` forks it and asks `/kitchen`, liveness and readiness in turn, each on
a fresh connection, as fast as it can, until all three answer 200 — then POST /shutdown. It prints only what holds in every run:
the first round in which all three answered — `/kitchen 200 · liveness 503 {"status":"DOWN"} · readiness 503
{"status":"OUT_OF_SERVICE"}` (before Boot publishes a state, liveness reads DOWN and readiness OUT_OF_SERVICE; Boot's status
mapper answers 503 for both) — that `/kitchen` answered 200 at least once while both said 503, the last round, and the exit. Then
the log's order: TiffinBox's server opened (in `@PostConstruct`, during the refresh), Boot's started line, `LivenessState CORRECT`,
`ReadinessState ACCEPTING_TRAFFIC` (both on `main`), the close on `SpringApplicationShutdownHook`.

`.r-race.out` · md5 `5cbff7738f6eff151607ffa9817a8244` · 3 of 3

```
after/'s jar, extracted by the run's first build (.harness/after), run exploded with the harness's witness joined;
harness/race.py forks it and asks /kitchen, liveness and readiness in turn, as fast as it can, until all three answer 200 -
it prints only what holds in every run, never a count - then POST /shutdown, port 19011:
$ cd .harness/after && python3 ../../harness/race.py 19011 secrets/tiffinbox/shutdown-token ../race.out ../race.err -- java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19011 --spring.main.sources=probe.health.Witness
  the first round in which all three answered: /kitchen 200 · liveness 503 {"status":"DOWN"} · readiness 503 {"status":"OUT_OF_SERVICE"}
  /kitchen answered 200 at least once while liveness and readiness both answered 503: yes
  the last round: /kitchen 200 · liveness 200 {"status":"UP"} · readiness 200 {"status":"UP"}
  exit 0 after POST /shutdown 200
the run's log, in order - TiffinBox's line, Boot's started line (its times cut), the witness's lines. Not shown: the other
16 lines (Boot's banner and starting lines, TiffinBox's own), and Spring's notes that a request's thread obtained
a bean while the main thread held the singleton lock - not counted: their number moves from run to run:
  TiffinBox listening on http://127.0.0.1:19011
  Started TiffinBoxServer
  harness: LivenessState CORRECT - published on the thread main
  harness: ReadinessState ACCEPTING_TRAFFIC - published on the thread main
  harness: the context closes - on the thread SpringApplicationShutdownHook
```


## 3 · change — the previous tree against after/

`diff -rq` of the two trees (copied under `.harness/`): the anchor README, `application.yaml`, and one new file. KitchenHealthIndicator
counted, and its key lines (`grep -n`); what `application.yaml` gains that is neither comment nor blank (five lines under
`management:`, nine with the comment); the anchor README's new section, counted; `ActuatorRoutes.java`, `TiffinBoxServer.java` and
`TiffinBoxApp.java` compared byte for byte.

`.r-change.out` · md5 `c0f81182253084c550d11e7f34044e98` · 3 of 3

```
the previous tree against after/, both copied under .harness/ - the files that differ:
$ diff -rq -x target -x secrets .harness/before .harness/after
  Files .harness/before/README.md and .harness/after/README.md differ
  Only in .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web: KitchenHealthIndicator.java
  Files .harness/before/tiffinbox-web/src/main/resources/application.yaml and .harness/after/tiffinbox-web/src/main/resources/application.yaml differ
  tiffinbox-web/src/main/java/com/tiffinbox/web/KitchenHealthIndicator.java - new: 39 lines · imports 5 · comment lines 8 · blank 5 - its key lines (grep -n):
    17: @Component
    18: public final class KitchenHealthIndicator implements HealthIndicator {
    29: public Health health() {
    31: return Health.up()
    32: .withDetail("customers", repo.findAll().size())
    33: .withDetail("ordersCooked", kitchen.cooked())
    35: } catch (Exception e) {
    36: return Health.down().withDetail("error", e.getClass().getSimpleName()).build();
  tiffinbox-web/src/main/resources/application.yaml - the lines it gains that are neither comment nor blank:
      endpoint:
        health:
          group:
            readiness:
              include: readinessState,kitchen
    (diff adds 9 lines, removes 0)
  README.md - the anchor's README: lines added 69, removed 0 - its new section (not shown)
  ActuatorRoutes.java against the previous tree's, byte for byte: the same
  TiffinBoxServer.java against the previous tree's, byte for byte: the same
  TiffinBoxApp.java against the previous tree's, byte for byte: the same
```


## 4 · kitchen — after/, as the README builds and runs it

after/ built the README's plain way, its jar run as the README runs it: readiness first, then health (UP, its two groups) and the
kitchen's own path — **404** while components are hidden. The README's flag that shows the components: readiness now shows its two
— `kitchen` and `readinessState`: a group `application.yaml` defines follows the flag, Boot's own do not — health shows **six**, the
kitchen's path answers `{"status":"UP"}` 200. The README's flag that shows the details, the kitchen asked alone:
`{"details":{"customers":4,"ordersCooked":120},"status":"UP"}` (keys sorted, mask 3). The README's line that switches the groups off:
**the start stops** —
TiffinBox's server had opened its port first — with Boot's failure analysis, 0 stack frames: `Health contributor 'readinessState'
defined in 'management.endpoint.health.group.readiness.include' does not exist` (exit 1).

`.r-kitchen.out` · md5 `7ce6d5a24c34de2262339c959fa2fd15` · 3 of 3

```
after/, copied to .harness/serve with a config tree, built the README's plain way; its jar run as the README runs it, port 19012:
$ cd .harness/serve && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built after/ · offline: yes · exit 0
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19012
  listens on: 127.0.0.1:19012
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19012/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19012/actuator/health
  {"groups":["liveness","readiness"],"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19012/actuator/health/kitchen
   404
$ $CURLSET 19012 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
the README's line that shows the components:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19012 --management.endpoint.health.show-components=always
  listens on: 127.0.0.1:19012
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19012/actuator/health/readiness
  {"components":{"kitchen":{"status":"UP"},"readinessState":{"status":"UP"}},"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19012/actuator/health
  {"components":{"diskSpace":{"status":"UP"},"kitchen":{"status":"UP"},"livenessState":{"status":"UP"},"ping":{"status":"UP"},"readinessState":{"status":"UP"},"ssl":{"status":"UP"}},"groups":["liveness","readiness"],"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19012/actuator/health/kitchen
  {"status":"UP"} 200
$ $CURLSET 19012 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
the README's line that shows the details - the kitchen asked alone (health's whole answer would show a disk and a folder):
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19012 --management.endpoint.health.show-details=always
  listens on: 127.0.0.1:19012
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19012/actuator/health/readiness
  {"components":{"kitchen":{"details":{"customers":4,"ordersCooked":120},"status":"UP"},"readinessState":{"status":"UP"}},"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19012/actuator/health/kitchen
  {"details":{"customers":4,"ordersCooked":120},"status":"UP"} 200
$ $CURLSET 19012 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
the README's line that switches the groups off:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19012 --management.endpoint.health.probes.enabled=false
  TiffinBox's own line, before it stopped: TiffinBox listening on http://127.0.0.1:19012
  Boot's failure analysis (its banner, APPLICATION FAILED TO START): 1 · stack frames (lines starting 'at '): 0 - the analysis, every line after its banner but the blank ones:
    Description:
    Health contributor 'readinessState' defined in 'management.endpoint.health.group.readiness.include' does not exist
    Action:
    Update your application to correct the invalid configuration.
    You can also set 'management.endpoint.health.validate-group-membership' to false to disable the validation.
  exit 1 · listening on 19012 now: 0
```


## 5 · dead — the database closed

after/'s exploded run with `CloseDb` and the README's details flag. Health's whole answer, through the filter: DOWN, 503 — `kitchen`
DOWN, the other five UP. Liveness `{"status":"UP"}` 200 (Boot's own group: no components). Readiness 503, its components shown with
the kitchen's error, `JdbcSQLSyntaxErrorException`: H2's `SHUTDOWN` leaves the URL, and the next connection opens a new, empty
in-memory database under it — the harness connected once more and found **0 tables** — so the table is gone, not unreachable (the
brief's hazard). The kitchen's path 503. `/customers` 500;
`/kitchen` 200 — the orders were counted at the start, from memory. The seven: `576b655c…`, as in `parts`' first run.

`.r-dead.out` · md5 `b13f60fd44d1234c04adc9d73fe67464` · 3 of 3

```
after/'s jar, extracted (.harness/after), run exploded with the harness joined - it closes the database once TiffinBox is
ready - and the README's details flag, port 19013:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19013 --spring.main.sources=probe.health.CloseDb --management.endpoint.health.show-details=always
  listens on: 127.0.0.1:19013
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
  harness: readiness ACCEPTING_TRAFFIC, then H2's SHUTDOWN: the database is closed
  harness: the same URL, connected again: a database with 0 tables
$ cd .harness/after && curl -s -o health.json -w '%{http_code}\n' http://127.0.0.1:19013/actuator/health
  503
  its answer, through a filter - the status, then each component's status (details never printed): DOWN · diskSpace UP · kitchen DOWN · livenessState UP · ping UP · readinessState UP · ssl UP
  the answer deleted: yes
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19013/actuator/health/liveness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19013/actuator/health/readiness
  {"components":{"kitchen":{"details":{"error":"JdbcSQLSyntaxErrorException"},"status":"DOWN"},"readinessState":{"status":"UP"}},"status":"DOWN"} 503
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19013/actuator/health/kitchen
  {"details":{"error":"JdbcSQLSyntaxErrorException"},"status":"DOWN"} 503
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19013/customers
  {"error":"JdbcSQLSyntaxErrorException"} 500
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19013/kitchen
  {"ordersCooked":120,"ordersValue":24300} 200
$ $CURLSET 19013 .harness/after/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 500 application/json  {"error":"JdbcSQLSyntaxErrorException"}
  GET   /revenue    -> 500 application/json  {"error":"JdbcSQLSyntaxErrorException"}
  GET   /dashboard  -> 500 application/json  {"error":"ExecutionException"}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 576b655c5d492c41bc52b79ed5feee76
```


## 6 · groups — the break (A/B/A′)

The database closed by the harness in every run; after/'s exploded run. **A** — after/ as it is: liveness 200, readiness **503**,
`/customers` 500: a platform stops sending traffic and does not restart the process. **B** — the README's flag that leaves the
kitchen out of readiness (`--management.endpoint.health.group.readiness.include=readinessState`): readiness **200**, `/customers`
500 — traffic keeps arriving at a TiffinBox that cannot answer it. **A′** — A's command again: readiness 503. The seven hash the
same in all three (`576b655c…`). C — the kitchen in liveness as well — is the exercise's capture (§9), not a panel: shown before the
exercise, it would be its answer.

`.r-groups.out` · md5 `ec7f685b75f7291de7d99f949df5fbaf` · 3 of 3

```
the break: which group the kitchen joins. In every run the harness closes the database once TiffinBox is ready; after/'s
jar, extracted (.harness/after), run exploded, port 19014.
A - after/ as it is (application.yaml: readiness includes readinessState,kitchen):
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19014 --spring.main.sources=probe.health.CloseDb
  listens on: 127.0.0.1:19014
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
  harness: readiness ACCEPTING_TRAFFIC, then H2's SHUTDOWN: the database is closed
  harness: the same URL, connected again: a database with 0 tables
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19014/actuator/health/liveness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19014/actuator/health/readiness
  {"status":"DOWN"} 503
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19014/customers
  {"error":"JdbcSQLSyntaxErrorException"} 500
$ $CURLSET 19014 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 576b655c5d492c41bc52b79ed5feee76
B - the README's flag that leaves the kitchen out of readiness:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19014 --spring.main.sources=probe.health.CloseDb --management.endpoint.health.group.readiness.include=readinessState
  listens on: 127.0.0.1:19014
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
  harness: readiness ACCEPTING_TRAFFIC, then H2's SHUTDOWN: the database is closed
  harness: the same URL, connected again: a database with 0 tables
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19014/actuator/health/liveness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19014/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19014/customers
  {"error":"JdbcSQLSyntaxErrorException"} 500
$ $CURLSET 19014 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 576b655c5d492c41bc52b79ed5feee76
A' - A again:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19014 --spring.main.sources=probe.health.CloseDb
  listens on: 127.0.0.1:19014
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
  harness: readiness ACCEPTING_TRAFFIC, then H2's SHUTDOWN: the database is closed
  harness: the same URL, connected again: a database with 0 tables
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19014/actuator/health/liveness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19014/actuator/health/readiness
  {"status":"DOWN"} 503
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19014/customers
  {"error":"JdbcSQLSyntaxErrorException"} 500
$ $CURLSET 19014 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 576b655c5d492c41bc52b79ed5feee76
```


## 7 · trap — C (labelled): readiness by hand, and a SIGTERM

Not part of the break. after/'s exploded run with the `Witness`. (1) A runner publishes `REFUSING_TRAFFIC` (`Refuse`): readiness 200
— the witness's order shows why: `CORRECT` · the runner · `REFUSING_TRAFFIC` · **`ACCEPTING_TRAFFIC`**, Boot's own, last (S4.20).
(2) After Boot's own `ACCEPTING_TRAFFIC`, a thread publishes `REFUSING_TRAFFIC` (`RefuseLater`): health and readiness
`{"status":"OUT_OF_SERVICE"}` 503, liveness 200. Then `kill -TERM $pid`: exit 143, the context closes on
`SpringApplicationShutdownHook`, and **no state is published after it** (0 witness lines). The classes in the jar's 39 libraries
whose bytes name `REFUSING_TRAFFIC`: `ApplicationAvailability`, `ReadinessState`, `ReadinessStateHealthIndicator` — the state's
default, the state itself and its health indicator; none of them is a context that closes.

`.r-trap.out` · md5 `20f246deb7d812743684fd83577f858d` · 3 of 3

```
C (labelled) - readiness changed by hand: after/'s jar, extracted (.harness/after), run exploded with the harness's witness,
port 19015.
1 - a runner publishes REFUSING_TRAFFIC (the harness's Refuse):
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19015 --spring.main.sources=probe.health.Witness,probe.health.Refuse
  listens on: 127.0.0.1:19015
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19015/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19015/actuator/health
  {"groups":["liveness","readiness"],"status":"UP"} 200
$ $CURLSET 19015 .harness/after/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  the witness's lines, in order:
    harness: LivenessState CORRECT - published on the thread main
    harness: a runner publishes REFUSING_TRAFFIC
    harness: ReadinessState REFUSING_TRAFFIC - published on the thread main
    harness: ReadinessState ACCEPTING_TRAFFIC - published on the thread main
    harness: the context closes - on the thread SpringApplicationShutdownHook
2 - after Boot's own ACCEPTING_TRAFFIC, a thread publishes REFUSING_TRAFFIC (the harness's RefuseLater); then a SIGTERM:
$ cd .harness/after && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19015 --spring.main.sources=probe.health.Witness,probe.health.RefuseLater
  listens on: 127.0.0.1:19015
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
  harness: LivenessState CORRECT - published on the thread main
  harness: ReadinessState ACCEPTING_TRAFFIC - published on the thread main
  harness: readiness ACCEPTING_TRAFFIC, then a thread publishes REFUSING_TRAFFIC
  harness: ReadinessState REFUSING_TRAFFIC - published on the thread harness-refuse
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19015/actuator/health
  {"groups":["liveness","readiness"],"status":"OUT_OF_SERVICE"} 503
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19015/actuator/health/liveness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19015/actuator/health/readiness
  {"status":"OUT_OF_SERVICE"} 503
$ kill -TERM $pid
  exit 143 · listening on 19015 now: 0
  the witness's lines from the context's close on: 1 - the context closes - on the thread SpringApplicationShutdownHook · states published after it: 0
  the classes in the jar's BOOT-INF/lib whose bytes name REFUSING_TRAFFIC (read from .harness/after's extracted lib):
    39 jars read · 3 classes: ApplicationAvailability ReadinessState ReadinessStateHealthIndicator
```


## 8 · native — the AOT jar and the binary (S4.14, ⚑12)

after/ built with the README's two native lines, offline: 8 of 8 stages, 0 tokens in the binary's bytes. The AOT jar (the README's
AOT line) and the binary (its run line), each with the README's components flag — read at run time, so it works on both, unlike
exposure: `Starting AOT-processed`, readiness `{"components":{"kitchen":{"status":"UP"},"readinessState":…},"status":"UP"}` 200, the
kitchen's path 200, the seven `115c36ba…`. The indicator needed no hint: the health descriptors' JSON is written in the binary
(the brief's re-measure).

`.r-native.out` · md5 `11bbe9ceb2ae864839af0a8da58c8ad4` · 3 of 3

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
  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 10 minutes · offline: yes
  file: Mach-O 64-bit executable · the demo token in its bytes: 0
the AOT jar - the README's AOT line, with the README's flag that shows the components, port 19016:
$ cd .harness/nat && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19016 --management.endpoint.health.show-components=always
  listens on: 127.0.0.1:19016
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19016/actuator/health/readiness
  {"components":{"kitchen":{"status":"UP"},"readinessState":{"status":"UP"}},"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19016/actuator/health/kitchen
  {"status":"UP"} 200
$ $CURLSET 19016 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
the binary - the README's line, the same flag:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19016 --management.endpoint.health.show-components=always
  listens on: 127.0.0.1:19016
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19016/actuator/health/readiness
  {"components":{"kitchen":{"status":"UP"},"readinessState":{"status":"UP"}},"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19016/actuator/health/kitchen
  {"status":"UP"} 200
$ $CURLSET 19016 .harness/nat/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```


## 9 · exercise — the exercise, run as written

`exercise/README.md`'s commands and `exercise/solution/SOLUTION.md`'s one line, read from the files and run exactly as written: the
kitchen in the liveness group as well, the database closed, liveness asked — `liveness {"status":"DOWN"} [503]`.

`.r-exercise.out` · md5 `e206184a3743ef9e03b94281cff11c86` · 3 of 3

```
exercise/README.md's commands, run exactly as written from this folder - 7 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine/run/secrets/tiffinbox .harness/mine/hc && rsync -a --exclude target after/ .harness/mine/after/
  $ mvn -o -B -q -f .harness/mine/after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package
  $ (cd .harness/mine/after && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted)
  $ javac -d .harness/mine/hc -cp ".harness/mine/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/mine/after/tiffinbox-web/target/extracted/lib/*" harness/probe/health/CloseDb.java
  $ chmod 700 .harness/mine/run/secrets .harness/mine/run/secrets/tiffinbox && (umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/run/secrets/tiffinbox/shutdown-token)
  exit 0 · printed: 0 line(s)
the solution's line (exercise/solution/SOLUTION.md), run exactly as written, from this folder:
$ (cd .harness/mine/run && exec java -cp "../after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../after/tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19019 --spring.main.sources=probe.health.CloseDb --management.endpoint.health.group.liveness.include=livenessState,kitchen > ../run.log 2>&1) & for i in $(seq 160); do grep -qx 'harness: done' .harness/mine/run.log 2> /dev/null && break; sleep 0.25; done; echo "liveness $(curl -s -w ' [%{http_code}]' http://127.0.0.1:19019/actuator/health/liveness)"; harness/shutdown.sh 19019 .harness/mine/run/secrets/tiffinbox/shutdown-token; wait
liveness {"status":"DOWN"} [503]
POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19019 now: 0
```


## Exercise

**Your turn:** put the kitchen into the liveness group as well, close the database, and read what a platform would now do.
`exercise/README.md` has the commands; done is the line `liveness {"status":"DOWN"} [503]`; the measured answer, run exactly as
written in a clean `env -i` shell, is `exercise/solution/SOLUTION.md`.

## RE-MEASURE — the brief's items this unit settles

| Item (brief) | The probes | This unit (receipts, 2026-10-07) |
|---|---|---|
| Liveness with the kitchen in its group (the exercise) | not measured (10-07: `LivenessState.BROKEN` from a runner → liveness 503) | **`liveness {"status":"DOWN"} [503]`** with the database closed (`exercise`) |
| The indicator in the binary | not measured | **kitchen UP, readiness 200 with it, its path 200 with the components flag** — the AOT jar and the binary, no hint needed (`native`) |
| The readiness trap over the bridge | Tomcat (10-07): a runner's or a ready listener's REFUSING overwritten; 1.5 s after ready → 503; SIGTERM → `REFUSING_TRAFFIC on SpringApplicationShutdownHook` | **a runner's overwritten** (`CORRECT · runner · REFUSING_TRAFFIC · ACCEPTING_TRAFFIC`, readiness 200); **after Boot's own → `OUT_OF_SERVICE` 503**; **SIGTERM → 143, no state published at close** — on TiffinBox's context; the other probe's line came from Tomcat's (`trap`) |
| Health 503 over the bridge (unit 21's open item) | 503 on Tomcat (10-07) | **503** — `{"status":"DOWN"}` (`dead`, `groups` A) and `{"status":"OUT_OF_SERVICE"}` (`trap`, `race`): the bridge passes the status of Boot's `WebEndpointResponse` (read from its code) |
| The readiness-group setting over the bridge (unit 21's open item) | readiness 503 with the group (10-06, bridge) | **503 with the kitchen in the group, 200 without** (`groups`); the group's components shown with the flag (`kitchen`) |
| `/actuator/health/kitchen` | settled at the merge: 404 by default, 200 with components | **404, then 200** (`kitchen`), 503 when DOWN (`dead`) |
| The race | 12-18 polls of 200/503/503, 5 runs (10-06) | **at least once: yes** in every run — 3 per receipts run, `cap()` dying on any drift; counts never printed (S4.9) |
| The two probes keys | the other probe's row did not record which key it set | **`management.endpoint.health.probes.enabled=false` → 404, 404** (and with after/'s group line: the start stops); **`management.health.probes.enabled=false` → nothing** (deprecated since 2.3.2, level `error`) (`parts`, `kitchen`) |

**Behaviour on restart** (the task's open item from unit 21's hand-off) is unit 25's — DevTools' restart rebuilding the bridge — as
unit 21's README says. What this unit measured of a stop: on SIGTERM TiffinBox's context closes on `SpringApplicationShutdownHook`
and publishes no availability state (`trap`); a liveness-driven restart is not measured (no platform here).

## Found on the way

- **The switch for the groups now stops the start.** With `application.yaml` naming `readinessState` in the readiness group,
  `--management.endpoint.health.probes.enabled=false` removes the state and Boot's group validation stops the start, with a failure
  analysis that names the key and offers `management.endpoint.health.validate-group-membership=false` (`kitchen`). Recorded in the
  anchor README and in `application.yaml`'s comment.
- **Boot's own probe groups never show components**; a group defined in `application.yaml` follows `show-components` and
  `show-details` (`parts` 2, `kitchen` 2-3, `dead`). So readiness shows the kitchen's error under the details flag, and liveness
  shows nothing.
- **A request that early reaches into the refresh.** In every race run here, Spring logged at INFO that a request's thread obtained
  `healthEndpoint` (in some runs `healthContributorRegistry` too) "while other thread holds singleton lock" — the first liveness or
  readiness request made Spring finish health's beans on the request's thread while the main thread was still creating singletons
  (11 of 11 runs counted for it here — 3 in a first receipts run, whose `race` drifted on exactly this count, and 8 by hand — 1 or 2
  lines per run). Spring Framework 7 allows it and says so; the answers were 503 until Boot published its states. Named in `race`,
  not counted.
- **SIGTERM publishes nothing on TiffinBox.** In Boot 4.1.1's jars, the contexts that publish `REFUSING_TRAFFIC` while they close are
  `ServletWebServerApplicationContext` and `ReactiveWebServerApplicationContext` (`spring-boot-web-server`, read once in this unit's
  probe; not in TiffinBox's jar, not a capture). TiffinBox's context is an `AnnotationConfigApplicationContext`: draining a TiffinBox
  is Course 18's.
- **The bridge's JSON key order is reflection's.** `ActuatorRoutes` writes Boot's health answers with TiffinBox's Jackson 2
  `ObjectMapper`, which orders a class's properties as reflection lists its methods — and that list's order can change from one JVM
  run to the next (here once, under heavy load: `kitchen` drifted, mask 3). Boot's own Jackson 3 mapper sorts properties. The
  captures sort keys; the bridge is not this unit's change (⚑1's class, and `change` asserts it byte for byte). A mapper with
  `MapperFeature.SORT_PROPERTIES_ALPHABETICALLY` would make the answers themselves stable — and would turn the Actuator lesson's
  documented `{"status":"UP","groups":[…]}` into `{"groups":[…],"status":"UP"}`: RED's call.
- **The harness waits for the main thread, not for a state.** `CloseDb` and `RefuseLater` first polled
  `ApplicationAvailability.getReadinessState()`; a thread that sees `ACCEPTING_TRAFFIC` recorded may run before the witness has
  printed it on `main`. Joining the main thread — which ends after `ACCEPTING_TRAFFIC` and its listeners — makes the order
  deterministic (every capture 3/3).

## For unit 23 — and for RED

**Start from `../c5-unit22/after`** (= `../c5-tiffinbox` now; `diff -rq -x target` empty). What you can rely on — measured here
unless a line says otherwise:
- **Health:** `/actuator/health` → status UP, groups `liveness` and `readiness`; six components (`diskSpace`, `kitchen`,
  `livenessState`, `ping`, `readinessState`, `ssl`); readiness = `readinessState` + `kitchen` (application.yaml); liveness = Boot's
  `livenessState` alone. Readiness waits for the kitchen: a test or a capture that closes or empties the database sees readiness 503 —
  wait for readiness 200 first, as `ready()` does; where readiness is what you measure, wait for a harness line instead.
- **Do not switch the probes off** (`management.endpoint.health.probes.enabled=false`): with the group line it stops the start.
- **The bridge is unchanged** (`ActuatorRoutes.java` byte for byte the Actuator lesson's): exposure still `health` only. Your
  `prometheus` goes into `application.yaml`'s list (⚑3) — the AOT jar and the binary read the built list only.
- **Compare health's JSON parsed, or with its keys sorted** (`sortjson` in `receipts.sh`), never as raw text: the bridge's key order
  can move between runs (Found on the way).
- **The race:** TiffinBox's own routes answer before readiness, and early actuator requests make Spring create health's beans on
  the request's thread (Spring's INFO lines, a moving count): never count Boot's log lines in a capture while something polls.
- **The kitchen's count** `/kitchen` → `{"ordersCooked":120,"ordersValue":24300}`; `KitchenHealthIndicator` reads
  `OrderQueue::cooked` too — your `FunctionCounter` (⚑5) reads the same getter, and tiffinbox-core is still untouched.
- **The seven** are `115c36ba…` on the jar, the AOT jar and the binary; with the database closed they are `576b655c…`.
- **Harness:** `harness/probe/health/` (`CloseDb`, `Witness`, `Refuse`, `RefuseLater`) compile against after/'s extracted class
  path and join by `--spring.main.sources`; reuse them by copying, never by path into this folder.
- **The seed:** `.m2-demo` = `../c5-unit21/.m2-demo` less `com/tiffinbox/` — Micrometer's Prometheus registry is in it (the S4 seed).
- **Ports:** 22 used 19010-19019; nothing of this unit listens after it ends (Interrupted). Unit 23 owns 19020-19029.
