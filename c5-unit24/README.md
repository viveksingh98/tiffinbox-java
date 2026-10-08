# c5-unit24 — Logging in Boot

Course 5 · Spring Boot · Section 4, its fourth unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1, Logback
1.5.38, GraalVM CE 25.3.4.1** (native-image 25.0.4.1), 2026-10-07. TiffinBox logged nothing per request — not even at DEBUG — and
nothing changed a level while it ran: a level meant a restart. This unit shows that silence on the previous tree, gives TiffinBox
one DEBUG line per answer and a log group, draws the road a line takes (`System.Logger` → `java.util.logging` → Boot's SLF4J bridge
→ Logback's appender) from inside the running process, explains the first lesson's logging file that "quietly stopped working"
and retires it (RED decided ⚑6b), lists the loggers and Boot's own groups, switches the level while TiffinBox runs and locks the switch, breaks the name the level is
set on (A/B/A′), counts the token at TRACE, and re-checks the AOT jar and the native binary — where the level changes only at start.

**The anchor changes (brief ⚑6):**
- `TiffinBoxServer.java`: `handle()`'s `finally` computes `route` — the key of the route TiffinBox declares (`GET /customers`), or
  `UNKNOWN` when no route takes the request's verb — and `status` (`exchange.getResponseCode()`) once, then
  **`LOG.log(DEBUG, "{0} -> {1}", route, status)`** through TiffinBox's own `System.Logger` (`tiffinbox`), then stops the timer with
  the same two values as its tags. One line per answer, at DEBUG: silent at INFO, Boot's default. It never holds a header, the token
  or anything the client typed — its text is one of TiffinBox's declared routes or `UNKNOWN`, and a number. It is written **before**
  the timer stops, so once the scrape counts an answer, that answer's line has been decided (the captures' barrier, below). The
  class's Javadoc gains a paragraph.
- `application.yaml`: **`logging.group.kitchen: tiffinbox, com.tiffinbox`**, with a comment — TiffinBox's own logger, and the
  loggers under `com.tiffinbox` (Boot logs TiffinBox's startup under its main class's name, `com.tiffinbox.web.TiffinBoxServer`).
- **Retired (⚑6b, RED decided — C5-S4 #43):** `tiffinbox-web/logging.properties`, `tiffinbox-web/logging-debug.properties` and the
  exec plugin's `<argument>-Djava.util.logging.config.file=logging.properties</argument>` — deleted, after `files` measured them on
  the previous tree, which still ships them: under Boot they changed nothing. The exec plugin stays, and still starts TiffinBox.
- **Not edited:** `tiffinbox-core` (`change`: 0 files differ), `TiffinBoxApp.java` (⚑11), `ActuatorRoutes.java`,
  `KitchenHealthIndicator.java`, `KitchenMetrics.java`. The exposure list stays `health,prometheus` (⚑3): `loggers` is a flag, for
  one run.

This unit's `after/` holds the change, the retirement and the anchor README's new section, and nothing else. **Unit 26 starts from
`after/`, and unit 25 is re-pointed to it** (see the last section); the anchor has moved on since: `../c5-tiffinbox` is unit 26's
`after/` now (`diff -rq -x target ../c5-tiffinbox ../c5-unit26/after` is empty).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 10 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) It runs for about 15 to 60 minutes on the author's Mac, most of it the three native builds (282-439 s each in the runs below, beside
other units' native builds). **After RED C5-S4 part A's bridge fix (2026-10-08, the Actuator lesson's anchor carried here):**
**3,397 s under `./receipts.sh`** (/bin/bash 3.2.57, this folder, exit 0) and **2,747 s under `bash receipts.sh`** (Homebrew bash
5.3.9, this folder, exit 0), every capture 3/3 and = published, beside three or four other units' receipts (load averages about
160-410; native builds 415-703 s, inside the 20-minute bound); the two hashes that moved (`change`: the anchor README's lines
added 114 → 116; `lock`: 415 and 415) were published from a 3.2 run of the same captures, 3/3, every check passed (2,611 s).
The runs of record of part B's revision, 2026-10-08: **2105 s under
`./receipts.sh`** (/bin/bash 3.2.57, this folder, exit 0) and **1794 s under `bash receipts.sh`** (Homebrew bash 5.3.9, this folder,
exit 0), every capture 3/3 and = published, while three units' receipts and their native builds held the one-minute load average
between about 40 and 190; every native build inside the capture's bound, under 20 minutes. The four hashes that moved (`change`,
`path`, `files`; `lock` moved and came back with the bridge change it measured deferred) were published from a 3.2 run of the same
captures, 3/3, every check passed (879 s). The first revision's runs of record, 2026-10-07: 663 s (5.3) and 652 s (3.2, from a sealed
clone).
It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first, so you can see which one moved).
Published hashes: before `f54f1d0d9ce7dcd505da38a4204082a3` · change `a442bcd0ee990675e62fe581d3fb7c6e` · path `aaa999e1098123fb1fba017041040f3c` · files `d1af636441477c70f89b55ec97250a9d` · groups `9fa009d838477a2bff5ec74f287074e7` · runtime `ac87b9c21245e07e69ab5f4aea79c762` · lock `b3b2ff8169e6939a8832d51d0a63ee2a` · names `0363b233f9c9cc17b76fbd6c2422def9` · native `38eaddc5731595eb78a81ffdc87059cd` · exercise `8dab017186f32397e9e2b0645516f4ca`

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else. It refuses a variable that does not name a
`bin/native-image`, and one whose `native-image --version` is not `native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1` — another
GraalVM prints other lines, so the captures could not match. The GraalVM's folder is never printed: every capture masks it as
`$GRAALVM_HOME`. Only `native` needs it: every Maven run and every `java` here is the plain JDK 25.0.4.1.

**Without a GraalVM** (`GRAALVM_HOME` not set): `receipts.sh` still runs. It fills `.m2-demo` (its first build), makes every
capture but `native` — `before`, `change`, `path`, `files`, `groups`, `runtime`, `lock`, `names` — and the exercise's, each checked
against `receipts.md5`, then stops where the native build would start, naming this section (exit 1).

## The repository, and what was downloaded

Every build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen): `../c5-unit23/.m2-demo` **less `com/tiffinbox/`**
(every run installs its own two modules first) — 5,418 files before this unit's own installs. **Nothing was downloaded** for this
unit: every build said `offline: yes`, the native-profile ones and the exec plugin's run included (`exec-maven-plugin` 3.6.4 was in
the seed). Logback 1.5.38 and SLF4J's `jul-to-slf4j` 2.0.18 come with Boot's starter since the first lesson. **The exec plugin**,
which `files` runs offline inside a capture, is resolved once before the captures by its help goal (`mvn -o -B -q -pl
tiffinbox-web exec:help` in `.harness/after`, with the same offline-then-Central rule as every build): no build phase reaches the
plugin, so on a fresh clone the first build would not fill it in, and the capture would have nothing to run.

**One way out is not Maven's.** GraalVM's native plugin reads its metadata repository (a zip,
`graalvm-reachability-metadata-1.1.8-repository.zip`, 3,362,517 bytes, from Maven Central) from the Maven repository — and when the
zip is not there it does not fail, even under `-o`: it downloads one from GitHub. So (1) the first build is the README's native
install, which needs nearly every artifact any capture's Maven line needs, the zip included — on a fresh clone it fills `.m2-demo`
from Maven Central, once; (2) a native-profile build while the zip is not in `.m2-demo` goes to Maven Central at once, never
offline first; (3) after the first build the script checks Boot's parent POM, Logback and `jul-to-slf4j`, the native plugin 1.1.8
and the zip are in `$M2`; (4) every build's log is searched for the plugin's own download line — found, the build's line says
`offline: no` and the run stops. (native-image prints one GitHub address in every build: its documentation link, never a download.)
At run time nothing leaves 127.0.0.1, and Logback writes to the terminal only: no file appender, no network appender.

**This revision (2026-10-08, RED C5-S4 part B's fixes) was not cloned here:** its sealed fresh-clone run was unit 26's, whose receipts build this unit's `after/` as their previous tree (`../c5-unit26/README.md`, "From a clone"). The paragraph below is this unit's own clone test, of its first revision.

**From a clone, sealed (2026-10-07, brief S4.2).** The repository was cloned at this unit's commit (less this paragraph and the
run-times note: `README.md` is the only file changed since) into an empty folder — no `.m2-demo` in this unit or in unit 23's, no
seed folder — and `receipts.sh` run under `env -i`, with a `HOME` whose `.mavenrc` points Maven's `user.home` there (Java reads
`user.home` from the account, not from `$HOME`) and every Java proxy property at a port that refuses, and whose Maven settings send
every repository to a `file://` copy of Central's files made from `.m2-demo` (4,061 files: its own installs, `_remote.repositories`,
`*.lastUpdated` and `resolver-status.properties` left out); `http_proxy`, `https_proxy`, their capitals and `ALL_PROXY` pointed at
the same refusing port. **With `GRAALVM_HOME` set, `./receipts.sh` (/bin/bash 3.2): exit 0 after 652 s** — all 10 captures =
published, every spoken number asserted, 0 raw demo tokens. **Without it, `bash receipts.sh` (bash 5.3): the 9 captures that need
no GraalVM = published, the exercise's included, then the stop the script announces (exit 1 after 167 s).** Both times the first
build said `offline: no` (the metadata zip was not in the empty `.m2-demo`), and so did the exec plugin's resolve; together they
filled `.m2-demo` from the copy — 508 files, every transfer from the `file://` copy — every later build said `offline: yes`,
`.m2-demo` ended with 1,436 files, and `github` appears 0 times in either run's log (in the build logs only as native-image's
documentation link and the copy's own `com/github/…` paths). **Found by this test, and fixed before it passed:** offline, a goal
named by its prefix (`exec:help`) whose plugin is not in `.m2-demo` fails with `No plugin found for prefix 'exec'`, which the
script's offline-then-Central rule did not count as resolution; it does now. And a first attempt that set `HOME` alone was **not**
sealed — Maven read the account's settings and fetched the same 508 files from Maven Central itself (both builds said
`offline: no`, as designed); the `.mavenrc` above is what seals it.

## The demo token — fake, and never printed

TiffinBox does not start without its shutdown token. Every run starts in a folder under `.harness/` holding a config tree,
`secrets/tiffinbox/shutdown-token` (`-rw-------`, folders `drwx------`), with a 26-character demo token that is fake and looks it;
`receipts.sh` writes it when it runs. The token never reaches a command line: the seven requests read it from the file. Every capture
is masked — the token becomes `[masked: the 26-character token]` — and `receipts.sh` counts the raw token in each run's own output
**before** masking (`.harness/raw-*`: 0 in all 30 capture runs); in **the log of every TiffinBox run** — standard output and error,
counted for the token and for the shutdown header's name, `X-Shutdown-Token`, in any case: 0 and 0 each (69 logs in the run of
record, the root-TRACE run's included); in the **loggers answers and scrapes saved on the way — each counted, then deleted in the same step**
(`gone()`: 9 of them, 0 each); then in every capture, this README, the exercise, the harness, `receipts.md5`, the anchor
README, `application.yaml`, `TiffinBoxServer.java`, and in the **bytes of the binary** each run builds: 0 each. The builder counts it
again in the script, the deck and the prompter: 0. **The DEBUG line cannot carry it:** its text is a declared route or `UNKNOWN`, and
a status number (`change`); at TRACE on every logger, the seven requests — the last one carrying the header — leave the token and
the header's name 0 times in the log (`names`, C). The exercise makes a random token of its own, which it never prints either.

## The folders, the variables and the ports

- `.harness/before/` — the previous tree, `../c5-unit23/after`, copied (for `change`); `.harness/after/` — `after/` copied and built
  with the README's native install (the run's first build: it fills `.m2-demo` on a fresh clone); its jar extracted to compile the
  harness, and its installed modules are what the exec runs of `files` resolve `tiffinbox-core` from; `files`' last run, the README's
  exec line on after/, starts there (with a config tree of its own in `tiffinbox-web/`).
- `before`: `.harness/prev/` (the previous tree, built the README's plain way). `files` A and B: `.harness/jul/` (the previous tree
  again, built the plain way and extracted — it still ships the two files). `path`, `groups`, `runtime`, `lock` and `names`:
  `.harness/serve/` (after/, built the README's plain way and extracted). `native`: `.harness/nat/` (after/, the README's
  two native lines) and `.harness/natl/` (after/ with `loggers` in `application.yaml`'s list — the AOT jar only). The exercise:
  `.harness/mine/`.
- **The harness:** `harness/probe/logging/` — the course's, never TiffinBox's; outside `com.tiffinbox`; compiled into `.harness/hc`
  against the first build's extracted jar. `Road.java` is joined by `--spring.main.sources=probe.logging.Road`, on the extracted
  class path (the README's `java -cp …` line, `../hc` added). When TiffinBox is ready it prints `java.util.logging`'s root logger
  (handlers, level), what `java.util.logging`'s configuration file asked for (`LogManager`'s `handlers` and `.level` properties),
  Logback's root logger (appenders, level) and Logback's listeners, then TiffinBox's own logger three ways — Logback's effective level,
  `java.util.logging`'s level, `System.Logger`'s DEBUG check; from then on, each time Logback's level for `tiffinbox` or for the root
  is set, that view again. `Jul.java` is a plain main, run alone in `files` C: no Boot, no Spring — it logs a route line at DEBUG
  and the orders cooked at INFO through `System.Logger("tiffinbox")`, so a `java.util.logging` file given to it does what Course 3
  wrote it for: the control for the counts that read 0 under Boot. And `harness/shutdown.sh` (POST /shutdown with the token from a file, the exercise's stop; the metrics lesson's).
- On screen: `$CURLSET` = `../c5-unit11/curlset.sh`, the comparison set since the secrets lesson; `$M2` = this unit's `.m2-demo`;
  `$GRAALVM_HOME` = the GraalVM. Every other command is printed whole.
- **The class-path layouts** (S4.18): the executable jar (`java -jar`, Boot's launcher) everywhere but `path` and `files` A, which run
  the extracted jar with `-cp` (its `lib/` holds the same 46 jars — the extract layout leaves the Compose module out, as the jar
  does) so the harness can join; `files` B and its last run use the exec plugin's own class path — Maven's, the module's
  dependencies — with `spring.docker.compose.enabled` false in `application.yaml`; `files` C runs `Jul` on `.harness/hc` alone.
- Ports (brief ⚑10, 19030-19039, checked free with `lsof` before anything is wiped; 18425 and 8080 too): `before` 19030 · `path`
  19031 · `files` 19032 · `groups` 19033 · `runtime` 19034 · `lock` 19035 · `names` 19036 · `native` 19037 · the exercise 19039;
  19038 unused. The exec run takes its port from `TIFFINBOX_PORT` (the plugin's arguments are fixed in the POM); nothing passes a
  bare port number.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM and the token** (`gsub()`, the patterns escaped as literals), in every line of every capture: the demo token
   → `[masked: the 26-character token]`; the GraalVM's folder → `$GRAALVM_HOME`; this folder's absolute path → `…` (also
   URL-encoded); the folder above it → `…/..`; the home folder → `~`; the user name → `<user>`. A last check fails if any capture
   still holds `/Users/`, `/private/`, `/home/` or `/var/folders/`, the GraalVM's folder, a unit number, Boot's process line
   (`with PID`, `started by`), a log line's time or a virtual thread's number.
2. **A log is read, never printed whole.** Every run's standard output and error go to `.harness/run.out` and `run.err`. A capture
   shows only: Boot's first line, from its message on, cut before `with PID` (it names the user and the folder); the harness's
   `harness: ` lines; and named DEBUG lines — TiffinBox's answer lines, and the DEBUG lines of the loggers under `com.tiffinbox` —
   each with its time → `<time>`, its process id → `<pid>`, and a virtual thread's name with its padding → `[    virtual-<n>]`
   (`gsub()`; Logback pads the thread to 15 characters, so the number's width would move the padding). Every other line is counted,
   not shown: **`its DEBUG lines: N · tiffinbox: R route lines, A answer lines · <logger>: n …`** — every DEBUG line Logback wrote,
   split by its logger (read from the line: the logger column ends at ` : `), TiffinBox's own split into its route lines (written once,
   at start, `route GET /customers -> customers()`) and its answer lines (`GET /customers -> 200`). The root-TRACE run's log is
   counted against a floor only (over 1,000 lines): line totals are not witnesses (S4.19).
3. **The barrier.** TiffinBox writes an answer's line after the answer is on the wire, so a count taken the moment `curl` returns
   could miss it. Every mid-run count first waits — silently, every 0.1 s, up to 15 s — until the scrape counts that many answers for
   the route and status (`tiffinbox_requests_seconds_count`, read from a pipe, never written to a file or printed): the line is
   written before the timer stops, so a counted answer's line is in the log, or never will be. Counts after a run's stop need no
   barrier: the process has exited.
4. **The loggers answer** (`/actuator/loggers`, exposed by the README's flag for one run) is written by the README's own curl line
   (`-o loggers.json`) beside the run's config tree, read as JSON through a declared filter and deleted in the same step (`gone()`;
   the exit trap deletes any left, and a last check fails if one is). **The scrape** in `native` (the README's line, `-o scrape.txt`)
   is treated the same way: it names this computer's memory, threads and a disk's folder, so only its status, content type and its
   one `tiffinbox_requests_seconds_count` line for the request are printed. The filter prints its size against a floor (over 30,000 bytes),
   its keys, the levels, every group with its members, the loggers' names by their first word, and TiffinBox's loggers (`tiffinbox`,
   every `com.tiffinbox…`) with their levels, keys sorted. **Never the total** (S4.19): the probes counted 324 and 478, and the
   number moves with the class path.
5. **Maven's and native-image's logs** are read, never printed whole: each build's `offline`/`exit` line; native-image's goal, the
   GraalVM it found, the builder's Java, its three warnings (the file URL cut), the eight stage names, the warning count and `BUILD
   SUCCESS`, the rest counted; every log searched for the plugin's metadata-repository download line.
6. **No duration is captured**: the native build is judged against a bound (1 minute or more, under 20 minutes — native builds here
   took up to 8 minutes under load); its seconds go to the terminal.
7. **Hygiene:** `receipts.sh` unsets every `TIFFINBOX_*`, `SPRING_*`, `MANAGEMENT_*`, `SERVER_*` and `LOGGING_*` variable (a
   `LOGGING_LEVEL_ROOT` of yours would change every log a capture counts), `DEBUG`, `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`,
   `_JAVA_OPTIONS`, `MAVEN_OPTS`, `MAVEN_ARGS` and `NATIVE_IMAGE_OPTIONS` before it runs anything — the list is an extended regular
   expression (`sed -E`: `/usr/bin/sed`'s basic one has no alternation, and the `\|` this script once used removed nothing — RED
   C5-S4 #63), and the script plants a canary under every one of those names first and stops if one survives; it puts `127.0.0.1` and `localhost`
   first in `no_proxy` and `NO_PROXY`; it refuses to run twice at once in this folder (`.r-lock`), with a `secrets/` in this folder,
   or with a `secrets/`, a `tiffinbox-local.yaml` or a `target/` in `after/`. No capture reads the process's environment, so macOS's
   `__CF_USER_TEXT_ENCODING` (CoreFoundation writes it into a process's environment) changes nothing here. **S4.16:** a last check
   greps this script, this README, the exercise's and every capture for an exposure list with a star, and fails on any.

**Interrupted.** `receipts.sh`'s exit trap stops the process it started in the background (a TiffinBox jar, an extracted class path,
Maven's exec run, or a binary), if one still runs, then `sweep()`s this run's process group for anything of this run — a TiffinBox
JVM (its jar, or `com.tiffinbox.web.TiffinBoxServer` on a class path), the JVM the exec plugin forks and Maven running it
(`exec:exec`), a binary, native-image's driver or its builder JVM (`java @…/vminvocation.args`) — TERM, then KILL after 5 s; then it
deletes any loggers answer or scrape a run left, and, after an interrupt only, the capture runs left unfinished (`.r-NAME.1-3`; after a failed
check they stay, for the diff the message names); then it drops the lock. Maven and native-image's builds run in the foreground:
Ctrl-C reaches them directly. Every command in the trap is guarded, so `set -e` cannot end it early. **Tested again 2026-10-08, on this revision**, the same way — `receipts.sh` as a job of its own process group, `SIGINT` to the whole group 175 s in, the moment TiffinBox listened on 19031 from the extracted class path with the harness joined (in the group: 3 processes — the script, that JVM, its readiness `sleep`): **exit 130**; 5 s later 0 processes in the group (and afterwards 0 anywhere naming this unit's folder); 18425, 8080 and 19030-19039 free; `.r-lock` gone; 0 unfinished capture files; 0 loggers answers or scrapes left; the published captures unchanged. **Tested 2026-10-07 on the final script, twice**, with `receipts.sh` as a job of its own process group (job control on, as a
terminal's foreground job is) and `SIGINT` sent to the whole group: **(1) during `path`**, 36 s in, the moment TiffinBox listened on
19031 from the extracted class path with the harness joined (in the group: 4 processes — the script, that TiffinBox JVM, a subshell
and its readiness `curl`) — **exit 130**; 5 s later 0 processes in the group, and anywhere 0 processes whose command names this
unit's folder; 18425, 8080 and 19030-19039 free; `.r-lock` gone; no loggers answer and no unfinished capture file left; **(2) during
the native build**, 175 s in, 20 s after native-image's builder JVM appeared (in the group: 5 processes — the script and its
subshell, Maven, native-image's driver, its builder) — **exit 130**, and the same: nothing left, every port free. (The count of
processes left is scoped to this unit's folder: other agents run TiffinBoxes of their own on this Mac, on their own ports.)

## 1 · before — the previous tree: DEBUG from the start, and nothing per request

The previous tree, built the README's plain way and run with the first lesson's flag line, `--logging.level.tiffinbox=debug` —
TiffinBox's own logger at DEBUG from the start. The loggers endpoint: 404, not exposed. The seven, then its log, counted after the
stop: 5 DEBUG lines, all of them route lines written at start; 0 for the seven answers.

`.r-before.out` · md5 `f54f1d0d9ce7dcd505da38a4204082a3` · 3 of 3

```
the previous tree (the anchor as the metrics lesson left it), copied to .harness/prev with a config tree, built the README's
plain way; run with the first lesson's flag line - TiffinBox's own logger at DEBUG, from the start - port 19030:
$ cd .harness/prev && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the previous tree · offline: yes · exit 0
$ cd .harness/prev && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19030 --logging.level.tiffinbox=debug
  listens on: 127.0.0.1:19030
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19030/actuator/health/readiness
  {"status":"UP"} 200
a level, while it runs - the loggers endpoint:
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19030/actuator/loggers/tiffinbox
  {"error":"not found"} 404
$ $CURLSET 19030 .harness/prev/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
its log, read after the stop:
  its DEBUG lines: 5 · tiffinbox: 5 route lines, 0 answer lines · no other logger
```


## 2 · change — the previous tree against after/

`diff -rq` of the two trees (copied under `.harness/`): four files differ — the README, the web POM, `TiffinBoxServer.java`,
`application.yaml` — and two are only in the previous tree, Course 3's logging files (⚑6b). TiffinBoxServer's diff counted, the two
tag lines it replaces, and its key lines now (`grep -n`: the DEBUG line between `} finally {` and the timer's stop); application.yaml's
gained lines that are neither comment nor blank; the anchor README's new section, counted; tiffinbox-core compared (`diff -rq -x
target`: 0 files); `TiffinBoxApp.java`, `ActuatorRoutes.java`, `KitchenHealthIndicator.java` and `KitchenMetrics.java` byte for
byte; the POM's one removed line, the exec argument; the two files: in the previous tree yes, in after/ no.

`.r-change.out` · md5 `a442bcd0ee990675e62fe581d3fb7c6e` · 3 of 3

```
the previous tree against after/, both copied under .harness/ - the files that differ:
$ diff -rq -x target -x secrets .harness/before .harness/after
  Files .harness/before/README.md and .harness/after/README.md differ
  Only in .harness/before/tiffinbox-web: logging-debug.properties
  Only in .harness/before/tiffinbox-web: logging.properties
  Files .harness/before/tiffinbox-web/pom.xml and .harness/after/tiffinbox-web/pom.xml differ
  Files .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java and .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java differ
  Files .harness/before/tiffinbox-web/src/main/resources/application.yaml and .harness/after/tiffinbox-web/src/main/resources/application.yaml differ
  tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java - diff adds 10 lines, removes 2; the code lines it removes:
    < .tag("route", handler != null ? key : "UNKNOWN")
    < .tag("status", Integer.toString(exchange.getResponseCode()))
  its key lines now (grep -n):
    65: private static final System.Logger LOG = System.getLogger("tiffinbox");
    181: } finally {                                  // a route TiffinBox declares, never what the client typed
    182: String route = handler != null ? key : "UNKNOWN";
    183: String status = Integer.toString(exchange.getResponseCode());
    184: LOG.log(DEBUG, "{0} -> {1}", route, status);   // one line per answer, at DEBUG; before the timer stops
    185: sample.stop(Timer.builder("tiffinbox.requests").description("TiffinBox's answers, by route and status")
    186: .tag("route", route)
    187: .tag("status", status)
  tiffinbox-web/src/main/resources/application.yaml - the lines it gains that are neither comment nor blank:
    logging:
      group:
        kitchen: tiffinbox, com.tiffinbox
    (diff adds 8 lines, removes 0)
  README.md - the anchor's README: lines added 116, removed 1 - its new section (not shown)
  tiffinbox-core against the previous tree's (diff -rq -x target): 0 files differ
  TiffinBoxApp.java against the previous tree's, byte for byte: the same
  ActuatorRoutes.java against the previous tree's, byte for byte: the same
  KitchenHealthIndicator.java against the previous tree's, byte for byte: the same
  KitchenMetrics.java against the previous tree's, byte for byte: the same
  tiffinbox-web/pom.xml - diff adds 0 lines, removes 1:
    < <argument>-Djava.util.logging.config.file=logging.properties</argument>
  tiffinbox-web/logging.properties - in the previous tree: yes · in after/: no
  tiffinbox-web/logging-debug.properties - in the previous tree: yes · in after/: no
```


## 3 · path — one line's road, and a level carried back

after/ built the README's plain way and extracted (the README's extract line); run from the extracted class path with Road joined
and the README's loggers flag. Road's lines at ready: the road. Then the README's POST — the group to DEBUG — and Road's view after
it; one request, and its line; the README's POST back to `null`, Road's view; one request, no line. Then **C (labelled)**, RED
C5-S4 #45: the README's POST to DEBUG sent to the root (`…/loggers/ROOT`), Road's view, `tiffinbox`'s levels, one request — the
propagator copied INFO into `java.util.logging`'s `tiffinbox` at the `null`, so it stays there: Actuator says DEBUG, 0 new lines;
the seven. Then the same root POST on a fresh process, where the group was never set: `java.util.logging`'s `tiffinbox` is `null`,
it follows the root, and the request prints its line; the seven.

`.r-path.out` · md5 `aaa999e1098123fb1fba017041040f3c` · 3 of 3

```
after/, copied to .harness/serve with a config tree, built the README's plain way, then extracted (the README's extract line):
$ cd .harness/serve && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built after/ · offline: yes · exit 0
$ cd .harness/serve && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  extracted: exit 0 · its lib/ holds 46 jars
run from the extracted class path with the harness's Road joined, and the README's loggers flag - port 19031:
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19031 --spring.main.sources=probe.logging.Road --management.endpoints.web.exposure.include=health,prometheus,loggers
  listens on: 127.0.0.1:19031
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19031/actuator/health/readiness
  {"status":"UP"} 200
the road, as Road read it when TiffinBox was ready:
  harness: java.util.logging's root logger - its handlers: [org.slf4j.bridge.SLF4JBridgeHandler] · its level: INFO
  harness: what java.util.logging's configuration file asked for (LogManager's properties) - handlers: java.util.logging.ConsoleHandler · .level: INFO
  harness: Logback's root logger - its appenders: [CONSOLE ch.qos.logback.core.ConsoleAppender] · its level: INFO
  harness: Logback's listeners: [ch.qos.logback.classic.jul.LevelChangePropagator, io.micrometer.core.instrument.binder.logging.LogbackMetrics$1]
  harness: at start - TiffinBox's logger: Logback's tiffinbox INFO · java.util.logging's tiffinbox null · System.Logger DEBUG loggable: false
the README's POST - the group kitchen to DEBUG - then one request:
$ curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":"DEBUG"}' http://127.0.0.1:19031/actuator/loggers/kitchen
   204
  harness: Logback's tiffinbox changed - TiffinBox's logger: Logback's tiffinbox DEBUG · java.util.logging's tiffinbox FINE · System.Logger DEBUG loggable: true
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19031/kitchen
  200
  its answer lines so far:
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : GET /kitchen -> 200
the README's POST - the group back to null - then one request:
$ curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":null}' http://127.0.0.1:19031/actuator/loggers/kitchen
   204
  harness: Logback's tiffinbox changed - TiffinBox's logger: Logback's tiffinbox INFO · java.util.logging's tiffinbox INFO · System.Logger DEBUG loggable: false
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19031/kitchen
  200
  its answer lines so far: 1
C (labelled) - after null, the root: the README's POST to DEBUG, sent to the root logger (ROOT), then one request:
$ curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":"DEBUG"}' http://127.0.0.1:19031/actuator/loggers/ROOT
   204
  harness: Logback's ROOT changed - TiffinBox's logger: Logback's tiffinbox DEBUG · java.util.logging's tiffinbox INFO · System.Logger DEBUG loggable: false
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19031/actuator/loggers/tiffinbox
  {"configuredLevel":null,"effectiveLevel":"DEBUG"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19031/kitchen
  200
  its answer lines so far: 1
$ $CURLSET 19031 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - the same root POST on a fresh process, the group never set: the same run line, port 19031:
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19031 --spring.main.sources=probe.logging.Road --management.endpoints.web.exposure.include=health,prometheus,loggers
  listens on: 127.0.0.1:19031
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19031/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":"DEBUG"}' http://127.0.0.1:19031/actuator/loggers/ROOT
   204
  harness: Logback's ROOT changed - TiffinBox's logger: Logback's tiffinbox DEBUG · java.util.logging's tiffinbox null · System.Logger DEBUG loggable: true
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19031/actuator/loggers/tiffinbox
  {"configuredLevel":null,"effectiveLevel":"DEBUG"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19031/kitchen
  200
  its answer lines: 1
$ $CURLSET 19031 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 4 · files — the Java logging files of Course 3: measured on the previous tree, retired here (brief ⚑6b)

On the previous tree, which still ships them: the two files' lines that are neither comment nor blank, and the web POM's exec
argument; the tree copied to `.harness/jul`, built and extracted. **A** — the README's line with the debug file, from that tree's
extracted class path, Road joined: what `java.util.logging` read (`.level: FINE`) against what Boot left (its bridge, INFO); the
seven; the log's DEBUG lines: 0; and the file's own output, counted — standard error's lines, and the lines in the file's bare
`%5$s%n` format (a route or orders-cooked message at the start of a line) on either stream: 0, 0. **B** — the README's `exec:exec`
line, from that tree (the exec plugin passes `-Djava.util.logging.config.file=logging.properties`), its port from
`TIFFINBOX_PORT`: the JVM it forks, whether that JVM's command line names the file (read with `ps`, never printed: yes), one INFO
line in Logback's format, the seven, 0 DEBUG lines, 0 and 0. **C (labelled)** — the control, RED C5-S4 #47: the harness's `Jul`,
no Boot, with each file — the debug file prints its 2 lines bare on standard error, `logging.properties` its 1: the counts A and B
read as 0 can fail. **Retired here:** after/ holds neither file, its POM names no logging file, and the README's exec line on after/
still serves the seven, its JVM's command line naming no file.

`.r-files.out` · md5 `d1af636441477c70f89b55ec97250a9d` · 3 of 3

```
the two Java logging files and the exec plugin's argument, on the previous tree, which still ships them - their lines
that are neither comment nor blank, and the argument (grep -n):
  tiffinbox-web/logging.properties:
    handlers = java.util.logging.ConsoleHandler
    .level   = INFO
    java.util.logging.ConsoleHandler.level = INFO
    java.util.logging.SimpleFormatter.format = %5$s%n
  tiffinbox-web/logging-debug.properties:
    handlers = java.util.logging.ConsoleHandler
    .level   = FINE
    java.util.logging.ConsoleHandler.level = FINE
    java.util.logging.SimpleFormatter.format = %5$s%n
  tiffinbox-web/pom.xml:
    133: <argument>-Djava.util.logging.config.file=logging.properties</argument>
the previous tree, copied to .harness/jul with a config tree, built the README's plain way, then extracted:
$ cd .harness/jul && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the previous tree · offline: yes · exit 0
$ cd .harness/jul && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  extracted: exit 0 · its lib/ holds 46 jars
A - the README's line with the debug file, from that tree's extracted class path, Road joined - port 19032:
$ cd .harness/jul && java -Djava.util.logging.config.file=tiffinbox-web/logging-debug.properties -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19032 --spring.main.sources=probe.logging.Road
  listens on: 127.0.0.1:19032
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19032/actuator/health/readiness
  {"status":"UP"} 200
  harness: java.util.logging's root logger - its handlers: [org.slf4j.bridge.SLF4JBridgeHandler] · its level: INFO
  harness: what java.util.logging's configuration file asked for (LogManager's properties) - handlers: java.util.logging.ConsoleHandler · .level: FINE
  harness: Logback's root logger - its appenders: [CONSOLE ch.qos.logback.core.ConsoleAppender] · its level: INFO
  harness: Logback's listeners: [ch.qos.logback.classic.jul.LevelChangePropagator, io.micrometer.core.instrument.binder.logging.LogbackMetrics$1]
  harness: at start - TiffinBox's logger: Logback's tiffinbox INFO · java.util.logging's tiffinbox null · System.Logger DEBUG loggable: false
$ $CURLSET 19032 .harness/jul/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  its DEBUG lines: 0 · tiffinbox: 0 route lines, 0 answer lines · no other logger
  standard error: 0 lines · in the file's bare format, on either stream: route lines 0, orders-cooked lines 0
B - the README's exec line, from that tree: the exec plugin passes its argument (logging.properties). Its port from
TIFFINBOX_PORT, its config tree in tiffinbox-web/ (the folder the plugin's JVM starts in) - port 19032:
$ cd .harness/jul && env TIFFINBOX_PORT=19032 mvn -o -q -B -Dmaven.repo.local="$M2" -pl tiffinbox-web exec:exec
  listens on: 127.0.0.1:19032 · the process listening: a child of the one started above (the JVM the exec plugin forks): yes
  Boot's first line: Starting TiffinBoxServer using Java 25.0.4.1
  the forked JVM's command line names logging.properties: yes
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19032/actuator/health/readiness
  {"status":"UP"} 200
  its log's line for the orders cooked:
    <time>  INFO <pid> --- [           main] tiffinbox                                : orders cooked:  120
$ $CURLSET 19032 .harness/jul/tiffinbox-web/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  its DEBUG lines: 0 · tiffinbox: 0 route lines, 0 answer lines · no other logger
  standard error: 0 lines · in the file's bare format, on either stream: route lines 0, orders-cooked lines 0
C (labelled) - the same files with no Boot to replace them: the harness's Jul, a plain main that logs one route line at
DEBUG and the orders cooked at INFO through System.Logger("tiffinbox"), from that tree, with each file:
$ cd .harness/jul && java -Djava.util.logging.config.file=tiffinbox-web/logging-debug.properties -cp ../hc probe.logging.Jul
  standard error: 2 lines · in the file's bare format, on either stream: route lines 1, orders-cooked lines 1
$ cd .harness/jul && java -Djava.util.logging.config.file=tiffinbox-web/logging.properties -cp ../hc probe.logging.Jul
  standard error: 1 lines · in the file's bare format, on either stream: route lines 0, orders-cooked lines 1
retired here - after/, this unit's tree:
  tiffinbox-web/logging.properties: deleted
  tiffinbox-web/logging-debug.properties: deleted
  tiffinbox-web/pom.xml - lines that name java.util.logging.config.file: 0
the README's exec line on after/ (.harness/after, the tree the first build installed), the argument gone - port 19032:
$ cd .harness/after && env TIFFINBOX_PORT=19032 mvn -o -q -B -Dmaven.repo.local="$M2" -pl tiffinbox-web exec:exec
  listens on: 127.0.0.1:19032 · the process listening: a child of the one started above (the JVM the exec plugin forks): yes
  Boot's first line: Starting TiffinBoxServer using Java 25.0.4.1
  the forked JVM's command line names logging.properties: no
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19032/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19032 .harness/after/tiffinbox-web/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 5 · groups — every logger through a filter; Boot's own groups on TiffinBox

after/'s jar with the README's loggers flag line: the README's `/actuator/loggers` line, through the filter (mask 4); the group
alone. Then the README's line for each of Boot's own groups at DEBUG — `web`, `sql` — the seven, and the log's DEBUG lines: 0 each.
Then Boot's own metadata (spring-boot 4.1.1's `META-INF/spring-configuration-metadata.json`, read from `$M2`): `logging.group`'s
type, and the values `logging.structured.format.console` offers.

`.r-groups.out` · md5 `9fa009d838477a2bff5ec74f287074e7` · 3 of 3

```
after/'s jar (.harness/serve), the README's loggers flag line - port 19033:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19033 --management.endpoints.web.exposure.include=health,prometheus,loggers
  listens on: 127.0.0.1:19033
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19033/actuator/health/readiness
  {"status":"UP"} 200
every logger - the README's line, written to loggers.json beside the run's config tree, read through a filter:
$ cd .harness/serve && curl -s -o loggers.json -w '%{http_code}\n' http://127.0.0.1:19033/actuator/loggers
  200
  its size, against a floor: over 30,000 bytes: yes · its keys: groups levels loggers
  levels: OFF ERROR WARN INFO DEBUG TRACE
  group kitchen: configuredLevel null · 2 members: tiffinbox, com.tiffinbox
  group sql: configuredLevel null · 3 members: org.springframework.jdbc.core, org.hibernate.SQL, org.jooq.tools.LoggerListener
  group web: configuredLevel null · 5 members: org.springframework.core.codec, org.springframework.http, org.springframework.web, org.springframework.boot.actuate.endpoint.web, org.springframework.boot.web.servlet.ServletContextInitializerBeans
  loggers: their names' first words: ROOT com io org tiffinbox · how many: not counted (the total moves)
  logger com.tiffinbox: {"configuredLevel": null, "effectiveLevel": "INFO"}
  logger com.tiffinbox.web: {"configuredLevel": null, "effectiveLevel": "INFO"}
  logger com.tiffinbox.web.TiffinBoxServer: {"configuredLevel": null, "effectiveLevel": "INFO"}
  logger tiffinbox: {"configuredLevel": null, "effectiveLevel": "INFO"}
  the demo token in it: 0 · deleted: yes
the group alone:
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19033/actuator/loggers/kitchen
  {"configuredLevel":null,"members":["tiffinbox","com.tiffinbox"]} 200
$ $CURLSET 19033 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
Boot's own groups on TiffinBox - the README's line for each, the seven, then the log:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19033 --logging.level.web=debug
  listens on: 127.0.0.1:19033
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19033/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19033 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  its DEBUG lines: 0 · tiffinbox: 0 route lines, 0 answer lines · no other logger
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19033 --logging.level.sql=debug
  listens on: 127.0.0.1:19033
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19033/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19033 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  its DEBUG lines: 0 · tiffinbox: 0 route lines, 0 answer lines · no other logger
Boot's own metadata - spring-boot 4.1.1's META-INF/spring-configuration-metadata.json, read from $M2:
  logging.group: java.util.Map<java.lang.String,java.util.List<java.lang.String>>
  logging.structured.format.console: its values ecs gelf logstash
```


## 6 · runtime — INFO, DEBUG, INFO, on one process

after/'s jar with the README's loggers flag line. The group; three requests at INFO, then the answer lines in the log (behind the
barrier: mask 3); the README's POST to DEBUG, `tiffinbox`'s levels; three requests, the lines; the README's POST back to `null`;
three requests, the lines; whether the process listening is still the one started (`lsof`'s pid against the script's, neither
printed); the seven, then the whole log counted.

`.r-runtime.out` · md5 `ac87b9c21245e07e69ab5f4aea79c762` · 3 of 3

```
after/'s jar (.harness/serve), the README's loggers flag line - port 19034:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19034 --management.endpoints.web.exposure.include=health,prometheus,loggers
  listens on: 127.0.0.1:19034
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19034/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19034/actuator/loggers/kitchen
  {"configuredLevel":null,"members":["tiffinbox","com.tiffinbox"]} 200
INFO - three requests:
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19034/customers
  200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19034/customers
  200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19034/customers
  200
  answer lines in its log: 0
the README's POST - the group to DEBUG:
$ curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":"DEBUG"}' http://127.0.0.1:19034/actuator/loggers/kitchen
   204
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19034/actuator/loggers/tiffinbox
  {"configuredLevel":"DEBUG","effectiveLevel":"DEBUG"} 200
DEBUG - three requests:
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19034/customers
  200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19034/customers
  200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19034/customers
  200
  answer lines in its log: 3
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : GET /customers -> 200
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : GET /customers -> 200
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : GET /customers -> 200
the README's POST - the group back to null:
$ curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":null}' http://127.0.0.1:19034/actuator/loggers/kitchen
   204
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19034/actuator/loggers/tiffinbox
  {"configuredLevel":null,"effectiveLevel":"INFO"} 200
INFO again - three requests:
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19034/customers
  200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19034/customers
  200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19034/customers
  200
  answer lines in its log: 3
  the process listening on 19034: the one started above: yes
$ $CURLSET 19034 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  its DEBUG lines: 3 · tiffinbox: 0 route lines, 3 answer lines · no other logger
```


## 7 · lock — read-only; and C, the writes the bridge refuses

The README's read-only line (`--management.endpoint.loggers.access=read-only`): the README's POST, then the group. Then **C
(labelled)**, the README's loggers flag line: the README's POST without a JSON `Content-Type` (curl's `-d` sends a form's type) →
**415**, the group still `null`; the README's POST with no body → **415**, still `null` — since RED C5-S4 #46's fix in the Actuator
lesson's anchor the bridge takes a write only as JSON, as Boot's own adapter does (before the fix: 204 and the group at DEBUG, then
204 and the group back to `null`); then the group to DEBUG and its member `tiffinbox` to INFO (the README's two POSTs), all three answers, one request, the
answer lines.

`.r-lock.out` · md5 `b3b2ff8169e6939a8832d51d0a63ee2a` · 3 of 3

```
the lock - the README's read-only line, port 19035:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19035 --management.endpoints.web.exposure.include=health,prometheus,loggers --management.endpoint.loggers.access=read-only
  listens on: 127.0.0.1:19035
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19035/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":"DEBUG"}' http://127.0.0.1:19035/actuator/loggers/kitchen
  {"error":"method not allowed"} 405
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19035/actuator/loggers/kitchen
  {"configuredLevel":null,"members":["tiffinbox","com.tiffinbox"]} 200
$ $CURLSET 19035 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - the writes the bridge refuses: the README's loggers flag line, port 19035:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19035 --management.endpoints.web.exposure.include=health,prometheus,loggers
  listens on: 127.0.0.1:19035
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19035/actuator/health/readiness
  {"status":"UP"} 200
the README's POST without a JSON Content-Type (curl -d sends a form's):
$ curl -s -w ' %{http_code}\n' -X POST -d '{"configuredLevel":"DEBUG"}' http://127.0.0.1:19035/actuator/loggers/kitchen
  {"error":"unsupported media type"} 415
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19035/actuator/loggers/kitchen
  {"configuredLevel":null,"members":["tiffinbox","com.tiffinbox"]} 200
the README's POST with no body:
$ curl -s -w ' %{http_code}\n' -X POST http://127.0.0.1:19035/actuator/loggers/kitchen
  {"error":"unsupported media type"} 415
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19035/actuator/loggers/kitchen
  {"configuredLevel":null,"members":["tiffinbox","com.tiffinbox"]} 200
C (labelled) - the group to DEBUG, then its member tiffinbox to INFO (the README's two POSTs), and one request:
$ curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":"DEBUG"}' http://127.0.0.1:19035/actuator/loggers/kitchen
   204
$ curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":"INFO"}' http://127.0.0.1:19035/actuator/loggers/tiffinbox
   204
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19035/actuator/loggers/kitchen
  {"configuredLevel":"DEBUG","members":["tiffinbox","com.tiffinbox"]} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19035/actuator/loggers/tiffinbox
  {"configuredLevel":"INFO","effectiveLevel":"INFO"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19035/actuator/loggers/com.tiffinbox
  {"configuredLevel":"DEBUG","effectiveLevel":"DEBUG"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19035/customers
  200
  answer lines in its log: 0
$ $CURLSET 19035 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 8 · names — the break (A/B/A′): which name the level is set on

One request in every run, behind the barrier, then the log's DEBUG lines counted and the named ones shown. **A** = the README's line
with the group `kitchen` at DEBUG; **B** = the README's line with only `com.tiffinbox` at DEBUG; **A′** = A re-run, the same command.
Then **C (labelled)**: the README's two lines that set the group and its member `tiffinbox` at start, in both orders; and the
README's line with every logger at TRACE (`--logging.level.root=trace`) — the seven, all seven response lines, the log counted for
the token and the header's name, against a floor, and its answer lines.

`.r-names.out` · md5 `0363b233f9c9cc17b76fbd6c2422def9` · 3 of 3

```
the break: which name the level is set on. One request in every run, then the log's DEBUG lines; port 19036.
A - the README's line: the group kitchen at DEBUG:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19036 --logging.level.kitchen=debug
  listens on: 127.0.0.1:19036
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19036/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19036/customers
  200
  its DEBUG lines: 7 · tiffinbox: 5 route lines, 1 answer lines · com.tiffinbox.web.TiffinBoxServer: 1
  <time> DEBUG <pid> --- [           main] com.tiffinbox.web.TiffinBoxServer        : Running with Spring Boot v4.1.1, Spring v7.0.9
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : GET /customers -> 200
$ $CURLSET 19036 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
B - the README's line: only com.tiffinbox at DEBUG:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19036 --logging.level.com.tiffinbox=debug
  listens on: 127.0.0.1:19036
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19036/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19036/customers
  200
  its DEBUG lines: 1 · tiffinbox: 0 route lines, 0 answer lines · com.tiffinbox.web.TiffinBoxServer: 1
  <time> DEBUG <pid> --- [           main] com.tiffinbox.web.TiffinBoxServer        : Running with Spring Boot v4.1.1, Spring v7.0.9
$ $CURLSET 19036 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
A' - A again:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19036 --logging.level.kitchen=debug
  listens on: 127.0.0.1:19036
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19036/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19036/customers
  200
  its DEBUG lines: 7 · tiffinbox: 5 route lines, 1 answer lines · com.tiffinbox.web.TiffinBoxServer: 1
  <time> DEBUG <pid> --- [           main] com.tiffinbox.web.TiffinBoxServer        : Running with Spring Boot v4.1.1, Spring v7.0.9
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : GET /customers -> 200
$ $CURLSET 19036 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - a group and one of its members at start, both orders (the README's two lines):
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19036 --logging.level.kitchen=debug --logging.level.tiffinbox=info
  listens on: 127.0.0.1:19036
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19036/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19036/customers
  200
  its DEBUG lines: 7 · tiffinbox: 5 route lines, 1 answer lines · com.tiffinbox.web.TiffinBoxServer: 1
  <time> DEBUG <pid> --- [           main] com.tiffinbox.web.TiffinBoxServer        : Running with Spring Boot v4.1.1, Spring v7.0.9
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : GET /customers -> 200
$ $CURLSET 19036 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19036 --logging.level.tiffinbox=info --logging.level.kitchen=debug
  listens on: 127.0.0.1:19036
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19036/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19036/customers
  200
  its DEBUG lines: 7 · tiffinbox: 5 route lines, 1 answer lines · com.tiffinbox.web.TiffinBoxServer: 1
  <time> DEBUG <pid> --- [           main] com.tiffinbox.web.TiffinBoxServer        : Running with Spring Boot v4.1.1, Spring v7.0.9
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : GET /customers -> 200
$ $CURLSET 19036 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - every logger at TRACE (the README's root line): the seven, the last one carrying the token's header:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19036 --logging.level.root=trace
  listens on: 127.0.0.1:19036
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19036/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19036 .harness/serve/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  its log, against a floor: over 1,000 lines: yes · its answer lines:
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : GET /customers -> 200
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : GET /revenue -> 200
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : GET /dashboard -> 200
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : GET /kitchen -> 200
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : UNKNOWN -> 405
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : POST /shutdown -> 200
```


## 9 · native — the AOT jar and the binary (S4.14, ⚑12); C, loggers in the list it was built with

after/ built with the README's two native lines: the AOT jar (the README's AOT line) and the binary (the README's line), each run
twice — with the README's loggers flag (the endpoint asked, then the README's POST), and with the README's kitchen flag (one request;
the scrape by the README's line — its status and content type, and its one line for that request, then deleted; the log's DEBUG
lines, the answer line) — and the seven after each. Then **C (labelled)**: a copy of after/ whose `application.yaml`
exposes `health,prometheus,loggers`, built with the README's native install, its AOT jar: the group, the README's POST, one request,
the line. (No native image is built from the copy: one native build per run, the anchor's.)

`.r-native.out` · md5 `38eaddc5731595eb78a81ffdc87059cd` · 3 of 3

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
the AOT jar - the README's AOT line with the README's loggers flag, port 19037:
$ cd .harness/nat && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19037 --management.endpoints.web.exposure.include=health,prometheus,loggers
  listens on: 127.0.0.1:19037
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19037/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19037/actuator/loggers/tiffinbox
  {"error":"not found"} 404
$ curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":"DEBUG"}' http://127.0.0.1:19037/actuator/loggers/kitchen
  {"error":"not found"} 404
$ $CURLSET 19037 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the AOT jar - the README's AOT line with the README's kitchen flag:
$ cd .harness/nat && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19037 --logging.level.kitchen=debug
  listens on: 127.0.0.1:19037
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19037/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19037/customers
  200
$ cd .harness/nat && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19037/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
  its line for the request: tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 1
  the demo token in it: 0 · deleted: yes
  its DEBUG lines: 7 · tiffinbox: 5 route lines, 1 answer lines · com.tiffinbox.web.TiffinBoxServer: 1
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : GET /customers -> 200
$ $CURLSET 19037 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the binary - the README's line with the loggers flag:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19037 --management.endpoints.web.exposure.include=health,prometheus,loggers
  listens on: 127.0.0.1:19037
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19037/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19037/actuator/loggers/tiffinbox
  {"error":"not found"} 404
$ curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":"DEBUG"}' http://127.0.0.1:19037/actuator/loggers/kitchen
  {"error":"not found"} 404
$ $CURLSET 19037 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the binary - the README's line with the kitchen flag:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19037 --logging.level.kitchen=debug
  listens on: 127.0.0.1:19037
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19037/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19037/customers
  200
$ cd .harness/nat && curl -s -o scrape.txt -w '%{http_code} %{content_type}\n' http://127.0.0.1:19037/actuator/prometheus
  200 text/plain;version=0.0.4;charset=utf-8
  its line for the request: tiffinbox_requests_seconds_count{route="GET /customers",status="200"} 1
  the demo token in it: 0 · deleted: yes
  its DEBUG lines: 7 · tiffinbox: 5 route lines, 1 answer lines · com.tiffinbox.web.TiffinBoxServer: 1
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : GET /customers -> 200
$ $CURLSET 19037 .harness/nat/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - loggers in the list it is built with: a copy of after/ (.harness/natl), application.yaml's exposure line
changed; built with the README's native install (the AOT jar - no native-image run):
$ diff after/tiffinbox-web/src/main/resources/application.yaml .harness/natl/tiffinbox-web/src/main/resources/application.yaml
  53c53
  <         include: health,prometheus
  ---
  >         include: health,prometheus,loggers
$ cd .harness/natl && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean install
  built .harness/natl (both modules, into $M2) · offline: yes · exit 0
$ cd .harness/natl && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19037
  listens on: 127.0.0.1:19037
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19037/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19037/actuator/loggers/kitchen
  {"configuredLevel":null,"members":["tiffinbox","com.tiffinbox"]} 200
$ curl -s -w ' %{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":"DEBUG"}' http://127.0.0.1:19037/actuator/loggers/kitchen
   204
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19037/customers
  200
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : GET /customers -> 200
$ $CURLSET 19037 .harness/natl/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 10 · exercise — the exercise, run as written

`.r-exercise.out` · md5 `8dab017186f32397e9e2b0645516f4ca` · 3 of 3

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
$ (cd .harness/mine/after && exec java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19039 --management.endpoints.web.exposure.include=health,prometheus,loggers > ../run.log 2>&1) & for i in $(seq 240); do [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19039/actuator/health/readiness)" = 200 ] && break; sleep 0.25; done; curl -s -o /dev/null -X POST -H 'Content-Type: application/json' -d '{"configuredLevel":"DEBUG"}' http://127.0.0.1:19039/actuator/loggers/tiffinbox; curl -s -o /dev/null http://127.0.0.1:19039/customers; t=$(curl -s http://127.0.0.1:19039/actuator/loggers/tiffinbox | sed 's/.*"effectiveLevel":"\([A-Z]*\)".*/\1/'); c=$(curl -s http://127.0.0.1:19039/actuator/loggers/com.tiffinbox | sed 's/.*"effectiveLevel":"\([A-Z]*\)".*/\1/'); harness/shutdown.sh 19039 .harness/mine/after/secrets/tiffinbox/shutdown-token; wait; echo "loggers/tiffinbox $t · loggers/com.tiffinbox $c · request DEBUG lines $(grep -cE ' DEBUG [0-9]+ --- .* tiffinbox +: GET /customers -> 200$' .harness/mine/run.log)"
POST /shutdown -> 200 · curl exit 0
loggers/tiffinbox DEBUG · loggers/com.tiffinbox INFO · request DEBUG lines 1
  exit 0 · listening on 19039 now: 0
  its log (.harness/mine/run.log): the demo token 0 times · X-Shutdown-Token 0 times
```


## Exercise

**Your turn:** switch only TiffinBox's own request log to debug while it runs, and leave Spring's com.tiffinbox loggers at info.
`exercise/README.md` has the commands; done is the line `loggers/tiffinbox DEBUG · loggers/com.tiffinbox INFO · request DEBUG lines 1`;
the measured answer, run exactly as written in a clean `env -i` shell, is `exercise/solution/SOLUTION.md`.

## RE-MEASURE — the brief's items this unit settles

| Item (brief) | The probes | This unit (receipts, 2026-10-07) |
|---|---|---|
| The `loggers` answer size (RE-MEASURE #3, unit 24's share) | 35,353 bytes over the 10-06 bridge; 34,923 characters in-process (10-07) | **a floor, never a size**: over 30,000 bytes (`groups`); never the total of loggers (324 / 478 on the probes) |
| The runtime round trip over the bridge | 10-07 on Tomcat: 0 → 3 → 3, one PID | **0 → `204` → 3 → `204` → 3**, the process listening the same throughout (`runtime`) |
| Break B, `com.tiffinbox` only | not run | **0 answer lines**; its one DEBUG line is Spring's `Running with Spring Boot v4.1.1, Spring v7.0.9`, under `com.tiffinbox.web.TiffinBoxServer` (`names`) |
| The binary's start-time level | not measured | **works**: `--logging.level.kitchen=debug` → 5 route lines, Spring's line, the answer line — in the AOT jar and in the binary; `loggers` by flag → 404, GET and POST, in both (`native`) |
| A level on a group, then on a member | not measured | **while it runs:** the last write wins for each logger, and the group's own answer keeps what was last set on the group (`kitchen` DEBUG, `tiffinbox` INFO, `com.tiffinbox` DEBUG, 0 answer lines — `lock` C); **at start:** the group won in both orders on the command line (`names` C). The voice says nothing about precedence; a chip says set one or the other |
| A POST without `Content-Type` → 415 | 10-07 on Tomcat (Spring MVC) | first revision: **204 on TiffinBox's bridge** (it read any body as JSON) and a POST with no body set the group back to `null`; since RED C5-S4 #46's fix: **415 and 415, the group unchanged** — as on Tomcat (`lock` C) |
| Read-only → 405, level unchanged | 10-07 on Tomcat | **405** (`{"error":"method not allowed"}`), the group still `null` (`lock`) |
| `web` and `sql` silent on TiffinBox | 10-07: 0 DEBUG lines each (base tree, no Actuator) | **0 each on the anchor with Actuator and the bridge**; `web` 5 members, `sql` 3 (`groups`) |
| What a level in Boot does to JUL | 10-06 in-process: `setLogLevel` → FINE | **the same through the endpoint**: DEBUG → `java.util.logging`'s `tiffinbox` `FINE`, `System.Logger` DEBUG loggable; `null` → INFO, not loggable (`path`) — and the INFO stays: a later root DEBUG leaves it, Actuator says DEBUG, 0 lines; on a fresh process the root DEBUG prints the line (`path` C) |
| The JUL file with Boot | 10-06: root handler the bridge, INFO, 0 route lines | **the same, and why:** `LogManager` still holds the file's `.level = FINE` (`files` A, on the previous tree); 0 lines on standard error and 0 in the file's own format, against 2 and 1 with no Boot (`files` C); the files retired here |
| Structured logging | 10-06: the metadata lists `ecs`, `gelf`, `logstash` | **the same** (`groups`); not switched on here |

## ⚑6b — the Java logging files: measured, then retired (RED decided, C5-S4 #43)

The brief left to RED whether to delete `tiffinbox-web/logging.properties`, `logging-debug.properties` and the exec plugin's
`-Djava.util.logging.config.file=logging.properties`. RED measured them doing nothing — not even before Boot's reset — and decided:
delete. This unit deletes all three (`change`) and measures them on the previous tree, which still ships them (`files`):
- **`logging-debug.properties`** on the command line: `java.util.logging` reads it (`LogManager`: `handlers =
  java.util.logging.ConsoleHandler`, `.level = FINE`), then Boot's logging system removes the root's console handler, installs
  `SLF4JBridgeHandler`, and Logback's `LevelChangePropagator` sets the root's level from Logback's: INFO. 0 DEBUG lines.
- **`logging.properties`** through the exec plugin (`mvn -q -B -pl tiffinbox-web exec:exec`, the README's Course 3 line): the plugin
  still runs TiffinBox under Boot (the seven, `115c36ba…`, exit 0), on Maven's class path; the file's `%5$s%n` format is not used —
  the lines come out in Logback's format. Its `.level = INFO` is the JDK's own default too (the `path` run, with no file, shows
  `.level: INFO`).
- **The control** (`files` C): with no Boot to replace them, the same files do what Course 3 wrote them for — 2 bare lines on standard
  error with the debug file, 1 with the other — so the 0s above are counts that could have failed.
- **Retired:** the anchor README's Course 3 sections still name both files and the `-D` flag, marked as history (and, since this
  lesson, as deleted); the exec plugin keeps its `-classpath … TiffinBoxServer` arguments and still serves the seven (`files`, last).

## Found on the way

- **TiffinBox's line comes after the answer.** `handle()` writes the response, then its `finally` runs: a `curl` that returns has its
  answer, not necessarily the line. Under load a count taken at once could read one short. The line is written before the timer
  stops, and every count waits for the scrape (mask 3) — no sleeps, no polling the log for a number it expects.
- **The bridge accepts a write it should refuse.** `ActuatorRoutes.handle()` reads any request body as JSON, whatever its
  `Content-Type`, and an absent body leaves `configuredLevel` absent — `null`, the reset. Spring MVC's adapter answers 415 to the
  first (the probe, on Tomcat). RED C5-S4 #46 (with part A's #2 and #4): **deferred to BLUE part A**, who fixes the bridge's request
  handling once, in the Actuator lesson's anchor, and cascades it here; `lock` and its voice move with that fix.
- **`null` is not a clean reset** (RED C5-S4 #45, `path` C). Logback's propagator copies the level a logger falls back to into
  `java.util.logging` — INFO, at the `null` — and nothing clears it, so a later change to the root reaches Logback's `tiffinbox`
  (Actuator: DEBUG) but not `java.util.logging`'s, and TiffinBox prints nothing; on a process where the group was never set, the
  same root change prints the line.
- **A group's own answer can be stale.** After the group's POST and a member's POST, `/actuator/loggers/kitchen` still says DEBUG
  while `tiffinbox` is INFO: the group answer reports what was last set on the group, not its members.
- **Boot's own line under TiffinBox's name.** `com.tiffinbox` at DEBUG prints one line, `Running with Spring Boot v4.1.1, Spring
  v7.0.9`, logged by `SpringApplication` under the main class's name — the reason `com.tiffinbox` is in the group.
- **The route lines' order** follows `getDeclaredMethods()`, which no specification fixes: never printed, only counted.

## For unit 26 — and unit 25's re-point, and RED

**Unit 26 starts from `../c5-unit24/after`** (the anchor has moved on since: `../c5-tiffinbox` is unit 26's `after/` now). What you
can rely on — measured here unless a line says otherwise:
- **`handle()`'s `finally` now has four statements:** `String route = …`, `String status = …`, the DEBUG line, then the timer's stop
  with `.tag("route", route)` and `.tag("status", status)`. Your wider catch is still the inner `catch (Exception e)` around
  `handler.invoke(this)`: it sits inside the `try`, so a 500 it writes passes through the same `finally` — logged and timed like any
  other answer (by construction; no 500 is measured here). An answer that never reaches `respond()` leaves
  `exchange.getResponseCode()` at `-1`, and the line would say `-> -1` (by construction, not measured).
- **The DEBUG line is silent at INFO**, so your captures' logs do not change unless a run sets `kitchen`, `tiffinbox` or the root to
  DEBUG or below. Whether Boot's `--debug` (the condition report) touches them is not measured here.
- **Logs:** count DEBUG lines by logger, never a line total; a TiffinBox line is written after its answer, so count after the stop or
  behind the scrape barrier (mask 3). Mask the time, the pid and `virtual-<n>` with its padding.
- **Exposure is still `health,prometheus`** (⚑3); `loggers` by flag, one JVM run; under AOT and in the binary, a flag exposes nothing.
- **The seven** are `115c36ba…` on the jar, the extracted class path, the exec run, the AOT jar and the binary, at every level here,
  root TRACE included.
- **The seed:** `.m2-demo` = `../c5-unit23/.m2-demo` less `com/tiffinbox/` (5,418 files; exec-maven-plugin 3.6.4 is in it).
- **Ports:** 24 used 19030-19039; nothing of this unit listens after it ends (Interrupted). Unit 26 owns 19050-19059.

**Unit 25 (DevTools), re-pointed to this tree before RED:** its copy under `.harness/dev/` changes by this unit's two files
(`TiffinBoxServer.java`, `application.yaml`) and the retirement (the two logging files gone, one line less in the POM's exec plugin);
the exposure list and the bridge are as unit 23 left them. If a unit 25 capture
counts log lines, the DEBUG line is silent unless it sets a level; whether a level set through `loggers` survives DevTools' restart
is **not measured here**. Its `anchor/` link and `before = after` move from `../c5-unit21/after` to `../c5-unit24/after`; its receipts re-run 3/3 under
both bashes (S4.1).

**For RED:** ⚑6b (above: RED decided, deleted here); the bridge's body handling and its query string — fixed by BLUE part A in the
Actuator lesson's anchor and carried here (`lock` C: 415, 415); whether the voice should say anything about
group-then-member (it does not; a chip does). And a
method note for every unit's S4.2 test: a `HOME` with a `settings.xml` does not seal Maven — Java reads `user.home` from the account,
so Maven reads the account's settings (here, none: straight to Maven Central). A sealed run needs `HOME/.mavenrc` setting
`-Duser.home` (the mvn script sources it after `receipts.sh` has cleared `MAVEN_OPTS`); a clone test that set `HOME` alone measured
the fresh-clone path, but not the seal.
