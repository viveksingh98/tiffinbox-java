# c5-unit25 — DevTools, Restart and Live Reload

Course 5 · Spring Boot · Section 4 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1, GraalVM CE 25.3.4.1**
(native-image 25.0.4.1), 2026-10-07. DevTools — Spring Boot's developer tools — restarts an application when a class file changes:
a second class loader for what sits in folders, a new context, the same JVM. This unit adds DevTools to **copies** of TiffinBox,
never to TiffinBox itself, and measures what it adds, which loader defines what, a restart against a cold start, an object that
crosses a restart (Course 2's "identity is name plus loader", on TiffinBox's own class), what restarts and what does not, Live
Reload (deprecated), the guards that keep DevTools out of what ships, the one line the native binary needs, and the exit code a
DevTools run ends with.

**The anchor does not change (brief ⚑7).** `anchor` in this folder is a link to `../c5-unit24/after` — TiffinBox as the logging
lesson left it. Every capture copies it under `.harness/` and changes the copy: one line in the web module's POM,

```
    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-devtools</artifactId><optional>true</optional></dependency>
```

and, for the native binary, one `<exclusion>` of `org.springframework.boot:spring-boot-devtools` in the native plugin. Nothing
under `anchor/` is built or written. This unit was first built on `../c5-unit21/after` (the Actuator lesson's tree) and re-pointed
here before RED, as the brief planned: the link changed, then the tree-dependent expectations at the top of `receipts.sh`'s checks,
and every capture was made again (see "The re-point", at the end).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 11 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) It ran for 2,812 s under `./receipts.sh` (/bin/bash 3.2.57) and 2,949 s under `bash receipts.sh` (Homebrew bash 5.3.9) — the two runs of record of this revision, 2026-10-08 (RED C5-S4 part B's fixes: the variable clean-up, and the anchor's retired logging files), each EXIT 0 with all eleven captures = published, the hashes unchanged — beside units 24 and 26's receipts and their native builds (one-minute load averages 7-8 as the 3.2 run's timed captures began, 88-208 for the 5.3 run's); its six native builds, 184-443 s each, are over half of it. The first revision's runs of record on the logging lesson's tree (2026-10-07) took 2,673 s (3.2) and 2,563 s (5.3); on the Actuator lesson's tree, 2,129 s and 2,305 s.
It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS` line first, so you can see which one moved).
Published hashes: added `aa2e2929f1165c758fbbbf8d6352ef4a` · loaders `31932a8561380caf709ac37530b90633` · restart `a5b72f622c926ca6facfe5845f3a79fa` · timing `0fc985516b6985f73c043bf65580c1c2` · identity `cdf54a312467ecbf166f7de80d000ab5` · which `02b1b496da15b94e587bd66b7048824d` · livereload `245eaab2d150323fc61850b42a312824` · ship `16eb4a4674231f5cf8aed0a8143bbfd5` · exits `96656dea659642d4ef7f9456e66adad2` · native `e2a620fd509723b89411d0551bd8d10e` · exercise `9b48c795e9543274eb9d10c4463049c1`.

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else. It refuses a variable that does not name a
`bin/native-image`, and one whose `native-image --version` is not `native-image 25.0.4.1 …` / `GraalVM CE 25.3.4.1+1.1` — another
GraalVM prints other lines, so the captures could not match. The GraalVM's folder is never printed: every capture masks it as
`$GRAALVM_HOME`. Only `native` needs it.

**Without a GraalVM** (`GRAALVM_HOME` not set): `receipts.sh` still runs. It fills `.m2-demo` (its first build), makes every
capture but `native` — `added`, `loaders`, `restart`, `timing`, `identity`, `which`, `livereload`, `ship`, `exits` — and the
exercise's, each checked against `receipts.md5`, then stops where the native build would start, naming this section (exit 1).

## The repository, and what was downloaded

Every build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen): `../c5-unit21/.m2-demo` copied **less
`com/tiffinbox/`** (every native build installs its own two modules) — 5,418 files, DevTools 4.1.1 and Micrometer's Prometheus
registry among them (Section 4's seed, `spring-boot/_research/m2-seed-s4/`, brought both). It is file for file
`../c5-unit24/.m2-demo` less `com/tiffinbox/`, so the re-point needed no new artifact. **Nothing was downloaded** for this unit: every
build said `offline: yes`, the native-profile ones included.

**One way out is not Maven's.** GraalVM's native plugin reads its metadata repository (a zip,
`graalvm-reachability-metadata-1.1.8-repository.zip`, 3,362,517 bytes, from Maven Central) from the Maven repository — and when the
zip is not there it does not fail, even under `-o`: it downloads one from GitHub. So (1) the first build is the README's native
install, on a DevTools copy with the native plugin's exclusion — it needs nearly every artifact any capture's Maven line needs, the
zip and DevTools included — and a second build on the same copy (the README's class-path build) fetches the one plugin only it
needs (the dependency plugin), so that every build inside a capture says `offline: yes`; (2) a native-profile build while the zip is
not in `.m2-demo` goes to Maven Central at once, never offline first; (3) after the first build the script checks that Boot's parent
POM, DevTools 4.1.1, Boot's plugin, the native plugin 1.1.8 and the zip are in `$M2`; (4) every build's log is searched for the
plugin's own download line — found, the build's line says `offline: no` and the run stops.

**This revision (2026-10-08) was not cloned here:** its sealed fresh-clone run was unit 26's, which builds the same anchor as its previous tree (`../c5-unit26/README.md`); the eleven hashes did not move. **From a clone, sealed (2026-10-07, on the logging lesson's tree).** The repository was cloned (its HEAD, `8ab95db`, with this unit's files put in as the commit adds them, less this README, which records the runs) into an empty folder — no `.m2-demo` here, in unit 24's or in unit 21's, no seed — and `receipts.sh` run under `env -i`: a `HOME` whose `.mavenrc` points Maven's `user.home` there (Java reads `user.home` from the account, not from `$HOME`) and every Java proxy property at a port that refuses, and whose Maven settings send every repository to a `file://` copy of Central's files made from `.m2-demo` (4,060 files: its own installs, `_remote.repositories`, `*.lastUpdated`, `resolver-status.properties` and `.DS_Store` left out); `http_proxy`, `https_proxy`, their capitals and `ALL_PROXY` at the same refusing port. **Without `GRAALVM_HOME`, `bash receipts.sh` (bash 5.3): exit 1 after 869 s** — the first build said `offline: no` (GraalVM's metadata repository was not in the empty `.m2-demo`) and took 510 files from the copy, the second said `offline: no` too (the dependency plugin) and took 171; 0 transfers from anywhere else, and no build inside a capture downloaded anything; `.m2-demo` ended with 1,861 files; the ten captures that need no GraalVM = published, the exercise's included; then the stop the script announces. **With `GRAALVM_HOME`, `./receipts.sh` (/bin/bash 3.2): exit 0 after 1,433 s** — all eleven captures = published, every spoken number asserted, 0 raw demo tokens; again 510 and 171 files from the copy, 0 from anywhere else, `.m2-demo` 1,861 files at the end: the native builds needed nothing more. `github` appears 0 times in either run's log (in the build logs only as the copy's own `com/github/…` paths and native-image's documentation link). A first try put the anchor's new link in the wrong place (inside the old link's folder, so the clone still pointed at `../c5-unit21/after`): its first capture, `added`, DIFFERED from `receipts.md5` and the run stopped — the published hashes pin the tree. On the Actuator lesson's tree the same two runs took 706 s and 2,023 s (490 and 171 files from the copy, `.m2-demo` 1,808 at the end), and an unsealed one — a `HOME` alone, which Maven does not read — filled `.m2-demo` from Maven Central itself, 661 files over HTTPS: the path a viewer's first run takes.

## The demo token — fake, and never printed

TiffinBox does not start without its shutdown token. Every run starts in a folder under `.harness/` holding a config tree,
`secrets/tiffinbox/shutdown-token` (`-rw-------`, folders `drwx------`), with a 26-character demo token that is fake and looks it;
`receipts.sh` writes it when it runs. The token never reaches a command line: the seven requests and `harness/clock.py` read it from
the file. Every capture is masked — the token becomes `[masked: the 26-character token]` — and `receipts.sh` counts the raw token in
each run's own output **before** masking (`.harness/raw-*`: 0 in all 33 capture runs), then in every capture, this README, the
exercise, the harness, `receipts.md5`, and the **bytes of both binaries** each run builds: 0 each. The builder counts it again in the
script, the deck and the prompter: 0. env's answer (`added`) masks every value; it is read, then deleted — it lists the names of your
environment's variables — and the exit trap deletes it again. The exercise makes a random token of its own, which it never prints.

## The folders, the variables and the ports

- `anchor/` — the link to the anchor (read only). `../c5-unit20/after` — the tree both Section 4 probes measured, read once by
  `added`, for the class-path count they disagreed on (RE-MEASURE 5).
- `.harness/fill/` — the two builds before the captures (they fill `.m2-demo`); its classes and class path are what the harness
  compiles against. `.harness/hc/` — `Loaders` and `Witness`; `.harness/hold/` and `.harness/holder.jar` — `Holder`, in a folder and in a
  jar; `.harness/me/` — `MainEnds`.
- `added`: `.harness/base/` (the anchor) and `.harness/dev/` (the anchor and DevTools' line) — `loaders`, `restart`, `timing`,
  `identity`, `livereload` and `exits` run `.harness/dev/`; `.harness/probes/` (the probes' tree and the same line). `which`:
  `.harness/which/`. `ship`: `.harness/ship-req/`, `.harness/ship-forced/`, `.harness/ship-opt/`, `.harness/aot-base/`,
  `.harness/aot-dev/`. `native`: `.harness/nat-b/` (no exclusion), `.harness/nat-a/` (the exclusion). The exercise: `.harness/mine/`,
  `.harness/mine-hc/`.
- On screen: `$CURLSET` = `../c5-unit11/curlset.sh`, the comparison set since the secrets lesson; `$M2` = this unit's `.m2-demo`;
  `$GRAALVM_HOME` = the GraalVM; `$pid` = the process the script started (jcmd's target). Every other command is printed whole.
- Ports (brief ⚑10, 19040-19049, checked free with `lsof` before anything is wiped; 18425, 8080 and 35729 too): `added` 19040 ·
  `loaders` 19041 · `restart` 19042 · `timing` 19043 · `identity` 19044 · `which` 19045 · `livereload` 19046, and Live Reload's own
  server on **19049** (one run; never its default 35729) · `ship` 19047 · `exits` 19048 · `native` 19047 · the exercise 19045.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM and the token** (`gsub()`, the patterns escaped as literals), in every line of every capture: the demo token
   → `[masked: the 26-character token]`; the GraalVM's folder → `$GRAALVM_HOME`; this folder's absolute path → `…` (also
   URL-encoded); the folder above it → `…/..`; the home folder → `~`; the user name → `<user>`. A last check fails if any capture
   still holds `/Users/`, `/private/`, `/home/` or `/var/folders/`, the GraalVM's folder, a unit number, or a class loader's address.
2. **A class loader's address** (` @45ff1ded` in the JVM's `ClassCastException` message) → ` @<hash>` (`identity`, the exercise); a
   lambda's or a proxy's generated name → `$$Lambda`, `jdk.proxy<n>.$Proxy<n>` (`loaders`). Both move from run to run.
3. **Boot's log** is read, never printed whole: a line is printed from its message on (time, level, pid, thread and logger cut);
   the thread a line ran on is printed by name where it matters (`restartedMain`, `File Watcher`). A start that fails (the binary
   without the exclusion) prints the exception the JVM printed for the main thread and every `Caused by:` line, the lines between
   them counted.
4. **The condition report** (`livereload`, `ship`): its header and the block named, whole, every other line counted.
5. **jcmd** (`loaders`, `exits`): `VM.classloaders show-classes=true` is read for the loader tree, the classes the restart loader
   defined (**sorted by name**: jcmd lists them in the order they were defined, and on the logging lesson's tree that order moved
   between runs — two of ActuatorRoutes' lambdas are made by the first request to an endpoint, here a readiness poll that can arrive
   mid-start, and KitchenMetrics' two when Micrometer binds it), TiffinBox's classes in the application loader and counts of the rest
   — never its first line (the pid) and never its length (it moves); `Thread.print` for the threads named `main` and `DestroyJavaVM`,
   counted, and the names of the Java threads that are not daemons — never a stack, a thread number or a pid.
6. **env's answer** (`added`): the property sources' names in order (the config tree's and `application.yaml`'s by label: their names
   hold absolute paths), the source `devtools`' keys and how many of its values are not `******` — never a value, and never another
   source's keys (environment variables, system properties).
7. **Maven's and native-image's logs** are read, never printed whole: each build's `offline`/`exit` line; native-image's exit, Maven's
   result, the stages it printed against the count it announces, its duration against a bound (1 minute or more, under 20 minutes),
   how many of native-image's class-path entries (the plugin's `Executing:` line) are DevTools' jar; a binary's bytes are searched for
   the token and for names under `org.springframework.boot.devtools` (counted).
8. **No duration is captured**: `timing` prints the cold start's median against a floor and the restart's and noticing's medians as
   ratios; native builds against a bound; the seconds go to the terminal (below).
9. **Hygiene:** `receipts.sh` unsets every `TIFFINBOX_*`, `SPRING_*`, `MANAGEMENT_*`, `SERVER_*` and `LOGGING_*` variable, `DEBUG`,
   `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`, `_JAVA_OPTIONS`, `MAVEN_OPTS`, `MAVEN_ARGS` and `NATIVE_IMAGE_OPTIONS` before it runs anything — the list is an extended regular
   expression (`sed -E`: `/usr/bin/sed`'s basic one has no alternation, and the `\|` this script once used removed nothing — RED
   C5-S4 #63), and the script plants a canary under every one of those names first and stops if one survives;
   it puts `127.0.0.1` and `localhost` first in `no_proxy` and `NO_PROXY` (every request it makes goes to `127.0.0.1`; an `http_proxy` of
   yours would otherwise receive curl's requests); it refuses to run twice at once in this folder (`.r-lock`) or with a `secrets/` in
   this folder. **S4.16:** a last check greps this script, this README, the exercise's files and every capture for an exposure list
   with a star: none (the one flag passed exposes `health,env`). **S4.3:** Live Reload is switched on in one run, on 19049, and a
   check fails if the script names its default port as a flag.
10. **DevTools' timing is polled, never slept.** A file is touched only once readiness answers 200 — measured while writing this
   unit: touched at TiffinBox's first answer (which comes mid-refresh, before DevTools' watcher has taken its first look at the folders),
   the change was missed in 7 of 11 runs. Every wait for a restart is a bounded poll of the log. Before every POST /shutdown of a
   DevTools run, jcmd confirms the first `main` thread has gone (`settled`): DevTools ends it once the restarted context is up, and a stop
   that raced it could change the exit code (the probes saw one 0 in 14 runs; this unit never did).

**Interrupted.** `receipts.sh`'s exit trap stops the process it started in the background (a TiffinBox JVM: DevTools' restarts happen inside it, and Live Reload's server is one of its threads), if one still runs, then `sweep()`s this run's process group for anything of this run — a TiffinBox JVM (a jar, a class-path run), a binary, native-image's driver or its builder JVM (`java @…/vminvocation.args`), the clock, the JVM-rule harness — TERM, then KILL after 5 s; then it deletes env's answer if a run left one, and, after an interrupt only, the capture runs left unfinished (`.r-NAME.1-3`; after a failed check they stay, for the diff the message names); then it drops the lock. Maven, native-image, javap, jcmd and `harness/clock.py` run in the foreground: Ctrl-C reaches them directly. Every command in the trap is guarded, so `set -e` cannot end it early. **Tested 2026-10-07 on the logging lesson's tree, twice** (as it was twice on the Actuator lesson's), with `receipts.sh` as a job of its own process group (job control on, as a terminal's foreground job is) and `SIGINT` sent to the whole group: **(1) while Live Reload listened** — 282 s in, during `livereload`'s run with it on (in the group then: the DevTools JVM with Live Reload's flag, two shells and a `sleep`; 19049 listened on) — **exit 130**; 5 s later 0 processes in the group, and anywhere 0 java, native-image, python3 or bash processes working in this folder; 18425, 8080, 35729 and 19040-19049 free, 19049 included; `.r-lock` gone; no unfinished capture file and no env answer left; **(2) during the native build** — 732 s in, 20 s after native-image's builder JVM appeared (in the group then: two shells, Maven's JVM, the native-image driver and its builder) — **exit 130**; the same: nothing left, every port free, the lock gone. Both times the captures made before the interrupt (six, then nine) still equalled `receipts.md5`. A first try at (1) came a moment late — 497 s in, on a loaded Mac, between two of `livereload`'s runs — and ended the same way: exit 130, nothing left.

## 1 · added — DevTools in a copy

The anchor copied twice — as it is, and with DevTools' line, inserted by the `perl` shown (`diff`: one line added). The anchor's copy
built the README's plain way, the DevTools copy the way the README builds the class path Maven lists (the Compose lesson's
`package dependency:build-classpath`). Their jars hold the same 46 jars, and the copy's holds **no entry that names devtools**: an
optional dependency stays out of the jar. The class path Maven lists for the copy's web module: 54 entries, all jars, DevTools'
among them, tiffinbox-core as the reactor's jar; the classes folder the README's `java -cp` line puts in front is not in the file. The
tree both probes measured, with the same line: **37 entries, all jars** (RE-MEASURE 5, below). Then the README's class-path run,
without the profile `dev` (it is Docker's), with the README's flag that exposes env (the Actuator lesson's): DevTools' log line,
TiffinBox's own lines on the thread `restartedMain` — none on `main` — and env's property sources: `devtools` sits after
`application.yaml`, with **seven** keys, every one for a web layer TiffinBox does not have (error pages, templates, static resources:
Course 6) or for Compose's readiness wait.

`.r-added.out` · md5 `aa2e2929f1165c758fbbbf8d6352ef4a` · 3 of 3

```
the anchor as the logging lesson left it, copied twice: .harness/base as it is, .harness/dev with one line more in the web
module's POM - DevTools, optional. The copy built as the README builds the class path Maven lists (the Compose lesson's), the
anchor's copy the README's plain way - both offline:
$ perl -0pi -e 's|\n  </dependencies>|\n    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-devtools</artifactId><optional>true</optional></dependency>\n  </dependencies>|' .harness/dev/tiffinbox-web/pom.xml
  lines added: 1
$ diff .harness/base/tiffinbox-web/pom.xml .harness/dev/tiffinbox-web/pom.xml
  61a62
  >     <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-devtools</artifactId><optional>true</optional></dependency>
$ cd .harness/base && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the anchor's copy · offline: yes · exit 0
$ cd .harness/dev && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt
  built the copy · offline: yes · exit 0
the two executable jars:
  jars under BOOT-INF/lib: 46 and 46 · the same names: yes
  entries of its jar that name devtools: 0
the class path Maven lists for the copy's web module - the classes folder the README's java -cp line puts in front is not in it:
  target/classpath.txt: 54 entries · jars 54 · spring-boot-devtools-4.1.1.jar among them: 1 · tiffinbox-core as: tiffinbox-core/target/tiffinbox-core-1.0.0.jar
the same line in the tree both Section 4 probes measured (the hints lesson's - before Actuator), copied to .harness/probes:
$ perl -0pi -e 's|\n  </dependencies>|\n    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-devtools</artifactId><optional>true</optional></dependency>\n  </dependencies>|' .harness/probes/tiffinbox-web/pom.xml
  lines added: 1
$ cd .harness/probes && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt
  built the probes' tree, with the same line · offline: yes · exit 0
  target/classpath.txt: 37 entries · jars 37 · spring-boot-devtools-4.1.1.jar among them: 1 · tiffinbox-core as: tiffinbox-core/target/tiffinbox-core-1.0.0.jar
the copy's class-path run - the README's line without the profile dev - with the README's flag that exposes env (the Actuator
lesson's), port 19040:
$ cd .harness/dev && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19040 --management.endpoints.web.exposure.include=health,env
  listens on: 127.0.0.1:19040
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19040/actuator/health/readiness
  {"status":"UP"} 200
  DevTools' line in Boot's log: Devtools property defaults active! Set 'spring.devtools.add-properties' to 'false' to disable
  the thread TiffinBox's own lines ran on: restartedMain · lines on a thread named main: 0
$ curl -s -o .harness/dev/env.json http://127.0.0.1:19040/actuator/env
  env's property sources, in order (the config tree's and application.yaml's by label): commandLineArgs · systemProperties · systemEnvironment · the config tree · application.yaml · devtools · applicationInfo
  the source devtools: 7 keys · values that are not ******: 0 - its keys:
    spring.docker.compose.readiness.wait
    spring.template.provider.cache
    spring.web.error.include-binding-errors
    spring.web.error.include-message
    spring.web.error.include-stacktrace
    spring.web.resources.cache.period
    spring.web.resources.chain.cache
$ $CURLSET 19040 .harness/dev/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 1 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```


## 2 · loaders — two class loaders

The same run (no env flag), asked by **jcmd** — the JDK's tool that asks a running JVM — once readiness answered 200:
`VM.classloaders show-classes=true`. Four loaders: bootstrap, platform, the application's (`"app"`, every jar on the class path) and
DevTools' **RestartClassLoader** under it, which defined 14 classes (listed by name) — every class of TiffinBox's web module
(ActuatorRoutes, KitchenHealthIndicator, KitchenMetrics, Route, TiffinBoxApp, TiffinBoxServer), the lambdas of ActuatorRoutes,
KitchenMetrics and TiffinBoxServer, and one proxy class the JDK generated. The
application loader defined TiffinBoxServer and TiffinBoxApp too — the first `main` loaded both before DevTools restarted it on
`restartedMain` — every tiffinbox-core class that had loaded by then (10), and DevTools' own classes; RestartClassLoader none
of either.

`.r-loaders.out` · md5 `31932a8561380caf709ac37530b90633` · 3 of 3

```
the copy's class-path run again, port 19041; once readiness answers 200, jcmd - the JDK's tool that asks a running JVM - lists
its class loaders and the classes each one defined:
$ cd .harness/dev && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19041
  listens on: 127.0.0.1:19041
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19041/actuator/health/readiness
  {"status":"UP"} 200
$ jcmd $pid VM.classloaders show-classes=true
  the loaders, as jcmd draws them:
    +-- <bootstrap>
       +-- "platform", jdk.internal.loader.ClassLoaders$PlatformClassLoader
          +-- "app", jdk.internal.loader.ClassLoaders$AppClassLoader
             +-- org.springframework.boot.devtools.restart.classloader.RestartClassLoader
  the classes RestartClassLoader defined, sorted by name: 14 -
    com.tiffinbox.web.ActuatorRoutes
    com.tiffinbox.web.ActuatorRoutes$$Lambda
    com.tiffinbox.web.ActuatorRoutes$$Lambda
    com.tiffinbox.web.ActuatorRoutes$$Lambda
    com.tiffinbox.web.KitchenHealthIndicator
    com.tiffinbox.web.KitchenMetrics
    com.tiffinbox.web.KitchenMetrics$$Lambda
    com.tiffinbox.web.KitchenMetrics$$Lambda
    com.tiffinbox.web.Route
    com.tiffinbox.web.TiffinBoxApp
    com.tiffinbox.web.TiffinBoxServer
    com.tiffinbox.web.TiffinBoxServer$$Lambda
    com.tiffinbox.web.TiffinBoxServer$$Lambda
    jdk.proxy<n>.$Proxy<n>
  com.tiffinbox.web classes the application loader defined: 2 - com.tiffinbox.web.TiffinBoxApp com.tiffinbox.web.TiffinBoxServer
  tiffinbox-core classes (com.tiffinbox, outside .web) - defined by the application loader: 10 · by RestartClassLoader: 0
  DevTools' own classes (org.springframework.boot.devtools) - defined by the application loader: some · by RestartClassLoader: 0
  (jcmd's answer is read, never printed whole: its first line names the pid, and its length moves from run to run)
$ $CURLSET 19041 .harness/dev/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 1 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```


## 3 · restart — one class file changes

`touch` changes `Route.class`'s time, as a compiler that rewrites it would. DevTools' `File Watcher` thread notices: `Restarting due
to 1 class path change (0 additions, 0 deletions, 1 modification)`. The process listening on the port is the same one; the banner,
TiffinBox's own lines and Boot's `Started` line come twice, DevTools' property-defaults line once; the new context reports `Condition
evaluation unchanged`; health answers with its groups; the seven, whole, are the same.

`.r-restart.out` · md5 `a5b72f622c926ca6facfe5845f3a79fa` · 3 of 3

```
the copy's class-path run, port 19042; once readiness answers 200, one class file's time changed, as a compiler that rewrites
it would change it:
$ cd .harness/dev && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19042
  listens on: 127.0.0.1:19042
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19042/actuator/health/readiness
  {"status":"UP"} 200
$ cd .harness/dev && touch tiffinbox-web/target/classes/com/tiffinbox/web/Route.class
  DevTools' line, on its thread File Watcher: Restarting due to 1 class path change (0 additions, 0 deletions, 1 modification)
  the process listening on 19042 now: the one this script started: yes
  in the log, once per start: Boot's banner 2 · 'orders cooked' 2 · 'TiffinBox listening' 2 · Boot's 'Started TiffinBoxServer' 2 · DevTools' 'Devtools property defaults active!' 1
  the new context's line about its conditions: Condition evaluation unchanged
  the threads TiffinBox's lines ran on: restartedMain x2
after the restart, readiness answered 200 again (asked until it did); then:
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19042/actuator/health
  {"status":"UP","groups":["liveness","readiness"]} 200
$ $CURLSET 19042 .harness/dev/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 1 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```


## 4 · timing — the restart against a cold start

`harness/clock.py` forks the copy's class-path run and asks `/kitchen` until the first 200 (the cold start: a new JVM from nothing);
then three times: it waits for readiness, changes `Route.class`'s time, and notes when the port refuses a connection (the old context
has closed TiffinBox's server: **noticing**) and when `/kitchen` answers 200 again (the **restart**); then POST /shutdown. Six runs,
run 1 a warm-up. DevTools' own defaults explain noticing: it looks every second and then waits for 400 ms of quiet.

`.r-timing.out` · md5 `0fc985516b6985f73c043bf65580c1c2` · 3 of 3

```
the cold start and the restart, timed from outside: harness/clock.py forks the copy's class-path run, port 19043, and asks
/kitchen until the first 200 - the cold start - then three times: waits until readiness answers 200, changes Route.class's
time, notes when the port stops accepting connections and when /kitchen answers 200 again; then POST /shutdown with the
token. 6 runs, run 1 a warm-up:
  how DevTools notices a change - its metadata's defaults: spring.devtools.restart.poll-interval 1s · spring.devtools.restart.quiet-period 400ms
$ cd .harness/dev && python3 ../../harness/clock.py 19043 secrets/tiffinbox/shutdown-token ../clock.out tiffinbox-web/target/classes/com/tiffinbox/web/Route.class 3 -- java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19043
  every run: a cold start, three restarts, then exit 1 after POST /shutdown: 6 of 6
the medians - the middle of the counted runs - the cold start against a floor, the restart against the cold start, noticing
against the restart (the seconds go to the terminal, never to this capture):
  counted: 5 cold starts and 15 restarts - run 1 left out
  the cold start's median over half a second: yes
  the restart's median, from the closed port to the first 200, under a quarter of the cold start's: yes
  noticing's median, from the change to the closed port, over the restart's: yes
```


**The seconds, on the terminal (this Mac, Apple M1, 2026-10-07):** over the six timed capture runs of this revision's two runs of record: at load 7-8 (3.2) cold starts 1.49-3.19 s (medians 1.86-2.33 s), restarts 0.12-1.00 s (medians 0.19-0.23 s), noticing 1.11-1.42 s (medians 1.37-1.40 s) — the restart's median 0.100-0.113 of the cold start's; at load 88-208 (5.3) cold starts 1.25-5.38 s (medians 1.67-3.48 s), restarts 0.12-1.10 s (medians 0.20-0.43 s), noticing 1.18-1.52 s (medians 1.38-1.39 s) — 0.087-0.171. Noticing's median stays near 1.4 s at any load: it is DevTools' own schedule (a look every second, then 400 ms of quiet), not work. (The first revision's runs: 0.072-0.170 at load 17-27, 0.135-0.139 at load 6-8; on the Actuator lesson's tree 0.070-0.094 at load 65-194, 0.116-0.128 at load 5-6.)

## 5 · identity — the break: where the holder of an old object lives (A/B/A′)

`Witness` (`harness/probe/Witness.java`, compiled into the folder `.harness/hc`, joined with `--spring.main.sources`) asks `Holder`
(`harness/probe/Holder.java`: one static field) at every start what it kept from the start before, compares it with this start's
TiffinBoxServer and casts it the plain way; then hands it this start's. **The flipped attribute: which loader defines `Holder`.**
A — `Holder` in a folder: RestartClassLoader defines it, the restart defines it again, and it keeps nothing. B — `Holder` in a jar: the
application loader defines it once; it survives the restart with start 1's TiffinBoxServer — same name, not the same class, not the
same loader — and the cast fails with the JVM's own message, two RestartClassLoaders in it. A′ = A, line for line. Course 2's sentence,
in its own words: "Identity is name plus loader." (`core-java-2`, the class-loading lesson; P10).

`.r-identity.out` · md5 `cdf54a312467ecbf166f7de80d000ab5` · 3 of 3

```
the break - where the holder of an old object lives. The copy's class-path run with the harness in front of its class path:
Witness (harness/probe/Witness.java, compiled into the folder .harness/hc, joined with --spring.main.sources) asks Holder - one
static field - at every start what it kept from the start before, then hands it this start's TiffinBoxServer. The flipped
attribute: which loader defines Holder - a folder's classes are DevTools' to restart, a jar's are not.
A - Holder in a folder (.harness/hold), port 19044:
$ cd .harness/dev && java -cp "../hc:../hold:tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19044 --spring.main.sources=probe.Witness
  listens on: 127.0.0.1:19044
$ cd .harness/dev && touch tiffinbox-web/target/classes/com/tiffinbox/web/Route.class
  WITNESS start 1 · Holder's loader RestartClassLoader · TiffinBoxServer's loader RestartClassLoader
  WITNESS start 1 · Holder keeps nothing from an earlier start
  WITNESS start 2 · Holder's loader RestartClassLoader · TiffinBoxServer's loader RestartClassLoader
  WITNESS start 2 · Holder keeps nothing from an earlier start
$ $CURLSET 19044 .harness/dev/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 1 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
B - Holder in a jar (.harness/holder.jar), port 19044:
$ cd .harness/dev && java -cp "../hc:../holder.jar:tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19044 --spring.main.sources=probe.Witness
  listens on: 127.0.0.1:19044
$ cd .harness/dev && touch tiffinbox-web/target/classes/com/tiffinbox/web/Route.class
  WITNESS start 1 · Holder's loader app · TiffinBoxServer's loader RestartClassLoader
  WITNESS start 1 · Holder keeps nothing from an earlier start
  WITNESS start 2 · Holder's loader app · TiffinBoxServer's loader RestartClassLoader
  WITNESS start 2 · Holder keeps the TiffinBoxServer of start 1
  WITNESS start 2 · same name true · same class false · same loader false
  WITNESS start 2 · cast java.lang.ClassCastException: class com.tiffinbox.web.TiffinBoxServer cannot be cast to class com.tiffinbox.web.TiffinBoxServer (com.tiffinbox.web.TiffinBoxServer is in unnamed module of loader org.springframework.boot.devtools.restart.classloader.RestartClassLoader @<hash>; com.tiffinbox.web.TiffinBoxServer is in unnamed module of loader org.springframework.boot.devtools.restart.classloader.RestartClassLoader @<hash>)
$ $CURLSET 19044 .harness/dev/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 1 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
A' - A again:
$ cd .harness/dev && java -cp "../hc:../hold:tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19044 --spring.main.sources=probe.Witness
  listens on: 127.0.0.1:19044
$ cd .harness/dev && touch tiffinbox-web/target/classes/com/tiffinbox/web/Route.class
  WITNESS start 1 · Holder's loader RestartClassLoader · TiffinBoxServer's loader RestartClassLoader
  WITNESS start 1 · Holder keeps nothing from an earlier start
  WITNESS start 2 · Holder's loader RestartClassLoader · TiffinBoxServer's loader RestartClassLoader
  WITNESS start 2 · Holder keeps nothing from an earlier start
$ $CURLSET 19044 .harness/dev/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 1 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```


## 6 · which — what restarts

A fresh DevTools copy, tiffinbox-core as a jar on its class path; run with `Loaders` (`harness/probe/Loaders.java`: the loaders of
TiffinBoxServer and OrderQueue at each start). While it runs, one comment line goes under `OrderQueue.java`'s package line — every line
of code below moves down one, so the class file changes (a comment after the last line changes no byte: Boot's parent fixes the build
time, measured while writing this unit) — and the module is rebuilt alone, as the README's table builds it: the jar's md5 changed, and
DevTools restarted nothing. Then one web class touched: one restart, one change, OrderQueue still from the application loader.

`.r-which.out` · md5 `02b1b496da15b94e587bd66b7048824d` · 3 of 3

```
what restarts. A copy of the copy's kind (.harness/which: the anchor and the same line), built the same way; tiffinbox-core
comes as a jar on its class path:
$ perl -0pi -e 's|\n  </dependencies>|\n    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-devtools</artifactId><optional>true</optional></dependency>\n  </dependencies>|' .harness/which/tiffinbox-web/pom.xml
  lines added: 1
$ cd .harness/which && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt
  built the copy · offline: yes · exit 0
  target/classpath.txt: 54 entries · jars 54 · spring-boot-devtools-4.1.1.jar among them: 1 · tiffinbox-core as: tiffinbox-core/target/tiffinbox-core-1.0.0.jar
its class-path run with the harness's Loaders (harness/probe/Loaders.java, from .harness/hc), port 19045:
$ cd .harness/which && java -cp "../hc:tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19045 --spring.main.sources=probe.Loaders
  listens on: 127.0.0.1:19045
  LOADERS start 1 · TiffinBoxServer's loader RestartClassLoader · OrderQueue's loader app
while it runs, a change in tiffinbox-core - one comment line under OrderQueue.java's package line, so every line of code after
it moves down one and the class file changes - and the module rebuilt alone, as the README's table builds it, offline:
$ cd .harness/which && perl -0pi -e 's|^(package com\.tiffinbox;\n)|\1// changed while TiffinBox runs\n|' tiffinbox-core/src/main/java/com/tiffinbox/OrderQueue.java
$ cd .harness/which && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package -pl tiffinbox-core
  built tiffinbox-core alone · offline: yes · exit 0
  the jar on the class path, rewritten: its md5 changed: yes · DevTools' restart lines so far: 0
then one class file of the web module, its time changed:
$ cd .harness/which && touch tiffinbox-web/target/classes/com/tiffinbox/web/Route.class
  DevTools' restart lines: 1 - Restarting due to 1 class path change (0 additions, 0 deletions, 1 modification)
  LOADERS start 2 · TiffinBoxServer's loader RestartClassLoader · OrderQueue's loader app
$ $CURLSET 19045 .harness/which/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 1 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```


## 7 · livereload — deprecated, off, on for one run, stopped

DevTools' own metadata: `spring.devtools.livereload.enabled` (default `false`) and `spring.devtools.livereload.port` (default 35729),
both **deprecated since 4.1.0, "Deprecated with no replacement"**. Off: the condition report says why its configuration did not match,
and nothing listens on 19049 or 35729. On, for one run, on 19049: `LiveReload server is running on port 19049`, `lsof` shows it on
**every interface** (`*:19049`) beside TiffinBox's `127.0.0.1:19046`; it serves `livereload.js` — byte for byte DevTools' own file —
and Boot's log says nothing about the deprecation. That run's POST /shutdown stops both.

`.r-livereload.out` · md5 `245eaab2d150323fc61850b42a312824` · 3 of 3

```
Live Reload in DevTools' own metadata (META-INF/spring-configuration-metadata.json in spring-boot-devtools-4.1.1.jar):
  spring.devtools.livereload.enabled · default false · deprecated: yes · since 4.1.0 · reason: Deprecated with no replacement
  spring.devtools.livereload.port · default 35729 · deprecated: yes · since 4.1.0 · reason: Deprecated with no replacement
off, as DevTools leaves it - the copy's class-path run with --debug, port 19046: the condition report's block for Live Reload,
the rest of the report counted:
$ cd .harness/dev && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19046 --debug
  listens on: 127.0.0.1:19046
    CONDITIONS EVALUATION REPORT
    … 446 lines not shown …
       LocalDevToolsAutoConfiguration.LiveReloadConfiguration:
          Did not match:
             - @ConditionalOnBooleanProperty (spring.devtools.livereload.enabled=true) did not find property 'spring.devtools.livereload.enabled' (OnPropertyCondition)
    … 175 lines not shown …
  19049 listened on: 0 · 35729 (its default): 0
$ $CURLSET 19046 .harness/dev/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 1 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
on, for this one run - its port 19049, never its default - port 19046:
$ cd .harness/dev && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19046 --spring.devtools.livereload.enabled=true --spring.devtools.livereload.port=19049
  listens on: *:19049 127.0.0.1:19046
  its line in Boot's log: LiveReload server is running on port 19049
$ curl -s -o .harness/livereload.js -w '%{http_code} %{content_type}\n' http://127.0.0.1:19049/livereload.js
  200 text/javascript
  the script it served is DevTools' own file (org/springframework/boot/devtools/livereload/livereload.js in its jar): yes
  lines in Boot's log that say deprecated (any case): 0
$ $CURLSET 19046 .harness/dev/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 1 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  19049 listened on now: 0
```


## 8 · ship — three guards, and the native profile's build

**1** optional: the copy's jar, 0 entries. **2** not optional: still 0 — Boot's repackage goal leaves DevTools out by default
(`excludeDevtools`, default `true`, read from the plugin's own descriptor). **3** forced in (`-Dspring-boot.repackage.excludeDevtools=false`):
DevTools' jar in `BOOT-INF/lib`; run with `java -jar`, DevTools keeps its restart off — `Initialized Restarter Condition initialized
without URLs` — and the run ends with exit 0; **a default, not a lock**: `-Dspring.devtools.restart.enabled=true` switches it back on
(`Restart enabled irrespective of application packaging due to System property …`), TiffinBox starts on `restartedMain`, and the run
exits 1. **C (labelled)** Boot's plugin told `includeOptional` and `excludeDevtools=false` (in its configuration — `includeOptional`
has no property): one jar more, DevTools'. **The native profile's build** (the README's AOT line) on the anchor and on the copy: Spring's
AOT step writes the same 149 files, byte for byte, none naming DevTools — Boot's process-aot goal filters DevTools out by name
(`DEVTOOLS_EXCLUDE_FILTER`, read with javap). The copy's native-profile jar does hold DevTools entries: three — GraalVM's metadata file
for DevTools and its two folders, which the native plugin's metadata step copies for every dependency Maven lists.

`.r-ship.out` · md5 `16eb4a4674231f5cf8aed0a8143bbfd5` · 3 of 3

```
why it must never ship - three guards. 1 optional: the copy (capture added's):
  entries of its jar that name devtools: 0
2 not optional - .harness/ship-req, the anchor and the line without <optional>; built the README's plain way:
$ perl -0pi -e 's|\n  </dependencies>|\n    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-devtools</artifactId></dependency>\n  </dependencies>|' .harness/ship-req/tiffinbox-web/pom.xml
  lines added: 1
$ cd .harness/ship-req && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built not optional · offline: yes · exit 0
  entries of its jar that name devtools: 0
  Boot's plugin, its repackage goal (META-INF/maven/plugin.xml): excludeDevtools default true · its property spring-boot.repackage.excludeDevtools
3 forced in - .harness/ship-forced, the same, built with that property false:
$ perl -0pi -e 's|\n  </dependencies>|\n    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-devtools</artifactId></dependency>\n  </dependencies>|' .harness/ship-forced/tiffinbox-web/pom.xml
  lines added: 1
$ cd .harness/ship-forced && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package -Dspring-boot.repackage.excludeDevtools=false
  built forced in · offline: yes · exit 0
  entries of its jar that name devtools: 1 -
    BOOT-INF/lib/spring-boot-devtools-4.1.1.jar
its jar run as the README runs it, with --debug, port 19047:
$ cd .harness/ship-forced && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19047 --debug
  listens on: 127.0.0.1:19047
    CONDITIONS EVALUATION REPORT
    … 429 lines not shown …
       LocalDevToolsAutoConfiguration:
          Did not match:
             - Initialized Restarter Condition initialized without URLs (OnInitializedRestarterCondition)
    … 175 lines not shown …
  lines on restartedMain: 0 · DevTools' 'Devtools property defaults active!': 0
$ $CURLSET 19047 .harness/ship-forced/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
the same jar, one system property more:
$ cd .harness/ship-forced && java -Dspring.devtools.restart.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=19047
  listens on: 127.0.0.1:19047
  DevTools' line: Restart enabled irrespective of application packaging due to System property 'spring.devtools.restart.enabled' being set to true
  TiffinBox's own lines on restartedMain: 1 · 'Devtools property defaults active!': 1
$ $CURLSET 19047 .harness/ship-forced/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 1 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
C (labelled) - .harness/ship-opt, the copy's line (optional) with Boot's plugin told to take optional dependencies and DevTools
(includeOptional true, excludeDevtools false - includeOptional has no property of its own), before the POM's first
</configuration>, Boot's plugin's:
$ perl -0pi -e 's|\n  </dependencies>|\n    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-devtools</artifactId><optional>true</optional></dependency>\n  </dependencies>|' .harness/ship-opt/tiffinbox-web/pom.xml
  lines added: 1
$ perl -0pi -e 's|\n        </configuration>|\n          <includeOptional>true</includeOptional><excludeDevtools>false</excludeDevtools>\n        </configuration>|' .harness/ship-opt/tiffinbox-web/pom.xml
  lines added: 1
$ cd .harness/ship-opt && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built C · offline: yes · exit 0
  jars under BOOT-INF/lib against the anchor's: 47 and 46 · only in C's: spring-boot-devtools-4.1.1.jar · only in the anchor's: 0
the native profile's build - the README's AOT line, Spring's AOT step on the plain JDK - on the copy (.harness/aot-dev) and on
the anchor (.harness/aot-base), offline:
$ perl -0pi -e 's|\n  </dependencies>|\n    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-devtools</artifactId><optional>true</optional></dependency>\n  </dependencies>|' .harness/aot-dev/tiffinbox-web/pom.xml
  lines added: 1
$ cd .harness/aot-base && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean package
  built the anchor · offline: yes · exit 0
$ cd .harness/aot-dev && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean package
  built the copy · offline: yes · exit 0
$ diff -rq .harness/aot-base/tiffinbox-web/target/spring-aot/main .harness/aot-dev/tiffinbox-web/target/spring-aot/main
  files Spring's AOT step wrote: 149 and 149 · files that differ, or are in one only: 0 · naming devtools: 0
$ javap -c -p -cp "$M2/org/springframework/boot/spring-boot-maven-plugin/4.1.1/spring-boot-maven-plugin-4.1.1.jar" org.springframework.boot.maven.ProcessAotMojo
$ javap -c -p -constants -cp "$M2/org/springframework/boot/spring-boot-maven-plugin/4.1.1/spring-boot-maven-plugin-4.1.1.jar" org.springframework.boot.maven.AbstractDependencyFilterMojo
  Boot's process-aot goal (ProcessAotMojo) reads DEVTOOLS_EXCLUDE_FILTER: 1 time(s) · the filter (AbstractDependencyFilterMojo, its static block): org.springframework.boot spring-boot-devtools
  each jar's entries that name devtools - the anchor's: 0 · the copy's: 3 -
    META-INF/native-image/org.springframework.boot/spring-boot-devtools/
    META-INF/native-image/org.springframework.boot/spring-boot-devtools/4.1.1/
    META-INF/native-image/org.springframework.boot/spring-boot-devtools/4.1.1/reachability-metadata.json
  the copy's build log, the native plugin's metadata step: [graalvm reachability metadata repository for org.springframework.boot:spring-boot-devtools:4.1.1]: Configuration directory is org.springframework.boot/spring-boot-devtools/4.1.0
```


## 9 · exits — exit 1 after a clean stop (A/B/A′, C, D, E)

A — the restart on (DevTools' default): POST /shutdown, the seven, **exit 1**. B — `-Dspring.devtools.restart.enabled=false`: exit 0.
A′ = A: exit 1. C (labelled) — the same class path without DevTools' jar: exit 0. Before each stop jcmd shows the same threads: no
thread named `main`, `DestroyJavaVM` waiting, `HTTP-Dispatcher` the other Java thread that is not a daemon. **D (labelled)** DevTools'
code, read with javap: `Restarter.immediateRestart()` ends by calling `SilentExitExceptionHandler.exitCurrentThread()`, which throws
`SilentExitException` — the first `main` thread ends with an exception that DevTools' handler hides. **E (labelled)** the JVM's own
rule, nothing of Spring (`harness/probe/MainEnds.java`): a main thread that hides its own uncaught exception, while a thread that is not
a daemon keeps the JVM up, ends the process with **1**; one that returns, with 0. Nothing is printed either way. So the brief's S4.21
("cause unmeasured") is measured here: it is how DevTools ends the first `main`, and never TiffinBox's failure.

`.r-exits.out` · md5 `96656dea659642d4ef7f9456e66adad2` · 3 of 3

```
how the copy's class-path run ends after a clean POST /shutdown - A the restart on (DevTools' default) · B off · A' = A ·
C (labelled) the same class path without DevTools' jar; port 19048:
A - the restart on:
$ cd .harness/dev && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19048
  listens on: 127.0.0.1:19048
  DevTools' restart lines: 0
  its threads (jcmd $pid Thread.print): named main 0 · named DestroyJavaVM 1 · Java threads that are not daemons: DestroyJavaVM HTTP-Dispatcher
$ $CURLSET 19048 .harness/dev/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 1 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
B - -Dspring.devtools.restart.enabled=false:
$ cd .harness/dev && java -Dspring.devtools.restart.enabled=false -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19048
  listens on: 127.0.0.1:19048
  DevTools' restart lines: 1 - Restart disabled due to System property 'spring.devtools.restart.enabled' being set to false
  its threads (jcmd $pid Thread.print): named main 0 · named DestroyJavaVM 1 · Java threads that are not daemons: DestroyJavaVM HTTP-Dispatcher
$ $CURLSET 19048 .harness/dev/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
A' - A again:
$ cd .harness/dev && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19048
  listens on: 127.0.0.1:19048
  DevTools' restart lines: 0
  its threads (jcmd $pid Thread.print): named main 0 · named DestroyJavaVM 1 · Java threads that are not daemons: DestroyJavaVM HTTP-Dispatcher
$ $CURLSET 19048 .harness/dev/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 1 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
$ cd .harness/dev && tr ':' '\n' < tiffinbox-web/target/classpath.txt | grep -v '/spring-boot-devtools-' | paste -sd: - > tiffinbox-web/target/classpath-nodevtools.txt
  entries: 54 and 53
C - without DevTools' jar:
$ cd .harness/dev && java -cp "tiffinbox-web/target/classes:$(cat tiffinbox-web/target/classpath-nodevtools.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19048
  listens on: 127.0.0.1:19048
  DevTools' restart lines: 0
  its threads (jcmd $pid Thread.print): named main 0 · named DestroyJavaVM 1 · Java threads that are not daemons: DestroyJavaVM HTTP-Dispatcher
$ $CURLSET 19048 .harness/dev/secrets/tiffinbox/shutdown-token
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
D (labelled) - DevTools' own code, read with javap from spring-boot-devtools-4.1.1.jar:
$ javap -c -p -cp "$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar" org.springframework.boot.devtools.restart.Restarter
$ javap -c -p -cp "$M2/org/springframework/boot/spring-boot-devtools/4.1.1/spring-boot-devtools-4.1.1.jar" org.springframework.boot.devtools.restart.SilentExitExceptionHandler
  Restarter.immediateRestart() ends by calling: org/springframework/boot/devtools/restart/SilentExitExceptionHandler.exitCurrentThread:()V
  SilentExitExceptionHandler.exitCurrentThread(): new org/springframework/boot/devtools/restart/SilentExitExceptionHandler$SilentExitException · athrow
E (labelled) - the JVM's own rule, with nothing of Spring (harness/probe/MainEnds.java: its main thread starts a thread that is not
a daemon, and hides its own uncaught exception):
$ java -cp .harness/me probe.MainEnds throw
  printed: 0 lines · exit 1
$ java -cp .harness/me probe.MainEnds return
  printed: 0 lines · exit 0
```


## 10 · native — the binary, without and with the exclusion

Two DevTools copies, each built with the README's two Maven lines. **Without an exclusion:** native-image's class path holds DevTools'
jar (the native plugin builds from Maven's class path, optional dependencies included — the hints lesson's finding), the binary holds
names under `org.springframework.boot.devtools`, and it stops at start, before TiffinBox's port opens: `Unable to instantiate factory
class [org.springframework.boot.devtools.restart.RestartScopeInitializer]` — `ClassNotFoundException` — exit 1. **With one
`<exclusion>`** beside the hints lesson's three: no DevTools on native-image's class path, none in the binary, health with its groups,
the seven, exit 0 (no DevTools, no exit 1).

`.r-native.out` · md5 `e2a620fd509723b89411d0551bd8d10e` · 3 of 3

```
two copies of the copy (the anchor and DevTools' optional line), each built with the README's two Maven lines, offline;
$GRAALVM_HOME names the GraalVM. Without an exclusion - .harness/nat-b:
$ perl -0pi -e 's|\n  </dependencies>|\n    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-devtools</artifactId><optional>true</optional></dependency>\n  </dependencies>|' .harness/nat-b/tiffinbox-web/pom.xml
  lines added: 1
$ cd .harness/nat-b && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean install
  built .harness/nat-b (both modules, into $M2) · offline: yes · exit 0
$ cd .harness/nat-b && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -pl tiffinbox-web native:compile-no-fork
  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 20 minutes · offline: yes
  native-image's class path (the plugin's 'Executing:' line) - entries that are spring-boot-devtools-4.1.1.jar: 1
  file: Mach-O 64-bit executable · the demo token in its bytes: 0 · strings naming org.springframework.boot.devtools in its bytes: 24
its binary, run from beside its config tree as the README runs it, port 19047:
$ cd .harness/nat-b && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19047
    Exception in thread "main" java.lang.IllegalArgumentException: Unable to instantiate factory class [org.springframework.boot.devtools.restart.RestartScopeInitializer] for factory type [org.springframework.context.ApplicationContextInitializer]
    … 12 lines not shown …
    Caused by: java.lang.ClassNotFoundException: org.springframework.boot.devtools.restart.RestartScopeInitializer
    … 6 lines not shown …
  exit 1 · listened on 19047: 0 time(s)
with one exclusion in the native plugin, beside the hints lesson's three - .harness/nat-a:
$ perl -0pi -e 's|\n  </dependencies>|\n    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-devtools</artifactId><optional>true</optional></dependency>\n  </dependencies>|' .harness/nat-a/tiffinbox-web/pom.xml
  lines added: 1
$ perl -0pi -e 's|\n          </exclusions>|\n            <exclusion><groupId>org.springframework.boot</groupId><artifactId>spring-boot-devtools</artifactId></exclusion>\n          </exclusions>|' .harness/nat-a/tiffinbox-web/pom.xml
  lines added: 1
$ cd .harness/nat-a && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean install
  built .harness/nat-a (both modules, into $M2) · offline: yes · exit 0
$ cd .harness/nat-a && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -pl tiffinbox-web native:compile-no-fork
  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 20 minutes · offline: yes
  native-image's class path (the plugin's 'Executing:' line) - entries that are spring-boot-devtools-4.1.1.jar: 0
  file: Mach-O 64-bit executable · the demo token in its bytes: 0 · strings naming org.springframework.boot.devtools in its bytes: 0
its binary, port 19047:
$ cd .harness/nat-a && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=19047
  listens on: 127.0.0.1:19047
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19047/actuator/health/readiness
  {"status":"UP"} 200
$ curl -s -w ' %{http_code}\n' http://127.0.0.1:19047/actuator/health
  {"status":"UP","groups":["liveness","readiness"]} 200
$ $CURLSET 19047 .harness/nat-a/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```


## 11 · exercise — run as written

`.r-exercise.out` · md5 `9b48c795e9543274eb9d10c4463049c1` · 3 of 3

```
exercise/README.md's commands, run exactly as written from this folder - 7 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine .harness/mine-hc .harness/mine.log && mkdir -p .harness/mine-hc && rsync -a --exclude target --exclude secrets anchor/ .harness/mine/
  $ perl -0pi -e 's|\n  </dependencies>|\n    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-devtools</artifactId><optional>true</optional></dependency>\n  </dependencies>|' .harness/mine/tiffinbox-web/pom.xml
  $ mvn -o -B -q -f .harness/mine/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -DskipTests clean package dependency:build-classpath -Dmdep.outputFile=target/classpath.txt
  $ javac -d .harness/mine-hc -cp ".harness/mine/tiffinbox-web/target/classes:$(cat .harness/mine/tiffinbox-web/target/classpath.txt)" harness/probe/Loaders.java
  $ mkdir -p .harness/mine/secrets/tiffinbox && chmod 700 .harness/mine/secrets .harness/mine/secrets/tiffinbox && (umask 077 && { LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 26; echo; } > .harness/mine/secrets/tiffinbox/shutdown-token)
  exit 0 · printed: 0 line(s)
the solution's commands (exercise/solution/SOLUTION.md), run exactly as written, from this folder - 6 lines:
  $ tr ':' '\n' < .harness/mine/tiffinbox-web/target/classpath.txt | sed 's|/tiffinbox-core/target/tiffinbox-core-1\.0\.0\.jar$|/tiffinbox-core/target/classes|' | paste -sd: - > .harness/mine/classpath-core-folder.txt
  $ (cd .harness/mine && exec java -cp "../mine-hc:tiffinbox-web/target/classes:$(cat classpath-core-folder.txt)" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=19045 --spring.main.sources=probe.Loaders > ../mine.log 2>&1) &
  $ for i in $(seq 240); do grep -q '^LOADERS start 1 ' .harness/mine.log 2> /dev/null && break; sleep 0.25; done; grep '^LOADERS start 1 ' .harness/mine.log
  $ touch .harness/mine/tiffinbox-core/target/classes/com/tiffinbox/OrderQueue.class
  $ for i in $(seq 240); do grep -q '^LOADERS start 2 ' .harness/mine.log && break; sleep 0.25; done; grep -o 'Restarting due to .*' .harness/mine.log; grep '^LOADERS start 2 ' .harness/mine.log
  $ harness/shutdown.sh 19045 .harness/mine/secrets/tiffinbox/shutdown-token; wait $!; echo "TiffinBox's exit code: $?"
LOADERS start 1 · TiffinBoxServer's loader RestartClassLoader · OrderQueue's loader RestartClassLoader
Restarting due to 1 class path change (0 additions, 0 deletions, 1 modification)
LOADERS start 2 · TiffinBoxServer's loader RestartClassLoader · OrderQueue's loader RestartClassLoader
POST /shutdown -> 200 · curl exit 0
TiffinBox's exit code: 1
  listening on 19045 now: 0
```


## Exercise

**Your turn:** put tiffinbox-core's classes folder on the class path instead of its jar, change OrderQueue, and watch what restarts.
`exercise/README.md` has the commands; done is the two lines `Restarting due to 1 class path change (0 additions, 0 deletions, 1
modification)` and `LOADERS start 2 · TiffinBoxServer's loader RestartClassLoader · OrderQueue's loader RestartClassLoader`; the
measured answer, run exactly as written in a clean `env -i` shell, is `exercise/solution/SOLUTION.md`.

## RE-MEASURE — the brief's items this unit settles

| # | What | 10-06 probe | 10-07 probe | This unit (receipts, 2026-10-07) |
|---|---|---|---|---|
| 4 | DevTools' restart against a cold start | about a tenth (0.09-0.14 s vs 0.95-0.99 s) | under a third (0.15-0.48 s vs 1.21-2.63 s, loaded) | **under a quarter, measured in the same runs** (the restart from the closed port to the first 200; medians of 15 restarts and 5 cold starts per capture run): 0.100-0.113 at load 7-8 and 0.087-0.171 at load 88-208 in the six timed capture runs of this revision's two runs of record; 0.072-0.170 and 0.135-0.139 in the first revision's; on the Actuator lesson's tree 0.070-0.094 and 0.116-0.128 — a fourteenth to a sixth of a cold start, never a quarter; under load the ratio spreads both ways |
| 5 | The DevTools run's class path | 37 jars | 36 entries | **The probes' tree, the README's line: 37 entries, all jars** (tiffinbox-core as the reactor's jar; the classes folder in front is not in the file) — the 10-06 count. With `compile` in place of `package`, the file still holds 37 entries, but tiffinbox-core comes as its classes folder: 36 jars (measured while writing this unit, not captured) — the likeliest source of the 10-07 count. **This tree (the logging lesson's: Actuator, and Micrometer's Prometheus registry): 54, all jars** (the Actuator lesson's tree, before the re-point: 47). |
| — | Break A (the holder in a folder) | not run | not run | **measured** (`identity` A, A′): no old object kept, no cast |
| — | The restart on a core folder | — | — | **measured** (the exercise): OrderQueue in the restart loader from the first start; one touch, one restart |

## Found on the way

- **The brief's Boot-plugin exclude is not needed.** ⚑7 and unit 21's hand-off said DevTools would need one more `<exclude>` in Boot's
  plugin for the AOT step. Measured: Boot's process-aot goal leaves DevTools off its class path itself (`ProcessAotMojo` applies
  `DEVTOOLS_EXCLUDE_FILTER`; its `-X` command line holds no DevTools jar), and Spring's AOT step writes byte-identical files with
  and without DevTools on Maven's class path. Added anyway, the exclude changed nothing measurable here (not captured).
- **The native-profile jar carries DevTools' metadata file.** The native plugin's `add-reachability-metadata` goal copies GraalVM's
  file for every dependency Maven lists — DevTools' included — into the jar (`META-INF/native-image/…/spring-boot-devtools/4.1.1/`);
  that goal has no `exclusions` parameter (its descriptor), so neither the native plugin's `<exclusion>` nor Boot's `<exclude>` removes
  it (both measured while writing this unit). The anchor's own native-profile jar already carries Jackson 3's metadata files the same
  way. The plain jar holds no DevTools entry.
- **RestartClassLoader holds 14 classes on this tree, not 6**, and the application loader holds TiffinBoxApp beside TiffinBoxServer
  (the probe named only the server): the first `main` names both. ActuatorRoutes (the Actuator lesson), KitchenHealthIndicator (the
  health lesson) and KitchenMetrics (the metrics lesson) joined the web module, with their lambdas (10 classes on the Actuator lesson's
  tree, before the re-point).
- **`includeOptional` brings DevTools alone on this tree** — the probe saw Jackson 3.1.5 come in and the Compose module stay out; the
  anchor's three Boot-plugin excludes (the Actuator lesson's) now keep all three out of the jar too.
- **A change touched too early is missed.** TiffinBox answers mid-refresh; a class file touched at its first answer, before DevTools'
  watcher took its first look at the folders, was part of that first look: no restart (7 of 11 runs while probing). Every capture
  touches only after readiness answers 200.
- **Rebuilding the core module while TiffinBox runs restarts nothing** (`which`); whether the restart that follows sees the new jar's
  classes is not measured here — OrderQueue's loader is `app` before and after, and no response depends on the comment line.

## The re-point to `../c5-unit24/after` (2026-10-07), and for RED

This unit was built on `../c5-unit21/after`, the Actuator lesson's tree (commit `9077840`), while the health, metrics and logging
lessons were being written, and re-pointed before RED to the tree a viewer has when this lesson plays: `../c5-unit24/after`, the
logging lesson's (the brief's "Code and anchor"). Between the two trees, the web module gained `KitchenHealthIndicator` (health),
`KitchenMetrics` and Micrometer's Prometheus registry (metrics); `TiffinBoxServer` a timer and a DEBUG line per answer (metrics,
logging); `ActuatorRoutes` one branch, for a scrape's bytes; and `application.yaml` a readiness group, `prometheus` in the exposure
list and the log group `kitchen`. tiffinbox-core did not change. TiffinBoxServer's new DEBUG line stays silent in every capture: no run here sets a level. Checked on the DevTools copy after the runs of record (not captured): the seven answered, 0 DEBUG lines; with the logging lesson's `--logging.level.kitchen=debug`, 12 — Boot's `Running with Spring Boot` line, TiffinBox's 5 route lines at start, and 6 answers (`/nowhere` is the JDK server's own 404, which TiffinBox's handler never sees).

| capture | on `../c5-unit21/after` | on `../c5-unit24/after` | what moved |
|---|---|---|---|
| `added` | `e6e17c0e25993a642937252392040a30` | `aa2e2929f1165c758fbbbf8d6352ef4a` | its first line names the logging lesson; `diff`'s hunk `53a54` → `61a62` (the web POM has eight lines more above DevTools' line: Prometheus' registry and its comment); jars under `BOOT-INF/lib` 39 and 39 → 46 and 46; the class path Maven lists 47 → 54 entries |
| `loaders` | `ab81385e35c5ec1c182be20671b095ac` | `31932a8561380caf709ac37530b90633` | RestartClassLoader's classes 10 → 14 — KitchenHealthIndicator, KitchenMetrics and KitchenMetrics' two lambdas — and the list sorted by name |
| `restart` | `a5b72f622c926ca6facfe5845f3a79fa` | `a5b72f622c926ca6facfe5845f3a79fa` | nothing: the same capture, byte for byte |
| `timing` | `0fc985516b6985f73c043bf65580c1c2` | `0fc985516b6985f73c043bf65580c1c2` | nothing: the same capture, byte for byte |
| `identity` | `cdf54a312467ecbf166f7de80d000ab5` | `cdf54a312467ecbf166f7de80d000ab5` | nothing: the same capture, byte for byte |
| `which` | `a15cbcacdf0960f6809cede439c4d389` | `02b1b496da15b94e587bd66b7048824d` | the class path Maven lists 47 → 54 entries |
| `livereload` | `53d74d02048a07c451ed4308e4ac5978` | `245eaab2d150323fc61850b42a312824` | the condition report's lines not shown: 432 and 169 → 446 and 175 |
| `ship` | `0f4fae6fc74cb53951c29671a199e98b` | `16eb4a4674231f5cf8aed0a8143bbfd5` | the report's lines not shown, 415 and 169 → 429 and 175; C's jars against the anchor's 40 and 39 → 47 and 46; the files Spring's AOT step wrote 144 → 149 |
| `exits` | `f3f160fb64a80c16a967b0e4eba21a24` | `96656dea659642d4ef7f9456e66adad2` | the class path's entries with and without DevTools' jar: 47 and 46 → 54 and 53 |
| `native` | `e2a620fd509723b89411d0551bd8d10e` | `e2a620fd509723b89411d0551bd8d10e` | nothing: the same capture, byte for byte |
| `exercise` | `9b48c795e9543274eb9d10c4463049c1` | `9b48c795e9543274eb9d10c4463049c1` | nothing: the same capture, byte for byte |

- **The checks' tree-dependent expectations** (the top of `receipts.sh`'s checks): `E_LIBS` 39 → 46, `E_CP` 47 → 54, `E_RCL` 10 → 14,
  `E_CORE` 10 → 10, `E_AOT` 144 → 149 — and a sixth, which had been hard-coded inside the `loaders` checks: the web module's classes in
  RestartClassLoader, by name (four on the Actuator lesson's tree, six here), now `E_WEB`. The builder reads every spoken number off the
  captures; two moved: "forty-seven jars" → "fifty-four jars", "ten classes of the web module" → "fourteen classes" (673 spoken
  words, as before).
- **`loaders` lists the restart loader's classes sorted by name** (Masks, 5): on this tree the order jcmd lists them in moved from one
  run to the next (a first pass's and the first publishing run's), so a capture that kept jcmd's order could not stay the same.
- **Unchanged by the tree:** the 11 lines `readme()` reads from the anchor's README, and its table row (the script's own message said
  12 lines; corrected); the `perl` lines' anchors in the anchor's web POM — `  </dependencies>` once, `          </exclusions>` once, and
  Boot's plugin's `        </configuration>`, the first of the three.
- **For RED:** whether a level set through the `loggers` endpoint (the logging lesson's, exposed by a flag) survives a DevTools restart
  is not measured here — it would need a capture of its own and words this unit does not have.
- Ports used: 19040-19049 only; nothing of this unit listens after it ends (Interrupted).
