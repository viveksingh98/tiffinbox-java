# c5-unit26 — Failure Analysis

Course 5 · Spring Boot · Section 4, its last unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1, GraalVM CE
25.3.4.1** (native-image 25.0.4.1), 2026-10-07. Started twice on one port, TiffinBox's second start died under forty stack frames
and not one sentence from Boot: Boot's own port analyzer serves Boot's own web servers, and TiffinBox's server is the JDK's. This
unit measures that report as a shape, counts Boot's failure analyzers by jar, runs Course 4's setter cycle in plain Spring and in
Boot (ledger P34), gives TiffinBox an analyzer of its own and breaks its registration (A/B/A′, and C: the same class as a bean),
shows what the analyzer leaves alone (D and E: a bind that is not TiffinBox's port taken), brings the trace back with `--debug`,
re-checks the AOT jar and the native binary, and closes the hang the hints lesson left: a class missing after the start answered
nobody, and at INFO left nothing in the log; now it answers 500, and its error is logged.

**The anchor changes (brief ⚑8):**
- `PortTakenFailureAnalyzer.java` (new, `tiffinbox-web`, package `com.tiffinbox.web`, 28 lines that are code): **`class
  PortTakenFailureAnalyzer extends AbstractFailureAnalyzer<BindException>`**, its constructor taking Boot's `Environment`. Its
  `analyze` claims one failure only (RED C5-S4 #58): the message `Address already in use` **and** the bind `TiffinBoxServer.start`
  makes — that method on the exception's stack (not `TiffinBoxServer.main`, which is under every failure of a start: a first version
  that looked for the class alone still claimed another bean's bind, measured). Anything else gets `null`, and Boot prints the trace.
  It builds the description from `tiffinbox.address` and `tiffinbox.port` — nothing else, so no setting, the token included, can
  reach a failure report — and passes the `BindException` on as the analysis's cause, as Boot's own analyzers do. Description:
  `TiffinBox could not listen on <address>:<port>: something else already listens there.` Action: `Stop the program on that port,
  or start TiffinBox on another: --tiffinbox.port=<a free port>.`
- `tiffinbox-web/src/main/resources/META-INF/spring.factories` (new): three comment lines and **one line**,
  `org.springframework.boot.diagnostics.FailureAnalyzer=com.tiffinbox.web.PortTakenFailureAnalyzer`.
- `TiffinBoxServer.java`: `handle()`'s one catch clause around a route, `catch (Exception e)` → **`catch (Exception | LinkageError e)`**,
  with a comment, and its first line **logs the error at ERROR, with its trace**: `LOG.log(System.Logger.Level.ERROR, key + " failed",
  e)` — `key` is a route TiffinBox declares (the handler exists), never what the client typed (RED C5-S4 #59: at INFO the old catch,
  and the first version of this one, left a missing class with no trace in the log). Then, as before, 500 and the cause's simple
  name; the class's Javadoc gains a paragraph. Inside the `try`, so a 500 it writes passes the same `finally` — its answer logged at
  DEBUG and timed (`hang`). `OutOfMemoryError` and `StackOverflowError` are not `LinkageError`s: still not caught.
- `ActuatorRoutes.java` (the bridge): its catch, already `catch (Exception | LinkageError e)`, logs at ERROR too, on TiffinBox's
  logger — a `LinkageError` with its trace, any other failure by its class alone: an exception's message can quote what the client
  sent (a body, a level), and the log never holds what a client typed (`hang`: the body's words 0 times). The edit stays inside the
  catch block: the bridge's request handling is BLUE part A's to fix, once, in the Actuator lesson's anchor (RED C5-S4 #46, part A
  #2/#4), and that fix cascades here.
- **Not edited:** `tiffinbox-core` (`change`: 0 files differ), **`TiffinBoxApp.java` (⚑11 — so RED S2 #8, its stale Javadoc, stays
  DEFERRED)**, `KitchenHealthIndicator.java`, `KitchenMetrics.java`, `Route.java`, `application.yaml`, both POMs. (The previous tree
  already lost Course 3's two logging files and the exec plugin's `-D` argument: the logging lesson retired them.) The exposure list stays `health,prometheus` (⚑3): `beans` is a flag, for one run (`analysis` C).

When this unit was made, `c5-tiffinbox` and this unit's `after/` held the change and the anchor README's new section, and nothing
else (`diff -rq -x target ../c5-tiffinbox after` was empty); the anchor has moved on since: `../c5-tiffinbox` is unit 27's `after/` (`diff -rq -x target ../c5-tiffinbox ../c5-unit27/after` is empty). **Unit 27 (Section 5) starts from `after/`** (see the last section).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 9 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) It runs for about 17 to 80 minutes on the author's Mac, most of it the six native builds — two in each of `native`'s three runs,
123-688 s each, beside other units' native builds (load averages from about 6 to about 190). **After RED C5-S4 part A's bridge
fix (2026-10-08, the Actuator lesson's anchor carried here): 4,118 s under `./receipts.sh`** (/bin/bash 3.2.57, this folder, exit 0,
every capture = published), beside three other units' receipts (load averages about 170-410; native builds 359-998 s, inside the
20-minute bound); the two hashes that moved (`change`: the anchor README's lines added 93 → 94; `hang`: a body sent with a read,
now 200 and never read) were published from a 3.2 run of the same captures, 3/3, every check passed (4,775 s). The runs of record
of part B's revision (RED C5-S4 part B's fixes), 2026-10-08: **1010 s under `./receipts.sh`** (/bin/bash 3.2.57, this folder, exit 0, every capture =
published; the load had fallen to about 6) and **1010 s under `bash receipts.sh`** (Homebrew bash 5.3.9, from a sealed clone, exit 0) — "From a clone",
below. The five hashes that moved (`change`, `analysis`, `hang`, `native`, `exercise`) were published from two 3.2 runs, every capture
3/3 and every check passed (the first stopped at `native`, which drifted: the route lines' order differs between native builds, and
its new log reading printed them — now filtered out and counted). Every native build stayed inside the capture's bound, under 20
minutes. The first revision's runs of record, 2026-10-07: 1435 s (3.2) and 2328 s (5.3).
It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first, so you can see which one moved).
Published hashes: taken `5b3f472737fb372bc9b69c47e5408cb5` · analyzers `f902c8a19e5df4d82bc1ca01d5ab2569` · cycle `e282ed5a7d1e5b0e645b5ea5a573a44d` · change `b67fa4c2542a480583ac3847ddfe1c16` · analysis `20f94cf251d5b3eaf9d32180845b50a5` · debug `7bae9b43043ade3fcdf73b534de09f59` · hang `96f2460d0293ce5241201cb5d19356d6` · native `113cfa86985dae96661dfb4f5e6d04a6` · exercise `dd4e408e3f9bb389887f8d553cd2d7d1`

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else. It refuses a variable that does not name a
`bin/native-image`, and one whose `native-image --version` is not `native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1` — another
GraalVM prints other lines, so the captures could not match. The GraalVM's folder is never printed: every capture masks it as
`$GRAALVM_HOME`. Only `native` needs it: every Maven run and every `java` here is the plain JDK 25.0.4.1.

**Without a GraalVM** (`GRAALVM_HOME` not set): `receipts.sh` still runs. It fills `.m2-demo` (its first build), makes every
capture but `native` — `taken`, `analyzers`, `cycle`, `change`, `analysis`, `debug`, `hang` — and the exercise's, each checked
against `receipts.md5`, then stops where the native build would start, naming this section (exit 1).

## The repository, and what was downloaded

Every build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen): `../c5-unit24/.m2-demo` **less `com/tiffinbox/`**
(every run installs its own two modules first) — 5,418 files before this unit's own installs. **Nothing was downloaded** for this
unit: every build said `offline: yes`, the native-profile ones included. **Boot's web-server and Tomcat modules** (`analyzers` reads
their `spring.factories` from `$M2`; TiffinBox never ships them, so none of its builds fetches them) were in the seed — Section 4's
Tomcat tree brought them. Before the captures `receipts.sh` runs the harness's POM, `harness/jars/pom.xml` — no code, the two jars
alone, every transitive dependency excluded — from a copy under `.harness/` (`mvn -o -B -q compile`), with the same
offline-then-Central rule as every build: here it said `offline: yes`; on a fresh clone it fetches the two jars from Maven Central,
once, and says so.

**One way out is not Maven's.** GraalVM's native plugin reads its metadata repository (a zip,
`graalvm-reachability-metadata-1.1.8-repository.zip`, 3,362,517 bytes, from Maven Central) from the Maven repository — and when the
zip is not there it does not fail, even under `-o`: it downloads one from GitHub. So (1) the first build is the README's native
install, which needs nearly every artifact any capture's Maven line needs, the zip included — on a fresh clone it fills `.m2-demo`
from Maven Central, once; (2) a native-profile build while the zip is not in `.m2-demo` goes to Maven Central at once, never
offline first; (3) after the first build the script checks Boot's parent POM, the native plugin 1.1.8 and the zip are in `$M2`;
(4) every build's log is searched for the plugin's own download line — found, the build's line says `offline: no` and the run
stops. (The plugin's `Downloaded GraalVM reachability metadata repository from file:…` line names the zip in `$M2`: not a download
from the network, and not what the search matches.) At run time nothing leaves 127.0.0.1.

**From a clone, sealed — this revision (2026-10-08, RED C5-S4 part B's fixes; brief S4.2).** The repository was cloned (`git clone` of its HEAD) into an empty folder, and the four folders this revision changes — `c5-unit24`, `c5-unit25`, this one and `c5-tiffinbox` — put in exactly as the commit holds them (112 files, the deleted ones gone, nothing git ignores: no `.m2-demo`, no `.harness/`, no `.r-*` anywhere; `README.md` is the only file changed since, by this paragraph and the run-times note). `bash receipts.sh` (Homebrew bash 5.3.9) ran under `env -i`, with a `HOME` whose `.mavenrc` points Maven's `user.home` there and every Java proxy property at a port that refuses (127.0.0.1:9), and whose Maven settings send every repository to a `file://` copy of Central's files made from `.m2-demo` (4,073 files: TiffinBox's own installs, `_remote.repositories`, `*.lastUpdated`, `resolver-status.properties` and `.DS_Store` left out, `maven-metadata-central.xml` served as `maven-metadata.xml`); `http_proxy`, `https_proxy`, their capitals and `ALL_PROXY` at the same refusing port; `GRAALVM_HOME` set. **Exit 0 after 1010 s** — all 9 captures = published, every spoken number asserted, 0 raw demo tokens. Two builds said `offline: no` — the first (GraalVM's metadata repository was not in the empty `.m2-demo`) and the harness POM's resolve of Boot's web-server and Tomcat jars — and between them took 508 files, every one from the `file://` copy, 0 from anywhere else; every later build said `offline: yes`; `.m2-demo` ended with 1,391 files; the build logs name `github` only as the copy's own `com/github/…` paths and native-image's documentation link, and hold 0 lines of the native plugin's metadata download.

**From a clone, sealed (2026-10-07, brief S4.2).** The repository at this unit's commit (less this paragraph: `README.md` is the
only file changed since) — HEAD, plus this unit's folder and the anchor as committed, in a scratch repository — was cloned into an
empty folder: no `.m2-demo` in this unit or in unit 24's, no seed folder. `receipts.sh` ran under `env -i`, with a `HOME` whose
`.mavenrc` points Maven's `user.home` there (Java reads `user.home` from the account, not from `$HOME`) and every Java proxy property
at a port that refuses, and whose Maven settings send every repository to a `file://` copy of Central's files made from `.m2-demo`
(4,061 files: TiffinBox's own installs, `_remote.repositories`, `*.lastUpdated` and `resolver-status.properties` left out,
`maven-metadata-central.xml` served as `maven-metadata.xml`); `http_proxy`, `https_proxy`, their capitals and `ALL_PROXY` pointed at
the same refusing port. **With `GRAALVM_HOME` set, `./receipts.sh` (/bin/bash 3.2): exit 0 after 2124 s** — all 9 captures =
published, every spoken number asserted, 0 raw demo tokens. **Without it, `bash receipts.sh` (bash 5.3), in a second clone of its
own: the 8 captures that need no GraalVM = published, the exercise's included, then the stop the script announces (exit 1 after
316 s).** Both times the first build said `offline: no` (the metadata zip was not in the empty `.m2-demo`) and downloaded 508 files,
every one from the `file://` copy, and the harness POM's resolve of Boot's web-server and Tomcat jars said `offline: no` too; every
later build said `offline: yes`, `.m2-demo` ended with 1,391 files, and `github` appears 0 times in either run's log (in the build
logs only as the copy's own `com/github/…` paths and native-image's documentation link).

## The demo token — fake, and never printed

TiffinBox does not start without its shutdown token. Every run starts in a folder under `.harness/` holding a config tree,
`secrets/tiffinbox/shutdown-token` (`-rw-------`, folders `drwx------`), with a 26-character demo token that is fake and looks it;
`receipts.sh` writes it when it runs. The token never reaches a command line: the seven requests and `harness/shutdown.sh` read it
from the file. Every capture is masked — the token becomes `[masked: the 26-character token]` — and `receipts.sh` counts the raw
token in each run's own output **before** masking (`.harness/raw-*`: 0 in all 27 capture runs); in **every failed start's log** —
standard output and error, the whole report, trace or analysis: 0 each (36 failed starts in the run of record); in **the
log of every TiffinBox that served** — counted for the token and for the shutdown header's name, `X-Shutdown-Token`, in any case: 0
and 0 each (33 logs); in the **beans answers saved on the way — each counted, then deleted in the same step** (`gone()`:
3 of them, 0 each); then in every capture, this README, the exercise, the harness, `receipts.md5`, the anchor README, the
analyzer, `spring.factories`, `TiffinBoxServer.java`, and in the **bytes of both binaries** each run builds: 0 each. The builder
counts it again in the script, the deck and the prompter: 0. **The analysis cannot carry it:** its text is the address and the
port, read by name (`change`). Boot's own analyzers print the value they could not use — `Value: "nineteen"` (`analyzers`) — which
is why the secrets lesson's length rule is a yes-or-no method, never a constraint on the token itself. The exercise makes a random
token of its own, which it never prints either.

## The folders, the variables and the ports

- `.harness/before/` — the previous tree, `../c5-unit24/after`, copied (for `change`); `.harness/after/` — `after/` copied and built
  with the README's native install (the run's first build: it fills `.m2-demo` on a fresh clone); its jar extracted to compile the
  harness.
- `taken`: `.harness/prev/` (the previous tree, built the README's plain way). `analyzers`, `cycle`, `analysis` A/A′ and the first
  TiffinBox, `debug`: `.harness/serve/` (after/, built the README's plain way and extracted). `analysis` B: `.harness/noline/`
  (after/ less the factories line); C: `.harness/bean/` (after/ with `@Component` on the class and no factories file). `hang`:
  `.harness/hb/` (the previous tree) and `.harness/ha/` (after/), each built, extracted, and given the README's trimmed copy under
  `tiffinbox-web/target/hang/`. `native`: `.harness/nat/` (after/, the README's two native lines) and `.harness/natc/` (after/ less
  the route annotation's `@Reflective`, the same two lines). `analysis` D and E: `.harness/serve/` again (D its jar, E its extracted
  class path with the harness's `Elsewhere` joined); `hang`'s INFO run: `.harness/ha/` again. The exercise: `.harness/mine/`.
- **The harness** (`harness/probe/cycle/`, the course's, never TiffinBox's; outside `com.tiffinbox`; compiled into `.harness/hc`
  against the first build's extracted jar): `Cook` and `Rail` — each needs the other, through an `@Autowired` setter, the shape of
  Course 4's `SetterBilling`/`SetterDelivery` — joined to TiffinBox by `--spring.main.sources=probe.cycle.Cook,probe.cycle.Rail` on
  the extracted class path (the README's `java -cp …` line, `../hc` added); `Plain` — a `main` that registers the two in a plain
  `AnnotationConfigApplicationContext` (no Boot), refreshes it and prints what it holds, Logback's root set to WARN first (with no
  configuration of its own Logback would print every DEBUG line of the refresh); `Tally` — the exercise's report, joined beside
  the cure: when TiffinBox is ready it prints what the cook and the rail each depend on (the bean factory's names) and the number
  each counts (RED C5-S4 #62: a done line that tells the cure from deleting the setters or flipping the switch).
  `harness/probe/bind/Elsewhere` — a bean that is not TiffinBoxServer and binds `127.0.0.1` and `probe.bind.port` when it is created
  (`analysis` E, joined by `--spring.main.sources=probe.bind.Elsewhere --probe.bind.port=19052`). `harness/shutdown.sh`: POST /shutdown with the
  token from a file and a 5-second limit (the metrics lesson's). `harness/jars/pom.xml`: the POM that resolves Boot's web-server and
  Tomcat jars into `$M2` (above).
- On screen: `$CURLSET` = `../c5-unit11/curlset.sh`, the comparison set since the secrets lesson; `$M2` = this unit's `.m2-demo`;
  `$GRAALVM_HOME` = the GraalVM; `$pid` = the process id `receipts.sh` kept when it started a binary (`native` C). Every other
  command is printed whole.
- **The class-path layouts** (S4.18): the executable jar (`java -jar`, Boot's launcher) in `taken`, `analyzers`' malformed value,
  `analysis`, `debug`; the extracted jar with `-cp` in `cycle` (so the harness can join); the extracted **thin** jar with `java -jar`
  in `hang` — its manifest's `Class-Path` names `lib/…` relative to the jar, so the README copies the thin jar **beside** the trimmed
  `lib/` (a thin jar left in `extracted/` would read the intact lib, whatever `-cp` says); the AOT jar and the binary in `native`.
- Ports (brief ⚑10, 19050-19059, checked free with `lsof` before anything is wiped; 18425 and 8080 too): `taken` 19050 · `cycle`
  19051 · `analysis` 19052 (and 19053: C's context, D, E's TiffinBox) · `debug` 19054 · `hang` 19055 · `native` 19056 (and 19057, C) · the exercise
  19059; 19058 unused. **The port taken in every capture is this unit's own**, held by a first TiffinBox of the same tree; nothing
  passes a bare port number.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM and the token** (`gsub()`, the patterns escaped as literals), in every line of every capture: the demo token
   → `[masked: the 26-character token]`; the GraalVM's folder → `$GRAALVM_HOME`; this folder's absolute path → `…` (also
   URL-encoded); the folder above it → `…/..`; the home folder → `~`; the user name → `<user>`. A last check fails if any capture
   still holds `/Users/`, `/private/`, `/home/` or `/var/folders/`, the GraalVM's folder, a unit number, Boot's process line
   (`with PID`, `started by`), a log line's time or a virtual thread's number.
2. **A failed start's log is read after it exited, never printed whole** (`fails()`, `SHAPEAWK`). Its standard output and error go
   to `.harness/fail.out` and `fail.err`. A capture shows its **shape**: `APPLICATION FAILED TO START` (the banner), the stack frames
   (`at …` lines), the `Caused by:` lines and the frames Logback folds as common (`... N common frames omitted`), counted — a frame
   carries a class, a method and a line number, so none is shown; the WARN, ERROR and DEBUG lines from their level on (no time, no
   pid), **a WARN's message cut after its exception's class, marked ` …`** (the rest names the bean, and for a bind failure its jar's
   URL); the first line of each exception; Boot's hint about the condition report; the condition report's four sections, counted
   (`--debug` only); then the analysis, from `Description:` to its end, its blank lines left out. Then its standard error's line
   count and the token, raw. **Never a line total** (S4.19): the probes counted 56 and 62 lines for the same failure.
3. **A running TiffinBox's log** (`.harness/run.out`, `run.err`) is read after it stopped: Boot's first line, cut before ` with PID`;
   TiffinBox's answer lines (its own logger's DEBUG lines that are not route lines), whole, with the time → `<time>`, the process id →
   `<pid>`, a virtual thread's name → `[    virtual-<n>]`; counts of the banner and WARN lines; its standard error's uncaught
   exceptions, frames and causes, counted, the first exception's and cause's lines shown. **The barrier** (`hang`, `native` C):
   before the stop, the script waits — silently, every 0.1 s, up to 15 s — until the scrape counts the answer it is about to read
   (TiffinBox writes an answer's line before its timer stops), and prints the scrape's one line for that route; the scrape is read
   from a pipe, never written to a file.
4. **The jars' `spring.factories`** are read in Python like `java.util.Properties` (a line ending in a backslash continues on the
   next; `#` and `!` start a comment), the key `org.springframework.boot.diagnostics.FailureAnalyzer` split at its commas — never
   counted by lines (a line count once gave 21 on a probe). The jars are listed by name, Boot's sorted, TiffinBox's thin jar last;
   each analyzer by its simple class name. **Boot's metadata** (`spring-configuration-metadata.json`) and **Spring's AOT metadata**
   (`reachability-metadata.json`) are read as JSON through filters that print one property, and one resource and one class.
5. **The beans answer** (`/actuator/beans`, the README's beans flag, one run: C's context) is written by the README's own curl line
   beside the run's config tree, read through a filter that prints the beans of one name — type and scope, never a resource path —
   and deleted in the same step (`gone()`; the exit trap deletes any left, and a last check fails if one is).
6. **Maven's and native-image's logs** are read, never printed whole: each build's `offline`/`exit` line; native-image's goal, the
   GraalVM it found, the builder's Java, its warnings (the file URL cut), the eight stage names, the warning count and `BUILD
   SUCCESS`, the rest counted; every log searched for the plugin's metadata-repository download line.
7. **No duration is captured**: each native build is judged against a bound (1 minute or more, under 20 minutes — native builds
   here took up to 8 minutes under load); its seconds go to the terminal.
8. **Hygiene:** `receipts.sh` unsets every `TIFFINBOX_*`, `SPRING_*`, `MANAGEMENT_*`, `SERVER_*` and `LOGGING_*` variable, `DEBUG`
   (Boot reads it as `--debug`: every failed start would print the condition report and the trace), `JAVA_TOOL_OPTIONS`,
   `JDK_JAVA_OPTIONS`, `_JAVA_OPTIONS`, `MAVEN_OPTS`, `MAVEN_ARGS` and `NATIVE_IMAGE_OPTIONS` before it runs anything — the list is an extended regular
   expression (`sed -E`: `/usr/bin/sed`'s basic one has no alternation, and the `\|` this script once used removed nothing — RED
   C5-S4 #63), and the script plants a canary under every one of those names first and stops if one survives; it puts
   `127.0.0.1` and `localhost` first in `no_proxy` and `NO_PROXY`; it refuses to run twice at once in this folder (`.r-lock`), with a
   `secrets/` in this folder, or with a `secrets/`, a `tiffinbox-local.yaml` or a `target/` in `after/`. No capture reads the
   process's environment, so macOS's `__CF_USER_TEXT_ENCODING` (CoreFoundation writes it into a process's environment) changes
   nothing here. **S4.16:** a last check greps this script, this README, the exercise's and every capture for an exposure list with a
   star, and fails on any.

**Interrupted.** `receipts.sh`'s exit trap stops the processes it started in the background — a serving TiffinBox (`$pid`) and a
start expected to fail (`$fpid`) — if they still run, then `sweep()`s this run's process group for anything of this run — a
TiffinBox JVM (its jar, the hang's thin jar, or `com.tiffinbox.web.TiffinBoxServer` on a class path), the harness's `Plain`, a
binary, native-image's driver or its builder JVM (`java @…/vminvocation.args`) — TERM, then KILL after 5 s; then it deletes any
beans answer a run left, and, after an interrupt only, the capture runs left unfinished (`.r-NAME.1-3`; after a failed check they
stay, for the diff the message names); then it drops the lock. Maven and native-image's builds run in the foreground: Ctrl-C reaches
them directly. Every command in the trap is guarded, so `set -e` cannot end it early. **Not re-run on this revision (2026-10-08):** RED C5-S4 part B's fixes left the trap and `sweep()` as they were; this revision's interrupt test ran on unit 24 (`../c5-unit24/README.md`, "Interrupted": exit 130, nothing left). The tests below are this unit's, on its first revision. **Tested 2026-10-07 on the final script, twice**, with `receipts.sh` as a job of its own process group (job control on, as a
terminal's foreground job is) and `SIGINT` sent to the whole group: **(1) during `analysis`**, 124 s in, while a first TiffinBox
held 19052 and a second one was starting on the same port (in the group: 4 processes — the script, the two TiffinBox JVMs and the
`sleep` of its readiness poll) — **exit 130**; 5 s later 0 processes in the group, and anywhere 0 processes whose command names this
unit's folder; 18425, 8080 and 19050-19059 free; `.r-lock` gone; no beans answer and no unfinished capture file left; **(2) during
the native build**, 588 s in, 25 s after native-image started (in the group: 5 processes — the script and its subshell, Maven,
native-image's driver, its builder JVM) — **exit 130**, and the same: nothing left, every port free. (The count of processes left
is scoped to this unit's folder: other agents run TiffinBoxes and native builds of their own on this Mac, on their own ports.)

## 1 · taken — the previous tree, started twice on one port

The previous tree, built the README's plain way; the README's run line on 19050 — listening, ready; then the same line again on the
same port, while the first one runs. The second exits 1: its log's shape — 40 frames, one `Caused by:`, 24 frames folded as common,
no `APPLICATION FAILED TO START`; Spring's WARN, Boot's `Application run failed`, the two exceptions' first lines
(`BeanCreationException` for `tiffinBoxServer`, `Caused by: java.net.BindException: Address already in use`), and the one sentence
Boot logs, a hint to re-run with `debug`. The first one, still the process listening, then its seven.

`.r-taken.out` · md5 `5b3f472737fb372bc9b69c47e5408cb5` · 3 of 3

```
the previous tree (the anchor as the logging lesson left it), copied to .harness/prev with a config tree, built the
README's plain way; the README's run line, port 19050 - TiffinBox, started once:
$ cd .harness/prev && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the previous tree · offline: yes · exit 0
$ cd .harness/prev && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19050
  listens on: 127.0.0.1:19050
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19050/actuator/health/readiness
  {"status":"UP"} 200
and again - the same line, the same port, while the first one runs:
$ cd .harness/prev && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19050
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 0 · stack frames 40 = 25 + 15 · Caused by: 1 · frames folded as common 24
  WARN s.c.a.AnnotationConfigApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.BeanCreationException …
  ERROR o.s.boot.SpringApplication: Application run failed
  org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'tiffinBoxServer': Invocation of init method failed
  Caused by: java.net.BindException: Address already in use
  the hint Boot logs: Error starting ApplicationContext. To display the condition evaluation report re-run your application with 'debug' enabled.
  its standard error: 0 lines · the demo token in its log: 0
the first one, after the second exited:
  the process listening on 19050: the one started above: yes
$ $CURLSET 19050 .harness/prev/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 2 · analyzers — Boot's failure analyzers, by jar; a malformed value

after/ built the README's plain way and extracted (46 jars in `lib/`). Every jar of that class path — `lib/`, then the thin jar with
TiffinBox's own classes — read for `META-INF/spring.factories` and its `FailureAnalyzer` key: **`spring-boot` 18,
`spring-boot-autoconfigure` 2, `spring-boot-micrometer-metrics` 1 — Boot's 21 — and TiffinBox's 1.** Among Boot's, the ones earlier
lessons met (the auto-configuration lesson's missing bean, `NoSuchBeanDefinitionFailureAnalyzer`; the validation lesson's,
`BindValidationFailureAnalyzer`; the profiles lesson's missing import file, `ConfigDataNotFoundFailureAnalyzer`), the cycle's
(`BeanCurrentlyInCreationFailureAnalyzer`) and the bind analyzer. **Boot's port analyzer** is in neither: `spring-boot-web-server`
(read from `$M2`) names `PortInUseFailureAnalyzer` and `MissingWebServerFactoryBeanFailureAnalyzer`, `spring-boot-tomcat`
`ConnectorStartFailureAnalyzer` — and TiffinBox's `lib/` holds 0 of either jar. Then the README's malformed-value line,
`--tiffinbox.port=nineteen`: 0 frames, the banner, `Failed to bind properties under 'tiffinbox.port' to java.lang.Integer:` with
its `Property`, `Value: "nineteen"`, `Origin` and `Reason`, and `Update your application's configuration`.

`.r-analyzers.out` · md5 `f902c8a19e5df4d82bc1ca01d5ab2569` · 3 of 3

```
after/, copied to .harness/serve with a config tree, built the README's plain way, then extracted (the README's extract line):
$ cd .harness/serve && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built after/ · offline: yes · exit 0
$ cd .harness/serve && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  extracted: exit 0 · its lib/ holds 46 jars
Boot's failure analyzers - every jar of the extracted class path (lib/, then the thin jar that holds TiffinBox's own
classes): its META-INF/spring.factories, the key org.springframework.boot.diagnostics.FailureAnalyzer, its value parsed:
  spring-boot-4.1.1.jar: 18
    ConfigDataNotFoundFailureAnalyzer
    IncompatibleConfigurationFailureAnalyzer
    NotConstructorBoundInjectionFailureAnalyzer
    AotInitializerNotFoundFailureAnalyzer
    BeanCurrentlyInCreationFailureAnalyzer
    BeanDefinitionOverrideFailureAnalyzer
    BeanNotOfRequiredTypeFailureAnalyzer
    BindFailureAnalyzer
    BindValidationFailureAnalyzer
    InvalidConfigurationPropertyNameFailureAnalyzer
    InvalidConfigurationPropertyValueFailureAnalyzer
    MissingParameterNamesFailureAnalyzer
    MutuallyExclusiveConfigurationPropertiesFailureAnalyzer
    NoSuchMethodFailureAnalyzer
    NoUniqueBeanDefinitionFailureAnalyzer
    PatternParseFailureAnalyzer
    UnboundConfigurationPropertyFailureAnalyzer
    ValidationExceptionFailureAnalyzer
  spring-boot-autoconfigure-4.1.1.jar: 2
    NoSuchBeanDefinitionFailureAnalyzer
    BundleContentNotWatchableFailureAnalyzer
  spring-boot-micrometer-metrics-4.1.1.jar: 1
    ValidationFailureAnalyzer
  tiffinbox-web-1.0.0.jar: 1
    PortTakenFailureAnalyzer
  jars read: 47 · with the key: 4 · analyzers named: 22
Boot's port analyzer - Boot's web-server module and its Tomcat module, read from $M2; TiffinBox ships neither:
  spring-boot-tomcat-4.1.1.jar: 1
    ConnectorStartFailureAnalyzer
  spring-boot-web-server-4.1.1.jar: 2
    PortInUseFailureAnalyzer
    MissingWebServerFactoryBeanFailureAnalyzer
  jars read: 2 · with the key: 2 · analyzers named: 3
  in TiffinBox's lib/: spring-boot-web-server 0 jars · spring-boot-tomcat 0 jars
a malformed value - the README's line, a word where the port goes:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=nineteen
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0
  WARN s.c.a.AnnotationConfigApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.UnsatisfiedDependencyException …
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  the hint Boot logs: Error starting ApplicationContext. To display the condition evaluation report re-run your application with 'debug' enabled.
  Description:
  Failed to bind properties under 'tiffinbox.port' to java.lang.Integer:
      Property: tiffinbox.port
      Value: "nineteen"
      Origin: "tiffinbox.port" from property source "commandLineArgs"
      Reason: failed to convert java.lang.String to @jakarta.validation.constraints.NotNull @jakarta.validation.constraints.Min java.lang.Integer (caused by java.lang.NumberFormatException: For input string: "nineteen")
  Action:
  Update your application's configuration
  its standard error: 0 lines · the demo token in its log: 0
```


## 3 · cycle — Course 4's setter cycle, in plain Spring and in Boot (ledger P34)

The harness's `Plain`, on after/'s extracted class path: plain Spring registers `Cook` and `Rail`, refreshes — `the context started:
true · allowCircularReferences: true`, each holding the other. Then Boot: the README's exploded run with the two joined — exit 1,
0 frames, the analysis drawing `cook ↑↓ rail`, the Action naming `spring.main.allow-circular-references` as a last resort; nothing
listened (no port after the exit, no `TiffinBox listening` line: the refresh stopped before TiffinBox's server opened). Boot's own metadata for the switch: `java.lang.Boolean ·
default false · declared by org.springframework.boot.SpringApplication`. Then the README's switch line on the same run: listening,
the seven `115c36ba…`, no banner, no WARN.

`.r-cycle.out` · md5 `e282ed5a7d1e5b0e645b5ea5a573a44d` · 3 of 3

```
the harness's Cook and Rail (harness/probe/cycle/): each needs the other, through a setter. Plain Spring first - the
harness's Plain registers the two in an AnnotationConfigApplicationContext, no Boot, on after/'s extracted class path:
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" probe.cycle.Plain
  harness: plain Spring, Cook and Rail - the context started: true · allowCircularReferences: true · the cook's rail is the rail bean: true · the rail's cook is the cook bean: true
Boot - the README's exploded run, the two joined by --spring.main.sources, port 19051:
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19051 --spring.main.sources=probe.cycle.Cook,probe.cycle.Rail
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0
  WARN s.c.a.AnnotationConfigApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.UnsatisfiedDependencyException …
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  the hint Boot logs: Error starting ApplicationContext. To display the condition evaluation report re-run your application with 'debug' enabled.
  Description:
  The dependencies of some of the beans in the application context form a cycle:
  ┌─────┐
  |  cook
  ↑     ↓
  |  rail
  └─────┘
  Action:
  Relying upon circular references is discouraged and they are prohibited by default. Update your application to remove the dependency cycle between beans. As a last resort, it may be possible to break the cycle automatically by setting spring.main.allow-circular-references to true.
  its standard error: 0 lines · the demo token in its log: 0
  listening on 19051 now: 0 · TiffinBox's listening line in its log: 0
Boot's own metadata for the switch - spring-boot-4.1.1.jar's META-INF/spring-configuration-metadata.json, from the extracted lib:
  spring.main.allow-circular-references: java.lang.Boolean · default false · declared by org.springframework.boot.SpringApplication
the README's switch, on the same run:
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19051 --spring.main.sources=probe.cycle.Cook,probe.cycle.Rail --spring.main.allow-circular-references=true
  listens on: 127.0.0.1:19051
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19051/actuator/health/readiness
  {"status":"UP"} 200
$ $CURLSET 19051 .harness/serve/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  its log: APPLICATION FAILED TO START 0 · WARN lines 0
```


## 4 · change — the previous tree against after/

`diff -rq` of the two trees (copied under `.harness/`): the README, the server and the bridge differ, and two paths are new — the
analyzer and the `META-INF/` folder. The analyzer's code lines, whole (28: the guard, `return null`, the frame check); the factories
file's one line; the server's diff counted, its code lines (the catch clause, removed and added, and its ERROR line); every catch
clause in `handle()`, before and after; the anchor README's new section, counted; tiffinbox-core compared (`diff -rq -x target`: 0
files); the bridge's diff counted, its code lines (the two ERROR lines and their `if`); `TiffinBoxApp.java`,
`KitchenHealthIndicator.java`, `KitchenMetrics.java`, `Route.java`, `application.yaml` and both POMs byte for byte.

`.r-change.out` · md5 `b67fa4c2542a480583ac3847ddfe1c16` · 3 of 3

```
the previous tree against after/, both copied under .harness/ - the files that differ:
$ diff -rq -x target -x secrets .harness/before .harness/after
  Files .harness/before/README.md and .harness/after/README.md differ
  Files .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/ActuatorRoutes.java and .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web/ActuatorRoutes.java differ
  Only in .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web: PortTakenFailureAnalyzer.java
  Files .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java and .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java differ
  Only in .harness/after/tiffinbox-web/src/main/resources: META-INF
  tiffinbox-web/src/main/java/com/tiffinbox/web/PortTakenFailureAnalyzer.java - new; its lines that are neither comment nor blank: 28
    package com.tiffinbox.web;
    import org.springframework.boot.diagnostics.AbstractFailureAnalyzer;
    import org.springframework.boot.diagnostics.FailureAnalysis;
    import org.springframework.core.env.Environment;
    import java.net.BindException;
    class PortTakenFailureAnalyzer extends AbstractFailureAnalyzer<BindException> {
        private final Environment environment;
        PortTakenFailureAnalyzer(Environment environment) {
            this.environment = environment;
        }
        @Override
        protected FailureAnalysis analyze(Throwable rootFailure, BindException cause) {
            if (!"Address already in use".equals(cause.getMessage()) || !thrownIn(TiffinBoxServer.class, "start", cause)) {
                return null;                             // not TiffinBox's port taken: Boot keeps the trace
            }
            String where = environment.getProperty("tiffinbox.address") + ":" + environment.getProperty("tiffinbox.port");
            return new FailureAnalysis("TiffinBox could not listen on " + where + ": something else already listens there.",
                    "Stop the program on that port, or start TiffinBox on another: --tiffinbox.port=<a free port>.", cause);
        }
        private static boolean thrownIn(Class<?> type, String method, Throwable failure) {
            for (StackTraceElement frame : failure.getStackTrace()) {
                if (frame.getClassName().equals(type.getName()) && frame.getMethodName().equals(method)) {
                    return true;
                }
            }
            return false;
        }
    }
  tiffinbox-web/src/main/resources/META-INF/spring.factories - new; its lines that are neither comment nor blank: 1
    org.springframework.boot.diagnostics.FailureAnalyzer=com.tiffinbox.web.PortTakenFailureAnalyzer
  tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java - diff adds 8 lines, removes 1; the lines that are code, not comment:
    <             } catch (Exception e) {
    >             } catch (Exception | LinkageError e) {   // a class the route needs, missing: 500, never a silent client
    >                 LOG.log(System.Logger.Level.ERROR, key + " failed", e);   // a route TiffinBox declares (its handler exists), and the trace
  every catch clause in handle(), before and after (grep -n):
    before 177: } catch (Exception e) {
    after  183: } catch (Exception | LinkageError e) {   // a class the route needs, missing: 500, never a silent client
  README.md - the anchor's README: lines added 94, removed 0 - its new section (not shown)
  tiffinbox-core against the previous tree's (diff -rq -x target): 0 files differ
  tiffinbox-web/src/main/java/com/tiffinbox/web/ActuatorRoutes.java - diff adds 6 lines, removes 0; the lines that are code, not comment:
    >             System.Logger log = System.getLogger("tiffinbox");     // TiffinBox's own logger: every 500 here is logged, at ERROR
    >             if (e instanceof LinkageError) {         // TiffinBox's own fault: the error and its trace
    >                 log.log(System.Logger.Level.ERROR, "an actuator request failed", e);
    >             } else {                                 // its message can quote what the client sent - a body, a level: the class alone
    >                 log.log(System.Logger.Level.ERROR, "an actuator request failed: {0}", e.getClass().getName());
    >             }
  TiffinBoxApp.java against the previous tree's, byte for byte: the same
  KitchenHealthIndicator.java against the previous tree's, byte for byte: the same
  KitchenMetrics.java against the previous tree's, byte for byte: the same
  Route.java against the previous tree's, byte for byte: the same
  tiffinbox-web/src/main/resources/application.yaml against the previous tree's, byte for byte: the same
  tiffinbox-web/pom.xml against the previous tree's, byte for byte: the same
  pom.xml against the previous tree's, byte for byte: the same
```


## 5 · analysis — the break (A/B/A′): the analyzer's one line; and C, the same class as a bean

A first TiffinBox (after/'s jar, the README's run line) holds 19052; each run is a second one, the same line. **A** — after/: exit 1,
the banner, 0 frames, `TiffinBox could not listen on 127.0.0.1:19052: something else already listens there.` and the Action, printed
by Boot's `LoggingFailureAnalysisReporter`. **B** — a copy with the factories line deleted (`sed`, the diff shown), built: 40 frames,
no banner, `Application run failed` — the previous tree's report. **A′** — A's command, re-run: the same. **C (labelled)** — a copy
with `@Component` on the class and no factories file (the diff shown), built: 40 frames, no banner. The first one, still the process
listening, then its seven. Then C's context on 19053, the README's beans flag line for one run: `/actuator/beans`, filtered to the
name — **1 bean `portTakenFailureAnalyzer`, `com.tiffinbox.web.PortTakenFailureAnalyzer`, singleton**: on a free port the context
holds the analyzer. That failing start never reached a context Boot could ask (its WARN: `cancelling refresh attempt`), and Boot
does not ask: **`javap` of spring-boot 4.1.1's `FailureAnalyzers`** — before D — shows it loading analyzers through
`SpringFactoriesLoader` (`forDefaultResourceLocation`, then `load`) and making 0 calls that ask the context for a bean (RED C5-S4
#61). **D (labelled)** — the README's address line, `--tiffinbox.address=192.0.2.1` (an address kept for documentation: no machine
has it): exit 1, 40 frames, no banner, `Caused by: java.net.BindException: Can't assign requested address` — a `BindException` that
is not a taken port. **E (labelled)** — the harness's `Elsewhere` joined, binding the port the first TiffinBox holds, TiffinBox
itself on 19053: exit 1, the trace (32 frames), `Error creating bean with name 'elsewhere'`, `Address already in use` — another bean's
bind. Neither says `already listens` (RED C5-S4 #58: before the guard, both did).

`.r-analysis.out` · md5 `20f94cf251d5b3eaf9d32180845b50a5` · 3 of 3

```
the break: the analyzer's one line. A first TiffinBox holds port 19052 - after/'s jar (.harness/serve), the README's run line:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19052
  listens on: 127.0.0.1:19052
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19052/actuator/health/readiness
  {"status":"UP"} 200
each run below is a second TiffinBox, the same line, on that port.
A - after/ (.harness/serve):
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19052
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0
  WARN s.c.a.AnnotationConfigApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.BeanCreationException …
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  the hint Boot logs: Error starting ApplicationContext. To display the condition evaluation report re-run your application with 'debug' enabled.
  Description:
  TiffinBox could not listen on 127.0.0.1:19052: something else already listens there.
  Action:
  Stop the program on that port, or start TiffinBox on another: --tiffinbox.port=<a free port>.
  its standard error: 0 lines · the demo token in its log: 0
B - a copy of after/ without the factories line (.harness/noline), built the README's plain way:
$ sed -i '' '/^org\.springframework\.boot\.diagnostics\.FailureAnalyzer=/d' .harness/noline/tiffinbox-web/src/main/resources/META-INF/spring.factories
$ diff after/tiffinbox-web/src/main/resources/META-INF/spring.factories .harness/noline/tiffinbox-web/src/main/resources/META-INF/spring.factories
  4d3
  < org.springframework.boot.diagnostics.FailureAnalyzer=com.tiffinbox.web.PortTakenFailureAnalyzer
$ cd .harness/noline && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the copy without the line · offline: yes · exit 0
$ cd .harness/noline && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19052
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 0 · stack frames 40 = 25 + 15 · Caused by: 1 · frames folded as common 24
  WARN s.c.a.AnnotationConfigApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.BeanCreationException …
  ERROR o.s.boot.SpringApplication: Application run failed
  org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'tiffinBoxServer': Invocation of init method failed
  Caused by: java.net.BindException: Address already in use
  the hint Boot logs: Error starting ApplicationContext. To display the condition evaluation report re-run your application with 'debug' enabled.
  its standard error: 0 lines · the demo token in its log: 0
A' - A again:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19052
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0
  WARN s.c.a.AnnotationConfigApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.BeanCreationException …
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  the hint Boot logs: Error starting ApplicationContext. To display the condition evaluation report re-run your application with 'debug' enabled.
  Description:
  TiffinBox could not listen on 127.0.0.1:19052: something else already listens there.
  Action:
  Stop the program on that port, or start TiffinBox on another: --tiffinbox.port=<a free port>.
  its standard error: 0 lines · the demo token in its log: 0
C (labelled) - the same class as a bean: a copy of after/ (.harness/bean), @Component on the class, no factories file:
$ sed -i '' 's/^class PortTakenFailureAnalyzer /@org.springframework.stereotype.Component class PortTakenFailureAnalyzer /' .harness/bean/tiffinbox-web/src/main/java/com/tiffinbox/web/PortTakenFailureAnalyzer.java && rm .harness/bean/tiffinbox-web/src/main/resources/META-INF/spring.factories
$ diff -r -x target -x secrets after .harness/bean
  diff -r -x target -x secrets after/tiffinbox-web/src/main/java/com/tiffinbox/web/PortTakenFailureAnalyzer.java .harness/bean/tiffinbox-web/src/main/java/com/tiffinbox/web/PortTakenFailureAnalyzer.java
  24c24
  < class PortTakenFailureAnalyzer extends AbstractFailureAnalyzer<BindException> {
  ---
  > @org.springframework.stereotype.Component class PortTakenFailureAnalyzer extends AbstractFailureAnalyzer<BindException> {
  Only in after/tiffinbox-web/src/main/resources/META-INF: spring.factories
$ cd .harness/bean && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the copy with the bean · offline: yes · exit 0
$ cd .harness/bean && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19052
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 0 · stack frames 40 = 25 + 15 · Caused by: 1 · frames folded as common 24
  WARN s.c.a.AnnotationConfigApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.BeanCreationException …
  ERROR o.s.boot.SpringApplication: Application run failed
  org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'tiffinBoxServer': Invocation of init method failed
  Caused by: java.net.BindException: Address already in use
  the hint Boot logs: Error starting ApplicationContext. To display the condition evaluation report re-run your application with 'debug' enabled.
  its standard error: 0 lines · the demo token in its log: 0
where Boot gets its analyzers - spring-boot 4.1.1's FailureAnalyzers, its calls read by javap (filtered, counted):
$ javap -c -p -cp "$M2/org/springframework/boot/spring-boot/4.1.1/spring-boot-4.1.1.jar" org.springframework.boot.diagnostics.FailureAnalyzers
  invokestatic SpringFactoriesLoader.forDefaultResourceLocation
  invokevirtual SpringFactoriesLoader.load
  invokevirtual SpringFactoriesLoader.load
  calls that ask the context for a bean (getBean, getBeansOfType, getBeanProvider, getBeanNamesForType): 0
D (labelled) - an address this machine does not have (192.0.2.1, kept for documentation): the README's address line, port 19053:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19053 --tiffinbox.address=192.0.2.1
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 0 · stack frames 40 = 25 + 15 · Caused by: 1 · frames folded as common 24
  WARN s.c.a.AnnotationConfigApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.BeanCreationException …
  ERROR o.s.boot.SpringApplication: Application run failed
  org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'tiffinBoxServer': Invocation of init method failed
  Caused by: java.net.BindException: Can't assign requested address
  the hint Boot logs: Error starting ApplicationContext. To display the condition evaluation report re-run your application with 'debug' enabled.
  its standard error: 0 lines · the demo token in its log: 0
E (labelled) - another bean's bind, on the port the first TiffinBox holds: after/'s extracted class path with the harness's
Elsewhere joined (a bean that binds 127.0.0.1 and probe.bind.port when it is created); TiffinBox itself on 19053, free:
$ cd .harness/serve && java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19053 --spring.main.sources=probe.bind.Elsewhere --probe.bind.port=19052
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 0 · stack frames 32 = 20 + 12 · Caused by: 1 · frames folded as common 19
  WARN s.c.a.AnnotationConfigApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.BeanCreationException …
  ERROR o.s.boot.SpringApplication: Application run failed
  org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'elsewhere': Invocation of init method failed
  Caused by: java.net.BindException: Address already in use
  the hint Boot logs: Error starting ApplicationContext. To display the condition evaluation report re-run your application with 'debug' enabled.
  its standard error: 0 lines · the demo token in its log: 0
the first TiffinBox, after the six:
  the process listening on 19052: the one started above: yes
$ $CURLSET 19052 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C's context, on a free port - the README's beans line, port 19053:
$ cd .harness/bean && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19053 --management.endpoints.web.exposure.include=health,prometheus,metrics,beans
  listens on: 127.0.0.1:19053
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19053/actuator/health/readiness
  {"status":"UP"} 200
$ cd .harness/bean && curl -s -o beans.json -w '%{http_code}\n' http://127.0.0.1:19053/actuator/beans
  200
  beans named portTakenFailureAnalyzer in its context: 1
    type com.tiffinbox.web.PortTakenFailureAnalyzer · scope singleton
  the demo token in it: 0 · deleted: yes
$ $CURLSET 19053 .harness/bean/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 6 · debug — the trace, still there

A first TiffinBox holds 19054; a second, the README's `--debug` line: exit 1, the banner, **39 frames** — the `BindException`'s
own (its 15 and the 24 the first report folded as common), logged at DEBUG by `LoggingFailureAnalysisReporter` (`Application failed
to start due to an exception`) — the condition report (71 positive matches, 73 negative, 11 unconditional classes on this class
path), and the same Description and Action. DEBUG lines by logger: `SpringApplication` 1, `ConditionEvaluationReportLogger` 1, the
reporter 1. The first one's seven.

`.r-debug.out` · md5 `7bae9b43043ade3fcdf73b534de09f59` · 3 of 3

```
the trace, back: a first TiffinBox holds port 19054 - after/'s jar (.harness/serve), the README's run line:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19054
  listens on: 127.0.0.1:19054
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19054/actuator/health/readiness
  {"status":"UP"} 200
a second, on the same port - the README's --debug line:
$ cd .harness/serve && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19054 --debug
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 39 = 39 · Caused by: 0 · frames folded as common 0
  DEBUG o.s.boot.SpringApplication: Loading source class com.tiffinbox.web.TiffinBoxApp
  WARN s.c.a.AnnotationConfigApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.BeanCreationException …
  DEBUG .s.b.a.l.ConditionEvaluationReportLogger:
  DEBUG o.s.b.d.LoggingFailureAnalysisReporter: Application failed to start due to an exception
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  java.net.BindException: Address already in use
  the condition report: CONDITIONS EVALUATION REPORT 1 · positive matches 71 · negative matches 73 · unconditional classes 11
  Description:
  TiffinBox could not listen on 127.0.0.1:19054: something else already listens there.
  Action:
  Stop the program on that port, or start TiffinBox on another: --tiffinbox.port=<a free port>.
  its standard error: 0 lines · the demo token in its log: 0
the first TiffinBox, after the second exited:
  the process listening on 19054: the one started above: yes
$ $CURLSET 19054 .harness/serve/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
```


## 7 · hang — C (labelled): the failure after the start

No analyzer runs once TiffinBox serves. The README's lines, in the previous tree (`.harness/hb`) and then in after/
(`.harness/ha`), each built and extracted: a copy of the extracted jar and its `lib/` under `target/hang/`, jackson-databind's
`com/fasterxml/jackson/databind/jdk14/JDK14Util*` deleted from the copy (`zip -d`: the copy holds 0 entries, the extracted lib 4),
the copy's thin jar run with `--logging.level.kitchen=debug` on 19055. `JDK14Util` is what Jackson needs to write a record:
`/customers` (a list of `Customer` records) needs it, `/dashboard` does not. **The previous tree** — one catch clause, `catch
(Exception e)`: `curl -m 5` prints `000`, exit 28; `/dashboard` answers 200, so the server lives; the scrape's line for `GET
/customers` says **`status="-1"`**, and after POST /shutdown its log's line says **`GET /customers -> -1`** — `handle()`'s
`finally` ran, logged and timed an answer no client received — and standard error holds one uncaught `Exception in thread ""
java.lang.NoClassDefFoundError: com/fasterxml/jackson/databind/jdk14/JDK14Util`, caused by `ClassNotFoundException`. **after/** —
`catch (Exception | LinkageError e)`: **`{"error":"ClassNotFoundException"} 500`**, curl exit 0, the scrape `status="500"`, the line
`GET /customers -> 500`, 0 uncaught exceptions. **after/'s copy again, at INFO** — Boot's default, the README's run line for the copy
without the kitchen flag, `sbom` exposed for this one run (Actuator's endpoint for a software bill of materials: it writes a record,
so it needs the same class): `/customers` 500; `/actuator/sbom` → `{"error":"NoClassDefFoundError"} 500`; a body sent with a read
(`-X GET -d 'oops, not json'` to health) → `{"status":"UP","groups":["liveness","readiness"]} 200` — since RED C5-S4 #46's fix in the
Actuator lesson's anchor the bridge reads a body only for a write that takes one, so this request no longer reaches the catch (it
answered 500 `JsonParseException` before, logged by its class). After POST /shutdown, the log read as its shape: **`ERROR tiffinbox:
GET /customers failed`**, **`ERROR tiffinbox: an actuator request failed`** — each followed by
`java.lang.NoClassDefFoundError: com/fasterxml/jackson/databind/jdk14/JDK14Util` and its trace, frames counted — and no other bridge
line; the body's words in the log: 0; standard error: 0 uncaught (RED C5-S4 #59). The catch's second branch (any other exception,
logged by its class alone) stays as written: a client's mistakes are 400s before it now.

`.r-hang.out` · md5 `96f2460d0293ce5241201cb5d19356d6` · 3 of 3

```
C (labelled) - the failure after the start: one class jackson-databind needs for a record, deleted from a copy of the
extracted lib by the README's lines - in the previous tree, then in after/; port 19055.
the previous tree, copied to .harness/hb with a config tree, built the README's plain way, extracted:
$ cd .harness/hb && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the previous tree · offline: yes · exit 0
$ cd .harness/hb && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  extracted: exit 0 · its lib/ holds 46 jars
  every catch clause in its handle() (grep -n):
    177: } catch (Exception e) {
$ cd .harness/hb && rm -rf tiffinbox-web/target/hang && mkdir tiffinbox-web/target/hang && cp tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar tiffinbox-web/target/hang/ && cp -R tiffinbox-web/target/extracted/lib tiffinbox-web/target/hang/lib
$ cd .harness/hb && zip -q -d tiffinbox-web/target/hang/lib/jackson-databind-2.22.2.jar 'com/fasterxml/jackson/databind/jdk14/JDK14Util*'
  entries under jdk14/JDK14Util in jackson-databind: the copy's 0 · the extracted lib's 4
$ cd .harness/hb && java -jar tiffinbox-web/target/hang/tiffinbox-web-1.0.0.jar --tiffinbox.port=19055 --logging.level.kitchen=debug
  listens on: 127.0.0.1:19055
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19055/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -m 5 -w ' %{http_code}\n' http://127.0.0.1:19055/customers
   000
  curl exit 28
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19055/dashboard
  200
  the scrape's line for GET /customers: tiffinbox_requests_seconds_count{route="GET /customers",status="-1"} 1
$ harness/shutdown.sh 19055 .harness/hb/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19055 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : GET /customers -> -1
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : GET /dashboard -> 200
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : POST /shutdown -> 200
  its answer lines: 3
  its standard error: uncaught exceptions 1 · stack frames 32 · Caused by: 1
    Exception in thread "" java.lang.NoClassDefFoundError: com/fasterxml/jackson/databind/jdk14/JDK14Util
    Caused by: java.lang.ClassNotFoundException: com.fasterxml.jackson.databind.jdk14.JDK14Util
after/, copied to .harness/ha with a config tree, built the README's plain way, extracted:
$ cd .harness/ha && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built after/ · offline: yes · exit 0
$ cd .harness/ha && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  extracted: exit 0 · its lib/ holds 46 jars
  every catch clause in its handle() (grep -n):
    183: } catch (Exception | LinkageError e) {   // a class the route needs, missing: 500, never a silent client
$ cd .harness/ha && rm -rf tiffinbox-web/target/hang && mkdir tiffinbox-web/target/hang && cp tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar tiffinbox-web/target/hang/ && cp -R tiffinbox-web/target/extracted/lib tiffinbox-web/target/hang/lib
$ cd .harness/ha && zip -q -d tiffinbox-web/target/hang/lib/jackson-databind-2.22.2.jar 'com/fasterxml/jackson/databind/jdk14/JDK14Util*'
  entries under jdk14/JDK14Util in jackson-databind: the copy's 0 · the extracted lib's 4
$ cd .harness/ha && java -jar tiffinbox-web/target/hang/tiffinbox-web-1.0.0.jar --tiffinbox.port=19055 --logging.level.kitchen=debug
  listens on: 127.0.0.1:19055
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19055/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -m 5 -w ' %{http_code}\n' http://127.0.0.1:19055/customers
  {"error":"ClassNotFoundException"} 500
  curl exit 0
$ curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19055/dashboard
  200
  the scrape's line for GET /customers: tiffinbox_requests_seconds_count{route="GET /customers",status="500"} 1
$ harness/shutdown.sh 19055 .harness/ha/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19055 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : GET /customers -> 500
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : GET /dashboard -> 200
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : POST /shutdown -> 200
  its answer lines: 3
  its standard error: uncaught exceptions 0 · stack frames 0 · Caused by: 0
after/'s copy again (.harness/ha), at INFO, Boot's default - the README's run line for the copy, no kitchen flag; it
exposes sbom for this one run (Actuator's endpoint for a software bill of materials: it needs the same class):
$ cd .harness/ha && java -jar tiffinbox-web/target/hang/tiffinbox-web-1.0.0.jar --tiffinbox.port=19055 --management.endpoints.web.exposure.include=health,prometheus,sbom
  listens on: 127.0.0.1:19055
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19055/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -m 5 -w ' %{http_code}\n' http://127.0.0.1:19055/customers
  {"error":"ClassNotFoundException"} 500
  curl exit 0
  the scrape's line for GET /customers: tiffinbox_requests_seconds_count{route="GET /customers",status="500"} 1
the bridge's catch - the README's sbom line; then its line that sends a body to health, a read: the bridge reads a body only
for a write that takes one (the Actuator lesson's fix), so this one never reaches the catch:
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19055/actuator/sbom
  {"error":"NoClassDefFoundError"} 500
$ curl -s -X GET -d 'oops, not json' -w ' %{http_code}\n' http://127.0.0.1:19055/actuator/health
  {"status":"UP","groups":["liveness","readiness"]} 200
$ harness/shutdown.sh 19055 .harness/ha/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 200 · curl exit 0
  exit 0 · listening on 19055 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  its log, read after it exited: APPLICATION FAILED TO START 0 · stack frames 57 = 30 + 2 + 25 + 0 · Caused by: 2 · frames folded as common 55
  ERROR tiffinbox: GET /customers failed
  ERROR tiffinbox: an actuator request failed
  java.lang.NoClassDefFoundError: com/fasterxml/jackson/databind/jdk14/JDK14Util
  Caused by: java.lang.ClassNotFoundException: com.fasterxml.jackson.databind.jdk14.JDK14Util
  java.lang.NoClassDefFoundError: com/fasterxml/jackson/databind/jdk14/JDK14Util
  Caused by: java.lang.ClassNotFoundException: com.fasterxml.jackson.databind.jdk14.JDK14Util
  the body's words in its log: oops 0 · not json 0
  its standard error: uncaught exceptions 0 · stack frames 0 · Caused by: 0
```


## 8 · native — the AOT jar and the binary (S4.14, ⚑12); C, the hints lesson's break

after/ built with the README's two native lines (8 of 8 stages, offline, the token 0 times in the binary). What Spring's AOT step
wrote for the binary, through a filter: the resource `META-INF/spring.factories`, and a reflection entry for
`com.tiffinbox.web.PortTakenFailureAnalyzer` with `allDeclaredConstructors` — the binary reads the file at run time and builds the
analyzer from it. The AOT jar (the README's AOT line) and the binary (the README's line), each started twice on 19056: the second
exits 1 with the banner, 0 frames, the sentence — Spring's WARN now from `GenericApplicationContext`, the context AOT uses — and the
first serves its seven. Then **C (labelled)**: a copy of after/ with the route annotation's `@Reflective` deleted — the hints
lesson's `breaks` C — built with the same two lines; the README's binary line with the kitchen flag on 19057: `/kitchen` →
**`{"error":"MissingReflectionRegistrationError"} 500`** (that lesson's client got no answer), the scrape `status="500"`; POST
/shutdown → `500` too (`shutdown()` is a route: the binary cannot invoke it), the binary still running, so SIGTERM (`kill $pid`) →
exit 143; its log's lines `GET /kitchen -> 500`, `POST /shutdown -> 500`, then its shape — `ERROR tiffinbox: GET /kitchen failed`,
`ERROR tiffinbox: POST /shutdown failed`, GraalVM's `MissingReflectionRegistrationError`, frames counted; 0 uncaught exceptions.

`.r-native.out` · md5 `113cfa86985dae96661dfb4f5e6d04a6` · 3 of 3

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
what Spring's AOT step wrote for the binary - .harness/nat's reachability-metadata.json (process-aot), through a filter:
  the resource META-INF/spring.factories: yes
  reflection entries for com.tiffinbox.web.PortTakenFailureAnalyzer: 1 · allDeclaredConstructors
the AOT jar, started twice on one port - the README's AOT line, port 19056:
$ cd .harness/nat && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19056
  listens on: 127.0.0.1:19056
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19056/actuator/health/readiness
  {"status":"UP"} 200
$ cd .harness/nat && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19056
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0
  WARN o.s.c.support.GenericApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.BeanCreationException …
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  Description:
  TiffinBox could not listen on 127.0.0.1:19056: something else already listens there.
  Action:
  Stop the program on that port, or start TiffinBox on another: --tiffinbox.port=<a free port>.
  its standard error: 0 lines · the demo token in its log: 0
$ $CURLSET 19056 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
the binary, started twice on one port - the README's line:
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19056
  listens on: 127.0.0.1:19056
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19056/actuator/health/readiness
  {"status":"UP"} 200
$ cd .harness/nat && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19056
  exit 1
  its log, read after it exited: APPLICATION FAILED TO START 1 · stack frames 0 · Caused by: 0 · frames folded as common 0
  WARN o.s.c.support.GenericApplicationContext: Exception encountered during context initialization - cancelling refresh attempt: org.springframework.beans.factory.BeanCreationException …
  ERROR o.s.b.d.LoggingFailureAnalysisReporter:
  Description:
  TiffinBox could not listen on 127.0.0.1:19056: something else already listens there.
  Action:
  Stop the program on that port, or start TiffinBox on another: --tiffinbox.port=<a free port>.
  its standard error: 0 lines · the demo token in its log: 0
$ $CURLSET 19056 .harness/nat/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its log: the demo token 0 times · X-Shutdown-Token 0 times
C (labelled) - the hints lesson's break: a copy of after/ (.harness/natc) without the route annotation's @Reflective, built
natively; the README's line with the kitchen flag, port 19057:
$ sed -i '' '/^@Reflective$/d' .harness/natc/tiffinbox-web/src/main/java/com/tiffinbox/web/Route.java
$ diff after/tiffinbox-web/src/main/java/com/tiffinbox/web/Route.java .harness/natc/tiffinbox-web/src/main/java/com/tiffinbox/web/Route.java
  18d17
  < @Reflective
$ cd .harness/natc && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean install
  built .harness/natc (both modules, into $M2) · offline: yes · exit 0
$ cd .harness/natc && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -pl tiffinbox-web native:compile-no-fork
  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 20 minutes · offline: yes
  the demo token in its bytes: 0
$ cd .harness/natc && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19057 --logging.level.kitchen=debug
  listens on: 127.0.0.1:19057
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19057/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -m 5 -w ' %{http_code}\n' http://127.0.0.1:19057/kitchen
  {"error":"MissingReflectionRegistrationError"} 500
  curl exit 0
  the scrape's line for GET /kitchen: tiffinbox_requests_seconds_count{route="GET /kitchen",status="500"} 1
$ harness/shutdown.sh 19057 .harness/natc/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 500 · curl exit 0
  still running: yes
$ kill $pid    # SIGTERM, to the binary this script started
  exit 143 · listening on 19057 now: 0
  its log: the demo token 0 times · X-Shutdown-Token 0 times
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : GET /kitchen -> 500
  <time> DEBUG <pid> --- [    virtual-<n>] tiffinbox                                : POST /shutdown -> 500
  its answer lines: 2
  its log, read after it exited: APPLICATION FAILED TO START 0 · stack frames 26 = 13 + 13 · Caused by: 0 · frames folded as common 0
  WARN i.m.c.i.binder.jvm.JvmGcMetrics: GC notifications will not be available because no GarbageCollectorMXBean of the JVM provides any. GCs=[young generation scavenger, complete scavenger]
  ERROR tiffinbox: GET /kitchen failed
  ERROR tiffinbox: POST /shutdown failed
  org.graalvm.nativeimage.MissingReflectionRegistrationError: Cannot reflectively invoke method 'java.lang.Object com.tiffinbox.web.TiffinBoxServer.kitchen()'. To allow this operation, add the following to the 'reflection' section of 'reachability-metadata.json' and rebuild the native image:
  org.graalvm.nativeimage.MissingReflectionRegistrationError: Cannot reflectively invoke method 'java.lang.Object com.tiffinbox.web.TiffinBoxServer.shutdown()'. To allow this operation, add the following to the 'reflection' section of 'reachability-metadata.json' and rebuild the native image:
  its standard error: uncaught exceptions 0 · stack frames 0 · Caused by: 0
```


## 9 · exercise — the exercise, run as written

`.r-exercise.out` · md5 `dd4e408e3f9bb389887f8d553cd2d7d1` · 3 of 3

```
exercise/README.md's commands, run exactly as written from this folder - 7 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine/probe/cycle && rsync -a --exclude target after/ .harness/mine/after/ && cp harness/probe/cycle/Cook.java harness/probe/cycle/Rail.java harness/probe/cycle/Tally.java .harness/mine/probe/cycle/
  $ mvn -o -B -q -f .harness/mine/after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package
  $ (cd .harness/mine/after && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted > /dev/null)
  $ mkdir -p .harness/mine/after/secrets/tiffinbox && chmod 700 .harness/mine/after/secrets .harness/mine/after/secrets/tiffinbox
  $ (umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/after/secrets/tiffinbox/shutdown-token)
  exit 0 · printed: 0 line(s)
the solution's line (exercise/solution/SOLUTION.md), run exactly as written, from this folder:
$ cp exercise/solution/probe/cycle/*.java .harness/mine/probe/cycle/ && javac -d .harness/mine/hc -cp ".harness/mine/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/mine/after/tiffinbox-web/target/extracted/lib/*" .harness/mine/probe/cycle/*.java && { (cd .harness/mine/after && exec java -cp "tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*:../hc" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19059 --spring.main.sources=probe.cycle.Cook,probe.cycle.Rail,probe.cycle.Shift,probe.cycle.Tally > ../run.log 2>&1) & } && for i in $(seq 240); do r=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:19059/actuator/health/readiness); [ "$r" = 200 ] && break; sleep 0.25; done; [ "$r" = 200 ] && w=started || w="never ready"; s=$(harness/seven.sh 19059 .harness/mine/after/secrets/tiffinbox/shutdown-token); wait; echo "Cook and Rail $w · $(sed -n 's/^harness: //p' .harness/mine/run.log) · the seven $s · APPLICATION FAILED TO START $(grep -c 'APPLICATION FAILED TO START' .harness/mine/run.log)"
Cook and Rail started · cook depends on [shift] and counts 12 slips · rail depends on [shift] and counts 3 hands · the seven 115c36bac276128e245ca57df11c2891 · APPLICATION FAILED TO START 0
  exit 0 · listening on 19059 now: 0
  its log (.harness/mine/run.log): its own token 0 times · X-Shutdown-Token 0 times
```


## Exercise

**Your turn:** break the cycle Boot drew without the switch: give Cook and Rail the third object both of them wanted.
`exercise/README.md` has the commands; done is the line `Cook and Rail started · cook depends on [shift] and counts 12 slips · rail
depends on [shift] and counts 3 hands · the seven 115c36bac276128e245ca57df11c2891 · APPLICATION FAILED TO START 0` — the half in the
middle is the harness's `Tally`, so deleting the setters (`cook depends on []`) or flipping the switch (`[rail]`, `[cook]`) does not
pass; the measured answer, run exactly as written in a clean `env -i` shell, is `exercise/solution/SOLUTION.md` (with the cured
`Cook`, `Rail` and `Shift` beside it, and those two shortcuts measured).

## RE-MEASURE — the brief's items this unit settles

| Item (brief) | The probes | This unit (receipts, 2026-10-07) |
|---|---|---|
| Port taken, no analyzer (READ FIRST 12) | 40 frames, 0 banners; 56 / 62 lines | **40 frames, 1 `Caused by:`, 24 folded as common, 0 banners** (`taken`, `analysis` B and C); no line total |
| Boot's analyzers on this class path | 20 (21 with Actuator); `spring-boot-web-server` 3 (10-07 notes) | **Boot's 21** (18 + 2 + 1, parsed) and TiffinBox's 1; **`spring-boot-web-server` names 2** (`PortInUseFailureAnalyzer`, `MissingWebServerFactoryBeanFailureAnalyzer`), `spring-boot-tomcat` 1 — the 10-07 notes' 3 does not hold for 4.1.1 |
| The `@Component` analyzer is ignored (10-07 `f2`) | 62 lines, 40 frames, no banner | **40 frames, no banner — and the bean is in the context** (`/actuator/beans`: 1) |
| `--debug` brings the trace back (10-07) | 39 frames, 222 lines | **39 frames** (the `BindException`'s own: 15 + 24), the condition report (71 / 73 / 11), the same analysis; no line total |
| Tomcat's own port analyzer (10-07 `w1`) | 0 frames, `Web server failed to start. Port … was already in use.` | **not re-run** (S4.3: Tomcat binds every interface; only unit 21's `ways` may start it): its analyzer is shown by its jar (`analyzers`) |
| A malformed flag value (10-07, `spring.jmx.enabled`) | `Invalid value …`, `BindFailureAnalyzer` | **TiffinBox's own key instead**, `--tiffinbox.port=nineteen`: 0 frames, `Failed to bind properties under 'tiffinbox.port' to java.lang.Integer`, `Value: "nineteen"` |
| P34 under Boot (READ FIRST 13) | exit 1, the cycle drawn; the switch → the seven | **the same, and plain Spring re-measured**: `allowCircularReferences: true`, started (`Plain`); Boot's metadata: default `false`; Boot's run never listened |
| The hang on the JVM (READ FIRST 14) | old catch: curl exit 28; new: `{"error":"ClassNotFoundException"} 500` | **the same, plus what the server recorded**: the old catch's line `GET /customers -> -1` and scrape `status="-1"`; the new catch's `500` in both; one uncaught `NoClassDefFoundError` against 0 |
| The analysis in the AOT jar and the binary (**re-measure**, unit 26) | not measured | **present in both**: 0 frames, the sentence; Spring's AOT metadata registers `META-INF/spring.factories` and the analyzer's constructors |
| The catch in the binary | not measured (the hints lesson's C hung) | **500**, `MissingReflectionRegistrationError` (`native` C); POST /shutdown 500 too; SIGTERM → 143 |
| The exercise's end state (**re-measure**) | "the harness pair starts, `115c36ba…`, 0 analysis lines" | **the same, plus what each bean got**: `cook depends on [shift] and counts 12 slips · rail depends on [shift] and counts 3 hands`, from the solution run as written (`exercise`) |

## Found on the way

- **A malformed value's analysis prints the value.** `BindFailureAnalyzer` writes `Value: "nineteen"` and its origin. For a port, a
  help; for a secret, a leak — the secrets lesson moved the token's length rule into a yes-or-no method for that reason. TiffinBox's
  own analyzer reads two keys by name and prints nothing else.
- **The cycle stops the start before TiffinBox listens.** The refresh failed on the harness's two beans before TiffinBox's server
  opened: no port held after the exit, no `TiffinBox listening` line in the log (`cycle`). Which bean the container created first is
  not measured.
- **Boot's one sentence in a trace is a hint:** `Error starting ApplicationContext. To display the condition evaluation report
  re-run your application with 'debug' enabled.` — logged by `ConditionEvaluationReportLogger` at INFO on every failed start here,
  analysis or not.
- **The AOT jar and the binary log the WARN from `GenericApplicationContext`**, the JVM from `AnnotationConfigApplicationContext`; the
  analysis is the same text.
- **A `BindException` does not say whose bind it was** (RED C5-S4 #58). Its message names the OS's reason, not the address or the
  caller; the analyzer reads the caller off the stack. `TiffinBoxServer.main` is the bottom frame of every failure of a start (it is
  the main class), so a check for the class alone still claimed another bean's bind — measured before the guard settled on
  `TiffinBoxServer.start`. The same check works in the AOT jar and the binary (GraalVM keeps the frames).
- **At INFO, a 500 used to leave no trace** (RED C5-S4 #59): the catch answered and timed it, and only the DEBUG answer line
  said anything. Now the error is logged at ERROR, with its trace.
- **Without the route hint, the binary cannot stop itself:** POST /shutdown is a route like the others, so it answers 500 and the
  process keeps running. Before this unit's catch, the same request got no answer at all (the hints lesson).

## For unit 27 — Section 5, and RED

**Unit 27 starts from `../c5-unit26/after`** (= `../c5-tiffinbox` when this unit was made; the anchor has moved on since: `../c5-tiffinbox` is unit 27's `after/` (`diff -rq -x target ../c5-tiffinbox ../c5-unit27/after` is empty)). What you can rely on — measured
here unless a line says otherwise:
- **A start that fails on TiffinBox's own taken port prints two sentences, not a trace** — on the jar, the AOT jar and the binary. A
  capture that counts frames on a port failure counts 0 now; `--debug` brings 39 back. Any other `BindException` keeps its trace.
- **`handle()`'s catch is `catch (Exception | LinkageError e)`, and it logs the error at ERROR**; an `Error` that is not a
  `LinkageError` still leaves `handle()`. A capture that counts ERROR lines, or reads a log at INFO, sees one per failed route.
- **The bridge's catch logs at ERROR too** (a `LinkageError` with its trace, an exception by its class); BLUE part A's fix of the
  bridge's request handling lands after this unit, in the Actuator lesson's anchor, and cascades through it.
- **`spring.factories` is new in `tiffinbox-web`**: one key. A second analyzer, or any other `spring.factories` key, is one more line
  there; `TiffinBoxApp.java` is still untouched (⚑11) — **RED S2 #8 stays DEFERRED**, to the next unit that edits it.
- **The brief's bare-port hazard stands** (§SECTION 5 (parked)): a bare number binds 18425 without a word; every capture here passed
  `--tiffinbox.port=`.
- **The seed:** `.m2-demo` = `../c5-unit24/.m2-demo` less `com/tiffinbox/` (5,418 files; Boot's web-server and Tomcat jars in it).
- **Ports:** 26 used 19050-19059; nothing of this unit listens after it ends (Interrupted). Unit 27 owns 19060-19069.

**For RED:** the analyzer's guard (RED C5-S4 #58, settled: D and E); whether the native C capture (two native builds per run) earns
its time; and whether Section 4's recap line about restarts should name DevTools by name.
