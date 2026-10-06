# c5-unit19 — AOT Processing and Native Image

Course 5 · Spring Boot · Section 3 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1, GraalVM CE 25.3.4.1**
(native-image 25.0.4.1), 2026-10-05. Course 3 built a native image and watched its closed world miss a class named only in a
text file. Spring has an ahead-of-time step of its own (AOT): Boot's `process-aot`, run by Boot's parent's profile `native`,
settles TiffinBox's configuration while the jar is built. This unit opens what it wrote (the bean definitions as Java code, and
a `reachability-metadata.json`), runs that jar on the JVM (the same seven responses; four definitions fewer), shows a setting it
froze (the virtual-thread switch, read and ignored at run time — both ways), times the start from outside the JVM (with the
JDK's AOT cache too), and builds the native binary with Boot's managed plugin — which says `BUILD SUCCESS`, and then stops at
start.

**The anchor changes (brief ⚑8):** `tiffinbox-web/pom.xml` declares GraalVM's Native Build Tools plugin, bare — Boot's parent
manages its version, **1.1.8**, where Course 3 pinned 1.1.13 (ledger P18, paid as a correction: under Boot's parent the number
goes down). `c5-tiffinbox` and this unit's `after/` hold the change and the anchor README's new section, and nothing else
(`diff -rq -x target ../c5-tiffinbox after` is empty). The next unit starts from `after/`.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 8 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) It runs for about
11-16 minutes on the author's Mac (668-970 s over the three full runs of 2026-10-06: 702 s under `bash receipts.sh`, 970 s under
`./receipts.sh` on a Mac warm from the next unit's fifteen native builds) — three native builds of two to three minutes each are most of it. It **dies** when a capture's md5
differs from `receipts.md5` (it prints the `DIFFERS` line first, so you can see which one moved).

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else — the variable Course 3 used, and the one GraalVM's
Maven plugin reads first (`native` prints `Found GraalVM installation from GRAALVM_HOME variable.`). It refuses to start when the
variable does not name a `bin/native-image`, or when `native-image --version` is not `native-image 25.0.4.1 …` / `GraalVM CE
25.3.4.1+1.1`: another GraalVM prints other lines (its vendor, its version, its counts), so the captures could not match, and the
script says so at once rather than after three native builds. The published captures were made with **GraalVM CE 25.3.4.1**,
the build Course 3 pinned (`graal-25.3.4.1`), downloaded with Vivek's approval on 2026-10-05 and checked against its published
sha256; it sits in the author's home folder, outside any system location. The Oracle GraalVM on the same Mac was not used. The
GraalVM's folder is never printed: every capture masks it as `$GRAALVM_HOME` (`gsub`, before the home folder's own mask), and
the last checks fail if a capture holds an absolute path. Nothing on the JVM side uses the GraalVM: every Maven run and every
`java` here is the plain JDK 25.0.4.1 (`JAVA_HOME`); only `native-image` comes from `GRAALVM_HOME`.

**Without a GraalVM** (`GRAALVM_HOME` not set — RED #82): `receipts.sh` still runs. It says so at once, fills `.m2-demo` (its first
build), makes every capture that needs no GraalVM — `change`, `generated`, `onjvm`, `frozen`, `async`, `ladder` — and the exercise's,
each checked against `receipts.md5` as always, and then stops where the native build would start, naming this section (exit 1). A
viewer with only a JDK can therefore fill `.m2-demo` and do the exercise. Set to anything that is not GraalVM CE 25.3.4.1, the variable
is still refused at once. Tested on a fresh clone (*Found on the way*).

## The repository, and what was downloaded

Every build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen and in the script): a copy of
`../c5-unit17/.m2-demo` plus the Section 3 seed `spring-boot/_research/m2-seed-s3/` (`rsync --ignore-existing`, without either's
`com/tiffinbox/`). Neither held GraalVM's plugin: the first build of the native profile, online once on 2026-10-05, downloaded
**54 files, 12,069,367 bytes, all from Maven Central** — native-maven-plugin 1.1.8 and what it needs, and GraalVM's
reachability metadata repository (a zip, read by the plugin's `add-reachability-metadata` and by `native:compile-no-fork`):

| artifact | files | bytes |
|---|---|---|
| `com.ethlo.time:itu:1.10.2` | jar+pom | 71796 |
| `com.fasterxml.jackson.core:jackson-annotations:2.17.1` | pom | 7059 |
| `com.fasterxml.jackson.core:jackson-annotations:2.17.2` | jar+pom | 85551 |
| `com.fasterxml.jackson.core:jackson-core:2.17.1` | pom | 9641 |
| `com.fasterxml.jackson.core:jackson-core:2.17.2` | jar+pom | 591568 |
| `com.fasterxml.jackson.core:jackson-databind:2.17.1` | pom | 21262 |
| `com.fasterxml.jackson.core:jackson-databind:2.17.2` | jar+pom | 1670716 |
| `com.fasterxml.jackson.dataformat:jackson-dataformat-xml:2.17.2` | jar+pom | 136576 |
| `com.fasterxml.jackson.dataformat:jackson-dataformat-yaml:2.17.1` | jar+pom | 58048 |
| `com.fasterxml.jackson.dataformat:jackson-dataformats-text:2.17.1` | pom | 3477 |
| `com.fasterxml.jackson:jackson-base:2.17.1` | pom | 11768 |
| `com.fasterxml.jackson:jackson-base:2.17.2` | pom | 11768 |
| `com.fasterxml.jackson:jackson-bom:2.17.1` | pom | 18694 |
| `com.fasterxml.woodstox:woodstox-core:6.7.0` | jar+pom | 1630166 |
| `com.fasterxml:oss-parent:55` | pom | 23564 |
| `com.github.openjson:openjson:1.0.13` | jar+pom | 36721 |
| `com.github.package-url:packageurl-java:1.5.0` | jar+pom | 28742 |
| `com.networknt:json-schema-validator:1.5.1` | jar+pom | 591739 |
| `org.apache.commons:commons-lang3:3.15.0` | pom | 31259 |
| `org.apache.maven:maven-parent:26` | pom | 39785 |
| `org.apache.maven:maven:3.3.1` | pom | 23383 |
| `org.codehaus.plexus:plexus-utils:3.0.24` | jar+pom | 251478 |
| `org.codehaus.woodstox:stax2-api:4.2.2` | jar+pom | 202219 |
| `org.cyclonedx:cyclonedx-core-java:9.0.5` | jar+pom | 2401470 |
| `org.cyclonedx:cyclonedx-maven-plugin:2.9.1` | jar+pom | 70886 |
| `org.graalvm.buildtools:graalvm-reachability-metadata:1.1.8` | zip+jar+pom | 3430758 |
| `org.graalvm.buildtools:native-maven-plugin:1.1.8` | jar+pom | 143324 |
| `org.graalvm.buildtools:utils:1.1.8` | jar+pom | 56360 |
| `org.slf4j:slf4j-api:2.0.13` | pom | 2826 |
| `org.slf4j:slf4j-bom:2.0.13` | pom | 7332 |
| `org.slf4j:slf4j-parent:2.0.13` | pom | 13366 |
| `org.twdata.maven:mojo-executor-parent:2.4.1` | pom | 14410 |
| `org.twdata.maven:mojo-executor:2.4.1` | jar+pom | 16047 |
| `org.yaml:snakeyaml:2.2` | jar+pom | 355608 |

Since then every build here is offline (`offline: yes` on the terminal and in the captures; a run that went online would change
a capture's hash, and `cap()` would stop). Every `_remote.repositories` marker says `central`. The native build itself downloads
nothing — while the metadata repository is in `.m2-demo` (below). **The plugin is now part of every build of the web module:** Boot's parent declares it with `<extensions>true</extensions>`,
so a plain `mvn -o package` resolves it too (measured: a plain offline build of `after/` against a repository without the plugin stops at once — *Found on the way*).

**One way out is not Maven's (RED #81).** GraalVM's plugin reads its metadata repository — the zip above — from the Maven repository,
and when the zip is not there it does **not** fail, even under `-o`: it logs `Unable to find the GraalVM reachability metadata
repository in Maven repository. Falling back to the default repository.` and downloads `graalvm-reachability-metadata-1.0.9.zip` from
**GitHub** into `target/` (so every `clean` build fetches it again); with GitHub unreachable the build fails, `Failed to download from
https://github.com/…`. github.com is outside the course's network tier, so `receipts.sh` never lets that happen silently: (1) the first
build is the README's native install, which needs every artifact any capture's Maven line needs, the zip included — on a fresh clone
it fills `.m2-demo` from Maven Central, once; (2) a native-profile build while the zip is not in `.m2-demo` goes to Maven Central at once
(`offline: no - GraalVM's metadata repository was not in .m2-demo, so Maven Central was asked for it`), never offline first; (3) after
the first build the script checks the zip is in `$M2`, beside Boot's parent and the plugin; (4) every build's log — the native build's
too — is searched for the plugin's own download line (`Downloaded GraalVM reachability metadata repository from http…`, `Failed to
download from http…`): found, the build's line says `offline: no`, and the run stops. Measured 2026-10-06 (BLUE's probe, three builds
of `after/`, `-Pnative -DskipTests clean install`, against a copy of `.m2-demo` without the zip and a mirror of Central made from the
same files): online → `Downloaded from central: …graalvm-reachability-metadata-1.1.8-repository.zip (3.4 MB …)`, the plugin read it from
the repository, exit 0, no GitHub line; online with every HTTPS proxy refused (GitHub unreachable) → the same, exit 0; offline, no zip,
GitHub unreachable → `Failed to download from https://github.com/oracle/graalvm-reachability-metadata/releases/download/1.0.9/…`,
`BUILD FAILURE` — the line step (4) catches. The exercise's README says the same: run `./receipts.sh` once first.

## The demo token — fake, and never printed

TiffinBox does not start without its shutdown token (the secrets lesson). Every run starts in a folder under `.harness/` that
holds a config tree, `secrets/tiffinbox/shutdown-token` (`-rw-------`, folders `drwx------`), with a 26-character demo token that
is fake and looks it; `receipts.sh` writes it when it runs (`.harness/` is git-ignored). The token never reaches a command line:
the seven requests read it from the file (`$CURLSET PORT TOKENFILE`), and so does `harness/ttfr.py`. Every capture is masked —
the token becomes `[masked: the 26-character token]` (`gsub`) — and `receipts.sh` counts the raw token in each run's own output
**before** masking (`.harness/raw-*`: 0 in all 24 capture runs), then in every capture, this README, the exercise, the harness,
`receipts.md5` — and in the **native binary's bytes** (`native`: `the demo token in its bytes: 0`, every build): the binary reads
the token from the config tree when it runs, so no build ever sees it. The builder counts it again in the script, the deck and
the prompter: 0. The exercise makes no token of its own: it builds and reads a file, and starts nothing.

## The folders, the variables and the ports

- `.harness/before/` — the previous tree, `../c5-unit17/after`, copied; `.harness/plain-*` and `.harness/np-*` are its and
  `after/`'s copies for `change`'s four builds.
- `.harness/after/` — `after/` copied, built with the profile `native` (the AOT jar), extracted with the README's command; its
  `secrets/` is the token's config tree. `onjvm`, `frozen`, `async` and `ladder` run here.
- `.harness/built-on/` — `after/` again, built the same way with the switch on while `process-aot` ran (`frozen` C).
- `.harness/gen/` — `generated`'s copy, rebuilt in every run of that capture. `.harness/native/` — `native`'s copy, rebuilt in
  every run (both modules installed into `$M2`, then the binary). `.harness/mine/` — the exercise's.
- `.harness/classes/` — the harness, `harness/aot/Frozen.java` and `Calls.java`, compiled against `.harness/after`'s extracted jar.
  Package `aot`, outside `com.tiffinbox`, so TiffinBoxApp's component scan never finds it. `Frozen` starts TiffinBoxApp's context
  with **`setMainApplicationClass(TiffinBoxServer.class)`** — in AOT mode Spring starts the context from the code generated for
  the main class, `TiffinBoxServer__ApplicationContextInitializer`, and looks it up by that class's name; it registers nothing of
  its own. `Calls` is an application of its own (TiffinBoxApp imported, `@EnableAsync`, one `@Async` method), so it is processed
  ahead of time on its own, into `.harness/calls/`, by the class `process-aot` runs.
- On screen: `$CURLSET` = `../c5-unit11/curlset.sh`, the comparison set since the secrets lesson — its folder carries a unit
  number, so no slide prints the path; `$M2` = this unit's `.m2-demo`; `$GRAALVM_HOME` = the GraalVM (above). Every other command
  is printed whole.
- Ports (brief ⚑10, 18900-18909, checked free with `lsof` before anything is wiped, 18425 too): `onjvm` 18900 (A, A′), 18901 (B),
  its harness 18902 (A, A′), 18903 (B) · `frozen` 18904 (A, A′), 18905 (B), 18906 (C) · `async` 18907 (A, A′), 18908 (B) · `ladder`
  18909 (the three training runs, which start the server during the refresh, and all 36 timed starts) · `native` 18909 (the binary,
  which stops before it binds). The exercise binds nothing.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM and the token:** in every line of every capture (`gsub()`, the patterns escaped as literals): the demo
   token → `[masked: the 26-character token]`; the GraalVM's folder → `$GRAALVM_HOME`; this folder's absolute path → `…` (also
   URL-encoded); the folder above it → `…/..`; the home folder → `~`; the user name → `<user>`. A last check fails if any capture
   still holds `/Users/`, `/private/` or `/home/`, and the builder refuses a capture that holds a unit number.
2. **Boot's log** is counted, never printed whole: its line count and its WARN and ERROR lines. Its first line is printed from
   its message on and cut before ` with PID` (the PID and the folder that follow move).
3. **Maven's logs** are read, never printed whole: the goals it ran on `tiffinbox-web` (its own `--- … @ tiffinbox-web ---` lines),
   its `offline`/`exit` line, and named lines of `add-reachability-metadata`'s log, each counted; every build's log — the native
   build's too — is searched for the plugin's metadata-repository download line (*The repository*). The GraalVM's mask (1) is
   skipped when `GRAALVM_HOME` is not set.
4. **native-image's log**, in `native`: the plugin's goal line and the line naming the GraalVM it found, the builder's Java line,
   its warnings (the file URL in the first cut to `'…'`), the eight stage names (their timings and memory cut by `sub`), the
   analysis's "found reachable" line, the warning count and `BUILD SUCCESS`; the rest counted. Its class path is read from the
   plugin's own command line, as jar names only.
5. **What is never captured, and why** — the native build is not byte-for-byte reproducible here, so only what held in every
   build is hashed (*The native build, deterministic and not*). No duration is captured: the ladder prints each way's median
   (the middle of its five counted runs) — the executable jar's against a floor, every other way's against the executable jar's, as a
   ratio: a median, so one busy moment cannot move it — the native build its
   duration against a bound (1 minute or more, under 10), and the seconds go to the terminal (quoted in this README as ranges, measured). The AOT cache's size in bytes is cut.
6. **Hygiene:** `receipts.sh` unsets every `TIFFINBOX_*` and `SPRING_*` variable, `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`,
   `MAVEN_OPTS`, `MAVEN_ARGS` and `NATIVE_IMAGE_OPTIONS` before it runs anything; it refuses to run twice at once in this folder
   (`.r-lock`), with a `secrets/` in this folder, or with a `secrets/`, a `tiffinbox-local.yaml` or a `target/` in `after/`
   (it is never built in place).

**Interrupted.** `receipts.sh`'s exit trap stops the process it started in the background (a TiffinBox jar, the binary, a harness), if one
still runs, and drops the lock — on a failed check and on Ctrl-C alike (a background job of a non-interactive shell ignores the
terminal's Ctrl-C). Maven, native-image and `harness/ttfr.py` run in the foreground: Ctrl-C reaches them directly, and `ttfr.py`
kills the JVM it forked before it exits. Every command in the trap is guarded, so `set -e` cannot end it early, and `$pid` is cleared
after every reap. **Tested 2026-10-06**, with `receipts.sh` as a job of its own process group (job control on, as a terminal's
foreground job is) and `SIGINT` sent to the whole group the moment native-image's builder JVM was in its third stage (`native`, the
first of its three builds; at that moment 1 native-image launcher, 1 builder JVM and 1 Maven ran): **exit 130**; 5 s later 0
native-image processes, 0 builder JVMs, 0 Maven, 0 TiffinBox or harness processes, 0 listeners on 18425 and 18900-18909, and `.r-lock`
gone. (Two earlier, unplanned interrupts — one during `change`'s Maven builds, one just after `native` — left nothing behind either.)
Since BLUE part C the trap also `sweep()`s this run's process group, as the next unit's does: anything of a native build still alive —
native-image's driver (in `$GRAALVM_HOME/bin`), its builder JVM (`java @…/vminvocation.args`, no class name to look for) or a TiffinBox
binary under `.harness/` — gets TERM, then KILL after 5 s. **Re-tested 2026-10-06 after that change**, the same way: `SIGINT` to the
group 20 s after the first native build's builder JVM appeared (369 s into the run; in the group, 5 processes: 1 Maven, 1 native-image
driver, 1 builder JVM among them): **exit 130**; 5 s later 0 processes in the group, and anywhere 0 native-image drivers, 0 builder
JVMs, 0 Maven, 0 TiffinBox binaries or jars, 0 listeners on 18425 and 18900-18909, `.r-lock` gone, no partial capture file left — and the
six captures made before the interrupt still equal to `receipts.md5`.

## The native build, deterministic and not

Two clean native builds of the same tree, on 2026-10-05 (a scratch copy, by hand, before this script existed), and the three in
every run of `native` since: the **binary's bytes differ** from build to build (two md5s, `62e36cb4…` and `7bfa66ec…`), and so do
two counts native-image prints — the methods registered for reflection (3,838 and 3,859) and the objects in the image heap
(387,868 and 387,878). What held in every build is what `native` hashes: the plugin's and the builder's version lines, the two
warnings, the eight stages, the analysis's line (`19,027 types, 27,275 fields, and 90,458 methods found reachable`), the warning
count, `BUILD SUCCESS`, the exit code, the binary's type (`file`), the files written beside it, the jars on native-image's class
path, the token count in the binary's bytes, and everything the binary printed. Its duration is counted against a bound: **1
minute or more, under 10 minutes** — 113-140 s over the 21 native builds of seven full runs on 2026-10-05/06, and 113-176 s over the 9
of BLUE part C's three full runs on 2026-10-06 (the runs of record: 118-133 s under `bash receipts.sh`, 174-176 s under `./receipts.sh`
on the warm Mac). The binary's size is not printed and not compared: Course 3 refused size
comparisons, and so does Section 3's rule S3.14.

## 1 · change — the previous tree against after/

`diff -rq` of the two trees (copied, `target/` and `secrets/` left out): two files — the anchor README (this lesson's
section) and `tiffinbox-web/pom.xml`, whose new lines are the plugin's four, with no `<version>`; Boot's parent manages it
(`spring-boot-dependencies-4.1.1.pom`). Both trees built the plain way: the executable jars have the same 170 entry names, 169 with the
same content — the one that differs is `META-INF/maven/com.tiffinbox/tiffinbox-web/pom.xml`, the copy of the POM Maven puts in every jar.
Both built with the profile `native`: `process-aot` runs on both (Boot's parent binds it); `add-reachability-metadata` only once the plugin
is declared — in Maven's order, before `process-aot`.

`.r-change.out` · md5 `bcaa8b3fac6ff735c0bc718570b0de1a` · 3 of 3

```
the previous tree - the anchor as the Compose lesson left it - against after/, both copied under .harness/:
$ diff -rq -x target -x secrets .harness/before .harness/after
  Files .harness/before/README.md and .harness/after/README.md differ
  Files .harness/before/tiffinbox-web/pom.xml and .harness/after/tiffinbox-web/pom.xml differ
after/'s tiffinbox-web/pom.xml against the previous one - every line diff adds, its comment lines counted, not shown:
        <plugin>
          <groupId>org.graalvm.buildtools</groupId>
          <artifactId>native-maven-plugin</artifactId>
        </plugin>
  lines diff removes: 0 · adds: 10 - not shown: a comment of 5 lines, and 1 blank
Boot's parent, the version it manages for that plugin (spring-boot-dependencies-4.1.1.pom, in $M2):
  <native-build-tools-plugin.version>1.1.8</native-build-tools-plugin.version>
both trees, built the plain way - the README's Maven line, offline, clean, each in a copy of its own:
$ cd .harness/plain-before && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the previous tree · offline: yes · exit 0
$ cd .harness/plain-after && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built after/ · offline: yes · exit 0
  the two executable jars, entry by entry: entries 170 and 170 · the same name and content (CRC-32): 169 · different: 1 - META-INF/maven/com.tiffinbox/tiffinbox-web/pom.xml
both trees, built with Boot's profile native - the README's line, offline, clean:
$ cd .harness/np-before && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean package
  built the previous tree · offline: yes · exit 0
$ cd .harness/np-after && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean package
  built after/ · offline: yes · exit 0
  the goals each ran on tiffinbox-web that the plain build did not (Maven's own lines):
  the previous tree: spring-boot:4.1.1:process-aot (process-aot)
  after/: native:1.1.8:add-reachability-metadata (add-reachability-metadata) · spring-boot:4.1.1:process-aot (process-aot)
```

## 2 · generated — what process-aot wrote

A copy of `after/`, rebuilt in each of the three runs. The build runs on Homebrew's OpenJDK (`mvn -version`); `process-aot`
starts TiffinBox's `main` to read its configuration — Boot's banner and first line are in Maven's log — and never starts the server (0
`TiffinBox listening` lines). It wrote 35 Java files (9 for TiffinBox's own classes), 45 class files (the proxy and the compiled sources:
`target/spring-aot/main/classes/`) and 2 resources. `TiffinBoxServer__BeanDefinitions.java` is shown without its blank lines. The JSON is read
with `python3`: its keys, TiffinBox's 9 entries with what each allows, and two classes it does not name. `add-reachability-metadata`'s own
log names the GraalVM repository version and, per jar, the directory it took — for 20 jars an older version's.

`.r-generated.out` · md5 `6a9b4e051aa732db7ecb90dc6d4a6408` · 3 of 3

```
after/, copied to .harness/gen, built with Boot's profile native - the README's line, offline, clean, on the plain JDK:
$ cd .harness/gen && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean package
  built .harness/gen · offline: yes · exit 0
  the JDK Maven ran on (mvn -version): Java version: 25.0.4.1 · a native-image in it: no
  the goals Maven ran on tiffinbox-web (its own lines; the rest of its log - 142 lines - not shown):
    clean:3.5.0:clean (default-clean)
    native:1.1.8:add-reachability-metadata (add-reachability-metadata)
    resources:3.5.0:resources (default-resources)
    compiler:3.15.0:compile (default-compile)
    resources:3.5.0:testResources (default-testResources)
    compiler:3.15.0:testCompile (default-testCompile)
    surefire:3.5.6:test (default-test)
    spring-boot:4.1.1:process-aot (process-aot)
    jar:3.5.0:jar (default-jar)
    spring-boot:4.1.1:repackage (repackage)
  process-aot ran TiffinBox's main to read its configuration - Boot's first line in the build's log: Starting TiffinBoxServer using Java 25.0.4.1 · lines saying TiffinBox listening: 0
what process-aot wrote, tiffinbox-web/target/spring-aot/main/:
  sources/: 35 Java files · TiffinBox's own, under com/tiffinbox/: 9
    com/tiffinbox/CustomerRepository__BeanDefinitions.java
    com/tiffinbox/Dashboard__BeanDefinitions.java
    com/tiffinbox/Database__BeanDefinitions.java
    com/tiffinbox/OrderQueue__BeanDefinitions.java
    com/tiffinbox/TiffinBoxProperties__BeanDefinitions.java
    com/tiffinbox/web/TiffinBoxApp__BeanDefinitions.java
    com/tiffinbox/web/TiffinBoxServer__ApplicationContextInitializer.java
    com/tiffinbox/web/TiffinBoxServer__BeanDefinitions.java
    com/tiffinbox/web/TiffinBoxServer__BeanFactoryRegistrations.java
  classes/: 45 files · resources/: 2 files
    resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/native-image.properties
    resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json
one of TiffinBox's own, whole: sources/com/tiffinbox/web/TiffinBoxServer__BeanDefinitions.java (35 lines; its blank lines not shown)
  | package com.tiffinbox.web;
  | import com.tiffinbox.CustomerRepository;
  | import com.tiffinbox.Dashboard;
  | import com.tiffinbox.OrderQueue;
  | import com.tiffinbox.TiffinBoxProperties;
  | import org.springframework.aot.generate.Generated;
  | import org.springframework.beans.factory.aot.BeanInstanceSupplier;
  | import org.springframework.beans.factory.config.BeanDefinition;
  | import org.springframework.beans.factory.support.RootBeanDefinition;
  | /**
  |  * Bean definitions for {@link TiffinBoxServer}.
  |  */
  | @Generated
  | public class TiffinBoxServer__BeanDefinitions {
  |   /**
  |    * Get the bean instance supplier for 'tiffinBoxServer'.
  |    */
  |   private static BeanInstanceSupplier<TiffinBoxServer> getTiffinBoxServerInstanceSupplier() {
  |     return BeanInstanceSupplier.<TiffinBoxServer>forConstructor(CustomerRepository.class, Dashboard.class, OrderQueue.class, TiffinBoxProperties.class)
  |             .withGenerator((registeredBean, args) -> new TiffinBoxServer(args.get(0), args.get(1), args.get(2), args.get(3)));
  |   }
  |   /**
  |    * Get the bean definition for 'tiffinBoxServer'.
  |    */
  |   public static BeanDefinition getTiffinBoxServerBeanDefinition() {
  |     RootBeanDefinition beanDefinition = new RootBeanDefinition(TiffinBoxServer.class);
  |     beanDefinition.setInitMethodNames("start");
  |     beanDefinition.setDestroyMethodNames("stop");
  |     beanDefinition.setInstanceSupplier(getTiffinBoxServerInstanceSupplier());
  |     return beanDefinition;
  |   }
  | }
resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/native-image.properties, whole:
  | Args = -H:Class=com.tiffinbox.web.TiffinBoxServer \
  | --no-fallback
resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json, read as JSON (python3):
  its top-level keys: comment "Spring Framework 7.0.9" · reflection 262 entries · resources 16 entries
  reflection entries naming com.tiffinbox: 9
    com.tiffinbox.CustomerRepository
    com.tiffinbox.Dashboard
    com.tiffinbox.Database · methods createAndSeed
    com.tiffinbox.MealType · allDeclaredFields · methods <init>
    com.tiffinbox.OrderQueue · allDeclaredFields · methods close
    com.tiffinbox.TiffinBoxProperties · allDeclaredFields · methods <init>
    com.tiffinbox.web.TiffinBoxApp
    com.tiffinbox.web.TiffinBoxServer · allDeclaredFields · methods start stop
    com.tiffinbox.web.TiffinBoxServer__ApplicationContextInitializer · methods <init>
  entries for com.tiffinbox.Customer: 0
  entries for com.tiffinbox.web.Route: 0
  files named reflect-config.json anywhere under .harness/gen: 0
the jar it packaged: its manifest says Spring-Boot-Native-Processed: true · its entries whose name ends __BeanDefinitions.class: 33
what the plugin's add-reachability-metadata added, by its own log (50 lines, counted):
  Using GraalVM reachability metadata repository version 1.0.9
  reachability-metadata.json files it put under target/classes/META-INF/native-image/, beside Spring's: 25
  jars it found no entry for at their own version, so it took an older one's: 20 - H2's: com.h2database:h2:2.5.250 -> com.h2database/h2/2.1.210
```

## 3 · onjvm — the AOT jar on the JVM, and the definitions

A, B, A′: the jar `.harness/after` holds (built with the profile `native`), run as the anchor README says, then with
`-Dspring.aot.enabled=true`, then as A again. B's first line says `AOT-processed`; the seven responses are `115c36ba…` all three times. The
harness `aot.Frozen` (TiffinBoxApp's context, main application class TiffinBoxServer) counts the context's bean definitions, A, B, A′, and
lists the names in A and not in B: the configuration-class post-processor, the autowired one, the common-annotation one (Course 4's finale
took each out by hand), and Boot's `internalCachingMetadataReaderFactory`.

`.r-onjvm.out` · md5 `18400959df18d7436873b750bbd28b4b` · 3 of 3

```
the jar process-aot left in .harness/after (README's native-profile build), on the JVM:
A - as the README runs it, its port 18431 made 18900:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18900
  listens on: 127.0.0.1:18900 · WARN lines 0 · ERROR lines 0
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ $CURLSET 18900 .harness/after/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
B - the README's AOT run, -Dspring.aot.enabled=true, port 18901:
$ cd .harness/after && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18901
  listens on: 127.0.0.1:18901 · WARN lines 0 · ERROR lines 0
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ $CURLSET 18901 .harness/after/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
A' - A re-run:
$ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18900
  listens on: 127.0.0.1:18900 · WARN lines 0 · ERROR lines 0
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ $CURLSET 18900 .harness/after/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
the harness (harness/aot/Frozen.java): TiffinBox's context, its main application class TiffinBoxServer, its bean definitions counted:
A - the JVM, port 18902:
$ cd .harness/after && java -cp "../classes:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" aot.Frozen --tiffinbox.port=18902
spring.aot.enabled, the system property: (not set)
the switch, as the environment holds it: spring.threads.virtual.enabled = (not set)
Boot's executor, the bean applicationTaskExecutor: org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor
20 tasks -> distinct threads 8 · virtual [false]
the context's bean definitions: 59
  (the definitions' names: 59 lines, not shown)
  Boot's log (standard output): 18 lines, not shown · WARN lines 0 · ERROR lines 0 · exit 0 · listening on 18902 now: 0
B - -Dspring.aot.enabled=true, port 18903:
$ cd .harness/after && java -Dspring.aot.enabled=true -cp "../classes:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" aot.Frozen --tiffinbox.port=18903
spring.aot.enabled, the system property: true
the switch, as the environment holds it: spring.threads.virtual.enabled = (not set)
Boot's executor, the bean applicationTaskExecutor: org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor
20 tasks -> distinct threads 8 · virtual [false]
the context's bean definitions: 55
  (the definitions' names: 55 lines, not shown)
  Boot's log (standard output): 18 lines, not shown · WARN lines 0 · ERROR lines 0 · exit 0 · listening on 18903 now: 0
A' - A re-run, port 18902:
$ cd .harness/after && java -cp "../classes:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" aot.Frozen --tiffinbox.port=18902
spring.aot.enabled, the system property: (not set)
the switch, as the environment holds it: spring.threads.virtual.enabled = (not set)
Boot's executor, the bean applicationTaskExecutor: org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor
20 tasks -> distinct threads 8 · virtual [false]
the context's bean definitions: 59
  (the definitions' names: 59 lines, not shown)
  Boot's log (standard output): 18 lines, not shown · WARN lines 0 · ERROR lines 0 · exit 0 · listening on 18902 now: 0
  definitions in A and not in B: 4 · in B and not in A: 0 · A' against A: the same names
    org.springframework.boot.autoconfigure.internalCachingMetadataReaderFactory
    org.springframework.context.annotation.internalAutowiredAnnotationProcessor
    org.springframework.context.annotation.internalCommonAnnotationProcessor
    org.springframework.context.annotation.internalConfigurationAnnotationProcessor
```

## 4 · frozen — the break: a setting decided at build time (A/B/A′, and C)

The harness with `--spring.threads.virtual.enabled=true` after the port: A on the JVM → `SimpleAsyncTaskExecutor`, twenty tasks on
twenty virtual threads; B with `-Dspring.aot.enabled=true` → the environment still says `true · from commandLineArgs`, and Boot's executor
is `ThreadPoolTaskExecutor`, eight platform threads — Boot's log has 0 WARN and 0 ERROR lines; A′ = A. C: a second copy, built with the
switch on while `process-aot` ran (`-Dspring-boot.aot.jvmArguments=…`), run with AOT and **without** the switch → `SimpleAsyncTaskExecutor`,
twenty virtual threads. Then the generated code itself: in each tree, the one bean method that makes `applicationTaskExecutor`
(`bean methods named for it: 1`). And why (RED #85): Boot's own class, read with `javap -v`, gives each of its two candidates a
condition — `applicationTaskExecutorVirtualThreads` `@ConditionalOnThreading(VIRTUAL)`, `applicationTaskExecutor`
`@ConditionalOnThreading(PLATFORM)`. `process-aot` evaluated the condition while it built the jar, and wrote down only the winner.

`.r-frozen.out` · md5 `d71f6fc99039576076ea08056328a84f` · 3 of 3

```
the harness again, the switch on after the port - spring.threads.virtual.enabled=true:
A - the JVM, the switch on, port 18904:
$ cd .harness/after && java -cp "../classes:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" aot.Frozen --tiffinbox.port=18904 --spring.threads.virtual.enabled=true
spring.aot.enabled, the system property: (not set)
the switch, as the environment holds it: spring.threads.virtual.enabled = true · from commandLineArgs
Boot's executor, the bean applicationTaskExecutor: org.springframework.core.task.SimpleAsyncTaskExecutor
20 tasks -> distinct threads 20 · virtual [true]
the context's bean definitions: 59
  (the definitions' names: 59 lines, not shown)
  Boot's log (standard output): 18 lines, not shown · WARN lines 0 · ERROR lines 0 · exit 0 · listening on 18904 now: 0
B - the same, -Dspring.aot.enabled=true, port 18905:
$ cd .harness/after && java -Dspring.aot.enabled=true -cp "../classes:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" aot.Frozen --tiffinbox.port=18905 --spring.threads.virtual.enabled=true
spring.aot.enabled, the system property: true
the switch, as the environment holds it: spring.threads.virtual.enabled = true · from commandLineArgs
Boot's executor, the bean applicationTaskExecutor: org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor
20 tasks -> distinct threads 8 · virtual [false]
the context's bean definitions: 55
  (the definitions' names: 55 lines, not shown)
  Boot's log (standard output): 18 lines, not shown · WARN lines 0 · ERROR lines 0 · exit 0 · listening on 18905 now: 0
A' - A re-run:
$ cd .harness/after && java -cp "../classes:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" aot.Frozen --tiffinbox.port=18904 --spring.threads.virtual.enabled=true
spring.aot.enabled, the system property: (not set)
the switch, as the environment holds it: spring.threads.virtual.enabled = true · from commandLineArgs
Boot's executor, the bean applicationTaskExecutor: org.springframework.core.task.SimpleAsyncTaskExecutor
20 tasks -> distinct threads 20 · virtual [true]
the context's bean definitions: 59
  (the definitions' names: 59 lines, not shown)
  Boot's log (standard output): 18 lines, not shown · WARN lines 0 · ERROR lines 0 · exit 0 · listening on 18904 now: 0
C - a second copy, .harness/built-on, built with the switch on while process-aot ran; run with AOT, the switch not set, port 18906:
$ cd .harness/built-on && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean package -Dspring-boot.aot.jvmArguments=-Dspring.threads.virtual.enabled=true
$ cd .harness/built-on && java -Dspring.aot.enabled=true -cp "../classes:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" aot.Frozen --tiffinbox.port=18906
spring.aot.enabled, the system property: true
the switch, as the environment holds it: spring.threads.virtual.enabled = (not set)
Boot's executor, the bean applicationTaskExecutor: org.springframework.core.task.SimpleAsyncTaskExecutor
20 tasks -> distinct threads 20 · virtual [true]
the context's bean definitions: 55
  (the definitions' names: 55 lines, not shown)
  Boot's log (standard output): 18 lines, not shown · WARN lines 0 · ERROR lines 0 · exit 0 · listening on 18906 now: 0
the code process-aot generated for Boot's executor, sources/org/springframework/boot/autoconfigure/task/TaskExecutorConfigurations__BeanDefinitions.java:
  .harness/after - the bean applicationTaskExecutor comes from: the bean method applicationTaskExecutor, type ThreadPoolTaskExecutor · bean methods named for it: 1
  .harness/built-on - the bean applicationTaskExecutor comes from: the bean method applicationTaskExecutorVirtualThreads, type SimpleAsyncTaskExecutor · bean methods named for it: 1
the condition on each candidate, in Boot's own class - javap -v, TaskExecutorConfigurations$TaskExecutorConfiguration, in $M2's spring-boot-autoconfigure-4.1.1.jar:
  the bean method applicationTaskExecutorVirtualThreads · @ConditionalOnThreading(VIRTUAL)
  the bean method applicationTaskExecutor · @ConditionalOnThreading(PLATFORM)
```

## 5 · async — @Async under AOT

The question unit 18 left (BLUE part B): which executor does an `@Async` method get under AOT? TiffinBox has no `@Async`, so
the harness `aot.Calls` is an application of its own — TiffinBoxApp imported, `@EnableAsync`, one `@Async` method of 100 ms — processed
ahead of time by `org.springframework.boot.SpringApplicationAotProcessor`, the class `process-aot` runs (its arguments: the main class,
then where to write sources, resources and classes, then a group and an artifact name), its sources compiled with `javac`. With the switch
on: twenty calls on twenty virtual threads on the JVM (A, A′), on eight platform threads under AOT (B) — Boot's executor, frozen.

`.r-async.out` · md5 `30c9c5e388645d010fa8635276ac7143` · 3 of 3

```
the harness with an @Async method (harness/aot/Calls.java) is its own application: processed ahead of time by the class process-aot runs,
Boot's SpringApplicationAotProcessor (its main class, then where to write sources, resources and classes, then a group and an artifact name):
$ cd .harness/after && java -cp "../classes:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" org.springframework.boot.SpringApplicationAotProcessor aot.Calls ../calls/sources ../calls/resources ../calls/classes com.tiffinbox harness
  exit 0 · Boot's log: 12 lines, not shown · written: 38 Java files · 2 class files (proxy classes, made by the processor) · 2 resources
$ javac -cp ".harness/calls/classes:.harness/classes:.harness/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:.harness/after/tiffinbox-web/target/extracted/lib/*" -d .harness/calls/classes $(find .harness/calls/sources -name '*.java')
  exit 0 · .harness/calls/classes now: 50 classes
A - the JVM, the switch on, port 18907:
$ cd .harness/after && java -cp "../calls/classes:../calls/resources:../classes:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" aot.Calls --tiffinbox.port=18907 --spring.threads.virtual.enabled=true
spring.aot.enabled, the system property: (not set)
Boot's executor, the bean applicationTaskExecutor: org.springframework.core.task.SimpleAsyncTaskExecutor
20 @Async calls -> distinct threads 20 · virtual [true]
  Boot's log (standard output): 18 lines, not shown · WARN lines 0 · ERROR lines 0 · exit 0 · listening on 18907 now: 0
B - -Dspring.aot.enabled=true, the switch on, port 18908:
$ cd .harness/after && java -Dspring.aot.enabled=true -cp "../calls/classes:../calls/resources:../classes:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" aot.Calls --tiffinbox.port=18908 --spring.threads.virtual.enabled=true
spring.aot.enabled, the system property: true
Boot's executor, the bean applicationTaskExecutor: org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor
20 @Async calls -> distinct threads 8 · virtual [false]
  Boot's log (standard output): 18 lines, not shown · WARN lines 0 · ERROR lines 0 · exit 0 · listening on 18908 now: 0
A' - A re-run:
$ cd .harness/after && java -cp "../calls/classes:../calls/resources:../classes:tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:tiffinbox-web/target/extracted/lib/*" aot.Calls --tiffinbox.port=18907 --spring.threads.virtual.enabled=true
spring.aot.enabled, the system property: (not set)
Boot's executor, the bean applicationTaskExecutor: org.springframework.core.task.SimpleAsyncTaskExecutor
20 @Async calls -> distinct threads 20 · virtual [true]
  Boot's log (standard output): 18 lines, not shown · WARN lines 0 · ERROR lines 0 · exit 0 · listening on 18907 now: 0
```

## 6 · ladder — the start, timed from outside

`harness/ttfr.py` forks the command, asks `/kitchen` every 2 ms until the first `200`, then sends POST /shutdown with the
token's header and waits for the exit: the clock starts before the process exists and stops when a client is served — never Boot's
`Started … in` line (P23). Six ways, six rounds, each round the six ways in turn (a busy moment slows them all alike); round 1 is a
warm-up. Three training runs first — `-XX:AOTCacheOutput=…` records a run and writes the cache in one command, `spring.context.exit=onRefresh`
ends the run once the context is refreshed (TiffinBox's server starts during the refresh, so the training binds 18909 briefly); the
cache's size is cut. Way 6 (RED #83) is a cache trained on, and run with, the executable jar itself. The capture prints each way's
median — the middle of its five counted runs (`each way's runs counted: 5 of 6`, computed, RED #92's kind) — a median, because a single
run is at the mercy of whatever else the Mac is doing. It judges **the executable jar against a floor only** (`over 1 s`: the opening's
"over a second") and **every other way against the executable jar's median, as a ratio** (RED #84, #88): on this Mac a JVM's start
moves with the machine's state, and the ratios held while the seconds moved half as much again. The seconds go to the terminal only.
Measured 2026-10-06, the three full runs of this version (rounds 2-6, three captures each; *quiet*: the two `bash receipts.sh` runs;
*warm*: the `./receipts.sh` run, which followed the next unit's fifteen native builds):

| way | medians, quiet | medians, warm | its median ÷ the jar's |
|---|---|---|---|
| 1 the executable jar | 1.175-1.248 s | 1.801-1.860 s | — (the floor: over 1 s) |
| 2 + Spring's AOT | 1.033-1.097 s | 1.482-1.572 s | 82-90 % (under it, over three quarters) |
| 3 the jar extracted | 0.912-0.965 s | 1.258-1.366 s | 70-79 % (under it) |
| 4 extracted + the JDK's AOT cache | 0.430-0.459 s | 0.574-0.623 s | 32-38 % (under half) |
| 5 extracted + the cache + Spring's AOT | 0.345-0.369 s | 0.504-0.516 s | 27-31 % (under half) |
| 6 the executable jar + its own cache | 0.820-0.857 s | 1.145-1.244 s | 63-71 % (under it, over half) |

Single runs of the jar: 1.144-1.940 s. A ceiling on the jar would not have lasted: the old bound, under 2 s, sat 0.14 s above the warm
run's slowest median, and the next unit's ladder, on the same Mac an hour into its native builds, timed the same kind of jar at medians
2.008-2.125 s (RED #88). On this Mac: Apple M1, 8 cores, 16 GB, JDK 25.0.4.1.

`.r-ladder.out` · md5 `c06b6d49a0afa7bb16d006ae7243546d` · 3 of 3

```
the start, timed from outside the JVM: harness/ttfr.py forks the command, asks /kitchen until the first 200, then sends POST /shutdown
with the token. Every way runs from .harness/after, port 18909; 6 rounds, each round the six ways in turn; round 1 is a warm-up, not counted.
first, the README's extract (done in .harness/after already) and three training runs - one command records the run and writes the cache:
$ cd .harness/after && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
$ cd .harness/after && java -XX:AOTCacheOutput=tiffinbox-web/target/plain.aot -Dspring.context.exit=onRefresh -jar tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar --tiffinbox.port=18909
  exit 0 · the JDK's own line: AOTCache creation is complete: tiffinbox-web/target/plain.aot [its size in bytes]
$ cd .harness/after && java -XX:AOTCacheOutput=tiffinbox-web/target/tiffinbox.aot -Dspring.aot.enabled=true -Dspring.context.exit=onRefresh -jar tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar --tiffinbox.port=18909
  exit 0 · the JDK's own line: AOTCache creation is complete: tiffinbox-web/target/tiffinbox.aot [its size in bytes]
$ cd .harness/after && java -XX:AOTCacheOutput=tiffinbox-web/target/jar.aot -Dspring.context.exit=onRefresh -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18909
  exit 0 · the JDK's own line: AOTCache creation is complete: tiffinbox-web/target/jar.aot [its size in bytes]
the six ways:
  1 $ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18909
  2 $ cd .harness/after && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18909
  3 $ cd .harness/after && java -jar tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar --tiffinbox.port=18909
  4 $ cd .harness/after && java -XX:AOTCache=tiffinbox-web/target/plain.aot -jar tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar --tiffinbox.port=18909
  5 $ cd .harness/after && java -XX:AOTCache=tiffinbox-web/target/tiffinbox.aot -Dspring.aot.enabled=true -jar tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar --tiffinbox.port=18909
  6 $ cd .harness/after && java -XX:AOTCache=tiffinbox-web/target/jar.aot -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18909
  every run: a 200, then exit 0 after POST /shutdown: 36 of 36
each way's median, the middle of its counted runs - the executable jar's against a floor, every other way's against the executable
jar's (the seconds go to the terminal, never to this capture):
  each way's runs counted: 5 of 6 - round 1 left out
  1 the executable jar: its median over 1 s: yes
  2 + Spring's AOT: its median under the executable jar's: yes · over three quarters of it: yes
  3 the jar extracted: its median under the executable jar's: yes
  4 extracted + the JDK's AOT cache: its median under half the executable jar's: yes
  5 extracted + the JDK's AOT cache + Spring's AOT: its median under half the executable jar's: yes
  6 the executable jar + the JDK's AOT cache: its median under the executable jar's: yes · over half of it: yes
```

## 7 · native — the native build, the binary, and the root

A copy of `after/` with a config tree beside its README, rebuilt in each of the three runs: the README's two Maven lines,
offline, with `GRAALVM_HOME` set. The lines shown are named in the script; the rest are counted. The binary is checked with `file`, its
bytes searched for the token, the files beside it listed (11 `.dylib`, the JDK's AWT libraries, which native-image copies out of the
GraalVM), and its class path compared with the jar's. Then it is run from beside its config tree, as the README runs it: it never
listens, prints Boot's banner and first line, and exits 1 — the exception Boot names and every `Caused by:` under it, each cut after
the bean it names and the lines between counted (Course 4's rule; RED #89): `tiffinBoxServer`, `customerRepository`, `database`, the
settings record, then GraalVM's refusal on the token-length rule; the frame under that last one that is neither GraalVM's nor the
JDK's is Hibernate Validator's. The native build's line says `offline: yes`: its log holds no download line of the plugin's. The method it could not call is shown from `after/`'s source. C: `native:compile`
from the root, as a single-module project would run it — exit 1 on the parent POM, before any module.

`.r-native.out` · md5 `8e952c5fc5c45c68d87119ff307eaf9b` · 3 of 3

```
after/, copied to .harness/native, a config tree beside its README - the README's two Maven lines, offline; $GRAALVM_HOME names the GraalVM:
$ cd .harness/native && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean install
  built .harness/native (both modules, into $M2) · offline: yes · exit 0
$ cd .harness/native && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -pl tiffinbox-web native:compile-no-fork
  its lines, in order (the rest - 138 lines - not shown):
    --- native:1.1.8:compile-no-fork (default-cli) @ tiffinbox-web ---
    Found GraalVM installation from GRAALVM_HOME variable.
    Java version: 25.0.4.1+1, vendor version: GraalVM CE 25.3.4.1+1.1
    Warning: Using a deprecated option --no-fallback from 'META-INF/native-image/com.tiffinbox/tiffinbox-web/native-image.properties' in '…'. No effect, no replacement available
    Warning: Option 'FallbackThreshold' is deprecated and might be removed in a future release: It no longer has any effect, and no replacement is available. Please refer to the GraalVM release notes.
    [1/8] Initializing...
    [2/8] Performing analysis...
    [3/8] Building universe...
    [4/8] Parsing methods...
    [5/8] Inlining methods...
    [6/8] Compiling methods...
    [7/8] Laying out methods...
    [8/8] Creating image...
    19,027 types,  27,275 fields, and  90,458 methods found reachable
    The build process encountered 2 warnings.
    BUILD SUCCESS
  exit 0 · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 10 minutes · offline: yes
the binary, .harness/native/tiffinbox-web/target/tiffinbox-web:
  file: Mach-O 64-bit executable · the demo token in its bytes: 0 · the files native-image wrote beside it: 11 .dylib - libawt libawt_lwawt libfontmanager …
  the jars on native-image's class path (the plugin's command line, names only): 36 · in the executable jar's BOOT-INF/lib: 31 · only on native-image's: jackson-core-3.1.5.jar jackson-databind-3.1.5.jar spring-boot-docker-compose-4.1.1.jar spring-boot-starter-4.1.1.jar spring-boot-starter-logging-4.1.1.jar spring-boot-starter-validation-4.1.1.jar · only in the jar: 1
the binary run, from .harness/native - its config tree beside it - as the README runs it, port 18909:
$ cd .harness/native && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18909
  listened on: nothing
  Boot's banner, its last line: :: Spring Boot ::                (v4.1.1)
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
  then: Application run failed
  the exception it names, then its causes - 4 lines start 'Caused by: ' - each cut after the bean it names, the last after the method; the lines between, counted:
    org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'tiffinBoxServer' …
    … 23 lines not shown …
    Caused by: org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'customerRepository' …
    … 19 lines not shown …
    Caused by: org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'database' …
    … 19 lines not shown …
    Caused by: org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'tiffinbox-com.tiffinbox.TiffinBoxProperties' …
    … 15 lines not shown …
    Caused by: org.graalvm.nativeimage.MissingReflectionRegistrationError: Cannot reflectively invoke method 'public boolean com.tiffinbox.TiffinBoxProperties.isShutdownTokenLongEnough()'.
  its first frame outside GraalVM's own and the JDK's: org.hibernate.validator.internal.util.ReflectionHelper.getValue(ReflectionHelper.java:121)
  exit 1 · listening on 18909 now: 0 · its output: 136 lines, 0 on standard error
  that method, in after/'s tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java (its line and the one above):
    @AssertTrue(message = "tiffinbox.shutdown-token must be 16 characters or more")
    public boolean isShutdownTokenLongEnough() {
C - native:compile from the root, as a single-module project runs it:
$ cd .harness/native && mvn -o -B -Dmaven.repo.local="$M2" -Pnative native:compile
  ran native:compile from the root · offline: yes · exit 1
  the project it ran on first, and its error: org.graalvm.buildtools:native-maven-plugin:1.1.8:compile (default-cli) on project tiffinbox-parent: Image classpath is empty. Check if your classpath configuration is correct.
```

## 8 · exercise — the exercise, run as written

`exercise/README.md`'s four lines, run exactly as written from this folder (Maven `-q` still prints Boot's banner and two
log lines: `process-aot` starts TiffinBox's `main`), then `exercise/solution/SOLUTION.md`'s one line, exactly as written.

`.r-exercise.out` · md5 `87142cc3f9e6e96271336c7f51962f6e` · 3 of 3

```
exercise/README.md's commands, run exactly as written from this folder - 4 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
  $ mvn -o -B -q -f .harness/mine/after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -Pnative -DskipTests clean package
  exit 0 · printed: 9 line(s)
the solution's line (exercise/solution/SOLUTION.md), run exactly as written, from this folder:
$ f=.harness/mine/after/tiffinbox-web/target/spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json; echo "reflection entries naming com.tiffinbox: $(grep -c '"type": "com\.tiffinbox\.' $f) · com.tiffinbox.Customer: $(grep -c '"type": "com\.tiffinbox\.Customer"' $f)"
reflection entries naming com.tiffinbox: 9 · com.tiffinbox.Customer: 0
  exit 0
```


## Exercise

`exercise/README.md`: *"Your turn: count TiffinBox's entries in the generated reachability metadata, then find the class its JSON
needs that is missing."* (20 words, the deck's last slide before the recap card). It builds a copy of `after/` with the Maven
profile `native` — no GraalVM — and leaves the file to the viewer. On a fresh clone `.m2-demo` is empty: `./receipts.sh` fills it
first, and needs no GraalVM to do so (*The GraalVM*; RED #82). Done: `reflection entries naming com.tiffinbox: 9 ·
com.tiffinbox.Customer: 0`. The measured answer, run exactly as written in a clean shell: `exercise/solution/SOLUTION.md`.
`receipts.sh` runs the README's lines and the solution's line exactly as written (`exercise`), and asserts the Done line is a
line of that capture, of the README and of the solution.

## Found on the way

- **The binary stops before the brief's suspects.** The brief named the router (`getDeclaredMethods()` and `invoke`) and Jackson on
  `Customer` as what a native TiffinBox might miss, and predicted nothing. Measured: the binary never gets that far. Binding
  `TiffinBoxProperties`, Boot validates it, and Hibernate Validator calls the token-length rule — `@AssertTrue
  isShutdownTokenLongEnough()`, the secrets lesson's — by reflection; Spring's metadata registers that record's constructor only, so
  GraalVM throws `MissingReflectionRegistrationError` and the context never finishes its refresh (`native`; `generated`: `<init>` only).
- **Three entries make it serve — by hand, in a scratch copy, not a capture (2026-10-05).** With one hand-written
  `META-INF/native-image/com.tiffinbox/hand/reachability-metadata.json` of three entries — `TiffinBoxProperties`'s
  `isShutdownTokenLongEnough`; `TiffinBoxServer`'s five route methods (`customers`, `revenue`, `dashboard`, `kitchen`, `shutdown`);
  `Customer` with `allDeclaredFields`, `allDeclaredConstructors`, `allPublicMethods` — the binary served the seven, `115c36ba…`, and
  started in 0.031-0.035 s from the fork to the first 200 (`ttfr.py`, 6 runs). The next unit re-measures it with real hints.
- **262, not the probe's 260.** `process-aot` runs on Maven's class path, and the Compose lesson's tree carries the optional
  `spring-boot-docker-compose`: its two listeners (`DockerComposeListener` and `DockerComposeServiceConnectionsApplicationListener`, read off
  the file by hand) are registered too. The executable jar does not hold the module; the native binary does (next item).
- **The binary is built from Maven's class path, not from the jar's** (`native`: 36 jars against 31): in addition, the optional
  `spring-boot-docker-compose` with its two Jackson 3 jars, and three starters (`spring-boot-starter`, `-logging`, `-validation` —
  jars with no classes, which Boot's repackage leaves out); missing, `spring-boot-jarmode-tools`, which Boot adds to the jar for
  `-Djarmode=tools`.
- **The plugin is a build extension now.** Boot's parent declares it with `<extensions>true</extensions>`, so every build of the web
  module loads it, profile or not. Measured by hand: a plain `mvn -o -B -DskipTests clean package` of `after/` against a scratch copy
  of `../c5-unit17/.m2-demo` (no plugin in it) stops at once — `Unresolveable build extension: Plugin
  org.graalvm.buildtools:native-maven-plugin:1.1.8 or one of its dependencies could not be resolved`. With network, the first build
  downloads it; offline, a repository needs it.
- **GraalVM's shared metadata is older than TiffinBox's jars.** The repository in the 1.1.8 zip is version 1.0.9; for 20 jars it found no
  directory at their own version and took the newest it had — H2 2.5.250 → 2.1.210 (`generated`), and, from the same log by hand,
  `spring-context` 7.0.9 → 5.3.15, `jackson-databind` 2.22.2 → 2.15.2, `logback-classic` 1.5.38 → 1.5.29.
- **`native:compile` from the root fails on the parent POM** (`native`, C: `Image classpath is empty`) — the third goal in this section
  that must run on the web module alone (the buildpack lesson's `build-image`, the Compose lesson's `process-aot`).
- **Spring's generated `native-image.properties` passes `--no-fallback`**, which GraalVM 25 calls deprecated ("No effect, no replacement
  available"): the native build's two warnings.
- **The training run starts the server.** `spring.context.exit=onRefresh` ends the run once the context is refreshed — and TiffinBox's
  `@PostConstruct` starts its server during the refresh, so a training run binds its port for a moment (`ladder` checks 18909 free after
  each).
- **On the executable jar itself, the cache helps less** — first by hand (4 runs: 0.80-0.93 s, against about 1.2 s without it and about
  0.45 s on the extracted jar), now a capture (RED #83): `ladder`'s way 6, a cache trained on the executable jar and run with it — its
  median under the jar's and **over half of it** (63-71 % of the jar's median over nine captures, against 32-38 % for way 4, the extracted
  jar with its cache, in the same interleaved rounds). So the recap says "with the jar extracted and the JDK's cache". Why the unextracted jar gains less was
  not measured, and nothing on screen says why.
- **GraalVM's plugin goes to GitHub when `.m2-demo` lacks its metadata repository, even under `-o`** (RED #81): *The repository* has the
  three measured builds and the four guards; every build's line now says what its log says.
- **A fresh clone, without a GraalVM, then with one** (RED #82). Tested 2026-10-06 on a `git clone` of the BLUE part C commit into
  `/private/tmp`, every command in an `env -i` shell, Maven pointed at a local mirror of Central made from `.m2-demo` and every HTTP(S)
  proxy at a closed port — so nothing could reach the internet, GitHub included. `./receipts.sh` without `GRAALVM_HOME`: the first
  build went to the mirror at once (`offline: no - GraalVM's metadata repository was not in .m2-demo, so Maven Central was asked for it`;
  468 files, the zip among them; no log line names github.com but native-image's own documentation link), `change`, `generated`,
  `onjvm`, `frozen`, `async`, `ladder` and `exercise` each 3/3 and = published, then the stop naming *The GraalVM* — exit 1, 396 s. The
  exercise's four lines and the solution's line, as written: the Done line. Then `./receipts.sh` with `GRAALVM_HOME`, on the
  `.m2-demo` that first build filled: every build `offline: yes`, all eight captures 3/3 and = published, exit 0, 974 s.
- **The executable jar's start drifts with the Mac** (RED #88): its medians were 1.18-1.25 s in this unit's quiet runs, 1.80-1.86 s in
  its warm one, and 2.01-2.13 s in the next unit's ladder, on the same Mac, an hour into its native builds. So `ladder` judges the executable jar against a floor only ("over 1
  s", the opening's "over a second") and every other way as a ratio of it, measured in the same rounds — a ceiling of 2 s would have
  failed that hour.
- **AWT's libraries beside the binary:** native-image wrote 11 `.dylib` files next to it (the JDK's AWT, font and image libraries —
  `libawt`, `libawt_lwawt`, `libfontmanager` …). The binary did not reach a point where they matter; what pulls AWT in was not measured.
- **`@Async` under AOT runs on the frozen pool** (`async`): the answer to the question the virtual-threads lesson carried here.

## For the next units — 20 — and for RED

**Unit 20 (What Breaks in Native, and the Hints That Fix It) starts from `after/`** — `../c5-tiffinbox` is identical to it
(`diff -rq -x target`, empty on 2026-10-06). What it inherits, measured here:

- **The repository.** Seed `.m2-demo` from this unit's: it holds `native-maven-plugin` 1.1.8, the 33 other artifacts it needs, and
  `graalvm-reachability-metadata-1.1.8-repository.zip` (the table above). Without the plugin even a plain offline build of the anchor
  stops: the plugin is a build extension of every web-module build now (*Found on the way*). Without the zip a native-profile build
  does not stop — the plugin fetches it from GitHub, even under `-o` — so a receipt's first build must need it, and every build log is
  searched for the plugin's download line (*The repository*; RED #81).
- **The GraalVM.** `GRAALVM_HOME` = GraalVM CE 25.3.4.1 (native-image 25.0.4.1); this unit's receipts refuse another. Never print its
  folder: mask it as `$GRAALVM_HOME`, before the home folder's mask (it lives under it).
- **The unhinted binary stops at start** (`native`): `MissingReflectionRegistrationError` on `TiffinBoxProperties.isShutdownTokenLongEnough()`,
  the token-length `@AssertTrue`, called by Hibernate Validator during binding. **⚑9's two hints — `@Reflective` on `Route`,
  `@RegisterReflectionForBinding(Customer.class)` on `TiffinBoxServer` — do not reach that method**: with them alone the binary would
  still stop there (inferred, not built: re-measure). A third registration is needed; the brief's "two lines" become at least three.
  By hand, three hand-written entries made a binary that served `115c36ba…` (*Found on the way*): the router's five methods and `Customer`
  were then enough for the seven.
- **The counts on this tree** (`generated`): 262 reflection entries, not the brief's 260 (the optional Compose module's two listeners);
  9 TiffinBox entries; `Customer` 0; `Route` 0; `TiffinBoxServer`: `start stop`; `TiffinBoxProperties`: `<init>` only. ⚑9's "260 → 261"
  must be re-measured from 262.
- **The native rung of the ladder (P17) is yours.** This unit's binary never answers, so the startup ladder here has JVM ways
  only (six). `harness/ttfr.py` is the clock (fork → first 200 from `/kitchen`, then POST /shutdown with the token); with three hand entries,
  0.031-0.035 s by hand. No size comparison (S3.14).
- **The native build:** about two minutes here (15 builds over five full runs, 113-140 s; `--no-fallback` warned twice in every one), not byte-for-byte
  reproducible (two md5s, and the reflection-registered method count moved: 3,838 / 3,859); the "found reachable" line held in every
  build. Hash what holds; bound the duration. Build it on the web module alone, after `install` (`native:compile` from the root fails on
  the parent POM). `process-aot` writes into `target/classes`: `clean` every build.
- **The binary's class path is Maven's** (36 jars, the optional Compose module and Jackson 3 among them); the executable jar's is 31.
- **The anchor README's unit-19 section** says the binary stops at start and "the next unit adds the hints": update it when the hints land.
- **Interrupts:** a SIGINT to this receipt's process group mid native build left no native-image process behind (*Interrupted*): the
  builder runs as `java @…/vminvocation.args`, so a `pgrep` for its class name finds nothing — look for `vminvocation.args`.
- Ports 18910-18919; this unit's ports 18900-18909 are free after every run.
