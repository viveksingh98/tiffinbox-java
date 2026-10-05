# c5-unit13 — The Executable Jar, Unpacked

Course 5 · Spring Boot · Section 3 · Verified on **JDK 25.0.4.1, Apache Maven 3.9.16, Spring Boot 4.1.1**, 2026-10-05.
TiffinBox's jar has always run beside a folder of other jars: its manifest names `lib/` and the 33 jars in it, and the jar
copied alone dies on a class from one of them. This unit declares Boot's plugin in `tiffinbox-web`'s POM —
bare, no version, no execution — and deletes the jar plugin's manifest settings and the `copy-dependencies` execution.
Then it opens the new jar (169 entries: TiffinBox's own classes, 31 jars kept whole, Boot's launcher), watches how it starts
(a class loader of the launcher's own, every class read where it sits), flattens it two ways (Boot's parent's way serves;
Course 3's two transformers do not even parse, and made to build they lose Spring Boot's own `spring.factories` and the
start), unpacks it with Boot's own tool (a thin jar and `lib/`, the shape TiffinBox started the unit with), and drops it into
a folder an older release left — where the old `Class-Path` header, kept, loads the old classes.

The change lands in `../c5-tiffinbox`; `after/` is this unit's frozen copy of it (`diff -rq -x target` empty). "Before" is
`../c5-unit11/after/` (the anchor as the last unit to change it left it; unit 12 did not change it), **copied** to
`.harness/before/`; the deploy folder's `lib/` comes from `../c5-unit10/after/`, **copied** to `.harness/older/` and built
there. Nothing here writes into another unit's folder. Clean builds, offline; every number the video speaks is asserted;
three runs per capture; and no capture, no README and no slide holds the demo token (masked, and counted: *The demo token*).

```
export JAVA_HOME=/opt/homebrew/opt/openjdk@25
export PATH="$JAVA_HOME/bin:$PATH"
./receipts.sh     # 10 captures, 3 runs each; every spoken number asserted; 0 raw tokens; a published-md5 mismatch stops it
```

**Either bash.** `./receipts.sh` runs macOS's `/bin/bash` 3.2; `bash receipts.sh` runs the first `bash` on your `PATH` — here
Homebrew's 5.3. Both give the same ten hashes (2026-10-05, BLUE: 3/3 under each). From bash 5.2 on, an `&` in the replacement of
`${x/pattern/replacement}` stands for the matched text (`patsub_replacement`, on by default), which turned `startjar`'s
`&& exec java` into `&& java && java  exec java`; the script switches that option off (RED #13).

**A fresh clone.** `.m2-demo` is git-ignored, so a clone's is empty: the first build's offline attempt cannot resolve Boot's
parent, and `build()` asks Maven Central once (the terminal says `offline: no - …`); only then does the script check that the
parent POM — which two captures read — is there. If neither `.m2-demo` nor Central can resolve it, the build stops with that
said (RED #14). The exercise's commands are offline: run `./receipts.sh` once first. **Measured by BLUE (2026-10-05)** without
asking Central for anything: a `git clone` of this repository with this unit's new files, its `.m2-demo` empty, Maven pointed by a
`.mvn/maven.config` at the clone's root to a read-only mirror on 127.0.0.1 that served this unit's own `.m2-demo`. With the
mirror down, the first build stopped with the message above. With it up, three builds went to it (`offline: no - …`: `after`,
the previous tree, `shade-boot`), 1,139 requests, 0 not found; every capture 3/3 and `= published`, exit 0; then the exercise's
three blocks, run as written in an `env -i` shell, printed the same transcript as `exercise/solution/SOLUTION.md`.

(`receipts.sh` carries the same two `export` lines at its top; a bare `java` on this Mac is 23.0.1.) `receipts.sh` **dies**
when a capture's md5 differs from `receipts.md5` — it prints the `DIFFERS` line first, so you can see which one moved
(tested 2026-10-05: with `before`'s published hash altered by one character, the run printed `before … DIFFERS from the
published c5a8d885…`, stopped with exit 1 and released its lock; `receipts.md5` was restored). A whole run takes about
2 min 20 s on the author's Mac (9 builds, then 10 captures × 3).

**The repository.** Every build runs `mvn -o` against this unit's own `.m2-demo` (`$M2` in the script): a copy of
`../c5-unit11/.m2-demo`, plus the Section 3 seed `spring-boot/_research/m2-seed-s3/` (the S3 probe's repository: the shade
plugin 3.6.2 and its four artifacts, Boot's plugin and loader tools), copied with `rsync --ignore-existing` and **without its
`com/tiffinbox/`** (locally installed TiffinBox jars, markers naming no repository: a module-only build could have picked a
stale `tiffinbox-core` from there). Every `_remote.repositories` marker left says `central`. Nothing was downloaded. Each of
the nine builds prints `built <tree> · offline: yes` (or `no - …`) on the terminal. Offline re-run of the frozen tree:
`mvn -o -B -f after/pom.xml -Dmaven.repo.local="$PWD/.m2-demo" verify` → BUILD SUCCESS.

## The anchor change

One file changed, none new (README aside) — `change`, below, shows every changed code line:
- `tiffinbox-web/pom.xml` — gains `spring-boot-maven-plugin`, declared bare: two lines, `groupId` and `artifactId`. Boot's
  parent (`spring-boot-starter-parent` 4.1.1, lines 207-215) manages its version and carries the `repackage` execution; the
  declaration is what binds it to `package` (ledger P24: the previous build ran no `spring-boot` goal). It loses the jar
  plugin's `<archive>` block (`Main-Class`, `addClasspath`, `classpathPrefix`) and the `copy-dependencies` execution: 26 code
  lines removed, 2 added.
- `README.md` (the anchor's) — a new section, *Course 5 · unit 13 — one executable jar*, with the run command (unchanged), the
  two commands that give a class path back (`extract`, then `java -cp "…/lib/*"`), and the warning about an old `lib/`; and a
  stale note on Course 3's *Build* section (its manifest and `lib/` listing).

**The run command is unchanged** — `java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431`, with its
token — and the seven responses hash to `115c36bac276128e245ca57df11c2891` (`serve`). **`target/lib/` is gone**: every later
receipt that built a class path from it takes one from the jar instead (*For the next units*, below).

## The demo token — fake, and never printed

TiffinBox does not start without its shutdown token (unit 11). Every run starts in a folder under `.harness/` holding a
config tree, `secrets/tiffinbox/shutdown-token` (`-rw-------`, folders `drwx------`), with a 26-character demo token that is
fake and looks it; `receipts.sh` writes it when it runs (`.harness/` is git-ignored). The token never reaches a command line:
the seven requests read it from the file (`$CURLSET PORT TOKENFILE`). Every capture is masked — the token becomes
`[masked: the 26-character token]` (`gsub`) — and `receipts.sh` counts the raw token in each run's own output **before**
masking (`.harness/raw-*`: 0 in all 30 capture runs), then in every capture, this README, the anchor README, the exercise
and `receipts.md5`: 0. The builder counts it again in the script, the deck and the prompter: 0.

## The folders, the variables and the ports

- `tree/` — the token's config tree; the runs that serve start here. `deploy/` — a server folder an older release left: the
  `lib/` of `../c5-unit10/after` (TiffinBox before its token, built with the jar plugin's `Class-Path` and
  `copy-dependencies`: 33 jars) and a config tree; each `folder` run copies its jar in, then starts it there. `alone/` — the
  previous jar, copied in with nothing else.
- Demo trees, each a copy of `after/` under `.harness/` with one file swapped or added, built clean: `headerkept/`
  (`headerkept/pom.xml`: `after/`'s web POM plus the previous tree's jar-plugin block, byte for byte — B), `shade-boot/`,
  `shade-c3/` (`shade-c3/pom.xml`), `shade-c3o/` (`shade-c3/pom-override.xml`), `twomains/` (+ `exercise/PrintRoutes.java`),
  `startclass/` (`twomains/` + `exercise/solution/pom.xml`).
- On screen: `$CURLSET` = `../c5-unit11/curlset.sh`, the comparison set since the secrets lesson (Course 4's seven requests,
  POST /shutdown with the token's header read from a file) — its folder carries a unit number, so no slide prints the path;
  `$PARENT` = `.m2-demo/org/springframework/boot/spring-boot-starter-parent/4.1.1/spring-boot-starter-parent-4.1.1.pom`;
  `$pid` = the java process `receipts.sh` started; `$C3POM` = `../c3-unit23/pom.xml` (Course 3's packaging POM; `files` only).
- Ports (brief ⚑10, 18840-18849, checked free with `lsof` before anything is wiped): launcher 18840 · folder A and A′ 18841,
  B 18842 (never binds) · shade Boot's 18843, Course 3's 18844 (binds only once the chain that reads `application.yaml` is put
  back) · extract 18845 · serve 18846 · the jar alone 18847 (never binds). 18848-18849 unused (the exercise starts no server).

## Masks, filters and hygiene — every one, declared

1. **Paths and the token:** in every line of every capture (`gsub()`, the patterns escaped as literals): the demo token →
   `[masked: the 26-character token]`; this folder's absolute path → `…`, also in its URL-encoded form (`%20` for each space:
   `-verbose:class` prints `file:` and `jar:nested:` URLs); the folder above it → `…/..`; the home folder → `~`. A last
   check fails if any capture still holds `/Users/`, `/private/` or `/home/`.
2. **`-verbose:class`** prints thousands of lines whose count moves by a line or two from run to run (a JDK class that some
   runs load and some do not: `java.util.concurrent.ForkJoinTask$AdaptedRunnableAction`, from `jrt:/java.base`): no raw total
   is printed. Shown: the named classes' lines, each with its `[uptime][info][class,load]` prefix cut (`sub()`), and the count
   of `org.springframework.boot.loader.*` classes logged (stable over every run here). `folder` B's "not shown" lines count its
   other output exactly, and its class-loading lines by a declared filter (RED #28): the lines whose source is `file:` or
   `jar:` — classes read from a jar or a folder — counted exactly (3651, the same in 8 of 8 runs), and the rest, the JDK's own
   classes and the ones generated while it runs, rounded to the hundred (about 3000: 3023 or 3024 here).
3. **jcmd:** `VM.classloaders`' first line (the pid) → `<pid>:`; trailing blanks dropped (`sub()`), blank lines dropped.
4. **Manifests** are unfolded (a line starting with one space continues the line before); a `Class-Path` is printed counted —
   entries, the first, and whether every one sits under `lib/` — never as its 33 names.
5. **Failed starts** show their exit code and listening count, then their cause: standard error without its stack frames (the
   frames counted) for the jar alone and the `-cp` run; for B, Boot's `Application run failed` line (its level kept, its time,
   pid, thread and logger cut by `sub()`) and every `Caused by:` line, whole, the rest counted; for Course 3's shaded jar, the
   log-format counts, its one ERROR line (time cut), the last `Caused by:` and the fields it rejects as null (sorted: the
   validator reports them in no fixed order).
6. **Maven's logs** are kept in `.harness/build-*.log` and read, never printed whole: the goal lines (`[INFO] --- …`), the shade
   plugin's warnings that name `spring.factories` or the imports file (each warning's jar line), the parse error, the
   main-class error.
7. **Hygiene:** `receipts.sh` unsets every `TIFFINBOX_*` and `SPRING_*` variable, `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`,
   `MAVEN_OPTS` and `MAVEN_ARGS` before it runs anything; it refuses to run twice at once in this folder (`.r-lock`), or with a
   `secrets/` in this folder; `extract`'s destination (`after/tiffinbox-web/target/extracted`, inside the build's own output
   folder) is removed before each of its runs.

**Interrupted.** `receipts.sh`'s exit trap stops the JVM it started in the background, if one still runs, and drops the
lock — on a failed check and on Ctrl-C alike (a background job of a non-interactive shell ignores the terminal's Ctrl-C). Every
command in the trap is guarded, so `set -e` cannot end it early, and `$pid` is cleared after every reap. Tested 2026-10-05:
`SIGINT` sent to the script's process group the moment `folder` A's JVM listened on 18841 → `receipts.sh` exited 130; 5 s
later nothing listened on 18840-18847, no java process ran a TiffinBox jar, and `.r-lock` was gone. **Re-tested by BLUE the same
day** on the new script (started as its own process group with SIGINT at its default, `perl -e '$SIG{INT} = "DEFAULT";
setpgrp(0, 0); exec @ARGV' ./receipts.sh`, SIGINT to the group when 18841 listened, 47 s in): exit 130; 5 s later 0 listeners on
18840-18849, 0 java processes running a TiffinBox jar, `.r-lock` gone.

## 1 · Before — the jar TiffinBox has shipped until now

`.r-before.out` `b5a8d885a89b2f953d15e6523af24fe5` — 18 lines

```
$ unzip -p .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar META-INF/MANIFEST.MF     (folded lines unfolded; the Class-Path counted)
  Manifest-Version: 1.0
  Created-By: Maven JAR Plugin 3.5.0
  Java-Version: 25
  Build-Jdk-Spec: 25
  Implementation-Title: TiffinBox Web
  Implementation-Version: 1.0.0
  Main-Class: com.tiffinbox.web.TiffinBoxServer
  Class-Path: 33 entries, the first lib/tiffinbox-core-1.0.0.jar, every one under lib/: yes
$ ls .harness/before/tiffinbox-web/target/lib
  jars: 33 · each named in the Class-Path: 33
  the jar: 15 entries, 11084 bytes · jars inside it: 0
the same jar, copied alone into an empty folder:
$ mkdir -p .harness/alone && cp .harness/before/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/alone/ && cd .harness/alone && java -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18847
  exit 1 · standard output 0 lines · standard error 6 lines · listening on 18847: 0
  Exception in thread "main" java.lang.NoClassDefFoundError: com/fasterxml/jackson/databind/ObjectMapper
  Caused by: java.lang.ClassNotFoundException: com.fasterxml.jackson.databind.ObjectMapper
  … and 4 stack-frame line(s) of standard error not shown …
```

The manifest names TiffinBox's main class and a `Class-Path` of 33 jars under `lib/`, the 33 in `lib/`: Course 2's runnable
jar, the shape Course 3 called the thin jar. Copied alone, it stops on a class from another jar — Jackson's `ObjectMapper` —
before any port opens.

## 2 · The change — one plugin, declared; the parent's execution; the goals

`.r-change.out` `7c6f785396f87fffcca6516b41e34f29` — 53 lines

```
files, README aside: the previous tree 18 · after/ 18 · in both 18: identical 17, changed 1
  only before: (none)
  only after:  (none)
tiffinbox-web/pom.xml, every changed line but comments and blanks (11 of those not shown):
-        <groupId>org.apache.maven.plugins</groupId>
-        <artifactId>maven-jar-plugin</artifactId>
-        <configuration>
-          <archive>
-            <manifest>
-              <mainClass>com.tiffinbox.web.TiffinBoxServer</mainClass>
-              <addClasspath>true</addClasspath>
-              <classpathPrefix>lib/</classpathPrefix>
-            </manifest>
-          </archive>
-        </configuration>
-      </plugin>
-      <plugin>
-        <groupId>org.apache.maven.plugins</groupId>
-        <artifactId>maven-dependency-plugin</artifactId>
-        <executions>
-          <execution>
-            <id>copy-libs</id>
-            <phase>prepare-package</phase>
-            <goals><goal>copy-dependencies</goal></goals>
-            <configuration>
-              <outputDirectory>${project.build.directory}/lib</outputDirectory>
-              <includeScope>runtime</includeScope>
-            </configuration>
-          </execution>
-        </executions>
+        <groupId>org.springframework.boot</groupId>
+        <artifactId>spring-boot-maven-plugin</artifactId>
  removed 26 · added 2
after/'s tiffinbox-web/pom.xml, the plugin as declared, whole (its lines 48-51):
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
Boot's parent, spring-boot-starter-parent 4.1.1 - what it manages for that plugin:
$ sed -n 207,215p "$PARENT"
          <artifactId>spring-boot-maven-plugin</artifactId>
          <executions>
            <execution>
              <id>repackage</id>
              <goals>
                <goal>repackage</goal>
              </goals>
            </execution>
          </executions>
the goals each build ran in tiffinbox-web (mvn -B clean package, its log): the previous tree 8 · after/ 8
  only the previous tree's: dependency:3.11.0:copy-dependencies (copy-libs)
  only after/'s:            spring-boot:4.1.1:repackage (repackage)
  the last goal: the previous tree jar:3.5.0:jar (default-jar) · after/ spring-boot:4.1.1:repackage (repackage)
```

Two lines added, 26 removed (comments and blanks aside); the declaration, printed whole from `after/`, is four lines — the two
inside a `<plugin>` tag, whose own `<plugin>` and `</plugin>` lines the diff aligns with the old blocks' (RED #25: the voice says
"two lines inside a plugin tag"). Boot's parent manages the plugin's version and its `repackage`
execution (lines 207-215, printed); the previous build's goals in `tiffinbox-web` held no `spring-boot` goal, and this build's
last goal is `spring-boot:4.1.1:repackage (repackage)`. Course 4's comment "even Boot's own parent does not make an executable
jar happen by itself" (ledger P24) held for every tree under that parent until this one: the declaration is the act.

## 3 · Inside — 169 entries, counted by place

`.r-inside.out` `27d8edf4f6336b30e4bbdbd4565151fd` — 33 lines

```
$ jar tf after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar     (counted by place)
  entries: 169 · directories among them: 28
  under BOOT-INF/classes/: 8 · classes 3: Route TiffinBoxApp TiffinBoxServer · YAML files 2: application-audit.yaml application.yaml
  under BOOT-INF/lib/: jars 31 · other files 0
  under org/springframework/boot/loader/: 112 · classes 99
  every other file: META-INF/MANIFEST.MF META-INF/services/java.nio.file.spi.FileSystemProvider META-INF/maven/com.tiffinbox/tiffinbox-web/pom.xml META-INF/maven/com.tiffinbox/tiffinbox-web/pom.properties BOOT-INF/classpath.idx BOOT-INF/layers.idx
  the service file, whole: org.springframework.boot.loader.nio.file.NestedFileSystemProvider
  BOOT-INF/classpath.idx: 31 lines
$ unzip -p after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar META-INF/MANIFEST.MF
  Manifest-Version: 1.0
  Created-By: Maven JAR Plugin 3.5.0
  Java-Version: 25
  Build-Jdk-Spec: 25
  Implementation-Title: TiffinBox Web
  Implementation-Version: 1.0.0
  Main-Class: org.springframework.boot.loader.launch.JarLauncher
  Start-Class: com.tiffinbox.web.TiffinBoxServer
  Spring-Boot-Version: 4.1.1
  Spring-Boot-Classes: BOOT-INF/classes/
  Spring-Boot-Lib: BOOT-INF/lib/
  Spring-Boot-Classpath-Index: BOOT-INF/classpath.idx
  Spring-Boot-Layers-Index: BOOT-INF/layers.idx
$ ls after/tiffinbox-web/target
  classes generated-sources maven-archiver maven-status tiffinbox-web-1.0.0.jar tiffinbox-web-1.0.0.jar.original
  tiffinbox-web-1.0.0.jar 16134092 bytes · tiffinbox-web-1.0.0.jar.original 10605 bytes
BOOT-INF/lib/ (31) against the previous tree's lib/ (33):
  only in lib/:          spring-boot-starter-4.1.1.jar spring-boot-starter-logging-4.1.1.jar spring-boot-starter-validation-4.1.1.jar
  only in BOOT-INF/lib/: spring-boot-jarmode-tools-4.1.1.jar
  spring-boot-starter-4.1.1.jar: classes 0 · Spring-Boot-Jar-Type: dependencies-starter
  spring-boot-starter-logging-4.1.1.jar: classes 0 · Spring-Boot-Jar-Type: dependencies-starter
  spring-boot-starter-validation-4.1.1.jar: classes 0 · Spring-Boot-Jar-Type: dependencies-starter
the 31 nested jars, each against the jar it came from - .m2-demo for 29, core's own build for tiffinbox-core,
  Boot's spring-boot-loader-tools jar for the tools jar: byte for byte the same 31 of 31
```

`BOOT-INF/classes/`: TiffinBox's three classes and its two YAML files. `BOOT-INF/lib/`: 31 jars — the previous `lib/`'s 33,
minus the three starters (each holds no class, and its manifest says `Spring-Boot-Jar-Type: dependencies-starter`), plus
`spring-boot-jarmode-tools-4.1.1.jar` (out of Boot's `spring-boot-loader-tools` jar: no download) — each byte for byte the jar
it came from. At the top, 99 classes of Boot's launcher, and one service file: Boot's file system for jars inside jars. The
manifest's `Main-Class` is Boot's `JarLauncher`; TiffinBox's main class moved to `Start-Class`. `.jar.original` is the plain jar
the jar plugin built. (The three starters' exclusion and their manifest line are two facts side by side here: the cause is
not flipped.)

## 4 · The launcher — the class named by hand, the loaders, the sources

`.r-launcher.out` `093790aa4c2f34ca2b49654eec3ee872` — 27 lines

```
TiffinBox's main class, named, with the jar as the class path:
$ java -cp after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18840
  exit 1 · standard output 0 lines · listening on 18840: 0
  Error: Could not find or load main class com.tiffinbox.web.TiffinBoxServer
  Caused by: java.lang.ClassNotFoundException: com.tiffinbox.web.TiffinBoxServer
the jar, run, with java's class-loading log on:
$ cd .harness/tree && java -verbose:class -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18840
  listens on: 127.0.0.1:18840 · WARN lines 0 · ERROR lines 0
$ jcmd "$pid" VM.classloaders     ($pid: the java process this script started)
<pid>:
+-- <bootstrap>
      |
      +-- "platform", jdk.internal.loader.ClassLoaders$PlatformClassLoader
            |
            +-- "app", jdk.internal.loader.ClassLoaders$AppClassLoader
                  |
                  +-- org.springframework.boot.loader.launch.LaunchedClassLoader
where five classes came from (-verbose:class):
  org.springframework.boot.loader.launch.JarLauncher source: file:…/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar
  com.tiffinbox.web.TiffinBoxServer source: jar:nested:…/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar/!BOOT-INF/classes/!/
  org.springframework.boot.SpringApplication source: jar:nested:…/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar/!BOOT-INF/lib/spring-boot-4.1.1.jar!/
  org.springframework.context.ApplicationContext source: jar:nested:…/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar/!BOOT-INF/lib/spring-context-7.0.9.jar!/
  com.tiffinbox.TiffinBoxProperties source: jar:nested:…/after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar/!BOOT-INF/lib/tiffinbox-core-1.0.0.jar!/
  classes of Boot's launcher (org.springframework.boot.loader.*) that -verbose:class logged: 98
$ $CURLSET 18840 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```

Named by hand, `com.tiffinbox.web.TiffinBoxServer` is not found: it sits under `BOOT-INF/classes/`. Run as a jar, the JVM
starts `JarLauncher` (from the jar file itself, on the app class path), which builds a `LaunchedClassLoader` under the app
loader (`jcmd`); TiffinBox's server comes from `!BOOT-INF/classes/!/` and Spring from `!BOOT-INF/lib/<jar>!/` — `jar:nested:`
URLs: the jars are read where they sit inside the file, not flattened (ledger P14). The seven responses: `115c36ba…`.

## 5 · The folder beside the jar — A/B/A′

`.r-folder.out` `d6041b05bb1747622c3bf3dbf6cfbe84` — 32 lines

```
deploy/: an older release's server folder - lib/ (33 jars: TiffinBox before its shutdown token, built with the
  jar plugin's Class-Path and copy-dependencies) and the token's config tree; each run copies its jar in, then starts it
  that lib/'s TiffinBoxProperties: methods named shutdownToken 0 · after/'s: 1
A   after/'s jar
  the jar's Class-Path: none
$ cp after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/deploy/ && cd .harness/deploy && java -verbose:class -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18841
  listens on: 127.0.0.1:18841 · WARN lines 0 · ERROR lines 0
  com.tiffinbox.web.TiffinBoxServer source: jar:nested:…/.harness/deploy/tiffinbox-web-1.0.0.jar/!BOOT-INF/classes/!/
  com.tiffinbox.TiffinBoxProperties source: jar:nested:…/.harness/deploy/tiffinbox-web-1.0.0.jar/!BOOT-INF/lib/tiffinbox-core-1.0.0.jar!/
$ $CURLSET 18841 .harness/deploy/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
B   headerkept/'s jar: the same plugin, the jar plugin's <archive> block kept
  the jar's Class-Path: 33 entries, the first lib/tiffinbox-core-1.0.0.jar, every one under lib/: yes
$ cp .harness/headerkept/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/deploy/ && cd .harness/deploy && java -verbose:class -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18842
  exit 1 · listening on 18842: 0 · banner lines 1 · Boot's failure report (APPLICATION FAILED TO START): 0
  com.tiffinbox.web.TiffinBoxServer source: jar:nested:…/.harness/deploy/tiffinbox-web-1.0.0.jar/!BOOT-INF/classes/!/
  com.tiffinbox.TiffinBoxProperties source: file:…/.harness/deploy/lib/tiffinbox-core-1.0.0.jar
  Boot: ERROR Application run failed · the "Caused by:" lines, each whole:
  Caused by: org.springframework.beans.BeanInstantiationException: Failed to instantiate [com.tiffinbox.web.TiffinBoxServer]: Constructor threw exception
  Caused by: java.lang.NoSuchMethodError: 'java.lang.String com.tiffinbox.TiffinBoxProperties.shutdownToken()'
  … 55 more line(s) of this run's output not shown: the banner, Boot's log, the stack frames …
  … and the class-loading log: 3651 lines for classes read from a jar or a folder, and about 3000 more - the JDK's own classes and the ones generated while it runs, rounded to the hundred: their number moves by a line or two from run to run …
A′  A, re-run
  the jar's Class-Path: none
$ cp after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar .harness/deploy/ && cd .harness/deploy && java -verbose:class -jar tiffinbox-web-1.0.0.jar --tiffinbox.port=18841
  listens on: 127.0.0.1:18841 · WARN lines 0 · ERROR lines 0
  com.tiffinbox.web.TiffinBoxServer source: jar:nested:…/.harness/deploy/tiffinbox-web-1.0.0.jar/!BOOT-INF/classes/!/
  com.tiffinbox.TiffinBoxProperties source: jar:nested:…/.harness/deploy/tiffinbox-web-1.0.0.jar/!BOOT-INF/lib/tiffinbox-core-1.0.0.jar!/
$ $CURLSET 18841 .harness/deploy/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```

deploy/ holds an older release's `lib/`: its `tiffinbox-core` has no `shutdownToken()` (`javap`: 0, after/'s: 1). **A** —
after/'s jar, no `Class-Path`: every class from inside the jar, `115c36ba…`. **B** — the same plugin, the jar plugin's
`<archive>` block kept: `repackage` keeps its `Class-Path` (33 entries), so `java -jar` puts deploy/'s `lib/` jars on the app
class path; the launcher's loader asks the app loader first, which answers with the older `TiffinBoxProperties`
(`file:…/.harness/deploy/lib/tiffinbox-core-1.0.0.jar`) while `TiffinBoxServer` comes from the jar: exit 1,
`NoSuchMethodError: 'java.lang.String com.tiffinbox.TiffinBoxProperties.shutdownToken()'`, no failure report (ledger P10:
two copies of one name, the loader asked first wins). **A′** = A, line for line. The flipped attribute: the manifest's
`Class-Path`.

## 6 · Shade — the same-named files, Boot's way, Course 3's way

`.r-shade.out` `442df805ed696e69f9d0efac3b876d9b` — 51 lines

```
the same-named files TiffinBox's 31 jars carry - the jars inside after/'s jar, each read where it is:
  META-INF/spring.factories: in 5 jars - spring-aop-7.0.9 spring-boot-4.1.1 spring-boot-autoconfigure-4.1.1 spring-boot-jarmode-tools-4.1.1 spring-boot-validation-4.1.1
  META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports: in 2 jars - spring-boot-autoconfigure-4.1.1 spring-boot-validation-4.1.1
  META-INF/services/org.apache.logging.log4j.util.PropertySource: in 2 jars - log4j-api-2.25.5 spring-boot-4.1.1
  after/'s jar keeps every copy, each inside its own jar - at the top of the jar itself: 0
  spring-boot-4.1.1.jar's own spring.factories: keys 13 · the run listener (EventPublishingRunListener) 1 · the config-data post-processor (ConfigDataEnvironmentPostProcessor) 1 · the YAML loader (YamlPropertySourceLoader) 1 · the logging listener (LoggingApplicationListener) 1 · failure analyzers (FailureAnalyzer=) 1
Boot's way - shade-boot/: the shade plugin declared bare (Boot's parent: its version, an execution, Boot's transformers)
  build: exit 0 · shade:3.6.2:shade (default) @ tiffinbox-web · its warnings naming those two files: 0
  the jar: entries 9898 · jars inside it 0 · its Main-Class: com.tiffinbox.web.TiffinBoxServer
  the imports file: lines 13 · ValidationAutoConfiguration among them 1 · one jar's own copy: none - a merge
  META-INF/spring.factories: keys 17 · one jar's own copy: none - a merge
    the run listener (EventPublishingRunListener) 1 · the config-data post-processor (ConfigDataEnvironmentPostProcessor) 1 · the YAML loader (YamlPropertySourceLoader) 1 · the logging listener (LoggingApplicationListener) 1 · failure analyzers (FailureAnalyzer=) 1
  the log4j service file: lines 3 · one jar's own copy: none - a merge
$ cd .harness/tree && java -jar ../shade-boot/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18843
  listens on: 127.0.0.1:18843 · WARN lines 0 · ERROR lines 0
$ $CURLSET 18843 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
Course 3's way - shade-c3/: the shade plugin with Course 3's execution and its two transformers, pasted as written
  Boot's parent's transformer list, its first entry:
  $ sed -n 252,254p "$PARENT"
                  <transformer implementation="org.apache.maven.plugins.shade.resource.AppendingTransformer">
                    <resource>META-INF/spring.handlers</resource>
                  </transformer>
  build: exit 1 · Unable to parse configuration of mojo org.apache.maven.plugins:maven-shade-plugin:3.6.2:shade for parameter resource: Cannot find 'resource' in class org.apache.maven.plugins.shade.resource.ManifestResourceTransformer
the same file with <transformers combine.self="override"> (shade-c3/pom-override.xml):
  build: exit 0 · BUILD SUCCESS lines 1 · its warnings naming those two files: 2
    spring-boot-autoconfigure-4.1.1.jar, spring-boot-validation-4.1.1.jar define 2 overlapping resources: META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports
    spring-aop-7.0.9.jar, spring-boot-4.1.1.jar, spring-boot-autoconfigure-4.1.1.jar, spring-boot-validation-4.1.1.jar define 1 overlapping resource: META-INF/spring.factories
  the jar: entries 9898 · jars inside it 0 · its Main-Class: com.tiffinbox.web.TiffinBoxServer
  the imports file: lines 12 · ValidationAutoConfiguration among them 0 · one jar's own copy: spring-boot-autoconfigure-4.1.1
  META-INF/spring.factories: keys 1 · one jar's own copy: spring-aop-7.0.9
    the run listener (EventPublishingRunListener) 0 · the config-data post-processor (ConfigDataEnvironmentPostProcessor) 0 · the YAML loader (YamlPropertySourceLoader) 0 · the logging listener (LoggingApplicationListener) 0 · failure analyzers (FailureAnalyzer=) 0
  the log4j service file: lines 3 · one jar's own copy: none - a merge
$ cd .harness/tree && java -jar ../shade-c3o/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18844
  exit 1 · listening on 18844: 0 · banner lines 1 · APPLICATION FAILED TO START: 0 · standard error 0 lines
  log lines in Boot's format (date, level, pid, ---): 0 · in Logback's own (time [thread] LEVEL logger --): 5 · the one at ERROR, its time cut:
  [main] ERROR org.springframework.boot.SpringApplication -- Application run failed
  the last "Caused by:": org.springframework.boot.context.properties.bind.validation.BindValidationException: Binding validation errors on tiffinbox
  the record's fields it rejects as null: cooks days jdbcUrl mealTypes shutdownToken · port among them: 0
that jar again, classes from spring-boot's own spring.factories added to spring-aop's file (jar uf) - then run alone:
  + the YAML loader's key (PropertySourceLoader): keys added 1 · classes 2 · the file now: keys 2
$ cd .harness/tree && java -jar ../putback-yaml/tiffinbox-web-1.0.0.jar --tiffinbox.port=18844
  exit 1 · listening on 18844: 0 · the record's fields it rejects as null: cooks days jdbcUrl mealTypes shutdownToken
  + that key and five more - the run listener, the listener that runs environment post-processors, the config-data
    post-processor, its location resolvers and its loaders: keys added 6 · classes 9 · the file now: keys 7
$ cd .harness/tree && java -jar ../putback-config/tiffinbox-web-1.0.0.jar --tiffinbox.port=18844
  listens on: 127.0.0.1:18844 · WARN lines 0 · ERROR lines 0
$ $CURLSET 18844 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```

Same-named files across the 31 jars: `META-INF/spring.factories` in 5, the imports file in 2, the log4j `PropertySource`
service file in 2. Boot's jar keeps every copy, each inside its own jar (0 at the top of the jar). **Flattened Boot's way**
(the parent's shade execution, `start-class` for the manifest): the imports file and `spring.factories` are merges (13 lines,
17 keys), and it serves — 9,898 entries, 0 jars inside: this is the fat jar Course 3 defined. **Course 3's two transformers**,
pasted into this Boot-parented POM, do not parse: Maven merged the child's list into the parent's entry by entry, and the
parent's first entry is an `AppendingTransformer` with a `<resource>`. With `combine.self="override"` it builds (BUILD
SUCCESS, two overlap warnings), and the services transformer merges the one service file two jars share (3 lines) — but
`spring.factories` and the imports file are not service files: the imports file is spring-boot-autoconfigure's own (12 lines,
validation's gone) and `spring.factories` is spring-aop's own (1 key). spring-boot's own copy is gone — the run listener, the
config-data post-processor, the YAML loader, the logging listener, the failure analyzers: 0 of each in the shaded file — and
the start reads no `application.yaml` (5 of the record's 6 fields rejected as null; `port` came from the command line), logs in
Logback's own format, prints no failure report, exits 1 (ledger P15, the fat-jar half).

**Which lines it was missing** (RED #4: the cause is not the YAML loader alone). The same shaded jar, with lines of spring-boot's
own `spring.factories` added to spring-aop's (`jar uf`, each class checked against spring-boot's own registration under that
key): the YAML loader's key alone (`PropertySourceLoader`, 2 classes) → exit 1, the same five fields null; that key plus the
five keys of the chain that reads `application.yaml` at all (`SpringApplicationRunListener` → `EventPublishingRunListener`,
`ApplicationListener` → `EnvironmentPostProcessorApplicationListener`, `EnvironmentPostProcessor` →
`ConfigDataEnvironmentPostProcessor`, `ConfigDataLocationResolver` and `ConfigDataLoader` → their config-tree and standard
classes: 9 classes, 7 keys) → it listens on 18844 and serves `115c36ba…`. The third resolver and loader (environment-variable
locations) and every other key stay out. The voice says "Boot's own, which registers the code that reads application dot yaml,
is gone".

## 7 · Extract — the jar, unpacked by Boot's own tool

`.r-extract.out` `5bffefa50e34ffc513b7b672425c3744` — 23 lines

```
after/README.md's extract command, read from the file, run as written from after/:
$ cd after && java -Djarmode=tools -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar extract --destination tiffinbox-web/target/extracted
  exit 0 · printed: 0 line(s)
$ ls after/tiffinbox-web/target/extracted
  lib tiffinbox-web-1.0.0.jar
  the thin jar: entries 15 · classes 3 · jars inside it 0 · Main-Class: com.tiffinbox.web.TiffinBoxServer
  its Class-Path: 31 entries, the first lib/tiffinbox-core-1.0.0.jar, every one under lib/: yes
  lib/: jars 31 · the same names as BOOT-INF/lib/: yes · byte for byte the nested jars: 31
the thin jar, run with java -jar (the README's note), class-loading log on:
$ cd .harness/tree && java -verbose:class -jar ../../after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar --tiffinbox.port=18845
  listens on: 127.0.0.1:18845 · WARN lines 0 · ERROR lines 0
  classes of Boot's launcher (org.springframework.boot.loader.*) that -verbose:class logged: 0
  com.tiffinbox.web.TiffinBoxServer source: file:…/after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar
  org.springframework.boot.SpringApplication source: file:…/after/tiffinbox-web/target/extracted/lib/spring-boot-4.1.1.jar
$ $CURLSET 18845 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
after/README.md's class-path command, read from the file - its paths made relative to tree/, its port 18431 made 18845:
$ cd .harness/tree && java -cp "../../after/tiffinbox-web/target/extracted/tiffinbox-web-1.0.0.jar:../../after/tiffinbox-web/target/extracted/lib/*" com.tiffinbox.web.TiffinBoxServer --tiffinbox.port=18845
  listens on: 127.0.0.1:18845 · WARN lines 0 · ERROR lines 0
$ $CURLSET 18845 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```

The README's extract command, run as written from `after/`, writes a thin jar (15 entries, TiffinBox's three classes,
`Main-Class: com.tiffinbox.web.TiffinBoxServer`, a `Class-Path` of 31 under `lib/`) and `lib/` (31 jars, byte for byte the
nested ones): Course 2's runnable jar, given back. `java -jar` on it serves with 0 launcher classes loaded; the README's
`java -cp "…extracted/tiffinbox-web-1.0.0.jar:…extracted/lib/*" com.tiffinbox.web.TiffinBoxServer` (its paths made relative to
tree/, its port changed) serves too. Both: `115c36ba…`.

## 8 · Serve — the run command, unchanged

`.r-serve.out` `4f3d9e4d982e5ccf9736a547a59783bb` — 8 lines

```
the run command after/README.md gives: java -jar tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18431
  the same line in the previous tree's README: 2 time(s)
that command, from tree/ (the token's config tree) - the jar's path made relative to tree/, its port 18431 made 18846:
$ cd .harness/tree && java -jar ../../after/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=18846
  listens on: 127.0.0.1:18846 · WARN lines 0 · ERROR lines 0
$ $CURLSET 18846 .harness/tree/secrets/tiffinbox/shutdown-token
POST  /shutdown   -> 200 application/json  {"stopping":true}
  exit 0 · the seven responses: 7 lines · md5 115c36bac276128e245ca57df11c2891
```

The run command read from `after/README.md` is the same line the previous tree's README gives; from tree/, the seven
responses hash to `115c36ba…`.

## 9 · Exercise — two main classes, then one property

`.r-exercise.out` `7d27490efe7a4465038521c6c7b294de` — 8 lines

```
twomains/: after/ plus exercise/PrintRoutes.java in tiffinbox-web/src/main/java/com/tiffinbox/web/tools - a second class with a main method
  build (mvn -B clean package): exit 1 · Unable to find a single main class from the following candidates [com.tiffinbox.web.TiffinBoxServer, com.tiffinbox.web.tools.PrintRoutes]
  the goal that failed: org.springframework.boot:spring-boot-maven-plugin:4.1.1:repackage (repackage)
startclass/: twomains/ with exercise/solution/pom.xml as tiffinbox-web's POM - one property, start-class
  build: exit 0 · PrintRoutes in the jar: 1
$ unzip -p .harness/startclass/tiffinbox-web/target/tiffinbox-web-1.0.0.jar META-INF/MANIFEST.MF | grep -E '^(Main|Start)-Class'
  Main-Class: org.springframework.boot.loader.launch.JarLauncher
  Start-Class: com.tiffinbox.web.TiffinBoxServer
```

## 10 · The demo files, against the files they stand in for

`.r-files.out` `e2aefecd14cdeb73da055ce6f7d08fa7` — 91 lines

```
headerkept/pom.xml, against after/'s tiffinbox-web/pom.xml:
  41a42,57
  >       <!-- Main-Class + Class-Path: the jar is runnable, not just built. No version here
  >            either — the parent's pluginManagement pins 3.5.0. -->
  >       <plugin>
  >         <groupId>org.apache.maven.plugins</groupId>
  >         <artifactId>maven-jar-plugin</artifactId>
  >         <configuration>
  >           <archive>
  >             <manifest>
  >               <mainClass>com.tiffinbox.web.TiffinBoxServer</mainClass>
  >               <addClasspath>true</addClasspath>
  >               <classpathPrefix>lib/</classpathPrefix>
  >             </manifest>
  >           </archive>
  >         </configuration>
  >       </plugin>
  > 
shade-boot/pom.xml, against after/'s tiffinbox-web/pom.xml:
  16a17,21
  >   <properties>
  >     <!-- The main class Boot's parent hands to the shade execution's manifest transformer (<mainClass>${start-class}). -->
  >     <start-class>com.tiffinbox.web.TiffinBoxServer</start-class>
  >   </properties>
  > 
  42,47c47,48
  <       <!-- Course 5: Boot's plugin, declared bare - no version, no execution. Boot's parent manages both, and declaring
  <            the plugin is what binds its repackage goal to package: the jar becomes Boot's executable jar, a jar of jars -
  <            TiffinBox's classes under BOOT-INF/classes, every jar it needs under BOOT-INF/lib, kept whole, and Boot's
  <            launcher at the top. The run command is unchanged. Gone with it: the jar plugin's Main-Class/Class-Path manifest
  <            and the copy-dependencies execution that filled target/lib - a Class-Path header survives repackage, and makes
  <            the jar load the classes it names from a lib/ folder beside it, whatever version sits there. -->
  ---
  >       <!-- shade-boot/, a demo beside the anchor: the shade plugin instead of Boot's, declared bare. Boot's parent
  >            manages its version and an execution with Boot's own transformers. -->
  49,50c50,51
  <         <groupId>org.springframework.boot</groupId>
  <         <artifactId>spring-boot-maven-plugin</artifactId>
  ---
  >         <groupId>org.apache.maven.plugins</groupId>
  >         <artifactId>maven-shade-plugin</artifactId>
shade-c3/pom.xml, against after/'s tiffinbox-web/pom.xml:
  42,47c42,43
  <       <!-- Course 5: Boot's plugin, declared bare - no version, no execution. Boot's parent manages both, and declaring
  <            the plugin is what binds its repackage goal to package: the jar becomes Boot's executable jar, a jar of jars -
  <            TiffinBox's classes under BOOT-INF/classes, every jar it needs under BOOT-INF/lib, kept whole, and Boot's
  <            launcher at the top. The run command is unchanged. Gone with it: the jar plugin's Main-Class/Class-Path manifest
  <            and the copy-dependencies execution that filled target/lib - a Class-Path header survives repackage, and makes
  <            the jar load the classes it names from a lib/ folder beside it, whatever version sits there. -->
  ---
  >       <!-- shade-c3/, a demo beside the anchor: the shade plugin instead of Boot's, with the execution and the two
  >            transformers Course 3's packaging POM wrote (its ${main.class} written out), pasted as they were. -->
  49,50c45,60
  <         <groupId>org.springframework.boot</groupId>
  <         <artifactId>spring-boot-maven-plugin</artifactId>
  ---
  >         <groupId>org.apache.maven.plugins</groupId>
  >         <artifactId>maven-shade-plugin</artifactId>
  >         <executions>
  >           <execution>
  >             <phase>package</phase>
  >             <goals><goal>shade</goal></goals>
  >             <configuration>
  >               <transformers>
  >                 <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
  >                   <mainClass>com.tiffinbox.web.TiffinBoxServer</mainClass>
  >                 </transformer>
  >                 <transformer implementation="org.apache.maven.plugins.shade.resource.ServicesResourceTransformer"/>
  >               </transformers>
  >             </configuration>
  >           </execution>
  >         </executions>
shade-c3/pom-override.xml, against shade-c3/pom.xml:
  52c52
  <               <transformers>
  ---
  >               <transformers combine.self="override">
exercise/solution/pom.xml, against after/'s tiffinbox-web/pom.xml:
  16a17,21
  >   <properties>
  >     <!-- The main class Boot's parent hands to the repackage goal (its <mainClass> reads ${spring-boot.run.main-class}, which is ${start-class}). -->
  >     <start-class>com.tiffinbox.web.TiffinBoxServer</start-class>
  >   </properties>
  > 
shade-c3's transformers against Course 3's ($C3POM, its shade execution; leading blanks dropped):
  3c3
  < <mainClass>${main.class}</mainClass>
  ---
  > <mainClass>com.tiffinbox.web.TiffinBoxServer</mainClass>
headerkept/'s jar block against the previous tree's (lines 42-57 of its tiffinbox-web/pom.xml):
  identical, 16 lines
```

`headerkept/pom.xml` is after/'s web POM plus the previous tree's jar-plugin block (byte for byte its lines 42-57). The shade
overlays swap Boot's plugin for the shade plugin; `shade-c3`'s transformers are Course 3's (`$C3POM`), its `${main.class}`
written out; `pom-override.xml` differs from `pom.xml` in one attribute. The exercise's solution adds one property.

## Exercise

`exercise/README.md` — run `./receipts.sh` once first on a fresh clone (it fills `.m2-demo`). In `.harness/mine`, a copy of after/: add `exercise/PrintRoutes.java` (a second class with a `main`),
package, and the build stops: `Unable to find a single main class from the following candidates
[com.tiffinbox.web.TiffinBoxServer, com.tiffinbox.web.tools.PrintRoutes]`. Make the build choose TiffinBox again without
deleting it, changing only web's POM: done is `Start-Class: com.tiffinbox.web.TiffinBoxServer` with `PrintRoutes` still in the
jar. Run exactly as written in a clean shell (`env -i`): `exercise/solution/SOLUTION.md` (the `start-class` property).

## Found on the way

- **The jar alone dies on Jackson, not Spring:** the class it names is `com/fasterxml/jackson/databind/ObjectMapper`
  (`NoClassDefFoundError`), not a Spring class.
- **"Every `tiffinbox` key is null" (brief finding 3) does not hold:** with Course 3's shaded jar, `port` arrives from the
  command line (Boot adds that property source itself); the five keys `application.yaml` and its imports carry are null.
- **No failure report in B, nor in Course 3's shaded jar.** B logs `Application run failed` and its `Caused by:` chain; the
  shaded jar has lost the failure analyzers along with spring-boot's `spring.factories`.
- **The shade overlays sit on after/'s POM**, not the old one (the probe's kept the old `Class-Path` in its shaded manifests);
  Boot's parent's shade execution then needs `start-class` for `Main-Class`, and also writes `dependency-reduced-pom.xml` into
  the module (a `.harness/` copy here).
- **More same-named files than the three counted:** `META-INF/spring.handlers` and `META-INF/spring.schemas` sit in 3 jars each
  (spring-aop, spring-beans, spring-context). Boot's parent's shade execution appends both; Course 3's two transformers keep one
  copy of each (they are among the overlaps the override build warns about). Not spoken: nothing in TiffinBox reads them.
- **`-verbose:class` totals move by a line from run to run** (6,869 vs 6,870 in one run of three): no raw total is printed;
  `folder` B counts its class-loading lines through a declared filter instead (*Masks*, 2).
- **The cause behind the null settings is the chain, not the YAML loader** (BLUE, after RED #4): putting the YAML loader's key
  back alone changes nothing; the five keys of the chain that reads `application.yaml` make the shaded jar serve (`shade`).
- **"The last course" is Course 4 from here** (RED #2): the fat-jar definition and the services transformer are Course 3's
  (unit 23), and the voice says "Course 3" in all seven places that said "the last course".

## For the next units — 14, 18 — and for RED

**Start TiffinBox from `c5-unit13/after/`** (build it first: `mvn -o -B -f ../c5-unit13/after/pom.xml
-Dmaven.repo.local=<your .m2-demo> -DskipTests clean package`, or copy it with `rsync -a --exclude target` and build the copy):
- **The token:** start in a folder holding `secrets/tiffinbox/shutdown-token` (a config tree: the token and a newline,
  `umask 077`), or set `TIFFINBOX_SHUTDOWN_TOKEN`. Without one it exits 1 (`must not be blank`).
- **The jar:** `java -jar <after>/tiffinbox-web/target/tiffinbox-web-1.0.0.jar --tiffinbox.port=<port>` — no `lib/`, nothing
  beside it.
- **A harness class path (`target/lib/` is gone):** `java -Djarmode=tools -jar <after>/tiffinbox-web/target/tiffinbox-web-1.0.0.jar
  extract --destination <dir>` → `<dir>/tiffinbox-web-1.0.0.jar` (thin: TiffinBox's 3 classes, the YAML, `Class-Path` of 31) and
  `<dir>/lib/` (31 jars); then `java -cp "<harness classes>:<dir>/tiffinbox-web-1.0.0.jar:<dir>/lib/*" <main> --tiffinbox.port=<port>`
  (the JVM expands `lib/*`; measured here with `com.tiffinbox.web.TiffinBoxServer` as the main: `115c36ba…`). Extract into
  `.harness/`, not into a shared tree; a destination that exists and is not empty stops it (measured: exit 1,
  `… already exists and is not empty`) — remove it first. The fallback is
  `mvn dependency:build-classpath` (the probe's way).
- **The seven:** `../c5-unit11/curlset.sh PORT TOKENFILE` (on screen as a `$VAR`), POST /shutdown carries the header read from
  the file → `115c36bac276128e245ca57df11c2891`, and the JVM exits 0.
- **Unit 14:** `tiffinbox-core` lands in Boot's `application` layer only in a reactor build from the root (brief finding 4);
  this tree has no `project.build.outputTimestamp` yet: two clean builds of it gave two jar md5s and one size (16,134,092
  bytes), measured 2026-10-05.
- **RED:** the brief's "B dies before binding" holds (0 listeners on 18842); the brief's 9 entries under `BOOT-INF/classes/`
  count the folder itself (8 below it here).
