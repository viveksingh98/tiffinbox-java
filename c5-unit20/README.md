# c5-unit20 — What Breaks in Native, and the Hints That Fix It

Course 5 · Spring Boot · Section 3, its last unit · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1, GraalVM CE
25.3.4.1** (native-image 25.0.4.1), 2026-10-06. A native image calls by reflection only what its build registered, and Spring's
ahead-of-time step (AOT) registers what Spring itself calls. TiffinBox's router calls the routes it finds by reflection, Jackson reads
the `Customer` record by reflection, and Hibernate Validator calls the token-length rule by reflection: the AOT lesson's binary built
green and stopped at start on the third. This unit puts a hint where each need is, shows what each one adds to Spring's
`reachability-metadata.json`, builds the binary — which serves the same seven responses as the jar — takes the hints out one at a
time to show what each one fixes, keeps the optional Docker Compose module and its Jackson 3 out of the binary, and times the
binary's start from outside.

**The anchor changes (brief ⚑9, plus what the AOT lesson measured):**
- `tiffinbox-web/.../Route.java`: **`@Reflective`** on `@interface Route` — every method carrying `@Route` is registered (here, the
  router's five).
- `tiffinbox-web/.../TiffinBoxServer.java`: **`@RegisterReflectionForBinding(Customer.class)`** — the record, its fields, its
  constructors and its four accessors.
- `tiffinbox-core/.../TiffinBoxProperties.java`: **`@Reflective`** on `isShutdownTokenLongEnough()` — the third registration the AOT
  lesson found missing. ⚑9's two hints alone are **not** enough: without this one the binary still stops at start (`breaks`, D).
- `tiffinbox-web/pom.xml`: the native plugin's **`<exclusions>`** — `org.springframework.boot:spring-boot-docker-compose`,
  `tools.jackson.core:jackson-databind`, `tools.jackson.core:jackson-core`. **The AOT lesson's OPEN item, fixed in the anchor:** the
  plugin builds the binary from Maven's class path, so the AOT lesson's binary held the Compose module and its Jackson 3 (34 and 991
  distinct names in its bytes); with the exclusions, 0 from the Compose module and 3 from Jackson 3 — names that classes of
  `spring-boot`'s own `org/springframework/boot/json/` mention (`native`). The Compose lesson's "the jar holds none of it" now holds
  for the binary too.
- Each annotation comes with its import (`org.springframework.aot.hint.annotation`, in `spring-core`) and a comment; nothing else in
  Java changed. **`TiffinBoxApp.java` is not edited** (`receipts.sh` compares it with the previous tree's, byte for byte), so RED S2
  #8 stays deferred.

`c5-tiffinbox` and this unit's `after/` hold the change, the anchor README's new section, and the AOT lesson's section with its last
paragraph in the past tense — and nothing else (`diff -rq -x target ../c5-tiffinbox after` is empty). Section 4 starts from
`after/`.

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
export GRAALVM_HOME=/path/to/a/graalvm-jdk-25      # GraalVM CE 25.3.4.1 for the published captures - see "The GraalVM"
./receipts.sh     # 6 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

(`receipts.sh` carries the two `export JAVA_HOME`/`PATH` lines at its top; a bare `java` on this Mac is 23.0.1.) It runs for about
45-49 minutes on the author's Mac (2,713, 2,822 and 2,939 s over three full runs on 2026-10-06 — the last two the runs of record, `./receipts.sh` (/bin/bash 3.2.57) and `bash receipts.sh` (Homebrew bash 5.3.9)) — fifteen native builds of about two minutes each are most of it: two
per run of `native`, three per run of `breaks`. It **dies** when a capture's md5 differs from `receipts.md5` (it prints the `DIFFERS`
line first, so you can see which one moved).

## The GraalVM

`receipts.sh` finds the GraalVM through **`GRAALVM_HOME`** and nowhere else — the variable Course 3 used, and the one GraalVM's
Maven plugin reads first (`native` prints `Found GraalVM installation from GRAALVM_HOME variable.`). It refuses to start when the
variable does not name a `bin/native-image`, or when `native-image --version` is not `native-image 25.0.4.1 …` / `GraalVM CE
25.3.4.1+1.1`: another GraalVM prints other lines, so the captures could not match, and the script says so at once rather than after
fifteen native builds. The published captures were made with **GraalVM CE 25.3.4.1**, the build Course 3 pinned, which Vivek approved
on 2026-10-05; it sits in the author's home folder, outside any system location. The GraalVM's folder is never printed: every capture
masks it as `$GRAALVM_HOME` (`gsub`, before the home folder's own mask), and the last checks fail if a capture holds an absolute path.
Nothing on the JVM side uses the GraalVM: every Maven run and every `java` here is the plain JDK 25.0.4.1 (`JAVA_HOME`); only
`native-image` comes from `GRAALVM_HOME`.

## The repository, and what was downloaded

Every build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` on screen and in the script): a copy of `../c5-unit19/.m2-demo`
(`rsync -a`), which holds GraalVM's plugin 1.1.8 and its reachability metadata repository, **less its `com/tiffinbox/`** (the AOT
lesson's own installs: every native build here installs its own two modules first). **Nothing was downloaded** for this unit: every
build said `offline: yes` (on the terminal and in the captures; a run that went online would change a capture's hash, and `cap()`
would stop). The three annotations come from `spring-core` 7.0.9, already there. Every `_remote.repositories` marker says `central`,
but for `com/tiffinbox/` (written by this unit's `install`). The plugin is a build extension of every web-module build (the AOT
lesson's finding): on a fresh clone, the first build — offline, then online once if it must — fills `.m2-demo` from Maven Central, and
the script checks Boot's parent and the plugin are there afterwards.

## The demo token — fake, and never printed

TiffinBox does not start without its shutdown token (the secrets lesson). Every run starts in a folder under `.harness/` that holds a
config tree, `secrets/tiffinbox/shutdown-token` (`-rw-------`, folders `drwx------`), with a 26-character demo token that is fake and
looks it; `receipts.sh` writes it when it runs (`.harness/` is git-ignored). The token never reaches a command line: the seven requests
read it from the file (`$CURLSET PORT TOKENFILE`), and so do `harness/ttfr.py` and `harness/shutdown.sh` (both hand it to the request
from the file). Every capture is masked — the token becomes `[masked: the 26-character token]` (`gsub`) — and `receipts.sh` counts the
raw token in each run's own output **before** masking (`.harness/raw-*`: 0 in all 18 capture runs), then in every capture, this
README, the exercise, the harness, `receipts.md5`, the anchor README — and in the **bytes of all five binaries** each run builds (the
previous tree's, after/'s, B's, C's, D's: 0 each): a binary reads the token from its config tree when it runs, so no build ever sees
it. The builder counts it again in the script, the deck and the prompter: 0. The exercise makes no token of its own.

## The folders, the variables and the ports

- `.harness/before/` — the previous tree, `../c5-unit19/after`, copied; `.harness/after/` — `after/` copied, built the plain way
  before the captures, with a config tree: the ladder's jar.
- `change`: `.harness/plain-before/`, `.harness/plain-after/` — both trees, the plain way, each run on the JVM.
- `metadata`: `.harness/meta-before/`, `.harness/meta-after/` (`-Pnative package`), `.harness/meta-e/` (E: the registrar).
- `native`: `.harness/nat-p/` (the previous tree) and `.harness/nat-a/` (after/), each installed and built natively. `breaks`:
  `.harness/nat-b/`, `nat-c/`, `nat-d/` — after/ copied, one line deleted; A and A′ run `.harness/nat-a`'s binary. The ladder runs
  `.harness/after`'s jar and `.harness/nat-a`'s binary. `.harness/mine/` — the exercise's.
- On screen: `$CURLSET` = `../c5-unit11/curlset.sh`, the comparison set since the secrets lesson — its folder carries a unit number,
  so no slide prints the path; `$M2` = this unit's `.m2-demo`; `$GRAALVM_HOME` = the GraalVM (above); `$pid` = the binary's process,
  which the script started (C's `kill`). Every other command is printed whole.
- Ports (brief ⚑10, 18910-18919, checked free with `lsof` before anything is wiped, 18425 too): `change` 18910 (the previous tree's
  jar), 18911 (after/'s) · `metadata` 18912 (after/'s AOT jar) · `native` 18913 (after/'s binary), 18914 (the previous tree's, which
  stops before it binds) · `breaks` 18913 (A, A′), 18915 (B), 18916 (C), 18917 (D, which stops before it binds) · `ladder` 18918 ·
  18919 unused. The exercise binds nothing.

## Masks, filters and hygiene — every one, declared

1. **Paths, the GraalVM and the token:** in every line of every capture (`gsub()`, the patterns escaped as literals): the demo token →
   `[masked: the 26-character token]`; the GraalVM's folder → `$GRAALVM_HOME`; this folder's absolute path → `…` (also URL-encoded);
   the folder above it → `…/..`; the home folder → `~`; the user name → `<user>`. A last check fails if any capture still holds
   `/Users/`, `/private/` or `/home/`, the GraalVM's folder, or a unit number.
2. **Boot's log** is counted, never printed whole: its WARN and ERROR lines, its first line from its message on, cut before ` with
   PID`. A start that fails prints its last `Caused by:` line, cut after the method it names (` To allow this operation…`, GraalVM's
   advice, follows), and the first stack frame that is neither GraalVM's nor the JDK's. C's standard error: each `Exception in thread`
   line, cut the same way.
3. **Maven's logs** are read, never printed whole: its `offline`/`exit` line per build.
4. **native-image's log:** for after/'s build, the plugin's goal line and the GraalVM it found, the builder's Java line, its two
   warnings (the file URL in the first cut to `'…'`), the eight stage names (timings and memory cut), the analysis's "found reachable"
   line, the warning count and `BUILD SUCCESS`, the rest counted; for the other four, the "found reachable" line. Every build: its exit,
   Maven's result, the stages printed against the count announced, the duration against its bound. The class path is read from the
   plugin's own `Executing:` line, as jar names only; each jar only on native-image's has its class files counted.
5. **The binaries' bytes:** the distinct names under `org.springframework.boot.docker.compose.` and under `tools.jackson.` are counted
   (`grep -ao`); a list of five or fewer is shown, and each name is looked for in the classes of `spring-boot-4.1.1.jar` under
   `org/springframework/boot/json/`.
6. **`reachability-metadata.json`** is read as JSON (`python3`), entry by entry, keyed by type: the counts, the entries only in one file,
   and each entry that differs (its methods, when only they differ).
7. **What is never captured** — a binary's bytes differ from build to build, so only what held in every build is hashed (*The native
   builds, deterministic and not*). No duration is captured: native builds are judged against a bound (1 minute or more, under 10
   minutes); the ladder prints the binary's median against a band and against the jar's median; the seconds go to the terminal
   (quoted below as ranges).
8. **Hygiene:** `receipts.sh` unsets every `TIFFINBOX_*` and `SPRING_*` variable, `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`, `MAVEN_OPTS`,
   `MAVEN_ARGS` and `NATIVE_IMAGE_OPTIONS` before it runs anything; it refuses to run twice at once in this folder (`.r-lock`), with a
   `secrets/` in this folder, or with a `secrets/`, a `tiffinbox-local.yaml` or a `target/` in `after/` (it is never built in place).

**Interrupted.** `receipts.sh`'s exit trap stops the process it started in the background (a TiffinBox jar or binary), if one still
runs, then `sweep()`s this run's process group for anything of a native build — native-image's driver (in `$GRAALVM_HOME/bin`), its
builder JVM, which runs as `java @…/vminvocation.args` (no class name to look for), or a TiffinBox binary — sending TERM, then KILL
after 5 s; then it drops the lock. Maven, native-image and `harness/ttfr.py` run in the foreground: Ctrl-C reaches them directly, and
`ttfr.py` kills the process it forked before it exits. Every command in the trap is guarded, so `set -e` cannot end it early, and
`$pid` is cleared after every reap. **Tested 2026-10-06, twice**: with `receipts.sh` as a job of its own process group (job control on, as a terminal's foreground job is) and `SIGINT` sent to the whole group. **During a native build** — the moment the previous tree's build reached its third stage (in the group: 1 Maven, 1 native-image driver, 1 builder JVM): **exit 130**; 5 s later 0 processes left in the group, and anywhere 0 native-image drivers, 0 builder JVMs, 0 Maven, 0 TiffinBox binaries or jars, 0 listeners on 18425 and 18910-18919, and `.r-lock` gone. **While a binary ran** — the moment after/'s binary, started by the script in the background, listened on 18913 during `native` (8 processes in the group, the binary among them): **exit 130**; 5 s later the same zeros, the binary stopped by the trap.

## The native builds, deterministic and not

Each run of `receipts.sh` builds fifteen binaries: the previous tree's and after/'s three times each (`native`), and B's, C's and D's
three times each (`breaks`). Per tree, every build printed the same lines: the plugin's and the builder's version lines, the two
warnings, the eight stages, the analysis's line, `BUILD SUCCESS` — and the binary did the same things, so every capture is 3 of 3. What
the analysis found reachable, per tree: the previous tree 19,027 types, 27,275 fields and 90,458 methods; after/ 17,798, 25,313 and 82,461; B 17,788, 25,312 and 82,437; C 17,793, 25,306 and 82,434; D 17,798, 25,313 and 82,460. The **binary's bytes differ** from build to build (after/'s binary `96abea1f…` in one full run and `2f1899b9…` in the next; the other four trees' binaries differed between those two runs too), so no
binary is hashed. Each build's duration is counted against a bound: **1 minute or more, under 10 minutes** — 138-179 s over the 45 native builds of those three full runs (longer run by run: 138-169 s, 152-172 s, 156-179 s). The binary's
size is not printed and not compared: Course 3 refused size comparisons, and so does Section 3's rule S3.14.

## 1 · change — the previous tree against after/

Where after/'s code calls by reflection (`grep -n`: the router's `getDeclaredMethods()` and `invoke`, Jackson's `writeValueAsBytes`,
and the token rule Hibernate Validator calls), the files that differ (five: three Java files, the web POM, the anchor README), the
lines each Java file gains that are neither comment nor blank (its import and its annotation; the comment lines counted, and the one
line diff removes is a comment), the POM's new lines (the comment counted). Then both trees built the plain way, each in a copy, their
jars compared entry by entry (4 of 170 differ: the two annotated classes, tiffinbox-core's jar, the POM copy; `BOOT-INF/lib` the same
31 jars, none of them the Compose module's or Jackson 3's), and each jar run as the README runs it: the seven, `115c36ba…`, both.

`.r-change.out` · md5 `b12100232924ac16c1da7dcbeec74363` · 3 of 3

```
where after/'s code calls by reflection - the router, finding its routes and calling one; Jackson, writing each route's answer - and the
rule Hibernate Validator calls while Boot binds the settings (grep -n):
  TiffinBoxServer.java:130: for (Method m : getClass().getDeclaredMethods()) {
  TiffinBoxServer.java:154: respond(exchange, 200, handler.invoke(this));
  TiffinBoxServer.java:175: byte[] body = JSON.writeValueAsBytes(value);
  TiffinBoxProperties.java:57: @AssertTrue(message = "tiffinbox.shutdown-token must be 16 characters or more")
  TiffinBoxProperties.java:58: public boolean isShutdownTokenLongEnough() {
the previous tree - the anchor as the AOT lesson left it - against after/, both copied under .harness/:
$ diff -rq -x target -x secrets .harness/before .harness/after
  Files .harness/before/README.md and .harness/after/README.md differ
  Files .harness/before/tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java and .harness/after/tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java differ
  Files .harness/before/tiffinbox-web/pom.xml and .harness/after/tiffinbox-web/pom.xml differ
  Files .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/Route.java and .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web/Route.java differ
  Files .harness/before/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java and .harness/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java differ
the lines diff adds to each Java file - comment and blank lines counted, not shown:
  tiffinbox-web/src/main/java/com/tiffinbox/web/Route.java:
    import org.springframework.aot.hint.annotation.Reflective;
    @Reflective
    (diff removes 0 - comment lines 0 · adds 7 - not shown: 4 comment lines, 1 blank)
  tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java:
    import org.springframework.aot.hint.annotation.RegisterReflectionForBinding;
    @RegisterReflectionForBinding(Customer.class)
    (diff removes 0 - comment lines 0 · adds 6 - not shown: 4 comment lines, 0 blank)
  tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java:
    import org.springframework.aot.hint.annotation.Reflective;
        @Reflective
    (diff removes 1 - comment lines 1 · adds 9 - not shown: 7 comment lines, 0 blank)
after/'s tiffinbox-web/pom.xml against the previous one - every line diff adds, its comment lines counted, not shown:
          <configuration>
            <exclusions>
              <exclusion>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-docker-compose</artifactId>
              </exclusion>
              <exclusion>
                <groupId>tools.jackson.core</groupId>
                <artifactId>jackson-databind</artifactId>
              </exclusion>
              <exclusion>
                <groupId>tools.jackson.core</groupId>
                <artifactId>jackson-core</artifactId>
              </exclusion>
            </exclusions>
          </configuration>
  lines diff removes: 0 · adds: 19 - not shown: a comment of 3 lines, and 0 blank
both trees, built the plain way - the README's Maven line, offline, clean, each in a copy of its own:
$ cd .harness/plain-before && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built the previous tree · offline: yes · exit 0
$ cd .harness/plain-after && mvn -o -B -Dmaven.repo.local="$M2" -DskipTests clean package
  built after/ · offline: yes · exit 0
  the two executable jars, entry by entry: entries 170 and 170 · the same name and content (CRC-32): 166 · different: 4 - BOOT-INF/classes/com/tiffinbox/web/Route.class BOOT-INF/classes/com/tiffinbox/web/TiffinBoxServer.class BOOT-INF/lib/tiffinbox-core-1.0.0.jar META-INF/maven/com.tiffinbox/tiffinbox-web/pom.xml
  the names under BOOT-INF/lib/ of both: the same: yes · jars under it: 31 · the Compose module's or Jackson 3's among them: 0
each jar on the JVM, as the README runs it, from beside its config tree:
$ cd .harness/plain-before && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18910
  listens on: 127.0.0.1:18910 · WARN lines 0 · ERROR lines 0
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ $CURLSET 18910 .harness/plain-before/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
$ cd .harness/plain-after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18911
  listens on: 127.0.0.1:18911 · WARN lines 0 · ERROR lines 0
  Boot's first line: Starting TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ $CURLSET 18911 .harness/plain-after/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```

## 2 · metadata — what the hints add to Spring's metadata

Both trees built with Boot's profile `native` on the plain JDK (no `native-image` in it), and Spring's two `reachability-metadata.json`
files compared entry by entry: **262 → 263**; `Customer` the one new entry; `TiffinBoxProperties` and `TiffinBoxServer` the two that
differ; `Route` in neither (the annotation needs no entry of its own: the binary reads it off each registered method — C's `routes
mapped`). after/'s jar from that build, run with the generated code: the seven, `115c36ba…`. Then **E**, the general tool — brief ⚑9's
loser, measured and kept out of the anchor: a copy of after/ whose token rule is registered by `harness/hints/ValidatorHints.java`, a
`RuntimeHintsRegistrar` imported by `@ImportRuntimeHints` on that copy's `TiffinBoxApp`, instead of `@Reflective`: Spring wrote the same
file, byte for byte. Course 3 said "the fix is data, not code"; here the data is written by code — an annotation's, or a registrar's.

`.r-metadata.out` · md5 `bac2806d59bfbafa92ca874e56634e2c` · 3 of 3

```
both trees, built with Boot's profile native - the README's line, offline, clean, on the plain JDK; Spring's process-aot writes
reachability-metadata.json, the file a native build reads:
$ cd .harness/meta-before && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean package
  built the previous tree · offline: yes · exit 0
$ cd .harness/meta-after && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean package
  built after/ · offline: yes · exit 0
  the JDK Maven ran on (mvn -version): Java version: 25.0.4.1 · a native-image in it: no
the two files, entry by entry - the previous tree's against after/'s:
  reflection entries: 262 and 263 · the same in both: 260 · only in the previous tree's: 0 · only in after/'s: 1 · different: 2 · resources: 16 and 16, the same: yes
  only in after/'s: com.tiffinbox.Customer · allDeclaredFields · allDeclaredConstructors · methods mealsPerDay mealType name pricePerMeal
  different: com.tiffinbox.TiffinBoxProperties · allDeclaredFields · methods <init> -> <init> isShutdownTokenLongEnough
  different: com.tiffinbox.web.TiffinBoxServer · allDeclaredFields · methods start stop -> customers dashboard kitchen revenue shutdown start stop
  entries for com.tiffinbox.web.Route: 0 and 0
after/'s jar from that build, on the JVM with the generated code - the README's AOT run, its port made 18912:
$ cd .harness/meta-after && java -Dspring.aot.enabled=true -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18912
  listens on: 127.0.0.1:18912 · WARN lines 0 · ERROR lines 0
  Boot's first line: Starting AOT-processed TiffinBoxServer v1.0.0 using Java 25.0.4.1
$ $CURLSET 18912 .harness/meta-after/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
E - the general tool: a copy of after/ whose token rule is registered by code - a RuntimeHintsRegistrar - not by @Reflective:
$ sed -i '' '/^    @Reflective$/d' .harness/meta-e/tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java
  lines deleted: 1
$ cp harness/hints/ValidatorHints.java .harness/meta-e/tiffinbox-web/src/main/java/com/tiffinbox/web/
$ sed -i '' 's/^public class TiffinBoxApp {$/@org.springframework.context.annotation.ImportRuntimeHints(ValidatorHints.class) public class TiffinBoxApp {/' .harness/meta-e/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxApp.java
  its TiffinBoxApp.java against after/'s: lines diff changes 1 - now:
    @org.springframework.context.annotation.ImportRuntimeHints(ValidatorHints.class) public class TiffinBoxApp {
  harness/hints/ValidatorHints.java, the code that registers the method (its lines from 'public void registerHints'):
    |     public void registerHints(RuntimeHints hints, ClassLoader classLoader) {
    |         hints.reflection().registerMethod(
    |                 ReflectionUtils.findMethod(TiffinBoxProperties.class, "isShutdownTokenLongEnough"), ExecutableMode.INVOKE);
$ cd .harness/meta-e && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean package
  built E · offline: yes · exit 0
  E's reachability-metadata.json against after/'s, byte for byte: the same
  E's entry for the settings record: com.tiffinbox.TiffinBoxProperties · allDeclaredFields · methods <init> isShutdownTokenLongEnough
```

## 3 · native — the previous tree's binary, then after/'s

The README's two Maven lines on a copy of each tree, with a config tree beside its README. **The previous tree** (no hints, no
exclusions): green, eight stages; 36 jars on native-image's class path against the executable jar's 31 — six only on native-image's
(the Compose module, 85 class files; Jackson 3's two jars, 218 and 905; three starters, 0 each) and one only in the jar
(`spring-boot-jarmode-tools`, which Boot adds for `-Djarmode=tools`); in its bytes, 34 distinct names from the Compose module and 991
from Jackson 3; run, it stops at start — the AOT lesson's failure, re-measured: `MissingReflectionRegistrationError` on
`isShutdownTokenLongEnough()`, the first frame Hibernate Validator's. **after/**: green, eight stages, its lines shown; 33 jars — the
jar's 31 less the jarmode tools, plus the three starters that hold no class; 0 names from the Compose module, 3 from Jackson 3, each
named in a class of `spring-boot-4.1.1.jar` under `org/springframework/boot/json/` (its JSON parser's support for Jackson 3, compiled
against names it can no longer reach — names only, no classes); no token in its bytes; run, it listens, Boot's first line says
`AOT-processed`, and the seven answer `115c36ba…` — the jar's md5.

`.r-native.out` · md5 `032848ee9ef2179105ce857a50967f6c` · 3 of 3

```
the previous tree - the AOT lesson's anchor: no hints, no exclusions - copied to .harness/nat-p with a config tree; the README's two
Maven lines, offline; $GRAALVM_HOME names the GraalVM:
$ cd .harness/nat-p && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean install
  built .harness/nat-p (both modules, into $M2) · offline: yes · exit 0
$ cd .harness/nat-p && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -pl tiffinbox-web native:compile-no-fork
  19,027 types,  27,275 fields, and  90,458 methods found reachable
  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 10 minutes
  the jars on native-image's class path (the plugin's command line, names only): 36 · in the executable jar's BOOT-INF/lib: 31 · only in the jar: spring-boot-jarmode-tools-4.1.1.jar
  only on native-image's: jackson-core-3.1.5.jar jackson-databind-3.1.5.jar spring-boot-docker-compose-4.1.1.jar spring-boot-starter-4.1.1.jar spring-boot-starter-logging-4.1.1.jar spring-boot-starter-validation-4.1.1.jar
    jackson-core-3.1.5.jar - its class files: 218
    jackson-databind-3.1.5.jar - its class files: 905
    spring-boot-docker-compose-4.1.1.jar - its class files: 85
    spring-boot-starter-4.1.1.jar - its class files: 0
    spring-boot-starter-logging-4.1.1.jar - its class files: 0
    spring-boot-starter-validation-4.1.1.jar - its class files: 0
  in the binary's bytes, distinct names under org.springframework.boot.docker.compose.: 34 · under tools.jackson.: 991
  the demo token in its bytes: 0
its binary, run from beside its config tree as the README runs it, port 18914:
$ cd .harness/nat-p && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18914
  listened on: nothing
  then: Application run failed · lines starting 'Caused by: ' 4 - the last, to the method it names:
    Caused by: org.graalvm.nativeimage.MissingReflectionRegistrationError: Cannot reflectively invoke method 'public boolean com.tiffinbox.TiffinBoxProperties.isShutdownTokenLongEnough()'.
  its first frame outside GraalVM's own and the JDK's: org.hibernate.validator.internal.util.ReflectionHelper.getValue(ReflectionHelper.java:121)
  exit 1 · listening on 18914 now: 0 · its output: 136 lines, 0 on standard error
after/ - the three hints and the exclusions - copied to .harness/nat-a with a config tree; the same two lines:
$ cd .harness/nat-a && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean install
  built .harness/nat-a (both modules, into $M2) · offline: yes · exit 0
$ cd .harness/nat-a && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -pl tiffinbox-web native:compile-no-fork
  its lines, in order (the rest - 134 lines - not shown):
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
    17,798 types,  25,313 fields, and  82,461 methods found reachable
    The build process encountered 2 warnings.
    BUILD SUCCESS
  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 10 minutes
  file: Mach-O 64-bit executable · the demo token in its bytes: 0
  the jars on native-image's class path (the plugin's command line, names only): 33 · in the executable jar's BOOT-INF/lib: 31 · only in the jar: spring-boot-jarmode-tools-4.1.1.jar
  only on native-image's: spring-boot-starter-4.1.1.jar spring-boot-starter-logging-4.1.1.jar spring-boot-starter-validation-4.1.1.jar
    spring-boot-starter-4.1.1.jar - its class files: 0
    spring-boot-starter-logging-4.1.1.jar - its class files: 0
    spring-boot-starter-validation-4.1.1.jar - its class files: 0
  in the binary's bytes, distinct names under org.springframework.boot.docker.compose.: 0 · under tools.jackson.: 3
    those 3: tools.jackson.core tools.jackson.core.type.TypeReference tools.jackson.databind.ObjectMapper
    each one named in a class of spring-boot-4.1.1.jar, under org/springframework/boot/json/: 3 of 3
its binary, run from beside its config tree as the README runs it, port 18913:
$ cd .harness/nat-a && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18913
  listens on: 127.0.0.1:18913 · WARN lines 0 · ERROR lines 0
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ $CURLSET 18913 .harness/nat-a/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```

## 4 · breaks — the hints, one at a time (A/B/A′, C, D)

A: after/'s binary, the one `native` built, its seven responses shown whole. **B**: a copy of after/ with the binding hint's line
deleted (`sed`, exactly one line), built with the README's two lines: its metadata has no `Customer` (262 entries, every other entry the
same as A's); its `/customers` answers `500 {"error":"InvalidDefinitionException"}` — Jackson's exception, named by TiffinBox's
handler — and the other six lines are A's. **A′** = A re-run, the same command: the seven, line for line. **C**: the route annotation's
`@Reflective` deleted: the server's entry is back to `start stop`; the binary starts and the router still maps all five routes
(`getDeclaredMethods()` and the annotations on them work); but `GET /kitchen` gets no answer in 5 s (`curl -m 5` → `000`, exit 28), nor
does POST /shutdown (`harness/shutdown.sh`, the token's header read from the file), and standard error holds one uncaught `Exception
in thread ""` per request — `MissingReflectionRegistrationError: Cannot reflectively invoke method … kitchen()` and `… shutdown()`:
finding a method is allowed, calling it is not; SIGTERM stops it (exit 143). **D**: the token rule's `@Reflective` deleted, the router's
and the record's hints still in: the record's entry is back to `<init>`, and the binary stops at start exactly as the previous tree's.

`.r-breaks.out` · md5 `8b06d769a9921dc60cc4c186499fc512` · 3 of 3

```
the hints, one at a time. A: after/'s binary, built by capture native. B, C and D: a copy of after/ with one hint's line deleted,
built with the README's two Maven lines, offline; each binary run from beside its config tree as the README runs it.
A - after/'s binary, port 18913:
$ cd .harness/nat-a && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18913
  listens on: 127.0.0.1:18913 · WARN lines 0 · ERROR lines 0
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ $CURLSET 18913 .harness/nat-a/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 200 application/json  [{"name":"Meera","mealsPerDay":1,"pricePerMeal":150,"mealType":"NON_VEG"},{"name":"Priya","mealsPerDay":1,"pricePerMeal":120,"mealType":"VEGAN"},{"name":"Ravi","mealsPerDay":2,"pricePerMeal":120,"mealType":"VEG"},{"name":"Sunil","mealsPerDay":3,"pricePerMeal":100,"mealType":"VEG"}]
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
B - without the binding hint, in .harness/nat-b:
$ sed -i '' '/^@RegisterReflectionForBinding(Customer.class)$/d' .harness/nat-b/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java
  lines deleted: 1
$ cd .harness/nat-b && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean install
  built .harness/nat-b (both modules, into $M2) · offline: yes · exit 0
$ cd .harness/nat-b && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -pl tiffinbox-web native:compile-no-fork
  17,788 types,  25,312 fields, and  82,437 methods found reachable
  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 10 minutes
  the demo token in its bytes: 0 · its reachability-metadata.json against A's:
  reflection entries: 263 and 262 · the same in both: 262 · only in A's: 1 · only in B's: 0 · different: 0 · resources: 16 and 16, the same: yes
  only in A's: com.tiffinbox.Customer · allDeclaredFields · allDeclaredConstructors · methods mealsPerDay mealType name pricePerMeal
$ cd .harness/nat-b && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18915
  listens on: 127.0.0.1:18915 · WARN lines 0 · ERROR lines 0
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ $CURLSET 18915 .harness/nat-b/secrets/tiffinbox/shutdown-token
  GET   /customers  -> 500 application/json  {"error":"InvalidDefinitionException"}
  GET   /revenue    -> 200 application/json  {"monthRevenue":24300}
  GET   /dashboard  -> 200 application/json  {"customers":4,"monthRevenue":24300,"pausedDays":5,"names":["Meera","Priya","Ravi","Sunil"]}
  GET   /kitchen    -> 200 application/json  {"ordersCooked":120,"ordersValue":24300}
  GET   /nowhere    -> 404 text/html  <h1>404 Not Found</h1>No context found for request
  GET   /shutdown   -> 405 application/json  {"error":"method not allowed"}
  POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 c655d5305b17e6530dbaddfe49028cf2
  response lines different from A's: 1 - GET /customers
A' - A re-run:
$ cd .harness/nat-a && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18913
  listens on: 127.0.0.1:18913 · WARN lines 0 · ERROR lines 0
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
$ $CURLSET 18913 .harness/nat-a/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
  its seven against A's, line for line: the same
C - without the route annotation's @Reflective, in .harness/nat-c:
$ sed -i '' '/^@Reflective$/d' .harness/nat-c/tiffinbox-web/src/main/java/com/tiffinbox/web/Route.java
  lines deleted: 1
$ cd .harness/nat-c && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean install
  built .harness/nat-c (both modules, into $M2) · offline: yes · exit 0
$ cd .harness/nat-c && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -pl tiffinbox-web native:compile-no-fork
  17,793 types,  25,306 fields, and  82,434 methods found reachable
  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 10 minutes
  the demo token in its bytes: 0 · its reachability-metadata.json against A's:
  reflection entries: 263 and 263 · the same in both: 262 · only in A's: 0 · only in C's: 0 · different: 1 · resources: 16 and 16, the same: yes
  different: com.tiffinbox.web.TiffinBoxServer · allDeclaredFields · methods customers dashboard kitchen revenue shutdown start stop -> start stop
$ cd .harness/nat-c && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18916
  listens on: 127.0.0.1:18916 · WARN lines 0 · ERROR lines 0
  Boot's first line: Starting AOT-processed TiffinBoxServer using Java 25.0.4.1
  TiffinBox's own line: routes mapped:  [GET /customers, GET /dashboard, GET /kitchen, GET /revenue, POST /shutdown]
$ curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://127.0.0.1:18916/kitchen
  printed: 000 · curl exit 28
$ harness/shutdown.sh 18916 .harness/nat-c/secrets/tiffinbox/shutdown-token
  POST /shutdown -> 000 · curl exit 28
  still running: yes · its standard error, each line naming a thread, to the method it names:
    Exception in thread "" org.graalvm.nativeimage.MissingReflectionRegistrationError: Cannot reflectively invoke method 'java.lang.Object com.tiffinbox.web.TiffinBoxServer.kitchen()'.
    Exception in thread "" org.graalvm.nativeimage.MissingReflectionRegistrationError: Cannot reflectively invoke method 'java.lang.Object com.tiffinbox.web.TiffinBoxServer.shutdown()'.
$ kill $pid    # SIGTERM, to the binary this script started
  exit 143 · listening on 18916 now: 0
D - without the token rule's @Reflective - the router's and the record's hints still in - in .harness/nat-d:
$ sed -i '' '/^    @Reflective$/d' .harness/nat-d/tiffinbox-core/src/main/java/com/tiffinbox/TiffinBoxProperties.java
  lines deleted: 1
$ cd .harness/nat-d && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -DskipTests clean install
  built .harness/nat-d (both modules, into $M2) · offline: yes · exit 0
$ cd .harness/nat-d && mvn -o -B -Dmaven.repo.local="$M2" -Pnative -pl tiffinbox-web native:compile-no-fork
  17,798 types,  25,313 fields, and  82,460 methods found reachable
  exit 0 · BUILD SUCCESS · stages it printed: 8 of the 8 it announces · its duration, against the bound: 1 minute or more, under 10 minutes
  the demo token in its bytes: 0 · its reachability-metadata.json against A's:
  reflection entries: 263 and 263 · the same in both: 262 · only in A's: 0 · only in D's: 0 · different: 1 · resources: 16 and 16, the same: yes
  different: com.tiffinbox.TiffinBoxProperties · allDeclaredFields · methods <init> isShutdownTokenLongEnough -> <init>
$ cd .harness/nat-d && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18917
  listened on: nothing
  then: Application run failed · lines starting 'Caused by: ' 4 - the last, to the method it names:
    Caused by: org.graalvm.nativeimage.MissingReflectionRegistrationError: Cannot reflectively invoke method 'public boolean com.tiffinbox.TiffinBoxProperties.isShutdownTokenLongEnough()'.
  its first frame outside GraalVM's own and the JDK's: org.hibernate.validator.internal.util.ReflectionHelper.getValue(ReflectionHelper.java:121)
  exit 1 · listening on 18917 now: 0 · its output: 136 lines, 0 on standard error
```

## 5 · ladder — the binary's start, timed from outside

`harness/ttfr.py` (the AOT lesson's clock, unchanged) forks the command, asks `/kitchen` every 2 ms until the first `200`, then sends
POST /shutdown with the token's header and waits for the exit: the clock starts before the process exists and stops when a client is
served — never Boot's `Started … in` line (P23). Two ways, interleaved — the executable jar (after/, the plain way) and after/'s binary,
each from beside its config tree — six rounds, round 1 a warm-up (a new binary's first start was slower — by hand, 2026-10-06: 0.154 s,
then 0.030-0.031 s; why was not measured). The capture prints the binary's median of the five counted
runs against a band (**over 0.01 s, under 0.1 s**) and against a tenth of the jar's median; the jar's own seconds are judged only
through that ratio (they moved between runs of this script: medians 1.285-1.876 s over five runs of the script, higher run by run). Measured, the runs of record (rounds 2-6, three
captures each): the binary 0.040-0.053 s, its medians 0.043-0.046 s (`./receipts.sh`), and 0.044-0.050 s, medians 0.048-0.050 s (`bash receipts.sh`); 0.032-0.044 s in the three runs before them. Every median sat under a tenth of the jar's — between a thirty-sixth and a forty-fifth of it. Both rose run by run, as the native builds' durations did: the Mac had been building native images for hours (its temperature was not measured). On this Mac: Apple M1, 8 cores, 16 GB, JDK 25.0.4.1. **This pays P17's native rung** — a start, on one
Mac, as a band; no size and no throughput figure (Course 3: "no start-up time, no throughput claim, no size comparison"; S3.14;
throughput is owed to Course 18 unit 06).

`.r-ladder.out` · md5 `990ba1f501ff082efd657712d9164ac3` · 3 of 3

```
the start, timed from outside: harness/ttfr.py forks the command, asks /kitchen until the first 200, then sends POST /shutdown
with the token. Two ways, each from beside its config tree, port 18918; 6 rounds, each round both ways in turn; round 1 is a warm-up.
  1 the executable jar, after/ built the plain way - $ cd .harness/after && java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18918
  2 after/'s binary, built by capture native - $ cd .harness/nat-a && tiffinbox-web/target/tiffinbox-web --tiffinbox.port=18918
  every run: a 200, then exit 0 after POST /shutdown: 12 of 12
the 5 counted rounds - each way's median, the middle of its 5 runs; the binary's against a band, then against the jar's (the seconds go to the terminal, never to this capture):
  2 the binary: its median over 0.01 s and under 0.1 s: yes
  2 against 1: the binary's median under a tenth of the jar's: yes
```

## 6 · exercise — the exercise, run as written

`exercise/README.md`'s four lines, run exactly as written from this folder (Maven `-q` still prints Boot's banner and two log lines:
the AOT step starts TiffinBox's `main`), then `exercise/solution/SOLUTION.md`'s one line, exactly as written.

`.r-exercise.out` · md5 `767fba2e3b5ad8f8fd4c564244315759` · 3 of 3

```
exercise/README.md's commands, run exactly as written from this folder - 4 lines:
  $ export JAVA_HOME=/opt/homebrew/opt/openjdk@25
  $ export PATH="$JAVA_HOME/bin:$PATH"
  $ rm -rf .harness/mine && mkdir -p .harness/mine && rsync -a --exclude target after/ .harness/mine/after/
  $ mvn -o -B -q -f .harness/mine/after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -Pnative -DskipTests clean package
  exit 0 · printed: 9 line(s)
the solution's line (exercise/solution/SOLUTION.md), run exactly as written, from this folder:
$ f=.harness/mine/after/tiffinbox-web/target/spring-aot/main/resources/META-INF/native-image/com.tiffinbox/tiffinbox-web/reachability-metadata.json; w=$(grep -c '"type": "com\.tiffinbox\.Customer"' $f); m=$(sed -n '/"type": "com\.tiffinbox\.Customer"/,/^    }/p' $f | grep -o '"name": "[A-Za-z]*"' | cut -d'"' -f4 | paste -sd' ' -); sed -i '' '/^@RegisterReflectionForBinding(Customer.class)$/d' .harness/mine/after/tiffinbox-web/src/main/java/com/tiffinbox/web/TiffinBoxServer.java && mvn -o -B -q -f .harness/mine/after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" -Pnative -DskipTests clean package > /dev/null && echo "com.tiffinbox.Customer entries - with the hint: $w, methods $m · deleted, built again: $(grep -c '"type": "com\.tiffinbox\.Customer"' $f)"
com.tiffinbox.Customer entries - with the hint: 1, methods mealsPerDay mealType name pricePerMeal · deleted, built again: 0
  exit 0
```


## Exercise

`exercise/README.md`: *"Your turn: delete the binding hint, run the AOT step again, and search the generated metadata for Customer."*
(18 words, the deck's last slide before the recap card). It copies `after/` and runs the AOT step once — no GraalVM — and leaves the
rest to the viewer. Done: `com.tiffinbox.Customer entries - with the hint: 1, methods mealsPerDay mealType name pricePerMeal ·
deleted, built again: 0`. The measured answer, run exactly as written in a clean shell: `exercise/solution/SOLUTION.md`. `receipts.sh`
runs the README's lines and the solution's line exactly as written (`exercise`), and asserts the Done line is a line of that capture,
of the README and of the solution.

## Found on the way

- **Finding is allowed; calling is not** (`breaks`, C). Without the route hint, GraalVM 25 still answered `getDeclaredMethods()` and the
  `@Route` annotations on TiffinBoxServer (`routes mapped` lists all five) — the entry Spring wrote for the server (`allDeclaredFields`,
  `start`, `stop`) was enough to find them — but refused `Method.invoke` on each. The error, `MissingReflectionRegistrationError`, is not
  an `Exception`: TiffinBox's handler catches `Exception`, so the request's thread dies with the error uncaught and **no response is
  ever sent** — the client waits. `../c5-unit11/curlset.sh` sets no time limit on its requests, so against that binary it would wait
  forever: C uses `curl -m 5` and `harness/shutdown.sh` (5 s) instead. POST /shutdown is a route too, so only a signal stops that
  binary (SIGTERM: 143).
- **The annotation `Route` needs no entry of its own** (`metadata`: 0 in both files): the binary reads `@Route` off each registered method.
- **TiffinBox logs nothing when a route fails** (B: Boot's log, 0 WARN and 0 ERROR lines): the 500's body names the exception's class,
  `InvalidDefinitionException`, and that is all a client or an operator learns. (By hand: of the executable jar's 31 libraries, only
  `jackson-databind-2.22.2.jar` defines a class of that name — `com.fasterxml.jackson.databind.exc.InvalidDefinitionException`.)
- **E's registrar wrote a byte-identical file**: the registrar class itself gets no entry; what it registers is indistinguishable from
  the annotation's.
- **The metadata still names the Compose module's two listeners** (`process-aot` reads Maven's class path, so 262 and 263 include
  them), while native-image, with the module excluded, finds neither class: the build printed the same two warnings as before (Spring's
  `--no-fallback`), nothing about them, and the binary serves.
- **The exclusions shrink what the analysis reaches**: 19,027 types found reachable in the previous tree's build, 17,798 in after/'s
  (both 3 of 3), with the hints added.
- **Jackson 3 leaves three names behind**: `tools.jackson.core`, `tools.jackson.core.type.TypeReference`,
  `tools.jackson.databind.ObjectMapper` — named by classes of `spring-boot`'s `org/springframework/boot/json/` (by hand: its
  `JsonParserFactory` holds `tools.jackson.databind.ObjectMapper` as a string; its `JacksonJsonParser` and two inner classes reference
  `tools/jackson/core/type/TypeReference`); the classes themselves are not in the binary.
- **The plugin's `exclusions` parameter** (`compile-no-fork`, 1.1.8) takes a list of Maven `Exclusion`s and matches groupId and artifactId
  exactly (read off the plugin's `isExcluded`, by `javap`, then measured: 36 → 33 jars). No wildcard.
- **The binary's jar on the JVM is untouched**: the plain jars differ only where the source does; the exclusions are plugin
  configuration, so the POM copy Maven puts in the jar is the fourth difference.

## For Section 4 — and for RED

**Section 4 (Operating the App) starts from `after/`** — `../c5-tiffinbox` is identical to it (`diff -rq -x target`, empty on
2026-10-06). What it inherits, measured here:

- **The native binary serves the seven** (`115c36ba…`), with three hints and three exclusions. A code path that reflection reaches is
  unregistered until something registers it, and a binary only says so when that path runs (C: at the first request; D: at start).
  Whether what Section 4 adds works in the binary is unmeasured here: re-measure the binary when Section 4 changes TiffinBox — a JVM run
  is no witness for it.
- **The exclusions** name three jars by groupId and artifactId. A new optional or development-only dependency is on native-image's class
  path unless it is added to them.
- **A route that throws an `Error` is never answered** (TiffinBox's handler catches `Exception`): a hazard for any later unit that puts a
  route or an endpoint behind reflection or a missing class. `curlset.sh` has no request time limit.
- **RED S2 #8 stays deferred**: `TiffinBoxApp.java` is unedited here (and asserted so).
- **The repository**: this unit's `.m2-demo` holds the native plugin and its metadata repository; seed from it, less `com/tiffinbox/`.
- **Interrupts**: native-image's builder runs as `java @…/vminvocation.args`; the trap's sweep looks for it by that, in the run's
  process group.
- Ports 18910-18919 are free after every run.
